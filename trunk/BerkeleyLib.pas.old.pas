{$Z4}
unit BerkeleyLib.pas.old;

interface
uses
  Windows, OS, DBConst;
const
  //dblib ='Berkeleydb.dll';
  dblib ='db_lib.lib';
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
  //function db_env_create(_para1: PDB_ENV; _para2:u_int32_t):longint; cdecl;
  function _db_version(_para1:Plongint; _para2:Plongint; _para3:Plongint):Pchar; cdecl;
  function _log_compare(_para1:PDB_LSN; _para2:PDB_LSN):longint; cdecl;
  //function db_env_set_func_close(_para1:function (_para1:longint):longint):longint;
  function _db_env_set_func_close(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_dirfree(_para1:procedure (_para1:PPchar; _para2:longint)):longint;
  function _db_env_set_func_dirfree(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_dirlist(_para1:function (_para1:Pchar; _para2:PPPchar; _para3:Plongint):longint):longint;
  function _db_env_set_func_dirlist(_para1:pointer):longint; cdecl;
  //function db_env_set_func_exists(_para1:function (_para1:Pchar; _para2:Plongint):longint):longint;
  function _db_env_set_func_exists(_para1:pointer):longint; cdecl;
  //function db_env_set_func_free(_para1:procedure (_para1:pointer)):longint;
  function _db_env_set_func_free(_para1:TSysFreeMem):longint; cdecl;
  //function db_env_set_func_fsync(_para1:function (_para1:longint):longint):longint;
  function _db_env_set_func_fsync(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_ioinfo(_para1:function (_para1:Pchar; _para2:longint; _para3:Pu_int32_t; _para4:Pu_int32_t; _para5:Pu_int32_t):longint):longint;
  function _db_env_set_func_ioinfo(_para1:pointer):longint; cdecl;
  //function db_env_set_func_malloc(_para1:Pprocedure (_para1:size_t)):longint;
  function _db_env_set_func_malloc(_para1:TSysGetMem):longint; cdecl;
  //function db_env_set_func_map(_para1:function (_para1:Pchar; _para2:size_t; _para3:longint; _para4:longint; _para5:Ppointer):longint):longint;
  function _db_env_set_func_map(_para1:Pointer):longint;  cdecl;
  //function db_env_set_func_open(_para1:function (_para1:Pchar; _para2:longint; args:array of const):longint):longint;
  function _db_env_set_func_open(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_read(_para1:function (_para1:longint; _para2:pointer; _para3:size_t):ssize_t):longint;
  function _db_env_set_func_read(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_realloc(_para1:Pprocedure (_para1:pointer; _para2:size_t)):longint;
  function _db_env_set_func_realloc(_para1:TSysReallocMem):longint; cdecl;
  //function db_env_set_func_rename(_para1:function (_para1:Pchar; _para2:Pchar):longint):longint;
  function _db_env_set_func_rename(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_seek(_para1:function (_para1:longint; _para2:size_t; _para3:db_pgno_t; _para4:u_int32_t; _para5:longint;
  //                      _para6:longint):longint):longint;
  function _db_env_set_func_seek(_para1:Pointer):longint;  cdecl;
  //function db_env_set_func_sleep(_para1:function (_para1:u_long; _para2:u_long):longint):longint;
  function _db_env_set_func_sleep(_para1:Pointer):longint;  cdecl;
  //function db_env_set_func_unlink(_para1:function (_para1:Pchar):longint):longint;
  function _db_env_set_func_unlink(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_unmap(_para1:function (_para1:pointer; _para2:size_t):longint):longint;
  function _db_env_set_func_unmap(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_write(_para1:function (_para1:longint; _para2:pointer; _para3:size_t):ssize_t):longint;
  function _db_env_set_func_write(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_yield(_para1:function :longint):longint;
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
  function  ___db_hcreate(_para1:size_t):longint; cdecl;
  //function __db_hsearch(_para1:TENTRY; _para2:ACTION):PENTRY; cdecl;
  procedure ___db_hdestroy; cdecl;



  //int function __crypto_region_init (env : PDB_ENV);
  function  ___db_isbigendian ():integer;
  //int function __db_byteorder (env : PDB_ENV, int);
  //int function __db_fchk (env : PDB_ENV; const PChar, u_int32_t, u_int32_t);
  //int function __db_fcchk (env : PDB_ENV; const PChar, u_int32_t, u_int32_t, u_int32_t);
  //int function __db_ferr (const env : PDB_ENV; const PChar, int);
  function ___db_fnl (const env : PDB_ENV; const p2:PChar): integer;
  //int function  __db_pgerr (PDB, pgno : db_pgno_t; int);
  //int function __db_pgfmt (env : PDB_ENV; db_pgno_t);
  function  ___db_panic_msg (env : PDB_ENV):integer;
  function  ___db_panic (p1: PDB_ENV; p2:integer):integer;
  //void function __db_errcall (const env : PDB_ENV; int, int, const PChar, va_list);
  //void function __db_errfile (const env : PDB_ENV; int, int, const PChar, va_list);
  //void function __db_logmsg (const env : PDB_ENV; txn : PDB_TXN; const PChar, u_int32_t, const PChar, ...)) __attribute__ ((__format__ (__printf__, 5, 6));
  //int function __db_unknown_flag (env : PDB_ENV; PChar, u_int32_t);
  //int function __db_unknown_type (env : PDB_ENV; PChar, DBTYPE);
  //int function __db_check_txn (PDB, txn : PDB_TXN; u_int32_t, int);
  //int function __db_not_txn_env (env : PDB_ENV);
  //int function __db_rec_toobig (env : PDB_ENV; u_int32_t, u_int32_t);
  //int function __db_rec_repl (env : PDB_ENV; u_int32_t, u_int32_t);
  function  ___db_getlong (p1 : PDB_ENV; const p2 : PChar; p3: PChar; p4: longint; p5: longint; var p6: longint):integer;
  function  ___db_getulong (p1 : PDB_ENV; const p2 :PChar; p3: PChar; p4: u_long; p5: u_long; var p6: u_long ):integer;
  //void function __db_idspace (var p : u_int32_t; int, var p : u_int32_t; var p : u_int32_t);
  //u_int32_t function __db_log2 (u_int32_t);
  //int function __db_util_arg (PChar, PChar, int *, PChar**);
  function  ___db_util_cache (p1 : PDB_ENV; db : PDB; var p3 : u_int32_t;var p4 : integer):integer;
  function  ___db_util_logset (const p1: PChar; p2: PChar):integer;
  procedure  ___db_util_siginit ();
  function  ___db_util_interrupted ():integer;
  procedure  ___db_util_sigresend ();


  function ___bam_cmp (db : PDB; const dbt : PDBT; page : PPAGE; P4:u_int32_t; p5 : pointer;var p6: integer): integer;
  function ___bam_defcmp (db : PDB; const dbt : PDBT; const dbt1 : PDBT):integer;
  //size_t function __bam_defpfx (db : PDB; const dbt : PDBT; const dbt : PDBT);
  function  ___bam_pgin (env : PDB_ENV; db : PDB; pgno : db_pgno_t; page : PPAGE; dbt : PDBT):integer;
  function  ___bam_pgout (env : PDB_ENV; db : PDB; pgno : db_pgno_t; page : PPAGE; dbt : PDBT):integer;
  //int function __bam_mswap (PAGE *);
  //void function __bam_cprint (dbc : PDBC);
  function ___bam_ca_delete (db : PDB; pgno : db_pgno_t; p3:u_int32_t; p4: integer):integer;
  function ___ram_ca_delete (db : PDB; pgno : db_pgno_t):integer;
  function ___bam_ca_di (dbc : PDBC; pgno : db_pgno_t; p3:u_int32_t; p4:integer):integer;
  //int function __bam_ca_dup (dbc : PDBC; u_int32_t, pgno : db_pgno_t; u_int32_t, pgno : db_pgno_t; u_int32_t);
  //int function __bam_ca_undodup (db : PDB; u_int32_t, pgno : db_pgno_t; u_int32_t, u_int32_t);
  //int function __bam_ca_rsplit (dbc : PDBC; pgno : db_pgno_t; db_pgno_t);
  //int function __bam_ca_split (dbc : PDBC; pgno : db_pgno_t; pgno : db_pgno_t; pgno : db_pgno_t; u_int32_t, int);
  //void function __bam_ca_undosplit (db : PDB; pgno : db_pgno_t; pgno : db_pgno_t; pgno : db_pgno_t; u_int32_t);
  //int function __bam_c_init (dbc : PDBC; DBTYPE);
  //int function __bam_c_refresh (dbc : PDBC);
  //int function __bam_c_count (dbc : PDBC; db_recno_t *);
  //int function __bam_c_dup (dbc : PDBC; dbc : PDBC);
  //int function __bam_bulk_overflow (dbc : PDBC; u_int32_t, pgno : db_pgno_t; u_int8_t *);
  //int function __bam_bulk_duplicates (dbc : PDBC; pgno : db_pgno_t; u_int8_t *, int32_t *, int32_t **, u_int8_t **, var p : u_int32_t; int);
  //int function __bam_c_rget (dbc : PDBC; dbt : PDBT);
  //int function __bam_ditem (dbc : PDBC; page : PPAGE; u_int32_t);
  //int function __bam_adjindx (dbc : PDBC; page : PPAGE; u_int32_t, u_int32_t, int);
  //int function __bam_dpages (dbc : PDBC; EPG *);
  //int function __bam_db_create (DB *);
  //int function __bam_db_close (DB *);
  //void function __bam_map_flags (db : PDB; var p : u_int32_t; var p : u_int32_t);
  //int function __bam_set_flags (db : PDB; var p : u_int32_tflagsp);
  //int function __bam_set_bt_compare (db : PDB; int function(*)(db : PDB; const dbt : PDBT; const dbt : PDBT));
  //void function __ram_map_flags (db : PDB; var p : u_int32_t; var p : u_int32_t);
  //int function __ram_set_flags (db : PDB; var p : u_int32_tflagsp);
  //int function __bam_open (db : PDB; txn : PDB_TXN; const Pchar; pgno : db_pgno_t; u_int32_t);
  //int function __bam_metachk (db : PDB; const Pchar, BTMETA *);
  //int function __bam_read_root (db : PDB; txn : PDB_TXN; pgno : db_pgno_t; u_int32_t);
  //int function __bam_new_file (db : PDB; txn : PDB_TXN; fh : PDB_FH, const Pchar);
  //int function __bam_new_subdb (db : PDB; db : PDB; DB_TXN *);
  //int function __bam_iitem (dbc : PDBC; dbt : PDBT; dbt : PDBT; u_int32_t, u_int32_t);
  //int function __bam_ritem (dbc : PDBC; page : PPAGE; u_int32_t, dbt : PDBT);
  //int function __bam_split_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_rsplit_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_adj_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_cadjust_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_cdel_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_repl_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_root_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_curadj_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_rcuradj_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_reclaim (db : PDB; DB_TXN *);
  //int function __bam_truncate (dbc : PDBC; var p : u_int32_t);
  //int function __ram_open (db : PDB; txn : PDB_TXN; const Pchar, pgno : db_pgno_t; u_int32_t);
  //int function __ram_append (dbc : PDBC; dbt : PDBT; dbt : PDBT);
  //int function __ram_c_del (dbc : PDBC);
  //int function __ram_c_get (dbc : PDBC; dbt : PDBT; dbt : PDBT; u_int32_t, db_pgno_t *);
  //int function __ram_c_put (dbc : PDBC; dbt : PDBT; dbt : PDBT; u_int32_t, db_pgno_t *);
  //int function __ram_ca (dbc : PDBC; ca_recno_arg);
  //int function __ram_getno (dbc : PDBC; const dbt : PDBT; db_recno_t *, int);
  //int function __ram_writeback (DB *);
  //int function __bam_rsearch (dbc : PDBC; db_recno_t *, u_int32_t, int, int *);
  //int function __bam_adjust (dbc : PDBC; int32_t);
  //int function __bam_nrecs (dbc : PDBC; db_recno_t *);
  //db_recno_t function __bam_total (db : PDB; PAGE *);
  //int function __bam_search (dbc : PDBC; pgno : db_pgno_t; const dbt : PDBT; u_int32_t, int, db_recno_t *, int *);
  //int function __bam_stkrel (dbc : PDBC; u_int32_t);
  //int function __bam_stkgrow (env : PDB_ENV; BTREE_CURSOR *);
  //int function __bam_split (dbc : PDBC; void : pointer; db_pgno_t *);
  //int function __bam_copy (db : PDB; page : PPAGE; page : PPAGE; u_int32_t, u_int32_t);
  //int function __bam_stat (dbc : PDBC; void : pointer; u_int32_t);
  //int function __bam_traverse (dbc : PDBC; db_lockmode_t, pgno : db_pgno_t; int function (*)(db : PDB; page : PPAGE; void : pointer; int *), void : pointer);
  //int function __bam_stat_callback (db : PDB; page : PPAGE; void : pointer; int *);
  //int function __bam_key_range (dbc : PDBC; dbt : PDBT; DB_KEY_RANGE *, u_int32_t);
  //int function __bam_30_btreemeta (db : PDB; Pchar, u_int8_t *);
  //int function __bam_31_btreemeta (db : PDB; Pchar, u_int32_t, fh : PDB_FH, page : PPAGE; int *);
  //int function __bam_31_lbtree (db : PDB; Pchar, u_int32_t, fh : PDB_FH, page : PPAGE; int *);
  //int function __bam_vrfy_meta (db : PDB; VRFY_DBINFO *, BTMETA *, pgno : db_pgno_t; u_int32_t);
  //int function __ram_vrfy_leaf (db : PDB; VRFY_DBINFO *, page : PPAGE; pgno : db_pgno_t; u_int32_t);
  //int function __bam_vrfy (db : PDB; VRFY_DBINFO *, page : PPAGE; pgno : db_pgno_t; u_int32_t);
  //int function __bam_vrfy_itemorder (db : PDB; VRFY_DBINFO *, page : PPAGE; pgno : db_pgno_t; u_int32_t, int, int, u_int32_t);
  //int function __bam_vrfy_structure (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; u_int32_t);
  //int function __bam_vrfy_subtree (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; void : pointer; void : pointer; u_int32_t, var p : u_int32_t; var p : u_int32_t; var p : u_int32_t);
  //int function __bam_salvage (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; u_int32_t, page : PPAGE; void : pointer; int function  (*)(void : pointer; const void : pointer), dbt : PDBT; u_int32_t);
  //int function __bam_salvage_walkdupint (db : PDB; VRFY_DBINFO *, page : PPAGE; dbt : PDBT; void : pointer; int function  (*)(void : pointer; const void : pointer), u_int32_t);
  //int function __bam_meta2pgset (db : PDB; VRFY_DBINFO *, BTMETA *, u_int32_t, DB *);
  //int function __bam_split_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; const dbt : PDBT; u_int32_t);
  //int function __bam_split_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_split_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_split_read (env : PDB_ENV; void : pointer; __bam_split_args **);
  //int function __bam_rsplit_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; const dbt : PDBT; pgno : db_pgno_t; pgno : db_pgno_t; const dbt : PDBT; lsn : PDB_LSN);
  //int function __bam_rsplit_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_rsplit_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_rsplit_read (env : PDB_ENV; void : pointer; __bam_rsplit_args **);
  //int function __bam_adj_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; u_int32_t, u_int32_t, u_int32_t);
  //int function __bam_adj_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_adj_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_adj_read (env : PDB_ENV; void : pointer; __bam_adj_args **);
  //int function __bam_cadjust_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; u_int32_t, int32_t, u_int32_t);
  //int function __bam_cadjust_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_cadjust_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_cadjust_read (env : PDB_ENV; void : pointer; __bam_cadjust_args **);
  function ___bam_cdel_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; p4:u_int32_t; pgno : db_pgno_t; lsn1: PDB_LSN; p6:u_int32_t):integer;
  //int function __bam_cdel_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_cdel_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_cdel_read (env : PDB_ENV; void : pointer; __bam_cdel_args **);
  //int function __bam_repl_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; u_int32_t, u_int32_t, const dbt : PDBT; const dbt : PDBT; u_int32_t, u_int32_t);
  //int function __bam_repl_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_repl_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_repl_read (env : PDB_ENV; void : pointer; __bam_repl_args **);
  //int function __bam_root_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; pgno : db_pgno_t; lsn : PDB_LSN);
  //int function __bam_root_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_root_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_root_read (env : PDB_ENV; void : pointer; __bam_root_args **);
  function ___bam_curadj_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; p4:u_int32_t; p5: db_ca_mode; pgno : db_pgno_t; pgno1 : db_pgno_t; pgno2 : db_pgno_t; p8:u_int32_t; p9: u_int32_t; p10:u_int32_t):integer;
  //int function __bam_curadj_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_curadj_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_curadj_read (env : PDB_ENV; void : pointer; __bam_curadj_args **);
  //int function __bam_rcuradj_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, ca_recno_arg, pgno : db_pgno_t; db_recno_t, u_int32_t);
  //int function __bam_rcuradj_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_rcuradj_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __bam_rcuradj_read (env : PDB_ENV; void : pointer; __bam_rcuradj_args **);
  //function  __bam_init_print (env : PDB_ENV; int function(***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t):integer;
  function  ___bam_init_print (env : PDB_ENV; p2 : Pointer; var size : size_t):integer;
  //int function __bam_init_getpgnos (env : PDB_ENV; int function(***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  function ___bam_init_recover (env : PDB_ENV; p2: Pointer; var size : size_t): integer ;

  //int function __crypto_region_init (env : PDB_ENV);
  //int function __db_byteorder (env : PDB_ENV; int);
  //int function __db_fchk (env : PDB_ENV; const Pchar, u_int32_t, u_int32_t);
  //int function __db_fcchk (env : PDB_ENV; const Pchar, u_int32_t, u_int32_t, u_int32_t);
  //int function __db_ferr (const env : PDB_ENV; const Pchar, int);
  //int function __db_fnl (const env : PDB_ENV; const Pchar);
  //int function  __db_pgerr (db : PDB; pgno : db_pgno_t; int);
  //int function __db_pgfmt (env : PDB_ENV; db_pgno_t);
  //#ifdef DIAGNOSTIC
  //void function __db_assert (const Pchar, const Pchar, int);
  //#endif
  //int function __db_panic_msg (env : PDB_ENV);
  //procedure __db_err (const env : PDB_ENV; const p2 : Pchar; ...)) __attribute__ ((__format__ (__printf__, 2, 3));
  //void function __db_errcall (const env : PDB_ENV; int, int, const Pchar, va_list);
  //void function __db_errfile (const env : PDB_ENV; int, int, const Pchar, va_list);
  //void function __db_logmsg (const env : PDB_ENV; txn : PDB_TXN; const Pchar, u_int32_t, const Pchar, ...)) __attribute__ ((__format__ (__printf__, 5, 6));
  //int function __db_unknown_flag (env : PDB_ENV; Pchar, u_int32_t);
  //int function __db_unknown_type (env : PDB_ENV; Pchar, DBTYPE);
  //int function __db_check_txn (db : PDB; txn : PDB_TXN; u_int32_t, int);
  //int function __db_not_txn_env (env : PDB_ENV);
  //int function __db_rec_toobig (env : PDB_ENV; u_int32_t, u_int32_t);
  //int function __db_rec_repl (env : PDB_ENV; u_int32_t, u_int32_t);
  //void function __db_idspace (var p : u_int32_t; int, var p : u_int32_t; var p : u_int32_t);
  //u_int32_t function __db_log2 (u_int32_t);
  //int function __db_util_arg (Pchar; Pchar; int *, Pchar**);

  //int function __dbreg_setup (db : PDB; const Pchar; u_int32_t);
  //int function __dbreg_teardown (DB *);
  //int function __dbreg_new_id (db : PDB; DB_TXN *);
  //int function __dbreg_get_id (db : PDB; txn : PDB_TXN; int32_t *);
  //int function __dbreg_assign_id (db : PDB; int32_t);
  //int function __dbreg_revoke_id (db : PDB; int, int32_t);
  //int function __dbreg_close_id (db : PDB; DB_TXN *);
  //int function __dbreg_register_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, const dbt : PDBT; const dbt : PDBT; int32_t, DBTYPE, pgno : db_pgno_t; u_int32_t);
  //int function __dbreg_register_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __dbreg_register_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __dbreg_register_read (env : PDB_ENV; void : pointer; __dbreg_register_args **);
  //function  __dbreg_init_print (env : PDB_ENV; int function (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t):integer;
  function  ___dbreg_init_print (env : PDB_ENV; p2:pointer; var size : size_t):integer;
  //int function __dbreg_init_getpgnos (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __dbreg_init_recover (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __dbreg_register_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __dbreg_add_dbentry (env : PDB_ENV; DB_LOG *, db : PDB; int32_t);
  //void function __dbreg_rem_dbentry (DB_LOG *, int32_t);
  //int function __dbreg_open_files (env : PDB_ENV);
  //int function __dbreg_close_files (env : PDB_ENV);
  //int function __dbreg_id_to_db (env : PDB_ENV; txn : PDB_TXN; DB **, int32_t, int);
  //int function __dbreg_id_to_db_int (env : PDB_ENV; txn : PDB_TXN; DB **, int32_t, int, int);
  //int function __dbreg_id_to_fname (DB_LOG *, int32_t, int, FNAME **);
  //int function __dbreg_fid_to_fname (DB_LOG *, u_int8_t *, int, FNAME **);
  //int function __dbreg_get_name (env : PDB_ENV; u_int8_t *, Pchar*);
  //int function __dbreg_do_open (env : PDB_ENV; txn : PDB_TXN; DB_LOG *, u_int8_t *, Pchar; DBTYPE, int32_t, pgno : db_pgno_t; void : pointer; u_int32_t);
  //int function __dbreg_lazy_id (DB *);
  //int function __dbreg_push_id (env : PDB_ENV; int32_t);
  //int function __dbreg_pop_id (env : PDB_ENV; int32_t *);
  //int function __dbreg_pluck_id (env : PDB_ENV; int32_t);
  //void function __dbreg_print_dblist (env : PDB_ENV);

  //int function __crdel_metasub_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; const dbt : PDBT; lsn : PDB_LSN);
  //int function __crdel_metasub_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __crdel_metasub_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __crdel_metasub_read (env : PDB_ENV; void : pointer; __crdel_metasub_args **);
  //function  __crdel_init_print (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t):integer;

  //int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer)
  function  ___crdel_init_print (env : PDB_ENV; p2:pointer; var size : size_t):integer;
  //int function __crdel_init_getpgnos (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __crdel_init_recover (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __crdel_metasub_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_master_open (db : PDB; txn : PDB_TXN; const Pchar; u_int32_t, int, DB **);
  //int function __db_master_update (db : PDB; db : PDB; txn : PDB_TXN; const Pchar; DBTYPE, mu_action, const Pchar; u_int32_t);
  //int function __db_dbenv_setup (db : PDB; txn : PDB_TXN; const Pchar; u_int32_t, u_int32_t);
  function ___db_close (db : PDB; txn : PDB_TXN; p3: u_int32_t):integer;
  //int function __db_refresh (db : PDB; txn : PDB_TXN; u_int32_t, int *);
  //int function __db_log_page (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; pgno : db_pgno_t; PAGE *);
  //int function __db_backup_name (env : PDB_ENV; const Pchar; txn : PDB_TXN; Pchar*);
  //DB * function __dblist_get (env : PDB_ENV; u_int32_t);
  //#if CONFIG_TEST
  //int function __db_testcopy (env : PDB_ENV; db : PDB; const Pchar);
  //#endif
  //int function __db_cursor_int (db : PDB; txn : PDB_TXN; DBTYPE, pgno : db_pgno_t; int, u_int32_t, dbc : PDBC*);
  //int function __db_cprint (DB *);
  function ___db_put (db : PDB; txn : PDB_TXN; dbt : PDBT; dbt2 : PDBT; p5:u_int32_t):integer;
  function ___db_del (db : PDB; txn : PDB_TXN; dbt : PDBT; p4:u_int32_t):integer;
  //int function __db_sync (DB *);
  //function __db_associate (db : PDB; txn : PDB_TXN; db : PDB; int function(*)(db : PDB; const dbt : PDBT; const dbt : PDBT; dbt : PDBT), u_int32_t):Integer;
  function ___db_associate (db : PDB; txn : PDB_TXN; db2 : PDB; p4:pointer; p5:u_int32_t):Integer;
  //int function __db_addrem_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, pgno : db_pgno_t; u_int32_t, u_int32_t, const dbt : PDBT; const dbt : PDBT; lsn : PDB_LSN);
  //int function __db_addrem_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_addrem_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_addrem_read (env : PDB_ENV; void : pointer; __db_addrem_args **);
  //int function __db_big_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, pgno : db_pgno_t; pgno : db_pgno_t; pgno : db_pgno_t; const dbt : PDBT; lsn : PDB_LSN; lsn : PDB_LSN; lsn : PDB_LSN);
  //int function __db_big_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_big_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_big_read (env : PDB_ENV; void : pointer; __db_big_args **);
  //int function __db_ovref_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; int32_t, lsn : PDB_LSN);
  //int function __db_ovref_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_ovref_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_ovref_read (env : PDB_ENV; void : pointer; __db_ovref_args **);
  //int function __db_relink_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; lsn : PDB_LSN);
  //int function __db_relink_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_relink_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_relink_read (env : PDB_ENV; void : pointer; __db_relink_args **);
  //int function __db_debug_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, const dbt : PDBT; int32_t, const dbt : PDBT; const dbt : PDBT; u_int32_t);
  //int function __db_debug_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_debug_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_debug_read (env : PDB_ENV; void : pointer; __db_debug_args **);
  //int function __db_noop_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN);
  //int function __db_noop_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_noop_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_noop_read (env : PDB_ENV; void : pointer; __db_noop_args **);
  function ___db_pg_alloc_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; p4: u_int32_t; lsn1 : PDB_LSN; pgno : db_pgno_t; lsn2 : PDB_LSN; pgno1 : db_pgno_t; p9:u_int32_t; pgno2 :db_pgno_t):integer;
  //int function __db_pg_alloc_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_alloc_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_alloc_read (env : PDB_ENV; void : pointer; __db_pg_alloc_args **);
  //int function __db_pg_free_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; const dbt : PDBT; db_pgno_t);
  //int function __db_pg_free_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_free_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_free_read (env : PDB_ENV; void : pointer; __db_pg_free_args **);
  //int function __db_cksum_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t);
  //int function __db_cksum_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_cksum_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_cksum_read (env : PDB_ENV; void : pointer; __db_cksum_args **);
  function ___db_pg_freedata_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; P4: u_int32_t; pgno : db_pgno_t; lsn1 : PDB_LSN; pgno1 : db_pgno_t; const dbt : PDBT; pgno2 : db_pgno_t; const dbt1 : PDBT):integer;
  //int function __db_pg_freedata_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_freedata_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_freedata_read (env : PDB_ENV; void : pointer; __db_pg_freedata_args **);
  //int function __db_pg_prepare_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, db_pgno_t);
  //int function __db_pg_prepare_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_prepare_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_prepare_read (env : PDB_ENV; void : pointer; __db_pg_prepare_args **);
  //int function __db_pg_new_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; const dbt : PDBT; db_pgno_t);
  //int function __db_pg_new_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_new_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_new_read (env : PDB_ENV; void : pointer; __db_pg_new_args **);
  //int function  __db_init_print (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  function  ___db_init_print (env : PDB_ENV; p2:Pointer; var size : size_t):integer;
  //int function __db_init_getpgnos (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __db_init_recover (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __db_c_close (dbc : PDBC);
  //int function __db_c_destroy (dbc : PDBC);
  function ___db_c_count (dbc : PDBC; var recno : db_recno_t):integer;
  //int function __db_c_del (dbc : PDBC; u_int32_t);
  function ___db_c_dup (dbc : PDBC; dbc1 : PDBC; p3: u_int32_t):integer;
  //int function __db_c_idup (dbc : PDBC; dbc : PDBC*, u_int32_t);
  //int function __db_c_newopd (dbc : PDBC; pgno : db_pgno_t; dbc : PDBC; dbc : PDBC*);
  function ___db_c_get (dbc : PDBC; dbt : PDBT; dbt1 : PDBT; p4: u_int32_t):integer;
  //int function __db_c_put (dbc : PDBC; dbt : PDBT; dbt : PDBT; u_int32_t);
  //int function __db_duperr (db : PDB; u_int32_t);
  //int function __db_c_secondary_get_pp (dbc : PDBC; dbt : PDBT; dbt : PDBT; u_int32_t);
  //int function __db_c_pget (dbc : PDBC; dbt : PDBT; dbt : PDBT; dbt : PDBT; u_int32_t);
  //int function __db_c_del_primary (dbc : PDBC);
  //DB * function __db_s_first (DB *);
  //int function __db_s_next (DB **);
  //int function __db_s_done (DB *);
  //u_int32_t function __db_partsize (u_int32_t, dbt : PDBT);
  function  ___db_pgin (env : PDB_ENV; p2: db_pgno_t; void : pointer; dbt : PDBT):integer;
  function  ___db_pgout (env : PDB_ENV; p2: db_pgno_t; void : pointer; dbt : PDBT):integer;
  //void function __db_metaswap (PAGE *);
  //int function __db_byteswap (env : PDB_ENV; db : PDB; pgno : db_pgno_t; page : PPAGE; size : size_t; int);
  //int function  __db_dispatch (env : PDB_ENV; int function(**)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer)), size : size_t; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  function  ___db_dispatch (env : PDB_ENV; p2:Pointer; p3:size_t; dbt : PDBT; lsn : PDB_LSN; p6:db_recops; void : pointer):integer;
  //int function  __db_add_recovery (env : PDB_ENV; int function (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size : size_t; int function (*)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), u_int32_t);
  function  ___db_add_recovery (env : PDB_ENV; p2: Pointer; var size : size_t; P4 : Pointer; p5 : u_int32_t):integer;
  //int function __db_txnlist_init (env : PDB_ENV; u_int32_t, u_int32_t, lsn : PDB_LSN; void : pointer);
  //int function __db_txnlist_add (env : PDB_ENV; void : pointer; u_int32_t, int32_t, lsn : PDB_LSN);
  //int function __db_txnlist_remove (env : PDB_ENV; void : pointer; u_int32_t);
  //void function __db_txnlist_ckp (env : PDB_ENV; void : pointer; lsn : PDB_LSN);
  //void function __db_txnlist_end (env : PDB_ENV; void : pointer);
  //int function __db_txnlist_find (env : PDB_ENV; void : pointer; u_int32_t);
  //int function __db_txnlist_update (env : PDB_ENV; void : pointer; u_int32_t, int32_t, lsn : PDB_LSN);
  //int function __db_txnlist_gen (env : PDB_ENV; void : pointer; int, u_int32_t, u_int32_t);
  //int function __db_txnlist_lsnadd (env : PDB_ENV; void : pointer; lsn : PDB_LSN; u_int32_t);
  //int function __db_txnlist_lsninit (env : PDB_ENV; DB_TXNHEAD *, lsn : PDB_LSN);
  //int function __db_add_limbo (env : PDB_ENV; void : pointer; int32_t, pgno : db_pgno_t; int32_t);
  //int function __db_do_the_limbo (env : PDB_ENV; txn : PDB_TXN; txn : PDB_TXN; DB_TXNHEAD *, db_limbo_state);
  //int function __db_default_getpgnos (env : PDB_ENV; lsn : PDB_LSNlsnp, void : pointer);
  //void function __db_txnlist_print (void : pointer);
  //int function __db_ditem (dbc : PDBC; page : PPAGE; u_int32_t, u_int32_t);
  //int function __db_pitem (dbc : PDBC; page : PPAGE; u_int32_t, u_int32_t, dbt : PDBT; dbt : PDBT);
  //int function __db_relink (dbc : PDBC; u_int32_t, page : PPAGE; PAGE **, int);
  //function __db_associate_pp (db : PDB; txn : PDB_TXN; db : PDB; int function(*)(db : PDB; const dbt : PDBT; const dbt : PDBT; dbt : PDBT), u_int32_t):integer;
  function ___db_associate_pp (db : PDB; txn : PDB_TXN; db1 : PDB; p : Pointer; p2:u_int32_t):integer;
  function ___db_close_pp (db : PDB; p2: u_int32_t):integer;
  function ___db_cursor_pp (db : PDB; txn : PDB_TXN; dbc : PDBC; p4: u_int32_t):integer;
  //int function __db_cursor (db : PDB; txn : PDB_TXN; dbc : PDBC*, u_int32_t);
  function ___db_del_pp (db : PDB; txn : PDB_TXN; dbt : PDBT; p4:u_int32_t):integer;
  function ___db_fd_pp (db : PDB; var p2: integer):integer;
  function ___db_get_pp (db : PDB; txn : PDB_TXN; dbt : PDBT; dbt1 : PDBT; p5: u_int32_t):integer;
  //int function __db_get (db : PDB; txn : PDB_TXN; dbt : PDBT; dbt : PDBT; u_int32_t);
  function ___db_join_pp (db : PDB; dbc : PDBC; dbc1 : PDBC; p4:u_int32_t):integer;
  function ___db_key_range_pp (db : PDB; txn : PDB_TXN; dbt : PDBT; p4: Pointer{PDB_KEY_RANGE}; p5: u_int32_t):integer;
  function ___db_open_pp (db : PDB; txn : PDB_TXN; const p3:Pchar; const p4:Pchar; p5:TDBTYPE; p6:u_int32_t; p7:integer): integer;
  function ___db_pget_pp (db : PDB; txn : PDB_TXN; dbt : PDBT; dbt1 : PDBT; dbt2 : PDBT; p6:u_int32_t):integer;
  //int function __db_pget (db : PDB; txn : PDB_TXN; dbt : PDBT; dbt : PDBT; dbt : PDBT; u_int32_t);
  //int function __db_put_pp (db : PDB; txn : PDB_TXN; dbt : PDBT; dbt : PDBT; u_int32_t);
  //int function __db_stat_pp (db : PDB; void : pointer; u_int32_t);
  //int function __db_stat (db : PDB; void : pointer; u_int32_t);
  //int function __db_sync_pp (db : PDB; u_int32_t);
  //int function __db_c_close_pp (dbc : PDBC);
  //int function __db_c_count_pp (dbc : PDBC; db_recno_t *, u_int32_t);
  //int function __db_c_del_pp (dbc : PDBC; u_int32_t);
  //int function __db_c_del_arg (dbc : PDBC; u_int32_t);
  //int function __db_c_dup_pp (dbc : PDBC; dbc : PDBC*, u_int32_t);
  //int function __db_c_get_pp (dbc : PDBC; dbt : PDBT; dbt : PDBT; u_int32_t);
  //int function __db_c_pget_pp (dbc : PDBC; dbt : PDBT; dbt : PDBT; dbt : PDBT; u_int32_t);
  //int function __db_c_put_pp (dbc : PDBC; dbt : PDBT; dbt : PDBT; u_int32_t);
  //int function __db_txn_auto_init (env : PDB_ENV; DB_TXN **);
  //int function __db_txn_auto_resolve (env : PDB_ENV; txn : PDB_TXN; int, int);
  //int function __db_join (db : PDB; dbc : PDBC*, dbc : PDBC*, u_int32_t);
  //int function __db_join_close (dbc : PDBC);
  //int function __db_secondary_corrupt (DB *);
  //int function __db_new (dbc : PDBC; u_int32_t, PAGE **);
  //int function __db_free (dbc : PDBC; PAGE *);
  //int function __db_lprint (dbc : PDBC);
  //int function __db_lget (dbc : PDBC; int, pgno : db_pgno_t; db_lockmode_t, u_int32_t, DB_LOCK *);
  //int function __db_lput (dbc : PDBC; DB_LOCK *);
  //int function __dbh_am_chk (db : PDB; u_int32_t);
  //int function __db_set_flags (db : PDB; u_int32_t);
  //int function __db_set_lorder (db : PDB; int);
  //int function __db_set_pagesize (db : PDB; u_int32_t);
  //int function __db_open (db : PDB; txn : PDB_TXN; const Pchar; const Pchar; DBTYPE, u_int32_t, int, db_pgno_t);
  //int function __db_get_open_flags (db : PDB; var p : u_int32_t);
  //int function __db_new_file (db : PDB; txn : PDB_TXN; fh : PDB_FH, const Pchar);
  //int function __db_init_subdb (db : PDB; db : PDB; const Pchar; DB_TXN *);
  //int function __db_chk_meta (env : PDB_ENV; db : PDB; DBMETA *, int);
  //int function __db_meta_setup (env : PDB_ENV; db : PDB; const Pchar; DBMETA *, u_int32_t, int);
  //int function __db_goff (db : PDB; dbt : PDBT; u_int32_t, pgno : db_pgno_t; void : pointer*, var p : u_int32_t);
  //int function __db_poff (dbc : PDBC; const dbt : PDBT; db_pgno_t *);
  //int function __db_ovref (dbc : PDBC; pgno : db_pgno_t; int32_t);
  //int function __db_doff (dbc : PDBC; db_pgno_t);
  //int function __db_moff (db : PDB; const dbt : PDBT; pgno : db_pgno_t; u_int32_t, int function (*)(db : PDB; const dbt : PDBT; const dbt : PDBT), int *);
  //int function __db_vrfy_overflow (db : PDB; VRFY_DBINFO *, page : PPAGE; pgno : db_pgno_t; u_int32_t);
  //int function __db_vrfy_ovfl_structure (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; u_int32_t, u_int32_t);
  //int function __db_safe_goff (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; dbt : PDBT; void : pointer; u_int32_t);
 procedure  ___db_loadme ();
   function  ___db_dump (db : PDB; p2:Pchar; p3:Pchar):integer;
  //procedure  __db_inmemdbflags (u_int32_t, void : pointer; void function (*)(u_int32_t, const FN *, void : pointer));
  procedure  ___db_inmemdbflags (u_int32_t, void : pointer; p3:Pointer);
  //int function __db_prnpage (db : PDB; pgno : db_pgno_t; FILE *);
  //int function __db_prpage (db : PDB; page : PPAGE; FILE *, u_int32_t);
  //void function __db_pr (u_int8_t *, u_int32_t, FILE *);
  //int function  __db_prdbt (dbt : PDBT; int, const Pchar; void : pointer; int function(*)(void : pointer; const void : pointer), int, VRFY_DBINFO *);
  function  ___db_prdbt (dbt : PDBT; p2:integer; const p3: Pchar; void : pointer; p5 : pointer; p6: integer; p7 : PVRFY_DBINFO):integer;
  //void function __db_prflags (u_int32_t, const FN *, void : pointer);
  //const Pchar function __db_dbtype_to_string (DBTYPE);
  //int function __db_prheader (db : PDB; Pchar; int, int, void : pointer; int function(*)(void : pointer; const void : pointer), VRFY_DBINFO *, db_pgno_t);
  function ___db_prheader (db : PDB; p1:Pchar; p2:integer; p3: integer; void : pointer; p4:Pointer; p5 : PVRFY_DBINFO; P6: db_pgno_t):integer;
  //int function __db_prfooter (void : pointer; int function  (*)(void : pointer; const void : pointer));
  function ___db_prfooter (void : pointer; p2:Pointer):integer;
  function ___db_pr_callback (void : pointer; const void2 : pointer):integer;
  //int function __db_addrem_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_big_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_ovref_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_relink_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_debug_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_noop_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_alloc_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_free_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_new_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_freedata_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_cksum_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_pg_prepare_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __db_traverse_big (db : PDB; pgno : db_pgno_t; int function (*)(db : PDB; page : PPAGE; void : pointer; int *), void : pointer);
  //int function __db_reclaim_callback (db : PDB; page : PPAGE; void : pointer; int *);
  //int function __db_truncate_callback (db : PDB; page : PPAGE; void : pointer; int *);
  //int function __dbenv_dbremove_pp (env : PDB_ENV; txn : PDB_TXN; const Pchar; const Pchar; u_int32_t);
  //int function __db_remove_pp (db : PDB; const Pchar; const Pchar; u_int32_t);
  //int function __db_remove (db : PDB; txn : PDB_TXN; const Pchar; const Pchar; u_int32_t);
  //int function __db_remove_int (db : PDB; txn : PDB_TXN; const Pchar; const Pchar; u_int32_t);
  //int function __dbenv_dbrename_pp (env : PDB_ENV; txn : PDB_TXN; const Pchar; const Pchar; const Pchar; u_int32_t);
  //int function __db_rename_pp (db : PDB; const Pchar; const Pchar; const Pchar; u_int32_t);
  //int function __db_rename (db : PDB; txn : PDB_TXN; const Pchar; const Pchar; const Pchar);
  //int function __db_rename_int (db : PDB; txn : PDB_TXN; const Pchar; const Pchar; const Pchar);
  //int function __db_ret (db : PDB; page : PPAGE; u_int32_t, dbt : PDBT; void : pointer*, var p : u_int32_t);
  //int function __db_retcopy (env : PDB_ENV; dbt : PDBT; void : pointer; u_int32_t, void : pointer*, var p : u_int32_t);
  //int function __db_truncate_pp (db : PDB; txn : PDB_TXN; var p : u_int32_t; u_int32_t);
  //int function __db_truncate (db : PDB; txn : PDB_TXN; var p : u_int32_t; u_int32_t);
  //int function __db_upgrade_pp (db : PDB; const Pchar; u_int32_t);
  //int function __db_upgrade (db : PDB; const Pchar; u_int32_t);
  //int function __db_lastpgno (db : PDB; Pchar; fh : PDB_FH, db_pgno_t *);
  //int function __db_31_offdup (db : PDB; Pchar; fh : PDB_FH, int, db_pgno_t *);
  //int function __db_verify_pp (db : PDB; const Pchar; const Pchar; FILE *, u_int32_t);
  //int function __db_verify_internal (db : PDB; const Pchar; const Pchar; void : pointer; int function  (*)(void : pointer; const void : pointer), u_int32_t);
  function ___db_verify_internal (db : PDB; const p2: Pchar; const p3:Pchar; void : pointer; p4:Pointer; p5: u_int32_t):Integer;
  //int function __db_verify (db : PDB; const Pchar; const Pchar; void : pointer; int function (*)(void : pointer; const void : pointer), u_int32_t);
  //int function  __db_vrfy_common (db : PDB; VRFY_DBINFO *, page : PPAGE; pgno : db_pgno_t; u_int32_t);
  //int function __db_vrfy_datapage (db : PDB; VRFY_DBINFO *, page : PPAGE; pgno : db_pgno_t; u_int32_t);
  //int function __db_vrfy_meta (db : PDB; VRFY_DBINFO *, DBMETA *, pgno : db_pgno_t; u_int32_t);
  //void function __db_vrfy_struct_feedback (db : PDB; VRFY_DBINFO *);
  //int function __db_salvage (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; page : PPAGE; void : pointer; int function(*)(void : pointer; const void : pointer), u_int32_t);
  //int function __db_vrfy_inpitem (db : PDB; page : PPAGE; pgno : db_pgno_t; u_int32_t, int, u_int32_t, var p : u_int32_t; var p : u_int32_t);
  //int function __db_vrfy_duptype (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; u_int32_t);
  //int function __db_salvage_duptree (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; dbt : PDBT; void : pointer; int function(*)(void : pointer; const void : pointer), u_int32_t);
  //int function __db_vrfy_dbinfo_create (env : PDB_ENV; u_int32_t, VRFY_DBINFO **);
  //int function __db_vrfy_dbinfo_destroy (env : PDB_ENV; VRFY_DBINFO *);
  //int function __db_vrfy_getpageinfo (VRFY_DBINFO *, pgno : db_pgno_t; VRFY_PAGEINFO **);
  //int function __db_vrfy_putpageinfo (env : PDB_ENV; VRFY_DBINFO *, VRFY_PAGEINFO *);
  //int function __db_vrfy_pgset (env : PDB_ENV; u_int32_t, DB **);
  //int function __db_vrfy_pgset_get (db : PDB; pgno : db_pgno_t; int *);
  //int function __db_vrfy_pgset_inc (db : PDB; db_pgno_t);
  //int function __db_vrfy_pgset_next (dbc : PDBC; db_pgno_t *);
  //int function __db_vrfy_childcursor (VRFY_DBINFO *, dbc : PDBC*);
  //int function __db_vrfy_childput (VRFY_DBINFO *, pgno : db_pgno_t; VRFY_CHILDINFO *);
  //int function __db_vrfy_ccset (dbc : PDBC; pgno : db_pgno_t; VRFY_CHILDINFO **);
  //int function __db_vrfy_ccnext (dbc : PDBC; VRFY_CHILDINFO **);
  //int function __db_vrfy_ccclose (dbc : PDBC);
  //int function  __db_salvage_init (VRFY_DBINFO *);
  //void function  __db_salvage_destroy (VRFY_DBINFO *);
  //int function __db_salvage_getnext (VRFY_DBINFO *, db_pgno_t *, var p : u_int32_t);
  //int function __db_salvage_isdone (VRFY_DBINFO *, db_pgno_t);
  //int function __db_salvage_markdone (VRFY_DBINFO *, db_pgno_t);
  //int function __db_salvage_markneeded (VRFY_DBINFO *, pgno : db_pgno_t; u_int32_t);

  //void function __db_shalloc_init (void : pointer; size_t);
  //int function __db_shalloc_size (size : size_t; size_t);
  //int function __db_shalloc (void : pointer; size : size_t; size : size_t; void : pointer);
  //void function __db_shalloc_free (void : pointer; void : pointer);
  //size_t function __db_shsizeof (void : pointer);
  //void function __db_shalloc_dump (void : pointer; FILE *);
  //int function __db_tablesize (u_int32_t);
  //void function __db_hashinit (void : pointer; u_int32_t);
  //int function __db_fileinit (env : PDB_ENV; fh : PDB_FH, size : size_t; int);
  function  ___db_overwrite (env : PDB_ENV; const p2:Pchar):integer;
  //int  function __dbenv_set_alloc (env : PDB_ENV; void : pointer function(*)(size_t), void : pointer function(*)(void : pointer; size_t), void function(*)(void : pointer));
  //int function __dbenv_get_encrypt_flags (env : PDB_ENV; var p : u_int32_t);
  //int function __dbenv_set_encrypt (env : PDB_ENV; const Pchar; u_int32_t);
  //int  function __dbenv_set_flags (env : PDB_ENV; u_int32_t, int);
  //int  function __dbenv_set_data_dir (env : PDB_ENV; const Pchar);
  //void function __dbenv_set_errcall (env : PDB_ENV; void function(*)(const Pchar; Pchar));
  //void function __dbenv_get_errfile (env : PDB_ENV; FILE **);
  //void function __dbenv_set_errfile (env : PDB_ENV; FILE *);
  //void function __dbenv_get_errpfx (env : PDB_ENV; const Pchar*);
  //void function __dbenv_set_errpfx (env : PDB_ENV; const Pchar);
  //int  function __dbenv_set_paniccall (env : PDB_ENV; void function(*)(env : PDB_ENV; int));
  //int  function __dbenv_set_shm_key (env : PDB_ENV; long);
  //int  function __dbenv_set_tas_spins (env : PDB_ENV; u_int32_t);
  //int  function __dbenv_set_tmp_dir (env : PDB_ENV; const Pchar);
  //int  function __dbenv_set_verbose (env : PDB_ENV; u_int32_t, int);
  //int function __db_mi_env (env : PDB_ENV; const Pchar);
  //int function __db_mi_open (env : PDB_ENV; const Pchar; int);
  //int function __db_env_config (env : PDB_ENV; Pchar; u_int32_t);
  //int function __dbenv_open (env : PDB_ENV; const Pchar; u_int32_t, int);
  //int function __dbenv_remove (env : PDB_ENV; const Pchar; u_int32_t);
  //int function __dbenv_close_pp (env : PDB_ENV; u_int32_t);
  //int function __dbenv_close (env : PDB_ENV; int);
  //int function __dbenv_get_open_flags (env : PDB_ENV; var p : u_int32_t);
  //int function __db_appname (env : PDB_ENV; APPNAME, const Pchar; u_int32_t, var fh : PDB_FH, Pchar*);
  //int function __db_home (env : PDB_ENV; const Pchar; u_int32_t);
  //int function __db_apprec (env : PDB_ENV; lsn : PDB_LSN; lsn : PDB_LSN; u_int32_t, u_int32_t);
  //int function __env_openfiles (env : PDB_ENV; DB_LOGC *, void : pointer; dbt : PDBT; lsn : PDB_LSN; lsn : PDB_LSN; double, int);
  //int function __db_e_attach (env : PDB_ENV; var p : u_int32_t);
  //int function __db_e_detach (env : PDB_ENV; int);
  //int function __db_e_remove (env : PDB_ENV; u_int32_t);
  function ___db_e_stat (env : PDB_ENV; regenv : PREGENV; region : PREGION; var P4:integer; p5: u_int32_t):integer;
  function  ___db_r_attach (env : PDB_ENV; reginfo: PREGINFO; p3: size_t):integer;
  function  ___db_r_detach (env : PDB_ENV; p2: PREGINFO; p3:integer):integer;

  //int function __fop_create_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, const dbt : PDBT; u_int32_t, u_int32_t);
  //int function __fop_create_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_create_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_create_read (env : PDB_ENV; void : pointer; __fop_create_args **);
  //int function __fop_remove_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, const dbt : PDBT; const dbt : PDBT; u_int32_t);
  //int function __fop_remove_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_remove_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_remove_read (env : PDB_ENV; void : pointer; __fop_remove_args **);
  //int function __fop_write_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, const dbt : PDBT; u_int32_t, u_int32_t, pgno : db_pgno_t; u_int32_t, const dbt : PDBT; u_int32_t);
  //int function __fop_write_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_write_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_write_read (env : PDB_ENV; void : pointer; __fop_write_args **);
  //int function __fop_rename_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, const dbt : PDBT; const dbt : PDBT; const dbt : PDBT; u_int32_t);
  //int function __fop_rename_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_rename_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_rename_read (env : PDB_ENV; void : pointer; __fop_rename_args **);
  //int function __fop_file_remove_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, const dbt : PDBT; const dbt : PDBT; const dbt : PDBT; u_int32_t, u_int32_t);
  //int function __fop_file_remove_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_file_remove_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_file_remove_read (env : PDB_ENV; void : pointer; __fop_file_remove_args **);
  //int function __fop_init_print (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  function ___fop_init_print (env : PDB_ENV; p2: Pointer; var size : size_t):integer ;
  //int function __fop_init_getpgnos (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __fop_init_recover (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __fop_create (env : PDB_ENV; txn : PDB_TXN; var fh : PDB_FH, const Pchar; APPNAME, int, u_int32_t);
  //int function __fop_remove (env : PDB_ENV; txn : PDB_TXN; u_int8_t *, const Pchar; APPNAME, u_int32_t);
  //int function __fop_write (env : PDB_ENV; txn : PDB_TXN; const Pchar; APPNAME, fh : PDB_FH, u_int32_t, pgno : db_pgno_t; u_int32_t, u_int8_t *, u_int32_t, u_int32_t, u_int32_t);
  //int function __fop_rename (env : PDB_ENV; txn : PDB_TXN; const Pchar; const Pchar; u_int8_t *, APPNAME, u_int32_t);
  //int function __fop_create_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_remove_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_write_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_rename_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_file_remove_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __fop_lock_handle (env : PDB_ENV; db : PDB; u_int32_t, db_lockmode_t, DB_LOCK *, u_int32_t);
  //int function __fop_file_setup (db : PDB; txn : PDB_TXN; const Pchar; int, u_int32_t, var p : u_int32_t);
  //int function __fop_subdb_setup (db : PDB; txn : PDB_TXN; const Pchar; const Pchar; int, u_int32_t);
  //int function __fop_remove_setup (db : PDB; txn : PDB_TXN; const Pchar; u_int32_t);
  //int function __fop_read_meta (env : PDB_ENV; const Pchar; u_int8_t *, size : size_t; fh : PDB_FH, int, var size : size_t);
  //int function __fop_dummy (db : PDB; txn : PDB_TXN; const Pchar; const Pchar; u_int32_t);
  //int function __fop_dbrename (db : PDB; const Pchar; const Pchar);

  //int function __ham_quick_delete (dbc : PDBC);
  //int function __ham_c_init (dbc : PDBC);
  //int function __ham_c_count (dbc : PDBC; db_recno_t *);
  //int function __ham_c_dup (dbc : PDBC; dbc : PDBC);
  //u_int32_t function __ham_call_hash (dbc : PDBC; u_int8_t *, int32_t);
  //int function __ham_init_dbt (env : PDB_ENV; dbt : PDBT; u_int32_t, void : pointer*, var p : u_int32_t);
  //int function __ham_c_update (dbc : PDBC; u_int32_t, int, int);
  //int function __ham_get_clist (db : PDB; pgno : db_pgno_t; u_int32_t, dbc : PDBC**);
  //int function __ham_insdel_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, pgno : db_pgno_t; u_int32_t, lsn : PDB_LSN; const dbt : PDBT; const dbt : PDBT);
  //int function __ham_insdel_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_insdel_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_insdel_read (env : PDB_ENV; void : pointer; __ham_insdel_args **);
  //int function __ham_newpage_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; lsn : PDB_LSN);
  //int function __ham_newpage_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_newpage_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_newpage_read (env : PDB_ENV; void : pointer; __ham_newpage_args **);
  //int function __ham_splitdata_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, pgno : db_pgno_t; const dbt : PDBT; lsn : PDB_LSN);
  //int function __ham_splitdata_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_splitdata_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_splitdata_read (env : PDB_ENV; void : pointer; __ham_splitdata_args **);
  //int function __ham_replace_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; u_int32_t, lsn : PDB_LSN; int32_t, const dbt : PDBT; const dbt : PDBT; u_int32_t);
  //int function __ham_replace_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_replace_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_replace_read (env : PDB_ENV; void : pointer; __ham_replace_args **);
  //int function __ham_copypage_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; lsn : PDB_LSN; const dbt : PDBT);
  //int function __ham_copypage_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_copypage_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_copypage_read (env : PDB_ENV; void : pointer; __ham_copypage_args **);
  //int function __ham_metagroup_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; lsn : PDB_LSN; pgno : db_pgno_t; lsn : PDB_LSN; u_int32_t);
  //int function __ham_metagroup_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_metagroup_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_metagroup_read (env : PDB_ENV; void : pointer; __ham_metagroup_args **);
  //int function __ham_groupalloc_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, lsn : PDB_LSN; pgno : db_pgno_t; u_int32_t, db_pgno_t);
  //int function __ham_groupalloc_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_groupalloc_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_groupalloc_read (env : PDB_ENV; void : pointer; __ham_groupalloc_args **);
  //int function __ham_curadj_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, pgno : db_pgno_t; u_int32_t, u_int32_t, u_int32_t, int, int, u_int32_t);
  //int function __ham_curadj_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_curadj_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_curadj_read (env : PDB_ENV; void : pointer; __ham_curadj_args **);
  //int function __ham_chgpg_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, db_ham_mode, pgno : db_pgno_t; pgno : db_pgno_t; u_int32_t, u_int32_t);
  //int function __ham_chgpg_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_chgpg_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_chgpg_read (env : PDB_ENV; void : pointer; __ham_chgpg_args **);
  //function  __ham_init_print (env : PDB_ENV; int function(***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t):integer;
  function  ___ham_init_print (env : PDB_ENV; p2:Pointer; var size : size_t):integer;
  //int function __ham_init_getpgnos (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __ham_init_recover (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  function  ___ham_pgin (env : PDB_ENV; db : PDB; pgno : db_pgno_t; void : pointer; dbt : PDBT):integer;
  function  ___ham_pgout (env : PDB_ENV; db : PDB; pgno : db_pgno_t; void : pointer; dbt : PDBT):integer;
  //int function __ham_mswap (void : pointer);
  //int function __ham_add_dup (dbc : PDBC; dbt : PDBT; u_int32_t, db_pgno_t *);
  //int function __ham_dup_convert (dbc : PDBC);
  //int function __ham_make_dup (env : PDB_ENV; const dbt : PDBT; dbt : PDBTd, void : pointer*, var p : u_int32_t);
  //void function __ham_dsearch (dbc : PDBC; dbt : PDBT; var p : u_int32_t; int *, u_int32_t);
  //void function __ham_cprint (dbc : PDBC);
  function  ___ham_func2 (db : PDB; const void : pointer; p3:u_int32_t):u_int32_t;
   function  ___ham_func3 (db : PDB; const void : pointer; p3:u_int32_t):u_int32_t;
  function  ___ham_func4 (db : PDB; const void : pointer; p3:u_int32_t):u_int32_t;
  function  ___ham_func5 (db : PDB; const void : pointer; p3:u_int32_t):u_int32_t;
  function ___ham_test (db : PDB; const void : pointer; p3:u_int32_t):u_int32_t;
  function ___ham_get_meta (dbc : PDBC):integer;
  function ___ham_release_meta (dbc : PDBC):integer;
  //int function __ham_dirty_meta (dbc : PDBC);
  //int function __ham_db_create (DB *);
  //int function __ham_db_close (DB *);
  //int function __ham_open (db : PDB; txn : PDB_TXN; const Pchar name, pgno : db_pgno_t; u_int32_t);
  //int function __ham_metachk (db : PDB; const Pchar; HMETA *);
  //int function __ham_new_file (db : PDB; txn : PDB_TXN; fh : PDB_FH, const Pchar);
  //int function __ham_new_subdb (db : PDB; db : PDB; DB_TXN *);
  //int function __ham_item (dbc : PDBC; db_lockmode_t, db_pgno_t *);
  //int function __ham_item_reset (dbc : PDBC);
  //void function __ham_item_init (dbc : PDBC);
  //int function __ham_item_last (dbc : PDBC; db_lockmode_t, db_pgno_t *);
  //int function __ham_item_first (dbc : PDBC; db_lockmode_t, db_pgno_t *);
  //int function __ham_item_prev (dbc : PDBC; db_lockmode_t, db_pgno_t *);
  //int function __ham_item_next (dbc : PDBC; db_lockmode_t, db_pgno_t *);
  //void function __ham_putitem (db : PDB; PAGE *p, const dbt : PDBT; int);
  //void function __ham_reputpair  (db : PDB; page : PPAGE; u_int32_t, const dbt : PDBT; const dbt : PDBT);
  //int function __ham_del_pair (dbc : PDBC; int);
  //int function __ham_replpair (dbc : PDBC; dbt : PDBT; u_int32_t);
  //void function __ham_onpage_replace (db : PDB; page : PPAGE; u_int32_t, int32_t, int32_t,  dbt : PDBT);
  //int function __ham_split_page (dbc : PDBC; u_int32_t, u_int32_t);
  //int function __ham_add_el (dbc : PDBC; const dbt : PDBT; const dbt : PDBT; int);
  //void function __ham_copy_item (db : PDB; page : PPAGE; u_int32_t, PAGE *);
  //int function __ham_add_ovflpage (dbc : PDBC; page : PPAGE; int, PAGE **);
  //int function __ham_get_cpage (dbc : PDBC; db_lockmode_t);
  //int function __ham_next_cpage (dbc : PDBC; pgno : db_pgno_t; int);
  //int function __ham_lock_bucket (dbc : PDBC; db_lockmode_t);
  //void function __ham_dpair (db : PDB; page : PPAGE; u_int32_t);
  //int function __ham_insdel_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_newpage_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_replace_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_splitdata_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_copypage_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_metagroup_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_groupalloc_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_curadj_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_chgpg_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __ham_reclaim (db : PDB; DB_TXN *txn);
  //int function __ham_truncate (dbc : PDBC; var p : u_int32_t);
  //int function __ham_stat (dbc : PDBC; void : pointer; u_int32_t);
  //int function __ham_traverse (dbc : PDBC; db_lockmode_t, int function (*)(db : PDB; page : PPAGE; void : pointer; int *), void : pointer; int);
  //int function __db_no_hash_am (env : PDB_ENV);
  //int function __ham_30_hashmeta (db : PDB; Pchar; u_int8_t *);
  //int function __ham_30_sizefix (db : PDB; fh : PDB_FH, Pchar; u_int8_t *);
  //int function __ham_31_hashmeta (db : PDB; Pchar; u_int32_t, fh : PDB_FH, page : PPAGE; int *);
  //int function __ham_31_hash (db : PDB; Pchar; u_int32_t, fh : PDB_FH, page : PPAGE; int *);
  //int function __ham_vrfy_meta (db : PDB; VRFY_DBINFO *, HMETA *, pgno : db_pgno_t; u_int32_t);
  //int function __ham_vrfy (db : PDB; VRFY_DBINFO *, page : PPAGE; pgno : db_pgno_t; u_int32_t);
  //int function __ham_vrfy_structure (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; u_int32_t);
  //int function __ham_vrfy_hashing (db : PDB; u_int32_t, HMETA *, u_int32_t, pgno : db_pgno_t; u_int32_t, u_int32_t function(*) (db : PDB; const void : pointer; u_int32_t)));
  //int function __ham_salvage (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; page : PPAGE; void : pointer; int function (*)(void : pointer; const void : pointer), u_int32_t);
  //int function __ham_meta2pgset (db : PDB; VRFY_DBINFO *, HMETA *, u_int32_t, DB *);
  
  //int function __lock_id_pp (env : PDB_ENV; var p : u_int32_t);
  //int function __lock_id (env : PDB_ENV; var p : u_int32_t);
  //int function __lock_id_free_pp (env : PDB_ENV; u_int32_t);
  //int function __lock_id_free (env : PDB_ENV; u_int32_t);
  //int function __lock_vec_pp (env : PDB_ENV; u_int32_t, u_int32_t, DB_LOCKREQ *, int, DB_LOCKREQ **);
  //int function __lock_vec (env : PDB_ENV; u_int32_t, u_int32_t, DB_LOCKREQ *, int, DB_LOCKREQ **);
  //int function __lock_get_pp (env : PDB_ENV; u_int32_t, u_int32_t, const dbt : PDBT; db_lockmode_t, DB_LOCK *);
  //int function __lock_get (env : PDB_ENV; u_int32_t, u_int32_t, const dbt : PDBT; db_lockmode_t, DB_LOCK *);
  //int function __lock_put_pp (env : PDB_ENV; DB_LOCK *);
  //int function __lock_put (env : PDB_ENV; DB_LOCK *);
  //int function __lock_downgrade (env : PDB_ENV; DB_LOCK *, db_lockmode_t, u_int32_t);
  //int function __lock_addfamilylocker (env : PDB_ENV; u_int32_t, u_int32_t);
  //int function __lock_freefamilylocker  (DB_LOCKTAB *, u_int32_t);
  //int function __lock_set_timeout ( env : PDB_ENV; u_int32_t, db_timeout_t, u_int32_t);
  //int function __lock_inherit_timeout ( env : PDB_ENV; u_int32_t, u_int32_t);
  //int function __lock_getlocker (DB_LOCKTAB *, u_int32_t, u_int32_t, int, DB_LOCKER **);
  //int function __lock_promote (DB_LOCKTAB *, DB_LOCKOBJ *, u_int32_t);
  //int function __lock_expired (env : PDB_ENV; db_timeval_t *, db_timeval_t *);
  //int function __lock_get_list (env : PDB_ENV; u_int32_t, u_int32_t, db_lockmode_t, dbt : PDBT);
  //int function __lock_detect_pp (env : PDB_ENV; u_int32_t, u_int32_t, int *);
  //int function __lock_detect (env : PDB_ENV; u_int32_t, int *);
  //void function __lock_dbenv_create (env : PDB_ENV);
  //void function __lock_dbenv_close (env : PDB_ENV);
  //int function __lock_set_lk_detect (env : PDB_ENV; u_int32_t);
  //int function __lock_set_lk_max (env : PDB_ENV; u_int32_t);
  //int function __lock_set_lk_max_locks (env : PDB_ENV; u_int32_t);
  //int function __lock_set_lk_max_lockers (env : PDB_ENV; u_int32_t);
  //int function __lock_set_lk_max_objects (env : PDB_ENV; u_int32_t);
  //int function __lock_set_env_timeout (env : PDB_ENV; db_timeout_t, u_int32_t);
  function ___lock_open (env : PDB_ENV):integer;
  //int function __lock_dbenv_refresh (env : PDB_ENV);
  //void function __lock_region_destroy (env : PDB_ENV; REGINFO *);
  function ___lock_id_set (env : PDB_ENV; p2: u_int32_t; p3: u_int32_t):integer;
  //int function __lock_stat_pp (env : PDB_ENV; DB_LOCK_STAT **, u_int32_t);
  function ___lock_dump_region (env : PDB_ENV; const p2: Pchar; p3:PFILE ):Integer;
  //void function __lock_printlock (DB_LOCKTAB *, struct __db_lock *, int, FILE *);
  //int function __lock_cmp (const dbt : PDBT; DB_LOCKOBJ *);
  //int function __lock_locker_cmp (u_int32_t, DB_LOCKER *);
  //u_int32_t function __lock_ohash (const dbt : PDBT);
  //u_int32_t function __lock_lhash (DB_LOCKOBJ *);
  //u_int32_t function __lock_locker_hash (u_int32_t);
  
  
  //int function __memp_alloc (DB_MPOOL *, REGINFO *, MPOOLFILE *, size : size_t; roff_t *, void : pointer);
  //#ifdef DIAGNOSTIC
  //void function __memp_check_order (DB_MPOOL_HASH *);
  //#endif
  //int function __memp_bhwrite (DB_MPOOL *, DB_MPOOL_HASH *, MPOOLFILE *, BH *, int);
  //int function __memp_pgread (DB_MPOOLFILE *, mutex : PDB_MUTEX ; BH *, int);
  //int function __memp_pg (DB_MPOOLFILE *, BH *, int);
  //void function __memp_bhfree (DB_MPOOL *, DB_MPOOL_HASH *, BH *, int);
  //int function __memp_fget_pp (DB_MPOOLFILE *, db_pgno_t *, u_int32_t, void : pointer);
  //int function __memp_fget (DB_MPOOLFILE *, db_pgno_t *, u_int32_t, void : pointer);
  //int function __memp_fcreate_pp (env : PDB_ENV; DB_MPOOLFILE **, u_int32_t);
  //int function __memp_fcreate (env : PDB_ENV; DB_MPOOLFILE **);
  //int function __memp_set_clear_len (DB_MPOOLFILE *, u_int32_t);
  //int function __memp_get_fileid (DB_MPOOLFILE *, u_int8_t *);
  //int function __memp_set_fileid (DB_MPOOLFILE *, u_int8_t *);
  //int function __memp_set_flags (DB_MPOOLFILE *, u_int32_t, int);
  //int function __memp_get_ftype (DB_MPOOLFILE *, int *);
  //int function __memp_set_ftype (DB_MPOOLFILE *, int);
  //int function __memp_set_lsn_offset (DB_MPOOLFILE *, int32_t);
  //int function __memp_set_pgcookie (DB_MPOOLFILE *, dbt : PDBT);
  //int function __memp_fopen (DB_MPOOLFILE *, MPOOLFILE *, const Pchar; u_int32_t, int, size_t);
  //void function __memp_last_pgno (DB_MPOOLFILE *, db_pgno_t *);
  //int function __memp_fclose (DB_MPOOLFILE *, u_int32_t);
  //int function __memp_mf_sync (DB_MPOOL *, MPOOLFILE *);
  //int function __memp_mf_discard (DB_MPOOL *, MPOOLFILE *);
  //Pchar function __memp_fn (DB_MPOOLFILE *);
  //Pchar function __memp_fns (DB_MPOOL *, MPOOLFILE *);
  //int function __memp_fput_pp (DB_MPOOLFILE *, void : pointer; u_int32_t);
  //int function __memp_fput (DB_MPOOLFILE *, void : pointer; u_int32_t);
  //int function __memp_fset_pp (DB_MPOOLFILE *, void : pointer; u_int32_t);
  //int function __memp_fset (DB_MPOOLFILE *, void : pointer; u_int32_t);
  //void function __memp_dbenv_create (env : PDB_ENV);
  //int function __memp_get_cachesize (env : PDB_ENV; var p : u_int32_t; var p : u_int32_t; int *);
  //int function __memp_set_cachesize (env : PDB_ENV; u_int32_t, u_int32_t, int);
  //int function __memp_set_mp_mmapsize (env : PDB_ENV; size_t);
  //int function __memp_nameop (env : PDB_ENV; u_int8_t *, const Pchar; const Pchar; const Pchar);
  //int function __memp_get_refcnt (env : PDB_ENV; u_int8_t *, int *);
  //int function __memp_open (env : PDB_ENV);
  //int function __memp_dbenv_refresh (env : PDB_ENV);
  //void function __mpool_region_destroy (env : PDB_ENV; REGINFO *);
  //int function __memp_register_pp (env : PDB_ENV; int, int function  (*)(env : PDB_ENV; pgno : db_pgno_t; void : pointer; dbt : PDBT), int function  (*)(env : PDB_ENV; pgno : db_pgno_t; void : pointer; dbt : PDBT));
  //int function __memp_register (env : PDB_ENV; int, int function  (*)(env : PDB_ENV; pgno : db_pgno_t; void : pointer; dbt : PDBT), int function (*)(env : PDB_ENV; pgno : db_pgno_t; void : pointer; dbt : PDBT));
  //int function __memp_stat_pp (env : PDB_ENV; DB_MPOOL_STAT **, DB_MPOOL_FSTAT ***, u_int32_t);
  function ___memp_dump_region (env : PDB_ENV; const p2:Pchar; p3:PFILE): integer;
  //void function __memp_stat_hash (REGINFO *, MPOOL *, var p : u_int32_t);
  //int function __memp_sync_pp (env : PDB_ENV; lsn : PDB_LSN);
  //int function __memp_sync (env : PDB_ENV; lsn : PDB_LSN);
  //int function __memp_fsync_pp (DB_MPOOLFILE *);
  //int function __memp_fsync (DB_MPOOLFILE *);
  //int function __mp_xxx_fh (DB_MPOOLFILE *, var fh : PDB_FH);
  //int function __memp_sync_int (env : PDB_ENV; DB_MPOOLFILE *, int, db_sync_op, int *);
  //int function __memp_trickle_pp (env : PDB_ENV; int, int *);

  //int function __db_fcntl_mutex_init (env : PDB_ENV; mutex : PDB_MUTEX ; u_int32_t);
  //int function __db_fcntl_mutex_lock (env : PDB_ENV; mutex : PDB_MUTEX);
  //int function __db_fcntl_mutex_unlock (env : PDB_ENV; mutex : PDB_MUTEX);
  //int function __db_fcntl_mutex_destroy (mutex : PDB_MUTEX);
  //int function __db_pthread_mutex_init (env : PDB_ENV; mutex : PDB_MUTEX ; u_int32_t);
  //int function __db_pthread_mutex_lock (env : PDB_ENV; mutex : PDB_MUTEX);
  //int function __db_pthread_mutex_unlock (env : PDB_ENV; mutex : PDB_MUTEX);
  //int function __db_pthread_mutex_destroy (mutex : PDB_MUTEX);
  //int function __db_tas_mutex_init (env : PDB_ENV; mutex : PDB_MUTEX ; u_int32_t);
  //int function __db_tas_mutex_lock (env : PDB_ENV; mutex : PDB_MUTEX);
  //int function __db_tas_mutex_unlock (env : PDB_ENV; mutex : PDB_MUTEX);
  //int function __db_tas_mutex_destroy (mutex : PDB_MUTEX);
  function ___db_win32_mutex_init (env : PDB_ENV; mutex : PDB_MUTEX; p3:u_int32_t):integer;
  function ___db_win32_mutex_lock (env : PDB_ENV; mutex : PDB_MUTEX):integer;
  function ___db_win32_mutex_unlock (env : PDB_ENV; mutex : PDB_MUTEX):integer;
  //int function __db_win32_mutex_destroy (mutex : PDB_MUTEX);
  //int function __db_mutex_setup (env : PDB_ENV; REGINFO *, void : pointer; u_int32_t);
  //void function __db_mutex_free (env : PDB_ENV; REGINFO *, mutex : PDB_MUTEX);
  //void function __db_shreg_locks_clear (mutex : PDB_MUTEX ; REGINFO *, REGMAINT *);
  //void function __db_shreg_locks_destroy (REGINFO *, REGMAINT *);
  //int function __db_shreg_mutex_init (env : PDB_ENV; mutex : PDB_MUTEX ; u_int32_t, u_int32_t, REGINFO *, REGMAINT *);
  //void function __db_shreg_maintinit (REGINFO *, void : pointeraddr, size_t);
  
  //int function __os_abspath (const Pchar);
  function ___os_umalloc (env : PDB_ENV; size : size_t; void : pointer):integer;
  //int function __os_urealloc (env : PDB_ENV; size : size_t; void : pointer);
  procedure ___os_ufree (env : PDB_ENV; void : pointer);
   function ___os_strdup (env : PDB_ENV; const Pchar; void : pointer):integer;
   function ___os_calloc (env : PDB_ENV; size : size_t; size2 : size_t; void : pointer):integer;
   function ___os_malloc (env : PDB_ENV; size : size_t; void : pointer):integer;
   function ___os_realloc (env : PDB_ENV; size : size_t; void : pointer):integer;
  procedure ___os_free (env : PDB_ENV; void : pointer);
  //void : pointerfunction __ua_memcpy (void : pointer; const void : pointer; size_t);
   function  ___os_clock (env : PDB_ENV; var p2:u_int32_t; var p3: u_int32_t):integer;
  //int function __os_fs_notzero (void);
  //int function __os_dirlist (env : PDB_ENV; const Pchar; Pchar**, int *);
  //void function __os_dirfree (env : PDB_ENV; Pchar*, int);
  //int function __os_get_errno_ret_zero (void);
   function ___os_get_errno ():integer;
  procedure ___os_set_errno (p1:integer);
  //int function __os_fileid (env : PDB_ENV; const Pchar; int, u_int8_t *);
  //int function __os_fsync (env : PDB_ENV; fh : PDB_FH);
  function  ___os_openhandle (env : PDB_ENV; const p2: Pchar; p3: integer;p4: integer; var fh : PDB_FH):integer;
  function  ___os_closehandle (env : PDB_ENV; fh : PDB_FH):integer;
  procedure ___os_id (var p1: u_int32_t);
  //int function __os_r_sysattach (env : PDB_ENV; REGINFO *, REGION *);
  //int function __os_r_sysdetach (env : PDB_ENV; REGINFO *, int);
  //int function __os_mapfile (env : PDB_ENV; Pchar; fh : PDB_FH, size : size_t; int, void : pointer*);
  //int function __os_unmapfile (env : PDB_ENV; void : pointer; size_t);
  //u_int32_t function __db_oflags (int);
   function ___db_omode (const p1:Pchar): integer;
  //int function __os_have_direct (void);
   function  ___os_open (env : PDB_ENV; const p2:Pchar; p3:u_int32_t; p4: integer; var fh : PDB_FH):integer;
  //int function __os_open_extend (env : PDB_ENV; const Pchar; u_int32_t, u_int32_t, u_int32_t, int, var fh : PDB_FH);
  //#ifdef HAVE_QNX
  //int function __os_shmname (env : PDB_ENV; const Pchar; Pchar*);
  //#endif
  //int function __os_r_attach (env : PDB_ENV; REGINFO *, REGION *);
  //int function __os_r_detach (env : PDB_ENV; REGINFO *, int);
  //int function __os_rename (env : PDB_ENV; const Pchar; const Pchar; u_int32_t);
  //int function __os_isroot (void);
  function ___db_rpath (const Pchar):Pchar;
  //int function __os_io (env : PDB_ENV; int, fh : PDB_FH, pgno : db_pgno_t; size : size_t; u_int8_t *, var size : size_t);
  function  ___os_read (env : PDB_ENV; fh : PDB_FH; void : pointer; size : size_t; var size2 : size_t):integer;
  function  ___os_write (env : PDB_ENV; fh : PDB_FH; void : pointer; size : size_t; var size2 : size_t):integer;
  //int function __os_seek (env : PDB_ENV; fh : PDB_FH, size : size_t; pgno : db_pgno_t; u_int32_t, int, DB_OS_SEEK);
  function  ___os_sleep (env : PDB_ENV; p2:u_long; p3: u_long):integer;
  //void function __os_spin (env : PDB_ENV);
  procedure  ___os_yield (env:PDB_ENV; p2: u_long);
  //int function __os_exists (const Pchar; int *);
  function  ___os_ioinfo (env : PDB_ENV; const p2: Pchar; fh : PDB_FH; var p4 : u_int32_t; var p5 : u_int32_t; var p : u_int32_t):integer;
  //int function __os_tmpdir (env : PDB_ENV; u_int32_t);
  //int function __os_region_unlink (env : PDB_ENV; const Pchar);
  //int function __os_unlink (env : PDB_ENV; const Pchar);
  //int function __os_is_winnt (void);
  //#if defined(DB_WIN32)
  //int function __os_win32_errno (void);
  //#endif
  //int function __os_have_direct (void);


  //int function __qam_position (dbc : PDBC; db_recno_t *, qam_position_mode, int *);
  //int function __qam_pitem (dbc : PDBC;  Qpage : PPAGE; u_int32_t, db_recno_t, dbt : PDBT);
  //int function __qam_append (dbc : PDBC; dbt : PDBT; dbt : PDBT);
  //int function __qam_c_dup (dbc : PDBC; dbc : PDBC);
  //int function __qam_c_init (dbc : PDBC);
  //int function __qam_truncate (dbc : PDBC; var p : u_int32_t);
  //int function __qam_incfirst_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, db_recno_t, db_pgno_t);
  //int function __qam_incfirst_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_incfirst_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_incfirst_read (env : PDB_ENV; void : pointer; __qam_incfirst_args **);
  //int function __qam_mvptr_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, db_recno_t, db_recno_t, db_recno_t, db_recno_t, lsn : PDB_LSN; db_pgno_t);
  //int function __qam_mvptr_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_mvptr_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_mvptr_read (env : PDB_ENV; void : pointer; __qam_mvptr_args **);
  //int function __qam_del_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, lsn : PDB_LSN; pgno : db_pgno_t; u_int32_t, db_recno_t);
  //int function __qam_del_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_del_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_del_read (env : PDB_ENV; void : pointer; __qam_del_args **);
  //int function __qam_add_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, lsn : PDB_LSN; pgno : db_pgno_t; u_int32_t, db_recno_t, const dbt : PDBT; u_int32_t, const dbt : PDBT);
  //int function __qam_add_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_add_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_add_read (env : PDB_ENV; void : pointer; __qam_add_args **);
  //int function __qam_delext_log (db : PDB; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, lsn : PDB_LSN; pgno : db_pgno_t; u_int32_t, db_recno_t, const dbt : PDBT);
  //int function __qam_delext_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_delext_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_delext_read (env : PDB_ENV; void : pointer; __qam_delext_args **);
  //int function __qam_init_print (env : PDB_ENV; int function (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
   function ___qam_init_print (env : PDB_ENV; p2 : pointer; var size : size_t):integer;
  //int function __qam_init_getpgnos (env : PDB_ENV; int function (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __qam_init_recover (env : PDB_ENV; int function (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __qam_mswap (PAGE *);
   function ___qam_pgin_out (env : PDB_ENV; pgno : db_pgno_t; void : pointer; dbt : PDBT):integer;
  //int function __qam_fprobe (db : PDB; pgno : db_pgno_t; void : pointer; qam_probe_mode, u_int32_t);
  //int function __qam_fclose (db : PDB; db_pgno_t);
  //int function __qam_fremove (db : PDB; db_pgno_t);
  //int function __qam_sync (DB *);
  //int function __qam_gen_filelist ( db : PDB; QUEUE_FILELIST **);
  //int function __qam_extent_names (env : PDB_ENV; Pchar; Pchar**);
  //void function  __qam_exid (db : PDB; u_int8_t *, u_int32_t);
  //int function __qam_nameop (db : PDB; txn : PDB_TXN; const Pchar; qam_name_op);
  //int function __qam_db_create (DB *);
  //int function __qam_db_close (db : PDB; u_int32_t);
  //int function __db_prqueue (db : PDB; FILE *, u_int32_t);
  //int function __qam_remove (db : PDB; txn : PDB_TXN; const Pchar; const Pchar; lsn : PDB_LSN);
  //int function __qam_rename (db : PDB; txn : PDB_TXN; const Pchar; const Pchar; const Pchar);
  //int function __qam_open (db : PDB; txn : PDB_TXN; const Pchar; pgno : db_pgno_t; int, u_int32_t);
  //int function __qam_set_ext_data (DB*, const Pchar);
  //int function __qam_metachk (db : PDB; const Pchar; QMETA *);
  //int function __qam_new_file (db : PDB; txn : PDB_TXN; fh : PDB_FH, const Pchar);
  //int function __qam_incfirst_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_mvptr_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_del_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_delext_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_add_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __qam_stat (dbc : PDBC; void : pointer; u_int32_t);
  //int function __db_no_queue_am (env : PDB_ENV);
  //int function __qam_31_qammeta (db : PDB; Pchar; u_int8_t *);
  //int function __qam_32_qammeta (db : PDB; Pchar; u_int8_t *);
  //int function __qam_vrfy_meta (db : PDB; VRFY_DBINFO *, QMETA *, pgno : db_pgno_t; u_int32_t);
  //int function __qam_vrfy_data (db : PDB; VRFY_DBINFO *, Qpage : PPAGE; pgno : db_pgno_t; u_int32_t);
  //int function __qam_vrfy_structure (db : PDB; VRFY_DBINFO *, u_int32_t);
  //int function __qam_vrfy_walkqueue (db : PDB; VRFY_DBINFO *, void : pointer; int function(*)(void : pointer; const void : pointer), u_int32_t);
  //int function __qam_salvage (db : PDB; VRFY_DBINFO *, pgno : db_pgno_t; page : PPAGE; void : pointer; int function  (*)(void : pointer; const void : pointer), u_int32_t);

  //int function __txn_begin_pp (env : PDB_ENV; txn : PDB_TXN; var txn : PDB_TXN; u_int32_t);
  //int function __txn_begin (env : PDB_ENV; txn : PDB_TXN; var txn : PDB_TXN; u_int32_t);
  //int function __txn_xa_begin (env : PDB_ENV; DB_TXN *);
  //int function __txn_compensate_begin (env : PDB_ENV; DB_TXN **txnp);
  //int function __txn_commit (txn : PDB_TXN; u_int32_t);
  //int function __txn_abort (DB_TXN *);
  //int function __txn_discard (txn : PDB_TXN; u_int32_t flags);
  //int function __txn_prepare (txn : PDB_TXN; u_int8_t *);
  //u_int32_t function __txn_id (DB_TXN *);
  //int  function __txn_set_timeout (txn : PDB_TXN; db_timeout_t, u_int32_t);
  //int function __txn_checkpoint_pp (env : PDB_ENV; u_int32_t, u_int32_t, u_int32_t);
  //int function __txn_checkpoint (env : PDB_ENV; u_int32_t, u_int32_t, u_int32_t);
  //int function __txn_getckp (env : PDB_ENV; lsn : PDB_LSN);
  //int function __txn_activekids (env : PDB_ENV; u_int32_t, DB_TXN *);
  //int function __txn_force_abort (env : PDB_ENV; u_int8_t *);
  //int function __txn_preclose (env : PDB_ENV);
  //int function __txn_reset (env : PDB_ENV);
  //void function __txn_updateckp (env : PDB_ENV; lsn : PDB_LSN);
  //int function __txn_regop_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, int32_t, const dbt : PDBT);
  //int function __txn_regop_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_regop_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_regop_read (env : PDB_ENV; void : pointer; __txn_regop_args **);
  //int function __txn_ckp_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, lsn : PDB_LSN; lsn : PDB_LSN; int32_t, u_int32_t);
  //int function __txn_ckp_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_ckp_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_ckp_read (env : PDB_ENV; void : pointer; __txn_ckp_args **);
  //int function __txn_child_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, lsn : PDB_LSN);
  //int function __txn_child_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_child_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_child_read (env : PDB_ENV; void : pointer; __txn_child_args **);
  //int function __txn_xa_regop_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, const dbt : PDBT; int32_t, u_int32_t, u_int32_t, lsn : PDB_LSN; const dbt : PDBT);
  //int function __txn_xa_regop_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_xa_regop_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_xa_regop_read (env : PDB_ENV; void : pointer; __txn_xa_regop_args **);
  //int function __txn_recycle_log (env : PDB_ENV; txn : PDB_TXN; lsn : PDB_LSN; u_int32_t, u_int32_t, u_int32_t);
  //int function __txn_recycle_getpgnos (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_recycle_print (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_recycle_read (env : PDB_ENV; void : pointer; __txn_recycle_args **);
   //function  __txn_init_print (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t):integer;
   function  ___txn_init_print (env : PDB_ENV; p2:pointer; var size : size_t):integer;
  //int function __txn_init_getpgnos (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //int function __txn_init_recover (env : PDB_ENV; int (***)(env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer), var size : size_t);
  //void function __txn_dbenv_create (env : PDB_ENV);
  //int function __txn_set_tx_max (env : PDB_ENV; u_int32_t);
  //int function __txn_regop_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_xa_regop_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_ckp_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_child_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //int function __txn_restore_txn (env : PDB_ENV; lsn : PDB_LSN; __txn_xa_regop_args *);
  //int function __txn_recycle_recover (env : PDB_ENV; dbt : PDBT; lsn : PDB_LSN; db_recops, void : pointer);
  //void function __txn_continue (env : PDB_ENV; txn : PDB_TXN; TXN_DETAIL *, size_t);
  //int function __txn_map_gid (env : PDB_ENV; u_int8_t *, TXN_DETAIL **, var size : size_t);
  //int function __txn_recover_pp (env : PDB_ENV; DB_PREPLIST *, long, long *, u_int32_t);
  //int function __txn_recover (env : PDB_ENV; DB_PREPLIST *, long, long *, u_int32_t);
  //int function __txn_get_prepared (env : PDB_ENV; XID *, DB_PREPLIST *, long, long *, u_int32_t);
  //int function __txn_open (env : PDB_ENV);
  //int function __txn_dbenv_refresh (env : PDB_ENV);
  //void function __txn_region_destroy (env : PDB_ENV; REGINFO *);
   function ___txn_id_set (env : PDB_ENV; p2: u_int32_t; p3: u_int32_t):integer;
  //int function __txn_stat_pp (env : PDB_ENV; DB_TXN_STAT **, u_int32_t);
  //int function __txn_closeevent (env : PDB_ENV; txn : PDB_TXN; DB *);
  //int function __txn_remevent (env : PDB_ENV; txn : PDB_TXN; const Pchar; u_int8_t*);
  //void function __txn_remrem (env : PDB_ENV; txn : PDB_TXN; const Pchar);
  //int function __txn_lockevent (env : PDB_ENV; txn : PDB_TXN; db : PDB; DB_LOCK *, u_int32_t);
  //void function __txn_remlock (env : PDB_ENV; txn : PDB_TXN; DB_LOCK *, u_int32_t);
  //int function __txn_doevents (env : PDB_ENV; txn : PDB_TXN; int, int);
  
  



implementation
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\btree_auto.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_compare.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_conv.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_curadj.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_cursor.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_delete.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_method.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_open.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_put.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_rec.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_reclaim.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_recno.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_rsearch.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_search.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_split.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_stat.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_upgrade.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\bt_verify.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\crdel_auto.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\crdel_rec.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\crypto_stub.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db.obj         '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\dbm.obj        '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\dbreg.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\dbreg_auto.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\dbreg_rec.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\dbreg_util.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_am.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_auto.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_byteorder.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_cam.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_conv.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_dispatch.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_dup.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_err.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_getlong.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_idspace.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_iface.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_join.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_log2.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_meta.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_method.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_open.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_overflow.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_ovfl_vrfy.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_pr.obj       '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_rec.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_reclaim.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_remove.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_rename.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_ret.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_salloc.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_shash.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_truncate.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_upg.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_upg_opd.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_vrfy.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\db_vrfyutil.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\env_file.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\env_method.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\env_open.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\env_recover.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\env_region.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\fileops_auto.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\fop_basic.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\fop_rec.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\fop_util.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash.obj        '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_auto.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_conv.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_dup.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_func.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_meta.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_method.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_open.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_page.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_rec.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_reclaim.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_stat.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_upgrade.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hash_verify.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hmac.obj        '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\hsearch.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\lock.obj        '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\lock_deadlock.obj'}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\lock_method.obj '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\lock_region.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\lock_stat.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\lock_util.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\log.obj          '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\log_archive.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\log_compare.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\log_get.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\log_method.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\log_put.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_alloc.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_bh.obj        '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_fget.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_fopen.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_fput.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_fset.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_method.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_region.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_register.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_stat.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_sync.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mp_trickle.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mutex.obj        '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\mut_win32.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_abs.obj       '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_alloc.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_clock.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_config.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_dir.obj       '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_errno.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_fid.obj       '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_fsync.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_handle.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_id.obj        '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_map.obj       '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_method.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_oflags.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_open.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_region.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_rename.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_root.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_rpath.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_rw.obj        '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_seek.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_sleep.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_spin.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_stat.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_tmpdir.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\os_unlink.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\qam.obj          '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\qam_auto.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\qam_conv.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\qam_files.obj    '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\qam_method.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\qam_open.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\qam_rec.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\qam_stat.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\qam_upgrade.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\qam_verify.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\rep_method.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\rep_record.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\rep_region.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\rep_util.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\sha1.obj         '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\strcasecmp.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\txn.obj          '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\txn_auto.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\txn_method.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\txn_rec.obj      '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\txn_recover.obj  '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\txn_region.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\txn_stat.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\txn_util.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\util_cache.obj   '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\util_log.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\util_sig.obj     '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\xa.obj           '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\xa_db.obj        '}
{$L 'P:\Berkeley DB\db-4.2.52.NC\Obj\xa_map.obj       '}

                                                      
                                                      

                                                      
  function _db_create             ;      external; // dblib name '_db_create'              ;
  //function db_env_create          ;      external dblib name '_db_env_create'          ;
  function _db_strerror            ;      external; // dblib name '_db_strerror'            ;
  function _db_version             ;      external; // dblib name '_db_version'             ;

  function _log_compare            ;      external; // dblib name '_log_compare'            ;
  function _db_env_set_func_close  ;      external; // dblib name '_db_env_set_func_close'  ;
  function _db_env_set_func_dirfree;      external; // dblib name '_db_env_set_func_dirfree';
  function _db_env_set_func_dirlist;      external; // dblib name '_db_env_set_func_dirlist';
  function _db_env_set_func_exists ;      external; // dblib name '_db_env_set_func_exists' ;
  function _db_env_set_func_free   ;      external; // dblib name '_db_env_set_func_free'   ;
  function _db_env_set_func_fsync  ;      external; // dblib name '_db_env_set_func_fsync'  ;
  function _db_env_set_func_ioinfo ;      external; // dblib name '_db_env_set_func_ioinfo' ;
  function _db_env_set_func_malloc ;      external; // dblib name '_db_env_set_func_malloc' ;
  function _db_env_set_func_map    ;      external; // dblib name '_db_env_set_func_map'    ;
  function _db_env_set_func_open   ;      external; // dblib name '_db_env_set_func_open'   ;
  function _db_env_set_func_read   ;      external; // dblib name '_db_env_set_func_read'   ;
  function _db_env_set_func_realloc;      external; // dblib name '_db_env_set_func_realloc';
  function _db_env_set_func_rename ;      external; // dblib name '_db_env_set_func_rename' ;
  function _db_env_set_func_seek   ;      external; // dblib name '_db_env_set_func_seek'   ;
  function _db_env_set_func_sleep  ;      external; // dblib name '_db_env_set_func_sleep'  ;
  function _db_env_set_func_unlink ;      external; // dblib name '_db_env_set_func_unlink' ;
  function _db_env_set_func_unmap  ;      external; // dblib name '_db_env_set_func_unmap'  ;
  function _db_env_set_func_write  ;      external; // dblib name '_db_env_set_func_write'  ;
  function _db_env_set_func_yield  ;      external; // dblib name '_db_env_set_func_yield'  ;

	function  ___db_add_recovery      ;	     external; // dblib name '___db_add_recovery'      ;
	function  ___db_dbm_close	        ;      external; // dblib name '___db_dbm_close'         ;
	function  ___db_dbm_delete	      ;      external; // dblib name '___db_dbm_delete'        ;
	function  ___db_dbm_fetch	        ;      external; // dblib name '___db_dbm_fetch'         ;
	function  ___db_dbm_firstkey      ;	     external; // dblib name '___db_dbm_firstkey'      ;
	function  ___db_dbm_init	        ;      external; // dblib name '___db_dbm_init'          ;
	function  ___db_dbm_nextkey	      ;      external; // dblib name '___db_dbm_nextkey'       ;
	function  ___db_dbm_store	        ;      external; // dblib name '___db_dbm_store'         ;
	function  ___db_hcreate	          ;      external; // dblib name '___db_hcreate'           ;
	procedure ___db_hdestroy	        ;      external; // dblib name '___db_hdestroy'          ;
	//function __db_hsearch	          ;      external; // dblib name '___db_hsearch'           ;
	procedure ___db_loadme	          ;      external; // dblib name '___db_loadme'          ;
  function  ___db_ndbm_clearerr     ;      external; // dblib name '___db_ndbm_clearerr'     ;
	procedure ___db_ndbm_close	      ;      external; // dblib name '___db_ndbm_close'        ;
	function  ___db_ndbm_delete	      ;      external; // dblib name '___db_ndbm_delete'       ;
	function  ___db_ndbm_dirfno	      ;      external; // dblib name '___db_ndbm_dirfno'       ;
	function  ___db_ndbm_error	      ;      external; // dblib name '___db_ndbm_error'        ;
	function  ___db_ndbm_fetch	      ;      external; // dblib name '___db_ndbm_fetch'        ;
	function  ___db_ndbm_firstkey     ;	     external; // dblib name '___db_ndbm_firstkey'     ;
	function  ___db_ndbm_nextkey      ;	     external; // dblib name '___db_ndbm_nextkey'      ;
	function  ___db_ndbm_open	        ;      external; // dblib name '___db_ndbm_open'         ;
	function  ___db_ndbm_pagfno	      ;      external; // dblib name '___db_ndbm_pagfno'       ;
	function  ___db_ndbm_rdonly	      ;      external; // dblib name '___db_ndbm_rdonly'       ;
	function  ___db_ndbm_store	      ;      external; // dblib name '___db_ndbm_store'        ;
  //
	function ___db_panic	            ;      external; // dblib name '___db_panic'             ;
	function ___db_r_attach	        ;      external; // dblib name '___db_r_attach'          ;
	function ___db_r_detach	        ;      external; // dblib name '___db_r_detach'          ;
	function ___db_win32_mutex_init  ;	     external; // dblib name '___db_win32_mutex_init'  ;
	function ___db_win32_mutex_lock  ;	     external; // dblib name '___db_win32_mutex_lock'  ;
	function ___db_win32_mutex_unlock;	     external; // dblib name '___db_win32_mutex_unlock';
	function ___ham_func2	          ;      external; // dblib name '___ham_func2'            ;
	function ___ham_func3	          ;      external; // dblib name '___ham_func3'            ;
	function ___ham_func4	          ;      external; // dblib name '___ham_func4'            ;
	function ___ham_func5	          ;      external; // dblib name '___ham_func5'            ;
	function ___ham_test	            ;      external; // dblib name '___ham_test'             ;
  function ___lock_dump_region	    ;      external; // dblib name '___lock_dump_region'     ;
	function ___lock_id_set	        ;      external; // dblib name '___lock_id_set'          ;
	function ___memp_dump_region	    ;      external; // dblib name '___memp_dump_region'     ;
	function ___os_calloc	          ;      external; // dblib name '___os_calloc'            ;
	function ___os_closehandle	      ;      external; // dblib name '___os_closehandle'       ;
	procedure ___os_free	            ;      external; // dblib name '___os_free'              ;
	function ___os_ioinfo	          ;      external; // dblib name '___os_ioinfo'            ;
	function ___os_malloc	          ;      external; // dblib name '___os_malloc'            ;
	function ___os_open	            ;      external; // dblib name '___os_open'              ;
	function ___os_openhandle	      ;      external; // dblib name '___os_openhandle'        ;
	function ___os_read	            ;      external; // dblib name '___os_read'              ;
	function ___os_realloc	          ;      external; // dblib name '___os_realloc'           ;
	function ___os_strdup	          ;      external; // dblib name '___os_strdup'            ;
	function ___os_umalloc	          ;      external; // dblib name '___os_umalloc'           ;
	function ___os_write	            ;      external; // dblib name '___os_write'             ;
	function ___txn_id_set	          ;      external; // dblib name '___txn_id_set'           ;
	function ___bam_init_print	      ;      external; // dblib name '___bam_init_print'       ;
	function ___bam_pgin	            ;      external; // dblib name '___bam_pgin'             ;
	function ___bam_pgout	          ;      external; // dblib name '___bam_pgout'            ;
	function ___crdel_init_print	    ;      external; // dblib name '___crdel_init_print'     ;
	function ___db_dispatch	        ;      external; // dblib name '___db_dispatch'          ;
	function ___db_dump	            ;      external; // dblib name '___db_dump'              ;
	function ___db_e_stat	          ;      external; // dblib name '___db_e_stat'            ;
	//function __db_err	              ;      external; // dblib name '___db_err'               ;
	function ___db_getlong	          ;      external; // dblib name '___db_getlong'           ;
	function ___db_getulong	        ;      external; // dblib name '___db_getulong'          ;
	//function __db_global_values	    ;      external; // dblib name '___db_global_values'     ;
	function ___db_init_print	      ;      external; // dblib name '___db_init_print'        ;
	procedure ___db_inmemdbflags	    ;      external; // dblib name '___db_inmemdbflags'      ;
	function ___db_isbigendian	      ;      external; // dblib name '___db_isbigendian'       ;
	function ___db_omode	            ;      external; // dblib name '___db_omode'             ;
	function ___db_overwrite	        ;      external; // dblib name '___db_overwrite'         ;
	function ___db_pgin	            ;      external; // dblib name '___db_pgin'              ;
	function ___db_pgout	            ;      external; // dblib name '___db_pgout'             ;
	function ___db_pr_callback	      ;      external; // dblib name '___db_pr_callback'       ;
	function ___db_prdbt	            ;      external; // dblib name '___db_prdbt'             ;
	function ___db_prfooter	        ;      external; // dblib name '___db_prfooter'          ;
	function ___db_prheader	        ;      external; // dblib name '___db_prheader'          ;
	function ___db_rpath	            ;      external; // dblib name '___db_rpath'             ;
	function  ___db_util_cache	      ;      external; // dblib name '___db_util_cache'        ;
	function ___db_util_interrupted	;      external; // dblib name '___db_util_interrupted'  ;
	function  ___db_util_logset	      ;      external; // dblib name '___db_util_logset'       ;
	procedure ___db_util_siginit	    ;      external; // dblib name '___db_util_siginit'      ;
	procedure ___db_util_sigresend	  ;      external; // dblib name '___db_util_sigresend'    ;
	function ___db_verify_internal	  ;      external; // dblib name '___db_verify_internal'   ;
	function ___dbreg_init_print	    ;      external; // dblib name '___dbreg_init_print'     ;
	function ___fop_init_print	      ;      external; // dblib name '___fop_init_print'       ;
	function ___ham_get_meta	        ;      external; // dblib name '___ham_get_meta'         ;
	function ___ham_init_print	      ;      external; // dblib name '___ham_init_print'       ;
	function ___ham_pgin	            ;      external; // dblib name '___ham_pgin'             ;
	function ___ham_pgout	          ;      external; // dblib name '___ham_pgout'            ;
	function ___ham_release_meta	    ;      external; // dblib name '___ham_release_meta'     ;
	function ___os_clock	            ;      external; // dblib name '___os_clock'             ;
	function ___os_get_errno	        ;      external; // dblib name '___os_get_errno'         ;
	procedure ___os_id	              ;      external; // dblib name '___os_id'                ;
	procedure ___os_set_errno	        ;      external; // dblib name '___os_set_errno'         ;
	function ___os_sleep	            ;      external; // dblib name '___os_sleep'             ;
	procedure ___os_ufree	            ;      external; // dblib name '___os_ufree'             ;
	procedure ___os_yield	            ;      external; // dblib name '___os_yield'             ;
	function ___qam_init_print	      ;      external; // dblib name '___qam_init_print'       ;
	function ___qam_pgin_out	        ;      external; // dblib name '___qam_pgin_out'         ;
	function ___txn_init_print	      ;      external; // dblib name '___txn_init_print'       ;
  function ___lock_open;                 external;

  function  ___db_panic_msg;             external;
  function  ___db_key_range_pp;          external;
  function ___db_open_pp;                external;
  function ___db_fnl;                    external;
  function ___db_put;                    external;
  function ___db_del;                    external;
  function ___db_associate;              external;
  function ___db_pg_alloc_log;           external;
  function ___db_pg_freedata_log;        external;
  function ___db_c_count;                external;
  function ___db_c_dup;                  external;
  function ___db_c_get;                  external;
  function ___db_associate_pp;           external;
  function ___db_close_pp;               external;
  function ___db_cursor_pp;              external;
  function ___db_del_pp;                 external;
  function ___db_fd_pp;                  external;
  function ___db_get_pp;                 external;
  function ___db_join_pp;                external;
  function ___db_pget_pp;                external;


  function  ___bam_curadj_log    ;       external;
  function  ___bam_ca_delete     ;       external;
  function  ___ram_ca_delete     ;       external;
  function  ___bam_cdel_log      ;       external;
  function  ___bam_cmp           ;       external;
  function  ___bam_defcmp        ;       external;
  function  ___bam_ca_di         ;       external;



  function _db_env_create(var _para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
    //function __qam_salvage(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:PPAGE; _para5:pointer;
    //           _para6:function (_para1:pointer; _para2:pointer):longint; _para7:u_int32_t):longint;cdecl;external;
  function ___qam_salvage(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:PPAGE; _para5:pointer;
               _para6:Pointer; _para7:u_int32_t):longint;cdecl;external;



  function ___bam_defpfx(_para1:PDB; _para2:PDBT; _para3:PDBT):size_t;cdecl;external;
  function ___bam_mswap(_para1:PPAGE):longint;cdecl;external;
  procedure ___bam_cprint(_para1:PDBC);cdecl;external;
  function ___bam_ca_dup(_para1:PDBC; _para2:u_int32_t; _para3:db_pgno_t; _para4:u_int32_t; _para5:db_pgno_t;
            _para6:u_int32_t):longint;cdecl;external;
  function ___bam_ca_undodup(_para1:PDB; _para2:u_int32_t; _para3:db_pgno_t; _para4:u_int32_t; _para5:u_int32_t):longint;cdecl;external;
  function ___bam_ca_rsplit(_para1:PDBC; _para2:db_pgno_t; _para3:db_pgno_t):longint;cdecl;external;
  function ___bam_ca_split(_para1:PDBC; _para2:db_pgno_t; _para3:db_pgno_t; _para4:db_pgno_t; _para5:u_int32_t;
             _para6:longint):longint;cdecl;external;
  procedure ___bam_ca_undosplit(_para1:PDB; _para2:db_pgno_t; _para3:db_pgno_t; _para4:db_pgno_t; _para5:u_int32_t);cdecl;external;
  function ___bam_c_init(_para1:PDBC; _para2: TDBTYPE):longint;cdecl;external;
  function ___bam_c_refresh(_para1:PDBC):longint;cdecl;external;
  function ___bam_c_count(_para1:PDBC; var _para2:db_recno_t):longint;cdecl;external;
  function ___bam_c_dup(_para1:PDBC; _para2:PDBC):longint;cdecl;external;
  function ___bam_bulk_overflow(_para1:PDBC; _para2:u_int32_t; _para3:db_pgno_t; var _para4:u_int8_t):longint;cdecl;external;
  function ___bam_bulk_duplicates(_para1:PDBC; _para2:db_pgno_t; var _para3:u_int8_t; var _para4:int32_t; var _para5:Pint32_t;
             var _para6:Pu_int8_t; _para7:Pu_int32_t; _para8:longint):longint;cdecl;external;
  function ___bam_c_rget(_para1:PDBC; _para2:PDBT):longint;cdecl;external;
  function ___bam_ditem(_para1:PDBC; _para2:PPAGE; _para3:u_int32_t):longint;cdecl;external;
  function ___bam_adjindx(_para1:PDBC; _para2:PPAGE; _para3:u_int32_t; _para4:u_int32_t; _para5:longint):longint;cdecl;external;
  function ___bam_dpages(_para1:PDBC; _para2:Pointer{PEPG}):longint;cdecl;external;
  function ___bam_db_create(_para1:PDB):longint;cdecl;external;
  function ___bam_db_close(_para1:PDB):longint;cdecl;external;
  procedure ___bam_map_flags(_para1:PDB; _para2:Pu_int32_t; _para3:Pu_int32_t);cdecl;external;
  function ___bam_set_flags(_para1:PDB; flagsp:Pu_int32_t):longint;cdecl;external;
  //function __bam_set_bt_compare(_para1:PDB; _para2:function (_para1:PDB; _para2:PDBT; _para3:PDBT):longint):longint;cdecl;external;
  function ___bam_set_bt_compare(_para1:PDB; _para2:Pointer):longint;cdecl;external;
  procedure ___ram_map_flags(_para1:PDB; _para2:Pu_int32_t; _para3:Pu_int32_t);cdecl;external;
  function ___ram_set_flags(_para1:PDB; flagsp:Pu_int32_t):longint;cdecl;external;
  function ___bam_open(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;
  function ___bam_read_root(_para1:PDB; _para2:PDB_TXN; _para3:db_pgno_t; _para4:u_int32_t):longint;cdecl;external;
  function ___bam_new_file(_para1:PDB; _para2:PDB_TXN; _para3:PDB_FH; _para4:Pchar):longint;cdecl;external;
  function ___bam_new_subdb(_para1:PDB; _para2:PDB; _para3:PDB_TXN):longint;cdecl;external;
  function ___bam_iitem(_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t; _para5:u_int32_t):longint;cdecl;external;
  function ___bam_ritem(_para1:PDBC; _para2:PPAGE; _para3:u_int32_t; _para4:PDBT):longint;cdecl;external;
  function ___bam_split_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_rsplit_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_adj_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_cadjust_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_cdel_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_repl_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_root_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_curadj_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_rcuradj_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_reclaim(_para1:PDB; _para2:PDB_TXN):longint;cdecl;external;
  function ___bam_truncate(_para1:PDBC; _para2:Pu_int32_t):longint;cdecl;external;
  function ___bam_search(_para1:PDBC; _para2:db_pgno_t; _para3:PDBT; _para4:u_int32_t; _para5:longint;
             var _para6:db_recno_t; var _para7:longint):longint;cdecl;external;
  function ___bam_stkrel(_para1:PDBC; _para2:u_int32_t):longint;cdecl;external;
  function ___bam_stkgrow(_para1:PDB_ENV; _para2:Pointer{PBTREE_CURSOR}):longint;cdecl;external;
  function ___bam_split(_para1:PDBC; _para2:pointer; var _para3:db_pgno_t):longint;cdecl;external;
  function ___bam_copy(_para1:PDB; _para2:PPAGE; _para3:PPAGE; _para4:u_int32_t; _para5:u_int32_t):longint;cdecl;external;
  function ___bam_stat(_para1:PDBC; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;
  //function ___bam_traverse(_para1:PDBC; _para2:db_lockmode_t; _para3:db_pgno_t; _para4:function (_para1:PDB; _para2:PPAGE; _para3:pointer; _para4:Plongint):longint; _para5:pointer):longint;cdecl;external;
  function ___bam_traverse(_para1:PDBC; _para2:db_lockmode_t; _para3:db_pgno_t; _para4:Pointer; _para5:pointer):longint;cdecl;external;
  function ___bam_stat_callback(_para1:PDB; _para2:PPAGE; _para3:pointer; _para4:Plongint):longint;cdecl;external;
  function ___bam_key_range(_para1:PDBC; _para2:PDBT; _para3:Pointer {PDB_KEY_RANGE}; _para4:u_int32_t):longint;cdecl;external;
  function ___bam_30_btreemeta(_para1:PDB; _para2:Pchar; _para3:Pu_int8_t):longint;cdecl;external;
  function ___bam_31_btreemeta(_para1:PDB; _para2:Pchar; _para3:u_int32_t; _para4:PDB_FH; _para5:PPAGE;
             _para6:Plongint):longint;cdecl;external;
  function ___bam_31_lbtree(_para1:PDB; _para2:Pchar; _para3:u_int32_t; _para4:PDB_FH; _para5:PPAGE;
             _para6:Plongint):longint;cdecl;external;
  function ___bam_vrfy_meta(_para1:PDB; _para2:PVRFY_DBINFO; _para3:Pointer {PBTMETA}; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;
  function ___ram_vrfy_leaf(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PPAGE; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;
  function ___bam_vrfy(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PPAGE; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;
  function ___bam_vrfy_itemorder(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PPAGE; _para4:db_pgno_t; _para5:u_int32_t;
             _para6:longint; _para7:longint; _para8:u_int32_t):longint;cdecl;external;
  function ___bam_vrfy_structure(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:u_int32_t):longint;cdecl;external;
  function ___bam_vrfy_subtree(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:pointer; _para5:pointer;
             _para6:u_int32_t; _para7:Pu_int32_t; _para8:Pu_int32_t; _para9:Pu_int32_t):longint;cdecl;external;
  //function ___bam_salvage(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:u_int32_t; _para5:PPAGE;
  //           _para6:pointer; _para7:function (_para1:pointer; _para2:pointer):longint; _para8:PDBT; _para9:u_int32_t):longint;cdecl;external;
  function ___bam_salvage(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:u_int32_t; _para5:PPAGE;
             _para6:pointer; _para7:Pointer; _para8:PDBT; _para9:u_int32_t):longint;cdecl;external;
   //function ___bam_salvage_walkdupint(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PPAGE; _para4:PDBT; _para5:pointer;
  //           _para6:function (_para1:pointer; _para2:pointer):longint; _para7:u_int32_t):longint;cdecl;external;
  function ___bam_salvage_walkdupint(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PPAGE; _para4:PDBT; _para5:pointer;
             _para6:Pointer;_para7:u_int32_t):longint;cdecl;external;
  function ___bam_meta2pgset(_para1:PDB; _para2:PVRFY_DBINFO; _para3:Pointer{PBTMETA}; _para4:u_int32_t; _para5:PDB):longint;cdecl;external;
  function ___bam_split_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t;
             _para6:PDB_LSN; _para7:db_pgno_t; _para8:PDB_LSN; _para9:u_int32_t; _para10:db_pgno_t;
             _para11:PDB_LSN; _para12:db_pgno_t; _para13:PDBT; _para14:u_int32_t):longint;cdecl;external;
  function ___bam_split_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_split_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_split_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__bam_split_args}):longint;cdecl;external;
  function ___bam_rsplit_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t;
             _para6:PDBT; _para7:db_pgno_t; _para8:db_pgno_t; _para9:PDBT; _para10:PDB_LSN):longint;cdecl;external;
  function ___bam_rsplit_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_rsplit_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_rsplit_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__bam_rsplit_args}):longint;cdecl;external;
  function ___bam_adj_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t;
             _para6:PDB_LSN; _para7:u_int32_t; _para8:u_int32_t; _para9:u_int32_t):longint;cdecl;external;
  function ___bam_adj_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_adj_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_adj_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__bam_adj_args}):longint;cdecl;external;
  function ___bam_cadjust_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t;
             _para6:PDB_LSN; _para7:u_int32_t; _para8:int32_t; _para9:u_int32_t):longint;cdecl;external;
  function ___bam_cadjust_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_cadjust_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_cadjust_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__bam_cadjust_args}):longint;cdecl;external;
  function ___bam_cdel_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_cdel_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_cdel_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__bam_cdel_args}):longint;cdecl;external;
  function ___bam_repl_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t;
             _para6:PDB_LSN; _para7:u_int32_t; _para8:u_int32_t; _para9:PDBT; _para10:PDBT;
             _para11:u_int32_t; _para12:u_int32_t):longint;cdecl;external;
  function ___bam_repl_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_repl_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_repl_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__bam_repl_args}):longint;cdecl;external;
  function ___bam_root_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t;
             _para6:db_pgno_t; _para7:PDB_LSN):longint;cdecl;external;
  function ___bam_root_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_root_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_root_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__bam_root_args}):longint;cdecl;external;
  function ___bam_curadj_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_curadj_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_curadj_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__bam_curadj_args}):longint;cdecl;external;
  function ___bam_rcuradj_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:Pointer{ca_recno_arg};
             _para6:db_pgno_t; _para7:db_recno_t; _para8:u_int32_t):longint;cdecl;external;
  function ___bam_rcuradj_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_rcuradj_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___bam_rcuradj_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__bam_rcuradj_args}):longint;cdecl;external;


  function ___crypto_region_init(_para1:PDB_ENV):longint;cdecl;external;
  function ___db_byteorder(_para1:PDB_ENV; _para2:longint):longint;cdecl;external;
  function ___db_fchk(_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t; _para4:u_int32_t):longint;cdecl;external;
  function ___db_fcchk(_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t; _para4:u_int32_t; _para5:u_int32_t):longint;cdecl;external;
  function ___db_ferr(_para1:PDB_ENV; _para2:Pchar; _para3:longint):longint;cdecl;external;
  function ___db_pgerr(_para1:PDB; _para2:db_pgno_t; _para3:longint):longint;cdecl;external;
  function ___db_pgfmt(_para1:PDB_ENV; _para2:db_pgno_t):longint;cdecl;external;
  procedure ___db_errcall(_para1:PDB_ENV; _para2:longint; _para3:longint; _para4:Pchar; _para5:va_list);cdecl;external;
  procedure ___db_errfile(_para1:PDB_ENV; _para2:longint; _para3:longint; _para4:Pchar; _para5:va_list);cdecl;external;
  function ___db_unknown_flag(_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t):longint;cdecl;external;
  function ___db_unknown_type(_para1:PDB_ENV; _para2:Pchar; _para3:TDBTYPE):longint;cdecl;external;
  function ___db_check_txn(_para1:PDB; _para2:PDB_TXN; _para3:u_int32_t; _para4:longint):longint;cdecl;external;
  function ___db_not_txn_env(_para1:PDB_ENV):longint;cdecl;external;
  function ___db_rec_toobig(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t):longint;cdecl;external;
  function ___db_rec_repl(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t):longint;cdecl;external;
  procedure ___db_idspace(_para1:Pu_int32_t; _para2:longint; _para3:Pu_int32_t; _para4:Pu_int32_t);cdecl;external;
  function ___db_log2(_para1:u_int32_t):u_int32_t;cdecl;external;
  function ___db_c_close(_para1:PDBC):longint;cdecl;external;
  function ___db_c_destroy(_para1:PDBC):longint;cdecl;external;
  function ___db_c_del(_para1:PDBC; _para2:u_int32_t):longint;cdecl;external;
  function ___db_c_idup(_para1:PDBC; var _para2:PDBC; _para3:u_int32_t):longint;cdecl;external;
  function ___db_c_newopd(_para1:PDBC; _para2:db_pgno_t; _para3:PDBC; var _para4:PDBC):longint;cdecl;external;
  function ___db_c_put(_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t):longint;cdecl;external;
  function ___db_duperr(_para1:PDB; _para2:u_int32_t):longint;cdecl;external;
  function ___db_c_secondary_get_pp(_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t):longint;cdecl;external;
  function ___db_c_pget(_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint;cdecl;external;
  function ___db_c_del_primary(_para1:PDBC):longint;cdecl;external;
  function ___db_s_first(_para1:PDB):PDB;cdecl;external;
  function ___db_s_next(_para1:PPDB):longint;cdecl;external;
  function ___db_s_done(_para1:PDB):longint;cdecl;external;
  function ___db_cursor(_para1:PDB; _para2:PDB_TXN; var _para3:PDBC; _para4:u_int32_t):longint;cdecl;external;
  function ___db_get(_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint;cdecl;external;
  function ___db_pget(_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:PDBT;
             _para6:u_int32_t):longint;cdecl;external;
  function ___db_put_pp(_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint;cdecl;external;
  function ___db_stat_pp(_para1:PDB; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;
  function ___db_stat(_para1:PDB; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;
  function ___db_sync_pp(_para1:PDB; _para2:u_int32_t):longint;cdecl;external;
  function ___db_c_close_pp(_para1:PDBC):longint;cdecl;external;
  function ___db_c_count_pp(_para1:PDBC; var _para2:db_recno_t; _para3:u_int32_t):longint;cdecl;external;
  function ___db_c_del_pp(_para1:PDBC; _para2:u_int32_t):longint;cdecl;external;
  function ___db_c_del_arg(_para1:PDBC; _para2:u_int32_t):longint;cdecl;external;
  function ___db_c_dup_pp(_para1:PDBC; var _para2:PDBC; _para3:u_int32_t):longint;cdecl;external;
  function ___db_c_get_pp(_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t):longint;cdecl;external;
  function ___db_c_pget_pp(_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint;cdecl;external;
  function ___db_c_put_pp(_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t):longint;cdecl;external;
  function ___db_txn_auto_init(_para1:PDB_ENV; var _para2:PDB_TXN):longint;cdecl;external;
  function ___db_txn_auto_resolve(_para1:PDB_ENV; _para2:PDB_TXN; _para3:longint; _para4:longint):longint;cdecl;external;
  function ___db_join(_para1:PDB; var _para2:PDBC; var _para3:PDBC; _para4:u_int32_t):longint;cdecl;external;
  function ___db_join_close(_para1:PDBC):longint;cdecl;external;
  function ___db_secondary_corrupt(_para1:PDB):longint;cdecl;external;
  function ___db_new(_para1:PDBC; _para2:u_int32_t; var _para3:PPAGE):longint;cdecl;external;
  function ___db_free(_para1:PDBC; _para2:PPAGE):longint;cdecl;external;
  function ___db_lprint(_para1:PDBC):longint;cdecl;external;




  function ___fop_create_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDBT;
             _para6:u_int32_t; _para7:u_int32_t):longint;cdecl;external;
  function ___fop_create_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_create_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_create_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__fop_create_args}):longint;cdecl;external;
  function ___fop_remove_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDBT;
             _para6:PDBT; _para7:u_int32_t):longint;cdecl;external;
  function ___fop_remove_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_remove_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_remove_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__fop_remove_args}):longint;cdecl;external;
  function ___fop_write_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDBT;
             _para6:u_int32_t; _para7:u_int32_t; _para8:db_pgno_t; _para9:u_int32_t; _para10:PDBT;
             _para11:u_int32_t):longint;cdecl;external;
  function ___fop_write_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_write_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_write_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__fop_write_args}):longint;cdecl;external;
  function ___fop_rename_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDBT;
             _para6:PDBT; _para7:PDBT; _para8:u_int32_t):longint;cdecl;external;
  function ___fop_rename_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_rename_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_rename_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__fop_rename_args}):longint;cdecl;external;
  function ___fop_file_remove_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDBT;
             _para6:PDBT; _para7:PDBT; _para8:u_int32_t; _para9:u_int32_t):longint;cdecl;external;
  function ___fop_file_remove_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_file_remove_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_file_remove_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__fop_file_remove_args}):longint;cdecl;external;
  function ___fop_create_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_remove_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_write_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_rename_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_file_remove_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___fop_lock_handle(_para1:PDB_ENV; _para2:PDB; _para3:u_int32_t; _para4:db_lockmode_t; _para5:Pointer {PDB_LOCK};
             _para6:u_int32_t):longint;cdecl;external;
  function ___fop_file_setup(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:longint; _para5:u_int32_t;
             _para6:Pu_int32_t):longint;cdecl;external;
  function ___fop_subdb_setup(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:longint;
             _para6:u_int32_t):longint;cdecl;external;
  function ___fop_remove_setup(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:u_int32_t):longint;cdecl;external;
  function ___fop_read_meta(_para1:PDB_ENV; _para2:Pchar; _para3:Pu_int8_t; _para4:size_t; _para5:PDB_FH;
             _para6:longint; var _para7:size_t):longint;cdecl;external;
  function ___fop_dummy(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:u_int32_t):longint;cdecl;external;
  function ___fop_dbrename(_para1:PDB; _para2:Pchar; _para3:Pchar):longint;cdecl;external;



  function ___bam_init_recover; external;

  function ___db_close; external;

  function ___dbreg_assign_id(_para1:PDB; _para2:int32_t):longint;cdecl;external;
  function ___dbreg_get_id(_para1:PDB; _para2:PDB_TXN; _para3:Pint32_t):longint;cdecl;external;
  function ___dbreg_register_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__dbreg_register_args}):longint;cdecl;external;




  function ___db_refresh(_para1:PDB; _para2:PDB_TXN; _para3:u_int32_t; _para4:Plongint):longint;cdecl;external;

  function ___crdel_metasub_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__crdel_metasub_args}):longint;cdecl;external;
  function ___crdel_metasub_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t;
             _para6:PDBT; _para7:PDB_LSN):longint;cdecl;external;


  function ___ram_append(_para1:PDBC; _para2:PDBT; _para3:PDBT):longint;cdecl;external;
  function ___ram_writeback(_para1:PDB):longint;cdecl;external;
  function ___ram_open(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;


  function ___ham_c_update(_para1:PDBC; _para2:u_int32_t; _para3:longint; _para4:longint):longint;cdecl;external;
  function ___ham_get_clist(_para1:PDB; _para2:db_pgno_t; _para3:u_int32_t; var _para4:PDBC):longint;cdecl;external;
  function ___ham_chgpg_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5: Integer{db_ham_mode};
             _para6:db_pgno_t; _para7:db_pgno_t; _para8:u_int32_t; _para9:u_int32_t):longint;cdecl;external;

  {
  function ___log_open(_para1:PDB_ENV):longint;cdecl;external;
  function ___log_find(_para1:PDB_LOG; _para2:longint; _para3:Pu_int32_t; _para4:Plogfile_validity):longint;cdecl;external;
  function ___log_valid(_para1:PDB_LOG; _para2:u_int32_t; _para3:longint; _para4:PPDB_FH; _para5:longint;
             _para6:Plogfile_validity):longint;cdecl;external;
  function ___log_dbenv_refresh(_para1:PDB_ENV):longint;cdecl;external;
  function ___log_stat_pp(_para1:PDB_ENV; _para2:PPDB_LOG_STAT; _para3:u_int32_t):longint;cdecl;external;
  procedure ___log_get_cached_ckp_lsn(_para1:PDB_ENV; _para2:PDB_LSN);cdecl;external;
  procedure ___log_region_destroy(_para1:PDB_ENV; _para2:PREGINFO);cdecl;external;
  function ___log_vtruncate(_para1:PDB_ENV; _para2:PDB_LSN; _para3:PDB_LSN; _para4:PDB_LSN):longint;cdecl;external;
  function ___log_is_outdated(_para1:PDB_ENV; _para2:u_int32_t; _para3:Plongint):longint;cdecl;external;
  procedure ___log_autoremove(_para1:PDB_ENV);cdecl;external;
  function ___log_cursor_pp(_para1:PDB_ENV; _para2:PPDB_LOGC; _para3:u_int32_t):longint;cdecl;external;
  function ___log_cursor(_para1:PDB_ENV; _para2:PPDB_LOGC):longint;cdecl;external;
  function ___log_c_close(_para1:PDB_LOGC):longint;cdecl;external;
  function ___log_c_get(_para1:PDB_LOGC; _para2:PDB_LSN; _para3:PDBT; _para4:u_int32_t):longint;cdecl;external;
  procedure ___log_dbenv_create(_para1:PDB_ENV);cdecl;external;
  function ___log_set_lg_bsize(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
  function ___log_set_lg_max(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
  function ___log_set_lg_regionmax(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
  function ___log_set_lg_dir(_para1:PDB_ENV; _para2:Pchar):longint;cdecl;external;
  function ___log_put_pp(_para1:PDB_ENV; _para2:PDB_LSN; _para3:PDBT; _para4:u_int32_t):longint;cdecl;external;
  function ___log_put(_para1:PDB_ENV; _para2:PDB_LSN; _para3:PDBT; _para4:u_int32_t):longint;cdecl;external;
  procedure ___log_txn_lsn(_para1:PDB_ENV; _para2:PDB_LSN; _para3:Pu_int32_t; _para4:Pu_int32_t);cdecl;external;
  function ___log_newfile(_para1:PDB_LOG; _para2:PDB_LSN):longint;cdecl;external;
  function ___log_flush_pp(_para1:PDB_ENV; _para2:PDB_LSN):longint;cdecl;external;
  function ___log_flush(_para1:PDB_ENV; _para2:PDB_LSN):longint;cdecl;external;
  function ___log_flush_int(_para1:PDB_LOG; _para2:PDB_LSN; _para3:longint):longint;cdecl;external;
  function ___log_file_pp(_para1:PDB_ENV; _para2:PDB_LSN; _para3:Pchar; _para4:size_t):longint;cdecl;external;
  function ___log_name(_para1:PDB_LOG; _para2:u_int32_t; _para3:PPchar; _para4:PPDB_FH; _para5:u_int32_t):longint;cdecl;external;
  function ___log_rep_put(_para1:PDB_ENV; _para2:PDB_LSN; _para3:PDBT):longint;cdecl;external;

 }

  
  function ___lock_id_pp(_para1:PDB_ENV; _para2:Pu_int32_t):longint;cdecl;external;
  function ___lock_id(_para1:PDB_ENV; _para2:Pu_int32_t):longint;cdecl;external;
  function ___lock_id_free_pp(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
  function ___lock_id_free(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
  function ___lock_vec_pp(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:Pointer{PDB_LOCKREQ}; _para5:longint;
             _para6:Pointer{PPDB_LOCKREQ}):longint;cdecl;external;
  function ___lock_vec(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:Pointer{PDB_LOCKREQ}; _para5:longint;
             _para6:Pointer{PPDB_LOCKREQ}):longint;cdecl;external;
  function ___lock_get_pp(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:PDBT; _para5:db_lockmode_t;
             _para6:Pointer{PDB_LOCK}):longint;cdecl;external;
  function ___lock_get(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:PDBT; _para5:db_lockmode_t;
             _para6:Pointer{PDB_LOCK}):longint;cdecl;external;
  function ___lock_put_pp(_para1:PDB_ENV; _para2:Pointer{PDB_LOCK}):longint;cdecl;external;
  function ___lock_put(_para1:PDB_ENV; _para2:Pointer{PDB_LOCK}):longint;cdecl;external;
  function ___lock_downgrade(_para1:PDB_ENV; _para2:Pointer{PDB_LOCK}; _para3:db_lockmode_t; _para4:u_int32_t):longint;cdecl;external;
  function ___lock_addfamilylocker(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t):longint;cdecl;external;
  function ___lock_freefamilylocker(_para1:Pointer{PDB_LOCKTAB}; _para2:u_int32_t):longint;cdecl;external;
  function ___lock_set_timeout(_para1:PDB_ENV; _para2:u_int32_t; _para3:db_timeout_t; _para4:u_int32_t):longint;cdecl;external;
  function ___lock_inherit_timeout(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t):longint;cdecl;external;
  function ___lock_getlocker(_para1:Pointer{PDB_LOCKTAB}; _para2:u_int32_t; _para3:u_int32_t; _para4:longint; _para5:PPointer{PDB_LOCKER}):longint;cdecl;external;
  function ___lock_promote(_para1:Pointer{PDB_LOCKTAB}; _para2:Pointer{PDB_LOCKOBJ}; _para3:u_int32_t):longint;cdecl;external;
  function ___lock_expired(_para1:PDB_ENV; var _para2: db_timeval_t; var _para3:db_timeval_t):longint;cdecl;external;
  function ___lock_get_list(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:db_lockmode_t; _para5:PDBT):longint;cdecl;external;
  function ___lock_detect_pp(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:Plongint):longint;cdecl;external;
  function ___lock_detect(_para1:PDB_ENV; _para2:u_int32_t; _para3:Plongint):longint;cdecl;external;
  procedure ___lock_dbenv_create(_para1:PDB_ENV);cdecl;external;
  procedure ___lock_dbenv_close(_para1:PDB_ENV);cdecl;external;
  function ___lock_set_lk_detect(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
  function ___lock_set_lk_max(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
  function ___lock_set_lk_max_locks(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
  function ___lock_set_lk_max_lockers(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
  function ___lock_set_lk_max_objects(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;
  function ___lock_set_env_timeout(_para1:PDB_ENV; _para2:db_timeout_t; _para3:u_int32_t):longint;cdecl;external;
  function ___lock_dbenv_refresh(_para1:PDB_ENV):longint;cdecl;external;
  procedure ___lock_region_destroy(_para1:PDB_ENV; _para2:PREGINFO);cdecl;external;
  function ___lock_stat_pp(_para1:PDB_ENV; _para2:PPointer{PDB_LOCK_STAT}; _para3:u_int32_t):longint;cdecl;external;
  procedure ___lock_printlock(_para1:Pointer{PDB_LOCKTAB}; _para2:Pointer{P__db_lock}; _para3:longint; _para4:PFILE);cdecl;external;
  function ___lock_cmp(_para1:PDBT; _para2:Pointer{PDB_LOCKOBJ}):longint;cdecl;external;
  function ___lock_locker_cmp(_para1:u_int32_t; _para2:Pointer{PDB_LOCKER}):longint;cdecl;external;
  function ___lock_ohash(_para1:PDBT):u_int32_t;cdecl;external;
  function ___lock_lhash(_para1:Pointer{PDB_LOCKOBJ}):u_int32_t;cdecl;external;
  function ___lock_locker_hash(_para1:u_int32_t):u_int32_t;cdecl;external;













  function ___ham_call_hash(_para1:PDBC; _para2:Pu_int8_t; _para3:int32_t):u_int32_t;cdecl;external;
  procedure ___ham_reputpair(_para1:PDB; _para2:PPAGE; _para3:u_int32_t; _para4:PDBT; _para5:PDBT);cdecl;external;
  procedure ___ham_putitem(_para1:PDB; p:PPAGE; _para3:PDBT; _para4:longint);cdecl;external;
  function ___ham_insdel_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__ham_insdel_args}):longint;cdecl;external;
  function ___ham_quick_delete(_para1:PDBC):longint;cdecl;external;
  function ___ham_c_init(_para1:PDBC):longint;cdecl;external;
  function ___ham_c_count(_para1:PDBC; var _para2:db_recno_t):longint;cdecl;external;
  function ___ham_c_dup(_para1:PDBC; _para2:PDBC):longint;cdecl;external;
  function ___ham_init_dbt(_para1:PDB_ENV; _para2:PDBT; _para3:u_int32_t; _para4:Ppointer; _para5:Pu_int32_t):longint;cdecl;external;
  function ___ham_insdel_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t;
             _para6:db_pgno_t; _para7:u_int32_t; _para8:PDB_LSN; _para9:PDBT; _para10:PDBT):longint;cdecl;external;
  function ___ham_insdel_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___ham_insdel_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___ham_newpage_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t;
             _para6:db_pgno_t; _para7:PDB_LSN; _para8:db_pgno_t; _para9:PDB_LSN; _para10:db_pgno_t;
             _para11:PDB_LSN):longint;cdecl;external;
  function ___ham_newpage_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___ham_newpage_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___ham_newpage_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__ham_newpage_args}):longint;cdecl;external;
  function ___ham_splitdata_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t;
             _para6:db_pgno_t; _para7:PDBT; _para8:PDB_LSN):longint;cdecl;external;
  function ___ham_splitdata_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___ham_splitdata_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;
  function ___ham_splitdata_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__ham_splitdata_args}):longint;cdecl;external;



  function ___ham_replace_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t;
             _para6:u_int32_t; _para7:PDB_LSN; _para8:int32_t; _para9:PDBT; _para10:PDBT; 
             _para11:u_int32_t):longint;cdecl;external;

  function ___ham_replace_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_replace_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_replace_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__ham_replace_args}):longint;cdecl;external;


  function ___ham_copypage_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t;
             _para6:PDB_LSN; _para7:db_pgno_t; _para8:PDB_LSN; _para9:db_pgno_t; _para10:PDB_LSN;
             _para11:PDBT):longint;cdecl;external;

  function ___ham_copypage_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_copypage_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_copypage_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__ham_copypage_args}):longint;cdecl;external;

  function ___ham_metagroup_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t;
             _para6:db_pgno_t; _para7:PDB_LSN; _para8:db_pgno_t; _para9:PDB_LSN; _para10:db_pgno_t;
             _para11:PDB_LSN; _para12:u_int32_t):longint;cdecl;external;

  function ___ham_metagroup_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_metagroup_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_metagroup_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__ham_metagroup_args}):longint;cdecl;external;

  function ___ham_groupalloc_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDB_LSN;
             _para6:db_pgno_t; _para7:u_int32_t; _para8:db_pgno_t):longint;cdecl;external;

  function ___ham_groupalloc_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_groupalloc_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_groupalloc_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__ham_groupalloc_args}):longint;cdecl;external;

  function ___ham_curadj_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t;
             _para6:u_int32_t; _para7:u_int32_t; _para8:u_int32_t; _para9:longint; _para10:longint;
             _para11:u_int32_t):longint;cdecl;external;

  function ___ham_curadj_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_curadj_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_curadj_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__ham_curadj_args}):longint;cdecl;external;


  function ___ham_chgpg_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_chgpg_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_chgpg_read(_para1:PDB_ENV; _para2:pointer; _para3:Pointer{PP__ham_chgpg_args}):longint;cdecl;external;

  //function ___ham_init_getpgnos(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  //function ___ham_init_recover(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function ___ham_mswap(_para1:pointer):longint;cdecl;external;

  function ___ham_add_dup(_para1:PDBC; _para2:PDBT; _para3:u_int32_t; var _para4:db_pgno_t):longint;cdecl;external;

  function ___ham_dup_convert(_para1:PDBC):longint;cdecl;external;


  function ___ham_make_dup(_para1:PDB_ENV; _para2:PDBT; d:PDBT; _para4:Ppointer; _para5:Pu_int32_t):longint;cdecl;external;

  procedure ___ham_dsearch(_para1:PDBC; _para2:PDBT; _para3:Pu_int32_t; _para4:Plongint; _para5:u_int32_t);cdecl;external;

  procedure ___ham_cprint(_para1:PDBC);cdecl;external;

  function ___ham_dirty_meta(_para1:PDBC):longint;cdecl;external;

  function ___ham_db_create(_para1:PDB):longint;cdecl;external;

  function ___ham_db_close(_para1:PDB):longint;cdecl;external;


  function ___ham_open(_para1:PDB; _para2:PDB_TXN; name:Pchar; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;


  function ___ham_metachk(_para1:PDB; _para2:Pchar; _para3:Pointer{PHMETA}):longint;cdecl;external;


  function ___ham_new_file(_para1:PDB; _para2:PDB_TXN; _para3:PDB_FH; _para4:Pchar):longint;cdecl;external;

  function ___ham_new_subdb(_para1:PDB; _para2:PDB; _para3:PDB_TXN):longint;cdecl;external;

  function ___ham_item(_para1:PDBC; _para2:db_lockmode_t; var _para3:db_pgno_t):longint;cdecl;external;

  function ___ham_item_reset(_para1:PDBC):longint;cdecl;external;

  procedure ___ham_item_init(_para1:PDBC);cdecl;external;

  function ___ham_item_last(_para1:PDBC; _para2:db_lockmode_t; var _para3:db_pgno_t):longint;cdecl;external;

  function ___ham_item_first(_para1:PDBC; _para2:db_lockmode_t; var _para3:db_pgno_t):longint;cdecl;external;

  function ___ham_item_prev(_para1:PDBC; _para2:db_lockmode_t; var _para3:db_pgno_t):longint;cdecl;external;

  function ___ham_item_next(_para1:PDBC; _para2:db_lockmode_t; var _para3:db_pgno_t):longint;cdecl;external;




  function ___ham_del_pair(_para1:PDBC; _para2:longint):longint;cdecl;external;

  function ___ham_replpair(_para1:PDBC; _para2:PDBT; _para3:u_int32_t):longint;cdecl;external;

  procedure ___ham_onpage_replace(_para1:PDB; _para2:PPAGE; _para3:u_int32_t; _para4:int32_t; _para5:int32_t;
              _para6:PDBT);cdecl;external;

  function ___ham_split_page(_para1:PDBC; _para2:u_int32_t; _para3:u_int32_t):longint;cdecl;external;



  function ___ham_add_el(_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:longint):longint;cdecl;external;

  procedure ___ham_copy_item(_para1:PDB; _para2:PPAGE; _para3:u_int32_t; _para4:PPAGE);cdecl;external;

  function ___ham_add_ovflpage(_para1:PDBC; _para2:PPAGE; _para3:longint; var _para4:PPAGE):longint;cdecl;external;

  function ___ham_get_cpage(_para1:PDBC; _para2:db_lockmode_t):longint;cdecl;external;

  function ___ham_next_cpage(_para1:PDBC; _para2:db_pgno_t; _para3:longint):longint;cdecl;external;

  function ___ham_lock_bucket(_para1:PDBC; _para2:db_lockmode_t):longint;cdecl;external;

  procedure ___ham_dpair(_para1:PDB; _para2:PPAGE; _para3:u_int32_t);cdecl;external;

  function ___ham_insdel_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_newpage_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_replace_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_splitdata_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_copypage_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_metagroup_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_groupalloc_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_curadj_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_chgpg_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function ___ham_reclaim(_para1:PDB; txn:PDB_TXN):longint;cdecl;external;

  function ___ham_truncate(_para1:PDBC; _para2:Pu_int32_t):longint;cdecl;external;

  function ___ham_stat(_para1:PDBC; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;

  //function ___ham_traverse(_para1:PDBC; _para2:db_lockmode_t; _para3:function (_para1:PDB; _para2:PPAGE; _para3:pointer; _para4:Plongint):longint; _para4:pointer; _para5:longint):longint;cdecl;external;

  //function ___ham_traverse(_para1:PDBC; _para2:db_lockmode_t; _para3:function (_para1:PDB; _para2:PPAGE; _para3:pointer; _para4:Plongint):longint; _para4:pointer; _para5:longint):longint;cdecl;external;

  //function ___db_no_hash_am(_para1:PDB_ENV):longint;cdecl;external;

  function ___ham_30_hashmeta(_para1:PDB; _para2:Pchar; _para3:Pu_int8_t):longint;cdecl;external;

  function ___ham_30_sizefix(_para1:PDB; _para2:PDB_FH; _para3:Pchar; _para4:Pu_int8_t):longint;cdecl;external;

  function ___ham_31_hashmeta(_para1:PDB; _para2:Pchar; _para3:u_int32_t; _para4:PDB_FH; _para5:PPAGE;
             _para6:Plongint):longint;cdecl;external;

  function ___ham_31_hash(_para1:PDB; _para2:Pchar; _para3:u_int32_t; _para4:PDB_FH; _para5:PPAGE;
             _para6:Plongint):longint;cdecl;external;

  function ___ham_vrfy_meta(_para1:PDB; _para2:PVRFY_DBINFO; _para3:Pointer{PHMETA}; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;

  function ___ham_vrfy(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PPAGE; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;

  function ___ham_vrfy_structure(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:u_int32_t):longint;cdecl;external;




end.






