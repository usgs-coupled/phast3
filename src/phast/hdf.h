#if !defined(HDF_H_INCLUDED)
#define HDF_H_INCLUDED
/*
 *   Functions called from FORTRAN
 */
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif
#if defined(FC_FUNC_)
#define HDF_INIT_INVARIANT     FC_FUNC_ (hdf_init_invariant,      HDF_INIT_INVARIANT)
#define HDF_FINALIZE_INVARIANT FC_FUNC_ (hdf_finalize_invariant,  HDF_FINALIZE_INVARIANT)
#define HDF_INTERMEDIATE       FC_FUNC_ (hdf_intermediate,        HDF_INTERMEDIATE)
#define HDF_WRITE_FEATURE      FC_FUNC_ (hdf_write_feature,       HDF_WRITE_FEATURE)
#define HDF_WRITE_GRID         FC_FUNC_ (hdf_write_grid,          HDF_WRITE_GRID)
#define HDF_OPEN_TIME_STEP     FC_FUNC_ (hdf_open_time_step,      HDF_OPEN_TIME_STEP)
#define HDF_CLOSE_TIME_STEP    FC_FUNC_ (hdf_close_time_step,     HDF_CLOSE_TIME_STEP)
#define PRNTAR_HDF             FC_FUNC_ (prntar_hdf,              PRNTAR_HDF)
#define HDF_VEL                FC_FUNC_ (hdf_vel,                 HDF_VEL)
#else
#if !defined(LAHEY_F95) && !defined(_WIN32) || defined(NO_UNDERSCORES)
#define HDF_INIT_INVARIANT     hdf_init_invariant
#define HDF_FINALIZE_INVARIANT hdf_finalize_invariant
#define HDF_INTERMEDIATE       hdf_intermediate
#define HDF_WRITE_FEATURE      hdf_write_feature
#define HDF_WRITE_GRID         hdf_write_grid
#define HDF_OPEN_TIME_STEP     hdf_open_time_step
#define HDF_CLOSE_TIME_STEP    hdf_close_time_step
#define PRNTAR_HDF             prntar_hdf
#define HDF_VEL                hdf_vel
#else
#define HDF_INIT_INVARIANT     hdf_init_invariant_
#define HDF_INTERMEDIATE       hdf_intermediate_
#define HDF_FINALIZE_INVARIANT hdf_finalize_invariant_
#define HDF_WRITE_FEATURE      hdf_write_feature_
#define HDF_WRITE_GRID         hdf_write_grid_
#define HDF_OPEN_TIME_STEP     hdf_open_time_step_
#define HDF_CLOSE_TIME_STEP    hdf_close_time_step_
#define PRNTAR_HDF             prntar_hdf_
#define HDF_VEL                hdf_vel_
#endif
#endif
extern "C"
{
	void HDF_INIT_INVARIANT(void);
	void HDF_INTERMEDIATE(void);
	void HDF_Finalize(void);
	void HDF_FINALIZE_INVARIANT(void);
	void HDF_OPEN_TIME_STEP(double *time, double *cnvtmi, int *print_chem,
							int *print_vel, int *f_scalar_count);
	void HDF_CLOSE_TIME_STEP(void);
	void HDF_VEL(double vx_node[], double vy_node[], double vz_node[],
				 int vmask[]);
	void HDF_WRITE_FEATURE(char *feature_name, int *nodes1, int *node_count,
						   int feature_name_l);
	void HDF_WRITE_GRID(double x[], double y[], double z[], int *nx, int *ny,
						int *nz, int ibc[], char *UTULBL, int UTULBL_l);
	void PRNTAR_HDF(double array[], double frac[], double *cnv, char *name,
					int name_l);
}


void HDF_Init(const char *prefix, int prefix_l);
void HDFBeginCTimeStep(int n);
void HDFFillHyperSlab(int chem_number, std::vector< double > &d, size_t columns);
//void HDFSetCell(const int n, std::vector <std::vector <int> > &back);
void HDFEndCTimeStep(std::vector <std::vector <int> > &back);
void HDFSetScalarNames(std::vector<std::string> &names);
//void HDFFillHyperSlab(int chem_number, std::vector < LDBLE > &d);
#endif // !defined(HDF_H_INCLUDED)