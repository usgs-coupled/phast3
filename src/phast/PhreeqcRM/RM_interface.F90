MODULE PhreeqcRM
    USE ISO_C_BINDING
    IMPLICIT NONE
    SAVE
#if defined(NDEBUG)
    LOGICAL :: rmf_debug=.false.
#else
    LOGICAL :: rmf_debug=.true.
#endif     
    INTEGER :: rmf_nxyz=-1
    INTEGER :: rmf_ncomps=-1
INCLUDE 'RM_interface_F.f90.inc'
    CONTAINS

INTEGER FUNCTION RM_Abort(id, rslt, str)
    IMPLICIT NONE
    INTEGER RMF_Abort
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: rslt
    CHARACTER(len=*), INTENT(in) :: str
    RM_Abort = RMF_Abort(id, rslt, trim(str)//C_NULL_CHAR)
    RETURN    
END FUNCTION RM_Abort

INTEGER FUNCTION RM_CloseFiles(id)
    IMPLICIT NONE
    INTEGER RMF_CloseFiles
    INTEGER, INTENT(in) :: id
    RM_CloseFiles = RMF_CloseFiles(id)
    RETURN    
END FUNCTION RM_CloseFiles

INTEGER FUNCTION RM_Concentrations2Utility(id, c, n, tc, p_atm)
    IMPLICIT NONE
    INTEGER RMF_Concentrations2Utility
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:,:) :: c
    INTEGER, INTENT(in) :: n
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: tc, p_atm
    if (rmf_debug) CALL ChK_Concentrations2Utility(id, c, n, tc, p_atm)
    RM_Concentrations2Utility = RMF_Concentrations2Utility(id, c, n, tc, p_atm)
    return
END FUNCTION RM_Concentrations2Utility  

SUBROUTINE ChK_Concentrations2Utility(id, c, n, tc, p_atm)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:,:) :: c
    INTEGER, INTENT(in) :: n
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: tc, p_atm
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double2D(id, c, n, rmf_ncomps, "Concentration", "RM_Concentrations2Utility")
    errors = errors + Chk_Double1D(id, tc, n, "Temperature", "RM_Concentrations2Utility")
    errors = errors + Chk_Double1D(id, p_atm, n, "Pressure", "RM_Concentrations2Utility")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument(s) in RM_Concentrations2Utility")
    endif
END SUBROUTINE Chk_Concentrations2Utility  

INTEGER FUNCTION RM_Create(nxyz, nthreads) 
    IMPLICIT NONE
    INTEGER RMF_Create
    INTEGER, INTENT(in) :: nxyz
	INTEGER, INTENT(in) :: nthreads
    RM_Create = RMF_Create(nxyz, nthreads) 
    rmf_nxyz = nxyz
  
    return
END FUNCTION RM_Create

INTEGER FUNCTION RM_CreateMapping(id, grid2chem)
    IMPLICIT NONE
    INTEGER RMF_CreateMapping
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in), DIMENSION(:) :: grid2chem
    if (rmf_debug) call Chk_CreateMapping(id, grid2chem)
    RM_CreateMapping = RMF_CreateMapping(id, grid2chem)
    return
END FUNCTION RM_CreateMapping

SUBROUTINE Chk_CreateMapping(id, grid2chem)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in), DIMENSION(:) :: grid2chem
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Integer1D(id, grid2chem, rmf_nxyz, "Grid2chem mapping", "RM_CreateMapping")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument(s) in RM_CreateMapping")
    endif
END SUBROUTINE Chk_CreateMapping

INTEGER FUNCTION RM_DecodeError(id, e)
    IMPLICIT NONE
    INTEGER RMF_DecodeError
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: e
    RM_DecodeError = RMF_DecodeError(id, e)
    return
END FUNCTION RM_DecodeError

INTEGER FUNCTION RM_Destroy(id)
    IMPLICIT NONE
    INTEGER RMF_Destroy
    INTEGER, INTENT(in) :: id
    RM_Destroy = RMF_Destroy(id)
    return
END FUNCTION RM_Destroy
  
INTEGER FUNCTION RM_DumpModule(id, dump_on, append) 
    IMPLICIT NONE
    INTEGER RMF_DumpModule
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: dump_on
    INTEGER, INTENT(in) :: append
    RM_DumpModule = RMF_DumpModule(id, dump_on, append)
    return
END FUNCTION RM_DumpModule

