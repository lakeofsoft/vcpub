
(*
	----------------------------------------------

	  vcSurroundDemo.dpr - VC 2.5 Pro Surround demo
	  Voice Communicator components version 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2008-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, Jan 2008

	  modified by:
		Lake, Jan-Feb 2008

	----------------------------------------------
*)

{$I unaDef.inc }

program
  vcSurroundDemo;

uses
  Forms,
  u_surround_main in 'u_surround_main.pas' {c_form_main},
  u_surround_sourceSel in 'u_surround_sourceSel.pas' {c_form_sourceManage};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'VC 2.5 - Surround Demo';
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.CreateForm(Tc_form_sourceManage, c_form_sourceManage);
  Application.Run;
end.

