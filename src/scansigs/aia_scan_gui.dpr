program aia_scan_gui;

uses
  Forms,
  aia_sg_main in 'aia_sg_main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
