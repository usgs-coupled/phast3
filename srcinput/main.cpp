#ifdef  __cplusplus
extern "C" {
#endif

#define EXTERNAL
//#define MAIN
#include "hstinpt.h"
#undef EXTERNAL
//#undef MAIN 

extern int clean_up(void);
extern void initialize(void);
extern int process_chem_names(void);
extern int process_file_names(int argc, char *argv[]);
extern int reset_transient_data(void);
extern int copy_token (char *token_ptr, char **ptr, int *length);
extern int error_msg (const char *err_str, const int stop);
extern int read_line_doubles(char *next_char, double **d, int *count_d, int *count_alloc);

extern int accumulate(void);
extern int check_properties(void);
extern int read_input(void);
extern int write_hst(void);
extern int write_thru(int thru);

#ifdef  __cplusplus
}
#endif
 
int main(int argc, char *argv[]);

#ifdef  __cplusplus
extern "C" {
#endif

int get_logical_line(FILE *fp, int *l);
int get_line(FILE *fp);
int read_file_doubles(char *next_char, double **d, int *count_d, int *count_alloc);

#ifdef  __cplusplus
}
#endif

#if !defined(__WPHAST__)
#error __WPHAST__ must be set
#endif
#include "Parser.h"
static CParser* g_pParser;
#include <fstream> // std::ifstream
#include <sstream> // std::istringstream

/* ----------------------------------------------------------------------
 *   MAIN
 * ---------------------------------------------------------------------- */
