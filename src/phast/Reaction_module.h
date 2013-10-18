#if !defined(REACTION_MODULE_H_INCLUDED)
#define REACTION_MODULE_H_INCLUDED
#include "PHRQ_base.h"
#include "IPhreeqcPhast.h"
#include "StorageBin.h"
#include <vector>
#include <list>
#include <set>

class PHRQ_io;
class IPhreeqc;

class Reaction_module: public PHRQ_base
{
public:

	Reaction_module(int *nxyz = NULL, int *thread_count = NULL, PHRQ_io * io=NULL);
	~Reaction_module(void);

	void BeginTimeStep(void);
	void Cell_initialize(
		int i, 
		int n_user_new, 
		int *initial_conditions1,
		int *initial_conditions2, 
		double *fraction1,
		int exchange_units, 
		int surface_units, 
		int ssassemblage_units,
		int ppassemblage_units, 
		int gasphase_units, 
		int kinetics_units,
		double porosity_factor,
		std::set<std::string> error_set);
	void Calculate_well_ph(double *c, double * ph, double * alkalinity);
	void Convert_to_molal(double *c, int n, int dim);
	void cxxSolution2fraction(cxxSolution * cxxsoln_ptr, std::vector<double> & d);
	void Distribute_initial_conditions_mix(
		int id,
		int *initial_conditions1,
		int *initial_conditions2,	
		double *fraction1);
	void EndTimeStep(void);
	void Error_stop(void);
	bool File_exists(const std::string &name);
	void File_rename(const std::string &temp_name, const std::string &name, const std::string &backup_name);
	int Find_components();
	//void Forward_and_back(int *initial_conditions, int *axes);
	void Fractions2Solutions(void);
	void Fractions2Solutions_thread(int n);	
	void Init_uz(void);
	void Initial_phreeqc_run(std::string &database_name, std::string &chemistry_name, std::string &prefix);
	void Initial_phreeqc_run_thread(int n);
	void Partition_uz(int iphrq, int ihst, double new_frac);
	void Partition_uz_thread(int n, int iphrq, int ihst, double new_frac);
	void Rebalance_load(void);
	void Rebalance_load_per_cell(void);
	void Run_cells(void);
	void Run_cells_thread(int i);
	void Scale_solids(int n, int iphrq, LDBLE frac);
	void Send_restart_name(std::string &name);
	void Set_end_cells(void);
	void Set_mapping(int *grid2chem);
	void Setup_boundary_conditions(const int n_boundary, int *boundary_solution1,
						  int *boundary_solution2, double *fraction1,
						  double *boundary_fraction, int dim);
	void Phreeqc2Concentrations(double * c);
	void Phreeqc2Concentrations_thread(int n);
	void Transfer_cells(cxxStorageBin &t_bin, int old, int nnew);
	void Write_bc_raw(int *solution_list, int * bc_solution_count, 
		int * solution_number, const std::string &prefix);
	void Write_error(const char * item);
	void Write_log(const char * item);
	void Write_output(const char * item);
	void Write_restart(void);
	void Write_screen(const char * item);
	void Write_xyz(const char * item);

	// setters and getters
	std::vector<IPhreeqcPhast *> & Get_workers() {return this->workers;}
	int Get_nthreads() {return this->nthreads;}
	const std::string Get_database_file_name(void) const {return this->database_file_name;}
	void Set_database_file_name(std::string &fn) {this->database_file_name = fn;}
	const std::string Get_file_prefix(void) const {return this->file_prefix;}
	void Set_file_prefix(std::string &fn) {this->file_prefix = fn;}
	cxxStorageBin & Get_phreeqc_bin(void) {return this->phreeqc_bin;}
	const int Get_mpi_tasks(void) const {return this->mpi_tasks;}
	void Set_mpi_tasks(int t) {this->mpi_tasks = t;}
	const int Get_mpi_myself(void) const {return this->mpi_myself;}
	void Set_mpi_myself(int t) {this->mpi_myself = t;}
	std::vector<double> & Get_old_saturation(void) {return this->old_saturation;}
	const bool Get_free_surface(void) const {return this->free_surface;};
	void Set_free_surface(int * t); 
	const bool Get_steady_flow(void) const {return this->steady_flow;};
	void Set_steady_flow(int * t);
	const int Get_nxyz(void) const {return this->nxyz;};
	void Set_nxyz(int t) {this->nxyz = t;};
	const std::vector<std::string> & Get_components(void) const {return this->components;};
	double Get_time(void) const {return this->time;};
	void Set_time(double t); 
	double Get_time_step(void) const {return this->time_step;};
	void Set_time_step(double t); 
	const double Get_time_conversion(void) const {return this->time_conversion;};
	void Set_time_conversion(double t); 
	const std::vector<double> & Get_x_node(void) const {return this->x_node;};
	void Set_x_node(double * t = NULL);
	const std::vector<double> & Get_y_node(void) const {return this->y_node;};
	void Set_y_node(double * t = NULL);
	const std::vector<double> & Get_z_node(void) const {return this->z_node;};
	void Set_z_node(double * t = NULL);
	std::vector<double> & Get_concentration(void) {return this->concentration;}
	void Set_concentration(double * t = NULL); 
	std::vector<double> & Get_saturation(void) {return this->saturation;};
	void Set_saturation(double * t); 
	std::vector<double> & Get_pv(void) {return this->pv;};
	void Set_pv(double * t = NULL); 
	std::vector<double> & Get_pv0(void) {return this->pv0;};
	void Set_pv0(double * t = NULL); 
	std::vector<double> & Get_volume(void) {return this->volume;};
	void Set_volume(double * t); 
	std::vector<int> & Get_print_chem_mask (void) {return this->print_chem_mask;}
	void Set_print_chem_mask(int * t); 
	std::vector<int> & Get_print_xyz_mask (void) {return this->print_xyz_mask;}
	void Set_print_xyz_mask (int * t); 
	int Get_rebalance_method(void) const {return this->rebalance_method;};
	void Set_rebalance_method(bool t) {this->rebalance_method = t;};
	double Get_rebalance_fraction(void) const {return this->rebalance_fraction;};
	void Set_rebalance_fraction(double t) {this->rebalance_fraction = t;};
	const bool Get_print_chem(void) const {return this->print_chem;};
	void Set_print_chem(bool t = false); 
	const bool Get_print_xyz(void) const {return this->print_xyz;};
	void Set_print_xyz(bool t = false); 
	const bool Get_print_hdf(void) const {return this->print_hdf;};
	void Set_print_hdf(bool t = false); 
	const bool Get_print_restart(void) const {return this->print_restart;};
	void Set_print_restart(bool t = false); 
	const bool Get_stop_message(void) const {return this->stop_message;};
	void Set_stop_message(bool t = false); 
	
