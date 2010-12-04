
(*
	----------------------------------------------

	  unaWave.pas
	  Voice Communicator components version 2.5
	  PCM wave routines

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 25 Mar 2002

	  modified by:
		Lake, Mar-Dec 2002
		Lake, Jan-Oct 2003
		Lake, Aug 2004

	----------------------------------------------
*)

{$I unaDef.inc }

{*
  Set of routines to work with PCM wave data.

  @Author Lake
  @Version 2.5.2008.07 Still here
}

unit
  unaWave;

interface


uses
  unaTypes;

type
  // --  --
  punaPCMFormat = ^unaPCMFormat;
  unaPCMFormat = packed record
    //
    pcmSamplesPerSecond: unsigned;	// sampling rate
    pcmBitsPerSample: unsigned;		// bits per sample
    pcmNumChannels: unsigned;		// number of channels
  end;

  // --  --
  punaWaveFormat = ^unaWaveFormat;
  unaWaveFormat = packed record
    //
    formatTag: unsigned;		// format tag id. could be WAVE_FORMAT_PCM or anything else
    formatOriginal: unaPCMFormat;	// original PCM format
    formatChannelMask: unsigned;	// channel mask
  end;

  // --  --
  punaPCMChunk = ^unaPCMChunk;
  unaPCMChunk = record
    //
    chunkFormat: unaPCMFormat;	// chunk format
    chunkDataLen: unsigned;	// length of actual data in chunk
    chunkBufSize: unsigned;	// size of chunk buffer in bytes
    chunkData: pointer;		// chunk data
  end;


  //
  // -- unavclWavePipeFormatExchange --
  //
  {*
	Pointer to <A href="unaWave/unavclWavePipeFormatExchange.html">unavclWavePipeFormatExchange</A>.
  }
  punavclWavePipeFormatExchange = ^unavclWavePipeFormatExchange;
  {*
	Data structure used for format exchange.
  }
  unavclWavePipeFormatExchange = packed record
    //
    r_formatM: unaWaveFormat;	/// data format
    //
    r_driverMode: int32;		        /// custom driver mode
    r_driverLib8: array[0..129] of AnsiChar;	/// library module name  (same size as "array [0..64] of WideChar" for backward compatibility)
  end;


{*
  Mixes buf1 and buf2 and stores the result in buf3 (buf3 could be one of buf1 or buf2).

  bitsN (N = 1, 2 or 3) specifies the number or bits in sample:
  8 = 1 byte per sample (from $00 = -128 to $FF = +127; $7F = -1, $80 = 0)
  16 = 2 bytes per sample (from $8000 = -32768 to $7FFF = 32767; $0 = 0, $FFFF = -1)
  32 = 4 bytes per sample (from $80000000 = -2147483648 to $7FFFFFFF = +2147483647; $0 = 0, $FFFFFFFF = -1)

  Size of buffer #N in bytes = (bitsN * samples * numChannels) shr 3
  Mixing is done by adding (doAdd is true) or subtracting (doAdd is false) samples with clipping.

  @return number of samples mixed.
}
function waveMix(buf1, buf2, buf3: pointer; samples: unsigned; bits1, bits2, bits3: unsigned; doAdd: bool = true; numChannels: unsigned = 1): unsigned; overload;
{*
  Mixes two chunks.

  @return number of samples mixed.
}
function waveMix(const chunk1, chunk2, chunk3: unaPCMChunk; doAdd: bool = true): unsigned; overload;

{*
  Calculates volume. Calculation is done by adding squares of samples and then dividing result on number of samples and applying square root.
  <BR />buf is a pointer to PCM samples
  <BR />samples is a number of samples.
  <BR />bits should have the value as described in waveMix() routine
  <BR />For multi-channel streams specify the channel number you wish to get the power of and total number of channels in the stream.
  <BR />Size of buffer can be calculated as (samples * bits * numChannels) shr 3
  <BR />Resulting value is from 0 (silence) to 32768 (loudest possible sound).
  <BR />Assumption sound has "natural" source is in effect. That means you can get useless results for signals, that are not sound by nature (constant non-zero signal for example).
}
function waveGetVolume(buf: pointer; samples: unsigned; bits: unsigned; numChannels: unsigned = 1; channel: unsigned = 0; deltaMethod: bool = false): unsigned;

{*
  Returns Logarithmic volume.
  <BR />Input range is from 0 to 32768.
  <BR />Result range is from 0 to 300.
}
function waveGetLogVolume(volume: int): unsigned;

