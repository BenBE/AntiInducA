Unit ODbgDetection;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Debugger Support
//
// This unit defines helper functions for detection of certain debuggers.
//
// *****************************************************************************
// To Do:
//
// *****************************************************************************
// News:
//  BenBE: Detection of Software Breakpoints (BYTE PTR [EIP] = $CC)
//  BenBE: Detection of active SoftIce based debuggers
//  BenBE: IsDebuggerActive_TLSInfo optimized a bit
//
// ****************************************************************************
// Bugs:
//  DONE -oBenBE -cBug, Dbg : IsDebuggerActive_TLSInfo only for NT Platforms
//  TODO -oBenBE -cBug, Dbg, Detection : #0000021 Fehler bei Debug-Hook-Abfrage (IsDebuggerActive_DbgHook)
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
    Classes;

//General Debugger Detection
Function IsDebuggerActive: Boolean;
Function IsDebuggerActive_TLSInfo: Boolean;
Function IsDebuggerActive_DbgHook: Boolean;

//Breakpoint Handling
Function IsBreakpoint(P: Pointer): Boolean;
Procedure DoBreakpoint;

//Detection of Hardware\Software Debuggers based on SoftIce
Function IsSoftIce: Boolean;
Function IsSoftIce1: Boolean;                                                   //Crashes with Exception $80000003 when ran without Debugger
Function IsSoftIce2: Boolean;                                                   //Crashes due to Hardware access
Function IsSoftIce3: Boolean;                                                   //Crashes due to Hardware access
Function IsSoftIce4: Boolean;

//System Information on availability of Debug Information
Function IsDebugRelease: Boolean;

//Detect VMware
function InVMWare: Boolean;

Implementation

Uses
    ODbgInterface,
    OIncProcs,
    OSysOSInfo;

Function IsDebuggerActive: Boolean;
Asm
    CALL    IsDebuggerActive_TLSInfo
    OR      AL, AL
    JNZ     @@Finish
//    CALL    IsDebuggerActive_DbgHook
//    OR      AL, AL
    JZ      IsSoftIce
@@Finish:
End;

Function IsDebuggerActive_TLSInfo: Boolean;
//Var
//    I: Integer;
//    B: PDWORD;

    Function Internal_IsReadable: Boolean;
    Asm
    PUSH    ECX
    PUSH    EAX

    PUSH    4
    PUSH    EAX
    CALL    IsBadReadPtr
    XOR     AL, $01
    SETNZ   AL

    POP     EDX
    POP     ECX
    End;

Asm
    //THX 2 uall@ogc: Hat mir ne einfachere Variante als das Lesen über die Kernel32.dll gezeigt
    //Result := False;

    CALL    IsWinNT
    TEST    EAX, EAX
    JZ      @@Finish

    MOV     EAX, DWORD PTR FS:[$00000018]
    CALL    Internal_IsReadable
    JZ      @@SearchMethod
    MOV     EAX, DWORD PTR [EDX+$00000030]
    CALL    Internal_IsReadable
    JZ      @@SearchMethod
    MOVZX   EAX, BYTE PTR [EDX+$00000002]
    TEST    EAX, $FFFFFFFE
    JZ      @@Finish

@@SearchMethod:
    PUSH    ESI

//    For I := $00 To $0F Do
//    Begin
    MOV     ECX, $00000010
    MOV     EDX, $7FFCF000
@@ReadLoop:
    XOR     EAX, EAX

    DEC     ECX
    JZ      @@FinishLoop

    //B := PDWORD($7FFD0000 + I * $1000);
    ADD     EDX, $00001000

    //If IsBadReadPtr(B, 4) Then Continue;
    MOV     EAX, EDX
    CALL    Internal_IsReadable
    JZ      @@ReadLoop

    //Result := Result Or (B^ = $00000001);
    CMP     DWORD PTR [EDX], $00010000
    //end;
    JNZ     @@ReadLoop

    SETZ    AL
    MOVZX   EAX, AL

@@FinishLoop:
    POP     ESI
@@Finish:
End;

Function IsDebuggerActive_DbgHook: Boolean;
Begin
    Result := DebugHook <> 0;
End;

Function IsDebugRelease: Boolean;
Begin
    Result := GetSystemMetrics(sm_Debug) > 0;
End;

Function IsSoftIce: Boolean;
Asm
    CALL    IsSoftIce1
    OR      AL, AL
    JZ      IsSoftIce4
End;

Function IsSoftIce1: Boolean;
Var
    debugger: Integer;
