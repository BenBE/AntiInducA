Unit OVFSManager;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Virtual File System Submodule
//
// This unit defines the basic typesand objects for interaction with real
// devices, virtual mountpoints and other data access points.
//
// *****************************************************************************
// To Do:
//  TODO 1 -oBenBE, Neo -cVFS, Security : Zugriff auf Benutzerverzeichnisse statt dem Programmverzeichnis
//  DONE -oNeo@BenBE -cVFS, Stream : ReadText- und ReadTextLn-Funktionen implementieren
//  DONE -oNeo@BenBE -cVFS, Stream : WriteText- und WriteTextLn-Funktionen implementieren
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
    Contnrs, 
    OVFSStreamBase,
    OVFSStreamWrapper;

{
ABSTRACT:

    This unit defines the basic objects needed for an Unix-like VFS that consists
    of the following predefined mountpoints:

        /                               Root Mountpoint
            dev/                        Device Library
                dos/                    Mapping of the DOS Drive letters
                unix/                   Mapping of the unix FS root node
                mmf/                    Memory Mapped Files (for fast access)
                proc/                   Access to processes by their pid
                    pid/                Process data directory for each process
                        procdata        Process information like exe name, owner, runtime
                        memory          Memory space of the process
                        modulelist/     List of modules loaded by the process
                info/                   Systeminfos
            home/                       Application homepath
                tmp/                    Temporary program data storage
            net/                        Network Neightbourhood (Netzwerkumgebung)
                127.0.0.1/              IP \ NetBEUI name of the computer to interact with
                    [user[:pw]@]share/  Network share access
                    sockTCP/port        TCP connection to the specified port
                    sockUDP/port        UDP connection to the specified port
            reg/                        Registry Root Node
                HKCU/                   HKEY_CURRENT_USER
                HKLM/                   HKEY_LOCALE_MACHINE
                HKCR/                   HKEY_CLASSES_ROOT
                HKCC/                   HKEY_CURRENT_CONFIG
                HKDD/                   HKEY_DYN_DATA
                HKUD/                   HKEY_USERS
                self/                   Own storage data access possibilities
                    HKCU/               SymLink to /dev/reg/HKCU/Software/Company/Program/
                    HKLW/               SymLink to /dev/reg/HKLM/Software/Company/Program/
                    ini/                SymLink to /home/exename.ini
            tmp/                        SymLink to /home/tmp/
            usr/                        User data directory \ user profile

SUPPORTED FEATURES:

    - Dynamic mountpoints
    - Automatic filetype recognition
    - Network (TCP\UDP\NetBEUI) support
    - Process Memory Editing
    - Memory Mapped Files support
    - Registry reading \ writing
    - File-to-Directory-Interpretation possible (e.g. for Compressed\Video\INI\... files)

NOTES and SPECIFICATIONS:

    - Mountpoints can either be VFS or Non-VFS-Links
        - For VFS-Links the protocoll spec at the beginning can be left out
            i.e. /dev/unix/bin and vfs:/dev/unix/bin specify the same directory
            Only requirement is, that paths begin with /
        - For Non-VFS the protocoll must be one of
            protocoll   path            description
            vfs         normal          VFS directory (optional, Full Access)
            win32       W32 Path Spec   DOS\W32 Logical Path specification (Drives read-only!)
            win32dev    UNC Device      Direct Device Access (WNT-based only, read-only!!!)
            unix        Unix Path Spec  Unix FS File (Full Access, if / read-only!!!, /dev and /etc forbidden!)
            mmfmem      MMF Name        Name of a MMF Area
            mmffile     [MMF Name@]File Mapping of a file as a MMF
            tcp         URL             TCP Connection to remote Host (for proxy use [[usr[:pw]@]proxy[:port];]dest:port)
            udp         URL             UDP Connection to remote Host (for proxy use [[usr[:pw]@]proxy[:port];]dest:port)
            http        URL             HTTP Request (URL contains NO protocoll spec!)
            https       URL             HTTPS Request (URL contains NO protocoll spec!)
            ftp         URL             FTP Server or Server path ([[user[:pw]@]proxy[:port];][user[:pw]@]host[:port][/path[/file]])
            uncfile     UNC File        UNC Network File Access (Full Access)
          or any other registered protocoll handler name.
    - Mountpoints can only be within existing directories, but excluding
      archives or file extraction directories (i.e. not within e.g. the image
      directory of a movie or animated gif)
    - Mountpoints can only be set to non-existing files\directories, i.e.
      if there's a file\dir /home/blub, there can not be a mountpoint
      making /home/blub --> /dev/dos/c, vice versa: if the mountpoint was
      created before the file, every attemp to create the file
      /home/blub will fail.
    - Mountpoints can be cascaded, i.e.
        /reg/self/ini --> /home/progname.ini;
        /home --> /dev/dos/c/programme/...;
        /dev/dos/c --> win32:c:/
        --> /reg/self/ini --> win32:c/programme/.../progname.ini

}

Const
    VFS_STATE_SUCCESS = 0;                                                      //Operation completed successfully
    VFS_STATE_PATH_NOT_FOUND = 1;                                               //The path requested could not be found
    VFS_STATE_FILE_NOT_FOUND = 2;                                               //The file requested could not be found
    VFS_STATE_INVALID_MOUNTPOINT = 3;                                           //Accessing information of the mountpoint failed
    VFS_STATE_INVALID_FILETYPE = 4;                                             //Gathering information for file path resolution failed
    VFS_STATE_ACCESS_DENIED = 5;                                                //Accessing this VFS Object was rejected
    VFS_STATE_INVALID_PROTOCOLL = 6;                                            //The given mountpoint protocoll is invalid or unrecognized

