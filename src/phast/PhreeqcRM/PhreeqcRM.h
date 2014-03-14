#if !defined(PHREEQCRM_H_INCLUDED)
#define PHREEQCRM_H_INCLUDED
#include "PHRQ_base.h"
#include "IPhreeqcPhast.h"
#include "StorageBin.h"
#include <vector>
#include <list>
#include <set>

class PHRQ_io;
class IPhreeqc;
/**
 * @class PhreeqcRMStop
 *
 * @brief This class is derived from std::exception and is thrown
 * when an unrecoverable error has occured.
 */
class IPQ_DLL_EXPORT PhreeqcRMStop : std::exception
{
};

#include "IrmResult.h"
/*! @brief Enumeration used to for MPI worker to determine method to call
*/
typedef enum {
	METHOD_CREATEMAPPING,
	METHOD_DUMPMODULE,
	METHOD_FINDCOMPONENTS,
	METHOD_GETCONCENTRATIONS,
	METHOD_GETDENSITY,
	METHOD_GETSELECTEDOUTPUT,
	METHOD_GETSOLUTIONVOLUME,
	METHOD_GETSPECIESCONCENTRATIONS,
	METHOD_INITIALPHREEQC2MODULE,
	METHOD_INITIALPHREEQCCELL2MODULE,
	METHOD_LOADDATABASE,
	METHOD_MPIWORKERBREAK,
	METHOD_RUNCELLS,
	METHOD_RUNFILE,
	METHOD_RUNSTRING,
	METHOD_SETCELLVOLUME,
	METHOD_SETCOMPONENTH2O,
	METHOD_SETCONCENTRATIONS,
	METHOD_SETDENSITY,
	METHOD_SETERRORHANDLERMODE,
	METHOD_SETFILEPREFIX,
	//METHOD_SETPARTITIONUZSOLIDS,
	METHOD_SETPOREVOLUME,
	METHOD_SETPRESSURE,
	METHOD_SETPRINTCHEMISTRYON,
	METHOD_SETPRINTCHEMISTRYMASK,
	METHOD_SETREBALANCEBYCELL,
	METHOD_SETSATURATION,
	METHOD_SETSELECTEDOUTPUTON,
	METHOD_SETSPECIESSAVEON,
	METHOD_SETTEMPERATURE,
	METHOD_SETTIME,
	METHOD_SETTIMECONVERSION,
	METHOD_SETTIMESTEP,
	METHOD_SETUNITSEXCHANGE,
	METHOD_SETUNITSGASPHASE,
	METHOD_SETUNITSKINETICS,
	METHOD_SETUNITSPPASSEMBLAGE,
	METHOD_SETUNITSSOLUTION,
	METHOD_SETUNITSSSASSEMBLAGE,
	METHOD_SETUNITSSURFACE,
	METHOD_SPECIESCONCENTRATIONS2MODULE
} MPI_METHOD;

class PhreeqcRM: public PHRQ_base
{
public:
	static void             CleanupReactionModuleInstances(void);
	static int              CreateReactionModule(int nxyz, int nthreads = -1);
	static IRM_RESULT       DestroyReactionModule(int n);
	static PhreeqcRM      * GetInstance(int n);

	PhreeqcRM(int nxyz, int thread_count_or_communicator, PHRQ_io * io=NULL);
	~PhreeqcRM(void);
	
