Unit OSysOSInfo;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// System and Platform Information Submodule
//
// This unit retreives information about the operating system
//
// *****************************************************************************
// To Do:
//
// *****************************************************************************
// News:
//
// *****************************************************************************
// Bugs:
//
// *****************************************************************************
// Info:
//  A huge part of this unit is based directly or indirectly on the old
//  OIncProcs.pas, rev 1.94 as well as many additions by foreign code.
//  A partial list of ressources is the following:
//    - http://www.delphi-forum.de/viewtopic.php?p=342714#342714
//    - http://www.delphipraxis.net/post326888.html#326888
//    - http://www.delphipraxis.net/post489223.html#489223
//    - http://www.winhistory.de
//    - ms-help://MS.PSDK.1033/sysinfo/base/getting_the_system_version.htm
//    - ms-help://MS.MSSDK.1033/MS.WinSDK.1033/sysinfo/base/getting_the_system_version.htm
//  Further sources might be named if you feel that they are missing in the
//  current listing. If this is the case, simply contact the Omorphia team.
//
//  Please note that the original OIncProcs routine was built on information
//  contained in the Platform SDK, August 2004 and therefore intersect in huge
//  parts with the source found in the Delphi Praxis Forums, although completely
//  written without knowledge of this translation.
//
//  The latest version available in the Delphi Praxis forums can be found here
//  renamed as GetWinBetaVerStrEx with slightly modified structure.
//
// *****************************************************************************

// Include the Compiler Version and Options Settings
{$I 'Omorphia.config.inc'}

Interface

Uses
    OIncTypes;

{
Here is a broad overview of the different releases and build numbers for the
various Windows Versions which gives no warranty for completeness.

// New Versions Check Info "GetVersionEx"
Major   Minor   Build   Name
3       51      ?       NT 3.5
4       0       950     95
4       0       1111    95 SR2
4       0       1381    NT 4.0
4       0       ?       95 SR2.5
4       10      1525    97 / 98 (Beta 1) Memphis
4       10      1998    98
4       10      2120    98 SP1 (Beta 1)
4       10      2222    98 SE
4       90      2380    ME (Beta 1)
4       90      2419    ME (Beta 2)
4       90      2452    ME (Beta 2 refresh)
4       90      2499    ME (Beta 3)
4       90      2525    ME (RC0, RC1)
4       90      2535    ME (RC2)
4       90      3000    ME (Gold)
5       0       2031    2000 (Beta 3)
5       0       2128    2000 (RC2)
5       0       2183    2000 (RC3)
5       0       2195    2000 Professional
5       1       2200    Whristler
5       1       2223    Whristler
5       1       2250    Whristler
5       1       2600    XP Professinal

4       ?       ?       NT
5       0       ?       2000
5       1       ?       XP
5       2       ?       Server 2003
5       5       ?       LH
}

// *****************************************************************************
// Name          : IsWinNT
// Parameter     : keine
// Resulttype    : Boolean
// Beschreibung  : Gibt TRUE zurück wenn ein NT System
// *****************************************************************************
Function IsWinNT: Boolean;

//Determines the broad version of Windows ...
// *****************************************************************************
// Name          : GetWinVer
// Parameter     : keine
// Resulttype    : TWinVersion
// Beschreibung  : Gibt die Windows Version zurück
// *****************************************************************************
Function GetWinVer: TWinVersion;
Function GetWinVerStr: String;

//Gives a detailed version string WITHOUT caring about betas ;-)
// *****************************************************************************
// Name          : GetWinVerStrEx
// Parameter     : keine
// Resulttype    : String
// Beschreibung  : Gibt die Windows Version als String zurück
// *****************************************************************************
Function GetWinVerEx: TWinVersionEx;
Function GetWinVerStrEx: String;

//Give very detailed version information including (hopefully) all betas ;-)
//function GetWinBetaVerEx: String;
Function GetWinBetaVerStrEx: String;

Function GetWinProductID: String;

Implementation

Uses
    Windows,
    SysUtils,
    ODbgInterface,
    OIncConsts;

Type
    POSVersionInfoA = ^TOSVersionInfoA;
    POSVersionInfoW = ^TOSVersionInfoW;
    POSVersionInfo = POSVersionInfoA;
    _OSVERSIONINFOA = Record
        dwOSVersionInfoSize: DWORD;
        dwMajorVersion: DWORD;
        dwMinorVersion: DWORD;
        dwBuildNumber: DWORD;
        dwPlatformId: DWORD;
        szCSDVersion: Array[0..127] Of AnsiChar;                                { Maintenance string for PSS usage }
        wServicePackMajor,
            wServicePackMinor,
            wSuiteMask: Word;
        wProductType,
            wReserved: Byte;
    End;
    {$EXTERNALSYM _OSVERSIONINFOA}
    _OSVERSIONINFOW = Record
        dwOSVersionInfoSize: DWORD;
        dwMajorVersion: DWORD;
        dwMinorVersion: DWORD;
        dwBuildNumber: DWORD;
        dwPlatformId: DWORD;
        szCSDVersion: Array[0..127] Of WideChar;                                { Maintenance string for PSS usage }
        wServicePackMajor,
            wServicePackMinor,
            wSuiteMask: Word;
        wProductType,
            wReserved: Byte;
    End;
    {$EXTERNALSYM _OSVERSIONINFOW}
    _OSVERSIONINFO = _OSVERSIONINFOA;
    TOSVersionInfoA = _OSVERSIONINFOA;
    TOSVersionInfoW = _OSVERSIONINFOW;
    TOSVersionInfo = TOSVersionInfoA;
    OSVERSIONINFOA = _OSVERSIONINFOA;
    {$EXTERNALSYM OSVERSIONINFOA}
    {$EXTERNALSYM OSVERSIONINFO}
    OSVERSIONINFOW = _OSVERSIONINFOW;
    {$EXTERNALSYM OSVERSIONINFOW}
    {$EXTERNALSYM OSVERSIONINFO}
    OSVersionInfo = OSVERSIONINFOA;

