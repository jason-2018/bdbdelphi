unit ObjectDataSet;

interface
uses
  Forms, Classes, ObjectDB, DB, PropertyFields;

const
  BOOKMARK_LESS = -1;
  BOOKMARK_EQUAL = 0;
  BOOKMARK_GREATER = 1;
  BOOKMARK_UNKNOWN = 2;

  DEFAULT_STRING_PROPERTY_LENGTH = 255;

Type
  PObjectBookmark = ^TObjectBookmark;
  TObjectBookmark = record
    ListIndex: TGuid;
    ItemID: TGuid;
    Flag: TBookmarkFlag;
  end;

  TNeedClassEvent = procedure( Sender: TObject; var ObjectClass: TClass ) of object;
  TCreateObjectEvent = procedure( Sender: TObject; var NewObject: TPersistObj ) of object;

  TCustomDBODataSet = class(TDataSet)
  private
    { Private declarations }
    FOpened: Boolean;
    FUpdatingList: Boolean;
    FBookmarkOffset: Integer;
    FCalcFieldsOffset: Integer;
    FBufferSize: Integer;

    FCurrentObject: TGuid;

    FObjects: TBerkeleyDB;

    FFilterBuffer: PChar;
    FObjectClass: TClass;
    FPropertyFields: TPropertyFields;
    FDefaultStringLength: Integer;
    FReadOnly: Boolean;

    FOnCreateObject: TCreateObjectEvent;
    FOnNeedClass: TNeedClassEvent;
    FObjectClassName: string;
    FdataSet : TDataSet;

    function LocateRecord(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions; SyncCursor: Boolean): Boolean;
    function MatchFieldValue( Field: TField; Value: Variant;
      Options: TLocateOptions ): Boolean;
    procedure NeedObjectClass;
    procedure SetObjectClass(const Value: TClass);
    procedure SetDefaultStringLength(const Value: Integer);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetObjectClassName(const Value: string);
  protected
    { record buffer methods }
    function AllocRecordBuffer: PChar; override;
    procedure BufferToCurrentObject( Buffer: PChar ); virtual;
    procedure ClearCalcFields(Buffer: PChar); override;
    procedure CurrentObjectToBuffer( Buffer: PChar ); virtual;
    procedure FreeRecordBuffer(var Buffer: PChar); override;
    function GetActiveRecordBuffer: PChar;
    function GetRecord(Buffer: PChar; GetMode: TGetMode;
      DoCheck: Boolean): TGetResult; override;
    function GetRecordSize: Word; override;
    procedure InternalInitRecord(Buffer: PChar); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;

    { bookmark methods }
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    procedure InternalGotoBookmark(Bookmark: Pointer); override;
    procedure InternalSetToRecord(Buffer: PChar); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;

    { navigational methods }
    procedure InternalFirst; override;
    procedure InternalLast; override;


    { editing methods }
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    procedure InternalDelete; override;
    procedure InternalPost; override;

    { dataset management methods }
    procedure InternalClose; override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalOpen; override;
    function IsCursorOpen: Boolean; override;
    procedure SetFiltered( Value: Boolean ); override;

    { supporting methods }
    procedure CalculateBufferOffsets; virtual;
    function GetNewObject: TPersistObj; virtual;
    procedure ListUpdated; virtual;
    function RecordFilter( Buffer: PChar ): Boolean; virtual;

    { properties }
    property DefaultStringLength: Integer read FDefaultStringLength  write SetDefaultStringLength default DEFAULT_STRING_PROPERTY_LENGTH;
    property ObjectClass: TClass read FObjectClass write SetObjectClass;
    property ObjectClassName: string read FObjectClassName write SetObjectClassName;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property DataSet : TDataSet read FDataset write FDataSet;
    property ObjectDB : TberkeleyDB read FObjects write FObjects;

    { events }
    property OnCreateObject: TCreateObjectEvent read FOnCreateObject write FOnCreateObject;
    property OnNeedClass: TNeedClassEvent read FOnNeedClass write FOnNeedClass;
  public
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;

    { record buffer methods }
    function GetFieldData( Field: TField; Buffer: Pointer ): Boolean; override;

    { bookmark methods }
    function BookmarkValid(Bookmark: TBookmark): Boolean; override;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;

    { record number methods }
    function GetRecNo: Integer; override;
    function GetRecordCount: Integer; override;
    function IsSequenced: Boolean; override;
    //procedure SetRecNo( Value: Integer ); override;


    function GetCanModify: Boolean; override;
    function Locate(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
      const ResultFields: string): Variant; override;

    { TList compatible methods }
    function Add( AnObject: TPersistObj ): Tguid;
    procedure BeginUpdate;
    //procedure Clear( const FreeObjects: Boolean = False );
    procedure Delete( const Index: TGuid; const FreeObject: Boolean = False ); overload;
    procedure EndUpdate;
    function IndexOf( const AnObject: TPersistObj ): TGuid;
    procedure Insert(Const Index: TGuid; Const AnObject: TPersistObj );
    procedure Remove( const AnObject: TPersistObj; const FreeObject: Boolean = False );

  published
    { Published declarations }
  end;


  TDBODataSet = class(TCustomDBODataSet)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    property ObjectClass;

  published
    { Published declarations }

    property DataSet;
        
    { properties from TDataSet }
    property Active;
    property AutoCalcFields;
    property Filtered;
    property ObjectView;
    property ReadOnly;

    { properties from TCustomDBODataSet }
    property DefaultStringLength;
    property ObjectClassName;
    property ObjectDB;

    { events from TDataSet }
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;

    { events from TCustomDBODataSet }
    property OnCreateObject;
    property OnNeedClass;
  end;


