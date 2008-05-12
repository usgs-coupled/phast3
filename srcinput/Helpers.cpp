#include <math.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <string>
#include <algorithm>
#include "Helpers.h"
static bool isamong(char c, const char *s_l);

/* ---------------------------------------------------------------------- */
bool equal (double a, double b, double eps)
/* ---------------------------------------------------------------------- */
{
/*
 *   Checks equality between two double precision numbers
 */
	if( fabs(a-b) <= eps ) return(true);
	return(false);
}
/* ---------------------------------------------------------------------- */
void free_check_null(void *ptr)
/* ---------------------------------------------------------------------- */
{
	if (ptr != NULL) {
		free(ptr);
	}
	return;
}
/* ---------------------------------------------------------------------- */
bool isamong(char c, const char *s_l)
/* ---------------------------------------------------------------------- */
/*
 *   Function checks if c is among the characters in the string s
 *
 *   Arguments:
 *      c     input, character to check
 *     *s     string of characters
 *
 *   Returns:
 *      TRUE  if c is in set,
 *      FALSE if c in not in set.
 */
{
	int i;

	for (i=0; s_l[i] != '\0'; i++) {
		if (c == s_l[i]) {
			return(true);
		}
	}
	return(false);
}
/* ---------------------------------------------------------------------- */
bool islegit(const char c)
/* ---------------------------------------------------------------------- */
/*
 *   Function checks for legal characters for chemical equations
 *
 *   Argument:
 *      c     input, character to check
 *
 *   Returns:
 *      TRUE  if c is in set,
 *      FALSE if c in not in set.
 */
{
	if( isalpha((int)c) ||
	    isdigit((int)c) ||
	    isamong(c,"+-=().:_") ){
		return(true);
	}
	return(false);
}

/* ---------------------------------------------------------------------- */
bool replace(const char *to_remove, const char *replacement, char *string_to_search)
/* ---------------------------------------------------------------------- */
{
/*
 *   Function replaces str1 with str2 in str
 *
 *   Arguments:
 *      str1     search str for str1
 *      str2     replace str1 if str1 found in str
 *      str      string to be searched
 *
 *   Returns
 *      TRUE     if string was replaced
 *      FALSE    if string was not replaced
 */
  const char * str1, *str2; 
  char *str;

  str1 = to_remove;
  str2 = replacement;
  str = string_to_search;
  size_t l, l1, l2;
  char *ptr_start, *ptr, *ptr1;

  ptr_start=strstr(str, str1);
  /*
  *   Str1 not found, return
  */
  if (ptr_start == NULL) return(false);
  /*
  *   Str1 found, replace Str1 with Str2
  */
  l=strlen(str);
  l1=strlen(str1);
  l2=strlen(str2);
  /*
  *   Make gap in str long enough for str2
  */
  if (l2 < l1) {
    for (ptr = (ptr_start + l1); ptr <= ptr_start + l; ptr++) {
      ptr1= ptr + l2 - l1;
      *ptr1=*ptr;
    }
  } else {
    ptr=str+l+1;
    ptr1=ptr+l2-l1;
    for ( ptr = (str+l+1); ptr >= ptr_start + l1; ptr--) {
      ptr1=ptr+l2-l1;
      *ptr1=*ptr;
    }
  }
  /*
  *   Copy str2 into str
  */
  ptr1=ptr_start;
  for (ptr = (char *) str2; *ptr != '\0'; ptr++) {
    *ptr1=*ptr; 
    ptr1++;
  }
  return(true);
}
/* ---------------------------------------------------------------------- */
void squeeze_white(char *s_l)
/* ---------------------------------------------------------------------- */
/*
 *   Delete all white space from string s
 *
 *   Argument:
 *      *s_l input, character string, possibly containing white space
 *           output, character string with all white space removed
 *
 *   Return: void
 */
{
	int i, j;

	for (i = j = 0; s_l[i] != '\0'; i++){
		if (! isspace((int)s_l[i])) s_l[j++]=s_l[i];
	}
	s_l[j]='\0';
}
/* ---------------------------------------------------------------------- */
void str_tolower(char *str)
/* ---------------------------------------------------------------------- */
{
/*
 *   Replaces string, str, with same string, lower case
 */
	char *ptr;
	ptr=str;
	while (*ptr != '\0') {
		*ptr=tolower(*ptr);
		ptr++;
	}
}
/* ---------------------------------------------------------------------- */
void str_toupper(char *str)
/* ---------------------------------------------------------------------- */
{
/*
 *   Replaces string, str, with same string, lower case
 */
	char *ptr;
	ptr=str;
	while (*ptr != '\0') {
		*ptr=toupper(*ptr);
		ptr++;
	}
}
/* ---------------------------------------------------------------------- */
int strcmp_nocase(const char *str1, const char *str2)
/* ---------------------------------------------------------------------- */
{
/*
 *   Compare two strings disregarding case
 */
	char c1, c2;
	while ((c1 = tolower(*str1++)) == (c2 = tolower(*str2++))) {
		if (c1 == '\0') return(0);
	}
	if (c1 < c2) return(-1);
	return(1);
}
/* ---------------------------------------------------------------------- */
int strcmp_nocase_arg1(const char *str1, const char *str2)
/* ---------------------------------------------------------------------- */
{
/*
 *   Compare two strings disregarding case
 */
	char c1, c2;
	while ((c1 = tolower(*str1++)) == (c2 = *str2++)) {
		if (c1 == '\0') return(0);
	}
	if (c1 < c2) return(-1);
	return(1);
}
/* ---------------------------------------------------------------------- */
char * string_duplicate (const char *token)
/* ---------------------------------------------------------------------- */
{
	size_t l;
	char *str;

	l = strlen(token);
	str = (char *) malloc ((size_t) (l +1) * sizeof(char) );
	strcpy (str, token);
	return(str);
}

/* ---------------------------------------------------------------------- */
int case_picker (std::vector<std::string> options, std::string query)
/* ---------------------------------------------------------------------- */
{

  int j = -1;
  int i;
  std::transform(query.begin(), query.end(), query.begin(), ::tolower);
  char *c_query = string_duplicate(query.c_str());
  replace("-", "", c_query);

  for (i = 0; i < (int) options.size(); i++)
  {
    if (strstr(options[i].c_str(), c_query) == options[i].c_str())
    {
      j = i;
      break;
    }
  }

  free_check_null(c_query);
  return(j);
}
