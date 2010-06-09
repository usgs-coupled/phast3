// phastexport.cpp : Defines the entry point for the application.
//
// Spawns a java app using the -jar jarfile [args...] 
// (ie javaw.exe -jar phast.jar)
//
// Before starting the app adds ..\lib\Win32 to the path
//
// Assumes that a Java Runtime Environment ( > 1.2) is properly installed
//
// Determines the location of javaw.exe by reading the registry
//    HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment\CurrentVersion = N.N
//    HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment\N.N\JavaHome
//    where N.N is the current installed version (ie 1.4)
//
// Expects the following layout:
//    .\bin
//    .\bin\${EXE_NAME}
//    .\lib
//    .\lib\${IDS_JARFILE}
//    .\lib\Win32
//    .\lib\Win32/*.dll
//
// ie
//    .\bin
//    .\bin\phasthdf.exe
//    .\lib
//    .\lib\jhdf.jar
//    .\lib\jhdf5.jar
//    .\lib\jhdfobj.jar
//    .\lib\phast.jar
//    .\lib\Win32
//    .\lib\Win32\jhdf.dll
//    .\lib\Win32\jhdf5.dll
//    Note: phast.jar contains MANIFEST/Main-Class="gov.usgs.phast.JWizardFrame"
//    and MANIFEST/Class-Path="jhdf.jar jhdf5.jar jhdfobj.jar"


#include "stdafx.h"
#include "resource.h"

// UNICODE => std::wstring   ANSI => std::string
typedef std::basic_string<TCHAR> tstring;

// Global Variables:
tstring g_err_msg;

// Foward declarations of functions included in this code module:
BOOL AddPath(tstring& extpath);
BOOL GetExtPath(tstring& app_path, tstring& extpath);
BOOL CreateCommandLine(HINSTANCE hInstance, LPSTR lpCmdLine, tstring& cmdline);
BOOL GetArgs(LPSTR lpCmdLine, tstring& args);
BOOL GetJavaExe(HINSTANCE hInstance, tstring& java_exe);
BOOL GetJarPath(HINSTANCE hInstance, tstring& jar_path);
BOOL GetAppPath(HINSTANCE hInstance, tstring& app_path);
BOOL RunCommandLine(tstring& cmdline);
int LoadString(HINSTANCE hInstance, UINT uID, tstring& strT);


int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	tstring cmdline;

	// ie "C:\Program Files\Java\j2re1.4.1\bin\javaw.exe"
	//     -jar "C:\Program Files\USGS\Phast\lib\phast.jar" "C:\Program Files\USGS\Phast\examples\ok\ok.h5"
	if (!::CreateCommandLine(hInstance, lpCmdLine, cmdline))
	{
		::OutputDebugString(TEXT("CreateCommandLine failed\n"));
		return EXIT_FAILURE;
	}

	tstring app_path;
	if (!::GetAppPath(hInstance, app_path))
	{
		::OutputDebugString(TEXT("GetAppPath failed\n"));
		return EXIT_FAILURE;
	}

	tstring extpath;
	if (!::GetExtPath(app_path, extpath))
	{
		::OutputDebugString(TEXT("GetExtPath failed\n"));
		return EXIT_FAILURE;
	}

	if (!::AddPath(extpath))
	{
		::OutputDebugString(TEXT("AddPath failed\n"));
		return EXIT_FAILURE;
	}

	if (!::RunCommandLine(cmdline))
	{
		::OutputDebugString(TEXT("RunCommandLine failed\n"));
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}

BOOL GetExtPath(tstring& app_path, tstring& extpath)
{
	BOOL bOk = TRUE;	
	extpath = app_path + tstring(TEXT("..\\lib\\Win32"));
	return bOk;
}

BOOL GetAppPath(HINSTANCE hInstance, tstring& app_path)
{
	TCHAR drive[_MAX_DRIVE];
	TCHAR dir[_MAX_DIR];
	TCHAR fname[_MAX_FNAME];
	TCHAR ext[_MAX_EXT];
	TCHAR szBuff[_MAX_PATH];
	TCHAR szOutput[_MAX_PATH];

	// Get exe path
	if (!::GetModuleFileName(hInstance, szBuff, _MAX_PATH))
	{
		::OutputDebugString(TEXT("GetModuleFileName failed"));
		return FALSE;

	}	
	::_tsplitpath_s(szBuff, drive, _MAX_DRIVE, dir, _MAX_DIR, fname, _MAX_FNAME, ext, _MAX_EXT);
	::_tmakepath_s(szOutput, _MAX_PATH, drive, dir, NULL, NULL);

	app_path = szOutput;
	return TRUE;
}


