#include <stdlib.h>
#include <string>
#include <vector>
//#define _CRTDBG_MAP_ALLOC
//#include <crtdbg.h>
extern int advection_example();
#if defined(USE_MPI)
#include <mpi.h>
#endif

//#if WIN32
#include <windows.h>
#include "phrqtype.h"
#include "PhreeqcRM.h"
#include "RM_interface.h"

//BOOL CtrlHandler(DWORD dwCtrlType)
//{
//	try
//	{
//		switch(dwCtrlType)
//		{
//		case CTRL_LOGOFF_EVENT:
//			break;
//		case CTRL_C_EVENT:
//		case CTRL_CLOSE_EVENT:
//		case CTRL_BREAK_EVENT:
//		case CTRL_SHUTDOWN_EVENT:
//			OutputDebugString("CtrlHandler Catch\n");
//			//HDFFinalize();
//			//write_restart(rate_sim_time_end * rate_cnvtmi);
//			//WriteRestartFile(0);
//			ExitProcess(1);
//			return TRUE;
//		default:
//			break;
//		}
//	}
//	catch(...)
//	{
//		ExitProcess(1);
//	}
//	return FALSE;
//}
//#endif

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

	advection_example();
#if defined(USE_MPI)
	MPI_Finalize();
#endif
	return EXIT_SUCCESS;
}
