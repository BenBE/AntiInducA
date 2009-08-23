Unit OIncTypes;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Base Code
//
// This unit defines types for the helper functions.
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
    Windows;

Type
    TVersion = Packed Record
        Major: Integer;
        Minor: Integer;
    End;

Type
    // Neo: Definition
    TWinVersion = (
        wvUnknown,                                                              // Neo: Unbekannte Windows Version
        wvWin32s,                                                               // Neo: Windows 3.1 (32 Bit Extensions)
        wvWin95,                                                                // Neo: Windows 95
        wvWin98,                                                                // Neo: Windows 98
        wvWinME,                                                                // Neo: Windows ME
        wvWinNT351,                                                             // Neo: Windows NT 3.51
        wvWinNT4,                                                               // Neo: Windows NT 4.00
        wvWin2000,                                                              // Neo: Windows 2000
        wvWinXP,                                                                // Neo: Windows XP
        wvWin2003,                                                              // Neo: Windows NET ? (= Windows Server 2003, Anm. by BenBE)
        wvWinLH,                                                                // BenBE: Windows LH (Wird derzeitig noch nicht erkannt!)
        wvWinVista                                                              // BenBE: Nur bei Abfrage des OS über Beta-Erkennung diagnostiziert (Ich such nicht nach Viren!)
        );

    TWinVersionEx = Record
        OSType: TWinVersion;                                                    // BenBE: Basic type of the OS.
        OSName: String;                                                         // BenBE: String 'Windows'
        OSVerBroad: String;                                                     // BenBE: '95', '98', 'XP', ...
        OSVerPrecise: String;                                                   // BenBE: '95 SR2', 'Longhorn (RC2)', ...
        OSSuite: String;                                                        // BenBE: 'Hohn', 'Professional', ...
        OSPatchLevel: String;                                                   // BenBE: 'Service Pack 6a', ...
        OSBuild: String;                                                        // BenBE: 'Build 5111', 'Build 2195',  ...
    End;

Type
    TWinMode = (
        wmUnknown,                                                              // Neo: Unbekannter Modus
        wmNormal,                                                               // Neo: Normaler Modus
        wmSafe,                                                                 // Neo: Abgesicherter Modus
        wmSafeNET                                                               // Neo: Abgesicherter Modus mit Netzwerk
        );
    TDriveType = (
        dtUnknown,                                                              // Neo: Unbekannter Laufwerk Type
        dtNoDrive,                                                              // Neo: Kein Laufwerk
        // MSG BenBE: Das ist aber schön, dass logische Laufwerke ins Nichts zeigen können :D
        dtDisk,                                                                 // Neo: Disketten Laufwerk
        dtCD,                                                                   // Neo: CD-ROM Laufwerk
        dtDVD,                                                                  // BenBE: DVD-ROM-Laufwerk
        dtNetDisk,                                                              // Neo: Netzwerk Laufwerk
        dtRamDisk,                                                              // Neo: RAM Laufwerk
        dtHardDisk                                                              // Neo: Festplatte
        );
    TDebugType = (
        dtUnbekannt,                                                            // BenBE: Unbekannter Debug-Eintrag
        dtFatal,                                                                // Neo: Fataler Fehler (Exit)
        dtWarning,                                                              // Neo: Warunungen
        dtHint,                                                                 // Neo: Hinweis
        dtInfo                                                                  // Neo: Info
        );

