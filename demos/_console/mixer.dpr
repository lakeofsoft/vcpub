
(*
	----------------------------------------------

	  mixer.dpr
	  Voice Communicator components version 2.5
	  Audio Tools - software PCM mixer

	----------------------------------------------
	  Copyright (c) 2001-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, Sep 2001

	  modified by:
		Lake, Jan-Jun 2002
		Lake, Jun 2003
		Lake, Oct 2005
                Lake, Jun 2009

	----------------------------------------------
*)

{$I unaDef.inc }

{$IFDEF VC21_USE_CON }
  {$APPTYPE CONSOLE }
{$ENDIF VC21_USE_CON }

program
  mixer;

uses
  mixerApp;

{$R *.res }

// -- main --

begin
  with (unaMixerApp.create(true, true, 'PCM mixer,  version 2.5.4  ', 'Copyright (c) 2001-2009 Lake of Soft, Ltd')) do try
    run();
  finally
    free();
  end;
end.

