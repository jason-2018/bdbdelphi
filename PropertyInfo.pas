{
  TPropertyInfo

  Copyright © Paul Johnson 2000
  All rights reserved.


  Wrapper classes for RTTI property information.
  (created for use with the TObjectDataset component)
}
unit PropertyInfo;

interface

uses
  SysUtils,
  TypInfo;

type

  TPropertyInfo = class
  private
    FPropInfo: PPropInfo;

    function GetKind: TTypeKind;
    function GetName: ShortString;
    function GetTypeData: PTypeData;
    function GetGetProcedure: Pointer;
    function GetSetProcedure: Pointer;
    function GetStoredProcedure: Pointer;
    function GetTypeName: ShortString;
  protected
    property PropInfo: PPropInfo read FPropInfo;
    property TypeData: PTypeData read GetTypeData;
  public
    constructor Create( PropertyInfo: PPropInfo );
    class function CreatePropertyInfoObj( PropInfo: PPropInfo ): TPropertyInfo;

    function IsStoredProperty( Instance: TObject ): Boolean;

    property GetProcedure: Pointer read GetGetProcedure;
    property Kind: TTypeKind read GetKind;
    property Name: ShortString read GetName;
    property SetProcedure: Pointer read GetSetProcedure;
    property StoredProcedure: Pointer read GetStoredProcedure;
    property TypeName: ShortString read GetTypeName;
  end;

  TClassPropertyInfo = class( TPropertyInfo )
  private
    function GetClassType: TClass;
    function GetPropertyCount: Integer;
    function GetUnitName: string;
  public
    function GetClassProperty( Instance: TObject ): TObject;
    procedure SetClassProperty( Instance: TObject; Value: TObject );

    property Class_Type: TClass read GetClassType;
    property PropertyCount: Integer read GetPropertyCount;
    property UnitName: string read GetUnitName;
  end;

  TFloatPropertyInfo = class( TPropertyInfo )
  private
    function GetFloatType: TFloatType;
  public
    function GetFloatProperty( Instance: TObject ): Extended;
    procedure SetFloatProperty( Instance: TObject; Value: Extended );

    property FloatType: TFloatType read GetFloatType;
  end;

  TInt64PropertyInfo = class( TPropertyInfo )
  private
    function GetMaxValue: Int64;
    function GetMinValue: Int64;
  public
    function GetInt64Property( Instance: TObject ): Int64;
    procedure SetInt64Property( Instance: TObject; Value: Int64 );

    property MaxValue: Int64 read GetMaxValue;
    property MinValue: Int64 read GetMinValue;
  end;

  TMethodPropertyInfo = class( TPropertyInfo )
  private
    function GetMethodKind: TMethodKind;
  public
    function GetMethodProperty( Instance: TObject ): TMethod;
    procedure SetMethodProperty( Instance: TObject; Value: TMethod );

    property MethodKind: TMethodKind read GetMethodKind;
  end;

  TOrdinalPropertyInfo = class( TPropertyInfo )
  private
    function GetOrdinalType: TOrdType;
    function GetMaxValue: LongInt;
    function GetMinValue: LongInt;
  public
    function GetOrdinalProperty( Instance: TObject ): LongInt;
    procedure SetOrdinalProperty( Instance: TObject; Value: LongInt );

    property MaxValue: LongInt read GetMaxValue;
    property MinValue: LongInt read GetMinValue;
    property OrdinalType: TOrdType read GetOrdinalType;
  end;

  TSetPropertyInfo = class( TOrdinalPropertyInfo )
  private
    function GetSetKind: TTypeKind;
    function GetSetTypeName: ShortString;
    function GetSetMaxValue: LongInt;
    function GetSetMinValue: LongInt;
    function GetSetTypeData: PTypeData;
    function GetSetEnumName(Index: Integer): string;
  protected
    property SetTypeData: PTypeData read GetSetTypeData;
  public
    property SetKind: TTypeKind read GetSetKind;
    property SetMaxValue: LongInt read GetSetMaxValue;
    property SetMinValue: LongInt read GetSetMinValue;
    property SetTypeName: ShortString read GetSetTypeName;
    property SetEnumNames[ Index: Integer ]: string read GetSetEnumName;
  end;

  TStringPropertyInfo = class( TPropertyInfo )
  private
    function GetMaxLength: Byte;
  public
    function GetStringProperty( Instance: TObject ): String;
    procedure SetStringProperty( Instance: TObject; Value: String );

    property MaxLength: Byte read GetMaxLength;
  end;

  TVariantPropertyInfo = class( TPropertyInfo )
  public
    function GetVariantProperty( Instance: TObject ): Variant;
    procedure SetVariantProperty( Instance: TObject; Value: Variant );
  end;


