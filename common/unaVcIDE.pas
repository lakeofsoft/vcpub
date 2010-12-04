
(*
	----------------------------------------------

	  unaVCIDE.pas - VC 2.5 Pro components to be used with VCL/IDE
	  Voice Communicator components version 2.5 Pro

	----------------------------------------------
	  Copyright (c) 2002-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 01 Jun 2002

	  modified by:
		Lake, Jun-Dec 2002
		Lake, Jan-Dec 2003
		Lake, Jan-May 2004
		Lake, May-Oct 2005
		Lake, Mar-Dec 2007
                Lake, Jan-Feb 2008

	----------------------------------------------
*)

{$I unaDef.inc }

{$IFDEF DEBUG }
  {$DEFINE LOG_UNAVCIDE_INFOS }	// log informational messages
  {$DEFINE LOG_UNAVCIDE_ERRORS }	// log critical errors
{$ENDIF DEBUG }

{$IFNDEF VC_LIC_PUBLIC }
  {$DEFINE UNAVCIDE_SCRIPT_COMPONENT }	// define to link scriptor component
{$ENDIF VC_LIC_PUBLIC }


{*
  Contains components and classes to be used in Delphi/C++Builder IDE.

  <P>Wave components:
    <LI><A href="unaVC_wave/unavclWaveInDevice.html">WaveIn</A>.
    <LI><A href="unaVC_wave/unavclWaveOutDevice.html">WaveOut</A>.
    <LI><A href="unaVC_wave/unavclWaveCodecDevice.html">WaveCodec</A>.
    <LI><A href="unaVC_wave/unavclWaveRiff.html">WaveRIFF</A>.
    <LI><A href="unaVC_wave/unavclWaveMixer.html">WaveMixer</A>.
    <LI><A href="unaVC_wave/unavclWaveResampler.html">WaveResampler</A>.

  <P>IP components:
    <LI><A href="unaVC_socks/unavclIPClient.html">IPClient</A>.
    <LI><A href="unaVC_socks/unavclIPServer.html">IPServer</A>.
    <LI><A href="unaVC_socks/unavclIPBroadcastServer.html">BroadcastServer</A>.
    <LI><A href="unaVC_socks/unavclIPBroadcastClient.html">BroadcastClient</A>.

  <P>Scripting:
    <LI><A href="unaVC_script/unavclScriptor.html">Scriptor</A> component.

  @Author Lake
  @Version 2.5.2008.03 Split into _pipe, _wave, _socks, _script units
}

unit
  unaVCIDE;

interface

uses
  unaClasses, Classes, 
  unaVC_pipe, unaVC_wave, unaVC_socks
{$IFDEF UNAVCIDE_SCRIPT_COMPONENT }
  , unaVC_script
{$ENDIF UNAVCIDE_SCRIPT_COMPONENT }
  ;


type
  //
  // redifine general pipes here
  unavclInOutPipe = unaVC_pipe.unavclInOutPipe;
  unavclInOutWavePipe = unaVC_wave.unavclInOutWavePipe;
  unavclInOutIpPipe = unaVC_socks.unavclInOutIpPipe;


// --
// wave pipes
// --
  TunavclWaveInDevice 		= class(unavclWaveInDevice) end;	/// WaveIn component.
  TunavclWaveOutDevice		= class(unavclWaveOutDevice) end;	/// WaveOut component.
  TunavclWaveCodecDevice	= class(unavclWaveCodecDevice) end;	/// WaveCodec component.
  TunavclWaveRiff		= class(unavclWaveRiff) end;		/// WaveRIFF component.
  TunavclWaveMixer		= class(unavclWaveMixer) end;		/// WaveMixer component.
  TunavclWaveResampler		= class(unavclWaveResampler) end;	/// WaveResampler component.


// --
// IP pipes
// --
  TunavclIPOutStream		= class(unavclIPClient) end;		/// IPClient component.
  TunavclIPInStream		= class(unavclIPServer) end;         	/// IPServer component.
  TunavclIPBroadcastServer	= class(unavclIPBroadcastServer) end;	/// BroadcastServer component.
  TunavclIPBroadcastClient	= class(unavclIPBroadcastClient) end;	/// BroadcastClient component.


{$IFDEF UNAVCIDE_SCRIPT_COMPONENT }

// --
// scripting
// --
  TunavclScriptor		= class(unavclScriptor) end;		/// Scriptor component.

{$ENDIF UNAVCIDE_SCRIPT_COMPONENT }


{*
  Registers VC pipes in Delphi IDE components palette.
}
procedure Register();


implementation


uses
  unaUtils;

// -- resister pipes in IDE --
//
procedure Register();
begin
  RegisterComponents(c_VC_reg_core_section_name, [
    //
    TunavclWaveInDevice,
    TunavclWaveOutDevice,
    TunavclWaveCodecDevice,
    TunavclWaveRiff,
    TunavclWaveMixer,
    TunavclWaveResampler,
    //
    TunavclIPOutStream,
    TunavclIPInStream,
    TunavclIPBroadcastServer,
    TunavclIPBroadcastClient
    //
{$IFDEF UNAVCIDE_SCRIPT_COMPONENT }
    , TunavclScriptor
{$ENDIF UNAVCIDE_SCRIPT_COMPONENT }
  ]);
end;


initialization

{$IFDEF LOG_UNAVCIDE_INFOS }
  logMessage('unaVCIDE - DEBUG is defined.');
{$ENDIF LOG_UNAVCIDE_INFOS }

end.

