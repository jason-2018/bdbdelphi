unit TestBerkeleyMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BerkeleyDB, BerkeleyDB40520, BerkeleyStat, StdCtrls;

type
  TForm2 = class(TForm)
    CreateDB: TButton;
    FreeDB: TButton;
    OpenDB: TButton;
    CloseDB: TButton;
    Populate: TButton;
    Memo1: TMemo;
    List: TButton;
    ListCursor: TButton;
    First: TButton;
    Last: TButton;
    Next: TButton;
    Prev: TButton;
    GetCursor: TButton;
    CloseCursor: TButton;
    Stat: TButton;
    procedure CreateDBClick(Sender: TObject);
    procedure FreeDBClick(Sender: TObject);
    procedure OpenDBClick(Sender: TObject);
    procedure CloseDBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PopulateClick(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure ListCursorClick(Sender: TObject);
    procedure GetCursorClick(Sender: TObject);
    procedure CloseCursorClick(Sender: TObject);
    procedure FirstClick(Sender: TObject);
    procedure LastClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure PrevClick(Sender: TObject);
    procedure StatClick(Sender: TObject);
  private
    { Private declarations }
    procedure _Update;
    function ExtractStr(var Data; var Key: Pointer;
      var KeyLen: Integer): Integer;
  public
    { Public declarations }
    DB: TBerkeleyDB;
    Cursor : TBerkeleyCursor;
    DBStat : TBerkeleyBtreeStat;
  end;

var
  Form2: TForm2;

implementation
uses
  StrUtils;

type
  TData = record
    Num : Integer;
    Str : String[26];
  end;


{$R *.dfm}
procedure TForm2._Update;
begin
  FreeDB.Enabled:=DB <> Nil;
  CreateDB.Enabled:=Not (DB <> Nil);
  if db <> Nil then
  begin
    CLoseDB.Enabled:=DB.Active;
    OpenDB.Enabled:=Not DB.Active;

  end;
end;


procedure TForm2.FormCreate(Sender: TObject);
begin
  _Update;
end;

function TForm2.ExtractStr( Var Data;
                            Var Key : Pointer;
                            Var KeyLen : Integer):Integer;

begin
  Key:=@Tdata(data).Str;
  KeyLen:=Length(TData(Data).Str);
end;

procedure TForm2.CreateDBClick(Sender: TObject);
begin
  DB:=TBerkeleyDB.Create('.\Test.db','Test');
  DB.AddIndex(ExtractStr);
  _Update;
end;

procedure TForm2.FreeDBClick(Sender: TObject);
begin
  DB.Free;
  DB:=Nil;
  _Update;
end;

procedure TForm2.OpenDBClick(Sender: TObject);
begin
  DB.Open;
  _Update;
end;


procedure TForm2.CloseDBClick(Sender: TObject);
begin
  DB.Close;
  _Update;
end;

procedure TForm2.PopulateClick(Sender: TObject);
var
  I: Integer;
  Data : TData;
begin
  //
  for I := 0 to 100 - 1 do
  begin
    Data.Num:=I;
    Data.Str:= DupeString(Char((i mod 26) + Byte('A')),20);

    DB.Write(Data.Num,Sizeof(Data.num),Data,Sizeof(data));
  end;
end;


procedure TForm2.ListClick(Sender: TObject);
var
  I: Integer;
  Data : TData;
  DataLen : Integer;
begin
  for I := 0 to 100 - 1 do
  begin
    Data.Num:=I;
    DataLen:=Sizeof(data);
    DB.Read(Data.Num,Sizeof(Data.num),Data,DataLen);

    Memo1.Lines.Add(IntToStr(Data.Num)+' : '+Data.Str);
  end;

end;


procedure TForm2.ListCursorClick(Sender: TObject);
var
  I: Integer;
  Data : TData;

begin
  Cursor:=DB.NewCursor;
  try
    
    Cursor.get(Data.Num,Sizeof(Data.num),Data,Sizeof(data),DB_FIRST);
      Memo1.Lines.Add(IntToStr(Data.Num)+' : '+Data.Str);

    for I := 0 to 100 - 1 do
    begin
      Data.Num:=I;
      Cursor.get(Data.Num,Sizeof(Data.num),Data,Sizeof(data),DB_NEXT);

      Memo1.Lines.Add(IntToStr(Data.Num)+' : '+Data.Str);
    end;
  finally
    Cursor.free;
  end;

end;

procedure TForm2.GetCursorClick(Sender: TObject);
begin
  Cursor:=DB.NewCursor;
end;

procedure TForm2.CloseCursorClick(Sender: TObject);
begin
  Cursor.free;
end;

procedure TForm2.FirstClick(Sender: TObject);
var
  Data : TData;
begin
  Cursor.get(Data.Num,Sizeof(Data.num),Data,Sizeof(data),DB_FIRST);
  Memo1.Lines.Add(IntToStr(Data.Num)+' : '+Data.Str);
end;

procedure TForm2.LastClick(Sender: TObject);
var
  Data : TData;
begin
  Cursor.get(Data.Num,Sizeof(Data.num),Data,Sizeof(data),DB_LAST);
  Memo1.Lines.Add(IntToStr(Data.Num)+' : '+Data.Str);
end;

procedure TForm2.NextClick(Sender: TObject);
var
  Data : TData;
begin
  Cursor.get(Data.Num,Sizeof(Data.num),Data,Sizeof(data),DB_NEXT);
  Memo1.Lines.Add(IntToStr(Data.Num)+' : '+Data.Str);
end;

procedure TForm2.PrevClick(Sender: TObject);
var
  Data : TData;
begin
  Cursor.get(Data.Num,Sizeof(Data.num),Data,Sizeof(data),DB_PREV);
  Memo1.Lines.Add(IntToStr(Data.Num)+' : '+Data.Str);
end;


procedure TForm2.StatClick(Sender: TObject);
begin
  DBStat:=TBerkeleyBtreeStat.Create(DB);
  Try
    DBStat.print(Memo1.Lines);
  Finally
    DBStat.free;
  End;
end;

end.
