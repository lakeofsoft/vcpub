//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "u_vccbMixer_main.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
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
  f_waveIn = new unaWaveInDevice(WAVE_MAPPER, false, false, 1);
  f_waveIn->setSampling(44100, 16, 2);
  f_waveIn->calcVolume = true;
  //
  c_comboBox_mixerIndex->Clear();
  //
  f_mixerSystem = new unaMsMixerSystem(-1);
  if (0 < f_mixerSystem->getMixerCount()) {
    //
    unsigned i = 0;
    while (i < f_mixerSystem->getMixerCount()) {
      //
      f_mixerSystem->selectMixer(i, NULL);
      c_comboBox_mixerIndex->Items->Add(f_mixerSystem->getMixerName());
      i++;
    }
    //
    c_comboBox_mixerIndex->ItemIndex = 0;
  }
  //
  c_comboBox_mixerIndexChange(Sender);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  freeAndNil(&f_mixerSystem);
  freeAndNil(&f_waveIn);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::a_recordExecute(TObject *Sender)
{
  int res = f_waveIn->open(false, 1000, 0);
  //
  if (!f_waveIn->isOpen())
    ShowMessage("Unable to open waveIn device, error text: \r\n" + f_waveIn->getErrorText(NULL, res));
  //
  reEnable();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::a_stopExecute(TObject *Sender)
{
  f_waveIn->close(1000);
  //
  reEnable();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_inConnChange(TObject *Sender)
{
  f_inConn = c_comboBox_inConn->ItemIndex;
  rebuildVolumeBar(c_trackBar_in, f_inLineIndex, f_inConn);
  if (0 <= f_inConn)
    f_mixerSystem->setRecSource(f_inConn, false);
  //
  //
  c_checkBox_inMuted->Tag = f_mixerSystem->getMuteControlID(f_inLineIndex, f_inConn);
  c_checkBox_inMuted->Enabled = (0 <= f_inConn) && (0 <= c_checkBox_inMuted->Tag);
  //
  if (c_checkBox_inMuted->Enabled)
    updateMixerControl(c_checkBox_inMuted->Tag);
  else
    c_checkBox_inMuted->Checked = false;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_voumeBar_change(TObject *Sender)
{
  int tag = (dynamic_cast<TControl*>(Sender))->Tag;
  //
  //
  if (f_volumeBar[tag].r_allowChange) {
    int pos = (dynamic_cast<TTrackBar*>(Sender))->Position;
    f_mixerSystem->setVolume(f_volumeBar[tag].r_lineIndex, f_volumeBar[tag].r_connIndex, pos);
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_timer_updateTimer(TObject *Sender)
{
  if (!ComponentState.Contains(csDestroying)) {
    //
    c_progressBar_left->Position = waveGetLogVolume(f_waveIn->getVolume(0));
    c_progressBar_right->Position = waveGetLogVolume(f_waveIn->getVolume(1));
    //
    c_statusBar_main->Panels->Items[0]->Text = "Mem: " + int2str(GetHeapStatus().TotalAllocated >> 10, 10, 3, ' ') + " KB";
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_mixerIndexChange(TObject *Sender)
{
  changeMixer(c_comboBox_mixerIndex->ItemIndex);

}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_comboBox_outConnChange(TObject *Sender)
{
  f_outConn = c_comboBox_outConn->ItemIndex;
  rebuildVolumeBar(c_trackBar_out, f_outLineIndex, f_outConn);
  //
  c_checkBox_outMute->Tag = f_mixerSystem->getMuteControlID(f_outLineIndex, f_outConn);
  c_checkBox_outMute->Enabled = (0 <= f_outConn) && (0 <= c_checkBox_outMute->Tag);
  //
  if (c_checkBox_outMute->Enabled)
    updateMixerControl(c_checkBox_outMute->Tag);
  else
    c_checkBox_outMute->Checked = true;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_label_URLClick(TObject *Sender)
{
  ShellExecute(0, "open", "http://lakeofsoft.com/vc/", NULL, NULL, SW_SHOWNORMAL);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_checkBox_outMuteClick(TObject *Sender)
{
  if (c_checkBox_outMute->Enabled)
    f_mixerSystem->muteConnection(f_outLineIndex, f_outConn, c_checkBox_outMute->Checked);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_checkBox_inMutedClick(TObject *Sender)
{
  if (c_checkBox_inMuted->Enabled)
    f_mixerSystem->muteConnection(f_inLineIndex, f_inConn, c_checkBox_inMuted->Checked);

}
//---------------------------------------------------------------------------

void __fastcall TForm1::c_checkBox_micForceClick(TObject *Sender)
{
  int micIndex;
  if (c_checkBox_micForce->Checked)
    micIndex = f_mixerSystem->getLineConnectionByType(f_inLineIndex, MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE, 0);
  else
    micIndex = f_mixerSystem->getRecSource();
  //
  c_comboBox_inConn->ItemIndex = micIndex;
  c_comboBox_inConnChange(this);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::SpeedButton1Click(TObject *Sender)
{
  c_trackBar_in->Position = c_trackBar_in->Position - 1;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::SpeedButton2Click(TObject *Sender)
{
  c_trackBar_in->Position = c_trackBar_in->Position + 1;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::changeMixer(int mixerIndex) {
  //
  unsigned i;
  //
  a_stop->Execute();
  //
  if (0 <= mixerIndex && mixerIndex < int(f_mixerSystem->getMixerCount())) {
    //
    c_comboBox_inConn->Clear();
    c_comboBox_outConn->Clear();
    //
    c_comboBox_inConn->Enabled = false;
    c_comboBox_outConn->Enabled = false;
    //
    c_trackBar_in->Enabled = false;
    c_trackBar_out->Enabled = false;
    //
    f_mixerSystem->selectMixer(mixerIndex, unsigned(Handle));
    //
    f_inLineIndex = f_mixerSystem->getLineIndex(false, -1);
    f_outLineIndex = f_mixerSystem->getLineIndex(true, -1);
    //
    if (0 <= f_inLineIndex) {
      // fill input lines
      c_label_in->Caption = "&" + f_mixerSystem->getLineName(f_inLineIndex, false);
      //
      rebuildVolumeBar(c_trackBar_inMain, f_inLineIndex, -1, true);
      //
      i = 0;
      while (i < f_mixerSystem->getLineConnectionCount(f_inLineIndex)) {
	//
	c_comboBox_inConn->Items->Add(f_mixerSystem->getLineConnectionName(f_inLineIndex, i, false));
	i++;
      }
      //
      if (0 < i) {
	//
	c_comboBox_inConn->Enabled = true;
	c_checkBox_micForceClick(this);
      }
    }
    //
    if (0 <= f_outLineIndex) {
      // fill output lines
      c_label_out->Caption = "&" + f_mixerSystem->getLineName(f_outLineIndex, false);
      //
      rebuildVolumeBar(c_trackBar_outMain, f_outLineIndex, -1, true);
      //
      i = 0;
      while (i < f_mixerSystem->getLineConnectionCount(f_outLineIndex)) {
	//
	c_comboBox_outConn->Items->Add(f_mixerSystem->getLineConnectionName(f_outLineIndex, i, false));
	i++;
      }
      //
      if (0 < i) {
	c_comboBox_outConn->Enabled = true;
	//
	c_comboBox_outConn->ItemIndex = 0;
	c_comboBox_outConnChange(this);
      }
    }
    //
  }
  //
  f_waveIn->deviceId = mixerIndex;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::reEnable() {
  a_record->Enabled = !f_waveIn->isOpen();
  a_stop->Enabled = !a_record->Enabled;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::onMixerControlChange(TMessage& msg) {
  updateMixerControl(msg.LParam);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::rebuildVolumeBar(TTrackBar* trackBar, unsigned iline, int iconn, bool allowNoConn) {
  //
  //with (trackBar) do begin
    //
    //with (f_volumeBar[tag]) do begin
      //
      f_volumeBar[trackBar->Tag].r_lineIndex = iline;
      f_volumeBar[trackBar->Tag].r_connIndex = iconn;
      f_volumeBar[trackBar->Tag].r_controlId = f_mixerSystem->getVolumeControlID(iline, iconn);
      f_volumeBar[trackBar->Tag].r_allowChange = true;
      //
      trackBar->Enabled = (0 <= f_volumeBar[trackBar->Tag].r_controlId) && ((0 <= iconn) || allowNoConn);
      //
      if (trackBar->Enabled)
	updateMixerControl(f_volumeBar[trackBar->Tag].r_controlId);
      else
	trackBar->Position = 0;
    //end;
  //end;
}
//---------------------------------------------------------------------------
bool __fastcall TForm1::updateVolumeBar(TTrackBar* trackBar, unsigned controlID) {
  //
  //with (trackBar) do begin
    //
    //with (f_volumeBar[tag]) do begin
      //
      if (f_volumeBar[trackBar->Tag].r_controlId == int(controlID)) {
	//
	f_volumeBar[trackBar->Tag].r_allowChange = false;
	//try
	  trackBar->Position = f_mixerSystem->getVolume(f_volumeBar[trackBar->Tag].r_lineIndex, f_volumeBar[trackBar->Tag].r_connIndex);
	//finally
	  f_volumeBar[trackBar->Tag].r_allowChange = true;
	//end;
	//
	return(true);
      }
      else
	return(false);
    //end;
  //end;
}
//---------------------------------------------------------------------------
void TForm1::updateMixerControl(unsigned controlID) {
  //
  if (updateVolumeBar(c_trackBar_in, controlID)) ;
  else
  if (updateVolumeBar(c_trackBar_out, controlID)) ;
  else
  if (updateVolumeBar(c_trackBar_inMain, controlID)) ;
  else
  if (updateVolumeBar(c_trackBar_outMain, controlID)) ;
  else
  if (c_checkBox_inMuted->Tag == int(controlID)) {
    //
    //with (c_checkBox_inMuted) do begin
      //
      c_checkBox_inMuted->Enabled = false;
      //try
	c_checkBox_inMuted->Checked = f_mixerSystem->isMutedConnection(f_inLineIndex, f_inConn);
      //finally
	c_checkBox_inMuted->Enabled = true;
      //end;
    //end;
  }
  else
  if (c_checkBox_outMute->Tag == int(controlID)) {
    //
    //with (c_checkBox_outMute) do begin
      //
      c_checkBox_outMute->Enabled = false;
      //try
	c_checkBox_outMute->Checked = f_mixerSystem->isMutedConnection(f_outLineIndex, f_outConn);
      //finally
	c_checkBox_outMute->Enabled = true;
      //end;
    //end;
  }
  else {
    // check if recording source was changed
    int newRecSource = f_mixerSystem->getRecSource();
    if ((0 <= newRecSource) && (newRecSource != f_inConn)) {
      //
      c_comboBox_inConn->ItemIndex = newRecSource;
      c_comboBox_inConnChange(this);
    }
  }
}









