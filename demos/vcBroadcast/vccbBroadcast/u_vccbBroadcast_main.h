//---------------------------------------------------------------------------

#ifndef u_vccbBroadcast_mainH
#define u_vccbBroadcast_mainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "unaVcIDE.hpp"
#include <ActnList.hpp>
#include <ComCtrls.hpp>
#include <Dialogs.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class Tc_form_main : public TForm
{
__published:	// IDE-managed Components
    TPageControl* c_pageControl_main;
    TTabSheet* c_tabSheet_server;
    TTabSheet* c_tabSheet_client;
    TEdit* c_edit_serverPort;
    TLabel* c_label_serverPort;
    TButton* c_button_serverStart;
    TButton* c_button_serverStop;
    TActionList* c_actionList_main;
    TAction* a_startServer;
    TAction* a_stopServer;
    TLabel* c_label_clientPort;
    TEdit* c_edit_clientPort;
    TStaticText* c_static_clientInfo;
    TButton* c_button_clientStart;
    TButton* c_button_clientStop;
    TAction* a_startClient;
    TAction* a_stopClient;
    TunavclWaveInDevice* waveIn_server;
    TunavclWaveOutDevice* waveOut_client;
    TunavclWaveCodecDevice* codecIn_server;
    TStatusBar* c_statusBar_main;
    TTimer* c_timer_main;
    TLabel* c_label_serverStat;
    TLabel* c_label_clientStat;
    TunavclWaveCodecDevice* codecOut_client;
    TCheckBox* c_checkBox_serverAutoStart;
    TunavclIPBroadcastServer* c_broadcastServer;
    TunavclIPBroadcastClient* c_broadcastClient;
    TEdit* c_edit_saveWAVname;
    TButton* c_button_saveWAV;
    TCheckBox* c_checkBox_saveWAV;
    TunavclWaveRiff* wavWrite;
    TSaveDialog* c_sd_saveWAV;
    TButton* c_button_ac;
    TLabel* c_label_url;
    TBevel* Bevel1;
    TBevel* Bevel2;
    TBevel* Bevel3;
    TBevel* Bevel4;
    TBevel* Bevel5;
    TLabel* c_label_web;
    TBevel* Bevel6;
    TLabel* Label1;
    TLabel* Label2;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
	void __fastcall FormShow(TObject *Sender);
	void __fastcall FormCloseQuery(TObject *Sender, bool &CanClose);
	void __fastcall a_stopServerExecute(TObject *Sender);
	void __fastcall a_startClientExecute(TObject *Sender);
	void __fastcall a_startServerExecute(TObject *Sender);
	void __fastcall a_stopClientExecute(TObject *Sender);
	void __fastcall c_timer_mainTimer(TObject *Sender);
	void __fastcall c_label_urlClick(TObject *Sender);
	void __fastcall c_button_saveWAVClick(TObject *Sender);
	void __fastcall c_edit_saveWAVnameChange(TObject *Sender);
	void __fastcall c_button_acClick(TObject *Sender);
	void __fastcall codecOut_clientDataAvailable(unavclInOutPipe *sender,
          Pointer data, DWORD len);
private:	// User declarations
    unaIniFile* f_ini;
public:		// User declarations
	__fastcall Tc_form_main(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
#endif
