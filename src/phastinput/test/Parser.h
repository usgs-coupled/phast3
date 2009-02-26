#pragma once

#define NOGDI
#include <windows.h>

LONG ExceptionFilter(DWORD dwExceptionCode);
DWORD GetExceptionCode(VOID);

// see winerror.h
#define MAKESOFTWAREEXCEPTION(Severity, Facility, Exception) \
	((DWORD) ( \
	/* Severity code */      (Severity       ) |   \
	/* MS(0) or Cust(1) */   (1         << 29) |   \
	/* Reserved(0) */        (0         << 28) |   \
	/* Facility code */      (Facility  << 16) |   \
	/* Exception code */     (Exception <<  0)))

#define INPUT_CONTAINS_ERRORS MAKESOFTWAREEXCEPTION(ERROR_SEVERITY_ERROR, FACILITY_NULL, 2)

#include <iosfwd>
#include <string>

#define KEYWORD 3
#define TRUE 1
#define FALSE 0
#define OK 1
#define MAX_LENGTH 100
#define EMPTY 2
#define OPTION 8
#define STOP 1
#define ERROR 0
#define CONTINUE 0

#define OPTION_EOF -1
#define OPTION_KEYWORD -2
#define OPTION_ERROR -3
#define OPTION_DEFAULT -4
#define OPTION_DEFAULT2 -5

class CParser
{
public:
	CParser(std::istream& input);
	virtual ~CParser(void);

	LPCTSTR GetErrorMsg(void);

	// phastinput overrides
	int get_logical_line(int *l);
	int get_line(void);
	int error_msg (const char *err_str, const int stop);


protected:
	std::istream& m_input_stream;
	std::ostream& m_output_stream;
	std::ostream& m_error_stream;

	std::string   m_errors;
};
