SUBROUTINE read1  
  ! ... Reads fundamental information, dimensioning data
  USE f_units
  USE mcb
  USE mcc
  use mcch
  USE mcg
  USE mcs
  USE mcw
  IMPLICIT NONE
  CHARACTER (LEN=250) :: LIMAGE  
  INTEGER :: ILAST  
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Pre-read of data file to strip out comments
10 READ(FUINC, 1001, END=20) LIMAGE  
   1001 FORMAT(A250)  
  ILAST = 250  
  CALL STONB(LIMAGE, ILAST, -1)  
  IF(LIMAGE(1:1) .NE.'C'.AND.LIMAGE(1:1) .NE.'c') &
       WRITE(FUINS,1101) LIMAGE(1:ILAST)
  1101 FORMAT(A)  
  GOTO 10  
20 CLOSE(FUINC)  
  REWIND FUINS  
  ! ... Start of data readin
  READ(FUINS, 1002) TITLE(1:80), TITLE(81:160)  
  1002 FORMAT(A80/A80)  
  if (print_rde) WRITE(FURDE, 1002) TITLE(1:80), TITLE(81:160)  
  READ(FUINS, * ) RESTRT, TIMRST  
  if (print_rde) WRITE(FURDE, 8001) 'RESTRT,TIMRST,[1.3]', RESTRT, TIMRST  
  8001 FORMAT(TR5,A/TR5,L5,1PG12.1)  
  IF(.NOT.RESTRT) THEN  
     READ(FUINS, * ) HEAT, SOLUTE, EEUNIT, CYLIND, SCALMF  
     if (print_rde) WRITE(FURDE, 8002) 'HEAT,SOLUTE,EEUNIT,CYLIND,SCALMF,[1.4]', &
          HEAT, SOLUTE, EEUNIT, CYLIND, SCALMF
     8002 FORMAT(TR5,A/TR5,5L5)  
     read(fuins,*) steady_flow, eps_p, eps_flow
     if (print_rde) write(furde,8013) 'steady_flow, eps_p, eps_flow', &
               steady_flow, eps_p, eps_flow
     8013 format(tr5,a/tr5,l5,2(1pe15.6))
     READ(FUINS, * ) NAXES  
     if (print_rde) WRITE(FURDE, 8003) 'NAXES', NAXES  
     READ(FUINS, * ) TMUNIT  
     if (print_rde) WRITE(FURDE, 8003) 'TMUNIT,[1.5]', TMUNIT  
     READ(FUINS, * ) NX, NY, NZ, NHCN, NPMZ  
     if (print_rde) WRITE(FURDE, 8003) 'NX,NY,NZ,NHCN,NPMZ,[1.6]', NX, NY, NZ, &
          NHCN, NPMZ
     8003 FORMAT(TR5,A/TR5,4I5,I8)  
     READ(FUINS, * ) NSBC, NFBC, NLBC, NRBC, NAIFC, NHCBC, NWEL  
     if (print_rde) WRITE(FURDE, 8103) 'NSBC,NFBC,NLBC,NRBC,NAIFC,NHCBC,NWEL,[1.7]', &
          &NSBC, NFBC, NLBC, NRBC, NAIFC, NHCBC, NWEL
     8103 FORMAT(TR5,A/TR5,8I5)  
     READ(FUINS, * ) SLMETH, nral  
     if (print_rde) WRITE(FURDE, 8004) 'SLMETH,nral,[1.8]', SLMETH, nral  
     8004 FORMAT(TR5,A/TR5,I5,I8)  
     !      ELSE
     !... ****restart is deactivated at present
     ! ... Read back selected common blocks and the partitioned large arrays
     ! ...      from disc for restart
     !  66  WRITE(*,*) 'Enter i.d. of restart data file'
     !      READ(*,'(A)') NAME
     !      IF(NAME.EQ.'Q'.OR.NAME.EQ.'q') STOP
     !      FNAME='Rst.'//NAME(1:10)
     !      INQUIRE(FILE=FNAME,EXIST=LEX)
     !      IF(LEX) THEN
     !         OPEN(FUIRST,FILE=FNAME,FORM='UNFORMATTED')
     !         REWIND FUIRST
     !      ELSE
     !         WRITE(*,'(2A)') FNAME,' DOES NOT EXIST'
     !         GO TO 66
     !      ENDIF
     !      REWIND FUIRST
     !      TEMP(1:160)=TITLE(1:160)
     !   30 READ(FUIRST,END=991) CAIB,CAIC,CAIG,CAIS,CAIW
     !      READ(FUIRST) CARB,CARC,CARG,CARM,CARP,CARS,CARV,CARW
     !      READ(FUIRST) CSCP
     !      READ(FUIRST) CSIB,CSIC,CSIG,CSIP,CSIS,CSIV,CSIW
     !      READ(FUIRST) CSLB,CSLC,CSLW
     !      READ(FUIRST) CSRB,CSRC,CSRP,CSRS,CSRV,CSRW
     !         TIMRST=CNVTM*TIMRST
     !         IF(ABS(TIME-TIMRST)/TIMRST.GT..001) GO TO 30
     !  TITLEO(1:160)=TITLE(1:160)
     !  TITLE(1:160)=TEMP(1:160)
     !  LTCOMR=LTCOM
  ENDIF
  RETURN  
!  991 IERR(160) = .TRUE.  
!  ERREXI = .TRUE.  
END SUBROUTINE read1
