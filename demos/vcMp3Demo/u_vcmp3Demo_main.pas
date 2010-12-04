
(*
	----------------------------------------------

	  u_vcMp3Demo_main.pas
	  Voice Communicator components version 2.5 Pro
	  MP3/Ogg Streaming Demo application - main form

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 21 Oct 2002

	  modified by:
		Lake, Oct-Nov 2002
		Lake, Jan-Dec 2003
		Lake, Jan-Mar 2004
		Lake, Oct 2005

	----------------------------------------------
*)

{$I unaDef.inc}
{$I unaBassDef.inc }

unit u_vcmp3Demo_main;

interface

uses
  Windows, unaTypes, Forms, MMSystem,
  unaClasses, unaEncoderAPI, unaVorbisAPI, unaMpglibAPI, unaSockets,
  Controls, StdCtrls, ComCtrls, Classes, ExtCtrls, ActnList, Dialogs,
  unavcIDE, Menus, unaVC_wave, unaVC_pipe;

type
  //
  // -- tMpgLibDecoder --
  tMpgLibDecoder = class(unaMpgLibDecoder)
  private
    f_outStream: unaMemoryStream;
  protected
    procedure startIn(); override;
    procedure notifyData(data: pointer; size: unsigned; var copyToStream: bool); override;
    procedure notifySamplingChange(rate, bits, channels: unsigned); override;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
  end;

  //
  tIPComponentEnum = (tipeEnc, tipeDec);	// IP component could be encoder or decoder
  tIPComponentType = (tiptSrv, tiptCln);	// IP component type could be server or client

  // --  --
  Tc_form_main = class(TForm)
    c_statusBar_main: TStatusBar;
    c_timer_update: TTimer;
    c_pageControl_main: TPageControl;
    c_tabSheet_encoder: TTabSheet;
    c_tabSheet_decoder: TTabSheet;
    c_comboBox_encoder: TComboBox;
    c_label_encoderChoose: TLabel;
    c_label_inputDevice: TLabel;
    c_comboBox_inputDevice: TComboBox;
    c_label_decoderSrc: TLabel;
    c_comboBox_decoderSource: TComboBox;
    c_label_decoderChoose: TLabel;
    c_comboBox_decoder: TComboBox;
    c_comboBox_outputDevice: TComboBox;
    c_label_outputDevice: TLabel;
    c_bevel_encodeSrcOptions: TBevel;
    c_label_encodeSrcOptions: TLabel;
    c_bevel_encodeOptions: TBevel;
    c_label_encodeOptions: TLabel;
    c_comboBox_encodedDest: TComboBox;
    c_label_encoderDest: TLabel;
    c_label_decodeSrcOptions: TLabel;
    c_bevel_decodeSrcOptions: TBevel;
    c_label_decodeOptions: TLabel;
    c_bevel_decodeOptions: TBevel;
    c_button_encodeStart: TButton;
    c_button_encodeStop: TButton;
    c_actionList_main: TActionList;
    a_encode_start: TAction;
    a_encode_stop: TAction;
    waveIn: TunavclWaveInDevice;
    c_comboBox_minBR: TComboBox;
    c_checkBox_enableVBR: TCheckBox;
    c_label_encoderMinBR: TLabel;
    c_label_encoderMaxBR: TLabel;
    c_comboBox_maxBR: TComboBox;
    c_comboBox_samplesRate: TComboBox;
    c_label_encoderSR: TLabel;
    c_comboBox_stereoMode: TComboBox;
    c_label_encoderSM: TLabel;
    c_label_encoderAvBR: TLabel;
    c_comboBox_avBR: TComboBox;
    c_button_decodeStart: TButton;
    c_button_decodeStop: TButton;
    a_decode_start: TAction;
    a_decode_stop: TAction;
    c_checkBox_disBRS: TCheckBox;
    c_comboBox_vbrQuality: TComboBox;
    c_label_encoderVBRQ: TLabel;
    c_label_encoderMp3File: TLabel;
    c_edit_destFile: TEdit;
    c_button_destBrowse: TButton;
    c_saveDialog_dest: TSaveDialog;
    c_button_playback: TButton;
    c_button_encCopyrights: TButton;
    c_checkBox_copyrighted: TCheckBox;
    c_checkBox_CRC: TCheckBox;
    c_checkBox_original: TCheckBox;
    c_checkBox_private: TCheckBox;
    c_checkBox_overwriteP: TCheckBox;
    waveOut: TunavclWaveOutDevice;
    a_help_show: TAction;
    c_label_encPortNumber: TLabel;
    c_edit_encPortNumber: TEdit;
    c_label_sourceFile: TLabel;
    c_edit_sourceFile: TEdit;
    c_button_sourceBrowse: TButton;
    c_openDialog_source: TOpenDialog;
    c_edit_decSrvPort: TEdit;
    c_label_decSrvPort: TLabel;
    c_label_warningOgg: TLabel;
    c_comboBox_encSocketType: TComboBox;
    c_label_encType: TLabel;
    c_comboBox_decSrvSocketType: TComboBox;
    c_label_decSrvSocketType: TLabel;
    c_edit_encSrvAddr: TEdit;
    c_label_encSrvAddr: TLabel;
    c_edit_decSrvAddr: TEdit;
    c_label_decSrvAddr: TLabel;
    c_button_decCopyrights: TButton;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    //
    procedure formCreate(sender: tObject);
    procedure formDestroy(sender: tObject);
    //
    procedure a_encode_startExecute(Sender: TObject);
    procedure a_encode_stopExecute(Sender: TObject);
    procedure a_decode_startExecute(Sender: TObject);
    procedure a_decode_stopExecute(Sender: TObject);
    //
    procedure c_timer_updateTimer(Sender: TObject);
    procedure c_checkBox_enableVBRClick(Sender: TObject);
    procedure c_comboBox_encoderChange(Sender: TObject);
    procedure c_comboBox_avBRChange(Sender: TObject);
    procedure c_comboBox_stereoModeChange(Sender: TObject);
    procedure c_button_destBrowseClick(Sender: TObject);
    procedure c_edit_destFileChange(Sender: TObject);
    procedure c_button_playbackClick(Sender: TObject);
    procedure c_button_encCopyrightsClick(Sender: TObject);
    procedure c_checkBox_overwritePClick(Sender: TObject);
    procedure c_comboBox_inputDeviceChange(Sender: TObject);
    procedure c_comboBox_outputDeviceChange(Sender: TObject);
    procedure c_comboBox_encodedDestChange(Sender: TObject);
    procedure c_comboBox_decoderSourceChange(Sender: TObject);
    procedure c_button_sourceBrowseClick(Sender: TObject);
    procedure c_edit_sourceFileChange(Sender: TObject);
    procedure c_comboBox_decoderChange(Sender: TObject);
    //
    procedure waveInDataAvailable(sender: unavclInOutPipe; data: Pointer; len: Cardinal);
    procedure waveOutFeedDone(sender: unavclInOutPipe; data: Pointer; len: Cardinal);
    procedure Exit1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    f_config: unaIniFile;
    //
    f_bladeOK: bool;
    f_lameOK: bool;
    f_vorbisEncodeOK: bool;
    f_vorbisDecodeOK: bool;
    f_bassOK: bool;
    f_mpgOK: bool;
    //
    f_blade: unaBladeMp3Enc;
    f_lame: unaLameMp3Enc;
    f_vorbisEncode: unaVorbisEnc;
    f_vorbisDecode: unaVorbisDecoder;
    f_vorbisDecodeVersion: int;
    //
    f_bassDecoder: unaBass;
    f_bassDecodedSize: int64;
    f_bassFile: unaBassStream;
    f_feedBuf: pointer;
    f_feedBufSize: unsigned;
    //
    // Ogg
    f_vorbisHP: int;
    f_oggOutFile: unaOggFile;
    f_oggInFile: unaOggFile;
    f_op: tOgg_packet;
    //
    // MpgLib
    f_mpgDecoder: tMpgLibDecoder;
    f_mpgDecodedSize: unsigned;
    f_mpgFile: tHandle;
    f_mpgPCM: tWAVEFORMATEX;
    f_mpgNeedFormatUpdate: bool;
    //
    // sockets
    f_socks: unaSocks;
    //
    f_sockClients: array[tIPComponentEnum] of unaList;
    f_sockId: array[tIPComponentEnum] of unsigned;
    f_sockConnId: array[tIPComponentEnum] of unsigned;
    f_ipComponentType: array[tIPComponentEnum] of tIPComponentType;
    f_ipComponentReady: array[tIPComponentEnum] of bool;
    //
    f_encoder: unaAbstractEncoder;
    f_decoderIndex: int;
    //
    f_encoderDestIndex: int;
    f_decoderSourceIndex: int;
    //
    f_closingOut: bool;
    //
    procedure flushOgg();
    //
    procedure enumAudioDevices();
    procedure enumEngineDevices();
    procedure myOnEncoderDataAvail(sender: tObject; data: pointer; size: unsigned; var copyToStream: bool);
    procedure myOnDecoderDataAvail(sender: tObject; data: pointer; size: unsigned; var copyToStream: bool);
    procedure myOnSocksEvent(sender: tObject; event: unaSocketEvent; id, connId: unsigned; data: pointer; size: unsigned);
  public
    { Public declarations }
  end;

