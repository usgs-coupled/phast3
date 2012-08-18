/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#ifndef RM_INTERFACE_H
#define RM_INTERFACE_H
#include "IPhreeqc.h"
#include "Var.h"
#define RM_calculate_well_ph                  rm_calculate_well_ph
#define RM_close_files                        rm_close_files
#define RM_convert_to_molal                   rm_convert_to_molal
#define RM_create                             rm_create
#define RM_destroy                            rm_destroy
#define RM_create_phreeqc_bin                 rm_create_phreeqc_bin 
#define RM_distribute_initial_conditions      rm_distribute_initial_conditions
#define RM_error                              rm_error
#define RM_find_components                    rm_find_components
#define RM_forward_and_back                   rm_forward_and_back
#define RM_fractions2solutions                rm_fractions2solutions
#define RM_get_component                      rm_get_component
#define RM_initial_phreeqc_run                rm_initial_phreeqc_run
#define RM_load_database                      rm_load_database
#define RM_log_screen_prt                     rm_log_screen_prt
#define RM_open_files                         rm_open_files
#define RM_pass_data                          rm_pass_data
#define RM_pass_transient_data                rm_pass_transient_data
#define RM_run_cells                          rm_run_cells
#define RM_send_restart_name                  rm_send_restart_name
#define RM_setup_boundary_conditions          rm_setup_boundary_conditions
#define RM_solutions2fractions                rm_solutions2fractions
#define RM_transport                          rm_transport
#define RM_write_bc_raw                       rm_write_bc_raw
#define RM_write_output                       rm_write_output
#define RM_write_restart		      rm_write_restart


/**
 * @mainpage IPhreeqc Library Documentation
 *
 *  @htmlonly
 *  <table>
 *   <tr><td class="indexkey"><a class="el" href="IPhreeqc_8h.html">IPhreeqc.h</a> </td><td class="indexvalue">C/Fortran Documentation </td></tr>
 *   <tr><td class="indexkey"><a class="el" href="IPhreeqc_8hpp.html">IPhreeqc.hpp</a> </td><td class="indexvalue">C++ Documentation </td></tr>
 *   <tr><td class="indexkey"><a class="el" href="Var_8h.html">Var.h</a></td><td class="indexvalue">IPhreeqc VARIANT Documentation </td></tr>
 *  </table>
 *  @endhtmlonly
 */

/*! \brief Enumeration used to return error codes.
*/

class RM_interface
{
public:
	static int Create_reaction_module();
	static IPQ_RESULT Destroy_reaction_module(int n);
	static Reaction_module* Get_instance(int n);
	static void CleanupReactionModuleInstances(void);
	static PHRQ_io phast_io;

private:
	friend class Reaction_module;
	static std::map<size_t, Reaction_module*> Instances;
	static size_t InstancesIndex;
};

