unit uallUtil;

{$I 'uallCollection.inc'}

interface

uses windows;

function ExtractFileNameWithExtention(sFileName: String): String; stdcall;
function ExtractFilePath(sFile: String): String; stdcall;
function ExtractFileName(sFile: String): String; stdcall;
function UpperCase(sString: String): String; stdcall;
function IntToStr(iValue: Integer): String; stdcall;
function IntToHex(dwValue, dwDigits: DWord): String; stdcall;
function LowerCase(sString: String): String; stdcall;
function GetExeDirectory: String; stdcall;
function CompareMem(P1, P2: Pointer; Length: Integer): Boolean; assembler; stdcall;
function StrAlloc(Size: Cardinal): PChar; stdcall;
procedure StrDispose(Str: PChar); stdcall;

implementation

function StrAlloc(Size: Cardinal): PChar; stdcall;
begin
  Inc(Size, SizeOf(Cardinal));
  GetMem(Result, Size);
  Cardinal(Pointer(Result)^) := Size;
  Inc(Result, SizeOf(Cardinal));
end;

procedure StrDispose(Str: PChar); stdcall;
begin
  if (Str <> nil) then
  begin
    Dec(Str, SizeOf(Cardinal));
    FreeMem(Str, Cardinal(Pointer(Str)^));
  end;
end;

function CompareMem(P1, P2: Pointer; Length: Integer): Boolean; assembler; stdcall;
asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,P1
        MOV     EDI,P2
        MOV     EDX,ECX
        XOR     EAX,EAX
        AND     EDX,3
        SAR     ECX,2
        JS      @@1     // Negative Length implies identity.
        REPE    CMPSD
        JNE     @@2
        MOV     ECX,EDX
        REPE    CMPSB
        JNE     @@2
@@1:    INC     EAX
@@2:    POP     EDI
        POP     ESI
end;


function ExtractFileNameWithExtention(sFileName: String): String; stdcall;
var
  i: Integer;
  j: integer;
begin
  j := 0;
  for i := 1 to length(sFileName) do
    if (sFileName[i] = '\') then j := i;
  result := Copy(sFileName, j + 1, length(sFileName));
end;

function ExtractFilePath(sFile: String): String; stdcall;
var
  i: Integer;
  j: Integer;
begin
  j := length(sFile);
  for i := 1 to length(sFile) do
    if sFile[i] = '\' then j := i;
  result := Copy(sFile, 1, j);
end;

function GetExeDirectory: String; stdcall;
begin
  result := ExtractFilePath(ParamStr(0));
end;

function IntToHex(dwValue, dwDigits: DWord): String; stdcall;
const
  hex: array[0..$F] of char = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
begin
  if (dwDigits > 8) then
    dwDigits := 8;
  Result := Copy(
       hex[(dwValue and $F0000000) shr 28]+
       hex[(dwValue and $0F000000) shr 24]+
       hex[(dwValue and $00F00000) shr 20]+
       hex[(dwValue and $000F0000) shr 16]+
       hex[(dwValue and $0000F000) shr 12]+
       hex[(dwValue and $00000F00) shr 8]+
       hex[(dwValue and $000000F0) shr 4]+
       hex[(dwValue and $0000000F) shr 0],9-dwDigits,dwDigits);
end;

function IntToStr(iValue: Integer): String; stdcall;
var
  Minus : Boolean;
begin
   Result := '';
   if (iValue = 0) then
      Result := '0';
   Minus :=   iValue < 0;
   if Minus then
      iValue := -iValue;
   while (iValue > 0) do
   begin
      Result := Char( (iValue mod 10) + Integer( '0' ) ) + Result;
      iValue := iValue div 10;
   end;
   if Minus then
      Result := '-' + Result;
end;

function LowerCase(sString: String): String; stdcall;
var
  Ch    : Char;
  L     : Integer;
  Source: PChar;
  Dest  : PChar;
begin
  L := Length(sString);
  SetLength(Result, L);
  Source := Pointer(sString);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'A') and (Ch <= 'Z') then Inc(Ch, 32);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  end;
end;

function UpperCase(sString: String): String; stdcall;
var
  Ch    : Char;
  L     : Integer;
  Source: PChar;
  Dest  : PChar;
begin
  L := Length(sString);
  SetLength(Result, L);
  Source := Pointer(sString);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'a') and (Ch <= 'z') then Dec(Ch, 32);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  end;
end;

function ExtractFileName(sFile: String): String; stdcall;
var
  i: Integer;
  j: Integer;
begin
  j := 0;
  for i := 1 to length(sFile) do
    if (sFile[i] = '\') then j := i;
  sFile := Copy(sFile,j+1,length(sFile));
  j := 0;
  for i := 1 to length(sFile) do
    if (sFile[i] = '.') then j := i;
  if j = 0 then j := length(sFile)+1;
  Result := Copy(sFile,1,j-1);
end;

end.