BOOL AddPath(tstring& extpath)
{
	BOOL bOk;
	
	// add extpath to Path and set
	if (extpath.size() > 0) {
		// get Path
		tstring path;
		DWORD dwBuf = ::GetEnvironmentVariable(TEXT("Path"), NULL, 0);
		path.reserve(dwBuf + 1);
		path.resize(dwBuf);
		dwBuf = ::GetEnvironmentVariable(TEXT("Path"), &path[0], dwBuf);

		// modify Path
		tstring newpath = extpath + tstring(TEXT(";")) + path;

		// set Path
		bOk = ::SetEnvironmentVariable(TEXT("Path"), newpath.c_str());
		if (!bOk)
		{
			::OutputDebugString(TEXT("SetEnvironmentVariable failed: "));
			::OutputDebugString(TEXT("Path:\n"));
			::OutputDebugString(newpath.c_str());
			::OutputDebugString(TEXT("\n"));
			return FALSE;
		}
	}
	return bOk;
}

BOOL RunCommandLine(tstring& cmdline)
{
	// create child process
    STARTUPINFO startupInfo;
    ::memset(&startupInfo, 0, sizeof(STARTUPINFO));
    startupInfo.cb = sizeof(STARTUPINFO);

    PROCESS_INFORMATION processInfo;
    ::memset(&processInfo, 0, sizeof(PROCESS_INFORMATION));

	BOOL bOk = ::CreateProcess(
		NULL,                    // name of executable module
		&cmdline[0],             // command line string
		NULL,                    // SD
		NULL,                    // SD
		FALSE,                   // handle inheritance option
		NORMAL_PRIORITY_CLASS,   // creation flags
		NULL,                    // new environment block
		NULL,                    // current directory name
		&startupInfo,            // startup information
		&processInfo             // process information
	);

	if (!bOk)
	{
		::OutputDebugString(TEXT("CreateProcess failed:\n"));
		::OutputDebugString(&cmdline[0]);
		::OutputDebugString(TEXT("\n"));
	}

	return bOk;
}

int LoadString(HINSTANCE hInstance, UINT uID, tstring& strT)
{
	strT.reserve(_MAX_PATH + 1);
	strT.resize(_MAX_PATH);
	int nChars = ::LoadString(hInstance, uID, &strT[0], _MAX_PATH);

	strT.resize(nChars);
	nChars = ::LoadString(hInstance, uID, &strT[0], _MAX_PATH);
	return nChars;
}

BOOL CreateCommandLine(HINSTANCE hInstance, LPSTR lpCmdLine, tstring& cmdline)
{
	tstring args;
	tstring java_exe;
	tstring jar_path;

	if (!::GetArgs(lpCmdLine, args))
	{
		::OutputDebugString(TEXT("GetArgs failed\n"));
		return FALSE;
	}

	if (!::GetJavaExe(hInstance, java_exe))
	{
		::OutputDebugString(TEXT("GetJavaExe failed"));
		::LoadString(hInstance, IDS_NOJRE, g_err_msg);
		::MessageBox(NULL, g_err_msg.c_str(), TEXT("Error"), MB_OK | MB_ICONERROR);
		return FALSE;
	}

	if (!::GetJarPath(hInstance, jar_path))
	{
		::OutputDebugString(TEXT("GetJarPath failed\n"));
		return FALSE;
	}

	cmdline = tstring(TEXT("\"")) + java_exe + tstring(TEXT("\""));
	cmdline += tstring(TEXT(" -jar "));
	cmdline += tstring(TEXT("\"")) + jar_path + tstring(TEXT("\""));
	cmdline += tstring(TEXT(" ")) + args;

	return TRUE;
}

BOOL GetJarPath(HINSTANCE hInstance, tstring& jar_path)
{
	tstring app_path;
	if (!::GetAppPath(hInstance, app_path))
	{
		::OutputDebugString(TEXT("GetAppPath failed\n"));
		return EXIT_FAILURE;
	}

	tstring sJARFILE;
	if (!::LoadString(hInstance, IDS_JARFILE, sJARFILE))
	{
		::OutputDebugString(TEXT("LoadString failed for IDS_JARFILE\n"));
		return FALSE;
	}

	jar_path = app_path + tstring(TEXT("..\\lib\\")) + sJARFILE;
	return TRUE;
}

