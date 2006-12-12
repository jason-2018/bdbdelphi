unit BerkeleyDBconst;

interface
const
  DB_VERSION_MAJOR = 4;
  DB_VERSION_MINOR = 2;
  DB_VERSION_PATCH = 52;
  DB_VERSION_STRING = 'Sleepycat Software: Berkeley DB 4.2.52: (December  3, 2003)';

const
  DB_MAX_PAGES = $ffffffff;

const
   DB_DBT_APPMALLOC = $001;
   DB_DBT_ISSET = $002;          { Lower level calls set value.  }
   DB_DBT_MALLOC = $004;         { Return in malloc'd memory.  }
   DB_DBT_PARTIAL = $008;        { Partial put/get.  }
   DB_DBT_REALLOC = $010;        { Return in realloc'd memory.  }
   DB_DBT_USERMEM = $020;        { Return in user's memory.  }
   DB_DBT_DUPOK = $040;          { Insert if duplicate.  }
{
   Common flags --
  	Interfaces which use any of these common flags should never have
  	interface specific flags in this range.
  }

   DB_CREATE = $0000001;         { Create file as necessary.  }
   DB_CXX_NO_EXCEPTIONS = $0000002; { C++: return error values.  }
   DB_FORCE = $0000004;           { Force (anything).  }
   DB_NOMMAP = $0000008;          { Don't mmap underlying file.  }
   DB_RDONLY = $0000010;          { Read-only (O_RDONLY).  }
   DB_RECOVER = $0000020;         { Run normal recovery.  }
   DB_THREAD = $0000040;          { Applications are threaded.  }
   DB_TRUNCATE = $0000080;        { Discard existing DB (O_TRUNC).  }
   DB_TXN_NOSYNC = $0000100;      { Do not sync log on commit.  }
   DB_TXN_NOT_DURABLE = $0000200; { Do not log changes.  }
   DB_USE_ENVIRON = $0000400;     { Use the environment.  }
   DB_USE_ENVIRON_ROOT = $0000800;{ Use the environment if root.  }
{
   Common flags --
  	Interfaces which use any of these common flags should never have
  	interface specific flags in this range.
  
   DB_AUTO_COMMIT:
  	DB_ENV->set_flags, DB->associate, DB->del, DB->put, DB->open,
  	DB->remove, DB->rename, DB->truncate
   DB_DIRTY_READ:
  	DB->cursor, DB->get, DB->join, DB->open, DBcursor->c_get,
  	DB_ENV->txn_begin
   DB_NOAUTO_COMMIT
  	DB->associate, DB->del, DB->put, DB->open,
  	DB->remove, DB->rename, DB->truncate
  
   !!!
   The DB_DIRTY_READ bit mask can't be changed without also changing the
   masks for the flags that can be OR'd into DB access method and cursor
   operation values.
  }

   DB_AUTO_COMMIT = $1000000;     { Implied transaction.  }
   DB_DIRTY_READ = $2000000;      { Dirty Read.  }
   DB_NO_AUTO_COMMIT = $4000000;  { Override env-wide AUTO-COMMIT.  }
{
   Flags private to db_env_create.
  }
{ An RPC client environment.  }
   DB_RPCCLIENT = $0000001;


const
   DB_REP_CREATE = $0000001;

   DB_XA_CREATE = $0000002; { Open in an XA environment.  }
{
   Flags private to DB_ENV->open.
  	   Shared flags up to 0x0000800  }

   DB_INIT_CDB = $0001000;  { Concurrent Access Methods.  }
   DB_INIT_LOCK = $0002000; { Initialize locking.  }
   DB_INIT_LOG = $0004000;  { Initialize logging.  }
   DB_INIT_MPOOL = $0008000;{ Initialize mpool.  }
   DB_INIT_REP = $0010000;  { Initialize replication.  }
   DB_INIT_TXN = $0020000;  { Initialize transactions.  }
   DB_JOINENV = $0040000;   { Initialize all subsystems present.  }
   DB_LOCKDOWN = $0080000;  { Lock memory into physical core.  }
   DB_PRIVATE = $0100000;   { DB_ENV is process local.  }
   DB_RECOVER_FATAL = $0200000; { Run catastrophic recovery.  }
   DB_SYSTEM_MEM = $0400000; { Use system-backed memory.  }
{
   Flags private to DB->open.
	   Shared flags up to 0x0000800  }
{ Exclusive open (O_EXCL).  }
   DB_EXCL = $0001000;
{ UNDOC: fcntl(2) locking.  }
   DB_FCNTL_LOCKING = $0002000;
{ UNDOC: allow subdb master open R/W  }
   DB_RDWRMASTER = $0004000;
{ UNDOC: open with write lock.  }
   DB_WRITEOPEN = $0008000;
{
   Flags private to DB_ENV->txn_begin.
  	   Shared flags up to 0x0000800  }
{ Do not wait for locks in this TXN.  }
   DB_TXN_NOWAIT = $0001000;
{ Always sync log on commit.  }
   DB_TXN_SYNC = $0002000;
{
   Flags private to DB_ENV->set_encrypt.
  }
{ AES, assumes SHA1 checksum  }
   DB_ENCRYPT_AES = $0000001;
{
   Flags private to DB_ENV->set_flags.
  	   Shared flags up to 0x0000800  }
{ Set CDB locking per environment.  }
   DB_CDB_ALLDB = $0001000;
{ Don't buffer databases in the OS.  }
   DB_DIRECT_DB = $0002000;
{ Don't buffer log files in the OS.  }
   DB_DIRECT_LOG = $0004000;
{ Automatically remove log files.  }
   DB_LOG_AUTOREMOVE = $0008000;
{ Set locking/mutex behavior.  }
   DB_NOLOCKING = $0010000;
{ Set panic state per DB_ENV.  }
   DB_NOPANIC = $0020000;
{ Overwrite unlinked region files.  }
   DB_OVERWRITE = $0040000;
{ Set panic state per environment.  }
   DB_PANIC_ENVIRONMENT = $0080000;
{ Page-fault regions on open.  }
   DB_REGION_INIT = $0100000;
{ Return NOTGRANTED on timeout.  }
   DB_TIME_NOTGRANTED = $0200000;
{ Write, don't sync, on txn commit.  }
   DB_TXN_WRITE_NOSYNC = $0400000;
{ Yield the CPU (a lot).  }
   DB_YIELDCPU = $0800000;
{
   Flags private to DB->set_feedback's callback.
  }
{ Upgrading.  }
   DB_UPGRADE = $0000001;
{ Verifying.  }
   DB_VERIFY = $0000002;
{
   Flags private to DB_MPOOLFILE->open.
  	   Shared flags up to 0x0000800  }
{ Don't buffer the file in the OS.  }
   DB_DIRECT = $0001000;
{ UNDOC: dealing with an extent.  }
   DB_EXTENT = $0002000;
{ Truncate file to N   pgsize.  }
   DB_ODDFILESIZE = $0004000;


   //Flags private to DB->set_flags.
   DB_CHKSUM = $0000001;  { Do checksumming  }
   DB_DUP = $0000002;     { Btree, Hash: duplicate keys.  }
   DB_DUPSORT = $0000004; { Btree, Hash: duplicate keys.  }
   DB_ENCRYPT = $0000008; { Btree, Hash: duplicate keys.  }
   DB_RECNUM = $0000010;  { Btree: record numbers.  }
   DB_RENUMBER = $0000020; { Recno: renumber on insert/delete.  }
   DB_REVSPLITOFF = $0000040; { Btree: turn off reverse splits.  }
   DB_SNAPSHOT = $0000080;    { Recno: snapshot the input.  }

   // Flags private to the DB->stat methods.
   DB_STAT_CLEAR = $0000001; { Clear stat after returning values.  }

   // Flags private to DB->join.
   DB_JOIN_NOSORT = $0000001; { Don't try to optimize join.  }

   // Flags private to DB->verify.
   DB_AGGRESSIVE = $0000001; { Salvage whatever could be data. }
   DB_NOORDERCHK = $0000002; { Skip sort order/hashing check.  }
{ Only perform the order check.  }
   DB_ORDERCHKONLY = $0000004;
{ Show page contents (-da).  }
   DB_PR_PAGE = $0000008;
{ Recovery test (-dr).  }
   DB_PR_RECOVERYTEST = $0000010;
{ Use printable format for salvage.  }
   DB_PRINTABLE = $0000020;
{ Salvage what looks like data.  }
   DB_SALVAGE = $0000040;
{
   !!!
   These must not go over 0x8000, or they will collide with the flags
   used by __bam_vrfy_subtree.
  }
{
   Flags private to DB->set_rep_transport's send callback.
  }
{ Do not buffer this message.  }
   DB_REP_NOBUFFER = $0000001;
{ Important--app. may want to flush.  }
   DB_REP_PERMANENT = $0000002;
{
   Locking.
                                                        }
   DB_LOCKVERSION = 1;
{ Unique file ID length.  }
   DB_FILE_ID_LEN = 20;
{
   Deadlock detector modes; used in the DB_ENV structure to configure the
   locking subsystem.
  }
   DB_LOCK_NORUN = 0;
   { Default policy.  }
   DB_LOCK_DEFAULT = 1;
   { Only expire locks, no detection.  }
   DB_LOCK_EXPIRE = 2;
   { Abort txn with maximum # of locks.  }
   DB_LOCK_MAXLOCKS = 3;
   { Abort txn with minimum # of locks.  }
   DB_LOCK_MINLOCKS = 4;
   { Abort txn with minimum writelocks.  }
   DB_LOCK_MINWRITE = 5;
   { Abort oldest transaction.  }
   DB_LOCK_OLDEST = 6;
   { Abort random transaction.  }
   DB_LOCK_RANDOM = 7;
   { Abort youngest transaction.  }
   DB_LOCK_YOUNGEST = 8;
   { Flag values for lock_vec(), lock_get().  }
   { Don't wait on unavailable lock.  }
   DB_LOCK_NOWAIT = $001;
   { Internal: record lock.  }
   DB_LOCK_RECORD = $002;
   { Internal: flag object removed.  }
   DB_LOCK_REMOVE = $004;
   { Internal: set lock timeout.  }
   DB_LOCK_SET_TIMEOUT = $008;
   { Internal: switch existing lock.  }
   DB_LOCK_SWITCH = $010;
   { Internal: upgrade existing lock.  }
   DB_LOCK_UPGRADE = $020;

const
  DB_HANDLE_LOCK = 1;
  DB_RECORD_LOCK = 2;
  DB_PAGE_LOCK = 3;

const
   DB_LOGVERSION = 8;
{ Oldest log version supported.  }
   DB_LOGOLDVER = 8;
   DB_LOGMAGIC = $040988;
{ Flag values for DB_ENV->log_archive().  }
{ Absolute pathnames.  }
   DB_ARCH_ABS = $001;
{ Data files.  }
   DB_ARCH_DATA = $002;
{ Log files.  }
   DB_ARCH_LOG = $004;
{ Remove log files.  }
   DB_ARCH_REMOVE = $008;
{ Flag values for DB_ENV->log_put().  }
{ Flush data to disk (public).  }
   DB_FLUSH = $001;
{ Flush supports a checkpoint  }
   DB_LOG_CHKPNT = $002;
{ Flush supports a commit  }
   DB_LOG_COMMIT = $004;
{ Don't copy data  }
   DB_LOG_NOCOPY = $008;
{ Do not log; keep in memory  }
   DB_LOG_NOT_DURABLE = $010;
{ Flag record with REP_PERMANENT  }
   DB_LOG_PERM = $020;
{ Write, don't sync log_put  }
   DB_LOG_WRNOSYNC = $040;


const
   DB_user_BEGIN = 10000;
   DB_debug_FLAG = $80000000;
{
   DB_LOGC --
  	Log cursor.
  }
   DB_LOGC_BUF_SIZE = 32 * 1024;
{ Log record came from disk.  }
   DB_LOG_DISK = $01;
{ Log region already locked  }
   DB_LOG_LOCKED = $02;
{ Turn-off error messages.  }
   DB_LOG_SILENT_ERR = $04;

const
   DB_MPOOL_CREATE = $001;
{ Return the last page.  }
   DB_MPOOL_LAST = $002;
{ Create a new page.  }
   DB_MPOOL_NEW = $004;
{ Flag values for DB_MPOOLFILE->put, DB_MPOOLFILE->set.  }
{ Page is not modified.  }
   DB_MPOOL_CLEAN = $001;
{ Page is modified.  }
   DB_MPOOL_DIRTY = $002;
{ Don't cache the page.  }
   DB_MPOOL_DISCARD = $004;
{ Flags values for DB_MPOOLFILE->set_flags.  }
{ Never open a backing file.  }
   DB_MPOOL_NOFILE = $001;
{ Unlink the file on last close.  }
   DB_MPOOL_UNLINK = $002;
{ Priority values for DB_MPOOLFILE->set_priority.  }

const
   MP_FILEID_SET = $001;
{ Was opened to flush a buffer.  }
   MP_FLUSH = $002;
{ File opened.  }
   MP_OPEN_CALLED = $004;
{ File is readonly.  }
   MP_READONLY = $008;

const
  DB_TXNVERSION = 1;

const
     TXN_CHILDCOMMIT = $001;
  { Compensating transaction.  }
     TXN_COMPENSATE = $002;
  { Transaction does dirty reads.  }
     TXN_DIRTY_READ = $004;
  { Transaction has a lock timeout.  }
     TXN_LOCKTIMEOUT = $008;
  { Structure allocated by TXN system.  }
     TXN_MALLOC = $010;
  { Do not sync on prepare and commit.  }
     TXN_NOSYNC = $020;
  { Do not wait on locks.  }
     TXN_NOWAIT = $040;
  { Transaction has been restored.  }
     TXN_RESTORED = $080;
  { Sync on prepare and commit.  }
     TXN_SYNC = $100;

const
     DB_XIDDATASIZE = 128;

const
     DB_EID_BROADCAST = -(1);
     DB_EID_INVALID = -(2);
  { rep_start flags values  }
     DB_REP_CLIENT = $001;
     DB_REP_LOGSONLY = $002;
     DB_REP_MASTER = $004;


const
   DB_RENAMEMAGIC = $030800;
{ Current btree version.  }
   DB_BTREEVERSION = 9;
{ Oldest btree version supported.  }
   DB_BTREEOLDVER = 8;
   DB_BTREEMAGIC = $053162;
{ Current hash version.  }
   DB_HASHVERSION = 8;
{ Oldest hash version supported.  }
   DB_HASHOLDVER = 7;
   DB_HASHMAGIC = $061561;
{ Current queue version.  }
   DB_QAMVERSION = 4;
{ Oldest queue version supported.  }
   DB_QAMOLDVER = 3;
   DB_QAMMAGIC = $042253;
{
   DB access method and cursor operation values.  Each value is an operation
   code to which additional bit flags are added.
  }
{ c_put()  }
   DB_AFTER = 1;
{ put()  }
   DB_APPEND = 2;
{ c_put()  }
   DB_BEFORE = 3;
{ stat()  }
   DB_CACHED_COUNTS = 4;
{ get()  }
   DB_CONSUME = 5;
{ get()  }
   DB_CONSUME_WAIT = 6;
{ c_get(), c_put(), DB_LOGC->get()  }
   DB_CURRENT = 7;
{ stat()  }
   DB_FAST_STAT = 8;
{ c_get(), DB_LOGC->get()  }
   DB_FIRST = 9;
{ get(), c_get()  }
   DB_GET_BOTH = 10;
{ c_get() (internal)  }
   DB_GET_BOTHC = 11;
{ get(), c_get()  }
   DB_GET_BOTH_RANGE = 12;
{ c_get()  }
   DB_GET_RECNO = 13;
{ c_get(); do not do primary lookup  }
   DB_JOIN_ITEM = 14;
{ c_put()  }
   DB_KEYFIRST = 15;
{ c_put()  }
   DB_KEYLAST = 16;
{ c_get(), DB_LOGC->get()  }
   DB_LAST = 17;
{ c_get(), DB_LOGC->get()  }
   DB_NEXT = 18;
{ c_get()  }
   DB_NEXT_DUP = 19;
{ c_get()  }
   DB_NEXT_NODUP = 20;
{ put(), c_put()  }
   DB_NODUPDATA = 21;
{ put()  }
   DB_NOOVERWRITE = 22;
{ close()  }
   DB_NOSYNC = 23;
{ c_dup()  }
   DB_POSITION = 24;
{ c_get(), DB_LOGC->get()  }
   DB_PREV = 25;
{ c_get(), DB_LOGC->get()  }
   DB_PREV_NODUP = 26;
{ stat()  }
   DB_RECORDCOUNT = 27;
{ c_get(), DB_LOGC->get()  }
   DB_SET = 28;
{ set_timout()  }
   DB_SET_LOCK_TIMEOUT = 29;
{ c_get()  }
   DB_SET_RANGE = 30;
{ get(), c_get()  }
   DB_SET_RECNO = 31;
{ set_timout() (internal)  }
   DB_SET_TXN_NOW = 32;
{ set_timout()  }
   DB_SET_TXN_TIMEOUT = 33;
{ c_get(), c_del() (internal)  }
   DB_UPDATE_SECONDARY = 34;
{ cursor()  }
   DB_WRITECURSOR = 35;
{ cursor() (internal)  }
   DB_WRITELOCK = 36;
{ This has to change when the max opcode hits 255.  }
{ Mask for operations flags.  }
   DB_OPFLAGS_MASK = $000000ff;
{
   Masks for flags that can be OR'd into DB access method and cursor
   operation values.

  	DB_DIRTY_READ	0x02000000	   Dirty Read.  }
{ Return multiple data values.  }
   DB_MULTIPLE = $04000000;
{ Return multiple data/key pairs.  }
   DB_MULTIPLE_KEY = $08000000;
{ Acquire write flag immediately.  }
   DB_RMW = $10000000;
{
   DB (user visible) error return codes.

   !!!
   For source compatibility with DB 2.X deadlock return (EAGAIN), use the
   following:
  	#include <errno.h>
  	#define DB_LOCK_DEADLOCK EAGAIN

   !!!
   We don't want our error returns to conflict with other packages where
   possible, so pick a base error value that's hopefully not common.  We
   document that we own the error name space from -30,800 to -30,999.
  }
{ DB (public) error return codes.  }
{ "Null" return from 2ndary callbk.  }
   DB_DONOTINDEX = -(30999);
{ Rename/remove while file is open.  }
   DB_FILEOPEN = -(30998);
{ Key/data deleted or never created.  }
   DB_KEYEMPTY = -(30997);
{ The key/data pair already exists.  }
   DB_KEYEXIST = -(30996);
{ Deadlock.  }
   DB_LOCK_DEADLOCK = -(30995);
{ Lock unavailable.  }
   DB_LOCK_NOTGRANTED = -(30994);
{ Server panic return.  }
   DB_NOSERVER = -(30993);
{ Bad home sent to server.  }
   DB_NOSERVER_HOME = -(30992);
{ Bad ID sent to server.  }
   DB_NOSERVER_ID = -(30991);
{ Key/data pair not found (EOF).  }
   DB_NOTFOUND = -(30990);
{ Out-of-date version.  }
   DB_OLD_VERSION = -(30989);
{ Requested page not found.  }
   DB_PAGE_NOTFOUND = -(30988);
{ There are two masters.  }
   DB_REP_DUPMASTER = -(30987);
{ Rolled back a commit.  }
   DB_REP_HANDLE_DEAD = -(30986);
{ Time to hold an election.  }
   DB_REP_HOLDELECTION = -(30985);
{ Cached not written perm written. }
   DB_REP_ISPERM = -(30984);
{ We have learned of a new master.  }
   DB_REP_NEWMASTER = -(30983);
{ New site entered system.  }
   DB_REP_NEWSITE = -(30982);
{ Permanent log record not written.  }
   DB_REP_NOTPERM = -(30981);
{ Site is too far behind master.  }
   DB_REP_OUTDATED = -(30980);
{ Site cannot currently be reached.  }
   DB_REP_UNAVAIL = -(30979);
{ Panic return.  }
   DB_RUNRECOVERY = -(30978);
{ Secondary index corrupt.  }
   DB_SECONDARY_BAD = -(30977);
{ Verify failed; bad format.  }
   DB_VERIFY_BAD = -(30976);
{ DB (private) error return codes.  }
   DB_ALREADY_ABORTED = -(30899);
{ Recovery file marked deleted.  }
   DB_DELETED = -(30898);
{ Object to lock is gone.  }
   DB_LOCK_NOTEXIST = -(30897);
{ Page needs to be split.  }
   DB_NEEDSPLIT = -(30896);
{ Child commit where parent
					   didn't know it was a parent.  }
   DB_SURPRISE_KID = -(30895);
{ Database needs byte swapping.  }
   DB_SWAPBYTES = -(30894);
{ Timed out waiting for election.  }
   DB_TIMEOUT = -(30893);
{ Encountered ckp record in log.  }
   DB_TXN_CKP = -(30892);
{ DB->verify cannot proceed.  }
   DB_VERIFY_FATAL = -(30891);
   DB_LOGFILEID_INVALID = -(1);
   DB_OK_BTREE = $01;
   DB_OK_HASH = $02;
   DB_OK_QUEUE = $04;
   DB_OK_RECNO = $08;
{ Checksumming.  }
   DB_AM_CHKSUM = $00000001;
{ Allow writes in client replica.  }
   DB_AM_CL_WRITER = $00000002;
{ Created by compensating txn.  }
   DB_AM_COMPENSATE = $00000004;
{ Database was created upon open.  }
   DB_AM_CREATED = $00000008;
{ Encompassing file was created.  }
   DB_AM_CREATED_MSTR = $00000010;
{ Error in DBM/NDBM database.  }
   DB_AM_DBM_ERROR = $00000020;
{ Variable length delimiter set.  }
   DB_AM_DELIMITER = $00000040;
{ Support Dirty Reads.  }
   DB_AM_DIRTY = $00000080;
{ Discard any cached pages.  }
   DB_AM_DISCARD = $00000100;
{ DB_DUP.  }
   DB_AM_DUP = $00000200;
{ DB_DUPSORT.  }
   DB_AM_DUPSORT = $00000400;
{ Encryption.  }
   DB_AM_ENCRYPT = $00000800;
{ Fixed-length records.  }
   DB_AM_FIXEDLEN = $00001000;
{ In-memory; no sync on close.  }
   DB_AM_INMEM = $00002000;
{ File is being renamed.  }
   DB_AM_IN_RENAME = $00004000;
{ Do not log changes.  }
   DB_AM_NOT_DURABLE = $00008000;
{ DB->open called.  }
   DB_AM_OPEN_CALLED = $00010000;
{ Fixed-length record pad.  }
   DB_AM_PAD = $00020000;
{ Page size was defaulted.  }
   DB_AM_PGDEF = $00040000;
{ Database is readonly.  }
   DB_AM_RDONLY = $00080000;
{ DB_RECNUM.  }
   DB_AM_RECNUM = $00100000;
{ DB opened by recovery routine.  }
   DB_AM_RECOVER = $00200000;
{ DB_RENUMBER.  }
   DB_AM_RENUMBER = $00400000;
{ An internal replication file.  }
   DB_AM_REPLICATION = $00800000;
{ DB_REVSPLITOFF.  }
   DB_AM_REVSPLITOFF = $01000000;
{ Database is a secondary index.  }
   DB_AM_SECONDARY = $02000000;
{ DB_SNAPSHOT.  }
   DB_AM_SNAPSHOT = $04000000;
{ Subdatabases supported.  }
   DB_AM_SUBDB = $08000000;
{ Pages need to be byte-swapped.  }
   DB_AM_SWAP = $10000000;
{ Opened in a transaction.  }
   DB_AM_TXN = $20000000;
{ DB handle is in the verifier.  }
   DB_AM_VERIFYING = $40000000;

const
     DBC_ACTIVE = $0001;
  { Cursor compensating, don't lock.  }
     DBC_COMPENSATE = $0002;
  { Cursor supports dirty reads.  }
     DBC_DIRTY_READ = $0004;
  { Cursor references off-page dups.  }
     DBC_OPD = $0008;
  { Recovery cursor; don't log/lock.  }
     DBC_RECOVER = $0010;
  { Acquire write flag in read op.  }
     DBC_RMW = $0020;
  { Cursor is transient.  }
     DBC_TRANSIENT = $0040;
  { Cursor may be used to write (CDB).  }
     DBC_WRITECURSOR = $0080;
  { Cursor immediately writing (CDB).  }
     DBC_WRITER = $0100;
  { Return Multiple data.  }
     DBC_MULTIPLE = $0200;
  { Return Multiple keys and data.  }
     DBC_MULTIPLE_KEY = $0400;
  { Free lock id on destroy.  }
     DBC_OWN_LID = $0800;


const
     DB_REGION_MAGIC = $120897;
  { List checkpoints.  }
     DB_VERB_CHKPOINT = $0001;
  { Deadlock detection information.  }
     DB_VERB_DEADLOCK = $0002;
  { Recovery information.  }
     DB_VERB_RECOVERY = $0004;
  { Replication information.  }
     DB_VERB_REPLICATION = $0008;
  { Dump waits-for table.  }
     DB_VERB_WAITSFOR = $0010;
  { after __rep_elect_init  }
     DB_TEST_ELECTINIT = 1;
  { after destroy op  }
     DB_TEST_POSTDESTROY = 2;
  { after logging all pages  }
     DB_TEST_POSTLOG = 3;
  { after logging meta in btree  }
     DB_TEST_POSTLOGMETA = 4;
  { after __os_open  }
     DB_TEST_POSTOPEN = 5;
  { after syncing the log  }
     DB_TEST_POSTSYNC = 6;
  { before destroy op  }
     DB_TEST_PREDESTROY = 7;
  { before __os_open  }
     DB_TEST_PREOPEN = 8;
  { subdb locking tests  }
     DB_TEST_SUBDB_LOCKS = 9;
  { DB_AUTO_COMMIT.  }
     DB_ENV_AUTO_COMMIT = $0000001;
  { DB_INIT_CDB.  }
     DB_ENV_CDB = $0000002;
  { CDB environment wide locking.  }
     DB_ENV_CDB_ALLDB = $0000004;
  { DB_CREATE set.  }
     DB_ENV_CREATE = $0000008;
  { DB_ENV allocated for private DB.  }
     DB_ENV_DBLOCAL = $0000010;
  { DB_DIRECT_DB set.  }
     DB_ENV_DIRECT_DB = $0000020;
  { DB_DIRECT_LOG set.  }
     DB_ENV_DIRECT_LOG = $0000040;
  { Doing fatal recovery in env.  }
     DB_ENV_FATAL = $0000080;
  { DB_LOCKDOWN set.  }
     DB_ENV_LOCKDOWN = $0000100;
  { DB_LOG_AUTOREMOVE set.  }
     DB_ENV_LOG_AUTOREMOVE = $0000200;
  { DB_NOLOCKING set.  }
     DB_ENV_NOLOCKING = $0000400;
  { DB_NOMMAP set.  }
     DB_ENV_NOMMAP = $0000800;
  { Okay if panic set.  }
     DB_ENV_NOPANIC = $0001000;
  { DB_ENV->open called.  }
     DB_ENV_OPEN_CALLED = $0002000;
  { DB_OVERWRITE set.  }
     DB_ENV_OVERWRITE = $0004000;
  { DB_PRIVATE set.  }
     DB_ENV_PRIVATE = $0008000;
  { DB_REGION_INIT set.  }
     DB_ENV_REGION_INIT = $0010000;
  { DB_RPCCLIENT set.  }
     DB_ENV_RPCCLIENT = $0020000;
  { User-supplied RPC client struct  }
     DB_ENV_RPCCLIENT_GIVEN = $0040000;
  { DB_SYSTEM_MEM set.  }
     DB_ENV_SYSTEM_MEM = $0080000;
     DB_ENV_THREAD = $0100000;            { DB_THREAD set.  }
     DB_ENV_TIME_NOTGRANTED = $0200000;   { DB_TIME_NOTGRANTED set.  }
     DB_ENV_TXN_NOSYNC = $0400000;        { DB_TXN_NOSYNC set.  }
     DB_ENV_TXN_NOT_DURABLE = $0800000;   { DB_TXN_NOT_DURABLE set.  }
     DB_ENV_TXN_WRITE_NOSYNC = $1000000;  { DB_TXN_WRITE_NOSYNC set.  }
     DB_ENV_YIELDCPU = $2000000;          { DB_YIELDCPU set.  }


{$ifndef DB_DBM_HSEARCH}
  { No historic interfaces by default.  }

  const
     DB_DBM_HSEARCH = 0;
{$endif}

const
   DBM_INSERT = 0;
   DBM_REPLACE = 1;

const
  DBM_SUFFIX = '.db';

implementation

end.
 