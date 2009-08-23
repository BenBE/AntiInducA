Unit OIncProcs;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Base Code
//
// This unit defines helper functions.
//
// *****************************************************************************
// To Do:
//  ToDo -oAll -cInc, Procs : Optimieren der Funktionen
//  ToDo -oNeo -cInc, Procs : Dokumentieren des Codes
//  DONE -oNeo -cInc, Procs : Konverter-Code für String to Real etc...
//  ToDo -oNeo -cInc, Procs : ExecuteCmd mit Ausgabeumleitung
//  ToDo -oBenBE@Neo -cInc, Procs : Statische Puffer durch dynamische Arrays als Puffer ersetzen
//  DONE -oNeo -cInc, Procs : RaiseException-Befehle durch OmorphiaErrorStr-Aufrufe ersetzen
//  ToDo -oBenBE -cInc, Procs : Nur notwendige Privileges mit RemoteShutdown anfordern
//  DONE -oBenBE -cInc, Procs : More accurate Function for OS Versions taken directly from MSPSDK 08\2004
//
// *****************************************************************************
// News:
//  matze: Funktion zum senden einer Mail per Mapi hinzugefügt
//  matze: Einige Fehler in den Kommentaren berichtigt
//  Neo: einige Komentare hinzugefügt
//  BenBE: Einige Funktionsnamen und Enum-Bezeichner geändert
//  BenBE: Entfernen der IntoToOrd\IntToFloat-Funktionen, da Direktzuweisung möglich
//  BenBE: Implementation der GetComputerInfo-Function
//  BenBE: Fehlerbeseitigung bei API-Funktionen
//  BenBE: Extended Windows Version Information String
//  BenBE: Unterscheiden von CD und DVD-Laufwerken.
//  BenBE: Procedure FreeAndNilSecure, die überprüft, ob ein mit FreeAndNil freizugebendes Object überhaupt Assigned ist
//
// *****************************************************************************
// Bugs:
//  TODO -oNeo -cInc, Procs : Kleinigkeiten
//  DONE -oBenBE -cBug, Inc, Procs : Private Funktionen exportieren (Inteface aktualisieren)
//  DONE -oBenBE -cBug, Inc, Procs : RebootWindows hat Remote-Privilege nicht angefordert, wenn RemoteShutdown
//  DONE -oBenBE -cBug, Inc, Procs : RebootWindows hat Privilegien nicht korrekt freigegeben
//  DONE -oBenBE -cBug, Inc, Procs : RebootWindows hat unter Win9x\Me vReboot und vForce ignoriert
//  DONE -oBenBE -cBug, Inc, Procs : RebootWindows bringt keinen Fehler bei RemoteShutdown-Versuch unter Win9x
//  DONE -oBenBE -cBug, Inc, Procs : Inkorrekte Erkennung von AMD-K7 Speed Suffix (Standardmäßig wird Athlon XP 1600+ angezeigt)
//  TODO 5 -oBenBE, Neo -cSecurity, Inc, Procs : Einfache Implementationsweise zur Programmierung von Viren ausnutzbar!
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
    Graphics,
    TypInfo,
    OIncTypes;

Function BindFunction(DLL: THandle; Name: String; ForceImport: Boolean = True): Pointer;
Function CheckForVersion(Const AVersion, RequiredVersion: TVersion): Boolean; Register;
Function GetModuleName(Handle: THandle): String;
Function IsValidHandle(Const Handle: THandle): Boolean;
Function VerStrToLibVersion(Version: String): TVersion;

// *****************************************************************************
// Name          : GetUserName
// Parameter     : keine
// Resulttype    : String
// Beschreibung  : Gibt den aktuellen Benutzernamen zurück
// *****************************************************************************
Function GetUserName: String;

// *****************************************************************************
// Name          : GetComputerName
// Parameter     : keine
// Resulttype    : String
// Beschreibung  : Gibt den aktuellen Computernamen zurück
// *****************************************************************************
Function GetComputerName: String;

// *****************************************************************************
// Name          : RebootWindows(vSystem, vMessage vForce, vReboot)
// Parameter     : vSystem(String)      = ?
//                 vMessage(String)     = Nachricht ausgeben
//                 vForce(Boolean)      = ?
//                 vReboot(Boolean)     = Neustart oder Runterfahren
// Resulttype    : Integer =
// Beschreibung  : Startet Windows Neu
// *****************************************************************************
Function RebootWindows(vSystem, vMessage: String; vForce, vReboot: Boolean; vDuration: Integer): Boolean;

// *****************************************************************************
// Name          : OpenCDDrive(vDrive)
// Parameter     : vDrive(Char) = CD-ROM Buchstabe
// Resulttype    : keine
// Beschreibung  : Öffnet das angegebenne CDROM Laufwerk
// *****************************************************************************
Procedure OpenCDDrive(vDrive: Char);                                            // Neo: geht zur zeit nur auf CD-Drive 0

// *****************************************************************************
// Name          : CloseCDDrive(vDrive)
// Parameter     : vDrive(Char) = CD-Rom Buchstabe
// Resulttype    : keine
// Beschreibung  : Schließt das angegebenne CDRom Laufwerk
// *****************************************************************************
Procedure CloseCDDrive(vDrive: Char);                                           // Neo: geht zur zeit nur auf CD-Drive 0

// *****************************************************************************
// Name          : DriveCaption(vDrive)
// Parameter     : vDrive(Char) = CD-Rom Buchstabe
// Resulttype    : keine
// Beschreibung  : Gibt den Datenträger Titel zurück
// *****************************************************************************
Function DriveCaption(vDrive: Char): String;

Function DriveType(vDrive: Char): TDriveType;
Function DriveTypeStr(vDrive: Char): String;

// *****************************************************************************
// Name          : CreateUniqueFileName(vFileName)
// Parameter     : vFileName(String) = Basis Dateinamen
// Resulttype    : String
// Beschreibung  : Erzeugt einen eindeutigen Filename auf Basis des angegebennen
// *****************************************************************************
Function CreateUniqueFileName(vFileName: String): String;

// *****************************************************************************
// Name          : WindowsMode
// Parameter     : keine
// Resulttype    : tWinMode
// Beschreibung  : Gibt den Windows Modus zurück
// *****************************************************************************
Function WindowsMode: TWinMode;

// *****************************************************************************
// Name          : WindowsModeStr
// Parameter     : keine
// Resulttype    : String
// Beschreibung  : Gibt den Windows Modus als String zurück
// *****************************************************************************
Function WindowsModeStr: String;

