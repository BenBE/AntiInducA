// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Virtual File System Streams Submodule
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

unit OVFSStreamBase;

interface

uses
    Windows, Classes;

Const
    VFSBufferSize = 4 * 1024 * 1024;                                            //Setup the unit for using of 4MB Buffers

type
    TOVFSStream = Class(TObject)
    Protected
        Function GetSize: Int64; Virtual; Abstract;
        Procedure SetSize(AValue: Int64); Virtual; Abstract;
        Function GetPosition: Int64; Virtual; Abstract;
        Procedure SetPosition(AValue: Int64); Virtual; Abstract;
    Public
        Function Read(Var Buffer; Count: Int64): Int64; Virtual; Abstract;
        Function Write(Const Buffer; Count: Int64): Int64; Virtual; Abstract;
        Function Seek(Offset: Int64; Origin: Word): Int64; Virtual; Abstract;

        Procedure ReadBuffer(Var Buffer; Count: Int64);
        Procedure WriteBuffer(Const Buffer; Count: Int64);

        Procedure ReadByte(Var Buffer: Byte); Overload;
        Procedure ReadWord(Var Buffer: Word); Overload;
        Procedure ReadDWORD(Var Buffer: DWORD); Overload;
        Procedure ReadSmallInt(Var Buffer: SmallInt); Overload;
        Procedure ReadShortInt(Var Buffer: Shortint); Overload;
        Procedure ReadLongInt(Var Buffer: Longint); Overload;
        Procedure ReadInt64(Var Buffer: Int64); Overload;
        Procedure ReadSingle(Var Buffer: Single); Overload;
        Procedure ReadDouble(Var Buffer: Double); Overload;
        Procedure ReadExtended(Var Buffer: Extended); Overload;
        Procedure ReadChar(Var Buffer: Char); Overload;
        Procedure ReadAnsiChar(Var Buffer: AnsiChar); Overload;
        Procedure ReadWideChar(Var Buffer: WideChar); Overload;
        Procedure ReadPChar(Var Buffer: PChar); Overload;
        Procedure ReadPAnsiChar(Var Buffer: PAnsiChar); Overload;
        Procedure ReadPWideChar(Var Buffer: PWideChar); Overload;
        Procedure ReadString(Var Buffer: String); Overload;
        Procedure ReadStringA(Var Buffer: AnsiString); Overload;
        Procedure ReadStringW(Var Buffer: WideString); Overload;
        Procedure ReadText(Var Buffer: String; Count: Integer); Overload;
        Procedure ReadTextLn(Var Buffer: String); Overload;
        Procedure ReadBoolean(Var Buffer: Boolean); Overload;
        Procedure ReadByteBool(Var Buffer: ByteBool); Overload;
        Procedure ReadWordBool(Var Buffer: WordBool); Overload;
        Procedure ReadLongBool(Var Buffer: LongBool); Overload;

        Function ReadByte: Byte; Overload;
        Function ReadWord: Word; Overload;
        Function ReadDWORD: DWORD; Overload;
        Function ReadSmallInt: SmallInt; Overload;
        Function ReadShortInt: Shortint; Overload;
        Function ReadLongInt: Longint; Overload;
        Function ReadInt64: Int64; Overload;
        Function ReadSingle: Single; Overload;
        Function ReadDouble: Double; Overload;
        Function ReadExtended: Extended; Overload;
        Function ReadChar: Char; Overload;
        Function ReadAnsiChar: AnsiChar; Overload;
        Function ReadWideChar: WideChar; Overload;
        Function ReadString: String; Overload;
        Function ReadStringA: AnsiString; Overload;
        Function ReadStringW: WideString; Overload;
        Function ReadBoolean: Boolean; Overload;
        Function ReadText(Count: Integer): String; Overload;
        Function ReadTextLn: String; Overload;
        Function ReadByteBool: ByteBool; Overload;
        Function ReadWordBool: WordBool; Overload;
        Function ReadLongBool: LongBool; Overload;

        Procedure WriteByte(Const Buffer: Byte);
        Procedure WriteWord(Const Buffer: Word);
        Procedure WriteDWORD(Const Buffer: DWORD);
        Procedure WriteSmallInt(Const Buffer: SmallInt);
        Procedure WriteShortInt(Const Buffer: Shortint);
        Procedure WriteLongInt(Const Buffer: Longint);
        Procedure WriteInt64(Const Buffer: Int64);
        Procedure WriteSingle(Const Buffer: Single);
        Procedure WriteDouble(Const Buffer: Double);
        Procedure WriteExtended(Const Buffer: Extended);
        Procedure WriteChar(Const Buffer: Char);
        Procedure WriteAnsiChar(Const Buffer: AnsiChar);
        Procedure WriteWideChar(Const Buffer: WideChar);
        Procedure WritePChar(Const Buffer: PChar);
        Procedure WritePAnsiChar(Const Buffer: PAnsiChar);
        Procedure WritePWideChar(Const Buffer: PWideChar);
        Procedure WriteString(Const Buffer: String);
        Procedure WriteStringA(Const Buffer: AnsiString);
        Procedure WriteStringW(Const Buffer: WideString);
        Procedure WriteText(Const Buffer: String);
        Procedure WriteTextLn(Const Buffer: String);
        Procedure WriteBoolean(Const Buffer: Boolean);
        Procedure WriteByteBool(Const Buffer: ByteBool);
        Procedure WriteWordBool(Const Buffer: WordBool);
        Procedure WriteLongBool(Const Buffer: LongBool);

        Function CopyFrom(Source: TStream; Count: Int64): Int64; Overload;
        Function CopyFrom(Source: TOVFSStream; Count: Int64): Int64; Overload;

        Property Position: Int64 Read GetPosition Write SetPosition;
        Property Size: Int64 Read GetSize Write SetSize;
    End;

