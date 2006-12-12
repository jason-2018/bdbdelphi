unit os;
interface
(*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2003
 *	Sleepycat Software.  All rights reserved.
 *
 * $Id: os.h,v 11.18 2003/03/11 14:59:29 bostic Exp $
 *)


(*
 * Flags understood by __os_open.
 *)
const
  DB_OSO_CREATE	=$0001;		(* POSIX: O_CREAT *)
  DB_OSO_DIRECT	=$0002;		(* Don't buffer the file in the OS. *)
  DB_OSO_EXCL	=$0004;		(* POSIX: O_EXCL *)
  DB_OSO_LOG	=$0008;		(* Opening a log file. *)
  DB_OSO_RDONLY	=$0010;		(* POSIX: O_RDONLY *)
  DB_OSO_REGION	=$0020;		(* Opening a region file. *)
  DB_OSO_SEQ	=$0040;		(* Expected sequential access. *)
  DB_OSO_TEMP	=$0080;		(* Remove after last close. *)
  DB_OSO_TRUNC	=$0100;		(* POSIX: O_TRUNC *)

(*
 * Seek options understood by __os_seek.
 *)
type
  DB_OS_SEEK = (
  	DB_OS_SEEK_CUR,			(* POSIX: SEEK_CUR *)
	DB_OS_SEEK_END,			(* POSIX: SEEK_END *)
	DB_OS_SEEK_SET			(* POSIX: SEEK_SET *)
        );

(*
 * We group certain seek/write calls into a single function so that we
 * can use pread(2)/pwrite(2) where they're available.
 *)
const
  DB_IO_READ	=1;
  DB_IO_WRITE	=2;

  DB_FH_NOSYNC	=$01;		(* Handle doesn't need to be sync'd. *)
  DB_FH_OPENED	=$02;		(* Handle is valid. *)
  DB_FH_UNLINK	=$04;		(* Unlink on close *)

(* DB filehandle. *)
type
  (* Mutex. *)
  TDB_MUTEX = record
    tas : LONGword;
	  nwaiters : LONGword;
	  id : longword ;	(* ID used for creating events *)
	  locked : longword ;		(* !0 if locked. *)
	  mutex_set_wait : longword ;	(* Granted after wait. *)
	  mutex_set_nowait : longword ;	(* Granted without waiting. *)
	  mutex_set_spin : longword ;	(* Granted without spinning. *)
	  mutex_set_spins : longword ;	(* Total number of spins. *)
	(*
	 * Flags should be an unsigned integer even if it's not required by
	 * the possible flags values, getting a single byte on some machines
	 * is expensive, and the mutex structure is a MP hot spot.
	 *)
	  flags : longword ;		(* MUTEX_XXX *)
  end;

  TDB_FH = record
    (*
     * The file-handle mutex is only used to protect the handle/fd
     * across seek and read/write pairs, it does not protect the
     * the reference count, or any other fields in the structure.
     *)
    mutexp : TDB_MUTEX;		(* Mutex to lock. *)

    ref : integer;			(* Reference count. *)

    handle : THANDLE;		(* Windows/32 file handle. *)
    fd : integer;			(* POSIX file descriptor. *)

    name : Pchar;		(* File name (ref DB_FH_UNLINK) *)

    (*
     * Last seek statistics, used for zero-filling on filesystems
     * that don't support it directly.
     *)
    pgno   : longword;
    pgsize : longword;
    offset : longword;
    flags  : byte;
  end;

implementation
end.
