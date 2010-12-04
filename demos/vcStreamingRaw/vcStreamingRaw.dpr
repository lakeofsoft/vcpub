
(*
	----------------------------------------------

	  vcStreamingRaw.pas - VC 2.5 Pro RAW Streaming demo
	  Voice Communicator components version 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2006-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, Nov 2006

	  modified by:
		Lake, Apr 2007
                Lake, May 2009

	----------------------------------------------
*)

{$I unaDef.inc }

program
  vcStreamingRaw;

uses
  Forms,
  u_sr_mainpas in 'u_sr_mainpas.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - RAW streaming Demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

