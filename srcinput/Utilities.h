/* utilities.c */
#if !defined(UTILITIES_H_INCLUDED)
#define UTILITIES_H_INCLUDED

#include <vector>
#include <string>
int convert_to_si(char *unit, double *conversion);
int units_conversion(char *input, const char *target, double *conversion,
					 int report_error);
int copy_token(char *token_ptr, char **ptr, int *length);
int error_msg(const char *err_str, const int stop);
void malloc_error(void);
int status(int count);
int vector_print(double *d, double scalar, int n, FILE * file);
int warning_msg(const char *err_str);
struct zone *grid_zone();
void zone_init(struct zone *zone_ptr);

// The following do not require hstinput.h

bool equal(double a, double b, double eps);
void free_check_null(void *ptr);
bool replace(const char *to_remove, const char *replacement,
			 char *string_to_search);
void squeeze_white(char *s_l);
void str_tolower(char *str);
int strcmp_nocase(const char *str1, const char *str2);
char *string_duplicate(const char *token);
int case_picker(std::vector < std::string > options, std::string query);


#endif // UTILITIES_H_INCLUDED
