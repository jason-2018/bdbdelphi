{$Z4}
unit BerkeleyLib;

{ $L BerkeleyDB.Obj}
interface
uses
  Windows, OS, DBConst;
const
  dblib ='BerkeleyDB.dll';
type
   u_int8_t  = byte;
   Pu_int8_t = ^u_int8_t;
   int16_t   = smallint;
   u_int16_t = word;
   int32_t   = longint;
   Pint32_t  = ^int32_t;
   u_int32_t = longword;
   Pu_int32_t = ^u_int32_t;

   size_t    = longword;
   time_t    = longword;
   db_timeval_t = longword;
type
   u_char = byte;
   u_short = word;
   u_int = dword;
   u_long = dword;
   long   = longint;

type
  db_recno_t = u_int32_t;
  db_timeout_t = u_int32_t;
  db_pgno_t = u_int32_t;  { Page number type.  }

{$ifdef _WIN64}
type
   ssize_t = __int64;
{$else}
type
   ssize_t = longword;
{$endif}

  {
     Region offsets are currently limited to 32-bits.  I expect that's going
     to have to be fixed in the not-too-distant future, since we won't want to
     split 100Gb memory pools into that many different regions.
  }
  roff_t = u_int32_t;


type
  { Key/data structure -- a Data-Base Thang.  }
  PDBT = ^TDBT;
  TDBT = record
    {  data/size must be fields 1 and 2 for DB 1.85 compatibility. }
    data : pointer;   { Key/data  }
    size : u_int32_t; { key/data length  }
    ulen : u_int32_t; { RO: length of user buffer.  }
    dlen : u_int32_t; { RO: get/put record length.  }
    doff : u_int32_t; { RO: get/put record offset.  }
    flags : u_int32_t;
  end;


  {  Transactions and recovery. }
     db_recops = (DB_TXN_ABORT = 0,DB_TXN_APPLY = 1,
       DB_TXN_BACKWARD_ALLOC = 2,DB_TXN_BACKWARD_ROLL = 3,
       DB_TXN_FORWARD_ROLL = 4,DB_TXN_GETPGNOS = 5,
       DB_TXN_OPENFILES = 6,DB_TXN_POPENFILES = 7,
       DB_TXN_PRINT = 8);


  datum = record
    dptr : Pchar;
    dsize : size_t;
  end;

