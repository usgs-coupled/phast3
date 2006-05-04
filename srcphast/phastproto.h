/* 
 * hdf.c
 */
#include <iostream>     // std::cout std::cerr
#ifdef HDF5_CREATE
#ifdef PHREEQC_IDENT
static char const svnid[] = "$Id$";
#endif
/*
 *   Functions called from C
 */
/*extern "C" {*/
	void HDF_Init(char* prefix, int prefix_l);
	void HDFBeginCTimeStep(void);
	void HDFSetCell(const int n);
	void HDFEndCTimeStep(void);
/*}*/

/*
 *   Functions called from FORTRAN
 */

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
extern "C" {
void HDF_INIT_INVARIANT(void);
void HDF_Finalize(void);
void HDF_FINALIZE_INVARIANT(void);
void HDF_OPEN_TIME_STEP(double* time, double* cnvtmi, int* print_chem, int* print_vel, int* f_scalar_count);
void HDF_CLOSE_TIME_STEP(void);
void HDF_VEL(double vx_node[], double vy_node[], double vz_node[], int vmask[]);
void HDF_WRITE_FEATURE(char* feature_name, int* nodes1, int* node_count, int feature_name_l);
void HDF_WRITE_GRID(double x[], double y[], double z[], int *nx, int *ny, int *nz, int ibc[], char* UTULBL, int UTULBL_l);
void PRNTAR_HDF(double array[], double frac[], double* cnv, char* name, int name_l);
}
#endif

/* 
 * hst.c
 */

#if defined(USE_MPI)
FILE *mpi_fopen(const char *filename, const char *mode);
#endif

#ifdef USE_MPI
 int mpi_send_solution(int solution_number, int task_number);
 int mpi_rebalance_load(double time_per_cell, double *frac, int transfer);
 int mpi_recv_solution(int solution_number, int task_number);
 int mpi_set_subcolumn(double *frac);
 int mpi_send_recv_cells(void);
 int mpi_recv_system(int task_number, int iphrq, int ihst, LDBLE *frac);
 int mpi_send_system(int task_number, int iphrq, int ihst, LDBLE *frac);
 int mpi_pack_elt_list(struct elt_list *totals, int *ints, int *i, double *doubles, int *d);
 int mpi_pack_solution(struct solution *solution_ptr, int *ints, int *ii, double *doubles, int *dd);
 int mpi_pack_solution_hst(struct solution *solution_ptr);
 int mpi_set_random(void);
 int mpi_unpack_elt_list(struct elt_list **totals, int *ints, int *i, double *doubles, int *d);
 int mpi_unpack_solution_hst(struct solution *solution_ptr, int solution_number, int msg_size);
 int mpi_unpack_solution(struct solution *solution_ptr, int *ints, int *ii, double *doubles, int *dd);
 int mpi_distribute_root(void);
 int distribute_from_root(double *fraction, int *dim, int *print_sel,
			  double *time_hst, double *time_step_hst, int *prslm,
			  double *frac, int *printzone_chem, int *printzone_xyz, 
			  int *print_out, int *print_hdf, int *print_restart);
 int mpi_update_root(void);
 int int_compare (const void *ptr1, const void *ptr2);

