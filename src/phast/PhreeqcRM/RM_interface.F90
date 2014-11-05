MODULE PhreeqcRM
    !USE ISO_C_BINDING
    IMPLICIT NONE
    SAVE
#if defined(NDEBUG)
    LOGICAL :: rmf_debug=.false.
#else
    LOGICAL :: rmf_debug=.true.
#endif     
    INTEGER :: rmf_nxyz=-1
    INTEGER :: rmf_ncomps=-1
!INCLUDE 'RM_interface_F.f90.inc'
    CONTAINS

INTEGER FUNCTION RM_Abort(id, rslt, str)
	USE ISO_C_BINDING
    IMPLICIT NONE 
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_Abort(id, result, str) &
			BIND(C, NAME='RMF_Abort')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: result
            CHARACTER(KIND=C_CHAR), INTENT(in) :: str(*)
        END FUNCTION RMF_Abort
    END INTERFACE     
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: rslt
    CHARACTER(len=*), INTENT(in) :: str
    RM_Abort = RMF_Abort(id, rslt, trim(str)//C_NULL_CHAR)
    RETURN    
END FUNCTION RM_Abort

INTEGER FUNCTION RM_CloseFiles(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_CloseFiles(id) &
			BIND(C, NAME='RMF_CloseFiles')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_CloseFiles
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_CloseFiles = RMF_CloseFiles(id)
    RETURN    
END FUNCTION RM_CloseFiles

INTEGER FUNCTION RM_Concentrations2Utility(id, c, n, tc, p_atm)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_Concentrations2Utility(id, c, n, tc, p_atm) &
			BIND(C, NAME='RMF_Concentrations2Utility')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: c(*)
            INTEGER(KIND=C_INT), INTENT(in) :: n
            REAL(KIND=C_DOUBLE), INTENT(in) :: tc(*), p_atm(*)
        END FUNCTION RMF_Concentrations2Utility  
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_Create(nxyz, nthreads) &
			BIND(C, NAME='RMF_Create') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: nxyz
			INTEGER(KIND=C_INT), INTENT(in) :: nthreads
        END FUNCTION RMF_Create
	END INTERFACE
    INTEGER, INTENT(in) :: nxyz
	INTEGER, INTENT(in) :: nthreads
    RM_Create = RMF_Create(nxyz, nthreads) 
    rmf_nxyz = nxyz
  
    return
END FUNCTION RM_Create

INTEGER FUNCTION RM_CreateMapping(id, grid2chem)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
		INTEGER(KIND=C_INT) FUNCTION RMF_CreateMapping(id, grid2chem) &
			BIND(C, NAME='RMF_CreateMapping')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: grid2chem(*)
        END FUNCTION RMF_CreateMapping
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
		INTEGER(KIND=C_INT) FUNCTION RMF_DecodeError(id, e) &
			BIND(C, NAME='RMF_DecodeError')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: e
        END FUNCTION RMF_DecodeError
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: e
    RM_DecodeError = RMF_DecodeError(id, e)
    return
END FUNCTION RM_DecodeError

INTEGER FUNCTION RM_Destroy(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_Destroy(id) &
			BIND(C, NAME='RMF_Destroy')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_Destroy
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_Destroy = RMF_Destroy(id)
    return
END FUNCTION RM_Destroy
  
INTEGER FUNCTION RM_DumpModule(id, dump_on, append) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_DumpModule(id, dump_on, append) &
			BIND(C, NAME='RMF_DumpModule')
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: dump_on
            INTEGER(KIND=C_INT), INTENT(in) :: append
        END FUNCTION RMF_DumpModule
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: dump_on
    INTEGER, INTENT(in) :: append
    RM_DumpModule = RMF_DumpModule(id, dump_on, append)
    return
END FUNCTION RM_DumpModule

INTEGER FUNCTION RM_ErrorMessage(id, errstr)
    USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_ErrorMessage(id, errstr) &
			BIND(C, NAME='RMF_ErrorMessage')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: errstr(*)
        END FUNCTION RMF_ErrorMessage
	END INTERFACE 
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: errstr
    RM_ErrorMessage = RMF_ErrorMessage(id, trim(errstr)//C_NULL_CHAR)
    return
END FUNCTION RM_ErrorMessage
        
INTEGER FUNCTION RM_FindComponents(id) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_FindComponents(id) &
			BIND(C, NAME='RMF_FindComponents') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_FindComponents  
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_FindComponents = RMF_FindComponents(id)
    rmf_ncomps = RM_FindComponents
    return
END FUNCTION RM_FindComponents  

INTEGER FUNCTION RM_GetChemistryCellCount(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetChemistryCellCount(id) &
			BIND(C, NAME='RMF_GetChemistryCellCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetChemistryCellCount 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetChemistryCellCount = RMF_GetChemistryCellCount(id)
    return
END FUNCTION RM_GetChemistryCellCount 
        
INTEGER FUNCTION RM_GetComponent(id, num, comp_name)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetComponent(id, num, comp_name, l) &
			BIND(C, NAME='RMF_GetComponent')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id, num, l
            CHARACTER(KIND=C_CHAR), INTENT(out) :: comp_name(*)
        END FUNCTION RMF_GetComponent 
	END INTERFACE
    INTEGER, INTENT(in) :: id, num
    CHARACTER(len=*), INTENT(inout) :: comp_name
    RM_GetComponent = RMF_GetComponent(id, num, comp_name, len(comp_name))
    return
END FUNCTION RM_GetComponent 
        
INTEGER FUNCTION RM_GetComponentCount(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetComponentCount(id) &
			BIND(C, NAME='RMF_GetComponentCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetComponentCount 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetComponentCount = RMF_GetComponentCount(id)
END FUNCTION RM_GetComponentCount 

INTEGER FUNCTION RM_GetConcentrations(id, c) 
	USE ISO_C_BINDING  
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetConcentrations(id, c) &
			BIND(C, NAME='RMF_GetConcentrations')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out)  :: c(*)
        END FUNCTION RMF_GetConcentrations 
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetDensity(id, density) &
			BIND(C, NAME='RMF_GetDensity')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: density(*)
        END FUNCTION RMF_GetDensity 
	END INTERFACE
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
	USE ISO_C_BINDING 
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetErrorString(id, errstr, l) &
			BIND(C, NAME='RMF_GetErrorString')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
			INTEGER(KIND=C_INT), INTENT(in) :: l
            CHARACTER(KIND=C_CHAR), INTENT(out) :: errstr(*)
        END FUNCTION RMF_GetErrorString 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(out) :: errstr
    RM_GetErrorString = RMF_GetErrorString(id, errstr, len(errstr))   
END FUNCTION RM_GetErrorString 

INTEGER FUNCTION RM_GetErrorStringLength(id)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetErrorStringLength(id) &
			BIND(C, NAME='RMF_GetErrorStringLength')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetErrorStringLength 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetErrorStringLength = RMF_GetErrorStringLength(id) 
END FUNCTION RM_GetErrorStringLength 
        
INTEGER FUNCTION RM_GetFilePrefix(id, prefix)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetFilePrefix(id, prefix, l) &
			BIND(C, NAME='RMF_GetFilePrefix')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: l
            CHARACTER(KIND=C_CHAR), INTENT(out) :: prefix(*)
        END FUNCTION RMF_GetFilePrefix
	END INTERFACE
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(inout) :: prefix
    integer l
    l = len(prefix)
    RM_GetFilePrefix = RMF_GetFilePrefix(id, prefix, l)
END FUNCTION RM_GetFilePrefix

INTEGER FUNCTION RM_GetGfw(id, gfw)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetGfw(id, gfw) &
			BIND(C, NAME='RMF_GetGfw')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: gfw(*)
        END FUNCTION RMF_GetGfw 
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetGridCellCount(id) &
			BIND(C, NAME='RMF_GetGridCellCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetGridCellCount
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetGridCellCount = RMF_GetGridCellCount(id)
END FUNCTION RM_GetGridCellCount

INTEGER FUNCTION RM_GetIPhreeqcId(id, i)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetIPhreeqcId(id, i) &
			BIND(C, NAME='RMF_GetIPhreeqcId')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: i
        END FUNCTION RMF_GetIPhreeqcId
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: i
    RM_GetIPhreeqcId = RMF_GetIPhreeqcId(id, i)
END FUNCTION RM_GetIPhreeqcId
        
INTEGER FUNCTION RM_GetMpiMyself(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetMpiMyself(id) &
			BIND(C, NAME='RMF_GetMpiMyself')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetMpiMyself
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetMpiMyself = RMF_GetMpiMyself(id)
END FUNCTION RM_GetMpiMyself
        
INTEGER FUNCTION RM_GetMpiTasks(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetMpiTasks(id) &
			BIND(C, NAME='RMF_GetMpiTasks')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetMpiTasks
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetMpiTasks = RMF_GetMpiTasks(id)
END FUNCTION RM_GetMpiTasks
        
INTEGER FUNCTION RM_GetNthSelectedOutputUserNumber(id, n)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetNthSelectedOutputUserNumber(id, n) &
			BIND(C, NAME='RMF_GetNthSelectedOutputUserNumber')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id, n
        END FUNCTION RMF_GetNthSelectedOutputUserNumber 
	END INTERFACE
    INTEGER, INTENT(in) :: id, n
    RM_GetNthSelectedOutputUserNumber = RMF_GetNthSelectedOutputUserNumber(id, n)
END FUNCTION RM_GetNthSelectedOutputUserNumber 
        
INTEGER FUNCTION RM_GetSaturation(id, sat)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSaturation(id, sat) &
			BIND(C, NAME='RMF_GetSaturation')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: sat(*)
        END FUNCTION RMF_GetSaturation
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSelectedOutput(id, so) &
			BIND(C, NAME='RMF_GetSelectedOutput')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: so(*)
        END FUNCTION RMF_GetSelectedOutput
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSelectedOutputColumnCount(id) &
			BIND(C, NAME='RMF_GetSelectedOutputColumnCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetSelectedOutputColumnCount
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetSelectedOutputColumnCount = RMF_GetSelectedOutputColumnCount(id)
END FUNCTION RM_GetSelectedOutputColumnCount
        
INTEGER FUNCTION RM_GetSelectedOutputCount(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSelectedOutputCount(id) &
			BIND(C, NAME='RMF_GetSelectedOutputCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetSelectedOutputCount
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetSelectedOutputCount = RMF_GetSelectedOutputCount(id)
END FUNCTION RM_GetSelectedOutputCount
        
INTEGER FUNCTION RM_GetSelectedOutputHeading(id, icol, heading)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSelectedOutputHeading(id, icol, heading, l) &
			BIND(C, NAME='RMF_GetSelectedOutputHeading')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id, icol, l
            CHARACTER(KIND=C_CHAR), INTENT(out) :: heading(*)
        END FUNCTION RMF_GetSelectedOutputHeading
	END INTERFACE
    INTEGER, INTENT(in) :: id, icol
    CHARACTER(len=*), INTENT(out) :: heading
    RM_GetSelectedOutputHeading = RMF_GetSelectedOutputHeading(id, icol, heading, len(heading))
END FUNCTION RM_GetSelectedOutputHeading
        
INTEGER FUNCTION RM_GetSelectedOutputRowCount(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSelectedOutputRowCount(id) &
			BIND(C, NAME='RMF_GetSelectedOutputRowCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetSelectedOutputRowCount
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetSelectedOutputRowCount = RMF_GetSelectedOutputRowCount(id)
END FUNCTION RM_GetSelectedOutputRowCount

INTEGER FUNCTION RM_GetSolutionVolume(id, vol)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSolutionVolume(id, vol) &
			BIND(C, NAME='RMF_GetSolutionVolume')  
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: vol(*)
        END FUNCTION RMF_GetSolutionVolume 
	END INTERFACE
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
	USE ISO_C_BINDING  
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesConcentrations(id, species_conc) &
			BIND(C, NAME='RMF_GetSpeciesConcentrations')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: species_conc(*)
        END FUNCTION RMF_GetSpeciesConcentrations 
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesCount(id) &
			BIND(C, NAME='RMF_GetSpeciesCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetSpeciesCount
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetSpeciesCount = RMF_GetSpeciesCount(id)
END FUNCTION RM_GetSpeciesCount

INTEGER FUNCTION RM_GetSpeciesD25(id, diffc)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesD25(id, diffc) &
			BIND(C, NAME='RMF_GetSpeciesD25')  
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: diffc(*)
        END FUNCTION RMF_GetSpeciesD25 
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesName(id, i, name, l) &
			BIND(C, NAME='RMF_GetSpeciesName')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id, i, l
            CHARACTER(KIND=C_CHAR), INTENT(out) :: name(*)
        END FUNCTION RMF_GetSpeciesName
	END INTERFACE
    INTEGER, INTENT(in) :: id, i
    CHARACTER(len=*), INTENT(out) :: name
    RM_GetSpeciesName = RMF_GetSpeciesName(id, i, name, len(name))
END FUNCTION RM_GetSpeciesName

INTEGER FUNCTION RM_GetSpeciesSaveOn(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesSaveOn(id) &
			BIND(C, NAME='RMF_GetSpeciesSaveOn')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetSpeciesSaveOn
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetSpeciesSaveOn = RMF_GetSpeciesSaveOn(id)
END FUNCTION RM_GetSpeciesSaveOn

INTEGER FUNCTION RM_GetSpeciesZ(id, z)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesZ(id, z) &
			BIND(C, NAME='RMF_GetSpeciesZ')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: z(*)
        END FUNCTION RMF_GetSpeciesZ 
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_GetThreadCount(id) &
			BIND(C, NAME='RMF_GetThreadCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetThreadCount
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetThreadCount = RMF_GetThreadCount(id)
END FUNCTION RM_GetThreadCount
        
DOUBLE PRECISION FUNCTION RM_GetTime(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        REAL(KIND=C_DOUBLE) FUNCTION RMF_GetTime(id) &
			BIND(C, NAME='RMF_GetTime')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetTime
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetTime = RMF_GetTime(id)
END FUNCTION RM_GetTime
        
DOUBLE PRECISION FUNCTION RM_GetTimeConversion(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        REAL(KIND=C_DOUBLE) FUNCTION RMF_GetTimeConversion(id) &
			BIND(C, NAME='RMF_GetTimeConversion')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetTimeConversion
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetTimeConversion = RMF_GetTimeConversion(id)
END FUNCTION RM_GetTimeConversion
        
DOUBLE PRECISION FUNCTION RM_GetTimeStep(id)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        REAL(KIND=C_DOUBLE) FUNCTION RMF_GetTimeStep(id) &
			BIND(C, NAME='RMF_GetTimeStep')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetTimeStep 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_GetTimeStep = RMF_GetTimeStep(id)
END FUNCTION RM_GetTimeStep 

INTEGER FUNCTION RM_InitialPhreeqc2Concentrations(id, c, n_boundary, bc_sol1, bc_sol2, f1) 
	USE ISO_C_BINDING  
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_InitialPhreeqc2Concentrations(id, c, n_boundary, bc_sol1, bc_sol2, f1) &
			BIND(C, NAME='RMF_InitialPhreeqc2Concentrations')
			USE ISO_C_BINDING   
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(OUT) :: c(*)
            INTEGER(KIND=C_INT), INTENT(IN) :: n_boundary, bc_sol1(*)
            INTEGER(KIND=C_INT), INTENT(IN), OPTIONAL :: bc_sol2(*)
            REAL(KIND=C_DOUBLE), INTENT(IN), OPTIONAL :: f1(*)
        END FUNCTION RMF_InitialPhreeqc2Concentrations
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_InitialPhreeqc2Module(id, ic1, ic2, f1) &
			BIND(C, NAME='RMF_InitialPhreeqc2Module')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: ic1(*)
            INTEGER(KIND=C_INT), INTENT(in), OPTIONAL :: ic2(*)
            REAL(KIND=C_DOUBLE), INTENT(in), OPTIONAL :: f1(*)
        END FUNCTION RMF_InitialPhreeqc2Module  
	END INTERFACE
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
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_InitialPhreeqcCell2Module(id, n_user, module_cell, dim_module_cell) &
			BIND(C, NAME='RMF_InitialPhreeqcCell2Module')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: n_user
            INTEGER(KIND=C_INT), INTENT(in) :: module_cell(*)
            INTEGER(KIND=C_INT), INTENT(in) :: dim_module_cell
        END FUNCTION RMF_InitialPhreeqcCell2Module  
	END INTERFACE
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
	USE ISO_C_BINDING  
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_InitialPhreeqc2SpeciesConcentrations(id, species_c, n_boundary, bc_sol1, bc_sol2, f1) &
			BIND(C, NAME='RMF_InitialPhreeqc2SpeciesConcentrations')   
			USE ISO_C_BINDING
                IMPLICIT NONE
                INTEGER(KIND=C_INT), INTENT(in) :: id
                REAL(KIND=C_DOUBLE), INTENT(OUT) :: species_c(*)
                INTEGER(KIND=C_INT), INTENT(IN) :: n_boundary, bc_sol1(*)
                INTEGER(KIND=C_INT), INTENT(IN), OPTIONAL :: bc_sol2(*)
                REAL(KIND=C_DOUBLE), INTENT(IN), OPTIONAL :: f1(*)
        END FUNCTION RMF_InitialPhreeqc2SpeciesConcentrations   
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:,:), INTENT(OUT) :: species_c
    INTEGER, INTENT(IN) :: n_boundary
    INTEGER, INTENT(IN), DIMENSION(:) :: bc_sol1
    INTEGER, INTENT(IN), DIMENSION(:), OPTIONAL :: bc_sol2
    DOUBLE PRECISION, INTENT(IN), DIMENSION(:), OPTIONAL :: f1
	if (rmf_debug) call Chk_InitialPhreeqc2SpeciesConcentrations(id, species_c, n_boundary, bc_sol1, bc_sol2, f1) 
    RM_InitialPhreeqc2SpeciesConcentrations = RMF_InitialPhreeqc2SpeciesConcentrations(id, species_c, n_boundary, bc_sol1, bc_sol2, f1)
END FUNCTION RM_InitialPhreeqc2SpeciesConcentrations          
        
SUBROUTINE Chk_InitialPhreeqc2SpeciesConcentrations(id, species_c, n_boundary, bc_sol1, bc_sol2, f1) 
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(IN), DIMENSION(:,:) :: species_c
    INTEGER, INTENT(IN) :: n_boundary 
    INTEGER, INTENT(IN), DIMENSION(:) :: bc_sol1
    INTEGER, INTENT(IN), DIMENSION(:) , OPTIONAL :: bc_sol2
    DOUBLE PRECISION, INTENT(IN), DIMENSION(:) , OPTIONAL :: f1
    INTEGER :: errors, nspecies
    nspecies = RM_GetSpeciesCount(id)
    errors = 0
    errors = errors + Chk_Double2D(id, species_c, n_boundary, nspecies, "concentration", "RM_InitialPhreeqc2SpeciesConcentrations")
    errors = errors + Chk_Integer1D(id, bc_sol1, n_boundary, "bc_sol1", "RM_InitialPhreeqc2SpeciesConcentrations")
    if (present(bc_sol2)) then
        errors = errors + Chk_Integer1D(id, bc_sol2, n_boundary, "bc_sol2", "RM_InitialPhreeqc2SpeciesConcentrations")
    endif
    if (present(f1)) then
        errors = errors + Chk_Double1D(id, f1, n_boundary, "f1", "RM_InitialPhreeqc2SpeciesConcentrations")
    endif
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_InitialPhreeqc2SpeciesConcentrations")
    endif
END SUBROUTINE Chk_InitialPhreeqc2SpeciesConcentrations

INTEGER FUNCTION RM_LoadDatabase(id, db) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_LoadDatabase(id, db) &
			BIND(C, NAME='RMF_LoadDatabase') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: db(*)
        END FUNCTION RMF_LoadDatabase 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: db
    RM_LoadDatabase = RMF_LoadDatabase(id, trim(db)//C_NULL_CHAR)
END FUNCTION RM_LoadDatabase 
        
INTEGER FUNCTION RM_LogMessage(id, str) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_LogMessage(id, str) &
			BIND(C, NAME='RMF_LogMessage') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: str(*)
        END FUNCTION RMF_LogMessage
	END INTERFACE
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: str
    RM_LogMessage = RMF_LogMessage(id, trim(str)//C_NULL_CHAR)
END FUNCTION RM_LogMessage

INTEGER FUNCTION RM_MpiWorker(id) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_MpiWorker(id) &
			BIND(C, NAME='RMF_MpiWorker') 
			USE ISO_C_BINDING
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_MpiWorker
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_MpiWorker = RMF_MpiWorker(id)
END FUNCTION RM_MpiWorker

INTEGER FUNCTION RM_MpiWorkerBreak(id) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_MpiWorkerBreak(id) &
			BIND(C, NAME='RMF_MpiWorkerBreak') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_MpiWorkerBreak
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_MpiWorkerBreak = RMF_MpiWorkerBreak(id)
END FUNCTION RM_MpiWorkerBreak
        
INTEGER FUNCTION RM_OpenFiles(id) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_OpenFiles(id) &
			BIND(C, NAME='RMF_OpenFiles') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_OpenFiles
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_OpenFiles = RMF_OpenFiles(id)
END FUNCTION RM_OpenFiles
        
INTEGER FUNCTION RM_OutputMessage(id, str)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_OutputMessage(id, str) &
			BIND(C, NAME='RMF_OutputMessage')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: str(*)
        END FUNCTION RMF_OutputMessage
	END INTERFACE
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: str
    RM_OutputMessage = RMF_OutputMessage(id, trim(str)//C_NULL_CHAR)
END FUNCTION RM_OutputMessage
        
INTEGER FUNCTION RM_RunCells(id)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_RunCells(id) &
			BIND(C, NAME='RMF_RunCells')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_RunCells  
	END INTERFACE
    INTEGER, INTENT(in) :: id
    RM_RunCells = RMF_RunCells(id)
END FUNCTION RM_RunCells  

INTEGER FUNCTION RM_RunFile(id, workers, initial_phreeqc, utility, chem_name)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_RunFile(id, workers, initial_phreeqc, utility, chem_name) &
			BIND(C, NAME='RMF_RunFile')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: workers, initial_phreeqc, utility
            CHARACTER(KIND=C_CHAR), INTENT(in) :: chem_name(*)
        END FUNCTION RMF_RunFile   
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: workers, initial_phreeqc, utility
    CHARACTER(len=*), INTENT(in) :: chem_name
    RM_RunFile = RMF_RunFile(id, workers, initial_phreeqc, utility, trim(chem_name)//C_NULL_CHAR)
END FUNCTION RM_RunFile   
        
INTEGER FUNCTION RM_RunString(id, initial_phreeqc, workers, utility, input_string)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_RunString(id, initial_phreeqc, workers, utility, input_string) &
			BIND(C, NAME='RMF_RunString')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: initial_phreeqc, workers, utility
            CHARACTER(KIND=C_CHAR), INTENT(in) :: input_string(*)
        END FUNCTION RMF_RunString   
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: initial_phreeqc, workers, utility
    CHARACTER(len=*), INTENT(in) :: input_string
    RM_RunString = RMF_RunString(id, initial_phreeqc, workers, utility, trim(input_string)//C_NULL_CHAR)
END FUNCTION RM_RunString   
        
INTEGER FUNCTION RM_ScreenMessage(id, str) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_ScreenMessage(id, str) &
			BIND(C, NAME='RMF_ScreenMessage') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: str(*)
        END FUNCTION RMF_ScreenMessage 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: str
    RM_ScreenMessage = RMF_ScreenMessage(id, trim(str)//C_NULL_CHAR) 
END FUNCTION RM_ScreenMessage   
 		     
INTEGER FUNCTION RM_SetComponentH2O(id, tf)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetComponentH2O(id, tf) &
			BIND(C, NAME='RMF_SetComponentH2O')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: tf
        END FUNCTION RMF_SetComponentH2O
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: tf
    RM_SetComponentH2O = RMF_SetComponentH2O(id, tf)
END FUNCTION RM_SetComponentH2O
 		     
INTEGER FUNCTION RM_SetConcentrations(id, c)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetConcentrations(id, c) &
			BIND(C, NAME='RMF_SetConcentrations')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: c(*)
        END FUNCTION RMF_SetConcentrations
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:,:), INTENT(in) :: c
	if (rmf_debug) call Chk_SetConcentrations(id, c)
    RM_SetConcentrations = RMF_SetConcentrations(id, c)
END FUNCTION RM_SetConcentrations
 	
SUBROUTINE Chk_SetConcentrations(id, c)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:,:) :: c
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double2D(id, c, rmf_nxyz, rmf_ncomps, "concentration", "RM_SetConcentrations")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_SetConcentrations")
    endif
END SUBROUTINE Chk_SetConcentrations

INTEGER FUNCTION RM_SetCurrentSelectedOutputUserNumber(id, n_user)  
	USE ISO_C_BINDING 
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetCurrentSelectedOutputUserNumber(id, n_user) &
			BIND(C, NAME='RMF_SetCurrentSelectedOutputUserNumber') 
			USE ISO_C_BINDING  
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: n_user
        END FUNCTION RMF_SetCurrentSelectedOutputUserNumber
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: n_user
    RM_SetCurrentSelectedOutputUserNumber = RMF_SetCurrentSelectedOutputUserNumber(id, n_user)
END FUNCTION RM_SetCurrentSelectedOutputUserNumber

INTEGER FUNCTION RM_SetDensity(id, density)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetDensity(id, density) &
			BIND(C, NAME='RMF_SetDensity')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: density(*)
        END FUNCTION RMF_SetDensity 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: density
	if (rmf_debug) call Chk_SetDensity(id, density)
    RM_SetDensity = RMF_SetDensity(id, density)
END FUNCTION RM_SetDensity 

SUBROUTINE Chk_SetDensity(id, density)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: density
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double1D(id, density, rmf_nxyz, "density", "RM_SetDensity")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_SetDensity")
    endif
END SUBROUTINE Chk_SetDensity
        
INTEGER FUNCTION RM_SetDumpFileName(id, name) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetDumpFileName(id, name) &
			BIND(C, NAME='RMF_SetDumpFileName') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: name(*)
        END FUNCTION RMF_SetDumpFileName  
	END INTERFACE
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: name
    RM_SetDumpFileName = RMF_SetDumpFileName(id, trim(name)//C_NULL_CHAR)
END FUNCTION RM_SetDumpFileName   

INTEGER FUNCTION RM_SetErrorHandlerMode(id, i)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetErrorHandlerMode(id, i) &
			BIND(C, NAME='RMF_SetErrorHandlerMode')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: i
        END FUNCTION RMF_SetErrorHandlerMode    
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: i
    RM_SetErrorHandlerMode = RMF_SetErrorHandlerMode(id, i)
END FUNCTION RM_SetErrorHandlerMode        
		        
INTEGER FUNCTION RM_SetFilePrefix(id, prefix) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetFilePrefix(id, prefix) &
			BIND(C, NAME='RMF_SetFilePrefix') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: prefix(*)
        END FUNCTION RMF_SetFilePrefix  
	END INTERFACE
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: prefix
    RM_SetFilePrefix = RMF_SetFilePrefix(id, trim(prefix)//C_NULL_CHAR) 
END FUNCTION RM_SetFilePrefix  

INTEGER FUNCTION RM_SetMpiWorkerCallback(id, fcn)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetMpiWorkerCallback(id, fcn) &
			BIND(C, NAME='RMF_SetMpiWorkerCallback')
			USE ISO_C_BINDING
			INTEGER(KIND=C_INT), INTENT(in) :: id
			INTERFACE
				INTEGER FUNCTION fcn(method_number)
				INTEGER, INTENT(in) :: method_number
				END FUNCTION 
			END INTERFACE
        END FUNCTION RMF_SetMpiWorkerCallback
	END INTERFACE
	INTEGER, INTENT(IN) :: id
	INTERFACE
		INTEGER FUNCTION fcn(method_number)
		INTEGER, INTENT(in) :: method_number
		END FUNCTION 
    END INTERFACE
    RM_SetMpiWorkerCallback = RMF_SetMpiWorkerCallback(id, fcn)
END FUNCTION RM_SetMpiWorkerCallback

INTEGER FUNCTION RM_SetPartitionUZSolids(id, tf)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetPartitionUZSolids(id, tf) &
			BIND(C, NAME='RMF_SetPartitionUZSolids')  
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in)  :: tf
        END FUNCTION RMF_SetPartitionUZSolids 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in)  :: tf
    RM_SetPartitionUZSolids = RMF_SetPartitionUZSolids(id, tf)
END FUNCTION RM_SetPartitionUZSolids 

INTEGER FUNCTION RM_SetPorosity(id, por)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetPorosity(id, por) &
			BIND(C, NAME='RMF_SetPorosity')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: por(*)
        END FUNCTION RMF_SetPorosity 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: por
	if (rmf_debug) call Chk_SetPorosity(id, por)
    RM_SetPorosity = RMF_SetPorosity(id, por)
END FUNCTION RM_SetPorosity 

SUBROUTINE Chk_SetPorosity(id, por)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: por
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double1D(id, por, rmf_nxyz, "porosity", "RM_SetPorosity")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_SetPorosity")
    endif
END SUBROUTINE Chk_SetPorosity

INTEGER FUNCTION RM_SetPressure(id, p)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetPressure(id, p) &
			BIND(C, NAME='RMF_SetPressure')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: p(*)
        END FUNCTION RMF_SetPressure   
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: p
	if (rmf_debug) call Chk_SetPressure(id, p)
    RM_SetPressure = RMF_SetPressure(id, p)
END FUNCTION RM_SetPressure        
  
SUBROUTINE Chk_SetPressure(id, p) 
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: p
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double1D(id, p, rmf_nxyz, "pressure", "RM_SetPressure")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_SetPressure")
    endif
END SUBROUTINE Chk_SetPressure

INTEGER FUNCTION RM_SetPrintChemistryOn(id, worker, initial_phreeqc, utility)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetPrintChemistryOn(id, worker, initial_phreeqc, utility) &
			BIND(C, NAME='RMF_SetPrintChemistryOn')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: worker, initial_phreeqc, utility
        END FUNCTION RMF_SetPrintChemistryOn 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: worker, initial_phreeqc, utility
    RM_SetPrintChemistryOn = RMF_SetPrintChemistryOn(id, worker, initial_phreeqc, utility)
END FUNCTION RM_SetPrintChemistryOn 

INTEGER FUNCTION RM_SetPrintChemistryMask(id, cell_mask)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetPrintChemistryMask(id, cell_mask) &
			BIND(C, NAME='RMF_SetPrintChemistryMask') 
			USE ISO_C_BINDING  
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: cell_mask(*)
        END FUNCTION RMF_SetPrintChemistryMask 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, DIMENSION(:), INTENT(in) :: cell_mask
	if (rmf_debug) call Chk_SetPrintChemistryMask(id, cell_mask)
    RM_SetPrintChemistryMask = RMF_SetPrintChemistryMask(id, cell_mask)
END FUNCTION RM_SetPrintChemistryMask 
 
SUBROUTINE Chk_SetPrintChemistryMask(id, cell_mask)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in), DIMENSION(:) :: cell_mask
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Integer1D(id, cell_mask, rmf_nxyz, "cell_mask", "RM_SetPrintChemistryMask")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_SetPrintChemistryMask")
    endif
END SUBROUTINE Chk_SetPrintChemistryMask

INTEGER FUNCTION RM_SetRebalanceByCell(id, method)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetRebalanceByCell(id, method) &
			BIND(C, NAME='RMF_SetRebalanceByCell')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in)  :: method
        END FUNCTION RMF_SetRebalanceByCell
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in)  :: method
    RM_SetRebalanceByCell = RMF_SetRebalanceByCell(id, method)
END FUNCTION RM_SetRebalanceByCell
        
INTEGER FUNCTION RM_SetRebalanceFraction(id, f)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetRebalanceFraction(id, f) &
			BIND(C, NAME='RMF_SetRebalanceFraction')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in)  :: f
        END FUNCTION RMF_SetRebalanceFraction
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in)  :: f
    RM_SetRebalanceFraction = RMF_SetRebalanceFraction(id, f)
END FUNCTION RM_SetRebalanceFraction
		
INTEGER FUNCTION RM_SetRepresentativeVolume(id, rv)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetRepresentativeVolume(id, rv) &
			BIND(C, NAME='RMF_SetRepresentativeVolume') 
			USE ISO_C_BINDING  
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: rv(*)
        END FUNCTION RMF_SetRepresentativeVolume 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: rv
    RM_SetRepresentativeVolume = RMF_SetRepresentativeVolume(id, rv)
END FUNCTION RM_SetRepresentativeVolume 

INTEGER FUNCTION RM_SetSaturation(id, sat)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetSaturation(id, sat) &
			BIND(C, NAME='RMF_SetSaturation')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: sat(*)
        END FUNCTION RMF_SetSaturation 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: sat
	if (rmf_debug) call Chk_SetSaturation(id, sat)
    RM_SetSaturation = RMF_SetSaturation(id, sat)
END FUNCTION RM_SetSaturation 

SUBROUTINE Chk_SetSaturation(id, sat)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: sat
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double1D(id, sat, rmf_nxyz, "sataturation", "RM_SetSaturation")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_SetSaturation")
    endif
END SUBROUTINE Chk_SetSaturation

INTEGER FUNCTION RM_SetSelectedOutputOn(id, tf)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetSelectedOutputOn(id, tf) &
			BIND(C, NAME='RMF_SetSelectedOutputOn')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: tf
        END FUNCTION RMF_SetSelectedOutputOn  
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: tf
    RM_SetSelectedOutputOn = RMF_SetSelectedOutputOn(id, tf)
END FUNCTION RM_SetSelectedOutputOn   

INTEGER FUNCTION RM_SetSpeciesSaveOn(id, save_on)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetSpeciesSaveOn(id, save_on) &
			BIND(C, NAME='RMF_SetSpeciesSaveOn')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: save_on
        END FUNCTION RMF_SetSpeciesSaveOn
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: save_on
    RM_SetSpeciesSaveOn = RMF_SetSpeciesSaveOn(id, save_on)
END FUNCTION RM_SetSpeciesSaveOn

INTEGER FUNCTION RM_SetTemperature(id, t)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetTemperature(id, t) &
			BIND(C, NAME='RMF_SetTemperature')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: t(*)
        END FUNCTION RMF_SetTemperature 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:), INTENT(in) :: t
	if (rmf_debug) call Chk_SetTemperature(id, t)
    RM_SetTemperature = RMF_SetTemperature(id, t)
END FUNCTION RM_SetTemperature 

SUBROUTINE Chk_SetTemperature(id, t)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: t
    INTEGER :: errors
    errors = 0
    errors = errors + Chk_Double1D(id, t, rmf_nxyz, "temperature", "RM_SetTemperature")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_SetTemperature")
    endif
END SUBROUTINE Chk_SetTemperature

INTEGER FUNCTION RM_SetTime(id, time)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetTime(id, time) &
			BIND(C, NAME='RMF_SetTime')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: time
        END FUNCTION RMF_SetTime 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in) :: time
    RM_SetTime = RMF_SetTime(id, time)
END FUNCTION RM_SetTime 
		     
INTEGER FUNCTION RM_SetTimeConversion(id, conv_factor)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetTimeConversion(id, conv_factor) &
			BIND(C, NAME='RMF_SetTimeConversion') 
			USE ISO_C_BINDING  
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: conv_factor
        END FUNCTION RMF_SetTimeConversion 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in) :: conv_factor
    RM_SetTimeConversion = RMF_SetTimeConversion(id, conv_factor)
END FUNCTION RM_SetTimeConversion 
		     
INTEGER FUNCTION RM_SetTimeStep(id, time_step)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetTimeStep(id, time_step) &
			BIND(C, NAME='RMF_SetTimeStep')  
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: time_step
        END FUNCTION RMF_SetTimeStep 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in) :: time_step
    RM_SetTimeStep = RMF_SetTimeStep(id, time_step)
END FUNCTION RM_SetTimeStep 

INTEGER FUNCTION RM_SetUnitsExchange(id, option)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsExchange(id, option) &
			BIND(C, NAME='RMF_SetUnitsExchange')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsExchange 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsExchange = RMF_SetUnitsExchange(id, option)
END FUNCTION RM_SetUnitsExchange 

INTEGER FUNCTION RM_SetUnitsGasPhase(id, option)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsGasPhase(id, option) &
			BIND(C, NAME='RMF_SetUnitsGasPhase')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsGasPhase 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsGasPhase = RMF_SetUnitsGasPhase(id, option)
END FUNCTION RM_SetUnitsGasPhase 

INTEGER FUNCTION RM_SetUnitsKinetics(id, option)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsKinetics(id, option) &
			BIND(C, NAME='RMF_SetUnitsKinetics')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsKinetics 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsKinetics = RMF_SetUnitsKinetics(id, option)
END FUNCTION RM_SetUnitsKinetics 

INTEGER FUNCTION RM_SetUnitsPPassemblage(id, option)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsPPassemblage(id, option) &
			BIND(C, NAME='RMF_SetUnitsPPassemblage')  
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsPPassemblage
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsPPassemblage = RMF_SetUnitsPPassemblage(id, option)
END FUNCTION RM_SetUnitsPPassemblage

INTEGER FUNCTION RM_SetUnitsSolution(id, option)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsSolution(id, option) &
			BIND(C, NAME='RMF_SetUnitsSolution')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsSolution  
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsSolution = RMF_SetUnitsSolution(id, option)
END FUNCTION RM_SetUnitsSolution  

INTEGER FUNCTION RM_SetUnitsSSassemblage(id, option)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsSSassemblage(id, option) &
			BIND(C, NAME='RMF_SetUnitsSSassemblage')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsSSassemblage 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsSSassemblage = RMF_SetUnitsSSassemblage(id, option)
END FUNCTION RM_SetUnitsSSassemblage  

INTEGER FUNCTION RM_SetUnitsSurface(id, option)   
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsSurface(id, option) &
			BIND(C, NAME='RMF_SetUnitsSurface')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsSurface 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: option
    RM_SetUnitsSurface = RMF_SetUnitsSurface(id, option)
END FUNCTION RM_SetUnitsSurface  

INTEGER FUNCTION RM_SpeciesConcentrations2Module(id, species_conc)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_SpeciesConcentrations2Module(id, species_conc) &
			BIND(C, NAME='RMF_SpeciesConcentrations2Module')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: species_conc(*)
        END FUNCTION RMF_SpeciesConcentrations2Module
	END INTERFACE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:,:), INTENT(in) :: species_conc
	if (rmf_debug) call Chk_SpeciesConcentrations2Module(id, species_conc)
    RM_SpeciesConcentrations2Module = RMF_SpeciesConcentrations2Module(id, species_conc)
END FUNCTION RM_SpeciesConcentrations2Module  

SUBROUTINE Chk_SpeciesConcentrations2Module(id, species_conc)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, DIMENSION(:,:), INTENT(in) :: species_conc
    INTEGER :: errors, nspecies
    nspecies = RM_GetSpeciesCount(id)
    errors = 0
    errors = errors + Chk_Double2D(id, species_conc, rmf_nxyz, nspecies, "species_conc", "RM_SpeciesConcentrations2Module")
    if (errors .gt. 0) then
        errors = RM_Abort(id, -3, "Invalid argument in RM_SpeciesConcentrations2Module")
    endif
END SUBROUTINE Chk_SpeciesConcentrations2Module

INTEGER FUNCTION RM_UseSolutionDensityVolume(id, tf)
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_UseSolutionDensityVolume(id, tf) &
			BIND(C, NAME='RMF_UseSolutionDensityVolume')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: tf
        END FUNCTION RMF_UseSolutionDensityVolume 
	END INTERFACE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: tf
    RM_UseSolutionDensityVolume = RMF_UseSolutionDensityVolume(id, tf)
END FUNCTION RM_UseSolutionDensityVolume 
        
INTEGER FUNCTION RM_WarningMessage(id, str) 
	USE ISO_C_BINDING
    IMPLICIT NONE
    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_WarningMessage(id, str) &
			BIND(C, NAME='RMF_WarningMessage') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: str(*)
        END FUNCTION RMF_WarningMessage
	END INTERFACE
    INTEGER, INTENT(in) :: id
    CHARACTER(len=*), INTENT(in) :: str
    RM_WarningMessage = RMF_WarningMessage(id, trim(str)//C_NULL_CHAR)
END FUNCTION RM_WarningMessage

INTEGER FUNCTION Chk_Double1D(id, t, n1, var, func)
    IMPLICIT NONE
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
        status = RM_ErrorMessage(id, trim(error_string)) 
    endif    
    Chk_Double1D = errors
END FUNCTION Chk_Double1D

INTEGER FUNCTION Chk_Double2D(id, t, n1, n2, var, func)
    IMPLICIT NONE
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
        status = RM_ErrorMessage(id, trim(error_string))  
    endif
    if (t1 .lt. n1)  then
        errors = errors + 1
        write(error_string, '(A,A,A,I8,A,A)') "First dimension of ", var, " is less than ", n1, " in ", func
        status = RM_ErrorMessage(id, trim(error_string)) 
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
        status = RM_ErrorMessage(id, trim(error_string)) 
    endif    
    Chk_Integer1D = errors
END FUNCTION Chk_Integer1D

INTEGER FUNCTION Chk_Integer2D(id, t, n1, n2, var, func)
    IMPLICIT NONE
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
        status = RM_ErrorMessage(id, trim(error_string))  
    endif
    if (t1 .lt. n1)  then
        errors = errors + 1
        write(error_string, '(A,A,A,I8,A,A)') "First dimension of ", var, " is less than ", n1, " in ", func
        status = RM_ErrorMessage(id, trim(error_string)) 
    endif    
    Chk_Integer2D = errors
END FUNCTION Chk_Integer2D

END MODULE PhreeqcRM

    