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
RM_interface::Create_reaction_module(int *nxyz, int *nthreads)
/* ---------------------------------------------------------------------- */
{
	int n = IPQ_OUTOFMEMORY;
	try
	{
		Reaction_module * Reaction_module_ptr = new Reaction_module(nxyz, nthreads);
		if (Reaction_module_ptr)
		{
			n = (int) Reaction_module_ptr->Get_workers()[0]->Get_Index();
			RM_interface::Instances[n] = Reaction_module_ptr;
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
errprt_c(const char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	std::string e_string(err_str, l);
	trim_right(e_string);
	RM_errprt(e_string);
}
/* ---------------------------------------------------------------------- */
void
RM_errprt(const std::string & e_string)
/* ---------------------------------------------------------------------- */
{
	std::ostringstream estr;
	estr << "ERROR: " << e_string << std::endl;
	RM_interface::phast_io.output_msg(estr.str().c_str());
	RM_interface::phast_io.error_msg(estr.str().c_str());
	RM_interface::phast_io.log_msg(estr.str().c_str());
	return;
}
/* ---------------------------------------------------------------------- */
void
warnprt_c(const char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	std::string e_string(err_str, l);
	trim_right(e_string);
	RM_warnprt(e_string);
}
/* ---------------------------------------------------------------------- */
void
RM_warnprt(const std::string & e_string)
/* ---------------------------------------------------------------------- */
{
	std::ostringstream estr;
	estr << "WARNING: " << e_string << std::endl;
	RM_interface::phast_io.error_msg(estr.str().c_str());
	RM_interface::phast_io.log_msg(estr.str().c_str());
}

/* ---------------------------------------------------------------------- */
void
logprt_c(const char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	std::string e_string(err_str, l);
	trim_right(e_string);
	RM_logprt(e_string);
}
/* ---------------------------------------------------------------------- */
void
RM_logprt(const std::string & e_string)
/* ---------------------------------------------------------------------- */
{
	RM_interface::phast_io.log_msg(e_string.c_str());
	RM_interface::phast_io.log_msg("\n");
}

/* ---------------------------------------------------------------------- */
void
screenprt_c(const char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	std::string e_string(err_str, l);
	trim_right(e_string);
	RM_screenprt(e_string);
}
/* ---------------------------------------------------------------------- */
void
RM_screenprt(const std::string & e_string)
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
#ifdef HDF5_CREATE
	HDF_Finalize();
#endif
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
int RM_create(int *nxyz, int *nthreads)
/* ---------------------------------------------------------------------- */
{
	return RM_interface::Create_reaction_module(nxyz, nthreads);
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
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		int nxyz = Reaction_module_ptr->Get_nxyz();
		std::vector<int> initial_conditions2; 
		initial_conditions2.assign(nxyz, -1);
		std::vector<double> fraction1; 
		fraction1.assign(nxyz, 1.0);

		Reaction_module_ptr->Distribute_initial_conditions_mix(
			*id,
			initial_conditions1,
			initial_conditions2.data(),
			fraction1.data());
	}
}
/* ---------------------------------------------------------------------- */
void
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
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Distribute_initial_conditions_mix(
			*id,
			initial_conditions1,
			initial_conditions2,
			fraction1);
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
	RM_errprt(e_string);
	RM_errprt("Stopping because of errors in reaction module.");
	RM_interface::CleanupReactionModuleInstances();
	IPhreeqcPhastLib::CleanupIPhreeqcPhast();
	exit(4);
}
#ifdef SKIP
void RM_forward_and_back(int *id,
		int *initial_conditions, 
		int *axes)
{
	//
	// Creates mapping from all grid cells to only cells for chemistry
	// Excludes inactive cells and cells that are redundant by symmetry
	// (1D or 2D chemistry)
	//
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Forward_and_back(initial_conditions, axes);
	}
}
#endif
void
RM_fractions2solutions(int *id)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Fractions2Solutions();
	}
}
int
RM_find_components(int *id)
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	return (Reaction_module_ptr->Find_components());
}
/* ---------------------------------------------------------------------- */
void RM_get_component(int * rm_id, int * num, char *chem_name, int l1)
	/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*rm_id);
	if (Reaction_module_ptr)
	{
		//strcpy(chem_name, Reaction_module_ptr->Get_components()[*num - 1].c_str());
		strncpy(chem_name, Reaction_module_ptr->Get_components()[*num - 1].c_str(), Reaction_module_ptr->Get_components()[*num - 1].size());
	}
}
/* ---------------------------------------------------------------------- */
void RM_initial_phreeqc_run(int *rm_id, char *db_name, char *chem_name, char *prefix, int l1, int l2, int l3)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*rm_id);
	if (Reaction_module_ptr)
	{
		std::string database_name(db_name, l1);
		trim_right(database_name);
		std::string chemistry_name(chem_name, l2);
		trim_right(chemistry_name);
		std::string prefix_name(prefix, l3);
		trim_right(prefix_name);
		Reaction_module_ptr->Initial_phreeqc_run(database_name, chemistry_name, prefix_name);
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
	RM_logprt(e_string);
	RM_screenprt(e_string);
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

#ifdef HDF5_CREATE
	HDF_Init(prefix, l_prefix);
#endif
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
			 double *volume, 					// nxyz geometric cell volumes 
			 int *printzone_chem,				// nxyz print flags for output file
			 int *printzone_xyz,				// nxyz print flags for chemistry XYZ file 
			 int *rebalance_method,             // method for rebalancing load
			 double *rebalance_fraction_hst, 	// parameter for rebalancing process load for parallel	
			 double *fraction                   // needed for first Solutions2Fractions
			 )
