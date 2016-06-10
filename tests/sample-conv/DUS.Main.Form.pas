unit DUS.Main.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids;

type
  TDUSMainForm = class(TForm)
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    RadioGroup1: TRadioGroup;
    procedure RadioGroup1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DUSMainForm: TDUSMainForm;

implementation

{$R *.dfm}

uses DUS.Main.Data, DUS.DataSet.Data;

procedure TDUSMainForm.FormCreate(Sender: TObject);
begin
  DUSMainData := TDUSMainData.Create(Self);
  DUSMainData.Open;
  DUSDatasetData := TDUSDataSetData.Create(Self);
end;

procedure TDUSMainForm.RadioGroup1Click(Sender: TObject);
begin
  DUSDatasetData.Open(RadioGroup1.ItemIndex);
end;

end.
