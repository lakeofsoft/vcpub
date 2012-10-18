
(*
	----------------------------------------------

	  u_daf_main.pas
	  Voice Communicator components version 2.5
	  Audio Feedabck demo - main form

	----------------------------------------------
	  Copyright (c) 2005-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 11 Aug 2005

	  modified by:
		Lake, Aug 2005
		Lake, May 2009

	----------------------------------------------
*)

{$I unaDef.inc }

unit
  u_daf_main;

interface

uses
  Windows, unaTypes, unaClasses, unaAudioFeedback,
  Forms, StdCtrls, Controls, Classes, ComCtrls, ExtCtrls,
  unaDspControls, unaVCIDE, Menus, unaVC_pipe, unaVC_wave;

type
  Tc_form_main = class(TForm)
    c_tb_delay: TTrackBar;
    c_cb_waveIn: TComboBox;
    c_cb_waveOut: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    c_button_start: TButton;
    c_button_stop: TButton;
    c_statusBar_main: TStatusBar;
    c_timer_update: TTimer;
    c_label_delayInfo: TLabel;
    c_fft_in: TunadspFFTControl;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    c_fft_out: TunadspFFTControl;
    Label4: TLabel;
    //
    procedure formCreate(sender: tObject);
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    procedure formDestroy(sender: tObject);
    procedure formShow(sender: tObject);
    //
    procedure c_button_startClick(Sender: TObject);
    procedure c_button_stopClick(Sender: TObject);
    procedure c_timer_updateTimer(Sender: TObject);
    procedure c_tb_delayChange(sender: tObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    f_config: unaIniFile;
    f_feedback: unaAudioFeedbackClass;
    f_delayStep: int;
    //
    procedure dafControl(cmd: int);
    procedure myOnDA(sender: tObject; data: pointer; len: uint);
    procedure myOnCD(sender: tObject; data: pointer; len: uint);
  public
    { Public declarations }
  end;

var
  c_form_main: Tc_form_main;


implementation


uses
  unaUtils,
  unaVCLUtils, unaVCIDEUtils, unaMsAcmClasses,
  ShellAPI;


{$R *.dfm}

{ tForm1 }

// --  --
procedure Tc_form_main.formCreate(sender: tObject);
begin
  // setup VC classes constants
  c_defChunksPerSecond := 50;			// 20 ms chunks
  //c_defPlaybackChunksAheadNumber := 0;		// no delay
  //
  {$IFDEF __AFTER_D7__ }
  doubleBuffered := True;
  {$ENDIF __AFTER_D7__ }
  //
  f_delayStep := 1000 div c_defChunksPerSecond;
  //
  f_config := unaIniFile.create();
  //
  f_feedback := unaAudioFeedbackClass.create(false, THREAD_PRIORITY_ABOVE_NORMAL);
  f_feedback.onDataAvailable := myOnDA;
  f_feedback.onChunkDone := myOnCD;
end;

// --  --
procedure Tc_form_main.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  c_timer_update.enabled := false;
  //
  c_fft_in.active := false;
  c_fft_out.active := false;
  //
  f_feedback.stop();
  //
  f_config.setValue('waveIn.deviceIndex', c_cb_waveIn.itemIndex);
  f_config.setValue('waveOut.deviceIndex', c_cb_waveOut.itemIndex);
  f_config.setValue('wave.delayPos', c_tb_delay.position);
  //
  saveControlPosition(self, f_config, 'position');
end;

// --  --
procedure Tc_form_main.formDestroy(sender: tObject);
begin
  freeAndNil(f_feedback);
  freeAndNil(f_config);
end;

// --  --
procedure Tc_form_main.formShow(sender: tObject);
begin
  loadControlPosition(self, f_config, 'position', true, false);
  //
  c_tb_delay.min := 1;
  c_tb_delay.max := 100;	// 20 ms * 100 = 2000 ms (max is 256)
  c_tb_delay.position := max(1, min(100, f_config.get('wave.delayPos', int(2))));	// default to 40 ms
  //
  enumWaveDevices(c_cb_waveIn,   true, true);
  enumWaveDevices(c_cb_waveOut, false, true);
  //
  c_cb_waveIn.itemIndex  := f_config.get('waveIn.deviceIndex', int(0));		// mapper by default
  c_cb_waveOut.itemIndex := f_config.get('waveOut.deviceIndex', int(0));	// mapper by default
  //
  c_timer_update.enabled := true;
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  shellExecute(handle, 'open', 'http://lakeofsoft.com/vc/a_delayedaudiofeedback.html', nil, nil, SW_SHOWNORMAL);
end;

// --  --
procedure Tc_form_main.c_button_startClick(Sender: TObject);
begin
  c_button_start.enabled := false;
  //
  f_feedback.setup(c_tb_delay.position * f_delayStep, index2deviceId(c_cb_waveIn), index2deviceId(c_cb_waveOut), nil);
  //
  // start DAF
  dafControl(1);
end;

// --  --
procedure Tc_form_main.c_button_stopClick(Sender: TObject);
begin
  c_button_stop.enabled := false;
  //
  // stop DAF
  dafControl(0);
end;

// --  --
procedure Tc_form_main.dafControl(cmd: int);
begin
  case (cmd) of

    0: begin
      //
      f_feedback.stop();
      //
      c_fft_in.active := false;
      c_fft_out.active := false;
    end;

    1: begin
      //
      with (f_feedback.waveIn.dstFormatExt.format) do begin
        //
	 c_fft_in.fft.fft.setFormat(nSamplesPerSec, wBitsPerSample, nChannels);
	c_fft_out.fft.fft.setFormat(nSamplesPerSec, wBitsPerSample, nChannels);
      end;
      //
      c_fft_in.active := true;
      c_fft_out.active := true;
      //
      f_feedback.start();
    end;

  end;
end;

// --  --
function status2str(status, errorCode: int): string;
begin
  case (status) of

    c_stat_afStopped:
      result := ' process is stopped';

    c_stat_afActive:
      result := ' process is running';

    c_stat_afErrorIn:
      result := ' recording device error - ' + unaWaveInDevice.getErrorText(errorCode);

    c_stat_afErrorOut:
      result := ' playback device error -  ' + unaWaveOutDevice.getErrorText(errorCode);

    else
      result := 'uknown status (' + int2str(status) + ')';

  end;
end;

// --  --
procedure Tc_form_main.c_timer_updateTimer(Sender: TObject);
var
  isRunning: bool;
begin
  c_statusBar_main.panels[0].text := status2str(f_feedback.status, f_feedback.errorCode);
  //
  isRunning := (c_stat_afActive = f_feedback.status);
  //
  c_button_start.enabled := not isRunning;
  c_button_stop.enabled := isRunning;
  c_cb_waveIn.enabled :=  not isRunning;
  c_cb_waveOut.enabled :=  not isRunning;
  //
  c_label_delayInfo.caption := int2str(c_tb_delay.position * f_delayStep) + ' ms';
end;

// --  --
procedure Tc_form_main.c_tb_delayChange(sender: tObject);
begin
  // adjust the delay
  f_feedback.delay := c_tb_delay.position * f_delayStep;
end;

// --  --
procedure Tc_form_main.myOnCD(sender: tObject; data: pointer; len: uint);
begin
  c_fft_out.fft.write(data, len);
end;

// --  --
procedure Tc_form_main.myOnDA(sender: tObject; data: pointer; len: uint);
begin
  c_fft_in.fft.write(data, len);
end;

// --  --
procedure Tc_form_main.Exit1Click(Sender: TObject);
begin
  close();
end;


end.

