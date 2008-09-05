SUBROUTINE terminate_phast(mpi_myself)
  ! ... Terminates the simulation run invoking normal shut-down procedures
  ! ...      or error processing as necessary
  USE f_units, ONLY: fuich
  USE machine_constants, ONLY: kdp
  USE mcb, ONLY: ibc
  USE mcc, ONLY: iprint_chem, iprint_xyz, prslmi, prtichead, oldstyle_head_file
  USE mcch, ONLY: f3name
  USE mcg, ONLY: nxyz, nxy
  USE mcn, ONLY: x_node, y_node, z_node, z
  USE mcp, ONLY: cnvli, cnvtmi, gz, den0
  USE mcv, ONLY: c, deltim, frac, time, p
  USE mg2, ONLY: hdprnt
#if defined(USE_MPI)
  USE mpi_mod
#endif
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: mpi_myself
  !
  CHARACTER(LEN=160) :: fname
  INTEGER :: length
  INTEGER :: m, stop_msg, imod, k
  INTEGER :: ios
  !
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF (mpi_myself == 0) THEN
     stop_msg = 1
     CALL equilibrate(c,nxyz,0,x_node,y_node,z_node,time,deltim,prslmi,cnvtmi,  &
       frac, iprint_chem, iprint_xyz, 0, stop_msg, 0, 0)
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
5304            FORMAT(10(f10.3))
            ELSE
                ! x, y, z, head
                DO m=1,nxyz
                    IF(ibc(m) /= -1) THEN
                        imod = MOD(m,nxy)
                        k = (m-imod)/nxy + MIN(1,imod)
                        write(fuich,"(4e20.12)") x_node(m), y_node(m), z_node(m), z_node(m)+p(m)/(den0*gz)
                    ENDIF
                END DO
            ENDIF
        ENDIF 
    ENDIF
  ENDIF  
  CALL closef(mpi_myself)
END SUBROUTINE terminate_phast
