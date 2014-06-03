/*! @file PhreeqcRM.h
	@brief C/Fortran Documentation
*/
#if !defined(PHREEQCRM_H_INCLUDED)
#define PHREEQCRM_H_INCLUDED
#ifdef USE_MPI
#include "mpi.h"
#define MP_TYPE MPI_Comm
#else
#define MP_TYPE int
#endif
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
	METHOD_SETPARTITIONUZSOLIDS,
	METHOD_SETPOREVOLUME,
	METHOD_SETPRESSURE,
	METHOD_SETPRINTCHEMISTRYON,
	METHOD_SETPRINTCHEMISTRYMASK,
	METHOD_SETREBALANCEBYCELL,
	METHOD_SETREBALANCEFRACTION,
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
	METHOD_SPECIESCONCENTRATIONS2MODULE,
	METHOD_USESOLUTIONDENSITYVOLUME
} MPI_METHOD;

class PhreeqcRM: public PHRQ_base
{
public:
	static void             CleanupReactionModuleInstances(void);
	static int              CreateReactionModule(int nxyz, MP_TYPE nthreads);
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
If @a thread_count_or_communicator is <= 0, the number of threads is set equal to the number of processors of the computer.
If multiprocessor, the MPI communicator to use within the reaction module. 
@param io        Optionally, a PHRQ_io input/output object can be provided to the constructor. By default
a PHRQ_io object is constructed to handle reading and writing files. 
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
	PhreeqcRM(int nxyz, MP_TYPE thread_count_or_communicator, PHRQ_io * io=NULL);
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
@a N sets of component concentrations are converted to SOLUTIONs numbered 1-@a n in the Utility IPhreeqc.
The solutions can be reacted and manipulated with the methods of IPhreeqc. If solution concentration units
(@ref SetUnitsSolution) is per liter, one liter of solution is created in the Utility instance; if solution
concentration units are mass fraction, one kilogram of solution is created in the Utility instance.
The motivation for this
method is the mixing of solutions in wells, where it may be necessary to calculate solution properties
(pH for example) or react the mixture to form scale minerals. 
The code fragment below makes a mixture of
concentrations and then calculates the pH of the mixture.
@param c             Vector of concentrations to be made SOLUTIONs in Utility IPhreeqc. 
Vector contains @a n values for each component (@ref GetComponentCount) in sequence. 
@param tc            Vector of temperatures to apply to the SOLUTIONs, in degrees C. Vector of size @a n. 
@param p_atm         Vector of pressures to apply to the SOLUTIONs, in atm. Vector of size @a n.
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
IPhreeqc * Concentrations2Utility(std::vector<double> &c, 
		   std::vector<double> tc, std::vector<double> p_atm);
/**
Provides a mapping from grid cells in the user's model to cells for which chemistry needs to be run. 
The mapping is used to eliminate inactive cells and to use symmetry to decrease the number of cells 
for which chemistry must be run. The mapping may be many-to-one to account for symmetry.
Default is a one-to-one mapping--all user grid cells are chemistry cells 
(equivalent to @a grid2chem values of 0,1,2,3,...,nxyz-1).
@param grid2chem        A vector of integers: Nonnegative is a chemistry cell number (0 based), 
negative is an inactive cell. Vector is of size @a nxyz (number of grid cells, @ref GetGridCellCount).
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
If @a result is negative, this method prints an error message corresponding to IRM_RESULT @a result. 
If @a result is non-negative, this method does nothing.
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
@param dump_on          Signal for writing the dump file, true or false.
@param append           Signal to append to the contents of the dump file, true or false.
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
Checks @a result for an error code. If result is negative, the result is decoded (@ref DecodeError), 
and printed as an error message along with the @a e_string, and an exception is thrown. If the result
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
@param prepend           True, prepend with "Error: "; false, @a error_string is used intact.
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
Elements are those that have been defined in a solution or any other reactant
(EQUILIBRIUM_PHASE, KINETICS, and others), including charge imbalance. 
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
@retval              Vector of vectors of ints. For each chemistry cell @a n, 
the nth vector in the vector of vectors contains
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
defined to the reaction module. 
Size of vector is @a nxyz, the number of grid cells in the user's model (@ref GetGridCellCount).
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
@retval              Number of chemistry cells.
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
Transfer solution concentrations from each reaction-module cell 
to the concentration vector given in the argument list (@a c).
Units of concentration for @a c are defined by @ref SetUnitsSolution. For concentration units of per liter, the 
solution volume is used to calculate the concentrations for @a c. 
For mass fraction concentration units, the solution mass is used to calculate concentrations for @a c.
Two options are available for the volume and mass of solution 
that are used in converting to transport concentrations: (1) the volume and mass of solution are
calculated by PHREEQC, or (2) the volume of solution is the product of porosity and saturation, 
and the mass of solution is volume times density as defined by @ref SetDensity. 
Which option is used is determined by @ref UseSolutionDensityVolume.
For option 1, the databases that have partial molar volume definitions needed 
to accurately calculate solution volume are
phreeqc.dat, Amm.dat, and pitzer.dat  
@param c                Vector to receive the concentrations. 
Dimension of the vector is set to @a ncomps times @a nxyz,
where,  ncomps is the result of @ref FindComponents or @ref GetComponentCount,
and @a nxyz is the number of user grid cells (@ref GetGridCellCount).  
Values for inactive cells are set to 1e30.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError). 
@see                    @ref FindComponents, @ref GetComponentCount, @ref SetConcentrations, 
@ref SetDensity, @ref SetUnitsSolution, @ref UseSolutionDensityVolume.
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
Transfer solution densities from the module workers to the vector given in the argument list (@a density). 
@param density              Vector to receive the densities. Dimension of the array is set to @a nxyz, 
where @a nxyz is the number of user grid cells (@ref GetGridCellCount). 
Values for inactive cells are set to 1e30. 
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
Get the setting for the action to be taken when the reaction module encounters an error.
Options are 0, return to calling program with an error return code (default); 
1, throw an exception, in C++, the exception can be caught, for C and Fortran, the program will exit; 
2, attempt to exit gracefully. 
@retval IRM_RESULT      Current setting for the error handling mode: 0, 1, or 2. 
@see                    @ref SetErrorHandlerMode.
@par C++ Example:
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
chemistry cells (vector contains 0,1,2,3,...,@a nxyz-1).     
@retval const std::vector < int >&      A vector of integers of size @a nxyz (number of grid cells, @ref GetGridCellCount). 
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
Returns a reference to a vector of doubles that contains the gram-formula weight of 
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
there are inactive regions or there is symmetry in the model definition.
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
The threaded version has @a nthreads, as defined in the constructor (@ref PhreeqcRM::PhreeqcRM).
The number of threads can be determined by @ref GetThreadCount.
There will be @a nthreads + 2 IPhreeqc instances. The first @a nthreads (0 based) instances will be the workers, the
next (nthreads) is the InitialPhreeqc instance, and the next (nthreads + 1) is the Utility instance. Getting
the IPhreeqc pointer for one of these allows the user to use any of the IPhreeqc methods
on that instance. For MPI, each process has exactly three IPhreeqc instances, one worker (0), 
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
Returns the MPI process (task) number. For the OPENMP version, the task number is always
zero, and the result of @ref GetMpiTasks is one. For the MPI version, 
the root task number is zero, and all workers have a unique task number greater than zero.
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
For the OPENMP version, the number of tasks is always
one (although there may be multiple threads, @ref GetThreadCount), 
and the task number returned by @ref GetMpiMyself is zero.
For the MPI version, the number of 
tasks and computer hosts are determined at run time by the mpiexec command. An MPI communicator
is used in constructing reaction modules for MPI. The communicator may define a subset of the
total number of MPI processes. The root task number is zero, and all workers have a unique task number greater than zero.
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
	int                                       GetNthSelectedOutputUserNumber(int n);
/**
Returns the setting for partitioning solids between the saturated and unsaturated 
parts of a partially saturated cell. The value has meaning only when saturations 
less than 1.0 are encountered. Unexpected results may
occur in partially saturated cells for models that try to account for a free surface, but 
consider only saturated-zone flow and transport. The partially saturated cells 
see a smaller volume of water, 
even though, physically, recharge water is percolating through these cells. 
It takes a longer time for reactions to occur in these cells than in cells 
that are fully saturated. By setting  @ref SetPartitionUZSolids to true, the
amounts of solids and gases are partioned according to the saturation. 
If a cell has a saturation of 0.5, then
the water interacts with only half of the solids and gases; the other half is unreactive
until the water table rises. As the saturation in a cell varies, 
solids and gases are transferred between the
saturated and unsaturated (unreactive) reservoirs of the cell. 
Unsaturated-zone flow and transport codes will probably use the default (false), 
which assumes all gases and solids are reactive regardless of saturation.  
@retval bool       @a True, the fraction of solids and gases available for 
reaction is equal to the saturation; 
@a False (default), all solids and gases are reactive regardless of saturation.
@see                @ref SetPartitionUZSolids.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
oss << "Partioning of UZ solids: " << phreeqc_rm.GetPartitionUZSolids(); 
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const bool                                GetPartitionUZSolids(void) const {return this->partition_uz_solids;}
/**
Returns the current set of pore volumes as 
defined by the last use of @ref SetPoreVolume or the default (0.1 L). 
Pore volume is used with cell volume (@ref SetCellVolume) in calculating porosity. 
Pore volumes may change as a function of pressure, in which case they can be updated
with @ref SetPoreVolume.
@retval const std::vector<double>&       A vector reference to the pore volumes.
Size of vector is @a nxyz, the number of grid cells in the user's model (@ref GetGridCellCount).
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
defined by the last use of @ref SetPressure. 
By default, the pressure vector is initialized with 1 atm; 
however, if @ref SetPressure has not been called, worker solutions will have pressures as defined in  
input files (@ref RunFile) or input strings (@ref RunString). If @ref SetPressure has been called,
worker solutions will have the pressures as defined by @ref SetPressure.
Pressure effects are considered by three PHREEQC databases: phreeqc.dat, Amm.dat, and pitzer.dat.
@retval const std::vector<double>&       A vector reference to the pressures in each cell, in atm.
Size of vector is @a nxyz, the number of grid cells in the user's model (@ref GetGridCellCount).
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
printing is enabled with @ref SetPrintChemistryOn, and the value in the vector for a cell is 1.       
@retval std::vector<int> &      Vector of integers. Size of vector is @a nxyz, where @a nxyz is the number
of grid cells in the user's model (@ref GetGridCellCount). A value of 0 for a cell indicates
printing for the cell is disabled; 
a value of 1 for a cell indicates printing for the cell is enabled.
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
(applied by using @ref RunFile or
@ref RunString). Printing the detailed output for the workers is generally used only for debugging, 
and PhreeqcRM will run
significantly faster when printing detailed output for the workers is disabled (@ref SetPrintChemistryOn).
@retval const std::vector<bool> & Print flag for the workers, InitialPhreeqc, and Utility IPhreeqc instances, in order.      
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
@retval bool           @a True indicates individual
cell run times are used in rebalancing (default); @a False, indicates average run times are used in rebalancing.
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
Vector reference to the current values of saturation for each cell. 
Saturation is a fraction ranging from 0 to 1, default values are 1.0.
Porosity is determined by the ratio of the pore volume (@ref SetPoreVolume)
to the cell volume (@ref SetCellVolume). 
The volume of water in a cell is the porosity times the saturation.
@retval std::vector<double> &      Vector of saturations, unitless. Size of vector is @a nxyz, where @a nxyz is the number
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
@param so               A vector to contain the selected-output values. 
Size of the vector is set to @a col times @a nxyz, where @a col is the number of
columns in the selected-output definition (@ref GetSelectedOutputColumnCount),
and @a nxyz is the number of grid cells in the user's model (@ref GetGridCellCount).
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
Returns the number of columns in the current selected-output definition. 
@ref SetCurrentSelectedOutputUserNumber determines which of the selected-output definitions is used.
@retval                 Number of columns in the current selected-output definition, 
negative is failure (See @ref DecodeError).
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
Returns the number of selected-output definitions. 
@ref SetCurrentSelectedOutputUserNumber determines which of the selected-output definitions is used.
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
Returns a selected-output heading. 
The number of headings is determined by @ref GetSelectedOutputColumnCount.
@ref SetCurrentSelectedOutputUserNumber determines which of the selected-output definitions is used.
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
Returns the current value of the selected-output property. 
A value of true for this property indicates that selected output data is being processed. 
A value of false indicates that selected output will not be retrieved for this time step, 
and processing the selected output is avoided, with some time savings. 
@retval bool      @a True, selected output is being processed; @a false, selected output is not being processed.
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
grid cells in the user's model (@ref GetGridCellCount).
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
Return a vector reference to the current solution volumes. 
Dimension of the vector will be @a nxyz, where @a nxyz is the number of user grid cells. 
Values for inactive cells are set to 1e30. 
Solution volumes are those calculated by the reaction module. 
Only the following databases distributed with PhreeqcRM have molar volume information 
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
Transfer concentrations of aqueous species to the vector argument (@a species_conc). 
This method is intended for use with multicomponent-diffusion transport calculations, 
and @ref SetSpeciesSaveOn must be set to @a true.
The list of aqueous species is determined by @ref FindComponents and includes all
aqueous species that can be made from the set of components.
Solution volumes used to calculate mol/L are calculated by the reaction module.
Only the following databases distributed with PhreeqcRM have molar volume information 
needed to accurately calculate solution volume: phreeqc.dat, Amm.dat, and pitzer.dat.
@param species_conc     Vector to receive the aqueous species concentrations. 
Dimension of the vector is set to @a nspecies times @a nxyz,
where @a nspecies is the number of aqueous species (@ref GetSpeciesCount),
and @a nxyz is the number of user grid cells (@ref GetGridCellCount).
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
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                GetSpeciesConcentrations(std::vector<double> & species_conc);
/**
Returns the number of aqueous species used in the reaction module. 
This method is intended for use with multicomponent-diffusion transport calculations, 
and @ref SetSpeciesSaveOn must be set to @a true.
The list of aqueous species is determined by @ref FindComponents and includes all
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
Returns a vector reference to diffusion coefficients at 25C for the set of aqueous species. 
This method is intended for use with multicomponent-diffusion transport calculations, 
and @ref SetSpeciesSaveOn must be set to @a true.
Diffusion coefficients are defined in SOLUTION_SPECIES data blocks, normally in the database file.
Databases distributed with the reaction module that have diffusion coefficients defined are
phreeqc.dat, Amm.dat, and pitzer.dat.
@retval Vector reference to the diffusion coefficients at 25 C, m^2/s. Dimension of the vector is @a nspecies,
where @a nspecies is the number of aqueous species (@ref GetSpeciesCount).
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
Returns a vector reference to the names of the aqueous species. 
This method is intended for use with multicomponent-diffusion transport calculations, 
and @ref SetSpeciesSaveOn must be set to @a true.
The list of aqueous species is determined by @ref FindComponents and includes all
aqueous species that can be made from the set of components.
@retval names      Vector of strings containing the names of the aqueous species. Dimension of the vector is @a nspecies,
where @a nspecies is the number of aqueous species (@ref GetSpeciesCount). 
@see                    @ref FindComponents, @ref GetSpeciesConcentrations, @ref GetSpeciesCount,
@ref GetSpeciesD25, @ref GetSpeciesZ,
@ref SpeciesConcentrations2Module, @ref GetSpeciesSaveOn, @ref SetSpeciesSaveOn.
@par C++ Example:
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
By default, concentrations of aqueous species are not saved. Setting the species-save property to true allows
aqueous species concentrations to be retrieved
with @ref GetSpeciesConcentrations, and solution compositions to be set with
@ref SpeciesConcentrations2Module.
@retval @a True indicates solution species concentrations are saved and can be used for multicomponent-diffusion calculation; 
@a False indicates that solution species concentrations are not saved. 
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
Returns a vector reference to the charge on each aqueous species. 
This method is intended for use with multicomponent-diffusion transport calculations, 
and @ref SetSpeciesSaveOn must be set to @a true.
@retval Vector containing the charge on each aqueous species. Dimension of the vector is @a nspecies,
where @a nspecies is the number of aqueous species (@ref GetSpeciesCount).
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
Returns a vector reference to the stoichiometry of each aqueous species. 
This method is intended for use with multicomponent-diffusion transport calculations, 
and @ref SetSpeciesSaveOn must be set to @a true.
@retval Vector of cxxNameDouble instances (maps), that contain the component names and 
associated stoichiometric coefficients for each aqueous species.  Dimension of the vector is @a nspecies,
where @a nspecies is the number of aqueous species (@ref GetSpeciesCount).
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
Each method returns a vector of integers that has size of the number of threads (@ref GetThreadCount), 
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
/**
Vector reference to the temperatures set by the last call to @ref SetTemperature. 
By default, the temperature vector is initialized with 25 C; 
however, if @ref SetTemperature has not been called, worker solutions will have temperatures as defined in  
input files (@ref RunFile) or input strings (@ref RunString). If @ref SetTemperature has been called,
worker solutions will have the temperatures as defined by @ref SetTemperature.
@retval Vector of temperatures, in degrees C. Size of vector is @a nxyz, where @a nxyz is the number
of grid cells in the user's model (@ref GetGridCellCount).
@see                    @ref SetTemperature, @ref GetPressure, @ref SetPressure.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
const std::vector<double> &  tempc = phreeqc_rm.GetTemperature();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector<double> &               GetTemperature(void) {return this->tempc;}
/**
Returns the number of threads, which is equal to the number of workers used to run in parallel with OPENMP.
For the OPENMP version, the number of threads is set implicitly or explicitly 
with the constructor (@ref PhreeqcRM::PhreeqcRM). 
For the MPI version, the number of threads is always one for each process.
@retval                 The number of threads used for OPENMP parallel processing.
@see                    @ref GetMpiTasks.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::ostringstream oss;
oss << "Number of threads: " << phreeqc_rm.GetThreadCount() << "\n";
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers; result is always 1.
 */
	int                                       GetThreadCount() {return this->nthreads;}
/**
Returns the current simulation time in seconds. 
The reaction module does not change the time value, so the
returned value is equal to the default (0.0) or the last time set by @ref SetTime.
@retval                 The current simulation time, in seconds.
@see                    @ref GetTimeConversion, @ref GetTimeStep, @ref SetTime,
@ref SetTimeConversion, @ref SetTimeStep.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::ostringstream strm;
strm << "Beginning transport calculation " 
     << phreeqc_rm.GetTime() * phreeqc_rm.GetTimeConversion() 
	 << " days\n";
phreeqc_rm.LogMessage(strm.str());
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	double                                    GetTime(void) const {return this->time;} 
/**
Returns a multiplier to convert time from seconds to another unit, as specified by the user.
The reaction module uses seconds as the time unit. The user can set a conversion
factor (@ref SetTimeConversion) and retrieve it with GetTimeConversion. 
The reaction module only uses the conversion factor when printing the long version
of cell chemistry (@ref SetPrintChemistryOn), which is rare. 
Default conversion factor is 1.0.
@retval                 Multiplier to convert seconds to another time unit.
@see                    @ref GetTime, @ref GetTimeStep, @ref SetTime, @ref SetTimeConversion, @ref SetTimeStep.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::ostringstream strm;
strm << "Beginning transport calculation " 
     <<   phreeqc_rm.GetTime() * phreeqc_rm.GetTimeConversion() 
	 << " days\n";
phreeqc_rm.LogMessage(strm.str());
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	double                                    GetTimeConversion(void) {return this->time_conversion;}
/**
Returns the current simulation time step in seconds.
This is the time over which kinetic reactions are integrated in a call to @ref RunCells.
The reaction module does not change the time step value, so the
returned value is equal to the default (0.0) or the last time step set by @ref SetTimeStep.
@retval                 The current simulation time step, in seconds.
@see                    @ref GetTime, @ref GetTimeConversion, @ref SetTime,
@ref SetTimeConversion, @ref SetTimeStep.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::ostringstream strm;
strm << "Time step " 
     << phreeqc_rm.GetTimeStep() * phreeqc_rm.GetTimeConversion() 
	 << " days\n";
phreeqc_rm.LogMessage(strm.str());
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	double                                    GetTimeStep(void) {return this->time_step;} 
/**
Returns the input units for exchangers.
In PHREEQC, exchangers are defined by
moles of exchange sites. SetUnitsExchange determines whether the
number of sites applies to the volume of the cell, the volume of
water in the cell, or the volume of rock in the cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).
@retval                 Input units for exchangers.
@see                    @ref SetUnitsExchange, @ref SetCellVolume, @ref SetPoreVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
int units_exchange = phreeqc_rm.GetUnitsExchange();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetUnitsExchange(void) {return this->units_Exchange;}
/**
Returns the input units for gas phases.
In PHREEQC, gas phases are defined by
moles of component gases. GetUnitsGasPhase determines whether the
number of moles applies to the volume of the cell, the volume of
water in the cell, or the volume of rock in the cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).
@retval                 Input units for gas phases.
@see                    @ref SetUnitsGasPhase, @ref SetCellVolume, @ref SetPoreVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
int units_gas_phase = phreeqc_rm.GetUnitsGasPhase();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetUnitsGasPhase(void) {return this->units_GasPhase;}
/**
Returns the input units for kinetic reactants.
In PHREEQC, kinetics are defined by
moles of kinetic reactant. GetUnitsKinetics determines whether the
number of moles applies to the volume of the cell, the volume of
water in the cell, or the volume of rock in the cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).
@retval                 Input units for kinetic reactants.
@see                    @ref SetUnitsKinetics, @ref SetCellVolume, @ref SetPoreVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
int units_kinetics = phreeqc_rm.GetUnitsKinetics();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetUnitsKinetics(void) {return this->units_Kinetics;}
/**
Returns the input units for pure phase assemblages (equilibrium phases).
In PHREEQC, equilibrium phases are defined by
moles of each phase. GetUnitsPPassemblage determines whether the
number of moles applies to the volume of the cell, the volume of
water in the cell, or the volume of rock in the cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).
@retval                 Input units for equilibrium phases.
@see                    @ref SetUnitsPPassemblage, @ref SetCellVolume, @ref SetPoreVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
int units_pp_assemblage = phreeqc_rm.GetUnitsPPassemblage();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetUnitsPPassemblage(void) {return this->units_PPassemblage;}
/**
Returns the units of concentration used by the transport model.
Options are 1, mg/L; 2 mol/L; or 3, mass fraction, kg/kgs.
In PHREEQC, solutions are defined by the number of moles of each
element in the solution. The units of transport concentration are used when 
transport concentrations are converted to
solution moles by @ref SetConcentrations and @ref Concentrations2Utility. 
The units of solution concentration also are used when solution moles are converted to 
transport concentrations by 
@ref GetConcentrations.
@n@n
To convert from mg/L to moles
of element in a cell, mg/L is converted to mol/L and
multiplied by the solution volume,
which is porosity (@ref SetCellVolume, @ref SetPoreVolume)
times saturation (@ref SetSaturation).
To convert from mol/L to moles
of element in a cell, mol/L is
multiplied by the solution volume,
which is porosity (@ref SetCellVolume, @ref SetPoreVolume)
times saturation (@ref SetSaturation).
To convert from mass fraction to moles
of element in a cell, kg/kgs is converted to mol/kgs, multiplied by density
(@ref SetDensity) and
multiplied by the solution volume,
which is porosity (@ref SetCellVolume, @ref SetPoreVolume)
times saturation (@ref SetSaturation).
@n@n
To convert from moles
of element in a cell to mg/L, the number of moles of an element is divided by the
solution volume resulting in mol/L, and then converted to
mg/L.
To convert from moles
of element in a cell to mol/L,  the number of moles of an element is divided by the
solution volume resulting in mol/L.
To convert from moles
of element in a cell to mass fraction, the number of moles of an element is converted to kg and divided
by the total mass of the solution.
Two options are available for the volume and mass of solution 
that are used in converting to transport concentrations: (1) the volume and mass of solution are
calculated by PHREEQC, or (2) the volume of solution is the product of porosity and saturation, 
and the mass of solution is volume times density as defined by @ref SetDensity. 
Which option is used is determined by @ref UseSolutionDensityVolume.
@retval                 Units for concentrations in transport.
@see                    @ref SetUnitsSolution, @ref SetCellVolume, @ref SetDensity, 
@ref SetPoreVolume, @ref UseSolutionDensityVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
int units_solution = phreeqc_rm.GetUnitsSolution();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetUnitsSolution(void) {return this->units_Solution;}
/**
Returns the input units for solid-solution assemblages.
In PHREEQC, solid solutions are defined by
moles of each component. GetUnitsSSassemblage determines whether the
number of moles applies to the volume of the cell, the volume of
water in the cell, or the volume of rock in the cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).
@retval                 Input units for solid solutions.
@see                    @ref SetUnitsSSassemblage, @ref SetCellVolume, @ref SetPoreVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
int units_ss_exchange = phreeqc_rm.GetUnitsSSassemblage();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetUnitsSSassemblage(void) {return this->units_SSassemblage;}
/**
Returns the input units for surfaces.
In PHREEQC, surfaces are defined by
moles of each surface sites. GetUnitsSurface determines whether the
number of moles applies to the volume of the cell, the volume of
water in the cell, or the volume of rock in the cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).
@retval                 Input units for solid surfaces.
@see                    @ref SetUnitsSurface, @ref SetCellVolume, @ref SetPoreVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
int units_surface = phreeqc_rm.GetUnitsSurface();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	int                                       GetUnitsSurface(void) {return this->units_Surface;}
/**
Returns a reference to the vector of IPhreeqcPhast instances. IPhreeqcPhast
inherits from IPhreeqc, and the vector can be interpreted as a vector of pointers to the worker,
InitialPhreeqc, and Utility IPhreeqc instances. For OPENMP, there are @a nthreads
workers, where @a nthreads is defined in the constructor (@ref PhreeqcRM::PhreeqcRM).
For MPI, there is a single worker. For OPENMP and MPI, there is one InitialPhreeqc and
one Utility instance.
@retval                 Vector of IPhreeqcPhast instances.
@see                    @ref PhreeqcRM::PhreeqcRM.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
IPhreeqc * utility_ptr = phreeqc_rm.GetIPhreeqcInstances()[phreeqc_rm.GetThreadCount() + 1];
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	const std::vector<IPhreeqcPhast *> &      GetWorkers() {return this->workers;}
/**
Fills a vector (@a destination_c) with concentrations from solutions in the InitialPhreeqc instance.
The method is used to obtain concentrations for boundary conditions. If a negative value
is used for a cell in @a boundary_solution1, then the highest numbered solution in the InitialPhreeqc instance
will be used for that cell. 
@param destination_c       Vector to receive the concentrations.The dimension of @a destination_c is set to @a ncomps times @a n_boundary,
where @a ncomps is the number of components returned from @ref FindComponents or @ref GetComponentCount, and @a n_boundary
is the dimension of the vector @a boundary_solution1.
@param boundary_solution1  Vector of solution index numbers that refer to solutions in the InitialPhreeqc instance.
Size is @a n_boundary.
@retval IRM_RESULT         0 is success, negative is failure (See @ref DecodeError).
@see                  @ref FindComponents, @ref GetComponentCount.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> bc_conc;
std::vector<int> bc1;
int nbound = 1;
bc1.resize(nbound, 0);                      // solution 0 from InitialIPhreeqc instance
status = phreeqc_rm.InitialPhreeqc2Concentrations(bc_conc, bc1);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	IRM_RESULT                                InitialPhreeqc2Concentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1);
/**
Fills a vector (@a destination_c) with concentrations from solutions in the InitialPhreeqc instance.
The method is used to obtain concentrations for boundary conditions. If a negative value
is used for a cell in @a boundary_solution1, then the highest numbered solution in the InitialPhreeqc instance
will be used for that cell. Concentrations may be a mixture of two
solutions, @a boundary_solution1 and @a boundary_solution2, with a mixing fraction for @a boundary_solution1 of
@a fraction1 and mixing fraction for @a boundary_solution2 of (1 - @a fraction1).
A negative value for @a boundary_solution2 implies no mixing, and the associated value for @a fraction1 is ignored.
@param destination_c       Vector of concentrations extracted from the InitialPhreeqc instance.
The dimension of @a destination_c is set to @a ncomps times @a n_boundary,
where @a ncomps is the number of components returned from @ref FindComponents or @ref GetComponentCount, and @a n_boundary
is the dimension of the vectors @a boundary_solution1, @a boundary_solution2, and @a fraction1.
@param boundary_solution1  Vector of solution index numbers that refer to solutions in the InitialPhreeqc instance.
Size is @a n_boundary.
@param boundary_solution2  Vector of solution index numbers that that refer to solutions in the InitialPhreeqc instance
and are defined to mix with @a boundary_solution1.
Size is @a n_boundary.
@param fraction1           Fraction of boundary_solution1 that mixes with (1 - @a fraction1) of @a boundary_solution2.
Size is @a n_boundary.
@retval IRM_RESULT         0 is success, negative is failure (See @ref DecodeError).
@see                  @ref FindComponents, @ref GetComponentCount.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> bc_conc, bc_f1;
std::vector<int> bc1, bc2;
int nbound = 1;
bc1.resize(nbound, 0);                      // solution 0 from InitialIPhreeqc instance
bc2.resize(nbound, -1);                     // no bc2 solution for mixing
bc_f1.resize(nbound, 1.0);                  // mixing fraction for bc1
status = phreeqc_rm.InitialPhreeqc2Concentrations(bc_conc, bc1, bc2, bc_f1);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	IRM_RESULT								  InitialPhreeqc2Concentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1,
													std::vector < int >    & boundary_solution2, 
													std::vector < double > & fraction1); 
/**
Transfer solutions and reactants from the InitialPhreeqc instance to the reaction-module workers.
@a Initial_conditions1 is used to select initial conditions, including solutions and reactants,
for each cell of the model, without mixing.
@a Initial_conditions1 is dimensioned 7 times @a nxyz, where @a nxyz is the number of grid cells in the user's model
(@ref GetGridCellCount). The dimension of 7 refers to solutions and reactants in the following order:
(0) SOLUTIONS, (1) EQUILIBRIUM_PHASES, (2) EXCHANGE, (3) SURFACE, (4) GAS_PHASE,
(5) SOLID_SOLUTIONS, and (6) KINETICS. 
The definition initial_solution1[3*nxyz + 99] = 2, indicates that 
cell 99 (0 based) contains the SURFACE definition (index 3) defined by SURFACE 2 in the InitialPhreeqc instance
(either by @ref RunFile or @ref RunString).
@param initial_conditions1 Vector of solution and reactant index numbers that refer to 
definitions in the InitialPhreeqc instance.
Size is 7 times @a nxyz. The order of definitions is given above.
Negative values are ignored, resulting in no definition of that entity for that cell.
@retval IRM_RESULT          0 is success, negative is failure (See @ref DecodeError).
@see                        @ref InitialPhreeqcCell2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<int> ic1;
ic1.resize(nxyz*7, -1);
for (int i = 0; i < nxyz; i++)
{
  ic1[i] = 1;              // Solution 1
  ic1[nxyz + i] = -1;      // Equilibrium phases none
  ic1[2*nxyz + i] = 1;     // Exchange 1
  ic1[3*nxyz + i] = -1;    // Surface none
  ic1[4*nxyz + i] = -1;    // Gas phase none
  ic1[5*nxyz + i] = -1;    // Solid solutions none
  ic1[6*nxyz + i] = -1;    // Kinetics none
}
status = phreeqc_rm.InitialPhreeqc2Module(ic1); 
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                InitialPhreeqc2Module(
													std::vector < int >    & initial_conditions1);
/**
Transfer solutions and reactants from the InitialPhreeqc instance to the reaction-module workers, possibly with mixing.
In its simplest form, @a  initial_conditions1 is used to select initial conditions, including solutions and reactants,
for each cell of the model, without mixing.
@a Initial_conditions1 is dimensioned 7 times @a  nxyz, where @a  nxyz is the number of grid cells in the user's model
(@ref GetGridCellCount). The dimension of 7 refers to solutions and reactants in the following order:
(0) SOLUTIONS, (1) EQUILIBRIUM_PHASES, (2) EXCHANGE, (3) SURFACE, (4) GAS_PHASE,
(5) SOLID_SOLUTIONS, and (6) KINETICS. 
The definition initial_solution1[3*nxyz + 99] = 2, indicates that 
cell 99 (0 based) contains the SURFACE definition (index 3) defined by SURFACE 2 in the InitialPhreeqc instance
(either by @ref RunFile or @ref RunString).
@n@n
It is also possible to mix solutions and reactants to obtain the initial conditions for cells. For mixing,
@a initials_conditions2 contains numbers for a second entity that mixes with the entity defined in @a initial_conditions1.
@a Fraction1 contains the mixing fraction for @a initial_conditions1, 
whereas (1 - @a fraction1) is the mixing fraction for @a initial_conditions2.
The definitions initial_solution1[3*nxyz + 99] = 2, initial_solution2[3*nxyz + 99] = 3,
fraction1[3*nxyz + 99] = 0.25 indicates that
cell 99 (0 based) contains a mixtrue of 0.25 SURFACE 2 and 0.75 SURFACE 3, 
where the surface compositions have been defined in the InitialPhreeqc instance. 
If the user number in @a initial_conditions2 is negative, no mixing occurs.
@param initial_conditions1 Vector of solution and reactant index numbers that refer to 
definitions in the InitialPhreeqc instance.
Size is 7 times @a nxyz, where @a nxyz is the number of grid cells in the user's model (@ref GetGridCellCount). 
The order of definitions is given above.
Negative values are ignored, resulting in no definition of that entity for that cell.
@param initial_conditions2  Vector of solution and reactant index numbers that refer to 
definitions in the InitialPhreeqc instance.
Nonnegative values of @a initial_conditions2 result in mixing with the entities defined in @a initial_conditions1.
Negative values result in no mixing.
Size is 7 times @a nxyz. The order of definitions is given above.
@param fraction1           Fraction of @a initial_conditions1 that mixes with (1 - @a fraction1) 
of @a initial_conditions2.
Size is 7 times @a nxyz. The order of definitions is given above.
@retval IRM_RESULT          0 is success, negative is failure (See @ref DecodeError).
@see                        @ref InitialPhreeqcCell2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<int> ic1, ic2;
ic1.resize(nxyz*7, -1);
ic2.resize(nxyz*7, -1);
std::vector<double> f1;
f1.resize(nxyz*7, 1.0);
for (int i = 0; i < nxyz; i++)
{
  ic1[i] = 1;              // Solution 1
  ic1[nxyz + i] = -1;      // Equilibrium phases none
  ic1[2*nxyz + i] = 1;     // Exchange 1
  ic1[3*nxyz + i] = -1;    // Surface none
  ic1[4*nxyz + i] = -1;    // Gas phase none
  ic1[5*nxyz + i] = -1;    // Solid solutions none
  ic1[6*nxyz + i] = -1;    // Kinetics none
}
status = phreeqc_rm.InitialPhreeqc2Module(ic1, ic2, f1); 
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                InitialPhreeqc2Module(
													std::vector < int >    & initial_conditions1,
													std::vector < int >    & initial_conditions2,	
													std::vector < double > & fraction1);
/**
Fills a vector @a destination_c with aqueous species concentrations from solutions in the InitialPhreeqc instance.
This method is intended for use with multicomponent-diffusion transport calculations, 
and @ref SetSpeciesSaveOn must be set to @a true.
The method is used to obtain aqueous species concentrations for boundary conditions. If a negative value
is used for a cell in @a boundary_solution1, then the highest numbered solution in the InitialPhreeqc instance
will be used for that cell.
@param destination_c           Vector of aqueous concentrations extracted from the InitialPhreeqc instance.
The dimension of @a species_c is @a nspecies times @a n_boundary,
where @a nspecies is the number of aqueous species returned from @ref GetSpeciesCount, 
and @a n_boundary is the dimension of @a boundary_solution1.
@param boundary_solution1  Vector of solution index numbers that refer to solutions in the InitialPhreeqc instance.
@retval IRM_RESULT         0 is success, negative is failure (See @ref DecodeError).
@see                  @ref FindComponents, @ref GetSpeciesCount, @ref SetSpeciesSaveOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> bc_conc, bc_f1;
std::vector<int> bc1, bc2;
int nbound = 1;
bc1.resize(nbound, 0);                      // solution 0 from Initial IPhreeqc instance
bc2.resize(nbound, -1);                     // no bc2 solution for mixing
bc_f1.resize(nbound, 1.0);                  // mixing fraction for bc1
status = phreeqc_rm.InitialPhreeqc2SpeciesConcentrations(bc_conc, bc1);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	IRM_RESULT                                InitialPhreeqc2SpeciesConcentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1);
/**
Fills a vector @a destination_c with aqueous species concentrations from solutions in the InitialPhreeqc instance.
This method is intended for use with multicomponent-diffusion transport calculations, 
and @ref SetSpeciesSaveOn must be set to @a true.
The method is used to obtain aqueous species concentrations for boundary conditions. If a negative value
is used for a cell in @a boundary_solution1, then the highest numbered solution in the InitialPhreeqc instance
will be used for that cell.
Concentrations may be a mixture of two
solutions, @a boundary_solution1 and @a boundary_solution2, with a mixing fraction for @a boundary_solution1 of
@a fraction1 and mixing fraction for @a boundary_solution2 of (1 - @a fraction1).
A negative value for @a boundary_solution2 implies no mixing, and the associated value for @a fraction1 is ignored.
@param destination_c           Vector of aqueous concentrations extracted from the InitialPhreeqc instance.
The dimension of @a species_c is @a nspecies times @a n_boundary,
where @a nspecies is the number of aqueous species returned from @ref GetSpeciesCount, and @a n_boundary is the dimension
of @a boundary_solution1.
@param boundary_solution1  Vector of solution index numbers that refer to solutions in the InitialPhreeqc instance.
@param boundary_solution2  Vector of solution index numbers that that refer to solutions in the InitialPhreeqc instance
and are defined to mix with @a boundary_solution1. Size is same as @a boundary_solution1.
@param fraction1           Vector of fractions of @a boundary_solution1 that mix with (1 - @a fraction1) of @a boundary_solution2.
Size is same as @a boundary_solution1.
@retval IRM_RESULT         0 is success, negative is failure (See @ref DecodeError).
@see                  @ref FindComponents, @ref GetSpeciesCount, @ref SetSpeciesSaveOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> bc_conc, bc_f1;
std::vector<int> bc1, bc2;
int nbound = 1;
bc1.resize(nbound, 0);                      // solution 0 from Initial IPhreeqc instance
bc2.resize(nbound, -1);                     // no bc2 solution for mixing
bc_f1.resize(nbound, 1.0);                  // mixing fraction for bc1
status = phreeqc_rm.InitialPhreeqc2SpeciesConcentrations(bc_conc, bc1);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	IRM_RESULT								  InitialPhreeqc2SpeciesConcentrations(
													std::vector < double > & destination_c, 
													std::vector < int >    & boundary_solution1,
													std::vector < int >    & boundary_solution2, 
													std::vector < double > & fraction1); 
/**
A cell numbered @a n in the InitialPhreeqc instance is selected to populate a series of cells 
in the reaction-module workers.
All reactants with the number @a n are transferred along with the solution.
If MIX @a n exists, it is used for the definition of the solution.
If @a n is negative, @a n is redefined to be the largest solution or MIX number in the InitialPhreeqc instance.
All reactants for each cell in the list @a cell_numbers are removed before the cell
definition is copied from the InitialPhreeqc instance to the workers.
@param n                  Cell number refers to a solution or MIX and associated reactants in the InitialPhreeqc instance.
@param cell_numbers       A vector of module cell numbers in the user's grid-cell numbering system that 
will be populated with cell @a n from the InitialPhreeqc instance.
@retval IRM_RESULT        0 is success, negative is failure (See @ref DecodeError).
@see                      @ref InitialPhreeqc2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<int> module_cells;
module_cells.push_back(18);
module_cells.push_back(19);
status = phreeqc_rm.InitialPhreeqcCell2Module(-1, module_cells);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                InitialPhreeqcCell2Module(int n, const std::vector<int> &cell_numbers);
/**
Load a database for all IPhreeqc instances--workers, InitialPhreeqc, and Utility. All definitions
of the reaction module are cleared (SOLUTION_SPECIES, PHASES, SOLUTIONs, etc.), and the database is read.
@param database         String containing the database name.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.LoadDatabase("phreeqc.dat");
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                LoadDatabase(const std::string &database);
/**
Print a message to the log file.
@param str              String to be printed.
@see                    @ref OpenFiles, @ref ErrorMessage, @ref OutputMessage, @ref ScreenMessage, @ref WarningMessage.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::ostringstream strm;
strm << "Beginning transport calculation " <<   phreeqc_rm.GetTime() * phreeqc_rm.GetTimeConversion() << " days\n";
strm << "          Time step             " <<   phreeqc_rm.GetTimeStep() * phreeqc_rm.GetTimeConversion() << " days\n";
phreeqc_rm.LogMessage(strm.str());
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	void                                      LogMessage(const std::string &str);
/**
MPI only. Calls MPI_Abort, which aborts MPI, and makes the reaction module unusable. 
Should be used only on encountering an unrecoverable error.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
int status = phreeqc_rm.MPI_Abort();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root or workers.
 */
	int                                       MpiAbort();
/**
MPI only. Workers (processes with @ref GetMpiMyself > 0) must call MpiWorker to be able to
respond to messages from the root to accept data, perform calculations,
or return data within the reaction module. 
MpiWorker contains a loop that reads a message from root, performs a
task, and waits for another message from root. 
@ref SetConcentrations, @ref RunCells, and @ref GetConcentrations
are examples of methods that send a message from root to get the workers to perform a task. 
The workers will respond to all methods that are designated "workers must be in the loop of RM_MpiWorker" 
in the MPI section of the method documentation.
The workers will continue to respond to messages from root until root calls
@ref MpiWorkerBreak.
@n@n
(Advanced) The list of tasks that the workers perform can be extended by using @ref SetMpiWorkerCallbackC.
It is then possible to use the MPI processes to perform other developer-defined tasks, 
such as transport calculations, without exiting from the MpiWorker loop. 
Alternatively, root calls @ref MpiWorkerBreak to allow the workers to continue past a call to RM_MpiWorker. 
The workers perform developer-defined calculations, and then MpiWorker is called again to respond to
requests from root to perform reaction-module tasks.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError). 
MpiWorker returns a value only when @ref MpiWorkerBreak is called by root.
@see                    @ref MpiWorkerBreak, @ref SetMpiWorkerCallbackC, @ref SetMpiWorkerCallbackCookie (C only).
@par C++ Example:
@htmlonly
<CODE>
<PRE>
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
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by all workers.
 */
	IRM_RESULT                                MpiWorker();
/**
MPI only. This method is called by root to force workers (processes with @ref GetMpiMyself > 0) 
to return from a call to @ref MpiWorker.
@ref MpiWorker contains a loop that reads a message from root, performs a
task, and waits for another message from root. The workers respond to all methods that are designated
"workers must be in the loop of MpiWorker" in the
MPI section of the method documentation.
The workers will continue to respond to messages from root until root calls MpiWorkerBreak.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref MpiWorker, @ref SetMpiWorkerCallbackC, @ref SetMpiWorkerCallbackCookie (C only).
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.MpiWorkerBreak();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	IRM_RESULT                                MpiWorkerBreak();	
/**
Opens the output and log files. Files are named prefix.chem.txt and prefix.log.txt 
based on the prefix defined by @ref SetFilePrefix.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetFilePrefix, @ref GetFilePrefix, @ref CloseFiles, 
@ref ErrorMessage, @ref LogMessage, @ref OutputMessage, @ref WarningMessage.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetFilePrefix("Advect_cpp");
phreeqc_rm.OpenFiles();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	IRM_RESULT                                OpenFiles(void);
/**
Print a message to the output file.
@param str              String to be printed.
@see                    @ref ErrorMessage, @ref LogMessage, @ref ScreenMessage, @ref WarningMessage.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::ostringstream oss;
oss << "Database:                                         " << phreeqc_rm.GetDatabaseFileName().c_str() << "\n";
oss << "Number of threads:                                " << phreeqc_rm.GetThreadCount() << "\n";
oss << "Number of MPI processes:                          " << phreeqc_rm.GetMpiTasks() << "\n";
oss << "MPI task number:                                  " << phreeqc_rm.GetMpiMyself() << "\n";
oss << "File prefix:                                      " << phreeqc_rm.GetFilePrefix() << "\n";
oss << "Number of grid cells in the user's model:         " << phreeqc_rm.GetGridCellCount() << "\n";
oss << "Number of chemistry cells in the reaction module: " << phreeqc_rm.GetChemistryCellCount() << "\n";
oss << "Number of components for transport:               " << phreeqc_rm.GetComponentCount() << "\n";
oss << "Error handler mode:                               " << phreeqc_rm.GetErrorHandlerMode() << "\n";
phreeqc_rm.OutputMessage(oss.str());
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	void                                      OutputMessage(const std::string &str);
/**
Runs a reaction step for all of the cells in the reaction module.
The current set of concentrations of the components (@ref SetConcentrations) is used
in the calculations. The length of time over which kinetic reactions are integrated is set
by @ref SetTimeStep. Other properties that may need to be updated as a result of the transport
calculations include pore volume, saturation, temperature, and pressure.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetConcentrations,  @ref SetPoreVolume,
@ref SetTemperature, @ref SetPressure, @ref SetSaturation, @ref SetTimeStep.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetSelectedOutputOn(print_selected_output_on); 
status = phreeqc_rm.SetPrintChemistryOn(print_chemistry_on, false, false); 
status = phreeqc_rm.SetPoreVolume(pv);            // If pore volume changes due to compressibility
status = phreeqc_rm.SetSaturation(sat);           // If saturation changes
status = phreeqc_rm.SetTemperature(temperature);  // If temperature changes
status = phreeqc_rm.SetPressure(pressure);        // If pressure changes
status = phreeqc_rm.SetConcentrations(c);         // Transported concentrations
status = phreeqc_rm.SetTimeStep(time_step);		  // Time step for kinetic reactions
time = time + time_step;
status = phreeqc_rm.SetTime(time);
status = phreeqc_rm.RunCells();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                RunCells(void);
/**
Run a PHREEQC input file. The first three arguments determine which IPhreeqc instances will run
the file--the workers, the InitialPhreeqc instance, and (or) the Utility instance. Input
files that modify the thermodynamic database should be run by all three sets of instances.
Files with SELECTED_OUTPUT definitions that will be used during the time-stepping loop need to
be run by the workers. Files that contain initial conditions or boundary conditions should
be run by the InitialPhreeqc instance.
@param workers          @a True, the workers will run the file; @a False, the workers will not run the file.
@param initial_phreeqc  @a True, the InitialPhreeqc instance will run the file; @a False, the InitialPhreeqc will not run the file.
@param utility          @a True, the Utility instance will run the file; @a False, the Utility instance will not run the file.
@param chemistry_name   Name of the file to run.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref RunString.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.RunFile(true, true, true, "advect.pqi");
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                RunFile(bool workers, bool initial_phreeqc, bool utility,  const std::string & chemistry_name);
/**
Run a PHREEQC input string. The first three arguments determine which
IPhreeqc instances will run
the string--the workers, the InitialPhreeqc instance, and (or) the Utility instance. Input
strings that modify the thermodynamic database should be run by all three sets of instances.
Strings with SELECTED_OUTPUT definitions that will be used during the time-stepping loop need to
be run by the workers. Strings that contain initial conditions or boundary conditions should
be run by the InitialPhreeqc instance.
@param workers          @a True, the workers will run the string; @a False, the workers will not run the string.
@param initial_phreeqc  @a True, the InitialPhreeqc instance will run the string; @a False, the InitialPhreeqc will not run the string.
@param utility          @a True, the Utility instance will run the string; @a False, the Utility instance will not run the string.
@param input_string     String containing PHREEQC input.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref RunFile.
@par C++ Example:
@htmlonly
<CODE>
<PRE>		
std::string input = "DELETE; -all";
status = phreeqc_rm.RunString(true, false, true, input.c_str());
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                RunString(bool workers, bool initial_phreeqc, bool utility, const std::string & input_string);
/**
Print message to the screen.
@param str              String to be printed.
@see                    @ref ErrorMessage, @ref LogMessage, @ref OutputMessage, @ref WarningMessage.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::ostringstream strm;
strm << "Beginning transport calculation " 
     <<   phreeqc_rm.GetTime() * phreeqc_rm.GetTimeConversion() 
	 << " days\n";
strm << "          Time step             " 
     <<   phreeqc_rm.GetTimeStep() * phreeqc_rm.GetTimeConversion() 
	 << " days\n";
phreeqc_rm.ScreenMessage(strm.str());
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	void                                      ScreenMessage(const std::string &str);
/**
Set the volume of each cell. Porosity is determined by the ratio of the pore volume (@ref SetPoreVolume)
to the cell volume. The volume of water in a cell is the porosity times the saturation (@ref SetSaturation).
@param vol              Vector of volumes, user units, but same as @ref SetPoreVolume. 
Size of array is @a nxyz, where @a nxyz is the number
of grid cells in the user's model (@ref GetGridCellCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetPoreVolume, @ref SetSaturation.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> cell_vol;
cell_vol.resize(nxyz, 1);
status = phreeqc_rm.SetCellVolume(cell_vol);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetCellVolume(const std::vector<double> &vol);
/**
Select whether to include H2O in the component list. 
By default, the total concentrations of H and O are included
in the list of components that need to be transported (@ref FindComponents).
However, the concentrations of H and O must be known
accurately (8 to 10 significant digits) for the numerical method of 
PHREEQC to produce accurate pH and pe values.
Because most of the H and O are in the water species,
it may be more robust (require less accuracy in transport) to 
transport the excess H and O (the H and O not in water) and water. 
PhreeqcRM will then add the H and O from water to the excess quantities 
to arrive at total H and total O concentrations for reaction calculations.
A value of @a true will cause water and the excess H and O to be included in the list of components. 
SetComponentH2O must be called before @ref FindComponents.
@param tf               @a True, excess H, excess O, and water are included in the component list;
@a False, total H and O are included in the list of components.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref FindComponents.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetComponentH2O(false);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetComponentH2O(bool tf);
/**
Use the vector of concentrations to set the moles of components in each cell.
Porosity is determined by the ratio of the pore volume (@ref SetPoreVolume)
to the volume (@ref SetCellVolume).
The volume of water in a cell is the porosity times the saturation (@ref SetSaturation).
The moles of each component are determined by the volume of water and per liter concentrations.
If concentration units (@ref SetUnitsSolution) are mass fraction, the
density (as determined by @ref SetDensity) is used to convert from mass fraction to per liter.
@param c               Vector of component concentrations. Size of vector is @a ncomps times @a nxyz, 
where @a ncomps is the number of components as determined
by @ref FindComponents or @ref GetComponentCount and
@a nxyz is the number of grid cells in the user's model (@ref GetGridCellCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetCellVolume, @ref SetPoreVolume, @ref SetSaturation, @ref SetUnitsSolution.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> c;
c.resize(nxyz * components.size());
...
AdvectCpp(c, bc_conc, ncomps, nxyz, nbound);
status = phreeqc_rm.SetPoreVolume(pv);            // If pore volume changes due to compressibility
status = phreeqc_rm.SetSaturation(sat);           // If saturation changes
status = phreeqc_rm.SetTemperature(temperature);  // If temperature changes
status = phreeqc_rm.SetPressure(pressure);        // If pressure changes
status = phreeqc_rm.SetConcentrations(c);         // Transported concentrations
status = phreeqc_rm.SetTimeStep(time_step);		  // Time step for kinetic reactions
time = time + time_step;
status = phreeqc_rm.SetTime(time);
status = phreeqc_rm.RunCells();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetConcentrations(const std::vector<double> &c); 
/**
Select the current selected output by user number. The user may define multiple SELECTED_OUTPUT
data blocks for the workers. A user number is specified for each data block. The value of
the argument @a n_user selects which of the SELECTED_OUTPUT definitions will be used
for selected-output operations.
@param n_user           User number of the SELECTED_OUTPUT data block that is to be used.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref GetNthSelectedOutputUserNumber, @ref GetSelectedOutput, @ref GetSelectedOutputColumnCount,
@ref GetSelectedOutputCount, @ref GetSelectedOutputRowCount, @ref GetSelectedOutputHeading,
@ref SetSelectedOutputOn.
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
  status = phreeqc_rm.GetSelectedOutput(so);
  // Process results here
}
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	IRM_RESULT								  SetCurrentSelectedOutputUserNumber(int n_user);
/**
Set the density for each cell. These density values are used 
when converting from transported mass-fraction concentrations (@ref SetUnitsSolution) to
produce per liter concentrations during a call to @ref SetConcentrations. 
They are also used when converting from module concentrations to transport concentrations
of mass fraction (@ref GetConcentrations), if @ref UseSolutionDensityVolume is set to @a false.
@param density          Vector of densities. Size of vector is @a nxyz, where @a nxyz is the number
of grid cells in the user's model (@ref GetGridCellCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref GetGridCellCount, @ref SetConcentrations, 
@ref SetUnitsSolution, @ref UseSolutionDensityVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> initial_density;
initial_density.resize(nxyz, 1.0);
phreeqc_rm.SetDensity(initial_density);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetDensity(const std::vector<double> &density);
/**
Set the name of the dump file. It is the name used by @ref DumpModule.
@param dump_name        Name of dump file.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref DumpModule.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetDumpFileName("advection_cpp.dmp");
bool dump_on = true;
bool append = false;
status = phreeqc_rm.DumpModule(dump_on, append);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	IRM_RESULT                                SetDumpFileName(const std::string & dump_name); 
/**
Set the action to be taken when the reaction module encounters an error.
Options are 0, return to calling program with an error return code (default);
1, throw an exception, in C++, the exception can be caught, for C and Fortran, the program will exit; or
2, attempt to exit gracefully.
@param mode             Error handling mode: 0, 1, or 2.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@par C++ Example:
@htmlonly
<CODE>
<PRE>
PhreeqcRM phreeqc_rm(nxyz, nthreads);
IRM_RESULT status;
status = phreeqc_rm.SetErrorHandlerMode(1); 
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetErrorHandlerMode(int mode);
/**
Set the prefix for the output (prefix.chem.txt) and log (prefix.log.txt) files.
These files are opened by @ref OpenFiles.
@param prefix           Prefix used when opening the output and log files.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref OpenFiles, @ref CloseFiles.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetFilePrefix("Advect_cpp");
phreeqc_rm.OpenFiles();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root.
 */
	IRM_RESULT                                SetFilePrefix(const std::string & prefix); 
/**
MPI and C/C++ only. Defines a callback function that allows additional tasks to be done
by the workers. The method @ref MpiWorker contains a loop,
where the workers receive a message (an integer),
run a function corresponding to that integer,
and then wait for another message.
SetMpiWorkerCallbackC allows the C or C++ developers to add another function
that responds to additional integer messages by calling developer-defined functions
corresponding to those integers.
@ref MpiWorker calls the callback function when the message number
is not one of the PhreeqcRM message numbers.
Messages are unique integer numbers. PhreeqcRM uses integers in a range
beginning at 0. It is suggested that developers use message numbers starting
at 1000 or higher for their tasks.
The callback function calls a developer-defined function specified
by the message number and then returns to @ref MpiWorker to wait for
another message.
@n@n
In C and C++, an additional pointer can be supplied to find the data necessary to do the task.
A void pointer may be set with @ref SetMpiWorkerCallbackCookie. This pointer
is passed to the callback function through a void pointer argument in addition
to the integer message argument. @ref SetMpiWorkerCallbackCookie
must be called by each worker before @ref MpiWorker is called.
@n@n
The motivation for this method is to allow the workers to perform other
tasks, for instance, parallel transport calculations, within the structure
of @ref MpiWorker. The callback function
can be used to allow the workers to receive data, perform transport calculations,
and send results, without leaving the loop of @ref MpiWorker. Alternatively,
it is possible for the workers to return from @ref MpiWorker
by a call to @ref MpiWorkerBreak by root. The workers could then call
subroutines to receive data, calculate transport, and send data,
and then resume processing PhreeqcRM messages from root with another
call to @ref MpiWorker.
@param fcn              A function that returns an integer and has an integer argument 
and a void * argument.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref MpiWorker, @ref MpiWorkerBreak,
@ref SetMpiWorkerCallbackCookie.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
Pseudo code for root:
// root calls a function that will involve the workers
status = init((void *) mydata);

int init(void *cookie)
{
  // use cookie to find data, phreeqcrm_comm
  int ierrmpi, message
  message = 1000;
  if (mpi_myself == 0)
  {
    // message number 1000 is sent to the workers
    MPI_Bcast(&message, 1, MPI_INT, 0, phreeqcrm_comm);
  }
  // Do some work here by root and (or) workers
  return 0;
}

Pseudo code for worker:

status = phreeqc_rm.SetMpiWorkerCallbackC(mpi_methods);
status = phreeqc_rm.SetMpiWorkerCallbackCookie((void *) mydata);
...
status = phreeqc_rm.MpiWorker();

int mpi_methods(int method, void *cookie)
{
  // this method is called by MpiWorker
  // because it was registered by SetMpiWorkerCallbackC
  int return_value;
  return_value = 0;
  if (method == 1000)
  {
    // Here the workers call init
    return_value = init(cookie);
  }
  return return_value;
}
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by workers, before call to @ref MpiWorker.
 */
	IRM_RESULT								  SetMpiWorkerCallbackC(int (*fcn)(int *method, void * cookie));
/**
MPI and C/C++ only. Defines a void pointer that can be used by
C and C++ functions called from the callback function (@ref SetMpiWorkerCallbackC)
to locate data for a task. The C callback function
that is registered with @ref SetMpiWorkerCallbackC has
two arguments, an integer message to identify a task, and a void
pointer. SetMpiWorkerCallbackCookie sets the value of the
void pointer that is passed to the callback function.
@param cookie           Void pointer that can be used by subroutines called from the callback function
to locate data needed to perform a task.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref MpiWorker, @ref MpiWorkerBreak,
@ref SetMpiWorkerCallbackC.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
Pseudo code for root:
// root calls a function that will involve the workers
status = init((void *) mydata);

int init(void *cookie)
{
  // use cookie to find data, phreeqcrm_comm
  int ierrmpi, message
  message = 1000;
  if (mpi_myself == 0)
  {
    // message number 1000 is sent to the workers
    MPI_Bcast(&message, 1, MPI_INT, 0, phreeqcrm_comm);
  }
  // Do some work here by root and (or) workers
  return 0;
}

Pseudo code for worker:

status = phreeqc_rm.SetMpiWorkerCallbackC(mpi_methods);
status = SetMpiWorkerCallbackCookie(id, (void *) mydata);
...
status = MpiWorker();

int mpi_methods(int method, void *cookie)
{
  // this method is called by MpiWorker
  // because it was registered by SetMpiWorkerCallbackC
  int return_value;
  return_value = 0;
  if (method == 1000)
  {
    // Here the workers call init
    return_value = init(cookie);
  }
  return return_value;
}
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by workers, before call to @ref MpiWorker.
 */
	IRM_RESULT								  SetMpiWorkerCallbackCookie(void * cookie);
/**
MPI and Fortran only. Defines a callback function that allows additional tasks to be done
by the workers. See documentation of PhreeqcRM for C and Fortran, method RM_SetMpiWorkerCallback.
 */
	IRM_RESULT								  SetMpiWorkerCallbackFortran(int (*fcn)(int *method));
/**
Sets the property for partitioning solids between the saturated and unsaturated 
parts of a partially saturated cell. The value has meaning only when saturations 
less than 1.0 are encountered. Unexpected results may
occur in partially saturated cells for models that try to account for a free surface, but 
consider only saturated-zone flow and transport. The partially saturated cells 
see a smaller volume of water, 
even though, physically, recharge water is percolating through these cells. 
It takes a longer time for reactions to occur in these cells than in cells 
that are fully saturated. By setting  SetPartitionUZSolids to true, the
amounts of solids and gases are partioned according to the saturation. 
If a cell has a saturation of 0.5, then
the water interacts with only half of the solids and gases; the other half is unreactive
until the water table rises. As the saturation in a cell varies, 
solids and gases are transferred between the
saturated and unsaturated (unreactive) reservoirs of the cell. 
Unsaturated-zone flow and transport codes will probably use the default (false), 
which assumes all gases and solids are reactive regardless of saturation.  
@param tf       @a True, the fraction of solids and gases available for 
reaction is equal to the saturation; 
@a False (default), all solids and gases are reactive regardless of saturation.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                @ref GetPartitionUZSolids.
@par C++ Example:
@htmlonly
<CODE>
<PRE>  
phreeqc_rm.SetPartitionUZSolids(false);
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetPartitionUZSolids(bool tf);
/**
Set the pore volume of each cell. Porosity is determined by the ratio of the pore volume
to the cell volume (@ref SetCellVolume). The volume of water in a cell is the porosity times the saturation
(@ref SetSaturation).
@param vol              Vector of pore volumes, user units, but same as @ref SetCellVolume. 
Size of vector is @a nxyz, where @a nxyz is the number
of grid cells in the user's model (@ref GetGridCellCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetCellVolume, @ref SetSaturation.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> pv;
pv.resize(nxyz, 0.2);
status = phreeqc_rm.SetPoreVolume(pv);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetPoreVolume(const std::vector<double> &vol); 
/**
Set the pressure for each cell for reaction calculations. Pressure effects are considered only in three of the
databases distributed with PhreeqcRM: phreeqc.dat, Amm.dat, and pitzer.dat.
@param p                Vector of pressures, in atm. Size of vector is @a nxyz, 
where @a nxyz is the number of grid cells in the user's model (@ref GetGridCellCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetTemperature.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> pressure;
pressure.resize(nxyz, 2.0);
phreeqc_rm.SetPressure(pressure);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetPressure(const std::vector<double> &p); 
/**
Enable or disable detailed output for each cell. Printing for a cell will occur only when the
printing is enabled with @ref SetPrintChemistryOn and the @a cell_mask value is 1.
@param cell_mask        Vector of integers. Size of vector is @a nxyz, where @a nxyz is the number
of grid cells in the user's model (@ref GetGridCellCount). A value of 0 will
disable printing detailed output for the cell; a value of 1 will enable printing detailed output for a cell.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetPrintChemistryOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<int> print_chemistry_mask;
print_chemistry_mask.resize(nxyz, 0);
for (int i = 0; i < nxyz/2; i++)
{
  print_chemistry_mask[i] = 1;
}
status = phreeqc_rm.SetPrintChemistryMask(print_chemistry_mask);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetPrintChemistryMask(std::vector<int> & cell_mask);
/**
Property that enables or disables printing detailed output from reaction calculations 
to the output file for a set of cells defined by @ref SetPrintChemistryMask. 
The detailed output prints all of the output typical of a PHREEQC reaction calculation, 
which includes solution descriptions and the compositions of all other reactants. 
The output can be several hundred lines per cell, which can lead to a very
large output file (prefix.chem.txt, @ref OpenFiles). 
For the worker instances, the output can be limited to a set of cells
(@ref SetPrintChemistryMask) and, in general, the
amount of information printed can be limited by use of options in the PRINT data block of PHREEQC 
(applied by using @ref RunFile or @ref RunString). 
Printing the detailed output for the workers is generally used only for debugging, 
and PhreeqcRM will run significantly faster 
when printing detailed output for the workers is disabled.
@param workers          @a True, enable detailed printing in the worker instances; 
@a False, disable detailed printing in the worker instances.
@param initial_phreeqc  @a True, enable detailed printing in the InitialPhreeqc instance; 
@a False, disable detailed printing in the InitialPhreeqc instance.
@param utility          @a True, enable detailed printing in the Utility instance; 
@a False, disable detailed printing in the Utility instance.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetPrintChemistryMask.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetPrintChemistryOn(false, true, false);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetPrintChemistryOn(bool workers, bool initial_phreeqc, bool utility); 
/**
PhreeqcRM attempts to rebalance the load of each thread or process such that each
thread or process takes the same amount of time to run its part of a @ref RunCells
calculation. Two algorithms are available; one uses the average time to run a set of
cells, and the other accounts for cells that were not run because saturation was zero (default).
The methods are similar, and it is not clear that one is better than the other.
@param tf           @a True, indicates individual cell times are used in rebalancing (default); 
@a False, indicates average times are used in rebalancing.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetRebalanceFraction.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetRebalanceByCell(true);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetRebalanceByCell(bool tf); 
/**
PhreeqcRM attempts to rebalance the load of each thread or process such that each
thread or process takes the same amount of time to run its part of a @ref RunCells
calculation. The rebalancing transfers cell calculations among threads or processes to
try to achieve an optimum balance. SetRebalanceFraction
adjusts the calculated optimum number of cell transfers by a fraction from 0 to 1.0 to
determine the actual number of cell transfers. A value of zero eliminates
load rebalancing. A value less than 1.0 is suggested to slow the approach to the optimum cell
distribution and avoid possible oscillations
where too many cells are transferred at one iteration, requiring reverse transfers at the next iteration.
Default is 0.5.

@param f                Fraction from 0.0 to 1.0.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetRebalanceByCell.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetRebalanceFraction(0.5);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetRebalanceFraction(double f); 
/**
Set the saturation of each cell. Saturation is a fraction ranging from 0 to 1.
Porosity is determined by the ratio of the pore volume (@ref SetPoreVolume)
to the cell volume (@ref SetCellVolume). The volume of water in a cell is the porosity times the saturation.

@param sat              Vector of saturations, unitless. Size of vector is @a nxyz, 
where @a nxyz is the number of grid cells in the user's model (@ref GetGridCellCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetCellVolume, @ref SetPoreVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> sat;
sat.resize(nxyz, 1.0);
status = phreeqc_rm.SetSaturation(sat);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetSaturation(const std::vector<double> &sat); 
/**
This property determines whether selected-output results are available to be retrieved
with @ref GetSelectedOutput. @a True indicates that selected-output results
will be accumulated during @ref RunCells and can be retrieved with @ref GetSelectedOutput;
@a False indicates that selected-output results will not
be accumulated during @ref RunCells. 

@param tf  @a True, enable selected output; @a False, disable selected output. 
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref GetSelectedOutput, @ref SetPrintChemistryOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetSelectedOutputOn(true);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetSelectedOutputOn(bool tf);
/**
Sets the value of the species-save property.
This method enables use of PhreeqcRM with multicomponent-diffusion transport calculations.
By default, concentrations of aqueous species are not saved. 
Setting the species-save property to @a true allows
aqueous species concentrations to be retrieved
with @ref GetSpeciesConcentrations, and solution compositions to be set with
@ref SpeciesConcentrations2Module.
SetSpeciesSaveOn must be called before calls to @ref FindComponents.

@param save_on          @a True indicates species concentrations are saved; 
@a False indicates species concentrations are not saved.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref FindComponents, @ref GetSpeciesConcentrations, @ref GetSpeciesCount,
@ref GetSpeciesD25, @ref GetSpeciesSaveOn, @ref GetSpeciesZ,
@ref GetSpeciesNames, @ref SpeciesConcentrations2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetSpeciesSaveOn(true);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	IRM_RESULT                                SetSpeciesSaveOn(bool save_on);
/**
Set the temperature for each cell for reaction calculations. If SetTemperature is not called, 
worker solutions will have temperatures as defined in  
input files (@ref RunFile) or input strings (@ref RunString).
@param t                Vector of temperatures, in degrees C. Size of vector is @a nxyz, where @a nxyz is the number
of grid cells in the user's model (@ref GetGridCellCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref GetPressure, @ref SetPressure, @ref GetTemperature.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
std::vector<double> temperature;
temperature.resize(nxyz, 20.0);
phreeqc_rm.SetTemperature(temperature);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
	IRM_RESULT                                SetTemperature(const std::vector<double> &t);
/**
Set current simulation time for the reaction module.
@param time             Current simulation time, in seconds.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetTimeStep, @ref SetTimeConversion.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
time += time_step;
status = phreeqc_rm.SetTime(time);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetTime(double time);
/**
Set a factor to convert to user time units. Factor times seconds produces user time units.

@param conv_factor      Factor to convert seconds to user time units.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetTime, @ref SetTimeStep.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
double time_conversion = 1.0 / 86400;
status = phreeqc_rm.SetTimeConversion(time_conversion); 
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetTimeConversion(double conv_factor);
/**
Set current time step for the reaction module. This is the length
of time over which kinetic reactions are integrated.

@param time_step        Current time step, in seconds.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetTime, @ref SetTimeConversion.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
time_step = 86400.;
status = phreeqc_rm.SetTimeStep(time_step);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetTimeStep(double time_step);
/**
Input units for exchangers. In PHREEQC, exchangers are defined by
moles of exchange sites. SetUnitsExchange determines whether the
number of sites applies to the volume of the cell, the volume of
water in the cell, or the volume of rock in the cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell by @ref InitialPhreeqc2Module and @ref InitialPhreeqcCell2Module 
on the basis of the porosity (@ref SetCellVolume and @ref SetPoreVolume).

@param option           Units option for exchangers: 0, 1, or 2. 
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetCellVolume, @ref SetPoreVolume, 
@ref InitialPhreeqc2Module, @ref InitialPhreeqcCell2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetUnitsExchange(1);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetUnitsExchange(int option);
/**
Input units for gas phases. In PHREEQC, gas phases are defined by
moles of component gases. SetUnitsGasPhase determines whether the
number of moles applies to the volume of the cell, the volume of
water in a cell, or the volume of rock in a cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell by @ref InitialPhreeqc2Module and @ref InitialPhreeqcCell2Module 
on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).

@param option           Units option for gas phases: 0, 1, or 2. 
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetCellVolume, @ref SetPoreVolume, 
@ref InitialPhreeqc2Module, @ref InitialPhreeqcCell2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetUnitsGasPhase(1);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetUnitsGasPhase(int option);
/**
Input units for kinetic reactants. In PHREEQC, kinetics are defined by
moles of kinetic reactant. SetUnitsKinetics determines whether the
number of moles applies to the volume of the cell, the volume of
water in a cell, or the volume of rock in a cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell by @ref InitialPhreeqc2Module and @ref InitialPhreeqcCell2Module 
on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).
@n@n
Note that the volume of water in a cell in the reaction module is equal
to the porosity times the saturation, which is usually much less than 1 liter.
It is important to write the
RATES definitions for KINETICS to account for the current volume of water,
often by calculating the rate of reaction per liter of water and multiplying by the
volume of water (Basic function SOLN_VOL).

@param option           Units option for kinetic reactants: 0, 1, or 2. 
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetCellVolume, @ref SetPoreVolume, 
@ref InitialPhreeqc2Module, @ref InitialPhreeqcCell2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetUnitsKinetics(1);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetUnitsKinetics(int option);
/**
Input units for pure phase assemblages (equilibrium phases).
In PHREEQC, equilibrium phases are defined by
moles of each phase. SetUnitsPPassemblage determines whether the
number of moles applies to the volume of the cell, the volume of
water in a cell, or the volume of rock in a cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell by @ref InitialPhreeqc2Module and @ref InitialPhreeqcCell2Module 
on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).

@param option           Units option for equilibrium phases: 0, 1, or 2.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetCellVolume, @ref SetPoreVolume, 
@ref InitialPhreeqc2Module, @ref InitialPhreeqcCell2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetUnitsPPassemblage(1);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetUnitsPPassemblage(int option);
/**
Solution concentration units used by the transport model.
Options are 1, mg/L; 2 mol/L; or 3, mass fraction, kg/kgs.
PHREEQC defines solutions by the number of moles of each
element in the solution.
@n@n
To convert from mg/L to moles
of element in a cell, mg/L is converted to mol/L and
multiplied by the solution volume,
which is porosity (@ref SetCellVolume, @ref SetPoreVolume)
times saturation (@ref SetSaturation).
To convert from mol/L to moles
of element in a cell, mol/L is
multiplied by the solution volume,
which is porosity (@ref SetCellVolume, @ref SetPoreVolume)
times saturation (@ref SetSaturation).
To convert from mass fraction to moles
of element in a cell, kg/kgs is converted to mol/kgs, multiplied by density
(@ref SetDensity) and
multiplied by the solution volume,
which is porosity (@ref SetCellVolume, @ref SetPoreVolume)
times saturation (@ref SetSaturation).
@n@n
To convert from moles
of element in a cell to mg/L, the number of moles of an element is divided by the
solution volume resulting in mol/L, and then converted to mg/L.
To convert from moles
of element in a cell to mol/L,  the number of moles of an element is divided by the
solution volume resulting in mol/L.
To convert from moles
of element in a cell to mass fraction, the number of moles of an element is converted to kg and divided
by the total mass of the solution.
Two options are available for the volume and mass of solution 
that are used in converting to transport concentrations: (1) the volume and mass of solution are
calculated by PHREEQC, or (2) the volume of solution is the product of porosity and saturation, 
and the mass of solution is volume times density as defined by @ref SetDensity. 
Which option is used is determined by @ref UseSolutionDensityVolume.
@param option           Units option for solutions: 1, 2, or 3, default is 1, mg/L.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetCellVolume, @ref SetDensity, @ref SetPoreVolume, @ref SetSaturation,
@ref UseSolutionDensityVolume.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetUnitsSolution(2);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetUnitsSolution(int option);
/**
Input units for solid-solution assemblages.
In PHREEQC, solid solutions are defined by
moles of each component. SetUnitsSSassemblage determines whether the
number of moles applies to the volume of the cell, the volume of
water in a cell, or the volume of rock in a cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell by @ref InitialPhreeqc2Module and @ref InitialPhreeqcCell2Module 
on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).

@param option           Units option for solid solutions: 0, 1, or 2. 
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetCellVolume, @ref SetPoreVolume, 
@ref InitialPhreeqc2Module, @ref InitialPhreeqcCell2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetUnitsSSassemblage(1);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetUnitsSSassemblage(int option);
/**
Input units for surfaces. In PHREEQC, surfaces are determined by
moles of surface sites. SetUnitsSurface defines whether the
number of sites applies to the volume of the cell, the volume of
water in a cell, or the volume of rock in a cell. Options are
0, mol/L of cell (default); 1, mol/L of water in the cell; 2 mol/L of rock in the cell.
If 1 or 2 is selected, the input is converted
to mol/L of cell by @ref InitialPhreeqc2Module and @ref InitialPhreeqcCell2Module 
on the basis of the porosity
(@ref SetCellVolume and @ref SetPoreVolume).

@param option           Units option for surfaces: 0, 1, or 2. 
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref SetCellVolume, @ref SetPoreVolume, 
@ref InitialPhreeqc2Module, @ref InitialPhreeqcCell2Module.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetUnitsSurface(1);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT                                SetUnitsSurface(int option);
/**
Set solution concentrations in the reaction module 
based on the vector of aqueous species concentrations (@a species_conc).
This method is intended for use with multicomponent-diffusion transport calculations,
and @ref SetSpeciesSaveOn must be set to @a true.
The method determines the total concentration of a component 
by summing the molarities of the individual species times the stoichiometric
coefficient of the element in each species.

@param species_conc     Vector of aqueous species concentrations. Dimension of the array is @a nspecies times @a nxyz,
where  @a nspecies is the number of aqueous species (@ref GetSpeciesCount),
and @a nxyz is the number of user grid cells (@ref GetGridCellCount).
Concentrations are moles per liter.
The list of aqueous species is determined by @ref FindComponents and includes all
aqueous species that can be made from the set of components.
@retval IRM_RESULT      0 is success, negative is failure (See @ref DecodeError).
@see                    @ref FindComponents, @ref GetSpeciesConcentrations, @ref GetSpeciesCount, 
@ref GetSpeciesD25, @ref GetSpeciesZ,
@ref GetSpeciesNames, @ref GetSpeciesSaveOn, @ref SetSpeciesSaveOn.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
status = phreeqc_rm.SetSpeciesSaveOn(true);
int ncomps = phreeqc_rm.FindComponents();
int nspecies = phreeqc_rm.GetSpeciesCount();
std::vector<double> c;
status = phreeqc_rm.GetSpeciesConcentrations(c);
...
SpeciesAdvectCpp(c, bc_conc, nspecies, nxyz, nbound);
status = phreeqc_rm.SpeciesConcentrations2Module(c);
status = phreeqc_rm.RunCells();
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
	IRM_RESULT								  SpeciesConcentrations2Module(std::vector<double> & species_conc); 
/**
Determines the volume and density to use when converting from the reaction-module concentrations
to transport concentrations (@ref GetConcentrations). 
Two options are available to convert concentration units: 
(1) the density and solution volume calculated by PHREEQC are used, or 
(2) the specified density (@ref SetDensity) 
and solution volume defined by the product of 
@ref SetSaturation, @ref SetPoreVolume, and @ref SetCellVolume are used.
Transport models that consider density-dependent flow will probably use the 
PHREEQC-calculated density and solution volume (default), 
whereas transport models that assume constant-density flow will probably use
specified values of density and solution volume. 
Only the following databases distributed with PhreeqcRM have molar volume information 
needed to accurately calculate density and solution volume: phreeqc.dat, Amm.dat, and pitzer.dat.
Density is only used when converting to transport units of mass fraction. 

@param tf          @a True indicates that the solution density and volume as 
calculated by PHREEQC will be used to calculate transport concentrations. 
@a False indicates that the solution density set by @ref SetDensity and the volume determined by the 
product of  @ref SetSaturation, @ref SetPoreVolume, 
and @ref SetCellVolume will be used to calculate transport concentrations.
@see                    @ref GetConcentrations, @ref SetCellVolume, @ref SetDensity, 
@ref SetPoreVolume, @ref SetSaturation.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
phreeqc_rm.UseSolutionDensityVolume(false);
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref MpiWorker.
 */
void UseSolutionDensityVolume(bool tf);
/**
Print a warning message to the screen and the log file.

@param warnstr          String to be printed.
@see                    @ref OpenFiles, @ref ErrorMessage, @ref LogMessage, @ref OutputMessage, @ref ScreenMessage.
@par C++ Example:
@htmlonly
<CODE>
<PRE>
phreeqc_rm.WarningMessage("Parameter is out of range, using default");
</PRE>
</CODE>
@endhtmlonly
@par MPI:
Called by root and (or) workers; only root writes to the log file.
 */
	void                                      WarningMessage(const std::string &warnstr);
	
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
	IRM_RESULT                                CheckCells();
	int                                       CheckSelectedOutput();
	IPhreeqc *                                Concentrations2UtilityH2O(std::vector<double> &c_in, 
		                                           std::vector<double> t_in, std::vector<double> p_in);
	IPhreeqc *                                Concentrations2UtilityNoH2O(std::vector<double> &c_in, 
		                                           std::vector<double> t_in, std::vector<double> p_in);
	void                                      Concentrations2Solutions(int n, std::vector<double> &c);
	void                                      Concentrations2SolutionsH2O(int n, std::vector<double> &c);
	void                                      Concentrations2SolutionsNoH2O(int n, std::vector<double> &c);
	void                                      cxxSolution2concentration(cxxSolution * cxxsoln_ptr, std::vector<double> & d, double v, double dens);
	void                                      cxxSolution2concentrationH2O(cxxSolution * cxxsoln_ptr, std::vector<double> & d, double v, double dens);
	void                                      cxxSolution2concentrationNoH2O(cxxSolution * cxxsoln_ptr, std::vector<double> & d, double v, double dens);
	cxxStorageBin &                           Get_phreeqc_bin(void) {return this->phreeqc_bin;}
	IRM_RESULT                                HandleErrorsInternal(std::vector< int > & r);
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
	double                                    TimeStandardTask(void);
	IRM_RESULT                                TransferCells(cxxStorageBin &t_bin, int old, int nnew);
	IRM_RESULT                                TransferCellsUZ(std::ostringstream &raw_stream, int old, int nnew);

private:
	IRM_RESULT                                SetGeneric(std::vector<double> &destination, int newSize, const std::vector<double> &origin, int mpiMethod, const std::string &name, const double newValue = 0.0);
protected:
	bool component_h2o;                      // true: use H2O, excess H, excess O, and charge; 
	                                         // false total H, total O, and charge
	std::string database_file_name;
	std::string chemistry_file_name;
	std::string dump_file_name;
	std::string file_prefix;
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
	bool use_solution_density_volume;

	// print flags
	std::vector<bool> print_chemistry_on;	// print flag for chemistry output file 
	bool selected_output_on;				// create selected output

	int error_count;
	int error_handler_mode;                 // 0, return code; 1, throw; 2 exit;
	bool need_error_check;

	// threading
	int nthreads;
	std::vector<IPhreeqcPhast *> workers;
	std::vector<int> start_cell;
	std::vector<int> end_cell;
	PHRQ_io phreeqcrm_io;

	// mpi 
#ifdef USE_MPI
	MPI_Comm phreeqcrm_comm;                                       // MPI communicator
#endif
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
	std::vector<double> standard_task_vector;   // root only

private:
	friend class RM_interface;
	static std::map<size_t, PhreeqcRM*> Instances;
	static size_t InstancesIndex;

};
#endif // !defined(PHREEQCRM_H_INCLUDED)
