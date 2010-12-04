
(*
	----------------------------------------------

	  u_pushBMP_main.dpr
	  Voice Communicator components version 2.5 Pro
	  pushBMP Demo application - main form source

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 10 Feb 2003

	  modified by:
		Lake, Oct 2003

	----------------------------------------------
*)

{$I unaDef.inc}

unit u_pushBMP_main;

interface

uses
  Windows, unaTypes, unaClasses, Forms, ExtCtrls, unaVcIDE, Controls, StdCtrls,
  CheckLst, Graphics, Classes, ComCtrls, Dialogs, Menus, unaVC_socks,
  unaVC_wave, unaVC_pipe;

type
  Tc_form_main = class(TForm)
    c_timer_update: TTimer;
    c_statusBar_main: TStatusBar;
    c_pageControl_main: TPageControl;
    c_tabSheet_cln: TTabSheet;
    c_tabSheet_srv: TTabSheet;
    c_label_srvInfo: TLabel;
    c_image_srvDest: TImage;
    c_button_srvStart: TButton;
    c_button_srvPush: TButton;
    c_button_srvStop: TButton;
    c_checkListBox_server: TCheckListBox;
    ipServer: TunavclIPInStream;
    codecOutServer: TunavclWaveCodecDevice;
    waveOutServer: TunavclWaveOutDevice;
    waveInServer: TunavclWaveInDevice;
    codecInServer: TunavclWaveCodecDevice;
    c_label_clnInfo: TLabel;
    c_image_clnDest: TImage;
    c_button_clnStart: TButton;
    c_button_clnPush: TButton;
    c_button_clnStop: TButton;
    c_checkListBox_client: TCheckListBox;
    ipClient: TunavclIPOutStream;
    waveInClient: TunavclWaveInDevice;
    codecInClient: TunavclWaveCodecDevice;
    codecOutClient: TunavclWaveCodecDevice;
    waveOutClient: TunavclWaveOutDevice;
    Bevel1: TBevel;
    Bevel2: TBevel;
    c_edit_srvPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    c_edit_clnPort: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    c_edit_clnServerAddr: TEdit;
    c_image_srvSource: TImage;
    c_image_clnSource: TImage;
    c_mm_main: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Label6: TLabel;
    Label7: TLabel;
    Help1: TMenuItem;
    About1: TMenuItem;
    //
    procedure formCreate(Sender: TObject);
    procedure formShow(Sender: TObject);
    procedure formDestroy(Sender: TObject);
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    //
    procedure c_button_clnStartClick(Sender: TObject);
    procedure c_button_srvStartClick(Sender: TObject);
    procedure c_button_clnStopClick(Sender: TObject);
    procedure c_button_srvStopClick(Sender: TObject);
    procedure c_timer_updateTimer(Sender: TObject);
    procedure c_button_srvPushClick(Sender: TObject);
    procedure c_button_clnPushClick(Sender: TObject);
    //
    procedure ipServerUserData(sender: tObject; connectionId: cardinal; data: pointer; len: cardinal);
    procedure ipClientUserData(sender: tObject; connectionId: cardinal; data: pointer; len: cardinal);
    procedure ipClientClientDisconnect(sender: TObject; connectionId: Cardinal; connected: LongBool);
    procedure ipServerServerClientDisconnect(sender: TObject;
      connectionId: Cardinal; connected: LongBool);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    f_ini: unaIniFile;
  public
    { Public declarations }
  end;

var
  c_form_main: Tc_form_main;


implementation


{$R *.dfm}

uses
  unaUtils, unaVCLUtils,
  ShellAPI;

// --  --
procedure Tc_form_main.formCreate(Sender: TObject);
begin
  f_ini := unaIniFile.create();
  //
  {$IFDEF DEBUG }
  {$ELSE }
  c_checkListBox_server.visible := false;
  c_checkListBox_client.visible := false;
  {$ENDIF }
end;

