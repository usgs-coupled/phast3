    INTERFACE
        
        INTEGER FUNCTION RM_Abort(id, result, str)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: result
            CHARACTER, INTENT(in) :: str
        END FUNCTION RM_Abort

        INTEGER FUNCTION RM_CloseFiles(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_CloseFiles
        
        INTEGER FUNCTION RM_Concentrations2Utility(id, c, n, tc, p_atm)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: c
            INTEGER, INTENT(in) :: n
            DOUBLE PRECISION, INTENT(in) :: tc, p_atm
        END FUNCTION RM_Concentrations2Utility  
        
        INTEGER FUNCTION RM_Create(nxyz, nthreads) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: nxyz
			INTEGER, INTENT(in), OPTIONAL :: nthreads
        END FUNCTION RM_Create

		INTEGER FUNCTION RM_CreateMapping(id, grid2chem)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: grid2chem
        END FUNCTION RM_CreateMapping

		INTEGER FUNCTION RM_DecodeError(id, e)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: e
        END FUNCTION RM_DecodeError
        
        INTEGER FUNCTION RM_Destroy(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_Destroy
        
        INTEGER FUNCTION RM_DumpModule(id, dump_on, append) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: dump_on
            INTEGER, INTENT(in) :: append
        END FUNCTION RM_DumpModule
        
        INTEGER FUNCTION RM_ErrorMessage(id, errstr)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, INTENT(in) :: errstr
        END FUNCTION RM_ErrorMessage
        
        INTEGER FUNCTION RM_FindComponents(id) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_FindComponents  

        INTEGER FUNCTION RM_GetChemistryCellCount(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetChemistryCellCount 
        
        INTEGER FUNCTION RM_GetComponent(id, num, comp_name)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id, num
            CHARACTER, INTENT(out) :: comp_name
        END FUNCTION RM_GetComponent 
        
        INTEGER FUNCTION RM_GetComponentCount(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetComponentCount 

        INTEGER FUNCTION RM_GetConcentrations(id, c)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(out)  :: c
        END FUNCTION RM_GetConcentrations 

        INTEGER FUNCTION RM_GetDensity(id, density)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(out) :: density
        END FUNCTION RM_GetDensity 
        
        INTEGER FUNCTION RM_GetFilePrefix(id, prefix)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, INTENT(out) :: prefix
        END FUNCTION RM_GetFilePrefix

        INTEGER FUNCTION RM_GetGfw(id, gfw)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(out) :: gfw
        END FUNCTION RM_GetGfw 

        INTEGER FUNCTION RM_GetGridCellCount(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetGridCellCount
        
        INTEGER FUNCTION RM_GetIPhreeqcId(id, i)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: i
        END FUNCTION RM_GetIPhreeqcId
        
        INTEGER FUNCTION RM_GetMpiMyself(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetMpiMyself
        
        INTEGER FUNCTION RM_GetMpiTasks(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetMpiTasks
        
        INTEGER FUNCTION RM_GetNthSelectedOutputUserNumber(id, n)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id, n
        END FUNCTION RM_GetNthSelectedOutputUserNumber 
        
        INTEGER FUNCTION RM_GetSelectedOutput(id, so)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(out) :: so
        END FUNCTION RM_GetSelectedOutput
        
        INTEGER FUNCTION RM_GetSelectedOutputColumnCount(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetSelectedOutputColumnCount
        
        INTEGER FUNCTION RM_GetSelectedOutputCount(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetSelectedOutputCount
        
        INTEGER FUNCTION RM_GetSelectedOutputHeading(id, icol, heading)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id, icol
            CHARACTER, INTENT(out) :: heading
        END FUNCTION RM_GetSelectedOutputHeading
        
        INTEGER FUNCTION RM_GetSelectedOutputRowCount(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetSelectedOutputRowCount
        
        INTEGER FUNCTION RM_GetThreadCount(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetThreadCount
        
        DOUBLE PRECISION FUNCTION RM_GetTime(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetTime
        
        DOUBLE PRECISION FUNCTION RM_GetTimeConversion(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetTimeConversion
        
        DOUBLE PRECISION FUNCTION RM_GetTimeStep(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetTimeStep 

        INTEGER FUNCTION RM_InitialPhreeqc2Concentrations(id, c, n_boundary, bc_sol1, bc_sol2, f1)   
                IMPLICIT NONE
                INTEGER, INTENT(in) :: id
                DOUBLE PRECISION, INTENT(OUT) :: c
                INTEGER, INTENT(IN) :: n_boundary, bc_sol1
                INTEGER, INTENT(IN), OPTIONAL :: bc_sol2
                DOUBLE PRECISION, INTENT(IN), OPTIONAL :: f1
        END FUNCTION RM_InitialPhreeqc2Concentrations    
        
        INTEGER FUNCTION RM_InitialPhreeqc2Module(id, ic1, ic2, f1)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: ic1
            INTEGER, INTENT(in), OPTIONAL :: ic2
            DOUBLE PRECISION, INTENT(in), OPTIONAL :: f1
        END FUNCTION RM_InitialPhreeqc2Module       
        
        INTEGER FUNCTION RM_LoadDatabase(id, db) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, INTENT(in) :: db
        END FUNCTION RM_LoadDatabase 
        
        INTEGER FUNCTION RM_LogMessage(id, str) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, INTENT(in) :: str
        END FUNCTION RM_LogMessage

        INTEGER FUNCTION RM_MpiWorker(id) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_MpiWorker

        INTEGER FUNCTION RM_MpiWorkerBreak(id) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_MpiWorkerBreak
        
        INTEGER FUNCTION RM_OpenFiles(id) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_OpenFiles
        
        INTEGER FUNCTION RM_OutputMessage(id, str)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, INTENT(in) :: str
        END FUNCTION RM_OutputMessage
        
        INTEGER FUNCTION RM_RunCells(id)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_RunCells  
        
        INTEGER FUNCTION RM_RunFile(id, workers, initial_phreeqc, utility, chem_name)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: workers, initial_phreeqc, utility
            CHARACTER, INTENT(in) :: chem_name
        END FUNCTION RM_RunFile   
        
        INTEGER FUNCTION RM_RunString(id, initial_phreeqc, workers, utility, input_string)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: initial_phreeqc, workers, utility
            CHARACTER, INTENT(in) :: input_string
        END FUNCTION RM_RunString   
        
        INTEGER FUNCTION RM_ScreenMessage(id, str) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, INTENT(in) :: str
        END FUNCTION RM_ScreenMessage   
 		     
        INTEGER FUNCTION RM_SetCellVolume(id, t)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: t
        END FUNCTION RM_SetCellVolume
 		     
        INTEGER FUNCTION RM_SetConcentrations(id, t)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: t
        END FUNCTION RM_SetConcentrations
 		     
        INTEGER FUNCTION RM_SetCurrentSelectedOutputUserNumber(id, i)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: i
        END FUNCTION RM_SetCurrentSelectedOutputUserNumber

        INTEGER FUNCTION RM_SetDensity(id, t)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: t
        END FUNCTION RM_SetDensity 
        
        INTEGER FUNCTION RM_SetDumpFileName(id, name) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, INTENT(in) :: name
        END FUNCTION RM_SetDumpFileName   

        INTEGER FUNCTION RM_SetErrorHandlerMode(id, i)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: i
        END FUNCTION RM_SetErrorHandlerMode        
		
        INTEGER FUNCTION RM_SetMpiWorkerCallback(id, fcn)
			INTEGER, INTENT(IN) :: id
			INTERFACE
			  INTEGER FUNCTION fcn(method_number)
				INTEGER, INTENT(in) :: method_number
			  END FUNCTION 
			END INTERFACE
        END FUNCTION RM_SetMpiWorkerCallback
        
        INTEGER FUNCTION RM_SetFilePrefix(id, prefix) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, INTENT(in) :: prefix
        END FUNCTION RM_SetFilePrefix  
				
        INTEGER FUNCTION RM_SetPartitionUZSolids(id, t)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in)  :: t
        END FUNCTION RM_SetPartitionUZSolids 

        INTEGER FUNCTION RM_SetPoreVolume(id, t)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: t
        END FUNCTION RM_SetPoreVolume 

        INTEGER FUNCTION RM_SetPressure(id, t)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: t
        END FUNCTION RM_SetPressure        
        
        INTEGER FUNCTION RM_SetPrintChemistryOn(id, worker, ip, utility)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: worker, ip, utility
        END FUNCTION RM_SetPrintChemistryOn 

        INTEGER FUNCTION RM_SetPrintChemistryMask(id, t)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: t
        END FUNCTION RM_SetPrintChemistryMask 
        
        INTEGER FUNCTION RM_SetRebalanceByCell(id, method)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in)  :: method
        END FUNCTION RM_SetRebalanceByCell
        
        INTEGER FUNCTION RM_SetRebalanceFraction(id, f)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in)  :: f
        END FUNCTION RM_SetRebalanceFraction

        INTEGER FUNCTION RM_SetSaturation(id, t)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: t
        END FUNCTION RM_SetSaturation 

        INTEGER FUNCTION RM_SetSelectedOutputOn(id, tf)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: tf
        END FUNCTION RM_SetSelectedOutputOn   

        INTEGER FUNCTION RM_SetTemperature(id, t)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: t
        END FUNCTION RM_SetTemperature 
		     
        INTEGER FUNCTION RM_SetTime(id, t)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: t
        END FUNCTION RM_SetTime 
		     
        INTEGER FUNCTION RM_SetTimeConversion(id, t)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: t
        END FUNCTION RM_SetTimeConversion 
		     
        INTEGER FUNCTION RM_SetTimeStep(id, t)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, INTENT(in) :: t
        END FUNCTION RM_SetTimeStep 

        INTEGER FUNCTION RM_SetUnitsExchange(id, u)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: u
        END FUNCTION RM_SetUnitsExchange 

        INTEGER FUNCTION RM_SetUnitsGasPhase(id, u)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: u
        END FUNCTION RM_SetUnitsGasPhase 

        INTEGER FUNCTION RM_SetUnitsKinetics(id, u)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: u
        END FUNCTION RM_SetUnitsKinetics 

        INTEGER FUNCTION RM_SetUnitsPPassemblage(id, u)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: u
        END FUNCTION RM_SetUnitsPPassemblage

        INTEGER FUNCTION RM_SetUnitsSolution(id, u)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: u
        END FUNCTION RM_SetUnitsSolution  

        INTEGER FUNCTION RM_SetUnitsSSassemblage(id, u)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: u
        END FUNCTION RM_SetUnitsSSassemblage  

        INTEGER FUNCTION RM_SetUnitsSurface(id, u)   
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, INTENT(in) :: u
        END FUNCTION RM_SetUnitsSurface  
        
        INTEGER FUNCTION RM_WarningMessage(id, str) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, INTENT(in) :: str
        END FUNCTION RM_WarningMessage
		 
    END INTERFACE