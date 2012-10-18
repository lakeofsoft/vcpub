
(*
	----------------------------------------------

	  u_vcAECDemo_main.pas - AEC Demo main form
	  Voice Communicator components version 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2007-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 27 Sep 2007

	  modified by:
		Lake, Sep-Dec 2007
		Lake, Jan 2008

	----------------------------------------------
*)

{$I unaDef.inc }

unit
  u_vcAECDemo_main;

interface

uses
  Windows, unaTypes, unaClasses, unaVCDSComp,
  Forms, unaVCIDE, ExtCtrls, StdCtrls, Controls, CheckLst, Classes,
  ComCtrls, Menus, unaVC_socks, unaVC_pipe, unaVC_wave;

const
  //
  c_samplesPerSec	= 16000;
  c_bitsPerSample	= 16;
  c_numChannels		= 1;

type
  Tc_form_main = class(TForm)
    c_label_capInfo: TLabel;
    c_label_capSize: TLabel;
    c_timer_update: TTimer;
    c_label_renSize: TLabel;
    codecIn: TunavclWaveCodecDevice;
    codecOut: TunavclWaveCodecDevice;
    ipClient: TunavclIPOutStream;
    c_edit_host: TEdit;
    c_button_connect: TButton;
    c_edit_port: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    c_button_disconnect: TButton;
    c_clb_vc: TCheckListBox;
    c_checkBox_useAEC: TCheckBox;
    c_label_aecInfo: TLabel;
    Bevel1: TBevel;
    c_sb_main: TStatusBar;
    ds_FD: TunavclDX_FullDuplex;
    c_rb_udp: TRadioButton;
    c_rb_tcp: TRadioButton;
    c_button_listen: TButton;
    c_button_close: TButton;
    Label3: TLabel;
    Label4: TLabel;
    c_mm_main: TMainMenu;
    File1: TMenuItem;
    Quit1: TMenuItem;
    ipServer: TunavclIPInStream;
    Bevel2: TBevel;
    Help1: TMenuItem;
    OnlineHelp1: TMenuItem;
    About1: TMenuItem;
    //
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    procedure formShow(sender: tObject);
    procedure formCreate(sender: tObject);
    procedure formDestroy(sender: tObject);
    //
    procedure c_timer_updateTimer(sender: tObject);
    procedure c_button_connectClick(sender: tObject);
    procedure c_button_disconnectClick(sender: tObject);
    //
    procedure ipClientClientDisconnect(sender: tObject; connectionId: cardinal; connected: longBool);
    procedure ipClientClientConnect(sender: tObject; connectionId: cardinal; connected: longBool);
    //
    procedure Quit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure OnlineHelp1Click(Sender: TObject);
  private
    { Private declarations }
    f_config: unaIniFile;
    f_useAEC: bool;
  public
    { Public declarations }
  end;

var
  c_form_main: Tc_form_main;


implementation


{$R *.dfm}

uses
  unaUtils, unaVCDSIntf, 
  ComObj, ShellAPI;

{ TForm1 }

// --  --
procedure Tc_form_main.formShow(sender: tObject);
begin
  c_edit_host.text := f_config.get('ip.host', c_edit_host.text);
  c_edit_port.text := f_config.get('ip.port', c_edit_port.text);
  //
  c_rb_udp.checked := f_config.get('ip.proto.udp', true);
  c_rb_tcp.checked := not c_rb_udp.checked;
  c_checkBox_useAEC.checked := f_config.get('aec.enable', false);
  //
  c_timer_update.enabled := true;
end;

// --  --
procedure Tc_form_main.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  c_timer_update.enabled := false;
  //
  c_button_disconnectClick(self);
  //
  ipClient.close();
  codecIn.close();
  //
  f_config.setValue('ip.host', c_edit_host.text);
  f_config.setValue('ip.port', c_edit_port.text);
  f_config.setValue('ip.proto.udp', c_rb_udp.checked);
  f_config.setValue('aec.enable', c_checkBox_useAEC.checked);
end;

// --  --
procedure Tc_form_main.c_timer_updateTimer(sender: tObject);
var
  res: int;
  //
  aecStatus: DWORD;
  aecParams: DSCFXAec;
  //
  a: bool;
  s: string;
