#define EXTERNAL extern
#include "hstinpt.h"
#include "message.h"
#include "stddef.h"
#include "Polyhedron.h"
#include "Cube.h"
#include "Wedge.h"
#include "Prism.h"
#include "XYZfile.h"
#include <sstream>
#include <iostream>
#include "PHAST_Transform.h"
#include "Zone_budget.h"
#if defined(__WPHAST__)
#define STATIC
#else
#define STATIC static
#endif
static char const svnid[] = "$Id$";
STATIC int next_keyword_or_option(const char **opt_list, int count_opt_list);
STATIC int streamify_to_next_keyword_or_option(const char **opt_list,
											   int count_opt_list,
											   std::istringstream & lines);
STATIC int streamify_to_next_keyword_or_option(const char **opt_list, int count_opt_list,
											   std::istringstream & lines,
											   char *start_string, const char *delimiting_string);
STATIC int streamify_prism_piece(const char **opt_list, int count_opt_list,
				std::istringstream & lines);
STATIC int read_chemistry_ic(void);
STATIC Cube *read_cube(char **next_char);
STATIC Wedge *read_wedge(char **next_char);
STATIC int read_flow_only(void);
STATIC int read_flow(void);
STATIC int read_fluid_properties(void);
STATIC int read_flux_bc(void);
STATIC int read_free_surface_bc(void);
STATIC int read_grid(void);
STATIC int read_head_ic(void);
STATIC int read_leaky_bc(void);
STATIC int read_drain(void);
STATIC int read_zone_budget(void);
#ifdef SKIP
STATIC bool read_coordinate_system(Polyhedron * poly_ptr, char *next_char);
#endif
#if defined(__WPHAST__)
int read_line_doubles(char *next_char, double **d, int *count_d,
					  int *count_alloc);
extern int read_lines_doubles(char *next_char, double **d, int *count_d,
							  int *count_alloc, const char **opt_list,
							  int count_opt_list, int *opt);
#else
STATIC int read_line_doubles(char *next_char, double **d, int *count_d,
							 int *count_alloc);
STATIC int read_lines_doubles(char *next_char, double **d, int *count_d,
							  int *count_alloc, const char **opt_list,
							  int count_opt_list, int *opt);
#endif
static int read_line_doubles_delimited(char *next_char, double **d,
									   int *count_d, int *count_alloc);
static int read_lines_doubles_delimited(char *next_char, double **d,
										int *count_d, int *count_alloc,
										const char **opt_list,
										int count_opt_list, int *opt);
STATIC double *read_list_doubles(char **ptr, int *count_doubles);
STATIC int read_media(void);
STATIC int read_number_description(char *ptr, int *n_user,
								   int *n_user_end, char **description);
STATIC int read_print_frequency(void);
STATIC int read_print_input(void);
STATIC int read_print_locations(void);
#ifdef SKIP
STATIC struct property *read_property_file_or_doubles(char *ptr,
													  const char **opt_list,
													  int count_opt_list,
													  int *opt);
#endif
STATIC int read_river(void);
STATIC int read_solute_transport(void);
STATIC int read_solution_method(void);
STATIC int read_specified_value_bc(void);
STATIC int read_steady_flow(void);
STATIC int read_time_control(void);
STATIC int read_time_data(char **next_char, struct time *time_ptr,
						  const char *errstr);
STATIC int read_title(void);
STATIC int read_units(void);
STATIC int read_well(void);
#ifdef SKIP
STATIC int read_zone(char **next_char, struct zone *zone_ptr);
#endif
#if defined(__WPHAST__)
extern int check_key(char *str);
#else
STATIC int check_key(char *str);
#endif
STATIC int check_line(const char *string, int allow_empty, int allow_eof,
					  int allow_keyword, int print);
STATIC int find_option(char *item, int *n, const char **list, int count_list,
					   int exact);
#if defined(__WPHAST__)
extern int get_line(FILE * fp);
#else
STATIC int get_line(FILE * fp);
STATIC int get_logical_line(FILE * fp, int *l);
STATIC int add_char_to_line(int *i, char c);
#endif
STATIC int get_true_false(char *string, int default_value);


#define OPTION_EOF -1
#define OPTION_KEYWORD -2
#define OPTION_ERROR -3
#define OPTION_DEFAULT -4
#define OPTION_DEFAULT2 -5

