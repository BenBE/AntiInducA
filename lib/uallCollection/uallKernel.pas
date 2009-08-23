unit uallKernel;

{$I 'uallCollection.inc'}

interface

uses windows, uallUtil, tlhelp32;

const
  THREAD_ALL_ACCESS                 = $1F03FF;
  SE_PRIVILEGE_ENABLED              = $2;
  SE_PRIVILEGE_DISABLED             = $0;
  
  WIN98_K32OBJ_SEMAPHORE            = $1;
  WIN98_K32OBJ_EVENT                = $2;
  WIN98_K32OBJ_MUTEX                = $3;
  WIN98_K32OBJ_CRITICAL_SECTION     = $4;
  WIN98_K32OBJ_CHANGE               = $5;
  WIN98_K32OBJ_PROCESS              = $6;
  WIN98_K32OBJ_THREAD               = $7;
  WIN98_K32OBJ_FILE                 = $8;
  WIN98_K32OBJ_CONSOLE              = $9;
  WIN98_K32OBJ_SCREEN_BUFFER        = $A;
  WIN98_K32OBJ_MAILSLOT             = $B;
  WIN98_K32OBJ_SERIAL               = $C;
  WIN98_K32OBJ_MEM_MAPPED_FILE      = $D;
  WIN98_K32OBJ_PIPE                 = $E;
  WIN98_K32OBJ_DEVICE_IOCTL         = $F;
  WIN98_K32OBJ_TOOLHELP_SNAPSHOT    = $10;
  WIN98_K32OBJ_SOCKET               = $11;

  PC_WRITEABLE          = $00020000;
  PC_USER               = $00040000;
  PC_PRESENT            = $80000000;
  PC_STATIC             = $20000000;
  PC_DIRTY              = $08000000;
  PageModifyPermissions = $0001000D;

type
  TRelocBlock = packed record
    dwAddress: DWord;
    dwSize   : DWord;
  end;
  PRelocBlock = ^TRelocBlock;

  TImportBlock = packed record
    dwCharacteristics: DWord;
    dwTimeDateStamp  : DWord;
    dwForwarderChain : DWord;
    dwName           : DWord;
    pFirstThunk      : Pointer;
  end;
  PImportBlock = ^TImportBlock;

  TImportNameBlock = packed record
    wHint: Word;
    pName: PChar;
  end;
  PImportNameBlock = ^TImportNameBlock;

  TJmpCode = packed record
    bPush: Byte;
    pAddr: Pointer;
    bRet : Byte;
  end;
  PJmpCode = ^TJmpCode;

  PTableAddress = ^TTableAddress;
  TTableAddress = packed record
                    pOrigFunction    : Pointer;
                    pCallbackFunction: Pointer;
                    pNext            : PTableAddress;
                  end;

  TUnicodeString  = packed record
                      wLength       : Word;
                      wMaximumLength: Word;
                      pBuffer       : PWideChar;
                    end;
  PUnicodeString = ^TUnicodeString;

  TProcessBasicInformation = packed record
                               Reserved1      : Pointer;
                               PebBaseAddress : Pointer;
                               Reserved2      : array[0..1] of Pointer;
                               UniqueProcessId: DWord;
                               Reserved3      : Pointer;
                             end;
  PProcessBasicInformation = ^TProcessBasicInformation;

  PHandleTableEntry9x = ^THandleTableEntry9x;
  THandleTableEntry9x = packed record
                          dwFlags: DWord;
                          pObject: Pointer;
                        end;

  PHandleTable9x = ^THandleTable9x;
  THandleTable9x = packed record
                     dwEntryCount: DWord;
                     dwTableEntry: array[0..0] of THandleTableEntry9x;
                   end;

  PModuleEntry = ^TModuleEntry;
  TModuleEntry = packed record
                   NextModule: PModuleEntry; //0
                   a: DWord;            //4
                   b: DWord;            //8
                   c: DWord;            //C
                   d: DWord;            //10
                   e: DWord;            //14
                   ModuleHandle: DWord; //18
                   f: DWord;            //1C
                   g: DWord;            //20
                   h: DWord;            //24
                   ModuleName: PWideChar; //28
                end;

  PPDB98 = ^TPDB98;
  TPDB98 = packed record
           bType              : Byte;
           Unknown_A          : Byte;
           wReference         : Word;
           dwUnknown_B        : DWord;
           dwUnknown1         : DWord;
           dwEvent            : DWord;
           dwTerminationStatus: DWord;
           dwUnknown2         : DWord;
           dwDefaultHeap      : DWord;
           dwMemoryContext    : DWord;
           dwFlags            : DWord;
           dwpPSP             : DWord;
           wPSPSelector       : Word;
           wMTEIndex          : Word;
           wThreads           : Word;
           wNotTermThreads    : Word;
           wUnknown3          : Word;
           wRing0Threads      : Word;
           dwHeapHandle       : DWord;
           dww16TDB           : DWord;
           dwMemMappedFiles   : DWord;
           pEDB               : Pointer;
           pHandleTable       : PHandleTable9x;
           pParentPDB         : PPDB98;
           pMODREFList        : Pointer;
           dwThreadList       : DWord;
           dwDebuggeeCB       : DWord;
           dwLocalHeapFreeHead: DWord;
           dwInitialRing0ID   : DWord;
           CriticalSection    : Pointer;
           dwUnknown4         : array [0..2] of DWord;
           dwConsole          : DWord;
           dwtlsInUseBits1    : DWord;
           dwtlsInUseBits2    : DWord;
           dwProcessDWORD     : DWord;
           pProcessGroup      : PPDB98;
           dwpExeMODREF       : DWord;
           dwTopExcFilter     : DWord;
           dwPriorityClass    : DWord;
           dwHeapList         : DWord;
           wHeapHandleList    : Word;
           dwHeapPointer      : DWord;
           dwConsoleProvider  : DWord;
           wEnvironSelector   : Word;
           wErrorMode         : Word;
           dwEventLoadFinished: DWord;
           wUTState           : Word;
           wUnknown5          : Word;
           wUnknown6          : Word;
         end;

  PIMTE = ^TIMTE;
  TIMTE = packed record
            dwUn1        : DWord;             // 00h
            pNTHdr       : PImageNtHeaders;   // 04h
            dwUn2        : DWord;             // 08h
            pFileName    : PChar;             // 0Ch
            pModName     : PChar;             // 10h
            wFileName    : Word;              // 14h
            wModName     : Word;              // 16h
            dwUn3        : DWord;             // 18h
            dwSections   : DWord;             // 1Ch
            dwUn5        : DWord;             // 20h
            dwBaseAddress: DWord;             // 24h
            wModule16    : Word;              // 28h
            wUsage       : Word;              // 2Ah
            dwUn7        : DWord;             // 2Ch
            pFileName2   : PChar;             // 30h
            wFileName2   : Word;              // 34h
            pModName2    : PChar;             // 36h
            wModName2    : Word;              // 3Ah
          end;
  TModuleTable = array[0..0] of PIMTE;
  PModuleTable = ^TModuleTable;

  PModRef = ^TModRef;
  TModRef = packed record
              pNextModRef: PModRef;           //00 Pointer to next MODREF in list (EOL=NULL)
              dwUn1      : DWord;             //04 number of ?
              dwUn2      : DWord;             //08 Ring0 TCB ?
              dwUn3      : DWord;             //0C
              wMTEIndex  : Word;              //10 Index to global array of pointers to IMTEs
              wUn4       : Word;              //12
              dwUn5      : DWord;             //14
              pPDB       : pPDB98;            //18 Pointer to process database
              dwUn6      : DWord;             //1C
              dwUn7      : DWord;             //20
              dwUn8      : DWord;             //24
            end;

  TLdrData = packed record
               dwLength                       : DWord;                    // 00
               dwInitialized                  : DWord;                    // 04
               pSsHandle                      : Pointer;                  // 08
               InLoadOrderModuleList          : PModuleEntry;             // 0C
               InMemoryOrderModuleList        : PModuleEntry;             // 14
               InInitializationOrderModuleList: PModuleEntry;             // 1C
               pEntryInProgress               : Pointer;                  // 24
             end;
  PLdrData = ^TLdrData;

  TPEBNT = packed record
             bInheritedAddressSpace          : Boolean;                   //000
             bReadImageFileExecOptions       : Boolean;                   //001
             bBeingDebugged                  : Boolean;                   //002
             bSpareBool                      : Boolean;                   //003 Allocation size
             dwMutant                        : DWord;                     //004
             dwImageBaseAddress              : DWord;                     //008 Instance
             pLdrData                        : PLdrData;                 //00C
             pProcessParameters              : Pointer;                   //010
             dwSubSystemData                 : DWord;                     //014
             dwProcessHeap                   : DWord;                     //018
             pFastPebLock                    : Pointer;                   //01C
             pFastPebLockRoutine             : Pointer;                   //020
             pFastPebUnlockRoutine           : Pointer;                   //024
             dwEnvironmentUpdateCount        : DWord;                     //028
             pKernelCallbackTable            : Pointer;                   //02C
             pEventLogSection                : Pointer;                   //030
             pEventLog                       : Pointer;                   //034
             pFreeList                       : Pointer;                   //038
             dwTlsExpansionCounter           : DWord;                     //03C
             dwTlsBitmap                     : DWord;                     //040
             i64TlsBitmapBits                : Int64;                     //044
             pReadOnlySharedMemoryBase       : Pointer;                   //04C
             pReadOnlySharedMemoryHeap       : Pointer;                   //050
             pReadOnlyStaticServerData       : Pointer;                   //054
             pAnsiCodePageData               : Pointer;                   //058
             pOemCodePageData                : Pointer;                   //05C
             pUnicodeCaseTableData           : Pointer;                   //060
             dwNumberOfProcessors            : DWord;                     //064
             i64NtGlobalFlag                 : Int64;                     //068 Address of a local copy
             i64CriticalSectionTimeout       : Int64;                     //070
             dwHeapSegmentReserve            : DWord;                     //078
             dwHeapSegmentCommit             : DWord;                     //07C
             dwHeapDeCommitTotalFreeThreshold: DWord;                     //080
             dwHeapDeCommitFreeBlockThreshold: DWord;                     //084
             dwNumberOfHeaps                 : DWord;                     //088
             dwMaximumNumberOfHeaps          : DWord;                     //08C
             pProcessHeaps                   : Pointer;                   //090
             pGdiSharedHandleTable           : Pointer;                   //094
             pProcessStarterHelper           : Pointer;                   //098
             pGdiDCAttributeList             : Pointer;                   //09C
             dwLoaderLock                    : DWord;                     //0A0
             dwOSMajorVersion                : DWord;                     //0A4
             dwOSMinorVersion                : DWord;                     //0A8
             wOSBuildNumber                  : Word;                      //0AC
             wOSCSDVersion                   : Word;                      //0AE
             dwOSPlatformId                  : DWord;                     //0B0
             dwImageSubsystem                : DWord;                     //0B4
             dwImageSubsystemMajorVersion    : DWord;                     //0B8
             dwImageSubsystemMinorVersion    : DWord;                     //0BC
             dwImageProcessAffinityMask      : DWord;                     //0C0
             dwGdiHandleBuffer               : array [0..$22-1] of DWord; //0C4
             dwPostProcessInitRoutine        : DWord;                     //14C
             dwTlsExpansionBitmap            : DWord;                     //150
             cTlsExpansionBitmapBits         : array[0..$80-1] of Char;   //154
             dwSessionId                     : DWord;                     //1D4
             pAppCompatInfo                  : Pointer;                   //1D8
             CSDVersion                      : TUnicodeString;            //1DC
           end;
  PPEBNT = ^TPEBNT;

