
(*
	----------------------------------------------

	  vcAudioTunnel.dpr
	  Voice Communicator components version 2.5 Pro
	  VC Audio Tunnel application - project source

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 18 Dec 2003

	  modified by:
		Lake, Jan-Mar 2004

	----------------------------------------------
*)

{$I unaDef.inc }

program
  vcAudioTunnel;

uses
  Forms,
  u_vcAT_main in 'u_vcAT_main.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - Audio Tunnel Application';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