INTEGER FUNCTION RM_ErrorMessage(id, errstr)
    IMPLICIT NONE
    INTEGER RMF_ErrorMessage
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: errstr
    RM_ErrorMessage = RMF_ErrorMessage(id, trim(errstr)//C_NULL_CHAR)
    return
END FUNCTION RM_ErrorMessage
        
INTEGER FUNCTION RM_FindComponents(id) 
    IMPLICIT NONE
    INTEGER RMF_FindComponents
    INTEGER, INTENT(in) :: id
    RM_FindComponents = RMF_FindComponents(id)
    rmf_ncomps = RM_FindComponents
    return
END FUNCTION RM_FindComponents  

INTEGER FUNCTION RM_GetChemistryCellCount(id)
    IMPLICIT NONE
    INTEGER RMF_GetChemistryCellCount
    INTEGER, INTENT(in) :: id
    RM_GetChemistryCellCount = RMF_GetChemistryCellCount(id)
    return
END FUNCTION RM_GetChemistryCellCount 
        
INTEGER FUNCTION RM_GetComponent(id, num, comp_name)
    IMPLICIT NONE
    INTEGER RMF_GetComponent
    INTEGER, INTENT(in) :: id, num
    CHARACTER(len=*), INTENT(inout) :: comp_name
    RM_GetComponent = RMF_GetComponent(id, num, comp_name, len(comp_name))
    return
END FUNCTION RM_GetComponent 
        
INTEGER FUNCTION RM_GetComponentCount(id)
    IMPLICIT NONE
    INTEGER RMF_GetComponentCount
    INTEGER, INTENT(in) :: id
    RM_GetComponentCount = RMF_GetComponentCount(id)
END FUNCTION RM_GetComponentCount 

INTEGER FUNCTION RM_GetConcentrations(id, c)   
    IMPLICIT NONE
    INTEGER RMF_GetConcentrations
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(out), DIMENSION(:,:) :: c
    if (rmf_debug) call Chk_GetConcentrations(id, c)  
    RM_GetConcentrations = RMF_GetConcentrations(id, c)   
    return
END FUNCTION RM_GetConcentrations         

SUBROUTINE Chk_GetConcentrations(id, c)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:,:) :: c
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double2D(id, c, rmf_nxyz, rmf_ncomps, "concentration", "RM_GetConcentrations")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument(s) in RM_GetConcentrations")
    endif
END SUBROUTINE Chk_GetConcentrations

INTEGER FUNCTION RM_GetDensity(id, density)   
    IMPLICIT NONE
    INTEGER RMF_GetDensity
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(out), dimension(:) :: density
    if (rmf_debug) call Chk_GetDensity(id, density)
    RM_GetDensity = RMF_GetDensity(id, density) 
    return
END FUNCTION RM_GetDensity 

SUBROUTINE Chk_GetDensity(id, density)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: density
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double1D(id, density, rmf_nxyz, "density", "RM_GetDensity")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_GetDensity")
    endif
END SUBROUTINE Chk_GetDensity

INTEGER FUNCTION RM_GetErrorString(id, errstr)   
    IMPLICIT NONE
    INTEGER RMF_GetErrorString
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(out) :: errstr
    RM_GetErrorString = RMF_GetErrorString(id, errstr, len(errstr))   
END FUNCTION RM_GetErrorString 

INTEGER FUNCTION RM_GetErrorStringLength(id)   
    IMPLICIT NONE
    INTEGER RMF_GetErrorStringLength
    INTEGER, INTENT(in) :: id
    RM_GetErrorStringLength = RMF_GetErrorStringLength(id) 
END FUNCTION RM_GetErrorStringLength 
        
INTEGER FUNCTION RM_GetFilePrefix(id, prefix)
    IMPLICIT NONE
    INTEGER RMF_GetFilePrefix
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(inout) :: prefix
    integer l
    l = len(prefix)
    RM_GetFilePrefix = RMF_GetFilePrefix(id, prefix, l)
END FUNCTION RM_GetFilePrefix

INTEGER FUNCTION RM_GetGfw(id, gfw)   
    IMPLICIT NONE
    INTEGER RMF_GetGfw
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(out) :: gfw
    if (rmf_debug) call Chk_GetGfw(id, gfw) 
    RM_GetGfw = RMF_GetGfw(id, gfw)   
END FUNCTION RM_GetGfw 

SUBROUTINE Chk_GetGfw(id, gfw) 
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: gfw
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double1D(id, gfw, rmf_ncomps, "gfw", "RM_GetGfw")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_GetGfw")
    endif
END SUBROUTINE Chk_GetGfw

INTEGER FUNCTION RM_GetGridCellCount(id)
    IMPLICIT NONE
    INTEGER RMF_GetGridCellCount
    INTEGER, INTENT(in) :: id
    RM_GetGridCellCount = RMF_GetGridCellCount(id)
END FUNCTION RM_GetGridCellCount

INTEGER FUNCTION RM_GetIPhreeqcId(id, i)
    IMPLICIT NONE
    INTEGER RMF_GetIPhreeqcId
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: i
    RM_GetIPhreeqcId = RMF_GetIPhreeqcId(id, i)
END FUNCTION RM_GetIPhreeqcId
        
INTEGER FUNCTION RM_GetMpiMyself(id)
    IMPLICIT NONE
    INTEGER RMF_GetMpiMyself
    INTEGER, INTENT(in) :: id
    RM_GetMpiMyself = RMF_GetMpiMyself(id)
END FUNCTION RM_GetMpiMyself
        
INTEGER FUNCTION RM_GetMpiTasks(id)
    IMPLICIT NONE
    INTEGER RMF_GetMpiTasks
    INTEGER, INTENT(in) :: id
    RM_GetMpiTasks = RMF_GetMpiTasks(id)
END FUNCTION RM_GetMpiTasks
        
INTEGER FUNCTION RM_GetNthSelectedOutputUserNumber(id, n)
    IMPLICIT NONE
    INTEGER RMF_GetNthSelectedOutputUserNumber
    INTEGER, INTENT(in) :: id, n
    RM_GetNthSelectedOutputUserNumber = RMF_GetNthSelectedOutputUserNumber(id, n)
END FUNCTION RM_GetNthSelectedOutputUserNumber 
        
INTEGER FUNCTION RM_GetSaturation(id, sat)
    IMPLICIT NONE
    INTEGER RMF_GetSaturation
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(out), DIMENSION(:) :: sat
    if (rmf_debug) call Chk_GetSaturation(id, sat)
    RM_GetSaturation = RMF_GetSaturation(id, sat)
