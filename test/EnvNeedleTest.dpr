program EnvNeedleTest;

uses
  Vcl.Forms,
  System.SysUtils,
  GUITestRunner,
  TestFramework,
  XMLTestRunnerNUnit in 'Componentes\XMLTestRunnerNUnit.pas',
  uEnvNeedleTest in 'uEnvNeedleTest.pas',
  EnvNeedle in '..\src\EnvNeedle.pas';

var
  oResultado: TTestResult;
  nResultado: integer;

begin
  Application.Initialize;

  if Trim(ParamStr(1)) = '' then
  begin
    GUITestRunner.RunRegisteredTests;
  end
  else
  begin
    oResultado := XMLTestRunnerNUnit.RunRegisteredTests(ChangeFileExt(Application.ExeName, '') +
      'Reports.xml');
    try
      nResultado := oResultado.ErrorCount + oResultado.FailureCount;
      System.Halt(nResultado);
    finally
      FreeAndNil(oResultado); //PC_OK
    end;
  end;
end.
