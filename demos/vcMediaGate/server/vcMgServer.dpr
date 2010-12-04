
(*
	----------------------------------------------

	  u_mgServer_main.pas
	  MediaGate demo application - Server project source

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 04 Apr 2003

	  modified by:
		Lake, Apr-Oct 2003
		Lake, Apr 2007

	----------------------------------------------
*)

{$I unaDef.inc }

program
  vcMgServer;

uses
  Forms,
  u_mgServer_main in 'u_mgServer_main.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - Media Gate Demo / Server';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

