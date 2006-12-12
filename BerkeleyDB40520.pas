{$Z4}
Unit BerkeleyDB40520;
interface
uses
  Windows;

(* DO NOT EDIT: automatically built by dist/s_windows. *)
(*
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1996-2006
 * Oracle Corporation.  All rights reserved.
 *
 * $Id: db.in,v 12.108 2006/09/13 14:53:37 mjc Exp $
 *
 * db.h include file layout:
 * General.
 * Database Environment.
 * Locking subsystem.
 * Logging subsystem.
 * Shared buffer cache (mpool) subsystem.
 * Transaction subsystem.
 * Access methods.
 * Access method cursors.
 * Dbm/Ndbm, Hsearch historic interfaces.
 *)


(*
 * Turn off inappropriate compiler warnings
 *)

//   __P(protos) protos

(*
 * Berkeley DB version information.
 *)
 Const
   DB_VERSION_MAJOR    = 4;
   DB_VERSION_MINOR    = 5;
   DB_VERSION_PATCH    = 20;
   DB_VERSION_STRING   = 'Berkeley DB 4.5.20: (September 20, 2006)';

(*
 * !!!
 * Berkeley DB uses specifically sized types.  If they're not provided by
 * the system, type them here.
 *
 * We protect them against multiple inclusion using __BIT_TYPES_DEFINED__,
 * as does BIND and Kerberos, since we don't know for sure what #include
 * files the user is using.
 *
 * !!!
 * We also provide the standard u_int, u_long etc., if they're not provided
 * by the system.
 *)
type
  int          = Integer;
  long         = integer;

  u_int8_t     = byte;
  Pu_int8_t     = ^u_int8_t;
  int16_t      = smallint;
  u_int16_t    = word;
  int32_t      = integer;
  u_int32_t    = DWORD;
  int64_t      = int64;
  u_int64_t    = int64;

  time_t       = int64;
type
  u_char       = Byte;
  u_short      = Word;
  u_int        = DWORD;
  u_long       = DWORD;

{$ifdef _WIN64}
type
  ssize_t      = int64_t;
  size_t       = int64_t;
{$else}
type
  ssize_t      = int32_t;
  size_t       = cardinal;
{$endif}

(*
 * uintmax_t --
 * Largest unsigned type, used to align structures in memory.  We don't store
 * floating point types in structures, so integral types should be sufficient
 * (and we don't have to worry about systems that store floats in other than
 * power-of-2 numbers of bytes).  Additionally this fixes compilers that rewrite
 * structure assignments and ANSI C memcpy calls to be in-line instructions
 * that happen to require alignment.
 *
 * uintptr_t --
 * Unsigned type that's the same size as a pointer.  There are places where
 * DB modifies pointers by discarding the bottom bits to guarantee alignment.
 * We can't use uintmax_t, it may be larger than the pointer, and compilers
 * get upset about that.  So far we haven't run on any machine where there's
 * no unsigned type the same size as a pointer -- here's hoping.
 *)
type
  uintmax_t = u_int64_t ;
{$ifdef _WIN64}
type
  uintptr_t= u_int64_t ;
{$else}
type
  uintptr_t= u_int32_t ;
{$endif}

(*
 * Sequences are only available on machines with 64-bit integral types.
 *)
type
  db_seq_t=int64_t ;

(* Thread and process identification. *)
type
  db_threadid_t = u_int32_t ;
type
  pid_t = int ;

(* Basic types that are exported or quasi-exported. *)
type
  db_pgno_t = u_int32_t ; (* Page number type. *)
  db_indx_t = u_int16_t ; (* Page offset type. *)
