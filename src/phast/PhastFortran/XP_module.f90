MODULE XP_module
  ! ... Storage for transport calculation in a derived type
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE

  ! ... Type definition
  TYPE :: Transporter

     ! ... MODULE mcb_w       
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: csbc, cfbc, clbc, crbc,  &
          cfbc_n, clbc_n, crbc_n,  &
          qsflx, qsflx_n
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: sfvlb

     ! ... MODULE mcch_w
     ! ... character strings for output
     CHARACTER(LEN=30) :: comp_name

     ! ... MODULE mcm_w
     ! ... matrix of difference equations information
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: rhssbc
     REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: vassbc
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: rs, rs1

     ! ... MODULE mcv_w
     ! ... dependent variable information
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: dc
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: c_w
     INTEGER :: is, iis_no
     INTEGER :: ns=0
     REAL(KIND=kdp) :: stotsi, stotsp, stsfbc, stslbc, stsrbc, stsdbc

     ! ... MODULE mcw_w
     ! ... well information
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
          stfwi, sthwi, stfwp, sthwp, tqwsi, tqwsp, u10
     REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: qslyr, qslyr_n
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: qsw
     REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: cwk
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: cwkt, cwkts
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: stswi, stswp

     ! extra storage for threading

     ! ... MODULE mcb
     INTEGER, DIMENSION(:), ALLOCATABLE ::  &
       mlbc, mrbc, leak_seg_m, river_seg_m, drain_seg_m

     ! ... MODULE mcc
     INTEGER :: ntsfal, ieq, itrn
     LOGICAL :: svbc

     ! ... MODULE mcm
     REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: rhs
     REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: va
     REAL(KIND=kdp) :: c11, c12, c13, c21, c22, c23, c24, c31, c32, c33, c34, c35, cfp, csp, &
       efp, esp
     REAL(KIND=kdp), DIMENSION(:), POINTER :: rhs_r, rhs_b !, rhsbcv
     !REAL(KIND=kdp), DIMENSION(:,:), POINTER :: vasbcv

     ! ... MODULE mcp
     ! ... parameter information
    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
          tfx, tfy, tfz,  &
          tsx, tsxy, tsxz, tsy, tsyx, tsyz, tsz, tszx, tszy 
    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: &
          sxx, syy, szz, vxx, vyy, vzz
    REAL(KIND=kdp) :: t0h

    ! ... MODULE mcs
    ! ... equation solver information
    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: diagc, diagr

    ! ... MODULE mcs2
    ! ... equation solver information
    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: diagra, envlra, envura, rr, sss, ww, xx, zz, &
        sumfil
    REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: ap, bbp, ra

    ! ... MODULE mcw
    REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE ::  &
        qflyr, qwlyr, dqwdpl, pwk
    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
        qwv, qwm, pwkt, tfw, wrangl, wrid
    REAL(KIND=kdp) :: twrend, pwrend, p00, t00, dengl, wridt, gcosth, qwr, eod, &
        dtadzw, dzmin, tambi

    LOGICAL :: cwatch, wrcalc

  END TYPE Transporter
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=85), PRIVATE :: ident_string=  &
       '$RCSfile: XP_module.f90,v $//$Revision: 1.1 $//$Date: 2013/09/19 20:41:58 $'
  TYPE (Transporter), DIMENSION(:), ALLOCATABLE :: xp_list

