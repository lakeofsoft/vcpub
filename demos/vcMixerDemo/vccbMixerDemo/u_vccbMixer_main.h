//---------------------------------------------------------------------------

#ifndef u_vccbMixer_mainH
#define u_vccbMixer_mainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Messages.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ActnList.hpp>
#include <Buttons.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
//
#include "unaMsAcmClasses.hpp"
#include "unaMsMixer.hpp"
  // --  --
typedef struct tag_TVolumeBar {
    int r_lineIndex;
    int r_connIndex;
    int r_controlId;
    bool r_allowChange;
} TVolumeBar;

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TActionList* c_actionList_main;
    TAction* a_record;
    TAction* a_stop;
    TTimer* c_timer_update;
    TStatusBar* c_statusBar_main;
    TComboBox* c_comboBox_mixerIndex;
    TLabel* Label5;
    TComboBox* c_comboBox_outConn;
    TLabel* c_label_out;
    TTrackBar* c_trackBar_out;
    TLabel* c_label_in;
    TComboBox* c_comboBox_inConn;
    TTrackBar* c_trackBar_in;
    TButton* c_button_recStart;
    TLabel* c_label_URL;
    TButton* c_button_recStop;
    TProgressBar* c_progressBar_right;
    TProgressBar* c_progressBar_left;
    TLabel* Label3;
    TLabel* Label4;
    TBevel* Bevel1;
    TTrackBar* c_trackBar_outMain;
    TTrackBar* c_trackBar_inMain;
    TBevel* Bevel2;
    TCheckBox* c_checkBox_outMute;
    TCheckBox* c_checkBox_inMuted;
    TBevel* Bevel3;
    TCheckBox* c_checkBox_micForce;
    TBevel* Bevel4;
    TLabel* Label1;
    TLabel* Label2;
    TSpeedButton* SpeedButton1;
    TSpeedButton* SpeedButton2;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall a_recordExecute(TObject *Sender);
	void __fastcall a_stopExecute(TObject *Sender);
	void __fastcall c_comboBox_inConnChange(TObject *Sender);
	void __fastcall c_voumeBar_change(TObject *Sender);
	void __fastcall c_timer_updateTimer(TObject *Sender);
	void __fastcall c_comboBox_mixerIndexChange(TObject *Sender);
	void __fastcall c_comboBox_outConnChange(TObject *Sender);
	void __fastcall c_label_URLClick(TObject *Sender);
	void __fastcall c_checkBox_outMuteClick(TObject *Sender);
	void __fastcall c_checkBox_inMutedClick(TObject *Sender);
	void __fastcall c_checkBox_micForceClick(TObject *Sender);
	void __fastcall SpeedButton1Click(TObject *Sender);
	void __fastcall SpeedButton2Click(TObject *Sender);
private:	// User declarations
    unaWaveInDevice* f_waveIn;
    unaMsMixerSystem* f_mixerSystem;
    int f_inConn;
    int f_outConn;
    int f_inLineIndex;
    int f_outLineIndex;
    TVolumeBar f_volumeBar[4];
    //
    void __fastcall changeMixer(int mixerIndex);
    void __fastcall reEnable();
    void __fastcall onMixerControlChange(TMessage &msg);
    void __fastcall rebuildVolumeBar(TTrackBar* trackBar, unsigned iline, int iconn, bool allowNoConn = false);
    bool __fastcall updateVolumeBar(TTrackBar* trackBar, unsigned controlID);
    //
    void updateMixerControl(unsigned controlID);
public:
BEGIN_MESSAGE_MAP
    VCL_MESSAGE_HANDLER(MM_MIXM_CONTROL_CHANGE, TMessage, onMixerControlChange);
END_MESSAGE_MAP(TForm);
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
