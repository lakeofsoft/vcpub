//---------------------------------------------------------------------------

#include <vcl.h>
#include <mem.h>
#pragma hdrstop

#include "u_cbvcWavePlayer_main.h"
#include "unaWave.hpp"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "unaVcIDE"
#pragma resource "*.dfm"
Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
__fastcall Tc_form_main::Tc_form_main(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::reEnableControls(bool isOpen)
{
  a_playback_start->Enabled = !isOpen;
  a_playback_stop->Enabled = isOpen;
  //
  c_edit_fileName->Enabled = !isOpen;
  c_trackBar_pos->Enabled = isOpen;
  if (!c_trackBar_pos->Enabled)
    wavRead->waveStream->streamPosition = 0;
  //
  c_trackBar_tempo->Enabled = isOpen;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::FormCreate(TObject *Sender)
{
  f_config = new unaIniFile("", "settings", 1000, true);
  //
  //loadControlPosition(self, f_config);
  //
  reEnableControls(false);
  //
  c_edit_fileName->Text = f_config->get_string("gui.file.name", "");
  c_checkBox_enableGO->Checked = f_config->get_bool("gui.go.checked", true);
  c_checkBox_autoRewind->Checked = f_config->get_bool("gui.ar.checked", false);
  //
  c_edit_fileNameChange(Sender);
  //
  f_invalidateIsDone = true;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::FormDestroy(TObject *Sender)
{
  a_playback_stop->Execute();
  //
  //saveControlPosition(self, f_config);
  //
  f_config->setValue("gui.file.name", c_edit_fileName->Text);
  f_config->setValue("gui.go.checked", c_checkBox_enableGO->Checked);
  f_config->setValue("gui.ar.checked", c_checkBox_autoRewind->Checked);
  //
  delete f_config;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::a_file_openExecute(TObject *Sender)
{
  if (c_openDialog_main->Execute()) {
    c_edit_fileName->Text = c_openDialog_main->FileName;
    if (!wavRead->active) {
      wavRead->fileName = c_edit_fileName->Text;
      c_statusBar_main->Panels->Items[1]->Text = wavRead->waveStream->srcFormatInfo;
    }
  }
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::c_edit_fileNameChange(TObject *Sender)
{
  a_playback_start->Enabled = !wavRead->active && (fileExists(trim(c_edit_fileName->Text, true, true)));
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::c_go_updateTimer(TObject *Sender)
{
  if (!ComponentState.Contains(csDestroying)) {
    //
    if (!f_inTimerGO) {
      //
      f_inTimerGO = true;
      //
      if (!f_invalidateIsDone)
	if (c_checkBox_enableGO->Checked)
	  c_paintBox_wave->Refresh();
      //
      c_progressBar_volumeLeft->Position = waveGetLogVolume(resampler->resampler->getVolume(0));
      c_progressBar_volumeRight->Position = waveGetLogVolume(resampler->resampler->getVolume(1));
      //
      f_inTimerGO = false;
    }
  }
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::a_playback_startExecute(TObject *Sender)
{
  reEnableControls(true);
  //
  wavRead->fileName = c_edit_fileName->Text;
  c_statusBar_main->Panels->Items[1]->Text = wavRead->waveStream->srcFormatInfo;
  c_statusBar_main->Hint = wavRead->waveStream->srcFormatInfo;
  //
  f_needSome = true;
  //
  wavRead->open();
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::a_playback_stopExecute(TObject *Sender)
{
  wavRead->close(0);
  //
  reEnableControls(false);
  //
  c_trackBar_tempo->Position = 10;
  c_trackBar_volume->Position = 10;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::c_checkBox_autoRewindClick(TObject *Sender)
{
  wavRead->loop = c_checkBox_autoRewind->Checked;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::c_trackBar_posChange(TObject *Sender)
{
  if (!f_autoSeekPos) {
    int pos = (wavRead->waveStream->streamSize / 100) * c_trackBar_pos->Position;
    wavRead->waveStream->streamPosition = pos;
  }
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::wavReadDataAvailable(unavclInOutPipe *sender, Pointer data, DWORD len)
{
  f_needSome = false;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::c_timer_updateTimer(TObject *Sender)
{
  if (!ComponentState.Contains(csDestroying)) {
    f_inTimer = true;
    //
    c_statusBar_main->Panels->Items[0]->Text = int2str(GetHeapStatus().TotalAllocated >> 10, 10, 3, ' ') + " KB";
    //
    f_autoSeekPos = true;
    c_trackBar_pos->Position = percent(wavRead->waveStream->streamPosition, wavRead->waveStream->streamSize);
    f_autoSeekPos = false;
    //
    c_statusBar_main->Panels->Items[2]->Text = IntToStr(wavRead->waveStream->streamPosition) + '/' + IntToStr(wavRead->waveStream->streamSize);
    //
    if (!f_needSome && waveOut->active && wavRead->waveStream->streamIsDone && (resampler->resampler->chunkSize > resampler->availableDataLenIn))
      a_playback_stop->Execute();
  }
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::c_trackBar_volumeChange(TObject *Sender)
{
  int pos = c_trackBar_volume->Max - c_trackBar_volume->Position;
  resampler->resampler->setVolume(-1, pos * 100);
  c_label_vol->Caption = IntToStr(pos * 10) + "%";
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::waveOutFeedChunk(unavclInOutPipe *sender, Pointer data, DWORD len)
{
  if (!ComponentState.Contains(csDestroying)) {
    //
    if (f_invalidateIsDone) {
      memcpy(&f_samples, data, len);
      f_samplesCount = len >> 2;	// 16 bits; 2 channels
      f_invalidateIsDone = false;
    }
  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_paintBox_wavePaint(TObject *Sender)
{
  c_paintBox_wave->Canvas->Brush->Color = clBtnFace;
  c_paintBox_wave->Canvas->FillRect(GetClientRect());
  //
  if (0 < f_samplesCount) {
    //
    double stepH = double(c_paintBox_wave->Width * 2) / f_samplesCount;
    double stepV = double(c_paintBox_wave->Height) / 65536;
    double offsetV = double(c_paintBox_wave->Height) / 2;
    //
    double pos = 0;
    //
    unsigned i = 0;
    while (i < f_samplesCount) {
      c_paintBox_wave->Canvas->Pixels[pos][offsetV - f_samples[i + 0] * stepV] = clBlue;
      c_paintBox_wave->Canvas->Pixels[pos][offsetV - f_samples[i + 1] * stepV] = clRed;
      pos = pos + stepH;
      i += 2;
    }
  }
  //
  f_invalidateIsDone = true;
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_trackBar_tempoChange(TObject *Sender)
{
  if (f_oldTempo != unsigned(c_trackBar_tempo->Position)) {
    unsigned pos = c_trackBar_tempo->Position * 10;	// 0% .. 100% .. 200%
    if (1 > pos) 
      pos = 10;	// 10% instead of 0%
    //
    unsigned rate = (44100 * pos) / 100;
    //
    resampler->resampler->setSampling(false, rate, 16, 2);
    wavRead->waveStream->realTimer->interval = ((1000 / wavRead->waveStream->chunkPerSecond) * pos) / 100;
    c_label_tempo->Caption = IntToStr(200 - pos) + "%";
    f_oldTempo = c_trackBar_tempo->Position;
  }
}
//---------------------------------------------------------------------------

