SUBROUTINE openf
  ! ... Opens input and output data files
  USE f_units
  USE mcch
  USE mcc
!#if defined(USE_MPI)
!  USE mpi_mod
!#endif
  IMPLICIT NONE
  CHARACTER(LEN=255) :: fname
  INTEGER :: ios, length
  LOGICAL :: lerror 
  INTEGER :: i, a_err
  CHARACTER(LEN=255) :: restart_name
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: openf.F90 7044 2012-10-29 22:55:01Z dlpark $'
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
  READ(fuinc,'(I10)') num_restart_files
  ALLOCATE(restart_files(num_restart_files), & 
       STAT = a_err)
  IF (a_err /= 0) THEN
     PRINT *, "Array allocation failed: openf, restart_files"  
     STOP
  ENDIF
  DO i = 1, num_restart_files
     READ(fuinc,'(A)') restart_files(i)
  ENDDO

  ! root opens all other files 
  if (mpi_myself == 0) then 
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
      CALL myopen(fulp, fname, lerror)

      !$$  REWIND fulp
      IF(print_rde) THEN
         fname=f3name(1:length)//'.rde.txt'
         CALL myopen(furde, fname, lerror)
      ENDIF

      fname=f3name(1:length)//'.head.txt'
      CALL myopen(fup, fname, lerror)

      fname=f3name(1:length)//'.wt.txt'
      CALL myopen(fuwt, fname, lerror)

      fname=f3name(1:length)//'.comps.txt'
      CALL myopen(fuc, fname, lerror)

      fname=f3name(1:length)//'.vel.txt'
      CALL myopen(fuvel, fname, lerror)

      fname=f3name(1:length)//'.wel.txt'
      CALL myopen(fuwel, fname, lerror)

      fname=f3name(1:length)//'.bal.txt'
      CALL myopen(fubal, fname, lerror)

      fname=f3name(1:length)//'.kd.txt'
      CALL myopen(fukd, fname, lerror)

      fname=f3name(1:length)//'.bcf.txt'
      CALL myopen(fubcf, fname, lerror)

      fname=f3name(1:length)//'.zf.txt'
      CALL myopen(fuzf, fname, lerror)

      fname=f3name(1:length)//'.zf.tsv'
      CALL myopen(fuzf_tsv, fname, lerror)

      fname=f3name(1:length)//'.comps.xyz.tsv'
      CALL myopen(fupmap, fname, lerror)

      fname=f3name(1:length)//'.head.xyz.tsv'
      CALL myopen(fupmp2, fname, lerror)

      fname=f3name(1:length)//'.wt.xyz.tsv'
      CALL myopen(fupmp3, fname, lerror)

      fname=f3name(1:length)//'.vel.xyz.tsv'
      CALL myopen(fuvmap, fname, lerror)

      fname=f3name(1:length)//'.wel.xyz.tsv'
      CALL myopen(fuplt, fname, lerror)
  endif
  IF (lerror) THEN
     STOP 'Stopping because of error(s) opening files.'
  ENDIF
END SUBROUTINE openf

SUBROUTINE myopen(funit, fname, lerror)
  CHARACTER(LEN=255), INTENT(IN) :: fname
  INTEGER, INTENT(IN) :: funit
  LOGICAL, INTENT(OUT) :: lerror
  INTEGER :: count

  ! ---------------------------------------------------------------------------
  count = 0
  ios = 1
  DO WHILE (ios > 0) 
     OPEN(funit,FILE=fname,IOSTAT=ios,ACTION='WRITE')
     count = count + 1
     IF (count > 20) EXIT
  END DO
  lerror = .FALSE.
  IF (ios > 0) THEN
     lerror = .TRUE.
     WRITE(*,*) 'ERROR: Opening funit ', funit, ' file ', fname
  ENDIF

END SUBROUTINE myopen