implementation

Uses
    SysUtils,
    ODbgInterface,
    OLangGeneral;

{ TOVFSStream }

Function TOVFSStream.CopyFrom(Source: TOVFSStream; Count: Int64): Int64;
Var
    BufSize: Integer;
    Buffer: Array Of Byte;
Begin
    If Count = 0 Then
    Begin
        Source.Position := 0;
        Count := Source.Size;
    End;
    Result := Count;

    If Count > VFSBufferSize Then
        BufSize := VFSBufferSize
    Else
        BufSize := Count;

    SetLength(Buffer, BufSize);
    While Count > 0 Do
    Begin
        BufSize := Count;
        If BufSize > VFSBufferSize Then
            BufSize := VFSBufferSize;
        Source.ReadBuffer(Buffer[0], BufSize);
        WriteBuffer(Buffer[0], BufSize);
        Dec(Count, BufSize);
    End;
End;

Function TOVFSStream.CopyFrom(Source: TStream; Count: Int64): Int64;
Var
    BufSize: Integer;
    Buffer: Array Of Byte;
Begin
    If Count = 0 Then
    Begin
        Source.Position := 0;
        Count := Source.Size;
    End;
    Result := Count;

    If Count > VFSBufferSize Then
        BufSize := VFSBufferSize
    Else
        BufSize := Count;

    SetLength(Buffer, BufSize);
    While Count > 0 Do
    Begin
        BufSize := Count;
        If BufSize > VFSBufferSize Then
            BufSize := VFSBufferSize;
        Source.ReadBuffer(Buffer[0], BufSize);
        WriteBuffer(Buffer[0], BufSize);
        Dec(Count, BufSize);
    End;
End;

Procedure TOVFSStream.ReadAnsiChar(Var Buffer: AnsiChar);
Begin
    ReadBuffer(Buffer, SizeOf(AnsiChar));
End;

Procedure TOVFSStream.ReadBoolean(Var Buffer: Boolean);
Begin
    ReadBuffer(Buffer, SizeOf(Boolean));
End;

Function TOVFSStream.ReadBoolean: Boolean;
Begin
    ReadBoolean(Result);
End;

Procedure TOVFSStream.ReadBuffer(Var Buffer; Count: Int64);
Var
    Tmp: Int64;
Begin
    Tmp := Read(Buffer, Count);
    If Tmp <> Count Then
        OmorphiaErrorStr(vl_Error, '', Format(vfsOperationFailedWrongCounts, ['ReadBuffer', Tmp, Count]));
End;

Procedure TOVFSStream.ReadByte(Var Buffer: Byte);
Begin
    ReadBuffer(Buffer, SizeOf(Byte));
End;

Procedure TOVFSStream.ReadByteBool(Var Buffer: ByteBool);
Begin
    ReadBuffer(Buffer, SizeOf(ByteBool));
End;

Procedure TOVFSStream.ReadChar(Var Buffer: Char);
Begin
    ReadBuffer(Buffer, SizeOf(Char));
