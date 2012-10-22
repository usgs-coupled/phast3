#include 'mpi_fix_case.h'
SUBROUTINE read1_distribute
#if defined(USE_MPI)
  USE mcb
  USE mcc
  USE mcg
  USE mcs
  USE mcw
  USE mpi_mod
  USE mpi_struct_arrays
  IMPLICIT NONE
  INTEGER :: int_real_type, jerr
  INTEGER, DIMENSION(21) :: array_bcst_i
  REAL(KIND=kdp), DIMENSION(1:1) :: array_bcst_r
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: read1_xfer.F90,v 1.5 2011/01/29 00:18:54 klkipp Exp klkipp $'
  ! ------------------------------------------------------------------------
  !...
  ! ... send the read1 parameter data
  !*** broadcast nx, ny, nz, npmz, nsbc, nfbc, nlbc, nrbc, ndbc, nwel, slmeth, nral
  ! ... Load the scalar variables
  IF (mpi_myself == 0) THEN
     array_bcst_i(1) = 0
     IF (restrt) array_bcst_i(1) = 1
     array_bcst_i(2) = 0
     IF (solute) array_bcst_i(2) = 1
     array_bcst_i(3) = 0
     IF (cylind) array_bcst_i(3) = 1
     array_bcst_i(4) = 0
     IF (steady_flow) array_bcst_i(4) = 1
     array_bcst_i(19) = naxes(1); array_bcst_i(20) = naxes(2); array_bcst_i(21) = naxes(3);
     array_bcst_i(6) = tmunit
     array_bcst_i(7) = nx; array_bcst_i(8) = ny; array_bcst_i(9) = nz
     array_bcst_i(10) = npmz
     array_bcst_i(11) = nsbc; array_bcst_i(12) = nfbc; array_bcst_i(13) = nlbc
     array_bcst_i(14) = nrbc;  array_bcst_i(15) = ndbc; array_bcst_i(16) = nwel
     array_bcst_i(17) = slmeth; array_bcst_i(18) = nral
  ENDIF
  int_real_type=MPI_struct_array(array_bcst_i,array_bcst_r)
  CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
       world, jerr)
  CALL MPI_TYPE_FREE(int_real_type,jerr)

  IF (mpi_myself > 0) THEN
     ! ... Load the scalar variables
     restrt = .FALSE.
     timrst = 0
     IF (array_bcst_i(1) == 1) THEN
        restrt = .TRUE.
        timrst = array_bcst_r(1)
     ENDIF
     solute = .FALSE.
     IF (array_bcst_i(2) == 1) solute = .TRUE.
     cylind = .FALSE.
     IF (array_bcst_i(3) == 1) cylind = .TRUE.
     steady_flow = .FALSE.
     IF (array_bcst_i(4) == 1) steady_flow = .TRUE.
     naxes(1) = array_bcst_i(19); naxes(2) = array_bcst_i(20); naxes(3) = array_bcst_i(21)
     tmunit = array_bcst_i(6)
     nx = array_bcst_i(7); ny = array_bcst_i(8); nz = array_bcst_i(9)
     npmz = array_bcst_i(10)
     nsbc = array_bcst_i(11); nfbc = array_bcst_i(12); nlbc = array_bcst_i(13)
     nrbc = array_bcst_i(14);  ndbc = array_bcst_i(15); nwel = array_bcst_i(16)
     slmeth = array_bcst_i(17); nral = array_bcst_i(18)
  ENDIF
#endif     
END SUBROUTINE read1_distribute
