unit uallProtect;

{$I 'uallCollection.inc'}

interface

uses windows, uallUtil, tlhelp32;

function HideLibraryNT(dwLibraryHandle: DWord): Boolean; stdcall;
function ShowLibraryNT(dwLibraryHandle: DWord): Boolean; stdcall;
function ForceLoadLibrary(pLibraryName: PChar): DWord; stdcall;
function ForceLoadLibraryNt(pLibraryName: PChar): DWord; stdcall;
procedure ProtectCall(pAddr: Pointer); stdcall;
procedure AntiDebugActiveProcess; stdcall;
function IsHooked(pLibraryName, pFunctionName: PChar): Boolean; stdcall;
procedure CloseAndDeleteMe; stdcall;

implementation

uses uallKernel, uallHook, uallProcess;

{$IFDEF DELPHI5_DOWN}
type
    PPointer = ^Pointer;
{$ENDIF}

var
  RtlEqualUnicodeStringOrig: function(UnicodeString1, UnicodeString2: PUnicodeString; bCaseSensitive: Boolean): Boolean; stdcall;
  RtlEqualUnicodeStringNext: function(UnicodeString1, UnicodeString2: PUnicodeString; bCaseSensitive: Boolean): Boolean; stdcall;
  sForceName: String;

function RtlEqualUnicodeStringCallback(UnicodeString1, UnicodeString2: PUnicodeString; bCaseSensitive: Boolean): Boolean; stdcall;
begin
  if (Pos(sForceName,UpperCase(UnicodeString2.pBuffer)) > 0) then
    Result := False else
    Result := RtlEqualUnicodeStringNext(UnicodeString1, UnicodeString2, bCaseSensitive);
end;

function ForceLoadLibraryNt(pLibraryName: PChar): DWord; stdcall;
begin
  Result := 0;
  if (not isNt) then
    Exit;
  @RtlEqualUnicodeStringOrig := GetProcAddress(GetModuleHandle('ntdll.dll'),'RtlEqualUnicodeString');
  if (@RtlEqualUnicodeStringOrig = nil) then
    Exit; {Cant find RtlEqualUnicodeString}
  if (not uallHook.HookCode(@RtlEqualUnicodeStringOrig,@RtlEqualUnicodeStringCallback,@RtlEqualUnicodeStringNext)) then
    Exit; {Cant hook RtlEqualUnicodeString}
  sForceName := UpperCase(pLibraryName);
  Result := LoadLibraryA(pLibraryName);
  uallHook.UnhookCode(@RtlEqualUnicodeStringNext);
end;

function IsAddrInModule(pAddr: Pointer; pLibraryName: PChar): Boolean; stdcall;
var
  INH            : PImageNtHeaders;
  IDH            : PImageDosHeader;
  dwLibraryHandle: DWord;