implementation

{ TPropertyInfo }

constructor TPropertyInfo.Create(PropertyInfo: PPropInfo);
begin
  FPropInfo := PropertyInfo;
end;

function TPropertyInfo.GetGetProcedure: Pointer;
begin
  Result := FPropInfo^.GetProc;
end;

function TPropertyInfo.GetKind: TTypeKind;
begin
  Result := FPropInfo^.PropType^.Kind;
end;

function TPropertyInfo.GetName: ShortString;
begin
  Result := FPropInfo^.Name;
end;

class function TPropertyInfo.CreatePropertyInfoObj(
  PropInfo: PPropInfo): TPropertyInfo;
begin

  case PropInfo^.PropType^.Kind of
  tkInteger, tkChar, tkEnumeration, tkWChar:
    Result := TOrdinalPropertyInfo.Create( PropInfo );
  tkSet:
    Result := TSetPropertyInfo.Create( PropInfo );
  tkFloat:
    Result := TFloatPropertyInfo.Create( PropInfo );
  tkString, tkLString, tkWString:
    Result := TStringPropertyInfo.Create( PropInfo );
  tkClass:
    Result := TClassPropertyInfo.Create( PropInfo );
  tkMethod:
    Result := TMethodPropertyInfo.Create( PropInfo );
  tkVariant:
    Result := TVariantPropertyInfo.Create( PropInfo );
  tkInt64:
    Result := TInt64PropertyInfo.Create( PropInfo );
  else
    Result := TPropertyInfo.Create( PropInfo );
  end;
  
end;

function TPropertyInfo.GetSetProcedure: Pointer;
begin
  Result := FPropInfo^.SetProc;
end;

function TPropertyInfo.GetStoredProcedure: Pointer;
begin
  Result := FPropInfo^.StoredProc;
end;

function TPropertyInfo.GetTypeData: PTypeData;
begin
  Result := TypInfo.GetTypeData( FPropInfo^.PropType^ );
end;

function TPropertyInfo.IsStoredProperty(Instance: TObject): Boolean;
begin
  Result := IsStoredProp( Instance, FPropInfo );
end;




function TPropertyInfo.GetTypeName: ShortString;
begin
  Result := FPropInfo^.PropType^.Name;
end;

{ TClassPropertyInfo }

function TClassPropertyInfo.GetClassProperty(Instance: TObject): TObject;
begin
  Result := TObject( GetOrdProp( Instance, FPropInfo ) );
end;

function TClassPropertyInfo.GetClassType: TClass;
begin
  Result := TypeData^.ClassType;
end;

function TClassPropertyInfo.GetPropertyCount: Integer;
begin
  Result := TypeData^.PropCount;
end;

function TClassPropertyInfo.GetUnitName: string;
begin
  Result := TypeData^.UnitName;
end;

procedure TClassPropertyInfo.SetClassProperty(Instance: TObject;
  Value: TObject);
begin
  SetOrdProp( Instance, FPropInfo, Integer( Value ) );
end;




{ TFloatPropertyInfo }

function TFloatPropertyInfo.GetFloatProperty(Instance: TObject): Extended;
begin
  Result := GetFloatProp( Instance, PropInfo );
end;

