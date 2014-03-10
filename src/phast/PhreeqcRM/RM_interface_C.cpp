#include "PhreeqcRM.h"
#include "RM_interface_C.h"
#include "IPhreeqcPhastLib.h"
#include "Phreeqc.h"
#include "PHRQ_io.h"
#include <string>
#include <map>
#ifdef THREADED_PHAST
#include <omp.h>
#endif
#ifdef USE_MPI
#include "mpi.h"
#endif
/* ---------------------------------------------------------------------- */
IRM_RESULT RM_Abort(int id, int result, const char * str)
/* ---------------------------------------------------------------------- */
{
	// decodes error
	// writes any error messages
	// exits 
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->DecodeError(result);
		Reaction_module_ptr->ErrorMessage(str);
		Reaction_module_ptr->MpiAbort();
		Reaction_module_ptr->DestroyReactionModule(id);
	    exit(4);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_CloseFiles(int id)
/* ---------------------------------------------------------------------- */
{	
	// closes output and log file
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->CloseFiles();
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int
RM_Concentrations2Utility(int id, double *c, int n, double *tc, double *p_atm)
/* ---------------------------------------------------------------------- */
{
	// set of concentrations c is imported to SOLUTIONs in the Utility IPhreeqc
	// n is the number of sets of concentrations
	// c is of size n times count_components, equivalent to Fortran definition (n, ncomps)
	// tc is array of dimension n of temperatures 
	// p_atm is array of dimension n pressure
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::vector<double> c_vector, tc_vector, p_atm_vector;
		size_t ncomps = Reaction_module_ptr->GetComponents().size();
		c_vector.resize(n * ncomps, 0.0);

		for (size_t i = 0; i < (size_t) n; i++)
		{
			for (size_t j = 0; j < ncomps; j++)
			{
				c_vector[j * n + i] = c[j * n + i];
			}
			tc_vector.push_back(tc[i]);
			p_atm_vector.push_back(p_atm[i]);
		}
		IPhreeqc * util_ptr = Reaction_module_ptr->Concentrations2Utility(c_vector, tc_vector, p_atm_vector);
		if (util_ptr != NULL)
		{
			return util_ptr->GetId();
		}
		return IRM_FAIL;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int RM_Create(int nxyz, int nthreads)
/* ---------------------------------------------------------------------- */
{
	//
	// Creates reaction module, called by root and MPI workers
	//
	return PhreeqcRM::CreateReactionModule(nxyz, nthreads);
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_CreateMapping(int id, int *grid2chem)
/* ---------------------------------------------------------------------- */
{
	//
	// Creates mapping from all grid cells to only cells for chemistry
	// Excludes inactive cells (negative values) and cells that are redundant by symmetry (many-to-one mapping)
	// (1D or 2D chemistry)
	//
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->CreateMapping(grid2chem);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_DecodeError(int id, int e)
/* ---------------------------------------------------------------------- */
{
	// Prints the error message for IRM_RESULT e
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->DecodeError(e);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT RM_Destroy(int id)
/* ---------------------------------------------------------------------- */
{
	return PhreeqcRM::DestroyReactionModule(id);
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_DumpModule(int id, int dump_on, int use_gz)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->DumpModule((dump_on != 0), (use_gz != 0));
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_ErrorMessage(int id, const char *err_str)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		if (err_str)
		{
			std::string e_string(err_str);
			trim_right(e_string);
			Reaction_module_ptr->ErrorMessage(e_string);
			return IRM_OK;
		}
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int
RM_FindComponents(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return (Reaction_module_ptr->FindComponents());
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetChemistryCellCount(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetChemistryCellCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetComponent(int id, int num, char *chem_name, int l1)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		if (chem_name != NULL)
		{
			if (l1 >= 0)
			{
				strncpy(chem_name, Reaction_module_ptr->GetComponents()[num].c_str(), l1);
			}
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int RM_GetComponentCount(int id)
/* ---------------------------------------------------------------------- */
{
	// Returns the number of components 
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetComponentCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_GetConcentrations(int id, double * c)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetConcentrations(c);
	}
	return IRM_BADINSTANCE;
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
int
RM_GetDensity(int id, double * d)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		IRM_RESULT return_value = IRM_OK;
		Reaction_module_ptr->GetDensity();
		if (Reaction_module_ptr->GetMpiMyself() == 0)
		{
			if (Reaction_module_ptr->GetDensity().size() == Reaction_module_ptr->GetGridCellCount())
			{
				memcpy(d, Reaction_module_ptr->GetDensity().data(), (size_t) (Reaction_module_ptr->GetGridCellCount()*sizeof(double)));
			}
			else
			{
				for (int i = 0; i < Reaction_module_ptr->GetGridCellCount(); i++)
				{
					d[i] = INACTIVE_CELL_VALUE;
				}
				return_value = IRM_FAIL;
			}
		}
		return return_value;
	}
	return IRM_BADINSTANCE;
}
#endif
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetDensity(int id, double * d)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		IRM_RESULT return_value = IRM_OK;
		std::vector <double> density;
		Reaction_module_ptr->GetDensity(density);
		if (Reaction_module_ptr->GetMpiMyself() == 0)
		{
			if (density.size() == Reaction_module_ptr->GetGridCellCount())
			{
				memcpy(d, density.data(), (size_t) (Reaction_module_ptr->GetGridCellCount()*sizeof(double)));
			}
			else
			{
				for (int i = 0; i < Reaction_module_ptr->GetGridCellCount(); i++)
				{
					d[i] = INACTIVE_CELL_VALUE;
				}
				return_value = IRM_FAIL;
			}
		}
		return return_value;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_GetFilePrefix(int id, char *prefix, int l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		if (prefix)
		{
			strncpy(prefix, Reaction_module_ptr->GetFilePrefix().c_str(), l);
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetGfw(int id, double * gfw)
/* ---------------------------------------------------------------------- */
{
	// Retrieves gram formula weights
	// size of d must be the number of components
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		size_t ncomps = Reaction_module_ptr->GetComponents().size();
		if (ncomps > 0)
		{
			memcpy(gfw, Reaction_module_ptr->GetGfw().data(), ncomps * sizeof(double));
			return IRM_OK;
		}
		return IRM_FAIL;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int RM_GetGridCellCount(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetGridCellCount();
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int 
RM_GetIPhreeqcId(int id, int i)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetIPhreeqcId(i);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int 
RM_GetMpiMyself(int id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetMpiMyself();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetMpiTasks(int id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetMpiTasks();
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int 
RM_GetNthSelectedOutputUserNumber(int id, int i)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetNthSelectedOutputUserNumber(i);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_GetSelectedOutput(int id, double * so)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutput(so);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetSelectedOutputColumnCount(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutputColumnCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetSelectedOutputCount(int id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutputCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_GetSelectedOutputHeading(int id, int icol, char *heading, int length)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::string head;
		IRM_RESULT rtn = Reaction_module_ptr->GetSelectedOutputHeading(icol, head);
		if (rtn >= 0)
		{
			strncpy(heading, head.c_str(), length);
		}
		return rtn;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetSelectedOutputRowCount(int id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutputRowCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetSolutionVolume(int id, double * v)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		IRM_RESULT return_value = IRM_OK;
		Reaction_module_ptr->GetSolutionVolume();
		if (Reaction_module_ptr->GetMpiMyself() == 0)
		{
			if (Reaction_module_ptr->GetSolutionVolume().size() == Reaction_module_ptr->GetGridCellCount())
			{
				memcpy(v, Reaction_module_ptr->GetSolutionVolume().data(), (size_t) (Reaction_module_ptr->GetGridCellCount()*sizeof(double)));
			}
			else
			{
				for (int i = 0; i < Reaction_module_ptr->GetGridCellCount(); i++)
				{
					v[i] = INACTIVE_CELL_VALUE;
				}
				return_value = IRM_FAIL;
			}
		}
		return return_value;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetSpeciesConcentrations(int id, double * species_conc)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		IRM_RESULT return_value = IRM_OK;
		std::vector<double> species_conc_vector;
		return_value = Reaction_module_ptr->GetSpeciesConcentrations(species_conc_vector);
		if (return_value == IRM_OK)
		{
			memcpy(species_conc, species_conc_vector.data(), species_conc_vector.size()*sizeof(double));
		}
		return return_value;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int
RM_GetSpeciesCount(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSpeciesCount();
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetSpeciesD25(int id, double * diffc)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		const std::vector<double> & diffc_vector = Reaction_module_ptr->GetSpeciesD25();
		memcpy(diffc, diffc_vector.data(), diffc_vector.size()*sizeof(double));
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_GetSpeciesName(int id, int i, char *name, int length)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		const std::vector<std::string> & names = Reaction_module_ptr->GetSpeciesNames();
		if (i >= 0 && i < (int) names.size())
		{
			strncpy(name, names[i].c_str(), length);
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int RM_GetSpeciesSaveOn(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return (Reaction_module_ptr->GetSpeciesSaveOn() ? 1 : 0);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetSpeciesZ(int id, double * z)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		const std::vector<double> & z_vector = Reaction_module_ptr->GetSpeciesZ();
		memcpy(z, z_vector.data(), z_vector.size()*sizeof(double));
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int 
RM_GetThreadCount(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetThreadCount();
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
double RM_GetTime(int id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetTime();
	}
	return (double) IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
double RM_GetTimeConversion(int id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetTimeConversion();
	}
	return (double) IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
double RM_GetTimeStep(int id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetTimeStep();
	}
	return (double) IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_InitialPhreeqc2Concentrations(
			int id,
			double *boundary_c,
			int n_boundary,
			int *boundary_solution1,  
			int *boundary_solution2, 
			double *fraction1)
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes a list of solution numbers and returns a set of
 *   concentrations
 *   Input: n_boundary - number of boundary conditions in list
 *          boundary_solution1 - list of first solution numbers to be mixed
 *          boundary_solution2 - list of second solution numbers to be mixed
 *          fraction1 - list of mixing fractions of solution 1
 *
 *   Output: boundary_c - concentrations for boundary conditions
 *                      - dimensions must be >= n_boundary x n_comp
 *
 */
	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::vector < int > boundary_solution1_vector, boundary_solution2_vector;
		std::vector < double > destination_c, fraction1_vector;
		boundary_solution1_vector.resize(n_boundary);
		memcpy(boundary_solution1_vector.data(), boundary_solution1, (size_t) (n_boundary * sizeof(int)));
		if (boundary_solution2 != NULL)
		{
			boundary_solution2_vector.resize(n_boundary);
			memcpy(boundary_solution2_vector.data(), boundary_solution2, (size_t) (n_boundary * sizeof(int)));
		}
		if (fraction1 != NULL)
		{
			fraction1_vector.resize(n_boundary);
			memcpy(fraction1_vector.data(), fraction1, (size_t) (n_boundary * sizeof(double)));
		}
		IRM_RESULT return_value = Reaction_module_ptr->InitialPhreeqc2Concentrations(
			destination_c,
			boundary_solution1_vector,
			boundary_solution2_vector,
			fraction1_vector);		
		if (return_value == 0)
		{
			memcpy(boundary_c, destination_c.data(), destination_c.size() * sizeof(double));
		}       
		return return_value;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_InitialPhreeqc2Module(int id,
							  int *initial_conditions1,		// 7 x nxyz end-member 1
							  int *initial_conditions2,		// 7 x nxyz end-member 2
							  double *fraction1)			// 7 x nxyz fraction of end-member 1
/* ---------------------------------------------------------------------- */
{
		// 7 indices for initial conditions
		// 0 solution
		// 1 ppassemblage
		// 2 exchange
		// 3 surface
		// 4 gas phase
		// 5 ss_assemblage
		// 6 kinetics
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->InitialPhreeqc2Module(
			initial_conditions1,
			initial_conditions2,
			fraction1);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_InitialPhreeqcCell2Module(int id,
                int n,		                            // InitialPhreeqc cell number
                int *module_numbers,		            // Module cell numbers
                int dim_module_numbers)			    // Number of module cell numbers
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::vector <int> module_numbers_vector;
		module_numbers_vector.resize(dim_module_numbers);
		memcpy(module_numbers_vector.data(), module_numbers, (size_t) (dim_module_numbers) * sizeof(int));
		return Reaction_module_ptr->InitialPhreeqcCell2Module(
			n,
			module_numbers_vector);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_InitialPhreeqc2SpeciesConcentrations(
			int id,
			double *species_c,
			int n_boundary,
			int *boundary_solution1,  
			int *boundary_solution2, 
			double *fraction1)
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes a list of solution numbers and returns a set of
 *   aqueous species concentrations
 *   Input: n_boundary - number of boundary conditions in list
 *          boundary_solution1 - list of first solution numbers to be mixed
 *          boundary_solution2 - list of second solution numbers to be mixed
 *          fraction1 - list of mixing fractions of solution 1
 *
 *   Output: species_c - aqueous species concentrations for boundary conditions
 *                     - dimensions must be n_boundary x n_species
 *
 */
	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		if (species_c && boundary_solution1)
		{
			std::vector < int > boundary_solution1_vector, boundary_solution2_vector;
			std::vector < double > destination_c, fraction1_vector;
			boundary_solution1_vector.resize(n_boundary);
			memcpy(boundary_solution1_vector.data(), boundary_solution1, (size_t) (n_boundary * sizeof(int)));
			if (boundary_solution2 != NULL)
			{
				boundary_solution2_vector.resize(n_boundary);
				memcpy(boundary_solution2_vector.data(), boundary_solution2, (size_t) (n_boundary * sizeof(int)));
			}
			if (fraction1 != NULL)
			{
				fraction1_vector.resize(n_boundary);
				memcpy(fraction1_vector.data(), fraction1, (size_t) (n_boundary * sizeof(double)));
			}
			IRM_RESULT return_value = Reaction_module_ptr->InitialPhreeqc2SpeciesConcentrations(
				destination_c,
				boundary_solution1_vector,
				boundary_solution2_vector,
				fraction1_vector);		
			if (return_value == 0)
			{
				memcpy(species_c, destination_c.data(), destination_c.size() * sizeof(double));
			}       
			return return_value;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_LoadDatabase(int id, const char *db_name)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::string db = PhreeqcRM::Char2TrimString(db_name);
		return Reaction_module_ptr->LoadDatabase(db.c_str());
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_LogMessage(int id, const char *err_str)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		if (err_str)
		{
			std::string e_string(err_str);
			Reaction_module_ptr->LogMessage(e_string);
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_MpiWorker(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->MpiWorker();
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_MpiWorkerBreak(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->MpiWorkerBreak();
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_OpenFiles(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->OpenFiles();
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_OutputMessage(int id, const char *err_str)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		if (err_str)
		{
			std::string e_string(err_str);
			Reaction_module_ptr->OutputMessage(e_string);
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_RunCells(int id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		//if (!Reaction_module_ptr->GetStopMessage())
		//{
			// Run chemistry calculations
			return Reaction_module_ptr->RunCells(); 
		//}
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_RunFile(int id, int workers, int initial_phreeqc, int utility, const char *chem_name)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::string str = PhreeqcRM::Char2TrimString(chem_name);
		return Reaction_module_ptr->RunFile((workers != 0), (initial_phreeqc != 0), (utility != 0), str.c_str());
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_RunString(int id, int workers, int initial_phreeqc, int utility, const char *input_string)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::string str = PhreeqcRM::Char2TrimString(input_string);
		return Reaction_module_ptr->RunString((workers != 0), (initial_phreeqc != 0), (utility != 0), input_string);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_ScreenMessage(int id, const char *err_str)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		if (err_str)
		{
			std::string e_string(err_str);
			Reaction_module_ptr->ScreenMessage(e_string);
			return IRM_OK;
		}
	    return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetCellVolume(int id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetCellVolume(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetComponentH2O(int id, int tf)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetComponentH2O(tf != 0);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetConcentrations(int id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetConcentrations(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetCurrentSelectedOutputUserNumber(int id, int i)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetCurrentSelectedOutputUserNumber(i);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetDensity(int id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetDensity(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetDumpFileName(int id, const char *name)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::string str = PhreeqcRM::Char2TrimString(name);
		return Reaction_module_ptr->SetDumpFileName(str.c_str());
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetErrorHandlerMode(int id, int mode)
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetErrorHandlerMode(mode);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetFilePrefix(int id, const char *name)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::string str = PhreeqcRM::Char2TrimString(name);
		return Reaction_module_ptr->SetFilePrefix(str.c_str());
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetMpiWorkerCallback(int id, int (*fcn)(int *x1, void *cookie))
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetMpiWorkerCallbackC(fcn);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetMpiWorkerCallbackCookie(int id, void *cookie)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetMpiWorkerCallbackCookie(cookie);
	}
	return IRM_BADINSTANCE;
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
int 
RM_SetPartitionUZSolids(int id, int t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetPartitionUZSolids(t);
	}
	return IRM_BADINSTANCE;
}
#endif
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetPoreVolume(int id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetPoreVolume(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetPressure(int id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetPressure(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetPrintChemistryOn(int id,	 int worker, int ip, int utility)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		bool tf_w = (worker != 0);
		bool tf_ip = (ip != 0);
		bool tf_utility = (utility != 0);
		return Reaction_module_ptr->SetPrintChemistryOn(tf_w, tf_ip, tf_utility);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetPrintChemistryMask(int id, int *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetPrintChemistryMask(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetRebalanceFraction(int id, double f)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetRebalanceFraction(f);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetRebalanceByCell(int id, int method)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetRebalanceByCell(method != 0);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetSaturation(int id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetSaturation(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetSelectedOutputOn(int id, int selected_output_on)
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetSelectedOutputOn(selected_output_on != 0);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetSpeciesSaveOn(int id, int save_on)
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetSpeciesSaveOn(save_on != 0);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetTemperature(int id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetTemperature(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetTime(int id, double t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetTime(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetTimeConversion(int id, double t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetTimeConversion(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetTimeStep(int id, double t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetTimeStep(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsExchange (int id, int u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetUnitsExchange(u);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsGasPhase (int id, int u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetUnitsGasPhase(u);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsKinetics (int id, int u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetUnitsKinetics(u);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsPPassemblage (int id, int u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetUnitsPPassemblage(u);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsSolution (int id, int u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetUnitsSolution(u);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsSSassemblage (int id, int u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetUnitsSSassemblage(u);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsSurface (int id, int u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetUnitsSurface(u);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SpeciesConcentrations2Module(int id, double * species_conc)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		if (species_conc)
		{
			IRM_RESULT return_value = IRM_OK;
			std::vector<double> species_conc_vector;
			species_conc_vector.resize(Reaction_module_ptr->GetGridCellCount() * Reaction_module_ptr->GetSpeciesCount());
			memcpy(species_conc_vector.data(), species_conc, species_conc_vector.size()*sizeof(double));
			return_value = Reaction_module_ptr->SpeciesConcentrations2Module(species_conc_vector);
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
/* 
--------------------------------------------------------------------- */
IRM_RESULT
RM_WarningMessage(int id, const char *err_str)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		if (err_str)
		{
			std::string e_string(err_str);
			trim_right(e_string);
			Reaction_module_ptr->WarningMessage(e_string);
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
void RM_write_bc_raw(
			int id,
			int *solution_list, 
			int bc_solution_count, 
			int solution_number, 
			char *prefix)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::string fn(prefix, prefix_l);
		Reaction_module_ptr->Write_bc_raw(
					solution_list, 
					bc_solution_count,
					solution_number, 
					fn);
	}
}
#endif
