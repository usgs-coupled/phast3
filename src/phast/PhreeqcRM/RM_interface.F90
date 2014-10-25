MODULE PhreeqcRM
INCLUDE 'RM_interface_F.f90.inc'
    CONTAINS
    
INTEGER FUNCTION RMF90_Abort(id, rslt, str)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: rslt
    CHARACTER, INTENT(in) :: str(*)
    ! closes output and log file
    RMF90_Abort = RM_Abort(id, rslt, str)
    RETURN    
END FUNCTION RMF90_Abort

INTEGER FUNCTION RMF90_CloseFiles(id)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    ! closes output and log file
    RMF90_CloseFiles = RM_CloseFiles(id)
    RETURN    
END FUNCTION RMF90_CloseFiles

INTEGER FUNCTION RMF90_Concentrations2Utility(id, c, n, tc, p_atm)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(in), DIMENSION(:,:) :: c
    INTEGER, INTENT(in) :: n
    DOUBLE PRECISION, INTENT(in), DIMENSION(:) :: tc, p_atm
#if !defined(NDEBUG)  
    INTEGER :: status, c1, c2, tc1, p_atm1, ncomps
    CHARACTER(100) :: error_string
      
    c1 = size(c,1)
    c2 = size(c,2)
    tc1 = size(tc)
    p_atm1 = size(p_atm)
    ! ncomps
    ncomps = RM_GetComponentCount(id)
    if (ncomps .eq. 0) then
        write(error_string, '(A, I4)') "Number of components is zero."  
        status = RM_ErrorMessage(id, trim(error_string))  
        RMF90_Concentrations2Utility = -7
        return
    endif
    if (ncomps < 0) then      
        RMF90_Concentrations2Utility = ncomps
        return
    endif
    if (c2 .ne. ncomps) then
        write(error_string, '(A, I4)') "Second dimension of c is not equal to ncomps, ", ncomps, "."
        status = RM_ErrorMessage(id, trim(error_string))  
        RMF90_Concentrations2Utility = -3
        return
    endif   
    ! c, tc, p_atm
    if ((tc1 .lt. n) .or. (p_atm1 .lt. n) .or. (c1 .lt. n)) then
        write(error_string, '(A, I4)') "First dimension of c and dimension of tc and p_atm must be greater than or equal to n, ", n, "."
        status = RM_ErrorMessage(id, trim(error_string)) 
        RMF90_Concentrations2Utility = -3 
        return
    endif
#endif    
    RMF90_Concentrations2Utility = RM_Concentrations2Utility(id, c, n, tc, p_atm)
    return
END FUNCTION RMF90_Concentrations2Utility  

INTEGER FUNCTION RMF90_Create(nxyz, nthreads) 
    IMPLICIT NONE
    INTEGER, INTENT(in) :: nxyz
	INTEGER, INTENT(in) :: nthreads
    RMF90_Create = RM_Create(nxyz, nthreads) 
    return
END FUNCTION RMF90_Create

INTEGER FUNCTION RMF90_CreateMapping(id, grid2chem)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in), DIMENSION(:) :: grid2chem
#if !defined(NDEBUG)    
    INTEGER :: status, g1, nxyz
    CHARACTER(100) :: error_string
    g1 = size(grid2chem,1)   
    nxyz = RM_GetGridCellCount(id)
    if (nxyz .eq. 0) then
        write(error_string, '(A, I4)') "Number of grid cells is zero."  
        status = RM_ErrorMessage(id, trim(error_string))  
        RMF90_CreateMapping = -7
        return
    endif
    if (nxyz .lt. 0) then  
        RMF90_CreateMapping = nxyz
        return
    endif 
    if (g1 .lt. nxyz) then
        write(error_string, '(A, I4)') "Dimension of grid2chem must be greater than or equal to nxyz, ", nxyz, "."
        status = RM_ErrorMessage(id, trim(error_string)) 
        RMF90_CreateMapping = -3 
        return        
    endif