// --  --
procedure Tc_form_main.formShow(Sender: TObject);
begin
  loadControlPosition(self, f_ini);
  //
  c_edit_srvPort.text := f_ini.get('ip.srv.port', '17805');
  //c_comboBox_srvSocketType.itemIndex := f_ini.get('ip.srv.proto', int(1));
  //
  c_edit_clnPort.text := f_ini.get('ip.cln.port', '17805');
  c_edit_clnServerAddr.text := f_ini.get('ip.cln.serverAddr', '192.168.0.100');
  //c_comboBox_clnSocketType.itemIndex := f_ini.get('ip.cln.proto', int(1));
  //
  c_timer_update.enabled := true;
end;

// --  --
procedure Tc_form_main.formDestroy(Sender: TObject);
begin
  freeAndNil(f_ini);
end;

// --  --
procedure Tc_form_main.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  c_button_clnStopClick(self);
  c_button_srvStopClick(self);
  //
  c_timer_update.enabled := false;
  //
  with (f_ini) do begin
    //
    setValue('ip.srv.port', c_edit_srvPort.text);
    //setValue('ip.srv.proto', c_comboBox_srvSocketType.itemIndex);
    //
    setValue('ip.cln.port', c_edit_clnPort.text);
    setValue('ip.cln.serverAddr', c_edit_clnServerAddr.text);
    //setValue('ip.cln.proto', c_comboBox_clnSocketType.itemIndex);
  end;
  //
  saveControlPosition(self, f_ini);
end;

// --  --
procedure Tc_form_main.c_timer_updateTimer(Sender: TObject);
var
  active: bool;
begin
  //
  c_statusBar_main.panels[0].text := 'Mem: ' + int2str(ams() shr 10, 10, 3) + ' KB';
  //
  c_label_srvInfo.caption := 'Got/Sent: ' + int2str(ipServer.inPacketsCount, 10, 3) + '/' + int2str(ipServer.outPacketsCount, 10, 3) + ' packets';
  c_label_clnInfo.caption := 'Got/Sent: ' + int2str(ipClient.inPacketsCount, 10, 3) + '/' + int2str(ipClient.outPacketsCount, 10, 3) + ' packets';
  //
  {$IFDEF DEBUG }
  c_checkListBox_server.checked[0] := waveInServer.active;
  c_checkListBox_server.checked[1] := codecInServer.active;
  c_checkListBox_server.checked[2] := ipServer.active;
  c_checkListBox_server.checked[3] := codecOutServer.active;
  c_checkListBox_server.checked[4] := waveOutServer.active;
  //
  c_checkListBox_client.checked[0] := waveInClient.active;
  c_checkListBox_client.checked[1] := codecInClient.active;
  c_checkListBox_client.checked[2] := ipClient.active;
  c_checkListBox_client.checked[3] := codecOutClient.active;
  c_checkListBox_client.checked[4] := waveOutClient.active;
  {$ENDIF }
  //
  active := ipClient.active;
  c_button_clnStart.enabled := not active;
  c_button_clnStop.enabled := active;
  c_button_clnPush.enabled := active;
  //
  active := ipServer.active;
  c_button_srvStart.enabled := not active;
  c_button_srvStop.enabled := active;
  c_button_srvPush.enabled := (0 < ipServer.clientCount);
  //
end;

// --  --
procedure Tc_form_main.c_button_clnStartClick(Sender: TObject);
begin
  c_button_clnStart.enabled := false;
  //
  ipClient.proto := unapt_TCP; //tunavclProtoType(c_comboBox_clnSocketType.itemIndex);
  ipClient.port := c_edit_clnPort.text;
  ipClient.host := c_edit_clnServerAddr.text;
  //
  waveInClient.open();
end;

// --  --
procedure Tc_form_main.c_button_clnStopClick(Sender: TObject);
begin
  c_button_clnStop.enabled := false;
  //
  waveInClient.close();
end;

// --  --
procedure Tc_form_main.c_button_srvStartClick(Sender: TObject);
begin
  c_button_srvStart.enabled := false;
  //
  ipServer.proto := unapt_TCP; //tunavclProtoType(c_comboBox_srvSocketType.itemIndex);
  ipServer.port := c_edit_srvPort.text;
  //
  waveInServer.open();
