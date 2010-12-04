//---------------------------------------------------------------------------

#ifndef u_vccbMp3Demo_mainH
#define u_vccbMp3Demo_mainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ActnList.hpp>
#include <ComCtrls.hpp>
#include <Dialogs.hpp>
#include <ExtCtrls.hpp>
//
#include "unaVcIDE.hpp"
#include "unaEncoderAPI.hpp"
#include "unaVorbisAPI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    //
    TStatusBar *c_statusBar_main;
    TTimer *c_timer_update;
    TPageControl *c_pageControl_main;
    TTabSheet *c_tabSheet_encoder;
    TTabSheet *c_tabSheet_decoder;
    TBevel *c_bevel_encodeTop;
    TLabel *c_label_encodeTop;
    TComboBox *c_comboBox_encoder;
    TLabel *c_label_encoderChoose;
    TLabel *c_label_inputDevice;
    TComboBox *c_comboBox_inputDevice;
    TBevel *c_bevel_decodeSource;
    TLabel *c_label_decodeTop;
    TLabel *c_label_decoderSrc;
    TComboBox *c_comboBox_encodedSource;
    TLabel *c_label_decoderChoose;
    TComboBox *c_comboBox_decoder;
    TComboBox *c_comboBox_outputDevice;
    TLabel *c_label_outputDevice;
    TBevel *c_bevel_encodeSrcOptions;
    TLabel *c_label_encodeSrcOptions;
    TBevel *c_bevel_encodeOptions;
    TLabel *c_label_encodeOptions;
    TComboBox *c_comboBox_encodedDest;
    TLabel *c_label_encoderDest;
    TLabel *c_label_decodeSrcOptions;
    TBevel *c_bevel_decodeSrcOptions;
    TLabel *c_label_decodeOptions;
    TBevel *c_bevel_decodeOptions;
    TButton *c_button_encodeStart;
    TButton *c_button_encodeStop;
    TActionList *c_actionList_main;
    TAction *a_encode_start;
    TAction *a_encode_stop;
    TunavclWaveInDevice *waveIn;
    TComboBox *c_comboBox_minBR;
    TCheckBox *c_checkBox_enableVBR;
    TLabel *c_label_encoderMinBR;
    TLabel *c_label_encoderMaxBR;
    TComboBox *c_comboBox_maxBR;
    TComboBox *c_comboBox_samplesRate;
    TLabel *c_label_encoderSR;
    TComboBox *c_comboBox_stereoMode;
    TLabel *c_label_encoderSM;
    TLabel *c_label_encoderAvBR;
    TComboBox *c_comboBox_avBR;
    TButton *c_button_decodeStart;
    TButton *c_button_decodeStop;
    TAction *a_decode_start;
    TAction *a_decode_stop;
    TCheckBox *c_checkBox_disBRS;
    TComboBox *c_comboBox_vbrQuality;
    TLabel *c_label_encoderVBRQ;
    TLabel *c_label_encoderMp3File;
    TEdit *c_edit_destFile;
    TButton *c_button_destBrowse;
    TSaveDialog *c_saveDialog_dest;
    TButton *c_button_playback;
    TButton *c_button_encodeAbout;
    TCheckBox *c_checkBox_copyrighted;
    TCheckBox *c_checkBox_CRC;
    TCheckBox *c_checkBox_original;
    TCheckBox *c_checkBox_private;
    TCheckBox *c_checkBox_overwriteP;
    TunavclWaveOutDevice *waveOut;
    TButton *c_button_help;
    TAction *a_help_show;
    TLabel *c_label_portNumber;
    TEdit *c_edit_portNumber;
    TLabel *c_label_sourceFile;
    TEdit *c_edit_sourceFile;
    TButton *c_button_sourceBrowse;
    TOpenDialog *c_openDialog_source;
    TEdit *c_edit_serverPort;
    TLabel *c_label_serverPort;
    TLabel *c_label_warningOgg;
    //
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall c_comboBox_inputDeviceChange(TObject *Sender);
	void __fastcall c_comboBox_encoderChange(TObject *Sender);
	void __fastcall c_comboBox_encodedDestChange(TObject *Sender);
	void __fastcall c_comboBox_avBRChange(TObject *Sender);
	void __fastcall c_checkBox_enableVBRClick(TObject *Sender);
	void __fastcall c_comboBox_stereoModeChange(TObject *Sender);
	void __fastcall c_edit_destFileChange(TObject *Sender);
	void __fastcall c_checkBox_overwritePClick(TObject *Sender);
	void __fastcall c_button_encodeAboutClick(TObject *Sender);
	void __fastcall c_button_destBrowseClick(TObject *Sender);
	void __fastcall c_button_playbackClick(TObject *Sender);
	void __fastcall c_comboBox_encodedSourceChange(TObject *Sender);
	void __fastcall c_comboBox_decoderChange(TObject *Sender);
	void __fastcall c_comboBox_outputDeviceChange(TObject *Sender);
	void __fastcall c_edit_sourceFileChange(TObject *Sender);
	void __fastcall c_button_sourceBrowseClick(TObject *Sender);
	void __fastcall c_timer_updateTimer(TObject *Sender);
	void __fastcall a_encode_startExecute(TObject *Sender);
	void __fastcall a_encode_stopExecute(TObject *Sender);
	void __fastcall a_decode_startExecute(TObject *Sender);
	void __fastcall a_decode_stopExecute(TObject *Sender);
	void __fastcall waveInDataAvailable(unavclInOutPipe *sender, Pointer data,
          DWORD len);
	void __fastcall waveOutFeedChunk(unavclInOutPipe *sender, Pointer data,
          DWORD len);
private:	// User declarations
    unaIniFile* f_config;
    //
    bool f_bladeOK;
    bool f_lameOK;
    bool f_vorbisEncodeOK;
    bool f_vorbisDecodeOK;
    bool f_bassOK;
    int f_decoderIndex;
    //
    unaBladeMp3Enc* f_blade;
    unaLameMp3Enc* f_lame;
    unaVorbisEnc* f_vorbisEncode;
    unaVorbisDecoder* f_vorbisDecode;
    //
    unaBass* f_bassDecode;
    __int64 f_bassDecodeSize;
    unaBassStream* f_bassFile;
    void* f_feedBuf;
    unsigned f_feedBufSize;
    //
    // Ogg
    int f_vorbisHP;
    unaOggFile* f_oggOutFile;
    unaOggFile* f_oggInFile;
    tOgg_packet f_op;
    //
    unaAbstractEncoder* f_encoder;
    //
    __fastcall void flushOgg();
    //
    __fastcall void enumAudioDevices();
    __fastcall void enumEngineDevices();
    __fastcall void myOnEncoderDataAvail(TObject* sender, void* data, unsigned size, int& copyToStream);
    __fastcall void myOnDecoderDataAvail(TObject* sender, void* data, unsigned size, int& copyToStream);
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
