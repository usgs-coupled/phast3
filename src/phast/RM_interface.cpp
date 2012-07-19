#include "Reaction_module.h"
#include "RM_interface.h"
#include "PHRQ_io.h"
#include <string>
#include <map>

//class RM_interface
//{
//public:
//	static int Create_reaction_module(int iphreeqc_id);
//	static IPQ_RESULT Destroy_reaction_module(int n);
//	static Reaction_module* Get_instance(int n);
//	static PHRQ_io phast_io;
//
//private:
//	static std::map<size_t, Reaction_module*> Instances;
//	static size_t InstancesIndex;
//};

std::map<size_t, Reaction_module*> RM_interface::Instances;
size_t RM_interface::InstancesIndex = 0;
PHRQ_io RM_interface::phast_io;

/* ---------------------------------------------------------------------- */
Reaction_module*
RM_interface::Get_instance(int id)
/* ---------------------------------------------------------------------- */
{
	std::map<size_t, Reaction_module*>::iterator it = RM_interface::Instances.find(size_t(id));
	if (it != RM_interface::Instances.end())
	{
		return (*it).second;
	}
	return 0;
}
/* ---------------------------------------------------------------------- */
int RM_create(int iphreeqc_id)
/* ---------------------------------------------------------------------- */
{
	return RM_interface::Create_reaction_module(iphreeqc_id);
}
/* ---------------------------------------------------------------------- */
int
RM_interface::Create_reaction_module(int iphreeqc_id)
/* ---------------------------------------------------------------------- */
{
	int n = IPQ_OUTOFMEMORY;
	try
	{
		Reaction_module* Reaction_module_ptr = new Reaction_module(iphreeqc_id);
		if (Reaction_module_ptr)
		{
			std::map<size_t, Reaction_module*>::value_type instance(RM_interface::InstancesIndex, Reaction_module_ptr);
			std::pair<std::map<size_t, Reaction_module*>::iterator, bool> pr = RM_interface::Instances.insert(instance);
			if (pr.second)
			{
				n = (int) (*pr.first).first;
				++RM_interface::InstancesIndex;
			}
		}
	}
	catch(...)
	{
		return IPQ_OUTOFMEMORY;
	}
	return n;
}
/* ---------------------------------------------------------------------- */
int RM_destroy(int id)
/* ---------------------------------------------------------------------- */
{
	return RM_interface::Destroy_reaction_module(id);
}
/* ---------------------------------------------------------------------- */
IPQ_RESULT
RM_interface::Destroy_reaction_module(int id)
/* ---------------------------------------------------------------------- */
{
	IPQ_RESULT retval = IPQ_BADINSTANCE;
	if (id >= 0)
	{
		std::map<size_t, Reaction_module*>::iterator it = RM_interface::Instances.find(size_t(id));
		if (it != RM_interface::Instances.end())
		{
			delete (*it).second;
			RM_interface::Instances.erase(it);
			retval = IPQ_OK;
		}
	}
	return retval;
}

/* ---------------------------------------------------------------------- */
void
RM_load_database(int *id, char *database_name, int l)
/* ---------------------------------------------------------------------- */
/*
 *   Main program for PHREEQC
 */
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		std::string database_file_name(database_name, l);
		Reaction_module_ptr->Load_database(database_file_name);
	}

}

/* ---------------------------------------------------------------------- */
void
RM_initial_phreeqc_run(int *id, char *chemistry_name, int l)
/* ---------------------------------------------------------------------- */
/*
 *   Main program for PHREEQC
 */
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		std::string chemistry_file_name(chemistry_name, l);
		Reaction_module_ptr->Initial_phreeqc_run(chemistry_name);
	}

}
/* ---------------------------------------------------------------------- */
void
RM_pass_data(int *id,
			 int *free_surface,					// free surface calculation
			 int *steady_flow,					// free surface calculation
			 int *nx, int *ny, int *nz,			// number of nodes each coordinate direction
			 double *time_hst,					// time from transport 
			 double *time_step_hst,				// time step from transport
			 double *cnvtmi,					// conversion factor for time
			 double *x_node,					// nxyz array of X coordinates for nodes 
			 double *y_node,					// nxyz array of Y coordinates for nodes  
			 double *z_node,					// nxyz array of Z coordinates for nodes 
			 double *fraction,					// mass fractions nxyz:components
			 double *frac,						// saturation fraction
			 double *pv,						// nxyz current pore volumes 
			 double *pv0,						// nxyz initial pore volumes
			 double *volume, 					// nxyz geometric cell volumes 
			 int *printzone_chem,				// nxyz print flags for output file
			 int *printzone_xyz,				// nxyz print flags for chemistry XYZ file 
			 double *rebalance_fraction_hst,	// parameter for rebalancing process load for parallel	
			 char * prefix,                     // prefix for file names
			 int l_prefix						// length of prefix string
			 )