Type
    // CPU Info Structur
    TCPUInfo = Record
        VendorIDString: String;
        Manufacturer: String;
        CPU_Name: String;
        Serial: String;
        PType: Byte;
        Family: Byte;
        Model: Byte;
        Stepping: Byte;
        ExtendedFamily: Byte;
        ExtendedModel: Byte;
        Features: DWORD;
        Features2: DWORD;
        ExtendedFeatures: DWORD;
        Signature: DWORD;
        ExtendedSignature: DWORD;

        BrandID: Word;
        BrandString: String;

        Cache_L1: DWORD;                                                        //Entire Size of Data + Instr L1 Cache (in Bytes)
        Cache_L1Data: DWORD;                                                    //Size of Data L1 Cache (in Bytes)
        Cache_L1Instr: DWORD;                                                   //Size of Instr L1 Cache (in Bytes)
        Cache_L2: DWORD;                                                        //Size of L2 Cache (in Bytes)
        Cache_L3: DWORD;                                                        //Size of L3 Cache (in Bytes)
        Cache_TLB: DWORD;                                                       //Entire Size of Data + Instr TLB (in Bytes)
        Cache_TLBData: DWORD;                                                   //Size of Data TLB Cache (in Bytes)
        Cache_TLBInstr: DWORD;                                                  //Size of Instruction TLB Cache (in Bytes)
        Cache_Trace: DWORD;                                                     //Size of Trace Cache (in Bytes)

        Ext_3DNow: Boolean;
        Ext_3DNowExt: Boolean;
        Ext_AA64LM: Boolean;
        Ext_ACPI: Boolean;
        Ext_APIC: Boolean;
        Ext_APIC_ID: Byte;
        Ext_ATC: Boolean;
        Ext_CID: Boolean;
        Ext_CLFLUSH: Boolean;
        Ext_CLFLUSH_LineSize: Byte;
        Ext_CMOV: Boolean;
        Ext_CPUID: Boolean;
        Ext_CPUID_MaxStd: DWORD;
        Ext_CPUID_MaxExt: DWORD;
        Ext_CPUID_MaxCentaur: DWORD;
        Ext_CX8: Boolean;
        Ext_CX16: Boolean;
        Ext_DAZ: Boolean;                                                       //Denormals-Are-Zero-Mode supported
        Ext_DE: Boolean;
        Ext_DS: Boolean;
        Ext_DSCPL: Boolean;
        Ext_EMM: Boolean;
        Ext_EST: Boolean;
        Ext_ETPRD: Boolean;
        Ext_FCMOV: Boolean;
        Ext_FPU: Boolean;
        Ext_FXSR: Boolean;
        Ext_FFXSR: Boolean;
        Ext_HPL: Boolean;
        Ext_HTT: Boolean;
        Ext_HTT_Count: Byte;
        Ext_IA64: Boolean;
        Ext_MCA: Boolean;
        Ext_MCE: Boolean;
        Ext_MMX: Boolean;
        Ext_MMXPlus: Boolean;
        Ext_MON: Boolean;
        Ext_MP: Boolean;
        Ext_MSR: Boolean;
        Ext_MTRR_P6: Boolean;
        Ext_MTRR_K6: Boolean;
        Ext_NB: Boolean;
        Ext_NX: Boolean;
        Ext_PAE: Boolean;
        Ext_PAT: Boolean;
        Ext_PGE: Boolean;
        Ext_PSE: Boolean;
        Ext_PSE36: Boolean;
        Ext_PSN: Boolean;
        Ext_REE: Boolean;
        Ext_SBF: Boolean;
        Ext_SEP: Boolean;
        Ext_SelfSnoop: Boolean;
        Ext_SSE: Boolean;
        Ext_SSE2: Boolean;
        Ext_SSE3: Boolean;
        Ext_TM: Boolean;
        Ext_TM2: Boolean;
        Ext_TSC: Boolean;
        Ext_VME: Boolean;
    End;

Type
    TCPUIDResult = Packed Record
        Reg_EAX: DWORD;
        Reg_EBX: DWORD;
        Reg_ECX: DWORD;
        Reg_EDX: DWORD;
        Valid: Boolean;
    End;
    tVoid = Procedure;

Const
    InvalidCPUIDNum: TCPUIDResult = (Reg_EAX: 0; Reg_EBX: 0; Reg_ECX: 0; Reg_EDX: 0; Valid: False);

