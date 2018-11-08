#include "PhreeqcRM.h"
#ifdef WIN32
#include <windows.h>
#endif
#include <string>
#include <map>
#include <iostream>
#include "FileHandler.h"
#include "RM_interface_C.h"
#include "IPhreeqcPhast.h"
#ifdef USE_GZ
#include "gzstream.h"
#else
#define gzFile FILE*
#define gzclose fclose
#define gzopen fopen
#define gzprintf fprintf
#define igzstream ifstream
#endif
#include "KDtree/KDtree.h"
#include "Phreeqc.h"
#include "Solution.h"
#include "IPhreeqc.h"
#include "hdf.h"
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
class FileHandler: public PHRQ_base
{
public:
	FileHandler();
	~FileHandler(void);	
	IRM_RESULT ProcessRestartFiles(
		int *initial_conditions1_in,
		int *initial_conditions2_in, 
		double *fraction1_in);
	bool GetHDFInitialized(void) {return this->HDFInitialized;}
	void SetHDFInitialized(bool tf) {this->HDFInitialized = tf;}
	bool GetHDFInvariant(void) {return this->HDFInvariant;}
	void SetHDFInvariant(bool tf) {this->HDFInvariant = tf;}
	bool GetXYZInitialized(void) {return this->XYZInitialized;}
	void SetXYZInitialized(bool tf) {this->XYZInitialized = tf;}
	std::map< std::string, std::ostream * > &GetBcZoneOstreams(void) {return this->BcZoneOstreams;}
	std::vector< std::ostream * > &GetXYZOstreams(void) {return this->XYZOstreams;}
	std::vector< std::string > &GetHeadings(void) {return this->Headings;}
	void SetHeadings(std::vector< std::string > &h) {this->Headings = h;}
	void SetSaturation(double *saturation);
	void SetNodes(double *x_node, double *y_node, double *z_node);
	void SetPhreeqcRM(int rm_id);
	IRM_RESULT SetRestartName(const char *name);
	IRM_RESULT WriteRestartFile(int *print_restart = NULL, int *indices_ic = NULL);
	IRM_RESULT WriteFiles(int *print_hdf = NULL, int *print_media = NULL, int *print_xyz = NULL, int *xyz_mask = NULL, int *print_restart = NULL);
	IRM_RESULT WriteHDF(int *print_hdf, int *print_media);
	IRM_RESULT WriteRestart(int *print_restart);
	IRM_RESULT WriteXYZ(int *print_xyz, int *xyz_mask);
    IRM_RESULT WriteBcRaw(double *c, int *solution_list, int * bc_solution_count, int * solution_number, char *prefix);

protected:
	bool HDFInitialized;
	bool HDFInvariant;
	bool XYZInitialized;
	std::vector< std::string > Headings;
	std::vector < std::ostream * > XYZOstreams;	
	std::map < std::string, int > RestartFileMap; 
	std::vector<double> x_node;
	std::vector<double> y_node;
	std::vector<double> z_node;
	double * saturation;               // only root
	//std::vector<int> mapping;        // only root
	std::vector<int> ic;
	std::map <std::string, std::ostream * > BcZoneOstreams;
	int rm_id;
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
#define SAVE_MEMORY
#if defined(SAVE_MEMORY) && defined(USE_MPI)
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::ProcessRestartFiles(
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(this->rm_id);
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
		this->ic.resize(array_size);

		// Check for null pointer
		if (mpi_myself == 0)
		{
			if (initial_conditions1_in == NULL ||
				initial_conditions2_in == NULL ||
				fraction1_in == NULL)
			{
				int result = IRM_FAIL;
				RM_Abort(this->rm_id, result, "NULL pointer in call to ProcessRestartFiles");
			}
			memcpy(&initial_conditions1.front(), initial_conditions1_in, array_size * sizeof(int));
			memcpy(&initial_conditions2.front(), initial_conditions2_in, array_size * sizeof(int));
			memcpy(&fraction1.front(),           fraction1_in,           array_size * sizeof(double));
			memcpy(&this->ic.front(), &initial_conditions1[0], array_size * sizeof(int));
		}
		/*
		* Read any restart files
		*/
		int block = 5000;
		for (std::map < std::string, int >::iterator it = RestartFileMap.begin(); it != RestartFileMap.end(); it++)
		{
			if (mpi_myself == 0)
			{	
				std::cerr << "Reading restart file " << it->first << std::endl;
				int	ifile = -100 - it->second;
				// Open file, use gsztream
				igzstream myfile;
				myfile.open(it->first.c_str());
				if (!myfile.good())

				{
					rtn = IRM_FAIL;
					std::ostringstream errstr;
					errstr << "File could not be opened: " << it->first.c_str();
					int result = IRM_FAIL;
					RM_Abort(this->rm_id, result, errstr.str().c_str());
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
					int result = IRM_FAIL;
					RM_Abort(this->rm_id, result, errstr.str().c_str());
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
				tempBin.read_raw(cparser);   // For big restart file, can't read in each process
				// root reads and distributes
				int pct = 0;
				std::cerr << "Restart transfer ";

				for (int n = 0; n < Reaction_module_ptr->GetMpiTasks(); n++)
				{						
					int count = Reaction_module_ptr->GetEndCell()[n] - Reaction_module_ptr->GetStartCell()[n] + 1;
					int nblocks = count / block;
					if (count % block > 0) nblocks += 1;
					for (int iblock = 0; iblock < nblocks; iblock++)
					{
						cxxStorageBin restart_bin;
						int start = Reaction_module_ptr->GetStartCell()[n] + iblock*block;
						int end = Reaction_module_ptr->GetStartCell()[n] + (iblock + 1)*block - 1;
						if (end > Reaction_module_ptr->GetEndCell()[n])
						{
							end = Reaction_module_ptr->GetEndCell()[n];
						}
						for (int j = start; j <= end; j++)
						{
							/* j is count_chem number */
							int i = Reaction_module_ptr->GetBackwardMapping()[j][0];   /* i is nxyz number */
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
							// Cell has been added to restart_bin
						}
						// block has been written to restart_bin
						if (n == 0)   
						{
							// restart_bin to root
							for (int i = Reaction_module_ptr->GetStartCell()[mpi_myself]; 
								i <= Reaction_module_ptr->GetEndCell()[mpi_myself]; i++)
							{
								Reaction_module_ptr->GetWorkers()[0]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(restart_bin,i);
							}
						}
						else           
						{
							// restart_bin to nonroot
							std::ostringstream dump;
							restart_bin.dump_raw(dump, 0);
							size_t string_size = dump.str().size() + 1;
							MPI_Send(&string_size, 1, MPI_INT, n, 0, MPI_COMM_WORLD);
							MPI_Send((void *) dump.str().c_str(), (int) string_size, MPI_CHAR, n, 0, MPI_COMM_WORLD);
						}
						if ((end * 100) / count_chemistry > pct)
						{
							int pct_block_count = ((end * 10) / count_chemistry) * 10;
							if (pct_block_count < 100)
							{
								std::cerr << pct_block_count << "% ";
							}
							pct = pct_block_count + 10;
						}
						//MPI_Barrier(MPI_COMM_WORLD);
					}
					// end of loop on blocks for a task for a restart file
				}	
				std::cerr << "100% " << std::endl;
				// end of loop on tasks for a restart file
				myfile.close();
			}
			// end of root for a restart file
			else           
			{		
				// nonroot receives initial conditions
				for (int n = 0; n < Reaction_module_ptr->GetMpiTasks(); n++)
				{			
					int count = Reaction_module_ptr->GetEndCell()[n] - Reaction_module_ptr->GetStartCell()[n] + 1;
					int nblocks = count / block;
					if (count % block > 0) nblocks += 1;
					for (int iblock = 0; iblock < nblocks; iblock++)
					{ 
						if (mpi_myself == n) 
						{
							int begin_cell = iblock*block;
							int end_cell = begin_cell + block - 1;
							if (end_cell > Reaction_module_ptr->GetEndCell()[n]) end_cell = Reaction_module_ptr->GetEndCell()[n];

							MPI_Status mpi_status;
							int size;
							MPI_Recv(&size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &mpi_status);
							char * string_buffer = new char[size + 1];
							MPI_Recv((void *) string_buffer, size, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &mpi_status);
							string_buffer[size] = '\0';
							Reaction_module_ptr->GetWorkers()[0]->RunString(string_buffer);
						}
						//MPI_Barrier(MPI_COMM_WORLD);
					}
				}				
			}
			// end of nonroot for restart file
		}  
		// end of restart file loop
		return rtn;
	}
	return IRM_BADINSTANCE;
}
#else // SAVE_MEMORY
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::ProcessRestartFiles(
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(this->rm_id);
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
		this->ic.resize(array_size);

		// Check for null pointer
		if (mpi_myself == 0)
		{
			if (initial_conditions1_in == NULL ||
				initial_conditions2_in == NULL ||
				fraction1_in == NULL)
			{
				int result = IRM_FAIL;
				RM_Abort(this->rm_id, result, "NULL pointer in call to ProcessRestartFiles");
			}
			memcpy((void *) &initial_conditions1.front(), initial_conditions1_in, array_size * sizeof(int));
			memcpy((void *) &initial_conditions2.front(), initial_conditions2_in, array_size * sizeof(int));
			memcpy((void *) &fraction1.front(),           fraction1_in,           array_size * sizeof(double));
			memcpy((void *) &this->ic.front(),           &initial_conditions1[0], array_size * sizeof(int));
		}
		if (RestartFileMap.size() > 0) 
		{
#ifdef USE_MPI
			// Transfer arrays
			MPI_Bcast(&initial_conditions1.front(), (int) array_size, MPI_INT, 0, MPI_COMM_WORLD);
			MPI_Bcast(&initial_conditions2.front(), (int) array_size, MPI_INT, 0, MPI_COMM_WORLD);
			MPI_Bcast(&fraction1.front(),           (int) array_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
			//memcpy(this->ic.data(), &initial_conditions1[0], array_size * sizeof(int));
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
					//RM_ErrorMessage(this->rm_id, errstr.str().c_str());
					int result = IRM_FAIL;
					RM_Abort(this->rm_id, result, errstr.str().c_str());
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
					int result = IRM_FAIL;
					RM_Abort(this->rm_id, result, errstr.str().c_str());
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
					int i = Reaction_module_ptr->GetBackwardMapping()[j][0];   /* i is nxyz number */
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
				int nthreads = Reaction_module_ptr->GetThreadCount();
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
					int status = Reaction_module_ptr->GetWorkers()[0]->RunString(delete_command.str().c_str());
					Reaction_module_ptr->ErrorHandler(status, "ProcessRestartFiles, RunString");
					//if (Reaction_module_ptr->GetWorkers()[0]->RunString(delete_command.str().c_str()) > 0) RM_Error(id);
				}
#endif
			}
		}
		if (mpi_myself != 0) 
		{
			x_node.clear();
			y_node.clear();
			z_node.clear();
			ic.clear();
		}
		return rtn;
	}
	return IRM_BADINSTANCE;
}
#endif
/* ---------------------------------------------------------------------- */
void
FileHandler::SetSaturation(double * saturation_in)
/* ---------------------------------------------------------------------- */
{
	this->saturation = saturation_in;
	if (this->saturation == NULL)
	{
		error_msg("NULL pointer in FileHandler.SetSaturation ", 1);
	}
}
/* ---------------------------------------------------------------------- */
void
FileHandler::SetNodes(double *x_node_in, double *y_node_in, double *z_node_in)
/* ---------------------------------------------------------------------- */
{
	if (x_node_in == NULL ||
		y_node_in == NULL ||
		z_node_in == NULL )
	{
		error_msg("NULL pointer in FileHandler.SetNodes ", 1);
	}
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(this->rm_id);
	int nxyz = Reaction_module_ptr->GetGridCellCount();

	if (Reaction_module_ptr->GetMpiMyself() == 0)
	{
		this->x_node.resize(nxyz);
		this->y_node.resize(nxyz);
		this->z_node.resize(nxyz);
		for (int i = 0; i < nxyz; i++)
		{
			this->x_node[i] = x_node_in[i];
			this->y_node[i] = y_node_in[i];
			this->z_node[i] = z_node_in[i];
		}
	}
#ifdef USE_MPI
	//MPI_Bcast(&this->x_node[0], nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	//MPI_Bcast(&this->y_node[0], nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	//MPI_Bcast(&this->z_node[0], nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}
/* ---------------------------------------------------------------------- */
void
FileHandler::SetPhreeqcRM(int rm_id_in)
/* ---------------------------------------------------------------------- */
{

	this->rm_id = rm_id_in;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::SetRestartName(const char *name)
/* ---------------------------------------------------------------------- */
{
	//std::string str = PhreeqcRM::Char2TrimString(name, nchar);
	std::string str(name);
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
FileHandler::WriteFiles(int *print_hdf_in, int *print_media_in, int *print_xyz_in, int *xyz_mask, int *print_restart_in)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(this->rm_id);
	if (Reaction_module_ptr)
	{	
		IRM_RESULT rtn = IRM_OK;
		int print_hdf, print_media, print_xyz, print_restart;

		if (print_hdf_in == 0 || 
			print_media_in == 0 ||
			print_xyz_in == 0 ||
			xyz_mask == 0 ||
			print_restart_in == 0)
		{
			Reaction_module_ptr->ErrorHandler(IRM_FAIL, "NULL pointer in FileHandler::WriteFiles");
			//RM_Error(id, "Null pointer in WriteFiles");
			return IRM_FAIL;
		}
		else
		{
			print_media = *print_media_in;		
			print_hdf = *print_hdf_in;
			print_xyz = *print_xyz_in;
			print_restart = *print_restart_in;

			if (print_hdf != 0)
			{
				IRM_RESULT result = WriteHDF(&print_hdf, &print_media);
				if (result) rtn = result;
			}
			if (print_xyz != 0)
			{
				IRM_RESULT result = WriteXYZ(&print_xyz, xyz_mask);
				if (result) rtn = result;
			}		
			if (print_restart != 0)
			{
				IRM_RESULT result = WriteRestart(&print_restart);
				if (result) rtn = result;
			}	

			return rtn;
		}
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::WriteHDF(int *print_hdf, int *print_media)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(this->rm_id);
	if (Reaction_module_ptr)
	{	
		int local_mpi_myself = RM_GetMpiMyself(this->rm_id);
		int nso = RM_GetSelectedOutputCount(this->rm_id);
		int nxyz = RM_GetSelectedOutputRowCount(this->rm_id); 
		//
		// Initialize HDF
		//
		if (!this->GetHDFInitialized() && *print_hdf != 0)
		{
			if (nso > 0) 
			{
				for (int iso = 0; iso < nso; iso++)
				{
					int status;
					int n_user = RM_GetNthSelectedOutputUserNumber(this->rm_id, iso);
					if (n_user >= 0)
					{
						status = RM_SetCurrentSelectedOutputUserNumber(this->rm_id, n_user);
						if (status >= 0)
						{
							// open file
							char prefix[256];
							RM_GetFilePrefix(this->rm_id, prefix, 256);
							std::ostringstream filename;
							filename << prefix << "_" << n_user;
							HDFInitialize(iso, filename.str().c_str(), (int) strlen(filename.str().c_str()));

							// Set HDF scalars
							std::vector < std::string > headings;
							int ncol = RM_GetSelectedOutputColumnCount(this->rm_id);
							for (int icol = 0; icol < ncol; icol++)
							{
								char head[100];
								status = RM_GetSelectedOutputHeading(this->rm_id, icol, head, 100);
								headings.push_back(head);
							}
							HDFSetScalarNames(iso, headings);
						}
					}
				}
			}
			else 
			{
				// open file
				char prefix[256];
				RM_GetFilePrefix(this->rm_id, prefix, 256);
				std::ostringstream filename;
				filename << prefix;
				HDFInitialize(0, filename.str().c_str(), (int) strlen(filename.str().c_str()));
			}
			this->SetHDFInitialized(true);
		}
		//	
		// Write H5 file
		//
		if (*print_hdf != 0)
		{
			if (nso > 0) 
			{
				std::vector<double> local_selected_out;
				int status;
				for (int iso = 0; iso < nso; iso++)
				{
					int n_user = RM_GetNthSelectedOutputUserNumber(this->rm_id, iso);
					if (n_user >= 0)
					{
						status = RM_SetCurrentSelectedOutputUserNumber(this->rm_id, n_user);
						int ncol = RM_GetSelectedOutputColumnCount(this->rm_id);
						if (status >= 0)
						{
							local_selected_out.resize((size_t) (nxyz*ncol));
							RM_GetSelectedOutput(this->rm_id, &local_selected_out.front());
							if ( !this->GetHDFInvariant())
							{
								HDF_WRITE_INVARIANT(&iso, &local_mpi_myself);
							}
							// Now write HDF file
							HDF_BEGIN_TIME_STEP(&iso);
							HDFBeginCTimeStep(iso);
							HDFFillHyperSlab(iso, local_selected_out, ncol);
							HDFEndCTimeStep(iso);
							HDF_END_TIME_STEP(&iso);
						}
					}
				}
			}
			else
			{
				int iso = 0;
				if ( !this->GetHDFInvariant())
				{
					HDF_WRITE_INVARIANT(&iso, &local_mpi_myself);
				}
				// Now write HDF file
				HDF_BEGIN_TIME_STEP(&iso);
				HDF_END_TIME_STEP(&iso);
			}
			*print_media = 0;
			this->SetHDFInvariant(true);
		}
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::WriteHDF(int id, int *print_hdf, int *print_media)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{	
		int local_mpi_myself = RM_GetMpiMyself(id);
		int nso = RM_GetSelectedOutputCount(id);
		int nxyz = RM_GetSelectedOutputRowCount(id); 
		//
		// Initialize HDF
		//
		if (!this->GetHDFInitialized() && nso > 0 && *print_hdf != 0)
		{
			for (int iso = 0; iso < nso; iso++)
			{
				int status;
				int n_user = RM_GetNthSelectedOutputUserNumber(id, iso);
				if (n_user >= 0)
				{
					status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
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
							status = RM_GetSelectedOutputHeading(id, icol, head, 100);
							headings.push_back(head);
						}
						HDFSetScalarNames(iso, headings);
					}
				}
			}
			this->SetHDFInitialized(true);
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
				int n_user = RM_GetNthSelectedOutputUserNumber(id, iso);
				if (n_user >= 0)
				{
					status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
					int ncol = RM_GetSelectedOutputColumnCount(id);
					if (status >= 0)
					{
						local_selected_out.resize((size_t) (nxyz*ncol));
						RM_GetSelectedOutput(id, &local_selected_out.front());
						if ( !this->GetHDFInvariant())
						{
							HDF_WRITE_INVARIANT(&iso, &local_mpi_myself);
						}
						// Now write HDF file
						HDF_BEGIN_TIME_STEP(&iso);
						HDFBeginCTimeStep(iso);
						HDFFillHyperSlab(iso, local_selected_out, ncol);
						HDFEndCTimeStep(iso);
						HDF_END_TIME_STEP(&iso);
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
#endif
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::WriteRestart(int *print_restart)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(this->rm_id);
	if (Reaction_module_ptr)
	{
		//Reaction_module_ptr->GetSaturation(this->saturation);
		int mpi_myself = Reaction_module_ptr->GetMpiMyself();
		if (print_restart != 0)
		{
			gzFile restart_file;
#ifdef USE_GZ
			std::string temp_name("temp_restart_file.gz");
#else
			std::string temp_name("temp_restart_file");
#endif

			std::string name(Reaction_module_ptr->GetFilePrefix());
			std::string backup_name(name);
			if (mpi_myself == 0)
			{
#ifdef USE_GZ
				name.append(".restart.gz");
				backup_name.append(".restart.gz~");
#else
				name.append(".restart");
				backup_name.append(".restart~");
#endif

				// open file 
				restart_file = gzopen(temp_name.c_str(), "wb");
				if (restart_file == NULL)
				{
					std::ostringstream errstr;
					errstr << "Temporary restart file could not be opened: " << temp_name;
					error_msg(errstr.str().c_str(), 1);
					throw PhreeqcRMStop();
				}

				// write header
				int count_chemistry = Reaction_module_ptr->GetChemistryCellCount();
				gzprintf(restart_file, "%s\n", "#PHAST restart file");
				gzprintf(restart_file, "%s%s\n", "#Prefix: ", Reaction_module_ptr->GetFilePrefix().c_str());
				time_t now = ::time(NULL);
				gzprintf(restart_file, "%s%s\n", "#Date: ", ctime(&now));
				gzprintf(restart_file, "%s%e\n", "#Current model time: ", Reaction_module_ptr->GetTime());
				gzprintf(restart_file, "%s%d\n", "#Grid cells: ", Reaction_module_ptr->GetGridCellCount());
				gzprintf(restart_file, "%s%d\n", "#Chemistry cells: ", count_chemistry);

				// write index
				gzprintf(restart_file, "%d\n", count_chemistry );
				for (int j = 0; j < count_chemistry; j++)	/* j is count_chem number */
				{
					int i = Reaction_module_ptr->GetBackwardMapping()[j][0];			/* i is nxyz number */
					gzprintf(restart_file, "%e %e %e %d ",  x_node[i], y_node[i], z_node[i], j);
					// write all solutions
					gzprintf(restart_file, "%d ", this->ic[7 * i]);
					// solution, use -1 if cell is dry
					//if (this->saturation[i] > 0.0)
					//{
					//	gzprintf(restart_file, "%d ", this->ic[7 * i]);
					//}
					//else
					//{
					//	gzprintf(restart_file, "-1 ");
					//}
					// pp_assemblage
					gzprintf(restart_file, "%d ", this->ic[7 * i + 1]);
					// exchange
					gzprintf(restart_file, "%d ", this->ic[7 * i + 2]);
					// surface
					gzprintf(restart_file, "%d ", this->ic[7 * i + 3]);
					// gas_phase
					gzprintf(restart_file, "%d ", this->ic[7 * i + 4]);
					// solid solution
					gzprintf(restart_file, "%d ", this->ic[7 * i + 5]);
					// kinetics
					gzprintf(restart_file, "%d \n", this->ic[7 * i + 6]);
				}
				gzclose(restart_file);
			}
			// write data
			Reaction_module_ptr->SetDumpFileName(temp_name.c_str());
			Reaction_module_ptr->DumpModule(true, true);

			// rename files
			if (mpi_myself == 0)
			{
				PhreeqcRM::FileRename(temp_name.c_str(), name.c_str(), backup_name.c_str());
			}
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::WriteXYZ(int *print_xyz, int *xyz_mask)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(this->rm_id);
	if (Reaction_module_ptr)
	{	
		//if (Reaction_module_ptr->GetComponentCount() > 0)
		//{
		//	Reaction_module_ptr->GetSaturation(this->saturation);
		//}
		int nso = RM_GetSelectedOutputCount(this->rm_id);
		int nxyz = RM_GetSelectedOutputRowCount(this->rm_id); 
		double current_time = RM_GetTimeConversion(this->rm_id) * RM_GetTime(this->rm_id);
		//
		// Initialize XYZ
		//
		if (!this->GetXYZInitialized() && nso > 0 && *print_xyz != 0)
		{
			for (int iso = 0; iso < nso; iso++)
			{
				int status;
				int n_user = RM_GetNthSelectedOutputUserNumber(this->rm_id, iso);
				if (n_user >= 0)
				{
					status = RM_SetCurrentSelectedOutputUserNumber(this->rm_id, n_user);
					if (status >= 0)
					{
						// open file							
						char prefix[256];
						RM_GetFilePrefix(this->rm_id, prefix, 256);
						std::ostringstream filename;
						filename << prefix << "_" << n_user << ".chem.xyz.tsv";
						if (!this->Get_io()->punch_open(filename.str().c_str()))
						{
							Reaction_module_ptr->ErrorHandler(IRM_FAIL, "Could not open xyz file.");
						}
						this->GetXYZOstreams().push_back(this->Get_io()->Get_punch_ostream());
						// write first headings
						char line_buff[132];
						sprintf(line_buff, "%15s\t%15s\t%15s\t%15s\t%2s\t", "x", "y",
							"z", "time", "in");
						this->Get_io()->punch_msg(line_buff);

						// create chemistry headings
						int ncol = RM_GetSelectedOutputColumnCount(this->rm_id);
						std::ostringstream h;
						for (int icol = 0; icol < ncol; icol++)
						{
							char head[100];
							status = RM_GetSelectedOutputHeading(this->rm_id, icol, head, 100);
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
		//	
		// Write XYZ file
		//
		if (*print_xyz != 0)
		{
			std::vector<double> local_selected_out;
			int status;
			for (int iso = 0; iso < nso; iso++)
			{
				int n_user = RM_GetNthSelectedOutputUserNumber(this->rm_id, iso);
				if (n_user >= 0)
				{
					status = RM_SetCurrentSelectedOutputUserNumber(this->rm_id, n_user);
					int ncol = RM_GetSelectedOutputColumnCount(this->rm_id);
					if (status >= 0)
					{
						this->Get_io()->Set_punch_ostream(this->GetXYZOstreams()[iso]);
						local_selected_out.resize((size_t) (nxyz*ncol));
						RM_GetSelectedOutput(this->rm_id, &local_selected_out.front());

						// write xyz file
#ifdef NEW_STYLE_XYZ
						for (int irow = 0; irow < nxyz; irow++)
						{
#else
						for (int ichem = 0; ichem < RM_GetChemistryCellCount(this->rm_id); ichem++)
						{
							PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(this->rm_id);
							int irow = Reaction_module_ptr->GetBackwardMapping()[ichem][0];
#endif
							if (xyz_mask[irow] <= 0) continue;
							int active = 1;
							if (Reaction_module_ptr->GetForwardMapping()[irow] < 0 || saturation[irow] <= 0 || saturation[irow] > 1e29)
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

	std::map< std::string, std::ostream * >::iterator it;
	for (it = file_handler.GetBcZoneOstreams().begin(); it != file_handler.GetBcZoneOstreams().end(); it++)
	{
		delete it->second;
	}
	file_handler.GetBcZoneOstreams().clear();
}
//
// Wrappers
//
/* ---------------------------------------------------------------------- */
void
FH_ProcessRestartFiles(
	int *initial_conditions1_in,
	int *initial_conditions2_in, 
	double *fraction1_in)
/* ---------------------------------------------------------------------- */
{
	file_handler.ProcessRestartFiles(initial_conditions1_in, 
		initial_conditions2_in, fraction1_in);
}
/* ---------------------------------------------------------------------- */
void
FH_SetSaturation(double *saturation)
/* ---------------------------------------------------------------------- */
{
	file_handler.SetSaturation(saturation);
}
/* ---------------------------------------------------------------------- */
void
FH_SetNodes(double *x_node, double *y_node, double *z_node)
/* ---------------------------------------------------------------------- */
{
	file_handler.SetNodes(x_node, y_node, z_node);
}
/* ---------------------------------------------------------------------- */
void
FH_SetPhreeqcRM(int *rm_id)
/* ---------------------------------------------------------------------- */
{
	file_handler.SetPhreeqcRM(*rm_id);
}
/* ---------------------------------------------------------------------- */
void
FH_SetRestartName(const char *name)
/* ---------------------------------------------------------------------- */
{
	if (name)
	{
		file_handler.SetRestartName(name);
	}
}
/* ---------------------------------------------------------------------- */
void
FH_WriteFiles(int *print_hdf, int *print_media, int *print_xyz, int *xyz_mask, int *print_restart)
/* ---------------------------------------------------------------------- */
{
	file_handler.WriteFiles(print_hdf, print_media, print_xyz, xyz_mask, print_restart);
}
/* ---------------------------------------------------------------------- */
void
FH_WriteBcRaw(double *c, int *solution_list, int * bc_solution_count, int * solution_number, char *prefix)
/* ---------------------------------------------------------------------- */
{
	file_handler.WriteBcRaw(c, solution_list, bc_solution_count, solution_number, prefix);
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
FileHandler::WriteBcRaw(double *c_in, int *solution_list, int * bc_solution_count, int * solution_number, char *prefix)
/* ---------------------------------------------------------------------- */
{
	// c                 array of concentrations
	// solution_list     set of cells to write
	// bc_solution_count number of cells in solution_list
	// solution_number   number to assign to the first cell (increment for each additional cell)
	// prefix            file name

	if (*solution_number == 0) return IRM_OK;
	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(this->rm_id);
	if (Reaction_module_ptr)
	{
		// Open file
		//std::string fn(prefix, prefix_l);
                std::string fn(prefix);
		//fn = trim_right(fn);
		
		std::ofstream *ofs;
		if(this->BcZoneOstreams.find(fn) == this->BcZoneOstreams.end())
		{
			ofs = new(std::ofstream);
			ofs->open(fn.c_str(), std::ios_base::app);
			if (!ofs->is_open())
			{
				std::ostringstream errstr;
				errstr << "Boundary condition file could not be opened for writing: " << fn;
				error_msg(errstr.str().c_str(), 1);
				delete ofs;
				throw PhreeqcRMStop();
			}
			BcZoneOstreams[fn] = ofs;
		}
		else
		{
			ofs = (ofstream *) BcZoneOstreams.find(fn)->second;
		}
		// Create std vector of concentrations
		std::vector<double> c;
		c.resize(Reaction_module_ptr->GetGridCellCount() * Reaction_module_ptr->GetComponentCount());
		memcpy(&c.front(), c_in, Reaction_module_ptr->GetGridCellCount() * Reaction_module_ptr->GetComponentCount());

		//
		int raw_number = *solution_number;
		std::vector<double> tc;
		std::vector<double> p_atm;
		tc.push_back(15.0);
		p_atm.push_back(1.0);
		for (int i = 0; i < *bc_solution_count; i++)
		{
			std::ostringstream oss;
			int n_fort = solution_list[i];
			int n_chem = Reaction_module_ptr->GetForwardMapping()[n_fort - 1];
			if (n_chem >= 0)
			{
				// Put concentrations for n_chem into a vector
				std::vector<double> cell;
				for(int i = 0; i < Reaction_module_ptr->GetComponentCount(); i++)
				{
					cell.push_back(c[i*Reaction_module_ptr->GetGridCellCount() + n_fort - 1]);
				}
				Reaction_module_ptr->Concentrations2Utility(cell, tc, p_atm);
				oss << "# Fortran cell " << n_fort << ". Time " << Reaction_module_ptr->GetTime() << "\n";
				Reaction_module_ptr->GetWorkers()[Reaction_module_ptr->GetThreadCount()]->Get_solution(1)->dump_raw(oss,0,&raw_number);
				raw_number++;
				*ofs << oss.str();
			}
			else
			{
				assert(false);
			}
		}
		//*solution_number = raw_number;
		*ofs << "# Done with zone for time step." << std::endl;
	}
	return IRM_OK;
}
