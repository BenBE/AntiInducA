Unit ODbgMapfile;
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

Interface

Uses
    Windows,
    SysUtils,
    Classes,
    OIncTypes;

Type
    TODbgMapfileParser = Class(TObject)
    Private
        FBaseAddress: TAdvPointer;
        FModuleSize: DWORD;
        FModuleName: String;
    Protected
        FUnitInfo: TList;
        FLineInfo: TList;
        FPublicsInfo: TList;
    Public
        Constructor Create(AAddress: TAdvPointer); Reintroduce; Virtual;
        Destructor Destroy; Override;
        Procedure AfterConstruction; Override;

        Class Function IsModuleInfoAvailable(AAddress: TAdvPointer): Boolean; Virtual; Abstract;

        Function QuerySymbol(AAddress: TAdvPointer): TODbgMapfileSymInfo;

        Property ModuleBase: TAdvPointer Read FBaseAddress;
        Property ModuleSize: DWORD Read FModuleSize;
        Property ModuleName: String Read FModuleName;
    End;

    TODbgMapfileParserClass = Class Of TODbgMapfileParser;

Function AddressToLocation(AAddress: Pointer): TODbgMapLocation;
Function PlaceToLocationStr(Place: TODbgMapLocation): String;

Function GetModuleOfAddress(AAddress: Pointer): HMODULE;
Function GetModuleExtractFilename(AModule: HMODULE): String;
Function GetModuleCodeSegment(AModule: HMODULE): TRVABlock;

Procedure RegisterMapfileParser(AMapfileParser: TODbgMapfileParserClass);
Procedure UnregisterMapfileParser(AMapfileParser: TODbgMapfileParserClass);

Implementation

Uses
{$IFDEF DELPHI6_UP}
    StrUtils,
{$ENDIF}
    Contnrs,
    Math,
    OIncProcs,
    OMathGeneral,
    ODbgInterface,
    ODbgMapfileGeneralMap,
    ODbgMapfileExports;

Var
    MapfileParserList: TClassList = Nil;
    MapfileParserObjects: TObjectList = Nil;

Function GetModuleOfAddress(AAddress: Pointer): HMODULE;
Var
    lpBuffer: TMemoryBasicInformation;
Begin
    If VirtualQuery(AAddress, lpBuffer, SizeOf(lpBuffer)) <> 0 Then
        Result := HMODULE(lpBuffer.AllocationBase)
    Else
        Result := 0;
End;

Function GetModuleExtractFilename(AModule: HMODULE): String;
Var
    ModName: Array[0..MAX_PATH] Of Char;
Begin
    // MSG BenBE : Fix für Warnmeldung unter FreePascal
    Result := '';
    SetString(Result, ModName, GetModuleFilename(AModule, ModName, SizeOf(ModName)));
    Result := ExtractFileName(Result);
End;

Function GetModuleCodeSegment(AModule: HMODULE): TRVABlock;
Var
    MZ: PImageDosHeader;
    PE: PImageNtHeaders;
    Sec: PImageSectionHeader;
    I: Integer;