End;

Procedure TOVFSStream.ReadDouble(Var Buffer: Double);
Begin
    ReadBuffer(Buffer, SizeOf(Double));
End;

Procedure TOVFSStream.ReadDWORD(Var Buffer: DWORD);
Begin
    ReadBuffer(Buffer, SizeOf(DWORD));
End;

Procedure TOVFSStream.ReadExtended(Var Buffer: Extended);
Begin
    ReadBuffer(Buffer, SizeOf(Extended));
End;

Procedure TOVFSStream.ReadInt64(Var Buffer: Int64);
Begin
    ReadBuffer(Buffer, SizeOf(Int64));
End;

Procedure TOVFSStream.ReadLongBool(Var Buffer: LongBool);
Begin
    ReadBuffer(Buffer, SizeOf(LongBool));
End;

Procedure TOVFSStream.ReadLongInt(Var Buffer: Integer);
Begin
    ReadBuffer(Buffer, SizeOf(Integer));
End;

Function TOVFSStream.ReadLongInt: Longint;
Begin
    ReadLongInt(Result);
End;

Procedure TOVFSStream.ReadPAnsiChar(Var Buffer: PAnsiChar);
Var
    TmpC: AnsiChar;
Begin
    Buffer := Nil;
    While TmpC <> #0 Do
    Begin
        ReadAnsiChar(TmpC);
        Buffer := StrCat(Buffer, PAnsiChar(AnsiString(TmpC)));
    End;
End;

Procedure TOVFSStream.ReadPChar(Var Buffer: PChar);
Var
    TmpC: Char;
Begin
    Buffer := Nil;
    While TmpC <> #0 Do
    Begin
        ReadChar(TmpC);
        Buffer := StrCat(Buffer, PChar(String(TmpC)));
    End;
End;

Procedure TOVFSStream.ReadPWideChar(Var Buffer: PWideChar);
Var
    X: DWORD;
    Len: DWORD;
    Data: Array Of WideChar;
    wc: PWideChar;
    WCD: WideChar;
Begin
    //TODO -oBenBE -cVFS, Stream : Implement ReadPWideChar for Delphi 5
    Len := 4096;
    SetLength(Data, Len);

    X := 0;
    wc := @Data[X];

    Repeat
        ReadWideChar(WCD);
        wc^ := WCD;
        If X = Len - 1 Then
        Begin
            SetLength(Data, Len * 2);
            Len := Len * 2;
            wc := @Data[X];
        End;
        Inc(wc);
        Inc(X);
    Until WCD = #0;

    GetMem(Buffer, X * SizeOf(WideChar));
    Move(Data[0], Buffer^, X * SizeOf(WideChar));
End;

Procedure TOVFSStream.ReadShortInt(Var Buffer: Shortint);
Begin
    ReadBuffer(Buffer, SizeOf(Shortint));
End;

Procedure TOVFSStream.ReadSingle(Var Buffer: Single);
Begin
    ReadBuffer(Buffer, SizeOf(Single));
End;

Procedure TOVFSStream.ReadSmallInt(Var Buffer: SmallInt);
Begin
    ReadBuffer(Buffer, SizeOf(SmallInt));
End;

Procedure TOVFSStream.ReadString(Var Buffer: String);
Var
    Len: Integer;
Begin
    Len := ReadLongInt;
    ReadText(Buffer, Len);
End;

Procedure TOVFSStream.ReadStringA(Var Buffer: AnsiString);
Var
    Len: Integer;
Begin
    ReadLongInt(Len);
    SetLength(Buffer, Len);
    If Len <> 0 Then
        ReadBuffer(Buffer[1], Len * SizeOf(Buffer[1]));
End;

Procedure TOVFSStream.ReadStringW(Var Buffer: WideString);
Var
    Len: Integer;
Begin
    ReadLongInt(Len);
    SetLength(Buffer, Len);
    If Len <> 0 Then
        ReadBuffer(Buffer[1], Len * SizeOf(Buffer[1]));
End;

Procedure TOVFSStream.ReadText(Var Buffer: String; Count: Integer);
Begin
    SetLength(Buffer, Count);
    If Count <> 0 Then
        ReadBuffer(Buffer[1], Count * SizeOf(Buffer[1]));
End;

Procedure TOVFSStream.ReadTextLn(Var Buffer: String);
Var
    LastChar: Char;
