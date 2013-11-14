/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#ifndef RMHELPER_H
#define RMHELPER_H
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif

#if defined(FC_FUNC_)
// Called from Fortran or C++
#define RMH_Write_Files                     FC_FUNC_ (rmh_write_files,                   RMH_WRITE_FILES)
#define RMH_HDF_Finalize                    FC_FUNC_ (rmh_hdf_finalize,                  RMH_HDF_FINALIZE)
#endif
#if defined(__cplusplus)
extern "C" {
#endif
void RMH_Write_Files(int *id, int *print_hdf, int *print_xyz, 
	double *x_node, double *y_node, double *z_node, int *xyz_mask,
	double *saturation, int *mapping);
void RMH_HDF_Finalize();

#if defined(__cplusplus)
}
#endif

#endif // RMHELPER_H
