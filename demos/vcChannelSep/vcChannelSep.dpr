
(*
	----------------------------------------------

	  vcChannelSep.dpr
	  vcChannelSep demo application - project source

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 10 Jan 2003

	  modified by:
		Lake, Jan 2003

	----------------------------------------------
*)

{$I unaDef.inc}

program
  vcChannelSep;

uses
  Forms,
  u_channelSep_main in 'u_channelSep_main.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - PCM Channel Separation demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