#if defined(__cplusplus)
extern "C" {
#endif
void RM_calculate_well_ph(int *id, double *c, double * ph, double * alkalinity);
void RM_cleanup();
void RM_close_files(int * solute);
void RM_convert_to_molal(int *id, double *c, int *n, int *dim);
int  RM_create();
void RM_create_phreeqc_bin(int *rm_id);
int  RM_destroy(int *id);
void RM_distribute_initial_conditions(int *id,
		int *initial_conditions1,		// 7 x nxyz end-member 1
		int *initial_conditions2,		// 7 x nxyz end-member 2
		double *fraction1,			    // 7 x nxyz fraction of end-member 1
		int *exchange_units,			// water (1) or rock (2)
		int *surface_units,			    // water (1) or rock (2)
		int *ssassemblage_units,		// water (1) or rock (2)		
		int *ppassemblage_units,		// water (1) or rock (2)
		int *gasphase_units,			// water (1) or rock (2)
		int *kinetics_units			    // water (1) or rock (2)
		);
void RM_error(int *id);
int RM_find_components(int *id);
void RM_forward_and_back(int *id,
		int *initial_conditions, 
		int *axes);
void RM_fractions2solutons(int *id);
void RM_get_component(int * id, int * num, char *chem_name, int l1);
void RM_initial_phreeqc_run(int * id, char *db_name, char *chem_name, char *prefix_name, int l1, int l2, int l3);
void RM_log_screen_prt(char *err_str, long l);
void RM_open_files(int * solute, char * prefix, int l_prefix);
void RM_open_error_file(void);
void RM_open_output_file(char * prefix, int l_prefix);
void RM_open_punch_file(char * prefix, int l_prefix);
void RM_open_log_file(char * prefix, int l_prefix);
void RM_pass_data(int *id,
             bool *fresur,
			 bool *steady_flow, 
			 int *nx, int *ny, int *nz,			// number of nodes each coordinate direction
			 //double *time_hst,					// time from transport 
			 //double *time_step_hst,				// time step from transport
			 double *cnvtmi,					// conversion factor for time
			 double *x_node,					// nxyz array of X coordinates for nodes 
			 double *y_node,					// nxyz array of Y coordinates for nodes  
			 double *z_node,					// nxyz array of Z coordinates for nodes 
			 //double *fraction,					// mass fractions nxyz:components
			 //double *frac,						// saturation fraction
			 //double *pv,						// nxyz current pore volumes 
			 double *pv0,						// nxyz initial pore volumes
			 double *volume, 					// nxyz geometric cell volumes 
			 int * printzone_chem,				// nxyz print flags for output file
			 int * printzone_xyz,				// nxyz print flags for chemistry XYZ file
			 double *rebalance_fraction_hst,	// parameter for rebalancing process load for parallel	
			 double *fraction                   // mass fraction array
			 );
#ifdef SKIP
void RM_pass_print_flags(int *id,
			 int * prslm,							// solution method print flag 
			 int * print_out,						// print flag for output file 
			 int * print_sel,						// print flag for selected output
			 int * print_hdf,						// print flag for hdf file
			 int * print_restart					// print flag for writing restart file 
			 );
#endif
void RM_run_cells(int *id,
			 int * prslm,							// solution method print flag 
			 int * print_out,						// print flag for output file 
			 int * print_sel,						// print flag for selected output
			 int * print_hdf,						// print flag for hdf file
			 int * print_restart,					// print flag for writing restart file 
			 double *time_hst,					    // time from transport 
			 double *time_step_hst,				    // time step from transport
 			 double *fraction,					    // mass fractions nxyz:components
			 double *frac,							// saturation fraction
			 double *pv,                            // nxyz current pore volumes 
			 int * stop_msg);
void RM_send_restart_name(int *id, char * s, long l);
void RM_setup_boundary_conditions(
			int *id,
			int *n_boundary, 
			int *boundary_solution1,  
			int *boundary_solution2, 
			double *fraction1,
			double *boundary_fraction, 
			int *dim);
void RM_solutions2fractions(int *id);
void RM_transport(int *ncomps);
void RM_write_bc_raw(int *id, 
			int *solution_list, 
			int * bc_solution_count, 
			int * solution_number, 
			char *prefix, 
			int prefix_l);
void RM_write_output(int *id);
void RM_write_restart(int *id);


void errprt_c(char *err_str, long l);
void logprt_c(char *err_str, long l);
void screenprt_c(char *err_str, long l);
void warnprt_c(char *err_str, long l);

//void RM_errprt(int id, char *err_str, long l);
//void RM_warnprt(int *id, char *err_str, long l);
//void RM_logprt(int *id, char *err_str, long l);
//void RM_screeenprt(int *id, char *err_str, long l);

void RM_errprt(const std::string & e_string);
void RM_warnprt(const std::string & e_string);
void RM_logprt(const std::string & e_string);
void RM_screenprt(const std::string & e_string);
extern void transport_component(int *i);
extern void transport_component_thread(int *i);

#if defined(__cplusplus)
}
#endif
// Global functions
//inline std::string trim_right(const std::string &source , const std::string& t = " \t")
//{
//	std::string str = source;
//	return str.erase( str.find_last_not_of(t) + 1);
//}
//
//inline std::string trim_left( const std::string& source, const std::string& t = " \t")
//{
//	std::string str = source;
//	return str.erase(0 , source.find_first_not_of(t) );
//}
//
//inline std::string trim(const std::string& source, const std::string& t = " \t")
//{
//	std::string str = source;
//	return trim_left( trim_right( str , t) , t );
//} 
#endif // RM_INTERFACE_H
