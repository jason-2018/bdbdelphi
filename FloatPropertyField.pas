{
  TFloatPropertyField

  Copyright © Paul Johnson 2000
  All rights reserved.


  Property field for floating point values.
  (created for use with the TObjectDataset component)
}
unit FloatPropertyField;

interface

uses
  Classes,
  TypInfo,
  DB,
  SysUtils,
  PropertyField,
  PropertyInfo;

type

  TFloatPropertyField = class( TPropertyField )
  private
    FFloatPropertyInfo: TFloatPropertyInfo;
  protected
    procedure InternalGetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
    procedure InternalSetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
  public
    constructor CreateFloat( FieldPropertyInfo: TFloatPropertyInfo ); virtual;
  end;


implementation



{ TFloatPropertyField }

constructor TFloatPropertyField.CreateFloat( FieldPropertyInfo: TFloatPropertyInfo );
begin
  inherited Create( FieldPropertyInfo );

  FFloatPropertyInfo := FieldPropertyInfo;

  DataType := ftFloat;
  DataSize := sizeof( Double );
end;

procedure TFloatPropertyField.InternalGetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
begin
  PByte( FieldBuffer + Offset )^ := FIELD_VALID;
  PDouble( FieldBuffer + DataOffset )^ := FFloatPropertyInfo.GetFloatProperty( FObject);
end;

procedure TFloatPropertyField.InternalSetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
begin
  FFloatPropertyInfo.SetFloatProperty( FObject, PDouble(FieldBuffer + DataOffset)^ );
end;

end.