var
  c_form_main: Tc_form_main;


implementation


{$R *.dfm}

uses
  shellAPI, sysUtils, unaVCLUtils,
  unaUtils, unaMsAcmClasses, unaMsAcmAPI, unaBladeEncAPI, unaBassAPI, WinSock,
  u_vcmp3Demo_about;


{ tMpgLibDecoder }

// --  --
procedure tMpgLibDecoder.afterConstruction();
begin
  f_outStream := unaMemoryStream.create();
  //
  inherited;
end;

// --  --
procedure tMpgLibDecoder.beforeDestruction();
begin
  inherited;
  //
  freeAndNil(f_outStream);
end;

// --  --
procedure tMpgLibDecoder.notifyData(data: pointer; size: unsigned; var copyToStream: bool);
begin
  inherited;
  //
  if (copyToStream) then
    f_outStream.write(data, size);
  //
  inc(c_form_main.f_mpgDecodedSize, size);
end;

// --  --
procedure tMpgLibDecoder.notifySamplingChange(rate, bits, channels: unsigned);
begin
  inherited;
  //
  fillPCMFormat(c_form_main.f_mpgPCM, rate, bits, channels);
  //
  c_form_main.f_mpgNeedFormatUpdate := true;
end;

// --  --
procedure tMpgLibDecoder.startIn();
begin
  f_outStream.clear();
  //
  inherited;
end;

{ Tc_form_main }

// --  --
procedure Tc_form_main.c_timer_updateTimer(Sender: TObject);
var
  format: PWAVEFORMATEXTENSIBLE;
begin
  if (not (csDestroying in ComponentState)) then begin
    //
    c_statusBar_main.Panels[0].Text := int2str(ams() shr 10, 10, 3) + ' KB';
    //
    if (nil <> f_encoder) then
      c_statusBar_main.panels[1].text := 'Encoder Output: ' + int2str(f_encoder.encodedDataSize shr 10, 10, 3) + ' KB'
    else begin
      //
      case (f_decoderIndex) of

	0 : begin //  Ogg/Vorbis
	  //
	  if (nil <> f_vorbisDecode) then
	    c_statusBar_main.panels[1].text := 'Ogg/Vorbis Decoder Out: ' + int2str(f_vorbisDecode.encodedDataSize shr 10, 10, 3) + ' KB';
	end;

	1 : begin // BASS
	  //
	  c_statusBar_main.panels[1].text := 'BASS Decoder Out: ' + int2str(f_bassDecodedSize shr 10, 10, 3) + ' KB';
	end;

	2 : begin // MpgLib
	  //
	  c_statusBar_main.panels[1].text := 'MpgLib Decoder Out: ' + int2str(f_mpgDecodedSize shr 10, 10, 3) + ' KB';
	  //
	  if (f_mpgNeedFormatUpdate) then begin
	    //
	    f_mpgNeedFormatUpdate := false;
	    //
	    waveOut.close();
	    //
	    format := nil;
	    try
	      FillFormatExt(format, @f_mpgPCM);
	      waveOut.pcmFormatExt := format;
	    finally
	      mrealloc(format);
	    end;
	    //
	    waveOut.open();
	    waveOut.flush();
	  end;
	end;

      end;	// case
    end;
  end;
end;

// --  --
procedure Tc_form_main.enumAudioDevices();
var
  i: int;
  inCaps: WAVEINCAPSW;
  outCaps: WAVEOUTCAPSW;
begin
  // enum waveIn/Out devices

  // PCM INPUT
  with (c_comboBox_inputDevice) do begin
    clear();
    //
    for i := -1 to unaWaveInDevice.getDeviceCount() - 1 do begin
      unaWaveInDevice.getCaps(unsigned(i), inCaps);
      items.add(inCaps.szPname);
    end;
    itemIndex := 0;
  end;

  // ENCODED INPUT
  with (c_comboBox_decoderSource) do begin
    //
    clear();
    items.add('MP3/Ogg file');
    items.add('TCP/IP Real-time Streaming Client');
    items.add('TCP/IP Real-time Streaming Server');
    itemIndex := 0;
  end;

  // RAW OUTPUT
  with (c_comboBox_outputDevice) do begin
    //
    clear();
    //
    for i := -1 to unaWaveOutDevice.getDeviceCount() - 1 do begin
      //
      unaWaveOutDevice.getCaps(unsigned(i), outCaps);
      items.add(outCaps.szPname);
    end;
    //
    itemIndex := 0;
  end;

  // ENCODED OUTPUT
  with (c_comboBox_encodedDest) do begin
    //
    clear();
    items.add('MP3/Ogg file');
    items.add('TCP/IP Real-time Streaming Client');
    items.add('TCP/IP Real-time Streaming Server');
    //
    itemIndex := 0;
  end;
end;

