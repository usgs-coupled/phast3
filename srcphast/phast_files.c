#define EXTERNAL
#include "global.h"
#include "phqalloc.h"
#include "output.h"
#include "phrqproto.h"
#include "phastproto.h"
#include "input.h"
#include "phast_files.h"

/* following line defines path for default data base file */
const char *default_data_base = "phast.dat";


static FILE *input_file           = NULL;
static FILE *database_file        = NULL;
static FILE *output               = NULL; /* OUTPUT_MESSAGE */
static FILE *punch_file           = NULL; /* OUTPUT_PUNCH */
static FILE *error_file           = NULL; /* OUTPUT_ERROR */
static FILE *dump_file            = NULL; /* OUTPUT_DUMP */
static FILE *echo_file = NULL;

static int fileop_handler(const int type, int (*PFN)(FILE*));
static int open_handler(const int type, const char *file_name);
static int output_handler(const int type, const char *err_str, const int stop, void *cookie, const char *format, va_list args);
static int rewind_wrapper(FILE* file_ptr);

/*     $Date: 2004/12/14 18:08:37 $ */
static char const rcsid[] = "$RCSfile: phast_files.c,v $  $Revision: 1.6 $";


/* ---------------------------------------------------------------------- */
int phast_handler(const int action, const int type, const char *err_str, const int stop, void *cookie, const char *format, va_list args)
/* ---------------------------------------------------------------------- */
{
	int i;

	switch (action) {
	case ACTION_OPEN:
		return open_handler(type, err_str);
		break;
	case ACTION_OUTPUT:
		return output_handler(type, err_str, stop, cookie, format, args);
		break;
	case ACTION_FLUSH:
		return fileop_handler(type, fflush);
		break;
	case ACTION_REWIND:
		return fileop_handler(type, rewind_wrapper);
		break;
	case ACTION_CLOSE:

		i = fileop_handler(type, fclose);
		switch (type) {
		case OUTPUT_ERROR:
			error_file = NULL;
			break;

		case OUTPUT_WARNING:
			break;

		case OUTPUT_MESSAGE:
			output = NULL;
			break;

		case OUTPUT_PUNCH:
			punch_file = NULL;
			break;

		case OUTPUT_SCREEN:
			break;

		case OUTPUT_LOG:
			break;

		case OUTPUT_STDERR:
			break;

		case OUTPUT_DUMP:
			dump_file = NULL;
			break;
		}


		return(i);
		break;
	}
	return ERROR;
}
/* ---------------------------------------------------------------------- */
int close_input_files(void)
/* ---------------------------------------------------------------------- */
{
	int i = 0;
	i |= fclose(database_file);
	i |= fclose(input_file);
	input_file = database_file = NULL;
	return (i);
}
/* ---------------------------------------------------------------------- */
int process_file_names(int argc, char *argv[], void **db_cookie, void **input_cookie, int log)
/* ---------------------------------------------------------------------- */
{
	int l;
	char token[2*MAX_LENGTH], default_name[2*MAX_LENGTH];
	char query[2*MAX_LENGTH];
	char in_file[2*MAX_LENGTH], out_file[2*MAX_LENGTH];
	char *env_ptr;
	char *ptr;
	int errors;
	ENTRY item, *found_item;

/*
 *   Prepare error handling
 */
	errors = setjmp(mark);
	if (errors != 0) {
		return errors;
	}

/*
 *   Prep for get_line
 */
	max_line = MAX_LINE;
	space ((void *) &line, INIT, &max_line, sizeof(char));
	space ((void *) &line_save, INIT, &max_line, sizeof(char));
	hcreate_multi(5, &strings_hash_table);
	hcreate_multi(2, &keyword_hash_table);

/*
 *   Initialize hash table
 */
	keyword_hash = PHRQ_malloc(sizeof(struct key));
	if (keyword_hash == NULL) {
		malloc_error();
	} else {
		keyword_hash->name = string_hsave("database");
		keyword_hash->keycount = 0;
		item.key = keyword_hash->name;
		item.data = keyword_hash;
		found_item = hsearch_multi(keyword_hash_table, item, ENTER);  
		if (found_item == NULL) {
			sprintf(error_string, "Hash table error in keyword initialization.");
			error_msg(error_string, STOP);
		}
	}


/*
 *   Open file for screen output
 */
	if (argc > 4) {
		error_file = fopen(argv[4], "w");
		if (error_file == NULL) {
			error_file = stderr;
			sprintf(error_string, "Error opening file, %s.", argv[4]);
			warning_msg(error_string);
		}
	} else {
		error_file = stderr;
	}

/*
 *   Open user-input file
 */
	strcpy(query,"Name of input file?");
	if (argc <= 1) {
		default_name[0]='\0';
		input_file = file_open(query, default_name, "r", FALSE);
	} else {
		strcpy(default_name, argv[1]);
		input_file = file_open(query, default_name, "r", TRUE);
	}
	if (phreeqc_mpi_myself == 0) output_msg(OUTPUT_SCREEN, "Input file: %s\n\n", default_name);
	output_msg(OUTPUT_SEND_MESSAGE, "Input file: %s\r\n\r\n", default_name);
	strcpy(in_file, default_name);
/*
 *   Open file for output
 */
	strcpy(query,"Name of output file?");
#ifdef DOS
	replace("."," ",default_name);
#endif
	ptr = default_name;
	copy_token(token, &ptr, &l);
	strcat(token,".out");
	if (argc <= 1) {
		output = file_open(query, token, "w", FALSE);
	} else if (argc == 2) {
		output = file_open(query, token, "w", TRUE);
	} else if (argc >= 3) {
		strcpy(token, argv[2]);
#if defined(USE_MPI)
		output = mpi_fopen(token, "w");
#else
#ifdef SKIP
		output = file_open(query, token, "w", TRUE);
#endif
#endif
	}		
	if (phreeqc_mpi_myself == 0) output_msg(OUTPUT_SCREEN, "Output file: %s\n\n", token);
	output_msg(OUTPUT_SEND_MESSAGE, "Output file: %s\r\n\r\n", token);
	strcpy(out_file, token);
	/*
	 *  Read input file for DATABASE keyword
	 */
	if (get_line(getc_callback, input_file) == KEYWORD) {
		ptr = line;
		copy_token(token, &ptr, &l);
		if (strcmp_nocase(token, "database") == 0) {
			user_database = string_duplicate(ptr);
			if (string_trim(user_database) == EMPTY) {
				warning_msg("DATABASE file name is missing; default database will be used.");
				user_database = free_check_null(user_database);
			}
		}
	}
	fclose(input_file);
	if ((input_file = fopen(in_file,"r")) == NULL) {;
		error_msg ("Can't reopen input file.", STOP);
	}
/*
 *   Open data base
 */
	strcpy(query,"Name of database file?");
	env_ptr = getenv("PHREEQC_DATABASE");
	if (user_database != NULL) {
		strcpy(token, user_database);
	} else if (env_ptr != NULL) {
		strcpy(token, env_ptr);
	} else {
		strcpy(token, default_data_base);
	} 
	if (argc <= 1) {
		database_file = file_open(query, token, "r", FALSE);
	} else if (argc < 4) {
		database_file = file_open(query, token, "r", TRUE);
	} else if (argc >= 4) {
		if (user_database == NULL) {
			strcpy(token, argv[3]);
		} else {
#ifndef PHREEQCI_GUI
			warning_msg("Database file from DATABASE keyword is used; command line argument ignored.");
#endif
		}
		database_file = file_open(query, token, "r", TRUE);
	}
	if (phreeqc_mpi_myself == 0) output_msg(OUTPUT_SCREEN, "Database file: %s\n\n", token);
	output_msg(OUTPUT_SEND_MESSAGE, "Database file: %s\r\n\r\n", token);


	output_msg(OUTPUT_MESSAGE, "   Input file: %s\n", in_file);
	output_msg(OUTPUT_MESSAGE, "  Output file: %s\n", out_file);
	output_msg(OUTPUT_MESSAGE, "Database file: %s\n\n", token);


/*
 *   local cleanup
 */
	user_database = free_check_null(user_database);
	line = free_check_null(line);
	line_save = free_check_null(line_save);

	hdestroy_multi(keyword_hash_table);
	keyword_hash = free_check_null(keyword_hash);
	keyword_hash_table = NULL;

	free_hash_strings(strings_hash_table);
	hdestroy_multi(strings_hash_table);
	strings_hash_table = NULL;

	*db_cookie = database_file;
	*input_cookie = input_file;

	return 0;
}
/* ---------------------------------------------------------------------- */
int open_input_files_phast(char *chemistry_name, char *database_name, void **db_cookie, void **input_cookie)
/* ---------------------------------------------------------------------- */
{
	int l;
	char token[2*MAX_LENGTH];
	char input_file_name[2*MAX_LENGTH];
	char *ptr;
	int errors;
	ENTRY item, *found_item;

/*
 *   Prepare error handling
 */
	errors = setjmp(mark);
	if (errors != 0) {
		return errors;
	}

/*
 *   Prep for get_line
 */
	max_line = MAX_LINE;
	space ((void *) &line, INIT, &max_line, sizeof(char));
	space ((void *) &line_save, INIT, &max_line, sizeof(char));
	hcreate_multi(5, &strings_hash_table);
	hcreate_multi(2, &keyword_hash_table);

/*
 *   Initialize hash table
 */
	keyword_hash = PHRQ_malloc(sizeof(struct key));
	if (keyword_hash == NULL) {
		malloc_error();
	} else {
		keyword_hash->name = string_hsave("database");
		keyword_hash->keycount = 0;
		item.key = keyword_hash->name;
		item.data = keyword_hash;
		found_item = hsearch_multi(keyword_hash_table, item, ENTER);  
		if (found_item == NULL) {
			sprintf(error_string, "Hash table error in keyword initialization.");
			error_msg(error_string, STOP);
		}
	}


/*
 *   Open error file
 */
	error_file = stderr;


	/*
	 *   Open user-input file
	 */
	ptr = chemistry_name;
	copy_token(input_file_name, &ptr, &l);
	if ( (input_file = fopen(input_file_name, "r")) == NULL) {
		error_msg("Can't open input file.", STOP);
	}
	/*
	 *  Read input file for DATABASE keyword
	 */
	if (get_line(getc_callback, input_file) == KEYWORD) {
		ptr = line;
		copy_token(token, &ptr, &l);
		if (strcmp_nocase(token, "database") == 0) {
			user_database = string_duplicate(ptr);
			if (string_trim(user_database) == EMPTY) {
				warning_msg("DATABASE file name is missing; default database will be used.");
				user_database = free_check_null(user_database);
			}
		}
	}
	fclose(input_file);
	if ((input_file = fopen(input_file_name,"r")) == NULL) {
		error_msg ("Can't reopen input file.", STOP);
	}
	/*
	 *   Open data base
	 */
	if (user_database != NULL) {
		strcpy(token, user_database);
	} else {
		ptr = database_name;
		copy_token(token, &ptr, &l);
	} 
	if ( ( database_file = fopen(token, "r")) == NULL) {
		error_msg ("Can't open database file.", STOP);
	}
/*
 *   local cleanup
 */
	user_database = free_check_null(user_database);
	line = free_check_null(line);
	line_save = free_check_null(line_save);

	hdestroy_multi(keyword_hash_table);
	keyword_hash = free_check_null(keyword_hash);
	keyword_hash_table = NULL;

	free_hash_strings(strings_hash_table);
	hdestroy_multi(strings_hash_table);
	strings_hash_table = NULL;

	*db_cookie = database_file;
	*input_cookie = input_file;

	return 0;
}
/* ---------------------------------------------------------------------- */
int getc_callback(void* cookie)
/* ---------------------------------------------------------------------- */
{
	int i;
	assert(cookie);
	i = getc((FILE*)cookie);
#ifdef PHREEQ98
	if (i == '\n') ++inputlinenr;
#endif
	return i;
}

