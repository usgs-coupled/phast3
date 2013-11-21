/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#ifndef FileWriter_H
#define FileWriter_H
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif

#if defined(FC_FUNC_)
// Called from Fortran or C++
#define WriteFiles                     FC_FUNC_ (writefiles,                   WRITEFILES)
#define FinalizeFiles                  FC_FUNC_ (finalizefiles,                FINALIZEFILES)
#endif
#if defined(__cplusplus)
extern "C" {
#endif
void WriteFiles(int *id, int *print_hdf, int *print_xyz, 
	double *x_node, double *y_node, double *z_node, int *xyz_mask,
	double *saturation, int *mapping);
void FinalizeFiles();

#if defined(__cplusplus)
}
#endif
void WriteHDF(int *id, int *print_hdf);void
WriteXYZ(int *id, int *print_xyz, 
	double *x_node, double *y_node, double *z_node, int *xyz_mask,
	double *saturation, int *mapping);
#endif // FileWriter_H
