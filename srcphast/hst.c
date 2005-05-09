#define EXTERNAL
#define MAIN
#include "phreeqc/global.h"
#include "phreeqc/output.h"
#include "hst.h"
#include "phreeqc/phqalloc.h"
#include "phreeqc/phrqproto.h"
#include "phreeqc/input.h"
#include "phast_files.h"
#include "phastproto.h"

static void BeginTimeStep(int print_sel, int print_out, int print_hdf);
static void EndTimeStep(int print_sel, int print_out, int print_hdf);
static void BeginCell(int print_sel, int print_out, int print_hdf, int index);
static void EndCell(int print_sel, int print_out, int print_hdf, int index);

static char const svnid[] = "$Id$";
#define RANDOM
#define REBALANCE
/* #define USE_MPI set in makefile */
#ifdef USE_MPI
 #define MESSAGE_MAX_NUMBERS 1000
 #include <mpi.h>
 #define MPI_MAX_TASKS 50
 #include <time.h>
 int mpi_tasks;
 int mpi_myself;
 int mpi_first_cell;
 int mpi_last_cell;
 int total_prep;
 int *random_list;
 LDBLE *random_frac;
 int *random_printzone_chem, *random_printzone_xyz;
 void * mpi_buffer;
 int mpi_buffer_position, mpi_max_buffer;
 LDBLE mpi_processor_test_time;
 int end_cells[MPI_MAX_TASKS][2];
 int number_cells[MPI_MAX_TASKS];

#define TIME
#ifdef TIME
LDBLE start_time, end_time, transport_time, transport_time_tot, chemistry_time, chemistry_time_tot, wait_time, wait_time_tot, optimum_chemistry, optimum_serial_time;
#endif
int static call_counter=0;
#else  /* #ifdef USE_MPI */
 const int mpi_tasks      = 1;
 const int mpi_myself     = 0;
static void EQUILIBRATE_SERIAL(double *fraction, int *dim, int *print_sel,
			 double *x_hst, double *y_hst, double *z_hst,
			 double *time_hst, double *time_step_hst, int *prslm, double *cnvtmi,
			 double *frac, int *printzone_chem, int *printzone_xyz,
			 int *print_out, int *print_hdf,
			 int *adjust_water_rock_ratio);
#endif  /* #ifdef USE_MPI */

#define CALCULATE_WELL_PH calculate_well_ph_
#define COLLECT_FROM_NONROOT collect_from_nonroot_
#define COUNT_ALL_COMPONENTS count_all_components_
#define CONVERT_TO_MOLAL convert_to_molal_
#define CONVERT_TO_MASS_FRACTION convert_to_mass_fraction_
#define DISTRIBUTE_INITIAL_CONDITIONS distribute_initial_conditions_
#define EQUILIBRATE equilibrate_
#define ERRPRT_C errprt_c_
#define FORWARD_AND_BACK forward_and_back_
#define LOGPRT_C logprt_c_
#define ON_ERROR_CLEANUP_AND_EXIT on_error_cleanup_and_exit_
#define PACK_FOR_HST pack_for_hst_
#define PHREEQC_FREE phreeqc_free_
#define PHREEQC_MAIN phreeqc_main_
#define SETUP_BOUNDARY_CONDITIONS setup_boundary_conditions_
#define WARNPRT_C warnprt_c_
#define UZ_INIT uz_init_


void CALCULATE_WELL_PH(double *c, LDBLE *ph, LDBLE *alkalinity);
void COLLECT_FROM_NONROOT(double *fraction, int *dim);
void CONVERT_TO_MASS_FRACTION(double *c, int *n, int *dim);
void CONVERT_TO_MOLAL(double *c, int *n, int *dim);
void COUNT_ALL_COMPONENTS(int *n_comp, char *names, int length);
void DISTRIBUTE_INITIAL_CONDITIONS(int *initial_conditions1, int *initial_conditions2, double *fraction1);
/*  #ifndef USE_MPI                                                                    */
/*  void EQUILIBRATE(double *fraction, int *dim, int *hst_print,                       */
/*  		 double *x_hst, double *y_hst, double *z_hst,                          */
/*  		 double *time_hst, double *time_step_hst, int *prslm, double *cnvtmi,  */
/*  		 double *frac, int *printzone, int *print_out);                 */
/*  #else                                                                              */
void EQUILIBRATE(double *fraction, int *dim, int *print_sel,
		 double *x_hst, double *y_hst, double *z_hst,
		 double *time_hst, double *time_step_hst, int *prslm, double *cnvtmi,
		 double *frac, int *printzone_chem, int *printzone_xyz, 
		 int *print_out, int *stop_msg, int *print_hdf,
		 int *adjust_water_rock_ratio);
/*  #endif                                                                             */

void ERRPRT_C(char *err_str, long l);
void FORWARD_AND_BACK(int *initial_conditions, int *axes, int *nx, int *ny, int *nz);
void ON_ERROR_CLEANUP_AND_EXIT(void);
void PACK_FOR_HST(double *fraction, int *dim);
void PHREEQC_FREE(int *solute);
void PHREEQC_MAIN(int *solute, char *chemistry_name, char *database_name, char *prefix,
		  int *mpi_tasks_fort, int *mpi_myself_fort, int chemistry_l, int database_l, int prefix_l);
void SETUP_BOUNDARY_CONDITIONS(const int *n_boundary, int *boundary_solution1,
			       int *boundary_solution2, double *fraction1,
			       double *boundary_fraction, int *dim);
int UZ_INIT(int * transient_fresur);
int n_to_ijk(int n_cell, int *i, int *j, int *k);

/* ---------------------------------------------------------------------- */
void PHREEQC_FREE(int *solute)
/* ---------------------------------------------------------------------- */
/*
 *   free space
 */
{
	int i;
  if (svnid == NULL) fprintf(stderr," ");
#ifdef HDF5_CREATE
  HDF_Finalize();
#endif

#ifdef USE_MPI
	MPI_Finalize();
	free_check_null(mpi_buffer);
	free_check_null(random_frac);
	free_check_null(random_printzone_chem);
	free_check_null(random_printzone_xyz);
	for (i = 0; i < count_chem; i++) {
		system_free(sz[i]);
		free_check_null(sz[i]);
	}
	free_check_null(sz);	
	free_check_null(frac1);
#endif
	if (*solute) {
		free_model_allocs();
		free_check_null(buffer);
		free_check_null(activity_list);
		free_check_null(forward);
		free_check_null(back);
		free_check_null(file_prefix);
		free_check_null(old_frac);
		if (uz != NULL) {
			for (i = 0; i < count_chem; i++) {
				system_free(uz[i]);
				free_check_null(uz[i]);
			}
			free_check_null(uz);
		}
		clean_up();
	} else {
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
		MergeFinalizeEcho();
#endif
	}
	close_output_files();
	return;
}
/* ---------------------------------------------------------------------- */
void PHREEQC_MAIN(int *solute, char *chemistry_name, char *database_name, char *prefix,
		  int *mpi_tasks_fort, int *mpi_myself_fort, int chemistry_l, int database_l, int prefix_l)
/* ---------------------------------------------------------------------- */
/*
 *   Main program for PHREEQC
 */
{
	int errors;
	void *db_cookie = NULL;
	void *input_cookie = NULL;

#if defined(WIN32_MEMORY_DEBUG)	
	int tmpDbgFlag;
	tmpDbgFlag = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
	tmpDbgFlag |= _CRTDBG_LEAK_CHECK_DF;
	/**
	tmpDbgFlag |= _CRTDBG_DELAY_FREE_MEM_DF;
	tmpDbgFlag |= _CRTDBG_CHECK_ALWAYS_DF;
	**/
	_CrtSetDbgFlag(tmpDbgFlag);
#endif

	phast = TRUE;
	chemistry_name[chemistry_l-1] = '\0';
	prefix[prefix_l-1] = '\0';
	database_name[database_l-1] = '\0';
	file_prefix = string_duplicate(prefix);
	/*
	 *   Add callbacks for echo_file
	 */
	if (add_output_callback(phast_handler, NULL) != OK) {
		fprintf(stderr, "ERROR: %s\n", "NULL pointer returned from malloc or realloc.");
		fprintf(stderr, "ERROR: %s\n", "Program terminating.");
		clean_up();
		exit(1);
		/* return(-1);*/
	}
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	/*
	 *   Add callbacks for merge
	 */
	if (add_output_callback(merge_handler, NULL) != OK) {
		fprintf(stderr, "ERROR: %s\n", "NULL pointer returned from malloc or realloc.");
		fprintf(stderr, "ERROR: %s\n", "Program terminating.");
		clean_up();
		exit(1);
		/* return(-1);*/
	}
#endif
	/*
	 *   Set jump for errors
	 */
	errors = setjmp(mark);
	if (errors != 0) {
		clean_up();
		exit(1);
		/* return errors;*/
	}
	/*
	 *  MPI stuff
	 */
#ifdef USE_MPI
	mpi_tasks = *mpi_tasks_fort;
	mpi_myself = *mpi_myself_fort;
#ifdef TIME
	start_time = (LDBLE) MPI_Wtime();
#endif
#endif  /* #ifdef USE_MPI */
	/*
	 *   initialize HDF
	 */
#ifdef HDF5_CREATE
	HDF_Init(prefix, prefix_l);
#endif
	/*
	 *  open echo file, searches for end of phastinput data
	 *  Must precede MergeInit, output_open could delete .log file
	 *  on mpi version.
	 */
	open_echo(prefix);
	/*
	 *   initialize merge
	 */
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	output_close(OUTPUT_ECHO);
	MergeInit(prefix, prefix_l, *solute); 	/* opens .O.chem,  .xyz.chem, .log */
# else
	open_output_file(prefix, *solute);
#endif
	if (errors != 0) {
		clean_up();
		exit(1);
		/*return errors;*/
	}
	if (mpi_myself == 0) {
		output_msg(OUTPUT_ECHO, "Running PHAST.\n\n");
	}
	/*
	 *  Return if flow only simulation
	 */
	if (*solute == FALSE) return/*(0)*/;
	/*
	 *   Open input files
	 */
	errors = open_input_files_phast(chemistry_name, database_name, &db_cookie, &input_cookie);
	/*
	 *   Initialize arrays
	 */
	errors = do_initialize();
	phreeqc_mpi_myself = mpi_myself;
	if (errors != 0) {
		clean_up();
		exit(1);
		/*return errors;*/
	}
	if (mpi_myself == 0) {
		output_msg(OUTPUT_ECHO, "Running PHREEQC for initial conditions.\n\n");
	}
	/*
	 *   Read data base
	 */
	if (mpi_myself == 0) {
	  output_msg(OUTPUT_ECHO,"Processing database file.\n");
	}
	errors = read_database(getc_callback, db_cookie);
	if (errors != 0) {
		clean_up();
		exit(1);
		/* return errors; */
	}
	if (mpi_myself == 0) {
	  output_msg(OUTPUT_LOG,"\nSuccessfully processed database file.\n");
	}
	/*
	 *   Read input data for simulation
	 */
	if (mpi_myself == 0) {
		output_msg(OUTPUT_ECHO,"\nProcessing chemical data file.\n");
	}
	errors = run_simulations(getc_callback, input_cookie);
	if (errors != 0) {
		clean_up();
		exit(1);
		/*return errors;*/
	}
	if (mpi_myself == 0) {
	  output_msg(OUTPUT_LOG,"\nSuccessfully processed chemistry data file.\n");
	}
	/*
	 *   Close input files and selected_output file
	 */
	close_input_files();
	output_close(OUTPUT_PUNCH);

#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	/* do nothing */
# else
	open_punch_file(prefix, *solute);
#endif
	if (mpi_myself == 0) output_msg(OUTPUT_ECHO, "PHREEQC done.\n");
	return;
}
/* ---------------------------------------------------------------------- */
void COUNT_ALL_COMPONENTS(int *n_comp, char *names, int length)
/* ---------------------------------------------------------------------- */
{
/*
 *   Counts components in any defined solution, gas_phase, exchanger,
 *   surface, or pure_phase_assemblage
 *
 *   Returns n_comp, which is total, including H, O, elements, and Charge
 *           names contains character strings with names of components
 */
	int i, j, k;
/*
 *   Accumulate all aqueous components
 */
	add_all_components();
/*
 *   Count components, 2 for hydrogen, oxygen,  + others,
 */
	count_component = 2;
	for (i = 0; i < count_master; i++) {
		if (master[i]->total > 0.0 && master[i]->s->type == AQ) {
			count_component++;
		}
	}
	if (transport_charge == TRUE) {
		count_total = count_component++;
	} else {
		count_total = count_component;
	}
/*
 *   Put information in buffer.
 *   Buffer contains an entry for every primary master
 *   species that can be used in the transport problem.
 *   Each entry in buffer is sent to HST for transort.
 */
	buffer = (struct buffer *) PHRQ_malloc ((size_t) count_component * sizeof(struct buffer));
	buffer[0].name = string_hsave("H");
	buffer[0].gfw = s_h2->secondary->elt->primary->elt->gfw;
	buffer[0].master = s_eminus->primary;
	buffer[1].name = string_hsave("O");
	buffer[1].gfw = s_o2->secondary->elt->primary->elt->gfw;
	buffer[1].master = s_h2o->primary;
	j = 2;
	for (i = 0; i < count_master; i++) {
		if (master[i]->total > 0.0 && master[i]->s->type == AQ) {
			buffer[j].name = master[i]->elt->name;
			buffer[j].master = master[i];
			buffer[j].gfw = master[i]->elt->gfw;
			buffer[j].first_master = -1;
			buffer[j].last_master = -1;
			j++;
		}
	}
/* Bogus component used if surface reactions are included */
	if (transport_charge == TRUE) {
		buffer[j].name = string_hsave("Charge");
		buffer[j].gfw = s_h2->secondary->elt->primary->elt->gfw;
		buffer[j].master = s_eminus->primary;
	}
	output_msg(OUTPUT_MESSAGE, "List of Components:\n");
	for (i = 0; i < count_component; i++) {
		output_msg(OUTPUT_MESSAGE, "\t%d\t%s\n", i+1, buffer[i].name);
		for (j=0; buffer[i].name[j] != '\0'; j++) {
			names[i * length + j] = buffer[i].name[j];
		}
	}
/*
 *   Make list of all master species, one for each non redox element
 *   one for each secondary master of redox elements
 */
	count_activity_list = 0;
	for (i = 0; i < count_master; i++) {
		if (master[i]->total > 0.0 && master[i]->s->type == AQ) {
			if ((i + 1 < count_master) && (master[i+1]->primary == FALSE)) {
				for (k = i+1; k < count_master; k++) {
					if (master[k]->primary == FALSE) {
						count_activity_list++;
					} else {
						break;
					}
				}
			} else {
				count_activity_list++;
			}
		}
	}
/*
 *   malloc space
 */
	activity_list = (struct activity_list *) PHRQ_malloc ((size_t) count_activity_list * sizeof(struct activity_list));
	count_activity_list = 0;
	for (i = 0; i < count_master; i++) {
		if (master[i]->total > 0.0 && master[i]->s->type == AQ) {
			if ((i + 1 < count_master) && (master[i+1]->primary == FALSE)) {
				for (k = i+1; k < count_master; k++) {
					if (master[k]->primary == FALSE) {
						activity_list[count_activity_list].master = master[k];
						activity_list[count_activity_list].name = master[k]->elt->name;
						count_activity_list++;
					} else {
						break;
					}
				}
			} else {
				activity_list[count_activity_list].master = master[i];
				activity_list[count_activity_list].name = master[i]->elt->name;
				count_activity_list++;
			}
		}
	}
	output_msg(OUTPUT_MESSAGE, "List of master species:\n");
	for (i = 0; i < count_activity_list; i++) {
		output_msg(OUTPUT_MESSAGE, "\t%d\t%s\n", i+1, activity_list[i].name);
	}
/*
 *   Associate buffer master species with activity_list master species
 */
	j = 0;
	for (i = 0; i < count_activity_list; i++) {
		while (activity_list[i].master->elt->primary != buffer[j].master) j++;
		if (buffer[j].first_master < 0) buffer[j].first_master = i;
		if (i > buffer[j].last_master ) buffer[j].last_master = i;
	}
#ifdef SKIP
	for (i = 0; i < count_component; i++) {
		fprintf(stderr,"%s\t%d\t%d\n", buffer[i].name, buffer[i].first_master, buffer[i].last_master);
	}
#endif
/*
 *   Realloc space for totals and activities for all solutions to make
 *   enough room during hst simulation, put array in standard form
 */

	for (i = 0; i < count_solution; i++) {
		xsolution_zero();
		add_solution(solution[i], 1.0/solution[i]->mass_water, 1.0);
		solution[i]->totals = PHRQ_realloc (solution[i]->totals, (size_t) (count_total - 1) * sizeof(struct conc));
		if (solution[i]->totals == NULL) malloc_error();
		solution[i]->master_activity = PHRQ_realloc (solution[i]->master_activity, (size_t) (count_activity_list + 1) * sizeof(struct master_activity));
		if (solution[i]->master_activity == NULL) malloc_error();
		for(j = 2; j < count_total; j++) {
			buffer[j].master->total_primary = buffer[j].master->total;
		}
		xsolution_save_hst(i);
	}
/*
 *   Make sure solution -1 is defined
 */
	if (count_solution > 0) {
		solution_duplicate(solution[0]->n_user, -1);
	} else {
		error_msg("No solutions have been defined.", STOP);
	}
	if (count_exchange > 0) {
		exchange_duplicate(exchange[0].n_user, -1);
	}
	if (count_gas_phase > 0) {
		gas_phase_duplicate(gas_phase[0].n_user, -1);
	}
	if (count_pp_assemblage > 0) {
		pp_assemblage_duplicate(pp_assemblage[0].n_user, -1);
	}
	if (count_surface > 0) {
		surface_duplicate(surface[0].n_user, -1);
	}
	if (count_s_s_assemblage > 0) {
		s_s_assemblage_duplicate(s_s_assemblage[0].n_user, -1);
	}
	if (count_kinetics > 0) {
		kinetics_duplicate(kinetics[0].n_user, -1);
	}

/*
 *   Set pe data structrure for all calculations
 */
	pe_data_free (pe_x);
	pe_x = pe_data_alloc();
/*
 *   Beginning of stored data for HST
 */
	first_solution = count_solution;
	first_gas_phase = count_gas_phase;
	first_exchange = count_exchange;
	first_pp_assemblage = count_pp_assemblage;
	first_surface = count_surface;
	first_s_s_assemblage = count_s_s_assemblage;
	first_kinetics = count_kinetics;

	*n_comp = count_component;
	/* mass_water_switch = TRUE; */
	delay_mass_water = FALSE;
	last_model.force_prep = TRUE;
	simulation = -1;
	return;
}
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
void DISTRIBUTE_INITIAL_CONDITIONS(int *initial_conditions1, int *initial_conditions2, double *fraction1)
/* ---------------------------------------------------------------------- */
{
/*
 *      ixyz - number of cells
 *      initial_conditions1 - Fortran, 7 x n_cell integer array, containing
 *           solution number
 *           pure_phases number
 *           exchange number
 *           surface number
 *           gas number
 *           solid solution number
 *           kinetics number
 *      initial_conditions2 - Fortran, 7 x n_cell integer array, containing
 *      fraction for 1 - Fortran, 7 x n_cell integer array, containing
 *
 *      Routine mixes solutions, pure_phase assemblages,
 *      exchangers, surface complexers, gases, solid solution assemblages,
 *      and kinetics for each cell.
 */
	int i;
	int first_cell, last_cell;
	int *sort_random_list;

	int j, k;
	/*
	 *  Save pointers to initial condition arrays
	 *  When rebalancing, these are used to initialize a system
	 */
	initial1 = initial_conditions1;
	initial2 = initial_conditions2;
	frac1 = PHRQ_malloc((size_t) 7*ixyz * sizeof(double));
	if (frac1 == NULL) malloc_error();
	for (j = 0; j < 7*ixyz; j++) {
		frac1[j] = fraction1[j];
	}
	/*
	 *  Set up random list for parallel processing
	 */
	random_list = PHRQ_malloc((size_t) count_chem * sizeof(int));
	if (random_list == NULL) malloc_error();
	random_frac = PHRQ_malloc((size_t) count_chem * sizeof(LDBLE));
	if (random_frac == NULL) malloc_error();
	random_printzone_chem = PHRQ_malloc((size_t) count_chem * sizeof(int));
	if (random_printzone_chem == NULL) malloc_error();
	random_printzone_xyz = PHRQ_malloc((size_t) count_chem * sizeof(int));
	if (random_printzone_xyz == NULL) malloc_error();
	if (mpi_myself == 0) mpi_set_random();
	MPI_Bcast(random_list, count_chem,                MPI_INT,    0, MPI_COMM_WORLD);
	count_cells = count_chem;
	mpi_set_subcolumn(NULL);
	mpi_buffer = PHRQ_malloc(sizeof(char));
	if (mpi_buffer == NULL) malloc_error();
        /*  left in equilibrate */
	/*
	wait_time = 0;
	wait_time_tot = 0;
	mpi_max_buffer = 1;
	*/
	/* 
	 * sort_random_list is the list of cell numbers that need to be saved for this processor
	 */
	first_cell = mpi_first_cell;
	last_cell = mpi_last_cell;
	sort_random_list = PHRQ_malloc((size_t) (last_cell - first_cell + 1) * sizeof(int));
	if (sort_random_list == NULL) malloc_error();
	memcpy(sort_random_list, &random_list[first_cell], (size_t) (last_cell - first_cell + 1) * sizeof(int));
	qsort (sort_random_list, (size_t) (last_cell - first_cell + 1), (size_t) sizeof(int), int_compare);

	/*
	 *  Allocate array for count_chem systems, sz
	 *  sz[i] == NULL, cell is not calculated by this processor
	 *  sz[i] != NULL, cell is calculated by this processor
	 */
	sz = PHRQ_malloc((size_t) (count_chem * sizeof(struct system)));
	if (sz == NULL) malloc_error();
	for (i = 0; i < count_chem; i++) {
		sz[i] = NULL;
	}
/*
 *  Copy solution, exchange, surface, gas phase, kinetics, solid solution for each active cell.
 */
	for (k = 0; k < last_cell - first_cell + 1; k++) {
		j = sort_random_list[k];  /* j is count_chem number */
		i = back[j].list[0];      /* i is ixyz number */
		assert (forward[i] >= 0); 
		sz[j] = system_initialize(i, j, initial1, initial2, frac1);   
	}
	sort_random_list = free_check_null(sort_random_list);
	if (input_error > 0) {
		error_msg("Terminating in distribute_initial_conditions.\n", STOP);
	}
	return;
}
#else
/* ---------------------------------------------------------------------- */
void DISTRIBUTE_INITIAL_CONDITIONS(int *initial_conditions1, int *initial_conditions2, double *fraction1)
/* ---------------------------------------------------------------------- */
{
/*
 *      ixyz - number of cells
 *      initial_conditions1 - Fortran, 7 x n_cell integer array, containing
 *           solution number
 *           pure_phases number
 *           exchange number
 *           surface number
 *           gas number
 *           solid solution number
 *           kinetics number
 *      initial_conditions2 - Fortran, 7 x n_cell integer array, containing
 *      fraction for 1 - Fortran, 7 x n_cell integer array, containing
 *
 *      Routine mixes solutions, pure_phase assemblages,
 *      exchangers, surface complexers, gases, solid solution assemblages,
 *      and kinetics for each cell.
 */
	int i, n_new, n_old1, n_old2;
	LDBLE f1;
	int alloc_solution, alloc_pp_assemblage, alloc_exchange, alloc_surface;
	int alloc_gas_phase, alloc_kinetics, alloc_s_s_assemblage;

	alloc_solution = 10;
	alloc_pp_assemblage = 10;
	alloc_exchange = 10;
	alloc_surface = 10;
	alloc_gas_phase = 10;
	alloc_kinetics = 10;
	alloc_s_s_assemblage = 10;

/*
 *  Count numbers of pp_assemblage, exchange, surface,
 *  gas_phase, kinetics, and solid solutions to allocate
 */
	for (i = 0; i < ixyz; i++) {
		if (forward[i] < 0) continue;
/*
 *   Count solutions
 */
		n_old1 = initial_conditions1[7*i];
		if (n_old1 >= 0) {
			alloc_solution++;
		}
/*
 *   Count pp_assemblage
 */
		n_old1 = initial_conditions1[ 7*i + 1 ];
		if (n_old1 >= 0) {
			alloc_pp_assemblage++;
		}
/*
 *   Count exchange assemblage
 */
		n_old1 = initial_conditions1[ 7*i + 2 ];
		if (n_old1 >= 0) {
			alloc_exchange++;
		}
/*
 *   Count surface assemblage
 */
		n_old1 = initial_conditions1[ 7*i + 3 ];
		if (n_old1 >= 0) {
			alloc_surface++;
		}
/*
 *   Count gas phase
 */
		n_old1 = initial_conditions1[ 7*i + 4 ];
		if (n_old1 >= 0) {
			alloc_gas_phase++;
		}
/*
 *   Count solid solution
 */
		n_old1 = initial_conditions1[ 7*i + 5 ];
		if (n_old1 >= 0) {
			alloc_s_s_assemblage++;
		}
/*
 *   Count kinetics
 */
		n_old1 = initial_conditions1[ 7*i + 6 ];
		if (n_old1 >= 0) {
			alloc_kinetics++;
		}
	}

/*
 *  Allocate space for solution, pp_assemblage, exchange, surface,
 *  gas_phase, kinetics, and solid solutions to allocate
 */
	space ((void *) &(solution), count_solution + alloc_solution, &max_solution, sizeof (struct solution *) );
	space ((void *) &pp_assemblage, count_pp_assemblage + alloc_pp_assemblage, &max_pp_assemblage, sizeof(struct pp_assemblage));
	space ((void *) &exchange, count_exchange + alloc_exchange, &max_exchange, sizeof(struct exchange));
	space ((void *) &surface, count_surface + alloc_surface, &max_surface, sizeof(struct surface));
	space ((void *) &gas_phase, count_gas_phase + alloc_gas_phase, &max_gas_phase, sizeof(struct gas_phase));
	space ((void *) &kinetics, count_kinetics + alloc_kinetics, &max_kinetics, sizeof(struct kinetics));
	space ((void *) &s_s_assemblage, count_s_s_assemblage + alloc_s_s_assemblage, &max_s_s_assemblage, sizeof(struct s_s_assemblage));
/*
 *  Copy solution, exchange, surface, gas phase, kinetics, solid solution for each active cell.
 */
	for (i = 0; i < ixyz; i++) {
		if (forward[i] < 0) continue;
		n_new = count_solution - first_solution + first_user_number;
/*
 *   Copy solution
 */
		n_old1 = initial_conditions1[7*i];
		n_old2 = initial_conditions2[7*i];
		f1 = fraction1[7*i];
		if (n_old1 >= 0) {
			mix_solutions(n_old1, n_old2, f1, n_new, "initial");
		}
/*
 *   Copy pp_assemblage
 */
		n_old1 = initial_conditions1[ 7*i + 1 ];
		n_old2 = initial_conditions2[ 7*i + 1 ];
		f1 = fraction1[7*i + 1];
		if (n_old1 >= 0) {
			mix_pp_assemblage(n_old1, n_old2, f1, n_new);
		}
/*
 *   Copy exchange assemblage
 */
		n_old1 = initial_conditions1[ 7*i + 2 ];
		n_old2 = initial_conditions2[ 7*i + 2 ];
		f1 = fraction1[7*i + 2];
		if (n_old1 >= 0) {
			mix_exchange(n_old1, n_old2, f1, n_new);
		}
/*
 *   Copy surface assemblage
 */
		n_old1 = initial_conditions1[ 7*i + 3 ];
		n_old2 = initial_conditions2[ 7*i + 3 ];
		f1 = fraction1[7*i + 3];
		if (n_old1 >= 0) {
			mix_surface(n_old1, n_old2, f1, n_new);
		}
/*
 *   Copy gas phase
 */
		n_old1 = initial_conditions1[ 7*i + 4 ];
		n_old2 = initial_conditions2[ 7*i + 4 ];
		f1 = fraction1[7*i + 4];
		if (n_old1 >= 0) {
			mix_gas_phase(n_old1, n_old2, f1, n_new);
		}
/*
 *   Copy solid solution
 */
		n_old1 = initial_conditions1[ 7*i + 5 ];
		n_old2 = initial_conditions2[ 7*i + 5 ];
		f1 = fraction1[7*i + 5];
		if (n_old1 >= 0) {
			mix_s_s_assemblage(n_old1, n_old2, f1, n_new);
		}
/*
 *   Copy kinetics
 */
		n_old1 = initial_conditions1[ 7*i + 6 ];
		n_old2 = initial_conditions2[ 7*i + 6 ];
		f1 = fraction1[7*i + 6];
		if (n_old1 >= 0) {
			mix_kinetics(n_old1, n_old2, f1, n_new);
		}
	}
	if (input_error > 0) {
		error_msg("Terminating in distribute_initial_conditions.\n", STOP);
	}
	return;
}
#endif
/* ---------------------------------------------------------------------- */
void SETUP_BOUNDARY_CONDITIONS(const int *n_boundary, int *boundary_solution1,
			       int *boundary_solution2, double *fraction1,
			       double *boundary_fraction, int *dim)
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes a list of solution numbers and returns a set of
 *   mass fractions
 *   Input: n_boundary - number of boundary conditions in list
 *          boundary_solution1 - list of first solution numbers to be mixed
 *          boundary_solution2 - list of second solution numbers to be mixed
 *          fraction1 - fraction of first solution 0 <= f <= 1
 *          dim - leading dimension of array boundary mass fractions
 *                must be >= to n_boundary
 *
 *   Output: boundary_fraction - mass fractions for boundary conditions
 *                             - dimensions must be >= n_boundary x n_comp
 *
 */
	int i, n_old1, n_old2;
	int n;
	LDBLE f1;

	struct solution *solution_ptr;
	for (i = 0; i < *n_boundary; i++) {
		n_old1 = boundary_solution1[i];
		n_old2 = boundary_solution2[i];
		f1 = fraction1[i];
		if (n_old1 >= 0) {
			mix_solutions(n_old1, n_old2, f1, -1, "boundary");
		} else {
			continue;
#ifdef SKIP
			/* allow negative number, should be for pumping well solution is not required */
			input_error++;
			error_msg("Negative solution number in boundary conditions.", CONTINUE);
#endif
		}
		solution_ptr = solution_bsearch(-1, &n, TRUE);
		solution_to_buffer(solution[n]);
		buffer_to_mass_fraction();
/*
		fprintf(stderr,"setup_boundary_conditions\n");
		buffer_print("Boundary", i);
 */
		buffer_to_hst(&boundary_fraction[i], *dim);
	}

	return;
}
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
void PACK_FOR_HST(double *fraction, int *dim)
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes solution data and makes array of mass fractions for HST
 *   Input: n_cell - number of cells in model
 *          dim - leading dimension of 2-d array fraction
 *
 *   Output: fraction - mass fractions of all components in all solutions
 *                      dimensions must be >= n_cell x n_comp
 */
	int i, j;

	for (i = 0; i < count_chem; i++) {
		solution_to_buffer(sz[i]->solution);
		buffer_to_mass_fraction();
		for (j = 0; j < count_back_list; j++) {
			buffer_to_hst(&fraction[back[i].list[j]], *dim);
		}
	}
	return;
}
#else
/* ---------------------------------------------------------------------- */
void PACK_FOR_HST(double *fraction, int *dim)
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes solution data and makes array of mass fractions for HST
 *   Input: n_cell - number of cells in model
 *          dim - leading dimension of 2-d array fraction
 *
 *   Output: fraction - mass fractions of all components in all solutions
 *                      dimensions must be >= n_cell x n_comp
 */
	int i, j, n;

	solution_bsearch(first_user_number, &first_solution, TRUE);
	for (i = 0; i < count_chem; i++) {
		n = first_solution + i;
		solution_to_buffer(solution[n]);
		buffer_to_mass_fraction();
		for (j = 0; j < count_back_list; j++) {
			buffer_to_hst(&fraction[back[i].list[j]], *dim);
		}
	}
	return;
}
#endif
#ifndef USE_MPI
/* ---------------------------------------------------------------------- */
static void EQUILIBRATE_SERIAL(double *fraction, int *dim, int *print_sel,
			double *x_hst, double *y_hst, double *z_hst,
			double *time_hst, double *time_step_hst, int *prslm, double *cnvtmi,
			double *frac, 
			int *printzone_chem,  int *printzone_xyz,
			int *print_out, int *print_hdf,
			int *adjust_water_rock_ratio)
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes mass fractions from HST, equilibrates each cell,
 *   and returns new mass fractions to HST
 *
 *   Input: ixyz - number of cells in model
 *          dim - leading dimension of 2-d array fraction
 *
 *   Output: fraction - mass fractions of all components in all solutions
 *                      dimensions must be >= ixyz x n_comp
 */
	int i, j, tot_same, tot_iter, tot_zero, max_iter;
	int active;
	int n_user;
	LDBLE kin_time;
	static int write_headings = 1;

	pr.all = *print_out;
