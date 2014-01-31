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
/*! @brief Enumeration used to for MPI worker to determine method to call
*/
typedef enum {
	METHOD_CREATEMAPPING,
	METHOD_DUMPMODULE,
	METHOD_GETCONCENTRATIONS,
	METHOD_GETDENSITY,
	METHOD_GETSELECTEDOUTPUT,
	METHOD_GETSOLUTIONVOLUME,
	METHOD_INITIALPHREEQC2MODULE,
	METHOD_INITIALPHREEQCCELL2MODULE,
	METHOD_LOADDATABASE,
	METHOD_MPIWORKERBREAK,
	METHOD_RUNCELLS,
	METHOD_RUNFILE,
	METHOD_RUNSTRING,
	METHOD_SETCELLVOLUME,
	METHOD_SETCONCENTRATIONS,
	METHOD_SETDENSITY,
	METHOD_SETERRORHANDLERMODE,
	METHOD_SETFILEPREFIX,
	METHOD_SETPARTITIONUZSOLIDS,
	METHOD_SETPOREVOLUME,
	METHOD_SETPOREVOLUMEZERO,
	METHOD_SETPRESSURE,
	METHOD_SETPRINTCHEMISTRYON,
	METHOD_SETPRINTCHEMISTRYMASK,
	METHOD_SETREBALANCEBYCELL,
	METHOD_SETSATURATION,
	METHOD_SETSELECTEDOUTPUTON,
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
	METHOD_SETUNITSSURFACE
} MPI_METHOD;

class PhreeqcRM: public PHRQ_base
{
public:
	static void             CleanupReactionModuleInstances(void);
	static int              CreateReactionModule(int nxyz, int nthreads = -1);
	static IRM_RESULT       DestroyReactionModule(int n);
	static PhreeqcRM      * GetInstance(int n);

	PhreeqcRM(int nxyz = 0, int thread_count = -1, PHRQ_io * io=NULL);
	~PhreeqcRM(void);
	
	// Key methods	
	IRM_RESULT                                CloseFiles(void);
	IPhreeqc *                                Concentrations2Utility(std::vector<double> &c_in, 
		                                           std::vector<double> t_in, std::vector<double> p_in);
	IRM_RESULT                                CreateMapping(int *grid2chem = NULL);
	void                                      DecodeError(int r);
	IRM_RESULT                                DumpModule(bool dump_on = false, bool use_gz = false);
	void                                      ErrorMessage(const std::string &error_string, bool prepend = true);
	void                                      ErrorHandler(int result, const std::string &e_string);
	int                                       FindComponents();
	IRM_RESULT                                GetConcentrations(double * c = NULL);
	IRM_RESULT                                InitialPhreeqc2Concentrations( 
                                                   double *c,
                                                   int n_boundary, 
                                                   int dim, 
                                                   int *boundary_solution1,
                                                   int *boundary_solution2 = NULL,
                                                   double *boundary_fraction = NULL);
	IRM_RESULT                                InitialPhreeqc2Module(
                                                   int *initial_conditions1 = NULL,
                                                   int *initial_conditions2 = NULL,	
                                                   double *fraction1 = NULL);
	IRM_RESULT                                InitialPhreeqcCell2Module(int i, const std::vector<int> &cell_numbers);
	IRM_RESULT                                LoadDatabase(const char * database = NULL);
	void                                      LogMessage(const std::string &str);
	IRM_RESULT                                MpiWorker();
	IRM_RESULT                                MpiWorkerBreak();	
	IRM_RESULT                                OpenFiles(void);
	void                                      OutputMessage(const std::string &str);
	IRM_RESULT                                ReturnHandler(IRM_RESULT result, const std::string &e_string);
	IRM_RESULT                                RunFile(bool workers = false, bool initial_phreeqc = false, bool utility = false,  const char *chemistry_name = NULL);
	IRM_RESULT                                RunString(bool workers = false, bool initial_phreeqc = false, bool utility = false, const char *str = NULL);
	IRM_RESULT                                RunCells(void);
	void                                      ScreenMessage(const std::string &str);
	void                                      WarningMessage(const std::string &str);

	// Utilities
	static std::string                        Char2TrimString(const char * str, size_t l = 0);
	static bool                               FileExists(const std::string &name);
	static void                               FileRename(const std::string &temp_name, const std::string &name, 
		                                           const std::string &backup_name);
	static IRM_RESULT                         Int2IrmResult(int r, bool positive_ok);


