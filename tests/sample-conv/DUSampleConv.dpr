program DUSampleConv;

uses
  Vcl.Forms,
  DUS.Main.Form in 'DUS.Main.Form.pas' {DUSMainForm},
  DUS.DataSet.Data in 'DUS.DataSet.Data.pas' {DUSDataSetData: TDataModule},
  DUS.Main.Data in 'DUS.Main.Data.pas' {DUSMainData: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDUSMainForm, DUSMainForm);
  Application.Run;
end.
