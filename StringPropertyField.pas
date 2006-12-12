{
  TStringPropertyField

  Copyright © Paul Johnson 2000
  All rights reserved.


  Property field for string properties.
  (created for use with the TObjectDataset component)
}
unit StringPropertyField;

interface

uses
  Classes,
  TypInfo,
  DB,
  SysUtils,
  PropertyField,
  PropertyInfo;


type
  TStringPropertyField = class( TPropertyField )
    FStringInfo: TStringPropertyInfo;
  protected
    procedure InternalGetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
    procedure InternalSetObjectProperty( FieldBuffer: PChar; FObject: TObject ); override;
  public
    constructor CreateLimited( FieldPropertyInfo: TStringPropertyInfo; Length: Integer );
  end;

implementation

{ TStringPropertyField }

constructor TStringPropertyField.CreateLimited( FieldPropertyInfo: TStringPropertyInfo; Length: Integer);
begin
  inherited Create( FieldPropertyInfo );

  FStringInfo := FieldPropertyInfo;

  Size := Length;
  DataType := ftString;

  // string buffer size = max string length + 1 character for the null terminator
  DataSize := (Size + sizeof( AnsiChar ));
end;

procedure TStringPropertyField.InternalGetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
var
  TempString: string;
  StringSize: Integer;
begin
  PByte( FieldBuffer + Offset )^ := FIELD_VALID;

  TempString := FStringInfo.GetStringProperty( FObject );

  // calculate amount of data to copy
  StringSize := Length( TempString );

  // limit the size of the string to the size of the buffer
  if StringSize > Size then begin
    StringSize := Size;
  end;

  // copy the string data, ensuring buffer contains null terminated string
  Move( PChar( TempString )^, (FieldBuffer + DataOffset)^, StringSize );
  (FieldBuffer + DataOffset + StringSize )^ := #0;

end;

procedure TStringPropertyField.InternalSetObjectProperty(FieldBuffer: PChar;
  FObject: TObject);
begin
  FStringInfo.SetStringProperty( FObject, (FieldBuffer + DataOffset) );
end;


end.
