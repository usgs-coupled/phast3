SUBROUTINE CreateMappingFortran(initial_conditions)
      USE mcg, only: nx, ny, nz, nxy, nxyz, naxes, grid2chem
      USE mcc, only: mpi_myself, rm_id
      IMPLICIT NONE
      INCLUDE "RM_interface_F.f90.inc"
      INTEGER :: status
      ! 
! calculate mapping from full set of cells to subset needed for chemistry
!
    CHARACTER(LEN=130) :: erline
    
    INTEGER, DIMENSION(:,:), ALLOCATABLE, INTENT(INOUT) :: initial_conditions
	integer i, m, n, ii, jj, kk
    integer count_chem
    logical axes(0:2)
  
	axes(0) = (naxes(1) .ne. 0)
	axes(1) = (naxes(2) .ne. 0)
	axes(2) = (naxes(3) .ne. 0)

	count_chem = 1

	if (.not.axes(0) .and. .not.axes(1) .and. .not.axes(2)) then
        erline = 'No active coordinate direction in DIMENSIONS keyword.'
		status = RM_ErrorMessage(rm_id, erline)
	endif
	if (axes(0)) count_chem = count_chem * nx
	if (axes(1)) count_chem = count_chem * ny
	if (axes(2)) count_chem = count_chem * nz
    
    grid2chem = -1
!
!   xyz domain
!
	if (axes(0) .and. axes(1) .and. (axes(2))) then
		n = 0;
		do m = 1, nxyz
            grid2chem(m) = -1
			if (initial_conditions(1, m) >= 0 .or. initial_conditions(1, m) <= -100) then
                grid2chem(m) = n
				n = n + 1
			endif
		enddo
		count_chem = n;
!
!   Copy xy plane
!
	else if (axes(0) .and. axes(1) .and. .not.axes(2)) then
		if (nz .ne. 2) then
            erline = 'Z direction should contain only two nodes for this 2D problem.'
            status = RM_ErrorMessage(rm_id, erline)
		endif
		n = 0
		do m = 1, nxyz
			CALL mtoijk(m, ii, jj, kk, nx, ny)
			if (kk == 1 .and. (initial_conditions(1, m) >= 0 .or. initial_conditions(1, m) <= -100) ) then
                grid2chem(m) = n
                grid2chem(m + nxy) = n
				n = n + 1
            endif
		enddo
		count_chem = n
!
!   Copy xz plane
!
	else if (axes(0) .and. .not.axes(1) .and. axes(2)) then
		if (ny .ne. 2) then
            erline = 'Y direction should contain only two nodes for this 2D problem.'
            status = RM_ErrorMessage(rm_id, erline)
		endif
		n = 0;
		do m = 1, nxyz
			CALL mtoijk(m, ii, jj, kk, nx, ny)
			if (jj == 1	.and. (initial_conditions(1, m) >= 0 .or. initial_conditions(1, m) <= -100)) then
                grid2chem(m) = n
                grid2chem(m + nx) = n
				n = n + 1
			endif
		enddo
		count_chem = n
!
!   Copy yz plane
!
	else if (.not.axes(0) .and. axes(1) .and. axes(2)) then
		if (nx .ne. 2) then
            erline = 'X direction should contain only two nodes for this 2D problem.'
            status = RM_ErrorMessage(rm_id, erline)
		endif
		n = 0
		do m = 1, nxyz
			CALL mtoijk(m, ii, jj, kk, nx, ny)
			if (ii == 1	.and. (initial_conditions(1, m) >= 0 .or. initial_conditions(1, m) <= -100)) then
                grid2chem(m) = n
                grid2chem(m + 1) = n
				n = n + 1
			endif
		enddo
		count_chem = n
!
!   Copy x line
!
	else if (axes(0) .and. .not.axes(1) .and. .not.axes(2)) then
		if (ny .ne. 2) then
            erline = 'Y direction should contain only two nodes for this 1D problem.'
            status = RM_ErrorMessage(rm_id, erline)
		endif
		if (nz .ne. 2) then
            erline = 'Z direction should contain only two nodes for this 1D problem.'
            status = RM_ErrorMessage(rm_id, erline)
        endif
		n = 0
		do m = 1, nxyz
			if (initial_conditions(1, m) < 0 .and. initial_conditions(1, m) > -100) then
                erline = 'Cannot have inactive cells in a 1D simulation.'
               status = RM_ErrorMessage(rm_id, erline)
            endif
			CALL mtoijk(m, ii, jj, kk, nx, ny)
			if (jj == 1 .and. kk == 1) then
                grid2chem(m) = n
                grid2chem(m + nx) = n
                grid2chem(m + nxy) = n
                grid2chem(m + nxy + nx) = n
				n = n + 1
			endif
		enddo
		count_chem = n
!
!   Copy y line
!
	else if (.not.axes(0) .and. axes(1) .and. .not.axes(2)) then
		if (nx .ne. 2) then
            erline = 'X direction should contain only two nodes for this 1D problem.'
            status = RM_ErrorMessage(rm_id, erline)
		endif
		if (nz .ne. 2) then
            erline = 'Z direction should contain only two nodes for this 1D problem.'
            status = RM_ErrorMessage(rm_id, erline)
		endif

		n = 0
		do m = 1, nxyz
			if (initial_conditions(1, m) < 0 .and. initial_conditions(1, m) > -100) then
                erline = 'Cannot have inactive cells in a 1D simulation.'
                status = RM_ErrorMessage(rm_id, erline)
		    endif
			CALL mtoijk(m, ii, jj, kk, nx, ny)
			if (ii == 1 .and. kk == 1) then
                grid2chem(m) = n
                grid2chem(m + 1) = n
                grid2chem(m + nxy) = n
                grid2chem(m + nxy + 1) = n
				n = n + 1
			endif
		enddo
		count_chem = n
!
!   Copy z line
!
	else if (.not.axes(0) .and. .not.axes(1) .and. axes(2)) then
		if (nx .ne. 2) then
            erline = 'X direction should contain only two nodes for this 1D problem.'
            status = RM_ErrorMessage(rm_id, erline)
        endif
		if (ny .ne. 2) then
            erline = 'Y direction should contain only two nodes for this 1D problem.'
            status = RM_ErrorMessage(rm_id, erline)
        endif
		n = 0
		do m = 1, nxyz
			if (initial_conditions(1, m) < 0 .and. initial_conditions(1, m) > -100) then
                erline = 'Cannot have inactive cells in a 1D simulation.'
               status = RM_ErrorMessage(rm_id, erline)
		    endif
			CALL mtoijk(m, ii, jj, kk, nx, ny)
			if (ii == 1 .and. jj == 1) then
                grid2chem(m) = n
                grid2chem(m + 1) = n
                grid2chem(m + nx) = n
                grid2chem(m + nx + 1) = n
				n = n + 1
			endif
		enddo
		count_chem = n
    endif
	return
END SUBROUTINE CreateMappingFortran
