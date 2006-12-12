unit BerkeleyStat;

interface
uses
  Classes,
  BerkeleyDB40520,
  BerkeleyEnv,
  BerkeleyDB;

Type
  TBerkeleyBtreeStat = class(TPersistent)
  private
    FStat : DB_BTREE_STAT;
    FDB   : TCoreBerkeleyDB;
  public
    Constructor Create(Const DB : TCoreBerkeleyDB);

    procedure Get;
    procedure Print(Strings : TStrings);

    property magic      : u_int32_t read FStat.bt_magic      ; (* Magic number. *)
    property version    : u_int32_t read FStat.bt_version    ; (* Version number. *)
    property metaflags  : u_int32_t read FStat.bt_metaflags  ; (* Metadata flags. *)
    property nkeys      : u_int32_t read FStat.bt_nkeys      ; (* Number of unique keys. *)
    property ndata      : u_int32_t read FStat.bt_ndata      ; (* Number of data items. *)
    property pagesize   : u_int32_t read FStat.bt_pagesize   ; (* Page size. *)
    property minkey     : u_int32_t read FStat.bt_minkey     ; (* Minkey value. *)
    property re_len     : u_int32_t read FStat.bt_re_len     ; (* Fixed-length record length. *)
    property re_pad     : u_int32_t read FStat.bt_re_pad     ; (* Fixed-length record pad. *)
    property levels     : u_int32_t read FStat.bt_levels     ; (* Tree levels. *)
    property int_pg     : u_int32_t read FStat.bt_int_pg     ; (* Internal pages. *)
    property leaf_pg    : u_int32_t read FStat.bt_leaf_pg    ; (* Leaf pages. *)
    property dup_pg     : u_int32_t read FStat.bt_dup_pg     ; (* Duplicate pages. *)
    property over_pg    : u_int32_t read FStat.bt_over_pg    ; (* Overflow pages. *)
    property empty_pg   : u_int32_t read FStat.bt_empty_pg   ; (* Empty pages. *)
    property free       : u_int32_t read FStat.bt_free       ; (* Pages on the free list. *)
    property int_pgfree : u_int32_t read FStat.bt_int_pgfree ; (* Bytes free in internal pages. *)
    property leaf_pgfree: u_int32_t read FStat.bt_leaf_pgfree; (* Bytes free in leaf pages. *)
    property dup_pgfree : u_int32_t read FStat.bt_dup_pgfree ; (* Bytes free in duplicate pages. *)
    property over_pgfree: u_int32_t read FStat.bt_over_pgfree; (* Bytes free in overflow pages. *)
  end;


implementation
uses
  Sysutils;

{ TBerkeleyBtreeStat }

constructor TBerkeleyBtreeStat.Create(const DB: TCoreBerkeleyDB);
begin
  Inherited Create;
  FDB:=DB;

end;

procedure TBerkeleyBtreeStat.Get;
var
  P : PDB_BTREE_STAT;
begin
  P:=Nil;
  if Assigned(FDB.DB) then
  begin
    Check(FDB.DB.stat(FDB.DB,Nil,@P,DB_FAST_STAT));
    Fstat:=DB_BTREE_STAT(p^);
  end;
end;

procedure TBerkeleyBtreeStat.Print(Strings: TStrings);
begin
  Get;
  
  Strings.Add('magic       :'+IntToStr(FStat.bt_magic));
  Strings.Add('version     :'+IntToStr(FStat.bt_version));
  Strings.Add('metaflags   :'+IntToStr(FStat.bt_metaflags));
  Strings.Add('nkeys       :'+IntToStr(FStat.bt_nkeys));
  Strings.Add('ndata       :'+IntToStr(FStat.bt_ndata));
  Strings.Add('pagesize    :'+IntToStr(FStat.bt_pagesize));
  Strings.Add('minkey      :'+IntToStr(FStat.bt_minkey));
  Strings.Add('re_len      :'+IntToStr(FStat.bt_re_len));
  Strings.Add('re_pad      :'+IntToStr(FStat.bt_re_pad));
  Strings.Add('levels      :'+IntToStr(FStat.bt_levels));
  Strings.Add('int_pg      :'+IntToStr(FStat.bt_int_pg));
  Strings.Add('leaf_pg     :'+IntToStr(FStat.bt_leaf_pg));
  Strings.Add('dup_pg      :'+IntToStr(FStat.bt_dup_pg));
  Strings.Add('over_pg     :'+IntToStr(FStat.bt_over_pg));
  Strings.Add('empty_pg    :'+IntToStr(FStat.bt_empty_pg));
  Strings.Add('free        :'+IntToStr(FStat.bt_free));
  Strings.Add('int_pgfree  :'+IntToStr(FStat.bt_int_pgfree));
  Strings.Add('leaf_pgfree :'+IntToStr(FStat.bt_leaf_pgfree));
  Strings.Add('dup_pgfree  :'+IntToStr(FStat.bt_dup_pgfree));
  Strings.Add('over_pgfree :'+IntToStr(FStat.bt_over_pgfree));
end;

end.
