#include <windows.h>
#include <string>
#include <map>
#include "RMHelper.h"
#include "Reaction_module.h"
#include "RM_interface.h"
#include "gzstream.h"
#include "KDtree/KDtree.h"
#include "Phreeqc.h"
#include "IPhreeqc.h"
#ifdef THREADED_PHAST
#include <omp.h>
#endif
#ifdef USE_MPI
#include "mpi.h"
#endif
class RMHelperInfo: public PHRQ_base
{
public:
	RMHelperInfo();
	~RMHelperInfo();
	IRM_RESULT ProcessRestartFiles(
		int *id, 
		int *initial_conditions1_in,
		int *initial_conditions2_in, 
		double *fraction1_in);
	IRM_RESULT SetRestartName(const char *name, long nchar);
	IRM_RESULT WriteRestartFile(int *id, int *print_restart = NULL, int *indices_ic = NULL);
	void SetNodes(double *x_node, double *y_node, double *z_node);

protected:
	std::map < std::string, int > FileMap; 
	double * x_node;
	double * y_node;
	double * z_node;
};
RMHelperInfo rmhelper; 

// Constructor
RMHelperInfo::RMHelperInfo()
{
	this->io = new PHRQ_io;
}
// Destructor
RMHelperInfo::~RMHelperInfo()
{
	delete this->io;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
ProcessRestartFiles(
	int *id, 
	int *initial_conditions1_in,
	int *initial_conditions2_in, 
	double *fraction1_in)
/* ---------------------------------------------------------------------- */
{
	return rmhelper.ProcessRestartFiles(id, initial_conditions1_in, 
		initial_conditions2_in, fraction1_in);
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RMHelperInfo::ProcessRestartFiles(
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
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
				fraction1_in == NULL ||
				x_node == NULL ||
				y_node == NULL ||
				z_node == NULL 
				)
			{
				std::ostringstream errstr;
				errstr << "NULL pointer in call to DistributeInitialConditions\n";
				error_msg(errstr.str().c_str(), 1);
			}

			memcpy(initial_conditions1.data(), initial_conditions1_in, array_size * sizeof(int));
			memcpy(initial_conditions2.data(), initial_conditions2_in, array_size * sizeof(int));
			memcpy(fraction1.data(),           fraction1_in,           array_size * sizeof(double));
		}
#ifdef USE_MPI
	//
	// Transfer arrays
	//
	MPI_Bcast(initial_conditions1.data(), (int) array_size, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(initial_conditions2.data(), (int) array_size, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(fraction1.data(),           (int) array_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
		int begin = Reaction_module_ptr->GetStartCell()[mpi_myself];
		int end =   Reaction_module_ptr->GetEndCell()[mpi_myself] + 1;

		/*
		* Read any restart files
		*/
		cxxStorageBin restart_bin;
		for (std::map < std::string, int >::iterator it = FileMap.begin(); it != FileMap.end(); it++)
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
				error_msg(errstr.str().c_str());
				break;
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
				rtn = IRM_FAIL;
				std::ostringstream errstr;
				errstr << "File does not have node locations: " << it->first.c_str() << "\nPerhaps it is an old format restart file.";
				error_msg(errstr.str().c_str(), 1);
				myfile.close();
				break;
			}

			// points are x, y, z, cell_no
			std::vector < Point > pts;
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
				// c_index defines entities present for each cell in restart file
				for (int j = 0; j < 7; j++)
				{
					cparser.get_iss() >> dummy;
					c_index.push_back(dummy);
				}

			}
			// Make Kd tree
			KDtree index_tree(pts);

			cxxStorageBin tempBin;
			tempBin.read_raw(cparser);

			for (int j = 0; j < count_chemistry; j++)	/* j is count_chem number */
			{
				int i = Reaction_module_ptr->GetBack()[j][0];   /* i is nxyz number */
				Point p(x_node[i], y_node[i], z_node[i]);
				int	k = (int) index_tree.Interpolate3d(p);	// k is index number in tempBin

				// solution
				if (initial_conditions1[i * 7] == ifile)
				{
					if (c_index[k * 7] != -1)	// entity k should be defined in tempBin
					{
						if (tempBin.Get_Solution(k) != NULL)
						{
							restart_bin.Set_Solution(j, tempBin.Get_Solution(k));
						}
						else
						{
							assert(false);
							initial_conditions1[7 * i] = -1;
						}
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
IRM_RESULT
RMH_SetRestartName(const char *name, long nchar)
/* ---------------------------------------------------------------------- */
{
	if (name)
	{
		return rmhelper.SetRestartName(name, nchar);
	}
	return IRM_OK;
}
IRM_RESULT
RMHelperInfo::SetRestartName(const char *name, long nchar)
{
	std::string str = Reaction_module::Cptr2TrimString(name, nchar);
	if (str.size() > 0)
	{
		int	i = (int) this->FileMap.size();
		this->FileMap[str] = i;
		return IRM_OK;
	}
	return IRM_INVALIDARG;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
WriteRestartFile(int *id, int *print_restart, int *indices_ic)
/* ---------------------------------------------------------------------- */
{
	return rmhelper.WriteRestartFile(id, print_restart, indices_ic);
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RMHelperInfo::WriteRestartFile(int *id, int *print_restart_in, int *indices_ic)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		int mpi_myself = Reaction_module_ptr->GetMpiMyself();
		int print_restart;
		if (mpi_myself == 0)
		{
			if (print_restart_in == NULL ||
				x_node == NULL ||
				y_node == NULL ||
				z_node == NULL ||
				indices_ic == NULL)
			{
				//rtn = IRM_FAIL;
				std::ostringstream errstr;
				errstr << "NULL pointer in WriteRestartFile";
				error_msg(errstr.str().c_str(), 1);
			}
			print_restart = *print_restart_in;
		}
#ifdef USE_MPI
		MPI_Bcast(&print_restart, 1, MPI_INT, 0, MPI_COMM_WORLD);
#endif
		if (print_restart != 0)
		{
			int mpi_tasks = Reaction_module_ptr->GetMpiTasks();
			std::string char_buffer;

			ogzstream ofs_restart;
			//ofstream ofs_restart;

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
					rmhelper.error_msg(errstr.str().c_str(), 1);	
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
					for (size_t k = 0; k < Reaction_module_ptr->GetBack()[j].size(); k++)
					{
						int i = Reaction_module_ptr->GetBack()[j][k];			/* i is nxyz number */
						ofs_restart << x_node[i] << "  " << y_node[i] << "  " << z_node[i] << "  " << j << "  ";
						// solution 
						//ofs_restart << rmhelper.have_Solution[i] << "  ";
						ofs_restart << indices_ic[7 * i] << "  ";
						// pp_assemblage
						//ofs_restart << have_PPassemblage[i] << "  ";
						ofs_restart << indices_ic[7 * i + 1] << "  ";
						// exchange
						//ofs_restart << have_Exchange[i] << "  ";
						ofs_restart << indices_ic[7 * i + 2] << "  ";
						// surface
						//ofs_restart << have_Surface[i] << "  ";
						ofs_restart << indices_ic[7 * i + 3] << "  ";
						// gas_phase
						//ofs_restart << have_GasPhase[i] << "  ";
						ofs_restart << indices_ic[7 * i + 4] << "  ";
						// solid solution
						//ofs_restart << have_SSassemblage[i] << "  ";
						ofs_restart << indices_ic[7 * i + 5] << "  ";
						// kinetics
						//ofs_restart << have_Kinetics[i] << std::endl;
						ofs_restart << indices_ic[7 * i + 6] << std::endl;
					}
				}
			}

			// write data
#ifdef USE_MPI
			Reaction_module_ptr->GetWorkers()[0]->SetDumpStringOn(true); 
			std::ostringstream in;
			std::cerr << "Start of writing " << mpi_myself << std::endl;
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
#else
			for (int n = 0; n < (int) Reaction_module_ptr->GetWorkers().size() - 1; n++)
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
			FileRename(temp_name.c_str(), name.c_str(), backup_name.c_str());
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
bool
FileExists(const std::string &name)
/* ---------------------------------------------------------------------- */
{
	FILE *stream;
	if ((stream = fopen(name.c_str(), "r")) == NULL)
	{
		return false;				/* doesn't exist */
	}
	fclose(stream);
	return true;					/* exists */
}

/* ---------------------------------------------------------------------- */
void
FileRename(const std::string &temp_name, const std::string &name, 
	const std::string &backup_name)
/* ---------------------------------------------------------------------- */
{
	if (FileExists(name))
	{
		if (FileExists(backup_name.c_str()))
			remove(backup_name.c_str());
		rename(name.c_str(), backup_name.c_str());
	}
	rename(temp_name.c_str(), name.c_str());
}
/* ---------------------------------------------------------------------- */
void
SetNodes(double *x_node, double *y_node, double *z_node)
/* ---------------------------------------------------------------------- */
{
	rmhelper.SetNodes(x_node, y_node, z_node);
}
/* ---------------------------------------------------------------------- */
void
RMHelperInfo::SetNodes(double *x_node_in, double *y_node_in, double *z_node_in)
/* ---------------------------------------------------------------------- */
{
	this->x_node = x_node_in;
	this->y_node = y_node_in;
	this->z_node = z_node_in;

}