//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
#include "..\..\common\U_common_audioconfig.hpp"
USERES("vccbTalkNow.res");
USEFORM("vccb_talkNow_main.cpp", c_form_main);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
	try
	{
		Application->Initialize();
		Application->CreateForm(__classid(Tc_form_main), &c_form_main);
		Application->CreateForm(__classid(Tc_form_common_audioConfig), &c_form_common_audioConfig);
		Application->Run();
	}
	catch (Exception &exception)
	{
		Application->ShowException(&exception);
	}
	return 0;
}
//---------------------------------------------------------------------------