/* ---------------------------------------------------------------------- */
{
	// pass data from Fortran to the Reaction module
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_free_surface(*free_surface != 0);
		Reaction_module_ptr->Set_steady_flow(*steady_flow != 0);
		Reaction_module_ptr->Set_transient_free_surface((*free_surface != 0) && (steady_flow == 0));
		Reaction_module_ptr->Set_nxyz(*nx);
		Reaction_module_ptr->Set_nxyz(*ny);
		Reaction_module_ptr->Set_nxyz(*nz);
		Reaction_module_ptr->Set_nxyz((*nx) * (*ny) * (*nz));
		Reaction_module_ptr->Set_time_hst(time_hst);
		Reaction_module_ptr->Set_time_step_hst(time_step_hst);
		Reaction_module_ptr->Set_cnvtmi(cnvtmi);
		Reaction_module_ptr->Set_x_node(x_node);
		Reaction_module_ptr->Set_y_node(y_node);
		Reaction_module_ptr->Set_z_node(z_node);
		Reaction_module_ptr->Set_fraction(fraction);
		Reaction_module_ptr->Set_frac(frac);
		Reaction_module_ptr->Set_pv(pv);
		Reaction_module_ptr->Set_pv0(pv0);
		Reaction_module_ptr->Set_volume(volume);
		Reaction_module_ptr->Set_printzone_chem(printzone_chem);
		Reaction_module_ptr->Set_printzone_xyz(printzone_xyz);
		Reaction_module_ptr->Set_rebalance_fraction_hst(rebalance_fraction_hst);
		std::string sprefix(prefix, l_prefix);
		sprefix = trim(sprefix);
		Reaction_module_ptr->Set_file_prefix(sprefix);
	}
}

/* ---------------------------------------------------------------------- */
void
RM_pass_print_flags(int *id,
			 int * prslm,							// solution method print flag 
			 int * print_out,						// print flag for output file 
			 int * print_sel,						// print flag for selected output
			 int * print_hdf,						// print flag for hdf file
			 int * print_restart					// print flag for writing restart file 
			 )
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_prslm(prslm != 0);
		Reaction_module_ptr->Set_print_chem(print_out != 0);
		Reaction_module_ptr->Set_print_xyz(print_sel != 0);
		Reaction_module_ptr->Set_print_hdf(print_hdf != 0);
		Reaction_module_ptr->Set_print_restart(print_restart != 0);
	}
}
/* ---------------------------------------------------------------------- */
void
RM_distribute_initial_conditions(int *id,
							  int *initial_conditions1,		// 7 x nxyz end-member 1
							  int *initial_conditions2,		// 7 x nxyz end-member 2
							  double *fraction1,			// 7 x nxyz fraction of end-member 1
							  int *exchange_units,			// water (1) or rock (2)
							  int *surface_units,			// water (1) or rock (2)
							  int *ssassemblage_units,		// water (1) or rock (2)		
							  int *ppassemblage_units,		// water (1) or rock (2)
							  int *gasphase_units,			// water (1) or rock (2)
							  int *kinetics_units			// water (1) or rock (2)
							  )
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
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Distribute_initial_conditions(
			initial_conditions1,
			initial_conditions2,
			fraction1,
			*exchange_units,
			*surface_units,
			*ssassemblage_units,
			*ppassemblage_units,
			*gasphase_units,
			*kinetics_units);
	}
}
/* ---------------------------------------------------------------------- */
void
RM_get_components(int *id, int *n_comp, char *names, int length)
/* ---------------------------------------------------------------------- */
{
/*
 *   Counts components in any defined solution, gas_phase, exchanger,
 *   surface, or pure_phase_assemblage
 *
 *   Returns:
 *           n_comp, which is total, including H, O, elements, and Charge
 *           names, which contains character strings with names of components
 */
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Get_components(n_comp, names, length);
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
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Convert_to_molal(c, *n, *dim);
	}
}
/* ---------------------------------------------------------------------- */
void
RM_calculate_well_ph(int *id, double *c, double * ph, double * alkalinity)
/* ---------------------------------------------------------------------- */
{
/*
 *  Converts data in c from mass fraction to molal
 *  Assumes c(dim, ncomps) and only first n rows are converted
 */
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Calculate_well_ph(c, ph, alkalinity);
	}
}

