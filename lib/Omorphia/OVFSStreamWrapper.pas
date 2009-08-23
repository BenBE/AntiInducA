// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Virtual File System Streams Submodule
//
// This unit defines the basic types and objects for interaction with real
// devices, virtual mountpoints and other data access points.
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

unit OVFSStreamWrapper;

interface

uses
    Classes, OVFSStreamBase;

type    
    TOVFSToVCLStream = Class(TStream)
    Private
        FVFSStream: TOVFSStream;
        Procedure SetVFSStream(Const Value: TOVFSStream);
    Protected
        Procedure SetSize(NewSize: Longint); Overload; Override;
        {$IFDEF DELPHI6_UP}
        Procedure SetSize(Const NewSize: Int64); Overload; Override;
        {$ENDIF}
    Public
        Constructor Create(ASource: TOVFSStream); Overload; Virtual;
        Constructor Create; Overload; Virtual;
        Destructor Destroy; Override;

        Function Read(Var Buffer; Count: Integer): Integer; Override;
        Function Write(Const Buffer; Count: Integer): Integer; Override;
        Function Seek(Offset: Integer; Origin: Word): Integer; Override;

        Property VFSStream: TOVFSStream Read FVFSStream Write SetVFSStream;
    End;

    TOVCLToVFSStream = Class(TOVFSStream)
    Private
        FVCLStream: TStream;
        FOwnsVCLStream: Boolean;
        Procedure SetVCLStream(Const Value: TStream);
    Protected
        Function GetSize: Int64; Override;
        Procedure SetSize(AValue: Int64); Override;
        Function GetPosition: Int64; Override;
        Procedure SetPosition(AValue: Int64); Override;
    Public
        Constructor Create(ASource: TStream; ATakeOwnership: Boolean); Overload; Virtual;
        Constructor Create(ASource: TStream); Overload; Virtual;
        Constructor Create; Overload; Virtual;
        Destructor Destroy; Override;

        Function Read(Var Buffer; Count: Int64): Int64; Override;
        Function Write(Const Buffer; Count: Int64): Int64; Override;
        Function Seek(Offset: Int64; Origin: Word): Int64; Override;

        Property VCLStream: TStream Read FVCLStream Write SetVCLStream;
        Property OwnsVCLStream: Boolean Read FOwnsVCLStream Write FOwnsVCLStream;
    End;

implementation

uses
    SysUtils,
    ODbgInterface,
    OIncProcs,
    OLangGeneral;
    
{ TOVFSToVCLStream }

Constructor TOVFSToVCLStream.Create;
Begin
    Create(Nil);
End;

Constructor TOVFSToVCLStream.Create(ASource: TOVFSStream);
Begin
    Inherited Create;

    FVFSStream := Nil;
    VFSStream := ASource;
End;

Destructor TOVFSToVCLStream.Destroy;
Begin
    VFSStream := Nil;

    Inherited;
End;

Function TOVFSToVCLStream.Read(Var Buffer; Count: Integer): Integer;
Begin
    If Not Assigned(VFSStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := VFSStream.Read(Buffer, Count);
End;

Function TOVFSToVCLStream.Seek(Offset: Integer; Origin: Word): Integer;
Begin
    If Not Assigned(VFSStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := VFSStream.Seek(Offset, Origin);
End;

Procedure TOVFSToVCLStream.SetSize(NewSize: Integer);
Begin
    If Not Assigned(VFSStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    VFSStream.Size := NewSize;
End;

{$IFDEF DELPHI6_UP}

Procedure TOVFSToVCLStream.SetSize(Const NewSize: Int64);
Begin
    If Not Assigned(VFSStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    VFSStream.Size := NewSize;
End;
{$ENDIF}

Procedure TOVFSToVCLStream.SetVFSStream(Const Value: TOVFSStream);
Begin
    FVFSStream := Value;
End;

Function TOVFSToVCLStream.Write(Const Buffer; Count: Integer): Integer;
Begin
    If Not Assigned(VFSStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := VFSStream.Write(Buffer, Count);
End;

{ TOVCLToVFSStream }

Constructor TOVCLToVFSStream.Create;
Begin
    Create(Nil);
End;

Constructor TOVCLToVFSStream.Create(ASource: TStream; ATakeOwnership: Boolean);
Begin
    Inherited Create;

    FVCLStream := Nil;
    VCLStream := ASource;

    OwnsVCLStream := ATakeOwnership;
End;

Constructor TOVCLToVFSStream.Create(ASource: TStream);
Begin
    Create(ASource, False);
End;

Destructor TOVCLToVFSStream.Destroy;
Begin
    VCLStream := Nil;
    Inherited;
End;

Function TOVCLToVFSStream.GetPosition: Int64;
Begin
    If Not Assigned(VCLStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := VCLStream.Position;
End;

Function TOVCLToVFSStream.GetSize: Int64;
Begin
    If Not Assigned(VCLStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := VCLStream.Size;
End;

Function TOVCLToVFSStream.Read(Var Buffer; Count: Int64): Int64;
Begin
    If Not Assigned(VCLStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := VCLStream.Read(Buffer, Count);
End;

Function TOVCLToVFSStream.Seek(Offset: Int64; Origin: Word): Int64;
Begin
    If Not Assigned(VCLStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := VCLStream.Seek(Offset, Origin);
End;

Procedure TOVCLToVFSStream.SetPosition(AValue: Int64);
Begin
    If Not Assigned(VCLStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    VCLStream.Position := AValue;
End;

Procedure TOVCLToVFSStream.SetSize(AValue: Int64);
Begin
    If Not Assigned(VCLStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    VCLStream.Size := AValue;
End;

Procedure TOVCLToVFSStream.SetVCLStream(Const Value: TStream);
Begin
    If OwnsVCLStream Then
        FreeAndNilSecure(FVCLStream);

    FVCLStream := Value;
    OwnsVCLStream := False;
End;

Function TOVCLToVFSStream.Write(Const Buffer; Count: Int64): Int64;
Begin
    If Not Assigned(VCLStream) Then
        OmorphiaErrorStr(vl_Error, '', vfsSrcDataStreamNotAssigned);

    Result := VCLStream.Write(Buffer, Count);
End;

end.
 
