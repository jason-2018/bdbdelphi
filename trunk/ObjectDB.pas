unit ObjectDB;
interface
uses
  Forms, Classes, SysUtils, Contnrs,
  //BerkeleyDLL,
  //BerkeleyDBConst,
  BerkeleyDB40520,
  DB;

type
  TPersistObj = class(TPersistent)
  Private
    FGuid : TGuid;
    procedure SetGuid (Value : Tguid);
    function GetGuid:TGuid;
  protected

  public
    Constructor Create;
  Published
    property Guid : TGuid read GetGuid write SetGuid;
  end;

  TPersistObjClass = class of TPersistObj;

  TDBLock = class
  Private
    FAutoDeadlockDetection     : boolean;
    FMaxNumberOfLockers     : integer;
    FMaxNumberOfLocks       : Integer;
    FMaxNumberOfLockObjects : integer;
  Published
    property AutoDeadlockDetection : boolean  read FAutoDeadlockDetection write FAutoDeadlockDetection;
    property MaxNumberOfLockers : integer  read FMaxNumberOfLockers write FMaxNumberOfLockers;
    property MaxNumberOfLocks   : Integer  read FMaxNumberOfLocks   write FMaxNumberOfLocks;
    property MaxNumberOfLockObjects : integer read FMaxNumberOfLockObjects write FMaxNumberOfLockObjects;
  end;


  TEnvFlags = ( INIT_CDB,        { Concurrent Access Methods.  }
                INIT_LOCK,      { Initialize locking.  }
                INIT_LOG,        { Initialize logging.  }
                INIT_MPOOL,    { Initialize mpool.  }
                INIT_REP,        { Initialize replication.  }
                INIT_TXN,        { Initialize transactions.  }
                JOINENV,          { Initialize all subsystems present.  }
                LOCKDOWN,        { Lock memory into physical core.  }
                PRIVATE,          { DB_ENV is process local.  }
                RECOVER,
                RECOVER_FATAL,  { Run catastrophic recovery.  }
                SYSTEM_MEM, { Use system-backed memory.  }
                THREAD,
                USE_ENVIRON,
                USE_ENVIRON_ROOT,
                DBREGISTER);

  TEnvFlagsSet = Set of TEnvFlags;

  TBerkeleyEnv = class(TComponent)
  private
    Fdbenv     : PDB_ENV;
    FEnvFlags  : TEnvFlagsSet;
    Flock      : TDBLock;
    FActive    : Boolean;

    FHomeDir   : String;
    FLogDir    : String;
    FTmpDir    : String;
    
    FBaseName  : String;

    FCacheSize : Integer;
    FPageSize  : Integer;

    Procedure SetActive(Value : Boolean);
  Public
    constructor Create(Owner : TComponent); override;
    Destructor Destroy; override;

    Procedure Open;
    Procedure Close;

  Published
    property Active : boolean read FActive Write SetActive;
    property HomeDir   : String read FHomeDir write FHomeDir;
    property LogDir    : String read FLogDir write FLogDir;
    property TmpDir    : String read FTmpDir write FTmpDir;
    property BaseName  : String Read FBaseName write FBaseName;
    property EnvFlags  : TEnvFlagsSet Read FEnvFlags write FEnvFlags;
    property CacheSize : Integer read FCacheSize write FCacheSize;
    property PageSize  : Integer read FPageSize  write FPageSize;
    //property Lock      : TDBLock read Flock;
  end;

  TDbOpenFlags = (DBAUTO_COMMIT,DBCREATE,DBEXCL,DBNOMMAP,DBDIRTY_READ,
                  DBRDONLY,DBTHREAD,DBTRUNCATE,DBUPGRADE);
  TDbOpenFlagSet = Set of TDbOpenFlags;

  TBerkeleyDB = class;



  TBdbGet = function ( key : PDBT; data : PDBT; const flags : Integer):integer of object;
  TBdbPut = function ( key : PDBT; data : PDBT; const flags : Integer):integer of object;
  TBdbDel = function ( key : PDBT; const flags : Integer):integer of object;

  TCoreBerkeleyDB = class(TCollectionItem)
  Private
    FOwner     : TBerkeleyDB;
    FDB        : PDB;
    FDBC       : PDBC;

    FkeyName   : String;
    FkeyType   : TFieldType;
    FkeySize   : Integer;

    //FDataBase  : String;
    FBaseType  : TDBTYPE;

    FCacheSize : Integer;
    FPageSize  : Integer;

    FSecondary : TCollection;

    FCurrent   : record
                   Key   : Variant;
                   Data  : Variant;
                   Recno : Cardinal;
                 end;

    function GetTransactional:boolean;
    function GetCount:cardinal;
  Protected
    Procedure Associate (const db : TCoreBerkeleyDB; const Flags : Integer);

    Procedure AcquireCursor;
    procedure ReleaseCursor;

    function GetRecno(Key : PDBT):Cardinal;

    function _Get  ( key : PDBT; data : PDBT; const flags : Integer):integer;
    function _CGet ( key : PDBT; data : PDBT; const flags : Integer):integer;
    function _Put  ( key : PDBT; data : PDBT; const flags : Integer):integer;
    function _CPut ( key : PDBT; data : PDBT; const flags : Integer):integer;
    function _Del  ( key : PDBT; const flags : Integer):integer;
    function _CDel ( key : PDBT; const flags : Integer):integer;

    procedure Sync;

  Public
    Get : TBdbGet;
    Put : TBdbPut;
    Del : TBdbDel;
    KeyCallBack : function (db : PDB; key : PDBT; Data : PDBT ; Key2 : PDBT ):longint;

    Constructor Create(Owner : TCollection); override;
    Destructor Destroy; override;
    procedure CreateDB(const Flags : Integer);
    procedure OpenDB(const Flags : Integer);
    procedure Close;

    function AddSecondaryIndex(Const Name : string):TCoreBerkeleyDB;

    procedure SetFlags (const Value : cardinal);
    function  GetFlags (const Value : cardinal):Boolean;

    property Transactional : Boolean Read GetTransactional;
    //property DataBase : String read FDataBase write FDataBase;
    Property Count : Cardinal Read GetCount;
  Published
    property BaseType  : TDBTYPE Read FBaseType write FBaseType default DB_BTREE;
    property KeyName   : String Read FkeyName Write FKeyName;
    property KeyType   : TFieldType Read FkeyType write FkeyType;
    property KeySize   : integer Read FKeySize write FKeySize;
    property CacheSize : Integer read FCacheSize write FCacheSize;
    property PageSize  : Integer read FPageSize  write FPageSize;
    property Secondary : TCollection read FSecondary;
  end;



  TBerkeleyDB = class(TComponent)
  private
    FFileName    : TFileName;
    FEnvironment : TBerkeleyEnv;
    FObjectList  : TObjectList;
    FRecno       : Cardinal;

    FPrimary      : TCoreBerkeleyDB;
    FSecondaries : TObjectList;
    FCurrentIndex: TCoreBerkeleyDB;

    FTid         : PDB_TXN;

    FBaseType  : TDBTYPE;
    FDBFlags   : TDbOpenFlagSet;

    FActive : Boolean;
    FAccessRecno : Boolean;

    FObjectClass : TPersistObjClass;


    function LookupCache(const Guid : TGuid):TPersistObj;

    function GetObject (Const id : TGuid):TPersistObj;
    procedure SetObject (Const id : TGuid; aObject : TPersistObj);

    function GetCount:cardinal;

    Procedure SetActive(Value : Boolean);


    procedure SetObjectClass(const Value: TPersistObjClass);
  protected

  public
    Constructor Create(Owner : TComponent); override;
    Destructor Destroy; override;

    Procedure Open;
    Procedure Close;

    procedure SetEnvironment ( Value : TBerkeleyEnv);
    procedure SetDBFlags(Value : TDbOpenFlagSet);
    function GetAccessRecno:Boolean;

    function Put( KeyBuffer : Pointer; const KeySize : integer;
                   buffer : Pointer; const BufSize : integer;
                   const flags : integer=0):Integer; overload;
    function Get( KeyBuffer : Pointer; const KeySize : integer;
                   buffer : Pointer; const BufSize : integer;
                   const flags : integer=0):Integer; overload;

    procedure Put(const aObject : TPersistObj; const flags : integer=0); overload;
    Function  Get(Const Guid : TGuid; const flags : integer=0):TPersistObj; overload;
    Procedure Del(Const Guid : TGuid; const flags : integer=0); overload;
    Function  Get(Const Index : Integer; const flags : integer=0):TPersistObj; overload;
    Procedure Del(Const Index : Integer; const flags : integer=0); overload;

    Procedure Add (Const aObject : TPersistObj);
    Procedure Insert(const id : TGuid; Const aObject : TPersistObj);
    procedure Delete(const id : TGuid; const FreeIt : Boolean);

    Procedure StartTransaction;
    procedure Commit;
    Procedure Abort;

    function first:TPersistObj; overload;
    function last:TPersistObj; overload;
    function next:TPersistObj; overload;
    function prev:TPersistObj; overload;

    function Locate (aKey : String; Value : Variant):TPersistObj;

    property ObjectClass: TPersistObjClass read FObjectClass write SetObjectClass;
    Property Count : Cardinal Read GetCount;
    property Objects[const id : TGuid]: TPersistObj Read GetObject write SetObject; default;
  Published
    property Active : boolean read FActive Write SetActive;
    property Environment : TBerkeleyEnv read FEnvironment Write FEnvironment;
    property BaseType : TDBTYPE Read FBaseType write FBaseType default DB_BTREE;
    property FileName : TFileName Read FFileName write FFileName;
    property DBFlags   : TDbOpenFlagSet Read FDBFlags write SetDBFlags;
    property AccessRecno : Boolean read FAccessRecno write FAccessRecno;
    property Primary : TCoreBerkeleyDB read FPrimary;
    property Recno : Cardinal read FRecNo;
  end;

  function XmlToObject (XMLValue : String; aCLass : TPersistObjClass):TPersistObj;
  Function ObjectToXml(aObject : TPersistObj):String;


  procedure Register;
