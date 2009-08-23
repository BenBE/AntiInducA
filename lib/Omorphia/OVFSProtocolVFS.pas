Unit OVFSProtocolVFS;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Virtual File System Submodule
//
// This unit defines the standard access protocolls of the VFS to access the
// VFS of Omorphia.
//
// *****************************************************************************
// To Do:
//  TODO -oBenBE -cVFS, Protocol : Implement the VFS Protocol Handler
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
    TOVFSProtocolVFS = Class(TOVFSProtocol)
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

Implementation

Uses
    ODbgInterface,
    OIncConsts,
    OIncProcs,
    OIncTypes,
    OVFSPathUtils;

{ TOVFSProtocolVFS }

Class Function TOVFSProtocolVFS.GetAttributes(AObj: TOVFSObject; AData: String): DWORD;
Var
    SL: TStringList;

    I: Integer;
    DH: TOVFSHandlerClass;
Begin
    //TODO 4 -oBenBE -cVFS, Protocol, VFS : Fix recursion bugs
    Result := 0;

    //Handle virtual Directories first!
    SL := TStringList.Create;
    Try
        AObj.Owner.GetDirectoryMountpoints(AData, SL);
        If SL.Count <> 0 Then
        Begin
            Result :=
                VFS_ATTRIBUTE_CAN_LIST Or
                VFS_ATTRIBUTE_IS_DIR Or
                VFS_ATTRIBUTE_VIRTUAL;

            Exit;
        End;
    Finally
        FreeAndNilSecure(SL);
    End;

    //Check if the source object is a file
    If Assigned(AObj.DataSrcObj) Then
    Begin
        //Check if the object is redirected by another VFS-Object
        //The given Object has a redirection, thus we have to check

        If AObj.DataSrcObj Is TOVFSObject Then
        Begin
            Result := TOVFSObject(AObj.DataSrcObj).FileAttributes;

            //Check if the current directory is a mountpoint
            If AObj.Owner.IsMountpoint(AData) Then
                Result := Result Or
                    VFS_ATTRIBUTE_IS_DIR Or
                    VFS_ATTRIBUTE_CAN_EXECUTE Or
                    VFS_ATTRIBUTE_VIRTUAL;
        End
        Else
        Begin
            Result :=
                VFS_ATTRIBUTE_IS_FILE Or
                VFS_ATTRIBUTE_CAN_READ Or
                VFS_ATTRIBUTE_CAN_WRITE;
        End;

        //Handle Data Handler Support
        //Data Handlers are implemented as subdirectories.
        For I := 0 To GetHandlerCount - 1 Do
        Begin
            DH := GetHandlerByIndex(I);
            If DH.IsVFSHandlerSupported(AObj) Then
            Begin
                Result := Result Or
                    VFS_ATTRIBUTE_IS_DIR or
                    VFS_ATTRIBUTE_CAN_EXECUTE;
                Break;
            End;
        End;
    End
    Else
    Begin
        Result :=
            VFS_ATTRIBUTE_IS_DIR Or
            VFS_ATTRIBUTE_VIRTUAL;
    End;
End;

Class Function TOVFSProtocolVFS.GetStoredFileSize(AObj: TOVFSObject;
    AData: String): Int64;
Begin
    Result := 0;
    If Not Assigned(AObj) Then
        Exit;
    If Not Assigned(AObj.DataSrcObj) Then
        Exit;
    If Not (AObj.DataSrcObj Is TOVFSObject) Then
        Exit;
    Result := TOVFSObject(AObj.DataSrcObj).FileSizeStored;
End;

Class Function TOVFSProtocolVFS.GetDirectory(AObj: TOVFSObject; AData: String; AStrings: TStrings): Integer;
Var
    VFSMan: TOVFSManager;
    VFSObj: TOVFSObject;
    X: Integer;

    I: Integer;
    DH: TOVFSHandlerClass;
