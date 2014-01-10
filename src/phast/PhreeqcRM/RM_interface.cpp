#include "PhreeqcRM.h"
#include "RM_interface.h"
#include "IPhreeqcPhastLib.h"
#include "Phreeqc.h"
#include "PHRQ_io.h"
#include <string>
#include <map>
#include "hdf.h"
#ifdef THREADED_PHAST
#include <omp.h>
#endif
#ifdef USE_MPI
#include "mpi.h"
#endif

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_CloseFiles(int *id)
/* ---------------------------------------------------------------------- */
{
	// error_file is stderr
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->CloseFiles();
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int
RM_Concentrations2Utility(int *id, double *c, int *n, int *dim, double *tc, double *p_atm)
/* ---------------------------------------------------------------------- */
{
	// error_file is stderr
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		std::vector<double> c_vector, tc_vector, p_atm_vector;
		size_t ncomps = Reaction_module_ptr->GetComponents().size();
		c_vector.resize(*n * ncomps, 0.0);

		for (size_t i = 0; i < (size_t) *n; i++)
		{
			for (size_t j = 0; j < ncomps; j++)
			{
				c_vector[j * (*n) + i] = c[j * (*dim) + i];
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
void
RM_convert_to_molal(int *id, double *c, int *n, int *dim)
/* ---------------------------------------------------------------------- */
{
/*
 *  Converts data in c from mass fraction to molal
 *  Assumes c(dim, ncomps) and only first n rows are converted
 */
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Convert_to_molal(c, *n, *dim);
	}
}

/* ---------------------------------------------------------------------- */
int RM_Create(int *nxyz, int *nthreads)
/* ---------------------------------------------------------------------- */
{
	return PhreeqcRM::CreateReactionModule(*nxyz, *nthreads);
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_CreateMapping(int *id, int *grid2chem)
/* ---------------------------------------------------------------------- */
{
	//
	// Creates mapping from all grid cells to only cells for chemistry
	// Excludes inactive cells and cells that are redundant by symmetry
	// (1D or 2D chemistry)
	//
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->CreateMapping(grid2chem);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_Destroy(int *id)
/* ---------------------------------------------------------------------- */
{
	return PhreeqcRM::DestroyReactionModule(*id);
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_DumpModule(int *id, int *dump_on, int *use_gz)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		bool dump = false;
		bool gz = false;
		if (Reaction_module_ptr->GetMpiMyself() == 0)
		{
			bool dump = (*dump_on != 0);
			bool gz = (*use_gz != 0);
		}
		return Reaction_module_ptr->DumpModule(dump, gz);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_ErrorHandler(int *id, int *result, const char * str, size_t l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		try
		{
			Reaction_module_ptr->ErrorHandler(*result, PhreeqcRM::Char2TrimString(str, l));
		}
		catch (PhreeqcRMStop)
		{
			Reaction_module_ptr->ErrorMessage("PhreeqcRM error.");
		}
		catch (...)
		{
			Reaction_module_ptr->ErrorMessage("Unknown exception.");
		}
		return Reaction_module_ptr->ReturnHandler((IRM_RESULT) *result, "");
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_ErrorMessage(int *id, const char *err_str, size_t l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		std::string e_string(err_str, (int) l);
		trim_right(e_string);
		e_string.append("\n");
		Reaction_module_ptr->ErrorMessage(e_string);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int
RM_FindComponents(int *id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return (Reaction_module_ptr->FindComponents());
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetChemistryCellCount(int * id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetChemistryCellCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_GetComponent(int * id, int * num, char *chem_name, size_t l1)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		if (chem_name != NULL)
		{
			if (l1 > 0)
			{
				strncpy(chem_name, Reaction_module_ptr->GetComponents()[*num - 1].c_str(), l1);
			}
			else
			{
				strcpy(chem_name, Reaction_module_ptr->GetComponents()[*num - 1].c_str());
			}
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetConcentrations(int *id, double * c)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetConcentrations(c);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetDensity(int *id, double * d)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		IRM_RESULT return_value = IRM_OK;
		Reaction_module_ptr->GetDensity();
		if (Reaction_module_ptr->GetMpiMyself() == 0)
		{
			if ((int) Reaction_module_ptr->GetDensity().size() == Reaction_module_ptr->GetGridCellCount())
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
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_GetFilePrefix(int * id, char *prefix, size_t l)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		strncpy(prefix, Reaction_module_ptr->GetFilePrefix().c_str(), l);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetGridCellCount(int * id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetGridCellCount();
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int 
RM_GetIPhreeqcId(int * id, int * i)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetIPhreeqcId(*i);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetMpiMyself(int * id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetMpiMyself();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetMpiTasks(int * id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetMpiTasks();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetNThreads(int * id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetNThreads();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetNthSelectedOutputUserNumber(int * id, int * i)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetNthSelectedOutputUserNumber(i);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_GetSelectedOutput(int * id, double * so)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutput(so);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetSelectedOutputColumnCount(int * id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutputColumnCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetSelectedOutputCount(int * id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutputCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_GetSelectedOutputHeading(int * id, int *icol, char *heading, size_t length)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		std::string head;
		IRM_RESULT rtn = Reaction_module_ptr->GetSelectedOutputHeading(icol, head);
		if (rtn == IRM_OK)
		{
			strncpy(heading, head.c_str(), length);
		}
		return rtn;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetSelectedOutputRowCount(int * id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutputRowCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetSolutionVolume(int *id, double * v)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		IRM_RESULT return_value = IRM_OK;
		Reaction_module_ptr->GetSolutionVolume();
		if (Reaction_module_ptr->GetMpiMyself() == 0)
		{
			if ((int) Reaction_module_ptr->GetSolutionVolume().size() == Reaction_module_ptr->GetGridCellCount())
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
double RM_GetTime(int * id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetTime();
	}
	return (double) IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
double RM_GetTimeConversion(int * id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetTimeConversion();
	}
	return (double) IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
double RM_GetTimeStep(int * id)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetTimeStep();
	}
	return (double) IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_InitialPhreeqc2Concentrations(
			int *id,
			double *boundary_c,
			int *n_boundary,
			int *dim,
			int *boundary_solution1,  
			int *boundary_solution2, 
			double *fraction1)
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes a list of solution numbers and returns a set of
 *   mass fractions
 *   Input: n_boundary - number of boundary conditions in list
 *          boundary_solution1 - list of first solution numbers to be mixed
 *          boundary_solution2 - list of second solution numbers to be mixed
 *          fraction1 - fraction of first solution 0 <= f <= 1
 *          boundary_c - n_boundary x ncomps concentrations
 *          dim - leading dimension of concentrations
 *                must be >= to n_boundary
 *
 *   Output: boundary_c - concentrations for boundary conditions
 *                      - dimensions must be >= n_boundary x n_comp
 *
 */
	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
			return Reaction_module_ptr->InitialPhreeqc2Concentrations(
						boundary_c,
						*n_boundary, 
						*dim,
						boundary_solution1,
						boundary_solution2,
						fraction1 );
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_InitialPhreeqc2Module(int *id,
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
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
RM_LoadDatabase(int * id, const char *db_name, size_t l)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		std::string db = PhreeqcRM::Char2TrimString(db_name, l);
		return Reaction_module_ptr->LoadDatabase(db.c_str());
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_LogMessage(int *id, const char *err_str, size_t l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		std::string e_string(err_str, (int) l);
		trim_right(e_string);
		e_string.append("\n");
		Reaction_module_ptr->LogMessage(e_string);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_OpenFiles(int *id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		// Files opened by root
		if (Reaction_module_ptr->GetMpiMyself() == 0)
		{
			// error_file is stderr
			return Reaction_module_ptr->OpenFiles();
		}
	}
	return IRM_BADINSTANCE;
}
/* 
--------------------------------------------------------------------- */
IRM_RESULT
RM_OutputMessage(int *id, const char *str, size_t l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		std::string e_string(str, (int) l);
		trim_right(e_string);
		e_string.append("\n");
		Reaction_module_ptr->WarningMessage(e_string);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;

}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_RunCells(int *id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		if (!Reaction_module_ptr->GetStopMessage())
		{
			// Run chemistry calculations
			return Reaction_module_ptr->RunCells(); 
		}
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_RunFile(int *id, int *workers, int *initial_phreeqc, int *utility, const char *chem_name, size_t l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		std::vector <int> args;
		args.resize(3,0);
		args[0] = (workers == NULL) ? 0 : *workers;
		args[1] = (initial_phreeqc == NULL) ? 0 : *initial_phreeqc;
		args[2] = (utility == NULL) ? 0 : *utility;
		std::string str = PhreeqcRM::Char2TrimString(chem_name, l);
		return Reaction_module_ptr->RunFile(args[0], args[1], args[2], str.c_str());
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_RunString(int *id, int *workers, int *initial_phreeqc, int *utility, const char *input_string, size_t l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{	
		std::vector <int> args;
		args.resize(3,0);
		args[0] = (workers == NULL) ? 0 : *workers;
		args[1] = (initial_phreeqc == NULL) ? 0 : *initial_phreeqc;
		args[2] = (utility == NULL) ? 0 : *utility;
		std::string str = PhreeqcRM::Char2TrimString(input_string, l);
		return Reaction_module_ptr->RunString(args[0], args[1], args[2], input_string);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_ScreenMessage(int *id, const char *err_str, size_t l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		std::string e_string(err_str, (int) l);
		trim_right(e_string);
		Reaction_module_ptr->ScreenMessage(e_string);
		Reaction_module_ptr->ScreenMessage("\n");
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetCellVolume(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetCellVolume(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetConcentrations(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetConcentrations(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetCurrentSelectedOutputUserNumber(int * id, int * i)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetCurrentSelectedOutputUserNumber(*i);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetDensity(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetDensity(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetFilePrefix(int *id, const char *name, size_t nchar)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		std::string str = PhreeqcRM::Char2TrimString(name, nchar);
		return Reaction_module_ptr->SetFilePrefix(str.c_str());
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetPartitionUZSolids(int *id, int *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		int tf = (t == NULL) ? 0 : 1;
		return Reaction_module_ptr->SetPartitionUZSolids(tf);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetPoreVolume(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetPoreVolume(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetPoreVolumeZero(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetPoreVolumeZero(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetPressure(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetPressure(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetPrintChemistryOn(int *id,	 int *worker, int *ip, int *utility)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		bool tf_w = (worker == NULL) ? false : (*worker != 0);
		bool tf_ip = (ip == NULL) ? false : (*ip != 0);
		bool tf_utility = (utility == NULL) ? false : (*utility != 0);
		return Reaction_module_ptr->SetPrintChemistryOn(tf_w, tf_ip, tf_utility);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetPrintChemistryMask(int *id, int *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetPrintChemistryMask(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetRebalanceFraction(int *id, double *f)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		double d = (f == NULL) ? 0.0 : *f;
		return Reaction_module_ptr->SetRebalanceFraction(d);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetRebalanceByCell(int *id, int *method)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		bool m = (method == NULL) ? false : (*method != 0);
		return Reaction_module_ptr->SetRebalanceByCell(m);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetSaturation(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetSaturation(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetSelectedOutputOn(int *id, int *selected_output_on)
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		bool so = (selected_output_on == NULL) ? false : (*selected_output_on != 0);
		return Reaction_module_ptr->SetSelectedOutputOn(so);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetStopMessage(int *id, int *stop_flag)
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		bool s = (stop_flag == NULL) ? true : (*stop_flag != 0);
		return Reaction_module_ptr->SetStopMessage(s);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetErrorHandlerMode(int *id, int *mode)
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		int m = mode ? *mode : 0;
		return Reaction_module_ptr->SetErrorHandlerMode(m);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetTemperature(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetTemperature(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetTime(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		double d = (t == NULL) ? 0.0 : *t;
		return Reaction_module_ptr->SetTime(d);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetTimeConversion(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		double d = (t == NULL) ? 1.0 : *t;
		return Reaction_module_ptr->SetTimeConversion(d);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetTimeStep(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		double d = (t == NULL) ? 0.0 : *t;
		return Reaction_module_ptr->SetTimeStep(d);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsExchange (int *id, int *u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		int t = (u == NULL) ? 1 : *u;
		return Reaction_module_ptr->SetUnitsExchange(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsGasPhase (int *id, int *u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		int t = (u == NULL) ? 1 : *u;
		return Reaction_module_ptr->SetUnitsGasPhase(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsKinetics (int *id, int *u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		int t = (u == NULL) ? 1 : *u;
		return Reaction_module_ptr->SetUnitsKinetics(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsPPassemblage (int *id, int *u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		int t = (u == NULL) ? 1 : *u;
		return Reaction_module_ptr->SetUnitsPPassemblage(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsSolution (int *id, int *u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		int t = (u == NULL) ? 1 : *u;
		return Reaction_module_ptr->SetUnitsSolution(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsSSassemblage (int *id, int *u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		int t = (u == NULL) ? 1 : *u;
		return Reaction_module_ptr->SetUnitsSSassemblage(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetUnitsSurface (int *id, int *u)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		int t = (u == NULL) ? 1 : *u;
		return Reaction_module_ptr->SetUnitsSurface(t);
	}
	return IRM_BADINSTANCE;
}
/* 
--------------------------------------------------------------------- */
IRM_RESULT
RM_WarningMessage(int *id, const char *err_str, size_t l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		std::string e_string(err_str, (int) l);
		trim_right(e_string);
		e_string.append("\n");
		Reaction_module_ptr->WarningMessage(e_string);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;

}
/* ---------------------------------------------------------------------- */
void RM_write_bc_raw(
			int *id,
			int *solution_list, 
			int * bc_solution_count, 
			int * solution_number, 
			char *prefix, 
			size_t prefix_l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(*id);
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
