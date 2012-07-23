#include <stdlib.h>

//#define _CRTDBG_MAP_ALLOC
//#include <crtdbg.h>

#if defined(USE_MPI)
#include <mpi.h>
#endif

#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) name
#endif

#if defined(FC_FUNC_)
#define PHAST_SUB FC_FUNC_(phast_sub, PHAST_SUB)
#endif

extern "C" void PHAST_SUB(int *mpi_tasks, int *mpi_myself);

#if WIN32
#include <windows.h>
#include "phrqtype.h"

extern "C" void HDF_Finalize(void);

#ifdef SKIP_REWRITE_PHAST //-------------------------------------------------------------------------
int write_restart(double hst_time);

extern LDBLE rate_sim_time_end;
extern LDBLE rate_cnvtmi;

BOOL CtrlHandler(DWORD dwCtrlType)
{
	try
	{
		switch(dwCtrlType)
		{
		case CTRL_LOGOFF_EVENT:
			break;
		case CTRL_C_EVENT:
		case CTRL_CLOSE_EVENT:
		case CTRL_BREAK_EVENT:
		case CTRL_SHUTDOWN_EVENT:
			OutputDebugString("CtrlHandler Catch\n");
			HDF_Finalize();
			write_restart(rate_sim_time_end * rate_cnvtmi);
			ExitProcess(1);
			return TRUE;
		default:
			break;
		}
	}
	catch(...)
	{
		ExitProcess(1);
	}
	return FALSE;
}
#endif

#endif // SKIP_REWRITE_PHAST

int main(int argc, char* argv[])
{
	int mpi_tasks;
	int mpi_myself;

#if defined(USE_MPI)
	if (MPI_Init(&argc, &argv) != MPI_SUCCESS)
	{
		return EXIT_FAILURE;
	}

	if (MPI_Comm_size(MPI_COMM_WORLD, &mpi_tasks) != MPI_SUCCESS)
	{
		return EXIT_FAILURE;
	}

	if (MPI_Comm_rank(MPI_COMM_WORLD, &mpi_myself) != MPI_SUCCESS)
	{
		return EXIT_FAILURE;
	}
#else
	mpi_tasks = 1;
	mpi_myself = 0;
#endif
#ifdef SKIP_REWRITE_PHAST //-------------------------------------------------------------------------
#if WIN32
	SetConsoleCtrlHandler((PHANDLER_ROUTINE) CtrlHandler, TRUE);
#endif
#endif // SKIP_REWRITE_PHAST
	//int tmpDbgFlag;

 //  _CrtSetReportMode(_CRT_WARN, _CRTDBG_MODE_FILE | _CRTDBG_MODE_DEBUG);
 //  _CrtSetReportFile(_CRT_WARN, _CRTDBG_FILE_STDOUT);
 //  _CrtSetReportMode(_CRT_ERROR, _CRTDBG_MODE_FILE | _CRTDBG_MODE_DEBUG);
 //  _CrtSetReportFile(_CRT_ERROR, _CRTDBG_FILE_STDOUT);
 //  _CrtSetReportMode(_CRT_ASSERT, _CRTDBG_MODE_FILE | _CRTDBG_MODE_DEBUG);
 //  _CrtSetReportFile(_CRT_ASSERT, _CRTDBG_FILE_STDOUT);

	//tmpDbgFlag = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
	///*tmpDbgFlag |= _CRTDBG_DELAY_FREE_MEM_DF;*/
	//tmpDbgFlag |= _CRTDBG_LEAK_CHECK_DF;
	///*tmpDbgFlag |= _CRTDBG_CHECK_ALWAYS_DF;*/
	//_CrtSetDbgFlag(tmpDbgFlag);
	//_crtBreakAlloc = 198;

	PHAST_SUB(&mpi_tasks, &mpi_myself);

	return EXIT_SUCCESS;
}
