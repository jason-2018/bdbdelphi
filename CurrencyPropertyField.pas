{
  TCurrencyPropertyField

  Copyright © Paul Johnson 2000
  All rights reserved.


  Property field for Currency values.
  (created for use with the TObjectDataset component)
}
unit CurrencyPropertyField;

interface

uses
  Classes,
  TypInfo,
  DB,
  SysUtils,
  PropertyField,
  FloatPropertyField,
  PropertyInfo;

type

  TCurrencyPropertyField = class( TFloatPropertyField )
  public
    constructor CreateFloat( FieldPropertyInfo: TFloatPropertyInfo ); override;
  end;

implementation

{ TCurrencyPropertyField }

constructor TCurrencyPropertyField.CreateFloat(FieldPropertyInfo: TFloatPropertyInfo);
begin
  inherited;

  // only thing to override for currency vs. float is the field type
  DataType := ftCurrency;
end;

end.