Type
    TODbgMapLocation = Record
        Address: DWORD;                                                         //Requested Source Address
        Module: HMODULE;                                                        //Module Handle of associated Module containing the desired address
        ModuleName: String;                                                     //Module filename of the given module
        ModuleRVA: DWORD;                                                       //RVA inside the module
        UnitName: String;                                                       //Name of the Unit containing the address
        UnitSource: String;                                                     //Source Filename containinge the given address
        UnitSourceLine: Integer;                                                //Line number of error location
        ProcName: String;                                                       //Name of the procedure containing the requested address
    End;

    {$IFDEF FPC}
    //
    // File header format.
    //

Type
    PIMAGE_FILE_HEADER = ^IMAGE_FILE_HEADER;
    _IMAGE_FILE_HEADER = Record
        Machine: Word;
        NumberOfSections: Word;
        TimeDateStamp: DWORD;
        PointerToSymbolTable: DWORD;
        NumberOfSymbols: DWORD;
        SizeOfOptionalHeader: Word;
        Characteristics: Word;
    End;
    IMAGE_FILE_HEADER = _IMAGE_FILE_HEADER;
    TImageFileHeader = IMAGE_FILE_HEADER;
    PImageFileHeader = PIMAGE_FILE_HEADER;

    //
    // Directory format.
    //

Type
    PIMAGE_DATA_DIRECTORY = ^IMAGE_DATA_DIRECTORY;
    _IMAGE_DATA_DIRECTORY = Record
        VirtualAddress: DWORD;
        Size: DWORD;
    End;
    IMAGE_DATA_DIRECTORY = _IMAGE_DATA_DIRECTORY;
    TImageDataDirectory = IMAGE_DATA_DIRECTORY;
    PImageDataDirectory = PIMAGE_DATA_DIRECTORY;

Const
    IMAGE_NUMBEROF_DIRECTORY_ENTRIES = 16;

    //
    // Optional header format.
    //

Type
    PIMAGE_OPTIONAL_HEADER32 = ^IMAGE_OPTIONAL_HEADER32;
    _IMAGE_OPTIONAL_HEADER = Record
        //
        // Standard fields.
        //
        Magic: Word;
        MajorLinkerVersion: Byte;
        MinorLinkerVersion: Byte;
        SizeOfCode: DWORD;
        SizeOfInitializedData: DWORD;
        SizeOfUninitializedData: DWORD;
        AddressOfEntryPoint: DWORD;
        BaseOfCode: DWORD;
        BaseOfData: DWORD;
        //
        // NT additional fields.
        //
        ImageBase: DWORD;
        SectionAlignment: DWORD;
        FileAlignment: DWORD;
        MajorOperatingSystemVersion: Word;
        MinorOperatingSystemVersion: Word;
        MajorImageVersion: Word;
        MinorImageVersion: Word;
        MajorSubsystemVersion: Word;
        MinorSubsystemVersion: Word;
        Win32VersionValue: DWORD;
        SizeOfImage: DWORD;
        SizeOfHeaders: DWORD;
        CheckSum: DWORD;
        Subsystem: Word;
        DllCharacteristics: Word;
        SizeOfStackReserve: DWORD;
        SizeOfStackCommit: DWORD;
        SizeOfHeapReserve: DWORD;
        SizeOfHeapCommit: DWORD;
        LoaderFlags: DWORD;
        NumberOfRvaAndSizes: DWORD;
        DataDirectory: Array[0..IMAGE_NUMBEROF_DIRECTORY_ENTRIES - 1] Of IMAGE_DATA_DIRECTORY;
    End;
    IMAGE_OPTIONAL_HEADER32 = _IMAGE_OPTIONAL_HEADER;
    TImageOptionalHeader32 = IMAGE_OPTIONAL_HEADER32;
    PImageOptionalHeader32 = PIMAGE_OPTIONAL_HEADER32;

