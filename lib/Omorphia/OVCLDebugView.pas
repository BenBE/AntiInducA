Unit OVCLDebugView;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// VCL Submodule
//
// This unit implements an easy way to include the DebugView into the project
// without handling all the stuff manually.
//
// *****************************************************************************
// To Do:
//  TODO -oMatze -cVCL, DebugView : Colorizing the items by kind
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
    SysUtils,
    Classes,
    Controls,
    Graphics,
    ComCtrls,
    OIncTypes;

Type
    //This type defines the different columns that can be displayed
    TOVCLDebugViewColumns = Set Of (
        ovcldvcTimestamp,
        ovcldvcMsgType,
        ovcldvcMsgLevel,
        ovcldvcPlaceAddr,
        ovcldvcPlaceModule,
        ovcldvcPlaceUnite,
        ovcldvcPlaceFile,
        ovcldvcPlaceFileLine,
        ovcldvcPlaceProcedure,
        ovcldvcMsgDescription,
        ovcldvcErrorClass,
        ovcldvcErrorMsg
        );

Type
    TOVCLDebugView = Class(TCustomListView)
    Private
        { Private-Deklarationen }
        FLiveScrolling: Boolean;
        FMaxItems: Integer;
        Procedure SetLiveScrolling(Const Value: Boolean);
        Procedure SetMaxItems(Const Value: Integer);
        Procedure DoLiveScroll;
        Procedure DoMaxItemCutoff;

        Function GetItemColor(Item: TListItem): TColor;
        Procedure OmCDI(Sender: TCustomListView; Item: TListItem;
            State: TCustomDrawState; Var DefaultDraw: Boolean);
    Protected
        { Protected-Deklarationen }
        Procedure HandleDebugStr(Sender: TObject; Level: Integer;
            Place: TODbgMapLocation; Desc: String; Var Handled: Boolean);
        Procedure HandleErrorStr(Sender: TObject; Level: Integer;
            Place: TODbgMapLocation; Desc: String; Var ErrorObj: Exception;
            Var Handled: Boolean);
    Public
        { Public-Deklarationen }
        Constructor Create(AOwner: TComponent); Override;
        Destructor Destroy; Override;
    Published
        { Published-Deklarationen }
        Property Action;
        Property Align;
        Property Anchors;
        Property BevelEdges;
        Property BevelInner;
        Property BevelOuter;
        Property BevelKind Default bkNone;
        Property BevelWidth;
        Property BiDiMode;
        Property BorderStyle;
        Property BorderWidth;
        Property Color;
        Property Constraints;
        Property Ctl3D;
        Property DragCursor;
        Property DragKind;
        Property DragMode;
        Property Enabled;
        Property Font;
        Property FlatScrollBars;
        Property FullDrag;
        Property GridLines;
        Property HideSelection;
        Property HotTrack;
        Property HotTrackStyles;
        Property HoverTime;
        Property IconOptions;
        Property Items Stored False;
        Property ParentBiDiMode;
        Property ParentColor Default False;
        Property ParentFont;
        Property ParentShowHint;
        Property PopupMenu;
        Property ShowColumnHeaders;
        Property ShowWorkAreas;
        Property ShowHint;
        Property TabOrder;
        Property TabStop Default True;
        Property Visible;
        Property OnChange;
        Property OnChanging;
        Property OnClick;
        Property OnContextPopup;
        Property OnDblClick;
        Property OnDeletion;
        Property OnEndDock;
        Property OnEndDrag;
        Property OnEnter;
        Property OnExit;
        Property OnDragDrop;
        Property OnDragOver;
        Property OnInfoTip;
        Property OnInsert;
        Property OnKeyDown;
        Property OnKeyPress;
        Property OnKeyUp;
        Property OnMouseDown;
        Property OnMouseMove;
        Property OnMouseUp;
        Property OnResize;
        Property OnSelectItem;

        Property LiveScrolling: Boolean Read FLiveScrolling
            Write SetLiveScrolling Default True;
        Property MaxItems: Integer Read FMaxItems Write SetMaxItems Default 0;
    End;

Implementation

Uses
    ODbgInterface;

{ TOVCLDebugView }

Constructor TOVCLDebugView.Create(AOwner: TComponent);

    Procedure CreateCol(ColName: String; ColSize: Integer);
    Begin
        With Columns.Add Do
        Begin
            Caption := ColName;
            Width := ColSize;
        End;
    End;

Begin
    Inherited;

    RowSelect := True;
    ReadOnly := True;
    ColumnClick := False;
    AllocBy := 64;
    Checkboxes := False;
    SortType := stNone;
    ViewStyle := vsReport;

    FLiveScrolling := True;
    FMaxItems := 0;

    CreateCol('Zeit', 55);
    CreateCol('Typ', 40);
    CreateCol('Level', 25);
    CreateCol('Adresse', 75);
    CreateCol('Modul', 100);
    CreateCol('Unit', 100);
    CreateCol('Datei', 100);
    CreateCol('Zeile', 50);
    CreateCol('Routine', 150);
    CreateCol('Beschreibung', 250);
    CreateCol('Exception (Class)', 75);
    CreateCol('Exception (Beschreibung)', 175);

    AddDebugEventHandler(HandleDebugStr);
    AddErrorEventHandler(HandleErrorStr);

    OnCustomDrawItem := OmCDI;
