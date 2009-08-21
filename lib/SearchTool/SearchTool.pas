unit SearchTool;

/////////////////////////////////////////////////////////////////////
//                                                                 //
//                           SearchTool                            //
//                         Version: 3.0.1.1                        //
//                                                                 //
//       Ich bedanke mich bei allen, die bei der Entwicklung       //
//   dieser Unit geholfen haben (durch Problemlösungsideen etc.)   //
//                                                                 //
//                                                                 //
//                                                                 //
//                                                                 //
//                Copyright © 2005-2006 Heiko Thiel                //
//                                                                 //
/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
//                                                                 //
// Lizenz                                                          //
//                                                                 //
// Sie dürfen diese Unit nach belieben modifizieren und benutzten, //
// unter der Bedienung, dass  eine Erwähnung der Unit inkl. Autor  //
// innerhalb des Programms erfolgt, wenn die Unit in irgendeiner   //
// Art und Weise benutzt wird     .                                //
//                                                                 //
/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
//                                                                 //
// Chronik                                                         //
//                                                                 //
// Version 3.0.1.1 (26.10.07)                                      //
//     - FIX: Unnötige CriticalSection entfernt                    // 
//                                                                 //
// Version 3.0.1 (23.06.07)                                        //
//     - FIX: Hat man im ST-Finishereignis (SendMessage) die       //
//            Suche gestartet, so endete das in einem Deadlock     //
//                                                                 //
// Version 3.0 (17.02.07)                                          //
//     - Filter erlaubt nun wieder Platzhalter (*)                 //
//     - FIX: Abbrechen verursachte Deadlock                       //
//     - CHANGE: SearchFiles wartet bei einem extra Therad nicht   //
//               mehr auf das Ende des Threads                     //
//                                                                 //
// Version 3.0  Alpha2 (28.05.06):                                 //
//     - Filtereinstellungen verbessert (Filter werden nicht mehr  //
//       als Array übergeben, sondern als String (durch ; getrennt)//
//     - SearchTool in einen Thread ausgelagert (aber auschaltbar) //
//     - Win95, 98 und ME- Kompatibilität wieder hergestellt       //
//                                                                 //
// Version 3.0  Alpha (28.05.06):                                  //
//     - UniCode-Unterstützung (Filter erst einmal wieder nur für  //
//                              Dateiendungen)                     //
//                                                                 //
// Versionen 2.0.1 - 2.0.3 (Okt. '05)                              //
//      - Filterfixes                                              //
//                                                                 //
// Version 2.0 (22.10.05):                                         //
//     - Arbeitsplatz-Bezeichnung aus dem System  auslesen         //
//     - Filter erlaubt Platzhalter (*)                            //
//                                                                 //
// Version 1.0 (24.09.05):                                         //
//     - Erstes Release                                            //
//                                                                 //
/////////////////////////////////////////////////////////////////////

interface

uses  Windows, Forms, Messages, ShlObj, SysUtils, ActiveX;

const
  ST_Start      = WM_User + 1500; //keine Parameter
  ST_CurrentDir = WM_User + 1501; //wParam = nicht benutzt; lParam=aktueller Ordner
  ST_NewFile    = WM_User + 1502; //wParam = Anzahl bisher gefundener Dateien; lParam=gefundene Datei
  ST_NewDir     = WM_User + 1503; //wParam = Anzahl bisher gefundener Ordner; lParam=gefundene Ordner
  ST_Finish     = WM_User + 1504; //keine Parameter

