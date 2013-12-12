#ifdef WIN32
#include <windows.h>
#endif
#include <string>
#include <map>
#include "TM_interface.h"
#ifdef THREADED_PHAST
#include <omp.h>
#endif
#ifdef USE_MPI
#include "mpi.h"
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
#ifdef THREADED_PHAST
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
#ifdef THREADED_PHAST
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
/* ---------------------------------------------------------------------- */
void TM_zone_flow_write_chem(int *print_zone_flows_xyzt)
/* ---------------------------------------------------------------------- */
{
#ifdef USE_MPI
	MPI_Bcast(print_zone_flows_xyzt, 1, MPI_INTEGER, 0, MPI_COMM_WORLD);
#endif
	if (print_zone_flows_xyzt != 0)
	{
		zone_flow_write_chem();
	}
}