CONTAINS
SUBROUTINE XP_init_thread(xp)
    USE mcb
    USE mcc
    USE mcg
    USE mcm
    USE mcp
    USE mcs
    USE mcs2
    USE mcw
    IMPLICIT NONE
    INTEGER a_err;
    TYPE (Transporter) :: xp

    ! ... MODULE mcb
    !INTEGER, DIMENSION(:), ALLOCATABLE ::  &
    !  mlbc, mrbc, leak_seg_m, river_seg_m, drain_seg_m
    if (nlbc > 0) then
        ALLOCATE (xp%mlbc(nlbc_seg), &
            xp%leak_seg_m(nlbc), &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array allocation failed: XP_init_thread"  
            STOP  
        ENDIF 
        xp%mlbc = mlbc
        xp%leak_seg_m = leak_seg_m
    endif
    if (nrbc > 0) then
        ALLOCATE (xp%mrbc(nrbc_seg), &
            xp%river_seg_m(nrbc), &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array allocation failed: XP_init_thread"  
            STOP  
        ENDIF 
        xp%mrbc = mrbc
        xp%river_seg_m = river_seg_m
    endif
    if (ndbc > 0) then
        ALLOCATE (xp%drain_seg_m(ndbc), &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array allocation failed: XP_init_thread"  
            STOP  
        ENDIF 
        xp%drain_seg_m = drain_seg_m
    endif
    ! ... MODULE mcc
    !INTEGER :: ntsfal, ieq, itrn
    !LOGICAL :: svbc
    xp%ntsfal = ntsfal
    xp%ieq = ieq
    xp%itrn = itrn
    xp%svbc = svbc

    ! ... MODULE mcm
!    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE, TARGET :: rhs
!    REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: va
!    REAL(KIND=kdp) :: c11, c12, c13, c21, c22, c23, c24, c31, c32, c33, c34, c35, cfp, csp, &
!    efp, esp
    ALLOCATE (xp%rhs(nxyz), &
        xp%va(7,nxyz), &
        STAT = a_err)
    IF (a_err /= 0) THEN
        PRINT *, "Array allocation failed: XP_init_thread"  
        STOP  
    ENDIF 
    !xp%rhs	  =   rhs
    !xp%va	  =   va	
    xp%c11	  =   c11
    xp%c12	  =   c12
    xp%c13	  =   c13
    xp%c21	  =   c21
    xp%c22	  =   c22
    xp%c23	  =   c23
    xp%c24	  =   c24
    xp%c31	  =   c31
    xp%c32	  =   c32
    xp%c33	  =   c33
    xp%c34	  =   c34
    xp%c35	  =   c35
    xp%cfp	  =   cfp
    xp%csp	  =   csp
    xp%efp	  =   efp
    xp%esp	  =   esp

    ! ... MODULE mcp
    ! ... parameter information
!    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
!        tfx, tfy, tfz,  &
!        tsx, tsxy, tsxz, tsy, tsyx, tsyz, tsz, tszx, tszy 
!    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: &
!        sxx, syy, szz, vxx, vyy, vzz
!    REAL(KIND=kdp) :: t0h

    ALLOCATE (xp%tfx(nxyz), xp%tfy(nxyz), xp%tfz(nxyz), &
        xp%tsx(nxyz), xp%tsy(nxyz), xp%tsz(nxyz), xp%tsxy(nxyz), xp%tsxz(nxyz), xp%tsyx(nxyz), xp%tsyz(nxyz),  &
        xp%tszx(nxyz), xp%tszy(nxyz),  &
        xp%sxx(nxyz), xp%syy(nxyz), xp%szz(nxyz), xp%vxx(nxyz), xp%vyy(nxyz), xp%vzz(nxyz),  &
        STAT = a_err)
    IF (a_err /= 0) THEN
        PRINT *, "Array allocation failed: XP_init_thread"  
        STOP  
    ENDIF
    xp%tfx = tfx
    xp%tfy = tfy
    xp%tfz = tfz
    xp%t0h = t0h

    ! ... MODULE mcs
    ! ... equation solver information
    !REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: diagc, diagr
    ALLOCATE(xp%diagc(nxyz), xp%diagr(nxyz),  &
        STAT = a_err)
    IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: XP_init_thread"
        STOP
    ENDIF
    xp%diagc = diagc
    xp%diagr = diagr


    !MODULE mcs2
    ! ... equation solver data arrays
    IF(slmeth == 1) THEN
        ! ... allocate space for the solver: mcs2
        ALLOCATE(xp%diagra(nbn), xp%envlra(ipenv(nbn+1)), xp%envura(ipenv(nbn+1)),  &
            STAT = a_err)
        IF (a_err /= 0) THEN  
            PRINT *, "array allocation failed: XP_init_thread"
            STOP
        ENDIF
        xp%diagra = diagra
        xp%envlra = envlra
        xp%envura = envura
    ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN
        ! ... allocate space for the solver: mcs2
        ALLOCATE(xp%ap(nrn,0:nsdr), xp%bbp(nbn,0:nsdr), xp%ra(lrcgd1,nbn), xp%rr(nrn), xp%sss(nbn),  &
            xp%xx(nxyz), xp%ww(nrn), xp%zz(nbn), xp%sumfil(nbn),  &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "array allocation failed: XP_init_thread"
            STOP
        ENDIF
        xp%ap      = ap
        xp%bbp     = bbp
        xp%ra      = ra
        xp%rr      = rr
        xp%sss     = sss
        xp%xx      = xx
        xp%ww      = ww
        xp%zz      = zz
        xp%sumfil  = sumfil
    ENDIF


    ! ... MODULE mcw
!    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
!        qflyr, qwlyr, dqwdpl, pwk, qwv, qwm, pwkt, tfw
!    REAL(KIND=kdp) :: twrend, pwrend, p00, t00, dengl
!    LOGICAL :: wrcalc
    if (nwel > 0) then
        ALLOCATE (xp%qflyr(nwel,nz),  &
            xp%qwlyr(nwel,nz), xp%dqwdpl(nwel,nz), &
            xp%pwk(nwel,nz), xp%qwm(nwel), xp%qwv(nwel), xp%pwkt(nwel), xp%tfw(nz), &
            xp%wrangl(nwel), &
            xp%wrid(nwel), &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array allocation failed: XP_init_thread"  
            STOP  
        ENDIF
        xp%qflyr    =	 qflyr 
        xp%qwlyr    =	 qwlyr 
        xp%dqwdpl   =	 dqwdpl
        xp%pwk      =	 pwk   
        xp%qwm      =	 qwm   
        xp%qwv      =	 qwv   
        xp%pwkt     =	 pwkt  
        xp%tfw      =	 tfw
        xp%wrangl   = wrangl
        xp%wrid     = wrid
        xp%twrend   =	 twrend
        xp%pwrend   =	 pwrend
        xp%p00      =	 p00   
        xp%t00      =	 t00   
        xp%dengl    = dengl
        xp%wridt    = wridt
        xp%gcosth   =     gcosth
        xp%qwr      =     qwr
        xp%eod      =     eod
        xp%dtadzw   =     dtadzw
        xp%dzmin    =     dzmin
        xp%tambi    =     tambi
        xp%cwatch   =     cwatch
        xp%wrcalc   =     wrcalc
    endif
END SUBROUTINE XP_init_thread
SUBROUTINE XP_free_thread(xp)
    USE mcb
    USE mcc
    USE mcg
    USE mcm
    USE mcp
    USE mcs
    USE mcw
    IMPLICIT NONE
    INTEGER a_err;
    TYPE (Transporter) :: xp

    ! ... MODULE mcb
    !INTEGER, DIMENSION(:), ALLOCATABLE ::  &
    !  mlbc, mrbc, leak_seg_m, river_seg_m, drain_seg_m
    if (nlbc > 0) then
        DEALLOCATE (xp%mlbc, &
            xp%leak_seg_m, &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array deallocation failed: XP_free_thread 1"  
            STOP  
        ENDIF 
    endif
    if (nrbc > 0) then
        DEALLOCATE (xp%mrbc, &
            xp%river_seg_m, &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array deallocation failed: XP_free_thread 2"  
            STOP  
        ENDIF 
    endif
    if (ndbc > 0) then
        DEALLOCATE ( xp%drain_seg_m, &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array deallocation failed: XP_free_thread 3"  
            STOP  
        ENDIF 
    endif
    ! ... MODULE mcc
    !INTEGER :: ntsfal, ieq, itrn
    !LOGICAL :: svbc


    ! ... MODULE mcm
!    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE, TARGET :: rhs
!    REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: va
!    REAL(KIND=kdp) :: c11, c12, c13, c21, c22, c23, c24, c31, c32, c33, c34, c35, cfp, csp, &
!    efp, esp
    DEALLOCATE (xp%rhs, &
        xp%va, &
        STAT = a_err)
    IF (a_err /= 0) THEN
        PRINT *, "Array deallocation failed: XP_free_thread 4"  
        STOP  
    ENDIF 

    ! ... MODULE mcp
    ! ... parameter information
!    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
!        tfx, tfy, tfz,  &
!        tsx, tsxy, tsxz, tsy, tsyx, tsyz, tsz, tszx, tszy 
!    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: &
!        sxx, syy, szz, vxx, vyy, vzz
!    REAL(KIND=kdp) :: t0h

    DEALLOCATE (xp%tfx, xp%tfy, xp%tfz, &
        xp%tsx, xp%tsy, xp%tsz, xp%tsxy, xp%tsxz, xp%tsyx, xp%tsyz,  &
        xp%tszx, xp%tszy,  &
        xp%sxx, xp%syy, xp%szz, xp%vxx, xp%vyy, xp%vzz,  &
        STAT = a_err)
    IF (a_err /= 0) THEN
        PRINT *, "Array deallocation failed: XP_free_thread 5"  
        STOP  
    ENDIF
    ! ... MODULE mcs
    ! ... equation solver information
    !REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: diagc, diagr
    DEALLOCATE(xp%diagc, xp%diagr,  &
        STAT = a_err)
    IF (a_err /= 0) THEN  
        PRINT *, "array deallocation failed: XP_free_thread 6"
        STOP
    ENDIF

    !MODULE mcs2
    ! ... equation solver data arrays
    IF(slmeth == 1) THEN
        ! ... allocate space for the solver: mcs2
        DEALLOCATE(xp%diagra, xp%envlra, xp%envura,  &
            STAT = a_err)
        IF (a_err /= 0) THEN  
            PRINT *, "array deallocation failed: XP_free_thread 7"
            STOP
        ENDIF
    ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN
        ! ... allocate space for the solver: mcs2
        DEALLOCATE(xp%ap, xp%bbp, xp%ra, xp%rr, xp%sss,  &
            xp%xx, xp%ww, xp%zz, xp%sumfil,  &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "array deallocation failed: XP_free_thread 8"
            STOP
        ENDIF
    ENDIF

    ! ... MODULE mcw
!    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
!        qflyr, qwlyr, dqwdpl, pwk, qwv, qwm, pwkt, tfw
!    REAL(KIND=kdp) :: twrend, pwrend, p00, t00, dengl
!    LOGICAL :: wrcalc
    if (nwel > 0) then
        DEALLOCATE (xp%qflyr,  &
            xp%qwlyr, xp%dqwdpl, &
            xp%pwk, xp%qwm, xp%qwv, xp%pwkt, xp%tfw, &
            xp%wrangl, &
            xp%wrid, &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array deallocation failed: XP_free_thread 9"  
            STOP  
        ENDIF
    endif
END SUBROUTINE XP_free_thread

  SUBROUTINE XP_create(xp, iis)
    ! ... Allocates and initializes the components of a derived type structure
    USE mcch, ONLY: comp_name              ! ... get sizes from modules
    USE mcg, ONLY: nxyz, nx, ny, nz
    USE mcw, ONLY: nwel
    USE mcb, ONLY: nsbc, nsbc_seg, nfbc_seg, nlbc, nlbc_seg, nrbc_seg
    IMPLICIT NONE
    TYPE (Transporter), INTENT(INOUT) :: xp
    INTEGER :: a_err
    LOGICAL :: init_zero = .TRUE.
    INTEGER :: iis
    !--------------------------------------------------------------------------
    IF (nxyz < 8) STOP "Incorrect grid in XP_create."
    ! ... init1_xfer
    ! ...      component arrays
    ALLOCATE (xp%dc(0:nxyz), xp%c_w(nxyz),  &
         STAT = a_err)
    IF (a_err /= 0) THEN
       PRINT *, "Array allocation failed: XP_create, point 1"  
       STOP
    ENDIF
    IF (init_zero) THEN
       xp%dc = 0
       xp%c_w = 0
    ENDIF

    ! ... Allocate matrix of difference equations arrays: mcm
    ALLOCATE (xp%rs(nxyz),  &
         STAT = a_err)
    IF (a_err /= 0) THEN
       PRINT *, "Array allocation failed: XP_create, point 2"  
       STOP
    ENDIF
    IF (init_zero) THEN 
       xp%rs = 0
    ENDIF

    ! ... Read2_xfer 
    IF (nsbc_seg > 0) THEN         
       ! ... Allocate specified value b.c. arrays: mcb and mcb_w
       ALLOCATE (xp%csbc(nsbc_seg),  &
            STAT = a_err)
       IF (a_err /= 0) THEN  
          PRINT *, "Array allocation failed: XP_create, point 3"
          STOP
       ENDIF
       IF (init_zero) THEN
          xp%csbc = 0
       ENDIF
    ENDIF
    IF (nfbc_seg > 0) THEN 
       ! ... Allocate specified flux b.c. arrays: mcb and mcb_w
       ALLOCATE (xp%qsflx(nfbc_seg), xp%qsflx_n(nfbc_seg),  &
            xp%cfbc(nfbc_seg), xp%cfbc_n(nfbc_seg),  &
            STAT = a_err)
       IF (a_err /= 0) THEN
          PRINT *, "Array allocation failed: XP_create, point 4"
          STOP
       ENDIF
       IF (init_zero) THEN
          xp%qsflx = 0
          xp%qsflx_n = 0
          xp%cfbc = 0
          xp%cfbc_n = 0
       ENDIF
    ENDIF
    IF (nlbc_seg > 0) THEN 
       ! ... Allocate leakage b.c. arrays: mcb and mcb_w
       ALLOCATE (xp%clbc(nlbc_seg), xp%clbc_n(nlbc_seg),  &
            STAT = a_err)
       IF (a_err /= 0) THEN  
          PRINT *, "Array allocation failed: XP_create, point 5"
          STOP
       ENDIF
       IF (init_zero) THEN
          xp%clbc = 0
          xp%clbc_n = 0
       ENDIF
    ENDIF
    IF (nrbc_seg > 0) THEN
       ! ... Allocate river leakage b.c. arrays: mcb and mcb_w
       ALLOCATE (xp%crbc(nrbc_seg), xp%crbc_n(nrbc_seg),  &
            STAT = a_err)
       IF (a_err /= 0) THEN  
          PRINT *, "Array allocation failed: XP_create, point 6"
          STOP
       ENDIF
       IF (init_zero) THEN
          xp%crbc = 0
          xp%crbc_n = 0
       ENDIF
    ENDIF
!!$    ! ... Allocate component label array: mcch_w
!!$    !       ALLOCATE (xp%comp_name(xp%ns),  &
!!$    !            STAT = a_err)
!!$    !       IF (a_err /= 0) THEN  
!!$    !          PRINT *, "Array allocation failed: XP_create, point 6.1"
!!$    !          STOP
!!$    !       ENDIF
    ! ... init2_1_xfer 
    IF (nwel > 0) THEN
       ! ... Allocate more well arrays: mcw_w
       ALLOCATE (xp%qslyr(nwel,nz), xp%qslyr_n(nwel,nz), xp%qsw(nwel),  &
            xp%cwk(nwel,nz), xp%cwkt(nwel), xp%cwkts(nwel),  &
            xp%stfwi(nwel), xp%sthwi(1), xp%stswi(nwel),  &
            xp%stfwp(nwel), xp%sthwp(1), xp%stswp(nwel),  &
            STAT = a_err)
       IF (a_err /= 0) THEN  
          PRINT *, "Array allocation failed: XP_create, point 7"
          STOP  
       ENDIF
       IF (init_zero) THEN
          xp%qslyr = 0._kdp
          xp%qslyr_n = 0._kdp
          xp%qsw = 0._kdp
          xp%cwk = 0._kdp
          xp%cwkt = 0._kdp
          xp%cwkts = 0._kdp
          xp%stfwi = 0._kdp
          xp%sthwi = 0._kdp
          xp%stswi = 0._kdp
          xp%stfwp = 0._kdp
          xp%sthwp = 0._kdp
          xp%stswp = 0._kdp
       ENDIF
    ENDIF
    IF (nsbc > 0) THEN
       ! ... Allocate difference equations arrays: mcm_w
       ALLOCATE (xp%vassbc(7,nsbc), xp%rhssbc(nsbc),  &
            STAT = a_err)
       IF (a_err /= 0) THEN  
          PRINT *, "Array allocation failed: XP_create, point 8"  
          STOP
       ENDIF
       IF (init_zero) THEN
          xp%vassbc = 0
          xp%rhssbc = 0
       ENDIF
    ENDIF
    IF (nlbc > 0) THEN
       ! ... Allocate leakage b.c. arrays: mcb_m
       ALLOCATE (xp%sfvlb(nlbc),  &
            STAT = a_err)
       IF (a_err /= 0) THEN  
          PRINT *, "Array allocation failed: XP_create, point 9" 
          STOP
       ENDIF
       IF (init_zero) THEN
          xp%sfvlb = 0
       ENDIF
    ENDIF

    ! ... Set name and number
    xp%iis_no = iis
    xp%comp_name = comp_name(iis)
  END SUBROUTINE XP_create

  SUBROUTINE XP_destroy(xp)
    ! ... Deletes a derived type
    USE mcc, ONLY: mpi_myself
    USE mcg, ONLY: nxyz, nx, ny, nz              ! ... get sizes from modules
    USE mcw, ONLY: nwel
    USE mcb, ONLY: nsbc, nsbc_seg, nfbc_seg, nlbc, nlbc_seg, nrbc_seg
    IMPLICIT NONE
    TYPE (Transporter), INTENT(INOUT) :: xp
    INTEGER :: da_err
    !------------------------------------------------------------------------------
    ! ... init1_xfer    
    ! ...      component arrays    
    DEALLOCATE (xp%dc, xp%c_w,  &
         STAT = da_err)
    IF (da_err /= 0) THEN
       PRINT *, "Array deallocation failed: XP_destroy, point 1"  
       STOP
    ENDIF
    ! ... Allocate matrix of difference equations arrays: mcm
    DEALLOCATE (xp%rs,  &
         STAT = da_err)
    IF (da_err /= 0) THEN
       PRINT *, "Array deallocation failed: XP_destroy, point 2"  
       STOP
    ENDIF

    ! ... Read2_xfer 
    IF (nsbc_seg > 0) THEN         
       ! ... Allocate specified value b.c. arrays: mcb and mcb_w
       DEALLOCATE (xp%csbc, &
            STAT = da_err)
       IF (da_err /= 0) THEN  
          PRINT *, "Array deallocation failed: XP_destroy, point 3"
          STOP
       ENDIF
    ENDIF
    IF (nfbc_seg > 0) THEN 
       ! ... Allocate specified flux b.c. arrays: mcb and mcb_w
       DEALLOCATE (xp%qsflx, xp%qsflx_n, xp%cfbc, xp%cfbc_n,  &
            STAT = da_err)
       IF (da_err /= 0) THEN
          PRINT *, "Array deallocation failed: XP_destroy, point 4"
          STOP
       ENDIF
    ENDIF
    IF (nlbc_seg > 0) THEN 
       ! ... Allocate leakage b.c. arrays: mcb and mcb_w
       DEALLOCATE (xp%clbc, xp%clbc_n,  &
            STAT = da_err)
       IF (da_err /= 0) THEN  
          PRINT *, "Array deallocation failed: XP_destroy, point 5"
          STOP
       ENDIF
    ENDIF
    IF (nrbc_seg > 0) THEN
       ! ... Allocate river leakage b.c. arrays: mcb and mcb_w
       DEALLOCATE (xp%crbc, xp%crbc_n,  &
            STAT = da_err)
       IF (da_err /= 0) THEN  
          PRINT *, "Array deallocation failed: XP_destroy, point 6"
          STOP
       ENDIF
    ENDIF
    ! ... init2_1_xfer 
    IF (nwel > 0) THEN
       ! ... Allocate more well arrays: mcw_w
       DEALLOCATE (xp%qslyr, xp%qslyr_n, xp%qsw,  &
            xp%cwk, xp%cwkt, xp%cwkts,  &
            xp%stfwi, xp%sthwi, xp%stswi,  &
            xp%stfwp, xp%sthwp, xp%stswp,  &
            STAT = da_err)
       IF (da_err /= 0) THEN  
          PRINT *, "Array deallocation failed: XP_destroy, point 7"
          STOP  
       ENDIF
    ENDIF
    IF (nsbc > 0) THEN
       ! ... Allocate difference equations arrays: mcm_w
       DEALLOCATE (xp%vassbc, xp%rhssbc,  &
            STAT = da_err)
       IF (da_err /= 0) THEN  
          PRINT *, "Array deallocation failed: XP_destroy, point 8"  
          STOP
       ENDIF
    ENDIF
    IF (nlbc > 0) THEN
       ! ... Allocate leakage b.c. arrays: mcb_m
       DEALLOCATE (xp%sfvlb, &
            STAT = da_err)
       IF (da_err /= 0) THEN  
          PRINT *, "Array deallocation failed: XP_destroy, point 9 " 
          STOP 
       ENDIF
    ENDIF
  END SUBROUTINE XP_destroy

END MODULE XP_module

SUBROUTINE create_transporters
! ... Allocates and initializes an xp derived type
  USE mcc            ! ... Get sizes from modules
  USE mcv
  USE XP_module, only: xp_list, XP_create
  IMPLICIT NONE
  INTEGER :: a_err, i
  !     ------------------------------------------------------------------
  IF (solute) THEN
     IF (local_ns > 0) THEN
        ALLOCATE (xp_list(local_ns),  &
             STAT = a_err)
        IF (a_err /= 0) THEN
           PRINT *, "Array allocation failed: transporters_create"  
           STOP
        ENDIF

        DO i = 1, ns
           IF (local_component_map(i) > 0) THEN
              CALL XP_create(xp_list(local_component_map(i)), i)
           ENDIF
        ENDDO
     ENDIF
  ENDIF
END SUBROUTINE create_transporters