{
   Simple R/W lock modes and for multi-granularity intention locking.

   !!!
   These values are NOT random, as they are used as an index into the lock
   conflicts arrays, i.e., DB_LOCK_IWRITE must be == 3, and DB_LOCK_IREAD
   must be == 4.
  }
  db_lockmode_t = (
    DB_LOCK_NG = 0,       { Not granted.  }
    DB_LOCK_READ = 1,     { Shared/read.  }
    DB_LOCK_WRITE = 2,    { Exclusive/write.  }
    DB_LOCK_WAIT = 3,     { Wait for event  }
    DB_LOCK_IWRITE = 4,   { Intent exclusive/write.  }
    DB_LOCK_IREAD = 5,    { Intent to share/read.  }
    DB_LOCK_IWR = 6,      { Intent to read and write.  }
    DB_LOCK_DIRTY = 7,    { Dirty Read.  }
    DB_LOCK_WWRITE = 8    { Was Written.  }
    );
       
  PDB_FH = ^TDB_FH;


  {
     A DB_LSN has two parts, a fileid which identifies a specific file, and an
     offset within that file.  The fileid is an unsigned 4-byte quantity that
     uniquely identifies a file within the log directory -- currently a simple
     counter inside the log.  The offset is also an unsigned 4-byte value.  The
     log manager guarantees the offset is never more than 4 bytes by switching
     to a new log file before the maximum length imposed by an unsigned 4-byte
     offset is reached.
    }
  PDB_LSN = ^TDB_LSN;
  TDB_LSN = record
    fil : u_int32_t;      { File ID.  }
    offset : u_int32_t;   { File offset.  }
  end;

  PTXN_EVENT = Pointer; // ^__txn_event;
  PDB_TXNMGR = Pointer; // ^TDB_TXNMGR;
  PTXN_LOGREC= Pointer; //^__txn_logrec;

  { Transaction that has committed.  }
  PDB_TXN = ^TDB_TXN;
  TDB_TXN = record
    mgrp             : PDB_TXNMGR;              { Pointer to transaction manager.  }
    parent           : PDB_TXN;               { Pointer to transaction's parent.  }
    last_lsn         : TDB_LSN;             { Lsn of last log write.  }
    txnid            : u_int32_t;              { Unique transaction id.  }
    tid              : u_int32_t;                { Thread id for use in MT XA.  }
    off              : roff_t;                   { Detail structure within region.  }
    lock_timeout     : db_timeout_t;    { Timeout for locks for this txn.  }
    expire           : db_timeout_t;          { Time this txn expires.  }
    txn_list         : pointer;             { Undo information for parent.  }
    {
      !!!
      Explicit representations of structures from queue.h.
      TAILQ_ENTRY(Tdb_txn) links;
      TAILQ_ENTRY(TDb_txn) xalinks;
    }
    links            : record                  { Links transactions off manager.  }
                         tqe_next : PDB_TXN;
                         tqe_prev : ^PDB_TXN;
                       end;
    xalinks          : record                { Links active XA transactions.  }
                         tqe_next : PDB_TXN;
                         tqe_prev : ^PDB_TXN;
                       end;
    {
      !!!
      Explicit representations of structures from queue.h.
      TAILQ_HEAD(__events, __txn_event) events;
    }
    events : record
         tqh_first : PTXN_EVENT;
         tqh_last : ^PTXN_EVENT;
      end;
    logs : record                     { Links deferred events.  }
         stqh_first : Ptxn_logrec;
         stqh_last : ^Ptxn_logrec;
      end;
    kids : record
         tqh_first : PDB_TXN;
         tqh_last : ^PDB_TXN;
      end;
    klinks : record
         tqe_next : PDB_TXN;
         tqe_prev : ^PDB_TXN;
      end;
    api_internal : pointer;   { API-private structure: used by C++  }
    cursors : u_int32_t;      { Number of cursors open for txn  }
    abort : function (db  : PDB_TXN):longint;cdecl;
    commit : function (db  : PDB_TXN; _para2:u_int32_t):longint;cdecl;
    discard : function (db  : PDB_TXN; _para2:u_int32_t):longint; cdecl;
    id : function (db  : PDB_TXN):u_int32_t; cdecl;
    prepare : function (db  : PDB_TXN;var _para2:u_int8_t):longint; cdecl;
    set_timeout : function (db  : PDB_TXN; _para2:db_timeout_t; _para3:u_int32_t):longint; cdecl;
    flags : u_int32_t;
  end;



  {
     DB_LOCK --
    	The structure is allocated by the caller and filled in during a
    	lock_get request (or a lock_vec/DB_LOCK_GET).
    }
  TDB_LOCK = record
    off : size_t;           { Offset of the lock in the region  }
    ndx : u_int32_t;        { Index of the object referenced by
                                 this lock; used for locking.  }
    gen : u_int32_t;        { Generation number of this lock.  }
    mode : db_lockmode_t;   { mode of this lock.  }
  end;




  PPDB = ^PDB;
  PDB = ^TDB;
  

  PDB_ENV = ^TDB_ENV;
  TDB_ENV = record
    db_errfile         : ^FILE;
    db_errpfx          : Pchar;
    db_errcall         : procedure (_para1:Pchar; _para2:Pchar); cdecl;
    db_feedback        : procedure (db  : PDB_ENV; _para2:longint; _para3:longint); cdecl;
    db_paniccall       : procedure (db  : PDB_ENV; _para2:longint); cdecl;
    db_malloc          : function (_para1:size_t):pointer; cdecl;
    db_realloc         : function (_para1:pointer; _para2:size_t):pointer; cdecl;
    db_free            : procedure (_para1:pointer); cdecl;
    verbose            : u_int32_t;
    app_private        : pointer;
    app_dispatch       : function (db  : PDB_ENV; _para2:PDBT; _para3: PDB_LSN ; _para4:db_recops):longint; cdecl;
    lk_conflicts       : ^u_int8_t;
    lk_modes           : u_int32_t;
    lk_max             : u_int32_t;
    lk_max_lockers     : u_int32_t;
    lk_max_objects     : u_int32_t;
    lk_detect          : u_int32_t;
    lk_timeout         : db_timeout_t;
    lg_bsize           : u_int32_t;
    lg_size            : u_int32_t;
    lg_regionmax       : u_int32_t;
    mp_gbytes          : u_int32_t;
    mp_bytes           : u_int32_t;
    mp_size            : size_t;
    mp_ncache          : longint;
    mp_mmapsize        : size_t;
    mp_maxwrite        : longint;
    mp_maxwrite_sleep  : longint;
    rep_eid            : longint;
    rep_send           : function (db  : PDB_ENV; _para2:PDBT; _para3:PDBT; _para4:PDB_LSN; _para5:longint; _para6:u_int32_t):longint;  cdecl;
    tx_max             : u_int32_t;
    tx_timestamp       : time_t;
    tx_timeout         : db_timeout_t;
    db_home            : Pchar;
    db_log_dir         : Pchar;
    db_tmp_dir         : Pchar;
    db_data_dir        : ^Pchar;
    data_cnt           : longint;
    data_next          : longint;
    db_mode            : longint;
    open_flags         : u_int32_t;
    reginfo            : pointer;
    lockfhp            : PDB_FH;
    recover_dtab       : function (db  : PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; cdecl;
    recover_dtab_size  : size_t;
    cl_handle          : pointer;
    cl_id              : longint;
    db_ref             : longint;
    shm_key            : longint;
    tas_spins          : u_int32_t;
    dblist_mutexp      : Pointer; // PDB_MUTEX;
    dblist             : record
                           lh_first : PDB;
                         end;
    links              : record
                           tqe_next : PDB_ENV;
                           tqe_prev : ^PDB_ENV;
                         end;
    xa_txn             : record
                           tqh_first : pointer; //PDB_TXN;
                           tqh_last : ^Pointer;// ^PDB_TXN;
                         end;
    xa_rmid            : longint;
    api1_internal      : pointer;
    api2_internal      : pointer;
    passwd             : Pchar;
    passwd_len         : size_t;
    crypto_handle      : pointer;
    mt_mutexp          : Pointer; // PDB_MUTEX;
    mti                : longint;
    mt                 : ^u_long;
    close              : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    dbremove           : function  (db  : PDB_ENV; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:u_int32_t):longint; cdecl;
    dbrename           : function  (db  : PDB_ENV; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:Pchar; _para6:u_int32_t):longint; cdecl;
    err                : procedure (db  : PDB_ENV; _para2:longint; _para3:Pchar; args:array of const);cdecl;
    errx               : procedure (db  : PDB_ENV; _para2:Pchar; args:array of const);cdecl;
    get_home           : function  (db  : PDB_ENV; _para2:PPchar):longint; cdecl;
    get_open_flags     : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    open               : function  (db  : PDB_ENV; _para2:Pchar; _para3:u_int32_t; _para4:longint):longint; cdecl;
    remove             : function  (db  : PDB_ENV; _para2:Pchar; _para3:u_int32_t):longint; cdecl;
    set_alloc          : function  (db  : PDB_ENV; _para2: pointer; _para3: pointer; _para4:pointer):longint; cdecl;
    set_app_dispatch   : function  (db  : PDB_ENV; _para2: pointer):longint; cdecl;
    get_data_dirs      : function  (db  : PDB_ENV; var _para2:PPchar):longint; cdecl;
    set_data_dir       : function  (db  : PDB_ENV; _para2:Pchar):longint; cdecl;
    get_encrypt_flags  : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_encrypt        : function  (db  : PDB_ENV; _para2:Pchar; _para3:u_int32_t):longint; cdecl;
    set_errcall        : procedure (db  : PDB_ENV; _para2:Pointer); cdecl;
    get_errfile        : procedure (db  : PDB_ENV; _para2: Pointer {PPFILE}); cdecl;
    set_errfile        : procedure (db  : PDB_ENV; _para2: Pointer {PPFILE}); cdecl;
    get_errpfx         : procedure (db  : PDB_ENV; _para2: PPchar); cdecl;
    set_errpfx         : procedure (db  : PDB_ENV; _para2: Pchar); cdecl;
    set_feedback       : function  (db  : PDB_ENV; _para2: Pointer):longint; cdecl;
    get_flags          : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_flags          : function  (db  : PDB_ENV; _para2:u_int32_t; _para3:longint):longint; cdecl;
    set_paniccall      : function  (db  : PDB_ENV; _para2:Pointer):longint; cdecl;
    set_rpc_server     : function  (db  : PDB_ENV; _para2:pointer; _para3:Pchar; _para4:longint; _para5:longint; _para6:u_int32_t):longint; cdecl;
    get_shm_key        : function  (db  : PDB_ENV; _para2:Plongint):longint; cdecl;
    set_shm_key        : function  (db  : PDB_ENV; _para2:longint):longint; cdecl;
    get_tas_spins      : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_tas_spins      : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_tmp_dir        : function  (db  : PDB_ENV; _para2:PPchar):longint; cdecl;
    set_tmp_dir        : function  (db  : PDB_ENV; _para2:Pchar):longint; cdecl;
    get_verbose        : function  (db  : PDB_ENV; _para2:u_int32_t; _para3:Plongint):longint; cdecl;
    set_verbose        : function  (db  : PDB_ENV; _para2:u_int32_t; _para3:longint):longint; cdecl;
    lg_handle          : pointer;
    get_lg_bsize       : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lg_bsize       : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_lg_dir         : function  (db  : PDB_ENV; _para2:PPchar):longint; cdecl;
    set_lg_dir         : function  (db  : PDB_ENV; _para2:Pchar):longint; cdecl;
    get_lg_max         : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lg_max         : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_lg_regionmax   : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lg_regionmax   : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    log_archive        : function  (db  : PDB_ENV; _array:PPchar; _para3:u_int32_t):longint; cdecl;
    log_cursor         : function  (db  : PDB_ENV; var _para2: Pointer {PDB_LOGC}; _para3:u_int32_t):longint;
    log_file           : function  (db  : PDB_ENV; _para2:PDB_LSN; _para3:Pchar; _para4:size_t):longint; cdecl;
    log_flush          : function  (db  : PDB_ENV; _para2:PDB_LSN):longint; cdecl;
    log_put            : function  (db  : PDB_ENV; _para2:PDB_LSN; _para3:PDBT; _para4:u_int32_t):longint; cdecl;
    log_stat           : function  (db  : PDB_ENV; var _para2: Pointer {PDB_LOG_STAT}; _para3:u_int32_t):longint; cdecl;
    lk_handle          : pointer;
    get_lk_conflicts   : function  (db  : PDB_ENV; var _para2:u_int8_t; var _para3:longint):longint; cdecl;
    set_lk_conflicts   : function  (db  : PDB_ENV; var _para2:u_int8_t; _para3:longint):longint; cdecl;
    get_lk_detect      : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lk_detect      : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    set_lk_max         : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_lk_max_locks   : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lk_max_locks   : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_lk_max_lockers : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lk_max_lockers : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_lk_max_objects : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lk_max_objects : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    lock_detect        : function  (db  : PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:Plongint):longint; cdecl;
    lock_dump_region   : function  (db  : PDB_ENV; _para2:Pchar; _para3: Pointer {PFILE}):longint; cdecl;
    lock_get           : function  (db  : PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:PDBT; _para5:db_lockmode_t; _para6: Pointer {PDB_LOCK}):longint; cdecl;
    lock_put           : function  (db  : PDB_ENV; _para2: Pointer {PDB_LOCK}):longint; cdecl;
    lock_id            : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    lock_id_free       : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    lock_stat          : function  (db  : PDB_ENV; var _para2: Pointer {PDB_LOCK_STAT}; _para3:u_int32_t):longint; cdecl;
    lock_vec           : function  (db  : PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4: Pointer {PDB_LOCKREQ}; _para5:longint; var _para6: Pointer {PDB_LOCKREQ}):longint; cdecl;
    mp_handle          : pointer;
    get_cachesize      : function  (db  : PDB_ENV; var _para2:u_int32_t; var _para3:u_int32_t; var _para4:longint):longint; cdecl;
    set_cachesize      : function  (db  : PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:longint):longint; cdecl;
    get_mp_mmapsize    : function  (db  : PDB_ENV; var _para2:size_t):longint; cdecl;
    set_mp_mmapsize    : function  (db  : PDB_ENV; _para2:size_t):longint; cdecl;
    get_mp_maxwrite    : function  (db  : PDB_ENV; var _para2:longint; _para3:Plongint):longint; cdecl;
    set_mp_maxwrite    : function  (db  : PDB_ENV; _para2:longint; _para3:longint):longint; cdecl;
    memp_dump_region   : function  (db  : PDB_ENV; _para2:Pchar; _para3: Pointer {PFILE}):longint; cdecl;
    memp_fcreate       : function  (db  : PDB_ENV; var _para2: Pointer {PDB_MPOOLFILE}; _para3:u_int32_t):longint; cdecl;
    memp_register      : function  (db  : PDB_ENV; _para2:longint; _para3:Pointer; _para4:Pointer):longint; cdecl;
    memp_stat          : function  (db  : PDB_ENV; var _para2: Pointer {PDB_MPOOL_STAT}; var _para3: Pointer {PDB_MPOOL_FSTAT}; _para4:u_int32_t):longint; cdecl;
    memp_sync          : function  (db  : PDB_ENV; _para2:PDB_LSN):longint; cdecl;
    memp_trickle       : function  (db  : PDB_ENV; _para2:longint; _para3:Plongint):longint; cdecl;
    rep_handle         : pointer;
    rep_elect          : function  (db  : PDB_ENV; _para2:longint; _para3:longint; _para4:u_int32_t; _para5:Plongint):longint; cdecl;
    rep_flush          : function  (db  : PDB_ENV):longint; cdecl;
    rep_process_message: function  (db  : PDB_ENV; _para2:PDBT; _para3:PDBT; _para4:Plongint; _para5:PDB_LSN):longint; cdecl;
    rep_start          : function  (db  : PDB_ENV; _para2:PDBT; _para3:u_int32_t):longint; cdecl;
    rep_stat           : function  (db  : PDB_ENV; var _para2: Pointer {PDB_REP_STAT}; _para3:u_int32_t):longint; cdecl;
    get_rep_limit      : function  (db  : PDB_ENV; var _para2:u_int32_t; var _para3:u_int32_t):longint; cdecl;
    set_rep_limit      : function  (db  : PDB_ENV; _para2:u_int32_t; _para3:u_int32_t):longint; cdecl;
    set_rep_request    : function  (db  : PDB_ENV; _para2:u_int32_t; _para3:u_int32_t):longint; cdecl;
    set_rep_transport  : function  (db  : PDB_ENV; _para2:longint; _para3:pointer):longint; cdecl;
    tx_handle          : pointer;
    get_tx_max         : function  (db  : PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_tx_max         : function  (db  : PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_tx_timestamp   : function  (db  : PDB_ENV; var _para2:time_t):longint; cdecl;
    set_tx_timestamp   : function  (db  : PDB_ENV; var _para2:time_t):longint; cdecl;
    txn_begin          : function  (db  : PDB_ENV; _para2:PDB_TXN; var _para3:PDB_TXN; _para4:u_int32_t):longint; cdecl;
    txn_checkpoint     : function  (db  : PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:u_int32_t):longint; cdecl;
    txn_recover        : function  (db  : PDB_ENV; _para2: Pointer {PDB_PREPLIST}; _para3:longint; _para4:Plongint; _para5:u_int32_t):longint; cdecl;
    txn_stat           : function  (db  : PDB_ENV; var _para2: Pointer {PDB_TXN_STAT}; _para3:u_int32_t):longint; cdecl;
    get_timeout        : function  (db  : PDB_ENV; var _para2:db_timeout_t; _para3:u_int32_t):longint; cdecl;
    set_timeout        : function  (db  : PDB_ENV; _para2:db_timeout_t; _para3:u_int32_t):longint; cdecl;
    test_abort         : longint;
    test_copy          : longint;
    flags              : u_int32_t;
  end;



  TSysGetMem = function (Size: Integer): Pointer; cdecl;
  TSysFreeMem = function (P: Pointer): Integer; cdecl;
  TSysReallocMem = function (P: Pointer; Size: Integer): Pointer; cdecl;

  TDBTYPE = (DB_BTREE = 1,DB_HASH = 2,DB_RECNO = 3, DB_QUEUE = 4,DB_UNKNOWN = 5);


  TAssociateFunc = function (param1 : PDB; const Param2 : PDBT; const param3 : PDBT ; Param4 : PDBT ):longint;

  TDB = record
	  pgsize                 : u_int32_t;		(* Database logical page size. *)

	  db_append_recno        : function  (db  : PDB; _para2:PDBT;    _para3:db_recno_t):longint; cdecl;
    db_feedback            : procedure (db  : PDB; _para2:longint; _para3:longint); cdecl;
    dup_compare            : function  (db  : PDB; _para2:PDBT;    _para3:PDBT):longint; cdecl;

    app_private            : pointer;
    dbenv                  : PDB_ENV;
    _type                  : TDBTYPE;
    mpf                    : Pointer; // PDB_MPOOLFILE;
    mutexp                 : Pointer; //PDB_MUTEX;
    fname                  : Pchar;
    dname                  : Pchar;
    open_flags             : u_int32_t;
    fileid                 : array[0..(DB_FILE_ID_LEN)-1] of u_int8_t;
    adj_fileid             : u_int32_t;
    log_filename           : Pchar; //PFNAME;

    meta_pgno              : db_pgno_t;
    lid                    : u_int32_t;
    cur_lid                : u_int32_t;
    associate_lid          : u_int32_t;
    handle_lock            : TDB_LOCK;
    cl_id                  : longint;
    timestamp              : time_t;
    my_rskey               : TDBT;
    my_rkey                : TDBT;
    my_rdata               : TDBT;
    saved_open_fhp         : PDB_FH;
    dblistlinks            : record
                               le_next : PDB;
                               le_prev : ^PDB;
                             end;
    free_queue             : record
                               tqh_first: Pointer; //PDBC;
                               tqh_last : ^Pointer; //^PDBC;
                             end;
    active_queue           : record
                               tqh_first: Pointer; //PDBC;
                               tqh_last : ^Pointer; //^PDBC;
                             end;
    join_queue             : record
                               tqh_first: Pointer; //PDBC;
                               tqh_last : ^Pointer; //^PDBC;
                             end;
    s_secondaries          : record
                               lh_first : PDB;
                             end;
    s_links                : record
                               le_next : PDB;
                               le_prev : ^PDB;
                             end;
    s_refcnt               : u_int32_t;
    s_callback             : function (db  : PDB; _para2:PDBT; _para3:PDBT; _para4:PDBT):longint; cdecl;
    s_primary              : PDB;
    api_internal           : pointer;
    bt_internal            : pointer;
    h_internal             : pointer;
    q_internal             : pointer;
    xa_internal            : pointer;

    associate              : function (db  : PDB; _para2:PDB_TXN; _para3:PDB; _para4: TAssociateFunc; _para5:u_int32_t):longint; cdecl;
    close                  : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    cursor                 : function (db  : PDB; _para2:PDB_TXN; var _para3: pointer {PDBC}; _para4:u_int32_t):longint; cdecl;
    del                    : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4:u_int32_t):longint; cdecl;
    err                    : procedure(db  : PDB; _para2:longint; _para3:Pchar; args:array of const); cdecl;
    errx                   : procedure(db  : PDB; _para2:Pchar; args:array of const); cdecl;
    fd                     : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get                    : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5 :u_int32_t):longint; cdecl;
    pget                   : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:PDBT; _para6:u_int32_t):longint; cdecl;
    get_byteswapped        : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get_cachesize          : function (db  : PDB; var _para2: u_int32_t; var _para3: u_int32_t; var _para4:longint):longint; cdecl;
    get_dbname             : function (db  : PDB; _para2:PPchar; _para3:PPchar):longint; cdecl;
    get_encrypt_flags      : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_env                : function (db  : PDB; _para2: Pointer {PPDB_ENV}):longint; cdecl;
    get_errfile            : procedure(db  : PDB; _para2: Pointer {PPFILE} ); cdecl;
    get_errpfx             : procedure(db  : PDB; _para2:PPchar); cdecl;
    get_flags              : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_lorder             : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get_open_flags         : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_pagesize           : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_transactional      : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get_type               : function (db  : PDB; var _para2:TDBTYPE):longint; cdecl;
    join                   : function (db  : PDB; _para2: Pointer {PPDBC}; _para3: Pointer {PPDBC}; _para4:u_int32_t):longint; cdecl;
    key_range              : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4: Pointer{PDB_KEY_RANGE}; _para5:u_int32_t):longint; cdecl;
    open                   : function (db  : PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:TDBTYPE; _para6:u_int32_t; _para7:longint):longint; cdecl;
    put                    : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint; cdecl;
    remove                 : function (db  : PDB; _para2:Pchar; _para3:Pchar; _para4:u_int32_t):longint; cdecl;
    rename                 : function (db  : PDB; _para2:Pchar; _para3:Pchar; _para4:Pchar; _para5:u_int32_t):longint; cdecl;
    truncate               : function (db  : PDB; _para2:PDB_TXN; var _para3: u_int32_t; _para4:u_int32_t):longint; cdecl;
    set_append_recno       : function (db  : PDB; _para2: Pointer):longint; cdecl; //para2 : function (db  : PDB; _para2:PDBT; _para3:db_recno_t):longint
    set_alloc              : function (db  : PDB; _para2: TSysGetMem; _para3: TSysReallocMem; _para4:TSysFreeMem):longint; cdecl; // Pprocedure (_para1:size_t)
    set_cachesize          : function (db  : PDB; _para2:u_int32_t; _para3:u_int32_t; _para4:longint):longint; cdecl;
    set_dup_compare        : function (db  : PDB; _para2: Pointer):longint; //function (db  : PDB; _para2:PDBT; _para3:PDBT):longint
    set_encrypt            : function (db  : PDB; _para2:Pchar; _para3:u_int32_t):longint; cdecl;
    set_errcall            : procedure(db  : PDB; _para2: Pointer); cdecl; //procedure (_para1:Pchar; _para2:Pchar)
    set_errfile            : procedure(db  : PDB; _para2: Pointer {PFILE}); cdecl;
    set_errpfx             : procedure(db  : PDB; _para2:Pchar); cdecl;
    set_feedback           : function (db  : PDB; _para2: Pointer):longint;  cdecl;//procedure (db  : PDB; _para2:longint; _para3:longint)
    set_flags              : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_lorder             : function (db  : PDB; _para2:longint):longint; cdecl;
    set_pagesize           : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_paniccall          : function (db  : PDB; _para2: pointer):longint; cdecl; //procedure (db  : PDB_ENV; _para2:longint)
    stat                   : function (db  : PDB; _para2:pointer; _para3:u_int32_t):longint; cdecl;
    sync                   : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    upgrade                : function (db  : PDB; _para2:Pchar; _para3:u_int32_t):longint; cdecl;
    verify                 : function (db  : PDB; _para2:Pchar; _para3:Pchar; _para4: Pointer {PFILE}; _para5:u_int32_t):longint; cdecl;
    get_bt_minkey          : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    set_bt_compare         : function (db  : PDB; _para2: pointer):longint; cdecl; //function (db  : PDB; _para2:PDBT; _para3:PDBT):longint
    set_bt_maxkey          : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_bt_minkey          : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_bt_prefix          : function (db  : PDB; _para2: pointer):longint; cdecl; //function (db  : PDB; _para2:PDBT; _para3:PDBT):size_t
    get_h_ffactor          : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_h_nelem            : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    set_h_ffactor          : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_h_hash             : function (db  : PDB; _para2:pointer):longint; cdecl; //function (db  : PDB; _para2:pointer; _para3:u_int32_t):u_int32_t
    set_h_nelem            : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    get_re_delim           : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get_re_len             : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_re_pad             : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get_re_source          : function (db  : PDB; _para2:PPchar):longint; cdecl;
    set_re_delim           : function (db  : PDB; _para2:longint):longint; cdecl;
    set_re_len             : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_re_pad             : function (db  : PDB; _para2:longint):longint; cdecl;
    set_re_source          : function (db  : PDB; _para2:Pchar):longint; cdecl;
    get_q_extentsize       : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    set_q_extentsize       : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    db_am_remove           : function (db  : PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:PDB_LSN):longint; cdecl;
    db_am_rename           : function (db  : PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:Pchar):longint; cdecl;
    stored_get             : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint; cdecl;
    stored_close           : function (db  : PDB; _para2:u_int32_t):longint; cdecl;

    am_ok                  : u_int32_t;
    orig_flags             : u_int32_t;
    flags                  : u_int32_t;
  end;



  DBM = Pointer;
  PDBM = ^DBM;

  PPAGE = Pointer;
  PVRFY_DBINFO = pointer;
  PREGENV = Pointer;
  PREGION = pointer;
  PREGINFO = Pointer;
  PDBC = Pointer;
  PFILE = Pointer;
  PDB_MUTEX = Pointer;


	db_ca_mode= (DB_CA_DI	= 1,
	             DB_CA_DUP	= 2,
	             DB_CA_RSPLIT	= 3,
	             DB_CA_SPLIT	= 4
  );


  function _db_create(var _para1: PDB; _para2:PDB_ENV; _para3:u_int32_t):longint; cdecl;
  function _db_strerror(_para1:longint):Pchar; cdecl;
  function _db_version(_para1:Plongint; _para2:Plongint; _para3:Plongint):Pchar; cdecl;
  function _log_compare(_para1:PDB_LSN; _para2:PDB_LSN):longint; cdecl;
  function _db_env_set_func_close(_para1:Pointer):longint; cdecl;
  function _db_env_set_func_dirfree(_para1:Pointer):longint; cdecl;
  function _db_env_set_func_dirlist(_para1:pointer):longint; cdecl;
  function _db_env_set_func_exists(_para1:pointer):longint; cdecl;
  function _db_env_set_func_free(_para1:TSysFreeMem):longint; cdecl;
  function _db_env_set_func_fsync(_para1:Pointer):longint; cdecl;
  function _db_env_set_func_ioinfo(_para1:pointer):longint; cdecl;
  function _db_env_set_func_malloc(_para1:TSysGetMem):longint; cdecl;
  function _db_env_set_func_map(_para1:Pointer):longint;  cdecl;
  function _db_env_set_func_open(_para1:Pointer):longint; cdecl;
  function _db_env_set_func_read(_para1:Pointer):longint; cdecl;
  function _db_env_set_func_realloc(_para1:TSysReallocMem):longint; cdecl;
  function _db_env_set_func_rename(_para1:Pointer):longint; cdecl;
  function _db_env_set_func_seek(_para1:Pointer):longint;  cdecl;
  function _db_env_set_func_sleep(_para1:Pointer):longint;  cdecl;
  function _db_env_set_func_unlink(_para1:Pointer):longint; cdecl;
  function _db_env_set_func_unmap(_para1:Pointer):longint; cdecl;
  function _db_env_set_func_write(_para1:Pointer):longint; cdecl;
  function _db_env_set_func_yield(_para1:Pointer):longint; cdecl;

  function  ___db_ndbm_clearerr( _para1:DBM):longint; cdecl;
  procedure ___db_ndbm_close( _para1:DBM); cdecl;
  function  ___db_ndbm_delete( _para1:DBM; _para2:datum):longint; cdecl;
  function  ___db_ndbm_dirfno( _para1:DBM):longint; cdecl;
  function  ___db_ndbm_error( _para1:DBM):longint;  cdecl;
  function  ___db_ndbm_fetch( _para1:DBM; _para2:datum):datum; cdecl;
  function  ___db_ndbm_firstkey( _para1:DBM):datum; cdecl;
  function  ___db_ndbm_nextkey( _para1:DBM):datum; cdecl;
  function  ___db_ndbm_open(_para1:Pchar; _para2:longint; _para3:longint):PDBM; cdecl;
  function  ___db_ndbm_pagfno( _para1:DBM):longint; cdecl;
  function  ___db_ndbm_rdonly( _para1:DBM):longint; cdecl;
  function  ___db_ndbm_store( _para1:DBM; _para2:datum; _para3:datum; _para4:longint):longint; cdecl;

  function  ___db_dbm_close:longint; cdecl;
  //function  ___db_dbm_dbrdonly:longint; cdecl;
  function  ___db_dbm_delete(_para1:datum):longint; cdecl;
  //function  ___db_dbm_dirf:longint; cdecl;
  function  ___db_dbm_fetch(_para1:datum):datum; cdecl;
  function  ___db_dbm_firstkey:datum; cdecl;
  function  ___db_dbm_init(_para1:Pchar):longint; cdecl;
  function  ___db_dbm_nextkey(_para1:datum):datum; cdecl;
  //function  ___db_dbm_pagf:longint; cdecl;
  function  ___db_dbm_store(_para1:datum; _para2:datum):longint; cdecl;


  function ___bam_cmp (db : PDB; const dbt : PDBT; page : PPAGE; P4:u_int32_t; p5 : pointer;var p6: integer): integer; cdecl;
  function ___bam_defcmp (db : PDB; const dbt : PDBT; const dbt1 : PDBT):integer; cdecl;
  function ___bam_pgin (env : PDB_ENV; db : PDB; pgno : db_pgno_t; page : PPAGE; dbt : PDBT):integer;cdecl;
  function ___bam_pgout (env : PDB_ENV; db : PDB; pgno : db_pgno_t; page : PPAGE; dbt : PDBT):integer;cdecl;
  function ___bam_ca_delete (db : PDB; pgno : db_pgno_t; p3:u_int32_t; p4: integer):integer;cdecl;
  function ___ram_ca_delete (db : PDB; pgno : db_pgno_t):integer;cdecl;
  function ___bam_ca_di (dbc : PDBC; pgno : db_pgno_t; p3:u_int32_t; p4:integer):integer;cdecl;
  function ___bam_cdel_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; p4:u_int32_t; pgno : db_pgno_t; lsn1: PDB_LSN; p6:u_int32_t):integer;cdecl;
  function ___bam_curadj_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; p4:u_int32_t; p5: db_ca_mode; pgno : db_pgno_t; pgno1 : db_pgno_t; pgno2 : db_pgno_t; p8:u_int32_t; p9: u_int32_t; p10:u_int32_t):integer;cdecl;
  function ___bam_init_print (env : PDB_ENV; p2 : Pointer; var size : size_t):integer;cdecl;
  function ___bam_init_recover (env : PDB_ENV; p2: Pointer; var size : size_t): integer ;cdecl;

  function  ___dbreg_init_print (env : PDB_ENV; p2:pointer; var size : size_t):integer;cdecl;
  function  ___crdel_init_print (env : PDB_ENV; p2:pointer; var size : size_t):integer;cdecl;

  function  ___db_hcreate(_para1:size_t):longint; cdecl;
  //function ___db_hsearch(_para1:TENTRY; _para2:ACTION):PENTRY; cdecl;
  procedure ___db_hdestroy; cdecl;
  function  ___db_isbigendian ():integer;cdecl;
  function  ___db_fnl (const env : PDB_ENV; const p2:PChar): integer;cdecl;
  function  ___db_panic_msg (env : PDB_ENV):integer;cdecl;
  function  ___db_panic (p1: PDB_ENV; p2:integer):integer;cdecl;
  function  ___db_getlong (p1 : PDB_ENV; const p2 : PChar; p3: PChar; p4: longint; p5: longint; var p6: longint):integer;cdecl;
  function  ___db_getulong (p1 : PDB_ENV; const p2 :PChar; p3: PChar; p4: u_long; p5: u_long; var p6: u_long ):integer;  cdecl;
  function  ___db_util_cache (p1 : PDB_ENV; db : PDB; var p3 : u_int32_t;var p4 : integer):integer;
  function  ___db_util_logset (const p1: PChar; p2: PChar):integer;cdecl;
  procedure ___db_util_siginit ();cdecl;
  function  ___db_util_interrupted ():integer;cdecl;
  procedure ___db_util_sigresend ();cdecl;
  function  ___db_close (db : PDB; txn : PDB_TXN; p3: u_int32_t):integer;cdecl;
  function  ___db_put (db : PDB; txn : PDB_TXN; dbt : PDBT; dbt2 : PDBT; p5:u_int32_t):integer;cdecl;
  function  ___db_del (db : PDB; txn : PDB_TXN; dbt : PDBT; p4:u_int32_t):integer;cdecl;
  function  ___db_associate (db : PDB; txn : PDB_TXN; db2 : PDB; p4:pointer; p5:u_int32_t):Integer;cdecl;
  function  ___db_pg_alloc_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; p4: u_int32_t; lsn1 : PDB_LSN; pgno : db_pgno_t; lsn2 : PDB_LSN; pgno1 : db_pgno_t; p9:u_int32_t; pgno2 :db_pgno_t):integer;cdecl;
  function  ___db_pg_freedata_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; P4: u_int32_t; pgno : db_pgno_t; lsn1 : PDB_LSN; pgno1 : db_pgno_t; const dbt : PDBT; pgno2 : db_pgno_t; const dbt1 : PDBT):integer;cdecl;
  function  ___db_init_print (env : PDB_ENV; p2:Pointer; var size : size_t):integer;cdecl;
  function  ___db_c_count (dbc : PDBC; var recno : db_recno_t):integer;cdecl;
  function  ___db_c_dup (dbc : PDBC; dbc1 : PDBC; p3: u_int32_t):integer;cdecl;
  function  ___db_c_get (dbc : PDBC; dbt : PDBT; dbt1 : PDBT; p4: u_int32_t):integer;cdecl;
  function  ___db_pgin (env : PDB_ENV; p2: db_pgno_t; void : pointer; dbt : PDBT):integer;cdecl;
  function  ___db_pgout (env : PDB_ENV; p2: db_pgno_t; void : pointer; dbt : PDBT):integer;cdecl;
  function  ___db_dispatch (env : PDB_ENV; p2:Pointer; p3:size_t; dbt : PDBT; lsn : PDB_LSN; p6:db_recops; void : pointer):integer;cdecl;
  function  ___db_add_recovery (env : PDB_ENV; p2: Pointer; var size : size_t; P4 : Pointer; p5 : u_int32_t):integer;cdecl;
  function  ___db_associate_pp (db : PDB; txn : PDB_TXN; db1 : PDB; p : Pointer; p2:u_int32_t):integer;cdecl;
  function  ___db_close_pp (db : PDB; p2: u_int32_t):integer;cdecl;
  function  ___db_cursor_pp (db : PDB; txn : PDB_TXN; dbc : PDBC; p4: u_int32_t):integer;cdecl;
  function  ___db_del_pp (db : PDB; txn : PDB_TXN; dbt : PDBT; p4:u_int32_t):integer;cdecl;
  function  ___db_fd_pp (db : PDB; var p2: integer):integer;cdecl;
  function  ___db_get_pp (db : PDB; txn : PDB_TXN; dbt : PDBT; dbt1 : PDBT; p5: u_int32_t):integer;cdecl;
  function  ___db_join_pp (db : PDB; dbc : PDBC; dbc1 : PDBC; p4:u_int32_t):integer;cdecl;
  function  ___db_key_range_pp (db : PDB; txn : PDB_TXN; dbt : PDBT; p4: Pointer{PDB_KEY_RANGE}; p5: u_int32_t):integer;cdecl;
  function  ___db_open_pp (db : PDB; txn : PDB_TXN; const p3:Pchar; const p4:Pchar; p5:TDBTYPE; p6:u_int32_t; p7:integer): integer;cdecl;
  function  ___db_pget_pp (db : PDB; txn : PDB_TXN; dbt : PDBT; dbt1 : PDBT; dbt2 : PDBT; p6:u_int32_t):integer;cdecl;
  procedure ___db_loadme ();cdecl;
  function  ___db_dump (db : PDB; p2:Pchar; p3:Pchar):integer;cdecl;
  procedure ___db_inmemdbflags (u_int32_t, void : pointer; p3:Pointer);cdecl;
  function  ___db_prdbt (dbt : PDBT; p2:integer; const p3: Pchar; void : pointer; p5 : pointer; p6: integer; p7 : PVRFY_DBINFO):integer;cdecl;
  function  ___db_prheader (db : PDB; p1:Pchar; p2:integer; p3: integer; void : pointer; p4:Pointer; p5 : PVRFY_DBINFO; P6: db_pgno_t):integer;cdecl;
  function  ___db_prfooter (void : pointer; p2:Pointer):integer;cdecl;
  function  ___db_pr_callback (void : pointer; const void2 : pointer):integer;cdecl;
  function  ___db_verify_internal (db : PDB; const p2: Pchar; const p3:Pchar; void : pointer; p4:Pointer; p5: u_int32_t):Integer;cdecl;
  function  ___db_overwrite (env : PDB_ENV; const p2:Pchar):integer;cdecl;
  function  ___db_e_stat (env : PDB_ENV; regenv : PREGENV; region : PREGION; var P4:integer; p5: u_int32_t):integer;cdecl;
  function  ___db_r_attach (env : PDB_ENV; reginfo: PREGINFO; p3: size_t):integer;cdecl;
  function  ___db_r_detach (env : PDB_ENV; p2: PREGINFO; p3:integer):integer;cdecl;
  function  ___db_win32_mutex_init (env : PDB_ENV; mutex : PDB_MUTEX; p3:u_int32_t):integer;cdecl;
  function  ___db_win32_mutex_lock (env : PDB_ENV; mutex : PDB_MUTEX):integer;cdecl;
  function  ___db_win32_mutex_unlock (env : PDB_ENV; mutex : PDB_MUTEX):integer;cdecl;

  function  ___fop_init_print (env : PDB_ENV; p2: Pointer; var size : size_t):integer ;cdecl;

  function  ___ham_init_print (env : PDB_ENV; p2:Pointer; var size : size_t):integer;cdecl;
  function  ___ham_pgin (env : PDB_ENV; db : PDB; pgno : db_pgno_t; void : pointer; dbt : PDBT):integer;cdecl;
  function  ___ham_pgout (env : PDB_ENV; db : PDB; pgno : db_pgno_t; void : pointer; dbt : PDBT):integer;cdecl;
  function  ___ham_func2 (db : PDB; const void : pointer; p3:u_int32_t):u_int32_t;cdecl;
  function  ___ham_func3 (db : PDB; const void : pointer; p3:u_int32_t):u_int32_t;cdecl;
  function  ___ham_func4 (db : PDB; const void : pointer; p3:u_int32_t):u_int32_t;cdecl;
  function  ___ham_func5 (db : PDB; const void : pointer; p3:u_int32_t):u_int32_t;cdecl;
  function  ___ham_test  (db : PDB; const void : pointer; p3:u_int32_t):u_int32_t;cdecl;
  function  ___ham_get_meta (dbc : PDBC):integer;cdecl;
  function  ___ham_release_meta (dbc : PDBC):integer;cdecl;

  function  ___lock_open (env : PDB_ENV):integer;cdecl;
  function  ___lock_id_set (env : PDB_ENV; p2: u_int32_t; p3: u_int32_t):integer;cdecl;
  function  ___lock_dump_region (env : PDB_ENV; const p2: Pchar; p3:PFILE ):Integer;cdecl;

  function  ___memp_dump_region (env : PDB_ENV; const p2:Pchar; p3:PFILE): integer;cdecl;


  function  ___os_umalloc (env : PDB_ENV; size : size_t; void : pointer):integer;cdecl;
  procedure ___os_ufree (env : PDB_ENV; void : pointer);cdecl;
  function  ___os_strdup (env : PDB_ENV; const Pchar; void : pointer):integer;cdecl;
  function  ___os_calloc (env : PDB_ENV; size : size_t; size2 : size_t; void : pointer):integer;cdecl;
  function  ___os_malloc (env : PDB_ENV; size : size_t; void : pointer):integer;cdecl;
  function  ___os_realloc (env : PDB_ENV; size : size_t; void : pointer):integer;cdecl;
  procedure ___os_free (env : PDB_ENV; void : pointer);cdecl;
  function  ___os_clock (env : PDB_ENV; var p2:u_int32_t; var p3: u_int32_t):integer;cdecl;
  function  ___os_get_errno ():integer;cdecl;
  procedure ___os_set_errno (p1:integer);cdecl;
  function  ___os_openhandle (env : PDB_ENV; const p2: Pchar; p3: integer;p4: integer; var fh : PDB_FH):integer;cdecl;
  function  ___os_closehandle (env : PDB_ENV; fh : PDB_FH):integer;cdecl;
  procedure ___os_id (var p1: u_int32_t);cdecl;
  function  ___db_omode (const p1:Pchar): integer;cdecl;
  function  ___os_open (env : PDB_ENV; const p2:Pchar; p3:u_int32_t; p4: integer; var fh : PDB_FH):integer;cdecl;
  function  ___db_rpath (const Pchar):Pchar;cdecl;
  function  ___os_read (env : PDB_ENV; fh : PDB_FH; void : pointer; size : size_t; var size2 : size_t):integer;cdecl;
  function  ___os_write (env : PDB_ENV; fh : PDB_FH; void : pointer; size : size_t; var size2 : size_t):integer;cdecl;
  function  ___os_sleep (env : PDB_ENV; p2:u_long; p3: u_long):integer;cdecl;
  procedure ___os_yield (env:PDB_ENV; p2: u_long);cdecl;
  function  ___os_ioinfo (env : PDB_ENV; const p2: Pchar; fh : PDB_FH; var p4 : u_int32_t; var p5 : u_int32_t; var p : u_int32_t):integer;cdecl;

  function  ___qam_init_print (env : PDB_ENV; p2 : pointer; var size : size_t):integer;cdecl;
  function  ___qam_pgin_out (env : PDB_ENV; pgno : db_pgno_t; void : pointer; dbt : PDBT):integer;cdecl;

  function  ___txn_init_print (env : PDB_ENV; p2:pointer; var size : size_t):integer;cdecl;
  function  ___txn_id_set (env : PDB_ENV; p2: u_int32_t; p3: u_int32_t):integer;cdecl;


