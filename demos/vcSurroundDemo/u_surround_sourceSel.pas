
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
  u_surround_sourceSel;

interface

uses
  Windows, unaTypes, unaClasses,
  Forms, StdCtrls, Controls, Classes, Dialogs, CheckLst, ComCtrls;

const
  //
  cuna_stype_live	= 100;
  cuna_stype_wave	= 101;
  cuna_stype_sine	= 102;

type
  // -- unaAudioSource --
  unaAudioSource = class(unaObject)
  private
    f_param: string;
    f_stype: int;
    //
    f_samplingRate: unsigned;
    f_byteRate: unsigned;
    f_name: string;
    f_mapping: DWORD;
    //
    f_chunk: pInt16Array;
    f_chunkSizeInSamples: unsigned;
    f_chunkWasTaken: bool;
    //
    procedure setSamplingRate(value: unsigned);
    function isActive(): bool;
  protected
    procedure updateSamplingRate(value: unsigned); virtual; abstract;
    function getIsActive(): bool; virtual; abstract;
    //
    procedure doOpen(); virtual; abstract;
    procedure doClose(); virtual; abstract;
    function doFillChunk(data: pInt16Array; numSamples, stepInSamples: unsigned): bool; virtual;
    procedure doPrepareNextChunk(); virtual; abstract;
  public
    constructor create(stype: int; const param: string);
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
    //
    procedure open();
    procedure close();
    //
    function fillChunk(data: pInt16Array; numSamples, stepInSamples: unsigned): bool;
    procedure prepareNextChunk();

    //
    property stype: int read f_stype;
    property param: string read f_param;
    property rate: unsigned read f_samplingRate write setSamplingRate;
    property active: bool read isActive;
    property name: string read f_name;
    property mapping: DWORD read f_mapping write f_mapping;
  end;


  //
  Tc_form_sourceManage = class(TForm)
    c_button_OK: TButton;
    c_rb_srcLive: TRadioButton;
    c_cb_liveIndex: TComboBox;
    c_rb_srcWave: TRadioButton;
    c_edit_waveFile: TEdit;
    c_button_waveFileSel: TButton;
    c_rb_srcSine: TRadioButton;
    c_edit_freq: TEdit;
    c_label_rate: TLabel;
    c_od_wave: TOpenDialog;
    c_lb_sources: TListBox;
    c_sb_main: TStatusBar;
    c_button_srcAdd: TButton;
    c_button_srcDrop: TButton;
    c_clb_speakers: TCheckListBox;
    c_label_map: TLabel;
    //
    procedure formCreate(sender: tObject);
    procedure formDestroy(sender: tObject);
    procedure c_button_waveFileSelClick(Sender: TObject);
    procedure c_cb_liveIndexChange(Sender: TObject);
    procedure c_edit_freqChange(Sender: TObject);
    procedure c_button_srcAddClick(Sender: TObject);
    procedure c_lb_sourcesClick(Sender: TObject);
    procedure c_clb_speakersClickCheck(Sender: TObject);
    procedure c_button_srcDropClick(Sender: TObject);
  private
    { Private declarations }
    f_source: unaObjectList;
    f_samplingRate: int;
    //
    function getSource(index: int): unaAudioSource;
    function getSourceCount(): int;
    //
    procedure mapMask2GUI();
    procedure mapGUI2mask();
  public
    { Public declarations }
    function manageSources(): bool;
    procedure updatePresence();
    //
    procedure setSamplingRate(rate: int);
    procedure openSources();
    procedure closeSources();
    //
    procedure prepareNextChunk();
    function contributeSource(speaker, sourceIndex: int; data: pInt16Array; numSamples: unsigned; stepInSamples: unsigned): bool;
    //
    function addSource(stype: int; const param: string; mask: DWORD): unaAudioSource;
    //
    property source[index: int]: unaAudioSource read getSource;
    property sourceCount: int read getSourceCount;
  end;

