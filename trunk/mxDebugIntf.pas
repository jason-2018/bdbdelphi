// ****************************************************************************
// * mxDebugger for Borland Delphi interface Unit
// ****************************************************************************
// * mxDebugger version 1.01
// * Copyright 2001, Lajos Farkas.
// * All Rights Reserved.
// ****************************************************************************
// * Date last modified: 18.10.2001
// ****************************************************************************
// * Feel free to contact me if you have any questions, comments or suggestions
// * at wmax@freemail.hu
// ****************************************************************************
// * Web page: www.geocities.com/maxcomponents
// ****************************************************************************
// *
// * Description: This is an external debugger application for Borland Delphi.
// * It gives you a tool to check your variables, expressions, and components
// * at both run- and designtime without any breakpoints.
// *
// ****************************************************************************

// ****************************************************************************
// ****************************************************************************
// * U S E D  C O M P I L E R  D I R E C T I V E S
// ****************************************************************************
// ****************************************************************************
// *
// * This unit uses 6 different compiler directives.
// * Please switch them on/off as your application requires.
// *
// * DEBUGGING  : When you undefine this directive you will remove the
// *              debugging possibility from your application.
// * USECONTROLS: You can send TCursor to the debugger
// * USECLASSES : You can send TComponent and TStrings and Registry Keys
// *              to the debugger. The HexDump also works only with this
// *              directive.
// * USEGRAPHICS: You can send TColor to the debugger
// *
// * USEMAPFILE : It is a special switch. If your compiler generates MAP file
// *              for your application you will receive information about
// *              unit names and line numbers in the debugger.
// *              For more information about how to create MAP file see
// *              MAP creation section.
// *
// * SYSTEMINFO : If it switched on you can send system information to th
// *              debugger with SendSystemInfo procedure.
// *
// * Usage:
// * Create one or more debugger from TmxDebugger class in your application,
// * and do not forget to start the debugging.
// *
// * For example:
// * Procedure TMainForm.FormCreate( Self: TObject );
// * Var mxDebugger:=TmxDebugger;
// * Begin
// *      mxDebugger:=TmxDebugger.Create;
// *      mxDebugger.StartDebugging;
// * End;
// *
// * Procedure TMainForm.btn_ViewClick(Sender: TObject);
// * begin
// *      Debugger.SendObject( 'btn_ViewClick Sender', Sender );
// * end;
// *
// * Procedure TMainForm.FormDestroy( Self: TObject );
// * Var mxDebugger:=TmxDebugger;
// * Begin
// *      mxDebugger.StopDebugging;
// *      mxDebugger.Free;
// * End;
// *
// ****************************************************************************

// ****************************************************************************
// ****************************************************************************
// * H O W   T O  U S E  M E S S A G E  G R O U P S
// ****************************************************************************
// ****************************************************************************
// *
// * You can send all of them to [mgGeneral, mgInfo, mgWarning, mgError] groups
// * Example:
// *
// *     Debugger.SendObject( 'btn_ViewClick Sender', Sender );
// *     Debugger.SendObject( 'btn_ViewClick Sender', Sender, mgInfo );
// *
// * The default Group is mgGeneral.
// *
// ****************************************************************************

// ****************************************************************************
// ****************************************************************************
// * H O W   T O  U S E  D E B U G L E V E L S
// ****************************************************************************
// ****************************************************************************
// *
// * You can send all of them to [ dlLow, dlMedium, dlHigh ] debug levels.
// * Example:
// *
// *     Debugger.SendObject( 'btn_ViewClick Sender', Sender );
// *     Debugger.SendObject( 'btn_ViewClick Sender', Sender, dlLow );
// *     Debugger.SendObject( 'btn_ViewClick Sender', Sender, mgInfo, dlLow );
// *
// * The default debug level is dlMedium. If the actual debug level is higher
// * as you specified in the procedure call the message will not be sent to
// * the debugger. Please use the SetDebugLevel procedure to set the actual
// * level.
// *
// ****************************************************************************

// ****************************************************************************
// ****************************************************************************
// * H O W   T O  C R E A T E   M A P   F I L E S
// ****************************************************************************
// ****************************************************************************
// *
// * To identify the unit name, function name and line number in source code,
// * you ave to a detailed map file, which is generated when the compiler
// * generates the application.
// *
// * If you do not create it, you will not receive information about function
// * names, units and line numbers.
// *
// * First you need to create map file for project as follows:
// *
// * (1) First make sure code optimization is switch off in
// *     Project|Options dialog Compiler tab.
// *
// * (2) Then switch on detailed map file in the Project|Options dialog
// *     Linker tab.
// *
// * (3) Now rebuild your application with a Project|Build All.
// *     A map file will be generated with the same name as the project.exe,
// *     e.g. project.map.
// *
// ****************************************************************************

{$DEFINE DEBUGGING}
{$DEFINE USEMAPFILE}
{$DEFINE SYSTEMINFO}
{$DEFINE USECONTROLS}
{$DEFINE USECLASSES}
{$DEFINE USEGRAPHICS}

Unit mxDebugIntf;

Interface

Uses Windows,
     SysUtils,
     WinProcs,
{$IFDEF USECLASSES}
     Classes,
     Registry,
{$ENDIF}
{$IFDEF USECONTROLS}
     Controls,
{$ENDIF}
{$IFDEF USEGRAPHICS}
     Graphics,
{$ENDIF}
     Messages,
     TypInfo;

Type
     // **************************************************************************
     // *** Command Messages
     // **************************************************************************

     TmxMessageTypes = (
          mtUnknown,
          mtStart,
          mtEnd,
          mtEnable,
          mtDisable,
          mtReadyToStart,
          mtDebuggerClosed,
          mtDebuggerOpened,
          mtInfoPackage,
          mtChangeDebugLevel,
          mtClearMessages,
          mtClearDebugger,
          mtMessage,
          mtInfoPad,
          mtString,
          mtNote,
          mtProcedureEnter,
          mtProcedureExit,
          mtSeparator,
          mtException,
          mtPoint,
          mtColor,
          mtCursor,
          mtRect,
          mtCheckPoint,
          mtReminder,
          mtMemoryDump,
          mtComponent,
          mtStringList,
          mtSystemInfo,
          mtObject,
          mtProperty,
          mtRegistry,
          mtShowDebugger
          );

     // **************************************************************************
     // *** Message Groups
     // **************************************************************************

     TmxMessageGroup = (
          mgGeneral,
          mgInfo,
          mgWarning,
          mgError );

     // **************************************************************************
     // *** Debugging Levels
     // **************************************************************************

     TmxDebugLevel = (
          dlLow,
          dlMedium,
          dlHigh );

     // **************************************************************************
     // *** Debugger class predefinition
     // **************************************************************************

     TmxDebugger = Class;

     // **************************************************************************
     // *** Message Record Types
     // **************************************************************************

     TmxMessage = Record
          MessageGroup: TmxMessageGroup;
          MessageType: TmxMessageTypes;
          MessageStr: ShortString;
          MessageInt: Integer;
          DebugLevel: TmxDebugLevel;
          DataSize: Integer;
          Data: Pointer;
     End;

     PmxDebugMessage = ^TmxDebugMessage;
     TmxDebugMessage = Record
          SenderID: String[ 50 ];
          MessageGroup: TmxMessageGroup;
          MessageStr: ShortString;
          MessageInt: Integer;
          DebugLevel: TmxDebugLevel;
          Time: TDateTime;
          ProcedureName: ShortString;
          UnitName: ShortString;
          Address: Integer;
          Line: Integer;
          DataSize: Integer;
          Data: Pointer;
     End;

     // **************************************************************************
     // *** The debugger class definition
     // **************************************************************************

     TmxDebugger = Class
     Private

          FName: String[ 8 ];
          FEnabled: Boolean;
          FDebugLevel: TmxDebugLevel;

{$IFDEF DEBUGGING}
          FID: String[ 50 ];
          FWindowHandle: hWnd;
          FDebuggerWnd: hWnd;

          Procedure SendInfoPackage;
          Function GetID: String;

          Procedure _Send( {$IFDEF USEMAPFILE}MapPointer: Pointer; {$ENDIF}AMessage: TmxMessage );
          Procedure _SendStr( {$IFDEF USEMAPFILE}MapPointer: Pointer; {$ENDIF}Const AName: String; AValue: String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );

{$ENDIF} // ** Debugging **

          Procedure SetEnabled( Value: Boolean );

     Protected

          Procedure WndProc( Var AMessage: TMessage ); Virtual;

     Public

          Procedure SetDebugLevel( AValue: TmxDebugLevel );

          Constructor Create( AName: ShortString ); Virtual;
          Destructor Destroy; Override;

