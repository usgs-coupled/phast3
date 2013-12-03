/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#include "Reaction_module.h"
#ifndef RMHELPER_H
#define RMHELPER_H
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif
//#include "Reaction_module.h"

#if defined(FC_FUNC_)
// Called from Fortran or C++int
#define ProcessRestartFiles                    FC_FUNC_ (processrestartfiles,                  PROCESSRESTARTFILES)
#define RMH_SetRestartName                     FC_FUNC_ (rmh_setrestartname,                   RMH_SETRESTARTNAME)
#define SetNodes                               FC_FUNC_ (setnodes,                             SETNODES)
#define WriteRestartFile                       FC_FUNC_ (writerestartfile,                     WRITERESTARTFILE)
// Calls to Fortran
#endif
#if defined(__cplusplus)
extern "C" {
#endif
IRM_RESULT RMH_SetRestartName(const char *name, long nchar);
IRM_RESULT WriteRestartFile(int *id, int *print_restart = NULL, int *indices_ic = NULL);
IRM_RESULT ProcessRestartFiles(
	int *id, 
	int *initial_conditions1_in = NULL,
	int *initial_conditions2_in = NULL, 
	double *fraction1_in = NULL);
void SetNodes(double *x_node, double *y_node, double *z_node);
#if defined(__cplusplus)
}
#endif
bool FileExists(const std::string &name);
void FileRename(const std::string &temp_name, const std::string &name, 
	const std::string &backup_name);
#endif // RMHELPER_H
