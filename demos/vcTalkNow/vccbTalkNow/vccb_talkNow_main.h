//---------------------------------------------------------------------------

#ifndef vccb_talkNow_mainH
#define vccb_talkNow_mainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "unaVcIDE.hpp"
#include <ActnList.hpp>
#include <CheckLst.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <Menus.hpp>
//---------------------------------------------------------------------------
class Tc_form_main : public TForm
{
__published:	// IDE-managed Components
    TunavclIPOutStream* ipClient;
    TunavclIPInStream* ipServer;
    TunavclWaveOutDevice* waveOut_client;
    TunavclWaveOutDevice* waveOut_server;
    TActionList* c_actionList_main;
    TAction* server_start;
    TAction* server_stop;
    TAction* client_start;
    TAction* client_stop;
    TStatusBar* c_statusBar_main;
    TunavclWaveInDevice* waveIn_client;
    TunavclWaveInDevice* waveIn_server;
    TunavclWaveCodecDevice* codecIn_client;
    TunavclWaveCodecDevice* codecOut_client;
    TunavclWaveCodecDevice* codecIn_server;
    TunavclWaveCodecDevice* codecOut_server;
    TPaintBox* c_paintBox_network;
    TPanel* c_panel_main;
    TLabel* Label4;
    TComboBox* c_comboBox_socketTypeServer;
    TLabel* Label1;
    TEdit* c_edit_serverPort;
    TProgressBar* c_pb_serverIn;
    TButton* c_button_serverStop;
    TButton* c_button_serverStart;
    TLabel* c_label_serverStat;
    TBevel* Bevel5;
    TLabel* Label5;
    TComboBox* c_comboBox_socketTypeClient;
    TButton* c_button_clientStart;
    TButton* c_button_clientStop;
    TProgressBar* c_pb_clientIn;
    TEdit* c_edit_serverPortClient;
    TEdit* c_edit_serverIPclient;
    TLabel* Label3;
    TLabel* c_label_clientStat;
    TButton* c_button_configAudioSrv;
    TButton* c_button_configAudioCln;
    TCheckListBox* c_clb_server;
    TCheckListBox* c_clb_client;
    TMainMenu* MainMenu1;
    TMenuItem* mi_file_root;
    TMenuItem* mi_help_root;
    TMenuItem* mi_help_about;
    TMenuItem* mi_file_listen;
    TMenuItem* mi_file_stop;
    TMenuItem* N1;
    TMenuItem* mi_file_connect;
    TMenuItem* mi_file_disconnect;
    TMenuItem* N2;
    TMenuItem* mi_file_exit;
    TMenuItem* mi_options_root;
    TMenuItem* mi_options_autoActivateSrv;
    TMenuItem* mi_options_LLN;
    TMenuItem* N3;
    TMenuItem* mi_options_maxClients;
    TMenuItem* mi_options_maxClients_1;
    TMenuItem* mi_options_maxClients_2;
    TMenuItem* mi_options_maxClients_10;
    TMenuItem* N4;
    TMenuItem* mi_options_maxClients_unlimited;
    TProgressBar* c_pb_clientOut;
    TProgressBar* c_pb_serverOut;
	TTimer *c_timer_update;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall FormResize(TObject *Sender);
	void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
	void __fastcall FormShow(TObject *Sender);
	void __fastcall server_startExecute(TObject *Sender);
	void __fastcall server_stopExecute(TObject *Sender);
	void __fastcall client_startExecute(TObject *Sender);
	void __fastcall client_stopExecute(TObject *Sender);
	void __fastcall c_timer_updateTimer(TObject *Sender);
	void __fastcall c_comboBox_socketTypeServerChange(TObject *Sender);
	void __fastcall c_comboBox_socketTypeClientChange(TObject *Sender);
	void __fastcall c_paintBox_networkPaint(TObject *Sender);
	void __fastcall c_button_configAudioSrvClick(TObject *Sender);
	void __fastcall c_button_configAudioClnClick(TObject *Sender);
	void __fastcall ipServerPacketEvent(TObject *sender, DWORD connectionId,
          const unavclInOutIPPacket &packet);
	void __fastcall ipServerSocketEvent(TObject *sender, DWORD connectionId,
          unaSocketEvent event, Pointer data, DWORD len);
	void __fastcall ipClientClientDisconnect(TObject *sender,
          DWORD connectionId, LongBool connected);
	void __fastcall ipClientPacketEvent(TObject *sender, DWORD connectionId,
          const unavclInOutIPPacket &packet);
	void __fastcall ipClientSocketEvent(TObject *sender, DWORD connectionId,
	  unaSocketEvent event, Pointer data, DWORD len);
	void __fastcall mi_help_aboutClick(TObject *Sender);
	void __fastcall mi_options_autoActivateSrvClick(TObject *Sender);
	void __fastcall mi_options_LLNClick(TObject *Sender);
	void __fastcall mi_file_exitClick(TObject *Sender);
	void __fastcall numClientsClick(TObject *Sender);
private:	// User declarations
    int f_clientSamples[65535];	// max client width = 65535
    int f_serverSamples[65536];	// max client width = 65535
    int f_samplesPos;
    int f_samplesMax;
    //
    int f_clientSamplesReceived;
    int f_serverSamplesReceived;
    unaIniFile* f_config;
    //
    void __fastcall updateStatus();
    //procedure wmEraseBkgnd(var message: tMessage); message WM_ERASEBKGND;
    void __fastcall adjustReceiveBuffers(bool enabled);
    void __fastcall adjustNumClients(int maxNum);
public:		// User declarations
	__fastcall Tc_form_main(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
#endif