procedure Register;
  
implementation
uses
  Windows,
  SysUtils,
  ObjectDataSetStrings,
  PropertyField,
  Variants;

procedure Register;
begin
  RegisterComponents('Berkeley ODB', [TDBODataSet]);
end;

{ TCustomDBODataSet }

procedure TCustomDBODataSet.SetObjectClass(
  const Value: TClass);
begin
  // Change of object class is not allowed when dataset is open
  CheckInactive();

  if Value <> nil then
  begin
    if Value.ClassInfo = nil then
    begin
      DatabaseError(OBJDATA_NO_CLASSINFO);
    end;

    FObjectClass := Value;
  end;
end;

procedure TCustomDBODataSet.SetDefaultStringLength(
  const Value: Integer);
{ set the default length of fields based on string properties }
begin
  FDefaultStringLength := Value;

  FPropertyFields.DefaultStringLength := DefaultStringLength;
end;

procedure TCustomDBODataSet.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
end;


function TCustomDBODataSet.AllocRecordBuffer: PChar;
begin
  GetMem( Result, FBufferSize );
end;

procedure TCustomDBODataSet.BufferToCurrentObject(Buffer: PChar);
{ set the current objects properties from the field data in 'Buffer' }
begin
  FPropertyFields.GetFromBuffer( GetActiveRecordBuffer, FObjects[ FCurrentObject ] );
end;

procedure TCustomDBODataSet.ClearCalcFields(Buffer: PChar);
begin
  FillChar( Buffer[ FCalcFieldsOffset ], CalcFieldsSize, 0 );
end;


procedure TCustomDBODataSet.CurrentObjectToBuffer(Buffer: PChar);
{ copy the data of the current object into 'Buffer' }
begin

  FPropertyFields.SetToBuffer( Buffer, FObjects[ FCurrentObject ] );

  // set the bookmark information to reflect that this is the current record
  with PObjectBookmark( Buffer + FBookmarkOffset )^ do
  begin
    ListIndex := FCurrentObject;
    ItemID := FObjects[ FCurrentObject ].Guid;
    Flag := bfCurrent;
  end;

end;

procedure TCustomDBODataSet.FreeRecordBuffer(var Buffer: PChar);
begin
  FreeMem( Buffer, FBufferSize );
end;

function TCustomDBODataSet.GetActiveRecordBuffer: PChar;
{ return the record buffer to use for the current state of the dataset }
begin
  case State of
    dsBrowse:
      begin
        if IsEmpty then
        begin
          Result := nil;
        end
        else
        begin
          Result := ActiveBuffer;
        end;
      end;
    dsCalcFields:
      begin
        Result := CalcBuffer;
      end;
    dsEdit, dsInsert:
      begin
        Result := ActiveBuffer;
      end;
    dsFilter:
      begin
        Result := FFilterBuffer;
      end;
  else
    Result := nil;
  end;
end;