END FUNCTION RM_GetSaturation
   
SUBROUTINE Chk_GetSaturation(id, sat)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: sat
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double1D(id, sat, rmf_nxyz, "saturation", "RM_GetSaturation")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_GetSaturation")
    endif
END SUBROUTINE Chk_GetSaturation

INTEGER FUNCTION RM_GetSelectedOutput(id, so)
    IMPLICIT NONE
    INTEGER RMF_GetSelectedOutput
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:,:), INTENT(out) :: so
    if (rmf_debug) call Chk_GetSelectedOutput(id, so)
    RM_GetSelectedOutput = RMF_GetSelectedOutput(id, so)
END FUNCTION RM_GetSelectedOutput
 
SUBROUTINE Chk_GetSelectedOutput(id, so)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:,:) :: so
    INTEGER :: errors, ncol
    ncol = RM_GetSelectedOutputColumnCount(id)
    errors = 0
    errors = errors + Chk_Double2D(id, so, rmf_nxyz, ncol, "selected output", "RM_GetSelectedOutput")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_GetSelectedOutput")
    endif
END SUBROUTINE Chk_GetSelectedOutput

INTEGER FUNCTION RM_GetSelectedOutputColumnCount(id)
    IMPLICIT NONE
    INTEGER RMF_GetSelectedOutputColumnCount
    INTEGER, INTENT(in) :: id
    RM_GetSelectedOutputColumnCount = RMF_GetSelectedOutputColumnCount(id)
END FUNCTION RM_GetSelectedOutputColumnCount
        
INTEGER FUNCTION RM_GetSelectedOutputCount(id)
    IMPLICIT NONE
    INTEGER RMF_GetSelectedOutputCount
    INTEGER, INTENT(in) :: id
    RM_GetSelectedOutputCount = RMF_GetSelectedOutputCount(id)
END FUNCTION RM_GetSelectedOutputCount
        
INTEGER FUNCTION RM_GetSelectedOutputHeading(id, icol, heading)
    IMPLICIT NONE
    INTEGER RMF_GetSelectedOutputHeading
    INTEGER, INTENT(in) :: id, icol
    CHARACTER(len=*), INTENT(out) :: heading
    RM_GetSelectedOutputHeading = RMF_GetSelectedOutputHeading(id, icol, heading, len(heading))
END FUNCTION RM_GetSelectedOutputHeading
        
INTEGER FUNCTION RM_GetSelectedOutputRowCount(id)
    IMPLICIT NONE
    INTEGER RMF_GetSelectedOutputRowCount
    INTEGER, INTENT(in) :: id
    RM_GetSelectedOutputRowCount = RMF_GetSelectedOutputRowCount(id)
END FUNCTION RM_GetSelectedOutputRowCount

INTEGER FUNCTION RM_GetSolutionVolume(id, vol)   
    IMPLICIT NONE
    INTEGER RMF_GetSolutionVolume
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(out), DIMENSION(:) :: vol
    if (rmf_debug) call Chk_GetDensity(id, vol)
    RM_GetSolutionVolume = RMF_GetSolutionVolume(id, vol)   
END FUNCTION RM_GetSolutionVolume 

SUBROUTINE Chk_GetSolutionVolume(id, vol)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: vol
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double1D(id, vol, rmf_nxyz, "vol", "RM_GetSolutionVolume")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_GetSolutionVolume")
    endif
END SUBROUTINE Chk_GetSolutionVolume

INTEGER FUNCTION RM_GetSpeciesConcentrations(id, species_conc)   
    IMPLICIT NONE
    INTEGER RMF_GetSpeciesConcentrations
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(out), DIMENSION(:,:) :: species_conc
	if (rmf_debug) call Chk_GetSpeciesConcentrations(id, species_conc)
    RM_GetSpeciesConcentrations = RMF_GetSpeciesConcentrations(id, species_conc)
END FUNCTION RM_GetSpeciesConcentrations 

SUBROUTINE Chk_GetSpeciesConcentrations(id, species_conc)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:,:) :: species_conc
    INTEGER :: errors, nspecies
    nspecies = RM_GetSpeciesCount(id)
    errors = 0
    errors = errors + Chk_Double2D(id, species_conc, rmf_nxyz, nspecies, "species concentration", "RM_GetSpeciesConcentrations")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_GetSpeciesConcentrations")
    endif
END SUBROUTINE Chk_GetSpeciesConcentrations

INTEGER FUNCTION RM_GetSpeciesCount(id)
    IMPLICIT NONE
    INTEGER RMF_GetSpeciesCount
    INTEGER, INTENT(in) :: id
    RM_GetSpeciesCount = RMF_GetSpeciesCount(id)
END FUNCTION RM_GetSpeciesCount

INTEGER FUNCTION RM_GetSpeciesD25(id, diffc)   
    IMPLICIT NONE
    INTEGER RMF_GetSpeciesD25
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(out), DIMENSION(:) :: diffc
	if (rmf_debug) call Chk_GetSpeciesD25(id, diffc)
    RM_GetSpeciesD25 = RMF_GetSpeciesD25(id, diffc)
END FUNCTION RM_GetSpeciesD25 