// *****************************************************************************
// Name          : GetEnvVarValue
// Parameter     : AName(String) = Benötigte Umgebungsvariable
// Resulttype    : String
// Beschreibung  : Gibt den Wert einer Umgebungsvariable zurück
// *****************************************************************************
Function GetEnvVarValue(AName: String): String;

// *****************************************************************************
// Name          : Space(vSpaceLength, vText, vSpaceChar)
// Parameter     : vSpaceLength(Integer) =
//                 vText(String)         =
//                 vSpaceChar(Char)      =
// Resulttype    : String
// Beschreibung  : Erzeugt einen String mit "vText" aufgefüllt mit "vSpaceChar" mit
//                 der gesamt länge von "vSpaceLength.
// *****************************************************************************
Function Space(vSpaceLength: Integer; vText: String; vSpaceChar: Char): String;

// *****************************************************************************
// Name          : IntToStr(AValue)
// Parameter     : AValue(Integer) =
// Resulttype    : String
// Beschreibung  : Wandelt eine Integer Wert in einen String um.
// *****************************************************************************
Function IntToStr(AValue: Integer): String;
Function IntToBool(AValue: Integer): Boolean;

// *****************************************************************************
// Name          : Hex(AValue)
// Parameter     : AValue(Integer) =
// Resulttype    : String
// Beschreibung  : Wandelt einen Integer in eine HexString um.
// *****************************************************************************
Function Hex(AValue: Integer): String;

// *****************************************************************************
// Name          : HexExt(AValue)
// Parameter     : AValue(Integer) =
// Resulttype    : String
// Beschreibung  : Wandelt einen Integer in eine String mit HexString um.
// *****************************************************************************
Function HexExt(AValue: Integer): String;

// *****************************************************************************
// Name          : PtrToString(AValue)
// Parameter     : AValue(Pointer) =
// Resulttype    : String
// Beschreibung  : Wandelt einen Pointer in eine String um.
// *****************************************************************************
Function PtrToStr(AValue: Pointer): String;

{ StrTo... }
Function StrToByte(vText: String): Byte;
Function StrToWord(vText: String): Word;
Function StrToInt(vText: String): Integer;
Function StrToReal(vText: String): Real;
Function StrToCurrency(vText: String): Currency;
Function StrToBool(vText: String): Boolean;

{ RealTo... }
Function RealToByte(AValue: Real): Byte;
Function RealToWord(AValue: Real): Word;
Function RealToInt(AValue: Real): Integer;
Function RealToCurrency(AValue: Real): Currency;
Function RealToBool(AValue: Real): Boolean;
Function RealToStr(AValue: Real): String;

{ BoolTo...}
Function BoolToByte(AValue: Boolean): Byte;
Function BoolToWord(AValue: Boolean): Word;
Function BoolToInt(AValue: Boolean): Integer;
Function BoolToReal(AValue: Boolean): Real;
Function BoolToCurrency(AValue: Boolean): Currency;
Function BoolToStr(AValue: Boolean): String;

Function ByteToBinaryStr(AValue: Byte): String;
Function WordToBinaryStr(AValue: Word): String;
Function DWordToBinaryStr(AValue: DWORD): String;

// Gibt die aktuelle Sprache des Systems zurück
Function GetOSLanguage: String;

// Neo: newline for text output, OS spezific
Function NewLine: String;

// Neo: check if the installed user.exe\OS kernel a debug release
Function IsAdministrator: Boolean;
Function IsWorkstationLocked: Boolean;
Function HasSoundcard: Boolean;

Function SendEMail(Handle: THandle; Mail: TStrings): Cardinal;

Function GetDataSizeStr(Size: Int64): String;

Function SwapBytes(A: DWORD): DWORD;
Function SwapBits(A: DWORD; N: Byte): DWORD;
Function IsBitSet(Const BitSet: DWORD; Const Bit: Byte): Boolean;

// Neo: get place for Text in given Font
Function GetSizeXOfTextByFont(AText: String; AFont: TFont): Integer;
Function GetSizeYOfTextByFont(AText: String; AFont: TFont): Integer;

Function GetEXEVersionStr(AFileName: String; AVersionField: String): String;

//Enum and Set Type Identifier Name Resolution routines
Function EnumValueToStr(AValue: Integer; ATypeInfo: PTypeInfo): String;
Function SetValueToStr(AValue: Integer; ATypeInfo: PTypeInfo; Brackets: Boolean): String;

Procedure FreeAndNilSecure(Var Obj);

Function Split(Var S: String; Const Del: String): String;

Implementation

Uses
    Forms,
    Mapi,
    MMSystem,
    ODbgInterface,
    OIncConsts,
    OSysOSInfo,
    OLangGeneral;

Function GetEXEVersionStr(AFileName: String; AVersionField: String): String;
// AVersionField Names:
//   CompanyName
//   FileDescription
//   FileVersion
//   InternalName
//   LegalCopyright
//   LegalTradeMarks
//   OriginalFileName
//   ProductName
//   ProductVersion
//   Comments
Var
    BufferSize: DWORD;
    Buffer: Pointer;
    ValueSize: DWORD;
    Value: Pointer;
Begin
    Result := '';
    BufferSize := GetFileVersionInfoSize(PChar(AFileName), BufferSize);
    If BufferSize > 0 Then
    Begin
        GetMem(Buffer, BufferSize);
        Try
            If Not GetFileVersionInfo(PChar(AFileName), 0, BufferSize, Buffer) Then
                Exit;

            ValueSize := 255;
            GetMem(Value, ValueSize);
            Try
                //                AVersionField := '\StringFileInfo\0409\';
                If VerQueryValue(Buffer, PChar(AVersionField), Value, ValueSize) Then
                    Result := PChar(Value)
                Else
                    Result := '???';
                // DONE -oNeo@BenBE -cFileVersion : Kannst du bitte mein Memory Exception lösen, und evtl. testen ob ich da nen fehler drin habe! Thx
            Finally
                FreeMem(Value, ValueSize);
            End;
        Finally
            FreeMem(Buffer, BufferSize);
        End;
    End;
End;

Function GetSizeXOfTextByFont(AText: String; AFont: TFont): Integer;
Var
    Temp: TCanvas;
Begin
    Temp := TCanvas.Create;
    Try
        Temp.Font.Assign(AFont);
        Result := Temp.TextWidth(AText);
    Finally
        Temp.Free;
    End;
End;

Function GetSizeYOfTextByFont(AText: String; AFont: TFont): Integer;
Var
    Temp: TCanvas;
