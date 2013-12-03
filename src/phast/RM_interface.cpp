#include "Reaction_module.h"
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
std::map<size_t, Reaction_module*> RM_interface::Instances;
size_t RM_interface::InstancesIndex = 0;
PHRQ_io RM_interface::phast_io;

//// static RM_interface methods
/* ---------------------------------------------------------------------- */
void RM_interface::CleanupReactionModuleInstances(void)
/* ---------------------------------------------------------------------- */
{
	std::map<size_t, Reaction_module*>::iterator it = RM_interface::Instances.begin();
	std::vector<Reaction_module*> rm_list;
	for ( ; it != RM_interface::Instances.end(); it++)
	{
		rm_list.push_back(it->second);
	}
	for (size_t i = 0; i < rm_list.size(); i++)
	{
		delete rm_list[i];
	}
}
/* ---------------------------------------------------------------------- */
int
RM_interface::CreateReactionModule(int *nxyz, int *nthreads)
/* ---------------------------------------------------------------------- */
{
	int n = IRM_OUTOFMEMORY;
	try
	{
		Reaction_module * Reaction_module_ptr = new Reaction_module(nxyz, nthreads);
		if (Reaction_module_ptr)
		{
			n = (int) Reaction_module_ptr->GetWorkers()[0]->Get_Index();
			RM_interface::Instances[n] = Reaction_module_ptr;
			return n;
		}
	}
	catch(...)
	{
		return IRM_OUTOFMEMORY;
	}
	return IRM_OUTOFMEMORY; 
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_interface::DestroyReactionModule(int *id)
/* ---------------------------------------------------------------------- */
{
	IRM_RESULT retval = IRM_BADINSTANCE;
	if (id)
	{
		std::map<size_t, Reaction_module*>::iterator it = RM_interface::Instances.find(size_t(*id));
		if (it != RM_interface::Instances.end())
		{
			delete (*it).second;
			retval = IRM_OK;
		}
	}
	return retval;
}
/* ---------------------------------------------------------------------- */
Reaction_module*
RM_interface::GetInstance(int *id)
/* ---------------------------------------------------------------------- */
{
	if (id != NULL)
	{
		std::map<size_t, Reaction_module*>::iterator it = RM_interface::Instances.find(size_t(*id));
		if (it != RM_interface::Instances.end())
		{
			return (*it).second;
		}
	}
	return 0;
}
/*
//
// end static RM_interface methods
//
*/

/* ---------------------------------------------------------------------- */
void
RM_calculate_well_ph(int *id, double *c, double * ph, double * alkalinity)
/* ---------------------------------------------------------------------- */
{
/*
 *  Converts data in c from mass fraction to molal
 *  Assumes c(dim, ncomps) and only first n rows are converted
 */
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Calculate_well_ph(c, ph, alkalinity);
	}
}
/* ---------------------------------------------------------------------- */
void
RM_CloseFiles(void)
/* ---------------------------------------------------------------------- */
{
	// error_file is stderr
	
	// open echo and log file, prefix.log.txt
	RM_interface::phast_io.log_close();

	// output_file is prefix.chem.txt
	RM_interface::phast_io.output_close();
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Convert_to_molal(c, *n, *dim);
	}
}

/* ---------------------------------------------------------------------- */
int RM_Create(int *nxyz, int *nthreads)
/* ---------------------------------------------------------------------- */
{
	return RM_interface::CreateReactionModule(nxyz, nthreads);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
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
	return RM_interface::DestroyReactionModule(id);
}


/* ---------------------------------------------------------------------- */
void RM_Error(int *id)
/* ---------------------------------------------------------------------- */
{
	std::string e_string;
	if (id != NULL)
	{
		if (id < 0)
		{
			e_string = "IPhreeqc module not created.";
		}
		else
		{
			e_string = GetErrorString(*id);
		}
	}
	RM_ErrorMessage(e_string.c_str());
	RM_ErrorMessage("Stopping because of errors in reaction module.");
	RM_interface::CleanupReactionModuleInstances();
	IPhreeqcPhastLib::CleanupIPhreeqcPhast();
	exit(4);
}

/* ---------------------------------------------------------------------- */
void
RM_ErrorMessage(const char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	if (err_str)
	{
		if (l >= 0)
		{
			std::string e_string(err_str, l);
			trim_right(e_string);
			std::ostringstream estr;
			estr << "ERROR: " << e_string << std::endl;
			RM_interface::phast_io.output_msg(estr.str().c_str());
			RM_interface::phast_io.error_msg(estr.str().c_str());
			RM_interface::phast_io.log_msg(estr.str().c_str());
		}
		else
		{
			std::string e_string(err_str);
			trim_right(e_string);
			std::ostringstream estr;
			estr << "ERROR: " << e_string << std::endl;
			RM_interface::phast_io.output_msg(estr.str().c_str());
			RM_interface::phast_io.error_msg(estr.str().c_str());
			RM_interface::phast_io.log_msg(estr.str().c_str());
		} 
	}
}