var
  c_form_sourceManage: Tc_form_sourceManage;


implementation


{$R *.dfm}

uses
  unaUtils, unaMsAcmClasses,
  unaVcIDEutils,
  u_surround_main;


type
  //
  unaASLive = class(unaAudioSource)
  private
    f_waveIn: unaWaveInDevice;
    f_subChunk: pointer;
    //
    procedure onWaveDA(sender: tObject; data: pointer; size: uint);
  protected
    procedure updateSamplingRate(value: unsigned); override;
    function getIsActive(): bool; override;
    procedure doOpen(); override;
    procedure doClose(); override;
    procedure doPrepareNextChunk(); override;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
  end;

  //
  unaASWAV = class(unaAudioSource)
  private
    f_riff: unaRiffStream;
  protected
    procedure updateSamplingRate(value: unsigned); override;
    function getIsActive(): bool; override;
    procedure doOpen(); override;
    procedure doClose(); override;
    procedure doPrepareNextChunk(); override;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
  end;

  //
  unaASSine = class(unaAudioSource)
  private
    f_freq: int;
    f_isActive: bool;
    //
    f_angle: real;
    f_turn: real;
    f_2_pi: real;
  protected
    procedure updateSamplingRate(value: unsigned); override;
    function getIsActive(): bool; override;
    procedure doOpen(); override;
    procedure doClose(); override;
    procedure doPrepareNextChunk(); override;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
  end;



{ unaAudioSource }

// --  --
procedure unaAudioSource.AfterConstruction();
begin
  rate := c_form_sourceManage.f_samplingRate;
  //
  inherited;
end;

// --  --
procedure unaAudioSource.BeforeDestruction();
begin
  close();
  //
  inherited;
  //
  mrealloc(f_chunk);
end;

// --  --
procedure unaAudioSource.close();
begin
  doClose();
end;

// --  --
constructor unaAudioSource.create(stype: int; const param: string);
begin
  f_param := param;
  f_stype := stype;
  //
  inherited create();
end;

// --  --
function unaAudioSource.doFillChunk(data: pInt16Array; numSamples, stepInSamples: unsigned): bool;
var
  count: unsigned;
  nsSrc, nsDst: pSmallInt;
begin
  count := 0;
  nsSrc := @f_chunk[0];
  nsDst := @data[0];
  while (count < min(f_chunkSizeInSamples, numSamples)) do begin
    //
    nsDst^ := smallInt( (int(nsDst^) + int(nsSrc^)) and $FFFF );	// mix, clipping may apply
    //
    inc(nsSrc);
    inc(nsDst, stepInSamples);
    //
    inc(count);
  end;
  //
  result := true;
  //
  f_chunkWasTaken := result;
end;

// --  --
function unaAudioSource.fillChunk(data: pInt16Array; numSamples, stepInSamples: unsigned): bool;
begin
  result := doFillChunk(data, numSamples, stepInSamples);
end;

// --  --
function unaAudioSource.isActive(): bool;
begin
  result := getIsActive();
end;

// --  --
procedure unaAudioSource.open();
begin
  doOpen();
  //
  f_chunkWasTaken := isActive;	// pretend our last chunk was used by someone (if we are active)
end;

// --  --
procedure unaAudioSource.prepareNextChunk();
begin
  if (f_chunkWasTaken) then
    doPrepareNextChunk();	// do prepare only our buffer was used
  //
  f_chunkWasTaken := false;	// mark buffer was not taken by any speaker yet
end;