end;

// --  --
procedure Tc_form_main.c_button_srvStopClick(Sender: TObject);
begin
  c_button_srvStop.enabled := false;
  //
  waveInServer.close();
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  shellExecute(handle, 'open', 'http://lakeofsoft.com/vc/a_pushdata.html', nil, nil, SW_SHOWNORMAL);
end;

// --  --
procedure Tc_form_main.c_button_clnPushClick(Sender: TObject);
var
  stream: tMemoryStream;
  res: tunaSendResult;
begin
  c_button_clnPush.enabled := false;
  //
  // push user data to server
  stream := tMemoryStream.create();
  try
    c_image_clnSource.picture.bitmap.saveToStream(stream);
    {

      NOTE:

      Although VC will care about re-packing big block into smaller ones,
      avoid sending more than 16 KB at a time. Create a loop and send
      smaller chunks one by one instead. Be also sure not to overload the
      bandwidth. For UDP data will be lost, for TCP there will be delays
      in real-time audio streaming.

      NOTE 2 (Jan 2008): no repacking will be done for UDP.

    }
    res := ipClient.sendData(0{does not matter}, stream.memory, stream.size);
    if (unasr_OK = res) then
      showMessage('Successfully sent ' + int2str(stream.size, 10, 3) + ' bytes.')
    else
      showMessage('Data could not be sent.');
    //
  finally
    stream.free();
  end;
end;

// --  --
procedure Tc_form_main.c_button_srvPushClick(Sender: TObject);
var
  stream: tMemoryStream;
  res: tunaSendResult;
begin
  c_button_srvPush.enabled := false;
  //
  // push user data to client
  stream := tMemoryStream.create();
  try
    c_image_srvSource.picture.bitmap.saveToStream(stream);
    {
      NOTE:

      Although VC will care about re-packing a big chunk into smaller ones,
      avoid sending more than 16 KB at a time. Create a loop and send
      smaller chunks one by one instead. Be also sure not to overload the
      bandwidth. For UDP data will be lost, for TCP there will be delays
      in real-time audio streaming.
    }
    res := ipServer.sendData(0{send to all clients}, stream.memory, stream.size);
    if (unasr_OK = res) then
      showMessage('Successfully sent ' + int2str(stream.size, 10, 3) + ' bytes.')
    else
      showMessage('Data could not be sent.');
    //
  finally
    stream.free();
  end;
end;

// --  --
procedure Tc_form_main.ipClientUserData(sender: tObject; connectionId: cardinal; data: pointer; len: cardinal);
var
  stream: tMemoryStream;
begin
  // assign new picture from server
  stream := tMemoryStream.create();
  try
    stream.write(data^, len);
    stream.position := 0;
    //
    c_image_clnDest.picture.bitmap.loadFromStream(stream);
  finally
    stream.free();
  end;
end;

// --  --
procedure Tc_form_main.ipServerUserData(sender: tObject; connectionId: cardinal; data: pointer; len: cardinal);
var
  stream: tMemoryStream;
begin
  // assign new picture from client
  stream := tMemoryStream.create();
  try
    stream.write(data^, len);
    stream.position := 0;
    //
    c_image_srvDest.picture.bitmap.loadFromStream(stream);
  finally
    stream.free();
  end;
end;

// --  --
procedure Tc_form_main.ipClientClientDisconnect(sender: TObject; connectionId: Cardinal; connected: LongBool);
begin
  waveInClient.close();
  // clear remote bitmap
  c_image_clnDest.picture.bitmap.handle := 0;
end;

// --  --
procedure Tc_form_main.ipServerServerClientDisconnect(sender: TObject; connectionId: Cardinal; connected: LongBool);
begin
  // clear remote bitmap
  c_image_srvDest.picture.bitmap.handle := 0;
end;

// --  --
procedure Tc_form_main.Exit1Click(Sender: TObject);
begin
  close();
end;


end.

