
(*
	----------------------------------------------

	  codec.dpr
	  Voice Communicator components version 2.5
	  Audio Tools - simple ACM codec

	----------------------------------------------
	  Copyright (c) 2001-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 01 Nov 2001

	  modified by:
		Lake, Jan-Jun 2002
		Lake, Jun 2003
		Lake, Oct 2005
                Lake, Jun 2009

	----------------------------------------------
*)

{$I unaDef.inc}

{$IFDEF VC21_USE_CON }
  {$APPTYPE CONSOLE }
{$ENDIF VC21_USE_CON }
 
program codec;

{$R *.res }

uses
  codecApp;

// -- main --

begin
  with (unaCodecApp.create(true, true, 'PCM codec,  version 2.5.4  ', 'Copyright (c) 2001-2009 Lake of Soft')) do try
    run();
  finally
    free();
  end;
end.