Const
    {$EXTERNALSYM VERSIONINFOSIZEA}
    VERSIONINFOSIZEA = SizeOf(TOSVersionInfoA) - (SizeOf(Word) * 3) - (SizeOf(Byte) * 2);
    {$EXTERNALSYM VERSIONINFOSIZEW}
    VERSIONINFOSIZEW = SizeOf(TOSVersionInfoW) - (SizeOf(Word) * 3) - (SizeOf(Byte) * 2);
    {$EXTERNALSYM VERSIONINFOSIZE}
    VERSIONINFOSIZE = VERSIONINFOSIZEA;

    //
    // RtlVerifyVersionInfo() os product type values
    //
    VER_NT_WORKSTATION = $00000001;
    VER_NT_DOMAIN_CONTROLLER = $00000002;
    VER_NT_SERVER = $00000003;

    VER_SERVER_NT = $80000000;
    VER_WORKSTATION_NT = $40000000;
    VER_SUITE_SMALLBUSINESS = $00000001;
    VER_SUITE_ENTERPRISE = $00000002;
    VER_SUITE_BACKOFFICE = $00000004;
    VER_SUITE_COMMUNICATIONS = $00000008;
    VER_SUITE_TERMINAL = $00000010;
    VER_SUITE_SMALLBUSINESS_RESTRICTED = $00000020;
    VER_SUITE_EMBEDDEDNT = $00000040;
    VER_SUITE_DATACENTER = $00000080;
    VER_SUITE_SINGLEUSERTS = $00000100;
    VER_SUITE_PERSONAL = $00000200;
    VER_SUITE_BLADE = $00000400;
    VER_SUITE_EMBEDDED_RESTRICTED = $00000800;
    VER_SUITE_SECURITY_APPLIANCE = $00001000;

    SM_SERVERR2 = 89;                                                           // Windows Server 2003 R2
    SM_STARTER = 88;                                                            // Starter Edition von Windows XP
    SM_MEDIACENTER = 87;                                                        // Windows XP media Center Edition
    SM_TABLETPC = 86;                                                           // Windows XP Tablet PC Edition

    PROCESSOR_ARCHITECTURE_INTEL = 0;
    PROCESSOR_ARCHITECTURE_MIPS = 1;
    PROCESSOR_ARCHITECTURE_ALPHA = 2;
    PROCESSOR_ARCHITECTURE_PPC = 3;
    PROCESSOR_ARCHITECTURE_SHX = 4;
    PROCESSOR_ARCHITECTURE_ARM = 5;
    PROCESSOR_ARCHITECTURE_IA64 = 6;
    PROCESSOR_ARCHITECTURE_ALPHA64 = 7;
    PROCESSOR_ARCHITECTURE_MSIL = 8;
    PROCESSOR_ARCHITECTURE_AMD64 = 9;
    PROCESSOR_ARCHITECTURE_IA32_ON_WIN64 = 10;

Function IsWinNT: Boolean;
Begin
    Result := Win32Platform = VER_PLATFORM_WIN32_NT;
End;

Function GetWinVer: TWinVersion;
Begin
    Result := wvUnknown;
    Case Win32Platform Of
        VER_PLATFORM_WIN32_WINDOWS:
            Begin
                Case Win32MajorVersion Of
                    4:
                        Begin
                            Case Win32MinorVersion Of
                                0: Result := wvWin95;
                                10: Result := wvWin98;
                                90: Result := wvWinME;
                            End;
                        End;
                End;
            End;
        VER_PLATFORM_WIN32_NT:
            Begin
                Case Win32MajorVersion Of
                    3:
                        Begin
                            If Win32MinorVersion = 51 Then
                                Result := wvWinNT351;
                        End;
                    4:
                        Begin
                            If Win32MinorVersion = 0 Then
                                Result := wvWinNT4;
                        End;
                    5:
                        Begin
                            Case Win32MinorVersion Of
                                0: Result := wvWin2000;
                                1: Result := wvWinXP;
                                2: Result := wvWin2003;
                            End;
                        End;
                    6:
                        Begin
                            Case Win32MinorVersion Of
                                0: Result := wvWinLH;
                            End;
                        End;
                End;
            End;
        VER_PLATFORM_WIN32s:
            Result := wvWin32s;
    End;
End;

Function GetWinVerStr: String;
Begin
    Result := WinVerNames[GetWinVer];
End;

Function GetWinVerStrEx: String;
Var
    osvi: TOSVersionInfo;

    RegKey: HKEY;
    BufSize: Integer;
    Buf: Array Of Char;
    RegRet: DWORD;