SUBROUTINE Chk_GetSpeciesD25(id, diffc)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: diffc
    INTEGER :: errors, nspecies
    nspecies = RM_GetSpeciesCount(id)
    errors = 0
    errors = errors + Chk_Double1D(id, diffc, nspecies, "diffusion coefficient", "RM_GetSpeciesD25")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_GetSpeciesD25")
    endif
END SUBROUTINE Chk_GetSpeciesD25

INTEGER FUNCTION RM_GetSpeciesName(id, i, name)
    IMPLICIT NONE
    INTEGER RMF_GetSpeciesName
    INTEGER, INTENT(in) :: id, i
    CHARACTER(len=*), INTENT(out) :: name
    RM_GetSpeciesName = RMF_GetSpeciesName(id, i, name, len(name))
END FUNCTION RM_GetSpeciesName

INTEGER FUNCTION RM_GetSpeciesSaveOn(id)
    IMPLICIT NONE
    INTEGER RMF_GetSpeciesSaveOn
    INTEGER, INTENT(in) :: id
    RM_GetSpeciesSaveOn = RMF_GetSpeciesSaveOn(id)
END FUNCTION RM_GetSpeciesSaveOn

INTEGER FUNCTION RM_GetSpeciesZ(id, z)   
    IMPLICIT NONE
    INTEGER RMF_GetSpeciesZ
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(out), DIMENSION(:) :: z
	if (rmf_debug) call Chk_GetSpeciesZ(id, z) 
    RM_GetSpeciesZ = RMF_GetSpeciesZ(id, z)
END FUNCTION RM_GetSpeciesZ 
    
SUBROUTINE Chk_GetSpeciesZ(id, z) 
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: z
    INTEGER :: errors, nspecies
    nspecies = RM_GetSpeciesCount(id)
    errors = 0
    errors = errors + Chk_Double1D(id, z, nspecies, "species charge", "RM_GetSpeciesZ")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_GetSpeciesZ")
    endif
END SUBROUTINE Chk_GetSpeciesZ

INTEGER FUNCTION RM_GetThreadCount(id)
    IMPLICIT NONE
    INTEGER RMF_GetThreadCount
    INTEGER, INTENT(in) :: id
    RM_GetThreadCount = RMF_GetThreadCount(id)
END FUNCTION RM_GetThreadCount
        
DOUBLE PRECISION FUNCTION RM_GetTime(id)
    IMPLICIT NONE
    DOUBLE PRECISION RMF_GetTime
    INTEGER, INTENT(in) :: id
    RM_GetTime = RMF_GetTime(id)
END FUNCTION RM_GetTime
        
DOUBLE PRECISION FUNCTION RM_GetTimeConversion(id)
    IMPLICIT NONE
    DOUBLE PRECISION RMF_GetTimeConversion
    INTEGER, INTENT(in) :: id
    RM_GetTimeConversion = RMF_GetTimeConversion(id)
END FUNCTION RM_GetTimeConversion
        
DOUBLE PRECISION FUNCTION RM_GetTimeStep(id)
    IMPLICIT NONE
    DOUBLE PRECISION RMF_GetTimeStep
    INTEGER, INTENT(in) :: id
    RM_GetTimeStep = RMF_GetTimeStep(id)
END FUNCTION RM_GetTimeStep 

INTEGER FUNCTION RM_InitialPhreeqc2Concentrations(id, c, n_boundary, bc_sol1, bc_sol2, f1)   
    IMPLICIT NONE
    INTEGER RMF_InitialPhreeqc2Concentrations
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(OUT), DIMENSION(:,:) :: c
    INTEGER, INTENT(IN) :: n_boundary 
    INTEGER, INTENT(IN), DIMENSION(:) :: bc_sol1
    INTEGER, INTENT(IN), DIMENSION(:) , OPTIONAL :: bc_sol2
    DOUBLE PRECISION, INTENT(IN), DIMENSION(:) , OPTIONAL :: f1
	if (rmf_debug) call Chk_InitialPhreeqc2Concentrations(id, c, n_boundary, bc_sol1, bc_sol2, f1) 
    RM_InitialPhreeqc2Concentrations = RMF_InitialPhreeqc2Concentrations(id, c, n_boundary, bc_sol1, bc_sol2, f1)
END FUNCTION RM_InitialPhreeqc2Concentrations    

SUBROUTINE Chk_InitialPhreeqc2Concentrations(id, c, n_boundary, bc_sol1, bc_sol2, f1) 
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(IN), DIMENSION(:,:) :: c
    INTEGER, INTENT(IN) :: n_boundary 
    INTEGER, INTENT(IN), DIMENSION(:) :: bc_sol1
    INTEGER, INTENT(IN), DIMENSION(:) , OPTIONAL :: bc_sol2
    DOUBLE PRECISION, INTENT(IN), DIMENSION(:) , OPTIONAL :: f1
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double2D(id, c, n_boundary, rmf_ncomps, "concentration", "RM_InitialPhreeqc2Concentrations")
    errors = errors + Chk_Integer1D(id, bc_sol1, n_boundary, "bc_sol1", "RM_InitialPhreeqc2Concentrations")
    if (present(bc_sol2)) then
        errors = errors + Chk_Integer1D(id, bc_sol2, n_boundary, "bc_sol2", "RM_InitialPhreeqc2Concentrations")
    endif
    if (present(f1)) then
        errors = errors + Chk_Double1D(id, f1, n_boundary, "f1", "RM_InitialPhreeqc2Concentrations")
    endif
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_InitialPhreeqc2Concentrations")
    endif
