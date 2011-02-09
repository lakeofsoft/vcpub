
(*
	----------------------------------------------

	  unaDspControls.pas - DSP components and controls
	  Voice Communicator components version 2.5 DSP

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 03 Nov 2003

	  modified by:
		Lake, Nov 2003

	----------------------------------------------
*)

{$I unaDef.inc}

{*
  FFT and DTMF VCL components.

  @Author Lake
  @Version 2.5.2008.07 Still here
}

unit
  unaDspControls;

interface

uses
  Windows, unaTypes, unaClasses, unaMsAcmAPI, unaMsAcmClasses,
  unaWave, unaVC_pipe, unaVC_wave, unaDSP,
  Graphics, Classes, Controls, ExtCtrls;


type
  //
  punaMBSPBands = ^unaMBSPBands;
  unaMBSPBands = array[byte] of pFloatArray;	// up to 256 bands

  //
  {*
  	FFT Pipe
  }
  TunadspFFTPipe = class(unavclInOutPipe)
  private
    f_fft: unadspFFT;
    //
    f_timer: unaMMTimer;
    f_dataProxy: array[word] of byte;
    f_channel: unsigned;	// for one channel only
    //
    f_localFormat: pointer;
    f_localFormatSize: unsigned;
    f_onFFTDone: tNotifyEvent;
    //
    function getInterval(): unsigned;
    procedure setInterval(value: unsigned);
    //
    procedure onTimer(sender: tObject);
  protected
    {*
      Opens the pipe.
    }
    function doOpen(): bool; override;
    {*
      Closes the pipe.
    }
    procedure doClose(); override;
    {*
      Writes data into the pipe.
    }
    function doWrite(data: pointer; len: unsigned; provider: pointer = nil): unsigned; override;
    {*
      Reads data from the pipe.
    }
    function doRead(data: pointer; len: unsigned): unsigned; override;
    {*
      Returns available data size in the pipe.
    }
    function getAvailableDataLen(index: int): unsigned; override;
    {*
      Returns active state of the pipe.
    }
    function isActive(): bool; override;
    {*
      Applies new format of the stream to the pipe.
    }
    function applyFormat(data: pointer; len: unsigned; provider: unavclInOutPipe = nil; restoreActiveState: bool = false): bool; override;
    {*
      Fills the format of the pipe stream.
    }
    function getFormatExchangeData(out data: pointer): unsigned; override;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
    //
    property updateInterval: unsigned read getInterval write setInterval;
    //
    property fft: unadspFFT read f_fft;
    //
    property channel: unsigned read f_channel write f_channel;
    //
    property onFFTDone: tNotifyEvent read f_onFFTDone write f_onFFTDone;
  end;


const
  cldef_BandLow		= $00808080;
  cldef_BandMed		= $00A0A0A0;
  cldef_BandTop		= $00C0C0C0;

type

  {*
  	FFT Control
  }
  TunadspFFTControl = class(tGraphicControl)
  private
    f_pipe: TunadspFFTPipe;
    f_bandWidth: unsigned;
    f_bandGap: unsigned;
    //
    f_pen: array[0..2] of hPen;
    f_penColor: array[0..2] of tColor;
    //
    function getSteps(): unsigned;
    procedure setSteps(value: unsigned);
    function getInterval: unsigned;
    procedure setInterval(value: unsigned);
    function getChannel(): unsigned;
    procedure setChannel(value: unsigned);
    procedure setColorBack(value: tColor);
    function getColorBack(): tColor;
    function getActive(): bool;
    procedure setActive(value: bool);
    //
    function getBandColor(index: int): tColor;
    procedure setBandColor(index: int; value: tColor);
  protected
    procedure Paint(); override;
    //
    procedure paintOnDC(dc: hDC); virtual;
    //
    procedure onFFTDone(sender: tObject); virtual;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
    //
    function displayMBSPBands(numBands: unsigned; values: punaMBSPBands; nSamples: unsigned): bool;
    //
    property fft: TunadspFFTPipe read f_pipe;
  published
    //
    property bandWidth: unsigned read f_bandWidth write f_bandWidth default 1;
    //
    property bandGap: unsigned read f_bandGap write f_bandGap default 0;
    //
    property steps: unsigned read getSteps write setSteps default 8;
    //
    property interval: unsigned read getInterval write setInterval default 1000;
    //
    property channel: unsigned read getChannel write setChannel default 0;
    //
    property color: tColor read getColorBack write setColorBack default clBlack;
    //
    property bandColorLow: tColor index 0 read getBandColor write setBandColor default cldef_BandLow;
    //
    property bandColorMed: tColor index 1 read getBandColor write setBandColor default cldef_BandMed;
    //
    property bandColorTop: tColor index 2 read getBandColor write setBandColor default cldef_BandTop;
    //
    property active: bool read getActive write setActive default false;
    //
    property Anchors;
    property Align;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Visible;
    //
    property OnClick;
{$IFDEF __BEFORE_D6__ }
{$ELSE }
    property OnContextPopup;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
{$ENDIF }
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;


  {*
    	DTMF Control	
  }
  TunavclDTMFDecoder = class(unavclInOutWavePipe)
  private
    f_isActive: bool;
    f_decoder: unaDspDTMFDecoder;
    //
    function getThreshold(): int;
    procedure setThreshold(value: int);
    function getOnCodeDE(): tDTMFCodeDetectedEvent;
    procedure setOnCodeDE(value: tDTMFCodeDetectedEvent);
  protected
    function applyDeviceFormat(format: PWAVEFORMATEXTENSIBLE; isSrc: bool = true): bool; override;
    //
    function doWrite(data: pointer; len: unsigned; provider: pointer = nil): unsigned; override;
    function getAvailableDataLen(index: int): unsigned; override;
    function doOpen(): bool; override;
    procedure doClose(); override;
    function  isActive(): bool; override;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
    //
  published
    property threshold: int read getThreshold write setThreshold default c_def_dtmfd_LVS;
    //
    {*
	Fires when new DTMF code is detected.
    }
    property onDTMFCodeDetected: tDTMFCodeDetectedEvent read getOnCodeDE write setOnCodeDE;
  end;


