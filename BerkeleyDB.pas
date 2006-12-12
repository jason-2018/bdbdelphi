unit BerkeleyDB;

interface
uses
  Windows,
  Classes,
  Contnrs,
  BerkeleyDB40520,
  BerkeleyEnv;

type
  //
  //
  //
  TKeyCallback = function ( secondary : PDB;
                           const key : PDBT;
                           const data : PDBT;
                           result: PDBT):int; cdecl;

  TExtactKey = function ( Var Data;
                          Var Key : Pointer;
                          Var KeyLen : Integer):Integer of object;

  TBerkeleyCursor = class;
  TberkeleyDB = class;

  TCoreBerkeleyDB = class(TBerkeleyObject)
  private
    FDB : PDB;
    FDBType : TDBTYPE;
    FFlags : DWORD;
    FMode  : DWORD;

    Factive : Boolean;

    // Environment
    FEnv : TBerkeleyEnv;

    // Transaction
    FTXN : PDB_TXN;

    // Cursor
    FCursors : TObjectList;

    // Event
    FOnExtractKey: TExtactKey;
    FCacheSize: Integer;

    function  GetCount: Integer;
    function  GetFlags: u_int32_t;
    procedure SetFlags(Value: u_int32_t);
    function  GetCursor(index: Integer): TBerkeleyCursor;
    function  GetCursorCount: Integer;
    procedure SetActive(const Value: boolean);

  protected
    procedure SetCacheSize(const Value: Integer); virtual;
    procedure AddCursor(Const aCursor : TBerkeleyCursor);
    procedure RemoveCursor(const aCursor: TBerkeleyCursor);
  public
    Constructor Create;
    Destructor Destroy; override;

    procedure Open; Virtual;
    procedure Close; Virtual;
    //
    // Cursor;
    //
    function NewCursor:TBerkeleyCursor;
    
    //
    //
    //
    function put( Var Key : DBT;
                  Var Data : DBT;
                  Const Flags : DWORD = 0):integer;
    function get ( Var Key : DBT;
                   Var Data : DBT;
                   Const Flags : DWORD = 0):integer;

    function Del ( Var Key : DBT;
                   Const Flags : DWORD = 0):integer;

    procedure Sync;

    // Handle
    property DB : PDB Read FDB;

    // Parameters
    property DBType : TDBType read FDBType write FDBType;
    property Flags  : u_int32_t read GetFlags write SetFlags;

    Property CacheSize : Integer read FCacheSize write SetCacheSize;

    //
    property Active : boolean read FActive write SetActive;
    property Count : Integer read GetCount;


    // Properties
    property Cursors[index : Integer] : TBerkeleyCursor read GetCursor;
    property CursorCount : Integer read GetCursorCount;

    // Events
    property OnExtractKey : TExtactKey read FOnExtractKey write FOnExtractKey;

  end;

  TBerkeleyIndex = class(TCoreBerkeleyDB)
  private
    FIndexName : String;
    FOwner : TBerkeleyDB;
    FMaxKeySize: Integer;
    procedure SetMaxKeySize(const Value: Integer);
  protected
    procedure SetCacheSize(const Value: Integer); override;
  public
    constructor Create(const DB: TBerkeleyDB; Const IndexName : string);
    destructor Destroy; override;
    procedure AfterConstruction; override;

    procedure Open; override;
    procedure Close; override;

    procedure Remove;

    property MaxKeySize : Integer read FMaxKeySize write SetMaxKeySize;
  end;

  TBerkeleyDB = class(TCoreBerkeleyDB)
  private
    FFileName,
    FDBName    : PChar;

    FIndexes : TObjectList;

    function GetFileName: string;
    function GetEnv: TBerkeleyEnv;
    procedure SetEnv(const Value: TBerkeleyEnv);
    function GetDBName: String;

    //
    //
    //
    function  GetIndex(index: Integer): TBerkeleyIndex;
    function  GetIndexCount: Integer;

  protected
    procedure AddToIndexList(const aIndex: TBerkeleyIndex);
    procedure RemoveFromIndexList(const aIndex: TBerkeleyIndex);

  public
    constructor Create ( Const aFileName : String;
                         Const aDBName : String = '';
                         Const aFlags : dword = DB_CREATE;
                         Const aEnv : TBerkeleyEnv = Nil); virtual;
    destructor Destroy; override;
    procedure AfterConstruction; override;

    procedure Open; override;
    procedure Close; override;

    // indexes
    function AddIndex( ExtractKey : TExtactKey):TBerkeleyIndex;
    procedure RemoveIndex(Const aIndex : TBerkeleyIndex);
    //
    //
    //
    function Write ( Var Key; Const KeyLen : Integer;
                     Var Data; Const DataLen : Integer;
                     Const Flags : DWORD = 0):integer; overload; virtual;
    function Write ( Var Buffer; Const BufLen : Integer;
                     Const Flags : DWORD = 0):integer; overload; virtual;


    function Read  ( Var Key; Const KeyLen : Integer;
                     Var Data; var DataLen : Integer;
                     Const Flags : DWORD = 0):integer; overload; virtual;

    function Read  ( Var Buffer; var BufLen : Integer;
                     Const Flags : DWORD = 0):integer; overload; virtual;

    function Delete ( var Key; Const Keylen : integer):integer;

    //
    //
    procedure StartTransaction( Const Flags : u_int32_t=0);
    procedure Commit( Const Flags : u_int32_t=DB_TXN_SYNC);
    procedure Abort;
    procedure Discard;


    //
    //
    //
    property Indexes [index : integer] : TBerkeleyIndex read GetIndex;
    property IndexCount : integer read GetIndexCount;

  published
    property FileName : string read GetFileName;
    property DBName : String read GetDBName;

    property Environment : TBerkeleyEnv read GetEnv write SetEnv;

  end;



  TBerkeleyCursor = class(TBerkeleyObject)
  private
    FOwner  : TCoreBerkeleyDB;
    FCursor : PDBC;

    FKey    : DBT;

    function GetRecno: integer;

  public
    Constructor Create(Const Owner : TCoreBerkeleyDB);
    Destructor Destroy; override;

    //
    //
    //
    function put( Var Key : DBT;
                  Var Data : DBT;
                  Const Flags : DWORD = DB_KEYLAST):integer; overload; virtual;
    function get ( Var Key : DBT;
                   Var Data : DBT;
                   Const Flags : DWORD = 0):integer; overload; virtual;

    function Del ( Var Key : DBT;
                   Const Flags : DWORD = 0):integer; overload; virtual;

    //
    // More civilized version...
    //
    function put ( Var Key; Const KeyLen : Integer;
                     Var Data; Const DataLen : Integer;
                     Const Flags : DWORD = 0):integer; overload; virtual;
    function put ( Var Buffer; Const BufLen : Integer;
                   Const Flags : DWORD = 0):integer; overload; virtual;
    function get  ( Var Key; Const KeyLen : Integer;
                    Var Data; Const DataLen : Integer;
                    Const Flags : DWORD = 0):integer;  overload; virtual;

    function Delete ( var Key; Const Keylen : integer):integer;

    property Cursor : PDBC read FCursor;

    property Recno : integer read GetRecno;
  end;



