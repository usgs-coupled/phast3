SUBROUTINE errprt(ie1,ie2)
  ! ... Prints the index numbers of errors encountered and a brief
  ! ...      message
!!$  USE f_units
  USE mcc
  INTEGER, INTENT(IN) :: ie1, ie2
  INTEGER :: ie
  CHARACTER(LEN=130) :: erline
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  DO  ie=ie1,ie2
     IF (ierr(ie)) GO TO 20
  END DO
  RETURN
20 erline =  '**** The Following Errors Were Detected ****'
  ! ... The error messages
  IF(ierr(1)) THEN
     erline='1   - READ1 -  NX or NY or NZ is too small'
     CALL errprt_c(erline)
  END IF
  IF(ierr(2)) THEN
     erline='2   - READ1 -  LX or LY or LZ is too small:param6.inc'
     CALL errprt_c(erline)
  END IF
  IF(ierr(3)) THEN
     erline='3   - READ1 -  Too many boundary condition cells '// 'are specified'
     CALL errprt_c(erline)
  END IF
  IF(ierr(4)) THEN
     erline='4   - INIT2 - '// 'LA4 is too small for the solver selected'//  &
          'Insufficient space for A4 array:param5.inc'
     CALL errprt_c(erline)
  END IF
  IF(ierr(6)) THEN
     erline='6   - READ1 -  LPMZ is too small, too many '//  &
          'porous media zones specified:param2.inc'
     CALL errprt_c(erline)
  END IF
  IF(ierr(7)) THEN
     erline='7   - READ1 -  Solution method code not recognized'
     CALL errprt_c(erline)
  END IF
  IF(ierr(9)) THEN
     erline='9   - READ1 -  LSDR is too small for number of '//  &
          'directions to be retained between restarts of conjugate-'  &
          //'gradient solver:param5.inc'
     CALL errprt_c(erline)
  END IF
  IF(ierr(10)) THEN
     erline='10  - READ1 -  '//  &
          'LA4 is too small'//' insufficient space for '//  &
          'envelope storage of RA arrays:param5.inc'
     CALL errprt_c(erline)
  END IF
  IF(ierr(11)) THEN
     erline='11  - READ1 - '//  &
          ' LA4 is too small for the dimension limits, LXYZ, '//  &
          'LSDR, and LRCGD1'// ' Insufficient space for A4 array:param5.inc'
     CALL errprt_c(erline)
  END IF
  IF(ierr(12)) THEN
     erline='12  - READ1 - '//  &
          'LXYZ is too small for specified NXYZ value:param1.inc'
     CALL errprt_c(erline)
  END IF
  IF(ierr(13)) THEN
     erline= '13  - LS is too small for number of species defined, NS'
     CALL errprt_c(erline)
  END IF
  IF(ierr(27)) THEN
     erline='27  - READ2 - Coordinate system tilt greater than '// '45 degrees'
     CALL errprt_c(erline)
  END IF
  IF(ierr(29)) THEN
     erline='29  - READ2 - Specified mass fraction and other '//  &
          'type of flow b.c. specified at same node'
     CALL errprt_c(erline)
  END IF
  IF(ierr(31)) THEN
     erline='31  - READ2 - Free surface problem with a '//  &
          'coordinate system tilt'
     CALL errprt_c(erline)
  END IF
  IF(ierr(33)) THEN
     erline='33  - READ2 - Specified pressure and other type '//  &
          'of flow b.c. defined at same node'
     CALL errprt_c(erline)
  END IF
  IF(ierr(34)) THEN
     erline='34  - READ2 - No heat b.c. allowed '
     CALL errprt_c(erline)
  END IF
  IF(ierr(35)) THEN
     erline='35  - READ2 - Only specified concentration b.c '//  &
          'allowed for solute; no diffusive solute flux allowed'
     CALL errprt_c(erline)
  END IF
  IF(ierr(36)) THEN
     erline='36  - READ2 - Only one face is allowed to have '//  &
          'a flux b.c. at a given node'
     CALL errprt_c(erline)
  END IF
  IF(ierr(37)) THEN
     erline='37  - READ2 - Only one face is allowed to have '//  &
          'a leakage b.c. at a given node'
     CALL errprt_c(erline)
  END IF
  IF(ierr(38)) THEN
     erline='38  - READ2 - Only a z-boundary face is allowed to have '//  &
          'a river b.c.'
     CALL errprt_c(erline)
  END IF
  IF(ierr(39)) THEN
     erline='39  - READ2 - Invalid b.c. code at one or more nodes '
     CALL errprt_c(erline)
  END IF
  IF(ierr(40)) THEN
     erline='40  - INIT2_1 - All cell columns are dry '
     CALL errprt_c(erline)
  END IF
