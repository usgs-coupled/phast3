/*! @file RM_interface.h
	@brief C/Fortran Documentation
*/
#ifndef RM_INTERFACE_H
#define RM_INTERFACE_H

#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif

#if defined(FC_FUNC_)
// Called from Fortran or C++
#define RM_CloseFiles                      FC_FUNC_ (rm_closefiles,                    RM_CLOSEFILES)  
#define RM_Concentrations2Utility          FC_FUNC_ (rm_concentrations2utility,        RM_CONCENTRATIONS2UTILITY)  
#define RM_convert_to_molal                FC_FUNC_ (rm_convert_to_molal,              RM_CONVERT_TO_MOLAL)   
#define RM_Create                          FC_FUNC_ (rm_create,                        RM_CREATE)
#define RM_CreateMapping                   FC_FUNC_ (rm_createmapping,                 RM_CREATEMAPPING)
#define RM_DecodeError                     FC_FUNC_ (rm_decodeerror,                   RM_DECODEERROR)
#define RM_Destroy                         FC_FUNC_ (rm_destroy,                       RM_DESTROY)
#define RM_DumpModule                      FC_FUNC_ (rm_dumpmodule,                    RM_DUMPMODULE)
#define RM_ErrorHandler                    FC_FUNC_ (rm_errorhandler,                  RM_ERRORHANDLER)
#define RM_ErrorMessage                    FC_FUNC_ (rm_errormessage,                  RM_ERRORMESSAGE)
#define RM_FindComponents                  FC_FUNC_ (rm_findcomponents,                RM_FINDCOMPONENTS)
#define RM_GetChemistryCellCount           FC_FUNC_ (rm_getchemistrycellcount,         RM_GETNCHEMISTRYCELLCOUNT)
#define RM_GetComponent                    FC_FUNC_ (rm_getcomponent,                  RM_GETCOMPONENT)
#define RM_GetConcentrations               FC_FUNC_ (rm_getconcentrations,             RM_GETCONCENTRATIONS)
#define RM_GetDensity                      FC_FUNC_ (rm_getdensity,                    RM_GETDENSITY)
#define RM_GetFilePrefix                   FC_FUNC_ (rm_getfileprefix,                 RM_GETFILEPREFIX)
#define RM_GetGridCellCount                FC_FUNC_ (rm_getgridcellcount,              RM_GETGRIDCELLCOUNT)
#define RM_GetIPhreeqcId                   FC_FUNC_ (rm_getiphreeqcid,                 RM_GETIPHREEQCID)
#define RM_GetMpiMyself                    FC_FUNC_ (rm_getmpimyself,                  RM_GETMPIMYSELF)
#define RM_GetMpiTasks                     FC_FUNC_ (rm_getmpitasks,                   RM_GETMPITASKS)
#define RM_GetNThreads                     FC_FUNC_ (rm_getnthreads,                   RM_GETNTHREADS)
#define RM_GetNthSelectedOutputUserNumber  FC_FUNC_ (rm_getnthselectedoutputusernumber, RM_GETNTHSELECTEDOUTPUTUSERNUMBER)
#define RM_GetSelectedOutput               FC_FUNC_ (rm_getselectedoutput,             RM_GETSELECTEDOUTPUT)
#define RM_GetSelectedOutputColumnCount    FC_FUNC_ (rm_getselectedoutputcolumncount,  RM_GETSELECTEDOUTPUTCOLUMNCOUNT)
#define RM_GetSelectedOutputCount          FC_FUNC_ (rm_getselectedoutputcount,        RM_GETSELECTEDOUTPUTCOUNT)
#define RM_GetSelectedOutputHeading        FC_FUNC_ (rm_getselectedoutputheading,      RM_GETSELECTEDOUTPUTHEADING)
#define RM_GetSelectedOutputRowCount       FC_FUNC_ (rm_getselectedoutputrowcount,     RM_GETSELECTEDOUTPUTROWCOUNT)
#define RM_GetSolutionVolume               FC_FUNC_ (rm_getsolutionvolume,             RM_GETSOLUTIONVOLUME)
#define RM_GetTime                         FC_FUNC_ (rm_gettime,                       RM_GETTIME)
#define RM_GetTimeConversion               FC_FUNC_ (rm_gettimeconversion,             RM_GETTIMECONVERSION)
#define RM_GetTimeStep                     FC_FUNC_ (rm_gettimestep,                   RM_GETTIMESTEP)
#define RM_InitialPhreeqc2Concentrations   FC_FUNC_ (rm_initialphreeqc2concentrations, RM_INITIALPHREEQC2CONCENTRATIONS)
#define RM_InitialPhreeqc2Module           FC_FUNC_ (rm_initialphreeqc2module,         RM_INITIALPHREEQC2MODULE)
#define RM_InitialPhreeqcCell2Module       FC_FUNC_ (rm_initialphreeqccell2module,     RM_INITIALPHREEQCCELL2MODULE)
#define RM_LoadDatabase                    FC_FUNC_ (rm_loaddatabase,                  RM_LOADDATABASE)
#define RM_LogMessage                      FC_FUNC_ (rm_logmessage,                    RM_LOGMESSAGE)
#define RM_MpiWorker                       FC_FUNC_ (rm_mpiworker,                     RM_MPIWORKER)
#define RM_MpiWorkerBreak                  FC_FUNC_ (rm_mpiworkerbreak,                RM_MPIWORKERBREAK)
#define RM_OpenFiles                       FC_FUNC_ (rm_openfiles,                     RM_OPENFILES)
#define RM_OutputMessage                   FC_FUNC_ (rm_outputmessage,                 RM_OUTPUTMESSAGE)
#define RM_RunCells                        FC_FUNC_ (rm_runcells,                      RM_RUNCELLS)
#define RM_RunFile                         FC_FUNC_ (rm_runfile,                          RM_RUNFILE)
#define RM_RunString                       FC_FUNC_ (rm_runstring,                     RM_RUNSTRING)
#define RM_ScreenMessage                   FC_FUNC_ (rm_screenmessage,                 RM_SCREENMESSAGE)
#define RM_SetCellVolume				   FC_FUNC_ (rm_setcellvolume,                 RM_SETCELLVOLUME)
#define RM_SetConcentrations			   FC_FUNC_ (rm_setconcentrations,             RM_SETCONCENTRATIONS)
#define RM_SetCurrentSelectedOutputUserNumber  FC_FUNC_ (rm_setcurrentselectedoutputusernumber, RM_SETCURRENTSELECTEDOUTPUTUSERNUMBER)
#define RM_SetDensity                      FC_FUNC_ (rm_setdensity,                    RM_SETDENSITY)
#define RM_SetDumpFileName                 FC_FUNC_ (rm_setdumpfilename,               RM_SETDUMPFILENAME)
#define RM_SetErrorHandlerMode             FC_FUNC_ (rm_seterrorhandlermode,           RM_SETERRORHANDLERMODE)
#define RM_SetFilePrefix                   FC_FUNC_ (rm_setfileprefix,                 RM_SETFILEPREFIX)
#define RM_SetMpiWorkerCallback            FC_FUNC_ (rm_setmpiworkercallback,          RM_SETMPIWORKERCALLBACK)
#define RM_SetPartitionUZSolids            FC_FUNC_ (rm_setpartitionuzsolids,          RM_SETPARTITIONUZSOLIDS)
#define RM_SetPoreVolume                   FC_FUNC_ (rm_setporevolume,                 RM_SETPOREVOLUME)
//#define RM_SetPoreVolumeZero               FC_FUNC_ (rm_setporevolumezero,             RM_SETPOREVOLUMEZERO)
#define RM_SetPrintChemistryMask           FC_FUNC_ (rm_setprintchemistrymask,         RM_SETPRINTCHEMISTRYMASK)
#define RM_SetPrintChemistryOn             FC_FUNC_ (rm_setprintchemistryon,           RM_SETPRINTCHEMISTRYON)
#define RM_SetPressure                     FC_FUNC_ (rm_setpressure,                   RM_SETPRESSURE)
#define RM_SetRebalanceFraction            FC_FUNC_ (rm_setrebalancefraction,          RM_SETREBALANCEFRACTION)
#define RM_SetRebalanceByCell              FC_FUNC_ (rm_setrebalancebycell,            RM_SETREBALANCEBYCELL)
#define RM_SetSaturation                   FC_FUNC_ (rm_setsaturation,                 RM_SETSATURATION)
#define RM_SetSelectedOutputOn             FC_FUNC_ (rm_setselectedoutputon,           RM_SETSELECTEDOUTPUTON)
#define RM_SetTemperature                  FC_FUNC_ (rm_settemperature,                RM_SETTEMPERATURE)
#define RM_SetTime                         FC_FUNC_ (rm_settime,                       RM_SETTIME)
#define RM_SetTimeConversion               FC_FUNC_ (rm_settimeconversion,             RM_SETTIMECONVERSION)
#define RM_SetTimeStep                     FC_FUNC_ (rm_settimestep,                   RM_SETTIMESTEP)
#define RM_SetUnitsExchange                FC_FUNC_ (rm_setunitsexchange,              RM_SETUNITSEXCHANGE)
#define RM_SetUnitsGasPhase                FC_FUNC_ (rm_setunitsgasphase,              RM_SETUNITSGASPHASE)
#define RM_SetUnitsKinetics                FC_FUNC_ (rm_setunitskinetics,              RM_SETUNITSKINETICS)
#define RM_SetUnitsPPassemblage            FC_FUNC_ (rm_setunitsppassemblage,          RM_SETUNITSPPASSEMBLAGE)
#define RM_SetUnitsSolution                FC_FUNC_ (rm_setunitssolution,              RM_SETUNITSSOLUTION)
#define RM_SetUnitsSSassemblage            FC_FUNC_ (rm_setunitsssassemblage,          RM_SETUNITSSSASSEMBLAGE)
#define RM_SetUnitsSSassemblage            FC_FUNC_ (rm_setunitsssassemblage,          RM_SETUNITSSSASSEMBLAGE)
#define RM_SetUnitsSurface                 FC_FUNC_ (rm_setunitssurface,               RM_SETUNITSSURFACE)
#define RM_write_bc_raw                    FC_FUNC_ (rm_write_bc_raw,                  RM_WRITE_BC_RAW)
#define RM_WarningMessage                  FC_FUNC_ (rm_warningmessage,                RM_WARNINGMESSAGE)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/**
 *  Closes the output file and log file. 
 *  @see                 @ref RM_OpenFiles
 *  MPI:
 *       Root process only.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      SUBROUTINE RM_CloseFiles()
 *          IMPLICIT NONE
 *      END SUBROUTINE RM_CloseFiles
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_CloseFiles(int *id);
void       RM_convert_to_molal(int *id, double *c, int *n, int *dim);
int        RM_Concentrations2Utility(int *id, double *c, int *n, double *tc, double *p_atm);
/**
 *  Creates a reaction module. 
 *  @param nxyz                   The number of cells in the in the user's model.
 *  @param nthreads               When using OPENMP, the number of worker threads to be used (optional).
 *  @see                 @ref RM_Destroy
 *  MPI:
 *       Called by all processes.
 *       Nthreads has no effect on the MPI version, all processes have one worker thread.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *       INTEGER FUNCTION RM_Create(nxyz, nthreads) 
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: nxyz
 *          INTEGER, OPTIONAL, INTENT(in) :: nthreads
 *      END FUNCTION RM_Create
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
int RM_Create(int *nxyz, int *nthreads = NULL);
/**
 *  Provides a many-to-one mapping of cells in the user's model to cells for which chemistry need to be run. 
 *  @param id                   The instance id returned from @ref RM_Create.
 *  @param grid2chem            An nxyz list of values: Nonnegative is a chemistry cell number, negative is an inactive cell.
 *  @see                        ???
 *  The mapping is used to eliminate inactive cells and to use symmetry to decrease the number of cells for which chemistry must be run.
 *  Default is a one-to-one mapping; all user cells are chemistry cells (equivalent to grid2chem values of 0,1,2,3...).
 *  MPI:
 *     Called by all processes.
 *     All arguments required for root process.
 *     Except for id, arguments are optional for non-root processes. 
 *       
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      INTEGER FUNCTION RM_CreateMapping(id, grid2chem)
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *          INTEGER, OPTIONAL :: grid2chem
 *      END FUNCTION RM_CreateMapping
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_CreateMapping (int *id, int *grid2chem); 
IRM_RESULT RM_DecodeError (int *id, int *e); 
/**
 *  Destroys a reaction module. 
 *  @param id               The instance id returned from @ref RM_Create.
 *  @see                    @ref RM_Destroy
 *  MPI:
 *     Called by all processes.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>          
 *      INTEGER FUNCTION RM_Destroy(id)
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *      END FUNCTION RM_Destroy
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_Destroy(int *id);
/**
 *  Writes the contents of all workers to file in _RAW formats, including SOLUTIONs and all reactants.
 *  @param id               The instance id returned from @ref RM_Create.
 *  @param dump_on          Signal for writing the dump file: 1 true, 0 false.
 *  @param use_gz           Signal to use gz compression for the dump file: 1 true, 0 false.
 *  File name is prefix.dump or prefix.dump.gz.
 *  @see                    @ref RM_SetFilePrefix
 *  MPI:
 *     Called by all processes.
 *     Id and dump_on required for root process.
 *     Except for id, arguments are optional for non-root processes. 
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>         
 *      INTEGER FUNCTION RM_DumpModule(id, dump_on, use_gz) 
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *          INTEGER, OPTIONAL, INTENT(in) :: dump_on, use_gz
 *      END FUNCTION RM_DumpModule
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_DumpModule(int *id, int *dump_on = NULL, int *use_gz = NULL);
/**
 *  Aborts reaction all modules and stops program execution. 
 *  @param id                   The instance id returned from @ref RM_Create (optional).
 *  @see                 @ref RM_ErrorMessage
 *  @par Fortran90 Interface:
 *  MPI:
 *       Aborts program when called from any process.
 *  @htmlonly
 *  <CODE>
 *  <PRE>    
 *      SUBROUTINE RM_Error(id)
 *          IMPLICIT NONE
 *          INTEGER, OPTIONAL, INTENT(in) :: id
 *      END SUBROUTINE RM_Error
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
int RM_ErrorHandler(int *id, int *result, const char * err_str = NULL, size_t l = 0);
/**
 *  Send an error message to the screen, output file, and log file. 
 *  @param str           String to be sent.
 *  @param l             Length of the string buffer (automatic in Fortran, optional in C).
 *  @see                 RM_Error, RM_LogMessage, RM_ScreenMessage, RM_WarningMessage. 
 *  MPI:
 *       Can be called from any process.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>        
 *      SUBROUTINE RM_ErrorMessage(errstr)
 *          IMPLICIT NONE
 *          CHARACTER(*), INTENT(in) :: errstr
 *      END SUBROUTINE RM_ErrorMessage
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_ErrorMessage(int *id, const char *err_str, size_t l);
/**
 *  Returns the number of items in the list of elements included in solutions and reactants in the IPhreeqcPhast workers.
 *  @param id            The instance id returned from @ref RM_Create.
 *  @retval Number of components
 *  @retval If negative, IRM_RESULT error code.
 *  The list is the set of components that need to be transported.
 *  @see                 @ref RM_GetComponent 
 *  MPI:
 *     Called by all processes.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      INTEGER FUNCTION RM_FindComponents(id) 
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *      END FUNCTION RM_FindComponents  
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
int        RM_FindComponents(int *id);
/**
 *  Returns the number of chemistry cells in the reaction module.
 *  @param id            The instance id returned from @ref RM_Create.
 *  @retval Number of chemistry cells.
 *  @retval If negative, IRM_RESULT error code.
 *  The number of chemistry cells is determined by the mapping defined in RM_CreateMapping.
 *  The number of chemistry cells is less than or equal to the number of cells in the user's model.
 *  @see                 @ref RM_CreateMapping, @ref RM_GetGridCellCount. 
 *  MPI:
 *     Called by all processes.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      INTEGER FUNCTION RM_FindComponents(id) 
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *      END FUNCTION RM_FindComponents  
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
int        RM_GetChemistryCellCount(int *id);
/**
 *  Retrieves an item from the list of elements included in solutions and reactants in the IPhreeqcPhast workers.
 *  @param id            The instance id returned from @ref RM_Create.
 *  @param num           The number of the component to be retrieved (zero based, less than the result of RM_FindComponents).
 *  @param chem_name     The string value associated with component num.
 *  @retval IRM_OK
 *  @retval If negative, IRM_RESULT error code.
 *  @see                 @ref RM_FindComponents 
 *  MPI:
 *     Called by root.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      INTEGER FUNCTION RM_GetComponent(id, num, comp_name)
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id, num
 *          CHARACTER, INTENT(out) :: comp_name
 *      END FUNCTION RM_GetComponent 
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_GetComponent(int * id, int * num, char *chem_name, size_t l1);
/**
 *  Transfer concentrations from the module workers to the concentration an array of concentrations (c). 
 *  @param id                   The instance id returned from @ref RM_Create.
 *  @param c                    Array containing concentrations with dimensions equivalent to Fortran (nxyz, ncomps), where nxyz is the number of user grid cells and ncomps is the result of RM_FindComponents.
 *  @see                        @ref RM_FindComponents, @ref RM_Concentrations2Module, @ref RM_SetUnits
 *  Units of concentration for c are defined by the solution definition for RM_SetUnits.
 *  MPI:
 *     Called by all processes.
 *	   Id and c are required for the root process.
 *     Except for id, arguments are optional for non-root processes. 
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      SUBROUTINE RM_GetConcentrations(id, c)   
 *          IMPLICIT NONE
 *          INTEGER :: id
 *          DOUBLE PRECISION, OPTIONAL :: c
 *      END SUBROUTINE RM_GetConcentrations 
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_GetConcentrations(int *id, double *c);
IRM_RESULT RM_GetDensity(int *id, double *density);
IRM_RESULT RM_GetFilePrefix(int *id, char *prefix, size_t l);
/**
 *  Returns the number of grid cells in the user's model.
 *  @param id            The instance id returned from @ref RM_Create.
 *  @retval Number of grid cells in the user's model.
 *  @retval If negative, IRM_RESULT error code.
 *  The mapping from grid cells to chemistry cells is defined by RM_CreateMapping.
 *  The number of chemistry cells may be less than the number of grid cells if there are inactive regions or symmetry in the model definition.
 *  @see                 @ref RM_CreateMapping, @ref RM_GetChemistryCellCount. 
 *  MPI:
 *     Called by all processes.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      INTEGER FUNCTION RM_GetGridCellCount(id)
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *      END FUNCTION RM_GetGridCellCount
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
int        RM_GetGridCellCount(int *id);
int        RM_GetIPhreeqcId(int *id, int *i);
int        RM_GetMpiMyself(int *id);
int        RM_GetMpiTasks(int *id);
int        RM_GetNThreads(int *id);
int        RM_GetNthSelectedOutputUserNumber(int *id, int *i);
IRM_RESULT RM_GetSelectedOutput(int *id, double *so);
int        RM_GetSelectedOutputColumnCount(int *id);
int        RM_GetSelectedOutputCount(int *id);
IRM_RESULT RM_GetSelectedOutputHeading(int *id, int * icol, char * heading, size_t length);
int        RM_GetSelectedOutputRowCount(int *id);
IRM_RESULT RM_GetSolutionVolume(int *id, double *solution_volume);
double     RM_GetTime(int *id);
double     RM_GetTimeConversion(int *id);
double     RM_GetTimeStep(int *id);
/**
 *  Fills an array (c) with concentrations from solutions in the InitialPhreeqc instance, useful for obtaining concentrations for boundary conditions.
 *  @param id                  The instance id returned from @ref RM_Create.
 *  @param c                   Array of concentrations extracted from InitialPhreeqc. The dimension of c is equivalent to Fortran allocation (dim, ncomp), where ncomp is the number of components returned from RM_FindComponents.
 *  @param n_boundary          The number of boundary condition cells that need to be filled.
 *  @param dim                 The maximum number of boundary conditions cells that will fit in the c array.
 *  @param boundary_solution1  Array of solution index numbers (at least n_boundary long).
 *  @param boundary_solution2  Array of solution index numbers that are defined to mix with boundary_solution1 (dimensioned at least n_boundary) (optional).
 *  @param fraction1           Fraction of boundary_solution1 that mixes with (1-fraction1) of boundary_solution2 (dimensioned at least n_boundary) (optional).
 *  @retval IRM_OK
 *  @retval If negative, IRM_RESULT error code.
 *  If boundary_solution2 and fraction1 are omitted, no mixing is used; concentrations are derived from boundary_solution1 only.
 *  A negative value for boundary_solution2 implies no mixing, and the associated value for fraction1 is ignored. 
 *  @see                 @ref RM_FindComponents 
 *  MPI:
 *     Called by the root process.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE> 
 *      INTEGER FUNCTION RM_InitialPhreeqc2Concentrations(id, c, n_boundary, dim, bc_sol1, bc_sol2, f1)   
 *              IMPLICIT NONE
 *              INTEGER :: id
 *              DOUBLE PRECISION, INTENT(OUT) :: c
 *              INTEGER, INTENT(IN) :: n_boundary, dim, bc_sol1
 *              INTEGER, INTENT(IN), OPTIONAL :: bc_sol2
 *              DOUBLE PRECISION, INTENT(IN), OPTIONAL :: f1
 *      END FUNCTION RM_InitialPhreeqc2Concentrations    
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_InitialPhreeqc2Concentrations(
                int *id,
                double *c,
                int *n_boundary,
                int *boundary_solution1,  
                int *boundary_solution2 = NULL, 
                double *fraction1 = NULL);
/**
 *  Transfer results from the InitialPhreeqc IPhreeqc instance to the reaction module workers. 
 *  @param id                   The instance id returned from @ref RM_Create.
 *  @param initial_conditions1  Array containing index numbers of solutions and reactants.
 *  @param initial_conditions2  Array containing index numbers of solutions and reactants (optional).
 *  @param fraction1            Array containing fraction of initial_condition1 (when initial_conditions2 is defined) (optional).
 *
 *  The structure of the initial condition arrays are 1D equivalent to a Fortran allocation
 *  of (nxyz,7), that is the first nxyz elements are solution numbers. The order of indexes
 *  is as follows (1) SOLUTIONS, (2) EQUILIBRIUM_PHASES, (3) EXCHANGE, (4) SURFACE, (5) GAS_PHASE,
 *  (6) SOLID_SOLUTIONS, and (7) KINETICS.
 *  @see                 @ref RM_InitialPhreeqcRunFile
 *  MPI:
 *     Called by all processes.
 *	   Id and initial_conditions1 are required for the root process.
 *     Except for id, arguments are optional for non-root processes. 
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      INTEGER FUNCTION RM_InitialPhreeqc2Concentrations(id, c, n_boundary, dim, bc_sol1, bc_sol2, f1)   
 *              IMPLICIT NONE
 *              INTEGER :: id
 *              DOUBLE PRECISION, INTENT(OUT) :: c
 *              INTEGER, INTENT(IN) :: n_boundary, dim, bc_sol1
 *              INTEGER, INTENT(IN), OPTIONAL :: bc_sol2
 *              DOUBLE PRECISION, INTENT(IN), OPTIONAL :: f1
 *      END FUNCTION RM_InitialPhreeqc2Concentrations    
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_InitialPhreeqc2Module(int *id,
                int *initial_conditions1,		        // 7 x nxyz end-member 1
                int *initial_conditions2 = NULL,		// 7 x nxyz end-member 2
                double *fraction1 = NULL);			    // 7 x nxyz fraction of end-member 1
IRM_RESULT RM_InitialPhreeqcCell2Module(int *id,
                int *n,		                            // InitialPhreeqc cell number
                int *module_numbers,		            // Module cell numbers
                int *dim_module_numbers);			    // Number of module cell numbers
/**
 *  Load a database for the InitialPhreeqc and all worker IPhreeqc instances. 
 *  @param id            The instance id returned from @ref RM_Create.
 *  @param db_name       String containing the database name.
 *  @param l             Length of the db_name string buffer (automatic in Fortran, optional in C).
 *  @see                 ???
 *  MPI:
 *     Called by all processes.
 *     Except for id, arguments are optional for non-root processes.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      INTEGER FUNCTION RM_LoadDatabase(id, db) 
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *          CHARACTER, OPTIONAL, INTENT(in) :: db
 *      END FUNCTION RM_LoadDatabase 
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_LoadDatabase(int *id, const char *db_name, size_t l);
/**
 *  Send a message to the log file. 
 *  @param str           String to be sent.
 *  @param l             Length of the string buffer (automatic in Fortran, optional in C).
 *  @see                 RM_ErrorMessage, RM_ScreenMessage, RM_WarningMessage. 
 *  MPI:
 *     Can be called by any process.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>
 *      SUBROUTINE RM_LogMessage(str) 
 *          IMPLICIT NONE
 *          CHARACTER :: str
 *      END SUBROUTINE RM_LogMessage  
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_LogMessage(int * id, const char *str, size_t l);
IRM_RESULT RM_MpiWorker(int * id);
IRM_RESULT RM_MpiWorkerBreak(int * id);

/**
 *  Opens the output file and log file. 
 *  @see                  @ref RM_SetFilePrefix @ref RM_CloseFiles
 *  Files are named prefix.chem.txt and prefix.log.txt
 *  MPI:
 *       Has effect only for root process.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>        
 *      INTEGER FUNCTION RM_OpenFiles(id) 
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *      END FUNCTION RM_OpenFiles
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_OpenFiles(int * id);
IRM_RESULT RM_OutputMessage(int *id, const char * err_str, size_t l);
/**
 *  Transfer array of concentrations to the reaction module workers. 
 *  @param id            The instance id returned from @ref RM_Create.
 *  @param time          The current time of the simulation, in seconds.
 *  @param time_step     The time over which kinetic reactions will be integrated, in seconds.
 *  @param concentration The array of concentrations to be transferred (nxyz of component 1, nxyz component 2, ...)
 *  @param stop_msg      Signal the end of the simulation (1 stop, 0 continue).
 *  @see                 ???
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>
 *      INTEGER FUNCTION RM_RunCells(id)   
 *          IMPLICIT NONE
 *          INTEGER :: id
 *      END FUNCTION RM_RunCells     
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_RunCells(int *id);
/**
 *  Run a PHREEQC file by the InitialPhreeqc (and all worker IPhreeqc instances, currently). 
 *  @param id            The instance id returned from @ref RM_Create.
 *  @param chem_name     String containing the name of the PHREEQC file to run.
 *  @param l             Length of the chem_name string buffer (automatic in Fortran, optional in C).
 *  @see                 ???
 *  MPI:
 *     Called by all processes.
 *     Except for id, arguments are optional for non-root processes.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      INTEGER FUNCTION RM_RunFile(id, workers, initial_phreeqc,utility, chem_name)
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *          INTEGER, OPTIONAL, INTENT(in) :: initial_phreeqc, workers, utility
 *          CHARACTER, OPTIONAL, INTENT(in) :: chem_name
 *      END FUNCTION RM_RunFile 
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_RunFile(int *id, int * workers, int *initial_phreeqc, int *utility, const char *chem_name, size_t l);
/**
 *  Run a PHREEQC file by the InitialPhreeqc (and all worker IPhreeqc instances, currently). 
 *  @param id            The instance id returned from @ref RM_Create.
 *  @param chem_name     String containing the name of the PHREEQC file to run.
 *  @param l             Length of the chem_name string buffer (automatic in Fortran, optional in C).
 *  @see                 ???
 *  <H>
 *  MPI:
 *     Called by all processes.
 *     Except for id, arguments are optional for non-root processes.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>  
 *      INTEGER FUNCTION RM_RunFile(id, workers, initial_phreeqc, utility, input_string)
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *          INTEGER, OPTIONAL, INTENT(in) :: initial_phreeqc, workers, utility
 *          CHARACTER, OPTIONAL, INTENT(in) :: input_string
 *      END FUNCTION RM_RunFile 
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_RunString(int *id, int * workers, int *initial_phreeqc, int *utility, const char * input_string, size_t l);
/**
 *  Send a message to the screen. 
 *  @param str           String to be sent to the screen.
 *  @param l             Length of the string buffer (automatic in Fortran, optional in C).
 *  @see                 RM_ErrorMessage, RM_LogMessage, RM_WarningMessage. 
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>
 *      SUBROUTINE RM_ScreenMessage(str) 
 *          IMPLICIT NONE
 *          CHARACTER :: str
 *      END SUBROUTINE RM_ScreenMessage     
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_ScreenMessage(int *id, const char *str, size_t l);
IRM_RESULT RM_SetCellVolume(int *id, double *t);
IRM_RESULT RM_SetConcentrations(int *id, double *t);
IRM_RESULT RM_SetCurrentSelectedOutputUserNumber(int *id, int *i);
IRM_RESULT RM_SetDensity(int *id, double *t);
IRM_RESULT RM_SetDumpFileName(int *id, const char *dump_name, size_t l);
IRM_RESULT RM_SetErrorHandlerMode(int *id, int *mode);
IRM_RESULT RM_SetFilePrefix(int *id, const char *prefix, size_t l);
IRM_RESULT RM_SetMpiWorkerCallback(int *id, int (*fcn)(int *x1));
IRM_RESULT RM_SetPartitionUZSolids(int *id, int *t);
IRM_RESULT RM_SetPoreVolume(int *id, double *t);
//IRM_RESULT RM_SetPoreVolumeZero(int *id, double *t);
IRM_RESULT RM_SetPrintChemistryOn(int *id, int *worker, int *ip, int *utility);
IRM_RESULT RM_SetPrintChemistryMask(int *id, int *t);
IRM_RESULT RM_SetPressure(int *id, double *t);
IRM_RESULT RM_SetRebalanceFraction(int *id, double *f);
IRM_RESULT RM_SetRebalanceByCell(int *id, int *method);
IRM_RESULT RM_SetSaturation(int *id, double *t);
IRM_RESULT RM_SetSelectedOutputOn(int *id, int *selected_output);
IRM_RESULT RM_SetTemperature(int *id, double *t);
IRM_RESULT RM_SetTime(int *id, double *t);
IRM_RESULT RM_SetTimeConversion(int *id, double *t);
IRM_RESULT RM_SetTimeStep(int *id, double *t);
IRM_RESULT RM_SetUnitsExchange(int *id, int *i);
IRM_RESULT RM_SetUnitsGasPhase(int *id, int *i);
IRM_RESULT RM_SetUnitsKinetics(int *id, int *i);
IRM_RESULT RM_SetUnitsPPassemblage(int *id, int *i);
IRM_RESULT RM_SetUnitsSolution(int *id, int *i);
IRM_RESULT RM_SetUnitsSSassemblage(int *id, int *i);
IRM_RESULT RM_SetUnitsSurface(int *id, int *i);
/**
 *  Send an warning message to the screen and log file. 
 *  @param str           String to be sent.
 *  @param l             Length of the string buffer (automatic in Fortran, optional in C).
 *  @see                 RM_ErrorMessage, RM_LogMessage, RM_ScreenMessage. 
 *  MPI:
 *       Can be called from any process.
 *  @par Fortran90 Interface:
 *  @htmlonly
 *  <CODE>
 *  <PRE>        
 *      SUBROUTINE RM_ErrorMessage(errstr)
 *          IMPLICIT NONE
 *          CHARACTER(*), INTENT(in) :: errstr
 *      END SUBROUTINE RM_ErrorMessage
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
IRM_RESULT RM_WarningMessage(int *id, const char *warn_str, size_t l);
void       RM_write_bc_raw(int *id, 
                int *solution_list, 
                int * bc_solution_count, 
                int * solution_number, 
                char *prefix, 
                size_t prefix_l);

#if defined(__cplusplus)
}
#endif

#endif // RM_INTERFACE_H