procedure ChangeReloc(POrigBase, PBaseTemp, PReloc, PBaseTarget: Pointer; dwRelocSize: DWord); stdcall;
procedure CreateImportTable(pLibraryHandle, pImportTable: pointer); stdcall;

function LoadLibraryAX(pLibraryName: PChar): DWord; stdcall;
function LoadLibraryParamAX(pLibraryName, pReserved: PChar): DWord; stdcall;
function LoadLibraryParamDllMainAX(pLibraryName, pReserved: PChar; bDllMain: Boolean): DWord; stdcall;

function CreateRemoteThreadX(dwProcessID: DWord; pThreadAttributes: Pointer;
  dwStackSize: DWord; pStartAddr: Pointer; pParameter: Pointer; dwCreationFlags: DWord; var dwThreadID: DWord): DWord; stdcall;
function OpenThreadX(dwAccess: DWord; bInheritHandle: Boolean; dwThreadID: DWord): DWord; stdcall;

function GetKernelHandle: DWord; stdcall;
function GetOwnModuleHandle: DWord; stdcall;
function GetRealModuleHandle(pAddress: pointer): DWord; stdcall;


function VirtualAllocExX(dwProcessID: DWord; pAddress: Pointer; dwSize: DWord; dwAllocationType: DWord; dwProtect: DWord): pointer; stdcall;
function VirtualFreeExX(dwProcessID: DWord; pMemoryAddress: Pointer; dwSize, dwFreeType: Cardinal): Boolean; stdcall;

function GetModuleSize(dwModuleHandle: DWord): Cardinal; stdcall; overload;
function GetModuleSizeEx(dwProcessID, dwModuleHandle: DWord): DWord; stdcall; 
function GetProcAddressX(dwLibraryHandle: DWord; pFunctionName: PChar): Pointer; stdcall;
function GetProcAddressEx(dwProcessID: DWord; pLibraryName, pFunctionName: PChar): Pointer; stdcall;

function is9x: Boolean; stdcall;
function isNT: Boolean; stdcall;

function isBadReadPtrX(pAddress: Pointer; dwSize: DWord): Boolean; stdcall;
function isBadWritePtrX(pAddress: Pointer; dwSize: DWord): Boolean; stdcall;

function GetProcessID(dwProcessHandle: DWord): DWord; stdcall;
function GetProcessIDNT(dwProcessHandle: DWord): DWord; stdcall;
function GetProcessID9X(dwProcessHandle: DWord): DWord; stdcall;
function GetThreadDatablock(hThread: DWord): DWord; stdcall;
function GetThread(dwProcessID: DWord): DWord; stdcall;

function GetModuleHandleEx(dwProcessID: DWord; pModuleName: PChar): DWord; stdcall;
function GetModuleFileNameByHandleEx(dwProcessID: DWord; dwModuleHandle: DWord): String; stdcall;
function GetModuleFileNameByNameEx(dwProcessID: DWord; sModuleName: PChar): String; stdcall;

procedure OutputDebugStringAX(sMessage: PChar); stdcall;

function GetObsfucator: DWord; stdcall;
function GetPDB: Pointer; stdcall;
function GetModuleTable9x: Pointer; stdcall;

function OpenThread9x(dwAccess: DWord; bInheritHandle: Boolean; dwThreadID: DWord): DWord; stdcall;
function OpenThread9x2(dwAccess: DWord; bInheritHandle: Boolean; dwThreadID: DWord): DWord; stdcall;
function OpenThread9x3(dwAccess: DWord; bInheritHandle: Boolean; dwThreadID: DWord): DWord; stdcall;
function OpenThreadNt(dwAccess: DWord; bInheritHandle: Boolean; dwThreadID: DWord): DWord; stdcall;

function GetModuleHandleA9x(pModuleName: PChar): DWord; stdcall;
function GetModuleHandleANt(pModuleName: PChar): DWord; stdcall;
function GetModuleHandleAX(pModuleName: Pchar): DWord; stdcall;

function isDebuggerPresentX: Boolean; stdcall;

function GetModuleFileNameANt(dwModuleHandle: DWord): String; stdcall;
function GetModuleFileNameA9x(dwModuleHandle: DWord): String; stdcall;
function GetModuleFileNameAX(dwModuleHandle: DWord): String; stdcall;

function GetDebugPrivilege: DWord; stdcall;
function SetDebugPrivilege(dwFlag: DWord): Boolean; stdcall; overload;
function GetAndSetDebugPrivilege(dwFlag: DWord; var dwFlagOld: DWord): Boolean; stdcall;

function ReadPChar(dwProcessID: DWord; pAddr: Pointer): string; stdcall;
function ReadPWideChar(dwProcessID: DWord; pAddr: Pointer): string; stdcall;
function FreeLibraryX(dwHandle: DWord): Boolean; stdcall;

function ReadLibrary(pLibraryName: PChar; OrigBase: DWord): DWord; stdcall;

implementation

{$IFDEF DELPHI5_DOWN}
type
    PPointer = ^Pointer;
{$ENDIF}

function ReadPWideChar(dwProcessID: DWord; pAddr: Pointer): string; stdcall;
var
  dwLength: DWord;
  dwProcessID2: DWord;
  pAddrRead: Pointer;
  bBuf: Word;
  dwRead: DWord;
  wString: WideString;
begin
  Result := '';
  dwProcessID2 := OpenProcess(PROCESS_ALL_ACCESS, False, dwProcessID);
  if (dwProcessID2 <> 0) then
    dwProcessID := dwProcessID2;
  pAddrRead := pAddr;
  dwLength := 0;
  while ReadProcessMemory(dwProcessID,pAddrRead,@bBuf,2,dwRead) and (dwRead = 2) and (bBuf <> 0) do
  begin
    inc(dwLength,2);
    pAddrRead := Pointer(DWord(pAddrRead)+2);
  end;
  if (bBuf = 0) and (dwRead = 2) then
  begin
    SetLength(wString,dwLength+2);
    ReadProcessMemory(dwProcessID,pAddr,@wString[1],dwLength+2,dwRead);
    Result := WideCharToString(PWideChar(wString));
  end;
  if (dwProcessID2 <> 0) then
    CloseHandle(dwProcessID2);
