
(*
	----------------------------------------------

	  u_surround_main.pas - VC 2.5 Pro Surround demo
	  Voice Communicator components version 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2008-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, Jan 2008

	  modified by:
		Lake, Jan-Feb 2008

	----------------------------------------------
*)

{$I unaDef.inc }

unit
  u_surround_main;

interface

uses
  Windows, unaTypes, unaClasses, unaMsAcmAPI,
  Forms, unaVCIDE, StdCtrls, Classes, Controls, Menus, ComCtrls, ExtCtrls,
  ActnList, unaVC_pipe, unaVC_wave;


type
  // --  --
  unaSpeakerNameMask = packed record
    r_name: string;
    r_mask: DWORD;
    r_cb: tCheckBox;
  end;

const
  //
  cuna_max_channels = 18;

var
  //
  v_speaker_name_mask_cb: array[0..cuna_max_channels - 1] of unaSpeakerNameMask =
    (
      (r_name: 'Front Left'; 		r_mask: SPEAKER_FRONT_LEFT),
      (r_name: 'Front Right';	        r_mask: SPEAKER_FRONT_RIGHT),
      (r_name: 'Front Center';	   	r_mask: SPEAKER_FRONT_CENTER),
      (r_name: 'Low Frequency';	 	r_mask: SPEAKER_LOW_FREQUENCY ),
      (r_name: 'Back Left';		r_mask: SPEAKER_BACK_LEFT),
      (r_name: 'Back Right';	    	r_mask: SPEAKER_BACK_RIGHT),
      (r_name: 'Front Left of Center';  r_mask: SPEAKER_FRONT_LEFT_OF_CENTER),
      (r_name: 'Front Right of Center'; r_mask: SPEAKER_FRONT_RIGHT_OF_CENTER),
      (r_name: 'Back Center';	    	r_mask: SPEAKER_BACK_CENTER),
      (r_name: 'Side Left';		r_mask: SPEAKER_SIDE_LEFT),
      (r_name: 'Side Right';	    	r_mask: SPEAKER_SIDE_RIGHT),
      (r_name: 'Top Center';	    	r_mask: SPEAKER_TOP_CENTER),
      (r_name: 'Top Front Left';	r_mask: SPEAKER_TOP_FRONT_LEFT),
      (r_name: 'Top Front Center';	r_mask: SPEAKER_TOP_FRONT_CENTER),
      (r_name: 'Top Front Right';	r_mask: SPEAKER_TOP_FRONT_RIGHT),
      (r_name: 'Top Back Left';	 	r_mask: SPEAKER_TOP_BACK_LEFT),
      (r_name: 'Top Back Center';	r_mask: SPEAKER_TOP_BACK_CENTER),
      (r_name: 'Top Back Right';	r_mask: SPEAKER_TOP_BACK_RIGHT)
    );

