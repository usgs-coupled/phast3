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
/*! @brief Enumeration used to return error codes.
*/
typedef enum {
	IRM_OK            =  0,  /*!< Success */
	IRM_OUTOFMEMORY   = -1,  /*!< Failure, Out of memory */
	IRM_BADVARTYPE    = -2,  /*!< Failure, Invalid VAR type */
	IRM_INVALIDARG    = -3,  /*!< Failure, Invalid argument */
	IRM_INVALIDROW    = -4,  /*!< Failure, Invalid row */
	IRM_INVALIDCOL    = -5,  /*!< Failure, Invalid column */
	IRM_BADINSTANCE   = -6,  /*!< Failure, Invalid rm instance id */
	IRM_FAIL          = -7,  /*!< Failure, Unspecified */
} IRM_RESULT;

class Reaction_module: public PHRQ_base
{
public:

	Reaction_module(int *nxyz = NULL, int *thread_count = NULL, PHRQ_io * io=NULL);
	~Reaction_module(void);
	void                           Calculate_well_ph(double *c, double * ph, double * alkalinity);
	int                            CheckSelectedOutput();
	void                           Concentrations2Module(void);	
	void                           Convert_to_molal(double *c, int n, int dim);
	static std::string             Cptr2TrimString(const char * str, long l = -1);
	IRM_RESULT                     CreateMapping(int *grid2chem);
	IRM_RESULT                     Distribute_initial_conditions_mix(
                                        int id,
                                        int *initial_conditions1,
                                        int *initial_conditions2,	
                                        double *fraction1);
	int                            Find_components();
	int                            GetNthSelectedOutputUserNumber(int *i);
	IRM_RESULT                     GetSelectedOutput(double *so);
	int                            GetSelectedOutputColumnCount(void);
	int                            GetSelectedOutputCount(void);
	IRM_RESULT                     GetSelectedOutputHeading(int *icol, std::string &heading);
	int                            GetSelectedOutputRowCount(void);
	int                            InitialPhreeqcRun(const char *chemistry_name, long l = -1);
	IRM_RESULT                     InitialPhreeqcConcentrations( 
                                        double *c,
                                        int *n_boundary, 
                                        int *dim, 
                                        int *boundary_solution1,
                                        int *boundary_solution2 = NULL,
                                        double *boundary_fraction = NULL);
	int                            LoadDatabase(const char * database, long l = -1);
	void                           Module2Concentrations(double * c);
	void                           RunCells(void);
	void                           Send_restart_name(std::string &name);
	int                            SetCurrentSelectedOutputUserNumber(int *i);
	void                           Write_bc_raw(int *solution_list, int * bc_solution_count, 
                                        int * solution_number, 
                                        const std::string &prefix);
	void                           Write_restart(void);

	// setters and getters
	std::vector<IPhreeqcPhast *> & Get_workers() {return this->workers;}
	int                            Get_nthreads() {return this->nthreads;}
	std::vector<double> &          GetCellVolume(void) {return this->cell_volume;}
	void                           SetCellVolume(double * t);
	IRM_RESULT                     SetChemistryFileName(const char * prefix, long l = -1);
	const std::string              GetDatabaseFileName(void) const {return this->database_file_name;}
	IRM_RESULT                     SetDatabaseFileName(const char * prefix, long l = -1);
	const std::string              GetFilePrefix(void) const {return this->file_prefix;}
	IRM_RESULT                     SetFilePrefix(std::string &fn); 
	IRM_RESULT                     SetFilePrefix(const char * prefix, long l = -1);
	cxxStorageBin &                Get_phreeqc_bin(void) {return this->phreeqc_bin;}
	const int                      Get_mpi_tasks(void) const {return this->mpi_tasks;}
	void                           Set_mpi_tasks(int t) {this->mpi_tasks = t;}
	const int                      GetMpiMyself(void) const {return this->mpi_myself;}
	const bool                     Get_free_surface(void) const {return this->free_surface;}
	void                           Set_free_surface(int * t); 
	const bool                     Get_steady_flow(void) const {return this->steady_flow;}
	void                           Set_steady_flow(int * t);
	const int                      GetChemistryCellCount(void) const {return this->count_chem;}
	const int                      GetGridCellCount(void) const {return this->nxyz;}
	const std::vector<std::string> & Get_components(void) const {return this->components;}
	double                         GetTime(void) const {return this->time;}
	void                           SetTime(double *t = NULL); 
	double                         GetTimeStep(void) const {return this->time_step;}
	void                           SetTimeStep(double *t = NULL); 
	const double                   GetTimeConversion(void) const {return this->time_conversion;}
	void                           SetTimeConversion(double *t); 
	const std::vector<double> &    Get_x_node(void) const {return this->x_node;}
	void                           Set_x_node(double * t = NULL);
	const std::vector<double> &    Get_y_node(void) const {return this->y_node;}
	void                           Set_y_node(double * t = NULL);
	const std::vector<double> &    Get_z_node(void) const {return this->z_node;}
	void                           Set_z_node(double * t = NULL);
	std::vector<double> &          GetDensity(void) {return this->density;}
	void                           SetDensity(double * t = NULL); 
	std::vector<double> &          GetConcentration(void) {return this->concentration;}
	void                           SetConcentration(double * t = NULL); 
	std::vector<double> &          GetSaturation(void) {return this->saturation;}
	void                           SetSaturation(double * t); 
	std::vector<double> &          GetPoreVolume(void) {return this->pore_volume;}
	void                           SetPoreVolume(double * t = NULL); 
	std::vector<double> &          GetPoreVolumeZero(void) {return this->pore_volume_zero;}
	void                           SetPoreVolumeZero(double * t = NULL); 
	std::vector<double> &          GetPressure(void) {return this->pressure;}
	void                           SetPressure(double * t = NULL);
	std::vector<double> &          GetTemperature(void) {return this->tempc;}
	void                           SetTemperature(double * t = NULL);  
	std::vector<int> &             Get_print_chem_mask (void) {return this->print_chem_mask;}
	void                           Set_print_chem_mask(int * t); 
	int                            GetRebalanceMethod(void) const {return this->rebalance_method;}
	void                           SetRebalanceMethod(int * t); 
	double                         Get_rebalance_fraction(void) const {return this->rebalance_fraction;}
	void                           Set_rebalance_fraction(double * t); 
	const bool                     Get_print_chem(void) const {return this->print_chem;}
	void                           Set_print_chem(int *t); 
	const bool                     GetSelectedOutputOn(void) const {return this->selected_output_on;}
	void                           SetSelectedOutputOn(int *t);
	const bool                     Get_print_restart(void) const {return this->print_restart;}
	void                           Set_print_restart(int *t); 
	const bool                     Get_stop_message(void) const {return this->stop_message;}
	void                           Set_stop_message(bool t = false); 
	
