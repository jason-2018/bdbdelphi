{
  TPropertyFields

  Copyright © Paul Johnson 2000
  All rights reserved.


  Class to manage all the published properties of a class as TPropertyField
  objects.
  (created for use with the TObjectDataset component)
}
unit PropertyFields;

interface

uses
  DB,
  Classes,
  TypInfo,
  PropertyField,
  PropertyInfo,
  PropertyInfoList;

type

  TPropertyFields = class
  private
    FFields: TList;
    FBufferSize: Integer;
    FDefaultStringLength: Integer;
    FProperties: TPropertyInfoList;

    function GetField(Index: Integer): TPropertyField;

    procedure AddField( PropertyField: TPropertyField );
    procedure GetPropertyList( ObjectClass: TClass );
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    procedure BuildList( ObjectClass: TClass );
    procedure CreateFieldDefs( FieldDefs: TFieldDefs );

    procedure SetToBuffer( Buffer: PChar; AnObject: TObject );
    procedure GetFromBuffer( Buffer: PChar; AnObject: TObject );

    property BufferSize: Integer read FBufferSize;
    property Count: Integer read GetCount;
    property DefaultStringLength: Integer read FDefaultStringLength
      write FDefaultStringLength;
    property Fields[ Index: Integer ]: TPropertyField read GetField; default;
  end;



implementation

{ TPropertyFields }

procedure TPropertyFields.GetPropertyList( ObjectClass: TClass );
begin
  FProperties.Free();

  FProperties := TPropertyInfoList.Create( ObjectClass );
end;

procedure TPropertyFields.BuildList(ObjectClass: TClass);
var
  PropertyIndex: Integer;
  PropertyInfo: TPropertyInfo;
  NewField: TPropertyField;
begin
  Clear;

  // get RTTI property list
  GetPropertyList( ObjectClass );

  for PropertyIndex := 0 to (FProperties.Count-1) do
  begin

    // find valid property info
    PropertyInfo := FProperties[ PropertyIndex ];

    // only create fields for properties that can be read from
    if PropertyInfo.GetProcedure <> nil then
    begin
      NewField := TPropertyField.CreatePropertyField( PropertyInfo, FDefaultStringLength );
      if NewField <> nil then
      begin
        AddField( NewField );
      end;
    end;
  end;
end;

procedure TPropertyFields.Clear;
var
  FieldIndex: Integer;
begin
  for FieldIndex := 0 to (Count-1) do begin
    Fields[ FieldIndex ].Free();
  end;

  FFields.Clear();

  FBufferSize := 0;
end;

constructor TPropertyFields.Create;
begin
  inherited;
  FDefaultStringLength:=236;
  FFields := TList.Create();
end;

destructor TPropertyFields.Destroy;
begin
  Clear();
  
  FProperties.Free();
  FFields.Free();

  inherited;
end;

function TPropertyFields.GetField(Index: Integer): TPropertyField;
begin
  Result := TPropertyField( FFields.Items[ Index ] );
end;

function TPropertyFields.GetCount: Integer;
begin
  Result := FFields.Count;
end;

procedure TPropertyFields.AddField(PropertyField: TPropertyField);
var
  SubIndex: Integer;
begin
  PropertyField.FieldNo := (FFields.Count+1);
  PropertyField.Offset := FBufferSize;

  // adjust the buffer size to include the new field
  FBufferSize := FBufferSize + PropertyField.DataSize + sizeof( TNullFieldFlag );

  FFields.Add( PropertyField );

  // recursively add all child properties
  for SubIndex := 0 to (PropertyField.SubFieldCount-1) do begin
    AddField( PropertyField.SubFields[ SubIndex ] );
  end;
end;

procedure TPropertyFields.GetFromBuffer(Buffer: PChar; AnObject: TObject);
{ Copy the field data in the buffer to the objects properties }
var
  FieldIndex: Integer;
begin
  for FieldIndex := 0 to (Count-1) do
  begin
    with Fields[ FieldIndex ] do
    begin
      if PropertyInfo.SetProcedure <> nil then
      begin
        SetObjectProperty( Buffer, AnObject );
      end;
    end;
  end;
end;

procedure TPropertyFields.SetToBuffer(Buffer: PChar; AnObject: TObject);
{ Fill the buffer with the data for all the properties }
var
  FieldIndex: Integer;
begin
  for FieldIndex := 0 to (Count-1) do
  begin
    Fields[ FieldIndex ].GetObjectProperty( Buffer, AnObject );
  end;
end;

procedure TPropertyFields.CreateFieldDefs(FieldDefs: TFieldDefs);
{ create field definitions for each property field }
var
  FieldIndex: Integer;
begin
  for FieldIndex := 0 to (Count-1) do
  begin
    if Fields[ FieldIndex ].Parent = nil then
    begin
      Fields[ FieldIndex ].PrepareFieldDef( FieldDefs.AddFieldDef );
    end;
  end;
end;



end.
