/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#ifndef RM_INTERFACE_H
#define RM_INTERFACE_H
#include "IPhreeqc.h"
#include "Var.h"
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif

#if defined(FC_FUNC_)
// Called from Fortran or C++
#define RM_calculate_well_ph               FC_FUNC_ (rm_calculate_well_ph,             RM_CALCULATE_WELL_PH)
#define RM_close_files                     FC_FUNC_ (rm_close_files,                   RM_CLOSE_FILES)    
#define RM_convert_to_molal                FC_FUNC_ (rm_convert_to_molal,              RM_CONVERT_TO_MOLAL)   
#define RM_create                          FC_FUNC_ (rm_create,                        RM_CREATE)
#define RM_destroy                         FC_FUNC_ (rm_destroy,                       RM_DESTROY)
#define RM_distribute_initial_conditions   FC_FUNC_ (rm_distribute_initial_conditions, RM_DISTRIBUTE_INITIAL_CONDITIONS)
#define RM_distribute_initial_conditions_mix  FC_FUNC_ (rm_distribute_initial_conditions_mix, RM_DISTRIBUTE_INITIAL_CONDITIONS_MIX)
#define RM_error                           FC_FUNC_ (rm_error,                         RM_ERROR)
#define RM_find_components                 FC_FUNC_ (rm_find_components,               RM_FIND_COMPONENTS)
#define RM_fractions2solutions             FC_FUNC_ (rm_fractions2solutions,           RM_FRACTIONS2SOLUTIONS)
#define RM_get_component                   FC_FUNC_ (rm_get_component,                 RM_GET_COMPONENT)
#define RM_initial_phreeqc_run             FC_FUNC_ (rm_initial_phreeqc_run,           RM_INITIAL_PHREEQC_RUN)
#define RM_load_database                   FC_FUNC_ (rm_load_database,                 RM_LOAD_DATABASE)
#define RM_log_screen_prt                  FC_FUNC_ (rm_log_screen_prt,                RM_LOG_SCREEN_PRT)
#define RM_open_files                      FC_FUNC_ (rm_open_files,                    RM_OPEN_FILES)
#define RM_pass_transient_data             FC_FUNC_ (rm_pass_transient_data,           RM_PASS_TRANSIENT_DATA)
#define RM_run_cells                       FC_FUNC_ (rm_run_cells,                     RM_RUN_CELLS)
#define RM_send_restart_name               FC_FUNC_ (rm_send_restart_name,             RM_SEND_RESTART_NAME)
#define RM_setup_boundary_conditions       FC_FUNC_ (rm_setup_boundary_conditions,     RM_SETUP_BOUNDARY_CONDITIONS)
#define RM_set_density                     FC_FUNC_ (rm_set_density,                   RM_SET_DENSITY)
#define RM_set_free_surface                FC_FUNC_ (rm_set_free_surface,              RM_SET_FREE_SURFACE)
#define RM_set_input_units                 FC_FUNC_ (rm_set_input_units,               RM_SET_INPUT_UNITS)
#define RM_set_mapping                     FC_FUNC_ (rm_set_mapping,                   RM_SET_MAPPING)
#define RM_set_nodes                       FC_FUNC_ (rm_set_nodes,                     RM_SET_NODES)
#define RM_set_printing                    FC_FUNC_ (rm_set_printing,                  RM_SET_PRINTING)
#define RM_set_print_chem_mask             FC_FUNC_ (rm_set_print_chem_mask,           RM_SET_PRINT_CHEM_MASK)
#define RM_set_print_xyz_mask              FC_FUNC_ (rm_set_print_xyz_mask,            RM_SET_PRINT_XYZ_MASK)
#define RM_set_pressure                    FC_FUNC_ (rm_set_pressure,                  RM_SET_PRESSURE)
#define RM_set_pv0                         FC_FUNC_ (rm_set_pv0,                       RM_SET_PV0)
#define RM_set_pv                          FC_FUNC_ (rm_set_pv,                        RM_SET_PV)
#define RM_set_rebalance                   FC_FUNC_ (rm_set_rebalance,                 RM_SET_REBALANCE)
#define RM_set_saturation                  FC_FUNC_ (rm_set_saturation,                RM_SET_SATURATION)
#define RM_set_steady_flow                 FC_FUNC_ (rm_set_steady_flow,               RM_SET_STEADY_FLOW)
#define RM_set_tempc                       FC_FUNC_ (rm_set_tempc,                     RM_SET_TEMPC)
#define RM_set_time_conversion             FC_FUNC_ (rm_set_time_conversion,           RM_SET_TIME_CONVERSION)
#define RM_set_volume					   FC_FUNC_ (rm_set_volume,                    RM_SET_VOLUME)
#define RM_phreeqc2concentrations          FC_FUNC_ (rm_phreeqc2concentrations,        RM_PHREEQC2CONCENTRATIONS)
#define RM_write_bc_raw                    FC_FUNC_ (rm_write_bc_raw,                  RM_WRITE_BC_RAW)
#define RM_write_output                    FC_FUNC_ (rm_write_output,                  RM_WRITE_OUTPUT)
#define RM_write_restart				   FC_FUNC_ (rm_write_restart,                 RM_WRITE_RESTART)
// Calls to Fortran
#define logprt_c                           FC_FUNC_ (logprt_c,                         LOGPRT_C)
#define screenprt_c                        FC_FUNC_ (screenprt_c,                      SCREENPRT_C)
#define errprt_c                           FC_FUNC_ (errprt_c,                         ERRPRT_C)
#define warnprt_c                          FC_FUNC_ (warnprt_c,                        WARNPRT_C)
#endif
#ifdef SKIP
#define RM_calculate_well_ph                  rm_calculate_well_ph
#define RM_close_files                        rm_close_files
#define RM_convert_to_molal                   rm_convert_to_molal
#define RM_create                             rm_create
#define RM_destroy                            rm_destroy
#define RM_distribute_initial_conditions      rm_distribute_initial_conditions
#define RM_error                              rm_error
#define RM_find_components                    rm_find_components
#define RM_fractions2solutions                rm_fractions2solutions
#define RM_get_component                      rm_get_component
#define RM_initial_phreeqc_run                rm_initial_phreeqc_run
#define RM_load_database                      rm_load_database
#define RM_log_screen_prt                     rm_log_screen_prt
#define RM_open_files                         rm_open_files
#define RM_pass_transient_data                rm_pass_transient_data
#define RM_run_cells                          rm_run_cells
#define RM_send_restart_name                  rm_send_restart_name
#define RM_setup_boundary_conditions          rm_setup_boundary_conditions
#define RM_set_density	                      rm_set_density
#define RM_set_input_units                    rm_set_input_units
#define RM_set_mapping                        rm_set_mapping
#define RM_set_nodes                          rm_set_nodes
#define RM_set_printing                       rm_set_printing
#define RM_set_print_chem_mask                rm_set_print_chem_mask
#define RM_set_print_xyz_mask                 rm_set_print_xyz_mask
#define RM_set_pressure                       rm_set_pressure
#define RM_set_pv0                            rm_set_pv0
#define RM_set_pv                             rm_set_pv
#define RM_set_rebalance                      rm_set_rebalance
#define RM_set_saturation                     rm_set_saturation
#define RM_set_tempc	                      rm_set_tempc
#define RM_set_time_conversion                rm_set_time_conversion
#define RM_set_volume                         rm_set_volume
#define RM_phreeqc2concentrations             rm_phreeqc2concentrations
#define RM_write_bc_raw                       rm_write_bc_raw
#define RM_write_output                       rm_write_output
#define RM_write_restart					  rm_write_restart
#endif

