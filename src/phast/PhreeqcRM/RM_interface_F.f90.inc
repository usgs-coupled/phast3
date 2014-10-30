    INTERFACE
        INTEGER(KIND=C_INT) FUNCTION RMF_Abort(id, result, str) &
			BIND(C, NAME='RMF_Abort')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: result
            CHARACTER(KIND=C_CHAR), INTENT(in) :: str(*)
        END FUNCTION RMF_Abort

        INTEGER(KIND=C_INT) FUNCTION RMF_CloseFiles(id) &
			BIND(C, NAME='RMF_CloseFiles')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_CloseFiles
        
        INTEGER(KIND=C_INT) FUNCTION RMF_Concentrations2Utility(id, c, n, tc, p_atm) &
			BIND(C, NAME='RMF_Concentrations2Utility')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: c(*)
            INTEGER(KIND=C_INT), INTENT(in) :: n
            REAL(KIND=C_DOUBLE), INTENT(in) :: tc(*), p_atm(*)
        END FUNCTION RMF_Concentrations2Utility  
       
        INTEGER(KIND=C_INT) FUNCTION RMF_Create(nxyz, nthreads) &
			BIND(C, NAME='RMF_Create') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: nxyz
			INTEGER(KIND=C_INT), INTENT(in) :: nthreads
        END FUNCTION RMF_Create

		INTEGER(KIND=C_INT) FUNCTION RMF_CreateMapping(id, grid2chem) &
			BIND(C, NAME='RMF_CreateMapping')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: grid2chem(*)
        END FUNCTION RMF_CreateMapping

		INTEGER(KIND=C_INT) FUNCTION RMF_DecodeError(id, e) &
			BIND(C, NAME='RMF_DecodeError')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: e
        END FUNCTION RMF_DecodeError
        
        INTEGER(KIND=C_INT) FUNCTION RMF_Destroy(id) &
			BIND(C, NAME='RMF_Destroy')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_Destroy
        
        INTEGER(KIND=C_INT) FUNCTION RMF_DumpModule(id, dump_on, append) &
			BIND(C, NAME='RMF_DumpModule')
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: dump_on
            INTEGER(KIND=C_INT), INTENT(in) :: append
        END FUNCTION RMF_DumpModule
        
        INTEGER(KIND=C_INT) FUNCTION RMF_ErrorMessage(id, errstr) &
			BIND(C, NAME='RMF_ErrorMessage')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: errstr(*)
        END FUNCTION RMF_ErrorMessage
        
        INTEGER(KIND=C_INT) FUNCTION RMF_FindComponents(id) &
			BIND(C, NAME='RMF_FindComponents') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_FindComponents  

        INTEGER(KIND=C_INT) FUNCTION RMF_GetChemistryCellCount(id) &
			BIND(C, NAME='RMF_GetChemistryCellCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetChemistryCellCount 
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetComponent(id, num, comp_name, l) &
			BIND(C, NAME='RMF_GetComponent')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id, num, l
            CHARACTER(KIND=C_CHAR), INTENT(out) :: comp_name(*)
        END FUNCTION RMF_GetComponent 
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetComponentCount(id) &
			BIND(C, NAME='RMF_GetComponentCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetComponentCount 

        INTEGER(KIND=C_INT) FUNCTION RMF_GetConcentrations(id, c) &
			BIND(C, NAME='RMF_GetConcentrations')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out)  :: c(*)
        END FUNCTION RMF_GetConcentrations 

        INTEGER(KIND=C_INT) FUNCTION RMF_GetDensity(id, density) &
			BIND(C, NAME='RMF_GetDensity')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: density(*)
        END FUNCTION RMF_GetDensity 

        INTEGER(KIND=C_INT) FUNCTION RMF_GetErrorString(id, errstr, l) &
			BIND(C, NAME='RMF_GetErrorString')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
			INTEGER(KIND=C_INT), INTENT(in) :: l
            CHARACTER(KIND=C_CHAR), INTENT(out) :: errstr(*)
        END FUNCTION RMF_GetErrorString 

        INTEGER(KIND=C_INT) FUNCTION RMF_GetErrorStringLength(id) &
			BIND(C, NAME='RMF_GetErrorStringLength')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetErrorStringLength 
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetFilePrefix(id, prefix, l) &
			BIND(C, NAME='RMF_GetFilePrefix')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: l
            CHARACTER(KIND=C_CHAR), INTENT(out) :: prefix(*)
        END FUNCTION RMF_GetFilePrefix

        INTEGER(KIND=C_INT) FUNCTION RMF_GetGfw(id, gfw) &
			BIND(C, NAME='RMF_GetGfw')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: gfw(*)
        END FUNCTION RMF_GetGfw 

        INTEGER(KIND=C_INT) FUNCTION RMF_GetGridCellCount(id) &
			BIND(C, NAME='RMF_GetGridCellCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetGridCellCount
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetIPhreeqcId(id, i) &
			BIND(C, NAME='RMF_GetIPhreeqcId')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: i
        END FUNCTION RMF_GetIPhreeqcId
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetMpiMyself(id) &
			BIND(C, NAME='RMF_GetMpiMyself')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetMpiMyself
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetMpiTasks(id) &
			BIND(C, NAME='RMF_GetMpiTasks')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetMpiTasks
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetNthSelectedOutputUserNumber(id, n) &
			BIND(C, NAME='RMF_GetNthSelectedOutputUserNumber')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id, n
        END FUNCTION RMF_GetNthSelectedOutputUserNumber 
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSaturation(id, sat) &
			BIND(C, NAME='RMF_GetSaturation')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: sat(*)
        END FUNCTION RMF_GetSaturation
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSelectedOutput(id, so) &
			BIND(C, NAME='RMF_GetSelectedOutput')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: so(*)
        END FUNCTION RMF_GetSelectedOutput
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSelectedOutputColumnCount(id) &
			BIND(C, NAME='RMF_GetSelectedOutputColumnCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetSelectedOutputColumnCount
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSelectedOutputCount(id) &
			BIND(C, NAME='RMF_GetSelectedOutputCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetSelectedOutputCount
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSelectedOutputHeading(id, icol, heading, l) &
			BIND(C, NAME='RMF_GetSelectedOutputHeading')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id, icol, l
            CHARACTER(KIND=C_CHAR), INTENT(out) :: heading(*)
        END FUNCTION RMF_GetSelectedOutputHeading
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetSelectedOutputRowCount(id) &
			BIND(C, NAME='RMF_GetSelectedOutputRowCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetSelectedOutputRowCount

        INTEGER(KIND=C_INT) FUNCTION RMF_GetSolutionVolume(id, vol) &
			BIND(C, NAME='RMF_GetSolutionVolume')  
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: vol(*)
        END FUNCTION RMF_GetSolutionVolume 

        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesConcentrations(id, species_conc) &
			BIND(C, NAME='RMF_GetSpeciesConcentrations')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: species_conc(*)
        END FUNCTION RMF_GetSpeciesConcentrations 

        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesCount(id) &
			BIND(C, NAME='RMF_GetSpeciesCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetSpeciesCount

        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesD25(id, diffc) &
			BIND(C, NAME='RMF_GetSpeciesD25')  
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: diffc(*)
        END FUNCTION RMF_GetSpeciesD25 

        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesName(id, i, name, l) &
			BIND(C, NAME='RMF_GetSpeciesName')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id, i, l
            CHARACTER(KIND=C_CHAR), INTENT(out) :: name(*)
        END FUNCTION RMF_GetSpeciesName

        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesSaveOn(id) &
			BIND(C, NAME='RMF_GetSpeciesSaveOn')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetSpeciesSaveOn

        INTEGER(KIND=C_INT) FUNCTION RMF_GetSpeciesZ(id, z) &
			BIND(C, NAME='RMF_GetSpeciesZ')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(out) :: z(*)
        END FUNCTION RMF_GetSpeciesZ 
        
        INTEGER(KIND=C_INT) FUNCTION RMF_GetThreadCount(id) &
			BIND(C, NAME='RMF_GetThreadCount')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetThreadCount
        
        REAL(KIND=C_DOUBLE) FUNCTION RMF_GetTime(id) &
			BIND(C, NAME='RMF_GetTime')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetTime
        
        REAL(KIND=C_DOUBLE) FUNCTION RMF_GetTimeConversion(id) &
			BIND(C, NAME='RMF_GetTimeConversion')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetTimeConversion
        
        REAL(KIND=C_DOUBLE) FUNCTION RMF_GetTimeStep(id) &
			BIND(C, NAME='RMF_GetTimeStep')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_GetTimeStep 

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
        
        INTEGER(KIND=C_INT) FUNCTION RMF_InitialPhreeqc2Module(id, ic1, ic2, f1) &
			BIND(C, NAME='RMF_InitialPhreeqc2Module')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: ic1(*)
            INTEGER(KIND=C_INT), INTENT(in), OPTIONAL :: ic2(*)
            REAL(KIND=C_DOUBLE), INTENT(in), OPTIONAL :: f1(*)
        END FUNCTION RMF_InitialPhreeqc2Module    
		 
        INTEGER(KIND=C_INT) FUNCTION RMF_InitialPhreeqcCell2Module(id, n_user, module_cell, dim_module_cell) &
			BIND(C, NAME='RMF_InitialPhreeqcCell2Module')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: n_user
            INTEGER(KIND=C_INT), INTENT(in) :: module_cell(*)
            INTEGER(KIND=C_INT), INTENT(in) :: dim_module_cell
        END FUNCTION RMF_InitialPhreeqcCell2Module   

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
        
        INTEGER(KIND=C_INT) FUNCTION RMF_LoadDatabase(id, db) &
			BIND(C, NAME='RMF_LoadDatabase') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: db(*)
        END FUNCTION RMF_LoadDatabase 
        
        INTEGER(KIND=C_INT) FUNCTION RMF_LogMessage(id, str) &
			BIND(C, NAME='RMF_LogMessage') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: str(*)
        END FUNCTION RMF_LogMessage

        INTEGER(KIND=C_INT) FUNCTION RMF_MpiWorker(id) &
			BIND(C, NAME='RMF_MpiWorker') 
			USE ISO_C_BINDING
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_MpiWorker

        INTEGER(KIND=C_INT) FUNCTION RMF_MpiWorkerBreak(id) &
			BIND(C, NAME='RMF_MpiWorkerBreak') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_MpiWorkerBreak
        
        INTEGER(KIND=C_INT) FUNCTION RMF_OpenFiles(id) &
			BIND(C, NAME='RMF_OpenFiles') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_OpenFiles
        
        INTEGER(KIND=C_INT) FUNCTION RMF_OutputMessage(id, str) &
			BIND(C, NAME='RMF_OutputMessage')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: str(*)
        END FUNCTION RMF_OutputMessage
        
        INTEGER(KIND=C_INT) FUNCTION RMF_RunCells(id) &
			BIND(C, NAME='RMF_RunCells')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
        END FUNCTION RMF_RunCells  
        
        INTEGER(KIND=C_INT) FUNCTION RMF_RunFile(id, workers, initial_phreeqc, utility, chem_name) &
			BIND(C, NAME='RMF_RunFile')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: workers, initial_phreeqc, utility
            CHARACTER(KIND=C_CHAR), INTENT(in) :: chem_name(*)
        END FUNCTION RMF_RunFile   
        
        INTEGER(KIND=C_INT) FUNCTION RMF_RunString(id, initial_phreeqc, workers, utility, input_string) &
			BIND(C, NAME='RMF_RunString')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: initial_phreeqc, workers, utility
            CHARACTER(KIND=C_CHAR), INTENT(in) :: input_string(*)
        END FUNCTION RMF_RunString   
        
        INTEGER(KIND=C_INT) FUNCTION RMF_ScreenMessage(id, str) &
			BIND(C, NAME='RMF_ScreenMessage') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: str(*)
        END FUNCTION RMF_ScreenMessage   
 		     
        !INTEGER(KIND=C_INT) FUNCTION RMF_SetCellVolume(id, vol)   
        !    IMPLICIT NONE
        !    INTEGER(KIND=C_INT), INTENT(in) :: id
        !    REAL(KIND=C_DOUBLE), INTENT(in) :: vol(*)
        !END FUNCTION RMF_SetCellVolume
 		     
        INTEGER(KIND=C_INT) FUNCTION RMF_SetComponentH2O(id, tf) &
			BIND(C, NAME='RMF_SetComponentH2O')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: tf
        END FUNCTION RMF_SetComponentH2O
 		     
        INTEGER(KIND=C_INT) FUNCTION RMF_SetConcentrations(id, c) &
			BIND(C, NAME='RMF_SetConcentrations')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: c(*)
        END FUNCTION RMF_SetConcentrations
 		     
        INTEGER(KIND=C_INT) FUNCTION RMF_SetCurrentSelectedOutputUserNumber(id, n_user) &
			BIND(C, NAME='RMF_SetCurrentSelectedOutputUserNumber') 
			USE ISO_C_BINDING  
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: n_user
        END FUNCTION RMF_SetCurrentSelectedOutputUserNumber

        INTEGER(KIND=C_INT) FUNCTION RMF_SetDensity(id, density) &
			BIND(C, NAME='RMF_SetDensity')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: density(*)
        END FUNCTION RMF_SetDensity 
        
        INTEGER(KIND=C_INT) FUNCTION RMF_SetDumpFileName(id, name) &
			BIND(C, NAME='RMF_SetDumpFileName') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: name(*)
        END FUNCTION RMF_SetDumpFileName   

        INTEGER(KIND=C_INT) FUNCTION RMF_SetErrorHandlerMode(id, i) &
			BIND(C, NAME='RMF_SetErrorHandlerMode')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: i
        END FUNCTION RMF_SetErrorHandlerMode        
		        
        INTEGER(KIND=C_INT) FUNCTION RMF_SetFilePrefix(id, prefix) &
			BIND(C, NAME='RMF_SetFilePrefix') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: prefix(*)
        END FUNCTION RMF_SetFilePrefix  

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
				
        INTEGER(KIND=C_INT) FUNCTION RMF_SetPartitionUZSolids(id, tf) &
			BIND(C, NAME='RMF_SetPartitionUZSolids')  
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in)  :: tf
        END FUNCTION RMF_SetPartitionUZSolids 

        !INTEGER(KIND=C_INT) FUNCTION RMF_SetPoreVolume(id, pv)  
        !    IMPLICIT NONE
        !    INTEGER(KIND=C_INT), INTENT(in) :: id
        !    REAL(KIND=C_DOUBLE), INTENT(in) :: pv(*)
        !END FUNCTION RMF_SetPoreVolume 

        INTEGER(KIND=C_INT) FUNCTION RMF_SetPorosity(id, por) &
			BIND(C, NAME='RMF_SetPorosity')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: por(*)
        END FUNCTION RMF_SetPorosity 

        INTEGER(KIND=C_INT) FUNCTION RMF_SetPressure(id, p) &
			BIND(C, NAME='RMF_SetPressure')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: p(*)
        END FUNCTION RMF_SetPressure        
        
        INTEGER(KIND=C_INT) FUNCTION RMF_SetPrintChemistryOn(id, worker, initial_phreeqc, utility) &
			BIND(C, NAME='RMF_SetPrintChemistryOn')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: worker, initial_phreeqc, utility
        END FUNCTION RMF_SetPrintChemistryOn 

        INTEGER(KIND=C_INT) FUNCTION RMF_SetPrintChemistryMask(id, cell_mask) &
			BIND(C, NAME='RMF_SetPrintChemistryMask') 
			USE ISO_C_BINDING  
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: cell_mask(*)
        END FUNCTION RMF_SetPrintChemistryMask 
        
        INTEGER(KIND=C_INT) FUNCTION RMF_SetRebalanceByCell(id, method) &
			BIND(C, NAME='RMF_SetRebalanceByCell')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in)  :: method
        END FUNCTION RMF_SetRebalanceByCell
        
        INTEGER(KIND=C_INT) FUNCTION RMF_SetRebalanceFraction(id, f) &
			BIND(C, NAME='RMF_SetRebalanceFraction')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in)  :: f
        END FUNCTION RMF_SetRebalanceFraction
		
        INTEGER(KIND=C_INT) FUNCTION RMF_SetRepresentativeVolume(id, rv) &
			BIND(C, NAME='RMF_SetRepresentativeVolume') 
			USE ISO_C_BINDING  
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: rv(*)
        END FUNCTION RMF_SetRepresentativeVolume 

        INTEGER(KIND=C_INT) FUNCTION RMF_SetSaturation(id, sat) &
			BIND(C, NAME='RMF_SetSaturation')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: sat(*)
        END FUNCTION RMF_SetSaturation 

        INTEGER(KIND=C_INT) FUNCTION RMF_SetSelectedOutputOn(id, tf) &
			BIND(C, NAME='RMF_SetSelectedOutputOn')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: tf
        END FUNCTION RMF_SetSelectedOutputOn   

        INTEGER(KIND=C_INT) FUNCTION RMF_SetSpeciesSaveOn(id, save_on) &
			BIND(C, NAME='RMF_SetSpeciesSaveOn')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: save_on
        END FUNCTION RMF_SetSpeciesSaveOn

        INTEGER(KIND=C_INT) FUNCTION RMF_SetTemperature(id, t) &
			BIND(C, NAME='RMF_SetTemperature')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: t(*)
        END FUNCTION RMF_SetTemperature 
		     
        INTEGER(KIND=C_INT) FUNCTION RMF_SetTime(id, time) &
			BIND(C, NAME='RMF_SetTime')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: time
        END FUNCTION RMF_SetTime 
		     
        INTEGER(KIND=C_INT) FUNCTION RMF_SetTimeConversion(id, conv_factor) &
			BIND(C, NAME='RMF_SetTimeConversion') 
			USE ISO_C_BINDING  
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: conv_factor
        END FUNCTION RMF_SetTimeConversion 
		     
        INTEGER(KIND=C_INT) FUNCTION RMF_SetTimeStep(id, time_step) &
			BIND(C, NAME='RMF_SetTimeStep')  
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: time_step
        END FUNCTION RMF_SetTimeStep 

        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsExchange(id, option) &
			BIND(C, NAME='RMF_SetUnitsExchange')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsExchange 

        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsGasPhase(id, option) &
			BIND(C, NAME='RMF_SetUnitsGasPhase')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsGasPhase 

        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsKinetics(id, option) &
			BIND(C, NAME='RMF_SetUnitsKinetics')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsKinetics 

        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsPPassemblage(id, option) &
			BIND(C, NAME='RMF_SetUnitsPPassemblage')  
			USE ISO_C_BINDING 
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsPPassemblage

        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsSolution(id, option) &
			BIND(C, NAME='RMF_SetUnitsSolution')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsSolution  

        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsSSassemblage(id, option) &
			BIND(C, NAME='RMF_SetUnitsSSassemblage')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsSSassemblage  

        INTEGER(KIND=C_INT) FUNCTION RMF_SetUnitsSurface(id, option) &
			BIND(C, NAME='RMF_SetUnitsSurface')   
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: option
        END FUNCTION RMF_SetUnitsSurface  

        INTEGER(KIND=C_INT) FUNCTION RMF_SpeciesConcentrations2Module(id, species_conc) &
			BIND(C, NAME='RMF_SpeciesConcentrations2Module')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            REAL(KIND=C_DOUBLE), INTENT(in) :: species_conc(*)
        END FUNCTION RMF_SpeciesConcentrations2Module  

        INTEGER(KIND=C_INT) FUNCTION RMF_UseSolutionDensityVolume(id, tf) &
			BIND(C, NAME='RMF_UseSolutionDensityVolume')
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            INTEGER(KIND=C_INT), INTENT(in) :: tf
        END FUNCTION RMF_UseSolutionDensityVolume 
        
        INTEGER(KIND=C_INT) FUNCTION RMF_WarningMessage(id, str) &
			BIND(C, NAME='RMF_WarningMessage') 
			USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: id
            CHARACTER(KIND=C_CHAR), INTENT(in) :: str(*)
        END FUNCTION RMF_WarningMessage
		 
    END INTERFACE