type
  Tc_form_main = class(TForm)
    waveOut: TunavclWaveOutDevice;
    c_button_srcManage: TButton;
    c_mm_main: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    c_cb_rate: TComboBox;
    Label1: TLabel;
    c_cb_surround: TComboBox;
    Label2: TLabel;
    c_button_open: TButton;
    c_button_close: TButton;
    c_panel_layout: TPanel;
    //
    scb_FL: TCheckBox;
    scb_LF: TCheckBox;
    scb_SL: TCheckBox;
    scb_FLC: TCheckBox;
    scb_FC: TCheckBox;
    scb_SR: TCheckBox;
    scb_FRC: TCheckBox;
    scb_FR: TCheckBox;
    scb_BL: TCheckBox;
    scb_BC: TCheckBox;
    scb_BR: TCheckBox;
    scb_TFL: TCheckBox;
    scb_TC: TCheckBox;
    scb_TFC: TCheckBox;
    scb_TFR: TCheckBox;
    scb_TBL: TCheckBox;
    scb_TBC: TCheckBox;
    scb_TBR: TCheckBox;
    c_sb_main: TStatusBar;
    Bevel1: TBevel;
    c_al_main: TActionList;
    a_src_manage: TAction;
    c_timer_main: TTimer;
    a_wave_open: TAction;
    a_wave_close: TAction;
    c_label_ch: TLabel;
    c_tv_map: TTreeView;
    c_rb_rootSpeakers: TRadioButton;
    c_rb_rootSources: TRadioButton;
    Label3: TLabel;
    c_cb_autoExpand: TCheckBox;
    Sources1: TMenuItem;
    ManageSourcesandmapping1: TMenuItem;
    Wave1: TMenuItem;
    Close1: TMenuItem;
    Close2: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    c_label_mixed: TLabel;
    //
    procedure formCreate(sender: tObject);
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    procedure formShow(sender: tObject);
    procedure formDestroy(sender: tObject);
    procedure exit1Click(sender: tObject);
    //
    procedure a_src_manageExecute(sender: tObject);
    procedure a_wave_openExecute(Sender: TObject);
    procedure a_wave_closeExecute(Sender: TObject);
    //
    procedure waveOutFeedDone(sender: unavclInOutPipe; data: Pointer; len: Cardinal);
    //
    procedure c_cb_surroundChange(Sender: TObject);
    procedure c_cb_rateChange(Sender: TObject);
    procedure c_cb_autoExpandClick(Sender: TObject);
    procedure scb_changed(Sender: TObject);
    procedure c_rb_rootViewClick(Sender: TObject);
    //
    procedure c_timer_mainTimer(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    f_config: unaIniFile;
    f_configuring: bool;
    f_customMask: DWORD;
    //
    f_totalMixed: int64;
    f_doneFeeding: bool;
    //
    f_channelMap: array[0..cuna_max_channels - 1] of int;
    //
    procedure mask2GUI(mask: DWORD);
    function GUI2mask(): DWORD;
    procedure createChannelMapArray();
    //
    procedure updateConfig();
    procedure rebuildMapView();
    procedure setDefaultConfig(index: int);
    procedure samplingParamsChanged(rateChanged: bool);
  public
    { Public declarations }
    function mappedTo(mask: DWORD; index: int): bool;
  end;

var
  c_form_main: Tc_form_main;


implementation


{$R *.dfm}

uses
  unaUtils, unaMsAcmClasses,
  unaVCLUtils, shellAPI,
  u_surround_sourceSel;


{ Tc_form_main }

// --  --
procedure Tc_form_main.formCreate(sender: tObject);
begin
  f_config := unaIniFile.create();
  //
  v_speaker_name_mask_cb[00].r_cb := scb_FL;
  v_speaker_name_mask_cb[01].r_cb := scb_FR;
  v_speaker_name_mask_cb[02].r_cb := scb_FC;
  v_speaker_name_mask_cb[03].r_cb := scb_LF;
  v_speaker_name_mask_cb[04].r_cb := scb_BL;
  v_speaker_name_mask_cb[05].r_cb := scb_BR;
  v_speaker_name_mask_cb[06].r_cb := scb_FLC;
  v_speaker_name_mask_cb[07].r_cb := scb_FRC;
  v_speaker_name_mask_cb[08].r_cb := scb_BC;
  v_speaker_name_mask_cb[09].r_cb := scb_SL;
  v_speaker_name_mask_cb[10].r_cb := scb_SR;
  v_speaker_name_mask_cb[11].r_cb := scb_TC;
  v_speaker_name_mask_cb[12].r_cb := scb_TFL;
  v_speaker_name_mask_cb[13].r_cb := scb_TFC;
  v_speaker_name_mask_cb[14].r_cb := scb_TFR;
  v_speaker_name_mask_cb[15].r_cb := scb_TBL;
  v_speaker_name_mask_cb[16].r_cb := scb_TBC;
  v_speaker_name_mask_cb[17].r_cb := scb_TBR;
end;

// --  --
procedure Tc_form_main.formShow(sender: tObject);
var
  cfg: int;
  i, cs: int;
  stype: int;
  param: string;
  mask: DWORD;
begin
  loadControlPosition(self, f_config);
  c_timer_main.enabled := true;
  //
  cfg := f_config.get('wave.config.index', int(1));					// stereo by default
  f_customMask := f_config.get('wave.config.mask', DWORD(KSAUDIO_SPEAKER_STEREO));	// stereo by default
  //
  f_configuring := true;
  try
    setDefaultConfig(cfg);
  finally
    f_configuring := false;
  end;
  //
  c_cb_rate.text := int2str(f_config.get('wave.samplingRate', int(44100)));
  c_cb_rateChange(self);
  //
  c_form_sourceManage.c_edit_waveFile.text := f_config.get('riff.file', 'test.wav');
  c_tv_map.autoExpand := f_config.get('gui.autoExpand', true);
  c_cb_autoExpand.checked := c_tv_map.autoExpand;
  //
  c_rb_rootSpeakers.checked := f_config.get('gui.viewFromSpeakers', true);
  c_rb_rootSources.checked := not c_rb_rootSpeakers.checked;
  //
  cs := f_config.get('source.count', int(0));
  for i := 0 to cs - 1 do begin
    //
    stype := f_config.get('source.' + int2str(i) + '.stype', int(cuna_stype_live));
    param := f_config.get('source.' + int2str(i) + '.param', '');
    mask  := f_config.get('source.' + int2str(i) + '.mask',  DWORD(0));
    //
    c_form_sourceManage.addSource(stype, param, mask);
  end;
  //
  rebuildMapView();
  c_form_sourceManage.updatePresence();
end;

// --  --
procedure Tc_form_main.formCloseQuery(sender: tObject; var canClose: boolean);
var
  i: int;
begin
  c_timer_main.enabled := false;
  a_wave_close.execute();
  //
  f_config.setValue('wave.config.index', c_cb_surround.itemIndex);	//
  f_config.setValue('wave.config.mask', f_customMask);	//
  f_config.setValue('wave.samplingRate', waveOut.pcm_samplesPerSec);	//
  //
  f_config.setValue('riff.file', c_form_sourceManage.c_edit_waveFile.text);	//
  f_config.setValue('gui.autoExpand', c_tv_map.autoExpand);
  f_config.setValue('gui.viewFromSpeakers', c_rb_rootSpeakers.checked);
  //
  f_config.setValue('source.count', c_form_sourceManage.sourceCount);
  for i := 0 to c_form_sourceManage.sourceCount - 1 do begin
    //
    f_config.setValue('source.' + int2str(i) + '.stype', c_form_sourceManage.source[i].stype);
    f_config.setValue('source.' + int2str(i) + '.param', c_form_sourceManage.source[i].param);
    f_config.setValue('source.' + int2str(i) + '.mask',  c_form_sourceManage.source[i].mapping);
  end;
  //
  saveControlPosition(self, f_config);
end;

// --  --
procedure Tc_form_main.exit1Click(sender: tObject);
begin
  close();
end;

// --  --
procedure Tc_form_main.formDestroy(sender: tObject);
begin
  freeAndNil(f_config);
end;

// --  --
function Tc_form_main.mappedTo(mask: DWORD; index: int): bool;
begin
  result := (0 = mask) or (0 <> (mask and v_speaker_name_mask_cb[index].r_mask))
end;

// --  --
procedure Tc_form_main.createChannelMapArray();
var
  i: int;
  channel: int;
begin
  fillChar(f_channelMap, sizeOf(f_channelMap), #255);
  //
  channel := 0;
  for i := 0 to cuna_max_channels - 1 do begin
    //
    if (mappedTo(waveOut.pcm_channelMask, i)) then begin
      //
      f_channelMap[channel] := i;
      inc(channel);
    end;
  end;
end;

// -- feed the monster --
procedure Tc_form_main.waveOutFeedDone(sender: unavclInOutPipe; data: Pointer; len: Cardinal);
var
  c, i: int;
  numSamples,
  step: unsigned;
begin
  if (not f_doneFeeding and (nil <> data) and (0 < len)) then begin
    //
    fillChar(data^, len, #0);	// since we can mix several sources, chunk must be clean before we start
    step := waveOut.pcm_numChannels;
    numSamples := (len div waveOut.pcm_numChannels) shr 1; // 16-bit
    //
    for c := 0 to waveOut.pcm_numChannels - 1 do begin
      //
      // mix samples from all the sources mapped to this speaker (channel) if any
      try
	for i := 0 to c_form_sourceManage.sourceCount - 1 do begin
	  //
	  if (c_form_sourceManage.contributeSource(f_channelMap[c], i, pInt16Array(@pInt16Array(data)[c]), numSamples, step)) then
	    inc(f_totalMixed, numSamples);
	end;
      except
	// ignore exceptions
      end;
    end;
    //
    waveOut.write(data, len);
    //
    c_form_sourceManage.prepareNextChunk();	// tell sources to prepare next chunks
  end;
end;

// --  --
procedure Tc_form_main.a_wave_openExecute(Sender: TObject);
begin
  waveOut.pcm_samplesPerSec := str2intInt(c_cb_rate.text, 44100);
  c_cb_rate.text := int2str(waveOut.pcm_samplesPerSec);
  f_totalMixed := 0;
  createChannelMapArray();
  //
  waveOut.open();
  if (waveOut.active) then begin
    //
    c_form_sourceManage.openSources();
    //
    a_src_manage.enabled := false;
    a_wave_open.enabled := false;
    a_wave_close.enabled := true;
    //
    c_panel_layout.enabled := false;
    c_cb_rate.enabled := false;
    c_cb_surround.enabled := false;
    //
    f_doneFeeding := false;
    waveOut.flush();	// start self-feeding loop
  end;
end;

// --  --
procedure Tc_form_main.a_wave_closeExecute(Sender: TObject);
begin
  f_doneFeeding := true;
  //
  waveOut.close();
  c_form_sourceManage.closeSources();
  //
  a_src_manage.enabled := true;
  a_wave_open.enabled := true;
  a_wave_close.enabled := false;
  //
  c_panel_layout.enabled := true;
  c_cb_rate.enabled := true;
  c_cb_surround.enabled := true;
end;

// --  --
procedure Tc_form_main.c_cb_surroundChange(Sender: TObject);
begin
  if (not f_configuring) then begin
    //
    f_configuring := true;
    try
      //
      setDefaultConfig(c_cb_surround.itemIndex);
      //
      c_form_sourceManage.updatePresence();
    finally
      f_configuring := false;
    end;
  end;
end;

// --  --
procedure Tc_form_main.c_timer_mainTimer(Sender: TObject);
begin
  if (not (csDestroying in componentState)) then begin
    //
    {$IFDEF DEBUG }
    c_sb_main.panels[0].text := 'Mem: ' + int2str(ams() shr 10, 10, 3) + ' KB';
    {$ENDIF DEBUG }
    //
    c_label_mixed.caption := 'Mixed: ' + int2str(f_totalMixed, 10, 3) + ' samples';
  end;
end;

// --  --
procedure Tc_form_main.setDefaultConfig(index: int);
begin
  case (index) of

    0: waveOut.pcm_channelMask := 0;
    1: waveOut.pcm_channelMask := KSAUDIO_SPEAKER_MONO;
    2: waveOut.pcm_channelMask := KSAUDIO_SPEAKER_STEREO;
    3: waveOut.pcm_channelMask := KSAUDIO_SPEAKER_QUAD;
    4: waveOut.pcm_channelMask := KSAUDIO_SPEAKER_SURROUND;
    5: waveOut.pcm_channelMask := KSAUDIO_SPEAKER_5POINT1;
    6: waveOut.pcm_channelMask := KSAUDIO_SPEAKER_5POINT1_SURROUND;
    7: waveOut.pcm_channelMask := KSAUDIO_SPEAKER_7POINT1;
    8: waveOut.pcm_channelMask := KSAUDIO_SPEAKER_7POINT1_SURROUND;
    9: waveOut.pcm_channelMask := f_customMask;

  end;
  //
  mask2GUI(waveOut.pcm_channelMask);
end;

// --  --
procedure Tc_form_main.scb_changed(Sender: TObject);
begin
  if (not f_configuring) then begin
    //
    f_configuring := true;
    try
      updateConfig();
    finally
      f_configuring := false;
    end;
  end;
end;

// --  --
procedure Tc_form_main.updateConfig();
begin
  f_customMask := GUI2mask();
  mask2GUI(f_customMask);
  //
  c_form_sourceManage.updatePresence();
end;

// --  --
function Tc_form_main.GUI2mask(): DWORD;
var
  i: int;
begin
  result := 0;
  for i := 0 to cuna_max_channels - 1 do
    if (v_speaker_name_mask_cb[i].r_cb.checked) then result := result or v_speaker_name_mask_cb[i].r_mask;
end;

// --  --
procedure Tc_form_main.rebuildMapView();

  // --  --
  procedure mapSources(const name: string; mask: DWORD);
  var
    i: int;
    src: unaAudioSource;
    node: tTreeNode;
  begin
    node := c_tv_map.items.addChild(nil, name);
    //
    for i := 0 to c_form_sourceManage.sourceCount - 1 do begin
      //
      src := c_form_sourceManage.source[i];
      if ((nil <> src) and (0 <> (mask and src.mapping))) then
	c_tv_map.items.addChild(node, src.name);
    end;
  end;

  // --  --
  procedure mapSpeakers(src: unaAudioSource);
  var
    node: tTreeNode;
    i: int;
  begin
    node := c_tv_map.items.addChild(nil, src.name);
    //
    for i := 0 to cuna_max_channels - 1 do
      if (mappedTo(src.mapping, i)) then c_tv_map.items.addChild(node, v_speaker_name_mask_cb[i].r_name);
  end;

var
  i: int;
begin
  c_tv_map.items.beginUpdate();
  try
    c_tv_map.items.clear();
    //
    if (c_rb_rootSpeakers.checked) then begin
      //
      for i := 0 to cuna_max_channels - 1 do
	if (v_speaker_name_mask_cb[i].r_cb.checked) then
	  mapSources(v_speaker_name_mask_cb[i].r_name, v_speaker_name_mask_cb[i].r_mask);
      //
    end
    else begin
      //
      if (c_rb_rootSources.checked) then begin	// should be checked, but anyways..
	//
	for i := 0 to c_form_sourceManage.sourceCount - 1 do
	  mapSpeakers(c_form_sourceManage.source[i]);
      end;
    end;
    //
  finally
    c_tv_map.items.endUpdate();
  end;
  //
  if (c_cb_autoExpand.checked) then
    c_tv_map.fullExpand();
end;

// --  --
procedure Tc_form_main.mask2GUI(mask: DWORD);
var
  i: int;
  nChannels: unsigned;

  // --  --
  function checkMask(flag: DWORD): bool;
  begin
    result := (0 = mask) or (0 <> (mask and flag));
    if (result) then
      inc(nChannels);
  end;

begin
  nChannels := 0;
  for i := 0 to cuna_max_channels - 1 do
    v_speaker_name_mask_cb[i].r_cb.checked := checkMask(v_speaker_name_mask_cb[i].r_mask);
  //
  rebuildMapView();
  //
  case (mask) of

    0: 				      c_cb_surround.itemIndex := 0;
    KSAUDIO_SPEAKER_MONO: 	      c_cb_surround.itemIndex := 1;
    KSAUDIO_SPEAKER_STEREO: 	      c_cb_surround.itemIndex := 2;
    KSAUDIO_SPEAKER_QUAD: 	      c_cb_surround.itemIndex := 3;
    KSAUDIO_SPEAKER_SURROUND:	      c_cb_surround.itemIndex := 4;
    KSAUDIO_SPEAKER_5POINT1:          c_cb_surround.itemIndex := 5;
    KSAUDIO_SPEAKER_5POINT1_SURROUND: c_cb_surround.itemIndex := 6;
    KSAUDIO_SPEAKER_7POINT1:          c_cb_surround.itemIndex := 7;
    KSAUDIO_SPEAKER_7POINT1_SURROUND: c_cb_surround.itemIndex := 8;
    else			      c_cb_surround.itemIndex := 9;

  end;
  //
  waveOut.pcm_channelMask := mask;
  waveOut.pcm_numChannels := nChannels;
  samplingParamsChanged(false);
end;

// --  --
procedure Tc_form_main.a_src_manageExecute(sender: tObject);
begin
  c_form_sourceManage.manageSources();
  //
  rebuildMapView();
end;

// --  --
procedure Tc_form_main.c_cb_rateChange(Sender: TObject);
begin
  waveOut.pcm_samplesPerSec := str2intInt(c_cb_rate.text, 44100);
  //
  samplingParamsChanged(true);
end;

// --  --
procedure Tc_form_main.samplingParamsChanged(rateChanged: bool);
begin
  c_label_ch.caption := int2str(waveOut.pcm_numChannels) + ' channel' + choice(waveOut.pcm_numChannels < 2, '', 's') + '; ' +
			int2str(waveOut.pcmFormatExt.Format.nAvgBytesPerSec, 10, 3) + ' bytes/sec';
  //
  if (rateChanged) then
    c_form_sourceManage.setSamplingRate(waveOut.pcm_samplesPerSec);
end;

// --  --
procedure Tc_form_main.c_rb_rootViewClick(Sender: TObject);
begin
  rebuildMapView();
end;

// --  --
procedure Tc_form_main.c_cb_autoExpandClick(Sender: TObject);
begin
  c_tv_map.autoExpand := c_cb_autoExpand.checked;
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  ShellExecute(handle, 'open', 'http://lakeofsoft.com/vc/a_surroundmixing.html', nil, nil, SW_SHOWNORMAL);
end;


end.