implementation
{$R *}

uses
  Activex, TypInfo, XMLIntf, XMLDoc, Variants, Dialogs;
var
  Error : Integer;
  ErrStr : String;


function IsSet(const Value : Integer; Const Bit : Integer):boolean;
begin
  Result:=(Value and bit) = bit;
end;

function Check(err : Integer):boolean;
begin
  Result:=err = 0;
  Error:=err;
  if Err <> 0 then
  begin
    ErrStr:=_Db_Strerror(Err);
    Raise Exception.create('Error #'+IntToStr(Error)+' : '+ErrStr);
  end;
end;

function InitDBT (var aDBT : DBT; Buffer : Pointer = Nil; BufSize : Integer = 0; Flags :integer =DB_DBT_USERMEM):PDBT;
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

procedure ZeroGuid(var Guid : TGuid);
begin
  FillChar(Guid,Sizeof(Guid),0);
end;

////////////////////////////////////////////////////////////////////////////////
//
// TPersistObj
//
////////////////////////////////////////////////////////////////////////////////

Constructor TPersistObj.Create;
begin
  Inherited Create;
  coCreateGuid(FGuid);
end;


procedure TPersistObj.SetGuid (Value : Tguid);
begin
 FGuid:=Value;
end;

function TPersistObj.GetGuid:TGuid;
begin
  result:=FGuid;