Const
  DB_MAX_PAGES = $ffffffff; (* >= # of pages in a file *)

type
  db_recno_t = u_int32_t ; (* Record number type. *)
const
  DB_MAX_RECORDS = $ffffffff; (* >= # of records in a tree *)

type
  db_timeout_t = u_int32_t ; (* Type of a timeout. *)

(*
 * Region offsets are the difference between a pointer in a region and the
 * region's base address.  With private environments, both addresses are the
 * result of calling malloc, and we can't assume anything about what malloc
 * will return, so region offsets have to be able to hold differences between
 * arbitrary pointers.
 *)
type
  roff_t = uintptr_t ;

(*
 * Forward structure declarations, so we can declare pointers and
 * applications can get type checking.
 *)
 {
struct __db;  type struct __db DB;
struct __db_cipher; type struct __db_cipher DB_CIPHER;
struct __db_env; type struct __db_env DB_ENV;
struct __db_h_stat; type struct __db_h_stat DB_HASH_STAT;
struct __db_lock_stat; type struct __db_lock_stat DB_LOCK_STAT;
struct __db_lock_u; type struct __db_lock_u DB_LOCK;
struct __db_lockreq; type struct __db_lockreq DB_LOCKREQ;
struct __db_locktab; type struct __db_locktab DB_LOCKTAB;
struct __db_log; type struct __db_log DB_LOG;
struct __db_log_cursor; type struct __db_log_cursor DB_LOGC;
struct __db_log_stat; type struct __db_log_stat DB_LOG_STAT;
struct __db_mpool; type struct __db_mpool DB_MPOOL;
struct __db_mpool_fstat;type struct __db_mpool_fstat DB_MPOOL_FSTAT;
struct __db_mpool_stat; type struct __db_mpool_stat DB_MPOOL_STAT;
struct __db_mpoolfile; type struct __db_mpoolfile DB_MPOOLFILE;
struct __db_mutex_stat; type struct __db_mutex_stat DB_MUTEX_STAT;
struct __db_mutex_t; type struct __db_mutex_t DB_MUTEX;
struct __db_mutexmgr; type struct __db_mutexmgr DB_MUTEXMGR;
struct __db_preplist; type struct __db_preplist DB_PREPLIST;
struct __db_qam_stat; type struct __db_qam_stat DB_QUEUE_STAT;
struct __db_rep; type struct __db_rep DB_REP;
struct __db_rep_stat; type struct __db_rep_stat DB_REP_STAT;
struct __db_repmgr_site; type struct __db_repmgr_site DB_REPMGR_SITE;
struct __db_seq_record; type struct __db_seq_record DB_SEQ_RECORD;
struct __db_seq_stat; type struct __db_seq_stat DB_SEQUENCE_STAT;
struct __db_sequence; type struct __db_sequence DB_SEQUENCE;
struct __db_txn; type struct __db_txn DB_TXN;
struct __db_txn_active; type struct __db_txn_active DB_TXN_ACTIVE;
struct __db_txn_stat; type struct __db_txn_stat DB_TXN_STAT;
struct __db_txnmgr; type struct __db_txnmgr DB_TXNMGR;
struct __dbc;  type struct __dbc DBC;
struct __dbc_internal; type struct __dbc_internal DBC_INTERNAL;
struct __fh_t;  type struct __fh_t DB_FH;
struct __fname;  type struct __fname FNAME;
struct __key_range; type struct __key_range DB_KEY_RANGE;
struct __mpoolfile; type struct __mpoolfile MPOOLFILE;
}
(* Key/data structure -- a Data-Base Thang. *)
const
  DB_DBT_APPMALLOC     = $001; (* Callback allocated memory. *)
  DB_DBT_ISSET         = $002; (* Lower level calls set value. *)
  DB_DBT_MALLOC        = $004; (* Return in malloc'd memory. *)
  DB_DBT_PARTIAL       = $008; (* Partial put/get. *)
  DB_DBT_REALLOC       = $010; (* Return in realloc'd memory. *)
  DB_DBT_USERCOPY      = $020; (* Use the user-supplied callback. *)
  DB_DBT_USERMEM       = $040; (* Return in user's memory. *)
  DB_DBT_DUPOK         = $080; (* Insert if duplicate. *)
type
  PDBT = ^DBT;
  DBT = packed record
    data: Pointer ;   (* Key/data *)
    size: u_int32_t ;   (* key/data length *)

    ulen: u_int32_t ;   (* RO: length of user buffer. *)
    dlen: u_int32_t ;   (* RO: get/put record length. *)
    doff: u_int32_t ;   (* RO: get/put record offset. *)

    app_data: Pointer ;

    flags: u_int32_t ;
  end;

(*
 * Common flags --
 * Interfaces which use any of these common flags should never have
 * interface specific flags in this range.
 *)
 const
   DB_CREATE          =$0000001; (* Create file as necessary. *)
   DB_DURABLE_UNKNOWN =$0000002; (* Durability on open (internal). *)
   DB_FORCE           =$0000004; (* Force (anything). *)
   DB_MULTIVERSION    =$0000008; (* Multiversion concurrency control. *)
   DB_NOMMAP          =$0000010; (* Don't mmap underlying file. *)
   DB_RDONLY          =$0000020; (* Read-only (O_RDONLY). *)
   DB_RECOVER         =$0000040; (* Run normal recovery. *)
   DB_THREAD          =$0000080; (* Applications are threaded. *)
   DB_TRUNCATE        =$0000100; (* Discard existing DB (O_TRUNC). *)
   DB_TXN_NOSYNC      =$0000200; (* Do not sync log on commit. *)
   DB_TXN_NOT_DURABLE =$0000400; (* Do not log changes. *)
   DB_TXN_WRITE_NOSYNC=$0000800; (* Write the log but don't sync. *)
   DB_USE_ENVIRON     =$0001000; (* Use the environment. *)
   DB_USE_ENVIRON_ROOT=$0002000; (* Use the environment if root. *)

(*
 * Common flags --
 * Interfaces which use any of these common flags should never have
 * interface specific flags in this range.
 *
 * DB_AUTO_COMMIT:
 * DB_ENV->set_flags, DB->open
 *      (Note: until the 4.3 release, legal to DB->associate, DB->del,
 * DB->put, DB->remove, DB->rename and DB->truncate, and others.)
 * DB_READ_COMMITTED:
 * DB->cursor, DB->get, DB->join, DBcursor->c_get, DB_ENV->txn_begin
 * DB_READ_UNCOMMITTED:
 * DB->cursor, DB->get, DB->join, DB->open, DBcursor->c_get,
 * DB_ENV->txn_begin
 * DB_TXN_SNAPSHOT:
 * DB_ENV->set_flags, DB_ENV->txn_begin, DB->cursor
 *
 * !!!
 * The DB_READ_COMMITTED and DB_READ_UNCOMMITTED bit masks can't be changed
 * without also changing the masks for the flags that can be OR'd into DB
 * access method and cursor operation values.
 *)
const
  DB_AUTO_COMMIT      =$02000000;(* Implied transaction. *)

  DB_READ_COMMITTED   =$04000000;(* Degree 2 isolation. *)
  DB_DEGREE_2         =$04000000;(* Historic name. *)

  DB_READ_UNCOMMITTED =$08000000;(* Degree 1 isolation. *)
  DB_DIRTY_READ       =$08000000;(* Historic name. *)

  DB_TXN_SNAPSHOT     =$10000000;(* Snapshot isolation. *)

(*
 * Flags common to db_env_create and db_create.
 *)
  DB_CXX_NO_EXCEPTIONS=$0000001; (* C++: return error values. *)

(*
 * Flags private to db_env_create.
 *    Shared flags up to $0000001 *)
  DB_RPCCLIENT        =$0000002; (* An RPC client environment. *)

(*
 * Flags private to db_create.
 *    Shared flags up to $0000001 *)
  DB_XA_CREATE        =$0000002; (* Open in an XA environment. *)

(*
 * Flags private to DB_ENV->open.
 *    Shared flags up to $0002000 *)
  DB_INIT_CDB         =$0004000; (* Concurrent Access Methods. *)
  DB_INIT_LOCK        =$0008000; (* Initialize locking. *)
  DB_INIT_LOG         =$0010000; (* Initialize logging. *)
  DB_INIT_MPOOL       =$0020000; (* Initialize mpool. *)
  DB_INIT_REP         =$0040000; (* Initialize replication. *)
  DB_INIT_TXN         =$0080000; (* Initialize transactions. *)
  DB_LOCKDOWN         =$0100000; (* Lock memory into physical core. *)
  DB_PRIVATE          =$0200000; (* DB_ENV is process local. *)
  DB_RECOVER_FATAL    =$0400000; (* Run catastrophic recovery. *)
  DB_REGISTER         =$0800000; (* Multi-process registry. *)
  DB_SYSTEM_MEM       =$1000000; (* Use system-backed memory. *)

  DB_JOINENV          =$0; (* Compatibility. *)

(*
 * Flags private to DB->open.
 *    Shared flags up to $0002000 *)
  DB_EXCL             =$0004000; (* Exclusive open (O_EXCL). *)
  DB_FCNTL_LOCKING    =$0008000; (* UNDOC: fcntl(2) locking. *)
  DB_NO_AUTO_COMMIT   =$0010000; (* Override env-wide AUTOCOMMIT. *)
  DB_RDWRMASTER       =$0020000; (* UNDOC: allow subdb master open R/W *)
  DB_WRITEOPEN        =$0040000; (* UNDOC: open with write lock. *)

(*
 * Flags private to DB->associate.
 *    Shared flags up to $0002000 *)
  DB_IMMUTABLE_KEY    = $0004000; (* Secondary key is immutable. *)
(*       Shared flags at $1000000 *)

(*
 * Flags private to DB_ENV->txn_begin.
 *    Shared flags up to $0002000 *)
  DB_TXN_NOWAIT       =$0004000; (* Do not wait for locks in this TXN. *)
  DB_TXN_SYNC         =$0008000; (* Always sync log on commit. *)

(*
 * Flags private to DB_ENV->set_encrypt.
 *)
  DB_ENCRYPT_AES      =$0000001; (* AES, assumes SHA1 checksum *)

(*
 * Flags private to DB_ENV->set_flags.
 *    Shared flags up to $00002000 *)
  DB_CDB_ALLDB        =$00004000;(* Set CDB locking per environment. *)
  DB_DIRECT_DB        =$00008000;(* Don't buffer databases in the OS. *)
  DB_DIRECT_LOG       =$00010000;(* Don't buffer log files in the OS. *)
  DB_DSYNC_DB         =$00020000;(* Set O_DSYNC on the databases. *)
  DB_DSYNC_LOG        =$00040000;(* Set O_DSYNC on the log. *)
  DB_LOG_AUTOREMOVE   =$00080000;(* Automatically remove log files. *)
  DB_LOG_INMEMORY     =$00100000;(* Store logs in buffers in memory. *)
  DB_NOLOCKING        =$00200000;(* Set locking/mutex behavior. *)
  DB_NOPANIC          =$00400000;(* Set panic state per DB_ENV. *)
  DB_OVERWRITE        =$00800000;(* Overwrite unlinked region files. *)
  DB_PANIC_ENVIRONMENT=$01000000;(* Set panic state per environment. *)
(*       Shared flags at $02000000 *)
(*       Shared flags at $04000000 *)
(*       Shared flags at $08000000 *)
(*       Shared flags at $10000000 *)
  DB_REGION_INIT      =$20000000;(* Page-fault regions on open. *)
  DB_TIME_NOTGRANTED  =$40000000;(* Return NOTGRANTED on timeout. *)
  DB_YIELDCPU         =$80000000;(* Yield the CPU (a lot). *)

(*
 * Flags private to DB->set_feedback's callback.
 *)
  DB_UPGRADE       =$0000001; (* Upgrading. *)
  DB_VERIFY        =$0000002; (* Verifying. *)

(*
 * Flags private to DB->compact.
 *    Shared flags up to $00002000
 *)
  DB_FREELIST_ONLY      =$00004000; (* Just sort and truncate. *)
  DB_FREE_SPACE         =$00008000; (* Free space . *)
  DB_COMPACT_FLAGS      = (DB_FREELIST_ONLY or DB_FREE_SPACE);

(*
 * Flags private to DB_MPOOLFILE->open.
 *    Shared flags up to $0002000 *)
  DB_DIRECT       =$0004000; (* Don't buffer the file in the OS. *)
  DB_EXTENT       =$0008000; (* internal: dealing with an extent. *)
  DB_ODDFILESIZE  =$0010000; (* Truncate file to N * pgsize. *)

(*
 * Flags private to DB->set_flags.
 *    Shared flags up to $00002000 *)
  DB_CHKSUM    =$00004000; (* Do checksumming *)
  DB_DUP       =$00008000; (* Btree, Hash: duplicate keys. *)
  DB_DUPSORT   =$00010000; (* Btree, Hash: duplicate keys. *)
  DB_ENCRYPT   =$00020000; (* Btree, Hash: duplicate keys. *)
  DB_INORDER   =$00040000; (* Queue: strict ordering on consume *)
  DB_RECNUM    =$00080000; (* Btree: record numbers. *)
  DB_RENUMBER  =$00100000; (* Recno: renumber on insert/delete. *)
  B_REVSPLITOFF=$00200000; (* Btree: turn off reverse splits. *)
  DB_SNAPSHOT  =$00400000; (* Recno: snapshot the input. *)

(*
 * Flags private to the DB_ENV->stat_print, DB->stat and DB->stat_print methods.
 *)
  DB_FAST_STAT          =$0000001; (* Don't traverse the database. *)
  DB_STAT_ALL           =$0000002; (* Print: Everything. *)
  DB_STAT_CLEAR         =$0000004; (* Clear stat after returning values. *)
  DB_STAT_LOCK_CONF     =$0000008; (* Print: Lock conflict matrix. *)
  DB_STAT_LOCK_LOCKERS  =$0000010; (* Print: Lockers. *)
  DB_STAT_LOCK_OBJECTS  =$0000020; (* Print: Lock objects. *)
  DB_STAT_LOCK_PARAMS   =$0000040; (* Print: Lock parameters. *)
  DB_STAT_MEMP_HASH     =$0000080; (* Print: Mpool hash buckets. *)
  DB_STAT_NOERROR       =$0000100; (* Internal: continue on error. *)
  DB_STAT_SUBSYSTEM     =$0000200; (* Print: Subsystems too. *)

(*
 * Flags private to DB->join.
 *)
  DB_JOIN_NOSORT        =$0000001; (* Don't try to optimize join. *)

(*
 * Flags private to DB->verify.
 *)
  DB_AGGRESSIVE       =$0000001; (* Salvage whatever could be data.*)
  DB_NOORDERCHK       =$0000002; (* Skip sort order/hashing check. *)
  DB_ORDERCHKONLY     =$0000004; (* Only perform the order check. *)
  DB_PR_PAGE          =$0000008; (* Show page contents (-da). *)
  DB_PR_RECOVERYTEST  =$0000010; (* Recovery test (-dr). *)
  DB_PRINTABLE        =$0000020; (* Use printable format for salvage. *)
  DB_SALVAGE          =$0000040; (* Salvage what looks like data. *)
  DB_UNREF            =$0000080; (* Report unreferenced pages. *)
(*
 * !!!
 * These must not go over $8000, or they will collide with the flags
 * used by __bam_vrfy_subtree.
 *)

(*
 * Flags private to DB->rep_set_transport's send callback.
 *)
  DB_REP_ANYWHERE       =$0000001; (* Message can be serviced anywhere. *)
  DB_REP_NOBUFFER       =$0000002; (* Do not buffer this message. *)
  DB_REP_PERMANENT      =$0000004; (* Important--app. may want to flush. *)
  DB_REP_REREQUEST      =$0000008; (* This msg already been requested. *)

(*******************************************************
 * Mutexes.
 *******************************************************)
type
  db_mutex_t = u_int32_t ;

(*
 * Flag arguments for DbEnv.mutex_alloc, DbEnv.is_alive and for the
 * DB_MUTEX structure.
 *)
const
  DB_MUTEX_ALLOCATED    =$01; (* Mutex currently allocated. *)
  DB_MUTEX_LOCKED       =$02; (* Mutex currently locked. *)
  DB_MUTEX_LOGICAL_LOCK =$04; (* Mutex backs a database lock. *)
  DB_MUTEX_PROCESS_ONLY =$08; (* Mutex private to a process. *)
  DB_MUTEX_SELF_BLOCK   =$10; (* Must be able to block self. *)

type
  PDB_MUTEX_STAT = ^DB_MUTEX_STAT;
  DB_MUTEX_STAT = record
    (* The following fields are maintained in the region's copy. *)
    st_mutex_align     : u_int32_t; (* Mutex alignment *)
    st_mutex_tas_spins : u_int32_t; (* Mutex test-and-set spins *)
    st_mutex_cnt       : u_int32_t;  (* Mutex count *)
    st_mutex_free      : u_int32_t; (* Available mutexes *)
    st_mutex_inuse     : u_int32_t; (* Mutexes in use *)
    st_mutex_inuse_max : u_int32_t; (* Maximum mutexes ever in use *)

    (* The following fields are filled-in from other places. *)
    st_region_wait     : u_int32_t; (* Region lock granted after wait. *)
    st_region_nowait   : u_int32_t; (* Region lock granted without wait. *)
    st_regsize         : roff_t;  (* Region size. *)
  end;

(* This is the length of the buffer passed to DB_ENV->thread_id_string() *)
const
  DB_THREADID_STRLEN =128;

(*******************************************************
 * Locking.
 *******************************************************)
  DB_LOCKVERSION =1;

  DB_FILE_ID_LEN =20; (* Unique file ID length. *)

(*
 * Deadlock detector modes; used in the DB_ENV structure to configure the
 * locking subsystem.
 *)
  DB_LOCK_NORUN    =0;
  DB_LOCK_DEFAULT  =1; (* Default policy. *)
  DB_LOCK_EXPIRE   =2; (* Only expire locks, no detection. *)
  DB_LOCK_MAXLOCKS =3; (* Select locker with max locks. *)
  DB_LOCK_MAXWRITE =4; (* Select locker with max writelocks. *)
  DB_LOCK_MINLOCKS =5; (* Select locker with min locks. *)
  DB_LOCK_MINWRITE =6; (* Select locker with min writelocks. *)
  DB_LOCK_OLDEST   =7; (* Select oldest locker. *)
  DB_LOCK_RANDOM   =8; (* Select random locker. *)
  DB_LOCK_YOUNGEST =9; (* Select youngest locker. *)

(* Flag values for lock_vec(), lock_get(). *)
  DB_LOCK_ABORT       =$001; (* Internal: Lock during abort. *)
  DB_LOCK_NOWAIT      =$002; (* Don't wait on unavailable lock. *)
  DB_LOCK_RECORD      =$004; (* Internal: record lock. *)
  DB_LOCK_SET_TIMEOUT =$008; (* Internal: set lock timeout. *)
  DB_LOCK_SWITCH      =$010; (* Internal: switch existing lock. *)
  DB_LOCK_UPGRADE     =$020; (* Internal: upgrade existing lock. *)

(*
 * Simple R/W lock modes and for multi-granularity intention locking.
 *
 * !!!
 * These values are NOT random, as they are used as an index into the lock
 * conflicts arrays, i.e., DB_LOCK_IWRITE must be == 3, and DB_LOCK_IREAD
 * must be == 4.
 *)
type
  db_lockmode_t =(
 DB_LOCK_NG=0,   (* Not granted. *)
 DB_LOCK_READ=1,   (* Shared/read. *)
 DB_LOCK_WRITE=2,  (* Exclusive/write. *)
 DB_LOCK_WAIT=3,   (* Wait for event *)
 DB_LOCK_IWRITE=4,  (* Intent exclusive/write. *)
 DB_LOCK_IREAD=5,  (* Intent to share/read. *)
 DB_LOCK_IWR=6,   (* Intent to read and write. *)
 DB_LOCK_READ_UNCOMMITTED=7, (* Degree 1 isolation. *)
 DB_LOCK_WWRITE=8  (* Was Written. *)
  );

(*
 * Request types.
 *)
type
 db_lockop_t =(
 DB_LOCK_DUMP=0,   (* Display held locks. *)
 DB_LOCK_GET=1,   (* Get the lock. *)
 DB_LOCK_GET_TIMEOUT=2,  (* Get lock with a timeout. *)
 DB_LOCK_INHERIT=3,  (* Pass locks to parent. *)
 DB_LOCK_PUT=4,   (* Release the lock. *)
 DB_LOCK_PUT_ALL=5,  (* Release locker's locks. *)
 DB_LOCK_PUT_OBJ=6,  (* Release locker's locks on obj. *)
 DB_LOCK_PUT_READ=7,  (* Release locker's read locks. *)
 DB_LOCK_TIMEOUT=8,  (* Force a txn to timeout. *)
 DB_LOCK_TRADE=9,  (* Trade locker ids on a lock. *)
 DB_LOCK_UPGRADE_WRITE=10 (* Upgrade writes for dirty reads. *)
  );

(*
 * Status of a lock.
 *)
type
  db_status_t = (
 DB_LSTAT_ABORTED=1,  (* Lock belongs to an aborted txn. *)
 DB_LSTAT_EXPIRED=2,  (* Lock has expired. *)
 DB_LSTAT_FREE=3,  (* Lock is unallocated. *)
 DB_LSTAT_HELD=4,  (* Lock is currently held. *)
 DB_LSTAT_PENDING=5,  (* Lock was waiting and has been
    * promoted; waiting for the owner
    * to run and upgrade it to held. *)
 DB_LSTAT_WAITING=6  (* Lock is on the wait queue. *)
  );

(* Lock statistics structure. *)
type
  PDB_LOCK_STAT = ^DB_LOCK_STAT;
  DB_LOCK_STAT = record
      st_id          : u_int32_t ;  (* Last allocated locker ID. *)
      st_cur_maxid   : u_int32_t ;  (* Current maximum unused ID. *)
      st_maxlocks    : u_int32_t ;  (* Maximum number of locks in table. *)
      st_maxlockers  : u_int32_t ; (* Maximum num of lockers in table. *)
      st_maxobjects  : u_int32_t ; (* Maximum num of objects in table. *)
      st_nmodes      : int   ;  (* Number of lock modes. *)
      st_nlocks      : u_int32_t ;  (* Current number of locks. *)
      st_maxnlocks   : u_int32_t ;  (* Maximum number of locks so far. *)
      st_nlockers    : u_int32_t ;  (* Current number of lockers. *)
      st_maxnlockers : u_int32_t ; (* Maximum number of lockers so far. *)
      st_nobjects    : u_int32_t ;  (* Current number of objects. *)
      st_maxnobjects : u_int32_t ; (* Maximum number of objects so far. *)
      st_nrequests   : u_int32_t ;  (* Number of lock gets. *)
      st_nreleases   : u_int32_t ;  (* Number of lock puts. *)
      st_nupgrade    : u_int32_t ;  (* Number of lock upgrades. *)
      st_ndowngrade  : u_int32_t ; (* Number of lock downgrades. *)
      st_lock_wait   : u_int32_t ;  (* Lock conflicts w/ subsequent wait *)
      st_lock_nowait : u_int32_t ; (* Lock conflicts w/o subsequent wait *)
      st_ndeadlocks  : u_int32_t ; (* Number of lock deadlocks. *)
      st_locktimeout : db_timeout_t ; (* Lock timeout. *)
      st_nlocktimeouts : u_int32_t ; (* Number of lock timeouts. *)
      st_txntimeout    : db_timeout_t ; (* Transaction timeout. *)
      st_ntxntimeouts  : u_int32_t ; (* Number of transaction timeouts. *)
      st_region_wait   : u_int32_t ; (* Region lock granted after wait. *)
      st_region_nowait : u_int32_t ; (* Region lock granted without wait. *)
      st_regsize       : roff_t   ;  (* Region size. *)
  end;

(*
 * DB_ILOCK --
 * Internal DB access method lock.
 *)
const
  DB_HANDLE_LOCK     =  1;
  DB_RECORD_LOCK     =  2;
  DB_PAGE_LOCK       =  3;

type
   DB_ILOCK = record
      pgno   : db_pgno_t ;   (* Page being locked. *)
      fileid : array [0..DB_FILE_ID_LEN-1] of u_int8_t;(* File id. *)
      _type  : u_int32_t ;   (* Type of lock. *)
  end;

(*
 * DB_LOCK --
 * The structure is allocated by the caller and filled in during a
 * lock_get request (or a lock_vec/DB_LOCK_GET).
 *)
type
  DB_LOCK =record
      off  : roff_t ;  (* Offset of the lock in the region *)
      ndx  : u_int32_t ;  (* Index of the object referenced by
    * this lock; used for locking. *)
      gen  : u_int32_t ;  (* Generation number of this lock. *)
      mode : db_lockmode_t;  (* mode of this lock. *)
  end;

(* Lock request structure. *)
type
  PDB_LOCKREQ = ^DB_LOCKREQ;
  DB_LOCKREQ = record
    op      : db_lockop_t;  (* Operation. *)
    mode    : db_lockmode_t; (* Requested mode. *)
    timeout : db_timeout_t ; (* Time to expire lock. *)
    obj     : ^DBT;  (* Object being locked. *)
    lock    : DB_LOCK ;  (* Lock returned. *)
  end;

(*******************************************************
 * Logging.
 *******************************************************)
const
  DB_LOGVERSION =12;  (* Current log version. *)
  DB_LOGOLDVER  =8;  (* Oldest log version supported. *)
  DB_LOGMAGIC   =$040988;

(* Flag values for DB_ENV->log_archive(). *)
  DB_ARCH_ABS   =$001;  (* Absolute pathnames. *)
  DB_ARCH_DATA  =$002;  (* Data files. *)
  DB_ARCH_LOG   =$004;  (* Log files. *)
  DB_ARCH_REMOVE=$008; (* Remove log files. *)

(* Flag values for DB_ENV->log_put(). *)
  DB_FLUSH           =$001; (* Flush data to disk (public). *)
  DB_LOG_CHKPNT      =$002; (* Flush supports a checkpoint *)
  DB_LOG_COMMIT      =$004; (* Flush supports a commit *)
  DB_LOG_NOCOPY      =$008; (* Don't copy data *)
  DB_LOG_NOT_DURABLE =$010; (* Do not log; keep in memory *)
  DB_LOG_WRNOSYNC    =$020; (* Write, don't sync log_put *)

(*
 * A DB_LSN has two parts, a fileid which identifies a specific file, and an
 * offset within that file.  The fileid is an unsigned 4-byte quantity that
 * uniquely identifies a file within the log directory -- currently a simple
 * counter inside the log.  The offset is also an unsigned 4-byte value.  The
 * log manager guarantees the offset is never more than 4 bytes by switching
 * to a new log file before the maximum length imposed by an unsigned 4-byte
 * offset is reached.
 *)
type
  PDB_LSN = ^DB_LSN;
  DB_LSN = record
      _file  : u_int32_t;  (* File ID. *)
      offset : u_int32_t ;  (* File offset. *)
  end;

(*
 * Application-specified log record types start at DB_user_BEGIN, and must not
 * equal or exceed DB_debug_FLAG.
 *
 * DB_debug_FLAG is the high-bit of the u_int32_t that specifies a log record
 * type.  If the flag is set, it's a log record that was logged for debugging
 * purposes only, even if it reflects a database change -- the change was part
 * of a non-durable transaction.
 *)
 const
   DB_user_BEGIN = 10000;
   DB_debug_FLAG = $80000000;

(*
 * DB_LOGC --
 * Log cursor.
 *)
const
  SK =$01; (* Log record came from disk. *)
  ED =$02; (* Log region already locked *)
  RR =$04; (* Turn-off error messages. *)


Type
  PDB_LOGC = ^DB_LOGC;
  DB_LOGC = record
    dbenv     : Pointer; //PDB_ENV  ;  (* Enclosing dbenv. *)

    c_fhp     : Pointer ; //^DB_FH  ;  (* File handle. *)
    c_lsn     :DB_LSN   ;  (* Cursor: LSN *)
    c_len     :u_int32_t ;  (* Cursor: record length *)
    c_prev    :u_int32_t ;  (* Cursor: previous record's offset *)

    c_dbt     :DBT   ;  (* Return DBT. *)
    p_lsn     :DB_LSN    ;  (* Persist LSN. *)
    p_version :u_int32_t ;  (* Persist version. *)

    bp        :^u_int8_t;   (* Allocated read buffer. *)
    bp_size   :u_int32_t ;  (* Read buffer length in bytes. *)
    bp_rlen   :u_int32_t ;  (* Read buffer valid data length. *)
    bp_lsn    :DB_LSN   ;  (* Read buffer first byte LSN. *)

    bp_maxrec :u_int32_t ;  (* Max record length in the log file. *)

    (* DB_LOGC PUBLIC HANDLE LIST BEGIN *)
    close      : function (_Logc : PDB_LOGC; P1 : u_int32_t):int; cdecl;
    get        : function  (_Logc : PDB_LOGC; Lsn : PDB_LSN; p1 : PDBT; p2 : u_int32_t):int; cdecl;
    version    : function (Logc : PDB_LOGC; var p1 : u_int32_t; p2 : u_int32_t):int; cdecl;
    (* DB_LOGC PUBLIC HANDLE LIST END *)

    flags      : u_int32_t ;
  end;

  (* Log statistics structure. *)
  PDB_LOG_STAT = ^DB_LOG_STAT;
  DB_LOG_STAT = record
    st_magic          : u_int32_t;  (* Log file magic number. *)
    st_version        : u_int32_t;  (* Log file version number. *)
    st_mode           : int   ;  (* Log file permissions mode. *)
    st_lg_bsize       : u_int32_t;  (* Log buffer size. *)
    st_lg_size        : u_int32_t;  (* Log file size. *)
    st_record         : u_int32_t;  (* Records entered into the log. *)
    st_w_bytes        : u_int32_t;  (* Bytes to log. *)
    st_w_mbytes       : u_int32_t;  (* Megabytes to log. *)
    st_wc_bytes       : u_int32_t;  (* Bytes to log since checkpoint. *)
    st_wc_mbytes      : u_int32_t;  (* Megabytes to log since checkpoint. *)
    st_wcount         : u_int32_t;  (* Total I/O writes to the log. *)
    st_wcount_fill    : u_int32_t; (* Overflow writes to the log. *)
    st_rcount         : u_int32_t;  (* Total I/O reads from the log. *)
    st_scount         : u_int32_t;  (* Total syncs to the log. *)
    st_region_wait    : u_int32_t; (* Region lock granted after wait. *)
    st_region_nowait  : u_int32_t; (* Region lock granted without wait. *)
    st_cur_file       : u_int32_t;  (* Current log file number. *)
    st_cur_offset     : u_int32_t;         (* Current log file offset. *)
    st_disk_file      : u_int32_t;  (* Known on disk log file number. *)
    st_disk_offset    : u_int32_t; (* Known on disk log file offset. *)
    st_regsize        : roff_t;  (* Region size. *)
    st_maxcommitperflush : u_int32_t ; (* Max number of commits in a flush. *)
    st_mincommitperflush : u_int32_t ; (* Min number of commits in a flush. *)
  end;

(*
 * We need to record the first log record of a transaction.  For user
 * defined logging this macro returns the place to put that information,
 * if it is need in rlsnp, otherwise it leaves it unchanged.  We also
 * need to track the last record of the transaction, this returns the
 * place to put that info.
 *)
  //DB_SET_TXN_LSNP(txn, blsnp, llsnp)  \
 //((txn)->set_txn_lsnp(txn, blsnp, llsnp))

(*******************************************************
 * Shared buffer cache (mpool).
 *******************************************************)
(* Flag values for DB_MPOOLFILE->get. *)
const
  DB_MPOOL_CREATE  =$001; (* Create a page. *)
  DB_MPOOL_DIRTY   =$002; (* Get page for an update. *)
  DB_MPOOL_EDIT    =$004; (* Modify without copying. *)
  DB_MPOOL_FREE    =$008; (* Free page if present. *)
  DB_MPOOL_LAST    =$010; (* Return the last page. *)
  DB_MPOOL_NEW     =$020; (* Create a new page. *)

(* Flag values for DB_MPOOLFILE->put, DB_MPOOLFILE->set. *)
  DB_MPOOL_DISCARD =$001; (* Don't cache the page. *)

(* Flags values for DB_MPOOLFILE->set_flags. *)
  DB_MPOOL_NOFILE  =$001; (* Never open a backing file. *)
  DB_MPOOL_UNLINK  =$002; (* Unlink the file on last close. *)

(* Priority values for DB_MPOOLFILE->set_priority. *)
type
  DB_CACHE_PRIORITY = (
 DB_PRIORITY_VERY_LOW=1,
 DB_PRIORITY_LOW=2,
 DB_PRIORITY_DEFAULT=3,
 DB_PRIORITY_HIGH=4,
 DB_PRIORITY_VERY_HIGH=5
  );

const
  MP_FILEID_SET   =$001;  (* Application supplied a file ID. *)
  MP_FLUSH        =$002;  (* Was opened to flush a buffer. *)
  MP_MULTIVERSION =$004;  (* Opened for multiversion access. *)
  MP_OPEN_CALLED  =$008;  (* File opened. *)
  MP_READONLY     =$010;  (* File is readonly. *)

type
  (* Per-process DB_MPOOLFILE information. *)
  PDB_MPOOLFILE = ^DB_MPOOLFILE;
  DB_MPOOLFILE = record
      fhp : pointer; //PDB_FH;   (* Underlying file handle. *)
      (*
     * !!!
     * The ref, pinref and q fields are protected by the region lock.
     *)
      ref : u_int32_t;   (* Reference count. *)

      pinref : u_int32_t;  (* Pinned block reference count. *)

      (*
     * !!!
     * Explicit representations of structures from queue.h.
     * TAILQ_ENTRY(DB_MPOOLFILE) q;
     *)
      q : record
            tqe_next : PDB_MPOOLFILE;
            tqe_prev : PDB_MPOOLFILE;
      end;    (* Linked list of DB_MPOOLFILE's. *)

      (*
     * !!!
     * The rest of the fields (with the exception of the MP_FLUSH flag)
     * are not thread-protected, even when they may be modified at any
     * time by the application.  The reason is the DB_MPOOLFILE handle
     * is single-threaded from the viewpoint of the application, and so
     * the only fields needing to be thread-protected are those accessed
     * by checkpoint or sync threads when using DB_MPOOLFILE structures
     * to flush buffers from the cache.
     *)
      dbenv : Pointer; //PDB_ENV;  (* Overlying DB_ENV. *)
      mfp : Pointer; //^MPOOLFILE;  (* Underlying MPOOLFILE. *)

      clear_len : u_int32_t; (* Cleared length on created pages. *)
      fileid : array [0..DB_FILE_ID_LEN-1] of u_int8_t;   (* Unique file ID. *)
   
      ftype : int;  (* File type. *)
      lsn_offset : int32_t; (* LSN offset in page. *)
      gbytes, bytes : u_int32_t; (* Maximum file size. *)
      pgcookie : ^DBT; (* Byte-string passed to pgin/pgout. *)
      priority : int32_t; (* Cache priority. *)

      addr : Pointer;  (* Address of mmap'd region. *)
      len : size_t;  (* Length of mmap'd region. *)

      config_flags : u_int32_t; (* Flags to DB_MPOOLFILE->set_flags. *)

      (* DB_MPOOLFILE PUBLIC HANDLE LIST BEGIN *)
      close : function (MpoolFile : PDB_MPOOLFILE ; p1 : u_int32_t):int; cdecl;
      get : function  (MpoolFile : PDB_MPOOLFILE ; var p1 : db_pgno_t ;  p2 : Pointer{DB_TXN}; p3 : u_int32_t; p4 : Pointer ):int; cdecl;
      open : function  (MpoolFile : PDB_MPOOLFILE ; const p1 : PChar; p2: u_int32_t; p3: int; p4: size_t):int; cdecl;
      put : function  (MpoolFile : PDB_MPOOLFILE ; p2 : Pointer; p3: u_int32_t):int; cdecl;
      _set : function   (MpoolFile : PDB_MPOOLFILE ; p2 : Pointer; p3: u_int32_t):int; cdecl;
      get_clear_len : function  (MpoolFile : PDB_MPOOLFILE ; var p2 : u_int32_t):int; cdecl;
      set_clear_len : function  (MpoolFile : PDB_MPOOLFILE ; p2 : u_int32_t):int; cdecl;
      get_fileid : function  (MpoolFile : PDB_MPOOLFILE ; var p2 : u_int8_t):int; cdecl;
      set_fileid : function  (MpoolFile : PDB_MPOOLFILE ; var p2 : u_int8_t):int; cdecl;
      get_flags : function  (MpoolFile : PDB_MPOOLFILE ; var p2 : u_int32_t):int; cdecl;
      set_flags : function  (MpoolFile : PDB_MPOOLFILE ; p2 : u_int32_t; p3 : int):int; cdecl;
      get_ftype : function  (MpoolFile : PDB_MPOOLFILE ; var p2 : int):int; cdecl;
      set_ftype : function  (MpoolFile : PDB_MPOOLFILE ; p2 : int):int; cdecl;
      get_lsn_offset : function  (MpoolFile : PDB_MPOOLFILE ; var p2 : int32_t):int; cdecl;
      set_lsn_offset : function  (MpoolFile : PDB_MPOOLFILE ; p2 : int32_t):int; cdecl;
      get_maxsize : function  (MpoolFile : PDB_MPOOLFILE ; var p2 : u_int32_t; var p3 : u_int32_t):int; cdecl;
      set_maxsize : function  (MpoolFile : PDB_MPOOLFILE ; p2 : u_int32_t; p3 : u_int32_t):int; cdecl;
      get_pgcookie : function  (MpoolFile : PDB_MPOOLFILE ; var p2 : DBT):int; cdecl;
      set_pgcookie : function  (MpoolFile : PDB_MPOOLFILE ; var p2 : DBT):int; cdecl;
      get_priority : function  (MpoolFile : PDB_MPOOLFILE ; var p2 : DB_CACHE_PRIORITY):int; cdecl;
      set_priority : function  (MpoolFile : PDB_MPOOLFILE ; p2 : DB_CACHE_PRIORITY):int; cdecl;
      sync : function  (MpoolFile : PDB_MPOOLFILE):int; cdecl;
      (* DB_MPOOLFILE PUBLIC HANDLE LIST END *)

      (*
     * MP_FILEID_SET, MP_OPEN_CALLED and MP_READONLY do not need to be
     * thread protected because they are initialized before the file is
     * linked onto the per-process lists, and never modified.
     *
     * MP_FLUSH is thread protected because it is potentially read/set by
     * multiple threads of control.
     *)
      flags : u_int32_t;
  end;

  (* Mpool statistics structure. *)
  PDB_MPOOL_STAT = ^DB_MPOOL_STAT;
  DB_MPOOL_STAT = record
      st_gbytes : u_int32_t ;  (* Total cache size: GB. *)
      st_bytes : u_int32_t ;  (* Total cache size: B. *)
      st_ncache : u_int32_t ;  (* Number of caches. *)
      st_regsize : roff_t   ; (* Region size. *)
      st_mmapsize : size_t   ; (* Maximum file size for mmap. *)
      st_maxopenfd : int   ; (* Maximum number of open fd's. *)
      st_maxwrite : int   ;  (* Maximum buffers to write. *)
      st_maxwrite_sleep : int   ; (* Sleep after writing max buffers. *)
      st_map : u_int32_t ;  (* Pages from mapped files. *)
      st_cache_hit : u_int32_t ; (* Pages found in the cache. *)
      st_cache_miss : u_int32_t ; (* Pages not found in the cache. *)
      st_page_create : u_int32_t ; (* Pages created in the cache. *)
      st_page_in : u_int32_t ;  (* Pages read in. *)
      st_page_out : u_int32_t ;  (* Pages written out. *)
      st_ro_evict : u_int32_t ;  (* Clean pages forced from the cache. *)
      st_rw_evict : u_int32_t ;  (* Dirty pages forced from the cache. *)
      st_page_trickle : u_int32_t ; (* Pages written by memp_trickle. *)
      st_pages : u_int32_t ;  (* Total number of pages. *)
      st_page_clean : u_int32_t ; (* Clean pages. *)
      st_page_dirty : u_int32_t ; (* Dirty pages. *)
      st_hash_buckets : u_int32_t ; (* Number of hash buckets. *)
      st_hash_searches : u_int32_t ; (* Total hash chain searches. *)
      st_hash_longest : u_int32_t ; (* Longest hash chain searched. *)
      st_hash_examined : u_int32_t ; (* Total hash entries searched. *)
      st_hash_nowait : u_int32_t ; (* Hash lock granted with nowait. *)
      st_hash_wait : u_int32_t ; (* Hash lock granted after wait. *)
      st_hash_max_nowait : u_int32_t ; (* Max hash lock granted with nowait. *)
      st_hash_max_wait : u_int32_t ; (* Max hash lock granted after wait. *)
      st_region_nowait : u_int32_t ; (* Region lock granted with nowait. *)
      st_region_wait : u_int32_t ; (* Region lock granted after wait. *)
      st_mvcc_frozen : u_int32_t ; (* Buffers frozen. *)
      st_mvcc_thawed : u_int32_t ; (* Buffers thawed. *)
      st_mvcc_freed : u_int32_t ; (* Frozen buffers freed. *)
      st_alloc : u_int32_t ;  (* Number of page allocations. *)
      st_alloc_buckets : u_int32_t ; (* Buckets checked during allocation. *)
      st_alloc_max_buckets : u_int32_t ;(* Max checked during allocation. *)
      st_alloc_pages : u_int32_t ; (* Pages checked during allocation. *)
      st_alloc_max_pages : u_int32_t ; (* Max checked during allocation. *)
      st_io_wait : u_int32_t ;  (* Thread waited on buffer I/O. *)
  end;

  (* Mpool file statistics structure. *)
  PDB_MPOOL_FSTAT = ^DB_MPOOL_FSTAT;
  DB_MPOOL_FSTAT = record
      file_name : PChar ;  (* File name. *)
      st_pagesize : u_int32_t ;  (* Page size. *)
      st_map : u_int32_t ;  (* Pages from mapped files. *)
      st_cache_hit : u_int32_t ; (* Pages found in the cache. *)
      st_cache_miss : u_int32_t ; (* Pages not found in the cache. *)
      st_page_create : u_int32_t ; (* Pages created in the cache. *)
      st_page_in : u_int32_t ;  (* Pages read in. *)
      st_page_out : u_int32_t ;  (* Pages written out. *)
  end;

(*******************************************************
 * Transactions and recovery.
 *******************************************************)
const
  DB_TXNVERSION = 1;

type
  db_recops = (
    DB_TXN_ABORT=0,   (* Public. *)
    DB_TXN_APPLY=1,   (* Public. *)
    DB_TXN_BACKWARD_ALLOC=2, (* Internal. *)
    DB_TXN_BACKWARD_ROLL=3,  (* Public. *)
    DB_TXN_FORWARD_ROLL=4,  (* Public. *)
    DB_TXN_OPENFILES=5,  (* Internal. *)
    DB_TXN_POPENFILES=6,  (* Internal. *)
    DB_TXN_PRINT=7   (* Public. *)
  );

(*
 * BACKWARD_ALLOC is used during the forward pass to pick up any aborted
 * allocations for files that were created during the forward pass.
 * The main difference between _ALLOC and _ROLL is that the entry for
 * the file not exist during the rollforward pass.
 *)
{
  DB_UNDO(op) ((op) == DB_TXN_ABORT ||   \
  (op) == DB_TXN_BACKWARD_ROLL || (op) == DB_TXN_BACKWARD_ALLOC)
  DB_REDO(op) ((op) == DB_TXN_FORWARD_ROLL || (op) == DB_TXN_APPLY)
}
const
  TXN_CHILDCOMMIT =$0001; (* Txn has committed. *)
  TXN_CDSGROUP  =$0002; (* CDS group handle. *)
  TXN_COMPENSATE =$0004; (* Compensating transaction. *)
  TXN_DEADLOCK  =$0008; (* Txn has deadlocked. *)
  TXN_LOCKTIMEOUT =$0010; (* Txn has a lock timeout. *)
  TXN_MALLOC  =$0020; (* Structure allocated by TXN system. *)
  TXN_NOSYNC  =$0040; (* Do not sync on prepare and commit. *)
  TXN_NOWAIT  =$0080; (* Do not wait on locks. *)
  TXN_PRIVATE  =$0100; (* Txn owned by cursor.. *)
  TXN_READ_COMMITTED =$0200; (* Txn has degree 2 isolation. *)
  TXN_READ_UNCOMMITTED =$0400; (* Txn has degree 1 isolation. *)
  TXN_RESTORED  =$0800; (* Txn has been restored. *)
  TXN_SNAPSHOT  =$1000; (* Snapshot Isolation. *)
  TXN_SYNC  =$2000; (* Write and sync on prepare/commit. *)
  TXN_WRITE_NOSYNC =$4000; (* Write only on prepare/commit. *)

type
  PDB_TXN = ^DB_TXN;
  DB_TXN = record
      mgrp : Pointer; // PDB_TXNMGR;  (* Pointer to transaction manager. *)
      parent : PDB_TXN; (* Pointer to transaction's parent. *)

      txnid : u_int32_t ;  (* Unique transaction id. *)
      name : Pchar;  (* Transaction name *)

      tid : db_threadid_t ;  (* Thread id for use in MT XA. *)
      td : Pointer;  (* Detail structure within region. *)
      lock_timeout : db_timeout_t ; (* Timeout for locks for this txn. *)
      expire : db_timeout_t ;  (* Time transaction expires. *)
      txn_list : Pointer; (* Undo information for parent. *)

      (*
     * !!!
     * Explicit representations of structures from queue.h.
     * TAILQ_ENTRY(__db_txn) links;
     * TAILQ_ENTRY(__db_txn) xalinks;
     *)
      links : record
        tqe_next: PDB_TXN;
        tqe_prev: PDB_TXN;
      end ;   (* Links transactions off manager. *)
      xalinks : record
        tqe_next: pdb_txn;
        tqe_prev: pdb_txn;
      end;   (* Links active XA transactions. *)
      
      (*
     * !!!
     * Explicit representations of structures from queue.h.
     * TAILQ_HEAD(__kids, __db_txn) kids;
     *)
      kids : record // __kids
        tqh_first: pdb_txn;
        tqh_last: pdb_txn;
      end;
      
      (*
     * !!!
     * Explicit representations of structures from queue.h.
     * TAILQ_HEAD(__events, __txn_event) events;
     *)
       events : record
         tqh_first: Pointer; //Ptxn_event ;
         tqh_last: Pointer; // Ptxn_event;
       end;

      (*
     * !!!
     * Explicit representations of structures from queue.h.
     * STAILQ_HEAD(__logrec, __txn_logrec) logs;
     *)
      logs :  record
        stqh_first: Pointer; //__txn_logrec *;
        stqh_last: Pointer; //__txn_logrec **;
      end;    (* Links deferred events. *)
      
      (*
     * !!!
     * Explicit representations of structures from queue.h.
     * TAILQ_ENTRY(__db_txn) klinks;
     *)
      klinks : record
        tqe_next : pdb_txn;
        tqe_prev : pdb_txn;
      end;

      api_internal : Pointer ;  (* C++ API private. *)
      xml_internal : Pointer ;  (* XML API private. *)

      cursors : u_int32_t ; (* Number of cursors open for txn *)
      
     (* DB_TXN PUBLIC HANDLE LIST BEGIN *)
     abort : function (Txn : PDB_TXN):int; cdecl;
     commit : function (Txn : PDB_TXN; flags : u_int32_t=0):int; cdecl;
     discard : function (Txn : PDB_TXN; flags : u_int32_t=0):int; cdecl;
     get_name : function (Txn : PDB_TXN; var p2 : PChar):int; cdecl;
     id : function (Txn : PDB_TXN):u_int32_t; cdecl;
     prepare : function (Txn : PDB_TXN; var p2 : u_int8_t):int; cdecl;
     set_name : function (Txn : PDB_TXN; const PChar ):int; cdecl;
     set_timeout : function (Txn : PDB_TXN; p2 : db_timeout_t; p3 : u_int32_t):int; cdecl;
     (* DB_TXN PUBLIC HANDLE LIST END *)

     (* DB_TXN PRIVATE HANDLE LIST BEGIN *)
     set_txn_lsnp : procedure (Txn : PDB_TXN; var p2 : PDB_LSN; var p3 : PDB_LSN ); cdecl;
     (* DB_TXN PRIVATE HANDLE LIST END *)

     flags : u_int32_t ;
  end;

const
  TXN_SYNC_FLAGS = (TXN_SYNC or TXN_NOSYNC or TXN_WRITE_NOSYNC);

(*
 * Structure used for two phase commit interface.  Berkeley DB support for two
 * phase commit is compatible with the X/Open XA interface.
 *
 * The XA   XIDDATASIZE defines the size of a global transaction ID.  We
 * have our own version here (for name space reasons) which must have the same
 * value.
 *)
const
  DB_XIDDATASIZE =128;
type
  DB_PREPLIST = record
    Txn : PDB_TXN;
    gid : array [0..DB_XIDDATASIZE-1] of u_int8_t;
  end;

(* Transaction statistics structure. *)
const
  TXN_ABORTED    =1;
  TXN_COMMITTED  =2;
  TXN_PREPARED   =3;
  TXN_RUNNING    =4;

  TXN_XA_ABORTED    =1;
  TXN_XA_DEADLOCKED =2;
  TXN_XA_ENDED      =3;
  TXN_XA_PREPARED   =4;
  TXN_XA_STARTED    =5;
  TXN_XA_SUSPENDED  =6;
type
  PDB_TXN_ACTIVE = ^DB_TXN_ACTIVE;
  DB_TXN_ACTIVE = record
    txnid     : u_int32_t;       (* Transaction ID *)
    parentid  : u_int32_t;       (* Transaction ID of parent *)
    pid       : pid_t;           (* Process owning txn ID *)
    tid       : db_threadid_t ;  (* Thread owning txn ID *)

    lsn       : DB_LSN;          (* LSN when transaction began *)

    read_lsn  : DB_LSN;          (* Read LSN for MVCC *)
    mvcc_ref  : u_int32_t;       (* MVCC reference count *)

    status    : u_int32_t;       (* Status of the transaction *)

    xa_status : u_int32_t;       (* XA status *)

    xid       : array [0..DB_XIDDATASIZE-1] of u_int8_t; (* Global transaction ID *)
    name      : array [0..50] of char;  (* 50 bytes of name, nul termination *)
  end;

type
  PDB_TXN_STAT = ^DB_TXN_STAT;
  DB_TXN_STAT = record
    st_last_ckp      : DB_LSN;    (* lsn of the last checkpoint *)
    st_time_ckp      : time_t;    (* time of last checkpoint *)
    st_last_txnid    : u_int32_t; (* last transaction id given out *)
    st_maxtxns       : u_int32_t; (* maximum txns possible *)
    st_naborts       : u_int32_t; (* number of aborted transactions *)
    st_nbegins       : u_int32_t; (* number of begun transactions *)
    st_ncommits      : u_int32_t; (* number of committed transactions *)
    st_nactive       : u_int32_t; (* number of active transactions *)
    st_nsnapshot     : u_int32_t; (* number of snapshot transactions *)
    st_nrestores     : u_int32_t; (* number of restored transactions
                                     after recovery. *)
    st_maxnactive    : u_int32_t; (* maximum active transactions *)
    st_maxnsnapshot  : u_int32_t; (* maximum snapshot transactions *)
    st_txnarray      : PDB_TXN_ACTIVE; (* array of active transactions *)
    st_region_wait   : u_int32_t; (* Region lock granted after wait. *)
    st_region_nowait : u_int32_t; (* Region lock granted without wait. *)
    st_regsize       : roff_t;    (* Region size. *)
  end;

(*******************************************************
 * Replication.
 *******************************************************)
(* Special, out-of-band environment IDs. *)
const
  DB_EID_BROADCAST =-1;
  DB_EID_INVALID   =-2;

(* rep_config flag values. *)
const
  DB_REP_CONF_BULK        =$0001; (* Bulk transfer. *)
  DB_REP_CONF_DELAYCLIENT =$0002; (* Delay client synchronization. *)
  DB_REP_CONF_NOAUTOINIT  =$0004; (* No automatic client init. *)
  DB_REP_CONF_NOWAIT      =$0008; (* Don't wait, return error. *)

(*
 * Operation code values for rep_start and/or repmgr_start.  Just one of the
 * following values should be passed in the flags parameter.  (If we ever need
 * additional, independent bit flags for these methods, we can start allocating
 * them from the high-order byte of the flags word, as we currently do elsewhere
 * for DB_AFTER through DB_WRITELOCK and DB_AUTO_COMMIT, etc.)
 *)
const
  DB_REP_CLIENT            =1;
  DB_REP_ELECTION          =2;
  DB_REP_FULL_ELECTION     =3;
  DB_REP_MASTER            =4;

(* Acknowledgement policies. *)
  DB_REPMGR_ACKS_ALL       =1;
  DB_REPMGR_ACKS_ALL_PEERS =2;
  DB_REPMGR_ACKS_NONE      =3;
  DB_REPMGR_ACKS_ONE       =4;
  DB_REPMGR_ACKS_ONE_PEER  =5;
  DB_REPMGR_ACKS_QUORUM    =6;

(* Replication Framework timeout configuration values. *)
  DB_REP_ACK_TIMEOUT       =1;
  DB_REP_ELECTION_TIMEOUT  =2;
  DB_REP_ELECTION_RETRY    =3;
  DB_REP_CONNECTION_RETRY  =4;

(* Event notification types. *)
  DB_EVENT_NO_SUCH_EVENT   =0; (* out-of-band sentinel value *)
  DB_EVENT_PANIC           =1;
  DB_EVENT_REP_CLIENT      =2;
  DB_EVENT_REP_MASTER      =3;
  DB_EVENT_REP_NEWMASTER   =4;
  DB_EVENT_REP_STARTUPDONE =5;
  DB_EVENT_WRITE_FAILED    =6;

(* Flag value for repmgr_add_remote_site. *)
  DB_REPMGR_PEER          =$01;

(* Replication Manager site status. *)
const
  DB_REPMGR_CONNECTED    =$01;
  DB_REPMGR_DISCONNECTED =$02;

type
  PDB_REPMGR_SITE = ^DB_REPMGR_SITE;
  DB_REPMGR_SITE = record
    eid  : int;
    host : PChar;
    port : u_int;

    status:u_int32_t ;
  end;

(* Replication statistics. *)
  PDB_REP_STAT = ^DB_REP_STAT;
  DB_REP_STAT = record
    (* !!!
   * Many replication statistics fields cannot be protected by a mutex
   * without an unacceptable performance penalty, since most message
   * processing is done without the need to hold a region-wide lock.
   * Fields whose comments end with a '+' may be updated without holding
   * the replication or log mutexes (as appropriate), and thus may be
   * off somewhat (or, on unreasonable architectures under unlucky
   * circumstances, garbaged).
   *)
   st_status        : u_int32_t ;  (* Current replication status. *)
   st_next_lsn      : DB_LSN ;     (* Next LSN to use or expect. *)
   st_waiting_lsn   : DB_LSN ;     (* LSN we're awaiting, if any. *)
   st_next_pg       : db_pgno_t ;  (* Next pg we expect. *)
   st_waiting_pg    : db_pgno_t ;  (* pg we're awaiting, if any. *)

   st_dupmasters    : u_int32_t ; (* # of times a duplicate master
                                     condition was detected.+ *)
   st_env_id        : int ;       (* Current environment ID. *)
   st_env_priority  : int ;       (* Current environment priority. *)
   st_bulk_fills    : u_int32_t ; (* Bulk buffer fills. *)
   st_bulk_overflows: u_int32_t ; (* Bulk buffer overflows. *)
   st_bulk_records  : u_int32_t ; (* Bulk records stored. *)
   st_bulk_transfers: u_int32_t ; (* Transfers of bulk buffers. *)
   st_client_rerequests: u_int32_t ; (* Number of forced rerequests. *)
   st_client_svc_req: u_int32_t ; (* Number of client service requests
                                     received by this client. *)
   st_client_svc_miss: u_int32_t ; (* Number of client service requests
                                      missing on this client. *)
   st_gen           : u_int32_t ;  (* Current generation number. *)
   st_egen          : u_int32_t ;  (* Current election gen number. *)
   st_log_duplicated: u_int32_t ; (* Log records received multiply.+ *)
   st_log_queued    : u_int32_t ; (* Log records currently queued.+ *)
   st_log_queued_max: u_int32_t ; (* Max. log records queued at once.+ *)
   st_log_queued_total: u_int32_t ; (* Total # of log recs. ever queued.+ *)
   st_log_records   : u_int32_t ; (* Log records received and put.+ *)
   st_log_requested : u_int32_t ; (* Log recs. missed and requested.+ *)
   st_master        : int ;   (* Env. ID of the current master. *)
   st_master_changes: u_int32_t ; (* # of times we've switched masters. *)
   st_msgs_badgen   : u_int32_t ; (* Messages with a bad generation #.+ *)
   st_msgs_processed: u_int32_t ; (* Messages received and processed.+ *)
   st_msgs_recover  : u_int32_t ; (* Messages ignored because this site
           was a client in recovery.+ *)
   st_msgs_send_failures: u_int32_t ;(* # of failed message sends.+ *)
   st_msgs_sent     : u_int32_t ;  (* # of successful message sends.+ *)
   st_newsites      : u_int32_t ;  (* # of NEWSITE msgs. received.+ *)
   st_nsites        : int ;   (* Current number of sites we will
           assume during elections. *)
   st_nthrottles    : u_int32_t ; (* # of times we were throttled. *)
   st_outdated      : u_int32_t ;  (* # of times we detected and returned
           an OUTDATED condition.+ *)
   st_pg_duplicated : u_int32_t ; (* Pages received multiply.+ *)
   st_pg_records    : u_int32_t ; (* Pages received and stored.+ *)
   st_pg_requested  : u_int32_t ; (* Pages missed and requested.+ *)
   st_startup_complete: u_int32_t; (* Site completed client sync-up. *)
   st_txns_applied  : u_int32_t ; (* # of transactions applied.+ *)

    (* Elections generally. *)
   st_elections     : u_int32_t ; (* # of elections held.+ *)
   st_elections_won : u_int32_t ; (* # of elections won by this site.+ *)

    (* Statistics about an in-progress election. *)
   st_election_cur_winner: int ; (* Current front-runner. *)
   st_election_gen   : u_int32_t; (* Election generation number. *)
   st_election_lsn   : DB_LSN ;  (* Max. LSN of current winner. *)
   st_election_nsites: int ;     (* # of 'registered voters'. *)
   st_election_nvotes: int ;     (* # of 'registered voters' needed. *)
   st_election_priority: int ;   (* Current election priority. *)
   st_election_status: int ;     (* Current election status. *)
   st_election_tiebreaker: u_int32_t ; (* Election tiebreaker value. *)
   st_election_votes : int ;           (* Votes received in this round. *)
   st_election_sec   : u_int32_t ;     (* Last election time seconds. *)
   st_election_usec  : u_int32_t ;     (* Last election time useconds. *)
  end;

(*******************************************************
 * Sequences.
 *******************************************************)
(*
 * The storage record for a sequence.
 *)
const
  DB_SEQ_DEC       =$00000001; (* Decrement sequence. *)
  DB_SEQ_INC       =$00000002; (* Increment sequence. *)
  DB_SEQ_RANGE_SET =$00000004; (* Range set (internal). *)
  DB_SEQ_WRAP      =$00000008; (* Wrap sequence at min/max. *)
  DB_SEQ_WRAPPED   =$00000010; (* Just wrapped (internal). *)

type
  PDB_SEQUENCE_STAT = ^DB_SEQUENCE_STAT;
  DB_SEQUENCE_STAT = record
    st_wait       : u_int32_t ; (* Sequence lock granted w/o wait. *)
    st_nowait     : u_int32_t ; (* Sequence lock granted after wait. *)
    st_current    : db_seq_t  ; (* Current value in db. *)
    st_value      : db_seq_t  ; (* Current cached value. *)
    st_last_value : db_seq_t  ; (* Last cached value. *)
    st_min        : db_seq_t  ; (* Minimum value. *)
    st_max        : db_seq_t  ; (* Maximum value. *)
    st_cache_size : int32_t   ; (* Cache size. *)
    st_flags      : u_int32_t ; (* Flag value. *)
  end;


  PDB_SEQ_RECORD = ^DB_SEQ_RECORD;
  DB_SEQ_RECORD = record
    seq_version : u_int32_t ; (* Version size/number. *)
    flags       : u_int32_t ;  (* Flags. *)
    seq_value   : db_seq_t ; (* Current value. *)
    seq_max     : db_seq_t ; (* Max permitted. *)
    seq_min     : db_seq_t ; (* Min permitted. *)
  end;

(*
 * Handle for a sequence object.
 *)
  PDB_SEQUENCE = ^DB_SEQUENCE;
  DB_SEQUENCE = record
    seq_dbp: Pointer;//PDB; (* DB handle for this sequence. *)
    mtx_seq :db_mutex_t ; (* Mutex if sequence is threaded. *)
    seq_rp:PDB_SEQ_RECORD; (* Pointer to current data. *)
    seq_record:DB_SEQ_RECORD ; (* Data from DB_SEQUENCE. *)
    seq_cache_size:int32_t  ; (* Number of values cached. *)
    seq_last_value:db_seq_t ; (* Last value cached. *)
    seq_key:DBT  ; (* DBT pointing to sequence key. *)
    seq_data:DBT  ; (* DBT pointing to seq_record. *)

    (* API-private structure: used by C++ and Java. *)
    api_internal:Pointer ;

    (* DB_SEQUENCE PUBLIC HANDLE LIST BEGIN *)
    close         : function (P1: PDB_SEQUENCE; p2:u_int32_t):int; cdecl;
    get           : function (p1: PDB_SEQUENCE; Txn : PDB_TXN; p3: int32_t; var p4 : db_seq_t; p5 :u_int32_t):int; cdecl;
    get_cachesize : function (p1: PDB_SEQUENCE; var p2 : int32_t):int; cdecl;
    get_db        : function (p1: PDB_SEQUENCE; var p2 : Pointer{PDB}):int; cdecl;
    get_flags     : function (p1: PDB_SEQUENCE; var p2 : u_int32_t):int; cdecl;
    get_key       : function (p1: PDB_SEQUENCE; var p2 : DBT):int; cdecl;
    get_range     : function (p1: PDB_SEQUENCE; var p2 : db_seq_t; var p3 : db_seq_t):int; cdecl;
    initial_value : function (p1: PDB_SEQUENCE; p2 : db_seq_t):int; cdecl;
    open          : function (p1: PDB_SEQUENCE; var Txn : DB_TXN; var p3: DBT; p4: u_int32_t):int; cdecl;
    remove        : function (p1: PDB_SEQUENCE; var Txn : DB_TXN; p3: u_int32_t):int; cdecl;
    set_cachesize : function (p1: PDB_SEQUENCE; p2: int32_t):int; cdecl;
    set_flags     : function (p1: PDB_SEQUENCE; p2: u_int32_t):int; cdecl;
    set_range     : function (p1: PDB_SEQUENCE; p2: db_seq_t; p3: db_seq_t):int; cdecl;
    stat          : function (p1: PDB_SEQUENCE; var p2 : PDB_SEQUENCE_STAT; p3: u_int32_t):int; cdecl;
    stat_print    : function (var p1: PDB_SEQUENCE; p2 : u_int32_t):int; cdecl;
    (* DB_SEQUENCE PUBLIC HANDLE LIST END *)
  end;


(*******************************************************
 * Access methods.
 *******************************************************)
type
  TDBTYPE = ( DB_BTREE=1,
              DB_HASH=2,
              DB_RECNO=3,
              DB_QUEUE=4,
              DB_UNKNOWN=5   (* Figure it out on open. *)
             );

const
  DB_RENAMEMAGIC  =$030800; (* File has been renamed. *)

  DB_BTREEVERSION =9;  (* Current btree version. *)
  DB_BTREEOLDVER  =8;  (* Oldest btree version supported. *)
  DB_BTREEMAGIC   =$053162;

  DB_HASHVERSION  =8;  (* Current hash version. *)
  DB_HASHOLDVER   =7;  (* Oldest hash version supported. *)
  DB_HASHMAGIC    =$061561;

  DB_QAMVERSION   =4;  (* Current queue version. *)
  DB_QAMOLDVER    =3;  (* Oldest queue version supported. *)
  DB_QAMMAGIC     =$042253;

  DB_SEQUENCE_VERSION =2;  (* Current sequence version. *)
  DB_SEQUENCE_OLDVER  =1;  (* Oldest sequence version supported. *)

(*
 * DB access method and cursor operation values.  Each value is an operation
 * code to which additional bit flags are added.
 *)
const
  DB_AFTER  = 1; (* c_put() *)
  DB_APPEND  = 2; (* put() *)
  DB_BEFORE  = 3; (* c_put() *)
  DB_CONSUME  = 4; (* get() *)
  DB_CONSUME_WAIT = 5; (* get() *)
  DB_CURRENT  = 6; (* c_get(), c_put(), DB_LOGC->get() *)
  DB_FIRST  = 7; (* c_get(), DB_LOGC->get() *)
  DB_GET_BOTH  = 8; (* get(), c_get() *)
  DB_GET_BOTHC  = 9; (* c_get() (internal) *)
  DB_GET_BOTH_RANGE =10; (* get(), c_get() *)
  DB_GET_RECNO  =11; (* c_get() *)
  DB_JOIN_ITEM  =12; (* c_get(); do not do primary lookup *)
  DB_KEYFIRST  =13; (* c_put() *)
  DB_KEYLAST  =14; (* c_put() *)
  DB_LAST  =15; (* c_get(), DB_LOGC->get() *)
  DB_NEXT  =16; (* c_get(), DB_LOGC->get() *)
  DB_NEXT_DUP  =17; (* c_get() *)
  DB_NEXT_NODUP  =18; (* c_get() *)
  DB_NODUPDATA  =19; (* put(), c_put() *)
  DB_NOOVERWRITE =20; (* put() *)
  DB_NOSYNC  =21; (* close() *)
  DB_POSITION  =22; (* c_dup() *)
  DB_PREV  =23; (* c_get(), DB_LOGC->get() *)
  DB_PREV_NODUP  =24; (* c_get(), DB_LOGC->get() *)
  DB_SET  =25; (* c_get(), DB_LOGC->get() *)
  DB_SET_LOCK_TIMEOUT =26; (* set_timout() *)
  DB_SET_RANGE  =27; (* c_get() *)
  DB_SET_RECNO  =28; (* get(), c_get() *)
  DB_SET_TXN_NOW =29; (* set_timout() (internal) *)
  DB_SET_TXN_TIMEOUT =30; (* set_timout() *)
  DB_UPDATE_SECONDARY =31; (* c_get(), c_del() (internal) *)
  DB_WRITECURSOR =32; (* cursor() *)
  DB_WRITELOCK  =33; (* cursor() (internal) *)

(* This has to change when the max opcode hits 255. *)
  DB_OPFLAGS_MASK =$000000ff; (* Mask for operations flags. *)

(*
 * Masks for flags that can be OR'd into DB access method and cursor
 * operation values.  Three top bits have already been taken:
 *
 * DB_AUTO_COMMIT $02000000
 * DB_READ_COMMITTED $04000000
 * DB_READ_UNCOMMITTED $08000000
 *)
const
  DB_MULTIPLE     =$10000000; (* Return multiple data values. *)
  DB_MULTIPLE_KEY =$20000000; (* Return multiple data/key pairs. *)
  DB_RMW          =$40000000; (* Acquire write lock immediately. *)

(*
 * DB (user visible) error return codes.
 *
 * !!!
 * We don't want our error returns to conflict with other packages where
 * possible, so pick a base error value that's hopefully not common.  We
 * document that we own the error name space from -30,800 to -30,999.
 *)
(* DB (public) error return codes. *)
const
  DB_BUFFER_SMALL =(-30999);(* User memory too small for return. *)
  DB_DONOTINDEX  =(-30998);(* 'Null' return from 2ndary callbk. *)
  DB_KEYEMPTY  =(-30997);(* Key/data deleted or never created. *)
  DB_KEYEXIST  =(-30996);(* The key/data pair already exists. *)
  DB_LOCK_DEADLOCK =(-30995);(* Deadlock. *)
  DB_LOCK_NOTGRANTED =(-30994);(* Lock unavailable. *)
  DB_LOG_BUFFER_FULL =(-30993);(* In-memory log buffer full. *)
  DB_NOSERVER  =(-30992);(* Server panic return. *)
  DB_NOSERVER_HOME =(-30991);(* Bad home sent to server. *)
  DB_NOSERVER_ID =(-30990);(* Bad ID sent to server. *)
  DB_NOTFOUND  =(-30989);(* Key/data pair not found (EOF). *)
  DB_OLD_VERSION =(-30988);(* Out-of-date version. *)
  DB_PAGE_NOTFOUND =(-30987);(* Requested page not found. *)
  DB_REP_DUPMASTER =(-30986);(* There are two masters. *)
  DB_REP_HANDLE_DEAD =(-30985);(* Rolled back a commit. *)
  DB_REP_HOLDELECTION =(-30984);(* Time to hold an election. *)
  DB_REP_IGNORE  =(-30983);(* This msg should be ignored.*)
  DB_REP_ISPERM  =(-30982);(* Cached not written perm written.*)
  DB_REP_JOIN_FAILURE =(-30981);(* Unable to join replication group. *)
  DB_REP_LOCKOUT =(-30980);(* API/Replication lockout now. *)
  DB_REP_NEWMASTER =(-30979);(* We have learned of a new master. *)
  DB_REP_NEWSITE =(-30978);(* New site entered system. *)
  DB_REP_NOTPERM =(-30977);(* Permanent log record not written. *)
  DB_REP_UNAVAIL =(-30976);(* Site cannot currently be reached. *)
  DB_RUNRECOVERY =(-30975);(* Panic return. *)
  DB_SECONDARY_BAD =(-30974);(* Secondary index corrupt. *)
  DB_VERIFY_BAD  =(-30973);(* Verify failed; bad format. *)
  DB_VERSION_MISMATCH =(-30972);(* Environment version mismatch. *)

(* DB (private) error return codes. *)
const
  DB_ALREADY_ABORTED =(-30899);
  DB_DELETED  =(-30898);(* Recovery file marked deleted. *)
  DB_NEEDSPLIT  =(-30897);(* Page needs to be split. *)
  DB_REP_BULKOVF =(-30896);(* Rep bulk buffer overflow. *)
  DB_REP_EGENCHG =(-30895);(* Egen changed while in election. *)
  DB_REP_LOGREADY =(-30894);(* Rep log ready for recovery. *)
  DB_REP_PAGEDONE =(-30893);(* This page was already done. *)
  DB_SURPRISE_KID =(-30892);(* Child commit where parent
        didn't know it was a parent. *)
  DB_SWAPBYTES  =(-30891);(* Database needs byte swapping. *)
  DB_TIMEOUT  =(-30890);(* Timed out waiting for election. *)
  DB_TXN_CKP  =(-30889);(* Encountered ckp record in log. *)
  DB_VERIFY_FATAL =(-30888);(* DB->verify cannot proceed. *)

const
  DB_AM_CHKSUM  =$00000001; (* Checksumming *)
  DB_AM_CL_WRITER =$00000002; (* Allow writes in client replica *)
  DB_AM_COMPENSATE =$00000004; (* Created by compensating txn *)
  DB_AM_CREATED  =$00000008; (* Database was created upon open *)
  DB_AM_CREATED_MSTR =$00000010; (* Encompassing file was created *)
  DB_AM_DBM_ERROR =$00000020; (* Error in DBM/NDBM database *)
  DB_AM_DELIMITER =$00000040; (* Variable length delimiter set *)
  DB_AM_DISCARD  =$00000080; (* Discard any cached pages *)
  DB_AM_DUP  =$00000100; (* DB_DUP *)
  DB_AM_DUPSORT  =$00000200; (* DB_DUPSORT *)
  DB_AM_ENCRYPT  =$00000400; (* Encryption *)
  DB_AM_FIXEDLEN =$00000800; (* Fixed-length records *)
  DB_AM_INMEM  =$00001000; (* In-memory; no sync on close *)
  DB_AM_INORDER  =$00002000; (* DB_INORDER *)
  DB_AM_IN_RENAME =$00004000; (* File is being renamed *)
  DB_AM_NOT_DURABLE =$00008000; (* Do not log changes *)
  DB_AM_OPEN_CALLED =$00010000; (* DB->open called *)
  DB_AM_PAD  =$00020000; (* Fixed-length record pad *)
  DB_AM_PGDEF  =$00040000; (* Page size was defaulted *)
  DB_AM_RDONLY  =$00080000; (* Database is readonly *)
  DB_AM_READ_UNCOMMITTED=$00100000; (* Support degree 1 isolation *)
  DB_AM_RECNUM  =$00200000; (* DB_RECNUM *)
  DB_AM_RECOVER  =$00400000; (* DB opened by recovery routine *)
  DB_AM_RENUMBER =$00800000; (* DB_RENUMBER *)
  DB_AM_REVSPLITOFF =$01000000; (* DB_REVSPLITOFF *)
  DB_AM_SECONDARY =$02000000; (* Database is a secondary index *)
  DB_AM_SNAPSHOT =$04000000; (* DB_SNAPSHOT *)
  DB_AM_SUBDB  =$08000000; (* Subdatabases supported *)
  DB_AM_SWAP  =$10000000; (* Pages need to be byte-swapped *)
  DB_AM_TXN  =$20000000; (* Opened in a transaction *)
  DB_AM_VERIFYING =$40000000; (* DB handle is in the verifier *)

(* Database handle. *)
const
  DB_LOGFILEID_INVALID = -1;

  DB_ASSOC_IMMUTABLE_KEY    = $00000001; (* Secondary key is immutable. *)

  DB_OK_BTREE =$01;
  DB_OK_HASH  =$02;
  DB_OK_QUEUE =$04;
  DB_OK_RECNO =$08;
type
  PDB = ^TDB;

  TSysGetMem = function (Size: Integer): Pointer; cdecl;
  TSysFreeMem = function (P: Pointer): Integer; cdecl;
  TSysReallocMem = function (P: Pointer; Size: Integer): Pointer; cdecl;


  TAssociateFunc = function (db : PDB; const key : PDBT; const Data : PDBT ; Key2 : PDBT ):longint; cdecl;
  TErrCall   = procedure (const Env : pointer{PDB_ENV}; const errpfx: PChar; const Msg : PChar ); cdecl;
  TMsgCall   = procedure (const Env : Pointer{PDB_ENV}; const p2 :PChar );
  TbtCompare = function  (P1 : PDB ; const aDBT : PDBT; const aDBT2 : PDBT): int; cdecl;
  TFeedBack  = procedure (P1 : PDB; p2 : int; p3 : int); cdecl;
  TH_Hash    = function  (P1 : PDB ; const p2 : Pointer; p3 : u_int32_t):u_int32_t; cdecl;
  TPanicCall = procedure (Env : Pointer {PDB_ENV}; P2 : int); cdecl;
  TDump      = function  (p1 : Pointer; const p2 : Pointer ):int; cdecl;


  TDB = record
    (*******************************************************
     * Public: owned by the application.
     *******************************************************)
    pgsize:u_int32_t ;  (* Database logical page size. *)

    (* Callbacks. *)
    db_append_recno : function (DB : PDB; var p2 : DBT; p3: db_recno_t):int; cdecl;
    db_feedbac: procedure (db : PDB; p2 : int; p3 : int); cdecl;
    dup_compare : function (db : PDB; const p2 : PDBT; const p3 : PDBT):int; cdecl;

    app_private:Pointer ;  (* Application-private handle. *)

    (*******************************************************
   * Private: owned by DB.
   *******************************************************)
    dbenv: Pointer; //PDB_ENV;   (* Backing environment. *)

    _type:TDBTYPE  ;   (* DB access method type. *)

    mpf:PDB_MPOOLFILE;  (* Backing buffer pool. *)

    mutex:db_mutex_t ;  (* Synchronization for free threading *)

    fname, dname :PChar ;  (* File/database passed to DB->open. *)
    open_flags:u_int32_t ;  (* Flags passed to DB->open. *)

    fileid: array [0..DB_FILE_ID_LEN-1] of u_int8_t;(* File's unique ID for locking. *)

    adj_fileid:u_int32_t ;  (* File's unique ID for curs. adj. *)

    log_filename: Pointer; //^FNAME;  (* File's naming info for logging. *)

    meta_pgno:db_pgno_t ;  (* Meta page number *)
    lid:u_int32_t ;   (* Locker id for handle locking. *)
    cur_lid:u_int32_t ;  (* Current handle lock holder. *)
    associate_lid:u_int32_t ; (* Locker id for DB->associate call. *)
    handle_lock:DB_LOCK  ;  (* Lock held on this handle. *)

    cl_id:u_int  ;   (* RPC: remote client id. *)

    timestamp:time_t  ;  (* Handle timestamp for replication. *)
    fid_gen:u_int32_t ;  (* Rep generation number for fids. *)

    (*
     * Returned data memory for DB->get() and friends.
     *)
    my_rskey:DBT  ;  (* Secondary key. *)
    my_rkey:DBT  ;  (* [Primary] key. *)
    my_rdata:DBT  ;  (* Data. *)

   (*
    * !!!
    * Some applications use DB but implement their own locking outside of
    * DB.  If they're using fcntl(2) locking on the underlying database
    * file, and we open and close a file descriptor for that file, we will
    * discard their locks.  The DB_FCNTL_LOCKING flag to DB->open is an
    * undocumented interface to support this usage which leaves any file
    * descriptors we open until DB->close.  This will only work with the
    * DB->open interface and simple caches, e.g., creating a transaction
    * thread may open/close file descriptors this flag doesn't protect.
    * Locking with fcntl(2) on a file that you don't own is a very, very
    * unsafe thing to do.  'Nuff said.
    *)
    saved_open_fhp: Pointer;//PDB_FH; (* Saved file handle. *)

   (*
    * Linked list of DBP's, linked from the DB_ENV, used to keep track
    * of all open db handles for cursor adjustment.
    *
    * !!!
    * Explicit representations of structures from queue.h.
    * TAILQ_ENTRY(__db) dblistlinks;
    *)
    dblistlinks : record
      tqe_next : PDB;
      tqe_prev : PDB;
    end;

    (*
    * Cursor queues.
    *
    * !!!
    * Explicit representations of structures from queue.h.
    * TAILQ_HEAD(__cq_fq, __dbc) free_queue;
    * TAILQ_HEAD(__cq_aq, __dbc) active_queue;
    * TAILQ_HEAD(__cq_jq, __dbc) join_queue;
    *)
    free_queue : record
      tqh_first: Pointer; //Pdbc ;
      tqh_last: Pointer; //Pdbc ;
    end;
    active_queue : record
      tqh_first: Pointer; //Pdbc ;
      tqh_last: Pointer; //Pdbc ;
    end;
    join_queue : record
      tqh_first: Pointer; //Pdbc;
      tqh_last: Pointer; //Pdbc;
    end;
    
    (*
    * Secondary index support.
    *
    * Linked list of secondary indices -- set in the primary.
    *
    * !!!
    * Explicit representations of structures from queue.h.
    * LIST_HEAD(s_secondaries, __db);
    *)
    s_secondaries : record
      lh_first: Pdb;
    end;

    (*
    * List entries for secondaries, and reference count of how
    * many threads are updating this secondary (see __db_c_put).
    *
    * !!!
    * Note that these are synchronized by the primary's mutex, but
    * filled in in the secondaries.
    *
    * !!!
    * Explicit representations of structures from queue.h.
    * LIST_ENTRY(__db) s_links;
    *)
    s_links: record
      le_next:Pdb;
      le_prev:Pdb;
    end;
    s_refcnt: u_int32_t ;

    (* Secondary callback and free functions -- set in the secondary. *)
    s_callback : function  (p1 : PDB; const p2 : PDBT; const p3 : PDBT; p4 : PDBT):int; cdecl;

    (* Reference to primary -- set in the secondary. *)
    s_primary:PDB;


    (* Flags passed to associate -- set in the secondary. *)
    s_assoc_flags:u_int32_t ;

    (* API-private structure: used by DB 1.85, C++, Java, Perl and Tcl *)
    api_internal:Pointer ;
    
    (* Subsystem-private structure. *)
    bt_internal:Pointer ;  (* Btree/Recno access method. *)
    h_internal:Pointer ;  (* Hash access method. *)
    q_internal:Pointer ;  (* Queue access method. *)
    xa_internal:Pointer ;  (* XA. *)
    
    (* DB PUBLIC HANDLE LIST BEGIN *)
    associate : function (p1 : PDB; Txn : PDB_TXN; p3: PDB; func : TAssociateFunc; p4: u_int32_t):int; cdecl;
    close     : function (p1 : PDB; p2: u_int32_t= 0):int; cdecl;
    compact   : function (p1 : PDB; Txn : PDB_TXN; aDBT : PDBT; aDBT2 : PDBT; p5 : Pointer{PDB_COMPACT}; p6: u_int32_t; aDBT3 : PDBT):int; cdecl;
    cursor    : function (p1 : PDB; Txn : PDB_TXN; var cursor {PDBC}; flags : u_int32_t):int; cdecl;
    del       : function (p1 : PDB; Txn : PDB_TXN; aDBT : PDBT; Flags : u_int32_t=0):int; cdecl;
    err       : procedure(db  : PDB; _para2:longint; _para3:Pchar; args:array of const); cdecl;
    errx      : procedure(db  : PDB; _para2:Pchar; args:array of const); cdecl;
    fd        : function (P1 : PDB ; var p2 : int):int; cdecl;
    get       : function (P1 : PDB ; Txn : PDB_TXN; aDBT : PDBT; aDBT2 : PDBT; p5 : u_int32_t):int; cdecl;

    get_bt_minkey     : function  (P1 : PDB ; var p2 : u_int32_t ):int; cdecl;
    get_byteswapped   : function  (P1 : PDB ; var p2 : int):int; cdecl;
    get_cachesize     : function  (P1 : PDB ; var p2 : u_int32_t ; var p3 : u_int32_t ; var p4 : int):int; cdecl;
    get_dbname        : function  (P1 : PDB ; var p2 : PChar; var p3 : PChar):int; cdecl;
    get_encrypt_flags : function  (P1 : PDB ; var p2 : u_int32_t ):int; cdecl;
    get_env           : Function  (p1 : PDB): pointer{PDB_ENV}; cdecl;
    get_errfile       : procedure (P1 : PDB ; var aFILE : pointer); cdecl;
    get_errpfx        : procedure (P1 : PDB ; var p2 : PChar); cdecl;
    get_flags         : function  (P1 : PDB ; var p : u_int32_t ):int; cdecl;
    get_h_ffactor     : function  (P1 : PDB ; var p : u_int32_t ):int; cdecl;
    get_h_nelem       : function  (P1 : PDB ; var p : u_int32_t ):int; cdecl;
    get_lorder        : function  (P1 : PDB ; var p2 : int):int; cdecl;
    get_mpf           : function  (p1 : PDB):PDB_MPOOLFILE; cdecl;
    get_msgfile       : procedure (P1 : PDB ; var aFILE : pointer); cdecl;
    get_open_flags    : function  (P1 : PDB ; var p : u_int32_t ):int; cdecl;
    get_pagesize      : function  (P1 : PDB ; var p : u_int32_t ):int; cdecl;
    get_q_extentsize  : function  (P1 : PDB ; var p : u_int32_t ):int; cdecl;
    get_re_delim      : function  (P1 : PDB ; var p2 : int):int; cdecl;
    get_re_len        : function  (P1 : PDB ; var p : u_int32_t ):int; cdecl;
    get_re_pad        : function  (P1 : PDB ; var p2 : int):int; cdecl;
    get_re_source     : function  (P1 : PDB ; var p2 : PChar):int; cdecl;
    get_transactional : function  (p1 : PDB):int; cdecl;
    get_type          : function  (P1 : PDB ; p2 : TDBTYPE):int; cdecl;
    join              : function  (P1 : PDB ; var p2 : Pointer{PDBC}; var p3 : Pointer{PDBC}; p4 : u_int32_t):int; cdecl;
    key_range         : function  (P1 : PDB ; Txn : PDB_TXN; aDBT : PDBT; p3: Pointer {DB_KEY_RANGE}; p4 : u_int32_t):int; cdecl;
    open              : function  (P1 : PDB ; Txn : PDB_TXN; const p3 : PChar; const p4: PChar; p5: TDBTYPE; p6: u_int32_t; p7 :int):int; cdecl;
    pget              : function  (P1 : PDB ; Txn : PDB_TXN; aDBT : PDBT; aDBT2 : PDBT; aDBT3 : PDBT; p6: u_int32_t):int; cdecl;
    put               : function  (P1 : PDB ; Txn : PDB_TXN; aDBT : PDBT; aDBT2 : PDBT; flags : u_int32_t):int; cdecl;
    remove            : function  (P1 : PDB ; const P2: PChar; const p3 :PChar; flags:  u_int32_t=0):int; cdecl;
    rename            : function  (P1 : PDB ; const p2 : PChar; const p3: PChar; const p4 : PChar; p5 :  u_int32_t):int; cdecl;
    set_alloc         : function  (db : PDB; _para2: TSysGetMem; _para3: TSysReallocMem; _para4:TSysFreeMem):longint; cdecl; // Pprocedure (_para1:size_t)
    set_append_recno  : function  (db  : PDB; _para2: Pointer):longint; cdecl; //para2 : function (db  : PDB; _para2:PDBT; _para3:db_recno_t):longint
    set_bt_compare    : function  (P1 : PDB ; p2 : TBtCompare):int; cdecl;
    set_bt_minkey     : function  (P1 : PDB ; p2: u_int32_t):int; cdecl;
    set_bt_prefix     : function  (P1 : PDB ; p2: Pointer{function (P1 : PDB ; const aDBT : PDBT; const DBT *):size_t}):int; cdecl;
    set_cachesize     : function  (P1 : PDB ; gbytes : u_int32_t; bytes : u_int32_t; ncache :  int):int; cdecl;
    set_dup_compare   : function  (P1 : PDB ; p2 : Pointer{function (P1 : PDB ; const aDBT : PDBT; const DBT *):int}):int; cdecl;
    set_encrypt       : function  (P1 : PDB ; const PChar , u_int32_t):int; cdecl;
    set_errcall       : procedure (P1 : PDB ; p2 : TErrCall); cdecl;
    set_errfile       : procedure (P1 : PDB ; aFILE : Pointer); cdecl;
    set_errpfx        : procedure (P1 : PDB ; const PChar ); cdecl;
    set_feedback      : function  (P1 : PDB ; p2 : TFeedBack):int; cdecl;
    set_flags         : function  (P1 : PDB ; p2 : u_int32_t):int; cdecl;
    set_h_ffactor     : function  (P1 : PDB ; p2 : u_int32_t):int; cdecl;
    set_h_hash        : function  (P1 : PDB ; p2 : TH_Hash):int; cdecl;
    set_h_nelem       : function  (P1 : PDB ; p2 : u_int32_t):int; cdecl;
    set_lorder        : function  (P1 : PDB ; p2 : int):int; cdecl;
    set_msgcall       : procedure (P1 : PDB ; p2 : TMsgCall); cdecl;
    set_msgfile       : procedure (P1 : PDB ; aFILE : pointer); cdecl;
    set_pagesize      : function  (P1 : PDB ; p2 : u_int32_t):int; cdecl;
    set_paniccall     : function  (P1 : PDB ; p2 : TPanicCall):int; cdecl;
    set_q_extentsize  : function  (P1 : PDB ; p2 : u_int32_t):int; cdecl;
    set_re_delim      : function  (P1 : PDB ; p2 : int):int; cdecl;
    set_re_len        : function  (P1 : PDB ; p2 : u_int32_t):int; cdecl;
    set_re_pad        : function  (P1 : PDB ; p2 : int):int; cdecl;
    set_re_source     : function  (P1 : PDB ; const p2: PChar ):int; cdecl;
    stat              : function  (P1 : PDB ; Txn : PDB_TXN; sp : Pointer; p4 : u_int32_t):int; cdecl;
    stat_print        : function  (P1 : PDB ; p2 : u_int32_t):int; cdecl;
    sync              : function  (P1 : PDB ; Flags : u_int32_t=0):int; cdecl;
    truncate          : function  (P1 : PDB ; Txn : DB_TXN; var p3 : u_int32_t; p4: u_int32_t):int; cdecl;
    upgrade           : function  (P1 : PDB ; const p2: PChar; p3 : u_int32_t):int; cdecl;
    verify            : function  (P1 : PDB ; const p2 : PChar; const p3 : PChar; aFILE : Pointer; p5 :u_int32_t):int; cdecl;
    (* DB PUBLIC HANDLE LIST END *)

    (* DB PRIVATE HANDLE LIST BEGIN *)
    dump          : function (P1 : PDB ; const p2 : PChar; p3 : TDump; p4 : Pointer; p5 : int; p6: int):int; cdecl;
    db_am_remove  : function (P1 : PDB ; Txn : PDB_TXN; const p3: PChar; const p4 : PChar ):int; cdecl;
    db_am_rename  : function (P1 : PDB ; Txn : PDB_TXN; const p3: PChar; const p4 : PChar; const p5: PChar ):int; cdecl;
    (* DB PRIVATE HANDLE LIST END *)

    (*
    * Never called; these are a place to save function pointers
    * so that we can undo an associate.
    *)
    stored_get   : function (P1 : PDB ; Txn : PDB_TXN; aDBT : PDBT; aDBT2 : PDBT; p5: u_int32_t):int; cdecl;
    stored_close : function (P1 : PDB ; p: u_int32_t):int; cdecl;

    am_ok: u_int32_t ;  (* Legal AM choices. *)

    (*
    * This field really ought to be an AM_FLAG, but we have
    * have run out of bits.  If/when we decide to split up
    * the flags, we can incorporate it.
    *)
    preserve_fid : int  ;  (* Do not free fileid on close. *)

    orig_flags   : u_int32_t ;     (* Flags at  open, for refresh *)
    flags        : u_int32_t ;
  end;

(*
 * Macros for bulk get.  These are only intended for the C API.
 * For C++, use DbMultiple*Iterator.
 *)
 {
  DB_MULTIPLE_INIT(pointer, dbt)     \
 (pointer = (u_int8_t *)(dbt)->data +    \
     (dbt)->ulen - sizeof(u_int32_t))
  DB_MULTIPLE_NEXT(pointer, dbt, retdata, retdlen)  \
 do begin        \
  if (*((u_int32_t *)(pointer)) == (u_int32_t)-1) begin \
   retdata = NULL;     \
   pointer = NULL;     \
   break;      \
  end       \
  retdata = (u_int8_t *)     \
      (dbt)->data + *(u_int32_t *)(pointer);  \
  (pointer) = (u_int32_t *)(pointer) - 1;   \
  retdlen = *(u_int32_t *)(pointer);   \
  (pointer) = (u_int32_t *)(pointer) - 1;   \
  if (retdlen == 0 &&     \
      retdata == (u_int8_t *)(dbt)->data)   \
   retdata = NULL;     \
 end while (0)
  DB_MULTIPLE_KEY_NEXT(pointer, dbt, retkey, retklen, retdata, retdlen) \
 do begin        \
  if (*((u_int32_t *)(pointer)) == (u_int32_t)-1) begin \
   retdata = NULL;     \
   retkey = NULL;     \
   pointer = NULL;     \
   break;      \
  end       \
  retkey = (u_int8_t *)     \
      (dbt)->data + *(u_int32_t *)(pointer);  \
  (pointer) = (u_int32_t *)(pointer) - 1;   \
  retklen = *(u_int32_t *)(pointer);   \
  (pointer) = (u_int32_t *)(pointer) - 1;   \
  retdata = (u_int8_t *)     \
      (dbt)->data + *(u_int32_t *)(pointer);  \
  (pointer) = (u_int32_t *)(pointer) - 1;   \
  retdlen = *(u_int32_t *)(pointer);   \
  (pointer) = (u_int32_t *)(pointer) - 1;   \
 end while (0)

  DB_MULTIPLE_RECNO_NEXT(pointer, dbt, recno, retdata, retdlen)   \
 do begin        \
  if (*((u_int32_t *)(pointer)) == (u_int32_t)0) begin \
   recno = 0;     \
   retdata = NULL;     \
   pointer = NULL;     \
   break;      \
  end       \
  recno = *(u_int32_t *)(pointer);   \
  (pointer) = (u_int32_t *)(pointer) - 1;   \
  retdata = (u_int8_t *)     \
      (dbt)->data + *(u_int32_t *)(pointer);  \
  (pointer) = (u_int32_t *)(pointer) - 1;   \
  retdlen = *(u_int32_t *)(pointer);   \
  (pointer) = (u_int32_t *)(pointer) - 1;   \
 end while (0)
  }
(*******************************************************
 * Access method cursors.
 *******************************************************)
(*
 * DBC_DONTLOCK and DBC_RECOVER are used during recovery and transaction
 * abort.  If a transaction is being aborted or recovered then DBC_RECOVER
 * will be set and locking and logging will be disabled on this cursor.  If
 * we are performing a compensating transaction (e.g. free page processing)
 * then DB_DONTLOCK will be set to inhibit locking, but logging will still
 * be required. DB_DONTLOCK is also used if the whole database is locked.
 *)
const
  DBC_ACTIVE  =$0001; (* Cursor in use. *)
  DBC_DONTLOCK  =$0002; (* Don't lock on this cursor. *)
  DBC_MULTIPLE  =$0004; (* Return Multiple data. *)
  DBC_MULTIPLE_KEY =$0008; (* Return Multiple keys and data. *)
  DBC_OPD  =$0010; (* Cursor references off-page dups. *)
  DBC_OWN_LID  =$0020; (* Free lock id on destroy. *)
  DBC_READ_COMMITTED =$0040; (* Cursor has degree 2 isolation. *)
  DBC_READ_UNCOMMITTED =$0080; (* Cursor has degree 1 isolation. *)
  DBC_RECOVER  =$0100; (* Recovery cursor; don't log/lock. *)
  DBC_RMW  =$0200; (* Acquire write flag in read op. *)
  DBC_TRANSIENT  =$0400; (* Cursor is transient. *)
  DBC_WRITECURSOR =$0800; (* Cursor may be used to write (CDB). *)
  DBC_WRITER  =$1000; (* Cursor immediately writing (CDB). *)

type
  PDBC = ^DBC;
  DBC = record
    dbp: PDB;   (* Related DB access method. *)
    txn: PDB_TXN;   (* Associated transaction. *)

    (*
     * Active/free cursor queues.
     *
     * !!!
     * Explicit representations of structures from queue.h.
     * TAILQ_ENTRY(__dbc) links;
     *)
     links : record
       tqe_next: PDBC;
       tqe_prev: PDBC;
     end;
     
      (*
     * The DBT *'s below are used by the cursor routines to return
     * data to the user when DBT flags indicate that DB should manage
     * the returned memory.  They point at a DBT containing the buffer
     * and length that will be used, and 'belonging' to the handle that
     * should 'own' this memory.  This may be a 'my_*' field of this
     * cursor--the default--or it may be the corresponding field of
     * another cursor, a DB handle, a join cursor, etc.  In general, it
     * will be whatever handle the user originally used for the current
     * DB interface call.
     *)
     rskey: PDBT;  (* Returned secondary key. *)
     rkey: PDBT;   (* Returned [primary] key. *)
     rdata: PDBT;  (* Returned data. *)

     my_rskey: DBT   ;  (* Space for returned secondary key. *)
     my_rkey: DBT   ;  (* Space for returned [primary] key. *)
     my_rdata: DBT   ;  (* Space for returned data. *)

     lref: Pointer ;   (* Reference to default locker. *)
     locker: u_int32_t ;  (* Locker for this operation. *)
     lock_dbt: DBT   ;  (* DBT referencing lock. *)
     lock: DB_ILOCK ;  (* Object to be locked. *)
     mylock: DB_LOCK   ;  (* CDB lock held on this cursor. *)

     cl_id: u_int   ;  (* Remote client id. *)

     dbtype: TDBTYPE   ;  (* Cursor type. *)

     internal: Pointer;//PDBC_INTERNAL;  (* Access method private. *)

      (* DBC PUBLIC HANDLE LIST BEGIN *)
      c_close  : function  (p1 : PDBC ):int; cdecl;
      c_count  : function  (p1 : PDBC ; var p2 : db_recno_t; p3 : u_int32_t):int; cdecl;
      c_del    : function  (p1 : PDBC ; flags : u_int32_t = 0):int; cdecl;
      c_dup    : function  (p1 : PDBC ; var p2 : PDBC; p3 : u_int32_t):int; cdecl;
      c_get    : function  (p1 : PDBC ; aDBT : PDBT; aDBT2 : PDBT; flags: u_int32_t):int; cdecl;
      c_pget   : function  (p1 : PDBC ; aDBT : PDBT; aDBT2 : PDBT; aDBT3 : PDBT; p5: u_int32_t):int; cdecl;
      c_put    : function  (p1 : PDBC ; aDBT : PDBT; aDBT2 : PDBT; flags: u_int32_t):int; cdecl;
      (* DBC PUBLIC HANDLE LIST END *)

      (* DBC PRIVATE HANDLE LIST BEGIN *)
      c_am_bulk   : function  (p1 : PDBC ; aDBT : PDBT; p3: u_int32_t):int; cdecl;
      c_am_close  : function  (p1 : PDBC ; p2: db_pgno_t; var p3: int ):int; cdecl;
      c_am_del    : function  (p1 : PDBC ):int; cdecl;
      c_am_destroy: function  (p1 : PDBC ):int; cdecl;
      c_am_get    : function  (p1 : PDBC ; aDBT : PDBT; aDBT2 : PDBT; p4: u_int32_t; var p5: db_pgno_t ):int; cdecl;
      c_am_put    : function  (p1 : PDBC ; aDBT : PDBT; aDBT2 : PDBT; p4: u_int32_t; var p5: db_pgno_t ):int; cdecl;
      c_am_writelock: function(p1 : PDBC ):int; cdecl;
      (* DBC PRIVATE HANDLE LIST END *)
     
      flags: u_int32_t ;
  end;

(* Key range statistics structure *)
type
  DB_KEY_RANGE = record
    less:double ;
    equal:double ;
    greater:double ;
  end;

(* Btree/Recno statistics structure. *)
type
  PDB_BTREE_STAT = ^DB_BTREE_STAT;
  DB_BTREE_STAT = record
    bt_magic      : u_int32_t; (* Magic number. *)
    bt_version    : u_int32_t; (* Version number. *)
    bt_metaflags  : u_int32_t; (* Metadata flags. *)
    bt_nkeys      : u_int32_t; (* Number of unique keys. *)
    bt_ndata      : u_int32_t; (* Number of data items. *)
    bt_pagesize   : u_int32_t; (* Page size. *)
    bt_minkey     : u_int32_t; (* Minkey value. *)
    bt_re_len     : u_int32_t; (* Fixed-length record length. *)
    bt_re_pad     : u_int32_t; (* Fixed-length record pad. *)
    bt_levels     : u_int32_t; (* Tree levels. *)
    bt_int_pg     : u_int32_t; (* Internal pages. *)
    bt_leaf_pg    : u_int32_t; (* Leaf pages. *)
    bt_dup_pg     : u_int32_t; (* Duplicate pages. *)
    bt_over_pg    : u_int32_t; (* Overflow pages. *)
    bt_empty_pg   : u_int32_t; (* Empty pages. *)
    bt_free       : u_int32_t; (* Pages on the free list. *)
    bt_int_pgfree : u_int32_t; (* Bytes free in internal pages. *)
    bt_leaf_pgfree: u_int32_t; (* Bytes free in leaf pages. *)
    bt_dup_pgfree : u_int32_t; (* Bytes free in duplicate pages. *)
    bt_over_pgfree: u_int32_t; (* Bytes free in overflow pages. *)
  end;

type
  DB_COMPACT = record
    (* Input Parameters. *)
    compact_fillpercent: u_int32_t ; (* Desired fillfactor: 1-100 *)
    compact_timeout: db_timeout_t ; (* Lock timeout. *)
    compact_pages: u_int32_t ;  (* Max pages to process. *)
    (* Output Stats. *)
    compact_pages_free: u_int32_t ; (* Number of pages freed. *)
    compact_pages_examine: u_int32_t ; (* Number of pages examine. *)
    compact_levels: u_int32_t ;  (* Number of levels removed. *)
    compact_deadlock: u_int32_t ; (* Number of deadlocks. *)
    compact_pages_truncated: db_pgno_t ; (* Pages truncated to OS. *)
    (* Internal. *)
    compact_truncate: db_pgno_t ; (* Page number for truncation *)
  end;

(* Hash statistics structure. *)
type
  DB_HASH_STAT = record
    hash_magic    : u_int32_t; (* Magic number. *)
    hash_version  : u_int32_t; (* Version number. *)
    hash_metaflags: u_int32_t; (* Metadata flags. *)
    hash_nkeys    : u_int32_t; (* Number of unique keys. *)
    hash_ndata    : u_int32_t; (* Number of data items. *)
    hash_pagesize : u_int32_t; (* Page size. *)
    hash_ffactor  : u_int32_t; (* Fill factor specified at create. *)
    hash_buckets  : u_int32_t; (* Number of hash buckets. *)
    hash_free     : u_int32_t; (* Pages on the free list. *)
    hash_bfree    : u_int32_t; (* Bytes free on bucket pages. *)
    hash_bigpages : u_int32_t; (* Number of big key/data pages. *)
    hash_big_bfree: u_int32_t; (* Bytes free on big item pages. *)
    hash_overflows: u_int32_t; (* Number of overflow pages. *)
    hash_ovfl_free: u_int32_t; (* Bytes free on ovfl pages. *)
    hash_dup      : u_int32_t; (* Number of dup pages. *)
    hash_dup_free : u_int32_t; (* Bytes free on duplicate pages. *)
  end;

(* Queue statistics structure. *)
type
   DB_QUEUE_STAT = record
    qs_magic       : u_int32_t; (* Magic number. *)
    qs_version     : u_int32_t; (* Version number. *)
    qs_metaflags   : u_int32_t; (* Metadata flags. *)
    qs_nkeys       : u_int32_t; (* Number of unique keys. *)
    qs_ndata       : u_int32_t; (* Number of data items. *)
    qs_pagesize    : u_int32_t; (* Page size. *)
    qs_extentsize  : u_int32_t; (* Pages per extent. *)
    qs_pages       : u_int32_t; (* Data pages. *)
    qs_re_len      : u_int32_t; (* Fixed-length record length. *)
    qs_re_pad      : u_int32_t; (* Fixed-length record pad. *)
    qs_pgfree      : u_int32_t; (* Bytes free in data pages. *)
    qs_first_recno : u_int32_t; (* First not deleted record. *)
    qs_cur_recno   : u_int32_t; (* Next available record number. *)
  end;

(*******************************************************
 * Environment.
 *******************************************************)
const
  DB_REGION_MAGIC = $120897; (* Environment magic number. *)

const
  DB_USERCOPY_GETDATA =$0001;
  DB_USERCOPY_SETDATA =$0002;

  DB_VERB_DEADLOCK    =$0001; (* Deadlock detection information. *)
  DB_VERB_RECOVERY    =$0002; (* Recovery information. *)
  DB_VERB_REGISTER    =$0004; (* Dump waits-for table. *)
  DB_VERB_REPLICATION =$0008; (* Replication information. *)
  DB_VERB_WAITSFOR    =$0010; (* Dump waits-for table. *)

  DB_TEST_ELECTINIT   = 1; (* after __rep_elect_init *)
  DB_TEST_ELECTVOTE1  = 2; (* after sending VOTE1 *)
  DB_TEST_POSTDESTROY = 3; (* after destroy op *)
  DB_TEST_POSTLOG     = 4; (* after logging all pages *)
  DB_TEST_POSTLOGMETA = 5; (* after logging meta in btree *)
  DB_TEST_POSTOPEN    = 6; (* after __os_open *)
  DB_TEST_POSTSYNC    = 7; (* after syncing the log *)
  DB_TEST_PREDESTROY  = 8; (* before destroy op *)
  DB_TEST_PREOPEN     = 9; (* before __os_open *)
  DB_TEST_RECYCLE     = 10; (* test rep and txn_recycle *)
  DB_TEST_SUBDB_LOCKS = 11; (* subdb locking tests *)

  DB_ENV_AUTO_COMMIT  =$00000001; (* DB_AUTO_COMMIT. *)
  DB_ENV_CDB          =$00000002; (* DB_INIT_CDB. *)
  DB_ENV_CDB_ALLDB    =$00000004; (* CDB environment wide locking. *)
  DB_ENV_CREATE       =$00000008; (* DB_CREATE set. *)
  DB_ENV_DBLOCAL      =$00000010; (* Environment for a private DB. *)
  DB_ENV_DIRECT_DB    =$00000020; (* DB_DIRECT_DB set. *)
  DB_ENV_DIRECT_LOG   =$00000040; (* DB_DIRECT_LOG set. *)
  DB_ENV_DSYNC_DB     =$00000080; (* DB_DSYNC_DB set. *)
  DB_ENV_DSYNC_LOG    =$00000100; (* DB_DSYNC_LOG set. *)
  DB_ENV_FATAL        =$00000200; (* Doing fatal recovery in env. *)
  DB_ENV_LOCKDOWN     =$00000400; (* DB_LOCKDOWN set. *)
  DB_ENV_LOG_AUTOREMOVE =$00000800; (* DB_LOG_AUTOREMOVE set. *)
  DB_ENV_LOG_INMEMORY   =$00001000; (* DB_LOG_INMEMORY set. *)
  DB_ENV_MULTIVERSION   =$00002000; (* DB_MULTIVERSION set. *)
  DB_ENV_NOLOCKING      =$00004000; (* DB_NOLOCKING set. *)
  DB_ENV_NOMMAP         =$00008000; (* DB_NOMMAP set. *)
  DB_ENV_NOPANIC        =$00010000; (* Okay if panic set. *)
  DB_ENV_OPEN_CALLED    =$00020000; (* DB_ENV->open called. *)
  DB_ENV_OVERWRITE      =$00040000; (* DB_OVERWRITE set. *)
  DB_ENV_PRIVATE        =$00080000; (* DB_PRIVATE set. *)
  DB_ENV_REGION_INIT    =$00100000; (* DB_REGION_INIT set. *)
  DB_ENV_RPCCLIENT      =$00200000; (* DB_RPCCLIENT set. *)
  DB_ENV_RPCCLIENT_GIVEN=$00400000; (* User-supplied RPC client struct *)
  DB_ENV_SYSTEM_MEM     =$00800000; (* DB_SYSTEM_MEM set. *)
  DB_ENV_THREAD         =$01000000; (* DB_THREAD set. *)
  DB_ENV_TIME_NOTGRANTED=$02000000; (* DB_TIME_NOTGRANTED set. *)
  DB_ENV_TXN_NOSYNC     =$04000000; (* DB_TXN_NOSYNC set. *)
  DB_ENV_TXN_SNAPSHOT   =$08000000; (* DB_TXN_SNAPSHOT set. *)
  DB_ENV_TXN_WRITE_NOSYNC=$10000000; (* DB_TXN_WRITE_NOSYNC set. *)
  DB_ENV_YIELDCPU       =$20000000; (* DB_YIELDCPU set. *)

(* Database Environment handle. *)
type
  Pmutex_iq = ^Tmutex_iq; 
  Tmutex_iq = record
                alloc_id:int   ; (* Allocation ID argument *)
                flags:u_int32_t ; (* Flags argument *)
              end;   (* Initial mutexes queue *)



  PDB_ENV = ^DB_ENV;
  DB_ENV = record
    (*******************************************************
   * Public: owned by the application.
   *******************************************************)
     (* Error message callback. *)
     db_errcall     : procedure (const Env : PDB_ENV; const p2: PChar; const p3 : PChar ); cdecl;
     db_errfile     : Pointer;//FILE *; (* Error message file stream. *)
     db_errpfx      : Pchar; (* Error message prefix. *)

     db_msgfile     : Pointer; //FILE *; (* Statistics message file stream. *)
     (* Statistics message callback. *)
     db_msgcall     : procedure  (const Env : PDB_ENV; const PChar ); cdecl;

     (* Other Callbacks. *)
     db_feedback    : procedure (Env : PDB_ENV; p2 : int; p3: int); cdecl;
     db_paniccall   : procedure (Env : PDB_ENV; p2: int); cdecl;
     db_event_func  : procedure  (Env : PDB_ENV; p2: u_int32_t; p3: Pointer ); cdecl;

     (* App-specified alloc functions. *)
     db_malloc      : function  (p1: size_t):Pointer; cdecl;
     db_realloc     : function  (p1: Pointer; p2 : size_t):Pointer; cdecl;
     db_free        : procedure (P1: Pointer ); cdecl;

     (* Application callback to copy data to/from a custom data source. *)
     dbt_usercopy   : function (aDBT : PDBT; p2: u_int32_t; p3: Pointer; p4: u_int32_t; p5 : u_int32_t):int; cdecl;

      (*
     * Currently, the verbose list is a bit field with room for 32
     * entries.  There's no reason that it needs to be limited, if
     * there are ever more than 32 entries, convert to a bit array.
     *)
     verbose        : u_int32_t  ; (* Verbose output. *)

     app_private    : Pointer ; (* Application-private handle. *)

     (* User-specified recovery dispatch. *)
     app_dispatch   : function (Env : PDB_ENV; aDBT : PDBT; Lsn : PDB_LSN; p4: db_recops):int; cdecl;


      (* Mutexes. *)
     mutex_align    : u_int32_t ; (* Mutex alignment *)
     mutex_cnt      : u_int32_t ; (* Number of mutexes to configure *)
     mutex_inc      : u_int32_t ; (* Number of mutexes to add *)
     mutex_tas_spins: u_int32_t ;(* Test-and-set spin count *)

     mutex_iq       : Pmutex_iq; (* Initial mutexes queue *)
     mutex_iq_next  : u_int  ; (* Count of initial mutexes *)
     mutex_iq_max   : u_int  ; (* Maximum initial mutexes *)

      (* Locking. *)
     lk_conflicts   : ^u_int8_t; (* Two dimensional conflict matrix. *)
     lk_modes       : int   ; (* Number of lock modes in table. *)
     lk_max         : u_int32_t  ; (* Maximum number of locks. *)
     lk_max_lockers : u_int32_t  ;(* Maximum number of lockers. *)
     lk_max_objects : u_int32_t  ;(* Maximum number of locked objects. *)
     lk_detect      : u_int32_t  ; (* Deadlock detect on all conflicts. *)
     lk_timeout     : db_timeout_t  ; (* Lock timeout period. *)

      (* Logging. *)
     lg_bsize       : u_int32_t  ; (* Buffer size. *)
     lg_size        : u_int32_t  ; (* Log file size. *)
     lg_regionmax   : u_int32_t  ; (* Region size. *)
     lg_filemode    : int   ; (* Log file permission mode. *)

      (* Memory pool. *)
     mp_gbytes      : u_int32_t  ; (* Cachesize: GB. *)
     mp_bytes       : u_int32_t  ; (* Cachesize: Bytes. *)
     mp_ncache      : u_int   ; (* Number of cache regions. *)
     mp_mmapsize    : size_t   ; (* Maximum file size for mmap. *)
     mp_maxopenfd   : int   ; (* Maximum open file descriptors. *)
     mp_maxwrite    : int   ; (* Maximum buffers to write. *)
     mp_maxwrite_sleep: int;    (* Sleep after writing max buffers. *)
      

      (* Transactions. *)
     tx_max         : u_int32_t  ; (* Maximum number of transactions. *)
     tx_timestamp   : time_t   ; (* Recover to specific timestamp. *)
     tx_timeout     : db_timeout_t  ; (* Timeout for transactions. *)

      (* Thread tracking. *)
     thr_nbucket    : u_int32_t ; (* Number of hash buckets. *)
     thr_max        : u_int32_t ; (* Max before garbage collection. *)
     thr_hashtab    : Pointer ; (* Hash table of DB_THREAD_INFO. *)

      (*******************************************************
     * Private: owned by DB.
     *******************************************************)
     pid_cache      : pid_t  ; (* Cached process ID. *)

      (* User files, paths. *)
     db_home        : Pchar ; (* Database home. *)
     db_log_dir     : Pchar ; (* Database log file directory. *)
     db_tmp_dir     : Pchar ; (* Database tmp file directory. *)

     db_data_dir    : PPchar; (* Database data file directories. *)
     data_cnt       : int   ; (* Database data file slots. *)
     data_next      : int   ; (* Next Database data file slot. *)

     db_mode        : int   ; (* Default open permissions. *)
     dir_mode       : int   ; (* Intermediate directory perms. *)
     env_lref       : Pointer ; (* Locker in non-threaded handles. *)
     open_flags     : u_int32_t  ; (* Flags passed to DB_ENV->open. *)

     reginfo        : Pointer; (* REGINFO structure reference. *)
     lockfhp        : Pointer;//PDB_FH; (* fcntl(2) locking file handle. *)

     registry       : Pointer; //PDB_FH; (* DB_REGISTER file handle. *)
     registry_off   : u_int32_t;
   (*
    * Offset of our slot.  We can't use
    * off_t because its size depends on
    * build settings.
    *)

     (* Return IDs. *)
     thread_id : procedure  (Env : PDB_ENV; var p2 : pid_t; var p3 : db_threadid_t); cdecl;
     (* Return if IDs alive. *)
     is_alive  : function (Env : PDB_ENV; p2: pid_t; p3: db_threadid_t; p4 : u_int32_t):int; cdecl;
     (* Format IDs into a string. *)
     thread_id_string : function (Env : PDB_ENV; p2: pid_t; p3 : db_threadid_t; p4 : PChar ):Pchar; cdecl;

     recover_dtab : pointer; (* Dispatch table for recover funcs. *)
        // recover_dtab (Env : PDB_ENV; aDBT : PDBT; Lsn : ^DB_LSN; db_recops, Pointer ):int; cdecl;
     recover_dtab_size: size_t;
     (* Slots in the dispatch table. *)

    cl_handle   : Pointer ; (* RPC: remote client handle. *)
    cl_id       : u_int   ;  (* RPC: remote client env id. *)

    db_ref      : int   ; (* DB reference count. *)

    shm_key     : long   ; (* shmget(2) key. *)

     (*
    * List of open DB handles for this DB_ENV, used for cursor
    * adjustment.  Must be protected for multi-threaded support.
    *
    * !!!
    * As this structure is allocated in per-process memory, the
    * mutex may need to be stored elsewhere on architectures unable
    * to support mutexes in heap memory, e.g. HP/UX 9.
    *
    * !!!
    * Explicit representation of structure in queue.h.
    * TAILQ_HEAD(__dblist, __db);
    *)
    mtx_dblist: db_mutex_t ;  (* Mutex. *)
    dblist : record
                  tqhirst  : pdb;
                  tqh_last : pdb ;
                end; // dblist;

     (*
    * XA support.
    *
    * !!!
    * Explicit representations of structures from queue.h.
    * TAILQ_ENTRY(__db_env) links;
    * TAILQ_HEAD(xa_txn, __db_txn);
    *)
     links : record
               tqe_next:pdb_env;
               tqe_prev:pdb_env;
             end;

     xa_txn: record //__xa_txn { (* XA Active Transactions. *)
       tqh_first: PDB_TXN;
       tqh_last : PDB_TXN;
     end;
    xa_rmid       : int   ; (* XA Resource Manager ID. *)

    passwd        : PChar ; (* Cryptography support. *)
    passwd_len    : size_t   ;
    crypto_handle : Pointer ; (* Primary handle. *)
    mtx_mt        : db_mutex_t  ; (* Mersenne Twister mutex. *)
    mti           : int   ;  (* Mersenne Twister index. *)
    mt            : ^u_long;  (* Mersenne Twister state vector. *)

     (* API-private structure. *)
    api1_internal : Pointer ; (* C++, Perl API private *)
    api2_internal : Pointer ; (* Java API private *)

    lk_handle     : Pointer; //PDB_LOCKTAB; (* Lock handle. *)
    lg_handle     : Pointer; //PDB_LOG; (* Log handle. *)
    mp_handle     : Pointer; //PDB_MPOOL; (* Mpool handle. *)
    mutex_handle  : Pointer; //PDB_MUTEXMGR; (* Mutex handle. *)
    rep_handle    : Pointer; //PDB_REP; (* Replication handle. *)
    tx_handle     : Pointer; //PDB_TXNMGR; (* Txn handle. *)

    (* DB_ENV PUBLIC HANDLE LIST BEGIN *)
    cdsgroup_begin      : function (Env : PDB_ENV; var Txn : PDB_TXN):int; cdecl;
    close               : function (Env : PDB_ENV; p2 : u_int32_t = 0):int; cdecl;
    dbremove            : function (Env : PDB_ENV; Txn : PDB_TXN; const p3 : PChar; const p4: PChar; p5 : u_int32_t):int; cdecl;
    dbrename            : function (Env : PDB_ENV; Txn : PDB_TXN; const p3 : PChar; const p4: PChar; const p5: PChar; p6: u_int32_t):int; cdecl;
    err                 : procedure(const Env : PDB_ENV; p2 :int; const p3 : PChar; args:array of const); cdecl;
    errx                : procedure(const Env : PDB_ENV; const p2 : PChar; args:array of const); cdecl;
    failchk             : function (Env : PDB_ENV; p2 : u_int32_t):int; cdecl;
    fileid_reset        : function (Env : PDB_ENV; const p2: PChar; p3: u_int32_t):int; cdecl;
    get_cachesize       : function (Env : PDB_ENV; var p : u_int32_t ; var p3 : u_int32_t ; var p4 :int):int; cdecl;
    get_data_dirs       : function (Env : PDB_ENV; var p2 : PChar):int; cdecl;
    get_encrypt_flags   : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_errfile         : procedure(Env : PDB_ENV; var p2 : Pointer {FILE **}); cdecl;
    get_errpfx          : procedure(Env : PDB_ENV; var p2 : PChar); cdecl;
    get_flags           : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_home            : function (Env : PDB_ENV; var p2: PChar):int; cdecl;
    get_lg_bsize        : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_lg_dir          : function (Env : PDB_ENV; var p2 : PChar):int; cdecl;
    get_lg_filemode     : function (Env : PDB_ENV; var p2 : int):int; cdecl;
    get_lg_max          : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_lg_regionmax    : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_lk_conflicts    : function (Env : PDB_ENV; var p2 : Pu_int8_t {**}; var p3 : int):int; cdecl;
    get_lk_detect       : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_lk_max_lockers  : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_lk_max_locks    : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_lk_max_objects  : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_mp_max_openfd   : function (Env : PDB_ENV; var p2: int):int; cdecl;
    get_mp_max_write    : function (Env : PDB_ENV; var p2: int; var p3: int):int; cdecl;
    get_mp_mmapsize     : function (Env : PDB_ENV; var p2: size_t):int; cdecl;
    get_msgfile         : procedure(Env : PDB_ENV; var p2 : pointer {FILE **}); cdecl;
    get_open_flags      : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_shm_key         : function (Env : PDB_ENV; var p2: long):int; cdecl;
    get_timeout         : function (Env : PDB_ENV; var p2 : db_timeout_t; p3: u_int32_t):int; cdecl;
    get_tmp_dir         : function (Env : PDB_ENV; const p2: PPChar):int; cdecl;
    get_tx_max          : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    get_tx_timestamp    : function (Env : PDB_ENV; var p2: time_t):int; cdecl;
    get_verbose         : function (Env : PDB_ENV; p2: u_int32_t; var p3: int):int; cdecl;
    is_bigendian        : function:int; cdecl;
    lock_detect         : function (Env : PDB_ENV; p2: u_int32_t; p3: u_int32_t; var p4 : int):int; cdecl;
    lock_get            : function (Env : PDB_ENV; p2 : u_int32_t; p3 : u_int32_t; const aDBT : PDBT; p5: db_lockmode_t; p6 : Pointer{PDB_LOCK}):int; cdecl;
    lock_id             : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    lock_id_free        : function (Env : PDB_ENV; p2 : u_int32_t):int; cdecl;
    lock_put            : function (Env : PDB_ENV; var p2 : DB_LOCK):int; cdecl;
    lock_stat           : function (Env : PDB_ENV; var p2 : PDB_LOCK_STAT; p3: u_int32_t):int; cdecl;
    lock_stat_print     : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    lock_vec            : function (Env : PDB_ENV; p2: u_int32_t; p3: u_int32_t; p4: PDB_LOCKREQ; p5: int; var p6: PDB_LOCKREQ ):int; cdecl;
    log_archive         : function (Env : PDB_ENV; var p2 : PChar; p3:  u_int32_t):int; cdecl;
    log_cursor          : function (Env : PDB_ENV; var p2 : PDB_LOGC; p3: u_int32_t):int; cdecl;
    log_file            : function (Env : PDB_ENV; const Lsn : PDB_LSN; p3 : PChar; p4 : size_t):int; cdecl;
    log_flush           : function (Env : PDB_ENV; const p2 : PDB_LSN):int; cdecl;
    log_printf          : function (Env : PDB_ENV; Txn : PDB_TXN; const PChar; args:array of const):int; cdecl;
    log_put             : function (Env : PDB_ENV; Lsn : PDB_LSN; const aDBT : PDBT; p5 : u_int32_t):int; cdecl;
    log_stat            : function (Env : PDB_ENV; var p2 : PDB_LOG_STAT; p3 : u_int32_t):int; cdecl;
    log_stat_print      : function (Env : PDB_ENV; p2 : u_int32_t):int; cdecl;
    lsn_reset           : function (Env : PDB_ENV; const p2 : PChar; p3 : u_int32_t):int; cdecl;
    memp_fcreate        : function (Env : PDB_ENV; var p2 : PDB_MPOOLFILE; p3 : u_int32_t):int; cdecl;
    memp_register       : function (Env : PDB_ENV; p2 : int; P3 : Pointer {int function(Env : PDB_ENV; db_pgno_t, Pointer , DBT *)};
                                                             p4 : Pointer {int function(Env : PDB_ENV; db_pgno_t, Pointer , DBT *)}):int; cdecl;
    memp_stat           : function (Env : PDB_ENV; var p2 : PDB_MPOOL_STAT; var p3 : PDB_MPOOL_FSTAT; p4 : u_int32_t):int; cdecl;
    memp_stat_print     : function (Env : PDB_ENV; p2 : u_int32_t):int; cdecl;
    memp_sync           : function (Env : PDB_ENV; var p2 : DB_LSN):int; cdecl;
    memp_trickle        : function (Env : PDB_ENV; p2 : int; var p3 : int):int; cdecl;
    mutex_alloc         : function (Env : PDB_ENV; p2 : u_int32_t; var p3 : db_mutex_t):int; cdecl;
    mutex_free          : function (Env : PDB_ENV; p2 : db_mutex_t):int; cdecl;
    mutex_get_align     : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    mutex_get_increment : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    mutex_get_max       : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    mutex_get_tas_spins : function (Env : PDB_ENV; var p : u_int32_t ):int; cdecl;
    mutex_lock          : function (Env : PDB_ENV; p2 : db_mutex_t):int; cdecl;
    mutex_set_align     : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    mutex_set_increment : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    mutex_set_max       : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    mutex_set_tas_spins : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    mutex_stat          : function (Env : PDB_ENV; var p2: PDB_MUTEX_STAT; p3 : u_int32_t):int; cdecl;
    mutex_stat_print    : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    mutex_unlock        : function (Env : PDB_ENV; p2: db_mutex_t):int; cdecl;

    open                : function (Env : PDB_ENV; const db_home: PChar; flags: u_int32_t; Mode: int = 0):int; cdecl;
    remove              : function (Env : PDB_ENV; const p2: PChar; p3: u_int32_t):int; cdecl;
    rep_elect           : function (Env : PDB_ENV; p2: int; p3: int; var p4: int; p5 : u_int32_t):int; cdecl;
    rep_flush           : function (Env : PDB_ENV):int; cdecl;
    rep_get_config      : function (Env : PDB_ENV; p2 : u_int32_t; var P3 :  int):int; cdecl;
    rep_get_limit       : function (Env : PDB_ENV; var p : u_int32_t; var p3 : u_int32_t ):int; cdecl;
    rep_get_nsites      : function (Env : PDB_ENV; var p2: int):int; cdecl;
    rep_get_priority    : function (Env : PDB_ENV; var p2: int):int; cdecl;
    rep_get_timeout     : function (Env : PDB_ENV; p2: int; var p3: u_int32_t):int; cdecl;
    rep_process_message : function (Env : PDB_ENV; aDBT : PDBT; aDBT2 : PDBT; var p5 : int; var p6 : DB_LSN):int; cdecl;
    rep_set_config      : function (Env : PDB_ENV; p2: u_int32_t; p3: int):int; cdecl;
    rep_set_limit       : function (Env : PDB_ENV; p2: u_int32_t; p3: u_int32_t):int; cdecl;
    rep_set_nsites      : function (Env : PDB_ENV; p2: int):int; cdecl;
    rep_set_priority    : function (Env : PDB_ENV; p2: int):int; cdecl;
    rep_set_timeout     : function (Env : PDB_ENV; p2: int; p3: db_timeout_t):int; cdecl;
    rep_set_transport   : function (Env : PDB_ENV; p2: int; p3: Pointer {function(Env : PDB_ENV; const aDBT : PDBT; const aDBT : PDBT; const Lsn : ^DB_LSN; int, u_int32_t):int}):int; cdecl;
    rep_start           : function (Env : PDB_ENV; aDBT : PDBT; p3: u_int32_t):int; cdecl;
    rep_stat            : function (Env : PDB_ENV; var p2: PDB_REP_STAT; p3 : u_int32_t):int; cdecl;
    rep_stat_print      : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    rep_sync            : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;

    repmgr_add_remote_site: function (Env : PDB_ENV; const p2: PChar; p3: u_int; var p4: int; p5: u_int32_t):int; cdecl;
    repmgr_get_ack_policy : function (Env : PDB_ENV; var p2 : int):int; cdecl;
    repmgr_set_ack_policy : function (Env : PDB_ENV; p2 : int):int; cdecl;
    repmgr_set_local_site : function (Env : PDB_ENV; const PChar , u_int, u_int32_t):int; cdecl;
    repmgr_site_list      : function (Env : PDB_ENV; var p2 : u_int; var p3 : PDB_REPMGR_SITE):int; cdecl;
    repmgr_start          : function (Env : PDB_ENV; p2 : int; p3: u_int32_t):int; cdecl;

    set_alloc             : function (Env : PDB_ENV; p2 : Pointer {function(size_t):Pointer}; p3: Pointer {function(Pointer , size_t):Pointer}; p4: Pointer {function(Pointer ):void}):int; cdecl;
    set_app_dispatch      : function (Env : PDB_ENV; p2 : Pointer {function(Env : PDB_ENV; aDBT : PDBT; Lsn : ^DB_LSN; db_recops):int}):int; cdecl;
    set_cachesize         : function (Env : PDB_ENV; p2 : u_int32_t; p3: u_int32_t; p4: int):int; cdecl;
    set_data_dir          : function (Env : PDB_ENV; Const Dir: PChar ):int; cdecl;
    set_encrypt           : function (Env : PDB_ENV; const p2: PChar; p3: u_int32_t):int; cdecl;
    set_errcall           : procedure(Env : PDB_ENV; p2: TErrCall ); cdecl;
    set_errfile           : procedure(Env : PDB_ENV; p2 : Pointer {FILE *}); cdecl;
    set_errpfx            : procedure(Env : PDB_ENV; const p2: PChar ); cdecl;
    set_event_notify      : function (Env : PDB_ENV; p2 : Pointer {function(Env : PDB_ENV; u_int32_t, Pointer ):void}):int; cdecl;
    set_feedback          : function (Env : PDB_ENV; p2 : Pointer {function(Env : PDB_ENV; int, int):void}):int; cdecl;
    set_flags             : function (Env : PDB_ENV; p2: u_int32_t; p3: int):int; cdecl;
    set_intermediate_dir  : function (Env : PDB_ENV; p2: int; p3: u_int32_t):int; cdecl;
    set_isalive           : function (Env : PDB_ENV; p2 : Pointer {function(Env : PDB_ENV; pid_t, db_threadid_t, u_int32_t):int}):int; cdecl;
    set_lg_bsize          : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    set_lg_dir            : function (Env : PDB_ENV; Const p2: PChar ):int; cdecl;
    set_lg_filemode       : function (Env : PDB_ENV; p2: int):int; cdecl;
    set_lg_max            : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    set_lg_regionmax      : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    set_lk_conflicts      : function (Env : PDB_ENV; var p2: u_int8_t; p3: int):int; cdecl;
    set_lk_detect         : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    set_lk_max_lockers    : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    set_lk_max_locks      : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    set_lk_max_objects    : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    set_mp_max_openfd     : function (Env : PDB_ENV; p2: int):int; cdecl;
    set_mp_max_write      : function (Env : PDB_ENV; p2: int; p3: int):int; cdecl;
    set_mp_mmapsize       : function (Env : PDB_ENV; p2: size_t):int; cdecl;
    set_msgcall           : procedure(Env : PDB_ENV; p2: Pointer {function(const Env : PDB_ENV; const PChar ):void}); cdecl;
    set_msgfile           : procedure(Env : PDB_ENV; p2: Pointer {FILE *}); cdecl;
    set_paniccall         : function (Env : PDB_ENV; p2: Pointer {function(Env : PDB_ENV; int):void}):int; cdecl;
    set_rep_request       : function (Env : PDB_ENV; p2: u_int32_t; p3: u_int32_t):int; cdecl;
    set_rpc_server        : function (Env : PDB_ENV; p2: Pointer; const p3: PChar; p4: long; p5: long; p6: u_int32_t):int; cdecl;
    set_shm_key           : function (Env : PDB_ENV; p2: long):int; cdecl;
    set_thread_count      : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    set_thread_id         : function (Env : PDB_ENV; p2: Pointer{void function(Env : PDB_ENV; pid_t *; db_threadid_t *)}):int; cdecl;
    set_thread_id_string  : function (Env : PDB_ENV; p2: Pointer {function(Env : PDB_ENV; pid_t, db_threadid_t, PChar ):PChar}):int; cdecl;
    set_timeout           : function (Env : PDB_ENV; p2: db_timeout_t; p3: u_int32_t):int; cdecl;
    set_tmp_dir           : function (Env : PDB_ENV; Const Dir : PChar ):int; cdecl;
    set_tx_max            : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    set_tx_timestamp      : function (Env : PDB_ENV; var p2: time_t):int; cdecl;
    set_verbose           : function (Env : PDB_ENV; p2: u_int32_t; p3: int):int; cdecl;
    stat_print            : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;

    txn_begin             : function (Env : PDB_ENV; Txn : PDB_TXN; var Txn1 : PDB_TXN; flags: u_int32_t):int; cdecl;
    txn_checkpoint        : function (Env : PDB_ENV; p2: u_int32_t; p3: u_int32_t; p4: u_int32_t):int; cdecl;
    txn_recover           : function (Env : PDB_ENV; var p2: DB_PREPLIST; p3: long; var p4: long; p5 : u_int32_t):int; cdecl;
    txn_stat              : function (Env : PDB_ENV; var p2: PDB_TXN_STAT; p3: u_int32_t):int; cdecl;
    txn_stat_print        : function (Env : PDB_ENV; p2: u_int32_t):int; cdecl;
    (* DB_ENV PUBLIC HANDLE LIST END *)

    (* DB_ENV PRIVATE HANDLE LIST BEGIN *)
    prdbt : function (aDBT : PDBT; p2 : int; const p3: PChar; p4: Pointer; p5 : Pointer{int function(Pointer; const Pointer )}; p6: int):int; cdecl;
    (* DB_ENV PRIVATE HANDLE LIST END *)

    test_abort    : int; (* Abort value for testing. *)
    test_check    : int; (* Checkpoint value for testing. *)
    test_copy     : int; (* Copy value for testing. *)

    flags         : u_int32_t ;
  end;

{$ifndef DB_DBM_HSEARCH}
const
  DB_DBM_HSEARCH =0;  (* No historic interfaces by default. *)
{$endif}
{$if DB_DBM_HSEARCH <> 0}
(*******************************************************
 * Dbm/Ndbm historic interfaces.
 *******************************************************)
type
   struct __db DBM;

const
   DBM_INSERT =0;  (* Flags to dbm_store(). *)
   DBM_REPLACE =1;

(*
 * The DB support for ndbm(3) always appends this suffix to the
 * file name to avoid overwriting the user's original database.
 *)
const
  DBM_SUFFIX ='.db';

{$if defined(_XPG4_2)}
type
  datum = record
 PChar dptr;
 size_t dsize;
  end;
{$else}
type struct {
 PChar dptr;
 int dsize;
} datum;
{$ifend}

(*
 * Translate NDBM calls into DB calls so that DB doesn't step on the
 * application's name space.
 *)
  dbm_clearerr(a)  __db_ndbm_clearerr(a)
  dbm_close(a)  __db_ndbm_close(a)
  dbm_delete(a, b) __db_ndbm_delete(a, b)
  dbm_dirfno(a)  __db_ndbm_dirfno(a)
  dbm_error(a)  __db_ndbm_error(a)
  dbm_fetch(a, b)  __db_ndbm_fetch(a, b)
  dbm_firstkey(a)  __db_ndbm_firstkey(a)
  dbm_nextkey(a)  __db_ndbm_nextkey(a)
  dbm_open(a, b, c) __db_ndbm_open(a, b, c)
  dbm_pagfno(a)  __db_ndbm_pagfno(a)
  dbm_rdonly(a)  __db_ndbm_rdonly(a)
  dbm_store(a, b, c, d) \
 __db_ndbm_store(a, b, c, d)

(*
 * Translate DBM calls into DB calls so that DB doesn't step on the
 * application's name space.
 *
 * The global variables dbrdonly, dirf and pagf were not retained when 4BSD
 * replaced the dbm interface with ndbm, and are not supported here.
 *)
  dbminit(a) __db_dbm_init(a)
  dbmclose __db_dbm_close
  delete(a) __db_dbm_delete(a)
  fetch(a) __db_dbm_fetch(a)
  firstkey __db_dbm_firstkey
  nextkey(a) __db_dbm_nextkey(a)
  store(a, b) __db_dbm_store(a, b)

(*******************************************************
 * Hsearch historic interface.
 *******************************************************)
type
  ACTION =(FIND, ENTER);

type
  ENTRY = record //entry
    key: PChar ;
    data: PChar ;
  end;

  hcreate(a) __db_hcreate(a)
  hdestroy __db_hdestroy
  hsearch(a, b) __db_hsearch(a, b)

{$ifend} (* DB_DBM_HSEARCH *)
var
  _Db_Create                : function (var p1 : PDB; Env : PDB_ENV = nil; flags: u_int32_t =0):int; cdecl;
  _Db_Strerror              : function (p1 : int):PChar; cdecl;
  _Db_Env_Create            : function (var Env : PDB_ENV; flags : u_int32_t=0):int; cdecl;
  _Db_Version               : function (var p1 : int; var p2 : int; var p3 : int):PChar; cdecl;
  _Log_Compare              : function (const Lsn : PDB_LSN; const p2: PDB_LSN):int; cdecl;
  (*
  db_env_set_func_close    : function ( p1: Pointer {function(int):int}):int; cdecl;
  db_env_set_func_dirfree  : function ( p1: Pointer {function(PPChar; int):void}):int; cdecl;
  db_env_set_func_dirlist  : function ( p1: Pointer {function(const PChar; var PPChar; var int ):int}):int; cdecl;
  db_env_set_func_exists   : function ( p1: Pointer {function(const PChar , var int ):int}):int; cdecl;
  db_env_set_func_free     : function ( p1: Pointer {procedure(Pointer )}):int; cdecl;
  db_env_set_func_fsync    : function ( p1: Pointer {function(int):int}):int; cdecl;
  db_env_set_func_ftruncate: function ( p1: Pointer {function(int, off_t):int}):int; cdecl;
  db_env_set_func_ioinfo   : function ( p1: Pointer {function(const PChar , int, u_int32_t *; var p : u_int32_t ; var p : u_int32_t ):int}):int; cdecl;
  *)
  //db_env_set_func_malloc   : function ( p1: Pointer {function(size_t):Pointer}):int; cdecl;
  (*
  db_env_set_func_map      : function ( p1: Pointer {function(PChar , size_t, int, int, var Pointer):int}):int; cdecl;
  db_env_set_func_pread    : function ( p1: Pointer {function(int, Pointer , size_t, off_t):ssize_t}):int; cdecl;
  db_env_set_func_pwrite   : function ( p1: Pointer {function(int, const Pointer , size_t, off_t):ssize_t}):int; cdecl;
  db_env_set_func_open     : function ( p1: Pointer {function(const PChar , int, ...):int}):int; cdecl;
  db_env_set_func_read     : function ( p1: Pointer {function(int, Pointer , size_t):ssize_t}):int; cdecl;
  db_env_set_func_realloc  : function ( p1: Pointer {function(Pointer , size_t):Pointer}):int; cdecl;
  db_env_set_func_rename   : function ( p1: Pointer {function(const PChar , const PChar ):int}):int; cdecl;
  db_env_set_func_seek     : function ( p1: Pointer {function(int, off_t, int):int}):int; cdecl;
  db_env_set_func_sleep    : function ( p1: Pointer {function(u_long, u_long):int}):int; cdecl;
  db_env_set_func_unlink   : function ( p1: Pointer {function(const PChar ):int}):int; cdecl;
  db_env_set_func_unmap    : function ( p1: Pointer {function(Pointer , size_t):int}):int; cdecl;
  db_env_set_func_write    : function ( p1: Pointer {function(int, const Pointer , size_t):ssize_t}):int; cdecl;
  db_env_set_func_yield    : function ( p1: Pointer {function(void):int}):int; cdecl;
  db_sequence_create       : function (var p1 : PDB_SEQUENCE; P2 : PDB ; p3: u_int32_t):int; cdecl;
  *)
{$if DB_DBM_HSEARCH <> 0}
  function  __db_ndbm_clearerr  (var p1 : DBM):int; cdecl;
  procedure __db_ndbm_close     (var p1 : DBM):; cdecl;
  function  __db_ndbm_delete    (var p1 : DBM; p2: datum):int; cdecl;
  function  __db_ndbm_dirfno    (var p1 : DBM):int; cdecl;
  function  __db_ndbm_error     (var p1 : DBM):int; cdecl;
  function  __db_ndbm_fetch     (var p1 : DBM; p2: datum):datum; cdecl;
  function  __db_ndbm_firstkey  (var p1 : DBM):datum; cdecl;
  function  __db_ndbm_nextkey   (var p1 : DBM):datum; cdecl;
  function  __db_ndbm_open      (const p1 PChar; p2 : int; p3: int):var p1 : DBM; cdecl;
  function  __db_ndbm_pagfno    (var p1 : DBM):int; cdecl;
  function  __db_ndbm_rdonly    (var p1 : DBM):int; cdecl;
  function  __db_ndbm_store     (var p1 : DBM; p2: datum; p3:  datum; p4: int):int; cdecl;

  function  __db_dbm_close      :int; cdecl;
  function  __db_dbm_delete     (p1: datum):int; cdecl;
  function  __db_dbm_fetch      (p1: datum):datum; cdecl;
  function  __db_dbm_firstkey   :datum; cdecl;
  function  __db_dbm_init       (p1: PChar ):int; cdecl;
  function  __db_dbm_nextkey    (p1: datum):datum; cdecl;
  function  __db_dbm_store      (p1: datum; p2: datum):int; cdecl;
{$ifend}
{$ifdef DB_DBM_HSEARCH <> 0}
  function  __db_hcreate         (p1: size_t):int; cdecl;
  function  __db_hsearch         (p1 : ENTRY; p2: ACTION):PENTRY; cdecl;
  procedure __db_hdestroy; cdecl;
{$Endif}

implementation
var
  Handle : THandle;
const
  LibName = 'libdb45d.dll';

procedure LoadLibrary;
begin

  Handle := Windows.LoadLibrary(LibName);
  if Handle <> 0 then
  begin
   @_Db_Create	                  := GetProcAddress(Handle, 'db_create'	          ); // @1
   @_Db_Env_Create                := GetProcAddress(Handle, 'db_env_create'	          ); // @2
   //@Db_sequence_create	  := GetProcAddress(Handle, 'db_sequence_create'	  ); // @3
   @_Db_Strerror                  := GetProcAddress(Handle, 'db_strerror'	          ); // @4
   @_Db_Version	                  := GetProcAddress(Handle, 'db_version'	          ); // @5
   //@db_xa_switch         := GetProcAddress(Handle, 'db_xa_switch'	          ); // @6
   @_Log_Compare                  := GetProcAddress(Handle, 'log_compare'	          ); // @7
   //@__db_add_recovery	  := GetProcAddress(Handle, '__db_add_recovery'	  ); // @8

   {$if DB_DBM_HSEARCH <> 0}
   @__db_dbm_close       := GetProcAddress(Handle, '__db_dbm_close'	          ); // @9
   @__db_dbm_delete	 := GetProcAddress(Handle, '__db_dbm_delete'	  ); // @10
   @__db_dbm_fetch       := GetProcAddress(Handle, '__db_dbm_fetch'	          ); // @11
   @__db_dbm_firstkey	 := GetProcAddress(Handle, '__db_dbm_firstkey'	  ); // @12
   @__db_dbm_init        := GetProcAddress(Handle, '__db_dbm_init'	          ); // @13
   @__db_dbm_nextkey	 := GetProcAddress(Handle, '__db_dbm_nextkey'	  ); // @14
   @__db_dbm_store       := GetProcAddress(Handle, '__db_dbm_store'	          ); // @15
   {$ifend}

   //@__db_get_flags_fn	  := GetProcAddress(Handle, '__db_get_flags_fn'	  ); // @16
   //@__db_get_seq_flags_fn:= GetProcAddress(Handle, '__db_get_seq_flags_fn'	  ); // @17

   {$ifdef DB_DBM_HSEARCH <> 0}
   @__db_hcreate	 := GetProcAddress(Handle, '__db_hcreate'	          ); // @18
   @__db_hdestroy        := GetProcAddress(Handle, '__db_hdestroy'	          ); // @19
   @__db_hsearch         := GetProcAddress(Handle, '__db_hsearch'	          ); // @20
   {$endif}

   //@__db_loadme          := GetProcAddress(Handle, '__db_loadme'	          ); // @21

   {$if DB_DBM_HSEARCH <> 0}
   @__db_ndbm_clearerr	  := GetProcAddress(Handle, '__db_ndbm_clearerr'	  ); // @22
   @__db_ndbm_close	  := GetProcAddress(Handle, '__db_ndbm_close'	  ); // @23
   @__db_ndbm_delete	  := GetProcAddress(Handle, '__db_ndbm_delete'	  ); // @24
   @__db_ndbm_dirfn	  := GetProcAddress(Handle, '__db_ndbm_dirfno'	  ); // @25
   @__db_ndbm_error	  := GetProcAddress(Handle, '__db_ndbm_error'	  ); // @26
   @__db_ndbm_fetch	  := GetProcAddress(Handle, '__db_ndbm_fetch'	  ); // @27
   @__db_ndbm_firstkey	  := GetProcAddress(Handle, '__db_ndbm_firstkey'	  ); // @28
   @__db_ndbm_nextkey	  := GetProcAddress(Handle, '__db_ndbm_nextkey'	  ); // @29
   @__db_ndbm_open        := GetProcAddress(Handle, '__db_ndbm_open'	          ); // @30
   @__db_ndbm_pagfno	  := GetProcAddress(Handle, '__db_ndbm_pagfno'	  ); // @31
   @__db_ndbm_rdonly	  := GetProcAddress(Handle, '__db_ndbm_rdonly'	  ); // @32
   @__db_ndbm_store	  := GetProcAddress(Handle, '__db_ndbm_store'	  ); // @33
   {$ifend}

   //@__db_panic	   := GetProcAddress(Handle, '__db_panic'	          ); // @34
   //@__db_r_attach        := GetProcAddress(Handle, '__db_r_attach'	          ); // @35
   //@__db_r_detach        := GetProcAddress(Handle, '__db_r_detach'	          ); // @36
   //@__ham_func2          := GetProcAddress(Handle, '__ham_func2'	          ); // @37
   //@__ham_func3          := GetProcAddress(Handle, '__ham_func3'	          ); // @38
   //@__ham_func4          := GetProcAddress(Handle, '__ham_func4'	          ); // @39
   //@__ham_func5          := GetProcAddress(Handle, '__ham_func5'	          ); // @40
   //@__ham_test	   := GetProcAddress(Handle, '__ham_test'	          ); // @41
   //@__lock_id_set        := GetProcAddress(Handle, '__lock_id_set'	          ); // @42
   //@__os_calloc          := GetProcAddress(Handle, '__os_calloc'	          ); // @43
   //@__os_closehandle	   := GetProcAddress(Handle, '__os_closehandle'	  ); // @44
   //@__os_dirfree         := GetProcAddress(Handle, '__os_dirfree'	          ); // @45
   //@__os_dirlist         := GetProcAddress(Handle, '__os_dirlist'	          ); // @46
   //@__os_free	           := GetProcAddress(Handle, '__os_free'	          ); // @47
   //@__os_get_syserr	   := GetProcAddress(Handle, '__os_get_syserr'	  ); // @48
   //@__os_getenv          := GetProcAddress(Handle, '__os_getenv'	          ); // @49
   //@__os_ioinfo          := GetProcAddress(Handle, '__os_ioinfo'	          ); // @50
   //@__os_malloc          := GetProcAddress(Handle, '__os_malloc'	          ); // @51
   //@__os_mkdir	   := GetProcAddress(Handle, '__os_mkdir'	          ); // @52
   //@__os_open	           := GetProcAddress(Handle, '__os_open'	          ); // @53
   //@__os_openhandle	   := GetProcAddress(Handle, '__os_openhandle'	  ); // @54
   //@__os_posix_err       := GetProcAddress(Handle, '__os_posix_err'	          ); // @55
   //@__os_read	           := GetProcAddress(Handle, '__os_read'	          ); // @56
   //@__os_realloc         := GetProcAddress(Handle, '__os_realloc'	          ); // @57
   //@__os_strdup          := GetProcAddress(Handle, '__os_strdup'	          ); // @58
   //@__os_umalloc         := GetProcAddress(Handle, '__os_umalloc'	          ); // @59
   //@__os_unlink     	   := GetProcAddress(Handle, '__os_unlink'     	  ); // @60
   //@__os_write	   := GetProcAddress(Handle, '__os_write'	          ); // @61
   //@__txn_id_set         := GetProcAddress(Handle, '__txn_id_set'	          ); // @62
   //@__bam_adj_read       := GetProcAddress(Handle, '__bam_adj_read'	          ); // @63
   //@__bam_cadjust_read   := GetProcAddress(Handle, '__bam_cadjust_read'	  ); // @64
   //@__bam_cdel_read 	   := GetProcAddress(Handle, '__bam_cdel_read' 	  ); // @65
   //@__bam_curadj_read	   := GetProcAddress(Handle, '__bam_curadj_read'	  ); // @66
   //@__bam_merge_read	   := GetProcAddress(Handle, '__bam_merge_read'	  ); // @67
   //@__bam_pgin	   := GetProcAddress(Handle, '__bam_pgin'	          ); // @68
   //@__bam_pgno_read	   := GetProcAddress(Handle, '__bam_pgno_read'	  ); // @69
   //@__bam_pgout          := GetProcAddress(Handle, '__bam_pgout'	          ); // @70
   //@__bam_rcuradj_read   := GetProcAddress(Handle, '__bam_rcuradj_read'	  ); // @71
   //@__bam_relink_43_read := GetProcAddress(Handle, '__bam_relink_43_read'	  ); // @72
   //@__bam_relink_read	   := GetProcAddress(Handle, '__bam_relink_read'	  ); // @73
   //@__bam_repl_read	   := GetProcAddress(Handle, '__bam_repl_read'	  ); // @74
   //@__bam_root_read      := GetProcAddress(Handle, '__bam_root_read'          ); // @75
   //@__bam_rsplit_read	   := GetProcAddress(Handle, '__bam_rsplit_read'	  ); // @76
   //@__bam_split_read	   := GetProcAddress(Handle, '__bam_split_read'	  ); // @77
   //@__crdel_inmem_create_read:= GetProcAddress(Handle, '__crdel_inmem_create_read'); // @78
   //@__crdel_inmem_remove_read:= GetProcAddress(Handle, '__crdel_inmem_remove_read'); // @79
   //@__crdel_inmem_rename_read:= GetProcAddress(Handle, '__crdel_inmem_rename_read'); // @80
   //@__crdel_metasub_read  := GetProcAddress(Handle, '__crdel_metasub_read'	  ); // @81
   //@__db_addrem_read	    := GetProcAddress(Handle, '__db_addrem_read'	  ); // @82
   //@__db_big_read         := GetProcAddress(Handle, '__db_big_read'	          ); // @83
   //@__db_cksum_read	    := GetProcAddress(Handle, '__db_cksum_read'	  ); // @84
   //@__db_ctime            := GetProcAddress(Handle, '__db_ctime'	          ); // @85
   //@__db_debug_read	    := GetProcAddress(Handle, '__db_debug_read'	  ); // @86
   //@__db_dispatch         := GetProcAddress(Handle, '__db_dispatch'	          ); // @87
   //@__db_dl	            := GetProcAddress(Handle, '__db_dl'	          ); // @88
   //@__db_dumptree         := GetProcAddress(Handle, '__db_dumptree'	          ); // @89
   //@__db_err	            := GetProcAddress(Handle, '__db_err'	          ); // @90
   //@__db_errx	            := GetProcAddress(Handle, '__db_errx'	          ); // @91
   //@__db_getlong          := GetProcAddress(Handle, '__db_getlong'	          ); // @92
   //@__db_getulong         := GetProcAddress(Handle, '__db_getulong'	          ); // @93
   //@__db_global_values	  := GetProcAddress(Handle, '__db_global_values'	  ); // @94
   //@__db_isbigendian	  := GetProcAddress(Handle, '__db_isbigendian'	  ); // @95
   //@__db_mkpath          := GetProcAddress(Handle, '__db_mkpath'	          ); // @96
   //@__db_msg	          := GetProcAddress(Handle, '__db_msg'	          ); // @97
   //@__db_noop_read       := GetProcAddress(Handle, '__db_noop_read'	          ); // @98
   //@__db_omode	          := GetProcAddress(Handle, '__db_omode'	          ); // @99
   //@__db_ovref_read	  := GetProcAddress(Handle, '__db_ovref_read'	  ); // @100
   //@__db_pg_alloc_42_read:= GetProcAddress(Handle, '__db_pg_alloc_42_read'	  ); // @101
   //@__db_pg_alloc_read	  := GetProcAddress(Handle, '__db_pg_alloc_read'	  ); // @102
   //@__db_pg_free_42_read := GetProcAddress(Handle, '__db_pg_free_42_read'	  ); // @103
   //@__db_pg_free_read	  := GetProcAddress(Handle, '__db_pg_free_read'	  ); // @104
   //@__db_pg_freedata_42_read := GetProcAddress(Handle, '__db_pg_freedata_42_read' ); // @105
   //@__db_pg_freedata_read:= GetProcAddress(Handle, '__db_pg_freedata_read'	  ); // @106
   //@__db_pg_init_read	  := GetProcAddress(Handle, '__db_pg_init_read'	  ); // @107
   //@__db_pg_new_read	  := GetProcAddress(Handle, '__db_pg_new_read'	  ); // @108
   //@__db_pg_prepare_read := GetProcAddress(Handle, '__db_pg_prepare_read'	  ); // @109
   //@__db_pg_sort_read	  := GetProcAddress(Handle, '__db_pg_sort_read'	  ); // @110
   //@__db_pgin	          := GetProcAddress(Handle, '__db_pgin'	          ); // @111
   //@__db_pgout	          := GetProcAddress(Handle, '__db_pgout'	          ); // @112
   //@__db_pr_callback	  := GetProcAddress(Handle, '__db_pr_callback'	  ); // @113
   //@__db_relink_42_read  := GetProcAddress(Handle, '__db_relink_42_read'	  ); // @114
   //@__db_rpath	          := GetProcAddress(Handle, '__db_rpath'	          ); // @115
   //@__db_stat_pp	  := GetProcAddress(Handle, '__db_stat_pp'	          ); // @116
   //@__db_stat_print_pp	  := GetProcAddress(Handle, '__db_stat_print_pp'	  ); // @117
   //@__db_util_cache	  := GetProcAddress(Handle, '__db_util_cache'	  ); // @118
   //@__db_util_interrupted:= GetProcAddress(Handle, '__db_util_interrupted'	  ); // @119
   //@__db_util_logset	  := GetProcAddress(Handle, '__db_util_logset'	  ); // @120
   //@__db_util_siginit	  := GetProcAddress(Handle, '__db_util_siginit'	  ); // @121
   //@__db_util_sigresend  := GetProcAddress(Handle, '__db_util_sigresend'	  ); // @122
   //@__db_verify_internal := GetProcAddress(Handle, '__db_verify_internal'	  ); // @123
   //@__dbreg_register_read:= GetProcAddress(Handle, '__dbreg_register_read'	  ); // @124
   //@__fop_create_read	  := GetProcAddress(Handle, '__fop_create_read'	  ); // @125
   //@__fop_file_remove_read:= GetProcAddress(Handle, '__fop_file_remove_read'	  ); // @126
   //@__fop_remove_read	  := GetProcAddress(Handle, '__fop_remove_read'	  ); // @127
   //@__fop_rename_read	  := GetProcAddress(Handle, '__fop_rename_read'	  ); // @128
   //@__fop_write_read	  := GetProcAddress(Handle, '__fop_write_read'	  ); // @129
   //@__ham_chgpg_read	  := GetProcAddress(Handle, '__ham_chgpg_read'	  ); // @130
   //@__ham_copypage_read  := GetProcAddress(Handle, '__ham_copypage_read'	  ); // @131
   //@__ham_curadj_read	  := GetProcAddress(Handle, '__ham_curadj_read'	  ); // @132
   //@__ham_get_meta	  := GetProcAddress(Handle, '__ham_get_meta'	          ); // @133
   //@__ham_groupalloc_42_read := GetProcAddress(Handle, '__ham_groupalloc_42_read' ); // @134
   //@__ham_groupalloc_read:= GetProcAddress(Handle, '__ham_groupalloc_read'	  ); // @135
   //@__ham_insdel_read	  := GetProcAddress(Handle, '__ham_insdel_read'	  ); // @136
   //@__ham_metagroup_42_read  := GetProcAddress(Handle, '__ham_metagroup_42_read'  ); // @137
   //@__ham_metagroup_read := GetProcAddress(Handle, '__ham_metagroup_read'	  ); // @138
   //@__ham_newpage_read	  := GetProcAddress(Handle, '__ham_newpage_read'	  ); // @139
   //@__ham_pgin	          := GetProcAddress(Handle, '__ham_pgin'	          ); // @140
   //@__ham_pgout          := GetProcAddress(Handle, '__ham_pgout'	          ); // @141
   //@__ham_release_meta	  := GetProcAddress(Handle, '__ham_release_meta'	  ); // @142
   //@__ham_replace_read	  := GetProcAddress(Handle, '__ham_replace_read'	  ); // @143
   //@__ham_splitdata_read := GetProcAddress(Handle, '__ham_splitdata_read'	  ); // @144
   //@__lock_list_print	  := GetProcAddress(Handle, '__lock_list_print'	  ); // @145
   //@__log_stat_pp        := GetProcAddress(Handle, '__log_stat_pp'	          ); // @146
   //@__mutex_set_wait_info:= GetProcAddress(Handle, '__mutex_set_wait_info'	  ); // @147
   //@__os_abspath         := GetProcAddress(Handle, '__os_abspath'	          ); // @148
   //@__os_clock	          := GetProcAddress(Handle, '__os_clock'	          ); // @149
   //@__os_exists          := GetProcAddress(Handle, '__os_exists'	          ); // @150
   //@__os_get_errno       := GetProcAddress(Handle, '__os_get_errno'	          ); // @151
   //@__os_id	          := GetProcAddress(Handle, '__os_id'	          ); // @152
   //@__os_mapfile         := GetProcAddress(Handle, '__os_mapfile'	          ); // @153
   //@__os_seek	          := GetProcAddress(Handle, '__os_seek'	          ); // @154
   //@__os_set_errno       := GetProcAddress(Handle, '__os_set_errno'	          ); // @155
   //@__os_sleep	          := GetProcAddress(Handle, '__os_sleep'	          ); // @156
   //@__os_spin	          := GetProcAddress(Handle, '__os_spin'	          ); // @157
   //@__os_ufree	          := GetProcAddress(Handle, '__os_ufree'	          ); // @158
   //@__os_unmapfile       := GetProcAddress(Handle, '__os_unmapfile'	          ); // @159
   //@__os_yield	          := GetProcAddress(Handle, '__os_yield'	          ); // @160
   //@__qam_add_read       := GetProcAddress(Handle, '__qam_add_read'	          ); // @161
   //@__qam_del_read       := GetProcAddress(Handle, '__qam_del_read'	          ); // @162
   //@__qam_delext_read	  := GetProcAddress(Handle, '__qam_delext_read'	  ); // @163
   //@__qam_incfirst_read  := GetProcAddress(Handle, '__qam_incfirst_read'	  ); // @164
   //@__qam_mvptr_read	  := GetProcAddress(Handle, '__qam_mvptr_read'	  ); // @165
   //@__qam_pgin_out       := GetProcAddress(Handle, '__qam_pgin_out'	          ); // @166
   //@__rep_stat_print	  := GetProcAddress(Handle, '__rep_stat_print'	  ); // @167
   //@__txn_child_read	  := GetProcAddress(Handle, '__txn_child_read'	  ); // @168
   //@__txn_ckp_42_read	  := GetProcAddress(Handle, '__txn_ckp_42_read'	  ); // @169
   //@__txn_ckp_read       := GetProcAddress(Handle, '__txn_ckp_read'	          ); // @170
   //@__txn_recycle_read	  := GetProcAddress(Handle, '__txn_recycle_read'	  ); // @171
   //@__txn_regop_42_read  := GetProcAddress(Handle, '__txn_regop_42_read'	  ); // @172
   //@__txn_regop_read	  := GetProcAddress(Handle, '__txn_regop_read'	  ); // @173
   //@__txn_xa_regop_read  := GetProcAddress(Handle, '__txn_xa_regop_read'	  ); // @174
  end;
end;

procedure UnloadLibrary;
begin
  Windows.FreeLibrary(Handle);
end;

initialization
  LoadLibrary;
Finalization
  UnloadLibrary;

end. (* !_DB_EXT_PROT_IN_ *)
