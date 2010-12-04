//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "u_vccbMp3Demo_main.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "unaVcIDE"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
}

//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  f_config = new unaIniFile("", "settings", 1000, true);
  //loadControlPosition(self, f_config);
  //
  f_blade = new unaBladeMp3Enc("", THREAD_PRIORITY_NORMAL);
  f_lame = new unaLameMp3Enc("", THREAD_PRIORITY_NORMAL);
  f_vorbisEncode = new unaVorbisEnc("", "", THREAD_PRIORITY_NORMAL);
  f_vorbisDecode = new unaVorbisDecoder("", THREAD_PRIORITY_NORMAL);
  f_bassDecode = new unaBass("", -1, 44100, BASS_DEVICE_LEAVEVOL, 0);
  //
  f_feedBuf = NULL;
  f_feedBufSize = 0;
  //
  f_blade->onDataAvailable = myOnEncoderDataAvail;
  f_lame->onDataAvailable = myOnEncoderDataAvail;
  f_vorbisEncode->onDataAvailable = myOnEncoderDataAvail;
  f_vorbisDecode->onDataAvailable = myOnDecoderDataAvail;
  //
  f_bladeOK = (BE_ERR_SUCCESSFUL == f_blade->errorCode);
  f_lameOK = (BE_ERR_SUCCESSFUL == f_lame->errorCode);
  f_vorbisEncodeOK = (BE_ERR_SUCCESSFUL == f_vorbisEncode->errorCode);
  f_vorbisDecodeOK = (BE_ERR_SUCCESSFUL == f_vorbisDecode->errorCode);
  f_bassOK = (BASS_OK == f_bassDecode->get_errorCode());
  //
  enumAudioDevices();
  enumEngineDevices();
  //
  c_comboBox_encoderChange(this);
  c_comboBox_maxBR->Items->Assign(c_comboBox_minBR->Items);
  c_comboBox_minBR->ItemIndex = f_config->get_uint("encoder.bitrate.min.index", unsigned(8));
  c_comboBox_maxBR->ItemIndex = f_config->get_uint("encoder.bitrate.max.index", unsigned(8));
  c_comboBox_avBR->ItemIndex = f_config->get_uint("encoder.bitrate.av.index", unsigned(8));
  c_checkBox_enableVBRClick(this);
  //
  c_checkBox_disBRS->Checked = f_config->get_bool("encoder.lame.disableBrs", false);
  //
  c_comboBox_samplesRate->ItemIndex = 5;
  c_comboBox_stereoMode->ItemIndex = 1;
  c_comboBox_vbrQuality->ItemIndex = 0;
  //
  c_edit_destFile->Text = f_config->get_string("output.file.name", "");
  c_checkBox_overwriteP->Checked = f_config->get_bool("output.file.overwritePrompt", true);
  c_edit_sourceFile->Text = f_config->get_string("input.file.name", "");
  c_edit_portNumber->Text = f_config->get_string("server.ip.port", "17840");
  c_edit_serverPort->Text = f_config->get_string("client.ip.server.port", "17840");
  //
  c_comboBox_inputDevice->ItemIndex = f_config->get_int("input.device.index", int(0));
  c_comboBox_inputDeviceChange(this);
  c_comboBox_outputDevice->ItemIndex = f_config->get_int("output.device.index", int(0));
  c_comboBox_outputDeviceChange(this);
  //
  c_comboBox_encodedDest->ItemIndex = f_config->get_int("output.encoded.index", int(0));
  c_comboBox_encodedDestChange(this);
  c_comboBox_encodedSource->ItemIndex = f_config->get_int("input.encoded.index", int(0));
  c_comboBox_encodedSourceChange(this);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  a_encode_stop->Execute();
  a_decode_stop->Execute();
  //
  freeAndNil(&f_blade);
  freeAndNil(&f_lame);
  freeAndNil(&f_vorbisEncode);
  freeAndNil(&f_vorbisDecode);
  freeAndNil(&f_bassDecode);
  //
  f_feedBufSize = 0;
  mrealloc(&f_feedBuf, 0);
  //
  //saveControlPosition(self, f_config);
  //with (f_config) do begin
  f_config->setValue("encoder.index", c_comboBox_encoder->ItemIndex);
  f_config->setValue("decoder.index", c_comboBox_decoder->ItemIndex);
    //
  f_config->setValue("encoder.lame.disableBrs", c_checkBox_disBRS->Checked);
  f_config->setValue("encoder.bitrate.min.index", c_comboBox_minBR->ItemIndex);
  f_config->setValue("encoder.bitrate.max.index", c_comboBox_maxBR->ItemIndex);
  f_config->setValue("encoder.bitrate.av.index", c_comboBox_avBR->ItemIndex);
