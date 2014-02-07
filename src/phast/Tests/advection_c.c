#include <malloc.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "RM_interface_C.h"
#include "IPhreeqc.h"

void advect_c(double *c, double *bc_conc, int ncomps, int nxyz, int dim);

    void advection_c()
	{
		// Based on PHREEQC Example 11
		int i, j;
		int nxyz; 
		int nthreads;
		int id;
		int status;
		double * cell_vol;
		double * pv0;
		double * pv;
		double * sat;
		int * print_chemistry_mask;
		int * grid2chem;
		char str[100] ;
		int ncomps;
		char ** components;
		int * ic1; 
		int * ic2;
		double * f1;
		int nbound;
		int * bc1;
		int * bc2;
		double * bc_f1;
		double * bc_conc;
		double * c;
		double time, time_step;
		double * density;
		double * temperature;
		double * pressure;
		int isteps, nsteps;
		double * selected_out;
		int col;
		char heading[100];
		double * tc;
		double * p_atm;
		int iphreeqc_id;
		int dump_on, append;

		nxyz = 40;
		nthreads = 2;
		id = RM_Create(nxyz, nthreads);
		status = RM_SetErrorHandlerMode(id, 2);
		status = RM_SetFilePrefix(id, "Advect_c");

		// Open error, log, and output files
		status = RM_OpenFiles(id);

		// Set concentration units
		status = RM_SetUnitsSolution(id, 2);      // 1, mg/L; 2, mol/L; 3, kg/kgs
		status = RM_SetUnitsPPassemblage(id, 1);  // 1, mol/L; 2 mol/kg rock
		status = RM_SetUnitsExchange(id, 1);      // 1, mol/L; 2 mol/kg rock
		status = RM_SetUnitsSurface(id, 1);       // 1, mol/L; 2 mol/kg rock
		status = RM_SetUnitsGasPhase(id, 1);      // 1, mol/L; 2 mol/kg rock
		status = RM_SetUnitsSSassemblage(id, 1);  // 1, mol/L; 2 mol/kg rock
		status = RM_SetUnitsKinetics(id, 1);      // 1, mol/L; 2 mol/kg rock  

		// Set conversion from seconds to user units
		status = RM_SetTimeConversion(id, 1.0 / 86400.0); // days

		// Set cell volume
		cell_vol = (double *) malloc((size_t) (nxyz * sizeof(double)));
		for (i = 0; i < nxyz; i++) cell_vol[i] = 1.0;
		status = RM_SetCellVolume(id, cell_vol);
    
		// Set initial pore volume
		pv0 = (double *) malloc((size_t) (nxyz * sizeof(double)));
		for (i = 0; i < nxyz; i++) pv0[i] = 0.2;
		status = RM_SetPoreVolumeZero(id, pv0);
    
		// Set current pore volume
		pv = (double *) malloc((size_t) (nxyz * sizeof(double)));
		for (i = 0; i < nxyz; i++) pv[i] = 0.2;
		status = RM_SetPoreVolume(id, pv);
    
		// Set saturation
		sat = (double *) malloc((size_t) (nxyz * sizeof(double)));
		for (i = 0; i < nxyz; i++) sat[i] = 1.0;
		status = RM_SetSaturation(id, sat);
    
		// Set cells to print chemistry when print chemistry is turned on
		print_chemistry_mask = (int *) malloc((size_t) (nxyz * sizeof(int)));
		for (i = 0; i < nxyz; i++) print_chemistry_mask[i] = 1;
		status = RM_SetPrintChemistryMask(id, print_chemistry_mask);
				
		// Partitioning of uz solids
		status = RM_SetPartitionUZSolids(id, 0);

		// For demonstation, two row, first active, second inactive
		grid2chem = (int *) malloc((size_t) (nxyz * sizeof(int)));
		for (i = 0; i < nxyz/2; i++) grid2chem[i] = i;
		status = RM_CreateMapping(id, grid2chem);
		
		// Load database
		status = RM_SetPrintChemistryOn(id, 0, 1, 0); // workers, initial_phreeqc, utility
		status = RM_LoadDatabase(id, "phreeqc.dat"); 

		// Run file to define solutions and reactants for initial conditions, selected output
		// There are three types of IPhreeqc modules in PhreeqcRM
		// Argument 1 refers to the InitialPhreeqc module for accumulating initial and boundary conditions
		// Argument 2 refers to the workers for doing reaction calculations for transport
		// Argument 3 refers to a utility module
		status = RM_RunFile(id, 1, 1, 1, "advect.pqi");

		// For demonstration, clear contents of workers and utility
		// Worker initial conditions are defined below
		strcpy(str, "DELETE; -all");
		status = RM_RunString(id, 1, 0, 1, str);	// workers, initial_phreeqc, utility 
 
		// Set get list of components
		ncomps = RM_FindComponents(id);
		components = (char **) malloc((size_t) (ncomps * sizeof(char *)));
		for (i = 0; i < ncomps; i++)
		{
			components[i] = (char *) malloc((size_t) (100 * sizeof(char *)));
			status = RM_GetComponent(id, i, components[i], 100);
		}
		    
		// Set array of initial conditions
		//allocate(ic1(nxyz,7), ic2(nxyz,7), f1(nxyz,7))
		ic1 = (int *) malloc((size_t) (7 * nxyz * sizeof(int)));
		ic2 = (int *) malloc((size_t) (7 * nxyz * sizeof(int)));
		f1 = (double *) malloc((size_t) (7 * nxyz * sizeof(double)));
		for (i = 0; i < nxyz; i++) 
		{
			ic1[i]          = 1;       // Solution 1
			ic1[nxyz + i]   = -1;      // Equilibrium phases none
			ic1[2*nxyz + i] = 1;       // Exchange 1
			ic1[3*nxyz + i] = -1;      // Surface none
			ic1[4*nxyz + i] = -1;      // Gas phase none
			ic1[5*nxyz + i] = -1;      // Solid solutions none
			ic1[6*nxyz + i] = -1;      // Kinetics none

			ic2[i]          = -1;      // Solution none
			ic2[nxyz + i]   = -1;      // Equilibrium phases none
			ic2[2*nxyz + i] = -1;      // Exchange none
			ic2[3*nxyz + i] = -1;      // Surface none
			ic2[4*nxyz + i] = -1;      // Gas phase none
			ic2[5*nxyz + i] = -1;      // Solid solutions none
			ic2[6*nxyz + i] = -1;      // Kinetics none

			f1[i]          = 1.0;      // Mixing fraction ic1 Solution
			f1[nxyz + i]   = 1.0;      // Mixing fraction ic1 Equilibrium phases 
			f1[2*nxyz + i] = 1.0;      // Mixing fraction ic1 Exchange 1
			f1[3*nxyz + i] = 1.0;      // Mixing fraction ic1 Surface 
			f1[4*nxyz + i] = 1.0;      // Mixing fraction ic1 Gas phase 
			f1[5*nxyz + i] = 1.0;      // Mixing fraction ic1 Solid solutions 
			f1[6*nxyz + i] = 1.0;      // Mixing fraction ic1 Kinetics 
		}
		status = RM_InitialPhreeqc2Module(id, ic1, ic2, f1);

		// Get a boundary condition from initial phreeqc
		nbound = 1;
		bc1 = (int *) malloc((size_t) (nbound * sizeof(int)));
		bc2 = (int *) malloc((size_t) (nbound * sizeof(int)));
		bc_f1 = (double *) malloc((size_t) (nbound * sizeof(double)));
		for (i = 0; i < nbound; i++) 
		{
			bc1[i]          = 0;       // Solution 1
			bc2[i]          = -1;      // no mixing
			bc_f1[i]        = 1.0;     // mixing fraction for bc1
		} 
		bc_conc = (double *) malloc((size_t) (ncomps * nbound * sizeof(double)));
		status = RM_InitialPhreeqc2Concentrations(id, bc_conc, nbound, bc1, bc2, bc_f1);
		
		// Initial equilibration of cells
		time = 0.0;
		time_step = 0.0;
		c = (double *) malloc((size_t) (ncomps * nxyz * sizeof(double)));
		status = RM_SetTime(id, time);
		status = RM_SetTimeStep(id, time_step);
		status = RM_RunCells(id); 
		status = RM_GetConcentrations(id, c);

		// Transient loop
		nsteps = 10;
		density = (double *) malloc((size_t) (nxyz * sizeof(double)));
		pressure = (double *) malloc((size_t) (nxyz * sizeof(double)));
		temperature = (double *) malloc((size_t) (nxyz * sizeof(double)));
		for (i = 0; i < nxyz; i++) 
		{
			density[i] = 1.0;
			pressure[i] = 2.0;
			temperature[i] = 20.0;
		}
		time_step = 86400;
		status = RM_SetTimeStep(id, time_step);
		for (isteps = 0; isteps < nsteps; isteps++)
		{
			// Advection calculation
			advect_c(c, bc_conc, ncomps, nxyz, nbound);
        
			// Send any new conditions to module
			status = RM_SetPoreVolume(id, pv);            // If pore volume changes due to compressibility
			status = RM_SetSaturation(id, sat);           // If saturation changes
			status = RM_SetTemperature(id, temperature);  // If temperature changes
			status = RM_SetPressure(id, pressure);        // If pressure changes
			status = RM_SetConcentrations(id, c);
        
			// Set print flag
 			if (isteps == nsteps - 1) 
			{
				status = RM_SetPrintChemistryOn(id, 1, 0, 0); // print at last time step, workers, initial_phreeqc, utility
			}
			else
			{
				status = RM_SetPrintChemistryOn(id, 0, 0, 0); // workers, initial_phreeqc, utility
			}
			// Run cells with new conditions
			time = time + time_step;
			status = RM_SetTime(id, time); 
			status = RM_RunCells(id);  
			status = RM_GetConcentrations(id, c);
 
			// Print results at last time step
			if (isteps == nsteps - 1) 
			{
 				// Get current density
				status = RM_GetDensity(id, density);

				// Get double array of selected output values
				col = RM_GetSelectedOutputColumnCount(id);
				//allocate(selected_out(nxyz,col))
				selected_out = (double *) malloc((size_t) (col * nxyz * sizeof(double)));
				status = RM_GetSelectedOutput(id, selected_out);

				// Print results
				for (i = 0; i < nxyz/2; i++)
				{
					fprintf(stderr, "Cell number %d\n", i);
					fprintf(stderr, "     Density: %f\n", density[i]);
					fprintf(stderr, "     Components: \n");
					for (j = 0; j < ncomps; j++)
					{
						fprintf(stderr, "          %2d %10s: %10.4f\n", j, components[j], c[j*nxyz + i]);
					}
					fprintf(stderr, "     Selected output: \n");
					for (j = 0; j < col; j++)
					{
						status = RM_GetSelectedOutputHeading(id, j, heading, 100);  
						fprintf(stderr, "          %2d %10s: %10.4f\n", j, heading, selected_out[j*nxyz + i]);
					}
				}
				free(selected_out);
			}
		}

		// Use utility instance of PhreeqcRM
		tc = (double *) malloc((size_t) (nxyz * sizeof(double)));
		p_atm = (double *) malloc((size_t) (nxyz * sizeof(double)));
		for (i = 0; i < nxyz; i++)
		{
			tc[i] = 15.0;
			p_atm[i] = 3.0;
		}
		iphreeqc_id = RM_Concentrations2Utility(id, c, nxyz, tc, p_atm);
		strcpy(str, "RUN_CELLS; -cells 0-19");
		// Option 1
		SetOutputFileName(iphreeqc_id, "utility_c.txt");
		SetOutputFileOn(iphreeqc_id, 1);
		status = RunString(iphreeqc_id, str);
		// Option 2
		status = RM_SetPrintChemistryOn(id, 0, 0, 1);  // workers, initial_phreeqc, utility
		status = RM_RunString(id, 0, 0, 1, str); 

		// Dump results
		dump_on = 1;
		append = 0;
		status = RM_SetDumpFileName(id, "advection_c.dmp.gz");
		status = RM_DumpModule(id, dump_on, append);    // second argument: gz disabled unless compiled with #define USE_GZ

		// free space
		free(cell_vol);
		free(pv0);
		free(pv);
		free(sat);
		free(print_chemistry_mask);
		free(grid2chem);
		for (i = 0; i < ncomps; i++)
		{
			free(components[i]);
		}
		free(components);
		free(ic1);
		free(ic2);
		free(f1);
		free(bc1);
		free(bc2);
		free(bc_f1);
		free(bc_conc);
		free(c);
		free(density);
		free(temperature);
		free(pressure);
	}
	void advect_c(double *c, double *bc_conc, int ncomps, int nxyz, int dim)
	{
		int i, j;
		// Advect
		for (i = nxyz/2 - 1; i > 0; i--)
		{
			for (j = 0; j < ncomps; j++)
			{
				c[j * nxyz + i] = c[j * nxyz + i - 1];
			}
		}
		// Cell 0 gets boundary condition
		for (j = 0; j < ncomps; j++)
		{
			c[j * nxyz] = bc_conc[j * dim];
		}
	}