/* ---------------------------------------------------------------------- */
static int output_handler(const int type, const char *err_str, const int stop, void *cookie, const char *format, va_list args)
/* ---------------------------------------------------------------------- */
{
	int flush;
	FILE *save_output = NULL;

	flush = TRUE;

#ifdef SKIP
	if (get_forward_output_to_log()) {
		save_output = output;
		output = log_file;
	}
#endif
	switch (type) {

	case OUTPUT_ERROR:
		if (status_on == TRUE) {
			if (error_file != NULL) {
				fprintf(error_file, "\n");
			}
#ifndef DOS
			status_on = FALSE;
#endif
		}		
		if (error_file != NULL) {
			fprintf(error_file, "ERROR: %s\n", err_str);
			if (flush) fflush(error_file);
		}
		if (output != NULL) {
			fprintf(output, "ERROR: %s\n", err_str);
			if (flush) fflush(output);
		}
		if (echo_file != NULL) {
			fprintf(echo_file, "ERROR: %s\n", err_str);
			if (flush) fflush(echo_file);
		}
		if (stop == STOP) {
			if (error_file != NULL) {
				fprintf(error_file, "Stopping.\n");
				fflush(error_file);
			}
			if (output != NULL) {
				fprintf(output, "Stopping.\n");
				fflush(output);
			}
		}
		break;

	case OUTPUT_WARNING:
		if (state == TRANSPORT && transport_warnings == FALSE) return(OK);
		if (state == ADVECTION && advection_warnings == FALSE) return(OK);
		if (pr.warnings >= 0) {
			if (count_warnings > pr.warnings) return(OK);
		}
		if (status_on == TRUE) {
			if (error_file != NULL) {
				fprintf(error_file,"\n");
			}
#ifndef DOS
			status_on = FALSE;
#endif
		}		
		if (error_file != NULL) {
			fprintf(error_file,"WARNING: %s\n", err_str);
			if (flush) fflush(error_file);
		}
		if (output != NULL) {
			fprintf(output,"WARNING: %s\n", err_str);
			if (flush) fflush(output);
		}
		if (echo_file != NULL) {
			fprintf(echo_file,"WARNING: %s\n", err_str);
			if (flush) fflush(echo_file);
		}
		break;

	case OUTPUT_CHECKLINE:
		if (pr.echo_input == TRUE) {
			if (output != NULL) {
				vfprintf(output, format, args);
				if (flush) fflush(output);
			}
			if (phreeqc_mpi_myself == 0) {
				if (echo_file != NULL) {
					vfprintf(echo_file, format, args);
					if (flush) fflush(echo_file);
				}
			}
		}
		break;

	case OUTPUT_ECHO:
		if (echo_file != NULL) {
			vfprintf(echo_file, format, args);
			if (flush) fflush(echo_file);
		}
		break;
	case OUTPUT_MESSAGE:
	case OUTPUT_BASIC:
		if (output != NULL) {
			vfprintf(output, format, args);
			if (flush) fflush(output);
		}
		break;
	case OUTPUT_PUNCH:
		if (punch_file != NULL) {
			if (pr.punch == TRUE && punch.in == TRUE) {
				vfprintf(punch_file, format, args);
				if (flush) fflush(punch_file);
			}
		}
		break;

	case OUTPUT_LOG:
		break;
	case OUTPUT_SCREEN:
		if (error_file != NULL) {
			vfprintf(error_file, format, args);
			if (flush) fflush(error_file);
		}
		break;
	case OUTPUT_STDERR:
	case OUTPUT_CVODE:
		if (stderr != NULL) {
			vfprintf(stderr, format, args);
			fflush(stderr);
		}
		break;
	case OUTPUT_DUMP:
		if (dump_file != NULL) {
			vfprintf(dump_file, format, args);
			fflush(dump_file);
		}
		break;
	}

	if (get_forward_output_to_log()) {
		output = save_output;
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int close_output_files(void)
/* ---------------------------------------------------------------------- */
{
	int ret = 0;

	if (output     != NULL) ret |= fclose(output);
	/*	if (log_file   != NULL) ret |= fclose(log_file); */
	if (punch_file != NULL) ret |= fclose(punch_file);
	if (dump_file  != NULL) ret |= fclose(dump_file);
	if (phast != TRUE) {
		if (error_file != NULL) ret |= fclose(error_file);
		error_file = NULL;
	}
	output /*= log_file*/ = punch_file = dump_file = NULL;
	return ret;
}
/* ---------------------------------------------------------------------- */
static int open_handler(const int type, const char *file_name)
/* ---------------------------------------------------------------------- */
{
	switch (type) {

	case OUTPUT_ERROR:
		error_file = stderr;
		if( error_file == NULL) {
			return ERROR;
		}
		break;
	case OUTPUT_MESSAGE:
		if (output != NULL) {
			fclose(output);
			output = NULL;
		}
		if( (output = fopen(file_name, "w")) == NULL) {
			return ERROR;
		}
		break;
	case OUTPUT_PUNCH:
		if (punch_file != NULL) {
			fclose(punch_file);
			punch_file = NULL;
		}
#if defined(USE_MPI)
		if (state != PHAST && phreeqc_mpi_myself == 0) {
			if( (punch_file = fopen(file_name, "w")) == NULL) {
				return ERROR;
			}
		} else {
			#ifdef SKIP
			if ((punch_file = mpi_fopen(file_name, "w")) == NULL) {
				return ERROR;
			}
			#endif
		}
#else
		if( (punch_file = fopen(file_name, "w")) == NULL) {
			return ERROR;
		} else {
			free_check_null(selected_output_file_name);
			selected_output_file_name = string_duplicate(file_name);
		}
#endif
		break;

	case OUTPUT_DUMP:
		if (dump_file != NULL) {
			fclose(dump_file);
			dump_file = NULL;
		}
		if( (dump_file = fopen(file_name, "w")) == NULL) {
			return ERROR;
		}
		break;
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
static int fileop_handler(const int type, int (*PFN)(FILE*))
/* ---------------------------------------------------------------------- */
{
	switch (type) {
	case OUTPUT_ERROR:
		if (error_file) PFN(error_file);
		break;

	case OUTPUT_WARNING:
		if (error_file) PFN(error_file);
		if (output) PFN(output);
		break;

	case OUTPUT_MESSAGE:
	case OUTPUT_CHECKLINE:
	case OUTPUT_BASIC:
		if (output) PFN(output);
		break;

	case OUTPUT_PUNCH:
		if (punch_file) PFN(punch_file);
		break;

	case OUTPUT_SCREEN:
		if (error_file) PFN(error_file);
		break;

	case OUTPUT_LOG:
		break;

	case OUTPUT_CVODE:
	case OUTPUT_STDERR:
		if (stderr) PFN(stderr);
		break;

	case OUTPUT_DUMP:
		if (dump_file) PFN(dump_file);
		break;
	}

	return(OK);
}
/* ---------------------------------------------------------------------- */
static int rewind_wrapper(FILE* file_ptr)
/* ---------------------------------------------------------------------- */
{
	rewind(file_ptr);
	return(OK);
}
/* ---------------------------------------------------------------------- */
FILE *open_echo(const char *prefix)
/* ---------------------------------------------------------------------- */
{
	extern int mpi_myself;
	int l;
	char *ptr;
	char token[MAX_LENGTH], token1[MAX_LENGTH], default_name[MAX_LENGTH];
	FILE *file_ptr;
	/*
	 *   check if echo file is current
	 */
	file_ptr = NULL;

	strcpy(token1, prefix);
	ptr = token1;
	copy_token(default_name, &ptr, &l);
	strcat(default_name, ".log");
	if (mpi_myself == 0) {
		if ((file_ptr = fopen(default_name, "r")) != NULL) {
			fseek(file_ptr, -24, SEEK_END);
			fscanf(file_ptr,"%24c", token);
			token[24] = '\0';
			fclose(file_ptr);
			if (strstr(token, "PHASTINPUT done.") == NULL) {
				remove(default_name);
			}
		}
	}
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	/* do nothing */
#else
	if ((echo_file = fopen(default_name, "a")) == NULL) {
		sprintf(error_string, "Can't open file, %s.", default_name);
		error_msg(error_string, STOP);
	}
#endif
	return echo_file;
}
/* ---------------------------------------------------------------------- */
int open_output_file(char *prefix, int solute)
/* ---------------------------------------------------------------------- */
{
	char token[2*MAX_LENGTH];
	char *ptr;
	int l;
	if (solute == FALSE) return(OK);

	/* ouput file */
	ptr = prefix;
	copy_token(token, &ptr, &l);
	strcat(token, ".O.chem");
	if ( (output = fopen(token, "w")) == NULL) {
		error_msg("Could not open output file.", STOP);
	}
	return OK;
}
/* ---------------------------------------------------------------------- */
int open_punch_file(char *prefix, int solute)
/* ---------------------------------------------------------------------- */
{
	char token[2*MAX_LENGTH];
	char *ptr;
	int l;
	if (solute == FALSE) return(OK);

	/* ouput file */
	ptr = prefix;
	copy_token(token, &ptr, &l);
	strcat(token, ".xyz.chem");
	if ( (punch_file = fopen(token, "w")) == NULL) {
		error_msg("Could not open punch file.", STOP);
	}
	return OK;
}