	// Key methods	
	IRM_RESULT                                CloseFiles(void);
	IPhreeqc *                                Concentrations2Utility(std::vector<double> &c_in, 
		                                           std::vector<double> t_in, std::vector<double> p_in);
	IRM_RESULT                                CreateMapping(int *grid2chem);
	void                                      DecodeError(int r);
	IRM_RESULT                                DumpModule(bool dump_on, bool append = false);
	void                                      ErrorHandler(int result, const std::string &e_string);
	void                                      ErrorMessage(const std::string &error_string, bool prepend = true);
	int                                       FindComponents();
	IRM_RESULT                                GetConcentrations(std::vector<double> &c);
	IRM_RESULT								  InitialPhreeqc2Concentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1,
													std::vector < int >    & boundary_solution2, 
													std::vector < double > & fraction1); 
	IRM_RESULT                                InitialPhreeqc2Concentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1);
	IRM_RESULT                                InitialPhreeqc2Module(
													int *initial_conditions1);
	IRM_RESULT                                InitialPhreeqc2Module(
													int *initial_conditions1,
													int *initial_conditions2,	
													double *fraction1);
	IRM_RESULT								  InitialPhreeqc2SpeciesConcentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1,
													std::vector < int >    & boundary_solution2, 
													std::vector < double > & fraction1); 
	IRM_RESULT                                InitialPhreeqc2SpeciesConcentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1);
	IRM_RESULT                                InitialPhreeqcCell2Module(int i, const std::vector<int> &cell_numbers);
	IRM_RESULT                                LoadDatabase(const char * database);
	void                                      LogMessage(const std::string &str);
	int                                       MpiAbort();
	IRM_RESULT                                MpiWorker();
	IRM_RESULT                                MpiWorkerBreak();	
	IRM_RESULT                                OpenFiles(void);
	void                                      OutputMessage(const std::string &str);
	IRM_RESULT                                RunCells(void);
	IRM_RESULT                                RunFile(bool workers, bool initial_phreeqc, bool utility,  const char *chemistry_name);
	IRM_RESULT                                RunString(bool workers, bool initial_phreeqc, bool utility, const char *str);
	void                                      ScreenMessage(const std::string &str);
	IRM_RESULT								  SpeciesConcentrations2Module(std::vector<double> & species_conc); 
	void                                      WarningMessage(const std::string &str);

	// TODO ///////////////////////////
	void                                      Write_bc_raw(int *solution_list, int * bc_solution_count, 
                                                  int * solution_number, 
                                                  const std::string &prefix);
	// Getters 
	const std::vector < std::vector <int> > & GetBackwardMapping(void) {return this->backward_mapping;}
	std::vector<double> &                     GetCellVolume(void) {return this->cell_volume;}
	int                                       GetChemistryCellCount(void) const {return this->count_chemistry;}
	int                                       GetComponentCount(void) const {return (int) this->components.size();}
	const std::vector<std::string> &          GetComponents(void) const {return this->components;}
	const std::string                         GetDatabaseFileName(void) const {return this->database_file_name;}
	//std::vector<double> &                     GetDensity(void); 
	IRM_RESULT                                GetDensity(std::vector<double> & density); 
	const std::vector < int> &                GetEndCell(void) const {return this->end_cell;}
	int                                       GetErrorHandlerMode(void) {return this->error_handler_mode;}
	const std::string                         GetFilePrefix(void) const {return this->file_prefix;}
	const std::vector < int > &               GetForwardMapping(void) {return this->forward_mapping;}
	const std::vector < double > &            GetGfw(void) {return this->gfw;}
	const int                                 GetGridCellCount(void) const {return this->nxyz;}
	int                                       GetInputUnitsSolution(void) {return this->input_units_Solution;}
	int                                       GetInputUnitsPPassemblage(void) {return this->input_units_PPassemblage;}
	int                                       GetInputUnitsExchange(void) {return this->input_units_Exchange;}
	int                                       GetInputUnitsSurface(void) {return this->input_units_Surface;}
	int                                       GetInputUnitsGasPhase(void) {return this->input_units_GasPhase;}
	int                                       GetInputUnitsSSassemblage(void) {return this->input_units_SSassemblage;}
	int                                       GetInputUnitsKinetics(void) {return this->input_units_Kinetics;}
	int                                       GetIPhreeqcId(int i) {return (i > 0 && i < this->nthreads + 2) ? this->workers[i]->GetId() : -1;};
	const int                                 GetMpiMyself(void) const {return this->mpi_myself;}
	const int                                 GetMpiTasks(void) const {return this->mpi_tasks;}
	int                                       GetNthSelectedOutputUserNumber(int i);
	//const bool                                GetPartitionUZSolids(void) const {return this->partition_uz_solids;}
	std::vector<double> &                     GetPoreVolume(void) {return this->pore_volume;}
	std::vector<double> &                     GetPressure(void) {return this->pressure;}
	std::vector<int> &                        GetPrintChemistryMask (void) {return this->print_chem_mask;}
	const std::vector <bool> &                GetPrintChemistryOn(void) const {return this->print_chemistry_on;}  
	bool                                      GetRebalanceMethod(void) const {return this->rebalance_by_cell;}
	double                                    GetRebalanceFraction(void) const {return this->rebalance_fraction;}
	std::vector<double> &                     GetSaturation(void) {return this->saturation;}
	IRM_RESULT                                GetSelectedOutput(std::vector<double> &so);
	int                                       GetSelectedOutputColumnCount(void);
	int                                       GetSelectedOutputCount(void);
	IRM_RESULT                                GetSelectedOutputHeading(int icol, std::string &heading);
	const bool                                GetSelectedOutputOn(void) const {return this->selected_output_on;}
	int                                       GetSelectedOutputRowCount(void);	
	std::vector<double> &                     GetSolutionVolume(void); 
	IRM_RESULT                                GetSpeciesConcentrations(std::vector<double> & species_conc);
	int                                       GetSpeciesCount(void) {return (int) this->species_names.size();}
	const std::vector<double> &               GetSpeciesD25(void) {return this->species_d_25;}
	bool                                      GetSpeciesSaveOn(void) {return this->species_save_on;}
	const std::vector<double> &               GetSpeciesZ(void) {return this->species_z;}
	const std::vector<std::string> &          GetSpeciesNames(void) {return this->species_names;}
	const std::vector<cxxNameDouble> &        GetSpeciesStoichiometry(void) {return this->species_stoichiometry;}
	const std::vector < int> &                GetStartCell(void) const {return this->start_cell;} 
	std::vector<double> &                     GetTemperature(void) {return this->tempc;}
	int                                       GetThreadCount() {return this->nthreads;}
	double                                    GetTime(void) const {return this->time;} 
	double                                    GetTimeStep(void) const {return this->time_step;}
	const double                              GetTimeConversion(void) const {return this->time_conversion;} 
	std::vector<IPhreeqcPhast *> &            GetWorkers() {return this->workers;}

	// Setters 
	IRM_RESULT                                SetCellVolume(const std::vector<double> &t);
	IRM_RESULT                                SetComponentH2O(bool tf);
	IRM_RESULT                                SetConcentrations(const std::vector<double> &t); 
	IRM_RESULT								  SetCurrentSelectedOutputUserNumber(int i);
	IRM_RESULT                                SetDensity(double * t);
	IRM_RESULT                                SetDumpFileName(const char * db); 
	IRM_RESULT                                SetErrorHandlerMode(int i);
	IRM_RESULT                                SetFilePrefix(const char * prefix); 
	IRM_RESULT								  SetMpiWorker(int (*fcn)(int *method, void *cookie));
	IRM_RESULT								  SetMpiWorkerCallbackC(int (*fcn)(int *method, void * cookie));
	IRM_RESULT								  SetMpiWorkerCallbackCookie(void * cookie);
	IRM_RESULT								  SetMpiWorkerCallbackFortran(int (*fcn)(int *method));
	//IRM_RESULT                                SetPartitionUZSolids(int t = -1);
	IRM_RESULT                                SetPoreVolume(double * t); 
	IRM_RESULT                                SetPrintChemistryMask(int * t);
	IRM_RESULT                                SetPrintChemistryOn(bool worker, bool ip, bool utility);
	IRM_RESULT                                SetPressure(double * t);  
	IRM_RESULT                                SetRebalanceFraction(double t); 
	IRM_RESULT                                SetRebalanceByCell(bool t); 
	IRM_RESULT                                SetSaturation(double * t); 
	IRM_RESULT                                SetSelectedOutputOn(bool t);
	IRM_RESULT                                SetSpeciesSaveOn(bool tf);
	IRM_RESULT                                SetTemperature(double * t);
	IRM_RESULT                                SetTime(double t);
	IRM_RESULT                                SetTimeConversion(double t);
	IRM_RESULT                                SetTimeStep(double t);
	IRM_RESULT                                SetUnitsExchange(int i);
	IRM_RESULT                                SetUnitsGasPhase(int i);
	IRM_RESULT                                SetUnitsKinetics(int i);
	IRM_RESULT                                SetUnitsPPassemblage(int i);
	IRM_RESULT                                SetUnitsSolution(int i);
	IRM_RESULT                                SetUnitsSSassemblage(int i);
	IRM_RESULT                                SetUnitsSurface(int i);

	// Utilities
	static std::string                        Char2TrimString(const char * str, size_t l = 0);
	static bool                               FileExists(const std::string &name);
	static void                               FileRename(const std::string &temp_name, const std::string &name, 
		                                           const std::string &backup_name);
	static IRM_RESULT                         Int2IrmResult(int r, bool positive_ok);
	IRM_RESULT                                ReturnHandler(IRM_RESULT result, const std::string &e_string);