end;

function ReadPChar(dwProcessID: DWord; pAddr: Pointer): string; stdcall;
var
  dwLength: DWord;
  dwProcessID2: DWord;
  pAddrRead: Pointer;
  bBuf: Byte;
  dwRead: DWord;
begin
  Result := '';
  dwProcessID2 := OpenProcess(PROCESS_ALL_ACCESS, False, dwProcessID);
  if (dwProcessID2 <> 0) then
    dwProcessID := dwProcessID2;
  pAddrRead := pAddr;
  dwLength := 0;
  while ReadProcessMemory(dwProcessID,pAddrRead,@bBuf,1,dwRead) and (dwRead = 1) and (bBuf <> 0) do
  begin
    inc(dwLength);
    pAddrRead := Pointer(DWord(pAddrRead)+1);
  end;
  if (bBuf = 0) and (dwRead = 1) then
  begin
    SetLength(Result,dwLength+1);
    ReadProcessMemory(dwProcessID,pAddr,@Result[1],dwLength+1,dwRead);
  end;
  if (dwProcessID2 <> 0) then
    CloseHandle(dwProcessID2);
end;

function GetDebugPrivilege: DWord; stdcall;
var
  dwToken       : DWord;
  dwReturnLength: DWord;
  tkp           : TTokenPrivileges;
  tkpold        : TTokenPrivileges;
  luid          : Int64;
begin
  Result := 0;
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, dwToken) then
  begin
    if LookupPrivilegeValue(nil, 'SeDebugPrivilege', luid) then
    begin
      tkp.PrivilegeCount            := 1;
      tkp.Privileges[0].Attributes  := SE_PRIVILEGE_ENABLED;
      tkp.Privileges[0].Luid        := luid;
      AdjustTokenPrivileges(dwToken, False, tkp, SizeOf(tkp), tkpold, dwReturnLength);
      Result := tkpOld.PrivilegeCount;
      AdjustTokenPrivileges(dwToken, False, tkpold, SizeOf(tkpold), tkpold, dwReturnLength);
    end;
    CloseHandle(dwToken);
  end;
end;

function SetDebugPrivilege(dwFlag: DWord): Boolean; stdcall;
var dwFlagOld: DWord;
begin
  Result := GetAndSetDebugPrivilege(dwFlag,dwFlagOld);
end;

function GetAndSetDebugPrivilege(dwFlag: DWord; var dwFlagOld: DWord): Boolean; stdcall; overload;
var
  dwToken       : DWord;
  dwReturnLength: DWord;
  tkp           : TTokenPrivileges;
  tkpold        : TTokenPrivileges;
  luid          : Int64;
begin
  Result := False;
  dwFlagOld := 0;
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, dwToken) then
  begin
    if LookupPrivilegeValue(nil, 'SeDebugPrivilege', luid) then
    begin
      tkp.PrivilegeCount            := 1;
      tkp.Privileges[0].Attributes  := dwFlag;
      tkp.Privileges[0].Luid        := luid;
      Result := AdjustTokenPrivileges(dwToken, False, tkp, SizeOf(tkp), tkpold, dwReturnLength);
      dwFlagOld := tkp.PrivilegeCount;
    end;
    CloseHandle(dwToken);
  end;
end;

function isDebuggerPresentX: Boolean; stdcall;
begin
  if is9x then
    Result := (PPDB98(GetPDB).dwFlags and 1) > 0 else
    Result := (PPEBNT(GetPDB).bBeingDebugged);
end;

function GetModuleTable9x: Pointer; stdcall;
var
  GDIReallyCares: procedure(P: Pointer); stdcall;
begin
  Result := nil;
  @GDIReallyCares := GetProcAddressX(GetKernelHandle,PChar(23));
  if (@GDIReallyCares <> nil) then
  begin
    GDIReallyCares(nil);
    asm
      MOV Result, ECX
    end;
  end;
end;

function GetModuleHandleA9x(pModuleName: PChar): DWord; stdcall;
var
  ModuleTable : PModuleTable;
  pPDB        : PPDB98;
  pModuleRef  : pModRef;
begin
  Result := 0;
  ModuleTable := GetModuleTable9x;
  pPDB := GetPDB;
  pModuleRef := pPDB^.pMODREFList;
  while (pModuleRef <> nil) do
  begin
    if UpperCase(uallUtil.ExtractFileName(ModuleTable[pModuleRef^.wMTEIndex].pModName)) =
       UpperCase(uallUtil.ExtractFileName(pModuleName)) then
       Result := ModuleTable[pModuleRef^.wMTEIndex].dwBaseAddress;
    pModuleRef := pModuleRef^.pNextModRef;
  end;
end;

function GetModuleFileNameA9x(dwModuleHandle: DWord): String; stdcall;
var
  ModuleTable : PModuleTable;
  pPDB        : PPDB98;
  pModuleRef  : pModRef;
begin
  Result := '';
  ModuleTable := GetModuleTable9x;
  pPDB := GetPDB;
  pModuleRef := pPDB^.pMODREFList;
  while (pModuleRef <> nil) do
  begin
    if (ModuleTable[pModuleRef^.wMTEIndex].dwBaseAddress = dwModuleHandle) then
      Result := ModuleTable[pModuleRef^.wMTEIndex].pFileName;
    pModuleRef := pModuleRef^.pNextModRef;
  end;
end;

function OpenThread9x3(dwAccess: DWord; bInheritHandle: Boolean; dwThreadID: DWord): DWord; stdcall;
var
  dwObs: DWord;
begin
  Result := 0;
  dwObs := GetObsfucator;
  if (PWord(dwThreadID xor dwObs)^ = WIN98_K32OBJ_THREAD) then
  begin
    PWord(dwThreadID xor dwObs)^ := WIN98_K32OBJ_PROCESS;
    Result := OpenProcess(dwAccess,False,dwThreadID);
    PWord(dwThreadID xor dwObs)^ := WIN98_K32OBJ_THREAD;
  end;
end;

function GetModuleHandleANt(pModuleName: PChar): DWord; stdcall;
var
  fModule  : PModuleEntry;
  bFound   : Boolean;
  pPEB     : PPEBNT;
begin
  bFound := False;
  Result := 0;
  pPEB := GetPDB;
  fModule := pPEB^.pLdrData^.InLoadOrderModuleList;
  while (fModule <> nil) and (fModule^.ModuleName <> nil) and (not bFound) do
  begin
    if (uallUtil.UpperCase(uallUtil.ExtractFileName(fModule^.ModuleName)) =
        uallUtil.UpperCase(uallUtil.ExtractFileName(pModuleName))) then
      Result := fModule.ModuleHandle;
    fModule := fModule^.NextModule;
  end;
end;

function GetModuleFileNameANt(dwModuleHandle: DWord): String; stdcall;
var
  fModule  : PModuleEntry;
  bFound   : Boolean;
  pPEB     : PPEBNT;
begin
  bFound := False;
  Result := '';
  pPEB := GetPDB;
  fModule := pPEB^.pLdrData^.InLoadOrderModuleList;
  while (fModule <> nil) and (fModule^.ModuleName <> nil) and (not bFound) do
  begin
    if  (fModule^.ModuleHandle = dwModuleHandle) then
      Result := fModule.ModuleName;
    fModule := fModule^.NextModule;
  end;
end;


function OpenThread9x(dwAccess: DWord; bInheritHandle: Boolean; dwThreadID: DWord): DWord; stdcall;
var
  dwCurrentProcess    : DWord;
  dwDupCP             : DWord;
  dwDupCalc           : DWord;
  dwOpenedThreadHandle: DWord;
  pPDB                : PPDB98;
  pHT                 : PHandleTable9x;
  dwDupSave           : THandleTableEntry9x;
begin
  Result := 0;
  pPDB := uallKernel.GetPDB;
  dwCurrentProcess := GetCurrentProcess;
  pHT := pPDB^.pHandleTable;
  if DuplicateHandle(dwCurrentProcess,dwCurrentProcess,dwCurrentProcess,@dwDupCP,0,False,DUPLICATE_SAME_ACCESS) then
  begin
    dwDupCalc := dwDupCP;
    if (pPDB^.bType <> 0) then
      dwDupCalc := dwDupCalc div 4;
    if (dwDupCalc < pHT^.dwEntryCount) then
    begin
      dwDupSave := pHT^.dwTableEntry[dwDupCalc];
      pHT^.dwTableEntry[dwDupCalc].dwFlags := THREAD_ALL_ACCESS;
      pHT^.dwTableEntry[dwDupCalc].pObject := Pointer(dwThreadID xor uallKernel.GetObsfucator);
      if DuplicateHandle(dwCurrentProcess,dwDupCP,dwCurrentProcess,@dwOpenedThreadHandle,dwAccess,bInheritHandle,0) then
        Result := dwOpenedThreadHandle;
      pHT^.dwTableEntry[dwDupCalc] := dwDupSave;
      CloseHandle(dwDupCP);
    end;
  end;
