SUBROUTINE time_step_save
  ! ... Copies the transient read3 group data for sources and 
  ! ...      boundary conditions to var_n to set up for the next time step
  USE mcb
  USE mcb_m
  USE mcc
  USE mcg
  USE mcv
  USE mcw
  USE mcw_m
  USE XP_module, ONLY: xp_list
  IMPLICIT NONE
  INTEGER :: i
  ! ... set string for use with rcs ident command
  CHARACTER(LEN=80) :: ident_string='$Id: time_step_save.F90,v 1.3 2011/01/29 00:18:54 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  IF (.NOT. xp_group) RETURN
  IF (nwel > 0) THEN
     qwv_n = qwv
     IF (mpi_myself == 0) THEN
        qflyr_n = qflyr
        qwm_n = qwm
        qsw_n = qsw
     ENDIF
  ENDIF
  IF (nsbc_seg > 0) THEN
     psbc_n = psbc
  ENDIF
  IF (nfbc_seg > 0) THEN
     qfflx_n = qfflx
     IF (mpi_myself == 0) THEN
        qsflx_n = qsflx
        cfbc_n = cfbc
     ENDIF
  ENDIF
  IF (nlbc_seg > 0) THEN
     philbc_n = philbc
     IF (mpi_myself == 0) THEN
        clbc_n = clbc
     ENDIF
  ENDIF
  IF (nrbc_seg > 0) THEN
     phirbc_n = phirbc
     IF (mpi_myself == 0) THEN
        crbc_n = crbc
     ENDIF
  ENDIF
  ! ... The following variables are derived quantities, thus are not
  ! ...     overwritten when reading a read3 data block
!!$!  if (.not. steady_flow .and. mpi_myself > 0) then
!!$!        p_n = p
!!$!  endif
!!$! if (fresur .and. .not. steady_flow) then
!!$!     frac_n = frac
!!$!     mfsbc_n = mfsbc
!!$!  endif
!!$  IF (nsbc > 0) THEN  
!!$     qfsbc_n = qfsbc
!!$  ENDIF
!!$  IF (nfbc > 0) THEN
!!$     qffbc_n = qffbc
!!$  ENDIF
!!$  IF (ndbc > 0) THEN
!!$     qfdbc_n = qfdbc
!!$  ENDIF
  DO i = 1, ns
     IF (component_map(i) == mpi_myself) THEN
        xp_list(local_component_map(i))%cfbc_n = xp_list(local_component_map(i))%cfbc
        xp_list(local_component_map(i))%clbc_n = xp_list(local_component_map(i))%clbc
        xp_list(local_component_map(i))%crbc_n = xp_list(local_component_map(i))%crbc
     ENDIF
  ENDDO
END SUBROUTINE time_step_save