Const
    VFS_ATTRIBUTE_IS_DIR = $00000001;                                           //D object is a directory (container)
    VFS_ATTRIBUTE_IS_FILE = $00000002;                                          //F object is a file (stream)
    VFS_ATTRIBUTE_ARCHIVED = $00000004;                                         //A attribute "archived"
    VFS_ATTRIBUTE_HIDDEN = $00000008;                                           //H attribute "hidden"
    VFS_ATTRIBUTE_CAN_READ = $00000010;                                         //R File can be read
    VFS_ATTRIBUTE_CAN_WRITE = $00000020;                                        //W File can be written
    VFS_ATTRIBUTE_SYSTEM = $00000040;                                           //S attribute "system"
    VFS_ATTRIBUTE_COMPRESSED = $00000080;                                       //C File is compressed
    VFS_ATTRIBUTE_ENCRYPTED = $00000100;                                        //E File is encrypted
    VFS_ATTRIBUTE_VIRTUAL = $00000200;                                          //V Object is a virtual object
    VFS_ATTRIBUTE_OFFLINE = $00000400;                                          //O File is an offline storage object
    VFS_ATTRIBUTE_TEMPORARY = $00000800;                                        //T attribute "temporary"
    VFS_ATTRIBUTE_QUOTA = $00001000;                                            //Q There's a disk quota on this object
    VFS_ATTRIBUTE_CAN_LIST = $00002000;                                         //L Directory listing is available
    VFS_ATTRIBUTE_CAN_EXECUTE = $00004000;                                      //X User can execute this object
    VFS_ATTRIBUTE_CAN_SEEK = $00008000;                                         //J File allows seeking inside the stream

Type
    TOnVFSNotifyEvent = Procedure(Sender: TObject; OP: String; Path: String) Of Object;

Type
    TOVFSObject = Class;
    TOVFSManager = Class;
    TOVFSProtocol = Class;
    TOVFSHandler = Class;

    TOVFSProtocolClass = Class Of TOVFSProtocol;
    TOVFSHandlerClass = Class Of TOVFSHandler;

    TOVFSObject = Class(TOVFSStream)
    Private
        FOwner: TOVFSManager;
        FParent: TOVFSObject;

        FFileData: String;
        FAccessMask: DWORD;
        FFilename: String;

        FDataSrcObj: TOVFSStream;

        FDestroying: Boolean;

        Function GetParent: TOVFSObject;
        Function GetPHC: TOVFSProtocolClass;
    Protected
        FSubObj: TObjectList;
        FPHC: TOVFSProtocolClass;

        FDirListOK: Boolean;
        FDirList: TStringList;

        Function GetDataSrcObj: TOVFSStream;

        Function GetSize: Int64; Override;
        Procedure SetSize(AValue: Int64); Override;
        Function GetPosition: Int64; Override;
        Procedure SetPosition(AValue: Int64); Override;

        Procedure DirListValidate; Virtual;
    Public
        Constructor Create(AOwner: TObject); Reintroduce; Overload; Virtual;
        Constructor Create(AOwner: TOVFSManager); Reintroduce; Overload; Virtual;
        Destructor Destroy; Override;

        Class Function CreateFile(APath: String; AAccess: DWORD; AManager: TOVFSManager = Nil): TOVFSObject;

        Function Read(Var Buffer; Count: Int64): Int64; Override;
        Function Write(Const Buffer; Count: Int64): Int64; Override;
        Function Seek(Offset: Int64; Origin: Word): Int64; Override;

        Function FileData: String; Virtual;

        Function FileName: String; Virtual;
        Function FilePath: String; Virtual;
        Function FileSize: Int64; Virtual;
        Function FileSizeStored: Int64;
        Function FilePos: Int64; Virtual;

        Function FileAttributes: DWORD; Virtual;

        Function DirListFilesCount: Integer; Virtual;
        Function DirListFilenames(Index: Integer): String; Virtual;
        Function DirListFileObjects(Index: Integer): TOVFSObject; Virtual;

        Property DataSrcObj: TOVFSStream Read GetDataSrcObj;
        Property PHC: TOVFSProtocolClass Read GetPHC;

        Property Owner: TOVFSManager Read FOwner;
        Property Parent: TOVFSObject Read GetParent;
    End;

    TOVFSRootObject = Class(TOVFSObject)
    Protected
        Function GetSize: Int64; Override;
        Procedure SetSize(AValue: Int64); Override;
        Function GetPosition: Int64; Override;
        Procedure SetPosition(AValue: Int64); Override;
    Public
        Constructor Create(AOwner: TOVFSManager); Override;
        Destructor Destroy; Override;

        Function Read(Var Buffer; Count: Int64): Int64; Override;
        Function Write(Const Buffer; Count: Int64): Int64; Override;
        Function Seek(Offset: Int64; Origin: Word): Int64; Override;

        Function FileName: String; Override;
        Function FilePath: String; Override;
        Function FileSize: Int64; Override;
        Function FilePos: Int64; Override;

        Function FileAttributes: DWORD; Override;
    End;

    TOVFSManager = Class(TObject)
    Private
        FOpenFilesList: TObjectList;
        FMountpointList: TStringList;

        FOVFSRootObject: TOVFSRootObject;
        FOnVFSNotify: TOnVFSNotifyEvent;
        Procedure SetOnVFSNotify(Const Value: TOnVFSNotifyEvent);
    Protected

    Public
        Constructor Create; Reintroduce; Virtual;
        Destructor Destroy; Override;

        Function CreateFile(APath: String; AAccess: DWORD): TOVFSObject;
        Procedure CloseFile(AFile: TOVFSObject);
        Procedure CloseAll;

        Function Mount(Dest, Source: String): Boolean;
        Function Unmount(Dest: String): Boolean;
        Function GetDirectoryMountpoints(AVFSPath: String; AStrings: TStrings): Integer;
        Function IsMountpoint(AVFSPath: String): Boolean;
        Function GetMountedPath(APath: String): String;

        Function OpenFilesCount: Integer;

        Function GetVFSRoot: TOVFSObject;
        Function GetParentObject(AnObj: TOVFSObject): TOVFSObject;

        Property OnVFSNotify: TOnVFSNotifyEvent Read FOnVFSNotify Write SetOnVFSNotify;
    End;

    TOVFSProtocol = Class(TObject)
    Protected
        Class Function GetVFSManager(AObj: TOVFSObject): TOVFSManager;
        Class Procedure SetVFSManager(AObj: TOVFSObject; AManager: TOVFSManager);
        Class Procedure SetDataSourceObject(AObj: TOVFSObject; ADataSrcObj: TOVFSStream);
    Public
        Class Function VFSProtocolPrefix: String; Virtual; Abstract;
        Class Function VFSProtocolName: String; Virtual; Abstract;
        Class Function GetDirectory(AObj: TOVFSObject; AData: String; AStrings: TStrings): Integer; Virtual; Abstract;
        Class Function GetStreamObject(AObj: TOVFSObject; AData: String; AAccess: DWORD): TOVFSStream; Virtual; Abstract;
        Class Function GetAttributes(AObj: TOVFSObject; AData: String): DWORD; Virtual; Abstract;
        Class Function GetParentObject(AObj: TOVFSObject; AData: String): TOVFSObject; Virtual; Abstract;
        Class Function GetFileSize(AObj: TOVFSObject; AData: String): Int64; Virtual; Abstract;
        Class Function GetStoredFileSize(AObj: TOVFSObject; AData: String): Int64; Virtual; Abstract;
    End;

    TOVFSHandler = Class(TObject)
    Protected
        Class Function GetVFSManager(AObj: TOVFSObject): TOVFSManager;
        Class Procedure SetVFSManager(AObj: TOVFSObject; AManager: TOVFSManager);
        Class Procedure SetDataSourceObject(AObj: TOVFSObject; ADataSrcObj: TOVFSStream);
    Public
        Class Function VFSHandlerID: String; Virtual; Abstract;
        Class Function VFSHandlerName: String; Virtual; Abstract;
        Class Function GetDirectory(AObj: TOVFSObject; AData: String; AStrings: TStrings): Integer; Virtual; Abstract;
        Class Function GetStreamObject(AObj: TOVFSObject; AData: String; AAccess: DWORD): TOVFSStream; Virtual; Abstract;
        Class Function GetAttributes(AObj: TOVFSObject; AData: String): DWORD; Virtual; Abstract;
        Class Function GetRawObject(AObj: TOVFSObject; AData: String): TOVFSObject; Virtual; Abstract;

        Class Function IsVFSHandlerSupported(AObj: TOVFSObject): Boolean; Virtual; Abstract;
    End;