// --  --
procedure Tc_form_main.enumEngineDevices();
begin
  c_comboBox_encoder.clear();
  c_comboBox_decoder.clear();

  // BLADE MP3 ENCODER
  if (f_bladeOK) then
    c_comboBox_encoder.items.add('Blade MP3 Encoder, version ' + int2str(f_blade.version.byMajorVersion) + '.' + int2str(f_blade.version.byMinorVersion))
  else
    c_comboBox_encoder.items.add('Blade MP3 Encoder - required module was not found.');

  // LAME MP3 ENCODER
  if (f_lameOK) then
    c_comboBox_encoder.items.add('Lame MP3 Encoder, version ' + int2str(f_lame.version.byMajorVersion) + '.' + int2str(f_lame.version.byMinorVersion))
  else
    c_comboBox_encoder.items.add('Lame MP3 Encoder - required module was not found.');

  // VORBIS ENCODER
  if (f_vorbisEncodeOK) then
    c_comboBox_encoder.items.add('Ogg/Vorbis Encoder, version ' + int2str(f_vorbisEncode.version))
  else
    c_comboBox_encoder.items.add('Ogg/Vorbis Encoder - required module(s) was not found.');
  //

  // VORBIS DECODER
  if (f_vorbisDecodeOK) then
    c_comboBox_decoder.items.add('Ogg/Vorbis Decoder, version ' + int2str(f_vorbisDecodeVersion))
  else
    c_comboBox_decoder.items.add('Ogg/Vorbis Decoder - required module(s) was not found.');
  //

  // BASS MP3/Ogg DECODER
  if (f_bassOK) then
    c_comboBox_decoder.items.add('BASS MP3/Ogg decoder, version ' + string(f_bassDecoder.get_versionStr()))
  else
    c_comboBox_decoder.items.add('BASS MP3/Ogg decoder - required module(s) was not found.');
  //

  // MpgLib DECODER
  if (f_mpgOK) then
    c_comboBox_decoder.items.add('MpgLib MP3 decoder, version ' + int2str(0))	// no version info
  else
    c_comboBox_decoder.items.add('MpgLib MP3 decoder - required module(s) was not found.');
  //  

  //
  c_comboBox_encoder.itemIndex := f_config.get('encoder.index', unsigned(0));
  c_comboBox_decoder.itemIndex := f_config.get('decoder.index', unsigned(0));
end;

// --  --
procedure Tc_form_main.formCreate(sender: tObject);
var
  e: tIPComponentEnum;
begin
  f_config := unaIniFile.create();
  loadControlPosition(self, f_config);
  //
  f_blade := unaBladeMp3Enc.create('');
  f_lame := unaLameMp3Enc.create('');
  f_vorbisEncode := unaVorbisEnc.create();
  f_vorbisDecode := unaVorbisDecoder.create();
  //
  f_bassDecoder := unaBass.create('', {$IFDEF BASS_AFTER_18 }0{$ELSE }-1{$ENDIF }, 44100, 32, handle);
  //
  f_blade.onDataAvailable := myOnEncoderDataAvail;
  f_lame.onDataAvailable := myOnEncoderDataAvail;
  f_vorbisEncode.onDataAvailable := myOnEncoderDataAvail;
  //
  f_mpgDecoder := tMpgLibDecoder.create('');
  f_mpgDecoder.onDataAvail := myOnDecoderDataAvail;
  //
  f_bladeOK := (BE_ERR_SUCCESSFUL = f_blade.errorCode);
  f_lameOK := (BE_ERR_SUCCESSFUL = f_lame.errorCode);
  f_vorbisEncodeOK := (BE_ERR_SUCCESSFUL = f_vorbisEncode.errorCode);
  f_vorbisDecodeOK := (BE_ERR_SUCCESSFUL = f_vorbisDecode.errorCode);
  f_vorbisDecodeVersion := f_vorbisDecode.version;
  freeAndNil(f_vorbisDecode);	// no longer needed here
  //
  f_bassOK := (BASS_OK = f_bassDecoder.get_errorCode());
  f_mpgOK := (mpglib_error_OK = f_mpgDecoder.errorCode);
  //
  f_feedBuf := nil;
  f_feedBufSize := 0;
  //
  f_socks := unaSocks.create();
  f_socks.onEvent := myOnSocksEvent;
  //
  for e := low(e) to high(e) do
    f_sockClients[e] := unaList.create();
  //
  enumAudioDevices();
  enumEngineDevices();
  //
  c_comboBox_encoderChange(self);
  c_comboBox_maxBR.items.Assign(c_comboBox_minBR.items);
  c_comboBox_minBR.itemIndex := f_config.get('encoder.bitrate.min.index', unsigned(8));
  c_comboBox_maxBR.itemIndex := f_config.get('encoder.bitrate.max.index', unsigned(8));
  c_comboBox_avBR.itemIndex := f_config.get('encoder.bitrate.av.index', unsigned(8));
  c_checkBox_enableVBRClick(self);
  //
  c_checkBox_disBRS.checked := f_config.get('encoder.lame.disableBrs', false);
  //
  c_comboBox_samplesRate.itemIndex := 5;
  c_comboBox_stereoMode.itemIndex := 1;
  c_comboBox_vbrQuality.itemIndex := 0;
  //
  c_edit_destFile.text := f_config.get('output.file.name', '');
  c_checkBox_overwriteP.checked := f_config.get('output.file.overwritePrompt', true);
  c_edit_sourceFile.text := f_config.get('input.file.name', '');
  //
  c_edit_encSrvAddr.text                := f_config.get('enc.ip.addr', '192.168.1.1');
  c_edit_encPortNumber.text             := f_config.get('enc.ip.port', '17840');
  c_comboBox_encSocketType.itemIndex    := f_config.get('enc.ip.socketType.index', int(0));
  c_edit_decSrvAddr.text                := f_config.get('dec.ip.addr', '192.168.1.1');
  c_edit_decSrvPort.text                := f_config.get('dec.ip.port', '17840');
  c_comboBox_decSrvSocketType.itemIndex := f_config.get('dec.ip.socketType.index', int(0));
  //
  c_comboBox_inputDevice.itemIndex := f_config.get('input.device.index', int(0));
  c_comboBox_inputDeviceChange(self);
  c_comboBox_outputDevice.itemIndex := f_config.get('output.device.index', int(0));
  c_comboBox_outputDeviceChange(self);
  //
  c_comboBox_encodedDest.itemIndex := f_config.get('output.encoded.index', int(0));
  c_comboBox_encodedDestChange(self);
  c_comboBox_decoderSource.itemIndex := f_config.get('input.encoded.index', int(0));
  c_comboBox_decoderSourceChange(self);
end;

// --  --
procedure Tc_form_main.formDestroy(sender: tObject);
var
  e: tIPComponentEnum;
