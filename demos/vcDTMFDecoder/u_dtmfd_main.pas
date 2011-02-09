
(*
	----------------------------------------------

	  u_dtmfd_main.pas - DTMF decoder demo main form
	  Voice Communicator components version 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2007-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 05 Jun 2007

	  modified by:
		Lake, Jun 2007

	----------------------------------------------
*)

{$I unaDef.inc}

unit
  u_dtmfd_main;

interface

uses
  Windows, unaTypes, unaClasses, unaDspControls,
  Forms, StdCtrls, ExtCtrls, unaVCIDE, Dialogs, ComCtrls, Controls, Classes,
  Menus, unaVC_wave, unaVC_pipe;

type
  Tc_form_main = class(TForm)
    Label1: TLabel;
    //
    c_label_fileName: TLabel;
    //
    c_cb_source: TComboBox;
    c_cb_loop: TCheckBox;
    //
    c_button_start: TButton;
    c_button_stop: TButton;
    c_pb_file: TProgressBar;
    //
    c_sb_main: TStatusBar;
    //
    waveIn: TunavclWaveInDevice;
    waveRiff: TunavclWaveRiff;
    //
    c_od_file: TOpenDialog;
    c_timer_update: TTimer;
    c_memo_output: TMemo;
    c_button_clear: TButton;
    c_tb_threshold: TTrackBar;
    Label2: TLabel;
    Label3: TLabel;
    vcDTMFDecoder: TunavclDTMFDecoder;
    c_mm_main: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    //
    procedure formCreate(sender: tObject);
    procedure formDestroy(sender: tObject);
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    procedure formShow(sender: tObject);
    //
    procedure c_button_startClick(Sender: TObject);
    procedure c_button_stopClick(Sender: TObject);
    //
    procedure c_cb_sourceChange(Sender: TObject);
    procedure c_cb_loopClick(Sender: TObject);
    //
    procedure c_timer_updateTimer(Sender: TObject);
    //
    procedure waveRiffStreamIsDone(sender: TObject);
    procedure c_button_clearClick(Sender: TObject);
    //
    procedure waveDataAvailable(sender: unavclInOutPipe; data: Pointer; len: Cardinal);
    procedure c_tb_thresholdChange(Sender: TObject);
    //
    procedure vcDTMFDecoderDTMFCodeDetected(sender: TObject; code: Char;const param: Single);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    f_config: unaIniFile;
    f_streamDone: bool;
    f_totalBytes: int64;
    //
    f_addText: string;
  public
    { Public declarations }
  end;

var
  c_form_main: Tc_form_main;


implementation


{$R *.dfm}

uses
  unaDsp,	// some constants
  unaUtils, unaVCLUtils, unaVCIDEUtils, ShellAPI;


{ Tc_form_main }

// --  --
procedure Tc_form_main.formCreate(sender: tObject);
var
  inputIsFile: bool;
begin
  f_config := unaIniFile.create();
  //
  enumWaveDevices(c_cb_source, true, false);
  //
  c_cb_source.items.addObject('Load audio from a *.WAV file...', pointer($666));
  //
  c_cb_source.itemIndex := f_config.get('input.index', int(0));
  //
  inputIsFile := ((0 <= c_cb_source.itemIndex) and (pointer($666) = c_cb_source.items.objects[c_cb_source.itemIndex]));
  //
  c_label_fileName.caption := f_config.get('input.fileName', '');
  c_cb_loop.checked := f_config.get('input.file.loop', false);
  //
  c_pb_file.visible := inputIsFile and fileExists(c_label_fileName.caption);
  c_label_fileName.visible := inputIsFile;
  c_cb_loop.visible := inputIsFile;
  //
  c_tb_threshold.position := f_config.get('decoder.threshold', int(c_def_dtmfd_LVS)) div 10;
end;

// --  --
procedure Tc_form_main.formDestroy(sender: tObject);
begin
  freeAndNil(f_config);
end;

// --  --
procedure Tc_form_main.formShow(sender: tObject);
begin
  loadControlPosition(self, f_config);
end;

// --  --
procedure Tc_form_main.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  c_timer_update.enabled := false;
  //
  waveIn.close();	// stop processing
  waveRiff.close();
  //
  f_config.setValue('input.fileName', c_label_fileName.caption);
  f_config.setValue('input.file.loop', c_cb_loop.checked);
  //
  f_config.setValue('input.index', c_cb_source.itemIndex);
  //
  f_config.setValue('decoder.threshold', c_tb_threshold.position * 10);
  //
  saveControlPosition(self, f_config);
end;

// --  --
procedure Tc_form_main.c_button_startClick(Sender: TObject);
var
  i: int;
