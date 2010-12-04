//---------------------------------------------------------------------------

#ifndef u_cbvcVoiceChat_mainH
#define u_cbvcVoiceChat_mainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "unaVcIDE.hpp"
#include <ActnList.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <Menus.hpp>
//---------------------------------------------------------------------------
class Tc_form_main : public TForm
{
__published:	// IDE-managed Components
	TMemo *c_memo_client;
	TSplitter *c_splitter_main;
	TMemo *c_memo_remote;
	TStatusBar *c_statusBar_main;
	TMainMenu *c_mainMenu;
	TMenuItem *mi_file;
	TMenuItem *mi_chat_goClient;
	TMenuItem *mi_chat_goServer;
	TMenuItem *N3;
	TMenuItem *mi_chat_stop;
	TMenuItem *N1;
	TMenuItem *mi_file_exit;
	TMenuItem *mi_edit;
	TMenuItem *mi_edit_audio;
	TMenuItem *mi_editAudio_1;
	TMenuItem *mi_editAudio_2;
	TMenuItem *mi_editAudio_3;
	TMenuItem *N2;
	TMenuItem *mi_esd;
	TMenuItem *N4;
	TMenuItem *mi_edit_clearRemote;
	TMenuItem *mi_help;
	TMenuItem *mi_help_about;
	TActionList *c_actionList_main;
	TAction *a_chat_beClient;
	TAction *a_chat_beServer;
	TAction *a_chat_stop;
	TAction *c_file_exit;
	TTimer *c_timer_update;
	TunavclWaveInDevice *waveIn;
	TunavclWaveCodecDevice *codecIn;
	TunavclIPOutStream *ipClient;
	TunavclIPInStream *ipServer;
	TunavclWaveCodecDevice *codecOut;
	TunavclWaveOutDevice *waveOut;
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall c_file_exitExecute(TObject *Sender);
	void __fastcall c_timer_updateTimer(TObject *Sender);
	void __fastcall a_chat_beServerExecute(TObject *Sender);
	void __fastcall a_chat_beClientExecute(TObject *Sender);
	void __fastcall a_chat_stopExecute(TObject *Sender);
	void __fastcall ipServerServerNewClient(TObject *sender, DWORD connectionId, LongBool connected);
	void __fastcall ipClientClientConnect(TObject *sender, DWORD connectionId, LongBool connected);
	void __fastcall c_memo_clientKeyPress(TObject *Sender, char &Key);
	void __fastcall ipClientTextData(TObject *sender, DWORD connectionId, const AnsiString data);
	void __fastcall ipServerTextData(TObject *sender, DWORD connectionId, const AnsiString data);
	void __fastcall mi_edit_clearRemoteClick(TObject *Sender);
	void __fastcall mi_editAudio_click(TObject *Sender);
	void __fastcall mi_esdClick(TObject *Sender);
private:	// User declarations
    AnsiString f_host;
    unaIniFile *f_config;
    bool f_needEnableClientMemo;
    TStringList *f_delayedStrings;
    //
    void __fastcall loadConfig();
    //
    void __fastcall serverAction(bool doStart);
    void __fastcall clientAction(bool doStart);
    void __fastcall silenceDetectionChanged();
public:		// User declarations
	__fastcall Tc_form_main(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
#endif
