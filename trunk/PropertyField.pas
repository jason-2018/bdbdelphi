{
  TPropertyField

  Copyright © Paul Johnson 2000
  All rights reserved.


  Class to map a published property of an object to a field buffer.
  (created for use with the TObjectDataset component)
}
unit PropertyField;

interface

uses
  Classes, TypInfo, DB, SysUtils, PropertyInfo;

const
  FIELD_NULL = 0;
  FIELD_VALID = 1;

type
  PByte = ^Byte;
  PLongInt = ^LongInt;
  PDouble = ^Double;
  TIntegerSet = set of 0..SizeOf(Integer) * 8 - 1;
  PWordBool = ^WordBool;

  PNullFieldFlag = ^TNullFieldFlag;
  TNullFieldFlag = Byte;


  TPropertyField = class
  private
    FParent: TPropertyField;
    FOffset: Integer;
    FDataOffset: Integer;
    FFieldNo: Integer;
    FSize: Integer;
    FDataType: TFieldType;
    FPropertyInfo: TPropertyInfo;
    FDataSize: Integer;
    FSubFields: TList;

    FName: string;

    function GetSubField(Index: Integer): TPropertyField;
    function GetSubFieldCount: Integer;
    procedure SetOffset(const Value: Integer);
  protected
    procedure AddSubField( PropertyField: TPropertyField );
    function GetObject( ParentObject: TObject ): TObject;

    procedure InternalGetObjectProperty( FieldBuffer: PChar; FObject: TObject ); virtual; abstract;
    procedure InternalSetObjectProperty( FieldBuffer: PChar; FObject: TObject ); virtual; abstract;

    property DataOffset: Integer read FDataOffset write FDataOffset;
  public
    constructor Create( FieldPropertyInfo: TPropertyInfo ); virtual;
    class function CreatePropertyField( PropertyInfo: TPropertyInfo;
      DefaultStringLength: Integer ): TPropertyField;    
    destructor Destroy; override;

    procedure PrepareFieldDef( FieldDef: TFieldDef );

    procedure GetObjectProperty( FieldBuffer: PChar; FObject: TObject ); virtual;
    procedure SetObjectProperty( FieldBuffer: PChar; FObject: TObject ); virtual;

    function GetField( FieldBuffer: PChar; FieldData: PChar ): Boolean; virtual;
    procedure SetField( FieldBuffer: PChar; FieldData: PChar ); virtual;

    property DataType: TFieldType read FDataType write FDataType;
    property Name: string read FName write FName;
    property Size: Integer read FSize write FSize;
    property DataSize: Integer read FDataSize write FDataSize;
    property FieldNo: Integer read FFieldNo write FFieldNo;
    property PropertyInfo: TPropertyInfo read FPropertyInfo;
    property Offset: Integer read FOffset write SetOffset;
    property Parent: TPropertyField read FParent write FParent;
    property SubFieldCount: Integer read GetSubFieldCount;
    property SubFields[ Index: Integer ]: TPropertyField read GetSubField;
  end;


implementation


uses
  ObjectPropertyField,
  CurrencyPropertyField,
  FloatPropertyField,
  OrdinalPropertyField,
  Int64PropertyField,
  DateTimePropertyField,
  StringPropertyField,
  SetPropertyField;

const
  DATETIME_TYPENAME = 'TDateTime';
  DATE_TYPENAME = 'TDate';
  TIME_TYPENAME = 'TTime';
  BOOLEAN_TYPENAME = 'Boolean';
  
{ TPropertyField }

procedure TPropertyField.PrepareFieldDef( FieldDef: TFieldDef );
var
  SubIndex: Integer;
begin
  FieldDef.DataType := FDataType;
  FieldDef.FieldNo := FFieldNo;
  FieldDef.Name := FName;
  FieldDef.Size := FSize;
  FieldDef.Required := False;

  // read only properties become read only fields
  if PropertyInfo.SetProcedure = nil then
  begin
    FieldDef.Attributes := FieldDef.Attributes + [DB.faReadOnly];
  end;

  // add child field definitions
  for SubIndex := 0 to (SubFieldCount-1) do
  begin
    SubFields[ SubIndex ].PrepareFieldDef( FieldDef.AddChild );
  end;
end;

function TPropertyField.GetField(FieldBuffer, FieldData: PChar): Boolean;
begin
  Result := PByte( FieldBuffer + FOffset )^ = FIELD_VALID;
  
  if Result then begin
    Move( (FieldBuffer + FDataOffset)^, FieldData^, FDataSize );
  end;
end;

procedure TPropertyField.SetField(FieldBuffer, FieldData: PChar);
begin
  if FieldData <> nil then
  begin
    PByte( FieldBuffer + FOffset )^ := FIELD_VALID;

    Move( FieldData^, (FieldBuffer + FDataOffset)^, FDataSize );
  end
  else
  begin
    PByte( FieldBuffer + FOffset )^ := FIELD_NULL;
  end;
end;

function TPropertyField.GetSubField(Index: Integer): TPropertyField;
begin
  Result := FSubFields.Items[ Index ];
end;