int mpi_pack_pp_assemblage(struct pp_assemblage *pp_assemblage_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_pack_exchange(struct exchange *exchange_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_pack_gas_phase(struct gas_phase *gas_phase_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_pack_kinetics(struct kinetics *kinetics_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_pack_s_s_assemblage(struct s_s_assemblage *s_s_assemblage_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_pack_surface(struct surface *surface_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_unpack_pp_assemblage(struct pp_assemblage *pp_assemblage_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_unpack_exchange(struct exchange *exchange_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_unpack_gas_phase(struct gas_phase *gas_phase_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_unpack_kinetics(struct kinetics *kinetics_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_unpack_s_s_assemblage(struct s_s_assemblage *s_s_assemblage_ptr, int *ints, int *ii, double *doubles, int *dd);
int mpi_unpack_surface(struct surface *surface_ptr, int *ints, int *ii, double *doubles, int *dd);
#endif

void buffer_to_solution(struct solution *solution_ptr);

/*
 *  hstsubs.c
 */
void add_all_components(void);
void buffer_print(const char *ptr, int n);
void buffer_to_hst(double *first, int dim);
void buffer_to_mass_fraction(void);
void buffer_to_moles(void);
void buffer_to_solution(struct solution *solution_ptr);
int calc_dummy_kinetic_reaction(struct kinetics *kinetics_ptr);
void copy_system_to_user(struct system *system_ptr, int n_user);
void copy_user_to_system(struct system *system_ptr, int n_user, int n_user_new);
int file_exists(const char* name);
int file_rename(const char *temp_name, const char* name, const char* backup_name);
void hst_moles_to_buffer(double *first, int dim);
void hst_to_buffer(double *first, int dim);
struct system *system_initialize(int i, int n_user_new, int *initial_conditions1, int *initial_conditions2, double *fraction1);
void moles_to_hst(double *first, int dim);
int print_using_hst(int cell_number);
int scale_solution(int n_solution, double kg);
void set_use_hst(int i);
void solution_to_buffer(struct solution *solution_ptr);
void unpack_from_hst(double *fraction, int *dim);
int write_restart(double hst_time);
int write_restart_init(std::ofstream& ofs, double time_hst);
int xexchange_save_hst(int n);
int xgas_save_hst(int n);
int xpp_assemblage_save_hst(int n);
int xsolution_save_hst(int n);
int xsurface_save_hst(int n);
int xs_s_assemblage_save_hst(int n);
/*
 * merge.c
 */
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
void MergeFinalize(void);
void MergeFinalizeEcho(void);
void MergeInit(char* prefix, int prefix_l, int solute);
void MergeBeginTimeStep(int print_sel, int print_out);
void MergeEndTimeStep(int print_sel, int print_out);
void MergeBeginCell(void);
void MergeEndCell(void);
int merge_handler(const int action, const int type, const char *name, const int stop, void *cookie, const char *format, va_list args);
#endif
/* 
 * mix.c
 */
int mix_solutions (int n_user1, int n_user2, LDBLE f1, int n_user_new, char *conditions);
int mix_exchange (int n_user1, int n_user2, LDBLE f1, int new_n_user);
int mix_pp_assemblage (int n_user1, int n_user2, LDBLE f1, int new_n_user);
int mix_gas_phase (int n_user1, int n_user2, LDBLE f1, int new_n_user);
int mix_s_s_assemblage (int n_user1, int n_user2, LDBLE f1, int new_n_user);
int mix_kinetics (int n_user1, int n_user2, LDBLE f1, int new_n_user);
int mix_surface (int n_user1, int n_user2, LDBLE f1, int new_n_user);
int partition_uz(int iphrq, int ihst, LDBLE new_frac);
int sum_solutions (struct solution *source1, LDBLE f1, struct solution *source2, LDBLE f2, struct solution *target);
int sum_exchange (struct exchange *source1, LDBLE f1, struct exchange *source2, LDBLE f2, struct exchange *target);
int sum_pp_assemblage (struct pp_assemblage *source1, LDBLE f1, struct pp_assemblage *source2, LDBLE f2, struct pp_assemblage *target);
int sum_gas_phase (struct gas_phase *source1, LDBLE f1, struct gas_phase *source2, LDBLE f2, struct gas_phase *target);
int sum_s_s_assemblage (struct s_s_assemblage *source1, LDBLE f1, struct s_s_assemblage *source2, LDBLE f2, struct s_s_assemblage *target);
int sum_kinetics (struct kinetics *source1, LDBLE f1, struct kinetics *source2, LDBLE f2, struct kinetics *target);
int sum_surface (struct surface *source1, LDBLE f1, struct surface *source2, LDBLE f2, struct surface *target);
struct system *system_alloc(void);
int system_free(struct system *system_ptr);
int system_init(struct system *system_ptr);
int xsolution_save_hst_ptr(struct solution *solution_ptr);
/*
 * phast_files.c
 */
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
int Merge_vfprintf(FILE *stream, const char *format, va_list args);
FILE *mpi_fopen(const char *filename, const char *mode);
#endif
int phast_handler(const int action, const int type, const char *err_str, const int stop, void *cookie, const char *format, va_list args);
