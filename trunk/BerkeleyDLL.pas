{$Z4}
unit BerkeleyDLL;

interface
uses
  Windows, BerkeleyOs, BerkeleyDBConst;
const
  dblib = 'libdb45d.dll';


(*
 * Berkeley DB version information.
 *)
const
  DB_VERSION_MAJOR     = 4;
  DB_VERSION_MINOR     = 5;
  DB_VERSION_PATCH     = 20;
  DB_VERSION_STRING    = 'Berkeley DB 4.5.20: (September 20, 2006)';

type
   int        = integer;         
   u_int8_t   = byte;
   Pu_int8_t  = ^u_int8_t;
   int16_t    = smallint;
   u_int16_t  = word;
   int32_t    = longint;
   Pint32_t   = ^int32_t;
   u_int32_t  = longword;
   Pu_int32_t = ^u_int32_t;

   size_t     = longword;
   time_t     = longword;
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



const
  DB_HANDLE_LOCK   =1;
  DB_RECORD_LOCK   =2;
  DB_PAGE_LOCK	   =3;

  DBC_ACTIVE	   = $0001;		//* Cursor in use. */
  DBC_COMPENSATE   = $0002;		//* Cursor compensating, don't lock. */
  DBC_DIRTY_READ   = $0004;		//* Cursor supports dirty reads. */
  DBC_OPD	   = $0008;		//* Cursor references off-page dups. */
  DBC_RECOVER	   = $0010;		//* Recovery cursor; don't log/lock. */
  DBC_RMW	   = $0020;		//* Acquire write flag in read op. */
  DBC_TRANSIENT	   = $0040;		//* Cursor is transient. */
  DBC_WRITECURSOR  = $0080;		//* Cursor may be used to write (CDB). */
  DBC_WRITER	   = $0100;		//* Cursor immediately writing (CDB). */
  DBC_MULTIPLE	   = $0200;		//* Return Multiple data. */
  DBC_MULTIPLE_KEY = $0400;		//* Return Multiple keys and data. */
  DBC_OWN_LID	   = $0800;		//* Free lock id on destroy. */

  

