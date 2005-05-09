SUBROUTINE wbcflo
  ! ... Calculates the flow rates at well bore b.c. cells
  ! ... QFLYR - the average mass flow rate over the time step
  ! ... Used with the cylindrical coordinate system with central well
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  USE mcg
  USE mcp
  USE mcs
  USE mcv
  USE mcw
  IMPLICIT NONE
  REAL(KIND=kdp) :: uqhw, uqwm
  INTEGER :: a_err, da_err, i, iis, iwel, iwfss, j, k, ks, m, nsa
  LOGICAL :: florev
  INTRINSIC INT
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: uqsw
  INTEGER, PARAMETER :: icxm=3, icxp=4, icym=2, icyp=5, iczm=1, iczp=6
  CHARACTER(LEN=130) :: logline1, logline2
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
!!$  erflg=.FALSE.
  iwel=1
  ! ... Allocate scratch space
  nsa = max(ns,1)
  ALLOCATE (uqsw(nsa), &
       stat = a_err)
  IF (a_err.NE.0) THEN  
     PRINT *, "Array allocation failed: wbcflo"  
     STOP  
  ENDIF
  DO  ks=1,nkswel(1)
     m=mwel(1,ks)
     CALL mtoijk(m,i,j,k,nx,ny)
     mimjk=ABS(cin(3,m))
     mipjk=ABS(cin(4,m))
     mijmk=ABS(cin(2,m))
     mijpk=ABS(cin(5,m))
     mijkm=ABS(cin(1,m))
     mijkp=ABS(cin(6,m))
     qflyr(iwel,ks)=vaw(icxm,k)* dp(mimjk)+vaw(icxp,k)*dp(mipjk)+vaw(icym,k)*  &
          dp(mijmk)+vaw(icyp,k)*dp(mijpk)+vaw(iczm,k)*  &
          dp(mijkm)+vaw(iczp,k)*dp(mijkp)+vaw(7,k)*dp(m)- rhsw(k)
     ! ... Convert to volumetric flow rate
     IF(qflyr(iwel,ks) < 0.) THEN
        qwlyr(iwel,ks)=qflyr(iwel,ks)/den(m)
     ELSE
        qwlyr(iwel,ks)=qflyr(iwel,ks)/denwk(iwel,ks)
     END IF
  END DO
  ! ... Sum mass, heat, and solute flow rates for the well
  ! ...      calculate enthalpy, temperature, mass fraction,
  ! ...      density profiles
  iwfss=INT(SIGN(1.d0,-qwm(1)))
  IF(ABS(qwm(1)) < 1.e-8_kdp) iwfss=0
  florev=.FALSE.
  IF(iwfss >= 0) THEN
     ! ... Production well
     uqwm=0.d0
     uqhw=0.d0
     DO  iis=1,ns
        uqsw(iis)=0.d0
     END DO
     DO  ks=1,nkswel(1)
        m=mwel(1,ks)
        CALL mtoijk(m,i,j,k,nx,ny)
        IF(qflyr(iwel,ks) <= 0.) THEN
           uqwm=uqwm-qflyr(iwel,ks)
           ! ... Production layer
           !               IF(HEAT) THEN
           !                  QHLYR(IWEL,KW)=QFLYR(IWEL,KW)*(EH(M)+CPF*DT(M))
           !                  UQHW=UQHW-QHLYR(IWEL,KW)
           !                  EHWK(IWEL,KW)=UQHW/UQWM
           !                  TWK(IWEL,KW)=TOFEP(EHWK(IWEL,KW),PWK(IWEL,KW),ERFLG)
           !               ENDIF
           DO  iis=1,ns
              qslyr(iwel,ks,iis)=qflyr(iwel,ks)*(c(m,iis)+dc(m,iis))
              uqsw(iis)=uqsw(iis)-qslyr(iwel,ks,iis)
              cwk(iwel,ks,iis)=uqsw(iis)/uqwm
           END DO
        ELSE
           ! ... Injection layer from producing well (not allowed at layer ks=1)
           uqwm=uqwm-qflyr(iwel,ks)
           !               IF(HEAT) THEN
           !                  EHWK(IWEL,KW)=EHWK(IWEL,KW-1)
           !                  QHLYR(IWEL,KW)=QFLYR(IWEL,KW)*EHWK(IWEL,KW)
           !                  UQHW=UQHW-QHLYR(IWEL,KW)
           !                  TWK(IWEL,KW)=TOFEP(EHWK(IWEL,KW),PWK(IWEL,KW),ERFLG)
           !               ENDIF
           DO  iis=1,ns
              cwk(iwel,ks,iis)=cwk(iwel,ks-1,iis)
              qslyr(iwel,ks,iis)=qflyr(iwel,ks)*cwk(iwel,ks,iis)
              uqsw(iis)=uqsw(iis)-qslyr(iwel,ks,iis)
           END DO
           denwk(iwel,ks)=den0
