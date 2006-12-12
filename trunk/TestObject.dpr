program TestObject;

uses
  Forms,
  ObjectDataSet in 'ObjectDataSet.pas',
  PropertyFields in 'PropertyFields.pas',
  ObjectUnit1 in 'ObjectUnit1.pas' {Form1},
  BerkeleyDB40520 in 'BerkeleyDB40520.pas',
  BerkeleyDB in 'BerkeleyDB.pas',
  BerkeleyEnv in 'BerkeleyEnv.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
