unit uEnvNeedleTest;

interface

uses
  System.Classes, TestFramework, System.SysUtils, EnvNeedle, Winapi.Windows,
  System.Generics.Collections,
  System.JSON;

type

  TestEnvNeedleTest = class(TTestCase)
  private
    oEnvNeedle: TEnvNeedle;
    procedure RemoveEnvironmentVariable(paVariableName: array of string);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGetEnvironmentVariableSimple;
    procedure TestGetEnvironmentVariableJsonStringArray;
    procedure TestGetEnvironmentVariableJsonStringTList;
    procedure TestGetEnvironmentVariableJsonStringGuess;
    procedure TestGetEnvironmentVariableJsonStringInvalid;
    procedure TestGetEnvironmentVariableJsonStringTemplatedVariable;
    procedure TestGetEnvironmentVariableJsonStringTemplatedVariableIdentifier;

    procedure TestGetEnvironmentVariableJsonObjectArray;
    procedure TestGetEnvironmentVariableJsonObjectTList;
    procedure TestGetEnvironmentVariableJsonObjectGuess;
    procedure TestGetEnvironmentVariableJsonObjectGuessIdentifier;

    procedure TestGetEnvironmentVariableDictionary;
    procedure TestSetEnvironmentVariable;
  end;

implementation

const
  sEnvironmentVariable = 'SOFT_ENV_NEEDLE_TEST';

{ TestEnvNeedleTest }

procedure TestEnvNeedleTest.RemoveEnvironmentVariable(paVariableName: array of string);
var
  sVariable: String;
begin
  for sVariable in paVariableName do
    Winapi.Windows.SetEnvironmentVariable(PWideChar(sVariable), nil);
end;

procedure TestEnvNeedleTest.SetUp;
begin
  inherited;
  oEnvNeedle := TEnvNeedle.Create;
end;

procedure TestEnvNeedleTest.TearDown;
begin
  FreeAndNil(oEnvNeedle);
  inherited;
end;


procedure TestEnvNeedleTest.TestGetEnvironmentVariableDictionary;
var
  oList: TDictionary<string, string>;
begin
  oList := TDictionary<string, string>.Create;
  try
    oList.Add('variable_one', '');
    oList.Add('variable_two', '');
    oList.Add('variable_three', '');

    oEnvNeedle.SetEnvironmentVariable('variable_one', 'Value_one');
    oEnvNeedle.SetEnvironmentVariable('variable_two', 'Value_two');
    oEnvNeedle.SetEnvironmentVariable('variable_three', 'Value_three');
    oEnvNeedle.GetEnvironmentVariable(oList);

    CheckTrue(oList.Items['variable_one'] = 'Value_one');
    CheckTrue(oList.Items['variable_two'] = 'Value_two');
    CheckTrue(oList.Items['variable_three'] = 'Value_three');

  finally
    oList.Free;
    RemoveEnvironmentVariable(['variable_one', 'variable_two', 'variable_three']);
  end;
end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableJsonObjectTList;
var
  oJSONObject: TJSONObject;
  aVariableNames: TList<String>;
begin
  oJSONObject := TJSONObject.Create;
  aVariableNames := TList<String>.Create;
  try
    oEnvNeedle.SetEnvironmentVariable('variable_one', 'Value_one');
    oEnvNeedle.SetEnvironmentVariable('variable_two', 'Value_two');
    oEnvNeedle.SetEnvironmentVariable('variable_three', 'Value_three');

    oJSONObject.AddPair('variable_one', 'variable_one');
    oJSONObject.AddPair('variable_two', 'variable_two');
    oJSONObject.AddPair('variable_three', 'variable_three');

    aVariableNames.Add('variable_one');
    aVariableNames.Add('variable_two');
    aVariableNames.Add('variable_three');

    oEnvNeedle.GetEnvironmentVariable(oJSONObject, false, aVariableNames);
    CheckTrue(oJSONObject.Pairs[0].JsonValue.Value = 'Value_one');
    CheckTrue(oJSONObject.Pairs[1].JsonValue.Value = 'Value_two');
    CheckTrue(oJSONObject.Pairs[2].JsonValue.Value = 'Value_three');

  finally
    RemoveEnvironmentVariable(['variable_one', 'variable_two', 'variable_three']);
    oJSONObject.free;
    aVariableNames.Free;
  end;
end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableJsonObjectGuess;
var
  oJSONObject: TJSONObject;
begin
  oJSONObject := TJSONObject.Create;

  try
    oEnvNeedle.SetEnvironmentVariable('variable_one', 'Value_one');
    oEnvNeedle.SetEnvironmentVariable('variable_two', 'Value_two');
    oEnvNeedle.SetEnvironmentVariable('variable_three', 'Value_three');

    oJSONObject.AddPair('variable_one', '{variable_one}');
    oJSONObject.AddPair('variable_two', '{variable_two}');
    oJSONObject.AddPair('variable_three', '{variable_three}');

    oEnvNeedle.GetEnvironmentVariable(oJSONObject, True, nil);
    CheckTrue(oJSONObject.Pairs[0].JsonValue.Value = 'Value_one');
    CheckTrue(oJSONObject.Pairs[1].JsonValue.Value = 'Value_two');
    CheckTrue(oJSONObject.Pairs[2].JsonValue.Value = 'Value_three');
  finally
    RemoveEnvironmentVariable(['variable_one', 'variable_two', 'variable_three']);
    oJSONObject.free;
  end;
