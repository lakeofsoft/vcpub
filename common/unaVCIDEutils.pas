
(*
	----------------------------------------------

	  unaVcIDEutils.pas
	  Voice Communicator components version 2.5 Pro
	  VC Utility functions for VCL classes

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 09 Feb 2003

	  modified by:
		Lake, Feb-May 2003
		Lake, Sep 2005
		Lake, Jun 2009

	----------------------------------------------
*)

{$I unaDef.inc }

{*
  Utility functions for VC and VCL classes.

  @Author Lake
  @Version 2.5.2008.07 Still here
}

unit
  unaVCIDEutils;

interface

uses
  Windows, unaTypes
{$IFDEF __BEFORE_D6__ }
  , StdCtrls
{$ELSE }
  , Controls
{$ENDIF __BEFORE_D6__ }
  ;

type
  proc_waveDeviceEnumCallback = procedure(caps: pointer; isInput: bool; var name: wString; deviceId: unsigned; var okToAdd: bool); stdcall;

{*
  Enumerates waveIn or waveOut devices, and fills the supplied box.
  NOTE: sets high-order bit of list.tag if includeMapper = false
}
{$IFDEF __BEFORE_D6__ }
procedure enumWaveDevices(list: tListBox; enumWaveIn: bool = true; includeMapper: bool = true; callback: proc_waveDeviceEnumCallback = nil); overload;
procedure enumWaveDevices(list: tComboBox; enumWaveIn: bool = true; includeMapper: bool = true; callback: proc_waveDeviceEnumCallback = nil); overload;
{$ELSE }
procedure enumWaveDevices(list: tCustomListControl; enumWaveIn: bool = true; includeMapper: bool = true; callback: proc_waveDeviceEnumCallback = nil);
{$ENDIF __BEFORE_D6__ }

{*
  Returns wave deviceId which corresponds to selected itemIndex in the list.
}
{$IFDEF __BEFORE_D6__ }
function index2deviceId(list: tListBox): int; overload;
function index2deviceId(list: tComboBox): int; overload;
{$ELSE }
function index2deviceId(list: tCustomListControl): int;
{$ENDIF __BEFORE_D6__ }

{*
  Returns itemIndex which corresponds to specified deviceId
}
function deviceId2index(deviceId: int; includeMapper: bool = true): int;


implementation


uses
  unaUtils, MMSystem, unaMsAcmClasses, Classes;

{$IFDEF __BEFORE_D6__ }

// --   --
function doEnum(tag: int; list: tStrings; enumWaveIn: bool; includeMapper: bool; callback: proc_waveDeviceEnumCallback): int;
var
  i: unsigned;
  max: int;
  ok: bool;
  //
  capsIn: WAVEINCAPSW;
  capsOut: WAVEOUTCAPSW;

  // --  --
  procedure newItem(itemId: unsigned; const defValue: AnsiString);
  var
    wname: wString;
    caps: pointer;
  begin
    if (enumWaveIn) then begin
      ok := unaWaveInDevice.getCaps(itemId, capsIn);
      caps := @capsIn;
    end
    else begin
      ok := unaWaveOutDevice.getCaps(itemId, capsOut);
      caps := @capsOut;
    end;
    //
    with list do
      //
      if (ok) then begin
	//
	if (enumWaveIn) then
	  wname := capsIn.szPname
	else
	  wname := capsOut.szPname
      end
      else
	wname := defValue;
    //
    ok := true;
    if (assigned(callback)) then
      callback(caps, enumWaveIn, wname, itemId, ok);
    //
    if (ok) then
      list.add(wname);
  end;

begin
  list.clear();
  //
  if (includeMapper) then
    //
    newItem(WAVE_MAPPER, 'Wave Mapper');
  //
  if (enumWaveIn) then
    max := unaWaveInDevice.getDeviceCount()
  else
    max := unaWaveOutDevice.getDeviceCount();
  //
  if (0 < max) then
    for i := 0 to max - 1 do
      //
      newItem(i, 'Wave' + choice(enumWaveIn, 'In', 'Out') + ' Device #' + int2str(i));
  //
  result := tag;
  if (not includeMapper) then
    result := int(unsigned(result) or $80000000);
