#if !defined(REACTION_MODULE_H_INCLUDED)
#define REACTION_MODULE_H_INCLUDED
#include "PHRQ_base.h"
#include "IPhreeqcPhast.h"
#include "StorageBin.h"
#include <vector>
#include <list>

class PHRQ_io;
class IPhreeqc;

class Reaction_module: public PHRQ_base
{
public:

	Reaction_module(PHRQ_io * io=NULL);
	~Reaction_module(void);
	// Called through wrappers
	//int Load_database(std::string database_name);
	//int Initial_phreeqc_run(std::string database_name, std::string chemistry_name);
	//void Get_components(int *n_comp, char *names, int length);


	void Convert_to_molal(double *c, int n, int dim);
	void Calculate_well_ph(double *c, double * ph, double * alkalinity);
	void Distribute_initial_conditions(
		int id,
		int *initial_conditions1,
		int *initial_conditions2,	
		double *fraction1,
		int exchange_units,
		int surface_units,
		int ssassemblage_units,
		int ppassemblage_units,
		int gasphase_units,
		int kinetics_units);
	void Error_stop(void);
	void Forward_and_back(
		int *initial_conditions, 
		int *axes);
	void Fractions2Solutions(void);
	int Find_components();	
	void Run_cells(void);
	void Scale_solids(int iphrq, LDBLE frac);

	void Send_restart_name(std::string name);
	void Setup_boundary_conditions(const int n_boundary, int *boundary_solution1,
						  int *boundary_solution2, double *fraction1,
						  double *boundary_fraction, int dim);
	void Solutions2Fractions(void);
	void Write_bc_raw(int *solution_list, int * bc_solution_count, 
		int * solution_number, const std::string &prefix);
	void Write_error(std::string item);
	void Write_log(std::string item);
	void Write_output(std::string item);
	void Write_screen(std::string item);
	void Write_xyz(std::string item);

	// setters and getters
	IPhreeqcPhast * Get_phast_iphreeqc_worker() {return this->phast_iphreeqc_worker;}
	const std::string Get_database_file_name(void) const {return this->database_file_name;}
	void Set_database_file_name(std::string fn) {this->database_file_name = fn;}
	const std::string Get_file_prefix(void) const {return this->file_prefix;}
	void Set_file_prefix(std::string fn) {this->file_prefix = fn;}
	cxxStorageBin & Get_phreeqc_bin(void) {return this->phreeqc_bin;}
	const int Get_mpi_tasks(void) const {return this->mpi_tasks;}
	void Set_mpi_tasks(int t) {this->mpi_tasks = t;}
	const int Get_mpi_myself(void) const {return this->mpi_myself;}
	void Set_mpi_myself(int t) {this->mpi_myself = t;}
	std::vector<double> & Get_old_frac(void) {return this->old_frac;}

	const bool Get_free_surface(void) const {return this->free_surface;};
	void Set_free_surface(bool t) {this->free_surface = t;};
	const bool Get_steady_flow(void) const {return this->steady_flow;};
	void Set_steady_flow(bool t) {this->steady_flow = t;};
	const bool Get_transient_free_surface(void) const {return this->transient_free_surface;};
	void Set_transient_free_surface(bool t) {this->transient_free_surface = t;};
	const int Get_nxyz(void) const {return this->nxyz;};
	void Set_nxyz(int t) {this->nxyz = t;};
	const int Get_nx(void) const {return this->nx;};
	void Set_nx(int t) {this->nx = t;};
	const int Get_ny(void) const {return this->ny;};
	void Set_ny(int t) {this->ny = t;};
	const int Get_nz(void) const {return this->nz;};
	void Set_nz(int t) {this->nz = t;};
	const std::vector<std::string> & Get_components(void) const {return this->components;};
	const double * Get_time_hst(void) const {return this->time_hst;};
	void Set_time_hst(double * t) {this->time_hst = t;};
	const double *Get_time_step_hst(void) const {return this->time_step_hst;};
	void Set_time_step_hst(double * t) {this->time_step_hst = t;};
	const double * Get_cnvtmi(void) const {return this->cnvtmi;};
	void Set_cnvtmi(double * t) {this->cnvtmi = t;};
	const double * Get_x_node(void) const {return this->x_node;};
	void Set_x_node(double * t) {this->x_node = t;};
	const double * Get_y_node(void) const {return this->y_node;};
	void Set_y_node(double * t) {this->y_node = t;};
	const double * Get_z_node(void) const {return this->z_node;};
	void Set_z_node(double * t) {this->z_node = t;};
	double * Get_fraction(void) const {return this->fraction;};
	void Set_fraction(double * t) {this->fraction = t;};
	const double * Get_frac(void) const {return this->frac;};
	void Set_frac(double * t) {this->frac = t;};
	const double * Get_pv(void) const {return this->pv;};
	void Set_pv(double * t) {this->pv = t;};
	const double * Get_pv0(void) const {return this->pv0;};
	void Set_pv0(double * t) {this->pv0 = t;};
	const double * Get_volume(void) const {return this->volume;};
	void Set_volume(double * t) {this->volume = t;};
	const int * Get_printzone_chem(void) const {return this->printzone_chem;};
	void Set_printzone_chem(int * t) {this->printzone_chem = t;};
	const int * Get_printzone_xyz(void) const {return this->printzone_xyz;};
	void Set_printzone_xyz(int * t) {this->printzone_xyz = t;};
	const double * Get_rebalance_fraction_hst(void) const {return this->rebalance_fraction_hst;};
	void Set_rebalance_fraction_hst(double * t) {this->rebalance_fraction_hst = t;};