Begin
    Result.Ptr.Ptr := Nil;
    Result.Size := 0;

    If AModule < $00010000 Then
        Exit;

    MZ := PImageDosHeader(AModule);

    If IsBadReadPtr(MZ, SizeOf(TImageDosHeader)) Then
        Exit;

    If MZ^.e_magic <> IMAGE_DOS_SIGNATURE Then
        Exit;

    {$IFNDEF FPC}
    TAdvPointer(PE).Addr := TAdvPointer(MZ).Addr + DWORD(MZ^._lfanew);
    {$ELSE}
    TAdvPointer(PE).Addr := TAdvPointer(MZ).Addr + DWORD(MZ^.e_lfanew);
    {$ENDIF}

    If PE.Signature <> IMAGE_NT_SIGNATURE Then
        Exit;

    Result.Ptr.Addr := 0;

    TAdvPointer(Sec).Addr := DWORD(PE) + SizeOf(TImageNtHeaders);
    If (((Sec^.Characteristics And IMAGE_SCN_MEM_EXECUTE) = IMAGE_SCN_MEM_EXECUTE) Or
        ((Sec^.Characteristics And IMAGE_SCN_CNT_CODE) = IMAGE_SCN_CNT_CODE)) Or
        (PDWORD(@Sec^.Name[0])^ = $45444F43) Or (PDWORD(@Sec^.Name[0])^ = $30585055) Then
    Begin
        Result.Ptr.Addr := AModule + Sec^.VirtualAddress;
        Result.Size := Sec^.Misc.VirtualSize;
    End;

    If Result.Ptr.Addr = 0 Then
    Begin
        For I := 1 To PE^.FileHeader.NumberOfSections - 1 Do
        Begin
            TAdvPointer(Sec).Addr := DWORD(PE) + SizeOf(TImageNtHeaders) + DWORD(I * SizeOf(TImageSectionHeader));
            If (Sec^.Characteristics And IMAGE_SCN_CNT_CODE) = IMAGE_SCN_CNT_CODE Then
            Begin
                If Result.Ptr.Addr = 0 Then
                Begin
                    Result.Ptr.Addr := AModule + Sec^.VirtualAddress;
                    Result.Size := Sec^.Misc.VirtualSize;
                End
                Else If (PE^.OptionalHeader.AddressOfEntryPoint > Sec^.VirtualAddress) And
                    (PE^.OptionalHeader.AddressOfEntryPoint < Sec^.VirtualAddress + Sec^.Misc.VirtualSize) Then
                Begin
                    Result.Ptr.Addr := AModule + Sec^.VirtualAddress;
                    Result.Size := Sec^.Misc.VirtualSize;
                End;
            End;
        End;
    End;

    If Result.Ptr.Addr = 0 Then
    Begin
        Result.Ptr.Addr := AModule + PE.OptionalHeader.BaseOfCode;
        Result.Size := PE.OptionalHeader.SizeOfCode;
    End;
End;

Function GetModuleMapFileData(AModule: HMODULE): TODbgMapfileParser;
Var
    X: Integer;
    A, B: Integer;
    T1, T2, T3: Int64;
    TmpClass: TODbgMapfileParserClass;
    TmpPtr: TAdvPointer;
Begin
    //Validate the data Pointer of the Module Handle
    TmpPtr := TAdvPointer(AModule);
    TmpPtr.Addr := GetModuleOfAddress(TmpPtr.Ptr);
    AModule := TmpPtr.Addr;

    //If the Module is nil we don't even need to query any further information
    Result := Nil;
    If AModule = 0 Then
        Exit;

    //If no object lists assigned simply return nil
    If Not Assigned(MapfileParserList) Then
        Exit;
    If Not Assigned(MapfileParserObjects) Then
        Exit;

    //Perform a binary search on the data objects.
    B := MapfileParserObjects.Count;
    If B <> 0 Then
    Begin
        A := 0;

        Repeat
            //Check for the location relative to the current element
            X := (A + B) Shr 1;

            Result := TODbgMapfileParser(MapfileParserObjects[X]);

            If Result.ModuleBase.Addr = TmpPtr.Addr Then
            Begin
                Exit;
            End
            Else If Result.ModuleBase.Addr < TmpPtr.Addr Then
            Begin
                //Desired object is located behind current --> Add DeltaX if possible
                If A = X Then
                    A := B
                Else
                    A := X;
            End
            Else
            Begin
                //Desired object is located before current --> Sub DeltaX if possible
                B := X;
            End;
        Until A = B;
    End
    Else
    Begin
        X := B;
    End;

    //BenBE: X now contains the index the new object should be inserted if found
    QueryPerformanceCounter(T1);
    Result := Nil;

    For A := 0 To MapfileParserList.Count - 1 Do
    Begin
        TmpClass := TODbgMapfileParserClass(MapfileParserList[A]);
        If TmpClass.IsModuleInfoAvailable(TmpPtr) Then
        Begin
            Result := TmpClass.Create(TmpPtr);
            Break;
        End;
    End;

    If Assigned(Result) Then
    Begin
        If X < MapfileParserObjects.Count Then
        Begin
            While TODbgMapfileParser(MapfileParserObjects[X]).ModuleBase.Addr < Result.ModuleBase.Addr Do
            Begin
                Inc(X);
                If X >= MapfileParserObjects.Count Then
                    Break;
            End;
        End;
        MapfileParserObjects.Insert(X, Result);
    End;

    QueryPerformanceCounter(T2);
    QueryPerformanceFrequency(T3);

    If Assigned(Result) Then
        OmorphiaDebugStr(vl_Timing, '', Format('Requesting Symbols for ''%s'' took %.2f ms.', [GetModuleExtractFilename(AModule), 1000 * (T2 - T1) / T3]));
