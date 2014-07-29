#if defined(USE_MPI)
#include <mpi.h>
#endif
#include <stdlib.h>
#include <iostream>
#include <string>
#include <vector>
#include "hdf.h"
#include "PhreeqcRM.h"
//#define _CRTDBG_MAP_ALLOC
//#include <crtdbg.h>

#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif

#if defined(FC_FUNC_)
#define PHAST_SUB FC_FUNC_(phast_sub, PHAST_SUB)
#endif

extern "C" void PHAST_SUB(int *mpi_tasks, int *mpi_myself, int *nthreads);

#if WIN32
#include <windows.h>
#include "phrqtype.h"
#include "PhreeqcRM.h"
#include "RM_interface_F.h"

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
			HDFFinalize();
			//write_restart(rate_sim_time_end * rate_cnvtmi);
			//WriteRestartFile(0);
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

int main(int argc, char* argv[])
{

#ifdef SKIP
	double *a[1000];
	double *b[1000];
	double *c[1000];

	for (int i = 0; i < 1000; i++)
	{
		a[i] = (double *) malloc(1000*sizeof(double));
		b[i] = (double *) malloc(1000*sizeof(double));
		c[i] = (double *) malloc(1000*sizeof(double));
	}

	double f;
	for (int i = 0; i < 1000; i++)
	{
		for (int j = 0; j < 1000; j++)
		{
			f = (double)rand() / RAND_MAX;
			a[i][j] = f;
			f = (double)rand() / RAND_MAX;
			b[i][j] = f;
		}
	}
	std::cerr << "Start matrix multiply..." << std::endl;
	clock_t t0 = clock();
	for (int i = 0; i < 1000; i++)
	{
		for (int j = 0; j < 1000; j++)
		{
			c[i][j] = 0.0;
			for (int k = 0; k < 1000; k++)
			{
				c[i][j] = c[i][j] + a[i][k]*b[k][j];
			}
		}
	}
	clock_t t_total = clock() - t0;
	std::cerr << "Matric multiply time: " << (double) t_total / (double) CLOCKS_PER_SEC << std::endl;
#endif
	int nthreads = 0;
	if (argc > 1)
	{
		sscanf(argv[1], "%d", &nthreads);
	}
	int mpi_tasks;
	int mpi_myself;
	try
	{
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
#if defined(WIN32_MEMORY_DEBUG)
	int tmpDbgFlag;
	tmpDbgFlag = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
	//tmpDbgFlag |= _CRTDBG_DELAY_FREE_MEM_DF;
	tmpDbgFlag |= _CRTDBG_LEAK_CHECK_DF;
	///tmpDbgFlag |= _CRTDBG_CHECK_ALWAYS_DF;
	_CrtSetDbgFlag(tmpDbgFlag);
#endif
		//  _CrtSetReportMode(_CRT_WARN, _CRTDBG_MODE_FILE | _CRTDBG_MODE_DEBUG);
		//  _CrtSetReportFile(_CRT_WARN, _CRTDBG_FILE_STDOUT);
		//  _CrtSetReportMode(_CRT_ERROR, _CRTDBG_MODE_FILE | _CRTDBG_MODE_DEBUG);
		//  _CrtSetReportFile(_CRT_ERROR, _CRTDBG_FILE_STDOUT);
		//  _CrtSetReportMode(_CRT_ASSERT, _CRTDBG_MODE_FILE | _CRTDBG_MODE_DEBUG);
		//  _CrtSetReportFile(_CRT_ASSERT, _CRTDBG_FILE_STDOUT);

		//tmpDbgFlag = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
		///*tmpDbgFlag |= _CRTDBG_DELAY_FREE_MEM_DF;*/
		//tmpDbgFlag |= _CRTDBG_LEAK_CHECK_DF;
		///*tmpDbgFlag |= _CRTDBG_CHECK_ALWAYS_DF;*/ // really slow?
		//_CrtSetDbgFlag(tmpDbgFlag);
		//_crtBreakAlloc = 198;
		
		PHAST_SUB(&mpi_tasks, &mpi_myself, &nthreads);

#if defined(USE_MPI)
		MPI_Finalize();
#endif
	}
	catch (PhreeqcRMStop)
	{
		std::string e_string = "PHAST is closing due to an error in PhreeqcRM.";
		std::cerr << e_string << std::endl;
#ifdef USE_MPI
		std::cerr << "Aborting MPI." << std::endl;
		int i;
		if (MPI_Initialized(&i))
		{
			MPI_Abort(MPI_COMM_WORLD, i);
		}
#endif
		return IRM_FAIL;
	}
	catch (...)
	{
		std::string e_string = "PHAST is closing due to an unhandled exception.";
		std::cerr << e_string << std::endl;
#ifdef USE_MPI
		std::cerr << "Aborting MPI." << std::endl;
		int i;
		if (MPI_Initialized(&i))
		{
			MPI_Abort(MPI_COMM_WORLD, i);
		}
#endif
		return IRM_FAIL;
	}

	return EXIT_SUCCESS;
}
