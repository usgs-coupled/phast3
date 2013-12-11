#include <stdlib.h>
#include <string>
#include <vector>
#include "../Reaction_module.h"


void advect(std::vector<double> &c, std::vector<double> bc_conc, int ncomps, int nxyz, int dim);

int advection_example()
{
	// Based on PHREEQC Example 11


	int nxyz = 40;
	int nthreads = 2;

	// Create reaction module
	Reaction_module phreeqc_rm(&nxyz, &nthreads);
	phreeqc_rm.SetFilePrefix("Advect");
	if (phreeqc_rm.GetMpiMyself() == 0)
	{
		// error_file is stderr
		Reaction_module::GetRmIo().Set_error_ostream(&std::cerr);

		// open echo and log file, prefix.log.txt
		std::string ln = phreeqc_rm.GetFilePrefix();
		ln.append(".log.txt");
		Reaction_module::GetRmIo().log_open(ln.c_str());

		// prefix.chem.txt
		std::string cn = phreeqc_rm.GetFilePrefix();
		cn.append(".chem.txt");
		Reaction_module::GetRmIo().output_open(cn.c_str());
	}

	// Set concentration units
	phreeqc_rm.SetUnitsSolution(2);      // 1, mg/L; 2, mol/L; 3, kg/kgs
	phreeqc_rm.SetUnitsPPassemblage(1);  // 1, mol/L; 2 mol/kg rock
	phreeqc_rm.SetUnitsExchange(1);      // 1, mol/L; 2 mol/kg rock
	phreeqc_rm.SetUnitsSurface(1);       // 1, mol/L; 2 mol/kg rock
	phreeqc_rm.SetUnitsGasPhase(1);      // 1, mol/L; 2 mol/kg rock
	phreeqc_rm.SetUnitsSSassemblage(1);  // 1, mol/L; 2 mol/kg rock
	phreeqc_rm.SetUnitsKinetics(1);      // 1, mol/L; 2 mol/kg rock
	// Set conversion from seconds to user units

	double time_conversion = 1.0 / 86400;
	phreeqc_rm.SetTimeConversion(&time_conversion);     // days

	// Set cell volume
	std::vector<double> cell_vol;
	cell_vol.resize(nxyz, 1);
	phreeqc_rm.SetCellVolume(cell_vol.data());

	// Set initial pore volume
	std::vector<double> pv0;
	pv0.resize(nxyz, 0.2);
	phreeqc_rm.SetPoreVolume(pv0.data());

	// Set current pore volume
	std::vector<double> pv;
	pv.resize(nxyz, 0.2);
	phreeqc_rm.SetPoreVolume(pv.data());

	// Set saturation
	std::vector<double> sat;
	sat.resize(nxyz, 1.0);
	phreeqc_rm.SetSaturation(sat.data());

	// Set cells to print chemistry when print chemistry is turned on
	std::vector<int> print_chemistry_mask;
	print_chemistry_mask.resize(nxyz, 1);
	phreeqc_rm.SetPrintChemistryMask(print_chemistry_mask.data());

	// Set printing of chemistry file
	int print_chemistry_on = 0;
	phreeqc_rm.SetPrintChemistryOn(&print_chemistry_on);

	// Partitioning of uz solids
	int partition_uz_solids = 0;
	phreeqc_rm.SetPartitionUZSolids(&partition_uz_solids);

	// For demonstation, two row, first active, second inactive
	std::vector<int> grid2chem;
	grid2chem.resize(nxyz, -1);
	for (int i = 0; i < nxyz/2; i++)
	{ 
		grid2chem[i] = i;
	}
	phreeqc_rm.CreateMapping(grid2chem.data());

	// Load database
	phreeqc_rm.LoadDatabase("phreeqc.dat");

	// Run file to define solutions and reactants for initial conditions
	int initial_phreeqc = 1;     // This is an IPhreeqc for accumulating initial and boundary conditions
	int workers = 1;             // This is one or more IPhreeqcs for doing the reaction calculations for transport
	int utility = 1;             // This is an extra IPhreeqc, I will use it, for example, to calculate pH in a 
	                             // mixture for a well
    phreeqc_rm.RunFile(&initial_phreeqc, &workers, &utility, "advect.pqi"); 

	// For demonstration, clear contents of workers and utility
	// Worker initial conditions are defined below
	initial_phreeqc = 0;
	std::string input = "DELETE; -all";
    phreeqc_rm.RunString(&initial_phreeqc, &workers, &utility, input.c_str()); 

	// Set reference to components
	phreeqc_rm.FindComponents();
	const std::vector<std::string> &components = phreeqc_rm.GetComponents();
	int ncomps = (int) components.size();

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
	phreeqc_rm.InitialPhreeqc2Module(ic1.data(), ic2.data(), f1.data());

	// Get a boundary condition
	std::vector<double> bc_conc, bc_f1;
	std::vector<int> bc1, bc2;
	int nbound = 1;
	int dim = 2;
	bc_conc.resize(dim * components.size(), 0.0);
	bc1.resize(nbound, 0);                    // solution 0
	bc2.resize(nbound, -1);                   // no mixing
	bc_f1.resize(nbound, 1.0);
	phreeqc_rm.InitialPhreeqc2Concentrations(bc_conc.data(), &nbound, &dim, bc1.data(), bc2.data(), bc_f1.data());

	// Initial equilibration of cells
	double time = 0.0;
	double time_step = 0.0;
	std::vector<double> c;
	c.resize(nxyz * components.size());
	phreeqc_rm.SetTime(&time);
	phreeqc_rm.SetTimeStep(&time_step);
	phreeqc_rm.RunCells(); 
	phreeqc_rm.GetConcentrations(c.data());

	int nsteps = 10;

	// Transient loop
	std::vector<double> density;
	density.resize(nxyz);
	time_step = 86400.;
	phreeqc_rm.SetTimeStep(&time_step);
	for (int steps = 0; steps < nsteps; steps++)
	{
		advect(c, bc_conc, ncomps, nxyz, dim);
		phreeqc_rm.SetConcentrations(c.data());
		if (steps == nsteps -1)
		{
			print_chemistry_on = 1;
			phreeqc_rm.SetPrintChemistryOn(&print_chemistry_on);
		}
		phreeqc_rm.SetSaturation(sat.data());     // If saturation changes
		time = time + time_step;
		phreeqc_rm.SetTime(&time);
		phreeqc_rm.RunCells();
		if (print_chemistry_on != 0)
		{
			// Get current density
			std::vector<double> &density = phreeqc_rm.GetDensity();

			// Get double array of selected output values
			std::vector<double> so;
			int col = phreeqc_rm.GetSelectedOutputColumnCount();
			so.resize(nxyz*col, 0);
			phreeqc_rm.GetSelectedOutput(so.data());

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
					phreeqc_rm.GetSelectedOutputHeading(&j, headings[j]);
					std::cerr << "          " << j << " " << headings[j] << ": " << so[j*nxyz + i] << "\n";
				}
			}
		}
	}
	int dump_on = 1;
	int use_gz = 1;
	phreeqc_rm.DumpModule(&dump_on, &use_gz);   
	return EXIT_SUCCESS;
}
void
advect(std::vector<double> &c, std::vector<double> bc_conc, int ncomps, int nxyz, int dim)
{
	for (int i = nxyz - 1 ; i > 0; i--)
	{
		for (size_t j = 0; j < ncomps; j++)
		{
			c[j * nxyz + i] = c[j * nxyz + i - 1];                 // component j
		}
	}
	// Cell zero gets boundary condition
	for (size_t j = 0; j < ncomps; j++)
	{
		c[j * nxyz] = bc_conc[j * dim];                                // component j
	} 
}
