unit EnvNeedle;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  Winapi.Windows,
  System.Generics.Defaults;

type
  TParseJsonException = class(Exception);

  TEnvNeedle = class(TObject)
  private
    FsIdentifierCharacterStart: String;
    FsIdentifierCharacterEnd: String;
    function ExtractStringBetweenDelims(psInput: String): TList<String>;
    procedure GetEnvironmentVariableGuest(poJsonObject: TJSONObject);
  public
    constructor Create;
    function GetEnvironmentVariable(const psVariableName: String): String; overload;

    procedure GetEnvironmentVariable(var psJson: String; pbGuessVariableName: Boolean; paVariablesName: array of string); overload;
    procedure GetEnvironmentVariable(var psJson: String; pbGuessVariableName: Boolean; paVariablesName: TList<String>); overload;

    procedure GetEnvironmentVariable(poJsonObject: TJSONObject; pbGuessVariableName: Boolean; paVariablesName: array of string); overload;
    procedure GetEnvironmentVariable(poJsonObject: TJSONObject; pbGuessVariableName: Boolean; paVariablesName: TList<String>); overload;

    procedure GetEnvironmentVariable(poList: TDictionary<string, string>); overload;

    function SetEnvironmentVariable(const psVariableName, psVariableValue: String): Boolean;

    property IdentifierCharacterStart: String write FsIdentifierCharacterStart;
    property IdentifierCharacterEnd: String write FsIdentifierCharacterEnd;
  end;

implementation

uses
  System.StrUtils;

{ TEnvNeedle }

constructor TEnvNeedle.Create;
begin
  inherited;
  FsIdentifierCharacterStart := '{';
  FsIdentifierCharacterEnd := '}';
end;

procedure TEnvNeedle.GetEnvironmentVariable(var psJson: String;
  pbGuessVariableName: Boolean; paVariablesName: array of string);
var
 aVariableNames: TList<String>;
 sVariableName: String;
begin
  aVariableNames := TList<String>.Create;
  try
    for sVariableName in paVariablesName do
      aVariableNames.Add(sVariableName);

    GetEnvironmentVariable(psJson, pbGuessVariableName, aVariableNames);
  finally
    aVariableNames.Free;
  end;
end;

procedure TEnvNeedle.GetEnvironmentVariable(poJsonObject: TJSONObject;
  pbGuessVariableName: Boolean; paVariablesName: array of string);
var
 aVariableNames: TList<String>;
 sVariableName: String;
begin
  aVariableNames := TList<String>.Create;
  try
    for sVariableName in paVariablesName do
      aVariableNames.Add(sVariableName);

    GetEnvironmentVariable(poJsonObject, pbGuessVariableName, aVariableNames);
  finally
    aVariableNames.Free;
  end;
end;


procedure TEnvNeedle.GetEnvironmentVariable(poList: TDictionary<string, string>);
var
  oItem: TPair<string, string>;
begin
  for oItem in poList do
    poList.AddOrSetValue(oItem.Key, GetEnvironmentVariable(oItem.Key));
end;


function TEnvNeedle.ExtractStringBetweenDelims(psInput: String): TList<String>;
var
  nPos, nbPos, nLastIndex: Integer;
begin
  result := TList<String>.Create;
  nLastIndex := 1;
  repeat
    nPos := Pos(FsIdentifierCharacterStart, psInput, nLastIndex);
    nLastIndex := nPos + nLastIndex;
    if nPos > 0 then
    begin
      nbPos := PosEx(FsIdentifierCharacterEnd, psInput, nPos + Length(FsIdentifierCharacterStart));
      if nbPos > 0 then
      begin
        result.add(Copy(psInput, nPos + Length(FsIdentifierCharacterStart), nbPos - (nPos + Length(FsIdentifierCharacterStart))));
      end;
    end;
  until nPos <= 0;

end;

procedure TEnvNeedle.GetEnvironmentVariableGuest(poJsonObject: TJSONObject);
var
  i: Integer;
  oPair: TJSONPair;
  sValue: String;
begin
  for i := 0 to poJsonObject.Count - 1 do
  begin
    oPair := poJsonObject.Pairs[i];
    sValue := GetEnvironmentVariable(oPair.JsonValue.Value);
    if sValue = EmptyStr then
      Continue;
    oPair.JsonValue := TJSONString.Create(sValue);
  end;
end;

procedure TEnvNeedle.GetEnvironmentVariable(poJsonObject: TJSONObject; pbGuessVariableName: Boolean;
  paVariablesName: TList<String>);
var
  i: Integer;
  oPair: TJSONPair;
  sValue: String;
begin
  if pbGuessVariableName then
  begin
    GetEnvironmentVariableGuest(poJsonObject);
    Exit;
  end;

  for i := 0 to poJsonObject.Count - 1 do
  begin
    oPair := poJsonObject.Pairs[i];

    if not paVariablesName.Contains(oPair.JsonValue.Value) then
     Continue;

    sValue := GetEnvironmentVariable(oPair.JsonValue.Value);
    oPair.JsonValue := TJSONString.Create(sValue);
  end;
end;

procedure TEnvNeedle.GetEnvironmentVariable(var psJson: String; pbGuessVariableName: Boolean;
  paVariablesName: TList<String>);
  var
  oJSONObject: TJSONObject;
begin
  oJSONObject := TJSONObject.ParseJSONValue(psJson) as TJSONObject;

  if oJSONObject = nil then
    raise TParseJsonException.Create('Erro to parse JSON string in TJSONObject!');

  try
    GetEnvironmentVariable(oJSONObject, pbGuessVariableName, paVariablesName);
    psJson := oJSONObject.ToString;
  finally
    oJSONObject.Free;
  end;
end;

function TEnvNeedle.SetEnvironmentVariable(const psVariableName, psVariableValue: String): Boolean;
begin
  if psVariableName.Trim = EmptyStr then
    Exit(False);

  result := Winapi.Windows.SetEnvironmentVariable(PWideChar(psVariableName), PWideChar(psVariableValue));
end;


function TEnvNeedle.GetEnvironmentVariable(const psVariableName: String): String;
var
  aVariables: TList<String>;
  sValue, sEnvironmentValue: String;
  nVariable: Integer;
begin
  result := EmptyStr;
  if psVariableName.Trim = EmptyStr then
    Exit;

  result := System.SysUtils.GetEnvironmentVariable(psVariableName.Trim).Trim;

  if result <> EmptyStr then
    Exit;

  aVariables := TList<String>.Create;
  try
    aVariables := ExtractStringBetweenDelims(psVariableName.Trim);
    if aVariables.Count = 0 then
      Exit;
    sValue := psVariableName.Trim;
    for nVariable := 0 to aVariables.Count - 1 do
    begin
      sEnvironmentValue := System.SysUtils.GetEnvironmentVariable(aVariables[nVariable]);
      sValue := StringReplace(sValue,
        FsIdentifierCharacterStart + aVariables[nVariable] + FsIdentifierCharacterEnd,
        sEnvironmentValue, [rfReplaceAll, rfIgnoreCase]);
    end;
    result := sValue;
  finally
    aVariables.Free;
  end;
end;

end.