int main(int argc, char *argv[])
/*
 *   Main program for PHREEQC
 */
{
	_CrtSetDbgFlag( _CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
	///_CrtSetBreakAlloc(123);

	std_error = fopen("NUL", "w");
	//std_error = stderr;
	fprintf(std_error, "Initialize...\n");
	initialize();
/*
 *   Open files
 */
	fprintf(std_error, "Process file names...\n");
	process_file_names(argc, argv);
	input_file = transport_file;
	//{{
	//// std::ifstream* p_ifs = new std::ifstream();
	//// p_ifs->open(transport_name);
	//// g_pParser = new CParser(*p_ifs);

	//std::ifstream ifs;
	//ifs.open(transport_name);
	//g_pParser = new CParser(ifs);

	//{{
	std::string str(
"TITLE\n"
".	Well flow Lohman, 1972, p. 19\n"
"FLOW_ONLY	true\n"
"UNITS\n"
"	-time		min\n"
"	-horizontal	ft\n"
"	-vertical	ft\n"
"	-head		ft\n"
"	-hydraulic	ft/day\n"
"	-specific_stor	1/ft\n"
"	-well_diameter	ft\n"
"	-well_flow_rate ft^3/day\n"
"GRID\n"
"	-uniform X \n"
"		0 4000	41\n"
"	-uniform Y\n"
"		0 4000	41\n"
"	-uniform Z \n"
"		-100 0   2\n"
"	-print_orientation XY\n"
"FLUID_PROPERTIES\n"
"	-compress	5e-15   #  fluid compressibility is negligible\n"
"	-viscosity	0.00115\n"
"MEDIA\n"
"	-zone	0 0 -100 4000 4000 0\n"
"		-Kx			137\n"
"		-Ky			137\n"
"		-Kz			137\n"
"		-porosity		.20\n"
"		-specific_storage	2e-6   # storage coef / aq thickness\n"
"FREE_SURFACE_BC	false\n"
"WELL 1\n"
"	2000	2000\n"
"		-diameter	1\n"
"		-pumping_rate 	96000\n"
"		-elevation	0.	-100.\n"
"WELL 2\n"
"	2200	2000\n"
"		-diameter	1\n"
"		-pumping_rate 	0\n"
"		-elevation	0.	-10.\n"
"WELL 3\n"
"	2400	2000\n"
"		-diameter	1\n"
"		-pumping_rate 	0\n"
"		-elevation	0.	-10.\n"
"HEAD_IC\n"
"	-zone	0 0 -100 4000 4000 0\n"
"		-head	0\n"
"SOLUTION_METHOD\n"
"	-iterative_solver\n"
"	-save_directions 10\n"
"	-space	0\n"
"	-time	1\n"
"TIME_CONTROL\n"
"	-time_step	30  sec\n"
"	-time_change	600 sec\n"
"PRINT_FREQUENCY\n"
"	-head	          	600 sec\n"
"	-hdf_head		600 sec\n"
"	-xyz_head		600 sec\n"
"	-hdf_velocity		600 sec\n"
"	-xyz_velocity		600 sec\n"
"	-well			600 sec\n"
"END\n"
);

	std::istringstream iss_in(str);
	g_pParser = new CParser(iss_in);
	//}}

	// g_pParser = new CParser(input_file);
	// g_pParser = new CParser(input_file);
	//}}
/*	fprintf(std_error, "Done process file names...\n"); */
	fprintf(echo_file, "Running PHASTINPUT.\n\nProcessing flow and transport data file.\n\n");
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
	for (simulation=0; ;simulation++) {
		reset_transient_data();
		fprintf(std_error, "Read input...\n");
		if (read_input() == EOF) {
			write_thru(TRUE);
			break;
		} else if (simulation > 0) {
			write_thru(FALSE);
		}
		if (simulation == 0 && flow_only == FALSE && input_error == 0) {
			process_chem_names();
		}
		fprintf(std_error, "Accumulate...\n");
		accumulate();
		fprintf(std_error, "Check properties...\n");
		check_properties();
		fprintf(std_error, "Write hst...\n");
		write_hst();
	}
	fprintf(std_error, "Clean up...\n");
	fprintf(echo_file, "\nPHASTINPUT done.\n\n");
	delete g_pParser;
	clean_up();
	return(0);
}

/* ---------------------------------------------------------------------- */
int get_logical_line(FILE *fp, int *l)
/* ---------------------------------------------------------------------- */
{
	return g_pParser->get_logical_line(fp, l);
}
/* ---------------------------------------------------------------------- */
int get_line(FILE *fp)
/* ---------------------------------------------------------------------- */
{
	return g_pParser->get_line(fp);
}
/* ---------------------------------------------------------------------- */
int read_file_doubles(char *next_char, double **d, int *count_d, int *count_alloc)
/* ---------------------------------------------------------------------- */
{

/*
 *      Reads doubles from a file
 *      next_char contains file name
 *      Appends to d.
 *      Stops at EOF or ERROR
 *
 *      Input Arguments:
 *         next_char    points to file name
 *         d            points to array of doubles, must be malloced
 *         count_d      number of elements in array
 *         count_alloc  number of elements malloced
 *
 *      Output Arguments:
 *         d            points to array of doubles, may have been
 *                          realloced
 *         count_d      updated number of elements in array
 *         count_alloc  updated of elements malloced
 *
 *      Returns:
 *         OK
 *         ERROR if any errors reading doubles
 */	
	int j, l, return_value;
	char token[MAX_LENGTH], name[MAX_LENGTH], property_file_name[MAX_LENGTH];
/*
 *    open file
 */
	return_value = OK;
	j = copy_token(token, &next_char, &l);
	std::ifstream ifs;
	ifs.open(token);
	if (!ifs.is_open()) {
		sprintf(error_string, "Can't open file, %s.", token);
		error_msg(error_string, STOP);
		return(ERROR);
	}
	CParser readDoubles(ifs);
	strcpy(property_file_name, token);
	strcpy(name, prefix);
	strcat(name, ".head.dat");
	if (strcmp(property_file_name, name) == 0) {
		head_ic_file_warning = TRUE;
	}
/*
 *   read doubles
 */
	for(;;) {
		j = readDoubles.get_line(0);
		if (j == EMPTY) {
			continue;
		} else if (j == EOF) {
			break;
		}
		next_char = line;
		if (read_line_doubles(next_char, d, count_d, count_alloc) == ERROR) {
			sprintf(error_string,"Reading from file %s\n%s", token, line) ;
			error_msg(error_string, CONTINUE);
			return_value = ERROR;
		}
	}
	if (*count_d > 0) {
		*d = (double*)realloc(*d, (size_t) *count_d * sizeof(double));
		*count_alloc = *count_d;
	}
	ifs.close();
	return(return_value);
}
