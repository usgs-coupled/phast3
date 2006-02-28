#include <windows.h>
#include "Parser.h"

extern "C" {

extern int   max_line;
extern char  *line;
extern char  *line_save;
extern int   next_keyword;

extern int malloc_error(void);
extern int check_key (char *str);
extern int copy_token (char *token_ptr, char **ptr, int *length);

}

#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>  // ::realloc
#include <crtdbg.h>  // memory debug routines

#include <cassert>   // assert macro
#include <iostream>  // std::cerr std::cin std::cout

CParser::CParser(std::istream& input)
: m_input_stream(input)
, m_output_stream(std::cout)
, m_error_stream(std::cerr)
{
}

CParser::~CParser(void)
{
}

int CParser::get_logical_line(int *l)
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
	char c;
	i = 0;
	for (;;) {
		j = this->m_input_stream.get();
		if (j == std::char_traits<char>::eof()) break;
		c = (char) j;
		if (c == '\\') {
			j = this->m_input_stream.get();
			if (j == std::char_traits<char>::eof()) break;
			j = this->m_input_stream.get();
			if (j == std::char_traits<char>::eof()) break;
			c = (char) j;
		}
		if (c == ';' || c == '\n') break;
		if ( i + 20 >= max_line) {
			max_line *= 2;
			line_save = (char *) ::realloc (line_save, (size_t) max_line * sizeof(char));
			if (line_save == NULL) malloc_error();
			line = (char *) ::realloc (line, (size_t) max_line * sizeof(char));
			if (line == NULL) malloc_error();
		}
		line_save[i++] = c;
	}
	if (j == std::char_traits<char>::eof() && i == 0) {
		*l = 0;
		line_save[i] = '\0';
		return(EOF);
	} 
	line_save[i] = '\0';
	*l = i;
	return(OK);
}

/* ---------------------------------------------------------------------- */
int CParser::get_line(void)
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
	while (return_value == EMPTY) {
/*
 *   Eliminate all characters after # sign as a comment
 */
		i=-1;
		j=0;
		empty=TRUE;
/*
 *   Get line, check for eof
 */
		if (this->get_logical_line(&l) == EOF) {
			next_keyword=0;
			return (EOF);
		}
/*
 *   Get long lines
 */
		j = l;
		ptr = strchr (line_save, '#');
		if (ptr != NULL) {
			j = (int)(ptr - line_save);
		}
		strncpy(line, line_save, (unsigned) j);
		line[j] = '\0';
		for (i = 0; i < j; i++) {
			if (! isspace((int)line[i]) ) {
				empty = FALSE;
				break;
			}
		}
/*
 *   New line character encountered
 */

		if (empty == TRUE) {
			return_value=EMPTY;
		} else {
			return_value=OK;
		}
	}
/*
 *   Determine return_value
 */
	if (return_value == OK) {
		if ( check_key(line) == TRUE) {
			return_value=KEYWORD;
		} else {
			ptr = line;
			copy_token(token, &ptr, &i);
			if (token[0] == '-' && isalpha((int)token[1])) {
				return_value = OPTION;
			}
		}
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int CParser::error_msg (const char *err_str, const int stop)
/* ---------------------------------------------------------------------- */
{
	this->m_errors += "ERROR: ";
	this->m_errors += err_str;
	this->m_errors += "\n";
	if (stop == STOP) {
		this->m_errors += "Stopping.\n";
		::RaiseException(INPUT_CONTAINS_ERRORS, 0, 0, NULL);
	}
	return OK;
}

LPCTSTR CParser::GetErrorMsg(void)
{
	return this->m_errors.c_str();
}

