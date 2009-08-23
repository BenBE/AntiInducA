Unit OVFSPathUtils;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Virtual File System Submodule
//
// This unit defines the basic types and objects for interaction with real
// devices, virtual mountpoints and other data access points.
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
//
// *****************************************************************************

// Include the Compiler Version and Options Settings
{$I 'Omorphia.config.inc'}

Interface

Uses
    Windows,
    SysUtils,
    Classes;

// Neo: replace an OS spezific delim, the result has at end also delim
Function IncPathDelim(APath: String): String;

//BenBE: Extended IncPathDelim-Function with customizable path delimiter
Function IncPathDelimEx(APath: String; Delim: Char = '/'): String;

//BenBE: Changes the delimiters of a path to the given format
Function TransformPathDelims(APath: String; Delim: Char = '/'): String;

//BenBE: Get the long path version of a short pathname
Function GetLongPath(AName: String): String;

//Neo: Search for a file with the given name and extension in the specified search path
Function SearchPath(APath, AFileName, AExtension: PChar; ABufferLength: DWORD; ABuffer: PChar; Var AFilePart: PChar): DWORD;

// Neo: get a Path from a given file, this include the system Path var
Function GetPathFromFile(AFileName: String): String; overload;
Function GetPathFromFile(AFileName: String; APath: String): String; overload;

// BenBE: Extract the file path out of a filepath
Function GetFileDirectory(APath: String): String;

// BenBE: Get the protocoll spec of a path
Function GetVFSPathProtocol(APath: String): String;

// BenBE: Get the protocoll data part of a path
Function GetVFSPathDataPart(APath: String): String;

// BenBE: Check if a path ends in / or \
Function IsIncPathDelim(APath: String): Boolean;

// BenBE: Check if a path is inside a directory
Function IsInsideDirectory(AMainDir: String; ASubDir: String): Boolean;

// BenBE: Get a string containing the attribute mask of a VFS File
Function VFSAttributesToMaskString(AAttributes: DWORD): String;

Implementation

Uses
    ODbgInterface,
    OIncProcs,
    OIncTypes,
    OVFSManager;

Function SearchPath; External Kernel32 Name 'SearchPathA';

Function IncPathDelim(APath: String): String;
Const
    {$IFDEF WIN32}
    Slash: Char = '\';
    {$ELSE}
    Slash: Char = '/';
    {$ENDIF}
Begin
    Result := IncPathDelimEx(APath, Slash);
End;

Function IncPathDelimEx(APath: String; Delim: Char = '/'): String;
Begin
    If Length(APath) = 0 Then
    Begin
        Result := Delim;
        Exit;
    End;

    Result := TransformPathDelims(APath, Delim);

    If Result[Length(Result)] <> Delim Then
        Result := Result + Delim;
End;

