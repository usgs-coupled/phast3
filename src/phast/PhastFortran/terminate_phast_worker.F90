SUBROUTINE terminate_phast_worker
  ! ... Terminates the simulation run for transport invoking normal shut-down procedures
  ! ...      or error processing as necessary
  USE f_units, ONLY: fuich
  USE machine_constants, ONLY: kdp
  USE mcb, ONLY: ibc
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
  CHARACTER(LEN=80) :: ident_string='$Id: terminate_phast_worker.F90,v 1.2 2013/09/26 22:49:48 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  ! *** special diagnostic message ***
#ifdef SKIP_TODO
  IF(col_scale) THEN
     IF (ident_diagc) THEN
        logline1 = '***INFORMATION: all transport column scaling was unnecessary.'
        status = RM_LogMessage(rm_id, logline1)
        status = RM_ScreenMessage(rm_id, logline1)
     ELSE
        logline1 = '***INFORMATION: transport column scaling was necessary!'
        status = RM_LogMessage(rm_id, logline1)
        status = RM_ScreenMessage(rm_id, logline1)
     ENDIF
  END IF
#endif
  CALL worker_closef !... this may be reactivated for error files
  !****a better routine name for what it does
  CALL dealloc_arr_worker
END SUBROUTINE terminate_phast_worker
