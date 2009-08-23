unit ODbgStack;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Debugger Support
//
// This unit provides a general interface to query Symbol Information for a
// given address based on mapfiles generated for a program.
//
// *****************************************************************************
// To Do:
//  TODO -oBenBE -cDebug : Test and verify for Delphi 4
//  TODO -oBenBE -cDebug : Test and verify for Delphi 5
//  TODO -oBenBE -cDebug : Test and verify for Delphi 6
//  DONE -oBenBE -cDebug : Test and verify for Delphi 7
//
// *****************************************************************************
// News:
//
// *****************************************************************************
// Bugs:
//  TODO -oBenBE -cBug, Debug, Mapfile : #0000024 Doesn't work together with some EXE file compressors
//  DONE -oBenBE -cBug, Debug, Mapfile : #0000024 Doesn't work together with Neolite
//  DONE -oBenBE -cBug, Debug, Mapfile : #0000024 Doesn't work together with UPX
//
// *****************************************************************************
// Info:
//
// *****************************************************************************

// Include the Compiler Version and Options Settings
{$I 'Omorphia.config.inc'}

interface

Uses
    Classes;

Function GetStackTrace(Levels: Integer = 100): TStringList;
Function GetStackTracePtr(Levels: Integer = 100): TList;

implementation

uses 
    Windows,
    OIncTypes,
    OIncProcs,
    ODbgMapfile;

Function GetStackTrace(Levels: Integer): TStringList;
var
    CallStack: TList;
    X: Integer;
Begin
    Result := TStringList.Create;
    try
        CallStack := GetStackTracePtr(Levels);
        try
            //Remove the entries referencing oursevels ...
            CallStack.Delete(0);
            CallStack.Delete(0);
            
            For X := 0 TO CallStack.Count - 1 Do
            Begin
                Result.Add(PlaceToLocationStr(AddressToLocation(CallStack[X])));
            end;
        finally
            FreeAndNilSecure(CallStack);
        end;
    except
        FreeAndNilSecure(Result);
    end;
end;

Function GetStackTracePtr(Levels: Integer): TList;

    Function IsCallInstr(Var Ptr: TAdvPointer; Out Dest: TAdvPointer): Boolean;
    Var
        Instr: PByte;
        Tmp: Pointer;
        TmpB: PByte Absolute Tmp;
        TmpW: PWord Absolute Tmp;
        TmpD: PDWORD Absolute Tmp;
    Begin
        //  =>  Ptr     Holds the Return Pointer to examine
        //  =>  Dest    ignored
        //  <=  Ptr     Holds the Instruction Pointer calling the procedure
        //  <=  Dest    Holds the called procedure entry point (if available, else nil)
        //  <=  Result  True if a valid call\jump instruction was found

        Dest.Addr := 0;
        Result := False;

        Instr := PByte(Ptr.Addr - 7);
        If Not IsBadReadPtr(Instr, 7) Then
        Begin
            Tmp := Instr;
            If TmpD^ And $00FFFFFF = $002494FF Then
            Begin
                Ptr.Ptr := Instr;
                Result := True;
                Exit;
            End;
        End;

        Instr := PByte(Ptr.Addr - 6);
        If Not IsBadReadPtr(Instr, 6) Then
        Begin
            If Instr^ = $FF Then
            Begin
                Tmp := Instr;
                Inc(TmpB);

                If TmpB^ In [$90, $91, $92, $93, $95, $96, $97] Then
                Begin
                    Ptr.Ptr := Instr;
                    Result := True;
                    Exit;
                End;

                If TmpB^ = $15 Then
                Begin
                    Inc(TmpB);

                    Dest.Addr := TmpD^;
                    If IsBadReadPtr(Dest.Ptr, 4) Then
                        Dest.Addr := 0;

                    Ptr.Ptr := Instr;
                    Result := True;
                    Exit;
                End;
            End;
        End;

        Instr := PByte(Ptr.Addr - 5);
        If Not IsBadReadPtr(Instr, 5) Then
        Begin
            If Instr^ = $E8 Then
            Begin
                Tmp := Instr;
                Inc(TmpB);

                Dest.Addr := Ptr.Addr + TmpD^;
                Ptr.Ptr := Instr;
                Result := True;
                Exit;
            End;
        End;

        Instr := PByte(Ptr.Addr - 4);
        If Not IsBadReadPtr(Instr, 4) Then
        Begin
            Tmp := Instr;
            If TmpD^ And $00FFFFFF = $002454FF Then
            Begin
                Ptr.Ptr := Instr;
                Result := True;
                Exit;
            End;
        End;

        Instr := PByte(Ptr.Addr - 3);
        If Not IsBadReadPtr(Instr, 3) Then
        Begin
            If Instr^ = $FF Then
            Begin
                Tmp := Instr;
                Inc(TmpB);

                If TmpB^ In [$50, $51, $52, $53, $55, $56, $57] Then
                Begin
                    Ptr.Ptr := Instr;
                    Result := True;
                    Exit;
                End;

                If TmpW^ = $2414 Then
                Begin
                    Ptr.Ptr := Instr;
                    Result := True;
                    Exit;
                End;
            End;
        End;

        Instr := PByte(Ptr.Addr - 2);
        If Not IsBadReadPtr(Instr, 2) Then
        Begin
            If Instr^ = $FF Then
            Begin
                Tmp := Instr;
                Inc(TmpB);

                If TmpB^ In [$D0..$D7] Then
                Begin
                    Inc(TmpB);

                    Dest.Addr := Ptr.Addr + TmpD^;
                    Ptr.Ptr := Instr;
                    Result := True;
                    Exit;
                End;

                If TmpB^ In [$10, $11, $12, $13, $16, $17] Then
                Begin
                    Ptr.Ptr := Instr;
                    Result := True;
                    Exit;
                End;
            End;
        End;
    End;

Var
    TOS, BOS: TAdvPointer;
    Curr: TAdvPointer;
    SrcPtr: TAdvPointer;
    Dest: TAdvPointer;

    ValidLen: Integer;

Begin
    Asm
    MOV     EAX, DWORD PTR FS:[$00000004]
    MOV     DWORD PTR [TOS], EAX
    MOV     DWORD PTR [BOS], EBP
    End;

    Result := TList.Create;
    Try
        ValidLen := 0;

        Curr := BOS;
        While (Curr.Addr < TOS.Addr) And (Curr.Addr >= BOS.Addr) Do
        Begin
            If ValidLen < 4 Then
            Begin
                If Not IsBadReadPtr(Curr.Ptr, 512) Then
                Begin
                    ValidLen := 512
                End
                Else If Not IsBadReadPtr(Curr.Ptr, 4) Then
                Begin
                    ValidLen := 4
                End
                Else
                Begin
                    ValidLen := 0;
                End;
            End;

            If ValidLen >= 4 Then
            Begin
                SrcPtr.Addr := TAdvPointer(PDWORD(Curr.Ptr)^).Addr;

                If IsCallInstr(SrcPtr, Dest) Then
                Begin
                    If Not IsBadCodePtr(Dest.Ptr) Then
                        Result.Add(Dest.Ptr);

                    Result.Add(SrcPtr.Ptr);
                End;
            End;

            Inc(Curr.Addr, 4);
            Dec(ValidLen, 4);
        End;
    Except
        FreeAndNilSecure(Result);
    End;
End;

end.
 
