
(*
	----------------------------------------------

	  volLevelApp.pas
	  Voice Communicator components version 2.5
	  Audio Tools - PCM wave volume level application class

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 29 Mar 2002

	  modified by:
		Lake, Mar-Jun 2002
		Lake, Jun 2003
		Lake, Oct 2005
                Lake, Jun 2009

	----------------------------------------------
*)

{$I unaDef.inc }

unit
  volLevelApp;

interface

uses
  Windows, MMSystem,
  unaTypes, unaUtils, unaClasses, unaMsAcmClasses,
{$IFNDEF CONSOLE }
  unaWinClasses,
{$ENDIF CONSOLE }
  unavcApp;

type

  unaVolLevelApp = class(unaVCApplication)
  private
{$IFNDEF CONSOLE }
    f_display: unaWinWindow;
    f_dc: hDC;
    f_redPen: hPen;
    f_greenPen: hPen;
    f_h: unsigned;
    //
    procedure drawChannel(nChannels: unsigned; channel: unsigned);
    function volume2Pos(height, volume: unsigned): unsigned;
{$ENDIF CONSOLE }
  protected
    function init(): bool; override;
    procedure feedback(); override;
  public
    constructor create(const title, copy: string);
    destructor Destroy(); override;
  end;


implementation


{ unaVolLevelApp }

// --  --
constructor unaVolLevelApp.create(const title, copy: string);
begin
  inherited create(true, true, title, copy, 256);
{$IFDEF CONSOLE }
{$ELSE}
  f_display := unaWinWindow.create(nil, nil, '', app.wnd, WS_CHILD or WS_VISIBLE, 0, 0, 32, app.width, app.captionHeight - 32).show();
  //
  app.addChild(f_display);
  SetClassLong(f_display.wnd, GCL_HBRBACKGROUND, app.winClass.wndClassW.hbrBackground);
  //
  f_h := f_display.height - 5;
  f_dc := f_display.getDC();
  //
  f_redPen := CreatePen(PS_SOLID, 0, RGB(255, 0, 0));
  f_greenPen := CreatePen(PS_SOLID, 0, RGB(0, 200, 0));
{$ENDIF CONSOLE }
end;

// --  --
destructor unaVolLevelApp.destroy();
begin
{$IFNDEF CONSOLE }
  Windows.DeleteObject(f_redPen);
  Windows.DeleteObject(f_greenPen);
  f_display.releaseDC(f_dc);
{$ENDIF CONSOLE }
  //
  inherited;
end;

{$IFDEF CONSOLE }
{$ELSE}

// --  --
procedure unaVolLevelApp.drawChannel(nChannels, channel: unsigned);
var
  h: unsigned;
  top: unsigned;
  p: unsigned;
begin
  h := f_h div nChannels;
  top := h * channel;
  //
  SelectObject(f_dc, f_redPen);
  ScrollWindowEx(f_display.wnd, 1, 0, nil, nil, 0, nil, SW_SCROLLCHILDREN);
  //
  p := volume2Pos(h, device.getPrevVolume(channel));
  MoveToEx(f_dc, 6, top + h - p, nil);
  p := volume2Pos(h, device.getVolume(channel));
  LineTo(f_dc, 5, top + h - p);
  //
  SelectObject(f_dc, f_greenPen);
  p := volume2Pos(h, unaWaveInDevice(device).minVolumeLevel);
  MoveToEx(f_dc, 4, top + h - p, nil);
  LineTo(f_dc, 6, top + h - p);
end;

{$ENDIF CONSOLE }

// --  --
procedure unaVolLevelApp.feedback();
var
  s: string;
  i: unsigned;
begin
  inherited;
  //
  s := '';
  if (nil <> device) then begin
    //
    for i := 0 to nChannels - 1 do begin
      s := s + 'Channel #' + int2Str(i) + ': ' + int2Str(device.getVolume(i)) + '   ';
{$IFDEF CONSOLE }
{$ELSE}
      drawChannel(nChannels, i);
{$ENDIF CONSOLE }
    end;
  end;
  //
{$IFDEF CONSOLE }
  write(s + '        '#13);
{$ELSE}
  infoMessage(s + '        '#13);
{$ENDIF CONSOLE }
end;

// --  --
function unaVolLevelApp.init(): bool;
begin
  result := inherited init();
  if (result) then begin
    //
    device := unaWaveInDevice.create(deviceID, false, true);
    device.calcVolume := true;
    // add outstream
    device.assignStream(unaMemoryStream, false, true);
    device.overNumOut := 2;
    //
    assignFormat();
    assignVolumeParams();
    //
    if (mmNoError(device.open())) then
      device.close()
    else
      unaWaveDevice(device).direct := false;
  end;
end;

{$IFDEF CONSOLE }
{$ELSE}

// --  --
function unaVolLevelApp.volume2Pos(height, volume: unsigned): unsigned;
begin
  result := (height div 100 * percent(volume, $8000));
end;

{$ENDIF CONSOLE }

end.

