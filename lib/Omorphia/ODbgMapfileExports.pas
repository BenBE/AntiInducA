Unit ODbgMapfileExports;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Debugger Support
//
// This unit provides Symbol information of exported DLL functions
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
    OIncTypes,
    ODbgMapfile;

Type
    TODbgMapfileParser_Exports = Class(TODbgMapfileParser)
    Private
        Procedure ParseMapfile(AModule: TAdvPointer);
        Procedure HandleBorlandPackage(Var Publics: TODbgMapfilePublicsInfo);
    Public
        Constructor Create(AAddress: TAdvPointer); Override;
        Destructor Destroy; Override;

        Class Function IsModuleInfoAvailable(AAddress: TAdvPointer): Boolean; Override;
    End;

Implementation

Uses
    SysUtils,
    Classes,
    OVFSPathUtils;

{ TODbgMapfileParser_Exports }

Constructor TODbgMapfileParser_Exports.Create(AAddress: TAdvPointer);
Begin
    Inherited;

    ParseMapfile(AAddress);
End;

Destructor TODbgMapfileParser_Exports.Destroy;
Begin
    Inherited;
End;

Procedure TODbgMapfileParser_Exports.HandleBorlandPackage(
    Var Publics: TODbgMapfilePublicsInfo);

    Function IsFunctionName(S: String; Var P: Integer; Out Len: Integer; Out Name: String): Boolean;
    Begin
        Result := False;
        Len := 0;
        Name := '';
        If (P = 0) Or (P > Length(S)) Then
            Exit;

        While (P < Length(S)) And (S[P] In ['0'..'9']) Do
        Begin
            Len := Len * 10 + Ord(S[P]) - 48;
            Inc(P);
        End;

        If P + Len > Length(S) Then
        Begin
            Len := 0;
            Exit;
        End;

        Name := Copy(S, P, Len);

        If Pos('$', Name) <> 0 Then
        Begin
            Len := 0;
            Name := '';
            Exit;
        End;

        Result := True;
    End;

Var
    PName: String;

    Pos_FirstAt: Integer;
    Pos_FirstDot: Integer;

    Len_PName: Integer;

    IdentStr: String;
    IdentLen: Integer;

    Publics_Unit: String;

    UnitPtr: PODbgMapfileUnitInfo;

    Procedure IdentToNameInfo(IdentStr: String);
    Begin
        Pos_FirstDot := Pos('.', IdentStr);
        If Pos_FirstDot <> 0 Then
        Begin
            Publics_Unit := Copy(PName, 1, Pos_FirstDot - 1);
            Delete(IdentStr, 1, Pos_FirstDot);

            New(UnitPtr);
            UnitPtr^.UnitName := Publics_Unit;
            UnitPtr^.UnitPtr := Publics.PublicPtr;
            FUnitInfo.Add(UnitPtr);
        End;

        Publics.PublicName := IdentStr;
    End;

Begin
    PName := Publics.PublicName;
    Len_PName := Length(PName);

    Pos_FirstAt := Pos('@', PName);

    //Check if it could be a package function name at all...
    If Pos_FirstAt <> 0 Then
    Begin
        //Check for Delphi 3 and below - although not supported ;-)
        If Len_PName > 9 Then
        Begin
            //Check if the 9th Char from right is an @-sign ...
            If PName[Len_PName - 8] = '@' Then
            Begin
                //Seems as if it's going to be one ...
                IdentStr := Copy(PName, Len_PName - 7, 8);

                //Check if the last 8 digit's are a valid hex number ...
                If StrToInt64Def(IdentStr, 0) = StrToInt64Def(IdentStr, 1) Then
                Begin
                    //Check if there is at least one dot to separate the unit name ...
                    Pos_FirstDot := Pos('.', PName);

                    If Pos_FirstDot <> 0 Then
                    Begin
                        //It's a Borlannd 3 package. Let's split the names by .
                        //Get the part before the @ sign ...
                        IdentStr := Copy(PName, 1, Len_PName - 9);
                        IdentStr := StringReplace(IdentStr, '@', '_', [rfReplaceAll]);

                        IdentToNameInfo(IdentStr);

                        Exit;
                    End;
                End;
            End;
        End;

        //Check for Delphi 4 and up ...
        //This will get a bit tricky ...
        //At first the easy part:
        If Copy(PName, 1, 5) = '@$xp$' Then
        Begin
            //Yeah, we got  type ident ... Let's check if it really is one
            Pos_FirstAt := 6;
            If IsFunctionName(PName, Pos_FirstAt, IdentLen, IdentStr) Then
            Begin
                IdentStr := StringReplace(IdentStr, '@', '.', [rfReplaceAll]);

                IdentToNameInfo(IdentStr);

                Exit;
            End;
        End;

        //Now the more complicated stuff: Reading function names ;-)
        If PName[1] = '@' Then
        Begin
            Delete(PName, 1, 1);
            PName := StringReplace(PName, '@', '.', [rfReplaceAll]);
            PName := StringReplace(PName, '$', '@', [rfReplaceAll]);

            //Yeah, we got function, proc, prop or other stupid ident ... Let's analyze it!
            Pos_FirstAt := Pos('@', PName);

            If Pos_FirstAt <> 0 Then
                IdentStr := Copy(PName, 1, Pos_FirstAt - 1)
            Else
                IdentStr := PName;

            IdentToNameInfo(IdentStr);

            Exit;
        End;
    End;
End;

Class Function TODbgMapfileParser_Exports.IsModuleInfoAvailable(AAddress: TAdvPointer): Boolean;
Var
    CodeSegment: TRVABlock;

    MZ: PImageDosHeader;
    PE: PImageNtHeaders;

    DDir: PImageDataDirectory;
    EDir: PImageExportDirectory;
