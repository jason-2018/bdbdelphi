program Project1;



uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  dbconst in 'dbconst.pas',
  ObjectDB in 'ObjectDB.pas',
  BerkeleyDLL in 'BerkeleyDLL.pas',
  BerkeleyDBconst in 'BerkeleyDBconst.pas',
  BerkeleyDB in 'BerkeleyDB.pas',
  BerkeleyLib in 'BerkeleyLib.pas';

{$R *.res}
//var
//  Debugger: TmxDebugger;

begin
  //Debugger:=TmxDebugger.Create('AAA');
  //Debugger.StartDebugging;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
