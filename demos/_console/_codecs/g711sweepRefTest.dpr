
{$APPTYPE CONSOLE }

{$I unaDef.inc }

program
  g711sweepRefTest;


uses
  Windows, unaTypes, unaUtils, unaG711;

var
  i: int;
  len: int64;
  sz: unsigned;
  inbuf, outbuf: pInt16Array;
begin
  if (paramCount > 1) then begin
    //
    if (fileExists(paramStr(1))) then begin
      //
      len := fileSize(paramStr(1));
      if (1 < len) then begin
	//
	logMessage('Reading srv file, size=' + int2str(len) + ' bytes.');
	//
	inbuf := malloc(len);
	outbuf := malloc(len);
	try
	  //
	  sz := len;
	  readFromFile(paramStr(1), inbuf, sz);
	  mswapbuf16(inbuf, sz);
	  //
	  if (hasSwitch('eu') or hasSwitch('eA') or (not hasSwitch('dA') and not hasSwitch('du'))) then begin
	    //
	    if (hasSwitch('eu')) then
	      ulaw_compress(sz shr 1, inbuf, outbuf)
	    else
	      alaw_compress(sz shr 1, inbuf, outbuf);	// default
	    //
	    // expand 8 to 16 (no sign extend)
	    for i := 0 to (len shr 1) - 1 do
	      inbuf[i] := pArray(outbuf)[i];
	    //
	    mswapbuf16(inbuf, sz);
	    writeToFile(paramStr(2), inbuf, sz);
	  end
	  else begin
	    //
	    // compress 16 to 8 (keep 8 LSB only)
	    for i := 0 to (len shr 1) - 1 do
	      pArray(inbuf)[i] := inbuf[i] and $FF;
	    //
	    if (hasSwitch('du')) then
	      ulaw_expand(sz shr 1, inbuf, outbuf)
	    else
	      alaw_expand(sz shr 1, inbuf, outbuf);	// default
	    //
	    mswapbuf16(outbuf, sz);
	    writeToFile(paramStr(2), outbuf, sz);
	  end;
	  //
	  logMessage('Encoding/decoding is done.');
	  //
	finally
	  mrealloc(inbuf);
	  mrealloc(outbuf);
	end;
      end
      else
	logMessage('Src file is too small.');
    end
    else
      logMessage('Count not file the src file <' + paramStr(1) + '>');
  end
  else
    logMessage(
      'G711 sweep reference test. Ver 1.0  (c) Lake of Soft  http://lakeofsoft.com/ '#13#10 +
      'Syntax: g711sweep  <src_file> <dst_file> </eA | /eu | /dA | /du>'#13#10 +
      '  eA - encode src with ALaw (default)'#13#10 +
      '  eu - encode src with muLaw'#13#10 +
      '  dA - decode src as ALaw'#13#10 +
      '  du - decode src as muLaw'#13#10 +
      ''#13#10 +
      '[Src and Dst file will be Word16 swapped (due to original reference files are in BE format)]'#13#10
    )
end.
