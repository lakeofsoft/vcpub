
(*
	----------------------------------------------

	  vcTalkNow.dpr
	  vcTalkNow demo application - project source

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, ?? Jun 2002

	  modified by:
		Lake, Jun-Dec 2002
		Lake, Jan-May 2003
		Lake, Aug 2005

	----------------------------------------------
*)

{$I unaDef.inc }

program
  vcTalkNow;

uses
  Forms,
  unaUtils,
  u_vcTalkNow_main in 'u_vcTalkNow_main.pas' {c_form_main},
  u_common_audioConfig in '..\common\u_common_audioConfig.pas' {c_form_common_audioConfig},
  u_vcTalkNow_about in 'u_vcTalkNow_about.pas' {c_form_about};

{$R *.res}

// tell we are OK with XP themes
{$IFDEF __BEFORE_D7__ }
  {$R unaWindowsXP.res }	
{$ELSE }
  {$R WindowsXP.res }	
{$ENDIF __BEFORE_D7__ }

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 Pro - Talk now demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.CreateForm(Tc_form_common_audioConfig, c_form_common_audioConfig);
  Application.CreateForm(Tc_form_about, c_form_about);
  Application.Run;
end.