BOOL GetJavaExe(HINSTANCE hInstance, tstring& java_exe)
{
	LONG lRet;
    HKEY hKey;
	DWORD dwBufLen;
	tstring value;
	tstring key;

	//  open HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment
	tstring sJRE_KEY;
	if (!::LoadString(hInstance, IDS_JRE_KEY, sJRE_KEY))
	{
		::OutputDebugString(TEXT("LoadString failed for IDS_JRE_KEY\n"));
		return FALSE;
	}
	lRet = ::RegOpenKeyEx(HKEY_LOCAL_MACHINE, sJRE_KEY.c_str(), 0, KEY_QUERY_VALUE, &hKey);
	if (lRet != ERROR_SUCCESS)
	{
		::OutputDebugString(TEXT("RegOpenKeyEx failed for HKEY_LOCAL_MACHINE\\"));
		::OutputDebugString(sJRE_KEY.c_str());
		::OutputDebugString(TEXT("\n"));
		return FALSE;
	}

	// query HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment\CurrentVersion
	tstring sCUR_VER;
	if (!::LoadString(hInstance, IDS_CUR_VER, sCUR_VER))
	{
		::OutputDebugString(TEXT("LoadString failed for IDS_CUR_VER\n"));
		return FALSE;
	}

	dwBufLen = 0;
	lRet = ::RegQueryValueEx(hKey, sCUR_VER.c_str(), NULL, NULL, NULL, &dwBufLen);
	if (lRet == ERROR_SUCCESS)
	{
		value.reserve(dwBufLen/sizeof(TCHAR));
		value.resize(dwBufLen/sizeof(TCHAR) - 1);
		lRet = ::RegQueryValueEx(hKey, sCUR_VER.c_str(), NULL, NULL, (LPBYTE)&value[0], &dwBufLen);
	}
	if (lRet != ERROR_SUCCESS)
	{
		::OutputDebugString(TEXT("RegQueryValueEx failed for HKEY_LOCAL_MACHINE\\"));
		::OutputDebugString(sJRE_KEY.c_str());
		::OutputDebugString(TEXT("\\"));
		::OutputDebugString(sCUR_VER.c_str());
		::OutputDebugString(TEXT("\n"));
		::RegCloseKey(hKey);
		return FALSE;
	}

	//  close HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment
	if (::RegCloseKey(hKey) != ERROR_SUCCESS)
	{
		::OutputDebugString(TEXT("RegCloseKey failed for HKEY_LOCAL_MACHINE\\"));
		::OutputDebugString(sJRE_KEY.c_str());
		::OutputDebugString(TEXT("\n"));
		// continue anyway
	}


	// open HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment\<CurrentVersion>
	key = sJRE_KEY.c_str();
	key += TEXT("\\");
	key += value.c_str();
	lRet = ::RegOpenKeyEx(HKEY_LOCAL_MACHINE, &key[0], 0, KEY_QUERY_VALUE, &hKey);
	if (lRet != ERROR_SUCCESS)
	{
		::OutputDebugString(TEXT("RegOpenKeyEx failed for HKEY_LOCAL_MACHINE\\"));
		::OutputDebugString(&key[0]);
		::OutputDebugString(TEXT("\n"));
		return FALSE;
	}


	// query HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment\<CurrentVersion>\JavaHome
	tstring sJAVAHOME;
	if (!::LoadString(hInstance, IDS_JAVAHOME, sJAVAHOME))
	{
		::OutputDebugString(TEXT("LoadString failed for IDS_JAVAHOME"));
		return FALSE;
	}
	lRet = ::RegQueryValueEx(hKey, sJAVAHOME.c_str(), NULL, NULL, NULL, &dwBufLen);
	if (lRet == ERROR_SUCCESS)
	{
		java_exe.reserve(dwBufLen/sizeof(TCHAR));
		java_exe.resize(dwBufLen/sizeof(TCHAR) - 1);
		lRet = ::RegQueryValueEx(hKey, sJAVAHOME.c_str(), NULL, NULL, (LPBYTE)&java_exe[0], &dwBufLen);
	}
	if (lRet != ERROR_SUCCESS)
	{
		::OutputDebugString(TEXT("RegQueryValueEx failed for HKEY_LOCAL_MACHINE\\"));
		::OutputDebugString(sJRE_KEY.c_str());
		::OutputDebugString(TEXT("\\"));
		::OutputDebugString(sJAVAHOME.c_str());
		::OutputDebugString(TEXT("\n"));

		::RegCloseKey(hKey);
		return FALSE;
	}


	// open HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment\<CurrentVersion>
	if (::RegCloseKey(hKey) != ERROR_SUCCESS)
	{
		::OutputDebugString(TEXT("RegCloseKey failed for HKEY_LOCAL_MACHINE\\"));
		::OutputDebugString(key.c_str());
	}

	// append \bin\javaw.exe
	// ie C:\Program Files\Java\j2re1.4.1\bin\javaw.exe
	tstring sAPPEND;
	if (!::LoadString(hInstance, IDS_APPEND, sAPPEND))
	{
		::OutputDebugString(TEXT("LoadString failed for IDS_APPEND\n"));
		return FALSE;
	}
	java_exe += sAPPEND;

	return TRUE;
}

BOOL GetArgs(LPSTR lpCmdLine, tstring& args)
{
#if defined(UNICODE)
	int nChars = ::lstrlenA(lpCmdLine);
	if (nChars > 1)
	{
		// convert lpCmdLine from ansi to unicode
		args.reserve(nChars + 1);
		args.resize(nChars);
		if (!::MultiByteToWideChar(CP_ACP, 0, lpCmdLine, -1, args.begin(), nChars + 1))
		{
			::OutputDebugString(TEXT("MultiByteToWideChar failed\n"));
			return FALSE;
		}
	}
	std::string test = lpCmdLine;
	assert(test.length() == args.length());
#else
	args = lpCmdLine;
#endif
	return TRUE;
}