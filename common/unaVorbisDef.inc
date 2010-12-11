
{x $DEFINE VC_OLD_VORBIS_API }	// define to compile "old" samples, which rely on full Vorbis API

// --  --
{$IFNDEF VC_PUBLIC }
  //
  {$IFNDEF VC_OLD_VORBIS_API }

    //
    // public version rely on "old" API
    // as well as some console samples, so define VC_OLD_VORBIS_API if you need them
    //
    {$DEFINE VC_LIBVORBIS_ONLY }		// define to limit API to libvorbis.dll only

  {$ENDIF VC_OLD_VORBIS_API }
  //
{$ENDIF VC_PUBLIC }