begin
  a_encode_stop.execute();
  a_decode_stop.execute();
  //
  freeAndNil(f_blade);
  freeAndNil(f_lame);
  freeAndNil(f_vorbisEncode);
  freeAndNil(f_vorbisDecode);
  freeAndNil(f_bassDecoder);
  freeAndNil(f_mpgDecoder);
  //
  f_feedBufSize := 0;
  mrealloc(f_feedBuf);
  //
  freeAndNil(f_socks);
  for e := low(e) to high(e) do
    freeAndNil(f_sockClients[e]);
  //
  saveControlPosition(self, f_config);
  with (f_config) do begin
    setValue('encoder.index', c_comboBox_encoder.itemIndex);
    setValue('decoder.index', c_comboBox_decoder.itemIndex);
    //
    setValue('encoder.lame.disableBrs', c_checkBox_disBRS.Checked);
    setValue('encoder.bitrate.min.index', c_comboBox_minBR.ItemIndex);
    setValue('encoder.bitrate.max.index', c_comboBox_maxBR.ItemIndex);
    setValue('encoder.bitrate.av.index', c_comboBox_avBR.ItemIndex);
    //
    setValue('enc.ip.addr', c_edit_encSrvAddr.text);
    setValue('enc.ip.port', c_edit_encPortNumber.text);
    setValue('enc.ip.socketType.index', c_comboBox_encSocketType.itemIndex);
    setValue('dec.ip.addr', c_edit_decSrvAddr.text);
    setValue('dec.ip.port', c_edit_decSrvPort.text);
    setValue('dec.ip.socketType.index', c_comboBox_decSrvSocketType.itemIndex);
    //
    setValue('output.file.name', c_edit_destFile.text);
    setValue('input.file.name', c_edit_sourceFile.text);
    setValue('output.file.overwritePrompt', c_checkBox_overwriteP.Checked);
    setValue('output.encoded.index', c_comboBox_encodedDest.itemIndex);
    setValue('input.encoded.index', c_comboBox_decoderSource.itemIndex);
    setValue('output.device.index', c_comboBox_outputDevice.itemIndex);
    setValue('input.device.index', c_comboBox_inputDevice.itemIndex);
  end;
  //
  freeAndNil(f_config);
end;

// --  --
procedure Tc_form_main.myOnSocksEvent(sender: tObject; event: unaSocketEvent; id, connId: unsigned; data: pointer; size: unsigned);
var
  e: tIPComponentEnum;
  asynch: bool;
begin
  //
  if (id = f_sockId[tipeEnc]) then
    e := tipeEnc
  else
    if (id = f_sockId[tipeDec]) then
      e := tipeDec
    else
      exit;	// unknown sockId
  //
  case (event) of

    // -- server --

    unaseServerListen: begin
      //
      // server is listening
      if (tiptSrv = f_ipComponentType[e]) then
	f_ipComponentReady[e] := true;
    end;

    unaseServerStop: begin
      //
      // server is not listening
      if (tiptSrv = f_ipComponentType[e]) then
	f_ipComponentReady[e] := false;
    end;

    unaseServerConnect: begin
      //
      // new client connection
      if (tipeEnc = e) then
	f_sockClients[e].add(connId)
      else
	if (tipeDec = e) then begin
	  //
	  // only one client is allowed per decoder
	  if (1 > f_sockClients[e].count) then
	    f_sockClients[e].add(connId);
	end;
    end;

    unaseServerData: begin
      //
      if (tipeEnc = e) then
	// some data from client, ignore, since encoder always takes data from waveIn only
      else
	if (tipeDec = e) then begin
	  //
	  // is that a client we have added at unaseServerConnect?
	  if ((0 < f_sockClients[e].count) and (connId = unsigned(f_sockClients[e][0]))) then begin
	    //
	    // feed decoder with new data from client
	    case (f_decoderIndex) of

	      0: begin	// vorbis
		// not supported
	      end;

	      1: begin	// BASS
		// not supported
	      end;

	      2: begin 	// mpgLib
		f_mpgDecoder.write(data, size);
	      end;

	    end;	// case (f_decoderIndex)
	  end;
	end;
    end;

    unaseServerDisconnect: begin
      //
      // client connection dropped
      f_sockClients[e].removeItem(connId);
    end;


    // --  client --

    unaseClientConnect: begin
      //
      // client was connected
      f_sockConnId[e] := connId;
      if (tiptCln = f_ipComponentType[e]) then begin
	//
	if (not f_ipComponentReady[e]) then begin
	  //
	  f_ipComponentReady[e] := true;
	  //
	  // we also need to "ping" the server once so it will know we are connected
	  f_socks.sendData(id, @id, sizeOf(id), connId, asynch);
	end;
      end;
    end;

    unaseClientData: begin
      //
      if (tipeEnc = e) then
	// some data from client, ignore, since encoder always takes data from waveIn only
      else
	if (tipeDec = e) then begin
	  //
	  // feed decoder with new data from server
	  case (f_decoderIndex) of

	    0: begin	// vorbis
	      // not supported
	    end;

	    1: begin	// BASS
	      // not supported
	    end;

	    2: begin 	// mpgLib
	      f_mpgDecoder.write(data, size);
	    end;

	  end;	// case (f_decoderIndex)
	end;
    end;

    unaseClientDisconnect: begin
      //
      // client was disconnected
      if (tiptCln = f_ipComponentType[e]) then
	f_ipComponentReady[e] := false;
    end;

    // thread
    unaseThreadStartupError: begin
      //
      f_sockId[e] := 0;
      f_sockConnId[e] := 0;
      f_ipComponentReady[e] := false;
      f_sockClients[e].clear();
    end;

  end;
end;

// --  --
function index2proto(index: int): int;
begin
  if (0 = index) then
    result := IPPROTO_UDP
  else
    result := IPPROTO_TCP;
  //
end;

// --  --
procedure Tc_form_main.a_encode_startExecute(Sender: TObject);
var
  bladeConfig: BE_CONFIG;
  lameConfig: BE_CONFIG_FORMATLAME;
  vorbisConfig: tVorbisSetup;
  config: pointer;
  //
  ok: bool;
  //
  minBR,
  maxBR,
  avBR: unsigned;
  samplesRate: unsigned;
  stereoMode: int;
