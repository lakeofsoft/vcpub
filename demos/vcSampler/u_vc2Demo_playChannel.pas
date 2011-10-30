
(*
	----------------------------------------------

	  u_vc2demo_playChannel.pas
	  Voice Communicator components version 2.5
	  VC Sampler demo application - wave channel form

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, May 2002

	  modified by:
		Lake, May-Dec 2002
		Lake, Feb 2003
		Lake, Oct 2005

	----------------------------------------------
*)

{$I unaDef.inc}

unit
  u_vc2demo_playChannel;

interface

uses
  Windows, unaTypes, Forms, StdCtrls, Classes, ActnList, Dialogs, ComCtrls, Controls,
  unaClasses, unaMsAcmClasses, ExtCtrls, Buttons;

type
  Tc_form_playbackChannel = class(TForm)
    c_groupBox_main: TGroupBox;
    Label2: TLabel;
    c_edit_fileName: TEdit;
    c_openDialog_file: TOpenDialog;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    c_button_fadeOut: TButton;
    c_button_fadeIn: TButton;
    c_trackBar_pan: TTrackBar;
    c_trackBar_volume: TTrackBar;
    c_label_volume: TLabel;
    c_label_pan: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    c_trackBar_freq: TTrackBar;
    Label7: TLabel;
    Label8: TLabel;
    c_actionList_main: TActionList;
    ac_play: TAction;
    ac_stop: TAction;
    ac_pause: TAction;
    ac_fadeout: TAction;
    ac_fadein: TAction;
    c_staticText_formatOriginal: TStaticText;
    c_checkBox_loop: TCheckBox;
    c_staticText_formatCurrent: TStaticText;
    ac_fileOpen: TAction;
    c_timer_fade: TTimer;
    SpeedButton1: TSpeedButton;
    procedure formCreate(Sender: TObject);
    procedure formClose(Sender: TObject; var Action: TCloseAction);
    procedure formDestroy(Sender: TObject);
    procedure ac_stopExecute(Sender: TObject);
    procedure c_trackBar_freqChange(Sender: TObject);
    procedure ac_playExecute(Sender: TObject);
    procedure c_checkBox_loopClick(Sender: TObject);
    procedure c_trackBar_volumeChange(Sender: TObject);
    procedure c_timer_fadeTimer(Sender: TObject);
    procedure ac_fadeoutExecute(Sender: TObject);
    procedure ac_fadeinExecute(Sender: TObject);
    procedure c_trackBar_panChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    f_riff: unaRiffStream;
    f_resampler: unaWaveResampler;
    f_oldPos: int;
    f_stream: unaAbstractStream;
    f_fadeDelta: int;
    //
    procedure reEnableControls();
    procedure setNewFile();
    procedure myOnDA(sender: tObject; data: pointer; size: uint);
  public
    { Public declarations }
  end;


implementation


{$R *.dfm}

uses
  unaUtils, unaMsAcmAPI, SysUtils,
  u_vc2demo_main;