Begin
    Temp := TCanvas.Create;
    Try
        Temp.Font.Assign(AFont);
        Result := Temp.TextHeight(AText);
    Finally
        Temp.Free;
    End;
End;

// BenBE: Funktion für Workstation-Verwaltung.
// Function by Thomas Stutz (SDC TipsDB): Überprüfen, ob Workstation gesperrt ist.
// Original found here: http://www.swissdelphicenter.com/de/showcode.php?id=2048

Function IsWorkstationLocked: Boolean;
Var
    hDesktop: HDESK;
Begin
    Result := False;
    hDesktop := OpenDesktop('default', 0, False, DESKTOP_SWITCHDESKTOP);
    If IsValidHandle(hDesktop) Then
    Begin
        Result := Not SwitchDesktop(hDesktop);
        CloseDesktop(hDesktop);
    End;
    DbgResetOSError;
End;

// OS Spezific Stuff

Function BindFunction(DLL: THandle; Name: String; ForceImport: Boolean = True): Pointer;
Begin
    //    DbgHint(Format('BindFunction(%.8x, ''%s'')', [DLL, Name]), 0, 'OGfxImport.BindFunction');
    If Not IsValidHandle(DLL) Then
        OmorphiaErrorStr(vl_Error, '', GfxLibraryNotLoaded);

    Result := GetProcAddress(DLL, PChar(Name));

    If ForceImport And Not Assigned(Result) Then
        OmorphiaErrorStr(vl_Error, '', Format(GfxLibraryFunctionNotFound, [Name, GetModuleName(DLL)]));
End;

Function CheckForVersion(Const AVersion, RequiredVersion: TVersion): Boolean;
Asm
    MOV     ECX, AVersion.TVersion.Major
    CMP     ECX, RequiredVersion.TVersion.Major
    JB      @@False
    JA      @@True
    MOV     ECX, AVersion.TVersion.Minor
    CMP     ECX, RequiredVersion.TVersion.Minor
    JB      @@False
@@True:
    XOR     EAX, EAX
    INC     EAX
    JMP     @@Ret
@@False:
    XOR     EAX, EAX
@@Ret:
End;

Function GetModuleName(Handle: THandle): String;
Var
    Buf: Array Of Char;
    BufSize: Integer;
Begin
    BufSize := StdBufferSize;
    SetLength(Buf, BufSize);
    GetModuleFilename(Handle, @Buf[0], BufSize);
    Result := StrPas(@Buf[0]);
End;

Function IsValidHandle(Const Handle: THandle): Boolean;
{$IFDEF OMORPHIA_FEATURES_USEASM} Assembler;
Asm
    TEST    EAX, EAX
    JZ      @@Finish
    NOT     EAX
    TEST    EAX, EAX
    SETNZ   AL

    {$IFDEF WINDOWS}
    JZ      @@Finish

    //Save the handle against modifications or loss
    PUSH    EAX

    //reserve some space for a later duplicate
    PUSH    EAX

    //Check if we are working on NT-Platform
    CALL    IsWindowsNTSystem
    TEST    EAX, EAX
    JZ      @@NoNTSystem

    PUSH    DWORD PTR [ESP]
    LEA     EAX, DWORD PTR [ESP+$04]
    PUSH    EAX
    CALL    GetHandleInformation
    TEST    EAX, EAX
    JNZ     @@Finish2

@@NoNTSystem:
    //Result := DuplicateHandle(GetCurrentProcess, Handle, GetCurrentProcess,
    //  @Duplicate, 0, False, DUPLICATE_SAME_ACCESS);
    PUSH    DUPLICATE_SAME_ACCESS
    PUSH    $00000000
    PUSH    $00000000
    LEA     EAX, DWORD PTR [ESP+$0C]
    PUSH    EAX
    CALL    GetCurrentProcess
    PUSH    EAX
    PUSH    DWORD PTR [ESP+$18]
    PUSH    EAX
    CALL    DuplicateHandle

    TEST    EAX, EAX
    JZ      @@Finish2

    //  Result := CloseHandle(Duplicate);
    PUSH    DWORD PTR [ESP]
    CALL    CloseHandle

@@Finish2:
    POP     EDX
    POP     EDX

    PUSH    EAX
    PUSH    $00000000
    CALL    SetLastError
    POP     EAX
    {$ENDIF}

@@Finish:
End;
{$ELSE}
Var
    Duplicate: THandle;
    Flags: DWORD;
Begin
    If IsWinNT Then
        Result := GetHandleInformation(Handle, Flags)
    Else
        Result := False;
    If Not Result Then
    Begin
        // DuplicateHandle is used as an additional check for those object types not
        // supported by GetHandleInformation (e.g. according to the documentation,
        // GetHandleInformation doesn't support window stations and desktop although
        // tests show that it does). GetHandleInformation is tried first because its
        // much faster. Additionally GetHandleInformation is only supported on NT...
        Result := DuplicateHandle(GetCurrentProcess, Handle, GetCurrentProcess,
            @Duplicate, 0, False, DUPLICATE_SAME_ACCESS);
        If Result Then
            Result := CloseHandle(Duplicate);
    End;
End;
{$ENDIF}

Function VerStrToLibVersion(Version: String): TVersion;
Var
    VerPart: String;
    VMaj, VMin: String;
Begin
    Result.Major := 0;
    Result.Minor := 0;

    If Version = '' Then
        Exit;

    // Done -oNeo -cInc, Procs : Versionsstring in Versionsinfo umwandeln
    If Pos(' ', Version) <> 0 Then
        VerPart := Copy(Version, 1, Pos(' ', Version) - 1)
    Else
        VerPart := Version;

    If Pos('.', VerPart) = 0 Then
    Begin
        Result.Major := StrToInt(VerPart);
        Exit;
    End;

    VMaj := Copy(VerPart, 1, Pos('.', VerPart) - 1);
    Result.Major := StrToInt(VMaj);

    Delete(VerPart, 1, Pos('.', VerPart));

    If Pos('.', VerPart) = 0 Then
    Begin
        Result.Minor := StrToInt(VerPart);
        Exit;
    End;

    VMin := Copy(VerPart, 1, Pos('.', VerPart) - 1);
    Result.Minor := StrToInt(VMin);
End;

// Determine the active OS Language

Function GetOSLanguage: String;
Var
    LanguageID: LANGID;
    LanguageSize: DWORD;
    Language: Array Of Char;