Var
    VFSManager: TOVFSManager;

Function GetLastVFSError: DWORD;
Procedure SetLastVFSError(Code: DWORD);

// BenBE: Checks if a given protocoll name is valid
Function IsValidProtocolName(AProtocol: String): Boolean;
// BenBE: Check if the given protocoll is registered
Function IsRegisteredProtocolName(AProtocol: String): Boolean;
// BenBE: Handle registering and unregistering protocolls
Function RegisterVFSProtocol(AVFSProtocolClass: TOVFSProtocolClass): Boolean;
Function UnregisterVFSProtocol(AVFSProtocolClass: TOVFSProtocolClass): Boolean;
// BenBE: Get a protocoll handling class
Function GetVFSProtocolClass(AProtocol: String): TOVFSProtocolClass;
// BenBE: To enumerate the VFS Protocols
Function GetProtocolCount: Integer;
Function GetProtocolByIndex(Index: Integer): TOVFSProtocolClass;

// BenBE: Checks if a given protocoll name is valid
Function IsValidHandlerName(AHandler: String): Boolean;
// BenBE: Check if the given protocoll is registered
Function IsRegisteredHandlerName(AHandler: String): Boolean;
// BenBE: Handle registering and unregistering protocolls
Function RegisterVFSHandler(AVFSHandlerClass: TOVFSHandlerClass): Boolean;
Function UnregisterVFSHandler(AVFSHandlerClass: TOVFSHandlerClass): Boolean;
// BenBE: Get a protocoll handling class
Function GetVFSHandlerClass(AHandler: String): TOVFSHandlerClass;
// BenBE: To enumerate the VFS Data Handlers
Function GetHandlerCount: Integer;
Function GetHandlerByIndex(Index: Integer): TOVFSHandlerClass;

Implementation

Uses
    ODbgInterface,
    OIncProcs,
    OIncConsts,
    OLangGeneral,
    OVFSPathUtils,
    OVFSProtocolls,
    OVFSProtocolVFS,
    OVFSDataSrc;

Var
    VFSProtocolClasses: TClassList;
    VFSHandlerClasses: TClassList;

Threadvar
    VFSLastError: DWORD;

Function GetLastVFSError: DWORD;
Begin
    Result := VFSLastError;
End;

Procedure SetLastVFSError(Code: DWORD);
Begin
    VFSLastError := Code;
    OmorphiaDebugStr(vl_Warning, '', Format('Last VFS Error Code changed to %d by call from %.8x.', [Code, GetCallerAddr]));
End;

{ TOVFSObject }

Constructor TOVFSObject.Create(AOwner: TOVFSManager);
Begin
    Inherited Create;

    FOwner := AOwner;
    FParent := Nil;

    //  TODO -oBenBE -cVFS, Object : Implement the constructor

    FPHC := Nil;

    FDataSrcObj := Nil;

    FDirList := TStringList.Create;
    FDirListOK := False;

    FSubObj := TObjectList.Create(False);
End;

Constructor TOVFSObject.Create(AOwner: TObject);
Begin
    If Not (AOwner Is TOVFSManager) Then
        Create(VFSManager)
    Else
        Create(TOVFSManager(AOwner));
End;

Class Function TOVFSObject.CreateFile(APath: String; AAccess: DWORD; AManager: TOVFSManager): TOVFSObject;
Begin
    //Check if a VFSManager was given
    If Not Assigned(AManager) Then
        AManager := VFSManager;

    //Check if the default manager was assigned or another one was given
    If Not Assigned(AManager) Then
        OmorphiaErrorStr(vl_Error, '', 'Unable to find an VFSManager to open the given file with.');

    Result := AManager.CreateFile(APath, AAccess);
End;

Destructor TOVFSObject.Destroy;
Var
    FTmp: TOVFSManager;
    FSub: TOVFSObject;
