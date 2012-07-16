MODULE mpi_struct_arrays
#if defined USE_MPI
  ! ... generic functions for real and integer MPI array structures
  USE machine_constants, ONLY: kdp
  USE mpi_mod
  IMPLICIT NONE
  PRIVATE
  INTERFACE mpi_struct_array
     MODULE PROCEDURE MPI_struct_int_real_array
     MODULE PROCEDURE MPI_struct_real_array_2
     MODULE PROCEDURE MPI_struct_real_array_3
     MODULE PROCEDURE MPI_struct_real_array_4
     MODULE PROCEDURE MPI_struct_real_array_5
     MODULE PROCEDURE MPI_struct_real_array_6
     MODULE PROCEDURE MPI_struct_int_array_2
     MODULE PROCEDURE MPI_struct_int_array_3
     MODULE PROCEDURE MPI_struct_int_array_4
     MODULE PROCEDURE MPI_struct_int_array_5
     MODULE PROCEDURE MPI_struct_int_array_6
     MODULE PROCEDURE MPI_struct_real_2_array_2
     MODULE PROCEDURE MPI_struct_real_2_array_3
     MODULE PROCEDURE MPI_struct_real_2_array_4
     MODULE PROCEDURE MPI_struct_real_2_array_5
     MODULE PROCEDURE MPI_struct_real_2_array_6
     MODULE PROCEDURE MPI_struct_int_2_array_2
     MODULE PROCEDURE MPI_struct_int_2_array_3
  END INTERFACE
  PUBLIC :: mpi_struct_array
  ! ... $Id: mpi_array_mod.F90,v 1.2 2011/01/29 00:18:54 klkipp Exp klkipp $
  ! ...
CONTAINS

  ! ... 1-D REAL-INTEGER ARRAY STRUCTURES

  FUNCTION mpi_struct_int_real_array(indx,values) RESULT(type_int_real)
    ! ... Purpose: Build an MPI structure consisting of an integer array and 
    ! ... a double precision real array.
    ! ... Explicit interface required: assumed-shape arrays INDX and VALUE.
    ! ...
    ! ... argument list
    ! ...
    INTEGER, DIMENSION(:) :: indx
    REAL(kind=kdp), DIMENSION(:) :: values
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_int_real
    ! ...  
    ! ... local variables
    ! ...
    INTEGER, DIMENSION(1:2) :: blks, types !, displs
    INTEGER :: ierr, i_size, v_size !, start_address, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:2) :: displs
    INTEGER :: start_address, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:2) :: displs
    INTEGER (KIND=MPI_ADDRESS_KIND) :: start_address, address
