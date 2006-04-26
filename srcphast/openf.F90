SUBROUTINE openf
  ! ... Opens input and output data files
  USE f_units
  USE mcch
#if defined(USE_MPI)
  USE mpi_mod
#endif
  IMPLICIT NONE
  CHARACTER(LEN=80) :: fname
  INTEGER :: ios, length
  LOGICAL :: lerror 
  integer num_files, i
  character(len=256) :: restart_name
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... 'Phast.tmp' contains chemistry data filename, chemistry data-base
  ! ...      filename, and prefix output filename at its head.
  lerror = .FALSE.
  OPEN(fuinc,FILE='Phast.tmp',IOSTAT=ios,STATUS='old',ACTION='READ')
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file Phast.tmp'
     STOP "Stopping."
  ENDIF
  READ(fuinc,'(A)') f1name
  READ(fuinc,'(A)') f2name
  READ(fuinc,'(A)') f3name
  READ(fuinc,'(I10)') num_files
  DO i = 1, num_files
     READ(fuinc,'(A)') restart_name
     CALL SEND_RESTART_NAME(restart_name)
  ENDDO
  OPEN(fuins,STATUS='scratch')
  REWIND fuins
  f3name = TRIM(f3name)
  length = LEN_TRIM(f3name)
  IF (LEN_TRIM(f3name(1:length)//'.xyz.comps') .GT. LEN(fname)) THEN
    ! assuming .xyz.comps is the longest suffix
    WRITE(*,*) 'Prefix too long:' , f3name(1:length)
    STOP "Stopping."
  ENDIF
  fname=f3name(1:length)//'.O.probdef'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fulp,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
!  REWIND fulp
  IF(print_rde) THEN
     fname=f3name(1:length)//'.O.rde'
#if defined(USE_MPI)
     CALL get_mpi_filename(fname)
#endif
     OPEN(furde,FILE=fname,IOSTAT=ios,ACTION='WRITE')
     IF (ios > 0) THEN
        lerror = .TRUE.
        WRITE(*,*) 'ERROR: Error opening file ', fname
     ENDIF
  ENDIF
  fname=f3name(1:length)//'.O.head'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fup,FILE=fname,IOSTAT=ios, ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.O.comps'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fuc,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.O.vel'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fuvel,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.O.wel'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fuwel,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.O.bal'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fubal,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.O.kd'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fukd,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.O.bcf'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fubcf,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  fname=f3name(1:length)//'.xyz.comps'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fupmap,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.xyz.head'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fupmp2,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.xyz.vel'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fuvmap,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.xyz.wel'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  OPEN(fuplt,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  IF (ios > 0) THEN
    lerror = .TRUE.
    WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
!!$  fname=f3name(1:length)//'.O.bcnfr'
!!$  OPEN(fubnfr,FILE=fname)
!!$  fname=f3name(1:length)//'.O.pzon'
!!$#if defined(USE_MPI)
!!$  CALL get_mpi_filename(fname)
!!$#endif
!!$  OPEN(fupzon,FILE=fname)
  IF (lerror) THEN
    STOP 'Stopping because of error(s) opening files.'
  ENDIF
END SUBROUTINE openf