	int Get_input_units_Solution(void) {return this->input_units_Solution;}
	int Get_input_units_PPassemblage(void) {return this->input_units_PPassemblage;}
	int Get_input_units_Exchange(void) {return this->input_units_Exchange;}
	int Get_input_units_Surface(void) {return this->input_units_Surface;}
	int Get_input_units_GasPhase(void) {return this->input_units_GasPhase;}
	int Get_input_units_SSassemblage(void) {return this->input_units_SSassemblage;}
	int Get_input_units_Kinetics(void) {return this->input_units_Kinetics;}

	void Set_input_units_Solution(int i) {this->input_units_Solution = i;}
	void Set_input_units_PPassemblage(int i) {this->input_units_PPassemblage = i;}
	void Set_input_units_Exchange(int i) {this->input_units_Exchange = i;}
	void Set_input_units_Surface(int i) {this->input_units_Surface = i;}
	void Set_input_units_GasPhase(int i) {this->input_units_GasPhase = i;}
	void Set_input_units_SSassemblage(int i) {this->input_units_SSassemblage = i;}
	void Set_input_units_Kinetics(int i) {this->input_units_Kinetics = i;}
	void Set_input_units(int *sol, int *pp, int *ex, int *surf, int *gas, int *ss, int *k);
protected:
	std::string database_file_name;
	std::string chemistry_file_name;
	std::string file_prefix;
	std::vector<std::string> selected_output_names;
	cxxStorageBin uz_bin;
	cxxStorageBin phreeqc_bin;
	std::map < std::string, int > FileMap; 
	int mpi_myself;
	int mpi_tasks;
	std::vector <std::string> components;	// list of components to be transported
	std::vector <double> gfw;				// gram formula weights converting mass to moles (1 for each component)
	double gfw_water;						// gfw of water

	bool free_surface;                      // free surface calculation
	bool steady_flow;						// steady-state flow
	int nxyz;								// number of nodes 
	int count_chem;							// number of cells for chemistry
	double time;						    // time from transport, sec 
	double time_step;					    // time step from transport, sec
	double time_conversion;					// time conversion factor, multiply to convert to preferred time unit for output
	std::vector<double> x_node;             // x node location, nxyz array
	std::vector<double> y_node;				// y node location, nxyz array
	std::vector<double> z_node;             // z node location, nxyz array
	std::vector<double> concentration;		// nxyz by ncomps concentrations nxyz:components
	std::vector <double> old_saturation;	// saturation fraction from previous step
	std::vector<double> saturation;	        // nxyz saturation fraction
	std::vector<double> pv;			        // nxyz current pore volumes 
	std::vector<double> pv0;				// nxyz initial pore volumes
	std::vector<double> volume;				// nxyz geometric cell volumes 
	std::vector<int> print_chem_mask;		// nxyz print flags for output file
	std::vector<int> print_xyz_mask;		// nxyz print flags for chemistry XYZ file 
	bool rebalance_method;                  // rebalance method 0 std, 1 by_cell
	double rebalance_fraction;			    // parameter for rebalancing process load for parallel	
	std::vector<int> have_Solution;
	std::vector<int> have_PPassemblage;
	std::vector<int> have_Exchange;
	std::vector<int> have_Surface;
	std::vector<int> have_GasPhase;
	std::vector<int> have_SSassemblage;
	std::vector<int> have_Kinetics;
	int input_units_Solution;
	int input_units_PPassemblage;
	int input_units_Exchange;
	int input_units_Surface;
	int input_units_GasPhase;
	int input_units_SSassemblage;
	int input_units_Kinetics;
	std::vector <int> forward;				// mapping from nxyz cells to count_chem chemistry cells
	std::vector <std::vector <int> > back;	// mapping from count_chem chemistry cells to nxyz cells 

	// print flags
	bool print_chem;						// print flag for chemistry output file 
	bool print_xyz;							// print flag for selected output
	bool print_hdf;							// print flag for hdf file
	bool print_restart;						// print flag for writing restart file 
	bool write_xyz_headings;                // write xyz headings once

	bool stop_message;

	// threading
	int nthreads;
	std::vector<IPhreeqcPhast *> workers;
	std::vector<int> start_cell;
	std::vector<int> end_cell;
	
};
#endif // !defined(REACTION_MODULE_H_INCLUDED)