protected:
	IRM_RESULT                                CellInitialize(
		                                          int i, 
		                                          int n_user_new, 
		                                          int *initial_conditions1,
		                                          int *initial_conditions2, 
		                                          double *fraction1,
		                                          std::set<std::string> &error_set);
	int                                       CheckSelectedOutput();
	IPhreeqc *                                Concentrations2UtilityH2O(std::vector<double> &c_in, 
		                                           std::vector<double> t_in, std::vector<double> p_in);
	IPhreeqc *                                Concentrations2UtilityNoH2O(std::vector<double> &c_in, 
		                                           std::vector<double> t_in, std::vector<double> p_in);
	void                                      Concentrations2Solutions(int n, std::vector<double> &c);
	void                                      Concentrations2SolutionsH2O(int n, std::vector<double> &c);
	void                                      Concentrations2SolutionsNoH2O(int n, std::vector<double> &c);
	void                                      cxxSolution2concentration(cxxSolution * cxxsoln_ptr, std::vector<double> & d, double v);
	void                                      cxxSolution2concentrationH2O(cxxSolution * cxxsoln_ptr, std::vector<double> & d, double v);
	void                                      cxxSolution2concentrationNoH2O(cxxSolution * cxxsoln_ptr, std::vector<double> & d, double v);
	cxxStorageBin &                           Get_phreeqc_bin(void) {return this->phreeqc_bin;}
	int                                       HandleErrorsInternal(std::vector< int > & r);
	//void                                      PartitionUZ(int n, int iphrq, int ihst, double new_frac);
	void                                      RebalanceLoad(void);
	void                                      RebalanceLoadPerCell(void);
	IRM_RESULT                                RunCellsThread(int i);
	IRM_RESULT                                RunFileThread(int n);
	IRM_RESULT                                RunStringThread(int n, std::string & input); 
	IRM_RESULT                                RunCellsThreadNoPrint(int n);
	void                                      Scale_solids(int n, int iphrq, LDBLE frac);
	IRM_RESULT                                SetChemistryFileName(const char * prefix = NULL);
	IRM_RESULT                                SetDatabaseFileName(const char * db = NULL);
	void                                      SetEndCells(void);
	IRM_RESULT                                TransferCells(cxxStorageBin &t_bin, int old, int nnew);

