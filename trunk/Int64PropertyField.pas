{
  TInt64PropertyField

  Copyright © Paul Johnson 2000
  All rights reserved.


  Property field for large integer properties.
  (created for use with the TObjectDataset component)
}
unit Int64PropertyField;

interface

uses
  Classes,
  TypInfo,
  DB,
  SysUtils,
  PropertyField,
  PropertyInfo,
  DbConsts;


type

  TInt64PropertyField = class( TPropertyField )
  private
    FMinValue: Int64;
    FMaxValue: Int64;
  protected
    procedure InternalGetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
    procedure InternalSetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
  public
    constructor CreateInt64( FieldPropertyInfo: TInt64PropertyInfo );

    procedure SetField( FieldBuffer: PChar; FieldData: PChar ); override;
  end;



implementation


{ TInt64PropertyField }

constructor TInt64PropertyField.CreateInt64(
  FieldPropertyInfo: TInt64PropertyInfo );
begin
  inherited Create( FieldPropertyInfo );

  DataType := ftLargeInt;
  DataSize := sizeof( Int64 );

  FMaxValue := FieldPropertyInfo.MaxValue;
  FMinValue := FieldPropertyInfo.MinValue;
end;

procedure TInt64PropertyField.InternalGetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
begin
  PByte( FieldBuffer + Offset )^ := FIELD_VALID;
  PInt64( FieldBuffer + DataOffset )^ := TInt64PropertyInfo( PropertyInfo ).GetInt64Property( FObject );
end;

procedure TInt64PropertyField.InternalSetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
begin
  TInt64PropertyInfo( PropertyInfo ).SetInt64Property( FObject, PInt64( FieldBuffer + DataOffset )^ );
end;


procedure TInt64PropertyField.SetField(FieldBuffer, FieldData: PChar);
var
  NewValue: Int64;
begin
  NewValue := PInt64( FieldBuffer + DataOffset )^;

  if (NewValue >= FMinValue) and (NewValue <= FMaxValue) then begin
    inherited;
  end
  else begin
    DatabaseErrorFmt( SFieldValueError, [Name]);
  end;
end;

end.
