//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "u_cbvcVoiceChat_main.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "unaVcIDE"
#pragma resource "*.dfm"
Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
__fastcall Tc_form_main::Tc_form_main(TComponent* Owner): TForm(Owner) {
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::FormDestroy(TObject *Sender) {
  f_config->setValue("ip.client.remoteServer", f_host);
  //
  //saveControlPosition(self, f_config);
  delete f_config;
  delete f_delayedStrings;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::loadConfig() {
  //loadControlPosition(self, f_config);
  //
  f_host = f_config->get_string("ip.client.remoteServer", "192.168.1.1");
  f_needEnableClientMemo = false;
  //
  waveIn->pcm_samplesPerSec = f_config->get_uint("wave.samplesPerSec", unsigned(22050));
  switch (waveIn->pcm_samplesPerSec) {

    case 8000: {
      mi_editAudio_1->Checked = true;
      break;
    }

    case 11025: {
      mi_editAudio_2->Checked = true;
      break;
    }

    default: {
      mi_editAudio_3->Checked = true;
      break;
    }
  }
  //
  mi_esd->Checked = f_config->get_bool("wave.silenceDetectionEnabled", true);
  silenceDetectionChanged();
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::FormCreate(TObject *Sender) {
  //
  f_config = new unaIniFile("", "settings", 1000, true);
  f_delayedStrings = new TStringList();
  //
  loadConfig();
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::c_file_exitExecute(TObject *Sender) {
  Close();
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::c_timer_updateTimer(TObject *Sender) {
  //
  if (!ComponentState.Contains(csDestroying)) {
    //
    c_statusBar_main->Panels->Items[0]->Text = int2str(GetHeapStatus().TotalAllocated >> 10, 10, 3, ' ') + " KB";
    //
    a_chat_beServer->Enabled = !ipServer->active;
    a_chat_beClient->Enabled = !ipClient->active;
    //
    if (!a_chat_beServer->Enabled && a_chat_beClient->Enabled) {
      c_statusBar_main->Panels->Items[1]->Text = "Mode: Server";
      a_chat_stop->Enabled = true;
      mi_edit_audio->Enabled = false;
    }
    else
      if (a_chat_beServer->Enabled && !a_chat_beClient->Enabled) {
	c_statusBar_main->Panels->Items[1]->Text = "Mode: Client";
	a_chat_stop->Enabled = true;
	mi_edit_audio->Enabled = false;
      }
      else {
	c_statusBar_main->Panels->Items[1]->Text = "Mode: none";
	a_chat_stop->Enabled = false;
	mi_edit_audio->Enabled = true;
      }
    //
    if (f_needEnableClientMemo) {
      //
      c_memo_client->Enabled = true;
      if (c_memo_client->CanFocus())
	c_memo_client->SetFocus();
      //
      f_needEnableClientMemo = false;
    }
    //
    int i = 0;
    while (i < f_delayedStrings->Count) {
      c_memo_remote->Lines->Add(f_delayedStrings->Strings[i]);
      //
      i++;
    }
    f_delayedStrings->Clear();
    //
  }
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::a_chat_beServerExecute(TObject *Sender) {
  serverAction(true);
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::a_chat_beClientExecute(TObject *Sender) {
  clientAction(true);
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::serverAction(bool doStart) {
  //
  if (doStart) {
    clientAction(false);
    //
    codecIn->consumer = ipServer;
    ipServer->consumer = codecOut;
    //
    waveIn->open();
  }
  else {
    c_memo_client->Enabled = false;
    waveIn->close(0);
    //
    c_memo_remote->Clear();
  }
  //
  a_chat_beServer->Enabled = !ipServer->active;
  a_chat_stop->Enabled = !a_chat_beServer->Enabled;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::clientAction(bool doStart)
{
  if (doStart) {
    //
    if (InputQuery("Enter Server address", "Server IP address or DNS name", f_host)) {
      //
      serverAction(false);
      //
      ipClient->host = f_host;
      //
      codecIn->consumer = ipClient;
      ipClient->consumer = codecOut;
      //
      waveIn->open();
    }
  }
  else {
    c_memo_client->Enabled = false;
    waveIn->close(0);
    //
    c_memo_remote->Clear();
  }
  //
  a_chat_beClient->Enabled = !ipClient->active;
  a_chat_stop->Enabled = !a_chat_beClient->Enabled;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::a_chat_stopExecute(TObject *Sender) {
  serverAction(false);
  clientAction(false);
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::ipServerServerNewClient(TObject *sender, DWORD connectionId, LongBool connected) {
  // should not access VCL here
  f_needEnableClientMemo = true;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::ipClientClientConnect(TObject *sender, DWORD connectionId, LongBool connected) {
  // should not access VCL here
  f_needEnableClientMemo = true;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::c_memo_clientKeyPress(TObject *Sender, char &Key) {
  //
  switch (Key) {

    case '\r': {
      //
      if (ipServer->active) {
	ipServer->sendText(ipServer->getClientConnId(0), c_memo_client->Text);
	c_memo_remote->Lines->Add("server > " + c_memo_client->Text);
      }
      else
	if (ipClient->active) {
	  ipClient->sendText(ipClient->clientConnId, c_memo_client->Text);
	  c_memo_remote->Lines->Add("client > " + c_memo_client->Text);
	}
      //
      c_memo_client->Clear();
      Key = 0;
    }
  }
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::ipClientTextData(TObject *sender, DWORD connectionId, const AnsiString data) {
  // should not access VCL here
  f_delayedStrings->Add("server > " + data);
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::ipServerTextData(TObject *sender, DWORD connectionId, const AnsiString data)
{
  // should not access VCL here
  f_delayedStrings->Add("client > " + data);
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::mi_edit_clearRemoteClick(TObject *Sender)
{
  c_memo_remote->Clear();
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::mi_editAudio_click(TObject *Sender)
{
  waveIn->pcm_samplesPerSec = dynamic_cast<TMenuItem*>(Sender)->Tag;
  dynamic_cast<TMenuItem*>(Sender)->Checked = true;
  //
  f_config->setValue("wave.samplesPerSec", waveIn->pcm_samplesPerSec);
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::mi_esdClick(TObject *Sender) {
  mi_esd->Checked = !mi_esd->Checked;
  f_config->setValue("wave.silenceDetectionEnabled", mi_esd->Checked);
  //
  silenceDetectionChanged();
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::silenceDetectionChanged() {
  waveIn->calcVolume = mi_esd->Checked;
}