Begin
    // Request the System LangID
    LanguageID := GetSystemDefaultLangID;
    // Translate the LangID to pChar
    LanguageSize := StdBufferSize;
    SetLength(Language, LanguageSize);
    VerLanguageName(LanguageID, @Language[0], LanguageSize);
    // Typecaste and Resulting
    Result := Copy(StrPas(@Language[0]), 0, LanguageSize);
End;

// Determine the Username current loged in

Function GetUserName: String;
Var
    BufferSize: DWORD;
    Buffer: Array Of Char;
Begin
    // Set the BufferSize for Calling API
    BufferSize := StdBufferSize;
    // Get the Username to Buffer!! Name length not > Buffer !!!
    SetLength(Buffer, BufferSize);
    Windows.GetUserName(@Buffer[0], BufferSize);
    // Result the given name in Buffer to Result
    Result := Copy(StrPas(@Buffer[0]), 0, BufferSize);
End;

// Determine the Name of Computer

Function GetComputerName: String;
Var
    BufferSize: DWORD;
    Buffer: Array Of Char;
Begin
    // Set the BufferSize for Calling API
    // Get the Computername to Buffer! Name length not > Buffer!!!
    BufferSize := StdBufferSize;
    SetLength(Buffer, BufferSize);
    Windows.GetComputerName(@Buffer[0], BufferSize);
    // Result the given buffer!
    Result := Copy(StrPas(@Buffer[0]), 0, BufferSize);
End;

// Create an Unique Filename in the Current Dir!

Function CreateUniqueFileName(vFileName: String): String;
Var
    Count: Integer;
    Name: String;
Begin
    //DONE -oBenBE@Neo -cInc, Procs : Optimieren von CreateUniqueFilename durch Zwischenspeicherung von Pfadteilen
    // Check if file exists
    Name := vFileName;
    // reset the count to zero
    Count := -1;
    // search some Filename with ending number
    While FileExists(Name) Do
    Begin
        Inc(Count);
        Name := ChangeFileExt(vFileName, '') + '_' + IntToStr(Count) +
            ExtractFileExt(vFileName);
    End;
    // OK! We have found an unique filename
    Result := Name;
End;

// Determine the Drivetype of a given Drive

Function DriveType(vDrive: Char): TDriveType;
Type
    STORAGE_MEDIA_TYPE = DWORD;
    STORAGE_BUS_TYPE = DWORD;

    TDMIDiskInfo = Record
        Cylinders: LARGE_INTEGER;
        MediaType: STORAGE_MEDIA_TYPE;
        TracksPerCylinder: DWORD;
        SectorsPerTrack: DWORD;
        BytesPerSector: DWORD;
        NumberMediaSides: DWORD;
        MediaCharacteristics: DWORD;                                            // Bitmask of MEDIA_XXX values.
    End;

    TDMIRemovableDiskInfo = Record
        Cylinders: LARGE_INTEGER;
        MediaType: STORAGE_MEDIA_TYPE;
        TracksPerCylinder: DWORD;
        SectorsPerTrack: DWORD;
        BytesPerSector: DWORD;
        NumberMediaSides: DWORD;
        MediaCharacteristics: DWORD;                                            // Bitmask of MEDIA_XXX values.
    End;

    TDMITapeInfo = Record
        MediaType: STORAGE_MEDIA_TYPE;
        MediaCharacteristics: DWORD;                                            // Bitmask of MEDIA_XXX values.
        CurrentBlockSize: DWORD;
        BusType: STORAGE_BUS_TYPE;
        //
        // Bus specific information describing the medium supported.
        //
        Case Integer Of                                                         {BusSpecificData}
            0: (                                                                {ScsiInformation}
                MediumType: Byte;
                DensityCode: Byte);
    End;

    DEVICE_MEDIA_INFO = Record
        Case Integer Of
            0: (DiskInfo: TDMIDiskInfo);
            1: (RemovableDiskInfo: TDMIRemovableDiskInfo);
            2: (TapeInfo: TDMITapeInfo);
    End;

    _GET_MEDIA_TYPES = Record
        DeviceType: DWORD;                                                      // FILE_DEVICE_XXX values
        MediaInfoCount: DWORD;
        MediaInfo: Array[0..0] Of DEVICE_MEDIA_INFO;
    End;
    TGetMediaTypes = _GET_MEDIA_TYPES;

    //Information obtained from the WinXP SP1 DDK:
Const
    FILE_DEVICE_MASS_STORAGE = $2D;
    FILE_DEVICE_DVD = $33;
    IOCTL_STORAGE_BASE = FILE_DEVICE_MASS_STORAGE;

    METHOD_BUFFERED = 0;
    FILE_ANY_ACCESS = 0;
Const
    //#define IOCTL_STORAGE_GET_MEDIA_TYPES_EX      CTL_CODE(IOCTL_STORAGE_BASE, 0x0301, METHOD_BUFFERED, FILE_ANY_ACCESS)
    IOCTL_STORAGE_GET_MEDIA_TYPES_EX = (
        (IOCTL_STORAGE_BASE Shl 16) Or (FILE_ANY_ACCESS Shl 14) Or
        ($0301 Shl 2) Or METHOD_BUFFERED);

Var
    GMT: TGetMediaTypes;
    Dev: HFILE;
    BufSize: DWORD;
    Buffer: Pointer;
