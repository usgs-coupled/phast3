SUBROUTINE error4
  ! ... Error detection routine for READ2 group
  ! ... Immediately after INIT2 routine
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcch, ONLY: caprnt
  USE mcg
  USE mcg_m
  USE mcn
  USE mcv, ONLY: frac
  USE mcw
  USE mcw_m
  USE mg2_m
  IMPLICIT NONE
  INCLUDE "RM_interface.f90.inc"
  INCLUDE 'ifwr.inc'
  INTRINSIC INDEX
  CHARACTER(LEN=9) :: cibc
  CHARACTER(LEN=130) :: logline1
  INTEGER :: status
  REAL(KIND=kdp) :: cnv
  INTEGER :: a_err, da_err, i, ic, ipmz, iwel, j, k, ks, m, m1, mks, mt
  LOGICAL :: allout
  LOGICAL, DIMENSION(:), ALLOCATABLE :: inzone
  !     ------------------------------------------------------------------
  !...
  IF(ichwt) THEN
     ! ... Check input of water table elevation
     DO  m=(nz-1)*nxy+1,nxyz
        IF(hwt(m) > z(nz)+.5*(z(nz)-z(nz-1))) ierr(45)=.TRUE.
     END DO
  END IF
  DO  i=4,200
     IF(ierr(i)) errexi=.TRUE.
  END DO
  IF(errexi) GO TO 150
  IF(fresur) THEN
     ! ... Check for multiple free surfaces in unconfined region
     ! ... This would be from initial conditions
     chk_fs: DO mt=1,nxy
        m1 = mfsbc(mt)
        DO m=m1-nxy,1,-nxy
           IF(frac(m) < 1._kdp) THEN
!!              ierr(148) = .true.       !   warning not fatal error
              WRITE(logline1,'(a)') 'Multiple free surfaces in column of cells;'//  &
                   ' Check initial condition on head field.'
                    status = RM_WarningMessage(rm_id, logline1)
              EXIT chk_fs
           END IF
        END DO
     END DO chk_fs
  END IF
  ! ... Check that each active cell is in a zone
  ALLOCATE (inzone(nxyz), &
       stat = a_err)
  IF (a_err.NE.0) THEN  
     PRINT *, "Array allocation failed: error4"  
     STOP  
  ENDIF
  inzone = .FALSE.
  DO  ipmz=1,npmz
     IF(i1z(ipmz) >= i2z(ipmz) .OR. k1z(ipmz) >= k2z(ipmz)) ierr(64)= .TRUE.
     IF(.NOT.cylind .AND. j1z(ipmz) >= j2z(ipmz)) ierr(64)=.TRUE.
     IF(cylind .AND. (j1z(ipmz) > 1 .OR. j2z(ipmz) > 1)) ierr(65)= .TRUE.
     IF(i2z(ipmz) > nx .OR. j2z(ipmz) > ny .OR. k2z(ipmz) > nz) ierr(66)=.TRUE.
     DO  k=k1z(ipmz),k2z(ipmz)
        DO  j=j1z(ipmz),j2z(ipmz)
           DO  i=i1z(ipmz),i2z(ipmz)
              m=(k-1)*nxy+(j-1)*nx+i
              inzone(m) = .TRUE.
           END DO
        END DO
     END DO
  END DO
  DO  m=1,nxyz
     IF((inzone(m) .AND. ibc(m) == -1) .OR. (.NOT.inzone(m) .AND. ibc(m) /= -1)) THEN
        ierr(63) = .TRUE.
        CALL mtoijk(m,i,j,k,nx,ny)
        WRITE(logline1,9001) '** Active Cell Not In Defined Zone;'//  &
             ' Cell I,J,K:M -',i,j,k,m
