Unit ODbgMapfileGeneralMap;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Debugger Support
//
// This unit provides Symbol information contained in Borland Mapfiles..
//
// *****************************************************************************
// To Do:
//  TODO -oBenBE -cDebug : Test and verify for Delphi 4
//  TODO -oBenBE -cDebug : Test and verify for Delphi 5
//  TODO -oBenBE -cDebug : Test and verify for Delphi 6
//  DONE -oBenBE -cDebug : Test and verify for Delphi 7
//  TODO -oBenBE -cDebug, Mapfile : Optimize the Mapfile Parser
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

Interface

Uses
    Windows,
    OIncTypes,
    ODbgMapfile;

Type
    TODbgMapfileParser_GeneralMapfile = Class(TODbgMapfileParser)
    Private
        Class Function GetModuleMapfile(AModulename: String): String;
        Procedure ParseMapfile(AMapfile: String);
    Public
        Constructor Create(AAddress: TAdvPointer); Override;
        Destructor Destroy; Override;

        Class Function IsModuleInfoAvailable(AAddress: TAdvPointer): Boolean; Override;
    End;

Implementation

Uses
    SysUtils,
    Classes,
    OIncProcs,
    OVFSPathUtils;

{ TODbgMapfileParser_GeneralMapfile }

Constructor TODbgMapfileParser_GeneralMapfile.Create(AAddress: TAdvPointer);
Begin
    Inherited;

    ParseMapfile(GetModuleMapfile(GetModuleName(AAddress.Addr)));
End;

Destructor TODbgMapfileParser_GeneralMapfile.Destroy;
Begin
    Inherited;
End;

Class Function TODbgMapfileParser_GeneralMapfile.GetModuleMapfile(AModulename: String): String;
Begin
    Result := '';

    If AModulename = '' Then
        Exit;

    If Not FileExists(AModulename) Then
        Exit;

    Result := ChangeFileExt(AModulename, '.map');
    If FileExists(Result) Then
        Exit;

    Result := GetPathFromFile(ExtractFileName(Result));

    If Not FileExists(Result) Then
        Result := '';
End;

Class Function TODbgMapfileParser_GeneralMapfile.IsModuleInfoAvailable(AAddress: TAdvPointer): Boolean;
Var
    ModuleName, ModuleMap: String;
    CodeSegment: TRVABlock;
Begin
    AAddress.Addr := GetModuleOfAddress(AAddress.Ptr);

    ModuleName := GetModuleName(AAddress.Addr);
    ModuleMap := GetModuleMapfile(ModuleName);

    CodeSegment := GetModuleCodeSegment(AAddress.Addr);

    Result := (ModuleMap <> '') And FileExists(ModuleMap) And Assigned(CodeSegment.Ptr.Ptr);
End;

Procedure TODbgMapfileParser_GeneralMapfile.ParseMapfile(AMapfile: String);
Type
    TSegmentEntry = Record
        SegmentIndex: Integer;
        SegmentRVA: TRVABlock;
        SegmentModule: String;
    End;

Var
    MAPSL: TStringList;

    Procedure SkipSegment;
    Begin
        While MAPSL.Count >= 2 Do
        Begin
            If (MAPSL[0] = '') And (MAPSL[1] = '') Then
                Break;
            MAPSL.Delete(0);
        End;
        While (MAPSL.Count > 0) And (MAPSL[0] = '') Do
            MAPSL.Delete(0);
    End;

    Procedure Delete2;
    Begin
        MAPSL.Delete(0);
        MAPSL.Delete(0);
    End;

Const
    MapOfSegs = 'Detailed map of segments';
    PublicsByValue = 'Address         Publics by Value';
    LineNumbersFor = 'Line numbers for ';

