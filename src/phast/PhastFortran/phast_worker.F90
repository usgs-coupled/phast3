SUBROUTINE phast_worker
#if defined(USE_MPI)
    ! ... The top level routine for a worker process that does the 
    ! ...     solute transport calculation for one component
    USE machine_constants, ONLY: kdp, one_plus_eps
    USE mcb, ONLY: fresur, adj_wr_ratio, qfsbc, nsbc
    USE mcc
    USE mcg
    USE mcch
    USE mcg
    USE mcn, ONLY: x_node, y_node, z_node, pv0, volume
    USE mcp
    USE mcs
    USE mcv
    USE mcv_m, ONLY: exchange_units, surface_units, ssassemblage_units,  &
        ppassemblage_units, gasphase_units, kinetics_units
    USE mcw
    USE print_control_mod
    USE XP_module, ONLY: Transporter
    USE mpi_mod
    IMPLICIT NONE
    INCLUDE 'RM_interface.f90.inc'
    REAL(KIND=kdp) :: deltim_dummy
    INTEGER :: stop_msg=0
    INTEGER :: i, a_err
    CHARACTER(LEN=130) :: logline1
    ! ... Set string for use with RCS ident command
    INTEGER hdf_initialized, hdf_invariant
    INTEGER PR_HDF_MEDIA
    INTEGER status
    CHARACTER(LEN=80) :: ident_string='$Id: phast_worker.F90,v 1.2 2013/09/26 22:49:48 klkipp Exp klkipp $'
    !     ------------------------------------------------------------------

    !...
    hdf_initialized = 0
    hdf_invariant = 0
    errexi=.FALSE.
    errexe=.FALSE.
    tsfail=.FALSE.

    ! ... Open Fortran files
    CALL openf   

    ! ... Receive memory allocation data, solute
    CALL read1_distribute
!    
! start CreateRM
!
    ! ... Make a PhreeqcRM
    rm_id = RM_Create(nxyz, nthreads)
    IF (rm_id.LT.0) THEN
        WRITE(*,*) "Could not create reaction module, worker ", mpi_myself
        STOP 
    END IF
 
    status = RM_LoadDatabase(rm_id, f2name);
    ! ... Open C files 
    status = RM_SetFilePrefix(rm_id)
    status = RM_OpenFiles(rm_id)
    
    IF (solute) THEN
        ! ... initial PHREEQC run to define reactants 
        status = RM_RunFile(rm_id) 
        ! Set components
        ns = RM_FindComponents(rm_id)
        ALLOCATE(comp_name(ns),  & 
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array allocation failed: init1, point 5"  
            STOP
        ENDIF
        DO i = 1, ns
            comp_name(i) = ' '
            status = RM_GetComponent(rm_id, i, comp_name(i))
        ENDDO  
    ENDIF
!
! end CreateRM
!
    IF (solute) THEN
        
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
        ! ... steady flow is calculated here
        IF (steady_flow) THEN
            ! ... steady flow calculation calls read3 and init3
            CALL init3_distribute
        ENDIF
!
! start of InitializeRM
!
        ! ... Initialize chemistry 

        CALL RM_SetUnits (rm_id)
        CALL RM_SetTimeConversion(rm_id)
        CALL RM_SetPoreVolumeZero(rm_id)
        CALL RM_SetSaturation(rm_id)
        CALL RM_SetPrintChemistryMask(rm_id)
        CALL RM_SetPartitionUZSolids(rm_id)
        CALL RM_SetCellVolume(rm_id)
        CALL RM_SetRebalance(rm_id)

        ! ... Mapping from full 3D domain to chemistry
        status = RM_CreateMapping(rm_id)
        
        ! ... Distribute initial conditions for chemistry    
        DO i = 1, num_restart_files
            CALL FH_SetRestartName(restart_files(i))
        ENDDO
        CALL FH_SetPointers(x_node(1), y_node(1), z_node(1), indx_sol1_ic(1,1))
        status = RM_InitialPhreeqc2Module(rm_id)
        CALL FH_ProcessRestartFiles(rm_id)
        
        ! ... collect solutions for transport
        CALL RM_GetConcentrations(rm_id)
!        
!end  of InitializeRM
!
        adj_wr_ratio = 1
!        
!start  of InitialEquilibrationRM
!
        ! ... Initial equilibration
        CALL RM_SetPoreVolume(rm_id)
        CALL RM_SetSaturation(rm_id)
        status = RM_SetPrintChemistryOn(rm_id)
        status = RM_SetSelectedOutputOn(rm_id, prhdfci .or. prcphrqi)
        CALL RM_RunCells(                                &
            rm_id,                                        &
            time_phreeqc,                                 &        ! time_hst
            deltim_dummy,                                 &        ! time_step_hst
            c(1,1),                                       &        ! fraction
            stop_msg) 
        CALL FH_WriteFiles(rm_id)  
!        
!end  of InitialEquilibrationRM
!     
        ! ... Write zone chemistry
        CALL TM_zone_flow_write_chem(print_zone_flows_xyzt%print_flag_integer)
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
                CALL TM_transport(rm_id, local_ns, nthreads)
                if (mpi_tasks > 1) CALL MPI_Barrier(world, ierrmpi)
                CALL sbc_gather
                CALL c_gather
            ENDIF
            IF(errexe .OR. errexi) GO TO 50
!        
!Start  of TimeStepRM
! 
            ! ... Chemistry calculation
            CALL RM_SetPoreVolume(rm_id)
            CALL RM_SetSaturation(rm_id)
            status = RM_SetPrintChemistryOn(rm_id)
            status = RM_SetSelectedOutputOn(rm_id, prhdfci .or. prcphrqi)
            CALL RM_RunCells(                                &
                rm_id,                                        &
                time_phreeqc,                                 &        ! time_hst
                deltim_dummy,                                 &        ! time_step_hst
                c(1,1),                                       &        ! fraction
                stop_msg) 
            CALL FH_WriteFiles(rm_id)
            status = RM_DumpModule(rm_id)
!        
!Start  of TimeStepRM
!       
            CALL TM_zone_flow_write_chem(print_zone_flows_xyzt%print_flag_integer)

            ! ... Save values for next time step
            CALL time_step_save
        ENDDO
        ! ... End of transient loop
     
50      CONTINUE      ! Errors jump to here

        ! ... Cleanup and stop

        IF(errexe .OR. errexi) THEN
            logline1 = 'ERROR exit.'
            CALL RM_LogMessage(logline1)
            CALL RM_ScreenMessage(logline1)
        END IF
     
    ENDIF        ! ... solute

    CALL MPI_BARRIER(MPI_COMM_WORLD, ierrmpi)
    CALL terminate_phast_worker

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
            x_face(nx-1), y_face(ny-1), z_face(nz-1), pv(nxyz), &
            pv0(nxyz), volume(nxyz), & ! tort(npmz), &
            STAT = a_err)
        IF (a_err /= 0) THEN  
            PRINT *, "Array allocation failed: init1_xfer_w, point 2"  
            STOP  
        ENDIF

        ! ... Allocate boundary condition information: mcb and mcb_m
        ALLOCATE(ibc(nxyz), char_ibc(nxyz), &
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
#endif  
! end USE_MPI
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
#ifdef SKIP_TODO
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
#endif  
! end SKIP_TODO
#endif  
! end USE_MPI  
END SUBROUTINE worker_closef