9001    FORMAT(a,4I5)
        status = RM_ErrorMessage(rm_id, logline1)
     END IF
  END DO
  DEALLOCATE (inzone, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed"  
     STOP  
  ENDIF
  DO  i=4,200
     IF(ierr(i)) errexi=.TRUE.
  END DO
  IF(errexi) GO TO 150
  ! ... Check well data
  DO  iwel=1,nwel
     IF(iw(iwel) < 1.OR.iw(iwel) > nx) ierr(51)=.TRUE.
     IF(.NOT.cylind.AND.(jw(iwel) < 1.OR.jw(iwel) > ny )) ierr(51)=.TRUE.
     !         IF(LCBW(IWEL).LT.1.OR.LCTW(IWEL).GT.NZ.OR.LCBW(IWEL).GT.
     !     &        LCTW(IWEL)) IERR(52)=.TRUE.
     IF(wqmeth(iwel) > 50.OR.wqmeth(iwel) < 0) ierr(53)=.TRUE.
     ! ... Check lower well completion layer
     !         M=CELLNO(IW(IWEL),JW(IWEL),LCBW(IWEL))
     !         IF(IBC(M).EQ.-1) IERR(54)=.TRUE.
     ! ... Check against all completion layers being outside the region
     allout=.TRUE.
     DO  ks=1,nkswel(iwel)
        mks=mwel(iwel,ks)
        IF(ibc(mks) /= -1) allout=.FALSE.
     END DO
     IF (allout) ierr(55)=.TRUE.
     ! ... Check well completion factor list
     IF(wqmeth(iwel) > 0) THEN
!!$        IF(wcfu(iwel,1) <= 0.) ierr(56)=.true.
!!$        IF(wcfl(iwel,nkswel(iwel)) <= 0.) ierr(56)=.true.
        allout=.TRUE.
        DO  ks=1,nkswel(iwel)
           IF(wcfl(iwel,ks) < 0.) ierr(61)=.TRUE.
           IF(wcfu(iwel,ks) < 0.) ierr(61)=.TRUE.
           IF(wcfl(iwel,ks) > 0. .OR. wcfu(iwel,ks) > 0.) allout=.FALSE.
        END DO
        IF (allout) ierr(62)=.TRUE.
     END IF
  END DO
  ! ... Check IBC array
  DO  m=1,nxyz
     IF(ibc(m) == -1) CYCLE
     WRITE(cibc,6001) ibc(m)
6001 FORMAT(i9.9)
     ! ... Specified value b.c. and any other flow b.c.
     IF(cibc(1:1) == '1' .AND. cibc(2:3) /= '00') ierr(33)=.TRUE.
     ! ... No heat b.c.
     IF(cibc(4:6) /= '000') ierr(34)=.TRUE.
     ! ... Only specified value solute b.c.
     IF(cibc(8:9) /= '00') ierr(35)=.TRUE.
!!$     ! ... No flux on 2 or 3 faces
!!$     IF(cibc(1:3) == '222' .or. cibc(1:3) == '220' .or. cibc(1:3) == '202' .or.  &
!!$          cibc(1:3) == '022') ierr(36)=.true.
!!$     IF(cibc(1:3) == '228' .or. cibc(1:3) == '208' .or. cibc(1:3) == '028') ierr(36)=.true.
!!$     ! ... No leakage on 2 or 3 faces
!!$     IF(cibc(1:3) == '333' .or. cibc(1:3) == '330' .or. cibc(1:3) == '303' .or.  &
!!$          cibc(1:3) == '033') ierr(37)=.true.
     ! ... No river on x or y face
     IF(cibc(1:1) == '6' .OR. cibc(2:2) == '6') ierr(38)=.TRUE.
     ! ... No flux and river on x or y face
     IF(cibc(1:1) == '8' .OR. cibc(2:2) == '8') ierr(38)=.TRUE.
     ! ... Illegal b.c. code
     IF(cibc(1:1) == '4' .OR. cibc(2:2) == '4' .OR. cibc(3:3) == '4') ierr(39)=.TRUE.
! ... allow for all types of flux, leaky, river, drain to coexist on same cell face
! ...      with the segment method
!!$     IF(cibc(1:1) == '5' .or. cibc(2:2) == '5' .or. cibc(3:3) == '5') ierr(39)=.true.
!!$     IF(cibc(1:1) == '7' .or. cibc(2:2) == '7' .or. cibc(3:3) == '7') ierr(39)=.true.
!!$     IF(cibc(1:1) == '9' .or. cibc(2:2) == '9' .or. cibc(3:3) == '9') ierr(39)=.true.
     IF(cibc(7:7) > '1') ierr(39)=.TRUE.
  END DO
  ! ... Aquifer leakage b.c.
  !.... this is dormant due to river leakage possibly below top layer of
  !....       cells
  !      DO 200 L=1,NLBC
  !         M=MLBC(L)
  !         WRITE(CIBC,6001) IBC(M)
  !         IC=INDEX(CIBC(1:3),'3')
  !         IF(IC.EQ.0) IC=INDEX(CIBC(1:3),'8')
  !               IMOD = MOD(M,NXY)
  !      K = (M-IMOD)/NXY + MIN(1,IMOD)
  !         IF(IC.EQ.3.AND.K.GT.1.AND.UZELB(M).LE.0.5D0*(Z(K)+Z(K-1)))
  !     &        IERR(41)=.TRUE.
  !         IF(IC.EQ.3.AND.K.LT.NZ.AND.UZELB(M).GE.0.5D0*(Z(K+1)+Z(K)))
  !     &        IERR(41)=.TRUE.
  ! 200  CONTINUE
!!$  ! ... A.i.f. b.c.
!!$  IF(naifc > 0.AND.iaif == 0) ierr(34)=.true.
  DO  i=4,200
     IF(ierr(i)) errexi=.TRUE.
  END DO
150 CONTINUE
  DO  m=1,nxyz
     lprnt2(m) = 1
     caprnt(m) = ibc_string(m)//'  '
  END DO
  IF (prtbc) THEN
     WRITE(fulp,2001) 'Boundary-Condition Type Array',  &
          'Ss:Specified head, Specified Concentration; ',  &
          'Sa:Specified head, Associated Concentration; ',  &
          'F:Flux; L:Leaky; R:River; D:Drain; W:Well; ',  &
          'X:Inactive '
2001 FORMAT(/tr40,a/tr10,2a/tr10,2a)
     CALL prchar(2,caprnt,lprnt2,fulp,000)
  ENDIF
END SUBROUTINE error4
