{
  TSetPropertyField

  Copyright © Paul Johnson 2000
  All rights reserved.


  Property field for set types. Set is implemented as an ADT field with a
  boolean sub-field for each element.
  (created for use with the TObjectDataset component)
}
unit SetPropertyField;

interface

uses
  Classes,
  TypInfo,
  DB,
  SysUtils,
  PropertyField,
  PropertyInfo;

type

  TSetPropertyField = class( TPropertyField )
  private
    FSetInfo: TSetPropertyInfo;
  protected
    procedure InternalGetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
    procedure InternalSetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
  public
    constructor CreateSet( FieldPropertyInfo: TSetPropertyInfo );

    property SetInfo: TSetPropertyInfo read FSetInfo;
  end;

  TSetPropertyElement = class( TPropertyField )
    FItemIndex: Integer;
    FSetField: TSetPropertyField;
  protected
    procedure InternalGetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
    procedure InternalSetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
  public
    constructor CreateElement( SetField: TSetPropertyField; ItemIndex: Integer ); virtual;
  end;

implementation

{ TSetPropertyField }

constructor TSetPropertyField.CreateSet( FieldPropertyInfo: TSetPropertyInfo );
var
  SubIndex: Integer;
begin
  inherited Create( FieldPropertyInfo );

  DataType := ftADT;
  FSetInfo := FieldPropertyInfo;

  // add each element of the set to the dataset as child fields
  for SubIndex := FSetInfo.SetMinValue to FSetInfo.SetMaxValue do begin
    AddSubField( TSetPropertyElement.CreateElement( Self, SubIndex ) );
  end;
end;

procedure TSetPropertyField.InternalGetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
begin
  PByte( FieldBuffer + Offset )^ := FIELD_VALID;
end;

procedure TSetPropertyField.InternalSetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
begin
end;

{ TSetPropertyElement }

constructor TSetPropertyElement.CreateElement( SetField: TSetPropertyField;
  ItemIndex: Integer );
begin
  inherited Create( SetField.SetInfo );

  FSetField := SetField;
  FItemIndex := ItemIndex;

  // elements are a a boolean field
  DataSize := sizeof( WordBool );
  DataType := ftBoolean;

  Name := FSetField.SetInfo.SetEnumNames[ FItemIndex ];
end;

procedure TSetPropertyElement.InternalGetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
var
  IntegerSet: TIntegerSet;
begin
  PByte( FieldBuffer + Offset )^ := FIELD_VALID;

  // get the value of the entire set as an integer
  IntegerSet := TIntegerSet( FSetField.SetInfo.GetOrdinalProperty( FSetField.GetObject( FObject ) ) );

  PWordBool( FieldBuffer + DataOffset )^ := (FItemIndex in IntegerSet);
end;

procedure TSetPropertyElement.InternalSetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
var
  IntegerSet: TIntegerSet;
begin
  IntegerSet := TIntegerSet( FSetField.SetInfo.GetOrdinalProperty( FSetField.GetObject( FObject ) ) );

  // add/remove this element from the set
  if PWordBool( FieldBuffer + DataOffset )^ then begin
    Include( IntegerSet, FItemIndex );
  end
  else begin
    Exclude( IntegerSet, FItemIndex );
  end;

  FSetField.SetInfo.SetOrdinalProperty( FSetField.GetObject( FObject ), Integer( IntegerSet ) );
end;

end.