END SUBROUTINE Chk_InitialPhreeqc2Concentrations

INTEGER FUNCTION RM_InitialPhreeqc2Module(id, ic1, ic2, f1)
    IMPLICIT NONE
    INTEGER RMF_InitialPhreeqc2Module
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in), DIMENSION(:,:) :: ic1
    INTEGER, INTENT(in), DIMENSION(:,:), OPTIONAL :: ic2
    DOUBLE PRECISION, INTENT(in), DIMENSION(:,:), OPTIONAL :: f1
	if (rmf_debug) call Chk_InitialPhreeqc2Module(id, ic1, ic2, f1)
    RM_InitialPhreeqc2Module = RMF_InitialPhreeqc2Module(id, ic1, ic2, f1)
END FUNCTION RM_InitialPhreeqc2Module    

SUBROUTINE Chk_InitialPhreeqc2Module(id, ic1, ic2, f1) 
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(IN), DIMENSION(:,:) :: ic1
    INTEGER, INTENT(IN), DIMENSION(:,:) , OPTIONAL :: ic2
    DOUBLE PRECISION, INTENT(IN), DIMENSION(:,:) , OPTIONAL :: f1
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Integer2D(id, ic1, rmf_nxyz, 7, "ic1", "RM_InitialPhreeqc2Module")
    if (present(ic2)) then
        errors = errors + Chk_Integer2D(id, ic2, rmf_nxyz, 7, "ic2", "RM_InitialPhreeqc2Module")
    endif
    if (present(f1)) then
        errors = errors + Chk_Double2D(id, f1, rmf_nxyz, 7, "f1", "RM_InitialPhreeqc2Module")
    endif
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_InitialPhreeqc2Module")
    endif
END SUBROUTINE Chk_InitialPhreeqc2Module

INTEGER FUNCTION RM_InitialPhreeqcCell2Module(id, n_user, module_cell, n_cell)
    IMPLICIT NONE
    INTEGER RMF_InitialPhreeqcCell2Module
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: n_user
    INTEGER, INTENT(in), DIMENSION(:) :: module_cell
    INTEGER, INTENT(in) :: n_cell
	if (rmf_debug) call Chk_InitialPhreeqcCell2Module(id, n_user, module_cell, n_cell)
    RM_InitialPhreeqcCell2Module = RMF_InitialPhreeqcCell2Module(id, n_user, module_cell, n_cell)
END FUNCTION RM_InitialPhreeqcCell2Module   

SUBROUTINE Chk_InitialPhreeqcCell2Module(id, n_user, module_cell, n_cell)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id, n_user, n_cell
    INTEGER, INTENT(in), DIMENSION(:) :: module_cell
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Integer1D(id, module_cell, n_cell, "module cells", "RM_InitialPhreeqcCell2Module")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_InitialPhreeqcCell2Module")
    endif
END SUBROUTINE Chk_InitialPhreeqcCell2Module

INTEGER FUNCTION RM_InitialPhreeqc2SpeciesConcentrations(id, species_c, n_boundary, bc_sol1, bc_sol2, f1)   
    IMPLICIT NONE
    INTEGER RMF_InitialPhreeqc2SpeciesConcentrations
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:,:), INTENT(OUT) :: species_c
    INTEGER, INTENT(IN) :: n_boundary
    INTEGER, INTENT(IN), DIMENSION(:) :: bc_sol1
    INTEGER, INTENT(IN), DIMENSION(:), OPTIONAL :: bc_sol2
    DOUBLE PRECISION, INTENT(IN), DIMENSION(:), OPTIONAL :: f1
    RM_InitialPhreeqc2SpeciesConcentrations = RMF_InitialPhreeqc2SpeciesConcentrations(id, species_c, n_boundary, bc_sol1, bc_sol2, f1)
END FUNCTION RM_InitialPhreeqc2SpeciesConcentrations          
        