/* ---------------------------------------------------------------------- */
int
read_input(void)
/* ---------------------------------------------------------------------- */
{
	int i, j;

	input_error = 0;
	next_keyword = 0;
/*
 *  Initialize keyword flags
 */
	for (i = 0; i < NKEYS; i++)
	{
		keyword[i].keycount = 0;
	}

	free_check_null(title_x);
	title_x = NULL;

	while ((i =
			check_line("Subroutine Read", FALSE, TRUE, TRUE,
					   FALSE)) != KEYWORD)
	{
		/* empty, eof, keyword, print */
		if (i == EOF)
			return (EOF);
		sprintf(error_string, "Unknown input: %s", line);
		warning_msg(error_string);
	}
/*
	  0	  "eof"
	  1	  "end"
	  2       "title"
	  3       "comment"
	  4       "grid"
	  5       "media"
	  6       "head_ic"
	  7       "chemistry_ic"
	  8       "free_surface_bc"
	  9       "specified_value_bc"
	  10      "specified_bc"
	  11      "flux_bc"
	  12      "leaky_bc"
	  13      "units"
	  14      "fluid_properties"
	  15      "solution_method"
	  16      "time_control"
	  17      "print_frequency"
	  18      "print_input"
	  19      "flow_only"
	  20      "free_surface" 
	  21      "rivers"
	  22      "river"
	  23      "wells"
	  24      "well"
	  25      "flow"
	  26      "print_locations"
	  27      "print_location"
	  28      "steady_flow"
	  29      "steady_state_flow"
	  30      "print_initial"
	  31      "solute_transport"
	  32      "specified_head_bc"
	  33      "drain"
	  34      "zone_budget"
	  35	  "zone_flow_rate"
	  36	"zone_flow_rates"
	  37	"zone_flowrate"
	  38	"zone_flowrates"
	  39    "zone_flow"
	  40    "zone_flows"
 */
	for (;;)
	{
		keyword[next_keyword].keycount++;
		switch (next_keyword)
		{
		case -1:				/* Have not read line with keyword */
			do
				j = check_line("No keyword", FALSE, TRUE, TRUE, FALSE);
			while (j != KEYWORD && j != EOF);
			break;
		case 0:				/* End encountered */
		case 1:				/* EOF encountered */
			goto END_OF_SIMULATION_INPUT;
		case 2:				/* title */
		case 3:				/* comment */
			read_title();
			break;
		case 4:				/* grid */
			read_grid();
			break;
		case 5:				/* media */
			read_media();
			break;
		case 6:				/* head init cond */
			read_head_ic();
			break;
		case 7:				/* chem init cond */
			read_chemistry_ic();
			break;
		case 8:				/* free surface bc */
		case 20:				/* free surface */
			read_free_surface_bc();
			break;
		case 9:				/* specified_value_bc */
			warning_msg
				("SPECIFIED_VALUE_BC is obsolete, use SPECIFIED_HEAD_BC.");
		case 10:				/* specified_bc */
		case 32:				/* specified_bc */
			read_specified_value_bc();
			break;
		case 11:				/* flux_bc */
			read_flux_bc();
			break;
		case 12:				/* leaky_bc */
			read_leaky_bc();
			break;
		case 13:				/* units */
			read_units();
			break;
		case 14:				/* fluid_properties */
			read_fluid_properties();
			break;
		case 15:				/* solution_method */
			read_solution_method();
			break;
		case 16:				/* time_control */
			read_time_control();
			break;
		case 17:				/* print_frequency */
			read_print_frequency();
			break;
		case 18:				/* print_input */
		case 30:				/* print_initial */
			read_print_input();
			break;
		case 19:				/* flow_only */
			read_flow_only();
			break;
		case 21:				/* rivers */
		case 22:				/* river */
			read_river();
			break;
		case 23:				/* wells */
		case 24:				/* well */
			read_well();
			break;
		case 25:				/* flow */
			read_flow();
			break;
		case 26:				/* print_locations */
		case 27:				/* print_location */
			read_print_locations();
			break;
		case 28:				/* steady_flow */
		case 29:				/* steady_state_flow */
			read_steady_flow();
			break;
		case 31:				/* steady_state_flow */
			read_solute_transport();
			break;
		case 33:				/* drain */
			read_drain();
			break;
		case 34:				/* zone_budget */
		case 35:				/* zone_flow_rate */
		case 36:				/* zone_flow_rates */
		case 37:				/* zone_flowrate */
		case 38:				/* zone_flowrates */
		case 39:				/* zone_flow */
		case 40:				/* zone_flows */
			read_zone_budget();
			break;
		}
	}
  END_OF_SIMULATION_INPUT:
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
read_title(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads title for simulation
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *         KEYWORD if keyword encountered, input_error may be incremented if
 *                    a keyword is encountered in an unexpected position
 *         EOF     if eof encountered while reading mass balance concentrations
 *         ERROR   if error occurred reading data
 *
 */
	char *ptr, *ptr1;
	int l;
	size_t title_x_length, line_length;
	int return_value;
	char token[MAX_LENGTH];
/*
 *   Read anything after keyword
 */
	ptr = line;
	copy_token(token, &ptr, &l);
	ptr1 = ptr;
	if (copy_token(token, &ptr, &l) != EMPTY)
	{
		title_x = string_duplicate(ptr1);
	}
	else
	{
		title_x = (char *) malloc(sizeof(char));
		title_x[0] = '\0';
	}

/*
 *   Read additonal lines
 */
	for (;;)
	{
		return_value = check_line("title", TRUE, TRUE, TRUE, TRUE);
		/* empty, eof, keyword, print */
		if (return_value == EOF || return_value == KEYWORD)
			break;
/*
 *   append line to title_x
 */
		title_x_length = strlen(title_x);
		line_length = strlen(line);
		title_x =
			(char *) realloc(title_x,
							 (size_t) (title_x_length + line_length +
									   2) * sizeof(char));
		if (title_x_length > 0)
		{
			title_x[title_x_length] = '\n';
			title_x[title_x_length + 1] = '\0';
		}
		strcat(title_x, line);
	}
	if (simulation > 0)
	{
		sprintf(error_string,
				"TITLE only useful for first simulation period");
		warning_msg(error_string);
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
/*
 *   Utilitity routines for read
 */
/* ---------------------------------------------------------------------- */

/* ---------------------------------------------------------------------- */
int
check_key(char *str)
/* ---------------------------------------------------------------------- */
{
/*
 *   Check if string begins with a keyword, returns TRUE or FALSE
 *
 *   Arguments:
 *      *str is pointer to character string to be checked for keywords
 *   Returns:
 *      TRUE,
 *      FALSE.
 */
	int i, l;
	char *ptr;
	char token[MAX_LENGTH];

	ptr = str;
	copy_token(token, &ptr, &l);
	str_tolower(token);
	next_keyword = -1;
	for (i = 0; i < NKEYS; i++)
	{
		if (strcmp(token, keyword[i].name) == 0)
		{
			next_keyword = i;
			return (TRUE);
		}
	}
	return (FALSE);
}

/* ---------------------------------------------------------------------- */
int
check_line(const char *string, int allow_empty, int allow_eof,
		   int allow_keyword, int print)
/* ---------------------------------------------------------------------- */
{
/*
 *   Function gets a new line and checks for empty, eof, and keywords.
 *
 *   Arguments:
 *      string        Input, character string used in printing error message
 *      allow_empty   Input, True or false, if a blank line is accepable
 *                       if false, another line is read
 *      allow_eof     Input, True or false, if EOF is acceptable
 *      allow_keyword Input, True or false, if a keyword is acceptable
 *
 *   Returns:
 *      EMPTY         if empty line read and allow_empty == true
 *      KEYWORD       if line begins with keyword
 *      EOF           if eof and allow_eof == true
 *      OK            otherwise
 *      OPTION        if line begins with -[alpha]
 *
 *   Terminates       if EOF and allow_eof == false.
 */
	int i;

	if (database_file != NULL)
	{
		print = FALSE;
	}

/* Get line */
	do
	{
		i = get_line(input);
		if (pr.echo_input == TRUE)
		{
			if ((print == TRUE && i != EOF) || i == KEYWORD)
			{
				output_msg(OUTPUT_ECHO, "\t%s\n", line_save);
			}
		}
	}
	while (i == EMPTY && allow_empty == FALSE);
/* Check eof */
	if (i == EOF && allow_eof == FALSE)
	{
		sprintf(error_string,
				"Unexpected eof while reading %s\nExecution terminated.\n",
				string);
		error_msg(error_string, STOP);
	}
/* Check keyword */
	if (i == KEYWORD && allow_keyword == FALSE)
	{
		sprintf(error_string,
				"Expected data for %s, but got a keyword ending data block.",
				string);
		error_msg(error_string, CONTINUE);
		input_error++;
	}
	check_line_return = i;
	return (i);
}

/* ---------------------------------------------------------------------- */
int
check_units(char *tot_units, int alkalinity, int check_compatibility,
			const char *default_units, int print)
/* ---------------------------------------------------------------------- */
{
#define NUNITS (sizeof(units) / sizeof(char *))
/*
 *   Check if legitimate units
 *   Input:
 *           tot_units           character string to check,
 *           alkalinity          TRUE if alkalinity, FALSE if any other total,
 *           check_compatibility TRUE check alk and default units, FALSE otherwise
 *           default_units       character string of default units (check /L, /kg, etc)
 *           print               TRUE print warning messages
 *   Output:
 *           tot_units           standard form for unit
 */
	int i, found;
	char *end;
	char string[MAX_LENGTH];
	const char *units[] = {
		"Mol/l",				/* 0 */
		"mMol/l",				/* 1 */
		"uMol/l",				/* 2 */
		"g/l",					/* 3 */
		"mg/l",					/* 4 */
		"ug/l",					/* 5 */
		"Mol/kgs",				/* 6 */
		"mMol/kgs",				/* 7 */
		"uMol/kgs",				/* 8 */
		"g/kgs",				/* 9 = ppt */
		"mg/kgs",				/* 10 = ppm */
		"ug/kgs",				/* 11 = ppb */
		"Mol/kgw",				/* 12 = mol/kg H2O */
		"mMol/kgw",				/* 13 = mmol/kg H2O */
		"uMol/kgw",				/* 14 = umol/kg H2O */
		"g/kgw",				/* 15 = mol/kg H2O */
		"mg/kgw",				/* 16 = mmol/kg H2O */
		"ug/kgw",				/* 17 = umol/kg H2O */
		"eq/l",					/* 18 */
		"meq/l",				/* 19 */
		"ueq/l",				/* 20 */
		"eq/kgs",				/* 21 */
		"meq/kgs",				/* 22 */
		"ueq/kgs",				/* 23 */
		"eq/kgw",				/* 24 */
		"meq/kgw",				/* 25 */
		"ueq/kgw",				/* 26 */
	};

	squeeze_white(tot_units);
	str_tolower(tot_units);
	replace("milli", "m", tot_units);
	replace("micro", "u", tot_units);
	replace("grams", "g", tot_units);
	replace("gram", "g", tot_units);
	replace("moles", "Mol", tot_units);
	replace("mole", "Mol", tot_units);
	replace("mol", "Mol", tot_units);
	replace("liter", "l", tot_units);
	replace("kgh", "kgw", tot_units);
	replace("ppt", "g/kgs", tot_units);
	replace("ppm", "mg/kgs", tot_units);
	replace("ppb", "ug/kgs", tot_units);
	replace("equivalents", "eq", tot_units);
	replace("equivalent", "eq", tot_units);
	replace("equiv", "eq", tot_units);

	if ((end = strstr(tot_units, "/l")) != NULL)
	{
		*(end + 2) = '\0';
	}
	if ((end = strstr(tot_units, "/kgs")) != NULL)
	{
		*(end + 4) = '\0';
	}
	if ((end = strstr(tot_units, "/kgw")) != NULL)
	{
		*(end + 4) = '\0';
	}
/*
 *   Check if unit in list
 */
	found = FALSE;
	for (i = 0; i < (int) NUNITS; i++)
	{
		if (strcmp(tot_units, units[i]) == 0)
		{
			found = TRUE;
			break;
		}
	}
	if (found == FALSE)
	{
		if (print == TRUE)
		{
			sprintf(error_string, "Unknown unit, %s.", tot_units);
			error_msg(error_string, CONTINUE);
		}
		return (ERROR);
	}

/*
 *   Check if units are compatible with default_units
 */
	if (check_compatibility == FALSE)
		return (OK);
/*
 *   Special cases for alkalinity
 */
	if (alkalinity == TRUE && strstr(tot_units, "Mol") != NULL)
	{
		if (print == TRUE)
		{
			sprintf(error_string,
					"Alkalinity given in moles, assumed to be equivalents.");
			warning_msg(error_string);
		}
		replace("Mol", "eq", tot_units);
	}
	if (alkalinity == FALSE && strstr(tot_units, "eq") != NULL)
	{
		if (print == TRUE)
		{
			error_msg("Only alkalinity can be entered in equivalents.",
					  CONTINUE);
		}
		return (ERROR);
	}
/*
 *   See if default_units are compatible with tot_units
 */
	if (strstr(default_units, "/l") && strstr(tot_units, "/l"))
		return (OK);
	if (strstr(default_units, "/kgs") && strstr(tot_units, "/kgs"))
		return (OK);
	if (strstr(default_units, "/kgw") && strstr(tot_units, "/kgw"))
		return (OK);

	strcpy(string, default_units);
	replace("kgs", "kg solution", string);
	replace("kgs", "kg solution", tot_units);
	replace("kgw", "kg water", string);
	replace("kgw", "kg water", tot_units);
	replace("/l", "/L", string);
	replace("Mol", "mol", string);
	replace("/l", "/L", tot_units);
	replace("Mol", "mol", tot_units);
	if (print == TRUE)
	{
		sprintf(error_string,
				"Units for master species, %s, are not compatible with default units, %s.",
				tot_units, string);
		error_msg(error_string, CONTINUE);
	}
	return (ERROR);
}

/* ---------------------------------------------------------------------- */
int
find_option(char *item, int *n, const char **list, int count_list, int exact)
/* ---------------------------------------------------------------------- */
{
/*
 *   Compares a string value to match beginning letters of a list of options
 *
 *      Arguments:
 *         item    entry: pointer to string to compare
 *         n       exit:  item in list that was matched
 *         list    entry: pointer to list of character values, assumed to
 *                 be lower case
 *         count_list entry: number of character values in list
 *
 *      Returns:
 *         OK      item matched
 *         ERROR   item not matched
 *         n       -1      item not matched
 *                 i       position of match in list
 */
	int i;
	char token[MAX_LENGTH];

	strcpy(token, item);
	str_tolower(token);
	for (i = 0; i < count_list; i++)
	{
		if (exact == TRUE)
		{
			if (strcmp(list[i], token) == 0)
			{
				*n = i;
				return (OK);
			}
		}
		else
		{
			if (strstr(list[i], token) == list[i])
			{
				*n = i;
				return (OK);
			}
		}
	}
	*n = -1;
	return (ERROR);
}

/* ---------------------------------------------------------------------- */
int
get_true_false(char *string, int default_value)
/* ---------------------------------------------------------------------- */
{
/*
 *   Returns true unless string starts with "F" or "f"
 */
	int l;
	char token[MAX_LENGTH];
	char *ptr;

	ptr = string;

	if (copy_token(token, &ptr, &l) == EMPTY)
	{
		return (default_value);
	}
	else
	{
		if (token[0] == 'F' || token[0] == 'f')
		{
			return (FALSE);
		}
	}
	return (TRUE);
}

#if !defined(__WPHAST__)
/* ---------------------------------------------------------------------- */
int
get_logical_line(FILE * fp, int *l)
/* ---------------------------------------------------------------------- */
{
/*
 *   Reads file fp until end of line, ";", or eof
 *   stores characters in line_save
 *   reallocs line_save and line if more space is needed
 *
 *   returns:
 *           EOF on empty line on end of file or
 *           OK otherwise
 *           *l returns length of line
 */
	int i, j;
	int pos;
	char c;
	i = 0;
	while ((j = getc(fp)) != EOF)
	{
		c = (char) j;
		if (c == '#')
		{
			/* ignore all chars after # until newline */
			do
			{
				c = (char) j;
				if (c == '\n')
				{
					break;
				}
				add_char_to_line(&i, c);
			}
			while ((j = getc(fp)) != EOF);
		}
		if (c == ';')
			break;
		if (c == '\n')
		{
			break;
		}
		if (c == '\\')
		{
			pos = i;
			add_char_to_line(&i, c);
			while ((j = getc(fp)) != EOF)
			{
				c = (char) j;
				if (c == '\\')
				{
					pos = i;
					add_char_to_line(&i, c);
					continue;
				}
				if (c == '\n')
				{
					/* remove '\\' */
					for (; pos < i; pos++)
					{
						line_save[pos] = line_save[pos + 1];
					}
					i--;
					break;
				}
				add_char_to_line(&i, c);
				if (!isspace(j))
					break;
			}
		}
		else
		{
			add_char_to_line(&i, c);
		}
	}
	if (j == EOF && i == 0)
	{
		*l = 0;
		line_save[i] = '\0';
		return (EOF);
	}
	line_save[i] = '\0';
	*l = i;
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
add_char_to_line(int *i, char c)
/* ---------------------------------------------------------------------- */
{
	if (*i + 20 >= max_line)
	{
		max_line *= 2;
		line_save =
			(char *) realloc(line_save, (size_t) max_line * sizeof(char));
		if (line_save == NULL)
			malloc_error();
		line = (char *) realloc(line, (size_t) max_line * sizeof(char));
		if (line == NULL)
			malloc_error();
	}
	line_save[*i] = c;
	*i += 1;
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
get_line(FILE * fp)
/* ---------------------------------------------------------------------- */
{
/*
 *   Read a line from input file put in "line".
 *   Copy of input line is stored in "line_save".
 *   Characters after # are discarded in line but retained in "line_save"
 *
 *   Arguments:
 *      fp is file name
 *   Returns:
 *      EMPTY,
 *      EOF,
 *      KEYWORD,
 *      OK,
 *      OPTION
 */
	int i, j, return_value, empty, l;
	char *ptr;
	char token[MAX_LENGTH];

	return_value = EMPTY;
	while (return_value == EMPTY)
	{
/*
 *   Eliminate all characters after # sign as a comment
 */
		i = -1;
		j = 0;
		empty = TRUE;
/*
 *   Get line, check for eof
 */
		if (get_logical_line(fp, &l) == EOF)
		{
			i = feof(fp);
			if (!i)
			{
				error_msg("Reading input file.", CONTINUE);
				error_msg("fgetc returned an error.", STOP);
			}
			else
			{
				next_keyword = 0;
				return (EOF);
			}
		}
/*
 *   Get long lines
 */
		j = l;
		ptr = strchr(line_save, '#');
		if (ptr != NULL)
		{
			j = ptr - line_save;
		}
		strncpy(line, line_save, (unsigned) j);
		line[j] = '\0';
		for (i = 0; i < j; i++)
		{
			if (!isspace((int) line[i]))
			{
				empty = FALSE;
				break;
			}
		}
/*
 *   New line character encountered
 */

		if (empty == TRUE)
		{
			return_value = EMPTY;
		}
		else
		{
			return_value = OK;
		}
	}
/*
 *   Determine return_value
 */
	if (return_value == OK)
	{
		if (check_key(line) == TRUE)
		{
			return_value = KEYWORD;
		}
		else
		{
			ptr = line;
			copy_token(token, &ptr, &i);
			if (token[0] == '-' && isalpha((int) token[1]))
			{
				return_value = OPTION;
			}
		}
	}
	return (return_value);
}
#endif /* __WPHAST__ */
/* ---------------------------------------------------------------------- */
int
get_option(const char **opt_list, int count_opt_list, char **next_char)
/* ---------------------------------------------------------------------- */
{
/*
 *   Read a line and check for options
 */
	int j;
	int opt_l, opt;
	char *opt_ptr;
	char option[MAX_LENGTH];
/*
 *   Read line
 */
	j = check_line("get_option", FALSE, TRUE, TRUE, FALSE);
	if (j == EOF)
	{
		j = OPTION_EOF;
	}
	else if (j == KEYWORD)
	{
		j = OPTION_KEYWORD;
	}
	else if (j == OPTION)
	{
		opt_ptr = line;
		copy_token(option, &opt_ptr, &opt_l);
		if (find_option(&(option[1]), &opt, opt_list, count_opt_list, FALSE)
			== OK)
		{
			j = opt;
			replace(option, opt_list[j], line_save);
			replace(option, opt_list[j], line);
			opt_ptr = line;
			copy_token(option, &opt_ptr, &opt_l);
			*next_char = opt_ptr;
			if (database_file == NULL && pr.echo_input == TRUE)
				output_msg(OUTPUT_ECHO, "\t%s\n", line_save);
		}
		else
		{
			if (database_file == NULL && pr.echo_input == TRUE)
				output_msg(OUTPUT_ECHO, "\t%s\n", line_save);
			error_msg("Unknown option.", CONTINUE);
			error_msg(line_save, CONTINUE);
			input_error++;
			j = OPTION_ERROR;
			*next_char = line;
		}
	}
	else
	{
		opt_ptr = line;
		copy_token(option, &opt_ptr, &opt_l);
		if (find_option(&(option[0]), &opt, opt_list, count_opt_list, TRUE) ==
			OK)
		{
			j = opt;
			*next_char = opt_ptr;
		}
		else
		{
			j = OPTION_DEFAULT;
			*next_char = line;
		}
		if (database_file == NULL && pr.echo_input == TRUE)
			output_msg(OUTPUT_ECHO, "\t%s\n", line_save);
	}
	return (j);
}

/* ---------------------------------------------------------------------- */
double *
read_list_doubles(char **ptr, int *count_doubles)
/* ---------------------------------------------------------------------- */
{
/*
 *   Reads a list of double numbers until end of line is reached or 
 *   a double can not be read from a token.
 *
 *      Arguments:
 *         ptr    entry: points to line to read from
 *                exit:  points to next non-double token or end of line
 *
 *         count_doubles exit: number of doubles read
 *
 *      Returns:
 *         pointer to a list of count_doubles doubles.
 */

	double *double_list;
	char token[MAX_LENGTH];
	double value;
	char *ptr_save;
	int l;

	double_list = (double *) malloc(sizeof(double));
	if (double_list == NULL)
		malloc_error();
	*count_doubles = 0;

	ptr_save = *ptr;
	while (copy_token(token, ptr, &l) != EMPTY)
	{
		if (sscanf(token, "%lf", &value) == 1)
		{
			*count_doubles = *count_doubles + 1;
			double_list =
				(double *) realloc(double_list,
								   (size_t) (*count_doubles) *
								   sizeof(double));
			if (double_list == NULL)
				malloc_error();
			double_list[(*count_doubles) - 1] = value;
			ptr_save = *ptr;
		}
		else
		{
			*ptr = ptr_save;
			break;
		}
	}
	return (double_list);
}

/* ---------------------------------------------------------------------- */
int
read_grid(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads grid data
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	int i, j = -1, l;
	int count, count_doubles;
	double *temp;
	char *ptr;
	char token[MAX_LENGTH];
	struct grid *grid_ptr;

	int return_value, opt, opt_save;
	char *next_char;
	const char *opt_list[] = {
		"uniform",				/* 0 */
		"nonuniform",			/* 1 */
		"non_uniform",			/* 2 */
		"chemistry_dimensions",	/* 3 */
		"transport_dimensions",	/* 4 */
		"print_orientation",	/* 5 */
		"overlay_uniform",		/* 6 */
		"overlay_nonuniform",	/* 7 */
		"snap",					/* 8 */
		"grid_origin",			/* 9 */
		"grid_angle"			/* 10 */
	};
	int count_opt_list = 11;
	/*
	 *   Read grid data
	 */
	return_value = UNKNOWN;
	opt_save = OPTION_ERROR;
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		if (opt == OPTION_DEFAULT)
		{
			opt = opt_save;
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_ERROR:
			error_msg("Expected an identifier for the GRID keyword",
					  CONTINUE);
			error_msg(line_save, CONTINUE);
			input_error++;
			break;
		case 0:				/* uniform spacing */
			/* read direction */
			i = copy_token(token, &next_char, &l);
			if (i == EMPTY)
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}
			str_tolower(token);
			if (token[0] == 'x')
			{
				j = 0;
			}
			else if (token[0] == 'y')
			{
				j = 1;
			}
			else if (token[0] == 'z')
			{
				j = 2;
			}
			else
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}

			/* set uniform */
			grid[j].uniform = TRUE;

			ptr = next_char;
			if (copy_token(token, &ptr, &l) == EMPTY)
			{
				grid_ptr = &grid[j];
				opt_save = OPTION_DEFAULT2;
				break;
			}
			else
			{
				if (sscanf(next_char, "%lf%lf%d", &(grid[j].coord[0]),
						   &(grid[j].coord[1]), &(grid[j].count_coord)) != 3)
				{
					sprintf(error_string,
							"Expected two coordinate values and the number of nodes for %c grid information.",
							grid[j].c);
					error_msg(error_string, CONTINUE);
					error_msg(line_save, CONTINUE);
					input_error++;
				}
			}
			opt_save = OPTION_ERROR;
			break;
		case 1:				/* nonuniform */
		case 2:				/* non_uniform */
			/* read direction */
			i = copy_token(token, &next_char, &l);
			if (i == EMPTY)
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}
			str_tolower(token);
			if (token[0] == 'x')
			{
				j = 0;
			}
			else if (token[0] == 'y')
			{
				j = 1;
			}
			else if (token[0] == 'z')
			{
				j = 2;
			}
			else
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}

			/* set nonuniform */
			grid[j].uniform = FALSE;
			ptr = next_char;
			temp = read_list_doubles(&ptr, &count_doubles);
			grid_ptr = &grid[j];
			if (temp == NULL)
			{
				break;
			}
			if (count_doubles > 0)
			{
				count = grid[j].count_coord;
				grid[j].coord =
					(double *) realloc(grid[j].coord,
									   (size_t) (count + count_doubles +
												 1) * sizeof(double));
				if (grid[j].coord == NULL)
					malloc_error();
				memcpy(&(grid[j].coord[count]),
					   temp, (size_t) count_doubles * sizeof(double));
				grid[j].count_coord += count_doubles;
			}
			free_check_null(temp);
			opt_save = OPTION_DEFAULT;
			break;
		case 3:				/* chemistry_dimensions */
		case 4:				/* transport_dimensions */
			for (j = 0; j < 3; j++)
			{
				axes[j] = FALSE;
			}
			while ((j = copy_token(token, &next_char, &l)) != EMPTY)
			{
				str_tolower(token);
				if (strstr(token, "x") != NULL)
					axes[0] = TRUE;
				if (strstr(token, "y") != NULL)
					axes[1] = TRUE;
				if (strstr(token, "z") != NULL)
					axes[2] = TRUE;
			}
			opt_save = OPTION_ERROR;
			break;
		case 5:				/* print_orientation */
			/* read coordinate directions */
			i = copy_token(token, &next_char, &l);
			if (i == EMPTY)
			{
				error_msg("Expected coordinate directions, xy or xz.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}
			str_tolower(token);
			if (strcmp(token, "xy") == 0)
			{
				print_input_xy = TRUE;
			}
			else if (strcmp(token, "xz") == 0)
			{
				print_input_xy = FALSE;
			}
			else
			{
				error_msg("Expected coordinate directions, xy or xz.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}
			opt_save = OPTION_ERROR;
			break;
		case 6:				/* overlay_uniform */
			/* read direction */
			i = copy_token(token, &next_char, &l);
			if (i == EMPTY)
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}
			str_tolower(token);
			if (token[0] == 'x')
			{
				j = 0;
			}
			else if (token[0] == 'y')
			{
				j = 1;
			}
			else if (token[0] == 'z')
			{
				j = 2;
			}
			else
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}
			/*
			 * malloc_space
			 */
			i = count_grid_overlay++;
			grid_overlay =
				(struct grid *) realloc(grid_overlay,
										(size_t) count_grid_overlay *
										sizeof(struct grid));
			if (grid_overlay == NULL)
				malloc_error();
			grid_overlay[i].coord =
				(double *) malloc((size_t) 2 * sizeof(double));
			if (grid_overlay[i].coord == NULL)
				malloc_error();
			grid_overlay[i].count_coord = 0;
			grid_overlay[i].elt_centroid = NULL;
			ptr = next_char;
			/*
			 * set values
			 */
			grid_overlay[i].direction = j;
			grid_overlay[i].uniform = TRUE;
			if (copy_token(token, &ptr, &l) == EMPTY)
			{
				grid_ptr = &grid_overlay[i];
				opt_save = OPTION_DEFAULT2;
				break;
			}
			else
			{
				if (sscanf(next_char, "%lf%lf%d", &(grid_overlay[i].coord[0]),
						   &(grid_overlay[i].coord[1]),
						   &(grid_overlay[i].count_coord)) != 3)
				{
					sprintf(error_string,
							"Expected two coordinate values and the number of nodes for %c grid information.",
							grid[j].c);
					error_msg(error_string, CONTINUE);
					error_msg(line_save, CONTINUE);
					input_error++;
				}
			}
			opt_save = OPTION_ERROR;
			break;

		case 7:				/* overlay_nonuniform */
			/* read direction */
			i = copy_token(token, &next_char, &l);
			if (i == EMPTY)
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}
			str_tolower(token);
			if (token[0] == 'x')
			{
				j = 0;
			}
			else if (token[0] == 'y')
			{
				j = 1;
			}
			else if (token[0] == 'z')
			{
				j = 2;
			}
			else
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}
			/*
			 * malloc_space
			 */
			i = count_grid_overlay++;
			grid_overlay =
				(struct grid *) realloc(grid_overlay,
										(size_t) count_grid_overlay *
										sizeof(struct grid));
			if (grid_overlay == NULL)
				malloc_error();
			grid_overlay[i].coord =
				(double *) malloc((size_t) 2 * sizeof(double));
			if (grid_overlay[i].coord == NULL)
				malloc_error();
			grid_overlay[i].count_coord = 0;
			grid_overlay[i].elt_centroid = NULL;
			ptr = next_char;
			/*
			 * set values
			 */
			grid_overlay[i].direction = j;
			grid_overlay[i].uniform = FALSE;

			ptr = next_char;
			temp = read_list_doubles(&ptr, &count_doubles);
			grid_ptr = &grid_overlay[i];
			if (temp == NULL)
			{
				break;
			}
			if (count_doubles > 0)
			{
				count = grid_ptr->count_coord;
				grid_ptr->coord =
					(double *) realloc(grid_ptr->coord,
									   (size_t) (count + count_doubles +
												 1) * sizeof(double));
				if (grid_ptr->coord == NULL)
					malloc_error();
				memcpy(&(grid_ptr->coord[count]),
					   temp, (size_t) count_doubles * sizeof(double));
				grid_ptr->count_coord += count_doubles;
			}
			free_check_null(temp);
			opt_save = OPTION_DEFAULT;
			break;

		case 8:				/* snap */
			/* read direction */
			i = copy_token(token, &next_char, &l);
			if (i == EMPTY)
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}
			str_tolower(token);
			if (token[0] == 'x')
			{
				j = 0;
			}
			else if (token[0] == 'y')
			{
				j = 1;
			}
			else if (token[0] == 'z')
			{
				j = 2;
			}
			else
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				break;
			}
			if (sscanf(next_char, "%lf", &(snap[j])) != 1)
			{
				sprintf(error_string,
						"Expected snap tolerance for minimum distance between nodes in %c direction.",
						grid[j].c);
				error_msg(error_string, CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
			}
			break;
		case OPTION_DEFAULT:
			/*
			 *   Read nonuniform grid coordinates for coordinate j
			 */
			opt_save = OPTION_DEFAULT;
			ptr = line;
			temp = read_list_doubles(&ptr, &count_doubles);
			if (temp == NULL)
			{
				break;
			}
			if (count_doubles > 0)
			{
				count = grid_ptr->count_coord;
				grid_ptr->coord =
					(double *) realloc(grid_ptr->coord,
									   (size_t) (count + count_doubles +
												 1) * sizeof(double));
				if (grid_ptr->coord == NULL)
					malloc_error();
				memcpy(&(grid_ptr->coord[count]),
					   temp, (size_t) count_doubles * sizeof(double));
				grid_ptr->count_coord += count_doubles;
			}
			free_check_null(temp);
			break;

		case OPTION_DEFAULT2:
			/*
			 *   Read uniform grid coordinates for grid_ptr
			 */
			/* read 2 coords and number of nodes */
			if (sscanf(next_char, "%lf%lf%d", &(grid_ptr->coord[0]),
					   &(grid_ptr->coord[1]), &(grid_ptr->count_coord)) != 3)
			{
				sprintf(error_string,
						"Expected two coordinate values and the number of nodes for %c grid information.",
						grid[j].c);
				error_msg(error_string, CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
			}
			opt_save = OPTION_ERROR;
			break;
		case 9:				/* grid origin in map units */

			if (sscanf
				(next_char, "%lf%lf%lf", &grid_origin[0], &grid_origin[1],
				 &grid_origin[2]) != 3)
			{
				sprintf(error_string,
						"Expected x, y, and z grid origin in map coordinates.");
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			opt_save = OPTION_ERROR;
			break;
		case 10:				/* grid angle counterclockwise */

			if (sscanf(next_char, "%lf", &grid_angle) != 1)
			{
				sprintf(error_string,
						"Expected grid angle (counterclockwise).");
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			opt_save = OPTION_ERROR;
			break;
		}
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"GRID can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_media(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads media properties
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	struct grid_elt *grid_elt_ptr;
	int return_value, opt;
	char *next_char;
	int l;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"kx",					/* 0 */
		"kxx",					/* 1 */
		"ky",					/* 2 */
		"kyy",					/* 3 */
		"kz",					/* 4 */
		"kzz",					/* 5 */
		"porosity",				/* 6 */
		"specific_storage",		/* 7 */
		"storage",				/* 8 */
		"dispersivity_longitudinal",	/* 9 */
		"dispersivity_long",	/* 10 */
		"long_alpha",			/* 11 */
		"longitudinal_alpha",	/* 12 */
		"alphat",				/* 13 */
		"alpha_t",				/* 14 */
		"transverse_alpha",		/* 15 */
		"trans_alpha",			/* 16 */
		"zone",					/* 17 */
		"active",				/* 18 */
		"long_dispersivity",	/* 19 */
		"longitudinal_dispersivity",	/* 20 */
		"long_disp",			/* 21 */
		"long",					/* 22 */
		"trans_dispersivity",	/* 23 */
		"transverse_dispersivity",	/* 24 */
		"trans_disp",			/* 25 */
		"trans",				/* 26 */
		"mask",					/* 27 */
		"horizontal_dispersivity",	/* 28 */
		"dispersivity_horizontal",	/* 29 */
		"alpha_horizontal",		/* 30 */
		"vertical_dispersivity",	/* 31 */
		"dispersivity_vertical",	/* 32 */
		"alpha_vertical",		/* 33 */
		"wedge",				/* 34 */
		"prism",				/* 35 */
		"vector",				/* 36 */
		"perimeter",			/* 37 */
		"top",					/* 38 */
		"bottom",				/* 39 */
		"description"			/* 40 */
		,"box"                  /* 41 */
		,"shell"                /* 42 */
	};
	int count_opt_list = 43;
	/*
	 *   Read grid data
	 */
	return_value = UNKNOWN;
	grid_elt_ptr = NULL;
	Prism *prism_ptr = NULL;
	/*
	 *   get first line
	 */
	sprintf(tag, "in MEDIA, definition %d.", count_grid_elt_zones);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			input_error++;
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 0:				/* kx */
		case 1:				/* kxx */
			/* read hydraulic conductivity */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for X direction hydraulic conductivity %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->kx != NULL)
			{
				sprintf(error_string,
						"X direction hydraulic conductivity has been redefined %s",
						tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->kx);
				grid_elt_ptr->kx = NULL;
			}
			grid_elt_ptr->kx =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->kx == NULL)
			{
				input_error++;
				sprintf(error_string,
						"Reading X direction hydraulic conductivity %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 2:				/* ky */
		case 3:				/* kyy */
			/* read Y hydraulic conductivity */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for Y direction hydraulic conductivity %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->ky != NULL)
			{
				sprintf(error_string,
						"Y direction hydraulic conductivity has been redefined %s",
						tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->ky);
				grid_elt_ptr->ky = NULL;
			}
			grid_elt_ptr->ky =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->ky == NULL)
			{
				input_error++;
				sprintf(error_string,
						"Reading Y direction hydraulic conductivity %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 4:				/* kz */
		case 5:				/* kzz */
			/* read Z hydraulic conductivity */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for Z direction hydraulic conductivity %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->kz != NULL)
			{
				sprintf(error_string,
						"Z direction hydraulic conductivity has been redefined %s",
						tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->kz);
				grid_elt_ptr->kz = NULL;
			}
			grid_elt_ptr->kz =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->kz == NULL)
			{
				input_error++;
				sprintf(error_string,
						"Reading Z direction hydraulic conductivity %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 6:				/* porosity */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for porosity %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->porosity != NULL)
			{
				sprintf(error_string, "Porosity has been redefined %s", tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->porosity);
				grid_elt_ptr->porosity = NULL;
			}
			grid_elt_ptr->porosity =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->porosity == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading porosity %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 7:				/* specific storage */
		case 8:				/* storage */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for specific storage %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->storage != NULL)
			{
				sprintf(error_string,
						"Specific storage has been redefined %s", tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->storage);
				grid_elt_ptr->storage = NULL;
			}
			grid_elt_ptr->storage =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->storage == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading storage %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 9:				/* dispersivity_longitudinal */
		case 10:				/* dispersivity_long */
		case 11:				/* long_alpha */
		case 12:				/* longitudinal_alpha */
		case 19:				/* long_dispersivity */
		case 20:				/* longitudinal_dispersivity */
		case 21:				/* long_disp */
		case 22:				/* long */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for longitudinal dispersivity %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->alpha_long != NULL)
			{
				sprintf(error_string,
						"Longitudinal dispersivity has been redefined %s",
						tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->alpha_long);
				grid_elt_ptr->alpha_long = NULL;
			}
			grid_elt_ptr->alpha_long =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->alpha_long == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading longitudinal dispersivity %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 13:				/* alphat */
		case 14:				/* alpha_t */
		case 15:				/* transverse_alpha */
		case 16:				/* trans_alpha */
		case 23:				/* trans_dispersivity */
		case 24:				/* transverse_dispersivity */
		case 25:				/* trans_disp */
		case 26:				/* trans */
			sprintf(error_string,
					"Transverse_dispersivity option is obsolete.\n\tUse -horizontal_dispersivity and -vertical_dispersivity.");
			warning_msg(error_string);
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for transverse dispersivity %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->alpha_trans != NULL)
			{
				sprintf(error_string,
						"Transverse dispersivity has been redefined %s", tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->alpha_trans);
				grid_elt_ptr->alpha_trans = NULL;
			}
			grid_elt_ptr->alpha_trans =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->alpha_trans == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading transverse dispersivity %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 17:				/* zone */
		case 41:				/* box */
			/*
			 *   Allocate space for grid_elt, read zone data
			 */
			grid_elt_zones =
				(struct grid_elt **) realloc(grid_elt_zones,
											 (size_t) (count_grid_elt_zones +
													   1) *
											 sizeof(struct grid_elt *));
			if (grid_elt_zones == NULL)
				malloc_error();

			grid_elt_zones[count_grid_elt_zones] = grid_elt_alloc();
			grid_elt_ptr = grid_elt_zones[count_grid_elt_zones];
			count_grid_elt_zones++;
			sprintf(tag, "in MEDIA, definition %d.", count_grid_elt_zones);

			grid_elt_ptr->polyh = read_cube(&next_char);
			if (grid_elt_ptr->polyh == NULL)
			{
				sprintf(error_string, "Reading zone %s", tag);
				error_msg(error_string, CONTINUE);
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 18:				/* active */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"active cell input %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->active != NULL)
			{
				sprintf(error_string, "Active cells have been redefined %s",
						tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->active);
				grid_elt_ptr->active = NULL;
			}
			grid_elt_ptr->active =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->active == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading active cells %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 27:				/* mask */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"mask %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->mask != NULL)
			{
				sprintf(error_string,
						"Mask for this zone is being redefined %s", tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->mask);
				grid_elt_ptr->mask = NULL;
			}
			grid_elt_ptr->mask =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->mask == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading mask %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 28:				/* horizontal_dispersivity */
		case 29:				/* dispersivity_horizontal */
		case 30:				/* alpha_horizontal */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for horizontal_dispersivity %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->alpha_horizontal != NULL)
			{
				sprintf(error_string,
						"Horizontal_dispersivity has been redefined %s", tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->alpha_horizontal);
				grid_elt_ptr->alpha_horizontal = NULL;
			}
			grid_elt_ptr->alpha_horizontal =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->alpha_horizontal == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading horizontal dispersivity %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 31:				/* vertical_dispersivity */
		case 32:				/* dispersivity_vertical */
		case 33:				/* alpha_vertical */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for vertical_dispersivity %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->alpha_vertical != NULL)
			{
				sprintf(error_string,
						"Vertical_dispersivity has been redefined %s", tag);
				warning_msg(error_string);
				property_free(grid_elt_ptr->alpha_vertical);
				grid_elt_ptr->alpha_vertical = NULL;
			}
			grid_elt_ptr->alpha_vertical =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (grid_elt_ptr->alpha_vertical == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading vertical dispersivity %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 34:				/* wedge */
			/*
			 *   Allocate space for grid_elt, read wedge data
			 */
			grid_elt_zones =
				(struct grid_elt **) realloc(grid_elt_zones,
											 (size_t) (count_grid_elt_zones +
													   1) *
											 sizeof(struct grid_elt *));
			if (grid_elt_zones == NULL)
				malloc_error();

			grid_elt_zones[count_grid_elt_zones] = grid_elt_alloc();
			grid_elt_ptr = grid_elt_zones[count_grid_elt_zones];
			count_grid_elt_zones++;
			sprintf(tag, "in MEDIA, definition %d.", count_grid_elt_zones);

			grid_elt_ptr->polyh = read_wedge(&next_char);
			{
				Wedge *w_ptr = dynamic_cast < Wedge * >(grid_elt_ptr->polyh);
				if (grid_elt_ptr->polyh == NULL
					|| w_ptr->orientation == Wedge::WEDGE_ERROR)
				{
					input_error++;
					sprintf(error_string, "Reading wedge %s", tag);
					error_msg(error_string, CONTINUE);
				}
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 35:				/* prism */
			{
				/*
				 *   Allocate space for grid_elt, read wedge data
				 */
				grid_elt_zones =
					(struct grid_elt **) realloc(grid_elt_zones,
												 (size_t)
												 (count_grid_elt_zones +
												  1) *
												 sizeof(struct grid_elt *));
				if (grid_elt_zones == NULL)
					malloc_error();

				grid_elt_zones[count_grid_elt_zones] = grid_elt_alloc();
				grid_elt_ptr = grid_elt_zones[count_grid_elt_zones];
				count_grid_elt_zones++;
				sprintf(tag, "in MEDIA, definition %d.",
						count_grid_elt_zones);
				prism_ptr = new Prism;
				grid_elt_ptr->polyh = prism_ptr;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}

		case 36:				/* vector */
		case 37:				/* perimeter */
		case 38:				/* top */
		case 39:				/* bottom */
			{
				std::istringstream lines;
				// opt = streamify_to_next_keyword_or_option(opt_list,
				//										count_opt_list,
				//										lines);
				opt = streamify_prism_piece(opt_list,
					count_opt_list,
					lines);

				if (grid_elt_ptr == NULL || grid_elt_ptr->polyh == NULL
					|| prism_ptr == NULL || !prism_ptr->Read(lines))
				{
					input_error++;
					sprintf(error_string, "Reading prism %s", tag);
					error_msg(error_string, CONTINUE);
					break;
				}
			}
			break;
		case 40:				/* description */
			/* read description */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone, wedge, or prism has not been defined for description %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (grid_elt_ptr->polyh->Get_description()->size() != 0)
			{
				sprintf(error_string, "Description has been redefined %s",
						tag);
				warning_msg(error_string);
				grid_elt_ptr->polyh->Get_description()->clear();
			}
			//std::string str(next_char);
			grid_elt_ptr->polyh->Get_description()->assign(next_char);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 42:				/* shell */
			if (grid_elt_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for -shell option %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			grid_elt_ptr->shell = true;
			sscanf(next_char, "%lf%lf%lf",  
				&grid_elt_ptr->shell_width[0], 
				&grid_elt_ptr->shell_width[1], 
				&grid_elt_ptr->shell_width[2]);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"MEDIA properties can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

#ifdef SKIP
/* ---------------------------------------------------------------------- */
int
read_zone(char **next_char, struct zone *zone_ptr)
/* ---------------------------------------------------------------------- */
{
	int i, j, l;
	double xyz[6];
	char *ptr;
	char token[MAX_LENGTH];

	ptr = *next_char;
/*
 *   read x1, y1, z1, x2, y2, z2
 */
	zone_ptr->zone_defined = FALSE;
	for (i = 0; i < 6; i++)
	{
		j = copy_token(token, &ptr, &l);
		if (j != DIGIT)
		{
			error_msg("Expected a coordinate value in zone definition.",
					  CONTINUE);
			error_msg(line_save, CONTINUE);
			input_error++;
			return (ERROR);
		}
		sscanf(token, "%lf", &(xyz[i]));
	}
	zone_ptr->x1 = xyz[0];
	zone_ptr->y1 = xyz[1];
	zone_ptr->z1 = xyz[2];
	zone_ptr->x2 = xyz[3];
	zone_ptr->y2 = xyz[4];
	zone_ptr->z2 = xyz[5];
	zone_ptr->zone_defined = TRUE;
	return (OK);
}
#endif
/* ---------------------------------------------------------------------- */
Cube *
read_cube(char **next_char)
/* ---------------------------------------------------------------------- */
{
	int i, j, l;
	double xyz[6];
	char *ptr;
	char token[MAX_LENGTH];
	ptr = *next_char;
	struct zone z;
/*
 *   read x1, y1, z1, x2, y2, z2
 */
	z.zone_defined = FALSE;
	for (i = 0; i < 6; i++)
	{
		j = copy_token(token, &ptr, &l);
		if (j != DIGIT)
		{
			error_msg("Expected a coordinate value in zone definition.",
					  CONTINUE);
			error_msg(line_save, CONTINUE);
			input_error++;
			return (NULL);
		}
		sscanf(token, "%lf", &(xyz[i]));
	}
	z.x1 = xyz[0];
	z.y1 = xyz[1];
	z.z1 = xyz[2];
	z.x2 = xyz[3];
	z.y2 = xyz[4];
	z.z2 = xyz[5];
	z.zone_defined = TRUE;

	PHAST_Transform::COORDINATE_SYSTEM coord(PHAST_Transform::GRID);
	if ((j = copy_token(token, &ptr, &l)) != EMPTY)
	{
		// Read coordinate system
		std::string cs(token);
		std::transform(cs.begin(), cs.end(), cs.begin(),::tolower);
		std::string grid("grid"), map("map");
		if (cs == grid)
		{
			coord = PHAST_Transform::GRID;
		}
		else if (cs == map)
		{
			coord = PHAST_Transform::MAP;
		}
		else
		{
			error_msg("Expected GRID or MAP for coordinate system.",
					  CONTINUE);
			error_msg(line_save, CONTINUE);
			input_error++;
			return (NULL);
		}
	}
	Cube *c_ptr = new Cube(&z);
	c_ptr->Set_coordinate_system(coord);
	c_ptr->Set_user_coordinate_system(coord);

	return (c_ptr);
}

//template<class InputIterator>
/* ---------------------------------------------------------------------- */
Wedge *
read_wedge(char **next_char)
/* ---------------------------------------------------------------------- */
{
	int i, j, l;
	double xyz[6];
	char *ptr;
	char token[MAX_LENGTH];
	ptr = *next_char;
	struct zone z;
/*
 *   read x1, y1, z1, x2, y2, z2
 */
	z.zone_defined = FALSE;
	for (i = 0; i < 6; i++)
	{
		j = copy_token(token, &ptr, &l);
		if (j != DIGIT)
		{
			error_msg("Expected a coordinate value in zone definition.",
					  CONTINUE);
			error_msg(line_save, CONTINUE);
			input_error++;
			return (NULL);
		}
		sscanf(token, "%lf", &(xyz[i]));
	}
	z.x1 = xyz[0];
	z.y1 = xyz[1];
	z.z1 = xyz[2];
	z.x2 = xyz[3];
	z.y2 = xyz[4];
	z.z2 = xyz[5];
	z.zone_defined = TRUE;

	// Read wedge orientation
	j = copy_token(token, &ptr, &l);
	if (j != UPPER && j != LOWER)
	{
		error_msg("Expected Xn, Yn, or Zn wedge definition.", CONTINUE);
		error_msg(line_save, CONTINUE);
		input_error++;
		return (NULL);
	}
	char token1[MAX_LENGTH];
	PHAST_Transform::COORDINATE_SYSTEM coord(PHAST_Transform::GRID);
	if ((j = copy_token(token1, &ptr, &l)) != EMPTY)
	{
		// Read coordinate system
		std::string cs(token1);
		std::transform(cs.begin(), cs.end(), cs.begin(),::tolower);
		std::string grid("grid"), map("map");
		if (cs == grid)
		{
			coord = PHAST_Transform::GRID;
		}
		else if (cs == map)
		{
			coord = PHAST_Transform::MAP;
		}
		else
		{
			error_msg("Expected GRID or MAP for coordinate system.",
					  CONTINUE);
			error_msg(line_save, CONTINUE);
			input_error++;
			return (NULL);
		}
	}

	std::string s(token);
	Wedge *w_ptr = new Wedge(&z, s);
	w_ptr->Set_coordinate_system(coord);
	w_ptr->Set_user_coordinate_system(coord);

	return (w_ptr);
}

/* ---------------------------------------------------------------------- */
int
read_head_ic(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads head initial conditions properties
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	struct Head_ic *head_ic_ptr;
	int return_value, opt;
	char *next_char;
	int l;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"zone",					/* 0 */
		"water_table",			/* 1 */
		"head",					/* 2 */
		"mask",					/* 3 */
		"wedge",				/* 4 */
		"prism",				/* 5 */
		"vector",				/* 6 */
		"perimeter",			/* 7 */
		"top",					/* 8 */
		"bottom",				/* 9 */
		"description"			/* 10 */
		,"box"                  /* 11 */
	};
	int count_opt_list = 12;
	/*
	 *   Read grid data
	 */
	return_value = UNKNOWN;
	head_ic_ptr = NULL;
	Prism *prism_ptr = NULL;

	/*
	 *   get first line
	 */
	sprintf(tag, "in HEAD_IC, definition %d.", count_head_ic);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* zone */
		case 11:			/* box */
			/*
			 *   Allocate space for head_ic, read zone data
			 */
			head_ic =
				(struct Head_ic **) realloc(head_ic,
											(size_t) (count_head_ic +
													  1) *
											sizeof(struct Head_ic *));
			if (head_ic == NULL)
				malloc_error();

			head_ic[count_head_ic] = head_ic_alloc();
			head_ic_ptr = head_ic[count_head_ic];
			count_head_ic++;
			sprintf(tag, "in HEAD_IC, definition %d.", count_head_ic);
			head_ic_init(head_ic_ptr);

			head_ic_ptr->polyh = read_cube(&next_char);
			if (head_ic_ptr->polyh == NULL)
			{
				sprintf(error_string, "Reading zone %s", tag);
				error_msg(error_string, CONTINUE);
			}
			head_ic_ptr->ic_type = ZONE;
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 1:				/* water_table */
			input_error++;
			sprintf(error_string,
					"Water_table option is no longer available, use -head. %s",
					tag);
			error_msg(error_string, CONTINUE);
			break;
#ifdef SKIP
			/*
			 *   Allocate space for head_ic  and head_list
			 */
			head_ic = (struct Head_ic **) realloc(head_ic, (size_t)
												  (count_head_ic +
												   1) *
												  sizeof(struct Head_ic *));
			if (head_ic == NULL)
				malloc_error();

			head_ic[count_head_ic] = head_ic_alloc();
			head_ic_ptr = head_ic[count_head_ic];
			head_ic_init(head_ic_ptr);
			head_ic_ptr->ic_type = WATER_TABLE;
			count_head_ic++;
			sprintf(tag, "in HEAD_IC, definition %d.", count_head_ic);
			head_ic_ptr->head =
				read_property_file_or_doubles(next_char, opt_list,
											  count_opt_list, &opt);
			if (head_ic_ptr->head == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading water table heads %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
#endif
		case 2:				/* head */
			/*
			 *   Read head value for zone
			 */
			if (head_ic_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for initial head condition %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (head_ic_ptr->head != NULL)
			{
				sprintf(error_string,
						"Initial head condition have been redefined %s", tag);
				warning_msg(error_string);
				property_free(head_ic_ptr->head);
				head_ic_ptr->head = NULL;
			}
			head_ic_ptr->head =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (head_ic_ptr->head == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading initial head condition %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 3:				/* mask */
			if (head_ic_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"initial head condition %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (head_ic_ptr->mask != NULL)
			{
				sprintf(error_string,
						"Mask for this zone is being redefined %s", tag);
				warning_msg(error_string);
				property_free(head_ic_ptr->mask);
				head_ic_ptr->mask = NULL;
			}
			head_ic_ptr->mask =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (head_ic_ptr->mask == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading mask %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 4:				/* wedge */
			/*
			 *   Allocate space for head_ic, read zone data
			 */
			head_ic =
				(struct Head_ic **) realloc(head_ic,
											(size_t) (count_head_ic +
													  1) *
											sizeof(struct Head_ic *));
			if (head_ic == NULL)
				malloc_error();

			head_ic[count_head_ic] = head_ic_alloc();
			head_ic_ptr = head_ic[count_head_ic];
			count_head_ic++;
			sprintf(tag, "in HEAD_IC, definition %d.", count_head_ic);
			head_ic_init(head_ic_ptr);

			head_ic_ptr->polyh = read_wedge(&next_char);
			{
				Wedge *w_ptr = dynamic_cast < Wedge * >(head_ic_ptr->polyh);
				if (head_ic_ptr->polyh == NULL
					|| w_ptr->orientation == Wedge::WEDGE_ERROR)
				{
					input_error++;
					sprintf(error_string, "Reading wedge %s", tag);
					error_msg(error_string, CONTINUE);
				}
			}
			head_ic_ptr->ic_type = ZONE;
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 5:				/* prism */
			{
				/*
				 *   Allocate space for head_ic, read zone data
				 */
				head_ic =
					(struct Head_ic **) realloc(head_ic,
												(size_t) (count_head_ic +
														  1) *
												sizeof(struct Head_ic *));
				if (head_ic == NULL)
					malloc_error();

				head_ic[count_head_ic] = head_ic_alloc();
				head_ic_ptr = head_ic[count_head_ic];
				count_head_ic++;
				sprintf(tag, "in HEAD_IC, definition %d.", count_head_ic);
				head_ic_init(head_ic_ptr);
				prism_ptr = new Prism;
				head_ic_ptr->polyh = prism_ptr;
				head_ic_ptr->ic_type = ZONE;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}

		case 6:				/* vector */
		case 7:				/* perimeter */
		case 8:				/* top */
		case 9:				/* bottom */
			{
				std::istringstream lines;
				// opt = streamify_to_next_keyword_or_option(opt_list,
				//										count_opt_list,
				//										lines);
				opt = streamify_prism_piece(opt_list,
					count_opt_list,
					lines);
				if (head_ic_ptr == NULL || head_ic_ptr->polyh == NULL
					|| prism_ptr == NULL || !prism_ptr->Read(lines))
				{
					input_error++;
					sprintf(error_string, "Reading prism %s", tag);
					error_msg(error_string, CONTINUE);
					break;
				}
			}
			break;
		case 10:				/* description */
			/* read description */
			if (head_ic_ptr == NULL)
			{
				sprintf(error_string,
						"Zone, wedge, or prism has not been defined for description %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (head_ic_ptr->polyh->Get_description()->size() != 0)
			{
				sprintf(error_string, "Description has been redefined %s",
						tag);
				warning_msg(error_string);
				head_ic_ptr->polyh->Get_description()->clear();
			}
			//std::string str(next_char);
			head_ic_ptr->polyh->Get_description()->assign(next_char);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"HEAD_IC can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_chemistry_ic(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads chemistry initial conditions 
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	char *next_char;
	struct chem_ic *chem_ic_ptr;
	int return_value, opt;
	int l;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"zone",					/* 0 */
		"solution",				/* 1 */
		"equilibrium_phases",	/* 2 */
		"pure_phases",			/* 3 */
		"phases",				/* 4 */
		"exchange",				/* 5 */
		"surface",				/* 6 */
		"gas_phase",			/* 7 */
		"solid_solution",		/* 8 */
		"kinetics",				/* 9 */
		"solid_solutions",		/* 10 */
		"mask",					/* 11 */
		"wedge",				/* 12 */
		"prism",				/* 13 */
		"vector",				/* 14 */
		"perimeter",			/* 15 */
		"top",					/* 16 */
		"bottom",				/* 17 */
		"description"			/* 18 */
		,"box"                  /* 19 */
	};
	int count_opt_list = 20;
	/*
	 *   Read chemical initial condition data
	 */
	return_value = UNKNOWN;
	chem_ic_ptr = NULL;
	Prism *prism_ptr = NULL;
	/*
	 *   get first line
	 */
	sprintf(tag, "in CHEMISTRY_IC, definition %d.", count_chem_ic);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* zone */
		case 19:			/* box */
			/*
			 *   Allocate space for chem_ic, read zone data
			 */
			chem_ic =
				(struct chem_ic **) realloc(chem_ic,
											(size_t) (count_chem_ic +
													  1) *
											sizeof(struct chem_ic *));
			if (chem_ic == NULL)
				malloc_error();

			chem_ic[count_chem_ic] = chem_ic_alloc();
			chem_ic_ptr = chem_ic[count_chem_ic];
			count_chem_ic++;
			sprintf(tag, "in CHEMISTRY_IC, definition %d.", count_chem_ic);
			chem_ic_init(chem_ic_ptr);

			chem_ic_ptr->polyh = read_cube(&next_char);
			if (chem_ic_ptr->polyh == NULL)
			{
				sprintf(error_string, "Reading zone %s", tag);
				error_msg(error_string, CONTINUE);
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 1:				/* solution */
			/*
			 *   Read solution number as property
			 */
			if (chem_ic_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for initial solution %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (chem_ic_ptr->solution != NULL)
			{
				sprintf(error_string,
						"Initial solution has been redefined %s", tag);
				warning_msg(error_string);
				property_free(chem_ic_ptr->solution);
				chem_ic_ptr->solution = NULL;
			}
			chem_ic_ptr->solution =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  TRUE);
			if (chem_ic_ptr->solution == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading initial solution %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 2:				/* equilibrium_phases */
		case 3:				/* pure_phases */
		case 4:				/* phases */
			/*
			 *   Read equilibrium_phases number as property
			 */
			if (chem_ic_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for initial equilibrium_phases %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (chem_ic_ptr->equilibrium_phases != NULL)
			{
				sprintf(error_string,
						"Initial equiluilibrium_phases have been redefined %s",
						tag);
				warning_msg(error_string);
				property_free(chem_ic_ptr->equilibrium_phases);
				chem_ic_ptr->equilibrium_phases = NULL;
			}
			chem_ic_ptr->equilibrium_phases =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  TRUE);
			if (chem_ic_ptr->equilibrium_phases == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading initial equilibrium_phases %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 5:				/* exchange */
			/*
			 *   Read exchange number as property
			 */
			if (chem_ic_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for initial exchange assemblage %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (chem_ic_ptr->exchange != NULL)
			{
				sprintf(error_string,
						"Initial exchange assemblage has been redefined %s",
						tag);
				warning_msg(error_string);
				property_free(chem_ic_ptr->exchange);
				chem_ic_ptr->exchange = NULL;
			}
			chem_ic_ptr->exchange =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  TRUE);
			if (chem_ic_ptr->exchange == NULL)
			{
				input_error++;
				sprintf(error_string,
						"Reading initial exchange assemblage %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 6:				/* surface */
			/*
			 *   Read surface number as property
			 */
			if (chem_ic_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for initial surface assemblage %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (chem_ic_ptr->surface != NULL)
			{
				sprintf(error_string,
						"Initial surface assemblage has been redefined %s",
						tag);
				warning_msg(error_string);
				property_free(chem_ic_ptr->surface);
				chem_ic_ptr->surface = NULL;
			}
			chem_ic_ptr->surface =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  TRUE);
			if (chem_ic_ptr->surface == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading initial surface assemblage %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 7:				/* gas_phase */
			/*
			 *   Read gas_phase number as property
			 */
			if (chem_ic_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for initial gas_phase %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (chem_ic_ptr->gas_phase != NULL)
			{
				sprintf(error_string,
						"Initial gas_phase has been redefined %s", tag);
				warning_msg(error_string);
				property_free(chem_ic_ptr->gas_phase);
				chem_ic_ptr->gas_phase = NULL;
			}
			chem_ic_ptr->gas_phase =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  TRUE);
			if (chem_ic_ptr->gas_phase == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading initial gas_phase %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 8:				/* solid_solution */
		case 10:				/* solid_solutions */
			/*
			 *   Read solid_solution number as property
			 */
			if (chem_ic_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for initial solid_solution %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (chem_ic_ptr->solid_solutions != NULL)
			{
				sprintf(error_string,
						"Initial solid_solution has been redefined %s", tag);
				warning_msg(error_string);
				property_free(chem_ic_ptr->solid_solutions);
				chem_ic_ptr->solid_solutions = NULL;
			}
			chem_ic_ptr->solid_solutions =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  TRUE);
			if (chem_ic_ptr->solid_solutions == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading initial solid_solution %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 9:				/* kinetics */
			/*
			 *   Read kinetics number as property
			 */
			if (chem_ic_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for initial kinetics %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (chem_ic_ptr->kinetics != NULL)
			{
				sprintf(error_string,
						"Initial kinetics has been redefined %s", tag);
				warning_msg(error_string);
				property_free(chem_ic_ptr->kinetics);
				chem_ic_ptr->kinetics = NULL;
			}
			chem_ic_ptr->kinetics =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  TRUE);
			if (chem_ic_ptr->kinetics == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading initial kinetics %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 11:				/* mask */
			if (chem_ic_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"initial chemistry condition %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (chem_ic_ptr->mask != NULL)
			{
				sprintf(error_string,
						"Mask for this zone is being redefined %s", tag);
				warning_msg(error_string);
				property_free(chem_ic_ptr->mask);
				chem_ic_ptr->mask = NULL;
			}
			chem_ic_ptr->mask =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (chem_ic_ptr->mask == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading mask %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 12:				/* wedge */
			/*
			 *   Allocate space for chem_ic, read wedge data
			 */
			chem_ic =
				(struct chem_ic **) realloc(chem_ic,
											(size_t) (count_chem_ic +
													  1) *
											sizeof(struct chem_ic *));
			if (chem_ic == NULL)
				malloc_error();

			chem_ic[count_chem_ic] = chem_ic_alloc();
			chem_ic_ptr = chem_ic[count_chem_ic];
			count_chem_ic++;
			sprintf(tag, "in CHEMISTRY_IC, definition %d.", count_chem_ic);
			chem_ic_init(chem_ic_ptr);

			chem_ic_ptr->polyh = read_wedge(&next_char);
			{
				Wedge *w_ptr = dynamic_cast < Wedge * >(chem_ic_ptr->polyh);
				if (chem_ic_ptr->polyh == NULL
					|| w_ptr->orientation == Wedge::WEDGE_ERROR)
				{
					input_error++;
					sprintf(error_string, "Reading wedge %s", tag);
					error_msg(error_string, CONTINUE);
				}
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 13:				/* prism */
			{
				/*
				 *   Allocate space for chem_ic, read wedge data
				 */
				chem_ic =
					(struct chem_ic **) realloc(chem_ic,
												(size_t) (count_chem_ic +
														  1) *
												sizeof(struct chem_ic *));
				if (chem_ic == NULL)
					malloc_error();

				chem_ic[count_chem_ic] = chem_ic_alloc();
				chem_ic_ptr = chem_ic[count_chem_ic];
				count_chem_ic++;
				sprintf(tag, "in CHEMISTRY_IC, definition %d.",
						count_chem_ic);
				chem_ic_init(chem_ic_ptr);

				prism_ptr = new Prism;
				chem_ic_ptr->polyh = prism_ptr;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}

		case 14:				/* vector */
		case 15:				/* perimeter */
		case 16:				/* top */
		case 17:				/* bottom */
			{
				std::istringstream lines;
				// opt = streamify_to_next_keyword_or_option(opt_list,
				//										count_opt_list,
				//										lines);
				opt = streamify_prism_piece(opt_list,
					count_opt_list,
					lines);
				if (chem_ic_ptr == NULL || chem_ic_ptr->polyh == NULL
					|| prism_ptr == NULL || !prism_ptr->Read(lines))
				{
					input_error++;
					sprintf(error_string, "Reading prism %s", tag);
					error_msg(error_string, CONTINUE);
					break;
				}
			}
			break;
		case 18:				/* description */
			/* read description */
			if (chem_ic_ptr == NULL)
			{
				sprintf(error_string,
						"Zone, wedge, or prism has not been defined for description %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (chem_ic_ptr->polyh->Get_description()->size() != 0)
			{
				sprintf(error_string, "Description has been redefined %s",
						tag);
				warning_msg(error_string);
				chem_ic_ptr->polyh->Get_description()->clear();
			}
			//std::string str(next_char);
			chem_ic_ptr->polyh->Get_description()->assign(next_char);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"CHEMISTRY_IC can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_free_surface_bc(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Define free surface boundary condition
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	int j, l;
	char *next_char, *ptr;
	int return_value, opt;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"adjust_water_rock_ratio"	/* 0 */
	};
	int count_opt_list = 1;

	ptr = line;
	/* read keyword */
	j = copy_token(token, &ptr, &l);

	/* read true or false */
	free_surface = get_true_false(ptr, TRUE);
	/*
	 *   get first line
	 */
	sprintf(tag, "in FREE_SURFACE, definition.");
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* adjust_water_rock_ratio */
			warning_msg
				("Adjust_water_rock_ratio is obsolete, value is always TRUE.");
			/*adjust_water_rock_ratio = get_true_false(ptr, TRUE); */
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"FREE_SURFACE can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
read_flow(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads chemistry initial conditions 
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	char *next_char, *ptr;
	int return_value, opt;
	int j, l;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"flow_only",			/* 0 */
		"steady_flow",			/* 1 */
		"head_tol",				/* 2 */
		"head_tolerance",		/* 3 */
		"flow_tol",				/* 4 */
		"flow_tolerance",		/* 5 */
		"flow_balance_tol",		/* 6 */
		"flow_balance_tolerance"	/* 7 */
	};
	int count_opt_list = 8;
	/*
	 *   Read flow information
	 */
	return_value = UNKNOWN;
	/*
	 *   get first line
	 */
	sprintf(tag, "in FLOW, definition %d.", count_chem_ic);
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* flow_only */
			flow_only = get_true_false(next_char, TRUE);
			break;
		case 1:				/* steady_flow */
			steady_flow = get_true_false(next_char, TRUE);
			break;
		case 2:				/* head_tol */
		case 3:				/* head_tolerance */
			ptr = next_char;
			j = copy_token(token, &ptr, &l);
			if (j == DIGIT)
			{
				sscanf(token, "%lf", &eps_head);
			}
			else if (j != EMPTY)
			{
				sprintf(error_string,
						"Expected tolerance for head in steady-state flow: %s",
						line);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			break;
		case 4:				/* flow_tol */
		case 5:				/* flow_tolerance */
		case 6:				/* flow_balance_tol */
		case 7:				/* flow_balance_tolerance */
			ptr = next_char;
			j = copy_token(token, &ptr, &l);
			if (j == DIGIT)
			{
				sscanf(token, "%lf", &eps_mass_balance);
			}
			else if (j != EMPTY)
			{
				sprintf(error_string,
						"Expected tolerance for mass balance in steady-state flow: %s",
						line);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"FLOW can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
read_flow_only(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Define flow only
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	char *next_char, *ptr;
	int return_value, opt;
	int j, l;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"diffusivity"			/* 0 */
	};
	int count_opt_list = 1;
	warning_msg("FLOW_ONLY is obsolete, use SOLUTE_TRANSPORT.");
	/*
	 *  Set true false
	 */
	ptr = line;
	/* read keyword */
	j = copy_token(token, &ptr, &l);

	/* read true or false */
	flow_only = get_true_false(ptr, TRUE);
	/*
	 *   get first line
	 */
	sprintf(tag, "in FLOW_ONLY, definition.");
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* diffusivity */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%lf", &fluid_diffusivity) != 1))
			{
				input_error++;
				sprintf(error_string,
						"Expected molecular diffusivity (m^2/s) in FLUID_PROPERTIES.");
				error_msg(error_string, CONTINUE);
			}
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"FLOW_ONLY can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_solute_transport(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Define flow only
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	char *next_char, *ptr;
	int return_value, opt;
	int j, l;
	int solute_transport;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"diffusivity"			/* 0 */
	};
	int count_opt_list = 1;
	/*
	 *  Set true false
	 */
	ptr = line;
	/* read keyword */
	j = copy_token(token, &ptr, &l);

	/* read true or false */
	solute_transport = get_true_false(ptr, TRUE);
	/* reverse sense of SOLUTE_TRANSPORT for flow_only */
	if (solute_transport == TRUE)
	{
		flow_only = FALSE;
	}
	else
	{
		flow_only = TRUE;
	}
	/*
	 *   get first line
	 */
	sprintf(tag, "in SOLUTE_TRANSPORT, definition.");
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* diffusivity */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%lf", &fluid_diffusivity) != 1))
			{
				input_error++;
				sprintf(error_string,
						"Expected molecular diffusivity (m^2/s) in FLUID_PROPERTIES.");
				error_msg(error_string, CONTINUE);
			}
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"SOLUTE_TRANSPORT can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_specified_value_bc(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads specified value boundary conditions
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	char *next_char;
	struct BC *bc_ptr;
	int return_value, opt;
	int j, l;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"zone",					/* 0 */
		"head",					/* 1 */
		"fixed_solution_composition",	/* 2 */
		"associated_solution_composition",	/* 3 */
		"fixed_solution",		/* 4 */
		"fixed",				/* 5 */
		"associated_solution",	/* 6 */
		"associated",			/* 7 */
		"mask",					/* 8 */
		"wedge",				/* 9 */
		"prism",				/* 10 */
		"vector",				/* 11 */
		"perimeter",			/* 12 */
		"top",					/* 13 */
		"bottom",				/* 14 */
		"description",			/* 15 */
		"exterior_cells_only"   /* 16 */
		,"box"                  /* 17 */
	};
	int count_opt_list = 18;
	/*
	 *   Read chemical initial condition data
	 */
	bc_specified_defined = TRUE;
	return_value = UNKNOWN;
	bc_ptr = NULL;
	Prism *prism_ptr = NULL;
	/*
	 *   get first line
	 */
	sprintf(tag, "in SPECIFIED_HEAD_BC, definition %d.", count_specified + 1);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* zone */
		case 17:			/* box */
			/*
			 *   Allocate space for bc, read zone data
			 */
			bc = (struct BC **) realloc(bc,
										(size_t) (count_bc +
												  1) * sizeof(struct BC *));
			if (bc == NULL)
				malloc_error();

			bc[count_bc] = bc_alloc();
			bc_ptr = bc[count_bc];
			bc_init(bc_ptr);
			bc_ptr->bc_type = BC_info::BC_SPECIFIED;
			count_specified++;
			sprintf(tag, "in SPECIFIED_HEAD_BC, definition %d.",
					count_specified);
			count_bc++;

			bc_ptr->polyh = read_cube(&next_char);
			if (bc_ptr->polyh == NULL)
			{
				sprintf(error_string, "Reading zone %s", tag);
				error_msg(error_string, CONTINUE);
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 1:				/* head */
			/*
			 *   Read head property
			 */
			if (simulation > 0 && steady_flow == TRUE)
			{
				input_error++;
				sprintf(error_string,
						"Head for specified value boundary condition can not be changed in STEADY_FLOW calculations.");
				error_msg(error_string, CONTINUE);
			}
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for head %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->bc_head != NULL)
			{
				sprintf(error_string, "Head has been redefined %s", tag);
				warning_msg(error_string);
				time_series_free(bc_ptr->bc_head);
				free_check_null(bc_ptr->bc_head);
				bc_ptr->bc_head = NULL;
			}
			bc_ptr->bc_head =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (bc_ptr->bc_head == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading head %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			break;
		case 2:				/* fixed solution composition */
		case 4:				/* fixed solution */
		case 5:				/* fixed  */
			/*
			 *   Read solution property
			 */
			if (bc_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for solution %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->bc_solution != NULL)
			{
				sprintf(error_string, "Solution has been redefined %s", tag);
				warning_msg(error_string);
				time_series_free(bc_ptr->bc_solution);
				free_check_null(bc_ptr->bc_solution);
				bc_ptr->bc_solution = NULL;
			}
			bc_ptr->bc_solution_type = FIXED;
			bc_ptr->bc_solution =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (bc_ptr->bc_solution == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading solution %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			break;
		case 3:				/* associated solution composition */
		case 6:				/* associated solution */
		case 7:				/* associated */
			/*
			 *   Read associated solution property
			 */
			if (bc_ptr == NULL)
			{
				sprintf(error_string,
						"Zone has not been defined for associated solution %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->bc_solution != NULL)
			{
				sprintf(error_string,
						"Associated solution has been redefined %s", tag);
				warning_msg(error_string);
				time_series_free(bc_ptr->bc_solution);
				free_check_null(bc_ptr->bc_solution);
				bc_ptr->bc_solution = NULL;
			}
			bc_ptr->bc_solution_type = ASSOCIATED;
			bc_ptr->bc_solution =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (bc_ptr->bc_solution == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading associated solution %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			break;
		case 8:				/* mask */
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"mask %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->mask != NULL)
			{
				sprintf(error_string,
						"Mask for this zone is being redefined %s", tag);
				warning_msg(error_string);
				property_free(bc_ptr->mask);
				bc_ptr->mask = NULL;
			}
			bc_ptr->mask =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (bc_ptr->mask == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading mask %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 9:				/* wedge */
			{
				/*
				 *   Allocate space for bc, read wedge data
				 */
				bc = (struct BC **) realloc(bc,
											(size_t) (count_bc +
													  1) *
											sizeof(struct BC *));
				if (bc == NULL)
					malloc_error();

				bc[count_bc] = bc_alloc();
				bc_ptr = bc[count_bc];
				bc_init(bc_ptr);
				bc_ptr->bc_type = BC_info::BC_SPECIFIED;
				count_specified++;
				sprintf(tag, "in SPECIFIED_HEAD_BC, definition %d.",
						count_specified);
				count_bc++;

				bc_ptr->polyh = read_wedge(&next_char);
				Wedge *w_ptr = dynamic_cast < Wedge * >(bc_ptr->polyh);
				if (bc_ptr->polyh == NULL
					|| w_ptr->orientation == Wedge::WEDGE_ERROR)
				{
					input_error++;
					sprintf(error_string, "Reading wedge %s", tag);
					error_msg(error_string, CONTINUE);
				}
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
		case 10:				/* prism */
			{
				bc = (struct BC **) realloc(bc,
											(size_t) (count_bc +
													  1) *
											sizeof(struct BC *));
				if (bc == NULL)
					malloc_error();

				bc[count_bc] = bc_alloc();
				bc_ptr = bc[count_bc];
				bc_init(bc_ptr);
				bc_ptr->bc_type = BC_info::BC_SPECIFIED;
				count_specified++;
				sprintf(tag, "in SPECIFIED_HEAD_BC, definition %d.",
						count_specified);
				count_bc++;

				prism_ptr = new Prism;
				bc_ptr->polyh = prism_ptr;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}

		case 11:				/* vector */
		case 12:				/* perimeter */
		case 13:				/* top */
		case 14:				/* bottom */
			{
				std::istringstream lines;
				// opt = streamify_to_next_keyword_or_option(opt_list,
				//										count_opt_list,
				//										lines);
				opt = streamify_prism_piece(opt_list,
					count_opt_list,
					lines);
				if (bc_ptr == NULL || bc_ptr->polyh == NULL
					|| prism_ptr == NULL || !prism_ptr->Read(lines))
				{
					input_error++;
					sprintf(error_string, "Reading prism %s", tag);
					error_msg(error_string, CONTINUE);
					break;
				}
			}
			break;
		case 15:				/* description */
			/* read description */
			if (bc_ptr == NULL)
			{
				sprintf(error_string,
						"Zone, wedge, or prism has not been defined for description %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->polyh->Get_description()->size() != 0)
			{
				sprintf(error_string, "Description has been redefined %s",
						tag);
				warning_msg(error_string);
				bc_ptr->polyh->Get_description()->clear();
			}
			//std::string str(next_char);
			bc_ptr->polyh->Get_description()->assign(next_char);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 16:				/* exterior_cells_only */
			/*
			 *   Read face for flux
			 */
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"exterior cell definition %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			str_tolower(token);
			if (strcmp(token, "x") == 0)
			{
				bc_ptr->face = 0;
				bc_ptr->cell_face = CF_X;
			}
			else if (strcmp(token, "y") == 0)
			{
				bc_ptr->face = 1;
				bc_ptr->cell_face = CF_Y;
			}
			else if (strcmp(token, "z") == 0)
			{
				bc_ptr->face = 2;
				bc_ptr->cell_face = CF_Z;
			}
			else if (strstr(token, "a") == token)
			{
				bc_ptr->face = 11;
				bc_ptr->cell_face = CF_ALL;
			}
			else
			{
				input_error++;
				sprintf(error_string,
						"Expected coordinate direction (X, Y, Z, or all) for exterior cell selection %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			bc_ptr->face_defined = TRUE;
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_flux_bc(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads flux boundary conditions
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	char *next_char;
	struct BC *bc_ptr;
	int return_value, opt;
	int j, l;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"zone",					/* 0 */
		"flux",					/* 1 */
		"associated_solution",	/* 2 */
		"face",					/* 3 */
		"solution",				/* 4 */
		"mask",					/* 5 */
		"wedge",				/* 6 */
		"prism",				/* 7 */
		"vector",				/* 8 */
		"perimeter",			/* 9 */
		"top",					/* 10 */
		"bottom",				/* 11 */
		"description"			/* 12 */
		,"box"                  /* 13 */
	};
	int count_opt_list = 14;
	/*
	 *   Read flux boundary condition
	 */
	bc_flux_defined = TRUE;
	return_value = UNKNOWN;
	bc_ptr = NULL;
	Prism *prism_ptr = NULL;
	/*
	 *   get first line
	 */
	sprintf(tag, "in FLUX_BC, definition %d.", count_flux + 1);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:			/* zone */
		case 13:		/* box */
			/*
			 *   Allocate space for bc, read zone data
			 */
			bc = (struct BC **) realloc(bc,
										(size_t) (count_bc +
												  1) * sizeof(struct BC *));
			if (bc == NULL)
				malloc_error();

			bc[count_bc] = bc_alloc();
			bc_ptr = bc[count_bc];
			bc_init(bc_ptr);
			bc_ptr->bc_type = BC_info::BC_FLUX;
			count_flux++;
			sprintf(tag, "in FLUX_BC, definition %d.", count_flux);
			count_bc++;

			/* read zone */
			bc_ptr->polyh = read_cube(&next_char);
			if (bc_ptr->polyh == NULL)
			{
				sprintf(error_string, "Reading zone %s", tag);
				error_msg(error_string, CONTINUE);
			}
			/* read to next */
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 1:				/* flux */
			/*
			 *   Read flux property
			 */
			if (simulation > 0 && steady_flow == TRUE)
			{
				input_error++;
				sprintf(error_string,
						"Flux for specified flux boundary condition can not be changed in STEADY_FLOW calculations.");
				error_msg(error_string, CONTINUE);
			}
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"flux %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->bc_flux != NULL)
			{
				sprintf(error_string, "Flux has been redefined %s", tag);
				warning_msg(error_string);
				time_series_free(bc_ptr->bc_flux);
				free_check_null(bc_ptr->bc_flux);
				bc_ptr->bc_flux = NULL;
			}
			bc_ptr->bc_flux =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (bc_ptr->bc_flux == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading flux %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			break;
		case 2:				/* associated solution */
		case 4:				/* solution */
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"associated solution %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->bc_solution != NULL)
			{
				sprintf(error_string,
						"Associated solution has been redefined %s", tag);
				warning_msg(error_string);
				time_series_free(bc_ptr->bc_solution);
				free_check_null(bc_ptr->bc_solution);
				bc_ptr->bc_solution = NULL;
			}
			bc_ptr->bc_solution_type = ASSOCIATED;
			bc_ptr->bc_solution =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (bc_ptr->bc_solution == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading associated solution %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			break;
		case 3:				/* face */
			/*
			 *   Read face for flux
			 */
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"flux face %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			str_tolower(token);
			if (strcmp(token, "x") == 0)
			{
				bc_ptr->face = 0;
				bc_ptr->cell_face = CF_X;
			}
			else if (strcmp(token, "y") == 0)
			{
				bc_ptr->face = 1;
				bc_ptr->cell_face = CF_Y;
			}
			else if (strcmp(token, "z") == 0)
			{
				bc_ptr->face = 2;
				bc_ptr->cell_face = CF_Z;
			}
			else
			{
				input_error++;
				sprintf(error_string,
						"Expected coordinate direction (X, Y, or Z) for flux face %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			bc_ptr->face_defined = TRUE;
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 5:				/* mask */
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"mask %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->mask != NULL)
			{
				sprintf(error_string,
						"Mask for this zone is being redefined %s", tag);
				warning_msg(error_string);
				property_free(bc_ptr->mask);
				bc_ptr->mask = NULL;
			}
			bc_ptr->mask =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (bc_ptr->mask == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading mask %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 6:				/* wedge */
			/*
			 *   Allocate space for bc, read wedge data
			 */
			bc = (struct BC **) realloc(bc,
										(size_t) (count_bc +
												  1) * sizeof(struct BC *));
			if (bc == NULL)
				malloc_error();

			bc[count_bc] = bc_alloc();
			bc_ptr = bc[count_bc];
			bc_init(bc_ptr);
			bc_ptr->bc_type = BC_info::BC_FLUX;
			count_flux++;
			sprintf(tag, "in FLUX_BC, definition %d.", count_flux);
			count_bc++;

			/* read wedge */
			bc_ptr->polyh = read_wedge(&next_char);
			{
				Wedge *w_ptr = dynamic_cast < Wedge * >(bc_ptr->polyh);
				if (bc_ptr->polyh == NULL
					|| w_ptr->orientation == Wedge::WEDGE_ERROR)
				{
					input_error++;
					sprintf(error_string, "Reading wedge %s", tag);
					error_msg(error_string, CONTINUE);
				}
			}
			/* read to next */
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 7:				/* prism */
			{
				bc = (struct BC **) realloc(bc,
											(size_t) (count_bc +
													  1) *
											sizeof(struct BC *));
				if (bc == NULL)
					malloc_error();

				bc[count_bc] = bc_alloc();
				bc_ptr = bc[count_bc];
				bc_init(bc_ptr);
				bc_ptr->bc_type = BC_info::BC_FLUX;
				count_flux++;
				sprintf(tag, "in FLUX_BC, definition %d.", count_flux);
				count_bc++;

				prism_ptr = new Prism;
				bc_ptr->polyh = prism_ptr;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}

		case 8:				/* vector */
		case 9:				/* perimeter */
		case 10:				/* top */
		case 11:				/* bottom */
			{
				std::istringstream lines;
				// opt = streamify_to_next_keyword_or_option(opt_list,
				//										count_opt_list,
				//										lines);
				opt = streamify_prism_piece(opt_list,
					count_opt_list,
					lines);
				if (bc_ptr == NULL || bc_ptr->polyh == NULL
					|| prism_ptr == NULL || !prism_ptr->Read(lines))
				{
					input_error++;
					sprintf(error_string, "Reading prism %s", tag);
					error_msg(error_string, CONTINUE);
					break;
				}
			}
			break;
		case 12:				/* description */
			/* read description */
			if (bc_ptr == NULL)
			{
				sprintf(error_string,
						"Zone, wedge, or prism has not been defined for description %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->polyh->Get_description()->size() != 0)
			{
				sprintf(error_string, "Description has been redefined %s",
						tag);
				warning_msg(error_string);
				bc_ptr->polyh->Get_description()->clear();
			}
			//std::string str(next_char);
			bc_ptr->polyh->Get_description()->assign(next_char);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_leaky_bc(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads leaky boundary conditions
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	char *next_char;
	struct BC *bc_ptr;
	int return_value, opt;
	int j, l;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"zone",					/* 0 */
		"head",					/* 1 */
		"associated_solution",	/* 2 */
		"hydraulic_conductivity",	/* 3 */
		"k",					/* 4 */
		"thickness",			/* 5 */
		"face",					/* 6 */
		"solution",				/* 7 */
		"mask",					/* 8 */
		"wedge",				/* 9 */
		"prism",				/* 10 */
		"vector",				/* 11 */
		"perimeter",			/* 12 */
		"top",					/* 13 */
		"bottom",				/* 14 */
		"description"			/* 15 */
		,"box"                  /* 16 */
	};
	int count_opt_list = 17;
	/*
	 *   Read chemical initial condition data
	 */
	bc_leaky_defined = TRUE;
	return_value = UNKNOWN;
	bc_ptr = NULL;
	Prism *prism_ptr = NULL;
	/*
	 *   get first line
	 */
	sprintf(tag, "in LEAKY_BC, definition %d.", count_leaky + 1);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* zone */
		case 16:			/* box */
			/*
			 *   Allocate space for bc, read zone data
			 */
			bc = (struct BC **) realloc(bc,
										(size_t) (count_bc +
												  1) * sizeof(struct BC *));
			if (bc == NULL)
				malloc_error();
			bc[count_bc] = bc_alloc();
			bc_ptr = bc[count_bc];
			bc_init(bc_ptr);
			bc_ptr->bc_type = BC_info::BC_LEAKY;
			count_leaky++;
			sprintf(tag, "in LEAKY_BC, definition %d.", count_leaky);
			count_bc++;

			bc_ptr->polyh = read_cube(&next_char);
			if (bc_ptr->polyh == NULL)
			{
				sprintf(error_string, "Reading zone %s", tag);
				error_msg(error_string, CONTINUE);
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 1:				/* head */
			/*
			 *   Read head property
			 */
			if (simulation > 0 && steady_flow == TRUE)
			{
				input_error++;
				sprintf(error_string,
						"Head for leaky boundary condition can not be changed in STEADY_FLOW calculations.");
				error_msg(error_string, CONTINUE);
			}
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"head %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->bc_head != NULL)
			{
				sprintf(error_string, "Head has been redefined %s", tag);
				warning_msg(error_string);
				time_series_free(bc_ptr->bc_head);
				free_check_null(bc_ptr->bc_head);
				bc_ptr->bc_head = NULL;
			}
			bc_ptr->bc_head =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (bc_ptr->bc_head == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading head %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			break;
		case 2:				/* associated solution */
		case 7:				/* solution */
			/*
			 *   Read associated solution property
			 */
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"associated solution %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->bc_solution != NULL)
			{
				sprintf(error_string,
						"Associated solution has been redefined %s", tag);
				warning_msg(error_string);
				time_series_free(bc_ptr->bc_solution);
				free_check_null(bc_ptr->bc_solution);
				bc_ptr->bc_solution = NULL;
			}
			bc_ptr->bc_solution_type = ASSOCIATED;
			bc_ptr->bc_solution =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (bc_ptr->bc_solution == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading associated solution %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			break;
		case 3:				/* hydraulic conductivity */
		case 4:				/* k */
			/*
			 *   Read hydraulic conductivity
			 */
			if (simulation > 0)
			{
				input_error++;
				sprintf(error_string,
						"Hydraulic conductivity can only be defined in first simulation period\n\t%s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"hydraulic conductivity %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->bc_k != NULL)
			{
				sprintf(error_string,
						"Hydraulic conductivity has been redefined %s", tag);
				warning_msg(error_string);
				property_free(bc_ptr->bc_k);
				bc_ptr->bc_k = NULL;
			}
			bc_ptr->bc_k =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (bc_ptr->bc_k == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading hydraulic conductivity %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 5:				/* thickness */
			/*
			 *   Read thickness
			 */
			if (simulation > 0)
			{
				input_error++;
				sprintf(error_string,
						"Thickness can only be defined in first simulation period %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"thickness %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->bc_thick != NULL)
			{
				sprintf(error_string, "Thickness has been redefined %s", tag);
				warning_msg(error_string);
				property_free(bc_ptr->bc_thick);
				bc_ptr->bc_thick = NULL;
			}
			bc_ptr->bc_thick =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (bc_ptr->bc_thick == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading thickness %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 6:				/* face */
			/*
			 *   Read face for flux
			 */
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"flux face %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			str_tolower(token);
			if (strcmp(token, "x") == 0)
			{
				bc_ptr->face = 0;
				bc_ptr->cell_face = CF_X;
			}
			else if (strcmp(token, "y") == 0)
			{
				bc_ptr->face = 1;
				bc_ptr->cell_face = CF_Y;
			}
			else if (strcmp(token, "z") == 0)
			{
				bc_ptr->face = 2;
				bc_ptr->cell_face = CF_Z;
			}
			else
			{
				input_error++;
				sprintf(error_string,
						"Expected coordinate direction (X, Y, or Z) for flux face %s",
						tag);
				error_msg(error_string, CONTINUE);
			}
			bc_ptr->face_defined = TRUE;
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 8:				/* mask */
			if (bc_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"mask %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->mask != NULL)
			{
				sprintf(error_string,
						"Mask for this zone is being redefined %s", tag);
				warning_msg(error_string);
				property_free(bc_ptr->mask);
				bc_ptr->mask = NULL;
			}
			bc_ptr->mask =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (bc_ptr->mask == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading mask %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 9:				/* wedge */
			/*
			 *   Allocate space for bc, read wedge data
			 */
			bc = (struct BC **) realloc(bc,
										(size_t) (count_bc +
												  1) * sizeof(struct BC *));
			if (bc == NULL)
				malloc_error();
			bc[count_bc] = bc_alloc();
			bc_ptr = bc[count_bc];
			bc_init(bc_ptr);
			bc_ptr->bc_type = BC_info::BC_LEAKY;
			count_leaky++;
			sprintf(tag, "in LEAKY_BC, definition %d.", count_leaky);
			count_bc++;

			bc_ptr->polyh = read_wedge(&next_char);
			{
				Wedge *w_ptr = dynamic_cast < Wedge * >(bc_ptr->polyh);
				if (bc_ptr->polyh == NULL
					|| w_ptr->orientation == Wedge::WEDGE_ERROR)
				{
					input_error++;
					sprintf(error_string, "Reading wedge %s", tag);
					error_msg(error_string, CONTINUE);
				}
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 10:				/* prism */
			{
				bc = (struct BC **) realloc(bc,
											(size_t) (count_bc +
													  1) *
											sizeof(struct BC *));
				if (bc == NULL)
					malloc_error();
				bc[count_bc] = bc_alloc();
				bc_ptr = bc[count_bc];
				bc_init(bc_ptr);
				bc_ptr->bc_type = BC_info::BC_LEAKY;
				count_leaky++;
				sprintf(tag, "in LEAKY_BC, definition %d.", count_leaky);
				count_bc++;

				prism_ptr = new Prism;
				bc_ptr->polyh = prism_ptr;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}

		case 11:				/* vector */
		case 12:				/* perimeter */
		case 13:				/* top */
		case 14:				/* bottom */
			{
				std::istringstream lines;
				// opt = streamify_to_next_keyword_or_option(opt_list,
				//										count_opt_list,
				//										lines);
				opt = streamify_prism_piece(opt_list,
					count_opt_list,
					lines);
				if (bc_ptr == NULL || bc_ptr->polyh == NULL
					|| prism_ptr == NULL || !prism_ptr->Read(lines))
				{
					input_error++;
					sprintf(error_string, "Reading prism %s", tag);
					error_msg(error_string, CONTINUE);
					break;
				}
			}
			break;
		case 15:				/* description */
			/* read description */
			if (bc_ptr == NULL)
			{
				sprintf(error_string,
						"Zone, wedge, or prism has not been defined for description %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (bc_ptr->polyh->Get_description()->size() != 0)
			{
				sprintf(error_string, "Description has been redefined %s",
						tag);
				warning_msg(error_string);
				bc_ptr->polyh->Get_description()->clear();
			}
			//std::string str(next_char);
			bc_ptr->polyh->Get_description()->assign(next_char);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
struct property *
read_property(char *ptr, const char **opt_list, int count_opt_list, int *opt,
			  int delimited, int allow_restart)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads property data in any of 4 forms:
 *         (1) a single double value
 *         (A) xyz + value points in input file used for interpolation
 *         (B) xyz + value points in external file used for interpolation
 *         (2) X,Y, or Z followed by value1, dist1, value2, dist2
 *         (3) b[y_element] or b[y_cell] followed by list of doubles
 *             on same and (or) succeeding lines
 *         (4) f[ile] followed by file name
 *         (5) r[estart_file] followed by file name
 *
 *      Arguments:
 *         ptr    entry: points to line to read from
 *            
 *
 *      Returns:
 *         pointer to property structure
 */

	int j;
	char token[MAX_LENGTH];
	char *ptr1, *start_of_property, *start_of_data_source;
	enum MIX_STYLE
	{
		MIX_OLDSTYLE = 0,
		MIX_XYZ = 1,
		MIX_POINTS = 2,
		MIX_CONSTANT = 3,
		MIX_NUMERIC = 4,
		MIX_UNKNOWN = 5
	};
	MIX_STYLE style;

	int l;
	struct property *p;
	char *next_char;

	p = property_alloc();
	next_char = ptr;
	start_of_property = ptr;

	j = copy_token(token, &next_char, &l);
	str_tolower(token);
/*
 *   empty, keep reading
 */
	if (j == EMPTY)
	{
		property_free(p);
		p = NULL;
		*opt = next_keyword_or_option(opt_list, count_opt_list);
		return (NULL);
	}
	else if (j == DIGIT)
	{
/*
 *   digit, read one value, check rest of line is empty
 */
		sscanf(token, "%lf", &(p->v[0]));
		j = copy_token(token, &next_char, &l);
		p->type = PROP_FIXED;
		p->count_v = 1;
		if (j != EMPTY)
		{
			input_error++;
			error_msg("Expected single property value after identifier",
					  CONTINUE);
			error_msg(line, CONTINUE);
		}
		if (delimited == TRUE)
		{
			*opt = get_option(opt_list, count_opt_list, &next_char);
		}
		else
		{
			*opt = next_keyword_or_option(opt_list, count_opt_list);
		}
	}
	else if (strstr(token, "constant") == token
			 || strstr(token, "uniform") == token)
	{
/*
 *   digit, read one value, check rest of line is empty
 */
		j = copy_token(token, &next_char, &l);
		sscanf(token, "%lf", &(p->v[0]));
		p->type = PROP_FIXED;
		p->count_v = 1;
		if (j != DIGIT)
		{
			input_error++;
			error_msg("Expected single property value after identifier",
					  CONTINUE);
			error_msg(line, CONTINUE);
		}
		if (delimited == TRUE)
		{
			*opt = get_option(opt_list, count_opt_list, &next_char);
		}
		else
		{
			*opt = next_keyword_or_option(opt_list, count_opt_list);
		}
	}
	else if (strstr(token, "points") == token)
	{
/*
 *   read points for interpolation
 */
		p->type = PROP_POINTS;
		std::istringstream lines;
		*opt =
			streamify_to_next_keyword_or_option(opt_list, count_opt_list,
												lines, start_of_property, "end_p");

		// remove identifier
		// std::string str;
		// lines >> str;

		// remove initial line
		//char str[1000];
		//lines.getline(str, 1000);

		// read points into property Data_source
		p->data_source->Read(lines, false);
		//p->data_source->Set_columns( Read_points(lines, p->data_source->Get_points()) );
		if (p->data_source->Get_points().size() <= 0
			|| p->data_source->Get_columns() != 4)
		{
			input_error++;
			char estring[MAX_LENGTH];
			sprintf(estring,
					"Expected rows of x, y, z, value for property in input file.");
			error_msg(estring, CONTINUE);
		}
		properties_with_data_source.push_back(p);
	}
	else if (strstr(token, "xyz") == token)
	{
/*
 *   read from file for interpolation
 */
		p->type = PROP_XYZ;
		//std::string str("XYZ ");
		//str.append(next_char);
		//std::istringstream lines(str);
		std::istringstream lines(start_of_property);
		p->data_source->Read(lines, false);
		p->data_source->Tidy(false);
		//XYZfile xyz(p->data_source->Get_file_name(), p->data_source->Get_coordinate_system());

		// Data source has list of points
		//p->data_source->Set_points(xyz.Get_points(-1));
		//p->data_source->Set_columns(xyz.Get_columns());
		//std::vector<Point> & these_pts = p->data_source->Get_points();
		//int these_columns = p->data_source->Get_columns();
		if (p->data_source->Get_points().size() <= 0
			|| p->data_source->Get_columns() != 4)
		{
			input_error++;
			char estring[MAX_LENGTH];
			sprintf(estring,
					"Expected rows of x, y, z, value for property in file %s.",
					p->data_source->Get_file_name().c_str());
			error_msg(estring, CONTINUE);
		}
		properties_with_data_source.push_back(p);
		*opt = get_option(opt_list, count_opt_list, &next_char);

	}
	else if (token[0] == 'X' || token[0] == 'x')
	{
/*
 *   linear in x
 */
		p->coord = 'x';
		p->type = PROP_LINEAR;
		p->count_v = 2;
		if (sscanf
			(next_char, "%lf%lf%lf%lf", &p->v[0], &p->dist1, &p->v[1],
			 &p->dist2) != 4)
		{
			input_error++;
			error_msg
				("Expected: value, distance, value, distance in linear  property definition.",
				 CONTINUE);
		}
		if (p->dist1 > p->dist2)
		{
			double save_d, save_v;
			save_d = p->dist1;
			save_v = p->v[0];
			p->dist1 = p->dist2;
			p->v[0] = p->v[1];
			p->dist2 = save_d;
			p->v[1] = save_v;
		}
		if (delimited == TRUE)
		{
			*opt = get_option(opt_list, count_opt_list, &next_char);
		}
		else
		{
			*opt = next_keyword_or_option(opt_list, count_opt_list);
		}
	}
	else if (token[0] == 'Y' || token[0] == 'y')
	{
/*
 *   linear in y
 */
		p->coord = 'y';
		p->type = PROP_LINEAR;
		p->count_v = 2;
		if (sscanf
			(next_char, "%lf%lf%lf%lf", &p->v[0], &p->dist1, &p->v[1],
			 &p->dist2) != 4)
		{
			input_error++;
			error_msg
				("Expected: value, distance, value, distance in linear  property definition.",
				 CONTINUE);
		}
		if (p->dist1 > p->dist2)
		{
			double save_d, save_v;
			save_d = p->dist1;
			save_v = p->v[0];
			p->dist1 = p->dist2;
			p->v[0] = p->v[1];
			p->dist2 = save_d;
			p->v[1] = save_v;
		}
		if (delimited == TRUE)
		{
			*opt = get_option(opt_list, count_opt_list, &next_char);
		}
		else
		{
			*opt = next_keyword_or_option(opt_list, count_opt_list);
		}
	}
	else if (token[0] == 'Z' || token[0] == 'z')
	{
/*
 *   linear in z
 */
		p->coord = 'z';
		p->type = PROP_LINEAR;
		p->count_v = 2;
		if (sscanf
			(next_char, "%lf%lf%lf%lf", &p->v[0], &p->dist1, &p->v[1],
			 &p->dist2) != 4)
		{
			input_error++;
			error_msg
				("Expected: value, distance, value, distance in linear  property definition.",
				 CONTINUE);
		}
		if (p->dist1 > p->dist2)
		{
			double save_d, save_v;
			save_d = p->dist1;
			save_v = p->v[0];
			p->dist1 = p->dist2;
			p->v[0] = p->v[1];
			p->dist2 = save_d;
			p->v[1] = save_v;
		}
		if (delimited == TRUE)
		{
			*opt = get_option(opt_list, count_opt_list, &next_char);
		}
		else
		{
			*opt = next_keyword_or_option(opt_list, count_opt_list);
		}
	}
	else if (token[0] == 'B' || token[0] == 'b')
	{
/*
 *   by_cell or by_element
 */
		if (delimited == FALSE)
		{
			j = read_lines_doubles(next_char, &(p->v), &(p->count_v),
								   &(p->count_alloc), opt_list,
								   count_opt_list, opt);
		}
		else
		{
			j = read_lines_doubles_delimited(next_char, &(p->v),
											 &(p->count_v), &(p->count_alloc),
											 opt_list, count_opt_list, opt);
		}
		p->type = PROP_ZONE;

		if (j == ERROR)
		{
			property_free(p);
			return (NULL);
		}

		p->v = (double *) realloc(p->v, (size_t) p->count_v * sizeof(double));
		p->count_alloc = p->count_v;
	}
	else if (token[0] == 'R' || token[0] == 'r')
	{
/*
 *   phast will read from restart file by_cell only
 */
		if (allow_restart == TRUE)
		{
			j = copy_token(token, &next_char, &l);
			std::string stdtoken(token);
			std::map < std::string, int >::iterator it =
				FileMap.find(stdtoken);
			if (it != FileMap.end())
			{
				j = it->second;
			}
			else
			{
				j = (int) FileMap.size();
				FileMap[stdtoken] = j;
			}
			p->v = (double *) malloc(sizeof(double));
			p->v[0] = -100 - j;
			p->count_v = 1;
			p->type = PROP_FIXED;
		}
		else
		{
			property_free(p);
			p = NULL;
			input_error++;
			error_msg
				("Restart file can only be used for CHEMISTRY_IC chemical properties.",
				 CONTINUE);
		}
		if (delimited == TRUE)
		{
			*opt = get_option(opt_list, count_opt_list, &next_char);
		}
		else
		{
			*opt = next_keyword_or_option(opt_list, count_opt_list);
		}
	}
	else if (token[0] == 'F' || token[0] == 'f')
	{
/*
 *   read from file by_cell or by_element
 */
		j = read_file_doubles(next_char, &(p->v), &(p->count_v),
							  &(p->count_alloc));
		p->type = PROP_ZONE;
		if (j == ERROR)
		{
			property_free(p);
			*opt = next_keyword_or_option(opt_list, count_opt_list);
			return (NULL);
		}
		if (delimited == TRUE)
		{
			*opt = get_option(opt_list, count_opt_list, &next_char);
		}
		else
		{
			*opt = next_keyword_or_option(opt_list, count_opt_list);
		}
	}
	else if (token[0] == 'M' || token[0] == 'm')
	{
/*
 *   Mixture
 */
		p->type = PROP_MIXTURE;
		if ((j = sscanf(next_char, "%lf%lf", &p->v[0], &p->v[1])) != 2)
		{
			input_error++;
			error_msg("Expected: two values for mixture definition",
					  CONTINUE);
		}

		/* Determine data source type */
		ptr1 = next_char;

		/* first mix */
		copy_token(token, &ptr1, &l);
		/* second mix */
		copy_token(token, &ptr1, &l);
		start_of_data_source = ptr1;	/* start_of_data_source is start of constant | points | xyz */

		/* read nothing | points | xyz */
		j = copy_token(token, &ptr1, &l);
		str_tolower(token);
		if (j == EMPTY)
		{
			style = MIX_OLDSTYLE;
		}
		else if (strstr(token, "points") == token)
		{
			style = MIX_POINTS;
		}
		else if (strstr(token, "xyz") == token)
		{
			style = MIX_XYZ;
		}
		else if (strstr(token, "constant") == token || strstr(token, "uniform") == token)
		{
			style = MIX_CONSTANT;
		}
		else if (j == DIGIT)
		{
			style = MIX_CONSTANT;
			sprintf(token,"%s %s", "constant", next_char);
			start_of_data_source = token;
		}
		else
		{
			style = MIX_UNKNOWN;
			input_error++;
			error_msg("Cannot interpret mixture input",
					  CONTINUE);
		}

		switch (style)
		{
		case MIX_OLDSTYLE:

			/* reread first two items and keep going */
			if (delimited == FALSE)
			{
				j = read_lines_doubles(next_char, &(p->v), &(p->count_v),
									   &(p->count_alloc), opt_list,
									   count_opt_list, opt);
			}
			else
			{
				j = copy_token(token, &next_char, &l);
				j = copy_token(token, &next_char, &l);
				p->count_v = 2;
				j = read_lines_doubles_delimited(next_char, &(p->v),
												 &(p->count_v),
												 &(p->count_alloc), opt_list,
												 count_opt_list, opt);
			}
			if (j == ERROR)
			{
				property_free(p);
				return (NULL);
			}

			p->v =
				(double *) realloc(p->v,
								   (size_t) p->count_v * sizeof(double));
			p->count_alloc = p->count_v;
			break;
		case MIX_XYZ:
			{
				p->type = PROP_MIX_XYZ;
				std::istringstream lines(start_of_data_source);
				p->data_source->Read_mixture(lines);
				p->data_source->Tidy(false);
				if (p->data_source->Get_points().size() <= 0
					|| p->data_source->Get_columns() != 4)
				{
					input_error++;
					char estring[MAX_LENGTH];
					sprintf(estring,
							"Expected rows of x, y, z, value for property in file %s.",
							p->data_source->Get_file_name().c_str());
					error_msg(estring, CONTINUE);
				}
				properties_with_data_source.push_back(p);
				//*opt = next_keyword_or_option(opt_list, count_opt_list);
				*opt = get_option(opt_list, count_opt_list, &next_char);
			}
			break;
		case MIX_POINTS:
			{
				p->type = PROP_MIX_POINTS;
				std::istringstream lines;
				*opt = streamify_to_next_keyword_or_option(opt_list,
					count_opt_list, lines,
					start_of_data_source, "end_p");

				// read points into property Data_source
				p->data_source->Read_mixture(lines);
				//p->data_source->Set_columns( Read_points(lines, p->data_source->Get_points()) );
				if (p->data_source->Get_points().size() <= 0
					|| p->data_source->Get_columns() != 4)
				{
					input_error++;
					char estring[MAX_LENGTH];
					sprintf(estring,
							"Expected rows of x, y, z, value for property in input file.");
					error_msg(estring, CONTINUE);
				}
				properties_with_data_source.push_back(p);
			}
			break;
		case MIX_CONSTANT:
			{
				p->type = PROP_MIX_CONSTANT;
				std::istringstream lines(start_of_data_source);
				p->data_source->Read_mixture(lines);
				p->data_source->Tidy(false);

				if (p->data_source->Get_points().size() <= 0)
				{
					input_error++;
					char estring[MAX_LENGTH];
					sprintf(estring,
							"Expected rows single value for property in input file.");
					error_msg(estring, CONTINUE);
				}
				properties_with_data_source.push_back(p);
				*opt = get_option(opt_list, count_opt_list, &next_char);
			}
			break;		
		default:
			error_msg("Unknown option for PROP_MIXTURE", STOP);
			break;		
		}

	}
	else
	{
		property_free(p);
		p = NULL;
		sprintf(error_string, "Unknown option reading property, %s.", token);
		input_error++;
		error_msg(error_string, STOP);
	}
	return (p);
}

#ifdef SKIP
/* ---------------------------------------------------------------------- */
struct property *
read_property_file_or_doubles(char *ptr, const char **opt_list,
							  int count_opt_list, int *opt)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads property data in any of 2 forms:
 *         (1) b[y_element] or b[y_cell] followed by list of doubles
 *             on same and (or) succeeding lines (default) enclosed in <>
 *         (2) f[ile] followed by file name
 *
 *      Arguments:
 *         ptr    entry: points to line to read from
 *            
 *
 *      Returns:
 *         pointer to property structure
 */

	int j;
	char token[MAX_LENGTH];
	int l;
	struct property *p;
	char *next_char, *next_char_save;

	p = property_alloc();

	next_char = ptr;
	next_char_save = ptr;
	j = copy_token(token, &next_char, &l);
	if (j == EMPTY || j == DIGIT || token[0] == '<')
	{
/*
 *   by_cell or by_element
 */
		j = read_lines_doubles_delimited(next_char_save, &(p->v),
										 &(p->count_v), &(p->count_alloc),
										 opt_list, count_opt_list, opt);
		if (j == ERROR)
		{
			property_free(p);
			return (NULL);
		}
		p->v = (double *) realloc(p->v, (size_t) p->count_v * sizeof(double));
		p->count_alloc = p->count_v;
	}
	else if (token[0] == 'B' || token[0] == 'b')
	{
/*
 *   by_cell or by_element
 */
		j = read_lines_doubles_delimited(next_char, &(p->v), &(p->count_v),
										 &(p->count_alloc), opt_list,
										 count_opt_list, opt);
		if (j == ERROR)
		{
			property_free(p);
			return (NULL);
		}
		p->v = (double *) realloc(p->v, (size_t) p->count_v * sizeof(double));
		p->count_alloc = p->count_v;
	}
	else if (token[0] == 'F' || token[0] == 'f')
	{
/*
 *   read from file by_cell or by_element
 */
		j = read_file_doubles(next_char, &(p->v), &(p->count_v),
							  &(p->count_alloc));
		*opt = next_keyword_or_option(opt_list, count_opt_list);
		if (j == ERROR)
		{
			property_free(p);
			return (NULL);
		}
	}
	else
	{
		*opt = next_keyword_or_option(opt_list, count_opt_list);
		return (NULL);
	}
	return (p);
}
#endif
#if !defined(__WPHAST__)
/* ---------------------------------------------------------------------- */
int
read_lines_doubles(char *next_char, double **d, int *count_d,
				   int *count_alloc, const char **opt_list,
				   int count_opt_list, int *opt)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads doubles on line starting at next_char
 *      and on succeeding lines. Appends to d.
 *      Stops at KEYWORD, OPTION, and EOF
 *
 *      Input Arguments:
 *         next_char    points to line to read from
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
 *         KEYWORD
 *         OPTION
 *         EOF
 *         ERROR if any errors reading doubles
 */

	if (read_line_doubles(next_char, d, count_d, count_alloc) == ERROR)
	{
		return (ERROR);
	}
	for (;;)
	{
		*opt = get_option(opt_list, count_opt_list, &next_char);
		if (*opt == OPTION_KEYWORD || *opt == OPTION_EOF
			|| *opt == OPTION_ERROR)
		{
			break;
		}
		else if (*opt >= 0)
		{
			break;
		}
		next_char = line;
		if (read_line_doubles(next_char, d, count_d, count_alloc) == ERROR)
		{
			return (ERROR);
		}
	}
	return (OK);
}
#endif
/* ---------------------------------------------------------------------- */
int
read_lines_doubles_delimited(char *next_char, double **d, int *count_d,
							 int *count_alloc, const char **opt_list,
							 int count_opt_list, int *opt)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads doubles on line starting at next_char
 *      and on succeeding lines. Appends to d.
 *      Doubles are delimited by <>.
 #
 *      Expets < to start. Stops at ">". Reads next line.
 *
 *      Input Arguments:
 *         next_char    points to line to read from
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
 *         KEYWORD
 *         OPTION
 *         EOF
 *         ERROR if any errors reading doubles
 */
	int j, l;
	char token[MAX_LENGTH];

	replace("<", "< ", next_char);
	j = copy_token(token, &next_char, &l);
	while (j == EMPTY)
	{
		*opt = get_option(opt_list, count_opt_list, &next_char);
		if (*opt == OPTION_KEYWORD || *opt == OPTION_EOF
			|| *opt == OPTION_ERROR || *opt >= 0)
		{
			input_error++;
			error_msg("List of values missing for property\n", CONTINUE);
			return (ERROR);
		}
		replace("<", "< ", next_char);
		j = copy_token(token, &next_char, &l);
	}
	/*
	 *  Should start with "<"
	 */
	if (token[0] != '<')
	{
		input_error++;
		error_msg("Starting \"<\" missing in list of values for property\n",
				  CONTINUE);
		*opt = next_keyword_or_option(opt_list, count_opt_list);
		return (ERROR);
	}
	if ((j =
		 read_line_doubles_delimited(next_char, d, count_d,
									 count_alloc)) == ERROR)
	{
		return (ERROR);
	}
	else if (j == DONE)
	{
		*opt = get_option(opt_list, count_opt_list, &next_char);
		return (DONE);
	}
	for (;;)
	{
		*opt = get_option(opt_list, count_opt_list, &next_char);
		if (*opt == OPTION_KEYWORD || *opt == OPTION_EOF
			|| *opt == OPTION_ERROR || *opt >= 0)
		{
			break;
		}
		next_char = line;
		if ((j =
			 read_line_doubles_delimited(next_char, d, count_d,
										 count_alloc)) == ERROR)
		{
			return (ERROR);
		}
		else if (j == DONE)
		{
			*opt = get_option(opt_list, count_opt_list, &next_char);
			return (DONE);
		}
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
read_line_doubles(char *next_char, double **d, int *count_d, int *count_alloc)
/* ---------------------------------------------------------------------- */
{
	int i, j, l, n;
	double value;
	char token[MAX_LENGTH];

	for (;;)
	{
		j = copy_token(token, &next_char, &l);
		if (j == EMPTY)
		{
			break;
		}
		if (j != DIGIT)
		{
			return (ERROR);
		}
		if (replace("*", " ", token) == TRUE)
		{
			if (sscanf(token, "%d%lf", &n, &value) != 2)
			{
				return (ERROR);
			}
		}
		else
		{
			sscanf(token, "%lf", &value);
			n = 1;
		}
		for (;;)
		{
			if ((*count_d) + n > (*count_alloc))
			{
				*count_alloc *= 2;
				*d = (double *) realloc(*d,
										(size_t) (*count_alloc) *
										sizeof(double));
				if (*d == NULL)
					malloc_error();
			}
			else
			{
				break;
			}
		}
		for (i = 0; i < n; i++)
		{
			(*d)[(*count_d) + i] = value;
		}
		*count_d += n;
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
read_line_doubles_delimited(char *next_char, double **d, int *count_d,
							int *count_alloc)
/* ---------------------------------------------------------------------- */
{
	int i, j, l, n;
	double value;
	char token[MAX_LENGTH];

	replace(">", " >", next_char);
	for (;;)
	{
		j = copy_token(token, &next_char, &l);
		if (j == EMPTY)
		{
			break;
		}
		if (token[0] == '>')
		{
			return (DONE);
		}
		if (j != DIGIT)
		{
			return (ERROR);
		}
		if (replace("*", " ", token) == TRUE)
		{
			if (sscanf(token, "%d%lf", &n, &value) != 2)
			{
				return (ERROR);
			}
		}
		else
		{
			sscanf(token, "%lf", &value);
			n = 1;
		}
		for (;;)
		{
			if ((*count_d) + n > (*count_alloc))
			{
				*count_alloc *= 2;
				*d = (double *) realloc(*d,
										(size_t) (*count_alloc) *
										sizeof(double));
				if (*d == NULL)
					malloc_error();
			}
			else
			{
				break;
			}
		}
		for (i = 0; i < n; i++)
		{
			(*d)[(*count_d) + i] = value;
		}
		*count_d += n;
	}
	return (OK);
}

#if !defined(__WPHAST__)
/* ---------------------------------------------------------------------- */
int
read_file_doubles(char *next_char, double **d, int *count_d, int *count_alloc)
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
	FILE *file_ptr;
/*
 *    open file
 */
	return_value = OK;
	j = copy_token(token, &next_char, &l);
	if ((file_ptr = fopen(token, "r")) == NULL)
	{
		sprintf(error_string, "Can't open file, %s.", token);
		error_msg(error_string, STOP);
		return (ERROR);
	}
	strcpy(property_file_name, token);
	strcpy(name, prefix);
	strcat(name, ".head.dat");
	if (strcmp(property_file_name, name) == 0)
	{
		head_ic_file_warning = TRUE;
	}
/*
 *   read doubles
 */
	for (;;)
	{
		j = get_line(file_ptr);
		if (j == EMPTY)
		{
			continue;
		}
		else if (j == EOF)
		{
			break;
		}
		next_char = line;
		if (read_line_doubles(next_char, d, count_d, count_alloc) == ERROR)
		{
			sprintf(error_string, "Reading from file %s\n%s", token, line);
			error_msg(error_string, CONTINUE);
			return_value = ERROR;
		}
	}
	if (*count_d > 0)
	{
		*d = (double *) realloc(*d, (size_t) * count_d * sizeof(double));
		*count_alloc = *count_d;
	}
	fclose(file_ptr);
	return (return_value);
}
#endif /* __WPHAST__ */
/* ---------------------------------------------------------------------- */
int
next_keyword_or_option(const char **opt_list, int count_opt_list)
/* ---------------------------------------------------------------------- */
{
/*
 *   Reads to next keyword or option or eof
 *
 *   Returns:
 *       KEYWORD
 *       OPTION
 *       EOF
 */
	int opt;
	char *next_char;

	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		if (opt == OPTION_EOF)
		{						/* end of file */
			break;
		}
		else if (opt == OPTION_KEYWORD)
		{						/* keyword */
			break;
		}
		else if (opt >= 0 && opt < count_opt_list)
		{
			break;
		}
		else
		{
			error_msg("Expected a keyword or option.", CONTINUE);
			error_msg(line_save, CONTINUE);
			input_error++;
		}
	}
	return (opt);
}

/* ---------------------------------------------------------------------- */
int
streamify_to_next_keyword_or_option(const char **opt_list, int count_opt_list,
									std::istringstream & lines)
/* ---------------------------------------------------------------------- */
{
/*
 *   Reads to next keyword or option or eof
 *
 *   Returns:
 *       KEYWORD
 *       OPTION
 *       EOF
 */
	int opt;
	char *next_char;
	std::string accumulate(line);
	accumulate.append("\n");
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		if (opt == OPTION_EOF)
		{						/* end of file */
			break;
		}
		else if (opt == OPTION_KEYWORD)
		{						/* keyword */
			break;
		}
		else if (opt >= 0 && opt < count_opt_list)
		{
			break;
		}
		else
		{
			accumulate.append(line);
			accumulate.append("\n");
		}
	}
	lines.str(accumulate);
	return (opt);
}
/* ---------------------------------------------------------------------- */
int
streamify_prism_piece(const char **opt_list, int count_opt_list,
				std::istringstream & lines)
/* ---------------------------------------------------------------------- */
{
/*
 *   Reads to next keyword or option or eof
 *
 *   Returns:
 *       KEYWORD
 *       OPTION
 *       EOF
 */
	int opt;
	char *next_char;

	// add option for end_points
	int count_opt_list_plus = count_opt_list + 1;
	char **opt_list_plus = (char **) malloc((size_t) (count_opt_list_plus  * sizeof(char *)));
	int i;
	for (i = 0; i < count_opt_list; i++)
	{
		opt_list_plus[i] = string_duplicate(opt_list[i]);
	}
	opt_list_plus[i] = string_duplicate("end_points");


	std::string accumulate(line);
	accumulate.append("\n");
	for (;;)
	{
		opt = get_option((const char **) opt_list_plus, count_opt_list_plus, &next_char);
		char *ptr = line;
		char token[MAX_LENGTH];
		int l;
		copy_token(token, &ptr, &l);
		str_tolower(token);
		if (opt == OPTION_EOF)
		{						/* end of file */
			break;
		}
		else if (strstr(token, "end_p") != NULL)
		{
			opt = get_option(opt_list, count_opt_list, &next_char);
			break;
		}
		else if (opt == OPTION_KEYWORD)
		{						/* keyword */
			break;
		}
		else if (opt >= 0 && opt < count_opt_list)
		{
			break;
		}
		else
		{
			accumulate.append(line);
			accumulate.append("\n");
		}
	}
	lines.str(accumulate);

	// free space
	for (i = 0; i < count_opt_list_plus; i++)
	{
		free_check_null(opt_list_plus[i]);
	}
	free_check_null(opt_list_plus);

	return (opt);
}
/* ---------------------------------------------------------------------- */
int
streamify_to_next_keyword_or_option(const char **opt_list, int count_opt_list,
									std::istringstream & lines,
									char *start_string, const char *delimiting_string)
/* ---------------------------------------------------------------------- */
{
/*
 *   Reads to next keyword or option or eof
 *
 *   Returns:
 *       KEYWORD
 *       OPTION
 *       EOF
 */
	int count_opt_list_plus = count_opt_list + 1;
	char **opt_list_plus = (char **) malloc((size_t) (count_opt_list_plus  * sizeof(char *)));
	int i;
	for (i = 0; i < count_opt_list; i++)
	{
		opt_list_plus[i] = string_duplicate(opt_list[i]);
	}
	opt_list_plus[i] = string_duplicate("end_points");

	int opt, l;
	char *next_char, *ptr;
	char token[MAX_LENGTH];
	std::string accumulate;
	if (start_string != NULL)
	{
	  accumulate.append(start_string);
	  accumulate.append("\n");
	}
	for (;;)
	{
		opt = get_option((const char **) opt_list_plus, count_opt_list_plus, &next_char);
		ptr = line;
		copy_token(token, &ptr, &l);
		str_tolower(token);

		if (opt == OPTION_EOF)
		{						/* end of file */
			break;
		}
		else if (delimiting_string != NULL && strstr(token, delimiting_string) != NULL)
		{
			opt = get_option(opt_list, count_opt_list, &next_char);
			break;
		}
		else if (opt == OPTION_KEYWORD)
		{						/* keyword */
			break;
		}
		else if (opt >= 0 && opt < count_opt_list)
		{
			break;
		}
		else
		{
			accumulate.append(line);
			accumulate.append("\n");
		}
	}
	lines.str(accumulate);

	// free space
	for (i = 0; i < count_opt_list_plus; i++)
	{
		free_check_null(opt_list_plus[i]);
	}
	free_check_null(opt_list_plus);
	return (opt);
}

/* ---------------------------------------------------------------------- */
int
read_units(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads units 
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	int l;
	char token[MAX_LENGTH];
	int return_value, opt;
	char *next_char;
	const char *opt_list[] = {
		"time",					/* 0 */
		"horizontal",			/* 1 */
		"horizontal_grid",		/* 2 */
		"vertical",				/* 3 */
		"vertical_grid",		/* 4 */
		"head",					/* 5 */
		"hydraulic_conductivity",	/* 6 */
		"k",					/* 7 */
		"specific_storage",		/* 8 */
		"storage",				/* 9 */
		"dispersivity",			/* 10 */
		"alpha",				/* 11 */
		"leaky_hydraulic_conductivity",	/* 12 */
		"leaky_k",				/* 13 */
		"leaky_thickness",		/* 14 */
		"thickness",			/* 15 */
		"flux",					/* 16 */
		"well_diameter",		/* 17 */
		"well_flow_rate",		/* 18 */
		"well_pumpage",			/* 19 */
		"river_bed_k",			/* 20 */
		"river_bed_hydraulic_conductivity",	/* 21 */
		"river_k",				/* 22 */
		"river_bed_thickness",	/* 23 */
		"river_thickness",		/* 24 */
		"drain_bed_k",			/* 25 */
		"drain_hydraulic_conductivity",	/* 26 */
		"drain_k",				/* 27 */
		"drain_bed_thickness",	/* 28 */
		"drain_thickness",		/* 29 */
		"drain_width",			/* 30 */
		"map_horizontal",		/* 31 */
		"map_vertical"			/* 32 */
		, "river_width"	    	/* 33 */
		, "river_depth"         /* 34 */
		, "well_depth"          /* 35 */
	};
	int count_opt_list = 36;
	/*
	 *   Read flags:
	 */
	return_value = UNKNOWN;
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			input_error++;
			sprintf(error_string, "Expected identifier for UNITS.");
			error_msg(error_string, CONTINUE);
			break;
		case 0:				/* time */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.time.si,
								 &units.time.input_to_si, TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string, "Expected units for time (T).");
				error_msg(error_string, CONTINUE);
				units.time.defined = FALSE;
			}
			else
			{
				units.time.define(token);
			}
			break;
		case 1:				/* horizontal */
		case 2:				/* horizontal_grid */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.horizontal.si,
								 &units.horizontal.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for horizontal grid (L).");
				error_msg(error_string, CONTINUE);
				units.horizontal.defined = FALSE;
			}
			else
			{
				units.horizontal.define(token);
			}
			break;
		case 3:				/* vertical */
		case 4:				/* vertical_grid */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.vertical.si,
								 &units.vertical.input_to_si, TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for vertical grid (L).");
				error_msg(error_string, CONTINUE);
				units.vertical.defined = FALSE;
			}
			else
			{
				units.vertical.define(token);
			}
			break;
		case 5:				/* head */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.head.si,
								 &units.head.input_to_si, TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string, "Expected units for head (L).");
				error_msg(error_string, CONTINUE);
				units.head.defined = FALSE;
			}
			else
			{
				units.head.define(token);
			}
			break;
		case 6:				/* hydraulic_conductivity */
		case 7:				/* k */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.k.si,
								 &units.k.input_to_si, TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for hydraulic conductivity (L/T).");
				error_msg(error_string, CONTINUE);
				units.k.defined = FALSE;
			}
			else
			{
				units.k.define(token);
			}
			break;
		case 8:				/* specific_storage */
		case 9:				/* storage */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.s.si,
								 &units.s.input_to_si, TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string, "Expected units for storage (1/L).");
				error_msg(error_string, CONTINUE);
				units.s.defined = FALSE;
			}
			else
			{
				units.s.define(token);
			}
			break;
		case 10:				/* dispersivity */
		case 11:				/* alpha */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.alpha.si,
								 &units.alpha.input_to_si, TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string, "Expected units for dispersivity (L).");
				error_msg(error_string, CONTINUE);
				units.alpha.defined = FALSE;
			}
			else
			{
				units.alpha.define(token);
			}
			break;
		case 12:				/* leaky_hydraulic_conductivity */
		case 13:				/* leaky_k */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.leaky_k.si,
								 &units.leaky_k.input_to_si, TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for leaky boundary hydraulic conductivity (L/T).");
				error_msg(error_string, CONTINUE);
				units.leaky_k.defined = FALSE;
			}
			else
			{
				units.leaky_k.define(token);
			}
			break;
		case 14:				/* leaky_thickness */
		case 15:				/* thickness */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.leaky_thick.si,
								 &units.leaky_thick.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for leaky boundary thickness (L).");
				error_msg(error_string, CONTINUE);
				units.leaky_thick.defined = FALSE;
			}
			else
			{
				units.leaky_thick.define(token);
			}
			break;
		case 16:				/* flux */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.flux.si,
								 &units.flux.input_to_si, TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string, "Expected units for flux (L/T).");
				error_msg(error_string, CONTINUE);
				units.flux.defined = FALSE;
			}
			else
			{
				units.flux.define(token);
			}
			break;
		case 17:				/* well_diameter */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.well_diameter.si,
								 &units.well_diameter.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for well bore diameter (L).");
				error_msg(error_string, CONTINUE);
				units.well_diameter.defined = FALSE;
			}
			else
			{
				units.well_diameter.define(token);
			}
			break;
		case 18:				/* well_flow_rate */
		case 19:				/* well_pumpage */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.well_pumpage.si,
								 &units.well_pumpage.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for well flow rate (L^3/T).");
				error_msg(error_string, CONTINUE);
				units.well_pumpage.defined = FALSE;
			}
			else
			{
				units.well_pumpage.define(token);
			}
			break;

		case 20:				/* river_bed_k */
		case 21:				/* river_bed_hydraulic_conductivity */
		case 22:				/* river_k */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.river_bed_k.si,
								 &units.river_bed_k.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for river bed hydraulic conductivity (L/T).");
				error_msg(error_string, CONTINUE);
				units.river_bed_k.defined = FALSE;
			}
			else
			{
				units.river_bed_k.define(token);
			}
			break;
		case 23:				/* river_bed_thickness */
		case 24:				/* river_thickness */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.river_bed_thickness.si,
								 &units.river_bed_thickness.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for river bed thickness (L).");
				error_msg(error_string, CONTINUE);
				units.river_bed_thickness.defined = FALSE;
			}
			else
			{
				units.river_bed_thickness.define(token);
			}
			break;
		case 25:				/* drain_bed_k */
		case 26:				/* drain_hydraulic_conductivity */
		case 27:				/* drain_k */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.drain_bed_k.si,
								 &units.drain_bed_k.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for drain bed hydraulic conductivity (L/T).");
				error_msg(error_string, CONTINUE);
				units.drain_bed_k.defined = FALSE;
			}
			else
			{
				units.drain_bed_k.define(token);
			}
			break;
		case 28:				/* drain_bed_thickness */
		case 29:				/* drain_thickness */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.drain_bed_thickness.si,
								 &units.drain_bed_thickness.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected units for drain bed thickness (L).");
				error_msg(error_string, CONTINUE);
				units.drain_bed_thickness.defined = FALSE;
			}
			else
			{
				units.drain_bed_thickness.define(token);
			}
			break;
		case 30:				/* drain_width */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.drain_width.si,
								 &units.drain_width.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string, "Expected units for drain width (L).");
				error_msg(error_string, CONTINUE);
				units.drain_width.defined = FALSE;
			}
			else
			{
				units.drain_width.define(token);
			}
			break;
		case 31:				/* map_horizontal */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.map_horizontal.si,
								 &units.map_horizontal.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string, "Expected map horizontal units (L).");
				error_msg(error_string, CONTINUE);
				units.map_horizontal.defined = FALSE;
			}
			else
			{
				units.map_horizontal.define(token);
			}
			break;
		case 32:				/* map_vertical */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.map_vertical.si,
								 &units.map_vertical.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string,
						"Expected vertical units for map coordinate system (L).");
				error_msg(error_string, CONTINUE);
				units.map_vertical.defined = FALSE;
			}
			else
			{
				units.map_vertical.define(token);
			}
			break;
		case 33:				/* river_width */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.river_width.si,
								 &units.river_width.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string, "Expected units for river width (L).");
				error_msg(error_string, CONTINUE);
				units.river_width.defined = FALSE;
			}
			else
			{
				units.river_width.define(token);
			}
			break;
		case 34:				/* river_depth */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.river_depth.si,
								 &units.river_depth.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string, "Expected units for river depths (L).");
				error_msg(error_string, CONTINUE);
				units.river_depth.defined = FALSE;
			}
			else
			{
				units.river_depth.define(token);
			}
			break;		
		case 35:				/* well_depth */
			if (copy_token(token, &next_char, &l) == EMPTY ||
				units_conversion(token,
								 units.well_depth.si,
								 &units.well_depth.input_to_si,
								 TRUE) == ERROR)
			{
				input_error++;
				sprintf(error_string, "Expected units for well depths (L).");
				error_msg(error_string, CONTINUE);
				units.well_depth.defined = FALSE;
			}
			else
			{
				units.well_depth.define(token);
			}
			break;		
		}
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"UNITS can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_fluid_properties(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads optional fluid properties
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *         KEYWORD if keyword encountered, input_error may be incremented if
 *                    a keyword is encountered in an unexpected position
 *         EOF     if eof encountered while reading mass balance concentrations
 *         ERROR   if error occurred reading data
 *
 */
	int l;
	char token[MAX_LENGTH];
	int return_value, opt;
	char *next_char;
	const char *opt_list[] = {
		"compressibility",		/* 0 */
		"density",				/* 1 */
		"viscosity",			/* 2 */
		"diffusivity"			/* 3 */
	};
	int count_opt_list = 4;
/*
 *   Read flags:
 */
	sprintf(error_string,
			"The FLUID_PROPERTIES data block is obsolete. All fluid properties are fixed at default values,\n\texcept diffusivity, which is defined in the SOLUTE_TRANSPORT data block.");
	warning_msg(error_string);
	return_value = UNKNOWN;
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			input_error++;
			sprintf(error_string,
					"Expected identifier for FLUID_PROPERTIES.");
			error_msg(error_string, CONTINUE);
			break;
		case 0:				/* compressibility */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%lf", &fluid_compressibility) != 1))
			{
				input_error++;
				sprintf(error_string,
						"Expected compressibility of water (1/Pa) in FLUID_PROPERTIES.");
				error_msg(error_string, CONTINUE);
			}
			break;
		case 1:				/* density */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%lf", &fluid_density) != 1))
			{
				input_error++;
				sprintf(error_string,
						"Expected density of water (kg/m^3) in FLUID_PROPERTIES.");
				error_msg(error_string, CONTINUE);
			}
			break;
		case 2:				/* viscosity */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%lf", &fluid_viscosity) != 1))
			{
				input_error++;
				sprintf(error_string,
						"Expected viscosity of water (Pa-s) in FLUID_PROPERTIES.");
				error_msg(error_string, CONTINUE);
			}
			break;
		case 3:				/* diffusivity */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%lf", &fluid_diffusivity) != 1))
			{
				input_error++;
				sprintf(error_string,
						"Expected molecular diffusivity (m^2/s) in FLUID_PROPERTIES.");
				error_msg(error_string, CONTINUE);
			}
			break;
		}
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"FLUID_PROPERTIES can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_solution_method(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads solver information
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *         KEYWORD if keyword encountered, input_error may be incremented if
 *                    a keyword is encountered in an unexpected position
 *         EOF     if eof encountered while reading mass balance concentrations
 *         ERROR   if error occurred reading data
 *
 */
	int l;
	char token[MAX_LENGTH];
	int return_value, opt;
	char *next_char;
	const char *opt_list[] = {
		"direct_solver",		/* 0 */
		"direct",				/* 1 */
		"tolerance",			/* 2 */
		"save_directions",		/* 3 */
		"save",					/* 4 */
		"maximum_iterations",	/* 5 */
		"maximum",				/* 6 */
		"iterations",			/* 7 */
		"iterative_solver",		/* 8 */
		"iterative",			/* 9 */
		"space_differencing",	/* 10 */
		"space",				/* 11 */
		"time_differencing",	/* 12 */
		"time",					/* 13 */
		"cross_dispersion",		/* 14 */
		"rebalance_fraction",	/* 15 */
		"rebalance_by_cell"		/* 16 */
	};
	int count_opt_list = 17;
/*
 *   Read flags:
 */
	return_value = UNKNOWN;
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			input_error++;
			sprintf(error_string, "Expected identifier for SOLUTION_METHOD.");
			error_msg(error_string, CONTINUE);
			break;
		case 0:				/* direct_solver */
		case 1:				/* direct */
			if (get_true_false(next_char, TRUE) == TRUE)
			{
				solver_method = DIRECT;
			}
			else
			{
				solver_method = ITERATIVE;
			}
			break;
		case 2:				/* tolerance */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%lf", &solver_tolerance) != 1))
			{
				input_error++;
				sprintf(error_string,
						"Expected tolerance for iterative solver in SOLUTION_METHOD.");
				error_msg(error_string, CONTINUE);
			}
			break;
		case 3:				/* save_directions */
		case 4:				/* save */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%d", &solver_save_directions) != 1))
			{
				input_error++;
				sprintf(error_string,
						"Expected number of directions to save in iterative solver in SOLUTION_METHOD.");
				error_msg(error_string, CONTINUE);
			}
			break;
		case 5:				/* maximum_iterations */
		case 6:				/* maximum */
		case 7:				/* iterations */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%d", &solver_maximum) != 1))
			{
				input_error++;
				sprintf(error_string,
						"Expected maximum number of iterations for iterative solver in SOLUTION_METHOD.");
				error_msg(error_string, CONTINUE);
			}
			break;
		case 8:				/* iterative_solver */
		case 9:				/* iterative */
			if (get_true_false(next_char, TRUE) == TRUE)
			{
				solver_method = ITERATIVE;
			}
			else
			{
				solver_method = DIRECT;
			}
			break;
		case 10:				/* space_differencing */
		case 11:				/* space */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%lf", &solver_space) != 1) ||
				solver_space < 0.0 || solver_space > 0.5)
			{
				input_error++;
				sprintf(error_string,
						"Expected weighting factor (0.0 to 0.5) for spatial differencing in SOLUTION_METHOD.");
				error_msg(error_string, CONTINUE);
			}
			break;
		case 12:				/* time_differencing */
		case 13:				/* time */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%lf", &solver_time) != 1) ||
				solver_time < 0.5 || solver_time > 1.0)
			{
				input_error++;
				sprintf(error_string,
						"Expected weighting factor (0.5 to 1.0) for time differencing in SOLUTION_METHOD.");
				error_msg(error_string, CONTINUE);
			}
			break;
		case 14:				/* cross_dispersion */
			cross_dispersion = get_true_false(next_char, TRUE);
			break;
		case 15:				/* rebalance_fraction */
			if (copy_token(token, &next_char, &l) != DIGIT ||
				(sscanf(token, "%lf", &rebalance_fraction) != 1) ||
				rebalance_fraction < 0.0 || rebalance_fraction > 1.0)
			{
				input_error++;
				sprintf(error_string,
						"Expected rebalance weight between 0.0 and 1.0, for rebalance_fraction in SOLUTION_METHOD.");
				warning_msg(error_string);
				rebalance_fraction = 0.5;
			}
			break;
		case 16:				/* rebalance_by_cell */
			rebalance_by_cell = get_true_false(next_char, TRUE);
			break;
		}
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"SOLUTION_METHOD can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_time_control(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads time stepping information
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *         KEYWORD if keyword encountered, input_error may be incremented if
 *                    a keyword is encountered in an unexpected position
 *         EOF     if eof encountered while reading mass balance concentrations
 *         ERROR   if error occurred reading data
 *
 */
	int return_value, opt;
	struct time *time_step_temp;
	int count_time_step_temp;
	char token[MAX_LENGTH];
	int i, l, count;
	char *next_char;
	const char *opt_list[] = {
		"delta_time",			/* 0 */
		"delta",				/* 1 */
		"step",					/* 2 */
		"time_step",			/* 3 */
		"time_change",			/* 4 */
		"change_time",			/* 5 */
		"end_time",				/* 6 */
		"time_end",				/* 7 */
		"end",					/* 8 */
		"initial_time",			/* 9 */
		"time_initial",			/* 10 */
		"start_time",			/* 11 */
		"time_start"			/* 12 */
		,"start"                /* 13 */
	};
	int count_opt_list = 14;
/*
 *   Read flags:
 */
	return_value = UNKNOWN;
	opt = get_option(opt_list, count_opt_list, &next_char);
	sprintf(tag, "in TIME_CONTROL.");
	time_step_temp = NULL;
	for (;;)
	{
		/*
		   opt = get_option(opt_list, count_opt_list, &next_char);
		 */
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			input_error++;
			sprintf(error_string, "Expected identifier for TIME.");
			error_msg(error_string, CONTINUE);
			break;
		case 0:				/* delta_time */
		case 1:				/* delta */
		case 2:				/* step */
		case 3:				/* time_step */
			if (time_step_temp != NULL)
			{
				sprintf(error_string,
						"Time step series has been redefined %s", tag);
				warning_msg(error_string);
				times_free(time_step_temp, count_time_step_temp);
				time_step_temp = NULL;
			}
			time_step_temp = (struct time *) malloc(sizeof(struct time));
			count_time_step_temp = 0;
			if (read_lines_times
				(next_char, &time_step_temp, &count_time_step_temp, opt_list,
				 count_opt_list, &opt) == ERROR)
			{
				input_error++;
				sprintf(error_string, "List of time_step %s", tag);
				error_msg(error_string, CONTINUE);
			}

			break;
		case 4:				/* time_change */
		case 5:				/* change_time */
		case 6:				/* end_time */
		case 7:				/* time_end */
		case 8:				/* end */
			if (time_end != NULL)
			{
				sprintf(error_string, "Time end series has been redefined %s",
						tag);
				warning_msg(error_string);
				times_free(time_end, count_time_end);
				time_end = NULL;
			}
			if (read_lines_times
				(next_char, &time_end, &count_time_end, opt_list,
				 count_opt_list, &opt) == ERROR)
			{
				input_error++;
				sprintf(error_string, "List of time_end %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 9:				/* initial_time */
		case 10:				/* time_initial */
		case 11:				/* start_time */
		case 12:				/* time_start */
		case 13:				/* start */
			read_time_data(&next_char, &time_start,
						   "Starting time in PRINT_CONTROL");
			opt = get_option(opt_list, count_opt_list, &next_char);
			break;
		}
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (time_step_temp != NULL)
	{
		time_series_free(&time_step);
		if (time_step_temp == 0 || (count_time_step_temp % 2) != 0)
		{
			input_error++;
			sprintf(error_string, "Time series for time_step %s", tag);
			error_msg(error_string, CONTINUE);
		}
		else
		{
			count = (count_time_step_temp) / 2;
			time_step.properties =
				(struct property_time **)
				malloc((size_t) (count * sizeof(struct property_time *)));
			if (time_step.properties == NULL)
				malloc_error();
			for (i = 0; i < count; i++)
			{
				time_step.properties[i] = property_time_alloc();
				time_copy(&(time_step_temp[2 * i]),
						  &time_step.properties[i]->time);
				time_copy(&(time_step_temp[2 * i + 1]),
						  &time_step.properties[i]->time_value);
			}
			time_step.count_properties = count;
		}
		for (i = 0; i < count_time_step_temp; i++)
		{
			time_free(&time_step_temp[i]);
		}
		free_check_null(time_step_temp);
		time_step_temp = NULL;
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_time_data(char **next_char, struct time *time_ptr, const char *errstr)
/* ---------------------------------------------------------------------- */
{
	int j, l;
	char token[MAX_LENGTH];

	time_ptr->type = UNDEFINED;
	time_ptr->value_defined = FALSE;
	if (time_ptr->input != NULL)
		free_check_null(time_ptr->input);
	time_ptr->input = NULL;
	if (copy_token(token, next_char, &l) != DIGIT ||
		(sscanf(token, "%lf", &time_ptr->value) != 1))
	{
		input_error++;
		sprintf(error_string, "Expected %s", errstr);
		error_msg(error_string, CONTINUE);
		return (ERROR);
	}
	else
	{
		time_ptr->value_defined = TRUE;
	}
	j = copy_token(token, next_char, &l);
	if (j == EMPTY)
	{
		time_ptr->type = UNITS;
	}
	else if (j == UPPER || j == LOWER)
	{
		time_ptr->input = string_duplicate(token);
		str_tolower(token);
		if (strstr(token, "step") == token)
		{
			time_ptr->type = STEP;
		}
		else
		{
			time_ptr->type = UNITS;
		}
	}
	else
	{
		input_error++;
		sprintf(error_string, "Expected %s", errstr);
		error_msg(error_string, CONTINUE);
		return (ERROR);
	}
	return (OK);

}

/* ---------------------------------------------------------------------- */
int
read_frequency_data(char **next_char, struct time *time_ptr,
					const char *errstr)
/* ---------------------------------------------------------------------- */
{
	int i, j, l;
	char token[MAX_LENGTH];

	time_ptr->type = UNDEFINED;
	time_ptr->value_defined = FALSE;
	if (time_ptr->input != NULL)
		free_check_null(time_ptr->input);
	time_ptr->input = NULL;
	/*
	 *  Read "end", write at end of simulation period
	 */
	if ((i = copy_token(token, next_char, &l)) == UPPER || i == LOWER)
	{
		if (strcmp_nocase(token, "end") == 0)
		{
			time_ptr->type = UNDEFINED;
		}
		else
		{
			input_error++;
			sprintf(error_string, "Expected %s", errstr);
			error_msg(error_string, CONTINUE);
			return (ERROR);
		}
		/*
		 *  Read number and units
		 */
	}
	else if (i == DIGIT && sscanf(token, "%lf", &time_ptr->value) == 1)
	{
		time_ptr->value_defined = TRUE;
		j = copy_token(token, next_char, &l);
		if (j == EMPTY)
		{
			time_ptr->type = UNITS;
		}
		else if (j == UPPER || j == LOWER)
		{
			str_tolower(token);
			if (strstr(token, "step") == token)
			{
				time_ptr->input = string_duplicate(token);
				time_ptr->type = STEP;
			}
			else if (strstr(token, "end") == token)
			{
				time_ptr->value_defined = FALSE;
				time_ptr->input = NULL;
				time_ptr->value_defined = FALSE;
			}
			else
			{
				time_ptr->input = string_duplicate(token);
				time_ptr->type = UNITS;
			}
		}
		else
		{
			input_error++;
			sprintf(error_string, "Expected %s", errstr);
			error_msg(error_string, CONTINUE);
			return (ERROR);
		}
		/*
		 *  Error
		 */
	}
	else
	{
		input_error++;
		sprintf(error_string, "Expected %s", errstr);
		error_msg(error_string, CONTINUE);
		return (ERROR);
	}
	return (OK);

}

/* ---------------------------------------------------------------------- */
int
read_print_frequency(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads print frequency information
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *         KEYWORD if keyword encountered, input_error may be incremented if
 *                    a keyword is encountered in an unexpected position
 *         EOF     if eof encountered while reading mass balance concentrations
 *         ERROR   if error occurred reading data
 *
 */
	struct time current_time;
	struct property_time *property_time_ptr;
	int return_value, opt;
	char *next_char;
	const char *opt_list[] = {
		"velocity",				/* 0 */
		"velocities",			/* 1 */
		"solver_statistics",	/* 2 */
		"head",					/* 3 */
		"heads",				/* 4 */
		"flow_balance",			/* 5 */
		"bc",					/* 6 */
		"map_head",				/* 7 */
		"map_heads",			/* 8 */
		"map_velocity",			/* 9 */
		"map_velocities",		/* 10 */
		"concentration",		/* 11 */
		"concentrations",		/* 12 */
		"selected_output",		/* 13 */
		"plot_head",			/* 14 */
		"plot_heads",			/* 15 */
		"plot_velocity",		/* 16 */
		"plot_velocities",		/* 17 */
		"selected_outputs",		/* 18 */
		"wells",				/* 19 */
		"conductances",			/* 20 */
		"conductance",			/* 21 */
		"well_time_series",		/* 22 */
		"wells_time_series",	/* 23 */
		"xyz_well",				/* 24 */
		"xyz_wells",			/* 25 */
		"progress_statistics",	/* 26 */
		"component",			/* 27 */
		"components",			/* 28 */
		"plot_component",		/* 29 */
		"plot_components",		/* 30 */
		"force_chemistry_print",	/* 31 */
		"hdf_concentrations",	/* 32 */
		"hdf_concentration",	/* 33 */
		"hdf_heads",			/* 34 */
		"hdf_head",				/* 35 */
		"hdf_velocities",		/* 36 */
		"hdf_velocity",			/* 37 */
		"save_final_heads",		/* 38 */
		"xyz_component",		/* 39 */
		"xyz_components",		/* 40 */
		"xyz_head",				/* 41 */
		"xyz_heads",			/* 42 */
		"xyz_velocity",			/* 43 */
		"xyz_velocities",		/* 44 */
		"hdf_chemistry",		/* 45 */
		"xyz_chemistry",		/* 46 */
		"force_chemistry",		/* 47 */
		"save_head",			/* 48 */
		"save_heads",			/* 49 */
		"echo_input",			/* 50 */
		"boundary_conditions",	/* 51 */
		"boundary",				/* 52 */
		"bc_flow_rates",		/* 53 */
		"restart",				/* 54 */
		"restart_file",			/* 55 */
		"print_default_end_of_period",	/* 56 */
		"end_of_period_default"	/* 57 */
		, "zone_budget"		/* 58 */
		, "zone_flow"		/* 59 */
		, "zone_flow_rates"	/* 60 */
		, "zone_flows"		/* 61 */
		, "tsv_zone_flow"		/* 62 */
		, "tsv_zone_flow_rates"	/* 63 */
		, "tsv_zone_flows"		/* 64 */	
	};
	int count_opt_list = 65;
/*
 *   Read flags:
 */
	time_init(&current_time);
	return_value = UNKNOWN;
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_ERROR:
			input_error++;
			sprintf(error_string, "Expected identifier for PRINT.");
			error_msg(error_string, CONTINUE);
			break;
		case OPTION_DEFAULT:	/* read time structure */
			time_free(&current_time);
			read_time_data(&next_char, &current_time,
						   "new time in PRINT_FREQUENCY.");
			break;
		case 0:				/* velocity */
		case 1:				/* velocities */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_velocity);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for velocities, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 2:				/* solver_statistics */
		case 26:				/* progress_statistics */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_statistics);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for solver statistics, in PRINT_FREQUENCY.");

				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 3:				/* head */
		case 4:				/* heads */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_head);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for heads, in PRINT_FREQUENCY.");

				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 5:				/* flow_balance */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_flow_balance);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for flow-balance data, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 53:				/* bc_flow_rates */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_bc_flow);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for boundary-condition data, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 7:				/* map_head */
		case 8:				/* map_heads */
		case 14:				/* plot_head */
		case 15:				/* plot_heads */
		case 41:				/* xyz_head */
		case 42:				/* xyz_heads */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_xyz_head);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for xyz head data, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 9:				/* map_velocity */
		case 10:				/* map_velocities */
		case 16:				/* plot_velocity */
		case 17:				/* plot_velocities */
		case 43:				/* xyz_velocity */
		case 44:				/* xyz_velocities */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_xyz_velocity);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for xyz velocity data, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 11:				/* concentration */
		case 12:				/* concentrations */
		case 13:				/* selected_output */
		case 18:				/* selected_outputs */
		case 46:				/* xyz_chemistry */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_xyz_chem);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for xyz chemistry data, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 19:				/* wells */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_wells);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for well data, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 20:				/* conductances */
		case 21:				/* conductance */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_conductances);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for conductance data, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 22:				/* well_time_series */
		case 23:				/* wells_time_series */
		case 24:				/* xyz_well */
		case 25:				/* xyz_wells */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_xyz_wells);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for xyz well file, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 27:				/* component */
		case 28:				/* components */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_comp);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for component concentrations file, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 29:				/* plot_component */
		case 30:				/* plot_components */
		case 39:				/* xyz_component */
		case 40:				/* xyz_components */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_xyz_comp);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for xyz component concentrations file, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 31:				/* force_chemistry_print */
		case 47:				/* force_chemistry */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_force_chem);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for chemistry output file, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 32:				/* hdf_concentrations */
		case 33:				/* hdf_concentration */
		case 45:				/* hdf_chemistry */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_hdf_chem);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for chemistry in HDF file, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 34:				/* hdf_heads */
		case 35:				/* hdf_head */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_hdf_head);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for heads in HDF file, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 36:				/* hdf_velocities */
		case 37:				/* hdf_velocity */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_hdf_velocity);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for velocities in HDF file, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 38:				/* save_final_heads */
		case 48:				/* save_head */
		case 49:				/* save_heads */
			save_final_heads = get_true_false(next_char, TRUE);
			break;
		case 50:				/* echo_input */
			pr.echo_input = get_true_false(next_char, TRUE);
			break;
			break;
		case 51:				/* boundary_conditions */
		case 52:				/* boundary */
		case 6:				/* bc */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_bc);
				property_time_ptr->int_value =
					get_true_false(next_char, TRUE);
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 54:				/* restart */
		case 55:				/* restart_file */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_restart);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for restart file, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 56:				/* print_default_end_of_period */
		case 57:				/* end_of_period_default */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_end_of_period);
				property_time_ptr->int_value =
					get_true_false(next_char, TRUE);
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;

		case 58:				/* zone_budget */
		case 59:				/* zone_flow */
		case 60:				/* zone_flow_rates */
		case 61:				/* zone_flows */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_zone_budget);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for zone_budget, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;
		case 62:				/* tsv_zone_flow */
		case 63:				/* tsv_zone_flow_rates */
		case 64:				/* tsv_zone_flows */
			if (current_time.value_defined == TRUE)
			{
				property_time_ptr =
					time_series_alloc_property_time(&print_zone_budget_tsv);
				read_frequency_data(&next_char,
									&(property_time_ptr->time_value),
									"Print frequency for zone_budget tsv, in PRINT_FREQUENCY.");
				time_copy(&current_time, &(property_time_ptr->time));
			}
			else
			{
				input_error++;
				error_msg("No start time for print frequency data", CONTINUE);
			}
			break;		}
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	time_free(&current_time);
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_print_input(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads data for printing input data
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *         KEYWORD if keyword encountered, input_error may be incremented if
 *                    a keyword is encountered in an unexpected position
 *         EOF     if eof encountered while reading mass balance concentrations
 *         ERROR   if error occurred reading data
 *
 */
	int return_value, opt;
	char *next_char;
	const char *opt_list[] = {
		"media_properties",		/* 0 */
		"medium_properties",	/* 1 */
		"media",				/* 2 */
		"medium",				/* 3 */
		"initial_conditions",	/* 4 */
		"initial",				/* 5 */
		"ic",					/* 6 */
		"boundary_conditions",	/* 7 */
		"boundary",				/* 8 */
		"bc",					/* 9 */
		"fluid_properties",		/* 10 */
		"fluid",				/* 11 */
		"solution_method",		/* 12 */
		"method",				/* 13 */
		"wells",				/* 14 */
		"component",			/* 15 */
		"components",			/* 16 */
		"head",					/* 17 */
		"heads",				/* 18 */
		"steady_flow_velocity",	/* 19 */
		"steady_flow_velocities",	/* 20 */
		"plot_component",		/* 21 */
		"plot_components",		/* 22 */
		"plot_head",			/* 23 */
		"plot_heads",			/* 24 */
		"ss_velocity",			/* 25 */
		"ss_velocities",		/* 26 */
		"hdf_concentration",	/* 27 */
		"hdf_concentrations",	/* 28 */
		"hdf_head",				/* 29 */
		"hdf_heads",			/* 30 */
		"hdf_steady_flow_velocity",	/* 31 */
		"hdf_steady_flow_velocities",	/* 32 */
		"xyz_component",		/* 33 */
		"xyz_components",		/* 34 */
		"xyz_head",				/* 35 */
		"xyz_heads",			/* 36 */
		"xyz_steady_flow_velocity",	/* 37 */
		"xyz_steady_flow_velocities",	/* 38 */
		"xyz_concentration",	/* 39 */
		"xyz_concentrations",	/* 40 */
		"hdf_chemistry",		/* 41 */
		"xyz_chemistry",		/* 42 */
		"hdf_ss_velocity",		/* 43 */
		"hdf_ss_velocities",	/* 44 */
		"xyz_ss_velocity",		/* 45 */
		"xyz_ss_velocities",	/* 46 */
		"velocity",				/* 47 */
		"velocities",			/* 48 */
		"hdf_velocity",			/* 49 */
		"hdf_velocities",		/* 50 */
		"xyz_velocity",			/* 51 */
		"xyz_velocities",		/* 52 */
		"force_chemistry",		/* 53 */
		"force_chemistry_print",	/* 54 */
		"echo_input",			/* 55 */
		"xyz_well",				/* 56 */
		"xyz_wells",			/* 57 */
		"conductance",			/* 58 */
		"conductances"			/* 59 */
		, "hdf_media"           /* 60 */
		, "hdf_media_properties" /* 61 */
	};
	int count_opt_list = 62;
/*
 *   Read flags:
 */
	return_value = UNKNOWN;
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			input_error++;
			sprintf(error_string, "Expected identifier for PRINT_INITIAL.");
			error_msg(error_string, CONTINUE);
			break;
		case 0:				/* media_properties */
		case 1:				/* medium_properties */
		case 2:				/* media */
		case 3:				/* medium */
			print_input_media = get_true_false(next_char, TRUE);
			break;
		case 4:				/* initial_conditions */
		case 5:				/* initial */
		case 6:				/* ic */
			warning_msg
				("-initial_conditions identifier is obsolete; Use -head.");
			print_input_head = get_true_false(next_char, TRUE);
			break;
		case 7:				/* boundary_conditions */
		case 8:				/* boundary */
		case 9:				/* bc */
			print_input_bc = get_true_false(next_char, TRUE);
			break;
		case 10:				/* fluid_properties */
		case 11:				/* fluid */
			print_input_fluid = get_true_false(next_char, TRUE);
			break;
		case 12:				/* solution_method */
		case 13:				/* method */
			print_input_method = get_true_false(next_char, TRUE);
			break;
		case 14:				/* wells */
			print_input_wells = get_true_false(next_char, TRUE);
			break;
		case 15:				/* component */
		case 16:				/* components */
			print_input_comp = get_true_false(next_char, TRUE);
			break;
		case 17:				/* head */
		case 18:				/* heads */
			print_input_head = get_true_false(next_char, TRUE);
			break;
		case 19:				/* steady_flow_velocity */
		case 20:				/* steady_flow_velocities */
		case 25:				/* ss_velocity */
		case 26:				/* ss_velocities */
		case 47:				/* velocity */
		case 48:				/* velocities */
			print_input_ss_vel = get_true_false(next_char, TRUE);
			print_input_ss_vel_defined = TRUE;
			break;
		case 21:				/* plot_component */
		case 22:				/* plot_components */
		case 33:				/* xyz_component */
		case 34:				/* xyz_components */
			print_input_xyz_comp = get_true_false(next_char, TRUE);
			break;
		case 23:				/* plot_head */
		case 24:				/* plot_heads */
		case 35:				/* xyz_head */
		case 36:				/* xyz_heads */
			print_input_xyz_head = get_true_false(next_char, TRUE);
			break;
		case 37:				/* xyz_steady_flow_velocity */
		case 38:				/* xyz_steady_flow_velocities */
		case 45:				/* xyz_ss_velocity */
		case 46:				/* xyz_ss_velocities */
		case 49:				/* xyz_velocity */
		case 50:				/* xyz_velocities */
			print_input_xyz_ss_vel = get_true_false(next_char, TRUE);
			print_input_xyz_ss_vel_defined = TRUE;
			break;
		case 27:				/* hdf_concentrations */
		case 28:				/* hdf_concentration */
		case 41:				/* hdf_chemistry */
			print_input_hdf_chem = get_true_false(next_char, TRUE);
			break;
		case 29:				/* hdf_head */
		case 30:				/* hdf_heads */
			print_input_hdf_head = get_true_false(next_char, TRUE);
			break;
		case 31:				/* hdf_steady_flow_velocity */
		case 32:				/* hdf_steady_flow_velocities */
		case 43:				/* hdf_ss_velocity */
		case 44:				/* hdf_ss_velocities */
		case 51:				/* hdf_velocity */
		case 52:				/* hdf_velocities */
			print_input_hdf_ss_vel = get_true_false(next_char, TRUE);
			print_input_hdf_ss_vel_defined = TRUE;
			break;
		case 39:				/* xyz_concentration */
		case 40:				/* xyz_concentrations */
		case 42:				/* xyz_chemistry */
			print_input_xyz_chem = get_true_false(next_char, TRUE);
			break;
		case 53:				/* force_chemistry */
		case 54:				/* force_chemistry_print */
			print_input_force_chem = get_true_false(next_char, TRUE);
			break;
		case 55:				/* echo_input */
			pr.echo_input = get_true_false(next_char, TRUE);
			break;
		case 56:				/* xyz_well */
		case 57:				/* xyz_wells */
			print_input_xyz_wells = get_true_false(next_char, TRUE);
			break;
		case 58:				/* conductance */
		case 59:				/* conductances */
			print_input_conductances = get_true_false(next_char, TRUE);
			break;
		case 60:				/* hdf_media */
		case 61:				/* hdf_media_properties */
			print_input_hdf_media = get_true_false(next_char, TRUE);
			break;
		}
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"PRINT_INITIAL can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_river(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads information for river-type leaky boundary condition
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *         KEYWORD if keyword encountered, input_error may be incremented if
 *                    a keyword is encountered in an unexpected position
 *         EOF     if eof encountered while reading mass balance concentrations
 *         ERROR   if error occurred reading data
 *
 */
	char *next_char, *ptr;
	int return_value, opt;
	int n_user, n_user_end;
	int i, j, l, n;
	River *river_ptr;
	char *description;
	int river_number, point_number;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"associated_solution",	/* 0 */
		"solution",				/* 1 */
		"head",					/* 2 */
		"z",					/* 3 */
		"bottom",				/* 4 */
		"river_bottom",			/* 5 */
		"k",					/* 6 */
		"hydraulic_conductivity",	/* 7 */
		"bed_k",				/* 8 */
		"bed_hydraulic_conductivity",	/* 9 */
		"width",				/* 10 */
		"depth",				/* 11 */
		"thickness",			/* 12 */
		"bed_thickness",		/* 13 */
		"default_k",			/* 14 */
		"default_bed_k",		/* 15 */
		"default_bed_hydraulic_conductivity",	/* 16 */
		"default_depth",		/* 17 */
		"default_solution",		/* 18 */
		"default_width",		/* 19 */
		"default_bed_thickness",	/* 20 */
		"default_thickness",	/* 21 */
		"node",					/* 22 */
		"point",				/* 23 */
		"coordinate_system"		/* 24 */
		,"xy_coordinate_system"	/* 25 */
		,"z_coordinate_system"	/* 26 */
	};
	int count_opt_list = 27;
