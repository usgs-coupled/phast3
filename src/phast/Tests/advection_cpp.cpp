#include <stdlib.h>
#include <string>
#include <vector>
#include "PhreeqcRM.h"

void AdvectCpp(std::vector<double> &c, std::vector<double> bc_conc, int ncomps, int nxyz, int dim);
void HandleError(PhreeqcRM &rm, IRM_RESULT r, const char *str);

int AdvectionCpp()
{
	// Based on PHREEQC Example 11


	int nxyz = 40;
	int nthreads = 3;
	IRM_RESULT status;

	// Create reaction module
	PhreeqcRM phreeqc_rm(&nxyz, &nthreads);
	status = phreeqc_rm.SetFilePrefix("Advect_cpp");
	HandleError(phreeqc_rm, status, "SetFilePrefix");
	if (phreeqc_rm.GetMpiMyself() == 0)
	{
		phreeqc_rm.OpenFiles();
	}

	// Set concentration units
	status = phreeqc_rm.SetUnitsSolution(2);      // 1, mg/L; 2, mol/L; 3, kg/kgs
	HandleError(phreeqc_rm, status, "SetUnitsSolution");
	status = phreeqc_rm.SetUnitsPPassemblage(1);  // 1, mol/L; 2 mol/kg rock
	HandleError(phreeqc_rm, status, "SetUnitsPPassemblage");
	status = phreeqc_rm.SetUnitsExchange(1);      // 1, mol/L; 2 mol/kg rock
	HandleError(phreeqc_rm, status, "SetUnitsExchange");
	status = phreeqc_rm.SetUnitsSurface(1);       // 1, mol/L; 2 mol/kg rock
	HandleError(phreeqc_rm, status, "SetUnitsSurface");
	status = phreeqc_rm.SetUnitsGasPhase(1);      // 1, mol/L; 2 mol/kg rock
	HandleError(phreeqc_rm, status, "SetUnitsGasPhase");
	status = phreeqc_rm.SetUnitsSSassemblage(1);  // 1, mol/L; 2 mol/kg rock
	HandleError(phreeqc_rm, status, "SetUnitsSSassemblage");
	status = phreeqc_rm.SetUnitsKinetics(1);      // 1, mol/L; 2 mol/kg rock
	HandleError(phreeqc_rm, status, "SetUnitsKinetics");

	// Set conversion from seconds to user units
	double time_conversion = 1.0 / 86400;
	status = phreeqc_rm.SetTimeConversion(time_conversion);     // days
	HandleError(phreeqc_rm, status, "SetTimeConversion");

	// Set cell volume
	std::vector<double> cell_vol;
	cell_vol.resize(nxyz, 1);
	status = phreeqc_rm.SetCellVolume(cell_vol.data());
	HandleError(phreeqc_rm, status, "SetCellVolume");

	// Set initial pore volume
	std::vector<double> pv0;
	pv0.resize(nxyz, 0.2);
	status = phreeqc_rm.SetPoreVolumeZero(pv0.data());
	HandleError(phreeqc_rm, status, "SetPoreVolumeZero");

	// Set current pore volume
	std::vector<double> pv;
	pv.resize(nxyz, 0.2);
	status = phreeqc_rm.SetPoreVolume(pv.data());
	HandleError(phreeqc_rm, status, "SetPoreVolume");

	// Set saturation
	std::vector<double> sat;
	sat.resize(nxyz, 1.0);
	status = phreeqc_rm.SetSaturation(sat.data());
	HandleError(phreeqc_rm, status, "SetSaturation");

	// Set cells to print chemistry when print chemistry is turned on
	std::vector<int> print_chemistry_mask;
	print_chemistry_mask.resize(nxyz, 1);
	status = phreeqc_rm.SetPrintChemistryMask(print_chemistry_mask.data());
	HandleError(phreeqc_rm, status, "SetPrintChemistryMask");

	// Set printing of chemistry file
	status = phreeqc_rm.SetPrintChemistryOn(false);
	HandleError(phreeqc_rm, status, "SetPrintChemistryOn");

	// Partitioning of uz solids
	status = phreeqc_rm.SetPartitionUZSolids(false);
	HandleError(phreeqc_rm, status, "SetPartitionUZSolids");

	// For demonstation, two row, first active, second inactive
	std::vector<int> grid2chem;
	grid2chem.resize(nxyz, -1);
	for (int i = 0; i < nxyz/2; i++)
	{ 
		grid2chem[i] = i;
	}
	status = phreeqc_rm.CreateMapping(grid2chem.data());
	HandleError(phreeqc_rm, status, "CreateMapping");

	// Load database
	status = phreeqc_rm.LoadDatabase("phreeqc.dat");
	HandleError(phreeqc_rm, status, "LoadDatabase");

	// Run file to define solutions and reactants for initial conditions, selected output
	int initial_phreeqc = 1;     // This is an IPhreeqc for accumulating initial and boundary conditions
	int workers = 1;             // This is one or more IPhreeqcs for doing the reaction calculations for transport
	int utility = 1;             // This is an extra IPhreeqc, I will use it, for example, to calculate pH in a 
	                             // mixture for a well
    status = phreeqc_rm.RunFile(&initial_phreeqc, &workers, &utility, "advect.pqi"); 
	HandleError(phreeqc_rm, status, "RunFile");

	// For demonstration, clear contents of workers and utility
	// Worker initial conditions are defined below
	initial_phreeqc = 0; 
	std::string input = "DELETE; -all";
    status = phreeqc_rm.RunString(&initial_phreeqc, &workers, &utility, input.c_str()); 
	HandleError(phreeqc_rm, status, "RunString");

	// Set reference to components
	int ncomps = phreeqc_rm.FindComponents();
	const std::vector<std::string> &components = phreeqc_rm.GetComponents();

	// Set array of initial conditions
	std::vector<int> ic1, ic2;
	ic1.resize(nxyz*7, -1);
	ic2.resize(nxyz*7, -1);
	std::vector<double> f1;
	f1.resize(nxyz*7, 1.0);
	for (int i = 0; i < nxyz; i++)
	{
		ic1[i] = 1;              // Solution 1
		ic1[nxyz + i] = -1;      // Equilibrium phases none
		ic1[2*nxyz + i] = 1;     // Exchange 1
		ic1[3*nxyz + i] = -1;    // Surface none
		ic1[4*nxyz + i] = -1;    // Gas phase none
		ic1[5*nxyz + i] = -1;    // Solid solutions none
		ic1[6*nxyz + i] = -1;    // Kinetics none
	}
	ic1[0] = 100;
	status = phreeqc_rm.InitialPhreeqc2Module(ic1.data(), ic2.data(), f1.data());
	HandleError(phreeqc_rm, status, "InitialPhreeqc2Module");

	// Get a boundary condition
	std::vector<double> bc_conc, bc_f1;
	std::vector<int> bc1, bc2;
	int nbound = 1;
	int dim = 2;
	bc_conc.resize(dim * components.size(), 0.0);
	bc1.resize(nbound, 0);                    // solution 0
	bc2.resize(nbound, -1);                   // no mixing
	bc_f1.resize(nbound, 1.0);
	status = phreeqc_rm.InitialPhreeqc2Concentrations(bc_conc.data(), 
		nbound, dim, bc1.data(), bc2.data(), bc_f1.data());
	HandleError(phreeqc_rm, status, "InitialPhreeqc2Concentrations");

	// Initial equilibration of cells
	double time = 0.0;
	double time_step = 0.0;
	std::vector<double> c;
	c.resize(nxyz * components.size());
	status = phreeqc_rm.SetTime(time);
	HandleError(phreeqc_rm, status, "SetTime");
	status = phreeqc_rm.SetTimeStep(time_step);
	HandleError(phreeqc_rm, status, "SetTimeStep");
	status = phreeqc_rm.RunCells();
	HandleError(phreeqc_rm, status, "RunCells");
	status = phreeqc_rm.GetConcentrations(c.data());
	HandleError(phreeqc_rm, status, "GetConcentrations");

	int nsteps = 10;

	// Transient loop
	std::vector<double> temperature, pressure;
	temperature.resize(nxyz, 20.0);
	pressure.resize(nxyz, 2.0);

	time_step = 86400.;
	status = phreeqc_rm.SetTimeStep(time_step);
	for (int steps = 0; steps < nsteps; steps++)
	{
		// Transport calculation here
		AdvectCpp(c, bc_conc, ncomps, nxyz, dim);

		// Send new conditions to module
		bool print_chemistry_on = (steps == nsteps - 1) ? true : false;
		status = phreeqc_rm.SetPrintChemistryOn(print_chemistry_on);
		HandleError(phreeqc_rm, status, "SetPrintChemistryOn");
		status = phreeqc_rm.SetPoreVolume(pv.data());            // If pore volume changes due to compressibility
		HandleError(phreeqc_rm, status, "SetPoreVolume");
		status = phreeqc_rm.SetSaturation(sat.data());           // If saturation changes
		HandleError(phreeqc_rm, status, "SetSaturation");
		status = phreeqc_rm.SetTemperature(temperature.data());  // If temperature changes
		HandleError(phreeqc_rm, status, "SetTemperature");
		status = phreeqc_rm.SetPressure(pressure.data());        // If pressure changes
		HandleError(phreeqc_rm, status, "SetPressure");
		status = phreeqc_rm.SetConcentrations(c.data());
		HandleError(phreeqc_rm, status, "SetConcentrations");

		// Run cells with new conditions
		time = time + time_step;
		status = phreeqc_rm.SetTime(time);
		HandleError(phreeqc_rm, status, "SetTime");
		status = phreeqc_rm.RunCells();
		HandleError(phreeqc_rm, status, "RunCells");
		status = phreeqc_rm.GetConcentrations(c.data());
		HandleError(phreeqc_rm, status, "GetConcentrations");

		// Print results at last time step
		if (print_chemistry_on != 0)
		{
			// Get current density
			std::vector<double> &density = phreeqc_rm.GetDensity();

			// Get double array of selected output values
			std::vector<double> so;
			int col = phreeqc_rm.GetSelectedOutputColumnCount();
			so.resize(nxyz*col, 0);
			status = phreeqc_rm.GetSelectedOutput(so.data());
		    HandleError(phreeqc_rm, status, "GetSelectedOutput");

			// Print results
			for (int i = 0; i < nxyz/2; i++)
			{
				std::cerr << "Cell number " << i << "\n";
				std::cerr << "     Density: " << density[i] << "\n";
				std::cerr << "     Components: " << "\n";
				for (int j = 0; j < ncomps; j++)
				{
					std::cerr << "          " << j << " " << components[j] << ": " << c[j*nxyz + i] << "\n";
				}
				std::vector<std::string> headings;
				headings.resize(col);
				std::cerr << "     Selected output: " << "\n";
				for (int j = 0; j < col; j++)
				{
					status = phreeqc_rm.GetSelectedOutputHeading(&j, headings[j]);
		            HandleError(phreeqc_rm, status, "GetSelectedOutputHeading");
					std::cerr << "          " << j << " " << headings[j] << ": " << so[j*nxyz + i] << "\n";
				}
			}
		}
	}
	bool dump_on = true;
	bool use_gz = false; 
	status = phreeqc_rm.DumpModule(dump_on, use_gz);    // gz disabled unless compiled with #define USE_GZ
	HandleError(phreeqc_rm, status, "DumpModule");
	return EXIT_SUCCESS;
}
void
AdvectCpp(std::vector<double> &c, std::vector<double> bc_conc, int ncomps, int nxyz, int dim)
{
	for (int i = nxyz - 1 ; i > 0; i--)
	{
		for (int j = 0; j < ncomps; j++)
		{
			c[j * nxyz + i] = c[j * nxyz + i - 1];                 // component j
		}
	}
	// Cell zero gets boundary condition
	for (int j = 0; j < ncomps; j++)
	{
		c[j * nxyz] = bc_conc[j * dim];                                // component j
	} 
}
void
HandleError(PhreeqcRM &rm, IRM_RESULT r, const char * str = "")
{
	if (r < 0)
	{
		rm.ErrorMessage(str);
		rm.DecodeError(r);
		exit(4);
	}
}