End;

Function AddressToLocation(AAddress: Pointer): TODbgMapLocation;
Var
    Module: HMODULE;
    ModuleName: String;
    ModuleInfo: TODbgMapfileParser;
    AdvPtr: TAdvPointer Absolute AAddress;
Begin
    Module := GetModuleOfAddress(AAddress);
    ModuleName := GetModuleExtractFilename(Module);
    ModuleInfo := GetModuleMapFileData(Module);

    If Assigned(ModuleInfo) Then
        Result := ModuleInfo.QuerySymbol(AdvPtr).Info
    Else
    Begin
        Result.Address := AdvPtr.Addr;
        Result.Module := Module;
        Result.ModuleRVA := Result.Address - Result.Module;
        Result.ModuleName := ModuleName;
        Result.UnitName := '';
        Result.ProcName := '';
        Result.UnitSource := '';
        Result.UnitSourceLine := -1;
    End;
End;

Function PlaceToLocationStr(Place: TODbgMapLocation): String;
Begin
    Result := IntToHex(Place.Address, 8) + '@';

    If Place.UnitName <> '' Then
    Begin
        If Place.ModuleName <> '' Then
            Result := Result + Place.ModuleName + '\' + Place.UnitName
        Else
            Result := Result + Place.UnitName;

        If (Place.UnitSourceLine > 0) Then
        Begin
            If LowerCase(Place.UnitName + '.pas') = LowerCase(ExtractFileName(Place.UnitSource)) Then
                Result := Result + Format('(%.5d)', [Place.UnitSourceLine])
            Else
                Result := Result + Format('(%s %.5d)', [ExtractFileName(Place.UnitSource), Place.UnitSourceLine]);
        End;

        If Place.ProcName <> '' Then
            Result := Result + ' in ' + Place.ProcName;
    End
    Else
    Begin
        If Place.ModuleName <> '' Then
        Begin
            If Place.ProcName <> '' Then
                Result := Result + Place.ModuleName + ' in ' + Place.ProcName
            Else
                Result := Result + Place.ModuleName;
        End
        Else
            Result := Result + Place.ProcName;
    End;
End;

Procedure RegisterMapfileParser(AMapfileParser: TODbgMapfileParserClass);
Begin
    If Not Assigned(AMapfileParser) Then
        Exit;

    If Not Assigned(MapfileParserList) Then
    Begin
        MapfileParserList := TClassList.Create;
        OmorphiaDebugStr(vl_Warning, '', 'The Mapfile Parser List is not initialized. Initializing to empty list.');
    End;

    If Not Assigned(MapfileParserObjects) Then
    Begin
        MapfileParserObjects := TObjectList.Create(True);
        OmorphiaDebugStr(vl_Warning, '', 'The Mapfile Parser Object List is not initialized. Initializing to empty list.');
    End;

    If MapfileParserList.IndexOf(AMapfileParser) = -1 Then
        MapfileParserList.Add(AMapfileParser)
    Else
        OmorphiaDebugStr(vl_Hint, '', 'Class ' + AMapfileParser.ClassName + ' has already been added.');