#endif    
    RMF90_CreateMapping = RM_CreateMapping(id, grid2chem)
    return
END FUNCTION RMF90_CreateMapping

INTEGER FUNCTION RMF90_DecodeError(id, e)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: e
    RMF90_DecodeError = RM_DecodeError(id, e)
    return
END FUNCTION RMF90_DecodeError

INTEGER FUNCTION RMF90_Destroy(id)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    RMF90_Destroy = RM_Destroy(id)
    return
END FUNCTION RMF90_Destroy
  
INTEGER FUNCTION RMF90_DumpModule(id, dump_on, append) 
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    INTEGER, INTENT(in) :: dump_on
    INTEGER, INTENT(in) :: append
    RMF90_DumpModule = RM_DumpModule(id, dump_on, append)
    return
END FUNCTION RMF90_DumpModule

INTEGER FUNCTION RMF90_ErrorMessage(id, errstr)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    CHARACTER, INTENT(in) :: errstr(*)
    RMF90_ErrorMessage = RM_ErrorMessage(id, errstr)
    return
END FUNCTION RMF90_ErrorMessage
        
INTEGER FUNCTION RMF90_FindComponents(id) 
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    RMF90_FindComponents = RM_FindComponents(id)
    return
END FUNCTION RMF90_FindComponents  

INTEGER FUNCTION RMF90_GetChemistryCellCount(id)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    RMF90_GetChemistryCellCount = RM_GetChemistryCellCount(id)
    return
END FUNCTION RMF90_GetChemistryCellCount 
        
INTEGER FUNCTION RMF90_GetComponent(id, num, comp_name)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id, num
    CHARACTER, INTENT(out) :: comp_name(*)
    RMF90_GetComponent = RM_GetComponent(id, num, comp_name)
    return
END FUNCTION RMF90_GetComponent 
        
INTEGER FUNCTION RMF90_GetComponentCount(id)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    RMF90_GetComponentCount = RM_GetComponentCount(id)
    return
END FUNCTION RMF90_GetComponentCount 

INTEGER FUNCTION RMF90_GetConcentrations(id, c)   
    IMPLICIT NONE
    INTEGER, INTENT(in) :: id
    DOUBLE PRECISION, INTENT(out), DIMENSION(:,:) :: c
#if !defined(NDEBUG)   
    INTEGER :: status, c1, c2, nxyz, ncomps
    CHARACTER(100) :: error_string 
    c1 = size(c,1)
    c2 = size(c,2)
    
    ! ncomps
    ncomps = RM_GetComponentCount(id)
    if (ncomps .eq. 0) then
        write(error_string, '(A, I4)') "Number of components is zero."  
        status = RM_ErrorMessage(id, trim(error_string))  
        RMF90_GetConcentrations = -7
        return
    endif
    if (ncomps < 0) then      
        RMF90_GetConcentrations = ncomps
        return
    endif
    if (c2 .ne. ncomps) then
        write(error_string, '(A, I4)') "Second dimension of c is not equal to ncomps, ", ncomps, "."
        status = RM_ErrorMessage(id, trim(error_string))  
        RMF90_GetConcentrations = -3
        return
    endif  
    ! nxyz
    nxyz = RM_GetGridCellCount(id)
    if (nxyz .eq. 0) then
        write(error_string, '(A, I4)') "Number of grid cells is zero."  
        status = RM_ErrorMessage(id, trim(error_string))  
        RMF90_GetConcentrations = -7
        return
    endif
    if (nxyz < 0) then      
        RMF90_GetConcentrations = nxyz
        return
    endif
    if (c1 .lt. nxyz) then
        write(error_string, '(A, I4)') "First dimension of c must be greater than or equal to nxyz, ", nxyz, "."
        status = RM_ErrorMessage(id, trim(error_string))  
        RMF90_GetConcentrations = -3
        return
    endif
#endif      
    RMF90_GetConcentrations = RM_GetConcentrations(id, c)   
    return
END FUNCTION RMF90_GetConcentrations         



        
        



END MODULE PhreeqcRM