INTEGER FUNCTION RM_LoadDatabase(id, db) 
    IMPLICIT NONE
    INTEGER RMF_LoadDatabase
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: db
    RM_LoadDatabase = RMF_LoadDatabase(id, trim(db)//C_NULL_CHAR)
END FUNCTION RM_LoadDatabase 
        
INTEGER FUNCTION RM_LogMessage(id, str) 
    IMPLICIT NONE
    INTEGER RMF_LogMessage
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: str
    RM_LogMessage = RMF_LogMessage(id, trim(str)//C_NULL_CHAR)
END FUNCTION RM_LogMessage

INTEGER FUNCTION RM_MpiWorker(id) 
    IMPLICIT NONE
    INTEGER RMF_MpiWorker
    INTEGER, INTENT(in) :: id
    RM_MpiWorker = RMF_MpiWorker(id)
END FUNCTION RM_MpiWorker

INTEGER FUNCTION RM_MpiWorkerBreak(id) 
    IMPLICIT NONE
    INTEGER RMF_MpiWorkerBreak
    INTEGER, INTENT(in) :: id
    RM_MpiWorkerBreak = RMF_MpiWorkerBreak(id)
END FUNCTION RM_MpiWorkerBreak
        
INTEGER FUNCTION RM_OpenFiles(id) 
    IMPLICIT NONE
    INTEGER RMF_OpenFiles
    INTEGER, INTENT(in) :: id
    RM_OpenFiles = RMF_OpenFiles(id)
END FUNCTION RM_OpenFiles
        
INTEGER FUNCTION RM_OutputMessage(id, str)
    IMPLICIT NONE
    INTEGER RMF_OutputMessage
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: str
    RM_OutputMessage = RMF_OutputMessage(id, trim(str)//C_NULL_CHAR)
END FUNCTION RM_OutputMessage
        
INTEGER FUNCTION RM_RunCells(id)   
    IMPLICIT NONE
    INTEGER RMF_RunCells
    INTEGER, INTENT(in) :: id
    RM_RunCells = RMF_RunCells(id)
END FUNCTION RM_RunCells  

INTEGER FUNCTION RM_RunFile(id, workers, initial_phreeqc, utility, chem_name)
    IMPLICIT NONE
    INTEGER RMF_RunFile
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: workers, initial_phreeqc, utility
    CHARACTER(len=*), INTENT(in) :: chem_name
    RM_RunFile = RMF_RunFile(id, workers, initial_phreeqc, utility, trim(chem_name)//C_NULL_CHAR)
END FUNCTION RM_RunFile   
        
INTEGER FUNCTION RM_RunString(id, initial_phreeqc, workers, utility, input_string)
    IMPLICIT NONE
    INTEGER RMF_RunString
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: initial_phreeqc, workers, utility
    CHARACTER(len=*), INTENT(in) :: input_string
    RM_RunString = RMF_RunString(id, initial_phreeqc, workers, utility, trim(input_string)//C_NULL_CHAR)
END FUNCTION RM_RunString   
        
INTEGER FUNCTION RM_ScreenMessage(id, str) 
    IMPLICIT NONE
    INTEGER RMF_ScreenMessage
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: str
    RM_ScreenMessage = RMF_ScreenMessage(id, trim(str)//C_NULL_CHAR) 
END FUNCTION RM_ScreenMessage   
 		     
INTEGER FUNCTION RM_SetComponentH2O(id, tf)   
    IMPLICIT NONE
    INTEGER RMF_SetComponentH2O
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: tf
    RM_SetComponentH2O = RMF_SetComponentH2O(id, tf)
END FUNCTION RM_SetComponentH2O
 		     
INTEGER FUNCTION RM_SetConcentrations(id, c)   
    IMPLICIT NONE
    INTEGER RMF_SetConcentrations
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:,:), INTENT(in) :: c
    RM_SetConcentrations = RMF_SetConcentrations(id, c)
END FUNCTION RM_SetConcentrations
 		     
INTEGER FUNCTION RM_SetCurrentSelectedOutputUserNumber(id, n_user)   
    IMPLICIT NONE
    INTEGER RMF_SetCurrentSelectedOutputUserNumber
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: n_user
    RM_SetCurrentSelectedOutputUserNumber = RMF_SetCurrentSelectedOutputUserNumber(id, n_user)
END FUNCTION RM_SetCurrentSelectedOutputUserNumber

INTEGER FUNCTION RM_SetDensity(id, density)
    IMPLICIT NONE
    INTEGER RMF_SetDensity
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: density
    RM_SetDensity = RMF_SetDensity(id, density)
END FUNCTION RM_SetDensity 
        
INTEGER FUNCTION RM_SetDumpFileName(id, name) 
    IMPLICIT NONE
    INTEGER RMF_SetDumpFileName
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: name
    RM_SetDumpFileName = RMF_SetDumpFileName(id, trim(name)//C_NULL_CHAR)
END FUNCTION RM_SetDumpFileName   

INTEGER FUNCTION RM_SetErrorHandlerMode(id, i)
    IMPLICIT NONE
    INTEGER RMF_SetErrorHandlerMode
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: i
    RM_SetErrorHandlerMode = RMF_SetErrorHandlerMode(id, i)
END FUNCTION RM_SetErrorHandlerMode        
		        
INTEGER FUNCTION RM_SetFilePrefix(id, prefix) 
    IMPLICIT NONE
    INTEGER RMF_SetFilePrefix
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: prefix
    RM_SetFilePrefix = RMF_SetFilePrefix(id, trim(prefix)//C_NULL_CHAR) 
END FUNCTION RM_SetFilePrefix  

INTEGER FUNCTION RM_SetMpiWorkerCallback(id, fcn)
    IMPLICIT NONE
    INTEGER RMF_SetMpiWorkerCallback
	INTEGER, INTENT(IN) :: id
	INTERFACE
		INTEGER FUNCTION fcn(method_number)
		INTEGER, INTENT(in) :: method_number
		END FUNCTION 
    END INTERFACE
    RM_SetMpiWorkerCallback = RMF_SetMpiWorkerCallback(id, fcn)
END FUNCTION RM_SetMpiWorkerCallback

INTEGER FUNCTION RM_SetPartitionUZSolids(id, tf)   
    IMPLICIT NONE
    INTEGER RMF_SetPartitionUZSolids
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in)  :: tf
    RM_SetPartitionUZSolids = RMF_SetPartitionUZSolids(id, tf)
END FUNCTION RM_SetPartitionUZSolids 

INTEGER FUNCTION RM_SetPorosity(id, por)   
    IMPLICIT NONE
    INTEGER RMF_SetPorosity
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: por
    RM_SetPorosity = RMF_SetPorosity(id, por)
END FUNCTION RM_SetPorosity 

INTEGER FUNCTION RM_SetPressure(id, p)   
    IMPLICIT NONE
    INTEGER RMF_SetPressure
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: p
    RM_SetPressure = RMF_SetPressure(id, p)
END FUNCTION RM_SetPressure        
        
INTEGER FUNCTION RM_SetPrintChemistryOn(id, worker, initial_phreeqc, utility)   
    IMPLICIT NONE
    INTEGER RMF_SetPrintChemistryOn
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: worker, initial_phreeqc, utility
    RM_SetPrintChemistryOn = RMF_SetPrintChemistryOn(id, worker, initial_phreeqc, utility)
END FUNCTION RM_SetPrintChemistryOn 

INTEGER FUNCTION RM_SetPrintChemistryMask(id, cell_mask)   
    IMPLICIT NONE
    INTEGER RMF_SetPrintChemistryMask
    INTEGER, INTENT(in) :: id
    INTEGER, DIMENSION(:), INTENT(in) :: cell_mask
    RM_SetPrintChemistryMask = RMF_SetPrintChemistryMask(id, cell_mask)
END FUNCTION RM_SetPrintChemistryMask 
        
INTEGER FUNCTION RM_SetRebalanceByCell(id, method)
    IMPLICIT NONE
    INTEGER RMF_SetRebalanceByCell
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in)  :: method
    RM_SetRebalanceByCell = RMF_SetRebalanceByCell(id, method)
END FUNCTION RM_SetRebalanceByCell
        
INTEGER FUNCTION RM_SetRebalanceFraction(id, f)
    IMPLICIT NONE
    INTEGER RMF_SetRebalanceFraction
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in)  :: f
    RM_SetRebalanceFraction = RMF_SetRebalanceFraction(id, f)
END FUNCTION RM_SetRebalanceFraction
		
INTEGER FUNCTION RM_SetRepresentativeVolume(id, rv)   
    IMPLICIT NONE
    INTEGER RMF_SetRepresentativeVolume
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: rv
    RM_SetRepresentativeVolume = RMF_SetRepresentativeVolume(id, rv)
END FUNCTION RM_SetRepresentativeVolume 

INTEGER FUNCTION RM_SetSaturation(id, sat)
    IMPLICIT NONE
    INTEGER RMF_SetSaturation
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: sat
    RM_SetSaturation = RMF_SetSaturation(id, sat)
END FUNCTION RM_SetSaturation 

INTEGER FUNCTION RM_SetSelectedOutputOn(id, tf)
    IMPLICIT NONE
    INTEGER RMF_SetSelectedOutputOn
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: tf
    RM_SetSelectedOutputOn = RMF_SetSelectedOutputOn(id, tf)
END FUNCTION RM_SetSelectedOutputOn   

INTEGER FUNCTION RM_SetSpeciesSaveOn(id, save_on)
    IMPLICIT NONE
    INTEGER RMF_SetSpeciesSaveOn
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: save_on
    RM_SetSpeciesSaveOn = RMF_SetSpeciesSaveOn(id, save_on)
END FUNCTION RM_SetSpeciesSaveOn

INTEGER FUNCTION RM_SetTemperature(id, t)
    IMPLICIT NONE
    INTEGER RMF_SetTemperature
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: t
    RM_SetTemperature = RMF_SetTemperature(id, t)
END FUNCTION RM_SetTemperature 
		     
INTEGER FUNCTION RM_SetTime(id, time)   
    IMPLICIT NONE
    INTEGER RMF_SetTime
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in) :: time
    RM_SetTime = RMF_SetTime(id, time)
END FUNCTION RM_SetTime 
		     
INTEGER FUNCTION RM_SetTimeConversion(id, conv_factor)   
    IMPLICIT NONE
    INTEGER RMF_SetTimeConversion
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in) :: conv_factor
    RM_SetTimeConversion = RMF_SetTimeConversion(id, conv_factor)
END FUNCTION RM_SetTimeConversion 
		     
INTEGER FUNCTION RM_SetTimeStep(id, time_step)   
    IMPLICIT NONE
    INTEGER RMF_SetTimeStep
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in) :: time_step
    RM_SetTimeStep = RMF_SetTimeStep(id, time_step)
END FUNCTION RM_SetTimeStep 

INTEGER FUNCTION RM_SetUnitsExchange(id, option)   
    IMPLICIT NONE
    INTEGER RMF_SetUnitsExchange
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsExchange = RMF_SetUnitsExchange(id, option)
END FUNCTION RM_SetUnitsExchange 

INTEGER FUNCTION RM_SetUnitsGasPhase(id, option)   
    IMPLICIT NONE
    INTEGER RMF_SetUnitsGasPhase
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsGasPhase = RMF_SetUnitsGasPhase(id, option)
END FUNCTION RM_SetUnitsGasPhase 

INTEGER FUNCTION RM_SetUnitsKinetics(id, option)   
    IMPLICIT NONE
    INTEGER RMF_SetUnitsKinetics
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsKinetics = RMF_SetUnitsKinetics(id, option)
END FUNCTION RM_SetUnitsKinetics 

INTEGER FUNCTION RM_SetUnitsPPassemblage(id, option)   
    IMPLICIT NONE
    INTEGER RMF_SetUnitsPPassemblage
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsPPassemblage = RMF_SetUnitsPPassemblage(id, option)
END FUNCTION RM_SetUnitsPPassemblage

INTEGER FUNCTION RM_SetUnitsSolution(id, option)   
    IMPLICIT NONE
    INTEGER RMF_SetUnitsSolution
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsSolution = RMF_SetUnitsSolution(id, option)
END FUNCTION RM_SetUnitsSolution  

INTEGER FUNCTION RM_SetUnitsSSassemblage(id, option)   
    IMPLICIT NONE
    INTEGER RMF_SetUnitsSSassemblage
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsSSassemblage = RMF_SetUnitsSSassemblage(id, option)
END FUNCTION RM_SetUnitsSSassemblage  

INTEGER FUNCTION RM_SetUnitsSurface(id, option)   
    IMPLICIT NONE
    INTEGER RMF_SetUnitsSurface
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsSurface = RMF_SetUnitsSurface(id, option)
END FUNCTION RM_SetUnitsSurface  

INTEGER FUNCTION RM_SpeciesConcentrations2Module(id, species_conc)
    IMPLICIT NONE
    INTEGER RMF_SpeciesConcentrations2Module
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:,:), INTENT(in) :: species_conc
    RM_SpeciesConcentrations2Module = RMF_SpeciesConcentrations2Module(id, species_conc)