{*
  Returns Logarithmic volume.
  <BR />Input range is from 0 to 32768.
  <BR />Result range is from 0 to 100.
}
function waveGetLogVolume100(volume: int): unsigned;

{*
  Extracts specified channel from PCM chunk.
  <BR />dest must be large enough to store required data (one channel).
  <BR />channel specifies which channel to extract (0, 1, 2... )
  <BR />Returns number of samples stored in dest buffer.
}
function waveExtractChannel(buf, dest: pointer; samples: unsigned; bits: unsigned; numChannels: unsigned = 1; channel: unsigned = 0): unsigned;

{*
  Replaces PCM data for specified channel with new one. Old data for this channel will be lost.
  <BR />channel specifies which channel to replace (0, 1, 2... )
  <BR />Returns number of samples stored in dest buffer.
}
function waveReplaceChannel(buf, source: pointer; samples: unsigned; bits: unsigned; numChannels: unsigned = 1; channel: unsigned = 0): unsigned; assembler;

{*
  Reverses PCM samples in wave chunk.
  bits specifies number of bits in sample.
  numChannels specifies number of channels in stream.

  @return number of samples processed.
}
function waveReverse(buf: pointer; samples: unsigned; bits: unsigned; numChannels: unsigned): unsigned; assembler;

{*
  Changes PCM stream characteristics.

  numChannels conversions supported:

  mono => any Number Of Channels
  stereo => mono; stereo; 4 channels; 6 channels; 8 channels ...
  3 channels => mono; 3 channels; 6 channels; 9 channels ...
  4 channels => mono; stereo; 4 channels; 8 channels; 12 channels ...
  5 channels => mono; 5 channels; 10 channels; 15 channels ...
  6 channels => mono; 3 channels; 6 channels; 12 channels ...
  ...
  i.e. number of dst channels must divide on number of src channels without a remainder

  @param bufSrc source samples
  @param bufDst destination samples (buffer must be already allocated)
  @param samples number of samples to read from bufSrc
  @param numChannelsSrc number of channels in source stream
  @param numChannelsDst number of channels in destination stream
  @param bitsSrc number of bits per sample in source stream
  @param bitsDst number of bits per sample in destination stream
  @param rateSrc sampling rate of source stream
  @param rateDst sampling rate of destination stream
  @return number of bytes produced by the function.
}
function waveResample(bufSrc, bufDst: pointer; samples, numChannelsSrc, numChannelsDst, bitsSrc, bitsDst, rateSrc, rateDst: unsigned): unsigned; overload;
{*
  Changes PCM stream characteristics.

  @return number of bytes produced by the function.
}
function waveResample(const bufSrc: unaPCMChunk; var bufDst: unaPCMChunk): unsigned; overload;

{*

  @return number of full samples which can be stored in given PCM chunk.
}
function waveGetChunkMaxSamplesCount(const chunk: unaPCMChunk): unsigned;

{*

  @return current number of full samples which is stored in given PCM chunk.
}
function waveGetChunkCurSamplesCount(const chunk: unaPCMChunk): unsigned;

{*
  Reallocates PCM chunk to hold required number of samples.
  NOTE: chunk.chunkData must be a valid pointer (or nil) before calling this function.

  @return number of bytes allocated.
}
function waveReallocateChunk(var chunk: unaPCMChunk; numSamples: unsigned = 0): unsigned;

{*
  Reads bytes from PCM chunk.

  @return number of bytes read
}
function waveReadFromChunk(var chunk: unaPCMChunk; buf: pointer; size: unsigned; bufOffs: unsigned = 0): unsigned;
{*
  Writes bytes to PCM chunk.
}
function waveWriteToChunk(var chunk: unaPCMChunk; buf: pointer; size: unsigned; bufOffs: unsigned = 0): unsigned;

{*
  Returns next gcd value.
}
function waveFindNextGcd(rate1, rate2: unsigned; startFrom: unsigned): unsigned;

{*
	Modifies linear volume for all samples.

	@param volume Percentage of original volume (100 means no change).
	@return Number of samples processed.
}
function waveModifyVolume100(volume: unsigned; buf: pointer; samples: unsigned; bits: unsigned = 16; numChannels: unsigned = 1; channel: int = -1): unsigned; overload;
{*
	Modifies linear volume for all samples.

	@param volume Percentage of original volume (100 means no change).
	@return Number of samples processed.
}
function waveModifyVolume100(volume: unsigned; const chunk: unaPCMChunk; channel: int): unsigned; overload;


