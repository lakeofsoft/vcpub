//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("vccbMp3Demo.res");
USEFORM("u_vccbMp3Demo_main.cpp", Form1);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
	try
	{
		Application->Initialize();
		Application->Title = "VC 2.5 Pro - Ogg/Mp3 demo";
		Application->CreateForm(__classid(TForm1), &Form1);
		Application->Run();
	}
	catch (Exception &exception)
	{
		Application->ShowException(&exception);
	}
	return 0;
}
//---------------------------------------------------------------------------