END FUNCTION RM_SpeciesConcentrations2Module  

INTEGER FUNCTION RM_UseSolutionDensityVolume(id, tf)
    IMPLICIT NONE
    INTEGER RMF_UseSolutionDensityVolume
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: tf
    RM_UseSolutionDensityVolume = RMF_UseSolutionDensityVolume(id, tf)
END FUNCTION RM_UseSolutionDensityVolume 
        
INTEGER FUNCTION RM_WarningMessage(id, str) 
    IMPLICIT NONE
    INTEGER RMF_WarningMessage
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: str
    RM_WarningMessage = RMF_WarningMessage(id, trim(str)//C_NULL_CHAR)
END FUNCTION RM_WarningMessage

INTEGER FUNCTION Chk_Double1D(id, t, n1, var, func)
    IMPLICIT NONE
    INTEGER RMF_ErrorMessage
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: t
    INTEGER, INTENT(in) :: n1
    CHARACTER(len=*), INTENT(in) :: var, func
    CHARACTER(len=200) :: error_string
    INTEGER :: errors, status, t1
    t1 = size(t,1)
    errors = 0
    if (t1 .lt. n1)  then
        errors = errors + 1
        write(error_string, '(A,A,A,I8,A,A)') "Dimension of ", var, " is less than ", n1, " in ", func
        status = RMF_ErrorMessage(id, trim(error_string)) 
    endif    
    Chk_Double1D = errors
END FUNCTION Chk_Double1D

INTEGER FUNCTION Chk_Double2D(id, t, n1, n2, var, func)
    IMPLICIT NONE
    INTEGER RMF_ErrorMessage
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:,:) :: t
    INTEGER, INTENT(in) :: n1, n2
    CHARACTER(len=*), INTENT(in) :: var, func
    CHARACTER(len=200) :: error_string
    INTEGER :: errors, status, t1, t2
    t1 = size(t,1)
    t2 = size(t,2)
    errors = 0
    if (t2 .ne. n2) then
        errors = errors + 1
        write(error_string, '(A,A,A,I8,A,A)') "Second dimension of ", var, " is not equal to ", n2, " in ", func
        status = RMF_ErrorMessage(id, trim(error_string))  
    endif
    if (t1 .lt. n1)  then
        errors = errors + 1
        write(error_string, '(A,A,A,I8,A,A)') "First dimension of ", var, " is less than ", n1, " in ", func
        status = RMF_ErrorMessage(id, trim(error_string)) 
    endif    
    Chk_Double2D = errors
