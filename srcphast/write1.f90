SUBROUTINE write1
  ! ... Writes out the basic dimensioning information and simulation
  ! ...     specifications
  USE f_units
  USE mcc
  USE mcch
  USE mcg
  USE mcp
  USE mcv
  IMPLICIT NONE
  INTEGER :: i
  CHARACTER(LEN=11) :: fmt1
  CHARACTER(LEN=130) :: logline1, logline2
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  WRITE (fulp,2001)  &
       '*    PHAST: A Three Dimensional Flow and Solute    *',  &
       '*         Reactive Transport Simulator             *',  &
       '*                 Version:'//version_name//'                 *'
2001 FORMAT(tr36,52('*') /tr36,'*',tr50,'*'/tr36,a/tr36,a/tr36,a)
  WRITE(fulp,2002)
2002 FORMAT(tr36,'*',tr50,'*'/tr36,52('*')////)
  WRITE(fulp,2003) title(1:80),title(81:160)
2003 FORMAT(//tr26,a80/tr26,a80)
  IF(restrt) WRITE(fulp,2003) titleo(1:80),titleo(81:160)
!!$  WRITE(fuplt,5001) title(1:80),title(81:160)
!!$  IF(restrt) WRITE(fuplt,5001) titleo(1:80),titleo(81:160)
  DO  i=fup,fubcf
     WRITE(i,2003) title(1:80),title(81:160)
     IF(restrt) WRITE(i,2003) titleo(1:80),titleo(81:160)
  END DO
  WRITE(fuzf,2003) title(1:80),title(81:160)
  ! ... Write header to file 'Fuzf2' for flow zone tab separated file
  WRITE(fuzf2,5001) title(1:80),title(81:160)
5001 FORMAT(a80)
  WRITE(fuzf2,5011) 'Flow Rates'//ACHAR(9)//'('//unitm//'/'//TRIM(unittm)//')'
  WRITE(fuzf2,5011) 'Time'//ACHAR(9)//'Zone'//ACHAR(9)//'Component'//ACHAR(9)//  &
       'Total in'//ACHAR(9)//'Total out'//ACHAR(9)//'Internal face in'//  &
       ACHAR(9)//'Internal face out'//ACHAR(9)//'Specified head in'//ACHAR(9)//  &
       'Specified head out'//ACHAR(9)//'Flux in'//ACHAR(9)//'Flux out'//ACHAR(9)//  &
       'Leaky in'//ACHAR(9)//'Leaky out'//ACHAR(9)//'River in'//ACHAR(9)//  &
       'River out'//ACHAR(9)//'Drain in'//ACHAR(9)//'Drain out'//ACHAR(9)//  &
       'Well in'//ACHAR(9)//'Well out'
  WRITE(logline1,5013) title(1:80)
  WRITE(logline2,5013) title(81:160)
5013 FORMAT(a80)
  CALL logprt_c(logline1)
  CALL logprt_c(logline2)
  WRITE(fulp,2004)
2004 FORMAT(/tr25,'*** Fundamental Information ***')
!!$  IF(heat) THEN
!!$     WRITE(fulp,2005) 'Heat transport simulation'
!!$  ELSE
  WRITE(fulp,2005) 'Isothermal simulation'
2005 FORMAT(tr20,a)
!!$  END IF
  IF(solute) THEN
     WRITE(fulp,2005) 'Solute transport simulation'
  ELSE
     WRITE(fulp,2005) 'No solute transport simulaton'
  END IF
  IF(restrt) WRITE(fulp,2006) cnvtmi*timrst,unittm
2006 FORMAT(tr20,'A restart to continue a previous simulation ',  &
       'from time ',1PG10.4,tr2,'(',a,')')
  IF(cylind) THEN
     WRITE(fulp,2005) 'Cylindrical coordinates'
  ELSE
     WRITE(fulp,2005) 'Cartesian coordinates'
  END IF
  IF(eeunit) THEN
     WRITE(fulp,2005) 'Data is in  U.S. customary units'
  ELSE
     WRITE(fulp,2005) 'Data is in metric units'
  END IF
  WRITE(fulp,2007) 'Time unit selected is ',utulbl
2007 FORMAT(tr20,2A)
  IF(solute.AND.scalmf) WRITE(fulp,2007) 'Solute concentration is ',  &
       'expressed as scaled mass fraction with range (0-1)'
  IF(solute.AND..NOT.scalmf) WRITE(fulp,2007) 'Solute ',  &
       'concentration is expressed as mass fraction'
  IF(slmeth == 1) THEN
     WRITE(fulp,2011)
2011 FORMAT(/tr10,'Direct D4 solver is selected')
  ELSE IF(slmeth == 2) THEN
     WRITE(fulp,2012)
2012 FORMAT(/tr10,'Iterative two-line-successive-over-relaxation ',  &
          'solver is selected')
  ELSE IF(slmeth == 3) THEN
     WRITE(fulp,2013)
2013 FORMAT(/tr10,'Iterative generalized conjugate gradient ',  &
          'solver with red-black reduction is selected')
  ELSE IF(slmeth == 5) THEN
     WRITE(fulp,2014)
2014 FORMAT(/tr10,'Iterative generalized conjugate gradient ',  &
          'solver with d4 zig-zag reduction is selected')
  END IF
  WRITE(fulp,2008) '*** Problem Dimension Information ***',  &
       'Number of nodes in x-direction '//dots,' NX ... ',nx,  &
       'Number of nodes in y-direction '//dots,' NY ... ',ny,  &
       'Number of nodes in z-direction '//dots,' NZ ... ',nz,  &
       'Total number of nodes '//dots,' NXYZ . ',nxyz
2008 FORMAT(/TR25,A/(TR10,A65,A,I6))
!!$  WRITE(logline1,5008) '*** Problem Dimension Information ***'
!!$5008 format(a)
!!$  WRITE(logline2,5009) 'Number of nodes in x-direction '//dots,' NX ... ',nx
!!$5009 format(a65,a,i6)
!!$  WRITE(logline3,5009) 'Number of nodes in y-direction '//dots,' NY ... ',ny
!!$  WRITE(logline4,5009) 'Number of nodes in z-direction '//dots,' NZ ... ',nz
!!$  WRITE(logline5,5009) 'Total number of nodes '//dots,' NXYZ . ',nxyz
!!$  call logprt_c(logline1)
!!$  call logprt_c(logline2)
!!$  call logprt_c(logline3)
!!$  call logprt_c(logline4)
!!$  call logprt_c(logline5)
  IF(solute) THEN
     ! ... Write static data to file 'FUPMAP' for screen or plotter maps
     ! ... Write header to file 'Fupmap' for component xyz field plots
     WRITE(fmt1,"(a,i2,a)") '(tr1,a,',ns,'a)'
     WRITE(fupmap,fmt1) 'x'//ACHAR(9)//'y'//ACHAR(9)//'z'//ACHAR(9)//'time'//  &
          ACHAR(9)//'in'//ACHAR(9),(comp_name(is)//ACHAR(9),is=1,ns)
  END IF
!!$  WRITE(fupmap,5001) title(1:80),title(81:160)
!!$  5001 FORMAT(a80)
!!$  WRITE(fupmap,5002) heat,solute,eeunit,cylind
!!$  5002 FORMAT(4L5)
!!$  WRITE(fupmap,5003) nx,ny,nz,nxy,nxyz 
!!$  5003 FORMAT(5I8)
!!$  WRITE(fupmap,5003) ns
  ! ... Write header to file 'Fupmap2' for head xyz field plots
  WRITE(fupmp2,5011) 'x'//ACHAR(9)//'y'//ACHAR(9)//'z'//ACHAR(9)//'time'//  &
       ACHAR(9)//'in'//ACHAR(9)//'head'//ACHAR(9) 
  ! ... Write header to file 'Fuvmap' for velocity xyz plots
  WRITE(fuvmap,5011) 'x'//ACHAR(9)//'y'//ACHAR(9)//'z'//ACHAR(9)//'time'//  &
       ACHAR(9)//'in'//ACHAR(9)//'vx-node'//ACHAR(9)//'vy-node'//ACHAR(9)//  &
       'vz-node'//ACHAR(9) 
5011 FORMAT(tr5,a)
  ! ... Write static data to file 'FUPLT' for temporal plots
  WRITE(fmt1,"(a,i2,a)") '(tr1,a,',ns+2,'a)'
  WRITE(fuplt,fmt1) 'x'//ACHAR(9)//'y'//ACHAR(9)//'z_datum'//  &
       ACHAR(9)//'Time'//ACHAR(9)//'Well_no'//ACHAR(9),  &
       (comp_name(is)//ACHAR(9),is=1,ns),'pH'//ACHAR(9)//'Alkalinity'//ACHAR(9)
!!$  ! ... Write static data to file 'FUBNFR' for b.c. flow summation
!!$  WRITE(fubnfr,5001) title(1:80),title(81:160)
!!$  WRITE(fubnfr,5002) heat,solute,eeunit,cylind
!!$  WRITE(fubnfr,5003) tmunit
!!$  WRITE(fubnfr,5003) nx,ny,nz,nxy,nxyz
!!$  WRITE(fubnfr,5003) ns
  ! ... Write static data to file 'FUPZON' for a zone plot
!!$  WRITE(fupzon,5001) title(1:80),title(81:160)
!!$  5001 FORMAT(a80)
!!$  WRITE(fupzon,5002) heat,solute,eeunit,cylind
!!$  5002 FORMAT(4L5)
!!$  WRITE(fupzon,5003) nx,ny,nz,nxy,nxyz
!!$  5003 FORMAT(5I8)
END SUBROUTINE write1