/* ---------------------------------------------------------------------- */
{
	// pass pointers from Fortran to the Reaction module
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_free_surface(*free_surface_f != 0);
		Reaction_module_ptr->Set_steady_flow(*steady_flow_f != 0);
		Reaction_module_ptr->Set_transient_free_surface((*free_surface_f != 0) && (steady_flow_f == 0));
		Reaction_module_ptr->Set_volume(volume);
		Reaction_module_ptr->Set_printzone_chem(printzone_chem);
		Reaction_module_ptr->Set_printzone_xyz(printzone_xyz);
		Reaction_module_ptr->Set_rebalance_method(*rebalance_method != 0);
		Reaction_module_ptr->Set_rebalance_fraction(*rebalance_fraction_hst);
		Reaction_module_ptr->Set_fraction(fraction);
	}
}
/* ---------------------------------------------------------------------- */
void RM_run_cells(int *id,
			 int * print_chem,						// print flag for output file 
			 int * print_xyz,						// print flag for xyz file
			 int * print_hdf,						// print flag for hdf file
			 int * print_restart,					// print flag for writing restart file 
			 double *time,					        // time from transport 
			 double *time_step,		   		        // time step from transport
 			 double *fraction,					    // mass fractions nxyz:components
			 double *frac,							// saturation fraction
			 int *nxyz,
			 int *count_comps,
			 int * stop_msg)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
#ifdef USE_MPI
		MPI_Bcast(stop_msg, 1, MPI_INT, 0, MPI_COMM_WORLD);
