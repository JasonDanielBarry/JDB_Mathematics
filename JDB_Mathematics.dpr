program JDB_Mathematics;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  InterpolatorClass in 'Source\InterpolatorClass.pas',
  LinearInterpolationMethods in 'Source\LinearInterpolationMethods.pas',
  LinearRescalingMethods in 'Source\LinearRescalingMethods.pas',
  RoundingMethods in 'Source\RoundingMethods.pas',
  TEST_RoundingMethods in 'Source\TEST_RoundingMethods.pas',
  GeomBox in 'Source\Geometry\GeomBox.pas',
  GeometryBaseClass in 'Source\Geometry\GeometryBaseClass.pas',
  GeometryMathMethods in 'Source\Geometry\GeometryMathMethods.pas',
  GeometryTypes in 'Source\Geometry\GeometryTypes.pas',
  GeomLineClass in 'Source\Geometry\GeomLineClass.pas',
  GeomPolygonClass in 'Source\Geometry\GeomPolygonClass.pas',
  GeomPolyLineClass in 'Source\Geometry\GeomPolyLineClass.pas',
  GeomSpaceVectorClass in 'Source\Geometry\GeomSpaceVectorClass.pas',
  TEST_GeomLineClass in 'Source\Geometry\TEST_GeomLineClass.pas',
  LinearAlgebraTypes in 'Source\LinearAlgebra\LinearAlgebraTypes.pas',
  LineIntersectionMethods in 'Source\LinearAlgebra\LineIntersectionMethods.pas',
  LAVectorMethods in 'Source\LinearAlgebra\LAVectorMethods.pas',
  LAMatrixDeterminantMethods in 'Source\LinearAlgebra\Matrices\LAMatrixDeterminantMethods.pas',
  LAMatrixHelperMethods in 'Source\LinearAlgebra\Matrices\LAMatrixHelperMethods.pas',
  LAMatrixMethods in 'Source\LinearAlgebra\Matrices\LAMatrixMethods.pas',
  TEST_LAMatrixMethods in 'Source\LinearAlgebra\Matrices\TEST_LAMatrixMethods.pas',
  DrawingAxisConversionAspectRatioClass in 'Source\AxisConversion\DrawingAxisConversionAspectRatioClass.pas',
  DrawingAxisConversionBaseClass in 'Source\AxisConversion\DrawingAxisConversionBaseClass.pas',
  DrawingAxisConversionCalculationsClass in 'Source\AxisConversion\DrawingAxisConversionCalculationsClass.pas',
  DrawingAxisConversionClass in 'Source\AxisConversion\DrawingAxisConversionClass.pas',
  DrawingAxisConversionMouseControlClass in 'Source\AxisConversion\DrawingAxisConversionMouseControlClass.pas',
  DrawingAxisConversionPanningClass in 'Source\AxisConversion\DrawingAxisConversionPanningClass.pas',
  DrawingAxisConversionZoomingClass in 'Source\AxisConversion\DrawingAxisConversionZoomingClass.pas';

{ keep comment here to protect the following conditional from being removed by the IDE when adding a unit }
{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
//    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
