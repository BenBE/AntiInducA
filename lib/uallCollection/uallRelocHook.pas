unit uallRelocHook;

{$I 'uallCollection.inc'}

interface

uses windows, tlhelp32, uallKernel, uallUtil;

function HookRelocationTable(pOrigFunction, pCallbackFunction: Pointer; var pNewFunction: pointer): DWord; stdcall;
function UnHookRelocationTable(pCallbackFunction, pNewFunction: Pointer): DWord; stdcall;

procedure RelocHookInit; stdcall;
procedure RelocHookRelease; stdcall;

implementation

{$IFDEF DELPHI5_DOWN}
type
    PPointer = ^Pointer;
{$ENDIF}

var
  oldGetProcAddress: function(hmodule: integer; procname: pchar): pointer; stdcall;
  nextGetProcAddress: function(hmodule: integer; procname: pchar): pointer; stdcall;

  oldLoadLibraryA: function(modulename: PChar): integer; stdcall;
  nextLoadLibraryA: function(modulename: PChar): integer; stdcall;


  Table: PTableAddress = nil;
  isGlobalHookPossible: boolean = false;

function HookRelocationTableModule(dwLibraryHandle: DWord; oldaddress, newaddress: pointer; var nextaddress: pointer): integer; stdcall;
var RelocBlock: PRelocBlock;
    RelocCount: integer;
    StartReloc: PWord;
    i: integer;
    p: PInteger;
    IDH: PImageDosHeader;
    INH: PImageNtHeaders;
    dwOldProtect: DWord;