implementation


uses
  unaUtils;

// -- --
procedure loadSample(); assembler;
{
	IN:	AL	- number of bits in sample (8, 16 or 32)
		ESI	- memory buffer pointer

	OUT:    EAX	- sample value (always 32 bit signed integer)

	AFFECTS:
		EAX
		ESI
}
asm

	cmp	al, 16
	je	@load_A16

	cmp	al, 8
	je	@load_A8

	cmp	al, 4
	je	@load_A4

  //@load_A32:
	lodsd			// eax = signed integer
	jmp	@exit

  @load_A4:
  	// not supported yet	
	jmp	@exit

  @load_A8:
	lodsb
	and	eax, 0FFh
	sub	eax, 080h
	sal	eax, 8		// eax = signed integer
	jmp	@exit

  @load_A16:
	lodsw
	cwde			// eax = signed integer
  @exit:
end;

// -- --
procedure saveSample(); assembler;
{
	IN:	BL	- 8, 16 or 32 bits in destination sample
		EAX	- sample value to store (always 32 bit signed integer)
		EDI	- memory buffer pointer

	OUT:    none

	AFFECTS:
		EAX
		EDI
}
asm
	push	ebx

	cmp	bl, 8
	je	@store_8

	cmp	bl, 16
	je	@store_16

	// store as 32 bit value
  //@store_32:
	stosd
	jmp	@exit

	// store as 16 bit value
  @store_16:
	mov	ebx, eax
	add	ebx, 08000h
	test	ebx, 080000000h
	jz	@store_16_01

	mov	eax, 08000h
	jmp	@store_16_w

  @store_16_01:
	test	eax, 080000000h
	jnz	@store_16_w

	mov	ebx, eax
	sub	ebx, 08000h
	test	ebx, 080000000h
	jnz	@store_16_w

	mov	eax, 07FFFh

  @store_16_w:
	stosw
	jmp	@exit

	// store as 8 bit value
  @store_8:
	sar	eax, 8
	add	eax, 080h
	test	eax, 080000000h
	jz	@store_8_01

	mov	eax, 0
	jmp	@store_8_b

  @store_8_01:
	cmp	eax, 0100h
	jb	@store_8_b

	mov	eax, 0FFh

  @store_8_b:
	stosb

  @exit:
	pop	ebx
end;

// --  --
function waveMix(buf1, buf2, buf3: pointer; samples: unsigned; bits1, bits2, bits3: unsigned; doAdd: bool; numChannels: unsigned): unsigned;
begin
  asm
	push 	esi
	push	edi
	push	ebx

	mov	ecx, samples
	mov	eax, numChannels
	imul	ecx			// EDX:EAX = samples * numChannels
	mov	ecx, eax
	mov	result, ecx

	// check if we have something to do
	cmp	ecx, 0
	je	@exit

	cmp	buf1, 0
	je	@exit
	cmp	buf2, 0
	je	@exit
	cmp	buf3, 0
	je	@exit

	mov	edi, buf3
	mov	bl, byte ptr bits3	// dest buffer bits number
	mov	bh, byte ptr bits1	// src buffer bits number

  @loop:
	// -- load A operand
	mov	esi, buf1
	mov	al, bh
	call	loadSample
	mov	buf1, esi

	mov	edx, eax	// store A operand

	// -- load B operand
	mov	esi, buf2
	mov	al, byte ptr bits2
	call	loadSample
	mov	buf2, esi

	xchg	eax, edx	// restore A operand

	// -- mix eax and ebx values

	cmp	doAdd, 0
	je	@do_mix_sub

  @do_mix_add:
	add	eax, edx
	jmp	@after_mix

  @do_mix_sub:
	sub	eax, edx

  @after_mix:
	// BL must be set to bits number
	call	saveSample		// store the result (EAX)
	loop	@loop

	// ------- loop ends here ------

  @exit:
	pop	ebx
	pop	edi
	pop	esi
  end;
end;

// --  --
function waveMix(const chunk1, chunk2, chunk3: unaPCMChunk; doAdd: bool = true): unsigned;
var
  samples: unsigned;
begin
  samples := min(waveGetChunkCurSamplesCount(chunk1), waveGetChunkCurSamplesCount(chunk2));
  if (0 < samples) then
    result := waveMix(chunk1.chunkData, chunk2.chunkData, chunk3.chunkData, samples,
		      chunk1.chunkFormat.pcmBitsPerSample,
		      chunk2.chunkFormat.pcmBitsPerSample,
		      chunk3.chunkFormat.pcmBitsPerSample)
  else
    result := 0;
