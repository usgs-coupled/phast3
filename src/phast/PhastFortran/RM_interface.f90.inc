    INTERFACE
        SUBROUTINE RM_CloseFiles()
            IMPLICIT NONE
        END SUBROUTINE RM_CloseFiles
        
        SUBROUTINE RM_convert_to_molal(id, c, n, dim)
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: c
            INTEGER :: n, dim
        END SUBROUTINE RM_convert_to_molal  
        
        INTEGER FUNCTION RM_Create(nxyz, nthreads) 
            IMPLICIT NONE
            INTEGER :: nxyz, nthreads
        END FUNCTION RM_Create

		INTEGER FUNCTION RM_CreateMapping(id, grid2chem)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, OPTIONAL :: grid2chem
        END FUNCTION RM_CreateMapping
        
        FUNCTION RM_Destroy(id) RESULT(iout)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER :: iout
        END FUNCTION RM_Destroy
        
        INTEGER FUNCTION RM_distribute_initial_conditions(id, ic1)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, OPTIONAL :: ic1
        END FUNCTION RM_distribute_initial_conditions 
        
        INTEGER FUNCTION RM_distribute_initial_conditions_mix(id, ic1, ic2, f1)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            INTEGER, OPTIONAL :: ic1, ic2
            DOUBLE PRECISION, OPTIONAL :: f1
        END FUNCTION RM_distribute_initial_conditions_mix
        
        SUBROUTINE RM_Error(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END SUBROUTINE RM_Error
        
        SUBROUTINE RM_ErrorMessage(errstr)
            IMPLICIT NONE
            CHARACTER(*), INTENT(in) :: errstr
        END SUBROUTINE RM_ErrorMessage
        
        INTEGER FUNCTION RM_FindComponents(id) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_FindComponents  
        
        INTEGER FUNCTION RM_GetComponent(id, num, comp_name)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id, num
            CHARACTER, INTENT(out) :: comp_name
        END FUNCTION RM_GetComponent 
        
        INTEGER FUNCTION RM_GetFilePrefix(id, prefix)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, INTENT(out) :: prefix
        END FUNCTION RM_GetFilePrefix
        
        INTEGER FUNCTION RM_GetMpiMyself(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetMpiMyself
        
        INTEGER FUNCTION RM_GetNthSelectedOutputUserNumber(id, n)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id, n
        END FUNCTION RM_GetNthSelectedOutputUserNumber 
        
        INTEGER FUNCTION RM_GetSelectedOutput(id, d)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            DOUBLE PRECISION, OPTIONAL, INTENT(out) :: d
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
            CHARACTER(*), INTENT(out) :: heading
        END FUNCTION RM_GetSelectedOutputHeading
        
        INTEGER FUNCTION RM_GetSelectedOutputRowCount(id)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
        END FUNCTION RM_GetSelectedOutputRowCount
        
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
        
        INTEGER FUNCTION RM_InitialPhreeqcRun(id, chem_name)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, OPTIONAL, INTENT(in) :: chem_name
        END FUNCTION RM_InitialPhreeqcRun          
        
        INTEGER FUNCTION RM_LoadDatabase(id, db) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, OPTIONAL, INTENT(in) :: db
        END FUNCTION RM_LoadDatabase 
        
        SUBROUTINE RM_LogScreenMessage(str) 
            IMPLICIT NONE
            CHARACTER :: str
        END SUBROUTINE RM_LogScreenMessage

        SUBROUTINE RM_Module2Concentrations(id, c)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: c
        END SUBROUTINE RM_Module2Concentrations  
        
        INTEGER FUNCTION RM_OpenFiles(id, prefix) 
            IMPLICIT NONE
            INTEGER, INTENT(in) :: id
            CHARACTER, OPTIONAL, INTENT(in) :: prefix
        END FUNCTION RM_OpenFiles
        
        SUBROUTINE RM_RunCells(id, time, time_step, c, stop_msg)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: time, time_step, c
            INTEGER :: stop_msg
        END SUBROUTINE RM_RunCells 

        SUBROUTINE RM_SetDensity(id, t)
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: t
        END SUBROUTINE RM_SetDensity  
        
        FUNCTION RM_SetFilePrefix(id, prefix) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: id, iout
            CHARACTER, OPTIONAL :: prefix
        END FUNCTION RM_SetFilePrefix 
		
        SUBROUTINE RM_set_free_surface(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            INTEGER, OPTIONAL :: t
        END SUBROUTINE RM_set_free_surface 

        SUBROUTINE RM_SetInputUnits(id, sol, pp, ex, surf, gas, ss, kin)   
            IMPLICIT NONE
            INTEGER :: id
            INTEGER, OPTIONAL :: sol, pp, ex, surf, gas, ss, kin
        END SUBROUTINE RM_SetInputUnits  
        
        SUBROUTINE RM_set_nodes(id, x_node, y_node, z_node)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: x_node, y_node, z_node
        END SUBROUTINE RM_set_nodes  

        SUBROUTINE RM_SetPressure(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: t
        END SUBROUTINE RM_SetPressure        
        
        SUBROUTINE RM_set_printing(id, print_chem, print_hdf, print_restart)   
            IMPLICIT NONE
            INTEGER :: id
            INTEGER, OPTIONAL :: print_chem, print_hdf, print_restart
        END SUBROUTINE RM_set_printing 

        SUBROUTINE RM_set_print_chem_mask(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            INTEGER, OPTIONAL :: t
        END SUBROUTINE RM_set_print_chem_mask 

        SUBROUTINE RM_SetPv(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: t
        END SUBROUTINE RM_SetPv 
        
        SUBROUTINE RM_SetPv0(id, t)
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: t
        END SUBROUTINE RM_SetPv0
        
        SUBROUTINE RM_SetRebalance(id, method, f)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER, OPTIONAL  :: method
            DOUBLE PRECISION, OPTIONAL  :: f
        END SUBROUTINE RM_SetRebalance

        SUBROUTINE RM_SetSaturation(id, t)
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: t
        END SUBROUTINE RM_SetSaturation 
				
        SUBROUTINE RM_set_steady_flow(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            INTEGER, OPTIONAL :: t
        END SUBROUTINE RM_set_steady_flow   

        SUBROUTINE RM_SetTemperature(id, t)
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: t
        END SUBROUTINE RM_SetTemperature 
		     
        SUBROUTINE RM_SetTimeConversion(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: t
        END SUBROUTINE RM_SetTimeConversion  

        SUBROUTINE RM_setup_boundary_conditions(id, n_boundary, bc_sol1, bc_sol2, f1, c, dim)   
	            IMPLICIT NONE
	            INTEGER :: id
	            INTEGER :: n_boundary, bc_sol1, bc_sol2, dim
	            DOUBLE PRECISION :: f1, c
        END SUBROUTINE RM_setup_boundary_conditions        
 		     
        SUBROUTINE RM_SetVolume(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: t
        END SUBROUTINE RM_SetVolume
		 
    END INTERFACE