{ -------------------------------------------------------------------------------

  DBXtoUD
  Copyright (c) 2016 Alessandro Savoiardo - EcoSoft
  www.ecosoft.it

  ------------------------------------------------------------------------------- }

unit DU.Converter;

interface

uses System.SysUtils, System.Classes;

type

  TDUConverter = class
  private const
    sComment = '// DBXtoUD ';
  private
    FLogEvent: TProc<string>;
    FConvDate: boolean;
    FConvFMTBCD: boolean;
    FConvSetFieldReadOnly: boolean;
    procedure WriteLog(AValue: string);
    procedure WriteLogFmt(AValue: string; Args: array of const);
  public
    procedure ConvertCode(const AName: string; ACode, ARes: TStrings);
    procedure ConvertDfm(const AName: string; ACode, ARes: TStrings);
    property LogEvent: TProc<string> read FLogEvent write FLogEvent;
    property ConvDate: boolean read FConvDate write FConvDate;
    property ConvFMTBCD: boolean read FConvFMTBCD write FConvFMTBCD;
    property ConvSetFieldReadOnly: boolean read FConvSetFieldReadOnly write FConvSetFieldReadOnly;
    procedure ConvertProject(ASource, ADest: string);
  end;

implementation

uses StrUtils, Generics.Collections, System.IOUtils, System.Types;

procedure TDUConverter.WriteLog(AValue: string);
begin
  if Assigned(FLogEvent) then
  begin
    FLogEvent(AValue);
  end;
end;

procedure TDUConverter.WriteLogFmt(AValue: string; Args: array of const);
begin
  WriteLog(Format(AValue, Args));
end;