end;

// --  --
function waveGetVolume(buf: pointer; samples: unsigned; bits: unsigned; numChannels: unsigned; channel: unsigned; deltaMethod: bool): unsigned;
var
  w: int64;
begin
  w := 0;
  asm
	push	esi
	push	edi
	push	ebx

	mov	result, 0

	mov	ecx, samples
	cmp 	ecx, 0
	je	@exit		// exit if there are no samples

	mov	ebx, numChannels
	cmp 	ebx, 0
	je	@exit		// exit if there are 0 channels

	mov	eax, channel
	cmp	eax, ebx
	jae	@exit		// exit if (channel >= numChannels)

	// skip required number of channels
	mov	esi, buf
	imul	byte ptr bits	// AX = channel * bits
	cwde			// EAX <- AX
	shr	eax, 3		// convert to bytes
	add	esi, eax	// advance to the beginning of channel

	// calculate size of sample (minus one channel)
	mov	eax, ebx
	dec	eax		// this is required since ESI will be increased by one channel every load
	imul	byte ptr bits	// AX = numChannels * bits
	cwde			// EAX <- AX
	shr	eax, 3		// convert to bytes
	mov	ebx, eax	//

	xor	edx, edx	// delta = 0

  @loop:
	mov	al, byte ptr bits
	call	loadSample		// EAX gets 32 bits signed integer
					// ESI shifts to next value
	cmp	deltaMethod, 0
	je	@doit

	// -- calculate sample as delta

	mov	edi, eax	// save current sample

	cmp	edx, eax
	jle	@lower		// EDX is lower then EAX

	sub	edx, eax
	mov	eax, edx
	jmp	@doit

  @lower:
	sub	eax, edx

  @doit:
	imul	eax		// EDX:EAX = EAX * EAX
	add	dword ptr w, eax
	adc	dword ptr w[4], edx

	add	esi, ebx	// move pointer to next sample for this channel
	mov	edx, edi	// restore EDX (it must contain prev. sample value for delta method)

	loop	@loop

	// --- loop ends here ---------------

	fild	w			// put w into ST(0)
	fidiv	dword ptr samples	// divide w on N
	fsqrt				// get square root

	fistp	w			// put ST(0) into w and pop FPU stack
	fwait				//

	mov	eax, dword ptr w	// assume w is less than 0x100000000
	mov	result, eax		// range is from 0 to 32'768

  @exit:
	pop	ebx
	pop	edi
	pop	esi
  end;
end;

// --  --
function waveExtractChannel(buf, dest: pointer; samples: unsigned; bits: unsigned; numChannels: unsigned = 1; channel: unsigned = 0): unsigned; assembler;
asm
{
	IN:	EAX = buf
		EDX = dest
		ECX = samples
		[ebp + $10] = bits
		[ebp + $0C] = numChannels
		[ebp + $08] = channel

	OUT:	EAX = num of samples stored
}
	push	esi
	push	edi
	push	ebx
	//
	push	ecx	// save number of samples

	mov	esi, eax	// ESI gets source ptr
	sub	eax, eax	// result := 0

	cmp 	ecx, 0
	je	@exit		// exit if there are no samples

	mov	ebx, numChannels
	cmp 	ebx, 0
	je	@exit		// exit if there are no channels

	mov	edi, edx	// EDI gets dest buf ptr

	mov	edx, channel
	cmp	edx, ebx
	jae	@exit		// exit if (channel >= numChannels)

	// skip required number of channels
	mov	bl, byte ptr bits
	mov	eax, edx	// EAX = channel
	imul	bl		// AX = channel * bits
	cwde			// EAX <- AX
	shr	eax, 3		// convert to bytes
	add	esi, eax	// advance to the beginning of channel

  @cont1:
	// calculate size of sample (minus one channel)
	mov	eax, numChannels
	dec	eax		// this is required since ESI will be increased by one channel every load
	imul	bl		// AX = numChannels * bits
	cwde			// EAX <- AX
	shr	eax, 3		// convert to bytes
	mov	edx, eax	// EDX = size of sample in bytes (munis one channel)

  @loop:
	mov	al, bl
	call	loadSample	// EAX gets 32 bits signed integer
				// ESI shifts to next value

	call	saveSample	// sample is stored in dest
				// EDI shifts to next value

	add	esi, edx	// move pointer to next sample for this channel
	loop	@loop

	// --- loop ends here ---------------
	pop	eax	// EAX = number of samples
	push	eax

  @exit:
	pop	ecx	// restore ESP pointer
	//
	pop	ebx
	pop	edi
	pop	esi