Begin
    //TODO -oBenBE -cDbg, Mapfile : Implement TODbgMapfileParser_Exports.IsModuleInfoAvailable
    Result := False;

    CodeSegment := GetModuleCodeSegment(AAddress.Addr);
    If Not Assigned(CodeSegment.Ptr.Ptr) Then
        Exit;

    MZ := AAddress.Ptr;

    If IsBadReadPtr(MZ, SizeOf(TImageDosHeader)) Then
        Exit;

    If MZ^.e_magic <> IMAGE_DOS_SIGNATURE Then
        Exit;

    {$IFNDEF FPC}
    TAdvPointer(PE).Addr := TAdvPointer(MZ).Addr + DWORD(MZ^._lfanew);
    {$ELSE}
    TAdvPointer(PE).Addr := TAdvPointer(MZ).Addr + DWORD(MZ^.e_lfanew);
    {$ENDIF}

    If PE^.Signature <> IMAGE_NT_SIGNATURE Then
        Exit;

    DDir := @(PE^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT]);

    TAdvPointer(EDir).Addr := DDir^.VirtualAddress;

    If Not Assigned(EDir) Then
        Exit;

    TAdvPointer(EDir).Addr := AAddress.Addr + TAdvPointer(EDir).Addr;

    Result := (EDir^.NumberOfFunctions <> 0) And (EDir^.NumberOfNames <> 0);
End;

Procedure TODbgMapfileParser_Exports.ParseMapfile(AModule: TAdvPointer);
Var
    CodeSegment: TRVABlock;

    MZ: PImageDosHeader;
    PE: PImageNtHeaders;

    DDir: PImageDataDirectory;
    EDir: PImageExportDirectory;

    ESegBase: TAdvPointer;

    X, Y: Integer;

    NamePtr: PDWORD;
    ProcPtr: PDWORD;
    OrdsPtr: PWord;

    Publics: TODbgMapfilePublicsInfo;
    PublicsPtr: PODbgMapfilePublicsInfo;

    IsBorlandPackage: Boolean;

type
    TNameDir = Array[0..0] of TAdvPointer;
    PNameDir = ^TNameDir;

    TOrdsDir = Array[0..0] of Word;
    POrdsDir = ^TOrdsDir;

var
    LibDLLName: PNameDir;
    LibDLLOrds: POrdsDir;

Begin
    //Check if the current module is a package
    //If this was the case we should analyze it's function names
    IsBorlandPackage := (FindResource(AModule.Addr, 'PACKAGEINFO', RT_RCDATA) <> 0) And (FindResource(AModule.Addr, 'PACKAGEOPTIONS', RT_RCDATA) <> 0);

    //TODO -oBenBE -cDbg, Mapfile : Implement TODbgMapfileParser_Exports.ParseMapfile
    CodeSegment := GetModuleCodeSegment(AModule.Addr);
    If Not Assigned(CodeSegment.Ptr.Ptr) Then
        Exit;

    MZ := AModule.Ptr;

    If IsBadReadPtr(MZ, SizeOf(TImageDosHeader)) Then
        Exit;

    If MZ^.e_magic <> IMAGE_DOS_SIGNATURE Then
        Exit;

    {$IFNDEF FPC}
    TAdvPointer(PE).Addr := TAdvPointer(MZ).Addr + DWORD(MZ^._lfanew);
    {$ELSE}
    TAdvPointer(PE).Addr := TAdvPointer(MZ).Addr + DWORD(MZ^.e_lfanew);
    {$ENDIF}

    If PE^.Signature <> IMAGE_NT_SIGNATURE Then
        Exit;

    DDir := @(PE^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT]);

    TAdvPointer(EDir).Addr := DDir^.VirtualAddress;

    If Not Assigned(EDir) Then
        Exit;

    ESegBase.Ptr := MZ;

    TAdvPointer(EDir).Addr := ESegBase.Addr + TAdvPointer(EDir).Addr;

    If Not (EDir^.NumberOfFunctions <> 0) And (EDir^.NumberOfNames <> 0) Then
        Exit;

    TAdvPointer(ProcPtr).Addr := ESegBase.Addr + DWORD(EDir^.AddressOfFunctions);
    TAdvPointer(NamePtr).Addr := ESegBase.Addr + DWORD(EDir^.AddressOfNames);    
    TAdvPointer(OrdsPtr).Addr := ESegBase.Addr + DWORD(EDir^.AddressOfNameOrdinals);

    LibDLLName := Pointer(NamePtr);
    LibDLLOrds := Pointer(OrdsPtr);
    

    For X := 0 To EDir^.NumberOfFunctions - 1 Do
    Begin
        Publics.PublicPtr.Ptr.Addr := ESegBase.Addr + ProcPtr^;
        Publics.PublicPtr.Size := CodeSegment.Ptr.Addr + CodeSegment.Size - Publics.PublicPtr.Ptr.Addr;

        Publics.PublicName := Format('Ord #$%0:.4x - %0:d', [X]);
        
        For Y := 0 TO EDir^.NumberOfNames - 1 Do
        Begin
            If LibDLLOrds^[Y] = X Then
            Begin
                Publics.PublicName := StrPas(TAdvPointer(ESegBase.Addr + LibDLLName^[Y].Addr).Ptr);

                If IsBorlandPackage Then
                    HandleBorlandPackage(Publics);

                Break;
            end;
        End;

        New(PublicsPtr);
        PublicsPtr^ := Publics;
        FPublicsInfo.Add(PublicsPtr);

        Inc(ProcPtr);
    End;
End;

Initialization
    RegisterMapfileParser(TODbgMapfileParser_Exports);
Finalization
    UnregisterMapfileParser(TODbgMapfileParser_Exports);
End.
