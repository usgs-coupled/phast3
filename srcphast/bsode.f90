SUBROUTINE bsode(zwr,yy,dyy,dz,yymax,yyerr,kflag,jstart)
  ! ... One step of integration of the two o.d.e.'s for the well riser
  ! ...      using a midpoint integration method with the Bulirsch-
  ! ...      Stoer rational function extrapolation method
  ! ... From Gear program p.96
  USE machine_constants, ONLY: kdp
  USE mcw
  IMPLICIT NONE
  REAL(kind=kdp), INTENT(INOUT) :: zwr
  REAL(kind=kdp), DIMENSION(2), INTENT(OUT) :: yy, dyy
  REAL(kind=kdp), INTENT(IN OUT) :: dz
  REAL(kind=kdp), DIMENSION(2), INTENT(IN OUT) :: yymax
  REAL(kind=kdp), DIMENSION(2), INTENT(OUT) :: yyerr
  INTEGER, INTENT(OUT) :: kflag
  INTEGER, INTENT(IN) :: jstart
  !
  REAL(KIND=kdp) :: a1, a2, b00, b11, dzchng, &
       fmax = 1.e7_kdp, quotsv, ta, u0, u1, za, zu
  REAL(KIND=kdp), DIMENSION(2) :: dyyn, yymxsv, yyn, yynm1, yysave
  REAL(KIND=kdp), DIMENSION(2,11) :: extrap
  REAL(KIND=kdp), DIMENSION(11,2) ::  quot = RESHAPE((/ 1._kdp, 2.25_kdp, 4._kdp, 9._kdp, &
       16._kdp, 36._kdp, 64._kdp, &
       144._kdp, 256._kdp, 576._kdp, 1024._kdp, &
       1._kdp, 1.77777777777777_kdp, 4._kdp, 7.1111111111111_kdp, 16._kdp, 28.4444444444444_kdp, &
       64._kdp, &
       113.77777777777_kdp, 256._kdp, 455.111111111111_kdp, 1024._kdp/), (/11,2/))
  REAL(KIND=kdp), DIMENSION(2,12) ::  ymaxhv, ynhv, ynm1hv
  INTEGER :: i, j, jhvsv, jhvsv1, jodd, k, l, m, m2, mnext, mtwo
  LOGICAL :: convrg
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: bsode.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  IF(jstart > 0) THEN
     yysave(1)=yy(1)
     yysave(2)=yy(2)
     yymxsv(1)=yymax(1)
     yymxsv(2)=yymax(2)
     CALL wfdydz(zwr,yy,dyyn)
  ELSE
     yy(1)=yysave(1)
     yy(2)=yysave(2)
     yymax(1)=yymxsv(1)
     yymax(2)=yymxsv(2)
  END IF
10 jhvsv1=0
  kflag=0
20 jhvsv=0
  za=zwr+dz
  jodd=1
  m=1
  mnext=2
  mtwo=3
  DO  i=1,2
     DO  j=1,maxpts
        extrap(i,j)=0.d0
     END DO
  END DO
  DO  j=1,maxpts
     quotsv=quot(j,jodd)
     quot(j,jodd)=m*m
     convrg=.true.
     IF(j <= maxord/2) convrg=.false.
     IF(j > maxord+1) THEN
        l=maxord+1
        dzchng=.7071068D0*dzchng
     ELSE
        l=j
        dzchng=1.d0+(maxord+1-j)/6.d0
     END IF
     b0=dz/m
     a2=b0*.5D0
     IF(j <= jhvsv1) THEN
        ! ... Use the values of the midpoint integration at the half way
        ! ...     point of the previous integration
        yyn(1)=ynhv(1,j)
        yyn(2)=ynhv(2,j)
        yynm1(1)=ynm1hv(1,j)
        yynm1(2)=ynm1hv(2,j)
        yymax(1)=ymaxhv(1,j)
        yymax(2)=ymaxhv(2,j)
     ELSE
        ! ... Integrate over range H by 2*M steps using midpoint method
        yynm1(1)=yysave(1)
        yynm1(2)=yysave(2)
        yyn(1)=yysave(1)+a2*dyyn(1)
        yyn(2)=yysave(2)+a2*dyyn(2)
        yymax(1)=yymxsv(1)
        yymax(2)=yymxsv(2)
        m2=m+m
        zu=zwr
        DO  k=2,m2
           zu=zu+a2
           CALL wfdydz(zu,yyn,dyy)
           u0=yynm1(1)+b0*dyy(1)
           yynm1(1)=yyn(1)
           yyn(1)=u0
           yymax(1)=MAX(yymax(1),ABS(u0))
           u0=yynm1(2)+b0*dyy(2)
           yynm1(2)=yyn(2)
           yyn(2)=u0
           yymax(2)=MAX(yymax(2),ABS(u0))
           IF(k == m.AND.jhvsv1 == 0.AND.k == 3) THEN
              jhvsv=jhvsv+1
              ynhv(1,jhvsv)=yyn(1)
              ynhv(2,jhvsv)=yyn(2)
              ynm1hv(1,jhvsv)=yynm1(1)
              ynm1hv(2,jhvsv)=yynm1(2)
              ymaxhv(1,jhvsv)=yymax(1)
              ymaxhv(2,jhvsv)=yymax(2)
           END IF
        END DO
     END IF
     CALL wfdydz(za,yyn,dyy)
     DO  i=1,2
        u1=extrap(i,1)
        ! ... Calculate the final value to be used in the extrapolation
        ta=(yyn(i)+yynm1(i)+a2*dyy(i))*.5D0
        a1=ta
        ! ... Insert the integral as the first extrapolated value
        extrap(i,1)=ta
        IF(l >= 2) THEN
           IF(ABS(u1)*fmax < ABS(a1)) GO TO 120
           ! ... Extrapolation by rational functions on the second and higher
           ! ...      intervals
           DO  k=2,l
              b1=quot(k,jodd)*u1
              b0=b1-a1
              u0=u1
              IF(ABS(b0) > 0.) THEN
                 b0=(a1-u1)/b0
                 u0=a1*b0
                 a1=b1*b0
              END IF
              u1=extrap(i,k)
              extrap(i,k)=u0
              ta=ta+u0
           END DO
        END IF
        yymax(i)=MAX(yymax(i),ABS(ta))
        yyerr(i)=ABS(yy(i)-ta)
        yy(i)=ta
        IF(yyerr(i) > epswr*yymax(i)) convrg=.false.
     END DO
     quot(j,jodd)=quotsv
     IF(convrg) GO TO 100
     jodd=3-jodd
     m=mnext
     mnext=mtwo
     mtwo=m+m
  END DO
  jhvsv1=jhvsv
90 IF(ABS(dz) <= dzmin) GO TO 110
  dz=.5*dz
  IF(ABS(dz) >= dzmin) GO TO 20
  dz=SIGN(dzmin,dz)
  GO TO 10
100 dz=dz*dzchng
  zwr=za
  RETURN
110 kflag=1
  GO TO 100
120 quot(j,jodd)=quotsv
  GO TO 90
END SUBROUTINE bsode