end;

// --  --
function waveReplaceChannel(buf, source: pointer; samples: unsigned; bits: unsigned; numChannels: unsigned = 1; channel: unsigned = 0): unsigned; assembler;
asm
{
	IN:	EAX = buf
		EDX = source
		ECX = samples
		[ebp + $10] = bits
		[ebp + $0C] = numChannels
		[ebp + $08] = channel

	OUT:	EAX = num of samples stored
}
	push	esi
	push	edi
	push	ebx
	//
	push	ecx	// save number of samples

	mov	edi, eax	// EDI gets buf ptr (destination)
	sub	eax, eax	// result := 0

	cmp 	ecx, 0
	je	@exit		// exit if there are no samples

	mov	ebx, numChannels
	cmp 	ebx, 0
	je	@exit		// exit if there are no channels

	mov	esi, edx	// ESI gets source ptr (channel data)

	mov	edx, channel
	cmp	edx, ebx
	jae	@exit		// exit if (channel >= numChannels)

	// skip required number of channels
	mov	bl, byte ptr bits
	mov	eax, edx	// EAX = channel
	imul	bl		// AX = channel * bits
	cwde			// EAX <- AX
	shr	eax, 3		// convert to bytes
	add	edi, eax	// advance to the beginning of channel

  @cont1:
	// calculate size of sample (minus one channel)
	mov	eax, numChannels
	dec	eax		// this is required since ESI will be increased by one channel every load
	imul	bl		// EDX:EAX = numChannels * bits
	cwde			// EAX <- AX
	shr	eax, 3		// convert to bytes
	mov	edx, eax	// EDX = size of sample in bytes (munis one channel)

  @loop:
	mov	al, bl
	call	loadSample	// EAX gets 32 bits signed integer
				// ESI shifts to next value

	call	saveSample	// sample is stored in dest
				// EDI shifts to next value

	add	edi, edx	// move pointer to next sample for this channel
	loop	@loop

	// --- loop ends here ---------------
	pop	eax	// EAX = number of samples
	push	eax

  @exit:
	pop	ecx	// restore ESP pointer
	//
	pop	ebx
	pop	edi
	pop	esi
end;

// --  --
function waveReverse(buf: pointer; samples: unsigned; bits: unsigned; numChannels: unsigned): unsigned; assembler;
asm
{
	IN:	EAX = buf
		EDX = samples
		ECX = bits
		[ebp + $08] = numChannels

	OUT:	EAX = num of samples processed
}
	push	esi
	push	edi
	push	ebx
	//

	mov	edi, eax	// EDI gets buf ptr (channel data)
	sub	eax, eax	// result := 0

	cmp 	edx, 0
	je	@exit		// exit if there are no samples

	mov	esi, edi	// ESI gets buf ptr (channel data)

	mov	eax, ecx
	shr	eax, 3		// convert number of bits to number of bytes
	mov	bh, al		// will need this later
	mov	bl, byte ptr numChannels
	imul	bl		// AX = number of bytes in one sample
	cwde			// EAX <- AX

	mov	bl, cl		// BL get number of bits in sample
	mov	ecx, edx	// ECX = num of samples

	dec	edx		// need one sample less
	imul	edx		// EDX:EAX = number of bytes in chunk
	add	eax, edi	// get to the end of buffer (assuming EDX=0)

	mov	edi, eax	// EDI = end of buffer

	shr	ecx, 1		// need only one half of buffer
	cmp	ecx, 0
	je	@exit		// exit if there are no samples

	sub	eax, eax
	mov	al, bh
	cwde
	mov	edx, eax

	mov	bh, byte ptr numChannels

  @loop:
	push	ecx

  @loop_channels:
	mov	al, bl
	call	loadSample	// EAX gets 32 bits signed integer
				// ESI shifts to next value
	mov	ecx, eax

	xchg	esi, edi
	sub	edi, edx	// shift back one value

	mov	al, bl
	call	loadSample
	call	saveSample

	xchg	esi, edi
	sub	edi, edx	// shift back one value

	mov	eax, ecx	// restore value
	call	saveSample	// EDI shifts to next value

	dec 	bh
	cmp 	bh, 0
	jne	@loop_channels	// repeat for all channels

	sub	eax, eax
	mov	al, dl
	mov	bh, byte ptr numChannels
	imul	bh
	cwde
	sub	edi, eax	// shift two samples back
	sub	edi, eax

	pop	ecx
	loop	@loop		// repear for half of samples

	// --- loop ends here ---------------
	pop	eax	// EAX = number of samples
	push	eax

  @exit:
	//
	pop	ebx
	pop	edi
	pop	esi
