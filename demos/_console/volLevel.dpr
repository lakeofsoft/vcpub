
(*
	----------------------------------------------

	  volLevel.dpr
	  Voice Communicator components version 2.5
	  Audio Tools - PCM volume meter

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 29 Mar 2002

	  modified by:
		Lake, Mar-Jun 2002
		Lake, Jun 2003
		Lake, Oct 2005
                Lake, Jun 2009

	----------------------------------------------
*)

{$I unaDef.inc}

{$IFDEF VC21_USE_CON }
  {$APPTYPE CONSOLE }
{$ENDIF VC21_USE_CON }

program
  volLevel;

{$R *.res }

uses
  volLevelApp;

// -- main --

begin
  with (unaVolLevelApp.create('PCM volume level,  version 2.5.4  ', 'Copyright (c) 2002-2009 Lake of Soft, Ltd')) do try
    run();
  finally
    free();
  end;
end.

