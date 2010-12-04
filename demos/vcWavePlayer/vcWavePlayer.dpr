
(*
	----------------------------------------------

	  u_vcWavePlayer_main.pas
	  Voice Communicator components version 2.5 Pro
	  VC Wave Player Demo application - project source

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 23 Oct 2002

	  modified by:
		Lake, Oct 2002
		Lake, Feb-May 2003

	----------------------------------------------
*)

{$I unaDef.inc}

program
  vcWavePlayer;

uses
  Forms,
  u_vcWavePlayer_main in 'u_vcWavePlayer_main.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - WAVe player demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