function TCustomDBODataSet.GetRecord(Buffer: PChar; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
{ retrieve the record data for the current, next or prior record depending on
  'GetMode'

  Returns: grOK if the record data is retrieved successfully
           grBOF if no prior record exists
           grEOF if no next record exists
           grError on error }
var
  Accepted: Boolean;
  aObject : TPersistObj;
begin
  if FObjects.Count < 1 then
  begin
    Result := grEOF;
  end
  else
  begin
    Accepted := False;
    repeat
      Result := grOK;
      case GetMode of
        gmPrior:
          begin
            // move to previous record
            //Dec( FCurrentObject );
            aObject:=FObjects.Prev;
            if aObject <> Nil then
              FCurrentObject:=aObject.Guid
            else
              Result:=grBOF;
          end;
        gmCurrent: ;
          // complain if the current object is invalid
          //if (FCurrentObject < 0) or (FCurrentObject = FObjects.Count) then
          //begin
          //  Result := grError;
          //end;
        gmNext:
          begin
            // move to next record
            //Inc( FCurrentObject )
            aObject:=FObjects.Next;
            if aObject <> Nil then
              FCurrentObject:=aObject.Guid
            else
              Result:=grEOF;
          end;
      end;

      if Result = grOk then
      begin
        // copy the record data of the new current object
        CurrentObjectToBuffer( Buffer );

        GetCalcFields( Buffer );

        // check for filtered records
        if Filtered then
        begin
          Accepted := RecordFilter( Buffer );
          if (GetMode = gmCurrent) and (not Accepted) then
          begin
            Result := grError;
          end;
        end
        else
        begin
          Accepted := True;
        end;
      end
      else if (Result = grError) and (DoCheck) then
      begin
        DatabaseError( OBJDATA_GETRECORD_ERROR );
      end;
    until (Result <> grOk) or (Accepted);
  end;

end;

function TCustomDBODataSet.GetRecordSize: Word;
begin
  Result := FPropertyFields.BufferSize;
end;

procedure TCustomDBODataSet.InternalInitRecord(Buffer: PChar);
{ clear the record buffer }
begin
  FillChar( Buffer^, FBufferSize, 0 );

  // Bookmark as an empty buffer
  PObjectBookmark( Buffer + FBookmarkOffset )^.Flag := bfBOF;
end;

procedure TCustomDBODataSet.SetFieldData(Field: TField;
  Buffer: Pointer);
{ update the current record buffer with data for 'Field' from 'Buffer' }
begin
  FPropertyFields.Fields[ Field.FieldNo-1 ].SetField( GetActiveRecordBuffer, Buffer );

  DataEvent( deFieldChange, LongInt( Field ) );
end;

procedure TCustomDBODataSet.GetBookmarkData(Buffer: PChar;
  Data: Pointer);
begin
  Move( (Buffer + FBookmarkOffset)^, Data^, sizeof( TObjectBookmark ) );
end;

function TCustomDBODataSet.GetBookmarkFlag(
  Buffer: PChar): TBookmarkFlag;
begin
  Result := PObjectBookmark( Buffer + FBookmarkOffset )^.Flag;
end;

procedure TCustomDBODataSet.InternalGotoBookmark(Bookmark: Pointer);
begin
  with PObjectBookmark( Bookmark )^ do
  begin
    FCurrentObject := FObjects[ItemID].Guid;
  end;
end;

procedure TCustomDBODataSet.InternalSetToRecord(Buffer: PChar);
begin
  // use the bookmark information to find the record
  InternalGotoBookmark( Buffer + FBookmarkOffset );
end;

procedure TCustomDBODataSet.SetBookmarkData(Buffer: PChar;
  Data: Pointer);
begin
  Move( Data^, (Buffer + FBookmarkOffset)^, sizeof( TObjectBookmark ) );
end;

procedure TCustomDBODataSet.SetBookmarkFlag(Buffer: PChar;
  Value: TBookmarkFlag);
begin
  PObjectBookmark( Buffer + FBookmarkOffset )^.Flag := Value;
end;

procedure TCustomDBODataSet.InternalFirst;
begin
  // indicate BOF position
  FCurrentObject:=FObjects.first.Guid; // := -1;
end;

procedure TCustomDBODataSet.InternalLast;
begin
  // indicate EOF position
  FCurrentObject := FObjects.Last.Guid;
end;

procedure TCustomDBODataSet.InternalAddRecord(Buffer: Pointer;
  Append: Boolean);
{ add a new record using the field data in 'Buffer' }
var
  NewObject: TPersistObj;
begin
  NewObject := GetNewObject();

  if Append then
  begin
    FCurrentObject :=NewObject.Guid;
    FObjects.Add( NewObject );
  end
  else
  begin
    FObjects.Insert( FCurrentObject, NewObject );
  end;

  BufferToCurrentObject( Buffer );
end;

procedure TCustomDBODataSet.InternalDelete;
begin
  // remove the object from the list and free it
  FObjects.Delete( FCurrentObject,True);
end;

procedure TCustomDBODataSet.InternalPost;
var
  NewObject: TPersistObj;
begin

  if State = dsInsert then
  begin
    NewObject := GetNewObject();

    // add/insert the new object onto the list
    //if (FCurrentObject >= FObjects.Count) or (FCurrentObject = -1) then
    //begin
    //  FCurrentObject := FObjects.Add( NewObject );
    //end
    //else begin
      FObjects.Insert( FCurrentObject, NewObject );
    //end;

  end;

  // copy the field data to the objects properties
  BufferToCurrentObject( GetActiveRecordBuffer );
end;

procedure TCustomDBODataSet.InternalClose;
begin
  // release the field objects
  BindFields( False );

  if DefaultFields then
  begin
    DestroyFields();
  end;

  // update internal state
  FOpened := False;
end;

procedure TCustomDBODataSet.InternalHandleException;
begin
  Application.HandleException( Self );
end;

procedure TCustomDBODataSet.InternalInitFieldDefs;
{ create field definitions based on object properties }
begin
  NeedObjectClass();

  // build new field definitions from the objects RTTI properties
  FieldDefs.Clear();
  FPropertyFields.BuildList( FObjectClass );
  FPropertyFields.CreateFieldDefs( FieldDefs );
end;

procedure TCustomDBODataSet.InternalOpen;
begin

  InternalInitFieldDefs();

  if DefaultFields then
  begin
    CreateFields();
  end;

  // connect fields to object properties
  BindFields( True );

  // pre calculate data, calculated field positions, etc.
  CalculateBufferOffsets();

  // move to BOF
  //FCurrentObject := -1;

  FOpened := True;
end;

function TCustomDBODataSet.IsCursorOpen: Boolean;
begin
  Result := FOpened;
end;

procedure TCustomDBODataSet.SetFiltered(Value: Boolean);
begin
  if Active then
  begin
    CheckBrowseMode();
    if Filtered <> Value then
    begin
      inherited SetFiltered( Value );
    end;
    First();
  end
  else begin
    inherited SetFiltered( Value );
  end;
end;


{ supporting methods }


procedure TCustomDBODataSet.CalculateBufferOffsets;
{ calculate various offsets into the record buffer }
begin
  FBookmarkOffset := FPropertyFields.BufferSize;
  FCalcFieldsOffset := FBookmarkOffset + sizeof( TObjectBookmark );

  // calculate size of buffer required for each record
  FBufferSize := FCalcFieldsOffset +  + CalcFieldsSize;
end;

function TCustomDBODataSet.GetNewObject: TPersistObj;
{ return a new instance of the class the dataset is using }
begin
  if Assigned( FOnCreateObject ) then
  begin
    { call the OnCreateObject event to allow objects with constructors other
      than the default create, since objects cannot
      override the default TObject constructor Create }
    FOnCreateObject( Self, Result );
  end
  else begin
    // use the default constructor
    Result := FObjectClass.Create() as TPersistObj;
  end;
end;

procedure TCustomDBODataSet.ListUpdated;
{ Update dataset after list has been modified }
begin
  if (not FUpdatingList) and Active then
  begin
    Refresh();
  end;
end;

function TCustomDBODataSet.RecordFilter( Buffer: PChar ): Boolean;
{ return true if record is accepted by filter event }
var
  SaveState: TDataSetState;
begin
  // use a temporary buffer to filter records
  SaveState := SetTempState( dsFilter );
  FFilterBuffer := Buffer;

  Result := True;
  if Assigned( OnFilterRecord ) then
  begin
    try
      OnFilterRecord( Self, Result );
    except
      InternalHandleException();
    end;
  end;

  RestoreState( SaveState );
end;


{ constructor and destructor }


constructor TCustomDBODataSet.Create(AOwner: TComponent);
begin
  inherited;

  FObjects := Nil;
  FPropertyFields := TPropertyFields.Create();

  // Indicate that bookmarks are available
  BookmarkSize := Sizeof( TObjectBookmark );

  { no length can be determined for fields based on long string properties so a
    default length is used instead }
  DefaultStringLength := DEFAULT_STRING_PROPERTY_LENGTH;

end;

destructor TCustomDBODataSet.Destroy;
begin
  FObjects.Free();
  FPropertyFields.Free();
  inherited;
end;

function TCustomDBODataSet.GetFieldData(Field: TField;
  Buffer: Pointer): Boolean;
{ put the data for 'Field' from the current record buffer into 'Buffer' }
var
  ActiveRecordBuffer: PChar;
begin
  ActiveRecordBuffer := GetActiveRecordBuffer();

  Result := (ActiveRecordBuffer <> nil);

  if Result then
  begin
    Result := FPropertyFields.Fields[ Field.FieldNo-1 ].GetField( ActiveRecordBuffer, Buffer );
  end;
end;

function TCustomDBODataSet.BookmarkValid(Bookmark: TBookmark): Boolean;
begin
  // bookmark is valid if the object is found in the list
  Result := FObjects[ PObjectBookmark( Bookmark )^.ItemID ] <> Nil;
end;

function TCustomDBODataSet.CompareBookmarks(Bookmark1,
  Bookmark2: TBookmark): Integer;
const
  NilResults: array[ Boolean, Boolean ] of Integer =
    (
    (BOOKMARK_UNKNOWN, BOOKMARK_LESS),
    (BOOKMARK_GREATER, BOOKMARK_EQUAL)
    );
var
  Index1, Index2: TGuid;
begin

  // Compare nil bookmark pointers
  Result := NilResults[ Bookmark1 = nil, Bookmark2 = nil ];

  if Result = BOOKMARK_UNKNOWN then
  begin

    // get object indexes for position comparison
    Index1 := FObjects[ PObjectBookmark( Bookmark1 )^.ItemID ].Guid;
    Index2 := FObjects[ PObjectBookmark( Bookmark2 )^.ItemID ].Guid;

    // compare indexes
    {
    if Index1 < Index2 then
    begin
      Result := BOOKMARK_LESS;
    end
    else if Index1 = Index2 then
    begin
      Result := BOOKMARK_EQUAL;
    end
    else
    begin
      Result := BOOKMARK_GREATER;
    end;
    }
  end;

end;

function TCustomDBODataSet.GetRecNo: Integer;
begin
  UpdateCursorPos;
  Result:=FObjects.Recno;
  {
  if (FCurrentObject = -1) and (RecordCount > 0) then
  begin
    Result := 1;
  end
  else begin
    Result := (FCurrentObject+1);
  end;
  }
end;

function TCustomDBODataSet.GetRecordCount: Integer;
var
  OldState: TDataSetState;
  FilterBuffer: PChar;
  OldObject: TGuid;
begin
  CheckActive;

  if not Filtered then
  begin
    Result := FObjects.Count;
  end
  else
  begin
    Result := 0;

    // count filtered objects
    OldObject := FCurrentObject;
    OldState := SetTempState( dsBrowse );
    try
      // use temporary buffer for filtering
      FilterBuffer := AllocRecordBuffer;
      try
        InternalFirst;

        while GetRecord( FilterBuffer, gmNext, True ) = grOk do
        begin
          Inc( Result );
        end;
      finally
        FreeRecordBuffer( FilterBuffer );
      end;
    finally
      RestoreState( OldState );
      FCurrentObject := OldObject;
    end;
  end;
end;

function TCustomDBODataSet.IsSequenced: Boolean;
{ return true if records can be located by sequence number }
begin
  Result := not Filtered;
end;

{
procedure TCustomDBODataSet.SetRecNo( Value: Integer );
var
  NewObjectIndex: TGuid;
begin
  if (Value >= 0) and (Value < FObjects.Count) then
  begin
    NewObjectIndex := (Value-1);

    if (NewObjectIndex <> FCurrentObject)
    then
    begin
      DoBeforeScroll();

      FCurrentObject := NewObjectIndex;
      Resync( [] );

      DoAfterScroll();
    end;
  end;
end;
}

function TCustomDBODataSet.Add(AnObject: TPersistObj): TGuid;
begin
  Result:=AnObject.Guid;
  FObjects.Add( AnObject );
  ListUpdated();
end;

procedure TCustomDBODataSet.BeginUpdate;
{ Prevent dataset refreshing while using Add, Insert, ... }
begin
  FUpdatingList := True;
end;


procedure TCustomDBODataSet.Delete( const Index: TGuid; const FreeObject: Boolean);
begin
  FObjects.Delete( Index, FreeObject );
  ListUpdated();
end;

procedure TCustomDBODataSet.EndUpdate;
{ Refresh dataset after object list has been updated with Add, Insert, ... }
begin
  if FUpdatingList then
  begin
    FUpdatingList := False;

    ListUpdated();
  end;
end;

function TCustomDBODataSet.IndexOf( const AnObject: TPersistObj): TGuid;
begin
  //Result := FObjects.IndexOf( AnObject );
end;

procedure TCustomDBODataSet.Insert(Const Index: TGuid; const AnObject: TPersistObj);
begin
  FObjects.Insert( Index, AnObject );

  ListUpdated();
end;

procedure TCustomDBODataSet.Remove(const AnObject: TPersistObj; const FreeObject: Boolean);
begin
  FObjects.Delete( AnObject.Guid, FreeObject );

  ListUpdated();
end;

function TCustomDBODataSet.GetCanModify: Boolean;
begin
  Result := (not FReadOnly);
end;

function TCustomDBODataSet.Locate(const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
begin
  DoBeforeScroll();

  Result := LocateRecord( KeyFields, KeyValues, Options, True );

  if Result then
  begin
    Resync( [rmExact, rmCenter] );

    DoAfterScroll();
  end;
end;


procedure TCustomDBODataSet.NeedObjectClass;
{ ensure that the object class is valid }
begin
  if (not Assigned( FObjectClass )) and (Assigned( FOnNeedClass )) then
  begin
    FOnNeedClass( Self, FObjectClass );
  end;

  // cannot continue without valid class
  if not Assigned( FObjectClass ) then
  begin
    DatabaseError( OBJDATA_NO_CLASS_SPECIFIED );
  end;
end;

function TCustomDBODataSet.LocateRecord(const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions;
  SyncCursor: Boolean): Boolean;
var
  Fields: TList;
  FieldCount: Integer;
  OldObject: TGuid;
  Index: Integer;
begin
  CheckBrowseMode();
  CursorPosChanged();

  Result := False;

  Fields := TList.Create();
  try
    GetFieldList( Fields, KeyFields );
    FieldCount := Fields.Count;

    // use filter state to provide temporary buffer for record matching
    OldObject := FCurrentObject;
    SetTempState( dsFilter );
    FFilterBuffer := TempBuffer();
    try
      InternalFirst();

      while GetRecord( FFilterBuffer, gmNext, True ) = grOk do
      begin

        for Index := 0 to (FieldCount-1) do
        begin
          if FieldCount = 1 then
          begin
            Result := MatchFieldValue( TField( Fields[ Index ] ), KeyValues, Options );
          end
          else
          begin
            Result := MatchFieldValue( TField( Fields[ Index ] ), KeyValues[ Index ], Options );
          end;
          if not Result then
          begin
            Break;
          end;
        end;

        if Result then
        begin
          Break;
        end;
      end;

      if not (Result and SyncCursor) then
      begin
        FCurrentObject := OldObject;
    end;
    finally
      RestoreState( dsBrowse );
    end;
  finally
    Fields.Free();
  end;
end;

function TCustomDBODataSet.MatchFieldValue(Field: TField;
  Value: Variant; Options: TLocateOptions): Boolean;
var
  FieldValue: string;
begin
  if Field.DataType = ftString then
  begin
    FieldValue := Field.Value;

    // trim field string to partial string length to simplify compare
    if loPartialKey in Options then
    begin
      if Length( FieldValue ) > Length( Value ) then
      begin
        SetLength( FieldValue, Length( Value ) );
      end;
    end;

    if loCaseInsensitive in Options then
    begin
      Result := (AnsiCompareText( Value, FieldValue ) = 0);
    end
    else
    begin
      Result := (AnsiCompareStr( Value, FieldValue ) = 0);
    end;
  end
  else
  begin
    Result := (Field.Value = Value);
  end;
end;

function TCustomDBODataSet.Lookup(const KeyFields: string;
  const KeyValues: Variant; const ResultFields: string): Variant;
begin
  Result := Null;

  if LocateRecord(KeyFields, KeyValues, [], False) then
  begin
    // use filter state as the data is stored in the filter buffer in LocateRecord
    SetTempState(dsFilter);
    try
      Result := FieldValues[ResultFields];
    finally
      RestoreState(dsBrowse);
    end;
  end;
end;

procedure TCustomDBODataSet.SetObjectClassName(const Value: string);
begin
  FObjectClassName := Value;
  SetObjectClass( GetClass( FObjectClassName ) );
end;

end.
 