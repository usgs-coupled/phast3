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


//class RM_interface
//{
//public:
	//static int CreateReactionModule(int *nxyz, int *nthreads = NULL);
	//static IRM_RESULT DestroyReactionModule(int *n);
	//static PhreeqcRM* GetInstance(int *n);
	//static void CleanupReactionModuleInstances(void);
//	static PHRQ_io phast_io;
//
//private:
//	friend class PhreeqcRM;
//	static std::map<size_t, PhreeqcRM*> Instances;
//	static size_t InstancesIndex;
//};

//std::map<size_t, PhreeqcRM*> RM_interface::Instances;
//size_t RM_interface::InstancesIndex = 0;
//PHRQ_io RM_interface::phast_io;



/* ---------------------------------------------------------------------- */
void
RM_calculate_well_ph(int *id, double *c, double * ph, double * alkalinity)
/* ---------------------------------------------------------------------- */
{
/*
 *  Converts data in c from mass fraction to molal
 *  Assumes c(dim, ncomps) and only first n rows are converted
 */
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM::GetRmIo().log_close();

	// output_file is prefix.chem.txt
	PhreeqcRM::GetRmIo().output_close();
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Convert_to_molal(c, *n, *dim);
	}
}

/* ---------------------------------------------------------------------- */
int RM_Create(int *nxyz, int *nthreads)
/* ---------------------------------------------------------------------- */
{
	return PhreeqcRM::CreateReactionModule(nxyz, nthreads);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	return PhreeqcRM::DestroyReactionModule(id);
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_DumpModule(int *id, int *dump_on, int *use_gz)
/* ---------------------------------------------------------------------- */
{	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->DumpModule(dump_on, use_gz);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
void RM_Error(const char * str, long l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM::ErrorStop(str, l);
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
			PhreeqcRM::GetRmIo().output_msg(estr.str().c_str());
			PhreeqcRM::GetRmIo().error_msg(estr.str().c_str());
			PhreeqcRM::GetRmIo().log_msg(estr.str().c_str());
		}
		else
		{
			std::string e_string(err_str);
			trim_right(e_string);
			std::ostringstream estr;
			estr << "ERROR: " << e_string << std::endl;
			PhreeqcRM::GetRmIo().output_msg(estr.str().c_str());
			PhreeqcRM::GetRmIo().error_msg(estr.str().c_str());
			PhreeqcRM::GetRmIo().log_msg(estr.str().c_str());
		} 
	}
}

/* ---------------------------------------------------------------------- */
int
RM_FindComponents(int *id)
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
int RM_GetChemistryCellCount(int * id)
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
IRM_RESULT RM_GetComponent(int * id, int * num, char *chem_name, int l1)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
void
RM_GetConcentrations(int *id, double * c)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->GetConcentrations(c);
	}
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_GetDensity(int *id, double * d)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		memcpy(d, Reaction_module_ptr->GetDensity().data(), (size_t) (Reaction_module_ptr->GetGridCellCount()*sizeof(double)));
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_GetFilePrefix(int * id, char *prefix, long l)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->GetGridCellCount();
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_GetMpiMyself(int * id)
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
RM_GetMpiTasks(int * id)
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
RM_GetNthSelectedOutputUserNumber(int * id, int * i)
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
IRM_RESULT RM_GetSelectedOutput(int * id, double * so)
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
RM_GetSelectedOutputColumnCount(int * id)
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
int RM_GetSelectedOutputCount(int * id)
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
IRM_RESULT RM_GetSelectedOutputHeading(int * id, int *icol, char *heading, int length)
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
int RM_GetSelectedOutputRowCount(int * id)
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
double RM_GetTime(int * id)
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
double RM_GetTimeConversion(int * id)
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
double RM_GetTimeStep(int * id)
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
	
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
			PhreeqcRM::GetRmIo().log_msg(e_string.c_str());
			PhreeqcRM::GetRmIo().log_msg("\n");
		}
		else
		{
			std::string e_string(err_str);
			trim_right(e_string);
			PhreeqcRM::GetRmIo().log_msg(e_string.c_str());
			PhreeqcRM::GetRmIo().log_msg("\n");
		}
	}
}