end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableJsonObjectGuessIdentifier;
var
  oJSONObject: TJSONObject;
begin
  oJSONObject := TJSONObject.Create;

  try
    oEnvNeedle.SetEnvironmentVariable('variable_one', 'Value_one');
    oEnvNeedle.SetEnvironmentVariable('variable_two', 'Value_two');
    oEnvNeedle.SetEnvironmentVariable('variable_three', 'Value_three');

    oJSONObject.AddPair('variable_one', '[variable_one]');
    oJSONObject.AddPair('variable_two', '[variable_two]');
    oJSONObject.AddPair('variable_three', '[variable_three]');

    oEnvNeedle.IdentifierCharacterStart := '[';
    oEnvNeedle.IdentifierCharacterEnd := ']';

    oEnvNeedle.GetEnvironmentVariable(oJSONObject, True, nil);
    CheckTrue(oJSONObject.Pairs[0].JsonValue.Value = 'Value_one');
    CheckTrue(oJSONObject.Pairs[1].JsonValue.Value = 'Value_two');
    CheckTrue(oJSONObject.Pairs[2].JsonValue.Value = 'Value_three');
  finally
    RemoveEnvironmentVariable(['variable_one', 'variable_two', 'variable_three']);
    oJSONObject.free;
  end;

end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableJsonObjectArray;
var
  oJSONObject: TJSONObject;
begin
  oJSONObject := TJSONObject.Create;
  try
    oEnvNeedle.SetEnvironmentVariable('variable_one', 'Value_one');
    oEnvNeedle.SetEnvironmentVariable('variable_two', 'Value_two');
    oEnvNeedle.SetEnvironmentVariable('variable_three', 'Value_three');

    oJSONObject.AddPair('variable_one', 'variable_one');
    oJSONObject.AddPair('variable_two', 'variable_two');
    oJSONObject.AddPair('variable_three', 'variable_three');

    oEnvNeedle.GetEnvironmentVariable(oJSONObject, false, ['variable_one', 'variable_two', 'variable_three']);
    CheckTrue(oJSONObject.Pairs[0].JsonValue.Value = 'Value_one');
    CheckTrue(oJSONObject.Pairs[1].JsonValue.Value = 'Value_two');
    CheckTrue(oJSONObject.Pairs[2].JsonValue.Value = 'Value_three');

  finally
    RemoveEnvironmentVariable(['variable_one', 'variable_two', 'variable_three']);
    oJSONObject.free;
  end;
end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableJsonStringTemplatedVariable;
const
  sJSONOut = '{"variable_one":"Value_one","variable_two":"http://Value_two:Value_Port/api"}';
var
  sJSON: String;
begin
  sJSON := '{"variable_one":"{variable_one}","variable_two":"http://{variable_two}:{variable_port}/api"}';
  try
    oEnvNeedle.SetEnvironmentVariable('variable_one', 'Value_one');
    oEnvNeedle.SetEnvironmentVariable('variable_two', 'Value_two');
    oEnvNeedle.SetEnvironmentVariable('variable_port', 'Value_Port');

    oEnvNeedle.GetEnvironmentVariable(sJSON, true, nil);
    CheckTrue(sJSON = sJSONOut);
  finally
    RemoveEnvironmentVariable(['variable_one', 'variable_two', 'variable_port']);
  end;

end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableJsonStringTemplatedVariableIdentifier;
const
  sJSONOut = '{"variable_one":"Value_one","variable_two":"http://Value_two:Value_Port/api"}';
var
  sJSON: String;
begin
  sJSON := '{"variable_one":"$variable_one}","variable_two":"http://$variable_two}:$variable_port}/api"}';
  try
    oEnvNeedle.SetEnvironmentVariable('variable_one', 'Value_one');
    oEnvNeedle.SetEnvironmentVariable('variable_two', 'Value_two');
    oEnvNeedle.SetEnvironmentVariable('variable_port', 'Value_Port');

    oEnvNeedle.IdentifierCharacterStart := '$';
    oEnvNeedle.IdentifierCharacterEnd := '}';

    oEnvNeedle.GetEnvironmentVariable(sJSON, true, nil);
    CheckTrue(sJSON = sJSONOut);

    sJSON := '{"variable_one":"${variable_one}","variable_two":"http://${variable_two}:${variable_port}/api"}';
    oEnvNeedle.IdentifierCharacterStart := '${';
    oEnvNeedle.IdentifierCharacterEnd := '}';

    oEnvNeedle.GetEnvironmentVariable(sJSON, true, nil);
    CheckTrue(sJSON = sJSONOut);

    sJSON := '{"variable_one":"{{variable_one}}","variable_two":"http://{{variable_two}}:{{variable_port}}/api"}';
    oEnvNeedle.IdentifierCharacterStart := '{{';
    oEnvNeedle.IdentifierCharacterEnd := '}}';

    oEnvNeedle.GetEnvironmentVariable(sJSON, true, nil);
    CheckTrue(sJSON = sJSONOut);

    sJSON := '{"variable_one":"Value_one","variable_two":"http://{{variable_two}}:{{variable_port}}/api"}';
    oEnvNeedle.IdentifierCharacterStart := '{{';
    oEnvNeedle.IdentifierCharacterEnd := '}}';

    oEnvNeedle.GetEnvironmentVariable(sJSON, true, nil);
    CheckTrue(sJSON = sJSONOut);
  finally
    RemoveEnvironmentVariable(['variable_one', 'variable_two', 'variable_port']);
  end;

