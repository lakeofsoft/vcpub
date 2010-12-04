//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
#include "..\..\common\U_common_audioconfig.hpp"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "unavcIDE"
#pragma link "unaVcIDE"
#pragma resource "*.dfm"
Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
__fastcall Tc_form_main::Tc_form_main(TComponent* Owner): TForm(Owner) {
}
//---------------------------------------------------------------------------

// --  --
void __fastcall Tc_form_main::FormCreate(TObject *Sender) {
  //
  WAVEFORMATEX pcmFormat;

  f_ini = new unaIniFile("", "", 1000, true);

  // server
  f_ini->setSection("server");
  c_comboBox_socketTypeServer->ItemIndex = f_ini->get_uint("socketTypeIndex", (unsigned)0);
  c_edit_serverPort->Text = f_ini->get_string("port", (AnsiString)"17810");
  c_checkBox_mixWaveServer->Checked = f_ini->get_bool("mixWave", false);
  c_edit_waveNameServer->Text = f_ini->get_string("waveName", (AnsiString)"");
  c_checkBox_useWaveInServer->Checked = f_ini->get_bool("useWaveIn", true);
  c_checkBox_autoStartServer->Checked = f_ini->get_bool("autoStart", true);
  //
  // client
  f_ini->setSection("client");
  c_comboBox_socketTypeClient->ItemIndex = f_ini->get_uint("socketTypeIndex", (unsigned)0);
  c_edit_clientSrvHost->Text = f_ini->get_string("serverHost", (AnsiString)"192.168.1.1");
  c_edit_clientSrvPort->Text = f_ini->get_string("serverPort", (AnsiString)"17810");
  c_checkBox_mixWaveClient->Checked = f_ini->get_bool("mixWave", false);
  c_edit_waveNameClient->Text = f_ini->get_string("waveName", (AnsiString)"");
  c_checkBox_useWaveInClient->Checked = f_ini->get_bool("useWaveIn", true);
  //
  c_comboBox_socketTypeServerChange(this);
  c_comboBox_socketTypeClientChange(this);
}

//  --  --
void __fastcall Tc_form_main::FormClose(TObject *Sender, TCloseAction &Action) {
  clientAction(false);
  serverAction(false);

  // server
  f_ini->setSection("server");
  f_ini->setValue("socketTypeIndex", c_comboBox_socketTypeServer->ItemIndex);
  f_ini->setValue("port", c_edit_serverPort->Text);
  f_ini->setValue("mixWave", c_checkBox_mixWaveServer->Checked);
  f_ini->setValue("waveName", c_edit_waveNameServer->Text);
  f_ini->setValue("useWaveIn", c_checkBox_useWaveInServer->Checked);
  f_ini->setValue("autoStart", c_checkBox_autoStartServer->Checked);
  //
  // client
  f_ini->setSection("client");
  f_ini->setValue("socketTypeIndex", c_comboBox_socketTypeClient->ItemIndex);
  f_ini->setValue("serverHost", c_edit_clientSrvHost->Text);
  f_ini->setValue("serverPort", c_edit_clientSrvPort->Text);
  f_ini->setValue("mixWave", c_checkBox_mixWaveClient->Checked);
  f_ini->setValue("waveName", c_edit_waveNameClient->Text);
  f_ini->setValue("useWaveIn", c_checkBox_useWaveInClient->Checked);
}

// --  --
void __fastcall Tc_form_main::FormShow(TObject *Sender) {
  //
  c_form_common_audioConfig->setupUI(true, true, false);
  // server
  c_form_common_audioConfig->doLoadConfig(waveIn_server, waveOut_server, codecIn_server, NULL, f_ini, "wave.format.server");
  updateFormat();
  // client
  c_form_common_audioConfig->doLoadConfig(waveIn_client, waveOut_client, codecIn_client, NULL, f_ini, "wave.format.client");
  updateFormat(false);
  //
  if (c_checkBox_autoStartServer->Checked)
    serverAction(true);
  //
  c_timer_update->Enabled = true;
}

// --  --
void __fastcall Tc_form_main::FormCloseQuery(TObject *Sender, bool &CanClose) {
  c_timer_update->Enabled = false;
}

