{
  TPropertyInfoList

  Copyright © Paul Johnson 2000
  All rights reserved.


  Wrapper class to manage the RTTI of a class as TPropertyInfo objects.  
  (created for use with the TObjectDataset component)
}
unit PropertyInfoList;

interface

uses
  Classes,
  PropertyInfo,
  TypInfo;

type

  TPropertyInfoList = class
  private
    FProperties: TList;
    FPropList: PPropList;
    procedure GetClassProperties( AClass: TClass );
    function GetCount: Integer;
    function GetItem(Index: Integer): TPropertyInfo;
    procedure ClearItems;
  public
    constructor Create( AClass: TClass );
    destructor Destroy; override;

    property Count: Integer read GetCount;
    property Items[ Index: Integer ]: TPropertyInfo read GetItem; default;
  end;

implementation

{ TPropertyInfoList }

procedure TPropertyInfoList.ClearItems;
var
  Index: Integer;
begin
  for Index := 0 to (Count-1) do
  begin
    TPropertyInfo( FProperties[ Index ] ).Free();
  end;

  FProperties.Clear();
end;

constructor TPropertyInfoList.Create(AClass: TClass);
begin
  FProperties := TList.Create();

  GetClassProperties( AClass );
end;

destructor TPropertyInfoList.Destroy;
begin
  ClearItems();
  FProperties.Free();

  FreeMem( FPropList );

  inherited;
end;

procedure TPropertyInfoList.GetClassProperties(AClass: TClass);
{ build the list of property info from the RTTI of AClass }
var
  PropertyCount: Integer;
  Index: Integer;
begin
  // get RTTI property list
  PropertyCount := GetTypeData( AClass.ClassInfo )^.PropCount;
  GetMem( FPropList, (PropertyCount * SizeOf( Pointer )) );
  GetPropInfos( AClass.ClassInfo, FPropList );

  // create property info objects to match RTTI properties
  for Index := 0 to (PropertyCount-1) do
  begin
    if FPropList^[ Index ] <> nil then
    begin
      FProperties.Add( TPropertyInfo.CreatePropertyInfoObj( FPropList^[ Index ] ) );
    end;
  end;
end;

function TPropertyInfoList.GetCount: Integer;
begin
  Result := FProperties.Count;
end;

function TPropertyInfoList.GetItem(Index: Integer): TPropertyInfo;
begin
  Result := TPropertyInfo( FProperties[ Index ] );
end;

end.