Begin
    FDestroying := True;

    //Fix a issue with file finalization
    If Assigned(FSubObj) Then
    Begin
        While FSubObj.Count > 0 Do
        Begin
            FSub := TOVFSObject(FSubObj[0]);
            If Assigned(FSub) Then
                FreeAndNilSecure(FSub);
            FSubObj.Delete(0);
        End;
        FreeAndNil(FSubObj);
    End;

    //Clear the directory list as it is no longer needed
    If Assigned(FDirList) Then
        FreeAndNil(FDirList);

    //Free the own data source object if any
    If Assigned(FDataSrcObj) Then
        FreeAndNil(FDataSrcObj);

    //Abmelden beim Parent-Object
    If Assigned(FParent) Then
    Begin
        If Assigned(FParent.FSubObj) Then
            FParent.FSubObj.Remove(Self)
        Else
            OmorphiaDebugStr(vl_Warning, '', 'Parent Object doesn''t have initialized subobject list!');
    End;

    //Remove the own reference off the VFS Manager
    If Assigned(FOwner) Then
    Begin
        FTmp := FOwner;
        FOwner := Nil;
        FTmp.CloseFile(Self);
    End;

    Inherited;
End;

Function TOVFSObject.DirListFilenames(Index: Integer): String;
Begin
    DirListValidate;

    Result := FDirList[Index];
End;

Function TOVFSObject.DirListFileObjects(Index: Integer): TOVFSObject;
Begin
    // TODO -oBenBE -cVFS, Object : Get a Directory \ File Object by Index
    Result := Owner.CreateFile(IncPathDelimEx(FilePath, '/') + DirListFilenames(Index), FAccessMask);
End;

Function TOVFSObject.DirListFilesCount: Integer;
Begin
    DirListValidate;

    Result := FDirList.Count;
End;

Procedure TOVFSObject.DirListValidate;
Begin
    // DONE -oBenBE -cVFS, Root : Returning of the Subdirectory list
    If FDirListOK Then
        Exit;

    // TODO -oBenBE -cVFS, Obj : Check for Data Handlers
    If Not Assigned(FPHC) Then
        OmorphiaErrorStr(vl_Error, '', 'No Protocol Handler assigned');

    FPHC.GetDirectory(Self, FFileData, FDirList);
    FDirListOK := True;
End;

Function TOVFSObject.FileAttributes: DWORD;
Begin
    Result := FPHC.GetAttributes(Self, FFileData);
End;

Function TOVFSObject.FileData: String;
Begin
    Result := FFileData;
End;

Function TOVFSObject.FileName: String;
Begin
    Result := FFilename;
End;

Function TOVFSObject.FilePath: String;
Begin
    If Assigned(Parent) Then
        Result := IncPathDelimEx(Parent.FilePath, '/') + FileName
    Else
        Result := '/';
End;

Function TOVFSObject.FilePos: Int64;
Begin
    Result := GetPosition;
End;

Function TOVFSObject.FileSize: Int64;
Begin
    Result := 0;
    If Not Assigned(FPHC) Then
        Exit;
    Result := FPHC.GetFileSize(Self, FFileData);
End;

Function TOVFSObject.FileSizeStored: Int64;
Begin
    Result := 0;
    If Not Assigned(FPHC) Then
        Exit;
    Result := FPHC.GetStoredFileSize(Self, FFileData);
End;

Function TOVFSObject.GetDataSrcObj: TOVFSStream;
Begin
    If Assigned(FDataSrcObj) Then
    Begin
        Result := FDataSrcObj;
        Exit;
    End;

    //    If FileAttributes And VFS_ATTRIBUTE_IS_FILE <> 0 Then
    FDataSrcObj := FPHC.GetStreamObject(Self, FFileData, FAccessMask);

    Result := FDataSrcObj;
End;

Function TOVFSObject.GetParent: TOVFSObject;
Begin
    If Assigned(FParent) Then
    Begin
        Result := FParent;
        Exit;
    End;

    FParent := FOwner.GetParentObject(Self);

    Result := FParent;
End;

Function TOVFSObject.GetPHC: TOVFSProtocolClass;
Begin
    Result := FPHC;
End;

Function TOVFSObject.GetPosition: Int64;
Begin
    If Not Assigned(DataSrcObj) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := FDataSrcObj.Position;
End;

Function TOVFSObject.GetSize: Int64;
Begin
    Result := 0;

    If FileAttributes And VFS_ATTRIBUTE_IS_FILE = 0 Then
        Exit;

    If Not Assigned(DataSrcObj) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := FDataSrcObj.Size;
End;

Function TOVFSObject.Read(Var Buffer; Count: Int64): Int64;
Begin
    // DONE -oBenBE -cVFS, Object : Implement Read
    If Not Assigned(DataSrcObj) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := FDataSrcObj.Read(Buffer, Count);
End;

Function TOVFSObject.Seek(Offset: Int64; Origin: Word): Int64;
Begin
    // DONE -oBenBE -cVFS, Object : Implement Seek
    If Not Assigned(DataSrcObj) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := FDataSrcObj.Seek(Offset, Origin);
End;

Procedure TOVFSObject.SetPosition(AValue: Int64);
Begin
    If Not Assigned(DataSrcObj) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    FDataSrcObj.Position := AValue;
End;

Procedure TOVFSObject.SetSize(AValue: Int64);
Begin
    If Not Assigned(DataSrcObj) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    FDataSrcObj.Size := AValue;
End;

Function TOVFSObject.Write(Const Buffer; Count: Int64): Int64;
Begin
    // DONE -oBenBE -cVFS, Object : Implement Write
    If Not Assigned(DataSrcObj) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := DataSrcObj.Write(Buffer, Count);
End;

{ TOVFSManager }

