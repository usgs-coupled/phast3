SUBROUTINE etom1  
  ! ... Converts the input data from READ2 from U.S. customary units
  ! ...      if required
  USE mcb
  USE mcc
  USE mcg
  USE mcp
  USE mcv
  USE mcw
  USE mg2
  IMPLICIT NONE
!!$  REAL(KIND=kdp) :: cnv  
  INTEGER :: i, ipmz, iwel, k, m
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
!!$  IF(HEAT.AND.NHCBC.GT.0) THEN  
!!$     DO  K = 1, NHCN  
!!$        ZHCBC(K) = CNVL* ZHCBC(K)  
!!$     END DO
!!$     ! ... Heat conduction b.c. thermal diffusivity
!!$     ! ...   diffusivity in L^2/t
!!$     DO  M = 1, NXYZ  
!!$        UKHCBC(M) = CNVTHC* UKHCBC(M)  
!!$        UDTHHC(M) = CNVL2* UDTHHC(M)  
!!$     END DO
!!$  ENDIF
  ! ... Aquifer properties
  ! ...      physical, by porous media zone
  ! ... Permeability
  DO  IPMZ = 1, NPMZ  
     KXX(IPMZ) = CNVL2* KXX(IPMZ)  
     IF(.NOT.CYLIND) KYY(IPMZ) = CNVL2* KYY(IPMZ)  
     KZZ(IPMZ) = CNVL2* KZZ(IPMZ)  
  END DO
  ! ... Media and fluid properties
  DO  i=1,npmz  
     ! ...      Porous media compressibilities
     abpm(i) = abpm(i)/cnvp  
     ! ...      Dispersivities for solute and heat
     IF(solute .OR. heat) THEN  
        alphl(i) = cnvl*alphl(i)  
        alphth(i) = cnvl*alphth(i)  
        alphtv(i) = cnvl*alphtv(i)  
     ENDIF
!!$     ! ...      Thermal properties
!!$     IF(HEAT) THEN  
!!$        KTHXPM(I) = CNVTHC* KTHXPM(I)  
!!$        KTHYPM(I) = CNVTHC* KTHYPM(I)  
!!$        KTHZPM(I) = CNVTHC* KTHZPM(I)  
!!$        RCPPM(I) = CNVD* CNVHC* RCPPM(I)  
!!$     ENDIF
  END DO
!!$  CPF = CNVHC* CPF  
!!$  KTHF = CNVTHC* KTHF  
!!$  BT = CNVT1* BT  
  ! ...      Solute properties
  if (solute) DM = (CNVL2/ CNVTM) * DM  
  ! ...      FLUID COMPRESIBILITY
  BP = BP/ CNVP  
  ! ... Fluid density data
  P0 = CNVP* P0  
  T0 = CNVT1* (T0 - CNVT2)  
  DENF0 = CNVD* DENF0  
  IF(SOLUTE) DENF1 = CNVD* DENF1  
  ! ... Fluid viscosity data
  IF(VISFAC.LT.0.) VISFAC = CNVVS* VISFAC  
  ! ... Well bore model information
  IF(NWEL.GT.0) THEN  
     ! ... Well bore location and structural data
     DO  IWEL = 1, NWEL  
        XW(IWEL) = CNVL* XW(IWEL)  
        YW(IWEL) = CNVL* YW(IWEL)  
        ZWB(IWEL) = CNVL* ZWB(IWEL)  
        ZWT(IWEL) = CNVL* ZWT(IWEL)  
        WBOD(IWEL) = CNVL* WBOD(IWEL)  
        ! ... Well riser data for riser calculation
!        WRISL(IWEL) = CNVL* WRISL(IWEL)  
!        WRID(IWEL) = CNVL* WRID(IWEL)  
!        WRRUF(IWEL) = CNVL* WRRUF(IWEL)  
        ! ... Well riser thermal data
!!$        IF(HEAT) THEN  
!!$           ! ... Heat transfer coefficient of riser pipe,thermal diffusivity
!!$           ! ...      and thermal conductivity
!!$           ! ...      around the riser pipe, temperatures at top and bottom
!!$           ! ...      of the riser pipe
!!$           HTCWR(IWEL) = CNVHTC* HTCWR(IWEL)  
!!$           KTHWR(IWEL) = CNVTHC* KTHWR(IWEL)  
!!$           KTHAWR(IWEL) = CNVTHC* KTHAWR(IWEL)  
!!$           DTHAWR(IWEL) = CNVL2* DTHAWR(IWEL)  
!!$           TABWR(IWEL) = CNVT1* (TABWR(IWEL) - CNVT2)  
!!$           TATWR(IWEL) = CNVT1* (TATWR(IWEL) - CNVT2)  
!!$        ENDIF
     END DO
     ! ... Well bore calculation information
!!$     TOLDPW = CNVP* TOLDPW  
!!$     TOLQW = CNVVF* TOLQW  
!!$     DZMIN = CNVL* DZMIN  
  ENDIF
  ! ... Boundary conditions
!!$  IF(NAIFC.GT.0) THEN  
!!$     ! ... Aquifer influence function b.c.
!!$     IF(IAIF.EQ.2) THEN  
!!$        ! ... Carter-Tracy influence function
!!$        KOAR = CNVL2* KOAR  
!!$        ABOAR = ABOAR/ CNVP  
!!$        BOAR = CNVL* BOAR  
!!$        VISOAR = CNVVS* VISOAR  
!!$        RIOAR = CNVL* RIOAR  
!!$        VOAR = CNVL3* VOAR  
!!$        ! ... Pot aquifer influence function
!!$        ELSEIF(RDVAIF) THEN  
!!$        IF(IAIF.EQ.1) CNV = CNVL3/ CNVP  
!!$        DO  M = 1, NXYZ  
!!$           UVAIFC(M) = CNV* UVAIFC(M)  
!!$        END DO
!!$     ENDIF
!!$  ENDIF
  ! ... Initial conditions
  PAATM = CNVP* PAATM  
  P0H = CNVP* P0H  
  T0H = CNVT1* (T0H - CNVT2)  
  ! ... I.C. distributions
  ! ... P at a z-level for hydrostatic pressure distribution
  IF(.NOT.ICHWT) THEN  
     IF(ICHYDP) THEN  
        ZPINIT = CNVL* ZPINIT  
        PINIT = CNVP* PINIT  
     ELSE  
        DO M = 1, NXYZ  
           P(M) = CNVP* P(M)  
        END DO
     ENDIF
     ELSEIF(FRESUR) THEN  
     DO  M = 1, NXYZ  
        HWT(M) = CNVL* HWT(M)  
     END DO
  ENDIF
  ! ... Temperature vs. distance i.c. for heat conduction b.c.
!!$  IF(HEAT.AND.NHCBC.GT.0) THEN  
!!$     DO  I = 1, NZTPHC  
!!$        ZTHC(I) = CNVL* ZTHC(I)  
!!$        TVZHC(I) = CNVT1* (TVZHC(I) - CNVT2)  
!!$     END DO
!!$  ENDIF
!!$  IF(HEAT) THEN  
!!$     DO  M = 1, NXYZ  
!!$        T(M) = CNVT1* (T(M) - CNVT2)  
!!$     END DO
!!$  ENDIF
END SUBROUTINE etom1