// --  --
procedure unaAudioSource.setSamplingRate(value: unsigned);
begin
  if (f_samplingRate <> value) then begin
    //
    close();
    //
    f_samplingRate := value;
    f_byteRate := f_samplingRate shl 1;	// 16 bit
    //
    f_chunkSizeInSamples := (f_byteRate div c_defChunksPerSecond) shr 1;	// 16 bit
    mrealloc(f_chunk, f_chunkSizeInSamples shl 1);
    fillChar(f_chunk^, f_chunkSizeInSamples shl 1, #0);
    //
    updateSamplingRate(value);
  end;
end;


{ unaASLive }

// --  --
procedure unaASLive.AfterConstruction();
var
  index: int;
begin
  f_waveIn := unaWaveInDevice.create(DWORD(str2intInt(f_param, -1)));
  f_waveIn.onDataAvailable := onWaveDA;
  f_waveIn.assignStream(false, nil, false);	// we do not need output stream from waveIn
  //
  index := deviceId2index(str2intInt(f_param));
  f_name := 'Live from ' + c_form_sourceManage.c_cb_liveIndex.items[index];
  //
  inherited;
end;

// --  --
procedure unaASLive.BeforeDestruction();
begin
  inherited;
  //
  mrealloc(f_subChunk);
  freeAndNil(f_waveIn);
end;

// --  --
procedure unaASLive.doClose();
begin
  f_waveIn.close();
end;

// --  --
procedure unaASLive.doOpen();
begin
  f_waveIn.open();
end;

// --  --
procedure unaASLive.doPrepareNextChunk();
var
  swap: pointer;
begin
  if (acquire(false, 10)) then try
    // swap chunk buffers
    swap := f_chunk;
    f_chunk := f_subChunk;
    f_subChunk := swap;
    //
  finally
    release({$IFDEF DEBUG }false{$ENDIF DEBUG });
  end;
end;

// --  --
function unaASLive.getIsActive(): bool;
begin
  result := f_waveIn.isOpen();
end;

// --  --
procedure unaASLive.onWaveDA(sender: tObject; data: pointer; size: uint);
begin
  size := min(size, f_chunkSizeInSamples shl 1);
  if ((0 < size) and (acquire(false, 20))) then try
    //
    move(data^, f_subChunk^, size);
  finally
    release({$IFDEF DEBUG }false{$ENDIF DEBUG });
  end;
end;

// --  --
procedure unaASLive.updateSamplingRate(value: unsigned);
begin
  f_waveIn.setSampling(value, 16, 1);
  //
  mrealloc(f_subChunk, f_chunkSizeInSamples shl 1);
  fillChar(f_subChunk^, f_chunkSizeInSamples shl 1, #0);
end;


{ unaASWAV }

// --  --
procedure unaASWAV.AfterConstruction();
begin
  f_riff := unaRiffStream.create(f_param, false, true, c_form_main.waveOut.acm2);
  f_riff.loop := true;
  //f_riff.
  //
  f_name := 'WAVE file [' + f_param + ']';
  //
  inherited;
end;

// --  --
procedure unaASWAV.BeforeDestruction();
begin
  inherited;
  //
  freeAndNil(f_riff);
end;

// --  --
procedure unaASWAV.doClose();
begin
  f_riff.close();
end;

// --  --
procedure unaASWAV.doOpen();
begin
  f_riff.passiveOpen();	// we will read from file manually
end;

// --  --
procedure unaASWAV.doPrepareNextChunk();
begin
  f_riff.readData(f_chunk, f_chunkSizeInSamples shl 1);
end;

// --  --
function unaASWAV.getIsActive(): bool;
begin
  result := f_riff.isOpen();
end;

// --  --
procedure unaASWAV.updateSamplingRate(value: unsigned);
begin
  // not much here
end;


{ unaASSine }

// --  --
procedure unaASSine.AfterConstruction();
begin
  f_freq := str2intInt(f_param, 4000);
  //
  f_name := 'Sine, freq=' + f_param + ' Hz';
  f_2_pi := 2 * pi;
  //
  inherited;
end;

// --  --
procedure unaASSine.BeforeDestruction();
begin
  inherited;
  //
end;

// --  --
procedure unaASSine.doClose();
begin
  f_isActive := false;
end;

// --  --
procedure unaASSine.doOpen();
begin
  f_isActive := true;
end;

// --  --
procedure unaASSine.doPrepareNextChunk();
var
  i: int;
begin
  // fill the buffer with sine
  for i := 0 to f_chunkSizeInSamples - 1 do begin
    //
    f_chunk[i] := round($2FFF * sin(f_angle));
    f_angle := f_angle + f_turn;
  end;
  //
  while (f_angle > f_2_pi) do
    f_angle := f_angle - f_2_pi;
end;

// --  --
function unaASSine.getIsActive(): bool;
begin
  result := f_isActive;
end;

// --  --
procedure unaASSine.updateSamplingRate(value: unsigned);
begin
  f_turn := f_freq * pi / value;
end;



{ Tc_form_sourceSel }

// --  --
procedure Tc_form_sourceManage.formCreate(sender: tObject);
var
  i: int;
begin
  f_source := unaObjectList.create();
  //
  enumWaveDevices(c_cb_liveIndex);
  c_cb_liveIndex.itemIndex := 0;
  //
  for i := 0 to cuna_max_channels - 1 do
    c_clb_speakers.items.add(v_speaker_name_mask_cb[i].r_name);
end;

// --  --
procedure Tc_form_sourceManage.updatePresence();
var
  i: int;
begin
  for i := 0 to cuna_max_channels - 1 do
    c_clb_speakers.items[i] := v_speaker_name_mask_cb[i].r_name + choice(c_form_main.mappedTo(c_form_main.waveOut.pcm_channelMask, i), ' /present/', '');
end;

// --  --
procedure Tc_form_sourceManage.formDestroy(sender: tObject);
begin
  freeAndNil(f_source);
end;

// --  --
function Tc_form_sourceManage.getSource(index: int): unaAudioSource;
begin
  result := f_source[index];
end;

// --  --
function Tc_form_sourceManage.getSourceCount(): int;
begin
  result := int(f_source.count);
end;

// --  --
function Tc_form_sourceManage.manageSources(): bool;
begin
  result := (mrOK = showModal());
end;

// --  --
procedure Tc_form_sourceManage.c_button_waveFileSelClick(Sender: TObject);
begin
  c_od_wave.InitialDir := extractFilePath(c_edit_waveFile.text);
  if (c_od_wave.execute()) then begin
    //
    c_edit_waveFile.text := c_od_wave.fileName;
    c_rb_srcWave.checked := true;
  end;
end;

// --  --
procedure Tc_form_sourceManage.c_cb_liveIndexChange(Sender: TObject);
begin
  c_rb_srcLive.checked := true;
end;

// --  --
procedure Tc_form_sourceManage.c_edit_freqChange(Sender: TObject);
begin
  c_rb_srcSine.checked := true;
end;

// --  --
procedure Tc_form_sourceManage.c_button_srcAddClick(Sender: TObject);
var
  stype: int;
  param: string;
begin
  if (c_rb_srcLive.checked) then begin
    //
    stype := cuna_stype_live;
    param := int2str(index2deviceId(c_cb_liveIndex));
  end
  else begin
    //
    if (c_rb_srcWave.checked) then begin
      //
      stype := cuna_stype_wave;
      param := c_edit_waveFile.text;
    end
    else begin
      //
      if (c_rb_srcSine.checked) then begin
	//
	stype := cuna_stype_sine;
	param := c_edit_freq.text;
      end
      else
	stype := -1;
    end;
  end;
  //
  if (0 < stype) then
    addSource(stype, param, 0);
end;

// --  --
function Tc_form_sourceManage.addSource(stype: int; const param: string; mask: DWORD): unaAudioSource;
begin
  case (stype) of

    cuna_stype_live: result := unaASLive.create(cuna_stype_live, param);
    cuna_stype_wave: result := unaASWAV.create (cuna_stype_wave, c_edit_waveFile.text);
    cuna_stype_sine: result := unaASSine.create(cuna_stype_sine, c_edit_freq.text);
    else
		     result := nil;
  end;
  //
  if (nil <> result) then begin
    //
    result.mapping := mask;
    f_source.add(result);
    c_lb_sources.items.add(result.name);
    c_lb_sources.itemIndex := c_lb_sources.items.count - 1;
    //
    mapMask2GUI();
  end;  
end;


// --  --
procedure Tc_form_sourceManage.c_lb_sourcesClick(Sender: TObject);
begin
  mapMask2GUI();
end;

// --  --
procedure Tc_form_sourceManage.mapMask2GUI();
var
  i: int;
  src: unaAudioSource;
begin
  if (0 <= c_lb_sources.itemIndex) then begin
    //
    src := source[c_lb_sources.itemIndex];
    if (nil <> src) then begin
      //
      for i := 0 to cuna_max_channels - 1 do
	c_clb_speakers.checked[i] := (0 <> (v_speaker_name_mask_cb[i].r_mask and src.mapping));
    end;
  end
  else
    for i := 0 to cuna_max_channels - 1 do
      c_clb_speakers.checked[i] := false;
end;

// --  --
procedure Tc_form_sourceManage.c_clb_speakersClickCheck(Sender: TObject);
begin
  if (0 <= c_lb_sources.itemIndex) then
    mapGUI2mask();
end;

// --  --
procedure Tc_form_sourceManage.mapGUI2mask();
var
  i: int;
  src: unaAudioSource;
begin
  if (0 <= c_lb_sources.itemIndex) then begin
    //
    src := source[c_lb_sources.itemIndex];
    if (nil <> src) then begin
      //
      src.mapping := 0;
      for i := 0 to cuna_max_channels - 1 do
	if (c_clb_speakers.checked[i]) then
	  src.mapping := src.mapping or v_speaker_name_mask_cb[i].r_mask;
    end;
  end;
end;


// --  --
procedure Tc_form_sourceManage.setSamplingRate(rate: int);
var
  i: int;
begin
  f_samplingRate := rate;
  c_label_rate.caption := 'Sampling Rate: ' + int2str(rate) + ' Hz';
  //
  for i := 0 to sourceCount - 1 do
    source[i].rate := rate;
end;

// --  --
procedure Tc_form_sourceManage.closeSources();
var
  i: int;
begin
  for i := 0 to sourceCount - 1 do
    source[i].close();
end;

// --  --
procedure Tc_form_sourceManage.openSources();
var
  i: int;
begin
  for i := 0 to sourceCount - 1 do
    source[i].open();
  //
  prepareNextChunk();	// tell sources to prepare new chunk
end;

// --  --
function Tc_form_sourceManage.contributeSource(speaker, sourceIndex: int; data: pInt16Array; numSamples, stepInSamples: unsigned): bool;
var
  src: unaAudioSource;
begin
  result := false;
  if (0 <= speaker) then begin
    //
    src := self.source[sourceIndex];
    if (nil <> src) then begin
      //
      if (0 <> (v_speaker_name_mask_cb[speaker].r_mask and src.mapping)) then
	result := src.fillChunk(data, numSamples, stepInSamples);
    end;
  end;
end;

// --  --
procedure Tc_form_sourceManage.prepareNextChunk();
var
  i: int;
begin
  for i := 0 to sourceCount - 1 do
    source[i].prepareNextChunk();	//
end;

// --  --
procedure Tc_form_sourceManage.c_button_srcDropClick(Sender: TObject);
var
  index: int;
begin
  index := c_lb_sources.itemIndex;
  if (0 <= index) then begin
    //
    f_source.removeByIndex(index);
    c_lb_sources.items.delete(index);
    //
    c_lb_sources.itemIndex := min(c_lb_sources.items.count - 1, max(0, index - 1));
    mapMask2GUI();
  end;
end;


end.

