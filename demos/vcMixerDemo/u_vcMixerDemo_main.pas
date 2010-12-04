
(*
	----------------------------------------------

	  u_vcMixerDemo_main.pas - MS system mixer demo application main form
	  Voice Communicator components version 2.5

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 10 Jun 2002

	  modified by:
		Lake, Aug-Dec 2002
		Lake, Feb-May 2003
		Lake, Oct 2005
		Lake, Dec 2008

	----------------------------------------------
*)

{$I unaDef.inc }

unit u_vcMixerDemo_main;

interface

uses
  Windows, unaTypes, Messages, MMSystem, unaMsMixer, unaMsAcmClasses,
  Forms, Controls, StdCtrls, Classes, ActnList, ComCtrls, ExtCtrls, Buttons,
  Menus;

type
  // --  --
  tVolumeBar = record
    r_lineIndex: int;
    r_connIndex: int;
    r_controlId: int;
    r_allowChange: bool;
  end;

  // --  --
  Tc_form_main = class(TForm)
    c_actionList_main: TActionList;
    a_record: TAction;
    a_stop: TAction;
    c_timer_update: TTimer;
    c_statusBar_main: TStatusBar;
    c_comboBox_mixerIndex: TComboBox;
    Label5: TLabel;
    c_comboBox_outConn: TComboBox;
    c_label_out: TLabel;
    c_trackBar_out: TTrackBar;
    c_label_in: TLabel;
    c_comboBox_inConn: TComboBox;
    c_trackBar_in: TTrackBar;
    c_button_recStart: TButton;
    c_button_recStop: TButton;
    c_progressBar_right: TProgressBar;
    c_progressBar_left: TProgressBar;
    Label3: TLabel;
    Label4: TLabel;
    Bevel1: TBevel;
    c_trackBar_outMain: TTrackBar;
    c_trackBar_inMain: TTrackBar;
    Bevel2: TBevel;
    c_checkBox_outMute: TCheckBox;
    c_checkBox_inMute: TCheckBox;
    Bevel3: TBevel;
    c_checkBox_micForce: TCheckBox;
    Bevel4: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    c_mm_main: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Label6: TLabel;
    Record1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    //
    procedure formCreate(sender: tObject);
    procedure formDestroy(sender: tObject);
    procedure formShow(sender: tObject);
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    //
    procedure a_recordExecute(Sender: TObject);
    procedure a_stopExecute(Sender: TObject);
    procedure c_comboBox_inConnChange(Sender: TObject);
    procedure c_voumeBar_change(sender: tObject);
    procedure c_timer_updateTimer(Sender: TObject);
    procedure c_comboBox_mixerIndexChange(Sender: TObject);
    procedure c_comboBox_outConnChange(Sender: TObject);
    //
    procedure c_checkBox_outMuteClick(Sender: TObject);
    procedure c_checkBox_inMuteClick(Sender: TObject);
    procedure c_checkBox_micForceClick(Sender: TObject);
    //
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    f_waveIn: unaWaveInDevice;
    f_mixerSystem: unaMsMixerSystem;
    f_inConn: int;
    f_outConn: int;
    f_inLineIndex: int;
    f_outLineIndex: int;
    f_volumeBar: array[0..3] of tVolumeBar;
    //
    procedure changeMixer(mixerIndex: integer);
    procedure reEnable();
    procedure onMixerControlChange(var msg: tMessage); message MM_MIXM_CONTROL_CHANGE;
    procedure rebuildVolumeBar(trackBar: tTrackBar; iline: unsigned; iconn: int; allowNoConn: bool = false);
    function updateVolumeBar(trackBar: tTrackBar; controlID: unsigned): bool;
    //
    procedure updateMixerControl(controlID: unsigned);
  public
    { Public declarations }
  end;

var
  c_form_main: Tc_form_main;


implementation


{$R *.dfm}

uses
  unaUtils, unaWave, SysUtils,
  ShellAPI;

// --  --
procedure Tc_form_main.formCreate(Sender: TObject);
var
  i: int;