Procedure TOVFSManager.CloseAll;
Begin
    //Opened files are no longer closed that way ...
    {
    While FOpenFilesList.Count > 0 Do
        CloseFile(TOVFSObject(FOpenFilesList[0]));
    }
    If GetVFSRoot = Nil Then
        OmorphiaErrorStr(vl_FatalError, '', 'The VFS Root Object is not assigned');

    If GetVFSRoot.FSubObj = Nil Then
        OmorphiaErrorStr(vl_FatalError, '', 'The subdirectory object list for the VFS Root Object is not assigned');

    GetVFSRoot.FSubObj.Clear;
End;

Procedure TOVFSManager.CloseFile(AFile: TOVFSObject);
Begin
    //  TODO -oBenBE -cVFS, Manager : Closing a file and freeing its context
    If Not Assigned(AFile) Then
        Exit;

    FOpenFilesList.Remove(AFile);

    If Not AFile.FDestroying Then
        FreeAndNil(AFile);
End;

Constructor TOVFSManager.Create;
Begin
    Inherited Create;

    FMountpointList := TStringList.Create;
    FOpenFilesList := TObjectList.Create(False);

    FOVFSRootObject := TOVFSRootObject.Create(Self);
End;

Function TOVFSManager.CreateFile(APath: String; AAccess: DWORD): TOVFSObject;

    Function InternalOpenAsSubObject(AParent: TOVFSObject; FullName, SubName: String; PH: TOVFSProtocolClass): TOVFSObject;
    var
        I: Integer;
        Obj: TOVFSObject;
    Begin
        //First check if the file has been opened before using same AccessMask ...
        For I := FOpenFilesList.Count - 1 downto 0 do
        Begin
            Obj:=TOVFSObject(FOpenFilesList[I]);
            If (Obj.PHC = PH) and (Obj.FileData = FullName) and (Obj.Parent = AParent) and (Obj.FAccessMask = AAccess) Then
            Begin
                Result := Obj;
                Exit;
            end;
        end;

    //File was not opened before ...
        Result := TOVFSObject.Create(Self);
        Try
            Try
                Result.FPHC := PH;
                Result.FParent := AParent;
                Result.FFileData := FullName;

                //Check if the necessary access is given ...
                {
                If Assigned(Result.FParent) Then
                Begin

                end;
                }

                Result.FAccessMask := AAccess;
                Result.FDirListOK := False;

                //Get the filename for this object
                If Assigned(Result.Parent) Then
                    Result.FFilename := SubName
                Else
                    Result.FFilename := ExtractFileName(FullName);

                Result.FDataSrcObj := Nil;

                If Assigned(AParent) Then
                Begin
                    If Not Assigned(AParent.FSubObj) Then
                    Begin
                        OmorphiaDebugStr(vl_Warning, '', 'The subdirectory object list of the directory object containing the requested file has not been initialized');
                        AParent.FSubObj := TObjectList.Create(False);
                    End;

                    AParent.FSubObj.Add(Result);
                End;
            Except
                FreeAndNilSecure(Result);
                Raise;
            End;
        Finally
            If Assigned(Result) Then
                FOpenFilesList.Add(Result);
        End;
    End;

Var
    Protocol: String;
    DataPart: String;

    ProtocolHandler: TOVFSProtocolClass;

    TmpParent: TOVFSObject;
    I: Integer;

    TmpFull, TmpDir: String;

    DHC: TOVFSHandlerClass;
Begin
    //  DONE -oBenBE -cVFS, Manager : Opening a file and creating its context
    //  TODO 5 -oBenBE -cSecurity, VFS, Manager : Check File paths