class RM_interface
{
public:
	static int Create_reaction_module(int *nxyz, int *nthreads);
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
void RM_close_files(int * solute);
void RM_convert_to_molal(int *id, double *c, int *n, int *dim);
int  RM_create(int *nxyz, int *nthreads);
int  RM_destroy(int *id);
void RM_distribute_initial_conditions(int *id,
		int *initial_conditions1);		// 7 x nxyz end-member 1
void RM_distribute_initial_conditions_mix(int *id,
		int *initial_conditions1,		// 7 x nxyz end-member 1
		int *initial_conditions2,		// 7 x nxyz end-member 2
		double *fraction1			    // 7 x nxyz fraction of end-member 1
		);
void RM_error(int *id);
int RM_find_components(int *id);
void RM_get_component(int * id, int * num, char *chem_name, int l1);
void RM_initial_phreeqc_run(int * id, char *db_name, char *chem_name, char *prefix_name, int l1, int l2, int l3);
void RM_log_screen_prt(char *err_str, long l);

void RM_open_files(int * solute, char * prefix, int l_prefix);
void RM_open_error_file(void);
void RM_open_output_file(char * prefix, int l_prefix);
void RM_open_punch_file(char * prefix, int l_prefix);
void RM_open_log_file(char * prefix, int l_prefix);
void RM_phreeqc2concentrations(int *id, double *c = NULL);
void RM_run_cells(int *id,
			 double *time,					        // time from transport 
			 double *time_step,				        // time step from transport
 			 double *concentration,					// mass fractions nxyz:components
			 int * stop_msg);
void RM_send_restart_name(int *id, char * s, long l);
void RM_setup_boundary_conditions(
			int *id,
			int *n_boundary, 
			int *boundary_solution1,  
			int *boundary_solution2, 
			double *fraction1,
			double *boundary_c, 
			int *dim);
void RM_set_density(int *id, double *t);
void RM_set_free_surface(int *id, int *t);
void RM_set_input_units (int *id, 
	int *sol=NULL, int *pp=NULL, int *ex=NULL, int *surf=NULL, int *gas=NULL, int *ss=NULL, int *kin=NULL);
void RM_set_mapping (int *id, int *grid2chem=NULL); 
void RM_set_nodes(int *id, double *x_node, double *y_node, double *z_node);
void RM_set_printing(int *id, int *print_chem, int *print_xyz, int *print_hdf, int *print_restart);
void RM_set_print_chem_mask(int *id, int *t);
void RM_set_print_xyz_mask(int *id, int *t);
void RM_set_pressure(int *id, double *t);
void RM_set_pv(int *id, double *t);
void RM_set_pv0(int *id, double *t);
void RM_set_rebalance(int *id, int *method, double *f);
void RM_set_saturation(int *id, double *t);
void RM_set_steady_flow(int *id, int *t);
void RM_set_tempc(int *id, double *t);
void RM_set_time_conversion(int *id, double *t);
void RM_set_volume(int *id, double *t);
void RM_write_bc_raw(int *id, 
			int *solution_list, 
			int * bc_solution_count, 
			int * solution_number, 
			char *prefix, 
			int prefix_l);
void RM_write_output(int *id);
void RM_write_restart(int *id);

void errprt_c(const char *err_str, long l);
void logprt_c(const char *err_str, long l);
void screenprt_c(const char *err_str, long l);
void warnprt_c(const char *err_str, long l);

void RM_errprt(const std::string & e_string);
void RM_warnprt(const std::string & e_string);
void RM_logprt(const std::string & e_string);
void RM_screenprt(const std::string & e_string);

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
