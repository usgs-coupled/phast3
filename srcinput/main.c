#define EXTERNAL
#define MAIN
#include "hstinpt.h"
#include "message.h"

#if defined(__WPHAST__)
#define main not_used
#define static
#endif
static char const svnid[] = "$Id$";

int main(int argc, char *argv[]);

static void initialize(void);
static int process_chem_names(void);
static int process_file_names(int argc, char *argv[]);

/* ----------------------------------------------------------------------
 *   MAIN
 * ---------------------------------------------------------------------- */
int main(int argc, char *argv[])
{
#if defined(_DEBUG) && !defined(__WPHAST__)
	int tmpDbgFlag;

	/*
	* Set the debug-heap flag to keep freed blocks in the
	* heap's linked list - This will allow us to catch any
	* inadvertent use of freed memory
	*/
	tmpDbgFlag = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
	tmpDbgFlag |= _CRTDBG_DELAY_FREE_MEM_DF;
	tmpDbgFlag |= _CRTDBG_LEAK_CHECK_DF;
	tmpDbgFlag |= _CRTDBG_CHECK_ALWAYS_DF;
	_CrtSetDbgFlag(tmpDbgFlag);
#endif
	std_error = stderr;
	error_file = stderr;
	/*
	 *   Add callbacks for error_msg and warning_msg
	 */
	add_message_callback(default_handler, NULL); 
	/*
	 * Initialize
	 */
	output_msg(OUTPUT_STDERR, "Initialize...\n");
	initialize();
/*
 *   Open files
 */
	output_msg(OUTPUT_STDERR, "Process file names...\n");
	process_file_names(argc, argv);
	input_file = transport_file;
/*	fprintf(std_error, "Done process file names...\n"); */
	output_msg(OUTPUT_ECHO, "Running PHASTINPUT.\n\nProcessing flow and transport data file.\n\n");
/*
 *   Use to cause output to be completely unbuffered
 */
	setbuf(echo_file, NULL);
/*	fprintf(std_error, "Done setbuf echo file...\n"); */
	setbuf(hst_file, NULL); 
/*	fprintf(std_error, "Done setbuf hst_file...\n"); */
/*
 *   Read input data for simulation
 */
	input = input_file;
	if (read_input() == EOF) {
		error_msg("No data defined.", STOP);
	}
	/*
	if (flow_only == FALSE && input_error == 0) {
		process_chem_names();
	}
	*/
	check_hst_units();
	check_time_series_data();
	if (input_error == 0) {
		collate_simulation_periods();
		for (simulation=0; simulation < count_simulation_periods; simulation++) {
			if (simulation > 0) write_thru(FALSE);
			current_start_time = simulation_periods[simulation];
			if (simulation < count_simulation_periods - 1) {
				current_end_time = simulation_periods[simulation + 1];
			} else {
				current_end_time = time_end[count_time_end - 1].value*time_end[count_time_end - 1].input_to_user;
			}
			reset_transient_data();
			if (input_error > 0) break;
			output_msg(OUTPUT_STDERR, "Accumulate...\n");
			accumulate();
			if (input_error > 0) break;
			if (simulation == 0) {
				output_msg(OUTPUT_STDERR, "Check properties...\n");
				check_properties();
			}
			output_msg(OUTPUT_STDERR, "Write hst...\n");
			write_hst();
			if (input_error > 0) break;
		}
		write_thru(TRUE);
	}
	/*
	 *  Finish
	 */
	output_msg(OUTPUT_STDERR, "Clean up...\n");
	output_msg(OUTPUT_ECHO, "\nPHASTINPUT done.\n\n");
	clean_up();
	clean_up_message();
	return(input_error);
}
/* ---------------------------------------------------------------------- */
int process_file_names(int argc, char *argv[])
/* ---------------------------------------------------------------------- */
{
	char name[MAX_LENGTH], token[MAX_LENGTH];
	char *ptr;
	FILE *new_file=NULL;
	int l, j;
		
	prefix = NULL;
	transport_name = NULL;
	chemistry_name = NULL;
	database_name = NULL;

	if (argc < 2 || argc > 3) {
		error_msg("Usage: phastinput prefix [database_file]\n", STOP);
	} else {
		for (j = 1; j < argc; j++) {
			switch (j) {
			case 1:
				ptr = argv[j];
				if (copy_token(token, &ptr, &l) != EMPTY) {
					prefix = string_duplicate(argv[j]);
				}
				break;
			case 2:
				ptr = argv[j];
				if (copy_token(token, &ptr, &l) != EMPTY) {
					database_name = string_duplicate(argv[j]);
				}
				break;
			}
		}

	}
/*
 *   get prefix
 */
	if (prefix == NULL) {
		output_msg(OUTPUT_STDERR, "Usage: phastinput prefix [database_file]\n");
		output_msg(OUTPUT_STDERR, "ERROR: Prefix for file names is mandatory.\n");
		error_msg("Terminating", STOP);
	}
/*
 *   open transport file
 */
	if (transport_name == NULL) {
		strcpy(name, prefix);
		strcat(name, ".trans.dat");
		transport_name = string_duplicate(name);
		if ((new_file = fopen(transport_name, "r")) == NULL) {
			sprintf(error_string, "Can't open transport data file, %s.\n", name);
			error_msg(error_string, STOP);
		} else {
 			output_msg(OUTPUT_STDERR, "\tFlow and transport data file: %s\n", transport_name);
			transport_file = new_file;
		}
	}
/*
 *  chemistry file name
 */
	if (chemistry_name == NULL) {
		strcpy(name, prefix);
		strcat(name, ".chem.dat");
		chemistry_name = string_duplicate(name);
	}		
/*
 *   database file name
 */
	if (database_name == NULL) {
		database_name = string_duplicate("phast.dat");
	}		
/*
 *   Open file for echo output
 */
	strcpy(name, prefix);
	strcat(name,".log");
	echo_file = fopen(name, "w");
	if (echo_file == NULL) {
		sprintf(error_string, "Can't open input echo file, %s.", name);
		error_msg(error_string, STOP);
	}
	output_msg(OUTPUT_STDERR, "\tEcho with errors file: %s\n", name);
/*
 *   Open hst file
 */
	strcpy(name, "Phast.tmp");
	if ((hst_file = fopen(name,"w")) == NULL) {
		sprintf(error_string, "Can't open temporary data file, %s.", name);
		error_msg(error_string, STOP);
	}
	return OK;
}
/* ---------------------------------------------------------------------- */
int process_chem_names(void)
/* ---------------------------------------------------------------------- */
{
	FILE *new_file=NULL;
		
/*
 *   open chemistry file
 */
	if ((new_file = fopen(chemistry_name, "r")) == NULL) {
		sprintf(error_string, "Chemistry data file not found, %s.", chemistry_name);
		error_msg(error_string, CONTINUE);
		input_error++;
	} else {
		fclose(new_file);
		output_msg(OUTPUT_STDERR, "\tChemistry data file: %s\n", chemistry_name);
	} 
/*
 *   open database file
 */
	if ((new_file = fopen(database_name, "r")) == NULL) {
		sprintf(error_string, "Database file not found, %s.", database_name);
		error_msg(error_string, CONTINUE);
		input_error++;
	} else {
		output_msg(OUTPUT_STDERR, "\tDatabase file: %s\n", database_name);
		fclose(new_file);
	}
	return OK;
}

