
(*
	----------------------------------------------

	  unaApp.pas
	  Common application class

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 29 Mar 2002

	  modified by:
		Lake, Mar-Dec 2002
		Lake, Jan-Dec 2003
		Lake, Mar 2004

	----------------------------------------------
*)

{$I unaDef.inc}

unit
  unaApp;

interface

uses
  Windows,
  unaTypes, unaUtils, unaClasses
{$IFDEF CONSOLE }
{$ELSE}
  , unaWinClasses
{$ENDIF CONSOLE }
  ;

type

  myConsoleApp = class;

  //
  // -- unaApplication --
  //

  unaApplication = class(unaObject)
  private
    f_ini: unaIniFile;
    f_title: string;
    f_copy: string;
    f_url: aString;
    f_urlOfs: int;
    f_startBtn: bool;
    f_stopBtn: bool;
    //
{$IFDEF CONSOLE }
    f_enterStop: bool;
{$ELSE }
    f_splash: unaWinSplashWindow;
{$ENDIF CONSOLE }
    f_app: myConsoleApp;
  protected
    function init(): bool; virtual;
    function start(): bool; virtual;
    function stop(): bool; virtual;
    procedure doRun(); virtual;
    //
    function okToUpdate(): bool; virtual;
    procedure feedback(); virtual;
    function onCommand(cmd: int): bool; virtual;
  public
    constructor create(hasGUI: bool; const title, copy: string; startBtn: bool = true; stopBtn: bool = true; height: unsigned = 32; const url: aString = 'http://lakeofsoft.com/'; urlOfs: int = 0);
    destructor Destroy(); override;
    procedure run();
    procedure doStart();
    procedure doStop();
    //
    property app: myConsoleApp read f_app;
    property ini: unaIniFile read f_ini;
{$IFDEF CONSOLE }
    property enterStop: bool read f_enterStop write f_enterStop;
{$ELSE }
    property splash: unaWinSplashWindow read f_splash;
{$ENDIF CONSOLE }
  end;

{$IFDEF CONSOLE }

  // too bad Object Pascal does not supports multiple inheritance
  myConsoleApp = class(unaConsoleApp)
  private
    f_master: unaApplication;
  protected
    function doInit(): bool; override;
    function execute(globalIndex: unsigned): int; override;
    procedure startIn(); override;
    procedure startOut(); override;
    //
    procedure onStart();
    procedure onStop();
  public
    constructor create(master: unaApplication; const title, copy: string; height: unsigned);
  end;

{$ELSE }

  // too bad Object Pascal does not supports multiple inheritance
  myConsoleApp = class(unaWinConsoleApp)
  private
    f_master: unaApplication;
    f_urlButton: unaWinButton;
  protected
    function doInit(): bool; override;
    procedure onStart(); override;
    procedure onStop(); override;
    function onCommand(cmd, wnd: int): bool; override;
    procedure idle(); override;
  public
    constructor create(hasGUI: bool; master: unaApplication; const title, copy: string; height: unsigned);
    //
    property urlButton: unaWinButton read f_urlButton;
  end;

{$ENDIF CONSOLE }


implementation


uses
  ShellApi
{$IFDEF __SYSUTILS_H_ }
  , SysUtils
{$ENDIF __SYSUTILS_H_ }
  ;

{ unaApplication }

// --  --
constructor unaApplication.create(hasGUI: bool; const title, copy: string; startBtn, stopBtn: bool; height: unsigned; const url: aString; urlOfs: int);
begin
  inherited create();
  //
  f_title := title;
  f_copy := copy;
  f_url := url;
  f_ini := unaIniFile.create();
  //
  f_startBtn := startBtn;
  f_stopBtn := stopBtn;
  f_urlOfs := urlOfs;
{$IFDEF CONSOLE}
  enterStop := true;
{$ENDIF CONSOLE }
  //
  myConsoleApp.create({$IFDEF CONSOLE}{$ELSE}hasGUI, {$ENDIF}self, title, copy, height);
end;

// --  --
destructor unaApplication.destroy();
begin
  inherited;
  //
  ini.free();
  f_app.free();
end;

// --  --
procedure unaApplication.doRun();
begin
{$IFDEF CONSOLE }
  f_app.run(f_enterStop);
{$ELSE }
  f_app.run();
{$ENDIF CONSOLE }
end;

// --  --
procedure unaApplication.doStart();
begin
  f_app.onStart();
