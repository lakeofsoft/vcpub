
(*
	----------------------------------------------

	  vcAECDemo.dpr - VC 2.5 Pro AEC Demo project
	  Voice Communicator components version 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2007-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 27 Sep 2007

	  modified by:
		Lake, Sep-Dec 2007
		Lake, Jan 2008

	----------------------------------------------
*)

{$I unaDef.inc }

program
  vcAECDemo;

uses
  Forms, ActiveX, ComObj,
  u_vcAECDemo_main in 'u_vcAECDemo_main.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  // This must be added, if AEC is to be started from non-main thread
  CoInitFlags := COINIT_MULTITHREADED;
  //
  Application.Initialize;
  Application.Title := 'VC25 - AEC Demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