begin
  f_waveIn := unaWaveInDevice.create(WAVE_MAPPER, false, false, 1);
  f_waveIn.setSampling();
  f_waveIn.calcVolume := true;
  //
  c_comboBox_mixerIndex.clear();
  //
  f_mixerSystem := unaMsMixerSystem.create();
  if (0 < f_mixerSystem.getMixerCount()) then begin
    //
    i := 0;
    while (i < f_mixerSystem.getMixerCount()) do begin
      //
      f_mixerSystem.selectMixer(i);
      c_comboBox_mixerIndex.items.add(f_mixerSystem.getMixerName());
      inc(i);
    end;
    //
    c_comboBox_mixerIndex.itemIndex := 0;
  end;
  //
  c_comboBox_mixerIndexChange(self);
end;

// --  --
procedure Tc_form_main.formShow(Sender: TObject);
begin
  c_timer_update.enabled := true;
end;

// --  --
procedure Tc_form_main.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  c_timer_update.enabled := false;
end;

// --  --
procedure Tc_form_main.formDestroy(sender: tObject);
begin
  freeAndNil(f_mixerSystem);
  freeAndNil(f_waveIn);
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://lakeofsoft.com/vc/a_volumemixer.html', nil, nil, SW_SHOWNORMAL);
end;

procedure Tc_form_main.a_recordExecute(Sender: TObject);
var
  res: int;
