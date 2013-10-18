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
        
        FUNCTION RM_create(nxyz, nthreads) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: nxyz, nthreads
            INTEGER :: iout
        END FUNCTION RM_create
        
        FUNCTION RM_destroy(id) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: iout
        END FUNCTION RM_destroy
        
        SUBROUTINE RM_distribute_initial_conditions(id, ic1)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: ic1
        END SUBROUTINE RM_distribute_initial_conditions 
        
        SUBROUTINE RM_distribute_initial_conditions_mix(id, ic1, ic2, f1)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: ic1, ic2
            DOUBLE PRECISION :: f1
        END SUBROUTINE RM_distribute_initial_conditions_mix
        
        SUBROUTINE RM_error(id)
            IMPLICIT NONE
            INTEGER :: id
        END SUBROUTINE RM_error
        
        FUNCTION RM_find_components(id) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: iout
        END FUNCTION RM_find_components  
        
        SUBROUTINE RM_get_component(id, num, comp_name)
            IMPLICIT NONE
            INTEGER :: id, num
            CHARACTER, INTENT(out) :: comp_name
        END SUBROUTINE RM_get_component
        
        SUBROUTINE RM_initial_phreeqc_run(id, db_name, chem_name, prefix)
            IMPLICIT NONE
            INTEGER :: id, num
            CHARACTER :: db_name, chem_name, prefix
        END SUBROUTINE RM_initial_phreeqc_run        
        
        SUBROUTINE RM_log_screen_prt(str) 
            IMPLICIT NONE
            CHARACTER :: str
        END SUBROUTINE RM_log_screen_prt
        
        SUBROUTINE RM_open_files(solute, prefix) 
            IMPLICIT NONE
            INTEGER :: solute
            CHARACTER :: prefix
        END SUBROUTINE RM_open_files
        
        SUBROUTINE RM_pass_data(rm_id,        &
            fresur,                      &
            steady_flow,                 &
            volume,                      &
            iprint_chem,                 &
            iprint_xyz,                  &
            rebalance_method_f,          &
            rebalance_fraction_f) 
            IMPLICIT NONE 
            logical, INTENT(INOUT) :: fresur, steady_flow
            INTEGER, INTENT(INOUT) :: rm_id, iprint_chem, iprint_xyz, rebalance_method_f 
            double precision, INTENT(INOUT) :: volume 
            double precision, INTENT(INOUT) :: rebalance_fraction_f
        END SUBROUTINE RM_pass_data        

        SUBROUTINE RM_phreeqc2concentrations(id, c)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: c
        END SUBROUTINE RM_phreeqc2concentrations  
        
        SUBROUTINE RM_run_cells(id, time, time_step, c, stop_msg)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: time, time_step, c
            INTEGER :: stop_msg
        END SUBROUTINE RM_run_cells  

        SUBROUTINE RM_setup_boundary_conditions(id, n_boundary, bc_sol1, bc_sol2, f1, c, dim)   
	            IMPLICIT NONE
	            INTEGER :: id
	            INTEGER :: n_boundary, bc_sol1, bc_sol2, dim
	            DOUBLE PRECISION :: f1, c
        END SUBROUTINE RM_setup_boundary_conditions  

        SUBROUTINE RM_set_input_units(id, sol, pp, ex, surf, gas, ss, kin)   
            IMPLICIT NONE
            INTEGER :: id
            INTEGER, OPTIONAL :: sol, pp, ex, surf, gas, ss, kin
        END SUBROUTINE RM_set_input_units  
        
        SUBROUTINE RM_set_mapping(id, grid2chem)   
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: grid2chem
        END SUBROUTINE RM_set_mapping  
        
        SUBROUTINE RM_set_nodes(id, x_node, y_node, z_node)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: x_node, y_node, z_node
        END SUBROUTINE RM_set_nodes         
        
        SUBROUTINE RM_set_printing(id, print_chem, print_xyz, print_hdf, print_restart)   
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: print_chem, print_xyz, print_hdf, print_restart
        END SUBROUTINE RM_set_printing 

        SUBROUTINE RM_set_pv(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: t
        END SUBROUTINE RM_set_pv 
        
        SUBROUTINE RM_set_pv0(id, t)
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: t
        END SUBROUTINE RM_set_pv0
        
        SUBROUTINE RM_set_saturation(id, t)
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: t
        END SUBROUTINE RM_set_saturation 
		       
        SUBROUTINE RM_set_time_conversion(id, t)   
            IMPLICIT NONE
            INTEGER :: id
            DOUBLE PRECISION :: t
        END SUBROUTINE RM_set_time_conversion         
 
    END INTERFACE