Type
    PIMAGE_NT_HEADERS32 = ^IMAGE_NT_HEADERS32;
    _IMAGE_NT_HEADERS = Record
        Signature: DWORD;
        FileHeader: IMAGE_FILE_HEADER;
        OptionalHeader: IMAGE_OPTIONAL_HEADER32;
    End;
    IMAGE_NT_HEADERS32 = _IMAGE_NT_HEADERS;
    TImageNtHeaders32 = IMAGE_NT_HEADERS32;
    PImageNtHeaders32 = PIMAGE_NT_HEADERS32;

    IMAGE_NT_HEADERS = IMAGE_NT_HEADERS32;
    PIMAGE_NT_HEADERS = PIMAGE_NT_HEADERS32;

    TImageNtHeaders = IMAGE_NT_HEADERS;
    PImageNtHeaders = PIMAGE_NT_HEADERS;

Type
    IMAGE_OPTIONAL_HEADER = IMAGE_OPTIONAL_HEADER32;
    PIMAGE_OPTIONAL_HEADER = PIMAGE_OPTIONAL_HEADER32;

    //
    // Section header format.
    //

Const
    IMAGE_SIZEOF_SHORT_NAME = 8;

Type
    TImgSecHdrMisc = Record
        Case Integer Of
            0: (PhysicalAddress: DWORD);
            1: (VirtualSize: DWORD);
    End;

    PIMAGE_SECTION_HEADER = ^IMAGE_SECTION_HEADER;
    _IMAGE_SECTION_HEADER = Record
        Name: Array[0..IMAGE_SIZEOF_SHORT_NAME - 1] Of Byte;
        Misc: TImgSecHdrMisc;
        VirtualAddress: DWORD;
        SizeOfRawData: DWORD;
        PointerToRawData: DWORD;
        PointerToRelocations: DWORD;
        PointerToLinenumbers: DWORD;
        NumberOfRelocations: Word;
        NumberOfLinenumbers: Word;
        Characteristics: DWORD;
    End;
    IMAGE_SECTION_HEADER = _IMAGE_SECTION_HEADER;
    TImageSectionHeader = IMAGE_SECTION_HEADER;
    PImageSectionHeader = PIMAGE_SECTION_HEADER;

    //
    // Section characteristics.
    //
    //      IMAGE_SCN_TYPE_REG                   0x00000000  // Reserved.
    //      IMAGE_SCN_TYPE_DSECT                 0x00000001  // Reserved.
    //      IMAGE_SCN_TYPE_NOLOAD                0x00000002  // Reserved.
    //      IMAGE_SCN_TYPE_GROUP                 0x00000004  // Reserved.
