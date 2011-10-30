
(*
	----------------------------------------------

	  wavOut.dpr
	  Voice Communicator components version 2.5
	  Example on how to load and playback the file from memory

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 2 Mar 2003

	  modified by:
		Lake, Apr-Jun 2003
		Lake, Oct 2005
                Lake, Jun 2009

	----------------------------------------------
*)

{$DEFINE CONSOLE }      // for some reason not defined by compiler in main project file
			// needed for unaDef.inc to work correctly

{$IFDEF CONSOLE }
  {$APPTYPE CONSOLE }
{$ENDIF CONSOLE }

{$I unaDef.inc }

program
  wavOut;

uses
  Windows, unaTypes, unaUtils, unaClasses,
  MMSystem, unaWave, unaMsAcmClasses;

{$R *.res }

type

  //
  // -- wavOutClass --
  //
  wavOutClass = class(unaObject)
  private
    f_acm: unaMsAcm;
    f_wavRead: unaRiffStream;
    f_waveOut: unaWaveOutDevice;
    //        wndProc
    f_data: pointer;
    f_dataSize: unsigned;
    f_dataPos: unsigned;
    f_backChunk: pointer;
    f_sampleSize: unsigned;
    //
    f_isLoop: bool;
    f_isBack: bool;
    f_loopCount: int;
    f_done: bool;
    //
    procedure myOnDA(sender: tObject; data: pointer; len: uint);
    procedure myOnACD(sender: tObject; data: pointer; len: uint);
  public
    procedure BeforeDestruction(); override;
    //
    function init(): bool;
    procedure run();
  end;


{ wavOutClass }

//
procedure wavOutClass.beforeDestruction();
begin
  f_done := true;	// Don't feed the animals!
  //
  freeAndNil(f_wavRead);
  freeAndNil(f_waveOut);
  freeAndNil(f_acm);
  //
  mrealloc(f_data);
  mrealloc(f_backChunk);
  //
  logMessage('Done.');
end;

//
function wavOutClass.init(): bool;
var
  i: int;
  s: string;
