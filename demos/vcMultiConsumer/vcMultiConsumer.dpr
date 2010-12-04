
(*
	----------------------------------------------

	  u_mcDemo_main.pas - vcMultiClient demo main form source
	  VC 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2003-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 20 Oct 2003

	  modified by:
		Lake, Oct 2003
		Lake, Oct 2005

	----------------------------------------------
*)

{$I unaDef.inc }

program
  vcMultiConsumer;

uses
  Forms,
  u_mcDemo_main in 'u_mcDemo_main.pas' {c_form_main},
  u_common_audioConfig in '..\common\u_common_audioConfig.pas' {c_form_common_audioConfig},
  u_mcDemo_newConsumer in 'u_mcDemo_newConsumer.pas' {c_form_newConsumer};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - Multi-Consumer Demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.CreateForm(Tc_form_common_audioConfig, c_form_common_audioConfig);
  Application.CreateForm(Tc_form_newConsumer, c_form_newConsumer);
  Application.Run;
end.

