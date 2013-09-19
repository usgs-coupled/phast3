SUBROUTINE closef
  ! ... Closes and deletes files and writes indices of time values
  ! ...      at which dependent variables have been saved
  USE f_units
  USE mcb
  USE mcb_m
  USE mcb2_m
  USE mcc
  USE mcc_m
  USE mcch
  USE mcch_m
  USE mcg
  USE mcg_m
  USE mcm
  USE mcm_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcs
  USE mcs2
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg2_m, ONLY: hdprnt, wt_elev
  IMPLICIT NONE
  !$$  INTEGER, INTENT(IN) :: mpi_myself     !*** always 0
  CHARACTER(LEN=6), DIMENSION(50) :: st
  INTEGER :: da_err, i1p, i2p, ifu, ip, izn  
  CHARACTER(LEN=130) :: logline1, logline2, logline3
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: closef.F90 7035 2012-10-25 22:33:01Z dlpark $'
  !     ------------------------------------------------------------------
  !...
  ! ... Close and delete the stripped input file
    CALL myclose(fuins, 'DELETE')
    IF(errexi) THEN
        logline1 = '          *** Simulation Aborted Due to Input Errors ***'
        logline2 = '               Please examine log file'
        CALL errprt_c(logline1)
        CALL errprt(1,200)  
        RETURN  
    ENDIF
    IF(errexe) THEN  
        logline1 = '          *** Simulation Aborted Due to Execution Errors ***'
        WRITE(logline2,3101) '               Time ..... ',cnvtmi*time,' ('//TRIM(unittm)//')'
3101    FORMAT(a,1pg12.4,a)
        CALL errprt_c(logline1)
        CALL errprt_c(logline2)
        CALL errprt(1,200)  
        RETURN  
    ENDIF
    logline1 = '            ***** Flow and Transport Simulation Completed ***** '
    WRITE(logline2,5004) '     Last time value calculated '//dots, cnvtmi* &
        time,' ('//TRIM(unittm)//')'
5004 FORMAT(a70,1pg11.4,a)  
    WRITE(logline3,5014) '     Last time step index '//dots,itime
5014 FORMAT(a70,i8)  
    DO  ifu=fup,fubcf
        WRITE(ifu,2003) TRIM(logline1)
