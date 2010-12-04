
(*
	----------------------------------------------

	  u_mcDemo_main.pas - vcMultiClient demo main form source
	  VC 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 20 Oct 2003

	  modified by:
		Lake, Oct 2003
		Lake, Oct 2005
		Lake, Apr 2007

	----------------------------------------------
*)

{$I unaDef.inc }

unit
  u_mcDemo_main;

interface

uses
  Windows, unaTypes, unaClasses, Forms,
  unaVcIDE, ExtCtrls, ComCtrls, Controls, StdCtrls, Classes, ActnList,
  Menus, unaVC_wave, unaVC_pipe;

type
  Tc_form_main = class(TForm)
    c_button_audioConfig: TButton;
    c_bevel_top: TBevel;
    c_label_consumers: TLabel;
    c_statusBar_main: TStatusBar;
    c_timer_update: TTimer;
    c_listBox_consumers: TListBox;
    c_button_add: TButton;
    c_button_remove: TButton;
    c_actionList_main: TActionList;
    a_consumer_add: TAction;
    a_consumer_remove: TAction;
    c_button_open: TButton;
    c_button_close: TButton;
    a_source_open: TAction;
    a_source_close: TAction;
    waveIn: TunavclWaveInDevice;
    waveCodec: TunavclWaveCodecDevice;
    c_button_consumerOpen: TButton;
    c_button_consumerClose: TButton;
    a_consumer_open: TAction;
    a_consumer_close: TAction;
    c_mm_main: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    //
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    procedure formCreate(sender: tObject);
    procedure formDestroy(sender: tObject);
    procedure formShow(sender: tObject);
    //
    procedure c_timer_updateTimer(sender: tObject);
    procedure c_button_audioConfigClick(sender: tObject);
    //
    procedure a_source_openExecute(sender: tObject);
    procedure a_source_closeExecute(sender: tObject);
    procedure a_consumer_addExecute(sender: tObject);
    procedure a_consumer_removeExecute(sender: tObject);
    procedure a_consumer_openExecute(Sender: TObject);
    procedure a_consumer_closeExecute(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    f_config: unaIniFile;
    f_nameIndex: int;
    //
    function nextIndex(): string;
    function getConsumerInfo(consumer: unavclInOutPipe): string;
    procedure updateAudioInfo();
    procedure updateProvidersInfo();
  public
    { Public declarations }
    property config: unaIniFile read f_config;
  end;

var
  c_form_main: Tc_form_main;


implementation


{$R *.dfm}

uses
  unaUtils, unaVCLUtils, unaMsAcmClasses, unaVC_socks, ShellAPI,
  u_common_audioConfig,
  SysUtils, u_mcDemo_newConsumer;

// --  --
procedure Tc_form_main.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  a_source_close.execute();
  //
  c_timer_update.enabled := false;
  //
  saveControlPosition(self, f_config);
end;

// --  --
procedure Tc_form_main.formCreate(sender: tObject);
begin
  f_config := unaIniFile.create();
end;

// --  --
procedure Tc_form_main.formDestroy(sender: tObject);
begin
  freeAndNil(f_config);
end;

// --  --
procedure Tc_form_main.formShow(sender: tObject);
begin
  loadControlPosition(self, f_config);
  //
  c_form_common_audioConfig.setupUI(true, true, false);
  c_form_common_audioConfig.doLoadConfig(waveIn, nil, waveCodec, nil, f_config);
  //
  c_listBox_consumers.items.addObject(getConsumerInfo(waveCodec), waveCodec);
  updateAudioInfo();
  //
  c_timer_update.enabled := true;
end;

// --  --
procedure Tc_form_main.c_timer_updateTimer(sender: tObject);
var
  active: bool;
  i: int;
  consumer: unavclInOutPipe;
  index: int;
begin
  {$IFDEF DEBUG }
  c_statusBar_main.panels[0].text := 'Mem: ' + int2str(ams() shr 10, 10, 3) + ' KB';
  {$ENDIF }
  //
  active := waveIn.active;
  //
  c_button_audioConfig.enabled := not active;
  a_source_open.enabled := not active;
  a_source_close.enabled := active;
  a_consumer_add.enabled := active;
  index := c_listBox_consumers.itemIndex;
  a_consumer_remove.enabled := (0 < index);
  //
  a_consumer_open.enabled := (0 < index) and (0 = unavclInOutPipe(c_listBox_consumers.items.objects[index]).tag);
  a_consumer_close.enabled := (0 < index) and (0 <> unavclInOutPipe(c_listBox_consumers.items.objects[index]).tag);
  //
  // care "active/closed" display
  for i := 0 to c_listBox_consumers.items.count - 1 do begin
    //
    consumer := unavclInOutPipe(c_listBox_consumers.items.objects[i]);
    //
    //if (consumer.tag <> choice(consumer.active, 1, int(0))) then
      c_listBox_consumers.items[i] := getConsumerInfo(consumer);
  end;
  //
  // display selected device info
end;

// --  --
procedure Tc_form_main.c_button_audioConfigClick(sender: tObject);
begin
  c_form_common_audioConfig.doConfig(waveIn, nil, waveCodec, nil, f_config);
  updateAudioInfo();
end;

// --  --
function Tc_form_main.getConsumerInfo(consumer: unavclInOutPipe): string;
var
  wave: unavclInOutWavePipe;
  codec: TunavclWaveCodecDevice;
  ipPipe: unavclInOutIpPipe;
  broadPipe: unavclIPBroadcastPipe;
begin
  if (nil <> consumer) then begin
    //
    result := consumer.providerOneAndOnly.name + '.' + choice(consumer.providerOneAndOnly.active, 'A', 'x') + ' --> ' +
	      consumer.name + '.' + choice(consumer.active, 'A', 'x') + ' [' + int2str(consumer.inBytes, 10, 3)  + ' / ' + int2str(consumer.outBytes, 10, 3) + '] ' + '::';
    //
    if (consumer is unavclInOutWavePipe) then begin
      //
      wave := (consumer as unavclInOutWavePipe);
      if (nil <> wave.device) then begin
	//
	if (consumer is TunavclWaveCodecDevice) then begin
	  //
	  codec := consumer as TunavclWaveCodecDevice;
	  case (codec.driverMode) of

	    unacdm_acm: begin
	      //
	      result := result + 'ACM: Src=' + codec.codec.srcFormatInfo + '; Dst= ' + codec.codec.dstFormatInfo;
	    end;

	    unacdm_openH323plugin: begin
	      //
	      result := result + 'H323P: ' + codec.driverLibrary + ',  formatIndex=' + int2str(codec.formatTag);
	    end;

	  end;
	end
	else begin
	  //
	  result := result + wave.device.srcFormatInfo;
	  //
	  if (consumer is TunavclWaveResampler) then
	    result := result + ' -> ' + wave.device.dstFormatInfo;
	  //
	end;
      end;
    end;
    //
    if (consumer is unavclInOutIpPipe) then begin
      //
      ipPipe := (consumer as unavclInOutIpPipe);
      //
      result := result + choice(unapt_UDP = ipPipe.proto, 'UDP', 'TCP') + ':';
      //
      if (ipPipe is TunavclIPOutStream) then
	result := result + string(TunavclIPOutStream(ipPipe).host) + ':' + string(ipPipe.port)
      else
	result := result + string(ipPipe.port);
    end;
    //
    if (consumer is unavclIPBroadcastPipe) then begin
      //
      broadPipe := consumer as unavclIPBroadcastPipe;
      result := result + 'UDP:' + string(broadPipe.port);
    end;
    //
    // remember active state
    consumer.tag := choice(consumer.active, 1, int(0));
  end
  else
    result := ' [nil] ';
end;

// --  --
function Tc_form_main.nextIndex(): string;
begin
  InterlockedIncrement(f_nameIndex);
  result := int2str(f_nameIndex);
end;

// --  --
procedure Tc_form_main.updateAudioInfo();
begin
  c_listBox_consumers.items[0] := getConsumerInfo(waveCodec);
end;

// --  --
procedure Tc_form_main.a_source_openExecute(sender: tObject);
begin
  waveIn.open();
  //
  if (not waveIn.active) then begin
    //
    waveIn.close();
    raise exception.create('Unable to open waveIn device, error text: '#13#10 + waveIn.waveErrorAsString);
  end;
  //
  updateProvidersInfo();
end;

// --  --
procedure Tc_form_main.a_source_closeExecute(sender: tObject);
begin
  waveIn.close();
  //
  updateProvidersInfo();
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  shellExecute(handle, 'open', 'http://lakeofsoft.com/vc/a_multiconsumer.html', nil, nil, SW_SHOWNORMAL);
end;

// --  --
procedure Tc_form_main.a_consumer_addExecute(sender: tObject);
var
  consumer: unavclInOutPipe;
  index: int;
begin
  if (c_form_newConsumer.selectNewConsumer(index)) then begin
    //
    consumer := nil;
    case (index) of

      0: begin	// waveOut
	//
	consumer := TunavclWaveOutDevice.create(self);
	with (TunavclWaveOutDevice(consumer)) do begin
	  //
	  deviceId := c_form_newConsumer.waveOutDeviceID;
	  //
	  name := 'waveOut' + nextIndex();
	end;
	//
	waveIn.addConsumer(consumer);
      end;

      1: begin	// waveRiff
	//
	consumer := TunavclWaveRiff.create(self);
	with (TunavclWaveRiff(consumer)) do begin
	  //
	  fileName := c_form_newConsumer.riffName;
	  isInput := false;	// save to file
	  formatTag := waveCodec.formatTag;	// save file in same codec format
	  //
	  name := 'waveRiff' + nextIndex();
	end;
	//
	waveIn.addConsumer(consumer);
      end;

      2: begin	// ipClient
	//
	consumer := TunavclIPOutStream.create(self);
	with (TunavclIPOutStream(consumer)) do begin
	  //
	  proto := c_form_newConsumer.proto;
	  host := c_form_newConsumer.host;
	  port := c_form_newConsumer.port;
	  //
	  name := 'ipClient' + nextIndex();
	end;
	//
	waveCodec.addConsumer(consumer);
      end;

      3: begin	// ipServer
	//
	consumer := TunavclIPInStream.create(self);
	with (TunavclIPInStream(consumer)) do begin
	  //
	  proto := c_form_newConsumer.proto;
	  port := c_form_newConsumer.port;
	  //
	  name := 'ipServer' + nextIndex();
	end;
	//
	waveCodec.addConsumer(consumer);
      end;

      4: begin	// ipBroadcast
	//
	consumer := TunavclIPBroadcastServer.create(self);
	with (TunavclIPBroadcastServer(consumer)) do begin
	  //
	  port := c_form_newConsumer.port;
	  //
	  name := 'ipBroadcast' + nextIndex();
	end;
	//
	waveCodec.addConsumer(consumer);
      end;

    end;
    //
    if (nil <> consumer) then begin
      //
      c_listBox_consumers.items.addObject(getConsumerInfo(consumer), consumer);
    end;
  end;
end;

// --  --
procedure Tc_form_main.a_consumer_removeExecute(sender: tObject);
var
  index: int;
  consumer: tObject;
begin
  index := c_listBox_consumers.itemIndex;
  if (0 < index) then begin
    //
    consumer := c_listBox_consumers.items.objects[index];
    c_listBox_consumers.items.delete(index);
    //
    freeAndNil(consumer);
  end;
end;

// --  --
procedure Tc_form_main.a_consumer_openExecute(Sender: TObject);
var
  index: int;
  consumer: unavclInOutPipe;
begin
  index := c_listBox_consumers.itemIndex;
  //
  if (0 < index) then begin
    //
    consumer := unavclInOutPipe(c_listBox_consumers.items.objects[index]);
    consumer.open();
  end;
end;

// --  --
procedure Tc_form_main.a_consumer_closeExecute(Sender: TObject);
var
  index: int;
  consumer: unavclInOutPipe;
begin
  index := c_listBox_consumers.itemIndex;
  //
  if (0 < index) then begin
    //
    consumer := unavclInOutPipe(c_listBox_consumers.items.objects[index]);
    consumer.close();
  end;
end;

// --  --
procedure Tc_form_main.updateProvidersInfo();
var
  i: int;
  consumer: unavclInOutPipe;
begin
  // update "active/closed" display for providers
  for i := 0 to c_listBox_consumers.items.count - 1 do begin
    //
    consumer := unavclInOutPipe(c_listBox_consumers.items.objects[i]);
    c_listBox_consumers.items[i] := getConsumerInfo(consumer);
  end;
end;

// --  --
procedure Tc_form_main.Exit1Click(Sender: TObject);
begin
  close();
end;


end.