!!$           IF(erflg) THEN
!!$              WRITE(fuclog,9006) 'TOFEP interpolation error in WBCFLO',  &
!!$                   'Production well no. ',iwel
!!$              9006          FORMAT(tr10,2A,i4)
!!$              ierr(129)=.TRUE.
!!$              errexe=.TRUE.
!!$              RETURN
!!$           END IF
           IF(uqwm < 0.) THEN
              WRITE(logline1,9012) 'Production well no. ', IWEL, &
                   ' has down bore flow from level ',Ks + 1,' to ',Ks, &
                   '; Time plane N =',itime-1
9012          FORMAT(A,I4,A,I2,A,I2,A,I4)
              WRITE(logline2,9022) ' Flow rate =',uqwm
9022          format(A,1PG10.2)  
              call warnprt_c(logline1)
              call warnprt_c(logline2)
              WRITE(fuwel,9002) 'Production well no. ',iwel,  &
                   ' has down bore flow from level ',k+1,' to ',  &
                   k,'; Time plane N =',itime-1,'Well flow =',uqwm
9002          FORMAT(tr10,a,i4,a,i2,a,i2,a,i4/tr15,a,1PG10.2)
              florev=.TRUE.
           END IF
        END IF
     END DO
  ELSE
     ! ... Injection well
     uqwm=-qwm(iwel)
     uqhw=uqwm*ehwkt(iwel)
     DO  iis=1,ns
        uqsw(iis)=uqwm*cwkt(iwel,iis)
     END DO
     DO  ks=nkswel(1),1,-1
        m=mwel(iwel,ks)
        CALL mtoijk(m,i,j,k,nx,ny)
        IF(qflyr(iwel,ks) > 0.) THEN
           ! ... Injection layer
           IF(k == nkswel(1)) THEN
              !                  IF(HEAT) THEN
              !                     EHWK(IWEL,KS)=EHWKT(IWEL)
              !                     TWK(IWEL,KS)=TWKT(IWEL)
              !                  ENDIF
              DO  iis=1,ns
                 cwk(iwel,ks,iis)=cwkt(iwel,iis)
              END DO
           ELSE
              !                  IF(HEAT) THEN
              !                     EHWK(IWEL,KS)=EHWK(IWEL,KS+1)
              !                     TWK(IWEL,KS)=TOFEP(EHWK(IWEL,KS),PWK(IWEL,KS),ERFLG)
              !                  ENDIF
              DO  iis=1,ns
                 cwk(iwel,ks,iis)=cwk(iwel,ks+1,iis)
              END DO
           END IF
           denwk(iwel,ks)=den0
           uqwm=uqwm+qflyr(iwel,ks)
           IF(heat) qhlyr(iwel,ks)=qflyr(iwel,ks)*ehwk(iwel,ks)
           uqhw=uqhw+qhlyr(iwel,ks)
           DO  iis=1,ns
              qslyr(iwel,ks,iis)=qflyr(iwel,ks)*cwk(iwel,ks,iis)
              uqsw(iis)=uqsw(iis)+qslyr(iwel,ks,iis)
           END DO
        ELSE
           ! ... Production layer into injection well
           uqwm=uqwm+qflyr(iwel,ks)
           !               IF(HEAT) THEN
           !                  QHLYR(IWEL,KS)=QFLYR(IWEL,KS)*(EH(M)+CPF*DT(M))
           !                  UQHW=UQHW+QHLYR(IWEL,KS)
           !                  EHWK(IWEL,KS)=UQHW/UQWM
           !                  TWK(IWEL,KS)=TOFEP(EHWK(IWEL,KS),PWK(IWEL,KS),ERFLG)
           !               ENDIF
           DO  iis=1,ns
              qslyr(iwel,ks,iis)=qflyr(iwel,ks)*(c(m,iis)+dc(m,iis))
              uqsw(iis)=uqsw(iis)+qslyr(iwel,ks,iis)
              cwk(iwel,ks,iis)=uqsw(iis)/uqwm
           END DO
           denwk(iwel,ks)=den0
        END IF
!!$        IF(erflg) THEN
!!$           WRITE(fuclog,9006) 'TOFEP Interpolation Error in WBCFLO',  &
!!$                'Injection Well No. ',iwel
!!$           ierr(129)=.TRUE.
!!$           errexe=.TRUE.
!!$           RETURN
!!$        END IF
        IF(uqwm > 0.) THEN
           florev=.TRUE.
           WRITE(logline1,9012) 'Injection well no. ',iwel, &
                ' has up bore flow from level ',Ks-1,' to ',Ks, &
                '; Time plane N =',itime-1
           WRITE(logline2,9022) ' Flow rate =',uqwm
           call warnprt_c(logline1)
           call warnprt_c(logline2)
           WRITE(fuwel,9002) 'Injection Well No. ',iwel,  &
                ' has up bore flow from level ',k-1,' to ',k,  &
                '; Time plane N =',itime-1,'Well flow =',uqwm
        END IF
     END DO
  END IF
  IF(florev) THEN
     logline1 =  'Well solute concentrations may be poor approximations (WBBAL)'
     CALL errprt_c(logline1)
     WRITE(fuwel,9003) 'Well solute concentrations may be poor approximations (WBBAL)'
9003 FORMAT(tr10,a)  
  END IF
  DEALLOCATE (uqsw, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed"  
     STOP  
  ENDIF
END SUBROUTINE wbcflo
