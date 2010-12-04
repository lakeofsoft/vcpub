
(*
	----------------------------------------------

	  u_vcBASSDemo_main.pas
	  vcBASSDemo demo application - main form

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 08 Jan 2003

	  modified by:
		Lake, Jan-Dec 2003
		Lake, Oct 2005
		Lake, Mar 2006
		Lake, Apr 2007
		Lake, Feb-May 2009

	----------------------------------------------
*)

{$I unaDef.inc }
{$I unaBassDef.inc }

unit
  u_vcBASSDemo_main;

interface

uses
  Windows, unaTypes, unaClasses, unaEncoderAPI,
  Graphics, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Classes, ActnList,
  CheckLst, Dialogs, Menus;

type
  Tc_form_main = class(TForm)
    PageControl1: TPageControl;
    c_tabSheet_bassInfo: TTabSheet;
    c_tabSheet_music: TTabSheet;
    c_tabSheet_stream: TTabSheet;
    c_tabSheet_samples: TTabSheet;
    c_tabSheet_CD: TTabSheet;
    c_tabSheet_record: TTabSheet;
    c_panel_bottom: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    c_edit_library: TEdit;
    c_label_libVersion: TLabel;
    c_button_bassLoad: TButton;
    c_button_bassUnload: TButton;
    c_memo_bassInfo: TMemo;
    Label4: TLabel;
    c_actionList_main: TActionList;
    a_bass_libLoad: TAction;
    a_bass_libUnload: TAction;
    Button3: TButton;
    Bevel1: TBevel;
    c_comboBox_deviceId: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    c_edit_playbackFreq: TEdit;
    c_checkListBox_initFlags: TCheckListBox;
    Label7: TLabel;
    c_button_bassInit: TButton;
    a_bass_libInit: TAction;
    c_timer_update: TTimer;
    Button1: TButton;
    a_bass_libInfoUpdate: TAction;
    c_tabSheet_volume: TTabSheet;
    c_trackBar_volumeMusic: TTrackBar;
    Label8: TLabel;
    c_trackBar_volumeSample: TTrackBar;
    Label9: TLabel;
    c_trackBar_volumeStream: TTrackBar;
    Label10: TLabel;
    Bevel2: TBevel;
    Label11: TLabel;
    c_trackBar_volumeMaster: TTrackBar;
    Button2: TButton;
    Button4: TButton;
    Button5: TButton;
    a_bass_actStop: TAction;
    a_bass_actStart: TAction;
    a_bass_actPause: TAction;
    c_edit_musicFile: TEdit;
    Label12: TLabel;
    Button6: TButton;
    c_listBox_musicModules: TListBox;
    Button7: TButton;
    c_checkListBox_musicFlags: TCheckListBox;
    Label13: TLabel;
    Label14: TLabel;
    Bevel3: TBevel;
    Button8: TButton;
    c_label_musicLen: TLabel;
    Button9: TButton;
    c_trackBar_musicAmp: TTrackBar;
    Label16: TLabel;
    Label17: TLabel;
    c_trackBar_musicPan: TTrackBar;
    Label18: TLabel;
    c_comboBox_musicChannel: TComboBox;
    Label19: TLabel;
    c_trackBar_musicChannelVolume: TTrackBar;
    Bevel4: TBevel;
    c_label_musicPos: TLabel;
    a_bass_musicLoad: TAction;
    a_bass_musicPlay: TAction;
    a_bass_musicUnload: TAction;
    a_file_browseMusic: TAction;
    a_file_browseLib: TAction;
    c_openDialog_music: TOpenDialog;
    c_openDialog_lib: TOpenDialog;
    Button10: TButton;
    a_bass_musicStop: TAction;
    c_trackBar_musicPos: TTrackBar;
    Button11: TButton;
    a_bass_musicLoadMem: TAction;
    c_comboBox_cdDrive: TComboBox;
    Label15: TLabel;
    Button12: TButton;
    a_bass_cdInit: TAction;
    Button13: TButton;
    a_bass_cdFree: TAction;
    c_label_cdDrive: TLabel;
    Button14: TButton;
    Button15: TButton;
    a_bass_cdDoorOpen: TAction;
    a_bass_cdDoorClose: TAction;
    c_memo_cdInfo: TMemo;
    c_button_updateCDinfo: TButton;
    c_checkBox_cdInDrive: TCheckBox;
    Label20: TLabel;
    c_comboBox_cdTrack: TComboBox;
    Button17: TButton;
    Button18: TButton;
    Bevel5: TBevel;
    a_bass_cdTrackPlay: TAction;
    a_bass_cdTrackStop: TAction;
    c_checkBox_cdTrackPlayLoop: TCheckBox;
    Label21: TLabel;
    c_edit_streamPath: TEdit;
    Button19: TButton;
    a_bass_streamBrowse: TAction;
    c_openDialog_stream: TOpenDialog;
    c_checkListBox_streamFlags: TCheckListBox;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    Button23: TButton;
    Button24: TButton;
    Label22: TLabel;
    Label23: TLabel;
    c_listBox_streamModules: TListBox;
    Bevel6: TBevel;
    a_bass_streamLoad: TAction;
    a_bass_streamLoadMem: TAction;
    a_bass_streamPlay: TAction;
    a_bass_streamStop: TAction;
    a_bass_streamUnload: TAction;
    c_trackBar_streamPos: TTrackBar;
    c_label_streamLength: TLabel;
    c_label_streamPos: TLabel;
    c_progressBar_streamLevelLeft: TProgressBar;
    c_progressBar_streamLevelRight: TProgressBar;
    c_timer_levelUpdate: TTimer;
    c_progressBar_musicLevelLeft: TProgressBar;
    c_progressBar_musicLevelRight: TProgressBar;
    PaintBox1: TPaintBox;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    c_mm_main: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Label3: TLabel;
    //
    procedure formCreate(sender: tObject);
    procedure formDestroy(sender: tObject);
    procedure formShow(sender: tObject);
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    //
    procedure a_bass_libLoadExecute(Sender: TObject);
    procedure a_bass_libUnloadExecute(Sender: TObject);
    procedure a_bass_libInitExecute(Sender: TObject);
    procedure a_bass_libInfoUpdateExecute(Sender: TObject);
    procedure a_bass_actStopExecute(Sender: TObject);
    procedure a_bass_actStartExecute(Sender: TObject);
    procedure a_bass_actPauseExecute(Sender: TObject);
    procedure a_bass_musicLoadExecute(Sender: TObject);
    procedure a_file_browseMusicExecute(Sender: TObject);
    procedure a_file_browseLibExecute(Sender: TObject);
    procedure a_bass_musicPlayExecute(Sender: TObject);
    procedure a_bass_musicUnloadExecute(Sender: TObject);
    procedure a_bass_musicStopExecute(Sender: TObject);
    procedure a_bass_musicLoadMemExecute(Sender: TObject);
    procedure a_bass_cdInitExecute(Sender: TObject);
    procedure a_bass_cdFreeExecute(Sender: TObject);
    procedure a_bass_cdDoorOpenExecute(Sender: TObject);
    procedure a_bass_cdDoorCloseExecute(Sender: TObject);
    procedure a_bass_cdTrackPlayExecute(Sender: TObject);
    procedure a_bass_cdTrackStopExecute(Sender: TObject);
    procedure a_bass_streamBrowseExecute(Sender: TObject);
    procedure a_bass_streamLoadExecute(Sender: TObject);
    procedure a_bass_streamLoadMemExecute(Sender: TObject);
    procedure a_bass_streamPlayExecute(Sender: TObject);
    procedure a_bass_streamStopExecute(Sender: TObject);
    procedure a_bass_streamUnloadExecute(Sender: TObject);
    //
    procedure c_timer_updateTimer(Sender: TObject);
    procedure c_listBox_streamModulesClick(Sender: TObject);
    procedure c_edit_streamPathChange(Sender: TObject);
    procedure c_trackBar_streamPosChange(Sender: TObject);
    procedure c_trackBar_musicPosChange(Sender: TObject);
    procedure c_trackBar_musicAmpChange(Sender: TObject);
    procedure c_trackBar_musicPanChange(Sender: TObject);
    procedure c_trackBar_volumeMusicChange(Sender: TObject);
    procedure c_trackBar_volumeSampleChange(Sender: TObject);
    procedure c_trackBar_volumeStreamChange(Sender: TObject);
    procedure c_trackBar_volumeMasterChange(Sender: TObject);
    procedure c_listBox_musicModulesClick(Sender: TObject);
    procedure c_trackBar_musicChannelVolumeChange(Sender: TObject);
    procedure c_timer_levelUpdateTimer(Sender: TObject);
    procedure c_comboBox_cdDriveChange(Sender: TObject);
    procedure c_edit_musicFileChange(Sender: TObject);
    //
    procedure c_button_updateCDinfoClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label1MouseEnter(Sender: TObject);
    procedure Label1MouseLeave(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    { Private declarations }
    f_caption: string;
    f_bass: unaBass;
    f_noChangeTrack: bool;
    // music
    //f_musicBMP: tBitmap;
    // cd
    f_cdDrive: char;
    // stream
    //f_streamBMP: tBitmap;
    //
    f_config: unaIniFile;
    //
    procedure displayBassInfo();
    procedure updateInitParams();
    // music
    function getSelectedMusic(): unaBassMusic;
    function getMusicFlags(): DWORD;
    procedure updateMusicInfo(rescanChannels: bool = false);
    // cd
    procedure enumCD();
    function getSelectedCDDrive(): char;
    procedure updateCDinfo();
    // stream
    function getSelectedStream(): unaBassStream;
    function getStreamFlags(): DWORD;
    procedure updateStreamInfo();
  public
    { Public declarations }
  end;

var
  c_form_main: Tc_form_main;


implementation


{$R *.dfm}

{$R vcBassDemoMem.RES }	// music and stream to load from memory

uses
  unaBassAPI, unaUtils, unaVCLUtils,
  Messages, sysUtils, shellAPI;

//=============== GUI ===================

// --  --
procedure Tc_form_main.Label1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://www.un4seen.com/', nil, nil, SW_SHOWNORMAL);
end;

// --  --
procedure Tc_form_main.Label2Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://lakeofsoft.com/', nil, nil, SW_SHOWNORMAL);
end;

// --  --
procedure Tc_form_main.Label1MouseEnter(Sender: TObject);
begin
  (sender as tLabel).font.style := [fsUnderline];
end;

// --  --
procedure Tc_form_main.Label1MouseLeave(Sender: TObject);
begin
  (sender as tLabel).font.style := [];
end;

// --  --
procedure Tc_form_main.formCreate(Sender: TObject);
begin
  f_config := unaIniFile.create();
  //
  c_checkListBox_initFlags.Checked[3] := true;
  c_checkListBox_musicFlags.Checked[9] := true;
  c_checkListBox_musicFlags.Checked[12] := true;
  c_checkListBox_streamFlags.Checked[5] := true;
  //
  c_edit_library.text := f_config.get('library', 'bass.dll');
  //
  f_caption := caption;
  a_bass_libLoad.execute();
  //
  c_edit_musicFileChange(sender);
  c_edit_streamPathChange(sender);
  //
  //
  enumCD();
end;

// --  --
procedure Tc_form_main.formShow(sender: tObject);
begin
  loadControlPosition(self, f_config);
  //
  c_label_libVersion.caption := c_label_libVersion.caption + ' (must be a BASS ' +
  {$IFDEF BASS_AFTER_23 }
    '2.4' +
  {$ELSE }
    {$IFDEF BASS_AFTER_22 }
      '2.3' +
    {$ELSE }
      {$IFDEF BASS_AFTER_21 }
        '2.2' +
      {$ELSE }
        {$IFDEF BASS_AFTER_20 }
          '2.1' +
        {$ELSE }
          {$IFDEF BASS_AFTER_18 }
            '2.0' +
          {$ELSE }
            '1.8' +
          {$ENDIF }
        {$ENDIF }
      {$ENDIF }
    {$ENDIF }
  {$ENDIF }
  ' compatible)';
end;

// --  --
procedure Tc_form_main.FormCloseQuery(sender: tObject; var canClose: boolean);
begin
  saveControlPosition(self, f_config);
  //
  f_config.setValue('library', c_edit_library.text);
end;

// --  --
procedure Tc_form_main.formDestroy(Sender: TObject);
begin
  a_bass_libUnload.execute();
  //
  freeAndNil(f_config);
end;

// --  --
procedure Tc_form_main.c_timer_updateTimer(Sender: TObject);
var
  cpu: DWORD;
begin
  if (nil <> f_bass) then begin
    //
    cpu := f_bass.get_CPU();
    caption := f_caption +
	       '   Mem: ' + int2str(ams() shr 10, 10, 3) + ' KB / ' +
	       ' CPU: ' + int2str(cpu div 100) + '.' + int2str(cpu mod 100) + '%';
    //
    updateMusicInfo();
    updateStreamInfo();
  end
  else
    caption := f_caption;
end;

// --  --
procedure Tc_form_main.c_timer_levelUpdateTimer(Sender: TObject);
var
  lev: DWORD;
  music: unaBassMusic;
  stream: unaBassStream;
begin
  // music levels
  music := getSelectedMusic();
  if (nil <> music) then begin
    // levels
    lev := music.asChannel.get_level();
    c_progressBar_musicLevelLeft.position := lev and $FFFF;
    c_progressBar_musicLevelRight.position := lev shr 16;
  end
  else begin
    c_progressBar_musicLevelLeft.position := 0;
    c_progressBar_musicLevelRight.position := 0;
  end;

  // stream levels
  stream := getSelectedStream();
  if (nil <> stream) then begin
    // levels
    lev := stream.asChannel.get_level();
    c_progressBar_streamLevelLeft.position := lev and $FFFF;
    c_progressBar_streamLevelRight.position := lev shr 16;
  end
  else begin
    c_progressBar_streamLevelLeft.position := 0;
    c_progressBar_streamLevelRight.position := 0;
  end;  
end;

//=============== BASS general ===================

// --  --
procedure Tc_form_main.a_file_browseLibExecute(Sender: TObject);
begin
  if (c_openDialog_lib.execute()) then
    c_edit_library.text := c_openDialog_lib.fileName;
end;

// --  --
procedure Tc_form_main.a_bass_libLoadExecute(Sender: TObject);
begin
  a_bass_libUnload.Execute();
  //
  f_bass := unaBass.create(c_edit_library.text, {$IFDEF BASS_AFTER_18 }1{$ELSE }-1{$ENDIF }, 44100, 32, handle);
  //
  displayBassInfo();
  updateInitParams();
  updateMusicInfo();
  //
  a_bass_libLoad.enabled := false;
  a_bass_libUnload.enabled := true;
  a_bass_libInit.enabled := true;
  //
  a_bass_actStart.enabled := true;
  a_bass_actStop.enabled := true;
  a_bass_actPause.enabled := true;
  //
  a_bass_actPause.enabled := true;
  a_file_browseLib.enabled := false;
  c_edit_library.enabled := false;
  //
  a_bass_actStart.execute();
end;

// --  --
procedure Tc_form_main.a_bass_libUnloadExecute(Sender: TObject);
begin
  c_listBox_musicModules.clear();
  c_listBox_streamModules.clear();
  c_comboBox_deviceId.clear();
  //
  freeAndNil(f_bass);
  //
  a_bass_libLoad.enabled := true;
  a_bass_libUnload.enabled := false;
  a_bass_libInit.enabled := false;
  //
  a_bass_actStart.enabled := false;
  a_bass_actStop.enabled := false;
  a_bass_actPause.enabled := false;
  //
  a_file_browseLib.enabled := true;
  c_edit_library.enabled := true;
  //
  c_memo_bassInfo.text := 'No library was loaded.';
end;

// --  --
procedure Tc_form_main.displayBassInfo();
var
  ver: DWORD;
  info: BASS_INFO;
  volMusic,
  volSample,
  volStream: int;
begin
  c_memo_bassInfo.clear();
  //
  if ((nil = f_bass) or (BASS_ERROR_NOLIBRARY = f_bass.get_errorCode())) then begin
    //
    c_memo_bassInfo.Text := 'No BASS library was found, or specified library is not compatible.';
    //
    freeAndNil(f_bass);
  end
  else begin
    ver := f_bass.get_version();
    {$IFDEF BASS_AFTER_22 }
    c_memo_bassInfo.lines.add('BASS Library version: ' + int2str((ver shr 24) and $FF) + '.' + int2str((ver shr 16) and $FF) + '.' + int2str((ver shr 8) and $FF) + '.' + int2str((ver shr 0) and $FF) );
    {$ELSE }
    c_memo_bassInfo.lines.add('BASS Library version: ' + int2str(ver and $FFFF) + '.' + int2str(ver shr 16));
    {$ENDIF }
    //
    if (f_bass.get_info(info)) then begin
      //
      with (info) do begin
	//
	c_memo_bassInfo.lines.add('flags = 0x' + int2str(flags, 16));
	c_memo_bassInfo.lines.add('hwsize = '  + int2str(hwsize));
	c_memo_bassInfo.lines.add('hwfree = '  + int2str(hwfree));
	c_memo_bassInfo.lines.add('freesam = ' + int2str(freesam));
	c_memo_bassInfo.lines.add('free3d = '  + int2str(free3d));
	c_memo_bassInfo.lines.add('minrate = ' + int2str(minrate));
	c_memo_bassInfo.lines.add('maxrate = ' + int2str(maxrate));
	c_memo_bassInfo.lines.add('eax = '     + string(bool2strStr(eax)));
	c_memo_bassInfo.lines.add('minbuf = '  + int2str(minbuf));
	c_memo_bassInfo.lines.add('dsver = '   + int2str(dsver));
	c_memo_bassInfo.lines.add('latency = ' + int2str(latency));
      end;
    end
    else
      c_memo_bassInfo.lines.add('BASS_GET_INFO fails, error code=' + int2str(f_bass.get_errorCode()));
    //
    // update volumes as well
    if (f_bass.get_globalVolumes(volMusic, volSample, volStream)) then begin
      c_trackBar_volumeMusic.Position := volMusic;
      c_trackBar_volumeSample.Position := volSample;
      c_trackBar_volumeStream.Position := volStream;
    end;
    //
    c_trackBar_volumeMaster.position := f_bass.get_volume();
  end;
end;

// --  --
procedure Tc_form_main.a_bass_libInitExecute(Sender: TObject);
var
  flags: DWORD;
  index: int;
begin
  if (nil <> f_bass) then begin
    //
    flags := 0;
    if (c_checkListBox_initFlags.Checked[0]) then
      flags := flags or BASS_DEVICE_8BITS;
    if (c_checkListBox_initFlags.Checked[1]) then
      flags := flags or BASS_DEVICE_MONO;
    if (c_checkListBox_initFlags.Checked[2]) then
      flags := flags or BASS_DEVICE_3D;
    if (c_checkListBox_initFlags.Checked[3]) then
      flags := flags or BASS_DEVICE_LEAVEVOL;
    if (c_checkListBox_initFlags.Checked[4]) then
      flags := flags or BASS_DEVICE_LATENCY;
    //
    index := c_comboBox_deviceId.itemIndex;
    if (0 <= index) then
      index := unsigned(c_comboBox_deviceId.items.objects[index]) - $1000
    else
      index := 0;
    //
    f_bass.initialize(index, str2intInt(c_edit_playbackFreq.text, 44100), flags, handle, true);
    displayBassInfo();
    //
    a_bass_actStart.execute();
  end;
end;

// --  --
procedure Tc_form_main.a_bass_libInfoUpdateExecute(Sender: TObject);
begin
  displayBassInfo();
end;

// --  --
procedure Tc_form_main.updateInitParams();
var
  i: integer;
  d: string;
begin
  c_comboBox_deviceId.items.clear();
  //
  if (nil <> f_bass) then begin
{$IFDEF BASS_AFTER_18 }
    // fucked up in 2.0
    i := 1;
{$ELSE }
    i := 0;
{$ENDIF BASS_AFTER_18 }
    repeat
      d := string(f_bass.get_deviceDescription(i));
      if ('' <> d) then
	c_comboBox_deviceId.items.addObject(d, pointer($1000 + i))
      else
	break;
      //
      inc(i);
    until (false);
    //
    c_comboBox_deviceId.itemIndex := 0;
  end;
end;

// --  --
procedure Tc_form_main.c_trackBar_volumeMusicChange(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.set_globalVolumes(c_trackBar_volumeMusic.Position, -1, -1);
end;

// --  --
procedure Tc_form_main.c_trackBar_volumeSampleChange(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.set_globalVolumes(-1, c_trackBar_volumeSample.Position, -1);
end;

// --  --
procedure Tc_form_main.c_trackBar_volumeStreamChange(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.set_globalVolumes(-1, -1, c_trackBar_volumeStream.Position);
end;

// --  --
procedure Tc_form_main.c_trackBar_volumeMasterChange(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.set_volume(c_trackBar_volumeMaster.Position);
end;

// --  --
procedure Tc_form_main.a_bass_actStopExecute(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.stop();
end;

// --  --
procedure Tc_form_main.a_bass_actStartExecute(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.start();
end;

// --  --
procedure Tc_form_main.a_bass_actPauseExecute(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.pause();
end;

//=============== Music ===================

// --  --
function Tc_form_main.getMusicFlags(): DWORD;
begin
  result := 0;
  with (c_checkListBox_musicFlags) do begin
    //
    if (checked[0]) then
      result := result or BASS_MUSIC_LOOP;
    if (checked[1]) then
      result := result or BASS_MUSIC_RAMP;
    if (checked[2]) then
      result := result or BASS_MUSIC_RAMPS;
    if (checked[3]) then
      result := result or BASS_MUSIC_FT2MOD;
    if (checked[4]) then
      result := result or BASS_MUSIC_PT1MOD;
    if (checked[5]) then
      result := result or BASS_MUSIC_MONO;
    if (checked[6]) then
      result := result or BASS_MUSIC_3D;
    if (checked[7]) then
      result := result or BASS_MUSIC_POSRESET;
    if (checked[8]) then
      result := result or BASS_MUSIC_SURROUND;
    if (checked[9]) then
      result := result or BASS_MUSIC_SURROUND2;
    if (checked[10]) then
      result := result or BASS_MUSIC_STOPBACK;
    if (checked[11]) then
      result := result or BASS_MUSIC_FX;
    if (checked[12]) then
      result := result or BASS_MUSIC_CALCLEN;
  end;
end;

// --  --
procedure Tc_form_main.a_bass_musicLoadExecute(Sender: TObject);
var
  flags: DWORD;
  name: string;
  music: unaBassMusic;
begin
  if ((nil <> f_bass) and fileExists(c_edit_musicFile.text)) then begin
    //
    // try to add new music module
    flags := getMusicFlags();
    music := unaBassMusic.create(f_bass);
    music.load(c_edit_musicFile.text, 0, 0, flags);
    if (0 <> music.handle) then begin
      //
      name := string(music.get_name());
      if (1 > length(name)) then
	name := '[ Untitled ]';
      //
      c_listBox_musicModules.itemIndex := c_listBox_musicModules.items.addObject(name, pointer(music));
      updateMusicInfo(true);
    end
    else begin
      freeAndNil(music);
      showMessage('Unable to load music file, error code=' + int2str(f_bass.get_errorCode()));
    end;
  end;
end;

// --  --
procedure Tc_form_main.a_bass_musicLoadMemExecute(Sender: TObject);
var
  res: unaResourceStream;
  flags: DWORD;
  music: unaBassMusic;
  name: string;
begin
  if (nil <> f_bass) then begin
    //
    res := unaResourceStream.createRes('MEMMUSIC');
    try
      if (nil <> res.data) then begin
	// try to add new music module
	flags := getMusicFlags();
	music := unaBassMusic.create(f_bass);
	music.load(res.data, res.getAvailableSize(), flags);
	if (0 <> music.handle) then begin
	  //
	  name := string(music.get_name());
	  if (1 > length(name)) then
	    name := '[ Untitled ]';
	  //
	  c_listBox_musicModules.itemIndex := c_listBox_musicModules.items.addObject(name, pointer(music));
	  updateMusicInfo(true);
	  //
	  showMessage('MOD Tracker module courtesy of Stilgar.');
	end
	else begin
	  freeAndNil(music);
	  showMessage('Unable to load music, error code=' + int2str(f_bass.get_errorCode()));
	end;
      end
      else
	showMessage('Unable to locate resource.');
    finally
      freeAndNil(res);
    end;
  end;  
end;

// --  --
procedure Tc_form_main.a_file_browseMusicExecute(Sender: TObject);
begin
  if (c_openDialog_music.execute()) then
    c_edit_musicFile.text := c_openDialog_music.fileName;
end;

// --  --
procedure Tc_form_main.c_edit_musicFileChange(Sender: TObject);
begin
  a_bass_musicLoad.Enabled := fileExists(c_edit_musicFile.text);
end;

// --  --
function Tc_form_main.getSelectedMusic(): unaBassMusic;
begin

  if ((nil <> f_bass) and (LB_ERR <> sendMessage(c_listBox_musicModules.handle, LB_GETCURSEL, 0, 0))) then
    result := unaBassMusic(c_listBox_musicModules.items.objects[c_listBox_musicModules.itemIndex])
  else
    result := nil;
end;

// --  --
procedure Tc_form_main.a_bass_musicPlayExecute(Sender: TObject);
var
  music: unaBassMusic;
  flags: DWORD;
begin
  music := getSelectedMusic();
  if (nil <> music) then begin
    //
    music.preBuf();
    flags := getMusicFlags();
    if (music.playEx(0, 0, flags, true)) then
      // OK
    else
      showMessage('PlayEx() fails, error code=' + int2str(f_bass.get_errorCode()));
  end;
end;

// --  --
procedure Tc_form_main.a_bass_musicStopExecute(Sender: TObject);
var
  music: unaBassMusic;
begin
  music := getSelectedMusic();
  if (nil <> music) then
    music.asChannel.stop();
end;

// --  --
procedure Tc_form_main.a_bass_musicUnloadExecute(Sender: TObject);
var
  music: unaBassMusic;
begin
  music := getSelectedMusic();
  if (nil <> music) then begin
    freeAndNil(music);
    c_listBox_musicModules.items.delete(c_listBox_musicModules.itemIndex);
    updateMusicInfo();
  end;
end;

// --  --
procedure Tc_form_main.updateMusicInfo(rescanChannels: bool);
var
  music: unaBassMusic;
  pos: QWORD;
  i: unsigned;
  channel: unsigned;
begin
  f_noChangeTrack := true;
  //
  music := getSelectedMusic();
  if (nil <> music) then begin
    // module
    c_label_musicLen.caption := 'Length: ' + floatToStrF(music.bytes2seconds(music.get_length()), ffFixed, 8, 2) + ' sec.';
{$IFDEF BASS_AFTER_21 }
      // fucked in 2.2
    c_trackBar_musicPos.max := trunc(music.bytes2seconds(music.get_length(true)));
{$ELSE }
    c_trackBar_musicPos.max := (music.get_length(false) and $FFFF);
{$ENDIF }
    //
    pos := music.asChannel.get_position(true);
    if (0 <= pos) then begin
      //
      c_label_musicPos.caption := 'Order: ' + int2str(pos and $FFFF) + '   Row: ' + int2str(pos shr 16);
{$IFDEF BASS_AFTER_21 }
      c_trackBar_musicPos.position := trunc(music.bytes2seconds(music.asChannel.get_position(false)));
{$ELSE }
      // fucked in 2.2
      c_trackBar_musicPos.position := (music.asChannel.get_position(false) and $FFFF);
{$ENDIF }
      c_trackBar_musicPos.enabled := true;
    end
    else begin
      //
      c_label_musicPos.caption := 'Order: 0   Row: 0';
      c_trackBar_musicPos.position := 0;
      c_trackBar_musicPos.enabled := false;
    end;
    //
    c_trackBar_musicAmp.position := music.get_ampLevel();
    c_trackBar_musicPan.position := music.get_panSeparation();
    c_trackBar_musicAmp.enabled := true;
    c_trackBar_musicPan.enabled := true;
    //
    // channels
    if (rescanChannels) then begin
      //
      c_comboBox_musicChannel.clear();
      i := 0;
      while (0 < music.get_channelVol(i)) do begin
	c_comboBox_musicChannel.items.add(int2str(i));
	//
	inc(i);
      end;
      //
      c_comboBox_musicChannel.itemIndex := 0;
    end;
    //
    if (0 <= c_comboBox_musicChannel.itemIndex) then begin
      //
      channel := c_comboBox_musicChannel.itemIndex;
      c_trackBar_musicChannelVolume.position := music.get_channelVol(channel);
      c_trackBar_musicChannelVolume.enabled := true;
    end
    else begin
      //
      c_trackBar_musicChannelVolume.position := 0;
      c_trackBar_musicChannelVolume.enabled := false;
    end;
    //
    a_bass_musicPlay.Enabled := true;
    a_bass_musicStop.Enabled := true;
    a_bass_musicUnload.Enabled := true;
  end
  else begin
    // no module
    c_label_musicLen.Caption := 'Length: 0.00 sec.';
    c_label_musicPos.caption := 'Order: 0   Row: 0';
    //
    c_trackBar_musicAmp.position := 0;
    c_trackBar_musicPan.position := 0;
    c_trackBar_musicPos.position := 0;
    c_trackBar_musicAmp.enabled := false;
    c_trackBar_musicPan.enabled := false;
    c_trackBar_musicPos.enabled := false;
    //
    // channels
    c_comboBox_musicChannel.clear();
    c_trackBar_musicChannelVolume.position := 0;
    c_trackBar_musicChannelVolume.enabled := false;
    //
    a_bass_musicPlay.Enabled := false;
    a_bass_musicStop.Enabled := false;
    a_bass_musicUnload.Enabled := false;
  end;
  //
  f_noChangeTrack := false;
end;

// --  --
procedure Tc_form_main.c_listBox_musicModulesClick(Sender: TObject);
begin
  updateMusicInfo(true);
end;

// --  --
procedure Tc_form_main.c_trackBar_musicAmpChange(Sender: TObject);
var
  music: unaBassMusic;
begin
  if (not f_noChangeTrack) then begin
    music := getSelectedMusic();
    if (nil <> music) then
      music.set_ampLevel(c_trackBar_musicAmp.position);
  end;    
end;

// --  --
procedure Tc_form_main.c_trackBar_musicPanChange(Sender: TObject);
var
  music: unaBassMusic;
begin
  if (not f_noChangeTrack) then begin
    music := getSelectedMusic();
    if (nil <> music) then
      music.set_panSeparation(c_trackBar_musicPan.position);
  end;    
end;

// --  --
procedure Tc_form_main.c_trackBar_musicChannelVolumeChange(Sender: TObject);
var
  music: unaBassMusic;
begin
  if (not f_noChangeTrack) then begin
    music := getSelectedMusic();
    if (nil <> music) then
      if (0 <= c_comboBox_musicChannel.itemIndex) then
	music.set_channelVol(c_comboBox_musicChannel.itemIndex, c_trackBar_musicChannelVolume.position);
  end;	
end;

// --  --
procedure Tc_form_main.c_trackBar_musicPosChange(Sender: TObject);
var
  music: unaBassMusic;
begin
  if (not f_noChangeTrack) then begin
    //
    music := getSelectedMusic();
    if (nil <> music) then
{$IFDEF BASS_AFTER_21 }
      // fucked in 2.2
      music.asChannel.set_position(music.seconds2bytes(c_trackBar_musicPos.position));
{$ELSE }
      music.asChannel.set_position(c_trackBar_musicPos.position and $FFFF, true);
{$ENDIF }
    //
  end;
end;

//=============== CD ===================

// --  --
procedure Tc_form_main.updateCDinfo();
var
  t: unsigned;
  c: int;
begin
  c_memo_cdInfo.clear();
  c_comboBox_cdTrack.clear();
  c_checkBox_cdInDrive.checked := false;
  //
  if ((nil <> f_bass) and (' ' <> f_cdDrive)) then begin
    //
    c := f_bass.cd_get_tracks();
    if ((0 <= c) and f_bass.cd_inDrive()) then begin
      //
      c_memo_cdInfo.lines.add(string('CDID_IDENTITY=' + f_bass.cd_get_ID(BASS_CDID_IDENTITY)));
      c_memo_cdInfo.lines.add(string('CDID_UPC=' + f_bass.cd_get_ID(BASS_CDID_UPC)));
      c_memo_cdInfo.lines.add(string('CDID_CDDB=' + f_bass.cd_get_ID(BASS_CDID_CDDB)));
      c_memo_cdInfo.lines.add(string('CDID_CDDB2=' + f_bass.cd_get_ID(BASS_CDID_CDDB2)));
      c_memo_cdInfo.lines.add('-------');
      c_memo_cdInfo.lines.add('Track count=' + int2str(c));
    end
    else
      c_memo_cdInfo.lines.add('<no disc in drive>');
    //
    c_checkBox_cdInDrive.checked := f_bass.cd_inDrive();
    //
    if (f_bass.cd_inDrive()) then begin
      //
      for t := 1 to c do
	c_comboBox_cdTrack.items.add(int2str(t));
    end;
  end;
end;

// --  --
procedure Tc_form_main.c_button_updateCDinfoClick(Sender: TObject);
begin
  updateCDinfo();
end;

// --  --
procedure Tc_form_main.enumCD();
var
  volume: string;
  d: char;
begin
  c_comboBox_cdDrive.clear();
  f_cdDrive := ' ';
  //
  volume := 'x:\';
  for d := 'A' to 'Z' do begin
    volume[1] := d;
    if (DRIVE_CDROM = Windows.GetDriveType(pChar(volume))) then
      c_comboBox_cdDrive.items.add(volume);
  end;
  //
  if (0 < c_comboBox_cdDrive.items.count) then begin
    c_comboBox_cdDrive.itemIndex := 0;
    //a_bass_cdInit.Execute();
    c_comboBox_cdDriveChange(nil);
  end
  else begin
    a_bass_cdInit.Enabled := false;
    a_bass_cdFree.Enabled := false;
  end;
end;

// --  --
procedure Tc_form_main.a_bass_cdInitExecute(Sender: TObject);
begin
  if (nil <> f_bass) then begin
    //
    if (' ' <> f_cdDrive) then
      f_bass.cd_free();
    //
    f_cdDrive := getSelectedCDDrive();
    if (' ' <> f_cdDrive) then
      if (not f_bass.cd_init(f_cdDrive, 0)) then begin
	showMessage('CD_Init() for drive ' + f_cdDrive + ':\ fails, error code=' + int2str(f_bass.get_errorCode()));
	f_cdDrive := ' ';
      end;
    //
    updateCDinfo();	
    //
    c_comboBox_cdDriveChange(sender);
  end;
end;

// --  --
procedure Tc_form_main.a_bass_cdFreeExecute(Sender: TObject);
begin
  if (nil <> f_bass) then begin
    //
    if (' ' <> f_cdDrive) then
      f_bass.cd_free();
  end;
  //
  f_cdDrive := ' ';
  c_comboBox_cdDriveChange(sender);
  //
  updateCDinfo();
end;

// --  --
procedure Tc_form_main.c_comboBox_cdDriveChange(Sender: TObject);
var
  newDrive: char;
begin
  newDrive := getSelectedCDDrive();
  a_bass_cdInit.Enabled := (newDrive <> f_cdDrive);
  a_bass_cdFree.Enabled := not a_bass_cdInit.Enabled;
  //
  c_label_cdDrive.caption := 'Initialized CD Drive: ' + f_cdDrive;
end;

// --  --
function Tc_form_main.getSelectedCDDrive(): char;
var
  drive: string;
begin
  result := ' ';
  //
  if (0 <= c_comboBox_cdDrive.itemIndex) then begin
    drive := c_comboBox_cdDrive.items[c_comboBox_cdDrive.itemIndex];
    if (1 < length(drive)) then
      result := drive[1];
  end;
end;

// --  --
procedure Tc_form_main.a_bass_cdDoorOpenExecute(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.cd_door(true);
end;

// --  --
procedure Tc_form_main.a_bass_cdDoorCloseExecute(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.cd_door(false);
end;

// --  --
procedure Tc_form_main.a_bass_cdTrackPlayExecute(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.cd_play(c_comboBox_cdTrack.itemIndex + 1, c_checkBox_cdTrackPlayLoop.checked, false);
end;

// --  --
procedure Tc_form_main.a_bass_cdTrackStopExecute(Sender: TObject);
begin
  if (nil <> f_bass) then
    f_bass.cd_stop();
end;

// ================= FILE STREAM =================

// --  --
procedure Tc_form_main.a_bass_streamBrowseExecute(Sender: TObject);
begin
  if (c_openDialog_stream.execute()) then
    c_edit_streamPath.Text := c_openDialog_stream.fileName;
end;

// --  --
function Tc_form_main.getStreamFlags(): DWORD;
begin
  result := 0;
  with (c_checkListBox_streamFlags) do begin
    //
    if (checked[0]) then
      result := result or BASS_SAMPLE_3D;
    if (checked[1]) then
      result := result or BASS_SAMPLE_MONO;
    if (checked[2]) then
      result := result or BASS_SAMPLE_LOOP;
    if (checked[3]) then
      result := result or BASS_SAMPLE_FX;
    if (checked[4]) then
      result := result or BASS_MP3_HALFRATE;
    if (checked[5]) then
      result := result or BASS_MP3_SETPOS;
  end;
end;

// --  --
function Tc_form_main.getSelectedStream(): unaBassStream;
begin
  if ((nil <> f_bass) and (LB_ERR <> sendMessage(c_listBox_streamModules.handle, LB_GETCURSEL, 0, 0))) then
    result := unaBassStream(c_listBox_streamModules.items.objects[c_listBox_streamModules.itemIndex])
  else
    result := nil;
end;

// --  --
procedure Tc_form_main.updateStreamInfo();
var
  stream: unaBassStream;
  len: int64;
  pos: int64;
begin
  f_noChangeTrack := true;
  //
  stream := getSelectedStream();
  if (nil <> stream) then begin
    // stream
    len := stream.get_length();
    c_label_streamLength.caption := 'Length: ' + floatToStrF(stream.bytes2seconds(len), ffFixed, 8, 2) + ' sec.';
    //
    pos := stream.asChannel.get_position();
    if (0 <= pos) then begin
      //
      c_label_streamPos.caption := 'Position: ' + floatToStrF(stream.bytes2seconds(pos), ffFixed, 8, 2) + ' sec.';
      c_trackBar_streamPos.position := percent(pos, len);
      c_trackBar_streamPos.enabled := true;
    end
    else begin
      //
      c_label_streamPos.caption := 'Position: 0.00 sec.';
      c_trackBar_streamPos.position := 0;
      c_trackBar_streamPos.enabled := false;
    end;
    //
    a_bass_streamPlay.Enabled := true;
    a_bass_streamStop.Enabled := true;
    a_bass_streamUnload.Enabled := true;
  end
  else begin
    // no stream
    c_label_streamLength.Caption := 'Length: 0.00 sec.';
    c_label_streamPos.caption := 'Position: 0.00 sec.';
    //
    c_trackBar_streamPos.position := 0;
    c_trackBar_streamPos.enabled := false;
    //
    a_bass_streamPlay.Enabled := false;
    a_bass_streamStop.Enabled := false;
    a_bass_streamUnload.Enabled := false;
  end;
  //
  f_noChangeTrack := false;
end;

// --  --
procedure Tc_form_main.c_edit_streamPathChange(Sender: TObject);
begin
  a_bass_streamLoad.Enabled := fileExists(c_edit_streamPath.text);
end;

// --  --
procedure Tc_form_main.a_bass_streamLoadExecute(Sender: TObject);
var
  flags: DWORD;
  stream: unaBassStream;
begin
  if ((nil <> f_bass) and fileExists(c_edit_streamPath.text)) then begin
    // try to add new stream
    flags := getStreamFlags();
    stream := unaBassStream.create(f_bass);
    stream.createStream(c_edit_streamPath.text, 0, 0, flags);
    if (0 <> stream.handle) then begin
      c_listBox_streamModules.itemIndex := c_listBox_streamModules.items.addObject(c_edit_streamPath.text, pointer(stream));
      updateStreamInfo();
    end
    else begin
      freeAndNil(stream);
      showMessage('Unable to load stream file, error code=' + int2str(f_bass.get_errorCode()));
    end;
  end;
end;

// --  --
procedure Tc_form_main.a_bass_streamLoadMemExecute(Sender: TObject);
var
  res: unaResourceStream;
  flags: DWORD;
  stream: unaBassStream;
begin
  if (nil <> f_bass) then begin
    res := unaResourceStream.createRes('MEMSTREAM');
    try
      if (nil <> res.data) then begin
	// try to add new stream
	flags := getStreamFlags();
	stream := unaBassStream.create(f_bass);
	stream.createStream(res.data, res.getAvailableSize(), flags);
	if (0 <> stream.handle) then begin
	  //
	  c_listBox_streamModules.itemIndex := c_listBox_streamModules.items.addObject('<stream from memory>', pointer(stream));
	  updateStreamInfo();
	  //
	  showMessage('Music courtesy of Mystic Circle.');
	end
	else begin
	  freeAndNil(stream);
	  showMessage('Unable to load stream, error code=' + int2str(f_bass.get_errorCode()));
	end;
      end
      else
	showMessage('Unable to locate resource.');
    finally
      freeAndNil(res);
    end;
  end;  
end;

// --  --
procedure Tc_form_main.a_bass_streamPlayExecute(Sender: TObject);
var
  stream: unaBassStream;
  flags: DWORD;
begin
  stream := getSelectedStream();
  if (nil <> stream) then begin
    stream.preBuf();
    flags := getStreamFlags();
    if (stream.play(not c_checkListBox_streamFlags.checked[6], flags)) then
      // OK
    else
      showMessage('PlayEx() fails, error code=' + int2str(f_bass.get_errorCode()));
  end;
end;

// --  --
procedure Tc_form_main.a_bass_streamStopExecute(Sender: TObject);
var
  stream: unaBassStream;
begin
  stream := getSelectedStream();
  if (nil <> stream) then
    stream.asChannel.stop();
end;

// --  --
procedure Tc_form_main.a_bass_streamUnloadExecute(Sender: TObject);
var
  stream: unaBassStream;
begin
  stream := getSelectedStream();
  if (nil <> stream) then begin
    //
    freeAndNil(stream);
    c_listBox_streamModules.items.delete(c_listBox_streamModules.itemIndex);
    updateStreamInfo();
  end;
end;

// --  --
procedure Tc_form_main.c_listBox_streamModulesClick(Sender: TObject);
begin
  updateStreamInfo();
end;

// --  --
procedure Tc_form_main.c_trackBar_streamPosChange(Sender: TObject);
var
  stream: unaBassStream;
begin
  if (not f_noChangeTrack) then begin
    //
    stream := getSelectedStream();
    if (nil <> stream) then
{$IFDEF BASS_AFTER_21 }
      // fucked in 2.2
      stream.asChannel.set_position(stream.get_length() * c_trackBar_streamPos.position div 100);
{$ELSE }
      stream.asChannel.set_position(stream.get_length() * c_trackBar_streamPos.position div 100, true);
{$ENDIF }
  end;
end;

// --  --
procedure Tc_form_main.Exit1Click(Sender: TObject);
begin
  close();
end;


end.