begin
  Result := True;
  dwLibraryHandle := GetModuleHandle(pLibraryName);
  IDH := pointer(dwLibraryHandle);
  if isBadReadPtr(IDH,SizeOf(TImageDosHeader)) or (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
    Exit;

  INH := pointer(dwLibraryHandle+DWord(IDH^._lfanew));
  if isBadReadPtr(INH,SizeOf(TImageNtHeaders)) or (INH^.Signature <> IMAGE_NT_SIGNATURE) then
    Exit;

  if (DWord(pAddr) < dwLibraryHandle) or (DWord(pAddr) > dwLibraryHandle+INH^.OptionalHeader.SizeOfImage) then
    Result := false;
end;

procedure CloseAndDeleteMe; stdcall;
  function ThreadDeleteBegin(Param: Pointer): Boolean; stdcall;
  var
    XDeleteFile      : function (pFileName: PChar): Boolean; stdcall;
    XSleep           : procedure (dwMilliseconds: DWord); stdcall;
    XOpenProcess     : function (dwDesiredAccess: DWord; bInheritHandle: Boolean; dwProcessId: DWord): DWord; stdcall;
    XTerminateProcess: function (dwProcess: DWord; dwExitCode: DWord): Boolean; stdcall;
    XCloseHandle     : function (dwHandle: DWord): Boolean; stdcall;
    pFileName        : PChar;
    dwProcessID      : DWord;
  begin
    Result := False;

    @XDeleteFile := PPointer(DWord(Param)+0*SizeOf(Pointer))^;
    @XSleep := PPointer(DWord(Param)+1*SizeOf(Pointer))^;
    @XOpenProcess := PPointer(DWord(Param)+2*SizeOf(Pointer))^;
    @XTerminateProcess := PPointer(DWord(Param)+3*SizeOf(Pointer))^;
    @XCloseHandle := PPointer(DWord(Param)+4*SizeOf(Pointer))^;
    dwProcessID := PDWord(DWord(Param)+5*SizeOf(Pointer))^;
    pFilename := Pointer(DWord(Param)+6*SizeOf(Pointer));

    if (@XDeleteFile <> nil) and
       (@XSleep <> nil) and
       (@XOpenProcess <> nil) and
       (@XTerminateProcess <> nil) and
       (pFilename <> nil) and
       (dwProcessID <> 0) then
    begin
      dwProcessID := XOpenProcess(PROCESS_ALL_ACCESS,false,dwProcessID);
      if (dwProcessID <> 0) then
      begin
        if XTerminateProcess(dwProcessID,0) then
        begin
          XSleep(1000);
          Result := XDeleteFile(pFileName);
        end;
        XCloseHandle(dwProcessID);
      end;
    end;
  end;
  procedure ThreadDeleteEnd; asm end;

var
  pTargetMemory   : Pointer;
  pTargetMemMove  : Pointer;
  dwProcessID     : DWord;
  dwKernelHandle  : DWord;
  dwProcessIDClose: DWord;
  dwThreadID      : DWord;
  dwWritten       : DWord;
  dwMemSize       : DWord;
  sFileName       : String;
  pAddr           : array[0..4] of Pointer;
begin
  dwProcessID := uallProcess.FindProcess('explorer');
  if (dwProcessID = 0 ) then
    Exit;
  dwProcessID := OpenProcess(PROCESS_ALL_ACCESS,false,dwPRocessID);
  if (dwProcessID = 0) then
    Exit;
    
  sFileName := Paramstr(0);
  dwMemSize := 5*SizeOf(Pointer)+length(sFileName)+1+Integer(@ThreadDeleteEnd)-Integer(@ThreadDeleteBegin);
  pTargetMemory := VirtualAllocExX(dwProcessID,nil,dwMemSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  pTargetMemMove := pTargetMemory;
  dwKernelHandle := GetModuleHandleA('kernel32.dll');
  pAddr[0] := GetProcAddress(dwKernelHandle,'DeleteFileA');
  pAddr[1] := GetProcAddress(dwKernelHandle,'Sleep');
  pAddr[2] := GetProcAddress(dwKernelHandle,'OpenProcess');
  pAddr[3] := GetProcAddress(dwKernelHandle,'TerminateProcess');
  pAddr[4] := GetProcAddress(dwKernelHandle,'CloseHandle');
  dwProcessIDClose := GetCurrentProcessID;
  if (pTargetMemory <> nil) then
  begin
    if WriteProcessMemory(dwProcessID,pTargetMemMove,@pAddr[0],SizeOf(pAddr),dwWritten) then
    begin
      pTargetMemMove := Pointer(DWord(pTargetMemMove)+dwWritten);
      if WriteProcessMemory(dwProcessID,pTargetMemMove,@dwProcessIDClose,SizeOf(dwProcessIDClose),dwWritten) then
      begin
        pTargetMemMove := Pointer(DWord(pTargetMemMove)+dwWritten);
        if WriteProcessMemory(dwProcessID,pTargetMemMove,@sFileName[1],Length(sFileName),dwWritten) then
        begin
          pTargetMemMove := Pointer(DWord(pTargetMemMove)+dwWritten+1);
          if WriteProcessMemory(dwProcessID,pTargetMemMove,@ThreadDeleteBegin,
               DWord(@ThreadDeleteEnd)-DWord(@ThreadDeleteBegin),dwWritten) then
            CreateRemoteThreadX(dwProcessID,nil,0,pTargetMemMove,pTargetMemory,0,dwThreadID);
        end;
      end;
    end;
  end;
  CloseHandle(dwProcessID);
end;

function CheckImportTableModule(dwLibraryHandle: DWord; pMemory: Pointer; pLibraryName: PChar): Boolean; stdcall;
var
  pIBlock   : PImportBlock;
  pThunks   : PPointer;
  INH       : PImageNtHeaders;
  IDH       : PImageDosHeader;
  pLibImport: PChar;
begin
  result := false;
  IDH := pointer(dwLibraryHandle);
  if (isBadReadPtr(IDH,SizeOf(TImageDosHeader))) or (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
    Exit;

  INH := pointer(dwLibraryHandle+DWord(IDH^._lfanew));
  if (isBadReadPtr(INH,SizeOf(TImageNtHeaders))) or (INH^.Signature <> IMAGE_NT_SIGNATURE) then
    Exit;

  if (INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress = 0) then
    Exit;

  pIBlock := Pointer(dwLibraryHandle+INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);

  pLibImport := Pointer(dwLibraryHandle+pIBlock^.dwName);
  while (not isBadReadPtr(pIBlock,SizeOf(Dword))) and
        (pIBlock^.pFirstThunk <> nil) do
  begin
    pThunks := Pointer(DWord(pIBlock^.pFirstThunk)+dwLibraryHandle);
    while (not isBadReadPtr(pThunks^,SizeOf(DWord))) and
          (pThunks^ <> nil) do
    begin
      if (UpperCase(pLibraryName) = UpperCase(pLibImport)) then
      begin
        if (not IsAddrInModule(pThunks^,pLibImport)) {Forwarded} then
          Result := true;
      end;
      Inc(pThunks);
    end;
    pIBlock := Pointer(DWord(pIBlock)+SizeOf(TImportBlock));
    pLibImport := Pointer(dwLibraryHandle+pIBlock^.dwName);
  end;
end;

function CheckImportTable(pMemory: Pointer; pLibraryName: PChar): Boolean; stdcall;
var
  dwSnap: DWord;
  ModuleEntry: TModuleEntry32;
begin
  result := false;
  dwSnap := CreateToolHelp32Snapshot(TH32CS_SNAPMODULE, GetCurrentProcessID);
  if (dwSnap > 0) then
  begin
    ModuleEntry.dwSize := SizeOf(TModuleEntry32);
    if Module32First(dwSnap,ModuleEntry) then
    begin
      repeat
        if (Result <> true) then
          Result := CheckImportTableModule(ModuleEntry.hModule,pMemory,pLibraryName);
      until (not Module32Next(dwSnap,ModuleEntry));
    end;
    CloseHandle(dwSnap);
  end;
end;


function CheckAddr(pLibraryHandle: Pointer; dwMemory, RealLibraryHandle: DWord): Boolean; stdcall;
var
  INH           : PImageNtHeaders;
  IDH           : PImageDosHeader;
  SEC           : PImageSectionHeader;
  i             : DWord;
  dwSectionCount: DWord;
begin
  Result := False;
  IDH := pLibraryHandle;
  if (isBadReadPtr(IDH,SizeOf(TImageDosHeader))) or
     (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
    Exit;

  INH := pointer(cardinal(pLibraryHandle)+cardinal(IDH^._lfanew));
  if (isBadReadPtr(INH,SizeOf(TImageNtHeaders))) or
     (INH^.Signature <> IMAGE_NT_SIGNATURE) then
    Exit;

  dwSectionCount := INH^.FileHeader.NumberOfSections;
  for i := 0 to dwSectionCount-1 do
  begin
    SEC := pointer(DWord(INH)+SizeOf(TImageNtHeaders)+i*SizeOf(TImageSectionHeader));
    if (not IsBadReadPtr(SEC,SizeOf(TImageSectionHeader))) and
       (SEC^.VirtualAddress <= dwMemory) and
       (SEC^.VirtualAddress+SEC^.Misc.PhysicalAddress >= dwMemory) then
      Result := Result or
        (not CompareMem(Pointer(DWord(pLibraryHandle) + SEC^.PointerToRawData + 
          dwMemory-SEC^.VirtualAddress), Pointer(dwMemory + RealLibraryHandle), 8));
  end;
end;

function CheckExportTable(pLibraryHandle: Pointer; pMemory, RealLibraryHandle: DWord): Boolean; stdcall;
var
  INH     : PImageNtHeaders;
  IDH     : PImageDosHeader;
  dwExport: DWord;
  i       : DWord;
  dwCount : DWord;
  pAddr   : Pointer;
begin
  Result := True;
  IDH := pLibraryHandle;
  if (isBadReadPtr(IDH,SizeOf(TImageDosHeader))) or
     (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
    Exit;

  INH := Pointer(Cardinal(pLibraryHandle)+Cardinal(IDH^._lfanew));
  if (isBadReadPtr(INH,SizeOf(TImageNtHeaders))) or
     (INH^.Signature <> IMAGE_NT_SIGNATURE) then
    Exit;

  dwExport := INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress;
  if (dwExport = 0) then
    Exit;

  dwCount := PWord(RealLibraryHandle+dwExport+24)^;
  pAddr := PPointer(RealLibraryHandle+dwExport+28)^;
  for i := 0 to dwCount-1 do
  begin
    if (PDWord(RealLibraryHandle+DWord(pAddr)+i*4)^ = DWord(pMemory)) then
      Result := false;
  end;
end;


function IsHooked(pLibraryName, pFunctionName: PChar): Boolean; stdcall;
var
  sModuleName: PChar;
  dwFileHandle: DWord;
  dwFileSize: DWord;
  dwLen: DWord;
  pMemory: Pointer;
  dwRead: DWord;
  dwRealLibraryHandle: DWord;
  pAddr: Pointer;
begin
  Result := False;
  pAddr := GetProcAddress(GetModuleHandle(pLibraryName),pFunctionName);
  if (not IsAddrInModule(pAddr,pLibraryName)) then
  begin
    Result := True;
    Exit;
  end;

  if (IsBadReadPtr(pAddr,8)) then
    Exit;

  dwRealLibraryHandle := GetRealModuleHandle(pAddr);
  if (dwRealLibraryHandle = 0) then
    Exit;

  sModuleName := StrAlloc(256);
  dwLen := GetModuleFileName(dwRealLibraryHandle,sModuleName,255);
  if (dwLen = 0) then
  begin
    StrDispose(sModuleName);
    Exit;
  end;

  dwFileHandle := CreateFileA(sModuleName,GENERIC_READ,FILE_SHARE_READ or FILE_SHARE_WRITE,nil,OPEN_EXISTING,0,0);
  if (Integer(dwFileHandle) <= 0) then
  begin
    StrDispose(sModuleName);
    Exit;
  end;

  dwFileSize := GetFileSize(dwFileHandle,nil);
  if (dwFileSize = 0) then
  begin
    StrDispose(sModuleName);
    CloseHandle(dwFileHandle);
    Exit;
  end;

  pMemory := VirtualAlloc(nil,dwFileSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pMemory = nil) then
  begin
    StrDispose(sModuleName);
    CloseHandle(dwFileHandle);
    Exit;
  end;

  ReadFile(dwFileHandle,pMemory^,dwFileSize,dwRead,nil);
  Result := CheckAddr(pMemory,DWord(pAddr)-dwRealLibraryHandle, dwRealLibraryHandle);
  if (not Result) then
    Result := CheckExportTable(pMemory,DWord(pAddr)-dwRealLibraryHandle, dwRealLibraryHandle);
  if (not Result) then
    Result := CheckImportTable(pAddr, pLibraryName);
  VirtualFree(pMemory,dwFileSize,MEM_RELEASE);
  CloseHandle(dwFileHandle);
end;

procedure AntiDebugActiveProcess; stdcall;
begin
  CreateFileA(PChar(ParamStr(0)),GENERIC_READ,0,nil,OPEN_EXISTING,0,0)
end;

procedure ProtectCall(pAddr: Pointer); stdcall;
asm
  MOV EBX, DWORD PTR [EBP+4]
  PUSH EBX
  MOV EAX, DWORD PTR [pAddr]
  XOR EAX, EBP
  PUSH EAX
  XOR EAX, EAX
  TEST EAX, EAX
  JNZ @muell
  JNZ @muell2
  JMP @weiter
@muell:
  DB $0F, $80
@weiter:
  //RDTSC
  DB $0F, $31
  MOV ECX, EAX
  MOV EBX, EDX
  JMP @weiter2
@muell2:
  DB $0F, $80
@weiter2:
  //RDTSC
  DB $0F, $31
  SUB EAX, ECX
  SUB EDX, EBX
  NEG EDX
  XOR EAX, EDX
  SHR EAX, 8
  XOR EBP, EAX
  @ende:
  POP EAX
  XOR EAX, EBP
  POP EBX
  POP EBP    
  POP ECX
  MOV DWORD PTR [ESP], EBX
  JMP EAX
end;

function ForceLoadLibrary(pLibraryName: PChar): DWord; stdcall;
var
  hide: array of Integer;
  count: Integer;
  i: Integer;
begin
  Result := 0;
  if (pos('KERNEL32',UpperCase(pLibraryName)) > 0) or (pos('NTDLL',UpperCase(pLibraryName)) > 0) then
    Exit;
  Count := 0;
  while (GetModuleHandle(pLibraryName) > 0) do
  begin
    Inc(count);
    SetLength(hide,count);
    hide[count-1] := GetModuleHandle(pLibraryName);
    HideLibraryNT(GetModuleHandle(pLibraryName));
  end;
  Result := LoadLibraryA(pLibraryName);
  for i := 0 to Count-1 do
    ShowLibraryNT(hide[i]);
end;

function HideLibraryNT(dwLibraryHandle: DWord): Boolean; stdcall;
asm
  PUSH EDX                        // save all registers we use
  PUSH ECX
  PUSH EBX
  MOV EBX, DWORD PTR [dwLibraryHandle]                    // EBX = handle of dll to hide
  MOV EAX,DWORD PTR FS:[$18]      // get dll table
  MOV EAX,DWORD PTR [EAX+$30]
  MOV EAX,DWORD PTR [EAX+$C]
  ADD EAX,$0C
  MOV ECX,DWORD PTR [EAX]

@weiter:
  CMP ECX,EAX                     // successful got table?
  JE @ende                        // if not go to end
  MOV EDX,ECX
  CMP DWORD PTR DS:[EDX+$8],0     // check for valid module
  MOV ECX,DWORD PTR DS:[ECX]
  JE @weiter                      // if not valid (end of table) go to end
  CMP EBX,DWORD PTR DS:[EDX+$18]  // is it the module we search?
  JNE @weiter                     // if not get next module in table
  LEA EBX, [EDX+$28]              // if so get the library name
  MOV EBX, [EBX]

  CMP BYTE PTR [EBX],$0           // library name is empty? (already hidden dll?)
  JE @ende                        // if so go to end

  MOV EDX, EBX
  MOV EAX, EDX
  ADD EAX, 3
  MOV CL, BYTE PTR [EDX]          // get the first char
  MOV BYTE PTR [EAX], CL          // save it in the second char #0 (unicode!)
  MOV BYTE PTR [EDX], $0          // delete first char (hide dll path)

  XOR EDX, EDX                    // search for last backslash
  MOV EBX, EAX
  ADD EBX, 1
@weiter2:
  MOV EAX, EBX
  ADD EBX, 2
  CMP BYTE PTR [EAX], $5C         // check for backslash
  JNE @weiter3                    // jmp to next char if no backslash
  MOV EDX, EAX                    // save last backslash address to edx
@weiter3:
  CMP BYTE PTR [EAX], $0          // check for last char
  JNE @weiter2                    // if not go on

  TEST EDX, EDX                   // check if we found a backslash
  JZ @ende                        // no backslash found, goto end

  ADD EDX, 2
  MOV EAX, EDX
  ADD EAX, 3

  MOV CL, BYTE PTR [EDX]          // get first char of the library name
  MOV BYTE PTR [EAX], CL          // save it in second char of libary name
  MOV BYTE PTR [EDX], $0          // destroy the first char (hide library name)

  XOR EAX, EAX
  ADD EAX, 1                      // set return param to true
  JMP @ende2

@ende:
  XOR EAX, EAX
@ende2:
  POP EBX
  POP ECX
  POP EDX
end;

function ShowLibraryNT(dwLibraryHandle: DWord): Boolean; stdcall;
asm
  PUSH EDX                        // save all registers we use
  PUSH ECX
  PUSH EBX
  MOV EBX, DWORD PTR [dwLibraryHandle]                    // EBX = handle of dll to hide
  MOV EAX,DWORD PTR FS:[$18]      // get dll table
  MOV EAX,DWORD PTR [EAX+$30]
  MOV EAX,DWORD PTR [EAX+$C]
  ADD EAX,$0C
  MOV ECX,DWORD PTR [EAX]

@weiter:
  CMP ECX,EAX                     // successful got table?
  JE @ende                        // if not go to end
  MOV EDX,ECX
  CMP DWORD PTR DS:[EDX+$8],0     // check for valid module
  MOV ECX,DWORD PTR DS:[ECX]
  JE @weiter                      // if not valid (end of table) go to end
  CMP EBX,DWORD PTR DS:[EDX+$18]  // is it the module we search?
  JNE @weiter                     // if not get next module in table
  LEA EBX, [EDX+$28]              // if so get the library name
  MOV EBX, [EBX]

  CMP BYTE PTR [EBX],$0           // library name is not empty? (no hidden dll?)
  JNE @ende                       // if so go to end

  MOV EDX, EBX
  MOV EAX, EDX
  ADD EAX, 3
  MOV CL, BYTE PTR [EAX]          // get the saved char
  MOV BYTE PTR [EDX], CL          // set it (revalid dll path)
  MOV BYTE PTR [EAX], $0          // delete saved char

  XOR EDX, EDX                    // search for last backslash
  MOV EBX, EAX
  ADD EBX, 1
@weiter2:
  MOV EAX, EBX
  ADD EBX, 2
  CMP BYTE PTR [EAX], $5C         // check for backslash
  JNE @weiter3                    // jmp to next char if no backslash
  MOV EDX, EAX                    // save last backslash address to edx
@weiter3:
  CMP BYTE PTR [EAX], $0          // check for last char
  JNE @weiter2                    // if not go on

  TEST EDX, EDX                   // check if we found a backslash
  JZ @ende                        // no backslash found, goto end

  ADD EDX, 2
  MOV EAX, EDX
  ADD EAX, 3

  MOV CL, BYTE PTR [EAX]          // get saved char of the library name
  MOV BYTE PTR [EDX], CL          // revalid library name
  MOV BYTE PTR [EAX], $0          // delete saved char

  XOR EAX, EAX
  ADD EAX, 1                      // set return param to true
  JMP @ende2

@ende:
  XOR EAX, EAX
@ende2:
  POP EBX
  POP ECX
  POP EDX
end;


end.