implementation
uses
  Sysutils,
  Dialogs;

//
// DBT
//
function InitDBT (var aDBT : DBT; Buffer : Pointer = Nil; BufSize : Integer = 0; Flags :integer =DB_DBT_USERMEM):PDBT; inline;
begin
  Fillchar(aDBT,Sizeof(DBT),0);
  aDBT.data:=Buffer;
  aDBT.size:=BufSize;
  aDBT.ulen:=BufSize;
  aDBT.flags:=Flags;
  result:=@aDBT;
end;

procedure ZeroDBT(var aDBT : DBT);
begin
  FillChar(aDBT,Sizeof(DBT),0);
end;


function KeyCallback ( secondary : PDB;
                       const key : PDBT;
                       const data : PDBT;
                       aResult: PDBT):int; cdecl;
var
  aKey : Pointer;
  aKeyLen : Integer;
begin
  TCoreBerkeleyDB(Secondary.app_private).FOnExtractKey(Data.data^,aKey,aKeyLen);
  InitDBT(aResult^,aKey,aKeyLen);
  Result:=0;
end;



{ TCoreBerkeleyDB }

constructor TCoreBerkeleyDB.Create;
begin
  inherited Create;
  Factive:=False;
  
  FCursors:=TObjectList.create;
  FFlags:=0;
  FMode:=0;
  FDBType:=DB_BTREE;

  FCacheSize:=0;
