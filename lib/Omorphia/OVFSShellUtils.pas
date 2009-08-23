Unit OVFSShellUtils;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Virtual File System Submodule
//
// This unit defines the basic routines for shell interaction.
//
// *****************************************************************************
// To Do:
// Implement http://www.luckie-online.de/Developer/Delphi/Sonstiges/CheckFileAccess.html
//
// *****************************************************************************
// News:
//
// *****************************************************************************
// Bugs:
//
// *****************************************************************************
// Info:
//
// *****************************************************************************

// Include the Compiler Version and Options Settings
{$I 'Omorphia.config.inc'}

Interface

Uses
    Windows,
    SysUtils,
    Classes;

// *****************************************************************************
// Name          : WindowsDir
// Parameter     : keine
// Resulttype    : String
// Beschreibung  : Gibt den Windows Pfad zurück
// *****************************************************************************
Function WindowsDir: String;

// *****************************************************************************
// Name          : SystemDir
// Parameter     : keine
// Resulttype    : String
// Beschreibung  : Gibt den Windows System Pfad zurück
// *****************************************************************************
Function SystemDir: String;

// *****************************************************************************
// Name          : TempDir
// Parameter     : keine
// Resulttype    : String
// Beschreibung  : Gibt den Windows Temp Pfad zurück
// *****************************************************************************
Function TempDir: String;

// *****************************************************************************
// Name          : Execute(vCommandLine, vUseCommandCom)
// Parameter     : vCommandLine(String)     = Befehl
//                 vUseCommandLine(Boolean) = Command.COM nutzen?
// Resulttype    : keine
// Beschreibung  : Ausführen externer Software
// *****************************************************************************

// *****************************************************************************
// Name          : DiskInFloppy(vDrive)
// Parameter     : vDrive(Char) = Floppy Buchstabe
// Resulttype    : Boolean
// Beschreibung  : Prüft nach einem Medium im Floppy Laufwerk
// *****************************************************************************
Function DiskInFloppy(vDrive: Char): Boolean;
Function DriveReady(ADrive: Char): Boolean;

Function Execute(vFileName: String; vParameter: String; vUseCommandCom: Boolean): Boolean;
Function RunProcess(AFileName: String; AShowCmd: DWORD; AWait: Boolean; AProcID: PDWORD): LongWord;
Function LockMedia(ADrive: Char; ALock: Boolean): Boolean;

Type
    TOIncFileCallBack = Procedure(APath: String; AFileName: String);

// Neo: searchFiles is used for recrusive searching in dirs, result is a TStringList, support for CallBack
Function SearchFiles(APath: String; AExtension: String; AStringList: TStrings; ASubFolder: Boolean = True; ACallBack: TOIncFileCallBack = Nil): Integer;

Implementation

Uses
    ShellAPI,
    ODbgInterface,
    OIncConsts,
    OIncProcs,
    OIncTypes,
    OSysOSInfo,
    OVFSPathUtils;

Function Execute(vFileName: String; vParameter: String; vUseCommandCom: Boolean): Boolean;
Const
    ObjectVerb: Array[0..4] Of String = ('edit', 'find', 'open', 'print', 'properties');
