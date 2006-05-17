#define EXTERNAL extern
#define MAIN
#include <fstream>
#include <iostream>     // std::cout std::cerr
#include "StorageBin.h"
#include "phreeqc/global.h"
#include "phreeqc/output.h"
#include "hst.h"
#include "phreeqc/phqalloc.h"
#include "phreeqc/phrqproto.h"
#include "phreeqc/input.h"
#include "phast_files.h"
#include "phastproto.h"
#include "Dictionary.h"

static void BeginTimeStep(int print_sel, int print_out, int print_hdf);
static void EndTimeStep(int print_sel, int print_out, int print_hdf);
static void BeginCell(int print_sel, int print_out, int print_hdf, int index);
static void EndCell(int print_sel, int print_out, int print_hdf, int index);

static char const svnid[] = "$Id: hst.c 827 2006-03-06 20:19:41Z dlpark $";
#define RANDOM
#define REBALANCE
/* #define USE_MPI set in makefile */
#ifdef USE_MPI
static int mpi_write_restart(double time_hst);
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
			 double *rebalance_fraction_hst,
			 int *print_restart);
#endif  /* #ifdef USE_MPI */
cxxStorageBin uzBin;
cxxStorageBin szBin;
cxxStorageBin phreeqcBin;
std::map<std::string, int> FileMap;
cxxDictionary dictionary;

#if !defined(LAHEY_F95) && !defined(_WIN32) || defined(NO_UNDERSCORES)
#define CALCULATE_WELL_PH calculate_well_ph
#define COLLECT_FROM_NONROOT collect_from_nonroot
#define COUNT_ALL_COMPONENTS count_all_components
#define CONVERT_TO_MOLAL convert_to_molal
#define CONVERT_TO_MASS_FRACTION convert_to_mass_fraction
#define DISTRIBUTE_INITIAL_CONDITIONS distribute_initial_conditions
#define EQUILIBRATE equilibrate
#define ERRPRT_C errprt_c
#define FORWARD_AND_BACK forward_and_back
#define LOGPRT_C logprt_c
#define ON_ERROR_CLEANUP_AND_EXIT on_error_cleanup_and_exit
#define PACK_FOR_HST pack_for_hst
#define PHREEQC_FREE phreeqc_free
#define PHREEQC_MAIN phreeqc_main
#define SEND_RESTART_NAME send_restart_name
#define SETUP_BOUNDARY_CONDITIONS setup_boundary_conditions
#define WARNPRT_C warnprt_c
#define UZ_INIT uz_init
#else
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
#define SEND_RESTART_NAME send_restart_name_
#define SETUP_BOUNDARY_CONDITIONS setup_boundary_conditions_
#define WARNPRT_C warnprt_c_
#define UZ_INIT uz_init_
#endif
extern "C" { 
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
		 double *rebalance_fraction_hst,
	         int *print_restart);
/*  #endif                                                                             */
void ERRPRT_C(char *err_str, long l);
void FORWARD_AND_BACK(int *initial_conditions, int *axes, int *nx, int *ny, int *nz);
void LOGPRT_C(char *err_str, long l);
void ON_ERROR_CLEANUP_AND_EXIT(void);
void PACK_FOR_HST(double *fraction, int *dim);
void PHREEQC_FREE(int *solute);
void PHREEQC_MAIN(int *solute, char *chemistry_name, char *database_name, char *prefix,
		  int *mpi_tasks_fort, int *mpi_myself_fort, int chemistry_l, int database_l, int prefix_l);
void SEND_RESTART_NAME(char *name, int nchar);
void SETUP_BOUNDARY_CONDITIONS(const int *n_boundary, int *boundary_solution1,
			       int *boundary_solution2, double *fraction1,
			       double *boundary_fraction, int *dim);