begin
  c_button_start.enabled := false;
  c_button_stop.enabled := true;
  //
  waveIn.close();	// just in case
  waveRiff.close();
  //
  f_totalBytes := 0;
  f_streamDone := false;
  //
  f_addText := '';
  //
  vcDTMFDecoder.threshold := c_tb_threshold.position * 10;	// synch GUI with values
  //
  i := c_cb_source.itemIndex;
  if ((0 <= i) and (pointer($666) = c_cb_source.items.objects[i])) then begin
    //
    waveRiff.fileName := c_label_fileName.caption;
    waveRiff.loop := c_cb_loop.checked;
    //
    vcDTMFDecoder.pcmFormatExt := waveRiff.device.srcFormatExt;
    //
    c_pb_file.visible := true;
    c_pb_file.max := waveRiff.waveStream.streamSize;
    //
    waveRiff.open();
  end
  else begin
    //
    waveIn.deviceId := index2deviceId(c_cb_source);
    waveIn.clearFormatCRC();	// force waveIn to update consumer's format
    //
    vcDTMFDecoder.pcmFormatExt := waveIn.pcmFormatExt;
    //
    waveIn.open();
  end;
  //
  c_timer_update.enabled := true;
end;

// --  --
procedure Tc_form_main.c_button_stopClick(Sender: TObject);
begin
  c_button_start.enabled := true;
  c_button_stop.enabled := false;
  //
  c_timer_update.enabled := false;
  //
  waveIn.close();
  waveRiff.close();
  //
  c_sb_main.panels[1].text := 'Stopped. ' + c_sb_main.panels[1].text;
end;

// --  --
procedure Tc_form_main.c_cb_sourceChange(Sender: TObject);
var
  i: int;
begin
  i := c_cb_source.itemIndex;
  if ((0 <= i) and (pointer($666) = c_cb_source.items.objects[i])) then begin
    //
    if (c_od_file.execute()) then begin
      //
      if (fileExists(c_od_file.fileName) and (c_label_fileName.caption <> c_od_file.fileName)) then
	c_button_stop.click();
      //
      c_label_fileName.caption := c_od_file.fileName;
    end;
    //
    c_pb_file.visible := fileExists(c_label_fileName.caption);
    c_label_fileName.visible := c_pb_file.visible;
    c_cb_loop.visible := c_pb_file.visible;
  end
  else begin
    //
    c_label_fileName.visible := false;
    c_pb_file.visible := false;
    c_cb_loop.visible := false;
    //
    c_button_stop.click();
  end;
end;

// --  --
procedure Tc_form_main.c_timer_updateTimer(Sender: TObject);
begin
  c_sb_main.panels[1].text := 'Bytes processed: ' + int2str(f_totalBytes, 10, 3);
  //
  if (c_pb_file.visible) then
    c_pb_file.position := waveRiff.waveStream.streamPosition;
  //
  {$IFDEF DEBUG }
  c_sb_main.panels[0].text := 'Mem: ' + int2str(ams() shr 10, 10, 3) + ' KB';
  {$ENDIF DEBUG }
  //
  if (f_streamDone) then
    c_button_stop.click();
  //
  if (vcDTMFDecoder.enter(true, 20)) then begin
    //
    try
      if ('' <> f_addText) then
	c_memo_output.text := c_memo_output.text + f_addText;
      //
      f_addText := '';
    finally
      vcDTMFDecoder.leaveRO();
    end;
  end;
end;

// --  --
procedure Tc_form_main.waveRiffStreamIsDone(sender: TObject);
begin
  f_streamDone := true;
end;

// --  --
procedure Tc_form_main.c_cb_loopClick(Sender: TObject);
begin
  waveRiff.loop := c_cb_loop.checked;
end;

// --  --
procedure Tc_form_main.c_button_clearClick(Sender: TObject);
begin
  c_memo_output.clear();
end;

// --  --
procedure Tc_form_main.waveDataAvailable(sender: unavclInOutPipe; data: Pointer; len: Cardinal);
begin
  if (len = vcDTMFDecoder.write(data, len)) then
    inc(f_totalBytes, len);
end;

// --  --
procedure Tc_form_main.c_tb_thresholdChange(Sender: TObject);
begin
  vcDTMFDecoder.threshold := c_tb_threshold.position * 10;
  Label3.caption := int2str(vcDTMFDecoder.threshold);
end;

// --  --
procedure Tc_form_main.vcDTMFDecoderDTMFCodeDetected(sender: TObject; code: Char; const param: Single);
begin
  if (vcDTMFDecoder.enter(true, 200)) then begin
    //
    try
      f_addText := f_addText + code;
    finally
      vcDTMFDecoder.leaveRO();
    end;
  end;
end;

// --  --
procedure Tc_form_main.Exit1Click(Sender: TObject);
begin
  close();
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  shellExecute(0, 'open', 'http://lakeofsoft.com/vc/a_dualtonemultifrequencydecode.html', nil, nil, SW_SHOWNORMAL);
end;


end.

