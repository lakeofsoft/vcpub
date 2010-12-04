//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "u_cbMgClient_main.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "unaVcIDE"
#pragma resource "*.dfm"
Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
__fastcall Tc_form_main::Tc_form_main(TComponent* Owner)
	: TForm(Owner) {
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::FormCreate(TObject *Sender) {
#ifdef _DEBUG
  randomize();
#endif
  //
  c_edit_host->Text = "192.168.1.1";
  c_edit_speakPort->Text = "17860";
  c_edit_listenPort->Text = "17861";
  c_rb_speak->Checked = true;
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormCloseQuery(TObject *Sender, bool &CanClose) {
  c_timer_update->Enabled = false;
  a_cln_stop->Execute();
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormShow(TObject *Sender) {
  //
#ifdef _DEBUG
  c_clb_debug->Visible = true;
#else
  c_clb_debug->Visible = false;
#endif
  c_checkBox_random->Visible = c_clb_debug->Visible;
  //
  c_timer_update->Enabled = true;
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_timer_updateTimer(TObject *Sender) {
#ifdef _DEBUG
    c_clb_debug->Checked[0] = waveIn->active;
    c_clb_debug->Checked[1] = codecIn->active;
    c_clb_debug->Checked[2] = ipClient->active;
    c_clb_debug->Checked[3] = codecOut->active;
    c_clb_debug->Checked[4] = waveOut->active;
#endif
    //
    c_statusBar_main->Panels->Items[0]->Text = "Mem: " + int2str(GetHeapStatus().TotalAllocated >> 10, 10, 3, ' ') + " KB";
    //
    if (c_rb_speak->Checked) {
      //
      unsigned sampleSize = codecIn->pcm_bitsPerSample >> 3 * codecIn->pcm_numChannels;
      if (1 < sampleSize)
	c_label_stat->Caption = "Sent: " + int2str(waveIn->outBytes / sampleSize, 10, 3, ' ') + " samples / " + int2str((waveIn->outBytes / sampleSize) / codecIn->pcm_samplesPerSec, 10, 0, ' ') + " seconds.";
    }
    else {
      //
      unsigned sampleSize = codecOut->pcm_bitsPerSample >> 3 * codecOut->pcm_numChannels;
      if (1 < sampleSize)
	c_label_stat->Caption = "Received: " + int2str(waveOut->inBytes / sampleSize, 10, 3, ' ') + " samples / " + int2str((waveOut->inBytes / sampleSize) / codecOut->pcm_samplesPerSec, 10, 0, ' ') + " seconds.";
    }
    //
    a_cln_start->Enabled = !ipClient->active;
    a_cln_stop->Enabled = !a_cln_start->Enabled;
    c_rb_speak->Enabled = a_cln_start->Enabled;
    c_rb_listen->Enabled = c_rb_speak->Enabled;
    //
    if (c_checkBox_random->Checked) {
      //
      if (25 == random(30)) {
	//
	if (a_cln_start->Enabled)
	  a_cln_start->Execute();
	else
	  a_cln_stop->Execute();
      }
    }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::a_cln_startExecute(TObject *Sender) {
  //
  a_cln_start->Enabled = false;
  //
  ipClient->host = c_edit_host->Text;
  //
  if (c_rb_speak->Checked) {
    // speak
    ipClient->port = c_edit_speakPort->Text;
    ipClient->consumer = NULL;	// no need to playback
    //
    if (!waveIn->open()) {
      waveIn->close(0);
      //
      ShowMessage("Unable to open waveIn device, error text: \r\n" + waveIn->waveErrorAsString);
    }
  }
  else {
    // listen
    ipClient->port = c_edit_listenPort->Text;
    ipClient->consumer = codecOut;	// restore playback chain
    ipClient->open();
  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::a_cln_stopExecute(TObject *Sender) {
  a_cln_stop->Enabled = false;
  // stop everything
  waveIn->close(0);
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::ipClientClientDisconnect(TObject *sender, DWORD connectionId, LongBool connected) {
  // stop everything
  waveIn->close(0);
}
//---------------------------------------------------------------------------




