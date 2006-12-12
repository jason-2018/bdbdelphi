unit TestDll;

interface

  function func1 (x : integer):integer; cdecl;
  
implementation

  function func1; external 'TestDll.dll' name 'func1';
end.
 