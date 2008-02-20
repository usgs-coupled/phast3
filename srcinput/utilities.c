#define EXTERNAL extern
#include "hstinpt.h"
#include "message.h"
static char const svnid[] = "$Id$";

static int isamong(char c, const char *s_l);

/* ---------------------------------------------------------------------- */
int copy_token (char *token_ptr, char **ptr, int *length)
/* ---------------------------------------------------------------------- */
{
/*
 *   Copies from **ptr to *token_ptr until first space is encountered.
 *
 *   Arguments:
 *      *token_ptr  output, place to store token
 *
 *     **ptr        input, character string to read token from
 *                  output, next position after token
 *
 *       length     output, length of token
 *
 *   Returns:
 *      UPPER,
 *      LOWER,
 *      DIGIT,
 *      EMPTY,
 *      UNKNOWN.
 */
	int i, return_value;
	char c;

/*
 *   Read to end of whitespace
 */
	while ( isspace((int) (c=**ptr)) ) (*ptr)++;
/*
 *   Check what we have
 */
	if ( isupper((int)c) ) {
		return_value=UPPER;
	} else if ( islower((int)c) ) {
		return_value=LOWER;
	} else if ( isdigit((int)c) || c=='.' || c=='-') {
		return_value=DIGIT;
	} else if ( c == '\0') {
		return_value=EMPTY;
	} else {
		return_value=UNKNOWN;
	}
/*
 *   Begin copying to token
 */
	i=0;
	while ( ( ! isspace ((int) (c=**ptr)) ) &&
		c != ',' &&
		c != ';' &&
		c != '\0' ) {
		token_ptr[i]=c;
		(*ptr)++;
		i++;
	}
	token_ptr[i]='\0';
	*length=i;
	return(return_value);
}
/* ---------------------------------------------------------------------- */
int dup_print(const char *ptr, int emphasis)
/* ---------------------------------------------------------------------- */
{
/*
 *   print character string to output and logfile
 *   if emphasis == TRUE the print is set off by
 *   a row of dashes before and after the character string.
 *   
 */
	size_t l, i;
	char *dash;

	l = strlen(ptr);
	dash = (char *) malloc((size_t) (l+2) * sizeof(char));
	if (emphasis == TRUE) {
		for (i = 0; i < l; i++) dash[i] = '-';
		dash[i] = '\0';
		output_msg(OUTPUT_ECHO,"%s\n%s\n%s\n\n", dash, ptr, dash);
	} else {
		output_msg(OUTPUT_ECHO,"%s\n\n", ptr);
	}
	free_check_null(dash);

	return(OK);
}
/* ---------------------------------------------------------------------- */
int equal (double a, double b, double eps)
/* ---------------------------------------------------------------------- */
{
/*
 *   Checks equality between two double precision numbers
 */
	if( fabs(a-b) <= eps ) return(TRUE);
	return(FALSE);
}
/* ---------------------------------------------------------------------- */
int free_check_null(void *ptr)
/* ---------------------------------------------------------------------- */
{
	if (ptr != NULL) {
		free(ptr);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int isamong(char c, const char *s_l)
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
			return(TRUE);
		}
	}
	return(FALSE);
}
/* ---------------------------------------------------------------------- */
int islegit(const char c)
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
		return(TRUE);
	}
	return(FALSE);
}
/* ---------------------------------------------------------------------- */
void malloc_error (void)
/* ---------------------------------------------------------------------- */
{
	error_msg("NULL pointer returned from malloc or realloc.", 
		  CONTINUE);
	error_msg("Program terminating.", STOP);
	return;
}
/* ---------------------------------------------------------------------- */
int print_centered(const char *string)
/* ---------------------------------------------------------------------- */
{
	size_t i, l, l1, l2;
	char token[MAX_LENGTH];

	l = strlen(string);
	l1 = (79 - l)/2;
	l2 = 79 -l -l1;
	for (i=0; i < l1; i++) token[i]='-';
	token[i]='\0';
	strcat(token, string);
	for (i=0; i < l2; i++) token[i + l1 + l]='-';
	token[79] = '\0';
	output_msg(OUTPUT_ECHO,"%s\n\n",token);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int replace(const char *str1, const char *str2, char *str)
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
	size_t l, l1, l2;
	char *ptr_start, *ptr, *ptr1;

	ptr_start=strstr(str, str1);
/*
 *   Str1 not found, return
 */
	if (ptr_start == NULL) return(FALSE);
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
	return(TRUE);
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
#ifdef SKIP
#if !defined(__WPHAST__)
/* ---------------------------------------------------------------------- */
int error_msg (const char *err_str, const int stop)
/* ---------------------------------------------------------------------- */
{
        fprintf(std_error,"ERROR: %s\n", err_str);
        fflush(std_error);
        fprintf(echo_file,"ERROR: %s\n", err_str);
        fflush(echo_file);
	if (stop == STOP) {
		fprintf(std_error,"Stopping.\n");
		fprintf(echo_file,"Stopping.\n");
		clean_up();
	        exit(1);
        }
	return(OK);
}
#endif
/* ---------------------------------------------------------------------- */
int warning_msg (const char *err_str)
/* ---------------------------------------------------------------------- */
{
        fprintf(std_error,"WARNING: %s\n", err_str);
        fflush(std_error);
        fprintf(echo_file,"WARNING: %s\n", err_str);
        fflush(echo_file);
	return(OK);
}
#endif
/* ---------------------------------------------------------------------- */
int backspace (FILE *file, int spaces)
/* ---------------------------------------------------------------------- */
{
	int i;
	char token[MAX_LENGTH];
	for (i = 0; i < spaces; i++) {
		token[i] = '\b';
	}
	token[i] = '\0';
	fprintf(file,"%s",token);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int vector_print(double *d, double scalar, int n, FILE *file)
/* ---------------------------------------------------------------------- */
{
	int j, k;
	k = 0;
	for (j=0; j < n; j++) {
		if (k > 5) {
			fprintf(file,"\n");
			k = 0;
		}				
		fprintf(file,"%16.7e", d[j] * scalar);
		k++;
	}
	if (k != 0) {
		fprintf(file,"\n");
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int units_conversion(char *input, const char *target, double *conversion, int report_error)
/* ---------------------------------------------------------------------- */
{
	char token[MAX_LENGTH], numer[MAX_LENGTH], denom[MAX_LENGTH];
	char *ptr;
	int has_denom, l;
	double factor, n_factor, d_factor;
/*
 *   split into numerator and denominator
 */
	ptr = input;
	copy_token(token, &ptr, &l);
	str_tolower(token);
/*
 *   get to standard form
 */
	replace("**", "^", token);
	replace("seconds", "S", token);
	replace("second", "S", token);
	replace("sec", "S", token);
	replace("minutes", "min", token);
	replace("minute", "min", token);
	replace("hours", "hr", token);
	replace("hour", "hr", token);
	replace("days", "d", token);
	replace("day", "d", token);
	replace("years", "y", token);
	replace("year", "y", token);
	replace("yr", "y", token);
	replace("y", "yr", token);
	replace("min", "MIN", token);

	replace("inches", "INCH", token);
	replace("inch", "INCH", token);
	replace("in", "INCH", token);
	replace("INCH", "inch", token);
	replace("feet", "ft", token);
	replace("foot", "ft", token);
	replace("miles", "mile", token);
	replace("meters", "m", token);
	replace("meter", "m", token);
	replace("kilo", "k", token);
	replace("centi", "c", token);
	replace("milli", "m", token);
	replace("ft3", "ft^3", token);
	replace("m3", "m^3", token);
	replace("litre", "liter", token);
	replace("gallon", "gal", token);
	replace("gpm", "gal/MIN", token);

	/* convert liters by removing other units with "l" */
	replace("mile", "MILE", token);
	replace("mi", "MILE", token);
	replace("gal", "GAL", token);
	replace("liter", "LITER", token);
	replace("l", "LITER", token);
	replace("MILE", "mile", token);
	replace("GAL", "gal", token);
	replace("LITER", "liter", token);

	ptr = token;
	if (replace("/"," ", token) == TRUE) {
		copy_token(numer, &ptr, &l);
		copy_token(denom, &ptr, &l);
		has_denom = TRUE;
	} else {
		copy_token(numer, &ptr, &l);
		has_denom = FALSE;
	}

	convert_to_si(numer, &n_factor);
	strcpy(token, numer);
	factor = n_factor;
	if (has_denom == TRUE) {
		convert_to_si(denom, &d_factor);
		strcat(token,"/");
		strcat(token, denom);
		factor /= d_factor;
	}
	*conversion = factor;
	if (strcmp(token, target) != 0) {
		if (report_error == TRUE) {
			input_error++;
			sprintf(error_string,"Input units, %s, can not be converted to SI units, %s.\n"
				"       Conversion produced, %s.",
				input, target, token);
			error_msg(error_string, CONTINUE);
		}
		return(ERROR);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int convert_to_si (char *unit, double *conversion)
/* ---------------------------------------------------------------------- */
{
	double factor;
	factor = 1;
	replace("S", "s", unit);
	if (replace("MIN","s", unit) == TRUE) {
		factor *= 60;
	}
	if (replace("hr","s", unit) == TRUE) {
		factor *= 60 * 60;
	}
	if (replace("d","s", unit) == TRUE) {
		factor *= 60 * 60 * 24;
	}
	if (replace("yr","s", unit) == TRUE) {
		factor *= 60 * 60 * 24 * 365.25;
	}
	if (replace("inch","m", unit) == TRUE) {
		factor *= .0254;
	}
	if (replace("ft^3","m^3", unit) == TRUE) {
		factor *= 2.832e-2;
	}
	if (replace("liter","m^3", unit) == TRUE) {
		factor *= 1e-3;
	}
	if (replace("gal","m^3", unit) == TRUE) {
		factor *= 3.785e-3;
	}
	if (replace("ft","m", unit) == TRUE) {
		factor *= .3048;
	}
	if (replace("mile","m", unit) == TRUE) {
		factor *= 1609.344;
	}
	if (replace("km","m", unit) == TRUE) {
		factor *= 1000.;
	}
	if (replace("cm","m", unit) == TRUE) {
		factor *= 0.01;
	}
	if (replace("mm","m", unit) == TRUE) {
		factor *= 0.001;
	}
	*conversion = factor;
	return(OK);
}