end;

// --  --
procedure enumWaveDevices(list: tListBox; enumWaveIn: bool; includeMapper: bool; callback: proc_waveDeviceEnumCallback); overload;
begin
  list.tag := doEnum(list.tag, list.items, enumWaveIn, includeMapper, callback);
end;

// --   --
procedure enumWaveDevices(list: tComboBox; enumWaveIn: bool; includeMapper: bool; callback: proc_waveDeviceEnumCallback); overload;
begin
  list.tag := doEnum(list.tag, list.items, enumWaveIn, includeMapper, callback);
end;

{$ELSE }

// --   --
procedure enumWaveDevices(list: tCustomListControl; enumWaveIn: bool; includeMapper: bool; callback: proc_waveDeviceEnumCallback);
var
  i: unsigned;
  max: int;
  ok: bool;
  //
  capsIn: WAVEINCAPSW;
  capsOut: WAVEOUTCAPSW;

  // --  --
  procedure newItem(itemId: unsigned; const defValue: wString);
  var
    wname: wString;
    caps: pointer;
  begin
    if (enumWaveIn) then begin
      //
      ok := unaWaveInDevice.getCaps(itemId, capsIn);
      caps := @capsIn;
    end
    else begin
      //
      ok := unaWaveOutDevice.getCaps(itemId, capsOut);
      caps := @capsOut;
    end;
    //
    with list do
      if (ok) then begin
	//
	if (enumWaveIn) then
	  wname := capsIn.szPname
	else
	  wname := capsOut.szPname;
      end
      else
	wname := defValue;
    //
    ok := true;
    if (assigned(callback)) then
      callback(caps, enumWaveIn, wname, itemId, ok);
    //
    if (ok) then
      list.addItem(wname, nil);
  end;

begin
  list.clear();
  //
  if (includeMapper) then
    newItem(WAVE_MAPPER, 'Wave Mapper');
  //
  if (enumWaveIn) then
    max := unaWaveInDevice.getDeviceCount()
  else
    max := unaWaveOutDevice.getDeviceCount();
  //
  if (0 < max) then begin
    //
    for i := 0 to max - 1 do
      newItem(i, 'Wave' + choice(enumWaveIn, 'In', 'Out') + ' Device #' + int2str(i));
  end;
  //
  if (not includeMapper) then
    list.tag := int(unsigned(list.tag) or $80000000);
end;

{$ENDIF __BEFORE_D6__ }

// --  --
function doGetindex(tag, itemIndex: int): int;
begin
  if (0 <> (tag and $80000000)) then
    // mapper was not included in the list
    result := itemIndex
  else
    if (0 = itemIndex) then
      result := int(WAVE_MAPPER)
    else
      result := itemIndex - 1;
end;


{$IFDEF __BEFORE_D6__ }

// --  --
function index2deviceId(list: tListBox): int;
begin
  result := doGetindex(list.tag, list.itemIndex);
end;

// --  --
function index2deviceId(list: tComboBox): int;
begin
  result := doGetindex(list.tag, list.itemIndex);
end;

{$ELSE }

// --  --
function index2deviceId(list: tCustomListControl): int;
begin
  result := doGetindex(list.tag, list.itemIndex);
end;

{$ENDIF __BEFORE_D6__ }

// --  --
function deviceId2index(deviceId: int; includeMapper: bool): int;
begin
  if (-1 = deviceId) then begin
    //
    if (includeMapper) then
      result := 0	// mapper is the first
    else
      result := -1;	// no mapper in the list
  end
  else
    if (includeMapper) then
      result := deviceId + 1	// adjust itemIndex
    else
      result := deviceId	// as is
end;


end.