end;

////////////////////////////////////////////////////////////////////////////////
//
// BerkeleyENV
//
////////////////////////////////////////////////////////////////////////////////
constructor TBerkeleyEnv.Create(Owner : TComponent);
begin
  Inherited Create(Owner);
  FDBenv:=Nil;

  FLock:=TDBLock.create;
  FActive:=False;  
  FCacheSize := 32 * 1024;
end;

Destructor TBerkeleyEnv.Destroy;
begin
  Close;
  FLock.free;
  inherited;
end;


procedure EnvErrCall ( const Env : pointer{PDB_ENV};
                       const errpfx: PChar;
                       const Msg : PChar ); cdecl;
begin
  ShowMessage(errpfx+' : '+Msg);
end;


Procedure TBerkeleyEnv.Open;
var
  Flags : Integer;
begin
  Factive:=False;

  (* Create an environment and initialize it for additional error reporting. *)
  Check(_db_Env_Create(Fdbenv));

  FDBEnv.set_errcall(FDBEnv,EnvErrCall);

  (*
   * Specify the shared memory buffer pool cachesize: 5MB.
   * Databases are in a subHomeDir of the environment home.
   *)
  {
  Try
    Check(Fdbenv.set_cachesize(Fdbenv, 0, FCacheSize, 0));
  except;
    close;
    Exit;
  end;
  }

  // Home dir
  if FHomeDir <> '' then
    Check(Fdbenv.set_data_dir(Fdbenv, Pchar(FHomeDir)));

  // Set LogDir
  If FLogDir <> '' then
    Check(Fdbenv.set_lg_dir(Fdbenv, Pchar(FlogDir)));

  // Set TMPdir
  If FTmpDir <> '' then
    Check(Fdbenv.set_tmp_dir(Fdbenv, Pchar(FTmpDir)));

  Flags:=DB_CREATE or DB_INIT_MPOOL;
  if INIT_CDB       in FEnvFlags then Flags:=Flags or DB_INIT_CDB;
  if INIT_LOCK      in FEnvFlags then Flags:=Flags or DB_INIT_LOCK;
  if INIT_LOG       in FEnvFlags then Flags:=Flags or DB_INIT_LOG;
  if INIT_MPOOL     in FEnvFlags then Flags:=Flags or DB_INIT_MPOOL;
  if INIT_REP       in FEnvFlags then Flags:=Flags or DB_INIT_REP;
  if INIT_TXN       in FEnvFlags then Flags:=Flags or DB_INIT_TXN;
  if JOINENV        in FEnvFlags then Flags:=Flags or DB_JOINENV;
  if LOCKDOWN       in FEnvFlags then Flags:=Flags or DB_LOCKDOWN;
  if PRIVATE        in FEnvFlags then Flags:=Flags or DB_PRIVATE;
  if RECOVER_FATAL  in FEnvFlags then Flags:=Flags or DB_RECOVER_FATAL;
  if SYSTEM_MEM     in FEnvFlags then Flags:=Flags or DB_SYSTEM_MEM;
  if RECOVER        in FEnvFlags then Flags:=Flags or DB_RECOVER;
  if THREAD         in FEnvFlags then Flags:=Flags or DB_THREAD;
  if USE_ENVIRON    in FEnvFlags then Flags:=Flags or DB_USE_ENVIRON;
  if USE_ENVIRON_ROOT in FEnvFlags then Flags:=Flags or DB_USE_ENVIRON_ROOT;
  if DBREGISTER     in FEnvFlags then Flags:=Flags or DB_REGISTER;

  (* Open the environment with full transactional support. *)
  Check(Fdbenv.open(Fdbenv, Pchar(FHomeDir),Flags));

  Factive:=True;
end;

Procedure TBerkeleyEnv.Close;
begin
  if Fdbenv = Nil then exit;
  Check(Fdbenv.close(Fdbenv));
  Fdbenv:=Nil;
