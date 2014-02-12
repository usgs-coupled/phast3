SUBROUTINE terminate_phast
  ! ... Terminates the simulation run invoking normal shut-down procedures
  ! ...      or error processing as necessary
  USE f_units, ONLY: fuich
  USE machine_constants, ONLY: kdp
  USE mcb, ONLY: ibc
  USE mcc, ONLY: iprint_chem, iprint_xyz, oldstyle_head_file, prslmi, rm_id
  USE mcc_m, ONLY: prtichead
  USE mcch, ONLY: f3name
  USE mcg, ONLY: nxyz, nxy
  USE mcn, ONLY: x_node, y_node, z_node, z
  USE mcp, ONLY: cnvli, cnvtmi, gz, den0
  USE mcs, ONLY: col_scale, ident_diagc
  USE mcv, ONLY: deltim, frac, time, p
  USE mcv, ONLY: c
  USE mg2_m, ONLY: hdprnt
#if defined(USE_MPI)
  USE mpi_mod
#endif
  IMPLICIT NONE
  INCLUDE "RM_interface_F.f90.inc"
  !
  CHARACTER(LEN=160) :: fname
  CHARACTER(LEN=130) :: logline1
  INTEGER :: status
  INTEGER :: length
  INTEGER :: m, imod, k
  INTEGER :: ios
  !     ------------------------------------------------------------------
  !...
  ! ... Print initial condition head distribution to file
  IF(prtichead) THEN
     ! ... Write to file 'FUICH' for initial condition steady-state head or
     ! ...      final head for future simulations.
     ! ... f3name null terminated in C
     f3name = f3name(1:LEN(f3name) - 1)
     length = LEN_TRIM(f3name)
     fname = f3name(1:length)//'.head.dat'
#if defined(USE_MPI)
     CALL get_mpi_filename(fname)
#endif
     OPEN(fuich,FILE=fname,IOSTAT=ios,ACTION='WRITE')
     IF (ios > 0) THEN
        WRITE(*,*) 'ERROR: Error opening file ', fname, '. File not written.'
     ELSE
        IF (oldstyle_head_file) THEN        
           DO m=1,nxyz
              IF(ibc(m) == -1) THEN
                 hdprnt(m) = 0._kdp
              ELSE
                 imod = MOD(m,nxy)
                 k = (m-imod)/nxy + MIN(1,imod)
                 hdprnt(m)=z(k)+p(m)/(den0*gz)
              ENDIF
           END DO
           WRITE(fuich,5304) (cnvli*hdprnt(m),m=1,nxyz)
5304       FORMAT(10(f10.3))
        ELSE
           ! ... x, y, z, head
           DO m=1,nxyz
              IF(ibc(m) /= -1) THEN
                 WRITE(fuich,"(4e20.12)") x_node(m), y_node(m), z_node(m), z_node(m)+p(m)/(den0*gz)
              ENDIF
           END DO
        ENDIF
     ENDIF
  ENDIF
  ! *** special diagnostic message ***
  IF(col_scale) THEN
     IF (ident_diagc) THEN
        logline1 = '***INFORMATION: all flow column scaling was unnecessary.'
        status = RM_LogMessage(rm_id, logline1)
        status = RM_ScreenMessage(rm_id, logline1)
     ELSE
        logline1 = '***INFORMATION: flow column scaling was necessary!'
        status = RM_LogMessage(rm_id, logline1)
        status = RM_ScreenMessage(rm_id, logline1)
     ENDIF
  END IF
  CALL closef
  CALL dealloc_arr
END SUBROUTINE terminate_phast
