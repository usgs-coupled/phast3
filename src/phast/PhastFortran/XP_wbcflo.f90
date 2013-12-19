SUBROUTINE XP_wbcflo(xp)
  ! ... Calculates the solute flow rates at well bore b.c. cells
  ! ... QSLYR - the average solute mass flow rate over the time step
  ! ... Used with the cylindrical coordinate system with central well
!  USE machine_constants, ONLY: kdp
  USE f_units
!  USE mcc
  USE mcg
  USE mcp
  USE mcs
  USE mcv
  USE mcw
  USE XP_module, ONLY: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  REAL(KIND=kdp) :: uqhw, uqwm, uqsw
  INTEGER :: i, iwel, iwfss, j, k, ks, m
  LOGICAL :: florev
  INTRINSIC INT
  INTEGER, PARAMETER :: icxm=3, icxp=4, icym=2, icyp=5, iczm=1, iczp=6
  CHARACTER(LEN=130) :: logline1, logline2
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: XP_wbcflo.f90,v 1.1 2013/09/19 20:41:58 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  iwel=1
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
        qwlyr(iwel,ks)=qflyr(iwel,ks)/den0
     ELSE
        qwlyr(iwel,ks)=qflyr(iwel,ks)/denwk(iwel,ks)
     END IF
  END DO
  ! ... Sum mass and solute flow rates for the well
  ! ...      calculate mass fraction
  iwfss=INT(SIGN(1._kdp,-qwm(1)))
  IF(ABS(qwm(1)) < 1.e-8_kdp) iwfss=0
  florev=.FALSE.
  IF(iwfss >= 0) THEN          ! ... Production well
     uqwm=0._kdp
     uqhw=0._kdp
     uqsw=0._kdp
     DO  ks=1,nkswel(1)
        m=mwel(1,ks)
        CALL mtoijk(m,i,j,k,nx,ny)
        IF(qflyr(iwel,ks) <= 0.) THEN            ! ... Production layer
           uqwm = uqwm-qflyr(iwel,ks)
           xp%qslyr(iwel,ks)=qflyr(iwel,ks)*(xp%c_w(m)+xp%dc(m))
           uqsw = uqsw - xp%qslyr(iwel,ks)
           xp%cwk(iwel,ks)=uqsw/uqwm
        ELSE           ! ... Injection layer from producing well (not allowed at layer ks=1)
           uqwm = uqwm-qflyr(iwel,ks)
           xp%cwk(iwel,ks)=xp%cwk(iwel,ks-1)
           xp%qslyr(iwel,ks)=qflyr(iwel,ks)*xp%cwk(iwel,ks)
           uqsw=uqsw-xp%qslyr(iwel,ks)
           denwk(iwel,ks)=den0
           IF(uqwm < 0.) THEN
              WRITE(logline1,9012) 'Production well no. ', IWEL, &
                   ' has down bore flow from level ',Ks + 1,' to ',Ks, &
                   '; Time plane N =',itime-1
9012          FORMAT(A,I4,A,I2,A,I2,A,I4)
              WRITE(logline2,9022) ' Flow rate =',uqwm
9022          format(A,1PG10.2)  
!!$              status = RM_WarningMessage(rm_id, logline1)
!!$              status = RM_WarningMessage(rm_id, logline2)
              WRITE(fuwel,9002) 'Production well no. ',iwel,  &
                   ' has down bore flow from level ',k+1,' to ',  &
                   k,'; Time plane N =',itime-1,'Well flow =',uqwm
9002          FORMAT(tr10,a,i4,a,i2,a,i2,a,i4/tr15,a,1PG10.2)
              florev=.TRUE.
           END IF
        END IF
     END DO
  ELSE               ! ... Injection well
     uqwm=-qwm(iwel)
     uqhw=uqwm*ehwkt(iwel)
     uqsw=uqwm*xp%cwkt(iwel)
     DO  ks=nkswel(1),1,-1
        m=mwel(iwel,ks)
        CALL mtoijk(m,i,j,k,nx,ny)
        IF(qflyr(iwel,ks) > 0.) THEN           ! ... Injection layer
           IF(k == nkswel(1)) THEN
              xp%cwk(iwel,ks)=xp%cwkt(iwel)
           ELSE
              xp%cwk(iwel,ks)=xp%cwk(iwel,ks+1)
           END IF
           denwk(iwel,ks)=den0
           uqwm=uqwm+qflyr(iwel,ks)
           xp%qslyr(iwel,ks)=qflyr(iwel,ks)*xp%cwk(iwel,ks)
           uqsw=uqsw+xp%qslyr(iwel,ks)
        ELSE                      ! ... Production layer into injection well
           uqwm=uqwm+qflyr(iwel,ks)
           xp%qslyr(iwel,ks)=qflyr(iwel,ks)*(xp%c_w(m)+xp%dc(m))
           uqsw=uqsw+xp%qslyr(iwel,ks)
           xp%cwk(iwel,ks)=uqsw/uqwm
           denwk(iwel,ks)=den0
        END IF
        IF(uqwm > 0.) THEN
           florev=.TRUE.
           WRITE(logline1,9012) 'Injection well no. ',iwel, &
                ' has up bore flow from level ',Ks-1,' to ',Ks, &
                '; Time plane N =',itime-1
           WRITE(logline2,9022) ' Flow rate =',uqwm
!!$           status = RM_WarningMessage(rm_id, logline1)
!!$           status = RM_WarningMessage(rm_id, logline2)
           WRITE(fuwel,9002) 'Injection Well No. ',iwel,  &
                ' has up bore flow from level ',k-1,' to ',k,  &
                '; Time plane N =',itime-1,'Well flow =',uqwm
        END IF
     END DO
  END IF
  IF(florev) THEN
     logline1 =  'Well solute concentrations may be poor approximations (XP_wbcflo)'
     !**     status = RM_ErrorMessage(rm_id, logline1)
     WRITE(fuwel,9003) 'Well solute concentrations may be poor approximations (XP_wbcflo)'
9003 FORMAT(tr10,a)
  END IF
END SUBROUTINE XP_wbcflo