procedure TPropertyField.AddSubField(PropertyField: TPropertyField);
begin
  PropertyField.Parent := Self;
  FSubFields.Add( PropertyField );
end;

function TPropertyField.GetSubFieldCount: Integer;
begin
  Result := FSubFields.Count;
end;

constructor TPropertyField.Create( FieldPropertyInfo: TPropertyInfo );
begin
  inherited Create();

  FSubFields := TList.Create();

  FPropertyInfo := FieldPropertyInfo;

  FName := PropertyInfo.Name;
  FSize := 0;
end;

destructor TPropertyField.Destroy;
begin
  FSubFields.Free();

  inherited;
end;

function TPropertyField.GetObject(ParentObject: TObject): TObject;
{ get the object for this property from the parent object }
var
  ParentsActualObject: TObject;
begin
  if (FParent <> nil) and (FParent is TObjectPropertyField) then
  begin
    // use the parent property's object }
    ParentsActualObject := Parent.GetObject( ParentObject );

    if ParentsActualObject <> nil then
    begin
      Result := TObjectPropertyField( Parent ).ClassPropertyInfo.GetClassProperty( ParentsActualObject );
    end
    else
    begin
      Result := nil;
    end;
  end
  else begin
    // use the given object if no parent property exists }
    Result := ParentObject;
  end;
end;

procedure TPropertyField.GetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
var
  ActualObject: TObject;
begin
  // get the object that contains this property
  ActualObject := GetObject( FObject );

  // put the property value in the fields buffer
  if ActualObject <> nil then
  begin
    InternalGetObjectProperty( FieldBuffer, ActualObject );
  end
  else
  begin
    PByte( FieldBuffer + FOffset )^ := FIELD_NULL;
  end;
end;

procedure TPropertyField.SetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
var
  ActualObject: TObject;
begin
  // get the object that contains this property
  ActualObject := GetObject( FObject );

  // set the new value of the property
  if ActualObject <> nil then
  begin
    InternalSetObjectProperty( FieldBuffer, ActualObject );
  end;
end;

procedure TPropertyField.SetOffset(const Value: Integer);
begin
  FOffset := Value;

  FDataOffset := Value + sizeof( TNullFieldFlag );
end;

class function TPropertyField.CreatePropertyField(
  PropertyInfo: TPropertyInfo;
  DefaultStringLength: Integer): TPropertyField;
{ create a property field to match the PropertyInfo provided }
begin
  Result := nil;

  case PropertyInfo.Kind of
    tkClass:
      begin
        if (PropertyInfo as TClassPropertyInfo).Class_Type.ClassInfo <> nil then
        begin
          Result := TObjectPropertyField.CreateObject( TClassPropertyInfo( PropertyInfo ), DefaultStringLength );
        end;
      end;
   tkFloat:
      begin
        if PropertyInfo.TypeName = DATETIME_TYPENAME then
        begin
          Result := TDateTimePropertyField.Create( PropertyInfo );
        end
        else if PropertyInfo.TypeName = DATE_TYPENAME then
        begin
          Result := TDatePropertyField.Create( PropertyInfo );
        end
        else if PropertyInfo.TypeName = TIME_TYPENAME then
        begin
          Result := TTimePropertyField.Create( PropertyInfo );
        end
        else
        begin
          case (PropertyInfo as TFloatPropertyInfo ).FloatType of
          ftSingle, ftDouble:
            Result := TFloatPropertyField.CreateFloat( TFloatPropertyInfo( PropertyInfo ) );
          ftCurr:
            Result := TCurrencyPropertyField.CreateFloat( TFloatPropertyInfo( PropertyInfo ) );
          end;
        end;
      end;
    tkEnumeration:
      begin
        if PropertyInfo.TypeName = BOOLEAN_TYPENAME then
        begin
          Result := TBooleanPropertyField.CreateOrdinal( PropertyInfo as TOrdinalPropertyInfo );
        end
        else
        begin
          Result := TIntegerPropertyField.CreateOrdinal( PropertyInfo as TOrdinalPropertyInfo );
        end;
      end;
    tkInt64:
      begin
        Result := TInt64PropertyField.CreateInt64( PropertyInfo as TInt64PropertyInfo );
      end;
    tkInteger:
      begin
        case (PropertyInfo as TOrdinalPropertyInfo).OrdinalType of
        otUWord:
          Result := TWordPropertyField.CreateOrdinal( TOrdinalPropertyInfo( PropertyInfo ) );
        else
          Result := TIntegerPropertyField.CreateOrdinal( TOrdinalPropertyInfo( PropertyInfo ) );
        end;
      end;
    tkString:
      begin
        Result := TStringPropertyField.CreateLimited( PropertyInfo as TStringPropertyInfo,
          TStringPropertyInfo( PropertyInfo ).MaxLength );
      end;
    tkLString, tkWString:
      begin
        Result := TStringPropertyField.CreateLimited( PropertyInfo as TStringPropertyInfo,
          DefaultStringLength );
      end;
    tkSet:
      begin
        Result := TSetPropertyField.CreateSet( PropertyInfo as TSetPropertyInfo );
      end;
  end;
end;

end.
