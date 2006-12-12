unit a;
interface

{
  Automatically converted by H2Pas 0.99.15 from a.h
  The following command line parameters were used:
    -d
    a.h
}

{$PACKRECORDS C}


  function ax_reg(_para1:longint; _para2:PXID; _para3:longint):longint;cdecl;external;

  function ax_unreg(_para1:longint; _para2:longint):longint;cdecl;external;







  function __ram_c_del(_para1:PDBC):longint;cdecl;external;

  function __ram_c_get(_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t; _para5:Pdb_pgno_t):longint;cdecl;external;

  function __ram_c_put(_para1:PDBC; _para2:PDBT; _para3:PDBT; _para4:u_int32_t; _para5:Pdb_pgno_t):longint;cdecl;external;

  function __ram_ca(_para1:PDBC; _para2:ca_recno_arg):longint;cdecl;external;


  function __ram_getno(_para1:PDBC; _para2:PDBT; _para3:Pdb_recno_t; _para4:longint):longint;cdecl;external;


  function __bam_rsearch(_para1:PDBC; _para2:Pdb_recno_t; _para3:u_int32_t; _para4:longint; _para5:Plongint):longint;cdecl;external;

  function __bam_adjust(_para1:PDBC; _para2:int32_t):longint;cdecl;external;

  function __bam_nrecs(_para1:PDBC; _para2:Pdb_recno_t):longint;cdecl;external;

  function __bam_total(_para1:PDB; _para2:PPAGE):db_recno_t;cdecl;external;



  function __db_cipherUpdateRounds(_para1:PcipherInstance; _para2:PkeyInstance; _para3:Pu_int8_t; _para4:longint; _para5:Pu_int8_t; 
             _para6:longint):longint;cdecl;external;


  function __dbreg_setup(_para1:PDB; _para2:Pchar; _para3:u_int32_t):longint;cdecl;external;

  function __dbreg_teardown(_para1:PDB):longint;cdecl;external;

  function __dbreg_new_id(_para1:PDB; _para2:PDB_TXN):longint;cdecl;external;



  function __dbreg_revoke_id(_para1:PDB; _para2:longint; _para3:int32_t):longint;cdecl;external;

  function __dbreg_close_id(_para1:PDB; _para2:PDB_TXN):longint;cdecl;external;



  function __dbreg_register_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t; 
             _para6:PDBT; _para7:PDBT; _para8:int32_t; _para9:DBTYPE; _para10:db_pgno_t; 
             _para11:u_int32_t):longint;cdecl;external;

  function __dbreg_register_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __dbreg_register_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __dbreg_init_getpgnos(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function __dbreg_init_recover(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function __dbreg_register_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __dbreg_add_dbentry(_para1:PDB_ENV; _para2:PDB_LOG; _para3:PDB; _para4:int32_t):longint;cdecl;external;

  procedure __dbreg_rem_dbentry(_para1:PDB_LOG; _para2:int32_t);cdecl;external;

  function __dbreg_open_files(_para1:PDB_ENV):longint;cdecl;external;

  function __dbreg_close_files(_para1:PDB_ENV):longint;cdecl;external;

  function __dbreg_id_to_db(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PPDB; _para4:int32_t; _para5:longint):longint;cdecl;external;

  function __dbreg_id_to_db_int(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PPDB; _para4:int32_t; _para5:longint; 
             _para6:longint):longint;cdecl;external;

  function __dbreg_id_to_fname(_para1:PDB_LOG; _para2:int32_t; _para3:longint; _para4:PPFNAME):longint;cdecl;external;

  function __dbreg_fid_to_fname(_para1:PDB_LOG; _para2:Pu_int8_t; _para3:longint; _para4:PPFNAME):longint;cdecl;external;

  function __dbreg_get_name(_para1:PDB_ENV; _para2:Pu_int8_t; _para3:PPchar):longint;cdecl;external;

  function __dbreg_do_open(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LOG; _para4:Pu_int8_t; _para5:Pchar; 
             _para6:DBTYPE; _para7:int32_t; _para8:db_pgno_t; _para9:pointer; _para10:u_int32_t):longint;cdecl;external;

  function __dbreg_lazy_id(_para1:PDB):longint;cdecl;external;

  function __dbreg_push_id(_para1:PDB_ENV; _para2:int32_t):longint;cdecl;external;

  function __dbreg_pop_id(_para1:PDB_ENV; _para2:Pint32_t):longint;cdecl;external;

  function __dbreg_pluck_id(_para1:PDB_ENV; _para2:int32_t):longint;cdecl;external;

  procedure __dbreg_print_dblist(_para1:PDB_ENV);cdecl;external;



  function __crdel_metasub_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __crdel_metasub_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;


  function __crdel_init_getpgnos(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function __crdel_init_recover(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function __crdel_metasub_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;


  function __db_master_open(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:u_int32_t; _para5:longint; 
             _para6:PPDB):longint;cdecl;external;



  function __db_master_update(_para1:PDB; _para2:PDB; _para3:PDB_TXN; _para4:Pchar; _para5:DBTYPE; 
             _para6:mu_action; _para7:Pchar; _para8:u_int32_t):longint;cdecl;external;


  function __db_dbenv_setup(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:u_int32_t; _para5:u_int32_t):longint;cdecl;external;

  function __db_close(_para1:PDB; _para2:PDB_TXN; _para3:u_int32_t):longint;cdecl;external;


  function __db_log_page(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:db_pgno_t; _para5:PPAGE):longint;cdecl;external;


  function __db_backup_name(_para1:PDB_ENV; _para2:Pchar; _para3:PDB_TXN; _para4:PPchar):longint;cdecl;external;

  function __dblist_get(_para1:PDB_ENV; _para2:u_int32_t):^DB;cdecl;external;


  function __db_testcopy(_para1:PDB_ENV; _para2:PDB; _para3:Pchar):longint;cdecl;external;

  function __db_cursor_int(_para1:PDB; _para2:PDB_TXN; _para3:DBTYPE; _para4:db_pgno_t; _para5:longint; 
             _para6:u_int32_t; _para7:PPDBC):longint;cdecl;external;

  function __db_cprint(_para1:PDB):longint;cdecl;external;

  function __db_put(_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:PDBT; _para5:u_int32_t):longint;cdecl;external;

  function __db_del(_para1:PDB; _para2:PDB_TXN; _para3:PDBT; _para4:u_int32_t):longint;cdecl;external;

  function __db_sync(_para1:PDB):longint;cdecl;external;



  function __db_associate(_para1:PDB; _para2:PDB_TXN; _para3:PDB; _para4:function (_para1:PDB; _para2:PDBT; _para3:PDBT; _para4:PDBT):longint; _para5:u_int32_t):longint;cdecl;external;



  function __db_associate(_para1:PDB; _para2:PDB_TXN; _para3:PDB; _para4:function (_para1:PDB; _para2:PDBT; _para3:PDBT; _para4:PDBT):longint; _para5:u_int32_t):longint;cdecl;external;



  function __db_addrem_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t; 
             _para6:db_pgno_t; _para7:u_int32_t; _para8:u_int32_t; _para9:PDBT; _para10:PDBT; 
             _para11:PDB_LSN):longint;cdecl;external;

  function __db_addrem_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_addrem_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_addrem_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_addrem_args):longint;cdecl;external;


  function __db_big_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t; 
             _para6:db_pgno_t; _para7:db_pgno_t; _para8:db_pgno_t; _para9:PDBT; _para10:PDB_LSN; 
             _para11:PDB_LSN; _para12:PDB_LSN):longint;cdecl;external;

  function __db_big_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_big_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_big_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_big_args):longint;cdecl;external;

  function __db_ovref_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t; 
             _para6:int32_t; _para7:PDB_LSN):longint;cdecl;external;

  function __db_ovref_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_ovref_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_ovref_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_ovref_args):longint;cdecl;external;

  function __db_relink_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t; 
             _para6:db_pgno_t; _para7:PDB_LSN; _para8:db_pgno_t; _para9:PDB_LSN; _para10:db_pgno_t; 
             _para11:PDB_LSN):longint;cdecl;external;

  function __db_relink_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_relink_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_relink_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_relink_args):longint;cdecl;external;




  function __db_debug_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDBT; 
             _para6:int32_t; _para7:PDBT; _para8:PDBT; _para9:u_int32_t):longint;cdecl;external;

  function __db_debug_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_debug_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_debug_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_debug_args):longint;cdecl;external;

  function __db_noop_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t; 
             _para6:PDB_LSN):longint;cdecl;external;

  function __db_noop_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_noop_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_noop_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_noop_args):longint;cdecl;external;

  function __db_pg_alloc_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDB_LSN; 
             _para6:db_pgno_t; _para7:PDB_LSN; _para8:db_pgno_t; _para9:u_int32_t; _para10:db_pgno_t):longint;cdecl;external;

  function __db_pg_alloc_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_alloc_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_alloc_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_pg_alloc_args):longint;cdecl;external;


  function __db_pg_free_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t; 
             _para6:PDB_LSN; _para7:db_pgno_t; _para8:PDBT; _para9:db_pgno_t):longint;cdecl;external;

  function __db_pg_free_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_free_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_free_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_pg_free_args):longint;cdecl;external;

  function __db_cksum_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t):longint;cdecl;external;

  function __db_cksum_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_cksum_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_cksum_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_cksum_args):longint;cdecl;external;



  function __db_pg_freedata_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t; 
             _para6:PDB_LSN; _para7:db_pgno_t; _para8:PDBT; _para9:db_pgno_t; _para10:PDBT):longint;cdecl;external;

  function __db_pg_freedata_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_freedata_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_freedata_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_pg_freedata_args):longint;cdecl;external;

  function __db_pg_prepare_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t):longint;cdecl;external;

  function __db_pg_prepare_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_prepare_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_prepare_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_pg_prepare_args):longint;cdecl;external;


  function __db_pg_new_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_pgno_t; 
             _para6:PDB_LSN; _para7:db_pgno_t; _para8:PDBT; _para9:db_pgno_t):longint;cdecl;external;

  function __db_pg_new_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_new_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_new_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__db_pg_new_args):longint;cdecl;external;

  function __db_init_getpgnos(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function __db_init_recover(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;


  function __db_partsize(_para1:u_int32_t; _para2:PDBT):u_int32_t;cdecl;external;

  procedure __db_metaswap(_para1:PPAGE);cdecl;external;

  function __db_byteswap(_para1:PDB_ENV; _para2:PDB; _para3:db_pgno_t; _para4:PPAGE; _para5:size_t; 
             _para6:longint):longint;cdecl;external;

  function __db_txnlist_init(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:PDB_LSN; _para5:pointer):longint;cdecl;external;

  function __db_txnlist_add(_para1:PDB_ENV; _para2:pointer; _para3:u_int32_t; _para4:int32_t; _para5:PDB_LSN):longint;cdecl;external;

  function __db_txnlist_remove(_para1:PDB_ENV; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;

  procedure __db_txnlist_ckp(_para1:PDB_ENV; _para2:pointer; _para3:PDB_LSN);cdecl;external;

  procedure __db_txnlist_end(_para1:PDB_ENV; _para2:pointer);cdecl;external;

  function __db_txnlist_find(_para1:PDB_ENV; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;

  function __db_txnlist_update(_para1:PDB_ENV; _para2:pointer; _para3:u_int32_t; _para4:int32_t; _para5:PDB_LSN):longint;cdecl;external;

  function __db_txnlist_gen(_para1:PDB_ENV; _para2:pointer; _para3:longint; _para4:u_int32_t; _para5:u_int32_t):longint;cdecl;external;

  function __db_txnlist_lsnadd(_para1:PDB_ENV; _para2:pointer; _para3:PDB_LSN; _para4:u_int32_t):longint;cdecl;external;

  function __db_txnlist_lsninit(_para1:PDB_ENV; _para2:PDB_TXNHEAD; _para3:PDB_LSN):longint;cdecl;external;

  function __db_add_limbo(_para1:PDB_ENV; _para2:pointer; _para3:int32_t; _para4:db_pgno_t; _para5:int32_t):longint;cdecl;external;

  function __db_do_the_limbo(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_TXN; _para4:PDB_TXNHEAD; _para5:db_limbo_state):longint;cdecl;external;

  function __db_default_getpgnos(_para1:PDB_ENV; lsnp:PDB_LSN; _para3:pointer):longint;cdecl;external;

  procedure __db_txnlist_print(_para1:pointer);cdecl;external;

  function __db_ditem(_para1:PDBC; _para2:PPAGE; _para3:u_int32_t; _para4:u_int32_t):longint;cdecl;external;

  function __db_pitem(_para1:PDBC; _para2:PPAGE; _para3:u_int32_t; _para4:u_int32_t; _para5:PDBT; 
             _para6:PDBT):longint;cdecl;external;

  function __db_relink(_para1:PDBC; _para2:u_int32_t; _para3:PPAGE; _para4:PPPAGE; _para5:longint):longint;cdecl;external;





  function __db_lget(_para1:PDBC; _para2:longint; _para3:db_pgno_t; _para4:db_lockmode_t; _para5:u_int32_t; 
             _para6:PDB_LOCK):longint;cdecl;external;

  function __db_lput(_para1:PDBC; _para2:PDB_LOCK):longint;cdecl;external;

  function __dbh_am_chk(_para1:PDB; _para2:u_int32_t):longint;cdecl;external;

  function __db_set_flags(_para1:PDB; _para2:u_int32_t):longint;cdecl;external;

  function __db_set_lorder(_para1:PDB; _para2:longint):longint;cdecl;external;

  function __db_set_pagesize(_para1:PDB; _para2:u_int32_t):longint;cdecl;external;



  function __db_open(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:DBTYPE; 
             _para6:u_int32_t; _para7:longint; _para8:db_pgno_t):longint;cdecl;external;

  function __db_get_open_flags(_para1:PDB; _para2:Pu_int32_t):longint;cdecl;external;


  function __db_new_file(_para1:PDB; _para2:PDB_TXN; _para3:PDB_FH; _para4:Pchar):longint;cdecl;external;


  function __db_init_subdb(_para1:PDB; _para2:PDB; _para3:Pchar; _para4:PDB_TXN):longint;cdecl;external;

  function __db_chk_meta(_para1:PDB_ENV; _para2:PDB; _para3:PDBMETA; _para4:longint):longint;cdecl;external;


  function __db_meta_setup(_para1:PDB_ENV; _para2:PDB; _para3:Pchar; _para4:PDBMETA; _para5:u_int32_t; 
             _para6:longint):longint;cdecl;external;

  function __db_goff(_para1:PDB; _para2:PDBT; _para3:u_int32_t; _para4:db_pgno_t; _para5:Ppointer; 
             _para6:Pu_int32_t):longint;cdecl;external;


  function __db_poff(_para1:PDBC; _para2:PDBT; _para3:Pdb_pgno_t):longint;cdecl;external;

  function __db_ovref(_para1:PDBC; _para2:db_pgno_t; _para3:int32_t):longint;cdecl;external;

  function __db_doff(_para1:PDBC; _para2:db_pgno_t):longint;cdecl;external;




  function __db_moff(_para1:PDB; _para2:PDBT; _para3:db_pgno_t; _para4:u_int32_t; _para5:function (_para1:PDB; _para2:PDBT; _para3:PDBT):longint; 
             _para6:Plongint):longint;cdecl;external;




  function __db_moff(_para1:PDB; _para2:PDBT; _para3:db_pgno_t; _para4:u_int32_t; _para5:function (_para1:PDB; _para2:PDBT; _para3:PDBT):longint; 
             _para6:Plongint):longint;cdecl;external;

  function __db_vrfy_overflow(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PPAGE; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;

  function __db_vrfy_ovfl_structure(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:u_int32_t; _para5:u_int32_t):longint;cdecl;external;

  function __db_safe_goff(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:PDBT; _para5:pointer; 
             _para6:u_int32_t):longint;cdecl;external;

  function __db_prnpage(_para1:PDB; _para2:db_pgno_t; _para3:PFILE):longint;cdecl;external;

  function __db_prpage(_para1:PDB; _para2:PPAGE; _para3:PFILE; _para4:u_int32_t):longint;cdecl;external;

  procedure __db_pr(_para1:Pu_int8_t; _para2:u_int32_t; _para3:PFILE);cdecl;external;


  procedure __db_prflags(_para1:u_int32_t; _para2:PFN; _para3:pointer);cdecl;external;


  function __db_dbtype_to_string(_para1:DBTYPE):^char;cdecl;external;

  function __db_addrem_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_big_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_ovref_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_relink_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_debug_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_noop_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_alloc_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_free_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_new_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_freedata_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_cksum_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_pg_prepare_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __db_traverse_big(_para1:PDB; _para2:db_pgno_t; _para3:function (_para1:PDB; _para2:PPAGE; _para3:pointer; _para4:Plongint):longint; _para4:pointer):longint;cdecl;external;

  function __db_traverse_big(_para1:PDB; _para2:db_pgno_t; _para3:function (_para1:PDB; _para2:PPAGE; _para3:pointer; _para4:Plongint):longint; _para4:pointer):longint;cdecl;external;

  function __db_reclaim_callback(_para1:PDB; _para2:PPAGE; _para3:pointer; _para4:Plongint):longint;cdecl;external;

  function __db_truncate_callback(_para1:PDB; _para2:PPAGE; _para3:pointer; _para4:Plongint):longint;cdecl;external;



  function __dbenv_dbremove_pp(_para1:PDB_ENV; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:u_int32_t):longint;cdecl;external;



  function __db_remove_pp(_para1:PDB; _para2:Pchar; _para3:Pchar; _para4:u_int32_t):longint;cdecl;external;



  function __db_remove(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:u_int32_t):longint;cdecl;external;



  function __db_remove_int(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:u_int32_t):longint;cdecl;external;




  function __dbenv_dbrename_pp(_para1:PDB_ENV; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:Pchar; 
             _para6:u_int32_t):longint;cdecl;external;




  function __db_rename_pp(_para1:PDB; _para2:Pchar; _para3:Pchar; _para4:Pchar; _para5:u_int32_t):longint;cdecl;external;




  function __db_rename(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:Pchar):longint;cdecl;external;




  function __db_rename_int(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:Pchar):longint;cdecl;external;

  function __db_ret(_para1:PDB; _para2:PPAGE; _para3:u_int32_t; _para4:PDBT; _para5:Ppointer; 
             _para6:Pu_int32_t):longint;cdecl;external;

  function __db_retcopy(_para1:PDB_ENV; _para2:PDBT; _para3:pointer; _para4:u_int32_t; _para5:Ppointer; 
             _para6:Pu_int32_t):longint;cdecl;external;

  function __db_truncate_pp(_para1:PDB; _para2:PDB_TXN; _para3:Pu_int32_t; _para4:u_int32_t):longint;cdecl;external;

  function __db_truncate(_para1:PDB; _para2:PDB_TXN; _para3:Pu_int32_t; _para4:u_int32_t):longint;cdecl;external;


  function __db_upgrade_pp(_para1:PDB; _para2:Pchar; _para3:u_int32_t):longint;cdecl;external;


  function __db_upgrade(_para1:PDB; _para2:Pchar; _para3:u_int32_t):longint;cdecl;external;

  function __db_lastpgno(_para1:PDB; _para2:Pchar; _para3:PDB_FH; _para4:Pdb_pgno_t):longint;cdecl;external;

  function __db_31_offdup(_para1:PDB; _para2:Pchar; _para3:PDB_FH; _para4:longint; _para5:Pdb_pgno_t):longint;cdecl;external;



  function __db_verify_pp(_para1:PDB; _para2:Pchar; _para3:Pchar; _para4:PFILE; _para5:u_int32_t):longint;cdecl;external;




  function __db_verify(_para1:PDB; _para2:Pchar; _para3:Pchar; _para4:pointer; _para5:function (_para1:pointer; _para2:pointer):longint; 
             _para6:u_int32_t):longint;cdecl;external;




  function __db_verify(_para1:PDB; _para2:Pchar; _para3:Pchar; _para4:pointer; _para5:function (_para1:pointer; _para2:pointer):longint; 
             _para6:u_int32_t):longint;cdecl;external;

  function __db_vrfy_common(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PPAGE; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;

  function __db_vrfy_datapage(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PPAGE; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;

  function __db_vrfy_meta(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PDBMETA; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;

  procedure __db_vrfy_struct_feedback(_para1:PDB; _para2:PVRFY_DBINFO);cdecl;external;


  function __db_salvage(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:PPAGE; _para5:pointer; 
             _para6:function (_para1:pointer; _para2:pointer):longint; _para7:u_int32_t):longint;cdecl;external;


  function __db_salvage(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:PPAGE; _para5:pointer; 
             _para6:function (_para1:pointer; _para2:pointer):longint; _para7:u_int32_t):longint;cdecl;external;

  function __db_vrfy_inpitem(_para1:PDB; _para2:PPAGE; _para3:db_pgno_t; _para4:u_int32_t; _para5:longint; 
             _para6:u_int32_t; _para7:Pu_int32_t; _para8:Pu_int32_t):longint;cdecl;external;

  function __db_vrfy_duptype(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:u_int32_t):longint;cdecl;external;


  function __db_salvage_duptree(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:PDBT; _para5:pointer; 
             _para6:function (_para1:pointer; _para2:pointer):longint; _para7:u_int32_t):longint;cdecl;external;


  function __db_salvage_duptree(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:PDBT; _para5:pointer; 
             _para6:function (_para1:pointer; _para2:pointer):longint; _para7:u_int32_t):longint;cdecl;external;

  function __db_vrfy_dbinfo_create(_para1:PDB_ENV; _para2:u_int32_t; _para3:PPVRFY_DBINFO):longint;cdecl;external;

  function __db_vrfy_dbinfo_destroy(_para1:PDB_ENV; _para2:PVRFY_DBINFO):longint;cdecl;external;

  function __db_vrfy_getpageinfo(_para1:PVRFY_DBINFO; _para2:db_pgno_t; _para3:PPVRFY_PAGEINFO):longint;cdecl;external;

  function __db_vrfy_putpageinfo(_para1:PDB_ENV; _para2:PVRFY_DBINFO; _para3:PVRFY_PAGEINFO):longint;cdecl;external;

  function __db_vrfy_pgset(_para1:PDB_ENV; _para2:u_int32_t; _para3:PPDB):longint;cdecl;external;

  function __db_vrfy_pgset_get(_para1:PDB; _para2:db_pgno_t; _para3:Plongint):longint;cdecl;external;

  function __db_vrfy_pgset_inc(_para1:PDB; _para2:db_pgno_t):longint;cdecl;external;

  function __db_vrfy_pgset_next(_para1:PDBC; _para2:Pdb_pgno_t):longint;cdecl;external;

  function __db_vrfy_childcursor(_para1:PVRFY_DBINFO; _para2:PPDBC):longint;cdecl;external;

  function __db_vrfy_childput(_para1:PVRFY_DBINFO; _para2:db_pgno_t; _para3:PVRFY_CHILDINFO):longint;cdecl;external;

  function __db_vrfy_ccset(_para1:PDBC; _para2:db_pgno_t; _para3:PPVRFY_CHILDINFO):longint;cdecl;external;

  function __db_vrfy_ccnext(_para1:PDBC; _para2:PPVRFY_CHILDINFO):longint;cdecl;external;

  function __db_vrfy_ccclose(_para1:PDBC):longint;cdecl;external;

  function __db_salvage_init(_para1:PVRFY_DBINFO):longint;cdecl;external;

  procedure __db_salvage_destroy(_para1:PVRFY_DBINFO);cdecl;external;

  function __db_salvage_getnext(_para1:PVRFY_DBINFO; _para2:Pdb_pgno_t; _para3:Pu_int32_t):longint;cdecl;external;

  function __db_salvage_isdone(_para1:PVRFY_DBINFO; _para2:db_pgno_t):longint;cdecl;external;

  function __db_salvage_markdone(_para1:PVRFY_DBINFO; _para2:db_pgno_t):longint;cdecl;external;

  function __db_salvage_markneeded(_para1:PVRFY_DBINFO; _para2:db_pgno_t; _para3:u_int32_t):longint;cdecl;external;

  procedure __db_shalloc_init(_para1:pointer; _para2:size_t);cdecl;external;

  function __db_shalloc_size(_para1:size_t; _para2:size_t):longint;cdecl;external;

  function __db_shalloc(_para1:pointer; _para2:size_t; _para3:size_t; _para4:pointer):longint;cdecl;external;

  procedure __db_shalloc_free(_para1:pointer; _para2:pointer);cdecl;external;

  function __db_shsizeof(_para1:pointer):size_t;cdecl;external;

  procedure __db_shalloc_dump(_para1:pointer; _para2:PFILE);cdecl;external;

  function __db_tablesize(_para1:u_int32_t):longint;cdecl;external;

  procedure __db_hashinit(_para1:pointer; _para2:u_int32_t);cdecl;external;

  function __db_fileinit(_para1:PDB_ENV; _para2:PDB_FH; _para3:size_t; _para4:longint):longint;cdecl;external;

  function __dbenv_set_alloc(_para1:PDB_ENV; _para2:Pprocedure (_para1:size_t); _para3:Pprocedure (_para1:pointer; _para2:size_t); _para4:procedure (_para1:pointer)):longint;cdecl;external;

  function __dbenv_set_alloc(_para1:PDB_ENV; _para2:Pprocedure (_para1:size_t); _para3:Pprocedure (_para1:pointer; _para2:size_t); _para4:procedure (_para1:pointer)):longint;cdecl;external;

  function __dbenv_set_alloc(_para1:PDB_ENV; _para2:Pprocedure (_para1:size_t); _para3:Pprocedure (_para1:pointer; _para2:size_t); _para4:procedure (_para1:pointer)):longint;cdecl;external;

  function __dbenv_set_alloc(_para1:PDB_ENV; _para2:Pprocedure (_para1:size_t); _para3:Pprocedure (_para1:pointer; _para2:size_t); _para4:procedure (_para1:pointer)):longint;cdecl;external;

  function __dbenv_get_encrypt_flags(_para1:PDB_ENV; _para2:Pu_int32_t):longint;cdecl;external;


  function __dbenv_set_encrypt(_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t):longint;cdecl;external;

  function __dbenv_set_flags(_para1:PDB_ENV; _para2:u_int32_t; _para3:longint):longint;cdecl;external;


  function __dbenv_set_data_dir(_para1:PDB_ENV; _para2:Pchar):longint;cdecl;external;


  procedure __dbenv_set_errcall(_para1:PDB_ENV; _para2:procedure (_para1:Pchar; _para2:Pchar));cdecl;external;


  procedure __dbenv_set_errcall(_para1:PDB_ENV; _para2:procedure (_para1:Pchar; _para2:Pchar));cdecl;external;

  procedure __dbenv_get_errfile(_para1:PDB_ENV; _para2:PPFILE);cdecl;external;

  procedure __dbenv_set_errfile(_para1:PDB_ENV; _para2:PFILE);cdecl;external;


  procedure __dbenv_get_errpfx(_para1:PDB_ENV; _para2:PPchar);cdecl;external;


  procedure __dbenv_set_errpfx(_para1:PDB_ENV; _para2:Pchar);cdecl;external;

  function __dbenv_set_paniccall(_para1:PDB_ENV; _para2:procedure (_para1:PDB_ENV; _para2:longint)):longint;cdecl;external;

  function __dbenv_set_paniccall(_para1:PDB_ENV; _para2:procedure (_para1:PDB_ENV; _para2:longint)):longint;cdecl;external;

  function __dbenv_set_shm_key(_para1:PDB_ENV; _para2:longint):longint;cdecl;external;

  function __dbenv_set_tas_spins(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;


  function __dbenv_set_tmp_dir(_para1:PDB_ENV; _para2:Pchar):longint;cdecl;external;

  function __dbenv_set_verbose(_para1:PDB_ENV; _para2:u_int32_t; _para3:longint):longint;cdecl;external;


  function __db_mi_env(_para1:PDB_ENV; _para2:Pchar):longint;cdecl;external;


  function __db_mi_open(_para1:PDB_ENV; _para2:Pchar; _para3:longint):longint;cdecl;external;

  function __db_env_config(_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t):longint;cdecl;external;


  function __dbenv_open(_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t; _para4:longint):longint;cdecl;external;


  function __dbenv_remove(_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t):longint;cdecl;external;

  function __dbenv_close_pp(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;

  function __dbenv_close(_para1:PDB_ENV; _para2:longint):longint;cdecl;external;

  function __dbenv_get_open_flags(_para1:PDB_ENV; _para2:Pu_int32_t):longint;cdecl;external;


  function __db_appname(_para1:PDB_ENV; _para2:APPNAME; _para3:Pchar; _para4:u_int32_t; _para5:PPDB_FH; 
             _para6:PPchar):longint;cdecl;external;


  function __db_home(_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t):longint;cdecl;external;

  function __db_apprec(_para1:PDB_ENV; _para2:PDB_LSN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t):longint;cdecl;external;

  function __env_openfiles(_para1:PDB_ENV; _para2:PDB_LOGC; _para3:pointer; _para4:PDBT; _para5:PDB_LSN; 
             _para6:PDB_LSN; _para7:double; _para8:longint):longint;cdecl;external;

  function __db_e_attach(_para1:PDB_ENV; _para2:Pu_int32_t):longint;cdecl;external;

  function __db_e_detach(_para1:PDB_ENV; _para2:longint):longint;cdecl;external;

  function __db_e_remove(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;




(* error 
 int  __ham_vrfy_hashing (DB *, u_int32_t, HMETA *, u_int32_t, db_pgno_t, u_int32_t, u_int32_t (*) (DB *, const void *, u_int32_t)));
 in declarator_list *)

    var
 : longint;

(* error 
 int  __ham_vrfy_hashing (DB *, u_int32_t, HMETA *, u_int32_t, db_pgno_t, u_int32_t, u_int32_t (*) (DB *, const void *, u_int32_t)));
 in declarator_list *)
 : longint;


  function __ham_salvage(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:PPAGE; _para5:pointer; 
             _para6:function (_para1:pointer; _para2:pointer):longint; _para7:u_int32_t):longint;cdecl;external;


  function __ham_salvage(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:PPAGE; _para5:pointer; 
             _para6:function (_para1:pointer; _para2:pointer):longint; _para7:u_int32_t):longint;cdecl;external;

  function __ham_meta2pgset(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PHMETA; _para4:u_int32_t; _para5:PDB):longint;cdecl;external;

  procedure __db_chksum(_para1:Pu_int8_t; _para2:size_t; _para3:Pu_int8_t; _para4:Pu_int8_t);cdecl;external;

  procedure __db_derive_mac(_para1:Pu_int8_t; _para2:size_t; _para3:Pu_int8_t);cdecl;external;

  function __db_check_chksum(_para1:PDB_ENV; _para2:PDB_CIPHER; _para3:Pu_int8_t; _para4:pointer; _para5:size_t;
             _para6:longint):longint;cdecl;external;

  procedure __db_SHA1Transform(_para1:Pu_int32_t; _para2:Pbyte);cdecl;external;

  procedure __db_SHA1Init(_para1:PSHA1_CTX);cdecl;external;

  procedure __db_SHA1Update(_para1:PSHA1_CTX; _para2:Pbyte; _para3:size_t);cdecl;external;

  procedure __db_SHA1Final(_para1:Pbyte; _para2:PSHA1_CTX);cdecl;external;



  function __memp_alloc(_para1:PDB_MPOOL; _para2:PREGINFO; _para3:PMPOOLFILE; _para4:size_t; _para5:Proff_t;
             _para6:pointer):longint;cdecl;external;
  procedure __memp_check_order(_para1:PDB_MPOOL_HASH);cdecl;external;
  function __memp_bhwrite(_para1:PDB_MPOOL; _para2:PDB_MPOOL_HASH; _para3:PMPOOLFILE; _para4:PBH; _para5:longint):longint;cdecl;external;
  function __memp_pgread(_para1:PDB_MPOOLFILE; _para2:PDB_MUTEX; _para3:PBH; _para4:longint):longint;cdecl;external;
  function __memp_pg(_para1:PDB_MPOOLFILE; _para2:PBH; _para3:longint):longint;cdecl;external;
  procedure __memp_bhfree(_para1:PDB_MPOOL; _para2:PDB_MPOOL_HASH; _para3:PBH; _para4:longint);cdecl;external;
  function __memp_fget_pp(_para1:PDB_MPOOLFILE; _para2:Pdb_pgno_t; _para3:u_int32_t; _para4:pointer):longint;cdecl;external;
  function __memp_fget(_para1:PDB_MPOOLFILE; _para2:Pdb_pgno_t; _para3:u_int32_t; _para4:pointer):longint;cdecl;external;
  function __memp_fcreate_pp(_para1:PDB_ENV; _para2:PPDB_MPOOLFILE; _para3:u_int32_t):longint;cdecl;external;
  function __memp_fcreate(_para1:PDB_ENV; _para2:PPDB_MPOOLFILE):longint;cdecl;external;
  function __memp_set_clear_len(_para1:PDB_MPOOLFILE; _para2:u_int32_t):longint;cdecl;external;
  function __memp_get_fileid(_para1:PDB_MPOOLFILE; _para2:Pu_int8_t):longint;cdecl;external;
  function __memp_set_fileid(_para1:PDB_MPOOLFILE; _para2:Pu_int8_t):longint;cdecl;external;

  function __memp_set_flags(_para1:PDB_MPOOLFILE; _para2:u_int32_t; _para3:longint):longint;cdecl;external;

  function __memp_get_ftype(_para1:PDB_MPOOLFILE; _para2:Plongint):longint;cdecl;external;

  function __memp_set_ftype(_para1:PDB_MPOOLFILE; _para2:longint):longint;cdecl;external;

  function __memp_set_lsn_offset(_para1:PDB_MPOOLFILE; _para2:int32_t):longint;cdecl;external;

  function __memp_set_pgcookie(_para1:PDB_MPOOLFILE; _para2:PDBT):longint;cdecl;external;


  function __memp_fopen(_para1:PDB_MPOOLFILE; _para2:PMPOOLFILE; _para3:Pchar; _para4:u_int32_t; _para5:longint; 
             _para6:size_t):longint;cdecl;external;

  procedure __memp_last_pgno(_para1:PDB_MPOOLFILE; _para2:Pdb_pgno_t);cdecl;external;

  function __memp_fclose(_para1:PDB_MPOOLFILE; _para2:u_int32_t):longint;cdecl;external;

  function __memp_mf_sync(_para1:PDB_MPOOL; _para2:PMPOOLFILE):longint;cdecl;external;

  function __memp_mf_discard(_para1:PDB_MPOOL; _para2:PMPOOLFILE):longint;cdecl;external;

  function __memp_fn(_para1:PDB_MPOOLFILE):^char;cdecl;external;

  function __memp_fns(_para1:PDB_MPOOL; _para2:PMPOOLFILE):^char;cdecl;external;

  function __memp_fput_pp(_para1:PDB_MPOOLFILE; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;

  function __memp_fput(_para1:PDB_MPOOLFILE; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;

  function __memp_fset_pp(_para1:PDB_MPOOLFILE; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;

  function __memp_fset(_para1:PDB_MPOOLFILE; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;

  procedure __memp_dbenv_create(_para1:PDB_ENV);cdecl;external;

  function __memp_get_cachesize(_para1:PDB_ENV; _para2:Pu_int32_t; _para3:Pu_int32_t; _para4:Plongint):longint;cdecl;external;

  function __memp_set_cachesize(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:longint):longint;cdecl;external;

  function __memp_set_mp_mmapsize(_para1:PDB_ENV; _para2:size_t):longint;cdecl;external;




  function __memp_nameop(_para1:PDB_ENV; _para2:Pu_int8_t; _para3:Pchar; _para4:Pchar; _para5:Pchar):longint;cdecl;external;

  function __memp_get_refcnt(_para1:PDB_ENV; _para2:Pu_int8_t; _para3:Plongint):longint;cdecl;external;

  function __memp_open(_para1:PDB_ENV):longint;cdecl;external;

  function __memp_dbenv_refresh(_para1:PDB_ENV):longint;cdecl;external;

  procedure __mpool_region_destroy(_para1:PDB_ENV; _para2:PREGINFO);cdecl;external;

  function __memp_register_pp(_para1:PDB_ENV; _para2:longint; _para3:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint; _para4:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint):longint;cdecl;external;

  function __memp_register_pp(_para1:PDB_ENV; _para2:longint; _para3:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint; _para4:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint):longint;cdecl;external;

  function __memp_register_pp(_para1:PDB_ENV; _para2:longint; _para3:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint; _para4:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint):longint;cdecl;external;

  function __memp_register(_para1:PDB_ENV; _para2:longint; _para3:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint; _para4:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint):longint;cdecl;external;

  function __memp_register(_para1:PDB_ENV; _para2:longint; _para3:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint; _para4:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint):longint;cdecl;external;

  function __memp_register(_para1:PDB_ENV; _para2:longint; _para3:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint; _para4:function (_para1:PDB_ENV; _para2:db_pgno_t; _para3:pointer; _para4:PDBT):longint):longint;cdecl;external;

  function __memp_stat_pp(_para1:PDB_ENV; _para2:PPDB_MPOOL_STAT; _para3:PPPDB_MPOOL_FSTAT; _para4:u_int32_t):longint;cdecl;external;

  procedure __memp_stat_hash(_para1:PREGINFO; _para2:PMPOOL; _para3:Pu_int32_t);cdecl;external;

  function __memp_sync_pp(_para1:PDB_ENV; _para2:PDB_LSN):longint;cdecl;external;

  function __memp_sync(_para1:PDB_ENV; _para2:PDB_LSN):longint;cdecl;external;

  function __memp_fsync_pp(_para1:PDB_MPOOLFILE):longint;cdecl;external;

  function __memp_fsync(_para1:PDB_MPOOLFILE):longint;cdecl;external;

  function __mp_xxx_fh(_para1:PDB_MPOOLFILE; _para2:PPDB_FH):longint;cdecl;external;

  function __memp_sync_int(_para1:PDB_ENV; _para2:PDB_MPOOLFILE; _para3:longint; _para4:db_sync_op; _para5:Plongint):longint;cdecl;external;

  function __memp_trickle_pp(_para1:PDB_ENV; _para2:longint; _para3:Plongint):longint;cdecl;external;

  function __db_fcntl_mutex_init(_para1:PDB_ENV; _para2:PDB_MUTEX; _para3:u_int32_t):longint;cdecl;external;

  function __db_fcntl_mutex_lock(_para1:PDB_ENV; _para2:PDB_MUTEX):longint;cdecl;external;

  function __db_fcntl_mutex_unlock(_para1:PDB_ENV; _para2:PDB_MUTEX):longint;cdecl;external;

  function __db_fcntl_mutex_destroy(_para1:PDB_MUTEX):longint;cdecl;external;

  function __db_pthread_mutex_init(_para1:PDB_ENV; _para2:PDB_MUTEX; _para3:u_int32_t):longint;cdecl;external;

  function __db_pthread_mutex_lock(_para1:PDB_ENV; _para2:PDB_MUTEX):longint;cdecl;external;

  function __db_pthread_mutex_unlock(_para1:PDB_ENV; _para2:PDB_MUTEX):longint;cdecl;external;

  function __db_pthread_mutex_destroy(_para1:PDB_MUTEX):longint;cdecl;external;

  function __db_tas_mutex_init(_para1:PDB_ENV; _para2:PDB_MUTEX; _para3:u_int32_t):longint;cdecl;external;

  function __db_tas_mutex_lock(_para1:PDB_ENV; _para2:PDB_MUTEX):longint;cdecl;external;

  function __db_tas_mutex_unlock(_para1:PDB_ENV; _para2:PDB_MUTEX):longint;cdecl;external;

  function __db_tas_mutex_destroy(_para1:PDB_MUTEX):longint;cdecl;external;

  function __db_win32_mutex_destroy(_para1:PDB_MUTEX):longint;cdecl;external;

  function __db_mutex_setup(_para1:PDB_ENV; _para2:PREGINFO; _para3:pointer; _para4:u_int32_t):longint;cdecl;external;

  procedure __db_mutex_free(_para1:PDB_ENV; _para2:PREGINFO; _para3:PDB_MUTEX);cdecl;external;

  procedure __db_shreg_locks_clear(_para1:PDB_MUTEX; _para2:PREGINFO; _para3:PREGMAINT);cdecl;external;

  procedure __db_shreg_locks_destroy(_para1:PREGINFO; _para2:PREGMAINT);cdecl;external;

  function __db_shreg_mutex_init(_para1:PDB_ENV; _para2:PDB_MUTEX; _para3:u_int32_t; _para4:u_int32_t; _para5:PREGINFO; 
             _para6:PREGMAINT):longint;cdecl;external;

  procedure __db_shreg_maintinit(_para1:PREGINFO; addr:pointer; _para3:size_t);cdecl;external;


  function __os_abspath(_para1:Pchar):longint;cdecl;external;

  function __os_urealloc(_para1:PDB_ENV; _para2:size_t; _para3:pointer):longint;cdecl;external;


  function __ua_memcpy(_para1:pointer; _para2:pointer; _para3:size_t):pointer;cdecl;external;

  function __os_fs_notzero:longint;cdecl;external;


  function __os_dirlist(_para1:PDB_ENV; _para2:Pchar; _para3:PPPchar; _para4:Plongint):longint;cdecl;external;

  procedure __os_dirfree(_para1:PDB_ENV; _para2:PPchar; _para3:longint);cdecl;external;

  function __os_get_errno_ret_zero:longint;cdecl;external;


  function __os_fileid(_para1:PDB_ENV; _para2:Pchar; _para3:longint; _para4:Pu_int8_t):longint;cdecl;external;

  function __os_fsync(_para1:PDB_ENV; _para2:PDB_FH):longint;cdecl;external;

  function __os_r_sysattach(_para1:PDB_ENV; _para2:PREGINFO; _para3:PREGION):longint;cdecl;external;

  function __os_r_sysdetach(_para1:PDB_ENV; _para2:PREGINFO; _para3:longint):longint;cdecl;external;

  function __os_mapfile(_para1:PDB_ENV; _para2:Pchar; _para3:PDB_FH; _para4:size_t; _para5:longint; 
             _para6:Ppointer):longint;cdecl;external;

  function __os_unmapfile(_para1:PDB_ENV; _para2:pointer; _para3:size_t):longint;cdecl;external;

  function __db_oflags(_para1:longint):u_int32_t;cdecl;external;

  function __os_have_direct:longint;cdecl;external;


  function __os_open_extend(_para1:PDB_ENV; _para2:Pchar; _para3:u_int32_t; _para4:u_int32_t; _para5:u_int32_t; 
             _para6:longint; _para7:PPDB_FH):longint;cdecl;external;


  function __os_shmname(_para1:PDB_ENV; _para2:Pchar; _para3:PPchar):longint;cdecl;external;

  function __os_r_attach(_para1:PDB_ENV; _para2:PREGINFO; _para3:PREGION):longint;cdecl;external;

  function __os_r_detach(_para1:PDB_ENV; _para2:PREGINFO; _para3:longint):longint;cdecl;external;



  function __os_rename(_para1:PDB_ENV; _para2:Pchar; _para3:Pchar; _para4:u_int32_t):longint;cdecl;external;

  function __os_isroot:longint;cdecl;external;

  function __os_io(_para1:PDB_ENV; _para2:longint; _para3:PDB_FH; _para4:db_pgno_t; _para5:size_t; 
             _para6:Pu_int8_t; _para7:Psize_t):longint;cdecl;external;

  function __os_seek(_para1:PDB_ENV; _para2:PDB_FH; _para3:size_t; _para4:db_pgno_t; _para5:u_int32_t; 
             _para6:longint; _para7:DB_OS_SEEK):longint;cdecl;external;

  procedure __os_spin(_para1:PDB_ENV);cdecl;external;


  function __os_exists(_para1:Pchar; _para2:Plongint):longint;cdecl;external;

  function __os_tmpdir(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;


  function __os_region_unlink(_para1:PDB_ENV; _para2:Pchar):longint;cdecl;external;


  function __os_unlink(_para1:PDB_ENV; _para2:Pchar):longint;cdecl;external;

  function __os_is_winnt:longint;cdecl;external;

  function __os_win32_errno:longint;cdecl;external;

  function __os_have_direct:longint;cdecl;external;

  function __qam_position(_para1:PDBC; _para2:Pdb_recno_t; _para3:qam_position_mode; _para4:Plongint):longint;cdecl;external;

  function __qam_pitem(_para1:PDBC; _para2:PQPAGE; _para3:u_int32_t; _para4:db_recno_t; _para5:PDBT):longint;cdecl;external;

  function __qam_append(_para1:PDBC; _para2:PDBT; _para3:PDBT):longint;cdecl;external;

  function __qam_c_dup(_para1:PDBC; _para2:PDBC):longint;cdecl;external;

  function __qam_c_init(_para1:PDBC):longint;cdecl;external;

  function __qam_truncate(_para1:PDBC; _para2:Pu_int32_t):longint;cdecl;external;

  function __qam_incfirst_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:db_recno_t; 
             _para6:db_pgno_t):longint;cdecl;external;

  function __qam_incfirst_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_incfirst_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_incfirst_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__qam_incfirst_args):longint;cdecl;external;

  function __qam_mvptr_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t; 
             _para6:db_recno_t; _para7:db_recno_t; _para8:db_recno_t; _para9:db_recno_t; _para10:PDB_LSN; 
             _para11:db_pgno_t):longint;cdecl;external;

  function __qam_mvptr_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_mvptr_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_mvptr_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__qam_mvptr_args):longint;cdecl;external;

  function __qam_del_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDB_LSN; 
             _para6:db_pgno_t; _para7:u_int32_t; _para8:db_recno_t):longint;cdecl;external;

  function __qam_del_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_del_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_del_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__qam_del_args):longint;cdecl;external;



  function __qam_add_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDB_LSN; 
             _para6:db_pgno_t; _para7:u_int32_t; _para8:db_recno_t; _para9:PDBT; _para10:u_int32_t; 
             _para11:PDBT):longint;cdecl;external;

  function __qam_add_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_add_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_add_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__qam_add_args):longint;cdecl;external;


  function __qam_delext_log(_para1:PDB; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDB_LSN; 
             _para6:db_pgno_t; _para7:u_int32_t; _para8:db_recno_t; _para9:PDBT):longint;cdecl;external;

  function __qam_delext_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_delext_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_delext_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__qam_delext_args):longint;cdecl;external;

  function __qam_init_getpgnos(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function __qam_init_getpgnos(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function __qam_init_recover(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function __qam_init_recover(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function __qam_mswap(_para1:PPAGE):longint;cdecl;external;

  function __qam_fprobe(_para1:PDB; _para2:db_pgno_t; _para3:pointer; _para4:qam_probe_mode; _para5:u_int32_t):longint;cdecl;external;

  function __qam_fclose(_para1:PDB; _para2:db_pgno_t):longint;cdecl;external;

  function __qam_fremove(_para1:PDB; _para2:db_pgno_t):longint;cdecl;external;

  function __qam_sync(_para1:PDB):longint;cdecl;external;

  function __qam_gen_filelist(_para1:PDB; _para2:PPQUEUE_FILELIST):longint;cdecl;external;

  function __qam_extent_names(_para1:PDB_ENV; _para2:Pchar; _para3:PPPchar):longint;cdecl;external;

  procedure __qam_exid(_para1:PDB; _para2:Pu_int8_t; _para3:u_int32_t);cdecl;external;


  function __qam_nameop(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:qam_name_op):longint;cdecl;external;

  function __qam_db_create(_para1:PDB):longint;cdecl;external;

  function __qam_db_close(_para1:PDB; _para2:u_int32_t):longint;cdecl;external;

  function __db_prqueue(_para1:PDB; _para2:PFILE; _para3:u_int32_t):longint;cdecl;external;



  function __qam_remove(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:PDB_LSN):longint;cdecl;external;




  function __qam_rename(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:Pchar; _para5:Pchar):longint;cdecl;external;


  function __qam_open(_para1:PDB; _para2:PDB_TXN; _para3:Pchar; _para4:db_pgno_t; _para5:longint; 
             _para6:u_int32_t):longint;cdecl;external;


  function __qam_set_ext_data(_para1:PDB; _para2:Pchar):longint;cdecl;external;


  function __qam_metachk(_para1:PDB; _para2:Pchar; _para3:PQMETA):longint;cdecl;external;


  function __qam_new_file(_para1:PDB; _para2:PDB_TXN; _para3:PDB_FH; _para4:Pchar):longint;cdecl;external;

  function __qam_incfirst_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_mvptr_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_del_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_delext_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_add_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __qam_stat(_para1:PDBC; _para2:pointer; _para3:u_int32_t):longint;cdecl;external;

  function __db_no_queue_am(_para1:PDB_ENV):longint;cdecl;external;

  function __qam_31_qammeta(_para1:PDB; _para2:Pchar; _para3:Pu_int8_t):longint;cdecl;external;

  function __qam_32_qammeta(_para1:PDB; _para2:Pchar; _para3:Pu_int8_t):longint;cdecl;external;

  function __qam_vrfy_meta(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PQMETA; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;

  function __qam_vrfy_data(_para1:PDB; _para2:PVRFY_DBINFO; _para3:PQPAGE; _para4:db_pgno_t; _para5:u_int32_t):longint;cdecl;external;

  function __qam_vrfy_structure(_para1:PDB; _para2:PVRFY_DBINFO; _para3:u_int32_t):longint;cdecl;external;


  function __qam_vrfy_walkqueue(_para1:PDB; _para2:PVRFY_DBINFO; _para3:pointer; _para4:function (_para1:pointer; _para2:pointer):longint; _para5:u_int32_t):longint;cdecl;external;


  function __qam_vrfy_walkqueue(_para1:PDB; _para2:PVRFY_DBINFO; _para3:pointer; _para4:function (_para1:pointer; _para2:pointer):longint; _para5:u_int32_t):longint;cdecl;external;


  function __qam_salvage(_para1:PDB; _para2:PVRFY_DBINFO; _para3:db_pgno_t; _para4:PPAGE; _para5:pointer; 
             _para6:function (_para1:pointer; _para2:pointer):longint; _para7:u_int32_t):longint;cdecl;external;

  function __rep_dbenv_create(_para1:PDB_ENV):longint;cdecl;external;

  function __rep_open(_para1:PDB_ENV):longint;cdecl;external;

  procedure __rep_elect_master(_para1:PDB_ENV; _para2:PREP; _para3:Plongint);cdecl;external;

  function __rep_process_message(_para1:PDB_ENV; _para2:PDBT; _para3:PDBT; _para4:Plongint; _para5:PDB_LSN):longint;cdecl;external;

  function __rep_process_txn(_para1:PDB_ENV; _para2:PDBT):longint;cdecl;external;

  function __rep_tally(_para1:PDB_ENV; _para2:PREP; _para3:longint; _para4:Plongint; _para5:u_int32_t; 
             _para6:u_int32_t):longint;cdecl;external;

  procedure __rep_cmp_vote(_para1:PDB_ENV; _para2:PREP; _para3:Plongint; _para4:PDB_LSN; _para5:longint; 
              _para6:longint; _para7:longint);cdecl;external;

  function __rep_cmp_vote2(_para1:PDB_ENV; _para2:PREP; _para3:longint; _para4:u_int32_t):longint;cdecl;external;

  function __rep_region_init(_para1:PDB_ENV):longint;cdecl;external;

  function __rep_region_destroy(_para1:PDB_ENV):longint;cdecl;external;

  procedure __rep_dbenv_refresh(_para1:PDB_ENV);cdecl;external;

  function __rep_dbenv_close(_para1:PDB_ENV):longint;cdecl;external;

  function __rep_preclose(_para1:PDB_ENV; _para2:longint):longint;cdecl;external;

  function __rep_check_alloc(_para1:PDB_ENV; _para2:PTXN_RECS; _para3:longint):longint;cdecl;external;


  function __rep_send_message(_para1:PDB_ENV; _para2:longint; _para3:u_int32_t; _para4:PDB_LSN; _para5:PDBT; 
             _para6:u_int32_t):longint;cdecl;external;

  function __rep_new_master(_para1:PDB_ENV; _para2:PREP_CONTROL; _para3:longint):longint;cdecl;external;

  function __rep_is_client(_para1:PDB_ENV):longint;cdecl;external;

  function __rep_noarchive(_para1:PDB_ENV):longint;cdecl;external;

  procedure __rep_send_vote(_para1:PDB_ENV; _para2:PDB_LSN; _para3:longint; _para4:longint; _para5:longint; 
              _para6:u_int32_t; _para7:longint; _para8:u_int32_t);cdecl;external;

  procedure __rep_elect_done(_para1:PDB_ENV; _para2:PREP);cdecl;external;

  function __rep_grow_sites(dbenv:PDB_ENV; nsites:longint):longint;cdecl;external;

  procedure __env_rep_enter(_para1:PDB_ENV);cdecl;external;

  procedure __env_rep_exit(_para1:PDB_ENV);cdecl;external;

  function __db_rep_enter(_para1:PDB; _para2:longint; _para3:longint):longint;cdecl;external;

  procedure __db_rep_exit(_para1:PDB_ENV);cdecl;external;

  procedure __op_rep_enter(_para1:PDB_ENV);cdecl;external;

  procedure __op_rep_exit(_para1:PDB_ENV);cdecl;external;

  procedure __rep_get_gen(_para1:PDB_ENV; _para2:Pu_int32_t);cdecl;external;

  function __txn_begin_pp(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PPDB_TXN; _para4:u_int32_t):longint;cdecl;external;

  function __txn_begin(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PPDB_TXN; _para4:u_int32_t):longint;cdecl;external;

  function __txn_xa_begin(_para1:PDB_ENV; _para2:PDB_TXN):longint;cdecl;external;

  function __txn_compensate_begin(_para1:PDB_ENV; txnp:PPDB_TXN):longint;cdecl;external;

  function __txn_commit(_para1:PDB_TXN; _para2:u_int32_t):longint;cdecl;external;

  function __txn_abort(_para1:PDB_TXN):longint;cdecl;external;

  function __txn_discard(_para1:PDB_TXN; flags:u_int32_t):longint;cdecl;external;

  function __txn_prepare(_para1:PDB_TXN; _para2:Pu_int8_t):longint;cdecl;external;

  function __txn_id(_para1:PDB_TXN):u_int32_t;cdecl;external;

  function __txn_set_timeout(_para1:PDB_TXN; _para2:db_timeout_t; _para3:u_int32_t):longint;cdecl;external;

  function __txn_checkpoint_pp(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:u_int32_t):longint;cdecl;external;

  function __txn_checkpoint(_para1:PDB_ENV; _para2:u_int32_t; _para3:u_int32_t; _para4:u_int32_t):longint;cdecl;external;

  function __txn_getckp(_para1:PDB_ENV; _para2:PDB_LSN):longint;cdecl;external;

  function __txn_activekids(_para1:PDB_ENV; _para2:u_int32_t; _para3:PDB_TXN):longint;cdecl;external;

  function __txn_force_abort(_para1:PDB_ENV; _para2:Pu_int8_t):longint;cdecl;external;

  function __txn_preclose(_para1:PDB_ENV):longint;cdecl;external;

  function __txn_reset(_para1:PDB_ENV):longint;cdecl;external;

  procedure __txn_updateckp(_para1:PDB_ENV; _para2:PDB_LSN);cdecl;external;


  function __txn_regop_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t; 
             _para6:int32_t; _para7:PDBT):longint;cdecl;external;

  function __txn_regop_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_regop_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_regop_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__txn_regop_args):longint;cdecl;external;

  function __txn_ckp_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:PDB_LSN; 
             _para6:PDB_LSN; _para7:int32_t; _para8:u_int32_t):longint;cdecl;external;

  function __txn_ckp_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_ckp_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_ckp_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__txn_ckp_args):longint;cdecl;external;

  function __txn_child_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t; 
             _para6:PDB_LSN):longint;cdecl;external;

  function __txn_child_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_child_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_child_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__txn_child_args):longint;cdecl;external;



  function __txn_xa_regop_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t; 
             _para6:PDBT; _para7:int32_t; _para8:u_int32_t; _para9:u_int32_t; _para10:PDB_LSN; 
             _para11:PDBT):longint;cdecl;external;

  function __txn_xa_regop_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_xa_regop_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_xa_regop_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__txn_xa_regop_args):longint;cdecl;external;

  function __txn_recycle_log(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LSN; _para4:u_int32_t; _para5:u_int32_t; 
             _para6:u_int32_t):longint;cdecl;external;

  function __txn_recycle_getpgnos(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_recycle_print(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_recycle_read(_para1:PDB_ENV; _para2:pointer; _para3:PP__txn_recycle_args):longint;cdecl;external;

  function __txn_init_getpgnos(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  function __txn_init_recover(_para1:PDB_ENV; _para2:PPfunction (_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint; _para3:Psize_t):longint;cdecl;external;

  procedure __txn_dbenv_create(_para1:PDB_ENV);cdecl;external;

  function __txn_set_tx_max(_para1:PDB_ENV; _para2:u_int32_t):longint;cdecl;external;

  function __txn_regop_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_xa_regop_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_ckp_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_child_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  function __txn_restore_txn(_para1:PDB_ENV; _para2:PDB_LSN; _para3:P__txn_xa_regop_args):longint;cdecl;external;

  function __txn_recycle_recover(_para1:PDB_ENV; _para2:PDBT; _para3:PDB_LSN; _para4:db_recops; _para5:pointer):longint;cdecl;external;

  procedure __txn_continue(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PTXN_DETAIL; _para4:size_t);cdecl;external;

  function __txn_map_gid(_para1:PDB_ENV; _para2:Pu_int8_t; _para3:PPTXN_DETAIL; _para4:Psize_t):longint;cdecl;external;

  function __txn_recover_pp(_para1:PDB_ENV; _para2:PDB_PREPLIST; _para3:longint; _para4:Plongint; _para5:u_int32_t):longint;cdecl;external;

  function __txn_recover(_para1:PDB_ENV; _para2:PDB_PREPLIST; _para3:longint; _para4:Plongint; _para5:u_int32_t):longint;cdecl;external;

  function __txn_get_prepared(_para1:PDB_ENV; _para2:PXID; _para3:PDB_PREPLIST; _para4:longint; _para5:Plongint; 
             _para6:u_int32_t):longint;cdecl;external;

  function __txn_open(_para1:PDB_ENV):longint;cdecl;external;

  function __txn_dbenv_refresh(_para1:PDB_ENV):longint;cdecl;external;

  procedure __txn_region_destroy(_para1:PDB_ENV; _para2:PREGINFO);cdecl;external;

  function __txn_stat_pp(_para1:PDB_ENV; _para2:PPDB_TXN_STAT; _para3:u_int32_t):longint;cdecl;external;

  function __txn_closeevent(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB):longint;cdecl;external;


  function __txn_remevent(_para1:PDB_ENV; _para2:PDB_TXN; _para3:Pchar; _para4:Pu_int8_t):longint;cdecl;external;


  procedure __txn_remrem(_para1:PDB_ENV; _para2:PDB_TXN; _para3:Pchar);cdecl;external;

  function __txn_lockevent(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB; _para4:PDB_LOCK; _para5:u_int32_t):longint;cdecl;external;

  procedure __txn_remlock(_para1:PDB_ENV; _para2:PDB_TXN; _para3:PDB_LOCK; _para4:u_int32_t);cdecl;external;

  function __txn_doevents(_para1:PDB_ENV; _para2:PDB_TXN; _para3:longint; _para4:longint):longint;cdecl;external;

  function __xa_get_txn(_para1:PDB_ENV; _para2:PPDB_TXN; _para3:longint):longint;cdecl;external;

  function __db_xa_create(_para1:PDB):longint;cdecl;external;

  function __db_rmid_to_env(rmid:longint; envp:PPDB_ENV):longint;cdecl;external;

  function __db_xid_to_txn(_para1:PDB_ENV; _para2:PXID; _para3:Psize_t):longint;cdecl;external;

  function __db_map_rmid(_para1:longint; _para2:PDB_ENV):longint;cdecl;external;

  function __db_unmap_rmid(_para1:longint):longint;cdecl;external;

  function __db_map_xid(_para1:PDB_ENV; _para2:PXID; _para3:size_t):longint;cdecl;external;

  procedure __db_unmap_xid(_para1:PDB_ENV; _para2:PXID; _para3:size_t);cdecl;external;


implementation


end.