Begin
    //TODO -oBenBE -cVFS, Stream : Optimize TOVFSStream.ReadTextLn
    LastChar := ReadChar;
    Buffer := '';
    While Not (LastChar In [#13, #10]) Do
    Begin
        Buffer := Buffer + LastChar;

        If Position >= Size Then
            Exit;

        LastChar := ReadChar;
    End;
    If LastChar = #13 Then
    Begin
        If ReadChar <> #10 Then
            Seek(-1, soFromCurrent);
    End
    Else
        OmorphiaDebugStr(vl_Warning, '', 'Unknown Line Ending Charater: ' + IntToHex(Ord(LastChar), 2));
End;

Procedure TOVFSStream.ReadWideChar(Var Buffer: WideChar);
Begin
    ReadBuffer(Buffer, SizeOf(WideChar));
End;

Procedure TOVFSStream.ReadWord(Var Buffer: Word);
Begin
    ReadBuffer(Buffer, SizeOf(Word));
End;

Procedure TOVFSStream.ReadWordBool(Var Buffer: WordBool);
Begin
    ReadBuffer(Buffer, SizeOf(WordBool));
End;

Function TOVFSStream.ReadWordBool: WordBool;
Begin
    ReadWordBool(Result);
End;

Procedure TOVFSStream.WriteAnsiChar(Const Buffer: AnsiChar);
Begin
    WriteBuffer(Buffer, SizeOf(AnsiChar));
End;

Procedure TOVFSStream.WriteBoolean(Const Buffer: Boolean);
Begin
    WriteBuffer(Buffer, SizeOf(Boolean));
End;

Procedure TOVFSStream.WriteBuffer(Const Buffer; Count: Int64);
Var
    Tmp: Int64;
Begin
    Tmp := Write(Buffer, Count);
    If Tmp <> Count Then
        OmorphiaErrorStr(vl_Error, '', Format(vfsOperationFailedWrongCounts, ['WriteBuffer', Tmp, Count]));
End;

Procedure TOVFSStream.WriteByte(Const Buffer: Byte);
Begin
    WriteBuffer(Buffer, SizeOf(Byte));
End;

Procedure TOVFSStream.WriteByteBool(Const Buffer: ByteBool);
Begin
    WriteBuffer(Buffer, SizeOf(ByteBool));
End;

Procedure TOVFSStream.WriteChar(Const Buffer: Char);
Begin
    WriteBuffer(Buffer, SizeOf(Char));
End;

Procedure TOVFSStream.WriteDouble(Const Buffer: Double);
Begin
    WriteBuffer(Buffer, SizeOf(Double));
End;

Procedure TOVFSStream.WriteDWORD(Const Buffer: DWORD);
Begin
    WriteBuffer(Buffer, SizeOf(DWORD));
End;

Procedure TOVFSStream.WriteExtended(Const Buffer: Extended);
Begin
    WriteBuffer(Buffer, SizeOf(Extended));
End;

Procedure TOVFSStream.WriteInt64(Const Buffer: Int64);
Begin
    WriteBuffer(Buffer, SizeOf(Int64));
End;

Procedure TOVFSStream.WriteLongBool(Const Buffer: LongBool);
Begin
    WriteBuffer(Buffer, SizeOf(LongBool));
End;

Procedure TOVFSStream.WriteLongInt(Const Buffer: Integer);
Begin
    WriteBuffer(Buffer, SizeOf(Longint));
End;

Procedure TOVFSStream.WritePAnsiChar(Const Buffer: PAnsiChar);
Var
    Len: Int64;
Begin
    Len := StrLen(Buffer);
    If Len <> 0 Then
        WriteBuffer(Buffer^, Len * SizeOf(AnsiChar));
    WriteAnsiChar(#0);
End;

Procedure TOVFSStream.WritePChar(Const Buffer: PChar);
Var
    Len: Int64;
Begin
    Len := StrLen(Buffer);
    If Len <> 0 Then
        WriteBuffer(Buffer^, Len * SizeOf(AnsiChar));
    WriteAnsiChar(#0);
End;

Procedure TOVFSStream.WritePWideChar(Const Buffer: PWideChar);
Var
    Len: Int64;
Begin
    //DONE -oBenBE -cVFS, Stream : Implement WritePWideChar for Delphi 5

    Len := Length(WideCharToString(Buffer));
    If Len <> 0 Then
        WriteBuffer(Buffer^, Len * SizeOf(WideChar));
    WriteWideChar(#0);
End;

Procedure TOVFSStream.WriteShortInt(Const Buffer: Shortint);
Begin
    WriteBuffer(Buffer, SizeOf(Shortint));
End;

Procedure TOVFSStream.WriteSingle(Const Buffer: Single);
Begin
    WriteBuffer(Buffer, SizeOf(Single));
End;

Procedure TOVFSStream.WriteSmallInt(Const Buffer: SmallInt);
Begin
    WriteBuffer(Buffer, SizeOf(SmallInt));
End;

Procedure TOVFSStream.WriteString(Const Buffer: String);
Var
    Len: Integer;
Begin
    Len := Length(Buffer);
    WriteLongInt(Len);
    If Len <> 0 Then
        WriteBuffer(Buffer[1], Len * SizeOf(Buffer[1]));
End;

Procedure TOVFSStream.WriteStringA(Const Buffer: AnsiString);
Var
    Len: Integer;
Begin
    Len := Length(Buffer);
    WriteLongInt(Len);
    If Len <> 0 Then
        WriteBuffer(Buffer[1], Len * SizeOf(AnsiChar));
End;

Procedure TOVFSStream.WriteStringW(Const Buffer: WideString);
Var
    Len: Integer;
Begin
    Len := Length(Buffer);
    WriteLongInt(Len);
    If Len <> 0 Then
        WriteBuffer(Buffer[1], Len * SizeOf(WideChar));
End;

Procedure TOVFSStream.WriteText(Const Buffer: String);
Var
    Len: Integer;
Begin
    Len := Length(Buffer);
    If Len <> 0 Then
        WriteBuffer(Buffer[1], Len * SizeOf(Buffer[1]));
End;

Procedure TOVFSStream.WriteTextLn(Const Buffer: String);
Begin
    WriteText(Buffer + #13#10);
End;

Procedure TOVFSStream.WriteWideChar(Const Buffer: WideChar);
Begin
    WriteBuffer(Buffer, SizeOf(WideChar));
End;

Procedure TOVFSStream.WriteWord(Const Buffer: Word);
Begin
    WriteBuffer(Buffer, SizeOf(Word));
End;

Procedure TOVFSStream.WriteWordBool(Const Buffer: WordBool);
Begin
    WriteBuffer(Buffer, SizeOf(WordBool));
End;

Function TOVFSStream.ReadAnsiChar: AnsiChar;
Begin
    ReadAnsiChar(Result);
End;

Function TOVFSStream.ReadByte: Byte;
Begin
    ReadByte(Result);
End;

Function TOVFSStream.ReadByteBool: ByteBool;
Begin
    ReadByteBool(Result);
End;

Function TOVFSStream.ReadChar: Char;
Begin
    ReadChar(Result);
End;

Function TOVFSStream.ReadDouble: Double;
Begin
    ReadDouble(Result);
End;

Function TOVFSStream.ReadDWORD: DWORD;
Begin
    ReadDWORD(Result);
End;

Function TOVFSStream.ReadExtended: Extended;
Begin
    ReadExtended(Result);
End;

Function TOVFSStream.ReadInt64: Int64;
Begin
    ReadInt64(Result);
End;

Function TOVFSStream.ReadLongBool: LongBool;
Begin
    ReadLongBool(Result);
End;

Function TOVFSStream.ReadShortInt: Shortint;
Begin
    ReadShortInt(Result);
End;

Function TOVFSStream.ReadSingle: Single;
Begin
    ReadSingle(Result);
End;

Function TOVFSStream.ReadSmallInt: SmallInt;
Begin
    ReadSmallInt(Result);
End;

Function TOVFSStream.ReadString: String;
Begin
    ReadString(Result);
End;

Function TOVFSStream.ReadStringA: AnsiString;
Begin
    ReadStringA(Result);
End;

Function TOVFSStream.ReadStringW: WideString;
Begin
    ReadStringW(Result);
End;

Function TOVFSStream.ReadText(Count: Integer): String;
Begin
    ReadText(Result, Count);
End;

Function TOVFSStream.ReadTextLn: String;
Begin
    ReadTextLn(Result);
End;

Function TOVFSStream.ReadWideChar: WideChar;
Begin
    ReadWideChar(Result);
End;

Function TOVFSStream.ReadWord: Word;
Begin
    ReadWord(Result);
End;

end.
 
