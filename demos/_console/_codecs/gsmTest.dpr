
{$I unaDef.inc }

program
  gsmTest;

{$APPTYPE CONSOLE}


uses
  unaTypes, unaUtils, unaClasses, unaGSM;

type
  //
  myEncoder = class(unaGSMEncoder)
  protected
    procedure onNewData(sender: unaObject; data: pointer; len: int); override;
  end;

  //
  myDecoder = class(unaGSMDecoder)
  protected
    procedure onNewData(sender: unaObject; data: pointer; len: int); override;
  end;


var
  w49: bool;
  g_offs: int64;
  g_out: int64;
  g_proc: int64;
  g_outf: tHandle;
  g_frcount: int64;


// --  --
procedure writeOutput(data: pointer; len: int);
begin
  if (0 = writeToFile(g_outf, data, len)) then
    inc(g_out, len);
end;


{ myEncoder }

// --  --
procedure myEncoder.onNewData(sender: unaObject; data: pointer; len: int);
begin
  writeOutput(data, len);
end;


{ myDecoder }

// --  --
procedure myDecoder.onNewData(sender: unaObject; data: pointer; len: int);
begin
  writeOutput(data, len);
end;



{ main routines }


// --  --
function process(ed: unaGSMcoder; const fname, foutname: wString): int;
var
  buf: array[0..16383] of byte;
  fsize, size: int64;
  pc, pc1: int;
  sz: unsigned;
  h: tHandle;
begin
  Randomize();
  //
  result := 0;
  size := fileSize(fname);
  fsize := size;
  h := fileOpen(fname);
  //
  ed.gsmOpt[GSM_OPT_WAV49] := choice(w49, 1, 0);
  //
  g_outf := fileCreate(foutname, true, true);
  try
    //
    pc1 := -1;
    g_frcount := 0;
    //
    if (0 < g_offs) then
      fileSeek(h, g_offs);
    //
    while (0 < size) do begin
       //
       sz := 1 + random(sizeof(buf));
       readFromFile(h, @buf, sz);
       if (0 < sz) then begin
         //
         inc(g_proc, ed.write(@buf, sz));
         //
         dec(size, sz);
         inc(result, sz);
         inc(g_frcount);
       end
       else
         break;   // some problem on read
       //
       pc := percent(result, fsize);
       if (pc1 <> pc) then begin
         //
         pc1 := pc;
         write('Processing, ', pc, '%       '#13);
       end;
    end;
  finally
    fileClose(h);
    fileClose(g_outf);
  end;
end;

// --  --
function encode(const fname: wString): int;
begin
  result := process(myEncoder.create(), fname, fname + '.gsm');
end;

// --  --
function decode(const fname: wString): int;
begin
  result := process(myDecoder.create(), fname, fname + '.pcm');
end;


// -- main --

var
  e, d: bool;
  fname: wString;
  i, sz: int;
begin
  writeLn('GSM Encoder/Decoder, 1.0/2011 				     by Lake of Soft');
  writeLn('Based on C-source Copyright 1992, 1993, 1994 by Jutta Degener and Carsten Bormann');
  //
  e := hasSwitch('e');
  d := hasSwitch('d');
  w49 := hasSwitch('wav49');
  g_offs := switchValue('o', false, 0);
  //
  i := 1;
  fname := switchFileName(i);
  if ((e xor d) and ('' <> fname)) then begin
    //
    writeln('');
    writeln('Input file: <' + fname + '>');
    writeln('Operation : ' + choice(e, 'encoding', 'decoding'));
    writeln('Format    : ' + choice(w49, 'GSM6.10/WAV49', 'GSM6.10'));
    writeln('Offset    : ' + int2str(g_offs));
    writeln('');
    //
    if (e) then
      sz := encode(fname)
    else
      sz := decode(fname);
    //
    writeLn('Done, read/processed=', sz, '/', g_proc, ' bytes;  out bytes=', g_out, '/out frames=', g_frcount);
  end
  else
    writeLn('usage: gsmTest [/d | /e] [/wav49] [/o=input_offset] <infile> ');
end.

