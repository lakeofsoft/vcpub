
(*
	----------------------------------------------

	  unaDsp.pas - DSP routines and classes
	  Voice Communicator components version 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 31 Oct 2003

	  modified by:
		Lake, Oct 2003
		Lake, Jun 2007

	----------------------------------------------
*)

{$I unaDef.inc}

{*
  FFT and DTMF implementations.

  @Author Lake
  @Version 2.5.2008.07 Still here
}

unit
  unaDsp;

interface

uses
  Windows, unaTypes, unaUtils, unaClasses, unaWave;

type
  {*
    FFT implementation.
  }
  unaDspFFT = class(unaObject)
  private
    f_bits: unsigned;
    f_channels: unsigned;
    //
    f_steps: unsigned;
    f_windowSize: unsigned;
    //
    f_helper: pUint32Array;
    f_cos_array: pFloatArray;
    f_sin_array: pFloatArray;
    f_dataProxy: pFloatArray;
    //
    f_dataR: pFloatArray;
    f_dataI: pFloatArray;
    //
    procedure samplesToDataProxy(samples: pointer; channel: unsigned);
    procedure dataProxyToRI();
    procedure setSteps(value: unsigned);
  public
    constructor create(windowSize: unsigned = 1024);
    //
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
    //
    {*
      size should be power of 2.
    }
    procedure setWindowSize(size: unsigned);
    procedure setFormat(format: punaPCMFormat); overload;
    procedure setFormat(bits, channels: unsigned); overload;
    //
    {*
      complex DFT. Results are in dataR, dataI.
      /Works really slow/
    }
    procedure dft_complex_forward(samples: pointer; channel: unsigned = 0);
    {*
      complex FFT. Results are in dataR, dataI.
      /Works faster/
    }
    procedure fft_complex_forward(samples: pointer; channel: unsigned = 0);
    //
    property data: pFloatArray read f_dataProxy;
    //
    property dataR: pFloatArray read f_dataR;
    property dataI: pFloatArray read f_dataI;
    //
    property windowSize: unsigned read f_windowSize write setWindowSize;
    property steps: unsigned read f_steps write setSteps;
  end;


type
  //
  tDtmfd_md4 = array[1..4] of double;

  //
  tDtmfd_rdec = record        // Goertzel results
    S2:    Double;     // sum of squares
    MxGLH: Double;     // sum of squares for all harmonics
    MxGL:  Double;     // sum of squares for 697..941 harmonics
    MxGH:  Double;     // sum of squares for 1209..1633 harmonics
    MGLM:  Double;     // Max of 697..941
    MGHM:  Double;     // Max of 1209..1633
    IL: Integer;       // index of max from F 697..941
    IH: Integer;       // index of max from F 1209..1633)
    K1: Single;        // MxGLH/S2
    K2: Single;        // MxGL/MxGLH
    K3: Single;        // MxGH/MxGLH
    K4: Single;        // MGLM/MxGL
    K5: Single;        // MGHM/MxGH
    K6: Single;        // K1*K2*K3*K4*K5 - signal quality estimation
  end;

const
  //c_dtmfd_VBSh	= 3000;		// noise amplitude
  //c_dtmfd_VS	= 6000; 	// amplitude of DTMF wave
  c_dtmfd_TG	= 25;   	// ms per Goertzel analyzis
  //c_dtmfd_TP	= 40;      	// ms per pause
  //c_dtmfd_TS	= 50;      	// ms per signal
  //
  c_def_dtmfd_LVS   = 900;    	// silence threshold
  //
  c_dtmfd_FDL: tDtmfd_md4 = (697,   770,  852,  941);	// DTMF low freqs
  c_dtmfd_FDH: tDtmfd_md4 = (1209, 1336, 1477, 1633); 	// DTMF hi freqs
  //
  c_dtmfd_TxDTMF	= '147*2580369#ABCD';	//	DTMF codes
  //
  c_dtmfd_maxBufSize	= 1000;
  //
  c_dtmfd_samplingRate	= 8000;