Begin
    // the system need some : at the string!
    // get the drive type an typecast Integer to dtConst ;-)
    Case GetDriveType(PChar(vDrive + ':\')) Of
        DRIVE_CDROM:
            Begin
                Result := dtCD;
                //DONE -oBenBE -cInc, Procs : Bitte auf Korrektheit prüfen!
                //MSG All: Siehe ms-help://MS.PSDKXPSP2.1033/devio/base/ioctl_storage_get_media_types_ex.htm für nähere Infos
                //MSG All: Oder auch http://forums.devshed.com/archive/t-136265%5CDetecting-DVD-drive

                If GetWinVer In [wvWinXP, wvWin2003, wvWinLH] Then
                Begin
                    Dev := CreateFile(PChar(Format('\\.\%s:', [vDrive])), FILE_ANY_ACCESS, FILE_SHARE_READ Or FILE_SHARE_WRITE, Nil, OPEN_EXISTING, 0, 0);
                    If IsValidHandle(Dev) Then
                    Begin
                        //TODO -oBenBE@All -cInc, Procs : Eigentliche Rekordgröße mit Definitionen vergleichen.
                        //MSG All: Problem ist, dass SizeOf(GMT) = 40, der IOCTRL-Code aber ne Input-Größe von >=72 haben möchte.
                        BufSize := 72;
                        GetMem(Buffer, BufSize);
                        Try
                            DeviceIoControl(Dev, IOCTL_STORAGE_GET_MEDIA_TYPES_EX, Nil, 0, Buffer, BufSize, BufSize, Nil);
                            GMT := _GET_MEDIA_TYPES(Buffer^);
                        Finally
                            FreeMem(Buffer);
                        End;
                        If GMT.DeviceType = FILE_DEVICE_DVD Then
                            Result := dtDVD;
                        CloseHandle(Dev);
                    End;
                End;
            End;
        DRIVE_FIXED: Result := dtHardDisk;
        DRIVE_RAMDISK: Result := dtRamDisk;
        DRIVE_REMOTE: Result := dtNetDisk;
        DRIVE_REMOVABLE:
            Begin
                //TODO -oBenBE@All -cInc, Procs : Unterscheidung von 3,5" und 5.25" Floppies.
                Result := dtDisk;
            End;
        DRIVE_NO_ROOT_DIR: Result := dtNoDrive;
    Else
        Result := dtUnknown;
    End;
End;

// Open a given CD Drive

Procedure OpenCDDrive(vDrive: Char);
Var
    OpenParam: TMCI_Open_Parms;
Begin
    If DriveType(vDrive) In [dtCD, dtDVD] Then
    Begin
        OpenParam.lpstrDeviceType := 'CDAudio';
        OpenParam.lpstrElementName := PChar(String(vDrive + ':'));
        OpenParam.dwCallback := 0;
        OpenParam.lpstrAlias := Nil;
        If mciSendCommand(0, mci_Open, mci_Wait Or mci_open_Type, Longint(@OpenParam)) <> 0 Then
            OmorphiaErrorStr(vl_UseWinAPI, '', 'mciError: Open Device');
        Try
            If mciSendCommand(OpenParam.wDeviceID, mci_Set, mci_Wait Or mci_Set_Door_Open, Longint(@OpenParam)) <> 0 Then
                OmorphiaErrorStr(vl_UseWinAPI, '', 'mciError: Open CD-Drive');
        Finally
            If mciSendCommand(OpenParam.wDeviceID, mci_Close, mci_Wait, Longint(@OpenParam)) <> 0 Then
                OmorphiaErrorStr(vl_UseWinAPI, '', 'mciError: Close Device');
        End;
    End
    Else
    Begin
        OmorphiaErrorStr(vl_Error, '', 'The given drive ' + vDrive + ': is not a CD Drive.');
    End;
End;

// Close a given CD Drive

Procedure CloseCDDrive(vDrive: Char);
Var
    OpenParam: TMCI_Open_Parms;
Begin
    // is an CD-ROM Drive
    If DriveType(vDrive) In [dtCD, dtDVD] Then
    Begin
        OpenParam.lpstrDeviceType := 'CDAudio';
        OpenParam.lpstrElementName := PChar(String(vDrive + ':'));
        OpenParam.dwCallback := 0;
        OpenParam.lpstrAlias := Nil;
        If (mciSendCommand(0, mci_Open, (mci_Wait Or mci_open_Type), Longint(@OpenParam)) <> 0) Then
            OmorphiaErrorStr(vl_UseWinAPI, '', 'mciError: Open Device');
        Try
            If (mciSendCommand(OpenParam.wDeviceID, mci_Set, (mci_Wait Or mci_Set_Door_Closed), Longint(@OpenParam)) <> 0) Then
                OmorphiaErrorStr(vl_UseWinAPI, '', 'mciError: Open CD-Drive');
        Finally
            If (mciSendCommand(OpenParam.wDeviceID, mci_Close, (mci_Wait), Longint(@OpenParam)) <> 0) Then
                OmorphiaErrorStr(vl_UseWinAPI, '', 'mciError: Close Device');
        End;
    End
    Else
    Begin
        OmorphiaErrorStr(vl_Error, '', 'The given drive ' + vDrive + ': is not a CD Drive.');
    End;
End;

Function DriveCaption(vDrive: Char): String;
Var
    BufferSize: DWORD;
    Buffer: Array Of Char;
    Tmp: DWORD;
Begin
    If DriveType(vDrive) <> dtUnknown Then
    Begin
        BufferSize := StdBufferSize;
        SetLength(Buffer, BufferSize);
        GetVolumeInformation(PChar(vDrive + ':\'), @Buffer[0], BufferSize, Nil, Tmp,
            Tmp, Nil, 0);
        Result := Copy(StrPas(@Buffer[0]), 0, BufferSize);
    End
    Else
        Result := '';
End;

Function RebootWindows(vSystem, vMessage: String; vForce, vReboot: Boolean;
    vDuration: Integer): Boolean;
Const
    SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
    SE_REMOTE_SHUTDOWN_NAME = 'SeRemoteShutdownPrivilege';
Var
    hToken: THandle;
    TP: TTokenPrivileges;
    Tmp: DWORD;
    iFlag: Cardinal;
Begin
    Result := False;
    DbgResetOSError;
    If IsWinNT Then
    Begin
        // Get the current process token handle so we can get shutdown privilege.
        If Not OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES Or TOKEN_QUERY, hToken) Then
        Begin
            OmorphiaDebugStr(vl_UseWinAPI, '', 'Open Process Token: Failed');
            DbgLastOSError;
            Exit;
        End;
        Try
            // Get the LUID for shutdown privilege.
            // Get shutdown privilege for this process.
            If Not LookupPrivilegeValue(Nil, SE_SHUTDOWN_NAME, TP.Privileges[0].Luid) Then
            Begin
                OmorphiaDebugStr(vl_UseWinAPI, '', 'Lookup Token Priviledge (Get Local Shutdown Priviledge): Failed');
                DbgLastOSError;
                Exit;
            End;

            TP.PrivilegeCount := 1;                                             // one privilege to set
            TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;

            If Not AdjustTokenPrivileges(hToken, False, TP, 0, Nil, Tmp) Then
            Begin
                OmorphiaDebugStr(vl_UseWinAPI, '', 'Adjust Token Priviledge (Get Local Shutdown Priviledge): Failed');
                DbgLastOSError;
                Exit;
            End;
            Try
                // Get the LUID for remote shutdown privilege.
                // Get remote shutdown privilege for this process.
                If Not LookupPrivilegeValue(PChar(vSystem), SE_REMOTE_SHUTDOWN_NAME, TP.Privileges[0].Luid) Then
                Begin
                    OmorphiaDebugStr(vl_UseWinAPI, '', 'Lookup Token Priviledge (Get Remote Shutdown Priviledge): Failed');
                    DbgLastOSError;
                    Exit;
                End;

                TP.PrivilegeCount := 1;                                         // one privilege to set
                TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;

                If Not AdjustTokenPrivileges(hToken, False, TP, 0, Nil, Tmp) Then
                Begin
                    OmorphiaDebugStr(vl_UseWinAPI, '', 'Adjust Token Priviledge (Get Remote Shutdown Priviledge): Failed');
                    DbgLastOSError;
                    Exit;
                End;
                Try
                    // Display the shutdown dialog box and start the countdown.
                    Result := InitiateSystemShutdown(PChar(vSystem), PChar(vMessage), vDuration, vForce, vReboot);
                    If Not Result Then
                        OmorphiaDebugStr(vl_UseWinAPI, '', 'Initiate System Shutdown: Failed');
                    DbgLastOSError;
                Finally
                    // Get the LUID for remote shutdown privilege.
                    // Get remote shutdown privilege for this process.
                    If Not LookupPrivilegeValue(PChar(vSystem), SE_REMOTE_SHUTDOWN_NAME,
                        TP.Privileges[0].Luid) Then
                        OmorphiaDebugStr(vl_UseWinAPI, '', 'Lookup Token Priviledge (Release Remote Shutdown Priviledge): Failed');

                    TP.PrivilegeCount := 1;                                     // one privilege to set
                    TP.Privileges[0].Attributes := 0;

                    If Not AdjustTokenPrivileges(hToken, False, TP, 0, Nil, Tmp) Then
                        OmorphiaDebugStr(vl_UseWinAPI, '', 'Adjust Token Priviledge (Release Remote Shutdown Priviledge): Failed');
                    DbgLastOSError;
                End;
            Finally
                // Get the LUID for shutdown privilege.
                // Get shutdown privilege for this process.
                If Not LookupPrivilegeValue(Nil, SE_SHUTDOWN_NAME, TP.Privileges[0].Luid) Then
                    OmorphiaDebugStr(vl_UseWinAPI, '', 'Lookup Token Priviledge (Release Local Shutdown Priviledge): Failed');
                DbgLastOSError;

                TP.PrivilegeCount := 1;                                         // one privilege to set
                TP.Privileges[0].Attributes := 0;

                If Not AdjustTokenPrivileges(hToken, False, TP, 0, Nil, Tmp) Then
                    OmorphiaDebugStr(vl_UseWinAPI, '', 'Adjust Token Priviledge (Release Local Shutdown Priviledge): Failed');
                DbgLastOSError;
            End;
        Finally
            CloseHandle(hToken);
        End;
    End
    Else
    Begin
        If vSystem <> '' Then
            OmorphiaDebugStr(vl_FatalError, '', 'Win9x doesn''t support remote shutdown.');
        If vReboot Then
            iFlag := EWX_REBOOT
        Else
            iFlag := EWX_SHUTDOWN;
        If vForce Then
            iFlag := iFlag Or EWX_FORCE;
        Result := ExitWindowsEx(iFlag, 0);
        If Not Result Then
            OmorphiaDebugStr(vl_UseWinAPI, 'OIncProcs.RebootWindows',
                'Error restarting Windows 95/98.');
        DbgLastOSError;
    End;
End;

Function WindowsMode: TWinMode;
Begin
    Case GetSystemMetrics(sm_CleanBoot) Of
        0: Result := wmNormal;
        1: Result := wmSafe;
        2: Result := wmSafeNET;
    Else
        Result := wmUnknown;
    End;
End;

Function Space(vSpaceLength: Integer; vText: String; vSpaceChar: Char): String;
Begin
    If (Length(vText) > vSpaceLength) Then
        Result := Copy(vText, 1, vSpaceLength - 3) + '...'
    Else
        Result := vText + StringOfChar(vSpaceChar, vSpaceLength - Length(vText));
End;

Function StrToInt(vText: String): Integer;
Var
    Code: Integer;
Begin
    Val(vText, Result, Code);
End;

Function IntToStr(AValue: Integer): String;
Begin
    Str(AValue, Result);
End;

Function Hex(AValue: Integer): String;
Begin
    Result := '0x' + IntToHex(AValue, 8);
End;

Function HexExt(AValue: Integer): String;
Begin
    Result := IntToStr(AValue) + ' [' + Hex(AValue) + ']';
End;

Function BoolToStr(AValue: Boolean): String;
Begin
    If (AValue) Then
        Result := 'TRUE'
    Else
        Result := 'FALSE';
End;

Function NewLine: String;
Begin
    Result := #13#10;
End;

Function PtrToStr(AValue: Pointer): String;
Begin
    If AValue = Nil Then
        Result := '^NIL'
    Else
        Result := Format('^0x%p', [AValue]);
End;

Function RealToStr(AValue: Real): String;
Begin
    Result := Format('%f', [AValue]);
End;

Function WindowsModeStr: String;
Begin
    Result := WinModeNames[WindowsMode];
End;

Function GetEnvVarValue(AName: String): String;
Var
    BufSize: Integer;
    Buf: Array Of Char;
Begin
    DbgResetOSError;
    Result := '';

    BufSize := Windows.GetEnvironmentVariable(PChar(AName), Nil, 0);
    If BufSize <= 0 Then
        Exit;
    DbgLastOSError(False);

    SetLength(Buf, BufSize);
    BufSize := Windows.GetEnvironmentVariable(PChar(AName), @Buf[0], BufSize);
    If BufSize + 1 <> Length(Buf) Then
        Exit;
    DbgLastOSError(False);

    Result := StrPas(@Buf[0]);
End;

Function DriveTypeStr(vDrive: Char): String;
Begin
    Result := DriveTypeNames[DriveType(vDrive)];
End;

{ StrTo... }

Function StrToByte(vText: String): Byte;
Var
    TempI: Integer;
Begin
    Val(vText, Result, TempI);
End;

Function StrToWord(vText: String): Word;
Var
    TempI: Integer;
Begin
    Val(vText, Result, TempI);
End;

Function StrToReal(vText: String): Real;
Begin
    Result := StrToFloat(vText);
End;

Function StrToCurrency(vText: String): Currency;
Begin
    Result := StrToFloat(vText);
End;

Function StrToBool(vText: String): Boolean;
Begin
    // MSG BenBE@Neo: Sollte IMHO noch ein wenig genauer prüfen.
    // DONE -oBenBE@Neo -cBug, Inc, Procs : Sinnhaftigkeit des Parameters wird nicht geprüft
    // DONE -oBenBE@Neo -cInc, Procs : Interpretation von Zahlen als Booleans
    Result := (StrToIntDef(vText, 0) <> 0) Or
        (UpperCase(vText) = 'TRUE') Or
        (UpperCase(vText) = 'JA') Or
        (UpperCase(vText) = 'WAHR') Or
        (UpperCase(vText) = 'YES');
End;

Function IntToBool(AValue: Integer): Boolean;
Begin
    Result := AValue <> 0;
End;

{ RealTo... }

Function RealToByte(AValue: Real): Byte;
Begin
    Result := Trunc(AValue);
End;

Function RealToWord(AValue: Real): Word;
Begin
    Result := Trunc(AValue);
End;

Function RealToInt(AValue: Real): Integer;
Begin
    Result := Trunc(AValue);
End;

Function RealToCurrency(AValue: Real): Currency;
Begin
    Result := AValue;
End;

Function RealToBool(AValue: Real): Boolean;
Begin
    Result := AValue <> 0;
End;

{ BoolTo...}

Function BoolToByte(AValue: Boolean): Byte;
Begin
    Result := Byte(AValue);
End;

Function BoolToWord(AValue: Boolean): Word;
Begin
    Result := Word(AValue);
End;

Function BoolToInt(AValue: Boolean): Integer;
Begin
    Result := Integer(AValue);
End;

Function BoolToReal(AValue: Boolean): Real;
Begin
    Result := BoolToByte(AValue);
End;

Function BoolToCurrency(AValue: Boolean): Currency;
Begin
    Result := BoolToByte(AValue);
End;

Function ByteToBinaryStr(AValue: Byte): String;
Var
    B: PByte;
Begin
    AValue := AValue And $FF;
    Result := StringOfChar('0', 8);
    B := @Byte(Result[8]);
    While AValue <> 0 Do
    Begin
        Inc(B^, AValue And 1);
        AValue := AValue Shr 1;
        Dec(B);
    End;
End;

Function WordToBinaryStr(AValue: Word): String;
Var
    B: PByte;
Begin
    AValue := AValue And $FFFF;
    Result := StringOfChar('0', 16);
    B := @Byte(Result[16]);
    While AValue <> 0 Do
    Begin
        Inc(B^, AValue And 1);
        AValue := AValue Shr 1;
        Dec(B);
    End;
End;

Function DWordToBinaryStr(AValue: DWORD): String;
Var
    B: PByte;
Begin
    Result := StringOfChar('0', 32);
    B := @Byte(Result[32]);
    While AValue <> 0 Do
    Begin
        Inc(B^, AValue And 1);
        AValue := AValue Shr 1;
        Dec(B);
    End;
End;

Function IsBitSet(Const BitSet: DWORD; Const Bit: Byte): Boolean;
//    Result := BitSet And (1 Shl Bit) <> 0;
Asm
    MOVZX   EDX, DL
    BT      EAX, EDX
    SETC    AL
End;

//DelphiSource.de
//http://www.delphi-source.de/tipps/?id=170

Function IsAdministrator: Boolean;
Const
    SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
    SECURITY_BUILTIN_DOMAIN_RID = $00000020;
    DOMAIN_ALIAS_RID_ADMINS = $00000220;
Var
    hAccessToken: THandle;
    ptgGroups: PTokenGroups;
    dwInfoBufferSize: DWORD;
    psidAdministrators: PSID;
    X: Integer;
    bSuccess: BOOL;
Begin
    // DONE -oNeo@BenBE -cInc, Procs : IsAdministrator: Add some comments
    Result := False;
    bSuccess := False;
    ptgGroups := Nil;
    psidAdministrators := Nil;
    Try
        bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True, hAccessToken); //Get the access token of the current thread
        If Not bSuccess Then                                                    //Check if successful
            If GetLastError = ERROR_NO_TOKEN Then
                bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hAccessToken); //If failed try the current process
        If bSuccess Then                                                        //If we have a token proceed
        Begin
            GetMem(ptgGroups, 1024);
            bSuccess := GetTokenInformation(hAccessToken, TokenGroups, ptgGroups, 1024, dwInfoBufferSize); //Query the token access priviledges and name information
            If bSuccess Then
            Begin
                AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, psidAdministrators); //Check if it's an authority (administrator)
                For X := 0 To ptgGroups.GroupCount - 1 Do
                    If EqualSid(psidAdministrators, ptgGroups.Groups[X].Sid) Then //Compare the SIDs (User System Identifiers) if it's contains Admin Access Flags
                    Begin
                        Result := True;
                        Break;
                    End;
            End;
        End;
    Finally
        If bSuccess Then                                                        //Free used handles and memory
            CloseHandle(hAccessToken);
        If Assigned(ptgGroups) Then
            FreeMem(ptgGroups);
        If Assigned(psidAdministrators) Then
            FreeSid(psidAdministrators);
    End;
