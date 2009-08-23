Unit OIncConsts;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Base Constants
//
// This unit defines global constants.
//
// *****************************************************************************
// To Do:
//
// *****************************************************************************
// News:
//
// ****************************************************************************
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
    OIncTypes;

// Default Buffer Size for API call's [0..x-1]
Const
    StdBufferSize = 256;

Const
    Letters = ['A'..'Z', 'a'..'z'];
    Digits = ['0'..'9'];
    AlphaNumeric = Letters + Digits;
    HexDigitsL = ['0'..'9', 'a'..'f'];
    HexDigitsU = ['0'..'9', 'A'..'F'];
    HexDigits = HexDigitsL + HexDigitsU;
    INVALID_FILE_ATTRIBUTES = DWORD(-1);

Var
    // MSG BenBE: Habsch absichtlich als Var deklariert, damit man lokalisierte Texte zuweisen kann.
    WinVerNames: Array[TWinVersion] Of String = (
        'Unbekannt',
        'Win32s',
        'Win95',
        'Win98',
        'WinME',
        'WinNT351',
        'WinNT4',
        'Win2000',
        'WinXP',
        'Win2003',
        'WinLH',
        'WinVista'
        );

    WinModeNames: Array[TWinMode] Of String = (
        'Unknown',                                                              // Neo: Unbekannter Modus
        'Normal',                                                               // Neo: Normaler Modus
        'Save Mode',                                                            // Neo: Abgesicherter Modus
        'Save Mode with Network'                                                // Neo: Abgesicherter Modus mit Netzwerk
        );

    DriveTypeNames: Array[TDriveType] Of String = (
        'Unbekannt',
        'No Drive',
        'Removable Disk',
        'CD ROM Drive',
        'DVD ROM Drive',
        'Network Drive',
        'RAM Disk',
        'Harddisk'
        );

Implementation

End.
