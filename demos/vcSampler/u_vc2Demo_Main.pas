
(*
	----------------------------------------------

	  u_vc2semo_main.pas
	  Voice Communicator components version 2.5
	  VC Sampler demo application - main form

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

{$I unaDef.inc }

unit u_vc2demo_main;

interface

uses
  Windows, unaTypes, Forms, Controls, StdCtrls, ComCtrls, Classes, ActnList, ExtCtrls, Dialogs, Buttons,
  unaClasses, unaMsAcmClasses, unaWave, Menus;

type
  Tc_form_vc2DemoMain = class(TForm)
    c_groupBox_top: TGroupBox;
    c_groupBox_bottom: TGroupBox;
    c_statusBar_main: TStatusBar;
    c_comboBox_playbackDevice: TComboBox;
    c_comboBox_recordingDevice: TComboBox;
    c_actionList_main: TActionList;
    ac_openOut: TAction;
    ac_closeOut: TAction;
    ac_closeIn: TAction;
    ac_chooseOut: TAction;
    ac_chooseIn: TAction;
    c_staticText_outFormat: TStaticText;
    c_staticText_inFormat: TStaticText;
    c_timer_update: TTimer;
    ac_addChannel: TAction;
    c_progressBar_outLeft: TProgressBar;
    c_progressBar_outRight: TProgressBar;
    c_progressBar_inRight: TProgressBar;
    c_progressBar_inLeft: TProgressBar;
    c_checkBox_saveOut2File: TCheckBox;
    c_edit_waveOutFile: TEdit;
    c_checkBox_saveIn2File: TCheckBox;
    c_edit_waveInFile: TEdit;
    c_sb_waveOutStart: TSpeedButton;
    c_sb_waveOutStop: TSpeedButton;
    c_sb_waveInStart: TSpeedButton;
    c_sb_waveInStop: TSpeedButton;
    ac_openIn: TAction;
    c_sb_waveOutChoose: TSpeedButton;
    c_sb_waveInChoose: TSpeedButton;
    c_sb_waveOutAddWave: TSpeedButton;
    c_speedButton_outFileOpen: TSpeedButton;
    c_speedButton_inFileOpen: TSpeedButton;
    c_saveDialog_main: TSaveDialog;
    c_checkBox_loop2Playback: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ac_openOutExecute(Sender: TObject);
    procedure ac_chooseOutExecute(Sender: TObject);
    procedure ac_closeOutExecute(Sender: TObject);
    procedure ac_openInExecute(Sender: TObject);
    procedure ac_closeInExecute(Sender: TObject);
    procedure ac_chooseInExecute(Sender: TObject);
    procedure c_timer_updateTimer(Sender: TObject);
    procedure ac_addChannelExecute(Sender: TObject);
    procedure c_comboBox_playbackDeviceChange(Sender: TObject);
    procedure c_comboBox_recordingDeviceChange(Sender: TObject);
    procedure c_speedButton_outFileOpenClick(Sender: TObject);
    procedure c_edit_waveOutFileChange(Sender: TObject);
    procedure c_speedButton_inFileOpenClick(Sender: TObject);
    procedure c_edit_waveInFileChange(Sender: TObject);
    procedure c_checkBox_saveOut2FileClick(Sender: TObject);
    procedure c_checkBox_saveIn2FileClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    f_acm: unaMsAcm;
    f_ini: unaIniFile;
    f_waveOutDeviceId: unsigned;
    f_waveOutFormat: unaPCMFormat;
    f_waveInFormat: unaPCMFormat;
    f_waveInDeviceId: unsigned;
    //
    f_waveInFile: string;
    f_waveOutFile: string;
    f_hintColorCount: unsigned;
    f_hintTextCount: unsigned;
    //
    f_playback: unaWaveOutDevice;
    f_recorder: unaWaveInDevice;
    f_mixer: unaWaveMixerDevice;
    f_channels: unaObjectList;
    f_riffOut: unaRiffStream;
    f_riffIn: unaRiffStream;
    f_inOutResampler: unaWaveResampler;
    f_inOutStream: unaAbstractStream;
    //
    procedure createDevices();
    procedure destroyDevices();
    procedure updateVolume(device: unaWaveDevice);
    procedure reEnable(device: unaWaveDevice);
    //
    procedure myOnDA(sender: tObject; data: pointer; size: uint);
  public
    { Public declarations }
    property mixer: unaWaveMixerDevice read f_mixer;
    property playback: unaWaveOutDevice read f_playback;
    property acm: unaMsAcm read f_acm;
    property channels: unaObjectList read f_channels;
    property ini: unaIniFile read f_ini write f_ini;
  end;

var
  c_form_vc2DemoMain: Tc_form_vc2DemoMain;


implementation


{$R *.dfm}

uses
  SysUtils, MMSystem, Graphics, ShellAPI,
  unaUtils, unaMsAcmAPI,
  u_vc2Demo_playChannel;

// --  --
procedure Tc_form_vc2DemoMain.createDevices();
var
  i: int;
  capsOut: WAVEOUTCAPSW;
  capsIn: WAVEINCAPSW;
begin
  f_acm := unaMsAcm.create();
  f_acm.enumDrivers();
  //
  f_playback := unaWaveOutDevice.create(WAVE_MAPPER, false, false, 10);
  with (f_playback) do begin
    setSampling(f_waveOutFormat);
    calcVolume := true;
    c_staticText_outFormat.caption := srcFormatInfo;
  end;
  //
  f_recorder := unaWaveInDevice.create();
  with (f_recorder) do begin
    //
    setSampling(f_waveInFormat);
    assignStream(false, nil);	// remove recorder output stream
    calcVolume := true;
    c_staticText_inFormat.caption := dstFormatInfo;
  end;
  //
  f_mixer := unaWaveMixerDevice.create(true);
  f_mixer.addConsumer(f_playback);
  f_mixer.setSampling(f_waveOutFormat);
  //
  f_channels := unaObjectList.create();
  f_channels.autoFree := false;
  //
  // OUT
  for i := -1 to unaWaveOutDevice.getDeviceCount() - 1 do begin
    //
    unaWaveOutDevice.getCaps(uint(i), capsOut);
    c_comboBox_playbackDevice.items.addObject(capsOut.szPname, pointer(i + 10));
  end;
  if (WAVE_MAPPER = f_waveOutDeviceId) then
    c_comboBox_playbackDevice.itemIndex := 0
  else
    c_comboBox_playbackDevice.itemIndex := min(unsigned(c_comboBox_playbackDevice.items.count) - 1, f_waveOutDeviceId + 1);
  //
  // IN
  for i := -1 to unaWaveInDevice.getDeviceCount() - 1 do begin
    //
    unaWaveInDevice.getCaps(uint(i), capsIn);
    c_comboBox_recordingDevice.items.addObject(capsIn.szPname, pointer(i + 10));
  end;
  if (WAVE_MAPPER = f_waveInDeviceId) then
    c_comboBox_recordingDevice.itemIndex := 0
  else
    c_comboBox_recordingDevice.itemIndex := min(unsigned(c_comboBox_recordingDevice.items.count) - 1, f_waveInDeviceId + 1);
  //
  //
  reEnable(f_playback);
  reEnable(f_recorder);
end;

// --  --
procedure Tc_form_vc2DemoMain.destroyDevices();
begin
  ac_closeOut.Execute();
  ac_closeIn.Execute();
  //
  freeAndNil(f_channels);
  freeAndNil(f_recorder);
  freeAndNil(f_playback);
  freeAndNil(f_mixer);
  freeAndNil(f_acm);
end;

// --  --
procedure Tc_form_vc2DemoMain.FormCreate(Sender: TObject);
begin
  f_ini := unaIniFile.create();

  // OUT
  f_ini.section := 'waveOut';
  f_waveOutDeviceId := f_ini.get('deviceId', WAVE_MAPPER);
  f_waveOutFormat.pcmSamplesPerSecond := f_ini.get('pcmSamplesPerSecond', unsigned(44100));
  f_waveOutFormat.pcmBitsPerSample := f_ini.get('pcmBitsPerSample', unsigned(16));
  f_waveOutFormat.pcmNumChannels := f_ini.get('pcmNumChannels', unsigned(2));
  //
  f_waveOutFile := trimS(f_ini.get('fileName', ''));
  c_edit_waveOutFile.Text := f_waveOutFile;
  c_checkBox_saveOut2File.Checked := f_ini.get('saveToFile', false);

  // IN
  f_ini.section := 'waveIn';
  f_waveInDeviceId := f_ini.get('deviceId', WAVE_MAPPER);
  f_waveInFormat.pcmSamplesPerSecond := f_ini.get('pcmSamplesPerSecond', unsigned(44100));
  f_waveInFormat.pcmBitsPerSample := f_ini.get('pcmBitsPerSample', unsigned(16));
  f_waveInFormat.pcmNumChannels := f_ini.get('pcmNumChannels', unsigned(2));
  //
  f_waveInFile := trimS(f_ini.get('fileName', ''));
  c_edit_waveInFile.Text := f_waveInFile;
  c_checkBox_saveIn2File.Checked := f_ini.get('saveToFile', false);

  //
  createDevices();

  //
  ini.section := 'main';
  c_saveDialog_main.InitialDir := ini.get('initialSaveDir', '.\');
end;

// --  --
procedure Tc_form_vc2DemoMain.FormDestroy(Sender: TObject);
begin
  // OUT
  f_ini.section := 'waveOut';
  f_ini.setValue('deviceId', f_waveOutDeviceId);
  f_ini.setValue('pcmSamplesPerSecond', f_waveOutFormat.pcmSamplesPerSecond);
  f_ini.setValue('pcmBitsPerSample', f_waveOutFormat.pcmBitsPerSample);
  f_ini.setValue('pcmNumChannels', f_waveOutFormat.pcmNumChannels);
  f_ini.setValue('fileName', f_waveOutFile);
  f_ini.setValue('saveToFile', c_checkBox_saveOut2File.Checked);

  // IN
  f_ini.section := 'waveIn';
  f_ini.setValue('deviceId', f_waveInDeviceId);
  f_ini.setValue('pcmSamplesPerSecond', f_waveInFormat.pcmSamplesPerSecond);
  f_ini.setValue('pcmBitsPerSample', f_waveInFormat.pcmBitsPerSample);
  f_ini.setValue('pcmNumChannels', f_waveInFormat.pcmNumChannels);
  f_ini.setValue('fileName', f_waveInFile);
  f_ini.setValue('saveToFile', c_checkBox_saveIn2File.Checked);

  freeAndNil(f_ini);
  //
  destroyDevices();
end;

// --  --
procedure Tc_form_vc2DemoMain.ac_openOutExecute(Sender: TObject);
var
  format: WAVEFORMATEX;
begin
  if (not f_playback.isOpen()) then begin
    //
    f_playback.deviceId := unsigned(int(c_comboBox_playbackDevice.Items.Objects[c_comboBox_playbackDevice.ItemIndex]) - 10);
    //f_playback.mapped := c_checkBox_outMapped.checked;
    //f_playback.direct := c_checkBox_outDirect.checked;
    if (c_checkBox_saveOut2File.Checked) then begin
      //
      fillPCMFormat(format, f_waveOutFormat.pcmSamplesPerSecond, f_waveOutFormat.pcmBitsPerSample, f_waveOutFormat.pcmNumChannels);
      f_riffOut := unaRiffStream.createNew(f_waveOutFile, format);
      f_riffOut.open();
      f_mixer.addConsumer(f_riffOut);
    end;
    f_playback.open();
    f_mixer.open();
  end;
  //
  reEnable(f_playback);
end;

// --  --
procedure Tc_form_vc2DemoMain.ac_chooseOutExecute(Sender: TObject);
var
  format: pWAVEFORMATEX;
begin
  new(format);
  fillPCMFormat(format^, f_waveOutFormat.pcmSamplesPerSecond, f_waveOutFormat.pcmBitsPerSample, f_waveOutFormat.pcmNumChannels);
  if (mmNoError(f_playback.formatChoose(format, 'Choose playback format'))) then begin
    //
    f_waveOutFormat.pcmSamplesPerSecond := format.nSamplesPerSec;
    f_waveOutFormat.pcmBitsPerSample := format.wBitsPerSample;
    f_waveOutFormat.pcmNumChannels := format.nChannels;
    //
    f_playback.setSampling(format);
    f_mixer.setSampling(format);
    c_staticText_outFormat.Caption := f_playback.srcFormatInfo;
  end;
  dispose(format);
end;

// --  --
procedure Tc_form_vc2DemoMain.ac_closeOutExecute(Sender: TObject);
begin
  f_channels.clear(1);
  f_mixer.close();
  f_playback.close();
  freeAndNil(f_riffOut);
  freeAndNil(f_inOutResampler);
  //
  reEnable(f_playback);
end;

// --  --
procedure Tc_form_vc2DemoMain.ac_openInExecute(Sender: TObject);
var
  format: WAVEFORMATEX;
  formatOut: WAVEFORMATEX;
begin
  if (not f_recorder.isOpen()) then begin
    f_recorder.deviceId := unsigned(int(c_comboBox_recordingDevice.items.objects[c_comboBox_recordingDevice.itemIndex]) - 10);
    //f_recorder.mapped := c_checkBox_inMapped.checked;
    //f_recorder.direct := c_checkBox_inDirect.checked;
    //
    fillPCMFormat(format, f_waveInFormat.pcmSamplesPerSecond, f_waveInFormat.pcmBitsPerSample, f_waveInFormat.pcmNumChannels);
    //
    if (c_checkBox_loop2Playback.checked) then begin
      // loop recording to playback (through resampler)
      fillPCMFormat(formatOut, f_waveOutFormat.pcmSamplesPerSecond, f_waveOutFormat.pcmBitsPerSample, f_waveOutFormat.pcmNumChannels);
      //
      f_inOutResampler := unaWaveResampler.create(false);
      with (f_inOutResampler) do begin
	setSampling(true, format);
	setSampling(false, formatOut);
	onDataAvailable := myOnDA;
	assignStream(false, nil);
      end;
      //
      f_recorder.addConsumer(f_inOutResampler);
      //
      f_inOutStream := mixer.addStream();
      //
      f_inOutResampler.open();
    end;
    //
    if (c_checkBox_saveIn2File.Checked) then begin
      //
      f_riffIn := unaRiffStream.createNew(f_waveInFile, format);
      f_riffIn.open();
      f_recorder.addConsumer(f_riffIn);
    end;
    f_recorder.open();
  end;
  //
  reEnable(f_recorder);
end;

// --  --
procedure Tc_form_vc2DemoMain.ac_closeInExecute(Sender: TObject);
begin
  f_recorder.close();
  freeAndNil(f_inOutResampler);
  freeandNil(f_riffIn);
  //
  if (nil <> f_inOutStream) then
    mixer.removeStream(f_inOutStream);
  //
  f_inOutStream := nil;
  //
  reEnable(f_recorder);
end;

// --  --
procedure Tc_form_vc2DemoMain.ac_chooseInExecute(Sender: TObject);
var
  format: pWAVEFORMATEX;
begin
  new(format);
  fillPCMFormat(format^, f_waveInFormat.pcmSamplesPerSecond, f_waveInFormat.pcmBitsPerSample, f_waveInFormat.pcmNumChannels);
  if (mmNoError(f_recorder.formatChoose(format, 'Choose recording format'))) then begin
    //
    f_waveInFormat.pcmSamplesPerSecond := format.nSamplesPerSec;
    f_waveInFormat.pcmBitsPerSample := format.wBitsPerSample;
    f_waveInFormat.pcmNumChannels := format.nChannels;
    //
    f_recorder.setSampling(format);
    c_staticText_inFormat.Caption := f_recorder.dstFormatInfo;
  end;
  dispose(format);
end;

// --  --
procedure Tc_form_vc2DemoMain.c_timer_updateTimer(Sender: TObject);
begin
  c_statusBar_main.Panels[0].text := 'Mem: ' + int2str(ams() shr 10, 10, 3) + ' KB';
  //
  updateVolume(f_playback);
  updateVolume(f_recorder);
  //
  inc(f_hintColorCount);
  inc(f_hintTextCount, 3);
end;

// --  --
procedure Tc_form_vc2DemoMain.About1Click(Sender: TObject);
begin
  shellExecute(handle, 'open', 'http://lakeofsoft.com/vc/a_asampler.html', nil, nil, SW_SHOWNORMAL);
end;

// --  --
procedure Tc_form_vc2DemoMain.ac_addChannelExecute(Sender: TObject);
var
  channel: Tc_form_playbackChannel;
begin
  channel := Tc_form_playbackChannel.create(nil);
  channel.Top := channel.Top + int(f_channels.count) * 20;
  channel.Left := channel.Left + int(f_channels.count) * 20;
  channel.c_groupBox_main.Caption := ' Channel #' + int2str(f_channels.count) + ' ';
  f_channels.Add(channel);
  channel.Show();
end;

// --  --
procedure Tc_form_vc2DemoMain.updateVolume(device: unaWaveDevice);
var
  posLeft: unsigned;
  posRight: unsigned;
begin
  if (nil <> device) then begin
    //
    if (device.isOpen) then begin
      posLeft := device.getVolume(0);
      posRight := device.getVolume(1);
    end
    else begin
      posLeft := 0;
      posRight := 0;
    end;
    //
    if (device is unaWaveOutDevice) then begin
      //
      c_progressBar_outLeft.position := waveGetLogVolume(posLeft);
      c_progressBar_outRight.position := waveGetLogVolume(posRight);
    end
    else begin
      //
      c_progressBar_inLeft.Position := waveGetLogVolume(posLeft);
      c_progressBar_inRight.Position := waveGetLogVolume(posRight);
    end;
    //
  end;
end;

// --  --
procedure Tc_form_vc2DemoMain.reEnable(device: unaWaveDevice);
var
  isOpen: bool;
begin
  isOpen := device.isOpen();
  if (device is unaWaveOutDevice) then begin
    //
    ac_openOut.Enabled := not isOpen;
    ac_closeOut.Enabled := isOpen;
    ac_chooseOut.Enabled := not isOpen;
    ac_addChannel.Enabled := isOpen;
    c_comboBox_playbackDevice.Enabled := not isOpen;
    //c_checkBox_outDirect.Enabled := not isOpen;
    //c_checkBox_outMapped.Enabled := not isOpen;
    c_checkBox_saveOut2File.Enabled := not isOpen;
    c_edit_waveOutFile.Enabled := not isOpen;
    c_speedButton_outFileOpen.Enabled := not isOpen;
    c_checkBox_loop2Playback.Enabled := isOpen and not f_recorder.isOpen();
    if (not c_checkBox_loop2Playback.Enabled) then
      c_checkBox_loop2Playback.Checked := false;
  end
  else begin
    //
    ac_openIn.Enabled := not isOpen;
    ac_closeIn.Enabled := isOpen;
    ac_chooseIn.Enabled := not isOpen;
    c_comboBox_recordingDevice.Enabled := not isOpen;
    //c_checkBox_inDirect.Enabled := not isOpen;
    //c_checkBox_inMapped.Enabled := not isOpen;
    c_checkBox_saveIn2File.Enabled := not isOpen;
    c_edit_waveInFile.Enabled := not isOpen;
    c_speedButton_inFileOpen.Enabled := not isOpen;
    c_checkBox_loop2Playback.Enabled := not isOpen and f_playback.isOpen();
  end;
end;

// --  --
procedure Tc_form_vc2DemoMain.c_comboBox_playbackDeviceChange(Sender: TObject);
begin
  f_waveOutDeviceId := unsigned(c_comboBox_playbackDevice.ItemIndex - 1);
end;

// --  --
procedure Tc_form_vc2DemoMain.c_comboBox_recordingDeviceChange(Sender: TObject);
begin
  f_waveInDeviceId := unsigned(c_comboBox_recordingDevice.ItemIndex - 1);
end;

// --  --
procedure Tc_form_vc2DemoMain.c_speedButton_outFileOpenClick(Sender: TObject);
begin
  if (c_saveDialog_main.Execute) then begin
    //
    f_waveOutFile := c_saveDialog_main.FileName;
    c_edit_waveOutFile.Text := f_waveOutFile;
    ini.section := 'main';
    ini.setValue('initialSaveDir', extractFilePath(f_waveOutFile));
  end;
end;

// --  --
procedure Tc_form_vc2DemoMain.c_edit_waveOutFileChange(Sender: TObject);
begin
  f_waveOutFile := c_edit_waveOutFile.Text;
  c_checkBox_saveOut2File.Checked := ('' <> trim(f_waveOutFile));
end;

// --  --
procedure Tc_form_vc2DemoMain.c_speedButton_inFileOpenClick(Sender: TObject);
begin
  if (c_saveDialog_main.Execute) then begin
    //
    f_waveInFile := c_saveDialog_main.FileName;
    c_edit_waveInFile.Text := f_waveInFile;
    ini.section := 'main';
    ini.setValue('initialSaveDir', extractFilePath(f_waveInFile));
  end;
end;

// --  --
procedure Tc_form_vc2DemoMain.c_edit_waveInFileChange(Sender: TObject);
begin
  f_waveInFile := c_edit_waveInFile.Text;
  c_checkBox_saveIn2File.Checked := ('' <> f_waveInFile);
end;

// --  --
procedure Tc_form_vc2DemoMain.myOnDA(sender: tObject; data: pointer; size: uint);
begin
  // put data from resampler to stream
  if (nil <> f_inOutStream) then
    f_inOutStream.write(data, size);
end;

// --  --
procedure Tc_form_vc2DemoMain.c_checkBox_saveOut2FileClick(Sender: TObject);
begin
  if (c_checkBox_saveOut2File.Checked and ('' = trim(c_edit_waveOutFile.Text))) then begin
    //
    c_checkBox_saveOut2File.Checked := false;
    c_speedButton_outFileOpenClick(nil);
  end;
end;

// --  --
procedure Tc_form_vc2DemoMain.c_checkBox_saveIn2FileClick(Sender: TObject);
begin
  if (c_checkBox_saveIn2File.Checked and ('' = trim(c_edit_waveInFile.Text))) then begin
    //
    c_checkBox_saveIn2File.Checked := false;
    c_speedButton_inFileOpenClick(nil);
  end;
end;

// --  --
procedure Tc_form_vc2DemoMain.Exit1Click(Sender: TObject);
begin
  close();
end;


end.

