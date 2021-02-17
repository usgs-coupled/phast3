SUBROUTINE etom1  
  ! ... Converts the input data from READ2 from U.S. customary units
  ! ...      if required
  ! ... For Phast, the main function is to convert from user input 
  ! ...     time units to S.I. time units
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg2_m
  IMPLICIT NONE
!!$  REAL(KIND=kdp) :: cnv  
  INTEGER :: i, ipmz, iwel, k, m
  !     ------------------------------------------------------------------
  !...
  ! ... Aquifer properties
  ! ...      physical, by porous media zone
  ! ... Permeability
  DO  ipmz = 1, npmz
     kxx(ipmz) = cnvl2*kxx(ipmz)
     IF(.NOT.cylind) kyy(ipmz) = cnvl2*kyy(ipmz)
     kzz(ipmz) = cnvl2*kzz(ipmz)
  END DO
  ! ... Media and fluid properties
  DO  ipmz=1,npmz  
     ! ...      Porous media compressibilities
     abpm(ipmz) = abpm(ipmz)/cnvp  
     ! ...      Dispersivities for solute
     IF(solute) THEN  
        alphl(ipmz) = cnvl*alphl(ipmz)  
        alphth(ipmz) = cnvl*alphth(ipmz)  
        alphtv(ipmz) = cnvl*alphtv(ipmz)  
     ENDIF
  END DO
  ! ...      Solute properties
  IF (solute) dm = (cnvl2/cnvtm)*dm  
  ! ...      Fluid Compresibility
  bp = bp/cnvp  
  ! ... Fluid density data
  p0 = cnvp*p0  
  t0 = cnvt1*(t0 - cnvt2)  
  denf0 = cnvd*denf0  
  IF(solute) denf1 = cnvd*denf1  
  ! ... Fluid viscosity data
  IF(visfac < 0.) visfac = cnvvs*visfac  
  ! ... Well bore model information
  IF(nwel > 0) THEN  
     ! ... Well bore location and structural data
     DO  iwel=1,nwel  
        xw(iwel) = cnvl*xw(iwel)  
        yw(iwel) = cnvl*yw(iwel)  
        zwb(iwel) = cnvl*zwb(iwel)  
        zwt(iwel) = cnvl*zwt(iwel)  
        wbod(iwel) = cnvl*wbod(iwel)  
        ! ... Well riser data for riser calculation
!!$        WRISL(IWEL) = CNVL* WRISL(IWEL)  
!!$        WRID(IWEL) = CNVL* WRID(IWEL)  
!!$        WRRUF(IWEL) = CNVL* WRRUF(IWEL)  
     END DO
     ! ... Well bore calculation information
!!$     TOLDPW = CNVP* TOLDPW  
!!$     TOLQW = CNVVF* TOLQW  
!!$     DZMIN = CNVL* DZMIN  
  ENDIF
  ! ... Boundary conditions
  ! ... Initial conditions
  paatm = cnvp*paatm  
  p0h = cnvp*p0h  
  t0h = cnvt1*(t0h - cnvt2)  
  ! ... P at a z-level for hydrostatic pressure distribution
  IF(.NOT.ichwt) THEN  
     IF(ichydp) THEN  
        zpinit = cnvl*zpinit  
        pinit = cnvp*pinit  
     ELSE
        DO m=1,nxyz  
           p(m) = cnvp*p(m)  
        END DO
     ENDIF
     ELSEIF(fresur) THEN  
     DO  m=1,nxyz  
        hwt(m) = cnvl*hwt(m)  
     END DO
  ENDIF
END SUBROUTINE etom1
