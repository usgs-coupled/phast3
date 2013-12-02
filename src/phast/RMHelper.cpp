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
	IRM_RESULT ProcesseRestartFiles(
		int *id, 
		int *initial_conditions1_in,
		int *initial_conditions2_in, 
		double *fraction1_in,
		double *x_node_in,
		double *y_node_in,
		double *z_node_in);
	int SetRestartName(std::string str);

protected:
	std::map < std::string, int > FileMap; 
	std::vector<int> have_Solution;
	std::vector<int> have_PPassemblage;
	std::vector<int> have_Exchange;
	std::vector<int> have_Surface;
	std::vector<int> have_GasPhase;
	std::vector<int> have_SSassemblage;
	std::vector<int> have_Kinetics;
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
	RMHelperInfo::ProcesseRestartFiles(
	int *id, 
	int *initial_conditions1_in,
	int *initial_conditions2_in, 
	double *fraction1_in,
	double *x_node,
	double *y_node,
	double *z_node
	)
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
		/*
		* Make copy of initial conditions for use in restart file
		*/
		for (int i = 0; i < nxyz; i++)
		{
			int j = 7 * i;
			have_Solution.push_back(initial_conditions1[j]);
			j++;
			have_PPassemblage.push_back(initial_conditions1[j]);
			j++;
			have_Exchange.push_back(initial_conditions1[j]);
			j++;
			have_Surface.push_back(initial_conditions1[j]);
			j++;
			have_GasPhase.push_back(initial_conditions1[j]);
			j++;
			have_SSassemblage.push_back(initial_conditions1[j]);
			j++;
			have_Kinetics.push_back(initial_conditions1[j]);
		}

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
int
RMH_SetRestartName(const char *name, long nchar)
/* ---------------------------------------------------------------------- */
{
	if (name)
	{
		std::string stdstring(name, nchar);
		trim(stdstring);
		return rmhelper.SetRestartName(stdstring);
	}
	return -1;
}
int
RMHelperInfo::SetRestartName(std::string str)
{
	int	i = (int) this->FileMap.size();
	this->FileMap[str] = i;
	return IRM_OK;
}