// --  --
procedure Register();


implementation


uses
  unaUtils, Math;

{ TunadspFFTPipe }

// --  --
procedure TunadspFFTPipe.afterConstruction();
begin
  f_timer := unaMMTimer.create(1000);
  //f_timer.enabled := false;
  f_timer.onTimer := onTimer;
  //
  f_fft := unadspFFT.create(1 shl 8{default window size});
  //
  f_localFormat := nil;
  //
  inherited;
end;

// --  --
function TunadspFFTPipe.applyFormat(data: pointer; len: unsigned; provider: unavclInOutPipe; restoreActiveState: bool): bool;
begin
  if (enter(false, 100)) then
    try
      mrealloc(f_localFormat, len);
      f_localFormatSize := len;
      //
      if (0 < len) then
	move(data^, f_localFormat^, len);
      //
      with (punavclWavePipeFormatExchange(data).r_formatM) do
	f_fft.setFormat(formatOriginal.pcmBitsPerSample, formatOriginal.pcmNumChannels);
      //
    finally
      leaveWO();
    end;
  //
  result := inherited applyFormat(data, len, provider, restoreActiveState);
end;

// --  --
procedure TunadspFFTPipe.beforeDestruction();
begin
  inherited;
  //
  freeAndNil(f_fft);
  freeAndNil(f_timer);
  mrealloc(f_localFormat);
end;

// --  --
procedure TunadspFFTPipe.doClose();
begin
  f_timer.stop();
  //
  inherited;
end;

// --  --
function TunadspFFTPipe.doOpen(): bool;
begin
  result := inherited doOpen();
  //
  if (result) then
    f_timer.start();
end;

// --  --
function TunadspFFTPipe.doRead(data: pointer; len: unsigned): unsigned;
begin
  result := 0;
end;

// --  --
function TunadspFFTPipe.doWrite(data: pointer; len: unsigned; provider: pointer): unsigned;
begin
  // copy new data locally
  if (0 < len) then
    move(data^, f_dataProxy, min(sizeOf(f_dataProxy), len));
  //
  // pass data to consumers
  onNewData(data, len, self);
  result := len;
end;

// --  --
function TunadspFFTPipe.getAvailableDataLen(index: int): unsigned;
begin
  result := 0;
end;

// --  --
function TunadspFFTPipe.getFormatExchangeData(out data: pointer): unsigned;
begin
  if (enter(true, 100)) then begin
    try
      result := f_localFormatSize;
      //
      if (0 < result) then begin
        //
	data := malloc(result);
	move(f_localFormat^, data^, result);
      end
      else
	data := nil;
      //
    finally
      leaveRO();
    end;
  end
  else begin
    //
    data := nil;
    result := 0;
  end;
end;

// --  --
function TunadspFFTPipe.getInterval(): unsigned;
begin
  result := f_timer.interval;
end;

// --  --
function TunadspFFTPipe.isActive(): bool;
begin
  result := f_timer.isRunning();
