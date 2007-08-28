#define EXTERNAL extern
#define MAIN
#include <mpi.h>
#include "phreeqc/global.h"
#include "phreeqc/output.h"
#include "hst.h"
#include "phreeqc/phqalloc.h"
#include "phreeqc/phrqproto.h"
#include "phreeqc/input.h"
#include "phast_files.h"
#include "phastproto.h"
#include <time.h>

#if !defined(LAHEY_F95) && !defined(_WIN32) || defined(NO_UNDERSCORES)
#define SLAVE_GET_SOLUTE slave_get_solute
#define SLAVE_GET_INDEXES slave_get_indexes
#else
#define SLAVE_GET_SOLUTE slave_get_solute_
#define SLAVE_GET_INDEXES slave_get_indexes_
#endif
extern "C" {
	void SLAVE_GET_SOLUTE(int *solute, int *nx, int *ny, int *nz);
	void SLAVE_GET_INDEXES(int *indx_sol1_ic, int *indx_sol2_ic, double *mxfrac, int *naxes, int *nxyz, double *x_node, double *y_node, double *z_node, double *cnvtmi, int *transient_fresur, int *steady_flow, double *pv0);
}
void SLAVE_GET_SOLUTE(int *solute, int *nx, int *ny, int *nz)
{
	MPI_Bcast(solute, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(nx, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(ny, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(nz, 1, MPI_INT, 0, MPI_COMM_WORLD);
	return;
}
void SLAVE_GET_INDEXES(int *indx_sol1_ic, int *indx_sol2_ic, double *mxfrac, int *naxes, int *nxyz, double *x_node, double *y_node, double *z_node, double *cnvtmi, int *transient_fresur, int *steady_flow, double *pv0)
{
	MPI_Bcast(indx_sol1_ic, 7*(*nxyz), MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(indx_sol2_ic, 7*(*nxyz), MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(mxfrac, 7*(*nxyz), MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(naxes, 3, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(x_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(y_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(z_node, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(cnvtmi, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(transient_fresur, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(steady_flow, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(pv0, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	return;
}
