#ifdef USE_MPI
#include <mpi.h>
#include <time.h>
#include <iostream>

#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif
#if defined(FC_FUNC_)
#define XFER_INDICES    FC_FUNC_ (xfer_indices,     XFER_INDICES)
#endif /*FC_FUNC_*/
#if defined(__cplusplus)
extern "C" {
#endif
	void XFER_INDICES(int *indx_sol1_ic, int *indx_sol2_ic,
		double *mxfrac, int *naxes, int *nxyz,
		double *x_node, double *y_node, double *z_node,
		double *cnvtmi, 
		int *steady_flow, double *pv0,
		int *rebalance_method_f, double *volume, double *tort, int *npmz,
		int *mpi_myself);
#if defined(__cplusplus)
}
#endif
void
XFER_INDICES(
	int    *indx_sol1_ic, 
	int    *indx_sol2_ic, 
	double *mxfrac,
	int    *naxes, 
	int    *nxyz,    // not sent?
	double *x_node, 
	double *y_node,
	double *z_node, 
	double *cnvtmi, 
	int    *steady_flow, 
	double *pv0, 
	int    *rebalance_method_f,          
	double *volume, 
	double *tort, 
	int    *npmz,  
	int    *mpi_myself)
{
    // make sure latest npmz for all workers
	//MPI_Bcast(indx_sol1_ic, 7 * (*nxyz), MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(indx_sol2_ic, 7 * (*nxyz), MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(mxfrac, 7 * (*nxyz), MPI_DOUBLE, 0, MPI_COMM_WORLD);
	//MPI_Bcast(naxes, 3, MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(x_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	//MPI_Bcast(y_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	//MPI_Bcast(z_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	//MPI_Bcast(cnvtmi, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	//MPI_Bcast(transient_fresur, 1, MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(steady_flow, 1, MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(pv0, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	//MPI_Bcast(rebalance_method_f, 1, MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(volume, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	//MPI_Bcast(npmz, 1, MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(tort, *npmz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	//rebalance_method = *rebalance_method_f;
	//MPI_Bcast(exchange_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(surface_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(ssassemblage_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(ppassemblage_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(gasphase_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	//MPI_Bcast(kinetics_units, 1, MPI_INT, 0, MPI_COMM_WORLD);
	return;
}
#endif // USE_MPI