end;

function GetModuleHandleAX(pModuleName: PChar): DWord; stdcall;
begin
  if (is9x) then
    Result := GetModuleHandleA9x(pModuleName) else
    Result := GetModuleHandleANt(pModuleName);
end;

function GetModuleFileNameAX(dwModuleHandle: DWord): String; stdcall;
begin
  if (is9x) then
    Result := GetModuleFileNameA9x(dwModuleHandle) else
    Result := GetModuleFileNameANt(dwModuleHandle);
end;

procedure OutputDebugStringAX(sMessage: PChar); stdcall;
var
  P: Pointer;
begin
  P := @sMessage;
  SetLastError(0);
  try
    Windows.RaiseException($40010006,0,2,@P);
  except
    SetLastError(2);
  end;
end;


function isBadWritePtrX(pAddress: Pointer; dwSize: DWord): Boolean; stdcall;
asm
  XOR EAX, EAX
  PUSH OFFSET @@Handler
  PUSH DWORD PTR FS:[EAX]
  MOV DWORD PTR FS:[EAX], ESP
  MOV ECX, DWORD PTR [dwSize]
  MOV EAX, DWORD PTR [pAddress]
  JMP @@Test
@@Weiter:
  MOV DL, BYTE PTR [EAX]
  MOV BYTE PTR [EAX], DL
  INC EAX
  DEC ECX
@@Test:
  TEST ECX, ECX
  JNZ @@Weiter
  XOR EAX, EAX
  POP DWORD PTR FS:[EAX]
  POP EBX
  JMP @@Ende
@@Handler:
  MOV EAX, DWORD PTR [ESP+$C]
  MOV TContext(EAX).EIP, OFFSET @@Error
  XOR EAX, EAX
  RET
@@Error:
  XOR EAX, EAX
  POP DWORD PTR FS:[EAX]
  ADD ESP, 4
  INC EAX
@@Ende:
end;

function isBadReadPtrX(pAddress: Pointer; dwSize: DWord): Boolean; stdcall;
asm
  XOR EAX, EAX
  PUSH OFFSET @@Handler
  PUSH DWORD PTR FS:[EAX]
  MOV DWORD PTR FS:[EAX], ESP
  MOV ECX, DWORD PTR [dwSize]
  MOV EAX, DWORD PTR [pAddress]
  JMP @@Test
@@Weiter:
  MOV DL, BYTE PTR [EAX]
  INC EAX
  DEC ECX
@@Test:
  TEST ECX, ECX
  JNZ @@Weiter
  XOR EAX, EAX
  POP DWORD PTR FS:[EAX]
  POP EBX
  JMP @@Ende
@@Handler:
  MOV EAX, DWORD PTR [ESP+$C]
  MOV TContext(EAX).EIP, OFFSET @@Error
  XOR EAX, EAX
  RET
@@Error:
  XOR EAX, EAX
  POP DWORD PTR FS:[EAX]
  ADD ESP, 4
  INC EAX
@@Ende:
end;

function GetThread(dwProcessID: DWord): DWord; stdcall;
var
  FSnapshotHandle: THandle;
  FThreadEntry32 : TThreadEntry32;
  ContinueLoop   : Boolean;
