/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#ifndef FileWriter_H
#define FileWriter_H

#if defined(__cplusplus)
extern "C" {
#endif
void FH_FinalizeFiles();
void FH_ProcessRestartFiles(int *initial_conditions1_in, int *initial_conditions2_in, 
	double *fraction1_in);
void FH_SetNodes(double *x_node, double *y_node, double *z_node);
void FH_SetPhreeqcRM(int *rm_id);
void FH_SetRestartName(const char *name);
void FH_WriteFiles(int *print_hdf, int *print_media, int *print_xyz, int *xyz_mask, int *print_restart);
void FH_WriteBcRaw(double *c, int *solution_list, int * bc_solution_count, int * solution_number, char *prefix);
#if defined(__cplusplus)
}
#endif

#endif // FileWriter_H