/* ---------------------------------------------------------------------- */
int 
RM_LoadDatabase(int * id, const char *db_name, long l)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::string db = PhreeqcRM::Char2TrimString(db_name, l);
		return Reaction_module_ptr->LoadDatabase(db.c_str());
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
RM_open_error_file(void)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM::GetRmIo().Set_error_ostream(&std::cerr);
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_OpenFiles(int *id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		
		IRM_RESULT rtn = IRM_OK;

		// Files opened by root
		if (Reaction_module_ptr->GetMpiMyself() == 0)
		{
			// error_file is stderr
			PhreeqcRM::GetRmIo().Set_error_ostream(&std::cerr);

			// open echo and log file, prefix.log.txt
			std::string ln = Reaction_module_ptr->GetFilePrefix();
			ln.append(".log.txt");
			if (!PhreeqcRM::GetRmIo().log_open(ln.c_str()))
				rtn = IRM_FAIL;

			// prefix.chem.txt
			std::string cn = Reaction_module_ptr->GetFilePrefix();
			cn.append(".chem.txt");
			if(PhreeqcRM::GetRmIo().output_open(cn.c_str()))
				rtn = IRM_FAIL;
		}
		return rtn;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_RunCells(int *id)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		if (!Reaction_module_ptr->GetStopMessage())
		{
			// Run chemistry calculations
			return Reaction_module_ptr->RunCells(); 
		}
	}
	return IRM_BADINSTANCE;
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
void RM_RunCells(int *id,
			 double *time,					        // time from transport 
			 double *time_step,		   		        // time step from transport
 			 double *concentration,					// mass fractions nxyz:components
			 int * stop_msg)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetStopMessage(*stop_msg != 0);
		if (!Reaction_module_ptr->GetStopMessage())
		{
			// Transfer data and pointers to PhreeqcRM	  
			Reaction_module_ptr->SetTime(time);
			Reaction_module_ptr->SetTimeStep(time_step);
			Reaction_module_ptr->SetConcentrations(concentration);

			// Run chemistry calculations
			Reaction_module_ptr->RunCells(); 

			// Transfer data reaction module to Fortran
			Reaction_module_ptr->GetConcentrations(concentration);
		}
	}
}
#endif
/* ---------------------------------------------------------------------- */
int 
RM_RunFile(int *id, int *initial_phreeqc, int *workers, int *utility, const char *chem_name, long l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::string str = PhreeqcRM::Char2TrimString(chem_name, l);
		return Reaction_module_ptr->RunFile(initial_phreeqc, workers, utility, str.c_str());
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
int 
RM_RunString(int *id, int *initial_phreeqc, int *workers, int *utility, const char *input_string, long l)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		std::string str = PhreeqcRM::Char2TrimString(input_string, l);
		return Reaction_module_ptr->RunString(initial_phreeqc, workers, utility, input_string);
	}
	return IRM_BADINSTANCE;
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
			PhreeqcRM::GetRmIo().screen_msg(e_string.c_str());
			PhreeqcRM::GetRmIo().screen_msg("\n");
		}
		else
		{	
			std::string e_string(err_str);
			trim_right(e_string);
			PhreeqcRM::GetRmIo().screen_msg(e_string.c_str());
			PhreeqcRM::GetRmIo().screen_msg("\n");
		}
	}
}

/* ---------------------------------------------------------------------- */
IRM_RESULT 
RM_SetCellVolume(int *id, double *t)
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
RM_SetConcentrations(int *id, double *t)
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
int RM_SetCurrentSelectedOutputUserNumber(int * id, int * i)
	/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetDensity(t);
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetFilePrefix(int *id, const char *name, long nchar)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		return Reaction_module_ptr->SetPressure(t);
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetPrintChemistryOn(int *id,	 int *print_chem)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		bool tf = (print_chem == NULL) ? false : (*print_chem != 0);
		return Reaction_module_ptr->SetPrintChemistryOn(tf);
	}
	return IRM_BADINSTANCE;

}
/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetPrintChemistryMask(int *id, int *t)
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
IRM_RESULT RM_SetRebalanceFraction(int *id, double *f)
/* ---------------------------------------------------------------------- */
{
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		bool so = (selected_output_on == NULL) ? false : (*selected_output_on != 0);
		Reaction_module_ptr->SetSelectedOutputOn(so);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
RM_SetStopMessage(int *id, int *stop_flag)
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->SetStopMessage(stop_flag == 0);
		return IRM_OK;
	}
	return IRM_BADINSTANCE;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT RM_SetTemperature(int *id, double *t)
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
RM_SetTime(int *id, double *t)
/* ---------------------------------------------------------------------- */
{
	//
	// multiply seconds to convert to user time units
	//
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
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
	PhreeqcRM * Reaction_module_ptr = PhreeqcRM::GetInstance(id);
	if (Reaction_module_ptr)
	{
		int t = (u == NULL) ? 1 : *u;
		return Reaction_module_ptr->SetUnitsSurface(t);
	}
	return IRM_BADINSTANCE;
}

/* 
--------------------------------------------------------------------- */
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
			PhreeqcRM::GetRmIo().error_msg(estr.str().c_str());
			PhreeqcRM::GetRmIo().log_msg(estr.str().c_str());
		}
		else
		{
			std::string e_string(err_str);
			trim_right(e_string);
			std::ostringstream estr;
			estr << "WARNING: " << e_string << std::endl;
			PhreeqcRM::GetRmIo().error_msg(estr.str().c_str());
			PhreeqcRM::GetRmIo().log_msg(estr.str().c_str());
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

/* ---------------------------------------------------------------------- */
void RM_write_output(int *id)
/* ---------------------------------------------------------------------- */
{
	if (GetOutputStringOn(*id))
	{
		PhreeqcRM::GetRmIo().output_msg(GetOutputString(*id));
	}
	PhreeqcRM::GetRmIo().output_msg(GetWarningString(*id));
	PhreeqcRM::GetRmIo().output_msg(GetErrorString(*id));
	PhreeqcRM::GetRmIo().screen_msg(GetWarningString(*id));
	PhreeqcRM::GetRmIo().screen_msg(GetErrorString(*id));
	if (GetSelectedOutputStringOn(*id))
	{
		PhreeqcRM::GetRmIo().punch_msg(GetSelectedOutputString(*id));
	}
}
