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
class RMHelper: public PHRQ_base
{
public:
	RMHelper();
	~RMHelper(void);
	bool GetHDFInitialized(void) {return this->HDFInitialized;}
	void SetHDFInitialized(bool tf) {this->HDFInitialized = tf;}
	bool GetHDFInvariant(void) {return this->HDFInvariant;}
	void SetHDFInvariant(bool tf) {this->HDFInvariant = tf;}
	bool GetXYZInitialized(void) {return this->XYZInitialized;}
	void SetXYZInitialized(bool tf) {this->XYZInitialized = tf;}
	std::vector< std::string > &GetHeadings(void) {return this->Headings;}
	void SetHeadings(std::vector< std::string > &h) {this->Headings = h;}

protected:
	bool HDFInitialized;
	bool HDFInvariant;
	bool XYZInitialized;
	std::vector< std::string > Headings;
};
RMHelper rmhelper;
// Constructor
RMHelper::RMHelper()
{
	this->io = new PHRQ_io;
	HDFInitialized = false;
	HDFInvariant = false;
	XYZInitialized = false;
}
// Destructor
RMHelper::~RMHelper()
{
	delete this->io;
}
/* ---------------------------------------------------------------------- */
void
RMH_Write_Files(int *id, int *print_hdf, int *print_xyz, 
	double *x_node, double *y_node, double *z_node, int *xyz_mask,
	double *saturation, int *mapping)
/* ---------------------------------------------------------------------- */
{
	//H5::H5File *file = new H5::H5File( FILE_NAME, H5F_ACC_RDWR );
#ifdef HDF5_CREATE
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{	
		int local_mpi_myself = Reaction_module_ptr->Get_mpi_myself();
#ifdef USE_MPI
	int flags[2];
	if (local_mpi_myself == 0)
	{
		if (print_hdf == 0 || print_xyz == 0)
		{
			Reaction_module_ptr->error_msg("Null pointer in RMH_Write_Files", 1);
		}
		flags[0] = *print_hdf;
		flags[1] = *print_xyz;
		MPI_Bcast(flags, 2, MPI_INT, 0, MPI_COMM_WORLD);
	}
	else
	{
		MPI_Bcast(flags, 2, MPI_INT, 0, MPI_COMM_WORLD);
	}
	*print_hdf = flags[0];
	*print_xyz = flags[1];
#endif
		int count_chem = Reaction_module_ptr->GetSelectedOutputRowCount();
		int nxyz = Reaction_module_ptr->Get_nxyz();
		double current_time = Reaction_module_ptr->Get_time_conversion() *  Reaction_module_ptr->Get_time();
		if (local_mpi_myself == 0)
		{
			int nsel = RM_GetSelectedOutputCount(id);

			// Set headings
			if (rmhelper.GetHeadings().size() == 0)
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
							// add Headings
							int ncol = RM_GetSelectedOutputColumnCount(id);
							for (int icol = 0; icol < ncol; icol++)
							{
								char head[100];
								status = RM_GetSelectedOutputHeading(id, &icol, head, 100);
								rmhelper.GetHeadings().push_back(head);
							}
						}
					}
				}
			}

			// Initialize HDF
			if (!rmhelper.GetHDFInitialized() && nsel > 0 && *print_hdf != 0)
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
							std::string pre = Reaction_module_ptr->Get_file_prefix();
							// need Reaction_module_ptr->GetFilePrefix();
							std::ostringstream oss;
							oss << "_" << n_user;
							pre.append(oss.str());
							HDF_Init(pre.c_str(), (int) pre.size());

							// Set HDF scalars
							HDFSetScalarNames(rmhelper.GetHeadings());
							rmhelper.SetHDFInitialized(true);
						}
					}
				}
			}

			// Initialize xyz
			if (!rmhelper.GetXYZInitialized() && nsel > 0 && *print_xyz != 0)
			{				
				for (int i = 0; i < nsel; i++)
				{
					int n_user = RM_GetNthSelectedOutputUserNumber(id, &i);
					if (n_user >= 0)
					{
						int status = RM_SetCurrentSelectedOutputUserNumber(id, &n_user);
						if (status >= 0)
						{
							// Open file
							//std::string filename = Reaction_module_ptr->Get_file_prefix();
							std::ostringstream filename;
							filename << Reaction_module_ptr->Get_file_prefix() << "_" << n_user << ".chem.xyz.tsv";
							if (!rmhelper.Get_io()->punch_open(filename.str().c_str()))
							{
								rmhelper.Get_io()->error_msg("Could not open xyz file.", 1);
							}

							// write first headings
							char line_buff[132];
							sprintf(line_buff, "%15s\t%15s\t%15s\t%15s\t%2s\t", "x", "y",
								"z", "time", "in");
							rmhelper.Get_io()->punch_msg(line_buff);
							
							// create chemistry headings
							int ncol = RM_GetSelectedOutputColumnCount(id);
							std::ostringstream h;
							for (int i = 0; i < ncol; i++)
							{
								std::string s(rmhelper.GetHeadings()[i]);
								s.append("\t");
								h.width(20);
								h << s;
							}
							h << "\n";
							rmhelper.Get_io()->punch_msg(h.str().c_str());
							rmhelper.SetXYZInitialized(true);
						}
					}
				}
			}
		}
	
		// Write H5 file
		if (*print_hdf != 0)
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
							if ( !rmhelper.GetHDFInvariant())
							{
								HDF_WRITE_INVARIANT(&local_mpi_myself);
								rmhelper.SetHDFInvariant(true);
							}
							// Now write HDF file
							HDF_BEGIN_TIME_STEP();
							HDFBeginCTimeStep(count_chem);
							HDFFillHyperSlab(0, local_selected_out, ncol);
							HDFEndCTimeStep();
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

		// Write xyz file
		if (*print_xyz != 0)
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
							local_selected_out.resize((size_t) (nxyz*ncol));
							int so_error = RM_GetSelectedOutput(id, local_selected_out.data());

							// write xyz file
							for (int irow = 0; irow < nxyz; irow++)
							{
								if (xyz_mask[irow] <= 0) continue;
								int active = 1;
								if (mapping[irow] < 0 || saturation[irow] <= 0)
								{
									active = 0;
								}

								// write x,y,z
								std::ostringstream ln;

								char line_buff[132];
								sprintf(line_buff, "%15g\t%15g\t%15g\t%15g\t%2d\t",
									x_node[irow], y_node[irow], z_node[irow], current_time,
									active);
								ln << line_buff;
								
								if (active)
								{
									// write chemistry values
									char token[21];
									for (int jcol = 0; jcol < ncol; jcol++)
									{		
										sprintf(token,"%19.10e\t", local_selected_out[irow * ncol + jcol ]);
										ln.width(20);
										//ln << local_selected_out[jcol * nxyz + irow ] << "\t";
										ln << token;
									}
								}
								ln << "\n";
								rmhelper.Get_io()->punch_msg(ln.str().c_str());
							}
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