type
  //
  tDTMFCodeDetectedEvent = procedure(sender: tObject; code: char; const param: single) of object;


  {*
    DTMF Decoder implementation.
  }
  unaDspDTMFDecoder = class(unaObject)
  private
    f_samplingRate: int;	// source sampling rate
    f_bitNum: int;		// source number of bits per sample
    f_numChannels: int; 	// source number of channels
    //
    f_NMX: int;                 	// num of samples in input buf
    f_BMX: int;                 	// index of first sample
    f_MX: array[0..c_dtmfd_maxBufSize - 1] of int16;  	// input buf
    f_NG: int;                    	// num of Goertzel cycles
    //f_NP: int;                    	// num of DTMF pause generator cycles
    //f_NS: int;                    	// num of DTMF signal generator cycles
    f_KGL: tDtmfd_md4;			// "Goertzel" F (697..941)
    f_KGH: tDtmfd_md4;                  // "Goertzel" F (1209..1633)
    //f_NK: int;                    	// DTMF code
    //f_MXW: array[1..2000] of single;  	// working DTMF buf
    //f_WS:  double;      // noise level
    //f_WL:  double;      // angle (rad)
    //f_WH:  double;	  // angle (rad)
    //f_VSL: double;      // signal 697..941
    //f_VSH: double;      // signal 1209..1633
    //f_NN:  int;     	// DTMF gen cycle
    //f_NRW: int;     	// working buf index
    //f_iL: int;      	// low DTMF code
    //f_iH: int;      	// hi DTMF code
    //
    f_dtmfd_LVS: int;	// threshold
    //
    f_state: int;   	// state:
			//  0 - waiting for signal start
			//  1 - searching max signal
			//  2 - waiting for signal end
    //
    //f_gate: unaInProcessGate;
    //
    f_onCode: tDTMFCodeDetectedEvent;
    //
    procedure processDTMFBuf();
  protected
    procedure DTMFCodeDetected(code: char; const param: single); virtual;
  public
    constructor create();
    procedure BeforeDestruction(); override;
    //
    function setFormat(samplingRate, bitsPerSample, numChannels: int): HRESULT;
    //
    function write(data: pointer; size: int): HRESULT;
    //
    function enter(ro: bool; timeout: int = 1000): bool;
    procedure leave({$IFDEF DEBUG }ro: bool{$ENDIF DEBUG });
    //
    {*
      The lower signal you have, the lower threshold value should be.
    }
    property threshold: int read f_dtmfd_LVS write f_dtmfd_LVS;
    //
    property onDTMFCodeDetected: tDTMFCodeDetectedEvent read f_onCode write f_onCode;
  end;


implementation


// -- from Math.pas --
function log2(const x: int64): float;
asm
	fld1		// ST(0) <= 1.0
	fild	x	// ST(1) <= ST(0) <= x
	fyl2x		// ST(1) <= ST(1) * log.2(ST(0))
	fwait
end;

// --  --
function min(a, b: int): int;
begin
  if (a < b) then
    result := a
  else
    result := b;
end;

// --  --
function bitReverse(x, steps: unsigned): unsigned;
{
	IN EAX = x
	IN ECX = steps

	OUT EAX = result
}
asm
	mov	ecx, edx
	and	ecx, $1F	// 0..31
	jecxz	@done
	//
	push	ecx
  @loop:
	ror	eax, 1
	rcl	edx, 1
	loop	@loop
	//
	pop	ecx
	//
	neg	ecx
	add	ecx, 32
	shl	edx, cl		// clear high cl bits
	shr	edx, cl
	//
  @done:
	mov	eax, edx
end;

{ unaDspFFT }

// --  --
procedure unaDspFFT.afterConstruction();
begin
  inherited;
  //
  setWindowSize(f_windowSize);
end;

// --  --
procedure unaDspFFT.beforeDestruction();
begin
  inherited;
  //
  mrealloc(f_helper);
  mrealloc(f_cos_array);
  mrealloc(f_sin_array);
  mrealloc(f_dataProxy);
  mrealloc(f_dataR);
  mrealloc(f_dataI);
end;