// --  --
procedure Tc_form_playbackChannel.FormCreate(Sender: TObject);
begin
  c_edit_fileName.Text := '';
  ac_play.Enabled := false;
  ac_stop.Enabled := false;
  ac_pause.Enabled := false;
  ac_fadeout.Enabled := false;
  ac_fadein.Enabled := false;
  //
  f_resampler := unaWaveResampler.create(false);
  f_resampler.assignStream(false, nil);	// remove output stream
  f_resampler.onDataAvailable := myOnDA;
  //
  c_form_vc2DemoMain.ini.section := 'Channels';
  c_openDialog_file.InitialDir := c_form_vc2DemoMain.ini.get('initialDir', '.\');
end;

// --  --
procedure Tc_form_playbackChannel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ac_stop.Execute();
  Action := caFree;
  c_form_vc2DemoMain.channels.removeItem(self);
end;

// --  --
procedure Tc_form_playbackChannel.setNewFile();
begin
  ac_stop.Execute();
  //
  freeAndNil(f_riff);
  f_riff := unaRiffStream.create(c_edit_fileName.text, true, c_checkBox_loop.checked, c_form_vc2DemoMain.acm);
  //
  if (nil <> f_riff.dstFormatExt) then begin
    //
    c_staticText_formatOriginal.caption := 'Input: ' + f_riff.srcFormatInfo;
    //
    f_riff.addConsumer(f_resampler);
    //
    f_resampler.setSamplingExt(true, f_riff.dstFormatExt);
    f_resampler.setSamplingExt(false, c_form_vc2DemoMain.playback.srcFormatExt);
    //
    c_trackBar_freq.position := 10;
    c_staticText_formatCurrent.caption := 'Ouput: ' + f_resampler.dstFormatInfo;
    //
    reEnableControls();
  end
  else
    c_staticText_formatCurrent.caption := 'Unknown wave format';
  //
end;

// --  --
procedure Tc_form_playbackChannel.ac_stopExecute(Sender: TObject);
begin
  f_riff.close();
  f_resampler.close();
  //
  if (nil <> f_stream) then
    c_form_vc2DemoMain.mixer.removeStream(f_stream);
  f_stream := nil;
  //
  reEnableControls();
end;

// --  --
procedure Tc_form_playbackChannel.FormDestroy(Sender: TObject);
begin
  ac_stop.execute();
  //
  freeAndNil(f_resampler);
  freeAndNil(f_riff);
end;

// --  --
procedure Tc_form_playbackChannel.c_trackBar_freqChange(Sender: TObject);
var
  pos: unsigned;
  rate: unsigned;
begin
  if (f_oldPos <> c_trackBar_freq.Position) then begin
    //
    pos := (20 - c_trackBar_freq.Position) * 10;	// 0% .. 100% .. 200%
    if (1 > pos) then
      pos := 10;	// 5% instead of 0%
    //
    rate := (c_form_vc2DemoMain.playback.srcFormatExt.Format.nSamplesPerSec * pos) div 100;
    f_resampler.setSampling(false, rate, c_form_vc2DemoMain.playback.srcFormatExt.Format.wBitsPerSample, c_form_vc2DemoMain.playback.srcFormatExt.Format.nChannels);
    f_riff.realTimer.interval := ((1000 div f_riff.chunkPerSecond) * pos) div 100;
    c_trackBar_volumeChange(nil);
    //
    c_staticText_formatCurrent.Caption := 'Ouput: ' + f_resampler.dstFormatInfo;
    //
    f_oldPos := c_trackBar_freq.Position;
  end;
end;

// --  --
procedure Tc_form_playbackChannel.ac_playExecute(Sender: TObject);
begin
  if (nil = f_stream) then begin
    //
    f_stream := c_form_vc2DemoMain.mixer.addStream();
    f_resampler.open();
    f_riff.open();
  end;
  //
  reEnableControls();
  c_trackBar_volumeChange(nil);
end;

// --  --
procedure Tc_form_playbackChannel.myOnDA(sender: tObject; data: pointer; size: uint);
begin
  // put data from resampler to stream
  if (nil <> f_stream) then
    f_stream.write(data, size);
end;

// --  --
procedure Tc_form_playbackChannel.c_checkBox_loopClick(Sender: TObject);
begin
  f_riff.loop := c_checkBox_loop.Checked;
end;

// --  --
procedure Tc_form_playbackChannel.c_trackBar_volumeChange(Sender: TObject);
var
  i: int;
  pos: unsigned;
  pan: unsigned;
  volume1: unsigned;
  volume2: unsigned;
begin
  pos := c_trackBar_volume.Max - c_trackBar_volume.Position;
  pan := c_trackBar_pan.Position;	// 100 means 100%/100%, 0 means 100%/0% and 200 means 0%/100%
  //
  if (unsigned(c_trackBar_pan.Max) div 2 > pan) then begin
    //
    volume1 := pos;
    volume2 := (pos * pan) div 100;
  end
  else begin
    //
    volume1 := (pos * (unsigned(c_trackBar_pan.Max) - pan)) div 100;
    volume2 := pos;
  end;
  //
  if ((nil <> f_resampler.dstFormatExt) and (0 < f_resampler.dstFormatExt.Format.nChannels)) then begin
    //
    for i := 0 to f_resampler.dstFormatExt.Format.nChannels - 1 do begin
      //
      if (0 <> i) then
	// other channels ;)
	f_resampler.setVolume100(i, volume2)
      else
	// left cnannel
	f_resampler.setVolume100(i, volume1);
    end;
  end;  	
  //
  c_label_volume.Caption := 'Volume = ' + int2str(pos div 10) + '.' + int2str(pos mod 10) + '%';
  //
  if (unsigned(c_trackBar_pan.Max) div 2 > pan) then
    c_label_pan.Caption := 'Pan = 100%/' + int2str(pan) + '%'
  else
    c_label_pan.Caption := 'Pan = ' + int2str(unsigned(c_trackBar_pan.Max) - pan) + '%/100%';
  //
  pos := c_trackBar_volume.Position;
  ac_fadeIn.enabled := pos > 100;
  ac_fadeOut.enabled := pos < unsigned(c_trackBar_volume.Max);
end;

// --  --
procedure Tc_form_playbackChannel.c_timer_fadeTimer(Sender: TObject);
var
  newPos: int;
begin
  newPos := c_trackBar_volume.position + f_fadeDelta;
  if (newPos < c_trackBar_volume.Min) then
    newPos := c_trackBar_volume.Min;
  if (newPos > c_trackBar_volume.Max) then
    newPos := c_trackBar_volume.Max;
  //
  if ((newPos < 100) and (0 > f_fadeDelta)) or
     (newPos >= c_trackBar_volume.Max) then
    c_timer_fade.Enabled := false;
  //
  c_trackBar_volume.Position := newPos;
end;

// --  --
procedure Tc_form_playbackChannel.ac_fadeoutExecute(Sender: TObject);
begin
  f_fadeDelta := +10;
  c_timer_fade.Enabled := true;
end;

// --  --
procedure Tc_form_playbackChannel.ac_fadeinExecute(Sender: TObject);
begin
  f_fadeDelta := -10;
  c_timer_fade.Enabled := true;
end;

// --  --
procedure Tc_form_playbackChannel.c_trackBar_panChange(Sender: TObject);
begin
  c_trackBar_volumeChange(nil);
end;

// --  --
procedure Tc_form_playbackChannel.reEnableControls();
var
  isPlaying: bool;
begin
  isPlaying := f_resampler.isOpen();
  //
  ac_play.Enabled := not isPlaying;
  ac_stop.Enabled := isPlaying;
  ac_pause.Enabled := isPlaying;
  c_checkBox_loop.Enabled := not isPlaying;
  c_trackBar_freq.Enabled := isPlaying;
  c_trackBar_volume.Enabled := isPlaying;
  c_trackBar_pan.Enabled := isPlaying;
  ac_fadeOut.Enabled := isPlaying;
  ac_fadeIn.Enabled := isPlaying;
end;

// --  --
procedure Tc_form_playbackChannel.SpeedButton1Click(Sender: TObject);
begin
  if (c_openDialog_file.Execute()) then begin
    //
    c_edit_fileName.Text := c_openDialog_file.FileName;
    setNewFile();
    c_form_vc2DemoMain.ini.section := 'Channels';
    c_form_vc2DemoMain.ini.setValue('initialDir', extractFilePath(c_edit_fileName.text));
  end;
end;


end.