end;

// --  --
function waveGetLogVolume(volume: int): unsigned; assembler;
asm
	mov	ecx, volume	// ECX = volume level, from 0 to 32768

	sub	eax, eax	// result := 0
	cmp	ecx, -1
	je	@done

	cmp	ecx, 32768
	mov	eax, 300
	jae	@done

	sub	eax, eax

	//
	cmp	ecx, 32
	jb	@done   	// volume is too low - assume 0

	fldlg2			// push log.10(2) constant

	push	ecx		// allocate 4 bytes on stack

        {$IFDEF CPU64 }
	fild	dword ptr [rsp]	// push volume on stack
	fwait
	mov	dword ptr [rsp], 32
	fidiv	dword ptr [rsp]	// ST(0) := volume / 32
        {$ELSE }
	fild	dword ptr [esp]	// push volume on stack
	fwait
	mov	dword ptr [esp], 32
	fidiv	dword ptr [esp]	// ST(0) := volume / 32
        {$ENDIF CPU64 }

	{ log.10(X) = log.2(X) * log.10(2) }

	fyl2x		// ST(1) <- ST(1) * log.2(ST(0))
			// and pops FPU stack
        {$IFDEF CPU64 }
	mov	dword ptr [rsp], 100
	fimul	dword ptr [rsp]

	fistp 	dword ptr [rsp]	// convert ST(0) into integer are pop FPU stack
        {$ELSE }
	mov	dword ptr [esp], 100
	fimul	dword ptr [esp]

	fistp 	dword ptr [esp]	// convert ST(0) into integer are pop FPU stack
        {$ENDIF CPU64 }

	fwait

	pop	eax	// restore esp and get result
  @done:
end;

// --  --
function waveGetLogVolume100(volume: int): unsigned;
begin
  result := waveGetLogVolume(volume) div 3;
end;

// --  --
function waveResample(bufSrc, bufDst: pointer; samples, numChannelsSrc, numChannelsDst, bitsSrc, bitsDst, rateSrc, rateDst: unsigned): unsigned;
const
  const_dstChannelMul = 100;
var
  step: double;
  next: double;
  u: uint32;
  srcChannel: unsigned;
  dstChannelStep: unsigned;
  sample: unsigned;