// --  --
constructor unaDspFFT.create(windowSize: unsigned);
begin
  inherited create();
  //
  f_windowSize := windowSize;
  //
  f_helper := nil;
  f_cos_array := nil;
  f_sin_array := nil;
  f_dataProxy := nil;
  f_dataR := nil;
  f_dataI := nil;
  //
  f_bits := 16;
  f_channels := 2;
end;

// --  --
procedure unaDspFFT.dataProxyToRI();
var
  i: unsigned;
begin
  for i := 0 to f_windowSize - 1 do begin
    //
    f_dataR[i] := f_dataProxy[i];
    f_dataI[i] := 0;
  end;
end;

// --  --
procedure unaDspFFT.dft_complex_forward(samples: pointer; channel: unsigned = 0);
var
  k, i: unsigned;
  sc: float;
begin
  samplesToDataProxy(samples, channel);
  //
  for i := 0 to f_windowSize - 1 do begin
    //
    // Zero REX[ ] and IMX[ ], so they can be used
    // as accumulators during the correlation
    //
    f_dataR[i] := 0;
    f_dataI[i] := 0;
  end;
  //
  for k := 0 to f_windowSize - 1 do begin	// Loop for each value in frequency domain
    //
    sc := 2 * Pi * k / f_windowSize;
    for i := 0 to f_windowSize - 1 do begin	// Correlate with the complex sinusoid, SR & SI
      //
      f_dataR[k] := f_dataR[k] + f_dataProxy[i] * cos(sc * i);
      f_dataI[k] := f_dataI[k] - f_dataProxy[i] * sin(sc * i);
    end;
  end;
end;

// --  --
procedure unaDspFFT.fft_complex_forward(samples: pointer; channel: unsigned);
var
  i, j, l, le2, ip: unsigned;
  tr, ti, ur, ui, sr, si: float;
begin
  {
    THE FAST FOURIER TRANSFORM
    Upon entry, N% contains the number of points in the DFT, REX[ ] and
    IMX[ ] contain the real and imaginary parts of the input. Upon return,
    REX[ ] and IMX[ ] contain the DFT output. All signals run from 0 to N%-1.
  }
  samplesToDataProxy(samples, channel);
  dataProxyToRI();
  //
  for i := 0 to f_windowSize - 1 do begin	// Bit reversal sorting
    //
    j := f_helper[i];
    if (i < j) then begin
      //
      ti := f_dataR[i];
      f_dataR[i] := f_dataR[j];
      f_dataR[j] := ti;
    end;
  end;
  //
  for L := 1 to f_steps do begin	// Loop for each stage
    //
    LE2 := (1 shl L) shr 1;
    UR := 1;
    UI := 0;
    //
    SR := f_cos_array[L - 1];	// Calculate sine & cosine values
    SI := f_sin_array[L - 1];
    //
    for j := 1 to LE2 do begin	// Loop for each sub DFT
      //
      I := J - 1;
      while (i < f_windowSize) do begin	// Loop for each butterfly
	//
	IP := I + LE2;
	TR := f_dataR[IP] * UR - f_dataI[IP] * UI;	// Butterfly calculation
	TI := f_dataR[IP] * UI + f_dataI[IP] * UR;
	//
	f_dataR[IP] := f_dataR[I] - TR;
	f_dataI[IP] := f_dataI[I] - TI;
	f_dataR[I] := f_dataR[I] + TR;
	f_dataI[I] := f_dataI[I] + TI;
	//
	inc(i, LE2 shl 1);
      end;
      //
      TR := UR;
      UR := TR * SR - UI * SI;
      UI := TR * SI + UI * SR;
    end;
  end;
end;

// --  --
procedure unaDspFFT.samplesToDataProxy(samples: pointer; channel: unsigned);
var
  i, ofs: unsigned;
begin
  ofs := channel;
  //
  for i := 0 to f_windowSize - 1 do begin
    //
    case (f_bits) of

      8:
	f_dataProxy[i] := ($7F - pArray(samples)[ofs]) shl 8;

      16:
	f_dataProxy[i] := pInt16Array(samples)[ofs];

      32:
	f_dataProxy[i] := pInt32Array(samples)[ofs];

    end;
    //
    inc(ofs, f_channels);
  end;
