SUBROUTINE terminate_phast_worker
  ! ... Terminates the simulation run for transport invoking normal shut-down procedures
  ! ...      or error processing as necessary
  USE f_units, ONLY: fuich
  USE machine_constants, ONLY: kdp
  USE mcb, ONLY: ibc
  USE mcc, ONLY: iprint_chem, iprint_xyz, oldstyle_head_file, solute, prslmi 
  USE mcc_m, ONLY: prtichead
  USE mcch, ONLY: f3name
  USE mcg, ONLY: nxyz, nxy
  USE mcn, ONLY: x_node, y_node, z_node, z
  USE mcp, ONLY: cnvli, cnvtmi, gz, den0
  USE mcs, ONLY: col_scale, ident_diagc
  USE mcv, ONLY: deltim, frac, time, p
  IMPLICIT NONE
  !
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: terminate_phast_worker.F90,v 1.2 2011/01/29 00:18:54 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
!!$  IF (mpi_myself == 0) THEN   *** this processor is never root
!!$     stop_msg = 1
!!$     CALL equilibrate(c,nxyz,0,x_node,y_node,z_node,time,deltim,prslmi,cnvtmi,  &
!!$       frac, iprint_chem, iprint_xyz, 0, stop_msg, 0, 0)
!!$  ENDIF  
  ! *** special diagnostic message ***
  IF(col_scale) THEN
     IF (ident_diagc) THEN
        logline1 = '***INFORMATION: all transport column scaling was unnecessary.'
        CALL logprt_c(logline1)
        CALL screenprt_c(logline1)
     ELSE
        logline1 = '***INFORMATION: transport column scaling was necessary!'
        CALL logprt_c(logline1)
        CALL screenprt_c(logline1)
     ENDIF
  END IF
  CALL worker_closef !... this may be reactivated for error files
  !****a better routine name for what it does
  IF (solute) CALL dealloc_arr_worker
END SUBROUTINE terminate_phast_worker
