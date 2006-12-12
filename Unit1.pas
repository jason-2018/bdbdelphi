unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  BerkeleyDBConst,
  BerkeleyDB,
  BerKeleyDLL,
  //TestDll,
  StdCtrls, ObjectDB, Provider;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    BerkeleyEnv: TBerkeleyEnv;
    DBTest: TBerkeleyDB;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    DataSetProvider1: TDataSetProvider;
    Button8: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
//
  Edit1.Text:=IntToStr(Sizeof(TDBC));

end;

procedure TForm1.Button1Click(Sender: TObject);
begin

  BerkeleyEnv.Open;

  DBTest.FileName:=ExtractFilePath(Application.ExeName)+'\Data\Test.BDB';
  //DBTest.Create;
  DBTest.Open;

  Edit1.Text:=IntToStr(DBTest.Count);
  Refresh;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  DBTest.Close;

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i : Integer;
  Num : String;
  Num1 : String;
begin
  //DBTest.StartTransaction;
  try
    for i:=1 to 10000 do
    begin

      Num:=Format('%5d',[i]);
      Num1:=IntToStr(i);
      DBTest.Put(PChar(Num),Length(Num),Pchar(Num1),Length(Num1),DB_NOOVERWRITE);
    end;

  //  DBTest.Commit;
  except
  //  DBTEst.Abort;
  end

end;

procedure TForm1.Button4Click(Sender: TObject);
var
  Data : array [0..10] of Char;
  Key  : String;
  i : Integer;
begin
  Try
    for i:=1 to 10000 do
    begin
      key:=Format('%5d',[i]);
      Fillchar(Data,Sizeof(data),0);
      DBTest.Get(Pchar(key),Length(Key),@Data,10);
      Edit2.Text:=StrPas(Data);
      Refresh;
      SetLength(Key,5);
      Edit1.Text:=Key;
      Refresh;

    end;
  Except
  end;

end;

procedure TForm1.Button6Click(Sender: TObject);
var
  Data : array [0..10] of Char;
  Key  : String;
  i : Integer;
begin
  try
    Fillchar(Data,Sizeof(data),0);
    key:=Format('%5d',[1]);
    DBTest.Get(Pchar(key),Length(Key),@Data,10, DB_FIRST);
    Edit2.Text:=StrPas(Data);
    Refresh;
    i:=1;
    while True do
    begin
      Fillchar(Data,Sizeof(data),0);
      DBTest.Get(Pchar(key),Length(Key),@Data,10, DB_NEXT);
      Edit2.Text:=StrPas(Data);
      Refresh;
      Inc(i);
    end;

  except
  end;
  Edit1.Text:=IntToStr(i);
  Refresh;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  Data : array [0..10] of Char;
  Key  : Integer;
  i : Integer;
begin
  try
    for i:=1 to 10000 do
    begin
      Fillchar(Data,Sizeof(data),0);
      key:=i;
      DBTest.Get(@Key,4,@Data,10, DB_SET_RECNO);
      Edit2.Text:=StrPas(Data);
      Refresh;
      Edit1.Text:=IntToStr(i);
      Refresh;
    end;

  except
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  Data : array [0..10] of Char;
  Key  : String;
  i : Integer;
begin
		(*
		 * Reset the key each time, the dbp->c_get() routine returns
		 * the key and data pair, not just the key!
		 *)
		//* Reset the data DBT. */
		FillChar(data, sizeof(data),0);
    Memo1.Lines.clear;

		key:=Format('%5d',[StrToInt(Edit2.Text)]);
		DBTest.get(@key[i],Length(Key),@data,10,DB_SET_RECNO);

		// Display the key and data.
		Memo1.Lines.Add(Format('%d : %s', [key, data]));

		// Move the cursor a record forward.
		DBTest.get(@key[i],Length(Key),@data,10,DB_NEXT);

		// Display the key and data.
		Memo1.Lines.Add(Format('Next = %d : %s',[key, data]));

		(*
		 * Retrieve the record number for the following record into
		 * local memory.
		 *)
		//data.data = &recno;
		//data.size = sizeof(recno);
		//data.ulen = sizeof(recno);
		//data.flags |= DB_DBT_USERMEM;
		//if ((ret = dbcp->c_get(dbcp, &key, &data, DB_GET_RECNO)) != 0) {

end;

end.
 