End;

Function HasSoundcard: Boolean;
Begin
    Result := WaveOutGetNumDevs > 0;
End;

Function SendEMail(Handle: THandle; Mail: TStrings): Cardinal;
Type
    TAttachAccessArray = Array[0..0] Of TMapiFileDesc;
    PAttachAccessArray = ^TAttachAccessArray;
Var
    MapiMessage: TMapiMessage;
    Receip: TMapiRecipDesc;
    Attachments: PAttachAccessArray;
    AttachCount: Integer;
    i1: Integer;
    FileName: String;
    MAPI_Session: Cardinal;
    WndList: Pointer;
Begin
    // ToDo -oNeo@Matze -cNet, SendEmail : Add some comments
    Result := MapiLogon(Handle, Nil, Nil, MAPI_LOGON_UI Or MAPI_NEW_SESSION, 0, @MAPI_Session);

    If Result <> SUCCESS_SUCCESS Then
    Begin
        // MSG Neo@matze: remove MessageBox and replace by OmorphiaDebugStr
        // MessageBox(Handle, 'Error while trying to send email', 'Error', MB_ICONERROR Or MB_OK);
        OmorphiaDebugStr(vl_Error, '', 'Error while trying to send email (Login failed)');
        Exit;
    End;

    Try
        ZeroMemory(@MapiMessage, SizeOf(MapiMessage));
        Attachments := Nil;
        ZeroMemory(@Receip, SizeOf(Receip));

        If Mail.Values['to'] <> '' Then
        Begin
            Receip.ulReserved := 0;
            Receip.ulRecipClass := MAPI_TO;
            Receip.lpszName := StrNew(PChar(Mail.Values['to']));
            Receip.lpszAddress := StrNew(PChar('SMTP:' + Mail.Values['to']));
            Receip.ulEIDSize := 0;
            MapiMessage.nRecipCount := 1;
            MapiMessage.lpRecips := @Receip;
        End;

        AttachCount := 0;

        //  TODO -oMatze -cInc, Procs : AttachmentCount als Angabe direkt aus Mail-Daten lesen
        For i1 := 0 To MaxInt Do
        Begin
            If Mail.Values['attachment' + IntToStr(i1)] = '' Then
                Break;
            Inc(AttachCount);
        End;

        If AttachCount > 0 Then
        Begin
            GetMem(Attachments, SizeOf(TMapiFileDesc) * AttachCount);

            For i1 := 0 To AttachCount - 1 Do
            Begin
                FileName := Mail.Values['attachment' + IntToStr(i1)];
                Attachments[i1].ulReserved := 0;
                Attachments[i1].flFlags := 0;
                Attachments[i1].nPosition := ULONG($FFFFFFFF);
                Attachments[i1].lpszPathName := StrNew(PChar(FileName));
                Attachments[i1].lpszFileName := StrNew(PChar(ExtractFileName(FileName)));
                Attachments[i1].lpFileType := Nil;
            End;
            MapiMessage.nFileCount := AttachCount;
            MapiMessage.lpFiles := @Attachments^;
        End;

        //  MSG BenBE@matze : PChar(Mail.Values['subject']) sollte als Zuweisung auch reichen
        If Mail.Values['subject'] <> '' Then
            MapiMessage.lpszSubject := StrNew(PChar(Mail.Values['subject']));

        //  TODO -oBenBE@Matze -cInc, Procs : Nachrichtentext als normale Nachricht hinter allen anderen Einträgen positionieren.
        //  MSG BenBE@matze : PChar(Mail.Values['body']) sollte als Zuweisung auch reichen
        If Mail.Values['body'] <> '' Then
            MapiMessage.lpszNoteText := StrNew(PChar(Mail.Values['body']));

        WndList := DisableTaskWindows(0);
        Try
            Result := MapiSendMail(MAPI_Session, Handle, MapiMessage, MAPI_DIALOG, 0);
        Finally
            EnableTaskWindows(WndList);
        End;

        For i1 := 0 To AttachCount - 1 Do
        Begin
            StrDispose(Attachments[i1].lpszPathName);
            StrDispose(Attachments[i1].lpszFileName);
        End;

        //  MSG BenBE@matze : Ressourcen-Schutzblöcke nicht vergessen!
        If Assigned(MapiMessage.lpszSubject) Then
            StrDispose(MapiMessage.lpszSubject);
        If Assigned(MapiMessage.lpszNoteText) Then
            StrDispose(MapiMessage.lpszNoteText);
        If Assigned(Receip.lpszAddress) Then
            StrDispose(Receip.lpszAddress);
        If Assigned(Receip.lpszName) Then
            StrDispose(Receip.lpszName);

    Finally
        MapiLogOff(MAPI_Session, Handle, 0, 0);
    End;
