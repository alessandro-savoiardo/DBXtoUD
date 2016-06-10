unit DUS.DataSet.Data;

interface

uses
  System.SysUtils, System.Classes, Data.FMTBcd, Datasnap.DBClient,
  Datasnap.Provider, SimpleDS, Data.DB, Data.SqlExpr, Data.DbxSqlite;

type
  TDUSDataSetData = class(TDataModule)
    SQLTable1: TSQLTable;
    SQLDataSet1: TSQLDataSet;
    SQLQuery1: TSQLQuery;
    SimpleDataSet1: TSimpleDataSet;
    DataSetProvider1: TDataSetProvider;
    ClientDataSet1: TClientDataSet;
  private
    { Private declarations }
  public
    procedure Open(AIdx: integer);
  end;

var
  DUSDataSetData: TDUSDataSetData;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

uses DUS.Main.Data;

{$R *.dfm}
{ TDUSDataSetData }

procedure TDUSDataSetData.Open(AIdx: integer);
var
  dts: TDataSet;
begin
  ClientDataSet1.Close;
  dts := nil;
  case AIdx of
    0: // TSQLDataSet
      begin
        SQLTable1.GetMetadata := false;
        SQLDataSet1.CommandText := 'select * from TEST where ID > :ID';
        SQLDataSet1.ParamByName('ID').AsInteger := 1;
        dts := SQLDataSet1;
      end;
    1: // TSQLTable
      begin
        SQLTable1.GetMetadata := false;
        SQLTable1.TableName := 'TEST';
        dts := SQLTable1;
      end;
    2: // TSQLQuery
      begin
        SQLQuery1.GetMetadata := false;
        SQLQuery1.SQL.Text := 'select * from TEST  where ID > :ID';
        SQLQuery1.ParamByName('ID').AsInteger := 1;
        dts := SQLQuery1;
      end;
    3: // TSimpleDataSet
      begin
        SimpleDataSet1.DataSet.CommandText := 'select * from TEST';
        dts := SimpleDataSet1;
      end;
  end;
  DataSetProvider1.DataSet := dts;
  ClientDataSet1.Open;
end;

end.
