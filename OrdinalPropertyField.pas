{
  TOrdinalPropertyField

  Copyright © Paul Johnson 2000
  All rights reserved.


  Property field for ordinal types.
  (created for use with the TObjectDataset component)
}
unit OrdinalPropertyField;

interface

uses
  Classes,
  TypInfo,
  DB,
  SysUtils,
  PropertyField,
  PropertyInfo;

type
  TOrdinalPropertyField = class( TPropertyField )
  private
    FMinValue: Integer;
    FMaxValue: Integer;
  protected
    function IntegerFromBuffer( FieldBuffer: PChar ): Integer; virtual; abstract;
    procedure IntegerToBuffer( FieldBuffer: PChar; Value: Integer ); virtual; abstract;
  public
    constructor CreateOrdinal( FieldPropertyInfo: TOrdinalPropertyInfo ); virtual;

    procedure InternalGetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
    procedure InternalSetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;

    procedure SetField( FieldBuffer: PChar; FieldData: PChar ); override;
  end;

  TIntegerPropertyField = class( TOrdinalPropertyField )
  private
  protected
    function IntegerFromBuffer( FieldBuffer: PChar ): Integer; override;
    procedure IntegerToBuffer( FieldBuffer: PChar; Value: Integer ); override;
  public
    constructor CreateOrdinal( FieldPropertyInfo: TOrdinalPropertyInfo ); override;
  end;

  TWordPropertyField = class( TOrdinalPropertyField )
  private
  protected
    function IntegerFromBuffer( FieldBuffer: PChar ): Integer; override;
    procedure IntegerToBuffer( FieldBuffer: PChar; Value: Integer ); override;
  public
    constructor CreateOrdinal( FieldPropertyInfo: TOrdinalPropertyInfo ); override;
  end;

  TBooleanPropertyField = class( TOrdinalPropertyField )
  private
  protected
    function IntegerFromBuffer( FieldBuffer: PChar ): Integer; override;
    procedure IntegerToBuffer( FieldBuffer: PChar; Value: Integer ); override;
  public
    constructor CreateOrdinal( FieldPropertyInfo: TOrdinalPropertyInfo ); override;
  end;


implementation

uses
  DBConsts;

type
  PWord = ^Word;

{ TOrdinalPropertyField }

constructor TOrdinalPropertyField.CreateOrdinal(
  FieldPropertyInfo: TOrdinalPropertyInfo);
begin
  inherited Create( FieldPropertyInfo );

  FMinValue := FieldPropertyInfo.MinValue;
  FMaxValue := FieldPropertyInfo.MaxValue;
end;

procedure TOrdinalPropertyField.InternalGetObjectProperty(
  FieldBuffer: PChar; FObject: TObject);
begin
  PByte( FieldBuffer + Offset )^ := FIELD_VALID;
  IntegerToBuffer( FieldBuffer + DataOffset, TOrdinalPropertyInfo( PropertyInfo ).GetOrdinalProperty( FObject ) );
end;

procedure TOrdinalPropertyField.InternalSetObjectProperty(
  FieldBuffer: PChar; FObject: TObject);
var
  NewValue: Integer;
begin
  NewValue := IntegerFromBuffer( FieldBuffer + DataOffset );

  TOrdinalPropertyInfo( PropertyInfo ).SetOrdinalProperty( FObject, NewValue );
end;

procedure TOrdinalPropertyField.SetField(FieldBuffer, FieldData: PChar);
var
  NewValue: Integer;
begin
  NewValue := IntegerFromBuffer( FieldData );

  if (NewValue >= FMinValue) and (NewValue <= FMaxValue) then begin
    inherited;
  end
  else begin
    DatabaseErrorFmt( SFieldRangeError, [Int( NewValue ), Name, Int( FMinValue ), Int( FMaxValue )]);
  end;
end;

{ TIntegerPropertyField }

constructor TIntegerPropertyField.CreateOrdinal(
  FieldPropertyInfo: TOrdinalPropertyInfo);
begin
  inherited;

  DataType := ftInteger;
  DataSize := sizeof( LongInt );
end;

function TIntegerPropertyField.IntegerFromBuffer(
  FieldBuffer: PChar): Integer;
begin
  Result := PLongInt( FieldBuffer )^;
end;

procedure TIntegerPropertyField.IntegerToBuffer(FieldBuffer: PChar; Value: Integer);
begin
  PLongInt( FieldBuffer )^ := Value;
end;


{ TWordPropertyField }

constructor TWordPropertyField.CreateOrdinal(
  FieldPropertyInfo: TOrdinalPropertyInfo);
begin
  inherited;

  DataType := ftWord;
  DataSize := sizeof( Word );
end;

function TWordPropertyField.IntegerFromBuffer(FieldBuffer: PChar): Integer;
begin
  Result := PWord( FieldBuffer )^;
end;

procedure TWordPropertyField.IntegerToBuffer(FieldBuffer: PChar;
  Value: Integer);
begin
  PWord( FieldBuffer )^ := Value;
end;

{ TBooleanPropertyField }

constructor TBooleanPropertyField.CreateOrdinal(
  FieldPropertyInfo: TOrdinalPropertyInfo);
begin
  inherited;

  DataType := ftBoolean;
  DataSize := sizeof( WordBool );
end;

function TBooleanPropertyField.IntegerFromBuffer(
  FieldBuffer: PChar): Integer;
begin
  Result := PWord( FieldBuffer )^;
end;

procedure TBooleanPropertyField.IntegerToBuffer(FieldBuffer: PChar;
  Value: Integer);
begin
  PWord( FieldBuffer )^ := Value;
end;

end.
