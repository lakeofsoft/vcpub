
(*
	----------------------------------------------

	  u_sr_mainpas.pas - VC 2.5 Pro RAW Streaming demo main form
	  Voice Communicator components version 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2006-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, Nov 2006

	  modified by:
		Lake, Apr 2007
                Lake, May 2009

	----------------------------------------------
*)

{$I unaDef.inc }

unit
  u_sr_mainpas;

interface

uses
  Windows, unaTypes, unaClasses,
  Forms, Controls, StdCtrls, ExtCtrls, unaVCIDE, Classes, ComCtrls, Menus,
  unaVC_wave, unaVC_socks, unaVC_pipe;

type
  Tc_form_main = class(TForm)
    waveIn: TunavclWaveInDevice;
    codecIn: TunavclWaveCodecDevice;
    ipClient: TunavclIPOutStream;
    ipServer: TunavclIPInStream;
    codecOut: TunavclWaveCodecDevice;
    waveOut: TunavclWaveOutDevice;
    //
    c_button_start: TButton;
    c_button_stop: TButton;
    //
    c_lb_main: TListBox;
    c_sb_main: TStatusBar;
    c_timer_up: TTimer;
    c_edit_host: TEdit;
    c_edit_port: TEdit;
    //
    c_cb_st: TComboBox;
    c_cb_sc: TCheckBox;
    c_cb_ss: TCheckBox;
    c_cb_waveIn: TComboBox;
    c_cb_rate: TComboBox;
    c_cb_codec: TComboBox;
    c_cb_waveOut: TComboBox;
    //
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    c_cb_mono: TCheckBox;
    c_mm_main: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Label8: TLabel;
    c_edit_bind: TEdit;
    Help1: TMenuItem;
    About1: TMenuItem;
    //
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    procedure formCreate(sender: tObject);
    //
    procedure c_button_startClick(sender: tObject);
    procedure c_button_stopClick(sender: tObject);
    procedure c_timer_upTimer(sender: tObject);
    procedure FormShow(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    f_config: unaIniFile;
  public
    { Public declarations }
  end;

var
  c_form_main: Tc_form_main;


implementation


{$R *.dfm}

uses
  unaUtils, unaVclUtils, unavcIdeUtils,
  ShellAPI;


 { Tc_form_main }

// --  --
procedure Tc_form_main.formCreate(sender: tObject);
begin
  f_config := unaIniFile.create();
  //
  c_edit_host.text := f_config.get('host', '127.0.0.1');
  c_edit_port.text := f_config.get('port', '17800');
  c_cb_st.itemIndex := f_config.get('st', int(0));
  //
  c_cb_sc.checked := f_config.get('start.client', true);
  c_cb_ss.checked := f_config.get('start.server', true);
  //
  enumWaveDevices(c_cb_waveIn, true, false);
  c_cb_waveIn.itemIndex := f_config.get('waveIn.index', int(0));
  //
  enumWaveDevices(c_cb_waveOut, false, false);
  c_cb_waveOut.itemIndex := f_config.get('waveOut.index', int(0));
  //
  c_cb_rate.text := f_config.get('waveIn.rate', '8000');
  c_cb_codec.text := f_config.get('waveIn.codec', c_cb_codec.items[0]);
  c_cb_mono.checked := f_config.get('waveIn.mono', true);
  //
  c_timer_up.enabled := true;
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  ShellExecute(handle, 'open', 'http://lakeofsoft.com/vc/a_rawstreaming.html', nil, nil, SW_SHOWNORMAL);
end;

// --  --
procedure Tc_form_main.c_button_startClick(sender: tObject);
begin
  ipClient.close();	// just in case
  ipServer.close();
  //
  // -- setup IP components --
  ipClient.host := c_edit_host.text;
  ipClient.port := c_edit_port.text;
  ipClient.bindToPort := c_edit_bind.text;
  if (0 = c_cb_st.itemIndex) then begin
    //
    ipClient.proto := unapt_UDP;
    ipServer.proto := unapt_UDP;
  end
  else begin
    //
    ipClient.proto := unapt_TCP;
    ipServer.proto := unapt_TCP;
  end;
  //
  ipServer.port := c_edit_port.text;
  //
  // -- start checked components --
  //
  if (c_cb_ss.checked) then begin
    //
    waveOut.deviceId := index2deviceId(c_cb_waveOut);
    //
    codecOut.pcm_samplesPerSec := str2intInt(c_cb_rate.text);
    codecOut.pcm_numChannels := choice(c_cb_mono.checked, 1, int(2));
    codecOut.formatTag := str2intInt(c_cb_codec.text, 1, 10, true);
    //
    ipServer.open();
    //
    sleep(500);	// give server a chance to start up
  end;
  //
  if (c_cb_sc.checked) then begin
    //
    waveIn.close();	// just in case
    //
    waveIn.deviceId := index2deviceId(c_cb_waveIn);
    waveIn.pcm_samplesPerSec := str2intInt(c_cb_rate.text);
    waveIn.pcm_numChannels := choice(c_cb_mono.checked, 1, int(2));
    //
    codecIn.formatTag := str2intInt(c_cb_codec.text, 1, 10, true);
    //
    waveIn.open();
  end;
end;

// --  --
procedure Tc_form_main.c_button_stopClick(sender: tObject);
begin
  waveIn.close();
  ipServer.close();
end;

// --  --
procedure Tc_form_main.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  c_button_stopClick(sender);
  //
  f_config.setValue('host', c_edit_host.text);
  f_config.setValue('port', c_edit_port.text);
  f_config.setValue('st', c_cb_st.itemIndex);
  //
  f_config.setValue('start.client', c_cb_sc.checked);
  f_config.setValue('start.server', c_cb_ss.checked);
  //
  f_config.setValue('waveIn.index', c_cb_waveIn.itemIndex);
  f_config.setValue('waveIn.rate', c_cb_rate.text);
  f_config.setValue('waveIn.codec', c_cb_codec.text);
  f_config.setValue('waveIn.mono', c_cb_mono.checked);
  //
  f_config.setValue('waveOut.index', c_cb_waveOut.itemIndex);
  //
  c_timer_up.enabled := false;
  //
  saveControlPosition(self, f_config);
  //
  freeAndNil(f_config);
end;

// --  --
procedure Tc_form_main.c_timer_upTimer(sender: tObject);
begin
  if (not (csDestroying in componentState)) then begin
    //
    c_sb_main.panels[0].text := 'Mem: ' + int2str(ams() shr 10, 10, 3) + ' KB';
    //
    c_lb_main.items[0] := 'waveIn:   ' + choice(waveIn.active,   'A', 'x') + ' ' + int2str(waveIn.inBytes)   + ' / ' + int2str(waveIn.outBytes);
    c_lb_main.items[1] := 'codecIn:  ' + choice(codecIn.active,  'A', 'x') + ' ' + int2str(codecIn.inBytes)  + ' / ' + int2str(codecIn.outBytes);
    c_lb_main.items[2] := 'ipClient: ' + choice(ipClient.active, 'A', 'x') + ' ' + int2str(ipClient.inBytes) + ' / ' + int2str(ipClient.outBytes);
    //
    c_lb_main.items[4] := 'ipServer: ' + choice(ipServer.active, 'A', 'x') + ' ' + int2str(ipServer.inBytes) + ' / ' + int2str(ipServer.outBytes) + ' / '  + int2str(ipServer.clientCount);
    c_lb_main.items[5] := 'codecOut: ' + choice(codecOut.active, 'A', 'x') + ' ' + int2str(codecOut.inBytes) + ' / ' + int2str(codecOut.outBytes);
    c_lb_main.items[6] := 'waveOut:  ' + choice(waveOut.active,  'A', 'x') + ' ' + int2str(waveOut.inBytes)  + ' / ' + int2str(waveOut.outBytes);
  end;
end;

// --  --
procedure Tc_form_main.FormShow(Sender: TObject);
begin
  loadControlPosition(self, f_config);
end;

// --  --
procedure Tc_form_main.Exit1Click(Sender: TObject);
begin
  close();
end;


end.

