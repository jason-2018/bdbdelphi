unit mp;

interface
const
	MP_CAN_MMAP		0x001	(* If the file can be mmap'd. *)
	MP_DIRECT		0x002	(* No OS buffering. *)
	MP_EXTENT		0x004	(* Extent file. *)
	MP_FAKE_DEADFILE	0x008	(* Deadfile field: fake flag. *)
	MP_FAKE_FILEWRITTEN	0x010	(* File_written field: fake flag. *)
	MP_FAKE_NB		0x020	(* No_backing_file field: fake flag. *)
	MP_FAKE_UOC		0x040	(* Unlink_on_close field: fake flag. *)
	MP_NOT_DURABLE		0x080	(* File is not durable. *)
  MP_TEMP			0x100	(* Backing file is a temporary. *)

type
  TMPOOLFILE  = record
	  mutex : TDB_MUTEX;

	  (* Protected by MPOOLFILE mutex. *)
	  mpf_cnt   : u_int32_t;		(* Ref count: DB_MPOOLFILEs. *)
	  block_cnt : u_int32_t;		(* Ref count: blocks in cache. *)

	  path_off  : roff_t;		(* File name location. *)

	  (*
	   * We normally don't lock the deadfile field when we read it since we
	   * only care if the field is zero or non-zero.  We do lock on read when
	   * searching for a matching MPOOLFILE -- see that code for more detail.
	   *)
	  deadfile : int32_t;		(* Dirty pages can be discarded. *)

	  (* Protected by mpool cache 0 region lock. *)
	  q : SH_TAILQ_ENTRY;		(* List of MPOOLFILEs *)
	  last_pgno : db_pgno_t;		(* Last page in the file. *)
	  orig_last_pgno : db_pgno_t;	(* Original last page in the file. *)
	  maxpgno : db_pgno_t;		(* Maximum page number. *)

	  (*
	   * None of the following fields are thread protected.
	   *
	   * There are potential races with the ftype field because it's read
	   * without holding a lock.  However, it has to be set before adding
	   * any buffers to the cache that depend on it being set, so there
	   * would need to be incorrect operation ordering to have a problem.
	   *)
	   ftype : int32_t;		(* File type. *)

	  (*
	   * There are potential races with the priority field because it's read
	   * without holding a lock.  However, a collision is unlikely and if it
	   * happens is of little consequence.
	   *)
	   priority : int32_t;		(* Priority when unpinning buffer. *)

	(*
	 * There are potential races with the file_written field (many threads
	 * may be writing blocks at the same time), and with no_backing_file
	 * and unlink_on_close fields, as they may be set while other threads
	 * are reading them.  However, we only care if the value of these fields
	 * are zero or non-zero, so don't lock the memory.
	 *
	 * !!!
	 * Theoretically, a 64-bit architecture could put two of these fields
	 * in a single memory operation and we could race.  I have never seen
	 * an architecture where that's a problem, and I believe Java requires
	 * that to never be the case.
	 *)
	int32_t	  file_written;		(* File was written. *)
	int32_t	  no_backing_file;	(* Never open a backing file. *)
	int32_t	  unlink_on_close;	(* Unlink file on last close. *)

	(*
	 * We do not protect the statistics in "stat" because of the cost of
	 * the mutex in the get/put routines.  There is a chance that a count
	 * will get lost.
	 *)
	DB_MPOOL_FSTAT stat;		(* Per-file mpool statistics. *)

	(*
	 * The remaining fields are initialized at open and never subsequently
	 * modified.
	 *)
	int32_t	  lsn_off;		(* Page's LSN offset. *)
	u_int32_t clear_len;		(* Bytes to clear on page create. *)

	roff_t	  fileid_off;		(* File ID string location. *)

	roff_t	  pgcookie_len;		(* Pgin/pgout cookie length. *)
	roff_t	  pgcookie_off;		(* Pgin/pgout cookie location. *)

	(*
	 * The flags are initialized at open and never subsequently modified.
	 *)
	u_int32_t  flags;
  end;


implementation

end.
 