#include <mpi.h>
#include <time.h>
#if defined(FC_FUNC_)
//#define WORKER_GET_INDEXES    FC_FUNC_ (worker_get_indexes,     WORKER_GET_INDEXES)
#endif /*FC_FUNC_*/
#define WORKER_GET_INDEXES      worker_get_indexes 
#if defined(__cplusplus)
extern "C" {
#endif
	void WORKER_GET_INDEXES(int *indx_sol1_ic, int *indx_sol2_ic,
		double *mxfrac, int *naxes, int *nxyz,
		double *x_node, double *y_node, double *z_node,
		double *cnvtmi, int *transient_fresur,
		int *steady_flow, double *pv0,
		int *rebalance_method_f, double *volume, double *tort, int *npmz,
		int *exchange_units, int *surface_units, int *ssassemblage_units, 
		int *ppassemblage_units, int *gasphase_units, int *kinetics_units);
#if defined(__cplusplus)
}
#endif
void
WORKER_GET_INDEXES(
	int    *indx_sol1_ic, 
	int    *indx_sol2_ic, 
	double *mxfrac,
	int    *naxes, 
	int    *nxyz,    // not sent?
	double *x_node, 
	double *y_node,
	double *z_node, 
	double *cnvtmi, 
	int    *transient_fresur, 
	int    *steady_flow, 
	double *pv0, 
	int    *rebalance_method_f,          
	double *volume, 
	double *tort, 
	int    *npmz,  
	int    *exchange_units, 
	int    *surface_units, 
	int    *ssassemblage_units, 
	int    *ppassemblage_units, 
	int    *gasphase_units, 
	int    *kinetics_units)
{
#ifdef USE_MPI
    // make sure latest npmz for all workers
	MPI_Bcast(indx_sol1_ic, 7 * (*nxyz), MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(indx_sol2_ic, 7 * (*nxyz), MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(mxfrac, 7 * (*nxyz), MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(naxes, 3, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(x_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(y_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(z_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(cnvtmi, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(transient_fresur, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(steady_flow, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(pv0, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(rebalance_method_f, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(volume, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(tort, *npmz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(npmz, 1, MPI_INT, 0, MPI_COMM_WORLD);
	//rebalance_method = *rebalance_method_f;
	MPI_Bcast(exchange_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(surface_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(ssassemblage_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(ppassemblage_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(gasphase_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(kinetics_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	return;
#endif
}

#ifdef SKIP
#ifdef USE_MPI
#define EXTERNAL extern
#define MAIN
#if defined(USE_MPI)
#include <mpi.h>
#endif
#include "phreeqc/global.h"
#include "phreeqc/output.h"
#include "hst.h"
#include "phreeqc/phqalloc.h"
#include "phreeqc/phrqproto.h"
#include "phreeqc/input.h"
#include "phast_files.h"
#include "phastproto.h"
#include <time.h>

#if defined(FC_FUNC_)
//#define WORKER_GET_SOLUTE     FC_FUNC_ (worker_get_solute,      WORKER_GET_SOLUTE)
#define WORKER_GET_INDEXES    FC_FUNC_ (worker_get_indexes,     WORKER_GET_INDEXES)
#else /*FC_FUNC_*/
#if !defined(LAHEY_F95) && !defined(_WIN32) || defined(NO_UNDERSCORES)
#define SLAVE_GET_SOLUTE slave_get_solute
#define SLAVE_GET_INDEXES slave_get_indexes
#else
#define SLAVE_GET_SOLUTE slave_get_solute_
#define SLAVE_GET_INDEXES slave_get_indexes_
#endif
#endif /*FC_FUNC_*/
extern "C"
{
//	void WORKER_GET_SOLUTE(int *solute, int *nx, int *ny, int *nz);
	void WORKER_GET_INDEXES(int *indx_sol1_ic, int *indx_sol2_ic,
		double *mxfrac, int *naxes, int *nxyz,
		double *x_node, double *y_node, double *z_node,
		double *cnvtmi, int *transient_fresur,
		int *steady_flow, double *pv0,
		int *rebalance_method_f, double *volume, double *tort, int *npmz,
		int *exchange_units, int *surface_units, int *ssassemblage_units, 
			       int *ppassemblage_units, int *gasphase_units, int *kinetics_units);
}
//void
//WORKER_GET_SOLUTE(int *solute, int *nx, int *ny, int *nz)
//{
//#if defined(USE_MPI)
//	MPI_Bcast(solute, 1, MPI_INT, 0, MPI_COMM_WORLD);
//	MPI_Bcast(nx, 1, MPI_INT, 0, MPI_COMM_WORLD);
//	MPI_Bcast(ny, 1, MPI_INT, 0, MPI_COMM_WORLD);
//	MPI_Bcast(nz, 1, MPI_INT, 0, MPI_COMM_WORLD);
//	return;
//#endif
//}

void
WORKER_GET_INDEXES(int *indx_sol1_ic, int *indx_sol2_ic, double *mxfrac,
				  int *naxes, int *nxyz, double *x_node, double *y_node,
				  double *z_node, double *cnvtmi, int *transient_fresur,
				  int *steady_flow, double *pv0, int *rebalance_method_f,
		                  double *volume, double *tort, int *npmz,
				  int *exchange_units, int *surface_units, int *ssassemblage_units, 
				  int *ppassemblage_units, int *gasphase_units, int *kinetics_units)
{
#if defined(USE_MPI)
	//fprintf(stderr,"ptrs %p %p\n", steady_flow, rebalance_method_f);
	//exit(4);
        // make sure latest npmz for all workers
	MPI_Bcast(npmz, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(indx_sol1_ic, 7 * (*nxyz), MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(indx_sol2_ic, 7 * (*nxyz), MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(mxfrac, 7 * (*nxyz), MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(naxes, 3, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(x_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(y_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(z_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(cnvtmi, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(transient_fresur, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(steady_flow, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(pv0, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(rebalance_method_f, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(volume, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(tort, *npmz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	rebalance_method = *rebalance_method_f;
	MPI_Bcast(exchange_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(surface_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(ssassemblage_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(ppassemblage_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(gasphase_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(kinetics_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	return;
#endif
}
#endif
#endif