/* ---------------------------------------------------------------------- */
void
C_IO_open_files(int * solute, char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	// error_file is stderr
	C_IO_open_error_file();
	
	// open echo and log file, prefix.log.txt
	C_IO_open_log_file(prefix, l_prefix);


	if (solute != 0)
	{
		// output_file is prefix.chem.txt
		C_IO_open_output_file(prefix, l_prefix);

		// punch_file is prefix.chem.txt
		C_IO_open_punch_file(prefix, l_prefix);
	}
}
/* ---------------------------------------------------------------------- */
void
C_IO_open_error_file(void)
/* ---------------------------------------------------------------------- */
{
	RM_interface::phast_io.Set_error_ostream(&std::cerr);
}
/* ---------------------------------------------------------------------- */
void
C_IO_open_output_file(char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	std::string fn(prefix, l_prefix);
	fn.append(".chem.txt");
	RM_interface::phast_io.output_open(fn.c_str());
}
/* ---------------------------------------------------------------------- */
void
C_IO_open_punch_file(char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	std::string fn(prefix, l_prefix);
	fn.append(".chem.xyz.tsv");
	RM_interface::phast_io.punch_open(fn.c_str());
}
/* ---------------------------------------------------------------------- */
void
C_IO_open_log_file(char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	std::string fn(prefix, l_prefix);
	fn.append(".log.txt");
	RM_interface::phast_io.log_open(fn.c_str());
}
/* ---------------------------------------------------------------------- */
void
errprt_c(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	C_IO_errprt(err_str, l);
}
/* ---------------------------------------------------------------------- */
void
C_IO_errprt(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	std::string e_string(err_str, l);
	trim_right(e_string);

	std::ostringstream estr;
	estr << "ERROR: " << e_string << std::endl;
	RM_interface::phast_io.error_msg(estr.str().c_str());
	RM_interface::phast_io.log_msg(estr.str().c_str());
	return;
}
/* ---------------------------------------------------------------------- */
void
warnprt_c(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	C_IO_warnprt(err_str, l);
}
/* ---------------------------------------------------------------------- */
void
C_IO_warnprt(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{

	std::string e_string(err_str, l);
	trim_right(e_string);

	std::ostringstream estr;
	estr << "WARNING: " << e_string << std::endl;
	RM_interface::phast_io.error_msg(estr.str().c_str());
	RM_interface::phast_io.log_msg(estr.str().c_str());

}

/* ---------------------------------------------------------------------- */
void
logprt_c(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	C_IO_logprt(err_str, l);
}
/* ---------------------------------------------------------------------- */
void
C_IO_logprt(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	std::string e_string(err_str, l);
	trim_right(e_string);

	std::ostringstream estr;
	estr << e_string << std::endl;
	RM_interface::phast_io.log_msg(estr.str().c_str());
}
/* ---------------------------------------------------------------------- */
void
screenprt_c(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	C_IO_screenprt(err_str, l);
}
/* ---------------------------------------------------------------------- */
void
C_IO_screenprt(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	std::string e_string(err_str, l);
	trim_right(e_string);

	std::ostringstream estr;
	estr << e_string << std::endl;
	RM_interface::phast_io.error_msg(estr.str().c_str());
}
/* ---------------------------------------------------------------------- */
void
RM_send_restart_name(int *id, char *name, long nchar)
/* ---------------------------------------------------------------------- */
{
	std::string stdstring(name, nchar);
	trim(stdstring);
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	Reaction_module_ptr->Send_restart_name(stdstring);

}