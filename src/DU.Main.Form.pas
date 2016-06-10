{ -------------------------------------------------------------------------------

  DBXtoUD
  Copyright (c) 2016 Alessandro Savoiardo - EcoSoft
  www.ecosoft.it

  ------------------------------------------------------------------------------- }

unit DU.Main.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, DU.Converter,
  Vcl.ExtCtrls, Vcl.FileCtrl;

const
  ProductVersion = '2016.1';

type
  TDUFormMain = class(TForm)
    PageControl1: TPageControl;
    tabPerform: TTabSheet;
    tabTest: TTabSheet;
    memLog: TMemo;
    pcTesting: TPageControl;
    tabCode: TTabSheet;
    tabDfm: TTabSheet;
    memCode: TMemo;
    memCodeConvert: TMemo;
    btnConvert: TButton;
    memDfm: TMemo;
    btnConvertDfm: TButton;
    memDfmConvert: TMemo;
    Panel1: TPanel;
    chkConvFMTBCD: TCheckBox;
    chkConvDate: TCheckBox;
    edtSource: TLabeledEdit;
    edtDestination: TLabeledEdit;
    Button1: TButton;
    btnOpenSource: TButton;
    btnOpenDestination: TButton;
    sbMain: TStatusBar;
    chkSetFieldReadOnly: TCheckBox;
    Panel2: TPanel;
    Label1: TLabel;
    procedure pcTestingResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnConvertDfmClick(Sender: TObject);
    procedure btnConvertClick(Sender: TObject);
    procedure btnOpenSourceClick(Sender: TObject);
    procedure btnOpenDestinationClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FConverter: TDUConverter;
    procedure CalcSizeMemo;
    procedure LoadSetting;
  public

  end;

var
  DUFormMain: TDUFormMain;

implementation

{$R *.dfm}

uses System.IniFiles, System.UITypes;

procedure TDUFormMain.FormCreate(Sender: TObject);
begin

  Caption := Caption + ' ' + ProductVersion;
  Application.Title := Caption;

  CalcSizeMemo;
  FConverter := TDUConverter.Create;
  FConverter.LogEvent := procedure(AValue: string)
    begin
      memLog.Lines.Add(AValue);
    end;
  with TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini')) do
  begin
    edtSource.Text := ReadString('SETTINGS', 'SOURCE', '');
    edtDestination.Text := ReadString('SETTINGS', 'DESTINATION', '');
  end;
  PageControl1.ActivePageIndex := 0;

end;

procedure TDUFormMain.FormDestroy(Sender: TObject);
begin
  FConverter.Free;
  with TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini')) do
  begin
    WriteString('SETTINGS', 'SOURCE', edtSource.Text);
    WriteString('SETTINGS', 'DESTINATION', edtDestination.Text);
  end;
end;

procedure TDUFormMain.pcTestingResize(Sender: TObject);
begin
  CalcSizeMemo;
end;

procedure TDUFormMain.btnConvertClick(Sender: TObject);
begin
  LoadSetting;
  FConverter.ConvertCode('Test', memCode.Lines, memCodeConvert.Lines);
end;

procedure TDUFormMain.btnConvertDfmClick(Sender: TObject);
begin
  LoadSetting;
  FConverter.ConvertDfm('Test', memDfm.Lines, memDfmConvert.Lines);
end;

procedure TDUFormMain.btnOpenDestinationClick(Sender: TObject);
var
  Res: string;
begin
  if SelectDirectory('Destination', edtDestination.Text, Res) then
    edtDestination.Text := Res;
end;

procedure TDUFormMain.btnOpenSourceClick(Sender: TObject);
var
  Res: string;
begin
  if SelectDirectory('Source', edtSource.Text, Res) then
    edtSource.Text := Res;

end;

procedure TDUFormMain.Button1Click(Sender: TObject);
begin
  if MessageDlg('Start conversion?', TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    LoadSetting;
    TThread.CreateAnonymousThread(
      procedure()
      var
        C: TDUConverter;
        sError, ASource, ADest: string;
      begin
        C := TDUConverter.Create;
        try
          try
            TThread.Synchronize(nil,
              procedure()
              begin
                C.ConvDate := chkConvDate.Checked;
                C.ConvFMTBCD := chkConvFMTBCD.Checked;
                C.ConvSetFieldReadOnly := chkSetFieldReadOnly.Checked;
                ASource := edtSource.Text;
                ADest := edtDestination.Text;
                C.LogEvent := procedure(AValue: string)
                  begin
                    TThread.Queue(nil,
                      procedure()
                      begin
                        memLog.Lines.Add(AValue);
                      end);
                  end;
              end);
            // Create directory for conversion
            ADest := IncludeTrailingPathDelimiter(ADest) +
              FormatDateTime('yyyy-mm-dd_hh_nn_ss', Now());
            CreateDir(ADest);
            C.ConvertProject(ASource, ADest);
            TThread.Synchronize(nil,
              procedure()
              begin
                MessageDlg('Terminate conversion.', TMsgDlgType.mtInformation,
                  [TMsgDlgBtn.mbOk], 0);
              end);
          except
            on e: exception do
            begin
              sError := e.Message;
              TThread.Synchronize(nil,
                procedure()
                begin
                  MessageDlg(sError, TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
                end);
            end;
          end;

        finally
          C.Free;
        end;
      end).Start;

  end;
end;

procedure TDUFormMain.CalcSizeMemo;
var
  mWidth, mHeigth: Integer;
begin
  mWidth := (pcTesting.Width - (memCode.Left * 5)) div 2;
  mHeigth := tabCode.Height - (memCode.Top * 4) - btnConvert.Height;
  memCode.Width := mWidth;
  memCode.Height := mHeigth;
  memCodeConvert.Left := memCode.Left * 2 + memCode.Width;
  memCodeConvert.Width := mWidth;
  memCodeConvert.Height := mHeigth;
  btnConvert.Top := mHeigth + (memCode.Top * 2);
  btnConvert.Left := (pcTesting.Width - btnConvert.Width) div 2;

  memDfm.Left := memCode.Left;
  memDfm.Width := memCode.Width;
  memDfm.Height := memCode.Height;
  memDfmConvert.Left := memCodeConvert.Left;
  memDfmConvert.Width := memCodeConvert.Width;
  memDfmConvert.Height := memCodeConvert.Height;
  btnConvertDfm.Top := btnConvert.Top;
  btnConvertDfm.Left := btnConvert.Left;
end;

procedure TDUFormMain.LoadSetting;
begin
  FConverter.ConvDate := chkConvDate.Checked;
  FConverter.ConvFMTBCD := chkConvFMTBCD.Checked;
  FConverter.ConvSetFieldReadOnly := chkSetFieldReadOnly.Checked;
end;

end.