!  IF(ierr(41)) THEN
!     erline='41  - INIT2_1 - One or more cell columns are dry '
!     CALL errprt_c(erline)
!  END IF   
  IF(ierr(45)) THEN
     erline='45  - READ2 - Input water table elevation above the '//  &
          'top of the expanded full cells in the uppermost plane'
     CALL errprt_c(erline)
  END IF
  IF(ierr(51)) THEN
     erline='51  - READ2 - Well x or y location outside '//  &
          'the simulation region'
     CALL errprt_c(erline)
  END IF
  IF(ierr(52)) THEN
     erline='52  - READ2 - Well completion layer outside the '//  &
          'simulation region or upside down completion'
     CALL errprt_c(erline)
  END IF
  IF(ierr(53)) THEN
     erline='53  - READ2 - Well calculation method selection '// 'not recognized'
     CALL errprt_c(erline)
  END IF
  IF(ierr(54)) THEN
     erline='54  - READ2 - Bottom completion zone has no porosity'
     CALL errprt_c(erline)
  END IF
  IF(ierr(55)) THEN
     erline='55  - READ2 - Well completed only in impermeable '// 'zones'
     CALL errprt_c(erline)
  END IF
  IF(ierr(56)) THEN
     erline='56  - READ2 - Well completion factor is zero in '//  &
          'uppermost or lowermost completion level'
     CALL errprt_c(erline)
  END IF
  IF(ierr(57)) THEN
     erline='57  - INIT2 - Well-bore area is greater than cell area in the x-y plane; '//  &
          'Well diameter too large'
     CALL errprt_c(erline)
  END IF
  IF(ierr(58)) THEN
     erline='58  - INIT2 - Well is completed in one or more cells that are inactive'
     CALL errprt_c(erline)
  END IF
  IF(ierr(61)) THEN
     erline='61  - READ2 - Negative well completion factor'
     CALL errprt_c(erline)
  END IF
  IF(ierr(62)) THEN
     erline='62  - READ2 - Well with all zero well indices'
     CALL errprt_c(erline)
  END IF
  IF(ierr(63)) THEN
     erline='63  - READ2 - A cell is not in any zone '//  &
          'but has not been flagged inactive '//  &
          'or a cell is in a zone but has been flagged'// ' inactive'
     CALL errprt_c(erline)
  END IF
  IF(ierr(64)) THEN
     erline='64  - READ2 - Indices defining a zone are '//  &
          'specified incorrectly;e.g. reverse order or only a plane'
     CALL errprt_c(erline)
  END IF
  IF(ierr(65)) THEN
     erline='65  - READ2 - A cylindrical coordinate system has '//  &
          'only one plane of nodes in the j-direction'
     CALL errprt_c(erline)
  END IF
  IF(ierr(66)) THEN
     erline='66  - READ2 - Specified zone boundaries lie outside '//  &
          'the simulation region'
     CALL errprt_c(erline)
  END IF
  IF(ierr(70)) THEN
     erline='70  - READ3 - Specified pressure and boundary fluid '//  &
          'flux at same node'
     CALL errprt_c(erline)
  END IF
  IF(ierr(72)) THEN
     erline='72  - READ3 - Specified mass fraction and solute '//  &
          'flux at same node'
     CALL errprt_c(erline)
  END IF
  IF(ierr(73)) THEN
     erline='73  - READ3 - Leakage head set below external '//  &
          'elevation of leaky boundary'
     CALL errprt_c(erline)
  END IF
  IF(ierr(74)) THEN
     erline='74  - READ3 - River head set below bottom '//  &
          'elevation of river'
     CALL errprt_c(erline)
 END IF
  IF(IERR(75)) THEN
     erline='75  - READ3 - Well head data specified for a '// &
          'well calculation type not requiring it'
     CALL errprt_c(erline)
  ENDIF
  IF(ierr(77)) THEN
     erline='77  - READ3 - Flux b.c. data specified '//  &
          'associated with a null cell number'
     CALL errprt_c(erline)
  END IF
  IF(ierr(79)) THEN
     erline='79  - READ3 - Exterior aquifer potential '//  &
          'set below b.c. cell elevation'
     CALL errprt_c(erline)
  END IF
  IF(ierr(83)) THEN
     erline='83  - READ3 - Time for input of next set of '//  &
          'transient data is earlier than or the same as '// 'the current time'
     CALL errprt_c(erline)
  END IF
  IF(ierr(91)) THEN
     erline='91  - READ2 - Error in X,Y, or Z range for read in '//  &
          'of porosity data'
     CALL errprt_c(erline)
  END IF
  IF(ierr(93)) THEN
     erline='93  - READ2 - Error in X,Y, or Z range for read in '//  &
          'of pressure data'
     CALL errprt_c(erline)
  END IF
  IF(ierr(96)) THEN
     erline='96  - READ2 - Error in X,Y, or Z range for read in '//  &
          'of solution index data'
     CALL errprt_c(erline)
  END IF
  IF(ierr(101)) THEN
     erline='101 - READ2 - Error in X,Y, or Z range for read in '//  &
          'of specified pressure, or mass fraction b.c.'
     CALL errprt_c(erline)
  END IF
  IF(ierr(102)) THEN
     erline='102 - READ2 - Error in X,Y, or Z range for read in '//  &
          'of specified flux b.c.'
     CALL errprt_c(erline)
  END IF
  IF(ierr(103)) THEN
     erline='103 - READ2 - Error in X,Y, or Z range for read in '//  &
          'of leakage b.c.'
     CALL errprt_c(erline)
  END IF
  IF(ierr(106)) THEN
     erline='106 - READ3 - Error in X,Y, or Z range for read in '//  &
          'of specified pressure b.c.'
     CALL errprt_c(erline)
  END IF
  IF(ierr(108)) THEN
     erline='108 - READ3 - Error in X,Y, or Z range for read in '//  &
          'of specified mass fraction b.c.'
     CALL errprt_c(erline)
  END IF
  IF(ierr(110)) THEN
     erline='110 - READ3 - Error in X,Y, or Z range for read in '//  &
          'of associated advective solute flux mass fractions'
     CALL errprt_c(erline)
  END IF
  IF(ierr(111)) THEN
     erline='111 - READ3 - Error in X,Y, or Z range for read in '//  &
          'of specified fluid flux b.c.'
     CALL errprt_c(erline)
  END IF
  IF(ierr(113)) THEN
     erline='113 - READ3 - Error in X,Y, or Z range for read in '//  &
          'of associated mass fraction for fluid '// 'of flux b.c.'
     CALL errprt_c(erline)
  END IF
  IF(ierr(114)) THEN
     erline='114 - READ3 -   Error in X,Y, or Z range for '//  &
          'read in of specified mass flux b.c'
     CALL errprt_c(erline)
  END IF
  IF(ierr(124)) THEN
     erline='124 - READ3 - Error in X,Y, or Z range for read in '//  &
          'of aquifer leakage parameters'
     CALL errprt_c(erline)
  END IF
  IF(ierr(125)) THEN
     erline='125 - READ3 - Error in X,Y, or Z range for read in '//  &
          'of print control index for sub-grid'
     CALL errprt_c(erline)
  END IF
  IF(ierr(126)) THEN
     erline='126 - READ3 - Error in X,Y, or Z range for read in '//  &
          'of mass fraction of outer leaky aquifer region'
     CALL errprt_c(erline)
  END IF
  IF(ierr(127)) THEN
     erline='127  - READ3 - Error in X,Y, or Z range for read in '//  &
          'of solution index data'
     CALL errprt_c(erline)
  END IF
  IF(ierr(131)) THEN
     erline='131 - READ2 - Error in X,Y, or Z range for read in '//  &
          'of leakage parameters'
     CALL errprt_c(erline)
  END IF
  IF(ierr(133)) THEN
     erline='133 - INIT2 - Too many specified P or C nodes'//  &
          ' identified by IBC = 1'
     CALL errprt_c(erline)
  END IF
  IF(ierr(135)) THEN
     erline='135 - INIT2 - Interpolation failure for mass '// 'fraction i.c.'
     CALL errprt_c(erline)
  END IF
  IF(ierr(138)) THEN
     erline='138 - READ2 - Interpolation failure for zone '// 'location '
     CALL errprt_c(erline)
  END IF
  IF(ierr(139)) THEN
     erline='139 - RCGIES - No convergence to equation solution '//  &
          'with generalized conjugate-gradient solver'
     CALL errprt_c(erline)
  END IF
  IF(ierr(142)) THEN
     erline='142 - WBBAL -  Wellbore excess residual flow for'//  &
          ' one or more wells'
     CALL errprt_c(erline)
  END IF
  IF(ierr(144)) THEN
     erline='144 - SUMCAL - Free surface has dropped or risen '//  &
          'more than one cell during a time step'
     CALL errprt_c(erline)
  END IF
  IF(ierr(145)) THEN
     erline='145 - READ2 - Interpolation failure for river '// 'location'
     CALL errprt_c(erline)
  END IF
  IF(ierr(146)) THEN
     erline='146 - PHAST - Failure to achieve convergence '//  &
          'on steady-state flow initial condition '
     CALL errprt_c(erline)
  END IF
  IF(ierr(147)) THEN
     erline='147 - ERROR3 - Specified head cell with saturation is isolated '//  &
          'by an unsaturated zone below'
     CALL errprt_c(erline)
  END IF
  IF(ierr(148)) THEN
     erline='148 - ERROR4 - Multiple free surfaces in same column of cells '//  &
          'from initial head distribution'
     CALL errprt_c(erline)
  END IF
  IF(ierr(170)) THEN
     erline='170 - SUMCAL - Failure to achieve desired limit'//  &
          ' on dependent variable change by time step reduction'
     CALL errprt_c(erline)
  END IF
  IF(ierr(171)) THEN
     erline='171 - COEFF - One or more negative dispersion coefficients '//  &
          'have been calculated. Consider turning off cross-dispersion fluxes'
     CALL errprt_c(erline)
  END IF

END SUBROUTINE errprt