Begin
    Result := 'Unknown Windows Version';

    DbgResetOSError;

    ZeroMemory(@osvi, SizeOf(osvi));
    osvi.dwOSVersionInfoSize := SizeOf(osvi);

    If Not GetVersionEx(Windows.POSVersionInfo(@osvi)^) Then
    Begin
        osvi.dwOSVersionInfoSize := VERSIONINFOSIZE;

        If Not GetVersionEx(Windows.POSVersionInfo(@osvi)^) Then
        Begin
            DbgLastOSError(False);
            Exit;
        End;
    End;

    Case osvi.dwPlatformId Of
        VER_PLATFORM_WIN32_WINDOWS:
            Begin
                If osvi.dwMajorVersion = 4 Then
                    Case osvi.dwMinorVersion Of
                        0:
                            Begin
                                Result := 'Microsoft Windows 95';
                                If osvi.szCSDVersion[0] In ['B', 'C'] Then
                                    Result := Result + ' OSR2';
                            End;
                        10:
                            Begin
                                Result := 'Microsoft Windows 98';
                                If osvi.szCSDVersion[0] = 'A' Then
                                    Result := Result + ' Second Edition';
                            End;
                        90:
                            Begin
                                Result := 'Microsoft Windows Millennium Edition';
                            End;
                    End;
            End;
        VER_PLATFORM_WIN32_NT:
            Begin
                Case osvi.dwMajorVersion Of
                    3, 4:
                        Begin
                            Result := 'Microsoft Windows NT';
                        End;
                    5:
                        Begin
                            Case osvi.dwMinorVersion Of
                                0:
                                    Begin
                                        Result := 'Microsoft Windows 2000';
                                    End;
                                1:
                                    Begin
                                        Result := 'Microsoft Windows XP';
                                    End;
                                2:
                                    Begin
                                        Result := 'Microsoft Windows Server 2003';
                                    End;
                            End;
                        End;
                    6:
                        Begin
                            Result := 'Microsoft Windows Longhorn';
                            OmorphiaDebugStr(vl_Warning, 'OIncProcs.WindowsVersionStrEx',
                                'Version String information for WinLH not confirmed!');
                        End;
                End;

                If osvi.dwOSVersionInfoSize = SizeOf(osvi) Then
                Begin
                    //Test for specific Product on WinNT4.0 SP6 and above

                    Case osvi.wProductType Of
                        VER_NT_WORKSTATION:
                            Begin
                                If osvi.dwMajorVersion = 4 Then
                                    Result := Result + ' Workstation 4.0'
                                Else If osvi.wSuiteMask And VER_SUITE_PERSONAL <> 0 Then
                                    Result := Result + ' Home Edition'
                                Else
                                    Result := Result + ' Professional';
                            End;
                        VER_NT_SERVER, VER_NT_DOMAIN_CONTROLLER:
                            Begin
                                If osvi.dwMajorVersion = 5 Then
                                Begin
                                    Case osvi.dwMinorVersion Of
                                        0:                                      //Windows 2000
                                            Begin
                                                If osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0 Then
                                                    Result := Result + ' Datacenter Server'
                                                Else If osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0 Then
                                                    Result := Result + ' Advanced Server'
                                                Else
                                                    Result := Result + ' Server';
                                            End;
                                        2:                                      //Windows Server 2003
                                            Begin
                                                If osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0 Then
                                                    Result := Result + ' Datacenter Edition'
                                                Else If osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0 Then
                                                    Result := Result + ' Enterprise Edition'
                                                Else If osvi.wSuiteMask = VER_SUITE_BLADE Then
                                                    Result := Result + ' Web Edition'
                                                Else
                                                    Result := Result + ' Standard Edition';
                                            End;
                                    End;
                                End
                                Else                                            // Windows NT 4.0
                                Begin
                                    If osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0 Then
                                        Result := Result + ' Server 4.0, Enterprise Edition'
                                    Else
                                        Result := Result + ' Server 4.0';
                                End;
                            End;
                    End;
                End
                Else
                Begin
                    //Test for specific Product on WinNT4.0 SP5 and below

                    RegRet := RegOpenKeyEx(HKEY_LOCAL_MACHINE,
                        'SYSTEM\CurrentControlSet\Control\ProductOptions', 0,
                        KEY_QUERY_VALUE,
                        RegKey);
                    If RegRet <> ERROR_SUCCESS Then
                    Begin
                        DbgLastOSError(False);
                        Exit;
                    End;
                    Try
                        BufSize := StdBufferSize;
                        SetLength(Buf, BufSize);
                        // Msg -oNeo : Muste das hier fixen, hoffe das ist so koreckt!
                        RegRet := RegQueryValueEx(RegKey, 'ProductType', Nil, Nil, @Byte(Buf[0]), @Cardinal(BufSize));

                        If BufSize > Length(Buf) Then
                        Begin
                            SetLength(Buf, BufSize + 1);
                            BufSize := Length(Buf);
                            // Msg -oNeo : Muste das hier fixen, hoffe das ist so koreckt!
                            RegRet := RegQueryValueEx(RegKey, 'ProductType', Nil, Nil, @Byte(Buf[0]), @Cardinal(BufSize));
                        End;

                        If (RegRet <> ERROR_SUCCESS) Or (BufSize > Length(Buf)) Then
                        Begin
                            DbgLastOSError(False);
                            Exit;
                        End;
                    Finally
                        RegCloseKey(RegKey);
                    End;

                    If UpperCase(String(Buf)) = 'WINNT' Then
                        Result := Result + ' Workstation';
                    If UpperCase(String(Buf)) = 'LANMANNT' Then
                        Result := Result + ' Server';
                    If UpperCase(String(Buf)) = 'SERVERNT' Then
                        Result := Result + ' Advanced Server';

                    Result := Format('%s %d.%d', [Result, osvi.dwMajorVersion,
                        osvi.dwMinorVersion]);
                End;

                // Display service pack (if any) and build number.

                // Test for SP6 versus SP6a.
                If (osvi.dwMajorVersion = 4) And (osvi.szCSDVersion = 'Service Pack 6') And (RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Hotfix\Q246009', 0, KEY_QUERY_VALUE, RegKey) = ERROR_SUCCESS) Then
                Begin
                    RegCloseKey(RegKey);
                    Result := Format('%s %sa (Build %d)', [Result, osvi.szCSDVersion, osvi.dwBuildNumber And $FFFF]);
                End
                Else                                                            // not Windows NT 4.0
                Begin
                    Result := Format('%s %s (Build %d)', [Result, osvi.szCSDVersion, osvi.dwBuildNumber And $FFFF]);
                End;
            End;
        VER_PLATFORM_WIN32s:
            Result := 'Microsoft Win32s';
    End;

    DbgResetOSError;
End;

Function GetWinVerEx: TWinVersionEx;
Var
    osvi: TOSVersionInfo;

    RegKey: HKEY;
    BufSize: Integer;
    Buf: Array Of Char;
    RegRet: DWORD;
Begin
    // Initialize the result record
    Result.OSType := wvUnknown;
    Result.OSName := '(unknwon)';
    Result.OSVerBroad := '(unknwon)';
    Result.OSVerPrecise := '(unknown)';
    Result.OSSuite := '(unknwon)';
    Result.OSPatchLevel := '(unknwon)';
    Result.OSBuild := '(unknwon)';

    DbgResetOSError;

    ZeroMemory(@osvi, SizeOf(osvi));
    osvi.dwOSVersionInfoSize := SizeOf(osvi);

    If Not GetVersionEx(Windows.POSVersionInfo(@osvi)^) Then
    Begin
        osvi.dwOSVersionInfoSize := VERSIONINFOSIZE;

        If Not GetVersionEx(Windows.POSVersionInfo(@osvi)^) Then
        Begin
            DbgLastOSError(False);
            Exit;
        End;
    End;

    Result.OSName := 'Microsoft Windows';
    Result.OSBuild := 'Build ' + IntToStr(osvi.dwBuildNumber);

    Case osvi.dwPlatformId Of
        VER_PLATFORM_WIN32_WINDOWS:
            Begin
                If osvi.dwMajorVersion = 4 Then
                Begin
                    Case osvi.dwMinorVersion Of
                        0:
                            Begin
                                Result.OSType := wvWin95;
                                Result.OSVerBroad := '95';
                                Result.OSVerPrecise := '95';
                                Result.OSPatchLevel := 'First Edition';
                                If osvi.szCSDVersion[0] In ['B', 'C'] Then
                                Begin
                                    If osvi.szCSDVersion[0] = 'B' Then
                                        Result.OSPatchLevel := 'Second Edition'
                                    Else
                                        Result.OSPatchLevel := 'Third Edition';
                                    Result.OSVerPrecise := Result.OSVerPrecise + ' OSR2';
                                End;
                            End;
                        10:
                            Begin
                                Result.OSType := wvWin98;
                                Result.OSVerBroad := '98';
                                Result.OSVerPrecise := '98';
                                Result.OSPatchLevel := 'First Edition';
                                If osvi.szCSDVersion[0] = 'A' Then
                                Begin
                                    Result.OSVerPrecise := Result.OSVerPrecise + ' SE';
                                    Result.OSPatchLevel := 'Second Edition';
                                End;
                            End;
                        90:
                            Begin
                                Result.OSType := wvWinME;
                                Result.OSVerBroad := 'Me';
                                Result.OSVerPrecise := 'Millenium';
                                Result.OSPatchLevel := 'First Edition';
                            End;
                    End;
                End;
            End;
        VER_PLATFORM_WIN32_NT:
            Begin
                Case osvi.dwMajorVersion Of
                    3, 4:
                        Begin
                            If osvi.dwMajorVersion = 3 Then
                            Begin
                                Result.OSType := wvWinNT351;
                                Result.OSVerBroad := 'NT';
                                Result.OSVerPrecise := 'NT 3.51';
                            End
                            Else
                            Begin
                                Result.OSType := wvWinNT4;
                                Result.OSVerBroad := 'NT';
                                Result.OSVerPrecise := 'NT 4.0';
                            End
                        End;
                    5:
                        Begin
                            Case osvi.dwMinorVersion Of
                                0:
                                    Begin
                                        Result.OSType := wvWin2000;
                                        Result.OSVerBroad := '2000';
                                        Result.OSVerPrecise := '2000';
                                    End;
                                1:
                                    Begin
                                        Result.OSType := wvWinXP;
                                        Result.OSVerBroad := 'XP';
                                        Result.OSVerPrecise := 'XP';
                                    End;
                                2:
                                    Begin
                                        Result.OSType := wvWin2003;
                                        Result.OSVerBroad := 'Server 2003';
                                        Result.OSVerPrecise := 'Server 2003';
                                    End;
                            End;
                        End;
                    6:
                        Begin
                            Result.OSType := wvWinLH;
                            Result.OSVerBroad := 'Longhorn';
                            Result.OSVerPrecise := 'Longhorn';

                            OmorphiaDebugStr(vl_Warning, 'OIncProcs.WindowsVersionStrEx',
                                'Version String information for WinLH not confirmed!');
                        End;
                End;

                If osvi.dwOSVersionInfoSize = SizeOf(osvi) Then
                Begin
                    //Test for specific Product on WinNT4.0 SP6 and above

                    Case osvi.wProductType Of
                        VER_NT_WORKSTATION:
                            Begin
                                If osvi.dwMajorVersion = 4 Then
                                Begin
                                    Result.OSVerPrecise := Result.OSVerPrecise + ' Workstation';
                                    Result.OSSuite := 'Workstation';
                                End
                                Else If osvi.wSuiteMask And VER_SUITE_PERSONAL <> 0 Then
                                    Result.OSSuite := 'Home Edition'
                                Else
                                    Result.OSSuite := 'Professional';
                            End;
                        VER_NT_SERVER, VER_NT_DOMAIN_CONTROLLER:
                            Begin
                                If osvi.dwMajorVersion = 5 Then
                                Begin
                                    Case osvi.dwMinorVersion Of
                                        0:                                      //Windows 2000
                                            Begin
                                                If osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0 Then
                                                    Result.OSSuite := 'Datacenter Server'
                                                Else If osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0 Then
                                                    Result.OSSuite := 'Advanced Server'
                                                Else
                                                    Result.OSSuite := 'Server';
                                            End;
                                        2:                                      //Windows Server 2003
                                            Begin
                                                If osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0 Then
                                                    Result.OSSuite := 'Datacenter Edition'
                                                Else If osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0 Then
                                                    Result.OSSuite := 'Enterprise Edition'
                                                Else If osvi.wSuiteMask = VER_SUITE_BLADE Then
                                                    Result.OSSuite := 'Web Edition'
                                                Else
                                                    Result.OSSuite := 'Standard Edition';
                                            End;
                                    End;
                                End
                                Else                                            // Windows NT 4.0
                                Begin
                                    Result.OSVerPrecise := Result.OSVerPrecise + ' Server';
                                    If osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0 Then
                                        Result.OSSuite := 'Enterprise Edition'
                                    Else
                                        Result.OSSuite := 'Standard Edition';
                                End;
                            End;
                    End;
                End
                Else
                Begin
                    //Test for specific Product on WinNT4.0 SP5 and below

                    RegRet := RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\ProductOptions', 0, KEY_QUERY_VALUE, RegKey);
                    If RegRet <> ERROR_SUCCESS Then
                    Begin
                        DbgLastOSError(False);
                        Exit;
                    End;
                    Try
                        BufSize := StdBufferSize;
                        SetLength(Buf, BufSize);
                        // Msg -oNeo : Muste das hier fixen, hoffe das ist so koreckt!
                        RegRet := RegQueryValueEx(RegKey, 'ProductType', Nil, Nil, @Byte(Buf[0]), @Cardinal(BufSize));

                        If BufSize > Length(Buf) Then
                        Begin
                            SetLength(Buf, BufSize + 1);
                            BufSize := Length(Buf);
                            // Msg -oNeo : Muste das hier fixen, hoffe das ist so koreckt!
                            RegRet := RegQueryValueEx(RegKey, 'ProductType', Nil, Nil, @Byte(Buf[0]), @Cardinal(BufSize));
                        End;

                        If (RegRet <> ERROR_SUCCESS) Or (BufSize > Length(Buf)) Then
                        Begin
                            DbgLastOSError(False);
                            Exit;
                        End;
                    Finally
                        RegCloseKey(RegKey);
                    End;

                    If UpperCase(String(Buf)) = 'WINNT' Then
                        Result.OSSuite := 'Workstation';
                    If UpperCase(String(Buf)) = 'LANMANNT' Then
                        Result.OSSuite := 'Server';
                    If UpperCase(String(Buf)) = 'SERVERNT' Then
                        Result.OSSuite := 'Advanced Server';
                End;

                // Display service pack (if any) and build number.

                Result.OSPatchLevel := osvi.szCSDVersion;
                // Test for SP6 versus SP6a.
                If (osvi.dwMajorVersion = 4) And (osvi.szCSDVersion = 'Service Pack 6') And (RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Hotfix\Q246009', 0, KEY_QUERY_VALUE, RegKey) = ERROR_SUCCESS) Then
                Begin
                    RegCloseKey(RegKey);
                    Result.OSPatchLevel := Result.OSPatchLevel + 'a';
                End;
            End;
        VER_PLATFORM_WIN32s:
            Result.OSVerBroad := '3.11 32bit (emulation)';
    End;

    DbgResetOSError;
End;

Function GetNativeSystemInfoEx: SYSTEM_INFO;
Var
    DLLWnd: THandle;
    SI: SYSTEM_INFO;
    GetNSI: Procedure(Var LPSYSTEM_INFO: SYSTEM_INFO); stdcall;
Begin
    DLLWnd := LoadLibrary('kernel32');
    If DLLWnd > 0 Then
    Begin
        Try
            @GetNSI := GetProcAddress(DLLWnd, 'GetNativeSystemInfo');
            If @GetNSI <> Nil Then
            Begin
                GetNSI(SI);
                Result := SI;
            End;
        Finally
            FreeLibrary(DLLWnd);
        End;
    End;
End;

Function GetWinBetaVerStrEx: String;
Var
    osvi: TOSVersionInfo;
    bOsVersionInfoEx: Boolean;
    Key: HKEY;
    szProductType: Array[0..79] Of Char;
    dwBuflen: DWORD;
    SI: SYSTEM_INFO;
Begin
    // Try calling GetVersionEx using the OSVERSIONINFOEX structure.
    // If that fails, try using the OSVERSIONINFO structure.
    ZeroMemory(@osvi, SizeOf(TOSVersionInfo));
    osvi.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);

    bOsVersionInfoEx := GetVersionEx(Windows.POSVersionInfo(@osvi)^);
    If Not bOsVersionInfoEx Then
    Begin
        osvi.dwOSVersionInfoSize := VERSIONINFOSIZE;

        If Not GetVersionEx(Windows.POSVersionInfo(@osvi)^) Then
        Begin
            DbgLastOSError(False);
            Exit;
        End;
    End;

    //  GetSystemInfo(si);
    SI := GetNativeSystemInfoEx;                                                // Use this method to avoid load issues on Windows 2000

    Case osvi.dwPlatformId Of
        // Test for the Windows NT product family.
        VER_PLATFORM_WIN32_NT:
            Begin
                If (osvi.dwMajorVersion = 6) And (osvi.dwMinorVersion = 0) Then
                Begin
                    If osvi.wProductType = VER_NT_WORKSTATION Then
                    Begin
                        Case LoWord(osvi.dwBuildNumber) Of
                            3683, 3718:
                                Result := 'Microsoft Windows M3 (Codename: Longhorn) ';
                            4008:
                                Result := 'Microsoft Windows M4 (Codename: Longhorn) ';
                            4015, 4029:
                                Result := 'Microsoft Windows M5 (Codename: Longhorn) ';
                            4051, 4053:
                                Result := 'Microsoft Windows M6 (Codename: Longhorn) ';
                            4074:
                                Result := 'Microsoft Windows WinHEC (Codename: Longhorn) ';
                            5048:
                                Result := 'Microsoft Windows (Codename: Longhorn) ';
                        Else
                            Begin
                                Result := 'Microsoft Windows Vista ';
                                Case LoWord(osvi.dwBuildNumber) Of
                                    5112:
                                        Result := Result + ' Beta 1 (Codename: Longhorn) ';
                                End;
                            End;
                        End;
                    End
                    Else
                        Result := 'Microsoft Windows Server (Longhorn) ';
                End;
                // Test for the specific product family.
                If (osvi.dwMajorVersion = 5) And (osvi.dwMinorVersion = 2) Then
                Begin
                    If GetSystemMetrics(SM_SERVERR2) <> 0 Then
                        Result := 'Microsoft Windows Server 2003 R2 '
                    Else If (osvi.wProductType = VER_NT_WORKSTATION) And (SI.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) Then
                        Result := 'Microsoft Windows XP Professional x64 Edition ';
                End
                Else
                    Result := 'Microsoft Windows Server 2003, ';

                If (osvi.dwMajorVersion = 5) And (osvi.dwMinorVersion = 1) Then
                    Result := 'Microsoft Windows XP ';

                If (osvi.dwMajorVersion = 5) And (osvi.dwMinorVersion = 0) Then
                    Result := 'Microsoft Windows 2000 ';

                If (osvi.dwMajorVersion <= 4) Then
                    Result := 'Microsoft Windows NT ';

                // Test for specific product on Windows NT 4.0 SP6 and later.
                If bOsVersionInfoEx Then
                Begin
                    // Test for the workstation type.
                    If (osvi.wProductType = VER_NT_WORKSTATION) And (SI.wProcessorArchitecture <> PROCESSOR_ARCHITECTURE_AMD64) Then
                    Begin
                        If (osvi.dwMajorVersion = 4) Then
                            Result := Result + 'Workstation 4.0 '
                        Else If (osvi.wSuiteMask And VER_SUITE_PERSONAL <> 0) Then
                            Result := Result + 'Home Edition '
                        Else
                        Begin                                                   // Unterscheidung zw. MCE  und Prof.
                            If GetSystemMetrics(SM_MEDIACENTER) <> 0 Then
                                Result := Result + 'Media Center Edition '
                            Else If GetSystemMetrics(SM_TABLETPC) <> 0 Then
                                Result := Result + 'Tablet PC Edition '
                            Else If GetSystemMetrics(SM_STARTER) <> 0 Then
                                Result := Result + 'Starter Edition '
                            Else
                                Result := Result + 'Professional ';
                        End;
                    End
                        // Test for the server type.
                    Else If (osvi.wProductType = VER_NT_SERVER) Or (osvi.wProductType = VER_NT_DOMAIN_CONTROLLER) Then
                    Begin
                        If (osvi.dwMajorVersion = 5) And (osvi.dwMinorVersion = 2) Then
                        Begin
                            If (SI.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64) Then // Win2003 Itanium
                            Begin
                                If (osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0) Then
                                    Result := Result + 'Datacenter Edition for Itanium-based Systems '
                                Else If (osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0) Then
                                    Result := Result + 'Enterprise Edition for Itanium-based Systems '
                                Else
                                    Result := Result + 'Standard Edition for Itanium-based Systems '
                            End
                            Else If (SI.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) Then // Win2003 x86-64
                            Begin
                                If (osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0) Then
                                    Result := Result + 'Datacenter x64 Edition '
                                Else If (osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0) Then
                                    Result := Result + 'Enterprise x64 Edition '
                                Else
                                    Result := Result + 'Standard x64 Edition'
                            End
                            Else
                            Begin                                               // Win 2003 x86
                                If (osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0) Then
                                    Result := Result + 'Datacenter Edition '
                                Else If (osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0) Then
                                    Result := Result + 'Enterprise Edition '
                                Else If (osvi.wSuiteMask = VER_SUITE_BLADE) Then
                                    Result := Result + 'Web Edition '
                                Else
                                    Result := Result + 'Standard Edition ';
                            End;
                        End                                                     // Win 2000
                        Else If (osvi.dwMajorVersion = 5) And (osvi.dwMinorVersion = 0) Then
                        Begin
                            If (osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0) Then
                                Result := Result + 'Datacenter Server '
                            Else If (osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0) Then
                                Result := Result + 'Advanced Server '
                            Else
                                Result := Result + 'Server ';

                            Case LoWord(osvi.dwBuildNumber) Of
                                1671:
                                    Result := Result + ' Beta 1 (Codename: NT 5.0) ';
                                1877:
                                    Result := Result + ' Beta 2 (Codename: NT 5.0) ';
                                2031:
                                    Result := Result + ' Beta 3 (Codename: NT 5.0) ';
                                2072:
                                    Result := Result + ' Beta für DEC-Alpha-Prozessoren (Codename: NT 5.0) ';
                                5111:
                                    Result := Result + ' (Codename: Neptune) ';
                            End;
                        End
                        Else
                        Begin                                                   // Windows NT 4.0
                            If (osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0) Then
                                Result := Result + 'Server 4.0, Enterprise Edition '
                            Else
                                Result := Result + 'Server 4.0 ';
                        End;
                    End
                End
                    // Test for specific product on Windows NT 4.0 SP5 and earlier
                Else
                Begin
                    dwBuflen := SizeOf(szProductType);

                    If (RegOpenKeyEx(HKEY_LOCAL_MACHINE,
                        'SYSTEM\CurrentControlSet\Control\ProductOptions', 0,
                        KEY_QUERY_VALUE, Key) = ERROR_SUCCESS) Then
                    Try
                        ZeroMemory(@szProductType, SizeOf(szProductType));

                        If (RegQueryValueEx(Key, 'ProductType', Nil, Nil,
                            @szProductType, @dwBuflen) <> ERROR_SUCCESS) Or
                            (dwBuflen > SizeOf(szProductType)) Then
                            ZeroMemory(@szProductType, SizeOf(szProductType));
                    Finally
                        RegCloseKey(Key);
                    End;

                    If (lstrcmpi('WINNT', szProductType) = 0) Then
                        Result := Result + 'Workstation ';
                    If (lstrcmpi('LANMANNT', szProductType) = 0) Then
                        Result := Result + 'Server ';
                    If (lstrcmpi('SERVERNT', szProductType) = 0) Then
                        Result := Result + 'Advanced Server ';

                    Result := Format('%s%d.%d', [Result, osvi.dwMajorVersion,
                        osvi.dwMinorVersion]);
                End;

                // Display service pack (if any) and build number.
                If (osvi.dwMajorVersion = 4) And
                    (lstrcmpi(osvi.szCSDVersion, 'Service Pack 6') = 0) Then
                Begin
                    // Test for SP6 versus SP6a.
                    If (RegOpenKeyEx(HKEY_LOCAL_MACHINE,
                        'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Hotfix\Q246009',
                        0, KEY_QUERY_VALUE, Key) = ERROR_SUCCESS) Then

                        Result := Format('%sService Pack 6a (Build %d)', [Result,
                            osvi.dwBuildNumber And $FFFF])
                    Else
                        // Windows NT 4.0 prior to SP6a
                        Result := Format('%s%s (Build %d)', [Result,
                            osvi.szCSDVersion, osvi.dwBuildNumber And $FFFF]);
                    RegCloseKey(Key);
                End
                    // Windows NT 3.51 and earlier or Windows 2000 and later
                Else
                Begin
                    Result := Format('%s%s (Build %d)', [Result,
                        osvi.szCSDVersion, osvi.dwBuildNumber And $FFFF]);
                End;
            End;
        // Test for the Windows 95 product family.
        VER_PLATFORM_WIN32_WINDOWS:
            Begin
                If (osvi.dwMajorVersion = 4) And (osvi.dwMinorVersion = 0) Then
                Begin
                    Result := 'Microsoft Windows 95';
                    Case LoWord(osvi.dwBuildNumber) Of
                        122:
                            Result := Result + ' Beta (Codename: Chicago) ';
                        189:
                            Result := Result + ' Beta 2 (Codename: Chicago) Sept. 1994 ';
                        347:
                            Result := Result + ' Beta 3 (Codename: Chicago) März 1995 ';
                        480:
                            Result := Result + ' Beta 4 (Codename: Chicago) Mai 1995 ';
                        950:
                            If (osvi.szCSDVersion[0] = 'A') Then
                                Result := Result + ' OSR1 ';
                        999:
                            Result := Result + 'B Beta (Codename: Nashville) ';
                        1111:
                            Result := Result + 'B OSR2 ';
                        1212, 1213:
                            Result := Result + 'B OSR2.1 ';
                        1214:
                            Result := Result + 'C OSR2.5 ';
                    End;
                End;

                If (osvi.dwMajorVersion = 4) And (osvi.dwMinorVersion = 10) Then
                Begin
                    Result := 'Microsoft Windows 98 ';
                    If (osvi.szCSDVersion[0] = 'A') Then
                        Result := Result + 'SE ';
                    Case LoWord(osvi.dwBuildNumber) Of
                        1387:
                            Result := Result + ' Developer Release (Codename: Memphis) ';
                        1488:
                            Result := Result + ' Beta 1 (Codename: Memphis) ';
                        1629:
                            Result := Result + ' Beta 3 (Codename: Memphis) ';
                    End;
                End;

                If (osvi.dwMajorVersion = 4) And (osvi.dwMinorVersion = 90) Then
                Begin
                    Result := 'Microsoft Windows Millennium Edition';
                    Case LoWord(osvi.dwBuildNumber) Of
                        2380:
                            Result := Result + ' Beta 1 (Codename: Georgia) ';
                    End;
                End;
            End;
        VER_PLATFORM_WIN32s:
            Result := 'Microsoft Win32s';
    End;
End;

Function GetWinBetaVerEx: TWinVersionEx;
Var
    osvi: TOSVersionInfo;
    bOsVersionInfoEx: Boolean;
    Key: HKEY;
    szProductType: Array[0..79] Of Char;
    dwBuflen: DWORD;
    SI: SYSTEM_INFO;
Begin
    // Initialize the result record
    Result.OSType := wvUnknown;
    Result.OSName := '(unknwon)';
    Result.OSVerBroad := '(unknwon)';
    Result.OSVerPrecise := '(unknown)';
    Result.OSSuite := '(unknwon)';
    Result.OSPatchLevel := '(unknwon)';
    Result.OSBuild := '(unknwon)';

    // Try calling GetVersionEx using the OSVERSIONINFOEX structure.
    // If that fails, try using the OSVERSIONINFO structure.
    ZeroMemory(@osvi, SizeOf(TOSVersionInfo));
    osvi.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);

    bOsVersionInfoEx := GetVersionEx(Windows.POSVersionInfo(@osvi)^);
    If Not bOsVersionInfoEx Then
    Begin
        osvi.dwOSVersionInfoSize := VERSIONINFOSIZE;

        If Not GetVersionEx(Windows.POSVersionInfo(@osvi)^) Then
        Begin
            DbgLastOSError(False);
            Exit;
        End;
    End;

    Result.OSName := 'Microsoft Windows';
    Result.OSBuild := 'Build ' + IntToStr(osvi.dwBuildNumber);

    //  GetSystemInfo(si);
    SI := GetNativeSystemInfoEx;                                                // Use this method to avoid load issues on Windows 2000

    Case osvi.dwPlatformId Of
        VER_PLATFORM_WIN32_NT:                                                  // Test for the Windows NT product family.
            Begin
                Case osvi.dwMajorVersion Of
                    3:
                        Begin
                            Result.OSType := wvWinNT351;
                            Result.OSVerBroad := 'NT 3.51';
                            Result.OSVerPrecise := 'NT 3.51';
                        End;
                    4:
                        Begin
                            Result.OSType := wvWinNT4;
                            Result.OSVerBroad := 'NT 4.0';
                            Result.OSVerPrecise := 'NT 4.0';
                            Result.OSSuite := 'Workstation';
                            If (osvi.wProductType = VER_NT_SERVER) Or (osvi.wProductType = VER_NT_DOMAIN_CONTROLLER) Then
                            Begin
                                If (osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0) Then
                                    Result.OSSuite := 'Enterprise Edition'
                                Else
                                    Result.OSSuite := 'Standard Edition';
                            End;

                            dwBuflen := SizeOf(szProductType);

                            If (RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\ProductOptions', 0, KEY_QUERY_VALUE, Key) = ERROR_SUCCESS) Then
                            Begin
                                Try
                                    ZeroMemory(@szProductType, SizeOf(szProductType));

                                    If (RegQueryValueEx(Key, 'ProductType', Nil, Nil,
                                        @szProductType, @dwBuflen) <> ERROR_SUCCESS) Or
                                        (dwBuflen > SizeOf(szProductType)) Then
                                        ZeroMemory(@szProductType, SizeOf(szProductType));
                                Finally
                                    RegCloseKey(Key);
                                End;
                            End;

                            If (lstrcmpi('WINNT', szProductType) = 0) Then
                                Result.OSSuite := 'Workstation';
                            If (lstrcmpi('LANMANNT', szProductType) = 0) Then
                                Result.OSSuite := 'Server';
                            If (lstrcmpi('SERVERNT', szProductType) = 0) Then
                                Result.OSSuite := 'Advanced Server';

                            // Display service pack (if any) and build number.
                            If lstrcmpi(osvi.szCSDVersion, 'Service Pack 6') = 0 Then
                            Begin
                                // Test for SP6 versus SP6a.
                                If (RegOpenKeyEx(HKEY_LOCAL_MACHINE,
                                    'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Hotfix\Q246009',
                                    0, KEY_QUERY_VALUE, Key) = ERROR_SUCCESS) Then

                                    Result.OSPatchLevel := 'Service Pack 6a'
                                Else
                                    Result.OSPatchLevel := osvi.szCSDVersion;
                                RegCloseKey(Key);
                            End;
                        End;
                    5:
                        Begin
                            // Test for the workstation type.
                            If bOsVersionInfoEx And (osvi.wProductType = VER_NT_WORKSTATION) And (SI.wProcessorArchitecture <> PROCESSOR_ARCHITECTURE_AMD64) Then
                            Begin
                                If (osvi.wSuiteMask And VER_SUITE_PERSONAL <> 0) Then
                                Begin
                                    Result.OSSuite := 'Home Edition';
                                End
                                Else
                                Begin                                           // Unterscheidung zw. MCE  und Prof.
                                    If GetSystemMetrics(SM_MEDIACENTER) <> 0 Then
                                        Result.OSSuite := 'Media Center Edition '
                                    Else If GetSystemMetrics(SM_TABLETPC) <> 0 Then
                                        Result.OSSuite := 'Tablet PC Edition '
                                    Else If GetSystemMetrics(SM_STARTER) <> 0 Then
                                        Result.OSSuite := 'Starter Edition '
                                    Else
                                        Result.OSSuite := 'Professional ';
                                End;
                            End;

                            Case osvi.dwMinorVersion Of
                                0:
                                    Begin
                                        Result.OSType := wvWin2000;
                                        Result.OSVerBroad := '2000';
                                        Result.OSVerPrecise := '2000';

                                        Case LoWord(osvi.dwBuildNumber) Of
                                            1671:
                                                Result.OSVerPrecise := 'NT 5.0 Beta 1 (2000)';
                                            1877:
                                                Result.OSVerPrecise := 'NT 5.0 Beta 2 (2000)';
                                            2031:
                                                Result.OSVerPrecise := 'NT 5.0 Beta 3 (2000)';
                                            2072:
                                                Result.OSVerPrecise := 'NT 5.0 Beta for DEC-Alpha-Prozessoren (2000)';
                                            5111:
                                                Result.OSVerPrecise := 'Neptune (2000)';
                                        End;

                                        If (osvi.wProductType = VER_NT_SERVER) Or (osvi.wProductType = VER_NT_DOMAIN_CONTROLLER) Then
                                        Begin
                                            If (osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0) Then
                                                Result.OSSuite := 'Datacenter Server '
                                            Else If (osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0) Then
                                                Result.OSSuite := 'Advanced Server '
                                            Else
                                                Result.OSSuite := 'Server ';
                                        End;
                                    End;
                                1:
                                    Begin
                                        Result.OSType := wvWinXP;
                                        Result.OSVerBroad := 'XP';
                                        Result.OSVerPrecise := 'XP';
                                    End;
                                2:
                                    Begin
                                        // Test for the specific product family.
                                        Result.OSType := wvWin2003;
                                        Result.OSVerBroad := 'Server 2003';
                                        Result.OSVerPrecise := 'Server 2003';
                                        If GetSystemMetrics(SM_SERVERR2) <> 0 Then
                                            Result.OSVerPrecise := 'Server 2003 R2'
                                        Else If bOsVersionInfoEx Then
                                        Begin
                                            If (osvi.wProductType = VER_NT_WORKSTATION) And (SI.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) Then
                                            Begin
                                                Result.OSType := wvWinXP;
                                                Result.OSVerBroad := 'XP';
                                                Result.OSVerPrecise := 'XP';
                                                Result.OSSuite := 'Professional x64 Edition';
                                            End
                                            Else If (osvi.wProductType = VER_NT_SERVER) Or (osvi.wProductType = VER_NT_DOMAIN_CONTROLLER) Then
                                            Begin
                                                Case SI.wProcessorArchitecture Of
                                                    PROCESSOR_ARCHITECTURE_IA64: // Win2003 Itanium
                                                        Begin
                                                            If osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0 Then
                                                                Result.OSSuite := 'Datacenter Edition for Itanium-based Systems'
                                                            Else If osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0 Then
                                                                Result.OSSuite := 'Enterprise Edition for Itanium-based Systems'
                                                            Else
                                                                Result.OSSuite := 'Standard Edition for Itanium-based Systems';
                                                        End;
                                                    PROCESSOR_ARCHITECTURE_AMD64: // Win2003 x86-64
                                                        Begin
                                                            If osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0 Then
                                                                Result.OSSuite := 'Datacenter x64 Edition'
                                                            Else If osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0 Then
                                                                Result.OSSuite := 'Enterprise x64 Edition'
                                                            Else
                                                                Result.OSSuite := 'Standard x64 Edition';
                                                        End;
                                                Else                            // Win 2003 x86
                                                    If osvi.wSuiteMask And VER_SUITE_DATACENTER <> 0 Then
                                                        Result.OSSuite := 'Datacenter Edition'
                                                    Else If osvi.wSuiteMask And VER_SUITE_ENTERPRISE <> 0 Then
                                                        Result.OSSuite := 'Enterprise Edition'
                                                    Else If osvi.wSuiteMask = VER_SUITE_BLADE Then
                                                        Result.OSSuite := 'Web Edition'
                                                    Else
                                                        Result.OSSuite := 'Standard Edition';
                                                End;
                                            End;
                                        End;
                                    End;
                            End;
                        End;
                    6:
                        Begin
                            Case osvi.dwMinorVersion Of
                                0:
                                    Begin
                                        Result.OSType := wvWinLH;
                                        Result.OSVerBroad := 'Longhorn';
                                        Result.OSVerPrecise := 'Longhorn';
                                        If osvi.wProductType = VER_NT_WORKSTATION Then
                                        Begin
                                            Case LoWord(osvi.dwBuildNumber) Of
                                                3683, 3718:
                                                    Result.OSVerPrecise := 'Longhorn (M3)';
                                                4008:
                                                    Result.OSVerPrecise := 'Longhorn (M4)';
                                                4015, 4029:
                                                    Result.OSVerPrecise := 'Longhorn (M5)';
                                                4051, 4053:
                                                    Result.OSVerPrecise := 'Longhorn (M6)';
                                                4074:
                                                    Result.OSVerPrecise := 'Longhorn (WinHEC)';
                                                5048:
                                                    Result.OSVerPrecise := 'Longhorn';
                                                5112:
                                                    Begin
                                                        Result.OSType := wvWinVista;
                                                        Result.OSVerBroad := 'Vista';
                                                        Result.OSVerPrecise := 'Vista (Beta 1)';
                                                    End;
                                            Else
                                                Result.OSType := wvWinVista;
                                                Result.OSVerBroad := 'Vista';
                                                Result.OSVerPrecise := 'Vista';
                                            End;
                                        End
                                        Else
                                        Begin
                                            Result.OSType := wvWinLH;
                                            Result.OSVerBroad := 'Longhorn';
                                            Result.OSVerPrecise := 'Longhorn (Server)';
                                        End;
                                    End;
                            End;
                        End;
                End;

                // Display service pack (if any) and build number.
                // Windows NT 3.51 and earlier or Windows 2000 and later
                If (osvi.dwMajorVersion <> 4) Then
                    Result.OSPatchLevel := osvi.szCSDVersion;
            End;
        // Test for the Windows 95 product family.
        VER_PLATFORM_WIN32_WINDOWS:
            Begin
                Case osvi.dwMajorVersion Of
                    4:
                        Begin
                            Case osvi.dwMinorVersion Of
                                0:
                                    Begin
                                        Result.OSType := wvWin95;
                                        Result.OSVerBroad := '95';
                                        Result.OSVerPrecise := '95';
                                        Result.OSPatchLevel := 'First Edition';

                                        Case LoWord(osvi.dwBuildNumber) Of
                                            122:
                                                Result.OSVerPrecise := '95 Beta 1 (Chicago)';
                                            189:
                                                Result.OSVerPrecise := '95 Beta 2 (Chicago, Sept. 1994)';
                                            347:
                                                Result.OSVerPrecise := '95 Beta 3 (Chicago, März 1995)';
                                            480:
                                                Result.OSVerPrecise := '95 Beta 4 (Chicago, Mai 1995)';
                                            950:
                                                If (osvi.szCSDVersion[0] = 'A') Then
                                                    Result.OSVerPrecise := '95 OSR1';
                                            999:
                                                Begin
                                                    Result.OSVerPrecise := '95B Beta (Nashville)';
                                                    Result.OSPatchLevel := 'Second Edition';
                                                End;
                                            1111:
                                                Begin
                                                    Result.OSVerPrecise := '95B OSR2';
                                                    Result.OSPatchLevel := 'Second Edition';
                                                End;
                                            1212, 1213:
                                                Begin
                                                    Result.OSVerPrecise := '95B OSR2.1';
                                                    Result.OSPatchLevel := 'Second Edition';
                                                End;
                                            1214:
                                                Begin
                                                    Result.OSVerPrecise := '95C OSR2.5';
                                                    Result.OSPatchLevel := 'Third Edition';
                                                End;
                                        End;
                                    End;
                                10:
                                    Begin
                                        Result.OSType := wvWin98;
                                        Result.OSVerBroad := '98';
                                        Result.OSVerPrecise := '98';
                                        Result.OSPatchLevel := 'First Edition';

                                        If (osvi.szCSDVersion[0] = 'A') Then
                                            Result.OSPatchLevel := 'Second Edition';

                                        Case LoWord(osvi.dwBuildNumber) Of
                                            1387:
                                                Result.OSVerPrecise := 'Developer Release (Memphis)';
                                            1488:
                                                Result.OSVerPrecise := 'Beta 1 (Memphis)';
                                            1629:
                                                Result.OSVerPrecise := 'Beta 3 (Memphis)';
                                        End;
                                    End;
                                90:
                                    Begin
                                        Result.OSType := wvWinME;
                                        Result.OSVerBroad := 'Me';
                                        Result.OSVerPrecise := 'Me';

                                        Case LoWord(osvi.dwBuildNumber) Of
                                            2380:
                                                Result.OSVerPrecise := 'Beta 1 (Georgia)';
                                        End;
                                    End;
                            End;
                        End;
                End;
            End;
    End;
End;

Function GetWinProductID: String;
Const
    Digits = 'BCDFGHJKMPQRTVWXY2346789';
    KeyName = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion';
    Valuename = 'DigitalProductID';
Var
    Value: String;
    I, J, X: Integer;

    Key: HKEY;
    ValueType, ValueLen: DWORD;
Begin
    Result := '';
    If 0 = RegOpenKeyEx(HKEY_LOCAL_MACHINE, KeyName, 0, KEY_READ, Key) Then
    Begin
        Try
            ValueLen := 0;
            RegQueryValueEx(Key, Valuename, Nil, @ValueType, Nil, @ValueLen);
            If ValueLen >= 67 Then
            Begin
                SetLength(Value, ValueLen);
                If RegQueryValueEx(Key, Valuename, Nil, @ValueType, @Value[1], @ValueLen) = 0 Then
                Begin
                    For I := 24 Downto 0 Do
                    Begin
                        X := 0;
                        For J := 14 Downto 0 Do
                        Begin
                            X := (X Shl 8) + Ord(Value[53 + J]);
                            Value[53 + J] := Char(X Div 24);
                            X := X Mod 24;
                        End;
                        Result := Digits[X + 1] + Result;
                        If ((I > 0) And ((I Mod 5) = 0)) Then
                            Result := '-' + Result;
                    End;
                End;
            End;
        Finally
            RegCloseKey(Key);
        End;
    End;
End;

End.