begin
  if (
      (nil = bufSrc) or
      (nil = bufDst) or
      (1 > bitsSrc) or
      (1 > bitsDst) or
      (1 > numChannelsSrc) or
      (1 > numChannelsDst) or
      (1 > samples) or
      (1 > rateSrc) or
      (1 > rateDst)
     ) then
    // invalid params
    result := 0
  else begin
    //
    if (
	(rateDst = rateSrc) and
	(numChannelsSrc = numChannelsDst) and
	(bitsSrc = bitsDst)
       ) then begin
      //
      result := samples * numChannelsSrc * bitsSrc shr 3;
      if ((bufSrc <> bufDst) and (0 < result)) then
	move(bufSrc^, bufDst^, result);
      //
      exit;	// nothing to do
    end;
    //
    next := 0;
    step := rateDst / rateSrc;
    //
    //dstChannelMul := 100;
    dstChannelStep := (numChannelsDst * const_dstChannelMul) div numChannelsSrc;

    asm
	push	esi
	push	edi
	push	ebx

	//cld			// should be
	mov	esi, bufSrc	// set source pointer
	mov	edi, bufDst	// set dest pointer
	mov	ecx, samples	// set samples counter
	mov	bl, byte ptr bitsDst	// set dest sample size
	mov	bh, byte ptr bitsSrc	// set source sample size

	fld	next		// push next on FPU stack
	xor	edx, edx	// EDX is a sample counter in dest buffer

	// --------- loop ends here ------
	
  @loop:
	push	ecx	// save ECX

	fadd	step	// go to next sample
	fist	u	// round the floating point value to unsigned
	fwait		//

	cmp	edx, u		// do we need to store this source sample into dest buffer?
	jae	@nextSrcSample	// if no, skip this sample

	// -- store this sample

  @storeSample:
	// save ESI since it could be required to store same sample several times
	push	esi
	push	edx

	xor	eax, eax
	mov	srcChannel, eax		// source channel counter
	mov	sample, eax		// sample value
	mov	edx, eax		// number of source channels mixed so far
	mov	ecx, eax		// dest channel number

  @loopSrcChannels:
	mov	al, bh
	call	loadSample		// get source sample value into EAX
	inc	srcChannel		// inc the source channel counter
	add	sample, eax		// mix this sample
	inc	edx			// inc number of mixed channels

  //@storeDstChannel:
	add	ecx, dstChannelStep		// go to next channel in dest buffer
	cmp	ecx, const_dstChannelMul	// should we store the source channel?
	jb	@nextSrcChannel			// if no, go to next source channel

	mov	eax, sample	// prepare to store the sample
	cmp	edx, 1		// should we care about mixing?
	je	@skipSampleDiv	// if no, skip division

        jmp     @skip

  @loop1:
        jmp @loop

  @skip:
	push	ecx
	mov	ecx, edx
	cdq
	idiv	ecx		// divide mixed sample on number of channels
				// this way we should avoid increasing the volume level
	pop	ecx

  @skipSampleDiv:
	mov	edx, ecx	// set number of dest channels we must fill

	xor	ecx, ecx
	mov	sample, ecx	// zero sample value

	mov	ecx, eax	// save EAX value

  @loopDstChannel:
	mov	eax, ecx	// restore EAX value
	// BL must be set to bits number
	call 	saveSample	// store samples into dest buffer

	sub	edx, const_dstChannelMul	// go to next dest channel
	cmp	edx, const_dstChannelMul	// do we have more channels?
	jae	@loopDstChannel			// if yes, store the sample into next dest channel

	xor	ecx, ecx	// zero dest channel number
	mov	edx, ecx	// zero number of source channels mixed so far

  @nextSrcChannel:
	mov	eax, srcChannel		//
	cmp	eax, numChannelsSrc	// do we have more source channels?
	jb	@loopSrcChannels	// if yes, go to next source channel

	pop	edx
	// restore original ESI
	pop	esi

	inc	edx	       	// go to next dest sample
	cmp	edx, u		// do we have more dest samples to fill?
	jb	@storeSample	// if yes, save this source sample just one more time

  @nextSrcSample:
	// here we need to go to the next source sample
	mov	eax, numChannelsSrc	// assuming there are no more than $FF channels
	imul	bh			// byte ptr bitsSrc
	cwde				// EAX <- AX
	shr 	eax, 3
	add	esi, eax		// move source pointer to next sample

  //@goLoop:
	pop	ecx		// restore source samples counter
	loop	@loop1		// and loop if there are more samples to handle

	// --------- loop ends here ------

	fstp	next	// pop next from FPU stack

	mov	eax, edi
	sub	eax, bufDst
	mov	u, eax

	pop	ebx
	pop	edi
	pop	esi
    end;
    //
    result := u;
  end;
end;

// --  --
function waveResample(const bufSrc: unaPCMChunk; var bufDst: unaPCMChunk): unsigned;
var
  samples: unsigned;
begin
  samples := waveGetChunkCurSamplesCount(bufSrc);
  result := waveResample(bufSrc.chunkData, bufDst.chunkData, samples,
			 bufSrc.chunkFormat.pcmNumChannels,
			 bufDst.chunkFormat.pcmNumChannels,
			 bufSrc.chunkFormat.pcmBitsPerSample,
			 bufDst.chunkFormat.pcmBitsPerSample,
			 bufSrc.chunkFormat.pcmSamplesPerSecond,
			 bufDst.chunkFormat.pcmSamplesPerSecond);
  bufDst.chunkDataLen := result;
end;

// --  --
function waveGetChunkMaxSamplesCount(const chunk: unaPCMChunk): unsigned;
begin
  with chunk do begin
    //
    if ((0 < chunkFormat.pcmBitsPerSample) and (0 < chunkFormat.pcmNumChannels)) then
      result := (chunkBufSize shl 3) div (chunkFormat.pcmBitsPerSample * chunkFormat.pcmNumChannels)
    else
      result := 0;
    //
  end;    
end;

// --  --
function waveGetChunkCurSamplesCount(const chunk: unaPCMChunk): unsigned;
begin
  with chunk do begin
    //
    if ((0 < chunkFormat.pcmBitsPerSample) and (0 < chunkFormat.pcmNumChannels)) then
      result := (chunkDataLen shl 3) div (chunkFormat.pcmBitsPerSample * chunkFormat.pcmNumChannels)
    else
      result := 0;
    //
  end;    