end;

destructor TCoreBerkeleyDB.Destroy;
begin
  FCursors.Free;

  if Factive then
    Close;
  inherited;
end;

procedure TCoreBerkeleyDB.Open;
begin

end;

procedure TCoreBerkeleyDB.Close;
begin

end;

//
//
//
function TCoreBerkeleyDB.put( Var Key : DBT;
                          Var Data : DBT;
                          Const Flags : DWORD = 0):integer;
begin
  Result:=FDB.put(FDB,FTXN,@Key,@Data,Flags);
  Check(Result);
end;

function TCoreBerkeleyDB.get ( Var Key : DBT;
                           Var Data : DBT;
                           Const Flags : DWORD = 0):integer;
begin
  Result:=FDB.Get(FDB,FTXN,@Key,@Data,Flags);
  Check(Result);
end;

function TCoreBerkeleyDB.Del ( Var Key : DBT;
                           Const Flags : DWORD = 0):integer;
begin
  Result:=FDB.del(FDB,FTXN,@Key);
end;

procedure TCoreBerkeleyDB.Sync;
begin
  Check(FDB.sync(FDB));
end;


//
//
//
function TCoreBerkeleyDB.NewCursor: TBerkeleyCursor;
begin
  Result:=TBerkeleyCursor.Create(Self);

end;

procedure TCoreBerkeleyDB.AddCursor(const aCursor: TBerkeleyCursor);
begin
  FCursors.Add(aCursor);
end;

procedure TCoreBerkeleyDB.RemoveCursor(const aCursor: TBerkeleyCursor);
begin
  FCursors.Extract(aCursor);
end;


function TCoreBerkeleyDB.GetCursor(index: Integer): TBerkeleyCursor;
begin
  Result:=FCursors[index] as TBerkeleyCursor;
end;

function TCoreBerkeleyDB.GetCursorCount: Integer;
begin
  Result:=FCursors.Count;
end;

function TCoreBerkeleyDB.GetFlags: u_int32_t;
begin
  Check(FDB.get_flags(FDB,Result));
end;

procedure TCoreBerkeleyDB.SetFlags(Value : u_int32_t);
begin
  Check(FDB.set_flags(FDB,Value));
end;

procedure TCoreBerkeleyDB.SetCacheSize(const Value: Integer);
begin
  FCacheSize := Value;
end;

//
//
//
procedure TCoreBerkeleyDB.SetActive(const Value: boolean);
begin
  if FActive and Value then
    Exit
  else if Not FActive and Value then
    Open
  else if FActive and Not Value then
    Close;

  FActive := Value;
end;


//
//
//
function TCoreBerkeleyDB.GetCount: Integer;
var
  Stat : PDB_BTREE_STAT;
begin
  Check(FDB.stat(FDB,FTXN,Stat,DB_FAST_STAT)); //DB_FAST_STAT
  Result:=Stat.bt_ndata;
end;


///////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////

{ TBerkeleyIndex }

constructor TBerkeleyIndex.Create( const DB : TBerkeleyDB; Const IndexName : String);
begin
  Inherited Create;
  FDB:=Nil;
  FIndexName:=IndexName;
  FOwner:=DB;
  Fenv:=Fowner.FEnv;
  Fowner.AddToIndexList(Self);

  FEnv:=DB.FEnv;
  FFlags:=DB_CREATE or DB_DUPSORT;
  FMode:=0;
  FDBType:=DB_BTREE;
  FTXN:=Nil;
end;

destructor TBerkeleyIndex.Destroy;
begin
  inherited;
end;

procedure TBerkeleyIndex.AfterConstruction;
//var
//  CacheSize : Integer;
begin
  inherited;
  if Assigned(FEnv) then
    Check(_Db_Create(FDB,FEnv.Env{,DB_THREAD}))
  else
    Check(_Db_Create(FDB,Nil{,DB_THREAD}));

  FDB.app_private:=Self;  // Reference to me
  FDB.set_errpfx(FDB,'IDX');
  FDB.set_errcall(FDB,ErrCall);

  //
  FDB.set_flags(FDB, DB_DUPSORT);

  // ????
  {
  if (FCacheSize * FMaxKeySize) > (256 *1024)  then
  begin
    CacheSize:=FCacheSize * FMaxKeySize;
    if (CacheSize mod 2) = 1 then
      Inc(CacheSize);

    FDB.set_cachesize(FDB,0,CacheSize,0);
  end;
  }
