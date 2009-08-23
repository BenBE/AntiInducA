Unit ODbgInterface;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Debugger Support
//
// This unit provides a general Debugging Interface which provides the ability
// to trigger general events of importance to a event handler.
//
// *****************************************************************************
// To Do:
//  DONE -oBenBE -cDbg, Error : Exceptions raised by the caller
//  DONE -oBenBE -cDbg, Exception : Hooken von RaiseExcept-Anweisungen
//
// *****************************************************************************
// News:
//  - Object.Free durch FreeAndNil(Object) ersetzt, um auch die Referenz gleich zu löschen
//  - Header of ODbgInterface shortened, because use of the Dbg-Functions is encouraged
//  - OmorphiaErrorStr raises exceptions at the caller's address
//  - DbgHint function removed, VerbosityCheck moved to OmorphiaDebugStr
//  - API-Hook zum automatischen Abfangen von Exceptions, die nicht durch OmorpiaErrorStr ausgelöst wurden
//    WICHTIG: Bei Probiemen mit diesem Update bitte schnellstmöglich bei BenBE
//    melden, da dies zu argen Problemen in der Delphi-IDE führen kann!!!
//  - Locations of Exceptions are traced to line numbers when a mapfile could be found.
//  - Detailled information for WinAPI errors with caller location
//  - Advanced detection and error handling of OS generated exceptions like AVs.
//
// *****************************************************************************
// Bugs:
//  DONE -oBenBE -cBug, Dbg, Debug : DebugEvent Handler mit AV abgestürzt, beim Versuch auf Self zuzugreifen.
//  DONE -oBenBE -cBug, Dbg, Error : ErrorEvent Handler mit AV abgestürzt, beim Versuch auf Self zuzugreifen.
//  DONE -oBenBE -cBug, Dbg, Error : OmorphiaErrorStr mixed up the debug and error handlers.
//  DONE -oBenBE -cBug, Dbg, Error : RemoveDebugEvent overwrote memory of the DebugEventHandlers, not the array elements.
//  DONE -oBenBE -cBug, Dbg, Error : Bereichsüberschreitung in Zeile 402 beim beenden von DebugOmorphia
//  DONE -oBenBE -cBug, Dbg, Error : Aufruferadresse doppelt in Exception-Meldung sichtbar.
//  DONE -ouall@BenBE -cBug, Dbg, Hook : Kompatibilität für Windows 9x, wenn Modulhandle nicht im SharedMem liegt
//  DONE -oBenBE -cBug, Dbg, Debug : AV when calling ODS, ADH, ADEH, RDH or RDEH in finalization sections
//  DONE -oBenBE -cBug, Dbg, Error : AV when calling OES, AEH, AEEH, REH or REEH in finalization sections
//  TODO -oBenBE -cBug, Dbg, Except : #0000023 Problems on Stack overflows (Program completely crashes!!!)
//  TODO -oNeo@BenBE -cBug, Dbg, Except : #0000022 Mit Try...Except behandelte Exceptions werden protokolliert.
//  DONE -oBenBE -cBug, Dbg, Debug : Hinzugefügte DebugEvent-Handler wurden nicht korrekt wiedergefunden
//  DONE -oBenBE -cBug, Dbg, Error : Hinzugefügte ErrorEvent-Handler wurden nicht korrekt wiedergefunden
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

//Outputs a debug message (Hint, Warning) WITHOUT raising an exception
Procedure OmorphiaDebugStr(Level: Integer; Place: String; Desc: String);
//Outputs a debug message (Error) AND raises the given Exception.
Procedure OmorphiaErrorStr(Level: Integer; Place: String; Desc: String; ErrorObj: Exception = Nil);

//MSG BenBE : Some short names \ aliases for OmorphiaDebugStr und OmorphiaErrorStr ...
//MSG BenBE : Use with care; I might remove them sometime ...
Const
    ODS: Procedure(Level: Integer; Place: String; Desc: String) = OmorphiaDebugStr;
    OES: Procedure(Level: Integer; Place: String; Desc: String; ErrorObj: Exception = Nil) = OmorphiaErrorStr;