end;

// --  --
function waveReallocateChunk(var chunk: unaPCMChunk; numSamples: unsigned): unsigned;
begin
  result := (numSamples * chunk.chunkFormat.pcmBitsPerSample * chunk.chunkFormat.pcmNumChannels) shr 3;
  chunk.chunkBufSize := result;
  chunk.chunkDataLen := 0;	// make sure buffer will not be abused
  mrealloc(chunk.chunkData, result);
end;

// --  --
function waveReadFromChunk(var chunk: unaPCMChunk; buf: pointer; size: unsigned; bufOffs: unsigned = 0): unsigned;
begin
  if ((nil <> buf) and (0 < size) and (size > bufOffs) and (0 < chunk.chunkDataLen)) then begin
    //
    result := min(chunk.chunkDataLen, size - bufOffs);
    if (0 < result) then begin
      //
      move(chunk.chunkData^, pChar(buf)[bufOffs], result);
      dec(chunk.chunkDataLen, result);
      //
      if (0 < chunk.chunkDataLen) then
	move(pChar(chunk.chunkData)[result], chunk.chunkData^, chunk.chunkDataLen);
    end;
  end
  else
    result := 0;
end;

// --  --
function waveWriteToChunk(var chunk: unaPCMChunk; buf: pointer; size: unsigned; bufOffs: unsigned = 0): unsigned;
begin
  if ((nil <> buf) and (0 < size) and (size > bufOffs) and (chunk.chunkBufSize > chunk.chunkDataLen)) then begin
    //
    result := min(chunk.chunkBufSize - chunk.chunkDataLen, size - bufOffs);
    if (0 < result) then begin
      move(pChar(buf)[bufOffs], pChar(chunk.chunkData)[chunk.chunkDataLen], result);
      inc(chunk.chunkDataLen, result);
    end;
  end
  else
    result := 0;
end;

// --  --
function waveFindNextGcd(rate1, rate2: unsigned; startFrom: unsigned): unsigned;
var
  d: unsigned;
  maximum: unsigned;
begin
  maximum := min(rate1, rate2);
  //
  d := startFrom - 1;
  repeat
    //
    inc(d);
    //
    result := gcd(d, rate1);
    if (result = d) then
      result := gcd(d, rate2);
    //
  until ((d = result) or (d >= maximum));
  //
  result := d;
end;

// --  --
function waveModifyVolume100(volume: unsigned; buf: pointer; samples: unsigned; bits: unsigned; numChannels: unsigned; channel: int): unsigned;
var
  hundred: uint32;
begin
  result := 0;
  if ((0 < samples) and
      (0 < bits) and
      (0 < numChannels) and
      ((0 > channel) or (int(numChannels) > channel))) then begin
    //
    hundred := 100;
    if (hundred <> volume) then begin
      //
      asm
          push	esi
          push	edi
          push	ebx

          mov	ecx, samples
          mov	esi, buf
          mov	edi, esi
          mov	bl, byte ptr bits	// dest buffer bits number
          mov	bh, bl

          mov	edx, 0	// channel number

    @loop:
          mov	al, bl
          call 	loadSample

          cmp     channel, -1
          je	@modify

          cmp	channel, edx
          je	@modify

          jmp	@nextChannel

    @modify:
          push	edx
          imul	volume
          idiv	hundred
          pop	edx

    @nextChannel:
          // BL must be set to bits number
          call	saveSample

          inc	edx
          cmp	edx, numChannels
          jb	@loop

          mov	edx, 0
          loop	@loop

          //  -- loop ends here --
          pop	ebx
          pop	edi
          pop	esi
      end;
    end;
    //
    result := samples;
  end;
end;

// --  --
function waveModifyVolume100(volume: unsigned; const chunk: unaPCMChunk; channel: int): unsigned;
var
  samples: unsigned;
begin
  if (100 <> volume) then begin
    //
    samples := waveGetChunkCurSamplesCount(chunk);
    if (0 < samples) then
      result := waveModifyVolume100(volume, chunk.chunkData, samples, chunk.chunkFormat.pcmBitsPerSample, chunk.chunkFormat.pcmNumChannels, channel)
    else
      result := 0;
  end
  else
    // pretend we have processed all samples
    result := waveGetChunkCurSamplesCount(chunk);
end;


end.