2003    FORMAT(//TR10,A)
        WRITE(ifu,2004) TRIM(logline2)
        WRITE(ifu,2004) TRIM(logline3)
2004    FORMAT(tr10,a)  
    END DO
    WRITE(fuzf,2003) TRIM(logline1)
    WRITE(fuzf,2004) TRIM(logline2)
    WRITE(fuzf,2004) TRIM(logline3)
    CALL logprt_c(' ')
    CALL logprt_c(logline1)
    CALL logprt_c(logline2)
    CALL logprt_c(logline3)
    WRITE(fulp,2003) TRIM(logline1)
    WRITE(fulp,2004) TRIM(logline2)
    WRITE(fulp,2004) TRIM(logline3)
    IF(nmapr > 0) THEN  
        WRITE(logline1,5005) '     Number of map records written '//dots, &
            nmapr
 5005   FORMAT(A70,I8)
        CALL logprt_c(logline1)
    ENDIF

    IF(chkptd) THEN  
        IF(ABS(pricpd) > 0._kdp) THEN
            logline1 = '     Check point dump made at the following times ('//TRIM(unittm)//')'
            WRITE(FULP,2004) TRIM(logline1)
            CALL logprt_c(logline1)
            i1p = - 9  
20          i1p = i1p + 10  
            i2p = MIN(i1p+9,nrsttp)  
            WRITE(fulp,2007) (idmptm(ip), ip=i1p,i2p)  
2007        FORMAT(tr5,10i10)  
            WRITE(fulp,2008) (cnvtmi*dmptm(ip), ip = i1p, i2p)  
2008        FORMAT(tr5,10(1pg12.5)/)  
            IF(i2p.LT.nrsttp) GOTO 20  
        ENDIF
        IF(ABS(pricpd) >= timchg) THEN  
            logline1 = '     Check point dump made at last time step'
            WRITE(fulp,2009) TRIM(logline1)
2009        FORMAT(tr10,2a)  
            CALL logprt_c(logline1)
        ENDIF
        WRITE(logline1,5005) '     Number of restart time planes written '//dots,nrsttp
        WRITE(fulp,2009) TRIM(logline1)
        CALL logprt_c(logline1)
        IF(savldo) THEN  
            logline1 = '     Only the most recent dump has been saved'
            WRITE(fulp,2009) TRIM(logline1)
            CALL logprt_c(logline1)
        ENDIF
    ENDIF
    ! ... delete file 'fuplt' if no plot data written
    st(fuplt) = 'delete'  
    IF(solute .AND. ntprtem > 0) st(fuplt) = 'keep  '  
    ! ... delete file 'fuorst' if no restart records written
    st(fuorst) = 'delete'  
    IF(nrsttp > 0) st(fuorst) = 'keep  '  
    ! ... delete file 'fupmap', file 'fupmp2', and file 'fuvmap'
    ! ...      if no screen or plotter map data written
    st(fupmap) = 'delete'  
    st(fupmp2) = 'delete'  
    st(fupmp3) = 'delete'  
    st(fuvmap) = 'delete'  
    st(fuich) = 'delete'

    IF(cntmapc) st(fupmap) = 'keep  '  
    IF(prtic_maphead .OR. ABS(primaphead) > 0._kdp) THEN
        st(fupmp2) = 'keep  '  
        st(fupmp3) = 'keep  '  
    END IF
    IF(ntprmapv > 0) st(fuvmap) = 'keep  '  
    IF(prtichead) st(fuich) = 'keep  '

    ! ... close and delete file 'fupzon' if no zone map data written
    st(fupzon) = 'delete'   
    st(fulp) = 'keep  '
    st(fup) = 'delete'  
    IF(ntprp > 0) st(fup) = 'keep  '  
    st(fuwt) = 'delete'  
    IF(ntprp > 0 .AND. fresur) st(fuwt) = 'keep  '  
    st(fuc) = 'delete'  
    IF(ntprc > 0 .AND. solute) st(fuc) = 'keep  '  
    st(fuvel) = 'delete'  
    IF(ntprvel > 0) st(fuvel) = 'keep  '  
    st(fuwel) = 'delete'  
    IF(ntprwel > 0) st(fuwel) = 'keep  '  
    st(fubal) = 'delete'  
    IF(ntprgfb > 0) st(fubal) = 'keep  '  
    st(fukd) = 'delete'  
    IF(ntprkd > 0 .OR. prt_kd) st(fukd) = 'keep  '  
    st(fubcf) = 'delete'  
    IF(ntprbcf > 0) st(fubcf) = 'keep  '   
    st(fuzf) = 'delete'  
    IF(ntprzf > 0) st(fuzf) = 'keep  '  
    st(fuzf_tsv) = 'delete'  
    IF(ntprzf_tsv > 0) st(fuzf_tsv) = 'keep  '  

    IF(print_rde) CALL myclose(furde, 'keep')  
    CALL myclose(fuorst, st(fuorst))  
    CALL myclose(fulp, st(fulp))  
    CALL myclose(fup, st(fup))  
    CALL myclose(fuwt, st(fuwt))  
    CALL myclose(fuc, st(fuc))  
    CALL myclose(fuvel, st(fuvel))  
    CALL myclose(fuwel, st(fuwel))  
    CALL myclose(fubal, st(fubal))  
    CALL myclose(fukd, st(fukd))  
    CALL myclose(fubcf, st(fubcf))  
    CALL myclose(fuzf, st(fuzf))
    CALL myclose(fuzf_tsv, st(fuzf_tsv))
    CALL myclose(fuplt, st(fuplt))  
    CALL myclose(fupmap, st(fupmap))  
    CALL myclose(fupmp2, st(fupmp2))  
    CALL myclose(fupmp3, st(fupmp3))  
    CALL myclose(fuvmap, st(fuvmap))  
    CALL myclose(fuich, st(fuich))
END SUBROUTINE closef

SUBROUTINE myclose(funit, st)
  IMPLICIT NONE
  CHARACTER(LEN=*), INTENT(IN) :: st
  INTEGER, INTENT(IN) :: funit
  INTEGER :: count, ios
  !-----------------------------------------------------------------------------------
  count = 0
  ios = 1
  DO WHILE (ios > 0) 
     CLOSE(funit, STATUS=st,IOSTAT=ios)
     !$$  if (ios > 0) print *, "Retry ", count, "closing unit ", funit, " iostat ", ios, st
     count = count + 1
     IF (count > 20) EXIT
  END DO
  IF (ios > 0) THEN
     WRITE(*,*) 'ERROR: Closing funit ', funit
  ENDIF

END SUBROUTINE myclose
