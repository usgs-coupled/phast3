#if !defined(HDF_H_INCLUDED)
#define HDF_H_INCLUDED
/*
 *   Functions called from FORTRAN
 */
extern "C"
{
	void HDF_CLOSE_TIME_STEP(int *);
	void HDF_FINALIZE_INVARIANT(int *);
	void HDF_INITIALIZE_INVARIANT(int *);
	void HDF_INTERMEDIATE(void);
	void HDF_OPEN_TIME_STEP(int *iso, double *time, double *cnvtmi, int *print_chem,
							int *print_vel, int *f_scalar_count);
	void HDF_PRNTAR(int *iso, double array[], double frac[], double *cnv, char *name);
	void HDF_VEL(int *iso, double vx_node[], double vy_node[], double vz_node[],
				 int vmask[]);
	void HDF_WRITE_FEATURE(int *iso, char *feature_name, int *nodes1, int *node_count);
	void HDF_WRITE_GRID(int *iso, double x[], double y[], double z[], int *nx, int *ny,
						int *nz, int ibc[], char *UTULBL);
}
// called from C++
void HDFBeginCTimeStep(int iso);
void HDFEndCTimeStep(int iso);
void HDFFillHyperSlab(int iso, std::vector< double > &d, size_t columns);
void HDFFinalize(void);
void HDFInitialize(int iso, const char *prefix, int prefix_l);
void HDFSetScalarNames(int iso, std::vector<std::string> &names);

#endif // !defined(HDF_H_INCLUDED)
