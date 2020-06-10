# EnvNeedle

Tool to cacth environment variables value's

## How to use

By importing into your Delphi project.

## Overloads methods

### Single Variable

``` Pascal
function GetEnvironmentVariable(const psVariableName: String): String;
```

_Return a value of environment variable if exists._

### With JSON Strings

``` Pascal
procedure GetEnvironmentVariable(var psJson: String; pbGuessVariableName: Boolean; paVariablesName: array of string);
```

OR

``` Pascal
procedure GetEnvironmentVariable(var psJson: String; pbGuessVariableName: Boolean; paVariablesName: TList<String>);
```

_Fill the fields values with the enviorement variables from the JSON string._

_If the variable `pbGuessVariableName` is set to `true` then the system try to guess the variable name by identifing his first character and his last character by keys character. Ex. `{your_envirioment_variable_name}`._

#### Exemples with JSON string

``` Pascal
const
  sJSONOut = '{"variable_one":"Value_one","variable_two":"Value_two"}';
var
  oEnvNeedle: TEnvNeedle;
  sJSON: String;
  aVariableNames: TList<String>;
begin
  oEnvNeedle := TEnvNeedle.Create;
  aVariableNames := TList<String>.Create;
  try
    sJSON := '{"variable_one":"variable_one","variable_two":"variable_two"}';

    aVariableNames.Add('variable_one');
    aVariableNames.Add('variable_two');

    oEnvNeedle.GetEnvironmentVariable(sJSON, false, ['variable_one', 'variable_two']);
    //OR
    oEnvNeedle.GetEnvironmentVariable(sJSON, false, aVariableNames);
    //OR
    sJSON := '{"variable_one":"{variable_one}","variable_two":"{variable_two}"}';

    oEnvNeedle.IdentifierCharacterStart := '{'; //this value is default
    oEnvNeedle.IdentifierCharacterEnd := '}'; //this value is default

    oEnvNeedle.GetEnvironmentVariable(sJSON, true, nil);
  finally
    oEnvNeedle.Free;
  end;
end;
```

The return is going to be

``` json
{
  "variable_one":"Value_one",
  "variable_two":"Value_two"
}
```

### With JSONObject

``` Pascal
procedure GetEnvironmentVariable(poJsonObject: TJSONObject; pbGuessVariableName: Boolean; paVariablesName: array of string);
```

OR

``` Pascal
procedure GetEnvironmentVariable(poJsonObject: TJSONObject; pbGuessVariableName: Boolean; paVariablesName: TList<String>);
```

_Fill the fields of JSONObject with the environment variables._

_If the variable `pbGuessVariableName` is set to `true` then the system try to guess the variable name by identifing his first character and his last character by keys character. Eq. `{your_envirioment_variable_name}`._

#### Exemples with JSONObject

```Pascal
var
  oJSONObject: TJSONObject;
  aVariableNames: TList<String>;
  oEnvNeedle: TEnvNeedle;
begin
  oEnvNeedle := TEnvNeedle.Create;
  oJSONObject := TJSONObject.Create;
  try

    aVariableNames := TList<String>.Create;
    aVariableNames.Add('variable_one');
    aVariableNames.Add('variable_two');

    oJSONObject.AddPair('variable_one', 'variable_one');
    oJSONObject.AddPair('variable_two', 'variable_two');

    oEnvNeedle.GetEnvironmentVariable(oJSONObject, false, ['variable_one', 'variable_two']);
    //OR
    oEnvNeedle.GetEnvironmentVariable(oJSONObject, false, aVariableNames);
    //OR
    oJSONObject.AddPair('variable_one', '{variable_one}');
    oJSONObject.AddPair('variable_two', '{variable_two}');

    oEnvNeedle.IdentifierCharacterStart := '{'; //this value is default
    oEnvNeedle.IdentifierCharacterEnd := '}'; //this value is default

    oEnvNeedle.GetEnvironmentVariable(oJSONObject, true, nil);
  finally
    oJSONObject.free;
    oEnvNeedle.free;
  end;
```

### With TDictionary

``` Pascal
procedure GetEnvironmentVariable(poList: TDictionary<string, string>);
```

#### Exemple with TDictionary

``` Pascal
var
  oList: TDictionary<string, string>;
begin
  oList := TDictionary<string, string>.Create;
  try
    oList.Add('variable_one', '');
    oList.Add('variable_two', '');

    oEnvNeedle.GetEnvironmentVariable(oList);
  finally
    oList.Free;
  end;
```

_Fill the dictionary values with environment variables using key has a index._

``` Pascal
function SetEnvironmentVariable(const psVariableName, psVariableValue: String): Boolean;
```

_Set the environment value to a specific environment variable and return his status._