End;

Function SwapBytes(A: DWORD): DWORD;
Asm
    BSWAP   EAX
End;

Function SwapBits(A: DWORD; N: Byte): DWORD;
Asm
    LEA     ECX, DWORD PTR [EDX-1]
    AND     ECX, $0000001F
    INC     ECX

    XOR     EDX, EDX

@@SwapLoop:
    RCR     EAX, 1
    RCL     EDX, 1
    LOOP    @@SwapLoop

    MOV     EAX, EDX
End;

Function EnumValueToStr(AValue: Integer; ATypeInfo: PTypeInfo): String;
Var
    TD: PTypeData;
Begin
    Result := Format('undefined (%d)', [AValue]);
    If ATypeInfo^.Kind <> tkEnumeration Then
        Exit;
    TD := GetTypeData(ATypeInfo);
    If AValue < TD.MinValue Then
        Exit;
    If AValue > TD.MaxValue Then
        Exit;
    Result := GetEnumName(ATypeInfo, AValue);
End;

Function SetValueToStr(AValue: Integer; ATypeInfo: PTypeInfo; Brackets: Boolean): String;
Var
    S: TIntegerSet;
    I: Integer;
Begin
    Result := '';
    Integer(S) := AValue;
    Try
        If ATypeInfo^.Kind <> tkSet Then
            Exit;
        ATypeInfo := GetTypeData(ATypeInfo)^.CompType^;
        If ATypeInfo^.Kind <> tkEnumeration Then
            Exit;

        For I := 0 To GetTypeData(ATypeInfo)^.MaxValue Do
            If I In S Then
            Begin
                If Result <> '' Then
                    Result := Result + ', ';
                Result := Result + EnumValueToStr(I, ATypeInfo);
            End;
    Finally
        If Brackets Then
            Result := '[' + Result + ']';
    End;
