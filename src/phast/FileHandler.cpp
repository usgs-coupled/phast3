#ifdef WIN32
#include <windows.h>
#endif
#include <string>
#include <map>
#include <iostream>
#include "FileHandler.h"
#include "PhreeqcRM.h"
#include "RM_interface.h"
#include "gzstream.h"
#include "KDtree/KDtree.h"
#include "Phreeqc.h"
#include "IPhreeqc.h"
#include "H5Cpp.h"
#include "hdf.h"
#ifdef THREADED_PHAST
#include <omp.h>
#endif
#ifdef USE_MPI
#include "mpi.h"
#endif
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif

#if defined(FC_FUNC_)
// Calls to Fortran
#define hdf_write_invariant         FC_FUNC_ (hdf_write_invariant,       HDF_WRITE_INVARIANT)
#define HDF_BEGIN_TIME_STEP         FC_FUNC_ (hdf_begin_time_step,       HDF_BEGIN_TIME_STEP)
#define HDF_END_TIME_STEP           FC_FUNC_ (hdf_end_time_step,         HDF_END_TIME_STEP)
#endif

#if defined(__cplusplus)
extern "C" {
#endif
extern void hdf_write_invariant(int *iso, int * mpi_myself);
extern void HDF_BEGIN_TIME_STEP(int *iso);
extern void HDF_END_TIME_STEP(int *iso);
#if defined(__cplusplus)
}
#endif
class FileHandler: public PHRQ_base
{
public:
	FileHandler();
	~FileHandler(void);	
	IRM_RESULT ProcessRestartFiles(
		int *id, 
		int *initial_conditions1_in,
		int *initial_conditions2_in, 
		double *fraction1_in);
	bool GetHDFInitialized(void) {return this->HDFInitialized;}
	void SetHDFInitialized(bool tf) {this->HDFInitialized = tf;}
	bool GetHDFInvariant(void) {return this->HDFInvariant;}
	void SetHDFInvariant(bool tf) {this->HDFInvariant = tf;}
	bool GetXYZInitialized(void) {return this->XYZInitialized;}
	void SetXYZInitialized(bool tf) {this->XYZInitialized = tf;}
	std::vector< std::ostream * > &GetXYZOstreams(void) {return this->XYZOstreams;}
	std::vector< std::string > &GetHeadings(void) {return this->Headings;}
	void SetHeadings(std::vector< std::string > &h) {this->Headings = h;}
	void SetPointers(double *x_node, double *y_node, double *z_node, int *ic, double *saturation = NULL, int *mapping = NULL);
	IRM_RESULT SetRestartName(const char *name, long nchar);
	IRM_RESULT WriteRestartFile(int *id, int *print_restart = NULL, int *indices_ic = NULL);
	IRM_RESULT WriteFiles(int *id, int *print_hdf = NULL, int *print_media = NULL, int *print_xyz = NULL, int *xyz_mask = NULL, int *print_restart = NULL);
	IRM_RESULT WriteHDF(int *id, int *print_hdf, int *print_media);
	IRM_RESULT WriteRestart(int *id, int *print_restart);
	IRM_RESULT WriteXYZ(int *id, int *print_xyz, int *xyz_mask);

protected:
	bool HDFInitialized;
	bool HDFInvariant;
	bool XYZInitialized;
	std::vector< std::string > Headings;
	std::vector < std::ostream * > XYZOstreams;	
	std::map < std::string, int > RestartFileMap; 
	double * x_node;
	double * y_node;
	double * z_node;
	double * saturation;  // only root
	int    * mapping;     // only root
	int    * ic;
};
FileHandler file_handler;
// Constructor
FileHandler::FileHandler()
{
	this->io = new PHRQ_io;
	HDFInitialized = false;
	HDFInvariant = false;
	XYZInitialized = false;
}
// Destructor
FileHandler::~FileHandler()
{
	delete this->io;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::ProcessRestartFiles(
	int *id, 
	int *initial_conditions1_in,
	int *initial_conditions2_in, 
	double *fraction1_in)
	/* ---------------------------------------------------------------------- */
{
	/*
	*      nxyz - number of cells
	*      initial_conditions1 - Fortran, 7 x nxyz integer array, containing
	*      entity numbers for
	*           solution number
	*           pure_phases number
	*           exchange number
	*           surface number
	*           gas number
	*           solid solution number
	*           kinetics number
	*      initial_conditions2 - Fortran, 7 x nxyz integer array, containing
	*			 entity numbers
	*      fraction1 - Fortran 7 x n_cell  double array, fraction for entity 1  
	*
	*      Routine mixes solutions, pure_phase assemblages,
	*      exchangers, surface complexers, gases, solid solution assemblages,
	*      and kinetics for each cell.
	*   
	*      saves results in restart_bin and then the reaction module
	*/
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		IRM_RESULT rtn = IRM_OK;
		int nxyz = Reaction_module_ptr->GetGridCellCount();
		int count_chemistry = Reaction_module_ptr->GetChemistryCellCount();
		int mpi_myself = Reaction_module_ptr->GetMpiMyself();
		size_t array_size = (size_t) (7 *nxyz);

		std::vector < int > initial_conditions1, initial_conditions2;
		std::vector < double > fraction1;
		initial_conditions1.resize(array_size);
		initial_conditions2.resize(array_size);
		fraction1.resize(array_size);

		// Check for null pointer
		if (mpi_myself == 0)
		{
			if (initial_conditions1_in == NULL ||
				initial_conditions2_in == NULL ||
				fraction1_in == NULL)
			{
				RM_Error("NULL pointer in call to DistributeInitialConditions");
			}
			memcpy(initial_conditions1.data(), initial_conditions1_in, array_size * sizeof(int));
			memcpy(initial_conditions2.data(), initial_conditions2_in, array_size * sizeof(int));
			memcpy(fraction1.data(),           fraction1_in,           array_size * sizeof(double));
		}
#ifdef USE_MPI
	// Transfer arrays
	MPI_Bcast(initial_conditions1.data(), (int) array_size, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(initial_conditions2.data(), (int) array_size, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(fraction1.data(),           (int) array_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
		/*
		* Read any restart files
		*/
		cxxStorageBin restart_bin;
		for (std::map < std::string, int >::iterator it = RestartFileMap.begin(); it != RestartFileMap.end(); it++)
		{
			int	ifile = -100 - it->second;
			// Open file, use gsztream
			igzstream myfile;
			myfile.open(it->first.c_str());
			if (!myfile.good())

			{
				rtn = IRM_FAIL;
				std::ostringstream errstr;
				errstr << "File could not be opened: " << it->first.c_str();
				RM_ErrorMessage(errstr.str().c_str());
				continue;
			}
			// read file
			CParser	cparser(myfile, this->Get_io());
			cparser.set_echo_file(CParser::EO_NONE);
			cparser.set_echo_stream(CParser::EO_NONE);

			// skip headers
			while (cparser.check_line("restart", false, true, true, false) == PHRQ_io::LT_EMPTY);

			// read number of lines of index
			int	n = -1;
			if (!(cparser.get_iss() >> n) || n < 4)
			{
				myfile.close();
				std::ostringstream errstr;
				errstr << "File does not have node locations: " << it->first.c_str() << "\nPerhaps it is an old format restart file.";
				RM_Error(errstr.str().c_str());
			}

			// points are x, y, z, cell_no
			std::vector < Point > pts, soln_pts;
			// index:
			// 0 solution
			// 1 ppassemblage
			// 2 exchange
			// 3 surface
			// 4 gas phase
			// 5 ss_assemblage
			// 6 kinetics
			std::vector<int> c_index;
			for (int i = 0; i < n; i++)
			{
				cparser.check_line("restart", false, false, false, false);
				double
					x,
					y,
					z,
					v;
				cparser.get_iss() >> x;
				cparser.get_iss() >> y;
				cparser.get_iss() >> z;
				cparser.get_iss() >> v;
				pts.push_back(Point(x, y, z, v));

				int dummy;
				
				// Solution
				cparser.get_iss() >> dummy;
				c_index.push_back(dummy);
				// Don't put location in soln_pts if solution undefined
				if (dummy != -1)
					soln_pts.push_back(Point(x, y, z, v));

				// c_index defines entities present for each cell in restart file
				for (int j = 1; j < 7; j++)
				{
					cparser.get_iss() >> dummy;
					c_index.push_back(dummy);
				}

			}
			// Make Kd tree
			KDtree index_tree(pts);
			KDtree index_tree_soln(soln_pts);

			cxxStorageBin tempBin;
			tempBin.read_raw(cparser);

			for (int j = 0; j < count_chemistry; j++)	/* j is count_chem number */
			{
				int i = Reaction_module_ptr->GetBack()[j][0];   /* i is nxyz number */
				Point p(x_node[i], y_node[i], z_node[i]);
				int	k = (int) index_tree.Interpolate3d(p);	            // k is index number in tempBin
				int	k_soln = (int) index_tree_soln.Interpolate3d(p);	// k is index number in tempBin

				// solution
				if (initial_conditions1[i * 7] == ifile)
				{
					// All solutions must be defined
					if (tempBin.Get_Solution(k_soln) != NULL)
					{
						restart_bin.Set_Solution(j, tempBin.Get_Solution(k_soln));
					}
					else
					{
						assert(false);
						initial_conditions1[7 * i] = -1;
					}
				}

				// PPassemblage
				if (initial_conditions1[i * 7 + 1] == ifile)
				{
					if (c_index[k * 7 + 1] != -1)	// entity k should be defined in tempBin
					{
						if (tempBin.Get_PPassemblage(k) != NULL)
						{
							restart_bin.Set_PPassemblage(j, tempBin.Get_PPassemblage(k));
						}
						else
						{
							assert(false);
							initial_conditions1[7 * i + 1] = -1;
						}
					}
				}

				// Exchange
				if (initial_conditions1[i * 7 + 2] == ifile)
				{
					if (c_index[k * 7 + 2] != -1)	// entity k should be defined in tempBin
					{
						if (tempBin.Get_Exchange(k) != NULL)
						{
							restart_bin.Set_Exchange(j, tempBin.Get_Exchange(k));
						}
						else
						{
							assert(false);
							initial_conditions1[7 * i + 2] = -1;
						}
					}
				}

				// Surface
				if (initial_conditions1[i * 7 + 3] == ifile)
				{
					if (c_index[k * 7 + 3] != -1)	// entity k should be defined in tempBin
					{
						if (tempBin.Get_Surface(k) != NULL)
						{
							restart_bin.Set_Surface(j, tempBin.Get_Surface(k));
						}
						else
						{
							assert(false);
							initial_conditions1[7 * i + 3] = -1;
						}
					}
				}

				// Gas phase
				if (initial_conditions1[i * 7 + 4] == ifile)
				{
					if (c_index[k * 7 + 4] != -1)	// entity k should be defined in tempBin
					{
						if (tempBin.Get_GasPhase(k) != NULL)
						{
							restart_bin.Set_GasPhase(j, tempBin.Get_GasPhase(k));
						}
						else
						{
							assert(false);
							initial_conditions1[7 * i + 4] = -1;
						}
					}
				}

				// Solid solution
				if (initial_conditions1[i * 7 + 5] == ifile)
				{
					if (c_index[k * 7 + 5] != -1)	// entity k should be defined in tempBin
					{
						if (tempBin.Get_SSassemblage(k) != NULL)
						{
							restart_bin.Set_SSassemblage(j, tempBin.Get_SSassemblage(k));
						}
						else
						{
							assert(false);
							initial_conditions1[7 * i + 5] = -1;
						}
					}
				}

				// Kinetics
				if (initial_conditions1[i * 7 + 6] == ifile)
				{
					if (c_index[k * 7 + 6] != -1)	// entity k should be defined in tempBin
					{
						if (tempBin.Get_Kinetics(k) != NULL)
						{
							restart_bin.Set_Kinetics(j, tempBin.Get_Kinetics(k));
						}
						else
						{
							assert(false);
							initial_conditions1[7 * i + 6] = -1;
						}
					}
				}
			}
			myfile.close();
#ifdef USE_MPI	
			for (int i = Reaction_module_ptr->GetStartCell()[mpi_myself]; 
				i <= Reaction_module_ptr->GetEndCell()[mpi_myself]; i++)
			{
				Reaction_module_ptr->GetWorkers()[0]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(restart_bin,i);
			}
#else
			// put restart definitions in reaction module
			Reaction_module_ptr->GetWorkers()[0]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(restart_bin);
			int nthreads = Reaction_module_ptr->GetNthreads();
			for (int n = 1; n < nthreads; n++)
			{
				std::ostringstream delete_command;
				delete_command << "DELETE; -cells\n";
				for (int i = Reaction_module_ptr->GetStartCell()[n]; 
					i <= Reaction_module_ptr->GetEndCell()[n]; i++)
				{
					cxxStorageBin sz_bin;
					Reaction_module_ptr->GetWorkers()[0]->Get_PhreeqcPtr()->phreeqc2cxxStorageBin(sz_bin, i);
					Reaction_module_ptr->GetWorkers()[n]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(sz_bin, i);
					delete_command << i << "\n";
				}
				if (Reaction_module_ptr->GetWorkers()[0]->RunString(delete_command.str().c_str()) > 0) RM_Error(0);
			}
#endif
		}
		return rtn;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
void
FileHandler::SetPointers(double *x_node_in, double *y_node_in, double *z_node_in, int *ic_in,
	double * saturation_in, int *mapping_in)
/* ---------------------------------------------------------------------- */
{
	this->x_node = x_node_in;
	this->y_node = y_node_in;
	this->z_node = z_node_in;
	this->saturation = saturation_in;
	this->mapping = mapping_in;  // only root
	this->ic = ic_in;
	if (this->x_node == NULL ||
		this->y_node == NULL ||
		this->z_node == NULL ||
		this->ic == NULL)
	{
		error_msg("NULL pointer in FileHandler.SetPointers ", 1);
	}
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::SetRestartName(const char *name, long nchar)
/* ---------------------------------------------------------------------- */
{
	std::string str = PhreeqcRM::Char2TrimString(name, nchar);
	if (str.size() > 0)
	{
		int	i = (int) this->RestartFileMap.size();
		this->RestartFileMap[str] = i;
		return IRM_OK;
	}
	return IRM_INVALIDARG;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::WriteFiles(int *id, int *print_hdf_in, int *print_media_in, int *print_xyz_in, int *xyz_mask, int *print_restart_in)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{	
		IRM_RESULT rtn = IRM_OK;
		int local_mpi_myself = RM_GetMpiMyself(id);
		int print_hdf, print_media, print_xyz, print_restart;
		if (local_mpi_myself == 0)
		{
			if (print_hdf_in == 0 || 
				print_media_in == 0 ||
				print_xyz_in == 0 ||
				xyz_mask == 0 ||
				print_restart_in == 0)
			{
				RM_Error("Null pointer in WriteFiles");
			}
			print_media = *print_media_in;		
			print_hdf = *print_hdf_in;
			print_xyz = *print_xyz_in;
			print_restart = *print_restart_in;
		}
#ifdef USE_MPI	
		int flags[3];
		if (local_mpi_myself == 0)
		{
			flags[0] = *print_hdf_in;
			flags[1] = *print_xyz_in;
			flags[2] = *print_restart_in;
		}
		MPI_Bcast(flags, 3, MPI_INT, 0, MPI_COMM_WORLD);
		print_hdf = flags[0];
		print_xyz = flags[1];
		print_restart = flags[2];
#endif
		if (print_hdf != 0)
		{
			IRM_RESULT result = WriteHDF(id, &print_hdf, &print_media);
			if (result) rtn = result;
		}
		if (print_xyz != 0)
		{
			IRM_RESULT result = WriteXYZ(id, &print_xyz, xyz_mask);
			if (result) rtn = result;
		}		
		if (print_restart != 0)
		{
			IRM_RESULT result = WriteRestart(id, &print_restart);
			if (result) rtn = result;
		}
		return rtn;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::WriteHDF(int *id, int *print_hdf, int *print_media)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{	
		int local_mpi_myself = RM_GetMpiMyself(id);
		int nso = RM_GetSelectedOutputCount(id);
		int nxyz = RM_GetSelectedOutputRowCount(id); 
		double current_time = RM_GetTimeConversion(id) * RM_GetTime(id);
		//
		// Initialize HDF
		//
		if (!this->GetHDFInitialized() && nso > 0 && *print_hdf != 0)
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
							char prefix[256];
							RM_GetFilePrefix(id, prefix, 256);
							std::ostringstream filename;
							filename << prefix << "_" << n_user;
							HDFInitialize(iso, filename.str().c_str(), (int) strlen(filename.str().c_str()));

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
				this->SetHDFInitialized(true);
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
				if (n_user >= 0)
				{
					status = RM_SetCurrentSelectedOutputUserNumber(id, &n_user);
					int ncol = RM_GetSelectedOutputColumnCount(id);
					if (status >= 0)
					{
						if (local_mpi_myself == 0)
						{
							local_selected_out.resize((size_t) (nxyz*ncol));
							int so_error = RM_GetSelectedOutput(id, local_selected_out.data());
							if ( !this->GetHDFInvariant())
							{
								hdf_write_invariant(&iso, &local_mpi_myself);
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
			*print_media = 0;
			this->SetHDFInvariant(true);
		}
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::WriteRestart(int *id, int *print_restart)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		int mpi_myself = Reaction_module_ptr->GetMpiMyself();
		if (print_restart != 0)
		{
			int mpi_tasks = Reaction_module_ptr->GetMpiTasks();
			std::string char_buffer;

			ogzstream ofs_restart;

			std::string temp_name("temp_restart_file.gz");
			std::string name(Reaction_module_ptr->GetFilePrefix());
			std::string backup_name(name);
			if (mpi_myself == 0)
			{
				name.append(".restart.gz");
				backup_name.append(".restart.backup.gz");

				// open file 
				ofs_restart.open(temp_name.c_str());
				if (!ofs_restart.good())
				{
					std::ostringstream errstr;
					errstr << "Temporary restart file could not be opened: " << temp_name;
					error_msg(errstr.str().c_str(), 1);	
				}

				// write header
				int count_chemistry = Reaction_module_ptr->GetChemistryCellCount();
				ofs_restart << "#PHAST restart file" << std::endl;
				ofs_restart << "#Prefix: " << Reaction_module_ptr->GetFilePrefix() << std::endl;
				time_t now = ::time(NULL);
				ofs_restart << "#Date: " << ctime(&now);
				ofs_restart << "#Current model time: " << Reaction_module_ptr->GetTime() << std::endl;
				ofs_restart << "#Grid cells: " << Reaction_module_ptr->GetGridCellCount() << std::endl;
				ofs_restart << "#Chemistry cells: " << count_chemistry << std::endl;

				// write index
				ofs_restart << Reaction_module_ptr->GetChemistryCellCount() << std::endl;
				for (int j = 0; j < count_chemistry; j++)	/* j is count_chem number */
				{
					int i = Reaction_module_ptr->GetBack()[j][0];			/* i is nxyz number */
					ofs_restart << x_node[i] << "  " << y_node[i] << "  " << z_node[i] << "  " << j << "  ";
					// solution, use -1 if cell is dry
					if (this->saturation[i] > 0.0)
					{
						ofs_restart << this->ic[7 * i] << "  ";
					}
					else
					{
						ofs_restart << -1 << "  ";
					}
					// pp_assemblage
					ofs_restart << this->ic[7 * i + 1] << "  ";
					// exchange
					ofs_restart << this->ic[7 * i + 2] << "  ";
					// surface
					ofs_restart << this->ic[7 * i + 3] << "  ";
					// gas_phase
					ofs_restart << this->ic[7 * i + 4] << "  ";
					// solid solution
					ofs_restart << this->ic[7 * i + 5] << "  ";
					// kinetics
					ofs_restart << this->ic[7 * i + 6] << "\n";
				}
			}
			// write data
#ifdef USE_MPI
			Reaction_module_ptr->GetWorkers()[0]->SetDumpStringOn(true); 
			std::ostringstream in;
			in << "DUMP; -cells " << Reaction_module_ptr->GetStartCell()[mpi_myself] << "-" << Reaction_module_ptr->GetEndCell()[mpi_myself] << "\n";
			Reaction_module_ptr->GetWorkers()[0]->RunString(in.str().c_str());
			for (int n = 0; n < mpi_tasks; n++)
			{
				// Need to transfer output stream to root and print
				if (mpi_myself == n)
				{
					if (n == 0)
					{
						ofs_restart << Reaction_module_ptr->GetWorkers()[0]->GetDumpString();
					}
					else
					{
						int size = (int) strlen(Reaction_module_ptr->GetWorkers()[0]->GetDumpString());
						MPI_Send(&size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
						MPI_Send((void *) Reaction_module_ptr->GetWorkers()[0]->GetDumpString(), size, MPI_CHARACTER, 0, 0, MPI_COMM_WORLD);
					}	
				}
				else if (mpi_myself == 0)
				{
					MPI_Status mpi_status;
					int size;
					MPI_Recv(&size, 1, MPI_INT, n, 0, MPI_COMM_WORLD, &mpi_status);
					char_buffer.resize(size+1);
					MPI_Recv((void *) char_buffer.c_str(), size, MPI_CHARACTER, n, 0, MPI_COMM_WORLD, &mpi_status);
					char_buffer[size] = '\0';
					ofs_restart << char_buffer;
				}
			}
			// Clear dump string to save space
			std::ostringstream clr;
			clr << "END\n";
			Reaction_module_ptr->GetWorkers()[0]->RunString(clr.str().c_str());
#else
			for (int n = 0; n < (int) Reaction_module_ptr->GetNthreads(); n++)
			{
				// Create DUMP and write
				Reaction_module_ptr->GetWorkers()[n]->SetDumpStringOn(true); 
				std::ostringstream in;
				in << "DUMP; -cells " << Reaction_module_ptr->GetStartCell()[n] << "-" << Reaction_module_ptr->GetEndCell()[n] << "\n";
				Reaction_module_ptr->GetWorkers()[n]->RunString(in.str().c_str());
				ofs_restart << Reaction_module_ptr->GetWorkers()[n]->GetDumpString();
				// Clear dump string to save space
				std::ostringstream clr;
				clr << "END\n";
				Reaction_module_ptr->GetWorkers()[n]->RunString(clr.str().c_str());
			}
#endif

			ofs_restart.close();
			// rename files
			PhreeqcRM::FileRename(temp_name.c_str(), name.c_str(), backup_name.c_str());
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::WriteXYZ(int *id, int *print_xyz, int *xyz_mask)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{	
		int local_mpi_myself = RM_GetMpiMyself(id);
			
		int nso = RM_GetSelectedOutputCount(id);
		int nxyz = RM_GetSelectedOutputRowCount(id); 
		double current_time = RM_GetTimeConversion(id) * RM_GetTime(id);
		//
		// Initialize XYZ
		//
		if (!this->GetXYZInitialized() && nso > 0 && *print_xyz != 0)
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
							char prefix[256];
							RM_GetFilePrefix(id, prefix, 256);
							std::ostringstream filename;
							filename << prefix << "_" << n_user << ".chem.xyz.tsv";
							if (!this->Get_io()->punch_open(filename.str().c_str()))
							{
								RM_Error("Could not open xyz file.");
							}
							this->GetXYZOstreams().push_back(this->Get_io()->Get_punch_ostream());
							// write first headings
							char line_buff[132];
							sprintf(line_buff, "%15s\t%15s\t%15s\t%15s\t%2s\t", "x", "y",
								"z", "time", "in");
							this->Get_io()->punch_msg(line_buff);
							
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
							this->Get_io()->punch_msg(h.str().c_str());
						}
					}
				}
				this->SetXYZInitialized(true);
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
				if (n_user >= 0)
				{
					status = RM_SetCurrentSelectedOutputUserNumber(id, &n_user);
					int ncol = RM_GetSelectedOutputColumnCount(id);
					if (status >= 0)
					{
						if (local_mpi_myself == 0)
						{
							this->Get_io()->Set_punch_ostream(this->GetXYZOstreams()[iso]);
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
										ln << token;
									}
								}
								ln << "\n";
								this->Get_io()->punch_msg(ln.str().c_str());
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
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
void
FH_FinalizeFiles()
/* ---------------------------------------------------------------------- */
{
	HDFFinalize();

	file_handler.Get_io()->Set_punch_ostream(NULL);
	for (int iso = 0; iso < (int) file_handler.GetXYZOstreams().size(); iso++)
	{
		delete file_handler.GetXYZOstreams()[iso];
	}
	file_handler.GetXYZOstreams().clear();
}
//
// Wrappers
//
/* ---------------------------------------------------------------------- */
void
FH_ProcessRestartFiles(
	int *id, 
	int *initial_conditions1_in,
	int *initial_conditions2_in, 
	double *fraction1_in)
/* ---------------------------------------------------------------------- */
{
	file_handler.ProcessRestartFiles(id, initial_conditions1_in, 
		initial_conditions2_in, fraction1_in);
}

/* ---------------------------------------------------------------------- */
void
FH_SetPointers(double *x_node, double *y_node, double *z_node, int *ic, double *saturation, int *mapping)
/* ---------------------------------------------------------------------- */
{
	file_handler.SetPointers(x_node, y_node, z_node, ic, saturation, mapping);
}
/* ---------------------------------------------------------------------- */
void
FH_SetRestartName(const char *name, long nchar)
/* ---------------------------------------------------------------------- */
{
	if (name)
	{
		file_handler.SetRestartName(name, nchar);
	}
}
/* ---------------------------------------------------------------------- */
void
FH_WriteFiles(int *id, int *print_hdf, int *print_media, int *print_xyz, int *xyz_mask, int *print_restart)
/* ---------------------------------------------------------------------- */
{
	file_handler.WriteFiles(id, print_hdf, print_media, print_xyz, xyz_mask, print_restart);
}
