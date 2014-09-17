
    
    subroutine advection_f90()    
    implicit none
#ifdef USE_MPI    
    INCLUDE 'mpif.h'
#endif
    INCLUDE 'RM_interface_F.f90.inc'
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
    integer :: mpi_myself
    integer :: i, j
    integer :: nxyz
    integer :: nthreads
    integer :: id
    integer :: status
    !integer :: partition_uz_solids
    double precision, dimension(:), allocatable   :: cell_vol
    double precision, dimension(:), allocatable   :: pv
    double precision, dimension(:), allocatable   :: sat
    integer,          dimension(:), allocatable   :: print_chemistry_mask
    integer,          dimension(:), allocatable   :: grid2chem
    integer                                       :: nchem
    character(100)                                :: string
    character(200)                                :: string1
    integer                                       :: ncomps, ncomps1
    character(100),   dimension(:), allocatable   :: components
    double precision, dimension(:), allocatable   :: gfw
    integer,          dimension(:,:), allocatable :: ic1, ic2
    double precision, dimension(:,:), allocatable :: f1
    integer                                       :: nbound
    integer,          dimension(:), allocatable   :: bc1, bc2
    double precision, dimension(:), allocatable   :: bc_f1
    integer,          dimension(:), allocatable   :: module_cells
    double precision, dimension(:,:), allocatable :: bc_conc
    double precision, dimension(:,:), allocatable :: c
    double precision                              :: time, time_step
    double precision, dimension(:), allocatable   :: density
    double precision, dimension(:), allocatable   :: volume
    double precision, dimension(:), allocatable   :: temperature
    double precision, dimension(:), allocatable   :: pressure
    integer                                       :: isteps, nsteps
    double precision, dimension(:,:), allocatable :: selected_out
    integer                                       :: col, isel, n_user
    character(100)                                :: heading
    double precision, dimension(:,:), allocatable :: c_well
    double precision, dimension(:), allocatable   :: tc, p_atm
    integer                                       :: vtype
    double precision                              :: pH
    character(100)                                :: svalue
    integer                                       :: iphreeqc_id, iphreeqc_id1
    integer                                       :: dump_on, append
    character(len=:), allocatable                 :: errstr
    integer                                       :: l

    nxyz = 40
#ifdef USE_MPI
	id = RM_Create(nxyz, MPI_COMM_WORLD)
    call MPI_Comm_rank(MPI_COMM_WORLD, mpi_myself, status)
	if (status .ne. MPI_SUCCESS) then
		stop "Failed to get mpi_myself"
    endif
	if (mpi_myself > 0) then
		status = RM_MpiWorker(id);
		status = RM_Destroy(id);
		return
	endif
#else
	nthreads = 3;
	id = RM_Create(nxyz, nthreads);
