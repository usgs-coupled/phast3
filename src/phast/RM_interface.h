/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#ifndef INC_IPHREEQC_H
#define INC_IPHREEQC_H

#include "Var.h"

/**
 * @mainpage IPhreeqc Library Documentation
 *
 *  @htmlonly
 *  <table>
 *   <tr><td class="indexkey"><a class="el" href="IPhreeqc_8h.html">IPhreeqc.h</a> </td><td class="indexvalue">C/Fortran Documentation </td></tr>
 *   <tr><td class="indexkey"><a class="el" href="IPhreeqc_8hpp.html">IPhreeqc.hpp</a> </td><td class="indexvalue">C++ Documentation </td></tr>
 *   <tr><td class="indexkey"><a class="el" href="Var_8h.html">Var.h</a></td><td class="indexvalue">IPhreeqc VARIANT Documentation </td></tr>
 *  </table>
 *  @endhtmlonly
 */

/*! \brief Enumeration used to return error codes.
*/
typedef enum {
	IPQ_OK            =  0,  /*!< Success */
	IPQ_OUTOFMEMORY   = -1,  /*!< Failure, Out of memory */
	IPQ_BADVARTYPE    = -2,  /*!< Failure, Invalid VAR type */
	IPQ_INVALIDARG    = -3,  /*!< Failure, Invalid argument */
	IPQ_INVALIDROW    = -4,  /*!< Failure, Invalid row */
	IPQ_INVALIDCOL    = -5,  /*!< Failure, Invalid column */
	IPQ_BADINSTANCE   = -6   /*!< Failure, Invalid instance id */
} IPQ_RESULT;


#if defined(__cplusplus)
extern "C" {
#endif
void 
create_reaction_module(void);
void
errprt_c(int *id, char *err_str, long l);
void
warnprt_c(int *id, char *err_str, long l);
void
logprt_c(int *id, char *err_str, long l);
void
screeenprt_c(int *id, char *err_str, long l);
void
initial_phreeqc_run(int *id, char *chemistry_name, int chemistry_l);

#if defined(__cplusplus)
}
#endif
// Global functions
inline std::string trim_right(const std::string &source , const std::string& t = " \t")
{
	std::string str = source;
	return str.erase( str.find_last_not_of(t) + 1);
}

inline std::string trim_left( const std::string& source, const std::string& t = " \t")
{
	std::string str = source;
	return str.erase(0 , source.find_first_not_of(t) );
}

inline std::string trim(const std::string& source, const std::string& t = " \t")
{
	std::string str = source;
	return trim_left( trim_right( str , t) , t );
} 
#endif // INC_IPHREEQC_H