//Event Handler Proto Types for Handler Procedures
Type
    TOmorphiaDebugHandler = Procedure(Level: Integer; Place: TODbgMapLocation; Desc: String; Var Handled: Boolean);
    TOmorphiaDebugEvent = Procedure(Sender: TObject; Level: Integer; Place: TODbgMapLocation; Desc: String; Var Handled: Boolean) Of Object;
    TOmorphiaErrorHandler = Procedure(Level: Integer; Place: TODbgMapLocation; Desc: String; Var ErrorObj: Exception; Var Handled: Boolean);
    TOmorphiaErrorEvent = Procedure(Sender: TObject; Level: Integer; Place: TODbgMapLocation; Desc: String; Var ErrorObj: Exception; Var Handled: Boolean) Of Object;

Procedure DbgResetOSError;
Procedure DbgLastOSError(DoError: Boolean = True);

//Management functions to add a new event handler
Procedure AddDebugHandler(Handler: TOmorphiaDebugHandler);
Procedure AddDebugEventHandler(Handler: TOmorphiaDebugEvent);
Procedure AddErrorHandler(Handler: TOmorphiaErrorHandler);
Procedure AddErrorEventHandler(Handler: TOmorphiaErrorEvent);

//Management functions to remove an existing event handler
Procedure RemoveDebugHandler(Handler: TOmorphiaDebugHandler);
Procedure RemoveDebugEventHandler(Handler: TOmorphiaDebugEvent);
Procedure RemoveErrorHandler(Handler: TOmorphiaErrorHandler);
Procedure RemoveErrorEventHandler(Handler: TOmorphiaErrorEvent);

//Flags to signal if OmorphiaDebugStr und OmorphiaErrorStr redirect their input to the custom handlers
//The state is set by the general config file.
Const
    Omorphia_UseDbg_HandleWarnings = {$IFDEF OMORPHIA_USEDBG_WARNINGS}True{$ELSE}False{$ENDIF};
    Omorphia_UseDbg_HandleErrors = {$IFDEF OMORPHIA_USEDBG_ERRORS}True{$ELSE}False{$ENDIF};

Const
    // Some debug level for use to better member
    vl_OmDbgMM = 0;
    vl_Hint = 1;
    vl_Warning = 2;
    vl_Error = 3;
    vl_FatalError = 4;
    vl_UseWinAPI = 5;
    vl_CodeName = 6;
    vl_Timing = 7;
    vl_Exception = 10;

    vl_all = 0;
    vl_Max = 10;
    vln: Array[0..vl_Max] Of String = (
        'show messages of the Omorphia Debug Memory Manager',
        'show every detail and hint of execution',
        'show warnings of special situations',
        'show internal errors returned by Omorphia',
        'show fatal errors, that can''t be ignored',
        'show OS errors returned by the API',
        'show current the source location',
        'show timing info for special parts of the source',
        'not defined',
        'not defined',
        'show really critical system faults only'
        );

Var
    //MSG BenBE : Ask Neo for this function's purpose :D
    VerboseLevel: Integer = vl_Max;

Function GetCallerAddr: DWORD; Register; Assembler;

Implementation

Uses
    SysConst,
    uallHook,
    ODbgMapfile,
    OIncProcs;

Var
    PatchOld: Procedure = Nil;
    InDebugHandler: Boolean = False;

Const                                                                           { copied from xx.h, recopied from System.pas }
    cContinuable = 0;
    cNonContinuable = 1;
    cUnwinding = 2;
    cUnwindingForExit = 4;
    cUnwindInProgress = cUnwinding Or cUnwindingForExit;
    cDelphiException = $0EEDFADE;
    cDelphiReRaise = $0EEDFADF;
    cDelphiExcept = $0EEDFAE0;
    cDelphiFinally = $0EEDFAE1;
    cDelphiTerminate = $0EEDFAE2;
    cDelphiUnhandled = $0EEDFAE3;
    cNonDelphiException = $0EEDFAE4;
    cDelphiExitFinally = $0EEDFAE5;
    cCppException = $0EEFFACE;                                                  { used by BCB }

    {$IFDEF DELPHI6_DOWN}
Type
    // DONE -oBenBE -cODbgInterface : EWin32Error mit EOSError ersetzen, da der Compiler ihn sonst ablehnt ;-)
    EOSError = EWin32Error;
    {$ENDIF}

Procedure DbgResetOSError;
Begin
    SetLastErrorEx(0, 0);
    If GetLastError <> 0 Then
        OmorphiaErrorStr(vl_UseWinAPI, '', 'Error resetting GetLastError value!');
End;

Procedure DbgLastOSError(DoError: Boolean = True);
Var
    OSErr: Integer;
