#include <stdarg.h>
#include <stdio.h>
#include <sstream>
#ifdef PHREEQC_IDENT
static char const svnid[] =
	"$Id$";
#endif
extern FILE *hst_file;
extern FILE *output;
extern FILE *database_file;
extern char *user_database;
extern char *selected_output_file;
extern int first_read_input;
/*
extern FILE  *log_file;
extern FILE  *punch_file;
extern FILE  *error_file;
extern FILE  *dump_file;
extern FILE  *echo_file;
*/
typedef int (*PFN_MESSAGE_CALLBACK) (const int type, const char *err_str,
									 const int stop, void *cookie,
									 const char *, va_list args);

struct message_callback
{
	PFN_MESSAGE_CALLBACK callback;
	void *cookie;
};
int add_message_callback(PFN_MESSAGE_CALLBACK pfn, void *cookie);
int clean_up_message(void);
int output_msg(const int type, const char *format, ...);
int warning_msg(const char *err_str);
int error_msg(const char *err_str, const int stop);
int default_handler(const int type, const char *err_str, const int stop,
					void *cookie, const char *, va_list args);



typedef enum
{ OUTPUT_ERROR, OUTPUT_WARNING, OUTPUT_MESSAGE, OUTPUT_PUNCH, OUTPUT_SCREEN,
	OUTPUT_LOG, OUTPUT_ECHO, OUTPUT_GUI_ERROR, OUTPUT_BASIC, OUTPUT_CVODE,
	OUTPUT_DUMP, OUTPUT_STDERR, OUTPUT_HST
} output_type;
enum ERROR_ACTION
{
	EA_CONTINUE = 0,
	EA_STOP = 1
};
