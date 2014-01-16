SUBROUTINE write3_ss_flow
  ! ... Writes well transient simulation period data as required during simulation
  ! ...      after INIT3 and ERROR3
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  USE mcc_m
  USE mcch
  USE mcch_m
  USE mcp
  USE mcp_m
  USE mcw
  USE mcw_m
  USE mg3_m
  IMPLICIT NONE
  INCLUDE "RM_interface.f90.inc"
  INCLUDE 'ifwr.inc'
  CHARACTER(LEN=11) :: blank = '           ', ucc, up1c, up2c, uqc, utc
  CHARACTER(LEN=4) :: limit
!!$  REAL(KIND=kdp), PARAMETER :: cnv = 1._kdp
  INTEGER :: iwel, ls, m
  CHARACTER(LEN=130) :: logline1, logline2, logline3, logline4
  INTEGER :: status
  !     ------------------------------------------------------------------
  !...
  ! ... Well data
  IF(nwel > 0 .AND. prtwel) THEN
     WRITE(fuwel,2009) '*** Transient Well Data ***',  &
          'Well', 'Flow Rate','Surface','Well Datum','Head', 'Injection or Limiting',  &
          'No. ','('//unitl//'^3/'//unittm//')','Head', 'Head','Limited?','Solution Index No.',  &
          '('//unitl//')','('//unitl//')','(-)',dash
     2009 FORMAT(//tr40,a/tr10,a,tr6,a,tr5,a,tr5,a,tr5,a,tr10,  &
          a/tr10,a,tr7,a,tr5,a,tr10,a,tr6,a,tr10,a/tr35,a,tr10,a,tr30,a/tr8,a90)
     DO  iwel=1,nwel
        uqc=BLANK
        IF(wqmeth(iwel) /= 20.AND.wqmeth(iwel) /= 40) WRITE(uqc,2010)(cnvl3i/cnvtmi)*qwv(iwel)
        2010    FORMAT(1PG11.4)
        up1c=BLANK
        !            IF(WQMETH(IWEL).GE.40) WRITE(UP1C,2010)
        !     &             CNVPI*(PWSURS(IWEL)/(den0*gz)+ZWT(IWEL)+riserlen)
        up2c=BLANK
        IF(wqmeth(iwel) == 20 .OR. wqmeth(iwel) == 30) &
             WRITE(up2c,2010) cnvli*(pwkt(iwel)/(den0*gz)+zwt(iwel))   !*** incorrect head
        limit='No '
        IF(wqmeth(iwel) == 30 .OR. wqmeth(iwel) == 50) limit='Yes'
        utc=BLANK
        IF(qwv(iwel) > 0. .AND. heat) WRITE(utc,2010) cnvt1i*twsrkt(iwel)+cnvt2i
        ucc=BLANK
        IF(solute) THEN
           IF(qwv(iwel) < 0.) lprnt1(1)=indx1_wel(iwel)
           IF(qwv(iwel) > 0.) lprnt1(1)=indx1_wel(iwel)
           IF(qwv(iwel) > 0. .OR. MOD(wqmeth(iwel),10) > 1) WRITE(ucc,2110) lprnt1(1)
2110       FORMAT(i4)
        END IF
        WRITE(fuwel,2011) welidno(iwel),uqc,up1c,up2c,limit,utc,ucc
2011    FORMAT(tr10,i3,3(tr5,a),a,2a)
     END DO
  END IF
     WRITE(fulp,2014) 'Automatic Time Step Control Parameters for Steady Flow',  &
       'Maximum pressure change allowed per time step'//dots,' DPTAS  ',  &
       cnvpi*dptas,'('//unitp//')',  &
       'Minimum time step required '//dots,' DTIMMN ',cnvtmi*dtimmn,'('//unittm//')',  &
       'Maximum time step allowed '//dots,' DTIMMX ',cnvtmi*dtimmx,'('//unittm//')'
     WRITE(logline1,5014) 'Automatic Time Step Control Parameters for Steady Flow'
     WRITE(logline2,5114) 'Maximum pressure change allowed per time step'//dots,  &
       ' DPTAS  ',cnvpi*dptas,'  ('//unitp//')'
     WRITE(logline3,5114) 'Minimum time step required '//dots,' DTIMMN ',  &
       cnvtmi*dtimmn,'  ('//unittm//')'
     WRITE(logline4,5114) 'Maximum time step allowed '//dots,' DTIMMX ',  &
          cnvtmi*dtimmx,'('//unittm//')'
2014 FORMAT(/tr20,a/  &
          tr10,a65,a,1PG10.2,tr2,a/tr10,a65,a,1PG10.2,tr2,a/  &
          tr10,a65,a,1PG10.2,tr2,a/tr10,a65,a,1PG10.2,tr2,a/  &
          tr10,a65,a,1PG10.2,tr2,a/tr10,a65,a,1PG10.2,tr2,a)
5014 format(a)
5114 FORMAT(a65,a,1PG10.2,a)
    status = RM_LogMessage(rm_id, logline1)
    status = RM_LogMessage(rm_id, logline2)
    status = RM_LogMessage(rm_id, logline3)
    status = RM_LogMessage(rm_id, logline4)
END SUBROUTINE write3_ss_flow