#endif
		if (*stop_msg == 0)
		{

#ifdef USE_MPI
			// Broadcast data to workers
			//MPI_Bcast(prslm, 1, MPI_INT, 0, MPI_COMM_WORLD);
			MPI_Bcast(print_chem, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
			MPI_Bcast(print_xyz, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
			MPI_Bcast(print_hdf, 1, MPI_INT, 0, MPI_COMM_WORLD);
			MPI_Bcast(print_restart, 1, MPI_INT, 0, MPI_COMM_WORLD);
			MPI_Bcast(fraction, (*nxyz)*(*count_comps), MPI_DOUBLE, 0, MPI_COMM_WORLD);
			MPI_Bcast(frac, *nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
			
			// Transfer data and pointers to Reaction_module	  
			Reaction_module_ptr->Set_print_chem(*print_chem != 0);
			Reaction_module_ptr->Set_print_xyz(*print_xyz != 0);
			Reaction_module_ptr->Set_print_hdf(*print_hdf != 0);
			Reaction_module_ptr->Set_print_restart(*print_restart != 0);
			Reaction_module_ptr->Set_time(*time);
			Reaction_module_ptr->Set_time_step(*time_step);
			Reaction_module_ptr->Set_fraction(fraction);
			Reaction_module_ptr->Set_frac(frac);

			// Transfer data Fortran to reaction module
			Reaction_module_ptr->Fractions2Solutions();

			// Run chemistry calculations
			Reaction_module_ptr->Run_cells(); 

			// Transfer data reaction module to Fortran
			Reaction_module_ptr->Solutions2Fractions();

			// Rebalance load
			Reaction_module_ptr->Rebalance_load();
		}
	}
}
void
RM_solutions2fractions(int *id)
/* ---------------------------------------------------------------------- */
{
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Solutions2Fractions();
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
/* ---------------------------------------------------------------------- */
void
RM_setup_boundary_conditions(
			int *id,
			int *n_boundary, 
			int *boundary_solution1,  
			int *boundary_solution2, 
			double *fraction1,
			double *boundary_fraction, 
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
 *          dim - leading dimension of array boundary mass fractions
 *                must be >= to n_boundary
 *
 *   Output: boundary_fraction - mass fractions for boundary conditions
 *                             - dimensions must be >= n_boundary x n_comp
 *
 */
	
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Setup_boundary_conditions(
					*n_boundary, 
					boundary_solution1,
					boundary_solution2, 
					fraction1,
					boundary_fraction, 
					*dim);
	}
}
void 
RM_set_input_units (int *id, int *sol, int *pp, int *ex, int *surf, int *gas, int *ss, int *kin)
{
	//
	// Sets units for reaction_module
	//
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_x_node(x_node);
		Reaction_module_ptr->Set_y_node(y_node);
		Reaction_module_ptr->Set_z_node(z_node);
	}
}
void RM_set_mapping(int *id,
		int *grid2chem)
{
	//
	// Creates mapping from all grid cells to only cells for chemistry
	// Excludes inactive cells and cells that are redundant by symmetry
	// (1D or 2D chemistry)
	//
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_mapping(grid2chem);
	}
}
void RM_set_pv(int *id, double *t)
{
	//
	// multiply seconds to convert to user time units
	//
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_pv(t);
	}
}
void RM_set_pv0(int *id, double *t)
{
	//
	// multiply seconds to convert to user time units
	//
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_pv0(t);
	}
}
void RM_set_time_conversion(int *id, double *t)
{
	//
	// multiply seconds to convert to user time units
	//
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Set_time_conversion(*t);
	}
}
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
void
RM_transport(int *id, int *ncomps)
/* ---------------------------------------------------------------------- */
{
	// Used for MPI transport calculations
	for (int i = 1; i <= *ncomps; i++)
	{
		transport_component_thread(&i);
	}
}
#else
/* ---------------------------------------------------------------------- */
void
RM_transport(int *id, int *ncomps)
/* ---------------------------------------------------------------------- */
{
	// Used for threaded transport calculations

#ifdef THREADED_PHAST
	int n = 1;
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr) {
		n = Reaction_module_ptr->Get_nthreads();
	}
	omp_set_num_threads(n);
	#pragma omp parallel 
	#pragma omp for
	for (int i = 1; i <= *ncomps; i++)
	{
		transport_component_thread(&i);
	}
#else
	for (int i = 1; i <= *ncomps; i++)
	{
		transport_component(&i);
	}
#endif
}
#endif
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
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
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
	Reaction_module * Reaction_module_ptr = RM_interface::Get_instance(*id);
	if (Reaction_module_ptr)
	{
		Reaction_module_ptr->Write_restart();
	}
}
/* ---------------------------------------------------------------------- */
void RM_zone_flow_write_chem(int *print_zone_flows_xyzt)
/* ---------------------------------------------------------------------- */
{
#ifdef USE_MPI
	MPI_Bcast(print_zone_flows_xyzt, 1, MPI_INTEGER, 0, MPI_COMM_WORLD);
#endif
	if (print_zone_flows_xyzt != 0)
	{
		zone_flow_write_chem();
	}
}
