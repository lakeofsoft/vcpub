
(*
	----------------------------------------------

	  u_channelSep_main.pas
	  vcChannelSep demo application - main form source

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 10 Jan 2003

	  modified by:
		Lake, Jan 2003
		Lake, May 2009

	----------------------------------------------
*)

{$I unaDef.inc}

unit
  u_channelSep_main;

interface

uses
  Windows, Forms, unaVcIDE, Controls, StdCtrls, Classes, ExtCtrls, ComCtrls,
  Menus, unaVC_wave, unaVC_pipe;

type
  Tc_form_main = class(TForm)
    waveIn1: TunavclWaveInDevice;
    waveOut1: TunavclWaveOutDevice;
    c_rb_left: TRadioButton;
    c_rb_right: TRadioButton;
    Label1: TLabel;
    c_statusBar_main: TStatusBar;
    Timer1: TTimer;
    Bevel1: TBevel;
    Label2: TLabel;
    Bevel2: TBevel;
    Label3: TLabel;
    b_start_2: TButton;
    b_stop_2: TButton;
    b_stop_1: TButton;
    b_start_1: TButton;
    c_checkBox_swap: TCheckBox;
    waveOut2: TunavclWaveOutDevice;
    waveIn2: TunavclWaveInDevice;
    Bevel3: TBevel;
    Label4: TLabel;
    c_mm_main: TMainMenu;
    Quot1: TMenuItem;
    Quit1: TMenuItem;
    procedure waveIn1DataAvailable(sender: unavclInOutPipe; data: pointer; len: cardinal);
    procedure FormCreate(Sender: TObject);
    procedure formDestroy(sender: tObject);
    procedure Timer1Timer(Sender: TObject);
    procedure b_start_1Click(Sender: TObject);
    procedure b_stop_1Click(Sender: TObject);
    procedure b_start_2Click(Sender: TObject);
    procedure b_stop_2Click(Sender: TObject);
    procedure waveIn2DataAvailable(sender: unavclInOutPipe; data: Pointer; len: Cardinal);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Quit1Click(Sender: TObject);
  private
    { Private declarations }
    f_channelDestBuf1: pointer;
    f_channelDestBuf2Left: pointer;
    f_channelDestBuf2Right: pointer;
  public
    { Public declarations }
  end;

var
  c_form_main: Tc_form_main;


implementation


{$R *.dfm}

uses
  unaTypes, unaUtils, unaWave;

// --  --
procedure Tc_form_main.Timer1Timer(Sender: TObject);
begin
  if (not (csDestroying in componentState)) then
    c_statusBar_main.Panels[0].Text := 'Mem: ' + int2str(ams() shr 10, 10, 3) + ' KB';
  //
end;

// --  --
procedure Tc_form_main.FormCreate(Sender: TObject);
var
  size: unsigned;
begin
  // allocate enough space for 1/10 sec of one channel data
  size := (1 * waveIn1.pcm_samplesPerSec * waveIn1.pcm_bitsPerSample shr 3) div 10;
  f_channelDestBuf1 := malloc(size);
  //
  // allocate enough space for 1/10 sec of one channel data
  size := (1 * waveIn2.pcm_samplesPerSec * waveIn2.pcm_bitsPerSample shr 3) div 10;
  f_channelDestBuf2Left  := malloc(size);
  f_channelDestBuf2Right := malloc(size);
end;

// --  --
procedure Tc_form_main.formDestroy(sender: tObject);
begin
  // make sure our buffers will not be used
  waveIn1.close();
  waveIn2.close();

  // deallocate buffers
  mrealloc(f_channelDestBuf1);
  mrealloc(f_channelDestBuf2Left);
  mrealloc(f_channelDestBuf2Right);
end;

// ----------------
// -- Extracting --
// ----------------
procedure Tc_form_main.waveIn1DataAvailable(sender: unavclInOutPipe; data: pointer; len: cardinal);
var
  numSamples: unsigned;
