program TestBerkeley;

uses
  Forms,
  TestBerkeleyMain in 'TestBerkeleyMain.pas' {Form2},
  BerkeleyDB in 'BerkeleyDB.pas',
  BerkeleyDB40520 in 'BerkeleyDB40520.pas',
  BerkeleyStat in 'BerkeleyStat.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