end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableJsonStringTList;
const
  sJSONOut = '{"variable_one":"Value_one","variable_two":"Value_two"}';
var
  sJSON: String;
  aVariableNames: TList<String>;
begin
  sJSON := '{"variable_one":"variable_one","variable_two":"variable_two"}';
  aVariableNames := TList<String>.Create;
  try
    oEnvNeedle.SetEnvironmentVariable('variable_one', 'Value_one');
    oEnvNeedle.SetEnvironmentVariable('variable_two', 'Value_two');

    aVariableNames.Add('variable_one');
    aVariableNames.Add('variable_two');
    aVariableNames.Add('variable_three');
    oEnvNeedle.GetEnvironmentVariable(sJSON, false, aVariableNames);
    CheckTrue(sJSON = sJSONOut);
  finally
    RemoveEnvironmentVariable(['variable_one', 'variable_two', 'variable_three']);
    aVariableNames.Free;
  end;
end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableJsonStringGuess;
const
  sJSONOut = '{"variable_one":"Value_one","variable_two":"Value_two"}';
var
  sJSON: String;
begin
  sJSON := '{"variable_one":"{variable_one}","variable_two":"{variable_two}"}';
  try
    oEnvNeedle.SetEnvironmentVariable('variable_one', 'Value_one');
    oEnvNeedle.SetEnvironmentVariable('variable_two', 'Value_two');

    oEnvNeedle.GetEnvironmentVariable(sJSON, true, nil);
    CheckTrue(sJSON = sJSONOut);
  finally
    RemoveEnvironmentVariable(['variable_one', 'variable_two', 'variable_three']);
  end;
end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableJsonStringInvalid;
var
  sJSON: String;
begin
  sJSON := '{"variable_one":"variable_one","variable_two":"variable_two", "invalidjson"}';
  try
    oEnvNeedle.GetEnvironmentVariable(sJSON, true, nil);
    CheckTrue(false);
  except
    on e: TParseJsonException do
    begin
      CheckTrue(true);
    end;
  end;

end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableJsonStringArray;
const
  sJSONOut = '{"variable_one":"Value_one","variable_two":"Value_two"}';
var
  sJSON: String;
begin
  sJSON := '{"variable_one":"variable_one","variable_two":"variable_two"}';
  try
    oEnvNeedle.SetEnvironmentVariable('variable_one', 'Value_one');
    oEnvNeedle.SetEnvironmentVariable('variable_two', 'Value_two');

    oEnvNeedle.GetEnvironmentVariable(sJSON, false, ['variable_one', 'variable_two', 'variable_three']);
    CheckTrue(sJSON = sJSONOut);
  finally
    RemoveEnvironmentVariable(['variable_one', 'variable_two', 'variable_three']);
  end;
end;

procedure TestEnvNeedleTest.TestGetEnvironmentVariableSimple;
begin
  oEnvNeedle.SetEnvironmentVariable(sEnvironmentVariable, 'Value');
  CheckTrue(oEnvNeedle.GetEnvironmentVariable(sEnvironmentVariable) = 'Value');
  RemoveEnvironmentVariable([sEnvironmentVariable]);

  oEnvNeedle.SetEnvironmentVariable(sEnvironmentVariable, '');
  CheckTrue(oEnvNeedle.GetEnvironmentVariable(sEnvironmentVariable) = '');
  RemoveEnvironmentVariable([sEnvironmentVariable]);

  oEnvNeedle.SetEnvironmentVariable('variable_one', 'http://localhost.com');
  oEnvNeedle.SetEnvironmentVariable('variable_two', '5012');
  CheckTrue(oEnvNeedle.GetEnvironmentVariable('{variable_one}:{variable_two}') = 'http://localhost.com:5012');

  CheckTrue(oEnvNeedle.GetEnvironmentVariable('') = '');
end;

procedure TestEnvNeedleTest.TestSetEnvironmentVariable;
begin
  CheckTrue(oEnvNeedle.SetEnvironmentVariable(sEnvironmentVariable, 'Value'));
  RemoveEnvironmentVariable([sEnvironmentVariable]);

  CheckTrue(oEnvNeedle.SetEnvironmentVariable(sEnvironmentVariable, ''));
  RemoveEnvironmentVariable([sEnvironmentVariable]);

  CheckFalse(oEnvNeedle.SetEnvironmentVariable('', ''));
end;

initialization

RegisterTest('TestEnvNeedleTest', TestEnvNeedleTest.Suite);

end.