	int                            Get_input_units_Solution(void) {return this->input_units_Solution;}
	int                            Get_input_units_PPassemblage(void) {return this->input_units_PPassemblage;}
	int                            Get_input_units_Exchange(void) {return this->input_units_Exchange;}
	int                            Get_input_units_Surface(void) {return this->input_units_Surface;}
	int                            Get_input_units_GasPhase(void) {return this->input_units_GasPhase;}
	int                            Get_input_units_SSassemblage(void) {return this->input_units_SSassemblage;}
	int                            Get_input_units_Kinetics(void) {return this->input_units_Kinetics;}

	void                           Set_input_units_Solution(int i) {this->input_units_Solution = i;}
	void                           Set_input_units_PPassemblage(int i) {this->input_units_PPassemblage = i;}
	void                           Set_input_units_Exchange(int i) {this->input_units_Exchange = i;}
	void                           Set_input_units_Surface(int i) {this->input_units_Surface = i;}
	void                           Set_input_units_GasPhase(int i) {this->input_units_GasPhase = i;}
	void                           Set_input_units_SSassemblage(int i) {this->input_units_SSassemblage = i;}
	void                           Set_input_units_Kinetics(int i) {this->input_units_Kinetics = i;}
	void                           Set_input_units(int *sol, int *pp, int *ex, int *surf, int *gas, int *ss, int *k);
protected:
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
	void Concentrations2Threads(int n);
	void cxxSolution2concentration(cxxSolution * cxxsoln_ptr, std::vector<double> & d);
	void Error_stop(void);
	bool File_exists(const std::string &name);
	void File_rename(const std::string &temp_name, const std::string &name, const std::string &backup_name);
	void Partition_uz(int iphrq, int ihst, double new_frac);
	void Partition_uz_thread(int n, int iphrq, int ihst, double new_frac);
	void Rebalance_load(void);
	void Write_error(const char * item);
	void Write_log(const char * item);
	void Write_output(const char * item);
	void Write_screen(const char * item);
	void Write_xyz(const char * item);
#ifdef SKIP
	void Init_uz(void);
#endif
	int Initial_phreeqc_run_thread(int n);
	void Rebalance_load_per_cell(void);
	void Run_cells_thread(int i);
	void Scale_solids(int n, int iphrq, LDBLE frac);
	void Set_end_cells(void);
	void Transfer_cells(cxxStorageBin &t_bin, int old, int nnew);

protected:
	std::string database_file_name;
	std::string chemistry_file_name;
	std::string file_prefix;
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
	std::vector<double> pressure;			// nxyz current pressure
	std::vector<double> pore_volume;		// nxyz current pore volumes 
	std::vector<double> pore_volume_zero;	// nxyz initial pore volumes
	std::vector<double> cell_volume;		// nxyz geometric cell volumes
	std::vector<double> tempc;				// nxyz temperature Celsius
	std::vector<double> density;			// nxyz density
	std::vector<int> print_chem_mask;		// nxyz print flags for output file
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
	bool selected_output_on;				// create selected output
	bool print_restart;						// print flag for writing restart file 

	bool stop_message;

	// threading
	int nthreads;
	std::vector<IPhreeqcPhast *> workers;
	std::vector<int> start_cell;
	std::vector<int> end_cell;
	
};
#endif // !defined(REACTION_MODULE_H_INCLUDED)
