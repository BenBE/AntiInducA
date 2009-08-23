unit OVFSProtocolWin32;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Virtual File System Submodule
//
// This unit defines the standard access protocolls of the VFS to access the
// native file system of Windows.
//
// *****************************************************************************
// To Do:
//  TODO -oBenBE -cVFS, Protocol : Implement the Win32 Protocol Handler
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
    Classes,
    OVFSManager,
    OVFSStreamBase;

Type
    TOVFSProtocolWin32 = Class(TOVFSProtocol)
    Public
        Class Function VFSProtocolPrefix: String; Override;
        Class Function VFSProtocolName: String; Override;
        Class Function GetDirectory(AObj: TOVFSObject; AData: String; AStrings: TStrings): Integer; Override;
        Class Function GetStreamObject(AObj: TOVFSObject; AData: String; AAccess: DWORD): TOVFSStream; Override;
        Class Function GetAttributes(AObj: TOVFSObject; AData: String): DWORD; Override;
        Class Function GetParentObject(AObj: TOVFSObject; AData: String): TOVFSObject; Override;
        Class Function GetFileSize(AObj: TOVFSObject; AData: String): Int64; Override;
        Class Function GetStoredFileSize(AObj: TOVFSObject; AData: String): Int64; Override;
    End;

implementation

Uses
    ODbgInterface,
    OIncConsts,
    OIncProcs,
    OIncTypes,
    OVFSPathUtils,
    OVFSShellUtils,
    OVFSStreamWrapper;

{ TOVFSProtocolWin32 }

Class Function TOVFSProtocolWin32.GetAttributes(AObj: TOVFSObject; AData: String): DWORD;
Const
    //WinNT.h:
    //  #define FILE_ATTRIBUTE_ENCRYPTED            0x00004000
    FILE_ATTRIBUTE_ENCRYPTED = $00004000;

    Function GetAttributes(AData: String): DWORD;
    Var
        dwFileAttributes: DWORD;
    Begin
        Result := 0;

        dwFileAttributes := GetFileAttributes(PChar(AData));

        If dwFileAttributes = INVALID_FILE_ATTRIBUTES Then
        Begin
            OmorphiaDebugStr(vl_Warning, '', Format('Invalid File Attribute for %s', [AData]));
            Exit;
        End;

        If dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY <> 0 Then
            Result :=
                VFS_ATTRIBUTE_IS_DIR Or
                VFS_ATTRIBUTE_CAN_LIST Or
                VFS_ATTRIBUTE_CAN_READ Or
                VFS_ATTRIBUTE_CAN_WRITE Or
                VFS_ATTRIBUTE_CAN_EXECUTE
        Else
            Result :=
                VFS_ATTRIBUTE_IS_FILE Or
                VFS_ATTRIBUTE_CAN_SEEK Or
                VFS_ATTRIBUTE_CAN_READ Or
                VFS_ATTRIBUTE_CAN_WRITE;
        If dwFileAttributes And FILE_ATTRIBUTE_READONLY <> 0 Then
            Result := Result And Not VFS_ATTRIBUTE_CAN_WRITE;
        If dwFileAttributes And FILE_ATTRIBUTE_HIDDEN <> 0 Then
            Result := Result Or VFS_ATTRIBUTE_HIDDEN;
        If dwFileAttributes And FILE_ATTRIBUTE_SYSTEM <> 0 Then
            Result := Result Or VFS_ATTRIBUTE_SYSTEM And Not VFS_ATTRIBUTE_CAN_WRITE;
        If dwFileAttributes And FILE_ATTRIBUTE_ARCHIVE <> 0 Then
            Result := Result Or VFS_ATTRIBUTE_ARCHIVED;
        If dwFileAttributes And FILE_ATTRIBUTE_COMPRESSED <> 0 Then
            Result := Result Or VFS_ATTRIBUTE_COMPRESSED;
        If dwFileAttributes And FILE_ATTRIBUTE_ENCRYPTED <> 0 Then
            Result := Result Or VFS_ATTRIBUTE_ENCRYPTED;
    End;
