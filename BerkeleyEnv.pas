{$Z4}
unit BerkeleyEnv;

interface
uses
  Windows, Contnrs, BerkeleyDB40520;

type
  TBerkeleyObject = class
  Private
    FLock : TRTLCriticalSection; 
  public
    Constructor create;
    Destructor Destroy; override;
    procedure EnterCriticalSection;
    procedure LeaveCriticalSection;
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

  TBerkeleyTXN = class;

  TBerkeleyEnv = class
  private
    FEnv : PDB_ENV;

    FEnvFlags  : TEnvFlagsSet;
    //Flock      : TDBLock;
    FActive    : Boolean;

    FHomeDir   : String;
    FLogDir    : String;
    FTmpDir    : String;

    FTransacts : TObjectList;

    Procedure SetActive(Value : Boolean);
    procedure SetHomeDir(const Value: String);
    procedure SetLogDir(const Value: String);
    procedure SetTmpDir(const Value: String);
  protected
    procedure AddToTXNList(Const TXN : TBerkeleyTXN);
    procedure RemoveFromTXNList(Const TXN : TBerkeleyTXN);
  public
    constructor Create;
    Destructor Destroy; override;

    Procedure Open;
    Procedure Close;

    property Env : PDB_ENV read FEnv;
  published
    property Active : boolean read FActive Write SetActive;
    property HomeDir   : String read FHomeDir write SetHomeDir;
    property LogDir    : String read FLogDir write SetLogDir;
    property TmpDir    : String read FTmpDir write SetTmpDir;
    property EnvFlags  : TEnvFlagsSet Read FEnvFlags write FEnvFlags;
  end;
  //
  //
  //
  TBerkeleyTXN = class(TBerkeleyObject)
  private
    FEnv : TBerkeleyEnv;
    FTXN : PDB_TXN;
    FFlags : Integer;
  public
    Constructor Create (Const Env : TBerkeleyEnv; Const Flags : Integer = 0);
    Destructor Destroy; override;
  end;



  //
  //
  //
  procedure ErrCall ( const Env : pointer{PDB_ENV};
                      const errpfx: PChar;
                      const Msg : PChar ); cdecl;

  function Check(err : Integer):boolean;

implementation
uses
  Sysutils, Dialogs;

procedure ErrCall ( const Env : pointer{PDB_ENV};
                    const errpfx: PChar;
                    const Msg : PChar ); cdecl;
begin
  ShowMessage(errpfx+' : '+Msg);
end;

function Check(err : Integer):boolean;
var
  ErrStr : String;
begin
  Result:=err = 0;
  if Err <> 0 then
  begin
    ErrStr:=_Db_Strerror(Err);
    Raise Exception.create('Error #'+IntToStr(Err)+' : '+ErrStr);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////

{ TBerkeleyObject }

constructor TBerkeleyObject.create;
begin
  Inherited Create;
  InitializeCriticalSection(FLock);
end;

destructor TBerkeleyObject.Destroy;
begin
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TBerkeleyObject.EnterCriticalSection;
begin
  Windows.EnterCriticalSection(FLock);
end;

procedure TBerkeleyObject.LeaveCriticalSection;
begin
  Windows.LeaveCriticalSection(FLock);
end;

////////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////

{ TBerkeleyEnv }

constructor TBerkeleyEnv.Create;
begin
  Inherited Create;
  FEnv:=Nil;

  //FLock:=TDBLock.create;
  FActive:=False;
  //FCacheSize := 32 * 1024;

  FTransacts:=TObjectList.create;
end;

Destructor TBerkeleyEnv.Destroy;
begin
  Close;
  FTransacts.Free;
  //FLock.free;
  inherited;
end;

Procedure TBerkeleyEnv.Open;
var
  Flags : Integer;
begin
  Factive:=False;

  (* Create an environment and initialize it for additional error reporting. *)
  Check(_db_Env_Create(FEnv));

  FEnv.set_errcall(FEnv,ErrCall);

  // Home dir
  if FHomeDir <> '' then
    Check(FEnv.set_data_dir(FEnv, Pchar(FHomeDir)));

  // Set LogDir
  If FLogDir <> '' then
    Check(FEnv.set_lg_dir(FEnv, Pchar(FlogDir)));

  // Set TMPdir
  If FTmpDir <> '' then
    Check(FEnv.set_tmp_dir(FEnv, Pchar(FTmpDir)));

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
  Check(FEnv.open(FEnv, Pchar(FHomeDir),Flags));

  Factive:=True;
end;

Procedure TBerkeleyEnv.Close;
begin
  if Assigned(FEnv) then
    Check(FEnv.close(FEnv));
  FEnv:=Nil;
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

procedure TBerkeleyEnv.SetHomeDir(const Value: String);
begin
  FHomeDir := Value;
  if Assigned(Fenv) then
    Check(FEnv.set_data_dir(FEnv, Pchar(FHomeDir)));

end;

procedure TBerkeleyEnv.SetLogDir(const Value: String);
begin
  FLogDir := Value;
  if Assigned(Fenv) then
    Check(FEnv.set_lg_dir(FEnv, Pchar(FHomeDir)));
end;

procedure TBerkeleyEnv.SetTmpDir(const Value: String);
begin
  FTmpDir := Value;
  if Assigned(Fenv) then
    Check(FEnv.set_tmp_dir(FEnv, Pchar(FHomeDir)));
end;

//
//
//
procedure TBerkeleyEnv.AddToTXNList(Const TXN : TBerkeleyTXN);
begin
  FTransacts.Add(TXN);
end;

procedure TBerkeleyEnv.RemoveFromTXNList(Const TXN : TBerkeleyTXN);
begin
  FTransacts.Extract(TXN);
end;



{ TBerkeleyTXN }

constructor TBerkeleyTXN.Create( const Env: TBerkeleyEnv;
                                 Const Flags : Integer = 0);
begin
  Inherited Create;
  FEnv:=Env;
  Fenv.AddToTXNList(Self);
  FFlags:=Flags;
  
  Fenv.Env.txn_begin(Fenv.Env,Nil,FTXN,Flags);
end;

destructor TBerkeleyTXN.Destroy;
begin
  Fenv.RemoveFromTXNList(Self);
  inherited;
end;

end.
