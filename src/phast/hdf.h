#if !defined(HDF_H_INCLUDED)
#define HDF_H_INCLUDED
/*
 *   Functions called from FORTRAN
 */
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif
#if defined(FC_FUNC_)
#define HDF_CLOSE_TIME_STEP    FC_FUNC_ (hdf_close_time_step,     HDF_CLOSE_TIME_STEP)
#define HDF_FINALIZE_INVARIANT FC_FUNC_ (hdf_finalize_invariant,  HDF_FINALIZE_INVARIANT)
#define HDF_INITIALIZE_INVARIANT FC_FUNC_ (hdf_initialize_invariant, HDF_INITIALIZE_INVARIANT)
#define HDF_INTERMEDIATE       FC_FUNC_ (hdf_intermediate,        HDF_INTERMEDIATE)
#define HDF_OPEN_TIME_STEP     FC_FUNC_ (hdf_open_time_step,      HDF_OPEN_TIME_STEP)
#define HDF_PRNTAR             FC_FUNC_ (hdf_prntar,              HDF_PRNTAR)
#define HDF_VEL                FC_FUNC_ (hdf_vel,                 HDF_VEL)
#define HDF_WRITE_FEATURE      FC_FUNC_ (hdf_write_feature,       HDF_WRITE_FEATURE)
#define HDF_WRITE_GRID         FC_FUNC_ (hdf_write_grid,          HDF_WRITE_GRID)
#else
#if !defined(LAHEY_F95) && !defined(_WIN32) || defined(NO_UNDERSCORES)
#define HDF_CLOSE_TIME_STEP    hdf_close_time_step
#define HDF_FINALIZE_INVARIANT hdf_finalize_invariant
#define HDF_INITIALIZE_INVARIANT     hdf_initialize_invariant
#define HDF_INTERMEDIATE       hdf_intermediate
#define HDF_OPEN_TIME_STEP     hdf_open_time_step
#define HDF_PRNTAR             hdf_prntar
#define HDF_VEL                hdf_vel
#define HDF_WRITE_FEATURE      hdf_write_feature
#define HDF_WRITE_GRID         hdf_write_grid
#else
#define HDF_CLOSE_TIME_STEP    hdf_close_time_step_
#define HDF_FINALIZE_INVARIANT hdf_finalize_invariant_
#define HDF_INITIALIZE_INVARIANT     hdf_initialize_invariant_
#define HDF_INTERMEDIATE       hdf_intermediate_
#define HDF_OPEN_TIME_STEP     hdf_open_time_step_
#define HDF_PRNTAR             hdf_prntar_
#define HDF_VEL                hdf_vel_
#define HDF_WRITE_FEATURE      hdf_write_feature_
#define HDF_WRITE_GRID         hdf_write_grid_
#endif
#endif
extern "C"
{
	void HDF_CLOSE_TIME_STEP(int *);
	void HDF_FINALIZE_INVARIANT(int *);
	void HDF_INITIALIZE_INVARIANT(int *);
	void HDF_INTERMEDIATE(void);
	void HDF_OPEN_TIME_STEP(int *iso, double *time, double *cnvtmi, int *print_chem,
							int *print_vel, int *f_scalar_count);
	void HDF_PRNTAR(int *iso, double array[], double frac[], double *cnv, char *name,
					int name_l);
	void HDF_VEL(int *iso, double vx_node[], double vy_node[], double vz_node[],
				 int vmask[]);
	void HDF_WRITE_FEATURE(int *iso, char *feature_name, int *nodes1, int *node_count,
						   int feature_name_l);
	void HDF_WRITE_GRID(int *iso, double x[], double y[], double z[], int *nx, int *ny,
						int *nz, int ibc[], char *UTULBL, int UTULBL_l);
}
// called from C++
void HDFBeginCTimeStep(int iso);
void HDFEndCTimeStep(int iso);
void HDFFillHyperSlab(int iso, std::vector< double > &d, size_t columns);
void HDFFinalize(void);
void HDFInitialize(int iso, const char *prefix, int prefix_l);
void HDFSetScalarNames(int iso, std::vector<std::string> &names);

#endif // !defined(HDF_H_INCLUDED)