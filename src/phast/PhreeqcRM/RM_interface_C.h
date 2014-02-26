/*! @file RM_interface_C.h
	@brief C/Fortran Documentation
*/#ifndef RM_INTERFACE_C_H
#define RM_INTERFACE_C_H

#if defined(__cplusplus)
extern "C" {
#endif
/**
Abort the program. Result will be interpreted as
an IRM_RESULT value and decoded; err_str will be printed; and the reaction module
will be destroyed. If using MPI, an MPI_Abort message will be sent before the reaction
module is destroyed. If the id is an invalid instance, RM_Abort will return a value of 
IRM_BADINSTANCE, otherwise the program will exit with a return code of 4.
@param id            The instance id returned from @ref RM_Create.
@param result        Integer treated as an IRM_RESULT return code. 
@param err_str       String to be printed as an error message. 
@retval IRM_RESULT   Program will exit before returning unless id is an invalid reaction module id.
@see                 @ref RM_Destroy, @ref RM_ErrorMessage.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_Abort(int id, int result, const char * err_str);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
iphreeqc_id = RM_Concentrations2Utility(id, c_well, 1, tc, p_atm);
strcpy(str, "SELECTED_OUTPUT 5; -pH; RUN_CELLS; -cells 1");
status = RunString(iphreeqc_id, str);
if (status != 0) status = RM_Abort(id, status, "IPhreeqc RunString failed");
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE> 
INTEGER FUNCTION RM_Abort(id, result, str)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: result
  CHARACTER, INTENT(in) :: str
END FUNCTION RM_Abort
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  	
iphreeqc_id = RM_Concentrations2Utility(id, c_well(1,1), 1, tc(1), p_atm(1))
string = "SELECTED_OUTPUT 5; -pH;RUN_CELLS; -cells 1"
status = RunString(iphreeqc_id, string)
if (status .ne. 0) status = RM_Abort(id, status, "IPhreeqc RunString failed");
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root or workers.
*/
int RM_Abort(int id, int result, const char * err_str);
/**
Close the output and log files. 
@param id            The instance id returned from @ref RM_Create.
@retval IRM_RESULT   0 is success, negative is failure (See @ref RM_DecodeError).  
@see                 @ref RM_OpenFiles, @ref RM_SetFilePrefix
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_CloseFiles(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
status = RM_CloseFiles(id);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>  
INTEGER FUNCTION RM_CloseFiles(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_CloseFiles
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
status = RM_CloseFiles(id)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called only by root.
 */
int        RM_CloseFiles(int id);
/**
N sets of component concentrations are converted to SOLUTIONs numbered 1-n in the Utility IPhreeqc.
The solutions can be reacted and manipulated with the methods of IPhreeqc. The motivation for this
method is the mixing of solutions in wells, where it may be necessary to calculate solution properties
(pH for example) or react the mixture to form scale minerals. The code fragments below make a mixture of
concentrations and then calculate the pH of the mixture.
@param id            The instance id returned from @ref RM_Create.
@param c             Array of concentrations to be made SOLUTIONs in Utility IPhreeqc. Array storage is equivalent to Fortran (n,ncomps).
@param n             The number of sets of concentrations.
@param tc            Array of temperatures to apply to the SOLUTIONs. Array of size n.
@param p_atm         Array of pressures to apply to the SOLUTIONs. Array of size n.
@retval IRM_RESULT   0 is success, negative is failure (See @ref RM_DecodeError).  
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_Concentrations2Utility(int id, double *c, int n, double *tc, double *p_atm);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
c_well = (double *) malloc((size_t) ((size_t) (1 * ncomps * sizeof(double))));
for (i = 0; i < ncomps; i++)
{
  c_well[i] = 0.5 * c[0 + nxyz*i] + 0.5 * c[9 + nxyz*i];
}
tc = (double *) malloc((size_t) (1 * sizeof(double)));
p_atm = (double *) malloc((size_t) (1 * sizeof(double)));
tc[0] = 15.0;
p_atm[0] = 3.0;
iphreeqc_id = RM_Concentrations2Utility(id, c_well, 1, tc, p_atm);
strcpy(str, "SELECTED_OUTPUT 5; -pH; RUN_CELLS; -cells 1");
status = RunString(iphreeqc_id, str);
status = SetCurrentSelectedOutputUserNumber(iphreeqc_id, 5);
status = GetSelectedOutputValue2(iphreeqc_id, 1, 0, &vtype, &pH, svalue, 100);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>  
INTEGER FUNCTION RM_Concentrations2Utility(id, c, n, tc, p_atm)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  DOUBLE PRECISION, INTENT(in) :: c
  INTEGER, INTENT(in) :: n
  DOUBLE PRECISION, INTENT(in) :: tc, p_atm
END FUNCTION RM_Concentrations2Utility  
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
allocate (c_well(1,ncomps))
do i = 1, ncomps
  c_well(1,i) = 0.5 * c(1,i) + 0.5 * c(10,i)
enddo
allocate(tc(1), p_atm(1))
tc(1) = 15.0
p_atm(1) = 3.0
iphreeqc_id = RM_Concentrations2Utility(id, c_well(1,1), 1, tc(1), p_atm(1))
string = "SELECTED_OUTPUT 5; -pH; RUN_CELLS; -cells 1"
status = RunString(iphreeqc_id, string)
status = SetCurrentSelectedOutputUserNumber(iphreeqc_id, 5);
status = GetSelectedOutputValue(iphreeqc_id, 1, 1, vtype, pH, svalue)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called only by root.
 */
int        RM_Concentrations2Utility(int id, double *c, int n, double *tc, double *p_atm);
/**
Creates a reaction module. 
@param id                     The instance id returned from @ref RM_Create.
@param nxyz                   The number of grid cells in the in the user's model.
@param nthreads               When using OPENMP, the number of worker threads to be used. 
If nthreads is <= 0, the number of threads is set equal to the number of processors of the computer.
@retval Id of the PhreeqcRM instance, negative is failure (See @ref RM_DecodeError).  
@see                 @ref RM_Destroy
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_Create(int nxyz, int nthreads);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
id = RM_Create(nxyz, nthreads);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_Create(nxyz, nthreads) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: nxyz
  INTEGER, INTENT(in), OPTIONAL :: nthreads
END FUNCTION RM_Create
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
id = RM_create(nxyz, nthreads)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and workers. The value of nthreads is ignored.
 */
int RM_Create(int nxyz, int nthreads);
/**
Provides a mapping from grid cells in the user's model to cells for which chemistry needs to be run. 
The mapping is used to eliminate inactive cells and to use symmetry to decrease the number of cells for which chemistry must be run. The mapping may be many-to-one to account for symmetry.
Default is a one-to-one mapping--all user grid cells are chemistry cells (equivalent to grid2chem values of 0,1,2,3,...,nxyz-1).
@param id                   The instance id returned from @ref RM_Create.
@param grid2chem            An array of integers: Nonnegative is a chemistry cell number, negative is an inactive cell. Array of size nxyz (number of grid cells).
@retval IRM_RESULT         0 is success, negative is failure (See @ref RM_DecodeError). 
     
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_CreateMapping (int id, int *grid2chem);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
// For demonstation, two equivalent rows by symmetry
grid2chem = (int *) malloc((size_t) (nxyz * sizeof(int)));
for (i = 0; i < nxyz/2; i++) 
{
  grid2chem[i] = i;
  grid2chem[i+nxyz/2] = i;
}
status = RM_CreateMapping(id, grid2chem);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>
INTEGER FUNCTION RM_CreateMapping(id, grid2chem)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: grid2chem
END FUNCTION RM_CreateMappingM_Create
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>     
! For demonstation, two equivalent rows by symmetry
allocate(grid2chem(nxyz))
do i = 1, nxyz/2
  grid2chem(i) = i - 1
  grid2chem(i+nxyz/2) = i - 1
enddo
status = RM_CreateMapping(id, grid2chem(1))  
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_CreateMapping (int id, int *grid2chem);
/**
If e is negative, this method prints an error message corresponding to IRM_RESULT e. If e is non-negative, this method does nothing.
@param id                   The instance id returned from @ref RM_Create.
@param e                    An IRM_RESULT value returned by one of the reaction module methods.
@retval IRM_RESULT          0 is success, negative is failure (See @ref RM_DecodeError). 
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
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_DecodeError (int id, int e); 
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
status = RM_CreateMapping(id, grid2chem);
if (status < 0) status = RM_DecodeError(id, status);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>
INTEGER FUNCTION RM_DecodeError(id, e)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: e
END FUNCTION RM_DecodeError
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>     
status = RM_CreateMapping(id, grid2chem(1))  
if (status < 0) status = RM_DecodeError(id, status)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Can be called by root and (or) workers.
 */
int RM_DecodeError (int id, int e); 
/**
Destroys a reaction module. 
@param id               The instance id returned from @ref RM_Create.
@retval IRM_RESULT   0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_Create
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_Destroy(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
status = RM_Destroy(id);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_Destroy(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_Destroy
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
status = RM_Destroy(id)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and workers.
 */
int RM_Destroy(int id);
/**
Writes the contents of all workers to file in _RAW formats, including SOLUTIONs and all reactants.
@param id               The instance id returned from @ref RM_Create.
@param dump_on          Signal for writing the dump file: 1 true, 0 false.
@param append           Signal to append to the contents of the dump file: 1 true, 0 false.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_SetDumpFileName
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_DumpModule(int id, int dump_on, int append);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  		
dump_on = 1;
append = 0;
status = RM_SetDumpFileName(id, "advection_c.dmp.gz");
status = RM_DumpModule(id, dump_on, append);  
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE> 
INTEGER FUNCTION RM_DumpModule(id, dump_on, append) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: dump_on
  INTEGER, INTENT(in) :: append
END FUNCTION RM_DumpModule
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>      dump_on = 1
append = 0
status = RM_SetDumpFileName(id, "advection_f90.dmp.gz")    
status = RM_DumpModule(id, dump_on, append)  
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root; workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_DumpModule(int id, int dump_on, int append);
/**
Send an error message to the screen, the output file, and the log file. 
@param id               The instance id returned from @ref RM_Create.
@param errstr           String to be printed.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_OpenFiles, @ref RM_LogMessage, @ref RM_ScreenMessage, @ref RM_WarningMessage. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_ErrorMessage(int id, const char *errstr);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
status = RM_ErrorMessage(id, "Goodby world");
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_ErrorMessage(id, errstr)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  CHARACTER, INTENT(in) :: errstr
END FUNCTION RM_ErrorMessage
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
status = RM_ErrorMessage(id, "Goodby world")
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers; root writes to output and log files.
 */
int RM_ErrorMessage(int id, const char *errstr);
/**
Returns the number of items in the list of all elements in the Initial Phreeqc instance. Elements are those that have been defined in a solution or any other reactant (EQUILIBRIUM_PHASE, KINETICS, and others). 
The method can be called multiple times and the list that is created is cummulative. 
The list is the set of components that needs to be transported.
@param id            The instance id returned from @ref RM_Create.
@retval              Number of components currently in the list, or IRM_RESULT error code (see @ref RM_DecodeError).
@see                 @ref RM_GetComponent 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_FindComponents(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
// Get list of components
ncomps = RM_FindComponents(id);
components = (char **) malloc((size_t) (ncomps * sizeof(char *)));
for (i = 0; i < ncomps; i++)
{
  components[i] = (char *) malloc((size_t) (100 * sizeof(char *)));
  status = RM_GetComponent(id, i, components[i], 100);
}
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>
INTEGER FUNCTION RM_FindComponents(id) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_FindComponents  
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>
! Get list of components
ncomps = RM_FindComponents(id)
allocate(components(ncomps))
do i = 1, ncomps
  status = RM_GetComponent(id, i, components(i))
enddo
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int        RM_FindComponents(int id);
/**
Returns the number of chemistry cells in the reaction module. The number of chemistry cells is defined by 
the set of non-negative integers in the mapping from user grid cells (@ref RM_CreateMapping). 
The number of chemistry cells is less than or equal to the number of cells in the user's model.
@param id            The instance id returned from @ref RM_Create.
@retval              Number of chemistry cells, or IRM_RESULT error code (see @ref RM_DecodeError).
@see                 @ref RM_CreateMapping, @ref RM_GetGridCellCount. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetChemistryCellCount(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
status = RM_CreateMapping(id, grid2chem);
nchem = RM_GetChemistryCellCount(id);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetChemistryCellCount(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetChemistryCellCount 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
status = RM_CreateMapping(id, grid2chem)
nchem = RM_GetChemistryCellCount(id)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
int        RM_GetChemistryCellCount(int id);
/**
Retrieves an item from the reaction-module component list that was generated by calls to @ref RM_FindComponents.
@param id               The instance id returned from @ref RM_Create.
@param num              The number of the component to be retrieved (zero based, 
less than the result of @ref RM_FindComponents or @ref RM_GetComponentCount).
@param chem_name        The string value associated with component num (output).
@param l                The length of the maximum number of characters for chem_name (C only).
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_FindComponents, @ref RM_GetComponentCount 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetComponent(int id, int num, char *chem_name, int l);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
// Get list of components
ncomps = RM_FindComponents(id);
components = (char **) malloc((size_t) (ncomps * sizeof(char *)));
for (i = 0; i < ncomps; i++)
{
  components[i] = (char *) malloc((size_t) (100 * sizeof(char *)));
  status = RM_GetComponent(id, i, components[i], 100);
}
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetComponent(id, num, comp_name)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id, num
  CHARACTER, INTENT(out) :: comp_name
END FUNCTION RM_GetComponent 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
! Get list of components
ncomps = RM_FindComponents(id)
allocate(components(ncomps))
do i = 1, ncomps
  status = RM_GetComponent(id, i, components(i))
enddo
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int RM_GetComponent(int id, int num, char *chem_name, int l);
/**
Returns the number of components in the reaction-module component list. 
@param id               The instance id returned from @ref RM_Create.   
@retval                 The number of components in the reaction module component list. The component list is generated by calls to @ref RM_FindComponents. 
The return value from the last call to @ref RM_FindComponents is equal to the return value from RM_GetComponentCount.
@see                    @ref RM_FindComponents, @ref RM_GetComponent.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetComponentCount(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
ncomps1 = RM_GetComponentCount(id);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetComponentCount(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetComponentCount 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
ncomps1 = RM_GetComponentCount(id)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int RM_GetComponentCount(int id);
/**
Transfer solution concentrations from each cell to the concentration array given in the argument list (c). 
Units of concentration for c are defined by @ref RM_SetUnitsSolution. For concentration units of per liter, the 
calculated solution volume is used to calculate the concentrations for c. Of the databases distributed with PhreeqcRM,
only phreeqc.dat, Amm.dat, and pitzer.dat have the partial molar volume definitions needed to calculate solution volume. 
Mass fraction concentration units do not require the solution volume to fill the c array (but, density is needed to
convert transport concentrations to cell solution concentrations, @ref RM_SetConcentrations).
@param id               The instance id returned from @ref RM_Create.
@param c                Array to receive the concentrations. Dimension of the array is equivalent to Fortran (nxyz, ncomps), 
where nxyz is the number of user grid cells and ncomps is the result of @ref RM_FindComponents or @ref RM_GetComponentCount.  Values for inactive cells are set to 1e30.
@see                    @ref RM_FindComponents, @ref RM_GetComponentCount, @ref RM_Concentrations2Module, @ref RM_SetUnitsSolution
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetConcentrations(int id, double *c);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
c = (double *) malloc((size_t) (ncomps * nxyz * sizeof(double)));
status = RM_RunCells(id); 
status = RM_GetConcentrations(id, c);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetConcentrations(id, c)   
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  DOUBLE PRECISION, INTENT(out)  :: c
END FUNCTION RM_GetConcentrations 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
allocate(c(nxyz, ncomps))
status = RM_RunCells(id) 
status = RM_GetConcentrations(id, c(1,1))
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_GetConcentrations(int id, double *c);
/**
Transfer solution densities from the module workers to the density array given in the argument list (density). 
@param id                   The instance id returned from @ref RM_Create.
@param density              Array to receive the densities. Dimension of the array is (nxyz), 
where nxyz is the number of user grid cells. Values for inactive cells are set to 1e30. Densities are those calculated by the reaction module. 
Only the following databases distributed with PhreeqcRM have molar volume information needed to calculate density: 
phreeqc.dat, Amm.dat, and pitzer.dat.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetDensity(int id, double *density);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
density = (double *) malloc((size_t) (nxyz * sizeof(double)));
status = RM_RunCells(id); 
status = RM_GetDensity(id, density);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetDensity(id, density)   
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  DOUBLE PRECISION, INTENT(out) :: density
END FUNCTION RM_GetDensity 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
allocate(density(nxyz))
status = RM_RunCells(id)  
status = RM_GetDensity(id, density(1))
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_GetDensity(int id, double *density);
/**
Returns the reaction-module file prefix to the character argument (prefix). 
@param id               The instance id returned from @ref RM_Create. 
@param prefix           Character string where the prefix is written.
@param l                Maximum number of characters that can be written to the argument (prefix) (C only). 
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError).  
@see                    @ref RM_SetFilePrefix.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetFilePrefix(int id, char *prefix, int l);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
char str[100], str1[200];
status = RM_GetFilePrefix(id, str, 100);
strcpy(str1, "File prefix: ");
strcat(str1, str);
strcat(str1, "\n");
status = RM_OutputMessage(id, str1);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetFilePrefix(id, prefix)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  CHARACTER, INTENT(out) :: prefix
END FUNCTION RM_GetFilePrefix
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
character(100) :: string
character(200) :: string1
status = RM_GetFilePrefix(id, string)
string1 = "File prefix: "//string;
status = RM_OutputMessage(id, string1)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers. 
 */
int RM_GetFilePrefix(int id, char *prefix, int l);
/**
Returns the gram formula weights (g/mol) for the components in the reaction-module component list. 
@param id               The instance id returned from @ref RM_Create. 
@param gfw              Array to receive the gram formula weights. Dimension of the array is (ncomps), 
where ncomps is the number of components in the component list. 
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError).  
@see                    @ref RM_FindComponents, @ref RM_GetComponentCount, @ref RM_GetComponent.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetGfw(int id, double * gfw);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
ncomps = RM_FindComponents(id);
components = (char **) malloc((size_t) (ncomps * sizeof(char *)));
gfw = (double *) malloc((size_t) (ncomps * sizeof(double)));
status = RM_GetGfw(id, gfw);
for (i = 0; i < ncomps; i++)
{
  components[i] = (char *) malloc((size_t) (100 * sizeof(char *)));
  status = RM_GetComponent(id, i, components[i], 100);
  sprintf(str,"%10s    %10.3f\n", components[i], gfw[i]);
  status = RM_OutputMessage(id, str);
}
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetGfw(id, gfw)   
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  DOUBLE PRECISION, INTENT(out) :: gfw
END FUNCTION RM_GetGfw 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
character(100),   dimension(:), allocatable   :: components
double precision, dimension(:), allocatable   :: gfw
ncomps = RM_FindComponents(id)
allocate(components(ncomps))
allocate(gfw(ncomps))
status = RM_GetGfw(id, gfw(1))
do i = 1, ncomps
  status = RM_GetComponent(id, i, components(i))
  write(string,"(A10, F15.4)") components(i), gfw(i)
  status = RM_OutputMessage(id, string)
enddo 
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root. 
 */
int RM_GetGfw(int id, double * gfw);
/**
Returns the number of grid cells in the user's model, which is defined in the call to @ref RM_Create. 
The mapping from grid cells to chemistry cells is defined by @ref RM_CreateMapping.
The number of chemistry cells may be less than the number of grid cells if 
there are inactive regions or symmetry in the model definition.
@param id               The instance id returned from @ref RM_Create. 
@retval                 Number of grid cells in the user's model, negative is failure (See @ref RM_DecodeError).
@see                    @ref RM_Create,  @ref RM_CreateMapping.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetGridCellCount(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE> 
nxyz = RM_GetGridCellCount(id);
sprintf(str1, "Number of grid cells in the user's model: %d\n", nxyz);
status = RM_OutputMessage(id, str1);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetGridCellCount(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetGridCellCount
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
nxyz = RM_GetGridCellCount(id)
write(string1, "(A,I)") "Number of grid cells in the user's model: ", nxyz
status = RM_OutputMessage(id, trim(string1))
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
int        RM_GetGridCellCount(int id);
/**
Returns an IPhreeqc id for one of the IPhreeqc instances in the reaction module. 
The threaded version has nthreads, as defined in @ref RM_Create.
The number of threads can be determined by @ref RM_GetThreadCount.
There will be nthreads + 2 IPhreeqc instances. The first nthreads will be the workers, the
next is the InitialPhreeqc instance, and the next is the Utility instance. Getting
the IPhreeqc id for one of these allows the user to use any of the IPhreeqc methods
on that instance. For MPI, each process has three IPhreeqc instances, one worker, 
one InitialPhreeqc instance, and one Utility instance.
@param id               The instance id returned from @ref RM_Create. 
@param i                The number of the IPhreeqc instance (0 based). 
@retval                 IPhreeqc id for the ith IPhreeqc instance, negative is failure (See @ref RM_DecodeError).
@see                    @ref RM_Create, @ref RM_GetThreadCount, documentation for IPhreeqc.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetIPhreeqcId(int id, int i);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE> 		
iphreeqc_id = RM_GetIPhreeqcId(id, nthreads + 1); // Utility instance 
strcpy(str, "SELECTED_OUTPUT 5; -pH; SOLUTION 1; RUN_CELLS; -cells 1");
status = RunString(iphreeqc_id, str);
status = SetCurrentSelectedOutputUserNumber(iphreeqc_id, 5);
status = GetSelectedOutputValue2(iphreeqc_id, 1, 0, &vtype, &pH, svalue, 100);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetIPhreeqcId(id, i)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: i
END FUNCTION RM_GetIPhreeqcId
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
iphreeqc_id = RM_GetIPhreeqcId(id, nthreads + 1) ! Utility instance
string = "SELECTED_OUTPUT 5; -pH;RUN_CELLS; -cells 1"
status = RunString(iphreeqc_id, string)
status = SetCurrentSelectedOutputUserNumber(iphreeqc_id, 5);
status = GetSelectedOutputValue(iphreeqc_id, 1, 1, vtype, pH, svalue)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
int        RM_GetIPhreeqcId(int id, int i);
/**
Returns the MPI task number. For the threaded version, the task number is always
zero and the result of @ref RM_GetMpiTasks is one. For the MPI version, 
the root task number is zero, and all workers have a task number greater than zero.
The number of tasks can be obtained with @ref RM_GetMpiTasks. The number of 
tasks and computer hosts are determined at run time by the mpiexec command.
@param id               The instance id returned from @ref RM_Create.  
@retval                 The MPI task number for a process, negative is failure (See @ref RM_DecodeError).
@see                    @ref RM_GetMpiTasks.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetMpiMyself(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>
mpi_myself = RM_GetMpiMyself(id);
if (mpi_myself == 0) 
{
  sprintf(str1, "I am root\n");
}
else
{
  sprintf(str1, "I am worker %d\n", mpi_myself);
}
status = RM_OutputMessage(id, str1);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetMpiMyself(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetMpiMyself
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
mpi_myself = RM_GetMpiMyself(id)
if (mpi_myself .eq. 0) then
  write(string1, "(A)") "I am root"
else
  write(string1, "(A,I)") "I am worker ", mpi_myself
endif
status = RM_OutputMessage(id, string1)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
int        RM_GetMpiMyself(int id);
/**
Returns the number of MPI processes (tasks). For the threaded version, the number of tasks is always
one (although there may be multiple threads, @ref RM_GetThreadCount), 
and the task number returned by @ref RM_GetMpiMyself is zero. For the MPI version, the number of 
tasks and computer hosts are determined at run time by the mpiexec command.
The root task number is zero, and all workers have a task number greater than zero.
@param id               The instance id returned from @ref RM_Create.  
@retval                 The number of MPI processes, negative is failure (See @ref RM_DecodeError).
@see                    @ref RM_GetMpiMyself.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetMpiTasks(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>
mpi_tasks = RM_GetMpiTasks(id);
sprintf(str1, "Number of MPI processes: %d\n", mpi_tasks);
status = RM_OutputMessage(id, str1);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetMpiTasks(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetMpiTasks
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
mpi_tasks = RM_GetMpiTasks(id)
write(string1, "(A,I)") "Number of MPI processes: ", mpi_tasks
status = RM_OutputMessage(id, string1)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
int        RM_GetMpiTasks(int id);
/**
Returns the user number for the nth selected output definition. 
Definitions are sorted by user number. Phreeqc allows multiple selected output
definitions, each of which is assigned a nonnegative integer identifier by the 
user. The number of definitions can be obtained by @ref RM_GetSelectedOutputCount.
To cycle through all of the definitions, RM_GetNthSelectedOutputUserNumber 
can be used to identify the user number for each selected output definition
in sequence. @ref RM_SetCurrentSelectedOutputUserNumber is then used to select
that user number for selected output processing.
@param id               The instance id returned from @ref RM_Create. 
@param n                The sequence number of the selected output definition for which the user number will be returned.  
@retval                 The user number of the nth selected output definition, negative is failure (See @ref RM_DecodeError).
@see                    @ref RM_GetSelectedOutput, 
@ref RM_GetSelectedOutputColumnCount, @ref RM_GetSelectedOutputCount, 
@ref RM_GetSelectedOutputHeading,
@ref RM_GetSelectedOutputRowCount, @ref RM_SetCurrentSelectedOutputUserNumber, @ref RM_SetSelectedOutputOn.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetNthSelectedOutputUserNumber(int id, int n);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>				
for (isel = 0; isel < RM_GetSelectedOutputCount(id); isel++)
{
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  fprintf(stderr, "Selected output sequence number: %d\n", isel);
  fprintf(stderr, "Selected output user number:     %d\n", n_user);
  col = RM_GetSelectedOutputColumnCount(id);
  selected_out = (double *) malloc((size_t) (col * nxyz * sizeof(double)));
  status = RM_GetSelectedOutput(id, selected_out);
  // Process results here
  free(selected_out);
}
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetNthSelectedOutputUserNumber(id, n)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id, n
END FUNCTION RM_GetNthSelectedOutputUserNumber
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>           
do isel = 1, RM_GetSelectedOutputCount(id)
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel - 1);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  write(*,*) "Selected output sequence number: ", isel);
  write(*,*) "Selected output user number:     ", n_user);
  col = RM_GetSelectedOutputColumnCount(id)
  allocate(selected_out(nxyz,col))
  status = RM_GetSelectedOutput(id, selected_out(1,1))
  ! Process results here
  deallocate(selected_out)
enddo
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int        RM_GetNthSelectedOutputUserNumber(int id, int n);
/**
Populates an array with values from the current selected output definition. @ref RM_SetCurrentSelectedOutputUserNumber 
determines which of the selected output definitions is used to populate the array. 
@param id               The instance id returned from @ref RM_Create. 
@param so               An array to contain the selected output value. Size of the array is equivalent to Fortran  (nxyz, col), 
where nxyz is the number of grid cells in the user's model (@ref RM_GetGridCellCount), and col is the number of 
columns in the selected output definition (@ref RM_GetSelectedOutputColumnCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_GetNthSelectedOutputUserNumber, 
@ref RM_GetSelectedOutputColumnCount, @ref RM_GetSelectedOutputCount, @ref RM_GetSelectedOutputHeading,
@ref RM_GetSelectedOutputRowCount, @ref RM_SetCurrentSelectedOutputUserNumber, @ref RM_SetSelectedOutputOn.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetSelectedOutput(int id, double *so);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>				
for (isel = 0; isel < RM_GetSelectedOutputCount(id); isel++)
{
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  col = RM_GetSelectedOutputColumnCount(id);
  selected_out = (double *) malloc((size_t) (col * nxyz * sizeof(double)));
  status = RM_GetSelectedOutput(id, selected_out);
  // Process results here
  free(selected_out);
}
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetSelectedOutput(id, so)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  DOUBLE PRECISION, INTENT(out) :: so
END FUNCTION RM_GetSelectedOutput
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>           
do isel = 1, RM_GetSelectedOutputCount(id)
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel - 1);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  col = RM_GetSelectedOutputColumnCount(id)
  allocate(selected_out(nxyz,col))
  status = RM_GetSelectedOutput(id, selected_out(1,1))
  ! Process results here
  deallocate(selected_out)
enddo
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int        RM_GetSelectedOutput(int id, double *so);
/**
Returns the number of columns in the current selected output definition. @ref RM_SetCurrentSelectedOutputUserNumber 
determines which of the selected output definitions is used. 
@param id               The instance id returned from @ref RM_Create. 
@retval                 Number of columns in the current selected output definition, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_GetNthSelectedOutputUserNumber, @ref RM_GetSelectedOutput,
@ref RM_GetSelectedOutputCount, @ref RM_GetSelectedOutputHeading,
@ref RM_GetSelectedOutputRowCount, @ref RM_SetCurrentSelectedOutputUserNumber, @ref RM_SetSelectedOutputOn.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetSelectedOutputColumnCount(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>				
for (isel = 0; isel < RM_GetSelectedOutputCount(id); isel++)
{
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  col = RM_GetSelectedOutputColumnCount(id);
  selected_out = (double *) malloc((size_t) (col * nxyz * sizeof(double)));
  status = RM_GetSelectedOutput(id, selected_out);
  // Process results here
  free(selected_out);
}
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetSelectedOutputColumnCount(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetSelectedOutputColumnCount
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>           
do isel = 1, RM_GetSelectedOutputCount(id)
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel - 1);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  col = RM_GetSelectedOutputColumnCount(id)
  allocate(selected_out(nxyz,col))
  status = RM_GetSelectedOutput(id, selected_out(1,1))
  ! Process results here
  deallocate(selected_out)
enddo
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int        RM_GetSelectedOutputColumnCount(int id);
/**
Returns the number of selected output definitions. @ref RM_SetCurrentSelectedOutputUserNumber 
determines which of the selected output definitions is used. 
@param id               The instance id returned from @ref RM_Create. 
@retval                 Number of selected output definitions, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_GetNthSelectedOutputUserNumber, @ref RM_GetSelectedOutput,
@ref RM_GetSelectedOutputColumnCount, @ref RM_GetSelectedOutputHeading,
@ref RM_GetSelectedOutputRowCount, @ref RM_SetCurrentSelectedOutputUserNumber, @ref RM_SetSelectedOutputOn.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetSelectedOutputCount(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>				
for (isel = 0; isel < RM_GetSelectedOutputCount(id); isel++)
{
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  col = RM_GetSelectedOutputColumnCount(id);
  selected_out = (double *) malloc((size_t) (col * nxyz * sizeof(double)));
  status = RM_GetSelectedOutput(id, selected_out);
  // Process results here
  free(selected_out);
}
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetSelectedOutputCount(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetSelectedOutputCount
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>           
do isel = 1, RM_GetSelectedOutputCount(id)
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel - 1);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  col = RM_GetSelectedOutputColumnCount(id)
  allocate(selected_out(nxyz,col))
  status = RM_GetSelectedOutput(id, selected_out(1,1))
  ! Process results here
  deallocate(selected_out)
enddo
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int        RM_GetSelectedOutputCount(int id);
/**
Returns the a selected output heading. The number of headings is determined by @ref RM_GetSelectedOutputColumnCount.
@ref RM_SetCurrentSelectedOutputUserNumber 
determines which of the selected output definitions is used. 
@param id               The instance id returned from @ref RM_Create. 
@param icol             The sequence number of the heading to be retrieved (0 based). 
@param heading          A string buffer to receive the heading. 
@param length           The maximum number of characters that can be written to the string buffer (C only). 
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError).  
@see                    @ref RM_GetNthSelectedOutputUserNumber, @ref RM_GetSelectedOutput,
@ref RM_GetSelectedOutputColumnCount, @ref RM_GetSelectedOutputCount, 
@ref RM_GetSelectedOutputRowCount, @ref RM_SetCurrentSelectedOutputUserNumber, @ref RM_SetSelectedOutputOn.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetSelectedOutputHeading(int id, int icol, char * heading, int length);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>
char heading[100];
for (isel = 0; isel < RM_GetSelectedOutputCount(id); isel++)
{
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  col = RM_GetSelectedOutputColumnCount(id);
  for (j = 0; j < col; j++)
  {
	status = RM_GetSelectedOutputHeading(id, j, heading, 100);  
	fprintf(stderr, "          %2d %10s\n", j, heading);
  }
}
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetSelectedOutputHeading(id, icol, heading)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id, icol
  CHARACTER, INTENT(out) :: heading
END FUNCTION RM_GetSelectedOutputHeading
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>           
do isel = 1, RM_GetSelectedOutputCount(id)
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel - 1);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  col = RM_GetSelectedOutputColumnCount(id)
  do j = 1, col
    status = RM_GetSelectedOutputHeading(id, j-1, heading)    
    write(*,'(10x,i2,A2,A10,A2,f10.4)') j, " ", trim(heading)
  enddo
enddo
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int        RM_GetSelectedOutputHeading(int id, int icol, char * heading, int length);
/**
Returns the number of rows in the current selected output definition. However, the method
is included only for convenience; the number of rows is always equal to the number of 
grid cells in the user's model, and is equal to @ref RM_GetGridCellCount.
@param id               The instance id returned from @ref RM_Create. 
@retval                 Number of rows in the current selected output definition, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_GetNthSelectedOutputUserNumber, @ref RM_GetSelectedOutput, @ref RM_GetSelectedOutputColumnCount,
@ref RM_GetSelectedOutputCount, @ref RM_GetSelectedOutputHeading,
@ref RM_SetCurrentSelectedOutputUserNumber, @ref RM_SetSelectedOutputOn.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetSelectedOutputRowCount(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>
for (isel = 0; isel < RM_GetSelectedOutputCount(id); isel++)
{
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  col = RM_GetSelectedOutputColumnCount(id);
  selected_out = (double *) malloc((size_t) (col * nxyz * sizeof(double)));
  status = RM_GetSelectedOutput(id, selected_out);
  // Print results
  for (i = 0; i < RM_GetSelectedOutputRowCount(id)/2; i++)
  {
    fprintf(stderr, "Cell number %d\n", i);
    fprintf(stderr, "     Selected output: \n");
    for (j = 0; j < col; j++)
    {
      status = RM_GetSelectedOutputHeading(id, j, heading, 100);  
      fprintf(stderr, "          %2d %10s: %10.4f\n", j, heading, selected_out[j*nxyz + i]);
    }
  }
  free(selected_out);
}
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetSelectedOutputRowCount(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetSelectedOutputRowCount
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>           
do isel = 1, RM_GetSelectedOutputCount(id)
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel - 1)
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user)
  col = RM_GetSelectedOutputColumnCount(id)
  allocate(selected_out(nxyz,col))
  status = RM_GetSelectedOutput(id, selected_out(1,1))
  ! Print results
  do i = 1, RM_GetSelectedOutputRowCount(id)
    write(*,*) "Cell number ", i
    write(*,*) "     Selected output: "
    do j = 1, col
      status = RM_GetSelectedOutputHeading(id, j-1, heading)    
      write(*,'(10x,i2,A2,A10,A2,f10.4)') j, " ", trim(heading),": ", selected_out(i,j)
    enddo
  enddo
  deallocate(selected_out)
enddo
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int        RM_GetSelectedOutputRowCount(int id);
/**
Transfer solution volumes from the module workers to the array given in the argument list (vol). 
@param id                   The instance id returned from @ref RM_Create.
@param density              Array to receive the solution volumes. Dimension of the array is (nxyz), 
where nxyz is the number of user grid cells. Values for inactive cells are set to 1e30. Solution volumes are those calculated by the reaction module. 
Only the following databases distributed with PhreeqcRM have molar volume information needed to calculate solution volume: 
phreeqc.dat, Amm.dat, and pitzer.dat.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetSolutionVolume(int id, double *vol);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
volume = (double *) malloc((size_t) (nxyz * sizeof(double)));
status = RM_RunCells(id); 
status = RM_GetSolutionVolume(id, volume);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetSolutionVolume(id, vol)   
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  DOUBLE PRECISION, INTENT(out) :: vol
END FUNCTION RM_GetSolutionVolume  
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
allocate(volume(nxyz))
status = RM_RunCells(id)  
status = RM_GetSolutionVolume(id, volume(1))
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int        RM_GetSolutionVolume(int id, double *vol);
/**
Returns the number of threads, which is equal to the number of workers used to run in parallel with OPENMPI. 
For the threaded version, the number of threads is set implicitly or explicitly with @ref RM_Create. For the
MPI version, the number of threads is always one for each process.
@param id               The instance id returned from @ref RM_Create.  
@retval                 The number of threads used for OPENMPI parallel processing, negative is failure (See @ref RM_DecodeError).
@see                    @ref RM_GetMpiTasks.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_GetThreadCount(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>		
sprintf(str1, "Number of threads: %d\n", RM_GetThreadCount(id));
status = RM_OutputMessage(id, str1);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_GetThreadCount(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetThreadCount
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
write(string1, "(A,I)") "Number of threads: ", RM_GetThreadCount(id)
status = RM_OutputMessage(id, string1)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers; result is always 1.
 */
int        RM_GetThreadCount(int id);
/**
Returns the current simulation time in seconds. The reaction module does not change the time value, so the 
returned value is equal to the default (0.0) or the last time set by @ref RM_SetTime.
@param id               The instance id returned from @ref RM_Create.  
@retval                 The current simulation time in seconds.
@see                    @ref RM_GetTimeConversion, @ref RM_GetTimeStep, @ref RM_SetTime, 
@ref RM_SetTimeConversion, @ref RM_SetTimeStep.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
double RM_GetTime(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>		
sprintf(str, "%s%10.1f%s", "Beginning reaction calculation ", 
        RM_GetTime(id) * RM_GetTimeConversion(id), " days\n");
status = RM_LogMessage(id, str);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
DOUBLE PRECISION FUNCTION RM_GetTime(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetTime
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
write(string, "(A32,F15.1,A)") "Beginning transport calculation ", &
      RM_GetTime(id) * RM_GetTimeConversion(id), " days"
status = RM_LogMessage(id, string);
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
double     RM_GetTime(int id);
/**
Returns a multiplier to convert time from seconds to another unit, as specified by the user. 
The reaction module uses seconds as the time unit. The user can set a conversion
factor (@ref RM_SetTimeConversion) and retrieve it with RM_GetTimeConversion. The 
reaction module only uses the conversion factor when printing the long version
of cell chemistry (@ref RM_SetPrintChemistryOn), which is rare. Default conversion factor is 1.0.
@param id               The instance id returned from @ref RM_Create.  
@retval                 Multiplier to convert seconds to another time unit. 
@see                    @ref RM_GetTime, @ref RM_GetTimeStep, @ref RM_SetTime, @ref RM_SetTimeConversion, @ref RM_SetTimeStep.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
double RM_GetTimeConversion(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>		
sprintf(str, "%s%10.1f%s", "Beginning reaction calculation ", 
        RM_GetTime(id) * RM_GetTimeConversion(id), " days\n");
status = RM_LogMessage(id, str);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
DOUBLE PRECISION FUNCTION RM_GetTimeConversion(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetTimeConversion
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
write(string, "(A32,F15.1,A)") "Beginning transport calculation ", &
      RM_GetTime(id) * RM_GetTimeConversion(id), " days"
status = RM_LogMessage(id, string);
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
double     RM_GetTimeConversion(int id);
/**
Returns the current simulation time step in seconds. 
This is the time over which kinetic reactions are integrated in a call to @ref RM_RunCells. 
The reaction module does not change the time step value, so the 
returned value is equal to the default (0.0) or the last time step set by @ref RM_SetTimeStep.
@param id               The instance id returned from @ref RM_Create.  
@retval                 The current simulation time step in seconds.
@see                    @ref RM_GetTime, @ref RM_GetTimeConversion, @ref RM_SetTime, 
@ref RM_SetTimeConversion, @ref RM_SetTimeStep.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
double RM_GetTimeStep(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>		
sprintf(str, "%s%10.1f%s", "          Time step                  ", 
        RM_GetTimeStep(id) * RM_GetTimeConversion(id), " days\n");
status = RM_LogMessage(id, str);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE> 
DOUBLE PRECISION FUNCTION RM_GetTimeStep(id)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_GetTimeStep 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
write(string, "(A32,F15.1,A)") "          Time step             ", &
      RM_GetTimeStep(id) * RM_GetTimeConversion(id), " days"
status = RM_LogMessage(id, string);
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
double     RM_GetTimeStep(int id);
/**
Fills an array (c) with concentrations from solutions in the InitialPhreeqc instance.
Used to obtain concentrations for boundary conditions. Concentrations may be a mixture of two
solutions, boundary_solution1 and boundary_solution2, with a mixing fraction for boundary_solution1 1 of
fraction1 and mixing fraction for boundary_solution2 of (1 - fraction1). 
A negative value for boundary_solution2 implies no mixing, and the associated value for fraction1 is ignored.
If boundary_solution2 and fraction1 are omitted (Fortran) or NULL (C), 
no mixing is used; concentrations are derived from boundary_solution1 only.
@param id                  The instance id returned from @ref RM_Create.
@param c                   Array of concentrations extracted from the InitialPhreeqc instance. 
The dimension of c is equivalent to Fortran allocation (n_boundary, ncomp), 
where ncomp is the number of components returned from @ref RM_FindComponents or @ref RM_GetComponentCount.
@param n_boundary          The number of boundary condition solutions that need to be filled.
@param boundary_solution1  Array of solution index numbers that refer to solutions in the InitialPhreeqc instance. 
Size is (n_boundary).
@param boundary_solution2  Array of solution index numbers that that refer to solutions in the InitialPhreeqc instance 
and are defined to mix with boundary_solution1. 
Size is (n_boundary). Optional in Fortran, may be NULL in C.
@param fraction1           Fraction of boundary_solution1 that mixes with (1-fraction1) of boundary_solution2.
Size is (n_boundary). Optional in Fortran, may be NULL in C.
@retval IRM_RESULT         0 is success, negative is failure (See @ref RM_DecodeError).
@see                  @ref RM_FindComponents, @ref RM_GetComponentCount. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_InitialPhreeqc2Concentrations(
  int id,
  double *c,
  int n_boundary,
  int *boundary_solution1,  
  int *boundary_solution2, 
  double *fraction1);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  		
nbound = 1;
bc1 = (int *) malloc((size_t) (nbound * sizeof(int)));
bc2 = (int *) malloc((size_t) (nbound * sizeof(int)));
bc_f1 = (double *) malloc((size_t) (nbound * sizeof(double)));
bc_conc = (double *) malloc((size_t) (ncomps * nbound * sizeof(double)));
for (i = 0; i < nbound; i++) 
{
  bc1[i]          = 0;       // Solution 0 from InitialPhreeqc instance
  bc2[i]          = -1;      // no bc2 solution for mixing
  bc_f1[i]        = 1.0;     // mixing fraction for bc1
} 
status = RM_InitialPhreeqc2Concentrations(id, bc_conc, nbound, bc1, bc2, bc_f1);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE> 
INTEGER FUNCTION RM_InitialPhreeqc2Concentrations(id, c, n_boundary, bc_sol1, bc_sol2, f1)   
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  DOUBLE PRECISION, INTENT(OUT) :: c
  INTEGER, INTENT(IN) :: n_boundary, bc_sol1
  INTEGER, INTENT(IN), OPTIONAL :: bc_sol2
  DOUBLE PRECISION, INTENT(IN), OPTIONAL :: f1
END FUNCTION RM_InitialPhreeqc2Concentrations    
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>      
nbound = 1
allocate(bc1(nbound), bc2(nbound), bc_f1(nbound))
allocate(bc_conc(nbound, ncomps))  
bc1 = 0           ! solution 0 from InitialPhreeqc instance
bc2 = -1          ! no bc2 solution for mixing
bc_f1 = 1.0       ! mixing fraction for bc1 
status = RM_InitialPhreeqc2Concentrations(id, bc_conc(1,1), nbound, bc1(1), bc2(1), bc_f1(1))
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_InitialPhreeqc2Concentrations(
                int id,
                double *c,
                int n_boundary,
                int *boundary_solution1,  
                int *boundary_solution2, 
                double *fraction1);
/**
Transfer solutions and reactants from the InitialPhreeqc instance to the reaction-module workers, possibly with mixing.
In its simplest form, initial_conditions1 is used to select initial conditions, including solutions and reactants, 
for each cell of the model, without mixing. 
Initial_conditions1 is dimensioned (nxyz, 7), where nxyz is the number of grid cells in the user's model 
(@ref RM_GetGridCellCount). The dimension of 7 refers to solutions and reactants in the following order:
(1) SOLUTIONS, (2) EQUILIBRIUM_PHASES, (3) EXCHANGE, (4) SURFACE, (5) GAS_PHASE,
(6) SOLID_SOLUTIONS, and (7) KINETICS. In Fortran, initial_conditions1(100, 4) = 2, indicates that
cell 99 (0 based) contains the SURFACE definition with user number 2 that has been defined in the 
InitialPhreeqc instance (either by @ref RM_RunFile or @ref RM_RunString). 
The same definition in C would be initial_solution1[3*nxyz + 99] = 2.
@n@n
It is also possible to mix solutions and reactants to obtain the initial conditions for cells. For mixing,
initials_conditions2 contains numbers for a second entity that mixes with the entity defined in initial_conditions1.
Fraction1 contains the mixing fraction for initial_conditions1, whereas (1 - fraction1) is the mixing fraction for 
initial_conditions2.
In Fortran, initial_conditions1(100, 4) = 2, initial_conditions2(100, 4) = 3, fraction1(100, 4) = 0.25 indicates that
cell 99 (0 based) contains a mixtrue of 0.25 SURFACE 2 and 0.75 SURFACE 3, where the surface compositions have been defined in the
InitialPhreeqc instance. The same definition in C would be initial_solution1[3*nxyz + 99] = 2, initial_solution2[3*nxyz + 99] = 3,
fraction1[3*nxyz + 99] = 0.25.
If the user number in initial_conditions2 is negative, no mixing occurs. 
If initials_conditions2 and fraction1 are omitted (Fortran) or NULL (C), 
no mixing is used, and initial conditions are derived solely from initials_conditions1.

@param id                  The instance id returned from @ref RM_Create.
@param initial_conditions1 Array of solution and reactant index numbers that refer to definitions in the InitialPhreeqc instance. 
Size is (nxyz x 7). The order of definitions is given above.
Negative values are ignored, resulting in no definition of that entity for that cell.
@param initial_conditions2  Array of solution and reactant index numbers that refer to definitions in the InitialPhreeqc instance. 
Nonnegative values of initial_conditions2 result in mixing with the entities defined in initial_conditions1.
Negative values result in no mixing.
Size is (nxyz x 7). The order of definitions is given above.
Optional in Fortran, may be NULL in C; omitting or setting to NULL results in no mixing.
@param fraction1           Fraction of initial_conditions1 that mixes with (1-fraction1) of initial_conditions2. 
Size is (nxyz x 7). The order of definitions is given above.
Optional in Fortran, may be NULL in C; omitting or setting to NULL results in no mixing.
@retval IRM_RESULT          0 is success, negative is failure (See @ref RM_DecodeError).
@see                        @ref RM_InitialPhreeqcCell2Module.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_InitialPhreeqc2Module(int id,
                int *initial_conditions1,		// 7 x nxyz end-member 1
                int *initial_conditions2,		// 7 x nxyz end-member 2
                double *fraction1);			    // 7 x nxyz fraction of end-member 1
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  		
ic1 = (int *) malloc((size_t) (7 * nxyz * sizeof(int)));
ic2 = (int *) malloc((size_t) (7 * nxyz * sizeof(int)));
f1 = (double *) malloc((size_t) (7 * nxyz * sizeof(double)));
for (i = 0; i < nxyz; i++) 
{
  ic1[i]          = 1;       // Solution 1
  ic1[nxyz + i]   = -1;      // Equilibrium phases none
  ic1[2*nxyz + i] = 1;       // Exchange 1
  ic1[3*nxyz + i] = -1;      // Surface none
  ic1[4*nxyz + i] = -1;      // Gas phase none
  ic1[5*nxyz + i] = -1;      // Solid solutions none
  ic1[6*nxyz + i] = -1;      // Kinetics none

  ic2[i]          = -1;      // Solution none
  ic2[nxyz + i]   = -1;      // Equilibrium phases none
  ic2[2*nxyz + i] = -1;      // Exchange none
  ic2[3*nxyz + i] = -1;      // Surface none
  ic2[4*nxyz + i] = -1;      // Gas phase none
  ic2[5*nxyz + i] = -1;      // Solid solutions none
  ic2[6*nxyz + i] = -1;      // Kinetics none

  f1[i]          = 1.0;      // Mixing fraction ic1 Solution
  f1[nxyz + i]   = 1.0;      // Mixing fraction ic1 Equilibrium phases 
  f1[2*nxyz + i] = 1.0;      // Mixing fraction ic1 Exchange 1
  f1[3*nxyz + i] = 1.0;      // Mixing fraction ic1 Surface 
  f1[4*nxyz + i] = 1.0;      // Mixing fraction ic1 Gas phase 
  f1[5*nxyz + i] = 1.0;      // Mixing fraction ic1 Solid solutions 
  f1[6*nxyz + i] = 1.0;      // Mixing fraction ic1 Kinetics 
}
status = RM_InitialPhreeqc2Module(id, ic1, ic2, f1); 
// No mixing is defined, so the following is equivalent
status = RM_InitialPhreeqc2Module(id, ic1, NULL, NULL);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE> 
INTEGER FUNCTION RM_InitialPhreeqc2Module(id, ic1, ic2, f1)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: ic1
  INTEGER, INTENT(in), OPTIONAL :: ic2
  DOUBLE PRECISION, INTENT(in), OPTIONAL :: f1
END FUNCTION RM_InitialPhreeqc2Module  
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>      
allocate(ic1(nxyz,7), ic2(nxyz,7), f1(nxyz,7))
ic1 = -1
ic2 = -1
f1 = 1.0
do i = 1, nxyz
  ic1(i,1) = 1       ! Solution 1
  ic1(i,2) = -1      ! Equilibrium phases none
  ic1(i,3) = 1       ! Exchange 1
  ic1(i,4) = -1      ! Surface none
  ic1(i,5) = -1      ! Gas phase none
  ic1(i,6) = -1      ! Solid solutions none
  ic1(i,7) = -1      ! Kinetics none
enddo   
status = RM_InitialPhreeqc2Module(id, ic1(1,1), ic2(1,1), f1(1,1))1))
! No mixing is defined, so the following is equivalent
status = RM_InitialPhreeqc2Module(id, ic1(1,1))
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_InitialPhreeqc2Module(int id,
                int *initial_conditions1,		// 7 x nxyz end-member 1
                int *initial_conditions2,		// 7 x nxyz end-member 2
                double *fraction1);			    // 7 x nxyz fraction of end-member 1
/**
A cell numbered n in the InitialPhreeqc instance is selected to populate a series of cells in the reaction module workers.
All reactants with the number n are transferred along with the solution. 
If MIX n exists, it is used for the definition of the solution. 
The list of cell numbers for the workers is module_numbers, with dimension dim_module_numbers. 
If n is negative, n is redefined to be the largest solution or MIX number in the InitialPhreeqc instance. 
All reactants for each cell in the list module_numbers are removed before the cell 
definition is copied from the InitialPhreeqc instance to the workers.
@param id                 The instance id returned from @ref RM_Create.
@param n                  Cell number refers to a solution or MIX and associated reactants in the InitialPhreeqc instance.
A negative number indicates the largest solution or MIX number in the InitialPhreeqc instance will be used.
@param module_numbers     A list of cell numbers in the user's grid-cell numbering system that will be populated with
cell n from the InitialPhreeqc instance.
@param dim_module_numbers The number of cell numbers in the module_numbers list.
@retval IRM_RESULT        0 is success, negative is failure (See @ref RM_DecodeError).
@see                      @ref RM_InitialPhreeqc2Module.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_InitialPhreeqcCell2Module(int id,
                int n,		                            // InitialPhreeqc cell number
                int *module_numbers,		            // Module cell numbers
                int dim_module_numbers);			    // Number of module cell numbers
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  		
module_cells = (int *) malloc((size_t) (2 * sizeof(int)));
module_cells[0] = 18;
module_cells[0] = 19;
// n will be the largest SOLUTION number in InitialPhreeqc instance
// copies solution and reactants to cells 18 and 19
status = RM_InitialPhreeqcCell2Module(id, -1, module_cells, 2);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE> 
INTEGER FUNCTION RM_InitialPhreeqcCell2Module(id, n_user, module_cell, dim_module_cell)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: n_user
  INTEGER, INTENT(in) :: module_cell
  INTEGER, INTENT(in) :: dim_module_cell
END FUNCTION RM_InitialPhreeqcCell2Module         
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>      
allocate (module_cells(2))
module_cells(1) = 18
module_cells(2) = 19
! n will be the largest SOLUTION number in InitialPhreeqc instance
! copies solution and reactants to cells 18 and 19
status = RM_InitialPhreeqcCell2Module(id, -1, module_cells(1), 2)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_InitialPhreeqcCell2Module(int id,
                int n,		                            // InitialPhreeqc cell number
                int *module_numbers,		            // Module cell numbers
                int dim_module_numbers);			    // Number of module cell numbers
/**
Load a database for all IPhreeqc instances--workers, InitialPhreeqc, and Utility. All definitions
of the reaction module are cleared (SOLUTION_SPECIES, PHASES, SOLUTIONs, etc.), and the database is read.
@param id               The instance id returned from @ref RM_Create.
@param db_name          String containing the database name.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError).
@see                    @ref RM_Create.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_LoadDatabase(int id, const char *db_name);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  	
status = RM_LoadDatabase(id, "phreeqc.dat"); 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE> 
INTEGER FUNCTION RM_LoadDatabase(id, db) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  CHARACTER, INTENT(in) :: db
END FUNCTION RM_LoadDatabase         
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>      
status = RM_LoadDatabase(id, "phreeqc.dat")
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_LoadDatabase(int id, const char *db_name);
/**
Print a message to the log file. 
@param id               The instance id returned from @ref RM_Create.
@param str              String to be printed.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_OpenFiles, @ref RM_ErrorMessage, @ref RM_OutputMessage, @ref RM_ScreenMessage, @ref RM_WarningMessage. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_LogMessage(int id, const char *str);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  			
sprintf(str, "%s%10.1f%s", "Beginning transport calculation      ", 
        RM_GetTime(id) * RM_GetTimeConversion(id), " days\n");
status = RM_LogMessage(id, str);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_LogMessage(id, str) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  CHARACTER, INTENT(in) :: str
END FUNCTION RM_LogMessage
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
write(string, "(A32,F15.1,A)") "Beginning transport calculation ", &
      RM_GetTime(id) * RM_GetTimeConversion(id), " days"
status = RM_LogMessage(id, string);
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int RM_LogMessage(int id, const char *str);
/**
For MPI, workers (processes with @ref RM_GetMpiMyself > 0) must call RM_MpiWorker to be able to
respond to messages from the root to accept data, perform calculations,
or return data. RM_MpiWorker contains a loop that reads a message from root, performs a 
task, and waits for another message from root. @ref RM_SetConcentrations, @ref RM_RunCells, and @ref RM_GetConcentrations
are examples of methods that send a message from root to get the workers to perform a task. The workers will
respond to all methods that are designated "workers must be in the loop of MpiWorker" in the
MPI section of the method documentation.
The workers will continue to respond to messages from root until root calls
@ref RM_MpiWorkerBreak.
@n@n
(Advanced) The list of tasks that the workers perform can be extended by using @ref RM_SetMpiWorkerCallback.
It is then possible to use the MPI processes to perform other developer-defined tasks, such as transport calculations, without
exiting from the RM_MpiWorker loop. Alternatively, root calls @ref RM_MpiWorkerBreak to allow the workers to continue
past a call to RM_MpiWorker. The workers perform developer-defined calculations, and then RM_MpiWorker is called again to respond to 
requests from root to perform reaction-module tasks.
@param id               The instance id returned from @ref RM_Create.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). RM_MpiWorker returns a value only when
@ref RM_MpiWorkerBreak is called by root.
@see                    @ref RM_MpiWorkerBreak, @ref RM_SetMpiWorkerCallback, @ref RM_SetMpiWorkerCallbackCookie (C only).
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_MpiWorker(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  			
status = RM_MpiWorker(id);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_MpiWorker(id) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_MpiWorker
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
status = RM_MpiWorker(id)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by all workers.
 */
int RM_MpiWorker(int id);
/**
For MPI, called by root to force workers (processes with @ref RM_GetMpiMyself > 0) to return from a call to @ref RM_MpiWorker. 
RM_MpiWorker contains a loop that reads a message from root, performs a 
task, and waits for another message from root. The workers respond to all methods that are designated "workers must be in the loop of MpiWorker" in the
MPI section of the method documentation.
The workers will continue to respond to messages from root until root calls RM_MpiWorkerBreak.
@param id               The instance id returned from @ref RM_Create.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_MpiWorker, @ref RM_SetMpiWorkerCallback, @ref RM_SetMpiWorkerCallbackCookie (C only).
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_MpiWorkerBreak(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  			
status = RM_MpiWorkerBreak(id);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_MpiWorkerBreak(id) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_MpiWorkerBreak
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
status = RM_MpiWorkerBreak(id)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int RM_MpiWorkerBreak(int id);
/**
Opens the output and log files. Files are named based on the prefix defined by
@ref RM_SetFilePrefix: prefix.chem.txt and prefix.log.txt.
@param id               The instance id returned from @ref RM_Create.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_SetFilePrefix, @ref RM_GetFilePrefix, @ref RM_CloseFiles..
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_OpenFiles(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  			
status = RM_SetFilePrefix(id, "Advect_c");
status = RM_OpenFiles(id);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_OpenFiles(id) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_OpenFiles
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
status = RM_SetFilePrefix(id, "Advect_f90")
status = RM_OpenFiles(id)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int RM_OpenFiles(int id);
/**
Print a message to the output file. 
@param id               The instance id returned from @ref RM_Create.
@param str              String to be printed.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_ErrorMessage, @ref RM_LogMessage, @ref RM_ScreenMessage, @ref RM_WarningMessage. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_OutputMessage(int id, const char *str);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  					
sprintf(str1, "Number of threads:                                %d\n", RM_GetThreadCount(id));
status = RM_OutputMessage(id, str1);
sprintf(str1, "Number of MPI processes:                          %d\n", RM_GetMpiTasks(id));
status = RM_OutputMessage(id, str1);
sprintf(str1, "MPI task number:                                  %d\n", RM_GetMpiMyself(id));
status = RM_OutputMessage(id, str1);
status = RM_GetFilePrefix(id, str, 100);
sprintf(str1, "File prefix:                                      %s\n", str);
status = RM_OutputMessage(id, str1);
sprintf(str1, "Number of grid cells in the user's model:         %d\n", RM_GetGridCellCount(id));
status = RM_OutputMessage(id, str1);
sprintf(str1, "Number of chemistry cells in the reaction module: %d\n", RM_GetChemistryCellCount(id));
status = RM_OutputMessage(id, str1);
sprintf(str1, "Number of components for transport:               %d\n", RM_GetComponentCount(id));
status = RM_OutputMessage(id, str1);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_OutputMessage(id, str)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  CHARACTER, INTENT(in) :: str
END FUNCTION RM_OutputMessage
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
write(string1, "(A,I)") "Number of threads:                                ", RM_GetThreadCount(id)
status = RM_OutputMessage(id, string1)
write(string1, "(A,I)") "Number of MPI processes:                          ", RM_GetMpiTasks(id)
status = RM_OutputMessage(id, string1)
write(string1, "(A,I)") "MPI task number:                                  ", RM_GetMpiMyself(id)
status = RM_OutputMessage(id, string1)
status = RM_GetFilePrefix(id, string)
write(string1, "(A,A)") "File prefix:                                      ", string
status = RM_OutputMessage(id, trim(string1))
write(string1, "(A,I)") "Number of grid cells in the user's model:         ", RM_GetGridCellCount(id)
status = RM_OutputMessage(id, trim(string1))
write(string1, "(A,I)") "Number of chemistry cells in the reaction module: ", RM_GetChemistryCellCount(id)
status = RM_OutputMessage(id, trim(string1))
write(string1, "(A,I)") "Number of components for transport:               ", RM_GetComponentCount(id)
status = RM_OutputMessage(id, trim(string1))
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int RM_OutputMessage(int id, const char *str);
/**
Runs a reaction step for all of the cells in the reaction module. 
The current set of concentrations of the components (@ref RM_SetConcentrations) is used
in the calculations. The length of time over which kinetic reactions are integrated is set
by @ref RM_SetTimeStep. Other properties that may need to be updated as a result of the transport 
calculations include pore volume, saturation, temperature, and pressure. 
@param id               The instance id returned from @ref RM_Create.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_SetConcentrations,  @ref RM_SetPoreVolume, 
@ref RM_SetTemperature, @ref RM_SetPressure, @ref RM_SetSaturation, @ref RM_SetTimeStep. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_RunCells(int id);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:			
@htmlonly
<CODE>
<PRE>  	
status = RM_SetPoreVolume(id, pv);             // If pore volume changes 
status = RM_SetSaturation(id, sat);            // If saturation changes
status = RM_SetTemperature(id, temperature);   // If temperature changes
status = RM_SetPressure(id, pressure);         // If pressure changes
status = RM_SetConcentrations(id, c);          // Transported concentrations
status = RM_SetTimeStep(id, time_step);        // Time step for kinetic reactions
status = RM_RunCells(id);
status = RM_GetConcentrations(id, c);          // Concentrations after reaction 
status = RM_GetDensity(id, density);           // Density after reaction
status = RM_GetSolutionVolume(id, volume);     // Solution volume after reaction
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>
INTEGER FUNCTION RM_RunCells(id)   
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
END FUNCTION RM_RunCells 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  	
status = RM_SetPoreVolume(id, pv(1))               ! If pore volume changes
status = RM_SetSaturation(id, sat(1))              ! If saturation changes
status = RM_SetTemperature(id, temperature(1))     ! If temperature changes
status = RM_SetPressure(id, pressure(1))           ! If pressure changes
status = RM_SetConcentrations(id, c(1,1))          ! Transported concentrations
status = RM_SetTimeStep(id, time_step)             ! Time step for kinetic reactions
status = RM_RunCells(id)  
status = RM_GetConcentrations(id, c(1,1))          ! Concentrations after reaction
status = RM_GetDensity(id, density(1))             ! Density after reaction
status = RM_GetSolutionVolume(id, volume(1))       ! Solution volume after reaction
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_RunCells(int id);
/**
Run a PHREEQC input file. The first three arguments determine which IPhreeqc instances will run
the file--the workers, the InitialPhreeqc instance, and (or) the Utility instance. Input
files that modify the thermodynamic database should be run by all three sets of instances.
Files with SELECTED_OUTPUT definitions that will be used during the time-stepping loop need to
be run by the workers. Files that contain initial conditions or boundary conditions should
be run by the InitialPhreeqc instance. 
@param id               The instance id returned from @ref RM_Create.
@param workers          Nonzero value, the workers will run the file; zero, the workers will not run the file.
@param initial_phreeqc  Nonzero value, the InitialPhreeqc instance will run the file; zero, the InitialPhreeqc will not run the file.
@param utility          Nonzero value, the Utility instance will run the file; zero, the Utility instance will not run the file.
@param chem_name        Name of the file to run.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_RunString. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_RunFile(int id, int workers, int initial_phreeqc, int utility, const char *chem_name);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:			
@htmlonly
<CODE>
<PRE>  
status = RM_RunFile(id, 1, 1, 1, "advect.pqi");
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>
INTEGER FUNCTION RM_RunFile(id, workers, initial_phreeqc, utility, chem_name)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: workers, initial_phreeqc, utility
  CHARACTER, INTENT(in) :: chem_name
END FUNCTION RM_RunFile 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  	
status = RM_RunFile(id, 1, 1, 1, "advect.pqi")
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int        RM_RunFile(int id, int workers, int initial_phreeqc, int utility, const char *chem_name);
/**
Run a PHREEQC input string. The first three arguments determine which 
IPhreeqc instances will run
the string--the workers, the InitialPhreeqc instance, and (or) the Utility instance. Input
strings that modify the thermodynamic database should be run by all three sets of instances.
Strings with SELECTED_OUTPUT definitions that will be used during the time-stepping loop need to
be run by the workers. Strings that contain initial conditions or boundary conditions should
be run by the InitialPhreeqc instance. 
@param id               The instance id returned from @ref RM_Create.
@param workers          Nonzero value, the workers will run the string; zero, the workers will not run the string.
@param initial_phreeqc  Nonzero value, the InitialPhreeqc instance will run the string; zero, the InitialPhreeqc will not run the string.
@param utility          Nonzero value, the Utility instance will run the string; zero, the Utility instance will not run the string.
@param input_string     String containing PHREEQC input.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_RunFile. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_RunString(int id, int workers, int initial_phreeqc, int utility, const char * input_string);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:			
@htmlonly
<CODE>
<PRE>  
strcpy(str, "DELETE; -all");
status = RM_RunString(id, 1, 0, 1, str);	// workers, initial_phreeqc, utility 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>
INTEGER FUNCTION RM_RunString(id, initial_phreeqc, workers, utility, input_string)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: initial_phreeqc, workers, utility
  CHARACTER, INTENT(in) :: input_string
END FUNCTION RM_RunString  
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  	
string = "DELETE; -all"
status = RM_RunString(id, 1, 0, 1, string)  ! workers, initial_phreeqc, utility
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_RunString(int id, int workers, int initial_phreeqc, int utility, const char * input_string);
/**
Print message to the screen. 
@param id               The instance id returned from @ref RM_Create.
@param str              String to be printed.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_ErrorMessage, @ref RM_OutputMessage, @ref RM_ScreenMessage, @ref RM_WarningMessage. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_ScreenMessage(int id, const char *str);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  			
sprintf(str, "%s%10.1f%s", "Beginning transport calculation      ", 
        time * RM_GetTimeConversion(id), " days\n");
status = RM_ScreenMessage(id, str);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_ScreenMessage(id, str) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  CHARACTER, INTENT(in) :: str
END FUNCTION RM_ScreenMessage
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
write(string, "(A32,F15.1,A)") "Beginning reaction calculation  ", &
      time * RM_GetTimeConversion(id), " days"
status = RM_ScreenMessage(id, string);
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers.
 */
int RM_ScreenMessage(int id, const char *str);
/**
Set the volume of each cell. Porosity is determined by the ratio of the pore volume (@ref RM_SetPoreVolume)
to the volume. The volume of water in a cell is the porosity times the saturation (@ref RM_SetSaturation).
@param id               The instance id returned from @ref RM_Create.
@param vol              Array of volumes, user units. Size of array is (nxyz), where nxyz is the number
of grid cells in the user's model (@ref RM_GetGridCellCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_SetPoreVolume, @ref RM_SetSaturation.. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_SetCellVolume(int id, double *vol);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  			
cell_vol = (double *) malloc((size_t) (nxyz * sizeof(double)));
for (i = 0; i < nxyz; i++) cell_vol[i] = 1.0;
status = RM_SetCellVolume(id, cell_vol);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_SetCellVolume(id, t)   
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  DOUBLE PRECISION, INTENT(in) :: t
END FUNCTION RM_SetCellVolume
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
allocate(cell_vol(nxyz))
cell_vol = 1.0
status = RM_SetCellVolume(id, cell_vol(1))
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_SetCellVolume(int id, double *vol);
/**
Set the concentrations by which the moles of components of each cell are determined. 
Porosity is determined by the ratio of the pore volume (@ref RM_SetPoreVolume)
to the volume (@ref RM_SetCellVolume). 
The volume of water in a cell is the porosity times the saturation (@ref RM_SetSaturation).
The moles of each component are determined by the volume of water and per liter concentrations. 
If concentration units (@ref RM_SetUnitsSolution) are mass fraction, the
density (as determined by @ref RM_SetDensity) is used to convert from mass fraction to per liter.
@param id               The instance id returned from @ref RM_Create.
@param vol              Array of component concentrations. Size of array is (nxyz, ncomps), where nxyz is the number
of grid cells in the user's model (@ref RM_GetGridCellCount), and ncomps is the number of components as determined
by @ref RM_FindComponents or @ref RM_GetComponentCount.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                     @ref RM_SetCellVolume, @ref RM_SetPoreVolume, @ref RM_SetSaturation, @ref RM_SetUnitsSolution. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_SetConcentrations(int id, double *c);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  			
c = (double *) malloc((size_t) (ncomps * nxyz * sizeof(double)));
...
advect_c(c, bc_conc, ncomps, nxyz, nbound);
status = RM_SetPoreVolume(id, pv);             // If pore volume changes 
status = RM_SetSaturation(id, sat);            // If saturation changes
status = RM_SetTemperature(id, temperature);   // If temperature changes
status = RM_SetPressure(id, pressure);         // If pressure changes
status = RM_SetConcentrations(id, c);          // Transported concentrations
status = RM_SetTimeStep(id, time_step);        // Time step for kinetic reactions
status = RM_SetTime(id, time);                 // Current time
status = RM_RunCells(id);  
status = RM_GetConcentrations(id, c);          // Concentrations after reaction 
status = RM_GetDensity(id, density);           // Density after reaction
status = RM_GetSolutionVolume(id, volume);     // Solution volume after reaction
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_SetConcentrations(id, c)   
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  DOUBLE PRECISION, INTENT(in) :: t
END FUNCTION RM_SetConcentrations
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
allocate(c(nxyz, ncomps))
...
call advect_f90(c, bc_conc, ncomps, nxyz)
status = RM_SetPoreVolume(id, pv(1))               ! If pore volume changes 
status = RM_SetSaturation(id, sat(1))              ! If saturation changes
status = RM_SetTemperature(id, temperature(1))     ! If temperature changes
status = RM_SetPressure(id, pressure(1))           ! If pressure changes
status = RM_SetConcentrations(id, c(1,1))          ! Transported concentrations
status = RM_SetTimeStep(id, time_step)             ! Time step for kinetic reactions
status = RM_SetTime(id, time)                      ! Current time
status = RM_RunCells(id)  
status = RM_GetConcentrations(id, c(1,1))          ! Concentrations after reaction
status = RM_GetDensity(id, density(1))             ! Density after reaction
status = RM_GetSolutionVolume(id, volume(1))       ! Solution volume after reaction
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_SetConcentrations(int id, double *c);
/**
Set the current selected output user number. The user may define multiple SELECTED_OUTPUT
data blocks for the workers. A user number is specified for each data block. The value of
the argument n_user selects which of the SELECTED_OUTPUT definitions will be used 
for selected-output operations.
@param id               The instance id returned from @ref RM_Create.
@param n_user           User number of the SELECTED_OUTPUT data block that is to be used. 
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_GetNthSelectedOutputUserNumber, @ref RM_GetSelectedOutput, @ref RM_GetSelectedOutputColumnCount,
@ref RM_GetSelectedOutputCount, @ref RM_GetSelectedOutputRowCount, @ref RM_GetSelectedOutputHeading,
@ref RM_SetSelectedOutputOn.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_SetCurrentSelectedOutputUserNumber(int id, int n_user);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  			
for (isel = 0; isel < RM_GetSelectedOutputCount(id); isel++)
{
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel);
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user);
  col = RM_GetSelectedOutputColumnCount(id);
  selected_out = (double *) malloc((size_t) (col * nxyz * sizeof(double)));
  status = RM_GetSelectedOutput(id, selected_out);
  // Process results here
  free(selected_out);
}
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_SetCurrentSelectedOutputUserNumber(id, n_user)   
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: n_user
END FUNCTION RM_SetCurrentSelectedOutputUserNumber
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
do isel = 1, RM_GetSelectedOutputCount(id)
  n_user = RM_GetNthSelectedOutputUserNumber(id, isel - 1)
  status = RM_SetCurrentSelectedOutputUserNumber(id, n_user)
  col = RM_GetSelectedOutputColumnCount(id)
  allocate(selected_out(nxyz,col))
  status = RM_GetSelectedOutput(id, selected_out(1,1))
  ! Process results here
  deallocate(selected_out)
enddo
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int RM_SetCurrentSelectedOutputUserNumber(int id, int n_user);
/**
Set the density for each cell. These density values are used only 
when converting from transported mass fraction concentrations (@ref RM_SetUnitsSolution) to
produce per liter concentrations during a call to @ref RM_SetConcentrations.
@param id               The instance id returned from @ref RM_Create.
@param density          Array of densities. Size of array is (nxyz), where nxyz is the number
of grid cells in the user's model (@ref RM_GetGridCellCount).
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_SetConcentrations. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_SetDensity(int id, double *density);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  			
density = (double *) malloc((size_t) (nxyz * sizeof(double)));
for (i = 0; i < nxyz; i++) 
{
	density[i] = 1.0;
}
status = RM_SetDensity(id, density);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE> 
INTEGER FUNCTION RM_SetDensity(id, density)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  DOUBLE PRECISION, INTENT(in) :: density
END FUNCTION RM_SetDensity 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  		
allocate(density(nxyz))
density = 1.0
status = RM_SetDensity(id, density(1))
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_SetDensity(int id, double *density);
/**
Set the name of the dump file. It is the name used by @ref RM_DumpModule.
@param id               The instance id returned from @ref RM_Create.
@param dump_name        Name of dump file.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_DumpModule.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_SetDumpFileName(int id, const char *dump_name);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE> 
status = RM_SetDumpFileName(id, "advection_c.dmp.gz"); 
dump_on = 1;
append = 0;
status = RM_DumpModule(id, dump_on, append);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_SetDumpFileName(id, name) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  CHARACTER, INTENT(in) :: name
END FUNCTION RM_SetDumpFileName
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  	
status = RM_SetDumpFileName(id, "advection_f90.dmp.gz")  
dump_on = 1
append = 0  
status = RM_DumpModule(id, dump_on, append)  
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int RM_SetDumpFileName(int id, const char *dump_name);
/**
Set the action to be taken when the reaction module encounters and error.
Options are 0, return to calling program with an error return code; 
1, throw an exception, in C++, the exception can be caught, for C and Fortran, the program will exit; 
2, attempt to exit gracefully. Default is 0.
@param id               The instance id returned from @ref RM_Create.
@param mode             Error handling mode: 0, 1, or 2.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_Destroy.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_SetErrorHandlerMode(int id, int mode);;
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE> 
id = RM_Create(nxyz, nthreads);
status = RM_SetErrorHandlerMode(id, 2);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_SetErrorHandlerMode(id, i)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  INTEGER, INTENT(in) :: i
END FUNCTION RM_SetErrorHandlerMode 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  	
id = RM_create(nxyz, nthreads)
status = RM_SetErrorHandlerMode(id, 2)  
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root, workers must be in the loop of @ref RM_MpiWorker.
 */
int RM_SetErrorHandlerMode(int id, int mode);

/**
Set the prefix for the output (prefix.chem.txt) and log (prefix.log.txt) files. 
These files are opened by @ref RM_OpenFiles.
@param id               The instance id returned from @ref RM_Create.
@param prefix           Prefix used when opening the output and log files.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_OpenFiles, @ref RM_CloseFiles.
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_SetFilePrefix(int id, const char *prefix);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE> 
status = RM_SetFilePrefix(id, "Advect_c");
status = RM_OpenFiles(id);
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_SetFilePrefix(id, prefix) 
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  CHARACTER, INTENT(in) :: prefix
END FUNCTION RM_SetFilePrefix 
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  	
status = RM_SetFilePrefix(id, "Advect_f90")
status = RM_OpenFiles(id)  
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root.
 */
int RM_SetFilePrefix(int id, const char *prefix);
int RM_SetMpiWorkerCallback(int id, int (*fcn)(int *x1));
int RM_SetMpiWorkerCallbackCookie(int id, void *cookie);
int RM_SetPartitionUZSolids(int id, int t);
int RM_SetPoreVolume(int id, double *t);
int RM_SetPrintChemistryOn(int id, int worker, int ip, int utility);
int RM_SetPrintChemistryMask(int id, int *t);
int RM_SetPressure(int id, double *t);
int RM_SetRebalanceFraction(int id, double *f);
int RM_SetRebalanceByCell(int id, int method);
int RM_SetSaturation(int id, double *t);
int RM_SetSelectedOutputOn(int id, int selected_output);
int RM_SetTemperature(int id, double *t);
int RM_SetTime(int id, double t);
int RM_SetTimeConversion(int id, double t);
int RM_SetTimeStep(int id, double t);
int RM_SetUnitsExchange(int id, int i);
int RM_SetUnitsGasPhase(int id, int i);
int RM_SetUnitsKinetics(int id, int i);
int RM_SetUnitsPPassemblage(int id, int i);
int RM_SetUnitsSolution(int id, int i);
int RM_SetUnitsSSassemblage(int id, int i);
int RM_SetUnitsSurface(int id, int i);
/**
Print warning message to the screen and the log file. 
@param id               The instance id returned from @ref RM_Create.
@param warnstr          String to be printed.
@retval IRM_RESULT      0 is success, negative is failure (See @ref RM_DecodeError). 
@see                    @ref RM_OpenFiles, @ref RM_LogMessage, @ref RM_OutputMessage, @ref RM_ScreenMessage, @ref RM_ErrorMessage. 
@par C Prototype:
@htmlonly
<CODE>
<PRE>  
int RM_WarningMessage(int id, const char *warnstr);
</PRE>
</CODE> 
@endhtmlonly
@par C Example:
@htmlonly
<CODE>
<PRE>  
status = RM_WarningMessage(id, "Parameter is out of range, using default");
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Interface:
@htmlonly
<CODE>
<PRE>   
INTEGER FUNCTION RM_WarningMessage(id, warnstr)
  IMPLICIT NONE
  INTEGER, INTENT(in) :: id
  CHARACTER, INTENT(in) :: warnstr
END FUNCTION RM_WarningMessage
</PRE>
</CODE> 
@endhtmlonly
@par Fortran90 Example:
@htmlonly
<CODE>
<PRE>  
status = RM_WarningMessage(id, "Parameter is out of range, using default")
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
Called by root and (or) workers; only root writes to the log file.
 */
int RM_WarningMessage(int id, const char *warn_str);
void RM_write_bc_raw(int id, 
                int *solution_list, 
                int bc_solution_count, 
                int solution_number, 
                const char *prefix);

#if defined(__cplusplus)
}
#endif

#endif // RM_INTERFACE_C_H
