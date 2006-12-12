{
  TDatePropertyField
  TTimePropertyField
  TDateTimePropertyField

  Copyright © Paul Johnson 2000
  All rights reserved.


  Property field for date and time values.
  (created for use with the TObjectDataset component)
}
unit DateTimePropertyField;

interface

uses
  Classes,
  TypInfo,
  DB,
  SysUtils,
  PropertyField,
  PropertyInfo;

type

  TDateTimePropertyField = class( TPropertyField )
  protected
    procedure InternalGetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
    procedure InternalSetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
  public
    constructor Create( FieldPropertyInfo: TPropertyInfo ); override;
  end;

  TDatePropertyField = class( TDateTimePropertyField )
  public
    constructor Create( FieldPropertyInfo: TPropertyInfo ); override;
  end;

  TTimePropertyField = class( TDateTimePropertyField )
  public
    constructor Create( FieldPropertyInfo: TPropertyInfo ); override;
  end;

implementation

const
  NULL_DATETIME = 0;

{ TDateTimePropertyField }

constructor TDateTimePropertyField.Create(FieldPropertyInfo: TPropertyInfo);
begin
  inherited;

  DataType := ftDateTime;
  DataSize := sizeof( Comp );
end;

procedure TDateTimePropertyField.InternalGetObjectProperty(
  FieldBuffer: PChar; FObject: TObject);
var
  TimeStamp: TTimeStamp;
  DateTime: Double;
begin
  DateTime := TFloatPropertyInfo( PropertyInfo ).GetFloatProperty( FObject );

  if DateTime = 0 then begin
    PByte( FieldBuffer + Offset )^ := FIELD_NULL;
  end
  else begin
    PByte( FieldBuffer + Offset )^ := FIELD_VALID;

    TimeStamp := DateTimeToTimeStamp( DateTime );

    case DataType of
    ftDate:
      PLongInt( FieldBuffer + DataOffset )^ := TimeStamp.Date;
    ftDateTime:
      PDouble( FieldBuffer + DataOffset )^ := TimeStampToMsecs( TimeStamp );
    ftTime:
      PLongInt( FieldBuffer + DataOffset )^ := TimeStamp.Time;
    end;
  end;
end;

procedure TDateTimePropertyField.InternalSetObjectProperty(
  FieldBuffer: PChar; FObject: TObject);
var
  TimeStamp: TTimeStamp;
begin
  if PByte( FieldBuffer + Offset )^ = FIELD_NULL then begin
    TFloatPropertyInfo( PropertyInfo ).SetFloatProperty( FObject, NULL_DATETIME );
  end
  else begin
    case DataType of
    ftDate:
      begin
        TimeStamp.Date := PLongInt( FieldBuffer + DataOffset )^;
        TimeStamp.Time := 0;
      end;
    ftDateTime:
      begin
        TimeStamp := MSecsToTimeStamp( PDouble( FieldBuffer + DataOffset )^ );
      end;
    ftTime:
      begin
        TimeStamp.Date := 0;
        TimeStamp.Time := PLongInt( FieldBuffer + DataOffset )^;
      end;
    end;

    TFloatPropertyInfo( PropertyInfo ).SetFloatProperty( FObject, TimeStampToDateTime( TimeStamp ) );
  end;
end;



{ TTimePropertyField }

constructor TTimePropertyField.Create(FieldPropertyInfo: TPropertyInfo);
begin
  inherited;

  DataType := ftTime;
end;

{ TDatePropertyField }

constructor TDatePropertyField.Create(FieldPropertyInfo: TPropertyInfo);
begin
  inherited;

  DataType := ftDate;
end;

end.