#endif
    status = RM_SetErrorHandlerMode(id, 2)  ! exit on error
    !status = RM_SetErrorHandlerMode(id, 0)  ! return on error
    status = RM_SetComponentH2O(id, 0)
	status = RM_SetRebalanceFraction(id, 0.5d0)
	status = RM_SetRebalanceByCell(id, 1)
    status = RM_UseSolutionDensityVolume(id, 0)
	status = RM_SetPartitionUZSolids(id, 0)
    
    status = RM_SetFilePrefix(id, "Advect_f90")
    ! Open error, log, and output files
    status = RM_OpenFiles(id)
  
    ! Set concentration units
    status = RM_SetUnitsSolution(id, 2)      ! 1, mg/L; 2, mol/L; 3, kg/kgs
    status = RM_SetUnitsPPassemblage(id, 1)  ! 0, mol/L cell; 1, mol/L water; 2 mol/L rock
    status = RM_SetUnitsExchange(id, 1)      ! 0, mol/L cell; 1, mol/L water; 2 mol/L rock
    status = RM_SetUnitsSurface(id, 1)       ! 0, mol/L cell; 1, mol/L water; 2 mol/L rock
    status = RM_SetUnitsGasPhase(id, 1)      ! 0, mol/L cell; 1, mol/L water; 2 mol/L rock
    status = RM_SetUnitsSSassemblage(id, 1)  ! 0, mol/L cell; 1, mol/L water; 2 mol/L rock
    status = RM_SetUnitsKinetics(id, 1)      ! 0, mol/L cell; 1, mol/L water; 2 mol/L rock

    ! Set conversion from seconds to user units
    status = RM_SetTimeConversion(id, dble(1.0 / 86400.0)) ! days
    
    ! Set cell volume
    allocate(cell_vol(nxyz))
    cell_vol = 1.0
    status = RM_SetCellVolume(id, cell_vol(1))
    
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
     do i = 1, nxyz/2
        print_chemistry_mask(i) = 1
        print_chemistry_mask(i+nxyz/2) = 0
    enddo   
    status = RM_SetPrintChemistryMask(id, print_chemistry_mask(1))
    
    ! Set printing of chemistry file to false
    status = RM_SetPrintChemistryOn(id, 0, 1, 0)  ! workers, initial_phreeqc, utility
    
    ! Partitioning of uz solids
    !partition_uz_solids = 0
    !status = RM_SetPartitionUZSolids(id, partition_uz_solids)

	! For demonstation, two equivalent rows by symmetry
    allocate(grid2chem(nxyz))
    do i = 1, nxyz/2
        grid2chem(i) = i - 1
        grid2chem(i+nxyz/2) = i - 1
    enddo
    status = RM_CreateMapping(id, grid2chem(1))  
    if (status < 0) status = RM_DecodeError(id, status) 
	nchem = RM_GetChemistryCellCount(id)

    ! Load database
    status = RM_LoadDatabase(id, "phreeqc.dat") 
    if (status .ne. 0) then
        l = RM_GetErrorStringLength(id)
        allocate (character(len=l) :: errstr)
        write(*,*) "Start of error string: "
        status = RM_GetErrorString(id, errstr)
        write(*,"(A)") errstr
        write(*,*) "End of error string."
        deallocate(errstr)
        status = RM_Destroy(id);
        stop
    endif 
    
    ! Run file to define solutions and reactants for initial conditions, selected output
    ! There are three types of IPhreeqc instances in PhreeqcRM
    ! Argument 1 refers to the worker IPhreeqcs for doing reaction calculations for transport
    ! Argument 2 refers to the InitialPhreeqc instance for accumulating initial and boundary conditions
    ! Argument 3 refers to the Utility instance available for processing
    status = RM_RunFile(id, 1, 1, 1, "advect.pqi")
 
    ! For demonstration, clear contents of workers and utility
    ! Worker initial conditions are defined below
    string = "DELETE; -all"
    status = RM_RunString(id, 1, 0, 1, string)  ! workers, initial_phreeqc, utility
 
    ! Get list of components, write to output file
    ncomps = RM_FindComponents(id)
    
    ! Print some of the reaction module information		
    write(string1, "(A,I)") "Number of threads:                                ", RM_GetThreadCount(id)
	status = RM_OutputMessage(id, string1)
	write(string1, "(A,I)") "Number of MPI processes:                          ", RM_GetMpiTasks(id)
	status = RM_OutputMessage(id, string1)
	write(string1, "(A,I)") "MPI task number:                                  ", RM_GetMpiMyself(id)
	status = RM_OutputMessage(id, string1)
	status = RM_GetFilePrefix(id, string)
	write(string1, "(A,A)") "File prefix:                                      ", string
	status = RM_OutputMessage(id, trim(string1))
	write(string1, "(A,I)") "Number of grid cells in the user's model:         ", RM_GetGridCellCount(id)
	status = RM_OutputMessage(id, trim(string1))
	write(string1, "(A,I)") "Number of chemistry cells in the reaction module: ", RM_GetChemistryCellCount(id)
	status = RM_OutputMessage(id, trim(string1))
	write(string1, "(A,I)") "Number of components for transport:               ", RM_GetComponentCount(id)
	status = RM_OutputMessage(id, trim(string1))
    allocate(components(ncomps))
    allocate(gfw(ncomps))
    status = RM_GetGfw(id, gfw(1))
    do i = 1, ncomps
        status = RM_GetComponent(id, i, components(i))
        write(string,"(A10, F15.4)") components(i), gfw(i)
        status = RM_OutputMessage(id, string)
    enddo
    status = RM_OutputMessage(id, " ")

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
    ! No mixing is defined, so the following is equivalent
    ! status = RM_InitialPhreeqc2Module(id, ic1(1,1))
    
    ! alternative for setting initial conditions
    ! cell number in second argument (-1 indicates last solution, 40 in this case)
    ! in advect.pqi and any reactants with the same number--
    ! Equilibrium phases, exchange, surface, gas phase, solid solution, and (or) kinetics--
    ! will be written to cells 18 and 19 (0 based)
    allocate (module_cells(2))
    module_cells(1) = 18
    module_cells(2) = 19
    status = RM_InitialPhreeqcCell2Module(id, -1, module_cells(1), 2)

    ! Get a boundary condition from initial phreeqc
    nbound = 1
    allocate(bc1(nbound), bc2(nbound), bc_f1(nbound))
    allocate(bc_conc(nbound, ncomps))  
    bc1 = 0           ! solution 0 from Initial IPhreeqc instance
    bc2 = -1          ! no bc2 solution for mixing
    bc_f1 = 1.0       ! mixing fraction for bc1 
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
    allocate(density(nxyz), pressure(nxyz), temperature(nxyz), volume(nxyz))
    volume = 1.0
    density = 1.0
    pressure = 2.0
    temperature = 20.0
    status = RM_SetDensity(id, density(1))
    status = RM_SetTemperature(id, temperature(1))
    status = RM_SetPressure(id, pressure(1))
    time_step = 86400
    status = RM_SetTimeStep(id, time_step)
    do isteps = 1, nsteps
        ! Advection calculation
		write(string, "(A32,F15.1,A)") "Beginning transport calculation ", &
              RM_GetTime(id) * RM_GetTimeConversion(id), " days"
		status = RM_LogMessage(id, string);
		status = RM_ScreenMessage(id, string)
		write(string, "(A32,F15.1,A)") "          Time step             ", &
              RM_GetTimeStep(id) * RM_GetTimeConversion(id), " days"
		status = RM_LogMessage(id, string)
		status = RM_ScreenMessage(id, string)        
        call advect_f90(c, bc_conc, ncomps, nxyz)
        
        ! Send any new conditions to module
        status = RM_SetPoreVolume(id, pv(1))               ! If pore volume changes 
        status = RM_SetSaturation(id, sat(1))              ! If saturation changes
        status = RM_SetTemperature(id, temperature(1))     ! If temperature changes
        status = RM_SetPressure(id, pressure(1))           ! If pressure changes
        status = RM_SetConcentrations(id, c(1,1))          ! Transported concentrations
        status = RM_SetTimeStep(id, time_step)             ! Time step for kinetic reactions
        time = time + time_step
        status = RM_SetTime(id, time)                      ! Current time
        
        ! print at last time step
 		if (isteps == nsteps) then
			status = RM_SetSelectedOutputOn(id, 1);        ! enable selected output
            status = RM_SetPrintChemistryOn(id, 1, 0, 0)   ! workers, initial_phreeqc, utility
        else
			status = RM_SetSelectedOutputOn(id, 0);        ! disable selected output
            status = RM_SetPrintChemistryOn(id, 0, 0, 0)   ! workers, initial_phreeqc, utility
        endif
        
        ! Run cells with new conditions
		write(string, "(A32,F15.1,A)") "Beginning reaction calculation  ", &
              time * RM_GetTimeConversion(id), " days"
		status = RM_LogMessage(id, string);
		status = RM_ScreenMessage(id, string);
        status = RM_RunCells(id)  

		! Retrieve reacted concentrations, density, volume
        status = RM_GetConcentrations(id, c(1,1))          ! Concentrations after reaction
        status = RM_GetDensity(id, density(1))             ! Density after reaction
        status = RM_GetSolutionVolume(id, volume(1))       ! Solution volume after reaction
 
        ! Print results at last time step
        if (isteps == nsteps) then
            do isel = 1, RM_GetSelectedOutputCount(id)
                n_user = RM_GetNthSelectedOutputUserNumber(id, isel)
                status = RM_SetCurrentSelectedOutputUserNumber(id, n_user)
				write(*,*) "Selected output sequence number: ", isel
				write(*,*) "Selected output user number:     ", n_user
                col = RM_GetSelectedOutputColumnCount(id)
                allocate(selected_out(nxyz,col))
                status = RM_GetSelectedOutput(id, selected_out(1,1))
                ! Print results
                do i = 1, RM_GetSelectedOutputRowCount(id)/2
                    write(*,*) "Cell number ", i
                    write(*,*) "     Density: ", density(i)
                    write(*,*) "     Volume: ", volume(i)
                    write(*,*) "     Components: "
                    do j = 1, ncomps
                        write(*,'(10x,i2,A2,A10,A2,f10.4)') j, " ",trim(components(j)), ": ", c(i,j)
                    enddo
                    write(*,*) "     Selected output: "
                    do j = 1, col
                        status = RM_GetSelectedOutputHeading(id, j, heading)    
                        write(*,'(10x,i2,A2,A10,A2,f10.4)') j, " ", trim(heading),": ", selected_out(i,j)
                    enddo
                enddo
                deallocate(selected_out)
            enddo
        endif
    enddo
    
 	! Use utility instance of PhreeqcRM to calculate pH of a mixture
    allocate (c_well(1,ncomps))
    do i = 1, ncomps
        c_well(1,i) = 0.5 * c(1,i) + 0.5 * c(10,i)
    enddo
    allocate(tc(1), p_atm(1))
	tc(1) = 15.0
	p_atm(1) = 3.0
	iphreeqc_id = RM_Concentrations2Utility(id, c_well(1,1), 1, tc(1), p_atm(1))
	string = "SELECTED_OUTPUT 5; -pH;RUN_CELLS; -cells 1"
	! Alternatively, utility pointer is worker number nthreads + 1 
	iphreeqc_id1 = RM_GetIPhreeqcId(id, RM_GetThreadCount(id) + 1)
	status = SetOutputFileName(iphreeqc_id, "utility_f90.txt")
	status = SetOutputFileOn(iphreeqc_id, .true.)
	status = RunString(iphreeqc_id, string)
	if (status .ne. 0) status = RM_Abort(id, status, "IPhreeqc RunString failed");
	status = SetCurrentSelectedOutputUserNumber(iphreeqc_id, 5);
    status = GetSelectedOutputValue(iphreeqc_id, 1, 1, vtype, pH, svalue)

	! Dump results   
	status = RM_SetDumpFileName(id, "advection_f90.dmp.gz")  
    dump_on = 1
    append = 0  
    status = RM_DumpModule(id, dump_on, append)    
    
    ! Clean up
	status = RM_CloseFiles(id)
	status = RM_MpiWorkerBreak(id)
	status = RM_Destroy(id)
    deallocate(cell_vol);
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
    deallocate(c_well);
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
    
