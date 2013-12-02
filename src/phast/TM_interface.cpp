#include <windows.h>
#include <string>
#include <map>
#include "TM_interface.h"
#ifdef THREADED_PHAST
#include <omp.h>
#endif
#ifdef USE_MPI
#include "mpi.h"
#endif
extern void transport_component(int *i);
extern void transport_component_thread(int *i);

#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
void
TM_transport(int *id, int *ncomps, int *nthreads)
/* ---------------------------------------------------------------------- */
{
	// Used for MPI transport calculations
	for (int i = 1; i <= *ncomps; i++)
	{
		transport_component_thread(&i);
	}
}
#else
/* ---------------------------------------------------------------------- */
void
TM_transport(int *id, int *ncomps, int *nthreads)
/* ---------------------------------------------------------------------- */
{
	int n = 1;
	// Used for threaded transport calculations
#ifdef THREADED_PHAST
	if (*nthreads <= 0)
	{
#if defined(_WIN32)
		SYSTEM_INFO sysinfo;
		GetSystemInfo( &sysinfo );

		n = sysinfo.dwNumberOfProcessors;
#else
		// Linux, Solaris, Aix, Mac 10.4+
		n = sysconf( _SC_NPROCESSORS_ONLN );
#endif
		*nthreads = n;
	}
	else
	{
		n = *nthreads;
	}
#endif
#ifdef THREADED_PHAST
	omp_set_num_threads(n);
	#pragma omp parallel
	#pragma omp for
	for (int i = 1; i <= *ncomps; i++)
	{
		transport_component_thread(&i);
	}
#else
	for (int i = 1; i <= *ncomps; i++)
	{
		transport_component(&i);
	}
#endif
}
#endif
/* ---------------------------------------------------------------------- */
void TM_zone_flow_write_chem(int *print_zone_flows_xyzt)
/* ---------------------------------------------------------------------- */
{
#ifdef USE_MPI
	MPI_Bcast(print_zone_flows_xyzt, 1, MPI_INTEGER, 0, MPI_COMM_WORLD);
#endif
	if (print_zone_flows_xyzt != 0)
	{
		zone_flow_write_chem();
	}
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::Distribute_initial_conditions_mix(
					int id, 
					int *initial_conditions1_in,
					int *initial_conditions2_in, 
					double *fraction1_in)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      nxyz - number of cells
	 *      initial_conditions1 - Fortran, 7 x nxyz integer array, containing
	 *      entity numbers for
	 *           solution number
	 *           pure_phases number
	 *           exchange number
	 *           surface number
	 *           gas number
	 *           solid solution number
	 *           kinetics number
	 *      initial_conditions2 - Fortran, 7 x nxyz integer array, containing
	 *			 entity numbers
	 *      fraction1 - Fortran 7 x n_cell  double array, fraction for entity 1  
	 *
	 *      Routine mixes solutions, pure_phase assemblages,
	 *      exchangers, surface complexers, gases, solid solution assemblages,
	 *      and kinetics for each cell.
	 *   
	 *      saves results in restart_bin and then the reaction module
	 */
	int i, j;
	IRM_RESULT rtn = IRM_OK;

	std::vector < int > initial_conditions1, initial_conditions2;
	std::vector < double > fraction1;
	initial_conditions1.resize(7 * this->nxyz);
	initial_conditions2.resize(7 * this->nxyz);
	fraction1.resize(7 * this->nxyz);
	size_t array_size = (size_t) (7 * this->nxyz);
	if (this->mpi_myself == 0)
	{
		if (initial_conditions1_in == NULL ||
			initial_conditions2_in == NULL ||
			fraction1_in == NULL)
		{
			std::ostringstream errstr;
			errstr << "NULL pointer in call to DistributeInitialConditions\n";
			error_msg(errstr.str().c_str(), 1);
		}

		memcpy(initial_conditions1.data(), initial_conditions1_in, array_size * sizeof(int));
		memcpy(initial_conditions2.data(), initial_conditions2_in, array_size * sizeof(int));
		memcpy(fraction1.data(),           fraction1_in,           array_size * sizeof(double));
	}
#ifdef USE_MPI
	//
	// Transfer arrays
	//
	MPI_Bcast(initial_conditions1.data(), 7 * (this->nxyz), MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(initial_conditions2.data(), 7 * (this->nxyz), MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(fraction1.data(),           7 * (this->nxyz), MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
	/*
	* Make copy of initial conditions for use in restart file
	*/
	for (i = 0; i < nxyz; i++)
	{
		j = 7 * i;
		have_Solution.push_back(initial_conditions1[j]);
		j++;
		have_PPassemblage.push_back(initial_conditions1[j]);
		j++;
		have_Exchange.push_back(initial_conditions1[j]);
		j++;
		have_Surface.push_back(initial_conditions1[j]);
		j++;
		have_GasPhase.push_back(initial_conditions1[j]);
		j++;
		have_SSassemblage.push_back(initial_conditions1[j]);
		j++;
		have_Kinetics.push_back(initial_conditions1[j]);
	}
	/*
	 *  Copy solution, exchange, surface, gas phase, kinetics, solid solution for each active cell.
	 *  Does nothing for indexes less than 0 (i.e. restart files)
	 */

	// calculate cells for each thread or process
	Set_end_cells();

#ifdef USE_MPI
	int begin = this->start_cell[this->mpi_myself];
	int end = this->end_cell[this->mpi_myself] + 1;
	size_t count_negative_porosity = 0;
	std::set<std::string> error_set;
	
	for (int k = begin; k < end; k++)
	{	
		j = k;                          /* j is count_chem number */
		i = this->back[j][0];           /* i is ixyz number */

		assert(forward[i] >= 0);
		assert (volume[i] > 0.0);
		double porosity = pore_volume_zero[i] / cell_volume[i];
		if (pore_volume_zero[i] < 0 || cell_volume[i] < 0)
		{
			std::ostringstream errstr;
			errstr << "Negative volume in cell " << i << ": volume, " << cell_volume[i]; 
			errstr << "\t initial volume, " << this->pore_volume_zero[i] << ".",
			count_negative_porosity++;
			error_msg(errstr.str().c_str());
			rtn = IRM_FAIL;
			continue;
		}
		assert (porosity > 0.0);
		double porosity_factor = (1.0 - porosity) / porosity;
		Cell_initialize(i, j, initial_conditions1.data(), initial_conditions2.data(),
			fraction1.data(),
			this->input_units_Exchange, this->input_units_Surface, this->input_units_SSassemblage,
			this->input_units_PPassemblage, this->input_units_GasPhase, this->input_units_Kinetics,
			porosity_factor,
			error_set);
	}
#else
	size_t count_negative_porosity = 0;
	std::set<std::string> error_set;
	for (i = 0; i < nxyz; i++)
	{							        /* i is ixyz number */
		j = this->forward[i];			/* j is count_chem number */
		if (j < 0)
			continue;
		assert(forward[i] >= 0);
		assert (cell_volume[i] > 0.0);
		double porosity = pore_volume_zero[i] / cell_volume[i];
		if (pore_volume_zero[i] < 0 || cell_volume[i] < 0)
		{
			std::ostringstream errstr;
			errstr << "Negative volume in cell " << i << ": volume, " << cell_volume[i]; 
			errstr << "\t initial volume, " << this->pore_volume_zero[i] << ".",
			count_negative_porosity++;
			error_msg(errstr.str().c_str());
			rtn = IRM_FAIL;
			continue;
		}
		assert (porosity > 0.0);
		double porosity_factor = (1.0 - porosity) / porosity;
		Cell_initialize(i, j, initial_conditions1.data(), initial_conditions2.data(),
			fraction1.data(),
			this->input_units_Exchange, this->input_units_Surface, this->input_units_SSassemblage,
			this->input_units_PPassemblage, this->input_units_GasPhase, this->input_units_Kinetics,
			porosity_factor,
			error_set);
	}
#endif
	if (error_set.size() > 0)
	{
		rtn = IRM_FAIL;
		std::set<std::string>::iterator it = error_set.begin();
		for (; it != error_set.end(); it++)
		{
			error_msg(it->c_str(), 0);
		}
	}
	if (count_negative_porosity > 0)
	{
		rtn = IRM_FAIL;
		std::ostringstream errstr;
		errstr << "Negative initial volumes may be due to initial head distribution.\n"
			"Make initial heads greater than or equal to the elevation of the node for each cell.\n"
			"Increase porosity, decrease specific storage, or use free surface boundary.";
		error_msg(errstr.str().c_str(), 1);
	}
	/*
	 * Read any restart files
	 */
	cxxStorageBin restart_bin;
	for (std::map < std::string, int >::iterator it = FileMap.begin();
		 it != FileMap.end(); it++)
	{
		int
			ifile = -100 - it->second;

		// use gsztream
		igzstream
			myfile;
		myfile.open(it->first.c_str());
		if (!myfile.good())

		{
			rtn = IRM_FAIL;
			std::ostringstream errstr;
			errstr << "File could not be opened: " << it->first.c_str();
			error_msg(errstr.str().c_str());
			break;
		}

		CParser	cparser(myfile, this->Get_io());
		cparser.set_echo_file(CParser::EO_NONE);
		cparser.set_echo_stream(CParser::EO_NONE);

		// skip headers
		while (cparser.check_line("restart", false, true, true, false) ==
			   PHRQ_io::LT_EMPTY);

		// read number of lines of index
		int	n = -1;
		if (!(cparser.get_iss() >> n) || n < 4)
		{
			rtn = IRM_FAIL;
			std::ostringstream errstr;
			errstr << "File does not have node locations: " << it->first.c_str() << "\nPerhaps it is an old format restart file.";
			error_msg(errstr.str().c_str(), 1);
			myfile.close();
			break;
		}

		// points are x, y, z, cell_no
		std::vector < Point > pts;
		// index:
		// 0 solution
		// 1 ppassemblage
		// 2 exchange
		// 3 surface
		// 4 gas phase
		// 5 ss_assemblage
		// 6 kinetics

		std::vector<int> c_index;
		for (i = 0; i < n; i++)
		{
			cparser.check_line("restart", false, false, false, false);
			double
				x,
				y,
				z,
				v;
			cparser.get_iss() >> x;
			cparser.get_iss() >> y;
			cparser.get_iss() >> z;
			cparser.get_iss() >> v;
			pts.push_back(Point(x, y, z, v));

			int dummy;
			// c_index defines entities present for each cell in restart file
			for (j = 0; j < 7; j++)
			{
				cparser.get_iss() >> dummy;
				c_index.push_back(dummy);
			}
		}
		KDtree
		index_tree(pts);

		cxxStorageBin tempBin;
		tempBin.read_raw(cparser);

		for (j = 0; j < count_chemistry; j++)	/* j is count_chem number */
		{
			i = this->back[j][0];   /* i is nxyz number */
			Point p(this->x_node[i], this->y_node[i], this->z_node[i]);
			int	k = (int) index_tree.Interpolate3d(p);	// k is index number in tempBin

			// solution
			if (initial_conditions1[i * 7] == ifile)
			{
				if (c_index[k * 7] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_Solution(k) != NULL)
					{
						restart_bin.Set_Solution(j, tempBin.Get_Solution(k));
					}
					else
					{
						assert(false);
						initial_conditions1[7 * i] = -1;
					}
				}
			}

			// PPassemblage
			if (initial_conditions1[i * 7 + 1] == ifile)
			{
				if (c_index[k * 7 + 1] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_PPassemblage(k) != NULL)
					{
						restart_bin.Set_PPassemblage(j, tempBin.Get_PPassemblage(k));
					}
					else
					{
						assert(false);
						initial_conditions1[7 * i + 1] = -1;
					}
				}
			}

			// Exchange
			if (initial_conditions1[i * 7 + 2] == ifile)
			{
				if (c_index[k * 7 + 2] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_Exchange(k) != NULL)
					{
						restart_bin.Set_Exchange(j, tempBin.Get_Exchange(k));
					}
					else
					{
						assert(false);
						initial_conditions1[7 * i + 2] = -1;
					}
				}
			}

			// Surface
			if (initial_conditions1[i * 7 + 3] == ifile)
			{
				if (c_index[k * 7 + 3] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_Surface(k) != NULL)
					{
						restart_bin.Set_Surface(j, tempBin.Get_Surface(k));
					}
					else
					{
						assert(false);
						initial_conditions1[7 * i + 3] = -1;
					}
				}
			}

			// Gas phase
			if (initial_conditions1[i * 7 + 4] == ifile)
			{
				if (c_index[k * 7 + 4] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_GasPhase(k) != NULL)
					{
						restart_bin.Set_GasPhase(j, tempBin.Get_GasPhase(k));
					}
					else
					{
						assert(false);
						initial_conditions1[7 * i + 4] = -1;
					}
				}
			}

			// Solid solution
			if (initial_conditions1[i * 7 + 5] == ifile)
			{
				if (c_index[k * 7 + 5] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_SSassemblage(k) != NULL)
					{
						restart_bin.Set_SSassemblage(j, tempBin.Get_SSassemblage(k));
					}
					else
					{
						assert(false);
						initial_conditions1[7 * i + 5] = -1;
					}
				}
			}

			// Kinetics
			if (initial_conditions1[i * 7 + 6] == ifile)
			{
				if (c_index[k * 7 + 6] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_Kinetics(k) != NULL)
					{
						restart_bin.Set_Kinetics(j, tempBin.Get_Kinetics(k));
					}
					else
					{
						assert(false);
						initial_conditions1[7 * i + 6] = -1;
					}
				}
			}
		}
		myfile.close();
	}

#ifdef USE_MPI	
	for (i = this->start_cell[this->mpi_myself]; i <= this->end_cell[this->mpi_myself]; i++)
	{
		this->GetWorkers()[0]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(restart_bin,i);
	}
#else
	// put restart definitions in reaction module
	this->GetWorkers()[0]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(restart_bin);

	for (int n = 1; n < this->nthreads; n++)
	{
		std::ostringstream delete_command;
		delete_command << "DELETE; -cells\n";
		for (i = this->start_cell[n]; i <= this->end_cell[n]; i++)
		{
			cxxStorageBin sz_bin;
			this->GetWorkers()[0]->Get_PhreeqcPtr()->phreeqc2cxxStorageBin(sz_bin, i);
			this->GetWorkers()[n]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(sz_bin, i);
			delete_command << i << "\n";
		}
		if (this->GetWorkers()[0]->RunString(delete_command.str().c_str()) > 0) RM_Error(0);
	}
#endif
	// initialize uz
	old_saturation.insert(old_saturation.begin(), nxyz, 1.0);
	return rtn;
}
#endif
