
(*
	----------------------------------------------

	  vcBASSDemo.dpr
	  vcBASSDemo demo application - project source

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 08 Jan 2003

	  modified by:
		Lake, Jan 2003
		Lake, Oct 2005
		Lake, Mar 2006
		Lake, May 2009

	----------------------------------------------
*)

{$I unaDef.inc }
{$I unaBassDef.inc }

program
  vcBASSDemo;

uses
  Forms,
  u_vcBASSDemo_main in 'u_vcBASSDemo_main.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