type
  MessageKind = (mkNoneMessage=$10000001, mkPostMessage, mkSendMessage);

  TWStrArr = array of WideString;

  TSearchTool = class
    private
      FFiles            : TWStrArr;
      FFilesCount       : Integer;
      FSaveFilesMemSize : Integer;

      FDirs             : TWStrArr;
      FDirsCount        : Integer;
      FSaveDirsMemSize  : Integer;

      FCurrentDir       : WideString;

      FMask             : WideString;
      FMaskA            : AnsiString; //Ansi-Variante von FFileMask, damit Delphi nicht ständig konvertieren muss

      FStartTime        : Cardinal;
      FSearchDuration   : Cardinal;
      FIsSearching      : LongBool;

      FBreak            : LongBool;
      FThread           : Integer ;

      FListFiles  : LongBool   ;
      FListDirs   : LongBool   ;
      FRecurse    : LongBool   ;
      FMHandle    : THandle    ;
      FMSystem    : MessageKind;
      FMCurrentDir: MessageKind;
      FMFound     : MessageKind;

      FExtraThread: Boolean;

      procedure CreateSystemMessage (const Msg: Cardinal; const wParam, lParam: Integer);
      procedure CreateCurrentDirMessage(const wParam, lParam: Integer);
      procedure CreateFoundMessage  (const Msg: Cardinal; const wParam, lParam: Integer);

      procedure NewFile(lPm: Integer);
      procedure NewDir(lPm: Integer);
      procedure ChangeDir(NewDir: WideString);

      procedure AddDir(const Dir: WideString);
      procedure AddFile(const FileName: WideString);

      procedure GetFilesA(Root: AnsiString);
      procedure GetFilesW(Root: WideString);

      procedure SearchFilesA(const Root: AnsiString);
      procedure SearchFilesW(const Root: WideString);

      procedure StartSearch;

      function NameOfMyComputer: WideString;
      function GetDuration: Cardinal;
      function GetCurrentDir: WideString;

      function GetFilesCount : Integer;
      function GetDirsCount : Integer;

      function GetListFiles  : LongBool;
      function GetListDirs   : LongBool;
      function GetRecurse    : LongBool;
      function GetMHandle    : THandle ;
      function GetMSystem    : MessageKind;
      function GetMCurrentDir: MessageKind;
      function GetMFound     : MessageKind;

      procedure SetMask       (Value: WideString);
      procedure SetListFiles  (Value: LongBool);
      procedure SetListDirs   (Value: LongBool);
      procedure SetRecurse    (Value: LongBool);
      procedure SetMHandle    (Value: THandle);
      procedure SetMSystem    (Value: MessageKind);
      procedure SetMCurrentDir(Value: MessageKind);
      procedure SetMFound     (Value: MessageKind);

    public
      constructor Create ;
      destructor  Destroy; override;

      function ResetData: Boolean;
      procedure SearchFiles(const RootFolder: WideString; const ExtraThread: Boolean = true); overload;
      procedure SearchFiles(const RootFolder: WideString; const Mask: WideString;
                            const Recurse: Boolean = false; const ExtraThread: Boolean = true); overload;
      procedure Break;

      property Mask          : WideString  read FMask write SetMask;

      property Files         : TWStrArr    read FFiles       ;
      property FilesCount    : Integer     read GetFilesCount;

      property Dirs          : TWStrArr    read FDirs        ;
      property DirsCount     : Integer     read GetDirsCount ;

      property CurrentDir    : WideString  read GetCurrentDir;
      property SearchDuration: Cardinal    read GetDuration ;
      property IsSearching   : LongBool    read FIsSearching;

      property ListFiles     : LongBool    read GetListFiles   write SetListFiles  ;
      property ListDirs      : LongBool    read GetListDirs    write SetListDirs   ;
      property Recurse       : LongBool    read GetRecurse     write SetRecurse    ;
      property MHandle       : THandle     read GetMHandle     write SetMHandle    ;
      property MSystem       : MessageKind read GetMSystem     write SetMSystem    ;
      property MCurrentDir   : MessageKind read GetMCurrentDir write SetMCurrentDir;
      property MFound        : MessageKind read GetMFound      write SetMFound     ;
  end;

var
  UniCodeSupport: Boolean;

  function PathMatchSpecA(pszFile, pszSpec: PAnsiChar): Boolean; stdcall;
  function PathMatchSpecW(pszFile, pszSpec: PWideChar): Boolean; stdcall;

implementation

  function PathMatchSpecA(pszFile, pszSpec: PAnsiChar): Boolean; external 'shlwapi.dll';
  function PathMatchSpecW(pszFile, pszSpec: PWideChar): Boolean; external 'shlwapi.dll';

{******************************************************************************}
{* Private methods                                                            *}
{******************************************************************************}