//    OmorphiaDebugStr(vl_Hint, '', Format('Opening file "%s" using access mask %.8x ...', [APath, AAccess]));

    Protocol := GetVFSPathProtocol(APath);
    DataPart := GetVFSPathDataPart(APath);

    ProtocolHandler := GetVFSProtocolClass(Protocol);

    If Not Assigned(ProtocolHandler) Then
        OmorphiaErrorStr(vl_Error, '', Format(vfsUnknownProtocol, [Protocol]));

    If DataPart = '' Then
        OmorphiaErrorStr(vl_Error, '', 'Pathnames must include at least one character!');

    //Check for paths inside the VFS Protocol
    If ProtocolHandler = TOVFSProtocolVFS Then
    Begin
        Result := GetVFSRoot;

        //Check if the root was requested ...
        If DataPart = '/' Then
        Begin
            Exit;
        End;

        //Remove leading and trailing slashes if any. Directories and files are handled equal ...
        If DataPart[1] <> '/' Then
            OmorphiaErrorStr(vl_Error, '', 'VFS Protocol Paths mzst start in the root directory!');
        Delete(DataPart, 1, 1);
        If Copy(DataPart, Length(DataPart), 1) = '/' Then
            Delete(DataPart, Length(DataPart), 1);

        TmpParent := Result;
        TmpFull := '';
        //Split the path into its parts
        While DataPart <> '' Do
        Begin
            I := Pos('/', DataPart);
            If I = 0 Then
            Begin
                TmpDir := DataPart;
                DataPart := '';
            End
            Else
            Begin
                TmpDir := Copy(DataPart, 1, I - 1);
                Delete(DataPart, 1, I);
            End;
            TmpFull := TmpFull + '/' + TmpDir;

            If (TmpDir = '.') Or (TmpDir = '..') Then
                OmorphiaErrorStr(vl_Error, '', 'Relative pathname are not permitted!');

            I := Pos('\', TmpDir);
            If I <> 0 Then
            Begin
                If I <> 1 Then
                    OmorphiaErrorStr(vl_Error, '', 'Backslashes are permitted as first character to indicate Data Handlers only.');

                //Handle explicit Data Handlers
                Delete(TmpDir, 1, 1);
                If Not IsRegisteredHandlerName(TmpDir) Then
                    OmorphiaErrorStr(vl_Error, '', Format('The given Protocol Handler (%s) does not exist.', [TmpDir]));

                DHC := GetVFSHandlerClass(TmpDir);

                If Not DHC.IsVFSHandlerSupported(TmpParent) Then
                    OmorphiaErrorStr(vl_Error, '', Format('The specified data handler (%s) does not support handling this kind of data in file %s.', [TmpDir, TmpParent.FPHC.VFSProtocolPrefix + ':' + TmpParent.FFileData]));

                //Do the linking between those objects ...
                // TODO -oBenBE -cVFS, Manager : Handle opening explicit data handlers
                OmorphiaErrorStr(vl_FatalError, '', 'Not yet implemented!');
            End;

            //Handle implicit Data Handlers
            If TmpParent.FileAttributes And VFS_ATTRIBUTE_IS_DIR = 0 Then
            Begin
                // TODO -oBenBE -cVFS, Manager : Handle opening implicit data handlers
                OmorphiaErrorStr(vl_FatalError, '', 'Not yet implemented!');
            End;

            TmpParent := InternalOpenAsSubObject(TmpParent, TmpFull, TmpDir, ProtocolHandler);
            //  TODO 5 -oBenBE -cVFS, Manager : #0000193 Verifying the result of InternalOpenAsSubObject
        End;

        Result := TmpParent;
        Exit;
    End;

    Result := InternalOpenAsSubObject(Nil, DataPart, ExtractFileName(DataPart), ProtocolHandler);
End;

Destructor TOVFSManager.Destroy;
Begin
    CloseAll;

    FreeAndNil(FOVFSRootObject);

    FreeAndNilSecure(FOpenFilesList);
    FreeAndNilSecure(FMountpointList);

    Inherited;
End;

Function TOVFSManager.GetDirectoryMountpoints(AVFSPath: String; AStrings: TStrings): Integer;
Var
    X: Integer;
    VFSPLen: Integer;
    TmpMountPath: String;
    SlashPos: Integer;
Begin
    If Pos('\', AVFSPath) <> 0 Then
        OmorphiaErrorStr(vl_Error, '', 'Invalid path using ''\'' for directory separation.');

    If AVFSPath = '' Then
    Begin
        OmorphiaDebugStr(vl_Warning, '', 'Invalid path specified: Assuming VFS Root Directory');
        AVFSPath := '/';
    End;

    If Pos('//', AVFSPath) <> 0 Then
    Begin
        OmorphiaDebugStr(vl_Warning, '', 'Replacing double slashes (''//'') to avoid problems on path comparision');
        AVFSPath := StringReplace(AVFSPath, '//', '/', [rfReplaceAll]);
    End;

    AVFSPath := IncPathDelimEx(AVFSPath, '/');

    If (AVFSPath[1] <> '/') Or (Pos('/../', AVFSPath) <> 0) Or (Pos('/./', AVFSPath) <> 0) Then
        OmorphiaErrorStr(vl_Error, '', 'Relative path specifications not allowed.');

    VFSPLen := Length(AVFSPath);

    For X := 0 To FMountpointList.Count - 1 Do
    Begin
        TmpMountPath := FMountpointList.Names[X];
        If Copy(TmpMountPath, 1, VFSPLen) = AVFSPath Then
        Begin
            Delete(TmpMountPath, 1, VFSPLen);
            SlashPos := Pos('/', TmpMountPath);
            If SlashPos <> 0 Then
                TmpMountPath := Copy(TmpMountPath, 1, SlashPos - 1);
            If TmpMountPath <> '' Then
                If AStrings.IndexOf(TmpMountPath) = -1 Then
                    AStrings.Add(TmpMountPath);
        End;
    End;

    Result := AStrings.Count;
End;

Function TOVFSManager.GetMountedPath(APath: String): String;
Var
    I: Integer;
    MP: String;
Begin
    Result := '';

    APath := IncPathDelimEx(APath, '/');

    For I := 0 To FMountpointList.Count - 1 Do
    Begin
        MP := FMountpointList.Names[I];
        If MP = Copy(APath, 1, Length(MP)) Then
        Begin
            Delete(APath, 1, Length(MP));
            Result := IncPathDelimEx(FMountpointList.Values[MP], '/') + APath;
            Exit;
        End;
    End;
End;

Function TOVFSManager.GetParentObject(AnObj: TOVFSObject): TOVFSObject;
Begin
    //  TODO -oBenBE -cVFS, Manager : Implement getting the parent of a VFS Object
    Result := Nil;
End;

Function TOVFSManager.GetVFSRoot: TOVFSObject;
Begin
    If Not Assigned(FOVFSRootObject) Then
    Begin
        FOVFSRootObject := TOVFSRootObject.Create(Self);
        FOVFSRootObject.FPHC := TOVFSProtocolVFS;
    End;

    Result := FOVFSRootObject;
End;

Function TOVFSManager.IsMountpoint(AVFSPath: String): Boolean;
Begin
    Result := FMountpointList.IndexOfName(IncPathDelimEx(AVFSPath, '/')) <> -1;
End;

Function TOVFSManager.Mount(Dest, Source: String): Boolean;
Var
    X: Integer;
    VFSDir: String;
Begin
    //  DONE -oBenBE -cVFS, Manager : #0000088 Mounting of devices and other objects
    Result := False;

    //Check if the Destination path isa pathname within the VFS Protocol
    If GetVFSPathProtocol(Dest) <> TOVFSProtocolVFS.VFSProtocolPrefix Then
        Exit;

    //Skip the protocol specification
    Dest := IncPathDelimEx(GetVFSPathDataPart(Dest), '/');

    //Check for a valid source protool
    If Not IsRegisteredProtocolName(GetVFSPathProtocol(Source)) Then
        Exit;

    //Check if we are re-routing a VFS Path
    If GetVFSPathProtocol(Source) = TOVFSProtocolVFS.VFSProtocolPrefix Then
    Begin
        //Check path relations, to avoid recursions
        If IsInsideDirectory(Dest, GetVFSPathDataPart(Source)) Then
            //The path to be mounted is a subpath of the mountpoint
            //This can't be valid, since then there already exists a mountpoint
            //we would override with this operation
            Exit;

        If IsInsideDirectory(GetVFSPathDataPart(Source), Dest) Then
            //The mountpoint is a subdirectory of the path it should mount
            //This operation is invalid as it allows for infinite mountpoint recursion
            //Which is strongly prohibited by this VFS Version.
            Exit;
    End;

    //Check if the mountpoint is in conflict with another Mountpoint
    For X := 0 To FMountpointList.Count - 1 Do
    Begin
        //Read the stored mountpoint
        VFSDir := FMountpointList.Names[X];

        //Check if Dest is a subdirectory of the mountpoint or vice versa
        If IsInsideDirectory(Dest, VFSDir) Or IsInsideDirectory(VFSDir, Dest) Then
            Exit;
    End;

    //Store the mountpoint to be active ...
    FMountpointList.Values[Dest] := Source;

    //Make changes appear in the root object
    GetVFSRoot.FDirListOK := False;

    //Return success in mounting the specified directory
    Result := True;
End;

Function TOVFSManager.OpenFilesCount: Integer;
Begin
    Result := FOpenFilesList.Count;
End;

Procedure TOVFSManager.SetOnVFSNotify(Const Value: TOnVFSNotifyEvent);
Begin
    FOnVFSNotify := Value;
End;

Function TOVFSManager.Unmount(Dest: String): Boolean;
Begin
    //  TODO -oBenBE -cVFS, Manager : Unmounting of devices and other objects
    Result := False;
End;

{ TOVFSRootObject }

Constructor TOVFSRootObject.Create(AOwner: TOVFSManager);
Begin
    Inherited;
    FFileData := '/';
    FPHC := TOVFSProtocolVFS;
End;

Destructor TOVFSRootObject.Destroy;
Begin

    Inherited;
End;

Function TOVFSRootObject.FileAttributes: DWORD;
Begin
    Result :=
        VFS_ATTRIBUTE_VIRTUAL Or
        VFS_ATTRIBUTE_IS_DIR Or
        VFS_ATTRIBUTE_CAN_LIST Or
        VFS_ATTRIBUTE_CAN_EXECUTE;
End;

Function TOVFSRootObject.FileName: String;
Begin
    Result := '';
End;

Function TOVFSRootObject.FilePath: String;
Begin
    Result := '/';
End;

Function TOVFSRootObject.FilePos: Int64;
Begin
    Result := 0;
End;

Function TOVFSRootObject.FileSize: Int64;
Begin
    Result := 0;
End;

Function TOVFSRootObject.GetPosition: Int64;
Begin
    Result := 0;
End;

Function TOVFSRootObject.GetSize: Int64;
Begin
    Result := 0;
End;

Function TOVFSRootObject.Read(Var Buffer; Count: Int64): Int64;
Begin
    Result := 0;
End;

Function TOVFSRootObject.Seek(Offset: Int64; Origin: Word): Int64;
Begin
    Result := 0;
End;

Procedure TOVFSRootObject.SetPosition(AValue: Int64);
Begin
    Raise Exception.Create(vfsOpNotSupported);
End;

Procedure TOVFSRootObject.SetSize(AValue: Int64);
Begin
    Raise Exception.Create(vfsOpNotSupported);
End;

Function TOVFSRootObject.Write(Const Buffer; Count: Int64): Int64;
Begin
    Result := 0;
End;

Function RegisterVFSProtocol(AVFSProtocolClass: TOVFSProtocolClass): Boolean;
Begin
    OmorphiaDebugStr(vl_Hint, '', Format('Trying to register %s (%s: %s).', [AVFSProtocolClass.ClassName, AVFSProtocolClass.VFSProtocolPrefix, AVFSProtocolClass.VFSProtocolName]));

    Result := False;

    If AVFSProtocolClass = TOVFSProtocol Then
        Exit;

    If Not IsValidProtocolName(AVFSProtocolClass.VFSProtocolPrefix) Then
        Exit;

    If Not Assigned(VFSProtocolClasses) Then
        VFSProtocolClasses := TClassList.Create;

    If IsRegisteredProtocolName(AVFSProtocolClass.VFSProtocolName) Then
        Exit;

    If VFSProtocolClasses.IndexOf(AVFSProtocolClass) = -1 Then
    Begin
        VFSProtocolClasses.Add(AVFSProtocolClass);
        Result := True;
    End;
End;

Function UnregisterVFSProtocol(AVFSProtocolClass: TOVFSProtocolClass): Boolean;
Begin
    OmorphiaDebugStr(vl_Hint, '', Format('Trying to unregister %s (%s: %s).', [AVFSProtocolClass.ClassName, AVFSProtocolClass.VFSProtocolPrefix, AVFSProtocolClass.VFSProtocolName]));

    Result := False;

    If Not Assigned(VFSProtocolClasses) Then
        Exit;

    Result := VFSProtocolClasses.Remove(AVFSProtocolClass) <> -1;
End;

Function IsValidProtocolName(AProtocol: String): Boolean;
Var
    X: Integer;
Begin
    Result := False;

    If AProtocol = '' Then                                                      //Check the length of the string
        Exit;

    If Length(AProtocol) > 8 Then                                               //Check the length of the string
        Exit;

    If Not (AProtocol[1] In Letters) Then                                       //Check if the first char is a letter
        Exit;

    For X := 2 To Length(AProtocol) Do                                          //For each remaining
        If Not (AProtocol[X] In AlphaNumeric) Then                              //Check if it's a alphanumeric signs
            Exit;

    Result := True;
End;

Function IsRegisteredProtocolName(AProtocol: String): Boolean;
Var
    X: Integer;
Begin
    Result := False;

    If Not IsValidProtocolName(AProtocol) Then
        Exit;

    For X := 0 To VFSProtocolClasses.Count - 1 Do
        If TOVFSProtocolClass(VFSProtocolClasses[X]).VFSProtocolPrefix = AProtocol Then
        Begin
            Result := True;
            Exit;
        End;
End;

Function GetVFSProtocolClass(AProtocol: String): TOVFSProtocolClass;
Var
    X: Integer;
Begin
    Result := Nil;

    For X := 0 To VFSProtocolClasses.Count - 1 Do
        If TOVFSProtocolClass(VFSProtocolClasses[X]).VFSProtocolPrefix = AProtocol Then
        Begin
            Result := TOVFSProtocolClass(VFSProtocolClasses[X]);
            Exit;
        End;
End;

Function GetProtocolCount: Integer;
Begin
    Result := 0;

    If Not Assigned(VFSProtocolClasses) Then
        Exit;

    Result := VFSProtocolClasses.Count;
End;

Function GetProtocolByIndex(Index: Integer): TOVFSProtocolClass;
Begin
    Result := Nil;

    If Not Assigned(VFSProtocolClasses) Then
        Exit;

    If Index < 0 Then
        Exit;

    If Index >= VFSProtocolClasses.Count Then
        Exit;

    Result := TOVFSProtocolClass(VFSProtocolClasses[Index]);
End;

Function RegisterVFSHandler(AVFSHandlerClass: TOVFSHandlerClass): Boolean;
Begin
    OmorphiaDebugStr(vl_Hint, '', Format('Trying to register %s (%s: %s).', [AVFSHandlerClass.ClassName, AVFSHandlerClass.VFSHandlerID, AVFSHandlerClass.VFSHandlerName]));

    Result := False;

    If AVFSHandlerClass = TOVFSHandler Then
        Exit;

    If Not IsValidHandlerName(AVFSHandlerClass.VFSHandlerID) Then
        Exit;

    If Not Assigned(VFSHandlerClasses) Then
        VFSHandlerClasses := TClassList.Create;

    If IsRegisteredHandlerName(AVFSHandlerClass.VFSHandlerID) Then
        Exit;

    If VFSHandlerClasses.IndexOf(AVFSHandlerClass) = -1 Then
    Begin
        VFSHandlerClasses.Add(AVFSHandlerClass);
        Result := True;
    End;
End;

Function UnregisterVFSHandler(AVFSHandlerClass: TOVFSHandlerClass): Boolean;
Begin
    OmorphiaDebugStr(vl_Hint, '', Format('Trying to unregister %s (%s: %s).', [AVFSHandlerClass.ClassName, AVFSHandlerClass.VFSHandlerID, AVFSHandlerClass.VFSHandlerName]));

    Result := False;

    If Not Assigned(VFSHandlerClasses) Then
        Exit;

    Result := VFSHandlerClasses.Remove(AVFSHandlerClass) <> -1;
End;

Function IsValidHandlerName(AHandler: String): Boolean;
Var
    X: Integer;
Begin
    Result := False;

    If AHandler = '' Then                                                       //Check the length of the string
        Exit;

    If Length(AHandler) > 8 Then                                                //Check the length of the string
        Exit;

    If Not (AHandler[1] In Letters) Then                                        //Check if the first char is a letter
        Exit;

    For X := 2 To Length(AHandler) Do                                           //For each remaining
        If Not (AHandler[X] In AlphaNumeric) Then                               //Check if it's a alphanumeric signs
            Exit;

    Result := True;
End;

Function IsRegisteredHandlerName(AHandler: String): Boolean;
Var
    X: Integer;
Begin
    Result := False;

    If Not IsValidHandlerName(AHandler) Then
        Exit;

    For X := 0 To VFSHandlerClasses.Count - 1 Do
        If TOVFSHandlerClass(VFSHandlerClasses[X]).VFSHandlerID = AHandler Then
        Begin
            Result := True;
            Exit;
        End;
End;

Function GetVFSHandlerClass(AHandler: String): TOVFSHandlerClass;
Var
    X: Integer;
Begin
    Result := Nil;

    For X := 0 To VFSHandlerClasses.Count - 1 Do
        If TOVFSHandlerClass(VFSHandlerClasses[X]).VFSHandlerID = AHandler Then
        Begin
            Result := TOVFSHandlerClass(VFSHandlerClasses[X]);
            Exit;
        End;
End;

Function GetHandlerCount: Integer;
Begin
    Result := 0;

    If Not Assigned(VFSHandlerClasses) Then
        Exit;

    Result := VFSHandlerClasses.Count;
End;

Function GetHandlerByIndex(Index: Integer): TOVFSHandlerClass;
Begin
    Result := Nil;

    If Not Assigned(VFSHandlerClasses) Then
        Exit;

    If Index < 0 Then
        Exit;

    If Index >= VFSHandlerClasses.Count Then
        Exit;

    Result := TOVFSHandlerClass(VFSHandlerClasses[Index]);
End;

{ TOVFSProtocol }

Class Function TOVFSProtocol.GetVFSManager(AObj: TOVFSObject): TOVFSManager;
Begin
    Result := AObj.Owner;
End;

Class Procedure TOVFSProtocol.SetDataSourceObject(AObj: TOVFSObject; ADataSrcObj: TOVFSStream);
Begin
    AObj.FDataSrcObj := ADataSrcObj;
End;

Class Procedure TOVFSProtocol.SetVFSManager(AObj: TOVFSObject; AManager: TOVFSManager);
Begin
    AObj.FOwner := AManager;
End;

{ TOVFSHandler }

Class Function TOVFSHandler.GetVFSManager(AObj: TOVFSObject): TOVFSManager;
Begin
    Result := AObj.Owner;
End;

Class Procedure TOVFSHandler.SetDataSourceObject(AObj: TOVFSObject;
    ADataSrcObj: TOVFSStream);
Begin
    AObj.FDataSrcObj := ADataSrcObj;
End;

Class Procedure TOVFSHandler.SetVFSManager(AObj: TOVFSObject;
    AManager: TOVFSManager);
Begin
    AObj.FOwner := AManager;
End;

Initialization
    VFSLastError := 0;

    If Not Assigned(VFSProtocolClasses) Then
        VFSProtocolClasses := TClassList.Create;

    If Not Assigned(VFSHandlerClasses) Then
        VFSHandlerClasses := TClassList.Create;

    If Not Assigned(VFSManager) Then
        VFSManager := TOVFSManager.Create;
Finalization
    If Assigned(VFSManager) Then
        FreeAndNil(VFSManager);

    If Assigned(VFSHandlerClasses) Then
        FreeAndNil(VFSHandlerClasses);

    If Assigned(VFSProtocolClasses) Then
        FreeAndNil(VFSProtocolClasses);
End.

