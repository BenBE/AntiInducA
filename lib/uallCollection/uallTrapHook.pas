unit uallTrapHook;

interface

uses windows, uallUtil, uallKernel;

function TrapHook(pTargetFunction: Pointer; pCallbackFunction: Pointer; var pNewFunction: Pointer): Boolean; stdcall;

implementation

type
  PListItem = ^TListItem;
  TListItem = packed record
    pAddr: Pointer;
    pNextItem: PListItem;
  end;

type
  TList = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Item: Pointer);
    procedure Delete(ItemIndex: Integer);
    function IndexOf(Item: pointer): Integer;
    function ItemAt(ItemIndex: Integer): Pointer;
    function Count: Integer;
  private
    FirstItem: pListItem;
end;


constructor TList.Create;
begin
  inherited Create;
  FirstItem := nil;
end;

destructor TList.Destroy;
begin
  while (FirstItem <> nil) do
    self.Delete(0);
  inherited Destroy;
end;

function TList.Count: Integer;
var SearchItem: PListItem;
begin
  SearchItem := self.FirstItem;
  Result := 0;
  while SearchItem <> nil do
  begin
    Inc(Result);
    SearchItem := SearchItem^.pNextItem;
  end;

end;

procedure TList.Add(Item: Pointer);
var pSearchItem: PListItem;
begin
  if (self.FirstItem = nil) then
  begin
    New(self.FirstItem);
    self.FirstItem^.pAddr := Item;
    self.FirstItem^.pNextItem := nil;
  end else
  begin
    pSearchItem := FirstItem;
    while pSearchItem^.pNextItem <> nil do
      pSearchItem := pSearchItem.pNextItem;
    New(pSearchItem^.pNextItem);
    pSearchItem^.pNextItem.pAddr := Item;
    pSearchItem^.pNextItem.pNextItem := nil;
  end;
end;

procedure TList.Delete(ItemIndex: Integer);
var pSearchItem, pDeleteItem: PListItem;
begin
  if (ItemIndex = 0) and (self.FirstItem <> nil) then
  begin
    pSearchItem := self.FirstItem^.pNextItem;
    Dispose(self.FirstItem);
    self.FirstItem := pSearchItem;
  end else
  if (ItemIndex > 0) and (self.FirstItem <> nil) then
  begin
    pSearchItem := self.FirstItem;
    while (ItemIndex > 1) and (pSearchItem^.pNextItem <> nil) do
    begin
      Dec(ItemIndex);
      pSearchItem := pSearchItem^.pNextItem;
    end;
    if (ItemIndex = 1) and (pSearchItem^.pNextItem <> nil) then
    begin
      pDeleteItem := pSearchItem^.pNextItem^.pNextItem;
      Dispose(pSearchItem^.pNextItem);
      pSearchItem^.pNextItem := pDeleteItem;
    end;
  end;
end;

function TList.ItemAt(ItemIndex: Integer): Pointer;
var SearchItem: PListItem;
begin
  SearchItem := self.FirstItem;
  while ItemIndex > 0 do
  begin
    if (SearchItem <> nil) then
      SearchItem := SearchItem.pNextItem;
    Dec(ItemIndex);
  end;
  if SearchItem <> nil then
    Result := SearchItem.pAddr else
    Result := nil;
end;

function TList.IndexOf(Item: Pointer): Integer;
var dwItemIndex: DWord;
    pSearchItem: PListItem;
begin
  pSearchItem := self.FirstItem;
  dwItemIndex := 0;
  Result := -1;
  while (pSearchItem <> nil) do
  begin
    if pSearchItem.pAddr = Item then
      Result := dwItemIndex;
    inc(dwItemIndex);
    pSearchItem := pSearchItem.pNextItem;
  end;
end;


var pTrapMemory: array[0..$100] of byte;
    dwRetHook: DWord;
    dwTrapAddr: DWord;
    dwEspReg: DWord;

procedure SetTrapFlagBegin;
asm
  MOV EAX, DWORD PTR [ESP]
  MOV DWORD [dwRetHook], EAX
  PUSHF
  OR DWORD PTR  [ESP], $100
  POPF
end;
procedure SetTrapFlagEnd; asm end;

procedure HookHandlerA;
asm
  MOV EAX, DWORD PTR [ESP+$C]
  MOV EBX, TContext(EAX).EIP;
  MOV DWORD PTR [dwTrapAddr], EBX
  MOV EBX, DWORD PTR [dwRetHook]
  MOV TContext(EAX).EIP, EBX
  XOR EAX, EAX