Begin
    // Neo: m$ mark that we have an error as default, like m$ stile ;-)
    Result := False;

    // Neo: check if an extension is given
  {    If Not isIn('.', vFileName) Then
       If Not Length(GetPathFromFile(vFileName + '.exe')) > Length(vFileName) Then
         If Not Length(GetPathFromFile(vFileName + '.com')) > Length(vFileName) Then
           Exit
          Else
           vFileName:=GetPathFromFile(vFileName + '.com')
         Else
          vFileName:=GetPathFromFile(vFileName + '.exe');
  }
    // Neo: if the given file wasn't found, search in path env
    If Not FileExists(vFileName) Then
        vFileName := GetPathFromFile(vFileName);

    // Neo: if we want use cmd shell
    If vUseCommandCom Then
    Begin
        vParameter := '/c start /wait %s ' + vParameter;
        If Pos(' ', vFileName) <> 0 Then
            vParameter := Format(vParameter, [AnsiQuotedStr(vFileName, '"')])
        Else
            vParameter := Format(vParameter, [vFileName]);
        If IsWinNT Then
            vFileName := GetPathFromFile('cmd.exe')
        Else
            vFileName := GetPathFromFile('command.com');
    End;

    // Neo: hook error handling
    Case ShellExecute(0, PChar(ObjectVerb[2]), PChar(vFileName),
        PChar(vParameter), Nil, SW_SHOWMINNOACTIVE) Of
        0:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'The operating system is out of memory or resources.');
        ERROR_FILE_NOT_FOUND:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'The specified file was not found. (' + vFileName + ')');
        ERROR_PATH_NOT_FOUND:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'The specified path was not found. (' + vFileName + ')');
        ERROR_BAD_FORMAT:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'The .exe file is invalid (non-Microsoft Win32® .exe or error in .exe image).');
        SE_ERR_ACCESSDENIED:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'The operating system denied access to the specified file.');
        SE_ERR_ASSOCINCOMPLETE:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'The file name association is incomplete or invalid.');
        SE_ERR_DDEBUSY:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'The Dynamic Data Exchange (DDE) transaction could not be completed because other DDE transactions were being processed.');
        SE_ERR_DDETIMEOUT:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'The DDE transaction could not be completed because the request timed out.');
        SE_ERR_DLLNOTFOUND:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'The specified dynamic-link library (DLL) was not found.');
        SE_ERR_NOASSOC:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'There is no application associated with the given file name extension. This error will also be returned if you attempt to print a file that is not printable.');
        SE_ERR_OOM:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'There was not enough memory to complete the operation.');
        SE_ERR_SHARE:
            OmorphiaDebugStr(vl_FatalError, 'OIncProcs.Execute',
                'A sharing violation occurred.');
    Else
        // Neo: no error, api gave us a stupid instance handle ;-)
        Result := True;
    End;
End;

// Neo: function by Luckie from www.delphi-forum.de, some change by neo

Function RunProcess(AFileName: String; AShowCmd: DWORD; AWait: Boolean; AProcID: PDWORD): LongWord;
Var
    StartupInfo: TStartupInfo;
    ProcessInfo: TProcessInformation;
