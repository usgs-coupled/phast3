#define EXTERNAL extern
#include "hstinpt.h"
#include "message.h"
#include <stddef.h>
static char const rcsid[] = "$RCSfile: message.c,v $  $Revision: 1.2 $";

 FILE  *input_file;
 FILE  *input;
 FILE  *output;
 FILE  *database_file;
 char *user_database;
 char *selected_output_file;
 int first_read_input;
 FILE  *log_file;
 FILE  *punch_file;
 FILE  *error_file;
 FILE  *dump_file;
 FILE  *echo_file;

static struct message_callback *message_callbacks = NULL;
static size_t count_message_callback = 0;
char big_buffer[10000];

/* ---------------------------------------------------------------------- */
int add_message_callback(PFN_MESSAGE_CALLBACK pfn, void *cookie)
/* ---------------------------------------------------------------------- */
{
	if (rcsid == NULL) fprintf(stderr," ");
	if (pfn) {
		message_callbacks = (struct message_callback*) realloc(message_callbacks, sizeof(struct message_callback) * (count_message_callback + 1));
		if (!message_callbacks) malloc_error();
		message_callbacks[count_message_callback].callback = pfn;
		message_callbacks[count_message_callback].cookie = cookie;
		++count_message_callback;
	}
	return OK;
}

/* ---------------------------------------------------------------------- */
int output_message(const int type, const char *err_str, const int stop, const char *format, va_list args)
/* ---------------------------------------------------------------------- */
{
	size_t i;

	for (i = 0; i < count_message_callback; ++i) {
		(message_callbacks[i].callback)(type, err_str, stop, message_callbacks[i].cookie, format, args);
	}

	if (stop == STOP) {
		clean_up();
		exit(1);
	}
	return OK;
}

/* ---------------------------------------------------------------------- */
int clean_up_message(void)
/* ---------------------------------------------------------------------- */
{
	if (message_callbacks != NULL) {
		free(message_callbacks);
		message_callbacks = NULL;
	}
	count_message_callback = 0;
	return OK;
}

/* ---------------------------------------------------------------------- */
int error_msg (const char *err_str, const int stop)
/* ---------------------------------------------------------------------- */
{
	va_list args = NULL;
	if (input_error <= 0) input_error = 1;

	return output_message(OUTPUT_ERROR, err_str, stop, "", args);
}

/* ---------------------------------------------------------------------- */
int warning_msg (const char *err_str)
/* ---------------------------------------------------------------------- */
{
	va_list args = NULL;
	int return_value;

	return_value = output_message(OUTPUT_WARNING, err_str, CONTINUE, "", args);
	count_warnings++;
	return (return_value);
}
/* ---------------------------------------------------------------------- */
int output_msg (const int type, const char* format, ...)
/* ---------------------------------------------------------------------- */
{
	int return_value;
	va_list args;

	va_start(args, format);
	return_value = output_message(type, big_buffer, CONTINUE, format, args);
	va_end(args);

	/*vfprintf(stdout, format, args);*/
	/*vsprintf(big_buffer, format, args);*/

	return(return_value);
}
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
int Merge_vfprintf(FILE *stream, const char *format, va_list args);
#define vfprintf Merge_vfprintf
#endif

/* ---------------------------------------------------------------------- */
int default_handler(const int type, const char *err_str, const int stop, void *cookie, const char *format, va_list args)
/* ---------------------------------------------------------------------- */
{
	int flush;

	flush = TRUE;

	switch (type) {
	case OUTPUT_ERROR:
		if (error_file != NULL) {
			fprintf(error_file, "\n");
		}
		if (error_file != NULL) {
			fprintf(error_file, "ERROR: %s\n", err_str);
			if (flush) fflush(error_file);
		}
		if (echo_file != NULL) {
			fprintf(echo_file, "ERROR: %s\n", err_str);
			if (flush) fflush(echo_file);
		}
		if (output != NULL) {
			fprintf(output, "ERROR: %s\n", err_str);
			if (flush) fflush(output);
		}
		if (stop == STOP) {
			if (error_file != NULL) {
				fprintf(error_file, "Stopping.\n");
				fflush(error_file);
			}
			if (echo_file != NULL) {
				fprintf(echo_file, "Stopping.\n");
				fflush(echo_file);
			}
			if (output != NULL) {
				fprintf(output, "Stopping.\n");
				fflush(output);
			}
		}
		break;

	case OUTPUT_WARNING:
		if (log_file != NULL) {
			fprintf(log_file,"WARNING: %s\n", err_str);
			if (flush) fflush(log_file);
		}
		if (error_file != NULL) {
			fprintf(error_file,"\n");
		}
		if (error_file != NULL) {
			fprintf(error_file,"WARNING: %s\n", err_str);
			if (flush) fflush(error_file);
		}
		if (echo_file != NULL) {
			fprintf(echo_file,"WARNING: %s\n", err_str);
			if (flush) fflush(echo_file);
		}
		if (output != NULL) {
			fprintf(output,"WARNING: %s\n", err_str);
			if (flush) fflush(output);
		}
		break;
	case OUTPUT_HST:
		if (hst_file != NULL) {
			vfprintf(hst_file, format, args);
			if (flush) fflush(hst_file);
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
			vfprintf(punch_file, format, args);
			if (flush) fflush(punch_file);
		}
		break;
	case OUTPUT_ECHO:
		if (echo_file != NULL) {
			vfprintf(echo_file, format, args);
			if (flush) fflush(echo_file);
		}
		break;
	case OUTPUT_GUI_ERROR:
		if (error_file != NULL) {
			vfprintf(error_file, format, args);
			if (flush) fflush(error_file);
		}
		break;
	case OUTPUT_LOG:
		if (log_file != NULL) {
			vfprintf(log_file, format, args);
			if (flush) fflush(error_file);
		}
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
			if (flush) fflush(dump_file);
		}
		break;
	}
	return(OK);
}

#undef vfprintf
