program ex_btrec;

(*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2006
 *	Oracle Corporation.  All rights reserved.
 *
 * $Id: ex_btrec.c,v 12.3 2006/08/24 14:45:41 bostic Exp $
 *)

uses
  BerkeleyDB40520;

const
  DATABASE     = 'access.db';
  WORDLIST     = '../test/wordlist';

function ex_btrec: integer;
var
  DB *dbp;
  DBC *dbcp;
  DBT key, data;
  DB_BTREE_STAT *statp;
  FILE *fp;
  db_recno_t recno;
  size_t len;
  int cnt, ret;
  char *p, *t, buf[1024], rbuf[1024];
  const char *progname = 'ex_btrec';		(* Program name. *)
begin
  (* Open the word database. *)
  if ((fp = fopen(WORDLIST, 'r')) == NULL)
  begin
    fprintf(stderr, '%s: open %s: %s\n',progname, WORDLIST, db_strerror(errno));
    return (1);
  end;

  (* Remove the previous database. *)
  remove(DATABASE);

  (* Create and initialize database object, open the database. *)
  if ((ret = db_create(dbp, NULL, 0)) <> 0)
  begin
    fprintf(stderr,'%s: db_create: %s\n', progname, db_strerror(ret));
    return (1);
  end;
  dbp.set_errfile(dbp, stderr);
  dbp.set_errpfx(dbp, progname);			(* 1K page sizes. *)
  if ((ret = dbp.set_pagesize(dbp, 1024)) <> 0)
  begin
  	dbp.err(dbp, ret, 'set_pagesize');
  	return (1);
  end;					(* Record numbers. *)
  if ((ret = dbp.set_flags(dbp, DB_RECNUM)) <> 0)
  begin
  	dbp.err(dbp, ret, 'set_flags: DB_RECNUM');
  	return (1);
  end;
  if ((ret = dbp.open(dbp,
      NULL, DATABASE, NULL, DB_BTREE, DB_CREATE, 0664)) <> 0)
  begin
  	dbp.err(dbp, ret, 'open: %s', DATABASE);
  	return (1);
  end;

  (*
   * Insert records into the database, where the key is the word
   * preceded by its record number, and the data is the same, but
   * in reverse order.
   *)
  memset(&key, 0, sizeof(DBT));
  memset(&data, 0, sizeof(DBT));
  for (cnt = 1; cnt <= 1000; ++cnt)
  begin
    (void)sprintf(buf, '%04d_', cnt);
    if (fgets(buf + 4, sizeof(buf) - 4, fp) == NULL)
    	break;
    len = strlen(buf);
    for (t = rbuf, p = buf + (len - 2); p >= buf;)
    	*t++ = *p--;
    *t++ = '\0';

    key.data = buf;
    data.data = rbuf;
    data.size = key.size = (u_int32_t)len - 1;

    if ((ret =
        dbp.put(dbp, NULL, &key, &data, DB_NOOVERWRITE)) <> 0)
    begin
    	dbp.err(dbp, ret, 'DB.put');
    	if (ret <> DB_KEYEXIST)
    		goto err1;
    end;
  end;

  (* Close the word database. *)
  (void)fclose(fp);

  (* Print out the number of records in the database. *)
  if ((ret = dbp.stat(dbp, NULL, &statp, 0)) <> 0)
  begin
  	dbp.err(dbp, ret, 'DB.stat');
  	goto err1;
  end;
  printf('%s: database contains %lu records\n',
      progname, (u_long)statp.bt_ndata);
  free(statp);

  (* Acquire a cursor for the database. *)
  if ((ret = dbp.cursor(dbp, NULL, &dbcp, 0)) <> 0)
  begin
  	dbp.err(dbp, ret, 'DB.cursor');
  	goto err1;
  end;

  (*
   * Prompt the user for a record number, then retrieve and display
   * that record.
   *)
  for (;;)
  begin
    (* Get a record number. *)
    printf('recno #> ');
    fflush(stdout);
    if (fgets(buf, sizeof(buf), stdin) == NULL)
      	break;
    recno = atoi(buf);

    (*
     * Reset the key each time, the dbp.c_get() routine returns
     * the key and data pair, not just the key!
     *)
    key.data = &recno;
    key.size = sizeof(recno);
    if ((ret = dbcp.c_get(dbcp, &key, &data, DB_SET_RECNO)) <> 0)
      goto get_err;

    (* Display the key and data. *)
    show('k/d\t', &key, &data);

    (* Move the cursor a record forward. *)
    ret := dbcp.c_get(dbcp, key, data, DB_NEXT));
    if (ret <> 0)
      goto get_err;

    (* Display the key and data. *)
    show('next\t', key, data);

    (*
     * Retrieve the record number for the following record into
     * local memory.
     *)
    data.data := @recno;
    data.size := sizeof(recno);
    data.ulen := sizeof(recno);
    data.flags := data.flags or DB_DBT_USERMEM;
    ret := dbcp.c_get(dbcp, key, data, DB_GET_RECNO);
    if (ret <> 0)
    begin
get_err:
      dbp.err(dbp, ret, 'DBcursor.get');
      if (ret <> DB_NOTFOUND) and (ret <> DB_KEYEMPTY) then
  	goto err2;
    end
    else
      printf('retrieved recno: %lu\n', (u_long)recno);

    (* Reset the data DBT. *)
    memset(&data, 0, sizeof(data));
  end;

  ret := dbcp.c_close(dbcp);
  if (ret <> 0) then
  begin
    dbp.err(dbp, ret, 'DBcursor.close');
    goto err1;
  end;
  if ((ret = dbp.close(dbp, 0)) <> 0)
  begin
    fprintf(stderr,'%s: DB.close: %s\n', progname, db_strerror(ret));
    Exit;
  end;

  exit;

err2:
  dbcp.c_close(dbcp);
err1:
  dbp.close(dbp, 0);

end;

(*
 * show --
 *	Display a key/data pair.
 *)
procedure show(msg, key, data)
	const char *msg;
	DBT *key, *data;
begin
  printf('%s%.*s : %.*s\n', msg,
        (int)key.size, (char *)key.data,
        (int)data.size, (char *)data.data);
end;

begin
  ex_btrec;
end.
