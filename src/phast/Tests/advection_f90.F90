
    
    subroutine advection_f90()
    implicit none
    INCLUDE 'RM_interface.f90.inc'
    INCLUDE 'IPhreeqc.f90.inc'
    interface
        subroutine advect_f90(c, bc_conc, ncomps, nxyz)
            implicit none
            double precision, dimension(:,:), allocatable :: bc_conc
            double precision, dimension(:,:), allocatable :: c 
            integer                                       :: ncomps, nxyz
        end subroutine advect_f90
    end interface
    
    ! Based on PHREEQC Example 11
    integer :: i, j
    integer :: nxyz
    integer :: nthreads
    integer :: id
    integer :: status
    integer :: partition_uz_solids
    double precision, dimension(:), allocatable   :: cell_vol
    double precision, dimension(:), allocatable   :: pv0
    double precision, dimension(:), allocatable   :: pv
    double precision, dimension(:), allocatable   :: sat
    integer,          dimension(:), allocatable   :: print_chemistry_mask
    integer,          dimension(:), allocatable   :: grid2chem
    character(100)                                :: string
    integer                                       :: ncomps
    character(100),   dimension(:), allocatable   :: components
    integer,          dimension(:,:), allocatable :: ic1, ic2
    double precision, dimension(:,:), allocatable :: f1
    integer                                       :: nbound
    integer,          dimension(:), allocatable   :: bc1, bc2
    double precision, dimension(:), allocatable   :: bc_f1
    double precision, dimension(:,:), allocatable :: bc_conc
    double precision, dimension(:,:), allocatable :: c
    double precision                              :: time, time_step
    double precision, dimension(:), allocatable   :: density
    double precision, dimension(:), allocatable   :: temperature
    double precision, dimension(:), allocatable   :: pressure
    integer                                       :: isteps, nsteps
    double precision, dimension(:,:), allocatable :: selected_out
    integer                                       :: col
    character(100)                                :: heading
    double precision, dimension(:), allocatable   :: tc, p_atm
    integer                                       :: iphreeqc_id
    integer                                       :: dump_on, append

    nxyz = 40
    nthreads = 2

    ! Create reaction module
    id = RM_create(nxyz, nthreads)
    status = RM_SetFilePrefix(id, "Advect_f90")
    status = RM_SetErrorHandlerMode(id, 2)
    ! Open error, log, and output files
    status = RM_OpenFiles(id)
  
    ! Set concentration units
    status = RM_SetUnitsSolution(id, 2)      ! 1, mg/L; 2, mol/L; 3, kg/kgs
    status = RM_SetUnitsPPassemblage(id, 1)  ! 1, mol/L; 2 mol/kg rock
    status = RM_SetUnitsExchange(id, 1)      ! 1, mol/L; 2 mol/kg rock
    status = RM_SetUnitsSurface(id, 1)       ! 1, mol/L; 2 mol/kg rock
    status = RM_SetUnitsGasPhase(id, 1)      ! 1, mol/L; 2 mol/kg rock
    status = RM_SetUnitsSSassemblage(id, 1)  ! 1, mol/L; 2 mol/kg rock
    status = RM_SetUnitsKinetics(id, 1)      ! 1, mol/L; 2 mol/kg rock  

    ! Set conversion from seconds to user units
    status = RM_SetTimeConversion(id, dble(1.0 / 86400.0)) ! days
    
    ! Set cell volume
    allocate(cell_vol(nxyz))
    cell_vol = 1.0
    status = RM_SetCellVolume(id, cell_vol(1))
    
    ! Set initial pore volume
    allocate(pv0(nxyz))
    pv0 = 0.2
    status = RM_SetPoreVolumeZero(id, pv0(1))
    
    ! Set current pore volume
    allocate(pv(nxyz))
    pv = 0.2
    status = RM_SetPoreVolume(id, pv(1))
    
    ! Set saturation
    allocate(sat(nxyz))
    sat = 1.0
    status = RM_SetSaturation(id, sat(1))
    
    ! Set cells to print chemistry when print chemistry is turned on
    allocate(print_chemistry_mask(nxyz))
    print_chemistry_mask = 1
    status = RM_SetPrintChemistryMask(id, print_chemistry_mask(1))
    
    ! Set printing of chemistry file to false
    status = RM_SetPrintChemistryOn(id, 0, 1, 0)  ! workers, initial_phreeqc, utility
    
    ! Partitioning of uz solids
    partition_uz_solids = 0
    status = RM_SetPartitionUZSolids(id, partition_uz_solids)

    ! For demonstation, two row, first active, second inactive
    allocate(grid2chem(nxyz))
    grid2chem = -1
    do i = 1, nxyz/2
        grid2chem(i) = i - 1
    enddo
    status = RM_CreateMapping(id, grid2chem(1))   

    ! Load database
    status = RM_LoadDatabase(id, "phreeqc.dat"); 
    
    ! Run file to define solutions and reactants for initial conditions, selected output
    ! There are three types of IPhreeqc modules in PhreeqcRM
    ! Argument 1 refers to the InitialPhreeqc module for accumulating initial and boundary conditions
    ! Argument 2 refers to the workers for doing reaction calculations for transport
    ! Argument 3 refers to a utility module
    status = RM_RunFile(id, 1, 1, 1, "advect.pqi")
 
    ! For demonstration, clear contents of workers and utility
    ! Worker initial conditions are defined below
    string = "DELETE; -all"
    status = RM_RunString(id, 1, 0, 1, string)  ! workers, initial_phreeqc, utility
 
    ! Set get list of components
    ncomps = RM_FindComponents(id)
    allocate(components(ncomps))
    do i = 1, ncomps
        status = RM_GetComponent(id, i, components(i))
    enddo
    
    ! Set array of initial conditions
    allocate(ic1(nxyz,7), ic2(nxyz,7), f1(nxyz,7))
    ic1 = -1
    ic2 = -1
    f1 = 1.0
    do i = 1, nxyz
        ic1(i,1) = 1       ! Solution 1
        ic1(i,2) = -1      ! Equilibrium phases none
        ic1(i,3) = 1       ! Exchange 1
        ic1(i,4) = -1      ! Surface none
        ic1(i,5) = -1      ! Gas phase none
        ic1(i,6) = -1      ! Solid solutions none
        ic1(i,7) = -1      ! Kinetics none
    enddo   
    status = RM_InitialPhreeqc2Module(id, ic1(1,1), ic2(1,1), f1(1,1))


    ! Get a boundary condition from initial phreeqc
    nbound = 1
    allocate(bc1(nbound), bc2(nbound), bc_f1(nbound))
    bc1 = 0           ! solution 0
    bc2 = -1          ! no mixing
    bc_f1 = 1.0       ! mixing fraction for bc1
    allocate(bc_conc(nbound, ncomps))   
    status = RM_InitialPhreeqc2Concentrations(id, bc_conc(1,1), nbound, bc1(1), bc2(1), bc_f1(1))
    
    ! Initial equilibration of cells
    time = 0.0
    time_step = 0.0
    allocate(c(nxyz, ncomps))
    status = RM_SetTime(id, time)
    status = RM_SetTimeStep(id, time_step)
    status = RM_RunCells(id) 
    status = RM_GetConcentrations(id, c(1,1))
    
    ! Transient loop
    nsteps = 10
    allocate(density(nxyz), pressure(nxyz), temperature(nxyz))
    density = 1.0
    pressure = 2.0
    temperature = 20.0
    time_step = 86400
    status = RM_SetTimeStep(id, time_step)
    do isteps = 1, nsteps
        ! Advection calculation
        call advect_f90(c, bc_conc, ncomps, nxyz)
        
        ! Send any new conditions to module
        status = RM_SetPoreVolume(id, pv(1))            ! If pore volume changes due to compressibility
        status = RM_SetSaturation(id, sat(1))           ! If saturation changes
        status = RM_SetTemperature(id, temperature(1))  ! If temperature changes
        status = RM_SetPressure(id, pressure(1))        ! If pressure changes
        status = RM_SetConcentrations(id, c(1,1))
        
        ! print at last time step
 		if (isteps == nsteps) then
            status = RM_SetPrintChemistryOn(id, 1, 0, 0)  ! workers, initial_phreeqc, utility
        else
            status = RM_SetPrintChemistryOn(id, 0, 0, 0)  ! workers, initial_phreeqc, utility
        endif
        ! Run cells with new conditions
        time = time + time_step
        status = RM_SetTime(id, time) 
        status = RM_RunCells(id)  
        status = RM_GetConcentrations(id, c(1,1))
 
        ! Print results at last time step
        if (isteps == nsteps) then
 			! Get current density
            status = RM_GetDensity(id, density(1))

			! Get double array of selected output values
            col = RM_GetSelectedOutputColumnCount(id)
            allocate(selected_out(nxyz,col))
            status = RM_GetSelectedOutput(id, selected_out(1,1))

			! Print results
            do i = 1, nxyz/2
                write(*,*) "Cell number ", i
                write(*,*) "     Density: ", density(i)
                write(*,*) "     Components: "
                do j = 1, ncomps
                    write(*,'(10x,i2,A2,A10,A2,f10.4)') j, " ",trim(components(j)), ": ", c(i,j)
                enddo
                write(*,*) "     Selected output: "
                do j = 1, col
                    status = RM_GetSelectedOutputHeading(id, j-1, heading)    
                    write(*,'(10x,i2,A2,A10,A2,f10.4)') j, " ", trim(heading),": ", selected_out(i,j)
                enddo
            enddo
            deallocate(selected_out)
        endif
    enddo
    
 	! Use utility instance of PhreeqcRM
    allocate(tc(nxyz), p_atm(nxyz))
	do i = 1, nxyz
		tc(i) = 15.0
		p_atm(i) = 3.0
	enddo
	iphreeqc_id = RM_Concentrations2Utility(id, c(1,1), nxyz, tc(1), p_atm(1))
	string = "RUN_CELLS; -cells 0-19"
	! Option 1, output goes to new file
	status = SetOutputFileName(iphreeqc_id, "utility_f90.txt")
	status = SetOutputFileOn(iphreeqc_id, .true.)
	status = RunString(iphreeqc_id, string)
	! Option 2, output goes to chem.txt file
    status = RM_SetPrintChemistryOn(id, 0, 0, 1)  ! workers, initial_phreeqc, utility
	status = RM_RunString(id, 0, 0, 1, string) 

	! Dump results   
    dump_on = 1
    append = 0
	status = RM_SetDumpFileName(id, "advection_f90.dmp.gz")    
    status = RM_DumpModule(id, dump_on, append)    ! second argument: gz disabled unless compiled with #define USE_GZ
    
    deallocate(cell_vol);
    deallocate(pv0);
    deallocate(pv);
    deallocate(sat);
    deallocate(print_chemistry_mask);
    deallocate(grid2chem);
    deallocate(components);
    deallocate(ic1);
    deallocate(ic2);
    deallocate(f1);
    deallocate(bc1);
    deallocate(bc2);
    deallocate(bc_f1);
    deallocate(bc_conc);
    deallocate(c);
    deallocate(density);
    deallocate(temperature);
    deallocate(pressure);
    deallocate(tc);
    deallocate(p_atm);
    return 
    end subroutine advection_f90

    subroutine advect_f90(c, bc_conc, ncomps, nxyz)
    implicit none
    double precision, dimension(:,:), allocatable :: bc_conc
    double precision, dimension(:,:), allocatable :: c 
    integer                                       :: ncomps, nxyz
    integer                                       :: i, j
    ! Advect
    do i = nxyz/2, 2, -1
        do j = 1, ncomps
            c(i,j) = c(i-1,j)
        enddo
    enddo
    ! Cell 1 gets boundary condition
    do j = 1, ncomps
        c(1,j) = bc_conc(1,j)
    enddo
        
    end subroutine advect_f90
    
