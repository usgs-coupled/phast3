#include <vector>
#include <string>
bool equal (double a, double b, double eps);
void free_check_null(void *ptr);
bool islegit(const char c);
bool replace(const char *to_remove, const char *replacement, char *string_to_search);
void squeeze_white(char *s_l);
void str_tolower(char *str);
void str_toupper(char *str);
int strcmp_nocase(const char *str1, const char *str2);
int strcmp_nocase_arg1(const char *str1, const char *str2);
char * string_duplicate (const char *token);
int case_picker (std::vector<std::string> options, std::string query);
