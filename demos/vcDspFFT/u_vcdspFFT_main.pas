
(*
	----------------------------------------------

	  u_vcdspFFT_main.pas
	  FFT Demo application - main form source

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, ?? 2003

	  modified by:
		Lake, ??-Dec 2003
		Lake, Oct 2005
		Lake, Oct 2011

	----------------------------------------------
*)

{$I unaDef.inc }

unit
  u_vcdspFFT_main;

interface

uses
  Windows, unaTypes, Messages, Forms,
  unaVcIDE, Classes, Controls, unaDspControls, StdCtrls, ComCtrls, Menus,
  ExtCtrls, unaVC_pipe, unaVC_wave;

type
  Tc_form_main = class(TForm)
    waveIn: TunavclWaveInDevice;
    c_statusBar_main: TStatusBar;
    Label4: TLabel;
    Label1: TLabel;
    fft_right_top: TunadspFFTControl;
    c_cb_rightTop: TCheckBox;
    fft_right_wide: TunadspFFTControl;
    c_cb_rightWide: TCheckBox;
    c_cb_left: TCheckBox;
    Label3: TLabel;
    c_mm_main: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    fft_left_small: TunadspFFTControl;
    fft_right_big: TunadspFFTControl;
    c_cb_rightBig: TCheckBox;
    Label2: TLabel;
    c_cb_dstyle: TComboBox;
    c_cb_grid: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure c_cb_leftClick(Sender: TObject);
    procedure c_cb_rightTopClick(Sender: TObject);
    procedure c_cb_rightWideClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure c_cb_rightBigClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure c_cb_dstyleChange(Sender: TObject);
    procedure c_cb_gridClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  c_form_main: Tc_form_main;


implementation


uses
  unaUtils,
  ShellAPI;

{$R *.dfm}

// --  --
procedure Tc_form_main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  wavein.close();
  //
  fft_left_small.fft.close();
  fft_right_top.fft.close();
  fft_right_wide.fft.close();
  fft_right_big.fft.close();
end;

// --  --
procedure Tc_form_main.FormCreate(Sender: TObject);
begin
  c_cb_left.checked := true;
  c_cb_rightTop.checked := true;
  c_cb_rightWide.checked := true;
  c_cb_rightBig.checked := true;
  //
  {$IFDEF __AFTER_D7__ }
  doubleBuffered := True;
  {$ENDIF __AFTER_D7__ }
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  shellExecute(handle, 'open', 'http://lakeofsoft.com/vc/a_fbands.html', nil, nil, SW_SHOWNORMAL);
end;

// --  --
procedure Tc_form_main.c_cb_dstyleChange(Sender: TObject);
var
  s: TunadspFFTDrawStype;
begin
  s := TunadspFFTDrawStype(c_cb_dstyle.itemIndex);
  //
  fft_left_small.drawStyle := s;
  fft_right_top.drawStyle := s;
  fft_right_wide.drawStyle := s;
  fft_right_big.drawStyle := s;
end;

// --  --
procedure Tc_form_main.c_cb_gridClick(Sender: TObject);
begin
  fft_left_small.drawGrid := c_cb_grid.Checked;
  fft_right_top.drawGrid := c_cb_grid.Checked;
  fft_right_wide.drawGrid := c_cb_grid.Checked;
  fft_right_big.drawGrid := c_cb_grid.Checked;
end;

// --  --
procedure Tc_form_main.c_cb_leftClick(Sender: TObject);
begin
  if (c_cb_left.checked) then
    waveIn.addConsumer(fft_left_small.fft)
  else begin
    //
    waveIn.removeConsumer(fft_left_small.fft);
    fft_left_small.fft.close();
  end;
end;

// --  --
procedure Tc_form_main.c_cb_rightTopClick(Sender: TObject);
begin
  if (c_cb_rightTop.checked) then
    waveIn.addConsumer(fft_right_top.fft)
  else begin
    //
    waveIn.removeConsumer(fft_right_top.fft);
    fft_right_top.fft.close();
  end;
end;

// --  --
procedure Tc_form_main.c_cb_rightWideClick(Sender: TObject);
begin
  if (c_cb_rightWide.checked) then
    waveIn.addConsumer(fft_right_wide.fft)
  else begin
    //
    waveIn.removeConsumer(fft_right_wide.fft);
    fft_right_wide.fft.close();
  end;
end;

// --  --
procedure Tc_form_main.c_cb_rightBigClick(Sender: TObject);
begin
  if (c_cb_rightBig.checked) then
    waveIn.addConsumer(fft_right_big.fft)
  else begin
    //
    waveIn.removeConsumer(fft_right_big.fft);
    fft_right_big.fft.close();
  end;
end;

// --  --
procedure Tc_form_main.Exit1Click(Sender: TObject);
begin
  close();
end;


end.