implementation


  function _db_create             ;     external  dblib; //name '_db_create'              ;
  //function db_env_create          ;   external  dblib; //name name '_db_env_create'          ;
  function _db_strerror            ;    external  dblib; //name name '_db_strerror'            ;
  function _db_version             ;    external  dblib; //name name '_db_version'             ;



  function _log_compare            ;    external  dblib; //name name '_log_compare'            ;

  function _db_env_set_func_close  ;    external  dblib; //name name '_db_env_set_func_close'  ;
  function _db_env_set_func_dirfree;    external  dblib; //name name '_db_env_set_func_dirfree';
  function _db_env_set_func_dirlist;    external  dblib; //name name '_db_env_set_func_dirlist';
  function _db_env_set_func_exists ;    external  dblib; //name name '_db_env_set_func_exists' ;
  function _db_env_set_func_free   ;    external  dblib; //name name '_db_env_set_func_free'   ;
  function _db_env_set_func_fsync  ;    external  dblib; //name name '_db_env_set_func_fsync'  ;
  function _db_env_set_func_ioinfo ;    external  dblib; //name name '_db_env_set_func_ioinfo' ;
  function _db_env_set_func_malloc ;    external  dblib; //name name '_db_env_set_func_malloc' ;
  function _db_env_set_func_map    ;    external  dblib; //name name '_db_env_set_func_map'    ;
  function _db_env_set_func_open   ;    external  dblib; //name name '_db_env_set_func_open'   ;
  function _db_env_set_func_read   ;    external  dblib; //name name '_db_env_set_func_read'   ;
  function _db_env_set_func_realloc;    external  dblib; //name name '_db_env_set_func_realloc';
  function _db_env_set_func_rename ;    external  dblib; //name name '_db_env_set_func_rename' ;
  function _db_env_set_func_seek   ;    external  dblib; //name name '_db_env_set_func_seek'   ;
  function _db_env_set_func_sleep  ;    external  dblib; //name name '_db_env_set_func_sleep'  ;
  function _db_env_set_func_unlink ;    external  dblib; //name name '_db_env_set_func_unlink' ;
  function _db_env_set_func_unmap  ;    external  dblib; //name name '_db_env_set_func_unmap'  ;
  function _db_env_set_func_write  ;    external  dblib; //name name '_db_env_set_func_write'  ;
  function _db_env_set_func_yield  ;    external  dblib; //name name '_db_env_set_func_yield'  ;

	function  ___db_dbm_close	        ;   external dblib; // name '___db_dbm_close'         ;
	function  ___db_dbm_delete	      ;   external dblib; // name '___db_dbm_delete'        ;
	function  ___db_dbm_fetch	        ;   external dblib; // name '___db_dbm_fetch'         ;
	function  ___db_dbm_firstkey      ;	  external dblib; // name '___db_dbm_firstkey'      ;
	function  ___db_dbm_init	        ;   external dblib; // name '___db_dbm_init'          ;
	function  ___db_dbm_nextkey	      ;   external dblib; // name '___db_dbm_nextkey'       ;
	function  ___db_dbm_store	        ;   external dblib; // name '___db_dbm_store'         ;
	//function __db_hsearch	          ;   external dblib; // name '___db_hsearch'           ;
  function  ___db_ndbm_clearerr     ;   external dblib; // name '___db_ndbm_clearerr'     ;
	procedure ___db_ndbm_close	      ;   external dblib; // name '___db_ndbm_close'        ;
	function  ___db_ndbm_delete	      ;   external dblib; // name '___db_ndbm_delete'       ;
	function  ___db_ndbm_dirfno	      ;   external dblib; // name '___db_ndbm_dirfno'       ;
	function  ___db_ndbm_error	      ;   external dblib; // name '___db_ndbm_error'        ;
	function  ___db_ndbm_fetch	      ;   external dblib; // name '___db_ndbm_fetch'        ;
	function  ___db_ndbm_firstkey     ;	  external dblib; // name '___db_ndbm_firstkey'     ;
	function  ___db_ndbm_nextkey      ;	  external dblib; // name '___db_ndbm_nextkey'      ;
	function  ___db_ndbm_open	        ;   external dblib; // name '___db_ndbm_open'         ;
	function  ___db_ndbm_pagfno	      ;   external dblib; // name '___db_ndbm_pagfno'       ;
	function  ___db_ndbm_rdonly	      ;   external dblib; // name '___db_ndbm_rdonly'       ;
	function  ___db_ndbm_store	      ;   external dblib; // name '___db_ndbm_store'        ;
  //
	function  ___memp_dump_region	    ;   external dblib; // name '___memp_dump_region'     ;

	function  ___txn_id_set	          ;   external dblib; // name '___txn_id_set'           ;
	function  ___crdel_init_print	    ;   external dblib; // name '___crdel_init_print'     ;

  function  ___db_close             ;   external dblib; // name '___db_close';
	function  ___db_hcreate	          ;   external dblib; // name '___db_hcreate'           ;
	function  ___db_add_recovery      ;	  external dblib; // name '___db_add_recovery'      ;
	procedure ___db_hdestroy	        ;   external dblib; // name '___db_hdestroy'          ;
	procedure ___db_loadme	          ;   external dblib; // name '___db_loadme'          ;
	function  ___db_dispatch	        ;   external dblib; // name '___db_dispatch'          ;
	function  ___db_dump	            ;   external dblib; // name '___db_dump'              ;
	function  ___db_e_stat	          ;   external dblib; // name '___db_e_stat'            ;
	//function __db_err	              ;   external dblib; // name '___db_err'               ;
	function  ___db_getlong	          ;   external dblib; // name '___db_getlong'           ;
	function  ___db_getulong	        ;   external dblib; // name '___db_getulong'          ;
	//function __db_global_values	    ;   external dblib; // name '___db_global_values'     ;
	function  ___db_init_print	      ;   external dblib; // name '___db_init_print'        ;
	procedure ___db_inmemdbflags	    ;   external dblib; // name '___db_inmemdbflags'      ;
	function  ___db_isbigendian	      ;   external dblib; // name '___db_isbigendian'       ;
	function  ___db_omode	            ;   external dblib; // name '___db_omode'             ;
	function  ___db_overwrite	        ;   external dblib; // name '___db_overwrite'         ;
	function  ___db_pgin	            ;   external dblib; // name '___db_pgin'              ;
	function  ___db_pgout	            ;   external dblib; // name '___db_pgout'             ;
	function  ___db_pr_callback	      ;   external dblib; // name '___db_pr_callback'       ;
	function  ___db_prdbt	            ;   external dblib; // name '___db_prdbt'             ;
	function  ___db_prfooter	        ;   external dblib; // name '___db_prfooter'          ;
	function  ___db_prheader	        ;   external dblib; // name '___db_prheader'          ;
	function  ___db_rpath	            ;   external dblib; // name '___db_rpath'             ;
	function  ___db_util_cache	      ;   external dblib; // name '___db_util_cache'        ;
	function  ___db_util_interrupted	;   external dblib; // name '___db_util_interrupted'  ;
	function  ___db_util_logset	      ;   external dblib; // name '___db_util_logset'       ;
	procedure ___db_util_siginit	    ;   external dblib; // name '___db_util_siginit'      ;
	procedure ___db_util_sigresend	  ;   external dblib; // name '___db_util_sigresend'    ;
	function  ___db_verify_internal	  ;   external dblib; // name '___db_verify_internal'   ;
	function  ___db_panic	            ;   external dblib; // name '___db_panic'             ;
	function  ___db_r_attach	        ;   external dblib; // name '___db_r_attach'          ;
	function  ___db_r_detach	        ;   external dblib; // name '___db_r_detach'          ;
	function  ___db_win32_mutex_init  ;	  external dblib; // name '___db_win32_mutex_init'  ;
	function  ___db_win32_mutex_lock  ;	  external dblib; // name '___db_win32_mutex_lock'  ;
	function  ___db_win32_mutex_unlock;	  external dblib; // name '___db_win32_mutex_unlock';

	function  ___dbreg_init_print	    ;   external dblib; // name '___dbreg_init_print'     ;

	function  ___fop_init_print	      ;   external dblib; // name '___fop_init_print'       ;

	function  ___ham_get_meta	        ;   external dblib; // name '___ham_get_meta'         ;
	function  ___ham_init_print	      ;   external dblib; // name '___ham_init_print'       ;
	function  ___ham_pgin	            ;   external dblib; // name '___ham_pgin'             ;
	function  ___ham_pgout	          ;   external dblib; // name '___ham_pgout'            ;
	function  ___ham_release_meta	    ;   external dblib; // name '___ham_release_meta'     ;
	function  ___ham_func2	          ;   external dblib; // name '___ham_func2'            ;
	function  ___ham_func3	          ;   external dblib; // name '___ham_func3'            ;
	function  ___ham_func4	          ;   external dblib; // name '___ham_func4'            ;
	function  ___ham_func5	          ;   external dblib; // name '___ham_func5'            ;
	function  ___ham_test	            ;   external dblib; // name '___ham_test'             ;

	function  ___os_clock	            ;   external dblib; // name '___os_clock'             ;
	function  ___os_get_errno	        ;   external dblib; // name '___os_get_errno'         ;
	procedure ___os_id	              ;   external dblib; // name '___os_id'                ;
	procedure ___os_set_errno	        ;   external dblib; // name '___os_set_errno'         ;
	function  ___os_sleep	            ;   external dblib; // name '___os_sleep'             ;
	procedure ___os_ufree	            ;   external dblib; // name '___os_ufree'             ;
	procedure ___os_yield	            ;   external dblib; // name '___os_yield'             ;
	function  ___os_calloc	          ;   external dblib; // name '___os_calloc'            ;
	function  ___os_closehandle	      ;   external dblib; // name '___os_closehandle'       ;
	procedure ___os_free	            ;   external dblib; // name '___os_free'              ;
	function  ___os_ioinfo	          ;   external dblib; // name '___os_ioinfo'            ;
	function  ___os_malloc	          ;   external dblib; // name '___os_malloc'            ;
	function  ___os_open	            ;   external dblib; // name '___os_open'              ;
	function  ___os_openhandle	      ;   external dblib; // name '___os_openhandle'        ;
	function  ___os_read	            ;   external dblib; // name '___os_read'              ;
	function  ___os_realloc	          ;   external dblib; // name '___os_realloc'           ;
	function  ___os_strdup	          ;   external dblib; // name '___os_strdup'            ;
	function  ___os_umalloc	          ;   external dblib; // name '___os_umalloc'           ;
	function  ___os_write	            ;   external dblib; // name '___os_write'             ;

	function  ___qam_init_print	      ;   external dblib; // name '___qam_init_print'       ;
	function  ___qam_pgin_out	        ;   external dblib; // name '___qam_pgin_out'         ;

	function  ___txn_init_print	      ;   external dblib; // name '___txn_init_print'       ;
  //function ___lock_open           ;   external

  function ___db_panic_msg;             external dblib; // name '___db_panic_msg';
  function ___db_key_range_pp;          external dblib; // name '___db_key_range_pp';
  function ___db_open_pp;               external dblib; // name '___db_open_pp';
  function ___db_fnl;                   external dblib; // name '___db_fnl';
  function ___db_put;                   external dblib; // name '___db_put';
  function ___db_del;                   external dblib; // name '___db_del';
  function ___db_associate;             external dblib; // name '___db_associate';
  function ___db_pg_alloc_log;          external dblib; // name '___db_pg_alloc_log';
  function ___db_pg_freedata_log;       external dblib; // name '___db_pg_freedata_log';
  function ___db_c_count;               external dblib; // name '___db_c_count';
  function ___db_c_dup;                 external dblib; // name '___db_c_dup';
  function ___db_c_get;                 external dblib; // name '___db_c_get';
  function ___db_associate_pp;          external dblib; // name '___db_associate_pp';
  function ___db_close_pp;              external dblib; // name '___db_close_pp';
  function ___db_cursor_pp;             external dblib; // name '___db_cursor_pp';
  function ___db_del_pp;                external dblib; // name '___db_del_pp';
  function ___db_fd_pp;                 external dblib; // name '___db_fd_pp';
  function ___db_get_pp;                external dblib; // name '___db_get_pp';
  function ___db_join_pp;               external dblib; // name '___db_join_pp';
  function ___db_pget_pp;               external dblib; // name '___db_pget_pp';


	function  ___bam_init_print	    ;     external dblib; // name '___bam_init_print'       ;
	function  ___bam_pgin	          ;     external dblib; // name '___bam_pgin'             ;
	function  ___bam_pgout	        ;     external dblib; // name '___bam_pgout'            ;
  function  ___bam_curadj_log    ;      external dblib; // name '___bam_curadj_log';
  function  ___bam_ca_delete     ;      external dblib; // name '___bam_ca_delete';
  function  ___ram_ca_delete     ;      external dblib; // name '___ram_ca_delete';
  function  ___bam_cdel_log      ;      external dblib; // name '___bam_cdel_log';
  function  ___bam_cmp           ;      external dblib; // name '___bam_cmp';
  function  ___bam_defcmp        ;      external dblib; // name '___bam_defcmp';
  function  ___bam_ca_di         ;      external dblib; // name '___bam_ca_di';
  function  ___bam_init_recover  ;      external dblib; // name '___bam_init_recover';


  function  ___lock_open;               external dblib; // name '___lock_open';
  function  ___lock_dump_region	    ;   external dblib; // name '___lock_dump_region'     ;
	function  ___lock_id_set	        ;   external dblib; // name '___lock_id_set'          ;


initialization
finalization
end.



