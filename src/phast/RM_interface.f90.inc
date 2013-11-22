    INTERFACE
        SUBROUTINE RM_close_files(solute)
            IMPLICIT NONE
            INTEGER, INTENT(in) :: solute
        END SUBROUTINE RM_close_files
        
        SUBROUTINE RM_convert_to_molal(id, c, n, dim)
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: c
            INTEGER :: n, dim
        END SUBROUTINE RM_convert_to_molal  
        
        FUNCTION RM_Create(nxyz, nthreads) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: nxyz, nthreads
            INTEGER :: iout
        END FUNCTION RM_Create
        
        FUNCTION RM_Destroy(id) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: iout
        END FUNCTION RM_Destroy
        
        SUBROUTINE RM_distribute_initial_conditions(id, ic1)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER, OPTIONAL :: ic1
        END SUBROUTINE RM_distribute_initial_conditions 
        
        SUBROUTINE RM_distribute_initial_conditions_mix(id, ic1, ic2, f1)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER, OPTIONAL :: ic1, ic2
            DOUBLE PRECISION, OPTIONAL :: f1
        END SUBROUTINE RM_distribute_initial_conditions_mix
        
        SUBROUTINE RM_Error(id)
            IMPLICIT NONE
            INTEGER :: id
        END SUBROUTINE RM_Error
        
        FUNCTION RM_FindComponents(id) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: iout
        END FUNCTION RM_FindComponents  
        
        SUBROUTINE RM_GetComponent(id, num, comp_name)
            IMPLICIT NONE
            INTEGER :: id, num
            CHARACTER, INTENT(out) :: comp_name
        END SUBROUTINE RM_GetComponent
        
        SUBROUTINE RM_InitialPhreeqcRun(id, db_name, chem_name, prefix)
            IMPLICIT NONE
            INTEGER :: id
            CHARACTER :: db_name, chem_name, prefix
        END SUBROUTINE RM_InitialPhreeqcRun        
        
        SUBROUTINE RM_LogScreenMessage(str) 
            IMPLICIT NONE
            CHARACTER :: str
        END SUBROUTINE RM_LogScreenMessage
        
        SUBROUTINE RM_OpenFiles(solute, prefix) 
            IMPLICIT NONE
            INTEGER :: solute
            CHARACTER :: prefix
        END SUBROUTINE RM_OpenFiles

        SUBROUTINE RM_Module2Concentrations(id, c)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: c
        END SUBROUTINE RM_Module2Concentrations  
        
        SUBROUTINE RM_RunCells(id, time, time_step, c, stop_msg)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: time, time_step, c
            INTEGER :: stop_msg
        END SUBROUTINE RM_RunCells  
        
        FUNCTION RM_SetFilePrefix(id, prefix) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: id, iout
            CHARACTER :: prefix
        END FUNCTION RM_SetFilePrefix

        SUBROUTINE RM_setup_boundary_conditions(id, n_boundary, bc_sol1, bc_sol2, f1, c, dim)   
	            IMPLICIT NONE
	            INTEGER :: id
	            INTEGER :: n_boundary, bc_sol1, bc_sol2, dim
	            DOUBLE PRECISION :: f1, c
        END SUBROUTINE RM_setup_boundary_conditions  

        SUBROUTINE RM_SetDensity(id, t)
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: t
        END SUBROUTINE RM_SetDensity 
		
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
        
        SUBROUTINE RM_CreateMapping(id, grid2chem)   
            IMPLICIT NONE
            INTEGER :: id
            INTEGER, OPTIONAL :: grid2chem
        END SUBROUTINE RM_CreateMapping  
        
        SUBROUTINE RM_set_nodes(id, x_node, y_node, z_node)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: x_node, y_node, z_node
        END SUBROUTINE RM_set_nodes         
        
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

        SUBROUTINE RM_SetPressure(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: t
        END SUBROUTINE RM_SetPressure 

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
 		     
        SUBROUTINE RM_SetVolume(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION, OPTIONAL :: t
        END SUBROUTINE RM_SetVolume
		 
    END INTERFACE