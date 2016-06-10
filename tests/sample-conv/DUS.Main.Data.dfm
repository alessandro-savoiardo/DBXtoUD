object DUSMainData: TDUSMainData
  OldCreateOrder = False
  Height = 427
  Width = 779
  object SQLConnection1: TSQLConnection
    ConnectionName = 'MAINCONNECTION'
    DriverName = 'Sqlite'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DbxSqlite'
      
        'DriverPackageLoader=TDBXSqliteDriverLoader,DBXSqliteDriver230.bp' +
        'l'
      
        'MetaDataPackageLoader=TDBXSqliteMetaDataCommandFactory,DbxSqlite' +
        'Driver230.bpl'
      'FailIfMissing=True'
      'Database=')
    Left = 224
    Top = 96
  end
end
