
(*
	----------------------------------------------

	  deviceEnum.dpr - wave device enumeration demo
	  Voice Communicator components version 2.5

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 13 Mar 2003

	  modified by:
		Lake, Mar 2002
		Lake, May 2002
		Lake, Feb 2003
		Lake, Jun 2003
		Lake, Oct 2005
                Lake, Jun 2009

	----------------------------------------------
*)

{$DEFINE NO_SU_AUTODEFINE }

{$DEFINE CONSOLE}
{$APPTYPE CONSOLE}

{$I unaDef.inc}


program
  deviceEnum;

{$R deviceEnum.RES }

uses
  Windows, Messages, unaTypes, unaUtils,
{$IFDEF VCX_DEMO}
  SysUtils,	// some functions are not exported from pre-compiled unaUtils.dcu
{$ENDIF}
  ShellApi, MMSystem, unaMsAcmAPI, unaMsAcmClasses;

// --  --
function writeFormat(value: unsigned; const formatName: string): string;
begin
  if (0 <> value) then
    result := '<dev_format>' + formatName + '</dev_format>'
  else
    result := '';
end;

// --  --
function writeStdFormats(value: unsigned): string;
begin
  //
  result := '<dev_supported_by_flag_formats>' +
	    writeFormat(WAVE_FORMAT_1M08 and value, '11.025 kHz, mono, 8-bit') +
	    writeFormat(WAVE_FORMAT_1M16 and value, '11.025 kHz, mono, 16-bit') +
	    writeFormat(WAVE_FORMAT_1S08 and value, '11.025 kHz, stereo, 8-bit') +
	    writeFormat(WAVE_FORMAT_1S16 and value, '11.025 kHz, stereo, 16-bit') +
	    //
	    writeFormat(WAVE_FORMAT_2M08 and value, '22.05 kHz, mono, 8-bit') +
	    writeFormat(WAVE_FORMAT_2M16 and value, '22.05 kHz, mono, 8-bit') +
	    writeFormat(WAVE_FORMAT_2S08 and value, '22.05 kHz, stereo, 8-bit') +
	    writeFormat(WAVE_FORMAT_2S16 and value, '22.05 kHz, stereo, 8-bit') +
	    //
	    writeFormat(WAVE_FORMAT_4M08 and value, '44.1 kHz, mono, 8-bit') +
	    writeFormat(WAVE_FORMAT_4M08 and value, '44.1 kHz, mono, 16-bit') +
	    writeFormat(WAVE_FORMAT_4S08 and value, '44.1 kHz, stereo, 8-bit') +
	    writeFormat(WAVE_FORMAT_4S08 and value, '44.1 kHz, stereo, 16-bit') +
	    '</dev_supported_by_flag_formats>';
end;

// --  --
function writeOtherFormat(isOut: bool; id, rate: unsigned; bits: byte; stereo: bool): string;
var
  W: WAVEFORMATEX;
  r: unsigned;
  hout: HWAVEOUT;
  hin: HWAVEIN;
begin
  W.wFormatTag := WAVE_FORMAT_PCM;
  W.nChannels := choice(stereo, unsigned(2), 1);
  W.nSamplesPerSec := rate;
  W.wBitsPerSample := bits;
  W.nBlockAlign := W.nChannels * (W.wBitsPerSample shr 3);
  W.nAvgBytesPerSec := W.nBlockAlign * W.nSamplesPerSec;
  W.cbSize := 0;

  if (isOut) then
    r := waveOutOpen(@hout, id, @W, 0, 0, WAVE_FORMAT_QUERY)
  else
    r := waveInOpen(@hin, id, @W, 0, 0, WAVE_FORMAT_QUERY);

  if (mmNoError(r)) then
    result := '<supported_format rate="' + int2str(rate) + '" bits="' + int2Str(bits) + '" stereo="' + choice(stereo, '1', '0') + '" />'
  else
    result := '';
end;