Const
    IMAGE_SCN_TYPE_NO_PAD = $00000008;                                          // Reserved.

    //      IMAGE_SCN_TYPE_COPY                  0x00000010  // Reserved.

    IMAGE_SCN_CNT_CODE = $00000020;                                             // Section contains code.
    IMAGE_SCN_CNT_INITIALIZED_DATA = $00000040;                                 // Section contains initialized data.
    IMAGE_SCN_CNT_UNINITIALIZED_DATA = $00000080;                               // Section contains uninitialized data.

    IMAGE_SCN_LNK_OTHER = $00000100;                                            // Reserved.
    IMAGE_SCN_LNK_INFO = $00000200;                                             // Section contains comments or some other type of information.

    //      IMAGE_SCN_TYPE_OVER                  0x00000400  // Reserved.

    IMAGE_SCN_LNK_REMOVE = $00000800;                                           // Section contents will not become part of image.
    IMAGE_SCN_LNK_COMDAT = $00001000;                                           // Section contents comdat.

    //                                           0x00002000  // Reserved.
    //      IMAGE_SCN_MEM_PROTECTED - Obsolete   0x00004000

    IMAGE_SCN_NO_DEFER_SPEC_EXC = $00004000;                                    // Reset speculative exceptions handling bits in the TLB entries for this section.
    IMAGE_SCN_GPREL = $00008000;                                                // Section content can be accessed relative to GP
    IMAGE_SCN_MEM_FARDATA = $00008000;

    //      IMAGE_SCN_MEM_SYSHEAP  - Obsolete    0x00010000

    IMAGE_SCN_MEM_PURGEABLE = $00020000;
    IMAGE_SCN_MEM_16BIT = $00020000;
    IMAGE_SCN_MEM_LOCKED = $00040000;
    IMAGE_SCN_MEM_PRELOAD = $00080000;

    IMAGE_SCN_ALIGN_1BYTES = $00100000;
    IMAGE_SCN_ALIGN_2BYTES = $00200000;
    IMAGE_SCN_ALIGN_4BYTES = $00300000;
    IMAGE_SCN_ALIGN_8BYTES = $00400000;
    IMAGE_SCN_ALIGN_16BYTES = $00500000;                                        // Default alignment if no others are specified.
    IMAGE_SCN_ALIGN_32BYTES = $00600000;
    IMAGE_SCN_ALIGN_64BYTES = $00700000;
    IMAGE_SCN_ALIGN_128BYTES = $00800000;
    IMAGE_SCN_ALIGN_256BYTES = $00900000;
    IMAGE_SCN_ALIGN_512BYTES = $00A00000;
    IMAGE_SCN_ALIGN_1024BYTES = $00B00000;
    IMAGE_SCN_ALIGN_2048BYTES = $00C00000;
    IMAGE_SCN_ALIGN_4096BYTES = $00D00000;
    IMAGE_SCN_ALIGN_8192BYTES = $00E00000;

    // Unused                                    0x00F00000

    IMAGE_SCN_ALIGN_MASK = $00F00000;

    IMAGE_SCN_LNK_NRELOC_OVFL = $01000000;                                      // Section contains extended relocations.
    IMAGE_SCN_MEM_DISCARDABLE = $02000000;                                      // Section can be discarded.
    IMAGE_SCN_MEM_NOT_CACHED = $04000000;                                       // Section is not cachable.
    IMAGE_SCN_MEM_NOT_PAGED = $08000000;                                        // Section is not pageable.
    IMAGE_SCN_MEM_SHARED = $10000000;                                           // Section is shareable.
    IMAGE_SCN_MEM_EXECUTE = $20000000;                                          // Section is executable.
    IMAGE_SCN_MEM_READ = $40000000;                                             // Section is readable.
    IMAGE_SCN_MEM_WRITE = DWORD($80000000);                                     // Section is writeable.

    //
    // TLS Chaacteristic Flags
    //

    IMAGE_SCN_SCALE_INDEX = $00000001;                                          // Tls index is scaled
    {$ENDIF}

Type
    TAdvPointer = Packed Record
        Case Boolean Of
            True:
            (
                Ptr: Pointer;
                );
            False:
            (
                Addr: DWORD;
                );
    End;

Type
    TRVABlock = Record
        Ptr: TAdvPointer;
        Size: DWORD;
    End;

    TODbgMapfileLineInfo = Record
        LinePtr: TRVABlock;
        LineFile: String;
        Line: Integer;
    End;

    TODbgMapfilePublicsInfo = Record
        PublicPtr: TRVABlock;
        PublicName: String;
    End;

    TODbgMapFileUnitInfo = Record
        UnitPtr: TRVABlock;
        UnitName: String;
    End;

    TODbgMapfileSymInfo = Record
        Symbol: TRVABlock;
        Info: TODbgMapLocation;
    End;

Type
    PODbgMapfileLineInfo = ^TODbgMapfileLineInfo;
    PODbgMapfilePublicsInfo = ^TODbgMapfilePublicsInfo;
    PODbgMapfileUnitInfo = ^TODbgMapFileUnitInfo;

Implementation

End.