end;

function HookThread(pTargetFunction: Pointer): DWord; stdcall;
var dwSize: DWord;
    pTrapMemoryCall: procedure;
    dwOverwriteSize: DWord;
    i: DWord;
begin
  dwOverwriteSize := 0;
  dwSize := 0;
  for i := 0 to DWord(@SetTrapFlagEnd)-DWord(@SetTrapFlagBegin)-1 do
    if (PByte(DWord(@SetTrapFlagBegin)+i)^ <> $C3) then
      Inc(dwSize) else Break;
  while (dwOverwriteSize < 6) do
  begin
    CopyMemory(@pTrapMemory[0],@SetTrapFlagBegin,dwSize);
    CopyMemory(@pTrapMemory[dwSize],Pointer(DWord(pTargetFunction)+DWord(dwOverwriteSize)),High(pTrapMemory)-dwSize);
    @pTrapMemoryCall := @pTrapMemory[0];
    asm
      PUSH OFFSET HookHandlerA
      PUSH DWORD PTR FS:[0]
      MOV DWORD PTR FS:[0], ESP
      PUSHAD
      PUSHFD
      MOV DWORD PTR [dwEspReg], ESP
      CALL pTrapMemoryCall
      MOV ESP, DWORD PTR [dwEspReg]
      POPFD
      POPAD
      POP DWORD PTR FS:[0]
      POP EAX
    end;
    inc(dwOverwriteSize,DWord(dwTrapAddr)-DWord(@pTrapMemory[0])-dwSize);
  end;
  Result := dwOverwriteSize;
end;


function TrapHook(pTargetFunction: Pointer; pCallbackFunction: Pointer; var pNewFunction: Pointer): Boolean; stdcall;
var dwThreadID: DWord;
    dwExitCode: DWord;
    JumpCode: TJmpCode;
    dwOldProtect: DWord;
    Debugger: Boolean;
begin
  Result := False;
  asm
    MOV [Debugger], 0
    PUSH OFFSET HookHandlerA
    PUSH DWORD PTR FS:[0]
    MOV DWORD PTR FS:[0], ESP
    PUSHAD
    PUSHFD
    MOV DWORD PTR [dwEspReg], ESP
    CALL @@TestTrap
    JMP @@TestEnd

  @@TestTrap:
    MOV EAX, DWORD PTR [ESP]
    MOV DWORD [dwRetHook], EAX
    PUSHF
    OR DWORD PTR  [ESP], $100
    POPF
    NOP
    MOV DWORD PTR [Debugger], 1

  @@TestEnd:
    MOV ESP, DWORD PTR [dwEspReg]
    POPFD
    POPAD
    POP DWORD PTR FS:[0]
    POP EAX
  end;
  if Debugger then
  begin
    MessageBoxA(0,'TrapHook doesnt work in IDE and some Debuggers',nil,0);
    Exit;
  end;

  dwThreadID := CreateThread(nil,0,@HookThread,pTargetFunction,0,dwThreadID);
  WaitForSingleObject(dwThreadID,INFINITE);
  GetExitCodeThread(dwThreadID,dwExitCode);
  JumpCode.bPush := $68;
  JumpCode.bRet := $C3;
  if (dwExitCode >= 6) and (dwExitCode < 20) then
  begin
    pNewFunction := VirtualAlloc(nil,dwExitCode+SizeOf(TJmpCode),MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
    CopyMemory(pNewFunction,pTargetFunction,dwExitCode);
    JumpCode.pAddr := Pointer(DWord(pTargetFunction)+dwExitCode);
    CopyMemory(Pointer(DWord(pNewFunction)+dwExitCode),@JumpCode,SizeOf(TJmpCode));
    JumpCode.pAddr := pCallbackFunction;
    if VirtualProtect(pTargetFunction,dwExitCode,PAGE_EXECUTE_READWRITE,dwOldProtect) then
    begin
      CopyMemory(pTargetFunction,@JumpCode,SizeOf(TJmpCode));
      VirtualProtect(pTargetFunction,dwExitCode,dwOldProtect,dwOldProtect);
    end else
      VirtualFree(pNewFunction,dwExitCode+SizeOf(TJmpCode),MEM_RELEASE);
  end;
end;



end.
