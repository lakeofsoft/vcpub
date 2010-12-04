
(*
	----------------------------------------------

	  vcDtmfDecoder.dpr - DTMF decoder demo
	  Voice Communicator components version 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2007-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 05 Jun 2007

	  modified by:
		Lake, Jun 2007

	----------------------------------------------
*)

{$I unaDef.inc}

program
  vcDtmfDecoder;

uses
  Forms,
  u_dtmfd_main in 'u_dtmfd_main.pas' {c_form_main};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tc_form_main, c_form_main);
  Application.Run;
end.