/* ---------------------------------------------------------------------- */
int clean_up(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Free all allocated memory, except strings
 */
	int i;

	/* dup_print ("End of flow and transport file.", TRUE); */

/* miscellaneous work space */
	free_check_null(min_ss_time_step.input);
	free_check_null(max_ss_time_step.input);

	free_check_null(title_x);
	free_check_null(line);
	free_check_null(line_save);

	/* Cells */
	for (i = 0; i < count_cells; i++) {
		cell_free(&cells[i]);
	}
	free_check_null(cells);

	/* Grid */
	for (i = 0; i < 3; i++) {
		free_check_null(grid[i].coord);
		free_check_null(grid[i].elt_centroid);
	}
	for (i = 0; i < count_grid_overlay; i++) {
		free_check_null(grid_overlay[i].coord);
		free_check_null(grid_overlay[i].elt_centroid);
	}
	free_check_null(grid_overlay);

	/* Grid_elt_zones */
	for (i = 0; i < count_grid_elt_zones; i++) {
		grid_elt_free(grid_elt_zones[i]);
	}
	free_check_null(grid_elt_zones);

	/* Chem_ic */
	for (i = 0; i < count_chem_ic; i++) {
		chem_ic_free(chem_ic[i]);
		free_check_null(chem_ic[i]);
	}
	free_check_null(chem_ic);

	/* Head_ic */
	for (i = 0; i < count_head_ic; i++) {
		head_ic_free(head_ic[i]);
		free_check_null(head_ic[i]);
	}
	free_check_null(head_ic);

	/* Bc */
	for (i = 0; i < count_bc; i++) {
		bc_free(bc[i]);
		free_check_null(bc[i]);
	}
	free_check_null(bc);

	/* Rivers */
	for (i = 0; i < count_rivers; i++) {
		river_free(&rivers[i]);
	}
	free_check_null(rivers);

	/* Wells */
	for (i = 0; i < count_wells; i++) {
		well_free(&wells[i]);
	}
	free_check_null(wells);

	/* Units */
	free_check_null(units.time.si);
	free_check_null(units.time.input);
	free_check_null(units.horizontal.si);
	free_check_null(units.horizontal.input);
	free_check_null(units.vertical.si);
	free_check_null(units.vertical.input);
	free_check_null(units.head.si);
	free_check_null(units.head.input);
	free_check_null(units.k.si);	
	free_check_null(units.k.input);	
	free_check_null(units.s.si);	
	free_check_null(units.s.input);	
	free_check_null(units.alpha.si);	
	free_check_null(units.alpha.input);	
	free_check_null(units.leaky_k.si);	
	free_check_null(units.leaky_k.input);	
	free_check_null(units.leaky_thick.si);	
	free_check_null(units.leaky_thick.input);	
	free_check_null(units.flux.si);	
	free_check_null(units.flux.input);	
	free_check_null(units.well_diameter.si);	
	free_check_null(units.well_diameter.input);	
	free_check_null(units.well_pumpage.si);	
	free_check_null(units.well_pumpage.input);	
	free_check_null(units.river_bed_k.si);	
	free_check_null(units.river_bed_k.input);	
	free_check_null(units.river_bed_thickness.si);
	free_check_null(units.river_bed_thickness.input);	

	/* time stepping */
	time_series_free(&time_step);
	times_free(time_end, count_time_end);
	free_check_null(time_end);

	time_free(&current_time_step);
	time_free(&current_time_end);

	/* .bcf file */
	time_series_free(&print_bc_flow);
	time_series_free(&print_comp);
	time_series_free(&print_conductances);
	time_series_free(&print_force_chem);
	time_series_free(&print_bc);

	time_free(&current_print_bc_flow);
	time_free(&current_print_comp);
	time_free(&current_print_conductances);
	time_free(&current_print_force_chem);

	/* .bal file */
	time_series_free(&print_flow_balance);
	time_series_free(&print_hdf_chem);
	time_series_free(&print_hdf_head);
	time_series_free(&print_hdf_velocity);
	time_series_free(&print_head);
	time_series_free(&print_statistics);
	time_series_free(&print_velocity);
	time_series_free(&print_wells);
	time_series_free(&print_xyz_chem);
	time_series_free(&print_xyz_comp);
	time_series_free(&print_xyz_head);
	time_series_free(&print_xyz_velocity);
	time_series_free(&print_xyz_wells);

	time_free(&current_print_flow_balance);
	time_free(&current_print_hdf_chem);
	time_free(&current_print_hdf_head);
	time_free(&current_print_hdf_velocity);
	time_free(&current_print_head);
	time_free(&current_print_statistics);
	time_free(&current_print_velocity);
	time_free(&current_print_wells);
	time_free(&current_print_xyz_chem);
	time_free(&current_print_xyz_comp);
	time_free(&current_print_xyz_head);
	time_free(&current_print_xyz_velocity);
	time_free(&current_print_xyz_wells);

	/* print zones */
	print_zone_struct_free(&print_zones_xyz);
	print_zone_struct_free(&print_zones_chem);

	free_check_null(simulation_periods);

	/* file names */
	free_check_null(prefix);
	free_check_null(transport_name);
	free_check_null(chemistry_name);
	free_check_null(database_name);	

/* files */
	if (input != NULL) fclose (input);
	if (echo_file != NULL) fclose (echo_file);
	if (std_error != NULL) fclose (std_error);
	if (hst_file != NULL) fclose (hst_file);

	return(OK);
}
/* ---------------------------------------------------------------------- */
void initialize(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Initialize global variables
 */
	int i;

	max_line = MAX_LENGTH;
/*
 *   Allocate space
 */
	line = (char *) malloc((size_t) max_line * sizeof(char));
	if (line == NULL) malloc_error();
	line_save = (char *) malloc((size_t) max_line * sizeof(char));
	if (line_save == NULL) malloc_error();

	/* Cells */
	count_cells = 0;
	cells = NULL;

/*
 *   Make minimum space for grid
 */
	for(i=0; i < 3; i++) {
		grid[i].coord = (double *) malloc ( (size_t) 2 * sizeof(double));
		if(grid[i].coord == NULL) malloc_error();
		grid[i].count_coord = 0;
		grid[i].uniform = UNDEFINED;	
		grid[i].uniform_expanded = FALSE;
		grid[i].elt_centroid = NULL;
		grid[i].min = 0.0;
		axes[i] = TRUE;
	}
	grid[0].c = 'X';
	grid[1].c = 'Y';
	grid[2].c = 'Z';
	count_grid_overlay = 0;
	grid_overlay = (struct grid *) malloc ( (size_t) 1 * sizeof(struct grid));
	if (grid_overlay == NULL) malloc_error();
	grid_overlay[0].count_coord = 0;
	grid_overlay[0].coord = NULL;
	grid_overlay[0].elt_centroid = NULL;
	snap[0] = .001;
	snap[1] = .001;
	snap[2] = .001;

/*
 *   initialize grid_elt_zones to contain definition
 *   of media properties
 */
	grid_elt_zones = malloc (sizeof(struct grid_elt *));
	if (grid_elt_zones == NULL) malloc_error();
	count_grid_elt_zones = 0;
/*
 *   initialize head_ic 
 */
	head_ic = malloc (sizeof(struct head_ic *));
	if (head_ic == NULL) malloc_error();
	count_head_ic = 0;
/*
 *   initialize chem_ic 
 */
	chem_ic = malloc (sizeof(struct chem_ic *));
	if (chem_ic == NULL) malloc_error();
	count_chem_ic = 0;
/*
 *   initialize bc
 */
	bc = malloc (sizeof(struct bc *));
	if (bc == NULL) malloc_error();
	count_bc = 0;
	count_specified = count_flux = count_leaky = 0;
/*
 *   initialize river
 */
	rivers = (River *) malloc (sizeof(River));
	if (rivers == NULL) malloc_error();
	rivers->count_points = 0;
	rivers->points = NULL;
	count_rivers = 0;
#ifndef PI
	PI = acos(-1);
#endif
/*
 *   wells
 */
	wells = NULL;
	count_wells = 0;

/*
 *   default free surface boundary condition 
 */
	free_surface = FALSE;
/*
 *   default flow_only
 */
	flow_only = FALSE;
/*
 *   default steady_flow
 */
	steady_flow = FALSE;
	eps_head = 1e-5;
	eps_mass_balance = 0.001;
	min_ss_time_step.value_defined = FALSE;
	min_ss_time_step.input = NULL;
	max_ss_time_step.value_defined = FALSE;
	max_ss_time_step.input = NULL;
	max_ss_head_change = -1;
	max_ss_iterations = 100;

	title_x = NULL;
/*
 *   default fluid properties and storage
 */
/*	fluid_compressibility = 4.7e-10; */
	fluid_compressibility = 0; 
	fluid_density = 1000.;
	fluid_viscosity = 0.001;
	fluid_diffusivity = 1e-9;
/*
 *   units
 */
	units.time.si = string_duplicate("s");
	units.time.input = NULL;
	units.time.defined = FALSE;
	units.horizontal.si = string_duplicate("m");
	units.horizontal.input = NULL;
	units.horizontal.defined = FALSE;
	units.vertical.si = string_duplicate("m");
	units.vertical.input = NULL;
	units.vertical.defined = FALSE;
	units.head.si = string_duplicate("m");
	units.head.input = NULL;
	units.head.defined = FALSE;
	units.k.si = string_duplicate("m/s");
	units.k.input = NULL;
	units.k.defined = FALSE;
	units.s.si = string_duplicate("1/m");
	units.s.input = NULL;
	units.s.defined = FALSE;
	units.alpha.si = string_duplicate("m");
	units.alpha.input = NULL;
	units.alpha.defined = FALSE;
	units.leaky_k.si = string_duplicate("m/s");
	units.leaky_k.input = NULL;
	units.leaky_k.defined = FALSE;
	units.leaky_thick.si = string_duplicate("m");
	units.leaky_thick.input = NULL;
	units.leaky_thick.defined = FALSE;
	units.flux.si = string_duplicate("m/s");
	units.flux.input = NULL;
	units.flux.defined = FALSE;
	units.river_bed_k.si = string_duplicate("m/s");
	units.river_bed_k.input = NULL;
	units.river_bed_k.defined = FALSE;
	units.river_bed_thickness.si = string_duplicate("m");
	units.river_bed_thickness.input = NULL;
	units.river_bed_thickness.defined = FALSE;
	units.well_diameter.si = string_duplicate("m");
	units.well_diameter.input = NULL;
	units.well_diameter.defined = FALSE;
	units.well_pumpage.si = string_duplicate("m^3/s");
	units.well_pumpage.input = NULL;
	units.well_pumpage.defined = FALSE;
/*
 *   Solver parameters
 */
	solver_method = ITERATIVE;
	solver_tolerance = 1e-10;
	solver_save_directions = 20;
	solver_maximum = 500;
	solver_space = 0.0;
	solver_time = 1.0;
	cross_dispersion = FALSE;
	rebalance_fraction = 0.5;
/*
 *   print input values set to false, xy true
 */
	print_input_bc = FALSE;
	print_input_comp = FALSE;
	print_input_conductances = FALSE;
	print_input_fluid = TRUE;
	print_input_force_chem = FALSE;
	print_input_hdf_chem = TRUE;
	print_input_hdf_head = TRUE;
	print_input_hdf_ss_vel = TRUE;
	print_input_hdf_ss_vel_defined = FALSE;
	print_input_head = TRUE;
	print_input_media = FALSE;
	print_input_method = TRUE;
	print_input_ss_vel = FALSE;
	print_input_ss_vel_defined = FALSE;
	print_input_wells = TRUE;
	print_input_xyz_chem = FALSE;
	print_input_xyz_comp = FALSE;
	print_input_xyz_head = FALSE;
	print_input_xyz_ss_vel = FALSE;
	print_input_xyz_ss_vel_defined = FALSE;
	print_input_xyz_wells = FALSE;
	print_input_xy = TRUE;
/*
 *   print parameters
 */

	time_series_init(&print_velocity);
	time_series_init(&print_hdf_velocity);
	time_series_init(&print_xyz_velocity);
	time_series_init(&print_head);
	time_series_init(&print_hdf_head);
	time_series_init(&print_xyz_head);
	time_series_init(&print_force_chem);
	time_series_init(&print_hdf_chem);
	time_series_init(&print_xyz_chem);
	time_series_init(&print_comp);
	time_series_init(&print_xyz_comp);
	time_series_init(&print_wells);
	time_series_init(&print_xyz_wells);
	time_series_init(&print_statistics);
	time_series_init(&print_flow_balance);
	time_series_init(&print_bc_flow);
	time_series_init(&print_conductances);
	time_series_init(&print_bc);

	/* print_zones */
	print_zone_struct_init(&print_zones_xyz);
	print_zone_struct_init(&print_zones_chem);

	/* .bcf file */
	current_print_bc_flow.type = UNITS;
	current_print_bc_flow.value = 0;
	current_print_bc_flow.value_defined = FALSE;
	current_print_bc_flow.input = NULL;

	current_print_bc = FALSE;

	current_print_comp.type = UNITS;
	current_print_comp.value = 0;
	current_print_comp.value_defined = FALSE;
	current_print_comp.input = NULL;

	current_print_conductances.type = UNITS;
	current_print_conductances.value = 0;
	current_print_conductances.value_defined = FALSE;
	current_print_conductances.input = NULL;

	current_print_force_chem.type = UNITS;
	current_print_force_chem.value = 0;
	current_print_force_chem.value_defined = FALSE;
	current_print_force_chem.input = NULL;

	/* .bal file */
	current_print_flow_balance.type = UNDEFINED;
	current_print_flow_balance.value_defined = FALSE;
	current_print_flow_balance.input = NULL;

	current_print_hdf_chem.type = UNDEFINED;
	current_print_hdf_chem.value_defined = FALSE;
	current_print_hdf_chem.input = NULL;

	current_print_hdf_head.type = UNDEFINED;
	current_print_hdf_head.value_defined = FALSE;
	current_print_hdf_head.input = NULL;

	current_print_hdf_velocity.type = UNDEFINED;
	current_print_hdf_velocity.value_defined = FALSE;
	current_print_hdf_velocity.input = NULL;

	current_print_head.type = UNDEFINED;
	current_print_head.value_defined = FALSE;
	current_print_head.input = NULL;

	current_print_statistics.type = UNDEFINED;
	current_print_statistics.value_defined = FALSE;
	current_print_statistics.input = NULL;

	save_final_heads = FALSE;

	current_print_velocity.type = UNITS;
	current_print_velocity.value = 0;
	current_print_velocity.value_defined = FALSE;
	current_print_velocity.input = NULL;

	current_print_wells.type = UNDEFINED;
	current_print_wells.value_defined = FALSE;
	current_print_wells.input = NULL;

	current_print_xyz_chem.type = UNITS;
	current_print_xyz_chem.value = 0;
	current_print_xyz_chem.value_defined = FALSE;
	current_print_xyz_chem.input = NULL;

	current_print_xyz_comp.type = UNITS;
	current_print_xyz_comp.value = 0;
	current_print_xyz_comp.value_defined = FALSE;
	current_print_xyz_comp.input = NULL;

	current_print_xyz_head.type = UNITS;
	current_print_xyz_head.value = 0;
	current_print_xyz_head.value_defined = FALSE;
	current_print_xyz_head.input = NULL;

	current_print_xyz_velocity.type = UNITS;
	current_print_xyz_velocity.value = 0;
	current_print_xyz_velocity.value_defined = FALSE;
	current_print_xyz_velocity.input = NULL;

	current_print_xyz_wells.type = UNITS;
	current_print_xyz_wells.value = 0;
	current_print_xyz_wells.value_defined = FALSE;
	current_print_xyz_wells.input = NULL;

	print_zones_xyz.print_zones = (struct print_zones *) malloc(sizeof(struct print_zones));
	if (print_zones_xyz.print_zones == NULL) malloc_error();
	print_zones_xyz.count_print_zones = 0;

	print_zones_chem.print_zones = (struct print_zones *) malloc(sizeof(struct print_zones));
	if (print_zones_chem.print_zones == NULL) malloc_error();
	print_zones_chem.count_print_zones = 0;

	for (i = 0; i < 3; i++) {
		print_zones_xyz.thin_grid_list[i] = NULL;
		print_zones_chem.thin_grid_list[i] = NULL;
	}

	current_time_step.value = 0.0;
	current_time_step.value_defined = FALSE;
	current_time_step.input = NULL;

	current_time_end.value_defined = FALSE;
	current_time_end.input = NULL;

	last_time_end = 0;
 	
 	simulation_periods = NULL;
 	count_simulation_periods = 0;
	head_ic_file_warning = FALSE;
	adjust_water_rock_ratio = TRUE;

	time_step.count_properties = 0;
	time_step.properties = NULL;

	time_end = NULL;
	count_time_end = 0;

	return;
}
