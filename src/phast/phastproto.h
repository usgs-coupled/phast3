/*
 * hdf.c
 */
#include <iostream>				// std::cout std::cerr
#ifdef HDF5_CREATE
#ifdef PHREEQC_IDENT
static char const svnid[] =
	"$Id$";
#endif
/*
 *   Functions called from C
 */
/*extern "C" {*/
void HDF_Init(char *prefix, int prefix_l);
void HDFBeginCTimeStep(void);
void HDFSetCell(const int n);
void HDFEndCTimeStep(void);
/*}*/

/*
 *   Functions called from FORTRAN
 */
#if defined(FC_FUNC_)
#define HDF_INIT_INVARIANT     FC_FUNC_ (hdf_init_invariant,      HDF_INIT_INVARIANT)
#define HDF_FINALIZE_INVARIANT FC_FUNC_ (hdf_finalize_invariant,  HDF_FINALIZE_INVARIANT)
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
#define HDF_WRITE_FEATURE      hdf_write_feature
#define HDF_WRITE_GRID         hdf_write_grid
#define HDF_OPEN_TIME_STEP     hdf_open_time_step
#define HDF_CLOSE_TIME_STEP    hdf_close_time_step
#define PRNTAR_HDF             prntar_hdf
#define HDF_VEL                hdf_vel
#else
#define HDF_INIT_INVARIANT     hdf_init_invariant_
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
#endif

/*
 * hst.cxx
 */

#ifdef USE_MPI
FILE *mpi_fopen(const char *filename, const char *mode);
int mpi_set_subcolumn(double *frac);
int mpi_rebalance_load(double time_per_cell, double *frac, int transfer);
int mpi_set_random(void);
int distribute_from_root(double *fraction, int *dim, int *print_sel,
						 double *time_hst, double *time_step_hst, int *prslm,
						 double *frac, int *printzone_chem,
						 int *printzone_xyz, int *print_out, int *print_hdf,
						 int *print_restart, double *pv, double *pv0);
FILE *mpi_fopen(const char *filename, const char *mode);
#endif
int int_compare(const void *ptr1, const void *ptr2);

/*
 *  hstsubs.c
 */
void add_all_components(void);
void buffer_print(const char *ptr, int n);
void buffer_to_hst(double *first, int dim);
void moles_to_hst(double *first, int dim);
void buffer_to_mass_fraction(void);
void buffer_to_moles(void);
void buffer_to_solution(struct solution *solution_ptr);
void buffer_scale_moles(double f);
void hst_to_buffer(double *first, int dim);
void hst_moles_to_buffer(double *first, int dim);
void set_use_hst(int i);
int xexchange_save_hst(int n);
int xgas_save_hst(int n);
int xpp_assemblage_save_hst(int n);
int xsolution_save_hst(int n);
int xsurface_save_hst(int n);
int xs_s_assemblage_save_hst(int n);
int calc_dummy_kinetic_reaction(struct kinetics *kinetics_ptr);
int print_using_hst(int cell_number);
int file_exists(const char *name);
int file_rename(const char *temp_name, const char *name,
				const char *backup_name);
/*
 * merge.c
 */
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
void MergeInit(char *prefix, int prefix_l, int solute);
void MergeFinalize(void);
void MergeFinalizeEcho(void);
void MergeBeginTimeStep(int print_sel, int print_out);
void MergeEndTimeStep(int print_sel, int print_out);
void MergeBeginCell(void);
void MergeEndCell(int print_sel, int print_out, int print_hdf, int n_proc);
int merge_handler(const int action, const int type, const char *name,
				  const int stop, void *cookie, const char *format,
				  va_list args);
int Merge_vfprintf(FILE * stream, const char *format, va_list args);
#endif
/*
 * cxxHstSubs.cxx
 */
#include "Solution.h"
void buffer_to_cxxsolution(int n);
void cxxsolution_to_buffer(cxxSolution * solution_ptr);
void unpackcxx_from_hst(double *fraction, int *dim);
//void unpackcxx_from_hst_confined(double *fraction, int *dim, double *pv0,
//								 double *pv);
void system_cxxInitialize(int i, int n_user_new, int *initial_conditions1,
					 int *initial_conditions2, double *fraction1,
					 int *exchange_units, int *surface_units, int *ssassemblage_units,
					 int *ppassemblage_units, int *gasphase_units, int *kinetics_units,
					 double porosity_factor);
int write_restart(double hst_time);
int scale_cxxsystem(int iphrq, LDBLE frac);
int partition_uz(int iphrq, int ihst, LDBLE new_frac);