	// TODO ///////////////////////////
	void                                      Convert_to_molal(double *c, int n, int dim);
	void                                      Write_bc_raw(int *solution_list, int * bc_solution_count, 
                                                  int * solution_number, 
                                                  const std::string &prefix);

	// Getters 
	const std::vector < std::vector <int> > & GetBack(void) {return this->back;}
	std::vector<double> &                     GetCellVolume(void) {return this->cell_volume;}
	const int                                 GetChemistryCellCount(void) const {return this->count_chemistry;}
	const std::vector<std::string> &          GetComponents(void) const {return this->components;}
	const std::string                         GetDatabaseFileName(void) const {return this->database_file_name;}
	std::vector<double> &                     GetDensity(void); 
	const std::vector < int> &                GetEndCell(void) const {return this->end_cell;}
	int                                       GetErrorHandlerMode(void) {return this->error_handler_mode;}
	const std::string                         GetFilePrefix(void) const {return this->file_prefix;}
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
	int                                       GetNThreads() {return this->nthreads;}
	int                                       GetNthSelectedOutputUserNumber(int *i);
	const bool                                GetPartitionUZSolids(void) const {return this->partition_uz_solids;}
	std::vector<double> &                     GetPoreVolume(void) {return this->pore_volume;}
	std::vector<double> &                     GetPoreVolumeZero(void) {return this->pore_volume_zero;} 
	std::vector<double> &                     GetPressure(void) {return this->pressure;}
	std::vector<int> &                        GetPrintChemistryMask (void) {return this->print_chem_mask;}
	const std::vector <bool> &                GetPrintChemistryOn(void) const {return this->print_chemistry_on;}  
	bool                                      GetRebalanceMethod(void) const {return this->rebalance_by_cell;}
	double                                    GetRebalanceFraction(void) const {return this->rebalance_fraction;}
	std::vector<double> &                     GetSaturation(void) {return this->saturation;}
	IRM_RESULT                                GetSelectedOutput(double *so = NULL);
	int                                       GetSelectedOutputColumnCount(void);
	int                                       GetSelectedOutputCount(void);
	IRM_RESULT                                GetSelectedOutputHeading(int *icol, std::string &heading);
	const bool                                GetSelectedOutputOn(void) const {return this->selected_output_on;}
	int                                       GetSelectedOutputRowCount(void);	
	std::vector<double> &                     GetSolutionVolume(void); 
	const std::vector < int> &                GetStartCell(void) const {return this->start_cell;} 
	//bool                                      GetStopMessage(void) const {return this->stop_message;}
	std::vector<double> &                     GetTemperature(void) {return this->tempc;}
	double                                    GetTime(void) const {return this->time;} 
	double                                    GetTimeStep(void) const {return this->time_step;}
	const double                              GetTimeConversion(void) const {return this->time_conversion;} 
	std::vector<IPhreeqcPhast *> &            GetWorkers() {return this->workers;}

