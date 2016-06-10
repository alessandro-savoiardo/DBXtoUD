program DBXtoUD;

uses
  Vcl.Forms,
  DU.Main.Form in 'DU.Main.Form.pas' {DUFormMain},
  DU.Converter in 'DU.Converter.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDUFormMain, DUFormMain);
  Application.Run;
end.