end;

//
//
//
procedure TBerkeleyIndex.Open;
var
  DBName : String;
begin
  DBName:=Fowner.DBName+'_'+FIndexName;

  EnterCriticalSection;
  Try
    Check(FDB.open(FDB,FTXN, Pchar(FOwner.FFilename),
                             Pchar(DBName),
                             FDBType,FFlags,FMode));

    Check(FOwner.FDB.associate(FOwner.FDB, (* Primary database *)
                  FTXN,         (* TXN id *)
                  FDB,          (* Secondary database *)
                  KeyCallback,  (* Callback used for key creation. *)
                 0));           (* Flags *)
    FActive:=True;

  Finally
    LeaveCriticalSection;
  End;
end;


procedure TBerkeleyIndex.Close;
var
  i : Integer;
begin
  if Assigned(FDB) then
  begin
    For i:=0 To FCursors.Count-1 do
      (FCursors[i] as TBerkeleyCursor).Free;

    Check(FDB.Close(FDB));
    FDB:=Nil;
  end;
  FActive:=False;
  Inherited;
end;


//
//
//
procedure TBerkeleyIndex.Remove;
var
  DBName : String;
begin
  DBName:=Fowner.DBName+'_'+FIndexName;
  EnterCriticalSection;
  try
    FDB.Remove(FDB,Pchar(FOwner.FFilename),Pchar(DBName));
    FDB:=Nil;
    FActive:=False;
  finally
    LeaveCriticalSection;
  end;
end;

procedure TBerkeleyIndex.SetCacheSize(const Value: Integer);
begin
  inherited;

end;

procedure TBerkeleyIndex.SetMaxKeySize(const Value: Integer);
begin
  FMaxKeySize := Value;
  if (FMaxKeySize Mod 2) = 1  then
    Inc(FMaxKeySize);
end;

///////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////

{ TBerkeleyDB }

constructor TBerkeleyDB.Create( const aFileName: String;
                                const aDBName: String = '';
                                Const aFlags : dword = DB_CREATE;
                                Const aEnv : TBerkeleyEnv = Nil);
begin
  Inherited Create;
  FDB:=Nil;
  FFlags:=aFlags;
  FActive:=False;
  FIndexes :=TObjectList.create;

  FEnv:=aEnv;
  FTXN:=Nil;

  FFilename:=Nil;
  FFileName:=StrNew(PChar(aFilename));
  FDBName:=Nil;
  if aDBName <> '' then
    FDBName:=StrNew(Pchar(aDBName));
end;

destructor TBerkeleyDB.Destroy;
begin

  // indexes
  FIndexes.Free;
  
  StrDispose(FFileName);
  if Assigned(FDBName) then
    StrDispose(FDBName);

  inherited;
end;

procedure TBerkeleyDB.AfterConstruction;
begin
  Inherited;
  if Assigned(FEnv) then
    Check(_Db_Create(FDB,FEnv.Env{,DB_THREAD}))
  else
    Check(_Db_Create(FDB,NIL{,DB_THREAD}));

  FDB.set_flags(FDB,DB_RECNUM);

  FDB.app_private:=Self;  // Reference to me
  FDB.set_errpfx(FDB,'DB');
  FDB.set_errcall(FDB,ErrCall);
end;

//
//
//
procedure TBerkeleyDB.Open;
var
  i: Integer;
begin
  EnterCriticalSection;
  Try
    Check(FDB.open(FDB,FTXN,Pchar(FFilename),Pchar(DBName),FDBType,FFlags,FMode));

    for i := 0 to Findexes.count - 1 do
    begin
      (FIndexes[i] as TBerkeleyIndex).Open;
    end;

    FActive:=True;

  Finally
    LeaveCriticalSection;
  End;
end;

procedure TBerkeleyDB.Close;
var
  i: Integer;
