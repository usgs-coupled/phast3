/*! @file PhreeqcRM.h
	@brief C/Fortran Documentation
*/
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
#include "IrmResult.h"
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

/**
Constructor for the PhreeqcRM reaction module. If the code is compiled with
the preprocessor directive USE_OPENMP, the reaction module is multithreaded.
If the code is compiled with the preprocessor directive USE_MPI, the reaction
module will use MPI and multiple processes. If neither preprocessor directive is used,
the reaction module will be serial (unparallelized). 
@param nxyz        The number of grid cells in the users model.
@param thread_count_or_communicator If multithreaded, the number of threads to use
in parallel segments of the code. 
If thread_count_or_communicator is <= 0, the number of threads is set equal to the number of processors of the computer.
If multiprocessor, the MPI communicator to use within the reaction module. 
@par C++ Example:
@htmlonly
<CODE>
<PRE>  		
int nxyz = 40;
#ifdef USE_MPI
  PhreeqcRM phreeqc_rm(nxyz, MPI_COMM_WORLD);
  int mpi_myself;
  if (MPI_Comm_rank(MPI_COMM_WORLD, &mpi_myself) != MPI_SUCCESS)
  {
    exit(4);
  }
  if (mpi_myself > 0)
  {
    phreeqc_rm.MpiWorker();
    return EXIT_SUCCESS;
  }
#else
  int nthreads = 3;
  PhreeqcRM phreeqc_rm(nxyz, nthreads);
#endif
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and all workers.
 */	
	PhreeqcRM(int nxyz, int thread_count_or_communicator, PHRQ_io * io=NULL);
	~PhreeqcRM(void);
/**
Close the output and log files. 
@retval IRM_RESULT   0 is success, negative is failure (See @ref DecodeError).  
@see                 @ref OpenFiles, @ref SetFilePrefix
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
status = phreeqc_rm.CloseFiles();
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called only by root.
 */	
	IRM_RESULT                                CloseFiles(void);
/**
N sets of component concentrations are converted to SOLUTIONs numbered 1-n in the Utility IPhreeqc.
The solutions can be reacted and manipulated with the methods of IPhreeqc. The motivation for this
method is the mixing of solutions in wells, where it may be necessary to calculate solution properties
(pH for example) or react the mixture to form scale minerals. The code fragment below makes a mixture of
concentrations and then calculate the pH of the mixture.
@param c             Vector of concentrations to be made SOLUTIONs in Utility IPhreeqc. 
Vector contains n values for each component (@ref GetComponentCount) in sequence. 
@param tc            Vector of temperatures to apply to the SOLUTIONs, in degrees C. Vector of size n. 
@param p_atm         Vector of pressures to apply to the SOLUTIONs, in atm. Vector of size n.
@retval IRM_RESULT   0 is success, negative is failure (See @ref DecodeError).  
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
std::vector <double> c_well;
c_well.resize(1*ncomps, 0.0);
for (int i = 0; i < ncomps; i++)
{
  c_well[i] = 0.5 * c[0 + nxyz*i] + 0.5 * c[9 + nxyz*i];
}
std::vector<double> tc, p_atm;
tc.resize(1, 15.0);
p_atm.resize(1, 3.0);
IPhreeqc * util_ptr = phreeqc_rm.Concentrations2Utility(c_well, tc, p_atm);
input = "SELECTED_OUTPUT 5; -pH;RUN_CELLS; -cells 1";
int iphreeqc_result;
util_ptr->SetOutputFileName("utility_cpp.txt");
util_ptr->SetOutputFileOn(true);
iphreeqc_result = util_ptr->RunString(input.c_str());
phreeqc_rm.ErrorHandler(iphreeqc_result, "IPhreeqc RunString failed");
int vtype;
double pH;
char svalue[100];
util_ptr->SetCurrentSelectedOutputUserNumber(5);
iphreeqc_result = util_ptr->GetSelectedOutputValue2(1, 0, &vtype, &pH, svalue, 100);
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called only by root.
 */
	IPhreeqc *                                Concentrations2Utility(std::vector<double> &c, 
		                                           std::vector<double> tc, std::vector<double> p_atm);
/**
Provides a mapping from grid cells in the user's model to cells for which chemistry needs to be run. 
The mapping is used to eliminate inactive cells and to use symmetry to decrease the number of cells 
for which chemistry must be run. The mapping may be many-to-one to account for symmetry.
Default is a one-to-one mapping--all user grid cells are chemistry cells 
(equivalent to grid2chem values of 0,1,2,3,...,nxyz-1).
@param grid2chem        A vector of integers: Nonnegative is a chemistry cell number (0 based), 
negative is an inactive cell. Vector is of size nxyz (number of grid cells).
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError). 
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
// For demonstation, two equivalent rows by symmetry
std::vector<int> grid2chem;
grid2chem.resize(nxyz, -1);
for (int i = 0; i < nxyz/2; i++)
{
  grid2chem[i] = i;
  grid2chem[i + nxyz/2] = i;
}
status = phreeqc_rm.CreateMapping(grid2chem);
if (status < 0) phreeqc_rm.DecodeError(status); 
int nchem = phreeqc_rm.GetChemistryCellCount();
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                CreateMapping(std::vector<int> &grid2chem);
/**
If result is negative, this method prints an error message corresponding to IRM_RESULT result. 
If result is non-negative, this method does nothing.
@param result               An IRM_RESULT value returned by one of the reaction-module methods.
@retval IRM_RESULT          0 is success, negative is failure. 
@par IRM_RESULT definition:
@htmlonly
<CODE>
<PRE>  
typedef enum {
  IRM_OK            =  0,  //Success
  IRM_OUTOFMEMORY   = -1,  //Failure, Out of memory 
  IRM_BADVARTYPE    = -2,  //Failure, Invalid VAR type 
  IRM_INVALIDARG    = -3,  //Failure, Invalid argument 
  IRM_INVALIDROW    = -4,  //Failure, Invalid row 
  IRM_INVALIDCOL    = -5,  //Failure, Invalid column 
  IRM_BADINSTANCE   = -6,  //Failure, Invalid rm instance id 
  IRM_FAIL          = -7,  //Failure, Unspecified 
} IRM_RESULT;
</PRE>
</CODE> 
@endhtmlonly
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
status = phreeqc_rm.CreateMapping(grid2chem);
if (status < 0) phreeqc_rm.DecodeError(status); 
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Can be called by root and (or) workers.
 */
	void                                      DecodeError(int result);