// --  --
function writeOtherFormats(isOut: bool; id: unsigned): string;
begin
  result := '<dev_supported_by_device_formats>' +
	    //
	    writeOtherFormat(isOut, id, 4000, 8, false) +
	    writeOtherFormat(isOut, id, 4000, 8, true) +
	    writeOtherFormat(isOut, id, 4000, 16, false) +
	    writeOtherFormat(isOut, id, 4000, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 8000, 8, false) +
	    writeOtherFormat(isOut, id, 8000, 8, true) +
	    writeOtherFormat(isOut, id, 8000, 16, false) +
	    writeOtherFormat(isOut, id, 8000, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 11025, 8, false) +
	    writeOtherFormat(isOut, id, 11025, 8, true) +
	    writeOtherFormat(isOut, id, 11025, 16, false) +
	    writeOtherFormat(isOut, id, 11025, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 12000, 8, false) +
	    writeOtherFormat(isOut, id, 12000, 8, true) +
	    writeOtherFormat(isOut, id, 12000, 16, false) +
	    writeOtherFormat(isOut, id, 12000, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 16000, 8, false) +
	    writeOtherFormat(isOut, id, 16000, 8, true) +
	    writeOtherFormat(isOut, id, 16000, 16, false) +
	    writeOtherFormat(isOut, id, 16000, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 22050, 8, false) +
	    writeOtherFormat(isOut, id, 22050, 8, true) +
	    writeOtherFormat(isOut, id, 22050, 16, false) +
	    writeOtherFormat(isOut, id, 22050, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 24000, 8, false) +
	    writeOtherFormat(isOut, id, 24000, 8, true) +
	    writeOtherFormat(isOut, id, 24000, 16, false) +
	    writeOtherFormat(isOut, id, 24000, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 32000, 8, false) +
	    writeOtherFormat(isOut, id, 32000, 8, true) +
	    writeOtherFormat(isOut, id, 32000, 16, false) +
	    writeOtherFormat(isOut, id, 32000, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 44100, 8, false) +
	    writeOtherFormat(isOut, id, 44100, 8, true) +
	    writeOtherFormat(isOut, id, 44100, 16, false) +
	    writeOtherFormat(isOut, id, 44100, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 48000, 8, false) +
	    writeOtherFormat(isOut, id, 48000, 8, true) +
	    writeOtherFormat(isOut, id, 48000, 16, false) +
	    writeOtherFormat(isOut, id, 48000, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 88200, 8, false) +
	    writeOtherFormat(isOut, id, 88200, 8, true) +
	    writeOtherFormat(isOut, id, 88200, 16, false) +
	    writeOtherFormat(isOut, id, 88200, 16, true) +
	    //
	    writeOtherFormat(isOut, id, 96000, 8, false) +
	    writeOtherFormat(isOut, id, 96000, 8, true) +
	    writeOtherFormat(isOut, id, 96000, 16, false) +
	    writeOtherFormat(isOut, id, 96000, 16, true) +
	    //
	    '</dev_supported_by_device_formats>';
end;

// --  --
procedure listDevices(wnd: HWND);
var
  i: int;
  inCaps: WAVEINCAPSW;
  outCaps: WAVEOUTCAPSW;
  output: string;