begin
  if (not (csDestroying in componentState)) then begin
    //
    // update GUI info
    c_sb_main.panels[0].text := 'Mem: ' + int2str(ams() shr 10, 10, 3) + ' KB';
    //
    //c_label_capInfo.caption := 'Captured buffers: ' + int2str(ds_FD.capBufCount);
    c_label_capSize.caption := 'Captured bytes: ' + int2str(ds_FD.outBytes[0], 10, 3);
    c_label_renSize.caption := 'Rendered bytes: ' + int2str(ds_FD.inBytes[0], 10, 3);
    //
    c_sb_main.panels[1].text := 'DS: 0x' + adjust(int2str(unsigned(ds_FD.dsRes), 16), 8, '0');
    //
    c_clb_vc.items[0] := 'codecIn - IN: ' + int2str(codecIn.inBytes[0], 10, 3) + ' / OUT: ' + int2str(codecIn.outBytes[0], 10, 3);
    c_clb_vc.items[1] := 'ipClient - IN: ' + int2str(ipClient.inBytes[1], 10, 3) + ' / OUT: ' + int2str(ipClient.outBytes[1], 10, 3);
    c_clb_vc.items[2] := 'codecOut - IN: ' + int2str(codecOut.inBytes[0], 10, 3) + ' / OUT: ' + int2str(codecOut.outBytes[0], 10, 3);
    //
    c_clb_vc.checked[0] := codecIn.active;
    c_clb_vc.checked[1] := ipClient.active;
    c_clb_vc.checked[2] := codecOut.active;
    //
    a := ipClient.active;
    c_checkBox_useAEC.enabled := not a;
    c_button_connect.enabled := not a;
    c_button_disconnect.enabled := a;
    //
    c_edit_host.enabled := not a;
    c_edit_port.enabled := not a;
    c_rb_udp.enabled := not a;
    c_rb_tcp.enabled := not a;
    //
    if (c_checkBox_useAEC.checked and ds_FD.active) then begin
      //
      res := ds_FD.getAECParams(aecParams);
      if (Succeeded(res)) then begin
	//
	s := s + #13#10'PARAMS: ';
	//
	s := s + 'AEC Effect is ' + choice(aecParams.fEnable, 'enabled', 'disabled');
	s := s + ';  Noise Fill is ' + choice(aecParams.fNoiseFill, 'enabled', 'disabled');
	//
	s := s + ';  Op.Mode is ';
	case (aecParams.dwMode) of
	  //
	  DSCFX_AEC_MODE_PASS_THROUGH:
	    s := s + 'PASS_THROUGH';

	  DSCFX_AEC_MODE_HALF_DUPLEX:
	    s := s + 'HALF_DUPLEX';

	  DSCFX_AEC_MODE_FULL_DUPLEX:
	    s := s + 'FULL_DUPLEX';

	  else
	    s := s + 'Unknown';
	end;
	//
      end
      else
	s := s + #13#10'Cannot get AEC parameters, error code=0x' + adjust(int2str(unsigned(res), 16), 8, ' ');
      //
      s := s + #13#10;
      //
      res := ds_FD.getAECStatus(aecStatus);      
      if (Succeeded(res)) then begin
	//
	s := s + #13#10'STATUS: ';
	//
	if (DSCFX_AEC_STATUS_HISTORY_UNINITIALIZED = aecStatus) then
	  s := s + 'UNINITIALIZED, ';
	//
	if (0 <> (aecStatus and DSCFX_AEC_STATUS_HISTORY_CONTINUOUSLY_CONVERGED)) then
	  s := s + 'CONTINUOUSLY_CONVERGED, ';
	if (0 <> (aecStatus and DSCFX_AEC_STATUS_HISTORY_PREVIOUSLY_DIVERGED)) then
	  s := s + 'PREVIOUSLY_DIVERGED, ';
	if (0 <> (aecStatus and DSCFX_AEC_STATUS_CURRENTLY_CONVERGED)) then
	  s := s + 'CURRENTLY_CONVERGED, ';
	//
	s := s + ' OK';
      end
      else
	s := s + #13#10'Cannot get AEC status, error code=0x' + adjust(int2str(unsigned(res), 16), 8, ' ');
      //
      c_label_aecInfo.caption := s;
    end
    else
      c_label_aecInfo.caption := 'AEC status: disabled';
    //
  end;    
end;

// --  --
procedure Tc_form_main.c_button_connectClick(sender: tObject);
begin
  codecIn.close();
  //
  ipClient.host := c_edit_host.text;
  ipClient.port := c_edit_port.text;
  if (c_rb_udp.checked) then
    ipClient.proto := unapt_UDP
  else
    ipClient.proto := unapt_TCP;
  //
  f_useAEC := c_checkBox_useAEC.checked;  
  //
  codecIn.pcm_samplesPerSec := c_samplesPerSec;
  codecIn.pcm_bitsPerSample := c_bitsPerSample;
  codecIn.pcm_numChannels := c_numChannels;
  //
  c_checkBox_useAEC.enabled := false;
  c_button_connect.enabled := false;
  c_button_disconnect.enabled := true;
  //
  c_edit_host.enabled := false;
  c_edit_port.enabled := false;
  c_rb_udp.enabled := false;
  c_rb_tcp.enabled := false;
  //
  ipClient.open();
end;

// --  --
procedure Tc_form_main.c_button_disconnectClick(sender: tObject);
begin
  codecIn.close();
  ds_FD.close();
  ipClient.close();
  //
  c_checkBox_useAEC.enabled := true;
  c_button_connect.enabled := true;
  c_button_disconnect.enabled := false;
  //
  c_edit_host.enabled := true;
  c_edit_port.enabled := true;
  c_rb_udp.enabled := true;
  c_rb_tcp.enabled := true;
end;

// --  --
procedure Tc_form_main.ipClientClientDisconnect(sender: tObject; connectionId: cardinal; connected: longBool);
begin
  if (not (csDestroying in componentState)) then begin
    //
    ds_FD.close();
    codecIn.close();	
  end;
end;

// --  --
procedure Tc_form_main.formCreate(sender: tObject);
begin
  f_config := unaIniFile.create();
  //
  ds_FD.pcm_samplesPerSec := c_samplesPerSec;
  ds_FD.pcm_bitsPerSample := c_bitsPerSample;
  ds_FD.pcm_numChannels := c_numChannels;
end;

// --  --
procedure Tc_form_main.formDestroy(sender: tObject);
begin
  freeAndNil(f_config);
end;

// --  --
procedure Tc_form_main.ipClientClientConnect(sender: tObject; connectionId: cardinal; connected: longBool);
begin
  // start DS
  ds_FD.enableAEC := f_useAEC;
  ds_FD.open();
  //
  //codecIn.open();	// start codec
end;

// --  --
procedure Tc_form_main.Quit1Click(Sender: TObject);
begin
  close();
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  guiMessageBox('VC 2.5'#13#10'AEC sample'#13#10#13#10'Copyright (c) 2005-2010 Lake of Soft', 'About AEC sample', MB_OK, handle);
end;

// --  --
procedure Tc_form_main.OnlineHelp1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://lakeofsoft.com/vc/a_acousticechocancellation_AEC.html', nil, nil, SW_SHOWNORMAL);
end;


end.

