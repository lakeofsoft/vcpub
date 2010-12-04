
(*
	----------------------------------------------

	  u_vcMp3Demo_about.pas
	  Voice Communicator components version 2.5 Pro
	  MP3/Ogg Streaming Demo application - about form

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 21 Oct 2002

	  modified by:
		Lake, Oct-Nov 2002
		Lake, Jan-Dec 2003
		Lake, Mar 2004
		Lake, Oct 2005

	----------------------------------------------
*)

{$I unaDef.inc}

unit
  u_vcmp3Demo_about;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  Tc_form_about = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure doAboutEncode();
  end;

var
  c_form_about: Tc_form_about;


implementation


{$R *.dfm}

{ Tc_form_about }

// --  --
procedure Tc_form_about.doAboutEncode();
begin
  showModal();
end;


procedure Tc_form_about.FormCreate(Sender: TObject);
begin
  Memo1.text :=
'  VC 2.5 - MP3/Ogg streaming demo  version 1.2'#13#10 +
'  http://lakeofsoft.com/vc/'#13#10 +
''#13#10 +
'-----------------'#13#10 +
''#13#10 +
'  This demo application shows how to use the VC 2.5 Pro components'#13#10 +
'  together with external encoders and decoders to produce live streams'#13#10 +
'  not supported by default Windows ACM codecs.'#13#10 +
''#13#10 +
'  This demo requires at least one of the encoding libraries:'#13#10 +
'  - BladeEnc.dll (version 0.90 or later) for Blade MP3 encoding;'#13#10 +
'  - Lame_enc.dll (version 3.90 or later) for Lame MP3 encoding;'#13#10 +
'  - ogg.dll, vorbis.dll and vorbisenc.dll for Ogg/Vorbis encoding.'#13#10 +
''#13#10 +
'  This demo also requires at least one of the decoding libraries:'#13#10 +
'  - ogg.dll and vorbis.dll for Ogg/Vorbis decoding;'#13#10 +
'  - bass.dll (version 1.7 or later) for MP3/Ogg decoding;'#13#10 +
'  - mpglib.dll for MP3 decoding;'#13#10 +
''#13#10 +
'  Blade MP3 Encoder is'#13#10 +
'    (c) Copyright 1998, 2001 - Tord Jansson'#13#10 +
'  Homepage:  http://bladeenc.mp3.no/'#13#10 +
'  Binary download:  http://www2.arnes.si/~mmilut/'#13#10 +
''#13#10 +
'  Lame MP3 Encoder is'#13#10 +
'    Copyrights (c) 1999,2000,2001 by Mark Taylor'#13#10 +
'    Copyrights (c) 1998 by Michael Cheng'#13#10 +
'  Homepage:  http://www.mp3dev.org/'#13#10 +
'  Binary download:  http://mitiok.cjb.net/'#13#10 +
''#13#10 +
'  More information about MP3 encoders:'#13#10 +
'    http://www.mp3-tech.org/encoders.html'#13#10 +
''#13#10 +
'  Ogg/Vorbis Encoder is'#13#10 +
'    Copyright (C) 1994-2003 Xiph.org Foundation. All rights reserved.'#13#10 +
'  Developers homepage: http://www.xiph.org/ogg/vorbis/'#13#10 +
''#13#10 +
'  BASS library is'#13#10 +
'    Copyright (c) 1999-2003 Ian Luck. All rights reserved.'#13#10 +
'  Homepage: http://www.un4seen.com/'#13#10 +
''#13#10 +
'  mpglib.dll (Win32) with source (LGPL)'#13#10 +
'  Version 0.92, November 2001'#13#10 +
'  Adapted from mpglib by Martin Pesch'#13#10 +
'  http://www.rz.uni-frankfurt.de/~pesch'#13#10 +
''#13#10 +
'-----------------'#13#10;

end;

end.

