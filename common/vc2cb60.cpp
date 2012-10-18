//---------------------------------------------------------------------------

#include <vcl.h>

#pragma hdrstop

USERES("vc2cb.res");
USERES("vc2ico.res");
USEPACKAGE("rtl.bpi");
USEPACKAGE("vcl.bpi");
USEUNIT("unavcIDE.pas");
USEUNIT("unavcIDEUtils.pas");
USEUNIT("unaEncoderAPI.pas");
USEUNIT("unaMsMixer.pas");
USEUNIT("unavcApp.pas");
USEUNIT("unaVCLutils.pas");
USEUNIT("unaMpglibAPI.pas");
USEUNIT("unaOpenH323PluginAPI.pas");
USEUNIT("unaAudioFeedback.pas");
USEUNIT("unaDspControls.pas");
USEUNIT("unaGridMonitorVCL.pas");
USEUNIT("unaVCDSComp.pas");
USEUNIT("unaVCDSIntf.pas");

USEFORMNS("../demos/common/u_common_audioConfig.pas", U_common_audioconfig, c_form_common_audioConfig);

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