end;

Procedure TBerkeleyEnv.SetActive(Value : Boolean);
begin
  if Value = FActive then
    Exit;

  if Not Value and Factive then
    Close
  else if Value and not Factive then
    Open;

  Factive:=Value;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  CoreBerkeleyDB
//
////////////////////////////////////////////////////////////////////////////////

Constructor TCoreBerkeleyDB.Create(Owner : TCollection);
begin
  inherited create(Owner);
  FOwner:=Nil;
  FSecondary :=TCollection.Create(TCoreBerkeleyDB);
  FBaseType:=DB_BTREE;
  Get:=_get;
  Put:=_Put;
  Del:=_Del;
end;

Destructor TCoreBerkeleyDB.Destroy;
begin
  Close;
  inherited Destroy;
end;

procedure TCoreBerkeleyDB.CreateDb(const Flags : Integer);
begin
  if Assigned(Fowner.FEnvironment) then
    Check(_Db_Create(FDB,Fowner.FEnvironment.FDBenv))
  else
    Check(_Db_Create(FDB));

  FDB.app_private:=Self;
end;

procedure TCoreBerkeleyDB.openDb(const Flags : integer);
var
  aFileName : String;
  aDataBAseName : String;
begin
  Try
    aFileName:=Fowner.FFileName;
    aDataBaseName:=ExtractFileName(aFileName);
    if Pos('.',aDataBaseName) > 0 then
      aDataBaseName:=Copy(aDataBaseName,1,Pos('.',aDataBaseName)-1);

    Check(FDB.open(FDB, FOwner.FTid,
                        Pchar(aFileName),
                        Pchar(aDataBaseName) ,
                        FBaseType, Flags , 0));
  Except
    Close;
    Raise;
  end;
end;

procedure TCoreBerkeleyDB.SetFlags (const Value : Cardinal);
begin
  Assert(FDB <> nil);
  
  Check(FDB.set_flags(FDB,Value));
end;

Function TCoreBerkeleyDB.GetFlags (const Value : Cardinal):Boolean;
Var
  Flags : Cardinal;
begin
  Flags:=Value;
  Check(FDB.get_flags(Fdb,Flags));
  Result:=Value =Flags;
end;

function TCoreBerkeleyDB.AddSecondaryIndex(Const Name : string):TCoreBerkeleyDB;
begin
  result:=TCoreBerkeleyDB.create(FSecondary);
  //Result.FDataBase:=FDataBase;
  Associate(Result,0);
end;


function _KeyCallBack (db : PDB; key : PDBT; Data : PDBT ; Key2 : PDBT ):longint; cdecl;
begin
  Result:=TCoreBerkeleyDB(db.App_Private).KeyCallBack(db, key, Data, Key2);
end;

Procedure TCoreBerkeleyDB.Associate (const db : TCoreBerkeleyDB; const Flags : Integer);
begin                                                    //DB_AUTO_COMMIT
  Check(FDB.associate(FDB,FOwner.FTid,db.Fdb,_KeyCallBack,Flags));
end;


procedure TCoreBerkeleyDB.Close;
begin
  if FDB = Nil Then exit;
  if Assigned(FDBC)  then
    ReleaseCursor;

  Check(FDB.close(FDB, 0));
  FDB:=Nil;
end;

function TCoreBerkeleyDB.GetTransactional:boolean;
begin
  Result:=False;
  If FDB = Nil then exit;
  Result:=FDB.get_transactional(FDB) <> 0;
end;

Procedure TCoreBerkeleyDB.AcquireCursor;
begin
  if FDBC <> Nil then exit;
 (* Acquire a cursor for the database. *)
  Check (Fdb.cursor(Fdb, Fowner.FTid, FDBC, 0));

  Get:=_CGet;
  Put:=_CPut;
  Del:=_Cdel;
end;

procedure TCoreBerkeleyDB.ReleaseCursor;
begin
  if FDBC = nil then exit;
  (* Close the cursor. *)
  Check(Fdbc.c_close(Fdbc));

  Fdbc:=Nil;
  Get:=_Get;
  Put:=_Put;
  Del:=_del;
end;

function TCoreBerkeleyDB.GetRecno(Key : PDBT):Cardinal;
var
  data : DBT;
  recno: Integer;
  Ret : Integer;
begin
  Result:=0;
  AcquireCursor;
  Try
    (*
     * Request the record number, and store it into appropriately
     * sized and aligned local memory.
     *)
    InitDBT(Data,@Recno,Sizeof(Recno));
    Ret:=get(key, @data, DB_GET_RECNO);
    case Ret of
    0: Begin
         Result:=recno;
         FCurrent.Recno:=Recno;
       end;
    
    end;
  finally
    ReleaseCursor;
  end;
end;

function TCoreBerkeleyDB._Get ( key : PDBT; data : PDBT; const flags : Integer):integer;
begin
  Result:=FDB.get(FDB, FOwner.FTid, key, Data, Flags);
end;

function TCoreBerkeleyDB._CGet ( key : PDBT; data : PDBT; const flags : Integer):integer;
begin
  Result:=FDBC.c_get(FDBC, key, data, Flags);
end;