end;

procedure unaApplication.doStop();
begin
  f_app.onStop();
end;

procedure unaApplication.feedback();
begin
  // nothing here
end;

// --  --
function unaApplication.init(): bool;
begin
  logMessage(' '#13#10 + f_title + ' ' + f_copy + #13#10' ', c_logModeFlags_normal);
  result := true;
end;

// --  --
function unaApplication.okToUpdate(): bool;
begin
  result := true;
end;

// --  --
function unaApplication.onCommand(cmd: int): bool;
begin
  case (cmd and $FFFF) of

    10: begin
      //
{$IFNDEF NO_ANSI_SUPPORT }
      if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
	ShellExecuteW(0, 'open', pwChar(wString(f_url)), nil, nil, SW_SHOWNORMAL)
{$IFNDEF NO_ANSI_SUPPORT }
      else
        ShellExecuteA(0, 'open', paChar(f_url), nil, nil, SW_SHOWNORMAL);
{$ENDIF NO_ANSI_SUPPORT }
      ;
    end;

  end;
  result := false;
end;

// --  --
procedure unaApplication.run();
begin
  doRun();
end;

// --  --
function unaApplication.start(): bool;
begin
  result := true;
end;

// --  --
function unaApplication.stop(): bool;
begin
  result := true;
end;


{$IFDEF CONSOLE }

{ myConsoleApp }

// --  --
constructor myConsoleApp.create(master: unaApplication; const title, copy: string; height: unsigned);
begin
  f_master := master;
  f_master.f_app := self;
  //
  inherited create(title + copy, LoadIcon(GetModuleHandle(nil), 'MAINICON'));
end;

// --  --
function myConsoleApp.doInit(): bool;
begin
  result := f_master.init();
end;

// --  --
function myConsoleApp.execute(globalIndex: unsigned): int;
begin
  //
  while (not shouldStop) do begin
    //
    if (f_master.okToUpdate()) then
      f_master.feedback();
    //
    sleepThread(50);
  end;
  //
  f_executeComplete := true;
  result := 0;
end;

// --  --
procedure myConsoleApp.onStart();
begin
  start();
end;

// --  --
procedure myConsoleApp.onStop();
begin
  stop();
end;

// --  --
procedure myConsoleApp.startIn();
begin
  inherited;
  //
  f_master.start();
end;

// --  --
procedure myConsoleApp.startOut();
begin
  inherited;
  //
  f_master.stop();
end;

{$ELSE }

{ myConsoleApp }

// --  --
constructor myConsoleApp.create(hasGUI: bool; master: unaApplication; const title, copy: string; height: unsigned);
begin
  f_master := master;
  f_master.f_app := self;
  //
  inherited create(hasGUI, title, copy, '', Windows.LoadIcon(Windows.GetModuleHandle(nil), 'MAINICON'), height, true, f_master.f_startBtn, f_master.f_stopBtn);
  //
  if (hasGUI) then
    if (nil <> urlButton) then
      urlButton.left := urlButton.left + f_master.f_urlOfs;
end;

// --  --
function myConsoleApp.doInit(): bool;
begin
  minWidth := 560;
  minHeight := captionHeight + 128;
  //
  if (hasGUI) then begin
    //
    f_master.f_splash := unaWinSplashWindow.create('Loading, please wait...', self, 250, 100);
    f_master.f_splash.show(SW_SHOW);
    //
    if ('' <> trimS(f_master.f_url)) then
      f_urlButton := unaWinButton.create(wString(f_master.f_url), self, 10, 404, 2, 150);
  end;
  //
  result := f_master.init();
  //
  if (hasGUI) then begin
    //
    f_master.f_splash.show(SW_HIDE);
    if (result) then
      show().redraw();
  end;
end;

// --  --
procedure myConsoleApp.idle();
begin
  inherited;
  //
  if (f_master.okToUpdate()) then
    f_master.feedback();
end;

// --  --
function myConsoleApp.onCommand(cmd, wnd: int): bool;
begin
  result := f_master.onCommand(cmd);
  //
  if (not result) then
    result := inherited onCommand(cmd, wnd);
end;

// --  --
procedure myConsoleApp.onStart();
begin
  inherited;
  //
  f_master.start();
end;

// --  --
procedure myConsoleApp.onStop();
begin
  inherited;
  //
  f_master.stop();
end;

{$ENDIF CONSOLE }


end.