procedure TDUConverter.ConvertCode(const AName: string; ACode, ARes: TStrings);
var
  sLine, sTmp: string;
  Idx: integer;
  DtsList: TStringList;
  IsImplementation: boolean;

  function ConvertDataType: boolean;
  begin
    Result := false;
    if ((FConvDate) and (Pos(LowerCase('TSQLTimeStampField'), sLine) > 0)) then
    begin
      Result := true;
      WriteLogFmt('%d TSQLTimeStampField', [Idx]);
      ARes.Add(StringReplace(ACode[Idx], 'TSQLTimeStampField', 'TDateTimeField',
        [rfReplaceAll, rfIgnoreCase]));
    end
    else if ((FConvDate) and (Pos(LowerCase('.AsSQLTimeStamp'), sLine) > 0)) then
    begin
      Result := true;
      WriteLogFmt('%d AsSQLTimeStamp', [Idx]);
      ARes.Add(StringReplace(StringReplace(ACode[Idx], '.AsSQLTimeStamp', '.AsDateTime',
        [rfReplaceAll, rfIgnoreCase]), 'DateTimeToSQLTimeStamp', '', [rfReplaceAll, rfIgnoreCase]));
    end
    else if ((FConvDate) and (Pos(LowerCase('DateTimeToSQLTimeStamp'), sLine) > 0)) then
    begin
      Result := true;
      WriteLogFmt('%d DateTimeToSQLTimeStamp', [Idx]);
      ARes.Add(StringReplace(ACode[Idx], 'DateTimeToSQLTimeStamp', '',
        [rfReplaceAll, rfIgnoreCase]));
    end
    else if ((FConvFMTBCD) and (Pos(LowerCase('TFMTBCDField'), sLine) > 0)) then
    begin
      Result := true;
      WriteLogFmt('%d TFMTBCDField', [Idx]);
      ARes.Add(StringReplace(ACode[Idx], 'TFMTBCDField', 'TFloatField',
        [rfReplaceAll, rfIgnoreCase]));
    end
  end;

  function AddDts: string;
  var
    p: integer;
    Tmp: string;
  begin
    Result := '';
    Tmp := ACode[Idx];
    p := Pos(':', Tmp);
    if p > 0 then
    begin
      Tmp := Trim(Copy(Tmp, 1, p - 1));
      p := Length(Tmp);
      while (p > 0) and (Tmp[p] <> ' ') and (Tmp[p] <> ',') and (Tmp[p] <> ';') do
      begin
        Result := Tmp[p] + Result;
        Dec(p);
      end;
    end;
    if Result <> '' then
      DtsList.Add(Result);
  end;

  function GetSpaceIdent: string;
  var
    c: char;
  begin
    Result := '';
    for c in ACode[Idx] do
    begin
      if c = ' ' then
        Result := Result + ' '
      else
      begin
        Result := Result;
        Break;
      end;
    end;
  end;

  function ListConvert: boolean;
  var
    s: string;
  begin
    Result := false;
    if IsImplementation then
    begin
      for s in DtsList.ToStringArray do
      begin
        // TSQLDataSet
        if Pos(LowerCase(s + '.SQLConnection'), sLine) > 0 then
        begin
          Result := true;
          ARes.Add(StringReplace(ACode[Idx], s + '.SQLConnection', s + '.Connection',
            [rfReplaceAll, rfIgnoreCase]));
        end
        else if Pos(LowerCase(s + '.CommandText'), sLine) > 0 then
        begin
          Result := true;
          ARes.Add(StringReplace(ACode[Idx], s + '.CommandText', s + '.SQL.Text',
            [rfReplaceAll, rfIgnoreCase]));
        end
        else if Pos(LowerCase(s + '.GetMetaData'), sLine) > 0 then
        begin
          Result := true;
          ARes.Add(TDUConverter.sComment + ' ' + ACode[Idx]);
        end
        else if Pos(LowerCase(s + '.CommandType'), sLine) > 0 then
        begin
          Result := true;
          ARes.Add(TDUConverter.sComment + ' ' + ACode[Idx]);
        end
        // TSimpleDataSet
        else if Pos(LowerCase(s + '.DataSet.SQLConnection'), sLine) > 0 then
        begin
          Result := true;
          ARes.Add(StringReplace(ACode[Idx], s + '.DataSet.SQLConnection', s + '.Connection',
            [rfReplaceAll, rfIgnoreCase]));
        end
        else if Pos(LowerCase(s + '.DataSet.CommandText'), sLine) > 0 then
        begin
          Result := true;
          ARes.Add(StringReplace(ACode[Idx], s + '.DataSet.CommandText', s + '.SQL.Text',
            [rfReplaceAll, rfIgnoreCase]));
        end
        else if Pos(LowerCase(s + '.DataSet.GetMetaData'), sLine) > 0 then
        begin
          Result := true;
          ARes.Add(TDUConverter.sComment + ' ' + ACode[Idx]);
        end
        else if Pos(LowerCase(s + '.DataSet.CommandType'), sLine) > 0 then
        begin
          Result := true;
          ARes.Add(TDUConverter.sComment + ' ' + ACode[Idx]);
        end;
        // I exit when I found the value to be converted
        if Result then
          Break;
        // Please note: It happened that ds and SQLds was duplicated, in this case exit
      end;
    end;
  end;

