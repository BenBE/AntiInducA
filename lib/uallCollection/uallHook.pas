unit uallHook;

{$I 'uallCollection.inc'}

interface

uses Windows, uallDisasm, uallProcess, uallKernel, tlhelp32, uallUtil;

function HookCode(pOrigFunction, pCallbackFunction: Pointer; var pNewFunction: Pointer): Boolean; stdcall;
function UnhookCode(var pNewFunction: Pointer): Boolean; stdcall;

function HookCodeKernel9x(pOrigFunction, pCallbackFunction: Pointer; var pNewFunction: Pointer): Boolean; stdcall;
function UnhookCodeKernel9x(var pNewFunction: Pointer): Boolean; stdcall;

function HookCodeNt(pOrigFunction, pCallbackFunction: Pointer; var pNewFunction: Pointer): Boolean; stdcall;
function UnhookCodeNt(var pNewFunction: Pointer): Boolean; stdcall;

function HookApiIAT(dwModuleHandle: DWord; pOrigFunction, pCallbackFunction: Pointer): Boolean; stdcall; overload;
function HookApiIAT(pOrigFunction, pCallbackFunction: Pointer): Boolean; stdcall; overload;
function HookApiIAT(sTargetModule, sTargetProc: String; pCallbackFunction: Pointer; var pOrigFunction: Pointer): Boolean; stdcall; overload;
function UnhookApiIAT(pCallbackFunction: Pointer; pOrigFunction: Pointer): Boolean; Stdcall; Overload;

function InjectLibrary(dwProcessID: DWord; pLibraryName: PChar): Boolean; stdcall;
function UnloadLibrary(dwProcessID: DWord; pLibraryName: PChar): Boolean; stdcall;

function InjectMe(dwProcessID: DWord; pDllMain: Pointer): Boolean; stdcall;
function InjectMeParam(dwProcessID: DWord; pDllMain: Pointer; pParam: PChar): Boolean; stdcall;

function GlobalInjectLibrary(pLibraryName: PChar): DWord; Stdcall;
function GlobalUnloadLibrary(pLibraryName: PChar): DWord; stdcall;

implementation

{$IFDEF DELPHI5_DOWN}
type
    PPointer = ^Pointer;
{$ENDIF}

function UnloadLibrary(dwProcessID: DWord; pLibraryName: PChar): Boolean; stdcall;

  function ThreadUnloadBegin(pParam: Pointer): DWord; stdcall;
  var XGetModuleHandleA: function(pModuleName: PChar): DWord; stdcall;
      XFreeLibrary     : function(dwModuleHandle: DWord): DWord; stdcall;
      pModuleName      : PChar;
      dwModuleHandle   : DWord;
  begin
    Result := 0;

    @XGetModuleHandleA := PPointer(DWord(pParam)+0*SizeOf(Pointer))^;
    @XFreeLibrary := PPointer(DWord(pParam)+1*SizeOf(Pointer))^;
    pModuleName := Pointer(DWord(pParam)+2*SizeOf(Pointer));

    if (@XGetModuleHandleA <> nil) and
       (@FreeLibrary <> nil) then
    begin
      dwModuleHandle := XGetModuleHandleA(pModuleName);
      if (dwModuleHandle <> 0) then
        Result := XFreeLibrary(dwModuleHandle);
    end;
  end;
  procedure ThreadUnloadEnd; asm end;

var
  dwProcessID2  : DWord;
  dwWritten     : DWord;
  dwThreadID    : DWord;
  dwMemSize     : DWord;
  pTargetMemory : Pointer;
  pTargetMemMove: Pointer;
  pUsedAddr     : array[0..1] of Pointer;
