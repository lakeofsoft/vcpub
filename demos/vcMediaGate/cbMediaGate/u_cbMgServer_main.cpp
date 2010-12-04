//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "u_cbMgServer_main.h"
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
  c_edit_speakPort->Text = "17860";
  c_edit_listenPort->Text = "17861";

}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormCloseQuery(TObject *Sender,
      bool &CanClose)
{
  c_timer_update->Enabled = false;
  //
  speakServer->close(0);
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::FormShow(TObject *Sender)
{
  c_clb_debug->Visible =
#ifdef _DEBUG
    true
#else
    false
#endif
    ;
  //
  c_timer_update->Enabled = true;
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::c_timer_updateTimer(TObject *Sender)
{
#ifdef _DEBUG
    c_clb_debug->Checked[0] = speakServer->active;
    //c_clb_debug.checked[1] = speakCodec.active;
    //c_clb_debug.checked[2] = listenCodec.active;
    c_clb_debug->Checked[3] = listenServer->active;
#endif
    //
    c_statusBar_main->Panels->Items[0]->Text = "Mem: " + int2str(GetHeapStatus().TotalAllocated >> 10, 10, 3, ' ') + " KB";
    //
    if (speakServer->remoteFormat) {
      //
      //unsigned sampleSize = (speakServer->remoteFormat->r_format.formatOriginal.pcmBitsPerSample >> 3) * speakServer->remoteFormat->r_format.formatOriginal.pcmNumChannels;
      //if (0 < sampleSize)
      c_label_received->Caption = "Received  : " + int2str(speakServer->inPacketsCount, 10, 3, ' ') + " packets.";
    }
    else
      c_label_received->Caption = "Waiting for data stream..";
    //
    c_label_listeners->Caption  = "Listeners : " + int2str(listenServer->clientCount, 10, 0, ' ') + "/" + int2str(listenServer->maxClients, 10, 0, ' ');
    //
    //if (0 < sampleSize) then
      c_label_served->Caption   = "Served    : " + int2str(listenServer->inBytes, 10, 3, ' ') + " bytes.";
    //
    a_srv_start->Enabled = !speakServer->active;
    a_srv_stop->Enabled = !a_srv_start->Enabled;
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::a_srv_startExecute(TObject *Sender)
{
  a_srv_start->Enabled = false;
  //
  speakServer->port = c_edit_speakPort->Text;
  listenServer->port = c_edit_listenPort->Text;
  //
  speakServer->open();
}
//---------------------------------------------------------------------------

void __fastcall Tc_form_main::a_srv_stopExecute(TObject *Sender)
{
  a_srv_stop->Enabled = false;
  //
  speakServer->close(0);
}
//---------------------------------------------------------------------------