Begin
    Result := -1;

    If Not Assigned(AObj) Then
        OmorphiaErrorStr(vl_Error, '', 'The supplied VFS Object is not assigned or nil');

    VFSMan := AObj.Owner;

    If Not Assigned(VFSMan) Then
        OmorphiaErrorStr(vl_Error, '', 'The supplied VFS Object doesn''t have an asigned Owner');

    If Not Assigned(AStrings) Then
        OmorphiaErrorStr(vl_Error, '', 'Result buffer not assigned.');

    If (AData = '/') Or Not Assigned(AObj.DataSrcObj) Then
    Begin
        Result := VFSMan.GetDirectoryMountpoints(AData, AStrings);
        Exit;
    End;

    // TODO -oBenBE, matze -cVFS, Protocol, VFS : Return a directory listing

    If Not (AObj.DataSrcObj Is TOVFSObject) Then
        Exit;

    VFSObj := TOVFSObject(AObj.DataSrcObj);

    //Handle Data Handler Support
    //Data Handlers are implemented as subdirectories.
    For I := 0 To GetHandlerCount - 1 Do
    Begin
        DH := GetHandlerByIndex(I);
        If DH.IsVFSHandlerSupported(AObj) Then
            AStrings.Add('\' + DH.VFSHandlerID);
    End;

    For X := 0 To VFSObj.DirListFilesCount - 1 Do
        AStrings.Add(VFSObj.DirListFilenames(X));
End;

Class Function TOVFSProtocolVFS.GetFileSize(AObj: TOVFSObject;
    AData: String): Int64;
Begin
    Result := 0;
    If Not Assigned(AObj) Then
        Exit;
    If Not Assigned(AObj.DataSrcObj) Then
        Exit;
    If Not (AObj.DataSrcObj Is TOVFSObject) Then
        Exit;
    Result := TOVFSObject(AObj.DataSrcObj).FileSize;
End;

Class Function TOVFSProtocolVFS.GetParentObject(AObj: TOVFSObject; AData: String): TOVFSObject;
Begin
    // TODO -oBenBE, matze -cVFS, Protocol, VFS : Return the parent object of a file
    Result := Nil;

    AData := GetVFSPathDataPart(AData);

    If AData = '' Then
    Begin
        OmorphiaDebugStr(vl_Warning, '', 'Invalid path, assuming ''/'' as directory of interest');
        AData := '/';
    End;

    If AData = '/' Then
        Exit;

    AData := GetFileDirectory(AData);

    AData := IncPathDelimEx(AData, '/');

    //TODO -oBenBE -cVFS, Protocol, VFS : Check for existing object instances \ Search for better solution
    Result := AObj.Owner.CreateFile(VFSProtocolPrefix + ':' + AData, fmOpenRead);
End;

Class Function TOVFSProtocolVFS.GetStreamObject(AObj: TOVFSObject; AData: String; AAccess: DWORD): TOVFSStream;
Var
    MPPath: String;
    VFSMan: TOVFSManager;
Begin
    // TODO -oBenBE, matze -cVFS, Protocol, VFS : Return a stream object for a given path
    Result := Nil;

    //Do we have a valid VFS Object?
    If Not Assigned(AObj) Then
        OmorphiaErrorStr(vl_Error, '', 'Requesting an VFS Object Stream requires the object this stream is for.');

    {
    //Recursion bug!!!
    //Is the Data Stream set yet?
    If Assigned(AObj.DataSrcObj) Then
    Begin
        Result := AObj.DataSrcObj;
        exit;
    end;
    //Recursion bug!!!
    }

    //Check for the right Protocoll Handler
    If AObj.PHC <> Self Then
        OmorphiaErrorStr(vl_Error, '', 'Invalid invoke of this routine using foreign Protocol Handler Class');

    //Get the associated VFS Manager object
    VFSMan := AObj.Owner;

    //Do we really have one?
    If Not Assigned(VFSMan) Then
        OmorphiaErrorStr(vl_Error, '', 'The supplied VFS Object doesn''t have an asigned Owner');

    //Korrekte "Ist innerhalb\unterhalb eines Mountpoints"-Behandlung ...
    MPPath := VFSMan.GetMountedPath(AObj.FileData);
    If MPPath <> '' Then
        Result := VFSMan.CreateFile(MPPath, AAccess);

    //Shorten next requests ;-)
    SetDataSourceObject(AObj, Result);
End;

Class Function TOVFSProtocolVFS.VFSProtocolName: String;
Begin
    Result := 'Main VFS Object Protocol Handler';
End;

Class Function TOVFSProtocolVFS.VFSProtocolPrefix: String;
Begin
    Result := 'vfs';
End;

Initialization
    RegisterVFSProtocol(TOVFSProtocolVFS);
Finalization
    UnregisterVFSProtocol(TOVFSProtocolVFS);
End.