{$IFDEF DEBUGGING}
          Property ID: String Read GetID;
          Property Handle: hWnd Read FWindowHandle;
{$ENDIF}

          Property Enabled: Boolean Read FEnabled Write SetEnabled;
          Property DebugLevel: TmxDebugLevel Read FDebugLevel Write SetDebugLevel;

          Procedure StartDebugging;
          Procedure StopDebugging;
          Procedure ShowDebugger;
          Procedure ClearDebugger;
          Procedure ClearMessages;
          Procedure SendSeparator( ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendEnter( AName: String; ADebugLevel: TmxDebugLevel = dlHigh );
          //Procedure SendEnter( AName: String; AFormat: String; AValues: Array Of Const; ADebugLevel: TmxDebugLevel = dlHigh );
          Procedure SendExit( AName: String; ADebugLevel: TmxDebugLevel = dlHigh );
          //Procedure SendExit( AName: String; AFormat: String; AValues: Array Of Const; ADebugLevel: TmxDebugLevel = dlHigh );
          Procedure SendMsg( Const AMessage: String; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendFmtMsg( Const AMessage: String; AFormat: String; AValues: Array Of Const; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendNote( Const AMessage: String; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendCheckPoint( Const AMessage: String; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendReminder( Const AMessage: String; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendFmtNote( Const AMessage: String; AFormat: String; AValues: Array Of Const; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendInfoPad( Const AName: String; Const AMessage: String; Index: Byte; ADebugLevel: TmxDebugLevel = dlLow ); Overload;
          Procedure SendInfoPad( Const AName: String; Const AMessage: String; AFormat: String; AValues: Array Of Const; Index: Byte; ADebugLevel: TmxDebugLevel = dlLow ); Overload;
          Procedure SendHex( Const AName: String; AValue: DWord; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendDate( Const AName: String; AValue: TDateTime; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendTime( Const AName: String; AValue: TDateTime; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendDateTime( Const AName: String; AValue: TDateTime; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendPointer( Const AName: String; AValue: Pointer; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendAssigned( Const AName: String; AValue: Pointer; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure Assert( ACondition: Boolean; AName: String; AValue: String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure AssertFmt( ACondition: Boolean; AName: String; AFormat: String; AValue: Array Of Const; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendString( Const AName: String; AValue: String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendFloat( Const AName: String; AValue: Extended; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendInteger( Const AName: String; AValue: Integer; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendDWord( Const AName: String; AValue: DWord; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendInt64( Const AName: String; AValue: Int64; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendOleStr( Const AName: String; AValue: PWideChar; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendBoolean( Const AName: String; AValue: Boolean; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendByte( Const AName: String; AValue: Byte; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendException( Const AName: String; AValue: Exception; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendPoint( Const AName: String; AValue: TPoint; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendRect( Const AName: String; AValue: TRect; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF USEGRAPHICS}
          Procedure SendColor( Const AName: String; AValue: TColor; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$ENDIF}
{$IFDEF USECONTROLS}
          Procedure SendCursor( Const AName: String; AValue: TCursor; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$ENDIF}
          Procedure SendCurrency( Const AName: String; AValue: Currency; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );

{$IFDEF USECLASSES}
          Procedure SendProperty( Const AName: String; AValue: TObject; APropertyName: String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendObject( Const AName: String; AValue: TObject; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendComponent( Const AName: String; AValue: TComponent; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendStrings( Const AName: String; AValue: TStrings; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF SYSTEMINFO}
          Procedure SendSystemInfo( AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$ENDIF}
{$ENDIF}

          Procedure SendBooleanArray( Const AName: String; AValues: Array Of Boolean; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendIntegerArray( Const AName: String; AValues: Array Of Integer; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendStringArray( Const AName: String; AValues: Array Of String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendFloatArray( Const AName: String; AValues: Array Of Extended; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );

{$IFDEF USECLASSES}
          Function GenerateHexDump( AData: Pointer; ADataSize: Integer ): TStringList;
          Procedure SendHexDump( Const AName: String; AAddress: Pointer; ASize: Integer; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );

          Procedure SendRegistryKey( Const AName: String; AKey: HKey; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
          Procedure SendRegistryPath( Const AName: String; APath: String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$ENDIF}

     End;

     // *************************************************************************************
     // *************************************************************************************
     // *************************************************************************************

{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}

     TmxMapRecord = Record
          UnitName: ShortString;
          ProcedureName: ShortString;
          LineNumber: Integer;
     End;

     TmxUnit = Class
          Name: ShortString;
          Next: Pointer;
     End;

     TmxProcedure = Class
          Name: ShortString;
          Start: Integer;
          Next: Pointer;
     End;

     TmxLine = Class
          Line: Integer;
          Start: Integer;
          UnitIndex: Integer;
          Next: Pointer;
     End;

     // ****************************************************
     // ****************************************************
     // ****************************************************

     TmxMap = Class( TObject )
     Private

          FUnitCount: Integer;
          FProcedureCount: Integer;
          FLineCount: Integer;
          FMapShift: Integer;

          FUnitRoot: TmxUnit;
          FProcedureRoot: TmxProcedure;
          FLineRoot: TmxLine;

          FLastUnit: TmxUnit;
          FLastProcedure: TmxProcedure;
          FLastLine: TmxLine;

          Procedure ImportMapInformation;
          Procedure FreeUp;
          Function GetUnit( AIndex: Integer ): TmxUnit;
          Function GetProcedure( AIndex: Integer ): TmxProcedure;
          Function GetLine( AIndex: Integer ): TmxLine;

          Function FindLine( AAddress: Integer ): TmxLine;
          Function FindProcedure( AAddress: Integer ): TmxProcedure;

     Public

          Constructor Create; Virtual;
          Destructor Destroy; Override;

          Function GetMapInfo( AMapPointer: Pointer ): TmxMapRecord;

          Procedure AddUnit( Const AName: ShortString );
          Procedure AddProcedure( Const AName: ShortString; AStart: Integer );
          Procedure AddLine( ALine: Integer; AStart: Integer; AUnitIndex: Integer );

          Property UnitCount: Integer Read FUnitCount;
          Property ProcedureCount: Integer Read FProcedureCount;
          Property LineCount: Integer Read FLineCount;
          Property MapShift: Integer Read FMapShift;

          Property Units[ Index: Integer ]: TmxUnit Read GetUnit;
          Property Procedures[ Index: Integer ]: TmxProcedure Read GetProcedure;
          Property Lines[ Index: Integer ]: TmxLine Read GetLine;
     End;

{$ENDIF}
{$ENDIF}

Var
     _mxClient2Debugger: Cardinal;
     _mxDebugger2Client: Cardinal;

{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     mxMap: TmxMap;
{$ENDIF}
{$ENDIF}

Implementation

{$IFDEF DEBUGGING}
{$IFNDEF VER80}

// *************************************************************************************
// ** DebuggerWindowProc, 8/9/01 9:31:28 AM
// *************************************************************************************

Function DebuggerWindowProc( ahWnd: HWND; aMessage: Integer; awParam: WPARAM; alParam: LPARAM ): Integer; Stdcall;
Var
     Obj: TObject;
     MsgRec: TMessage;
Begin
     Obj := TObject( GetWindowLong( ahWnd, 0 ) );

     If Not ( Obj Is TmxDebugger ) Then
          Result := DefWindowProc( ahWnd, aMessage, awParam, alParam )
     Else
     Begin
          MsgRec.Msg := aMessage;
          MsgRec.wParam := awParam;
          MsgRec.lParam := alParam;
          TmxDebugger( Obj ).WndProc( MsgRec );
          Result := MsgRec.Result;
     End;
End;

Var
     mxDebuggerWindowClass: TWndClass = (
          style: 0;
          lpfnWndProc: @DebuggerWindowProc;
          cbClsExtra: 0;
          cbWndExtra: SizeOf( Pointer );
          hInstance: 0;
          hIcon: 0;
          hCursor: 0;
          hbrBackground: 0;
          lpszMenuName: Nil;
          lpszClassName: 'mxDebuggerWindowClass' );

// *************************************************************************************
// ** DebuggerAllocateHWnd, 8/9/01 9:27:26 AM
// *************************************************************************************

Function DebuggerAllocateHWnd( Obj: TObject ): HWND;
Var
     TempClass: TWndClass;
     ClassRegistered: Boolean;
Begin
     mxDebuggerWindowClass.hInstance := HInstance;
     ClassRegistered := GetClassInfo( HInstance,
          mxDebuggerWindowClass.lpszClassName,
          TempClass );

     If Not ClassRegistered Then
     Begin
          Result := WinProcs.RegisterClass( mxDebuggerWindowClass );
          If Result = 0 Then Exit;
     End;

     Result := CreateWindowEx( WS_EX_TOOLWINDOW,
          mxDebuggerWindowClass.lpszClassName,
          '',
          WS_POPUP,
          0, 0,
          0, 0,
          0,
          0,
          HInstance,
          Nil );

     If ( Result <> 0 ) And Assigned( Obj ) Then SetWindowLong( Result, 0, Integer( Obj ) );
End;

// *************************************************************************************
// ** DebuggerDeAllocateHWnd, 8/9/01 9:31:12 AM
// *************************************************************************************

Procedure DebuggerDeAllocateHWnd( Wnd: HWND );
Begin
     DestroyWindow( Wnd );
End;

{$ENDIF}
{$ENDIF}

// *************************************************************************************
// *************************************************************************************
// *************************************************************************************
// ** TmxDebugger.Create, 8/8/01 2:08:40 PM
// *************************************************************************************
// *************************************************************************************
// *************************************************************************************

Constructor TmxDebugger.Create( AName: ShortString );
{$IFDEF DEBUGGING}
Var
     Size: DWORD;
     LocalMachine: Array[ 0..MAX_COMPUTERNAME_LENGTH ] Of char;
{$ENDIF}
Begin
     Inherited Create;

{$IFDEF DEBUGGING}

     FName := AName;

     // ** Generates Unique ID **

     Size := Sizeof( LocalMachine );
     GetComputerName( LocalMachine, Size );

     FID := Format( '%s [%g]', [ LocalMachine, Now ] );

{$IFDEF VER80}
     FWindowHandle := AllocateHWnd( WndProc );
{$ELSE}
     FWindowHandle := DebuggerAllocateHWnd( Self );
{$ENDIF}

     FDebuggerWnd := 0;
     FEnabled := TRUE;

     FDebugLevel := dlMedium;
{$ENDIF}

End;

// *************************************************************************************
// ** TmxDebugger.Destroy, 8/8/01 2:08:37 PM
// *************************************************************************************

Destructor TmxDebugger.Destroy;
Begin
{$IFDEF DEBUGGING}
     StopDebugging;

{$IFDEF VER80}
     DeallocateHWnd( FWindowHandle );
{$ELSE}
     DebuggerDeAllocateHWnd( FWindowHandle );
{$ENDIF}
{$ENDIF}

     Inherited Destroy;
End;

// *************************************************************************************
// ** GetID, 8/10/01 8:23:08 AM
// *************************************************************************************

{$IFDEF DEBUGGING}

Function TmxDebugger.GetID: String;
Begin
     Result := FID;
End;
{$ENDIF}

// *************************************************************************************
// ** TmxDebugger.WndProc, 8/9/01 9:25:43 AM
// *************************************************************************************

Procedure TmxDebugger.WndProc( Var AMessage: TMessage );
Begin
{$IFDEF DEBUGGING}
     If AMessage.Msg = _mxDebugger2Client Then
     Begin
          Case TmxMessageTypes( AMessage.wParam ) Of

               mtReadyToStart:
                    //If FDebuggerWnd = 0 Then
                    Begin
                         FDebuggerWnd := AMessage.lParam;
                         SendInfoPackage;
                    End;
{$WARNINGS OFF}
               mtDebuggerClosed: If FDebuggerWnd = AMessage.lParam Then FDebuggerWnd := 0;
{$WARNINGS ON}
               mtDebuggerOpened: StartDebugging;

          End;

     End
     Else DefWindowProc( Handle, AMessage.Msg, AMessage.wParam, AMessage.lParam );
{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger._Send, 8/8/01 2:20:59 PM
// *************************************************************************************

{$IFDEF DEBUGGING}

Procedure TmxDebugger._Send( {$IFDEF USEMAPFILE}MapPointer: Pointer; {$ENDIF}AMessage: TmxMessage );
Var
     I: Integer;
     Data: PmxDebugMessage;
     Target: PChar;
     Source: PChar;
     CopyDataStruct: TCopyDataStruct;
{$IFDEF USEMAPFILE}
     MapInfo: TmxMapRecord;
{$ENDIF}
Begin
     If FDebuggerWnd = 0 Then Exit;
     If Not Enabled Then Exit;

     If Not ( AMessage.MessageType In [ mtInfoPackage, mtChangeDebugLevel ] ) Then
          If AMessage.DebugLevel > FDebugLevel Then Exit;

     CopyDataStruct.dwData := 0;
     CopyDataStruct.cbData := Sizeof( TmxDebugMessage ) + AMessage.DataSize;
     Data := AllocMem( CopyDataStruct.cbData );

     Try
          Data^.SenderID := FID;
          Data^.Time := Now;
          Data^.MessageGroup := AMessage.MessageGroup;
          Data^.MessageStr := AMessage.MessageStr;
          Data^.MessageInt := AMessage.MessageInt;
          Data^.DebugLevel := FDebugLevel;

          // *** Work with attached data ***

          Data^.DataSize := AMessage.DataSize;
          //Data^.Data := PChar( AMessage.Data );

          Target := PChar( @Data^.Data );
          Source := PChar( AMessage.Data );

          For I := 1 To AMessage.DataSize Do
          Begin
               Target[ 0 ] := Source[ 0 ];
               Inc( Target );
               Inc( Source );
          End;

          // ** TODO : Get Information from Map File ***

{$IFDEF USEMAPFILE}
          MapInfo := mxMap.GetMapInfo( MapPointer );
          Data^.UnitName := MapInfo.UnitName;
          Data^.ProcedureName := MapInfo.ProcedureName;
          Data^.Line := MapInfo.LineNumber;
{$ELSE}
          Data^.UnitName := '';
          Data^.ProcedureName := '';
          Data^.Line := 0;
{$ENDIF}

          CopyDataStruct.lpData := Data;
          SendMessage( FDebuggerWnd, WM_COPYDATA, WParam( AMessage.MessageType ), LParam( @CopyDataStruct ) );

     Finally
          FreeMem( Data );
     End;
End;

// *************************************************************************************
// ** TmxDebugger._SendStr, 8/17/01 2:40:51 PM
// *************************************************************************************

Procedure TmxDebugger._SendStr( {$IFDEF USEMAPFILE}MapPointer: Pointer; {$ENDIF}Const AName: String; AValue: String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
Var
     _Message: TmxMessage;
Begin
     With _Message Do
     Begin
          MessageGroup := AMsgGroup;
          DebugLevel := ADebugLevel;
          MessageType := mtString;
          MessageInt := 0;

          If AName <> '' Then
               MessageStr := Format( '%s=%s', [ AName, AValue ] ) Else
               MessageStr := AValue;

          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}MapPointer, {$ENDIF}_Message );
End;

{$ENDIF}

// *************************************************************************************
// ** TmxDebugger.SetEnabled, 8/8/01 2:18:43 PM
// *************************************************************************************

Procedure TmxDebugger.SetEnabled( Value: Boolean );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     If Value <> FEnabled Then
     Begin
          FEnabled := TRUE;

          With _Message Do
          Begin
               MessageGroup := mgGeneral;

               If FEnabled Then
                    MessageType := mtEnable Else
                    MessageType := mtDisable;

               DebugLevel := dlLow;
               MessageStr := '';
               MessageInt := 0;
               DataSize := 0;
               Data := Nil;
          End;

          _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
     End;
{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.StartDebugging, 8/9/01 9:14:16 AM
// *************************************************************************************

Procedure TmxDebugger.StartDebugging;
Begin
{$IFDEF DEBUGGING}
     SendMessage( HWND_BROADCAST, _mxClient2Debugger, WParam( mtStart ), Handle );
{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.StopDebugging, 8/9/01 9:14:31 AM
// *************************************************************************************

Procedure TmxDebugger.StopDebugging;
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := dlLow;
          MessageType := mtEnd;
          MessageStr := '';
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

     FDebuggerWnd := 0;
{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.ShowDebugger, 9/13/01 3:42:06 PM
// *************************************************************************************

Procedure TmxDebugger.ShowDebugger;
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := dlLow;
          MessageType := mtShowDebugger;
          MessageStr := '';
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.SendInfoPackage, 8/9/01 1:08:50 PM
// *************************************************************************************

{$IFDEF DEBUGGING}

Procedure TmxDebugger.SendInfoPackage;
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
Begin
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := FDebugLevel;
          MessageType := mtInfoPackage;
          MessageStr := ParamStr( 0 ) + '|' + FName;
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
End;

{$ENDIF}

// *************************************************************************************
// *** Set the debug level
// *************************************************************************************

Procedure TmxDebugger.SetDebugLevel( AValue: TmxDebugLevel );
{$IFDEF DEBUGGING}
Var
     _MapPointer: ^Longint;
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
     Asm
        MOV _MapPointer,EBP
     End;

     If ( FDebugLevel <> AValue ) Then
     Begin
          FDebugLevel := AValue;

          With _Message Do
          Begin
               MessageGroup := mgGeneral;
               DebugLevel := FDebugLevel;
               MessageType := mtChangeDebugLevel;
               MessageStr := '';
               MessageInt := 0;
               DataSize := 0;
               Data := Nil;
          End;

          _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
     End;
{$ENDIF}
End;

// *************************************************************************************
// *** Clear the debugger's display
// *************************************************************************************

Procedure TmxDebugger.ClearDebugger;
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := dlLow;
          MessageType := mtClearDebugger;
          MessageStr := '';
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

// *************************************************************************************
// *** Clear the messages
// *************************************************************************************

Procedure TmxDebugger.ClearMessages;
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := dlLow;
          MessageType := mtClearMessages;
          MessageStr := '';
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

{$ENDIF}
End;

// *************************************************************************************
// *** Send a message to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendMsg( Const AMessage: String; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtMessage;
          MessageStr := AMessage;
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.SendFmtMsg, 8/14/01 4:17:43 PM
// *************************************************************************************

Procedure TmxDebugger.SendFmtMsg( Const AMessage: String; AFormat: String; AValues: Array Of Const; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtMessage;
          MessageStr := AMessage + '=' + Format( AFormat, AValues );
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

{$ENDIF}
End;

// *************************************************************************************
// *** Send a note to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendNote( Const AMessage: String; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtNote;
          MessageStr := AMessage;
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.SendFmtNote, 8/14/01 4:17:43 PM
// *************************************************************************************

Procedure TmxDebugger.SendFmtNote( Const AMessage: String; AFormat: String; AValues: Array Of Const; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtNote;
          MessageStr := AMessage + '=' + Format( AFormat, AValues );
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.SendCheckPoint, 8/31/01 3:54:39 PM
// *************************************************************************************

Procedure TmxDebugger.SendCheckPoint( Const AMessage: String; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtCheckPoint;
          MessageStr := AMessage;
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.SendReminder, 8/31/01 3:55:08 PM
// *************************************************************************************

Procedure TmxDebugger.SendReminder( Const AMessage: String; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtReminder;
          MessageStr := AMessage;
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.SendInfoPad, 8/15/01 8:40:58 AM
// *************************************************************************************

Procedure TmxDebugger.SendInfoPad( Const AName: String; Const AMessage: String; Index: Byte; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtInfoPad;
          MessageStr := AName + '|' + AMessage;
          MessageInt := Index;
          DataSize := 0;
          Data := Nil;
     End;

     If Index In [ 1..3 ] Then _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.SendInfoPad, 8/15/01 8:41:08 AM
// *************************************************************************************

Procedure TmxDebugger.SendInfoPad( Const AName: String; Const AMessage: String; AFormat: String; AValues: Array Of Const; Index: Byte; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtInfoPad;
          MessageStr := AName + '|' + AMessage + '=' + Format( AFormat, AValues );
          MessageInt := Index;
          DataSize := 0;
          Data := Nil;

     End;

     If Index In [ 1..3 ] Then _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a Method Enter to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendEnter( AName: String; ADebugLevel: TmxDebugLevel = dlHigh );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtProcedureEnter;
          MessageStr := AName;
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

{$ENDIF}
End;

// *************************************************************************************
// *** Send a Method Exit to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendExit( AName: String; ADebugLevel: TmxDebugLevel = dlHigh );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtProcedureExit;
          MessageStr := AName;
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

{$ENDIF}
End;

// *************************************************************************************
// *** Send a Separator to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendSeparator( ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := mgGeneral;
          DebugLevel := ADebugLevel;
          MessageType := mtSeparator;
          MessageStr := '';
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

{$ENDIF}
End;

// *************************************************************************************
// *** Send a Float value to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendFloat( Const AName: String; AValue: Extended; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, FloatToStr( AValue ) + ' [FLOAT]', AMsgGroup, ADebugLevel );

{$ENDIF}
End;

// *************************************************************************************
// *** Send a String value to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendString( Const AName: String; AValue: String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, AValue + ' [STRING]', AMsgGroup, ADebugLevel );

{$ENDIF}
End;

// *************************************************************************************
// *** Send an integer value to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendInteger( Const AName: String; AValue: Integer; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, IntToStr( AValue ) + ' [INTEGER]', AMsgGroup, ADebugLevel );

{$ENDIF}
End;

// *************************************************************************************
// *** Send a DWord value to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendDWord( Const AName: String; AValue: DWord; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, IntToStr( AValue ) + ' [DWORD]', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send an integer value to the debugger in hexadecimal format
// *************************************************************************************

Procedure TmxDebugger.SendHex( Const AName: String; AValue: DWord; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, '$' + IntToHex( AValue, 2 ), AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send an int64 value to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendInt64( Const AName: String; AValue: Int64; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, IntToStr( AValue ) + ' [INT64]', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a OleStr to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendOleStr( Const AName: String; AValue: PWideChar; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, OleStrToString( AValue ) + ' [OLESTR]', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a Boolean value to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendBoolean( Const AName: String; AValue: Boolean; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     If AValue Then
          _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, 'TRUE [BOOLEAN]', AMsgGroup, ADebugLevel ) Else
          _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, 'FALSE [BOOLEAN]', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a Byte value to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendByte( Const AName: String; AValue: Byte; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, IntToStr( AValue ) + ' [BYTE]', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send an Exception to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendException( Const AName: String; AValue: Exception; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
     _Message: TmxMessage;
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := AMsgGroup;
          DebugLevel := ADebugLevel;
          MessageType := mtException;
          MessageStr := AName + '=' + AValue.Message;
          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a pointer to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendPointer( Const AName: String; AValue: Pointer; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, Format( '$%.8x', [ LongInt( AValue ) ] ) + ' [POINTER]', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a point to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendPoint( Const AName: String; AValue: TPoint; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := AMsgGroup;
          DebugLevel := ADebugLevel;
          MessageType := mtPoint;

          If AName <> '' Then
               MessageStr := Format( '%s = ( %d, %d )', [ AName, AValue.X, AValue.Y ] ) Else
               MessageStr := Format( '%s = ( %d, %d )', [ 'Point', AValue.X, AValue.Y ] );

          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a Rect to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendRect( Const AName: String; AValue: TRect; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := AMsgGroup;
          DebugLevel := ADebugLevel;
          MessageType := mtRect;

          If AName <> '' Then
               MessageStr := Format( '%s = ( %d, %d, %d, %d )', [ AName, AValue.Left, AValue.Top, AValue.Right, AValue.Bottom ] ) Else
               MessageStr := Format( '%s = ( %d, %d, %d, %d )', [ 'Rect', AValue.Left, AValue.Top, AValue.Right, AValue.Bottom ] );

          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a Color to the debugger
// *************************************************************************************

{$IFDEF USEGRAPHICS}

Procedure TmxDebugger.SendColor( Const AName: String; AValue: TColor; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _RBGColor: Longint;
     _Message: TmxMessage;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := AMsgGroup;
          DebugLevel := ADebugLevel;
          MessageType := mtColor;

          _RBGColor := ColorToRGB( AValue );

          If AName <> '' Then
               MessageStr := Format( '%s=%s ( %d, %d, %d )', [ AName, ColorToString( AValue ), ( _RBGColor Div $10000 ), ( ( _RBGColor Mod $10000 ) Div $100 ), ( _RBGColor Mod $100 ) ] ) Else
               MessageStr := Format( '%s=%s ( %d, %d, %d )', [ 'Color', ColorToString( AValue ), ( _RBGColor Div $10000 ), ( ( _RBGColor Mod $10000 ) Div $100 ), ( _RBGColor Mod $100 ) ] );

          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

{$ENDIF}

// *************************************************************************************
// *** Send a Cursor to the debugger
// *************************************************************************************

{$IFDEF USECONTROLS}

Procedure TmxDebugger.SendCursor( Const AName: String; AValue: TCursor; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := AMsgGroup;
          DebugLevel := ADebugLevel;
          MessageType := mtCursor;

          If AName <> '' Then
               MessageStr := Format( '%s=%s', [ AName, CursorToString( AValue ) ] ) Else
               MessageStr := Format( '%s=%s', [ 'Cursor', CursorToString( AValue ) ] );

          MessageInt := 0;
          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

{$ENDIF}

// *************************************************************************************
// *** Send a Currency value to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendCurrency( Const AName: String; AValue: Currency; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, CurrToStr( AValue ) + ' [CURRENCY]', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a DateTime to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendDateTime( Const AName: String; AValue: TDateTime; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, DateTimeToStr( AValue ) + ' [DATETIME]', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a Date to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendDate( Const AName: String; AValue: TDateTime; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, DateToStr( AValue ) + ' [DATE]', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a Time to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendTime( Const AName: String; AValue: TDateTime; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, TimeToStr( AValue ) + ' [TIME]', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.GenerateHexDump, 9/3/01 11:29:52 AM
// *************************************************************************************

{$IFDEF USECLASSES}

Function TmxDebugger.GenerateHexDump( AData: Pointer; ADataSize: Integer ): TStringList;
Var
     _Address: ShortString;
     _Dump: ShortString;
     _Ansi: ShortString;
     X, I: Integer;
Begin
     Result := TStringList.Create;

     _Address := Format( '%.8x:', [ LongInt( AData ) ] );
     _Dump := '';
     _Ansi := '';

     For I := 0 To ADataSize - 1 Do
     Begin
          _Dump := _Dump + Format( '%3.2x', [ Byte( ( pChar( AData ) + I )^ ) ] );

          If Byte( ( pChar( AData ) + I )^ ) >= 31 Then
               _Ansi := _Ansi + Char( ( pChar( AData ) + I )^ ) Else
               _Ansi := _Ansi + '.';

          If ( LongInt( AData ) + I ) Mod 16 = 7 Then _Dump := _Dump + ' |';

          If ( LongInt( AData ) + I ) Mod 16 = 15 Then
          Begin
               For X := Length( _Dump ) + 1 To 50 Do _Dump := ' ' + _Dump;
               For X := Length( _Ansi ) + 1 To 16 Do _Ansi := ' ' + _Ansi;

               Result.Add( _Address + _Dump + ' | ' + _Ansi );

               _Address := Format( '%.8x:', [ LongInt( AData ) + I + 1 ] );
               _Dump := '';
               _Ansi := '';
          End;
     End;

     For X := Length( _Dump ) + 1 To 50 Do _Dump := _Dump + ' ';

     Result.Add( _Address + _Dump + ' | ' + _Ansi );
End;

{$ENDIF}

// *************************************************************************************
// *** Send a Hexadecimal Dump to the debugger
// *************************************************************************************

{$IFDEF USECLASSES}

Procedure TmxDebugger.SendHexDump( Const AName: String; AAddress: Pointer; ASize: Integer; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
     _MessageData: TStringList;
     _MemoryStream: TMemoryStream;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _MessageData := Nil;
     _MemoryStream := Nil;

     Try
          _MessageData := GenerateHexDump( AAddress, ASize );
          Try
               _MemoryStream := TMemoryStream.Create;
               _MessageData.SaveToStream( _MemoryStream );

               With _Message Do
               Begin
                    MessageGroup := AMsgGroup;
                    DebugLevel := ADebugLevel;
                    MessageType := mtMemoryDump;
                    MessageStr := AName;
                    MessageInt := 0;
                    DataSize := _MemoryStream.Size;
                    Data := _MemoryStream.Memory;
                    //_MemoryStream.SaveToFile( 'c:\test.log' );
               End;

               _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

          Finally
               _MemoryStream.Free;
          End;
     Finally
          _MessageData.Free;
     End;
{$ENDIF}
End;

{$ENDIF}

// *************************************************************************************
// *** Send an object to the debugger
// *************************************************************************************

{$IFDEF USECLASSES}

Function ObjectToStringList( AObject: TObject; Indent: String ): TStringList;
Var
     PropertyIndex: Integer;
     PropertyList: ^TPropList;
     PropertyName: String;
     PropertyInfo: PPropInfo;
     PropertyType: PTypeInfo;
     PropertyKind: TTypeKind;

     I: Integer;
     TempStr: String;
     TempInteger: Integer;
     InternalStringList: TStringList;

     BaseType: PTypeInfo;
     BaseData: PTypeData;
     GetProc: Pointer;
     NextObject: TObject;
Begin
     Result := TStringList.Create;

     GetMem( PropertyList, SizeOf( TPropList ) );
     Try
          FillChar( PropertyList^[ 0 ], SizeOf( TPropList ), #00 );
          GetPropList( AObject.ClassInfo, tkProperties - [ tkArray, tkRecord, tkInterface ], @PropertyList^[ 0 ] );

          PropertyIndex := 0;
          While ( ( PropertyIndex < High( PropertyList^ ) ) And ( Nil <> PropertyList^[ PropertyIndex ] ) ) Do
          Begin
               PropertyInfo := PropertyList^[ PropertyIndex ];
               PropertyType := PropertyInfo^.PropType^;
               PropertyKind := PropertyType^.Kind;
               PropertyName := PropertyInfo^.Name;
               GetProc := PropertyInfo^.GetProc;

               If Not Assigned( GetProc ) Then Result.Add( Indent + PropertyName + ' = <' + PropertyType^.Name + '>' ) Else
               Begin
                    Case PropertyKind Of

                         tkUnknown: Result.Add( Indent + 'Unknown property type' );
                         tkArray: Result.Add( Indent + 'Property is an array' );
                         tkRecord: Result.Add( Indent + 'Property is a record' );
                         tkInterface: Result.Add( Indent + 'Property is an interface' );
                         tkInteger: Result.Add( Indent + PropertyName + ' = ' + IntToStr( GetOrdProp( AObject, PropertyInfo ) ) );
                         tkChar: Result.Add( Indent + PropertyName + ' = ' + '#$' + IntToHex( GetOrdProp( AObject, PropertyInfo ), 2 ) );
                         tkEnumeration: Result.Add( Indent + PropertyName + ' = ' + GetEnumName( PropertyType, GetOrdProp( AObject, PropertyInfo ) ) );
                         tkFloat: Result.Add( Indent + PropertyName + ' = ' + FloatToStr( GetFloatProp( AObject, PropertyInfo ) ) );
                         tkWChar: Result.Add( Indent + PropertyName + ' = #$' + IntToHex( GetOrdProp( AObject, PropertyInfo ), 4 ) );
                         tkWString: Result.Add( Indent + PropertyName + ' = ' + '''' + GetStrProp( AObject, PropertyInfo ) + '''' );
                         tkString: Result.Add( Indent + PropertyName + ' = ' + '''' + GetStrProp( AObject, PropertyInfo ) + '''' );
                         tkLString: Result.Add( Indent + PropertyName + ' = ' + '''' + GetStrProp( AObject, PropertyInfo ) + '''' );
                         tkVariant: Result.Add( Indent + PropertyName + ' = ' + GetVariantProp( AObject, PropertyInfo ) );
                         tkMethod: Result.Add( Indent + PropertyName + ' = (' + GetEnumName( TypeInfo( TMethodKind ), Ord( GetTypeData( PropertyType )^.MethodKind ) ) + ')' );
                         tkSet:
                              Begin
                                   BaseType := GetTypeData( PropertyType )^.CompType^;
                                   BaseData := GetTypeData( BaseType );
                                   TempInteger := GetOrdProp( AObject, PropertyInfo );
                                   Result.Add( Indent + PropertyName + ' = [' + BaseType^.Name + ']' );

                                   For I := BaseData^.MinValue To BaseData^.MaxValue Do
                                   Begin
                                        If GetEnumName( BaseType, I ) = '' Then Break;
                                        TempStr := Indent + '   ' + GetEnumName( BaseType, I );

                                        If I In TIntegerSet( TempInteger ) Then
                                             TempStr := TempStr + ' = True' Else
                                             TempStr := TempStr + ' = False';

                                        Result.Add( Indent + TempStr );
                                   End;

                                   Result.Add( Indent + 'End' );
                              End;

                         tkClass:
                              Begin
                                   TempInteger := GetOrdProp( AObject, PropertyInfo );

                                   If TempInteger = 0 Then
                                   Begin
                                        TempStr := PropertyName + ' = <' + PropertyType^.Name + '> (Not Assigned)';
                                        Result.Add( Indent + TempStr );
                                   End
                                   Else
                                   Begin
                                        NextObject := TObject( TempInteger );
                                        TempStr := PropertyName + ' = <' + PropertyType^.Name + '>';
                                        If NextObject Is TComponent Then TempStr := TempStr + ': ' + TComponent( NextObject ).Name;
                                        Result.Add( Indent + TempStr );

                                        If Not ( NextObject Is TComponent ) Then
                                        Begin
                                             InternalStringList := ObjectToStringList( NextObject, Indent + '  ' );
                                             For I := 0 To InternalStringList.Count - 1 Do Result.Add( InternalStringList[ I ] );
                                             Result.Add( Indent + 'End' );
                                             InternalStringList.Free;
                                        End;
                                   End;
                              End;
                    Else Result.Add( Indent + PropertyName + ' = <' + PropertyType^.Name + '> (' + GetEnumName( TypeInfo( TTypeKind ), Ord( PropertyKind ) ) + ')' );
                    End
               End;

               Inc( PropertyIndex );
          End;

     Finally

          FreeMem( PropertyList );

     End;
End;

{$ENDIF}

// *************************************************************************************
// ** TmxDebugger.SendObject, 9/4/01 12:05:30 PM
// *************************************************************************************

{$IFDEF USECLASSES}

Procedure TmxDebugger.SendObject( Const AName: String; AValue: TObject; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
     _ObjectStream: TStringList;
     _MemoryStream: TMemoryStream;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _MemoryStream := Nil;
     _ObjectStream := Nil;

     Try
          _ObjectStream := ObjectToStringList( AValue, '' );

          _MemoryStream := TMemoryStream.Create;
          _ObjectStream.SaveToStream( _MemoryStream );

          With _Message Do
          Begin
               MessageGroup := AMsgGroup;
               DebugLevel := ADebugLevel;
               MessageType := mtObject;
               MessageStr := AName + ' [TOBJECT]';
               MessageInt := 0;
               DataSize := _MemoryStream.Size;
               Data := _MemoryStream.Memory;
               //_MemoryStream.SaveToFile( 'c:\object.log' );
          End;

          _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

     Finally
          _MemoryStream.Free;
          _ObjectStream.Free;
     End;
{$ENDIF}
End;

{$ENDIF}

// *************************************************************************************
// ** PropertyToString, 9/4/01 1:19:11 PM
// *************************************************************************************

{$IFDEF USECLASSES}

Function PropertyToStringList( AObject: TObject; PropertyName: String ): TStringList;
Var
     I: Integer;
     PropertyInfo: PPropInfo;
     PropertyType: PTypeInfo;
     PropertyKind: TTypeKind;
     BaseType: PTypeInfo;
     BaseData: PTypeData;
     GetProc: Pointer;
Begin
     Result := TStringList.Create;

     PropertyInfo := GetPropInfo( AObject.ClassInfo, PropertyName );

     If Assigned( PropertyInfo ) Then
     Begin
          PropertyType := PropertyInfo^.PropType^;
          PropertyKind := PropertyType^.Kind;

          GetProc := PropertyInfo^.GetProc;

          Result.Add( 'Property type is:' );
          Result.Add( '-----------------' );
          Result.Add( '<' + PropertyType^.Name + '>' );
          Result.Add( '' );
          Result.Add( 'Property value(s):' );
          Result.Add( '------------------' );

          If Assigned( GetProc ) Then
          Begin
               Case PropertyKind Of
                    tkUnknown: Result.Add( 'Unknown property type' );
                    tkArray: Result.Add( 'Property is an array' );
                    tkRecord: Result.Add( 'Property is a record' );
                    tkInterface: Result.Add( 'Property is an interface' );
                    tkFloat: Result.Add( FloatToStr( GetFloatProp( AObject, PropertyInfo ) ) );
                    tkEnumeration: Result.Add( GetEnumName( PropertyType, GetOrdProp( AObject, PropertyInfo ) ) );
                    tkLString: Result.Add( GetStrProp( AObject, PropertyInfo ) );
                    tkWString: Result.Add( GetStrProp( AObject, PropertyInfo ) );
                    tkString: Result.Add( GetStrProp( AObject, PropertyInfo ) );
                    tkVariant: Result.Add( GetVariantProp( AObject, PropertyInfo ) );
                    tkInteger: Result.Add( IntToStr( GetOrdProp( AObject, PropertyInfo ) ) );
                    tkChar: Result.Add( '#$' + IntToHex( GetOrdProp( AObject, PropertyInfo ), 2 ) );
                    tkWChar: Result.Add( '#$' + IntToHex( GetOrdProp( AObject, PropertyInfo ), 4 ) );
                    tkMethod: Result.Add( '(' + GetEnumName( TypeInfo( TMethodKind ), Ord( GetTypeData( PropertyType )^.MethodKind ) ) + ')' );

                    tkSet:
                         Begin
                              BaseType := GetTypeData( PropertyType )^.CompType^;
                              BaseData := GetTypeData( BaseType );

                              For I := BaseData^.MinValue To BaseData^.MaxValue Do
                              Begin
                                   If I In TIntegerSet( GetOrdProp( AObject, PropertyInfo ) ) Then
                                   Begin
                                        If GetEnumName( BaseType, I ) = '' Then Break;
                                        Result.Add( GetEnumName( BaseType, I ) );
                                   End;
                              End;
                         End;

                    tkClass:
                         Begin
                              If GetOrdProp( AObject, PropertyInfo ) = 0 Then
                                   Result.Add( '<' + PropertyType^.Name + '> (Not Assigned)' ) Else
                                   Result.Add( '<' + PropertyType^.Name + '> (Assigned)' );
                         End;

               Else Result.Add( '<' + PropertyType^.Name + '> (' + GetEnumName( TypeInfo( TTypeKind ), Ord( PropertyKind ) ) + ')' );
               End
          End
     End
     Else Result.Add( '<Unknown>' );
End;

{$ENDIF}

// *************************************************************************************
// *** Send a property value to the debugger
// *************************************************************************************

{$IFDEF USECLASSES}

Procedure TmxDebugger.SendProperty( Const AName: String; AValue: TObject; APropertyName: String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
     _ObjectStream: TStringList;
     _MemoryStream: TMemoryStream;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _MemoryStream := Nil;
     _ObjectStream := Nil;

     Try
          _ObjectStream := PropertyToStringList( AValue, APropertyName );

          _MemoryStream := TMemoryStream.Create;
          _ObjectStream.SaveToStream( _MemoryStream );

          With _Message Do
          Begin
               MessageGroup := AMsgGroup;
               DebugLevel := ADebugLevel;
               MessageType := mtProperty;
               MessageStr := AName + ' [PROPERTY]';
               MessageInt := 0;
               DataSize := _MemoryStream.Size;
               Data := _MemoryStream.Memory;
               //_MemoryStream.SaveToFile( 'C:\Property.log' );
          End;

          _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

     Finally
          _MemoryStream.Free;
          _ObjectStream.Free;
     End;
{$ENDIF}
End;

{$ENDIF}

// *************************************************************************************
// *** Send a component to the debugger
// *************************************************************************************

{$IFDEF USECLASSES}

Procedure TmxDebugger.SendComponent( Const AName: String; AValue: TComponent; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
     _ComponentStream: TMemoryStream;
     _MemoryStream: TMemoryStream;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _MemoryStream := Nil;
     _ComponentStream := Nil;

     Try
          _ComponentStream := TMemoryStream.Create;
          _MemoryStream := TMemoryStream.Create;

          _ComponentStream.WriteComponent( AValue );
          _ComponentStream.Position := 0;

          ObjectBinaryToText( _ComponentStream, _MemoryStream );

          With _Message Do
          Begin
               MessageGroup := AMsgGroup;
               DebugLevel := ADebugLevel;
               MessageType := mtComponent;
               MessageStr := AName + ' [TCOMPONENT]';
               MessageInt := 0;
               DataSize := _MemoryStream.Size;
               Data := _MemoryStream.Memory;
               //_MemoryStream.SaveToFile( 'c:\component.log' );
          End;

          _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

     Finally
          _MemoryStream.Free;
          _ComponentStream.Free;
     End;
{$ENDIF}
End;

{$ENDIF}

// *************************************************************************************
// *** Send Strings to the debugger
// *************************************************************************************

{$IFDEF USECLASSES}

Procedure TmxDebugger.SendStrings( Const AName: String; AValue: TStrings; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
     _MemoryStream: TMemoryStream;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _MemoryStream := Nil;

     Try
          _MemoryStream := TMemoryStream.Create;
          AValue.SaveToStream( _MemoryStream );

          With _Message Do
          Begin
               MessageGroup := AMsgGroup;
               DebugLevel := ADebugLevel;
               MessageType := mtStringList;
               MessageStr := AName;
               MessageInt := 0;
               DataSize := _MemoryStream.Size;
               Data := _MemoryStream.Memory;
               //_MemoryStream.SaveToFile( 'c:\component.log' );
          End;

          _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

     Finally
          _MemoryStream.Free;
     End;
{$ENDIF}
End;

{$ENDIF}

// *************************************************************************************
// ** Short information about the client system
// *************************************************************************************

{$IFDEF USECLASSES}
{$IFDEF SYSTEMINFO}

Procedure TmxDebugger.SendSystemInfo( AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
     _MemoryStream: TMemoryStream;
     _SystemInfo: TStringList;
     _MemoryStatus: TMemoryStatus;
     _OSVersionInfo: TOSVersionInfo;
     _TempArray: Array[ 0..255 ] Of Char;
     _Length: DWord;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _MemoryStream := Nil;

     Try
          _MemoryStream := TMemoryStream.Create;
          _SystemInfo := TStringList.Create;

          // *** Generate System Info ***

          _Length := 255;
          FillChar( _TempArray, SizeOf( _TempArray ), #0 );
          GetComputerName( _TempArray, _Length );
          _SystemInfo.Add( Format( 'ComputerName: %s', [ _TempArray ] ) );

          FillChar( _TempArray, SizeOf( _TempArray ), #0 );
          _Length := 255;
          GetUserName( _TempArray, _Length );
          _SystemInfo.Add( Format( 'UserName: %s', [ _TempArray ] ) );

          // *** OS Version ***

          _OSVersionInfo.dwOSVersionInfoSize := sizeof( TOSVERSIONINFO );
          GetVersionEx( _OSVersionInfo );
          Case _OSVersionInfo.dwPlatformId Of
               VER_PLATFORM_WIN32s: _SystemInfo.Add( 'Windows Type: 3.1/32s' );
               VER_PLATFORM_WIN32_WINDOWS: _SystemInfo.Add( 'Windows Type: 95/Me' );
               VER_PLATFORM_WIN32_NT: _SystemInfo.Add( 'Windows Type: NT/2000' );
          End;

          With _OSVersionInfo Do
          Begin
               _SystemInfo.Add( Format( 'Windows Version : %d.%d', [ dwMajorVersion, dwMinorVersion ] ) );
               _SystemInfo.Add( Format( 'Build Number: %d', [ LOWORD( dwBuildNumber ) ] ) );
               _SystemInfo.Add( '' );
          End;

          // *** Memory Status ***

          _MemoryStatus.dwLength := sizeof( TMemoryStatus );
          GlobalMemoryStatus( _MemoryStatus );
          With _MemoryStatus Do
          Begin
               _SystemInfo.Add( Format( 'Total memory: %d KB', [ Trunc( dwTotalPhys / 1024 ) ] ) );
               _SystemInfo.Add( Format( 'Memory Available: %d KB', [ Trunc( dwAvailPhys / 1024 ) ] ) );
               _SystemInfo.Add( Format( 'Memory Usage: %d %%', [ trunc( dwAvailPhys / dwTotalPhys * 100 ) ] ) );
               _SystemInfo.Add( Format( 'Swapfile Total: %d KB', [ Trunc( dwTotalPageFile / 1024 ) ] ) );
               _SystemInfo.Add( Format( 'Swapfile Size: %d KB', [ Trunc( ( dwTotalPageFile - dwAvailPageFile ) / 1024 ) ] ) );
               _SystemInfo.Add( Format( 'Swapfile Usage: %d %%', [ 100 - trunc( dwAvailPageFile / dwTotalPageFile * 100 ) ] ) );
               _SystemInfo.Add( '' );
          End;

          // ****************************

          _SystemInfo.SaveToStream( _MemoryStream );

          With _Message Do
          Begin
               MessageGroup := AMsgGroup;
               DebugLevel := ADebugLevel;
               MessageType := mtSystemInfo;
               MessageStr := 'System information';
               MessageInt := 0;
               DataSize := _MemoryStream.Size;
               Data := _MemoryStream.Memory;
               //_MemoryStream.SaveToFile( 'c:\systeminfo.log' );
          End;

          _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );

     Finally
          _MemoryStream.Free;
     End;
{$ENDIF}
End;

{$ENDIF}
{$ENDIF}

// *************************************************************************************
// *** Send a Boolean Array to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendBooleanArray( Const AName: String; AValues: Array Of Boolean; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     X: Integer;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF} '', 'Start of Boolean Array', AMsgGroup, ADebugLevel );

     For X := Low( AValues ) To High( AValues ) Do
     Begin
          If AValues[ X ] Then
               _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}Format( 'Item %d', [ X ] ), 'TRUE', AMsgGroup, ADebugLevel ) Else
               _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}Format( 'Item %d', [ X ] ), 'FALSE', AMsgGroup, ADebugLevel );
     End;

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF} '', 'End of Boolean Array', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send an Integer Array to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendIntegerArray( Const AName: String; AValues: Array Of Integer; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     X: Integer;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF} '', 'Start of Integer Array', AMsgGroup, ADebugLevel );

     For X := Low( AValues ) To High( AValues ) Do
     Begin
          _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}Format( 'Item %d', [ X ] ), Format( '%d', [ AValues[ X ] ] ), AMsgGroup, ADebugLevel );
     End;

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF} '', 'End of Integer Array', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a String Array to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendStringArray( Const AName: String; AValues: Array Of String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     X: Integer;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF} '', 'Start of String Array', AMsgGroup, ADebugLevel );

     For X := Low( AValues ) To High( AValues ) Do
     Begin
          _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}Format( 'Item %d', [ X ] ), AValues[ X ], AMsgGroup, ADebugLevel );
     End;

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF} '', 'End of String Array', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send a Float Array to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendFloatArray( Const AName: String; AValues: Array Of Extended; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     X: Integer;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF} '', 'Start of Float Array', AMsgGroup, ADebugLevel );

     For X := Low( AValues ) To High( AValues ) Do
     Begin
          _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}Format( 'Item %d', [ X ] ), FloatToStr( AValues[ X ] ), AMsgGroup, ADebugLevel );
     End;

     _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF} '', 'End of Float Array', AMsgGroup, ADebugLevel );
{$ENDIF}
End;

// *************************************************************************************
// *** Send Assigned to the debugger
// *************************************************************************************

Procedure TmxDebugger.SendAssigned( Const AName: String; AValue: Pointer; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     If Assigned( AValue ) Then
          _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, '(Assigned)' ) Else
          _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, '(Not Assigned)' );
{$ENDIF}
End;

// *************************************************************************************
// *** Assert
// *************************************************************************************

Procedure TmxDebugger.Assert( ACondition: Boolean; AName: String; AValue: String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     If Not ACondition Then
     Begin
          _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, AValue + ' [ASSERT]', AMsgGroup, ADebugLevel );
     End;
{$ENDIF}
End;

// *************************************************************************************
// *** Assert, Formated array
// *************************************************************************************

Procedure TmxDebugger.AssertFmt( ACondition: Boolean; AName: String; AFormat: String; AValue: Array Of Const; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
Var
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     If Not ACondition Then
     Begin
          _SendStr( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}AName, Format( AFormat, AValue ) + ' [ASSERT]', AMsgGroup, ADebugLevel );
     End;
{$ENDIF}
End;

// *************************************************************************************
// ** TmxDebugger.SendRegistryPath, 9/7/01 11:41:43 AM
// *************************************************************************************

{$IFDEF USECLASSES}

Procedure TmxDebugger.SendRegistryPath( Const AName: String; APath: String; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := AMsgGroup;
          DebugLevel := ADebugLevel;
          MessageType := mtRegistry;
          MessageInt := 0;

          If AName <> '' Then
               MessageStr := Format( '%s=%s', [ AName, APath ] ) Else
               MessageStr := APath;

          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

{$ENDIF}

// *************************************************************************************
// ** TmxDebugger.SendRegistryKey, 9/7/01 11:42:06 AM
// *************************************************************************************

{$IFDEF USECLASSES}

Procedure TmxDebugger.SendRegistryKey( Const AName: String; AKey: HKey; AMsgGroup: TmxMessageGroup = mgGeneral; ADebugLevel: TmxDebugLevel = dlLow );
{$IFDEF DEBUGGING}
Var
     _Message: TmxMessage;
     _TempStr: String;
{$IFDEF USEMAPFILE}
     _MapPointer: ^Longint;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     Asm
        MOV _MapPointer,EBP
     End;
{$ENDIF}

     With _Message Do
     Begin
          MessageGroup := AMsgGroup;
          DebugLevel := ADebugLevel;
          MessageType := mtRegistry;
          MessageInt := 0;

          Case AKey Of
               HKEY_CLASSES_ROOT: _TempStr := 'HKEY_CLASSES_ROOT';
               HKEY_CURRENT_USER: _TempStr := 'HKEY_CURRENT_USER';
               HKEY_LOCAL_MACHINE: _TempStr := 'HKEY_LOCAL_MACHINE';
               HKEY_USERS: _TempStr := 'HKEY_USERS';
               HKEY_PERFORMANCE_DATA: _TempStr := 'HKEY_PERFORMANCE_DATA';
               HKEY_CURRENT_CONFIG: _TempStr := 'HKEY_CURRENT_CONFIG';
               HKEY_DYN_DATA: _TempStr := 'HKEY_CURRENT_CONFIG';
          Else _TempStr := Format( 'DWORD(%s)', [ IntToHex( AKey, 8 ) ] );
          End;

          If AName <> '' Then
               MessageStr := Format( '%s=%s', [ AName, _TempStr ] ) Else
               MessageStr := _TempStr;

          DataSize := 0;
          Data := Nil;
     End;

     _Send( {$IFDEF USEMAPFILE}_MapPointer, {$ENDIF}_Message );
{$ENDIF}
End;

{$ENDIF}

// *************************************************************************************
// *************************************************************************************
// *************************************************************************************
// * TmxMap.Create, 9/9/2002 5:23:23 PM
// *************************************************************************************
// *************************************************************************************
// *************************************************************************************

{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}

Constructor TmxMap.Create;
Begin
     Inherited Create;

     FUnitCount := 0;
     FProcedureCount := 0;
     FLineCount := 0;
     FMapShift := 0;

     FUnitRoot := Nil;
     FProcedureRoot := Nil;
     FLineRoot := Nil;

     FLastUnit := Nil;
     FLastProcedure := Nil;
     FLastLine := Nil;

     ImportMapInformation;
End;

// *************************************************************************************
// ** TmxMap.ImportMapInformation, 9/10/01 10:37:38 AM
// *************************************************************************************

Function ConvertAddress( Address: Pointer ): Pointer; Assembler;
Asm
	TEST    EAX,EAX
	JE      @@1
	SUB     EAX,OFFSET TextStart
@@1:
End;

Procedure TmxMap.ImportMapInformation;
Var
     _MapFile: System.TextFile;
     _Buffer: Array[ 1..8192 ] Of Char; { 8K buffer }
     _FirstUnit: Boolean;
     _Line: ShortString;
Begin
     If Not FileExists( ChangeFileExt( ParamStr( 0 ), '.map' ) ) Then Exit;

     FMapShift := Integer( pChar( @Self ) - pChar( ConvertAddress( @Self ) ) ) - 512;

     AssignFile( _MapFile, ChangeFileExt( ParamStr( 0 ), '.map' ) );
     System.SetTextBuf( _MapFile, _Buffer );

     Try
          Reset( _MapFile );

          While Not EOF( _MapFile ) Do
          Begin
               Readln( _MapFile, _Line );
               If Pos( 'Publics by Value', _Line ) > 0 Then Break;
          End;

          While Not EOF( _MapFile ) Do
          Begin
               Readln( _MapFile, _Line );

               If Pos( 'TextStart', _Line ) > 0 Then FMapShift := Integer( @TextStart ) - StrToInt( '$' + Copy( _Line, 7, 8 ) );
               If Pos( 'Line numbers for', _Line ) <> 0 Then Break;

               If Pos( '0001:', _Line ) <> 0 Then AddProcedure( Copy( _Line, 22, 99 ), Mapshift + StrToInt( '$' + Copy( _Line, 7, 8 ) ) );
          End;

          _FirstUnit := TRUE;

          While Not EOF( _MapFile ) Do
          Begin
               Readln( _MapFile, _Line );
               If Pos( 'Program entry point', _Line ) <> 0 Then Break;
               If Pos( 'Bound resource files', _Line ) <> 0 Then Break;

               If Pos( 'Line numbers for', _Line ) > 0 Then
               Begin
                    AddUnit( ExtractFileName( Copy( _Line, Pos( '(', _Line ) + 1, Pos( ')', _Line ) - Pos( '(', _Line ) - 1 ) ) );
                    _FirstUnit := FALSE;
               End
               Else
               Begin
                    If Not _FirstUnit Then
                    Begin
                         If Length( _Line ) >= 20 Then AddLine( StrToInt( Copy( _Line, 1, 6 ) ), Mapshift + StrToInt( '$' + Copy( _Line, 13, 8 ) ), FUnitCount - 1 );
                         If Length( _Line ) >= 40 Then AddLine( StrToInt( Copy( _Line, 21, 6 ) ), Mapshift + StrToInt( '$' + Copy( _Line, 33, 8 ) ), FUnitCount - 1 );
                         If Length( _Line ) >= 60 Then AddLine( StrToInt( Copy( _Line, 41, 6 ) ), Mapshift + StrToInt( '$' + Copy( _Line, 53, 8 ) ), FUnitCount - 1 );
                         If Length( _Line ) >= 80 Then AddLine( StrToInt( Copy( _Line, 61, 6 ) ), Mapshift + StrToInt( '$' + Copy( _Line, 73, 8 ) ), FUnitCount - 1 );
                    End;
               End;
          End;

     Finally

          System.Closefile( _MapFile );

     End;
End;

// *************************************************************************************
// * TmxMap.Destroy, 9/9/2002 5:23:27 PM
// *************************************************************************************

Destructor TmxMap.Destroy;
Begin
     FreeUp;
     Inherited Destroy;
End;

// *************************************************************************************
// ** TmxMap.FreeUp, 9/10/01 9:40:58 AM
// *************************************************************************************

Procedure TmxMap.FreeUp;
Var
     _Unit: TmxUnit;
     _Procedure: TmxProcedure;
     _Line: TmxLine;
Begin
     While FUnitRoot <> Nil Do
     Begin
          _Unit := FUnitRoot.Next;
          FUnitRoot.Free;
          FUnitRoot := _Unit;
     End;

     While FProcedureRoot <> Nil Do
     Begin
          _Procedure := FProcedureRoot.Next;
          FProcedureRoot.Free;
          FProcedureRoot := _Procedure;
     End;

     While FLineRoot <> Nil Do
     Begin
          _Line := FLineRoot.Next;
          FLineRoot.Free;
          FLineRoot := _Line;
     End;
End;

// *************************************************************************************
// ** TmxMap.AddUnit, 9/10/01 9:47:28 AM
// *************************************************************************************

Procedure TmxMap.AddUnit( Const AName: ShortString );
Var
     _NewUnit: TmxUnit;
Begin
     _NewUnit := TmxUnit.Create;
     _NewUnit.Name := AName;

     If FUnitRoot = Nil Then
          FUnitRoot := _NewUnit Else
          FLastUnit.Next := _NewUnit;

     FLastUnit := _NewUnit;
     Inc( FUnitCount );
End;

// *************************************************************************************
// ** TmxMap.AddProcedure, 9/10/01 10:07:50 AM
// *************************************************************************************

Procedure TmxMap.AddProcedure( Const AName: ShortString; AStart: Integer );
Var
     _NewProcedure: TmxProcedure;
Begin
     _NewProcedure := TmxProcedure.Create;
     _NewProcedure.Name := AName;
     _NewProcedure.Start := AStart;

     If FProcedureRoot = Nil Then
          FProcedureRoot := _NewProcedure Else
          FLastProcedure.Next := _NewProcedure;

     FLastProcedure := _NewProcedure;
     Inc( FProcedureCount );
End;

// *************************************************************************************
// ** TmxMap.AddLine, 9/10/01 10:19:53 AM
// *************************************************************************************

Procedure TmxMap.AddLine( ALine: Integer; AStart: Integer; AUnitIndex: Integer );
Var
     _NewLine: TmxLine;
Begin
     _NewLine := TmxLine.Create;
     _NewLine.Line := ALine;
     _NewLine.Start := AStart;
     _NewLine.UnitIndex := AUnitIndex;

     If FLineRoot = Nil Then
          FLineRoot := _NewLine Else
          FLastLine.Next := _NewLine;

     FLastLine := _NewLine;
     Inc( FLineCount );
End;

// *************************************************************************************
// ** TmxMap.GetUnit, 9/10/01 9:53:47 AM
// *************************************************************************************

Function TmxMap.GetUnit( AIndex: Integer ): TmxUnit;
Var
     _Unit: TmxUnit;
     _Index: Integer;
Begin
     Result := Nil;
     If AIndex > FUnitCount - 1 Then Exit;

     _Index := 0;
     _Unit := FUnitRoot;

     While _Unit <> Nil Do
     Begin
          If _Index = AIndex Then
          Begin
               Result := _Unit;
               Break;
          End;

          Inc( _Index );
          _Unit := _Unit.Next;
     End;
End;

// *************************************************************************************
// ** TmxMap.GetProcedure, 9/10/01 10:11:16 AM
// *************************************************************************************

Function TmxMap.GetProcedure( AIndex: Integer ): TmxProcedure;
Var
     _Procedure: TmxProcedure;
     _Index: Integer;
Begin
     Result := Nil;
     If AIndex > FProcedureCount - 1 Then Exit;

     _Index := 0;
     _Procedure := FProcedureRoot;

     While _Procedure <> Nil Do
     Begin
          If _Index = AIndex Then
          Begin
               Result := _Procedure;
               Break;
          End;

          Inc( _Index );
          _Procedure := _Procedure.Next;
     End;
End;

// *************************************************************************************
// ** TmxMap.GetLine, 9/10/01 10:22:19 AM
// *************************************************************************************

Function TmxMap.GetLine( AIndex: Integer ): TmxLine;
Var
     _Line: TmxLine;
     _Index: Integer;
Begin
     Result := Nil;
     If AIndex > FLineCount - 1 Then Exit;

     _Index := 0;
     _Line := FLineRoot;

     While _Line <> Nil Do
     Begin
          If _Index = AIndex Then
          Begin
               Result := _Line;
               Break;
          End;

          Inc( _Index );
          _Line := _Line.Next;
     End;
End;

// *************************************************************************************
// ** TmxMap.FindLine, 9/10/01 11:20:04 AM
// *************************************************************************************

Function TmxMap.FindLine( AAddress: Integer ): TmxLine;
Var
     _Line: TmxLine;
     _Valid: Boolean;
Begin
     Result := Nil;
     _Valid := FALSE;
     _Line := FLineRoot;

     While _Line <> Nil Do
     Begin
          If Result <> Nil Then
          Begin
               If _Line.Start > AAddress Then
               Begin
                    _Valid := TRUE;
                    Break;
               End;
          End;

          If _Line.Start <= AAddress Then Result := _Line;
          _Line := _Line.Next;
     End;

     If Not _Valid Then Result := Nil;
End;

// *************************************************************************************
// ** TmxMap.FindProcedure, 9/10/01 11:34:35 AM
// *************************************************************************************

Function TmxMap.FindProcedure( AAddress: Integer ): TmxProcedure;
Var
     _Procedure: TmxProcedure;
     _LastProcedure: TmxProcedure;
     _Valid: Boolean;
Begin
     Result := Nil;
     _Procedure := FProcedureRoot;
     _LastProcedure := Nil;
     _Valid := FALSE;

     While _Procedure <> Nil Do
     Begin
          If _Procedure.Start > AAddress Then
          Begin
               Result := _LastProcedure;
               _Valid := TRUE;
               Break;
          End;

          _LastProcedure := _Procedure;
          _Procedure := _Procedure.Next;
     End;

     If Not _Valid Then Result := _LastProcedure;
End;

// *************************************************************************************
// * TmxMap.GetMapInfo, 9/9/2002 5:27:17 PM
// *************************************************************************************

Function TmxMap.GetMapInfo( AMapPointer: Pointer ): TmxMapRecord;
Var
     _CalculatedAddress: Integer;
     _Line: TmxLine;
     _Procedure: TmxProcedure;
Begin
     pChar( AMapPointer ) := pChar( AMapPointer ) + 4;
     _CalculatedAddress := LongInt( AMapPointer^ ) - 5;

     _Line := FindLine( _CalculatedAddress );
     _Procedure := FindProcedure( _CalculatedAddress );

     If Assigned( _Procedure ) Then
          Result.ProcedureName := _Procedure.Name Else
          Result.ProcedureName := '';

     If Assigned( _Line ) Then
     Begin
          Result.UnitName := Units[ _Line.UnitIndex ].Name;
          Result.LineNumber := _Line.Line;
     End
     Else
     Begin
          Result.UnitName := '';
          Result.LineNumber := 0;
     End;
End;

{$ENDIF}
{$ENDIF}

// *************************************************************************************
// ** Initialization, 8/9/01 8:07:24 AM
// *************************************************************************************

Initialization

     _mxClient2Debugger := RegisterWindowMessage( 'mxClient2Debugger' );
     _mxDebugger2Client := RegisterWindowMessage( 'mxDebugger2Client' );

{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     mxMap := TmxMap.Create;
{$ENDIF}
{$ENDIF}

// *************************************************************************************
// * Finalization, 9/9/2002 5:27:29 PM
// *************************************************************************************

Finalization

{$IFDEF DEBUGGING}
{$IFDEF USEMAPFILE}
     mxMap.Free;
{$ENDIF}
{$ENDIF}

End.
