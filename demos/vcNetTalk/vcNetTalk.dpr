
(*
	----------------------------------------------

	  vcNetTalk.dpr
	  Voice Communicator components version 2.5 Pro
	  VC NetTalk demo application

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 01 Jun 2002

	  modified by:
		Lake, Jun-Dec 2002
		Lake, Jan-May 2003

	----------------------------------------------
*)

{$I unaDef.inc}

program vcNetTalk;

uses
  Forms,
  u_vcNetTalk_main in 'u_vcNetTalk_main.pas' {c_form_vcNetTalkMain},
  u_common_audioConfig in '..\common\u_common_audioConfig.pas' {c_form_common_audioConfig};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - Net Talk Demo';
  Application.CreateForm(Tc_form_vcNetTalkMain, c_form_vcNetTalkMain);
  Application.CreateForm(Tc_form_common_audioConfig, c_form_common_audioConfig);
  Application.Run;
end.

