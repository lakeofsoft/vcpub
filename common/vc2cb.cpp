//---------------------------------------------------------------------------

#include <vcl.h>

#pragma hdrstop

USERES("vc2cb.res");
USERES("vc2ico.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("unavcIDE.pas");
USEUNIT("unavcIDEUtils.pas");
USEUNIT("unaEncoderAPI.pas");
USEUNIT("unaMsMixer.pas");
USEUNIT("unavcApp.pas");
USEUNIT("unaVCLutils.pas");
USEUNIT("unaIcyStreamer.pas");
USEUNIT("unaMpglibAPI.pas");
USEUNIT("unaOpenH323PluginAPI.pas");
USEUNIT("unaAudioFeedback.pas");
USEUNIT("unaDspControls.pas");
USEUNIT("unaGridMonitorVCL.pas");
USEUNIT("unaDspDLibPipes.pas");
USEUNIT("unaVCDSComp.pas");
USEUNIT("unaVCDSIntf.pas");
USEUNIT("unaConfRTP.pas");
USEUNIT("unaConfRTPclient.pas");
USEUNIT("unaConfRTPserver.pas");
USEUNIT("unaG711.pas");
USEUNIT("unaIPStreaming.pas");

USEFORMNS("../demos/common/u_common_audioConfig.pas", U_common_audioconfig, c_form_common_audioConfig);
USEFORMNS("../demos/common/u_common_dsplFilterConfig.pas", U_common_dsplfilterconfig, c_form_dsplFilterConfig);
USEFORMNS("../demos/common/u_common_dsplFilters.pas", U_common_dsplfilters, c_from_dspFilters);

//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
	return 1;
}
//---------------------------------------------------------------------------