int UZ_INIT(int * transient_fresur);
void WARNPRT_C(char *err_str, long l);
int n_to_ijk(int n_cell, int *i, int *j, int *k);
}
/* ---------------------------------------------------------------------- */
void PHREEQC_FREE(int *solute)
/* ---------------------------------------------------------------------- */
/*
 *   free space
 */
{
	//int i;
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
#ifdef REPLACED
	for (i = 0; i < count_chem; i++) {
		system_free(sz[i]);
		free_check_null(sz[i]);
	}
	free_check_null(sz);	
#endif
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
#ifdef REPLACED
		if (uz != NULL) {
			for (i = 0; i < count_chem; i++) {
				system_free(uz[i]);
				free_check_null(uz[i]);
			}
			free_check_null(uz);
		}
#endif
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
	input_file_name[0] = '\0';
	output_file_name[0] = '\0';
	database_file_name[0] = '\0';
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

	/* Open error (screen) file */
	if (output_open(OUTPUT_ERROR, "Dummy") != OK) exit(4);

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
	open_echo(prefix, mpi_myself);
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
	if (*solute == FALSE) {
		return/*(0)*/;
	}
	/*
	 *   Open input files
	 */
	errors = open_input_files_phast(chemistry_name, database_name, &db_cookie, &input_cookie);
	if (errors != 0) {
		clean_up();
		exit(1);
		/*return errors;*/
	}
	if (mpi_myself == 0) {
		output_msg(OUTPUT_ECHO, "Output file:    %s\n", output_file_name);
		output_msg(OUTPUT_ECHO, "Chemistry file: %s\n", input_file_name);
		output_msg(OUTPUT_ECHO, "Database file:  %s\n\n", database_file_name);
		output_msg(OUTPUT_MESSAGE, "Output file:    %s\n", output_file_name);
		output_msg(OUTPUT_MESSAGE, "Chemistry file: %s\n", input_file_name);
		output_msg(OUTPUT_MESSAGE, "Database file:  %s\n\n", database_file_name);
	}
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
	if (buffer == NULL) malloc_error();
	buffer_dbg = buffer;
	buffer[0].name = string_hsave("H");
	if (s_h2 != NULL) {
		buffer[0].gfw = s_h2->secondary->elt->primary->elt->gfw;
	} else {
		buffer[0].gfw = 1.;
	}
	buffer[0].master = s_eminus->primary;
	buffer[1].name = string_hsave("O");
	if (s_o2 != NULL) {
		buffer[1].gfw = s_o2->secondary->elt->primary->elt->gfw;
	} else {
		buffer[1].gfw = 16.;
	}
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
		if (s_h2 != NULL) {
			buffer[j].gfw = s_h2->secondary->elt->primary->elt->gfw;
		} else {
			buffer[j].gfw = 1.0;
		}
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
	if (activity_list == NULL) malloc_error();
	activity_list_dbg = activity_list;

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
/*
 *   Realloc space for totals and activities for all solutions to make
 *   enough room during hst simulation, put array in standard form
 */

	for (i = 0; i < count_solution; i++) {
		xsolution_zero();
		add_solution(solution[i], 1.0/solution[i]->mass_water, 1.0);
		solution[i]->totals = (struct conc *) PHRQ_realloc (solution[i]->totals, (size_t) (count_total - 1) * sizeof(struct conc));
		if (solution[i]->totals == NULL) malloc_error();
		solution[i]->master_activity = (struct master_activity *) PHRQ_realloc (solution[i]->master_activity, (size_t) (count_activity_list + 1) * sizeof(struct master_activity));
		if (solution[i]->master_activity == NULL) malloc_error();
		solution[i]->count_master_activity = count_activity_list;
		/*solution[i]->species_gamma = PHRQ_realloc (solution[i]->species_gamma, (size_t) (count_activity_list + 1) * sizeof(struct master_activity));
		if (solution[i]->species_gamma == NULL) malloc_error();*/
		solution[i]->species_gamma = NULL;
		solution[i]->count_species_gamma = 0;

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
	/*
	 *  set up C++ storage
	 */

	phreeqcBin.import_phreeqc();
	dictionary.add_phreeqc();
	/*
	fprintf(stderr, "Size of dictionary %d\n", dictionary.size());
	for (i = 0; i < 10; i++) {
		std::cerr << *dictionary.int2string(i) << std::endl;
	}
	*/
	//std::ostringstream oss;
	//phreeqcBin.dump_raw(oss,0);
	//std::cerr << oss.str();
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
	struct system *system_ptr;
	int j, k;
	/*
	 *  Save pointers to initial condition arrays
	 *  When rebalancing, these are used to initialize a system
	 */
	initial1 = initial_conditions1;
	initial2 = initial_conditions2;
	frac1 = (double *) PHRQ_malloc((size_t) 7*ixyz * sizeof(double));
	if (frac1 == NULL) malloc_error();
	for (j = 0; j < 7*ixyz; j++) {
		frac1[j] = fraction1[j];
	}
	/*
	 *  Set up random list for parallel processing
	 */
	random_list = (int *) PHRQ_malloc((size_t) count_chem * sizeof(int));
	if (random_list == NULL) malloc_error();
	random_frac = (LDBLE *) PHRQ_malloc((size_t) count_chem * sizeof(LDBLE));
	if (random_frac == NULL) malloc_error();
	random_printzone_chem = (int *) PHRQ_malloc((size_t) count_chem * sizeof(int));
	if (random_printzone_chem == NULL) malloc_error();
	random_printzone_xyz = (int *) PHRQ_malloc((size_t) count_chem * sizeof(int));
	if (random_printzone_xyz == NULL) malloc_error();
	if (mpi_myself == 0) mpi_set_random();
	MPI_Bcast(random_list, count_chem,                MPI_INT,    0, MPI_COMM_WORLD);
	count_cells = count_chem;
	mpi_set_subcolumn(NULL);
	mpi_buffer = PHRQ_malloc(sizeof(char));
	if (mpi_buffer == NULL) malloc_error();
	/* 
	 * sort_random_list is the list of cell numbers that need to be saved for this processor
	 */
	first_cell = mpi_first_cell;
	last_cell = mpi_last_cell;
	sort_random_list = (int *) PHRQ_malloc((size_t) (last_cell - first_cell + 1) * sizeof(int));
	if (sort_random_list == NULL) malloc_error();
	memcpy(sort_random_list, &random_list[first_cell], (size_t) (last_cell - first_cell + 1) * sizeof(int));
	qsort (sort_random_list, (size_t) (last_cell - first_cell + 1), (size_t) sizeof(int), int_compare);

/*
 *  Copy solution, exchange, surface, gas phase, kinetics, solid solution for each active cell.
 */
	for (k = 0; k < last_cell - first_cell + 1; k++) {
		j = sort_random_list[k];  /* j is count_chem number */
		i = back[j].list[0];      /* i is ixyz number */
		assert (forward[i] >= 0); 
		//system_ptr = system_initialize(i, j, initial1, initial2, frac1);   
		system_ptr = system_cxxInitialize(i, j, initial_conditions1, initial_conditions2, fraction1);   
		/* C++ */
		szBin.add(system_ptr);
		system_free(system_ptr);
		system_ptr = (struct system *) free_check_null(system_ptr);
	}
	/*
	 * Read any restart files
	 */
	for (std::map<std::string, int>::iterator it = FileMap.begin(); it != FileMap.end(); it++) {
		int ifile = -100 - it->second;
		// Storage bin
		cxxStorageBin tempBin;
		// parser
		std::fstream myfile;
		myfile.open(it->first.c_str(), std::ios_base::in);
		if (!myfile.is_open()) {
			sprintf(error_string, "File could not be opened: %s.", it->first.c_str());
			error_msg(error_string, STOP);
		}
		std::ostringstream oss;
		CParser cparser(myfile, oss, std::cerr);
		// read data
		tempBin.read_raw(cparser);
		// solutions
		std::vector<int> warn;
		std::string entity_type[7] = {"Solutions", "PPassemblages", "Exchangers", "Surfaces", "GasPhase", "SSassemblages", "Kinetics"};
		warn.reserve(7);
		for (i = 0; i < 7; i++) {
			warn[i] = 0;
		}
		for (k = 0; k < last_cell - first_cell + 1; k++) {
			int n_old1;
			j = sort_random_list[k];  /* j is count_chem number */
			i = back[j].list[0];      /* i is ixyz number */
			assert (forward[i] >= 0); 
			system_ptr = system_initialize(i, j, initial1, initial2, frac1);   
			/* C++ */
			szBin.add(system_ptr);
			system_free(system_ptr);
			system_ptr = (struct system *) free_check_null(system_ptr);
			if (j < 0) continue;
			/*
			 *   Copy solution
			 */
			n_old1 = initial_conditions1[7*i];
			if (n_old1 == ifile) {
				if (tempBin.getSolution(j) != NULL) {
					szBin.setSolution(j, tempBin.getSolution(j));
				} else {
					input_error++;
					sprintf(error_string, "Solution %d not found in restart file %s", j, it->first.c_str());
					error_msg(error_string, CONTINUE);
				}
			}
			/*
			 *   Copy pp_assemblage
			 */
			n_old1 = initial_conditions1[ 7*i + 1 ];
			if (n_old1 == ifile) {
				if (tempBin.getPPassemblage(j) != NULL) {
					szBin.setPPassemblage(j, tempBin.getPPassemblage(j));
				} else {
					warn[1]++;
					//error_msg("PPassemblage %d not found in restart file %s", j, it->first.c_str());
				}
			}
			/*
			 *   Copy exchange assemblage
			 */
			n_old1 = initial_conditions1[ 7*i + 2 ];
			if (n_old1 == ifile) {
				if (tempBin.getExchange(j) != NULL) {
					szBin.setExchange(j, tempBin.getExchange(j));
				} else {
					warn[2]++;
					//error_msg("Exchange %d not found in restart file %s", j, it->first.c_str());
				}
			}
			/*
			 *   Copy surface assemblage
			 */
			n_old1 = initial_conditions1[ 7*i + 3 ];
			if (n_old1 == ifile) {
				if (tempBin.getSurface(j) != NULL) {
					szBin.setSurface(j, tempBin.getSurface(j));
				} else {
					warn[3]++;
					//error_msg("Surface %d not found in restart file %s", j, it->first.c_str());
				}
			}
			/*
			 *   Copy gas phase
			 */
			n_old1 = initial_conditions1[ 7*i + 4 ];
			if (n_old1 == ifile) {
				if (tempBin.getGasPhase(j) != NULL) {
					szBin.setGasPhase(j, tempBin.getGasPhase(j));
				} else {
					warn[4]++;
					//error_msg("GasPhase %d not found in restart file %s", j, it->first.c_str());
				}
			}
			/*
			 *   Copy solid solution
			 */
			n_old1 = initial_conditions1[ 7*i + 5 ];
			if (n_old1 == ifile) {
				if (tempBin.getSSassemblage(j) != NULL) {
					szBin.setSSassemblage(j, tempBin.getSSassemblage(j));
				} else {
					warn[5]++;
					//error_msg("SSassemblage %d not found in restart file %s", j, it->first.c_str());
				}
			}
			/*
			 *   Copy kinetics
			 */
			n_old1 = initial_conditions1[ 7*i + 6 ];
			if (n_old1 == ifile) {
				if (tempBin.getKinetics(j) != NULL) {
					szBin.setKinetics(j, tempBin.getKinetics(j));
				} else {
					warn[6]++;
					//error_msg("Kinetics %d not found in restart file %s", j, it->first.c_str());
				}
			}
		}
		for (i = 1; i < 7; i++) {
			if (warn[i] > 0) {
				std::ostringstream os;
				os << "Reading file " << it->first << ":" << std::endl;
				for (j = 1; j < 7; j++) {
					if (warn[j] == 0) continue;
					os << "\t" << warn[j] << " " << entity_type[j] << " were not found for cells defined by restart file." << std::endl;
				}
				std::string token = os.str();
				warning_msg(token.c_str());
				break;
			}
		}
	}
	sort_random_list = (int *) free_check_null(sort_random_list);
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
	int i, j;
	struct system *system_ptr;
/*
 *  Copy solution, exchange, surface, gas phase, kinetics, solid solution for each active cell.
 */
	for (i = 0; i < ixyz; i++) { 	  /* i is ixyz number */
		j = forward[i];           /* j is count_chem number */
		if (j < 0) continue;
		assert (forward[i] >= 0); 
		//system_ptr = system_initialize(i, j, initial_conditions1, initial_conditions2, fraction1);   
		system_ptr = system_cxxInitialize(i, j, initial_conditions1, initial_conditions2, fraction1);   
		/* C++ */
		szBin.add(system_ptr);
		system_free(system_ptr);
		system_ptr = (struct system *) free_check_null(system_ptr);
	}
	//std::ostringstream oss;
	//szBin.dump_raw(oss,0);
	//std::cerr << oss.str();
	/*
	 * Read any restart files
	 */
	for (std::map<std::string, int>::iterator it = FileMap.begin(); it != FileMap.end(); it++) {
		int ifile = -100 - it->second;
		// Storage bin
		cxxStorageBin tempBin;
		// parser
		std::fstream myfile;
		myfile.open(it->first.c_str(), std::ios_base::in);
		if (!myfile.is_open()) {
			sprintf(error_string, "File could not be opened: %s.", it->first.c_str());
			error_msg(error_string, STOP);
		}
		std::ostringstream oss;
		CParser cparser(myfile, oss, std::cerr);
		// read data
		tempBin.read_raw(cparser);
		//std::ostringstream oss1;
		//tempBin.dump_raw(oss1, 0);
		//std::cerr << oss1.str();
		// put data into szBin
		// solutions
		std::string entity_type[7] = {"Solutions", "PPassemblages", "Exchangers", "Surfaces", "GasPhase", "SSassemblages", "Kinetics"};
		std::vector<int> warn;
		warn.reserve(7);
		for (i = 0; i < 7; i++) {
			warn[i] = 0;
		}
		//fprintf(stderr, "%d\n", warn[0]);
		for (i = 0; i < ixyz; i++) { 	  /* i is ixyz number */
			int n_old1;
			j = forward[i];           /* j is count_chem number */
			if (j < 0) continue;
			/*
			 *   Copy solution
			 */
			n_old1 = initial_conditions1[7*i];
			if (n_old1 == ifile) {
				if (tempBin.getSolution(j) != NULL) {
					szBin.setSolution(j, tempBin.getSolution(j));
				} else {
					input_error++;
					sprintf(error_string, "Solution %d not found in restart file %s", j, it->first.c_str());
					error_msg(error_string, CONTINUE);
				}
			}
			/*
			 *   Copy pp_assemblage
			 */
			n_old1 = initial_conditions1[ 7*i + 1 ];
			if (n_old1 == ifile) {
				if (tempBin.getPPassemblage(j) != NULL) {
					szBin.setPPassemblage(j, tempBin.getPPassemblage(j));
				} else {
					warn[1]++;
					//error_msg("PPassemblage %d not found in restart file %s", j, it->first.c_str());
				}
			}
			/*
			 *   Copy exchange assemblage
			 */
			n_old1 = initial_conditions1[ 7*i + 2 ];
			if (n_old1 == ifile) {
				if (tempBin.getExchange(j) != NULL) {
					szBin.setExchange(j, tempBin.getExchange(j));
				} else {
					warn[2]++;
					//error_msg("Exchange %d not found in restart file %s", j, it->first.c_str());
				}
			}
			/*
			 *   Copy surface assemblage
			 */
			n_old1 = initial_conditions1[ 7*i + 3 ];
			if (n_old1 == ifile) {
				if (tempBin.getSurface(j) != NULL) {
					szBin.setSurface(j, tempBin.getSurface(j));
				} else {
					warn[3]++;
					//error_msg("Surface %d not found in restart file %s", j, it->first.c_str());
				}
			}
			/*
			 *   Copy gas phase
			 */
			n_old1 = initial_conditions1[ 7*i + 4 ];
			if (n_old1 == ifile) {
				if (tempBin.getGasPhase(j) != NULL) {
					szBin.setGasPhase(j, tempBin.getGasPhase(j));
				} else {
					warn[4]++;
					//error_msg("GasPhase %d not found in restart file %s", j, it->first.c_str());
				}
			}
			/*
			 *   Copy solid solution
			 */
			n_old1 = initial_conditions1[ 7*i + 5 ];
			if (n_old1 == ifile) {
				if (tempBin.getSSassemblage(j) != NULL) {
					szBin.setSSassemblage(j, tempBin.getSSassemblage(j));
				} else {
					warn[5]++;
					//error_msg("SSassemblage %d not found in restart file %s", j, it->first.c_str());
				}
			}
			/*
			 *   Copy kinetics
			 */
			n_old1 = initial_conditions1[ 7*i + 6 ];
			if (n_old1 == ifile) {
				if (tempBin.getKinetics(j) != NULL) {
					szBin.setKinetics(j, tempBin.getKinetics(j));
				} else {
					warn[6]++;
					//error_msg("Kinetics %d not found in restart file %s", j, it->first.c_str());
				}
			}
		}
		for (i = 1; i < 7; i++) {
			if (warn[i] > 0) {
				std::ostringstream os;
				os << "Reading file " << it->first << ":" << std::endl;
				for (j = 1; j < 7; j++) {
					if (warn[j] == 0) continue;
					os << "\t" << warn[j] << " " << entity_type[j] << " were not found for cells defined by restart file." << std::endl;
				}
				std::string token = os.str();
				warning_msg(token.c_str());
				break;
			}
		}
	}
	if (input_error > 0) {
		error_msg("Terminating in distribute_initial_conditions.\n", STOP);
	}
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
	double f1, f2;

	for (i = 0; i < *n_boundary; i++) {
		cxxMix mixmap;
		n_old1 = boundary_solution1[i];
		n_old2 = boundary_solution2[i];
		f1 = fraction1[i];
		f2 = 1 - f1;
		mixmap.add(n_old1, f1);
		if (f2 > 0.0) {
			mixmap.add(n_old2, f2);
		}
		cxxSolution *cxxsoln_ptr = phreeqcBin.mix_cxxSolutions(mixmap);
		if (cxxsoln_ptr == NULL) {
			input_error++;
			error_msg("Solution not found for boundary condition.", CONTINUE);
		}
		cxxsolution_to_buffer(cxxsoln_ptr);
		buffer_to_mass_fraction();
		buffer_to_hst(&boundary_fraction[i], *dim);
		delete cxxsoln_ptr;
	}
	return;
}
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
	cxxSolution *cxxsoln_ptr;
	for (i = 0; i < count_chem; i++) {
		cxxsoln_ptr = szBin.getSolution(i);
		cxxsolution_to_buffer(cxxsoln_ptr);
		buffer_to_mass_fraction();
		for (j = 0; j < count_back_list; j++) {
			buffer_to_hst(&fraction[back[i].list[j]], *dim);
		}
	}
	return;
}
#ifndef USE_MPI
/* ---------------------------------------------------------------------- */
static void EQUILIBRATE_SERIAL(double *fraction, int *dim, int *print_sel,
			       double *x_hst, double *y_hst, double *z_hst,
			       double *time_hst, double *time_step_hst, int *prslm, double *cnvtmi,
			       double *frac, 
			       int *printzone_chem,  int *printzone_xyz,
			       int *print_out, int *print_hdf,
			       double *rebalance_fraction_hst,
			       int *print_restart)
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
	unpackcxx_from_hst(fraction, dim);
