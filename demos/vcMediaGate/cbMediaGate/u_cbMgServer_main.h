//---------------------------------------------------------------------------

#ifndef u_cbMgServer_mainH
#define u_cbMgServer_mainH
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
    TEdit* c_edit_speakPort;
    TLabel* Label1;
    TLabel* Label2;
    TEdit* c_edit_listenPort;
    TButton* c_button_start;
    TButton* c_button_stop;
    TCheckListBox* c_clb_debug;
    TunavclIPInStream* speakServer;
    TunavclIPInStream* listenServer;
    TTimer* c_timer_update;
    TActionList* c_actionList_main;
    TAction* a_srv_start;
    TAction* a_srv_stop;
    TLabel* Label3;
    TBevel* Bevel1;
    TBevel* Bevel2;
    TLabel* Label4;
    TBevel* Bevel3;
    TStatusBar* c_statusBar_main;
    TLabel* c_label_listeners;
    TLabel* c_label_served;
    TLabel* c_label_received;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormCloseQuery(TObject *Sender, bool &CanClose);
	void __fastcall FormShow(TObject *Sender);
	void __fastcall c_timer_updateTimer(TObject *Sender);
	void __fastcall a_srv_startExecute(TObject *Sender);
	void __fastcall a_srv_stopExecute(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall Tc_form_main(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
#endif
