{
  TObjectPropertyField

  Copyright © Paul Johnson 2000
  All rights reserved.


  Property field for objects (ADT field).
  (created for use with the TObjectDataset component)
}
unit ObjectPropertyField;

interface

uses
  Classes,
  TypInfo,
  DB,
  SysUtils,
  PropertyField,
  PropertyInfoList,
  PropertyInfo;


type

  TObjectPropertyField = class( TPropertyField )
    FPropertyList: TPropertyInfoList;
    FPropertyCount: Integer;
    FDefaultStringLength: Integer;
    FClassInfo: TClassPropertyInfo;
  protected
    procedure InternalGetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
    procedure InternalSetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
  public
    constructor CreateObject( FieldPropInfo: TClassPropertyInfo; DefaultStringLength: Integer ); virtual;
    destructor Destroy; override;

    property ClassPropertyInfo: TClassPropertyInfo read FClassInfo;
  end;

implementation


{ TObjectPropertyField }

constructor TObjectPropertyField.CreateObject( FieldPropInfo: TClassPropertyInfo;
  DefaultStringLength: Integer );
var
  PropertyIndex: Integer;
  NewSubField: TPropertyField;
begin
  inherited Create( FieldPropInfo );

  FClassInfo := FieldPropInfo;

  DataType := ftADT;
  FDefaultStringLength := DefaultStringLength;

  // get RTTI details for the objects class
  FPropertyList := TPropertyInfoList.Create( FClassInfo.Class_Type );

  // create a property field for each RTTI property of the objects class
  for PropertyIndex := 0 to (FPropertyList.Count-1) do begin
    NewSubField := CreatePropertyField( FPropertyList[ PropertyIndex ], FDefaultStringLength );
    if NewSubField <> nil then begin
      AddSubField( NewSubField );
    end;
  end;
end;

destructor TObjectPropertyField.Destroy;
begin
  FPropertyList.Free();

  inherited;
end;

procedure TObjectPropertyField.InternalGetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
begin
  // ADT parent field is always valid
  PByte( FieldBuffer + Offset )^ := FIELD_VALID;
end;

procedure TObjectPropertyField.InternalSetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
begin
end;

end.
