
{$Z4}
unit db;
interface
uses
  windows, dbconst, os;
{
  Automatically converted by H2Pas 0.99.15 from db.h
  The following command line parameters were used:
    db.h
}

{ $PACKRECORDS C}


{
     !!!
     Berkeley DB uses specifically sized types.  If they're not provided by
     the system, typedef them here.

     We protect them against multiple inclusion using __BIT_TYPES_DEFINED__,
     as does BIND and Kerberos, since we don't know for sure what #include
     files the user is using.

     !!!
     We also provide the standard u_int, u_long etc., if they're not provided
     by the system.
}
const
  dblib ='Berkeleydb.dll';
type
   u_int8_t  = byte;
   int16_t   = smallint;
   u_int16_t = word;
   int32_t   = longint;
   u_int32_t = longword;

   size_t    = longword;
   time_t    = longword;
type
   u_char = byte;
   u_short = word;
   u_int = dword;
   u_long = dword;
{$ifdef _WIN64}
type
   ssize_t = __int64;
{$else}
type
   ssize_t = longword;
{$endif}
  { Basic types that are exported or quasi-exported.  }

type
  db_pgno_t = u_int32_t;
  { Page number type.  }

  db_indx_t = u_int16_t;
  { Page offset type.  }
  { >= # of pages in a file  }


type
  db_recno_t = u_int32_t;
  { Record number type.  }
  { >= # of records in a tree  }

const
  DB_MAX_RECORDS = $ffffffff;

type

  db_timeout_t = u_int32_t;

  { Type of a timeout.  }
  {
     Region offsets are currently limited to 32-bits.  I expect that's going
     to have to be fixed in the not-too-distant future, since we won't want to
     split 100Gb memory pools into that many different regions.
    }

     roff_t = u_int32_t;
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



  PPDB_ENV = ^PDB_ENV;
  PDB_ENV = ^TDB_ENV;
  PDB_FH = ^TDB_FH;

  PDB_LOGC = ^TDB_LOGC;
  PDB_MPOOLFILE = ^TDB_MPOOLFILE;

  PMPOOLFILE = ^TMPOOLFILE;

(*
 * MPOOLFILE --
 *	Shared DB_MPOOLFILE information.
 *)
  TMPOOLFILE = record 
         {undefined structure}
  end;

  PDB_TXNMGR = ^TDB_TXNMGR;
  TDB_TXNMGR = record
         {undefined structure}
  end;

  PDB_TXN = ^TDB_TXN;

  P__txn_event = ^__txn_event;
  __txn_event = record
  end;

  P__txn_logrec = ^__txn_logrec;
  __txn_logrec = record
  end;

  PDB_TXN_ACTIVE = ^TDB_TXN_ACTIVE;

  PPDB = ^PDB;
  PDB = ^TDB;

  PDBT = ^TDBT;


  PDB_MUTEX = ^TDB_MUTEX;
  TDB_MUTEX = record //__mutex_t
  end;

  PFNAME = ^FNAME;
  FNAME = record //__fname
  end;

  PPDBC=^PDBC;
  PDBC = ^TDBC;

  PDB_KEY_RANGE = ^TDB_KEY_RANGE;

  PPFILE = ^PFILE;
  PFILE = ^TFILE;
  TFILE = record
  end;

  PDBC_INTERNAL = ^TDBC_INTERNAL;
  TDBC_INTERNAL = record // __dbc_internal
  end;

  PDB_LOG_STAT = ^TDB_LOG_STAT;

  PDB_LOCK =^TDB_LOCK;

  PDB_LOCK_STAT = ^TDB_LOCK_STAT;

  PDB_LOCKREQ = ^TDB_LOCKREQ;

  PDB_MPOOL_STAT = ^TDB_MPOOL_STAT;

  PDB_MPOOL_FSTAT = ^TDB_MPOOL_FSTAT;

  PDB_REP_STAT = ^TDB_REP_STAT;

  PDB_PREPLIST = ^TDB_PREPLIST;

  PDB_TXN_STAT = ^TDB_TXN_STAT;

  PENTRY = ^TENTRY;
  TENTRY = record
    key : Pchar;
    data : Pchar;
  end;

{ Key/data structure -- a Data-Base Thang.  }
   TDBT = record
       {  data/size must be fields 1 and 2 for DB 1.85 compatibility. }
        data : pointer;   { Key/data  }
        size : u_int32_t; { key/data length  }
        ulen : u_int32_t; { RO: length of user buffer.  }
        dlen : u_int32_t; { RO: get/put record length.  }
        doff : u_int32_t; { RO: get/put record offset.  }
        flags : u_int32_t;
     end;

  { Flags private to db_create. }
  { Open of an internal rep database.  }

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
  {
     Request types.
    }
  db_lockop_t = (
    DB_LOCK_DUMP = 0,           { Display held locks.  }
    DB_LOCK_GET = 1,            { Get the lock.  }
    DB_LOCK_GET_TIMEOUT = 2,    { Get lock with a timeout.  }
    DB_LOCK_INHERIT = 3,        { Pass locks to parent.  }
    DB_LOCK_PUT = 4,            { Release the lock.  }
    DB_LOCK_PUT_ALL = 5,        { Release locker's locks.  }
    DB_LOCK_PUT_OBJ = 6,        { Release locker's locks on obj.  }
    DB_LOCK_PUT_READ = 7,       { Release locker's read locks.  }
    DB_LOCK_TIMEOUT = 8,        { Force a txn to timeout.  }
    DB_LOCK_TRADE = 9,          { Trade locker ids on a lock.  }
    DB_LOCK_UPGRADE_WRITE = 10  { Upgrade writes for dirty reads.  }
    );
  {
     Status of a lock.
    }
  db_status_t = (
    DB_LSTAT_ABORTED = 1,   { Lock belongs to an aborted txn.  }
    DB_LSTAT_ERR = 2,       { Lock is bad.  }
    DB_LSTAT_EXPIRED = 3,   { Lock has expired.  }
    DB_LSTAT_FREE = 4,      { Lock is unallocated.  }
    DB_LSTAT_HELD = 5,      { Lock is currently held.  }
    DB_LSTAT_NOTEXIST = 6,  { Object on which lock was waiting was removed  }
    DB_LSTAT_PENDING = 7,   { Lock was waiting and has been promoted; waiting
                              for the owner to run and upgrade it to held.  }
    DB_LSTAT_WAITING = 8    { Lock is on the wait queue.  }
    );

  { Lock statistics structure.  }
  TDB_LOCK_STAT = record
     st_id : u_int32_t;                { Last allocated locker ID.  }
     st_cur_maxid : u_int32_t;         { Current maximum unused ID.  }
     st_maxlocks : u_int32_t;          { Maximum number of locks in table.  }
     st_maxlockers : u_int32_t;        { Maximum num of lockers in table.  }
     st_maxobjects : u_int32_t;        { Maximum num of objects in table.  }
     st_nmodes : u_int32_t;            { Number of lock modes.  }
     st_nlocks : u_int32_t;            { Current number of locks.  }
     st_maxnlocks : u_int32_t;         { Maximum number of locks so far.  }
     st_nlockers : u_int32_t;          { Current number of lockers.  }
     st_maxnlockers : u_int32_t;       { Maximum number of lockers so far.  }
     st_nobjects : u_int32_t;          { Current number of objects.  }
     st_maxnobjects : u_int32_t;       { Maximum number of objects so far.  }
     st_nconflicts : u_int32_t;        { Number of lock conflicts.  }
     st_nrequests : u_int32_t;         { Number of lock gets.  }
     st_nreleases : u_int32_t;         { Number of lock puts.  }
     st_nnowaits : u_int32_t;          { Number of requests that would have
                                         waited, but NOWAIT was set.  }
     st_ndeadlocks : u_int32_t;        { Number of lock deadlocks.  }
     st_locktimeout : db_timeout_t;    { Lock timeout.  }
     st_nlocktimeouts : u_int32_t;     { Number of lock timeouts.  }
     st_txntimeout : db_timeout_t;     { Transaction timeout.  }
     st_ntxntimeouts : u_int32_t;      { Number of transaction timeouts.  }
     st_region_wait : u_int32_t;       { Region lock granted after wait.  }
     st_region_nowait : u_int32_t;     { Region lock granted without wait.  }
     st_regsize : u_int32_t;           { Region size.  }
  end;

  { DB_LOCK_ILOCK --  Internal DB access method lock. }
  TDB_LOCK_ILOCK = record
    pgno : db_pgno_t;                                     { Page being locked.  }
    fileid : array[0..(DB_FILE_ID_LEN)-1] of u_int8_t;    { File id.  }
    _type : u_int32_t;                                    { Type of lock.  }
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

  { Lock request structure.  }
  TDB_LOCKREQ = record
    op : db_lockop_t;         { Operation.  }
    mode : db_lockmode_t;     { Requested mode.  }
    timeout : db_timeout_t;   { Time to expire lock.  }
    obj : PDBT;               { Object being locked.  }
    lock : TDB_LOCK;          { Lock returned.  }
  end;

  {                                                      
     Logging.
                                                          }
  { Current log version.  }


  {
     Application-specified log record types start at DB_user_BEGIN, and must not
     equal or exceed DB_debug_FLAG.
    
     DB_debug_FLAG is the high-bit of the u_int32_t that specifies a log record
     type.  If the flag is set, it's a log record that was logged for debugging
     purposes only, even if it reflects a database change -- the change was part
     of a non-durable transaction.
    }
  TDB_LOGC = record
    dbenv : PDB_ENV;       { Enclosing dbenv.  }
    c_fhp : PDB_FH;        { File handle.  }
    c_lsn : TDB_LSN;       { Cursor: LSN  }
    c_len : u_int32_t;     { Cursor: record length  }
    c_prev : u_int32_t;    { Cursor: previous record's offset  }
    c_dbt : TDBT;          { Return DBT.  }
    bp : ^u_int8_t;        { Allocated read buffer.  }
    bp_size : u_int32_t;   { Read buffer length in bytes.  }
    bp_rlen : u_int32_t;   { Read buffer valid data length.  }
    bp_lsn : TDB_LSN;      { Read buffer first byte LSN.  }
    bp_maxrec : u_int32_t; { Max record length in the log file.  }
    close : function ( _para1:PDB_LOGC; _para2:u_int32_t):longint;cdecl;
    get : function (_para1:PDB_LOGC; _para2:PDB_LSN; _para3:PDBT; _para4:u_int32_t):longint; cdecl;
    flags : u_int32_t;
  end;

  { Log statistics structure.  }
  TDB_LOG_STAT = record
    st_magic : u_int32_t;                { Log file magic number.  }
    st_version : u_int32_t;              { Log file version number.  }
    st_mode : longint;                   { Log file mode.  }
    st_lg_bsize : u_int32_t;             { Log buffer size.  }
    st_lg_size : u_int32_t;              { Log file size.  }
    st_w_bytes : u_int32_t;              { Bytes to log.  }
    st_w_mbytes : u_int32_t;             { Megabytes to log.  }
    st_wc_bytes : u_int32_t;             { Bytes to log since checkpoint.  }
    st_wc_mbytes : u_int32_t;            { Megabytes to log since checkpoint.  }
    st_wcount : u_int32_t;               { Total writes to the log.  }
    st_wcount_fill : u_int32_t;          { Overflow writes to the log.  }
    st_scount : u_int32_t;               { Total syncs to the log.  }
    st_region_wait : u_int32_t;          { Region lock granted after wait.  }
    st_region_nowait : u_int32_t;        { Region lock granted without wait.  }
    st_cur_file : u_int32_t;             { Current log file number.  }
    st_cur_offset : u_int32_t;           { Current log file offset.  }
    st_disk_file : u_int32_t;            { Known on disk log file number.  }
    st_disk_offset : u_int32_t;          { Known on disk log file offset.  }
    st_regsize : u_int32_t;              { Region size.  }
    st_maxcommitperflush : u_int32_t;    { Max number of commits in a flush.  }
    st_mincommitperflush : u_int32_t;    { Min number of commits in a flush.  }
  end;

  {                                                      
     Shared buffer cache (mpool).
                                                          }
  { Flag values for DB_MPOOLFILE->get.  }
  { Create a page.  }
  TDB_CACHE_PRIORITY = (
    DB_PRIORITY_VERY_LOW = 1,
    DB_PRIORITY_LOW = 2,
    DB_PRIORITY_DEFAULT = 3,
    DB_PRIORITY_HIGH = 4,
    DB_PRIORITY_VERY_HIGH = 5
  );

  { Application supplied a file ID.  }

  { Per-process DB_MPOOLFILE information.  }
  {
  	   MP_FILEID_SET, MP_OPEN_CALLED and MP_READONLY do not need to be
  	   thread protected because they are initialized before the file is
  	   linked onto the per-process lists, and never modified.

  	   MP_FLUSH is thread protected becase it is potentially read/set by
  	   multiple threads of control.
  	  }

  
  TDB_MPOOLFILE = record
    fhp : PDB_FH;                      { Underlying file handle.  }
    { !!! The ref, pinref and q fields are protected by the region lock. }
    ref : u_int32_t;                   { Reference count.  }
    pinref : u_int32_t;                { Pinned block reference count.  }
    { !!! Explicit representations of structures from queue.h. TAILQ_ENTRY(DB_MPOOLFILE) q; }
    q : record                         { Linked list of DB_MPOOLFILE's.  }
         tqe_next : PDB_MPOOLFILE;
         tqe_prev : ^PDB_MPOOLFILE;
      end;
    {
      !!!
      The rest of the fields (with the exception of the MP_FLUSH flag)
      are not thread-protected, even when they may be modified at any
      time by the application.  The reason is the DB_MPOOLFILE handle
      is single-threaded from the viewpoint of the application, and so
      the only fields needing to be thread-protected are those accessed
      by checkpoint or sync threads when using DB_MPOOLFILE structures
      to flush buffers from the cache.
    }
    dbenv : PDB_ENV;                   { Overlying TDB_ENV.  }
    mfp : PMPOOLFILE;                  { Underlying MPOOLFILE.  }
    clear_len : u_int32_t;             { Cleared length on created pages.  }
    fileid : array[0..(DB_FILE_ID_LEN)-1] of u_int8_t; { Unique file ID.  }
    ftype : longint;                   { File type.  }
    lsn_offset : int32_t;              { LSN offset in page.  }
    gbytes : u_int32_t;                { Maximum file size.  }
    bytes : u_int32_t;                 { Byte-string passed to pgin/pgout.  }
    pgcookie : PDBT;                   { Cache priority.  }
    priority : TDB_CACHE_PRIORITY;     { Address of mmap'd region.  }
    addr : pointer;                    { Length of mmap'd region.  }
    len : size_t;                      { Flags to DB_MPOOLFILE->set_flags.  }
    config_flags : u_int32_t;
    close : function (_para1:PDB_MPOOLFILE; _para2:u_int32_t):longint;cdecl;
    get : function (_para1:PDB_MPOOLFILE; var _para2: db_pgno_t; _para3:u_int32_t; _para4:pointer):longint; cdecl;
    open : function (_para1:PDB_MPOOLFILE; _para2:Pchar; _para3:u_int32_t; _para4:longint; _para5:size_t):longint; cdecl;
    put : function (_para1:PDB_MPOOLFILE; _para2:pointer; _para3:u_int32_t):longint; cdecl;
    _set : function (_para1:PDB_MPOOLFILE; _para2:pointer; _para3:u_int32_t):longint; cdecl;
    get_clear_len : function (_para1:PDB_MPOOLFILE; var _para2: u_int32_t):longint; cdecl;
    set_clear_len : function (_para1:PDB_MPOOLFILE; _para2:u_int32_t):longint; cdecl;
    get_fileid : function (_para1:PDB_MPOOLFILE; var _para2:u_int8_t):longint; cdecl;
    set_fileid : function (_para1:PDB_MPOOLFILE; var _para2:u_int8_t):longint; cdecl;
    get_flags : function (_para1:PDB_MPOOLFILE; var _para2:u_int32_t):longint; cdecl;
    set_flags : function (_para1:PDB_MPOOLFILE; _para2:u_int32_t; _para3:longint):longint; cdecl;
    get_ftype : function (_para1:PDB_MPOOLFILE; var _para2:longint):longint; cdecl;
    set_ftype : function (_para1:PDB_MPOOLFILE; _para2:longint):longint; cdecl;
    get_lsn_offset : function (_para1:PDB_MPOOLFILE; var _para2:int32_t):longint; cdecl;
    set_lsn_offset : function (_para1:PDB_MPOOLFILE; _para2:int32_t):longint; cdecl;
    get_maxsize : function (_para1:PDB_MPOOLFILE; var _para2:u_int32_t; var _para3:u_int32_t):longint; cdecl;
    set_maxsize : function (_para1:PDB_MPOOLFILE; _para2:u_int32_t; _para3:u_int32_t):longint; cdecl;
    get_pgcookie : function (_para1:PDB_MPOOLFILE; _para2:PDBT):longint; cdecl;
    set_pgcookie : function (_para1:PDB_MPOOLFILE; _para2:PDBT):longint; cdecl;
    get_priority : function (_para1:PDB_MPOOLFILE; var _para2: TDB_CACHE_PRIORITY):longint; cdecl;
    set_priority : function (_para1:PDB_MPOOLFILE; _para2:TDB_CACHE_PRIORITY):longint; cdecl;
    sync : function (_para1:PDB_MPOOLFILE):longint; cdecl;
    flags : u_int32_t;
  end;

  {
     Mpool statistics structure.
    }
  TDB_MPOOL_STAT = record
    st_gbytes : u_int32_t;                   { Total cache size: GB.  }
    st_bytes : u_int32_t;                    { Total cache size: B.  }
    st_ncache : u_int32_t;                   { Number of caches.  }
    st_regsize : u_int32_t;                  { Cache size.  }
    st_map : u_int32_t;                      { Pages from mapped files.  }
    st_cache_hit : u_int32_t;                { Pages found in the cache.  }
    st_cache_miss : u_int32_t;               { Pages not found in the cache.  }
    st_page_create : u_int32_t;              { Pages created in the cache.  }
    st_page_in : u_int32_t;                  { Pages read in.  }
    st_page_out : u_int32_t;                 { Pages written out.  }
    st_ro_evict : u_int32_t;                 { Clean pages forced from the cache.  }
    st_rw_evict : u_int32_t;                 { Dirty pages forced from the cache.  }
    st_page_trickle : u_int32_t;             { Pages written by memp_trickle.  }
    st_pages : u_int32_t;                    { Total number of pages.  }
    st_page_clean : u_int32_t;               { Clean pages.  }
    st_page_dirty : u_int32_t;               { Dirty pages.  }
    st_hash_buckets : u_int32_t;             { Number of hash buckets.  }
    st_hash_searches : u_int32_t;            { Total hash chain searches.  }
    st_hash_longest : u_int32_t;             { Longest hash chain searched.  }
    st_hash_examined : u_int32_t;            { Total hash entries searched.  }
    st_hash_nowait : u_int32_t;              { Hash lock granted with nowait.  }
    st_hash_wait : u_int32_t;                { Hash lock granted after wait.  }
    st_hash_max_wait : u_int32_t;            { Max hash lock granted after wait.  }
    st_region_nowait : u_int32_t;            { Region lock granted with nowait.  }
    st_region_wait : u_int32_t;              { Region lock granted after wait.  }
    st_alloc : u_int32_t;                    { Number of page allocations.  }
    st_alloc_buckets : u_int32_t;            { Buckets checked during allocation.  }
    st_alloc_max_buckets : u_int32_t;        { Max checked during allocation.  }
    st_alloc_pages : u_int32_t;              { Pages checked during allocation.  }
    st_alloc_max_pages : u_int32_t;          { Max checked during allocation.  }
  end;

  { Mpool file statistics structure.  }
  TDB_MPOOL_FSTAT = record
    file_name      : Pchar;       { File name.  }
    st_pagesize    : size_t;      { Page size.  }
    st_map         : u_int32_t;   { Pages from mapped files.  }
    st_cache_hit   : u_int32_t;   { Pages found in the cache.  }
    st_cache_miss  : u_int32_t;   { Pages not found in the cache.  }
    st_page_create : u_int32_t;   { Pages created in the cache.  }
    st_page_in     : u_int32_t;   { Pages read in.  }
    st_page_out    : u_int32_t;   { Pages written out.  }
  end;

  {                                                      
     Transactions and recovery.
                                                          }
     db_recops = (DB_TXN_ABORT = 0,DB_TXN_APPLY = 1,
       DB_TXN_BACKWARD_ALLOC = 2,DB_TXN_BACKWARD_ROLL = 3,
       DB_TXN_FORWARD_ROLL = 4,DB_TXN_GETPGNOS = 5,
       DB_TXN_OPENFILES = 6,DB_TXN_POPENFILES = 7,
       DB_TXN_PRINT = 8);
  {
     BACKWARD_ALLOC is used during the forward pass to pick up any aborted
     allocations for files that were created during the forward pass.
     The main difference between _ALLOC and _ROLL is that the entry for
     the file not exist during the rollforward pass.
    }
    
  { Transaction that has committed.  }
  TDB_TXN = record
    mgrp : PDB_TXNMGR;              { Pointer to transaction manager.  }
    parent : PDB_TXN;               { Pointer to transaction's parent.  }
    last_lsn : TDB_LSN;             { Lsn of last log write.  }
    txnid : u_int32_t;              { Unique transaction id.  }
    tid : u_int32_t;                { Thread id for use in MT XA.  }
    off : roff_t;                   { Detail structure within region.  }
    lock_timeout : db_timeout_t;    { Timeout for locks for this txn.  }
    expire : db_timeout_t;          { Time this txn expires.  }
    txn_list : pointer;             { Undo information for parent.  }
    {
      !!!
      Explicit representations of structures from queue.h.
      TAILQ_ENTRY(Tdb_txn) links;
      TAILQ_ENTRY(TDb_txn) xalinks;
    }
    links : record                  { Links transactions off manager.  }
         tqe_next : PDB_TXN;
         tqe_prev : ^PDB_TXN;
      end;
    xalinks : record                { Links active XA transactions.  }
         tqe_next : PDB_TXN;
         tqe_prev : ^PDB_TXN;
      end;
    {
      !!!
      Explicit representations of structures from queue.h.
      TAILQ_HEAD(__events, __txn_event) events;
    }
    events : record
         tqh_first : ^__txn_event;
         tqh_last : ^P__txn_event;
      end;
    logs : record                     { Links deferred events.  }
         stqh_first : P__txn_logrec;
         stqh_last : ^P__txn_logrec;
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
    abort : function (_para1:PDB_TXN):longint;cdecl;
    commit : function (_para1:PDB_TXN; _para2:u_int32_t):longint;cdecl;
    discard : function (_para1:PDB_TXN; _para2:u_int32_t):longint; cdecl;
    id : function (_para1:PDB_TXN):u_int32_t; cdecl;
    prepare : function (_para1:PDB_TXN;var _para2:u_int8_t):longint; cdecl;
    set_timeout : function (_para1:PDB_TXN; _para2:db_timeout_t; _para3:u_int32_t):longint; cdecl;
    flags : u_int32_t;
  end;

  {
     Structure used for two phase commit interface.  Berkeley DB support for two
     phase commit is compatible with the X/open XA interface.
    
     The XA #define XIDDATASIZE defines the size of a global transaction ID.  We
     have our own version here (for name space reasons) which must have the same
     value.
    }
     TDB_PREPLIST = record
          txn : PDB_TXN;
          gid : array[0..(DB_XIDDATASIZE)-1] of u_int8_t;
       end;

  { Transaction statistics structure.  }
  TDB_TXN_ACTIVE = record
    txnid : u_int32_t;                                { Transaction ID  }
    parentid : u_int32_t;                             { Transaction ID of parent  }
    lsn : TDB_LSN;                                    { LSN when transaction began  }
    xa_status : u_int32_t;                            { XA status  }
    xid : array[0..(DB_XIDDATASIZE)-1] of u_int8_t;   { XA global transaction ID  }
  end;

  TDB_TXN_STAT = record
     st_last_ckp : TDB_LSN;          { lsn of the last checkpoint  }
     st_time_ckp : time_t;           { time of last checkpoint  }
     st_last_txnid : u_int32_t;      { last transaction id given out  }
     st_maxtxns : u_int32_t;         { maximum txns possible  }
     st_naborts : u_int32_t;         { number of aborted transactions  }
     st_nbegins : u_int32_t;         { number of begun transactions  }
     st_ncommits : u_int32_t;        { number of committed transactions  }
     st_nactive : u_int32_t;         { number of active transactions  }
     st_nrestores : u_int32_t;       { number of restored transactions
                                       after recovery.  }
     st_maxnactive : u_int32_t;      { maximum active transactions  }
     st_txnarray : PDB_TXN_ACTIVE;   { array of active transactions  }
     st_region_wait : u_int32_t;     { Region lock granted after wait.  }
     st_region_nowait : u_int32_t;   { Region lock granted without wait.  }
     st_regsize : u_int32_t;         { Region size.  }
  end;

  {                                                      
     Replication.
                                                          }
  { Special, out-of-band environment IDs.  }

  { Replication statistics.  }
  { !!!
  	   Many replication statistics fields cannot be protected by a mutex
  	   without an unacceptable performance penalty, since most message
  	   processing is done without the need to hold a region-wide lock.
  	   Fields whose comments end with a '+' may be updated without holding
  	   the replication or log mutexes (as appropriate), and thus may be
  	   off somewhat (or, on unreasonable architectures under unlucky
  	   circumstances, garbaged).
  	  }

  TDB_REP_STAT = record
    st_status : u_int32_t;                 { Current replication status.  }
    st_next_lsn : TDB_LSN;                 { Next LSN to use or expect.  }
    st_waiting_lsn : TDB_LSN;              { LSN we're awaiting, if any.  }
    st_dupmasters : u_int32_t;             { # of times a duplicate master  condition was detected.+  }
    st_env_id : longint;                   { Current environment ID.  }
    st_env_priority : longint;             { Current environment priority.  }
    st_gen : u_int32_t;                    { Current generation number.  }
    st_in_recovery : u_int32_t;            { This site is in client sync-up.  }
    st_log_duplicated : u_int32_t;         { Log records received multiply.+  }
    st_log_queued : u_int32_t;             { Log records currently queued.+  }
    st_log_queued_max : u_int32_t;         { Max. log records queued at once.+  }
    st_log_queued_total : u_int32_t;       { Total # of log recs. ever queued.+  }
    st_log_records : u_int32_t;            { Log records received and put.+  }
    st_log_requested : u_int32_t;          { Log recs. missed and requested.+  }
    st_master : longint;                   { Env. ID of the current master.  }
    st_master_changes : u_int32_t;         { # of times we've switched masters.  }
    st_msgs_badgen : u_int32_t;            { Messages with a bad generation #.+  }
    st_msgs_processed : u_int32_t;         { Messages received and processed.+  }
    st_msgs_recover : u_int32_t;           { Messages ignored because this site was a client in recovery.+  }
    st_msgs_send_failures : u_int32_t;     { # of failed message sends.+  }
    st_msgs_sent : u_int32_t;              { # of successful message sends.+  }
    st_newsites : u_int32_t;               { # of NEWSITE msgs. received.+  }
    st_nsites : longint;                   { Current number of sites we will  assume during elections.  }
    st_nthrottles : u_int32_t;             { # of times we were throttled.  }
    st_outdated : u_int32_t;               { # of times we detected and returned an OUTDATED condition.+  }
    st_txns_applied : u_int32_t;           { # of transactions applied.+  }
    { Elections generally.  }
    st_elections : u_int32_t;              { # of elections held.+  }
    st_elections_won : u_int32_t;          { # of elections won by this site.+  }
    { Statistics about an in-progress election.  }
    st_election_cur_winner : longint;      { Current front-runner.  }
    st_election_gen : u_int32_t;           { Election generation number.  }
    st_election_lsn : TDB_LSN;             { Max. LSN of current winner.  }
    st_election_nsites : longint;          { # of "registered voters".  }
    st_election_priority : longint;        { Current election priority.  }
    st_election_status : longint;          { Current election status.  }
    st_election_tiebreaker : longint;      { Election tiebreaker value.  }
    st_election_votes : longint;           { Votes received in this round.  }
  end;

  {
     Access methods.
                                                          }
  { Figure it out on open.  }

  { File has been renamed.  }

{ Database handle.  }
{
	   Public: owned by the application.
	                                                        }
{ Database logical page size.  }
{ Callbacks.  }
  { Application-private handle.  }
  {
  	   Private: owned by DB.
  	                                                        }
  { Backing environment.  }
  { DB access method type.  }
  { Backing buffer pool.  }
  { Synchronization for free threading  }
  { File/database passed to DB->open.  }
  { Flags passed to DB->open.  }
  { File's unique ID for locking.  }
  { File's unique ID for curs. adj.  }
  { File's naming info for logging.  }
  { Meta page number  }
  { Locker id for handle locking.  }
  { Current handle lock holder.  }
  { Locker id for DB->associate call.  }
  { Lock held on this handle.  }
  { RPC: remote client id.  }
  { Handle timestamp for replication.  }
  {
  	   Returned data memory for DB->get() and friends.
  	  }
  { Secondary key.  }
  { [Primary] key.  }
  { Data.  }
  {
  	   !!!
  	   Some applications use DB but implement their own locking outside of
  	   DB.  If they're using fcntl(2) locking on the underlying database
  	   file, and we open and close a file descriptor for that file, we will
  	   discard their locks.  The DB_FCNTL_LOCKING flag to DB->open is an
  	   undocumented interface to support this usage which leaves any file
  	   descriptors we open until DB->close.  This will only work with the
  	   DB->open interface and simple caches, e.g., creating a transaction
  	   thread may open/close file descriptors this flag doesn't protect.
  	   Locking with fcntl(2) on a file that you don't own is a very, very
  	   unsafe thing to do.  'Nuff said.
  	  }
  { Saved file handle.  }
  {
  	   Linked list of DBP's, linked from the DB_ENV, used to keep track
  	   of all open db handles for cursor adjustment.
  	  
  	   !!!
  	   Explicit representations of structures from queue.h.
  	   LIST_ENTRY(Tdb) dblistlinks;
  	  }
  {
  	   Cursor queues.
  	  
  	   !!!
  	   Explicit representations of structures from queue.h.
  	   TAILQ_HEAD(__cq_fq, __dbc) free_queue;
  	   TAILQ_HEAD(__cq_aq, __dbc) active_queue;
  	   TAILQ_HEAD(__cq_jq, __dbc) join_queue;
  	  }
  {
  	   Secondary index support.
  	  
  	   Linked list of secondary indices -- set in the primary.
  	  
  	   !!!
  	   Explicit representations of structures from queue.h.
  	   LIST_HEAD(s_secondaries, __db);
  	  }
  {
  	   List entries for secondaries, and reference count of how
  	   many threads are updating this secondary (see __db_c_put).
  	  
  	   !!!
  	   Note that these are synchronized by the primary's mutex, but
  	   filled in in the secondaries.
  	  
  	   !!!
  	   Explicit representations of structures from queue.h.
  	   LIST_ENTRY(__db) s_links;
  	  }
  { Secondary callback and free functions -- set in the secondary.  }
  { Reference to primary -- set in the secondary.  }
  { API-private structure: used by DB 1.85, C++, Java, Perl and Tcl  }
  { Subsystem-private structure.  }
  { Btree/Recno access method.  }
  { Hash access method.  }
  { Queue access method.  }
  { XA.  }
  { Methods.  }
  {
  	   Never called; these are a place to save function pointers
  	   so that we can undo an associate.
  	  }
  { Legal AM choices.  }
  { Flags at  open, for refresh.  }


  TSysGetMem = function (Size: Integer): Pointer; cdecl;
  TSysFreeMem = function (P: Pointer): Integer; cdecl;
  TSysReallocMem = function (P: Pointer; Size: Integer): Pointer; cdecl;

  TDBTYPE = (DB_BTREE = 1,DB_HASH = 2,DB_RECNO = 3, DB_QUEUE = 4,DB_UNKNOWN = 5);

  TAssociateFunc = function (param1 : PDB; const Param2 : PDBT; const param3 : PDBT ; Param4 : PDBT ):longint;

  TDB = record
	  pgsize                 : u_int32_t;		(* Database logical page size. *)

	  db_append_recno        : function (_para1:PDB; _para2:PDBT; _para3:db_recno_t):longint; cdecl;
    db_feedback            : procedure (_para1:PDB; _para2:longint; _para3:longint); cdecl;
    dup_compare            : function (_para1:PDB; _para2:PDBT; _para3:PDBT):longint; cdecl;

    app_private            : pointer;

    dbenv                  : PDB_ENV;
    _type                  : TDBTYPE;
    mpf                    : PDB_MPOOLFILE;
    mutexp                 : PDB_MUTEX;
    fname                  : Pchar;
    dname                  : Pchar;
    open_flags             : u_int32_t;
    fileid                 : array[0..(DB_FILE_ID_LEN)-1] of u_int8_t;
    adj_fileid             : u_int32_t;
    log_filename           : Pchar; // PFNAME;
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
                               le_next :PDB;
                               le_prev : ^PDB;
                             end;
    free_queue             : record
                               tqh_first : PDBC;
                               tqh_last : ^PDBC;
                             end;
    active_queue           : record
                               tqh_first : PDBC;
                               tqh_last : ^PDBC;
                             end;
    join_queue             : record
                               tqh_first : PDBC;
                               tqh_last : ^PDBC;
                             end;
    s_secondaries          : record
                               lh_first : PDB;
                             end;
    s_links                : record
                               le_next : PDB;
                               le_prev : ^PDB;
                             end;
    s_refcnt               : u_int32_t;
    s_callback             : function (_para1:PDB; _para2:PDBT; _para3:PDBT; _para4:PDBT):longint; cdecl;
    s_primary              : PDB;
    api_internal           : pointer;
    bt_internal            : pointer;
    h_internal             : pointer;
    q_internal             : pointer;
    xa_internal            : pointer;

    associate              : function (_para1:PDB; _para2:PDB_TXN; _para3:PDB; _para4: TAssociateFunc; _para5:u_int32_t):longint; cdecl;
    close                  : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;
    cursor                 : function (_para1:PDB; _para2:PDB_TXN; _para3: PPDBC; _para4:u_int32_t):longint; cdecl;
    del                    : function (_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:u_int32_t):longint; cdecl;
    err                    : procedure(_para1:PDB; _para2:longint; _para3:Pchar; args:array of const); cdecl;
    errx                   : procedure(_para1:PDB; _para2:Pchar; args:array of const); cdecl;
    fd                     : function (_para1:PDB; _para2:Plongint):longint; cdecl;
    get                    : function (_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5 :u_int32_t):longint; cdecl;
    pget                   : function (_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:PDBT; _para6:u_int32_t):longint; cdecl;
    get_byteswapped        : function (_para1:PDB; _para2:Plongint):longint; cdecl;
    get_cachesize          : function (_para1:PDB; var _para2: u_int32_t; var _para3: u_int32_t; var _para4:longint):longint; cdecl;
    get_dbname             : function (_para1:PDB; _para2:PPchar; _para3:PPchar):longint; cdecl;
    get_encrypt_flags      : function (_para1:PDB; var _para2:u_int32_t):longint; cdecl;
    get_env                : function (_para1:PDB; _para2:PPDB_ENV):longint; cdecl;
    get_errfile            : procedure(_para1:PDB; _para2:PPFILE ); cdecl;
    get_errpfx             : procedure(_para1:PDB; _para2:PPchar); cdecl;
    get_flags              : function (_para1:PDB; var _para2:u_int32_t):longint; cdecl;
    get_lorder             : function (_para1:PDB; _para2:Plongint):longint; cdecl;
    get_open_flags         : function (_para1:PDB; var _para2:u_int32_t):longint; cdecl;
    get_pagesize           : function (_para1:PDB; var _para2:u_int32_t):longint; cdecl;
    get_transactional      : function (_para1:PDB; _para2:Plongint):longint; cdecl;
    get_type               : function (_para1:PDB; var _para2:TDBTYPE):longint; cdecl;
    join                   : function (_para1:PDB; _para2:PPDBC; _para3:PPDBC; _para4:u_int32_t):longint; cdecl;
    key_range              : function (_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDB_KEY_RANGE; _para5:u_int32_t):longint; cdecl;
    open                   : function (_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:TDBTYPE; _para6:u_int32_t; _para7:longint):longint; cdecl;
    put                    : function (_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint; cdecl;
    remove                 : function (_para1:PDB; _para2:Pchar; _para3:Pchar; _para4:u_int32_t):longint; cdecl;
    rename                 : function (_para1:PDB; _para2:Pchar; _para3:Pchar; _para4:Pchar; _para5:u_int32_t):longint; cdecl;
    truncate               : function (_para1:PDB; _para2:PDB_TXN; var _para3: u_int32_t; _para4:u_int32_t):longint; cdecl;
    set_append_recno       : function (_para1:PDB; _para2: Pointer):longint; cdecl; //para2 : function (_para1:PDB; _para2:PDBT; _para3:db_recno_t):longint
    set_alloc              : function (_para1:PDB; _para2: TSysGetMem; _para3: TSysReallocMem; _para4:TSysFreeMem):longint; cdecl; // Pprocedure (_para1:size_t)
    set_cachesize          : function (_para1:PDB; _para2:u_int32_t; _para3:u_int32_t; _para4:longint):longint; cdecl;
    set_dup_compare        : function (_para1:PDB; _para2: Pointer):longint; //function (_para1:PDB; _para2:PDBT; _para3:PDBT):longint
    set_encrypt            : function (_para1:PDB; _para2:Pchar; _para3:u_int32_t):longint; cdecl;
    set_errcall            : procedure(_para1:PDB; _para2: Pointer); cdecl; //procedure (_para1:Pchar; _para2:Pchar)
    set_errfile            : procedure(_para1:PDB; _para2:PFILE); cdecl;
    set_errpfx             : procedure(_para1:PDB; _para2:Pchar); cdecl;
    set_feedback           : function (_para1:PDB; _para2: Pointer):longint;  cdecl;//procedure (_para1:PDB; _para2:longint; _para3:longint)
    set_flags              : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;
    set_lorder             : function (_para1:PDB; _para2:longint):longint; cdecl;
    set_pagesize           : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;
    set_paniccall          : function (_para1:PDB; _para2: pointer):longint; cdecl; //procedure (_para1:PDB_ENV; _para2:longint)
    stat                   : function (_para1:PDB; _para2:pointer; _para3:u_int32_t):longint; cdecl;
    sync                   : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;
    upgrade                : function (_para1:PDB; _para2:Pchar; _para3:u_int32_t):longint; cdecl;
    verify                 : function (_para1:PDB; _para2:Pchar; _para3:Pchar; _para4:PFILE; _para5:u_int32_t):longint; cdecl;
    get_bt_minkey          : function (_para1:PDB; var _para2:u_int32_t):longint; cdecl;
    set_bt_compare         : function (_para1:PDB; _para2: pointer):longint; cdecl; //function (_para1:PDB; _para2:PDBT; _para3:PDBT):longint
    set_bt_maxkey          : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;
    set_bt_minkey          : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;
    set_bt_prefix          : function (_para1:PDB; _para2: pointer):longint; cdecl; //function (_para1:PDB; _para2:PDBT; _para3:PDBT):size_t
    get_h_ffactor          : function (_para1:PDB; var _para2:u_int32_t):longint; cdecl;
    get_h_nelem            : function (_para1:PDB; var _para2:u_int32_t):longint; cdecl;
    set_h_ffactor          : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;
    set_h_hash             : function (_para1:PDB; _para2:pointer):longint; cdecl; //function (_para1:PDB; _para2:pointer; _para3:u_int32_t):u_int32_t
    set_h_nelem            : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;
    get_re_delim           : function (_para1:PDB; _para2:Plongint):longint; cdecl;
    get_re_len             : function (_para1:PDB; var _para2:u_int32_t):longint; cdecl;
    get_re_pad             : function (_para1:PDB; _para2:Plongint):longint; cdecl;
    get_re_source          : function (_para1:PDB; _para2:PPchar):longint; cdecl;
    set_re_delim           : function (_para1:PDB; _para2:longint):longint; cdecl;
    set_re_len             : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;
    set_re_pad             : function (_para1:PDB; _para2:longint):longint; cdecl;
    set_re_source          : function (_para1:PDB; _para2:Pchar):longint; cdecl;
    get_q_extentsize       : function (_para1:PDB; var _para2:u_int32_t):longint; cdecl;
    set_q_extentsize       : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;
    db_am_remove           : function (_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:PDB_LSN):longint; cdecl;
    db_am_rename           : function (_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:Pchar):longint; cdecl;
    stored_get             : function (_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint; cdecl;
    stored_close           : function (_para1:PDB; _para2:u_int32_t):longint; cdecl;

    am_ok                  : u_int32_t;
    orig_flags             : u_int32_t;
    flags                  : u_int32_t;
  end;

  {
     Access method cursors.
                                                          }
  { Cursor in use.  }

  {
  	   The DBT  's below are used by the cursor routines to return
  	   data to the user when DBT flags indicate that DB should manage
  	   the returned memory.  They point at a DBT containing the buffer
  	   and length that will be used, and "belonging" to the handle that
  	   should "own" this memory.  This may be a "my_ " field of this
  	   cursor--the default--or it may be the corresponding field of
  	   another cursor, a DB handle, a join cursor, etc.  In general, it
  	   will be whatever handle the user originally used for the current
  	   DB interface call.
  	  }

  TDBC = record
    dbp : PDB;                    { Related DB access method.  }
    txn : PDB_TXN;                { Associated transaction.  }
    {
      Active/free cursor queues.

      !!!
      Explicit representations of structures from queue.h.
      TAILQ_ENTRY(__dbc) links;
    }
    links : record
         tqe_next : PDBC;
         tqe_prev : ^PDBC;
      end;
    rskey : PDBT;                 { Returned secondary key.  }
    rkey : PDBT;                  { Returned [primary] key.  }
    rdata : PDBT;                 { Returned data.  }
    my_rskey : TDBT;              { Space for returned secondary key.  }
    my_rkey : TDBT;               { Space for returned [primary] key.  }
    my_rdata : TDBT;              { Space for returned data.  }
    lid : u_int32_t;              { Default process' locker id.  }
    locker : u_int32_t;           { Locker for this operation.  }
    lock_dbt : TDBT;              { DBT referencing lock.  }
    lock : TDB_LOCK_ILOCK;        { Object to be locked.  }
    mylock : TDB_LOCK;            { CDB lock held on this cursor.  }
    cl_id : longint;              { Remote client id.  }
    dbtype : TDBTYPE;             { Cursor type.  }
    internal : PDBC_INTERNAL;
    c_close : function (_para1:PDBC):longint; cdecl;
    c_count : function (_para1:PDBC; var _para2:db_recno_t; _para3:u_int32_t):longint; cdecl;
    c_del : function (_para1:PDBC; _para2:u_int32_t):longint; cdecl;
    c_dup : function (_para1:PDBC; _para2:PPDBC; _para3:u_int32_t):longint; cdecl;
    c_get : function (_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t):longint; cdecl;
    c_pget : function (_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint; cdecl;
    c_put : function (_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t):longint; cdecl;
    c_am_bulk : function (_para1:PDBC; _para2:PDBT; _para3:u_int32_t):longint; cdecl;
    c_am_close : function (_para1:PDBC; _para2:db_pgno_t; _para3:Plongint):longint; cdecl;
    c_am_del : function (_para1:PDBC):longint; cdecl;
    c_am_destroy : function (_para1:PDBC):longint; cdecl;
    c_am_get : function (_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t; var _para5:db_pgno_t):longint; cdecl;
    c_am_put : function (_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t; var _para5:db_pgno_t):longint; cdecl;
    c_am_writelock : function (_para1:PDBC):longint; cdecl;
    flags : u_int32_t;
  end;

  { Key range statistics structure  }
  TDB_KEY_RANGE = record
    less : double;
    equal : double;
    greater : double;
  end;

  { Btree/Recno statistics structure.  }
  TDB_BTREE_STAT = record
    bt_magic : u_int32_t;            { Magic number.  }
    bt_version : u_int32_t;          { Version number.  }
    bt_metaflags : u_int32_t;        { Metadata flags.  }
    bt_nkeys : u_int32_t;            { Number of unique keys.  }
    bt_ndata : u_int32_t;            { Number of data items.  }
    bt_pagesize : u_int32_t;         { Page size.  }
    bt_maxkey : u_int32_t;           { Maxkey value.  }
    bt_minkey : u_int32_t;           { Minkey value.  }
    bt_re_len : u_int32_t;           { Fixed-length record length.  }
    bt_re_pad : u_int32_t;           { Fixed-length record pad.  }
    bt_levels : u_int32_t;           { Tree levels.  }
    bt_int_pg : u_int32_t;           { Internal pages.  }
    bt_leaf_pg : u_int32_t;          { Leaf pages.  }
    bt_dup_pg : u_int32_t;           { Duplicate pages.  }
    bt_over_pg : u_int32_t;          { Overflow pages.  }
    bt_free : u_int32_t;             { Pages on the free list.  }
    bt_int_pgfree : u_int32_t;       { Bytes free in internal pages.  }
    bt_leaf_pgfree : u_int32_t;      { Bytes free in leaf pages.  }
    bt_dup_pgfree : u_int32_t;       { Bytes free in duplicate pages.  }
    bt_over_pgfree : u_int32_t;      { Bytes free in overflow pages.  }
  end;

  { Hash statistics structure.  }
  TDB_HASH_STAT = record
    hash_magic : u_int32_t;         { Magic number.  }
    hash_version : u_int32_t;       { Version number.  }
    hash_metaflags : u_int32_t;     { Metadata flags.  }
    hash_nkeys : u_int32_t;         { Number of unique keys.  }
    hash_ndata : u_int32_t;         { Number of data items.  }
    hash_pagesize : u_int32_t;      { Page size.  }
    hash_ffactor : u_int32_t;       { Fill factor specified at create.  }
    hash_buckets : u_int32_t;       { Number of hash buckets.  }
    hash_free : u_int32_t;          { Pages on the free list.  }
    hash_bfree : u_int32_t;         { Bytes free on bucket pages.  }
    hash_bigpages : u_int32_t;      { Number of big key/data pages.  }
    hash_big_bfree : u_int32_t;     { Bytes free on big item pages.  }
    hash_overflows : u_int32_t;     { Number of overflow pages.  }
    hash_ovfl_free : u_int32_t;     { Bytes free on ovfl pages.  }
    hash_dup : u_int32_t;           { Number of dup pages.  }
    hash_dup_free : u_int32_t;      { Bytes free on duplicate pages.  }
  end;

  { Queue statistics structure.  }
  TDB_QUEUE_STAT = record
    qs_magic : u_int32_t;         { Magic number.  }
    qs_version : u_int32_t;       { Version number.  }
    qs_metaflags : u_int32_t;     { Metadata flags.  }
    qs_nkeys : u_int32_t;         { Number of unique keys.  }
    qs_ndata : u_int32_t;         { Number of data items.  }
    qs_pagesize : u_int32_t;      { Page size.  }
    qs_extentsize : u_int32_t;    { Pages per extent.  }
    qs_pages : u_int32_t;         { Data pages.  }
    qs_re_len : u_int32_t;        { Fixed-length record length.  }
    qs_re_pad : u_int32_t;        { Fixed-length record pad.  }
    qs_pgfree : u_int32_t;        { Bytes free in data pages.  }
    qs_first_recno : u_int32_t;   { First not deleted record.  }
    qs_cur_recno : u_int32_t;     { Next available record number.  }
  end;

  {                                                      
     Environment.
                                                          }
  { Environment magic number.  }

  { Database Environment handle.  }
  {
  	   Public: owned by the application.
  	                                                        }
  { Error message file stream.  }
  { Error message prefix.  }
  { Callbacks.  }
  { App-specified alloc functions.  }
  {
  	   Currently, the verbose list is a bit field with room for 32
  	   entries.  There's no reason that it needs to be limited, if
  	   there are ever more than 32 entries, convert to a bit array.
  	  }
  { Verbose output.  }
  { Application-private handle.  }
  { User-specified recovery dispatch.  }
  { Locking.  }
  { Two dimensional conflict matrix.  }
  { Number of lock modes in table.  }
  { Maximum number of locks.  }
  { Maximum number of lockers.  }
  { Maximum number of locked objects.  }
  { Deadlock detect on all conflicts.  }
  { Lock timeout period.  }
  { Logging.  }
  { Buffer size.  }
  { Log file size.  }
  { Region size.  }
  { Memory pool.  }
  { Cachesize: GB.  }
  { Cachesize: Bytes.  }
  { DEPRECATED: Cachesize: bytes.  }
  { Number of cache regions.  }
  { Maximum file size for mmap.  }
  { Maximum buffers to write.  }
  { Sleep after writing max buffers.  }
  { Replication  }
  { environment id.  }
  { Send function.  }
  { Transactions.  }
  { Maximum number of transactions.  }
  { Recover to specific timestamp.  }
  { Timeout for transactions.  }
  {                                                      
  	   Private: owned by DB.
  	                                                        }
  { User files, paths.  }
  { Database home.  }
  { Database log file directory.  }
  { Database tmp file directory.  }
  { Database data file directories.  }
  { Database data file slots.  }
  { Next Database data file slot.  }
  { Default open permissions.  }
  { Flags passed to DB_ENV->open.  }
  { REGINFO structure reference.  }
  { fcntl(2) locking file handle.  }
  { Dispatch table for recover funcs.  }
  { Slots in the dispatch table.  }
  { RPC: remote client handle.  }
  { RPC: remote client env id.  }
  { DB reference count.  }
  { shmget(2) key.  }
  { test-and-set spins.  }
  {
  	   List of open DB handles for this DB_ENV, used for cursor
  	   adjustment.  Must be protected for multi-threaded support.
  	  
  	   !!!
  	   As this structure is allocated in per-process memory, the
  	   mutex may need to be stored elsewhere on architectures unable
  	   to support mutexes in heap memory, e.g. HP/UX 9.
  	  
  	   !!!
  	   Explicit representation of structure in queue.h.
  	   LIST_HEAD(dblist, __db);
  	  }
  { Mutex.  }
  {
  	   XA support.
  	  
  	   !!!
  	   Explicit representations of structures from queue.h.
  	   TAILQ_ENTRY(DB_ENV) links;
  	   TAILQ_HEAD(xa_txn, __db_txn);
  	  }
  { XA Active Transactions.  }
  { XA Resource Manager ID.  }
  { API-private structure.  }
  { C++, Perl API private  }
  { Java API private  }
  { Cryptography support.  }
  { Primary handle.  }
  { Mersenne Twister mutex.  }
  { Mersenne Twister index.  }
  { Mersenne Twister state vector.  }
  { DB_ENV Methods.  }
  { Log handle and methods.  }
  { Lock handle and methods.  }
  { Mpool handle and methods.  }
  { Replication handle and methods.  }
  { Txn handle and methods.  }
  { Abort value for testing.  }
  { Copy value for testing.  }


  TDB_ENV = record
    db_errfile : ^FILE;
    db_errpfx : Pchar;
    db_errcall : procedure (_para1:Pchar; _para2:Pchar); cdecl;
    db_feedback : procedure (_para1:PDB_ENV; _para2:longint; _para3:longint); cdecl;
    db_paniccall : procedure (_para1:PDB_ENV; _para2:longint); cdecl;
    db_malloc : function (_para1:size_t):pointer; cdecl;
    db_realloc : function (_para1:pointer; _para2:size_t):pointer; cdecl;
    db_free : procedure (_para1:pointer); cdecl;
    verbose : u_int32_t;
    app_private : pointer;
    app_dispatch : function (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops):longint; cdecl;
    lk_conflicts : ^u_int8_t;
    lk_modes : u_int32_t;
    lk_max : u_int32_t;
    lk_max_lockers : u_int32_t;
    lk_max_objects : u_int32_t;
    lk_detect : u_int32_t;
    lk_timeout : db_timeout_t;
    lg_bsize : u_int32_t;
    lg_size : u_int32_t;
    lg_regionmax : u_int32_t;
    mp_gbytes : u_int32_t;
    mp_bytes : u_int32_t;
    mp_size : size_t;
    mp_ncache : longint;
    mp_mmapsize : size_t;
    mp_maxwrite : longint;
    mp_maxwrite_sleep : longint;
    rep_eid : longint;
    rep_send : function (_para1:PDB_ENV; _para2:PDBT; _para3:PDBT; _para4:PDB_LSN; _para5:longint; 
                 _para6:u_int32_t):longint;  cdecl;
    tx_max : u_int32_t;
    tx_timestamp : time_t;
    tx_timeout : db_timeout_t;
    db_home : Pchar;
    db_log_dir : Pchar;
    db_tmp_dir : Pchar;
    db_data_dir : ^Pchar;
    data_cnt : longint;
    data_next : longint;
    db_mode : longint;
    open_flags : u_int32_t;
    reginfo : pointer;
    lockfhp : PDB_FH;
    recover_dtab : function (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; cdecl;
    recover_dtab_size : size_t;
    cl_handle : pointer;
    cl_id : longint;
    db_ref : longint;
    shm_key : longint;
    tas_spins : u_int32_t;
    dblist_mutexp : PDB_MUTEX;
    dblist : record
         lh_first : PDB;
      end;
    links : record
         tqe_next : PDB_ENV;
         tqe_prev : ^PDB_ENV;
      end;
    xa_txn : record
         tqh_first : PDB_TXN;
         tqh_last : ^PDB_TXN;
      end;
    xa_rmid : longint;
    api1_internal : pointer;
    api2_internal : pointer;
    passwd : Pchar;
    passwd_len : size_t;
    crypto_handle : pointer;
    mt_mutexp : PDB_MUTEX;
    mti : longint;
    mt : ^u_long;
    close              : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    dbremove           : function (_para1:PDB_ENV; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:u_int32_t):longint; cdecl;
    dbrename           : function (_para1:PDB_ENV; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:Pchar;
                                  _para6:u_int32_t):longint; cdecl;
    err                           : procedure (_para1:PDB_ENV; _para2:longint; _para3:Pchar; args:array of const);cdecl;
    errx                          : procedure (_para1:PDB_ENV; _para2:Pchar; args:array of const);cdecl;
    get_home                      : function (_para1:PDB_ENV; _para2:PPchar):longint; cdecl;
    get_open_flags                : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    open                          : function (_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t; _para4:longint):longint; cdecl;
    remove                        : function (_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t):longint; cdecl;
    set_alloc                     : function (_para1:PDB_ENV; _para2: pointer; _para3: pointer; _para4:pointer):longint; cdecl;
    set_app_dispatch              : function (_para1:PDB_ENV; _para2: pointer):longint; cdecl;
    get_data_dirs                 : function (_para1:PDB_ENV; var _para2:PPchar):longint; cdecl;
    set_data_dir                  : function (_para1:PDB_ENV; _para2:Pchar):longint; cdecl;
    get_encrypt_flags             : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_encrypt                   : function (_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t):longint; cdecl;
    set_errcall                   : procedure (_para1:PDB_ENV; _para2:Pointer); cdecl;
    get_errfile                   : procedure (_para1:PDB_ENV; _para2:PPFILE); cdecl;
    set_errfile                   : procedure (_para1:PDB_ENV; _para2:PFILE); cdecl;
    get_errpfx                    : procedure (_para1:PDB_ENV; _para2:PPchar); cdecl;
    set_errpfx                    : procedure (_para1:PDB_ENV; _para2:Pchar); cdecl;
    set_feedback                  : function (_para1:PDB_ENV; _para2:Pointer):longint; cdecl;
    get_flags                     : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_flags                     : function (_para1:PDB_ENV; _para2:u_int32_t; _para3:longint):longint; cdecl;
    set_paniccall                 : function (_para1:PDB_ENV; _para2:Pointer):longint; cdecl;
    set_rpc_server                : function (_para1:PDB_ENV; _para2:pointer; _para3:Pchar; _para4:longint; _para5:longint;
                                                 _para6:u_int32_t):longint; cdecl;
    get_shm_key                   : function (_para1:PDB_ENV; _para2:Plongint):longint; cdecl;
    set_shm_key                   : function (_para1:PDB_ENV; _para2:longint):longint; cdecl;
    get_tas_spins                 : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_tas_spins                 : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_tmp_dir                   : function (_para1:PDB_ENV; _para2:PPchar):longint; cdecl;
    set_tmp_dir                   : function (_para1:PDB_ENV; _para2:Pchar):longint; cdecl;
    get_verbose                   : function (_para1:PDB_ENV; _para2:u_int32_t; _para3:Plongint):longint; cdecl;
    set_verbose                   : function (_para1:PDB_ENV; _para2:u_int32_t; _para3:longint):longint; cdecl;
    lg_handle : pointer;
    get_lg_bsize                  : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lg_bsize                  : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_lg_dir                    : function (_para1:PDB_ENV; _para2:PPchar):longint; cdecl;
    set_lg_dir                    : function (_para1:PDB_ENV; _para2:Pchar):longint; cdecl;
    get_lg_max                    : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lg_max                    : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_lg_regionmax              : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lg_regionmax              : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    log_archive                   : function (_para1:PDB_ENV; _array:PPchar; _para3:u_int32_t):longint; cdecl;
    log_cursor                    : function (_para1:PDB_ENV; var _para2:PDB_LOGC; _para3:u_int32_t):longint;
    log_file                      : function (_para1:PDB_ENV; _para2:PDB_LSN; _para3:Pchar; _para4:size_t):longint; cdecl;
    log_flush                     : function (_para1:PDB_ENV; _para2:PDB_LSN):longint; cdecl;
    log_put                       : function (_para1:PDB_ENV; _para2:PDB_LSN; _para3:PDBT; _para4:u_int32_t):longint; cdecl;
    log_stat                      : function (_para1:PDB_ENV; var _para2:PDB_LOG_STAT; _para3:u_int32_t):longint; cdecl;
    lk_handle : pointer;
    get_lk_conflicts              : function (_para1:PDB_ENV; var _para2:u_int8_t; var _para3:longint):longint; cdecl;
    set_lk_conflicts              : function (_para1:PDB_ENV; var _para2:u_int8_t; _para3:longint):longint; cdecl;
    get_lk_detect                 : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lk_detect                 : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    set_lk_max                    : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_lk_max_locks              : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lk_max_locks              : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_lk_max_lockers            : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lk_max_lockers            : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_lk_max_objects            : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_lk_max_objects            : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    lock_detect                   : function (_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:Plongint):longint; cdecl;
    lock_dump_region              : function (_para1:PDB_ENV; _para2:Pchar; _para3:PFILE):longint; cdecl;
    lock_get                      : function (_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:PDBT; _para5:db_lockmode_t;
                                      _para6:PDB_LOCK):longint; cdecl;
    lock_put                      : function (_para1:PDB_ENV; _para2:PDB_LOCK):longint; cdecl;
    lock_id                       : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    lock_id_free                  : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    lock_stat                     : function (_para1:PDB_ENV; var _para2:PDB_LOCK_STAT; _para3:u_int32_t):longint; cdecl;
    lock_vec                      : function (_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:PDB_LOCKREQ; _para5:longint;
                                        var _para6:PDB_LOCKREQ):longint; cdecl;
    mp_handle : pointer;
    get_cachesize                 : function (_para1:PDB_ENV; var _para2:u_int32_t; var _para3:u_int32_t; var _para4:longint):longint; cdecl;
    set_cachesize                 : function (_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:longint):longint; cdecl;
    get_mp_mmapsize               : function (_para1:PDB_ENV; var _para2:size_t):longint; cdecl;
    set_mp_mmapsize               : function (_para1:PDB_ENV; _para2:size_t):longint; cdecl;
    get_mp_maxwrite               : function (_para1:PDB_ENV; var _para2:longint; _para3:Plongint):longint; cdecl;
    set_mp_maxwrite               : function (_para1:PDB_ENV; _para2:longint; _para3:longint):longint; cdecl;
    memp_dump_region              : function (_para1:PDB_ENV; _para2:Pchar; _para3:PFILE):longint; cdecl;
    memp_fcreate                  : function (_para1:PDB_ENV; var _para2:PDB_MPOOLFILE; _para3:u_int32_t):longint; cdecl;
    memp_register                 : function (_para1:PDB_ENV; _para2:longint; _para3:Pointer; _para4:Pointer):longint; cdecl;
    memp_stat                     : function (_para1:PDB_ENV; var _para2:PDB_MPOOL_STAT; var _para3:PDB_MPOOL_FSTAT; _para4:u_int32_t):longint; cdecl;
    memp_sync                     : function (_para1:PDB_ENV; _para2:PDB_LSN):longint; cdecl;
    memp_trickle                  : function (_para1:PDB_ENV; _para2:longint; _para3:Plongint):longint; cdecl;
    rep_handle : pointer;
    rep_elect                     : function (_para1:PDB_ENV; _para2:longint; _para3:longint; _para4:u_int32_t; _para5:Plongint):longint; cdecl;
    rep_flush                     : function (_para1:PDB_ENV):longint; cdecl;
    rep_process_message           : function (_para1:PDB_ENV; _para2:PDBT; _para3:PDBT; _para4:Plongint; _para5:PDB_LSN):longint; cdecl;
    rep_start                     : function (_para1:PDB_ENV; _para2:PDBT; _para3:u_int32_t):longint; cdecl;
    rep_stat                      : function (_para1:PDB_ENV; var _para2:PDB_REP_STAT; _para3:u_int32_t):longint; cdecl;
    get_rep_limit                 : function (_para1:PDB_ENV; var _para2:u_int32_t; var _para3:u_int32_t):longint; cdecl;
    set_rep_limit                 : function (_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t):longint; cdecl;
    set_rep_request               : function (_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t):longint; cdecl;
    //set_rep_transport : function (_para1:PDB_ENV; _para2:longint; _para3:function (_para1:PDB_ENV; _para2:PDBT; _para3:PDBT; _para4:PDB_LSN; _para5:longint;
    //                        _para6:u_int32_t):longint):longint;
    set_rep_transport : function (_para1:PDB_ENV; _para2:longint; _para3:pointer):longint; cdecl;
    tx_handle : pointer;
    get_tx_max : function (_para1:PDB_ENV; var _para2:u_int32_t):longint; cdecl;
    set_tx_max : function (_para1:PDB_ENV; _para2:u_int32_t):longint; cdecl;
    get_tx_timestamp : function (_para1:PDB_ENV; var _para2:time_t):longint; cdecl;
    set_tx_timestamp : function (_para1:PDB_ENV; var _para2:time_t):longint; cdecl;
    txn_begin : function (_para1:PDB_ENV; _para2:PDB_TXN; var _para3:PDB_TXN; _para4:u_int32_t):longint; cdecl;
    txn_checkpoint : function (_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:u_int32_t):longint; cdecl;
    txn_recover : function (_para1:PDB_ENV; _para2:PDB_PREPLIST; _para3:longint; _para4:Plongint; _para5:u_int32_t):longint; cdecl;
    txn_stat : function (_para1:PDB_ENV; var _para2:PDB_TXN_STAT; _para3:u_int32_t):longint; cdecl;
    get_timeout : function (_para1:PDB_ENV; var _para2:db_timeout_t; _para3:u_int32_t):longint; cdecl;
    set_timeout : function (_para1:PDB_ENV; _para2:db_timeout_t; _para3:u_int32_t):longint; cdecl;
    test_abort : longint;
    test_copy : longint;
    flags : u_int32_t;
  end;

     DBM = TDB;
     PDBM = ^DBM;
  { Flags to dbm_store().  }

  {
     The DB support for ndbm(3) always appends this suffix to the
     file name to avoid overwriting the user's original database.
    }

  datum = record
    dptr : Pchar;
    dsize : size_t;
  end;
  {
     Translate NDBM calls into DB calls so that DB doesn't step on the
     application's name space.
    }
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_clearerr(var a : DBM) : longint;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  procedure dbm_close(var a : DBM);

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_delete(var a : dbm; b : datum) : longint;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_dirfno(var a : DBM) : longint;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_error(var a : DBM) : longint;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_fetch(var a : DBM; b : Datum) : datum;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_firstkey(var a : DBM) : datum;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_nextkey(var a : DBM) : datum;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_open(a : Pchar; b,c : longint) : PDBM;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_pagfno(var a : DBM) : longint;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_rdonly(var a : DBM) : longint;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_store(var a : DBM; b,c : datum; d : longint) : longint;

  {
     Translate DBM calls into DB calls so that DB doesn't step on the
     application's name space.
    
     The global variables dbrdonly, dirf and pagf were not retained when 4BSD
     replaced the dbm interface with ndbm, and are not supported here.
    }
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbminit(a : Pchar) : longint;

  //const
  //   dbmclose = __db_dbm_close;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }
  function delete(a : datum) : longint;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function fetch(a : Datum) : Datum;


  //const
  //   firstkey = __db_dbm_firstkey;
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function nextkey(a : Datum) : Datum;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function store(a,b : Datum) : longint;

  {                                                      
     Hsearch historic interface.
                                                          }

  

Type
  ACTION = (FIND,ENTER);

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function hcreate(a : longint) : longint;


//  const
//     hdestroy = __db_hdestroy;
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function hsearch(a : TENTRY; b : ACTION) : PENTRY;

  { DB_DBM_HSEARCH  }
  { !_DB_H_  }
  { DO NOT EDIT: automatically built by dist/s_rpc.  }
  { was #define dname def_expr }
  function DB_RPC_SERVERPROG : dword;

  { was #define dname def_expr }
  function DB_RPC_SERVERVERS : dword;

  { DO NOT EDIT: automatically built by dist/s_include.  }

  function _db_create(var _para1: PDB; _para2:PDB_ENV; _para3:u_int32_t):longint; cdecl;
  function db_strerror(_para1:longint):Pchar; cdecl;
  function db_env_create(_para1:PPDB_ENV; _para2:u_int32_t):longint; cdecl;
  function db_version(_para1:Plongint; _para2:Plongint; _para3:Plongint):Pchar; cdecl;
  function log_compare(_para1:PDB_LSN; _para2:PDB_LSN):longint; cdecl;
  //function db_env_set_func_close(_para1:function (_para1:longint):longint):longint;
  function db_env_set_func_close(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_dirfree(_para1:procedure (_para1:PPchar; _para2:longint)):longint;
  function db_env_set_func_dirfree(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_dirlist(_para1:function (_para1:Pchar; _para2:PPPchar; _para3:Plongint):longint):longint;
  function db_env_set_func_dirlist(_para1:pointer):longint; cdecl;
  //function db_env_set_func_exists(_para1:function (_para1:Pchar; _para2:Plongint):longint):longint;
  function db_env_set_func_exists(_para1:pointer):longint; cdecl;
  //function db_env_set_func_free(_para1:procedure (_para1:pointer)):longint;
  function db_env_set_func_free(_para1:TSysFreeMem):longint; cdecl;
  //function db_env_set_func_fsync(_para1:function (_para1:longint):longint):longint;
  function db_env_set_func_fsync(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_ioinfo(_para1:function (_para1:Pchar; _para2:longint; _para3:Pu_int32_t; _para4:Pu_int32_t; _para5:Pu_int32_t):longint):longint;
  function db_env_set_func_ioinfo(_para1:pointer):longint; cdecl;
  //function db_env_set_func_malloc(_para1:Pprocedure (_para1:size_t)):longint;
  function db_env_set_func_malloc(_para1:TSysGetMem):longint; cdecl;
  //function db_env_set_func_map(_para1:function (_para1:Pchar; _para2:size_t; _para3:longint; _para4:longint; _para5:Ppointer):longint):longint;
  function db_env_set_func_map(_para1:Pointer):longint;  cdecl;
  //function db_env_set_func_open(_para1:function (_para1:Pchar; _para2:longint; args:array of const):longint):longint;
  function db_env_set_func_open(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_read(_para1:function (_para1:longint; _para2:pointer; _para3:size_t):ssize_t):longint;
  function db_env_set_func_read(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_realloc(_para1:Pprocedure (_para1:pointer; _para2:size_t)):longint;
  function db_env_set_func_realloc(_para1:TSysReallocMem):longint; cdecl;
  //function db_env_set_func_rename(_para1:function (_para1:Pchar; _para2:Pchar):longint):longint;
  function db_env_set_func_rename(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_seek(_para1:function (_para1:longint; _para2:size_t; _para3:db_pgno_t; _para4:u_int32_t; _para5:longint;
  //                      _para6:longint):longint):longint;
  function db_env_set_func_seek(_para1:Pointer):longint;  cdecl;
  //function db_env_set_func_sleep(_para1:function (_para1:u_long; _para2:u_long):longint):longint;
  function db_env_set_func_sleep(_para1:Pointer):longint;  cdecl;
  //function db_env_set_func_unlink(_para1:function (_para1:Pchar):longint):longint;
  function db_env_set_func_unlink(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_unmap(_para1:function (_para1:pointer; _para2:size_t):longint):longint;
  function db_env_set_func_unmap(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_write(_para1:function (_para1:longint; _para2:pointer; _para3:size_t):ssize_t):longint;
  function db_env_set_func_write(_para1:Pointer):longint; cdecl;
  //function db_env_set_func_yield(_para1:function :longint):longint;
  function db_env_set_func_yield(_para1:Pointer):longint; cdecl;
  function __db_ndbm_clearerr(var _para1:DBM):longint; cdecl;
  procedure __db_ndbm_close(var _para1:DBM); cdecl;
  function __db_ndbm_delete(var _para1:DBM; _para2:datum):longint; cdecl;
  function __db_ndbm_dirfno(var _para1:DBM):longint; cdecl;
  function __db_ndbm_error(var _para1:DBM):longint;  cdecl;
  function __db_ndbm_fetch(var _para1:DBM; _para2:datum):datum; cdecl;
  function __db_ndbm_firstkey(var _para1:DBM):datum; cdecl;
  function __db_ndbm_nextkey(var _para1:DBM):datum; cdecl;
  function __db_ndbm_open(_para1:Pchar; _para2:longint; _para3:longint):PDBM; cdecl;
  function __db_ndbm_pagfno(var _para1:DBM):longint; cdecl;
  function __db_ndbm_rdonly(var _para1:DBM):longint; cdecl;
  function __db_ndbm_store(var _para1:DBM; _para2:datum; _para3:datum; _para4:longint):longint; cdecl;
  function __db_dbm_close:longint; cdecl;
  //function __db_dbm_dbrdonly:longint; cdecl;
  function __db_dbm_delete(_para1:datum):longint; cdecl;
  //function __db_dbm_dirf:longint; cdecl;
  function __db_dbm_fetch(_para1:datum):datum; cdecl;
  function __db_dbm_firstkey:datum; cdecl;
  function __db_dbm_init(_para1:Pchar):longint; cdecl;
  function __db_dbm_nextkey(_para1:datum):datum; cdecl;
  //function __db_dbm_pagf:longint; cdecl;
  function __db_dbm_store(_para1:datum; _para2:datum):longint; cdecl;
  function __db_hcreate(_para1:size_t):longint; cdecl;
  function __db_hsearch(_para1:TENTRY; _para2:ACTION):PENTRY; cdecl;
  procedure __db_hdestroy; cdecl;

  { !_DB_EXT_PROT_IN_  }

implementation

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }
  function dbm_clearerr(var a : DBM) : longint;
    begin
       dbm_clearerr:=__db_ndbm_clearerr(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }
  procedure dbm_close(var a : DBM);
    begin
       __db_ndbm_close(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }
  function dbm_delete(var a : dbm; b : datum) : longint;
    begin
       dbm_delete:=__db_ndbm_delete(a,b);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }
  function dbm_dirfno(var a : DBM) : longint;
    begin
       dbm_dirfno:=__db_ndbm_dirfno(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_error(var a : DBM) : longint;
    begin
       dbm_error:=__db_ndbm_error(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_fetch(var a : DBM; b : Datum) : datum;
    begin
       dbm_fetch:=__db_ndbm_fetch(a,b);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_firstkey(var a : DBM) : datum;
    begin
       dbm_firstkey:=__db_ndbm_firstkey(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_nextkey(var a : DBM) : datum;
    begin
       dbm_nextkey:=__db_ndbm_nextkey(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_open(a : Pchar; b,c : longint) : PDBM;
    begin
       dbm_open:=__db_ndbm_open(a,b,c);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_pagfno(var a : DBM) : longint;
    begin
       dbm_pagfno:=__db_ndbm_pagfno(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_rdonly(var a : DBM) : longint;
    begin
       dbm_rdonly:=__db_ndbm_rdonly(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbm_store(var a: DBM; b,c : datum; d : longint) : longint;
    begin
       dbm_store:=__db_ndbm_store(a,b,c,d);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function dbminit(a : Pchar) : longint;
    begin
       dbminit:=__db_dbm_init(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function delete(a : Datum) : longint;
    begin
       delete:=__db_dbm_delete(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }
  function fetch(a : Datum) : Datum;
    begin
       fetch:=__db_dbm_fetch(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function nextkey(a : Datum) : datum;
    begin
       nextkey:=__db_dbm_nextkey(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function store(a,b : Datum) : longint;
    begin
       store:=__db_dbm_store(a,b);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function hcreate(a : longint) : longint;
    begin
       hcreate:=__db_hcreate(a);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function hsearch(a : TENTRY; b : ACTION) : PENTRY;
  begin
    hsearch:=__db_hsearch(a,b);
  end;

  { was #define dname def_expr }
  function DB_RPC_SERVERPROG : dword;
      begin
         DB_RPC_SERVERPROG:=dword(351457);
      end;

  { was #define dname def_expr }
  function DB_RPC_SERVERVERS : dword;
      begin
         DB_RPC_SERVERVERS:=dword(4002);
      end;



//#define	DB_UNDO(op)	((op) == DB_TXN_ABORT || (op) == DB_TXN_BACKWARD_ROLL || (op) == DB_TXN_BACKWARD_ALLOC)
//#define	DB_REDO(op)	((op) == DB_TXN_FORWARD_ROLL || (op) == DB_TXN_APPLY)


(*

*
 * Macros for bulk get.  These are only intended for the C API.
 * For C++, use DbMultiple*Iterator.
 *
#define	DB_MULTIPLE_INIT(pointer, dbt)
  (pointer = (u_int8_t * )(dbt)->data + (dbt)->ulen - sizeof(u_int32_t))
#define	DB_MULTIPLE_NEXT(pointer, dbt, retdata, retdlen)
   do
   { if (*((u_int32_t * )(pointer)) == (u_int32_t)-1)
     {   retdata = NULL; pointer = NULL; break; }
		retdata = (u_int8_t * )
		    (dbt)->data + *(u_int32_t * )(pointer);
		(pointer) = (u_int32_t * )(pointer) - 1;
		retdlen = *(u_int32_t * )(pointer);
		(pointer) = (u_int32_t * )(pointer) - 1;
		if (retdlen == 0 &&
		    retdata == (u_int8_t * )(dbt)->data)
			retdata = NULL;
	} while (0)
#define	DB_MULTIPLE_KEY_NEXT(pointer, dbt, retkey, retklen, retdata, retdlen) \
	do {								\
		if (*((u_int32_t * )(pointer)) == (u_int32_t)-1) {	\
			retdata = NULL;
			retkey = NULL;
			pointer = NULL;
			break;
		}
		retkey = (u_int8_t * )
		    (dbt)->data + *(u_int32_t * )(pointer);
		(pointer) = (u_int32_t * )(pointer) - 1;
		retklen = *(u_int32_t * )(pointer);
		(pointer) = (u_int32_t * )(pointer) - 1;
		retdata = (u_int8_t * )
		    (dbt)->data + *(u_int32_t * )(pointer);
		(pointer) = (u_int32_t * )(pointer) - 1;
		retdlen = *(u_int32_t * )(pointer);
		(pointer) = (u_int32_t * )(pointer) - 1;
	} while (0)

  procedure	DB_MULTIPLE_RECNO_NEXT(pointer, dbt, recno, retdata, retdlen)
  begin
    do
    begin
		if ( *((u_int32_t * )(pointer)) == (u_int32_t)0)
    begin
			recno = 0;
			retdata = NULL;
			pointer = NULL;
			break;
		end;
		recno = *(u_int32_t * )(pointer);
		(pointer) = (u_int32_t * )(pointer) - 1;
		retdata = (u_int8_t * )
		    (dbt)->data + *(u_int32_t * )(pointer);
		(pointer) = (u_int32_t * )(pointer) - 1;
		retdlen = *(u_int32_t * )(pointer);
		(pointer) = (u_int32_t * )(pointer) - 1;
	  end; while (0)
  end;

*)

  function _db_create             ;      external dblib name '_db_create'              ;
  function db_env_create          ;      external dblib name '_db_env_create'          ;
  function db_strerror            ;      external dblib name '_db_strerror'            ;
  function db_version             ;      external dblib name '_db_version'             ;

  function log_compare            ;      external dblib name '_log_compare'            ;
  function db_env_set_func_close  ;      external dblib name '_db_env_set_func_close'  ;
  function db_env_set_func_dirfree;      external dblib name '_db_env_set_func_dirfree';
  function db_env_set_func_dirlist;      external dblib name '_db_env_set_func_dirlist';
  function db_env_set_func_exists ;      external dblib name '_db_env_set_func_exists' ;
  function db_env_set_func_free   ;      external dblib name '_db_env_set_func_free'   ;
  function db_env_set_func_fsync  ;      external dblib name '_db_env_set_func_fsync'  ;
  function db_env_set_func_ioinfo ;      external dblib name '_db_env_set_func_ioinfo' ;
  function db_env_set_func_malloc ;      external dblib name '_db_env_set_func_malloc' ;
  function db_env_set_func_map    ;      external dblib name '_db_env_set_func_map'    ;
  function db_env_set_func_open   ;      external dblib name '_db_env_set_func_open'   ;
  function db_env_set_func_read   ;      external dblib name '_db_env_set_func_read'   ;
  function db_env_set_func_realloc;      external dblib name '_db_env_set_func_realloc';
  function db_env_set_func_rename ;      external dblib name '_db_env_set_func_rename' ;
  function db_env_set_func_seek   ;      external dblib name '_db_env_set_func_seek'   ;
  function db_env_set_func_sleep  ;      external dblib name '_db_env_set_func_sleep'  ;
  function db_env_set_func_unlink ;      external dblib name '_db_env_set_func_unlink' ;
  function db_env_set_func_unmap  ;      external dblib name '_db_env_set_func_unmap'  ;
  function db_env_set_func_write  ;      external dblib name '_db_env_set_func_write'  ;
  function db_env_set_func_yield  ;      external dblib name '_db_env_set_func_yield'  ;


	//function __db_add_recovery      ;	     external dblib name '___db_add_recovery'      ;
	function __db_dbm_close	        ;      external dblib name '___db_dbm_close'         ;
	function __db_dbm_delete	      ;      external dblib name '___db_dbm_delete'        ;
	function __db_dbm_fetch	        ;      external dblib name '___db_dbm_fetch'         ;
	function __db_dbm_firstkey      ;	     external dblib name '___db_dbm_firstkey'      ;
	function __db_dbm_init	        ;      external dblib name '___db_dbm_init'          ;
	function __db_dbm_nextkey	      ;      external dblib name '___db_dbm_nextkey'       ;
	function __db_dbm_store	        ;      external dblib name '___db_dbm_store'         ;
	function __db_hcreate	          ;      external dblib name '___db_hcreate'           ;
	procedure __db_hdestroy	        ;      external dblib name '___db_hdestroy'          ;
	function __db_hsearch	          ;      external dblib name '___db_hsearch'           ;
	//function __db_loadme	          ;      external dblib name '___db_loadme'          ;
  function __db_ndbm_clearerr     ;      external dblib name '___db_ndbm_clearerr'     ;
	procedure __db_ndbm_close	      ;      external dblib name '___db_ndbm_close'        ;
	function __db_ndbm_delete	      ;      external dblib name '___db_ndbm_delete'       ;
	function __db_ndbm_dirfno	      ;      external dblib name '___db_ndbm_dirfno'       ;
	function __db_ndbm_error	      ;      external dblib name '___db_ndbm_error'        ;
	function __db_ndbm_fetch	      ;      external dblib name '___db_ndbm_fetch'        ;
	function __db_ndbm_firstkey     ;	     external dblib name '___db_ndbm_firstkey'     ;
	function __db_ndbm_nextkey      ;	     external dblib name '___db_ndbm_nextkey'      ;
	function __db_ndbm_open	        ;      external dblib name '___db_ndbm_open'         ;
	function __db_ndbm_pagfno	      ;      external dblib name '___db_ndbm_pagfno'       ;
	function __db_ndbm_rdonly	      ;      external dblib name '___db_ndbm_rdonly'       ;
	function __db_ndbm_store	      ;      external dblib name '___db_ndbm_store'        ;
	//function __db_panic	            ;      external dblib name '___db_panic'             ;
	//function __db_r_attach	        ;      external dblib name '___db_r_attach'          ;
	//function __db_r_detach	        ;      external dblib name '___db_r_detach'          ;
	//function __db_win32_mutex_init  ;	     external dblib name '___db_win32_mutex_init'  ;
	//function __db_win32_mutex_lock  ;	     external dblib name '___db_win32_mutex_lock'  ;
	//function __db_win32_mutex_unlock;	     external dblib name '___db_win32_mutex_unlock';
	//function __ham_func2	          ;      external dblib name '___ham_func2'            ;
	//function __ham_func3	          ;      external dblib name '___ham_func3'            ;
	//function __ham_func4	          ;      external dblib name '___ham_func4'            ;
	//function __ham_func5	          ;      external dblib name '___ham_func5'            ;
	//function __ham_test	            ;      external dblib name '___ham_test'             ;
  //function __lock_dump_region	    ;      external dblib name '___lock_dump_region'     ;
	//function __lock_id_set	        ;      external dblib name '___lock_id_set'          ;
	//function __memp_dump_region	    ;      external dblib name '___memp_dump_region'     ;
	//function __os_calloc	          ;      external dblib name '___os_calloc'            ;
	//function __os_closehandle	      ;      external dblib name '___os_closehandle'       ;
	//function __os_free	            ;      external dblib name '___os_free'              ;
	//function __os_ioinfo	          ;      external dblib name '___os_ioinfo'            ;
	//function __os_malloc	          ;      external dblib name '___os_malloc'            ;
	//function __os_open	            ;      external dblib name '___os_open'              ;
	//function __os_openhandle	      ;      external dblib name '___os_openhandle'        ;
	//function __os_read	            ;      external dblib name '___os_read'              ;
	//function __os_realloc	          ;      external dblib name '___os_realloc'           ;
	//function __os_strdup	          ;      external dblib name '___os_strdup'            ;
	//function __os_umalloc	          ;      external dblib name '___os_umalloc'           ;
	//function __os_write	            ;      external dblib name '___os_write'             ;
	//function __txn_id_set	          ;      external dblib name '___txn_id_set'           ;
	//function __bam_init_print	      ;      external dblib name '___bam_init_print'       ;
	//function __bam_pgin	            ;      external dblib name '___bam_pgin'             ;
	//function __bam_pgout	          ;      external dblib name '___bam_pgout'            ;
	//function __crdel_init_print	    ;      external dblib name '___crdel_init_print'     ;
	//function __db_dispatch	        ;      external dblib name '___db_dispatch'          ;
	//function __db_dump	            ;      external dblib name '___db_dump'              ;
	//function __db_e_stat	          ;      external dblib name '___db_e_stat'            ;
	//function __db_err	              ;      external dblib name '___db_err'               ;
	//function __db_getlong	          ;      external dblib name '___db_getlong'           ;
	//function __db_getulong	        ;      external dblib name '___db_getulong'          ;
	//function __db_global_values	    ;      external dblib name '___db_global_values'     ;
	//function __db_init_print	      ;      external dblib name '___db_init_print'        ;
	//function __db_inmemdbflags	    ;      external dblib name '___db_inmemdbflags'      ;
	//function __db_isbigendian	      ;      external dblib name '___db_isbigendian'       ;
	//function __db_omode	            ;      external dblib name '___db_omode'             ;
	//function __db_overwrite	        ;      external dblib name '___db_overwrite'         ;
	//function __db_pgin	            ;      external dblib name '___db_pgin'              ;
	//function __db_pgout	            ;      external dblib name '___db_pgout'             ;
	//function __db_pr_callback	      ;      external dblib name '___db_pr_callback'       ;
	//function __db_prdbt	            ;      external dblib name '___db_prdbt'             ;
	//function __db_prfooter	        ;      external dblib name '___db_prfooter'          ;
	//function __db_prheader	        ;      external dblib name '___db_prheader'          ;
	//function __db_rpath	            ;      external dblib name '___db_rpath'             ;
	//function __db_util_cache	      ;      external dblib name '___db_util_cache'        ;
	//function __db_util_interrupted	;      external dblib name '___db_util_interrupted'  ;
	//function __db_util_logset	      ;      external dblib name '___db_util_logset'       ;
	//function __db_util_siginit	    ;      external dblib name '___db_util_siginit'      ;
	//function __db_util_sigresend	  ;      external dblib name '___db_util_sigresend'    ;
	//function __db_verify_internal	  ;      external dblib name '___db_verify_internal'   ;
	//function __dbreg_init_print	    ;      external dblib name '___dbreg_init_print'     ;
	//function __fop_init_print	      ;      external dblib name '___fop_init_print'       ;
	//function __ham_get_meta	        ;      external dblib name '___ham_get_meta'         ;
	//function __ham_init_print	      ;      external dblib name '___ham_init_print'       ;
	//function __ham_pgin	            ;      external dblib name '___ham_pgin'             ;
	//function __ham_pgout	          ;      external dblib name '___ham_pgout'            ;
	//function __ham_release_meta	    ;      external dblib name '___ham_release_meta'     ;
	//function __os_clock	            ;      external dblib name '___os_clock'             ;
	//function __os_get_errno	        ;      external dblib name '___os_get_errno'         ;
	//function __os_id	              ;      external dblib name '___os_id'                ;
	//function __os_set_errno	        ;      external dblib name '___os_set_errno'         ;
	//function __os_sleep	            ;      external dblib name '___os_sleep'             ;
	//function __os_ufree	            ;      external dblib name '___os_ufree'             ;
	//function __os_yield	            ;      external dblib name '___os_yield'             ;
	//function __qam_init_print	      ;      external dblib name '___qam_init_print'       ;
	//function __qam_pgin_out	        ;      external dblib name '___qam_pgin_out'         ;
	//function __txn_init_print	      ;      external dblib name '___txn_init_print'       ;

end.