end;

// --  --
procedure TunadspFFTPipe.onTimer(sender: tObject);
begin
  if (enter(true, 100)) then
    try
      f_fft.fft_complex_forward(@f_dataProxy, f_channel);
    finally
      leaveRO();
    end;
  //
  if (assigned(f_onFFTDone)) then
    f_onFFTDone(self);
end;

// --  --
procedure TunadspFFTPipe.setInterval(value: unsigned);
begin
  f_timer.interval := value;
end;

{ TunadspFFTControl }

// --  --
procedure TunadspFFTControl.afterConstruction();
begin
  f_pipe := TunadspFFTPipe.create(nil);
  f_pipe.onFFTDone := onFFTDone;
  //
  f_bandWidth := 1;
  canvas.brush.color := clBlack;
  //
  bandColorLow := cldef_BandLow;
  bandColorMed := cldef_BandMed;
  bandColorTop := cldef_BandTop;
  //
  width := 100;
  height := 200;
  //
  controlStyle := controlStyle + [csOpaque];
  //
  inherited;
end;

// --  --
procedure TunadspFFTControl.beforeDestruction();
begin
  inherited;
  //
  freeAndNil(f_pipe);
end;

// --  --
function TunadspFFTControl.displayMBSPBands(numBands: unsigned; values: punaMBSPBands; nSamples: unsigned): bool;
var
  dc: hDC;
  b, j, k: int;
  h, w, x, t: int;
  p: float;
  lh: float;
  rect: tRect;
begin
  canvas.lock();
  try
    //
    dc := canvas.handle;
    if ((0 <> dc) and (0 < nSamples)) then begin
      //
      // clear background
      //fillRect(dc, clientRect, canvas.brush.handle);
      //
      h := clientRect.bottom - clientRect.top;
      w := clientRect.right - clientRect.left;
      //
      if (0 < h) then begin
	//
	// draw bands
	x := f_bandGap;
	lh := log2(h);
	for b := 0 to numBands - 1 do begin
	  //
	  p := 0;
	  for k := 1 to nSamples - 1 do
	    p := p + abs(values[b][k] - values[b][k - 1]);
	  //
	  t := trunc( log2(1 + p * numBands * h / nSamples) / lh * h );
	  if (t < 1) then
	    t := 1;
	  if (t > h) then
	    t := h;
	  //
	  for j := 0 to f_bandWidth - 1 do begin
	    //
	    if (int(x + j) < w) then begin
	      //
	      for k := 0 to 2 do begin
		//
		SelectObject(dc, f_pen[k]);
		moveToEx(dc, x + j, h - (t div 3) * (int(k) + 0), nil);
		lineTo  (dc, x + j, h - (t div 3) * (int(k) + 1));
	      end;
	    end;
	  end;
	  //
	  // clear rest of band
	  rect.left   := x;
	  rect.right  := x + int(f_bandWidth);
	  rect.top    := 0;
	  rect.bottom := h - t;
	  fillRect(dc, rect, canvas.brush.handle);
	  //
	  inc(x, f_bandWidth);
	  inc(x, f_bandGap);
	end;
      end;
    end;
  finally
    canvas.unlock();
  end;
  //
  result := true;
end;

// --  --
function TunadspFFTControl.getActive(): bool;
begin
  result := fft.active;
end;

// --  --
function TunadspFFTControl.getBandColor(index: int): tColor;
begin
  result := f_penColor[index];
end;

// --  --
function TunadspFFTControl.getChannel(): unsigned;
begin
  result := f_pipe.channel;
end;

// --  --
function TunadspFFTControl.getColorBack(): tColor;
begin
  result := canvas.brush.color;
end;

// --  --
function TunadspFFTControl.getInterval(): unsigned;
begin
  result := f_pipe.updateInterval;
end;

// --  --
function TunadspFFTControl.getSteps(): unsigned;
begin
  result := f_pipe.fft.steps;
end;

// --  --
procedure TunadspFFTControl.onFFTDone(sender: tObject);
begin
  invalidate();
end;

// --  --
procedure TunadspFFTControl.paint();
begin
  with (canvas) do begin
    //
    lock();
    try
      //
      paintOnDC(handle);
    finally
      unlock();
    end;
  end;
end;

// --  --
procedure TunadspFFTControl.paintOnDC(dc: hDC);
var
  i, j, x, k: unsigned;
  h, w, t: int;
  r: double;