begin
  res := f_waveIn.open();
  //
  if (not f_waveIn.isOpen()) then
    raise exception.create('Unable to open waveIn device, error text: '#13#10 + f_waveIn.getErrorText(res));
  //
  reEnable();
end;

// --  --
procedure Tc_form_main.a_stopExecute(Sender: TObject);
begin
  f_waveIn.close();
  //
  reEnable();
end;

// --  --
procedure Tc_form_main.reEnable();
begin
  a_record.enabled := not f_waveIn.isOpen();
  a_stop.enabled := not a_record.enabled;
end;

// --  --
procedure Tc_form_main.rebuildVolumeBar(trackBar: tTrackBar; iline: unsigned; iconn: int; allowNoConn: bool);
begin
  with (trackBar) do begin
    //
    with f_volumeBar[tag] do begin
      //
      r_lineIndex := iline;
      r_connIndex := iconn;
      r_controlId := f_mixerSystem.getVolumeControlID(iline, iconn);
      r_allowChange := (0 <= iconn);
      //
      enabled := (0 <= r_controlId) and ((0 <= iconn) or allowNoConn);
      //
      if (enabled) then
	updateMixerControl(r_controlId)
      else
	position := 0;
    end;
  end;
end;

// --  --
function Tc_form_main.updateVolumeBar(trackBar: tTrackBar; controlID: unsigned): bool;
begin
  with (trackBar) do begin
    //
    with f_volumeBar[tag] do begin
      //
      if (r_controlId = int(controlID)) then begin
	//
	r_allowChange := false;
	try
	  trackBar.position := f_mixerSystem.getVolume(r_lineIndex, r_connIndex);
	finally
	  r_allowChange := true;
	end;
	//
	result := true;
      end
      else
	result := false;
    end;
  end;
end;

// --  --
procedure Tc_form_main.c_comboBox_inConnChange(Sender: TObject);
begin
  f_inConn := c_comboBox_inConn.itemIndex;
  //
  rebuildVolumeBar(c_trackBar_in, f_inLineIndex, f_inConn);
  if (0 <= f_inConn) then
    f_mixerSystem.setRecSource(f_inConn, false{do not care about un-muting});
  //
  with c_checkBox_inMute do begin
    //
    tag := f_mixerSystem.getMuteControlID(f_inLineIndex, f_inConn);
    enabled := (0 <= f_inConn) and (0 <= tag);
    //
    if (enabled) then
      updateMixerControl(tag)
    else
      checked := false;
  end;
end;

// --  --
procedure Tc_form_main.c_comboBox_outConnChange(Sender: TObject);
begin
  f_outConn := c_comboBox_outConn.itemIndex;
  rebuildVolumeBar(c_trackBar_out, f_outLineIndex, f_outConn);
  //
  with c_checkBox_outMute do begin
    //
    tag := f_mixerSystem.getMuteControlID(f_outLineIndex, f_outConn);
    enabled := (0 <= f_outConn) and (0 <= tag);
    //
    if (enabled) then
      updateMixerControl(tag)
    else
      checked := true;
  end;
end;

// --  --
procedure Tc_form_main.updateMixerControl(controlID: unsigned);
var
  newRecSource: int;
begin
  if (updateVolumeBar(c_trackBar_in, controlID)) then
  else
    if (updateVolumeBar(c_trackBar_out, controlID)) then
    else
      if (updateVolumeBar(c_trackBar_inMain, controlID)) then
      else
        if (updateVolumeBar(c_trackBar_outMain, controlID)) then
        else begin
          //
          if (c_checkBox_inMute.tag = int(controlID)) then begin
            //
            with c_checkBox_inMute do begin
              //
              enabled := false;
              try
                if (0 < f_inLineIndex) then
                  checked := f_mixerSystem.isMutedConnection(f_inLineIndex, f_inConn)
                else
                  checked := true;
              finally
                enabled := true;
              end;
            end;
          end
          else begin
            //
            if (c_checkBox_outMute.tag = int(controlID)) then begin
              //
              with c_checkBox_outMute do begin
                //
                if (0 <= f_outLineIndex) then begin
                  //
                  enabled := false;
                  try
                    checked := f_mixerSystem.isMutedConnection(f_outLineIndex, f_outConn);
                  finally
                    enabled := true;
                  end;
                end;
              end;
            end
            else begin
              // check if recording source was changed
              newRecSource := f_mixerSystem.getRecSource();
              if ((0 <= newRecSource) and (newRecSource <> f_inConn)) then begin
                //
                c_comboBox_inConn.itemIndex := newRecSource;
                c_comboBox_inConnChange(self);
              end;
            end;
          end;
        end;
end;

// --  --
procedure Tc_form_main.onMixerControlChange(var msg: tMessage);
begin
  updateMixerControl(msg.LParam);
end;

// --  --
procedure Tc_form_main.c_voumeBar_change(sender: tObject);
var
  tag: int;
begin
  tag := (sender as tControl).tag;
  //
  with f_volumeBar[tag] do begin
    //
    if (r_allowChange) then
      f_mixerSystem.setVolume(r_lineIndex, r_connIndex, (sender as tTrackBar).position);
  end;
end;

// --  --
procedure Tc_form_main.c_checkBox_inMuteClick(Sender: TObject);
begin
  if (c_checkBox_inMute.enabled) then
    f_mixerSystem.muteConnection(f_inLineIndex, f_inConn, c_checkBox_inMute.checked);
end;

// --  --
procedure Tc_form_main.c_checkBox_outMuteClick(Sender: TObject);
begin
  if (c_checkBox_outMute.enabled) then
    f_mixerSystem.muteConnection(f_outLineIndex, f_outConn, c_checkBox_outMute.checked);
end;

// --  --
procedure Tc_form_main.c_timer_updateTimer(Sender: TObject);
begin
  if (not (csDestroying in componentState)) then begin
    //
    c_progressBar_left.position := waveGetLogVolume(f_waveIn.getVolume(0));
    c_progressBar_right.position := waveGetLogVolume(f_waveIn.getVolume(1));
    //
    {$IFDEF DEBUG }
    c_statusBar_main.panels[0].text := 'Mem: ' + int2str(ams() shr 10, 10, 3) + ' KB';
    {$ENDIF DEBUG }
  end;
end;

// --  --
procedure Tc_form_main.changeMixer(mixerIndex: integer);
var
  i: int;
  deviceId: int;
  name: wideString;
begin
  a_stop.execute();
  //
  c_comboBox_inConn.clear();
  c_comboBox_outConn.clear();
  c_comboBox_inConn.enabled := false;
  c_comboBox_outConn.enabled := false;
  //
  c_checkBox_micForce.enabled := false;
  //
  c_trackBar_in.enabled := false;
  c_trackBar_out.enabled := false;
  //
  if ((0 <= mixerIndex) and (mixerIndex < int(f_mixerSystem.getMixerCount()))) then begin
    //
    f_mixerSystem.selectMixer(mixerIndex, handle);
    //
    f_inLineIndex := f_mixerSystem.getLineIndex(false);
    f_outLineIndex := f_mixerSystem.getLineIndex(true);
  end
  else begin
    //
    rebuildVolumeBar(c_trackBar_inMain, 0, -1, true);
    rebuildVolumeBar(c_trackBar_outMain, 0, -1, true);
    //
    c_comboBox_outConnChange(self);
    c_comboBox_inConnChange(self);
    //
    f_inLineIndex := -1;
    f_outLineIndex := -1;
  end;
  //
  if (0 <= f_inLineIndex) then begin
    // fill input lines
    c_label_in.caption := '&' + f_mixerSystem.getLineName(f_inLineIndex);
    //
    rebuildVolumeBar(c_trackBar_inMain, f_inLineIndex, -1, true);
    //
    i := 0;
    while (i < f_mixerSystem.getLineConnectionCount(f_inLineIndex)) do begin
      //
      name := f_mixerSystem.getLineConnectionName(f_inLineIndex, i);
      if ('' <> name) then
	c_comboBox_inConn.items.add(name)
      else
	c_comboBox_inConn.items.add('<Untitled Line>');
      //
      inc(i);
    end;
    //
    if (0 < i) then begin
      //
      c_comboBox_inConn.enabled := true;
      c_checkBox_micForceClick(self);
    end
    else
  end
  else begin
    // fill input lines
    c_label_in.caption := 'No such line';
    c_trackBar_inMain.enabled := false;
    c_trackBar_in.enabled := false;
    //
    rebuildVolumeBar(c_trackBar_inMain, 0, -1);
    rebuildVolumeBar(c_trackBar_in, 0, -1);
    c_trackBar_inMain.position := 0;
    c_trackBar_in.position := 0;
    //
    c_comboBox_inConn.clear();
    c_comboBox_inConn.enabled := false;
    //
    c_checkBox_inMute.enabled := false;
  end;
  //
  if (0 <= f_outLineIndex) then begin
    // fill output lines
    c_label_out.caption := '&' + f_mixerSystem.getLineName(f_outLineIndex);
    //
    rebuildVolumeBar(c_trackBar_outMain, f_outLineIndex, -1, true);
    //
    i := 0;
    while (i < f_mixerSystem.getLineConnectionCount(f_outLineIndex)) do begin
      //
      c_comboBox_outConn.items.add(f_mixerSystem.getLineConnectionName(f_outLineIndex, i));
      inc(i);
    end;
    //
    if (0 < i) then begin
      c_comboBox_outConn.enabled := true;
      //
      c_comboBox_outConn.itemIndex := 0;
      c_comboBox_outConnChange(self);
    end;
  end
  else begin
    //
    // fill output lines
    c_label_out.caption := 'No such line';
    c_trackBar_outMain.enabled := false;
    c_trackBar_out.enabled := false;
    //
    rebuildVolumeBar(c_trackBar_outMain, 0, -1);
    rebuildVolumeBar(c_trackBar_out, 0, -1);
    c_trackBar_outMain.position := 0;
    c_trackBar_out.position := 0;
    //
    c_comboBox_outConn.clear();
    c_comboBox_outConn.enabled := false;
    //
    c_checkBox_outMute.enabled := false;
  end;
  //
  deviceId := f_mixerSystem.getDeviceId(true, false);
  //
  if (0 <= deviceId) then begin
    //
    a_record.enabled := true;
    f_waveIn.deviceId := deviceId;
    Label6.caption := '';
  end
  else begin
    //
    a_record.enabled := false;
    //
    if (-3 = deviceId) then
      Label6.caption := 'This mixer has no associated recording device.'
    else
      if (-2 = deviceId) then
        Label6.caption := 'No mixer device was selected.';
  end;
end;

// --  --
procedure Tc_form_main.c_comboBox_mixerIndexChange(Sender: TObject);
begin
  changeMixer(c_comboBox_mixerIndex.itemIndex);
end;

// --  --
procedure Tc_form_main.c_checkBox_micForceClick(Sender: TObject);
var
  micIndex: int;
begin
  if (c_checkBox_micForce.checked) then
    micIndex := f_mixerSystem.getLineConnectionByType(f_inLineIndex, MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE)
  else
    micIndex := f_mixerSystem.getRecSource();
  //
  c_comboBox_inConn.itemIndex := micIndex;
  c_comboBox_inConnChange(self);
end;

// --  --
procedure Tc_form_main.SpeedButton1Click(Sender: TObject);
begin
{$IFDEF DEBUG }
  c_trackBar_in.position := c_trackBar_in.position - 1;
{$ENDIF }
end;

// --  --
procedure Tc_form_main.SpeedButton2Click(Sender: TObject);
begin
{$IFDEF DEBUG }
  c_trackBar_in.position := c_trackBar_in.position + 1;
{$ENDIF }
end;

// --  --
procedure Tc_form_main.Exit1Click(Sender: TObject);
begin
  close();
end;


end.