END FUNCTION Chk_Double2D

INTEGER FUNCTION Chk_Integer1D(id, t, n1, var, func)
    IMPLICIT NONE
    INTEGER RMF_ErrorMessage
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in), DIMENSION(:) :: t
    INTEGER, INTENT(in) :: n1
    CHARACTER(len=*), INTENT(in) :: var, func
    CHARACTER(len=200) :: error_string
    INTEGER :: errors, status, t1
    t1 = size(t,1)
    errors = 0
    if (t1 .lt. n1)  then
        errors = errors + 1
        write(error_string, '(A,A,A,I8,A,A)') "Dimension of ", var, " is less than ", n1, " in ", func
        status = RMF_ErrorMessage(id, trim(error_string)) 
    endif    
    Chk_Integer1D = errors
END FUNCTION Chk_Integer1D

INTEGER FUNCTION Chk_Integer2D(id, t, n1, n2, var, func)
    IMPLICIT NONE
    INTEGER RMF_ErrorMessage
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in), DIMENSION(:,:) :: t
    INTEGER, INTENT(in) :: n1, n2
    CHARACTER(len=*), INTENT(in) :: var, func
    CHARACTER(len=200) :: error_string
    INTEGER :: errors, status, t1, t2
    t1 = size(t,1)
    t2 = size(t,2)
    errors = 0
    if (t2 .ne. n2) then
        errors = errors + 1
        write(error_string, '(A,A,A,I8,A,A)') "Second dimension of ", var, " is not equal to ", n2, " in ", func
        status = RMF_ErrorMessage(id, trim(error_string))  
    endif
    if (t1 .lt. n1)  then
        errors = errors + 1
        write(error_string, '(A,A,A,I8,A,A)') "First dimension of ", var, " is less than ", n1, " in ", func
        status = RMF_ErrorMessage(id, trim(error_string)) 
    endif    
    Chk_Integer2D = errors
END FUNCTION Chk_Integer2D

END MODULE PhreeqcRM

    