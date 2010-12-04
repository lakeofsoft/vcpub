
(*
	----------------------------------------------

	  vcSampler.dpr
	  Voice Communicator components version 2.5
	  VC Sampler demo application

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, May 2002

	  modified by:
		Lake, May-Dec 2002
		Lake, Feb-May 2003
		Lake, Oct 2005

	----------------------------------------------
*)

{$I unaDef.inc}

program
  vcSampler;

uses
  Forms,
  u_vc2Demo_Main in 'u_vc2Demo_Main.pas' {c_form_vc2DemoMain},
  u_vc2Demo_playChannel in 'u_vc2Demo_playChannel.pas' {c_form_playbackChannel};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - Audio sampler demo';
  Application.CreateForm(Tc_form_vc2DemoMain, c_form_vc2DemoMain);
  Application.Run;
end.