private:
	IRM_RESULT                                SetGeneric(std::vector<double> &destination, int newSize, const std::vector<double> &origin, int mpiMethod, const std::string &name, const double newValue = 0.0);
protected:
	bool component_h2o;                      // true: use H2O, excess H, excess O, and charge; 
	                                         // false total H, total O, and charge
	std::string database_file_name;
	std::string chemistry_file_name;
	std::string dump_file_name;
	std::string file_prefix;
	//cxxStorageBin uz_bin;
	cxxStorageBin phreeqc_bin;
	int mpi_myself;
	int mpi_tasks;
	std::vector <std::string> components;	// list of components to be transported
	std::vector <double> gfw;				// gram formula weights converting mass to moles (1 for each component)
	double gfw_water;						// gfw of water
	//bool partition_uz_solids;
	int nxyz;								// number of nodes 
	int count_chemistry;					// number of cells for chemistry
	double time;						    // time from transport, sec 
	double time_step;					    // time step from transport, sec
	double time_conversion;					// time conversion factor, multiply to convert to preferred time unit for output
	//std::vector <double> old_saturation;	// saturation fraction from previous step
	std::vector<double> saturation;	        // nxyz saturation fraction
	std::vector<double> pressure;			// nxyz current pressure
	std::vector<double> pore_volume;		// nxyz current pore volumes 
	//std::vector<double> pore_volume_zero;	// nxyz initial pore volumes
	std::vector<double> cell_volume;		// nxyz geometric cell volumes
	std::vector<double> tempc;				// nxyz temperature Celsius
	std::vector<double> density;			// nxyz density
	std::vector<double> solution_volume;	// nxyz density
	std::vector<int> print_chem_mask;		// nxyz print flags for output file
	bool rebalance_by_cell;                 // rebalance method 0 std, 1 by_cell
	double rebalance_fraction;			    // parameter for rebalancing process load for parallel	
	int input_units_Solution;               // 1 mg/L, 2 mol/L, 3 kg/kgs
	int input_units_PPassemblage;           // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	int input_units_Exchange;               // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	int input_units_Surface;                // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	int input_units_GasPhase;               // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	int input_units_SSassemblage;           // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	int input_units_Kinetics;               // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	std::vector <int> forward_mapping;					// mapping from nxyz cells to count_chem chemistry cells
	std::vector <std::vector <int> > backward_mapping;	// mapping from count_chem chemistry cells to nxyz cells 

	// print flags
	std::vector<bool> print_chemistry_on;	// print flag for chemistry output file 
	bool selected_output_on;				// create selected output

	//bool stop_message;
	int error_count;
	int error_handler_mode;                 // 0, return code; 1, throw; 2 exit;

	// threading
	int nthreads;
	std::vector<IPhreeqcPhast *> workers;
	std::vector<int> start_cell;
	std::vector<int> end_cell;
	PHRQ_io phreeqcrm_io;

	// mpi 
	int phreeqcrm_comm;                                       // MPI communicator
	int (*mpi_worker_callback_fortran) (int *method);
	int (*mpi_worker_callback_c) (int *method, void *cookie);
	void *mpi_worker_callback_cookie;

	// mcd
	bool species_save_on;
	std::vector <std::string> species_names;
	std::vector <double> species_z;
	std::vector <double> species_d_25;
	std::vector <cxxNameDouble> species_stoichiometry;
	std::map<int, int> s_num2rm_species_num;

private:
	friend class RM_interface;
	static std::map<size_t, PhreeqcRM*> Instances;
	static size_t InstancesIndex;

};
#endif // !defined(PHREEQCRM_H_INCLUDED)
