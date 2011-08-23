#ifndef _INC_MESSAGE_H
#define _INC_MESSAGE_H
#if !defined(PHREEQC_CLASS)
#define CLASS_STATIC
#else
#if !defined(_INC_PHREEQC_H)
#define CLASS_STATIC
#endif
#endif
#include <stdarg.h>
#ifdef PHREEQC_IDENT
static char const svnidoutput[] =
	"$Id: output.h 4388 2010-05-13 00:19:31Z charlton $";
#endif

typedef int (*PFN_OUTPUT_CALLBACK) (const int action, const int type,
									const char *err_str, const int stop,
									void *cookie, const char *, va_list args);

struct output_callback
{
	PFN_OUTPUT_CALLBACK callback;
	void *cookie;
};

int add_output_callback(PFN_OUTPUT_CALLBACK pfn, void *cookie);
int clean_up_output_callbacks(void);
int output_message(const int type, const char *err_str, const int stop,
				   const char *format, va_list args);
int output_msg(const int type, const char *format, ...);
int warning_msg(const char *err_str, ...);
int error_msg(const char *err_str, const int stop, ...);
CLASS_STATIC int phreeqc_handler(const int action, const int type, const char *err_str,
					const int stop, void *cookie, const char *, va_list args);
void set_forward_output_to_log(int value);
int get_forward_output_to_log(void);

/*
 *  Functions for output callbacks
 */
int output_open(const int type, const char *file_name, ...);
int output_fflush(const int type, ...);
int output_rewind(const int type, ...);
int output_close(const int type, ...);

typedef enum
{
	OUTPUT_ERROR,
	OUTPUT_WARNING,
	OUTPUT_MESSAGE,
	OUTPUT_PUNCH,
	OUTPUT_SCREEN,
	OUTPUT_LOG,
	OUTPUT_CHECKLINE,
	OUTPUT_GUI_ERROR,
	OUTPUT_BASIC,
	OUTPUT_CVODE,
	OUTPUT_DUMP,
	OUTPUT_STDERR,
	OUTPUT_SEND_MESSAGE,
	OUTPUT_ECHO,
	OUTPUT_PUNCH_END_ROW
} output_type;

typedef enum
{
	ACTION_OPEN,
	ACTION_OUTPUT,
	ACTION_CLOSE,
	ACTION_REWIND,
	ACTION_FLUSH
} action_type;

#endif /* _INC_MESSAGE_H */