Begin
    OSErr := GetLastError;
    Try
        If OSErr <> 0 Then
        Begin
            If DoError Then
                OmorphiaErrorStr(vl_UseWinAPI, Format('%.8x@', [GetCallerAddr]),
                    Format('WinAPIError %d (0x%.8x): %s', [OSErr, OSErr, SysErrorMessage(OSErr)]),
                    EOSError.CreateFmt(SWin32Error, [OSErr, SysErrorMessage(OSErr)]))
            Else
                OmorphiaDebugStr(vl_UseWinAPI, Format('%.8x@', [GetCallerAddr]),
                    Format('WinAPIError %d (0x%.8x): %s', [OSErr, OSErr, SysErrorMessage(OSErr)]));
        End;
    Finally
        DbgResetOSError;
    End;
End;

Var
    //Internal variables holding the non-VCL event handlers
    DebugHandler: TList = Nil;
    ErrorHandler: TList = Nil;

Type
    //Internal Error Handler object class for the VCL Debugger.
    //This is named NonVCL, because it cannot be used as component or in the
    //VCL streaming routines.
    TODbgDebuggerNonVCL = Class(TObject)
    Private
        FDebugEventHandler: Array Of TOmorphiaDebugEvent;
        FErrorEventHandler: Array Of TOmorphiaErrorEvent;
    Public
        Constructor Create; Reintroduce; Virtual;
        Destructor Destroy; Override;

        // Procedures too Add And Remove the VCL Event Handlers
        Procedure AddDebugEventHandler(Handler: TOmorphiaDebugEvent);
        Procedure RemoveDebugEventHandler(Handler: TOmorphiaDebugEvent);

        Procedure AddErrorEventHandler(Handler: TOmorphiaErrorEvent);
        Procedure RemoveErrorEventHandler(Handler: TOmorphiaErrorEvent);
    End;

Var
    //Make an Variable of the Debugger Object
    OmorphiaDebugger: TODbgDebuggerNonVCL;

    //Internal function to get the caller address (of the calling function)

Function GetCallerAddr: DWORD; Register; Assembler;
Asm
    //This function reads the stack frame of the calling function.
    //This function itself has none such stack frame, because there are
    //no Paramters or local variables that would requiere this.

    //DWORD PTR [ESP]   is the own return address (because there's no stack frame for this function)
    //DWORD PTR [EBP]   is the next stack frame
    //DWORD PTR [EBP+4] is the calling functions return address
    MOV     EAX, DWORD PTR [EBP+$04]
End;

//Outputs a debug message (Hint, Warning) WITHOUT raising an exception

Procedure OmorphiaDebugStr(Level: Integer; Place: String; Desc: String);
Var
    X: Integer;
    Handled: Boolean;
    PH: TOmorphiaDebugHandler;
    PE: TOmorphiaDebugEvent;
    TmpPlace: TODbgMapLocation;
Begin
    If Level < VerboseLevel Then
        Exit;

    //request different caller address if correct format is given
    If (Pos('@', Place) = 9) And (StrToIntDef('$' + Copy(Place, 1, 8), 0) = StrToIntDef('$' + Copy(Place, 1, 8), 1)) Then
        TmpPlace := AddressToLocation(Pointer(StrToIntDef('$' + Copy(Place, 1, 8), 0)))
    Else
        TmpPlace := AddressToLocation(Pointer(GetCallerAddr));

    //Output the hint to the debugging console
    OutputDebugString(PChar(Format('Omorphia (Debug Level %0:d): %2:s: %3:s',
        [Level, DWORD(TmpPlace.Address), PlaceToLocationStr(TmpPlace), Desc])));

    {$IFDEF OMORPHIA_USEDBG_WARNINGS}
    //DONE -oBenBE -cDbg, Debug : Warnung, wenn Debugger-Warnungen compilerseitig abgeschaltet sind.
    Handled := False;
    If Assigned(DebugHandler) Then
    Begin
        // Done -oBenBE -cDbg, Debug : DebugHandlerProcs implementieren
        For X := 0 To DebugHandler.Count - 1 Do
        Begin
            //Load the address of some debug handler
            PH := DebugHandler[X];
            //Call it with our paramters
            PH(Level, TmpPlace, Desc, Handled);
            //If no further handling is needed, exit the loop
            If Handled Then
                Break;
        End;
    End;

    // Done -oBenBE -cDbg, Debug : DebugEventHandlerProcs implementieren
    If Not Handled Then
    Begin
        If Assigned(OmorphiaDebugger) Then
        Begin
            For X := 0 To High(OmorphiaDebugger.FDebugEventHandler) Do
            Begin
                //Load the address of some debug handler
                PE := OmorphiaDebugger.FDebugEventHandler[X];
                //Call it with our paramters, give OmorphiaDebugger as Sender
                PE(OmorphiaDebugger, Level, TmpPlace, Desc, Handled);
                //If no further handling is needed, exit the loop
                If Handled Then
                    Break;
            End;
        End;
    End;
    {$ENDIF}