/**
Writes the contents of all workers to file in _RAW formats, including SOLUTIONs and all reactants.
@param dump_on          Signal for writing the dump file: 1 true, 0 false.
@param append           Signal to append to the contents of the dump file: 1 true, 0 false.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError). 
@see                    @ref SetDumpFileName
@par C++ Example:
@htmlonly
<CODE>
<PRE>  				
bool dump_on = true;
bool append = false;
status = phreeqc_rm.SetDumpFileName("advection_cpp.dmp");
status = phreeqc_rm.DumpModule(dump_on, append);
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root; workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                DumpModule(bool dump_on, bool append = false);
/**
Checks result for an error code. If result is negative, the result is decoded (@ref DecodeError), 
and printed as an error message along with the e_string, and an exception is thrown. If the result
is nonnegative, no action is taken and IRM_OK is returned.
@param result           IRM_RESULT to be checked for an error.
@param e_string         String to be printed if an error is found.
@see                    @ref ErrorMessage.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  				
iphreeqc_result = util_ptr->RunString(input.c_str());
if (iphreeqc_result != 0)
{
  phreeqc_rm.ErrorHandler(IRM_FAIL, "IPhreeqc RunString failed");
}
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	void                                      ErrorHandler(int result, const std::string &e_string);
/**
Send an error message to the screen, the output file, and the log file. 
@param error_string      String to be printed.
@param prepend           True, prepend with "Error: "; false, error_string is used intact.
@see                    @ref OpenFiles, @ref LogMessage, @ref ScreenMessage, @ref WarningMessage. 
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
phreeqc_rm.ErrorMessage("Goodby world");
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers; root writes to output and log files.
 */
	void                                      ErrorMessage(const std::string &error_string, bool prepend = true);
