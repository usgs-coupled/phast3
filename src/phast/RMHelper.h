/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#ifndef RMHELPER_H
#define RMHELPER_H
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif
//#include "Reaction_module.h"

#if defined(FC_FUNC_)
// Called from Fortran or C++int
#define RMH_SetRestartName                     FC_FUNC_ (rmh_setrestartname,                   RMH_SETRESTARTNAME)
// Calls to Fortran
#endif
#if defined(__cplusplus)
extern "C" {
#endif
int RMH_SetRestartName(const char *name, long nchar);
#if defined(__cplusplus)
}
#endif

#endif // RMHELPER_H