Begin
    FillChar(StartupInfo, SizeOf(StartupInfo), #0);
    StartupInfo.cb := SizeOf(StartupInfo);
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW Or STARTF_FORCEONFEEDBACK;
    StartupInfo.wShowWindow := AShowCmd;
    If Not CreateProcess(Nil, PChar(AFileName), Nil, Nil, False, DETACHED_PROCESS
        Or NORMAL_PRIORITY_CLASS, Nil, Nil, StartupInfo, ProcessInfo) Then
        Result := WAIT_FAILED
    Else
    Begin
        If AWait = False Then
        Begin
            If Assigned(AProcID) Then
                AProcID^ := ProcessInfo.dwProcessId;
            Result := WAIT_FAILED;
        End
        Else
        Begin
            If Assigned(AProcID) Then
                AProcID^ := INVALID_HANDLE_VALUE;
            WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
            GetExitCodeProcess(ProcessInfo.hProcess, Result);
        End;
    End;
    If ProcessInfo.hThread <> 0 Then
        CloseHandle(ProcessInfo.hThread);
    If ProcessInfo.hProcess <> 0 Then
        CloseHandle(ProcessInfo.hProcess);
End;

Function WindowsDir: String;
Var
    BufferSize: DWORD;
    Buffer: Array Of Char;
Begin
    BufferSize := StdBufferSize;
    SetLength(Buffer, BufferSize);
    GetWindowsDirectory(@Buffer[0], BufferSize);
    Result := IncPathDelim(Copy(StrPas(@Buffer[0]), 0, BufferSize));
End;

Function SystemDir: String;
Var
    BufferSize: DWORD;
    Buffer: Array Of Char;
Begin
    BufferSize := StdBufferSize;
    SetLength(Buffer, BufferSize);
    GetSystemDirectory(@Buffer[0], BufferSize);
    Result := IncPathDelim(Copy(StrPas(@Buffer[0]), 0, BufferSize));
End;

Function TempDir: String;
Var
    BufferSize: DWORD;
    Buffer: Array Of Char;
Begin
    BufferSize := StdBufferSize;
    SetLength(Buffer, BufferSize);
    GetTempPath(BufferSize, @Buffer[0]);
    Result := IncPathDelim(Copy(StrPas(@Buffer[0]), 0, BufferSize));
End;

Function SearchFiles(APath: String; AExtension: String; AStringList: TStrings; ASubFolder: Boolean = True; ACallBack: TOIncFileCallBack = Nil): Integer;
Var
    SearchRec: TSearchRec;
Begin
    // Neo: make an '\' at end
    APath := IncPathDelim(APath);

    // Neo: search all Files
    Try
        If FindFirst(APath + AExtension, faAnyFile, SearchRec) = 0 Then
        Begin
            Repeat
                If (SearchRec.Name <> '.') And (SearchRec.Name <> '..') Then
                    If Assigned(AStringList) Then
                        AStringList.Add(APath + SearchRec.Name);
                If Assigned(ACallBack) Then
                    ACallBack(APath, SearchRec.Name);
            Until FindNext(SearchRec) <> 0;
        End;
    Finally
        FindClose(SearchRec);
    End;
    If ASubFolder Then
    Begin
        // Neo: search all Path
        ZeroMemory(@SearchRec, SizeOf(SearchRec));
        Try
            If FindFirst(APath + '*', faAnyFile, SearchRec) = 0 Then
            Begin
                Repeat
                    If SearchRec.Attr And faDirectory <> 0 Then
                        If (SearchRec.Name <> '.') And (SearchRec.Name <> '..') Then
                            SearchFiles(APath + SearchRec.Name, AExtension, AStringList, ASubFolder, ACallBack);
                Until FindNext(SearchRec) <> 0;
            End;
        Finally
            FindClose(SearchRec);
        End;
    End;
    // Neo: give the count of files
    Result := AStringList.Count;
    DbgResetOSError;
End;

// http://www.delphipraxis.net/topic40776_laufwerk+sperren.html

Function LockMedia(ADrive: Char; ALock: Boolean): Boolean;
Var
    LWStatus: HWND;
    LTemp: Cardinal;
    LPMR32: Boolean;
Const
    IOCTL_STORAGE_MEDIA_REMOVAL = $2D4804;
Begin
    LWStatus := CreateFile(PChar('\\.\' + ADrive + ':'), GENERIC_READ Or GENERIC_WRITE, 0, Nil, OPEN_EXISTING, 0, 0);
    LPMR32 := ALock;
    If LWStatus <> INVALID_HANDLE_VALUE Then
    Begin
        Result := DeviceIoControl(LWStatus, IOCTL_STORAGE_MEDIA_REMOVAL, @LPMR32, SizeOf(LPMR32), Nil, 0, LTemp, Nil);
        CloseHandle(LWStatus);
    End
    Else
        Result := False;
End;

Function DiskInFloppy(vDrive: Char): Boolean;
Var
    sRec: TSearchRec;
    I, LastErrorMode: Integer;
Begin
    Result := False;

    If DriveType(vDrive) <> dtDisk Then
        Exit;

    LastErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    I := FindFirst(vDrive + ':\*.*', faAnyFile, sRec);
    FindClose(sRec);
    SetErrorMode(LastErrorMode);

    Case I Of
        0: Result := True;
        2, 18:
            Begin
                OmorphiaDebugStr(vl_Hint, '', 'Diskette im Laufwerk ' + vDrive + ' ist leer !');
                Result := True;
            End;
        21, 3: OmorphiaDebugStr(vl_Hint, '', 'Keine Diskette im Laufwerk ' + vDrive)
    Else
        OmorphiaDebugStr(vl_Hint, '', 'Diskette nicht formatiert ! ' + IntToStr(I));
    End;
End;

Function DriveReady(ADrive: Char): Boolean;
Var
    sRec: TSearchRec;
    I, LastErrorMode: Integer;
Begin
    Result := False;

    If Not (DriveType(ADrive) In [dtCD, dtDVD]) Then
        Exit;

    LastErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    I := FindFirst(ADrive + ':\*.*', faAnyFile, sRec);
    FindClose(sRec);
    SetErrorMode(LastErrorMode);

    If I = 0 Then
        Result := True;
End;

End.