end;

// --  --
procedure unaDspFFT.setFormat(format: punaPCMFormat);
begin
  setFormat(format.pcmBitsPerSample, format.pcmNumChannels);
end;

// --  --
procedure unaDspFFT.setFormat(bits, channels: unsigned);
begin
  f_bits := bits;
  f_channels := channels;
end;

// --  --
procedure unaDspFFT.setSteps(value: unsigned);
begin
  if (0 < (value and $1F)) then
    setWindowSize(1 shl (value and $1F));
end;

// --  --
procedure unaDspFFT.setWindowSize(size: unsigned);
var
  i: unsigned;
begin
  {
	m = FFT_Step;
	n = 1 << m;
	nv = n >> 1;
  }
  i := round(log2(size));
  //
  if (0 < i) then begin
    //
    f_steps := i;
    f_windowSize := 1 shl f_steps;
    //
    mrealloc(f_helper, f_windowSize * sizeof(f_helper[0]));
    mrealloc(f_cos_array, f_steps * sizeof(f_cos_array[0]));
    mrealloc(f_sin_array, f_steps * sizeof(f_sin_array[0]));
    mrealloc(f_dataProxy, f_windowSize * sizeof(f_dataProxy[0]));
    //
    mrealloc(f_dataR, f_windowSize * sizeof(f_dataR[0]));
    mrealloc(f_dataI, f_windowSize * sizeof(f_dataI[0]));
    //
    for i := 0 to f_steps - 1 do begin
      //
      f_cos_array[i] :=  cos(Pi / (1 shl i));
      f_sin_array[i] := -sin(Pi / (1 shl i));
    end;
    //
    for i := 0 to f_windowSize - 1 do
      f_helper[i] := bitReverse(i, f_steps);
    //
  end;
end;



{ unaDspDTMFDecoder }

// --  --
procedure unaDspDTMFDecoder.BeforeDestruction();
begin
  inherited;
  //
  //freeAndNil(f_gate);
end;

// --  --
constructor unaDspDTMFDecoder.create();
begin
  //f_gate := unaInProcessGate.create();
  //
  f_dtmfd_LVS := c_def_dtmfd_LVS;	// default threshold
  //
  setFormat(c_dtmfd_samplingRate, 16, 1);
  //
  inherited create();
end;

// --  --
procedure unaDspDTMFDecoder.DTMFCodeDetected(code: char; const param: single);
begin
  if (assigned(f_onCode)) then
    f_onCode(self, code, param);
end;

// --  --
function unaDspDTMFDecoder.enter(ro: bool; timeout: int): bool;
begin
  result := acquire(ro, timeout);
end;

// --  --
procedure unaDspDTMFDecoder.leave({$IFDEF DEBUG }ro: bool{$ENDIF DEBUG });
begin
  release({$IFDEF DEBUG }false{$ENDIF DEBUG });
end;

