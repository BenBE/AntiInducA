Unit OVCLDebugger;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// VCL Submodule
//
// This unit encapsulates the Omorphia internal Non-VCL debugger to
// utilize its output for display in VCL programs.
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

Interface

Uses
    Windows,
    Classes,
    ODbgInterface;

Type
    TOVCLDebugger = Class(TComponent)
    Private
        FOnDebugStr: TOmorphiaDebugEvent;
        FOnErrorStr: TOmorphiaErrorEvent;
        Procedure SetOnDebugStr(Const Value: TOmorphiaDebugEvent);
        Procedure SetOnErrorStr(Const Value: TOmorphiaErrorEvent);
        { Private-Deklarationen }
    Protected
        { Protected-Deklarationen }
    Public
        { Public-Deklarationen }
        Constructor Create(AOwner: TComponent); Override;
        Destructor Destroy; Override;
    Published
        { Published-Deklarationen }
        Property OnDebugStr: TOmorphiaDebugEvent Read FOnDebugStr Write SetOnDebugStr;
        Property OnErrorStr: TOmorphiaErrorEvent Read FOnErrorStr Write SetOnErrorStr;
    End;

Implementation

{ TOVCLDebugger }

Constructor TOVCLDebugger.Create(AOwner: TComponent);
Begin
    Inherited;

    FOnDebugStr := Nil;                                                         //Initialize the fields
    FOnErrorStr := Nil;                                                         //Initialize the fields
End;

Destructor TOVCLDebugger.Destroy;
Begin
    OnErrorStr := Nil;                                                          //Remove the handler Procs
    OnDebugStr := Nil;                                                          //Remove the handler Procs

    Inherited;
End;

Procedure TOVCLDebugger.SetOnDebugStr(Const Value: TOmorphiaDebugEvent);
Begin
    If Assigned(FOnDebugStr) Then
        RemoveDebugEventHandler(FOnDebugStr);

    FOnDebugStr := Value;

    If Assigned(FOnDebugStr) Then
        AddDebugEventHandler(FOnDebugStr);
End;

Procedure TOVCLDebugger.SetOnErrorStr(Const Value: TOmorphiaErrorEvent);
Begin
    If Assigned(FOnErrorStr) Then
        RemoveErrorEventHandler(FOnErrorStr);

    FOnErrorStr := Value;

    If Assigned(FOnErrorStr) Then
        AddErrorEventHandler(FOnErrorStr);
End;

End.