begin
  Result := 0;
  dwProcessID := GetProcessID(dwProcessID);
  if (dwProcessID = 0) then
    Exit;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD,0);
  FThreadEntry32.dwSize := Sizeof(FThreadEntry32);
  ContinueLoop := Thread32First(FSnapshotHandle,FThreadEntry32);
  while ContinueLoop do
  begin
    if (FThreadEntry32.th32OwnerProcessID = dwProcessID) then
      result := FThreadEntry32.th32ThreadID;
    ContinueLoop := Thread32Next(FSnapshotHandle,FThreadEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function GetModuleFileNameByNameEx(dwProcessID: DWord; sModuleName: PChar): String; stdcall; overload;
begin
  Result := GetModuleFileNameByHandleEx(dwProcessID,GetModuleHandleEx(dwProcessID,sModuleName));
end;

function GetModuleFileNameByHandleEx(dwProcessID: DWord; dwModuleHandle: DWord): String; stdcall; overload;
var
  FSnapshotHandle: THandle;
  FModuleEntry32 : TModuleEntry32;
  ContinueLoop   : Boolean;
begin
  Result := '';
  dwProcessID := GetProcessID(dwProcessID);
  if (dwProcessID = 0) then
    Exit;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,dwProcessID);
  FModuleEntry32.dwSize := Sizeof(FModuleEntry32);
  ContinueLoop := Module32First(FSnapshotHandle,FModuleEntry32);
  while ContinueLoop do
  begin
    if (dwModuleHandle = FModuleEntry32.hModule) then
     Result := FModuleEntry32.szExePath;
    ContinueLoop := Module32Next(FSnapshotHandle,FModuleEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function GetModuleHandleEx(dwProcessID: DWord; pModuleName: PChar): DWord; stdcall;
var
  FSnapshotHandle: THandle;
  FModuleEntry32 : TModuleEntry32;
  ContinueLoop   : Boolean;
begin
  Result := 0;
  dwProcessID := GetProcessID(dwProcessID);
  if (dwProcessID = 0) then
    Exit;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,dwProcessID);
  FModuleEntry32.dwSize := Sizeof(FModuleEntry32);
  ContinueLoop := Module32First(FSnapshotHandle,FModuleEntry32);
  while ContinueLoop do
  begin
    if (Pos(UpperCase(pModuleName),UpperCase(FModuleEntry32.szModule)) > 0) then
      Result := FModuleEntry32.hModule;
    ContinueLoop := Module32Next(FSnapshotHandle,FModuleEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function GetProcessID(dwProcessHandle: DWord): DWord; stdcall;
var dwProcessH: DWord;
begin
  dwProcessH := OpenProcess(PROCESS_ALL_ACCESS, False, dwProcessHandle);
  if (dwProcessH <> 0) then
  begin
    CloseHandle(dwProcessH);
    Result := dwProcessHandle;
  end else
  if isNt then
    Result := GetProcessIDNT(dwProcessHandle) else
    Result := GetPRocessID9X(dwProcessHandle);
end;

function GetObsfucator: DWord; stdcall;
asm
  CALL GetCurrentProcessID
  XOR EAX, DWORD PTR FS:[30h]
end;

function GetPDB: Pointer; stdcall;
asm
  MOV EAX, DWORD PTR FS:[30h]
end;

function GetProcessID9X(dwProcessHandle: DWord): DWord; stdcall;
var
  dwObs: DWord;
  pHT  : PHandleTable9x;
  pPDB : pPDB98;
begin
  Result := 0;
  if (dwProcessHandle = 0) then
    Exit;
  if (dwProcessHandle = GetCurrentProcess) then
    Result := GetCurrentProcessID else
  begin
    dwObs := GetObsfucator;
    pPDB := GetPDB;
    pHT :=  pPDB^.pHandleTable;
    if (PDWord(pPDB)^ <> 0) then
      dwProcessHandle := dwProcessHandle div 4;
    if (dwProcessHandle < pHT^.dwEntryCount) then
      Result := DWord(pHT^.dwTableEntry[dwProcessHandle].pObject) xor dwObs;
  end;
end;

function GetProcessIdNT(dwProcessHandle: DWord): DWord; stdcall;
var
  NtQueryInformationProcess: function(dwHandle: DWord; dwInfo: DWord;
    pbi: PProcessBasicInformation; dwSize: DWord; pData: Pointer): DWord; stdcall;
  pbi                      : TProcessBasicInformation;
begin
  Result := 0;
  @NtQueryInformationProcess := GetProcAddress(GetModuleHandle('ntdll.dll'),'NtQueryInformationProcess');
  if (@NtQueryInformationProcess <> nil) then
  begin
    if (NtQueryInformationProcess(dwProcessHandle, 0, @pbi, SizeOf(pbi), nil) = 0) then
      Result := pbi.UniqueProcessId;
  end;
end;

function GetThreadDatablock(hThread: DWord): DWord; stdcall;
var
  SelectorEntry: TLDTEntry;
  lpContext    : TContext;
begin
  result := 0;
  lpContext.ContextFlags := CONTEXT_FULL;
  if GetThreadContext(hThread,lpContext) and
     GetThreadSelectorEntry(hThread,lpContext.SegFs,SelectorEntry) then
  begin
    Result := (SelectorEntry.BaseHi shl 24) or (SelectorEntry.BaseMid shl 16) or
              SelectorEntry.BaseLow;
  end;
end;


function FindFirstModuleHandle(dwProcessHandle: DWord): DWord; stdcall;
var
  Memory     : TMemoryBasicInformation;
  pStart     : Pointer;
  DosHdr     : TImageDosHeader;
  dwBytesRead: DWord;
begin
  pStart := nil;
  Result := 0;
  while VirtualQuery(pStart,Memory,SizeOf(Memory)) > 0 do
  begin
    if (Memory.State <> MEM_FREE) then
    begin
      if (ReadProcessMemory(dwProcessHandle,Memory.AllocationBase,@DosHdr,SizeOf(DosHdr),dwBytesRead)) and
         (dwBytesRead = SizeOf(DosHdr)) and
         (DosHdr.e_magic = IMAGE_DOS_SIGNATURE) then
           Result := DWord(Memory.AllocationBase);
    end;
    pStart := Pointer(DWord(Memory.BaseAddress)+Memory.RegionSize);
  end;
end;


function GetModuleSize(dwModuleHandle: DWord): DWord; stdcall;
var
  IDH: PImageDosHeader;
  INH: PimageNtHeaders;
begin
  Result := 0;
  if (dwModuleHandle = 0) then
    Exit;
  IDH := Pointer(dwModuleHandle);
  if isBadReadPtr(IDH,SizeOf(TImageDosHeader)) then
    Exit;
  if (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
    Exit;
  INH := Pointer(dwModuleHandle+DWord(IDH^._lfanew));
  if (INH^.Signature <> IMAGE_NT_SIGNATURE) then
    Exit;
  if isBadReadPtr(INH,SizeOf(TImageNtHeaders)) then
    Exit;
  Result := INH^.OptionalHeader.SizeOfImage;
end;

function GetModuleSizeEx(dwProcessID, dwModuleHandle: DWord): DWord; stdcall; overload;
var
  dwProcessID2: DWord;
  IDH         : TImageDosHeader;
  INH         : TImageNtHeaders;
  dwRead      : DWord;
begin
  Result := 0;
  dwProcessID2 := OpenProcess(PROCESS_ALL_ACCESS,false,dwProcessID);
  if (dwProcessID2 <> 0) then
    dwProcessID := dwProcessID2;

  if ReadProcessMemory(dwProcessID, Pointer(dwModuleHandle), @IDH, SizeOf(TImageDosHeader),dwRead) and
    (dwRead = SizeOf(TImageDosHeader)) then
  begin
    if (IDH.e_magic = IMAGE_DOS_SIGNATURE) and
       ReadProcessMemory(dwProcessID, Pointer(dwModuleHandle+DWord(IDH._lfanew)), @INH, SizeOf(TImageNtHeaders),dwRead) and
       (dwRead = SizeOf(TImageNtHeaders)) then
    begin
      if (INH.Signature = IMAGE_NT_SIGNATURE) then
        Result :=  INH.OptionalHeader.SizeOfImage;
    end;
  end;
  if (dwProcessID2 <> 0) then
    CloseHandle(dwProcessID2);
end;

function GetModuleSizeEx(dwProcessID: DWord; pLibraryName: PChar): DWord; stdcall; overload;
begin
  result := GetModuleSizeEx(dwProcessID, GetModuleHandleEx(dwProcessID, pLibraryName));
end;

function GetProcAddressEx(dwProcessID: DWord; pLibraryName, pFunctionName: PChar): Pointer; stdcall;
var
  dwProcessID2    : DWord;
  dwSize          : DWord;
  dwBase          : DWord;
  dwRead          : DWord;
  pFunctionAddress: Pointer;
  pMemory         : Pointer;
begin
  Result := Nil;
  if (dwProcessID = 0) then
    Exit;
  dwProcessID2 := OpenProcess(PROCESS_ALL_ACCESS,false,dwProcessID);
  if (dwProcessID2 = 0) then
    Exit;

  dwSize := GetModuleSizeEx(dwProcessID,pLibraryName);
  dwBase := GetModuleHandleEx(dwProcessID,pLibraryName);

  if (dwSize = 0) or (dwBase = 0) then
    Exit;

  pMemory := VirtualAlloc(nil,dwSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pMemory = nil) then
    Exit;
  if (not ReadProcessMemory(dwProcessID2, Pointer(dwBase), pMemory, dwSize, dwRead)) or (dwRead <> dwSize) then
    Exit;
  pFunctionAddress := GetProcAddressX(DWord(pMemory), pFunctionName);

  if (DWord(pFunctionAddress) <= DWord(pMemory)) or
     (DWord(pFunctionAddress) >= DWord(pMemory)+dwSize) then
    Result := nil else
    Result := Pointer( DWord(pFunctionAddress) - DWord(PMemory) + dwBase);

  VirtualFree(pMemory,dwSize,MEM_DECOMMIT);
  if (dwProcessID2 <> 0) then
    CloseHandle(dwProcessID2);
end;

function is9x: boolean; stdcall;
asm
  MOV     EAX, FS:[030H]
  TEST    EAX, EAX
  SETS    AL
end;

function isNT: boolean; stdcall;
begin
  result := (GetVersion and $80000000) = 0;
end;

function GetRealModuleHandle(pAddress: pointer): DWord; stdcall;
var
  lpBuffer: TMemoryBasicInformation;
begin
  Result := 0;
  if VirtualQuery(pAddress,lpBuffer,sizeof(lpBuffer)) = 0 then
    Exit;
  Result := DWord(lpBuffer.AllocationBase);
end;

function GetOwnModuleHandle: DWord; stdcall;
begin
  result := GetRealModuleHandle(@GetOwnModuleHandle);
end;

function GetKernelHandle: DWord; stdcall;
asm
  MOV     EAX, DWORD PTR FS:[030H]
  TEST    EAX, EAX
  JS      @@W9X
@@WNT:
  MOV     EAX, DWORD PTR [EAX+00CH]
  MOV     ESI, DWORD PTR [EAX+01CH]
  LODSD
  MOV     EAX, DWORD PTR [EAX+008H]
  JMP     @@K32
@@W9X:
  MOV     EAX, DWORD PTR [EAX+034H]
  LEA     EAX, DWORD PTR [EAX+07CH]
  MOV     EAX, DWORD PTR [EAX+03CH]
@@K32:
end;


function GetProcAddressX(dwLibraryHandle: DWord; pFunctionName: PChar): Pointer; stdcall;
var
  NtHeader           : PImageNtHeaders;
  DosHeader          : PImageDosHeader;
  DataDirectory      : PImageDataDirectory;
  ExportDirectory    : PImageExportDirectory;
  i                  : Integer;
  iExportOrdinal     : Integer;
  ExportName         : String;
  dwPosDot           : DWord;
  dwNewmodule        : DWord;
  pFirstExportName   : Pointer;
  pFirstExportAddress: Pointer;
  pFirstExportOrdinal: Pointer;
  pExportAddr        : PDWord;
  pExportNameNow     : PDWord;
  pExportOrdinalNow  : PWord;
begin
  Result := nil;
  DosHeader := Pointer(dwLibraryHandle);
  if (pFunctionName = nil) then
    Exit;

  if (isBadReadPtr(DosHeader,sizeof(TImageDosHeader)) or
     (DosHeader^.e_magic <> IMAGE_DOS_SIGNATURE)) then
    Exit; {Wrong PE (DOS) Header}

  NtHeader := Pointer(DWord(DosHeader^._lfanew)+DWord(DosHeader));
  if (isBadReadPtr(NtHeader, sizeof(TImageNTHeaders)) or
     (NtHeader^.Signature <> IMAGE_NT_SIGNATURE)) then
    Exit; {Wrong PW (NT) Header}

  DataDirectory := @NtHeader^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT];
  if (DataDirectory = nil) or (DataDirectory^.VirtualAddress = 0) then
    Exit; {Library has no exporttable}

  ExportDirectory := Pointer(DWord(DosHeader) + DWord(DataDirectory^.VirtualAddress));
  if isBadReadPtr(ExportDirectory,SizeOf(TImageExportDirectory)) then
    Exit;

  pFirstExportName := Pointer(DWord(ExportDirectory^.AddressOfNames)+DWord(DosHeader));
  pFirstExportOrdinal := Pointer(DWord(ExportDirectory^.AddressOfNameOrdinals)+DWord(DosHeader));
  pFirstExportAddress := Pointer(DWord(ExportDirectory^.AddressOfFunctions)+DWord(DosHeader));

  if (integer(pFunctionName) > $FFFF) then {is FunctionName a PChar?}
  begin
    iExportOrdinal := -1;                  {if we dont find the correct ExportOrdinal}
    for i := 0 to ExportDirectory^.NumberOfNames-1 do {for each export do}
    begin
      pExportNameNow := Pointer(Integer(pFirstExportName)+SizeOf(Pointer)*i);
      if (not isBadReadPtr(pExportNameNow,SizeOf(DWord))) then
      begin
        ExportName := PChar(pExportNameNow^+ DWord(DosHeader));
        if (ExportName = pFunctionName) then {is it the export we search? Calculate the ordinal.}
        begin
          pExportOrdinalNow := Pointer(Integer(pFirstExportOrdinal)+SizeOf(Word)*i);
          if (not isBadReadPtr(pExportOrdinalNow,SizeOf(Word))) then
            iExportOrdinal := pExportOrdinalNow^;
        end;
      end;
    end;
  end else{no PChar, calculate the ordinal directly}
    iExportOrdinal := DWord(pFunctionName)-DWord(ExportDirectory^.Base);

  if (iExportOrdinal < 0) or (iExportOrdinal > Integer(ExportDirectory^.NumberOfFunctions)) then
    Exit; {havent found the ordinal}

  pExportAddr := Pointer(iExportOrdinal*4+Integer(pFirstExportAddress));
  if (isBadReadPtr(pExportAddr,SizeOf(DWord))) then
    Exit;

  {Is the Export outside the ExportSection? If not its NT spezific forwared function}
  if (pExportAddr^ < DWord(DataDirectory^.VirtualAddress)) or
     (pExportAddr^ > DWord(DataDirectory^.VirtualAddress+DataDirectory^.Size)) then
  begin
    if (pExportAddr^ <> 0) then {calculate export address}
      Result := Pointer(pExportAddr^+DWord(DosHeader));
  end else
  begin {forwarded function (like kernel32.EnterCriticalSection -> NTDLL.RtlEnterCriticalSection)}
    ExportName := PChar(dwLibraryHandle+pExportAddr^);
    dwPosDot := Pos('.',ExportName);
    if (dwPosDot > 0) then
    begin
      dwNewModule := GetModuleHandle(PChar(Copy(ExportName,1,dwPosDot-1)));
      if (dwNewModule = 0) then
        dwNewModule := LoadLibrary(PChar(Copy(ExportName,1,dwPosDot-1)));
      if (dwNewModule <> 0) then
        result := GetProcAddressX(dwNewModule,PChar(Copy(ExportName,dwPosDot+1,Length(ExportName))));
    end;
  end;
end;

function VirtualAllocExX(dwProcessID: DWord; pAddress: Pointer; dwSize: DWord; dwAllocationType: DWord; dwProtect: DWord): pointer; stdcall;
var
  dwProcessID2: DWord;
begin
  dwProcessID2 := OpenProcess(PROCESS_ALL_ACCESS,false,dwProcessID);
  if (dwProcessID2 <> 0) then
    dwProcessID := dwProcessID2;

  if (not isNT) then {win9x has no VAEx API -> get shared memory}
    Result := VirtualAlloc(pAddress,dwSize,$8000000 or dwAllocationType,dwProtect) else
    Result := VirtualAllocEx(dwProcessID,pAddress,dwSize,dwAllocationType,dwProtect);

  if (dwProcessID2 <> 0) then
    CloseHandle(dwProcessID2);
end;

function VirtualFreeExX(dwProcessID: DWord; pMemoryAddress: Pointer; dwSize, dwFreeType: DWord): Boolean; stdcall;
var
  dwProcessID2: DWord;
begin
  dwProcessID2 := OpenProcess(PROCESS_ALL_ACCESS,false,dwProcessID);
  if (dwProcessID2 <> 0) then
    dwProcessID := dwProcessID2;

  if (not isNT) then {win9x has no VFEx API -> release shared memory normaly}
    Result := VirtualFree(pMemoryAddress,dwSize,dwFreeType) else
    Result := VirtualFreeEx(dwProcessID,pMemoryAddress,dwSize,dwFreeType) <> nil;

  if (dwProcessID2 <> 0) then
    CloseHandle(dwProcessID2);
end;

procedure ThreadCreateThread; stdcall; forward;

procedure ThreadCreateThreadBegin;
asm
  CALL ThreadCreateThread
end;

procedure ThreadCreateThread; stdcall;
var
  XCreateThread    : function (pThreadAttributes: Pointer; dwStackSize: DWord; pStartAddr: Pointer;
                               pParameter: Pointer; dwCreationFlags: DWord; var dwThreadID: DWord): DWord; stdcall;
  dwThreadID       : DWord;
  dwStackSize      : DWord;
  dwCreationFlags  : DWord;
  pParam           : Pointer;
  pThreadAttributes: Pointer;
  pStartAddr       : Pointer;
  pParameter       : Pointer;
  pRet             : Pointer;
begin
  asm
    CALL @@GetAddr
    @@GetAddr:
    POP EAX                     // Return Address in EAX [offset @@GetAddr in EAX] ; Target   ex. 00D20050
    MOV EBX, OFFSET @@GetAddr   // Offset GetAddr in EBX                           ; Source       00450030
    SUB EBX, OFFSET ThreadCreateThreadBegin // subtract Offset ThreadCreateThread  ; Source       00450012
    SUB EAX, EBX                            // subtract the difference             ; Target       00D20022
    SUB EAX, 7*4                            // subtract parametersize                             etc.
    MOV DWORD PTR [pParam], EAX              // store it in Param
  end;
  @XCreateThread := PPointer(DWord(pParam)+0*SizeOf(Pointer))^;

  pThreadAttributes := PPointer(DWord(pParam)+1*SizeOf(Pointer))^;
  dwStackSize := PDWord(DWord(pParam)+2*SizeOf(Pointer))^;
  pStartAddr := PPointer(DWord(pParam)+3*SizeOf(Pointer))^;
  pParameter := PPointer(DWord(pParam)+4*SizeOf(Pointer))^;
  dwCreationFlags := PDWord(DWord(pParam)+5*SizeOf(Pointer))^;
  pRet := PPointer(DWord(pParam)+6*SizeOf(Pointer))^;

  if (@XCreateThread <> nil) and (pStartAddr <> nil) then
    XCreateThread(pThreadAttributes,dwStackSize,pStartAddr,pParameter,dwCreationFlags,dwThreadID);
  asm
    PUSH DWORD PTR [pRet]
    POP DWORD PTR [EBP+4]
  end;
end;

procedure ThreadCreateThreadEnd;
asm
  JMP ThreadCreateThread
end;

function CreateRemoteThreadX(dwProcessID: DWord; pThreadAttributes: Pointer; dwStackSize: DWord;
 pStartAddr: Pointer; pParameter: Pointer; dwCreationFlags: DWord; var dwThreadID: DWord): DWord; stdcall;
var
  i             : Integer;
  cContext      : TContext;
  dwProcessID2  : DWord;
  dwMemSize     : DWord;
  dwThreadUsed  : DWord;
  dwSuspendCount: DWord;
  dwWritten     : DWord;
  pTargetMemory : Pointer;
  pTargetMemMove: Pointer;
  pAddr         : Pointer;
  pReturnAddr   : Pointer;
begin
  Result := 0;
  dwProcessID2 := OpenProcess(PROCESS_ALL_ACCESS,false,dwProcessID);
  if (dwProcessID2 <> 0) then
    dwProcessID := dwProcessID2;
   if (isNt) then
    Result := CreateRemoteThread(dwProcessID,pThreadAttributes,dwStackSize,pStartAddr,pParameter,
      dwCreationFlags,dwThreadID) else
  begin
    dwMemSize := 7*SizeOf(Pointer)+Integer(@ThreadCreateThreadEnd)- Integer(@ThreadCreateThreadBegin);
    pTargetMemory := VirtualAllocExX(dwProcessID,nil,dwMemSize, MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
    pTargetMemMove := pTargetMemory;
    dwThreadUsed := GetThread(dwProcessID);
    pAddr := GetProcAddress(GetModuleHandle('kernel32.dll'),'CreateThread');
    if (pTargetMemory <> nil) and (dwThreadUsed <> 0) and (pAddr <> nil) then
    begin
      dwThreadUsed := OpenThreadX(THREAD_ALL_ACCESS,false,dwThreadUsed);
      if (dwThreadUsed <> 0) then
      begin
        dwSuspendCount := SuspendThread(dwThreadUsed);
        for i := 0 to dwSuspendCount-1 do
          SuspendThread(dwThreadUsed);
        cContext.ContextFlags := CONTEXT_FULL;
        if GetThreadContext(dwThreadUsed,cContext) then
        begin
          pReturnAddr := Pointer(cContext.Eip);

          WriteProcessMemory(dwProcessID,pTargetMemMove,@pAddr,SizeOf(DWord),dwWritten);
          pTargetMemMove := Pointer(DWord(pTargetMemMove)+dwWritten);
          WriteProcessMemory(dwProcessID,pTargetMemMove,@pThreadAttributes,SizeOf(DWord),dwWritten);
          pTargetMemMove := Pointer(DWord(pTargetMemMove)+dwWritten);
          WriteProcessMemory(dwProcessID,pTargetMemMove,@dwStackSize,SizeOf(DWord),dwWritten);
          pTargetMemMove := Pointer(DWord(pTargetMemMove)+dwWritten);
          WriteProcessMemory(dwProcessID,pTargetMemMove,@pStartAddr,SizeOf(DWord),dwWritten);
          pTargetMemMove := Pointer(DWord(pTargetMemMove)+dwWritten);
          WriteProcessMemory(dwProcessID,pTargetMemMove,@pParameter,SizeOf(DWord),dwWritten);
          pTargetMemMove := Pointer(DWord(pTargetMemMove)+dwWritten);
          WriteProcessMemory(dwProcessID,pTargetMemMove,@dwCreationFlags,SizeOf(DWord),dwWritten);
          pTargetMemMove := Pointer(DWord(pTargetMemMove)+dwWritten);
          WriteProcessMemory(dwProcessID,pTargetMemMove,@pReturnAddr,SizeOf(DWord),dwWritten);
          pTargetMemMove := Pointer(DWord(pTargetMemMove)+dwWritten);
          WriteProcessMemory(dwProcessID,pTargetMemMove,@ThreadCreateThreadBegin,
            DWord(@ThreadCreateThreadEnd)-DWord(@ThreadCreateThreadBegin),dwWritten);

          cContext.Eip := DWord(pTargetMemMove);
          if SetThreadContext(dwThreadUsed,cContext) then
            Result := 1;
        end;
        for i := 0 to dwSuspendCount do
          ResumeThread(dwThreadUsed);
      end;
    end;
  end;
  if (dwProcessID2 <> 0) then
    CloseHandle(dwProcessID2);
end;


function OpenThread9x2(dwAccess: DWord; bInheritHandle: Boolean; dwThreadID: DWord): DWord; stdcall;
var
  pTDB        : Pointer;
  pOpenProcess: Pointer;
  OpenThread  : Pointer;
begin
  Result := 0;
  pTDB := Pointer(dwThreadID xor GetObsfucator);
  if IsBadReadPtr(pTDB, 4) then
    Exit;
  pOpenProcess := GetProcAddress(GetModuleHandle('kernel32.dll'),'OpenProcess');
  if (pOpenProcess = nil) then
    Exit;
  if (PByte(pOpenProcess)^ = $68) then
    pOpenProcess := PPointer(Pointer(DWord(pOpenProcess)+1))^;

  OpenThread := Pointer(DWord(pOpenProcess)+$24);
  asm
    PUSH    DWORD PTR [dwAccess]
    PUSH    DWORD PTR [bInheritHandle]
    PUSH    DWORD PTR [dwThreadID]
    MOV     EAX, DWORD PTR [pTDB]
    CALL    OpenThread
    MOV     Result, EAX
  end;
end;

function OpenThreadNt(dwAccess: DWord; bInheritHandle: Boolean; dwThreadID: DWord): Dword; stdcall;
var
  pOpenThreadNT: function (dwAccess: DWord; bInheritHandle: LongBool; dwThreaID: DWord): DWord; stdcall;
begin
  Result := 0;
  @pOpenThreadNT := GetProcAddress(GetModuleHandle('kernel32.dll'),'OpenThread');
  if (@pOpenThreadNT = nil) then
    Exit;
  Result := pOpenThreadNT(dwAccess,bInheritHandle,dwThreadID);
end;

function OpenThreadX(dwAccess: DWord; bInheritHandle: Boolean; dwThreadID: DWord): DWord; stdcall;
begin
  if isNT then
    Result := OpenThreadNT(dwAccess, bInheritHandle, dwThreadID) else
    Result := OpeNThread9x(dwAccess,bInheritHandle,dwThreadID);
end;


function LoadLibraryAX(pLibraryName: PChar): DWord; stdcall;
begin
  result := LoadLibraryParamAX(pLibraryName, nil);
end;

procedure ChangeReloc(POrigBase, PBaseTemp, PReloc, PBaseTarget: Pointer; dwRelocSize: DWord); stdcall;
var
  pCurrentRelocBlock: PRelocBlock;
  RelocCount        : DWord;
  PCurrentStart     : PWord;
  i                 : Integer;
  pRelocAddress     : PInteger;
  iDif              : Integer;
Begin
  pCurrentRelocBlock := PReloc;
  iDif := Integer(PBaseTarget) - Integer(POrigBase);
  PCurrentStart := Pointer(Integer(PReloc) + 8);
  while (not isBadReadPtr(pCurrentRelocBlock, SizeOf(TRelocBlock))) and
        (not isBadReadPtr(pCurrentStart,SizeOf(Pointer))) and
        (DWord(pCurrentRelocBlock) < DWord(pReloc)+dwRelocSize ) do
  begin
    RelocCount := (pCurrentRelocBlock^.dwSize - 8) div SizeOf(Word);
    for i := 0 to RelocCount - 1 do
    begin
      if (not isBadReadPtr(pCurrentStart,SizeOf(Pointer))) and
         (PCurrentStart^ xor $3000 < $1000) then
      begin
        pRelocAddress := Pointer(pCurrentRelocBlock^.dwAddress + PCurrentStart^ mod $3000 + DWord(PBaseTemp));
        if (not isBadWritePtr(pRelocAddress,SizeOf(Integer))) then
          pRelocAddress^ := pRelocAddress^ + iDif;
      end;
      PCurrentStart := Pointer(DWord(PCurrentStart) + SizeOf(Word));
    end;
    pCurrentRelocBlock := Pointer(PCurrentStart);
    pCurrentStart := Pointer(DWord(PCurrentStart) + 8);
  end;
end;

procedure ChangeRelocOld(POrigBase, PBaseTemp, PReloc, PBaseTarget: Pointer); stdcall;
var
  pCurrentRelocBlock: PRelocBlock;
  RelocCount        : DWord;
  PCurrentStart     : PWord;
  i                 : Integer;
  pRelocAddress     : PInteger;
  iDif              : Integer;
Begin
  pCurrentRelocBlock := PReloc;
  iDif := Integer(PBaseTarget) - Integer(POrigBase);
  PCurrentStart := Pointer(Integer(PReloc) + 8);
  while (not isBadReadPtr(pCurrentRelocBlock, SizeOf(TRelocBlock))) and
        (not isBadReadPtr(pCurrentStart,SizeOf(Pointer))) and
        (pCurrentRelocBlock^.dwAddress <> 0) do
  begin
    RelocCount := (pCurrentRelocBlock^.dwSize - 8) div SizeOf(Word);
    for i := 0 to RelocCount - 1 do
    begin
      if (not isBadReadPtr(pCurrentStart,SizeOf(Pointer))) and
         (PCurrentStart^ xor $3000 < $1000) then
      begin
        pRelocAddress := Pointer(pCurrentRelocBlock^.dwAddress + PCurrentStart^ mod $3000 + DWord(PBaseTemp));
        if (not isBadWritePtr(pRelocAddress,SizeOf(Integer))) then
          pRelocAddress^ := pRelocAddress^ + iDif;
      end;
      PCurrentStart := Pointer(DWord(PCurrentStart) + SizeOf(Word));
    end;
    pCurrentRelocBlock := Pointer(PCurrentStart);
    pCurrentStart := Pointer(DWord(PCurrentStart) + 8);
  end;
end;

procedure CreateImportTable(pLibraryHandle, pImportTable: pointer); stdcall;
var pIBlock        : PImportBlock;
    pThunksRead    : PDWord;
    pThunksWrite   : PDWord;
    pDllName       : PChar;
    dwLibraryHandle: DWord;
    dwOldProtect   : DWord;
begin
  pIBlock := pImportTable;
  while (not isBadReadPtr(pIBlock,SizeOf(TImportBlock))) and
        (pIBlock^.pFirstThunk <> nil) and (pIBlock^.dwName <> 0) do
  begin
    pDllName := Pointer(DWord(pLibraryHandle)+DWord(pIBlock^.dwName));
    if (not isBadReadPtr(pDllName,4)) then
    begin
      dwLibraryHandle := LoadLibrary(pDllName);
      pThunksRead := Pointer(DWord(pIBlock^.pFirstThunk)+DWord(pLibraryHandle));
      pThunksWrite := pThunksRead;
      if (DWord(pIBlock^.dwTimeDateStamp) = $FFFFFFFF) then
        pThunksRead := Pointer(DWord(pIBlock^.dwCharacteristics)+DWord(pLibraryHandle));
      while (not isBadReadPtr(pThunksRead,SizeOf(DWord))) and
            (not isBadReadPtr(pThunksWrite,SizeOf(Word))) and
            (pThunksRead^ <> 0) do
      begin
        if VirtualProtect(pThunksWrite,SizeOf(DWord),PAGE_EXECUTE_READWRITE,dwOldProtect) then
        begin
          if (DWord(pThunksRead^) and  $80000000 <> 0) then
            pThunksWrite^ := DWord(GetProcAddress(dwLibraryHandle,PChar(pThunksRead^ and $FFFF))) else
            pThunksWrite^ := DWord(GetProcAddress(dwLibraryHandle,PChar(DWord(pLibraryHandle)+pThunksRead^+SizeOf(Word))));
          VirtualProtect(pThunksWrite,SizeOf(DWord),dwOldProtect,dwOldProtect);
        end;
        Inc(pThunksRead);
        Inc(pThunksWrite);
      end;
    end;
    pIBlock := Pointer(DWord(pIBlock)+SizeOf(TImportBlock));
  end;
end;

function FreeLibraryX(dwHandle: DWord): Boolean; stdcall;
var
  IDH: PImageDosHeader;
  INH: PImageNTHeaders;
begin
  Result := false;
  if (dwHandle = 0) then
    Exit;

  IDH := Pointer(dwHandle);
  if (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
    Exit;

  INH := Pointer(DWord(IDH^._lfanew)+DWord(IDH));
  if (INH^.Signature <> IMAGE_NT_SIGNATURE) then
    Exit;

  if VirtualFree(Pointer(dwHandle),INH^.OptionalHeader.SizeOfImage,MEM_DECOMMIT) then
    Result := True;
end;

function LoadLibraryParamAX(pLibraryName, pReserved: PChar): DWord; stdcall;
begin
  Result := LoadLibraryParamDllMainAX(pLibraryName, pReserved, true);
end;

function ReadLibrary(pLibraryName: PChar; OrigBase: DWord): DWord; stdcall;
var
  DllMain    : function (dwHandle, dwReason, dwReserved: DWord): DWord; stdcall;
  IDH        : PImageDosHeader;
  INH        : PImageNtHeaders;
  SEC        : PImageSectionHeader;
  dwread     : DWord;
  dwSecCount : DWord;
  dwFileSize : DWord;
  dwmemsize  : DWord;
  i          : Integer;
  iFileHandle: Integer;
  pFileMem   : Pointer;
  pAll       : Pointer;
  SysDirP    : array [0..MAX_PATH-1] of Char;
  SysDir     : String;
begin
  Result := 0;
  iFileHandle := CreateFileA(pLibraryName,GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
  if (iFileHandle <= 0) then
  begin
    GetSystemDirectory(SysDirP, MAX_PATH);
    SysDir := SysDirP;
    iFileHandle := CreateFileA(PChar(SysDir+'\'+pLibraryName),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
    if (iFileHandle <= 0) then
      iFileHandle := CreateFileA(PChar(SysDir+'\DRIVERS\'+pLibraryName),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
      if (iFileHandle <= 0) then
        Exit;
  end;

  dwFileSize := GetFileSize(iFileHandle,nil);
  pFileMem := VirtualAlloc(nil,dwFileSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pFileMem = nil) then
  begin
    CloseHandle(iFileHandle);
    Exit;
  end;

  ReadFile(iFileHandle,pFileMem^,dwFileSize,dwRead,nil);
  IDH := pFileMem;
  if (isBadReadPtr(IDH,SizeOf(TImageDosHeader))) or
     (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
  begin
    VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  INH := pointer(cardinal(pFileMem)+cardinal(IDH^._lfanew));
  if (isBadReadPtr(INH, SizeOf(TImageNtHeaders))) or
     (INH^.Signature <> IMAGE_NT_SIGNATURE) then
  begin
    VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  SEC := Pointer(Integer(INH)+SizeOf(TImageNtHeaders));
  dwMemSize := INH^.OptionalHeader.SizeOfImage;
  if (dwMemSize = 0) then
  begin
    VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  pAll := VirtualAlloc(nil,dwMemSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pAll = nil) then
  begin
    VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  dwSecCount := INH^.FileHeader.NumberOfSections;
  CopyMemory(pAll,IDH,DWord(SEC)-DWord(IDH)+dwSecCount*SizeOf(TImageSectionHeader));
  for i := 0 to dwSecCount-1 do
  begin
    CopyMemory(Pointer(DWord(pAll)+SEC^.VirtualAddress),
      Pointer(DWord(pFileMem)+DWord(SEC^.PointerToRawData)),
      SEC^.SizeOfRawData);
    SEC := Pointer(Integer(SEC)+SizeOf(TImageSectionHeader));
  end;

  if (INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress <> 0) then
  ChangeReloc(Pointer(INH^.OptionalHeader.ImageBase),
              pAll,
              Pointer(DWord(pAll)+INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress),
              Pointer(OrigBase),
              INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size);
  CreateImportTable(pAll, Pointer(DWord(pAll)+INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress));

  @DllMain := Pointer(INH^.OptionalHeader.AddressOfEntryPoint+DWord(pAll));
  Result := DWord(pAll);

  VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
  CloseHandle(iFileHandle);
end;


function LoadLibraryParamDllMainAX(pLibraryName, pReserved: PChar; bDllMain: Boolean): DWord; stdcall;
var
  DllMain    : function (dwHandle, dwReason, dwReserved: DWord): DWord; stdcall;
  IDH        : PImageDosHeader;
  INH        : PImageNtHeaders;
  SEC        : PImageSectionHeader;
  dwread     : DWord;
  dwSecCount : DWord;
  dwLen      : DWord;
  dwFileSize : DWord;
  dwmemsize  : DWord;
  i          : Integer;
  iFileHandle: Integer;
  pFileMem   : Pointer;
  pAll       : Pointer;
  SysDirP    : array [0..MAX_PATH-1] of Char;
  SysDir     : String;
begin
  Result := 0;
  iFileHandle := CreateFileA(pLibraryName,GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
  if (iFileHandle <= 0) then
  begin
    GetSystemDirectory(SysDirP, MAX_PATH);
    SysDir := SysDirP;
    iFileHandle := CreateFileA(PChar(SysDir+'\'+pLibraryName),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
    if (iFileHandle <= 0) then
      iFileHandle := CreateFileA(PChar(SysDir+'\DRIVERS\'+pLibraryName),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
      if (iFileHandle <= 0) then
        Exit;
  end;

  dwFileSize := GetFileSize(iFileHandle,nil);
  pFileMem := VirtualAlloc(nil,dwFileSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pFileMem = nil) then
  begin
    CloseHandle(iFileHandle);
    Exit;
  end;

  ReadFile(iFileHandle,pFileMem^,dwFileSize,dwRead,nil);
  IDH := pFileMem;
  if (isBadReadPtr(IDH,SizeOf(TImageDosHeader))) or
     (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
  begin
    VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  INH := pointer(cardinal(pFileMem)+cardinal(IDH^._lfanew));
  if (isBadReadPtr(INH, SizeOf(TImageNtHeaders))) or
     (INH^.Signature <> IMAGE_NT_SIGNATURE) then
  begin
    VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  if (pReserved <> nil) then
    dwLen := Length(pReserved)+1 else dwLen := 0;

  SEC := Pointer(Integer(INH)+SizeOf(TImageNtHeaders));
  dwMemSize := INH^.OptionalHeader.SizeOfImage;
  if (dwMemSize = 0) then
  begin
    VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  pAll := VirtualAlloc(nil,dwMemSize+dwLen,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pAll = nil) then
  begin
    VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  dwSecCount := INH^.FileHeader.NumberOfSections;
  CopyMemory(pAll,IDH,DWord(SEC)-DWord(IDH)+dwSecCount*SizeOf(TImageSectionHeader));
  CopyMemory(Pointer(DWord(pAll) +  dwMemSize),pReserved,dwLen-1);
  for i := 0 to dwSecCount-1 do
  begin
    CopyMemory(Pointer(DWord(pAll)+SEC^.VirtualAddress),
      Pointer(DWord(pFileMem)+DWord(SEC^.PointerToRawData)),
      SEC^.SizeOfRawData);
    SEC := Pointer(Integer(SEC)+SizeOf(TImageSectionHeader));
  end;

  if (INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress <> 0) then
  ChangeReloc(Pointer(INH^.OptionalHeader.ImageBase),
              pAll,
              Pointer(DWord(pAll)+INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress),
              pAll,
              INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size);
  CreateImportTable(pAll, Pointer(DWord(pAll)+INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress));

  @DllMain := Pointer(INH^.OptionalHeader.AddressOfEntryPoint+DWord(pAll));
  if (INH^.OptionalHeader.AddressOfEntryPoint <> 0) and (bDllMain) then
  begin
    try
      if (pReserved <> nil) then
        DllMain(DWord(pAll),DLL_PROCESS_ATTACH,DWord(pAll)+dwMemSize) else
        DllMain(DWord(pAll),DLL_PROCESS_ATTACH,0);
    except
    end;
  end;
  Result := DWord(pAll);

  VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
  CloseHandle(iFileHandle);
end;

end.
