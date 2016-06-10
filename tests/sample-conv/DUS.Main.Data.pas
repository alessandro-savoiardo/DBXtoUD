unit DUS.Main.Data;

interface

uses
  System.SysUtils, System.Classes, Data.FMTBcd, Data.DB,
  Data.SqlExpr, Datasnap.DBClient, SimpleDS, Datasnap.Provider, Data.DbxSqlite;

type
  TDUSMainData = class(TDataModule)
    SQLConnection1: TSQLConnection;
  private
    procedure CreateTables;
  public
    procedure Open;
  end;

var
  DUSMainData: TDUSMainData;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}
{ TDUSMainData }

procedure TDUSMainData.CreateTables;
var
  dts: TSQLQuery;
begin
  dts := TSQLQuery.Create(nil);
  try
    dts.SQLConnection := SQLConnection1;
    dts.SQL.Clear;
    dts.SQL.Add('CREATE TABLE IF NOT EXISTS test(   ');
    dts.SQL.Add('id INTEGER PRIMARY KEY,  ');
    dts.SQL.Add('title VARCHAR(200),   ');
    dts.SQL.Add(' content MEDIUMTEXT,  ');
    dts.SQL.Add(' count DECIMAL(10,2),  ');
    dts.SQL.Add(' up_date DATETIME );');
    dts.ExecSQL();
    dts.SQL.Clear;
    dts.SQL.Add('INSERT OR REPLACE INTO test VALUES (1, ''test'', ''test'', 10.2, ''2016-01-01'') ');
    dts.ExecSQL();
  finally
    dts.Free;
  end;
end;

procedure TDUSMainData.Open;
var
  dbFile: string;
begin
  dbFile := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'test.db';
  SQLConnection1.Params.Values['Database'] := dbFile;
  if not FileExists(dbFile) then
  begin
    SQLConnection1.Params.Values['FailIfMissing'] := 'False';
  end;
  SQLConnection1.Open;
  CreateTables;
end;

end.