	const bool Get_prslm(void) const {return this->prslm;};
	void Set_prslm(bool t) {this->prslm = t;};
	const bool Get_print_chem(void) const {return this->print_chem;};
	void Set_print_chem(bool t) {this->print_chem = t;};
	const bool Get_print_xyz(void) const {return this->print_xyz;};
	void Set_print_xyz(bool t) {this->print_xyz = t;};
	const bool Get_print_hdf(void) const {return this->print_hdf;};
	void Set_print_hdf(bool t) {this->print_hdf = t;};
	const bool Get_print_restart(void) const {return this->print_restart;};
	void Set_print_restart(bool t) {this->print_restart = t;};

protected:
	// internal methods
	void Cell_initialize(
	//	std::ostringstream &mix_string,
	//	std::ostringstream &copy_string,
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
		double porosity_factor);

	//void Unpack_fraction_array(void);
	//void Pack_fraction_array(void);
	bool n_to_ijk (int n, int &i, int &j, int &k);
	void cxxSolution2fraction(cxxSolution * cxxsoln_ptr, std::vector<double> & d);
	void Write_restart(void);
	bool File_exists(const std::string name);
	void File_rename(const std::string temp_name, const std::string name, const std::string backup_name);
	void Partition_uz(int iphrq, int ihst, double new_frac);
	void Init_uz(void);

protected:
	IPhreeqcPhast * phast_iphreeqc_worker;
	std::string database_file_name;
	std::string file_prefix;
	cxxStorageBin uz_bin;
	//cxxStorageBin sz_bin;
	cxxStorageBin phreeqc_bin;
	std::map < std::string, int > FileMap; 
	int mpi_myself;
	int mpi_tasks;
	std::vector <std::string> components;	// list of components to be transported
	std::vector <double> gfw;				// gram formula weights converting mass to moles (1 for each component)
	std::vector <double> old_frac;			// saturation fraction from previous step
	double gfw_water;						// gfw of water
	int count_chem;							// number of cells for chemistry

	// From Fortran
	bool free_surface;                      // free surface calculation
	bool steady_flow;						// steady-state flow
	bool transient_free_surface;            // free surface and not steady flow
	int nxyz;								// number of nodes 
	int nx, ny, nz;							// number of nodes in each coordinate direction
	double *time_hst;						// scalar time from transport 
	double *time_step_hst;					// scalar time step from transport
	double *cnvtmi;							// scalar conversion factor for time
	double *x_node;							// nxyz array of X coordinates for nodes
	double *y_node;							// nxyz array of Y coordinates for nodes 
	double *z_node;							// nxyz array of Z coordinates for nodes
	double *fraction;						// nxyz by ncomps mass fractions nxyz:components
	double *frac;							// nxyz saturation fraction
	double *pv;								// nxyz current pore volumes 
	double *pv0;							// nxyz initial pore volumes
	double *volume;							// nxyz geometric cell volumes 
	int *printzone_chem;					// nxyz print flags for output file
	int *printzone_xyz;						// nxyz print flags for chemistry XYZ file 
	double *rebalance_fraction_hst;			// parameter for rebalancing process load for parallel	
	int * ic1;								// reactant number for end member 1; indicates presence in model
	std::vector <int> forward;				// mapping from nxyz cells to count_chem chemistry cells
	std::vector <std::vector <int> > back;	// mapping from count_chem chemistry cells to nxyz cells 

	// print flags
	bool prslm;								// solution method print flag 
	bool print_chem;						// print flag for chemistry output file 
	bool print_xyz;							// print flag for selected output
	bool print_hdf;							// print flag for hdf file
	bool print_restart;						// print flag for writing restart file 
	bool write_xyz_headings;                // write xyz headings once

	char line_buffer[4096];
};
#endif // !defined(REACTION_MODULE_H_INCLUDED)
