#include <windows.h>
#include <string>
#include <map>
#include <iostream>
#include "FileWriter.h"
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
extern void HDF_WRITE_INVARIANT(int *iso, int * mpi_myself);
extern void HDF_BEGIN_TIME_STEP(int *iso);
extern void HDF_END_TIME_STEP(int *iso);
#if defined(__cplusplus)
}
#endif
class FileWriterInfo: public PHRQ_base
{
public:
	FileWriterInfo();
	~FileWriterInfo(void);
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
FileWriterInfo FileWriter;
// Constructor
FileWriterInfo::FileWriterInfo()
{
	this->io = new PHRQ_io;
	HDFInitialized = false;
	HDFInvariant = false;
	XYZInitialized = false;
}
// Destructor
FileWriterInfo::~FileWriterInfo()
{
	delete this->io;
}
/* ---------------------------------------------------------------------- */
void
WriteFiles(int *id, int *print_hdf, int *print_xyz, 
	double *x_node, double *y_node, double *z_node, int *xyz_mask,
	double *saturation, int *mapping)
	/* ---------------------------------------------------------------------- */
{
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
				Reaction_module_ptr->error_msg("Null pointer in WriteFiles", 1);
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
		if (*print_hdf != 0)
		{
			WriteHDF(id, print_hdf);
		}
		if (*print_xyz != 0)
		{
			WriteXYZ(id, print_xyz, x_node, y_node, z_node, 
				xyz_mask, saturation, mapping);
		}
	}
}

/* ---------------------------------------------------------------------- */
void
WriteHDF(int *id, int *print_hdf)
/* ---------------------------------------------------------------------- */
{
#ifdef HDF5_CREATE
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{	
		int local_mpi_myself = Reaction_module_ptr->Get_mpi_myself();
			
		int nso = RM_GetSelectedOutputCount(id);
		int nxyz = Reaction_module_ptr->Get_nxyz(); // need RM method
		double current_time = Reaction_module_ptr->Get_time_conversion() *  Reaction_module_ptr->Get_time();
		//
		// Initialize HDF
		//
		if (!FileWriter.GetHDFInitialized() && nso > 0 && *print_hdf != 0)
		{
			if (local_mpi_myself == 0)
			{
				for (int iso = 0; iso < nso; iso++)
				{
					int status;
					int n_user = RM_GetNthSelectedOutputUserNumber(id, &iso);
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
							HDFInitialize(iso, pre.c_str(), (int) pre.size());

							// Set HDF scalars
							std::vector < std::string > headings;
							int ncol = RM_GetSelectedOutputColumnCount(id);
							for (int icol = 0; icol < ncol; icol++)
							{
								char head[100];
								status = RM_GetSelectedOutputHeading(id, &icol, head, 100);
								headings.push_back(head);
							}
							HDFSetScalarNames(iso, headings);
						}
					}
				}
				FileWriter.SetHDFInitialized(true);
			}
		}
		//	
		// Write H5 file
		//
		if (*print_hdf != 0)
		{
			std::vector<double> local_selected_out;
			int status;
			for (int iso = 0; iso < nso; iso++)
			{
				int n_user = RM_GetNthSelectedOutputUserNumber(id, &iso);
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
							if ( !FileWriter.GetHDFInvariant())
							{
								HDF_WRITE_INVARIANT(&iso, &local_mpi_myself);
								FileWriter.SetHDFInvariant(true);
							}
							// Now write HDF file
							HDF_BEGIN_TIME_STEP(&iso);
							HDFBeginCTimeStep(iso);
							HDFFillHyperSlab(iso, local_selected_out, ncol);
							HDFEndCTimeStep(iso);
							HDF_END_TIME_STEP(&iso);
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
}

/* ---------------------------------------------------------------------- */
void
WriteXYZ(int *id, int *print_xyz, 
	double *x_node, double *y_node, double *z_node, int *xyz_mask,
	double *saturation, int *mapping)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{	
		int local_mpi_myself = Reaction_module_ptr->Get_mpi_myself();
			
		int nso = RM_GetSelectedOutputCount(id);
		int nxyz = Reaction_module_ptr->Get_nxyz(); // need RM method
		double current_time = Reaction_module_ptr->Get_time_conversion() *  Reaction_module_ptr->Get_time();
		//
		// Initialize XYZ
		//
		if (!FileWriter.GetXYZInitialized() && nso > 0 && *print_xyz != 0)
		{
			if (local_mpi_myself == 0)
			{
				for (int iso = 0; iso < nso; iso++)
				{
					int status;
					int n_user = RM_GetNthSelectedOutputUserNumber(id, &iso);
					if (n_user >= 0)
					{
						status = RM_SetCurrentSelectedOutputUserNumber(id, &n_user);
						if (status >= 0)
						{
							// open file
							std::string pre = Reaction_module_ptr->Get_file_prefix();
							// need Reaction_module_ptr->GetFilePrefix();
							std::ostringstream filename;
							filename << Reaction_module_ptr->Get_file_prefix() << "_" << n_user << ".chem.xyz.tsv";
							if (!FileWriter.Get_io()->punch_open(filename.str().c_str()))
							{
								FileWriter.Get_io()->error_msg("Could not open xyz file.", 1);
							}

							// write first headings
							char line_buff[132];
							sprintf(line_buff, "%15s\t%15s\t%15s\t%15s\t%2s\t", "x", "y",
								"z", "time", "in");
							FileWriter.Get_io()->punch_msg(line_buff);
							
							// create chemistry headings
							int ncol = RM_GetSelectedOutputColumnCount(id);
							std::ostringstream h;
							for (int icol = 0; icol < ncol; icol++)
							{
								char head[100];
								status = RM_GetSelectedOutputHeading(id, &icol, head, 100);
								std::string s(head);
								s.append("\t");
								h.width(20);
								h << s;
							}
							h << "\n";
							FileWriter.Get_io()->punch_msg(h.str().c_str());
						}
					}
				}
				FileWriter.SetXYZInitialized(true);
			}
		}
		//	
		// Write XYZ file
		//
		if (*print_xyz != 0)
		{
			std::vector<double> local_selected_out;
			int status;
			for (int iso = 0; iso < nso; iso++)
			{
				int n_user = RM_GetNthSelectedOutputUserNumber(id, &iso);
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
										sprintf(token,"%19.10e\t", local_selected_out[jcol * nxyz + irow]);
										ln.width(20);
										//ln << local_selected_out[jcol * nxyz + irow ] << "\t";
										ln << token;
									}
								}
								ln << "\n";
								FileWriter.Get_io()->punch_msg(ln.str().c_str());
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
}
/* ---------------------------------------------------------------------- */
void
FinalizeFiles()
/* ---------------------------------------------------------------------- */
{
#ifdef HDF5_CREATE
		HDFFinalize();
#endif
}