/**
Returns the number of items in the list of all elements in the InitialPhreeqc instance. 
Elements are those that have been defined in a solution or any other reactant 
(EQUILIBRIUM_PHASE, KINETICS, and others). 
The method can be called multiple times and the list that is created is cummulative. 
The list is the set of components that needs to be transported. By default the list 
includes total H and total O concentrations;
for numerical accuracy in transport, the list may be defined to include excess H and O 
(the H and O not contained in water) 
and the water concentration (@ref SetComponentH2O).
If multicomponent diffusion (MCD) is to be modeled, there is a capability to retrieve aqueous species concentrations
(@ref GetSpeciesConcentrations) and to set new solution concentrations after 
MCD from the individual species concentrations 
(@ref SpeciesConcentrations2Module). 
To use these methods the save-species property needs to be turned on (@ref SetSpeciesSaveOn).
If the save-species property is on, FindComponents will generate 
a list of aqueous species (@ref GetSpeciesCount, @ref GetSpeciesNames), their diffusion coefficients at 25 C (@ref GetSpeciesD25),
their charge (@ref GetSpeciesZ).
@retval              Number of components currently in the list, or IRM_RESULT error code (see @ref DecodeError).
@see                 @ref GetComponents, @ref SetSpeciesSaveOn, @ref GetSpeciesConcentrations, @ref SpeciesConcentrations2Module,
@ref GetSpeciesCount, @ref GetSpeciesNames, @ref GetSpeciesD25, @ref GetSpeciesZ, @ref SetComponentH2O.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
int ncomps = phreeqc_rm.FindComponents();
const std::vector<std::string> &components = phreeqc_rm.GetComponents();
const std::vector < double > & gfw = phreeqc_rm.GetGfw();
for (int i = 0; i < ncomps; i++)
{
  std::ostringstream strm;
  strm.width(10);
  strm << components[i] << "    " << gfw[i] << "\n";
  phreeqc_rm.OutputMessage(strm.str());
}
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	int                                       FindComponents();
/**
Returns a mapping for each chemistry cell number in the reaction module to grid cell numbers in the 
user grid. Each chemistry cell will map to one or more grid cells. 
@retval              Vector of vectors of ints. For each chemistry cell n, the nth vector in the vector of vectors contains
the user grid cell numbers that the chemistry cell maps to.
@see                 @ref CreateMapping, @ref GetForwardMapping.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
for (int j = 0; j < count_chemistry; j++)	
{
    // First grid cell in list for chemistry cell j
	int i = phreeqc_rm.GetBackwardMapping()[j][0]; 
}
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector < std::vector <int> > & GetBackwardMapping(void) {return this->backward_mapping;}
/**
Returns the current set of cell volumes as 
defined by the last use of @ref SetCellVolume or the default (1.0 L). 
Cell volume is used with pore volume (@ref SetPoreVolume) in calculating porosity. 
In most cases, cell volumes are expected to be constant.
@retval const std::vector<double>&       A vector reference to the cell volumes
defined to the reaction module by the last call to @ref SetCellVolume, or default 1.0. 
Size of vector is nxyz, the number of grid cells in the user's model (@ref GetGridCellCount).
@see                 @ref GetPoreVolume, @ref SetCellVolume, @ref SetPoreVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
const std::vector<double> & vol = phreeqc_rm.GetCellVolume(); 
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector<double> &               GetCellVolume(void) {return this->cell_volume;}
/**
Returns the number of chemistry cells in the reaction module. The number of chemistry cells is defined by 
the set of non-negative integers in the mapping from user grid cells (@ref CreateMapping), or, by default,
the number of grid cells (@ref GetGridCellCount). 
The number of chemistry cells is less than or equal to the number of grid cells in the user's model.
@retval              Number of chemistry cells, or IRM_RESULT error code (see @ref DecodeError).
@see                 @ref CreateMapping, @ref GetGridCellCount. 
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
status = phreeqc_rm.CreateMapping(grid2chem);
std::ostringstream oss;
oss << "Number of chemistry cells in the reaction module: " 
    << phreeqc_rm.GetChemistryCellCount() << "\n";
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetChemistryCellCount(void) const {return this->count_chemistry;}
/**
Returns the number of components in the reaction-module component list. 
@retval                 The number of components in the reaction-module component list. The component list is 
generated by calls to @ref FindComponents. 
The return value from the last call to @ref FindComponents is equal to the return value from GetComponentCount.
@see                    @ref FindComponents, @ref GetComponents.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
std::ostringstream oss;
oss << "Number of components for transport: " << phreeqc_rm.GetComponentCount() << "\n";
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
	int                                       GetComponentCount(void) const {return (int) this->components.size();}
/**
Returns a reference to the reaction-module component list that was generated by calls to @ref FindComponents.
@retval const std::vector<std::string>&       A vector of strings; each string is a component name.
@see                    @ref FindComponents, @ref GetComponentCount 
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
const std::vector<std::string> &components = phreeqc_rm.GetComponents();
const std::vector < double > & gfw = phreeqc_rm.GetGfw();
for (int i = 0; i < ncomps; i++)
{
  std::ostringstream strm;
  strm.width(10);
  strm << components[i] << "    " << gfw[i] << "\n";
  phreeqc_rm.OutputMessage(strm.str());
}
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector<std::string> &          GetComponents(void) const {return this->components;}
/**
Transfer solution concentrations from each reaction-module cell to the concentration array given in the argument list (c).
Units of concentration for c are defined by @ref SetUnitsSolution. For concentration units of per liter, the 
calculated solution volume is used to calculate the concentrations for c. Of the databases distributed with PhreeqcRM,
only phreeqc.dat, Amm.dat, and pitzer.dat have the partial molar volume definitions needed 
to accurately calculate solution volume. 
Mass fraction concentration units do not require the solution volume to fill the c array (but, density is needed to
convert transport concentrations to cell solution concentrations, @ref SetConcentrations).
@param c                Array to receive the concentrations. 
Dimension of the array is equivalent to Fortran (nxyz, ncomps), 
where nxyz is the number of user grid cells and ncomps is the result of 
@ref FindComponents or @ref GetComponentCount.  Values for inactive cells are set to 1e30.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError). 
@see                    @ref FindComponents, @ref GetComponentCount, @ref Concentrations2Module, @ref SetUnitsSolution
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
std::vector<double> c;
status = phreeqc_rm.RunCells();
status = phreeqc_rm.GetConcentrations(c);
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                GetConcentrations(std::vector<double> &c);
/**
Returns the file name of the database. Should be called after @ref LoadDatabase.
@retval std::string      The file name defined in @ref LoadDatabase. 
@see                    @ref LoadDatabase.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  	
std::ostringstream oss;
oss << "Database: " << phreeqc_rm.GetDatabaseFileName().c_str() << "\n";
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	std::string                               GetDatabaseFileName(void) {return this->database_file_name;}
/**
Transfer solution densities from the module workers to the density array given in the argument list. 
@param density              Vector to receive the densities. Dimension of the array is set to nxyz, 
where nxyz is the number of user grid cells. Values for inactive cells are set to 1e30. 
Densities are those calculated by the reaction module. 
Only the following databases distributed with PhreeqcRM have molar volume information needed 
to accurately calculate density: phreeqc.dat, Amm.dat, and pitzer.dat.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError). 
@see                    @ref GetSolutionVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
status = phreeqc_rm.RunCells();
status = phreeqc_rm.GetConcentrations(c);              
std::vector<double> density;
status = phreeqc_rm.GetDensity(density); 
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                GetDensity(std::vector<double> & density); 
/**
Each worker is assigned a range of chemistry cell numbers that are run by @ref RunCells. The range of
cells for a worker may vary as load rebalancing occurs. At any point in the calculations, the
first cell and last cell to be run by a worker can be found in the vectors returned by 
@ref GetStartCell and @ref GetEndCell.
Each method returns a vector of integers that has length of the number of threads (@ref GetThreadCount), 
if using OPENMP, or the number of processes (@ref GetMpiTasks), if using MPI.
@retval IRM_RESULT      Vector of integers, one for each worker, that gives the last chemistry cell 
to be run by each worker. 
@see                    @ref GetStartCell, @ref GetThreadCount, @ref GetMpiTasks.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
std::ostringstream oss;
oss << "Current distribution of cells for workers\n";
oss << "Worker First cell   Last Cell\n";
int n;
#ifdef USE_MPI
  n = phreeqc_rm.GetMpiTasks();
#else
  n = phreeqc_rm.GetThreadCount();
#endif
for (int i = 0; i < n; i++)
{
	oss << i << "      " 
	    << phreeqc_rm.GetStartCell()[i] 
	    << "            " 
		<< phreeqc_rm.GetEndCell()[i] << "\n";
}
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector < int> &                GetEndCell(void) const {return this->end_cell;}
/**
Get the setting for the action to be taken when the reaction module encounters and error.
Options are 0, return to calling program with an error return code; 
1, throw an exception, in C++, the exception can be caught, for C and Fortran, the program will exit; 
2, attempt to exit gracefully. Default is 0.
@retval IRM_RESULT      Current setting for the error handling mode: 0, 1, or 2.. 
@see                    @ref SetErrorHandlerMode.
@par C Example:
@htmlonly
<CODE>
<PRE> 
std::ostringstream oss;
oss << "Error handler mode: " << phreeqc_rm.GetErrorHandlerMode() << "\n";
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetErrorHandlerMode(void) {return this->error_handler_mode;}
/**
Returns the file prefix for the output (.chem.txt) and log files (.log.txt). 
@retval std::string     The file prefix as set by @ref SetFilePrefix, or "myrun", by default. 
@see                    @ref SetFilePrefix.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  	
std::ostringstream oss;
oss << "Database: " << phreeqc_rm.GetDatabaseFileName().c_str() << "\n";
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	std::string                               GetFilePrefix(void) {return this->file_prefix;}
/**
Returns a reference to a vector of ints that is a mapping from the user grid cells to the 
chemistry cells.  
The mapping is used to eliminate inactive cells and to use symmetry to decrease the number of cells 
for which chemistry must be run. The mapping may be many-to-one to account for symmetry.
The mapping is set by @ref CreateMapping, or default is a one-to-one mapping--all user grid cells are 
chemistry cells (vector contains 0,1,2,3,...,nxyz-1).     
@retval const std::vector < int >&      A vector of integers of size nxyz (number of grid cells @ref GetGridCellCount). 
Nonnegative is a chemistry cell number (0 based), negative is an inactive cell. 
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
const std::vector<int> &f_map = phreeqc_rm.GetForwardMapping();
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector < int > &               GetForwardMapping(void) {return this->forward_mapping;}
/**
Returns a reference to a vector of doubles that contains the gram-formula weights of 
each component. Called after @ref FindComponents. Order of weights is same as order of components from 
@ref GetComponents.
@retval const std::vector<double>&       A vector of doubles; each value is a component gram-formula weight, g/mol.
@see                    @ref FindComponents, @ref GetComponents.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
const std::vector<std::string> &components = phreeqc_rm.GetComponents();
const std::vector < double > & gfw = phreeqc_rm.GetGfw();
for (int i = 0; i < ncomps; i++)
{
  std::ostringstream strm;
  strm.width(10);
  strm << components[i] << "    " << gfw[i] << "\n";
  phreeqc_rm.OutputMessage(strm.str());
}
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector < double > &            GetGfw(void) {return this->gfw;}
/**
Returns the number of grid cells in the user's model, which is defined in 
the call to the constructor for the reaction module. 
The mapping from grid cells to chemistry cells is defined by @ref CreateMapping.
The number of chemistry cells may be less than the number of grid cells if 
there are inactive regions or symmetry in the model definition.
@retval                 Number of grid cells in the user's model.
@see                    @ref PhreeqcRM::PhreeqcRM ,  @ref CreateMapping.
@par C++ Example:
@htmlonly
<CODE>
<PRE> 
std::ostringstream oss;
oss << "Number of grid cells in the user's model: " << phreeqc_rm.GetGridCellCount() << "\n";
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetGridCellCount(void) {return this->nxyz;}
/**
Returns an IPhreeqc pointer to the ith IPhreeqc instance in the reaction module. 
The threaded version has nthreads, as defined in the constructor (@ref PhreeqcRM::PhreeqcRM).
The number of threads can be determined by @ref GetThreadCount.
There will be nthreads + 2 IPhreeqc instances. The first nthreads (0 based) will be the workers, the
next (nthreads) is the InitialPhreeqc instance, and the next (nthreads + 1) is the Utility instance. Getting
the IPhreeqc pointer for one of these allows the user to use any of the IPhreeqc methods
on that instance. For MPI, each process has three IPhreeqc instances, one worker (0), 
one InitialPhreeqc instance (1), and one Utility instance (2).
@param i                The number of the IPhreeqc instance (0 based) to be retrieved. 
@retval                 IPhreeqc pointer to the ith IPhreeqc instance (0 based) in the reaction module.
@see                    @ref PhreeqcRM::PhreeqcRM, @ref GetThreadCount, documentation for IPhreeqc.
@par C++ Example:
@htmlonly
<CODE>
<PRE> 	
// Utility pointer is worker nthreads + 1 
IPhreeqc * util_ptr1 = phreeqc_rm.GetIPhreeqcPointer(phreeqc_rm.GetThreadCount() + 1);
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	IPhreeqc *                                GetIPhreeqcPointer(int i) {return (i >= 0 && i < this->nthreads + 2) ? this->workers[i] : NULL;}
/**
Returns the MPI process (task) number. For the threaded version, the task number is always
zero, and the result of @ref GetMpiTasks is one. For the MPI version, 
the root task number is zero, and all workers have a task number greater than zero.
The number of tasks can be obtained with @ref GetMpiTasks. The number of 
tasks and computer hosts are determined at run time by the mpiexec command, and the
number of reaction-module processes is defined by the communicator used in
constructing the reaction modules (@ref PhreeqcRM::PhreeqcRM).
@retval                 The MPI task number for a process.
@see                    @ref GetMpiTasks.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::ostringstream oss;
oss << "MPI task number: " << phreeqc_rm.GetMpiMyself() << "\n";
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const int                                 GetMpiMyself(void) const {return this->mpi_myself;}
/**
Returns the number of MPI processes (tasks) assigned to the reaction module. 
For the threaded version, the number of tasks is always
one (although there may be multiple threads, @ref GetThreadCount), 
and the task number returned by @ref GetMpiMyself is zero.
For the MPI version, the number of 
tasks and computer hosts are determined at run time by the mpiexec command. An MPI communicator
is used in constructing reaction modules for MPI. The communicator may define a subset of the
total number of MPI processes. The root task number is zero, and all workers have a task number greater than zero.
@retval                 The number of MPI processes assigned to the reaction module.
@see                    @ref GetMpiMyself, @ref PhreeqcRM::PhreeqcRM.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::ostringstream oss;
oss << "Number of MPI processes: " << phreeqc_rm.GetMpiTasks() << "\n";
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const int                                 GetMpiTasks(void) const {return this->mpi_tasks;}
/**
Returns the user number for the nth selected-output definition. 
Definitions are sorted by user number. Phreeqc allows multiple selected-output
definitions, each of which is assigned a nonnegative integer identifier by the 
user. The number of definitions can be obtained by @ref GetSelectedOutputCount.
To cycle through all of the definitions, GetNthSelectedOutputUserNumber 
can be used to identify the user number for each selected-output definition
in sequence. @ref SetCurrentSelectedOutputUserNumber is then used to select
that user number for selected-output processing.
@param n                The sequence number of the selected-output definition for which the user number will be returned. 
Fortran, 1 based; C, 0 based.
@retval                 The user number of the nth selected-output definition, negative is failure (See @ref DecodeError).
@see                    @ref GetSelectedOutput, 
@ref GetSelectedOutputColumnCount, @ref GetSelectedOutputCount, 
@ref GetSelectedOutputHeading,
@ref GetSelectedOutputRowCount, @ref SetCurrentSelectedOutputUserNumber, @ref SetSelectedOutputOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>	
for (int isel = 0; isel < phreeqc_rm.GetSelectedOutputCount(); isel++)
{
  int n_user = phreeqc_rm.GetNthSelectedOutputUserNumber(isel);
  status = phreeqc_rm.SetCurrentSelectedOutputUserNumber(n_user);
  std::cerr << "Selected output sequence number: " << isel << "\n";
  std::cerr << "Selected output user number:     " << n_user << "\n";
  std::vector<double> so;
  int col = phreeqc_rm.GetSelectedOutputColumnCount();
  status = phreeqc_rm.GetSelectedOutput(so);
  // Process results here
}
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
	int                                       GetNthSelectedOutputUserNumber(int i);
	//const bool                                GetPartitionUZSolids(void) const {return this->partition_uz_solids;}
/**
Returns the current set of pore volumes as 
defined by the last use of @ref SetPoreVolume or the default (0.1 L). 
Pore volume is used with cell volume (@ref SetCellVolume) in calculating porosity. 
Pore volumes may change as a function of pressure, in which case they can be updated
with @ref SetPoreVolume.
@retval const std::vector<double>&       A vector reference to the pore volumes.
Size of vector is nxyz, the number of grid cells in the user's model (@ref GetGridCellCount).
@see                 @ref GetCellVolume, @ref SetCellVolume, @ref SetPoreVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
const std::vector<double> & vol = phreeqc_rm.GetPoreVolume(); 
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	std::vector<double> &                     GetPoreVolume(void) {return this->pore_volume;}
/**
Returns the current set of pressures as 
defined by the last use of @ref SetPressure or the default (1 atm). 
Pressure effects are considered by three PHREEQC databases: phreeqc.dat, Amm.dat, and pitzer.dat.
@retval const std::vector<double>&       A vector reference to the pressures in each cell, in atm.
Size of vector is nxyz, the number of grid cells in the user's model (@ref GetGridCellCount).
@see                 @ref SetPressure, @ref GetTemperature, @ref SetTemperature.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
const std::vector<double> & p_atm = phreeqc_rm.GetPressure(); 
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	std::vector<double> &                     GetPressure(void) {return this->pressure;}
/**
Return a reference to the vector of print flags that enable or disable detailed output for each cell. 
Printing will occur only when the
printing is enabled with @ref SetPrintChemistryOn, and the value in the vector for a cell is nonzero.       
@retval std::vector<int> &      Vector of integers. Size of vector is (nxyz), where nxyz is the number
of grid cells in the user's model (@ref GetGridCellCount). A value of zero for a cell indicates
printing for the cell is disabled; 
a nonzero value for a cell indicates printing for the cell is enabled.
@see                    @ref SetPrintChemistryOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
const std::vector<int> & print_chemistry_mask1 = phreeqc_rm.GetPrintChemistryMask();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector<int> &                  GetPrintChemistryMask (void) {return this->print_chem_mask;}
/**
Return a vector reference to the current print flags for detailed output for the three sets of IPhreeqc instances:
the workers, the InitialPhreeqc instance, and the Utility instance. Dimension of the vector is 3. 
Printing of detailed output from reaction calculations to the output file 
is enabled when the vector value is true, disabled when false.
The detailed output prints all of the output
typical of a PHREEQC reaction calculation, which includes solution descriptions and the compositions of
all other reactants. The output can be several hundred lines per cell, which can lead to a very
large output file (prefix.chem.txt, @ref OpenFiles). For the worker instances, 
the output can be limited to a set of cells
(@ref SetPrintChemistryMask) and, in general, the
amount of information printed can be limited by use of options in the PRINT data block of PHREEQC 
(applied by using @ref RM_RunFile or
@ref RM_RunString). Printing the detailed output for the workers is generally used only for debugging, 
and PhreeqcRM will run
significantly faster when printing detailed output for the workers is disabled (@ref SetPrintChemistryOn).
@retval const std::vector <bool> & Print flag for the workers, InitialPhreeqc, and Utility IPhreeqc instances, in order.      
@see                     @ref SetPrintChemistryOn, @ref SetPrintChemistryMask.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
const std::vector<bool> & print_on = phreeqc_rm.GetPrintChemistryOn();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector <bool> &                GetPrintChemistryOn(void) const {return this->print_chemistry_on;}  
/**
Get the load-rebalancing method used for parallel processing. 
PhreeqcRM attempts to rebalance the load of each thread or 
process such that each
thread or process takes the same amount of time to run its part of a @ref RunCells
calculation. Two algorithms are available: one accounts for cells that were not run 
because saturation was zero (true), and the other uses the average time 
to run all of the cells assigned to a process or thread (false), .
The methods are similar, and it is not clear that one is better than the other.
@retval bool           True indicates individual
cell run times are used in rebalancing (default); False, indicates average run times are used in rebalancing.
@see                    @ref GetRebalanceFraction, @ref SetRebalanceByCell, @ref SetRebalanceFraction.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
bool rebalance = phreeqc_rm.GetRebalanceByCell();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	bool                                      GetRebalanceByCell(void) const {return this->rebalance_by_cell;}
/**
Get the fraction used to determine the number of cells to transfer among threads or processes.
PhreeqcRM attempts to rebalance the load of each thread or process such that each
thread or process takes the same amount of time to run its part of a @ref RunCells
calculation. The rebalancing transfers cell calculations among threads or processes to
try to achieve an optimum balance. @ref SetRebalanceFraction
adjusts the calculated optimum number of cell transfers by a fraction from 0 to 1.0 to
determine the number of cell transfers that actually are made. A value of zero eliminates
load rebalancing. A value less than 1.0 is suggested to avoid possible oscillations,
where too many cells are transferred at one iteration, requiring reverse transfers at the next iteration.
Default is 0.5.
@retval int       Fraction used in rebalance, 0.0 to 1.0.
@see                    @ref GetRebalanceByCell, @ref SetRebalanceByCell, @ref SetRebalanceFraction.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
double f_rebalance = phreeqc_rm.GetRebalanceFraction();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	double                                    GetRebalanceFraction(void) const {return this->rebalance_fraction;}
/**
Get a vector reference to the current values of saturation for each cell. Saturation is a fraction ranging from 0 to 1.
Porosity is determined by the ratio of the pore volume (@ref SetPoreVolume)
to the cell volume (@ref SetCellVolume). The volume of water in a cell is the porosity times the saturation.
@retval std::vector<double> &      Vector of saturations, unitless. Size of vector is (nxyz), where nxyz is the number
of grid cells in the user's model (@ref GetGridCellCount).
@see                    @ref SetSaturation, GetPoreVolume, GetCellVolume, SetCellVolume, SetPoreVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
const std::vector<double> &  current_sat =  phreeqc_rm.GetSaturation();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector<double> &               GetSaturation(void) {return this->saturation;}
/**
Populates a vector with values from the current selected-output definition. @ref SetCurrentSelectedOutputUserNumber
determines which of the selected-output definitions is used to populate the vector.
@param so               A vector to contain the selected-output values. Size of the vector is set to col times nxyz,
where nxyz is the number of grid cells in the user's model (@ref GetGridCellCount), and col is the number of
columns in the selected-output definition (@ref GetSelectedOutputColumnCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref GetNthSelectedOutputUserNumber,
@ref GetSelectedOutputColumnCount, @ref GetSelectedOutputCount, @ref GetSelectedOutputHeading,
@ref GetSelectedOutputRowCount, @ref SetCurrentSelectedOutputUserNumber, @ref SetSelectedOutputOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
for (int isel = 0; isel < phreeqc_rm.GetSelectedOutputCount(); isel++)
{
  int n_user = phreeqc_rm.GetNthSelectedOutputUserNumber(isel);
  status = phreeqc_rm.SetCurrentSelectedOutputUserNumber(n_user);
  std::vector<double> so;
  int col = phreeqc_rm.GetSelectedOutputColumnCount();
  status = phreeqc_rm.GetSelectedOutput(so);
  // Process results here
}
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                GetSelectedOutput(std::vector<double> &so);
/**
Returns the number of columns in the current selected-output definition. @ref SetCurrentSelectedOutputUserNumber
determines which of the selected-output definitions is used.
@retval                 Number of columns in the current selected-output definition, negative is failure (See @ref DecodeError).
@see                    @ref GetNthSelectedOutputUserNumber, @ref GetSelectedOutput,
@ref GetSelectedOutputCount, @ref GetSelectedOutputHeading,
@ref GetSelectedOutputRowCount, @ref SetCurrentSelectedOutputUserNumber, @ref SetSelectedOutputOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
for (int isel = 0; isel < phreeqc_rm.GetSelectedOutputCount(); isel++)
{
  int n_user = phreeqc_rm.GetNthSelectedOutputUserNumber(isel);
  status = phreeqc_rm.SetCurrentSelectedOutputUserNumber(n_user);
  std::vector<double> so;
  int col = phreeqc_rm.GetSelectedOutputColumnCount();
  status = phreeqc_rm.GetSelectedOutput(so);
  // Print results
  for (int i = 0; i < phreeqc_rm.GetSelectedOutputRowCount()/2; i++)
  {
    std::vector<std::string> headings;
    headings.resize(col);
    std::cerr << "     Selected output: " << "\n";
    for (int j = 0; j < col; j++)
    {
      status = phreeqc_rm.GetSelectedOutputHeading(j, headings[j]);
      std::cerr << "          " << j << " " << headings[j] << ": " << so[j*nxyz + i] << "\n";
    }
  }
}
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	int                                       GetSelectedOutputColumnCount(void);
/**
Returns the number of selected-output definitions. @ref SetCurrentSelectedOutputUserNumber
determines which of the selected-output definitions is used.
@retval                 Number of selected-output definitions, negative is failure (See @ref DecodeError).
@see                    @ref GetNthSelectedOutputUserNumber, @ref GetSelectedOutput,
@ref GetSelectedOutputColumnCount, @ref GetSelectedOutputHeading,
@ref GetSelectedOutputRowCount, @ref SetCurrentSelectedOutputUserNumber, @ref SetSelectedOutputOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
for (int isel = 0; isel < phreeqc_rm.GetSelectedOutputCount(); isel++)
{
  int n_user = phreeqc_rm.GetNthSelectedOutputUserNumber(isel);
  status = phreeqc_rm.SetCurrentSelectedOutputUserNumber(n_user);
  std::vector<double> so;
  int col = phreeqc_rm.GetSelectedOutputColumnCount();
  status = phreeqc_rm.GetSelectedOutput(so);
  // Process results here
}
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	int                                       GetSelectedOutputCount(void);
/**
Returns a selected-output heading. The number of headings is determined by @ref GetSelectedOutputColumnCount.
@ref SetCurrentSelectedOutputUserNumber
determines which of the selected-output definitions is used.
@param icol             The sequence number of the heading to be retrieved, 0 based.
@param heading          A string to receive the heading.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref GetNthSelectedOutputUserNumber, @ref GetSelectedOutput,
@ref GetSelectedOutputColumnCount, @ref GetSelectedOutputCount,
@ref GetSelectedOutputRowCount, @ref SetCurrentSelectedOutputUserNumber, @ref SetSelectedOutputOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
for (int isel = 0; isel < phreeqc_rm.GetSelectedOutputCount(); isel++)
{
  int n_user = phreeqc_rm.GetNthSelectedOutputUserNumber(isel);
  status = phreeqc_rm.SetCurrentSelectedOutputUserNumber(n_user);
  std::vector<double> so;
  int col = phreeqc_rm.GetSelectedOutputColumnCount();
  status = phreeqc_rm.GetSelectedOutput(so);
  std::vector<std::string> headings;
  headings.resize(col);
  std::cerr << "     Selected output: " << "\n";
  for (int j = 0; j < col; j++)
  {
    status = phreeqc_rm.GetSelectedOutputHeading(j, headings[j]);
    std::cerr << "          " << j << " " << headings[j] << "\n";
  }
}
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	IRM_RESULT                                GetSelectedOutputHeading(int icol, std::string &heading);
/**
Returns the current value of the selected-output-on property. A value of true for this property indicates
that selected output data is being processed. A value of false 
indicates that selected output will not be retrieved for this time step, and processing the 
selected output is avoided, with some time savings. 
@retval bool      True, selected output is being processed; false, selected output is not being processed.
@see              @ref SetSelectedOutputOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
bool so_on = phreeqc_rm.GetSelectedOutputOn();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	bool                                      GetSelectedOutputOn(void) {return this->selected_output_on;}
/**
Returns the number of rows in the current selected-output definition. However, the method
is included only for convenience; the number of rows is always equal to the number of
grid cells in the user's model, and is equal to @ref GetGridCellCount.
@retval                 Number of rows in the current selected-output definition, negative is failure 
(See @ref DecodeError).
@see                    @ref GetNthSelectedOutputUserNumber, @ref GetSelectedOutput, @ref GetSelectedOutputColumnCount,
@ref GetSelectedOutputCount, @ref GetSelectedOutputHeading,
@ref SetCurrentSelectedOutputUserNumber, @ref SetSelectedOutputOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
for (int isel = 0; isel < phreeqc_rm.GetSelectedOutputCount(); isel++)
{
  int n_user = phreeqc_rm.GetNthSelectedOutputUserNumber(isel);
  status = phreeqc_rm.SetCurrentSelectedOutputUserNumber(n_user);
  std::vector<double> so;
  int col = phreeqc_rm.GetSelectedOutputColumnCount();
  status = phreeqc_rm.GetSelectedOutput(so);
  // Print results
  for (int i = 0; i < phreeqc_rm.GetSelectedOutputRowCount()/2; i++)
  {
    std::vector<std::string> headings;
    headings.resize(col);
    std::cerr << "     Selected output: " << "\n";
    for (int j = 0; j < col; j++)
    {
      status = phreeqc_rm.GetSelectedOutputHeading(j, headings[j]);
      std::cerr << "          " << j << " " << headings[j] << ": " << so[j*nxyz + i] << "\n";
    }
  }
}
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	int                                       GetSelectedOutputRowCount(void);	
/**
Return a vector reference to the current solution volumes. Dimension of the vector will be nxyz,
where nxyz is the number of user grid cells. Values for inactive cells are set to 1e30. 
Solution volumes are those calculated by the reaction module. Only the following databases distributed with PhreeqcRM have molar volume information 
needed to accurately calculate solution volume: phreeqc.dat, Amm.dat, and pitzer.dat.
@retval Vector reference to current solution volumes.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.RunCells();
const std::vector<double> &volume = phreeqc_rm.GetSolutionVolume(); 
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	const std::vector<double> &               GetSolutionVolume(void); 
/**
Transfer concentrations of aqueous species to the vector argument. This
method is intended for use with multicomponent-diffusion transport calculations.
The list of aqueous
species is determined by @ref FindComponents and includes all
aqueous species that can be made from the set of components.
Solution volumes used to calculate mol/L are calculated by the reaction module.
Only the following databases distributed with PhreeqcRM have molar volume information 
needed to accurately calculate solution volume: phreeqc.dat, Amm.dat, and pitzer.dat.
@param species_conc     Vector to receive the aqueous species concentrations. 
Dimension of the vector is set to nspecies times nxyz,
where nspecies is the number of aqueous species (@ref GetSpeciesCount),
and nxyz is the number of user grid cells (@ref GetGridCellCount).
Concentrations are moles per liter.
Values for inactive cells are set to 1e30.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref FindComponents, @ref GetSpeciesCount, @ref GetSpeciesD25, @ref GetSpeciesZ,
@ref GetSpeciesNames, @ref SpeciesConcentrations2Module, @ref GetSpeciesSaveOn, @ref SetSpeciesSaveOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetSpeciesSaveOn(true);
int ncomps = phreeqc_rm.FindComponents();
int npecies = phreeqc_rm.GetSpeciesCount();	
status = phreeqc_rm.RunCells();
std::vector<double> c;
status = phreeqc_rm.GetSpeciesConcentrations(c);	
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
	IRM_RESULT                                GetSpeciesConcentrations(std::vector<double> & species_conc);
/**
Returns the number of aqueous species used in the reaction module. This
method is intended for use with multicomponent-diffusion transport calculations.
The list of aqueous
species is determined by @ref FindComponents and includes all
aqueous species that can be made from the set of components.
@retval int      The number of aqueous species.
@see                    @ref FindComponents, @ref GetSpeciesConcentrations, @ref GetSpeciesD25, @ref GetSpeciesZ,
@ref GetSpeciesNames, @ref SpeciesConcentrations2Module, @ref GetSpeciesSaveOn, @ref SetSpeciesSaveOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetSpeciesSaveOn(true);
int ncomps = phreeqc_rm.FindComponents();
int npecies = phreeqc_rm.GetSpeciesCount();	
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetSpeciesCount(void) {return (int) this->species_names.size();}
/**
Returns a vector reference to diffusion coefficients at 25C for the set of aqueous species. This
method is intended for use with multicomponent-diffusion transport calculations.
Diffusion coefficients are defined in SOLUTION_SPECIES data blocks, normally in the database file.
Databases distributed with the reaction module that have diffusion coefficients defined are
phreeqc.dat, Amm.dat, and pitzer.dat.
@retval Vector reference to the diffusion coefficients at 25 C, m^2/s. Dimension of the vector is nspecies,
where nspecies is the number of aqueous species (@ref GetSpeciesCount).
@see                    @ref FindComponents, @ref GetSpeciesConcentrations, @ref GetSpeciesCount, @ref GetSpeciesZ,
@ref GetSpeciesNames, @ref SpeciesConcentrations2Module, @ref GetSpeciesSaveOn, @ref SetSpeciesSaveOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetSpeciesSaveOn(true);
int ncomps = phreeqc_rm.FindComponents();
int npecies = phreeqc_rm.GetSpeciesCount();
const std::vector < double > & species_d = phreeqc_rm.GetSpeciesD25();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector<double> &               GetSpeciesD25(void) {return this->species_d_25;}
/**
Returns a vector reference to the names of the aqueous species. This
method is intended for use with multicomponent-diffusion transport calculations.
The list of aqueous
species is determined by @ref FindComponents and includes all
aqueous species that can be made from the set of components.
@retval names      Vector of strings containing the names of the aqueous species. Dimension of the vector is nspecies,
where nspecies is the number of aqueous species (@ref GetSpeciesCount). 
@see                    @ref FindComponents, @ref GetSpeciesConcentrations, @ref GetSpeciesCount,
@ref GetSpeciesD25, @ref GetSpeciesZ,
@ref SpeciesConcentrations2Module, @ref GetSpeciesSaveOn, @ref SetSpeciesSaveOn.
@par C Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetSpeciesSaveOn(true);
int ncomps = phreeqc_rm.FindComponents();
int npecies = phreeqc_rm.GetSpeciesCount();
const std::vector<std::string> &species = phreeqc_rm.GetSpeciesNames();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector<std::string> &          GetSpeciesNames(void) {return this->species_names;}
/**
Returns the value of the species-save property.
This
method is intended for use with multicomponent-diffusion transport calculations.
By default, concentrations of aqueous species are not saved. Setting the species-save property to true allows
aqueous species concentrations to be retrieved
with @ref GetSpeciesConcentrations, and solution compositions to be set with
@ref SpeciesConcentrations2Module.
@retval True indicates solution species concentrations are saved and can be used for multicomponent-diffusion calculation; 
False indicates that solution species concentrations are not saved. 
@see                    @ref FindComponents, @ref GetSpeciesConcentrations, @ref GetSpeciesCount,
@ref GetSpeciesD25, @ref GetSpeciesSaveOn, @ref GetSpeciesZ,
@ref GetSpeciesNames, @ref SpeciesConcentrations2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetSpeciesSaveOn(true);
int ncomps = phreeqc_rm.FindComponents();
int npecies = phreeqc_rm.GetSpeciesCount();
bool species_on = phreeqc_rm.GetSpeciesSaveOn();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	bool                                      GetSpeciesSaveOn(void) {return this->species_save_on;}
/**
Returns a vector reference to the charge on each aqueous species. This
method is intended for use with multicomponent-diffusion transport calculations.
@retval Vector containing the charge on each aqueous species. Dimension of the vector is nspecies,
where nspecies is the number of aqueous species (@ref GetSpeciesCount).
@see                    @ref FindComponents, @ref GetSpeciesConcentrations, @ref GetSpeciesCount, @ref GetSpeciesZ,
@ref GetSpeciesNames, @ref SpeciesConcentrations2Module, @ref GetSpeciesSaveOn, @ref SetSpeciesSaveOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetSpeciesSaveOn(true);
int ncomps = phreeqc_rm.FindComponents();
int npecies = phreeqc_rm.GetSpeciesCount();
const std::vector < double > & species_z = phreeqc_rm.GetSpeciesZ();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector<double> &               GetSpeciesZ(void) {return this->species_z;}
/**
Returns a vector reference to the stoichiometry of each aqueous species. This
method is intended for use with multicomponent-diffusion transport calculations.
@retval Vector of cxxNameDouble instances (maps), that contain the component name and 
associated stoichiometric coefficient for each aqueous species.  Dimension of the vector is nspecies,
where nspecies is the number of aqueous species (@ref GetSpeciesCount).
@see                    @ref FindComponents, @ref GetSpeciesConcentrations, @ref GetSpeciesCount, @ref GetSpeciesD25,
@ref GetSpeciesNames, @ref SpeciesConcentrations2Module, @ref GetSpeciesSaveOn, @ref SetSpeciesSaveOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
const std::vector<std::string> &species = phreeqc_rm.GetSpeciesNames();
const std::vector < double > & species_z = phreeqc_rm.GetSpeciesZ();
const std::vector < double > & species_d = phreeqc_rm.GetSpeciesD25();
bool species_on = phreeqc_rm.GetSpeciesSaveOn();
int nspecies = phreeqc_rm.GetSpeciesCount();
for (int i = 0; i < nspecies; i++)
{
  std::ostringstream strm;
  strm << species[i] << "\n";
  strm << "    Charge: " << species_z[i] << std::endl;
  strm << "    Dw:     " << species_d[i] << std::endl;
  cxxNameDouble::const_iterator it = phreeqc_rm.GetSpeciesStoichiometry()[i].begin();
  for (; it != phreeqc_rm.GetSpeciesStoichiometry()[i].begin(); it++)
  {
    strm << "          " << it->first << "   " << it->second << "\n";
  }
  phreeqc_rm.OutputMessage(strm.str());
}
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector<cxxNameDouble> &        GetSpeciesStoichiometry(void) {return this->species_stoichiometry;}
/**
Each worker is assigned a range of chemistry cell numbers that are run by @ref RunCells. The range of
cells for a worker may vary as load rebalancing occurs. At any point in the calculations, the
first cell and last cell to be run by a worker can be found in the vectors returned by 
@ref GetStartCell and @ref GetEndCell.
Each method returns a vector of integers that has length of the number of threads (@ref GetThreadCount), 
if using OPENMP, or the number of processes (@ref GetMpiTasks), if using MPI.
@retval IRM_RESULT      Vector of integers, one for each worker, that gives the first chemistry cell 
to be run by each worker. 
@see                    @ref GetEndCell, @ref GetThreadCount, @ref GetMpiTasks.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
std::ostringstream oss;
oss << "Current distribution of cells for workers\n";
oss << "Worker First cell   Last Cell\n";
int n;
#ifdef USE_MPI
  n = phreeqc_rm.GetMpiTasks();
#else
  n = phreeqc_rm.GetThreadCount();
#endif
for (int i = 0; i < n; i++)
{
	oss << i << "      " 
	    << phreeqc_rm.GetStartCell()[i] 
	    << "            " 
		<< phreeqc_rm.GetEndCell()[i] << "\n";
}
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector < int> &                GetStartCell(void) const {return this->start_cell;} 
	std::vector<double> &                     GetTemperature(void) {return this->tempc;}
	int                                       GetThreadCount() {return this->nthreads;}
	double                                    GetTime(void) const {return this->time;} 
	double                                    GetTimeStep(void) const {return this->time_step;}
	const double                              GetTimeConversion(void) const {return this->time_conversion;} 
	int                                       GetUnitsExchange(void) {return this->units_Exchange;}
	int                                       GetUnitsGasPhase(void) {return this->units_GasPhase;}
	int                                       GetUnitsKinetics(void) {return this->units_Kinetics;}
	int                                       GetUnitsSolution(void) {return this->units_Solution;}
	int                                       GetUnitsPPassemblage(void) {return this->units_PPassemblage;}
	int                                       GetUnitsSSassemblage(void) {return this->units_SSassemblage;}
	int                                       GetUnitsSurface(void) {return this->units_Surface;}
	std::vector<IPhreeqcPhast *> &            GetWorkers() {return this->workers;}
	IRM_RESULT								  InitialPhreeqc2Concentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1,
													std::vector < int >    & boundary_solution2, 
													std::vector < double > & fraction1); 
	IRM_RESULT                                InitialPhreeqc2Concentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1);
	IRM_RESULT                                InitialPhreeqc2Module(
													std::vector < int >    & initial_conditions1);
	IRM_RESULT                                InitialPhreeqc2Module(
													std::vector < int >    & initial_conditions1,
													std::vector < int >    & initial_conditions2,	
													std::vector < double > & fraction1);
	IRM_RESULT								  InitialPhreeqc2SpeciesConcentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1,
													std::vector < int >    & boundary_solution2, 
													std::vector < double > & fraction1); 
	IRM_RESULT                                InitialPhreeqc2SpeciesConcentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1);
	IRM_RESULT                                InitialPhreeqcCell2Module(int i, const std::vector<int> &cell_numbers);
	IRM_RESULT                                LoadDatabase(const std::string &database);
	void                                      LogMessage(const std::string &str);
	int                                       MpiAbort();
	IRM_RESULT                                MpiWorker();
	IRM_RESULT                                MpiWorkerBreak();	
	IRM_RESULT                                OpenFiles(void);
	void                                      OutputMessage(const std::string &str);
	IRM_RESULT                                RunCells(void);
	IRM_RESULT                                RunFile(bool workers, bool initial_phreeqc, bool utility,  const std::string & chemistry_name);
	IRM_RESULT                                RunString(bool workers, bool initial_phreeqc, bool utility, const std::string & str);
	void                                      ScreenMessage(const std::string &str);
	IRM_RESULT                                SetCellVolume(const std::vector<double> &t);
	IRM_RESULT                                SetComponentH2O(bool tf);
	IRM_RESULT                                SetConcentrations(const std::vector<double> &t); 
	IRM_RESULT								  SetCurrentSelectedOutputUserNumber(int i);
	IRM_RESULT                                SetDensity(const std::vector<double> &t);
	IRM_RESULT                                SetDumpFileName(const std::string & db); 
	IRM_RESULT                                SetErrorHandlerMode(int i);
	IRM_RESULT                                SetFilePrefix(const std::string & prefix); 
	IRM_RESULT								  SetMpiWorker(int (*fcn)(int *method, void *cookie));
	IRM_RESULT								  SetMpiWorkerCallbackC(int (*fcn)(int *method, void * cookie));
	IRM_RESULT								  SetMpiWorkerCallbackCookie(void * cookie);
	IRM_RESULT								  SetMpiWorkerCallbackFortran(int (*fcn)(int *method));
	//IRM_RESULT                                SetPartitionUZSolids(int t = -1);
	IRM_RESULT                                SetPoreVolume(const std::vector<double> &t); 
	IRM_RESULT                                SetPrintChemistryMask(std::vector<int> & t);
	IRM_RESULT                                SetPrintChemistryOn(bool worker, bool ip, bool utility);
	IRM_RESULT                                SetPressure(const std::vector<double> &t);  
	IRM_RESULT                                SetRebalanceByCell(bool t); 
	IRM_RESULT                                SetRebalanceFraction(double t); 
	IRM_RESULT                                SetSaturation(const std::vector<double> &t); 
	IRM_RESULT                                SetSelectedOutputOn(bool t);
	IRM_RESULT                                SetSpeciesSaveOn(bool tf);
	IRM_RESULT                                SetTemperature(const std::vector<double> &t);
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
	IRM_RESULT								  SpeciesConcentrations2Module(std::vector<double> & species_conc); 
	void                                      WarningMessage(const std::string &str);
	
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
	int units_Solution;                     // 1 mg/L, 2 mol/L, 3 kg/kgs
	int units_PPassemblage;                 // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	int units_Exchange;                     // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	int units_Surface;                      // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	int units_GasPhase;                     // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	int units_SSassemblage;                 // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
	int units_Kinetics;                     // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
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