End;

Procedure UnregisterMapfileParser(AMapfileParser: TODbgMapfileParserClass);
Var
    X: Integer;
Begin
    If Not Assigned(AMapfileParser) Then
        Exit;

    If Not Assigned(MapfileParserList) Then
    Begin
        OmorphiaDebugStr(vl_Error, '', 'The Mapfile Parser list is not assigned!');
        Exit;
    End;

    If Not Assigned(MapfileParserObjects) Then
    Begin
        OmorphiaDebugStr(vl_Error, '', 'The Mapfile Parser list is not assigned!');
        Exit;
    End;

    X := MapfileParserList.Remove(AMapfileParser);
    If X = -1 Then
        OmorphiaDebugStr(vl_Hint, '', 'Class ' + AMapfileParser.ClassName + ' not found on the list.');

    While MapfileParserObjects.FindInstanceOf(AMapfileParser, True) <> -1 Do
        MapfileParserObjects.Delete(MapfileParserObjects.FindInstanceOf(AMapfileParser, True));
End;

{ TODbgMapfileParser }

Procedure TODbgMapfileParser.AfterConstruction;

    Function SortPtr(Ptr1, Ptr2: Pointer): Integer;
    Var
        DataPtr1: ^TRVABlock Absolute Ptr1;
        DataPtr2: ^TRVABlock Absolute Ptr2;
    Begin
        If DataPtr1^.Ptr.Addr > DataPtr2^.Ptr.Addr Then
            Result := 1
        Else If DataPtr1^.Ptr.Addr < DataPtr2^.Ptr.Addr Then
            Result := -1
        Else
            Result := 0;
    End;

    Procedure FixRVAData(List: TList);
    Var
        X: Integer;
        RVA1, RVA2: ^TRVABlock;
    Begin
        For X := List.Count - 2 Downto 0 Do
        Begin
            RVA1 := List[X];
            RVA2 := List[X + 1];
            //TODO -oBenBE@BenBE -cDebug, Mapfile : Bereichsgrößen-Einschränkung funktioniert nicht korrekt.
            If Int64(RVA1.Ptr.Addr) + Int64(RVA1.Size) > Int64(RVA2.Ptr.Addr) Then
                RVA1.Size := RVA2.Ptr.Addr - RVA1.Ptr.Addr;
        End;
    End;

Begin
    Inherited;

    FUnitInfo.Capacity := FUnitInfo.Count;
    FUnitInfo.Sort(@SortPtr);
    FixRVAData(FUnitInfo);

    FLineInfo.Capacity := FLineInfo.Count;
    FLineInfo.Sort(@SortPtr);
    FixRVAData(FLineInfo);

    FPublicsInfo.Capacity := FPublicsInfo.Count;
    FPublicsInfo.Sort(@SortPtr);
    FixRVAData(FPublicsInfo);
End;

Constructor TODbgMapfileParser.Create(AAddress: TAdvPointer);
Var
    MBI: TMemoryBasicInformation;

Begin
    Inherited Create;

    FBaseAddress.Addr := GetModuleOfAddress(AAddress.Ptr);

    FModuleName := GetModuleExtractFilename(FBaseAddress.Addr);

    FModuleSize := 0;
    If VirtualQuery(FBaseAddress.Ptr, MBI, SizeOf(MBI)) = SizeOf(MBI) Then
        FModuleSize := MBI.RegionSize;

    FUnitInfo := TList.Create;
    FUnitInfo.Capacity := 256;

    FLineInfo := TList.Create;
    FLineInfo.Capacity := 16384;

    FPublicsInfo := TList.Create;
    FPublicsInfo.Capacity := 2048;
End;

Destructor TODbgMapfileParser.Destroy;
Var
    P: Pointer;