begin
  c_statusBar_main.panels[1].text := '';
  f_encoderDestIndex := c_comboBox_encodedDest.itemIndex;
  //
  f_ipComponentReady[tipeEnc] := false;
  case (c_comboBox_encodedDest.itemIndex) of

    1: f_ipComponentType[tipeEnc] := tiptCln;
    2: f_ipComponentType[tipeEnc] := tiptSrv;

  end;
  //
  case (c_comboBox_encoder.itemIndex) of

    0: f_encoder := f_blade;
    1: f_encoder := f_lame;
    2: f_encoder := f_vorbisEncode;
    else
      f_encoder := nil;

  end;

  //
  if (nil <> f_encoder) then begin
    //
    config := nil;
    //
    if (0 = c_comboBox_avBR.ItemIndex) then
      avBR := 0
    else
      avBR  := str2intUnsigned(c_comboBox_avBR.text, 128);
    //
    if (c_checkBox_enableVBR.Checked) then begin
      minBR := str2intUnsigned(c_comboBox_minBR.text, 128);
      maxBR := str2intUnsigned(c_comboBox_maxBR.text, 128);
    end
    else begin
      minBR := avBR;
      maxBR := avBR;
    end;
    //
    samplesRate := str2intUnsigned(c_comboBox_samplesRate.text, 44100);
    //
    waveIn.pcm_NumChannels := 2;
    case (c_comboBox_stereoMode.itemIndex) of

      0: begin
	//
	stereoMode := BE_MP3_MODE_MONO;
	waveIn.pcm_NumChannels := 1;
      end;

      1: stereoMode := BE_MP3_MODE_STEREO;

      2: stereoMode := BE_MP3_MODE_JSTEREO;

      3: stereoMode := BE_MP3_MODE_DUALCHANNEL;

      else
	stereoMode := BE_MP3_MODE_STEREO;
    end;
    //
    waveIn.pcm_SamplesPerSec := samplesRate;
    waveIn.pcm_BitsPerSample := 16;
    //
    if (f_blade = f_encoder) then begin
      //
      fillChar(bladeConfig, sizeOf(bladeConfig), #0);
      bladeConfig.dwConfig := BE_CONFIG_MP3;
      with bladeConfig.r_mp3 do begin
	//
	dwSampleRate := samplesRate;
	byMode := stereoMode;
	wBitrate := avBR;
	//
	bPrivate := c_checkBox_private.checked;
	bCRC :=  c_checkBox_crc.checked;
	bCopyright :=  c_checkBox_copyrighted.checked;
	bOriginal :=  c_checkBox_original.checked;
      end;
      config := @bladeConfig;
    end;
    //
    if ((nil = config) and (f_lame = f_encoder)) then begin
      //
      fillChar(lameConfig, sizeOf(lameConfig), #0);
      lameConfig.dwConfig := BE_CONFIG_LAME;
      with lameConfig.r_lhv1 do begin
	//
	dwStructVersion := CURRENT_STRUCT_VERSION;
	dwStructSize := sizeOf(lameConfig);
	dwSampleRate := samplesRate;
	//dwReSampleRate := 0;
	nMode := stereoMode;
	dwBitrate := minBR;
	dwMaxBitrate := maxBR;
	nPreset := LQP_NOPRESET;
	dwMpegVersion := MPEG2;
	//dwPsyModel := 0;
	//dwEmphasis := 0;
	bPrivate := c_checkBox_private.checked;
	bCRC :=  c_checkBox_crc.checked;
	bCopyright :=  c_checkBox_copyrighted.checked;
	bOriginal :=  c_checkBox_original.checked;
	//
	bWriteVBRHeader := false;
	bEnableVBR := c_checkBox_enableVBR.Checked;
	nVBRQuality := c_comboBox_vbrQuality.ItemIndex;
	//
	if (c_checkBox_enableVBR.Checked) then begin
	  //
	  dwVbrAbr_bps := avBR;
	  if (0 < avBR) then
	    nVbrMethod := VBR_METHOD_ABR
	  else
	    nVbrMethod := VBR_METHOD_NEW
	end
	else
	  nVbrMethod := VBR_METHOD_NONE;
	//
	bNoRes := c_checkBox_disBRS.Checked;
	bStrictIso := false;
	//btReserved := 0;
      end;
      config := @lameConfig;
    end;

    // --  --
    if ((nil = config) and (f_vorbisEncode = f_encoder)) then begin
      //
      fillChar(vorbisConfig, sizeOf(vorbisConfig), #0);
      //
      vorbisConfig.r_numOfChannels := waveIn.pcm_NumChannels;
      vorbisConfig.r_samplingRate := samplesRate;
      //
      if (c_checkBox_enableVBR.Checked) then begin
	//
	vorbisConfig.r_encodeMethod := vemVBR;
	vorbisConfig.r_quality := (10 - c_comboBox_vbrQuality.ItemIndex - 1.999) / 10;
      end
      else begin
	//
	vorbisConfig.r_encodeMethod := vemRateManage;
	vorbisConfig.r_manage_minBitrate := -1;
	vorbisConfig.r_manage_normalBitrate := avBR * 1000;
	vorbisConfig.r_manage_maxBitrate := -1;
	vorbisConfig.r_manage_mode := OV_ECTL_RATEMANAGE_AVG;
      end;
      //
      config := @vorbisConfig;
    end;

    //
    if (nil <> config) then begin
      //
      f_vorbisHP := 3;	// need to set this before opening the encoder
      if (BE_ERR_SUCCESSFUL = f_encoder.setConfig(config)) then begin
	//
	if (BE_ERR_SUCCESSFUL = f_encoder.open()) then begin
	  //
	  case (f_encoderDestIndex) of

	    0: begin
	      //
	      c_edit_destFile.enabled := false;
	      deleteFile(c_edit_destFile.text);
	      //
	      c_button_destBrowse.enabled := false;
	      //
	      ok := true;
	    end;

	    1, 2: begin
	      //
	      case (f_ipComponentType[tipeEnc]) of

		tiptSrv: begin
		  //
		  f_sockClients[tipeEnc].clear();
		  f_sockId[tipeEnc] := f_socks.createServer(c_edit_encPortNumber.text, index2proto(c_comboBox_encSocketType.itemIndex), true, 5, 0);
		  ok := (0 < f_sockId[tipeEnc]);
		end;

		tiptCln: begin
		  //
		  f_sockId[tipeEnc] := f_socks.createConnection(c_edit_encSrvAddr.text, c_edit_encPortNumber.text, index2proto(c_comboBox_encSocketType.itemIndex));
		  ok := (0 < f_sockId[tipeEnc]) and (0 < f_sockConnId[tipeEnc]);
		end;

		else
		  ok := false;

	      end;
	      //
	      c_edit_encSrvAddr.enabled := false;
	      c_edit_encPortNumber.enabled := false;
	      c_comboBox_encSocketType.enabled := false;
	    end;

	    else
	      ok := false;

	  end;
	  //
	  if (ok) then begin
	    //
	    a_encode_stop.enabled := true;
	    a_encode_start.enabled := false;
	    //
	    waveIn.open();
	    waveIn.waveInDevice.assignStream(false, nil);
	  end
	  else begin
	    //
	    c_button_encodeStop.click();
	    c_statusBar_main.panels[1].text := 'TCP/IP operation failed';
	    f_encoder := nil;
	  end;
	  //
	end
	else begin
	  //
	  c_statusBar_main.panels[1].text := 'Open fails, error code: ' + int2str(f_encoder.errorCode, 16);
	  f_encoder := nil;
	end
      end
      else begin
	//
	c_statusBar_main.panels[1].text := 'Config fails, error code: ' + int2str(f_encoder.errorCode, 16);
	f_encoder := nil;
      end;
    end;
  end
  else
    c_statusBar_main.panels[1].text := 'Please select an encoder.';
  //
end;

// --  --
procedure Tc_form_main.a_encode_stopExecute(Sender: TObject);
begin
  if (nil <> f_encoder) then begin
    //
    waveIn.close();
    f_encoder.close();
    //
    a_encode_stop.enabled := false;
    a_encode_start.enabled := true;
    //
    case (f_encoderDestIndex) of

      0: begin
	//
	c_edit_destFile.enabled := true;
	c_button_destBrowse.enabled := c_edit_destFile.enabled;
	//
	if (nil <> f_oggOutFile) then
	  flushOgg();
	//
	freeAndNil(f_oggOutFile);
      end;

      1, 2: begin
	//
	f_ipComponentReady[tipeEnc] := false;
	f_sockClients[tipeEnc].clear();
	//
	if (0 < f_sockId[tipeEnc]) then
	  f_socks.closeThread(f_sockId[tipeEnc]);
	//
	f_sockId[tipeEnc] := 0;
	f_sockConnId[tipeEnc] := 0;
	//
	c_edit_encSrvAddr.enabled := true;
	c_edit_encPortNumber.enabled := true;
	c_comboBox_encSocketType.enabled := true;
      end;

    end;
    //
    f_encoder := nil;
  end;
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  shellExecute(handle, 'open', 'http://lakeofsoft.com/vc/a_mp3demo.html', nil, nil, SW_SHOWNORMAL);
end;

procedure Tc_form_main.a_decode_startExecute(Sender: TObject);
var
  ok: bool;
  freq: int;
  volume: int;
  pan: int;
  flags: DWORD;
begin
  a_decode_start.enabled := false;
  //
  c_statusBar_main.panels[1].text := '';
  f_decoderIndex := c_comboBox_decoder.itemIndex;	// 0 - Ogg/Vorbis
							// 1 - BASS
							// 2 - MpgLib
  //
  f_ipComponentReady[tipeDec] := false;
  case (c_comboBox_decoderSource.itemIndex) of

    1: f_ipComponentType[tipeDec] := tiptCln;
    2: f_ipComponentType[tipeDec] := tiptSrv;

  end;
  //
  f_decoderSourceIndex := c_comboBox_decoderSource.itemIndex;
  case (f_decoderSourceIndex) of

    0: begin	// file

      ok := true;
      case (f_decoderIndex) of

	0: begin	// Ogg/Vorbis library
	  //
	  f_oggInFile := unaOggFile.create(c_edit_sourceFile.text, -1, GENERIC_READ);
	  if (0 <> f_oggInFile.errorCode) then begin
	    //
	    c_statusBar_main.panels[1].text := 'OGG File Error code: ' + int2str(f_oggInFile.errorCode);
	    ok := false;
	  end
	  else begin
	    // create decoder as well
	    f_vorbisDecode := unaVorbisDecoder.create();
	    f_vorbisDecode.onDataAvailable := myOnDecoderDataAvail;
	    //
	    // init ogg reader and vorbis decoder
	    f_oggInFile.sync_init();
	    //
	    if (0 = f_oggInFile.vorbis_decode_int(f_vorbisDecode)) then begin
	      // init and open waveOut device
	      waveOut.pcm_samplesPerSec := f_vorbisDecode.vi.rate;
	      waveOut.pcm_bitsPerSample := 16;	// vorbis always has 16 bits
	      waveOut.pcm_numChannels := f_vorbisDecode.vi.channels;
	      //
	      f_vorbisDecode.decode_initBuffer(8912);
	    end
	    else begin
	      //
	      c_statusBar_main.panels[1].text := 'OGG Decoder Error code: ' + int2str(f_oggInFile.errorCode);
	      ok := false;
	    end;
	  end;
	  //
	  if (not ok) then
	    a_decode_stopExecute(sender);
	end;

	1: begin	// BASS
	  //
	  f_bassFile := unaBassStream.create(f_bassDecoder);
	  if (f_bassFile.createStream(c_edit_sourceFile.text, 0, 0, BASS_STREAM_DECODE)) then begin
	    //
	    f_bassFile.asChannel.get_attributes(freq, volume, pan);
	    flags := f_bassFile.asChannel.get_flags();
	    //
	    waveOut.pcm_samplesPerSec := freq;
	    //
	    if (0 <> (BASS_SAMPLE_8BITS and flags)) then
	      waveOut.pcm_bitsPerSample := 8
	    else
	      waveOut.pcm_bitsPerSample := 16;
	    //
	    if (0 <> (BASS_SAMPLE_MONO and flags)) then
	      waveOut.pcm_numChannels := 1
	    else
	      waveOut.pcm_numChannels := 2;
	    //
	    f_bassDecodedSize := 0;
	  end
	  else begin
	    //
	    c_statusBar_main.panels[1].text := 'File decoding error: ' + int2str(f_bassDecoder.get_errorCode());
	    freeAndNil(f_bassFile);
	    ok := false;
	    //
	  end;
	end;

	2: begin	// MpgLib
	  //
	  f_mpgFile := fileCreate(c_edit_sourceFile.text, false, true);
	  ok := (INVALID_HANDLE_VALUE <> f_mpgFile) and (0 <> f_mpgFile);
	  //
	  if (ok) then
	    f_mpgDecoder.open()
	  else
	    f_mpgFile := 0;
	  //
	  f_mpgDecodedSize := 0;
	end;

	else begin
	  //
	  c_statusBar_main.panels[1].text := 'Unknown decode library';
	  a_decode_start.enabled := true;
	end;

      end;

    end;

    1, 2: begin	// TCP/IP stream
      //
      case (f_ipComponentType[tipeDec]) of

	tiptSrv: begin
	  //
	  f_sockClients[tipeDec].clear();
	  f_sockId[tipeDec] := f_socks.createServer(c_edit_decSrvPort.text, index2proto(c_comboBox_decSrvSocketType.itemIndex), true, 5, 0);
	  ok := (0 < f_sockId[tipeDec]);
	end;

	tiptCln: begin
	  //
	  f_sockId[tipeDec] := f_socks.createConnection(c_edit_decSrvAddr.text, c_edit_decSrvPort.text, index2proto(c_comboBox_decSrvSocketType.itemIndex));
	  ok := (0 < f_sockId[tipeDec]) and (0 < f_sockConnId[tipeDec]);
	end;

	else
	  ok := false;

      end;
      //
      // aslo open the decoder (only mpgDecoder is supported)
      if (ok) then
	f_mpgDecoder.open()
      else
	f_mpgFile := 0;
      //
      f_mpgDecodedSize := 0;
      //
      c_edit_decSrvAddr.enabled := false;
      c_edit_decSrvPort .enabled := false;
      c_comboBox_decSrvSocketType.enabled := false;
    end;

    else
      ok := false;

  end;

  //
  if (ok) then begin
    //
    f_closingOut := false;
    waveOut.open();
    //
    if (0 = f_decoderSourceIndex) then
      // make sure waveOut will fire waveOutAfterChunkFeed() event, so we will start feeding cycle
      waveOut.flush();
    //
  end;

  //
  a_decode_stop.enabled := not a_decode_start.enabled;
  c_comboBox_decoderSource.enabled := a_decode_start.enabled;
end;

// --  --
procedure Tc_form_main.a_decode_stopExecute(Sender: TObject);
begin
  f_closingOut := true;
  waveOut.close();
  //
  case (f_decoderSourceIndex) of

    0: begin
      //
      case (f_decoderIndex) of

	0: begin	// Ogg/Vorbis
	  //
	  freeAndNil(f_oggInFile);
	  freeAndNil(f_vorbisDecode);
	end;

	1: begin	// BASS
	  //
	  freeAndNil(f_bassFile);
	end;

	2: begin
	  //
	  f_mpgDecoder.stop();
	  if (0 <> f_mpgFile) then
	    CloseHandle(f_mpgFile);
	end;

      end;
    end;

    1, 2: begin
      //
      f_ipComponentReady[tipeDec] := false;
      //
      f_sockClients[tipeDec].clear();
      //
      if (0 < f_sockId[tipeDec]) then
	f_socks.closeThread(f_sockId[tipeDec]);
      //
      f_sockId[tipeDec] := 0;
      f_sockConnId[tipeDec] := 0;
      //
      f_mpgDecoder.stop();
      //
      c_edit_decSrvAddr.enabled := true;
      c_edit_decSrvPort.enabled := true;
      c_comboBox_decSrvSocketType.enabled := true;
    end;

  end;
  //
  a_decode_start.enabled := true;
  a_decode_stop.enabled := not a_decode_start.enabled;
  c_comboBox_decoderSource.enabled := a_decode_start.enabled;
end;

// --  --
procedure Tc_form_main.flushOgg();
begin
  while (f_vorbisEncode.popPacket(f_op)) do begin
    //* weld the packet into the bitstream */
    f_oggOutFile.packetIn(f_op);
    f_oggOutFile.pageOut();
  end;
  //
  f_oggOutFile.flush();
end;

// --  --
procedure Tc_form_main.waveInDataAvailable(sender: unavclInOutPipe; data: Pointer; len: Cardinal);
begin
  if (nil <> f_encoder) then begin
    // use lazy thread to return to waveIn ASAP
    f_encoder.lazyWrite(data, len);

    // or we can use synchronous encode
    //f_encoder.encodeChunk(data, len);
  end;
end;

// --  --
procedure Tc_form_main.myOnEncoderDataAvail(sender: tObject; data: pointer; size: unsigned; var copyToStream: bool);
var
  i: int;
  asynch: bool;
begin
  if (nil <> f_encoder) then begin
    //
    if (f_vorbisEncode = f_encoder) then begin
      //
      if (nil = f_oggOutFile) then
	f_oggOutFile := unaOggFile.create(c_edit_destFile.text, -1, GENERIC_WRITE);
      //
      if (0 <> f_oggOutFile.errorCode) then begin
	c_statusBar_main.panels[1].text := 'OGG library error code: ' + int2str(f_oggOutFile.errorCode);
      end
      else begin
	// care about vorbis header
	while (0 < f_vorbisHP) do begin
	  //
	  if (f_vorbisEncode.popPacket(f_op)) then begin
	    f_oggOutFile.packetIn(f_op);
	    dec(f_vorbisHP);
	  end
	  else
	    break;
	  //
	  if (1 > f_vorbisHP) then begin
	    // This ensures the actual audio data will start on a new page, as per spec
	    f_oggOutFile.flush();
	  end;
	end;
	//
	if (1 > f_vorbisHP) then begin	// done with header?
	  // yes
	  if (f_vorbisEncode.popPacket(f_op)) then begin
	    //* weld the packet into the bitstream */
	    f_oggOutFile.packetin(f_op);
	    f_oggOutFile.pageOut();
	  end;
	end;
      end;
      //
      copyToStream := true;	// since we are not writing to file directly here,
				// allow oggEncoder to do that for us
      //				
    end
    else begin
      //
      case (f_encoderDestIndex) of

	0: begin
	  // mp3 file does not require any special handling
	  writeToFile(c_edit_destFile.text, data, size)
	end;

	1, 2: begin
	  //
	  case (f_ipComponentType[tipeEnc]) of

	    tiptSrv: begin
	      //
	      if (0 < f_sockId[tipeEnc]) then begin
		//
		i := 0;
		while (i < int(f_sockClients[tipeEnc].count)) do begin
		  //
		  f_socks.sendData(f_sockId[tipeEnc], data, size, unsigned(f_sockClients[tipeEnc][i]), asynch);
		  inc(i);
		end;
	      end;
	    end;

	    tiptCln: begin
	      //
	      f_socks.sendData(f_sockId[tipeEnc], data, size, f_sockConnId[tipeEnc], asynch);
	    end;

	  end;	// case
	  //
	  copyToStream := false;	// since we are not writing to file directly here,
					// allow oggEncoder to do that for us
	end;

      end;
    end;
  end;
end;

// --  --
procedure Tc_form_main.myOnDecoderDataAvail(sender: tObject; data: pointer; size: unsigned; var copyToStream: bool);
begin
  case (f_decoderSourceIndex) of

    0: copyToStream := true;	// local stream is needed to feed the waveOut

    1, 2: begin
      // seems like mpgLib has produced new chunk of PCM data
      waveOut.write(data, size);
      copyToStream := false;	
    end;

  end;
end;

// --  --
procedure Tc_form_main.c_checkBox_enableVBRClick(Sender: TObject);
begin
  c_comboBox_minBR.Enabled := (1 = c_comboBox_encoder.ItemIndex) and c_checkBox_enableVBR.Checked;
  c_comboBox_maxBR.Enabled := (1 = c_comboBox_encoder.ItemIndex) and c_checkBox_enableVBR.Checked;
  c_comboBox_vbrQuality.Enabled := (c_checkBox_enableVBR.Checked and (0 = c_comboBox_avBR.ItemIndex));
  //
  if (c_checkBox_enableVBR.Checked) then begin
    //
    c_comboBox_avBR.ItemIndex := 0;
    c_comboBox_avBRChange(self);
  end
  else
    c_comboBox_avBR.ItemIndex := 9;
end;

// --  --
procedure Tc_form_main.c_comboBox_encoderChange(Sender: TObject);
var
  index: int;
begin
  index := c_comboBox_encoder.itemIndex;	// 0 - Blade
						// 1 - Lame
						// 2 - Ogg/Vorbis
  //
  c_checkBox_enableVBR.enabled := (0 < index);
  if (not c_checkBox_enableVBR.Enabled) then
    c_checkBox_enableVBR.checked := false;
  //
  c_checkBox_disBRS.Enabled := (1 = index);	// Lame only
  //
  if (2 = index) then
    c_saveDialog_dest.filterIndex := 2
  else
    c_saveDialog_dest.filterIndex := 1;
  //
  c_checkBox_copyrighted.enabled := (2 > index);
  c_checkBox_original.enabled := (2 > index);
  c_checkBox_crc.enabled := (2 > index);
  c_checkBox_private.enabled := (2 > index);
end;

// --  --
procedure Tc_form_main.c_comboBox_decoderChange(Sender: TObject);
begin
  c_edit_sourceFileChange(self);
end;

// --  --
procedure Tc_form_main.c_comboBox_avBRChange(Sender: TObject);
begin
  if ((0 = c_comboBox_avBR.ItemIndex) and not c_checkBox_enableVBR.Checked) then begin
    c_comboBox_avBR.ItemIndex := 1;
    c_statusBar_main.Panels[1].Text := 'VBR mode must be enabled.';
  end;
  //
  c_comboBox_vbrQuality.Enabled := ((0 = c_comboBox_avBR.ItemIndex) and c_checkBox_enableVBR.Checked);
end;

// --  --
procedure Tc_form_main.c_comboBox_stereoModeChange(Sender: TObject);
begin
  if ((2 = c_comboBox_stereoMode.ItemIndex) and not (0 < c_comboBox_encoder.ItemIndex)) then begin
    c_comboBox_stereoMode.itemIndex := 1;
    c_statusBar_main.panels[1].text := 'Not supported by Blade encoder.';
  end;
end;

// --  --
procedure Tc_form_main.c_button_destBrowseClick(Sender: TObject);
begin
  if (c_saveDialog_dest.Execute()) then
    c_edit_destFile.text := trim(c_saveDialog_dest.fileName);
end;

// --  --
procedure Tc_form_main.c_button_sourceBrowseClick(Sender: TObject);
begin
  if (c_openDialog_source.Execute()) then
    c_edit_sourceFile.text := trim(c_openDialog_source.fileName);
end;

// --  --
procedure Tc_form_main.c_edit_destFileChange(Sender: TObject);
begin
  a_encode_start.enabled := ('' <> trim(c_edit_destFile.text));
  c_button_playback.enabled := a_encode_start.enabled;
end;

// --  --
procedure Tc_form_main.c_edit_sourceFileChange(Sender: TObject);
begin
  a_decode_start.enabled := not waveOut.active;
  //
  c_label_warningOgg.visible := (
    (0 = c_comboBox_decoder.itemIndex) and
    (
       not sameString('.ogg', extractFileExt(c_edit_sourceFile.text))
       and
       (1 > c_comboBox_decoderSource.itemIndex)
    )
  );
end;

// --  --
procedure Tc_form_main.c_button_playbackClick(Sender: TObject);
begin
  ShellExecuteA(handle, 'open', paChar(aString(c_edit_destFile.text)), nil, nil, SW_SHOWNORMAL);
end;

// --  --
procedure Tc_form_main.c_button_encCopyrightsClick(Sender: TObject);
begin
  c_form_about.doAboutEncode();
end;

// --  --
procedure Tc_form_main.c_checkBox_overwritePClick(Sender: TObject);
begin
  if (c_checkBox_overwriteP.checked) then
    c_saveDialog_dest.options := c_saveDialog_dest.Options + [ofOverwritePrompt]
  else
    c_saveDialog_dest.options := c_saveDialog_dest.Options - [ofOverwritePrompt];
end;

// --  --
procedure Tc_form_main.c_comboBox_inputDeviceChange(Sender: TObject);
begin
  waveIn.deviceId := c_comboBox_inputDevice.itemIndex - 1;
end;

// --  --
procedure Tc_form_main.c_comboBox_outputDeviceChange(Sender: TObject);
begin
  waveOut.deviceId := c_comboBox_outputDevice.itemIndex - 1;
end;

// --  --
procedure Tc_form_main.c_comboBox_encodedDestChange(Sender: TObject);
var
  isFile: bool;
  isServer: bool;
  isClient: bool;
begin
  isFile := (0 = c_comboBox_encodedDest.itemIndex);
  isServer := (2 = c_comboBox_encodedDest.itemIndex);
  isClient := (1 = c_comboBox_encodedDest.itemIndex);
  //
  c_edit_destFile.visible := isFile;
  c_button_destBrowse.visible := isFile;
  c_button_playback.visible := isFile;
  c_checkBox_overwriteP.visible := isFile;
  c_label_encoderMp3File.visible := isFile;
  //
  c_label_encSrvAddr.visible := isClient;
  c_edit_encSrvAddr.visible := isClient;
  c_edit_encPortNumber.visible := isServer or isClient;
  c_label_encPortNumber.visible := isServer or isClient;
  c_label_encType.visible := isServer or isClient;
  c_comboBox_encSocketType.visible := isServer or isClient;
end;

// --  --
procedure Tc_form_main.c_comboBox_decoderSourceChange(Sender: TObject);
var
  isFile: bool;
  isServer: bool;
  isClient: bool;
begin
  isFile := (0 = c_comboBox_decoderSource.itemIndex);
  isClient := (1 = c_comboBox_decoderSource.itemIndex);
  isServer := (2 = c_comboBox_decoderSource.itemIndex);
  //
  c_edit_sourceFile.visible := isFile;
  c_button_sourceBrowse.visible := isFile;
  c_label_sourceFile.visible := isFile;
  //
  c_label_decSrvAddr.visible := isClient;
  c_edit_decSrvAddr.visible := isClient;
  //
  c_label_decSrvPort.visible := isClient or isServer;
  c_label_decSrvSocketType.visible := isClient or isServer;
  c_edit_decSrvPort.visible := isClient or isServer;
  c_comboBox_decSrvSocketType.visible := isClient or isServer;
  //
  if (isClient or isServer) then
    c_comboBox_decoder.itemIndex := 2;	// only mpgLib is supported as stream decoder as for now
  //
  c_edit_sourceFileChange(self);
end;

// --  --
procedure Tc_form_main.waveOutFeedDone(sender: unavclInOutPipe; data: Pointer; len: Cardinal);
var
  realLen: int;
  feedLen: unsigned;
  //
  ok: bool;
begin
  case (f_decoderSourceIndex) of

    0: begin	// file, we have to read data from file and feed waveOut manually
      //
      if (len > f_feedBufSize) then begin
	//
	f_feedBufSize := len;
	mrealloc(f_feedBuf, f_feedBufSize);
      end;
      //
      feedLen := 0;
      ok := (f_mpgOK) or (nil <> f_bassFile) or ((nil <> f_vorbisDecode) and (nil <> f_oggInFile));
      //
      if (ok) then begin
	//
	repeat
	  //
	  realLen := 0;
	  case (f_decoderIndex) of

	    0: begin	// vorbis
	      //
	      if (nil <> f_vorbisDecode) then begin
		//
		realLen := f_vorbisDecode.readDecode(f_feedBuf, len - feedLen)
	      end
	    end;

	    1: begin	// BASS
	      //
	      if (nil <> f_bassFile) then begin
		//
		realLen := f_bassFile.asChannel.get_data(f_feedBuf, len - feedLen);
		if (0 < realLen) then
		  inc(f_bassDecodedSize, realLen);
		//
	      end;
	    end;

	    2: begin	// mpgLib
	      //
	      if (0 <> f_mpgFile) then begin
		//
		realLen := f_mpgDecoder.f_outStream.getSize();
		if (realLen < int(len - feedLen)) then begin
		  //
		  repeat
		    // feed more data to encoder
		    realLen := f_feedBufSize;
		    readFromFile(f_mpgFile, f_feedBuf, unsigned(realLen));
		    if (0 < realLen) then
		      f_mpgDecoder.write(f_feedBuf, realLen)
		    else
		      break;	// no more data
		    //
		    while (not f_mpgDecoder.shouldStop and (f_mpgDecoder.inDataSize > 0) and (f_mpgDecoder.f_outStream.getSize() < 1)) do
		      sleep(10);
		    //
		  until (f_mpgDecoder.shouldStop or (f_mpgDecoder.f_outStream.getSize() > 0));
		end;
		//
		if (0 < realLen) then
		  realLen := f_mpgDecoder.f_outStream.read(f_feedBuf, len - feedLen);
		//
	      end
	    end;

	  end;	// case
	  //
	  if (0 < realLen) then begin
	    //
	    // since decoder returns PCM samples, we can feed them directly to waveOut
	    if (not f_closingOut and not f_mpgNeedFormatUpdate) then
	      waveOut.write(f_feedBuf, realLen);
	    //
	    inc(feedLen, realLen);
	  end;
	  //
	until ((1 > realLen) or (feedLen >= len));
	//
	// check if we have reached end of the file
	if (0 >= realLen) then
	  a_decode_stop.execute();
	//
      end
      else
	a_decode_stop.execute();
      //
    end;

    1, 2: begin	// TCP/IP stream
      //
      case (f_decoderIndex) of

	0: begin	// vorbis
	  // not supported
	end;

	1: begin	// BASS
	  // not supported
	end;

	2: begin 	// mpgLib
	  // we will feed waveOut as soon as decoder has some new data in myOnDecoderDataAvail(), so nothing to do here
	end;

      end;	// case (f_decoderIndex)
    end;

  end;
end;

// --  --
procedure Tc_form_main.Exit1Click(Sender: TObject);
begin
  close();
end;

// --  --
procedure Tc_form_main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  a_encode_stop.execute();
  a_decode_stop.execute();
end;


end.