begin
  Result := False;
  dwProcessID2 := OpenProcess(PROCESS_ALL_ACCESS,false,dwProcessID);
  if (dwProcessID2 <> 0) then
    dwProcessID := dwProcessID2;

  dwMemSize := 4*SizeOf(Pointer)+Length(pLibraryName)+1+Integer(@ThreadUnloadEnd)-Integer(@ThreadUnloadBegin);
  pTargetMemory := VirtualAllocExX(dwProcessID,nil, dwMemSize, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  pTargetMemMove := pTargetMemory;

  if (PTargetMemory <> nil) then
  begin
    pUsedAddr[0] := GetProcAddress(GetModuleHandle('kernel32.dll'),'GetModuleHandleA');
    pUsedAddr[1] := GetProcAddress(GetModuleHandle('kernel32.dll'),'FreeLibrary');
    if WriteProcessMemory(dwProcessID,pTargetMemMove,@pUsedAddr[0],SizeOf(pUsedAddr),dwWritten) and
       (dwWritten = SizeOf(pUsedAddr)) then
    begin
      pTargetMemMove := Pointer(DWord(pTargetMemMove)+SizeOf(pUsedAddr));
      if WriteProcessMemory(dwProcessID,pTargetMemMove, pLibraryName,Length(pLibraryName),dwWritten) then
      begin
        pTargetMemMove := Pointer(Integer(pTargetMemMove)+Length(pLibraryName)+1);
        if WriteProcessMemory(dwProcessID,pTargetMemMove, @ThreadUnloadBegin,
          DWord(@ThreadUnloadEnd)-DWord(@ThreadUnloadBegin),dwWritten) then
          Result := (CreateRemoteThreadX(dwProcessID,nil,0,pTargetMemMove,pTargetMemory,0,dwThreadID) <> 0);
      end;
    end;
  end;
  if (dwProcessID2 <> 0) then
    CloseHandle(dwProcessID2);
end;

function InjectLibrary(dwProcessID: DWord; pLibraryName: PChar): Boolean; stdcall;
var
  dwProcessID2 : DWord;
  dwMemSize    : DWord;
  dwWritten    : DWord;
  dwThreadID   : DWord;
  pLLA         : Pointer;
  pTargetMemory: Pointer;
begin
  Result := False;

  dwProcessID2 := OpenProcess(PROCESS_ALL_ACCESS,false,dwProcessID);
  if (dwProcessID2 <> 0) then
    dwProcessID := dwProcessID2;

  dwMemSize := Length(pLibraryName)+1;
  pTargetMemory := VirtualAllocExX(dwProcessID,nil,dwMemSize, MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  pLLA := GetProcAddress(GetModuleHandleA('kernel32.dll'),'LoadLibraryA');
  if (pLLA <> nil) and (pTargetMemory <> nil) and (pLibraryName <> nil) then
  begin
    if WriteProcessMemory(dwProcessID,pTargetMemory,pLibraryName,dwMemSize,dwWritten) and
      (dwWritten = dwMemSize) then
    Result := CreateRemoteThreadX(dwProcessID,nil,0,pLLA,pTargetMemory,0,dwThreadID) <> 0;
  end;
  if (dwProcessID2 <> 0) then
    CloseHandle(dwProcessID2);
end;

function GlobalInjectLibrary(pLibraryName: PChar): DWord; stdcall;
var
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  ContinueLoop: Boolean;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  Result := 0;
  while ContinueLoop do 
  begin
    if (uallHook.InjectLibrary(FProcessEntry32.th32ProcessID, pLibraryName)) Then
        Inc(Result);
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function GlobalUnloadLibrary(pLibraryName: PChar): DWord; stdcall;
var
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  ContinueLoop: BOOL;
  s: String;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  S := '';
  while ContinueLoop do
  begin
    if (uallHook.UnloadLibrary(FProcessEntry32.th32ProcessID, pLibraryName)) then
        Inc(Result);
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function InjectMe(dwProcessID: DWord; pDllMain: Pointer): Boolean; stdcall;
begin
  Result := InjectMeParam(dwProcessID, pDllMain, nil);
end;

function InjectMeParam(dwProcessID: DWord; pDllMain: Pointer; pParam: PChar): Boolean; stdcall;
var
  IDH        : PImageDosHeader;
  INH        : PImageNtHeaders;
  SEC        : PImageSectionHeader;
  dwread     : DWord;
  dwSecCount : DWord;
  dwFileSize : DWord;
  dwMemSize  : DWord;
  i          : Integer;
  iFileHandle: Integer;
  pFileMem   : Pointer;
  pAll       : Pointer;
  sLibraryName : String;
  dwProcessID2 : DWord;
  pTargetMem : Pointer;
  dwThreadID : DWord;
  dwWritten  : DWord;
begin
  Result := False;
  if (pDllMain = nil) then
    Exit;

  sLibraryName := ParamStr(0);
  iFileHandle := CreateFileA(PChar(sLibraryName), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL, 0);

  if (iFileHandle < 0) then
    Exit;

  dwFileSize := GetFileSize(iFileHandle, nil);
  if (dwFileSize = 0) then
  begin
    CloseHandle(iFileHandle);
    Exit;
  end;

  pFileMem := VirtualAlloc(nil, dwFileSize, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if (pFileMem = nil) then
  begin
    CloseHandle(iFileHandle);
    Exit;
  end;

  ReadFile(iFileHandle, pFileMem^, dwFileSize, dwRead, nil);
  IDH := pFileMem;
  if (isBadReadPtr(IDH,SizeOf(TImageDosHeader))) or
     (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
  begin
    VirtualFree(pFileMem,dwFileSize,MEM_RELEASE);
    CloseHandle(iFileHandle);
    Exit;
  end;

  INH := Pointer(DWord(pFileMem) + DWord(IDH^._lfanew));
  if (isBadReadPtr(INH, SizeOf(TImageNtHeaders))) or
     (INH^.Signature <> IMAGE_NT_SIGNATURE) then
  begin
    VirtualFree(pFileMem,dwFileSize,MEM_RELEASE);
    CloseHandle(iFileHandle);
    Exit;
  end;

  SEC := Pointer(Integer(INH)+SizeOf(TImageNtHeaders));
  dwMemSize := INH^.OptionalHeader.SizeOfImage;
  if (dwMemSize = 0) then
  begin
    VirtualFree(pFileMem, dwFileSize, MEM_RELEASE);
    CloseHandle(iFileHandle);
    Exit;
  end;

  if (pParam <> nil) then
    dwMemSize := dwMemSize+DWord(Length(pParam))+1;

  pAll := VirtualAlloc(nil,dwMemSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pAll = nil) then
  begin
    VirtualFree(pFileMem, dwFileSize, MEM_RELEASE);
    CloseHandle(iFileHandle);
    Exit;
  end;

  dwProcessID2 := OpenProcess(PROCESS_ALL_ACCESS, False, dwProcessID);
  if (dwProcessID2 <> 0) then
    dwProcessID := dwProcessID2;

  pTargetMem := VirtualAllocExX(dwProcessID, nil, dwMemSize, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if (pTargetMem = nil) then
  begin
    VirtualFree(pFileMem, dwFileSize, MEM_RELEASE);
    VirtualFree(pAll,dwMemSize, MEM_RELEASE);
    CloseHandle(iFileHandle);
    if (dwProcessID2 <> 0) then
      CloseHandle(dwProcessID2);
    Exit;
  end;

  dwSecCount := INH^.FileHeader.NumberOfSections;
  CopyMemory(pAll, IDH, DWord(SEC)-DWord(IDH)+dwSecCount*SizeOf(TImageSectionHeader));
  for i := 0 to dwSecCount-1 do
  begin
    CopyMemory(Pointer(DWord(pAll) + SEC^.VirtualAddress),
      Pointer(DWord(pFileMem) + DWord(SEC^.PointerToRawData)),
      SEC^.SizeOfRawData);
    SEC := Pointer(Integer(SEC) + SizeOf(TImageSectionHeader));
  end;

  ChangeReloc(Pointer(INH^.OptionalHeader.ImageBase),
              pAll,
              Pointer(DWord(pAll)+INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress),
              pTargetMem,
              INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size);
  CreateImportTable(pAll, Pointer(DWord(pAll)+INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress));

  if (pParam <> nil) then
    CopyMemory(Pointer(DWord(pAll)+ dwMemSize-DWord(Length(pParam))-1), pParam,Length(pParam));

  if WriteProcessMemory(dwProcessID, pTargetMem, pAll, dwMemSize, dwWritten) and
     (dwWritten = dwMemSize) then
  begin
    pDllMain := Pointer((DWord(pDllMain) - GetModuleHandle(nil)) + DWord(pTargetMem));

    if (pParam = nil) then
      Result := CreateRemoteThreadX(dwProcessID, nil, 0, pDllMain, nil, 0, dwThreadID) <> 0 else
      Result := CreateRemoteThreadX(dwProcessID, nil, 0, pDllMain, Pointer(DWord(pTargetMem)+dwMemSize-1-DWord(Length(pParam))), 0, dwThreadID) <> 0;
  end;

  VirtualFree(pAll, dwMemSize, MEM_RELEASE);
  VirtualFree(pFileMem, dwFileSize, MEM_RELEASE);
  CloseHandle(iFileHandle);

  if (dwProcessID2 <> 0) then
    CloseHandle(dwProcessID2);
end;

function HookIAT(pDllHandle, pImportSection, pOrigFunction, pCallbackFunction: Pointer): boolean; stdcall;
var
  pCurrentImportBlock: PImportBlock;
  pThunks            : PPointer;
  dwOldProtect       : DWord;
begin
  Result := False;
  pCurrentImportBlock := Pointer(DWord(pDllHandle) + DWord(pImportSection));
  if (isBadReadPtr(pCurrentImportBlock,SizeOf(TImportBlock))) then
    Exit;
    
  while (pCurrentImportBlock^.dwName <> 0) and
        (pCurrentImportBlock^.pFirstThunk <> nil) do
  begin
    pThunks := Pointer(DWord(pCurrentImportBlock^.pFirstThunk) + DWord(pDllHandle));
    while (not isBadReadPtr(pThunks,SizeOf(DWord))) and
          (pThunks^ <> Nil) do
    begin
      if VirtualProtect(pThunks, SizeOf(DWord), PAGE_EXECUTE_READWRITE, dwOldProtect) then
      begin
        if (pThunks^ = pOrigFunction) then
        begin
          Result := True;
          pThunks^ := pCallbackFunction;
        end;
        VirtualProtect(pThunks, SizeOf(DWord), dwOldProtect, dwOldProtect);
      end;
      Inc(pThunks);
    end;
    pCurrentImportBlock := Pointer(Integer(pCurrentImportBlock) + SizeOf(TImportBlock));
  end;
end;

function HookApiIAT(dwModuleHandle: DWord; pOrigFunction, pCallbackFunction: Pointer): Boolean; stdcall; overload;
var
    IDH: PImageDosHeader;
    INH: PImageNtHeaders;
begin
  Result := False;
  IDH := Pointer(dwModuleHandle);
  if (isBadReadPtr(IDH,SizeOf(TImageDosHeader)) or
     (IDH^.e_magic <> IMAGE_DOS_SIGNATURE)) then
    Exit; {Wrong PE (DOS) Header.}

  INH := Pointer(Cardinal(IDH) + Cardinal(IDH^._lfanew));
  If (isBadreadPtr(INH,SizeOf(TImageNtHeaders)) or
     (INH^.Signature <> IMAGE_NT_SIGNATURE)) then
    Exit; {Wrong OE (NT) Header.}

  {Redirect IAT}
  Result := HookIAT(
      Pointer(IDH),
      Pointer(INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress),
      pOrigFunction,
      pCallBackFunction);
End;

function HookApiIAT(pOrigFunction, pCallbackFunction: Pointer): Boolean; stdcall; overload;
var
  sAllModules: String;
  sModule    : String;
begin
  Result := False;
  sAllModules := FindModulesInProcess(GetCurrentProcessId);
  while (Length(sAllModules) > 0) do  {for each module call HookApiIAT}
  begin
    sModule := Copy(sAllModules, 1, Pos(#13#10, sAllModules) - 1);
    Result := Result or HookApiIAT(GetModuleHandleA(PChar(sModule)), pOrigFunction, pCallbackFunction);
    Delete(sAllModules, 1, Length(sModule)+2);
  end;
end;

function HookApiIAT(sTargetModule, sTargetProc: String; pCallbackFunction: Pointer; var pOrigFunction: Pointer): Boolean; stdcall; overload;
var
  Module: Cardinal;
begin
  Result := False;
  Module := GetModuleHandle(PChar(sTargetModule));

  If Module = 0 then
    Module := LoadLibrary(PChar(sTargetModule));  {Module is not loaded?}

  If Module = 0 then
    Exit; {Cant load library.}

  pOrigFunction := GetProcAddress(Module, PChar(sTargetProc));
  if pOrigFunction = nil then
    Exit; {Cant find exported function inside the library}

  Result := HookApiIAT(pOrigFunction, pCallbackFunction);
end;

function UnhookApiIAT(pCallbackFunction: Pointer; pOrigFunction: Pointer): Boolean; Stdcall; Overload;
begin
  Result := HookApiIAT(pCallbackFunction, pOrigFunction);
end;

function VirtualProtectKernel9x(dwAddress: Pointer; dwSize: DWord; bWriteable: Boolean): Boolean; stdcall;
var VXDCallProtect: function (Service: DWord; Page: DWord; Size: DWord; AndPermission: DWord; OrPermission: DWord): DWord; stdcall;
begin
  Result := False;
  if (not is9x) then
    Exit;
  @VXDCAllProtect := GetProcAddressX(GetModuleHandle('kernel32.dll'),PChar(1));
  if (@VXDCallProtect = nil) then
    Exit;
  if bWriteable then
    Result := VXDCallProtect(PageModifyPermissions,DWord(dwAddress) shr 12,
       dwSize shr 12, 0, PC_STATIC OR PC_USER OR PC_WRITEABLE) > 0 else
    Result := VXDCallProtect(PageModifyPermissions,DWord(dwAddress) shr 12,
       dwSize shr 12, 0, PC_STATIC OR PC_USER) > 0;
end;


procedure nextCallData;
asm
  MOV EBX, $12345678
  MOV EAX, DWORD PTR FS:[30h]
  CMP EAX, EBX
  JNE @@nextCall
  PUSH $12345678
  RET
@@nextCall:
end;
function SimpleSize(pAddr: pointer): DWord;
var dwSize: DWord;
begin
  dwSize := 0;
  repeat
    inc(dwSize);
  until PByte(DWord(pAddr)+dwSize-1)^ = $C3;
  Result := dwSize;
end;

function UnHookCodeKernel9x(var pNewFunction: Pointer): Boolean; stdcall;
var
  Error: Boolean;
  JumpCode: TJmpCode;
  dwSizeAll: DWOrd;
  dwSize: DWord;
  sName: String;
  pWalker: Pointer;
  dwJmpSize: DWord;
begin
  Result := False;
  if (pNewFunction = nil) then
    Exit;
  dwJmpSize := SizeOf(TJmpCode);
  dwSizeAll := 0;
  JumpCode.bPush := $68;
  JumpCode.bRet := $C3;
  pWalker := pNewFunction;
  try
    repeat
      Error := not InstructionInfo(pWalker, sName, dwSize);
      Inc(dwSizeAll, dwSize);
      pWalker := Pointer(DWord(pWalker) + dwSize);
    until ((dwSizeAll >= dwJmpSize) or Error);
  except
    Exit;
  end;
  try
    CopyMemory(@JumpCode,Pointer(DWord(pNewFunction)+dwSizeAll),SizeOf(TJmpCode));
    VirtualProtectKernel9x(Pointer(DWord(JumpCode.pAddr)-dwSizeAll),$1000, True);
    CopyMemory(Pointer(DWord(JumpCode.pAddr)-dwSizeAll),pNewFunction,dwSizeAll);
    VirtualProtectKernel9x(Pointer(DWord(JumpCode.pAddr)-dwSizeAll),$1000, False);
    VirtualFree(Pointer(DWord(pNewFunction)-SimpleSize(@nextCallData)),$1000, MEM_RELEASE);
    Result := True;
  except
    Exit;
  end;
end;


function HookCodeKernel9x(pOrigFunction, pCallbackFunction: Pointer; var pNewFunction: Pointer): Boolean; stdcall;
var JumpCode: TJmpCode;
    Error: Boolean;
    pWalker: Pointer;
    sName: String;
    dwSize: DWord;
    dwSizeAll: DWord;
    dwJmpSize: DWord;
    PEB: Pointer;
    pNewKernelModeFunction: Pointer;
begin
  Result := False;
  dwJmpSize := SizeOf(TJmpCode);
  dwSizeAll := 0;
  JumpCode.bPush := $68;
  JumpCode.bRet := $C3;
  pWalker := pOrigFunction;
  try
    repeat
      Error := not InstructionInfo(pWalker, sName, dwSize);
      Inc(dwSizeAll, dwSize);
      pWalker := Pointer(DWord(pWalker) + dwSize);
    until ((dwSizeAll >= dwJmpSize) or Error);
  except
    Exit;
  end;
  if (Error) then
    Exit;
  if not VirtualProtectKernel9x(pOrigFunction,$1000, True) then
    Exit;

  pNewKernelModeFunction := VirtualAllocExX(GetCurrentProcessID,nil,$1000,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pNewKernelModeFunction <> nil) then
  begin
    PEB := uallKernel.GetPDB;
    JumpCode.pAddr := Pointer(DWord(pOrigFunction) + dwSizeAll);
    try
      CopyMemory(pNewKernelModeFunction, @nextCallData, SimpleSize(@nextCallData));
      CopyMemory(Pointer(DWord(pNewKernelModeFunction) + 1), @PEB, 4);
      CopyMemory(Pointer(DWord(pNewKernelModeFunction) + 17), @pCallBackFunction, 4);
      CopyMemory(Pointer(DWord(pNewKernelModeFunction) + SimpleSize(@nextCallData)), pOrigFunction, dwSizeAll);
      CopyMemory(Pointer(DWord(pNewKernelModeFunction) + dwSizeAll + SimpleSize(@nextCallData)), @JumpCode, dwJmpSize);
      
      pNewFunction := Pointer(DWord(pNewKernelModeFunction)+SimpleSize(@nextCallData));
      JumpCode.pAddr := pNewKernelModeFunction;
      CopyMemory(pOrigFunction,@JumpCode,SizeOf(TJmpCode));
      VirtualProtectKernel9x(pOrigFunction,$1000, False);
      Result := True;
    except
      VirtualFree(pNewKernelModeFunction,$1000,MEM_RELEASE);
    end;
  end;
end;


function HookCode(pOrigFunction, pCallbackFunction: Pointer; var pNewFunction: Pointer): Boolean; stdcall;
begin
  if (not is9x) or (is9x and (DWord(pOrigFunction) < $80000000)) then
    Result := uallHook.HookCodeNt(pOrigFunction, pCallbackFunction, pnewFunction) else
    Result := uallHook.HookCodeKernel9x(pOrigFunction, pCallbackFunction, pnewFunction);
end;

function UnhookCode(var pNewFunction: Pointer): Boolean; stdcall;
begin
  if (not is9x) or (is9x and (DWord(pNewFunction) < $80000000)) then
    Result := uallHook.UnhookCodeNt(pnewFunction) else
    Result := uallHook.UnhookCodeKernel9x(pnewFunction);
end;

function UnhookCodeNt(var pNewFunction: Pointer): Boolean; stdcall;
var
  sName       : String;
  dwSize      : DWord;
  dwSizeAll   : DWord;
  dwOldProtect: DWord;
  dwJmpSize   : DWord;
  pWalker     : Pointer;
  Error       : Boolean;
  JmpCode     : TJmpCode;
Begin
  dwSizeAll := 0;
  dwJmpSize := SizeOf(TJmpCode);
  pWalker := pNewFunction;
  JmpCode.bPush := $00;
  JmpCode.bRet := $00;
  Result := False;

  if (pNewFunction = nil) then
    Exit;

  {Calculate count of bytes which must be copied.}
  try
    repeat
      Error := not InstructionInfo(pWalker, sName, dwSize);
      Inc(dwSizeAll, dwSize);
      pWalker := Pointer(DWord(pWalker) + dwSize);
    until ((dwSizeAll >= dwJmpSize) or Error);
  except
    Exit;
  end;
  if (Error) then
    Exit; {Found an unknown assembler instruction.}

  if (isBadReadPtr(pNewFunction,dwJmpSize)) then
    Exit; {Memory is not readable.}

  CopyMemory(@JmpCode, Pointer(DWord(pNewFunction) + dwSizeAll), dwJmpsize);
  if (JmpCode.bPush <> $68) or (JmpCode.bRet <> $C3) then
    Exit; {This is not a hooked function.}

  if (isBadReadPtr(Pointer(DWord(JmpCode.pAddr) - dwSizeAll),dwJmpSize)) then
    Exit; {Memory is not readable.}

  if (not VirtualProtect(Pointer(DWord(JmpCode.pAddr) - dwSizeAll), dwJmpSize, PAGE_EXECUTE_READWRITE, dwOldProtect)) then
    Exit; {Cant get write access to function.}

  {Write the original code back.}
  CopyMemory(Pointer(DWord(JmpCode.pAddr) - dwSizeAll), pNewFunction, dwJmpSize);

  VirtualProtect(Pointer(DWord(JmpCode.pAddr) - dwSizeAll), dwJmpSize, dwOldProtect, dwOldProtect);
  pNewFunction := Nil;
  Result := True;
  VirtualFree(pNewFunction,dwSizeAll+dwJmpSize,MEM_RELEASE);
end;

function HookCodeNt(pOrigFunction, pCallbackFunction: Pointer; var pNewFunction: Pointer): Boolean; stdcall; 
var
  sName       : String;
  dwSize      : DWord;
  dwSizeAll   : DWord;
  dwOldProtect: DWord;
  dwJmpSize   : DWord;
  pWalker     : Pointer;
  Error       : Boolean;
  JumpCode    : TJmpCode;
Begin
  dwSizeAll := 0;
  dwJmpSize := SizeOf(Tjmpcode);
  pWalker := pOrigFunction;
  JumpCode.bPush := $68;
  JumpCode.bRet := $C3;
  Result := False;

  {Calculate count of bytes which must be copied because of overwriting.}
  try
    repeat
      Error := not InstructionInfo(pWalker, sName, dwSize);
      Inc(dwSizeAll, dwSize);
      pWalker := Pointer(DWord(pWalker) + dwSize);
    until ((dwSizeAll >= dwJmpSize) or Error);
  except
    Exit;
  end;

  if (Error) Then
    Exit; {Found an unknown assembler instruction.}

  if (not VirtualProtect(pOrigFunction, dwJmpSize, PAGE_EXECUTE_READWRITE, dwOldProtect)) and (not is9x) then
    Exit; {Cant get needed rights for hooking the function.}

  pNewFunction := VirtualAlloc(nil, dwJmpSize + dwSizeAll, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if (pNewFunction = nil) then
    Exit; {Cant get memory for the new function.}

  {Create the new function with the intructions which will be overwritten.}
  try
    CopyMemory(pNewFunction, pOrigFunction, dwSizeAll);
    JumpCode.pAddr := Pointer(DWord(pOrigFunction) + dwSizeAll);
    CopyMemory(Pointer(DWord(pNewFunction) + dwSizeAll), @JumpCode, dwJmpSize);
    JumpCode.pAddr := pCallbackFunction;

    {Write the jumpcode to hook the function.}
    CopyMemory(pOrigFunction, @JumpCode, dwJmpSize);
    Result := True;
  except
    VirtualFree(pNewFunction, dwJmpSize + dwSizeAll,MEM_RELEASE);
  end;
  VirtualProtect(pOrigFunction, dwJmpSize, dwOldProtect, dwOldProtect);
end;

end.

