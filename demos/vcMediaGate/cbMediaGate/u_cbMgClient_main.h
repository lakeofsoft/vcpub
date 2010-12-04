//---------------------------------------------------------------------------

#ifndef u_cbMgClient_mainH
#define u_cbMgClient_mainH
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
//---------------------------------------------------------------------------
class Tc_form_main : public TForm
{
__published:	// IDE-managed Components
    TEdit* c_edit_host;
    TLabel* Label1;
    TEdit* c_edit_speakPort;
    TLabel* Label2;
    TRadioButton* c_rb_speak;
    TRadioButton* c_rb_listen;
    TButton* c_button_go;
    TunavclWaveInDevice* waveIn;
    TButton* c_button_stop;
    TunavclWaveCodecDevice* codecIn;
    TunavclIPOutStream* ipClient;
    TunavclWaveCodecDevice* codecOut;
    TunavclWaveOutDevice* waveOut;
    TCheckListBox* c_clb_debug;
    TTimer* c_timer_update;
    TEdit* c_edit_listenPort;
    TLabel* Label3;
    TLabel* Label4;
    TBevel* Bevel1;
    TBevel* Bevel2;
    TLabel* Label5;
    TLabel* Label6;
    TLabel* Label7;
    TBevel* Bevel3;
    TStatusBar* c_statusBar_main;
    TActionList* c_actionList_main;
    TAction* a_cln_start;
    TAction* a_cln_stop;
    TLabel* c_label_stat;
    TLabel* Label8;
    TLabel* Label9;
    TCheckBox* c_checkBox_random;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormCloseQuery(TObject *Sender, bool &CanClose);
	void __fastcall FormShow(TObject *Sender);
	void __fastcall c_timer_updateTimer(TObject *Sender);
	void __fastcall a_cln_startExecute(TObject *Sender);
	void __fastcall a_cln_stopExecute(TObject *Sender);
	void __fastcall ipClientClientDisconnect(TObject *sender,
	  DWORD connectionId, LongBool connected);
private:	// User declarations

public:		// User declarations
	__fastcall Tc_form_main(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
#endif