begin
  // clear background
  fillRect(dc, clientRect, canvas.brush.handle);
  //
  h := clientRect.bottom - clientRect.top;
  w := clientRect.right - clientRect.left;
  //
  if ((0 < h) and (0 < f_bandWidth)) then begin
    // draw FFT bands
    x := 0;
    r := h / 256;
    for i := 0 to f_pipe.fft.windowSize shr 1 do begin
      //
      if (0.001 > abs(f_pipe.fft.dataR[i])) then
	t := 0
      else
	//t := round(r * abs(f_pipe.fft.dataR[i] / f_pipe.fft.windowSize));
	t := round(r * abs((SQRt(  sqr(f_pipe.fft.dataI[i]) + sqr(f_pipe.fft.dataR[i])) / (f_pipe.fft.windowSize) )));
      //
      if (0 < t) then begin
        //
	for j := 0 to f_bandWidth - 1 do begin
	  //
	  if (int(x + j) < w) then begin
	    //
	    for k := 0 to 2 do begin
	      //
	      windows.selectObject(dc, f_pen[k]);
	      moveToEx(dc, x + j, h - (t shr 2) * (int(k) + 0), nil);
	      lineTo  (dc, x + j, h - (t shr 2) * (int(k) + 1));
	    end;
	  end;
	end;
      end;
      //
      inc(x, f_bandWidth);
      inc(x, f_bandGap);
    end;
  end;
end;

// --  --
procedure TunadspFFTControl.setActive(value: bool);
begin
  fft.active := value;
end;

// --  --
procedure TunadspFFTControl.setBandColor(index: int; value: tColor);
begin
  f_penColor[index] := value;
  //
  windows.deleteObject(f_pen[index]);
  f_pen[index] := windows.createPen(PS_SOLID, 1, value);
  //
  refresh();
end;

// --  --
procedure TunadspFFTControl.setChannel(value: unsigned);
begin
  f_pipe.channel := value;
end;

// --  --
procedure TunadspFFTControl.setColorBack(value: tColor);
begin
  canvas.brush.color := value;
  refresh();
end;

procedure TunadspFFTControl.setInterval(value: unsigned);
begin
  f_pipe.updateInterval := value;
end;

// --  --
procedure TunadspFFTControl.setSteps(value: unsigned);
begin
  f_pipe.fft.steps := value;
end;


{ TunavclDTMFDecoder }

// --  --
procedure TunavclDTMFDecoder.AfterConstruction();
begin
  f_decoder := unaDspDTMFDecoder.create();
  //
  inherited;
end;

// --  --
function TunavclDTMFDecoder.applyDeviceFormat(format: PWAVEFORMATEXTENSIBLE; isSrc: bool): bool;
begin
  if (nil <> f_decoder) then
    result := SUCCEEDED(f_decoder.setFormat(format.format.nSamplesPerSec, format.format.wBitsPerSample, format.format.nChannels))
  else
    result := false;  
end;

// --  --
procedure TunavclDTMFDecoder.BeforeDestruction();
begin
  inherited;
  //
  freeAndNil(f_decoder);
end;

// --  --
procedure TunavclDTMFDecoder.doClose();
begin
  inherited;
  //
  f_isActive := false;
end;

// --  --
function TunavclDTMFDecoder.doOpen(): bool;
begin
  result := inherited doOpen();
  //
  f_isActive := result;
end;

// --  --
function TunavclDTMFDecoder.doWrite(data: pointer; len: unsigned; provider: pointer): unsigned;
begin
  if (SUCCEEDED(f_decoder.write(data, len))) then
    result := len
  else
    result := 0;
end;

// --  --
function TunavclDTMFDecoder.getAvailableDataLen(index: int): unsigned;
begin
  result := 0;
end;

// --  --
function TunavclDTMFDecoder.getOnCodeDE(): tDTMFCodeDetectedEvent;
begin
  result := f_decoder.onDTMFCodeDetected;
end;

// --  --
function TunavclDTMFDecoder.getThreshold(): int;
begin
  result := f_decoder.threshold;
end;

// --  --
function TunavclDTMFDecoder.isActive(): bool;
begin
  result := f_isActive;
end;

// --  --
procedure TunavclDTMFDecoder.setOnCodeDE(value: tDTMFCodeDetectedEvent);
begin
  f_decoder.onDTMFCodeDetected := value;
end;

// --  --
procedure TunavclDTMFDecoder.setThreshold(value: int);
begin
  f_decoder.threshold := value;
end;



// --------

// --  --
procedure Register();
begin
  RegisterComponents(c_VC_reg_DSP_section_name, [
    TunadspFFTPipe,
    TunadspFFTControl,
    TunavclDTMFDecoder
  ]);
end;


end.

