SUBROUTINE read1  
  ! ... Reads fundamental information, dimensioning data
  USE f_units
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcch
  USE mcch_m
  USE mcg
  USE mcg_m
  USE mcs
  USE mcw
  USE mcw_m
  IMPLICIT NONE
  INTERFACE
     FUNCTION uppercase(string) RESULT(outstring)
       IMPLICIT NONE
       CHARACTER(LEN=*), INTENT(IN) :: string
       CHARACTER(LEN=LEN(string)) :: outstring
     END FUNCTION uppercase
  END INTERFACE
  CHARACTER(LEN=255) :: limage  
  CHARACTER(LEN=1) :: uchar
  INTEGER :: ios
  INTEGER, DIMENSION(21) :: array_bcst_i
  REAL(KIND=kdp), DIMENSION(1) :: array_bcst_r
  ! ------------------------------------------------------------------------
  !...
  ! ... Pre-read of data file to strip out comments
  DO
     READ(fuinc,'(a255)',IOSTAT=ios) limage
     IF(ios < 0) EXIT
     uchar = uppercase(limage(1:1))
     IF(uchar /= 'C') WRITE(fuins,'(a)') TRIM(limage)
  END DO
  CLOSE(fuinc)
  REWIND fuins
  ! ... Start of data readin
  READ(fuins, 1002) title(1:80), title(81:160)  
1002 FORMAT(A80/A80)  
  IF (print_rde) WRITE(FURDE, 1002) title(1:80), title(81:160)  
  READ(fuins,*) restrt, timrst  
  IF (print_rde) WRITE(FURDE, 8001) 'RESTRT,TIMRST,[1.3]', restrt, timrst  
8001 FORMAT(TR5,A/TR5,L5,1PG12.1)
  IF(.NOT.restrt) THEN
     READ(FUINS,*) heat, solute, eeunit, cylind, scalmf  
     IF (print_rde) WRITE(FURDE, 8002) 'HEAT,SOLUTE,EEUNIT,CYLIND,SCALMF,[1.4]', &
          heat, solute, eeunit, cylind, scalmf
8002 FORMAT(TR5,A/TR5,5L5)  
     READ(fuins,*) steady_flow, eps_p, eps_flow
     IF (print_rde) WRITE(furde,8013) 'steady_flow, eps_p, eps_flow', &
          steady_flow, eps_p, eps_flow
8013 FORMAT(tr5,a/tr5,l5,2(1pe15.6))
     READ(FUINS,*) naxes  
     IF (print_rde) WRITE(FURDE, 8003) 'NAXES', naxes
     READ(FUINS,*) tmunit
     IF (print_rde) WRITE(FURDE, 8003) 'TMUNIT,[1.5]', tmunit
     READ(FUINS,*) nx, ny, nz, nhcn, npmz  
     nxyz = nx * ny * nz
     IF (print_rde) WRITE(FURDE, 8003) 'NX,NY,NZ,NHCN,NPMZ,[1.6]', nx, ny, nz,  &
          nhcn, npmz
8003 FORMAT(TR5,A/TR5,4I5,I8)  

     READ(FUINS,*) nsbc, nfbc, nlbc, nrbc, ndbc, naifc, nhcbc, nwel
     IF (print_rde) WRITE(FURDE, 8103) 'NSBC,NFBC,NLBC,NRBC,NDBC,NAIFC,NHCBC,NWEL,[1.7]',  &
           nsbc, nfbc, nlbc, nrbc, ndbc, naifc, nhcbc, nwel
8103 FORMAT(TR5,A/TR5,10I5)
     READ(FUINS,*) slmeth, nral  
     IF (print_rde) WRITE(FURDE, 8004) 'SLMETH,nral,[1.8]', slmeth, nral  
8004 FORMAT(TR5,A/TR5,I5,I8)  

     ! ... number of threads, multithreaded version only
!     READ(fuins, *) nthreads  
!     IF (print_rde) WRITE(furde, 8004) 'C.1.9 .. number of threads', nthreads
!#if defined(USE_MPI)
!     nthreads = -1
!#endif

  ENDIF
END SUBROUTINE read1
