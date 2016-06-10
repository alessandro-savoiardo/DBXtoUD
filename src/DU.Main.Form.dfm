object DUFormMain: TDUFormMain
  Left = 0
  Top = 0
  Caption = 'DBX to UD'
  ClientHeight = 492
  ClientWidth = 686
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 41
    Width = 686
    Height = 350
    ActivePage = tabTest
    Align = alClient
    TabOrder = 0
    object tabPerform: TTabSheet
      Caption = 'Perform'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object edtSource: TLabeledEdit
        Left = 3
        Top = 24
        Width = 598
        Height = 23
        EditLabel.Width = 36
        EditLabel.Height = 15
        EditLabel.Caption = 'Source'
        TabOrder = 0
      end
      object edtDestination: TLabeledEdit
        Left = 3
        Top = 68
        Width = 598
        Height = 23
        EditLabel.Width = 60
        EditLabel.Height = 15
        EditLabel.Caption = 'Destination'
        TabOrder = 1
      end
      object Button1: TButton
        Left = 570
        Top = 104
        Width = 75
        Height = 25
        Caption = 'Convert'
        TabOrder = 2
        OnClick = Button1Click
      end
      object btnOpenSource: TButton
        Left = 612
        Top = 23
        Width = 29
        Height = 25
        Caption = '...'
        TabOrder = 3
        OnClick = btnOpenSourceClick
      end
      object btnOpenDestination: TButton
        Left = 612
        Top = 67
        Width = 29
        Height = 25
        Caption = '...'
        TabOrder = 4
        OnClick = btnOpenDestinationClick
      end
    end
    object tabTest: TTabSheet
      Caption = 'Testing'
      ImageIndex = 1
      object pcTesting: TPageControl
        Left = 0
        Top = 0
        Width = 678
        Height = 295
        ActivePage = tabCode
        Align = alClient
        TabOrder = 0
        OnResize = pcTestingResize
        object tabCode: TTabSheet
          Caption = 'Code'
          DesignSize = (
            670
            265)
          object memCode: TMemo
            Left = 3
            Top = 3
            Width = 390
            Height = 254
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            Lines.Strings = (
              'unit DUS.DataSet.Data;'
              ''
              'interface'
              ''
              'uses'
              
                '  System.SysUtils, System.Classes, Data.FMTBcd, Datasnap.DBClien' +
                't,'
              
                '  Datasnap.Provider, SimpleDS, Data.DB, Data.SqlExpr, Data.DbxSq' +
                'lite;'
              ''
              'type'
              '  TDUSDataSetData = class(TDataModule)'
              '    SQLTable1: TSQLTable;'
              '    SQLDataSet1: TSQLDataSet;'
              '    SQLQuery1: TSQLQuery;'
              '    SimpleDataSet1: TSimpleDataSet;'
              '    DataSetProvider1: TDataSetProvider;'
              '    ClientDataSet1: TClientDataSet;'
              '  private'
              '    { Private declarations }'
              '  public'
              '    procedure Open(AIdx: integer);'
              '  end;'
              ''
              'var'
              '  DUSDataSetData: TDUSDataSetData;'
              ''
              'implementation'
              ''
              '{ %CLASSGROUP '#39'Vcl.Controls.TControl'#39' }'
              ''
              'uses DUS.Main.Data;'
              ''
              '{$R *.dfm}'
              '{ TDUSDataSetData }'
              ''
              'procedure TDUSDataSetData.Open(AIdx: integer);'
              'var'
              '  dts: TDataSet;'
              'begin'
              '  ClientDataSet1.Close;'
              '  dts := nil;'
              '  case AIdx of'
              '    0: // TSQLDataSet'
              '      begin'
              '        SQLTable1.GetMetadata := false;'
              
                '        SQLDataSet1.CommandText := '#39'select * from TEST where ID ' +
                '> :ID'#39';'
              '        SQLDataSet1.ParamByName('#39'ID'#39').AsInteger := 1;'
              '        dts := SQLDataSet1;'
              '      end;'
              '    1: // TSQLTable'
              '      begin'
              '        SQLTable1.GetMetadata := false;'
              '        SQLTable1.TableName := '#39'TEST'#39';'
              '        dts := SQLTable1;'
              '      end;'
              '    2: // TSQLQuery'
              '      begin'
              '        SQLQuery1.GetMetadata := false;'
              
                '        SQLQuery1.SQL.Text := '#39'select * from TEST  where ID > :I' +
                'D'#39';'
              '        SQLQuery1.ParamByName('#39'ID'#39').AsInteger := 1;'
              '        dts := SQLQuery1;'
              '      end;'
              '    3: // TSimpleDataSet'
              '      begin'
              
                '        SimpleDataSet1.DataSet.CommandText := '#39'select * from TES' +
                'T'#39';'
              '        dts := SimpleDataSet1;'
              '      end;'
              '  end;'
              '  DataSetProvider1.DataSet := dts;'
              '  ClientDataSet1.Open;'
              'end;'
              ''
              'end.')
            ParentFont = False
            ScrollBars = ssVertical
            TabOrder = 0
            WordWrap = False
          end
          object memCodeConvert: TMemo
            Left = 408
            Top = 3
            Width = 390
            Height = 254
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            ScrollBars = ssVertical
            TabOrder = 1
            WordWrap = False
          end
          object btnConvert: TButton
            Left = 225
            Top = 233
            Width = 86
            Height = 32
            Anchors = [akRight]
            Caption = 'Convert  -->>'
            TabOrder = 2
            OnClick = btnConvertClick
          end
        end
        object tabDfm: TTabSheet
          Caption = 'Dfm'
          ImageIndex = 1
          DesignSize = (
            670
            265)
          object memDfm: TMemo
            Left = 3
            Top = 3
            Width = 256
            Height = 217
            Anchors = [akLeft, akTop, akRight, akBottom]
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            Lines.Strings = (
              'object DUSDataSetData: TDUSDataSetData'
              '  OldCreateOrder = False'
              '  Height = 427'
              '  Width = 779'
              '  object SQLTable1: TSQLTable'
              '    MaxBlobSize = -1'
              '    SQLConnection = DUSMainData.SQLConnection1'
              '    TableName = '#39'TEST'#39
              '    Left = 208'
              '    Top = 132'
              '  end'
              '  object SQLDataSet1: TSQLDataSet'
              '    CommandText = '#39'select *'#39'#13#10'#39'from TEST'#39
              '    MaxBlobSize = -1'
              '    Params = <>'
              '    SQLConnection = DUSMainData.SQLConnection1'
              '    Left = 208'
              '    Top = 80'
              '  end'
              '  object SQLQuery1: TSQLQuery'
              '    MaxBlobSize = -1'
              '    Params = <>'
              '    SQL.Strings = ('
              '      '#39'select * from TEST'#39')'
              '    SQLConnection = DUSMainData.SQLConnection1'
              '    Left = 204'
              '    Top = 200'
              '  end'
              '  object SimpleDataSet1: TSimpleDataSet'
              '    Aggregates = <>'
              '    DataSet.CommandText = '#39'select *'#39'#13#10'#39'from TEST'#39
              '    DataSet.MaxBlobSize = -1'
              '    DataSet.Params = <>'
              '    Params = <>'
              '    Left = 204'
              '    Top = 260'
              '  end'
              '  object DataSetProvider1: TDataSetProvider'
              '    Left = 372'
              '    Top = 196'
              '  end'
              '  object ClientDataSet1: TClientDataSet'
              '    Aggregates = <>'
              '    Params = <>'
              '    ProviderName = '#39'DataSetProvider1'#39
              '    Left = 476'
              '    Top = 200'
              '  end'
              'end')
            ParentFont = False
            ScrollBars = ssVertical
            TabOrder = 0
            WordWrap = False
          end
          object btnConvertDfm: TButton
            Left = 225
            Top = 232
            Width = 86
            Height = 32
            Anchors = [akRight]
            Caption = 'Convert  -->>'
            TabOrder = 1
            OnClick = btnConvertDfmClick
          end
          object memDfmConvert: TMemo
            Left = 274
            Top = 3
            Width = 390
            Height = 217
            Anchors = [akTop, akRight, akBottom]
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            ScrollBars = ssVertical
            TabOrder = 2
            WordWrap = False
          end
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 295
        Width = 678
        Height = 25
        Align = alBottom
        TabOrder = 1
        object Label1: TLabel
          Left = 7
          Top = 4
          Width = 598
          Height = 15
          Caption = 
            'Copy your code into clipboard and paste code in left memo and pr' +
            'ess "Convert" for testing or manual conversion'
        end
      end
    end
  end
  object memLog: TMemo
    Left = 0
    Top = 391
    Width = 686
    Height = 82
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 686
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    object chkConvFMTBCD: TCheckBox
      Left = 264
      Top = 13
      Width = 197
      Height = 17
      Caption = 'TFMTBCDField -> TFloatField'
      TabOrder = 0
    end
    object chkConvDate: TCheckBox
      Left = 7
      Top = 13
      Width = 245
      Height = 17
      Caption = 'TSQLTimeStampField -> TDateTimeField'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object chkSetFieldReadOnly: TCheckBox
      Left = 460
      Top = 13
      Width = 209
      Height = 17
      Caption = 'Options.SetFieldsReadOnly = False'
      TabOrder = 2
    end
  end
  object sbMain: TStatusBar
    Left = 0
    Top = 473
    Width = 686
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Copyright (c) 2016 Alessandro Savoiardo - EcoSoft'
  end
end
