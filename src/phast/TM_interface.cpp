#ifdef USE_MPI
#include "mpi.h"
#endif
#ifdef WIN32
#include <windows.h>
#else
#ifdef USE_OPENMP
#include <unistd.h>
#endif
#endif
#include <string>
#include <map>
#include "TM_interface.h"
#ifdef USE_OPENMP
#include <omp.h>
#endif
extern void transport_component(int *i);
extern void transport_component_thread(int *i);

#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
void
TM_transport(int *id, int *ncomps, int *nthreads)
/* ---------------------------------------------------------------------- */
{ 
	// Used for MPI transport calculations
	for (int i = 1; i <= *ncomps; i++)
	{
		transport_component_thread(&i);
	}
}
#else
/* ---------------------------------------------------------------------- */
void
TM_transport(int *id, int *ncomps, int *nthreads)
/* ---------------------------------------------------------------------- */
{
	int n = 1;
	// Used for threaded transport calculations
#ifdef USE_OPENMP
	if (*nthreads <= 0)
	{
#if defined(_WIN32)
		SYSTEM_INFO sysinfo;
		GetSystemInfo( &sysinfo );

		n = sysinfo.dwNumberOfProcessors;
#else
		// Linux, Solaris, Aix, Mac 10.4+
		n = sysconf( _SC_NPROCESSORS_ONLN );
#endif
		*nthreads = n;
	}
	else
	{
		n = *nthreads;
	}
#endif
#ifdef USE_OPENMP
	omp_set_num_threads(n);
	#pragma omp parallel
	#pragma omp for
	for (int i = 1; i <= *ncomps; i++)
	{
		transport_component_thread(&i);
	}
#else
	for (int i = 1; i <= *ncomps; i++)
	{
		transport_component(&i);
	}
#endif
}
#endif


