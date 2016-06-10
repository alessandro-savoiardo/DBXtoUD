object DUSDataSetData: TDUSDataSetData
  OldCreateOrder = False
  Height = 427
  Width = 779
  object SQLTable1: TSQLTable
    MaxBlobSize = -1
    SQLConnection = DUSMainData.SQLConnection1
    TableName = 'TEST'
    Left = 208
    Top = 132
  end
  object SQLDataSet1: TSQLDataSet
    CommandText = 'select *'#13#10'from TEST'
    MaxBlobSize = -1
    Params = <>
    SQLConnection = DUSMainData.SQLConnection1
    Left = 208
    Top = 80
  end
  object SQLQuery1: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQL.Strings = (
      'select * from TEST')
    SQLConnection = DUSMainData.SQLConnection1
    Left = 204
    Top = 200
  end
  object SimpleDataSet1: TSimpleDataSet
    Aggregates = <>
    DataSet.CommandText = 'select *'#13#10'from TEST'
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    Left = 204
    Top = 260
  end
  object DataSetProvider1: TDataSetProvider
    Left = 372
    Top = 196
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DataSetProvider1'
    Left = 476
    Top = 200
  end
end
