//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "unavcIDE.hpp"
#include <ActnList.hpp>
#include <CheckLst.hpp>
#include <ComCtrls.hpp>
#include <Dialogs.hpp>
#include <ExtCtrls.hpp>
#include "unaVcIDE.hpp"
//---------------------------------------------------------------------------
class Tc_form_main : public TForm
{
__published:	// IDE-managed Components
	TStatusBar *c_statusBar_main;
	TOpenDialog *c_openDialog_wave;
	TActionList *c_actionList_main;
	TAction *a_srvStart;
	TAction *a_srvStop;
	TAction *a_clientStart;
	TAction *a_clientStop;
	TTimer *c_timer_update;
	TunavclWaveRiff *riff_client;
	TunavclWaveResampler *resampler_client;
	TunavclWaveInDevice *waveIn_client;
	TunavclWaveMixer *mixer_client;
	TunavclWaveCodecDevice *codecIn_client;
	TunavclIPOutStream *ipClient;
	TunavclWaveCodecDevice *codecOut_client;
	TunavclWaveOutDevice *waveOut_client;
	TunavclWaveRiff *riff_server;
	TunavclWaveResampler *resampler_server;
	TunavclWaveInDevice *waveIn_server;
	TunavclWaveMixer *mixer_server;
	TunavclWaveCodecDevice *codecIn_server;
	TunavclIPInStream *ipServer;
	TunavclWaveCodecDevice *codecOut_server;
	TunavclWaveOutDevice *waveOut_server;
	TPageControl *c_pageControl_main;
	TTabSheet *c_tabSheet_server;
	TGroupBox *c_groupBox_server;
	TLabel *Label1;
	TBevel *Bevel1;
	TLabel *c_label_statusSrv;
	TBevel *Bevel4;
	TLabel *Label5;
	TLabel *Label6;
	TBevel *Bevel5;
	TEdit *c_edit_serverPort;
	TButton *c_button_startServer;
	TButton *c_button_stopServer;
	TCheckListBox *c_checkListBox_server;
	TEdit *c_edit_waveNameServer;
	TCheckBox *c_checkBox_mixWaveServer;
	TButton *c_button_chooseWaveServer;
	TCheckBox *c_checkBox_useWaveInServer;
	TButton *c_button_formatChooseServer;
	TStaticText *c_static_formatInfoServer;
	TStaticText *c_staticText_deviceInfoServer;
	TCheckBox *c_checkBox_autoStartServer;
	TComboBox *c_comboBox_socketTypeServer;
	TProgressBar *c_pb_volumeOutServer;
	TProgressBar *c_pb_volumeInServer;
	TTabSheet *c_tabSheet_client;
	TGroupBox *c_groupBox_client;
	TLabel *Label2;
	TLabel *Label3;
	TBevel *Bevel2;
	TLabel *c_label_statusClient;
	TBevel *Bevel3;
	TLabel *Label4;
	TLabel *Label7;
	TBevel *Bevel6;
	TEdit *c_edit_clientSrvHost;
	TButton *c_button_startClient;
	TButton *c_button_stopClient;
	TEdit *c_edit_clientSrvPort;
	TCheckListBox *c_checkListBox_client;
	TCheckBox *c_checkBox_mixWaveClient;
	TEdit *c_edit_waveNameClient;
	TButton *c_button_chooseWaveClient;
	TCheckBox *c_checkBox_useWaveInClient;
	TStaticText *c_static_formatInfoClient;
	TButton *c_button_formatChooseClient;
	TStaticText *c_staticText_deviceInfoClient;
	TComboBox *c_comboBox_socketTypeClient;
	TProgressBar *c_pb_volumeOutClient;
	TProgressBar *c_pb_volumeInClient;
	void __fastcall a_srvStartExecute(TObject *Sender);
	void __fastcall a_srvStopExecute(TObject *Sender);
	void __fastcall a_clientStartExecute(TObject *Sender);
	void __fastcall a_clientStopExecute(TObject *Sender);
	void __fastcall c_timer_updateTimer(TObject *Sender);
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
	void __fastcall c_button_formatChooseClientClick(TObject *Sender);
	void __fastcall c_button_formatChooseServerClick(TObject *Sender);
	void __fastcall c_button_chooseWaveClientClick(TObject *Sender);
	void __fastcall c_button_chooseWaveServerClick(TObject *Sender);
	void __fastcall FormShow(TObject *Sender);
	void __fastcall c_comboBox_socketTypeServerChange(TObject *Sender);
	void __fastcall c_comboBox_socketTypeClientChange(TObject *Sender);
	void __fastcall FormCloseQuery(TObject *Sender, bool &CanClose);
	void __fastcall ipClientClientDisconnect(TObject *sender,
          DWORD connectionId, LongBool connected);
private:	// User declarations
	unaIniFile* f_ini;
        //
	void __fastcall reEnable(bool server = true);
	void __fastcall serverAction(bool doOpen = true);
	void __fastcall clientAction(bool doOpen = true);
	void __fastcall chooseFile(TCheckBox *cb, TEdit *edit);
	void __fastcall deviceInfo(bool isServer, unsigned index, unavclInOutPipe *device);
	void __fastcall updateFormat(bool isServer = true);
	void __fastcall updateFormatInfo(bool isServer = true);
public:		// User declarations
	__fastcall Tc_form_main(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
#endif