/*
 *   Read river points
 */
	river_defined = TRUE;
	return_value = UNKNOWN;
	river_ptr = NULL;
	point_number = -1;

	ptr = line;
	read_number_description(ptr, &n_user, &n_user_end, &description);
/*
 *   Find space for river data
 */
	if (n_user >= 0)
	{
		river_ptr = river_search(n_user, &n);
	}
	else
	{
		river_ptr = NULL;
	}
	if (river_ptr == NULL && simulation > 0)
	{
		sprintf(error_string, "River number %d not found for transient data.",
				n_user);
		error_msg(error_string, CONTINUE);
		input_error++;
	}
	if (river_ptr != NULL && simulation == 0)
	{
		sprintf(error_string,
				"River number %d is being deleted and overwritten.", n_user);
		warning_msg(error_string);
		river_free(river_ptr);
	}
	else
	{
		rivers =
			(River *) realloc(rivers,
							  (size_t) (count_rivers + 1) * sizeof(River));
		if (rivers == NULL)
			malloc_error();
		n = count_rivers++;
		river_ptr = &(rivers[n]);
	}
	river_number = n;
	rivers[river_number].points =
		(River_Point *) malloc((size_t) sizeof(River_Point));
	if (rivers[river_number].points == NULL)
		malloc_error();
	rivers[river_number].count_points = 0;
	rivers[river_number].points->polygon = NULL;
	rivers[river_number].new_def = TRUE;
	point_number = -1;
	rivers[river_number].n_user = n_user;
	rivers[river_number].description = description;
	rivers[river_number].coordinate_system = PHAST_Transform::GRID;
	rivers[river_number].z_coordinate_system_user = PHAST_Transform::GRID;
