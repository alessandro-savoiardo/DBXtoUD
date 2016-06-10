object DUSMainForm: TDUSMainForm
  Left = 0
  Top = 0
  Caption = 'DUSMainForm'
  ClientHeight = 397
  ClientWidth = 693
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 8
    Top = 76
    Width = 669
    Height = 313
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object RadioGroup1: TRadioGroup
    Left = 8
    Top = 8
    Width = 657
    Height = 62
    Caption = 'Components'
    Columns = 5
    Items.Strings = (
      'TSQLDataSet'
      'TSQLTable'
      'TSQLQuery'
      'TSimpleDataset')
    TabOrder = 1
    OnClick = RadioGroup1Click
  end
  object DataSource1: TDataSource
    DataSet = DUSDataSetData.ClientDataSet1
    Left = 56
    Top = 136
  end
end