#endif
    CHARACTER(len=64) :: err_loc_message=  &
         'Phast_worker MPI_struct_int_real_array MPI_TYPE_COMMIT 1'
    ! .......................................................................
    type_int_real=0
    i_size=SIZE(indx); v_size=SIZE(values)
    blks=(/i_size, v_size/)
    types=(/MPI_INTEGER, MPI_DOUBLE_PRECISION/)
    displs(1)=0
    CALL MPI_GET_ADDRESS(indx(1), start_address, ierr)
    CALL MPI_GET_ADDRESS(values(1), address, ierr)
    displs(2)=address-start_address
    CALL MPI_TYPE_CREATE_STRUCT(2, blks, displs, types, type_int_real, ierr)
    CALL MPI_TYPE_COMMIT(type_int_real,ierr)
    ! ...
  END FUNCTION mpi_struct_int_real_array

  ! ... 1-D REAL ARRAY STRUCTURES

  FUNCTION MPI_struct_real_array_2(r_array_1, r_array_2) RESULT(type_real_2)
    ! ... Purpose: Build an MPI structure consisting of double precision 
    ! ...          real arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    REAL(kind=kdp), DIMENSION(:) :: r_array_1, r_array_2
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_real_2
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:2) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:2) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:2) :: displs, address
#endif
    ! .......................................................................
    type_real_2=0
    blks=(/SIZE(r_array_1),SIZE(r_array_2)/)
    types=(/MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION/)
    CALL MPI_GET_ADDRESS(r_array_1(1), address(1), ierr)
    CALL MPI_GET_ADDRESS(r_array_2(1), address(2), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(2, blks, displs, types, type_real_2, ierr)
    CALL MPI_TYPE_COMMIT(type_real_2, ierr)
    ! ...
  END FUNCTION MPI_struct_real_array_2

  FUNCTION MPI_struct_real_array_3(r_array_1, r_array_2, r_array_3) RESULT(type_real_3)
    ! ... Purpose: Build an MPI structure consisting of 3 double precision 
    ! ...          real arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    REAL(kind=kdp), DIMENSION(:) :: r_array_1, r_array_2, r_array_3
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_real_3
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:3) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:3) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:3) :: displs, address
#endif
    ! .......................................................................
    type_real_3=0
    blks=(/SIZE(r_array_1),SIZE(r_array_2),SIZE(r_array_3)/)
    types=(/MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION/)
    CALL MPI_GET_ADDRESS(r_array_1(1), address(1), ierr)
    CALL MPI_GET_ADDRESS(r_array_2(1), address(2), ierr)
    CALL MPI_GET_ADDRESS(r_array_3(1), address(3), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(3, blks, displs, types, type_real_3, ierr)
    CALL MPI_TYPE_COMMIT(type_real_3, ierr)
    ! ...
  END FUNCTION MPI_struct_real_array_3

  FUNCTION MPI_struct_real_array_4(r_array_1, r_array_2, r_array_3, r_array_4) &
       RESULT(type_real_4)
    ! ... Purpose: Build an MPI structure consisting of 4 double precision 
    ! ...          real arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    REAL(kind=kdp), DIMENSION(:) :: r_array_1, r_array_2, r_array_3, r_array_4
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_real_4
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:4) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:4) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:4) :: displs, address
#endif
    ! .......................................................................
    type_real_4=0
    blks=(/SIZE(r_array_1),SIZE(r_array_2),SIZE(r_array_3),SIZE(r_array_4)/)
    types=(/MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, &
         MPI_DOUBLE_PRECISION/)
    CALL MPI_GET_ADDRESS(r_array_1(1), address(1), ierr)
    CALL MPI_GET_ADDRESS(r_array_2(1), address(2), ierr)
    CALL MPI_GET_ADDRESS(r_array_3(1), address(3), ierr)
    CALL MPI_GET_ADDRESS(r_array_4(1), address(4), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    displs(4)=address(4)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(4, blks, displs, types, type_real_4, ierr)
    CALL MPI_TYPE_COMMIT(type_real_4, ierr)
    ! ...
  END FUNCTION MPI_struct_real_array_4


  FUNCTION MPI_struct_real_array_5(r_array_1, r_array_2, r_array_3, r_array_4, &
       r_array_5) RESULT(type_real_5)
    ! ... Purpose: Build an MPI structure consisting of 5 double precision 
    ! ...          real arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    REAL(kind=kdp), DIMENSION(:) :: r_array_1, r_array_2, r_array_3, &
         r_array_4, r_array_5
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_real_5
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:5) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:5) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:5) :: displs, address
#endif
    ! .......................................................................
    type_real_5=0
    blks=(/SIZE(r_array_1),SIZE(r_array_2),SIZE(r_array_3),SIZE(r_array_4), &
         SIZE(r_array_5)/)
    types=(/MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, &
         MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION/)
    CALL MPI_GET_ADDRESS(r_array_1(1), address(1), ierr)
    CALL MPI_GET_ADDRESS(r_array_2(1), address(2), ierr)
    CALL MPI_GET_ADDRESS(r_array_3(1), address(3), ierr)
    CALL MPI_GET_ADDRESS(r_array_4(1), address(4), ierr)
    CALL MPI_GET_ADDRESS(r_array_5(1), address(5), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    displs(4)=address(4)-address(1)
    displs(5)=address(5)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(5, blks, displs, types, type_real_5, ierr)
    CALL MPI_TYPE_COMMIT(type_real_5, ierr)
    ! ...
  END FUNCTION MPI_struct_real_array_5


  FUNCTION MPI_struct_real_array_6(r_array_1, r_array_2, r_array_3, r_array_4, &
       r_array_5, r_array_6) RESULT(type_real_6)
    ! ... Purpose: Build an MPI structure consisting of 6 double precision 
    ! ...          real arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    REAL(kind=kdp), DIMENSION(:) :: r_array_1, r_array_2, r_array_3, &
         r_array_4, r_array_5, r_array_6
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_real_6
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:6) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:6) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:6) :: displs, address
#endif
    ! .......................................................................
    type_real_6=0
    blks=(/SIZE(r_array_1),SIZE(r_array_2),SIZE(r_array_3),SIZE(r_array_4), &
         SIZE(r_array_5),SIZE(r_array_6)/)
    types=(/MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, &
         MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION/)
    CALL MPI_GET_ADDRESS(r_array_1(1), address(1), ierr)
    CALL MPI_GET_ADDRESS(r_array_2(1), address(2), ierr)
    CALL MPI_GET_ADDRESS(r_array_3(1), address(3), ierr)
    CALL MPI_GET_ADDRESS(r_array_4(1), address(4), ierr)
    CALL MPI_GET_ADDRESS(r_array_5(1), address(5), ierr)
    CALL MPI_GET_ADDRESS(r_array_6(1), address(6), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    displs(4)=address(4)-address(1)
    displs(5)=address(5)-address(1)
    displs(6)=address(6)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(6, blks, displs, types, type_real_6, ierr)
    CALL MPI_TYPE_COMMIT(type_real_6, ierr)
    ! ...
  END FUNCTION MPI_struct_real_array_6

  ! ... 1-D INTEGER ARRAY STRUCTURES

  FUNCTION MPI_struct_int_array_2(i_array_1, i_array_2) RESULT(type_int_2)
    ! ... Purpose: Build an MPI structure consisting of 2 integer arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    INTEGER, DIMENSION(:) :: i_array_1, i_array_2
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_int_2
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:2) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:2) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:2) :: displs, address
#endif
    ! .......................................................................
    type_int_2=0
    blks=(/SIZE(i_array_1),SIZE(i_array_2)/)
    types=(/MPI_INTEGER, MPI_INTEGER/)
    CALL MPI_GET_ADDRESS(i_array_1(1), address(1), ierr)
    CALL MPI_GET_ADDRESS(i_array_2(1), address(2), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(2, blks, displs, types, type_int_2, ierr)
    CALL MPI_TYPE_COMMIT(type_int_2, ierr)
    ! ...
  END FUNCTION MPI_struct_int_array_2

  FUNCTION MPI_struct_int_array_3(i_array_1, i_array_2, i_array_3) RESULT(type_int_3)
    ! ... Purpose: Build an MPI structure consisting of 3 integer arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    INTEGER, DIMENSION(:) :: i_array_1, i_array_2, i_array_3
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_int_3
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:3) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:3) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:3) :: displs, address
#endif
    ! .......................................................................
    type_int_3=0
    blks=(/SIZE(i_array_1),SIZE(i_array_2),SIZE(i_array_3)/)
    types=(/MPI_INTEGER, MPI_INTEGER, MPI_INTEGER/)
    CALL MPI_GET_ADDRESS(i_array_1(1), address(1), ierr)
    CALL MPI_GET_ADDRESS(i_array_2(1), address(2), ierr)
    CALL MPI_GET_ADDRESS(i_array_3(1), address(3), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(3, blks, displs, types, type_int_3, ierr)
    CALL MPI_TYPE_COMMIT(type_int_3, ierr)
    ! ...
  END FUNCTION MPI_struct_int_array_3

  FUNCTION MPI_struct_int_array_4(i_array_1, i_array_2, i_array_3, i_array_4) &
       RESULT(type_int_4)
    ! ... Purpose: Build an MPI structure consisting of 4 integer arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    INTEGER, DIMENSION(:) ::i_array_1, i_array_2, i_array_3, i_array_4
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_int_4
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:4) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:4) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:4) :: displs, address
#endif
    ! .......................................................................
    type_int_4=0
    blks=(/SIZE(i_array_1),SIZE(i_array_2),SIZE(i_array_3),SIZE(i_array_4)/)
    types=(/MPI_INTEGER, MPI_INTEGER, MPI_INTEGER, MPI_INTEGER/)
    CALL MPI_GET_ADDRESS(i_array_1(1), address(1), ierr)
    CALL MPI_GET_ADDRESS(i_array_2(1), address(2), ierr)
    CALL MPI_GET_ADDRESS(i_array_3(1), address(3), ierr)
    CALL MPI_GET_ADDRESS(i_array_4(1), address(4), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    displs(4)=address(4)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(4, blks, displs, types, type_int_4, ierr)
    CALL MPI_TYPE_COMMIT(type_int_4, ierr)
    ! ...
  END FUNCTION MPI_struct_int_array_4

  FUNCTION MPI_struct_int_array_5(i_array_1, i_array_2, i_array_3, i_array_4, &
       i_array_5) RESULT(type_int_5)
    ! ... Purpose: Build an MPI structure consisting of 5 integer arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    INTEGER, DIMENSION(:) ::i_array_1, i_array_2, i_array_3, &
         i_array_4, i_array_5
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_int_5
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:5) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:5) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:5) :: displs, address
#endif
    ! .......................................................................
    type_int_5=0
    blks=(/SIZE(i_array_1),SIZE(i_array_2),SIZE(i_array_3),SIZE(i_array_4), &
         SIZE(i_array_5)/)
    types=(/MPI_INTEGER, MPI_INTEGER, MPI_INTEGER, MPI_INTEGER, &
         MPI_INTEGER/)
    CALL MPI_GET_ADDRESS(i_array_1(1), address(1), ierr)
    CALL MPI_GET_ADDRESS(i_array_2(1), address(2), ierr)
    CALL MPI_GET_ADDRESS(i_array_3(1), address(3), ierr)
    CALL MPI_GET_ADDRESS(i_array_4(1), address(4), ierr)
    CALL MPI_GET_ADDRESS(i_array_5(1), address(5), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    displs(4)=address(4)-address(1)
    displs(5)=address(5)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(5, blks, displs, types, type_int_5, ierr)
    CALL MPI_TYPE_COMMIT(type_int_5, ierr)
    ! ...
  END FUNCTION MPI_struct_int_array_5

  FUNCTION MPI_struct_int_array_6(i_array_1, i_array_2, i_array_3, i_array_4, &
       i_array_5, i_array_6) RESULT(type_int_6)
    ! ... Purpose: Build an MPI structure consisting of 6 integer arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    INTEGER, DIMENSION(:) ::i_array_1, i_array_2, i_array_3, &
         i_array_4, i_array_5, i_array_6
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_int_6
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:6) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:6) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:6) :: displs, address
#endif
    ! .......................................................................
    type_int_6=0
    blks=(/SIZE(i_array_1),SIZE(i_array_2),SIZE(i_array_3),SIZE(i_array_4), &
         SIZE(i_array_5),SIZE(i_array_6)/)
    types=(/MPI_INTEGER, MPI_INTEGER, MPI_INTEGER, MPI_INTEGER, &
         MPI_INTEGER, MPI_INTEGER/)
    CALL MPI_GET_ADDRESS(i_array_1(1), address(1), ierr)
    CALL MPI_GET_ADDRESS(i_array_2(1), address(2), ierr)
    CALL MPI_GET_ADDRESS(i_array_3(1), address(3), ierr)
    CALL MPI_GET_ADDRESS(i_array_4(1), address(4), ierr)
    CALL MPI_GET_ADDRESS(i_array_5(1), address(5), ierr)
    CALL MPI_GET_ADDRESS(i_array_6(1), address(6), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    displs(4)=address(4)-address(1)
    displs(5)=address(5)-address(1)
    displs(6)=address(6)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(6, blks, displs, types, type_int_6, ierr)
    CALL MPI_TYPE_COMMIT(type_int_6, ierr)
    ! ...
  END FUNCTION MPI_struct_int_array_6

  ! ... 2_D REAL ARRAY STRUCTURES

  FUNCTION MPI_struct_real_2_array_2(r_array_1, r_array_2) RESULT(type_real_2)
    ! ... Purpose: Build an MPI structure consisting of a 2-D double precision 
    ! ...          real arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    REAL(kind=kdp), DIMENSION(:,:) :: r_array_1, r_array_2
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_real_2
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:2) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:2) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:2) :: displs, address
#endif
    ! .......................................................................
    type_real_2=0
    blks=(/SIZE(r_array_1),SIZE(r_array_2)/)
    types=(/MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION/)
    CALL MPI_GET_ADDRESS(r_array_1(1,1), address(1), ierr)
    CALL MPI_GET_ADDRESS(r_array_2(1,1), address(2), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(2, blks, displs, types, type_real_2, ierr)
    CALL MPI_TYPE_COMMIT(type_real_2, ierr)
    ! ...
  END FUNCTION MPI_struct_real_2_array_2

  FUNCTION MPI_struct_real_2_array_3(r_array_1, r_array_2, r_array_3) RESULT(type_real_3)
    ! ... Purpose: Build an MPI structure consisting of 3 2-D double precision 
    ! ...          real arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    REAL(kind=kdp), DIMENSION(:,:) :: r_array_1, r_array_2, r_array_3
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_real_3
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:3) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:3) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:3) :: displs, address
#endif
    ! .......................................................................
    type_real_3=0
    blks=(/SIZE(r_array_1),SIZE(r_array_2),SIZE(r_array_3)/)
    types=(/MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION/)
    CALL MPI_GET_ADDRESS(r_array_1(1,1), address(1), ierr)
    CALL MPI_GET_ADDRESS(r_array_2(1,1), address(2), ierr)
    CALL MPI_GET_ADDRESS(r_array_3(1,1), address(3), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(3, blks, displs, types, type_real_3, ierr)
    CALL MPI_TYPE_COMMIT(type_real_3, ierr)
    ! ...
  END FUNCTION MPI_struct_real_2_array_3

  FUNCTION MPI_struct_real_2_array_4(r_array_1, r_array_2, r_array_3, &
       r_array_4) RESULT(type_real_4)
    ! ... Purpose: Build an MPI structure consisting of 4 2-D double precision 
    ! ...          real arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    REAL(kind=kdp), DIMENSION(:,:) :: r_array_1, r_array_2, r_array_3, &
         r_array_4
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_real_4
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:4) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:4) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:4) :: displs, address
#endif
    ! .......................................................................
    type_real_4=0
    blks=(/SIZE(r_array_1),SIZE(r_array_2),SIZE(r_array_3),SIZE(r_array_4)/)
    types=(/MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, &
         MPI_DOUBLE_PRECISION/)
    CALL MPI_GET_ADDRESS(r_array_1(1,1), address(1), ierr)
    CALL MPI_GET_ADDRESS(r_array_2(1,1), address(2), ierr)
    CALL MPI_GET_ADDRESS(r_array_3(1,1), address(3), ierr)
    CALL MPI_GET_ADDRESS(r_array_4(1,1), address(4), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    displs(4)=address(4)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(4, blks, displs, types, type_real_4, ierr)
    CALL MPI_TYPE_COMMIT(type_real_4, ierr)
    ! ...
  END FUNCTION MPI_struct_real_2_array_4

  FUNCTION MPI_struct_real_2_array_5(r_array_1, r_array_2, r_array_3, &
       r_array_4, r_array_5) RESULT(type_real_5)
    ! ... Purpose: Build an MPI structure consisting of 5 2-D double precision 
    ! ...          real arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    REAL(kind=kdp), DIMENSION(:,:) :: r_array_1, r_array_2, r_array_3, &
         r_array_4, r_array_5
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_real_5
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:5) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:5) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:5) :: displs, address
#endif
    ! .......................................................................
    type_real_5=0
    blks=(/SIZE(r_array_1),SIZE(r_array_2),SIZE(r_array_3),SIZE(r_array_4), &
         SIZE(r_array_5)/)
    types=(/MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, &
         MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION/)
    CALL MPI_GET_ADDRESS(r_array_1(1,1), address(1), ierr)
    CALL MPI_GET_ADDRESS(r_array_2(1,1), address(2), ierr)
    CALL MPI_GET_ADDRESS(r_array_3(1,1), address(3), ierr)
    CALL MPI_GET_ADDRESS(r_array_4(1,1), address(4), ierr)
    CALL MPI_GET_ADDRESS(r_array_5(1,1), address(5), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    displs(4)=address(4)-address(1)
    displs(5)=address(5)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(5, blks, displs, types, type_real_5, ierr)
    CALL MPI_TYPE_COMMIT(type_real_5, ierr)
    ! ...
  END FUNCTION MPI_struct_real_2_array_5

  FUNCTION MPI_struct_real_2_array_6(r_array_1, r_array_2, r_array_3,  &
       r_array_4,r_array_5, r_array_6) RESULT(type_real_6)
    ! ... Purpose: Build an MPI structure consisting of 6 2-D double precision 
    ! ...          real arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    REAL(kind=kdp), DIMENSION(:,:) :: r_array_1, r_array_2, r_array_3, &
         r_array_4, r_array_5, r_array_6
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_real_6
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:6) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:6) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:6) :: displs, address
#endif
    ! .......................................................................
    type_real_6=0
    blks=(/SIZE(r_array_1),SIZE(r_array_2),SIZE(r_array_3),SIZE(r_array_4), &
         SIZE(r_array_5),SIZE(r_array_6)/)
    types=(/MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, &
         MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION, MPI_DOUBLE_PRECISION/)
    CALL MPI_GET_ADDRESS(r_array_1(1,1), address(1), ierr)
    CALL MPI_GET_ADDRESS(r_array_2(1,1), address(2), ierr)
    CALL MPI_GET_ADDRESS(r_array_3(1,1), address(3), ierr)
    CALL MPI_GET_ADDRESS(r_array_4(1,1), address(4), ierr)
    CALL MPI_GET_ADDRESS(r_array_5(1,1), address(5), ierr)
    CALL MPI_GET_ADDRESS(r_array_6(1,1), address(6), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    displs(4)=address(4)-address(1)
    displs(5)=address(5)-address(1)
    displs(6)=address(6)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(6, blks, displs, types, type_real_6, ierr)
    CALL MPI_TYPE_COMMIT(type_real_6, ierr)
    ! ...
  END FUNCTION MPI_struct_real_2_array_6

  ! ... 2_D Integer Array Structures

  FUNCTION MPI_struct_int_2_array_2(i_array_1, i_array_2) RESULT(type_int_2)
    ! ... Purpose: Build an MPI structure consisting of a 2-D 
    ! ...          integer arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    INTEGER, DIMENSION(:,:) :: i_array_1, i_array_2
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_int_2
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:2) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:2) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:2) :: displs, address
#endif
    ! .......................................................................
    type_int_2=0
    blks=(/SIZE(i_array_1),SIZE(i_array_2)/)
    types=(/MPI_INTEGER, MPI_INTEGER/)
    CALL MPI_GET_ADDRESS(i_array_1(1,1), address(1), ierr)
    CALL MPI_GET_ADDRESS(i_array_2(1,1), address(2), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(2, blks, displs, types, type_int_2, ierr)
    CALL MPI_TYPE_COMMIT(type_int_2, ierr)
    ! ...
  END FUNCTION MPI_struct_int_2_array_2

  FUNCTION MPI_struct_int_2_array_3(i_array_1, i_array_2, i_array_3) RESULT(type_int_3)
    ! ... Purpose: Build an MPI structure consisting of 3 2-D 
    ! ...          integer arrays.
    ! ... Explicit interface required: assumed-shape arrays 
    ! ...
    ! ... argument list
    ! ...
    INTEGER, DIMENSION(:,:) :: i_array_1, i_array_2, i_array_3
    ! ...
    ! ... result
    ! ...
    INTEGER :: type_int_3
    ! ...  
    ! ... local variables
    ! ...
    INTEGER :: ierr
    INTEGER, DIMENSION(1:3) :: blks, types !, displs, address
#if defined(MPI_32)
    INTEGER, DIMENSION(1:3) :: displs, address
#else
    INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(1:3) :: displs, address
#endif
    ! .......................................................................
    type_int_3=0
    blks=(/SIZE(i_array_1),SIZE(i_array_2),SIZE(i_array_3)/)
    types=(/MPI_INTEGER, MPI_INTEGER, MPI_INTEGER/)
    CALL MPI_GET_ADDRESS(i_array_1(1,1), address(1), ierr)
    CALL MPI_GET_ADDRESS(i_array_2(1,1), address(2), ierr)
    CALL MPI_GET_ADDRESS(i_array_3(1,1), address(3), ierr)
    displs(1)=0
    displs(2)=address(2)-address(1)
    displs(3)=address(3)-address(1)
    CALL MPI_TYPE_CREATE_STRUCT(3, blks, displs, types, type_int_3, ierr)
    CALL MPI_TYPE_COMMIT(type_int_3, ierr)
    ! ...
  END FUNCTION MPI_struct_int_2_array_3
#endif !  USE_MPI

END MODULE mpi_struct_arrays