// --  --
procedure unaDspDTMFDecoder.processDTMFBuf();
var
  MGL: tDtmfd_MD4;     //
  MGH: tDtmfd_MD4;     //
  RdecO: tDtmfd_Rdec;  //
  RdecI: tDtmfd_Rdec;  //

  // Goertzel
  procedure Run_G();
  var
    i1, i2: int;
    XI: Double;   //
    S0: Double;   //
    SM1L: tDtmfd_MD4;    //
    SM1H: tDtmfd_MD4;    //
    SM2L: tDtmfd_MD4;    //
    SM2H: tDtmfd_MD4;    //
  begin
    for i1 := 1 to 4 do begin                //
      //
      SM1L[i1] := 0.0;
      SM1H[i1] := 0.0;
      SM2L[i1] := 0.0;
      SM2H[i1] := 0.0;
    end;
    //
    RdecI.S2 := 0.0;
    for i1 := 0 to f_NG - 1 do begin               //
      //
      XI := f_MX[f_BMX + i1];
      RdecI.S2 := RdecI.S2 + XI * XI;            //
      //
      for i2 := 1 to 4 do begin              //
	//
	S0 := XI + f_KGL[i2] * SM1L[i2] - SM2L[i2];  //
	SM2L[i2] := SM1L[i2];
	SM1L[i2] := S0;
	//
	S0 := XI + f_KGH[i2] * SM1H[i2] - SM2H[i2];  //
	SM2H[i2] := SM1H[i2];
	SM1H[i2] := S0;
      end;
    end;
    //
    for i1 := 1 to 4 do begin
      //
      MGL[i1] := Sqrt(SM1L[i1] * SM1L[i1] + SM2L[i1] * SM2L[i1] - f_KGL[i1] * SM1L[i1] * SM2L[i1]) / f_NG;
      MGH[i1] := Sqrt(SM1H[i1] * SM1H[i1] + SM2H[i1] * SM2H[i1] - f_KGH[i1] * SM1H[i1] * SM2H[i1]) / f_NG;
    end;
    //
    RdecI.MxGL  := Sqrt(MGL[1] * MGL[1] + MGL[2] * MGL[2] + MGL[3] * MGL[3] + MGL[4] * MGL[4]);
    RdecI.MxGH  := Sqrt(MGH[1] * MGH[1] + MGH[2] * MGH[2] + MGH[3] * MGH[3] + MGH[4] * MGH[4]);
    RdecI.MxGLH := Sqrt(RdecI.MxGL * RdecI.MxGL + RdecI.MxGH * RdecI.MxGH);
    RdecI.S2    := Sqrt(RdecI.S2) / f_NG;
  end;

  // --  --
  procedure Decod_DTMF();   //
  var
    IDTMF: Integer ;

    // --  --
    procedure Run_K();     // 
    var
      i1: int;
      Max: Double;
    begin
      Max := -1.0;
      for i1 := 1 to 4 do begin
	//
	if (MGL[i1] > Max) then begin
	  //
	  Max := MGL[i1];
	  RdecI.IL := i1;
	end;
      end;
      //
      Max := -1.0;
      for i1:=1 to 4 do begin
	//
	if (MGH[i1] > Max) then begin
	  //
	  Max := MGH[i1];
	  RdecI.IH := i1;
	end;
      end;
      //
      RdecI.K1 := RdecI.MxGLH / RdecI.S2;
      RdecI.K2 := RdecI.MxGL / RdecI.MxGLH;
      RdecI.K3 := RdecI.MxGH / RdecI.MxGLH;
      RdecI.K4 := MGL[RdecI.IL] / RdecI.MxGL;
      RdecI.K5 := MGH[RdecI.IH] / RdecI.MxGH;
      RdecI.K6 := RdecI.K1 * RdecI.K2 * RdecI.K3 * RdecI.K4 * RdecI.K5;
    end;

  begin
    case (f_state) of

      0: begin
	//
	if (RdecI.MxGLH > f_dtmfd_LVS) then begin
	  //
	  Run_K();
	  f_state := 1;
	  RdecO.MxGLH := 0;
	end;
      end;

      1: begin
	//
	if (RdecI.MxGLH > RdecO.MxGLH) then begin
	  //
	  Run_K();
	  RdecO := RdecI;
	end
	else begin
	  //
	  if (RdecO.K6 > 2.5) then begin
	    //
	    IDTMF := (RdecO.IH - 1) * 4 + RdecO.IL;
	    //
	    DTMFCodeDetected(c_dtmfd_TxDTMF[IDTMF], RdecO.K6);
	    //
	    RdecO.MxGLH := 0;
	    f_state := 2;
	  end;
	end;
      end;

      2: begin
	//
	if (RdecI.MxGLH < f_dtmfd_LVS) then
	  f_state :=0;
      end;

    end;

  end;


begin
  while (f_NMX - f_BMX >= f_NG) do begin
    //
    Run_G();
    Decod_DTMF();
    //
    f_BMX := f_BMX + (f_NG shr 1);       // shift first sample index by half of NG size
  end;
  //
  if (f_NMX > 0) then begin
    //
    if (0 < f_BMX) then begin
      //
      if (f_BMX < f_NMX) then
	move(f_MX[f_BMX], f_MX[0], (f_NMX - f_BMX) shl 1);	// move tail to buffer's head
      //
      dec(f_NMX, f_BMX);
      f_BMX := 0;    // reset first sample index
    end;
  end;