	// Setters 
	IRM_RESULT                                SetConcentrations(double * t = NULL); 
	IRM_RESULT								  SetCurrentSelectedOutputUserNumber(int i = -1);
	IRM_RESULT                                SetCellVolume(double * t = NULL);
	IRM_RESULT                                SetDensity(double * t = NULL);
	IRM_RESULT                                SetDumpFileName(const char * db = NULL); 
	IRM_RESULT                                SetErrorHandlerMode(int i = 0); 
	IRM_RESULT                                SetExitOnError(bool t = true);
	//IRM_RESULT                                SetFilePrefix(std::string fn = ""); 
	IRM_RESULT                                SetFilePrefix(const char * prefix = NULL);
	IRM_RESULT                                SetPartitionUZSolids(int t = -1);
	IRM_RESULT                                SetPoreVolume(double * t = NULL); 
	IRM_RESULT                                SetPoreVolumeZero(double * t = NULL);
	IRM_RESULT                                SetPrintChemistryMask(int * t = NULL);
	IRM_RESULT                                SetPrintChemistryOn(bool worker = false, bool ip = false, bool utility = false);
	IRM_RESULT                                SetPressure(double * t = NULL);  
	IRM_RESULT                                SetRebalanceFraction(double t = 0.0); 
	IRM_RESULT                                SetRebalanceByCell(bool t = false); 
	IRM_RESULT                                SetSaturation(double * t = NULL); 
	IRM_RESULT                                SetSelectedOutputOn(bool t = false);
	//IRM_RESULT                                SetStopMessage(bool t = false); 
	IRM_RESULT                                SetTemperature(double * t = NULL);
	IRM_RESULT                                SetTime(double t = 0.0);
	IRM_RESULT                                SetTimeConversion(double t = 1.0);
	IRM_RESULT                                SetTimeStep(double t = 1.0);
	IRM_RESULT                                SetUnitsExchange(int i = 1);
	IRM_RESULT                                SetUnitsGasPhase(int i = 1);
	IRM_RESULT                                SetUnitsKinetics(int i = 1);
	IRM_RESULT                                SetUnitsPPassemblage(int i = 1);
	IRM_RESULT                                SetUnitsSolution(int i = 1);
	IRM_RESULT                                SetUnitsSSassemblage(int i = 1);
	IRM_RESULT                                SetUnitsSurface(int i = 1);
protected:
	void                                      BeginTimeStep(void);
	IRM_RESULT                                CellInitialize(
		                                          int i, 
		                                          int n_user_new, 
		                                          int *initial_conditions1,
		                                          int *initial_conditions2, 
		                                          double *fraction1,
		                                          std::set<std::string> &error_set);
	int                                       CheckSelectedOutput();
	void                                      Concentrations2Solutions(int n, std::vector<double> &c);
	void                                      cxxSolution2concentration(cxxSolution * cxxsoln_ptr, std::vector<double> & d, double v);
	cxxStorageBin &                           Get_phreeqc_bin(void) {return this->phreeqc_bin;}
	int                                       HandleErrorsInternal(std::vector< int > & r);
	void                                      PartitionUZ(int n, int iphrq, int ihst, double new_frac);
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

protected:
	std::string database_file_name;
	std::string chemistry_file_name;
	std::string dump_file_name;
	std::string file_prefix;
	cxxStorageBin uz_bin;
	cxxStorageBin phreeqc_bin;
	int mpi_myself;
	int mpi_tasks;
	std::vector <std::string> components;	// list of components to be transported
	std::vector <double> gfw;				// gram formula weights converting mass to moles (1 for each component)
	double gfw_water;						// gfw of water
	bool partition_uz_solids;
	int nxyz;								// number of nodes 
	int count_chemistry;					// number of cells for chemistry
	double time;						    // time from transport, sec 
	double time_step;					    // time step from transport, sec
	double time_conversion;					// time conversion factor, multiply to convert to preferred time unit for output
	std::vector <double> old_saturation;	// saturation fraction from previous step
	std::vector<double> saturation;	        // nxyz saturation fraction
	std::vector<double> pressure;			// nxyz current pressure
	std::vector<double> pore_volume;		// nxyz current pore volumes 
	std::vector<double> pore_volume_zero;	// nxyz initial pore volumes
	std::vector<double> cell_volume;		// nxyz geometric cell volumes
	std::vector<double> tempc;				// nxyz temperature Celsius
	std::vector<double> density;			// nxyz density
	std::vector<double> solution_volume;	// nxyz density
	std::vector<int> print_chem_mask;		// nxyz print flags for output file
	bool rebalance_by_cell;                 // rebalance method 0 std, 1 by_cell
	double rebalance_fraction;			    // parameter for rebalancing process load for parallel	
	int input_units_Solution;               // 1 mg/L, 2 mmol/L, 3 kg/kgs
	int input_units_PPassemblage;           // water 1, rock 2
	int input_units_Exchange;               // water 1, rock 2
	int input_units_Surface;                // water 1, rock 2
	int input_units_GasPhase;               // water 1, rock 2
	int input_units_SSassemblage;           // water 1, rock 2
	int input_units_Kinetics;               // water 1, rock 2
	std::vector <int> forward;				// mapping from nxyz cells to count_chem chemistry cells
	std::vector <std::vector <int> > back;	// mapping from count_chem chemistry cells to nxyz cells 

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

private:
	friend class RM_interface;
	static std::map<size_t, PhreeqcRM*> Instances;
	static size_t InstancesIndex;

};
#endif // !defined(PHREEQCRM_H_INCLUDED)
