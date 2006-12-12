program TestBDB;

{$APPTYPE CONSOLE}

uses
  BerkeleyDB40520,
  SysUtils;

begin
  { TODO -oUser -cConsole Main : Insert code here }
  writeln ('DBT            '+IntToStr(SizeOf(DBT)));
  writeln ('DB_MUTEX_STAT  '+IntToStr(SizeOf(DB_MUTEX_STAT)));
  writeln ('DB_LOCK_STAT   '+IntToStr(SizeOf(DB_LOCK_STAT)));
  writeln ('DB_ILOCK       '+IntToStr(SizeOf(DB_ILOCK)));
  writeln ('DB_LOCK        '+IntToStr(SizeOf(DB_LOCK)));
  writeln ('DB_LOCKREQ     '+IntToStr(SizeOf(DB_LOCKREQ)));
  writeln ('DB_LSN         '+IntToStr(SizeOf(DB_LSN)));
  writeln ('DB_LOGC        '+IntToStr(SizeOf(DB_LOGC)));
  writeln ('DB_LOG_STAT    '+IntToStr(SizeOf(DB_LOG_STAT)));
  writeln ('DB_MPOOLFILE   '+IntToStr(SizeOf(DB_MPOOLFILE)));
  writeln ('DB_MPOOL_STAT  '+IntToStr(SizeOf(DB_MPOOL_STAT)));
  writeln ('DB_MPOOL_FSTAT '+IntToStr(SizeOf(DB_MPOOL_FSTAT)));
  writeln ('DB_TXN         '+IntToStr(SizeOf(DB_TXN)));
  writeln ('DB_PREPLIST    '+IntToStr(SizeOf(DB_PREPLIST)));
  writeln ('DB_TXN_ACTIVE  '+IntToStr(SizeOf(DB_TXN_ACTIVE)));
  writeln ('DB_TXN_STAT    '+IntToStr(SizeOf(DB_TXN_STAT)));

  writeln ('DB_REPMGR_SITE    '+IntToStr(SizeOf(DB_REPMGR_SITE)));
  writeln ('DB_REP_STAT       '+IntToStr(SizeOf(DB_REP_STAT)));
  writeln ('DB_SEQUENCE_STAT  '+IntToStr(SizeOf(DB_SEQUENCE_STAT)));
  writeln ('DB_SEQ_RECORD     '+IntToStr(SizeOf(DB_SEQ_RECORD)));
  writeln ('DB_SEQUENCE       '+IntToStr(SizeOf(DB_SEQUENCE)));
  writeln ('DB                '+IntToStr(SizeOf(TDB)));
  writeln ('DBC               '+IntToStr(SizeOf(DBC)));
  writeln ('DB_KEY_RANGE      '+IntToStr(SizeOf(DB_KEY_RANGE)));
  writeln ('DB_BTREE_STAT     '+IntToStr(SizeOf(DB_BTREE_STAT)));
  writeln ('DB_COMPACT        '+IntToStr(SizeOf(DB_COMPACT)));
  writeln ('DB_HASH_STAT      '+IntToStr(SizeOf(DB_HASH_STAT)));
  writeln ('DB_QUEUE_STAT     '+IntToStr(SizeOf(DB_QUEUE_STAT)));
  writeln ('DB_ENV            '+IntToStr(SizeOf(DB_ENV)));

  readln;
end.
