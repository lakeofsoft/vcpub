
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

program
  vcdspFFT;

uses
  Forms,
  u_vcdspFFT_main in 'u_vcdspFFT_main.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - FFT control demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

