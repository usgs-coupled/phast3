
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
    INCLUDE 'RM_interface_F.f90.inc'
    INTERFACE
        integer function mpi_methods(method)
            integer, intent(in) :: method
        end function
    END INTERFACE
    INTEGER :: stop_msg=0
    INTEGER :: i, a_err
    CHARACTER(LEN=130) :: logline1
    INTEGER hdf_initialized, hdf_invariant
    INTEGER PR_HDF_MEDIA
    INTEGER status
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

    IF (solute) THEN
        ! ... Make a PhreeqcRM
        rm_id = RM_Create(nxyz, MPI_COMM_WORLD)
        IF (rm_id.LT.0) THEN
            WRITE(*,*) "Could not create reaction module, worker ", mpi_myself
            STOP 
        END IF
        time_phreeqc = 0._kdp
        nthreads = RM_GetThreadCount(rm_id)
        status = RM_SetMpiWorkerCallback(rm_id, mpi_methods)
        status = RM_MpiWorker(rm_id)                               ! loop until calculation is done
    ENDIF        ! ... solute

    CALL MPI_BARRIER(MPI_COMM_WORLD, ierrmpi)
    CALL terminate_phast_worker
#endif  
END SUBROUTINE phast_worker
    
SUBROUTINE worker_init1  
        ! ... Initializes dimensions, unit labels, conversion factors
    USE machine_constants, ONLY: kdp, one_plus_eps
    USE mcb, ONLY: char_ibc, fresur, ibc, adj_wr_ratio, qfsbc, nsbc
    USE mcc
    USE mcg
    USE mcch
    USE mcg
    USE mcn
    USE mcp
    USE mcs
    USE mcv
    USE mcv_m, ONLY: exchange_units, surface_units, ssassemblage_units,  &
        ppassemblage_units, gasphase_units, kinetics_units
    USE mcw
    USE print_control_mod        
    USE f_units, ONLY: print_rde
        !USE mcb
        !USE mcn
        IMPLICIT NONE
        INTEGER :: a_err, da_err, iis, nsa
 
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
INTEGER FUNCTION mpi_methods(method)
    USE mpi_mod
    IMPLICIT none
    INTERFACE
        INTEGER FUNCTION set_components
        END FUNCTION set_components
        SUBROUTINE worker_init1
        END SUBROUTINE worker_init1
        SUBROUTINE set_component_map
        END SUBROUTINE set_component_map
        INTEGER FUNCTION set_fdtmth
        END FUNCTION set_fdtmth
    END INTERFACE
    integer method, return_value
    logical debug 
    debug = .false.
    return_value = 0
#if defined(USE_MPI)
    if (method == METHOD_SETCOMPONENTS) then
        if (debug) write(*,*) "METHOD_SETCOMPONENTS"
        return_value = set_components()
    else if (method == METHOD_WORKERINIT1) then
        if (debug) write(*,*) "METHOD_WORKERINIT1"
        CALL worker_init1
    else if (method == METHOD_SETCOMPONENTMAP) then
        if (debug) write(*,*) "METHOD_SETCOMPONENTMAP"
        CALL set_component_map
    else if (method == METHOD_GROUP2DISTRIBUTE) then
        if (debug) write(*,*) "METHOD_GROUP2DISTRIBUTE"
        CALL group2_distribute
    else if (method == METHOD_CREATETRANSPORTERS) then
        if (debug) write(*,*) "METHOD_CREATETRANSPORTERS"
        CALL create_transporters
    else if (method == METHOD_PROCESSRESTARTFILES) then
        if (debug) write(*,*) "METHOD_PROCESSRESTARTFILES"
        CALL process_restart_files
    else if (method == METHOD_INIT3DISTRIBUTE) then
        if (debug) write(*,*) "METHOD_INIT3DISTRIBUTE"
        CALL init3_distribute
    else if (method == METHOD_ZONEFLOWWRITECHEM) then
        if (debug) write(*,*) "METHOD_ZONEFLOWWRITECHEM"
        CALL zone_flow_write_chem
    else if (method == METHOD_FLOWDISTRIBUTE) then
        if (debug) write(*,*) "METHOD_FLOWDISTRIBUTE"
        CALL flow_distribute
    else if (method == METHOD_SETFDTMTH) then
        if (debug) write(*,*) "METHOD_SETFDTMTH"
        return_value = set_fdtmth()
    else if (method == METHOD_CDISTRIBUTE) then
        if (debug) write(*,*) "METHOD_CDISTRIBUTE"
        CALL c_distribute
    else if (method == METHOD_PDISTRIBUTE) then
        if (debug) write(*,*) "METHOD_PDISTRIBUTE"
        CALL p_distribute
    else if (method == METHOD_TIMESTEPWORKER) then
        if (debug) write(*,*) "METHOD_TIMESTEPWORKER"
        CALL timestep_worker
    else if (method == METHOD_RUNTRANSPORT) then
        if (debug) write(*,*) "METHOD_RUNTRANSPORT"
        CALL run_transport
    else if (method == METHOD_SBCGATHER) then
        if (debug) write(*,*) "METHOD_SBCGATHER"
        CALL sbc_gather
    else if (method == METHOD_CGATHER) then
        if (debug) write(*,*) "METHOD_CGATHER"
        CALL c_gather
    else if (method == METHOD_TIMESTEPSAVE) then
        if (debug) write(*,*) "METHOD_TIMESTEPSAVE"
        CALL time_step_save
    endif
#endif
    mpi_methods = return_value
END FUNCTION mpi_methods
