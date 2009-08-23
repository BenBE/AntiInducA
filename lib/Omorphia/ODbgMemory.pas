Unit ODbgMemory;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Debugger Support
//
// This unit provides an alternative memory manager that auto-reports each
// allocation. reallocation and release of memory to the debugger (ODS).
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
//  PLEASE MAKE SURE THIS MEMORY MANAGER IS LISTED IN THE USES CLAUSE AFTER
//  ANY EXTERNAL MEMORY MANAGER AS THIS UNIT DEFINES A MEMORY MANAGER HOOK
//  WHICH RELIES ON INTERSECTING CALLS TO THE ACTIVE MEMORY MANAGER.
//
//  REMEMBER THAT THIS MEMORY MANAGER SIGNIFICANTLY SLOWS DOWN EXECUTION OF
//  MEMORY ALLOCATION, REALLOCATION AND RELEASE REQUESTS AS ALL CALLS ARE
//  REDIRECTED UPON EXECUTION.
//
//  WHILE EXECUTING CALLS TO THE MEMORY MANAGER THIS MANAGER SWITCHES BACK TO
//  THE ORIGINAL MEMORY MANAGER WHICH CAUSES EVERY MEMORY ALLOCATION MADE IN
//  MEANTIME TO BE UNMONITORED AND THEREFORE DISCARDED BY THIS MANAGER; ALTHOUGH
//  THEY GET MONITORED AND HANDLED BY THE UNDERLAYING MANGER.
// *****************************************************************************

// Include the Compiler Version and Options Settings
{$I 'Omorphia.config.inc'}

//EVERYONE UNCOMMENTING THE FOLLOWING DEFINE SHOULD BE BURNED, STONED OR
//OTHERWISE PUNISHED BY DEATH !!!
{.$DEFINE OmDebugAutoStart}

Interface

Uses
    Windows;

Procedure OmDebugMM_SetActive(EnableOmMM: Boolean);
Function OmDebugMM_IsActive: Boolean;

Implementation

Uses
    SysUtils,
    ODbgInterface;

Function OmGetMem(Size: Integer): Pointer; Forward;
Function OmFreeMem(P: Pointer): Integer; Forward;
Function OmReallocMem(P: Pointer; Size: Integer): Pointer; Forward;

Const
    OmDebugMM: TMemoryManager = (
        GetMem: OmGetMem;
        FreeMem: OmFreeMem;
        ReallocMem: OmReallocMem
        );

Var
    SysMM: TMemoryManager;

Function OmGetMem(Size: Integer): Pointer;

    Procedure DoOutput(Caller: DWORD; Ptr: Pointer; Size: Integer);
    Begin
        OmorphiaDebugStr(vl_OmDbgMM, Format('%.8x@OmAllocMemory', [Caller]),
            Format('HA@%p: Size %d', [Result, Size]));
    End;

Begin
    Result := SysMM.GetMem(Size);
    SetMemoryManager(SysMM);
    Try
        DoOutput(GetCallerAddr, Result, Size);
    Finally
        SetMemoryManager(OmDebugMM);
    End;
End;

Function OmFreeMem(P: Pointer): Integer;

    Procedure DoOutput(Caller: DWORD; Ptr: Pointer; Code: Integer);
    Begin
        OmorphiaDebugStr(vl_OmDbgMM, Format('%.8x@OmDeallocMemory', [Caller]),
            Format('HD@%p: Code %d', [Ptr, Code]));
    End;

Begin
    Result := SysMM.FreeMem(P);
    SetMemoryManager(SysMM);
    Try
        DoOutput(GetCallerAddr, P, Result);
    Finally
        SetMemoryManager(OmDebugMM);
    End;
End;

Function OmReallocMem(P: Pointer; Size: Integer): Pointer;

    Procedure DoOutput(Caller: DWORD; PtrOld, PtrNew: Pointer; SizeNew: Integer);
    Begin
        OmorphiaDebugStr(vl_OmDbgMM, Format('%.8x@OmReallocMemory', [Caller]),
            Format('HR@%p-->%p: Size %d', [PtrOld, PtrNew, SizeNew]));
    End;

Begin
    Result := SysMM.ReallocMem(P, Size);
    SetMemoryManager(SysMM);
    Try
        DoOutput(GetCallerAddr, P, Result, Size);
    Finally
        SetMemoryManager(OmDebugMM);
    End;
End;

Procedure OmDebugMM_SetActive(EnableOmMM: Boolean);

    Procedure DoEnableMsg;
    Begin
        OmorphiaDebugStr(vl_OmDbgMM, '', 'Enabling Omorphia Debug Memory Manager');
    End;

    Procedure DoDisableMsg;
    Begin
        OmorphiaDebugStr(vl_OmDbgMM, '', 'Disabling Omorphia Debug Memory Manager');
    End;

Begin
    If EnableOmMM Then
    Begin
        SetMemoryManager(SysMM);
        DoEnableMsg;
        SetMemoryManager(OmDebugMM);
    End
    Else
    Begin
        SetMemoryManager(SysMM);
        DoDisableMsg;
    End;
End;

Function OmDebugMM_IsActive: Boolean;
Var
    CurrMM: TMemoryManager;
Begin
    GetMemoryManager(CurrMM);
    Result :=
        (@CurrMM.GetMem = @OmDebugMM.GetMem) And
        (@CurrMM.ReallocMem = @OmDebugMM.ReallocMem) And
        (@CurrMM.FreeMem = @OmDebugMM.FreeMem);
End;

Initialization
    GetMemoryManager(SysMM);
    {$IFDEF OmDebugAutoStart}
    OmDebugMM_SetActive(True);
    {$ENDIF}
Finalization
    OmDebugMM_SetActive(False);
End.
