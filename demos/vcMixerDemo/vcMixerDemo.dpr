
(*
	----------------------------------------------

	  vcMixerDemo.dpr - MS system mixer demo application project source
	  Voice Communicator components version 2.5

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 10 Jun 2002

	  modified by:
		Lake, Aug-Dec 2002
		Lake, Feb-May 2003
		Lake, Oct 2005

	----------------------------------------------
*)

{$I unaDef.inc }

program
  vcMixerDemo;

uses
  Forms,
  u_vcMixerDemo_main in 'u_vcMixerDemo_main.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - System Mixer demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