begin
  Idx := 0;
  ARes.Clear;
  ARes.BeginUpdate;
  DtsList := TStringList.Create;
  try
    DtsList.Sorted := true;
    DtsList.Duplicates := TDuplicates.dupIgnore;
    IsImplementation := false;
    while Idx < ACode.Count do
    begin
      sLine := LowerCase(Trim(ACode[Idx]));
      if Pos('implementation', sLine) > 0 then
      begin
        IsImplementation := true;
      end;
      if (Copy(sLine, 1, 5) = 'uses') then
      begin
        Dec(Idx);
        repeat
          Inc(Idx);
          sTmp := ACode[Idx];
          sTmp := StringReplace(sTmp, 'Data.SqlExpr', 'MemDS, DBAccess, Uni',
            [rfReplaceAll, rfIgnoreCase]);
          sTmp := StringReplace(sTmp, 'SqlExpr', 'MemDS, DBAccess, Uni',
            [rfReplaceAll, rfIgnoreCase]);
          sTmp := StringReplace(sTmp, 'Data.DBXCommon,', '', [rfReplaceAll, rfIgnoreCase]);
          sTmp := StringReplace(sTmp, 'DBXCommon,', '', [rfReplaceAll, rfIgnoreCase]);
          sTmp := StringReplace(sTmp, 'Data.DBXCommon', '', [rfReplaceAll, rfIgnoreCase]);
          sTmp := StringReplace(sTmp, 'DBXCommon', '', [rfReplaceAll, rfIgnoreCase]);
          sTmp := StringReplace(sTmp, 'SimpleDS,', '', [rfReplaceAll, rfIgnoreCase]); // Fix virgola
          sTmp := StringReplace(sTmp, 'SimpleDS', '', [rfReplaceAll, rfIgnoreCase]);
          if (FConvDate) then
          begin
            sTmp := StringReplace(sTmp, 'Data.SqlTimSt,', '', [rfReplaceAll, rfIgnoreCase]);
            sTmp := StringReplace(sTmp, 'SqlTimSt,', '', [rfReplaceAll, rfIgnoreCase]);
            sTmp := StringReplace(sTmp, 'Data.SqlTimSt', '', [rfReplaceAll, rfIgnoreCase]);
            sTmp := StringReplace(sTmp, 'SqlTimSt', '', [rfReplaceAll, rfIgnoreCase]);
          end;
          if (FConvFMTBCD) then
          begin
            sTmp := StringReplace(sTmp, 'Data.FMTBcd,', '', [rfReplaceAll, rfIgnoreCase]);
            sTmp := StringReplace(sTmp, 'FMTBcd,', '', [rfReplaceAll, rfIgnoreCase]);
            sTmp := StringReplace(sTmp, 'Data.FMTBcd', '', [rfReplaceAll, rfIgnoreCase]);
            sTmp := StringReplace(sTmp, 'FMTBcd', '', [rfReplaceAll, rfIgnoreCase]);
          end;
          ARes.Add(sTmp);
        until Pos(';', ACode[Idx]) > 0;
      end
      else if ConvertDataType then
      begin
      end
      else if (Pos('tsqlconnection', sLine) > 0) then
      begin
        WriteLogFmt('%d TSQLConnection', [Idx]);
        ARes.Add(StringReplace(ACode[Idx], 'TSQLConnection', 'TUniConnection',
          [rfReplaceAll, rfIgnoreCase]));
      end
      else if (Pos('tsqldataset', sLine) > 0) then
      begin
        WriteLogFmt('%d TSQLDataSet', [Idx]);
        ARes.Add(StringReplace(ACode[Idx], 'TSQLDataSet', 'TUniQuery',
          [rfReplaceAll, rfIgnoreCase]));
        sTmp := AddDts;
        if (IsImplementation) and (sTmp <> '') then
        begin
          if Pos('.create', sLine) > 0 then
          begin
            ARes.Add(Format('%s%s.UniDirectional := True; ' + TDUConverter.sComment,
              [GetSpaceIdent(), sTmp]));
            if FConvSetFieldReadOnly then
              ARes.Add(Format('%s%s.Options.SetFieldsReadOnly := False; ' + TDUConverter.sComment,
                [GetSpaceIdent(), sTmp]));
          end;
        end;
      end
      else if (Pos('tsqltable', sLine) > 0) then
      begin
        WriteLogFmt('%d TSQLTable', [Idx]);
        ARes.Add(StringReplace(ACode[Idx], 'TSQLTable', 'TUniTable', [rfReplaceAll, rfIgnoreCase]));
        sTmp := AddDts;
        if (IsImplementation) and (sTmp <> '') then
        begin
          if Pos('.create', sLine) > 0 then
          begin
            ARes.Add(Format('%s%s.UniDirectional := True; ' + TDUConverter.sComment,
              [GetSpaceIdent(), sTmp]));
            if FConvSetFieldReadOnly then
              ARes.Add(Format('%s%s.Options.SetFieldsReadOnly := False; ' + TDUConverter.sComment,
                [GetSpaceIdent(), sTmp]));
          end;
        end;
      end
      else if (Pos('tsqlquery', sLine) > 0) then
      begin
        WriteLogFmt('%d TSQLQuery', [Idx]);
        ARes.Add(StringReplace(ACode[Idx], 'TSQLQuery', 'TUniQuery', [rfReplaceAll, rfIgnoreCase]));
        sTmp := AddDts;
        if (IsImplementation) and (sTmp <> '') then
        begin
          if Pos('.create', sLine) > 0 then
          begin
            ARes.Add(Format('%s%s.UniDirectional := True; ' + TDUConverter.sComment,
              [GetSpaceIdent(), sTmp]));
            if FConvSetFieldReadOnly then
              ARes.Add(Format('%s%s.Options.SetFieldsReadOnly := False; ' + TDUConverter.sComment,
                [GetSpaceIdent(), sTmp]));
          end;
        end;
      end
      else if (Pos('tsimpledataset', sLine) > 0) then
      begin
        WriteLogFmt('%d TSimpleDataSet', [Idx]);
        ARes.Add(StringReplace(ACode[Idx], 'TSimpleDataSet', 'TUniQuery',
          [rfReplaceAll, rfIgnoreCase]));
        sTmp := AddDts;
        if (IsImplementation) and (sTmp <> '') then
        begin
          if Pos('.create', sLine) > 0 then
          begin
            ARes.Add(Format('%s%s.CachedUpdates := True; ' + TDUConverter.sComment,
              [GetSpaceIdent(), sTmp]));
            if FConvSetFieldReadOnly then
              ARes.Add(Format('%s%s.Options.SetFieldsReadOnly := False; ' + TDUConverter.sComment,
                [GetSpaceIdent(), sTmp]));
          end;
        end;
      end
      else if ListConvert then
      begin
        // skip
      end
      else
        ARes.Add(ACode[Idx]);
      Inc(Idx);
    end;
  finally
    ARes.EndUpdate;
  end;
