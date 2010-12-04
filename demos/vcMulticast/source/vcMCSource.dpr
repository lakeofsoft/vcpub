
(*
	----------------------------------------------

	  vcMCSource.dpr
	  vcMulticast Source demo application - project source

	----------------------------------------------
	  Copyright (c) 2005-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 01 Oct 2005

	  modified by:
		Lake, Oct 2005

	----------------------------------------------
*)

{$I unaDef.inc }

program
  vcMCSource;

uses
  Forms,
  u_vcMCsource_main in 'u_vcMCsource_main.pas' {c_form_main};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - Multicast Source demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.