/*
 *   Calculate equilibrium
 */
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
	// free all c structures
	reinitialize();
	for (i = 0; i < count_chem; i++) {     /* i is count_chem number */
		j = back[i].list[0];           /* j is nxyz number */
		/*
		if (*time_hst > 0) {
			  std::ostringstream oss;
			  cxxSolution *cxxsoln_ptr = szBin.getSolution(i);
			  cxxsoln_ptr->dump_raw(oss,0);
			  std::cerr << oss.str();
		}
		*/
		if (transient_free_surface == TRUE) partition_uz(i, j, frac[j]); 
		if (frac[j] < 1e-10) frac[j] = 0.0;
		// set flags
		active = FALSE;
		if ( frac[j] > 0.0) active = TRUE;
		pr.all = FALSE;
		if (*print_out == TRUE && printzone_chem[j] == TRUE) pr.all = TRUE;
		pr.punch = FALSE;
		if (*print_sel == TRUE && printzone_xyz[j] == TRUE && punch.in == TRUE) pr.punch = TRUE;

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
			//if (transient_free_surface == TRUE) scale_solution(n_solution, frac[j]); 
			//if (transient_free_surface == TRUE) scale_cxxsolution(i, frac[j]); 
			if (transient_free_surface == TRUE) scale_cxxsystem(i, 1.0/frac[j]);
			/*
			  std::ostringstream oss;
			  cxxSolution *cxxsoln_ptr = szBin.getSolution(i);
			  cxxsoln_ptr->dump_raw(oss,0);
			  std::cerr << oss.str();
			*/
			// copy cxx data to c structures
			szBin.cxxStorageBin2phreeqc(i);
			set_use_hst(i);
			n_user = i;
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
			/*
			 *   Save data
			 */
			solution_bsearch(i, &n_solution, TRUE);
			if (n_solution == -999) {
				error_msg("How did this happen?", STOP);
			}
			xsolution_save_hst(n_solution);
			if (save.exchange == TRUE) {
				exchange_bsearch(i, &n_exchange);
				xexchange_save_hst(n_exchange);
			}
			if (save.gas_phase == TRUE) {
				gas_phase_bsearch(i, &n_gas_phase);
				xgas_save_hst(n_gas_phase);
			}
			if (save.pp_assemblage == TRUE) {
				pp_assemblage_bsearch(i, &n_pp_assemblage);
				xpp_assemblage_save_hst(n_pp_assemblage);
			}
			if (save.surface == TRUE) {
				surface_bsearch(i, &n_surface);
				xsurface_save_hst(n_surface);
			}
			if (save.s_s_assemblage == TRUE) {
				s_s_assemblage_bsearch(i, &n_s_s_assemblage);
				xs_s_assemblage_save_hst(n_s_s_assemblage);
			}
			szBin.phreeqc2cxxStorageBin(i);
			if (active && transient_free_surface == TRUE) scale_cxxsystem(i, frac[j]);
		} else {
				if (pr.all == TRUE ) {
					output_msg(OUTPUT_MESSAGE, "Time %g. Cell %d: x=%15g\ty=%15g\tz=%15g\n", (*time_hst) * (*cnvtmi), j + 1, x_hst[j], y_hst[j], z_hst[j]);
					output_msg(OUTPUT_MESSAGE, "Cell is dry.\n");
				}
		}
		// free phreeqc structures
		reinitialize();
		EndCell(*print_sel, *print_out, *print_hdf, j);
	}
	/*
	 *  Write restart data
	 */
	if (*print_restart == 1) write_restart((*time_hst) * (*cnvtmi));

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
                 double *rebalance_fraction_hst,
		 int *print_restart)