begin
  result := false;
  logMessage('Init.');
  //
  if (0 < paramCount) then begin
    //
    s := '';
    for i := 1 to paramCount do begin
      //
      s := paramStr(i);
      if (('' <> s) and (not (aChar(s[1]) in ['/', '\']))) then
	break
      else
	s := '';
    end;
    //
    if ('' <> s) then begin
      //
      f_acm := unaMsAcm.create();
      f_acm.enumDrivers();
      f_wavRead := unaRiffStream.create(s, false, false, f_acm);
      //
      result := (0 = f_wavRead.status);
      //
      if (result) then begin
	//
	logMessage('Input file:  <' + s + '>');
	//
	f_wavRead.onDataAvailable := myOnDA;
	f_wavRead.assignStream(false, nil);
	//
	f_waveOut := unaWaveOutDevice.create(unsigned(switchValue('d', false, int(WAVE_MAPPER))), false, false, 5);
	f_waveOut.onAfterChunkDone := myOnACD;
	f_waveOut.setSamplingExt(true, f_wavRead.dstFormatExt);
	//
	f_isLoop := hasSwitch('L');
	f_isBack := hasSwitch('B');
      end;
    end;
  end
  else
    logMessage(
      '  syntax: wavOut <file.wav> [/l] [/b] [/dN]'#13#10#13#10 +
      '			/l  - loop'#13#10 +
      '			/b  - backward direction'#13#10 +
      '			/dN - use waveOut device #N');
end;

//
procedure wavOutClass.myOnACD(sender: tObject; data: pointer; len: uint);
var
  size: int;
  feed: unsigned;
  waveOut: unaWaveOutDevice;
begin
  if (f_done) then
  else begin
    //
    waveOut := unaWaveOutDevice(sender);
    if ((0 < f_dataSize) and f_isLoop or (not f_isLoop and (1 > f_loopCount))) then begin
      //
      feed := 0;
      repeat
	//
	if (f_isBack) then begin
	  //
	  size := min(len - feed, f_dataPos);
	  //
	  if (0 < size) then begin
	    dec(f_dataPos, size);
	    move(pArray(f_data)[f_dataPos], f_backChunk^, size);
	    //
	    // reverse samples
	    waveReverse(f_backChunk, size div int(f_sampleSize), waveOut.srcFormatExt.Format.wBitsPerSample, waveOut.srcFormatExt.Format.nChannels);
	    //
	    waveOut.write(f_backChunk, size);
	  end;
	  //
	  if (1 > f_dataPos) then begin
	    //
	    inc(f_loopCount);
	    f_dataPos := f_dataSize;	// loop
	  end;
	end
	else begin
	  //
	  size := min(int(len - feed), int(f_dataSize - f_dataPos));
	  //
	  if (0 < size) then begin
	    //
	    waveOut.write(@pArray(f_data)[f_dataPos], size);
	    //
	    inc(f_dataPos, size);
	  end;
	  //
	  if (f_dataPos >= f_dataSize) then begin
	    //
	    inc(f_loopCount);
	    f_dataPos := 0;		// loop
	  end;
	end;
	//
	inc(feed, size);
	//
      until ((not f_isLoop and (0 < f_loopCount)) or (1 > size) or (feed >= len));
    end;
  end;
end;

//
procedure wavOutClass.myOnDA(sender: tObject; data: pointer; len: uint);
var
  pos: int;
begin
  if ((nil <> data) and (0 < len)) then begin
    //
    pos := f_dataSize;
    inc(f_dataSize, len);
    mrealloc(f_data, f_dataSize);
    //
    move(data^, pArray(f_data)[pos], len);
  end;
end;

//
procedure wavOutClass.run();
begin
  logMessage('Loading input file...');
  f_wavRead.open();
  //
  while (not f_wavRead.streamIsDone) do begin
    // wait until the whole file is loaded into memory
    Sleep(50);
  end;
  //
  f_wavRead.close();	// no longer needed
  //
  logMessage('Done, memory taken: ' + int2str(f_dataSize shr 10, 10, 3) + ' KB');
  logMessage('Starting playback...');
  //
  if (f_isBack) then begin
    //
    f_dataPos := f_dataSize;
    f_backChunk := malloc(f_waveOut.chunkSize);
    f_sampleSize := (f_waveOut.srcFormatExt.Format.wBitsPerSample shr 3) * f_waveOut.srcFormatExt.Format.nChannels;
  end;
  //
  f_loopCount := 0;
  f_waveOut.open();
  f_waveOut.flush();	// start self-feedback process
  //
  logMessage(#13#10'-------------------------' +
	     #13#10'Backward direction: ' + bool2strStr(f_isBack) +
	     #13#10'Looped playback   : ' + bool2strStr(f_isLoop) +
	     #13#10'-------------------------' +
	     #13#10'Press Esc to terminate' +
	     #13#10'');
  //
  repeat
    //
    if (0 <> (GetKeyState(VK_ESCAPE) and $8000)) then
      break;
    //
    Sleep(50);
{$IFDEF CONSOLE }
    write('Playback position: ' + int2str(f_dataPos, 10, 3) + ';   Loops: ' + int2str(f_loopCount) + '              '#13);
{$ENDIF CONSOLE }
    //
  until (not f_isLoop and (0 < f_loopCount));
  //
  FlushConsoleInputBuffer(GetStdHandle(STD_INPUT_HANDLE));	// remove all pressed keys from queue
  //
{$IFDEF CONSOLE }
  logMessage('');
{$ENDIF CONSOLE }
end;


// -- main --

begin
  logMessage('wavOut,  version 2.5.4   Copyright (c) 2003-2009 Lake of Soft');
  logMessage('VC Components version 2.5            http://lakeofsoft.com/vc'#13#10);
  //
  with (wavOutClass.create()) do
    try
      if (init()) then
	run();
    finally
      free();
    end;
end.

