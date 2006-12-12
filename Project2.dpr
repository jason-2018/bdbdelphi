program Project2;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  BerkerleyDB in 'BerkerleyDB.pas';


DB_ENV *db_init(char *, char *, int, int);
int	fill(DB_ENV *, DB *, int, int, int, int);
int	get(DB *,int, int, int, int, int, int *);
int	main(int, char *[]);
void	usage(void);

const char
	*progname = 'bench_001';		(* Program name. *)
(*
 * db_init --
 *	Initialize the environment.
 *)
 *
Function db_init(home : Pchar; prefix : PChar; cachesize, txn : integer): DB_ENV;
var
	dbenv : PDB_ENV;
	flags, ret : integer;
begin

  ret = db_env_create(&dbenv, 0);
	if (ret <> 0)then
  begin
		dbenv.err(dbenv, ret, 'db_env_create');
		return (NULL);
	end;
	dbenv.set_errfile(dbenv, stderr);
	dbenv.set_errpfx(dbenv, prefix);
	dbenv.set_cachesize(dbenv, 0,
	    cachesize == 0 ? 50 * 1024 * 1024 : (u_int32_t)cachesize, 0);

	flags = DB_CREATE or DB_INIT_MPOOL;
	if (txn) then
		flags  or = flagsor or DB_INIT_TXN  or  DB_INIT_LOCK;

	if ((ret = dbenv.open(dbenv, home, flags, 0)) != 0)
  begin
		dbenv.err(dbenv, ret, 'DB_ENV.open: %s', home);
		(void)dbenv.close(dbenv, 0);
		return (NULL);
	end;
	return (dbenv);
end;

(*
 * get -- loop getting batches of records.
 *
 *)

get(dbp, txn, datalen, num, dups, iter, countp)int
	DB *dbp;
	int txn, datalen, num, dups, iter, *countp;
begin
	DBC *dbcp;
	DBT key, data;
	DB_TXN *txnp;
	u_int32_t len, klen;
	int count, flags, i, j, ret;
	void *pointer, *dp, *kp;

	memset(&key, 0, sizeof(key));
	key.data = &j;
	key.size = sizeof(j);
	memset(&data, 0, sizeof(data));
	data.flags = DB_DBT_USERMEM;
	data.data = malloc(datalen*1024*1024);
	data.ulen = data.size = datalen*1024*1024;
	count = 0;
	flags = DB_SET;
	if (!dups)
		flags  or = DB_MULTIPLE_KEY;
	else
		flags  or = DB_MULTIPLE;
	for (i = 0; i < iter; i++)
  begin
		txnp = NULL;
		if (txn)
			dbp.dbenv.txn_begin(dbp.dbenv, NULL, &txnp, 0);
		dbp.cursor(dbp, txnp, &dbcp, 0);

		j = random(1000000) % num;
		switch (ret = dbcp.c_get(dbcp, &key, &data, flags)) begin
		case 0:
			break;
		default:
			dbp.err(dbcp.dbp, ret, 'DBC.c_get');
			return (ret);
		end;
		DB_MULTIPLE_INIT(pointer, &data);
		if (dups)
			while (pointer != NULL) begin
				DB_MULTIPLE_NEXT(pointer, &data, dp, len);
				if (dp != NULL)
					count++;
			end;
		else
			while (pointer != NULL) begin
				DB_MULTIPLE_KEY_NEXT(pointer,
				    &data, kp, klen, dp, len);
				if (kp != NULL)
					count++;
			end;
		dbcp.c_close(dbcp);
		if (txn)
			txnp.commit(txnp, 0);
	end;

	*countp = count;
	return (0);
end;

(*
 * fill - fill a db
 *	Since we open/created the db with transactions (potentially),
 * we need to populate it with transactions.  We'll bundle the puts
 * 10 to a transaction.
 *)
Const
  PUTS_PER_TXN	10

fill(dbenv, dbp, txn, datalen, num, dups) int
	DB_ENV *dbenv;
	DB *dbp;
	int txn, datalen, num, dups;
begin
	DBT key, data;
	DB_TXN *txnp;
	struct data begin
		int id;
		char str[1];
	end; *data_val;
	int count, i, ret;
	(*
	 * Insert records into the database, where the key is the user
	 * input and the data is the user input in reverse order.
	 *)
	txnp = NULL;
	ret = 0;
	count = 0;
	memset(&key, 0, sizeof(DBT));
	memset(&data, 0, sizeof(DBT));
	key.data = &i;
	key.size = sizeof(i);
	data.data = data_val = (struct data *) malloc(datalen);
	memcpy(data_val.str, '0123456789012345678901234567890123456789',
	    datalen - sizeof (data_val.id));
	data.size = datalen;
	data.flags = DB_DBT_USERMEM;

	for (i = 0; i < num; i++) begin
		if (txn != 0 && i % PUTS_PER_TXN == 0) begin
			if (txnp != NULL) begin
				ret = txnp.commit(txnp, 0);
				txnp = NULL;
				if (ret != 0)
					goto err;
			end;
			if ((ret =
			    dbenv.txn_begin(dbenv, NULL, &txnp, 0)) != 0)
				goto err;
		end;
		data_val.id = 0;
		do begin
			switch (ret =
			    dbp.put(dbp, txnp, &key, &data, 0)) begin
			case 0:
				count++;
				break;
			default:
				dbp.err(dbp, ret, 'DB.put');
				goto err;
			end;
		end; while (++data_val.id < dups);
	end;
	if (txnp != NULL)
		ret = txnp.commit(txnp, 0);

	printf('%d\n', count);
	return (ret);

err:	if (txnp != NULL)
		(void)txnp.abort(txnp);
	return (ret);