/*
 *   get first line
 */
	sprintf(tag, "in RIVER, definition %d.", n_user);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		/*
		   opt = get_option(opt_list, count_opt_list, &next_char);
		 */
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* associated solution */
		case 1:				/* solution */
			if (point_number < 0)
			{
				sprintf(error_string, "No river point has been defined for "
						"associated solution %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (river_ptr->points[point_number].solution != NULL)
			{
				sprintf(error_string,
						"Solution time series has been redefined %s", tag);
				warning_msg(error_string);
				time_series_free(river_ptr->points[point_number].solution);
				free_check_null(river_ptr->points[point_number].solution);
				river_ptr->points[point_number].solution = NULL;
			}
			river_ptr->points[point_number].solution =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (river_ptr->points[point_number].solution == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading associated solution %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			else
			{
				river_ptr->points[point_number].solution_defined = TRUE;
			}
			break;
		case 2:				/* head */
			if (simulation > 0 && steady_flow == TRUE)
			{
				input_error++;
				sprintf(error_string,
						"Head for river can not be changed in STEADY_FLOW calculations.");
				error_msg(error_string, CONTINUE);
			}

			if (point_number < 0)
			{
				sprintf(error_string, "No river point has been defined for "
						"head %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (river_ptr->points[point_number].head != NULL)
			{
				sprintf(error_string,
						"Head time series has been redefined %s", tag);
				warning_msg(error_string);
				time_series_free(river_ptr->points[point_number].head);
				free_check_null(river_ptr->points[point_number].head);
				river_ptr->points[point_number].head = NULL;
			}
			river_ptr->points[point_number].head =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (river_ptr->points[point_number].head == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading head %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			else
			{
				river_ptr->points[point_number].head_defined = TRUE;
			}
			break;
		case 3:				/* z */
		case 4:				/* bottom */
		case 5:				/* river_bottom */
			if (simulation > 0)
			{
				sprintf(error_string,
						"Top of river bottom can only be defined in first simulation period\n\t%s",
						tag);
				warning_msg(error_string);
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (point_number < 0)
			{
				sprintf(error_string, "No river point has been defined for "
						"top of river bottom %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected top of river bottom for river point. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &river_ptr->points[point_number].z_user);
				river_ptr->points[point_number].z_user_defined = TRUE;
				//river_ptr->points[point_number].z_input_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 6:				/* k */
		case 7:				/* hydraulic_conductivity */
		case 8:				/* bed_k */
		case 9:				/* bed_hydraulic_conductivity */
			if (simulation > 0)
			{
				sprintf(error_string,
						"Bed hydraulic conductivity can only be defined in the first simulation period\n\t%s",
						tag);
				warning_msg(error_string);
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (point_number < 0)
			{
				sprintf(error_string, "No river point has been defined for "
						"bed hydraulic conductivity %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected bed hydraulic conductivity for river point. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &river_ptr->points[point_number].k);
				river_ptr->points[point_number].k_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 10:				/* width */
			if (simulation > 0)
			{
				sprintf(error_string,
						"Width can only be defined in first simulation period\n\t%s",
						tag);
				warning_msg(error_string);
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (point_number < 0)
			{
				sprintf(error_string, "No river point has been defined for "
						"width %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string, "Expected width at river point. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &river_ptr->points[point_number].width_user);
				river_ptr->points[point_number].width_user_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 11:				/* depth */
			river_depths_defined = true;
			if (simulation > 0)
			{
				sprintf(error_string,
						"Depth can only be defined in first simulation period\n\t%s",
						tag);
				warning_msg(error_string);
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (point_number < 0)
			{
				sprintf(error_string, "No river point has been defined for "
						"depth %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string, "Expected depth at river point. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &river_ptr->points[point_number].depth_user);
				river_ptr->points[point_number].depth_user_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 12:				/* thickness */
		case 13:				/* bed_thickness */
			if (simulation > 0)
			{
				sprintf(error_string,
						"Bed thickness can only be defined in the first simulation period\n\t%s",
						tag);
				warning_msg(error_string);
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (point_number < 0)
			{
				sprintf(error_string, "No river point has been defined for "
						"bed thickness %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected bed thickness for river point. %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf",
					   &river_ptr->points[point_number].thickness);
				river_ptr->points[point_number].thickness_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 14:				/* default_k */
		case 15:				/* default_bed_k */
		case 16:				/* default_bed_hydraulic_conductivity */
			sprintf(error_string,
					"Default bed hydraulic conductivity identifier is obsolete; use interpolation as described for head.\n\t%s",
					tag);
			warning_msg(error_string);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 17:				/* default depth */
			sprintf(error_string,
					"Default depth identifier is obsolete; use interpolation as described for head.\n\t%s",
					tag);
			warning_msg(error_string);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 18:				/* default_solution */
			sprintf(error_string,
					"Default solution identifier is obsolete; use interpolation as described for head.\n\t%s",
					tag);
			warning_msg(error_string);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 19:				/* default width */
			sprintf(error_string,
					"Default width identifier is obsolete; use interpolation as described for head.\n\t%s",
					tag);
			warning_msg(error_string);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 20:				/* default_bed_thickness */
		case 21:				/* default_thickness */
			sprintf(error_string,
					"Default bed thickness identifier is obsolete; use interpolation as described for head.\n\t%s",
					tag);
			warning_msg(error_string);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 22:				/* node */
		case 23:				/* point */
			/* case OPTION_DEFAULT:  *//* Read x, y */
			river_ptr->points =
				(River_Point *) realloc(river_ptr->points,
										(size_t) ((river_ptr->count_points +
												   1) *
												  (sizeof(River_Point))));
			if (river_ptr->points == NULL)
				malloc_error();
			point_number = river_ptr->count_points++;
			river_point_init(&(river_ptr->points[point_number]));
			river_ptr->points[point_number].width_grid = 0.0;
			for (i = 0; i < 4; i++)
			{
				river_ptr->points[point_number].vertex[i].x = 0.0;
				river_ptr->points[point_number].vertex[i].y = 0.0;
			}
			river_ptr->points[point_number].polygon = NULL;
			river_ptr->points[point_number].update = 0;
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected an X value of river point. %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &river_ptr->points[point_number].x_user);
				river_ptr->points[point_number].x_user_defined = TRUE;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected an Y value of river point. %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &river_ptr->points[point_number].y_user);
				river_ptr->points[point_number].y_user_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 24:				/* coordinate_system */
		case 25:				/* xy_coordinate_system */
			j = copy_token(token, &next_char, &l);
			str_tolower(token);
			if (strstr(token, "map") == token)
			{
				river_ptr->coordinate_system = PHAST_Transform::MAP;
			}
			else if (strstr(token, "grid") == token)
			{
				river_ptr->coordinate_system = PHAST_Transform::GRID;
			}
			else
			{
				sprintf(error_string,
						"Expected coordinate system for river points. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 26:				/* z_coordinate_system */
			j = copy_token(token, &next_char, &l);
			str_tolower(token);
			if (strstr(token, "map") == token)
			{
				river_ptr->z_coordinate_system_user = PHAST_Transform::MAP;
			}
			else if (strstr(token, "grid") == token)
			{
				river_ptr->z_coordinate_system_user = PHAST_Transform::GRID;
			}
			else
			{
				sprintf(error_string,
						"Expected coordinate system for river bottoms. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_number_description(char *ptr, int *n_user,
						int *n_user_end, char **description)
/* ---------------------------------------------------------------------- */
{
	int l, n;
	char token[MAX_LENGTH];
	char *ptr1;
/*
 *   Read user number
 */
	copy_token(token, &ptr, &l);
	ptr1 = ptr;
	if (copy_token(token, &ptr, &l) != DIGIT)
	{
		*n_user = -1;
		*n_user_end = -1;
	}
	else if (strstr(token, "-") != NULL)
	{
		replace("-", " ", token);
		n = sscanf(token, "%d%d", n_user, n_user_end);
		if (n != 2)
		{
			sprintf(error_string, "Reading number range for %s.",
					keyword[next_keyword].name);
			error_msg(error_string, CONTINUE);
			input_error++;
		}
		ptr1 = ptr;
	}
	else
	{
		sscanf(token, "%d", n_user);
		*n_user_end = *n_user;
		ptr1 = ptr;
	}
/*
 *   Read description
 */
	for (; isspace((int) ptr1[0]); ptr1++);
	*description = string_duplicate(ptr1);
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
read_well(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads information for well information
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *         KEYWORD if keyword encountered, input_error may be incremented if
 *                    a keyword is encountered in an unexpected position
 *         EOF     if eof encountered while reading mass balance concentrations
 *         ERROR   if error occurred reading data
 *
 */
	char *next_char, *ptr;
	char *description;
	int return_value, opt;
	int i, j, l, n;
	int n_user, n_user_end;
	Well *well_ptr;
	int well_number;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"associated_solution",	/* 0 */
		"solution",				/* 1 */
		"lsd",					/* 2 */
		"land_surface_datum",	/* 3 */
		"radius",				/* 4 */
		"depths",				/* 5 */
		"allocate_by_pressure_and_mobility",	/* 6 */
		"depth",				/* 7 */
		"diameter",				/* 8 */
		"elevation",			/* 9 */
		"elevations",			/* 10 */
		"pumpage",				/* 11 */
		"pumping",				/* 12 */
		"pumping_rate",			/* 13 */
		"injection",			/* 14 */
		"injection_rate",		/* 15 */
		"allocation_by_pressure_and_mobility",	/* 16 */
		"pressure_and_mobility",	/* 17 */
		"allocate_by_head_and_mobility",	/* 18 */
		"allocation_by_head_and_mobility",	/* 19 */
		"head_and_mobility",	/* 20 */
		"coordinate_system"		/* 21 */
		, "z_coordinate_system"         /* 22 */
		, "xy_coordinate_system"        /* 23 */
		, "xy_location"                 /* 24 */
		, "location"                    /* 25 */
	};
	int count_opt_list = 26;
/*
 *   Read well information
 */
	well_defined = TRUE;
	return_value = UNKNOWN;
	well_ptr = NULL;

	ptr = line;
	read_number_description(ptr, &n_user, &n_user_end, &description);
/*
 *   Find space for well data
 */
	if (n_user >= 0)
	{
		well_ptr = well_search(n_user, &n);
	}
	else
	{
		well_ptr = NULL;
	}
	if (well_ptr == NULL)
	{
		if (simulation > 0)
		{
			sprintf(error_string,
					"Well number %d not found for transient data.", n_user);
			error_msg(error_string, CONTINUE);
			input_error++;
		}
		else
		{
			wells =
				(Well *) realloc(wells,
								 (size_t) (count_wells + 1) * sizeof(Well));
			if (wells == NULL)
				malloc_error();
			n = count_wells++;
			well_ptr = &(wells[n]);
		}
	}
	else
	{
		assert(simulation == 0);
		sprintf(error_string,
				"Well number %d is being deleted and overwritten.", n_user);
		warning_msg(error_string);
		well_free(well_ptr);
	}

	/*
	 *   Initialize well
	 */
	well_ptr->depth_user =
		(Well_Interval *) malloc((size_t) sizeof(Well_Interval));
	if (well_ptr->depth_user == NULL)
		malloc_error();
	well_ptr->count_depth_user = 0;
	well_ptr->elevation_user =
		(Well_Interval *) malloc((size_t) sizeof(Well_Interval));
	if (well_ptr->elevation_user == NULL)
		malloc_error();
	well_ptr->count_elevation_user = 0;
	well_ptr->cell_fraction =
		(Cell_Fraction *) malloc((size_t) sizeof(Cell_Fraction));
	if (well_ptr->cell_fraction == NULL)
		malloc_error();
	well_ptr->count_cell_fraction = 0;
	well_ptr->new_def = TRUE;
	well_ptr->n_user = n_user;
	well_ptr->description = description;
	well_ptr->x_user = 0;
	well_ptr->x_user_defined = FALSE;
	well_ptr->y_user = 0;
	well_ptr->y_user_defined = FALSE;
	well_ptr->radius = 0;
	well_ptr->radius_defined = FALSE;
	well_ptr->diameter = 0;
	well_ptr->solution = NULL;
	well_ptr->solution_defined = FALSE;
	well_ptr->lsd_user = 0;
	well_ptr->lsd_user_defined = FALSE;
	well_ptr->mobility_and_pressure = FALSE;
	well_ptr->depth_user_defined = FALSE;
	well_ptr->count_depth_user = 0;
	well_ptr->elevation_user_defined = FALSE;
	well_ptr->count_elevation_user = 0;
	well_ptr->q = NULL;
	well_ptr->q_defined = FALSE;
	well_ptr->diameter = 0;
	well_ptr->diameter_defined = FALSE;
	well_ptr->radius = 0;
	well_ptr->radius_defined = FALSE;
	well_ptr->xy_coordinate_system_user = PHAST_Transform::GRID;
	well_ptr->z_coordinate_system_user = PHAST_Transform::GRID;
	//well_ptr->depth_units_user = new cunit("m");
	well_ptr->elevation_grid = NULL;

	well_number = n;
/*
 *   get first line
 */
	sprintf(tag, "in WELLS, definition %d.", n_user);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		/*
		   opt = get_option(opt_list, count_opt_list, &next_char);
		 */
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = get_option(opt_list, count_opt_list, &next_char);
			//opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* associated solution */
		case 1:				/* solution */
			if (well_ptr->solution != NULL)
			{
				sprintf(error_string,
						"Solution time series has been redefined %s", tag);
				warning_msg(error_string);
				time_series_free(well_ptr->solution);
				free_check_null(well_ptr->solution);
				well_ptr->solution = NULL;
			}
			well_ptr->solution =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			/* sscanf(token, "%d", &well_ptr->solution); */
			if (well_ptr->solution == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading associated solution %s", tag);
				error_msg(error_string, CONTINUE);
				opt = get_option(opt_list, count_opt_list, &next_char);
				//opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			else
			{
				well_ptr->solution_defined = TRUE;
			}
			break;
		case 2:				/* lsd */
		case 3:				/* land_surface_datum */
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected land surface datum for well. %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &well_ptr->lsd_user);
				well_ptr->lsd_user_defined = TRUE;
			}
			/* read to next */
			opt = get_option(opt_list, count_opt_list, &next_char);
			//opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 4:				/* radius */
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string, "Expected radius of well %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &well_ptr->radius);
				well_ptr->radius_defined = TRUE;
			}
			/* read to next */
			opt = get_option(opt_list, count_opt_list, &next_char);
			//opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 8:				/* diameter */
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string, "Expected diameter for well point. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &well_ptr->diameter);
				well_ptr->diameter_defined = TRUE;
			}
			/* read to next */
			opt = get_option(opt_list, count_opt_list, &next_char);
			//opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 6:				/* allocate_by_pressure_and_mobility */
		case 16:				/* allocation_by_pressure_and_mobility */
		case 17:				/* pressure_and_mobility */
		case 18:				/* allocate_by_head_and_mobility */
		case 19:				/* allocation_by_head_and_mobility */
		case 20:				/* head_and_mobility */
			well_ptr->mobility_and_pressure = get_true_false(next_char, TRUE);
			/* read to next */
			opt = get_option(opt_list, count_opt_list, &next_char);
			//opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 7:				/* depth */
		case 5:				/* depths */
			well_depths_defined = true;
			well_ptr->depth_user =
				(Well_Interval *) realloc(well_ptr->depth_user,
										  (size_t) (well_ptr->count_depth_user +
													1) *
										  sizeof(Well_Interval));
			if (well_ptr->depth_user == NULL)
				malloc_error();
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected first depth for screen interval. %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf",
					   &well_ptr->depth_user[well_ptr->count_depth_user].top);
				j = copy_token(token, &next_char, &l);
				if (j != DIGIT)
				{
					sprintf(error_string,
							"Expected second depth for screen interval. %s",
							tag);
					error_msg(error_string, CONTINUE);
					input_error++;
				}
				else
				{
					sscanf(token, "%lf",
						   &well_ptr->depth_user[well_ptr->count_depth_user].bottom);
					well_ptr->depth_user_defined = TRUE;
					well_ptr->count_depth_user++;
				}
			}
			/* read to next */
			opt = get_option(opt_list, count_opt_list, &next_char);
			//opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 9:				/* elevation */
		case 10:				/* elevations */
			well_ptr->elevation_user =
				(Well_Interval *) realloc(well_ptr->elevation_user,
										  (size_t) (well_ptr->
													count_elevation_user +
													1) *
										  sizeof(Well_Interval));
			if (well_ptr->elevation_user == NULL)
				malloc_error();
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected first elevation for screen interval. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf",
					   &well_ptr->elevation_user[well_ptr->count_elevation_user].top);
				j = copy_token(token, &next_char, &l);
				if (j != DIGIT)
				{
					sprintf(error_string,
							"Expected second elevation for screen interval. %s",
							tag);
					error_msg(error_string, CONTINUE);
					input_error++;
				}
				else
				{
					sscanf(token, "%lf",
						   &well_ptr->elevation_user[well_ptr->count_elevation_user].bottom);
					well_ptr->elevation_user_defined = TRUE;
					well_ptr->count_elevation_user++;
				}
			}
			/* read to next */
			opt = get_option(opt_list, count_opt_list, &next_char);
			//opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 11:				/* pumpage */
		case 12:				/* pumping */
		case 13:				/* pumping_rate */
			if (well_ptr->q != NULL)
			{
				sprintf(error_string,
						"Injection/pumping time series has been redefined %s",
						tag);
				warning_msg(error_string);
				time_series_free(well_ptr->q);
				free_check_null(well_ptr->q);
				well_ptr->q = NULL;
			}
			well_ptr->q =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (well_ptr->q == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading pumping rate %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			else
			{
				well_ptr->q_defined = TRUE;
				for (i = 0; i < well_ptr->q->count_properties; i++)
				{
					well_ptr->q->properties[i]->property->v[0] *= -1;
				}
			}
			break;
		case 14:				/* injection */
		case 15:				/* injection_rate */
			if (well_ptr->q != NULL)
			{
				sprintf(error_string,
						"Injection/pumping time series has been redefined %s",
						tag);
				warning_msg(error_string);
				time_series_free(well_ptr->q);
				free_check_null(well_ptr->q);
				well_ptr->q = NULL;
			}
			well_ptr->q =
				time_series_read_property(next_char, opt_list, count_opt_list,
										  &opt);
			if (well_ptr->q == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading injection rate %s", tag);
				error_msg(error_string, CONTINUE);
				opt = next_keyword_or_option(opt_list, count_opt_list);
			}
			else
			{
				well_ptr->q_defined = TRUE;
			}
			break;
		case OPTION_DEFAULT:	/* Read x, y */
		case 24:	/*xy_location */
		case 25:	/*location */
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected an X value of well location. %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &well_ptr->x_user);
				well_ptr->x_user_defined = TRUE;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected an Y value of well location. %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &well_ptr->y_user);
				well_ptr->y_user_defined = TRUE;
			}
			/* read to next */
			opt = get_option(opt_list, count_opt_list, &next_char);
			//opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 21:				/* coordinate_system */
		case 23:				/* xy_coordinate_system */	
			j = copy_token(token, &next_char, &l);
			str_tolower(token);
			if (strstr(token, "map") == token)
			{
				well_ptr->xy_coordinate_system_user = PHAST_Transform::MAP;
			}
			else if (strstr(token, "grid") == token)
			{
				well_ptr->xy_coordinate_system_user = PHAST_Transform::GRID;
			}
			else
			{
				sprintf(error_string,
						"Expected coordinate system for well location. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			opt = get_option(opt_list, count_opt_list, &next_char);
			//opt = next_keyword_or_option(opt_list, count_opt_list);
			break;

		case 22:				/* elevation_coordinate_system */
			j = copy_token(token, &next_char, &l);
			str_tolower(token);
			if (strstr(token, "map") == token)
			{
				well_ptr->z_coordinate_system_user = PHAST_Transform::MAP;
			}
			else if (strstr(token, "grid") == token)
			{
				well_ptr->z_coordinate_system_user = PHAST_Transform::GRID;
			}
			else
			{
				sprintf(error_string,
						"Expected coordinate system for LSD and -elevation data. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			opt = get_option(opt_list, count_opt_list, &next_char);
			//opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_print_locations(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads zones for printing
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	char *next_char, *ptr;
	int return_value, opt;
	int i, j, l;
	char token[MAX_LENGTH];
	struct print_zones *print_zones_ptr;
	struct print_zones_struct *print_zones_struct_ptr;
	const char *opt_list[] = {
		"zone",					/* 0 */
		"print",				/* 1 */
		"thin_grid",			/* 2 */
		"thin",					/* 3 */
		"sample_grid",			/* 4 */
		"sample",				/* 5 */
		"xyz_chemistry",		/* 6 */
		"hdf_chemistry",		/* 7 */
		"chemistry",			/* 8 */
		"mask",					/* 9 */
		"wedge",				/* 10 */
		"prism",				/* 11 */
		"vector",				/* 12 */
		"perimeter",			/* 13 */
		"top",					/* 14 */
		"bottom",				/* 15 */
		"description"			/* 16 */
		,"box"                  /* 17 */
	};
	int count_opt_list = 18;
	int count_zones = 0;

	/*
	 *   Read zones for printing
	 */
	return_value = UNKNOWN;
	/*
	 *   get first line
	 */
	print_zones_ptr = NULL;
	print_zones_struct_ptr = NULL;
	Prism *prism_ptr = NULL;
	/* if 3 print zones are used (chem, xyz, hdf), remove following statement */
	print_zones_struct_ptr = &print_zones_xyz;
	sprintf(tag, "in PRINT_LOCATIONS, definition %d.", count_zones + 1);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* zone */
		case 17:			/* box */
			count_zones++;
			/*
			 *   Allocate space for print_zone, read zone data
			 */
			if (print_zones_struct_ptr == NULL)
			{
				sprintf(error_string,
						"First identifier must be -xyz_chemistry or -chemistry %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}

			print_zones_struct_ptr->print_zones =
				(struct print_zones *) realloc(print_zones_struct_ptr->
											   print_zones,
											   (size_t) ((print_zones_struct_ptr)->count_print_zones + 1) * sizeof(struct print_zones));
			if (print_zones_struct_ptr->print_zones == NULL)
				malloc_error();
			print_zones_ptr =
				&(print_zones_struct_ptr->
				  print_zones[print_zones_struct_ptr->count_print_zones]);
			/* initialize */
			print_zones_ptr->print = NULL;
			print_zones_ptr->mask = NULL;
			print_zones_struct_ptr->count_print_zones++;
			sprintf(tag, "in PRINT_LOCATIONS, definition %d.", count_zones);

			print_zones_ptr->polyh = read_cube(&next_char);
			if (print_zones_ptr->polyh == NULL)
			{
				sprintf(error_string, "Reading zone %s", tag);
				error_msg(error_string, CONTINUE);
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 1:				/* print */
			count_zones++;
			/*
			 *   Read print property
			 */
			if (print_zones_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"-print %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (print_zones_ptr->print != NULL)
			{
				sprintf(error_string, "Print has been redefined %s", tag);
				warning_msg(error_string);
				property_free(print_zones_ptr->print);
				print_zones_ptr->print = NULL;
			}
			print_zones_ptr->print =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			break;
		case 2:				/* thin_grid */
		case 3:				/* thin */
		case 4:				/* sample_grid */
		case 5:				/* sample */
			count_zones++;
			/* read direction */
			i = copy_token(token, &next_char, &l);
			if (i == EMPTY)
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			str_tolower(token);
			if (token[0] == 'x')
			{
				j = 0;
			}
			else if (token[0] == 'y')
			{
				j = 1;
			}
			else if (token[0] == 'z')
			{
				j = 2;
			}
			else
			{
				error_msg("Expected a coordinate direction, x, y, or z.",
						  CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			ptr = next_char;
			if (sscanf
				(next_char, "%d",
				 &(print_zones_struct_ptr->thin_grid[j])) != 1)
			{
				sprintf(error_string,
						"Expected frequency of nodes to sample for %c -sample_grid information.",
						grid[j].c);
				error_msg(error_string, CONTINUE);
				error_msg(line_save, CONTINUE);
				input_error++;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 6:				/* xyz_chemistry */
			count_zones++;
			/*
			 *   Reading xyz_chemistry print mask
			 */
			print_zones_struct_ptr = &print_zones_xyz;
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 7:				/* hdf_chemistry */
			count_zones++;
			/*
			 *   Reading hdf_chemistry print mask
			 */
			sprintf(error_string,
					"-hdf_chemistry not supported for data block PRINT_LOCATIONS");
			error_msg(error_string, CONTINUE);
			input_error++;

			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 8:				/* chemistry */
			count_zones++;
			/*
			 *   Reading chemistry print mask
			 */
			print_zones_struct_ptr = &print_zones_chem;
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 9:				/* mask */
			if (print_zones_ptr == NULL)
			{
				sprintf(error_string, "Zone has not been defined for "
						"mask %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (print_zones_ptr->mask != NULL)
			{
				sprintf(error_string,
						"Mask for this zone is being redefined %s", tag);
				warning_msg(error_string);
				property_free(print_zones_ptr->mask);
				print_zones_ptr->mask = NULL;
			}
			print_zones_ptr->mask =
				read_property(next_char, opt_list, count_opt_list, &opt, TRUE,
							  FALSE);
			if (print_zones_ptr->mask == NULL)
			{
				input_error++;
				sprintf(error_string, "Reading mask %s", tag);
				error_msg(error_string, CONTINUE);
			}
			break;
		case 10:				/* wedge */
			count_zones++;
			/*
			 *   Allocate space for print_zone, read wedge data
			 */
			if (print_zones_struct_ptr == NULL)
			{
				sprintf(error_string,
						"First identifier must be -xyz_chemistry or -chemistry %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}

			print_zones_struct_ptr->print_zones =
				(struct print_zones *) realloc(print_zones_struct_ptr->
											   print_zones,
											   (size_t) ((print_zones_struct_ptr)->count_print_zones + 1) * sizeof(struct print_zones));
			if (print_zones_struct_ptr->print_zones == NULL)
				malloc_error();
			print_zones_ptr =
				&(print_zones_struct_ptr->
				  print_zones[print_zones_struct_ptr->count_print_zones]);
			/* initialize */
			print_zones_ptr->print = NULL;
			print_zones_ptr->mask = NULL;
			print_zones_struct_ptr->count_print_zones++;
			sprintf(tag, "in PRINT_LOCATIONS, definition %d.", count_zones);

			print_zones_ptr->polyh = read_wedge(&next_char);
			{
				Wedge *w_ptr =
					dynamic_cast < Wedge * >(print_zones_ptr->polyh);
				if (print_zones_ptr->polyh == NULL
					|| w_ptr->orientation == Wedge::WEDGE_ERROR)
				{
					input_error++;
					sprintf(error_string, "Reading wedge %s", tag);
					error_msg(error_string, CONTINUE);
				}
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 11:				/* prism */
			{
				if (print_zones_struct_ptr == NULL)
				{
					sprintf(error_string,
							"First identifier must be -xyz_chemistry or -chemistry %s",
							tag);
					error_msg(error_string, CONTINUE);
					input_error++;
					opt = next_keyword_or_option(opt_list, count_opt_list);
					break;
				}

				print_zones_struct_ptr->print_zones =
					(struct print_zones *) realloc(print_zones_struct_ptr->
												   print_zones,
												   (size_t) ((print_zones_struct_ptr)->count_print_zones + 1) * sizeof(struct print_zones));
				if (print_zones_struct_ptr->print_zones == NULL)
					malloc_error();
				print_zones_ptr =
					&(print_zones_struct_ptr->
					  print_zones[print_zones_struct_ptr->count_print_zones]);
				/* initialize */
				print_zones_ptr->print = NULL;
				print_zones_ptr->mask = NULL;
				print_zones_struct_ptr->count_print_zones++;
				sprintf(tag, "in PRINT_LOCATIONS, definition %d.",
						count_zones);

				prism_ptr = new Prism;
				print_zones_ptr->polyh = prism_ptr;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}

		case 12:				/* vector */
		case 13:				/* perimeter */
		case 14:				/* top */
		case 15:				/* bottom */
			{
				std::istringstream lines;
				// opt = streamify_to_next_keyword_or_option(opt_list,
				//										count_opt_list,
				//										lines);
				opt = streamify_prism_piece(opt_list,
					count_opt_list,
					lines);
				if (print_zones_ptr == NULL || print_zones_ptr->polyh == NULL
					|| prism_ptr == NULL || !prism_ptr->Read(lines))
				{
					input_error++;
					sprintf(error_string, "Reading prism %s", tag);
					error_msg(error_string, CONTINUE);
					break;
				}
			}
			break;
		case 16:				/* description */
			/* read description */
			if (print_zones_ptr == NULL)
			{
				sprintf(error_string,
						"Zone, wedge, or prism has not been defined for description %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (print_zones_ptr->polyh->Get_description()->size() != 0)
			{
				sprintf(error_string, "Description has been redefined %s",
						tag);
				warning_msg(error_string);
				print_zones_ptr->polyh->Get_description()->clear();
			}
			//std::string str(next_char);
			print_zones_ptr->polyh->Get_description()->assign(next_char);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
read_steady_flow(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads steady flow information
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *         KEYWORD if keyword encountered, input_error may be incremented if
 *                    a keyword is encountered in an unexpected position
 *         EOF     if eof encountered while reading mass balance concentrations
 *         ERROR   if error occurred reading data
 *
 */
	char *next_char, *ptr;
	int return_value, opt;
	int j, l;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"xxx_flow_only",		/* 0 */
		"xxx_steady_flow",		/* 1 */
		"head_tol",				/* 2 */
		"head_tolerance",		/* 3 */
		"flow_tol",				/* 4 */
		"flow_tolerance",		/* 5 */
		"flow_balance_tol",		/* 6 */
		"flow_balance_tolerance",	/* 7 */
		"minimum_time_step",	/* 8 */
		"minimum_time",			/* 9 */
		"minimum",				/* 10 */
		"maximum_time_step",	/* 11 */
		"maximum_time",			/* 12 */
		"maximum",				/* 13 */
		"head_change_limit",	/* 14 */
		"head_limit",			/* 15 */
		"head_change",			/* 16 */
		"save_head",			/* 17 */
		"save_heads",			/* 18 */
		"save_steady_state_head",	/* 19 */
		"save_steady_head",		/* 20 */
		"save_steady_heads",	/* 21 */
		"save_steady_state_heads",	/* 22 */
		"head_change_target",	/* 23 */
		"head_target",			/* 24 */
		"iterations",			/* 25 */
		"growth_factor"			/* 26 */
	};
	int count_opt_list = 27;
/*
 *  Set true false
 */
	ptr = line;
	/* read keyword */
	j = copy_token(token, &ptr, &l);

	/* read true or false */
	steady_flow = get_true_false(ptr, TRUE);
/*
 *   Read flow information
 */
	return_value = UNKNOWN;
/*
 *   get first line
 */
	sprintf(tag, "in STEADY_FLOW, definition.");
	for (;;)
	{
		opt = get_option(opt_list, count_opt_list, &next_char);
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* flow_only */
			warning_msg
				("Option -flow_only is obsolete; use T/F on SOLUTE_TRANSPORT keyword.");
			/* flow_only = get_true_false(next_char, TRUE); */
			break;
		case 1:				/* steady_flow */
			warning_msg
				("Option -steady_flow is obsolete; use T/F on STEADY_FLOW keyword.");
			/* steady_flow = get_true_false(next_char, TRUE); */
			break;
		case 2:				/* head_tol */
		case 3:				/* head_tolerance */
			ptr = next_char;
			j = copy_token(token, &ptr, &l);
			if (j == DIGIT)
			{
				sscanf(token, "%lf", &eps_head);
			}
			else if (j != EMPTY)
			{
				sprintf(error_string,
						"Expected tolerance for head in steady-state flow: %s",
						line);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			break;
		case 4:				/* flow_tol */
		case 5:				/* flow_tolerance */
		case 6:				/* flow_balance_tol */
		case 7:				/* flow_balance_tolerance */
			ptr = next_char;
			j = copy_token(token, &ptr, &l);
			if (j == DIGIT)
			{
				sscanf(token, "%lf", &eps_mass_balance);
			}
			else if (j != EMPTY)
			{
				sprintf(error_string,
						"Expected tolerance for mass balance in steady-state flow: %s",
						line);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			break;
		case 8:				/* minimum_time_step */
		case 9:				/* minimum_time */
		case 10:				/* minimum */
			read_time_data(&next_char, &min_ss_time_step,
						   "minimum time step for steady-state flow calculation.");
			break;
		case 11:				/* maximum_time_step */
		case 12:				/* maximum_time */
		case 13:				/* maximum */
			read_time_data(&next_char, &max_ss_time_step,
						   "maximum time step for steady-state flow calculation.");
			break;
		case 14:				/* head_change_limit */
		case 15:				/* head_limit */
		case 16:				/* head_change */
		case 23:				/*head_change_target */
		case 24:				/*head_target */
			ptr = next_char;
			j = copy_token(token, &ptr, &l);
			if (j == DIGIT)
			{
				sscanf(token, "%lf", &max_ss_head_change);
			}
			else if (j != EMPTY)
			{
				sprintf(error_string,
						"Expected target for maximum head change for a time step for steady-state flow calculation: %s",
						line);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			break;
		case 17:				/* save_head */
		case 18:				/* save_heads */
		case 19:				/* save_steady_state_heads */
		case 20:				/* save_steady_head */
		case 21:				/* save_steady_heads */
		case 22:				/* save_steady_state_head */
			warning_msg
				("-save_steady_state_heads has been replaced with -save_final_heads in PRINT_FREQUENCY");
			/* save_steady_state_heads = get_true_false(next_char, TRUE); */
			save_final_heads = get_true_false(next_char, TRUE);
			break;
		case 25:				/*iterations */
			ptr = next_char;
			j = copy_token(token, &ptr, &l);
			if (j == DIGIT)
			{
				sscanf(token, "%d", &max_ss_iterations);
			}
			else if (j != EMPTY)
			{
				sprintf(error_string,
						"Expected maximum number of iterations for attempting to find steady state flow condition: %s",
						line);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			break;
		case 26:				/*growth_factor */
			ptr = next_char;
			j = copy_token(token, &ptr, &l);
			if (j == DIGIT)
			{
				sscanf(token, "%lf", &growth_factor_ss);
			}
			else if (j != EMPTY)
			{
				sprintf(error_string,
						"Expected growth factor for automatic time stepping: %s",
						line);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	if (simulation > 0)
	{
		input_error++;
		sprintf(error_string,
				"STEADY_FLOW can only be defined in first simulation period.");
		error_msg(error_string, CONTINUE);
	}
	return (return_value);
}

#include "Drain.h"
/* ---------------------------------------------------------------------- */
int
read_drain(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads information for drain-type leaky boundary condition
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	char *next_char, *ptr;
	int return_value, opt;
	int n_user, n_user_end;
	int j, l;

	char *description;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"z",					/* 0 */
		"bottom",				/* 1 */
		"drain_bottom",			/* 2 */
		"k",					/* 3 */
		"hydraulic_conductivity",	/* 4 */
		"bed_k",				/* 5 */
		"bed_hydraulic_conductivity",	/* 6 */
		"width",				/* 7 */
		"thickness",			/* 8 */
		"bed_thickness",		/* 9 */
		"node",					/* 10 */
		"point",				/* 11 */
		"coordinate_system"		/* 12 */
		, "xy_coordinate_system"		/* 13 */
		, "z_coordinate_system"		/* 14 */
	};
	int count_opt_list = 15;
	/*
	 *   Read drain points
	 */
	return_value = UNKNOWN;

	ptr = line;
	read_number_description(ptr, &n_user, &n_user_end, &description);
	/*
	 *   Find space for drain data
	 */
	Drain *drain = new Drain;

	drain->n_user = n_user;
	drain->description.append(description);
	free_check_null(description);
	River_Point rp;

	River_Point *rp_ptr = &rp;
	river_point_init(rp_ptr);

	/*
	 *   get first line
	 */
	sprintf(tag, "in drain, definition %d.", n_user);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		/*
		   opt = get_option(opt_list, count_opt_list, &next_char);
		 */
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;

		case 0:				/* z */
		case 1:				/* bottom */
		case 2:				/* drain_bottom */
			if (simulation > 0)
			{
				sprintf(error_string,
						"Drain elevation can only be defined in first simulation period\n\t%s",
						tag);
				warning_msg(error_string);
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (rp_ptr->x_user_defined == 0)
			{
				sprintf(error_string, "No drain point has been defined for "
						"top of drain bottom %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string, "Expected elevation of drain point. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &rp_ptr->z_user);
				rp_ptr->z_user_defined = TRUE;
				//rp_ptr->z_input_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 3:				/* k */
		case 4:				/* hydraulic_conductivity */
		case 5:				/* bed_k */
		case 6:				/* bed_hydraulic_conductivity */
			if (simulation > 0)
			{
				sprintf(error_string,
						"Bed hydraulic conductivity can only be defined in the first simulation period\n\t%s",
						tag);
				warning_msg(error_string);
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (rp_ptr->x_user_defined == 0)
			{
				sprintf(error_string, "No drain point has been defined for "
						"bed hydraulic conductivity %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected bed hydraulic conductivity for drain point. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &rp_ptr->k);
				rp_ptr->k_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 7:				/* width */
			if (simulation > 0)
			{
				sprintf(error_string,
						"Width can only be defined in first simulation period\n\t%s",
						tag);
				warning_msg(error_string);
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (rp_ptr->x_user_defined == 0)
			{
				sprintf(error_string, "No drain point has been defined for "
						"width %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string, "Expected width at drain point. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &rp_ptr->width_user);
				rp_ptr->width_user_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;

		case 8:				/* thickness */
		case 9:				/* bed_thickness */
			if (simulation > 0)
			{
				sprintf(error_string,
						"Bed thickness can only be defined in the first simulation period\n\t%s",
						tag);
				warning_msg(error_string);
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (rp_ptr->x_user_defined == 0)
			{
				sprintf(error_string, "No drain point has been defined for "
						"bed thickness %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected bed thickness for drain point. %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &rp_ptr->thickness);
				rp_ptr->thickness_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;

		case 10:				/* node */
		case 11:				/* point */
			/* case OPTION_DEFAULT:  *//* Read x, y */
			if (rp_ptr->x_user_defined == TRUE)
			{
				drain->points.push_back(rp);
			}
			river_point_init(rp_ptr);
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected an X value of drain point. %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &rp_ptr->x_user);
				rp_ptr->x_user_defined = TRUE;
			}
			j = copy_token(token, &next_char, &l);
			if (j != DIGIT)
			{
				sprintf(error_string,
						"Expected an Y value of drain point. %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			else
			{
				sscanf(token, "%lf", &rp_ptr->y_user);
				rp_ptr->y_user_defined = TRUE;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 12:				/* coordinate_system */
		case 13:				/* xy_coordinate_system */
			j = copy_token(token, &next_char, &l);
			str_tolower(token);
			if (strstr(token, "map") == token)
			{
				drain->coordinate_system = PHAST_Transform::MAP;
			}
			else if (strstr(token, "grid") == token)
			{
				drain->coordinate_system = PHAST_Transform::GRID;
			}
			else
			{
				sprintf(error_string,
						"Expected XY coordinate system for drain points. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 14:				/* z_coordinate_system */
			j = copy_token(token, &next_char, &l);
			str_tolower(token);
			if (strstr(token, "map") == token)
			{
				drain->z_coordinate_system = PHAST_Transform::MAP;
			}
			else if (strstr(token, "grid") == token)
			{
				drain->z_coordinate_system = PHAST_Transform::GRID;
			}
			else
			{
				sprintf(error_string,
						"Expected Z coordinate system for drain points. %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;		
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}

	if (rp_ptr->x_user_defined == TRUE)
	{
		drain->points.push_back(rp);
	}
	drains.push_back(drain);
	drain_defined = true;
	return (return_value);
}

#ifdef SKIP
bool
read_coordinate_system(Polyhedron * poly_ptr, char *next_char)
{

	Cube *c = dynamic_cast < Cube * >(poly_ptr);
	if (c == NULL)
	{
		sprintf(error_string,
				"-coordinate_system only applies to zones and wedges. Use -perimeter_coord, -top_coord, and -bottom_coord for prisms. %s",
				tag);
		error_msg(error_string, CONTINUE);
		input_error++;
		return false;
	}
	str_tolower(next_char);
	if (strstr(next_char, "map"))
	{
		c->Set_coordinate_system(PHAST_Transform::MAP);
		return true;
	}
	else if (strstr(next_char, "grid"))
	{
		c->Set_coordinate_system(PHAST_Transform::GRID);
		return true;
	}
	sprintf(error_string, "Expected MAP or GRID for coordinate system");
	error_msg(error_string, CONTINUE);
	input_error++;
	return false;

}
#endif
/* ---------------------------------------------------------------------- */
int
read_zone_budget(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Reads polyhedron data for flow and solute budget
	 *
	 *      Arguments:
	 *         none
	 *
	 *      Returns:
	 *         KEYWORD if keyword encountered, input_error may be incremented if
	 *                    a keyword is encountered in an unexpected position
	 *         EOF     if eof encountered while reading mass balance concentrations
	 *         ERROR   if error occurred reading data
	 *
	 */
	int return_value, opt;
	char *ptr, *next_char;
	int n_user, n_user_end;
	char *description;
	int l;
	char token[MAX_LENGTH];
	const char *opt_list[] = {
		"zone",					/* 0 */
		"wedge",				/* 1 */
		"prism",				/* 2 */
		"perimeter",			/* 3 */
		"top",					/* 4 */
		"bottom",				/* 5 */
		"description",			/* 6 */
		"combination"			/* 7 */
		,"box"                  /* 8 */
	};
	int count_opt_list = 9;
	/*
	 *   Read grid data
	 */
	return_value = UNKNOWN;
	Prism *prism_ptr = NULL;

	// read number and description
	ptr = line;
	read_number_description(ptr, &n_user, &n_user_end, &description);
	Zone_budget *zb = new Zone_budget;
	zb->Set_n_user(n_user);
	zb->Set_description(description);
	free_check_null(description);
	/*
	 *   get first line
	 */
	sprintf(tag, "in ZONE_BUDGET, definition %d.",
			(int) Zone_budget::zone_budget_map.size() + 1);
	opt = get_option(opt_list, count_opt_list, &next_char);
	for (;;)
	{
		next_char = line;
		if (opt >= 0)
		{
			copy_token(token, &next_char, &l);
		}
		switch (opt)
		{
		case OPTION_EOF:		/* end of file */
			return_value = EOF;
			break;
		case OPTION_KEYWORD:	/* keyword */
			return_value = KEYWORD;
			break;
		case OPTION_DEFAULT:
		case OPTION_ERROR:
			sprintf(error_string, "Expected an identifier %s", tag);
			error_msg(error_string, CONTINUE);
			error_msg(line_save, CONTINUE);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			input_error++;
			break;
		case 0:				/* zone */
		case 8:				/* box */
			/*
			 *   Allocate space for head_ic, read zone data
			 */
			zb->Set_polyh(read_cube(&next_char));
			if (zb->Get_polyh() == NULL)
			{
				sprintf(error_string, "Reading zone %s", tag);
				error_msg(error_string, CONTINUE);
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 1:				/* wedge */
			/*
			 *   Allocate space for head_ic, read zone data
			 */
			zb->Set_polyh(read_wedge(&next_char));
			{
				Wedge *w_ptr = dynamic_cast < Wedge * >(zb->Get_polyh());
				if (zb->Get_polyh() == NULL
					|| w_ptr->orientation == Wedge::WEDGE_ERROR)
				{
					input_error++;
					sprintf(error_string, "Reading wedge %s", tag);
					error_msg(error_string, CONTINUE);
				}
			}
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;

		case 2:				/* prism */
			{
				/*
				 *   Allocate space for head_ic, read zone data
				 */
				prism_ptr = new Prism;
				zb->Set_polyh(prism_ptr);
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}

		case 3:				/* perimeter */
		case 4:				/* top */
		case 5:				/* bottom */
			{
				std::istringstream lines;
				// opt = streamify_to_next_keyword_or_option(opt_list,
				//										count_opt_list,
				//										lines);
				opt = streamify_prism_piece(opt_list,
					count_opt_list,
					lines);
				if (zb->Get_polyh() == NULL || !prism_ptr->Read(lines))
				{
					input_error++;
					sprintf(error_string, "Reading prism %s", tag);
					error_msg(error_string, CONTINUE);
					break;
				}
			}
			break;
		case 6:				/* description */
			/* read description */
			if (zb->Get_polyh() == NULL)
			{
				sprintf(error_string,
						"Zone, wedge, or prism has not been defined for description %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				opt = next_keyword_or_option(opt_list, count_opt_list);
				break;
			}
			if (zb->Get_polyh()->Get_description()->size() != 0)
			{
				sprintf(error_string, "Description has been redefined %s",
						tag);
				warning_msg(error_string);
				zb->Get_polyh()->Get_description()->clear();
			}
			//std::string str(next_char);
			zb->Get_polyh()->Get_description()->assign(next_char);
			opt = next_keyword_or_option(opt_list, count_opt_list);
			break;
		case 7:				/* combo */
			{
				int i;
				std::istringstream lines;
				opt = streamify_to_next_keyword_or_option(opt_list,
					count_opt_list,
					lines);
				std::string dummy;
				lines >> dummy;
				while (lines >> i)
				{
					zb->Get_combo().push_back(i);
				}
				if (zb->Get_combo().size() == 0)
				{
					sprintf(error_string,
							"Expected list of integers for Zone budget combination %s",
							tag);
					error_msg(error_string, CONTINUE);
					input_error++;
				}

			}
			break;
		}
		return_value = check_line_return;
		if (return_value == EOF || return_value == KEYWORD)
			break;
	}
	Zone_budget::zone_budget_map[n_user] = zb;

	return (return_value);
}