/* ---------------------------------------------------------------------- */
int
RM_FindComponents(int *id)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return (Reaction_module_ptr->FindComponents());
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetChemistryCellCount(int * rm_id)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetChemistryCellCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_GetComponent(int * rm_id, int * num, char *chem_name, int l1)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		if (chem_name != NULL)
		{
			if (l1 >= 0)
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
RM_GetFilePrefix(int * rm_id, char *prefix, long l)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		strncpy(prefix, Reaction_module_ptr->GetFilePrefix().c_str(), l);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetGridCellCount(int * rm_id)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetGridCellCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetMpiMyself(int * rm_id)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetMpiMyself();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetNthSelectedOutputUserNumber(int * rm_id, int * i)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetNthSelectedOutputUserNumber(i);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_GetSelectedOutput(int * rm_id, double * so)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutput(so);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetSelectedOutputColumnCount(int * rm_id)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutputColumnCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetSelectedOutputCount(int * rm_id)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutputCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_GetSelectedOutputHeading(int * rm_id, int *icol, char *heading, int length)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
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
int RM_GetSelectedOutputRowCount(int * rm_id)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetSelectedOutputRowCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
double RM_GetTime(int * rm_id)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetTime();
	}
	return (double) IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
double RM_GetTimeConversion(int * rm_id)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetTimeConversion();
	}
	return (double) IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
double RM_GetTimeStep(int * rm_id)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
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
	
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
			return Reaction_module_ptr->InitialPhreeqc2Concentrations(
						boundary_c,
						n_boundary, 
						dim,
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->InitialPhreeqc2Module(
			*id,
			initial_conditions1,
			initial_conditions2,
			fraction1);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int 
RM_InitialPhreeqcRunFile(int *rm_id, const char *chem_name, long l)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->InitialPhreeqcRunFile(chem_name, l);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
void
RM_LogMessage(const char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	if (err_str)
	{
		if (l >= 0)
		{
			std::string e_string(err_str, l);
			trim_right(e_string);
			RM_interface::phast_io.log_msg(e_string.c_str());
			RM_interface::phast_io.log_msg("\n");
		}
		else
		{
			std::string e_string(err_str);
			trim_right(e_string);
			RM_interface::phast_io.log_msg(e_string.c_str());
			RM_interface::phast_io.log_msg("\n");
		}
	}
}

/* ---------------------------------------------------------------------- */
int 
RM_LoadDatabase(int * rm_id, const char *db_name, long l)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->LoadDatabase(db_name, l);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
void
RM_LogScreenMessage(const char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
// writes to log file and screen
	if (err_str)
	{
		if (l >= 0)
		{
			std::string e_string(err_str, l);
			trim_right(e_string);
			RM_LogMessage(e_string.c_str());
			RM_ScreenMessage(e_string.c_str());
		}
		else
		{
			std::string e_string(err_str);
			trim_right(e_string);
			RM_LogMessage(e_string.c_str());
			RM_ScreenMessage(e_string.c_str());
		}
	}
}

/* ---------------------------------------------------------------------- */
void
RM_Module2Concentrations(int *id, double * c)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Module2Concentrations(c);
	}
}

/* ---------------------------------------------------------------------- */
void
RM_open_error_file(void)
/* ---------------------------------------------------------------------- */
{
	RM_interface::phast_io.Set_error_ostream(&std::cerr);
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_OpenFiles(int *id, const char * prefix_in, int l)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		
		IRM_RESULT rtn;
		rtn = Reaction_module_ptr->SetFilePrefix(prefix_in, l);

		// Files opened by root
		if (Reaction_module_ptr->GetMpiMyself() == 0)
		{
			// error_file is stderr
			//RM_open_error_file();
			RM_interface::phast_io.Set_error_ostream(&std::cerr);

			// open echo and log file, prefix.log.txt
			std::string ln = Reaction_module_ptr->GetFilePrefix();
			ln.append(".log.txt");
			RM_interface::phast_io.log_open(ln.c_str());

			// prefix.chem.txt
			std::string cn = Reaction_module_ptr->GetFilePrefix();
			cn.append(".chem.txt");
			RM_interface::phast_io.output_open(cn.c_str());
		}
		return rtn;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
void RM_RunCells(int *id,
			 double *time,					        // time from transport 
			 double *time_step,		   		        // time step from transport
 			 double *concentration,					// mass fractions nxyz:components
			 int * stop_msg)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetStopMessage(*stop_msg != 0);
		if (!Reaction_module_ptr->GetStopMessage())
		{
			// Transfer data and pointers to Reaction_module	  
			Reaction_module_ptr->SetTime(time);
			Reaction_module_ptr->SetTimeStep(time_step);
			Reaction_module_ptr->SetConcentration(concentration);

			// Transfer data Fortran to reaction module
			Reaction_module_ptr->Concentrations2Module();

			// Run chemistry calculations
			Reaction_module_ptr->RunCells(); 

			// Transfer data reaction module to Fortran
			Reaction_module_ptr->Module2Concentrations(concentration);

			// Rebalance load
			//Reaction_module_ptr->Rebalance_load();
		}
	}
}