function TCoreBerkeleyDB._Put ( key : PDBT; data : PDBT; const flags : Integer):integer;
begin
  Result:=FDB.put(FDB, FOwner.FTid, key, data, Flags);
end;

function TCoreBerkeleyDB._CPut ( key : PDBT; data : PDBT; const flags : Integer):integer;
begin
  Result:=FDBC.c_put(FDBC, key, data, Flags);
end;

function TCoreBerkeleyDB._CDel ( key : PDBT; const flags : Integer):Integer;
begin
	Result:=FDBC.c_del(FDBC, Flags);
end;

function TCoreBerkeleyDB._Del ( key : PDBT; const flags : Integer):Integer;
begin
  Result:=FDB.del(FDB,Fowner.FTid,Key,Flags);
end;

procedure TCoreBerkeleyDB.Sync;
begin
  Check(FDB.sync(FDB,0));
end;

//
//
//
function TCoreBerkeleyDB.GetCount:cardinal;
var
  //Count : Cardinal;
  Stat : PDB_BTREE_STAT;
begin
  Check(FDB.stat(FDB,Nil,Stat,DB_FAST_STAT)); //DB_FAST_STAT
  Result:=Stat.bt_ndata;
  //FreeMem(Stat);
end;


////////////////////////////////////////////////////////////////////////////////
//
//  BerkeleyDB
//
////////////////////////////////////////////////////////////////////////////////
Constructor TBerkeleyDB.Create(Owner : TComponent);
begin
  Inherited Create(Owner);
  FPrimary     :=TCoreBerkeleyDB.Create(Nil);
  FPrimary.FOwner:=Self;
  FSecondaries :=TObjectList.create(True);
  FObjectList  :=TObjectList.create(true);
  FBaseType    :=DB_BTREE;
  FDBFlags     :=[DBCREATE];
  FTid         :=Nil;
  FCurrentIndex:=Nil;

end;


Destructor TBerkeleyDB.Destroy;
begin
  Close;
  FObjectList.free;
  FSecondaries.Free;
  FPrimary.Free;
  Inherited Destroy;
end;

//
//
//
procedure TBerkeleyDB.open;
Var
  Flags : Integer;
begin
  Factive:=False;

  if (FEnvironment = Nil) and (FFIleName = '') then
    Raise Exception.create('FileName not defined !');

  if (FEnvironment <> nil) and Not(FEnvironment.FActive) then
    Raise Exception.create('Environment not open !');

  FPrimary.FBaseType:=FBaseType;
  FPrimary.CreateDB(0);

  if FAccessRecno then
    FPrimary.SetFlags(DB_RECNUM);

	//Check(FDB.set_pagesize(FDB, FPageSize));
  //Check(FDB.set_cachesize(FDB, 0, FCacheSize, 0));

  Flags:=0;
  if DBAUTO_COMMIT in FDBFlags then Flags:=Flags or DB_AUTO_COMMIT;
  if DBCREATE      in FDBFlags then Flags:=Flags or DB_CREATE;
  if DBEXCL        in FDBFlags then Flags:=Flags or DB_EXCL;
  if DBNOMMAP      in FDBFlags then Flags:=Flags or DB_NOMMAP;
  if DBDIRTY_READ  in FDBFlags then Flags:=Flags or DB_DIRTY_READ;
  if DBRDONLY      in FDBFlags then Flags:=Flags or DB_RDONLY;
  if DBTHREAD      in FDBFlags then Flags:=Flags or DB_THREAD;
  if DBTRUNCATE    in FDBFlags then Flags:=Flags or DB_TRUNCATE;
  if DBUPGRADE     in FDBFlags then Flags:=Flags or DB_UPGRADE;

  FPrimary.OpenDB(Flags);
  FActive:=True;

  FAccessRecno:=FPrimary.GetFlags(DB_RECNUM);
end;

procedure TBerkeleyDB.close;
begin
  Factive:=False;
  if FPrimary = Nil Then exit;
  FPrimary.Close;
end;

procedure TBerkeleyDB.SetEnvironment ( Value : TBerkeleyEnv);
begin
  FEnvironment:=Value;
  if INIT_TXN in FEnvironment.FEnvFlags then
    FDBFlags:=FDBFlags+[DBAUTO_COMMIT]
  else
    FDBFlags:=FDBFlags-[DBAUTO_COMMIT];
end;

procedure TBerkeleyDB.SetDBFlags(Value : TDbOpenFlagSet);
begin
  if DBAUTO_COMMIT in Value then
  begin
    if (FEnvironment = Nil) Then
    begin
      ShowMessage('Set an env. to use transaction');
      exit;
    end;

    If not(INIT_TXN in FEnvironment.FEnvFlags) then
    begin
      ShowMessage('Set INIT_TXN in env. to use transaction');
      exit;
    end;
  end;
  FDBFlags:=Value;
end;


procedure TBerkeleyDB.SetObjectClass(const Value: TPersistObjClass);
begin
  if Value <> nil then
  begin
    if Value.ClassInfo = nil then
    begin
      Raise Exception.create('Class Error');
      //tabaseError(OBJDATA_NO_CLASSINFO);
    end;

    FObjectClass := Value;
  end;
