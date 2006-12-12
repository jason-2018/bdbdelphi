program btrec;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  BerkeleyDLL in 'BerkeleyDLL.pas',
  BerkeleyDBconst in 'BerkeleyDBconst.pas';

const
	DATABASE = 'access.db';
	WORDLIST = '../test/wordlist';


function ex_btrec:integer;
var
	dbp : PDB;
	dbcp : PDBC;
	key, data : TDBT;
	statp : TDB_BTREE_STAT;
	fp : Text;
	recno : db_recno_t;
	len   : u_int32_t;
	cnt, ret : integer;
	p : PChar;
  t : PChar;
  buf : String;
  rbuf : String;
const
  progname : Pchar = 'ex_btrec';		(* Program name. *)
label
 suite,
 get_err,
 err1,
 err2;
begin
	(* Open the word database. *)
  assign(fp,WORDLIST);
  Reset(fp);

	(* Remove the previous database. *)
	deleteFile(DATABASE);

	(* Create and initialize database object, open the database. *)
	if (_db_create(dbp, Nil, 0) <> 0) then
  begin
		writeln (Format('%s: db_create: %s\n', [progname, _db_strerror(ret)]));
		Exit;
	end;

	//dbp.set_errfile(dbp, stderr);
	//dbp.set_errpfx(dbp, progname);			(* 1K page sizes. *)
	if (dbp.set_pagesize(dbp, 1024) <> 0) then
  begin
		//dbp.err(dbp, ret, 'set_pagesize');
		Exit;
	end;

  (* Record numbers. *)
	if (dbp.set_flags(dbp, DB_RECNUM) <> 0) then
  begin
		writeln('set_flags: DB_RECNUM');
		Exit;
	end;

	if (dbp.open(dbp,Nil, DATABASE, Nil, DB_BTREE, DB_CREATE, 0664) <> 0) then
  begin
		writeln(format('open: %s', [DATABASE]));
		Exit;
	end;

	(*
	 * Insert records into the database, where the key is the word
	 * preceded by its record number, and the data is the same, but
	 * in reverse order.
	 *)
	fillchar(key, sizeof(TDBT),0);
	fillchar(data, sizeof(TDBT),0);

	for cnt := 1 to 1000 do
  begin
		Buf:=Format ('%4d',[ cnt])+#0;

		Readln(fp,rBuf);
    rBuf:=rBuf+#0;

		key.data := @buf[1];
    key.size := length(buf)+1;

		data.data := @rbuf[1];
		data.size := length(Rbuf)+1;

		if (dbp.put(dbp, Nil, @key, @data, DB_NOOVERWRITE) <> 0) then
    begin
			Writeln('DB.put');
  		goto err1;
		end;
	end;

	(* Close the word database. *)
	close(fp);

	(* Print out the number of records in the database. *)
	if (dbp.stat(dbp, @statp, 0) <> 0) then
  begin
		Writeln('DB.stat');
		goto err1;
	end;

	Writeln(format('%s: database contains %d records',[progname,statp.bt_ndata]));
	//freemem(statp);

	(* Acquire a cursor for the database. *)
	if (dbp.cursor(dbp, Nil, dbcp, 0) <> 0) then
  begin
		Writeln('DB.cursor');
		goto err1;
	end;


	(* Move the cursor a record FIRST. *)
	if (dbcp.c_get(dbcp, @key, @data, DB_FIRST) <> 0) then
	  goto get_err;

	while true do
  begin
    Buf:=StrPas(Pchar(key.data));
    Rbuf:=StrPas(Pchar(data.data));

		(* Display the key and data. *)
		writeln(format('%s : %s', [Buf , rbuf ]));

		(* Move the cursor a record NEXT. *)
		if (dbcp.c_get(dbcp, @key, @data, DB_NEXT) <> 0) then
			goto suite;
  end;

suite:
	(*
	 * Prompt the user for a record number, then retrieve and display
	 * that record.
	 *)
	while true do
  begin
		(* Get a record number. *)
		write('recno #> ');
		readln(buf);
    if Buf = '' then goto err2;
		recno := StrToInt(buf);

		(*
		 * Reset the key each time, the dbp.c_get() routine returns
		 * the key and data pair, not just the key!
		 *)
		key.data := @recno;
		key.size := sizeof(recno);
		if (dbcp.c_get(dbcp, @key, @data, DB_SET_RECNO) <> 0) then
			goto get_err;

		(* Display the key and data. *)
		writeln('Current : ',StrPas(Pchar(key.data)),' - ', StrPas(Pchar(data.data)));

		(* Move the cursor a record forward. *)
		if (dbcp.c_get(dbcp, @key, @data, DB_NEXT) <> 0) then
			goto get_err;

		(* Display the key and data. *)
		writeln('Next : ',StrPas(Pchar(key.data)),' - ', StrPas(Pchar(data.data)));

		(*
		 * Retrieve the record number for the following record into
		 * local memory.
		 *)
		data.data := @recno;
		data.size := sizeof(recno);
		data.ulen := sizeof(recno);
		data.flags := DB_DBT_USERMEM;
		if (dbcp.c_get(dbcp, @key, @data, DB_GET_RECNO) <> 0) then
    begin
get_err:
      Writeln('Error DBcursor.get');
			//if (ret != DB_NOTFOUND && ret != DB_KEYEMPTY)
			goto err2;
		end
    else
			writeln(format('retrieved recno: %d', [recno]));

		(* Reset the data DBT. *)
		Fillchar(data, sizeof(data), 0);
	end;

	if (dbcp.c_close(dbcp) <> 0) then
  begin
		Writeln('DBcursor.close');
		goto err1;
	end;

	if (dbp.close(dbp, 0) <> 0) then
  begin
		writeln(format('%s: DB.close: %s', [progname, _db_strerror(ret)]));
		exit;
	end;

	Exit;

  err2:	dbcp.c_close(dbcp);
  err1:	dbp.close(dbp, 0);

end;



begin
	ex_btrec;
end.
