
{$I unaDef.inc }

program
  adpcm_test;

{$APPTYPE CONSOLE }

uses
  unaTypes, unaUtils, unaADPCM;

// --  --
procedure log(msg: string);
begin
  {$IFDEF DEBUG }
  writeln(msg);
  {$ELSE }
  logMessage(msg);
  {$ENDIF DEBUG }
end;

var
  inBytes, outBytes: int64;

// --  --
function decode(infile: string; variant: una_ADPCM_type): bool;
var
  outfile: string;
  inf, outf: thandle;
  dec: unaADPCM_decoder;
  buf, outbuf: pointer;
  size: unsigned;
  encsize, encsize_prev: unsigned;
  done, sz: int64;
begin
  result := false;
  inBytes := 0;
  outBytes := 0;
  encsize_prev := 0;
  //
  outfile := copy(infile, 1, length(infile) - length('.adpcm'));
  if (not fileExists(outfile)) then
    log(#13#10'Output file: <' + outfile +'> must exists, assuming it is mono, 16bits, WAV')
  else begin
    log(#13#10'Decoding file: <' + infile + '> into <' + outfile +'>, assuming it is mono, 16bits, WAV');
    //
    inf := fileOpen(infile);
    outf := fileOpen(outfile, true);
    fileSeek(outf, 44);
    dec := unaADPCM_decoder.create(variant);
    try
      sz := fileSize(inf);
      done := 0;
      size := $4000;
      buf := malloc(size);
      result := true;
      //
      while (done < sz) do begin
	//
	size := 4;
	encsize := 0;
	readFromFile(inf, @encsize, size);
	if (0 < encsize) then begin
	  //
	  inc(inBytes, size);
	  //
	  readFromFile(inf, buf, encsize);
	  if (0 < encsize) then begin
	    //
	    inc(inBytes, encsize);
	    //
	    size := dec.decode(buf, encsize, outbuf);
	    if (0 < size) then begin
	      //
	      if (0 = writeToFile(outf, outbuf, size)) then begin
		//
		inc(outBytes, size);
		//
		if (encsize_prev <> size) then begin
		  //
		  encsize_prev := size;
		  log(#13#10'Wrote ' + int2str(encsize_prev) + ' bytes.. ');
		end
		else
		  Write('*');
	      end
	      else
		break;
	    end
	    else
	      break;
	  end;
	end;
	//
	if (1 > size) then
	  break;
	//
	inc(done, 4 + encsize);
      end;
    finally
      fileClose(inf);
      fileClose(outf);
      freeAndNil(dec);
    end;
  end;
end;

// --  --
function encode(infile: string; variant: una_ADPCM_type): bool;
var
  outfile: string;
  inf, outf: thandle;
  enc: unaADPCM_encoder;
  buf, outbuf: pointer;
  size: unsigned;
  num_samples: int;
  encsize, encsize_prev: unsigned;
  done, sz: int64;
begin
  result := false;
  inBytes := 0;
  outBytes := 0;
  encsize_prev := 0;
  //
  outfile := infile + '.adpcm';
  if (44 + 4 > fileSize(infile)) then
    log(#13#10'Source file: <' + infile + '> is too short.')
  else begin
    //
    log(#13#10'Encoding file: <' + infile + '> into <' + outfile + '>, assuming input is mono, 16bits, WAV');
    //
    inf := fileOpen(infile);
    fileSeek(inf, 44);
    outf := fileCreate(outfile, true, true);
    enc := unaADPCM_encoder.create(variant);
    try
      //
      sz := fileSize(inf);
      done := 0;
      size := $4000;
      if (adpcm_IMA4 = variant) then
	inc(size, 2);	// read one more sample each time, IMA4 requires odd number of samples per encode
      //
      buf := malloc(size);
      result := true;
      //
      while (done < sz) do begin
	//
	readFromFile(inf, buf, size);
	if (0 < size) then begin
	  //
	  inc(inBytes, size);
	  //
	  num_samples := size shr 1;
	  case (variant) of

	    adpcm_IMA4: begin
	      //
	      if (1 <> (num_samples and 1)) then
		dec(num_samples);	// skip last sample in file
	    end;

	    else begin
	      //
	      if (0 <> (num_samples and 1)) then
		dec(num_samples);	// skip last sample in file
	    end;

	  end;
	  //
	  encsize := enc.encode(buf, num_samples, outbuf);
	  if (0 < encsize) then begin
	    //
	    if (0 = writeToFile(outf, @encsize, 4)) then begin
	      //
	      if (0 = writeToFile(outf, outbuf, encsize)) then begin
		//
		inc(outBytes, encsize + 4);
		//
		if (encsize_prev <> encsize) then begin
		  //
		  encsize_prev := encsize;
		  log(#13#10'Encsize=' + int2str(encsize) + ' bytes.. ');
		end
		else
		  Write('*');
	      end
	      else
		break;
	    end
	    else
	      break;
	    //
	  end
	  else
	    break;
	end;
	//
	if (1 > size) then
	  break;
	//
	inc(done, size);
      end;
    finally
      fileClose(inf);
      fileClose(outf);
      freeAndNil(enc);
    end;
  end;
end;

// --  --
function mode2str(variant: una_ADPCM_type): string;
begin
  case (variant) of

    adpcm_IMA4: result := 'IMA';
    adpcm_DVI4: result := 'DVI4';
    adpcm_VDVI: result := 'VDVI';
    else
      result := '<unknown:' + int2str(ord(variant)) + '>';

  end;
end;

var
  variant: una_ADPCM_type;
  infile: string;
  res: bool;
begin
  log('ADPCM test, Version 1.0  (c) 2010 Lake of Soft'#13#10);
  if (paramCount < 1) then begin
    //
    log('syntax: <infile.wav> [-d|-e] [-IMA|-DVI4|-VDVI]');
    log('    -d=decode|-e=encode / default is encode');
    log('    -IMA|DVI4|VDVI=method / default is IMA');
  end
  else begin
    //
    infile := paramStr(1);
    if (fileExists(infile)) then begin
      //
      variant := adpcm_IMA4;
      if (hasSwitch('dvi4')) then
	variant := adpcm_DVI4
      else
	if (hasSwitch('vdvi')) then
	  variant := adpcm_VDVI;
      //
      log('Assuming mode: ' + mode2str(variant));
      //
      if (hasSwitch('d')) then
	res := decode(infile, variant)
      else
	res := encode(infile, variant);
      //
      if (res) then
	log(#13#10'Done, ' + int2str(inBytes) + ' bytes read, ' + int2str(outBytes) + ' bytes written')
      else
	log(#13#10'Terminated due to some error.');
    end
    else
      log('Specified input file <' + infile + '> was not found.');
  end;
end.

