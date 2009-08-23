unit uallProcess;

{$I 'uallCollection.inc'}

interface

uses windows, tlhelp32, uallUtil, uallKernel;

function FindProcess(ExeNames: PChar): DWord; stdcall;
function FindModulesInProcess(ProcessID: DWord): string; stdcall; overload;
function FindModulesInProcess(ExecutableName: PChar): string; stdcall; overload;
function FindAllProcesses: string; stdcall;
function GetExecutableFromPID(dwProcessID: DWord): String; stdcall;

implementation


function FindModulesInProcess(ExecutableName: PChar): string; stdcall; overload;
begin
  Result := FindModulesInProcess(FindProcess(ExecutableName));
end;

function FindModulesInProcess(ProcessID: DWord): string; stdcall; overload;
var sFoundModules  : String;
    FSnapshotHandle: THandle;
    FModuleEntry32 : TModuleEntry32;
    ContinueLoop   : Boolean;
begin
  Result := '';
  sFoundModules := '';
  if (ProcessID <> 0) then
  begin
    FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,ProcessID);
    FModuleEntry32.dwSize := Sizeof(FModuleEntry32);
    ContinueLoop := Module32First(FSnapshotHandle,FModuleEntry32);
    while ContinueLoop do
    begin
      sFoundModules := sFoundModules+FModuleEntry32.szModule+#13#10;
      ContinueLoop := Module32Next(FSnapshotHandle,FModuleEntry32);
    end;
    result := sFoundModules;
    CloseHandle(FSnapshotHandle);
  end;
end;

function GetExecutableFromPID(dwProcessID: DWord): string; stdcall;
var FSnapshotHandle: THandle;
    FModuleEntry32 : TModuleEntry32;
begin
  Result := '';
  dwProcessID := GetProcessID(dwProcessID);
  if (dwProcessID <> 0) then
  begin
    FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,dwProcessID);
    FModuleEntry32.dwSize := Sizeof(FModuleEntry32);
    Module32First(FSnapshotHandle,FModuleEntry32);
    result := FModuleEntry32.szExePath;
    CloseHandle(FSnapshotHandle);
  end;
end;

function FindAllProcesses: string; stdcall;
var
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  ContinueLoop   : Boolean;
  sFoundProcesses: String;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle,FProcessEntry32);
  sFoundProcesses := '';
  while ContinueLoop do
  begin
    sFoundProcesses := sFoundProcesses+ExtractFilename(FProcessEntry32.szExeFile)+#13#10;
    ContinueLoop := Process32Next(FSnapshotHandle,FProcessEntry32);
  end;
  if (Length(sFoundProcesses) > 0) then
    Result := Copy(sFoundProcesses,1,length(sFoundProcesses)-2);
  CloseHandle(FSnapshotHandle);
end;

function FindProcess(ExeNames: PChar): DWord; stdcall;
  function DeleteExe(sProcessNames: string): string;
  var i: DWord;
      j: DWord;
  begin
    SetLength(Result,Length(sProcessNames));
    result := '';
    j := 0;
    for i := 1 to length(sProcessNames) do
    begin
      if (Copy(sProcessNames,i,6) = ('.EXE'#13#10)) then
        j := 4;
      if (j > 0) then
        Dec(j) else
        Result := Result+sProcessNames[i];
    end;
  end;
var
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  ContinueLoop   : Boolean;
  sExeSearch     : String;
  sExeProcess    : String;
  i              : integer;
begin
  Result := 0;
  sExeSearch := DeleteExe(uppercase(#13#10+exenames+#13#10));
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle,FProcessEntry32);
  while ContinueLoop do
  begin
    sExeProcess := uppercase(uallUtil.extractfilename(FProcessEntry32.szExeFile));
    i := pos(sExeProcess,sExeSearch);
    if (i > 0) and
       (sExeSearch[i-1] = #10) and
       (sExeSearch[i+length(sExeProcess)] = #13)  then
      result := FProcessEntry32.th32ProcessID;
    ContinueLoop := Process32Next(FSnapshotHandle,FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

end.