Begin
    While FPublicsInfo.Count > 0 Do
    Begin
        P := FPublicsInfo[0];
        FPublicsInfo.Delete(0);
        Dispose(P);
    End;
    FreeAndNilSecure(FPublicsInfo);

    While FLineInfo.Count > 0 Do
    Begin
        P := FLineInfo[0];
        FLineInfo.Delete(0);
        Dispose(P);
    End;
    FreeAndNilSecure(FLineInfo);

    While FUnitInfo.Count > 0 Do
    Begin
        P := FUnitInfo[0];
        FUnitInfo.Delete(0);
        Dispose(P);
    End;
    FreeAndNilSecure(FUnitInfo);

    FBaseAddress.Ptr := Nil;

    Inherited;
End;

Function TODbgMapfileParser.QuerySymbol(AAddress: TAdvPointer): TODbgMapfileSymInfo;
Var
    ModuleUnit: PODbgMapfileUnitInfo;
    ModuleLine: PODbgMapfileLineInfo;
    ModulePublic: PODbgMapfilePublicsInfo;

    Function FindFittingRVA(AAddress: TAdvPointer; List: TList): Integer;
    Var
        RVA: TRVABlock;
        X: Integer;
        A, B: Integer;
    Begin
        Result := -1;

        A := 0;
        B := List.Count;

        While A <> B Do
        Begin
            X := (A + B) Shr 1;
            RVA := TRVABlock(List[X]^);
            If (RVA.Ptr.Addr <= AAddress.Addr) And (RVA.Ptr.Addr + RVA.Size > AAddress.Addr) Then
            Begin
                Result := X;
                Exit;
            End
            Else If RVA.Ptr.Addr > AAddress.Addr Then                           //Current RVA block is behind the searched address
            Begin
                B := X;
            End
            Else
            Begin
                If A = X Then
                    A := B
                Else
                    A := X;
            End;
        End;
    End;

Var
    TmpIdx: Integer;
Begin
    // DONE -oBenBE -cDbg, Mapfile : Implement TODbgMapfileParser.QuerySymbol

    Result.Info.Address := AAddress.Addr;
    Result.Info.Module := ModuleBase.Addr;
    Result.Info.ModuleRVA := Result.Info.Address - Result.Info.Module;
    Result.Info.ModuleName := ModuleName;

    ModuleUnit := Nil;
    TmpIdx := FindFittingRVA(AAddress, FUnitInfo);
    If TmpIdx <> -1 Then
        ModuleUnit := PODbgMapfileUnitInfo(FUnitInfo[TmpIdx]);

    ModulePublic := Nil;
    TmpIdx := FindFittingRVA(AAddress, FPublicsInfo);
    If TmpIdx <> -1 Then
        ModulePublic := PODbgMapfilePublicsInfo(FPublicsInfo[TmpIdx]);

    ModuleLine := Nil;
    TmpIdx := FindFittingRVA(AAddress, FLineInfo);
    If TmpIdx <> -1 Then
        ModuleLine := PODbgMapfileLineInfo(FLineInfo[TmpIdx]);

    If Assigned(ModuleUnit) Then
    Begin
        Result.Info.UnitName := ModuleUnit^.UnitName;
        Result.Symbol := ModuleUnit^.UnitPtr;
    End;

    If Assigned(ModulePublic) Then
    Begin
        Result.Info.ProcName := ModulePublic^.PublicName;
        Result.Symbol := ModulePublic^.PublicPtr;
    End;

    If Assigned(ModuleLine) Then
    Begin
        Result.Info.UnitSource := ModuleLine^.LineFile;
        Result.Info.UnitSourceLine := ModuleLine^.Line;
        Result.Symbol := ModuleLine^.LinePtr;
    End;
End;

Initialization
    If Not Assigned(MapfileParserList) Then
        MapfileParserList := TClassList.Create;
    If Not Assigned(MapfileParserObjects) Then
        MapfileParserObjects := TObjectList.Create(True);
Finalization
    If Assigned(MapfileParserObjects) Then
        FreeAndNilSecure(MapfileParserObjects);
    If Assigned(MapfileParserList) Then
        FreeAndNilSecure(MapfileParserList);
End.
