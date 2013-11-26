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
			n = (int) Reaction_module_ptr->Get_workers()[0]->Get_Index();
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
RM_interface::GetInstance(int id)
/* ---------------------------------------------------------------------- */
{
	std::map<size_t, Reaction_module*>::iterator it = RM_interface::Instances.find(size_t(id));
	if (it != RM_interface::Instances.end())
	{
		return (*it).second;
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Calculate_well_ph(c, ph, alkalinity);
	}
}
/* ---------------------------------------------------------------------- */
void
RM_close_files(int *solute)
/* ---------------------------------------------------------------------- */
{
	// error_file is stderr
	
	// open echo and log file, prefix.log.txt
	RM_interface::phast_io.log_close();

	if (*solute != 0)
	{
		// output_file is prefix.chem.txt
		RM_interface::phast_io.output_close();

		// punch_file is prefix.chem.txt
		RM_interface::phast_io.punch_close();
	}
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
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
IRM_RESULT
RM_distribute_initial_conditions(int *id,
							  int *initial_conditions1)		// 7 x nxyz end-member 1
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		int nxyz = Reaction_module_ptr->GetGridCellCount();
		std::vector<int> initial_conditions2; 
		initial_conditions2.assign(nxyz, -1);
		std::vector<double> fraction1; 
		fraction1.assign(nxyz, 1.0);

		return Reaction_module_ptr->Distribute_initial_conditions_mix(
			*id,
			initial_conditions1,
			initial_conditions2.data(),
			fraction1.data());
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_distribute_initial_conditions_mix(int *id,
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->Distribute_initial_conditions_mix(
			*id,
			initial_conditions1,
			initial_conditions2,
			fraction1);
	}
	return IRM_BADINSTANCE;
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return (Reaction_module_ptr->Find_components());
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetChemistryCellCount(int * rm_id)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
	if (Reaction_module_ptr)
	{
		if (chem_name != NULL)
		{
			if (l1 >= 0)
			{
				strncpy(chem_name, Reaction_module_ptr->Get_components()[*num - 1].c_str(), l1);
			}
			else
			{
				strcpy(chem_name, Reaction_module_ptr->Get_components()[*num - 1].c_str());
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
	if (Reaction_module_ptr)
	{
		strncpy(prefix, Reaction_module_ptr->GetFilePrefix().c_str(), l);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetMpiMyself(int * rm_id)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetNthSelectedOutputUserNumber(i);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_GetGridCellCount(int * rm_id)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetGridCellCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_GetSelectedOutput(int * rm_id, double * so)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetTimeStep();
	}
	return (double) IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
int 
RM_InitialPhreeqcRun(int *rm_id, const char *chem_name, long l)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->InitialPhreeqcRun(chem_name, l);
	}
	return IRM_BADINSTANCE;
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_InitialPhreeqcRun(int *rm_id, char *db_name, char *chem_name, char *prefix, int l1, int l2, int l3)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
	if (Reaction_module_ptr)
	{
		std::string database_name(db_name, l1);
		trim_right(database_name);
		std::string chemistry_name(chem_name, l2);
		trim_right(chemistry_name);
		std::string prefix_name(prefix, l3);
		trim_right(prefix_name);
		return Reaction_module_ptr->InitialPhreeqcRun(database_name, chemistry_name, prefix_name);
	}
	return IRM_BADINSTANCE;
}
#endif
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
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
void
RM_OpenFiles(int *id, const char * prefix_in, int l)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetFilePrefix(prefix_in, l);

		// Files opened by root
		if (Reaction_module_ptr->GetMpiMyself() == 0)
		{
			// error_file is stderr
			//RM_open_error_file();
			RM_interface::phast_io.Set_error_ostream(&std::cerr);

			// open echo and log file, prefix.log.txt
			//RM_open_log_file(Reaction_module_ptr->GetFilePrefix().c_str(), l);
			std::string ln = Reaction_module_ptr->GetFilePrefix();
			ln.append(".log.txt");
			RM_interface::phast_io.log_open(ln.c_str());

			// prefix.chem.txt
			std::string cn = Reaction_module_ptr->GetFilePrefix();
			cn.append(".chem.txt");
			//RM_open_output_file(Reaction_module_ptr->GetFilePrefix().c_str(), l);
			RM_interface::phast_io.output_open(cn.c_str());
		}
	}
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
void
RM_open_log_file(const char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	std::string fn(prefix, l_prefix);
	trim(fn);
	fn.append(".log.txt");
	RM_interface::phast_io.log_open(fn.c_str());
}

/* ---------------------------------------------------------------------- */
void
RM_open_output_file(const char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	std::string fn(prefix, l_prefix);
	trim(fn);
	fn.append(".chem.txt");
	RM_interface::phast_io.output_open(fn.c_str());
}

/* ---------------------------------------------------------------------- */
void
RM_open_punch_file(const char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	std::string fn(prefix, l_prefix);
	trim(fn);
	fn.append(".chem.xyz.tsv");
	RM_interface::phast_io.punch_open(fn.c_str());
}
#endif
/* ---------------------------------------------------------------------- */
void RM_RunCells(int *id,
			 double *time,					        // time from transport 
			 double *time_step,		   		        // time step from transport
 			 double *concentration,					// mass fractions nxyz:components
			 int * stop_msg)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_stop_message(*stop_msg != 0);
		if (!Reaction_module_ptr->Get_stop_message())
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
void
RM_send_restart_name(int *id, char *name, long nchar)
/* ---------------------------------------------------------------------- */
{
	std::string stdstring(name, nchar);
	trim(stdstring);
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	Reaction_module_ptr->Send_restart_name(stdstring);

}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetFilePrefix(int *id, const char *name, long nchar)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetFilePrefix(name, nchar);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int RM_SetCurrentSelectedOutputUserNumber(int * rm_id, int * i)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*rm_id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetDensity(t);
	}
}

