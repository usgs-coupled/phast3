#include <stdlib.h>
#include <string>
#include <vector>
#include "PhreeqcRM.h"

void AdvectCpp(std::vector<double> &c, std::vector<double> bc_conc, int ncomps, int nxyz, int dim);

int advection_cpp()
{
	// Based on PHREEQC Example 11

	try
	{
		int nxyz = 40;
		int nthreads = 3;
		IRM_RESULT status;

		// Create reaction module
		PhreeqcRM phreeqc_rm(nxyz, nthreads);
		status = phreeqc_rm.SetErrorHandlerMode(1);        // throw exception on error
		status = phreeqc_rm.SetFilePrefix("Advect_cpp");
		if (phreeqc_rm.GetMpiMyself() == 0)
		{
			phreeqc_rm.OpenFiles();
		}

		// Set concentration units
		status = phreeqc_rm.SetUnitsSolution(2);      // 1, mg/L; 2, mol/L; 3, kg/kgs
		status = phreeqc_rm.SetUnitsPPassemblage(1);  // 0, mol/L cell; 1, mol/L water; 2 mol/kg rock
		status = phreeqc_rm.SetUnitsExchange(1);      // 0, mol/L cell; 1, mol/L water; 2 mol/kg rock
		status = phreeqc_rm.SetUnitsSurface(1);       // 0, mol/L cell; 1, mol/L water; 2 mol/kg rock
		status = phreeqc_rm.SetUnitsGasPhase(1);      // 0, mol/L cell; 1, mol/L water; 2 mol/kg rock
		status = phreeqc_rm.SetUnitsSSassemblage(1);  // 0, mol/L cell; 1, mol/L water; 2 mol/kg rock
		status = phreeqc_rm.SetUnitsKinetics(1);      // 0, mol/L cell; 1, mol/L water; 2 mol/kg rock

		// Set conversion from seconds to user units
		double time_conversion = 1.0 / 86400;
		status = phreeqc_rm.SetTimeConversion(time_conversion);     // days

		// Set cell volume
		std::vector<double> cell_vol;
		cell_vol.resize(nxyz, 1);
		status = phreeqc_rm.SetCellVolume(cell_vol.data());

		// Set current pore volume
		std::vector<double> pv;
		pv.resize(nxyz, 0.2);
		status = phreeqc_rm.SetPoreVolume(pv.data());

		// Set saturation
		std::vector<double> sat;
		sat.resize(nxyz, 1.0);
		status = phreeqc_rm.SetSaturation(sat.data());

		// Set cells to print chemistry when print chemistry is turned on
		std::vector<int> print_chemistry_mask;
		print_chemistry_mask.resize(nxyz, 1);
		status = phreeqc_rm.SetPrintChemistryMask(print_chemistry_mask.data());

		// Partitioning of uz solids
		status = phreeqc_rm.SetPartitionUZSolids(false);

		// For demonstation, two equivalent rows by symmetry
		std::vector<int> grid2chem;
		grid2chem.resize(nxyz, -1);
		for (int i = 0; i < nxyz/2; i++)
		{
			grid2chem[i] = i;
			grid2chem[i + nxyz/2] = i;
		}
		status = phreeqc_rm.CreateMapping(grid2chem.data());

		// Set printing of chemistry file
		status = phreeqc_rm.SetPrintChemistryOn(false, true, false); // workers, initial_phreeqc, utility

		// Load database
		status = phreeqc_rm.LoadDatabase("phreeqc.dat");

		// Run file to define solutions and reactants for initial conditions, selected output
		bool workers = true;             // This is one or more IPhreeqcs for doing the reaction calculations for transport
		bool initial_phreeqc = true;     // This is an IPhreeqc for accumulating initial and boundary conditions
		bool utility = true;             // This is an extra IPhreeqc, I will use it, for example, to calculate pH in a
		// mixture for a well
		status = phreeqc_rm.RunFile(workers, initial_phreeqc, utility, "advect.pqi");

		// For demonstration, clear contents of workers and utility
		// Worker initial conditions are defined below
		initial_phreeqc = false;
		std::string input = "DELETE; -all";
		status = phreeqc_rm.RunString(workers, initial_phreeqc, utility, input.c_str());

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
		//ic1[0] = 100;
		status = phreeqc_rm.InitialPhreeqc2Module(ic1.data(), ic2.data(), f1.data());

		// Get a boundary condition
		std::vector<double> bc_conc, bc_f1;
		std::vector<int> bc1, bc2;
		int nbound = 1;
		bc1.resize(nbound, 0);                      // solution 0
		status = phreeqc_rm.InitialPhreeqc2Concentrations(bc_conc, bc1);
		//bc2.resize(nbound, -1);                   // no mixing
		//bc_f1.resize(nbound, 1.0);
		//status = phreeqc_rm.InitialPhreeqc2Concentrations(bc_conc.data(),
		//	bc1, bc2, bc_f1);

		// Initial equilibration of cells
		double time = 0.0;
		double time_step = 0.0;
		std::vector<double> c;
		c.resize(nxyz * components.size());
		status = phreeqc_rm.SetTime(time);
		status = phreeqc_rm.SetTimeStep(time_step);
		status = phreeqc_rm.RunCells();
		status = phreeqc_rm.GetConcentrations(c.data());

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
			AdvectCpp(c, bc_conc, ncomps, nxyz, nbound);

			// Send new conditions to module
			bool print_chemistry_on = (steps == nsteps - 1) ? true : false;
			status = phreeqc_rm.SetPrintChemistryOn(print_chemistry_on, false, false); // workers, initial_phreeqc, utility
			status = phreeqc_rm.SetPoreVolume(pv.data());            // If pore volume changes due to compressibility
			status = phreeqc_rm.SetSaturation(sat.data());           // If saturation changes
			status = phreeqc_rm.SetTemperature(temperature.data());  // If temperature changes
			status = phreeqc_rm.SetPressure(pressure.data());        // If pressure changes
			status = phreeqc_rm.SetConcentrations(c.data());

			// Run cells with new conditions
			time = time + time_step;
			status = phreeqc_rm.SetTime(time);
			status = phreeqc_rm.RunCells();
			status = phreeqc_rm.GetConcentrations(c.data());

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
						std::cerr << "          " << j << " " << headings[j] << ": " << so[j*nxyz + i] << "\n";
					}
				}
			}
		}
		
 		// Use utility instance of PhreeqcRM to calculate pH of a mixture
		std::vector <double> c_well;
		c_well.resize(1*ncomps, 0.0);
		for (int i = 0; i < ncomps; i++)
		{
			c_well[i] = 0.5 * c[0 + nxyz*i] + 0.5 * c[9 + nxyz*i];
		}
		std::vector<double> tc, p_atm;
		tc.resize(1, 15.0);
		p_atm.resize(1, 3.0);
		IPhreeqc * util_ptr = phreeqc_rm.Concentrations2Utility(c_well, tc, p_atm);
		input = "SELECTED_OUTPUT 5; -pH;RUN_CELLS; -cells 1";
		int iphreeqc_result;
		util_ptr->SetOutputFileName("utility_cpp.txt");
		util_ptr->SetOutputFileOn(true);
		iphreeqc_result = util_ptr->RunString(input.c_str());
		int vtype;
		double pH;
		char svalue[100];
		util_ptr->SetCurrentSelectedOutputUserNumber(5);
		iphreeqc_result = util_ptr->GetSelectedOutputValue2(1, 0, &vtype, &pH, svalue, 100);

		// Dump results
		bool dump_on = true;
		bool append = false;
		status = phreeqc_rm.SetDumpFileName("advection_cpp.dmp");
		status = phreeqc_rm.DumpModule(dump_on, append);    // gz disabled unless compiled with #define USE_GZ

		status = phreeqc_rm.CloseFiles();
	}
	catch (PhreeqcRMStop)
	{
		std::string e_string = "Advection_cpp failed with an error in PhreeqcRM.";
		std::cerr << e_string << std::endl;
		return IRM_FAIL;
	}
	catch (...)
	{
		std::string e_string = "Advection_cpp failed with an unhandled exception.";
		std::cerr << e_string << std::endl;
		return IRM_FAIL;
	}
	return EXIT_SUCCESS;
}
void
AdvectCpp(std::vector<double> &c, std::vector<double> bc_conc, int ncomps, int nxyz, int dim)
{
	for (int i = nxyz/2 - 1 ; i > 0; i--)
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
int units_tester()
{
	// Based on PHREEQC Example 11

	try
	{
		int nxyz = 3;
		int nthreads = 3;
		IRM_RESULT status;

		// Create reaction module
		PhreeqcRM phreeqc_rm(nxyz, nthreads);
		status = phreeqc_rm.SetErrorHandlerMode(1);        // throw exception on error
		status = phreeqc_rm.SetFilePrefix("Units_InitialPhreeqc_1");
		if (phreeqc_rm.GetMpiMyself() == 0)
		{
			phreeqc_rm.OpenFiles();
		}

		// Set concentration units
		status = phreeqc_rm.SetUnitsSolution(1);      // 1, mg/L; 2, mol/L; 3, kg/kgs
		status = phreeqc_rm.SetUnitsPPassemblage(2);  // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
		status = phreeqc_rm.SetUnitsExchange(1);      // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
		status = phreeqc_rm.SetUnitsSurface(1);       // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
		status = phreeqc_rm.SetUnitsGasPhase(1);      // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
		status = phreeqc_rm.SetUnitsSSassemblage(1);  // 0, mol/L cell; 1, mol/L water; 2 mol/L rock
		status = phreeqc_rm.SetUnitsKinetics(1);      // 0, mol/L cell; 1, mol/L water; 2 mol/L rock

		// Set cell volume
		std::vector<double> cell_vol;
		cell_vol.resize(nxyz, 1);
		status = phreeqc_rm.SetCellVolume(cell_vol.data());

		// Set current pore volume
		std::vector<double> pv;
		pv.resize(nxyz, 0.2);
		status = phreeqc_rm.SetPoreVolume(pv.data());

		// Set saturation
		std::vector<double> sat;
		sat.resize(nxyz, 1.0);
		status = phreeqc_rm.SetSaturation(sat.data());

		// Set printing of chemistry file
		status = phreeqc_rm.SetPrintChemistryOn(true, true, false); // workers, initial_phreeqc, utility

		// Load database
		status = phreeqc_rm.LoadDatabase("phreeqc.dat");

		// Run file to define solutions and reactants for initial conditions, selected output
		bool workers = false;             // This is one or more IPhreeqcs for doing the reaction calculations for transport
		bool initial_phreeqc = true;      // This is an IPhreeqc for accumulating initial and boundary conditions
		bool utility = false;             // This is an extra IPhreeqc, I will use it, for example, to calculate pH in a
		// mixture for a well
		status = phreeqc_rm.RunFile(workers, initial_phreeqc, utility, "units.pqi");

		status = phreeqc_rm.SetFilePrefix("Units_InitialPhreeqc_2");
		if (phreeqc_rm.GetMpiMyself() == 0)
		{
			phreeqc_rm.OpenFiles();
		}

		// Set reference to components
		int ncomps = phreeqc_rm.FindComponents();
		const std::vector<std::string> &components = phreeqc_rm.GetComponents();
		
		std::vector < int > cell_numbers;
		cell_numbers.push_back(0);
		status = phreeqc_rm.InitialPhreeqcCell2Module(1, cell_numbers);
		cell_numbers[0] = 1;
		status = phreeqc_rm.InitialPhreeqcCell2Module(2, cell_numbers);
		cell_numbers[0] = 2;
		status = phreeqc_rm.InitialPhreeqcCell2Module(3, cell_numbers);
		
		// Retrieve concentrations
		std::vector<double> c;
		c.resize(nxyz * components.size());
		status = phreeqc_rm.SetFilePrefix("Units_Worker");
		if (phreeqc_rm.GetMpiMyself() == 0)
		{
			phreeqc_rm.OpenFiles();
		}
		std::vector < int > print_mask;
		print_mask.resize(3, 1);
		phreeqc_rm.SetPrintChemistryMask(print_mask.data());
		status = phreeqc_rm.RunCells();
		status = phreeqc_rm.GetConcentrations(c.data());

		// Use utility instance of PhreeqcRM
		std::vector<double> tc, p_atm;
		tc.resize(nxyz, 25.0);
		p_atm.resize(nxyz, 1.0);
		IPhreeqc * util_ptr = phreeqc_rm.Concentrations2Utility(c, tc, p_atm);
		std::string input;
		input = "RUN_CELLS; -cells 0-2";
		// Option 1, output goes to new file
		int iphreeqc_result;
		util_ptr->SetOutputFileName("Units_utility.out");
		util_ptr->SetOutputFileOn(true);
		iphreeqc_result = util_ptr->RunString(input.c_str());
		
	}
	catch (PhreeqcRMStop)
	{
		std::string e_string = "Advection_cpp failed with an error in PhreeqcRM.";
		std::cerr << e_string << std::endl;
		return IRM_FAIL;
	}
	catch (...)
	{
		std::string e_string = "Advection_cpp failed with an unhandled exception.";
		std::cerr << e_string << std::endl;
		return IRM_FAIL;
	}
	return EXIT_SUCCESS;
}