type
  PDBC =^TDBC; // forward;

  { Key/data structure -- a Data-Base Thang.  }
  PDBT = ^TDBT;
  TDBT = record
    {  data/size must be fields 1 and 2 for DB 1.85 compatibility. }
    data : pointer;   { Key/data  }
    size : u_int32_t; { key/data length  }
    ulen : u_int32_t; { RO: length of user buffer.  }
    dlen : u_int32_t; { RO: get/put record length.  }
    doff : u_int32_t; { RO: get/put record offset.  }
    app_data : Pointer;
    flags : u_int32_t;
  end;


  {  Transactions and recovery. }
  db_recops = ( DB_TXN_ABORT = 0,
                DB_TXN_APPLY = 1,
                DB_TXN_BACKWARD_ALLOC = 2,
                DB_TXN_BACKWARD_ROLL = 3,
                DB_TXN_FORWARD_ROLL = 4,
                DB_TXN_GETPGNOS = 5,
                DB_TXN_OPENFILES = 6,
                DB_TXN_POPENFILES = 7,
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





  // Key range statistics structure
  TDB_KEY_RANGE = record
    less       : double;
    equal      : double;
    greater    : double;
  end;

  // Btree/Recno statistics structure.
  PDB_BTREE_STAT=^TDB_BTREE_STAT;
  TDB_BTREE_STAT = record
    bt_magic	   : u_int32_t;       // Magic number.
    bt_version	   : u_int32_t;       // Version number.
    bt_metaflags   : u_int32_t;       // Metadata flags.
    bt_nkeys	   : u_int32_t;       // Number of unique keys.
    bt_ndata	   : u_int32_t;       // Number of data items.
    bt_pagesize    : u_int32_t;       // Page size.
    bt_maxkey	   : u_int32_t;       // Maxkey value.
    bt_minkey	   : u_int32_t;       // Minkey value.
    bt_re_len	   : u_int32_t;       // Fixed-length record length.
    bt_re_pad	   : u_int32_t;       // Fixed-length record pad.
    bt_levels	   : u_int32_t;       // Tree levels.
    bt_int_pg	   : u_int32_t;       // Internal pages.
    bt_leaf_pg	   : u_int32_t;       // Leaf pages.
    bt_dup_pg	   : u_int32_t;       // Duplicate pages.
    bt_over_pg	   : u_int32_t;       // Overflow pages.
    bt_free	   : u_int32_t;       // Pages on the free list.
    bt_int_pgfree  : u_int32_t;       // Bytes free in internal pages.
    bt_leaf_pgfree : u_int32_t;       // Bytes free in leaf pages.
    bt_dup_pgfree  : u_int32_t;       // Bytes free in duplicate pages.
    bt_over_pgfree : u_int32_t;       // Bytes free in overflow pages.
  end;


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

  TDB_TXN_QUEUE = record
    tqe_next : PDB_TXN;
    tqe_prev : ^PDB_TXN;
  end;

  TDB_TXN = record
    mgrp             : PDB_TXNMGR;              { Pointer to transaction manager.  }
    parent           : PDB_TXN;               { Pointer to transaction's parent.  }
    //last_lsn         : TDB_LSN;             { Lsn of last log write.  }
    txnid            : u_int32_t;              { Unique transaction id.  }
    name             : PChar;
    tid              : u_int32_t;                { Thread id for use in MT XA.  }
    td               : Pointer;
    //off              : roff_t;                   { Detail structure within region.  }
    lock_timeout     : db_timeout_t;    { Timeout for locks for this txn.  }
    expire           : db_timeout_t;          { Time this txn expires.  }
    txn_list         : pointer;             { Undo information for parent.  }
    {
      !!!
      Explicit representations of structures from queue.h.
      TAILQ_ENTRY(Tdb_txn) links;
      TAILQ_ENTRY(TDb_txn) xalinks;
    }
    links            : TDB_TXN_QUEUE;                  { Links transactions off manager.  }
    xalinks          : TDB_TXN_QUEUE;                { Links active XA transactions.  }
    {
      !!!
      Explicit representations of structures from queue.h.
      TAILQ_HEAD(__events, __txn_event) events;
    }
    kids : TDB_TXN_QUEUE;
    events : record
         tqh_first : PTXN_EVENT;
         tqh_last : ^PTXN_EVENT;
      end;
    logs : record                     { Links deferred events.  }
         stqh_first : Ptxn_logrec;
         stqh_last : ^Ptxn_logrec;
      end;
    klinks : TDB_TXN_QUEUE;
    api_internal : pointer;   { API-private structure: used by C++  }
    xml_internal : pointer;		(* XML API private. *)

    cursors : u_int32_t;      { Number of cursors open for txn  }

    //* DB_TXN PUBLIC HANDLE LIST BEGIN */
    abort : function (db  : PDB_TXN):longint;cdecl;
    commit : function (db  : PDB_TXN; _para2:u_int32_t):longint;cdecl;
    discard : function (db  : PDB_TXN; _para2:u_int32_t):longint; cdecl;
    get_name : function (dn : PDB_TXN; const name : Pchar):int; cdecl;
    id : function (db  : PDB_TXN):u_int32_t; cdecl;
    prepare : function (db  : PDB_TXN;var _para2:u_int8_t):longint; cdecl;
    set_name : function (db : PDB_TXN; const c: Pchar):int; cdecl;
    set_timeout : function (db  : PDB_TXN; _para2:db_timeout_t; _para3:u_int32_t):longint; cdecl;
    //* DB_TXN PUBLIC HANDLE LIST END */

    //* DB_TXN PRIVATE HANDLE LIST BEGIN */
    set_txn_lsnp: procedure(db : PDB_TXN; Var para1 : PDB_LSN; var para2 :PDB_LSN); cdecl;
    //* DB_TXN PRIVATE HANDLE LIST END */

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


(*
 * DB_LOCK_ILOCK --
 *	Internal DB access method lock.
 *)
  TDB_LOCK_ILOCK = record
	  pgno : db_pgno_t;			//* Page being locked. */
	  fileid : array [0..DB_FILE_ID_LEN-1] of u_int8_t; //* File id. */
	  _type  : u_int32_t;			//* Type of lock. */
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
    xa_txn             : TDB_TXN_QUEUE;
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

  TDBTYPE = (DB_UNDEF=0, DB_BTREE = 1,DB_HASH = 2,DB_RECNO = 3, DB_QUEUE = 4,DB_UNKNOWN = 5);

  TDBCQUEUE  = record
    tqh_first: PDBC;
    tqh_last : ^PDBC;
  end;

  TDBQUEUE  = record
    le_next : PDB;
    le_prev : ^PDB;
  end;

  TAssociateFunc = function (db : PDB; key : PDBT; Data : PDBT ; Key2 : PDBT ):longint; cdecl;

  TDB = record
	  pgsize            : u_int32_t;		(* Database logical page size. *)

	  db_append_recno   : function  (db  : PDB; _para2:PDBT;    _para3:db_recno_t):longint; cdecl;
    db_feedback       : procedure (db  : PDB; _para2:longint; _para3:longint); cdecl;
    dup_compare       : function  (db  : PDB; _para2:PDBT;    _para3:PDBT):longint; cdecl;

    app_private       : pointer;
    dbenv             : PDB_ENV;
    _type             : TDBTYPE;
    mpf               : Pointer; // PDB_MPOOLFILE;
    mutexp            : Pointer; //PDB_MUTEX;
    fname             : Pchar;
    dname             : Pchar;
    open_flags        : u_int32_t;
    fileid            : array[0..(DB_FILE_ID_LEN)-1] of u_int8_t;
    adj_fileid        : u_int32_t;
    log_filename      : Pchar; //PFNAME;

    meta_pgno         : db_pgno_t;
    lid               : u_int32_t;
    cur_lid           : u_int32_t;
    associate_lid     : u_int32_t;
    handle_lock       : TDB_LOCK;
    cl_id             : longint;
    timestamp         : time_t;
    my_rskey          : TDBT;
    my_rkey           : TDBT;
    my_rdata          : TDBT;
    saved_open_fhp    : PDB_FH;
    dblistlinks       : TDBQUEUE;
    free_queue        : TDBCQUEUE;
    active_queue      : TDBCQUEUE;
    join_queue        : TDBCQUEUE;
    s_secondaries     : record
                          lh_first : PDB;
                        end;
    s_links           : TDBQUEUE;
    s_refcnt          : u_int32_t;
    s_callback        : function (db  : PDB; _para2:PDBT; _para3:PDBT; _para4:PDBT):longint; cdecl;
    s_primary         : PDB;
    api_internal      : pointer;
    bt_internal       : pointer;
    h_internal        : pointer;
    q_internal        : pointer;
    xa_internal       : pointer;

    associate         : function (db  : PDB; _para2:PDB_TXN; _para3:PDB; _para4: TAssociateFunc; _para5:u_int32_t):longint; cdecl;
    close             : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    cursor            : function (db  : PDB; txn: PDB_TXN; var cursor: PDBC; Flags :u_int32_t):longint; cdecl;
    del               : function (db  : PDB; _para2: PDB_TXN; _para3:PDBT; _para4:u_int32_t):longint; cdecl;
    err               : procedure(db  : PDB; _para2:longint; _para3:Pchar; args:array of const); cdecl;
    errx              : procedure(db  : PDB; _para2:Pchar; args:array of const); cdecl;
    fd                : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get               : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5 :u_int32_t):longint; cdecl;
    pget              : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:PDBT; _para6:u_int32_t):longint; cdecl;
    get_byteswapped   : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get_cachesize     : function (db  : PDB; var _para2: u_int32_t; var _para3: u_int32_t; var _para4:longint):longint; cdecl;
    get_dbname        : function (db  : PDB; _para2:PPchar; _para3:PPchar):longint; cdecl;
    get_encrypt_flags : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_env           : function (db  : PDB; _para2: Pointer {PPDB_ENV}):longint; cdecl;
    get_errfile       : procedure(db  : PDB; _para2: Pointer {PPFILE} ); cdecl;
    get_errpfx        : procedure(db  : PDB; _para2:PPchar); cdecl;
    get_flags         : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_lorder        : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get_open_flags    : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_pagesize      : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_transactional : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get_type          : function (db  : PDB; var _para2:TDBTYPE):longint; cdecl;
    join              : function (db  : PDB; _para2: Pointer {PPDBC}; _para3: Pointer {PPDBC}; _para4:u_int32_t):longint; cdecl;
    key_range         : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4: Pointer{PDB_KEY_RANGE}; _para5:u_int32_t):longint; cdecl;
    open              : function (db  : PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:TDBTYPE; _para6:u_int32_t; _para7:longint):longint; cdecl;
    put               : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint; cdecl;
    remove            : function (db  : PDB; _para2:Pchar; _para3:Pchar; _para4:u_int32_t):longint; cdecl;
    rename            : function (db  : PDB; _para2:Pchar; _para3:Pchar; _para4:Pchar; _para5:u_int32_t):longint; cdecl;
    truncate          : function (db  : PDB; _para2:PDB_TXN; var _para3: u_int32_t; _para4:u_int32_t):longint; cdecl;
    set_append_recno  : function (db  : PDB; _para2: Pointer):longint; cdecl; //para2 : function (db  : PDB; _para2:PDBT; _para3:db_recno_t):longint
    set_alloc         : function (db  : PDB; _para2: TSysGetMem; _para3: TSysReallocMem; _para4:TSysFreeMem):longint; cdecl; // Pprocedure (_para1:size_t)
    set_cachesize     : function (db  : PDB; _para2:u_int32_t; _para3:u_int32_t; _para4:longint):longint; cdecl;
    set_dup_compare   : function (db  : PDB; _para2: Pointer):longint; cdecl;//function (db  : PDB; _para2:PDBT; _para3:PDBT):longint
    set_encrypt       : function (db  : PDB; _para2:Pchar; _para3:u_int32_t):longint; cdecl;
    set_errcall       : procedure(db  : PDB; _para2: Pointer); cdecl; //procedure (_para1:Pchar; _para2:Pchar)
    set_errfile       : procedure(db  : PDB; _para2: Pointer {PFILE}); cdecl;
    set_errpfx        : procedure(db  : PDB; _para2:Pchar); cdecl;
    set_feedback      : function (db  : PDB; _para2: Pointer):longint;  cdecl;//procedure (db  : PDB; _para2:longint; _para3:longint)
    set_flags         : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_lorder        : function (db  : PDB; _para2:longint):longint; cdecl;
    set_pagesize      : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_paniccall     : function (db  : PDB; _para2: pointer):longint; cdecl; //procedure (db  : PDB_ENV; _para2:longint)
    stat              : function (db  : PDB; _para2:pointer; _para3:u_int32_t):longint; cdecl;
    sync              : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    upgrade           : function (db  : PDB; _para2:Pchar; _para3:u_int32_t):longint; cdecl;
    verify            : function (db  : PDB; _para2:Pchar; _para3:Pchar; _para4: Pointer {PFILE}; _para5:u_int32_t):longint; cdecl;
    get_bt_minkey     : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    set_bt_compare    : function (db  : PDB; _para2: pointer):longint; cdecl; //function (db  : PDB; _para2:PDBT; _para3:PDBT):longint
    set_bt_maxkey     : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_bt_minkey     : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_bt_prefix     : function (db  : PDB; _para2: pointer):longint; cdecl; //function (db  : PDB; _para2:PDBT; _para3:PDBT):size_t
    get_h_ffactor     : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_h_nelem       : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    set_h_ffactor     : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_h_hash        : function (db  : PDB; _para2:pointer):longint; cdecl; //function (db  : PDB; _para2:pointer; _para3:u_int32_t):u_int32_t
    set_h_nelem       : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    get_re_delim      : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get_re_len        : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    get_re_pad        : function (db  : PDB; _para2:Plongint):longint; cdecl;
    get_re_source     : function (db  : PDB; _para2:PPchar):longint; cdecl;
    set_re_delim      : function (db  : PDB; _para2:longint):longint; cdecl;
    set_re_len        : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    set_re_pad        : function (db  : PDB; _para2:longint):longint; cdecl;
    set_re_source     : function (db  : PDB; _para2:Pchar):longint; cdecl;
    get_q_extentsize  : function (db  : PDB; var _para2:u_int32_t):longint; cdecl;
    set_q_extentsize  : function (db  : PDB; _para2:u_int32_t):longint; cdecl;
    db_am_remove      : function (db  : PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:PDB_LSN):longint; cdecl;
    db_am_rename      : function (db  : PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:Pchar):longint; cdecl;
    stored_get        : function (db  : PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint; cdecl;
    stored_close      : function (db  : PDB; _para2:u_int32_t):longint; cdecl;

    am_ok             : u_int32_t;
    orig_flags        : u_int32_t;
    flags             : u_int32_t;
  end;



  DBM = Pointer;
  PDBM = ^DBM;

  PPAGE = Pointer;
  PVRFY_DBINFO = pointer;
  PREGENV = Pointer;
  PREGION = pointer;
  PREGINFO = Pointer;
  PFILE = Pointer;
  PDB_MUTEX = Pointer;


	db_ca_mode= (DB_CA_DI	= 1,
	             DB_CA_DUP	= 2,
	             DB_CA_RSPLIT	= 3,
	             DB_CA_SPLIT	= 4
  );


(*******************************************************
 * Access method cursors.
 *******************************************************)
  TDBC = record
		dbp : PDB;			// Related DB access method.
		txn : PDB_TXN;	// Associated transaction.

		(*
		 * Active/free cursor queues.
		 *
		 * !!!
		 * Explicit representations of structures from queue.h.
		 * TAILQ_ENTRY(__dbc) links;
		 *)
		links : TDBCQUEUE;
		(*
		 * The DBT *'s below are used by the cursor routines to return
		 * data to the user when DBT flags indicate that DB should manage
		 * the returned memory.  They point at a DBT containing the buffer
		 * and length that will be used, and "belonging" to the handle that
		 * should "own" this memory.  This may be a "my_*" field of this
		 * cursor--the default--or it may be the corresponding field of
		 * another cursor, a DB handle, a join cursor, etc.  In general, it
		 * will be whatever handle the user originally used for the current
		 * DB interface call.
		 *)
		rskey : PDBT;		//* Returned secondary key. */
		rkey  : PDBT;		//* Returned [primary] key. */
		rdata : PDBT;		//* Returned data. */

		my_rskey : TDBT;		//* Space for returned secondary key. */
		my_rkey  : TDBT;		//* Space for returned [primary] key. */
		my_rdata : TDBT;		//* Space for returned data. */

		lid      : u_int32_t;		//* Default process' locker id. */
		locker   : u_int32_t;		//* Locker for this operation. */
		lock_dbt : TDBT;		      //* DBT referencing lock. */
		lock     : TDB_LOCK_ILOCK;		//* Object to be locked. */
		mylock   : TDB_LOCK;		//* CDB lock held on this cursor. */

		cl_id    : longint;		//* Remote client id. */

		dbtype   : TDBTYPE;		//* Cursor type. */

		internal : Pointer; //PDBC_INTERNAL;		//* Access method private. */

		c_close  : Function (dbc : PDBC):integer;	cdecl; //* Methods: public. */
		c_count  : function (dbc : PDBC; var recno : db_recno_t; flags : u_int32_t):integer; cdecl;
		c_del    : function (dbc : PDBC; flags : u_int32_t):integer; cdecl;
		c_dup    : function (dbc : PDBC; var dbc1 : PDBC; flags : u_int32_t):integer; cdecl;
		c_get    : function (dbc : PDBC; Key : PDBT; Data : PDBT; flags : u_int32_t):integer; cdecl;
		c_pget   : function (dbc : PDBC; dbt : PDBT; dbt1 : PDBT; dbt2 : PDBT; flags : u_int32_t):integer; cdecl;
		c_put    : function (dbc : PDBC; Key : PDBT; Data : PDBT; flags : u_int32_t):integer; cdecl;

						//* Methods: private. */
		c_am_bulk    : function (dbc : PDBC; dbt : PDBT; Flags : u_int32_t):integer; cdecl;
		c_am_close   : function (dbc : PDBC; pgno : db_pgno_t; var flags : integer):integer; cdecl;
		c_am_del     : function (dbc : PDBC):integer; cdecl;
		c_am_destroy : function (dbc : PDBC):integer; cdecl;
		c_am_get     : function (dbc : PDBC; dbt : PDBT; dbt1 : PDBT; flags : u_int32_t; var pgno : db_pgno_t):integer; cdecl;
		c_am_put     : function (dbc : PDBC; dbt : PDBT; dbt1 : PDBT; flags : u_int32_t; var pgno : db_pgno_t):integer; cdecl;
		c_am_writelock : function (dbc : PDBC):integer; cdecl;

		flags          : u_int32_t;
	end;




  function _db_create(var _para1: PDB; _para2:PDB_ENV; _para3:u_int32_t):longint; cdecl;
  function _db_strerror(_para1:longint):Pchar; cdecl;
  function _db_version(_para1:Plongint; _para2:Plongint; _para3:Plongint):Pchar; cdecl;
  function _log_compare(_para1:PDB_LSN; _para2:PDB_LSN):longint; cdecl;


  function _db_env_create (var dbenv :PDB_ENV; flags: u_int32_t):integer ; cdecl;

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
  function  ___db_util_cache (p1 : PDB_ENV; db : PDB; var p3 : u_int32_t;var p4 : integer):integer; cdecl;
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

  function _db_create              ; cdecl; external  dblib name 'db_create'              ;
  function _db_env_create          ; cdecl; external  dblib name 'db_env_create'          ;
  function _db_strerror            ; cdecl; external  dblib name 'db_strerror'            ;
  function _db_version             ; cdecl; external  dblib name 'db_version'             ;

  function _log_compare            ; cdecl; external  dblib name 'log_compare'            ;

  function _db_env_set_func_close  ; cdecl; external  dblib name 'db_env_set_func_close'  ;
  function _db_env_set_func_dirfree; cdecl; external  dblib name 'db_env_set_func_dirfree';
  function _db_env_set_func_dirlist; cdecl; external  dblib name 'db_env_set_func_dirlist';
  function _db_env_set_func_exists ; cdecl; external  dblib name 'db_env_set_func_exists' ;
  function _db_env_set_func_free   ; cdecl; external  dblib name 'db_env_set_func_free'   ;
  function _db_env_set_func_fsync  ; cdecl; external  dblib name 'db_env_set_func_fsync'  ;
  function _db_env_set_func_ioinfo ; cdecl; external  dblib name 'db_env_set_func_ioinfo' ;
  function _db_env_set_func_malloc ; cdecl; external  dblib name 'db_env_set_func_malloc' ;
  function _db_env_set_func_map    ; cdecl; external  dblib name 'db_env_set_func_map'    ;
  function _db_env_set_func_open   ; cdecl; external  dblib name 'db_env_set_func_open'   ;
  function _db_env_set_func_read   ; cdecl; external  dblib name 'db_env_set_func_read'   ;
  function _db_env_set_func_realloc; cdecl; external  dblib name 'db_env_set_func_realloc';
  function _db_env_set_func_rename ; cdecl; external  dblib name 'db_env_set_func_rename' ;
  function _db_env_set_func_seek   ; cdecl; external  dblib name 'db_env_set_func_seek'   ;
  function _db_env_set_func_sleep  ; cdecl; external  dblib name 'db_env_set_func_sleep'  ;
  function _db_env_set_func_unlink ; cdecl; external  dblib name 'db_env_set_func_unlink' ;
  function _db_env_set_func_unmap  ; cdecl; external  dblib name 'db_env_set_func_unmap'  ;
  function _db_env_set_func_write  ; cdecl; external  dblib name 'db_env_set_func_write'  ;
  function _db_env_set_func_yield  ; cdecl; external  dblib name 'db_env_set_func_yield'  ;

  function  ___db_dbm_close	   ; cdecl; external dblib name '__db_dbm_close'         ;
  function  ___db_dbm_delete	   ; cdecl; external dblib name '__db_dbm_delete'        ;
  function  ___db_dbm_fetch	   ; cdecl; external dblib name '__db_dbm_fetch'         ;
  function  ___db_dbm_firstkey     ; cdecl; external dblib name '__db_dbm_firstkey'      ;
  function  ___db_dbm_init	   ; cdecl; external dblib name '__db_dbm_init'          ;
  function  ___db_dbm_nextkey	   ; cdecl; external dblib name '__db_dbm_nextkey'       ;
  function  ___db_dbm_store	   ; cdecl; external dblib name '__db_dbm_store'         ;
  //function __db_hsearch	   ; cdecl; external dblib name '__db_hsearch'           ;
  function  ___db_ndbm_clearerr    ; cdecl; external dblib name '__db_ndbm_clearerr'     ;
  procedure ___db_ndbm_close	   ; cdecl; external dblib name '__db_ndbm_close'        ;
  function  ___db_ndbm_delete	   ; cdecl; external dblib name '__db_ndbm_delete'       ;
  function  ___db_ndbm_dirfno	   ; cdecl; external dblib name '__db_ndbm_dirfno'       ;
  function  ___db_ndbm_error	   ; cdecl; external dblib name '__db_ndbm_error'        ;
  function  ___db_ndbm_fetch	   ; cdecl; external dblib name '__db_ndbm_fetch'        ;
  function  ___db_ndbm_firstkey    ; cdecl; external dblib name '__db_ndbm_firstkey'     ;
  function  ___db_ndbm_nextkey     ; cdecl; external dblib name '__db_ndbm_nextkey'      ;
  function  ___db_ndbm_open	   ; cdecl; external dblib name '__db_ndbm_open'         ;
  function  ___db_ndbm_pagfno	   ; cdecl; external dblib name '__db_ndbm_pagfno'       ;
  function  ___db_ndbm_rdonly	   ; cdecl; external dblib name '__db_ndbm_rdonly'       ;
  function  ___db_ndbm_store	   ; cdecl; external dblib name '__db_ndbm_store'        ;
  //
  function  ___memp_dump_region	   ; cdecl; external dblib name '__memp_dump_region'     ;

  function  ___txn_id_set	   ; cdecl; external dblib name '__txn_id_set'           ;
  function  ___crdel_init_print	   ; cdecl; external dblib name '__crdel_init_print'     ;

  function  ___db_close            ; cdecl; external dblib name '__db_close';
  function  ___db_hcreate	   ; cdecl; external dblib name '__db_hcreate'           ;
  function  ___db_add_recovery     ; cdecl; external dblib name '__db_add_recovery'      ;
  procedure ___db_hdestroy	   ; cdecl; external dblib name '__db_hdestroy'          ;
  procedure ___db_loadme	   ; cdecl; external dblib name '__db_loadme'          ;
  function  ___db_dispatch	   ; cdecl; external dblib name '__db_dispatch'          ;
  function  ___db_dump	           ; cdecl; external dblib name '__db_dump'              ;
  function  ___db_e_stat	   ; cdecl; external dblib name '__db_e_stat'            ;
  //function __db_err	           ; cdecl; external dblib name '__db_err'               ;
  function  ___db_getlong	   ; cdecl; external dblib name '__db_getlong'           ;
  function  ___db_getulong	   ; cdecl; external dblib name '__db_getulong'          ;
  //function __db_global_values	   ; cdecl; external dblib name '__db_global_values'     ;
  function  ___db_init_print	   ; cdecl; external dblib name '__db_init_print'        ;
  procedure ___db_inmemdbflags	   ; cdecl; external dblib name '__db_inmemdbflags'      ;
  function  ___db_isbigendian	   ; cdecl; external dblib name '__db_isbigendian'       ;
  function  ___db_omode	           ; cdecl; external dblib name '__db_omode'             ;
  function  ___db_overwrite	   ; cdecl; external dblib name '__db_overwrite'         ;
  function  ___db_pgin	           ; cdecl; external dblib name '__db_pgin'              ;
  function  ___db_pgout	           ; cdecl; external dblib name '__db_pgout'             ;
  function  ___db_pr_callback	   ; cdecl; external dblib name '__db_pr_callback'       ;
  function  ___db_prdbt	           ; cdecl; external dblib name '__db_prdbt'             ;
  function  ___db_prfooter	   ; cdecl; external dblib name '__db_prfooter'          ;
  function  ___db_prheader	   ; cdecl; external dblib name '__db_prheader'          ;
  function  ___db_rpath	           ; cdecl; external dblib name '__db_rpath'             ;
  function  ___db_util_cache	   ; cdecl; external dblib name '__db_util_cache'        ;
  function  ___db_util_interrupted ; cdecl; external dblib name '__db_util_interrupted'  ;
  function  ___db_util_logset	   ; cdecl; external dblib name '__db_util_logset'       ;
  procedure ___db_util_siginit	   ; cdecl; external dblib name '__db_util_siginit'      ;
  procedure ___db_util_sigresend   ; cdecl; external dblib name '__db_util_sigresend'    ;
  function  ___db_verify_internal  ; cdecl; external dblib name '__db_verify_internal'   ;
  function  ___db_panic	           ; cdecl; external dblib name '__db_panic'             ;
  function  ___db_r_attach	   ; cdecl; external dblib name '__db_r_attach'          ;
  function  ___db_r_detach	   ; cdecl; external dblib name '__db_r_detach'          ;
  function  ___db_win32_mutex_init ; cdecl; external dblib name '__db_win32_mutex_init'  ;
  function  ___db_win32_mutex_lock ; cdecl; external dblib name '__db_win32_mutex_lock'  ;
  function  ___db_win32_mutex_unlock;cdecl; external dblib name '__db_win32_mutex_unlock';

  function  ___dbreg_init_print;  cdecl; external dblib name '__dbreg_init_print'     ;

  function  ___fop_init_print;    cdecl; external dblib name '__fop_init_print'       ;

  function  ___ham_get_meta;      cdecl; external dblib name '__ham_get_meta'         ;
  function  ___ham_init_print;    cdecl; external dblib name '__ham_init_print'       ;
  function  ___ham_pgin;          cdecl; external dblib name '__ham_pgin'             ;
  function  ___ham_pgout;         cdecl; external dblib name '__ham_pgout'            ;
  function  ___ham_release_meta;  cdecl; external dblib name '__ham_release_meta'     ;
  function  ___ham_func2;         cdecl; external dblib name '__ham_func2'            ;
  function  ___ham_func3;         cdecl; external dblib name '__ham_func3'            ;
  function  ___ham_func4;         cdecl; external dblib name '__ham_func4'            ;
  function  ___ham_func5;         cdecl; external dblib name '__ham_func5'            ;
  function  ___ham_test;          cdecl; external dblib name '__ham_test'             ;

  function  ___os_clock;          cdecl; external dblib name '__os_clock'             ;
  function  ___os_get_errno;      cdecl; external dblib name '__os_get_errno'         ;
  procedure ___os_id;             cdecl; external dblib name '__os_id'                ;
  procedure ___os_set_errno;      cdecl; external dblib name '__os_set_errno'         ;
  function  ___os_sleep;          cdecl; external dblib name '__os_sleep'             ;
  procedure ___os_ufree;          cdecl; external dblib name '__os_ufree'             ;
  procedure ___os_yield;          cdecl; external dblib name '__os_yield'             ;
  function  ___os_calloc;         cdecl; external dblib name '__os_calloc'            ;
  function  ___os_closehandle;    cdecl; external dblib name '__os_closehandle'       ;
  procedure ___os_free;           cdecl; external dblib name '__os_free'              ;
  function  ___os_ioinfo;         cdecl; external dblib name '__os_ioinfo'            ;
  function  ___os_malloc;         cdecl; external dblib name '__os_malloc'            ;
  function  ___os_open;           cdecl; external dblib name '__os_open'              ;
  function  ___os_openhandle;     cdecl; external dblib name '__os_openhandle'        ;
  function  ___os_read;           cdecl; external dblib name '__os_read'              ;
  function  ___os_realloc   ;     cdecl; external dblib name '__os_realloc'           ;
  function  ___os_strdup   ;      cdecl; external dblib name '__os_strdup'            ;
  function  ___os_umalloc;        cdecl; external dblib name '__os_umalloc'           ;
  function  ___os_write;          cdecl; external dblib name '__os_write'             ;

  function  ___qam_init_print;    cdecl; external dblib name '__qam_init_print'       ;
  function  ___qam_pgin_out;      cdecl; external dblib name '__qam_pgin_out'         ;

  function  ___txn_init_print;    cdecl; external dblib name '__txn_init_print'       ;
  //function ___lock_open;               external

  function ___db_panic_msg;       cdecl; external dblib name '__db_panic_msg';
  function ___db_key_range_pp;    cdecl; external dblib name '__db_key_range_pp';
  function ___db_open_pp;         cdecl; external dblib name '__db_open_pp';
  function ___db_fnl;             cdecl; external dblib name '__db_fnl';
  function ___db_put;             cdecl; external dblib name '__db_put';
  function ___db_del;             cdecl; external dblib name '__db_del';
  function ___db_associate;       cdecl; external dblib name '__db_associate';
  function ___db_pg_alloc_log;    cdecl; external dblib name '__db_pg_alloc_log';
  function ___db_pg_freedata_log; cdecl; external dblib name '__db_pg_freedata_log';
  function ___db_c_count;         cdecl; external dblib name '__db_c_count';
  function ___db_c_dup;           cdecl; external dblib name '__db_c_dup';
  function ___db_c_get;           cdecl; external dblib name '__db_c_get';
  function ___db_associate_pp;    cdecl; external dblib name '__db_associate_pp';
  function ___db_close_pp;        cdecl; external dblib name '__db_close_pp';
  function ___db_cursor_pp;       cdecl; external dblib name '__db_cursor_pp';
  function ___db_del_pp;          cdecl; external dblib name '__db_del_pp';
  function ___db_fd_pp;           cdecl; external dblib name '__db_fd_pp';
  function ___db_get_pp;          cdecl; external dblib name '__db_get_pp';
  function ___db_join_pp;         cdecl; external dblib name '__db_join_pp';
  function ___db_pget_pp;         cdecl; external dblib name '__db_pget_pp';


  function  ___bam_init_print;    cdecl; external dblib name '__bam_init_print';
  function  ___bam_pgin;          cdecl; external dblib name '__bam_pgin';
  function  ___bam_pgout;         cdecl; external dblib name '__bam_pgout';
  function  ___bam_curadj_log;    cdecl; external dblib name '__bam_curadj_log';
  function  ___bam_ca_delete;     cdecl; external dblib name '__bam_ca_delete';
  function  ___ram_ca_delete;     cdecl; external dblib name '__ram_ca_delete';
  function  ___bam_cdel_log;      cdecl; external dblib name '__bam_cdel_log';
  function  ___bam_cmp;           cdecl; external dblib name '__bam_cmp';
  function  ___bam_defcmp;        cdecl; external dblib name '__bam_defcmp';
  function  ___bam_ca_di;         cdecl; external dblib name '__bam_ca_di';
  function  ___bam_init_recover;  cdecl; external dblib name '__bam_init_recover';


  function  ___lock_open;         cdecl; external dblib name '__lock_open';
  function  ___lock_dump_region;  cdecl; external dblib name '__lock_dump_region';
  function  ___lock_id_set;       cdecl; external dblib name '__lock_id_set';


initialization
finalization
end.