function TFloatPropertyInfo.GetFloatType: TFloatType;
begin
  Result := TypeData^.FloatType;
end;

procedure TFloatPropertyInfo.SetFloatProperty(Instance: TObject;
  Value: Extended);
begin
  SetFloatProp( Instance, PropInfo, Value );
end;



{ TInt64PropertyInfo }

function TInt64PropertyInfo.GetInt64Property(Instance: TObject): Int64;
begin
  Result := GetInt64Prop( Instance, FPropInfo );
end;

function TInt64PropertyInfo.GetMaxValue: Int64;
begin
  Result := TypeData^.MaxInt64Value;
end;

function TInt64PropertyInfo.GetMinValue: Int64;
begin
  Result := TypeData^.MinInt64Value;
end;

procedure TInt64PropertyInfo.SetInt64Property(Instance: TObject; Value: Int64);
begin
  SetInt64Prop( Instance, FPropInfo, Value );
end;



{ TMethodPropertyInfo }

function TMethodPropertyInfo.GetMethodKind: TMethodKind;
begin
  Result := TypeData^.MethodKind;
end;

function TMethodPropertyInfo.GetMethodProperty(Instance: TObject): TMethod;
begin
  Result := GetMethodProp( Instance, FPropInfo );
end;

procedure TMethodPropertyInfo.SetMethodProperty(Instance: TObject;
  Value: TMethod);
begin
  SetMethodProp( Instance, FPropInfo, Value );
end;



{ TOrdinalPropertyInfo }

function TOrdinalPropertyInfo.GetMaxValue: LongInt;
begin
  Result := TypeData^.MaxValue;
end;

function TOrdinalPropertyInfo.GetMinValue: LongInt;
begin
  Result := TypeData^.MinValue;
end;

function TOrdinalPropertyInfo.GetOrdinalProperty(Instance: TObject): LongInt;
begin
  Result := GetOrdProp( Instance, FPropInfo );
end;

function TOrdinalPropertyInfo.GetOrdinalType: TOrdType;
begin
  Result := TypeData^.OrdType;
end;

procedure TOrdinalPropertyInfo.SetOrdinalProperty(Instance: TObject;
  Value: Integer);
begin
  SetOrdProp( Instance, FPropInfo, Value );
end;



{ TStringPropertyInfo }

function TStringPropertyInfo.GetMaxLength: Byte;
begin
  Result := TypeData^.MaxLength;
end;

function TStringPropertyInfo.GetStringProperty(Instance: TObject): string;
begin
  Result := GetStrProp( Instance, FPropInfo );
end;


procedure TStringPropertyInfo.SetStringProperty(Instance: TObject;
  Value: string);
begin
  SetStrProp( Instance, FPropInfo, Value );
end;



{ TVariantPropertyInfo }

function TVariantPropertyInfo.GetVariantProperty(Instance: TObject): Variant;
begin
  Result := GetFloatProp( Instance, FPropInfo );
end;

procedure TVariantPropertyInfo.SetVariantProperty(Instance: TObject;
  Value: Variant);
begin
  SetVariantProp( Instance, FPropInfo, Value );
end;




{ TSetPropertyInfo }

function TSetPropertyInfo.GetSetEnumName(Index: Integer): string;
begin
  Result := GetEnumName( TypeData^.CompType^, Index );
end;

function TSetPropertyInfo.GetSetKind: TTypeKind;
begin
  Result := TypeData^.CompType^^.Kind;
end;

function TSetPropertyInfo.GetSetMaxValue: LongInt;
begin
  Result := SetTypeData^.MaxValue;
end;

function TSetPropertyInfo.GetSetMinValue: LongInt;
begin
  Result := SetTypeData^.MinValue;
end;

function TSetPropertyInfo.GetSetTypeData: PTypeData;
begin
  Result := TypInfo.GetTypeData( TypeData^.CompType^ );
end;

function TSetPropertyInfo.GetSetTypeName: ShortString;
begin
  Result := TypeData^.CompType^^.Name;
end;

end.