begin
  result := 0;
  IDH := pointer(dwLibraryHandle);
  if (IsBadReadPtr(IDH,SizeOf(TImageDosHeader))) or (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
    Exit;

  INH := pointer(dwLibraryHandle+DWord(IDH^._lfanew));
  if (IsBadReadPtr(INH,SizeOf(TImageNtHeaders))) or (INH^.Signature <> IMAGE_NT_SIGNATURE) then
    Exit;

  if (INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress = 0) then
    Exit;
  if (INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size = 0) then
    Exit;

  RelocBlock := Pointer(dwLibraryHandle+INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress);
  StartReloc := Pointer(DWord(RelocBlock)+8);

  while (not IsBadReadPtr(RelocBlock,8)) and (RelocBlock^.dwAddress <> 0) do
  begin
    RelocCount := (RelocBlock^.dwSize-8) div SizeOf(Word);
    for i := 0 to RelocCount-1 do
    begin
      if (not IsBadReadPtr(StartReloc,2)) and  (StartReloc^ xor $3000 < $1000) then
      begin
        p := Pointer(RelocBlock^.dwAddress+(StartReloc^ mod $3000)+dwLibraryHandle);
        if (not IsBadReadPtr(pointer(integer(p)-2),6)) and
           (pbyte(integer(p)-2)^ = $FF) and
           ((pbyte(integer(p)-1)^ = $25) or (pbyte(integer(p)-1)^ = $15)) and
           (not isbadreadptr(pointer(p^),4)) and
           (not isbadreadptr(ppointer(p^)^,4)) and
           (ppointer(p^)^ = oldaddress) then
        begin
          if VirtualProtect(pointer(p^),4,PAGE_EXECUTE_READWRITE,dwOldProtect) then
          begin
            ppointer(p^)^ := newaddress;
            inc(result);
            VirtualProtect(pointer(p^),4,dwOldProtect,dwOldProtect);
          end;
        end;
      end;
      StartReloc := pointer(integer(StartReloc)+SizeOf(Word));
    end;
    RelocBlock := pointer(StartReloc);
    StartReloc := pointer(integer(StartReloc)+8);
  end;

  nextaddress := oldaddress;
end;

procedure HookNewLibrary(Table: PTableAddress; hmodule: integer);
var dummy: pointer;
begin
  while (Table <> nil) do
  begin
    HookRelocationTableModule(hmodule,Table^.pOrigFunction,Table^.pCallbackFunction,dummy);
    Table := Table^.pNext;
  end;
end;

function ChangeTableAddress(Table: PTableAddress; pOrigFunction: pointer): pointer;
begin
  result := pOrigFunction;
  while (Table <> nil) do
  begin
    if (Table^.pOrigFunction = pOrigFunction) then
    begin
      result := Table^.pCallbackFunction;
      exit;
    end else
      Table := Table^.pNext;
  end;
end;

procedure RemoveFromTable(var Table: PTableAddress; pCallbackFunction: pointer);
var Tablex, TableY: PTableAddress;
begin
  TableY := Table;
  if (Table <> nil) then
  begin
     if (Table^.pCallbackFunction = pCallbackFunction) then
     begin
       Tablex := Table^.pNext;
       Dispose(Table);
       Table := Tablex;
     end else
     begin
        while TableY^.pNext <> nil do
        begin
          Tablex := TableY^.PNext;
          if (Tablex.pCallbackFunction = pCallbackFunction) then
          begin
            TableY^.pNext := Tablex^.pNext;
            Dispose(Tablex);
            Exit;
          end;
          TableY := TableY^.PNext;
        end;
     end;
  end;
end;


procedure AddToTable(var Table: PTableAddress; pOrigFunction, pCallbackFunction: pointer);
var Tablex: PTableAddress;
begin
  if (Table = nil) then
  begin
    New(Table);
    Table^.pNext := nil;
    Table^.pOrigFunction := pOrigFunction;
    Table^.pCallbackFunction := pCallbackFunction;
  end else
  begin
    Tablex := Table;
    while (Tablex^.pNext <> nil) do
      Tablex := Tablex^.pNext;
    New(Tablex^.pNext);
    Tablex^.pNext^.pOrigFunction := pOrigFunction;
    Tablex^.pNext^.pCallbackFunction := pCallbackFunction;
    Tablex^.pNext^.pNext := nil;
  end;
end;

function myGetProcAddress(hmodule: integer; procname: pchar): pointer; stdcall;
begin
  result := nextGetProcAddress(hmodule, procname);
  if (DWord(Result) < $80000000) or
     (isGlobalHookPossible) then
    Result := ChangeTableAddress(Table,result);
end;

function myLoadLibraryA(modulename: PChar): integer; stdcall;
begin
  result := nextLoadLibraryA(modulename);
  HookNewLibrary(Table,result);
end;

function HookRelocationTableAllModules(oldaddress, newaddress: pointer; var nextaddress: pointer): integer; stdcall;
var hsnap: integer;
    lpme: TModuleEntry32;
begin
  result := 0;
  hsnap := CreateToolHelp32Snapshot(TH32CS_SNAPMODULE,GetCurrentProcessID);
  if (hsnap > 0) then
  begin
    lpme.dwSize := sizeOf(lpme);
    if Module32First(hsnap,lpme) then
    begin
      repeat
        inc(result,HookRelocationTableModule(lpme.hModule,oldaddress,newaddress,nextaddress));
      until (not Module32Next(hsnap,lpme));
    end;
    CloseHandle(hsnap);
  end;
end;

function UnHookRelocationTable(pCallbackFunction, pNewFunction: Pointer): DWord; stdcall;
var dummy: pointer;
begin
  if (DWord(pCallbackFunction) < $80000000) or
     (isGlobalHookPossible) then
  begin
    Result := HookRelocationTableAllModules(pCallbackFunction,pNewFunction,dummy);
    RemoveFromTable(Table,pCallbackFunction);
  end else result := 0;
end;

function HookRelocationTable(pOrigFunction, pCallbackFunction: pointer; var pNewFunction: pointer): DWord; stdcall;
begin
  AddToTable(Table,pOrigFunction,pCallbackFunction);
  Result := HookRelocationTableAllModules(pOrigFunction,pCallbackFunction,pNewFunction);
end;

procedure RelocHookInit; stdcall;
begin
  Table := nil;
  isGlobalHookPossible := (isNT) or (GetOwnModuleHandle > $80000000);
  if isGlobalHookPossible then
  begin
    @oldGetProcAddress := GetProcAddress(GetModuleHandle('kernel32.dll'),'GetProcAddress');
    @oldLoadLibraryA := GetProcAddress(GetModuleHandle('kernel32.dll'),'LoadLibraryA');

    HookRelocationTable(@oldGetProcAddress,@myGetProcAddress,@nextGetProcAddress);
    HookRelocationTable(@oldLoadLibraryA,@myLoadLibraryA,@nextLoadLibraryA);
  end;
end;

procedure RelocHookRelease; stdcall;
begin
  if isGlobalHookPossible then
  begin
    UnHookRelocationTable(@nextLoadLibraryA,@myLoadLibraryA);
    UnHookRelocationTable(@nextGetProcAddress,@myGetProcAddress);
  end;
end;

end.