end;

function TBerkeleyDB.GetAccessRecno:Boolean;
begin
  Result:=FaccessRecno;
  if FPrimary <> nil then
    Result:=FPrimary.GetFlags(DB_RECNUM);
end;



Procedure TBerkeleyDB.SetActive(Value : Boolean);
begin
  if Value then
    Open
  else
    Close;
end;

function TBerkeleyDB.LookupCache(const Guid : TGuid):TPersistObj;
var
  i : Integer;
  aGuid : TGuid;
begin
  result:=Nil;
  for i:=0 to FObjectList.Count-1 do
  begin
    aGuid:=(FObjectList.Items[i] as TPersistObj).Guid;
    if CompareMem(@aGuid,@Guid,Sizeof(TGuid)) then
    begin
      Result:=FObjectList.Items[i] as TPersistObj;
      Exit;
    end;
  end;
end;

procedure TBerkeleyDB.StartTransaction;		(* Begin the transaction. *)
begin
  if FEnvironment = Nil then
    Raise Exception.Create('No berkeley environment defined !');

  Check(FEnvironment.Fdbenv^.txn_begin(FEnvironment.Fdbenv, Nil, Ftid, 0));
  if FPrimary.Fdbc <> Nil then
  begin
    FPrimary.ReleaseCursor;
    FPrimary.AcquireCursor;
  end;
end;

procedure TBerkeleyDB.Commit;
begin
  if Ftid = Nil then exit;
	Check(Ftid.commit(Ftid, 0));
  if FPrimary.Fdbc <> Nil then
    FPrimary.ReleaseCursor;
end;

procedure TBerkeleyDB.Abort;
begin
  if Ftid = Nil then exit;
  check(Ftid.abort(Ftid));
  if FPrimary.Fdbc <> Nil then
    FPrimary.ReleaseCursor;
end;

function TBerkeleyDB.Put( KeyBuffer : Pointer; const KeySize : integer;
                   buffer : Pointer; const BufSize : integer;
                   const flags : integer=0):integer;
var
  key, data : DBT;
begin
  InitDBT(Key,KeyBuffer,KeySize);
  InitDBT(Data,Buffer,BufSize);
  Result:=FPrimary.put(@key, @data, Flags);
end;

function TBerkeleyDB.Get( KeyBuffer : Pointer; const KeySize : integer;
                   buffer : Pointer; const BufSize : integer;
                   const flags : integer=0):Integer;
var
  key, data : DBT;
begin
  if IsSet(Flags,DB_FIRST) or IsSet(Flags,DB_NEXT) or
     IsSet(Flags,DB_PREV) or IsSet(Flags,DB_LAST) or
     IsSet(Flags,DB_SET_RECNO) or IsSet(Flags,DB_CURRENT) then
    FPrimary.AcquireCursor
  else
    FPrimary.ReleaseCursor;

  InitDBT(Key,KeyBuffer,KeySize);
  InitDBT(Data,Buffer,BufSize);
  result:=FPrimary.get(@key, @data, Flags);
end;

procedure TBerkeleyDB.Put(const aObject : TPersistObj; const flags : integer=0);
var
  key, data : DBT;
  Guid : TGuid;
  Buffer : String;
  Ret : Integer;
begin
  Guid:=aObject.Guid;
  Buffer:=ObjectToXML(aObject);

  InitDBT(Key,@Guid,Sizeof(TGuid));
  InitDBT(Data,@Buffer[1],Length(Buffer));

  ret:=FPrimary.Put(@key, @data, Flags);
  if ret = 0 then
    FRecno:=Primary.GetRecno(@Key);
end;

Function TBerkeleyDB.Get(Const Guid : TGuid; const flags : integer=0):TPersistObj;
var
  key, data : DBT;
  Buffer : String;
  ret : Integer;
begin
  Result:=LookupCache(Guid);
  if Result <> Nil then
  begin
    InitDBT(Key,@Guid,Sizeof(Guid));
    FRecno:=Primary.GetRecno(@Key);
    exit;
  end;

  InitDBT(Key,@Guid,Sizeof(Guid));
  InitDBT(Data,Nil,0,0);

  Ret:=FPrimary.Get( @key, @data, Flags);
  Case Ret of
  0: begin
       SetLength(Buffer,Data.size);
       Move(Data.Data^,Buffer[1],Data.Size);

       Result:=XMLToObject(Buffer,FObjectClass);
       FObjectList.Add(Result);

       FRecno:=Primary.GetRecno(@Key);
     end;
  DB_NOTFOUND:;
  end;
end;

function TBerkeleyDB.GetCount:cardinal;
begin
  Result:=FPrimary.GetCount;
end;

Procedure TBerkeleyDB.Del(Const Guid : TGuid; const flags : integer=0);
var
  key : DBT;
begin
  InitDBT(Key,@Guid,Sizeof(Guid));
  FPrimary.del(@Key,Flags);
end;

Function TBerkeleyDB.Get(Const Index : Integer; const flags : integer=0):TPersistObj;
var
  key, data : DBT;
  Buffer : String;
  aFlags : Integer;
  Ret : Integer;