End;

//Outputs a debug message (Error) AND raises the given Exception.

Procedure OmorphiaErrorStr(Level: Integer; Place: String; Desc: String; ErrorObj: Exception = Nil);
Var
    X: Integer;
    Handled: Boolean;
    PH: TOmorphiaErrorHandler;
    PE: TOmorphiaErrorEvent;
    TmpPlace: TODbgMapLocation;
Begin
    If Level < VerboseLevel Then
        Exit;

    //request different caller address if correct format is given
    If (Pos('@', Place) = 9) And (StrToIntDef('$' + Copy(Place, 1, 8), 0) = StrToIntDef('$' + Copy(Place, 1, 8), 1)) Then
        TmpPlace := AddressToLocation(Pointer(StrToIntDef('$' + Copy(Place, 1, 8), 0)))
    Else
        TmpPlace := AddressToLocation(Pointer(GetCallerAddr));

    //Output the error to the debugging console
    If Assigned(ErrorObj) Then
        OutputDebugString(PChar(Format('Omorphia (Error Level %0:d): %2:s: %3:s (%s: %s)',
            [Level, DWORD(TmpPlace.Address), PlaceToLocationStr(TmpPlace), Desc, ErrorObj.ClassName, ErrorObj.Message])))
    Else
        OutputDebugString(PChar(Format('Omorphia (Error Level %0:d): %2:s: %3:s (NIL)',
            [Level, DWORD(TmpPlace.Address), PlaceToLocationStr(TmpPlace), Desc])));

    Handled := False;
    If Assigned(ErrorHandler) Then
    Begin
        // Done -oBenBE -cDbg, Error : ErrorHandlerProcs implementieren
        For X := 0 To ErrorHandler.Count - 1 Do
        Begin
            //Load the address of some error handler
            PH := ErrorHandler[X];
            //Call it with our paramters
            PH(Level, TmpPlace, Desc, ErrorObj, Handled);
            //If no further handling is needed, exit the loop
            If Handled Then
                Break;
        End;
    End;

    // Done -oBenBE -cDbg, Error : ErrorEventHandlerProcs implementieren
    If Not Handled Then
    Begin
        If Assigned(OmorphiaDebugger) Then
        Begin
            For X := 0 To High(OmorphiaDebugger.FErrorEventHandler) Do
            Begin
                //Load the address of some error handler
                PE := OmorphiaDebugger.FErrorEventHandler[X];
                //Call it with our paramters, give OmorphiaDebugger as Sender
                PE(OmorphiaDebugger, Level, TmpPlace, Desc, ErrorObj, Handled);
                //If no further handling is needed, exit the loop
                If Handled Then
                    Break;
            End;
        End;
    End;

    //Check if an exception was given and if not, create a std exception object presenting our message
    If Not Assigned(ErrorObj) Then
        ErrorObj := ExceptClass.CreateFmt('Omorphia (Error Level %0:d): %2:s: %3:s', [Level, GetCallerAddr, Place, Desc]);

    //If not handled raise it, else simply free it.
    Try
        InDebugHandler := True;
        If Not Handled Then
            Raise ErrorObj at Pointer(GetCallerAddr)
        Else
            FreeAndNil(ErrorObj);
    Finally
        InDebugHandler := False;
    End;
End;

Procedure OmorphiaExceptStr(dwExceptionCode: DWORD; dwExceptionFlags: DWORD; nNumberOfArguments: DWORD; lpArguments: PDWORD); Stdcall;
Type
    PExceptData = ^TExceptData;
    TExceptData = Packed Record
        Case Integer Of
            0:
            (
                ExceptAddr: Pointer;                                            // Pretended\real address of failure
                ExceptObj: TObject;                                             // Exception object by the application\system
                Reg_EBX: DWORD;                                                 // Old Register of EBX
                Reg_ESI: DWORD;                                                 // Old Register of ESI
                Reg_EDI: DWORD;                                                 // Old Register of EDI
                Reg_EBP: DWORD;                                                 // Old Register of EBP
                Reg_ESP: DWORD;                                                 // Old Register of ESP
                );
            1:
            (
                Arg1: DWORD;
                Arg2: DWORD;
                Arg3: DWORD;
                Arg4: DWORD;
                );
    End;

