Unit OVFSDataSrcTAR;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Virtual File System Submodule
//
// This unit defines the standard access protocolls of the VFS to access the
// native file system of Windows and the VFS of Omorphia.
//
// *****************************************************************************
// To Do:
//  TODO -oBenBE -cVFS, Protocol : Implement the VFS Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the Unix Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the MMF Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the TCP Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the UDP Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the HTTP Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the HTTPS Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the FTP Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the UNC Protocol Handler
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
    TOVFSHandlerTAR = Class(TOVFSHandler)
    Public
        Class Function VFSHandlerID: String; Override;
        Class Function VFSHandlerName: String; Override;
        Class Function GetDirectory(AObj: TOVFSObject; AData: String; AStrings: TStrings): Integer; Override;
        Class Function GetStreamObject(AObj: TOVFSObject; AData: String; AAccess: DWORD): TOVFSStream; Override;
        Class Function GetAttributes(AObj: TOVFSObject; AData: String): DWORD; Override;
        Class Function GetRawObject(AObj: TOVFSObject; AData: String): TOVFSObject; Override;
        Class Function IsVFSHandlerSupported(AObj: TOVFSObject): Boolean; Override;
    End;

Implementation

Uses
    ODbgInterface;

Const
    TAR_BlockSize = 512;
    TAR_HeaderSize = TAR_BlockSize;
    TAR_FilenameLength = 100;
    TAR_MLEN = 32;
    TAR_UsernameMLEN = TAR_MLEN;
    TAR_GroupnameMLEN = TAR_MLEN;

Const
    TAR_MAGIC_USTAR = 'ustar'#32#32#0;
    TAR_MAGIC_GNUTAR = 'GNUtar'#32#0;

Const
    // The linkflag defines the type of file
    TAR_LINKFLAG_OLDNORMAL = #0;                                                // Normal disk file, Unix compatible
    TAR_LINKFLAG_NORMAL = '0';                                                  // Normal disk file
    TAR_LINKFLAG_LINK = '1';                                                    // Link to previously dumped file
    TAR_LINKFLAG_SYMLINK = '2';                                                 // Symbolic link
    TAR_LINKFLAG_CHARDEVICE = '3';                                              // Character special file
    TAR_LINKFLAG_BLOCKDEVICE = '4';                                             // Block special file
    TAR_LINKFLAG_DIR = '5';                                                     // Directory
    TAR_LINKFLAG_FIFO = '6';                                                    // FIFO special file
    TAR_LINKFLAG_CONTIGNIOUS = '7';                                             // Contiguous file

Type
    TTARHeader = Packed Record
        Case Boolean Of
            False: (
                Header: Array[0..TAR_HeaderSize - 1] Of Char;
                );
            True: (
                FileName: Array[0..TAR_FilenameLength - 1] Of Char;
                FileMode: Array[0..7] Of Char;
                FileUID: Array[0..7] Of Char;
                FileGID: Array[0..7] Of Char;
                FileSize: Array[0..11] Of Char;
                FileMTime: Array[0..11] Of Char;
                FileChecksum: Array[0..7] Of Char;
                LinkFlag: Char;
                LinkName: Array[0..TAR_FilenameLength - 1] Of Char;
                Magic: Array[0..7] Of Char;
                UserName: Array[0..TAR_UsernameMLEN - 1] Of Char;
                GroupName: Array[0..TAR_GroupnameMLEN - 1] Of Char;
                DevMajor: Array[0..7] Of Char;
                DevMinor: Array[0..7] Of Char;
                );
    End;

    { TOVFSHandlerTAR }

Class Function TOVFSHandlerTAR.GetAttributes(AObj: TOVFSObject; AData: String): DWORD;
Begin
    Result :=
        VFS_ATTRIBUTE_ARCHIVED Or
        VFS_ATTRIBUTE_CAN_LIST Or
        VFS_ATTRIBUTE_CAN_READ Or
        VFS_ATTRIBUTE_VIRTUAL;
End;

Class Function TOVFSHandlerTAR.GetDirectory(AObj: TOVFSObject; AData: String; AStrings: TStrings): Integer;
Var
    VFSData: TOVFSStream;
    VFSObj: TOVFSObject;
    X: Integer;

    I: Integer;
    DH: TOVFSHandlerClass;
Begin
    Result := -1;

    If Not Assigned(AObj) Then
        OmorphiaErrorStr(vl_Error, '', 'The supplied VFS Object is not assigned or nil');

    If Not Assigned(AStrings) Then
        OmorphiaErrorStr(vl_Error, '', 'Result buffer not assigned.');
        
    VFSData := AObj.DataSrcObj;

    If Not Assigned(VFSData) Then
        OmorphiaErrorStr(vl_Error, '', 'The supplied VFS Object doesn''t have an data stream assigned to it');

//    If not (VFSData is TOVFSObject_TAR) Then
//        OmorphiaErrorStr(vl_Error, '', 'The Data Source for this object needs to be an VFS TAR Object.');
        
    // TODO -oBenBE, matze -cVFS, Protocol, VFS : Return a directory listing

    If Not (AObj.DataSrcObj Is TOVFSObject) Then
        Exit;

    VFSObj := TOVFSObject(AObj.DataSrcObj);
    
End;

Class Function TOVFSHandlerTAR.GetRawObject(AObj: TOVFSObject; AData: String): TOVFSObject;
Begin
    Result := Nil;
End;

Class Function TOVFSHandlerTAR.GetStreamObject(AObj: TOVFSObject; AData: String; AAccess: DWORD): TOVFSStream;
Begin
    Result := Nil;
End;

Class Function TOVFSHandlerTAR.IsVFSHandlerSupported(AObj: TOVFSObject): Boolean;
Begin
    // TODO -oBenBE -cVFS, Handler, TAR : Improve this check ;-)
    Result :=
        (AObj.FileSize > TAR_BlockSize) And
        (ExtractFileExt(AObj.FileName) = '.tar');
End;

Class Function TOVFSHandlerTAR.VFSHandlerID: String;
Begin
    Result := 'TAR';
End;

Class Function TOVFSHandlerTAR.VFSHandlerName: String;
Begin
    Result := 'TAR Archive Handling';
End;

Initialization
    RegisterVFSHandler(TOVFSHandlerTAR);
Finalization
    UnregisterVFSHandler(TOVFSHandlerTAR);
End.