Asm
    PUSHAD
    PUSH    EBP
    XOR     EDX, EDX
    PUSH    OFFSET @@MyHandler
    PUSH    DWORD PTR FS:[EDX]
    MOV     FS:[EDX], ESP
    XOR     EAX, EAX
    MOV     debugger, 1

    MOV     EBP, 'BCHK'     // 'BCHK' -> 4243484Bh
    MOV     EAX, $00000004  // Function 4h
    INT     $03             // call int 3 (Makes Delphi stop at this location, simply continue)
    CMP     AL, $03         // compare AL with 3
    SETNZ   AL              // if <> SoftIce is loaded

    JMP     @@BehindMyHandler
@@MyHandler:
    MOV     ESP, DWORD PTR [EBP-4]
    MOV     debugger, 0
@@BehindMyHandler:
    XOR     EDX, EDX
    MOV     EAX, debugger
    POP     DWORD PTR FS:[EDX]
    POP     EDX
    POP     EBP
    POPAD
End;

Function IsSoftIce2: Boolean;
Asm
    MOV     EAX, $004F      // AX = $004F
    INT     $41             // INT 41 CPU - MS Windows debugging kernel - DEBUGGER INSTALLATION CHECK
    CMP     AX, $F386       // AX = $F386 if a debugger is present
    SETZ    AL
    MOVZX   EAX, AL
End;

Function IsSoftIce3: Boolean;
Asm
    MOV     AH, $43
    INT     $68
    CMP     AX, $F386
    SETZ    AL
    MOVZX   EAX, AL
End;

Function IsSoftIce4: Boolean;
Asm
    //Check for WinNT
    CALL    GetVersion
    TEST    EAX, $80000000

    LEA     EAX, DWORD PTR [@@SoftIceNT]
    JZ      @@IsSoftIce4_NonWin9X
    LEA     EAX, DWORD PTR [@@SoftIce9x]
@@IsSoftIce4_NonWin9X:

    //Check if we can open the desired VXD Device
    //hFile = CreateFile(
    //  "\\\\.\\SICE",
    //  GENERIC_READ | GENERIC_WRITE,
    //  FILE_SHARE_READ | FILE_SHARE_WRITE,
    //  NULL,
    //  OPEN_EXISTING,
    //  FILE_ATTRIBUTE_NORMAL,
    //  NULL);
    PUSH    0
    PUSH    FILE_ATTRIBUTE_NORMAL
    PUSH    OPEN_EXISTING
    PUSH    0
    PUSH    FILE_SHARE_READ OR FILE_SHARE_WRITE
    PUSH    GENERIC_READ OR GENERIC_WRITE
    PUSH    EAX
    CALL    CreateFile

    MOV     EDX, EAX

    //If not IsValidHandle Then Goto Finish
    TEST    EAX, EAX    //Test for NZ
    JZ      @@Finish
    NOT     EAX
    TEST    EAX, EAX    //Test for <> -1
    JZ      @@Finish

    //  CloseHandle(hFile);    // closes the handle
    PUSH    EDX
    CALL    CloseHandle

    //Return true
    XOR     EAX, EAX
    INC     EAX
    JMP     @@Finish

@@SoftIce9x:
    DB '\\.\SICE', 0
@@SoftIceNT:
    DB '\\.\NTICE', 0
@@Finish:
End;

Function IsBreakpoint(P: Pointer): Boolean;
Asm
    MOV     AL, BYTE PTR [EAX]  //Read the byte at the given Addr
    NOT     AL                  //Negate
    CMP     AL, $33             //Compare with $33
    SETZ    AL                  //If equal there's a breakpoint
    MOVZX   EAX, AL             //Expand the int to the whole EAX
End;

Procedure DebugBreak; Stdcall; External Kernel32;

Procedure DoBreakpoint;
Asm
    JMP     DebugBreak
End;

function InVMware: Boolean; 
asm 
    XOR     EAX, EAX
    
    PUSH    OFFSET @@Handler 
    PUSH    DWORD PTR FS:[EAX] 
    MOV     DWORD PTR FS:[EAX], ESP 
    MOV     EAX, 564D5868h 
    MOV     EBX, 3c6cf712h 
    MOV     ECX, 0Ah 
    MOV     DX, 5658h  
    IN      EAX, DX 
    MOV     EAX, True 
    JMP     @@NotHandle 
@@Handler: 
    MOV     EAX, [ESP+$C] 
    MOV     TContext(EAX).EIP, OFFSET @@Handled 
    XOR     EAX, EAX 
    RET 
@@Handled: 
    XOR     EAX, EAX 
@@NotHandle: 
    XOR     EBX, EBX 
    POP     DWORD PTR FS:[EBX] 
    ADD     ESP, 4 
end;

End.