/* ---------------------------------------------------------------------- */
{
#ifndef USE_MPI
  if (!(*stop_msg == 1)) {
    EQUILIBRATE_SERIAL(fraction, dim, print_sel,
		       x_hst, y_hst, z_hst,
		       time_hst, time_step_hst, prslm, cnvtmi,
		       frac, printzone_chem, printzone_xyz, print_out, print_hdf,
		       rebalance_fraction_hst,
		       print_restart);
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
		random_list = (int *) free_check_null(random_list);
		return;
	}
	/*
	 *  Initialize on first call to equilibrate
	 */
	if (call_counter == 0) {
		wait_time = 0;
		wait_time_tot = 0;
		mpi_max_buffer = 1;
	}
	call_counter++;
	rebalance_fraction = *rebalance_fraction_hst;
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
			     frac, printzone_chem, printzone_xyz, 
			     print_out, print_hdf, print_restart);
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
	sort_random_list = (int *) PHRQ_malloc((size_t) (last_cell - first_cell + 1) * sizeof(int));
	if (sort_random_list == NULL) malloc_error();
	memcpy(sort_random_list, &random_list[first_cell], (size_t) (last_cell - first_cell + 1) * sizeof(int));
	qsort (sort_random_list, (size_t) (last_cell - first_cell + 1), (size_t) sizeof(int), int_compare);
	/*
	 *  Run chemistry for cells
	 */
	// free all c structures
	reinitialize();
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
			//copy_system_to_user(sz[i], first_user_number);
			cell_no = i;
			//solution_bsearch(first_user_number, &first_solution, TRUE);
			//n_solution = first_solution;
			/*if (*adjust_water_rock_ratio) scale_solution(n_solution, frac[j]); */
			//if (transient_free_surface == TRUE) scale_cxxsolution(i, frac[j]); 
			if (transient_free_surface == TRUE) scale_cxxsystem(i, 1.0/frac[j]);
			szBin.cxxStorageBin2phreeqc(i);
			set_use_hst(i);
			//n_user = solution[n_solution]->n_user;
			n_user = i;
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
			solution_bsearch(i, &n_solution, TRUE);
			if (n_solution == -999) {
				error_msg("How did this happen?", STOP);
			}
			xsolution_save_hst(n_solution);
			if (save.exchange == TRUE) {
				exchange_bsearch(i, &n_exchange);
				xexchange_save_hst(n_exchange);
			}
			if (save.gas_phase == TRUE) {
				gas_phase_bsearch(i, &n_gas_phase);
				xgas_save_hst(n_gas_phase);
			}
			if (save.pp_assemblage == TRUE) {
				pp_assemblage_bsearch(i, &n_pp_assemblage);
				xpp_assemblage_save_hst(n_pp_assemblage);
			}
			if (save.surface == TRUE) {
				surface_bsearch(i, &n_surface);
				xsurface_save_hst(n_surface);
			}
			if (save.s_s_assemblage == TRUE) {
				s_s_assemblage_bsearch(i, &n_s_s_assemblage);
				xs_s_assemblage_save_hst(n_s_s_assemblage);
			}
			/*
			 * Be careful, scale_solution zeros some arrays
			 * can delete some results from run_reaction
			 */
			/*if (active && *adjust_water_rock_ratio) scale_solution(n_solution, 1.0/frac[j]); */
			//if (active && transient_free_surface == TRUE) scale_solution(n_solution, 1.0/frac[j]);
 			//copy_user_to_system(sz[i], first_user_number, i);
			szBin.phreeqc2cxxStorageBin(i);
			if (active && transient_free_surface == TRUE) scale_cxxsystem(i, frac[j]);
		}
		// free phreeqc structures
		reinitialize();
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
	if (*print_restart == 1) mpi_write_restart((*time_hst) * (*cnvtmi));
	COLLECT_FROM_NONROOT(fraction, dim);
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
	forward = (int *) PHRQ_malloc((size_t) ixyz * sizeof(int));
	if (forward == NULL) malloc_error();
	back = (struct back_list *) PHRQ_malloc((size_t) count_chem * sizeof(struct back_list ));
	if (back == NULL) malloc_error();

