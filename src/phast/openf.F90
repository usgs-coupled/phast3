SUBROUTINE openf
  ! ... Opens input and output data files
  USE f_units
  USE mcch
#if defined(USE_MPI)
  USE mpi_mod
#endif
  IMPLICIT NONE
  CHARACTER(LEN=255) :: fname
  INTEGER :: ios, length
  LOGICAL :: lerror 
  INTEGER :: num_files, i
  CHARACTER(LEN=255) :: restart_name
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
  !$$  OPEN(fuins,FILE='stripped.in')
  REWIND fuins
  f3name = TRIM(f3name)
  length = LEN_TRIM(f3name)
  IF (LEN_TRIM(f3name(1:length)//'.comps.xyz.tsv') .GT. LEN(fname)) THEN
     ! assuming .comps.xyz.tsv is the longest suffix
     WRITE(*,*) 'Prefix too long:' , f3name(1:length)
     STOP "Stopping."
  ENDIF
  fname=f3name(1:length)//'.probdef.txt'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fulp,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fulp, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  !  REWIND fulp
  IF(print_rde) THEN
     fname=f3name(1:length)//'.rde.txt'
#if defined(USE_MPI)
     CALL get_mpi_filename(fname)
#endif
     !OPEN(furde,FILE=fname,IOSTAT=ios,ACTION='WRITE')
     CALL MYOPEN(furde, fname, ios)
     IF (ios > 0) THEN
        lerror = .TRUE.
        WRITE(*,*) 'ERROR: Error opening file ', fname
     ENDIF
  ENDIF
  fname=f3name(1:length)//'.head.txt'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fup,FILE=fname,IOSTAT=ios, ACTION='WRITE')
  CALL MYOPEN(fup, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.wt.txt'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fuwt,FILE=fname,IOSTAT=ios, ACTION='WRITE')
  CALL MYOPEN(fuwt, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.comps.txt'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fuc,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fuc, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.vel.txt'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fuvel,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fuvel, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.wel.txt'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fuwel,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fuwel, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.bal.txt'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fubal,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fubal, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.kd.txt'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fukd,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fukd, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.bcf.txt'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fubcf,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fubcf, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.zf.txt'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fuzf,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fuzf, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.zf.tsv'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fuzf_tsv,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fuzf_tsv, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  fname=f3name(1:length)//'.comps.xyz.tsv'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fupmap,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fupmap, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.head.xyz.tsv'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fupmp2,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fupmp2, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.wt.xyz.tsv'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fupmp3,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fupmp3, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.vel.xyz.tsv'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fuvmap,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fuvmap, fname, ios)
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Error opening file ', fname
  ENDIF
  fname=f3name(1:length)//'.wel.xyz.tsv'
#if defined(USE_MPI)
  CALL get_mpi_filename(fname)
#endif
  !OPEN(fuplt,FILE=fname,IOSTAT=ios,ACTION='WRITE')
  CALL MYOPEN(fuplt, fname, ios)
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
SUBROUTINE MYOPEN(funit, fname, ios)
    CHARACTER(LEN=255), intent(in) :: fname
    INTEGER, intent(in) :: funit
    INTEGER, intent(out) :: ios
    INTEGER :: count
    
    count =0
    ios = 1
    DO WHILE (ios > 0) 
        OPEN(funit,FILE=fname,IOSTAT=ios,ACTION='WRITE')
        count = count + 1
        if (count > 20) exit
    end do
    return
END SUBROUTINE MYOPEN
