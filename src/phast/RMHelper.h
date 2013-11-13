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
#define RMH_Write_HDF                       FC_FUNC_ (rmh_write_hdf,                     RMH_WRITE_HDF)
#define RMH_HDF_Finalize                    FC_FUNC_ (rmh_hdf_finalize,                  RMH_HDF_FINALIZE)
#endif
#if defined(__cplusplus)
extern "C" {
#endif
void RMH_Write_HDF(int *id, int *hdf_initialized, int *hdf_invariant, int *print_hdf);
void RMH_HDF_Finalize();

#if defined(__cplusplus)
}
#endif

#endif // RMHELPER_H
