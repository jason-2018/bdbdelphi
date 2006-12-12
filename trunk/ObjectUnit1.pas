unit ObjectUnit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BerkeleyDLL, ObjectDB, StdCtrls, DB, ObjectDataSet, Grids,
  DBGrids;
Type
  TPerson = class(TPersistObj)
  Private
    FForName : String;
    FSurName : String;
    FAdress  : String;
    FPC      : String;
    FTown    : String;    
  Published
    property ForName : String read FForName write FForName;
    property SurName : String read FSurName write FSurName;
    property Adress  : String read FAdress  write FAdress;
    property PC      : String read FPC      write FPC;
    property Town    : String read FTown    write FTown;
  end;
  TPersonClass = Class of TPerson;

type
  TForm1 = class(TForm)
    Env: TBerkeleyEnv;
    Person: TBerkeleyDB;
    Button1: TButton;
    ForName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SurName: TEdit;
    Label3: TLabel;
    Adress: TEdit;
    Label4: TLabel;
    CP: TEdit;
    Town: TEdit;
    Label5: TLabel;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    DBODataSet1: TDBODataSet;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    aPerson : TPerson;
    Procedure SetData;
  end;

var
  Form1: TForm1;


implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Env.Open;
  Person.Open;
  Person.ObjectClass:=TPerson;
  DBODataSet1.ObjectClass:=TPerson;
  DBODataSet1.Active:=true;
  Edit1.Text:=IntToStr(Person.Count);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  aPerson:=TPerson.Create;   
  aPerson.ForName  := ForName.Text;
  aPerson.SurName  := SurName.Text;
  aPerson.Adress   := Adress.Text;
  aPerson.PC       := Cp.Text;
  aPerson.Town     := TOwn.text;

  Person.Add(aPerson);
end;

Procedure TForm1.SetData;
begin
  ForName.Text    := aPerson.ForName;
  SurName.Text    := aPerson.SurName;
  Adress.Text     := aPerson.Adress;
  Cp.Text         := aPerson.PC;
  TOwn.text       := aPerson.Town;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  aPerson:=Person.first as TPerson;
  SetData;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  aPerson:=Person.Prev as TPerson;
  SetData;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  aPerson:=Person.Next as TPerson;
  SetData;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  aPerson:=Person.Last as TPerson;
  SetData;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Person.Close;
  Env.close;

end;

end.