End;

Destructor TOVCLDebugView.Destroy;
Begin
    RemoveErrorEventHandler(HandleErrorStr);
    RemoveDebugEventHandler(HandleDebugStr);
    Inherited;
End;

Procedure TOVCLDebugView.DoLiveScroll;
Begin
    If Items.Count <= 0 Then
        Exit;

    If LiveScrolling Then
        Items[Items.Count - 1].MakeVisible(False);
End;

Procedure TOVCLDebugView.DoMaxItemCutoff;
Begin
    If MaxItems = 0 Then
        Exit;

    While Items.Count > MaxItems Do
        Items.Delete(0);
End;

Function TOVCLDebugView.GetItemColor(Item: TListItem): TColor;
Var
    SubColor: TColor;
    Level: Integer;
Begin
    Result := clWhite;

    Level := StrToIntDef(Item.SubItems[1], -1);

    If Not Assigned(Item) Then
        Exit;

    SubColor := clBlack;
    If Item.SubItems[0] = 'ODS' Then
        SubColor := $001010
    Else If Item.SubItems[0] = 'OES' Then
        SubColor := $100010
    Else If Item.SubItems[0] = 'OXS' Then
    Begin
        SubColor := $100010;
        If Level = 10 Then
            SubColor := $101000;
    End;

    Result := clWhite - (Level + 2) * SubColor;
End;

Procedure TOVCLDebugView.HandleDebugStr(Sender: TObject; Level: Integer;
    Place: TODbgMapLocation; Desc: String; Var Handled: Boolean);
Begin
    //TODO -oMatze -cVCL, DebugView : Add a new Item for a debug string
    Items.BeginUpdate;
    Try
        //Neuen Eintrag hinzufügen
        With Items.Add Do
        Begin
            Caption := TimeToStr(Now);
            SubItems.Add('ODS');
            SubItems.Add(IntToStr(Level));
            SubItems.Add(IntToHex(Place.Address, 8));                           //Später nur die ersten 8 Byte
            SubItems.Add(Place.ModuleName);
            SubItems.Add(Place.UnitName);
            SubItems.Add(Place.UnitSource);

            If Place.UnitSourceLine = -1 Then
                SubItems.Add('-')
            Else
                SubItems.Add(IntToStr(Place.UnitSourceLine));

            SubItems.Add(Place.ProcName);
            SubItems.Add(Desc);
            SubItems.Add('-');
            SubItems.Add('-');
        End;

        DoMaxItemCutoff;
    Finally
        Items.EndUpdate;
    End;
    DoLiveScroll;
End;

Procedure TOVCLDebugView.HandleErrorStr(Sender: TObject; Level: Integer;
    Place: TODbgMapLocation; Desc: String; Var ErrorObj: Exception;
    Var Handled: Boolean);
Begin
    //TODO -oMatze -cVCL, DebugView : Add a new Item for an error string
    //TODO -oMatze -cVCL, DebugView : Handle Exception with (ErrorObj = nil) AND (Level = 10);
    Items.BeginUpdate;
    Try
        //Neuen Eintrag hinzufügen
        With Items.Add Do
        Begin
            Caption := TimeToStr(Now);
            If (ErrorObj = Nil) And (Level = vl_Exception) Then
                SubItems.Add('OXS')
            Else
                SubItems.Add('OES');
            SubItems.Add(IntToStr(Level));
            SubItems.Add(IntToHex(Place.Address, 8));                           //Später nur die ersten 8 Byte
            SubItems.Add(Place.ModuleName);
            SubItems.Add(Place.UnitName);
            SubItems.Add(Place.UnitSource);

            If (Place.UnitSourceLine = -1) Or (Place.UnitSourceLine = 0) Then
                SubItems.Add('-')
            Else
                SubItems.Add(IntToStr(Place.UnitSourceLine));

            SubItems.Add(Place.ProcName);
            SubItems.Add(Desc);
            If Assigned(ErrorObj) Then
            Begin
                SubItems.Add(ErrorObj.ClassName);
                SubItems.Add(ErrorObj.Message);
            End
            Else
            Begin
                SubItems.Add('-');
                SubItems.Add('-');
            End;
        End;

        DoMaxItemCutoff;
    Finally
        Items.EndUpdate;
    End;
    DoLiveScroll;
End;

Procedure TOVCLDebugView.OmCDI(Sender: TCustomListView; Item: TListItem;
    State: TCustomDrawState; Var DefaultDraw: Boolean);
Begin
    Sender.Canvas.Brush.Color := GetItemColor(Item);
    Sender.Canvas.FillRect(Item.DisplayRect(drLabel));
End;

Procedure TOVCLDebugView.SetLiveScrolling(Const Value: Boolean);
Begin
    FLiveScrolling := Value;
End;

Procedure TOVCLDebugView.SetMaxItems(Const Value: Integer);
Begin
    FMaxItems := Value;

    If FMaxItems < 0 Then
        FMaxItems := 0;

    If MaxItems = 0 Then
        Exit;

    DoLiveScroll;
End;

End.