Var
    SegmentLine: String;
    SegmentData: TSegmentEntry;
    SegmentFile: String;

    CodeSegment: TRVABlock;

    X: Integer;

    Procedure ParseSegmentLine(Line: String);
    Var
        SegmentNumber: String;
        SegmentRVA: String;
        SegmentSize: String;
        SegmentName: String;
        Len: Integer;

        UnitData: TODbgMapFileUnitInfo;
        UnitDataPtr: PODbgMapfileUnitInfo;
    Begin
        SegmentNumber := '$' + Copy(Line, 1, 4);
        Delete(Line, 1, 5);

        If StrToIntDef(SegmentNumber, 0) <> 1 Then
            Exit;

        SegmentRVA := '$' + Copy(Line, 1, 8);
        Delete(Line, 1, 9);
        SegmentSize := '$' + Copy(Line, 1, 8);
        Delete(Line, 1, 9);

        If Copy(Line, 1, 35) <> 'C=CODE     S=.text    G=(none)   M=' Then
            Exit;
        Delete(Line, 1, 35);

        Len := Pos(' ', Line) - 1;
        If Len < 1 Then
            Len := Length(Line);

        SegmentName := Copy(Line, 1, Len);
        UnitData.UnitName := SegmentName;

        // DONE -omatze@BenBE -cBugFix : #0000014 IntOverflow
        UnitData.UnitPtr.Ptr.Addr := DWORD(StrToInt64Def(SegmentRVA, {$IFOPT Q+}$100000000{$ENDIF} - CodeSegment.Ptr.Addr)) + CodeSegment.Ptr.Addr;
        UnitData.UnitPtr.Size := StrToIntDef(SegmentSize, 0);

        New(UnitDataPtr);
        UnitDataPtr^ := UnitData;
        FUnitInfo.Add(UnitDataPtr);
    End;

    Procedure ParsePublicsLine(Line: String);
    Var
        SegmentNumber: String;
        SegmentRVA: String;
        SegmentName: String;

        PublicData: TODbgMapfilePublicsInfo;
        PublicDataPtr: PODbgMapfilePublicsInfo;
    Begin
        SegmentNumber := '$' + Copy(Line, 1, 4);
        Delete(Line, 1, 5);

        If StrToIntDef(SegmentNumber, 0) <> 1 Then
            Exit;

        SegmentRVA := '$' + Copy(Line, 1, 8);
        Delete(Line, 1, 8);

        SegmentName := Trim(Line);

        PublicData.PublicName := SegmentName;
        PublicData.PublicPtr.Ptr.Addr := DWORD(StrToIntDef(SegmentRVA, 0)) + CodeSegment.Ptr.Addr;
        PublicData.PublicPtr.Size := CodeSegment.Ptr.Addr + CodeSegment.Size - PublicData.PublicPtr.Ptr.Addr;

        New(PublicDataPtr);
        PublicDataPtr^ := PublicData;
        FPublicsInfo.Add(PublicDataPtr);
    End;

    Procedure ParseLineInfo(LineFile: String; Line: String);
    Var
        SpacePos: Integer;
        LineNumber: Integer;
        LineSegment: Integer;
        LineAddress: DWORD;

        LineData: TODbgMapfileLineInfo;
        LineDataPtr: PODbgMapfileLineInfo;
    Begin
        Line := Trim(Line);
        While Line <> '' Do
        Begin
            SpacePos := Pos(#32, Line);

            If SpacePos = 0 Then
                Exit;

            LineNumber := StrToIntDef(Copy(Line, 1, SpacePos - 1), -1);
            Delete(Line, 1, SpacePos);
            LineSegment := StrToIntDef('$' + Copy(Line, 1, 4), 0);
            Delete(Line, 1, 5);
            LineAddress := StrToIntDef('$' + Copy(Line, 1, 8), 0);
            Delete(Line, 1, 8);

            Line := Trim(Line);

            If LineSegment <> 1 Then
                Continue;

            LineData.Line := LineNumber;
            LineData.LineFile := LineFile;
            LineData.LinePtr.Ptr.Addr := LineAddress + CodeSegment.Ptr.Addr;
            LineData.LinePtr.Size := CodeSegment.Ptr.Addr + CodeSegment.Size - LineAddress;

            New(LineDataPtr);
            LineDataPtr^ := LineData;
            FLineInfo.Add(LineDataPtr);
        End;
    End;

Begin
    //DONE -oBenBE -cDbg, Mapfile : Implement TODbgMapfileParser_GeneralMap.ParseMapfile
    CodeSegment := GetModuleCodeSegment(ModuleBase.Addr);

    //If the Mapfile System was unable to determine the Code Segment base, simply exit
    If Not Assigned(CodeSegment.Ptr.Ptr) Then
        Exit;

    MAPSL := TStringList.Create;
    Try
        MAPSL.BeginUpdate;
        Try
            If Not FileExists(AMapfile) Then
                Exit;

            MAPSL.LoadFromFile(AMapfile);

            SkipSegment;

            If Trim(MAPSL[0]) <> MapOfSegs Then
                Exit;

            Delete2;

            While (Trim(MAPSL[0]) <> '') Do
            Begin
                Try
                    ParseSegmentLine(Trim(MAPSL[0]));
                Finally
                    MAPSL.Delete(0);
                End;
            End;

            Repeat
                While Trim(MAPSL[0]) = '' Do
                Begin
                    If MAPSL.Count = 0 Then
                        Exit;

                    MAPSL.Delete(0);
                End;
                SkipSegment;
            Until Trim(MAPSL[0]) = PublicsByValue;

            Delete2;

            While Trim(MAPSL[0]) <> '' Do
            Try
                ParsePublicsLine(Trim(MAPSL[0]));
            Finally
                MAPSL.Delete(0);
            End;

            While Trim(MAPSL[0]) = '' Do
            Begin
                If MAPSL.Count = 0 Then
                    Exit;

                MAPSL.Delete(0);
            End;

            While Copy(Trim(MAPSL[0]), 1, Length(LineNumbersFor)) = LineNumbersFor Do
            Begin
                SegmentLine := Trim(MAPSL[0]);
                Delete(SegmentLine, 1, Length(LineNumbersFor));
                If Pos(')', SegmentLine) <> 0 Then
                    Delete(SegmentLine, Pos(')', SegmentLine), MaxInt);
                If Pos(' ', SegmentLine) <> 0 Then
                    Delete(SegmentLine, Pos(' ', SegmentLine), MaxInt);

                X := Pos('(', SegmentLine);
                If X <> 0 Then
                Begin
                    SegmentData.SegmentModule := Copy(SegmentLine, 1, X - 1);
                    SegmentFile := Copy(SegmentLine, X + 1, MaxInt);
                End
                Else
                Begin
                    SegmentData.SegmentModule := SegmentLine;
                    SegmentFile := SegmentLine;
                End;

                Delete2;

                While Trim(MAPSL[0]) <> '' Do
                Try
                    ParseLineInfo(SegmentFile, Trim(MAPSL[0]));
                Finally
                    MAPSL.Delete(0);
                End;

                While Trim(MAPSL[0]) = '' Do
                Begin
                    If MAPSL.Count = 0 Then
                        Exit;

                    MAPSL.Delete(0);
                End;
            End;
        Finally
            MAPSL.EndUpdate;
        End;
    Finally
        FreeAndNil(MAPSL);
    End;
End;

Initialization
    RegisterMapfileParser(TODbgMapfileParser_GeneralMapfile);
Finalization
    UnregisterMapfileParser(TODbgMapfileParser_GeneralMapfile);
End.