/*
 *   Update solution compositions
 */
	unpack_from_hst(fraction, dim);
/*
 *   Calculate equilibrium
 */
	n_gas_phase = first_gas_phase;
	n_exchange = first_exchange;
	n_pp_assemblage = first_pp_assemblage;
	n_surface = first_surface;
	n_s_s_assemblage = first_s_s_assemblage;
	n_kinetics = first_kinetics;
	kin_time = *time_step_hst;
 	timest = kin_time;

	state = PHAST;
	tot_same = 0;
	tot_iter = 0;
	tot_zero = 0;
	max_iter = 0;
        if (*print_sel == TRUE) {
		simulation++;
                pr.punch = TRUE;
	} else {
		pr.punch = FALSE;
	}
	pr.hdf = *print_hdf;

	BeginTimeStep(*print_sel, *print_out, *print_hdf);
	if (punch.in == TRUE && write_headings) {
		int pr_punch = pr.punch;
		pr.punch = TRUE;
		/*
		 * write headings
		 */
		punch.new_def = TRUE;
		output_msg(OUTPUT_PUNCH,"%15s\t%15s\t%15s\t%15s\t%2s\t","x","y","z","time","in");
		tidy_punch();
		write_headings = 0;
		pr.punch = pr_punch;
	}

	rate_sim_time_start = *time_hst - *time_step_hst;
	rate_sim_time_end = *time_hst;
	initial_total_time = 0;
	for (i = 0; i < count_chem; i++) {     /* i is count_chem number */
		j = back[i].list[0];           /* j is nxyz number */
		if (transient_free_surface == TRUE) partition_uz(i, j, frac[j]); 
		if (frac[j] < 1e-10) frac[j] = 0.0;
		if ( frac[j] > 0.0) {
			active = TRUE;
		} else {
			active = FALSE;
		}

		if (*print_out == TRUE && printzone_chem[j] == TRUE) {
			pr.all = TRUE;
		} else {
			pr.all = FALSE;
		}
		if (*print_sel == TRUE && printzone_xyz[j] == TRUE && punch.in == TRUE) {
			pr.punch = TRUE;
		} else {
			pr.punch = FALSE;
		}

		BeginCell(*print_sel, *print_out, *print_hdf, j);

		if (pr.punch == TRUE) {
			output_msg(OUTPUT_PUNCH, "%15g\t%15g\t%15g\t%15g\t%2d\t", x_hst[j], y_hst[j],
				z_hst[j], (*time_hst) * (*cnvtmi), active);
			if (active == FALSE) {
				output_msg(OUTPUT_PUNCH, "\n");
			}
		}
		if (active) {
			cell_no = i;
			solution_bsearch(first_user_number, &first_solution, TRUE);
			n_solution = first_solution + i;
			if (*adjust_water_rock_ratio) scale_solution(n_solution, frac[j]); 
			set_use_hst();
			n_user = solution[n_solution]->n_user;
			set_initial_moles(n_user);
			run_reactions(n_user, kin_time, FALSE, 1.0);
			if (iterations == 0) tot_zero++;
			if (iterations > max_iter) max_iter = iterations;
			tot_same += same_model;
			tot_iter += iterations;
			sum_species();
			if (pr.all == TRUE) {
				output_msg(OUTPUT_MESSAGE, "Time %g. Cell %d: x=%15g\ty=%15g\tz=%15g\n", (*time_hst) * (*cnvtmi), j + 1, x_hst[j], y_hst[j], z_hst[j]);
				print_using_hst(j + 1);
			}
			print_all();
			punch_all();
		} else {
				if (pr.all == TRUE ) {
					output_msg(OUTPUT_MESSAGE, "Time %g. Cell %d: x=%15g\ty=%15g\tz=%15g\n", (*time_hst) * (*cnvtmi), j + 1, x_hst[j], y_hst[j], z_hst[j]);
					output_msg(OUTPUT_MESSAGE, "Cell is dry.\n");
				}
		}
/*
 *   Save data
 */
		xsolution_save_hst(n_solution);
		if (active && *adjust_water_rock_ratio) scale_solution(n_solution, 1.0/frac[j]); 
		if (save.exchange == TRUE) {
			xexchange_save_hst(n_exchange);
		}
		if (save.gas_phase == TRUE) {
			xgas_save_hst(n_gas_phase);
		}
		if (save.pp_assemblage == TRUE) {
			xpp_assemblage_save_hst(n_pp_assemblage);
		}
		if (save.surface == TRUE) {
			xsurface_save_hst(n_surface);
		}
		if (save.s_s_assemblage == TRUE) {
			xs_s_assemblage_save_hst(n_s_s_assemblage);
		}
		EndCell(*print_sel, *print_out, *print_hdf, j);
	}
	EndTimeStep(*print_sel, *print_out, *print_hdf);
/*
 *   Put values back for HST
 */
	PACK_FOR_HST(fraction, dim);
/*
 *   Write screen and log messages
 */
        if (*prslm == TRUE) {
	  sprintf(error_string,"          Total cells: %d", count_chem);
	  output_msg(OUTPUT_SCREEN, "%s\n", error_string);
	  output_msg(OUTPUT_ECHO, "%s\n", error_string);
	  sprintf(error_string,"          Number of cells with same aqueous model: %d", tot_same);
	  output_msg(OUTPUT_SCREEN, "%s\n", error_string);
	  output_msg(OUTPUT_ECHO, "%s\n", error_string);
	  sprintf(error_string,"          Total iterations all cells: %d", tot_iter);
	  output_msg(OUTPUT_SCREEN, "%s\n", error_string);
	  output_msg(OUTPUT_ECHO, "%s\n", error_string);
	  sprintf(error_string,"          Number of cells with zero iterations: %d", tot_zero);
	  output_msg(OUTPUT_SCREEN, "%s\n", error_string);
	  output_msg(OUTPUT_ECHO, "%s\n", error_string);
	  sprintf(error_string,"          Maximum iterations for one cell: %d", max_iter);
	  output_msg(OUTPUT_SCREEN, "%s\n\n", error_string);
	  output_msg(OUTPUT_ECHO, "%s\n\n", error_string);
	}
	return;
}
#endif
/* ---------------------------------------------------------------------- */
void EQUILIBRATE(double *fraction, int *dim, int *print_sel,
		 double *x_hst, double *y_hst, double *z_hst,
		 double *time_hst, double *time_step_hst, int *prslm, double *cnvtmi,
		 double *frac, 
		 int *printzone_chem, int *printzone_xyz,
		 int *print_out, int *stop_msg, int *print_hdf,
                 int *adjust_water_rock_ratio)