procedure TSearchTool.CreateFoundMessage(const Msg: Cardinal; const wParam, lParam: Integer);
begin
  if FMHandle = 0 then exit;  
  case FMFound of
    mkPostMessage: PostMessage(FMHandle, Msg, wParam, lParam);
    mkSendMessage: SendMessage(FMHandle, Msg, wParam, lParam);
  end
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.CreateCurrentDirMessage(const wParam, lParam: Integer);
begin
  if FMHandle = 0 then exit;
  case FMCurrentDir of
    mkPostMessage: PostMessage(FMHandle, ST_CurrentDir, wParam, lParam);
    mkSendMessage: SendMessage(FMHandle, ST_CurrentDir, wParam, lParam);
  end
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.CreateSystemMessage(const Msg: Cardinal; const wParam, lParam: Integer);
begin
  if FMHandle = 0 then exit;
  case FMSystem of
    mkPostMessage: PostMessage(FMHandle, Msg, wParam, lParam);
    mkSendMessage: SendMessage(FMHandle, Msg, wParam, lParam);
  end
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.NewFile(lPm: Integer);
begin
  if FMHandle = 0 then exit;
  if (FMFound = mkPostMessage) and (not FListFiles) then lPm:=0;
  CreateFoundMessage(ST_NewFile, wParam(FFilesCount), lPm)
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.NewDir(lPm: Integer);
begin
  if FMHandle = 0 then exit;
  if (FMFound = mkPostMessage) and (not FListDirs) then lPm:=0;
  CreateFoundMessage(ST_NewDir, wParam(FDirsCount), lPm)
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.ChangeDir(NewDir: WideString);
begin
  FCurrentDir:=NewDir;
  CreateCurrentDirMessage(0, lParam(PWideChar(FCurrentDir)));
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.AddDir(const Dir: WideString);
begin
  if FListDirs then
  begin
    if FDirsCount = FSaveDirsMemSize then
    begin
      FSaveDirsMemSize:=FSaveDirsMemSize shl 1;
      SetLength(FDirs, FSaveDirsMemSize);
    end;
    FDirs[FDirsCount]:=Dir;
    NewDir(lParam(PWideChar(FDirs[FDirsCount])));
    inc(FDirsCount);
  end
  else NewDir(lParam(PWideChar(Dir)));
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.AddFile(const FileName: WideString);
begin
  if FListFiles then
  begin
    if FFilesCount = FSaveFilesMemSize then
    begin
      FSaveFilesMemSize:=FSaveFilesMemSize shl 1;
      SetLength(FFiles, FSaveFilesMemSize);
    end;
    FFiles[FFilesCount]:=FileName;
    NewFile(lParam(PWideChar(FFiles[FFilesCount])));
    inc(FFilesCount);
  end
  else NewFile(lParam(FileName));
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.GetFilesA(Root: AnsiString);
var
  wfd      : TWin32FindDataA;
  HFindFile: THandle        ;
  FileName : AnsiString     ;
  NextDir  : AnsiString     ;