begin
  aFlags:=0;
  Result:=Nil;
  //Result:=LookupCache(Guid);
  //if Result <> Nil then exit;
  if Not IsSet(Flags,DB_SET_RECNO) then
    aFlags:=Flags or DB_SET_RECNO;

  InitDBT(Key,@Index,Sizeof(Index));
  FillChar(Data,Sizeof(Data),0);
  Ret:=FPrimary.Get(@key, @data, aFlags);
  Case Ret of
  0: begin
       SetLength(Buffer,Data.size);
       Move(Data.Data^,Buffer[1],Data.Size);

       Result:=XMLToObject(Buffer,FObjectClass);
       FObjectList.Add(Result);
       FRecno:=Index;
     end;
  DB_NOTFOUND:;
  end;

end;

Procedure TBerkeleyDB.Del(Const Index : Integer; const flags : integer=0);
var
  key  : DBT;
begin
  FPrimary.AcquireCursor;
  InitDBT(Key,@Index,Sizeof(Index));
  FPrimary.del(@key,flags);
end;

//
//
//
function TBerkeleyDB.GetObject (Const id : TGuid):TPersistObj;
begin
  Result:=Get(Id);
end;

procedure TBerkeleyDB.SetObject (Const id : TGuid; aObject : TPersistObj);
begin
  Put(aObject);
end;

//
//
//
Procedure TBerkeleyDB.Add (Const aObject : TPersistObj);
begin
  FObjectList.Add(aObject);
  Put(aObject,0);
end;

Procedure TBerkeleyDB.Insert(const id : TGuid; Const aObject : TPersistObj);
begin
  FObjectList.Add(aObject);
  Put(aObject);
end;

procedure TBerkeleyDB.Delete(const id : TGuid; Const FreeIt : Boolean);
var
  aObject : TPersistObj;
begin
  if FreeIt then
  begin
    aObject:=LookupCache(id);
    if aObject <> Nil then aObject.Free;
  end;
  Del(Id);
end;

function TBerkeleyDB.first:TPersistObj;
var
  Guid : TGuid;
begin
  FPrimary.AcquireCursor;
  ZeroGuid(Guid);
  Result:=get(Guid,DB_FIRST);
end;

function TBerkeleyDB.last:TPersistObj;
var
  Guid : TGuid;
begin
  FPrimary.AcquireCursor;
  ZeroGuid(Guid);
  Result:=get(Guid,DB_LAST);
end;

function TBerkeleyDB.next:TPersistObj;
var
  Guid : TGuid;
begin
  FPrimary.AcquireCursor;
  ZeroGuid(Guid);
  Result:=get(Guid,DB_NEXT);
end;

function TBerkeleyDB.prev:TPersistObj;
var
  Guid : TGuid;
begin
  FPrimary.AcquireCursor;
  ZeroGuid(Guid);
  Result:=get(Guid,DB_PREV);
end;

function TBerkeleyDB.Locate (aKey : String; Value : Variant):TPersistObj;
begin
  //Result:=LookupCache
  Result:=Nil;
end;

//
//
//
function XMLToObject(XMLValue : String; aClass : TPersistObjClass):TPersistObj;
var
  Xml : IXMLDocument;
  Root,Node,Node1 : IXMLNode;
  PropInfo : PPropInfo;
  i : Integer;
  name,value : string;
  ClassName : string;
  uid : string;
begin
  //Result:=Nil;

  Xml:=LoadXMLData(XmlValue);
  Xml.Active:=True;
  Root:=XML.ChildNodes.FindNode(aClass.ClassName);

  Result:=aClass.Create;

  for i:=0 to Root.ChildNodes.Count-1 do
  begin
    Node:=Root.ChildNodes.Nodes[i];
    name:=Lowercase(Node.NodeName);

    if Node.ChildNodes.Count = 0 then Continue;
    Node1:=Node.ChildNodes[0];

    if Not( Node1.NodeType in [ntText,ntCData])  then
      continue;

    if Node.NodeValue = Null then
      Continue;

    name:=Lowercase(Node.NodeName);
    PropInfo:=GetPropInfo(PTypeInfo(Result.ClassInfo), name);

    if PropInfo = nil then Continue;
    //  Raise Exception.Create('Field Not Found :'+Lowercase(Fields.FieldDef(i).Name));
    case PropInfo^.PropType^.Kind of
    tkUnknown      : ;
    tkChar         : ;
    tkEnumeration  : begin
                       Value:=Node.Attributes['value'];
                       SetOrdProp(Result, Lowercase(Name),StrToInt(Value));
                     end;
    tkSet          : begin
                       Value:=Node.Attributes['value'];
                       SetOrdProp(Result, Lowercase(Name),StrToInt(Value));
                     end;
    tkClass        : begin
                       ClassName:=Node.Attributes['classname'];
                       uid:=Node.Attributes['uid'];
                     end;
    tkWChar        : ;
    tkLString      : begin
                       Value:=Node.NodeValue;
                       SetStrProp(Result, Lowercase(Name),Value);
                     end;
    tkWString      : begin
                       Value:=Node.NodeValue;
                       SetWideStrProp(Result, Lowercase(Name),Value);
                     end;
    tkVariant      : begin
                       Value:=Node.NodeValue;
                       SetVariantProp(Result, Lowercase(Name),Value);
                     end;
    tkArray        : ;
    tkRecord       : ;
    tkInterface    : ;
    tkInt64        : begin
                       Value:=Node.Attributes['value'];
                       SetInt64Prop(Result, Lowercase(Name),StrToInt(Value));
                     end;
    tkDynArray     : ;
    tkInteger      : begin
                       Value:=Node.Attributes['value'];
                       SetOrdProp(Result, Lowercase(Name),StrToInt(Value));
                     end;
    tkString       : begin
                       Value:=Node.NodeValue;
                       SetStrProp(Result, Lowercase(Name),Value);
                     end;
    tkFloat        : begin
                       Value:=Node.Attributes['value'];
                       SetFloatProp(Result, Lowercase(Name),StrToDateTime(Value));
                     end;
    tkMethod       : ;
    end;
  end;
  XML:=Nil;
  Node:=Nil;
  Node1:=Nil;
