
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
    fft_left_small: TunadspFFTControl;
    Label1: TLabel;
    fft_right_small: TunadspFFTControl;
    c_cb_right1: TCheckBox;
    Label2: TLabel;
    fft_right_wide: TunadspFFTControl;
    c_cb_right2: TCheckBox;
    fft_right_wide2: TunadspFFTControl;
    c_cb_right3: TCheckBox;
    c_cb_left: TCheckBox;
    Label3: TLabel;
    c_mm_main: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure c_cb_leftClick(Sender: TObject);
    procedure c_cb_right1Click(Sender: TObject);
    procedure c_cb_right2Click(Sender: TObject);
    procedure c_cb_right3Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
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
procedure Tc_form_main.FormCreate(Sender: TObject);
begin
  c_cb_left.checked := true;
  //c_cb_right1.checked := true;	// takes a lot of CPU
  c_cb_right2.checked := true;
  c_cb_right3.checked := true;
end;

// --  --
procedure Tc_form_main.About1Click(Sender: TObject);
begin
  shellExecute(handle, 'open', 'http://lakeofsoft.com/vc/a_fbands.html', nil, nil, SW_SHOWNORMAL);
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
procedure Tc_form_main.c_cb_right1Click(Sender: TObject);
begin
  if (c_cb_right1.checked) then
    waveIn.addConsumer(fft_right_small.fft)
  else begin
    //
    waveIn.removeConsumer(fft_right_small.fft);
    fft_right_small.fft.close();
  end;
end;

// --  --
procedure Tc_form_main.c_cb_right2Click(Sender: TObject);
begin
  if (c_cb_right2.checked) then
    waveIn.addConsumer(fft_right_wide.fft)
  else begin
    //
    waveIn.removeConsumer(fft_right_wide.fft);
    fft_right_wide.fft.close();
  end;
end;

// --  --
procedure Tc_form_main.c_cb_right3Click(Sender: TObject);
begin
  if (c_cb_right3.checked) then
    waveIn.addConsumer(fft_right_wide2.fft)
  else begin
    //
    waveIn.removeConsumer(fft_right_wide2.fft);
    fft_right_wide2.fft.close();
  end;
end;

// --  --
procedure Tc_form_main.Exit1Click(Sender: TObject);
begin
  close();
end;


end.