Begin
    Result := 0;
    // UNC-Pfade abfangen
    If Copy(AData, 1, 2) = '\\' Then
    Begin
        //Zugriff auf UNC-Pfade verweigern!
        SetLastVFSError(ERROR_ACCESS_DENIED);
        Exit;
    End;

    // Cut off the '/' or '\' if it is the last Char except it is a mask like this 'X:\'
    If IsIncPathDelim(AData) And (Length(AData) > 3) Then
        AData := Copy(AData, 1, Length(AData) - 1);

    Case DriveType(AData[1]) Of
        dtDisk:
            Begin
                If DiskInFloppy(AData[1]) Then
                    Result := GetAttributes(AData)
                Else
                    Result := Result Or VFS_ATTRIBUTE_VIRTUAL;
            End;
        dtCD, dtDVD:
            Begin
                If DriveReady(AData[1]) Then
                    Result := GetAttributes(AData)
                Else
                    Result := Result Or VFS_ATTRIBUTE_VIRTUAL;
            End;
        dtHardDisk:
            Begin
                Result := GetAttributes(AData);
            End;
        dtNetDisk:
            Begin
                //Check if the Disk is ready :)
                //Result := GetAttributes(AData);
            End;
    Else
        Result := Result Or VFS_ATTRIBUTE_VIRTUAL;
    End;
End;

Class Function TOVFSProtocolWin32.GetDirectory(AObj: TOVFSObject; AData: String; AStrings: TStrings): Integer;
Var
    SR: TSearchRec;
    LastErrorMode: Integer;
