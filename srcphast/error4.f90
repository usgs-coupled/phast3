SUBROUTINE error4
  ! ... Error detection routine for READ2 group
  ! ... Immediately after INIT2 routine
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  USE mct
  USE mcv, ONLY: frac
  USE mcw
  USE mg2
  INCLUDE 'ifwr.inc'
  INTRINSIC INDEX
  CHARACTER(LEN=9) :: cibc
  CHARACTER(LEN=130) :: logline1
  REAL(KIND=kdp) :: cnv
  INTEGER :: a_err, da_err, i, ic, ipmz, iwel, j, k, ks, m, m1, mks, mt
  LOGICAL :: allout
  LOGICAL, DIMENSION(:), ALLOCATABLE :: inzone
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF(ichwt) THEN
     ! ... Check input of water table elevation
     DO  m=(nz-1)*nxy+1,nxyz
        IF(hwt(m) > z(nz)+.5*(z(nz)-z(nz-1))) ierr(45)=.true.
     END DO
  END IF
  DO  i=4,200
     IF(ierr(i)) errexi=.true.
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
              CALL warnprt_c(logline1)
              EXIT chk_fs
           END IF
        END DO
     END DO chk_fs
  END IF
  ! ... Check that each active cell is in a zone
  allocate (inzone(nxyz), &
       stat = a_err)
  if (a_err.ne.0) then  
     print *, "Array allocation failed: error4"  
     stop  
  endif
  inzone = .false.
  DO  ipmz=1,npmz
     IF(i1z(ipmz) >= i2z(ipmz) .OR. k1z(ipmz) >= k2z(ipmz)) ierr(64)= .true.
     IF(.NOT.cylind .AND. j1z(ipmz) >= j2z(ipmz)) ierr(64)=.true.
     IF(cylind .AND. (j1z(ipmz) > 1 .OR. j2z(ipmz) > 1)) ierr(65)= .true.
     IF(i2z(ipmz) > nx .OR. j2z(ipmz) > ny .OR. k2z(ipmz) > nz) ierr(66)=.true.
     DO  k=k1z(ipmz),k2z(ipmz)
        DO  j=j1z(ipmz),j2z(ipmz)
           DO  i=i1z(ipmz),i2z(ipmz)
              m=(k-1)*nxy+(j-1)*nx+i
              inzone(m) = .true.
           END DO
        END DO
     END DO
  END DO
  DO  m=1,nxyz
     IF((inzone(m) .AND. ibc(m) == -1) .OR. (.NOT.inzone(m) .AND. ibc(m) /= -1)) THEN
        ierr(63) = .true.
        CALL mtoijk(m,i,j,k,nx,ny)
        WRITE(logline1,9001) '** Active Cell Not In Defined Zone;'//  &
             ' Cell I,J,K:M -',i,j,k,m
9001    FORMAT(a,4I5)
        CALL errprt_c(logline1)
     END IF
  END DO
  deallocate (inzone, &
       stat = da_err)
  if (da_err /= 0) then  
     print *, "Array deallocation failed"  
     stop  
  endif
  DO  i=4,200
     IF(ierr(i)) errexi=.true.
  END DO
  IF(errexi) GO TO 150
  ! ... Check well data
  DO  iwel=1,nwel
     IF(iw(iwel) < 1.OR.iw(iwel) > nx) ierr(51)=.true.
     IF(.NOT.cylind.AND.(jw(iwel) < 1.OR.jw(iwel) > ny )) ierr(51)=.true.
     !         IF(LCBW(IWEL).LT.1.OR.LCTW(IWEL).GT.NZ.OR.LCBW(IWEL).GT.
     !     &        LCTW(IWEL)) IERR(52)=.TRUE.
     IF(wqmeth(iwel) > 50.OR.wqmeth(iwel) < 0) ierr(53)=.true.
     ! ... Check lower well completion layer
     !         M=CELLNO(IW(IWEL),JW(IWEL),LCBW(IWEL))
     !         IF(IBC(M).EQ.-1) IERR(54)=.TRUE.
     ! ... Check against all completion layers being outside the region
     allout=.true.
     DO  ks=1,nkswel(iwel)
        mks=mwel(iwel,ks)
        IF(ibc(mks) /= -1) allout=.false.
     END DO
     IF (allout) ierr(55)=.true.
     ! ... Check well completion factor list
     IF(wqmeth(iwel) > 0) THEN
!!$        IF(wcfu(iwel,1) <= 0.) ierr(56)=.true.
!!$        IF(wcfl(iwel,nkswel(iwel)) <= 0.) ierr(56)=.true.
        allout=.true.
        DO  ks=1,nkswel(iwel)
           IF(wcfl(iwel,ks) < 0.) ierr(61)=.true.
           IF(wcfu(iwel,ks) < 0.) ierr(61)=.true.
           IF(wcfl(iwel,ks) > 0. .OR. wcfu(iwel,ks) > 0.) allout=.false.
        END DO
        IF (allout) ierr(62)=.true.
     END IF
  END DO
  ! ... Check IBC array
  DO  m=1,nxyz
     IF(ibc(m) == -1) CYCLE
     WRITE(cibc,6001) ibc(m)
6001 FORMAT(i9.9)
     ! ... Specified value b.c. and any other flow b.c.
     IF(cibc(1:1) == '1' .AND. cibc(2:3) /= '00') ierr(33)=.true.
     ! ... No heat b.c.
     IF(cibc(4:6) /= '000') ierr(34)=.true.
     ! ... Only specified value solute b.c.
     IF(cibc(8:9) /= '00') ierr(35)=.true.
     ! ... No flux on 2 or 3 faces
     IF(cibc(1:3) == '222' .or. cibc(1:3) == '220' .or. cibc(1:3) == '202' .or.  &
          cibc(1:3) == '022') ierr(36)=.true.
     IF(cibc(1:3) == '228' .or. cibc(1:3) == '208' .or. cibc(1:3) == '028') ierr(36)=.true.
     ! ... No leakage on 2 or 3 faces
     IF(cibc(1:3) == '333' .or. cibc(1:3) == '330' .or. cibc(1:3) == '303' .or.  &
          cibc(1:3) == '033') ierr(37)=.true.
     ! ... No river on x or y face
     IF(cibc(1:1) == '6' .or. cibc(2:2) == '6') ierr(38)=.true.
     ! ... No flux and river on x or y face
     IF(cibc(1:1) == '8' .or. cibc(2:2) == '8') ierr(38)=.true.
     ! ... Illegal b.c. code
     IF(cibc(1:1) == '4' .or. cibc(2:2) == '4' .or. cibc(3:3) == '4') ierr(39)=.true.
     IF(cibc(1:1) == '5' .or. cibc(2:2) == '5' .or. cibc(3:3) == '5') ierr(39)=.true.
     IF(cibc(1:1) == '7' .or. cibc(2:2) == '7' .or. cibc(3:3) == '7') ierr(39)=.true.
     IF(cibc(1:1) == '9' .or. cibc(2:2) == '9' .or. cibc(3:3) == '9') ierr(39)=.true.
     IF(cibc(7:7) > '1') ierr(39)=.true.
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
     IF(ierr(i)) errexi=.true.
  END DO
150 CONTINUE
  DO  m=1,nxyz
     lprnt2(m)=1
     aprnt2(m)=ibc(m)
  END DO
  cnv=1.d0
  if (prtbc) then
     WRITE(fulp,2001) 'Boundary Condition Index Array'
2001 FORMAT(/tr40,7A)
     CALL prntar(2,aprnt2,lprnt2,fulp,cnv,10,000)
  endif
END SUBROUTINE error4
