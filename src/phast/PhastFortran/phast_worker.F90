#include 'mpi_fix_case.h'
SUBROUTINE phast_worker
#if defined(USE_MPI)
    ! ... The top level routine for a worker process that does the 
    ! ...     solute transport calculation for one component
    USE machine_constants, ONLY: kdp, one_plus_eps
    USE mcb, ONLY: fresur, adj_wr_ratio, transient_fresur, qfsbc, nsbc
    USE mcc
    USE mcg
    USE mcch
    USE mcg
    USE mcn, ONLY: x_node, y_node, z_node, pv0, volume, pv_phreeqc
    USE mcp
    USE mcs
    USE mcv
    USE mcv_m, ONLY: exchange_units, surface_units, ssassemblage_units,  &
        ppassemblage_units, gasphase_units, kinetics_units
    USE mcw
    USE print_control_mod
    USE XP_module, ONLY: Transporter
    USE mpi_mod
    USE mpi_struct_arrays
    IMPLICIT NONE
    INTERFACE
        FUNCTION RM_create(nthreads) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: nthreads
            INTEGER :: iout
        END FUNCTION RM_create
        FUNCTION RM_destroy(id) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: iout
        END FUNCTION RM_destroy
        FUNCTION RM_find_components(id) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: iout
        END FUNCTION RM_find_components
        SUBROUTINE RM_log_screen_prt(str) 
            IMPLICIT NONE
            CHARACTER :: str
        END SUBROUTINE RM_log_screen_prt
        SUBROUTINE worker_get_indexes(indx_sol1_ic, indx_sol2_ic, &
            mxfrac, naxes, nxyz, &
            x_node, y_node, z_node, &
            cnvtmi, transient_fresur, &
            steady_flow, pv0, &
            rebalance_method_f, volume, tort, npmz, &
            exchange_units, surface_units, ssassemblage_units, &
            ppassemblage_units, gasphase_units, kinetics_units)
            USE machine_constants, ONLY: kdp
        IMPLICIT NONE
            INTEGER :: indx_sol1_ic 
            INTEGER :: indx_sol2_ic 
            REAL(KIND=kdp) :: mxfrac
            INTEGER :: naxes 
            INTEGER :: nxyz    
            REAL(KIND=kdp) x_node 
            REAL(KIND=kdp) y_node
            REAL(KIND=kdp) z_node 
            REAL(KIND=kdp) cnvtmi 
            INTEGER :: transient_fresur 
            LOGICAL :: steady_flow 
            REAL(KIND=kdp) :: pv0 
            INTEGER :: rebalance_method_f          
            REAL(KIND=kdp) :: volume 
            REAL(KIND=kdp) :: tort
            INTEGER :: npmz 
            INTEGER :: exchange_units 
            INTEGER :: surface_units 
            INTEGER :: ssassemblage_units 
            INTEGER :: ppassemblage_units 
            INTEGER :: gasphase_units
            INTEGER :: kinetics_units
        END SUBROUTINE worker_get_indexes
    END INTERFACE
    REAL(KIND=kdp) :: deltim_dummy
    INTEGER :: stop_msg=0, print_restart_flag
    INTEGER :: i, a_err
    CHARACTER(LEN=130) :: logline1
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: phast_worker.F90,v 1.5 2011/01/29 00:18:54 klkipp Exp klkipp $'
    !     ------------------------------------------------------------------

    !...
    errexi=.FALSE.
    errexe=.FALSE.
    tsfail=.FALSE.

    ! ... Open Fortran files
    CALL openf   

    ! ... Receive memory allocation data, solute
    CALL read1_distribute

    ! ... Make a Reaction_module
    rm_id = RM_create(nthreads)
    IF (rm_id.LT.0) THEN
        WRITE(*,*) "Could not create reaction module, worker ", mpi_myself
        STOP 
    END IF
 
    ! ... Open C files //TODO error checks
    !CALL RM_open_files(solute, f3name)

    IF (solute) THEN

        ! ... initial PHREEQC run to define reactants
        CALL RM_initial_phreeqc_run(rm_id, f2name, f1name, f3name)
        ! Set components
        ns = RM_find_components(rm_id)
        ALLOCATE(comp_name(ns),  & 
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array allocation failed: init1, point 5"  
            STOP
        ENDIF
        DO i = 1, ns
            comp_name(i) = ' '
            CALL RM_get_component(rm_id, i, comp_name(i))
        ENDDO   

        !TODO CALL on_error_cleanup_and_exit

        ! ... Receive init1 data
        CALL worker_init1 

        ! ... Map components to processes for transport calculations
        CALL set_component_map

        IF(errexi) GO TO 50

        ! ... transfer read2 and init2 data to worker
        CALL group2_distribute

        ! ... Create Transporter(s)
        CALL create_transporters

        deltim_dummy = 0._kdp
        time_phreeqc = 0._kdp

        ! ... Initialize chemistry 
        CALL worker_get_indexes(indx_sol1_ic(1,1), indx_sol2_ic(1,1), ic_mxfrac(1,1), naxes(1), nxyz,  &
            x_node(1), y_node(1), z_node(1), cnvtmi, transient_fresur, steady_flow, pv0(1),  &
            rebalance_method_f, volume(1), tort(1), npmz, &
            exchange_units, surface_units, ssassemblage_units,  &
            ppassemblage_units, gasphase_units, kinetics_units)
        CALL RM_pass_data(               &
            rm_id,                       &
            fresur,                      &
            steady_flow,                 &
            nx, ny, nz,                  &
            cnvtmi,                      &
            x_node, y_node, z_node,      &
            pv0,                         &
            volume,                      &
            iprint_chem,                 &
            iprint_xyz,                  &
            rebalance_fraction_f,        &
            c,                           &
            mpi_myself,                  &
            mpi_tasks)

        ! ... Mapping from full 3D domain to chemistry
        CALL RM_forward_and_back(rm_id, indx_sol1_ic, naxes) 
        
        ! ... Distribute initial conditions for chemistry    
        DO i = 1, num_restart_files
            CALL RM_send_restart_name(rm_id, restart_files(i))
        ENDDO
        CALL RM_distribute_initial_conditions( &
            rm_id,                  &
            indx_sol1_ic,           & ! 7 x nxyz end-member 1 
            indx_sol2_ic,           & ! 7 x nxyz end-member 2
            ic_mxfrac,              & ! 7 x nxyz fraction of end-member 1
            exchange_units,	        & ! water (1) or rock (2)
            surface_units,          & ! water (1) or rock (2)
            ssassemblage_units,     & ! water (1) or rock (2)		
            ppassemblage_units,     & ! water (1) or rock (2)
            gasphase_units,         & ! water (1) or rock (2)
            kinetics_units	)	  ! water (1) or rock (2)  
     
        ! ... collect solutions for transport
        CALL RM_solutions2fractions(rm_id)

        ! ... steady flow is calculated here
        IF (steady_flow) THEN
            ! ... steady flow calculation calls read3 and init3
            CALL init3_distribute
        ENDIF

        ! ... Initial equilibration
        adj_wr_ratio = 1
        print_restart_flag = 0 
        CALL RM_run_cells(      &
            rm_id,              &
            prslmi,             &        ! prslm
            prf_chem_phrqi,     &        ! print_chem
            prcphrqi,           &        ! print_xyz
            prhdfci,            &        ! print_hdf
            print_restart_flag, &        ! print_restart
            time_phreeqc,       &        ! time_hst
            deltim_dummy,       &        ! time_step_hst
            c,                  &        ! fraction
            frac,               &        ! frac
            pv,                 &        ! pv 
            nxyz,               &
            ns,                 &
            stop_msg) 

        ! ... Write zone chemistry
        CALL RM_zone_flow_write_chem(print_zone_flows_xyzt%print_flag_integer)
        stop_msg = 0
        deltim_dummy = 0._kdp
 
        ! ... distribute  initial p and c_w to workers from manager
        CALL flow_distribute
        deltim_dummy = 0._kdp

        ! ... Error check
        IF(errexe .OR. errexi) GO TO 50


        ! ... Transient loop for transport
        fdtmth = fdtmth_tr     ! ... set time differencing method to transient
        DO
            ! ... Transport calculation
            CALL c_distribute
            CALL p_distribute

            ! ... manager calculates flow

            ! ... Receive the transient data, if necessary
            IF (xp_group) THEN
                DO WHILE(time*one_plus_eps >= timchg)
                    CALL init3_distribute
                    IF(thru) EXIT        ! ... Normal exit from time step loop
                    IF(errexi) EXIT
                END DO
            ENDIF
            CALL thru_distribute
            IF (thru) EXIT          ! ... second step of exit

            CALL timestep_worker     ! ... this only receives some data. it is a hold point 
            IF (.NOT. steady_flow) CALL flow_distribute

            ! ... Processes do transport
            IF (local_ns > 0) THEN 
                CALL RM_transport(rm_id, local_ns)
                if (mpi_tasks > 1) CALL MPI_Barrier(world, ierrmpi)
                CALL sbc_gather
                CALL c_gather
            ENDIF

            IF(errexe .OR. errexi) GO TO 50

            ! ... Chemistry calculation
            CALL RM_run_cells(      &
                rm_id,              &
                prslmi,             &        ! prslm
                prf_chem_phrqi,     &        ! print_chem
                prcphrqi,           &        ! print_xyz
                prhdfci,            &        ! print_hdf
                print_restart_flag, &        ! print_restart
                time_phreeqc,       &        ! time_hst
                deltim_dummy,       &        ! time_step_hst
                c,                  &        ! fraction
                frac,               &        ! frac
                pv,                 &        ! pv 
                nxyz,               &
                ns,                 &
                stop_msg) 
                            
            CALL RM_zone_flow_write_chem(print_zone_flows_xyzt%print_flag_integer)

            ! ... Save values for next time step
            CALL time_step_save
        ENDDO
        ! ... End of transient loop
     
50      CONTINUE      ! Errors jump to here

        ! ... Cleanup and stop

        IF(errexe .OR. errexi) THEN
            logline1 = 'ERROR exit.'
            CALL logprt_c(logline1)
            CALL screenprt_c(logline1)
        END IF
     
    ENDIF        ! ... solute

    !!$  if (solute) CALL XP_destroy(xp_list(1))
    CALL MPI_BARRIER(MPI_COMM_WORLD, ierrmpi)
    CALL terminate_phast_worker
    !!$ PRINT *, 'Transport Simulation Completed; exit worker process ', mpi_myself

CONTAINS

    SUBROUTINE worker_init1  
        ! ... Initializes dimensions, unit labels, conversion factors
        USE f_units, ONLY: print_rde
        USE mcb
        USE mcn
        IMPLICIT NONE
        INTEGER :: a_err, da_err, iis, nsa
        CHARACTER(LEN=10), DIMENSION(:), ALLOCATABLE :: ucomp_name
        !     ------------------------------------------------------------------
        !...
        ! ... Allocate scratch space for component names
        ! ... Start phreeqec and count number of components
        !      CALL PHREEQC_MAIN(SOLUTE, F1NAME, F2NAME, F3NAME)
        ALLOCATE (ucomp_name(100), &
            STAT = a_err)
        IF (a_err /= 0) THEN  
            PRINT *, "Array allocation failed: worker_init1 1"  
            STOP  
        ENDIF
 
        nsa = MAX(ns,1)
        nxy = nx * ny  
        nxyz = nxy * nz  

        ! print arrays
        ALLOCATE (iprint_chem(nxyz), iprint_xyz(nxyz), &
            STAT = a_err)
        IF (a_err /= 0) THEN  
            PRINT *, "Array allocation failed: worker_init1 2"  
            STOP  
        ENDIF
        ALLOCATE ( &
            indx_sol1_ic(7,nxyz), indx_sol2_ic(7,nxyz), &
            c(nxyz,nsa), &
            ic_mxfrac(7,nxyz), &
            STAT = a_err)
        IF (a_err /= 0) THEN  
            PRINT *, "Array allocation failed: worker_init1 3"  
            STOP  
        ENDIF

        print_rde = .FALSE.

        ! ... additional init1 for worker (formerly init1_xfer)
        nxyzh = (nxyz+MOD(nxyz,2))/2
        mtp1 = nxyz - nxy + 1          ! ... first cell in top plane of global mesh

        ! ... Allocate node information arrays: mcn
        ALLOCATE (rm(nx), x(nx), y(ny), z(nz), x_node(nxyz), y_node(nxyz), z_node(nxyz),  &
            x_face(nx-1), y_face(ny-1), z_face(nz-1),  &
            pv0(nxyz), volume(nxyz), pv_phreeqc(nxyz), tort(npmz), &
            STAT = a_err)
        IF (a_err /= 0) THEN  
            PRINT *, "Array allocation failed: init1_xfer_w, point 2"  
            STOP  
        ENDIF

        ! ... Allocate boundary condition information: mcb and mcb_m
        ALLOCATE(ibc(nxyz),  &
            STAT = a_err)
        IF (a_err /= 0) THEN  
            PRINT *, "Array allocation failed: init1_xfer_w, point 3"  
            STOP  
        ENDIF
        pv0 = 0
        ibc = 0

        ! ... Set up time marching units and conversion factors
        IF (tmunit == 1) THEN 
            cnvtm = 1._kdp  
        ELSEIF (tmunit == 2) THEN   
            cnvtm = 60._kdp  
        ELSEIF (tmunit == 3) THEN   
            cnvtm = 3600._kdp  
        ELSEIF (tmunit == 4) THEN    
            cnvtm = 86400._kdp  
        ELSEIF (tmunit == 6) THEN   
            cnvtm = 3.155815d7  
        ENDIF
        cnvtmi = 1._kdp/cnvtm  
        cnvl = 1._kdp  
        cnvm = 1._kdp  
        cnvp = 1._kdp  
        cnvvs = 1._kdp  
        cnvcn = 1._kdp  
        cnvhe = 1._kdp  
        cnvme = 1._kdp  
        cnvt1 = 1._kdp  
        cnvt2 = 0._kdp  
        cnvthc = 1._kdp  
        cnvhtc = 1._kdp  
        cnvhf = 1._kdp  
        cnvl2 = cnvl*cnvl  
        cnvl3 = cnvl2*cnvl  
        cnvd = cnvm/cnvl3  
        cnvvf = cnvl3/cnvtm  
        cnvff = cnvvf/cnvl2  
        cnvmf = cnvm/(cnvtm*cnvl2)  
        cnvsf = cnvmf  
        cnvdf = cnvl2/cnvtm  
        cnvvl = cnvl/cnvtm  
        cnvcn = cnvcn*cnvvl  
        cnvhc = cnvhe/(cnvm*cnvt1)  
        ! ... Calculate inverse conversion factors
        cnvli = 1._kdp/cnvl
        cnvmi = 1._kdp/cnvm
        cnvpi = 1._kdp/cnvp
        cnvvsi = 1._kdp/cnvvs
        cnvcni = 1._kdp/cnvcn
        cnvhei = 1._kdp/cnvhe
        cnvmei = 1._kdp/cnvme
        cnvt1i = 1._kdp/cnvt1
        cnvhfi = 1._kdp/cnvhf
        cnvl2i = 1._kdp/cnvl2
        cnvl3i = 1._kdp/cnvl3
        cnvdi = 1._kdp/cnvd
        cnvvfi = 1._kdp/cnvvf
        cnvffi = 1._kdp/cnvff
        cnvmfi = 1._kdp/cnvmf
        cnvsfi = 1._kdp/cnvsf
        cnvdfi = 1._kdp/cnvdf
        cnvvli = 1._kdp/cnvvl
        cnvcni = 1._kdp/cnvcn
        cnvhci = 1._kdp/cnvhc
        cnvmfi = cnvmfi*cnvl2i  
        cnvt2i = 0._kdp

        ALLOCATE(caprnt(nxyz),  & 
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array allocation failed: init1_xfer_w, point 5"  
            STOP
        ENDIF

        ! *** many of these arrays are unused by worker ***
        ! ... Allocate dependent variable arrays: mcv
        ALLOCATE (dzfsdt(nxy), dp(0:nxyz), dt(0:0),  &
            sxx(nxyz), syy(nxyz), szz(nxyz), vxx(nxyz), vyy(nxyz), vzz(nxyz),  &
            zfs(nxy),  &
            eh(1), frac(nxyz), frac_icchem(nxyz), p(nxyz), t(1),  &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array allocation failed: init1_xfer_w, point 6"
            STOP
        ENDIF
        dp = 0
        dt = 0
        zfs = -1.e20_kdp
        dt = 0._kdp
        t = 0._kdp

    END SUBROUTINE worker_init1
#endif  ! USE_MPI
END SUBROUTINE phast_worker

SUBROUTINE worker_closef
#if defined(USE_MPI)
  ! ... Closes and deletes files and writes indices of time values
  ! ...      at which dependent variables have been saved
  ! ... Also deallocates the arrays
  USE f_units
  USE mcb
  USE mcc
  USE mcch
  USE mcn
  USE mcp
  USE mcv
  USE mpi_mod
  IMPLICIT NONE
  CHARACTER(LEN=6), DIMENSION(40) :: st
  INTEGER :: a_err, da_err
  !     ------------------------------------------------------------------
  !...

  ! ... Close and delete the stripped input file
  CLOSE(fuins,STATUS='DELETE')  
#ifdef SKIP
  ! ... delete the read echo 'furde' file upon successful completion
  CALL update_status(st)
  ! ... Close the files
  IF(print_rde) CLOSE(furde,status='delete')  
  CLOSE(fuorst, status = st(fuorst))  
  CLOSE(fulp, status = st(fulp))  
  CLOSE(fup, status = st(fup)) 
  CLOSE(fuwt, status = st(fuwt)) 
  CLOSE(fuc, status = st(fuc))  
  CLOSE(fuvel, status = st(fuvel))  
  CLOSE(fuwel, status = st(fuwel))  
  CLOSE(fubal, status = st(fubal))  
  CLOSE(fukd, status = st(fukd))  
  CLOSE(fubcf, status = st(fubcf))  
  CLOSE(fuzf, status = st(fuzf))  
  CLOSE(fuzf_tsv, status = st(fuzf_tsv))
  CLOSE(fuplt, status = st(fuplt))  
  CLOSE(fupmap, status = st(fupmap))  
  CLOSE(fupmp2, status = st(fupmp2))
  CLOSE(fupmp3, status = st(fupmp2))  
  CLOSE(fuvmap, status = st(fuvmap))   
  CLOSE(fuich, status = st(fuich))
  ! ... Close files and free memory in phreeqc
  IF (solute) THEN  
     CALL phreeqc_free(solute)
     DEALLOCATE (iprint_chem, iprint_xyz, &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed worker_closef: 1"  
        STOP  
     ENDIF
     DEALLOCATE (c, ic_mxfrac, &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed worker_closef: 2"  
        STOP  
     ENDIF
  ELSE
    CALL MPI_FINALIZE(ierrmpi)
  ENDIF
#endif  ! SKIP
#endif  ! USE_MPI  
END SUBROUTINE worker_closef
#ifdef SKIP
SUBROUTINE phast_worker
#if defined(USE_MPI)
  ! ... The top level routine for a worker process that does the 
  ! ...     solute transport calculation for one component
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE mcb, ONLY: adj_wr_ratio, transient_fresur, qfsbc, nsbc
  USE mcc
  USE mcg
  USE mcch
  USE mcg
  USE mcn, ONLY: x_node, y_node, z_node, pv0, volume, pv_phreeqc
  USE mcp
  USE mcs
  USE mcv
  USE mcv_m, ONLY: exchange_units, surface_units, ssassemblage_units,  &
       ppassemblage_units, gasphase_units, kinetics_units
  USE mcw
  USE print_control_mod
  USE XP_module, ONLY: Transporter
  USE mpi_mod
  USE mpi_struct_arrays
  IMPLICIT NONE
  REAL(KIND=kdp) :: deltim_dummy
  INTEGER :: stop_msg=0, print_restart_flag
  INTEGER :: i
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: phast_worker.F90,v 1.5 2011/01/29 00:18:54 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  !!$  PRINT *, 'Starting worker process ', mpi_myself
  errexi=.FALSE.
  errexe=.FALSE.
  tsfail=.FALSE.

  CALL openf   
  ! ... Receive memory allocation data, solute
  CALL read1_distribute

  IF (solute) THEN
     CALL phreeqc_main(solute, f1name, f2name, f3name, mpi_tasks, mpi_myself)
     CALL on_error_cleanup_and_exit

     CALL worker_init1 
     ! ... Receive init1 data
     CALL set_component_map

     IF(errexi) GO TO 50

     ! ... transfer read2 and init2 data to worker
     CALL group2_distribute
     !
     ! ... Create Transporter(s)
     !
     CALL create_transporters

     deltim_dummy = 0._kdp
     time_phreeqc = 0._kdp

#if defined(HDF5_CREATE)
     CALL hdf_write_invariant(mpi_myself)
#endif
     !
     ! ... Initialize chemistry 
     !
     CALL worker_get_indexes(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, naxes, nxyz,  &
          x_node, y_node, z_node, cnvtmi, transient_fresur, steady_flow, pv0,  &
          rebalance_method_f, volume, tort, npmz, &
          exchange_units, surface_units, ssassemblage_units,  &
          ppassemblage_units, gasphase_units, kinetics_units)
     CALL forward_and_back(indx_sol1_ic, naxes, nx, ny, nz)  
     CALL distribute_initial_conditions(indx_sol1_ic, indx_sol2_ic, ic_mxfrac,  &
          exchange_units, surface_units, ssassemblage_units,  &
          ppassemblage_units, gasphase_units, kinetics_units,  &
          pv0, volume)

     CALL uz_init(transient_fresur)
     CALL collect_from_nonroot(c, nxyz) 
     !
     ! ... steady flow is calculated here
     !
     IF (steady_flow) THEN
        ! ... steady flow calculation calls read3 and init3
        CALL init3_distribute
     ENDIF
     !
     ! ... Initial equilibration
     !
     adj_wr_ratio = 1
     print_restart_flag = 0 
     CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time_phreeqc,deltim_dummy,prslmi,  &
          cnvtmi,frac_icchem,iprint_chem,iprint_xyz,  &
          prf_chem_phrqi,stop_msg,prhdfci,rebalance_fraction_f,  &
          print_restart_flag, pv_phreeqc, pv0, steady_flow, volume, przf_xyzt)
     CALL zone_flow_write_chem(mpi_tasks, mpi_myself, .true.)
     stop_msg = 0
     deltim_dummy = 0._kdp
     !   
     ! ... distribute  initial p and c_w to workers from manager
     !
     CALL flow_distribute

     deltim_dummy = 0._kdp

     IF(errexe .OR. errexi) GO TO 50

     fdtmth = fdtmth_tr     ! ... set time differencing method to transient
     !
     ! ... Transient loop for transport
     !
     DO
        !
        ! ... Transport calculation
        !
        CALL c_distribute
        CALL p_distribute

        ! ... manager calculates flow

        ! ... Receive the transient data, if necessary
        IF (xp_group) THEN
           DO WHILE(time*one_plus_eps >= timchg)
              CALL init3_distribute
              IF(thru) EXIT        ! ... Normal exit from time step loop
              IF(errexi) EXIT
           END DO
        ENDIF
        CALL thru_distribute

        IF (thru) EXIT          ! ... second step of exit

        CALL timestep_worker     !***** this only receives some data. it is a hold point 

        IF (.NOT. steady_flow) CALL flow_distribute

        IF (local_ns > 0) THEN 
           DO i = 1, local_ns
              CALL coeff_trans
              CALL XP_rhsn(xp_list(i))
              IF(nwel > 0) THEN
                 IF(cylind) THEN
                    CALL XP_wellsc(xp_list(i))
                 ELSE
                    CALL XP_wellsr(xp_list(i))
                 END IF
              END IF
              CALL XP_aplbce(xp_list(i))
              CALL XP_asmslc(xp_list(i))
              CALL XP_sumcal1(xp_list(i))
              IF(errexe .OR. errexi) EXIT
           ENDDO
           if (mpi_tasks > 1) CALL MPI_Barrier(world, ierrmpi)
           CALL sbc_gather
           CALL c_gather
        ENDIF
        IF(errexe .OR. errexi) GO TO 50
        !
        ! ... Chemistry calculation
        !
        CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time,deltim,prslmi,cnvtmi,  &
             frac,iprint_chem,iprint_xyz,prf_chem_phrqi,stop_msg,prhdfci,rebalance_fraction_f,  &
             print_restart%print_flag_integer, pv_phreeqc, pv0, steady_flow, volume, przf_xyzt)
        CALL zone_flow_write_chem(mpi_tasks, mpi_myself, .true.)
        !
        !  Save values for next time step
        !
        CALL time_step_save

     ENDDO
     ! ... End of transient loop

50   CONTINUE
     ! ... Cleanup and stop
!!$     !     logline1 = 'Done with transient simulation of component transport.'
!!$     !     CALL logprt_c(logline1)
!!$     !     CALL screenprt_c(logline1)
     IF(errexe .OR. errexi) THEN
        logline1 = 'ERROR exit.'
        CALL logprt_c(logline1)
        CALL screenprt_c(logline1)
     END IF

  ENDIF        ! ... solute
  !!$  if (solute) CALL XP_destroy(xp_list(1))
  CALL MPI_BARRIER(MPI_COMM_WORLD, ierrmpi)
  CALL terminate_phast_worker
!!$ PRINT *, 'Transport Simulation Completed; exit worker process ', mpi_myself

CONTAINS

  SUBROUTINE worker_init1  
    ! ... Initializes dimensions, unit labels, conversion factors
    USE f_units, ONLY: print_rde
    USE mcb
    USE mcn
    IMPLICIT NONE
    INTEGER :: a_err, da_err, iis, nsa
    CHARACTER(LEN=10), DIMENSION(:), ALLOCATABLE :: ucomp_name
    !     ------------------------------------------------------------------
    !...
    ! ... Allocate scratch space for component names
    ! ... Start phreeqec and count number of components
    !      CALL PHREEQC_MAIN(SOLUTE, F1NAME, F2NAME, F3NAME)
    ALLOCATE (ucomp_name(100), &
         STAT = a_err)
    IF (a_err /= 0) THEN  
       PRINT *, "Array allocation failed: worker_init1 1"  
       STOP  
    ENDIF
    ucomp_name = " "
    IF (solute) CALL count_all_components (ns, ucomp_name)  
    ! ... Allocate component arrays
    nsa = MAX(ns,1)
    ! ... Allocate dependent variable arrays
    nxy = nx * ny  
    nxyz = nxy * nz  

    ALLOCATE (iprint_chem(nxyz), iprint_xyz(nxyz), &
         STAT = a_err)
    IF (a_err /= 0) THEN  
       PRINT *, "Array allocation failed: worker_init1 2"  
       STOP  
    ENDIF
    ALLOCATE (comp_name(nsa), &
         indx_sol1_ic(7,nxyz), indx_sol2_ic(7,nxyz), &
         c(nxyz,nsa), &
         ic_mxfrac(7,nxyz), &
         STAT = a_err)
    IF (a_err /= 0) THEN  
       PRINT *, "Array allocation failed: worker_init1 3"  
       STOP  
    ENDIF
    IF (solute) THEN  
       DO  iis = 1,ns  
          comp_name(iis) = ucomp_name(iis)
       END DO
    ENDIF
!!$! ... Zero the output record counters
!!$!  nrsttp = 0  
!!$!  nmapr = 0  
!!$!  ! ... Zero the output time plane counters
!!$!  ntprbcf = 0
!!$!  ntprcpd = 0
!!$!  ntprgfb = 0
!!$!  ntprzf = 0
!!$!  ntprzf_tsv = 0
!!$!  ntprzf_heads = 0
!!$!  ntprkd = 0
!!$!  ntprmapcomp = 0
!!$!  ntprmaphead = 0
!!$!  ntprmapv = 0
!!$!  ntprhdfv = 0
!!$!  ntprhdfh = 0
!!$!  ntprp = 0
!!$!  ntprc = 0
!!$!  ntprvel = 0
!!$!  ntprwel = 0
!!$!  ntprtem = 0
!!$!  prt_kd = .false.
    print_rde = .FALSE.
    DEALLOCATE (ucomp_name, &
         STAT = da_err)
    IF (da_err /= 0) THEN  
       PRINT *, "Array deallocation failed: worker_init1"  
       STOP  
    ENDIF

    ! ... additional init1 for worker (formerly init1_xfer)

    IF (cylind) ny = 1  
    nxy = nx*ny  
    nxyz = nxy*nz  
    nxyzh = (nxyz+MOD(nxyz,2))/2
    mtp1 = nxyz - nxy + 1          ! ... first cell in top plane of global mesh
    ! ... Allocate node information arrays: mcn
    ALLOCATE (rm(nx), x(nx), y(ny), z(nz), x_node(nxyz), y_node(nxyz), z_node(nxyz),  &
         x_face(nx-1), y_face(ny-1), z_face(nz-1),  &
         pv0(nxyz), volume(nxyz), pv_phreeqc(nxyz), tort(npmz), &
         STAT = a_err)
    IF (a_err /= 0) THEN  
       PRINT *, "Array allocation failed: init1_xfer_w, point 2"  
       STOP  
    ENDIF
    ! ... Allocate boundary condition information: mcb and mcb_m
    ALLOCATE(ibc(nxyz),  &
         STAT = a_err)
    IF (a_err /= 0) THEN  
       PRINT *, "Array allocation failed: init1_xfer_w, point 3"  
       STOP  
    ENDIF
    pv0 = 0
    ibc = 0
    ! ... Set up time marching units and conversion factors
    IF (tmunit == 1) THEN  
!!$     unittm = 's'  
!!$     utulbl = 'seconds'  
       cnvtm = 1._kdp  
    ELSEIF (tmunit == 2) THEN  
!!$     unittm = 'min'  
!!$     utulbl = 'minutes'  
       cnvtm = 60._kdp  
    ELSEIF (tmunit == 3) THEN  
!!$     unittm = 'h'  
!!$     utulbl = 'hours'  
       cnvtm = 3600._kdp  
    ELSEIF (tmunit == 4) THEN  
!!$     unittm = 'd'  
!!$     utulbl = 'days'  
       cnvtm = 86400._kdp  
    ELSEIF (tmunit == 6) THEN  
!!$     unittm = 'yr'  
!!$     utulbl = 'years'  
       cnvtm = 3.155815d7  
    ENDIF
    cnvtmi = 1._kdp/cnvtm  
!!$  unitm = 'kg'  
!!$  unitl = 'm '  
!!$  unitt = 'c'  
!!$  unith = 'j  '  
!!$  unithf = 'w    '  
!!$  unitp = 'pa '  
!!$  unitep = 'j/kg'  
!!$  unitvs = 'pa-s'  
    cnvl = 1._kdp  
    cnvm = 1._kdp  
    cnvp = 1._kdp  
    cnvvs = 1._kdp  
    cnvcn = 1._kdp  
    cnvhe = 1._kdp  
    cnvme = 1._kdp  
    cnvt1 = 1._kdp  
    cnvt2 = 0._kdp  
    cnvthc = 1._kdp  
    cnvhtc = 1._kdp  
    cnvhf = 1._kdp  
    cnvl2 = cnvl*cnvl  
    cnvl3 = cnvl2*cnvl  
    cnvd = cnvm/cnvl3  
    cnvvf = cnvl3/cnvtm  
    cnvff = cnvvf/cnvl2  
    cnvmf = cnvm/(cnvtm*cnvl2)  
    cnvsf = cnvmf  
    cnvdf = cnvl2/cnvtm  
    cnvvl = cnvl/cnvtm  
    cnvcn = cnvcn*cnvvl  
    cnvhc = cnvhe/(cnvm*cnvt1)  
    ! ... Calculate inverse conversion factors
    cnvli = 1._kdp/cnvl
    cnvmi = 1._kdp/cnvm
    cnvpi = 1._kdp/cnvp
    cnvvsi = 1._kdp/cnvvs
    cnvcni = 1._kdp/cnvcn
    cnvhei = 1._kdp/cnvhe
    cnvmei = 1._kdp/cnvme
    cnvt1i = 1._kdp/cnvt1
    cnvhfi = 1._kdp/cnvhf
    cnvl2i = 1._kdp/cnvl2
    cnvl3i = 1._kdp/cnvl3
    cnvdi = 1._kdp/cnvd
    cnvvfi = 1._kdp/cnvvf
    cnvffi = 1._kdp/cnvff
    cnvmfi = 1._kdp/cnvmf
    cnvsfi = 1._kdp/cnvsf
    cnvdfi = 1._kdp/cnvdf
    cnvvli = 1._kdp/cnvvl
    cnvcni = 1._kdp/cnvcn
    cnvhci = 1._kdp/cnvhc
    cnvmfi = cnvmfi*cnvl2i  
    cnvt2i = 0._kdp

    ALLOCATE(caprnt(nxyz),  & 
         STAT = a_err)
    IF (a_err /= 0) THEN
       PRINT *, "Array allocation failed: init1_xfer_w, point 5"  
       STOP
    ENDIF

    ! *** many of these arrays are unused by worker ***
    ! ... Allocate dependent variable arrays: mcv
    ALLOCATE (dzfsdt(nxy), dp(0:nxyz), dt(0:0),  &
         sxx(nxyz), syy(nxyz), szz(nxyz), vxx(nxyz), vyy(nxyz), vzz(nxyz),  &
         zfs(nxy),  &
         eh(1), frac(nxyz), frac_icchem(nxyz), p(nxyz), t(1),  &
         STAT = a_err)
    IF (a_err /= 0) THEN
       PRINT *, "Array allocation failed: init1_xfer_w, point 6"
       STOP
    ENDIF
    dp = 0
    dt = 0
    zfs = -1.e20_kdp
    dt = 0._kdp
    t = 0._kdp
    !*****the following may depend on previous call of phreeqc
    ! *** receive iis index 

  END SUBROUTINE worker_init1
#endif  ! USE_MPI
END SUBROUTINE phast_worker

SUBROUTINE worker_closef
#if defined(USE_MPI)
  ! ... Closes and deletes files and writes indices of time values
  ! ...      at which dependent variables have been saved
  ! ... Also deallocates the arrays
  USE f_units
  USE mcb
  USE mcc
  USE mcch
  USE mcn
  USE mcp
  USE mcv
  USE mpi_mod
  IMPLICIT NONE
  CHARACTER(LEN=6), DIMENSION(40) :: st
  INTEGER :: a_err, da_err
  !     ------------------------------------------------------------------
  !...
  ! ... Close and delete the stripped input file
  CLOSE(fuins,STATUS='DELETE')  
  ! ... delete the read echo 'furde' file upon successful completion
  CALL update_status(st)
  ! ... Close the files
  IF(print_rde) CLOSE(furde,status='delete')  
  CLOSE(fuorst, status = st(fuorst))  
  CLOSE(fulp, status = st(fulp))  
  CLOSE(fup, status = st(fup)) 
  CLOSE(fuwt, status = st(fuwt)) 
  CLOSE(fuc, status = st(fuc))  
  CLOSE(fuvel, status = st(fuvel))  
  CLOSE(fuwel, status = st(fuwel))  
  CLOSE(fubal, status = st(fubal))  
  CLOSE(fukd, status = st(fukd))  
  CLOSE(fubcf, status = st(fubcf))  
  CLOSE(fuzf, status = st(fuzf))  
  CLOSE(fuzf_tsv, status = st(fuzf_tsv))
  CLOSE(fuplt, status = st(fuplt))  
  CLOSE(fupmap, status = st(fupmap))  
  CLOSE(fupmp2, status = st(fupmp2))
  CLOSE(fupmp3, status = st(fupmp2))  
  CLOSE(fuvmap, status = st(fuvmap))  
!!$  close(fupzon, status = st(fupzon))  
!!$  close(fubnfr, status = st(fubcf))  
  CLOSE(fuich, status = st(fuich))
  ! ... Close files and free memory in phreeqc
  IF (solute) THEN  
     CALL phreeqc_free(solute)
     DEALLOCATE (iprint_chem, iprint_xyz, &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed worker_closef: 1"  
        STOP  
     ENDIF
     DEALLOCATE (c, ic_mxfrac, &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed worker_closef: 2"  
        STOP  
     ENDIF
  ELSE
    CALL MPI_FINALIZE(ierrmpi)
  ENDIF
#endif  ! USE_MPI  
END SUBROUTINE worker_closef
#endif