#include <windows.h>
#include <string>
#include <map>
#include <iostream>
#include "RMHelper.h"
#include "Reaction_module.h"
#include "RM_interface.h"
#include "H5Cpp.h"
#include "hdf.h"
#ifdef THREADED_PHAST
#include <omp.h>
#endif
#ifdef USE_MPI
#include "mpi.h"
#endif

#if defined(__cplusplus)
extern "C" {
#endif
extern void HDF_WRITE_INVARIANT(int * mpi_myself);
extern void HDF_BEGIN_TIME_STEP(void);
extern void HDF_END_TIME_STEP(void);
#if defined(__cplusplus)
}
#endif

/* ---------------------------------------------------------------------- */
void
RMH_Write_HDF(int *id, int *hdf_initialized, int *hdf_invariant, int *print_hdf)
/* ---------------------------------------------------------------------- */
{
	//H5::H5File *file = new H5::H5File( FILE_NAME, H5F_ACC_RDWR );
#ifdef HDF5_CREATE
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);

	if (Reaction_module_ptr)
	{	
		int local_mpi_myself = Reaction_module_ptr->Get_mpi_myself();
		int count_chem = Reaction_module_ptr->GetSelectedOutputRowCount();

		if (local_mpi_myself == 0)
		{
			int nsel = RM_GetSelectedOutputCount(id);

			// Do initialization
			if (*hdf_initialized == 0 && nsel > 0)
			{
				for (int i = 0; i < nsel; i++)
				{
					int status;
					int n_user = RM_GetNthSelectedOutputUserNumber(id, &i);
					if (n_user >= 0)
					{
						status = RM_SetCurrentSelectedOutputUserNumber(id, &n_user);
						if (status >= 0)
						{
							// open file
							{
								std::string pre = Reaction_module_ptr->Get_file_prefix();
								// need Reaction_module_ptr->GetFilePrefix();
								std::ostringstream oss;
								oss << "_" << n_user;
								pre.append(oss.str());
								HDF_Init(pre.c_str(), (int) pre.size());
							}
							// add scalars
							{
								std::vector< std::string > headings;
								int ncol = RM_GetSelectedOutputColumnCount(id);
								for (int icol = 0; icol < ncol; icol++)
								{
									char head[100];
									status = RM_GetSelectedOutputHeading(id, &icol, head, 100);
									headings.push_back(head);
								}
								HDFSetScalarNames(headings);
							}
							*hdf_initialized = 1;
						}
					}
				}
			}
		}

		
		// Write H5 file
		if (print_hdf != 0)
		{
			std::vector<double> local_selected_out;
			int status;
			for (int i = 0; i < RM_GetSelectedOutputCount(id); i++)
			{
				int n_user = RM_GetNthSelectedOutputUserNumber(id, &i);
				int ncol = RM_GetSelectedOutputColumnCount(id);
				if (n_user >= 0)
				{
					status = RM_SetCurrentSelectedOutputUserNumber(id, &n_user);
					if (status >= 0)
					{
						if (local_mpi_myself == 0)
						{
							local_selected_out.resize((size_t) (count_chem*ncol));
							int so_error = RM_GetSelectedOutput(id, local_selected_out.data());
							if ( *hdf_invariant == 0)
							{
								HDF_WRITE_INVARIANT(&local_mpi_myself);
								*hdf_invariant = 1;
							}
							// Now write HDF file
							HDF_BEGIN_TIME_STEP();
							HDFBeginCTimeStep(count_chem);
							HDFFillHyperSlab(0, local_selected_out, ncol);
							Reaction_module_ptr->EndTimeStep();
							HDF_END_TIME_STEP();
						}
						else
						{
							int so_error = RM_GetSelectedOutput(id, local_selected_out.data());
						}
					}
				}
			}

		}
	}
#endif
/*		
	RM_open_files	 		
		HDF_Init
	RM_initial_phreeqc_run	 	
		Initial_phreeqc_run_thread
			HDFSetScalarNames
	hdf_write_invariant 		
		HDF_INIT_INVARIANT
		HDF_WRITE_GRID
		HDF_WRITE_FEATURE
		HDF_FINALIZE_INVARIANT	
		
!! initial conditions	
	hdf_begin_time_step 		
		HDF_OPEN_TIME_STEP
	RM_run_cells 	
		Run_cells
			BeginTimeStep
				HDFBeginCTimeStep
			HDFFillHyperSlab	
			EndTimeStep
				HDFEndCTimeStep
	hdf_end_time_step	
		PRNTAR_HDF
		MEDIA_HDF
			PRNTAR_HDF
		HDF_VEL
		HDF_CLOSE_TIME_STEP	
		
!! transient loop
	hdf_begin_time_step 		
		HDF_OPEN_TIME_STEP
	RM_run_cells 	
		Run_cells
			BeginTimeStep
				HDFBeginCTimeStep
			HDFFillHyperSlab	
			EndTimeStep
				HDFEndCTimeStep
	hdf_end_time_step	
		PRNTAR_HDF
		MEDIA_HDF
			PRNTAR_HDF
		HDF_VEL
		HDF_CLOSE_TIME_STEP
	write_hdf_intermediate
		HDF_INTERMEDIATE
	RM_close_files
		HDF_Finalize
*/
}
/* ---------------------------------------------------------------------- */
void
RMH_HDF_Finalize()
/* ---------------------------------------------------------------------- */
{
#ifdef HDF5_CREATE
		HDF_Finalize();
#endif
}