/* ---------------------------------------------------------------------- */
{
#ifndef USE_MPI
  if (!(*stop_msg == 1)) {
    EQUILIBRATE_SERIAL(fraction, dim, print_sel,
		       x_hst, y_hst, z_hst,
		       time_hst, time_step_hst, prslm, cnvtmi,
		       frac, printzone_chem, printzone_xyz, print_out, print_hdf,
		       adjust_water_rock_ratio);
  }
  return;
#else  /* #ifndef USE_MPI */

/*
 *   Routine takes mass fractions from HST, equilibrates each cell,
 *   and returns new mass fractions to HST
 *
 *   Input: ixyz - number of cells in model
 *          dim - leading dimension of 2-d array fraction
 *
 *   Output: fraction - mass fractions of all components in all solutions
 *                      dimensions must be >= ixyz x n_comp
 */
	int i, j, k, total_eq, tot_iter, tot_zero, max_iter;
	int active;
	int n_user;
	LDBLE kin_time;
	int first_cell, last_cell;
	int initial_prep;
	int *sort_random_list;
	LDBLE time_sum;
	int rebalance_count;
	LDBLE t0;
	static int write_headings = 1;

#ifdef TIME
	static LDBLE time_distribute = 0.0, time_collect = 0.0, time_rebalance = 0.0;
	static LDBLE time_distribute_tot = 0.0, time_collect_tot = 0.0, time_rebalance_tot;
#endif
	static LDBLE time_equilibrate = 0.0, time_equilibrate_tot = 0.0;
	/* Message for end of calculation */
#ifdef TIME
#ifdef _DEBUG
	fflush(NULL);
#endif
	end_time = (LDBLE) MPI_Wtime();
	transport_time = end_time - start_time;
	transport_time_tot += transport_time;
	start_time = end_time;
	t0 = end_time;
#endif
	MPI_Bcast(stop_msg, 1,                   MPI_INT,    0, MPI_COMM_WORLD);
	if (*stop_msg == 1) {
		random_list = free_check_null(random_list);
		return;
	}
	/*
	 *  Initialize on first call to equilibrate
	 */
	if (call_counter == 0) {
		/*  moved to distribute_initial_conditions */
		/*
		random_list = PHRQ_malloc((size_t) count_chem * sizeof(int));
		if (random_list == NULL) malloc_error();
		random_frac = PHRQ_malloc((size_t) count_chem * sizeof(LDBLE));
		if (random_frac == NULL) malloc_error();
		random_printzone_chem = PHRQ_malloc((size_t) count_chem * sizeof(int));
		if (random_printzone_chem == NULL) malloc_error();
		random_printzone_xyz = PHRQ_malloc((size_t) count_chem * sizeof(int));
		if (random_printzone_xyz == NULL) malloc_error();
		if (mpi_myself == 0) mpi_set_random();
		MPI_Bcast(random_list, count_chem,                MPI_INT,    0, MPI_COMM_WORLD);
		mpi_set_subcolumn(frac);
		*/
		wait_time = 0;
		wait_time_tot = 0;
		/*
		  mpi_buffer = PHRQ_malloc(sizeof(char));
		  if (mpi_buffer == NULL) malloc_error();
		*/
		mpi_max_buffer = 1;
	}
	call_counter++;
	initial_prep = total_prep;
	first_cell = 0;
	last_cell = count_chem;
	first_cell = mpi_first_cell;
	last_cell = mpi_last_cell;
	if (last_cell > count_chem) {
		sprintf(error_string, "Process %d: Last cell of subcolumn exceeds length of column.\n", mpi_myself);
		error_msg(error_string, STOP);
	}
	rebalance_count = 0;
	time_sum = 0;
	/* Set time at beginning of calculations */
	/* Distribute arguments from root */
	distribute_from_root(fraction, dim, print_sel,
			  time_hst, time_step_hst, prslm,
			  frac, printzone_chem, printzone_xyz, print_out, print_hdf);
#ifdef TIME
	end_time = (LDBLE) MPI_Wtime();
	time_distribute = end_time - start_time;
	time_distribute_tot += time_distribute;
	start_time = end_time;
#endif
	pr.all = *print_out;
/*
 *   Update solution compositions
 */
/*
 *   Calculate equilibrium
 */
	n_gas_phase = first_gas_phase;
	n_exchange = first_exchange;
	n_pp_assemblage = first_pp_assemblage;
	n_surface = first_surface;
	n_s_s_assemblage = first_s_s_assemblage;
	n_kinetics = first_kinetics;
	kin_time = *time_step_hst;
 	timest = kin_time;


	state = PHAST;
	total_eq = 0;
	tot_iter = 0;
	tot_zero = 0;
	max_iter = 0;
        if (*print_sel == TRUE) {
		simulation++;
                pr.punch = TRUE;
	} else {
		pr.punch = FALSE;
	}
	pr.hdf = *print_hdf;

	BeginTimeStep(*print_sel, *print_out, *print_hdf);
	if (punch.in == TRUE && write_headings) {
		int pr_punch = pr.punch;
		pr.punch = TRUE;
		/*
		 * write headings
		 */
		punch.new_def = TRUE;
		output_msg(OUTPUT_PUNCH,"%15s\t%15s\t%15s\t%15s\t%2s\t","x","y","z","time","in");
		tidy_punch();
		write_headings = 0;
		pr.punch = pr_punch;
	}

	rate_sim_time_start = *time_hst - *time_step_hst;
	rate_sim_time_end = *time_hst;
	initial_total_time = 0;
	/*
	 *  Sort list for processor
	 */
	sort_random_list = PHRQ_malloc((size_t) (last_cell - first_cell + 1) * sizeof(int));
	if (sort_random_list == NULL) malloc_error();
	memcpy(sort_random_list, &random_list[first_cell], (size_t) (last_cell - first_cell + 1) * sizeof(int));
	qsort (sort_random_list, (size_t) (last_cell - first_cell + 1), (size_t) sizeof(int), int_compare);
	/*
	 *  Run chemistry for cells
	 */
	for (k = first_cell; k <= last_cell; k++) {
		i = sort_random_list[k - first_cell];    /* 1 to count_chem */
		j = back[i].list[0];                     /* 1 to nijk */
		if (transient_free_surface == TRUE) partition_uz(i, j, frac[j]); 
		if (frac[j] <= 1e-8) frac[j] = 0.0;
		if (frac[j] > 0.0) {
			active = TRUE;
		} else {
			active = FALSE;
		}

		if (*print_out == TRUE && printzone_chem[j] == TRUE) {
			pr.all = TRUE;
		} else {
			pr.all = FALSE;
		}
		if (*print_sel == TRUE && printzone_xyz[j] == TRUE && punch.in == TRUE) {
			pr.punch = TRUE;
		} else {
			pr.punch = FALSE;
		}

		BeginCell(*print_sel, *print_out, *print_hdf, j);
		if (pr.punch == TRUE) {
			output_msg(OUTPUT_PUNCH, "%15g\t%15g\t%15g\t%15g\t%2d\t", x_hst[j], y_hst[j],
				z_hst[j], (*time_hst) * (*cnvtmi), active);
			if (active == FALSE) {
				output_msg(OUTPUT_PUNCH, "\n");
			}
		}
		if (active) {
			copy_system_to_user(sz[i], first_user_number);
			cell_no = i;
			solution_bsearch(first_user_number, &first_solution, TRUE);
			n_solution = first_solution;
			if (*adjust_water_rock_ratio) scale_solution(n_solution, frac[j]); 
			set_use_hst();
			n_user = solution[n_solution]->n_user;
			set_initial_moles(n_user);
			run_reactions(n_user, kin_time, FALSE, 1.0);
			if (iterations == 0) tot_zero++;
			if (iterations > max_iter) max_iter = iterations;
			total_eq++;
			tot_iter += iterations;
			sum_species();

			if (pr.all == TRUE) {
				output_msg(OUTPUT_MESSAGE, "Time %g. Cell %d: x=%15g\ty=%15g\tz=%15g\n", (*time_hst) * (*cnvtmi), j + 1, x_hst[j], y_hst[j], z_hst[j]);
				print_using_hst(j + 1);
			}
			print_all();
			punch_all();
		} else {
			if (pr.all == TRUE ) {
				output_msg(OUTPUT_MESSAGE, "Time %g. Cell %d: x=%15g\ty=%15g\tz=%15g\n", (*time_hst) * (*cnvtmi), j + 1, x_hst[j], y_hst[j], z_hst[j]);
				output_msg(OUTPUT_MESSAGE, "Cell is dry.\n");
			}
		}
/*
 *   Save data
 */
		if (active) {
			xsolution_save_hst(n_solution);
			if (save.exchange == TRUE) {
				xexchange_save_hst(n_exchange);
			}
			if (save.gas_phase == TRUE) {
				xgas_save_hst(n_gas_phase);
			}
			if (save.pp_assemblage == TRUE) {
				xpp_assemblage_save_hst(n_pp_assemblage);
			}
			if (save.surface == TRUE) {
				xsurface_save_hst(n_surface);
			}
			if (save.s_s_assemblage == TRUE) {
				xs_s_assemblage_save_hst(n_s_s_assemblage);
			}
			/*
			 * Be careful, scale_solution zeros some arrays
			 * can delete some results from run_reaction
			 */
			if (active && *adjust_water_rock_ratio) scale_solution(n_solution, 1.0/frac[j]); 
			copy_user_to_system(sz[i], first_user_number, i);
		}
		EndCell(*print_sel, *print_out, *print_hdf, j);
	}
#ifdef TIME
	time_sum = (LDBLE) MPI_Wtime() - start_time;
	MPI_Barrier(MPI_COMM_WORLD);
	end_time = (LDBLE) MPI_Wtime();
	time_equilibrate = end_time - start_time;
	time_equilibrate_tot += time_equilibrate;
	start_time = end_time;
#endif

	EndTimeStep(*print_sel, *print_out, *print_hdf);

/*
 *   Put values back for HST
 */
	COLLECT_FROM_NONROOT(fraction, dim);
	/*if (mpi_myself == 0) PACK_FOR_HST(fraction, dim);*/
#ifdef TIME
	MPI_Barrier(MPI_COMM_WORLD);
	if (mpi_myself == 0) {
		end_time = (LDBLE) MPI_Wtime();
		time_collect = end_time - start_time;
		time_collect_tot += time_collect;
		start_time = end_time;
	}
#endif
/*
 *   Write screen and log messages
 */
	if (mpi_myself == 0) {
		if (*prslm == TRUE) {
		  sprintf(error_string,"          Total cells: %d", count_chem);
		  output_msg(OUTPUT_SCREEN, "%s\n", error_string);
		  sprintf(error_string,"          Cells processed by root: %d", last_cell - first_cell + 1);
		  output_msg(OUTPUT_SCREEN, "%s\n", error_string);
		  output_msg(OUTPUT_ECHO, "%s\n", error_string);
		  sprintf(error_string,"          Number of root cells with same aqueous model: %d", total_eq - (total_prep - initial_prep));
		  output_msg(OUTPUT_SCREEN, "%s\n", error_string);
		  output_msg(OUTPUT_ECHO, "%s\n", error_string);
		  sprintf(error_string,"          Total iterations all root cells: %d", tot_iter);
		  output_msg(OUTPUT_SCREEN, "%s\n", error_string);
		  output_msg(OUTPUT_ECHO, "%s\n", error_string);
		  sprintf(error_string,"          Number of root cells with zero iterations: %d", tot_zero);
		  output_msg(OUTPUT_SCREEN, "%s\n", error_string);
		  output_msg(OUTPUT_ECHO, "%s\n", error_string);
		  sprintf(error_string,"          Maximum iterations for single root cell: %d", max_iter);
		  output_msg(OUTPUT_SCREEN, "%s\n", error_string);
		  output_msg(OUTPUT_ECHO, "%s\n", error_string);
		}
	}

	/* rebalance */
	rebalance_count++;
	if (rebalance_count >= 1) {
		mpi_rebalance_load(time_sum/(last_cell - first_cell + 1), frac, TRUE);
		rebalance_count = 0;
		time_sum = 0;
		first_cell = mpi_first_cell;
		last_cell = mpi_last_cell;
	}
	sort_random_list = (int *) free_check_null(sort_random_list);
#ifdef TIME
	end_time = (LDBLE) MPI_Wtime();
	time_rebalance = end_time - start_time;
	time_rebalance_tot += time_rebalance;
	start_time = end_time;
	chemistry_time = time_distribute + time_equilibrate + time_collect + time_rebalance;
	chemistry_time_tot += chemistry_time;
	start_time = end_time;
	if (mpi_myself == 0) {
		output_msg(OUTPUT_SCREEN,"          Estimated overall efficiency for chemistry:              %5.1f %%\n", (double) (100.*optimum_chemistry/chemistry_time));
		/* fprintf(stderr,"          Estimated speedup of chemistry:                          %5.1f\n", optimum_serial_time/chemistry_time); */
		output_msg(OUTPUT_SCREEN, "          Clock time transport: %10.2f\tCumulative:   %10.2f (s)\n", (double) transport_time, (double) transport_time_tot);
		output_msg(OUTPUT_SCREEN, "          Clock time chemistry: %10.2f\tCumulative:   %10.2f (s)\n", (double) chemistry_time, (double) chemistry_time_tot);
#ifdef SKIP
#endif
		output_msg(OUTPUT_SCREEN, "\t\tDistributing: %e.\tCumulative: %e\n", (double) time_distribute, (double) time_distribute_tot);
		output_msg(OUTPUT_SCREEN, "\t\tChem + wait:  %e.\tCumulative: %e\n", (double) time_equilibrate, (double) time_equilibrate_tot);
		output_msg(OUTPUT_SCREEN, "\t\tWait:         %e.\tCumulative: %e\n", (double) wait_time, (double) wait_time_tot);
		output_msg(OUTPUT_SCREEN, "\t\tGathering:    %e.\tCumulative: %e\n", (double) time_collect, (double) time_collect_tot);
		output_msg(OUTPUT_SCREEN, "\t\tRebalance:    %e.\tCumulative: %e\n", (double) time_rebalance, (double) time_rebalance_tot);
		output_msg(OUTPUT_SCREEN, "\t\tNon-Chemistry %e.\tCumulative: %e\n", (double) (chemistry_time - time_equilibrate), (double) (chemistry_time_tot - time_equilibrate_tot));

	}
#endif
	return;
#endif  /* #ifndef USE_MPI */
}
/* ---------------------------------------------------------------------- */
void FORWARD_AND_BACK(int *initial_conditions, int *axes, int *nx, int *ny, int *nz)
/* ---------------------------------------------------------------------- */
{
/*
 *   calculate mapping from full set of cells to subset needed for chemistry
 */
	int i, n, ii, jj, kk;

	count_chem = 1;
	ix = *nx;
	iy = *ny;
	iz = *nz;

	ixy = ix * iy;
	ixz = ix * iz;
	iyz = iy * iz;
	ixyz = ix * iy * iz;

	if (axes[0] == FALSE &&
	    axes[1] == FALSE &&
	    axes[2] == FALSE) {
		error_msg("No active coordinate direction in DIMENSIONS keyword.", STOP);
	}
	if (axes[0] == TRUE) count_chem *= ix;
	if (axes[1] == TRUE) count_chem *= iy;
	if (axes[2] == TRUE) count_chem *= iz;
/*
 *   malloc space
 */
	forward = PHRQ_malloc((size_t) ixyz * sizeof(int));
	if (forward == NULL) malloc_error();
	back = PHRQ_malloc((size_t) count_chem * sizeof(struct back_list ));
	if (back == NULL) malloc_error();

/*
 *   xyz domain
 */
	if ((axes[0] == TRUE) && (axes[1] == TRUE) && (axes[2] == TRUE)) {
		count_back_list = 1;
		n = 0;
		for (i = 0; i < ixyz; i++) {
			if (initial_conditions[7*i] >= 0) {
				forward[i] = n;
				back[n].list[0] = i;
				n++;
			} else {
				forward[i] = -1;
			}
		}
		count_chem = n;
/*
 *   Copy xy plane
 */
	} else if ((axes[0] == TRUE) && (axes[1] == TRUE) && (axes[2] == FALSE)) {
		count_back_list = 2;
		n = 0;
		for (i = 0; i < ixyz; i++) {
			n_to_ijk(i, &ii, &jj, &kk);
			if (kk == 0 && initial_conditions[7*i] >= 0) {
				forward[i] = n;
				back[n].list[0] = i;
				back[n].list[1] = i + ixy;
				n++;
			} else {
				forward[i] = -1;
			}
		}
		count_chem = n;
/*
 *   Copy xz plane
 */
	} else if ((axes[0] == TRUE) && (axes[1] == FALSE) && (axes[2] == TRUE)) {
		count_back_list = 2;
		n = 0;
		for (i = 0; i < ixyz; i++) {
			n_to_ijk(i, &ii, &jj, &kk);
			if (jj == 0 && initial_conditions[7*i] >= 0) {
				forward[i] = n;
				back[n].list[0] = i;
				back[n].list[1] = i + ix;
				n++;
			} else {
				forward[i] = -1;
			}
		}
		count_chem = n;
/*
 *   Copy yz plane
 */
	} else if ((axes[0] == FALSE) && (axes[1] == TRUE) && (axes[2] == TRUE)) {
		if (ix != 2) {
			sprintf(error_string, "X direction should contain only two nodes for this 2D problem.");
			error_msg(error_string, STOP);
		}

		count_back_list = 2;
		n = 0;
		for (i = 0; i < ixyz; i++) {
			n_to_ijk(i, &ii, &jj, &kk);
			if (ii == 0 && initial_conditions[7*i] >= 0) {
				forward[i] = n;
				back[n].list[0] = i;
				back[n].list[1] = i + 1;
				n++;
			} else {
				forward[i] = -1;
			}
		}
		count_chem = n;
/*
 *   Copy x line
 */
	} else if ((axes[0] == TRUE) && (axes[1] == FALSE) && (axes[2] == FALSE)) {
		if (iy != 2) {
			sprintf(error_string, "Y direction should contain only two nodes for this 1D problem.");
			error_msg(error_string, STOP);
		}
		if (iz != 2) {
			sprintf(error_string, "Z direction should contain only two nodes for this 1D problem.");
			error_msg(error_string, STOP);
		}

		count_back_list = 4;
		n = 0;
		for (i = 0; i < ixyz; i++) {
			if (initial_conditions[i*7] < 0) {
				input_error++;
				sprintf(error_string, "Can not have inactive cells in a 1D simulation.");
				error_msg(error_string, STOP);
			}
			n_to_ijk(i, &ii, &jj, &kk);
			if (jj == 0 && kk == 0) {
				forward[i] = n;
				back[n].list[0] = i;
				back[n].list[1] = i + ix;
				back[n].list[2] = i + ixy;
				back[n].list[3] = i + ixy + ix;
				n++;
			} else {
				forward[i] = -1;
			}
		}
		count_chem = n;
/*
 *   Copy y line
 */
	} else if ((axes[0] == FALSE) && (axes[1] == TRUE) && (axes[2] == FALSE)) {
		if (ix != 2) {
			sprintf(error_string, "X direction should contain only two nodes for this 1D problem.");
			error_msg(error_string, STOP);
		}
		if (iz != 2) {
			sprintf(error_string, "Z direction should contain only two nodes for this 1D problem.");
			error_msg(error_string, STOP);
		}

		count_back_list = 4;
		n = 0;
		for (i = 0; i < ixyz; i++) {
			if (initial_conditions[i*7] < 0) {
				input_error++;
				sprintf(error_string, "Can not have inactive cells in a 1D simulation.");
				error_msg(error_string, STOP);
			}
			n_to_ijk(i, &ii, &jj, &kk);
			if (ii == 0 && kk == 0) {
				forward[i] = n;
				back[n].list[0] = i;
				back[n].list[1] = i + 1;
				back[n].list[2] = i + ixy;
				back[n].list[3] = i + ixy + 1;
				n++;
			} else {
				forward[i] = -1;
			}
		}
		count_chem = n;
/*
 *   Copy z line
 */
	} else if ((axes[0] == FALSE) && (axes[1] == FALSE) && (axes[2] == TRUE)) {
		count_back_list = 4;
		n = 0;
		for (i = 0; i < ixyz; i++) {
			if (initial_conditions[i*7] < 0) {
				input_error++;
				sprintf(error_string, "Can not have inactive cells in a 1D simulation.");
				error_msg(error_string, STOP);
			}
			n_to_ijk(i, &ii, &jj, &kk);
			if (ii == 0 && jj == 0) {
				forward[i] = n;
				back[n].list[0] = i;
				back[n].list[1] = i + 1;
				back[n].list[2] = i + ix;
				back[n].list[3] = i + ix + 1;
				n++;
			} else {
				forward[i] = -1;
			}
		}
		count_chem = n;
	}
	return;
}
/* ---------------------------------------------------------------------- */
int n_to_ijk(int n, int *i, int *j, int *k)
/* ---------------------------------------------------------------------- */
{
	int return_value;

	return_value = OK;

	*k = n / ixy;
	*j = (n % ixy) / ix;
	*i = (n % ixy) % ix;

	if (*k < 0 || *k >= iz) {
		error_msg("Z index out of range", CONTINUE);
		return_value = ERROR;
	}
	if (*j < 0 || *j >= iy) {
		error_msg("Y index out of range", CONTINUE);
		return_value = ERROR;
	}
	if (*i < 0 || *i >= ix) {
		error_msg("X index out of range", CONTINUE);
		return_value = ERROR;
	}
	return(return_value);
}
/* ---------------------------------------------------------------------- */
void CONVERT_TO_MOLAL(double *c, int *n, int *dim)
/* ---------------------------------------------------------------------- */
{
	int i;
/*
 *  convert c from mass fraction to moles
 *  The c array is dimensioned c(dim,ns).
 *  n is the number of rows that are used.
 *  In f90 dim = n and is often the number of
 *    cells in the domain.
 */
	for (i = 0; i < *n; i++) {
		hst_to_buffer(&c[i], *dim);
		buffer_to_moles();
		moles_to_hst(&c[i], *dim);
	}
	return;
}
/* ---------------------------------------------------------------------- */
void CONVERT_TO_MASS_FRACTION(double *c, int *n, int *dim)
/* ---------------------------------------------------------------------- */
{
	int i;
/*
 *  convert c from mass fraction to moles
 */
	for (i = 0; i < *n; i++) {
		hst_moles_to_buffer(&c[i], *dim);
		buffer_to_mass_fraction();
		buffer_to_hst(&c[i], *dim);
	}
	return;
}
/* ---------------------------------------------------------------------- */
void ERRPRT_C(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
        char *e_string;

	e_string = PHRQ_malloc((size_t) (l+1)*sizeof(char));
	strncpy(e_string, err_str, (size_t) (l));
	e_string[l] = '\0';
	string_trim_right(e_string);
        output_msg(OUTPUT_ECHO,"ERROR: %s\n", e_string);
        output_msg(OUTPUT_SCREEN,"ERROR: %s\n", e_string);
	free_check_null(e_string);
	return;
}
/* ---------------------------------------------------------------------- */
void WARNPRT_C(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
        char *e_string;

	e_string = PHRQ_malloc((size_t) (l+1)*sizeof(char));
	strncpy(e_string, err_str, (size_t) (l));
	e_string[l] = '\0';
	string_trim_right(e_string);
        output_msg(OUTPUT_ECHO,"WARNING: %s\n", e_string);
        output_fflush(OUTPUT_ECHO);
        output_msg(OUTPUT_SCREEN,"WARNING: %s\n", e_string);
        output_fflush(OUTPUT_SCREEN);
	free_check_null(e_string);
	return;
}
/* ---------------------------------------------------------------------- */
void LOGPRT_C(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
        char *e_string;

	if (mpi_myself != 0) return;
	e_string = PHRQ_malloc((size_t) (l+1)*sizeof(char));
	strncpy(e_string, err_str, (size_t) (l));
	e_string[l] = '\0';
	string_trim_right(e_string);
        output_msg(OUTPUT_ECHO,"%s\n", e_string);
        output_fflush(OUTPUT_ECHO);
	/*
        fprintf(error_file,"%s\n", e_string);
        fflush(error_file);
	*/
	free_check_null(e_string);
	return;
}