begin
  output := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
	    '<deviceEnum>' +
	    '<info>' +
		'<author>deviceEnum, version 2.5.4</author>' +
		'<copyright>Copyright (c) 2002-2009 Lake of Soft, Ltd</copyright>' +
		'<legal>Visit http://lakeofsoft.com/ for more information</legal>' +
	    '</info>' +
	    // input devices
	    '<input>';
  //
  for i := 0 to unaWaveInDevice.getDeviceCount() - 1 do
    if (unaWaveInDevice.getCaps(i, inCaps)) then begin
      //
      output := output + '<device id="' + int2Str(i) + '" mid="' + int2Str(inCaps.wMid) + '" pid="' + int2Str(inCaps.wPid) + '">' +
			   '<dev_version>' + int2Str(inCaps.vDriverVersion shr 8) + '.' + int2Str(inCaps.vDriverVersion and $0F) + '</dev_version>' +
			   '<dev_name>' + inCaps.szPname + '</dev_name>' +
			   writeStdFormats(inCaps.dwFormats) +
			   writeOtherFormats(false, i) +
			   '<dev_support_channels mono="' + choice(0 <> (inCaps.wChannels and 1), '1', '0') + '" stereo="' + choice(0 <> (inCaps.wChannels and 2), '1', '0') + '" />' +
			 '</device>';
    end;
  //
  output := output + '</input>' +
		     '<output>';
  //
  for i := 0 to unaWaveOutDevice.getDeviceCount() - 1 do
    if (unaWaveOutDevice.getCaps(i, outCaps)) then begin
      //
      output := output + '<device id="' + int2Str(i) + '" mid="' + int2Str(outCaps.wMid) + '" pid="' + int2Str(outCaps.wPid) + '">' +
			 '<dev_version>' + int2Str(outCaps.vDriverVersion shr 8) + '.' + int2Str(outCaps.vDriverVersion and $0F) + '</dev_version>' +
			 '<dev_name>' + outCaps.szPname + '</dev_name>' +
			 writeStdFormats(outCaps.dwFormats) +
			 writeOtherFormats(true, i) +
			 '<dev_support_channels mono="' + choice(0 <> (outCaps.wChannels and 1), '1', '0') + '" stereo="' + choice(0 <> (outCaps.wChannels and 2), '1', '0') + '" />' +
			 '<dev_support_features>' +
			 choice(0 <> (WAVECAPS_LRVOLUME and outCaps.dwSupport), '"separate left and right volume control" ', ' ') +
			 choice(0 <> (WAVECAPS_PITCH and outCaps.dwSupport), '"pitch control" ', ' ') +
			 choice(0 <> (WAVECAPS_PLAYBACKRATE and outCaps.dwSupport), '"playback rate control" ', ' ') +
			 choice(0 <> (WAVECAPS_SYNC and outCaps.dwSupport), '"driver is synchronous and will block while playing a buffer" ', ' ') +
			 choice(0 <> (WAVECAPS_VOLUME and outCaps.dwSupport), '"volume control" ', ' ') +
			 choice(0 <> (WAVECAPS_SAMPLEACCURATE and outCaps.dwSupport), '"returns sample-accurate position information" ', ' ') +
			 '</dev_support_features>' +
			 '</device>';
    end;
  //
  output := output + '</output>' +
		     '</deviceEnum>';
  //
  writeLn(output);
  setWindowText(wnd, pChar(output));
end;

var
  g_tmpFile: string = '';

// --  --
function myDialogProc(
  hwndDlg: HWND;  // handle to dialog box
  uMsg: UINT;     // message
  wParam: WPARAM; // first message parameter
  lParam: LPARAM  // second message parameter
  ): Windows.BOOL; stdcall;
var
  value: string;
begin
  result := false;

  case (uMsg) of

    WM_INITDIALOG: begin
      result := true;
    end;

    WM_COMMAND: begin
      case (LOWORD(wParam)) of

	IDOK: begin
	  if ('' <> g_tmpFile) then
	    fileDelete(g_tmpFile);
	  //
	  endDialog(hwndDlg, wParam);
	  result := true;
	end;

	IDCANCEL: begin
	  if ('' <> g_tmpFile) then
	    deleteFile(pChar(g_tmpFile));
	  //
	  endDialog(hwndDlg, wParam);
	  result := true;
	end;

	9002: begin	// List button
	  EnableWindow(GetDlgItem(hwndDlg, 9002), false);	// disable List button
	  try
	    listDevices(GetDlgItem(hwndDlg, 9001));
	  except
	    EnableWindow(GetDlgItem(hwndDlg, 9002), true);	// enable List button in case of exception
	  end;
	  //
	  EnableWindow(GetDlgItem(hwndDlg, 9003), true);	// enable Show button
	end;

	9003: begin	// Show button
	  if ('' <> g_tmpFile) then
	    fileDelete(g_tmpFile);
	  //
	  g_tmpFile := changeFileExt(getTemporaryFileName('de$'), '.xml');
	  setLength(value, 32768);
	  setLength(value, GetWindowText(GetDlgItem(hwndDlg, 9001), pChar(value), 32767));
	  writeToFile(g_tmpFile, aString(trimS(value)));
	  //
	  ShellExecuteA(0, 'open', paChar(aString(g_tmpFile)), nil, nil, SW_SHOWNORMAL);
	end;

      end;
    end;

  end;
end;

// -- main --

begin
  if (hasSwitch('nodlg')) then
    listDevices(0)
  else
    dialogBox(hinstance, MAKEINTRESOURCE(9000), 0, @myDialogProc);
end.