Const
    ExceptionAV_RWFlag: Array[Boolean] Of String = ('reading', 'writing');

Var
    Place: ^TODbgMapLocation;
    Msg: String;
    Data: PExceptData;

Var
    ExceptionInfo: PExceptionRecord;

    Procedure OutputExceptionToDebugger;
    Begin
        If Assigned(Data^.ExceptObj) And (Data^.ExceptObj Is Exception) Then
            OutputDebugString(PChar(Format('Omorphia (Error Level %0:d): %2:s: %3:s (%s: %s)', [vl_Exception, DWORD(Data^.ExceptAddr), PlaceToLocationStr(Place^), Msg, Data^.ExceptObj.ClassName, Exception(Data^.ExceptObj).Message])))
        Else
            OutputDebugString(PChar(Format('Omorphia (Error Level %0:d): %2:s: %3:s (NIL)', [vl_Exception, DWORD(Data^.ExceptAddr), PlaceToLocationStr(Place^), Msg])));
    End;

    Procedure OutputException;
    Var
        X: Integer;
        Handled: Boolean;
        PH: TOmorphiaErrorHandler;
        PE: TOmorphiaErrorEvent;
    Begin
        OutputExceptionToDebugger;

        Handled := False;
        If Assigned(ErrorHandler) Then
        Begin
            // Done -oBenBE -cDbg, Exception : ErrorHandlerProcs implementieren
            For X := 0 To ErrorHandler.Count - 1 Do
            Begin
                //Load the address of some error handler
                PH := ErrorHandler[X];
                //Call it with our paramters
                PH(vl_Exception, Place^, Msg, Exception(Data^.ExceptObj), Handled);
                //If no further handling is needed, exit the loop
                If Handled Then
                    Break;
            End;
        End;

        // Done -oBenBE -cDbg, Exception : ErrorEventHandlerProcs implementieren
        If Not Handled Then
        Begin
            If Assigned(OmorphiaDebugger) Then
            Begin
                For X := 0 To High(OmorphiaDebugger.FErrorEventHandler) Do
                Begin
                    //Load the address of some error handler
                    PE := OmorphiaDebugger.FErrorEventHandler[X];
                    //Call it with our paramters, give OmorphiaDebugger as Sender
                    PE(OmorphiaDebugger, vl_Exception, Place^, Msg, Exception(Data^.ExceptObj), Handled);
                    //If no further handling is needed, exit the loop
                    If Handled Then
                        Break;
                End;
            End;
        End;
    End;

