
(*
	----------------------------------------------

	  vcDAF.dpr
	  Voice Communicator components version 2.5
	  Audio Feedback demo

	----------------------------------------------
	  Copyright (c) 2005-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 11 Aug 2005

	  modified by:
		Lake, Aug 2005
		Lake, May 2009

	----------------------------------------------
*)

{$I unaDef.inc }

program vcDAF;

uses
  Forms,
  u_daf_main in 'u_daf_main.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - DAF';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