End;

Procedure FreeAndNilSecure(Var Obj);
Var
    Temp: TObject;
Begin
    Temp := TObject(Obj);
    Pointer(Obj) := Nil;
    If Assigned(Temp) Then
        Temp.Free
    Else
        OmorphiaDebugStr(vl_Warning, '', Format('Object %p to clear already unassigned.', [Pointer(Obj)]));
End;

//DF by alzaimar:
//http://www.delphi-forum.de/viewtopic.php?p=308367#308367
//Minor changes since original

Function Split(Var S: String; Const Del: String): String;
Var
    P: Integer;
Begin
    P := Pos(Del, S);
    If P = 0 Then
        P := Length(S) + 1;

    Result := Copy(S, 1, P - 1);
    Delete(S, 1, P + Length(Del));
End;

Function GetDataSizeStr(Size: Int64): String;
Const
    UnitNames: Array[0..6] Of String =
    ('Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB');
Var
    X: Integer;
Begin
    Result := '';

    If Size = 0 Then
        Result := '0 Bytes';
    If Size = 1 Then
        Result := '1 Byte';

    If Result <> '' Then
        Exit;

    X := High(UnitNames);

    While Size Shr (10 * X) = 0 Do
        Dec(X);

    If X = 0 Then
    Begin
        Result := Format('%d Bytes', [Size]);
        Exit;
    End;

    Size := Size Shr (10 * (X - 1));

    If Size < 16384 Then
        Result := Format('%.1f %s (%d %s)', [Size / 1024, UnitNames[X], Size, UnitNames[X - 1]])
    Else
        Result := Format('%.1f %s', [Size / 1024, UnitNames[X]]);
End;

End.

