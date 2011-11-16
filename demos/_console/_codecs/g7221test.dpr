
(*
	----------------------------------------------

	  g7221test.dpr
	  Voice Communicator components version 2.5

	----------------------------------------------
	  Copyright (c) 2011-2011 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, Oct 2011

	  modified by:
		Lake, Oct 2011

	----------------------------------------------
*)

{$I unaDef.inc}

{$APPTYPE CONSOLE }

program
  g7221test;

uses
  unaTypes, unaUtils, unaG7221;

var
  outf: tHandle;
  outFrames: int;

type
  //
  myEnc = class(unaG7221Encoder)
  protected
    procedure notify(stream: pointer; sizeBytes: int); override;
  end;

  //
  myDec = class(unaG7221Decoder)
  protected
    procedure notify(stream: pointer; sizeBytes: int); override;
  end;


{ myEnc }

// --  --
procedure myEnc.notify(stream: pointer; sizeBytes: int);
begin
  writeToFile(outf, stream, sizeBytes);
  inc(outFrames);
end;


{ myDec }

// --  --
procedure myDec.notify(stream: pointer; sizeBytes: int);
begin
  writeToFile(outf, stream, sizeBytes);
  inc(outFrames);
end;


// -- main routines --

// --  --
function process(codec: unaG7221Coder; const fin_name, fout_name: wString): int;
var
  sz, szDone, fs, fileSz: unsigned;
  inf: tHandle;
  frame: array[word] of byte;
begin
  Randomize();
  //
  outFrames := 0;
  result := 0;
  szDone := 0;
  //
  inf := fileOpen(fin_name);
  fileSz := fileSize(inf);
  //
  writeLn('Processing input file, size=', fileSize2str(fileSz), ' ...');
  try
    outf := fileCreate(fout_name, true, true);
    try
      //
      fs := 32768;
      repeat
        //
        sz := 1 + random(fs);
        readFromFile(inf, @frame, sz);
        if (0 < sz) then
          inc(result, codec.write(@frame, sz))
        else
          break;
        //
        inc(szDone, sz);
        //
        write(percent(szDone, fileSz), '%'#13);
        //
      until (false);
      //
      writeLn;
      //
      result := result * codec.framesize;
      //
      freeAndNil(codec);
    finally
      fileClose(outf);
    end;
  finally
    fileClose(inf);
  end;
end;

// --  --
function encode(const fname: wString): int;
begin
  result := process(myEnc.create(switchValue('sr', false, 16000), switchValue('br', false, 24000)), fname, fname + '.g722');
end;

// --  --
function decode(const fname: wString): int;
begin
  result := process(myDec.create(switchValue('sr', false, 16000), switchValue('br', false, 24000)), fname, fname + '.pcm');
end;


// -- main --

var
  i: int;
  fname: wString;
begin
  writeLn('G.722.1 Encoder/Decoder, 1.0/2011     by Lake of Soft');
  writeLn('Based on C-source (c) 1999 Polycom			');
  //
  i := 1;
  fname := switchFileName(i);
  if ('' <> fname) then begin
    //
    if (hasSwitch('e')) then
      i := encode(fname)
    else
      i := decode(fname);
    //
    writeLn('Done, ', int2str(i, 10, 3), ' samples processed, ', int2str(outFrames, 10, 3), ' frames written.');
  end
  else
    writeLn('usage: <filename> [/e] [/sr=sampleRate] [/br=bitrate]');
end.