Function TransformPathDelims(APath: String; Delim: Char = '/'): String;
Begin
    Result := APath;
    If Delim <> '\' Then
        Result := StringReplace(APath, '\', Delim, [rfReplaceAll]);
    If Delim <> '/' Then
        Result := StringReplace(Result, '/', Delim, [rfReplaceAll]);
End;

Function InternalGetLongPathName(ShortPath, LongPath: LPCTSTR; Size: DWORD): DWORD; Stdcall; External Kernel32 Name 'GetLongPathNameA';

Function GetLongPath(AName: String): String;
Var
    S: PChar;
    Len: Integer;
Begin
    DbgResetOSError;
    S := AllocMem(MAX_PATH);
    Try
        StrPCopy(S, AName);
        Len := InternalGetLongPathName(S, S, MAX_PATH);
        If Len > MAX_PATH Then
        Begin
            ReallocMem(S, Len);
            InternalGetLongPathName(S, S, Len);
        End;
        If GetLastError <> 0 Then
            S := PChar(AName);
        Result := S;
    Finally
        FreeMem(S);
    End;
End;

Function GetPathFromFile(AFileName: String): String;
Begin
    Result := GetPathFromFile(AFileName, GetEnvVarValue('Path'));
End;

Function GetPathFromFile(AFileName: String; APath: String): String;
Var
    Line: String;
    CPos: Integer;
    Temp: String;
Begin
    // DONE -oNeo@BenBE -cGetPathFromFile : Complete implementation of GetPathFromFile
    // Neo: result only the given FileName if not found in path env
    Result := AFileName;
    // Neo: get path env
    Line := APath;
    While Length(Line) <> 0 Do
    Begin
        // Neo: find pos of next / first ';'
        CPos := Pos(';', Line) - 1;
        // Neo: if no more ';' found set to length
        If CPos < 1 Then
            CPos := Length(Line) + 1;
        // Neo: get path with \ at end
        Temp := IncPathDelim(Copy(Line, 1, CPos - 1));
        // Neo: cut of path from start
        Line := Copy(Line, CPos + 1, Length(Line) - CPos);
        // Neo: check if file exists
        If FileExists(Temp + AFileName) Then
        Begin
            // Neo: yes, we found it!
            Result := Temp + AFileName;
            Exit;
        End;
    End;
End;

Function GetFileDirectory(APath: String): String;
Var
    X, LastPos, Len: Integer;
Begin
    LastPos := 0;
    Len := Length(APath);

    If Len = 0 Then
    Begin
        Result := '/';
        Exit;
    End;

    If APath[Len] In ['/', '\'] Then
        Dec(Len);

    X := Len;
    While X > 0 Do
    Begin
        If APath[X] In ['/', '\'] Then
        Begin
            LastPos := X;
            Break;
        End;
        Dec(X);
    End;

    If LastPos = 0 Then
        LastPos := Len + 1;

    Result := Copy(APath, 1, LastPos - 1);
End;

Function GetVFSPathProtocol(APath: String): String;
Var
    ProtocolPos: Integer;
Begin
    Result := 'vfs';                                                            //Default to 'vfs' as protocoll

    APath := Trim(APath);                                                       //Eliminate all blanks at the beginning or end of the path

    If Length(APath) = 0 Then                                                   //If Blank path --> Exit
        Exit;

    If APath[1] = '/' Then                                                      //If first char is '/' --> Exit (it's an absolute VFS Path)
        Exit;

    ProtocolPos := Pos(':', APath) - 1;                                         //Look for the protocoll seperator ':'

    If ProtocolPos = 0 Then                                                     //If none found --> Exit
        Exit;

    If ProtocolPos >= 9 Then                                                    //If found to late in the string --> Exit
        Exit;

    Result := LowerCase(Copy(APath, 1, ProtocolPos));                           //Return the protocoll ident

    If Not IsValidProtocolName(Result) Then
        Result := 'vfs';
End;

Function GetVFSPathDataPart(APath: String): String;
Var
    ProtocolPos: Integer;
Begin
    Result := APath;                                                            //Return the Path itself as default

    If Length(APath) = 0 Then                                                   //If Blank path --> Exit
        Exit;

    If APath[1] = '/' Then                                                      //If first char is '/' --> Exit (it's an absolute VFS Path)
        Exit;

    ProtocolPos := Pos(':', APath) - 1;                                         //Look for the protocoll seperator ':'

    If ProtocolPos = 0 Then                                                     //If none found --> Exit
        Exit;

    If ProtocolPos >= 9 Then                                                    //If found to late in the string --> Exit
        Exit;

    Result := Copy(APath, ProtocolPos + 2, Length(APath) - ProtocolPos - 1);    //Return the protocoll ident
End;

Function IsIncPathDelim(APath: String): Boolean;
Begin
    //DONE -oBenBE -cVFS, Path : Sicherheitsabfrage auf leeren Pfadnamen

    Result := False;

    If APath = '' Then
        Exit;

    Result := APath[Length(APath)] In ['/', '\'];
End;

Function IsInsideDirectory(AMainDir: String; ASubDir: String): Boolean;
Begin
    AMainDir := LowerCase(TransformPathDelims(AMainDir));
    ASubDir := LowerCase(TransformPathDelims(ASubDir));

    Result := AMainDir = Copy(ASubDir, 1, Length(AMainDir));
End;

Function VFSAttributesToMaskString(AAttributes: DWORD): String;
Const
    AttributeMasks: Array[1..16] Of DWORD = (
        VFS_ATTRIBUTE_IS_DIR,                                                   //D object is a directory (container)
        VFS_ATTRIBUTE_IS_FILE,                                                  //F object is a file (stream)
        VFS_ATTRIBUTE_ARCHIVED,                                                 //A attribute "archived"
        VFS_ATTRIBUTE_HIDDEN,                                                   //H attribute "hidden"
        VFS_ATTRIBUTE_CAN_READ,                                                 //R File can be read
        VFS_ATTRIBUTE_CAN_WRITE,                                                //W File can be written
        VFS_ATTRIBUTE_SYSTEM,                                                   //S attribute "system"
        VFS_ATTRIBUTE_VIRTUAL,                                                  //V Object is a virtual object
        VFS_ATTRIBUTE_COMPRESSED,                                               //C File is compressed
        VFS_ATTRIBUTE_ENCRYPTED,                                                //E File is encrypted
        VFS_ATTRIBUTE_OFFLINE,                                                  //O File is an offline storage object
        VFS_ATTRIBUTE_TEMPORARY,                                                //T attribute "temporary"
        VFS_ATTRIBUTE_QUOTA,                                                    //Q There's a disk quota on this object
        VFS_ATTRIBUTE_CAN_LIST,                                                 //L A directory listing is available
        VFS_ATTRIBUTE_CAN_EXECUTE,                                              //X User can execute this object
        VFS_ATTRIBUTE_CAN_SEEK                                                  //J File allows seeking inside the stream
        );
    AttributeSigns: Array[1..16] Of Char = 'DFAHRWSVCEOTQLXJ';
Var
    X: Integer;
Begin
    Result := StringOfChar('-', Length(AttributeSigns));
    For X := Low(AttributeSigns) To High(AttributeSigns) Do
    Begin
        If AAttributes And AttributeMasks[X] <> 0 Then
            Result[X] := AttributeSigns[X];
    End;
End;

End.