begin
  EnterCriticalSection;
  try
    If Assigned(FDB) then
    begin
      For i:=0 To FCursors.Count-1 do
        (FCursors[i] as TBerkeleyCursor).Free;

      for i := 0 to Findexes.count - 1 do
      begin
        (FIndexes[i] as TBerkeleyIndex).Close;
      end;

      Check(FDB.Close(FDB));
    end;
    FDB:=Nil;
    FActive:=False;

  finally
    LeaveCriticalsection;
  end;
end;


//
//
//
function TBerkeleyDB.AddIndex(ExtractKey: TExtactKey):TBerkeleyIndex;
begin
  Result:=TBerkeleyIndex.Create(Self,'Str');
  Result.OnExtractKey:=ExtractKey;
end;

procedure TBerkeleyDB.AddToIndexList(Const aIndex : TBerkeleyIndex);
begin
  FIndexes.Add(aIndex);
end;

procedure TBerkeleyDB.RemoveFromIndexList(Const aIndex : TBerkeleyIndex);
begin
  FIndexes.Extract(aIndex);
end;

procedure TBerkeleyDB.RemoveIndex(const aIndex: TBerkeleyIndex);
begin
  aIndex.Remove;
  FIndexes.Remove(aIndex);
end;

function  TBerkeleyDB.GetIndex(index: Integer): TBerkeleyIndex;
begin
  Result:=FIndexes[Index] as TBerkeleyIndex;
end;

function  TBerkeleyDB.GetIndexCount: Integer;
begin
  Result:=FIndexes.Count;
end;

//
//
//

function TBerkeleyDB.GetDBName: String;
begin
  Result:=FDBName;
end;

function TBerkeleyDB.GetEnv: TBerkeleyEnv;
begin
  Result:=FEnv;
end;

procedure TBerkeleyDB.SetEnv(const Value: TBerkeleyEnv);
begin
  FEnv:=Value;
end;

function TBerkeleyDB.GetFileName: string;
begin
  Result:=FFilename;
end;

//
//
//
function TBerkeleyDB.Write ( Var Key; Const KeyLen : Integer;
                             Var Data; Const DataLen : Integer;
                             Const Flags : DWORD = 0):integer;
var
  _Key  : DBT;
  _Data : DBT;
begin
  InitDBT(_Key,@Key,KeyLen);
  InitDBT(_Data,@Data,DataLen);
  Result:=Put(_Key,_Data,Flags);
end;

function TBerkeleyDB.Write ( Var Buffer; Const BufLen : Integer;
                             Const Flags : DWORD = 0):integer; 
var
  _Key  : DBT;
  _Data : DBT;
  Key : Pointer;
  Keylen : Integer;
begin
  if Not Assigned(FOnExtractKey) then
    Raise Exception.Create('Error extracting key');

  FOnExtractKey(Buffer,Key,KeyLen);
  InitDBT(_Key,Key,KeyLen);
  InitDBT(_Data,@Buffer,BufLen);
  Result:=Put(_Key,_Data,Flags);
end;

function TBerkeleyDB.Read  ( Var Key; Const KeyLen : Integer;
                             Var Data; Var DataLen : Integer;
                             Const Flags : DWORD = 0):integer;
var
  _Key  : DBT;
  _Data : DBT;
begin
  InitDBT(_Key,@Key,KeyLen);
  InitDBT(_Data,@Data,DataLen);
  Result:=Get(_Key,_Data,Flags);
end;

function TBerkeleyDB.Read  ( Var Buffer; var BufLen : Integer;
                             Const Flags : DWORD = 0):integer; 
var
  _Key  : DBT;
  _Data : DBT;
  Key : Pointer;
  Keylen : Integer;
begin
  if Not Assigned(FOnExtractKey) then
    Raise Exception.Create('Error extracting key');

  FOnExtractKey(Buffer,Key,KeyLen);
  InitDBT(_Key,@Key,KeyLen);
  InitDBT(_Data,@Buffer,BufLen);
  Result:=Get(_Key,_Data,Flags);
end;

function TBerkeleyDB.Delete ( var Key; Const Keylen : Integer):integer;
var
  _Key  : DBT;
begin
  InitDBT(_Key,@Key,KeyLen);
  Result:=Del(_Key);
end;


//
//
//
procedure TBerkeleyDB.StartTransaction( Const Flags : u_int32_t=0);
begin
  if Assigned(Fenv) then
    Check(FEnv.Env.txn_begin(Fenv.env,Nil,FTXN,Flags));
