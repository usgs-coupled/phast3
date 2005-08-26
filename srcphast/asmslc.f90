SUBROUTINE asmslc  
  !.....Performs the assembly and solution of the concentration from the
  !.....     solute transport equations for each component
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  USE mcch
  USE mcg
  USE mcm
  USE mcs
  USE mcs2
  USE mcv
  USE mcw
  IMPLICIT NONE
  INTERFACE
     SUBROUTINE rowscale(nrow,norm,a,diag,ierr)
       USE machine_constants, ONLY: kdp
       IMPLICIT NONE
       INTEGER, INTENT(IN) :: nrow
       INTEGER, INTENT(IN) :: norm
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: a
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: diag
       INTEGER, INTENT(OUT) :: ierr
     END SUBROUTINE rowscale

     SUBROUTINE colscale(nrow,norm,a,ci,diag,ierr)
       USE machine_constants, ONLY: kdp
       IMPLICIT NONE
       INTEGER, INTENT(IN) :: nrow  
       INTEGER, INTENT(IN) :: norm  
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: a    
       INTEGER, DIMENSION(:,:), INTENT(IN) :: ci 
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: diag
       INTEGER, INTENT(OUT) :: ierr
     END SUBROUTINE colscale

     SUBROUTINE gcgris(ap,bp,ra,rr,ss,xx,w,z,sumfil)
       USE machine_constants, ONLY: kdp
       REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT) :: ap
       REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT) :: bp
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN OUT) :: ra
       REAL(kind=kdp), DIMENSION(:), INTENT(IN OUT) :: rr
       REAL(kind=kdp), DIMENSION(:), INTENT(IN OUT) :: ss, w, z
       REAL(kind=kdp), DIMENSION(:), INTENT(INOUT) :: sumfil
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: xx
!!$       REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: xx, sumfil
     END SUBROUTINE gcgris

     SUBROUTINE tfrds(diagra,envlra,envura)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: diagra, envlra, envura
     END SUBROUTINE tfrds
  END INTERFACE
  !
  INTEGER :: m, ma, norm, iierr  
!!$  INTEGER :: iic, iii, jjj, jjjd, nnn
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  ! ... Assemble and solve the transport equation for each component
  IF (ERREXE) RETURN
  logline1 =  '     Beginning solute-transport calculation.'
  WRITE(*,'(a)') TRIM(logline1)
  CALL logprt_c(logline1)
  dc = 0._kdp
  ieq = 3  
  DO is=1,ns  
     logline1 =  '          '//comp_name(is)
     WRITE(*,'(a)') TRIM(logline1)
     CALL logprt_c(logline1)
     itrn = 0  
30   itrn = itrn + 1
     CALL asembl  
     CALL aplbci
!!$  !*****special output for solver testing
!!$      open(60,file='vaph.dat')
!!$      write(60,*) 'unscaled matrices  ', 'component:',is
!!$      nnn=0
!!$      do iii=1,nxyz 
!!$         do iic=1,6 
!!$            jjj = ci(iic,iii)
!!$            IF(ABS(va(iic,iii)) > 0._kdp .and. jjj > 0  &
!!$                 .and. jjj <= nxyz) THEN
!!$               nnn = nnn+1
!!$               write(60,*) iii, jjj, va(iic,iii)
!!$            END IF
!!$         end do
!!$         nnn = nnn+1
!!$         iic = 7
!!$         write(60,*) iii, iii, va(iic,iii)
!!$      end do
!!$            write(60,'(1pg25.15)')  (rhs(iii),iii=1,nxyz)
!!$            write(60,*) nnn, nxyz
        CLOSE(60)
!!$  !*****end special output
     ! ... Scale the matrix equations
!!$  *****      col_scale = .false.
     norm = 0          ! ... use L-infinity norm
     IF(row_scale) CALL rowscale(nxyz,norm,va,diagr,iierr)
     IF(col_scale) CALL colscale(nxyz,norm,va,ci,diagc,iierr)
     IF(iierr /= 0) THEN
        WRITE(fuclog,*) 'Error in scaling: ', iierr
!!        ierr(81) = .TRUE.
        RETURN
     END IF
     IF(col_scale) THEN
        IF(MINVAL(diagc) /= 1._kdp .AND. MAXVAL(diagc) /= 1._kdp)  &
             ident_diagc = .FALSE.
     END IF
     IF(row_scale) THEN
        DO ma=1,nxyz
           rhs(ma) = diagr(ma)*rhs(ma)
        END DO
     END IF
!!$  !*****special output for solver testing
      OPEN(60,file='vaph.dat')
!!$      write(60,*) 
!!$      write(60,*) 'scaled matrices  ', 'component:',is
!!$      nnn=0
!!$      do iii=1,nxyz 
!!$         do iic=1,6 
!!$            jjj = ci(iic,iii)
!!$            IF(ABS(va(iic,iii)) > 0._kdp .and. jjj > 0  &
!!$                 .and. jjj <= nxyz) THEN
!!$               nnn = nnn+1
!!$               write(60,*) iii, jjj, va(iic,iii)
!!$            END IF
!!$         end do
!!$         nnn = nnn+1
!!$         iic = 7
!!$         write(60,*) iii, iii, va(iic,iii)
!!$      end do
!!$            write(60,'(1pg25.15)')  (rhs(iii),iii=1,nxyz)
!!$            write(60,*) nnn, nxyz
!!$        close(60)
!!$  !*****end special output
     ! ... Solve the matrix equations
     IF(slmeth == 1) THEN  
        ! ... Direct solver
        CALL tfrds(diagra, envlra, envura)  
     ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN  
        ! ... Generalized conjugate gradient iterative solver on reduced matrix
        CALL gcgris(ap, bbp, ra, rr, sss, xx, ww, zz, sumfil)
     ENDIF
     IF(errexe) RETURN  
     ! ... Solute equation for one component has just been solved
     dcmax(is) = 0._kdp
     ! ... Descale the solution vector
     IF(col_scale) THEN
        DO ma=1,nxyz
           rhs(ma) = diagc(ma)*rhs(ma)
        END DO
     END IF
     ! ... Extract the solution from the solution vector
     DO  m=1,nxyz  
        ma = mrno(m)  
        dc(m,is) = rhs(ma)  
        IF(frac(m) > 0.) dcmax(is) = MAX(dcmax(is),ABS(dc(m,is)))
     END DO
     ! ... If adjustable time step, check for unacceptable time step length
     ! *** only fixed time steps for solute in Phast
!!$     IF(autots .AND. jtime > 2) THEN  
!!$        ! ... If DC is too large, abort the P,T,C iteration and reduce the time step
!!$        IF(ABS(dcmax(is)) > 1.5*dctas(is)) THEN  
!!$           tsfail = .TRUE.
!!$           RETURN
!!$        ENDIF
!!$     ENDIF
     ! ... Do a second solute transport for explicit cross-derivative fluxes
     IF(crosd .AND. itrn < 2) GOTO 30  
  END DO
END SUBROUTINE asmslc