/* ---------------------------------------------------------------------- */
void
RM_ScreenMessage(const char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	if (err_str)
	{
		if (l >= 0)
		{
			std::string e_string(err_str, l);
			trim_right(e_string);
			RM_interface::phast_io.screen_msg(e_string.c_str());
			RM_interface::phast_io.screen_msg("\n");
		}
		else
		{	
			std::string e_string(err_str);
			trim_right(e_string);
			RM_interface::phast_io.screen_msg(e_string.c_str());
			RM_interface::phast_io.screen_msg("\n");
		}
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetCellVolume(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetCellVolume(t);
	}
}

/* ---------------------------------------------------------------------- */
int RM_SetCurrentSelectedOutputUserNumber(int * rm_id, int * i)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetCurrentSelectedOutputUserNumber(i);
	}
	return -1;
}

/* ---------------------------------------------------------------------- */
void RM_SetDensity(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetDensity(t);
	}
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetFilePrefix(int *id, const char *name, long nchar)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetFilePrefix(name, nchar);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
void 
RM_set_free_surface(int *id, int *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_free_surface(t);
	}
}

/* ---------------------------------------------------------------------- */
void 
RM_SetInputUnits (int *id, int *sol, int *pp, int *ex, int *surf, int *gas, int *ss, int *kin)
/* ---------------------------------------------------------------------- */
{
	//
	// Sets units for reaction_module
	//
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		// WATER = 1, ROCK = 2, as is < 0
		Reaction_module_ptr->SetInputUnits(sol, pp, ex, surf, gas, ss, kin);
	}
}
/* ---------------------------------------------------------------------- */
void RM_SetPoreVolume(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetPoreVolume(t);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetPoreVolumeZero(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetPoreVolumeZero(t);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetPressure(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetPressure(t);
	}
}
/* ---------------------------------------------------------------------- */
int
RM_SetPrintChemistryOn(int *id,	 int *print_chem)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetPrintChemistryOn(print_chem);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;

}
/* ---------------------------------------------------------------------- */
void RM_SetPrintChemistryMask(int *id, int *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetPrintChemistryMask(t);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetRebalance(int *id, int *method, double *f)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetRebalanceMethod(method);
		Reaction_module_ptr->Set_rebalance_fraction(f);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetSaturation(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetSaturation(t);
	}
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetSelectedOutputOn(int *id, int *selected_output_on)
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetSelectedOutputOn(selected_output_on);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
void 
RM_set_steady_flow(int *id, int *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_steady_flow(t);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetTemperature(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetTemperature(t);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetTimeConversion(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetTimeConversion(t);
	}
}

/* ---------------------------------------------------------------------- */
void
RM_WarningMessage(const char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	if (err_str)
	{
		if (l >= 0)
		{
			std::string e_string(err_str, l);
			trim_right(e_string);
			std::ostringstream estr;
			estr << "WARNING: " << e_string << std::endl;
			RM_interface::phast_io.error_msg(estr.str().c_str());
			RM_interface::phast_io.log_msg(estr.str().c_str());
		}
		else
		{
			std::string e_string(err_str);
			trim_right(e_string);
			std::ostringstream estr;
			estr << "WARNING: " << e_string << std::endl;
			RM_interface::phast_io.error_msg(estr.str().c_str());
			RM_interface::phast_io.log_msg(estr.str().c_str());
		}
	}
}

/* ---------------------------------------------------------------------- */
void RM_write_bc_raw(
			int *id,
			int *solution_list, 
			int * bc_solution_count, 
			int * solution_number, 
			char *prefix, 
			int prefix_l)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
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

/* ---------------------------------------------------------------------- */
void RM_write_output(int *id)
/* ---------------------------------------------------------------------- */
{
	if (GetOutputStringOn(*id))
	{
		RM_interface::phast_io.output_msg(GetOutputString(*id));
	}
	RM_interface::phast_io.output_msg(GetWarningString(*id));
	RM_interface::phast_io.output_msg(GetErrorString(*id));
	RM_interface::phast_io.screen_msg(GetWarningString(*id));
	RM_interface::phast_io.screen_msg(GetErrorString(*id));
	if (GetSelectedOutputStringOn(*id))
	{
		RM_interface::phast_io.punch_msg(GetSelectedOutputString(*id));
	}
}

/* ---------------------------------------------------------------------- */
void RM_write_restart(int *id)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Write_restart();
	}
}