/*
 *   xyz domain
 */
	if ((axes[0] == TRUE) && (axes[1] == TRUE) && (axes[2] == TRUE)) {
		count_back_list = 1;
		n = 0;
		for (i = 0; i < ixyz; i++) {
			if (initial_conditions[7*i] >= 0 || initial_conditions[7*i] <= -100) {
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
			if (kk == 0 && (initial_conditions[7*i] >= 0 || initial_conditions[7*i] <= -100)) {
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
			if (jj == 0 && (initial_conditions[7*i] >= 0 || initial_conditions[7*i] <= -100)) {
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
			if (ii == 0 && (initial_conditions[7*i] >= 0 || initial_conditions[7*i] <= -100)) {
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
			if (initial_conditions[i*7] < 0 && initial_conditions[7*i] > -100) {
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
			if (initial_conditions[i*7] < 0 && initial_conditions[7*i] > -100) {
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
			if (initial_conditions[i*7] < 0 && initial_conditions[7*i] > -100) {
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

	e_string = (char *) PHRQ_malloc((size_t) (l+1)*sizeof(char));
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

	e_string = (char *) PHRQ_malloc((size_t) (l+1)*sizeof(char));
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
	e_string = (char *) PHRQ_malloc((size_t) (l+1)*sizeof(char));
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
	int nnew, old;
	int change;
	int error;
	LDBLE max_old, max_new, t;
	int ihst, iphrq; /* ihst is natural number to ixyz; iphrq is 0 to count_chem */
	int icells;
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
				/*end_cells_new[i][1] = (end_cells_new[i][1] + end_cells[i][1])/2;*/
				/*end_cells_new[i][1] = end_cells_new[i][1];*/
				icells = (int) ((end_cells_new[i][1] - end_cells[i][1])*rebalance_fraction);
				/*fprintf(stderr, "i %d, new %d, old %d, rebal_fraction %g, icells %d\n",i, end_cells_new[i][1], end_cells[i][1], rebalance_fraction, icells);*/
				end_cells_new[i][1] = end_cells[i][1] + icells;
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
	 *   Redefine columns
	 */
	nnew = 0;
	old = 0;
	change = 0;
#ifdef TIME
	/* MPI_Barrier(MPI_COMM_WORLD); */
	t0 = (LDBLE) MPI_Wtime();
#endif
	if (transfer == TRUE) {
		for (k = 0; k < count_cells; k++) {
			i = random_list[k];
			iphrq = i;                    /* iphrq is 1 to count_chem */
			ihst = back[i].list[0];       /* ihst is 1 to nxyz */
			while (k > end_cells[old][1]) {
				old++;
			}
			while (k > end_cells_new[nnew][1]) {
				nnew++;
			}

			if (old == nnew) continue;
			change++;
			if (mpi_myself == old) 	{
				szBin.mpi_send(iphrq, nnew);
				if (transient_free_surface) {
					uzBin.mpi_send(iphrq, nnew);
					MPI_Send(&(frac[ihst]), 1, MPI_DOUBLE, nnew, 0, MPI_COMM_WORLD);
				}
				szBin.remove(iphrq);
			}
			if (mpi_myself == nnew)	{
				szBin.mpi_recv(old);
				if (transient_free_surface) {
					uzBin.mpi_recv(old);
					MPI_Status mpi_status;
					MPI_Recv(&(frac[ihst]), 1, MPI_DOUBLE, old, 0, MPI_COMM_WORLD, &mpi_status);
					old_frac[ihst] = frac[ihst];
				}
			}
		}
	}
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
int mpi_set_random(void)
/* ---------------------------------------------------------------------- */
{
	int i, j, n;
	int *temp_random;
	/*
	 *   Generate array random with chemistry cells randomized
	 */
	temp_random = (int *) PHRQ_malloc((size_t) count_chem * sizeof(int));
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
	temp_random = (int *) free_check_null(temp_random);
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
/* ---------------------------------------------------------------------- */
int distribute_from_root(double *fraction, int *dim, int *print_sel,
			 double *time_hst, double *time_step_hst, int *prslm,
			 double *frac, 
			 int *printzone_chem, int *printzone_xyz, 
			 int *print_out, int *print_hdf, int *print_restart)
/* ---------------------------------------------------------------------- */
{
	int task_number;
	int i, j, k, mpi_msg_size;
	int i1, j1, k1;
	MPI_Status mpi_status;

	/*
	 *  Send from root to nodes
	 */
	for (task_number = 1; task_number < mpi_tasks; task_number++) {
		if (mpi_myself == task_number) {
			MPI_Recv(&mpi_msg_size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &mpi_status);
			double *doubles = new double[mpi_msg_size];
			MPI_Recv(doubles, mpi_msg_size, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, &mpi_status);
			int d = 0;
			for (k = end_cells[task_number][0]; k <= end_cells[task_number][1]; k++) {
				for (i = 0; i < count_total; i++) {
					buffer[i].moles = doubles[d++];
				}
				if (transport_charge == TRUE) {
					buffer[i].moles = doubles[d++];
				}
				i = random_list[k];                        /* 1, count_chem */
				buffer_to_cxxsolution(i);
			}
			delete[] doubles;
		}
		if (mpi_myself == 0) {
			std::vector<double> doubles;
			for (k = end_cells[task_number][0]; k <= end_cells[task_number][1]; k++) {
				i = random_list[k];                        /* 1, count_chem */
				j = back[i].list[0];
				hst_to_buffer(&fraction[j], *dim);
				buffer_to_moles();
				for (i = 0; i < count_total; i++) {
					doubles.push_back(buffer[i].moles);
				}
				if (transport_charge == TRUE) {
					doubles.push_back(buffer[i].moles);
				}
			}
			mpi_buffer_position = doubles.size();
			MPI_Send(&mpi_buffer_position, 1, MPI_INT, task_number, 0, MPI_COMM_WORLD);
			MPI_Send(&(doubles.front()), mpi_buffer_position, MPI_DOUBLE, task_number, 0, MPI_COMM_WORLD);
		}
	}
	if (mpi_myself == 0) {
		/* unpack root solutions */
		for (k = end_cells[0][0]; k <= end_cells[0][1]; k++) {
			i = random_list[k];                        /* 1, count_chem */
			j = back[i].list[0];
			hst_to_buffer(&fraction[j], *dim);
			buffer_to_moles();
			//buffer_to_solution(sz[i]->solution);
			buffer_to_cxxsolution(i);
		}
	} 
	/*
	MPI_Bcast(dim, 1,                         MPI_INT,    0, MPI_COMM_WORLD);
	*/
	MPI_Bcast(print_sel, 1,                   MPI_INT,    0, MPI_COMM_WORLD);
	MPI_Bcast(time_hst, 1,                    MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(time_step_hst, 1,               MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(prslm, 1,                       MPI_INT,    0, MPI_COMM_WORLD);
	MPI_Bcast(print_out, 1,                   MPI_INT,    0, MPI_COMM_WORLD);
	MPI_Bcast(print_hdf, 1,                   MPI_INT,    0, MPI_COMM_WORLD);
	MPI_Bcast(print_restart, 1,               MPI_INT,    0, MPI_COMM_WORLD);
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
	MPI_Barrier(MPI_COMM_WORLD);
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
	/*
	 *  Pack messages and send from nodes to root
	 */
	for (task_number = 1; task_number < mpi_tasks; task_number++) {
		if (mpi_myself == task_number) {
			mpi_buffer_position = 0;
			std::vector<double> doubles;
			for (k = end_cells[task_number][0]; k <= end_cells[task_number][1]; k++) {
				i = random_list[k];                    /* i is 1 to count_chem */
				cxxsolution_to_buffer(szBin.getSolution(i));
				for (i = 0; i < count_total; i++) {
					doubles.push_back(buffer[i].moles);
				}
				if (transport_charge == TRUE) {
					doubles.push_back(buffer[i].moles);
				}
			}
			mpi_buffer_position = doubles.size();
			MPI_Send(&task_number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
			MPI_Send(&mpi_buffer_position, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
			MPI_Send(&(doubles.front()), mpi_buffer_position, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
		}
		if (mpi_myself == 0) {
			MPI_Recv(&rank, 1, MPI_INT, MPI_ANY_SOURCE, 0, MPI_COMM_WORLD, &mpi_status);
			MPI_Recv(&mpi_msg_size, 1, MPI_INT, rank, 0, MPI_COMM_WORLD, &mpi_status);
			double *doubles = new double[mpi_msg_size];
			MPI_Recv(doubles, mpi_msg_size, MPI_DOUBLE, rank, 0, MPI_COMM_WORLD, &mpi_status);
			int d = 0;
			for (k = end_cells[rank][0]; k <= end_cells[rank][1]; k++) {
				for (i = 0; i < count_total; i++) {
					buffer[i].moles = doubles[d++];
				}
				if (transport_charge == TRUE) {
					buffer[i].moles = doubles[d++];
				}
				buffer_to_mass_fraction();
				i = random_list[k];
				for (j = 0; j < count_back_list; j++) {
					buffer_to_hst(&fraction[back[i].list[j]], *dim);
				}
			}
			delete[] doubles;
		}
	}
	if (mpi_myself == 0) {
		/* pack solutions from root process */
		for (k = end_cells[0][0]; k <= end_cells[0][1]; k++) {
			i = random_list[k];
			cxxsolution_to_buffer(szBin.getSolution(i));
			buffer_to_mass_fraction();
			for (j = 0; j < count_back_list; j++) {
				buffer_to_hst(&fraction[back[i].list[j]], *dim);
			}
		}
	} 
	MPI_Barrier(MPI_COMM_WORLD);
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
  buffer_to_cxxsolution(n_user);
  cxxSolution *cxxsoln = szBin.getSolution(n_user);
  reinitialize();
  solution[0] = cxxsoln->cxxSolution2solution();
  count_solution++;

  //  solution_duplicate(solution[first_solution]->n_user, n_user);
  //  solution_bsearch(first_user_number, &first_solution, TRUE);
  solution_ptr = solution_bsearch(n_user, &i, FALSE);
  if (solution_ptr == NULL) {
    sprintf(error_string,"Could not find solution %d in calculate_well_ph\n", n_user);
    error_msg(error_string, STOP);
  }
  /*
   * Make enough space
   */
  // solution[i]->totals = (struct conc *) PHRQ_realloc (solution[i]->totals, (size_t) (count_total - 1) * sizeof(struct conc));
  //if (solution[i]->totals == NULL) malloc_error();
  //solution[i]->master_activity = (struct master_activity *) PHRQ_realloc (solution[i]->master_activity, (size_t) (count_activity_list + 1) * sizeof(struct master_activity));
  //solution[i]->count_master_activity = count_activity_list;
  //solution[i]->species_gamma = NULL;
  //solution[i]->count_species_gamma = 0;
  //if (solution[i]->master_activity == NULL) malloc_error();
  /*
   *  Zero out solution
   */
  //for (j = 0; j < count_total - 1; j++) {
  //  solution_ptr->totals[j].moles = 0;
  //}
  /*
   *  copy buffer to solution
   */
  //buffer_to_solution(solution_ptr);
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
	return file_ptr;
}
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
	} else {
		old_frac = NULL;
	}
	
	return(OK);
}
/* ---------------------------------------------------------------------- */
void ON_ERROR_CLEANUP_AND_EXIT(void)
/* ---------------------------------------------------------------------- */
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
/* ---------------------------------------------------------------------- */
void SEND_RESTART_NAME(char * name, int nchar)
/* ---------------------------------------------------------------------- */
{
	int i = FileMap.size();
	name[nchar - 1] = '\0';
	string_trim(name);
	std::string stdstring(name);
	FileMap[stdstring] = i;
}
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
int mpi_write_restart(double time_hst)
/* ---------------------------------------------------------------------- */
{
	std::ofstream ofs_restart;

	std::string temp_name("temp_restart_file");
	string_trim(file_prefix);
	std::string name(file_prefix);
	name.append(".restart");
	std::string backup_name = name;
	backup_name.append(".backup");
	// open file 
	if (mpi_myself == 0) {
		ofs_restart.open(temp_name.c_str());
		// write header
		ofs_restart << "#PHAST restart file" << std::endl;
		time_t now = time(NULL);
		ofs_restart << "#Prefix: " << file_prefix << std::endl;
		ofs_restart << "#Date: " << ctime(&now);
		ofs_restart << "#Current model time: " << time_hst << std::endl;
		ofs_restart << "#nx, ny, nz: " << ix << ", " << iy << ", " << iz << std::endl;
		szBin.dump_raw(ofs_restart, 0);
	}
	//
	// collect and write data from nonroot nodes
	//
	int task_number, rank, mpi_msg_size;
	MPI_Status mpi_status;
	for (task_number = 1; task_number < mpi_tasks; task_number++) {
		if (mpi_myself == task_number) {
			std::ostringstream oss_restart;
			szBin.dump_raw(oss_restart, 0);
			std::string stdstring = oss_restart.str();
			const char *string = stdstring.c_str();
			int string_size = stdstring.size() + 1;
			//const char *string = oss_restart.str().c_str();
			//char * string = string_duplicate(oss_restart.str().c_str());
			//int string_size = strlen(string) + 1;
			//int string_size = oss_restart.str().c_str().size() + 1;
			MPI_Send(&task_number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
			MPI_Send(&string_size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
			MPI_Send((void *)string, string_size, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
			//free_check_null(string);
		}
		if (mpi_myself == 0) {
			MPI_Recv(&rank, 1, MPI_INT, MPI_ANY_SOURCE, 0, MPI_COMM_WORLD, &mpi_status);
			MPI_Recv(&mpi_msg_size, 1, MPI_INT, rank, 0, MPI_COMM_WORLD, &mpi_status);
			if (mpi_max_buffer < mpi_msg_size) {
				mpi_max_buffer = mpi_msg_size + 10;
				mpi_buffer = PHRQ_realloc(mpi_buffer, (size_t) mpi_max_buffer);
			}
			MPI_Recv(mpi_buffer, mpi_msg_size, MPI_CHAR, rank, 0, MPI_COMM_WORLD, &mpi_status);
			ofs_restart << (char *) mpi_buffer;
		}
	}

	// rename files
	if (mpi_myself == 0) {
		file_rename(temp_name.c_str(), name.c_str(), backup_name.c_str());
	}
	MPI_Barrier(MPI_COMM_WORLD);
	return(OK);
}
#endif
