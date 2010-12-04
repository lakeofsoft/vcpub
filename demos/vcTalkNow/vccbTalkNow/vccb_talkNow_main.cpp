//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "vccb_talkNow_main.h"
#include "..\..\common\U_common_audioconfig.hpp"
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
void __fastcall Tc_form_main::FormCreate(TObject *Sender)
{
  f_samplesMax = c_paintBox_network->ClientWidth;
  //
  f_config = new unaIniFile("", "config", 1000, true);
  //loadControlPosition(self, f_config);
  //
  c_label_clientStat->Color = clBlack;
  c_label_clientStat->Font->Color = clWhite;
  c_label_serverStat->Color = clBlack;
  c_label_serverStat->Font->Color = clWhite;
  //
  //with (f_config) do begin
    c_comboBox_socketTypeServer->ItemIndex = f_config->get_int("server.socket.type", 0);
    c_comboBox_socketTypeClient->ItemIndex = f_config->get_int("client.socket.type", 0);
    //
    c_edit_serverPort->Text = f_config->get_string("server.socket.port", "17820");
    c_edit_serverPortClient->Text = f_config->get_string("client.socket.port", "17820");
    c_edit_serverIPclient->Text = f_config->get_string("client.socket.ip", "192.168.1.1");
    adjustNumClients(f_config->get_int("server.maxClients", 10));
    switch (ipServer->maxClients) {

       case  1: mi_options_maxClients_1->Checked = true;
		break;

       case  2: mi_options_maxClients_2->Checked = true;
		break;

       case 10: mi_options_maxClients_10->Checked = true;
		break;

      default:
		mi_options_maxClients_unlimited->Checked = true;
		break;
    }
    //
    mi_options_autoActivateSrv->Checked = f_config->get_bool("server.config.autoStart", true);
    mi_options_LLN->Checked = f_config->get_bool("network.longLatency", false);
    //
    c_comboBox_socketTypeServerChange(Sender);
    c_comboBox_socketTypeClientChange(Sender);
  //end;
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormDestroy(TObject *Sender)
{
  freeAndNil(&f_config);
	
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormResize(TObject *Sender)
{
  f_samplesMax = c_paintBox_network->ClientWidth;
	
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormClose(TObject *Sender,
      TCloseAction &Action)
{
  c_timer_update->Enabled = false;
  //
  client_stop->Execute();
  server_stop->Execute();
  //
  //saveControlPosition(self, f_config);
  //with (f_config) do begin
    f_config->setValue("server.socket.type", c_comboBox_socketTypeServer->ItemIndex);
    f_config->setValue("client.socket.type", c_comboBox_socketTypeClient->ItemIndex);
    f_config->setValue("server.socket.port", c_edit_serverPort->Text);
    f_config->setValue("server.maxClients", ipServer->maxClients);
    //
    f_config->setValue("client.socket.port", c_edit_serverPortClient->Text);
    f_config->setValue("client.socket.ip", c_edit_serverIPclient->Text);
    f_config->setValue("server.config.autoStart", mi_options_autoActivateSrv->Checked);
    f_config->setValue("network.longLatency", mi_options_LLN->Checked);
  //end;
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormShow(TObject *Sender)
{
  c_form_common_audioConfig->setupUI(true, true, false);
  c_form_common_audioConfig->doLoadConfig(waveIn_server, waveOut_server, codecIn_server, NULL, f_config, "waveConfig.server");
  c_form_common_audioConfig->doLoadConfig(waveIn_client, waveOut_client, codecIn_client, NULL, f_config, "waveConfig.client");
  //
  adjustReceiveBuffers(mi_options_LLN->Checked);
  //
  if (mi_options_autoActivateSrv->Checked)
    server_start->Execute();

}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::server_startExecute(TObject *Sender)
{
  server_start->Enabled = false;
  //
  ipServer->port = c_edit_serverPort->Text;
  // activate server
  waveIn_server->open();
  //
  if (!waveIn_server->active) {
    //
    waveIn_server->close(0);
    ShowMessage("Unable to open waveIn device, error text: \r\n" + waveIn_server->waveErrorAsString);
  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::server_stopExecute(TObject *Sender)
{
  server_stop->Enabled = false;
  // stop server
  waveIn_server->close(0);
	
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::client_startExecute(TObject *Sender)
{
  client_start->Enabled = false;
  //
  ipClient->port = c_edit_serverPortClient->Text;
  ipClient->host = c_edit_serverIPclient->Text;
  // activate wave components
  waveIn_client->open();
  //
  if (!waveIn_client->active) {
    //
    waveIn_client->close(0);
    ShowMessage("Unable to open waveIn device, error text: \r\n" + waveIn_client->waveErrorAsString);
  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::client_stopExecute(TObject *Sender)
{
  client_stop->Enabled = false;
  // stop client
  waveIn_client->close(0);
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_timer_updateTimer(TObject *Sender)
{
  if (!ComponentState.Contains(csDestroying)) {
    updateStatus();
    //
    f_samplesPos++;
    if (f_samplesPos > f_samplesMax)
      f_samplesPos = 0;//low(f_clientSamples);
    //
    f_clientSamples[f_samplesPos] =  f_clientSamplesReceived;
    f_serverSamples[f_samplesPos] =  f_serverSamplesReceived;
    //
    f_clientSamplesReceived = 0;
    f_serverSamplesReceived = 0;
    //
    if (0 == (f_samplesPos & 0xF))
      c_paintBox_network->Invalidate();
    //
    c_pb_clientIn->Position = waveGetLogVolume(waveIn_client->device->getVolume(0));
    c_pb_clientOut->Position = waveGetLogVolume(waveOut_client->device->getVolume(0));
    //
    c_pb_serverIn->Position = waveGetLogVolume(waveIn_server->device->getVolume(0));
    c_pb_serverOut->Position = waveGetLogVolume(waveOut_server->device->getVolume(0));
  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_comboBox_socketTypeServerChange(
      TObject *Sender)
{
  if (0 == c_comboBox_socketTypeServer->ItemIndex)
    ipServer->proto = unapt_UDP;
  else
    ipServer->proto = unapt_TCP;

}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_comboBox_socketTypeClientChange(
      TObject *Sender)
{
  if (0 == c_comboBox_socketTypeClient->ItemIndex)
    ipClient->proto = unapt_UDP;
  else
    ipClient->proto = unapt_TCP;

}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_paintBox_networkPaint(TObject *Sender)
{
  double stepV;
  double offsetV;
  double pos;
  TRect rect;
  int maxValue;

//  with tControlCanvas(c_paintBox_network->Canvas) do begin
    //
    c_paintBox_network->Canvas->Brush->Color = clBlack;
    rect.Left = 0;
    rect.Right = c_paintBox_network->Width;
    rect.Top = 0;
    rect.Bottom = c_paintBox_network->Height;
    //
    c_paintBox_network->Canvas->FillRect(rect);
    //
    maxValue = 1;
    for (int i = 0; i <= f_samplesMax; i++) {
      //
      if (maxValue < f_clientSamples[i])
	maxValue = f_clientSamples[i];
    }
    //
    for (int i = 0; i <= f_samplesMax; i++) {
      //
      if (maxValue < f_serverSamples[i])
	maxValue = f_serverSamples[i];
    }
    //
    stepV = c_paintBox_network->Height / (maxValue * 1.1);
    //
    offsetV = c_paintBox_network->Height * 0.98;
    //
    c_paintBox_network->Canvas->Pen->Color = clBlue;
    c_paintBox_network->Canvas->MoveTo(f_samplesPos, 0);
    c_paintBox_network->Canvas->LineTo(f_samplesPos, c_paintBox_network->Height);
    //
    pos = 1;
    c_paintBox_network->Canvas->Pen->Color = clRed;
    for (int i = 1; i <= f_samplesMax; i++) {
      //
      c_paintBox_network->Canvas->MoveTo(pos - 1, offsetV - f_clientSamples[i - 1] * stepV);
      c_paintBox_network->Canvas->LineTo(pos    , offsetV - f_clientSamples[i + 0] * stepV);
      //
      pos = pos + 1;
    }
    //
    pos = 1;
    c_paintBox_network->Canvas->Pen->Color = clGreen;
    for (int i = 1; i <= f_samplesMax; i++) {
      //
      c_paintBox_network->Canvas->MoveTo(pos - 1, offsetV - f_serverSamples[i - 1] * stepV);
      c_paintBox_network->Canvas->LineTo(pos    , offsetV - f_serverSamples[i + 0] * stepV);
      //
      pos = pos + 1;
    }

//  end;
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_button_configAudioSrvClick(TObject *Sender)
{
  c_form_common_audioConfig->doConfig(waveIn_server, waveOut_server, codecIn_server, NULL, f_config, "waveConfig.server");

}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_button_configAudioClnClick(TObject *Sender)
{
  c_form_common_audioConfig->doConfig(waveIn_client, waveOut_client, codecIn_client, NULL, f_config, "waveConfig.client");
	
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::ipServerPacketEvent(TObject *sender,
      DWORD connectionId, const unavclInOutIPPacket &packet)
{
  switch (packet.r_command) {
    //
    case cmd_inOutIPPacket_audio:
      f_serverSamplesReceived += packet.r_dataSize;
      break;

  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::ipServerSocketEvent(TObject *sender,
      DWORD connectionId, unaSocketEvent event, Pointer data, DWORD len)
{
  switch (event) {

    case unaseThreadStartupError:
      ShowMessage("Server cannot startup.\r\nCheck if server port is not used by other applications.");
      waveIn_server->close(0);
      break;

  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::ipClientClientDisconnect(TObject *sender,
      DWORD connectionId, LongBool connected)
{
  // since client may be disconnected explicitly, we need to care about closing other devices
  waveIn_client->close(0);

}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::ipClientPacketEvent(TObject *sender,
      DWORD connectionId, const unavclInOutIPPacket &packet)
{
  switch (packet.r_command) {
    //
    case cmd_inOutIPPacket_audio:
      f_clientSamplesReceived += packet.r_dataSize;
      break;

    case cmd_inOutIPPacket_outOfSeats:
      // server is out of seats for us :(
      ShowMessage("Server is out of seats.");
      break;

  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::ipClientSocketEvent(TObject *sender,
      DWORD connectionId, unaSocketEvent event, Pointer data, DWORD len)
{
  switch (event) {

    case unaseThreadStartupError:
      ShowMessage("Client cannot connect.\r\nCheck if server is up and running and both server address and port are correct.");
      waveIn_client->close(0);
      break;

  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::mi_help_aboutClick(TObject *Sender)
{
  //c_form_about->showAbout();
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::mi_options_autoActivateSrvClick(
      TObject *Sender)
{
  mi_options_autoActivateSrv->Checked = !mi_options_autoActivateSrv->Checked;
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::mi_options_LLNClick(TObject *Sender)
{
  mi_options_LLN->Checked = !mi_options_LLN->Checked;
  //
  adjustReceiveBuffers(mi_options_LLN->Checked);
	
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::mi_file_exitClick(TObject *Sender)
{
  Close();
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::numClientsClick(TObject *Sender)
{
  //if (sender is tMenuItem) then begin
    adjustNumClients(dynamic_cast<TMenuItem*>(Sender)->Tag);
    //
    dynamic_cast<TMenuItem*>(Sender)->Checked = true;
  //end;
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::updateStatus() {
  //
  if (!ComponentState.Contains(csDestroying)) {
    //
    bool serverIsOn = ipServer->active;
    server_start->Enabled = !serverIsOn;
    server_stop->Enabled = serverIsOn;
    c_comboBox_socketTypeServer->Enabled = !serverIsOn;
    c_edit_serverPort->Enabled = !serverIsOn;
    c_button_configAudioSrv->Enabled = !serverIsOn;
    //
    bool clientIsOn = ipClient->active;
    client_start->Enabled = !clientIsOn;
    client_stop->Enabled = clientIsOn;
    c_comboBox_socketTypeClient->Enabled = !clientIsOn;
    c_edit_serverPortClient->Enabled = !clientIsOn;
    c_edit_serverIPclient->Enabled = !clientIsOn;
    c_button_configAudioCln->Enabled = !clientIsOn;
    //
    mi_options_LLN->Enabled = !serverIsOn && !clientIsOn;
    mi_options_maxClients->Enabled = !serverIsOn;
    //
    c_label_serverStat->Caption = " Server   [in/out: " + int2str(ipServer->outBytes >> 10, 10, 3, ' ') + "/" + int2str(ipServer->inBytes >> 10, 10, 3, ' ') + " KB]   [Num. of Clients: " + int2str(ipServer->clientCount, 10, 0, ' ') + "/" + int2str(ipServer->maxClients, 10, 0, ' ') + "]";
    c_label_clientStat->Caption = " Client   [in/out: " + int2str(ipClient->outBytes >> 10, 10, 3, ' ') + "/" + int2str(ipClient->inBytes >> 10, 10, 3, ' ') + " KB]   [Lost: " + int2str(ipClient->inPacketsOutOfSeq, 10, 0, ' ') + " packets]";
    //
    c_statusBar_main->Panels->Items[0]->Text = "Mem: " + int2str(GetHeapStatus().TotalAllocated >> 10, 10, 3, ' ') + " KB";
    //
#ifdef _DEBUG
    c_clb_server->Visible = true;
    c_clb_client->Visible = true;
    //
    c_clb_server->Checked[0] = waveIn_server->active;
    c_clb_server->Checked[1] = codecIn_server->active;
    c_clb_server->Checked[2] = ipServer->active;
    c_clb_server->Checked[3] = codecOut_server->active;
    c_clb_server->Checked[4] = waveOut_server->active;
    //
    c_clb_client->Checked[0] = waveIn_client->active;
    c_clb_client->Checked[1] = codecIn_client->active;
    c_clb_client->Checked[2] = ipClient->active;
    c_clb_client->Checked[3] = codecOut_client->active;
    c_clb_client->Checked[4] = waveOut_client->active;
#else
    c_clb_server->Visible = false;
    c_clb_client->Visible = false;
#endif
  }
}
//---------------------------------------------------------------------------
    //procedure wmEraseBkgnd(var message: tMessage); message WM_ERASEBKGND;
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::adjustReceiveBuffers(bool enabled) {
  //
  if (enabled) {
    //
    unsigned size = enabled ? 40 : 5;
    //
    // adjust size of receive buffers
    codecOut_server->overNum = size;
    waveOut_server->overNum = size;
    codecIn_server->overNum = size;
    waveIn_server->overNum = size;
  }
}
//---------------------------------------------------------------------------
void __fastcall Tc_form_main::adjustNumClients(int maxNum) {
  //
  // make sure server is stopped
  server_stop->Execute();
  //
  if (1 != maxNum)
    ipServer->consumer = NULL;	// no sence to feed output with more than one client
  else
    ipServer->consumer = codecOut_server;	// feed output with one client
  //
  ipServer->maxClients = maxNum;
}
//---------------------------------------------------------------------------