#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
int mpi_send_solution(int solution_number, int task_number)
/* ---------------------------------------------------------------------- */
{
	int i, j, d, n;
	int count_totals, count_totals_position, count_activity, count_activity_position;
	int max_size, member_size, position;
	int ints[MESSAGE_MAX_NUMBERS];
	double doubles[MESSAGE_MAX_NUMBERS];
	void *buffer;
	struct solution *solution_ptr;
	struct master *master_ptr;
/*
 *   Malloc space for a buffer
 */
	max_size = 0;
	MPI_Pack_size(MESSAGE_MAX_NUMBERS, MPI_INT, MPI_COMM_WORLD, &member_size);
	max_size += member_size;
	MPI_Pack_size(MESSAGE_MAX_NUMBERS, MPI_DOUBLE, MPI_COMM_WORLD, &member_size);
	max_size += member_size;
	buffer = PHRQ_malloc(max_size);
	if (buffer == NULL) malloc_error();
/*
 *   Make list of list of ints and doubles from solution structure
 *   This list is not the complete structure, but only enough
 *   for batch-reaction, advection, and transport calculations
 */
	solution_ptr = solution_bsearch(solution_number, &n, TRUE);
	i = 0;
	d = 0;
	/*	int new_def; */
	/*	int n_user; */
	ints[i++] = solution_ptr->n_user;
	/*	int n_user_end; */
	/*	char *description; */
	/*	double tc; */
	doubles[d++] = solution_ptr->tc;
	/*	double ph; */
	doubles[d++] = solution_ptr->ph;
	/*	double solution_pe; */
	doubles[d++] = solution_ptr->solution_pe;
	/*	double mu; */
	doubles[d++] = solution_ptr->mu;
	/*	double ah2o; */
	doubles[d++] = solution_ptr->ah2o;
	/*	double density; */
	/*	LDBLE total_h; */
	doubles[d++] = solution_ptr->total_h;
	/*	LDBLE total_o; */
	doubles[d++] = solution_ptr->total_o;
	/*	LDBLE cb; */
	doubles[d++] = solution_ptr->cb;
	/*	LDBLE mass_water; */
	doubles[d++] = solution_ptr->mass_water;

	/*	LDBLE total_alkalinity; */
	/*	LDBLE total_co2; */
	/*	char *units; */
	/*	struct pe_data *pe; */
	/*	int default_pe; */
/*
 *	struct conc *totals;
*/
	count_totals_position = i++;
	count_totals = 0;
	for (j = 0; solution_ptr->totals[j].description != NULL; j++ ) {
		master_ptr = master_bsearch(solution_ptr->totals[j].description);
		if (master_ptr == NULL) {
			input_error++;
			sprintf(error_string,"Packing solution message: %s, element not found\n", solution_ptr->totals[j].description);
			error_msg(error_string, CONTINUE);
		}
		ints[i++] = master_ptr->number;
		doubles[d++] = solution_ptr->totals[j].moles;
		count_totals++;
	}
	ints[count_totals_position] = count_totals;
/*
 *	struct master_activity *master_activity;
 */
	count_activity_position = i++;
	count_activity = 0;
	for (j = 0; solution_ptr->master_activity[j].description != NULL; j++ ) {
		master_ptr = master_bsearch(solution_ptr->master_activity[j].description);
		if (master_ptr == NULL) {
			input_error++;
			sprintf(error_string,"Packing solution message: %s, element not found\n", solution_ptr->master_activity[j].description);
			error_msg(error_string, CONTINUE);
		}
		ints[i++] = master_ptr->number;
		doubles[d++] = solution_ptr->master_activity[j].la;
		count_activity++;
	}
	ints[count_activity_position] = count_activity;
	/*	int count_isotopes; */
	/*	struct isotope *isotopes; */
	if (input_error > 0) {
		error_msg("Stopping due to errors\n", STOP);
	}
/*
 *   Send message to processor
 */
	position = 0;
	MPI_Pack(&i, 1, MPI_INT, buffer, max_size, &position, MPI_COMM_WORLD);
	MPI_Pack(ints, i, MPI_INT, buffer, max_size, &position, MPI_COMM_WORLD);
	MPI_Pack(&d, 1, MPI_INT, buffer, max_size, &position, MPI_COMM_WORLD);
	MPI_Pack(doubles, d, MPI_DOUBLE, buffer, max_size, &position, MPI_COMM_WORLD);
	MPI_Send(buffer, position, MPI_PACKED, task_number, 0, MPI_COMM_WORLD);

	buffer = (void *) free_check_null(buffer);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_recv_solution(int solution_number, int task_number)
/* ---------------------------------------------------------------------- */
{
	int i, j, d, n;
	int count_ints, count_doubles;
	int count_totals, count_activity;
	int max_size, member_size, position, msg_size;
	int ints[MESSAGE_MAX_NUMBERS];
	double doubles[MESSAGE_MAX_NUMBERS];
	void *buffer;
	struct solution *solution_ptr;
	struct master *master_ptr;
	MPI_Status mpi_status;
/*
 *   Malloc space for a buffer
 */
	max_size = 0;
	MPI_Pack_size(MESSAGE_MAX_NUMBERS, MPI_INT, MPI_COMM_WORLD, &member_size);
	max_size += member_size;
	MPI_Pack_size(MESSAGE_MAX_NUMBERS, MPI_DOUBLE, MPI_COMM_WORLD, &member_size);
	max_size += member_size;
	buffer = PHRQ_malloc(max_size);
	if (buffer == NULL) malloc_error();
/*
 *   Recieve solution
 */
	MPI_Recv(buffer, max_size, MPI_PACKED, task_number, 0, MPI_COMM_WORLD, &mpi_status);
 	position = 0;
 	MPI_Get_count(&mpi_status, MPI_PACKED, &msg_size);
 	MPI_Unpack(buffer, msg_size, &position, &count_ints, 1, MPI_INT, MPI_COMM_WORLD);
 	MPI_Unpack(buffer, msg_size, &position, ints, count_ints, MPI_INT, MPI_COMM_WORLD);
 	MPI_Unpack(buffer, msg_size, &position, &count_doubles, 1, MPI_INT, MPI_COMM_WORLD);
 	MPI_Unpack(buffer, msg_size, &position, doubles, count_doubles, MPI_DOUBLE, MPI_COMM_WORLD);
/*
 *   Make solution structure
 */
	if (solution_bsearch(solution_number, &n, FALSE) != NULL) {
		solution_free(solution[n]);
	} else {
		n=count_solution++;
		if (count_solution >= max_solution) {
			space ((void *) &(solution), count_solution, &max_solution, sizeof (struct solution *) );
		}
	}
	solution[n] = solution_alloc();
	solution_ptr = solution[n];
	if (solution_ptr == NULL) malloc_error();
/*
 *   Make list of list of ints and doubles from solution structure
 *   This list is not the complete structure, but only enough
 *   for batch-reaction, advection, and transport calculations
 */
	i = 0;
	d = 0;
	/*	int new_def; */
	/* solution_ptr->new_def = FALSE; */
	/*	int n_user; */
	solution_ptr->n_user = ints[i++];
	/*	int n_user_end; */
	solution_ptr->n_user_end = solution_ptr->n_user;

	/*debugging*/
	solution_ptr->n_user = solution_number;
	solution_ptr->n_user_end = solution_number;

	/*	char *description; */
	solution_ptr->description = free_check_null(solution_ptr->description);
	solution_ptr->description = string_duplicate(" ");
	/*	double tc; */
	solution_ptr->tc = doubles[d++];
	/*	double ph; */
	solution_ptr->ph = doubles[d++];
	/*	double solution_pe; */
	solution_ptr->solution_pe = doubles[d++];
	/*	double mu; */
	solution_ptr->mu = doubles[d++];
	/*	double ah2o; */
	solution_ptr->ah2o = doubles[d++];
	/*	double density; */
	solution_ptr->density = 1.0;
	/*	LDBLE total_h; */
	solution_ptr->total_h = doubles[d++];
	/*	LDBLE total_o; */
	solution_ptr->total_o = doubles[d++];
	/*	LDBLE cb; */
	solution_ptr->cb = doubles[d++];
	/*	LDBLE mass_water; */
	solution_ptr->mass_water = doubles[d++];
	/*	LDBLE total_alkalinity; */
	solution_ptr->total_alkalinity = 0;
	/*	LDBLE total_co2; */
	solution_ptr->total_co2 = 0;
	/*	char *units; */
	/*	struct pe_data *pe; */
	/*	int default_pe; */
	solution_ptr->default_pe = 0;
/*
 *	struct conc *totals;
*/
	count_totals = ints[i++];
	solution_ptr->totals = PHRQ_realloc(solution_ptr->totals, (size_t) (count_totals + 1) * sizeof(struct conc));
	if (solution_ptr->totals == NULL) malloc_error();
	for (j = 0; j < count_totals; j++) {
		master_ptr = master[ints[i++]];
		solution_ptr->totals[j].description = master_ptr->elt->name;
		solution_ptr->totals[j].moles = doubles[d++];
	}
	solution_ptr->totals[j].description = NULL;

/*
 *	struct master_activity *master_activity;
 */
	count_activity = ints[i++];
	solution_ptr->master_activity = PHRQ_realloc(solution_ptr->master_activity, (size_t) (count_activity + 1) * sizeof(struct master_activity));
	if (solution_ptr->master_activity == NULL) malloc_error();
	for (j = 0; j < count_activity; j++) {
		master_ptr = master[ints[i++]];
		solution_ptr->master_activity[j].description = master_ptr->elt->name;
		solution_ptr->master_activity[j].la = doubles[d++];
	}
	solution_ptr->master_activity[j].description = NULL;

	/*	int count_isotopes; */
	solution_ptr->count_isotopes = 0;
	/*	struct isotope *isotopes; */

	buffer = free_check_null(buffer);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_send_recv_cells(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Send first cell of subcolumn to previous subcolumn
 */
	if (mpi_first_cell > 1) {
		mpi_send_solution (mpi_first_cell, mpi_myself - 1);
	}
	if (mpi_last_cell < count_cells) {
		mpi_recv_solution(mpi_last_cell + 1, mpi_myself + 1);
	}
/*
 *   Send last cell of subcolumn to next subcolumn
 */
	if (mpi_last_cell < count_cells) {
		mpi_send_solution (mpi_last_cell, mpi_myself + 1);
	}
	if (mpi_first_cell > 1) {
		mpi_recv_solution(mpi_first_cell - 1, mpi_myself - 1);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_set_subcolumn(double *frac)
/* ---------------------------------------------------------------------- */
{
#include <time.h>
	int i;
	double time_exec;
	int j;
	double t0;
	int n, num_np1_tasks, num_n_tasks;
/*
 *   calculate ends of subcolumn
 */
	n = count_cells / mpi_tasks;
	num_np1_tasks = count_cells - mpi_tasks * n;
	num_n_tasks = mpi_tasks - num_np1_tasks;
	if (mpi_myself < num_n_tasks) {
		mpi_first_cell = mpi_myself * n + 1;
		mpi_last_cell = mpi_first_cell + n - 1;
	} else {
		mpi_first_cell = (num_n_tasks * n) + (mpi_myself - num_n_tasks) * (n + 1) + 1;
		mpi_last_cell = mpi_first_cell + n;
	}
	for (i = 0; i < mpi_tasks; i++) {
		if (i < num_n_tasks) {
			end_cells[i][0] = i * n;
			end_cells[i][1] = end_cells[i][0] + n - 1;
		} else {
			end_cells[i][0] = (num_n_tasks * n) + (i - num_n_tasks) * (n + 1);
			end_cells[i][1] = end_cells[i][0] + n;
		}
	}
	/*
	 *  Timing loop
	 */
	t0 = (LDBLE) MPI_Wtime();
	time_exec = 0;
	j = 100*100*100*10;
	for (i = 1; i < j; i++) {
		time_exec += 1.0/(double) i;
	}
	time_exec = (LDBLE) MPI_Wtime() - t0;
	/*
	 *  Gather times of all tasks
	 */
	mpi_rebalance_load(time_exec, frac, FALSE);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_rebalance_load(double time_per_cell, double *frac, int transfer)
/* ---------------------------------------------------------------------- */
{
#include <time.h>
	double recv_buffer[MPI_MAX_TASKS + 1];
	LDBLE total;
	int i, j, k, min_cell, max_cell;
	int end_cells_new[MPI_MAX_TASKS][2];
	int cells[MPI_MAX_TASKS];
	LDBLE new_n, min_time, max_time;
	int n, total_cells, diff_cells, last;
	int new, old;
	int change;
	int error;
	LDBLE max_old, max_new, t;
	int ihst, iphrq; /* ihst is natural number to ixyz; iphrq is 0 to count_chem */
#ifdef TIME
	LDBLE t0;
#endif
	/*
	 *  Gather times of all tasks
	 */
	MPI_Gather (&time_per_cell, 1, MPI_DOUBLE, recv_buffer, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

	error = FALSE;
	new_n = 0;
	total_cells = 0;
	if (mpi_myself == 0) {
		total = 0;
		for (i = 0; i < mpi_tasks; i++) {
			if (recv_buffer[i] <= 0) {
				sprintf(error_string,"Time for  cell %d: %g\n", i, recv_buffer[i]);
				error = TRUE;
				break;
			}
			total += recv_buffer[0]/recv_buffer[i];
		}
		if (error == FALSE) {
			/* new_n is number of cells for root */
			new_n = count_cells/total;
		}
	}
	/*
	MPI_Bcast(&error, mpi_tasks, MPI_INT, 0, MPI_COMM_WORLD);
	if (error == TRUE) return(FALSE);
	*/
	/*
	 *  Set first and last cells
	 */
	if (mpi_myself == 0) {
		total_cells = 0;
		n = 0;
		/*
		 *  Calculate number of cells per process, rounded to lower number
		 */
		for (i = 0; i < mpi_tasks; i++) {
			n = (int) floor(new_n*recv_buffer[0]/recv_buffer[i]);
			if (n < 1) n = 1;
			cells[i] = n;
			total_cells += n;
		}
		/*
		 *  Distribute cells from rounding down
		 */
		diff_cells = count_cells - total_cells;
		if (diff_cells > 0) {
			for (j = 0; j < diff_cells; j++) {
				min_cell = 0;
				min_time = (cells[0] + 1) * recv_buffer[0];
				for (i = 1; i < mpi_tasks; i++) {
					if ((cells[i] + 1) * recv_buffer[i] < min_time) {
						min_cell = i;
						min_time = (cells[i] + 1) * recv_buffer[i];
					}
				}
				cells[min_cell] += 1;
			}
		} else if (diff_cells < 0) {
			for (j = 0; j < -diff_cells; j++) {
				max_cell = -1;
				max_time = 0;
				for (i = 0; i < mpi_tasks; i++) {
					if (cells[i] > 1) {
						if ((cells[i] - 1) * recv_buffer[i] > max_time) {
							max_cell = i;
							max_time = (cells[i] - 1) * recv_buffer[i];
						}
					}
				}
				cells[max_cell] -= 1;
			}
		}
		/*
		 *  Fill in subcolumn ends
		 */
		last = -1;
		for (i = 0; i < mpi_tasks; i++) {
			end_cells_new[i][0] = last + 1;
			end_cells_new[i][1] = end_cells_new[i][0] + cells[i] - 1;
			last = end_cells_new[i][1];
		}
		/*
		 *  Check that all cells are distributed
		 */
		if (end_cells_new[mpi_tasks - 1][1] != count_cells - 1 ) {
			output_msg(OUTPUT_STDERR,"Failed: %d, count_cells %d, last cell %d\n", diff_cells, count_cells, end_cells_new[mpi_tasks - 1][1]);
			for (i = 0; i < mpi_tasks; i++) {
				output_msg(OUTPUT_STDERR,"%d: first %d\tlast %d\n",i, end_cells_new[i][0], end_cells_new[i][1]);
			}
			error_msg("Failed to redistribute cells.", STOP);
		}
		/*
		 *   Compare old and new times
		 */
		max_old = 0.0;
		max_new = 0.0;
		for (i = 0; i < mpi_tasks; i++) {
			t = cells[i]*recv_buffer[i];
			if (t > max_new) max_new = t;
			t = (end_cells[i][1] - end_cells[i][0] + 1)*recv_buffer[i];
			if (t > max_old) max_old = t;
		}
#ifdef TIME
		optimum_serial_time = 1e20;
		for (i = 0; i < mpi_tasks; i++) {
			t = count_cells*recv_buffer[i];
			if (t < optimum_serial_time) {
				optimum_serial_time = t;
				/* fprintf(stderr,"%d, Optimum serial time: %e\n", i, (double) optimum_serial_time); */
			}
		}
		optimum_chemistry = max_new;
#endif
		/* fprintf(stdout,"\tMax time new: %e. Max time old: %e. Estimated efficiency: %5.1f%%\n", max_new, max_old, 100.*max_new/max_old); */
		output_msg(OUTPUT_STDERR,"          Estimated efficiency of chemistry without communication: %5.1f %%\n", (float) ((LDBLE)100.*max_new/max_old));
		wait_time = max_old - max_new;
		wait_time_tot += wait_time;
#ifdef REBALANCE
		if ((max_old - max_new)/max_old < 0.01) {
			/*			fprintf(stderr,"Stick\n"); */
			for (i = 0; i < mpi_tasks; i++) {
				end_cells_new[i][0] = end_cells[i][0];
				end_cells_new[i][1] = end_cells[i][1];
			}
		} else {
			for (i = 0; i < mpi_tasks - 1; i++) {
				end_cells_new[i][1] = (end_cells_new[i][1] + end_cells[i][1])/2;
				/*end_cells_new[i][1] = end_cells_new[i][1];*/
				/*end_cells_new[i][1] = end_cells[i][1] + (end_cells_new[i][1] - end_cells[i][1])/3;*/
				end_cells_new[i+1][0] = end_cells_new[i][1] + 1;
			}
		}
#else
		if (call_counter >= 1) {
			for (i = 0; i < mpi_tasks; i++) {
				end_cells_new[i][0] = end_cells[i][0];
				end_cells_new[i][1] = end_cells[i][1];
			}
		}
#endif
	}
	/*
	 *   Broadcast new subcolumns
	 */
	MPI_Bcast(end_cells_new, 2*mpi_tasks, MPI_INT, 0, MPI_COMM_WORLD);
	/*
	 *   Print old new divisions
	 */
#ifdef SKIP
	if (mpi_myself == 0) {
		for (i = 0; i < mpi_tasks; i++) {
			output_msg(OUTPUT_STDERR, "%3d: Old %6d-%6d\t%6d\t\tNew %6d-%6d\t%6d\n", i, end_cells[i][0], end_cells[i][1], end_cells[i][1] - end_cells[i][0], end_cells_new[i][0],   end_cells_new[i][1], end_cells_new[i][1] - end_cells_new[i][0]);
		}

	}
#endif
	/*
	 *   Redefine columns
	 */
	new = 0;
	old = 0;
	change = 0;
#ifdef TIME
	/* MPI_Barrier(MPI_COMM_WORLD); */
	t0 = (LDBLE) MPI_Wtime();
#endif
	if (transfer == TRUE) {
		/*solution_bsearch(first_user_number, &first_solution, TRUE);*/
		for (k = 0; k < count_cells; k++) {
			i = random_list[k];
			iphrq = i;                    /* iphrq is 1 to count_chem */
			ihst = back[i].list[0];       /* ihst is 1 to nxyz */
			/*
			n_solution = first_solution + i;
			n_user = solution[n_solution]->n_user;
			*/
			while (k > end_cells[old][1]) {
				old++;
			}
			while (k > end_cells_new[new][1]) {
				new++;
			}

			if (old == new) continue;
			change++;
			/*
			  if (mpi_myself == 0) {
			  fprintf(stderr, "%d [%d]: old %d,  %d-%d. new %d, %d-%d\n", k, i, old, end_cells[old][0], end_cells[old][1], new, end_cells_new[new][0],   end_cells_new[new][1]);
			  }
			*/
			if (mpi_myself == old) 	{
				mpi_send_system(new, iphrq, ihst, frac);
				system_free(sz[iphrq]);
				sz[iphrq] = free_check_null(sz[iphrq]);
			}
			if (mpi_myself == new) 	mpi_recv_system(old, iphrq, ihst, frac);
		}
	}
#ifdef TIME
	/* MPI_Barrier(MPI_COMM_WORLD); */
#ifdef SKIP
	if (mpi_myself == 0) {
		t1 = (LDBLE) MPI_Wtime();
		time_rebalance += t1 - t0;
		output_msg(OUTPUT_STDERR, "\tTIME Rebalancing:  %e.\tCumulative: %e\n", t1 - t0, (double) time_rebalance);
	}
#endif
#endif
	mpi_first_cell = end_cells_new[mpi_myself][0];
	mpi_last_cell = end_cells_new[mpi_myself][1];
	for (i = 0; i < mpi_tasks; i++) {
		end_cells[i][0] = end_cells_new[i][0];
		end_cells[i][1] = end_cells_new[i][1];
		if (mpi_myself == 0) {
			/* fprintf(stderr, "Task %d: %d\t-\t%d\n", i, end_cells[i][0], end_cells[i][1]); */
		}
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_send_system(int task_number, int iphrq, int ihst, LDBLE *frac)
/* ---------------------------------------------------------------------- */
{
	int i, d;
	int max_size, member_size, position;
	int ints[MESSAGE_MAX_NUMBERS];
	double doubles[MESSAGE_MAX_NUMBERS];
	void *buffer;
	struct solution *solution_ptr;
	struct exchange *exchange_ptr;
	struct gas_phase *gas_phase_ptr;
	struct kinetics *kinetics_ptr;
	struct pp_assemblage *pp_assemblage_ptr;
	struct surface *surface_ptr;
	struct s_s_assemblage *s_s_assemblage_ptr;
/*
 *   Malloc space for a buffer
 */
	max_size = 0;
	MPI_Pack_size(MESSAGE_MAX_NUMBERS, MPI_INT, MPI_COMM_WORLD, &member_size);
	max_size += member_size;
	MPI_Pack_size(MESSAGE_MAX_NUMBERS, MPI_DOUBLE, MPI_COMM_WORLD, &member_size);
	max_size += member_size;
	buffer = PHRQ_malloc(max_size);
	if (buffer == NULL) malloc_error();
/*
 *   Make list of list of ints and doubles from structures in
 *   the following order:
 *      equilibrium_phases
 *      exchange
 *      gas_phase
 *      kinetics
 *      solid_solution
 *      surface
 *
 *   This does not transfer the complete structure, only enough
 *   for batch-reaction, advection, and transport calculations
 *   assuming the structures already exist in the target process
 *   and only need to be updated.
 */
	i = 0;
	d = 0;
	/*
	 *   Solution
	 */
	solution_ptr = sz[iphrq]->solution;
	mpi_pack_solution(solution_ptr, ints, &i, doubles, &d);
	/*
	 *   Equilibrium_phases
	 */
	/*pp_assemblage_ptr = pp_assemblage_bsearch(system_number, &n);*/
	pp_assemblage_ptr = sz[iphrq]->pp_assemblage;
	mpi_pack_pp_assemblage(pp_assemblage_ptr, ints, &i, doubles, &d);
	/*
	 *   Exchange
	 */
	/*exchange_ptr = exchange_bsearch(system_number, &n);*/
	exchange_ptr = sz[iphrq]->exchange;
	mpi_pack_exchange(exchange_ptr, ints, &i, doubles, &d);
	/*
	 *   Gas phase
	 */
	/*gas_phase_ptr = gas_phase_bsearch(system_number, &n);*/
	gas_phase_ptr = sz[iphrq]->gas_phase;
	mpi_pack_gas_phase(gas_phase_ptr, ints, &i, doubles, &d);
	/*
	 *   Kinetics phase
	 */
	/*kinetics_ptr = kinetics_bsearch(system_number, &n);*/
	kinetics_ptr = sz[iphrq]->kinetics;
	mpi_pack_kinetics(kinetics_ptr, ints, &i, doubles, &d);
	/*
	 *   Solid solutions
	 */
	/*s_s_assemblage_ptr = s_s_assemblage_bsearch(system_number, &n);*/
	s_s_assemblage_ptr = sz[iphrq]->s_s_assemblage;
	mpi_pack_s_s_assemblage(s_s_assemblage_ptr, ints, &i, doubles, &d);
	/*
	 *   Surface
	 */
	/*surface_ptr = surface_bsearch(system_number, &n);*/
	surface_ptr = sz[iphrq]->surface;
	mpi_pack_surface(surface_ptr, ints, &i, doubles, &d);
	/*
	 *  Send uz info
	 */
	if (uz != NULL && uz[iphrq] != NULL) {
		ints[i++] = 1;
		doubles[d++] = frac[ihst];
		/*
		 *   Equilibrium_phases
		 */
		pp_assemblage_ptr = uz[iphrq]->pp_assemblage;
		mpi_pack_pp_assemblage(pp_assemblage_ptr, ints, &i, doubles, &d);
		/*
		 *   Exchange
		 */
		exchange_ptr = uz[iphrq]->exchange;
		mpi_pack_exchange(exchange_ptr, ints, &i, doubles, &d);
		/*
		 *   Gas phase
		 */
		gas_phase_ptr = uz[iphrq]->gas_phase;
		mpi_pack_gas_phase(gas_phase_ptr, ints, &i, doubles, &d);
		/*
		 *   Kinetics phase
		 */
		kinetics_ptr = uz[iphrq]->kinetics;
		mpi_pack_kinetics(kinetics_ptr, ints, &i, doubles, &d);
		/*
		 *   Solid solutions
		 */
		s_s_assemblage_ptr = uz[iphrq]->s_s_assemblage;
		mpi_pack_s_s_assemblage(s_s_assemblage_ptr, ints, &i, doubles, &d);
		/*
		 *   Surface
		 */
		surface_ptr = uz[iphrq]->surface;
		mpi_pack_surface(surface_ptr, ints, &i, doubles, &d);
	} else {
		ints[i++] = 0;
	}
	assert(i < MESSAGE_MAX_NUMBERS);
	assert(d < MESSAGE_MAX_NUMBERS);
/*
 *   Send message to processor
 */
	position = 0;
	MPI_Pack(&i, 1, MPI_INT, buffer, max_size, &position, MPI_COMM_WORLD);
	MPI_Pack(ints, i, MPI_INT, buffer, max_size, &position, MPI_COMM_WORLD);
	MPI_Pack(&d, 1, MPI_INT, buffer, max_size, &position, MPI_COMM_WORLD);
	MPI_Pack(doubles, d, MPI_DOUBLE, buffer, max_size, &position, MPI_COMM_WORLD);
	MPI_Send(buffer, position, MPI_PACKED, task_number, 0, MPI_COMM_WORLD);
	buffer = free_check_null(buffer);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_recv_system(int task_number, int iphrq, int ihst, LDBLE *frac)
/* ---------------------------------------------------------------------- */
{
	int i, d;
	int max_size, member_size, position, msg_size;
	MPI_Status mpi_status;
	int count_ints, count_doubles;
	int ints[MESSAGE_MAX_NUMBERS];
	double doubles[MESSAGE_MAX_NUMBERS];
	void *buffer;
	struct solution *solution_ptr;
	struct exchange *exchange_ptr;
	struct gas_phase *gas_phase_ptr;
	struct kinetics *kinetics_ptr;
	struct pp_assemblage *pp_assemblage_ptr;
	struct surface *surface_ptr;
	struct s_s_assemblage *s_s_assemblage_ptr;
/*
 *   Malloc space for a buffer
 */
	max_size = 0;
	MPI_Pack_size(MESSAGE_MAX_NUMBERS, MPI_INT, MPI_COMM_WORLD, &member_size);
	max_size += member_size;
	MPI_Pack_size(MESSAGE_MAX_NUMBERS, MPI_DOUBLE, MPI_COMM_WORLD, &member_size);
	max_size += member_size;
	buffer = PHRQ_malloc(max_size);
	if (buffer == NULL) malloc_error();
/*
 *   Make list of list of ints and doubles from structures in
 *   the following order:
 *      equilibrium_phases
 *      exchange
 *      gas_phase
 *      kinetics
 *      solid_solution
 *      surface
 *
 *   This does not transfer the complete structure, only enough
 *   for batch-reaction, advection, and transport calculations
 *   assuming the structures already exist in the target process
 *   and only need to be updated.
 */
/*
 *   Recieve solution
 */
 	MPI_Recv(buffer, max_size, MPI_PACKED, task_number, 0, MPI_COMM_WORLD, &mpi_status);
 	position = 0;
 	MPI_Get_count(&mpi_status, MPI_PACKED, &msg_size);
 	MPI_Unpack(buffer, msg_size, &position, &count_ints, 1, MPI_INT, MPI_COMM_WORLD);
 	MPI_Unpack(buffer, msg_size, &position, ints, count_ints, MPI_INT, MPI_COMM_WORLD);
 	MPI_Unpack(buffer, msg_size, &position, &count_doubles, 1, MPI_INT, MPI_COMM_WORLD);
 	MPI_Unpack(buffer, msg_size, &position, doubles, count_doubles, MPI_DOUBLE, MPI_COMM_WORLD);

	exchange_ptr = NULL;
	gas_phase_ptr = NULL;
	kinetics_ptr = NULL;
	pp_assemblage_ptr = NULL;
	surface_ptr = NULL;
	s_s_assemblage_ptr = NULL;
	/*
	 * Allocate or free system
	 */
#ifdef SKIP
	if (sz[iphrq] != NULL) {
		  system_free(sz[iphrq]);
		  sz[iphrq] = free_check_null(sz[iphrq]);
	}
	sz[iphrq] = system_initialize(ihst, iphrq, initial1, initial2, frac1);   
#endif
 	if (sz[iphrq] != NULL) {
		/* 
		 * mpi_myself has system for each solution
		 * but not necessarily the entire system
		 * if a cell is moved to process 0
		 */
		if(mpi_myself == 0 &&
		   sz[iphrq]->exchange == NULL &&
		   sz[iphrq]->pp_assemblage == NULL &&
		   sz[iphrq]->gas_phase == NULL &&
		   sz[iphrq]->s_s_assemblage == NULL &&
		   sz[iphrq]->kinetics == NULL &&
		   sz[iphrq]->surface == NULL
		   ) {
			system_free(sz[iphrq]);
			sz[iphrq] = free_check_null(sz[iphrq]);
			sz[iphrq] = system_initialize(ihst, iphrq, initial1, initial2, frac1);   
		}

	} else {
		sz[iphrq] = system_initialize(ihst, iphrq, initial1, initial2, frac1);   
 	}
	/*
	 *   Solution
	 */
	i = 0;
	d = 0;
	if (ints[i++] != 0) {
		solution_ptr = sz[iphrq]->solution;
		if (solution_ptr == NULL) {
			sprintf(error_string, "Task %d: Did not find recieved solution %d.", mpi_myself, ints[i]);
			error_msg(error_string, STOP);
		} else {
			mpi_unpack_solution(solution_ptr, ints, &i, doubles, &d);
		}
	}
	/*
	 *   Equilibrium_phases
	 */
	if (ints[i++] != 0) {
		/*pp_assemblage_ptr = pp_assemblage_bsearch(ints[i], &n);*/
		pp_assemblage_ptr = sz[iphrq]->pp_assemblage;
		if (pp_assemblage_ptr == NULL) {
			sprintf(error_string, "Task %d: Did not find recieved pp_assemblage %d.", mpi_myself, ints[i]);
			error_msg(error_string, STOP);
		} else {
			mpi_unpack_pp_assemblage(pp_assemblage_ptr, ints, &i, doubles, &d);
		}
	}
	/*
	 *   Exchange
	 */
	if (ints[i++] != 0) {
		/*exchange_ptr = exchange_bsearch(ints[i], &n);*/
		exchange_ptr = sz[iphrq]->exchange;
		if (exchange_ptr == NULL) {
			sprintf(error_string, "Task %d: Did not find recieved exchange %d.", mpi_myself, ints[i]);
			error_msg(error_string, STOP);
		} else {
			mpi_unpack_exchange(exchange_ptr, ints, &i, doubles, &d);
		}
	}
	/*
	 *   Gas phase
	 */
	if (ints[i++] != 0) {
		/*gas_phase_ptr = gas_phase_bsearch(ints[i], &n);*/
		gas_phase_ptr = sz[iphrq]->gas_phase;
		if (gas_phase_ptr == NULL) {
			sprintf(error_string, "Task %d: Did not find recieved gas_phase %d.", mpi_myself, ints[i]);
			error_msg(error_string, STOP);
		} else {
			mpi_unpack_gas_phase(gas_phase_ptr, ints, &i, doubles, &d);
		}
	}
	/*
	 *   Kinetics phase
	 */
	if (ints[i++] != 0) {
		/*kinetics_ptr = kinetics_bsearch(ints[i], &n);*/
		kinetics_ptr = sz[iphrq]->kinetics;
		if (kinetics_ptr == NULL) {
			sprintf(error_string, "Task %d: Did not find recieved kinetics %d.", mpi_myself, ints[i]);
			error_msg(error_string, STOP);
		} else {
			mpi_unpack_kinetics(kinetics_ptr, ints, &i, doubles, &d);
		}
	}
	/*
	 *   Solid solutions
	 */
	if (ints[i++] != 0) {
		/*s_s_assemblage_ptr = s_s_assemblage_bsearch(ints[i], &n);*/
		s_s_assemblage_ptr = sz[iphrq]->s_s_assemblage;
		if (s_s_assemblage_ptr == NULL) {
			sprintf(error_string, "Task %d: Did not find recieved solid_solution %d.", mpi_myself, ints[i]);
			error_msg(error_string, STOP);
		} else {
			mpi_unpack_s_s_assemblage(s_s_assemblage_ptr, ints, &i, doubles, &d);
		}
	}
	/*
	 *   Surface
	 */
	if (ints[i++] != 0) {
		/*surface_ptr = surface_bsearch(ints[i], &n);*/
		surface_ptr = sz[iphrq]->surface;
		if (surface_ptr == NULL) {
			sprintf(error_string, "Task %d: Did not find recieved surface %d.", mpi_myself, ints[i]);
			error_msg(error_string, STOP);
		} else {
			mpi_unpack_surface(surface_ptr, ints, &i, doubles, &d);
		}
	}
	/*
	 *  Unsaturated zone
	 */
	if (ints[i++] != 0) {
		/*
		 * Allocate or free system
		 */
		if (uz[iphrq] == NULL) {
			uz[iphrq] = system_alloc();
		} else {
			system_free(uz[iphrq]);
		}
		frac[ihst] = doubles[d++];
		old_frac[ihst] = frac[ihst];
		/*
		 *   Equilibrium_phases
		 */
		if (ints[i++] != 0) {
			if (uz[iphrq]->pp_assemblage == NULL) {
				if (pp_assemblage_ptr == NULL) {
					sprintf(error_string, "Task %d: Error in UZ pp_assemblage %d.", mpi_myself, iphrq);
					error_msg(error_string, STOP);
				} 
				uz[iphrq]->pp_assemblage = pp_assemblage_alloc();
				pp_assemblage_copy(pp_assemblage_ptr, uz[iphrq]->pp_assemblage, pp_assemblage_ptr->n_user); 
			} 
			mpi_unpack_pp_assemblage(uz[iphrq]->pp_assemblage, ints, &i, doubles, &d);
		}
		/*
		 *   Exchange
		 */
		if (ints[i++] != 0) {
			if (uz[iphrq]->exchange == NULL) {
				if (exchange_ptr == NULL) {
					sprintf(error_string, "Task %d: Error in UZ exchange %d.", mpi_myself, iphrq);
					error_msg(error_string, STOP);
				} 
				uz[iphrq]->exchange = exchange_alloc();
				exchange_copy(exchange_ptr, uz[iphrq]->exchange, exchange_ptr->n_user); 
			} 
			mpi_unpack_exchange(uz[iphrq]->exchange, ints, &i, doubles, &d);
		}
		/*
		 *   Gas phase
		 */
		if (ints[i++] != 0) {
			if (uz[iphrq]->gas_phase == NULL) {
				if (gas_phase_ptr == NULL) {
					sprintf(error_string, "Task %d: Error in UZ gas_phase %d.", mpi_myself, iphrq);
					error_msg(error_string, STOP);
				} 
				uz[iphrq]->gas_phase = gas_phase_alloc();
				gas_phase_copy(gas_phase_ptr, uz[iphrq]->gas_phase, gas_phase_ptr->n_user); 
			} 
			mpi_unpack_gas_phase(uz[iphrq]->gas_phase, ints, &i, doubles, &d);
		}
		/*
		 *   Kinetics phase
		 */
		if (ints[i++] != 0) {
			if (uz[iphrq]->kinetics == NULL) {
				if (kinetics_ptr == NULL) {
					sprintf(error_string, "Task %d: Error in UZ kinetics %d.", mpi_myself, iphrq);
					error_msg(error_string, STOP);
				} 
				uz[iphrq]->kinetics = kinetics_alloc();
				kinetics_copy(kinetics_ptr, uz[iphrq]->kinetics, kinetics_ptr->n_user); 
			} 
			mpi_unpack_kinetics(uz[iphrq]->kinetics, ints, &i, doubles, &d);
		}
		/*
		 *   Solid solutions
		 */
		if (ints[i++] != 0) {
			if (uz[iphrq]->s_s_assemblage == NULL) {
				if (s_s_assemblage_ptr == NULL) {
					sprintf(error_string, "Task %d: Error in UZ s_s_assemblage %d.", mpi_myself, iphrq);
					error_msg(error_string, STOP);
				} 
				uz[iphrq]->s_s_assemblage = s_s_assemblage_alloc();
				s_s_assemblage_copy(s_s_assemblage_ptr, uz[iphrq]->s_s_assemblage, s_s_assemblage_ptr->n_user); 
			} 
			mpi_unpack_s_s_assemblage(uz[iphrq]->s_s_assemblage, ints, &i, doubles, &d);
		}
		/*
		 *   Surface
		 */
		if (ints[i++] != 0) {
			if (uz[iphrq]->surface == NULL) {
				if (surface_ptr == NULL) {
					sprintf(error_string, "Task %d: Error in UZ surface %d.", mpi_myself, iphrq);
					error_msg(error_string, STOP);
				} 
				uz[iphrq]->surface = surface_alloc();
				surface_copy(surface_ptr, uz[iphrq]->surface, surface_ptr->n_user); 
			} 
			mpi_unpack_surface(uz[iphrq]->surface, ints, &i, doubles, &d);
		}
	}
	assert(count_ints == i);
	assert(count_doubles == d);
	buffer = free_check_null(buffer);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_pack_elt_list(struct elt_list *totals, int *ints, int *i, double *doubles, int *d)
/* ---------------------------------------------------------------------- */
{
	int ii, dd, start_ints, j;
	ii = *i;
	dd = *d;
	start_ints = ii++;
	if (totals != NULL) {
		for (j = 0; totals[j].elt != NULL; j++) {
			ints[ii++] = totals[j].elt->master->number;
			doubles[dd++] = totals[j].coef;
		}
	} else {
		j = 0;
	}
	ints[start_ints] = j;
	*d = dd;
	*i = ii;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_unpack_elt_list(struct elt_list **totals, int *ints, int *i, double *doubles, int *d)
/* ---------------------------------------------------------------------- */
{
	int ii, dd, j;
	int count, master_number;
	ii = *i;
	dd = *d;

	count = ints[ii++];
	/*
	 *  Realloc space
	 */
	*totals = PHRQ_realloc(*totals, (size_t) (count + 1) * sizeof(struct elt_list));
	if (*totals == NULL) malloc_error();
	/*
	 *  Fill in totals
	 */
	for (j = 0; j < count; j++) {
		master_number = master[ints[ii++]]->number;
		(*totals)[j].elt = master[master_number]->elt;
		(*totals)[j].coef = doubles[dd++];
	}
	(*totals)[j].elt = NULL;
	*d = dd;
	*i = ii;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_set_random(void)
/* ---------------------------------------------------------------------- */
{
	int i, j, n;
	int *temp_random;
	/*
	 *   Generate array random with chemistry cells randomized
	 */
	temp_random = PHRQ_malloc((size_t) count_chem * sizeof(int));
	if (temp_random == NULL) malloc_error();
	for (i = 0; i < count_chem; i++) {
		temp_random[i] = i;
	}
	n = count_chem;
#ifdef RANDOM
	for (i = 0; i < count_chem; i++) {
		j = rand();
		j = (int) (((double) n)*j/(RAND_MAX));
		/* fprintf(stderr, "Random %d.\n",j);*/
		random_list[i] = temp_random[j];
		if (j < n - 1) {
			temp_random[j] = temp_random[n - 1];
		}
		/*
		fprintf(stderr, "Position %d.\tNatural cell number %d.\n",i, random_list[i]);
		*/
		n--;
	}
#else
	for (i = 0; i < count_chem; i++) {
		random_list[i] = i;
	}
#endif
	temp_random = free_check_null(temp_random);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int int_compare (const void *ptr1, const void *ptr2)
/* ---------------------------------------------------------------------- */
{
	const int *i1, *i2;
	i1 = (const int *) ptr1;
	i2 = (const int *) ptr2;
	if (*i1 > *i2) return(1);
	if (*i1 < *i2) return(-1);
	return(0);
}
#endif
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
int mpi_pack_solution_hst(struct solution *solution_ptr)
/* ---------------------------------------------------------------------- */
{
	/* solution_number is 1 to count_chem */
	int i, j, d;
	int count_totals, count_totals_position;
	int max_size, member_size, position;
	int ints[MESSAGE_MAX_NUMBERS];
	double doubles[MESSAGE_MAX_NUMBERS];
	struct master *master_ptr;

	position = mpi_buffer_position;
/*
 *   Malloc space for a buffer
 */
	max_size = 0;
	MPI_Pack_size(MESSAGE_MAX_NUMBERS, MPI_INT, MPI_COMM_WORLD, &member_size);
	max_size += member_size;
	MPI_Pack_size(MESSAGE_MAX_NUMBERS, MPI_DOUBLE, MPI_COMM_WORLD, &member_size);
	max_size += member_size;
	if (mpi_buffer_position + max_size > mpi_max_buffer) {
		mpi_max_buffer = mpi_buffer_position + max_size;
		mpi_buffer = PHRQ_realloc(mpi_buffer, (size_t) (mpi_max_buffer));
		if (mpi_buffer == NULL) malloc_error();
	}
/*
 *   Make list of list of ints and doubles from solution structure
 *   This list is not the complete structure, but only enough
 *   for batch-reaction, advection, and transport calculations
 */
	/*solution_ptr = solution_bsearch(solution_number, &n, TRUE);*/
	/*solution_ptr = sz[solution_number]->solution;*/
	i = 0;
	d = 0;
	/*	int new_def; */
	/*	int n_user; */
	ints[i++] = solution_ptr->n_user;
	/*	int n_user_end; */
	/*	char *description; */
	/*	double tc; */
	doubles[d++] = solution_ptr->tc;
	/*	double ph; */
	doubles[d++] = solution_ptr->ph;
	/*	double solution_pe; */
	doubles[d++] = solution_ptr->solution_pe;
	/*	double mu; */
	doubles[d++] = solution_ptr->mu;
	/*	double ah2o; */
	doubles[d++] = solution_ptr->ah2o;
	/*	double density; */
	/*	LDBLE total_h; */
	doubles[d++] = solution_ptr->total_h;
	/*	LDBLE total_o; */
	doubles[d++] = solution_ptr->total_o;
	/*	LDBLE cb; */
	doubles[d++] = solution_ptr->cb;
	/*	LDBLE mass_water; */
	doubles[d++] = solution_ptr->mass_water;

	/*	LDBLE total_alkalinity; */
	/*	LDBLE total_co2; */
	/*	char *units; */
	/*	struct pe_data *pe; */
	/*	int default_pe; */
/*
 *	struct conc *totals;
*/
	count_totals_position = i++;
	count_totals = 0;
	for (j = 0; solution_ptr->totals[j].description != NULL; j++ ) {
		master_ptr = master_bsearch(solution_ptr->totals[j].description);
		if (master_ptr == NULL) {
			input_error++;
			sprintf(error_string,"Packing solution message: %s, element not found\n", solution_ptr->totals[j].description);
			error_msg(error_string, CONTINUE);
		}
		ints[i++] = master_ptr->number;
		doubles[d++] = solution_ptr->totals[j].moles;
		count_totals++;
	}
	ints[count_totals_position] = count_totals;
	/*	int count_isotopes; */
	/*	struct isotope *isotopes; */
	if (input_error > 0) {
		error_msg("Stopping due to errors\n", STOP);
	}
/*
 *   Send message to processor
 */
	MPI_Pack(&i, 1, MPI_INT, mpi_buffer, mpi_max_buffer, &position, MPI_COMM_WORLD);
	MPI_Pack(ints, i, MPI_INT, mpi_buffer, mpi_max_buffer, &position, MPI_COMM_WORLD);
	MPI_Pack(&d, 1, MPI_INT, mpi_buffer, mpi_max_buffer, &position, MPI_COMM_WORLD);
	MPI_Pack(doubles, d, MPI_DOUBLE, mpi_buffer, mpi_max_buffer, &position, MPI_COMM_WORLD);
	/*
	MPI_Send(buffer, position, MPI_PACKED, task_number, 0, MPI_COMM_WORLD);
	*/
	mpi_buffer_position = position;

	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_unpack_solution_hst(struct solution *solution_ptr, int solution_number, int msg_size)
/* ---------------------------------------------------------------------- */
{
	/* solution_number is 1 to count_chem */
	int i, j, d;
	int count_ints, count_doubles;
	int count_totals;
	int position;
	int ints[MESSAGE_MAX_NUMBERS];
	double doubles[MESSAGE_MAX_NUMBERS];
	struct master *master_ptr;
/*
 *   Recieve solution
 */
 	position = mpi_buffer_position;
 	MPI_Unpack(mpi_buffer, msg_size, &position, &count_ints, 1, MPI_INT, MPI_COMM_WORLD);
 	MPI_Unpack(mpi_buffer, msg_size, &position, ints, count_ints, MPI_INT, MPI_COMM_WORLD);
 	MPI_Unpack(mpi_buffer, msg_size, &position, &count_doubles, 1, MPI_INT, MPI_COMM_WORLD);
 	MPI_Unpack(mpi_buffer, msg_size, &position, doubles, count_doubles, MPI_DOUBLE, MPI_COMM_WORLD);
 	mpi_buffer_position = position;
/*
 *   Make solution structure
 */
	/* assert(sz[solution_number] != NULL);*/
	/* solution_ptr = sz[solution_number]->solution; */
/*
 *   Make list of list of ints and doubles from solution structure
 *   This list is not the complete structure, but only enough
 *   for batch-reaction, advection, and transport calculations
 */
	i = 0;
	d = 0;
	/*	int new_def; */
	solution_ptr->new_def = FALSE;
	/*	int n_user; */
	solution_ptr->n_user = ints[i++];
	/*	int n_user_end; */
	solution_ptr->n_user_end = solution_ptr->n_user;

	/*debugging*/
	solution_ptr->n_user = solution_number;
	solution_ptr->n_user_end = solution_number;

	/*	char *description; */
	solution_ptr->description = free_check_null(solution_ptr->description);
	solution_ptr->description = string_duplicate(" ");
	/*	double tc; */
	solution_ptr->tc = doubles[d++];
	/*	double ph; */
	solution_ptr->ph = doubles[d++];
	/*	double solution_pe; */
	solution_ptr->solution_pe = doubles[d++];
	/*	double mu; */
	solution_ptr->mu = doubles[d++];
	/*	double ah2o; */
	solution_ptr->ah2o = doubles[d++];
	/*	double density; */
	solution_ptr->density = 1.0;
	/*	LDBLE total_h; */
	solution_ptr->total_h = doubles[d++];
	/*	LDBLE total_o; */
	solution_ptr->total_o = doubles[d++];
	/*	LDBLE cb; */
	solution_ptr->cb = doubles[d++];
	/*	LDBLE mass_water; */
	solution_ptr->mass_water = doubles[d++];
	/*	LDBLE total_alkalinity; */
	solution_ptr->total_alkalinity = 0;
	/*	LDBLE total_co2; */
	solution_ptr->total_co2 = 0;
	/*	char *units; */
	/*	struct pe_data *pe; */
	/*	int default_pe; */
	solution_ptr->default_pe = 0;
/*
 *	struct conc *totals;
*/
	count_totals = ints[i++];
	solution_ptr->totals = PHRQ_realloc(solution_ptr->totals, (size_t) (count_totals + 1) * sizeof(struct conc));
	if (solution_ptr->totals == NULL) malloc_error();
	for (j = 0; j < count_totals; j++) {
		master_ptr = master[ints[i++]];
		solution_ptr->totals[j].description = master_ptr->elt->name;
		solution_ptr->totals[j].moles = doubles[d++];
	}
	solution_ptr->totals[j].description = NULL;
	/*	int count_isotopes; */
	solution_ptr->count_isotopes = 0;
	/*	struct isotope *isotopes; */
	return(OK);
}

/* ---------------------------------------------------------------------- */
int mpi_pack_solution(struct solution *solution_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	/* solution_number is 1 to count_chem */
	int i, j, d;
	int count_totals, count_totals_position, count_activity, count_activity_position;
	struct master *master_ptr;

	i = *ii;
	d = *dd;
	if (solution_ptr == NULL) {
		ints[i++] = 0;
	} else {
		ints[i++] = 1;
		/*	int new_def; */
		/*	int n_user; */
		ints[i++] = solution_ptr->n_user;
		/*	int n_user_end; */
		/*	char *description; */
		/*	double tc; */
		doubles[d++] = solution_ptr->tc;
		/*	double ph; */
		doubles[d++] = solution_ptr->ph;
		/*	double solution_pe; */
		doubles[d++] = solution_ptr->solution_pe;
		/*	double mu; */
		doubles[d++] = solution_ptr->mu;
		/*	double ah2o; */
		doubles[d++] = solution_ptr->ah2o;
		/*	double density; */
		/*	LDBLE total_h; */
		doubles[d++] = solution_ptr->total_h;
		/*	LDBLE total_o; */
		doubles[d++] = solution_ptr->total_o;
		/*	LDBLE cb; */
		doubles[d++] = solution_ptr->cb;
		/*	LDBLE mass_water; */
		doubles[d++] = solution_ptr->mass_water;

		/*	LDBLE total_alkalinity; */
		/*	LDBLE total_co2; */
		/*	char *units; */
		/*	struct pe_data *pe; */
		/*	int default_pe; */
		/*
		 *	struct conc *totals;
		 */
		count_totals_position = i++;
		count_totals = 0;
		for (j = 0; solution_ptr->totals[j].description != NULL; j++ ) {
			master_ptr = master_bsearch(solution_ptr->totals[j].description);
			if (master_ptr == NULL) {
				input_error++;
				sprintf(error_string,"Packing solution message: %s, element not found\n", solution_ptr->totals[j].description);
				error_msg(error_string, CONTINUE);
			}
			ints[i++] = master_ptr->number;
			doubles[d++] = solution_ptr->totals[j].moles;
			count_totals++;
		}
		ints[count_totals_position] = count_totals;
		/*
		 *	struct master_activity *master_activity;
		 */
		count_activity_position = i++;
		count_activity = 0;
		for (j = 0; solution_ptr->master_activity[j].description != NULL; j++ ) {
			master_ptr = master_bsearch(solution_ptr->master_activity[j].description);
			if (master_ptr == NULL) {
				input_error++;
				sprintf(error_string,"Packing solution message: %s, element not found\n", solution_ptr->master_activity[j].description);
				error_msg(error_string, CONTINUE);
			}
			ints[i++] = master_ptr->number;
			doubles[d++] = solution_ptr->master_activity[j].la;
			count_activity++;
		}
		ints[count_activity_position] = count_activity;
		/*	int count_isotopes; */
		/*	struct isotope *isotopes; */
		if (input_error > 0) {
			error_msg("Stopping due to errors\n", STOP);
		}
	}
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_unpack_solution(struct solution *solution_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	/* solution_number is 1 to count_chem */
	int i, j, d;
	int count_totals, count_activity;
	struct master *master_ptr;
	i = *ii;
	d = *dd;
	/*	int new_def; */
	solution_ptr->new_def = FALSE;
	/*	int n_user; */
	solution_ptr->n_user = ints[i++];
	/*	int n_user_end; */
	solution_ptr->n_user_end = solution_ptr->n_user;

	/*debugging*/
	/*
	solution_ptr->n_user = solution_number;
	solution_ptr->n_user_end = solution_number;
	*/
	/*	char *description; */
	solution_ptr->description = free_check_null(solution_ptr->description);
	solution_ptr->description = string_duplicate(" ");
	/*	double tc; */
	solution_ptr->tc = doubles[d++];
	/*	double ph; */
	solution_ptr->ph = doubles[d++];
	/*	double solution_pe; */
	solution_ptr->solution_pe = doubles[d++];
	/*	double mu; */
	solution_ptr->mu = doubles[d++];
	/*	double ah2o; */
	solution_ptr->ah2o = doubles[d++];
	/*	double density; */
	solution_ptr->density = 1.0;
	/*	LDBLE total_h; */
	solution_ptr->total_h = doubles[d++];
	/*	LDBLE total_o; */
	solution_ptr->total_o = doubles[d++];
	/*	LDBLE cb; */
	solution_ptr->cb = doubles[d++];
	/*	LDBLE mass_water; */
	solution_ptr->mass_water = doubles[d++];
	/*	LDBLE total_alkalinity; */
	solution_ptr->total_alkalinity = 0;
	/*	LDBLE total_co2; */
	solution_ptr->total_co2 = 0;
	/*	char *units; */
	/*	struct pe_data *pe; */
	/*	int default_pe; */
	solution_ptr->default_pe = 0;
/*
 *	struct conc *totals;
*/
	count_totals = ints[i++];
	solution_ptr->totals = PHRQ_realloc(solution_ptr->totals, (size_t) (count_totals + 1) * sizeof(struct conc));
	if (solution_ptr->totals == NULL) malloc_error();
	for (j = 0; j < count_totals; j++) {
		master_ptr = master[ints[i++]];
		solution_ptr->totals[j].description = master_ptr->elt->name;
		solution_ptr->totals[j].moles = doubles[d++];
	}
	solution_ptr->totals[j].description = NULL;

/*
 *	struct master_activity *master_activity;
 */
	count_activity = ints[i++];
	solution_ptr->master_activity = PHRQ_realloc(solution_ptr->master_activity, (size_t) (count_activity + 1) * sizeof(struct master_activity));
	if (solution_ptr->master_activity == NULL) malloc_error();
	for (j = 0; j < count_activity; j++) {
		master_ptr = master[ints[i++]];
		solution_ptr->master_activity[j].description = master_ptr->elt->name;
		solution_ptr->master_activity[j].la = doubles[d++];
	}
	solution_ptr->master_activity[j].description = NULL;

	/*	int count_isotopes; */
	solution_ptr->count_isotopes = 0;
	/*	struct isotope *isotopes; */
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int distribute_from_root(double *fraction, int *dim, int *print_sel,
			 double *time_hst, double *time_step_hst, int *prslm,
			 double *frac, 
			 int *printzone_chem, int *printzone_xyz, 
			 int *print_out, int *print_hdf)
/* ---------------------------------------------------------------------- */
{
	int task_number;
	int i, j, k, mpi_msg_size;
	int i1, j1, k1;
	MPI_Status mpi_status;
	struct solution *solution_ptr;

	/* initialize a solution */
	if (mpi_myself == 0) {
		i = random_list[0];   
		solution_ptr = solution_replicate(sz[i]->solution, i);
	} else {
		solution_ptr = NULL;
		i = random_list[end_cells[mpi_myself][0]];
		solution_ptr = solution_replicate(sz[i]->solution, i);
	}
	/*
	if (mpi_myself == 0) {
		unpack_from_hst(fraction, dim);
	}
	*/
	/*
	 *  Send from root to nodes
	 */

	/*solution_bsearch(first_user_number, &first_solution, TRUE);*/
	for (task_number = 1; task_number < mpi_tasks; task_number++) {
		if (mpi_myself == task_number) {
			MPI_Recv(&mpi_msg_size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &mpi_status);
			if (mpi_max_buffer < mpi_msg_size) {
				mpi_max_buffer = mpi_msg_size;
				mpi_buffer = PHRQ_realloc(mpi_buffer, (size_t) mpi_max_buffer);
			}
			MPI_Recv(mpi_buffer, mpi_msg_size, MPI_PACKED, 0, 0, MPI_COMM_WORLD, &mpi_status);
			mpi_buffer_position = 0;
			for (k = end_cells[task_number][0]; k <= end_cells[task_number][1]; k++) {
				i = random_list[k];                        /* 1, count_chem */
				/* n_solution = first_solution + i; */
				/* n_user = solution[n_solution]->n_user; */
				/*mpi_unpack_solution_hst(sz[i]->solution, i, mpi_msg_size);*/
				mpi_unpack_solution_hst(solution_ptr, i, mpi_msg_size);
				solution_to_buffer(solution_ptr);
				buffer_to_solution(sz[i]->solution);
			}
		}
		if (mpi_myself == 0) {
			mpi_buffer_position = 0;
			for (k = end_cells[task_number][0]; k <= end_cells[task_number][1]; k++) {
				i = random_list[k];                        /* 1, count_chem */
				j = back[i].list[0];
				hst_to_buffer(&fraction[j], *dim);
				buffer_to_moles();
				buffer_to_solution(solution_ptr);
				/* n_solution = first_solution + i; */
				/* n_user = solution[n_solution]->n_user; */
				mpi_pack_solution_hst (solution_ptr);
			}
			MPI_Send(&mpi_buffer_position, 1, MPI_INT, task_number, 0, MPI_COMM_WORLD);
			MPI_Send(mpi_buffer, mpi_buffer_position, MPI_PACKED, task_number, 0, MPI_COMM_WORLD);
		}
	}
	if (mpi_myself == 0) {
		/* unpack root solutions */
		for (k = end_cells[0][0]; k <= end_cells[0][1]; k++) {
			i = random_list[k];                        /* 1, count_chem */
			j = back[i].list[0];
			hst_to_buffer(&fraction[j], *dim);
			buffer_to_moles();
			buffer_to_solution(sz[i]->solution);
		}
	} 
	/* free solution_ptr */
	solution_free(solution_ptr);
	/*
	MPI_Bcast(dim, 1,                         MPI_INT,    0, MPI_COMM_WORLD);
	*/
	MPI_Bcast(print_sel, 1,                   MPI_INT,    0, MPI_COMM_WORLD);
	MPI_Bcast(time_hst, 1,                    MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(time_step_hst, 1,               MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(prslm, 1,                       MPI_INT,    0, MPI_COMM_WORLD);
	MPI_Bcast(print_out, 1,                   MPI_INT,    0, MPI_COMM_WORLD);
	MPI_Bcast(print_hdf, 1,                   MPI_INT,    0, MPI_COMM_WORLD);
	if (mpi_myself == 0) {
		for (k = 0; k < count_chem; k++) {
			i = random_list[k];
			j = back[i].list[0];
			random_frac[k] = frac[j];
			random_printzone_chem[k] = printzone_chem[j];
			random_printzone_xyz[k] = printzone_xyz[j];
		}
	}
	for (task_number = 1; task_number < mpi_tasks; task_number++) {
		j = end_cells[task_number][0];
		k = end_cells[task_number][1] - end_cells[task_number][0] + 1;
		if (mpi_myself == 0) {
			MPI_Send(&(random_frac[j]), k, MPI_DOUBLE, task_number, 0, MPI_COMM_WORLD);
			if (*print_out == TRUE) {
				MPI_Send(&(random_printzone_chem[j]), k, MPI_INT, task_number, 0, MPI_COMM_WORLD);
			}
			if (*print_sel == TRUE) {
				MPI_Send(&(random_printzone_xyz[j]), k, MPI_INT, task_number, 0, MPI_COMM_WORLD);
			}
		}
		if (mpi_myself == task_number) {
			MPI_Recv(&(random_frac[j]), k, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, &mpi_status);
			if (*print_out == TRUE ) {
				MPI_Recv(&(random_printzone_chem[j]), k, MPI_INT, 0, 0, MPI_COMM_WORLD, &mpi_status);
			}
			if (*print_sel == TRUE ) {
				MPI_Recv(&(random_printzone_xyz[j]), k, MPI_INT, 0, 0, MPI_COMM_WORLD, &mpi_status);
			}

			/*
			 *  Put frac and printzone into correct positions
			 */
			for (k1 = j; k1 < j + k; k1++) {
				i1 = random_list[k1];
				j1 = back[i1].list[0];
				frac[j1] = random_frac[k1];
			}
			if (*print_out == TRUE ) {
				for (k1 = j; k1 < j + k; k1++) {
					i1 = random_list[k1];
					j1 = back[i1].list[0];
					printzone_chem[j1] = random_printzone_chem[k1];
				}
			}
			if (*print_sel == TRUE ) {
				for (k1 = j; k1 < j + k; k1++) {
					i1 = random_list[k1];
					j1 = back[i1].list[0];
					printzone_xyz[j1] = random_printzone_xyz[k1];
				}
			}
		}
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
void COLLECT_FROM_NONROOT(double *fraction, int *dim)
/* ---------------------------------------------------------------------- */
{
	int task_number;
	int i, j, k;
	int rank;
	int mpi_msg_size;
	MPI_Status mpi_status;
	struct solution *solution_ptr;

	/* initialize a solution */
	if (mpi_myself == 0) {
		i = random_list[0];   
		solution_ptr = solution_replicate(sz[i]->solution, i);
	} else {
		solution_ptr = NULL;
	}
	/*
	 *  Pack messages and send from nodes to root
	 */

	/*solution_bsearch(first_user_number, &first_solution, TRUE);*/
	for (task_number = 1; task_number < mpi_tasks; task_number++) {
		if (mpi_myself == task_number) {
			mpi_buffer_position = 0;
			for (k = end_cells[task_number][0]; k <= end_cells[task_number][1]; k++) {
				i = random_list[k];                    /* i is 1 to count_chem */
				/* n_solution = first_solution + i;*/
				/* n_user = solution[n_solution]->n_user;*/
				/*mpi_pack_solution(n_user);*/
				mpi_pack_solution_hst(sz[i]->solution);
			}
			MPI_Send(&task_number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
			MPI_Send(&mpi_buffer_position, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
			MPI_Send(mpi_buffer, mpi_buffer_position, MPI_PACKED, 0, 0, MPI_COMM_WORLD);
		}
		if (mpi_myself == 0) {
			MPI_Recv(&rank, 1, MPI_INT, MPI_ANY_SOURCE, 0, MPI_COMM_WORLD, &mpi_status);
			MPI_Recv(&mpi_msg_size, 1, MPI_INT, rank, 0, MPI_COMM_WORLD, &mpi_status);
			if (mpi_max_buffer < mpi_msg_size) {
				mpi_max_buffer = mpi_msg_size;
				mpi_buffer = PHRQ_realloc(mpi_buffer, (size_t) mpi_max_buffer);
			}
			MPI_Recv(mpi_buffer, mpi_msg_size, MPI_PACKED, rank, 0, MPI_COMM_WORLD, &mpi_status);
			mpi_buffer_position = 0;
			for (k = end_cells[rank][0]; k <= end_cells[rank][1]; k++) {
				i = random_list[k];
				/*
				  n_solution = first_solution + i;
				  n_user = solution[n_solution]->n_user;
				  mpi_unpack_solution(n_user, mpi_msg_size);
				*/
				mpi_unpack_solution_hst(solution_ptr, i, mpi_msg_size);
				solution_to_buffer(solution_ptr);
				buffer_to_mass_fraction();
				for (j = 0; j < count_back_list; j++) {
					buffer_to_hst(&fraction[back[i].list[j]], *dim);
				}
			}
		}
	}
	if (mpi_myself == 0) {
		/* pack solutions from root process */
		for (k = end_cells[0][0]; k <= end_cells[0][1]; k++) {
			i = random_list[k];
			solution_to_buffer(sz[i]->solution);
			buffer_to_mass_fraction();
			for (j = 0; j < count_back_list; j++) {
				buffer_to_hst(&fraction[back[i].list[j]], *dim);
			}
		}
		/* free solution */
		solution_free(solution_ptr);
	} 
}
#endif
/* ---------------------------------------------------------------------- */
void CALCULATE_WELL_PH(double *c, LDBLE *ph, LDBLE *alkalinity)
/* ---------------------------------------------------------------------- */
{
  struct solution *solution_ptr;
  int i, j, n_user;

  /*
   *  put moles into buffer
   */
  for (j = 0; j < count_component; j++) {
    buffer[j].moles = c[j];
  }
  n_user = -2;
  solution_duplicate(solution[first_solution]->n_user, n_user);
  solution_bsearch(first_user_number, &first_solution, TRUE);
  solution_ptr = solution_bsearch(n_user, &i, FALSE);
  if (solution_ptr == NULL) {
    sprintf(error_string,"Could not find solution %d in calculate_well_ph\n", n_user);
    error_msg(error_string, STOP);
  }
  /*
   * Make enough space
   */
  solution[i]->totals = PHRQ_realloc (solution[i]->totals, (size_t) (count_total - 1) * sizeof(struct conc));
  if (solution[i]->totals == NULL) malloc_error();
  solution[i]->master_activity = PHRQ_realloc (solution[i]->master_activity, (size_t) (count_activity_list + 1) * sizeof(struct master_activity));
  if (solution[i]->master_activity == NULL) malloc_error();
  /*
   *  Zero out solution
   */
  for (j = 0; j < count_total - 1; j++) {
    solution_ptr->totals[j].moles = 0;
  }
  /*
   *  copy buffer to solution
   */
  buffer_to_solution(solution_ptr);
  /*
   * set use flags
   */
  use.temperature_ptr = NULL;
  use.irrev_ptr = NULL;
  use.mix_ptr = NULL;
  /*
 *   set solution
 */
  use.solution_ptr = solution[i];
  use.n_solution_user = n_user;
  use.n_solution = i;
  use.solution_in = TRUE;
  save.solution = TRUE;
  save.n_solution_user = n_user;
  save.n_solution_user_end = n_user;
  /*
   *   Switch out exchange
   */
  use.exchange_ptr = NULL;
  use.exchange_in = FALSE;
  save.exchange = FALSE;
  /*
 *   Switch out gas_phase
 */
  use.gas_phase_ptr = NULL;
  use.gas_phase_in = FALSE;
  save.gas_phase = FALSE;
  /*
 *   Switch out pp_assemblage
 */
  use.pp_assemblage_ptr = NULL;
  use.pp_assemblage_in = FALSE;
  save.pp_assemblage = FALSE;
  /*
 *   Switch out surface
 */
  use.surface_ptr = NULL;
  use.surface_in = FALSE;
  save.surface = FALSE;
  /*
 *   Switch out s_s_assemblage
 */
  use.s_s_assemblage_ptr = NULL;
  use.s_s_assemblage_in = FALSE;
  save.s_s_assemblage = FALSE;
  /*
 *   Switch out kinetics
 */
  use.kinetics_ptr = NULL;
  use.kinetics_in = FALSE;
  save.kinetics = FALSE;

  state = REACTION;
  run_reactions(n_user, 0.0, FALSE, 0.0);
  state = PHAST;
  *ph = -(s_hplus->la);
  *alkalinity = total_alkalinity/mass_water_aq_x;
  return;
}


/*-------------------------------------------------------------------------
 * Function          BeginTimeStep
 *-------------------------------------------------------------------------
 */
void BeginTimeStep(int print_sel, int print_out, int print_hdf)
{
#ifdef HDF5_CREATE
	if (print_hdf == TRUE) {
	  HDFBeginCTimeStep();
	}
#endif
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	/* Always open file for output in case of a warning message */
		MergeBeginTimeStep(print_sel, print_out);
#endif
}

/*-------------------------------------------------------------------------
 * Function          EndTimeStep
 *-------------------------------------------------------------------------
 */
void EndTimeStep(int print_sel, int print_out, int print_hdf)
{
#ifdef HDF5_CREATE
	if (print_hdf == TRUE) {
	  HDFEndCTimeStep();
	}
#endif
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	/* Always open file for output in case of a warning message */
	MergeEndTimeStep(print_sel, print_out);
#endif
}

/*-------------------------------------------------------------------------
 * Function          BeginCell
 *-------------------------------------------------------------------------
 */
void BeginCell(int print_sel, int print_out, int print_hdf, int index)
{
#ifdef HDF5_CREATE
		if (print_hdf == TRUE) {
		  HDFSetCell(index);
		}
#endif
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
		/* Always open file for output in case of a warning message */
		MergeBeginCell();
#endif
}

/*-------------------------------------------------------------------------
 * Function          EndCell
 *-------------------------------------------------------------------------
 */
void EndCell(int print_sel, int print_out, int print_hdf, int index)
{
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	/* Always open file for output in case of a warning message */
	MergeEndCell();
#endif
}

/*-------------------------------------------------------------------------
 * Function          mpi_fopen
 *-------------------------------------------------------------------------
 */
FILE *mpi_fopen(const char *filename, const char *mode)
{
	FILE* file_ptr;
	if ((file_ptr = tmpfile()) == NULL) {
		sprintf(error_string, "Can't open temporary file.");
		error_msg(error_string, STOP);
	}
#ifdef SKIP
	char default_name[MAX_LENGTH];
	sprintf(default_name, "%d.%s", mpi_myself, filename);
	if ((file_ptr = fopen(default_name, "w")) == NULL) {
		sprintf(error_string, "Can't open file, %s.", default_name);
		error_msg(error_string, STOP);
	}
#endif
	return file_ptr;
}
/* ---------------------------------------------------------------------- */
int dump_surface_hst(struct surface *surface_ptr)
/* ---------------------------------------------------------------------- */
{
/*
 *   Print moles of each surface master species
 */
	int i, j, l;

	/* if ((surface_ptr = surface_bsearch(k, &n)) == NULL) return(OK);*/

	output_msg(OUTPUT_SCREEN, "SURFACE \n");
	/*	int n_user; */
	output_msg(OUTPUT_SCREEN,"n_user = %d\n", surface_ptr->n_user);
	/*	int n_user_end; */
	output_msg(OUTPUT_SCREEN,"n_user_end = %d\n", surface_ptr->n_user_end);
	/*	int new_def; */
	output_msg(OUTPUT_SCREEN,"new_def = %d\n", surface_ptr->new_def);
	/*	int diffuse_layer; */
	output_msg(OUTPUT_SCREEN,"diffuse_layer = %d\n", surface_ptr->diffuse_layer);
	/*	int edl; */
	output_msg(OUTPUT_SCREEN,"edl = %d\n", surface_ptr->edl);
	/*	int only_counter_ions; */
	output_msg(OUTPUT_SCREEN,"only_counter_ions = %d\n", surface_ptr->only_counter_ions);
	/*	double thickness; */
	output_msg(OUTPUT_SCREEN,"thickness = %e\n", (double) surface_ptr->thickness);
	/*	char *description; */
	output_msg(OUTPUT_SCREEN,"description = %s\n", surface_ptr->description);
	/*	int solution_equilibria; */
	output_msg(OUTPUT_SCREEN,"solution_equilibria = %d\n", surface_ptr->solution_equilibria);
	/*	int n_solution; */
	output_msg(OUTPUT_SCREEN,"n_solution = %d\n", surface_ptr->n_solution);
	/*	int count_comps; */
	output_msg(OUTPUT_SCREEN,"count_comps = %d\n", surface_ptr->count_comps);
	/* struct surface_comp *comps; */
	for (i = 0; i < surface_ptr->count_comps; i++) {
		/* 	char *formula; */
		output_msg(OUTPUT_SCREEN,"formula = %s\n", surface_ptr->comps[i].formula);
		/* 	LDBLE moles; */
		output_msg(OUTPUT_SCREEN,"\tmoles = %e\n", (double) surface_ptr->comps[i].moles);
		/*	struct master *master; */
		output_msg(OUTPUT_SCREEN,"\tmaster = %s\n", surface_ptr->comps[i].master->s->name);
		/*	struct elt_list *totals; */
		output_msg(OUTPUT_SCREEN,"\ttotals\n");
		for (j = 0; surface_ptr->comps[i].totals[j].elt != NULL; j++) {
			output_msg(OUTPUT_SCREEN, "\t\t%s\t%e\n", surface_ptr->comps[i].totals[j].elt->name,
				(double) surface_ptr->comps[i].totals[j].coef);
		}
		/*	LDBLE la; */
		output_msg(OUTPUT_SCREEN,"\tla = %e\n", (double) surface_ptr->comps[i].la);
		/*	int charge; */
		output_msg(OUTPUT_SCREEN,"\tcharge = %e\n", (double) surface_ptr->comps[i].charge);
		/*	LDBLE cb; */
		output_msg(OUTPUT_SCREEN,"\tcb = %e\n", (double) surface_ptr->comps[i].cb);
		/*	char *phase_name; */
		if (surface_ptr->comps[i].phase_name != NULL) {
			output_msg(OUTPUT_SCREEN,"\tphase_name = %s\n", surface_ptr->comps[i].phase_name);
		} else {
			output_msg(OUTPUT_SCREEN,"\tphase_name = \n");
		}
		/*	double phase_proportion; */
		output_msg(OUTPUT_SCREEN,"\tphase_proportion = %e\n", (double) surface_ptr->comps[i].phase_proportion);
		/*	char *rate_name; */
		if (surface_ptr->comps[i].rate_name != NULL) {
			output_msg(OUTPUT_SCREEN,"\trate_name = %s\n", surface_ptr->comps[i].rate_name);
		} else {
			output_msg(OUTPUT_SCREEN,"\trate_name = \n");
		}
	}
	/*	int count_charge; */
	output_msg(OUTPUT_SCREEN,"count_charge = %d\n", surface_ptr->count_charge);
	/* struct surface_charge *charge;*/
	if (surface_ptr->edl == TRUE) {
		for (l = 0; l < surface_ptr->count_charge; l++) {
			output_msg(OUTPUT_SCREEN, "name = %s\n", surface_ptr->charge[l].name);
			output_msg(OUTPUT_SCREEN, "\tspecific_area = %e\n", (double) surface_ptr->charge[l].specific_area);
			output_msg(OUTPUT_SCREEN, "\tgrams = %e\n", (double) surface_ptr->charge[l].grams);
			output_msg(OUTPUT_SCREEN, "\tcharge_balance = %e\n", (double) surface_ptr->charge[l].charge_balance);
			output_msg(OUTPUT_SCREEN, "\tmass_water = %e\n", (double) surface_ptr->charge[l].mass_water);
			if (surface_ptr->charge[l].diffuse_layer_totals != NULL) {
				for (j = 0; surface_ptr->charge[l].diffuse_layer_totals[j].elt != NULL; j++) {
					output_msg(OUTPUT_SCREEN, "\t\t%s\t%e\n", 
						   surface_ptr->charge[l].diffuse_layer_totals[j].elt->name,
						   (double) surface_ptr->charge[l].diffuse_layer_totals[j].coef);
				}
			}
			output_msg(OUTPUT_SCREEN,"\tcount_charge = %d\n", surface_ptr->charge[l].count_g);
			/* g */
			/* psi_master */
			if ( surface_ptr->charge[l].psi_master != NULL) {
				output_msg(OUTPUT_SCREEN,"\tcount_charge = %s\n", surface_ptr->charge[l].psi_master->s->name);
			} else {		
				output_msg(OUTPUT_SCREEN,"\tcount_charge = \n");
			} 
			output_msg(OUTPUT_SCREEN,"\tla_psi = %e\n", (double) surface_ptr->charge[l].la_psi);
		}
	}
	/*	int related_phases; */
	output_msg(OUTPUT_SCREEN,"related_phases = %d\n", surface_ptr->related_phases);
	/*	int related_rate; */
	output_msg(OUTPUT_SCREEN,"related_rate = %d\n", surface_ptr->related_rate);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int dump_exchange_hst(int k)
/* ---------------------------------------------------------------------- */
{
/*
 *   Print exchange assemblage
 */
	int i, j, n;
	struct exchange *exchange_ptr;

	if ((exchange_ptr = exchange_bsearch(k, &n)) == NULL) return(OK);

	output_msg(OUTPUT_SCREEN, "EXCHANGE %d\n", k);
	/*	int n_user; */
	output_msg(OUTPUT_SCREEN,"n_user = %d\n", exchange_ptr->n_user);
	/*	int n_user_end; */
	output_msg(OUTPUT_SCREEN,"n_user_end = %d\n", exchange_ptr->n_user_end);
	/*	int new_def; */
	output_msg(OUTPUT_SCREEN,"new_def = %d\n", exchange_ptr->new_def);
	/*	char *description; */
	output_msg(OUTPUT_SCREEN,"description = %s\n", exchange_ptr->description);
	/*	int solution_equilibria; */
	output_msg(OUTPUT_SCREEN,"solution_equilibria = %d\n", exchange_ptr->solution_equilibria);
	/*	int n_solution; */
	output_msg(OUTPUT_SCREEN,"n_solution = %d\n", exchange_ptr->n_solution);
	/*	int count_comps; */
	output_msg(OUTPUT_SCREEN,"count_comps = %d\n", exchange_ptr->count_comps);
	/* struct exchange_comp *comps; */
	for (i = 0; i < exchange[n].count_comps; i++) {
		/* 	char *formula; */
		output_msg(OUTPUT_SCREEN,"formula = %s\n", exchange[n].comps[i].formula);
		/* 	char *formula_z; */
		output_msg(OUTPUT_SCREEN,"formula_z = %e\n", (double) exchange[n].comps[i].formula_z);
		output_msg(OUTPUT_SCREEN,"\tformula totals\n");
		for (j = 0; exchange[n].comps[i].totals[j].elt != NULL; j++) {
			output_msg(OUTPUT_SCREEN, "\t\t%s\t%e\n", exchange[n].comps[i].totals[j].elt->name,
				(double) exchange[n].comps[i].totals[j].coef);
		}
		/* 	LDBLE moles; */
		output_msg(OUTPUT_SCREEN,"\tmoles = %e\n", (double) exchange[n].comps[i].moles);
		/*	struct master *master; */
		output_msg(OUTPUT_SCREEN,"\tmaster = %p\n", (void *) exchange[n].comps[i].master);
		/*		output_msg(OUTPUT_SCREEN,"\tmaster = %s\n", exchange[n].comps[i].master->s->name); */
		/*	struct elt_list *totals; */
		output_msg(OUTPUT_SCREEN,"\ttotals\n");
		for (j = 0; exchange[n].comps[i].totals[j].elt != NULL; j++) {
			output_msg(OUTPUT_SCREEN, "\t\t%s\t%e\n", exchange[n].comps[i].totals[j].elt->name,
				(double) exchange[n].comps[i].totals[j].coef);
		}
		/*	LDBLE la; */
		output_msg(OUTPUT_SCREEN,"\tla = %e\n", (double) exchange[n].comps[i].la);
		/*	int charge; */
		output_msg(OUTPUT_SCREEN,"\tcharge_balance = %e\n", (double) exchange[n].comps[i].charge_balance);
		/*	char *phase_name; */
		if (exchange[n].comps[i].phase_name != NULL) {
			output_msg(OUTPUT_SCREEN,"\tphase_name = %s\n", exchange[n].comps[i].phase_name);
		} else {
			output_msg(OUTPUT_SCREEN,"\tphase_name = \n");
		}
		/*	double phase_proportion; */
		output_msg(OUTPUT_SCREEN,"\tphase_proportion = %e\n", (double) exchange[n].comps[i].phase_proportion);
		/*	char *rate_name; */
		if (exchange[n].comps[i].rate_name != NULL) {
			output_msg(OUTPUT_SCREEN,"\trate_name = %s\n", exchange[n].comps[i].rate_name);
		} else {
			output_msg(OUTPUT_SCREEN,"\trate_name = \n");
		}
	}
	/*	int related_phases; */
	output_msg(OUTPUT_SCREEN,"related_phases = %d\n", exchange_ptr->related_phases);
	/*	int related_rate; */
	output_msg(OUTPUT_SCREEN,"related_rate = %d\n", exchange_ptr->related_rate);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int dump_kinetics_hst (struct kinetics *kinetics_ptr)
/* ---------------------------------------------------------------------- */
{
/*
 *      Dumps kinetics data
 */
	int i, j;
	struct kinetics_comp *kinetics_comp_ptr;

	if (kinetics_ptr == NULL) {
		output_msg(OUTPUT_DUMP, "NULL ptr to dump_kinetics_hst\n");
		return(OK);
	}
	output_msg(OUTPUT_DUMP, "KINETICS  %d\n", kinetics_ptr->n_user);
	/* int n_user; */
	output_msg(OUTPUT_DUMP,"\tn_user = %d\n", kinetics_ptr->n_user);
	/* int n_user_end; */
	output_msg(OUTPUT_DUMP, "\tn_user_end = %d\n", kinetics_ptr->n_user_end);
	/* char *description; */
	output_msg(OUTPUT_DUMP, "\tdescription = %s\n", kinetics_ptr->description);
	/* int count_steps;*/
	output_msg(OUTPUT_DUMP, "\tcount_steps = %d\n", kinetics_ptr->count_steps);
	/* LDBLE *steps; */
	for (i = 0; i < kinetics_ptr->count_steps; i++) {
		output_msg(OUTPUT_DUMP, "\t\t%15.6e\n", (double) kinetics_ptr->steps[i]);
	}
	/* LDBLE step_divide; */
	output_msg(OUTPUT_DUMP, "\tstep_divide = %15.6e\n", (double) kinetics_ptr->step_divide);
	/* char *units;*/
	output_msg(OUTPUT_DUMP, "\tunits = %s\n", kinetics_ptr->units);
	/* struct elt_list *totals;*/
	output_msg(OUTPUT_DUMP,"\ttotals\n");
	if (kinetics_ptr->totals != NULL) {
		for (j = 0; kinetics_ptr->totals[j].elt != NULL; j++) {
			output_msg(OUTPUT_DUMP, "\t\t%s\t%e\n", kinetics_ptr->totals[j].elt->name,
				   (double) kinetics_ptr->totals[j].coef);
		}
	}
	/* int rk;*/
	output_msg(OUTPUT_DUMP, "\trk = %d\n", kinetics_ptr->rk);
	/* int bad_step_max;*/
	output_msg(OUTPUT_DUMP, "\tbad_step_max = %d\n", kinetics_ptr->bad_step_max);
	/* int use_cvode;*/
	output_msg(OUTPUT_DUMP, "\tuse_cvode = %d\n", kinetics_ptr->use_cvode);
	/* int count_comps */
	output_msg(OUTPUT_DUMP, "\tcount_comps = %d\n", kinetics_ptr->count_comps);
	for (i = 0; i < kinetics_ptr->count_comps; i++) {
		kinetics_comp_ptr = &kinetics_ptr->comps[i];
		/* char *rate_name; */
		output_msg(OUTPUT_DUMP, "\trate_name = %-15s\n", kinetics_comp_ptr->rate_name);
		/* int count_list; */
		output_msg(OUTPUT_DUMP, "\t\tcount_list = %d\n", kinetics_comp_ptr->count_list);
		/* struct name_coef *list; */
		output_msg(OUTPUT_DUMP, "\t\tformula = ");
		for (j = 0; j < kinetics_comp_ptr->count_list; j++) {
			output_msg(OUTPUT_DUMP, "\t\t\t%s  %12.3e\n", kinetics_comp_ptr->list[j].name, (double) kinetics_comp_ptr->list[j].coef);
		}
		/*	struct phase *phase; */
		/* LDBLE tol; */
		output_msg(OUTPUT_DUMP, "\t\ttol = %15.2e\n", (double) kinetics_comp_ptr->tol);
		/* LDBLE m; */
		output_msg(OUTPUT_DUMP, "\t\tm = %15.2e\n", (double) kinetics_comp_ptr->m);
		/* LDBLE m0; */
		output_msg(OUTPUT_DUMP, "\t\tm0 = %15.6e\n", (double) kinetics_comp_ptr->m0);
		/* LDBLE initial_moles */
		output_msg(OUTPUT_DUMP, "\t\tinitial_moles = %15.6e\n", (double) kinetics_comp_ptr->initial_moles);
		/* LDBLE moles */
		output_msg(OUTPUT_DUMP, "\t\tmoles = %15.6e\n", (double) kinetics_comp_ptr->moles);
		/* int count_c_params; */
		/* char **c_params; */
		/* int count_d_params; */
		output_msg(OUTPUT_DUMP, "\t\tcount_d_params = %d\n", (double) kinetics_comp_ptr->count_d_params);
		/* LDBLE *d_params; */
		output_msg(OUTPUT_DUMP, "\t\tparm =");
		for (j = 0; j < kinetics_comp_ptr->count_d_params; j++) {
				output_msg(OUTPUT_DUMP, "\t\t\t%15.6e\n", (double) kinetics_comp_ptr->d_params[j]);
		}
	}
	output_msg(OUTPUT_DUMP, "END KINETICS  %d\n", kinetics_ptr->n_user);
	return(OK);}

/* ---------------------------------------------------------------------- */
int UZ_INIT(int * transient_fresur)
/* ---------------------------------------------------------------------- */
{
	int i;

	transient_free_surface = *transient_fresur;
	if (transient_free_surface == TRUE) {
		old_frac = (LDBLE *) PHRQ_malloc((size_t) (ixyz * sizeof(LDBLE)));
		if (old_frac == NULL) malloc_error();
		for (i = 0; i < ixyz; i++) {
			old_frac[i] = 1.0;
		}
		uz = PHRQ_malloc((size_t) (count_chem * sizeof(struct system)));
		if (uz == NULL) malloc_error();
		for (i = 0; i < count_chem; i++) {
			uz[i] = NULL;
		}
	} else {
		old_frac = NULL;
		uz = NULL;
	}
	
	return(OK);
}
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
int mpi_pack_pp_assemblage(struct pp_assemblage *pp_assemblage_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j;
	i = *ii;
	d = *dd;
	if (pp_assemblage_ptr == NULL) {
		ints[i++] = 0;
	} else {
		ints[i++] = 1;
		/* int n_user; */
		ints[i++] = pp_assemblage_ptr->n_user;

		/* int n_user_end; */
		/* char *description; */
		/* int new_def; */
		/* struct elt_list *next_elt; */
		/*	struct elt_list *next_secondary; */
		/* int count_comps; */
		ints[i++] = pp_assemblage_ptr->count_comps;
		/* struct pure_phase *pure_phases; */
		for (j = 0; j < pp_assemblage_ptr->count_comps; j++) {
			doubles[d++] = pp_assemblage_ptr->pure_phases[j].si;
			doubles[d++] = pp_assemblage_ptr->pure_phases[j].moles;
			doubles[d++] = pp_assemblage_ptr->pure_phases[j].delta;
		}
	}
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_pack_exchange(struct exchange *exchange_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j;
	i = *ii;
	d = *dd;
	if (exchange_ptr == NULL) {
		ints[i++] = 0;
	} else {
		ints[i++] = 1;
		/* int n_user; */
		ints[i++] = exchange_ptr->n_user;
		/* int n_user_end; */
		/* int new_def; */
		/* char *description; */
		/* int solution_equilibria; */
		/* int n_solution; */
		/* int count_comps; */
		ints[i++] = exchange_ptr->count_comps;
		/* struct exch_comp *comps; */
		for (j = 0; j < exchange_ptr->count_comps; j++) {
			/* char *formula; */
			/* double formula_z; */
			/* struct elt_list *formula_totals; */
			mpi_pack_elt_list(exchange_ptr->comps[j].formula_totals, ints, &i, doubles, &d);
			/* LDBLE moles; */
			/* struct master *master; */
			/* struct elt_list *totals; */
			mpi_pack_elt_list(exchange_ptr->comps[j].totals, ints, &i, doubles, &d);
			/* LDBLE la; */
			doubles[d++] = exchange_ptr->comps[j].la;
			/* LDBLE charge_balance; */
			doubles[d++] = exchange_ptr->comps[j].charge_balance;
			/* char *phase_name; */
			/* double phase_proportion; */
			/* char *rate_name; */
		}
		/* int related_phases; */
		/* int related_rate; */
	}
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_pack_gas_phase(struct gas_phase *gas_phase_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j;
	i = *ii;
	d = *dd;
	if (gas_phase_ptr == NULL) {
		ints[i++] = 0;
	} else {
		ints[i++] = 1;
		/* int n_user; */
		ints[i++] = gas_phase_ptr->n_user;
		/* int n_user_end; */
		/* char *description; */
		/* int new_def; */
		/* int solution_equilibria; */
		/* int n_solution; */
		/* int type; */
		ints[i++] = gas_phase_ptr->type;
		/* LDBLE total_p; */
		doubles[d++] = gas_phase_ptr->total_p;
		/* LDBLE total_moles; */
		doubles[d++] = gas_phase_ptr->total_moles;
		/* double volume; */
		doubles[d++] = gas_phase_ptr->volume;
		/* double temperature; */
		doubles[d++] = gas_phase_ptr->temperature;
		/* int count_comps; */
		ints[i++] = gas_phase_ptr->count_comps;
		/* struct gas_comp *comps; */
		for (j = 0; j < gas_phase_ptr->count_comps; j++) {
			doubles[d++] = gas_phase_ptr->comps[j].moles;
		}
	}
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_pack_kinetics(struct kinetics *kinetics_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j;
	i = *ii;
	d = *dd;
	if (kinetics_ptr == NULL) {
		ints[i++] = 0;
	} else {
		ints[i++] = 1;
		/* int n_user; */
		ints[i++] = kinetics_ptr->n_user;
		/* int n_user_end; */
		/* char *description; */
		/* int count_comps; */
		ints[i++] = kinetics_ptr->count_comps;
		/* struct kinetics_comp *comps; */
		for (j = 0; j < kinetics_ptr->count_comps; j++) {
			/* char *rate_name; */
			/* struct name_coef *list; */
			/* int count_list; */
			/* double tol; */
			/* LDBLE m; */
			doubles[d++] = kinetics_ptr->comps[j].m;
			/* double m0; */
			doubles[d++] = kinetics_ptr->comps[j].m0;
			/* LDBLE moles; */
			doubles[d++] = kinetics_ptr->comps[j].moles;
			/* int count_c_params; */
			/* char **c_params; */
			/* int count_d_params; */
			/* double *d_params; */
		}
		/* int count_steps; */
		/* double *steps; */
		/* double step_divide; */
		/* char *units; */
		/* struct elt_list *totals; */
		/* int rk; */
	}
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_pack_s_s_assemblage(struct s_s_assemblage *s_s_assemblage_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j, k;
	i = *ii;
	d = *dd;
	if (s_s_assemblage_ptr == NULL) {
		ints[i++] = 0;
	} else {
		ints[i++] = 1;
		/* int n_user; */
		ints[i++] = s_s_assemblage_ptr->n_user;
		/* int n_user_end; */
		/* char *description; */
		/* int new_def; */
		/* int count_s_s; */
		ints[i++] = s_s_assemblage_ptr->count_s_s;
		/* struct s_s *s_s; */
		for (j = 0; j < s_s_assemblage_ptr->count_s_s; j++) {
			/* char *name; */
			/* int count_comps; */
			ints[i++] = s_s_assemblage_ptr->s_s[j].count_comps;
			/* struct s_s_comp *comps; */
			for (k = 0; k < s_s_assemblage_ptr->s_s[j].count_comps; k++) {
				/* char *name; */
				/* struct phase *phase; */
				/* double initial_moles; */
				/* LDBLE moles; */
				doubles[d++] = s_s_assemblage_ptr->s_s[j].comps[k].moles;
				/* LDBLE delta; */
				/* LDBLE fraction_x; */
				/* LDBLE log10_lambda; */
				/* LDBLE log10_fraction_x; */
				/* LDBLE dn, dnc, dnb; */
			}
			/* LDBLE total_moles; */
			/* LDBLE dn; */
			/* double a0, a1; */
			/* double ag0, ag1; */
			/* int s_s_in; */
			/* int miscibility; */
			/* int spinodal; */
			/* double tk, xb1, xb2; */
			/* int input_case; */
			/* double p[4]; */
		}

	}
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_pack_surface(struct surface *surface_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j;
	i = *ii;
	d = *dd;
	if (surface_ptr == NULL) {
		ints[i++] = 0;
	} else {
		ints[i++] = 1;
		/* int n_user; */
		ints[i++] = surface_ptr->n_user;
		/* int n_user_end; */
		/* int new_def; */
		/* int diffuse_layer; */
		/* int edl; */
		/* int only_counter_ions; */
		/* double thickness; */
		/* char *description; */
		/* int solution_equilibria; */
		/* int n_solution; */
		/* int count_comps; */
		ints[i++] = surface_ptr->count_comps;
		/* struct surface_comp *comps; */
		for (j = 0; j < surface_ptr->count_comps; j++) {
			/* char *formula; */
			/* LDBLE moles; */
			/* struct master *master; */
			/* struct elt_list *totals; */
			mpi_pack_elt_list(surface_ptr->comps[j].totals, ints, &i, doubles, &d);
			/* LDBLE la; */
			doubles[d++] = surface_ptr->comps[j].la;
			/* int charge; */
			ints[i++] = surface_ptr->comps[j].charge;
			/* LDBLE cb; */
			doubles[d++] = surface_ptr->comps[j].cb;
			/* char *phase_name; */
			/* double phase_proportion; */
			/* char *rate_name; */
		}
		if (surface_ptr->edl == TRUE) {
			/* int count_charge; */
			ints[i++] = surface_ptr->count_charge;
			/* struct surface_charge *charge; */
			for (j = 0; j < surface_ptr->count_charge; j++) {
				/* char *name; */
				/* double specific_area; */
				/* LDBLE grams; */
				doubles[d++] = surface_ptr->charge[j].grams;
				/* LDBLE charge_balance; */
				doubles[d++] = surface_ptr->charge[j].charge_balance;
				/* LDBLE mass_water; */
				doubles[d++] = surface_ptr->charge[j].mass_water;
				/* struct elt_list *diffuse_layer_totals; */
				mpi_pack_elt_list(surface_ptr->charge[j].diffuse_layer_totals, ints, &i, doubles, &d);
				/* int count_g; */
				/* struct surface_diff_layer *g; */  /* stores g and dg/dXd for each ionic charge */
				/* struct master *psi_master; */
				/* LDBLE la_psi; */
				doubles[d++] = surface_ptr->charge[j].la_psi;
			}
			/* int related_phases; */
			/* int related_rate; */
		}
	}
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_unpack_pp_assemblage(struct pp_assemblage *pp_assemblage_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j;
	i = *ii;
	d = *dd;
	/* int n_user; */
	pp_assemblage_ptr->n_user = ints[i++];
	/* int n_user_end; */
	pp_assemblage_ptr->n_user_end = pp_assemblage_ptr->n_user;
	/* char *description; */
	/* int new_def; */
	/* pp_assemblage_ptr->new_def = FALSE; */  /* pp_assemblage may be new at receiving processor */
	/* struct elt_list *next_elt; */
	/*	struct elt_list *next_secondary; */
	/* int count_comps; */
	pp_assemblage_ptr->count_comps = ints[i++];
	/* struct pure_phase *pure_phases; */
	for (j = 0; j < pp_assemblage_ptr->count_comps; j++) {
		pp_assemblage_ptr->pure_phases[j].si = doubles[d++];
		pp_assemblage_ptr->pure_phases[j].moles = doubles[d++];
		pp_assemblage_ptr->pure_phases[j].delta = doubles[d++];
	}
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_unpack_exchange(struct exchange *exchange_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j, old_count_comps, k;
	i = *ii;
	d = *dd;
	/* int n_user; */
	exchange_ptr->n_user = ints[i++];
	/* int n_user_end; */
	exchange_ptr->n_user_end = exchange_ptr->n_user;
	/* int new_def; */
	/* exchange_ptr->new_def = FALSE; */ /* exchange assemblage may be new at receiving processor */
	/* char *description; */
	/* int solution_equilibria; */
	/* int n_solution; */
	/* int count_comps; */
	old_count_comps = exchange_ptr->count_comps;
	exchange_ptr->count_comps = ints[i++];
	if (exchange_ptr->count_comps > old_count_comps) {
		exchange_ptr->comps = (struct exch_comp *) PHRQ_realloc(exchange_ptr->comps, (size_t) (exchange_ptr->count_comps) * sizeof (struct exch_comp));
		if (exchange_ptr->comps == NULL) malloc_error();
		for (k = old_count_comps; k < exchange_ptr->count_comps; k++) {
			exchange_ptr->comps[k].formula_totals = NULL;
			exchange_ptr->comps[k].phase_name = NULL;
			exchange_ptr->comps[k].phase_proportion = 0.0;
			exchange_ptr->comps[k].rate_name = NULL;
			exchange_ptr->comps[k].formula = string_hsave("New");
			/*warning_msg("New component added to exchanger in recv_system.");*/
		}
	} else if (exchange_ptr->count_comps < old_count_comps) {
		for (k = exchange_ptr->count_comps; k < old_count_comps; k++) {
			free_check_null(exchange_ptr->comps[k].formula_totals);
			free_check_null(exchange_ptr->comps[k].totals);
		}
	}
	/* struct exch_comp *comps; */
	for (j = 0; j < exchange_ptr->count_comps; j++) {
		/* char *formula; */
		/* double formula_z; */
		/* struct elt_list *formula_totals; */
		mpi_unpack_elt_list(&(exchange_ptr->comps[j].formula_totals), ints, &i, doubles, &d);
		/* LDBLE moles; */
		/* struct master *master; */
		/* struct elt_list *totals; */
		mpi_unpack_elt_list(&(exchange_ptr->comps[j].totals), ints, &i, doubles, &d);
		/* LDBLE la; */
		exchange_ptr->comps[j].la = doubles[d++];
		/* LDBLE charge_balance; */
		exchange_ptr->comps[j].charge_balance = doubles[d++];
		/* char *phase_name; */
		/* double phase_proportion; */
		/* char *rate_name; */
	}
	/* int related_phases; */
	/* int related_rate; */
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_unpack_gas_phase(struct gas_phase *gas_phase_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j;
	i = *ii;
	d = *dd;
	/* int n_user; */
	gas_phase_ptr->n_user = ints[i];
	/* int n_user_end; */
	gas_phase_ptr->n_user_end = ints[i++];
	/* char *description; */
	/* int new_def; */
	/* gas_phase_ptr->new_def = FALSE; */ /* gas phase may be new at receiving processor */
	/* int solution_equilibria; */
	/* int n_solution; */
	/* int type; */
	gas_phase_ptr->type = ints[i++];
	/* LDBLE total_p; */
	gas_phase_ptr->total_p = doubles[d++];
	/* LDBLE total_moles; */
	gas_phase_ptr->total_moles = doubles[d++];
	/* double volume; */
	gas_phase_ptr->volume = doubles[d++];
	/* double temperature; */
	gas_phase_ptr->temperature = doubles[d++];
	/* int count_comps; */
	gas_phase_ptr->count_comps = ints[i++];
	/* struct gas_comp *comps; */
	for (j = 0; j < gas_phase_ptr->count_comps; j++) {
		gas_phase_ptr->comps[j].moles = doubles[d++];
	}
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_unpack_kinetics(struct kinetics *kinetics_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j;
	i = *ii;
	d = *dd;
	/* int n_user; */
	kinetics_ptr->n_user = ints[i];
	/* int n_user_end; */
	kinetics_ptr->n_user_end = ints[i++];
	/* char *description; */
	/* int count_comps; */
	kinetics_ptr->count_comps = ints[i++];
	/* struct kinetics_comp *comps; */
	for (j = 0; j < kinetics_ptr->count_comps; j++) {
		/* char *rate_name; */
		/* struct name_coef *list; */
		/* int count_list; */
		/* double tol; */
		/* LDBLE m; */
		kinetics_ptr->comps[j].m = doubles[d++];
		/* double m0; */
		kinetics_ptr->comps[j].m0 = doubles[d++];
		/* LDBLE moles; */
		kinetics_ptr->comps[j].moles = doubles[d++];
		/* int count_c_params; */
		/* char **c_params; */
		/* int count_d_params; */
		/* double *d_params; */
	}
	/* int count_steps; */
	/* double *steps; */
	/* double step_divide; */
	/* char *units; */
	/* struct elt_list *totals; */
	/* int rk; */
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_unpack_s_s_assemblage(struct s_s_assemblage *s_s_assemblage_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j, k;
	i = *ii;
	d = *dd;
	/* int n_user; */
	s_s_assemblage_ptr->n_user = ints[i];
	/* int n_user_end; */
	s_s_assemblage_ptr->n_user_end = ints[i++];
	/* char *description; */
	/* int new_def; */
	/* int count_s_s; */
	s_s_assemblage_ptr->count_s_s = ints[i++];
	/* struct s_s *s_s; */
	for (j = 0; j < s_s_assemblage_ptr->count_s_s; j++) {
		/* char *name; */
		/* int count_comps; */
		s_s_assemblage_ptr->s_s[j].count_comps = ints[i++];
		/* struct s_s_comp *comps; */
		for (k = 0; k < s_s_assemblage_ptr->s_s[j].count_comps; k++) {
			/* char *name; */
			/* struct phase *phase; */
			/* double initial_moles; */
			/* LDBLE moles; */
			s_s_assemblage_ptr->s_s[j].comps[k].moles = doubles[d++];
			/* LDBLE delta; */
			/* LDBLE fraction_x; */
			/* LDBLE log10_lambda; */
			/* LDBLE log10_fraction_x; */
			/* LDBLE dn, dnc, dnb; */
		}
		/* LDBLE total_moles; */
		/* LDBLE dn; */
		/* double a0, a1; */
		/* double ag0, ag1; */
		/* int s_s_in; */
		/* int miscibility; */
		/* int spinodal; */
		/* double tk, xb1, xb2; */
		/* int input_case; */
		/* double p[4]; */
	}
	*dd = d;
	*ii = i;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mpi_unpack_surface(struct surface *surface_ptr, int *ints, int *ii, double *doubles, int *dd)
/* ---------------------------------------------------------------------- */
{
	int i, d, j;
	i = *ii;
	d = *dd;
	/* int n_user; */
	surface_ptr->n_user = ints[i];
	/* int n_user_end; */
	surface_ptr->n_user_end = ints[i++];
	/* int new_def; */
	/* surface_ptr->new_def = FALSE; */ /* surface assemblage may be new at receiving processor */
	/* int diffuse_layer; */
	/* int edl; */
	/* int only_counter_ions; */
	/* double thickness; */
	/* char *description; */
	/* int solution_equilibria; */
	/* int n_solution; */
	/* int count_comps; */
	surface_ptr->count_comps = ints[i++];
	/* struct surface_comp *comps; */
	for (j = 0; j < surface_ptr->count_comps; j++) {
		/* char *formula; */
		/* LDBLE moles; */
		/* struct master *master; */
		/* struct elt_list *totals; */
		mpi_unpack_elt_list(&(surface_ptr->comps[j].totals), ints, &i, doubles, &d);
		/* LDBLE la; */
		surface_ptr->comps[j].la = doubles[d++];
		/* int charge; */
		surface_ptr->comps[j].charge = ints[i++];
		/* LDBLE cb; */
		surface_ptr->comps[j].cb = doubles[d++];
		/* char *phase_name; */
		/* double phase_proportion; */
		/* char *rate_name; */
	}
	if (surface_ptr->edl == TRUE) {
		/* int count_charge; */
		surface_ptr->count_charge = ints[i++];
		/* struct surface_charge *charge; */
		for (j = 0; j < surface_ptr->count_charge; j++) {
			/* char *name; */
			/* double specific_area; */
			/* LDBLE grams; */
			surface_ptr->charge[j].grams = doubles[d++];
			/* LDBLE charge_balance; */
			surface_ptr->charge[j].charge_balance = doubles[d++];
			/* LDBLE mass_water; */
			surface_ptr->charge[j].mass_water = doubles[d++];
			/* struct elt_list *diffuse_layer_totals; */
			mpi_unpack_elt_list(&(surface_ptr->charge[j].diffuse_layer_totals), ints, &i, doubles, &d);
			/* int count_g; */
			/* struct surface_diff_layer *g; */  /* stores g and dg/dXd for each ionic charge */
			/* struct master *psi_master; */
			/* LDBLE la_psi; */
			surface_ptr->charge[j].la_psi = doubles[d++];
		}
		/* int related_phases; */
		/* int related_rate; */
	}
	*dd = d;
	*ii = i;
	return(OK);
}
#endif


void ON_ERROR_CLEANUP_AND_EXIT(void)
{
	int errors;
/*
 *   Prepare error handling
 */
	errors = setjmp(mark);
	if (errors != 0) {
		clean_up();
		exit(1);
	}
	return;
}