end;

Function ObjectToXml(aObject : TPersistObj):String;
var
  PListe  : PPropList;
  Name    : String;
  TypeData : PTypeData;
  i,j : integer;
  Str  : String;
  aObj : TPersistObj;
begin
  Result:='<'+aObject.ClassName+'>';

  TypeData := GetTypeData(PTypeInfo(aObject.ClassInfo));
  j:= TypeData^.PropCount;

  New(PListe);
  GetPropInfos(PTypeInfo(aObject.ClassInfo), PListe);

  for i:=0 to j-1 do
  begin
    Name := UpperCase(PListe^[I]^.Name);


    case PListe^[I]^.PropType^.Kind of
    tkUnknown      : Raise Exception.Create('Erreur');
    tkInteger      : begin
                       Str := IntToStr(GetOrdProp(aObject, PListe^[I]));
                       Result:=Result+'<'+Name+' TypeKind="tkInteger" value="'+str+'">';
                     end;
    tkChar         : ;
    tkEnumeration  : begin
                       Str := IntToStr(GetOrdProp(aObject, PListe^[I]));
                       Result:=Result+'<'+Name+' TypeKind="tkEnumeration" value="'+str+'"/>';
                     end;
    tkSet          : begin
                       Str := IntToStr(GetOrdProp(aObject, PListe^[I]));
                       Result:=Result+'<'+Name+' TypeKind="tkSet" value:="'+Str+'"/>';
                     end;
    tkClass        : begin
                       aObj:=TPersistObj(GetOrdProp(aObject, PListe^[I]));
                       Result:=Result+'<'+Name+' TypeKind="tkClass" classname="'+aObj.ClassName+'" uid="'+GuidToString(aObj.FGuid)+'"/>';
                     end;
    tkWChar        : Raise Exception.Create('Erreur');
    tkLString      : begin
                       Result:=Result+'<'+Name+' TypeKind="tkLString">';
                       Str := GetStrProp(aObject, PListe^[I]);
                       Result:=Result+Str;
                       Result:=Result+'</'+Name+'>';
                     end;
    tkWString      : begin
                       Result:=Result+'<'+Name+' TypeKind="tkWString">';
                       Str:=GetWideStrProp(aObject, PListe^[I]);
                       Result:=Result+Str;
                       Result:=Result+'</'+Name+'>';
                     end;
    tkVariant      : begin
                       Result:=Result+'<'+Name+' TypeKind="tkVariant">';
                       Str := GetVariantProp(aObject, PListe^[I]);
                       Result:=Result+Str;
                       Result:=Result+'</'+Name+'>';
                     end;
    tkArray        : Raise Exception.Create('Erreur');
    tkRecord       : Raise Exception.Create('Erreur');
    tkInterface    : Raise Exception.Create('Erreur');
    tkInt64        : begin
                       Str := IntToStr(GetInt64Prop(aObject, PListe^[I]));
                       Result:=Result+'<'+Name+' TypeKind="tkInt64" value="'+Str+'"/>';
                     end;
    tkDynArray     : Raise Exception.Create('Erreur');
    tkString       : begin
                       Result:=Result+'<'+Name+' TypeKind="tkString">';
                       Str := GetStrProp(aObject, PListe^[I]);
                       Result:=Result+Str;
                       Result:=Result+'</'+Name+'>';
                     end;
    tkFloat        : begin
                       Str := FloatToStr(GetFloatProp(aObject, PListe^[I]));
                       Result:=Result+'<'+Name+' TypeKind="tkFloat" value="'+Str+'"/>';
                     end;
    tkMethod       : Raise Exception.Create('Erreur');
    end;

  end;
  Dispose(PListe);
  Result:=Result+'</'+aObject.ClassName+'>';
end;


procedure Register;
begin
  RegisterComponents('Berkeley ODB', [TBerkeleyEnv]);
  RegisterComponents('Berkeley ODB', [TBerkeleyDB]);
end;

Var
  BerkeleyDBList : TObjectList;
initialization
  RegisterClass(TPersistObj);

  BerkeleyDBList :=TObjectList.create(True);

finalization
  BerkeleyDBList.Free;

end.
