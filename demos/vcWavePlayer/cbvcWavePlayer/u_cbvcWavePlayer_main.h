//---------------------------------------------------------------------------

#ifndef u_cbvcWavePlayer_mainH
#define u_cbvcWavePlayer_mainH
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
	TunavclWaveResampler *resampler;
	TunavclWaveOutDevice *waveOut;
	TunavclWaveRiff *wavRead;
	TOpenDialog *c_openDialog_main;
	TTimer *c_timer_update;
	TTimer *c_go_update;
	TActionList *c_actionList_main;
	TAction *a_file_open;
	TAction *a_playback_start;
	TAction *a_playback_stop;
	TStatusBar *c_statusBar_main;
	TPanel *Panel1;
	TTrackBar *c_trackBar_tempo;
	TLabel *c_label_tempo;
	TLabel *c_label_vol;
	TTrackBar *c_trackBar_volume;
	TProgressBar *c_progressBar_volumeLeft;
	TProgressBar *c_progressBar_volumeRight;
	TBevel *Bevel2;
	TLabel *c_label_caption;
	TBevel *Bevel1;
	TEdit *c_edit_fileName;
	TLabel *Label1;
	TButton *c_button_browse;
	TButton *c_button_start;
	TButton *c_button_stop;
	TCheckBox *c_checkBox_autoRewind;
	TTrackBar *c_trackBar_pos;
	TCheckBox *c_checkBox_enableGO;
	TBevel *Bevel3;
	TLabel *Label2;
	TPaintBox *c_paintBox_wave;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall a_file_openExecute(TObject *Sender);
	void __fastcall c_edit_fileNameChange(TObject *Sender);
	void __fastcall c_go_updateTimer(TObject *Sender);
	void __fastcall a_playback_startExecute(TObject *Sender);
	void __fastcall a_playback_stopExecute(TObject *Sender);
	void __fastcall c_checkBox_autoRewindClick(TObject *Sender);
	void __fastcall c_trackBar_posChange(TObject *Sender);
	void __fastcall wavReadDataAvailable(unavclInOutPipe *sender,
          Pointer data, DWORD len);
	void __fastcall c_timer_updateTimer(TObject *Sender);
	void __fastcall c_trackBar_volumeChange(TObject *Sender);
	void __fastcall waveOutFeedChunk(unavclInOutPipe *sender, Pointer data,
          DWORD len);
	void __fastcall c_paintBox_wavePaint(TObject *Sender);
	void __fastcall c_trackBar_tempoChange(TObject *Sender);
private:	// User declarations
    unaIniFile *f_config;
    bool f_autoSeekPos;
    short int f_samples[65536];
    unsigned f_samplesCount;
    unsigned f_oldTempo;
    bool f_invalidateIsDone;
    bool f_needSome;
    bool f_inTimer;
    bool f_inTimerGO;
    void __fastcall reEnableControls(bool isOpen);
public:		// User declarations
	__fastcall Tc_form_main(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE Tc_form_main *c_form_main;
//---------------------------------------------------------------------------
#endif