end;

procedure TBerkeleyDB.Commit( Const Flags : u_int32_t=DB_TXN_SYNC);
begin
  if Assigned(FTXN) then
    Check(FTXN.commit(FTXN,Flags));
  FTXN:=Nil;
end;

procedure TBerkeleyDB.Abort;
begin
  if Assigned(FTXN) then
    Check(FTXN.abort(FTXN));
  FTXN:=Nil;
end;

procedure TBerkeleyDB.Discard;
begin
  if Assigned(FTXN) then
    Check(FTXN.Discard(FTXN));
  FTXN:=Nil;
end;


///////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////

{ TBerkeleyCursor }

constructor TBerkeleyCursor.Create(Const Owner : TCoreBerkeleyDB);
begin
  inherited Create;
  FOwner:=Owner;
  FOwner.AddCursor(Self);

  (* Get a cursor *)
  Check(Fowner.FDB.cursor(Fowner.FDB,FOwner.FTXN,FCursor, 0));
end;

destructor TBerkeleyCursor.Destroy;
begin
  Check(FCursor.c_close(FCursor));
  FOwner.RemoveCursor(Self);
  inherited;
end;

//
//
//
function TBerkeleyCursor.get( var Key : DBT; var Data: DBT;
                              const Flags: DWORD):integer;
begin
  Result:=FCursor.c_get(FCursor,@Key,@Data,Flags);
  Check(Result);
  if Result = 0 then
    FKey:=Key;
end;

function TBerkeleyCursor.put(var Key : DBT; var Data : DBT;
  const Flags: DWORD = DB_KEYLAST):integer;
begin
  result:=FCursor.c_put(FCursor,@Key,@Data,Flags);
  Check(Result);
  if Result = 0 then
    FKey:=Key;
end;

function TBerkeleyCursor.Del( var Key : DBT; 
                              Const Flags : DWORD = 0):integer;
begin
  result:=FCursor.c_del(FCursor);
  Check(Result);
end;
//
//
//
function TBerkeleyCursor.put ( Var Key; Const KeyLen : Integer;
                             Var Data; Const DataLen : Integer;
                             Const Flags : DWORD = 0):integer;
var
  _Key  : DBT;
  _Data : DBT;
begin
  InitDBT(_Key,@Key,KeyLen);
  InitDBT(_Data,@Data,DataLen);
  Result:=Put(_Key,_Data,Flags);
end;

function TBerkeleyCursor.put ( Var Buffer; Const BufLen : Integer;
                                 Const Flags : DWORD = 0):integer;
var
  _Key  : DBT;
  _Data : DBT;
  Key : Pointer;
  Keylen : Integer;
begin
  if Not Assigned(FOwner.FOnExtractKey) then
    Raise Exception.Create('Error extracting key');

  FOwner.FOnExtractKey(Buffer,Key,KeyLen);
  InitDBT(_Key,Key,KeyLen);
  InitDBT(_Data,@Buffer,BufLen);
  Result:=Put(_Key,_Data,Flags);
end;

function TBerkeleyCursor.get  ( Var Key; Const KeyLen : Integer;
                             Var Data; Const DataLen : Integer;
                             Const Flags : DWORD = 0):integer;
var
  _Key  : DBT;
  _Data : DBT;
begin
  InitDBT(_Key,@Key,KeyLen);
  InitDBT(_Data,@Data,DataLen);
  Result:=Get(_Key,_Data,Flags);
end;

function TBerkeleyCursor.Delete ( var Key; Const Keylen : Integer):integer;
var
  _Key  : DBT;
begin
  InitDBT(_Key,@Key,KeyLen);
  Result:=Del(_Key);
end;


//
//
//
function TBerkeleyCursor.GetRecno: integer;
var
  data : DBT;
  recno: Integer;
  Ret : Integer;
begin
  Result:=0;
  (*
   * Request the record number, and store it into appropriately
   * sized and aligned local memory.
   *)
  InitDBT(Data,@Recno,Sizeof(Recno));
  Ret:=get(Fkey, data, DB_GET_RECNO);
  case Ret of
  0: Result:=recno;
  else
    Check(Ret);
  end;
end;

end.
