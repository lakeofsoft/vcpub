
(*
	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 04 Jul 2003

	  modified by:
		Lake, Jul 2003
		Lake, Oct 2005

	----------------------------------------------
*)

{$I unaDef.inc}

program
  vcSoundRec;

uses
  Forms,
  u_vcSR_main in 'u_vcSR_main.pas' {c_form_main},
  u_vcSR_format in 'u_vcSR_format.pas' {c_form_format};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - Sound Record Demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.CreateForm(Tc_form_format, c_form_format);
  Application.Run;
end.