Begin
    //TODO -oBenBE -cVFS, Protocol, Win32 : Auflisten von Win32-Verzeichnissen
    //TODO -oBenBE -cVFS, Protocol, Win32 : Verifizierung des Pfadnamens
    //TODO -oBenBE -cVFS, Protocol, Win32 : Prüfung des Pfadnamens auf Zugriffsberechtigung
    Result := 0;

    If Copy(AData, 1, 2) = '\\' Then
        Exit;

    If LowerCase(AData[1]) = 'a' Then
    Begin
        If DriveType(AData[1]) = dtDisk Then
            If Not DiskInFloppy(AData[1]) Then
                Exit;
    End;

    OmorphiaDebugStr(vl_Hint, '', 'Auflisten von Verzeichnis ' + IncPathDelimEx(AData, '\'));

    LastErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);

    If FindFirst(IncPathDelimEx(AData, '\') + '*.*', faAnyFile, SR) = 0 Then
    Begin
        Repeat
            If (SR.Name = '.') Or (SR.Name = '..') Then
                Continue;

            AStrings.Add(SR.FindData.cFileName);
            Inc(Result);
        Until FindNext(SR) <> 0;
        FindClose(SR);
    End;

    SetErrorMode(LastErrorMode);
End;

Class Function TOVFSProtocolWin32.GetFileSize(AObj: TOVFSObject;
    AData: String): Int64;
Var
    SR: TSearchRec;
    LastErrorMode: Integer;
Begin
    Result := 0;
    // UNC-Pfade abfangen
    If Copy(AData, 1, 2) = '\\' Then
    Begin
        //Zugriff auf UNC-Pfade verweigern!
        SetLastVFSError(ERROR_ACCESS_DENIED);
        Exit;
    End;

    // Cut off the '/' or '\' if it is the last Char except it is a mask like this 'X:\'
    If IsIncPathDelim(AData) And (Length(AData) > 3) Then
        AData := Copy(AData, 1, Length(AData) - 1);

    LastErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    If FindFirst(AData, faAnyFile, SR) = 0 Then
        Result := SR.FindData.nFileSizeHigh Shl 32 + SR.FindData.nFileSizeLow;
    FindClose(SR);
    SetErrorMode(LastErrorMode);
End;

Class Function TOVFSProtocolWin32.GetParentObject(AObj: TOVFSObject; AData: String): TOVFSObject;
Begin
    //TODO -oBenBE -cVFS, Protocol, Win32 : Get the Parent object
    Result := Nil;
End;

Class Function TOVFSProtocolWin32.GetStoredFileSize(AObj: TOVFSObject;
    AData: String): Int64;
Var
    nFileSizeHigh,
        nFileSizeLow: DWORD;
    LastErrorMode: Integer;
Begin
    Result := 0;
    // UNC-Pfade abfangen
    If Copy(AData, 1, 2) = '\\' Then
    Begin
        //Zugriff auf UNC-Pfade verweigern!
        SetLastVFSError(ERROR_ACCESS_DENIED);
        Exit;
    End;

    // Cut off the '/' or '\' if it is the last Char except it is a mask like this 'X:\'
    If IsIncPathDelim(AData) And (Length(AData) > 3) Then
        AData := Copy(AData, 1, Length(AData) - 1);

    LastErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    nFileSizeLow := GetCompressedFileSize(PChar(AData), @nFileSizeHigh);
    If nFileSizeLow <> INVALID_FILE_SIZE Then
        Result := nFileSizeHigh Shl 32 + nFileSizeLow;
    SetErrorMode(LastErrorMode);
End;

Class Function TOVFSProtocolWin32.GetStreamObject(AObj: TOVFSObject; AData: String; AAccess: DWORD): TOVFSStream;
Var
    VCLStream: TFileStream;
    lData: Integer;
Begin
    Result := Nil;

    //TODO -oBenBE -cVFS, Protocol, Win32 : Auswerten des Namens
    AData := TransformPathDelims(Trim(AData), '\');

    lData := Length(AData);
    If lData < 2 Then
    Begin
        SetLastVFSError(ERROR_FILE_INVALID);
        Exit;
    End;

    If lData = 2 Then
    Begin
        If AData[2] = ':' Then
        Begin
            //Zugriffe auf die Laufwerkshardware verweigern!
            SetLastVFSError(ERROR_ACCESS_DENIED);
            Exit;
        End;
    End;

    If Copy(AData, 1, 2) = '\\' Then
    Begin
        //Zugriff auf UNC-Pfade verweigern!
        SetLastVFSError(ERROR_ACCESS_DENIED);
        Exit;
    End;

    If lData = 3 Then
    Begin
        If Copy(AData, 2, 2) = ':\' Then
        Begin
            //Zugriff auf die Laufwerkshardware verweigern!
            SetLastVFSError(ERROR_ACCESS_DENIED);
            Exit;
        End;
    End;

    If Copy(AData, 2, 2) <> ':\' Then
    Begin
        //Zugriffe auf relative Pfade verweigern!
        SetLastVFSError(ERROR_ACCESS_DENIED);
        Exit;
    End;

    If (Pos('\.\', AData) <> 0) Or (Pos('\..\', AData) <> 0) Then
    Begin
        //Zugriffe auf relative Pfade verweigern!
        SetLastVFSError(ERROR_ACCESS_DENIED);
        Exit;
    End;

    If AObj.FileAttributes And VFS_ATTRIBUTE_IS_FILE = 0 Then
    Begin
        //Zugriffe auf Verzeichnisse als Streams verweigern!
        SetLastVFSError(ERROR_ACCESS_DENIED);
        Exit;
    End;

    //If the object is a file then we have to delete the '/' or '\' if it is the last char
    If AObj.FileAttributes And VFS_ATTRIBUTE_IS_FILE <> 0 Then
        If IsIncPathDelim(AData) Then
            AData := Copy(AData, 1, Length(AData) - 1);

    VCLStream := TFileStream.Create(AData, AAccess);
    Result := TOVCLToVFSStream.Create(VCLStream, True);
End;

Class Function TOVFSProtocolWin32.VFSProtocolName: String;
Begin
    Result := 'Native Windows FS Protocol Handler';
End;

Class Function TOVFSProtocolWin32.VFSProtocolPrefix: String;
Begin
    Result := 'win32';
End;

Initialization
    RegisterVFSProtocol(TOVFSProtocolWin32);
Finalization
    UnregisterVFSProtocol(TOVFSProtocolWin32);
end.
 