end;

procedure TDUConverter.ConvertDfm(const AName: string; ACode, ARes: TStrings);
var
  Idx: integer;
  space, spaceprop, tmpprop: string;
  TmpList: TStringList;

  function GetSpaceIdent: string;
  var
    c: char;
  begin
    Result := '';
    for c in ACode[Idx] do
    begin
      if c = ' ' then
        Result := Result + ' '
      else
      begin
        Result := Result;
        Break;
      end;
    end;
  end;

  function ConvertDataType: boolean;
  begin
    Result := false;
    if ((FConvDate) and (Pos('TSQLTimeStampField', ACode[Idx]) > 0)) then
    begin
      Result := true;
      WriteLogFmt('%d TSQLTimeStampField', [Idx]);
      ARes.Add(StringReplace(ACode[Idx], 'TSQLTimeStampField', 'TDateTimeField',
        [rfReplaceAll, rfIgnoreCase]));
    end
    else if ((FConvFMTBCD) and (Pos('TFMTBCDField', ACode[Idx]) > 0)) then
    begin
      Result := true;
      WriteLogFmt('%d TFMTBCDField', [Idx]);
      ARes.Add(StringReplace(ACode[Idx], 'TFMTBCDField', 'TFloatField',
        [rfReplaceAll, rfIgnoreCase]));
    end
  end;

