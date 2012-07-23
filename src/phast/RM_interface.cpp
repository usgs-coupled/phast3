#include "Reaction_module.h"
#include "RM_interface.h"
#include "IPhreeqcPhastLib.h"
#include "PHRQ_io.h"
#include <string>
#include <map>

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
RM_interface::Create_reaction_module()
/* ---------------------------------------------------------------------- */
{
	int n = IPQ_OUTOFMEMORY;
	try
	{
		Reaction_module* Reaction_module_ptr = new Reaction_module();
		if (Reaction_module_ptr)
		{
			//std::map<size_t, Reaction_module*>::value_type instance(RM_interface::InstancesIndex, Reaction_module_ptr);
			n = Reaction_module_ptr->Get_phast_iphreeqc_worker()->Get_Index();
			RM_interface::Instances[Reaction_module_ptr->Get_phast_iphreeqc_worker()->Get_Index()] = Reaction_module_ptr;
			//std::pair<std::map<size_t, Reaction_module*>::iterator, bool> pr = RM_interface::Instances.insert(instance);
			//if (pr.second)
			//{
			//	n = (int) (*pr.first).first;
			//	++RM_interface::InstancesIndex;
			//}
		}
	}
	catch(...)
	{
		return IPQ_OUTOFMEMORY;
	}
	return n;
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
			retval = IPQ_OK;
		}
	}
	return retval;
}
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

// end static RM_interface methods



/* ---------------------------------------------------------------------- */
void
errprt_c(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	std::string e_string(err_str, l);
	trim_right(e_string);
	errprt(e_string);
}
/* ---------------------------------------------------------------------- */
void
errprt(const std::string & e_string)
/* ---------------------------------------------------------------------- */
{
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
	std::string e_string(err_str, l);
	trim_right(e_string);
	warnprt(e_string);
}
/* ---------------------------------------------------------------------- */
void
warnprt(const std::string & e_string)
/* ---------------------------------------------------------------------- */
{
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
	std::string e_string(err_str, l);
	trim_right(e_string);
	logprt(e_string);
}
/* ---------------------------------------------------------------------- */
void
logprt(const std::string & e_string)
/* ---------------------------------------------------------------------- */
{
	RM_interface::phast_io.log_msg(e_string.c_str());
	RM_interface::phast_io.log_msg("\n");
}

/* ---------------------------------------------------------------------- */
void
screenprt_c(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	std::string e_string(err_str, l);
	trim_right(e_string);
	screenprt(e_string);
}
/* ---------------------------------------------------------------------- */
void
screenprt(const std::string & e_string)
/* ---------------------------------------------------------------------- */
{
	RM_interface::phast_io.screen_msg(e_string.c_str());
	RM_interface::phast_io.screen_msg("\n");
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
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Convert_to_molal(c, *n, *dim);
	}
}
/* ---------------------------------------------------------------------- */
int RM_create()
/* ---------------------------------------------------------------------- */
{
	return RM_interface::Create_reaction_module();
}

/* ---------------------------------------------------------------------- */
int RM_destroy(int *id)
/* ---------------------------------------------------------------------- */
{
	return RM_interface::Destroy_reaction_module(*id);
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
void RM_error(int *id)
/* ---------------------------------------------------------------------- */
{
	std::string e_string;
	if (id < 0)
	{
		e_string = "IPhreeqc module not created.";
	}
	else
	{
		e_string = GetErrorString(*id);
	}
	errprt(e_string);
	errprt("Stopping because of errors.");
	RM_interface::CleanupReactionModuleInstances();
	IPhreeqcPhastLib::CleanupIPhreeqcPhast();
	//IPhreeqcLib::CleanupIPhreeqcInstances();
	exit(1);
}
void RM_forward_and_back(int *id,
		int *initial_conditions, 
		int *axes)
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Forward_and_back(initial_conditions, axes);
	}
}
/* ---------------------------------------------------------------------- */
void
RM_log_screen_prt(char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
// writes to log file and screen
	std::string e_string(err_str, l);
	trim_right(e_string);
	logprt(e_string);
	screenprt(e_string);
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
RM_open_files(int * solute, char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	// error_file is stderr
	RM_open_error_file();
	
	// open echo and log file, prefix.log.txt
	RM_open_log_file(prefix, l_prefix);


	if (*solute != 0)
	{
		// output_file is prefix.chem.txt
		RM_open_output_file(prefix, l_prefix);

		// punch_file is prefix.chem.txt
		RM_open_punch_file(prefix, l_prefix);
	}
}
/* ---------------------------------------------------------------------- */
void
RM_open_log_file(char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	std::string fn(prefix, l_prefix);
	trim(fn);
	fn.append(".log.txt");
	RM_interface::phast_io.log_open(fn.c_str());
}
/* ---------------------------------------------------------------------- */
void
RM_open_output_file(char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	std::string fn(prefix, l_prefix);
	trim(fn);
	fn.append(".chem.txt");
	RM_interface::phast_io.output_open(fn.c_str());
}
/* ---------------------------------------------------------------------- */
void
RM_open_punch_file(char * prefix, int l_prefix)
/* ---------------------------------------------------------------------- */
{
	std::string fn(prefix, l_prefix);
	trim(fn);
	fn.append(".chem.xyz.tsv");
	RM_interface::phast_io.punch_open(fn.c_str());
}
/* ---------------------------------------------------------------------- */
void
RM_pass_data(int *id,
			 bool *free_surface_f,				// free surface calculation
			 bool *steady_flow_f,				// free surface calculation
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
			 double *rebalance_fraction_hst  	// parameter for rebalancing process load for parallel	
			 )
/* ---------------------------------------------------------------------- */
{
	// pass data from Fortran to the Reaction module
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_free_surface(*free_surface_f != 0);
		Reaction_module_ptr->Set_steady_flow(*steady_flow_f != 0);
		Reaction_module_ptr->Set_transient_free_surface((*free_surface_f != 0) && (steady_flow_f == 0));
		Reaction_module_ptr->Set_nx(*nx);
		Reaction_module_ptr->Set_ny(*ny);
		Reaction_module_ptr->Set_nz(*nz);
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
		//std::string sprefix(prefix, l_prefix);
		//sprefix = trim(sprefix);
		//Reaction_module_ptr->Set_file_prefix(sprefix);
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
RM_send_restart_name(int *id, char *name, long nchar)
/* ---------------------------------------------------------------------- */
{
	std::string stdstring(name, nchar);
	trim(stdstring);
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	Reaction_module_ptr->Send_restart_name(stdstring);

}
void RM_write_output(int *id)
{
	RM_interface::phast_io.output_msg(GetOutputString(*id));
	RM_interface::phast_io.error_msg(GetWarningString(*id));
	RM_interface::phast_io.error_msg(GetErrorString(*id));
	RM_interface::phast_io.punch_msg(GetSelectedOutputString(*id));
}