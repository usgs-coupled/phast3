/*! @file RM_interface_C.h
	@brief C/Fortran Documentation
*/#ifndef RM_INTERFACE_C_H
#define RM_INTERFACE_C_H

#if defined(__cplusplus)
extern "C" {
#endif
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
Called by root, workers must be in the loop of @ref MpiWorker.
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
Called by root; workers must be in the loop of @ref MpiWorker.
 */
int RM_DumpModule(int id, int dump_on, int append);
//int RM_ErrorHandler(int id, int result, const char * err_str);
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
Transfer solution concentrations from the module workers to the concentration array given in the argument list (c). 
@param id               The instance id returned from @ref RM_Create.
@param c                Array to receive the concentrations. Dimension of the array is equivalent to Fortran (nxyz, ncomps), 
where nxyz is the number of user grid cells and ncomps is the result of @ref RM_FindComponents or @ref RM_GetComponentCount. 
Units of concentration for c are defined by RM_SetUnitsSolution.
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
Called by root, workers must be in the loop of @ref MpiWorker.
 */
int RM_GetConcentrations(int id, double *c);
/**
Transfer solution densities from the module workers to the density array given in the argument list (density). 
@param id                   The instance id returned from @ref RM_Create.
@param density              Array to receive the densities. Dimension of the array is (nxyz), 
where nxyz is the number of user grid cells. Densities are those calculated by the reaction module. 
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
Called by root, workers must be in the loop of @ref MpiWorker.
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
strcpy(str1, "File prefix is ");
strncat(str1, str, 200);
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
string1 = "File prefix is "//string;
status = RM_OutputMessage(id, string1)
</PRE>
</CODE> 
@endhtmlonly
@par MPI:
   Called by root and workers.
 */
int RM_GetFilePrefix(int id, char *prefix, int l);
int RM_GetGfw(int id, double * gfw);
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
int        RM_GetGridCellCount(int id);
int        RM_GetIPhreeqcId(int id, int i);
int        RM_GetMpiMyself(int id);
int        RM_GetMpiTasks(int id);
int        RM_GetNThreads(int id);
int        RM_GetNthSelectedOutputUserNumber(int id, int i);
int        RM_GetSelectedOutput(int id, double *so);
int        RM_GetSelectedOutputColumnCount(int id);
int        RM_GetSelectedOutputCount(int id);
int        RM_GetSelectedOutputHeading(int id, int icol, char * heading, int length);
int        RM_GetSelectedOutputRowCount(int id);
int        RM_GetSolutionVolume(int id, double *v);
double     RM_GetTime(int id);
double     RM_GetTimeConversion(int id);
double     RM_GetTimeStep(int id);
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
int RM_InitialPhreeqc2Concentrations(
                int id,
                double *c,
                int n_boundary,
                //int dim, 
                int *boundary_solution1,  
                int *boundary_solution2, 
                double *fraction1);
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
int RM_InitialPhreeqc2Module(int id,
                int *initial_conditions1,		// 7 x nxyz end-member 1
                int *initial_conditions2,		// 7 x nxyz end-member 2
                double *fraction1);			    // 7 x nxyz fraction of end-member 1
int RM_InitialPhreeqcCell2Module(int id,
                int n,		                            // InitialPhreeqc cell number
                int *module_numbers,		            // Module cell numbers
                int dim_module_numbers);			    // Number of module cell numbers
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
int RM_LoadDatabase(int id, const char *db_name);
int RM_LogMessage(int id, const char *str);
int RM_MpiWorker(int id);
int RM_MpiWorkerBreak(int id);
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
int RM_OpenFiles(int id);
int RM_OutputMessage(int id, const char *str);
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
int RM_RunCells(int id);
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
 *      INTEGER FUNCTION RM_RunFile(id, workers, initial_phreeqc, utility, chem_name)
 *          IMPLICIT NONE
 *          INTEGER, INTENT(in) :: id
 *          INTEGER, OPTIONAL, INTENT(in) :: initial_phreeqc, workers, utility
 *          CHARACTER, OPTIONAL, INTENT(in) :: chem_name
 *      END FUNCTION RM_RunFile 
 *  </PRE>
 *  </CODE>
 *  @endhtmlonly
 */
int        RM_RunFile(int id, int workers, int initial_phreeqc, int utility, const char *chem_name);
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
int RM_RunString(int id, int workers, int initial_phreeqc, int utility, const char * input_string);
int RM_ScreenMessage(int id, const char *str);
int RM_SetCellVolume(int id, double *t);
int RM_SetConcentrations(int id, double *t);
int RM_SetCurrentSelectedOutputUserNumber(int id, int i);
int RM_SetDensity(int id, double *t);
int RM_SetDumpFileName(int id, const char *dump_name);
int RM_SetErrorHandlerMode(int id, int mode);
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
 *  Send an warning message to the screen and log file. 
 *  @param str           String to be sent.
 *  @param l             Length of the string buffer (automatic in Fortran, optional in C).
 *  @see                 RM_ErrorMessage, RM_LogMessage, RM_LogScreenMessage, RM_ScreenMessage. 
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