end;

// --  --
function unaDspDTMFDecoder.setFormat(samplingRate, bitsPerSample, numChannels: int): HRESULT;
var
  i: int;
begin
  if (enter(false, 2000)) then begin
    try
      //
      if ((0 < samplingRate) and (8 <= bitsPerSample) and (1 <= numChannels)) then begin
	//
	f_samplingRate := samplingRate;	// source sampling rate
	f_bitNum := bitsPerSample;	// source num of bits per sample
	f_numChannels := numChannels;	// source number of channels
	//
	for i := 1 to 4 do begin
	  //
	  f_KGL[i] := 2.0 * cos(2.0 * Pi * c_dtmfd_FDL[i] / c_dtmfd_samplingRate);
	  f_KGH[i] := 2.0 * cos(2.0 * Pi * c_dtmfd_FDH[i] / c_dtmfd_samplingRate);
	end;
	//
	f_NG := round(c_dtmfd_TG * c_dtmfd_samplingRate / 1000);                  // ms
	// gen
	//f_NP := round(0.5 * c_dtmfd_TP * f_FDSC / 1000);
	//f_NS := round(c_dtmfd_TS * f_FDSC / 1000);  		//
	//
	f_NMX := 0;		// num of samples in buffer
	f_BMX := 0;		// first sample index
	//
	f_state := 0;
	//
	result := S_OK;
      end
      else
	result := E_INVALIDARG;
      //
    finally
      leave({$IFDEF DEBUG }false{$ENDIF DEBUG });
    end;
  end
  else
    result := E_FAIL;
end;

// --  --
function unaDspDTMFDecoder.write(data: pointer; size: int): HRESULT;
var
  i: int;
  d: pInt16Array;
  num: int;
  nc: int;
  doConvert: bool;
begin
  if ((0 < size) and (nil <> data)) then begin
    //
    if (enter(true)) then begin
      //
      try
	//
	num := 0;
	d := nil;
	//
	if ((1 = f_numChannels) and (c_dtmfd_samplingRate = f_samplingRate)) then begin
	  //
	  doConvert := false;
	  case (f_bitNum) of

	    16: begin
	      //
	      d := data;
	      num := size shr 1;	// num of samples is twice less
	    end;

	    8: begin
	      //
	      d := malloc(size shl 1);	// two bytes per each sample from original buf
	      num := size;
	      //
	      for i := 0 to size - 1 do
		d[i] := (int(pArray(data)[i]) - $80) * $100;
	    end;

	    else
	      doConvert := true;

	  end;
	end
	else
	  doConvert := true;
	//
	if (doConvert) then begin
	  //
	  num := (size div f_numChannels);
	  if (16 = f_bitNum) then
	    num := num shr 1;
	  //
	  d := malloc(num shl 1);	// two bytes per sample
	  waveResample(data, d, num, f_numChannels, 1, f_bitNum, 16, f_samplingRate, c_dtmfd_samplingRate);
	end;
	//
	if (nil <> d) then begin
	  //
	  try
	    // fill input buffer
	    while (0 < num) do begin
	      //
	      nc := min(c_dtmfd_maxBufSize - f_NMX, num);
	      if (0 < nc) then begin
		//
		move(d^, f_MX[f_NMX], nc shl 1);
		inc(f_NMX, nc);
		//
		processDTMFBuf();
		//
		dec(num, nc);
	      end
	      else
		break;	// no more input data
	      //
	    end;
	    //
	    result := S_OK;
	    //
	  finally
	    if (d <> data) then
	      mrealloc(d);
	  end;
	end
	else
	  result := E_NOTIMPL;
	//
      finally
	leave({$IFDEF DEBUG }true{$ENDIF DEBUG });
      end;
    end
    else
      result := E_FAIL;
    //
  end
  else
    result := E_INVALIDARG;
end;


end.