//
  f_config->setValue("server.ip.port", c_edit_portNumber->Text);
  f_config->setValue("client.ip.server.port", c_edit_serverPort->Text);
//
  f_config->setValue("output.file.name", c_edit_destFile->Text);
  f_config->setValue("input.file.name", c_edit_sourceFile->Text);
  f_config->setValue("output.file.overwritePrompt", c_checkBox_overwriteP->Checked);
  f_config->setValue("output.encoded.index", c_comboBox_encodedDest->ItemIndex);
  f_config->setValue("input.encoded.index", c_comboBox_encodedSource->ItemIndex);
  f_config->setValue("output.device.index", c_comboBox_outputDevice->ItemIndex);
  f_config->setValue("input.device.index", c_comboBox_inputDevice->ItemIndex);
  //end;
  //
  freeAndNil(&f_config);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_inputDeviceChange(TObject *Sender)
{
  waveIn->deviceId = c_comboBox_inputDevice->ItemIndex - 1;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_encoderChange(TObject *Sender)
{
  int index = c_comboBox_encoder->ItemIndex;	// 0 - Blade
						// 1 - Lame
						// 2 - Ogg/Vorbis
  //
  c_checkBox_enableVBR->Enabled = (0 < index);
  if (!c_checkBox_enableVBR->Enabled)
    c_checkBox_enableVBR->Checked = false;
  //
  c_checkBox_disBRS->Enabled = (1 == index);	// Lame only
  //
  if (2 == index)
    c_saveDialog_dest->FilterIndex = 2;
  else
    c_saveDialog_dest->FilterIndex = 1;
  //
  c_checkBox_copyrighted->Enabled = (2 > index);
  c_checkBox_original->Enabled = (2 > index);
  c_checkBox_CRC->Enabled = (2 > index);
  c_checkBox_private->Enabled = (2 > index);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_encodedDestChange(TObject *Sender)
{
  bool isFile = (0 == c_comboBox_encodedDest->ItemIndex);
  c_edit_destFile->Enabled = isFile;
  c_button_destBrowse->Enabled = isFile;
  c_button_playback->Enabled = isFile;
  c_checkBox_overwriteP->Enabled = isFile;
  c_label_encoderMp3File->Enabled = isFile;
  //
  c_edit_portNumber->Enabled = !isFile;
  c_label_portNumber->Enabled = !isFile;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_avBRChange(TObject *Sender)
{
  if ((0 == c_comboBox_avBR->ItemIndex) && !c_checkBox_enableVBR->Checked) {
    c_comboBox_avBR->ItemIndex = 1;
    c_statusBar_main->Panels->Items[1]->Text = "VBR mode must be enabled.";
  }
  //
  c_comboBox_vbrQuality->Enabled = ((0 == c_comboBox_avBR->ItemIndex) && c_checkBox_enableVBR->Checked);

}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_checkBox_enableVBRClick(TObject *Sender)
{
  c_comboBox_minBR->Enabled = (1 == c_comboBox_encoder->ItemIndex) && c_checkBox_enableVBR->Checked;
  c_comboBox_maxBR->Enabled = (1 == c_comboBox_encoder->ItemIndex) && c_checkBox_enableVBR->Checked;
  c_comboBox_vbrQuality->Enabled = (c_checkBox_enableVBR->Checked && (0 == c_comboBox_avBR->ItemIndex));
  if (c_checkBox_enableVBR->Checked) {
    c_comboBox_avBR->ItemIndex = 0;
    c_comboBox_avBRChange(this);
  }
  else
    c_comboBox_avBR->ItemIndex = 9;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_stereoModeChange(TObject *Sender)
{
  if ((2 == c_comboBox_stereoMode->ItemIndex) && !(0 < c_comboBox_encoder->ItemIndex)) {
    c_comboBox_stereoMode->ItemIndex = 1;
    c_statusBar_main->Panels->Items[1]->Text = "Not supported by Blade encoder.";
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_edit_destFileChange(TObject *Sender)
{
  a_encode_start->Enabled = (0 != trim(c_edit_destFile->Text, true, true).AnsiCompare(""));
  c_button_playback->Enabled = a_encode_start->Enabled;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_checkBox_overwritePClick(TObject *Sender)
{
  if (c_checkBox_overwriteP->Checked)
    c_saveDialog_dest->Options << ofOverwritePrompt;
  else
    c_saveDialog_dest->Options >> ofOverwritePrompt;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_button_encodeAboutClick(TObject *Sender)
{
  //c_form_about.doAboutEncode();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_button_destBrowseClick(TObject *Sender)
{
  if (c_saveDialog_dest->Execute())
    c_edit_destFile->Text = trim(c_saveDialog_dest->FileName, true, true);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_button_playbackClick(TObject *Sender)
{
  ::ShellExecute(Handle, "open", c_edit_destFile->Text.c_str(), NULL, NULL, SW_SHOWNORMAL);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_encodedSourceChange(TObject *Sender)
{
  bool isFile = (0 == c_comboBox_encodedSource->ItemIndex);
  c_edit_sourceFile->Enabled = isFile;
  c_button_sourceBrowse->Enabled = isFile;
  c_label_sourceFile->Enabled = isFile;
  //
  c_edit_serverPort->Enabled = !isFile;
  c_label_serverPort->Enabled = !isFile;
  //
  c_edit_sourceFileChange(this);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_decoderChange(TObject *Sender)
{
  c_edit_sourceFileChange(this);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_outputDeviceChange(TObject *Sender)
{
  waveOut->deviceId = c_comboBox_outputDevice->ItemIndex - 1;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_edit_sourceFileChange(TObject *Sender)
{
  a_decode_start->Enabled = !waveOut->active && (0 != trim(c_edit_sourceFile->Text, true, true).AnsiCompare(""));
  c_label_warningOgg->Visible = (
    (0 == c_comboBox_decoder->ItemIndex) &&
    (
       (0 != ExtractFileExt(c_edit_sourceFile->Text).AnsiCompare(".ogg"))
       ||
       (0 < c_comboBox_encodedSource->ItemIndex)
    )
  );
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_button_sourceBrowseClick(TObject *Sender)
{
  if (c_openDialog_source->Execute())
    c_edit_sourceFile->Text = trim(c_openDialog_source->FileName, true, true);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_timer_updateTimer(TObject *Sender)
{
  if (!ComponentState.Contains(csDestroying)) {
    //
    c_statusBar_main->Panels->Items[0]->Text = int2str(GetHeapStatus().TotalAllocated >> 10, 10, 3, ' ') + " KB";
    //
    if (f_encoder)
      c_statusBar_main->Panels->Items[1]->Text = "Encoder Output: " + int2str(f_encoder->encodedDataSize >> 10, 10, 3, ' ') + " KB";
    else
      switch (f_decoderIndex) {

	case 0 : //  Ogg/Vorbis
	  if (f_vorbisDecode)
	    c_statusBar_main->Panels->Items[1]->Text = "Ogg/Vorbis Decoder Out: " + int2str(f_vorbisDecode->encodedDataSize >> 10, 10, 3, ' ') + " KB";
	  break;


	case 1 : // BASS
	  c_statusBar_main->Panels->Items[1]->Text = "BASS Decoder Out: " + int2str(f_bassDecodeSize >> 10, 10, 3, ' ') + " KB";
	  break;

      }
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::a_encode_startExecute(TObject *Sender)
{
  BE_CONFIG bladeConfig;
  BE_CONFIG_FORMATLAME lameConfig;
  tVorbisSetup vorbisConfig;
  void* config;
  //
  unsigned minBR;
  unsigned maxBR;
  unsigned avBR;
  unsigned samplesRate;
  int stereoMode;
  //
  c_statusBar_main->Panels->Items[1]->Text = "";
  //
  switch (c_comboBox_encoder->ItemIndex) {

    case 0:
      f_encoder = f_blade;
      break;

    case 1:
      f_encoder = f_lame;
      break;

    case 2:
      f_encoder = f_vorbisEncode;
      break;

    default:
      f_encoder = NULL;
  }

  //
  if (f_encoder) {
    //
    config = NULL;
    //
    if (0 == c_comboBox_avBR->ItemIndex)
      avBR = 0;
    else
      avBR = str2intUnsigned(c_comboBox_avBR->Text, 128, 10);
    //
    if (c_checkBox_enableVBR->Checked) {
      minBR = str2intUnsigned(c_comboBox_minBR->Text, 128, 10);
      maxBR = str2intUnsigned(c_comboBox_maxBR->Text, 128, 10);
    }
    else {
      minBR = avBR;
      maxBR = avBR;
    }
    //
    samplesRate = str2intUnsigned(c_comboBox_samplesRate->Text, 44100, 10);
    //
    waveIn->pcm_numChannels = 2;
    switch (c_comboBox_stereoMode->ItemIndex) {

      case 0:
	stereoMode = BE_MP3_MODE_MONO;
	waveIn->pcm_numChannels = 1;
	break;

      case 1:
	stereoMode = BE_MP3_MODE_STEREO;
	break;

      case 2:
	stereoMode = BE_MP3_MODE_JSTEREO;
	break;

      case 3:
	stereoMode = BE_MP3_MODE_DUALCHANNEL;
	break;

      default:
	stereoMode = BE_MP3_MODE_STEREO;

    }
    //
    waveIn->pcm_samplesPerSec = samplesRate;
    waveIn->pcm_bitsPerSample = 16;
    //
    if (f_blade == f_encoder) {
      //
      memset(&bladeConfig, 0, sizeof(bladeConfig));
      bladeConfig.dwConfig = BE_CONFIG_MP3;
      //with bladeConfig.r_mp3 do begin
	bladeConfig.r_mp3.dwSampleRate = samplesRate;
	bladeConfig.r_mp3.byMode = stereoMode;
	bladeConfig.r_mp3.wBitrate = avBR;
	//
	bladeConfig.r_mp3.bPrivate = c_checkBox_private->Checked;
	bladeConfig.r_mp3.bCRC = c_checkBox_CRC->Checked;
	bladeConfig.r_mp3.bCopyright = c_checkBox_copyrighted->Checked;
	bladeConfig.r_mp3.bOriginal = c_checkBox_original->Checked;
      //end;
      config = &bladeConfig;
    }
    //
    if (!config && (f_lame == f_encoder)) {
      //
      memset(&lameConfig, 0, sizeof(lameConfig));
      lameConfig.dwConfig = BE_CONFIG_LAME;
      //with lameConfig.r_lhv1 do begin
	lameConfig.r_lhv1.dwStructVersion = CURRENT_STRUCT_VERSION;
	lameConfig.r_lhv1.dwStructSize = sizeof(lameConfig);
	lameConfig.r_lhv1.dwSampleRate = samplesRate;
	//dwReSampleRate := 0;
	lameConfig.r_lhv1.nMode = stereoMode;
	lameConfig.r_lhv1.dwBitrate = minBR;
	lameConfig.r_lhv1.dwMaxBitrate = maxBR;
	lameConfig.r_lhv1.nPreset = LQP_NOPRESET;
	lameConfig.r_lhv1.dwMpegVersion = MPEG2;
	//dwPsyModel := 0;
	//dwEmphasis := 0;
	lameConfig.r_lhv1.bPrivate = c_checkBox_private->Checked;
	lameConfig.r_lhv1.bCRC = c_checkBox_CRC->Checked;
	lameConfig.r_lhv1.bCopyright = c_checkBox_copyrighted->Checked;
	lameConfig.r_lhv1.bOriginal = c_checkBox_original->Checked;
	//
	lameConfig.r_lhv1.bWriteVBRHeader = false;
	lameConfig.r_lhv1.bEnableVBR = c_checkBox_enableVBR->Checked;
	lameConfig.r_lhv1.nVBRQuality = c_comboBox_vbrQuality->ItemIndex;
	//
	if (c_checkBox_enableVBR->Checked) {
	  //
	  lameConfig.r_lhv1.dwVbrAbr_bps = avBR;
	  if (0 < avBR) 
	    lameConfig.r_lhv1.nVbrMethod = VBR_METHOD_ABR;
	  else
	    lameConfig.r_lhv1.nVbrMethod = VBR_METHOD_NEW;
	}
	else
	  lameConfig.r_lhv1.nVbrMethod = VBR_METHOD_NONE;
	//
	lameConfig.r_lhv1.bNoRes = c_checkBox_disBRS->Checked;
	lameConfig.r_lhv1.bStrictIso = false;
	//btReserved := 0;
      //end;
      config = &lameConfig;
    };

    // --  --
    if (!config && (f_vorbisEncode == f_encoder)) {
      //
      memset(&vorbisConfig, 0, sizeof(vorbisConfig));
      //
      vorbisConfig.r_numOfChannels = waveIn->pcm_numChannels;
      vorbisConfig.r_samplingRate = samplesRate;
      //
      if (c_checkBox_enableVBR->Checked) {
	vorbisConfig.r_encodeMethod = vemVBR;
	vorbisConfig.r_quality = (10 - c_comboBox_vbrQuality->ItemIndex - 1.999) / 10;
      }
      else {
	vorbisConfig.r_encodeMethod = vemRateManage;
	vorbisConfig.r_manage_minBitrate = -1;
	vorbisConfig.r_manage_normalBitrate = avBR * 1000;
	vorbisConfig.r_manage_maxBitrate = -1;
	vorbisConfig.r_manage_mode = OV_ECTL_RATEMANAGE_AVG;
      }
      //
      config = &vorbisConfig;
    }

    //
    if (config) {
      //
      f_vorbisHP = 3;	// need to set this before opening the encoder
      if (BE_ERR_SUCCESSFUL == f_encoder->setConfig(config)) {
	//
	if (BE_ERR_SUCCESSFUL == f_encoder->open()) {
	  //
	  a_encode_stop->Enabled = true;
	  a_encode_start->Enabled = false;
	  //
	  c_edit_destFile->Enabled = false;
	  c_button_destBrowse->Enabled = false;
	  DeleteFile(c_edit_destFile->Text);
	  //
	  waveIn->waveInDevice->assignStream(false, (Unaclasses::unaAbstractStream*)NULL, false);
	  waveIn->open();
	}
	else {
	  c_statusBar_main->Panels->Items[1]->Text = "Open fails, error code: " + int2str(f_encoder->errorCode, 16, 0, ' ');
	  f_encoder = NULL;
	}
      }
      else {
	c_statusBar_main->Panels->Items[1]->Text = "Config fails, error code: " + int2str(f_encoder->errorCode, 16, 0, ' ');
	f_encoder = NULL;
      }
    }
  }
  else
    c_statusBar_main->Panels->Items[1]->Text = "Please select an encoder.";

}
//---------------------------------------------------------------------------

void __fastcall TForm1::a_encode_stopExecute(TObject *Sender)
{
  if (f_encoder) {
    //
    waveIn->close(0);
    f_encoder->close();
    //
    a_encode_stop->Enabled = false;
    a_encode_start->Enabled = true;
    //
    c_edit_destFile->Enabled = (0 == c_comboBox_encodedDest->ItemIndex);
    c_button_destBrowse->Enabled = c_edit_destFile->Enabled;
    if (f_oggOutFile)
      flushOgg();
    //
    freeAndNil(&f_oggOutFile);
    //
    f_encoder = NULL;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::a_decode_startExecute(TObject *Sender)
{
  bool ok;
  int freq;
  int volume;
  int pan;
  DWORD flags;
  //
  a_decode_start->Enabled = false;
  //
  c_statusBar_main->Panels->Items[1]->Text = "";
  f_decoderIndex = c_comboBox_decoder->ItemIndex;	// 0 - Ogg/Vorbis
							// 1 - BASS
  //
  switch (c_comboBox_encodedSource->ItemIndex) {

    case 0: {	// file

      switch (f_decoderIndex) {

	case 0: 	// Ogg/Vorbis library
	  //
	  ok = true;
	  f_oggInFile = new unaOggFile(c_edit_sourceFile->Text, -1, GENERIC_READ);
	  if (0 != f_oggInFile->errorCode) {
	    c_statusBar_main->Panels->Items[1]->Text = "OGG File Error code: " + int2str(f_oggInFile->errorCode, 10, 0, ' ');
	    ok = false;
	  }
	  else {
	    // create decoder as well
	    f_vorbisDecode = new unaVorbisDecoder("", THREAD_PRIORITY_NORMAL);
	    // init ogg reader and vorbis decoder
	    f_oggInFile->sync_init();
	    //
	    if (0 == f_oggInFile->vorbis_decode_int(f_vorbisDecode)) {
	      // init and open waveOut device
	      waveOut->pcm_samplesPerSec = f_vorbisDecode->vi->rate;
	      waveOut->pcm_bitsPerSample = 16;	// vorbis always has 16 bits
	      waveOut->pcm_numChannels = f_vorbisDecode->vi->channels;
	      //
	      f_vorbisDecode->decode_initBuffer(8912);
	      //
	      waveOut->open();
	      // make sure waveOut will fire waveOutAfterChunkFeed() event, so we will start self-feeding cycle
	      waveOut->flush();
	    }
	    else {
	      c_statusBar_main->Panels->Items[1]->Text = "OGG Decoder Error code: " + int2str(f_oggInFile->errorCode, 10, 0, ' ');
	      ok = false;
	    }
	  }
	  //
	  if (!ok)
	    a_decode_stopExecute(Sender);
	  //
	  break;

	case 1:
	  //
	  f_bassFile = new unaBassStream(f_bassDecode, false);
	  //
	  if (f_bassFile->createStream(c_edit_sourceFile->Text, 0, 0, BASS_STREAM_DECODE)) {
	    //
	    f_bassFile->asChannel->get_attributes(freq, volume, pan);
	    flags = f_bassFile->asChannel->get_flags();
	    //
	    waveOut->pcm_samplesPerSec = freq;
	    //
	    if (0 != (BASS_SAMPLE_8BITS & flags))
	      waveOut->pcm_bitsPerSample = 8;
	    else
	      waveOut->pcm_bitsPerSample = 16;
	    //
	    if (0 != (BASS_SAMPLE_MONO & flags))
	      waveOut->pcm_numChannels = 1;
	    else
	      waveOut->pcm_numChannels = 2;
	    //
	    f_bassDecodeSize = 0;
	    waveOut->open();
	    // make sure waveOut will fire waveOutAfterChunkFeed() event, so we will start feeding cycle
	    waveOut->flush();
	  }
	  else {
	    c_statusBar_main->Panels->Items[1]->Text = "File decoding error: " + int2str(f_bassDecode->get_errorCode(), 10, 0, ' ');
	    freeAndNil(&f_bassFile);
	    a_decode_start->Enabled = true;
	  }
	  //
	  break;

	default:
	  c_statusBar_main->Panels->Items[1]->Text = "Unknown decode library";
	  a_decode_start->Enabled = true;

      }
      break;

    }

    case 1: 	// IP stream
      c_statusBar_main->Panels->Items[1]->Text = "Not implemented";
      a_decode_start->Enabled = true;
      break;

  };

  //
  a_decode_stop->Enabled = !a_decode_start->Enabled;
  c_comboBox_encodedSource->Enabled = a_decode_start->Enabled;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::a_decode_stopExecute(TObject *Sender)
{
  waveOut->close(0);
  //
  switch (f_decoderIndex) {

    case 0: 	// Ogg/Vorbis
      freeAndNil(&f_oggInFile);
      freeAndNil(&f_vorbisDecode);
      break;

    case 1: 	// BASS
      freeAndNil(&f_bassFile);
      break;

  }
  //
  a_decode_start->Enabled = true;
  a_decode_stop->Enabled = !a_decode_start->Enabled;
  c_comboBox_encodedSource->Enabled = a_decode_start->Enabled;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::waveInDataAvailable(unavclInOutPipe *sender,
      Pointer data, DWORD len)
{
  if (f_encoder) {
    // use lazy thread to return to waveIn ASAP
    f_encoder->lazyWrite(data, len);

    // or we can use synchronous encode
    //f_encoder.encodeChunk(data, len);
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::waveOutFeedChunk(unavclInOutPipe *sender,
      Pointer data, DWORD len)
{
  int realLen;
  unsigned feedLen;
  //
  bool ok;
  //
  if (len > f_feedBufSize) {
    f_feedBufSize = len;
    mrealloc(&f_feedBuf, f_feedBufSize);
  };
  //
  feedLen = 0;
  ok = (f_bassFile || (f_vorbisDecode && f_oggInFile));
  //
  if (ok) {
    //
    do {
      if (f_bassFile)
	realLen = f_bassFile->asChannel->get_data(f_feedBuf, len - feedLen);
      else
	realLen = f_vorbisDecode->readDecode(f_feedBuf, len - feedLen);
      //
      if (0 < realLen) {
	// since BASS returns PCM samples, we can feed them directly to waveOut
	waveOut->write(f_feedBuf, realLen, NULL);
	f_bassDecodeSize += realLen;
      }
      //
      feedLen += realLen;
      //
    }
    while ((1 <= realLen) && (feedLen < len));
    //
    // check if we have reached end of the file
    if (0 >= realLen)
      a_decode_stop->Execute();
  }
  else
    a_decode_stop->Execute();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::flushOgg() {
  //
  while (f_vorbisEncode->popPacket(f_op)) {
    //* weld the packet into the bitstream */
    f_oggOutFile->packetIn(f_op);
    f_oggOutFile->pageOut();
  }
  //
  f_oggOutFile->flush();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::enumAudioDevices() {
  //
  int i;
  WAVEINCAPSW inCaps;
  WAVEOUTCAPSW outCaps;
  // enum waveIn/Out devices

  // PCM INPUT
  c_comboBox_inputDevice->Clear();
  //
  for (i = -1; i < (int)unaWaveInDevice::getDeviceCount(NULL); i++) {
    unaWaveInDevice::getCaps(NULL, (unsigned)i, inCaps);
    c_comboBox_inputDevice->Items->Add(inCaps.szPname);
  }
  c_comboBox_inputDevice->ItemIndex = 0;

  // ENCODED INPUT
  c_comboBox_encodedSource->Clear();
  c_comboBox_encodedSource->Items->Add("MP3/Ogg file");
    //items.add('MP3/Ogg Streaming Demo [Server]');
  c_comboBox_encodedSource->ItemIndex = 0;

  // RAW OUTPUT
  c_comboBox_outputDevice->Clear();
  //
  for (i = -1; i < (int)unaWaveInDevice::getDeviceCount(NULL) - 1; i++) {
    unaWaveOutDevice::getCaps(NULL, (unsigned)i, outCaps);
    c_comboBox_outputDevice->Items->Add(outCaps.szPname);
  }
  c_comboBox_outputDevice->ItemIndex = 0;

  // ENCODED OUTPUT
  c_comboBox_encodedDest->Clear();
  c_comboBox_encodedDest->Items->Add("MP3/Ogg file");
  //items.add('MP3/Ogg Streaming Demo [Client]');
  c_comboBox_encodedDest->ItemIndex = 0;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::enumEngineDevices() {
  //
  c_comboBox_encoder->Clear();
  c_comboBox_decoder->Clear();

  // BLADE MP3 ENCODER
  if (f_bladeOK)
    c_comboBox_encoder->Items->Add("Blade MP3 Encoder, version " + int2str(f_blade->version->byMajorVersion, 10, 0, ' ') + '.' + int2str(f_blade->version->byMinorVersion, 10, 0, ' '));
  else
    c_comboBox_encoder->Items->Add("Blade MP3 Encoder - required module was not found.");

  // LAME MP3 ENCODER
  if (f_lameOK)
    c_comboBox_encoder->Items->Add("Lame MP3 Encoder, version " + int2str(f_lame->version->byMajorVersion, 10, 0, ' ') + "." + int2str(f_lame->version->byMinorVersion, 10, 0, ' '));
  else
    c_comboBox_encoder->Items->Add("Lame MP3 Encoder - required module was not found.");

  // VORBIS ENCODER
  if (f_vorbisEncodeOK)
    c_comboBox_encoder->Items->Add("Ogg/Vorbis Encoder, version " + int2str(f_vorbisEncode->version, 10, 0, ' '));
  else
    c_comboBox_encoder->Items->Add("Ogg/Vorbis Encoder - required module(s) was not found.");

  // VORBIS DECODER
  if (f_vorbisDecodeOK)
    c_comboBox_decoder->Items->Add("Ogg/Vorbis Decoder, version " + int2str(f_vorbisDecode->version, 10, 0, ' '));
  else
    c_comboBox_decoder->Items->Add("Ogg/Vorbis Decoder - required module(s) was not found.");

  // BASS MP3/Ogg DECODER
  if (f_bassOK)
    c_comboBox_decoder->Items->Add("BASS MP3/Ogg decoder, version " + f_bassDecode->get_versionStr());
  else
    c_comboBox_decoder->Items->Add("BASS MP3/Ogg decoder - required module(s) was not found.");

  //
  c_comboBox_encoder->ItemIndex = f_config->get("encoder.index", unsigned(0));
  c_comboBox_decoder->ItemIndex = f_config->get("decoder.index", unsigned(0));
}
//---------------------------------------------------------------------------
void __fastcall TForm1::myOnEncoderDataAvail(TObject* sender, void* data, unsigned size, int& copyToStream) {
  //
  if (f_encoder) {
    //
    if (f_vorbisEncode == f_encoder) {
      //
      if (!f_oggOutFile)
	f_oggOutFile = new unaOggFile(c_edit_destFile->Text, -1, GENERIC_WRITE);
      //
      if (0 != f_oggOutFile->errorCode) {
	c_statusBar_main->Panels->Items[1]->Text = "OGG library error code: " + int2str(f_oggOutFile->errorCode, 10, 0, ' ');
      }
      else {
	// care about vorbis header
	while (0 < f_vorbisHP) {
	  //
	  if (f_vorbisEncode->popPacket(f_op)) {
	    f_oggOutFile->packetIn(f_op);
	    f_vorbisHP--;
	  }
	  else
	    break;
	  //
	  if (1 > f_vorbisHP) {
	    // This ensures the actual audio data will start on a new page, as per spec
	    f_oggOutFile->flush();
	  }
	}
	//
	if (1 > f_vorbisHP) {	// done with header?
	  // yes
	  if (f_vorbisEncode->popPacket(f_op)) {
	    //* weld the packet into the bitstream */
	    f_oggOutFile->packetIn(f_op);
	    f_oggOutFile->pageOut();
	  }
	}
      }
      //
      copyToStream = true;	// since we are not writing to file directly here,
				// allow oggEncoder to do that for us
    }
    else
      // mp3 file does not require any special handling
      writeToFile(c_edit_destFile->Text, data, size, 0, FILE_END);
  }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::myOnDecoderDataAvail(TObject* sender, void* data, unsigned size, int& copyToStream) {
  //
  copyToStream = true;	// since we are not writing data here, let decoder do that for us
}


