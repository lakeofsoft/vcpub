
(*
	----------------------------------------------

	  vcMp3Demo.dpr
	  Voice Communicator components version 2.5 Pro
	  MP3/Ogg Streaming Demo application - project source

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 21 Oct 2002

	  modified by:
		Lake, Oct 2002
		Lake, Jan-May 2003

	----------------------------------------------
*)

{$I unaDef.inc}

program vcMp3Demo;

uses
  Forms,
  u_vcmp3Demo_main in 'u_vcmp3Demo_main.pas' {c_form_main},
  u_vcmp3Demo_about in 'u_vcmp3Demo_about.pas' {c_form_about};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - MP3/Ogg Streaming Demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.CreateForm(Tc_form_about, c_form_about);
  Application.Run;
end.