// --  --
AnsiString getIpStatus(unavclInOutIpPipe *ip, TunavclWaveInDevice *rec, TunavclWaveRiff *wave, TunavclWaveOutDevice *play) {
  //
  if (0 != ip->getErrorCode())
    return("Error code: " + IntToStr(ip->getErrorCode()));
  else
    if (!ip->active)
      return("Not active");
    else
      return("Packets: in " + IntToStr(ip->inPacketsCount) + ", out " + IntToStr(ip->outPacketsCount) +
	     " / Rec: " + IntToStr(rec->device->outBytes >> 10) + " KB" +
	     " / WAVe: " + IntToStr(wave->device->outBytes >> 10) + " KB" +
	     " / Play: " + IntToStr(play->device->inBytes >> 10) + " KB");
}

// --  --
void __fastcall Tc_form_main::deviceInfo(bool isServer, unsigned index, unavclInOutPipe *device) {
  //
  TCheckListBox *lb;
  TStaticText *st;
  //
  if (isServer) {
    lb = c_checkListBox_server;
    st = c_staticText_deviceInfoServer;
  }
  else {
    lb = c_checkListBox_client;
    st = c_staticText_deviceInfoClient;
  }
  //
  lb->Checked[index] = device->active;
  //
  if ((int)index == lb->ItemIndex)
    if (dynamic_cast<unavclInOutWavePipe*>(device))
      st->Caption = "Src: " + dynamic_cast<unavclInOutWavePipe*>(device)->device->srcFormatInfo + "\r\n" +
		    "Dst: " + dynamic_cast<unavclInOutWavePipe*>(device)->device->dstFormatInfo;
    else
      if (dynamic_cast<unavclInOutIpPipe*>(device))
	st->Caption = "Sent: " + IntToStr(device->inBytes >> 10) + " KB\r\n" +
		      "Received: " + IntToStr(device->outBytes >> 10) + " KB";
}

// --  --
void __fastcall Tc_form_main::c_timer_updateTimer(TObject *Sender) {
  //
  if (!ComponentState.Contains(csDestroying)) {
    c_statusBar_main->Panels->Items[0]->Text = "Mem. usage: " + IntToStr(GetHeapStatus().TotalAllocated	>> 10) + " KB";
    // server
    c_label_statusSrv->Caption = getIpStatus(ipServer, waveIn_server, riff_server, waveOut_server);
    c_label_statusClient->Caption = getIpStatus(ipClient, waveIn_client, riff_client, waveOut_client);
    //
    c_pb_volumeInClient->Position = waveGetLogVolume(mixer_client->mixer->getVolume(0));
    c_pb_volumeInServer->Position = waveGetLogVolume(mixer_server->mixer->getVolume(0));
    c_pb_volumeOutClient->Position = waveGetLogVolume(waveOut_client->waveOutDevice->getVolume(0));
    c_pb_volumeOutServer->Position = waveGetLogVolume(waveOut_server->waveOutDevice->getVolume(0));
    //
    deviceInfo(true, 0, waveIn_server);
    deviceInfo(true, 1, riff_server);
    deviceInfo(true, 2, resampler_server);
    deviceInfo(true, 3, mixer_server);
    deviceInfo(true, 4, codecIn_server);
    deviceInfo(true, 5, ipServer);
    deviceInfo(true, 6, codecOut_server);
    deviceInfo(true, 7, waveOut_server);

    //
    deviceInfo(false, 0, waveIn_client);
    deviceInfo(false, 1, riff_client);
    deviceInfo(false, 2, resampler_client);
    deviceInfo(false, 3, mixer_client);
    deviceInfo(false, 4, codecIn_client);
    deviceInfo(false, 5, ipClient);
    deviceInfo(false, 6, codecOut_client);
    deviceInfo(false, 7, waveOut_client);
    //
    reEnable(false);
    reEnable(true);
  }
}

// --  --
void __fastcall Tc_form_main::reEnable(bool server) {
  //
  if (!ComponentState.Contains(csDestroying)) {
    //
    if (server) {
      bool isActive = ipServer->active;
      //
      a_srvStart->Enabled = !isActive;
      a_srvStop->Enabled = isActive;
      c_button_formatChooseServer->Enabled = !isActive;
    }
    else {
      bool isActive = ipClient->active;
      //
      a_clientStart->Enabled = !isActive;
      a_clientStop->Enabled = isActive;
      c_button_formatChooseClient->Enabled = !isActive;
    }
  }
}