end;

int
main(argc, argv)
	int argc;
	char *argv[];
begin
	extern char *optarg;
	extern int optind;
	DB *dbp;
	DB_ENV *dbenv;
	DB_TXN *txnp;
	struct timeval start_time, end_time;
	double secs;
	int cache, ch, count, datalen, dups, env, init, iter, num, pagesize;
	int ret, rflag, txn;

	txnp = NULL;
	datalen = 20;
	iter = num = 1000000;
	env = 1;
	dups = init = rflag = txn = 0;

	pagesize = 65536;
	cache = 1000 * pagesize;

	while ((ch = getopt(argc, argv, 'c:d:EIi:l:n:p:RT')) != EOF)
		switch (ch) begin
		case 'c':
			cache = atoi(optarg);
			break;
		case 'd':
			dups = atoi(optarg);
			break;
		case 'E':
			env = 0;
			break;
		case 'I':
			init = 1;
			break;
		case 'i':
			iter = atoi(optarg);
			break;
		case 'l':
			datalen = atoi(optarg);
			break;
		case 'n':
			num = atoi(optarg);
			break;
		case 'p':
			pagesize = atoi(optarg);
			break;
		case 'R':
			rflag = 1;
			break;
		case 'T':
			txn = 1;
			break;
		case '?':
		default:
			usage();
		end;
	argc -= optind;
	argv += optind;

	(* Remove the previous database. *)
	if (!rflag) begin
		if (env)
			system('rm -rf BENCH_001; mkdir BENCH_001');
		else
			(void)unlink(DATABASE);
	end;

	dbenv = NULL;
	if (env == 1 &&
	    (dbenv = db_init('BENCH_001', 'bench_001', cache, txn)) == NULL)
		return (-1);
	if (init)
		exit(0);
	(* Create and initialize database object, open the database. *)
	if ((ret = db_create(&dbp, dbenv, 0)) != 0) begin
		fprintf(stderr,
		    '%s: db_create: %s\n', progname, db_strerror(ret));
		exit(EXIT_FAILURE);
	end;
	dbp.set_errfile(dbp, stderr);
	dbp.set_errpfx(dbp, progname);
	if ((ret = dbp.set_pagesize(dbp, pagesize)) != 0) begin
		dbp.err(dbp, ret, 'set_pagesize');
		goto err1;
	end;
	if (dups && (ret = dbp.set_flags(dbp, DB_DUP)) != 0) begin
		dbp.err(dbp, ret, 'set_flags');
		goto err1;
	end;

	if (env == 0 && (ret = dbp.set_cachesize(dbp, 0, cache, 0)) != 0) begin
		dbp.err(dbp, ret, 'set_cachesize');
		goto err1;
	end;

	if ((ret = dbp.set_flags(dbp, DB_DUP)) != 0) begin
		dbp.err(dbp, ret, 'set_flags');
		goto err1;
	end;

	if (txn != 0)
		if ((ret = dbenv.txn_begin(dbenv, NULL, &txnp, 0)) != 0)
			goto err1;

	if ((ret = dbp.open(
	    dbp, txnp, DATABASE, NULL, DB_BTREE, DB_CREATE, 0664)) != 0) begin
		dbp.err(dbp, ret, '%s: open', DATABASE);
		if (txnp != NULL)
			(void)txnp.abort(txnp);
		goto err1;
	end;

	if (txnp != NULL)
		ret = txnp.commit(txnp, 0);
	txnp = NULL;
	if (ret != 0)
		goto err1;

	if (rflag) begin
		(* If no environment, fill the cache. *)
		if (!env && (ret =
		    get(dbp, txn, datalen, num, dups, iter, &count)) != 0)
			goto err1;

		(* Time the get loop. *)
		gettimeofday(&start_time, NULL);
		if ((ret =
		    get(dbp, txn, datalen, num, dups, iter, &count)) != 0)
			goto err1;
		gettimeofday(&end_time, NULL);
		secs =
		    (((double)end_time.tv_sec * 1000000 + end_time.tv_usec) -
		    ((double)start_time.tv_sec * 1000000 + start_time.tv_usec))
		    / 1000000;
		printf('%d records read using %d batches in %.2f seconds: ',
		    count, iter, secs);
		printf('%.0f records/second\n', (double)count / secs);

	end; else if ((ret = fill(dbenv, dbp, txn, datalen, num, dups)) != 0)
		goto err1;

	(* Close everything down. *)
	if ((ret = dbp.close(dbp, rflag ? DB_NOSYNC : 0)) != 0) begin
		fprintf(stderr,
		    '%s: DB.close: %s\n', progname, db_strerror(ret));
		return (1);
	end;
	return (ret);

err1:	(void)dbp.close(dbp, 0);
	return (1);
end;

void
usage()
begin
	fprintf(stderr, 'usage: %s %s\n\t%s\n',
	    progname, '[-EIRT] [-c cachesize] [-d dups]',
	    '[-i iterations] [-l datalen] [-n keys] [-p pagesize]');
	exit(EXIT_FAILURE);
end;

var
  DB : TBerkeleyDB;
  Data : array [0..3] of char;
  Key  : array [0..2] of char;
  PageSize : Integer;
  DBName: String;
begin
  DB:=TBerkeleyDB.create;
  DB.FileName:='P:\Berkeley DB\db-4.2.52.NC\build_win32\Test.BDB';
  DB.DBCreate;
  DB.DBOpen;
  DB.DBPut('TEST',4,'AAA',3);

  key:='AAA';
  DB.DBGet(Data,SizeOf(data),key,Sizeof(Key));

  DB.free;



end.