begin
  // extract left or right channel
  //
  numSamples := waveExtractChannel(
    data,		// our source PCM data
    f_channelDestBuf1,	// our dest pre-allocated buffer
      // we can pre-calculate number of samples in chunk of data, but it should not take much time to do in-place divs here
    len div (waveIn1.pcm_bitsPerSample shr 3) div waveIn1.pcm_numChannels,
    waveIn1.pcm_bitsPerSample,	// need to know number of bits
    waveIn1.pcm_numChannels,	// need to know number of channels in the stream
    choice(c_rb_left.checked, unsigned(0){left}, 1{right})	// which channel to extract
  );

  // now feed waveOut with extracted data
  // NOTE: waveOut must have one channel
  waveOut1.write(f_channelDestBuf1, 1 * numSamples * (waveIn1.pcm_bitsPerSample shr 3));
end;

// ---------------
// -- Replacing --
// ---------------
procedure Tc_form_main.waveIn2DataAvailable(sender: unavclInOutPipe; data: Pointer; len: Cardinal);
var
  numSamples: unsigned;
  numSamplesLeft: unsigned;
  numSamplesRight: unsigned;
begin
  if (c_checkBox_swap.checked) then begin
    //
    // we can pre-calculate number of samples in one chunk of data,
    // but it should not take too much time to do in-place divs here
    //
    numSamples := len div (waveIn2.pcm_bitsPerSample shr 3) div waveIn2.pcm_numChannels;

    with (waveIn2) do begin
    
      // 1. extract left channel data
      numSamplesLeft := waveExtractChannel(
	data,			// our source PCM data
	f_channelDestBuf2Left, 	// our dest pre-allocated buffer for left channel
	numSamples,
	pcm_bitsPerSample,	// need to know number of bits
	pcm_numChannels,	// need to know number of channels in the stream
	0{left}	// which channel to extract
      );

      // 2. extract right channel data
      numSamplesRight := waveExtractChannel(
	data,			// our source PCM data
	f_channelDestBuf2Right, // our dest pre-allocated buffer for right channel
	numSamples,
	pcm_bitsPerSample,	// need to know number of bits
	pcm_numChannels,	// need to know number of channels in the stream
	1{right}		// which channel to extract
      );

      // 3. insert left channel in place of right channel
      waveReplaceChannel(
	data,			// can use supplied data buffer
	f_channelDestBuf2Left,	// left channel data
	numSamplesLeft,		// should be equal to numSamples
	pcm_bitsPerSample,	// need to know number of bits
	pcm_numChannels,	// need to know number of channels in the stream
	1{right}		// which channel to replace
      );

      // 4. insert right channel in place of left channel
      waveReplaceChannel(
	data,			// can use supplied data buffer
	f_channelDestBuf2Right,	// left channel data
	numSamplesRight,	// should be equal to numSamples
	pcm_bitsPerSample,	// need to know number of bits
	pcm_numChannels,	// need to know number of channels in the stream
	0{left}		// which channel to replace
      );
    end;
  end;

  // now feed waveOut with replaced (or original) data
  waveOut2.write(data, len);
end;

// --  --
procedure Tc_form_main.b_start_1Click(Sender: TObject);
begin
  b_start_1.enabled := false;
  //
  b_stop_2Click(sender);
  //
  // start extraction example
  waveOut1.open();
  waveIn1.open();
  //
  b_stop_1.enabled := true;
end;

// --  --
procedure Tc_form_main.b_stop_1Click(Sender: TObject);
begin
  b_stop_1.enabled := false;
  //
  // stop extraction example
  waveIn1.close();
  waveOut1.close();
  //
  b_start_1.enabled := true;
end;

// --  --
procedure Tc_form_main.b_start_2Click(Sender: TObject);
begin
  b_start_2.enabled := false;
  //
  b_stop_1Click(sender);
  //
  // start replacing example
  waveOut2.open();
  waveIn2.open();
  //
  b_stop_2.enabled := true;
end;

// --  --
procedure Tc_form_main.b_stop_2Click(sender: TObject);
begin
  b_stop_2.enabled := false;
  //
  // stop replacing example
  waveIn2.close();
  waveOut2.close();
  //
  b_start_2.enabled := true;
end;

// --  --
procedure Tc_form_main.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  waveIn1.close();
  waveIn2.close();
end;

// --  --
procedure Tc_form_main.quit1Click(sender: tObject);
begin
  close();
end;


end.

