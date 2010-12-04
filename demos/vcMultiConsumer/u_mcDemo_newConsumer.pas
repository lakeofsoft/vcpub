
(*
	----------------------------------------------

	  u_mcDemo_main.pas - vcMultiClient demo main form source
	  VC 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 20 Oct 2003

	  modified by:
		Lake, Oct 2003
		Lake, Oct 2005

	----------------------------------------------
*)

{$I unaDef.inc }

unit
  u_mcDemo_newConsumer;

interface

uses
  Windows, unaTypes, Forms, unaVcIDE, unaVC_socks,
  ComCtrls, ExtCtrls, Controls, StdCtrls, Classes, Dialogs;

type
  Tc_form_newConsumer = class(TForm)
    c_comboBox_consumerType: TComboBox;
    Label1: TLabel;
    c_bevel_top: TBevel;
    c_pageControl_main: TPageControl;
    TabSheet1: TTabSheet;
    c_tabSheet_ipClient: TTabSheet;
    c_tabSheet_ipServer: TTabSheet;
    c_tabSheet_waveRiff: TTabSheet;
    c_button_OK: TButton;
    c_button_cancel: TButton;
    c_comboBox_waveOutDevId: TComboBox;
    c_label_waveOutDevId: TLabel;
    c_edit_clnServerAddr: TEdit;
    Label5: TLabel;
    c_comboBox_clnSocketType: TComboBox;
    Label3: TLabel;
    c_edit_clnPort: TEdit;
    Label4: TLabel;
    c_comboBox_srvSocketType: TComboBox;
    Label7: TLabel;
    c_edit_srvPort: TEdit;
    Label8: TLabel;
    c_label_waveRiff: TLabel;
    c_edit_waveRiffName: TEdit;
    c_button_waveRiffBrowse: TButton;
    c_saveDialog_waveRiff: TSaveDialog;
    TabSheet5: TTabSheet;
    c_edit_broadPort: TEdit;
    c_label_broadPort: TLabel;
    //
    procedure formCreate(sender: tObject);
    //
    procedure c_pageControl_mainChange(Sender: TObject);
    procedure c_comboBox_consumerTypeChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure c_button_waveRiffBrowseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    waveOutDeviceID: int;
    //
    port: string;
    host: string;
    proto: tunavclProtoType;
    //
    riffName: string;
    //
    function selectNewConsumer(out consumerIndex: int): bool;
  end;

var
  c_form_newConsumer: Tc_form_newConsumer;


implementation


{$R *.dfm}

uses
  MMSystem, unaVcIDEUtils, u_mcDemo_main;

// --  --
procedure Tc_form_newConsumer.formCreate(Sender: TObject);
begin
  enumWaveDevices(c_comboBox_waveOutDevId, false, true);
  //
  c_comboBox_clnSocketType.itemIndex := 1;
  c_comboBox_srvSocketType.itemIndex := 1;
  //
  c_comboBox_consumerType.itemIndex := 0;
{$IFDEF __AFTER_D4__ }
  c_pageControl_main.activePageIndex := 0;
{$ENDIF}
  //
end;

// --  --
procedure Tc_form_newConsumer.formShow(Sender: TObject);
begin
  with (c_form_main.config) do begin
    //
    c_comboBox_waveOutDevId.itemIndex := get('waveOut.deviceIndex', int(0));
    c_comboBox_clnSocketType.itemIndex := get('ip.client.proto', ord(unapt_UDP));
    c_edit_clnPort.text := get('ip.client.port', '17800');
    c_edit_clnServerAddr.text := get('ip.client.host', '192.168.1.1');
    //
    c_comboBox_srvSocketType.itemIndex := get('ip.server.proto', ord(unapt_UDP));
    c_edit_srvPort.text := get('ip.server.port', '17800');
    //
    //
    c_edit_broadPort.text := get('ip.broadcast.port', '17830');
    //
    c_edit_waveRiffName.text := get('riff.name', '');
  end;
end;

// --  --
function Tc_form_newConsumer.selectNewConsumer(out consumerIndex: int): bool;
begin
  result := (mrOK = showModal());
  //
  if (result) then begin
    //
    consumerIndex := c_comboBox_consumerType.itemIndex;
    //
    //
    case (consumerIndex) of

      0: begin	// waveOut
	waveOutDeviceID := index2deviceId(c_comboBox_waveOutDevId);
      end;

      1: begin	// waveRiff
	riffName := c_edit_waveRiffName.text;
      end;

      2: begin	// ipClient
	host := c_edit_clnServerAddr.text;
	port := c_edit_clnPort.text;
	proto := tunavclProtoType(c_comboBox_clnSocketType.itemIndex);
      end;

      3: begin	// ipServer
	port := c_edit_srvPort.text;
	proto := tunavclProtoType(c_comboBox_srvSocketType.itemIndex);
      end;

      4: begin	// ipBroadcast
	port := c_edit_broadPort.text;
      end;

    end;
    //
    with (c_form_main.config) do begin
      //
      setValue('waveOut.deviceIndex', c_comboBox_waveOutDevId.itemIndex);
      setValue('ip.client.proto', c_comboBox_clnSocketType.itemIndex);
      setValue('ip.client.port', c_edit_clnPort.text);
      setValue('ip.client.host', c_edit_clnServerAddr.text);
      //
      setValue('ip.server.proto', c_comboBox_srvSocketType.itemIndex);
      setValue('ip.server.port', c_edit_srvPort.text);
      //
      setValue('ip.broadcast.port', c_edit_broadPort.text);
      //
      setValue('riff.name', c_edit_waveRiffName.text);
    end;
  end;
end;

// --  --
procedure Tc_form_newConsumer.c_pageControl_mainChange(Sender: TObject);
begin
  c_comboBox_consumerType.itemIndex := c_pageControl_main.activePage.pageIndex;
end;

// --  --
procedure Tc_form_newConsumer.c_comboBox_consumerTypeChange(Sender: TObject);
begin
{$IFDEF __AFTER_D4__ }
  if (c_pageControl_main.activePageIndex <> c_comboBox_consumerType.itemIndex) then
    c_pageControl_main.activePageIndex := c_comboBox_consumerType.itemIndex;
{$ELSE }
  // do something for D4, too lazy now
{$ENDIF }
end;

// --  --
procedure Tc_form_newConsumer.c_button_waveRiffBrowseClick(sender: tObject);
begin
  if (c_saveDialog_waveRiff.execute()) then begin
    //
    c_edit_waveRiffName.text := c_saveDialog_waveRiff.fileName;
  end;
end;

end.