begin
  if not FBreak then
  begin
    ZeroMemory(@wfd, SizeOf(wfd));
    HFindFile:=FindFirstFileA(PAnsiChar(Root+'*'), wfd);
    if not ((HFindFile=0) or (HFindFile = INVALID_HANDLE_VALUE)) then
    begin
      try
        repeat
          if (wfd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then
          begin
            if not ((AnsiString(wfd.cFileName) = '.') or (AnsiString(wfd.cFileName) = '..')) then
            begin
              FileName := Root+wfd.cFileName;
              if PathMatchSpecA(PAnsiChar(FileName), PAnsiChar(FMaskA)) then AddDir(FileName);
              if FRecurse then
              begin
                NextDir:=Root+wfd.cFileName+AnsiChar('\');
                ChangeDir(NextDir);
                GetFilesA(NextDir);
                ChangeDir(Root);
              end
            end
          end
          else
          begin
            FileName:=Root+wfd.cFileName;
            if PathMatchSpecA(PAnsiChar(FileName), PAnsiChar(FMaskA)) then AddFile(Root+wfd.cFileName)
          end;
        until (not FindNextFileA(HFindFile, wfd)) or FBreak
      finally
        Windows.FindClose(HFindFile)
      end
    end
  end
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.GetFilesW(Root: WideString);
var
  wfd      : TWin32FindDataW;
  HFindFile: THandle        ;
  FileName : WideString     ;
  NextDir  : WideString     ;
begin
  ChangeDir(Root);
  if not FBreak then
  begin
    ZeroMemory(@wfd, SizeOf(wfd));
    HFindFile:=FindFirstFileW(PWideChar(Root+'*'), wfd);
    if not ((HFindFile=0) or (HFindFile = INVALID_HANDLE_VALUE)) then
    begin
      try
        repeat
          if (wfd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then
          begin
            if not ((WideString(wfd.cFileName)='.') or (WideString(wfd.cFileName)='..')) then
            begin
              FileName:=Root+wfd.cFileName;
              if PathMatchSpecW(PWideChar(FileName), PWideChar(FMask)) then AddDir(FileName);
              if FRecurse then        
              begin
                NextDir:=Root+wfd.cFileName+WideChar('\');
                ChangeDir(NextDir);
                GetFilesW(NextDir);
                ChangeDir(Root);
              end;
            end;
          end
          else
          begin
            FileName:=Root+wfd.cFileName;
            if PathMatchSpecW(PWideChar(FileName), PWideChar(FMask)) then AddFile(Root+wfd.cFileName)
          end;
        until (not FindNextFileW(HFindFile, wfd)) or FBreak
      finally
        Windows.FindClose(HFindFile)
      end
    end
  end
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SearchFilesA(const Root: AnsiString);
var
  DrStrLen: Cardinal;
  DrStr   : AnsiString;
  CrDrStr : PAnsiChar;
  CrDrLen : Integer;

  DirEx   : Cardinal;
  Dw1, Dw2: Cardinal;
begin
  if Root = AnsiString(NameOfMyComputer) + '\' then
  begin
    DrStrLen := GetLogicalDriveStringsA(0, nil);
    SetLength(DrStr, DrStrLen);
    if GetLogicalDriveStringsA(DrStrLen, @DrStr[1])=DrStrLen-1 then
    begin
      CrDrStr:=PAnsiChar(DrStr);
      while (not FBreak) and (CrDrStr[0] <> #0) do
      begin
        ChangeDir(AnsiString(CrDrStr));
        if PathMatchSpecA(CrDrStr, PAnsiChar(FMaskA)) then AddDir(AnsiString(CrDrStr));
        CrDrLen:=lstrlenA(CrDrStr);
        if FRecurse and GetVolumeInformationA(CrDrStr, nil, 0, nil, DW1, DW2, nil, 0) then GetFilesA(CrDrStr);
        inc(CrDrStr, CrDrLen+1)
      end
    end
  end
  else
  begin
    DirEx:=GetFileAttributesA(PAnsiChar(Root)); //DirectoryExists
    if (DirEx<>DWord(-1)) and (FILE_ATTRIBUTE_DIRECTORY and DirEx=FILE_ATTRIBUTE_DIRECTORY) then
    begin
      GetFilesA(Root);
    end
  end
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SearchFilesW(const Root: WideString);
var
  DrStrLen: Cardinal;
  DrStr   : WideString;
  CrDrStr : PWideChar;
  CrDrLen : Integer;

  DirEx   : Cardinal;
  Dw1, Dw2: Cardinal;
begin
  if Root = NameOfMyComputer + '\' then
  begin
    DrStrLen := GetLogicalDriveStringsW(0, nil);
    SetLength(DrStr, DrStrLen);
    if GetLogicalDriveStringsW(DrStrLen, @DrStr[1])=DrStrLen-1 then
    begin
      CrDrStr:=PWideChar(DrStr);
      while (not FBreak) and (CrDrStr[0] <> #0) do
      begin
        ChangeDir(CrDrStr);
        if PathMatchSpecW(CrDrStr, PWideChar(FMask)) then AddDir(CrDrStr);
        CrDrLen:=lstrlenW(CrDrStr);
        if FRecurse and GetVolumeInformationW(CrDrStr, nil, 0, nil, DW1, DW2, nil, 0) then GetFilesW(CrDrStr);
        inc(CrDrStr, CrDrLen+1)
      end
    end
  end
  else
  begin
    DirEx:=GetFileAttributesW(PWideChar(Root)); //DirectoryExists
    if (DirEx<>DWord(-1)) and (FILE_ATTRIBUTE_DIRECTORY and DirEx=FILE_ATTRIBUTE_DIRECTORY) then
    begin
      GetFilesW(Root);
    end
  end
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.StartSearch;
var
  lenFStr: Integer;
  CurDirA: AnsiString;
begin
  FStartTime:=GetTickCount;
  FBreak      :=false;
  CreateSystemMessage(ST_Start, 0, 0);

  //Start-Reservation
  if FListFiles then
  begin
    FSaveFilesMemSize:=100 ;
    SetLength(FFiles, 100);
  end
  else
  begin
    FSaveFilesMemSize:=0 ;
    FFiles:=nil;
  end;
  FFilesCount := 0  ;
  if FListDirs then
  begin
    FSaveDirsMemSize:=100 ;
    SetLength(FDirs, 100);
  end
  else
  begin
    FSaveDirsMemSize:=0;
    FDirs:= nil;
  end;
  FDirsCount := 0  ;

  if UniCodeSupport then
  begin
    lenFStr := lstrlenW(PWideChar(FCurrentDir));
    if lenFStr > 0 then
    begin
      if FCurrentDir[lenFStr] <> '\' then
      begin
        if FCurrentDir[lenFStr] = '/' then FCurrentDir[lenFStr] := '\'
                                      else FCurrentDir := FCurrentDir+'\'
      end;
      SearchFilesW(FCurrentDir)
    end;
  end
  else
  begin
    CurDirA := FCurrentDir;
    lenFStr := lstrlenA(PAnsiChar(CurDirA));
    if lenFStr > 0 then
    begin
      if CurDirA[lenFStr] <> '\' then
      begin
        if CurDirA[lenFStr] = '/' then CurDirA[lenFStr] := '\'
                                  else CurDirA := CurDirA+'\'
      end;
      FCurrentDir:=CurDirA;
      SearchFilesA(CurDirA)
    end;
  end;

  FCurrentDir:='';
  if FListFiles then SetLength(FFiles, FFilesCount);
  if FListDirs  then SetLength(FDirs , FDirsCount );
  FSearchDuration:=GetTickCount-FStartTime;
  FBreak      :=false;
  InterlockedExchange(Integer(FIsSearching), Integer(false));
  if FExtraThread then CloseHandle(FThread);
  CreateSystemMessage(ST_Finish, 0, 0);
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.NameOfMyComputer: WideString; //Bezeichnung des Arbeitsplatzes
var
  pMal: IMalloc    ;
  pidl: PItemIdList;
  isf: IShellFolder;
  StrRet: TStrRet  ;
  p: PChar;
begin
  Result:='';
  if (SHGetMalloc(pMal) = NoError) and
     (SHGetDesktopFolder(isf) = NoError) then
  begin
    try
      SHGetSpecialFolderLocation(0, CSIDL_Drives, pidl);
      if pidl <> nil then
      begin
        if isf.GetDisplayNameOf(pidl, SHGDN_NORMAL, StrRet) = S_OK then
        begin
          case StrRet.uType of
            STRRET_CSTR  : SetString(Result, StrRet.cStr, lstrlen(StrRet.cStr));
            STRRET_OFFSET: begin
                             p:=PChar(@pidl.mkid.abID[StrRet.uOffset-SizeOf(pidl.mkid.cb)]);
                             SetString(Result, p, lstrlen(p))
                           end;
            STRRET_WSTR  : Result:=StrRet.pOleStr;
          end
        end
      end;
    finally
      if pidl<> nil then pMal.Free(pidl);
      isf:=nil;
      pMal:=nil
    end
  end
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.GetDuration: Cardinal;
begin
  if FIsSearching then Result:=GetTickCount-FStartTime
                  else Result:=FSearchDuration;
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.GetCurrentDir: WideString;
begin
  Result:=FCurrentDir; //wird von der TRL synchronisiert
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.GetFilesCount : Integer;
begin
  InterlockedExchange(Integer(Result), Integer(FFilesCount));
end;

function TSearchTool.GetDirsCount : Integer;
begin
  InterlockedExchange(Integer(Result), Integer(FDirsCount));
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.GetListFiles: LongBool;
begin
  InterlockedExchange(Integer(Result), Integer(FListFiles));
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.GetListDirs: LongBool;
begin
  InterlockedExchange(Integer(Result), Integer(FListDirs));
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.GetRecurse: LongBool;
begin
  InterlockedExchange(Integer(Result), Integer(FRecurse));
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.GetMHandle: THandle;
begin
  InterlockedExchange(Integer(Result), Integer(FMHandle))
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.GetMSystem: MessageKind;
begin
  InterlockedExchange(Integer(Result), Integer(FMSystem));
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.GetMCurrentDir: MessageKind;
begin
  InterlockedExchange(Integer(Result), Integer(FMCurrentDir));
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.GetMFound: MessageKind;
begin
  InterlockedExchange(Integer(Result), Integer(FMFound));
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SetMask(Value: WideString);
begin
  FMask  := Value;
  FMaskA := Value;
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SetListFiles(Value: LongBool);
begin
  InterlockedExchange(Integer(FListFiles), Integer(Value));
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SetListDirs(Value: LongBool);
begin
  InterlockedExchange(Integer(FListDirs), Integer(Value));
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SetRecurse(Value: LongBool);
begin
  InterlockedExchange(Integer(FRecurse), Integer(Value));
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SetMHandle(Value: THandle);
begin
  InterlockedExchange(Integer(FMHandle), Value)
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SetMSystem(Value: MessageKind);
begin
  InterlockedExchange(Integer(FMSystem), Integer(Value));
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SetMCurrentDir(Value: MessageKind);
begin
  InterlockedExchange(Integer(FMCurrentDir), Integer(Value));
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SetMFound     (Value: MessageKind);
begin
  InterlockedExchange(Integer(FMFound), Integer(Value));
end;

{*----------------------------------------------------------------------------*}

procedure StartThread(ST: TSearchTool);
begin
  ST.StartSearch;
end;

{******************************************************************************}
{* Public methods                                                             *}
{******************************************************************************}

constructor TSearchTool.Create;
begin
  ResetData;
  FThread         := 0;
  FExtraThread    := false;
  FSearchDuration := 0;
  FRecurse        := false;

  FMHandle        := 0    ;
  FMSystem        := mkSendMessage;
  FMCurrentDir    := mkPostMessage;
  FMFound         := mkPostMessage;

  FIsSearching    := false;
  FBreak          := false;
  FListDirs       := true ;
  FListFiles      := true ;
end;

{*----------------------------------------------------------------------------*}

destructor TSearchTool.Destroy;
begin
  Self.Break;
end;

{*----------------------------------------------------------------------------*}

function TSearchTool.ResetData: Boolean;
begin
  if not FIsSearching then
  begin
    FFiles            := nil;
    FFilesCount       :=   0;
    FSaveFilesMemSize :=   0;

    FDirs             := nil;
    FDirsCount        := 0  ;
    FSaveDirsMemSize  := 0  ;
    Result            :=true;
  end
  else Result:=false
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SearchFiles(const RootFolder: WideString; const ExtraThread: Boolean = true);
var
  Dummy   : Cardinal;
begin
  Self.Break;

  FIsSearching:=true;
  FCurrentDir:=RootFolder;
  FSearchDuration:=0;
  if ExtraThread then
  begin
    FExtraThread:=true;
    FThread:=BeginThread(nil, 0, @StartThread, Self, 0, Dummy);
  end
  else
  begin
    FExtraThread:=false;
    StartSearch;
  end;
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.SearchFiles(const RootFolder: WideString; const Mask: WideString;
                                  const Recurse: Boolean = false; const ExtraThread: Boolean = true);
var
  Dummy   : Cardinal;
begin
  Self.Break;
  FRecurse := Recurse;
  FMask    := Mask;
  FMaskA   := Mask;

  FIsSearching:=true;
  FCurrentDir:=RootFolder;
  FSearchDuration:=0;
  if ExtraThread then
  begin
    FExtraThread:=true;
    FThread:=BeginThread(nil, 0, @StartThread, Self, 0, Dummy);
  end
  else
  begin
    FExtraThread:=false;
    StartSearch;
  end;
end;

{*----------------------------------------------------------------------------*}

procedure TSearchTool.Break;
var
  waitRes: Cardinal;
begin
  InterlockedExchange(Integer(FBreak), Integer(true)); //1=true
  if FIsSearching then
  begin
    if FExtraThread then
    begin
      waitRes:=WAIT_TIMEOUT;
      while (waitRes = WAIT_TIMEOUT) and FIsSearching do
      begin
        Application.ProcessMessages;
        waitRes:=WaitForSingleObject(FThread, 100);
      end;
    end
    else
    begin
      while FIsSearching do
      begin
        Application.ProcessMessages;
      end;
    end;
  end;
end;

{*----------------------------------------------------------------------------*}

initialization
  UniCodeSupport:=Win32Platform = VER_PLATFORM_WIN32_NT;
  
end.