/* ---------------------------------------------------------------------- */
void
RM_setup_boundary_conditions(
			int *id,
			int *n_boundary, 
			int *boundary_solution1,  
			int *boundary_solution2, 
			double *fraction1,
			double *boundary_c, 
			int *dim)
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
	
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Setup_boundary_conditions(
					*n_boundary, 
					boundary_solution1,
					boundary_solution2, 
					fraction1,
					boundary_c, 
					*dim);
	}
}

/* ---------------------------------------------------------------------- */
void 
RM_set_free_surface(int *id, int *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		// WATER = 1, ROCK = 2, as is < 0
		Reaction_module_ptr->Set_input_units(sol, pp, ex, surf, gas, ss, kin);
	}
}

/* ---------------------------------------------------------------------- */
void
RM_set_nodes(int *id,
			 double *x_node,					// nxyz array of X coordinates for nodes 
			 double *y_node,					// nxyz array of Y coordinates for nodes  
			 double *z_node 					// nxyz array of Z coordinates for nodes 
			 )
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_x_node(x_node);
		Reaction_module_ptr->Set_y_node(y_node);
		Reaction_module_ptr->Set_z_node(z_node);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetPressure(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetPressure(t);
	}
}

/* ---------------------------------------------------------------------- */
void
RM_set_printing(int *id,
			 int *print_chem,
			 int *selected_output_on,
			 int *print_restart 
			 )
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_print_chem(print_chem);
		Reaction_module_ptr->SetSelectedOutputOn(selected_output_on);
		Reaction_module_ptr->Set_print_restart(print_restart);
	}
}

/* ---------------------------------------------------------------------- */
void RM_set_print_chem_mask(int *id, int *t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_print_chem_mask(t);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetPv(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetPv(t);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetPv0(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetPv0(t);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetRebalance(int *id, int *method, double *f)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
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
	//
	// multiply seconds to convert to user time units
	//
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetSaturation(t);
	}
}

/* ---------------------------------------------------------------------- */
void 
RM_set_steady_flow(int *id, int *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_steady_flow(t);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetTemperature(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetTimeConversion(t);
	}
}

/* ---------------------------------------------------------------------- */
void RM_SetVolume(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetVolume(t);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::GetInstance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Write_restart();
	}
}