Begin
    Try
        InDebugHandler := True;
        DWORD(Data) := DWORD(lpArguments);

        Case dwExceptionCode Of
            cDelphiExcept, cDelphiFinally, cDelphiTerminate, cDelphiUnhandled, cNonDelphiException, cDelphiExitFinally, cCppException:
                Begin
                    Exit;
                End;
            cDelphiException:
                Begin
                    New(Place);
                    Try
                        Place^ := AddressToLocation(Data^.ExceptAddr);
                        Msg := Format('Delphi Exception at %p: ESP=%.8x, EBP=%.8x, ESI=%.8x, EDI=%.8x, EBX=%.8x.', [Data^.ExceptAddr, Data^.Reg_ESP, Data^.Reg_EBP, Data^.Reg_ESI, Data^.Reg_EDI, Data^.Reg_EBX]);

                        OutputException;
                    Finally
                        Dispose(Place);
                    End;
                End;
        Else
            ExceptionInfo := PExceptionRecord(Data);

            New(Place);
            Try
                Place^ := AddressToLocation(ExceptionInfo^.ExceptionAddress);

                Case dwExceptionCode Of
                    EXCEPTION_ACCESS_VIOLATION:
                        Begin
                            Msg := Format('Access Violation at %p: An exception occured while %s address %p.', [ExceptionInfo^.ExceptionAddress, ExceptionAV_RWFlag[ExceptionInfo^.ExceptionInformation[0] <> 0], Pointer(ExceptionInfo^.ExceptionInformation[1])]);

                            OutputException;
                        End;
                    EXCEPTION_DATATYPE_MISALIGNMENT:
                        Begin
                            Msg := Format('Datatype misalignment while executing an instruction at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_BREAKPOINT:
                        Begin
                            Msg := Format('Software breakpoint at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_SINGLE_STEP:
                        Begin
                            Msg := Format('Single step trap at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_ARRAY_BOUNDS_EXCEEDED:
                        Begin
                            Msg := Format('Hardware array bounds exceeded by index operation at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_FLT_DENORMAL_OPERAND:
                        Begin
                            Msg := Format('Operation involving a denormalized floating point number at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_FLT_DIVIDE_BY_ZERO:
                        Begin
                            Msg := Format('Floating point division by zero operation encountered at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_FLT_INEXACT_RESULT:
                        Begin
                            Msg := Format('Inexact floating point result exception encountered at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_FLT_INVALID_OPERATION:
                        Begin
                            Msg := Format('Encountered an invalid floating point operation at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_FLT_OVERFLOW:
                        Begin
                            Msg := Format('Floating point overflow while performing an operation at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_FLT_STACK_CHECK:
                        Begin
                            Msg := Format('Floating point stack overflow or underflow exception while performing instruction at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_FLT_UNDERFLOW:
                        Begin
                            Msg := Format('Floating point underflow at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_INT_DIVIDE_BY_ZERO:
                        Begin
                            Msg := Format('Integer division by zero operation encountered at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_INT_OVERFLOW:
                        Begin
                            Msg := Format('Integer overflow while rangechecking at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_PRIV_INSTRUCTION:
                        Begin
                            Msg := Format('Error at %p while executing a priviledged instruction not allowed in usermode.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_IN_PAGE_ERROR:
                        Begin
                            Msg := Format('Error at %p while switching to memory page not currently present to the program.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_ILLEGAL_INSTRUCTION:
                        Begin
                            Msg := Format('Trying to execute an invalid or unknown instruction at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_NONCONTINUABLE_EXCEPTION:
                        Begin
                            Msg := Format('Uncontinuable exception at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_STACK_OVERFLOW:
                        Begin
                            Msg := Format('Stack overflow at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_INVALID_DISPOSITION:
                        Begin
                            Msg := Format('Error at %p while executing a priviledged instruction not allowed in usermode.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_GUARD_PAGE:
                        Begin
                            Msg := Format('Performing access to an guarded page at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    EXCEPTION_INVALID_HANDLE:
                        Begin
                            Msg := Format('The operation at %p tried to use an invalid handle.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                    CONTROL_C_EXIT:
                        Begin
                            Msg := Format('Control-C handler called at %p.', [ExceptionInfo^.ExceptionAddress]);

                            OutputException;
                        End;
                End;
            Finally
                Dispose(Place);
            End;
        End;
    Finally
        InDebugHandler := False;
    End;
End;

Procedure AddDebugHandler(Handler: TOmorphiaDebugHandler);
Begin
    // Done -oBenBE -cDbg, Interface: AddDebugHandler implementieren
    If Not Assigned(DebugHandler) Then
        Exit;

    //Search for the given handler and if not found, add it.
    If DebugHandler.IndexOf(@Handler) = -1 Then
        DebugHandler.Add(@Handler);
End;

Procedure AddDebugEventHandler(Handler: TOmorphiaDebugEvent);
Begin
    // Done -oBenBE -cDbg, Interface: AddDebugEventHandler implementieren
    If Not Assigned(OmorphiaDebugger) Then
        Exit;

    //Call the omorphia debugger for handling the new event handler
    OmorphiaDebugger.AddDebugEventHandler(Handler);
End;

Procedure AddErrorHandler(Handler: TOmorphiaErrorHandler);
Begin
    // Done -oBenBE -cDbg, Interface: AddErrorHandler implementieren
    If Not Assigned(ErrorHandler) Then
        Exit;

    //Search for the given handler and if not found, add it.
    If ErrorHandler.IndexOf(@Handler) = -1 Then
        ErrorHandler.Add(@Handler);
End;

Procedure AddErrorEventHandler(Handler: TOmorphiaErrorEvent);
Begin
    // Done -oBenBE -cDbg, Interface: AddErrorEventHandler implementieren
    If Not Assigned(OmorphiaDebugger) Then
        Exit;

    //Call the omorphia debugger for handling the new event handler
    OmorphiaDebugger.AddErrorEventHandler(Handler);
End;

Procedure RemoveDebugHandler(Handler: TOmorphiaDebugHandler);
Var
    X: Integer;
Begin
    // Done -oBenBE -cDbg, Interface: RemoveDebugHandler implementieren
    If Not Assigned(DebugHandler) Then
        Exit;

    //Look if the given handler was added previously and if found, delete it.
    X := DebugHandler.IndexOf(@Handler);
    If X <> -1 Then
        DebugHandler.Delete(X)
    Else
        OmorphiaDebugStr(vl_Warning, '', 'The given Debug Handler wasn''t added before.');
End;

Procedure RemoveDebugEventHandler(Handler: TOmorphiaDebugEvent);
Begin
    // Done -oBenBE -cDbg, Interface: RemoveDebugEventHandler implementieren
    If Not Assigned(OmorphiaDebugger) Then
        Exit;

    //Ask the Omorphia Debugger to remove the given handler
    OmorphiaDebugger.RemoveDebugEventHandler(Handler);
End;

Procedure RemoveErrorHandler(Handler: TOmorphiaErrorHandler);
Var
    X: Integer;
Begin
    // Done -oBenBE -cDbg, Interface: RemoveErrorHandler implementieren
    If Not Assigned(ErrorHandler) Then
        Exit;

    //Look if the given handler was added previously and if found, delete it.
    X := ErrorHandler.IndexOf(@Handler);
    If X <> -1 Then
        ErrorHandler.Delete(X)
    Else
        OmorphiaDebugStr(vl_Warning, '', 'The given Error Handler wasn''t added before.');
End;

Procedure RemoveErrorEventHandler(Handler: TOmorphiaErrorEvent);
Begin
    // Done -oBenBE -cDbg, Interface: RemoveErrorEventHandler implementieren
    If Not Assigned(OmorphiaDebugger) Then
        Exit;

    //Ask the Omorphia Debugger to remove the given handler
    OmorphiaDebugger.RemoveErrorEventHandler(Handler);
End;

{ TODbgDebuggerNonVCL }

Procedure TODbgDebuggerNonVCL.AddDebugEventHandler(Handler: TOmorphiaDebugEvent);
Var
    X: Integer;
Begin
    //Look for the given handler and if found, simply exit
    For X := 0 To High(FDebugEventHandler) Do
        If PInt64(@FDebugEventHandler[X])^ = PInt64(@Handler)^ Then
            Exit;

    //If not found add it to the queue
    SetLength(FDebugEventHandler, Length(FDebugEventHandler) + 1);
    FDebugEventHandler[High(FDebugEventHandler)] := Handler;
End;

Procedure TODbgDebuggerNonVCL.AddErrorEventHandler(Handler: TOmorphiaErrorEvent);
Var
    X: Integer;
Begin
    //Look for the given handler and if found, simply exit
    For X := 0 To High(FErrorEventHandler) Do
        If PInt64(@FErrorEventHandler[X])^ = PInt64(@Handler)^ Then
            Exit;

    //If not found add it to the queue
    SetLength(FErrorEventHandler, Length(FErrorEventHandler) + 1);
    FErrorEventHandler[High(FErrorEventHandler)] := Handler;
End;

Constructor TODbgDebuggerNonVCL.Create;
Begin
    Inherited;

    //Initialize the arrays holding the Event handler info
    SetLength(FDebugEventHandler, 0);
    SetLength(FErrorEventHandler, 0);
End;

Destructor TODbgDebuggerNonVCL.Destroy;
Begin
    //Finalize the arrays holding the Event handler info
    SetLength(FDebugEventHandler, 0);
    SetLength(FErrorEventHandler, 0);

    Inherited;
End;

Procedure TODbgDebuggerNonVCL.RemoveDebugEventHandler(Handler: TOmorphiaDebugEvent);
Var
    X: Integer;
Begin
    //Look for the given handler in the handler list
    For X := High(FDebugEventHandler) Downto 0 Do
        If PInt64(@FDebugEventHandler[X])^ = PInt64(@Handler)^ Then
        Begin
            //If found move all remaining handlers one place to the front
            If High(FDebugEventHandler) > X Then
                Move(@FDebugEventHandler[X + 1], @FDebugEventHandler[X], (High(FDebugEventHandler) - X) * SizeOf(TOmorphiaDebugEvent));
            //Delete the unnecessary entry
            SetLength(FDebugEventHandler, High(FDebugEventHandler));
            Exit;
        End;

    OmorphiaDebugStr(vl_Warning, '', 'The given Debug Event Handler wasn''t added before.');
End;

Procedure TODbgDebuggerNonVCL.RemoveErrorEventHandler(Handler: TOmorphiaErrorEvent);
Var
    X: Integer;
Begin
    //Look for the given handler in the handler list
    For X := High(FErrorEventHandler) Downto 0 Do
        If PInt64(@FErrorEventHandler[X])^ = PInt64(@Handler)^ Then
        Begin
            //If found move all remaining handlers one place to the front
            If High(FErrorEventHandler) > X Then
                Move(@FErrorEventHandler[X + 1], @FErrorEventHandler[X], (High(FErrorEventHandler) - X) * SizeOf(TOmorphiaErrorEvent)); //Bereichsüberschreitung
            //Delete the unnecessary entry
            SetLength(FErrorEventHandler, High(FErrorEventHandler));
            Exit;
        End;

    OmorphiaDebugStr(vl_Warning, '', 'The given Error Event Handler wasn''t added before.');
End;

//Advanced Exception Handler (Hook)

Var
    OldDebugHook: Byte = 0;
    OldRaiseException: Pointer = Nil;

Procedure LocalRaiseExceptHook; Stdcall;

//Parameters:
//  dwExceptionCode: DWORD;
//  dwExceptionFlags: DWORD;
//  nNumberOfArguments: DWORD;
//  lpArguments: PDWORD;
Asm
    //Create the stack frame foor the current procedure
    PUSH    EBP
    MOV     EBP, ESP

    //We are already in an error or exception handler.
    //Avoid recursion!
    CMP     BYTE PTR [InDebugHandler], $00
    JNZ     @SkipHandling

    //Read the Exception Code into EDX
    MOV     EAX, DWORD PTR [EBP+$08]

    //Test if it's a Delphi-specific Exception
    CMP     EAX, cDelphiException
    JZ      @HandleDelphiException

    //If not, handle an system exception!
    CMP     EAX, cNonDelphiException
    JZ      @HandleNonDelphiException
    JMP     @SkipHandling

@HandleDelphiException:
    //Handle an Delphi Exception
    PUSH    DWORD PTR [EBP+$14]
    PUSH    DWORD PTR [EBP+$10]
    PUSH    DWORD PTR [EBP+$0C]
    PUSH    EAX
    PUSH    OFFSET [@SkipHandling]
    JMP     OmorphiaExceptStr

@HandleNonDelphiException:
    //Get the true exception info!

    MOV     EAX, DWORD PTR [EBP+$14]
    TEST    EAX, EAX
    JZ      @SkipHandling

    MOV     EAX, DWORD PTR [EAX+$14]
    TEST    EAX, EAX
    JZ      @SkipHandling

    PUSH    EAX
    PUSH    4
    PUSH    DWORD PTR [EAX+$04]
    PUSH    DWORD PTR [EAX]
    CALL    OmorphiaExceptStr

@SkipHandling:
    POP     EBP

    JMP     DWORD PTR [PatchOld]
End;

Initialization
    // Neo: for debug only setup "VerboseLevel" to show all
    VerboseLevel := 0;
    DebugHandler := TList.Create;
    ErrorHandler := TList.Create;
    OmorphiaDebugger := TODbgDebuggerNonVCL.Create;

    //Create a Raise Exception hook to automatically handle Raise Exception Constructs and other Errors
    If Not HookApiIAT('kernel32.dll', 'RaiseException', @LocalRaiseExceptHook, @PatchOld) Then
        OmorphiaDebugStr(vl_Warning, '', 'Error initializing Raise Exception Hook');

Finalization
    //Unhook the RaiseException Handler
    Try
        If Not UnhookApiIAT(@LocalRaiseExceptHook, @PatchOld) Then
            OmorphiaDebugStr(vl_Warning, '', 'Error finalizing Raise Exception Hook');
    Except
        OmorphiaDebugStr(vl_Warning, '', 'Error finalizing Raise Exception Hook');
    End;

    If Assigned(OmorphiaDebugger) Then
        FreeAndNil(OmorphiaDebugger);
    If Assigned(ErrorHandler) Then
        FreeAndNil(ErrorHandler);
    If Assigned(DebugHandler) Then
        FreeAndNil(DebugHandler);
End.

