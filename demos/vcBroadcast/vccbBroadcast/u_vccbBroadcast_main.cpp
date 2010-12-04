//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "u_vccbBroadcast_main.h"
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
  f_ini = new unaIniFile("", "", 1000, true);
  f_ini->setSection("GUI.Server");
  //
//{$IFDEF __BEFORE_D6__ }
  c_label_serverStat->Color = clGray;
  c_label_clientStat->Color = clGray;
//{$ELSE }
  //c_label_serverStat->Color = clMedGray;
  //c_label_clientStat->Color = clMedGray;
//{$ENDIF}
  //
  c_checkBox_serverAutoStart->Checked = f_ini->get_bool("autoStartServer", true);
  c_edit_serverPort->Text = f_ini->get_string("portNumber", "17830");
//{$IFDEF __AFTER_D5__}
  //c_pageControl_main->TabIndex = (f_ini->get("tabActive", true)) ? 0 : 1;
//{$ENDIF}
  //
  f_ini->setSection("GUI.Client");
  c_edit_clientPort->Text = f_ini->get_string("portNumber", "17830");
  c_edit_saveWAVname->Text = f_ini->get_string("wavOutput", "");
  c_checkBox_saveWAV->Checked = f_ini->get_bool("wavOutputChecked", false);
  //
  c_timer_mainTimer(Sender);
  c_timer_main->Enabled = true;
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormDestroy(TObject *Sender)
{
  freeAndNil(&f_ini);
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormClose(TObject *Sender,
      TCloseAction &Action)
{
  f_ini->setSection("GUI.Server");
  f_ini->set_bool("autoStartServer", c_checkBox_serverAutoStart->Checked);
  f_ini->set_string("portNumber", c_edit_serverPort->Text);
//{$IFDEF __AFTER_D5__}
  //f_ini.setValue('tabActive', (0 = c_pageControl_main->TabIndex));
//{$ENDIF}
  //
  f_ini->setSection("GUI.Client");
  f_ini->set_string("portNumber", c_edit_clientPort->Text);
  f_ini->set_string("wavOutput", c_edit_saveWAVname->Text);
  f_ini->set_bool("wavOutputChecked",   c_checkBox_saveWAV->Checked);
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormShow(TObject *Sender)
{
  //loadControlPosition(self, f_ini);
  //
  c_form_common_audioConfig->setupUI(true, true, false);
  c_form_common_audioConfig->doLoadConfig(waveIn_server, waveOut_client, codecIn_server, NULL, f_ini, "wave");
  //
  if (c_checkBox_serverAutoStart->Checked && !c_broadcastServer->active)
    a_startServer->Execute();
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormCloseQuery(TObject *Sender,
      bool &CanClose)
{
  c_timer_main->Enabled = false;
  //
  a_stopServer->Execute();
  a_stopClient->Execute();
  //
  //saveControlPosition(self, f_ini);
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::a_stopServerExecute(TObject *Sender)
{
  waveIn_server->close(0);
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::a_startClientExecute(TObject *Sender)
{
  if (c_checkBox_saveWAV->Checked) {
    wavWrite->fileName = c_edit_saveWAVname->Text;
    waveOut_client->consumer = wavWrite;
  }
  else
    waveOut_client->consumer = NULL;
  //
  c_broadcastClient->port = c_edit_clientPort->Text;
  c_broadcastClient->open();
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::a_startServerExecute(TObject *Sender)
{
  a_startServer->Enabled = false;
  c_broadcastServer->port = c_edit_serverPort->Text;
  //
  waveIn_server->open();
  //
  if (!waveIn_server->active) {
    //
    waveIn_server->close(0);
    ShowMessage("Unable to open waveIn device, error text: \r\n" + waveIn_server->waveErrorAsString);
  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::a_stopClientExecute(TObject *Sender)
{
  c_broadcastClient->close(0);
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_timer_mainTimer(TObject *Sender)
{
  bool serverActive;
  bool clientActive;
  //
  if (!ComponentState.Contains(csDestroying)) {
    //
    c_statusBar_main->SimpleText = "Mem: " + int2str(GetHeapStatus().TotalAllocated, 10, 3, ' ');
    //
    serverActive = c_broadcastServer->active;
    a_startServer->Enabled = !serverActive;
    a_stopServer->Enabled = serverActive;
    c_edit_serverPort->Enabled = !serverActive;
    c_button_ac->Enabled = !serverActive;
    //
    clientActive = c_broadcastClient->active;
    a_startClient->Enabled = !clientActive;
    a_stopClient->Enabled = clientActive;
    c_checkBox_saveWAV->Enabled = !clientActive;
    c_button_saveWAV->Enabled = !clientActive;
    c_edit_clientPort->Enabled = !clientActive;
    c_edit_saveWAVnameChange(NULL);
    //
    if (codecOut_client->active) {
      //
      //with (codecOut_client->codec->) do
	c_static_clientInfo->Caption =
	  "Codec: " + (codecOut_client->codec->driver ? (AnsiString)codecOut_client->codec->driver->getDetails()->szShortName : (AnsiString)"") + "\r\n" +
	  "Input: " + codecOut_client->codec->srcFormatInfo + " / data: " + int2str(codecOut_client->codec->getDataAvailable(true), 10, 3, ' ') + "\r\n" +
	  "Output: " + codecOut_client->codec->dstFormatInfo + "\r\n" +
	  //'waveOut: ' + waveOut_client.waveOutDevice.srcFormatInfo + #13#10 +
	  "Packets Lost: "+ int2str(c_broadcastClient->packetsLost, 10, 3, ' ') + "\r\n" +
	  "Remote host: " + ipH2str(c_broadcastClient->remoteHost) + ":" + int2str(c_broadcastClient->remotePort, 10, 3, ' ');
    }
    else
      c_static_clientInfo->Caption = "Not active.";
    //
    c_label_serverStat->Caption = "Sent: "     + int2str(c_broadcastServer->packetsSent,     10, 3, ' ') + " packets; " + int2str(c_broadcastServer->outBytes >> 10, 10, 3, ' ') + " KB";
    c_label_clientStat->Caption = "Received: " + int2str(c_broadcastClient->packetsReceived, 10, 3, ' ') + " packets; " + int2str(c_broadcastClient->outBytes >> 10, 10, 3, ' ') + " KB";
  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_label_urlClick(TObject *Sender)
{
  ShellExecute(0, "open", "http://lakeofsoft.com/vc/", NULL, NULL, SW_SHOWNORMAL);
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_button_saveWAVClick(TObject *Sender)
{
  if (c_sd_saveWAV->Execute()) {
    //
    c_edit_saveWAVname->Text = trim(c_sd_saveWAV->FileName, true, true);
    c_checkBox_saveWAV->Checked = (0 != c_edit_saveWAVname->Text.AnsiCompare(""));
  }
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_edit_saveWAVnameChange(TObject *Sender)
{
  c_checkBox_saveWAV->Enabled = c_checkBox_saveWAV->Enabled && (0 != c_edit_saveWAVname->Text.AnsiCompare(""));
  c_checkBox_saveWAV->Checked = c_checkBox_saveWAV->Checked && (0 != c_edit_saveWAVname->Text.AnsiCompare(""));
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_button_acClick(TObject *Sender)
{
  c_form_common_audioConfig->doConfig(waveIn_server, waveOut_client, codecIn_server, NULL, f_ini, "wave");
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::codecOut_clientDataAvailable(unavclInOutPipe *sender, Pointer data, DWORD len)
{
  if (wavWrite->active)
    // pass data to wave file writer
    wavWrite->write(data, len, NULL);
}
//---------------------------------------------------------------------------