begin
  Idx := 0;
  ARes.BeginUpdate;
  ARes.Clear;
  while Idx < ACode.Count do
  begin
    if (Pos(' TSQLConnection', ACode[Idx]) > 0) then
    begin
      WriteLogFmt('%d TSQLConnection', [Idx]);
      ARes.Add(StringReplace(ACode[Idx], 'TSQLConnection', 'TUniConnection',
        [rfReplaceAll, rfIgnoreCase]));
    end
    else if (Pos(' TSQLDataSet', ACode[Idx]) > 0) then
    begin
      WriteLogFmt('%d TSQLDataSet', [Idx]);
      space := GetSpaceIdent;
      spaceprop := space + '  ';
      ARes.Add(StringReplace(ACode[Idx], 'TSQLDataSet', 'TUniQuery', [rfReplaceAll, rfIgnoreCase]));
      ARes.Add(spaceprop + 'UniDirectional = True');
      if FConvSetFieldReadOnly then
        ARes.Add(spaceprop + 'Options.SetFieldsReadOnly = False');
      Inc(Idx);
      while (not SameText(ACode[Idx], space + 'end')) and (Idx < ACode.Count) do
      begin
        if ((StartsText(spaceprop + 'SchemaName', ACode[Idx])) or
          (StartsText(spaceprop + 'SchemaName', ACode[Idx])) or
          (StartsText(spaceprop + 'GetMetadata', ACode[Idx])) or
          (StartsText(spaceprop + 'DbxCommandType', ACode[Idx])) or
          (StartsText(spaceprop + 'MaxBlobSize', ACode[Idx]))) then
        begin
          // skip
        end
        else if (StartsText(spaceprop + 'SQLConnection', ACode[Idx])) then
        begin
          ARes.Add(spaceprop + 'Connection' + Copy(ACode[Idx], Length(spaceprop + 'SQLConnection') +
            1, Maxint));
        end
        else if (StartsText(spaceprop + 'CommandText', ACode[Idx])) then
        begin
          TmpList := TStringList.Create;
          try
            tmpprop := Copy(ACode[Idx], Length(spaceprop + 'CommandText = ') + 1, Maxint);
            if tmpprop <> '' then
              TmpList.Add(tmpprop);

            while (Copy(ACode[Idx], Length(ACode[Idx]), 1) <> '''') and (Idx < ACode.Count) do
            begin
              Inc(Idx);
              TmpList.Add(ACode[Idx]);
            end;

            if TmpList.Count > 0 then
            begin
              ARes.Add(spaceprop + 'SQL.Strings = (');
              TmpList[TmpList.Count - 1] := TmpList[TmpList.Count - 1] + ')';
              ARes.AddStrings(TmpList);
            end;
          finally
            TmpList.Free;
          end;
        end
        else if ConvertDataType then
        begin
          // skip
        end
        else
          ARes.Add(ACode[Idx]);
        Inc(Idx);
      end;
      ARes.Add(ACode[Idx]);
    end
    else if (Pos(' TSQLTable', ACode[Idx]) > 0) then
    begin
      WriteLogFmt('%d TSQLTable', [Idx]);
      space := GetSpaceIdent;
      spaceprop := space + '  ';
      ARes.Add(StringReplace(ACode[Idx], 'TSQLTable', 'TUniTable', [rfReplaceAll, rfIgnoreCase]));
      ARes.Add(spaceprop + 'UniDirectional = True');
      if FConvSetFieldReadOnly then
        ARes.Add(spaceprop + 'Options.SetFieldsReadOnly = False');
      Inc(Idx);
      while (not SameText(ACode[Idx], space + 'end')) and (Idx < ACode.Count) do
      begin
        if ((StartsText(spaceprop + 'SchemaName', ACode[Idx])) or
          (StartsText(spaceprop + 'SchemaName', ACode[Idx])) or
          (StartsText(spaceprop + 'GetMetadata', ACode[Idx])) or
          (StartsText(spaceprop + 'DbxCommandType', ACode[Idx])) or
          (StartsText(spaceprop + 'MaxBlobSize', ACode[Idx]))) then
        begin
          // skip
        end
        else if (StartsText(spaceprop + 'SQLConnection', ACode[Idx])) then
        begin
          ARes.Add(spaceprop + 'Connection' + Copy(ACode[Idx], Length(spaceprop + 'SQLConnection') +
            1, Maxint));
        end
        else if ConvertDataType then
        begin
          // skip
        end
        else
          ARes.Add(ACode[Idx]);
        Inc(Idx);
      end;
      ARes.Add(ACode[Idx]);
    end
    else if (Pos(' TSQLQuery', ACode[Idx]) > 0) then
    begin
      WriteLogFmt('%d TSQLQuery', [Idx]);
      space := GetSpaceIdent;
      spaceprop := space + '  ';
      ARes.Add(StringReplace(ACode[Idx], 'TSQLQuery', 'TUniQuery', [rfReplaceAll, rfIgnoreCase]));
      ARes.Add(spaceprop + 'UniDirectional = True');
      if FConvSetFieldReadOnly then
        ARes.Add(spaceprop + 'Options.SetFieldsReadOnly = False');
      Inc(Idx);
      while (not SameText(ACode[Idx], space + 'end')) and (Idx < ACode.Count) do
      begin
        if ((StartsText(spaceprop + 'SchemaName', ACode[Idx])) or
          (StartsText(spaceprop + 'SchemaName', ACode[Idx])) or
          (StartsText(spaceprop + 'GetMetadata', ACode[Idx])) or
          (StartsText(spaceprop + 'DbxCommandType', ACode[Idx])) or
          (StartsText(spaceprop + 'MaxBlobSize', ACode[Idx]))) then
        begin
          // skip
        end
        else if (StartsText(spaceprop + 'SQLConnection', ACode[Idx])) then
        begin
          ARes.Add(spaceprop + 'Connection' + Copy(ACode[Idx], Length(spaceprop + 'SQLConnection') +
            1, Maxint));
        end
        else if ConvertDataType then
        begin
          // skip
        end
        else
          ARes.Add(ACode[Idx]);
        Inc(Idx);
      end;
      ARes.Add(ACode[Idx]);
    end
    else if (Pos(' TSimpleDataSet', ACode[Idx]) > 0) then
    begin
      WriteLogFmt('%d TSimpleDataSet', [Idx]);
      space := GetSpaceIdent;
      spaceprop := space + '  ';
      ARes.Add(StringReplace(ACode[Idx], 'TSimpleDataSet', 'TUniQuery',
        [rfReplaceAll, rfIgnoreCase]));
      ARes.Add(spaceprop + 'CachedUpdates = True');
      if FConvSetFieldReadOnly then
        ARes.Add(spaceprop + 'Options.SetFieldsReadOnly = False');
      Inc(Idx);
      while (not SameText(ACode[Idx], space + 'end')) and (Idx < ACode.Count) do
      begin
        if ((StartsText(spaceprop + 'Aggregates', ACode[Idx])) or
          (StartsText(spaceprop + 'DataSet.Params', ACode[Idx])) or
          (StartsText(spaceprop + 'DataSet.SchemaName', ACode[Idx])) or
          (StartsText(spaceprop + 'DataSet.GetMetadata', ACode[Idx])) or
          (StartsText(spaceprop + 'DataSet.DbxCommandType', ACode[Idx])) or
          (StartsText(spaceprop + 'DataSet.MaxBlobSize', ACode[Idx]))) then
        begin
          // skip
        end
        else if (StartsText(spaceprop + 'DataSet.SQLConnection', ACode[Idx])) then
        begin
          ARes.Add(spaceprop + 'Connection' + Copy(ACode[Idx],
            Length(spaceprop + 'DataSet.SQLConnection') + 1, Maxint));
        end
        else if (StartsText(spaceprop + 'DataSet.CommandText', ACode[Idx])) then
        begin
          TmpList := TStringList.Create;
          try
            tmpprop := Copy(ACode[Idx], Length(spaceprop + 'DataSet.CommandText = ') + 1, Maxint);
            if tmpprop <> '' then
              TmpList.Add(tmpprop);

            while (Copy(ACode[Idx], Length(ACode[Idx]), 1) <> '''') and (Idx < ACode.Count) do
            begin
              Inc(Idx);
              TmpList.Add(ACode[Idx]);
            end;

            if TmpList.Count > 0 then
            begin
              ARes.Add(spaceprop + 'SQL.Strings = (');
              TmpList[TmpList.Count - 1] := TmpList[TmpList.Count - 1] + ')';
              ARes.AddStrings(TmpList);
            end;
          finally
            TmpList.Free;
          end;
        end
        else if ConvertDataType then
        begin
          // skip
        end
        else
          ARes.Add(ACode[Idx]);
        Inc(Idx);
      end;
      ARes.Add(ACode[Idx]);
    end
    else if ConvertDataType then
    begin
      // I must convert all field for compatibility
      // skip
    end
    else
      ARes.Add(ACode[Idx]);

    Inc(Idx);
  end;
  ARes.EndUpdate;
end;

procedure TDUConverter.ConvertProject(ASource, ADest: string);
var
  sFileName, sName: string;
  lRead, lWrite: TStringList;
  DfmRead, DfmConvert: TMemoryStream;
begin
  lRead := TStringList.Create;
  lWrite := TStringList.Create;
  DfmRead := TMemoryStream.Create;
  DfmConvert := TMemoryStream.Create;
  try
    if not TDirectory.Exists(ASource) then
      raise Exception.Create('Source not found');
    if not TDirectory.Exists(ADest) then
      raise Exception.Create('Destination not found');

    for sFileName in TDirectory.GetDirectories(ASource) do
    begin
      if not SameText(TPath.GetFileName(sFileName), '__history') then // Skip History
      begin
        sName := IncludeTrailingPathDelimiter(ADest) + TPath.GetFileName(sFileName);
        CreateDir(sName);
        ConvertProject(sFileName, sName);
      end;
    end;

    ADest := IncludeTrailingPathDelimiter(ADest);
    for sFileName in TDirectory.GetFiles(ASource) do
    begin
      sName := TPath.GetFileName(sFileName);
      lRead.Clear;
      lWrite.Clear;
      if not SameText(sName, '.DS_Store') then
      begin
        if TPath.GetExtension(sName) = '.pas' then
        begin
          WriteLog('PAS - ' + sName + ' ' + sFileName);
          lRead.LoadFromFile(sFileName);
          ConvertCode(sName, lRead, lWrite);
          lWrite.SaveToFile(ADest + sName, lRead.Encoding);
        end
        else if (TPath.GetExtension(sName) = '.dfm') or (TPath.GetExtension(sName) = '.fmx')  then
        begin
          WriteLog('DFM - ' + sName + ' ' + sFileName);
          DfmConvert.Clear;
          DfmRead.Clear;
          DfmRead.LoadFromFile(sFileName);
          // The DFM can be binary and I must check first the type
          case TestStreamFormat(DfmRead) of
            sofUnknown:
              begin
                raise Exception.Create('Invalid format!');
              end;
            sofBinary:
              begin
                DfmRead.Position := 0;
                ObjectResourceToText(DfmRead, DfmConvert);
                DfmConvert.Position := 0;
                lRead.LoadFromStream(DfmConvert);
              end;
          else
            begin
              // sofText, sofUTF8Text
              lRead.LoadFromFile(sFileName);
            end;
          end;
          ConvertDfm(sName, lRead, lWrite);
          lWrite.SaveToFile(ADest + sName, lRead.Encoding);
        end
        else if TPath.GetExtension(sName) = '.dcu' then
        begin
          // skip
        end
        else
        begin
          WriteLog('COPY - ' + sName + ' ' + sFileName);
          TFile.Copy(sFileName, ADest + sName, true);
        end;
      end;

    end;
  finally
    lRead.Free;
    lWrite.Free;
    DfmRead.Free;
    DfmConvert.Free;
  end;

end;

end.