// --  --
void __fastcall Tc_form_main::clientAction(bool doOpen) {
  //
  if (doOpen) {
    ipClient->port = c_edit_clientSrvPort->Text;
    ipClient->host = c_edit_clientSrvHost->Text;
    //
    riff_client->fileName = c_edit_waveNameClient->Text;
  }
  //
  waveIn_client->active = doOpen && c_checkBox_useWaveInClient->Checked;
  riff_client->active = doOpen && c_checkBox_mixWaveClient->Checked;
  //
  mixer_client->active = doOpen;
  ipClient->active = doOpen;
}

// --  --
void __fastcall Tc_form_main::serverAction(bool doOpen) {
  //
  if (doOpen) {
    ipServer->port = c_edit_serverPort->Text;
    //
    riff_server->fileName = c_edit_waveNameServer->Text;
  }
  //
  waveIn_server->active = doOpen && c_checkBox_useWaveInServer->Checked;
  riff_server->active = doOpen && c_checkBox_mixWaveServer->Checked;
  //
  mixer_server->active = doOpen;
  ipServer->active = doOpen;
}

// --  --
void __fastcall Tc_form_main::a_clientStartExecute(TObject *Sender) {
  //
  clientAction(true);
}

// --  --
void __fastcall Tc_form_main::a_clientStopExecute(TObject *Sender) {
  //
  clientAction(false);
}

// --  --
void __fastcall Tc_form_main::a_srvStartExecute(TObject *Sender) {
  //
  serverAction(true);
}

// --  --
void __fastcall Tc_form_main::a_srvStopExecute(TObject *Sender) {
  //
  serverAction(false);
}

//  --  --
void __fastcall Tc_form_main::c_button_chooseWaveServerClick(TObject *Sender) {
  chooseFile(c_checkBox_mixWaveServer, c_edit_waveNameServer);
}

//  -- --
void __fastcall Tc_form_main::c_button_chooseWaveClientClick(TObject *Sender) {
  chooseFile(c_checkBox_mixWaveClient, c_edit_waveNameClient);
}

// --  --
void __fastcall Tc_form_main::chooseFile(TCheckBox *cb, TEdit *edit) {
  //
  if (c_openDialog_wave->Execute()) {
    cb->Checked = true;
    edit->Text = c_openDialog_wave->FileName;
  }
}

//  --  --
void __fastcall Tc_form_main::c_button_formatChooseClientClick(TObject *Sender) {
  if (S_OK == c_form_common_audioConfig->doConfig(waveIn_client, waveOut_client, codecIn_client, NULL, f_ini, "wave.format.client"))
    updateFormat(false);
}

//  --  --
void __fastcall Tc_form_main::c_button_formatChooseServerClick(TObject *Sender) {
  //
  if (S_OK == c_form_common_audioConfig->doConfig(waveIn_server, waveOut_server, codecIn_server, NULL, f_ini, "wave.format.server"))
    updateFormat(true);
}

// --  --
void __fastcall Tc_form_main::updateFormatInfo(bool isServer) {
  //
  if (isServer)
    c_static_formatInfoServer->Caption = codecIn_server->device->dstFormatInfo;
  else
    c_static_formatInfoClient->Caption = codecIn_client->device->dstFormatInfo;
}

// --  --
void __fastcall Tc_form_main::updateFormat(bool isServer) {
  //
  if (isServer) {
    mixer_server->pcmFormat = codecIn_server->pcmFormat;
    waveIn_server->pcmFormat = codecIn_server->pcmFormat;
    resampler_server->dstFormat = codecIn_server->pcmFormat;
  }
  else {
    mixer_client->pcmFormat = codecIn_client->pcmFormat;
    waveIn_client->pcmFormat = codecIn_client->pcmFormat;
    resampler_client->dstFormat = codecIn_client->pcmFormat;
  };
  //
  updateFormatInfo(isServer);
}

// --  --
void __fastcall Tc_form_main::c_comboBox_socketTypeClientChange(TObject *Sender) {
  //
  if (0 == c_comboBox_socketTypeClient->ItemIndex)
    ipClient->proto = unapt_UDP;
  else
    ipClient->proto = unapt_TCP;
}

// --  --
void __fastcall Tc_form_main::c_comboBox_socketTypeServerChange(TObject *Sender) {
  //
  if (0 == c_comboBox_socketTypeServer->ItemIndex)
    ipServer->proto = unapt_UDP;
  else
    ipServer->proto = unapt_TCP;
}


void __fastcall Tc_form_main::ipClientClientDisconnect(TObject *sender, DWORD connectionId, LongBool connected) {
  clientAction(false);
}
//---------------------------------------------------------------------------

