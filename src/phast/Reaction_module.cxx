#include "Reaction_module.h"
#include "RM_interface.h"
#include "PHRQ_base.h"
#include "PHRQ_io.h"
#include "IPhreeqc.h"
#include "IPhreeqc.hpp"
#include "IPhreeqcPhast.h"
#include <assert.h>
#include "System.h"
#include "gzstream.h"
#include "KDtree/KDtree.h"
#include "cxxMix.h"
#include "Solution.h"
#include "Exchange.h"
#include "Surface.h"
#include "PPassemblage.h"
#include "SSassemblage.h"
#include "cxxKinetics.h"
#include "GasPhase.h"
#include <time.h>
#include "hdf.h"
#ifdef THREADED_PHAST
#include <omp.h>
#endif
#ifdef USE_MPI
#include <mpi.h>
#endif
#define protected public
#include "Phreeqc.h"
Reaction_module::Reaction_module(int thread_count, PHRQ_io *io)
	//
	// constructor
	//
: PHRQ_base(io)
{
	int n = 1;
#ifdef THREADED_PHAST
	
#if defined(_WIN32)
	SYSTEM_INFO sysinfo;
	GetSystemInfo( &sysinfo );

	n = sysinfo.dwNumberOfProcessors;
#else
	// Linux, Solaris, Aix, Mac 10.4+
	n = sysconf( _SC_NPROCESSORS_ONLN );
#endif
#ifdef OTHERS
int mib[4];
size_t len = sizeof(numCPU); 

/* set the mib for hw.ncpu */
mib[0] = CTL_HW;
mib[1] = HW_AVAILCPU;  // alternatively, try HW_NCPU;

/* get the number of CPUs from the system */
sysctl(mib, 2, &numCPU, &len, NULL, 0);

if( numCPU < 1 ) 
{
     mib[1] = HW_NCPU;
     sysctl( mib, 2, &numCPU, &len, NULL, 0 );

     if( numCPU < 1 )
     {
          numCPU = 1;
     }
}
#endif
#ifdef SKIP
#ifdef _WIN32
	if (thread_count == 0)
	{
		char *str;
		str = getenv("NUMBER_OF_PROCESSORS");
		n = atoi(str);
	}
#endif
#endif
#endif
	this->nthreads = (thread_count > 0) ? thread_count : n;
	//this->nthreads = 1;
	// last one is to calculate well pH
	for (int i = 0; i <= this->nthreads; i++)
	{
		this->workers.push_back(new IPhreeqcPhast);
	}
	if (this->Get_workers()[0])
	{
		std::map<size_t, Reaction_module*>::value_type instance(this->Get_workers()[0]->Get_Index(), this);
		RM_interface::Instances.insert(instance);
	}
	else
	{
		std::cerr << "Reaction module not created." << std::endl;
		exit(4);
	}

	this->mpi_myself = 0;
	this->mpi_tasks = 1;

	this->gfw_water = 18.;						// gfw of water
	this->count_chem = 0;
	this->free_surface = false;					// free surface calculation
	this->steady_flow = false;					// steady-state flow calculation
	this->transient_free_surface = false;		// free surface and not steady flow
	this->nxyz = 0;								// number of nodes 
	this->nx = this->ny = this->nz = 0;			// number of nodes in each coordinate direction
	this->time_hst = 0;							// scalar time from transport 
	this->time_step_hst = 0;					// scalar time step from transport
	this->cnvtmi = NULL;						// scalar conversion factor for time
	this->x_node = NULL;						// nxyz array of X coordinates for nodes
	this->y_node = NULL;						// nxyz array of Y coordinates for nodes 
	this->z_node = NULL;						// nxyz array of Z coordinates for nodes
	this->fraction = NULL;						// nxyz by ncomps mass fractions nxyz:components
	this->frac = NULL;							// nxyz saturation fraction
	this->pv = NULL;							// nxyz current pore volumes 
	this->pv0 = NULL;							// nxyz initial pore volumes
	this->volume = NULL;						// nxyz geometric cell volumes 
	this->printzone_chem = NULL;				// nxyz print flags for output file
	this->printzone_xyz = NULL;					// nxyz print flags for chemistry XYZ file 
	this->ic1 = NULL;							// reactant number for end member 1
	this->rebalance_fraction_hst = NULL;		// parameter for rebalancing process load for parallel	

	// print flags
	this->prslm = false;						// solution method print flag 
	this->print_chem = false;					// print flag for chemistry output file 
	this->print_xyz = false;					// print flag for selected output
	this->print_hdf = false;					// print flag for hdf file
	this->print_restart = false;				// print flag for writing restart file 
	write_xyz_headings = true;
}
Reaction_module::~Reaction_module(void)
{
	std::map<size_t, Reaction_module*>::iterator it = RM_interface::Instances.find(this->Get_workers()[0]->Get_Index());
	//delete phast_iphreeqc_worker;
	for (int i = 0; i <= it->second->Get_nthreads(); i++)
	{
		delete it->second->Get_workers()[i];
	}
	if (it != RM_interface::Instances.end())
	{
		RM_interface::Instances.erase(it);
	}

}

// Reaction_module methods

/* ---------------------------------------------------------------------- */
void
Reaction_module::BeginCell(int index)
/* ---------------------------------------------------------------------- */
{
	// index is nxyz number
#ifdef HDF5_CREATE
	HDFSetCell(index, back);
#endif
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	/* Always open file for output in case of a warning message */
	//TODO MergeBeginCell();
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::BeginTimeStep(void)
/* ---------------------------------------------------------------------- */
{
#ifdef HDF5_CREATE
	HDFBeginCTimeStep(this->count_chem);
#endif
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	/* Always open file for output in case of a warning message */
	//TODOMergeBeginTimeStep(print_sel, print_out);
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Calculate_well_ph(double *c, double * pH, double * alkalinity)
/* ---------------------------------------------------------------------- */
{

	// convert mass fraction to moles and store in d
	std::vector<double> d;  
	size_t k;
	for (k = 0; k < this->components.size(); k++)
	{	
		d.push_back(c[k] * 1000.0/gfw[k]);
	}

	// Store in NameDouble
	cxxNameDouble nd;
	for (k = 3; k < components.size(); k++)
	{
		if (d[k] <= 1e-14) d[k] = 0.0;
		nd.add(components[k].c_str(), d[k]);
	}	

	cxxSolution cxxsoln(this->Get_io());	
	cxxsoln.Update(d[0] + 2.0/gfw_water, d[1] + 1.0/gfw_water, d[2], nd);
	cxxStorageBin temp_bin;
	temp_bin.Set_Solution(0, &cxxsoln);

	// Copy all entities numbered 1 into IPhreeqc
	this->Get_workers()[this->nthreads]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(temp_bin, 0);
	std::string input;
	input.append("RUN_CELLS; -cell 0; SELECTED_OUTPUT; -reset false; -pH; -alkalinity; END");
	this->Get_workers()[0]->RunString(input.c_str());

	VAR pvar;
	this->Get_workers()[this->nthreads]->GetSelectedOutputValue(1,0,&pvar);
	*pH = pvar.dVal;
	this->Get_workers()[this->nthreads]->GetSelectedOutputValue(1,1,&pvar);
	*alkalinity = pvar.dVal;

	// Alternatively
	//*pH = -(this->phast_iphreeqc_worker->Get_PhreeqcPtr()->s_hplus->la);
	//*alkalinity = this->phast_iphreeqc_worker->Get_PhreeqcPtr()->total_alkalinity / 
	//	this->phast_iphreeqc_worker->Get_PhreeqcPtr()->mass_water_aq_x;
	return;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Cell_initialize(
					int i, 
					int n_user_new, 
					int *initial_conditions1,
					int *initial_conditions2, 
					double *fraction1,
					int exchange_units, 
					int surface_units, 
					int ssassemblage_units,
					int ppassemblage_units, 
					int gasphase_units, 
					int kinetics_units,
					double porosity_factor)
/* ---------------------------------------------------------------------- */
{
	int n_old1, n_old2;
	double f1;

	cxxStorageBin initial_bin;
	/*
	 *   Copy solution
	 */
	n_old1 = initial_conditions1[7 * i];
	n_old2 = initial_conditions2[7 * i];
	f1 = fraction1[7 * i];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		cxxSolution cxxsoln(phreeqc_bin.Get_Solutions(), mx, n_user_new);
		initial_bin.Set_Solution(n_user_new, &cxxsoln);
	}

	/*
	 *   Copy pp_assemblage
	 */
	n_old1 = initial_conditions1[7 * i + 1];
	n_old2 = initial_conditions2[7 * i + 1];
	f1 = fraction1[7 * i + 1];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (ppassemblage_units == 2)
		{
			mx.Multiply(porosity_factor);
		}
		cxxPPassemblage cxxentity(phreeqc_bin.Get_PPassemblages(), mx,
								  n_user_new);
		initial_bin.Set_PPassemblage(n_user_new, &cxxentity);
	}
	/*
	 *   Copy exchange assemblage
	 */

	n_old1 = initial_conditions1[7 * i + 2];
	n_old2 = initial_conditions2[7 * i + 2];
	f1 = fraction1[7 * i + 2];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (exchange_units == 2)
		{
			mx.Multiply(porosity_factor);
		}
		cxxExchange cxxexch(phreeqc_bin.Get_Exchangers(), mx, n_user_new);
		initial_bin.Set_Exchange(n_user_new, &cxxexch);
	}
	/*
	 *   Copy surface assemblage
	 */
	n_old1 = initial_conditions1[7 * i + 3];
	n_old2 = initial_conditions2[7 * i + 3];
	f1 = fraction1[7 * i + 3];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (surface_units == 2)
		{
			mx.Multiply(porosity_factor);
		}
		cxxSurface cxxentity(phreeqc_bin.Get_Surfaces(), mx, n_user_new);
		initial_bin.Set_Surface(n_user_new, &cxxentity);
	}
	/*
	 *   Copy gas phase
	 */
	n_old1 = initial_conditions1[7 * i + 4];
	n_old2 = initial_conditions2[7 * i + 4];
	f1 = fraction1[7 * i + 4];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (gasphase_units == 2)
		{
			mx.Multiply(porosity_factor);
		}
		cxxGasPhase cxxentity(phreeqc_bin.Get_GasPhases(), mx, n_user_new);
		initial_bin.Set_GasPhase(n_user_new, &cxxentity);
	}
	/*
	 *   Copy solid solution
	 */
	n_old1 = initial_conditions1[7 * i + 5];
	n_old2 = initial_conditions2[7 * i + 5];
	f1 = fraction1[7 * i + 5];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (ssassemblage_units == 2)
		{
			mx.Multiply(porosity_factor);
		}
		cxxSSassemblage cxxentity(phreeqc_bin.Get_SSassemblages(), mx,
								  n_user_new);
		initial_bin.Set_SSassemblage(n_user_new, &cxxentity);
	}
	/*
	 *   Copy kinetics
	 */
	n_old1 = initial_conditions1[7 * i + 6];
	n_old2 = initial_conditions2[7 * i + 6];
	f1 = fraction1[7 * i + 6];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (kinetics_units == 2)
		{
			mx.Multiply(porosity_factor);
		}
		cxxKinetics cxxentity(phreeqc_bin.Get_Kinetics(), mx, n_user_new);
		initial_bin.Set_Kinetics(n_user_new, &cxxentity);
	}
	this->Get_workers()[0]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(initial_bin);
	return;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Convert_to_molal(double *c, int n, int dim)
/* ---------------------------------------------------------------------- */
{
/*
 *  convert c from mass fraction to moles
 *  The c array is dimensioned c(dim,ns).
 *  n is the number of rows that are used.
 *  In f90 dim = n and is often the number of
 *    cells in the domain.
 */
	int i;
	for (i = 0; i < n; i++)
	{
		double *ptr = &c[i];
		size_t k;
		for (k = 0; k < this->components.size(); k++)
		{	
			ptr[k * dim] *= 1000.0/this->gfw[k];
		}
	}
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::cxxSolution2fraction(cxxSolution * cxxsoln_ptr, std::vector<double> & d)
/* ---------------------------------------------------------------------- */
{
	d.clear();

	d.push_back((cxxsoln_ptr->Get_total_h() - 2.0 / this->gfw_water) * this->gfw[0]/1000. ); 
	d.push_back((cxxsoln_ptr->Get_total_o() - 1.0 / this->gfw_water) * this->gfw[1]/1000.);
	d.push_back(cxxsoln_ptr->Get_cb() * this->gfw[2]/1000.);

	// Simplify totals
	{
	  cxxNameDouble nd = cxxsoln_ptr->Get_totals().Simplify_redox();
	  cxxsoln_ptr->Set_totals(nd);
	}
	size_t i;
	for (i = 3; i < this->components.size(); i++)
	{
		d.push_back(cxxsoln_ptr->Get_total(components[i].c_str()) * this->gfw[i]/1000.);
	}
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Distribute_initial_conditions(
					int id, 
					int *initial_conditions1,
					int *initial_conditions2, 
					double *fraction1,
					int exchange_units, 
					int surface_units, 
					int ssassemblage_units,
					int ppassemblage_units, 
					int gasphase_units, 
					int kinetics_units)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      nxyz - number of cells
	 *      initial_conditions1 - Fortran, 7 x n_cell integer array, containing
	 *           solution number
	 *           pure_phases number
	 *           exchange number
	 *           surface number
	 *           gas number
	 *           solid solution number
	 *           kinetics number
	 *      initial_conditions2 - Fortran, 7 x n_cell integer array, containing
	 *      fraction for 1 - Fortran, 7 x n_cell integer array, containing
	 *
	 *      Routine mixes solutions, pure_phase assemblages,
	 *      exchangers, surface complexers, gases, solid solution assemblages,
	 *      and kinetics for each cell.
	 *   
	 *      saves results in restart_bin and then the reaction module
	 */
	int i, j;
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
	
	for (int k = begin; k < end; k++)
	{	
		j = k;                          /* j is count_chem number */
		i = this->back[j][0];           /* i is ixyz number */
		
		//j = this->forward[i];			/* j is count_chem number */
		//if (j < 0)
		//	continue;
		assert(forward[i] >= 0);
		assert (volume[i] > 0.0);
		double porosity = pv0[i] / volume[i];
		if (pv0[i] < 0 || volume[i] < 0)
		{
			std::ostringstream errstr;
			errstr << "Negative volume in cell " << i << ": volume, " << volume[i]; 
			errstr << "\t initial volume, " << this->pv0[i] << ".",
			count_negative_porosity++;
			error_msg(errstr.str().c_str());
			continue;
		}
		assert (porosity > 0.0);
		double porosity_factor = (1.0 - porosity) / porosity;
		Cell_initialize(i, j, initial_conditions1, initial_conditions2,
			fraction1,
			exchange_units, surface_units, ssassemblage_units,
			ppassemblage_units, gasphase_units, kinetics_units,
			porosity_factor);
	}
#else
	int begin = 0;
	int end = nxyz;
	size_t count_negative_porosity = 0;
	
	for (i = 0; i < nxyz; i++)
	{							        /* i is ixyz number */
		j = this->forward[i];			/* j is count_chem number */
		if (j < 0)
			continue;
		assert(forward[i] >= 0);
		assert (volume[i] > 0.0);
		double porosity = pv0[i] / volume[i];
		if (pv0[i] < 0 || volume[i] < 0)
		{
			std::ostringstream errstr;
			errstr << "Negative volume in cell " << i << ": volume, " << volume[i]; 
			errstr << "\t initial volume, " << this->pv0[i] << ".",
			count_negative_porosity++;
			error_msg(errstr.str().c_str());
			continue;
		}
		assert (porosity > 0.0);
		double porosity_factor = (1.0 - porosity) / porosity;
		Cell_initialize(i, j, initial_conditions1, initial_conditions2,
			fraction1,
			exchange_units, surface_units, ssassemblage_units,
			ppassemblage_units, gasphase_units, kinetics_units,
			porosity_factor);
	}
#endif
	if (count_negative_porosity > 0)
	{
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

		for (j = 0; j < count_chem; j++)	/* j is count_chem number */
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

#ifdef USE_MPI	for (i = this->start_cell[this->mpi_myself]; i <= this->end_cell[this->mpi_myself]; i++)
	{
		this->Get_workers()[0]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(restart_bin,i);
	}
#else
	for (int n = 0; n < this->nthreads; n++)
	{
		for (i = this->start_cell[n]; i <= this->end_cell[n]; i++)
		{
			this->Get_workers()[n]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(restart_bin,i);
		}
	}
#ifdef SKIP
	// put restart definitions in reaction module
	this->Get_workers()[0]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(restart_bin);

	for (int n = 1; n < this->nthreads; n++)
	{
		std::ostringstream delete_command;
		delete_command << "DELETE; -cells\n";
		for (i = this->start_cell[n]; i <= this->end_cell[n]; i++)
		{
			cxxStorageBin sz_bin;
			this->Get_workers()[0]->Get_PhreeqcPtr()->phreeqc2cxxStorageBin(sz_bin, i);
			this->Get_workers()[n]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(sz_bin, i);
			delete_command << i << "\n";
		}
		if (this->Get_workers()[0]->RunString(delete_command.str().c_str()) > 0) RM_error(0);
	}
#endif
#endif
	// initialize uz
	if (this->transient_free_surface)
	{
		for (i = 0; i < this->nxyz; i++)
		{
			this->old_frac.push_back(1.0);
		}
	}
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::EndCell(int index)
/* ---------------------------------------------------------------------- */
{
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	/* Always open file for output in case of a warning message */
	//TODO MergeEndCell(print_sel, print_out, print_hdf, index);
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::EndTimeStep(void)
/* ---------------------------------------------------------------------- */
{
#ifdef HDF5_CREATE
	HDFEndCTimeStep(back);
#endif
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	/* Always open file for output in case of a warning message */
	//TODO MergeEndTimeStep(print_sel, print_out);
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Error_stop(void)
/* ---------------------------------------------------------------------- */
{
	int n = (int) this->Get_workers()[0]->Get_Index();
	RM_error(&n);
}
/* ---------------------------------------------------------------------- */
bool
Reaction_module::File_exists(const std::string name)
/* ---------------------------------------------------------------------- */
{
	FILE *stream;
	if ((stream = fopen(name.c_str(), "r")) == NULL)
	{
		return false;				/* doesn't exist */
	}
	fclose(stream);
	return true;					/* exists */
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::File_rename(const std::string temp_name, const std::string name, 
	const std::string backup_name)
/* ---------------------------------------------------------------------- */
{
	if (this->File_exists(name))
	{
		if (this->File_exists(backup_name.c_str()))
			remove(backup_name.c_str());
		rename(name.c_str(), backup_name.c_str());
	}
	rename(temp_name.c_str(), name.c_str());
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Forward_and_back(int *initial_conditions, int *naxes)
/* ---------------------------------------------------------------------- */
{
/*
 *   calculate mapping from full set of cells to subset needed for chemistry
 */
	int
		i,
		n,
		ii,
		jj,
		kk;

	bool axes[3];
	axes[0] = naxes[0] != 0;
	axes[1] = naxes[1] != 0;
	axes[2] = naxes[2] != 0;

	this->count_chem = 1;

	int ixy = this->nx * this->ny;
	int ixyz = this->nxyz;

	if (!axes[0] && !axes[1] && !axes[2])
	{
		error_msg("No active coordinate direction in DIMENSIONS keyword.", 1);
	}
	if (axes[0])
		this->count_chem *= this->nx;
	if (axes[1])
		this->count_chem *= this->ny;
	if (axes[2])
		this->count_chem *= this->nz;
/*
 *   malloc space
 */
	this->forward.reserve(ixyz);
/*
 *   xyz domain
 */
	if (axes[0] && axes[1] && (axes[2]))
	{
		n = 0;
		for (i = 0; i < ixyz; i++)
		{
			if (initial_conditions[7 * i] >= 0
				|| initial_conditions[7 * i] <= -100)
			{
				//this->forward[i] = n;
				this->forward.push_back(n);

				std::vector <int> temp;
				this->back.push_back(temp);
				this->back[n].push_back(i);
				n++;
			}
			else
			{
				//this->forward[i] = -1;
				this->forward.push_back(-1);
			}
		}
		this->count_chem = n;
	}
/*
 *   Copy xy plane
 */
	else if (axes[0] && axes[1] && !axes[2])
	{
		if (this->nz != 2)
		{
			std::ostringstream errstr;
			errstr << "Z direction should contain only two nodes for this 2D problem." ;
			error_msg(errstr.str().c_str(), 1);
		}
		n = 0;
		for (i = 0; i < ixyz; i++)
		{
			this->n_to_ijk(i, ii, jj, kk);
			if (kk == 0 && (initial_conditions[7 * i] >= 0 || initial_conditions[7 * i] <= -100) )
			{
				this->forward.push_back(n);

				std::vector <int> temp;
				this->back.push_back(temp);
				this->back[n].push_back(i);
				this->back[n].push_back(i + ixy);
				n++;
			}
			else
			{
				this->forward.push_back(-1);
			}
		}
		this->count_chem = n;
	}
/*
 *   Copy xz plane
 */
	else if (axes[0] && !axes[1] && axes[2])
	{
		if (this->ny != 2)
		{
			std::ostringstream errstr;
			errstr << "Y direction should contain only two nodes for this 2D problem." ;
			error_msg(errstr.str().c_str(), 1);
		}
		n = 0;
		for (i = 0; i < ixyz; i++)
		{
			this->n_to_ijk(i, ii, jj, kk);
			if (jj == 0	&& (initial_conditions[7 * i] >= 0 || initial_conditions[7 * i] <= -100))
			{
				this->forward.push_back(n);

				std::vector <int> temp;
				this->back.push_back(temp);
				this->back[n].push_back(i);
				this->back[n].push_back(i + this->nx);
				n++;
			}
			else
			{
				this->forward.push_back(-1);
			}
		}
		this->count_chem = n;
	}
/*
 *   Copy yz plane
 */
	else if (!axes[0] && axes[1] && axes[2])
	{
		if (this->nx != 2)
		{
			std::ostringstream errstr;
			errstr << "X direction should contain only two nodes for this 2D problem." ;
			error_msg(errstr.str().c_str(), 1);
		}

		n = 0;
		for (i = 0; i < ixyz; i++)
		{
			this->n_to_ijk(i, ii, jj, kk);
			if (ii == 0	&& (initial_conditions[7 * i] >= 0 || initial_conditions[7 * i] <= -100))
			{
				this->forward.push_back(n);

				std::vector <int> temp;
				this->back.push_back(temp);
				this->back[n].push_back(i);
				this->back[n].push_back(i + 1);
				n++;
			}
			else
			{
				this->forward.push_back(-1);
			}
		}
		this->count_chem = n;
	}
/*
 *   Copy x line
 */
	else if (axes[0] && !axes[1] && !axes[2])
	{
		if (this->ny != 2)
		{
			std::ostringstream errstr;
			errstr << "Y direction should contain only two nodes for this 1D problem." ;
			error_msg(errstr.str().c_str(), 1);
		}
		if (this->nz != 2)
		{
			std::ostringstream errstr;
			errstr << "Z direction should contain only two nodes for this 1D problem." ;
			error_msg(errstr.str().c_str(), 1);
		}

		n = 0;
		for (i = 0; i < ixyz; i++)
		{
			if (initial_conditions[i * 7] < 0 && initial_conditions[7 * i] > -100)
			{
				std::ostringstream errstr;
				errstr << "Cannot have inactive cells in a 1D simulation.";
				error_msg(errstr.str().c_str(), 1);
			}
			this->n_to_ijk(i, ii, jj, kk);
			if (jj == 0 && kk == 0)
			{
				this->forward.push_back(n);

				std::vector <int> temp;
				this->back.push_back(temp);
				this->back[n].push_back(i);
				this->back[n].push_back(i + this->nx);
				this->back[n].push_back(i + ixy);
				this->back[n].push_back(i + ixy + this->nx);
				n++;
			}
			else
			{
				this->forward.push_back(-1);
			}
		}
		this->count_chem = n;
	}
/*
 *   Copy y line
 */
	else if (!axes[0] && axes[1] && !axes[2])
	{
		if (this->nx != 2)
		{
			std::ostringstream errstr;
			errstr << "X direction should contain only two nodes for this 1D problem." ;
			error_msg(errstr.str().c_str(), 1);
		}
		if (this->nz != 2)
		{
			std::ostringstream errstr;
			errstr << "Z direction should contain only two nodes for this 1D problem." ;
			error_msg(errstr.str().c_str(), 1);
		}

		n = 0;
		for (i = 0; i < ixyz; i++)
		{
			if (initial_conditions[i * 7] < 0 && initial_conditions[7 * i] > -100)
			{
				std::ostringstream errstr;
				errstr << "Cannot have inactive cells in a 1D simulation.";
				error_msg(errstr.str().c_str(), 1);
			}
			this->n_to_ijk(i, ii, jj, kk);
			if (ii == 0 && kk == 0)
			{
				this->forward.push_back(n);

				std::vector <int> temp;
				this->back.push_back(temp);
				this->back[n].push_back(i);
				this->back[n].push_back(i + 1);
				this->back[n].push_back(i + ixy);
				this->back[n].push_back(i + ixy + 1);
				n++;
			}
			else
			{
				this->forward.push_back(-1);
			}
		}
		this->count_chem = n;
	}
/*
 *   Copy z line
 */
	else if (!axes[0] && !axes[1] && axes[2])
	{
		if (this->nx != 2)
		{
			std::ostringstream errstr;
			errstr << "X direction should contain only two nodes for this 1D problem." ;
			error_msg(errstr.str().c_str(), 1);
		}
		if (this->ny != 2)
		{
			std::ostringstream errstr;
			errstr << "Y direction should contain only two nodes for this 1D problem." ;
			error_msg(errstr.str().c_str(), 1);
		}
		n = 0;
		for (i = 0; i < ixyz; i++)
		{
			if (initial_conditions[i * 7] < 0 && initial_conditions[7 * i] > -100)
			{
				std::ostringstream errstr;
				errstr << "Cannot have inactive cells in a 1D simulation.";
				error_msg(errstr.str().c_str(), 1);
			}
			this->n_to_ijk(i, ii, jj, kk);
			if (ii == 0 && jj == 0)
			{
				this->forward.push_back(n);
				
				std::vector <int> temp;
				this->back.push_back(temp);
				this->back[n].push_back(i);
				this->back[n].push_back(i + 1);
				this->back[n].push_back(i + this->nx);
				this->back[n].push_back(i + this->nx + 1);
				n++;
			}
			else
			{
				this->forward.push_back(-1);
			}
		}
		this->count_chem = n;
	}
	return;
}
/* ---------------------------------------------------------------------- */
int
Reaction_module::Find_components(void)	
/* ---------------------------------------------------------------------- */
{
/*
 *   Counts components in any defined solution, gas_phase, exchanger,
 *   surface, or pure_phase_assemblage
 *
 *   Returns 
 *		n_comp, which is total, including H, O, elements, and Charge
 *      names, which contains character strings with names of components
 */
	// Always include H, O, Charge
	this->components.clear();
	this->components.push_back("H");
	this->components.push_back("O");
	this->components.push_back("Charge");

	// Get other components
	IPhreeqcPhast * phast_iphreeqc_worker = this->Get_workers()[0];
	size_t count_components = phast_iphreeqc_worker->GetComponentCount();
	size_t i;
	for (i = 0; i < count_components; i++)
	{
		std::string comp(phast_iphreeqc_worker->GetComponent((int) i));
		assert (comp != "H");
		assert (comp != "O");
		assert (comp != "Charge");
		assert (comp != "charge");

		this->components.push_back(comp);
	}
	// Calculate gfw for components
	for (i = 0; i < components.size(); i++)
	{
		if (components[i] == "Charge")
		{
			this->gfw.push_back(1.0);
		}
		else
		{
			this->gfw.push_back(phast_iphreeqc_worker->Get_gfw(components[i].c_str()));
		}
	}
	if (this->mpi_myself == 0)
	{
		std::ostringstream outstr;
		outstr << "List of Components:\n" << std::endl;
		for (i = 0; i < this->components.size(); i++)
		{
			outstr << "\t" << i + 1 << "\t" << this->components[i].c_str() << std::endl;
		}
		Write_output(outstr.str());
	}
	return (int) this->components.size();
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Fractions2Solutions_thread(int n)
/* ---------------------------------------------------------------------- */
{
	int i, j, k;

	for (j = this->start_cell[n]; j <= this->end_cell[n]; j++)
	{
		std::vector<double> d;  // scratch space to convert from mass fraction to moles
		// j is count_chem number
		//j = this->forward[i];
		i = this->back[j][0];
		if (j < 0) continue;

		// get mass fractions and store as moles in d
		double *ptr = &this->fraction[i];
		for (k = 0; k < (int) this->components.size(); k++)
		{	
			d.push_back(ptr[this->nxyz * k] * 1000.0/this->gfw[k]);
		}

		// update solution 
		cxxNameDouble nd;
		for (k = 3; k < (int) components.size(); k++)
		{
			if (d[k] <= 1e-14) d[k] = 0.0;
			nd.add(components[k].c_str(), d[k]);
		}	

		cxxSolution *soln_ptr = this->Get_workers()[n]->Get_solution(j);
		//this->sz_bin.Get_Solution((int) j)->Update(
		if (soln_ptr)
		{
			soln_ptr->Update(
				d[0] + 2.0/gfw_water,
				d[1] + 1.0/gfw_water,
				d[2],
				nd);
		}
	}
	return;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Fractions2Solutions(void)
/* ---------------------------------------------------------------------- */
{
	int i, j, k;

	for (int n = 0; n < this->nthreads; n++)	
	{

		for (j = this->start_cell[n]; j < this->end_cell[n]; j++)
		{
			std::vector<double> d;  // scratch space to convert from mass fraction to moles
			// j is count_chem number
			i = this->back[j][0];
			if (j < 0) continue;

			// get mass fractions and store as moles in d
			double *ptr = &this->fraction[i];
			for (k = 0; k < (int) this->components.size(); k++)
			{	
				d.push_back(ptr[this->nxyz * k] * 1000.0/this->gfw[k]);
			}

			// update solution 
			cxxNameDouble nd;
			for (k = 3; k < (int) components.size(); k++)
			{
				if (d[k] <= 1e-14) d[k] = 0.0;
				nd.add(components[k].c_str(), d[k]);
			}
			cxxSolution *soln_ptr = this->Get_workers()[n]->Get_solution(j);
			if (soln_ptr)
			{
				soln_ptr->Update(
					d[0] + 2.0/gfw_water,
					d[1] + 1.0/gfw_water,
					d[2],
					nd);
			}
		}
	}
	return;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Init_uz(void)
/* ---------------------------------------------------------------------- */
{
	int	i;

	if (transient_free_surface)
	{
		for (i = 0; i < nxyz; i++)
		{
			old_frac.push_back(1.0);
		}
	}
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Initial_phreeqc_run_thread(int n)
/* ---------------------------------------------------------------------- */
{
		IPhreeqcPhast * iphreeqc_phast_worker = this->Get_workers()[n];
		int ipp_id = (int) iphreeqc_phast_worker->Get_Index();

		iphreeqc_phast_worker->SetOutputFileOn(false);
		iphreeqc_phast_worker->SetErrorFileOn(false);
		iphreeqc_phast_worker->SetLogFileOn(false);
		iphreeqc_phast_worker->SetSelectedOutputStringOn(false);
		if (n == 0)
		{
			iphreeqc_phast_worker->SetSelectedOutputFileOn(true);
			iphreeqc_phast_worker->SetOutputStringOn(true);
		}
		else
		{
			iphreeqc_phast_worker->SetSelectedOutputFileOn(false);
			iphreeqc_phast_worker->SetOutputStringOn(false);
		}

		// Load database
		if (iphreeqc_phast_worker->LoadDatabase(this->database_file_name.c_str()) > 0) RM_error(&ipp_id);
		if (n == 0)
		{
			Write_output(iphreeqc_phast_worker->GetOutputString());
		}

		// Run chemistry file
		if (iphreeqc_phast_worker->RunFile(this->chemistry_file_name.c_str()) > 0) RM_error(&ipp_id);

		// Create a StorageBin with initial PHREEQC for boundary conditions
		if (n == 0)
		{
			Write_output(iphreeqc_phast_worker->GetOutputString());
			this->Get_phreeqc_bin().Clear();
			this->Get_workers()[0]->Get_PhreeqcPtr()->phreeqc2cxxStorageBin(this->Get_phreeqc_bin());
		}
		if (n == this->nthreads)
		{
			iphreeqc_phast_worker->SetSelectedOutputStringOn(true);
			std::string in ="SOLUTION";
			iphreeqc_phast_worker->RunString(in.c_str());
			std::vector<std::string> names;
			for (int i = 0; i < iphreeqc_phast_worker->GetSelectedOutputColumnCount(); i++)
			{
				VAR v;
				VarInit(&v);
				iphreeqc_phast_worker->GetSelectedOutputValue(0, i, &v);
				names.push_back(v.sVal);
			}
			HDFSetScalarNames(names);
			this->selected_output_names = names;
		}
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Initial_phreeqc_run(std::string database_name, std::string chemistry_name, std::string prefix)
/* ---------------------------------------------------------------------- */
{
	/*
	*  Run PHREEQC to obtain PHAST reactants
	*/
	this->database_file_name = database_name;
	this->chemistry_file_name = chemistry_name;
	this->file_prefix = prefix;

	// load database and run chemistry file
	// Eventually need an copy operator for IPhreeqcPhast
#ifdef THREADED_PHAST
	omp_set_num_threads(this->nthreads+1);
	#pragma omp parallel 
	#pragma omp for
#endif
	for (int n = 0; n <= this->nthreads; n++)
	{
		Initial_phreeqc_run_thread(n);
	} 	

}
/* ---------------------------------------------------------------------- */
bool
Reaction_module::n_to_ijk(int n, int &i, int &j, int &k) 
/* ---------------------------------------------------------------------- */
{

	k = n / (this->nx * this->ny) ;
	j = (n % (this->nx * this->ny)) / this->nx;
	i = (n % (this->nx * this->ny)) % this->nx;

	if (k < 0 || k >= this->nz)
	{
		error_msg("Z index out of range");
		return false;
	}
	if (j < 0 || j >= this->ny)
	{
		error_msg("Y index out of range");
		return false;
	}
	if (i < 0 || i >= this->nx)
	{
		error_msg("X index out of range");
		return false;
	}
	return true;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Partition_uz_thread(int n, int iphrq, int ihst, double new_frac)
/* ---------------------------------------------------------------------- */
{
	int n_user;
	double s1, s2, uz1, uz2;

	/* 
	 * repartition solids for partially saturated cells
	 */

	if ((fabs(this->old_frac[ihst] - new_frac) > 1e-8) ? true : false)
		return;

	n_user = iphrq;

	if (new_frac >= 1.0)
	{
		/* put everything in saturated zone */
		uz1 = 0;
		uz2 = 0;
		s1 = 1.0;
		s2 = 1.0;
	}
	else if (new_frac <= 1e-10)
	{
		/* put everything in unsaturated zone */
		uz1 = 1.0;
		uz2 = 1.0;
		s1 = 0.0;
		s2 = 0.0;
	}
	else if (new_frac > this->old_frac[ihst])
	{
		/* wetting cell */
		uz1 = 0.;
		uz2 = (1.0 - new_frac) / (1.0 - this->old_frac[ihst]);
		s1 = 1.;
		s2 = 1.0 - uz2;
	}
	else
	{
		/* draining cell */
		s1 = new_frac / this->old_frac[ihst];
		s2 = 0.0;
		uz1 = 1.0 - s1;
		uz2 = 1.0;
	}
	cxxMix szmix, uzmix;
	szmix.Add(0, s1);
	szmix.Add(1, s2);
	uzmix.Add(0, uz1);
	uzmix.Add(1, uz2);
	/*
	 *   Calculate new compositions
	 */

	cxxStorageBin sz_bin;
	IPhreeqcPhast *phast_iphreeqc_worker = this->workers[n];
	phast_iphreeqc_worker->Put_cell_in_storage_bin(sz_bin, n_user);

//Exchange
	if (sz_bin.Get_Exchange(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.Set_Exchange(0, sz_bin.Get_Exchange(n_user));
		tempBin.Set_Exchange(1, this->uz_bin.Get_Exchange(n_user));
		cxxExchange newsz(tempBin.Get_Exchangers(), szmix, n_user);
		cxxExchange newuz(tempBin.Get_Exchangers(), uzmix, n_user);
		sz_bin.Set_Exchange(n_user, &newsz);
		this->uz_bin.Set_Exchange(n_user, &newuz);
	}
//PPassemblage
	if (sz_bin.Get_PPassemblage(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.Set_PPassemblage(0, sz_bin.Get_PPassemblage(n_user));
		tempBin.Set_PPassemblage(1, this->uz_bin.Get_PPassemblage(n_user));
		cxxPPassemblage newsz(tempBin.Get_PPassemblages(), szmix, n_user);
		cxxPPassemblage newuz(tempBin.Get_PPassemblages(), uzmix, n_user);
		sz_bin.Set_PPassemblage(n_user, &newsz);
		this->uz_bin.Set_PPassemblage(n_user, &newuz);
	}
//Gas_phase
	if (sz_bin.Get_GasPhase(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.Set_GasPhase(0, sz_bin.Get_GasPhase(n_user));
		tempBin.Set_GasPhase(1, this->uz_bin.Get_GasPhase(n_user));
		cxxGasPhase newsz(tempBin.Get_GasPhases(), szmix, n_user);
		cxxGasPhase newuz(tempBin.Get_GasPhases(), uzmix, n_user);
		sz_bin.Set_GasPhase(n_user, &newsz);
		this->uz_bin.Set_GasPhase(n_user, &newuz);
	}
//SSassemblage
	if (sz_bin.Get_SSassemblage(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.Set_SSassemblage(0, sz_bin.Get_SSassemblage(n_user));
		tempBin.Set_SSassemblage(1, this->uz_bin.Get_SSassemblage(n_user));
		cxxSSassemblage newsz(tempBin.Get_SSassemblages(), szmix, n_user);
		cxxSSassemblage newuz(tempBin.Get_SSassemblages(), uzmix, n_user);
		sz_bin.Set_SSassemblage(n_user, &newsz);
		this->uz_bin.Set_SSassemblage(n_user, &newuz);
	}
//Kinetics
	if (sz_bin.Get_Kinetics(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.Set_Kinetics(0, sz_bin.Get_Kinetics(n_user));
		tempBin.Set_Kinetics(1, this->uz_bin.Get_Kinetics(n_user));
		cxxKinetics newsz(tempBin.Get_Kinetics(), szmix, n_user);
		cxxKinetics newuz(tempBin.Get_Kinetics(), uzmix, n_user);
		sz_bin.Set_Kinetics(n_user, &newsz);
		this->uz_bin.Set_Kinetics(n_user, &newuz);
	}
//Surface
	if (sz_bin.Get_Surface(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.Set_Surface(0, sz_bin.Get_Surface(n_user));
		tempBin.Set_Surface(1, this->uz_bin.Get_Surface(n_user));
		cxxSurface newsz(tempBin.Get_Surfaces(), szmix, n_user);
		cxxSurface newuz(tempBin.Get_Surfaces(), uzmix, n_user);
		sz_bin.Set_Surface(n_user, &newsz);
		this->uz_bin.Set_Surface(n_user, &newuz);
	}

	// Put back in reaction module
	phast_iphreeqc_worker->Get_cell_from_storage_bin(sz_bin, n_user);

	/*
	 *   Eliminate uz if new fraction 1.0
	 */
	if (new_frac >= 1.0)
	{
		this->uz_bin.Remove(iphrq);
	}

	this->old_frac[ihst] = new_frac;
}
void
Reaction_module::Rebalance_load(void)
/* ---------------------------------------------------------------------- */
{
	if (this->nthreads <= 1) return;
#include <time.h>

	std::vector<int> start_cell_new;
	std::vector<int> end_cell_new;
	for (int i = 0; i < this->nthreads; i++)
	{
		start_cell_new.push_back(0);
		end_cell_new.push_back(0);
	}

	std::vector<int> cells_v;
	bool error = false;
	std::ostringstream error_stream;
	/*
	 *  Gather times of all tasks
	 */
	std::vector<double> recv_buffer;

	double total = 0;
	for (int i = 0; i < this->nthreads; i++)
	{
		IPhreeqcPhast * phast_iphreeqc_worker = this->workers[i];
		int cells = this->end_cell[i] - this->start_cell[i] + 1;
		//std::cerr << "Time: " << i << "  " << phast_iphreeqc_worker->Get_thread_clock_time() << 
		//	"Time per cell: " << phast_iphreeqc_worker->Get_thread_clock_time()/ ((double) cells)  << "\n";
		recv_buffer.push_back(phast_iphreeqc_worker->Get_thread_clock_time()/((double) cells));
		if (recv_buffer.back() <= 0)
		{
			error_stream << "Time for  cell " << i << ": " << recv_buffer.back() << "\n";
			error = true;
			break;
		}
		total += recv_buffer[0] / recv_buffer.back();
		//std::cerr << "Total: " << total << "  " << recv_buffer[0] / recv_buffer.back() << "\n";
	}
	for (int i = 0; i < this->nthreads; i++)
	{

	}
	
	if (error)
	{
		error_msg(error_stream.str().c_str(), STOP);
	}

	/*
	 *  Set first and last cells
	 */
	double new_n = this->count_chem / total; /* new_n is number of cells for root */
	int	total_cells = 0;
	int n = 0;
	/*
	*  Calculate number of cells per process, rounded to lower number
	*/
	for (int i = 0; i < this->nthreads; i++)
	{
		n = (int) floor(new_n * recv_buffer[0] / recv_buffer[i]);
		if (n < 1)
			n = 1;
		cells_v.push_back(n);
		total_cells += n;
	}
	/*
	*  Distribute cells from rounding down
	*/
	int diff_cells = this->count_chem - total_cells;
	if (diff_cells > 0)
	{
		for (int j = 0; j < diff_cells; j++)
		{
			int min_cell = 0;
			double min_time = (cells_v[0] + 1) * recv_buffer[0];
			for (int i = 1; i < this->nthreads; i++)
			{
				if ((cells_v[i] + 1) * recv_buffer[i] < min_time)
				{
					min_cell = i;
					min_time = (cells_v[i] + 1) * recv_buffer[i];
				}
			}
			cells_v[min_cell] += 1;
		}
	}
	else if (diff_cells < 0)
	{
		for (int j = 0; j < -diff_cells; j++)
		{
			int max_cell = -1;
			double max_time = 0;
			for (int i = 0; i < this->nthreads; i++)
			{
				if (cells_v[i] > 1)
				{
					if ((cells_v[i] - 1) * recv_buffer[i] > max_time)
					{
						max_cell = i;
						max_time = (cells_v[i] - 1) * recv_buffer[i];
					}
				}
			}
			cells_v[max_cell] -= 1;
		}
	}
	/*
	*  Fill in subcolumn ends
	*/
	int last = -1;
	for (int i = 0; i < this->nthreads; i++)
	{
		start_cell_new[i] = last + 1;
		end_cell_new[i] = start_cell_new[i] + cells_v[i] - 1;
		last = end_cell_new[i];
	}
	/*
	*  Check that all cells are distributed
	*/
	if (end_cell_new[this->nthreads - 1] != this->count_chem - 1)
	{
		error_stream << "Failed: " << diff_cells << ", count_cells " << this->count_chem << ", last cell "
			<< end_cell_new[this->nthreads - 1] << "\n";
		for (int i = 0; i < this->nthreads; i++)
		{
			error_stream << i << ": first " << start_cell_new[i] << "\tlast " << end_cell_new[i] << "\n";
		}
		error_stream << "Failed to redistribute cells." << "\n";
		error_msg(error_stream.str().c_str(), STOP);
	}
	/*
	*   Compare old and new times
	*/
	double max_old = 0.0;
	double max_new = 0.0;
	for (int i = 0; i < this->nthreads; i++)
	{
		double t = cells_v[i] * recv_buffer[i];
		if (t > max_new)
			max_new = t;
		t = (end_cell[i] - start_cell[i] + 1) * recv_buffer[i];
		if (t > max_old)
			max_old = t;
	}
	std::cerr << "          Estimated efficiency of chemistry " << (float) ((LDBLE) 100. * max_new / max_old) << "\n";


	if ((max_old - max_new) / max_old < 0.01)
	{
		for (int i = 0; i < this->nthreads; i++)
		{
			start_cell_new[i] = start_cell[i];
			end_cell_new[i] = end_cell[i];
		}
	}
	else
	{
		for (int i = 0; i < this->nthreads - 1; i++)
		{
			int icells = (int) ((end_cell_new[i] - end_cell[i]) * *this->rebalance_fraction_hst);
			end_cell_new[i] = end_cell[i] + icells;
			start_cell_new[i + 1] = end_cell_new[i] + 1;
		}
	}
	/*
	 *   Redefine columns
	 */
	int nnew = 0;
	int old = 0;
	int change = 0;

	for (int k = 0; k < this->count_chem; k++)
	{
		int i = k;
		int iphrq = i;			/* iphrq is 1 to count_chem */
		int ihst = this->back[i][0];	/* ihst is 1 to nxyz */
		while (k > end_cell[old])
		{
			old++;
		}
		while (k > end_cell_new[nnew])
		{
			nnew++;
		}

		if (old == nnew)
			continue;
		change++;
		IPhreeqcPhast * old_worker = this->workers[old];
		IPhreeqcPhast * new_worker = this->workers[nnew];
		cxxStorageBin temp_bin; 
		old_worker->Get_PhreeqcPtr()->phreeqc2cxxStorageBin(temp_bin, iphrq);
		new_worker->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(temp_bin, iphrq);
		std::ostringstream del;
		del << "DELETE; -cell " << iphrq << "\n";
		old_worker->RunString(del.str().c_str());
	}

	for (int i = 0; i < this->nthreads; i++)
	{
		start_cell[i] = start_cell_new[i];
		end_cell[i] = end_cell_new[i];
		IPhreeqcPhast * worker = this->workers[i];
		worker->Set_start_cell(start_cell_new[i]);
		worker->Set_end_cell(end_cell_new[i]);
	}
	std::cerr << "          Cells shifted between threads     " << change << "\n";

	return;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Run_cells()
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes mass fractions from HST, equilibrates each cell,
 *   and returns new mass fractions to HST
 */

/*
 *   Update solution compositions in sz_bin
 */
	clock_t t0 = clock();
	for (int n = 0; n < this->nthreads; n++)
	{
		IPhreeqcPhast * phast_iphreeqc_worker = this->workers[n];
		phast_iphreeqc_worker->Set_out_stream(new ostringstream); 
		phast_iphreeqc_worker->Set_punch_stream(new ostringstream);
	}
#ifdef THREADED_PHAST
	omp_set_num_threads(this->nthreads);
	#pragma omp parallel 
	#pragma omp for
#endif
	for (int n = 0; n < this->nthreads; n++)
	{
		Run_cells_thread(n);
	} 

	// Output
	if (this->print_hdf)
	{
		BeginTimeStep();
	}
	for (int n = 0; n < this->nthreads; n++)
	{
		// write output results
		if (this->print_chem)
		{
			Write_output(this->workers[n]->Get_out_stream().str().c_str());
		}
		delete &this->workers[n]->Get_out_stream();

		// write punch results
		if (this->print_xyz)
		{
			Write_xyz(this->workers[n]->Get_punch_stream().str().c_str());
		}
		delete &this->workers[n]->Get_punch_stream();

		// write restart
		if (this->print_restart)
		{
			this->Write_restart();
		}

		// write hdf
		if (this->print_hdf)
		{
			HDFFillHyperSlab(this->start_cell[n], this->workers[n]->Get_punch_vector());
		}
		this->workers[n]->Get_punch_vector().clear();
	} 	
	if (this->print_hdf)
	{
		EndTimeStep();
	}
	//std::cerr << "Running: " << (double) (clock() - t0) << std::endl;
}
/* ---------------------------------------------------------------------- */
void 
Reaction_module::Run_cells_thread(int n)
/* ---------------------------------------------------------------------- */
{
	/*
	*   Routine takes mass fractions from HST, equilibrates each cell,
	*   and returns new mass fractions to HST
	*/

	/*
	*   Update solution compositions 
	*/
	clock_t t0 = clock();
	this->Fractions2Solutions_thread(n);

	int i, j;
	IPhreeqcPhast *phast_iphreeqc_worker = this->Get_workers()[n];

	// Do not write to files from phreeqc, run_cells writes files
	phast_iphreeqc_worker->SetLogFileOn(false);
	phast_iphreeqc_worker->SetSelectedOutputFileOn(false);
	phast_iphreeqc_worker->SetDumpFileOn(false);
	phast_iphreeqc_worker->SetDumpStringOn(false);
	phast_iphreeqc_worker->SetOutputFileOn(false);
	phast_iphreeqc_worker->SetErrorFileOn(false);

	for (i = this->start_cell[n]; i <= this->end_cell[n]; i++)
	{							/* i is count_chem number */
		j = back[i][0];			/* j is nxyz number */

		// Set local print flags
		bool pr_chem = this->print_chem && (this->printzone_chem[j] != 0);
		bool pr_xyz = this->print_xyz && (this->printzone_xyz[i] != 0);
		bool pr_hdf = this->print_hdf;

		// partition solids between UZ and SZ
		if (transient_free_surface)	
		{
			this->Partition_uz_thread(n, i, j, frac[j]);
		}

		// ignore small saturations
		bool active = true;
		if (frac[j] <= 1e-10) 
		{
			frac[j] = 0.0;
			active = false;
		}

		if (active)
		{
			// set cell number, pore volume got Basic functions
			phast_iphreeqc_worker->Set_cell_volumes(i, pv0[j], frac[j], volume[j]);

			// Adjust for fractional saturation and pore volume
			if (this->transient_free_surface)
			{
				this->Scale_solids(n, i, 1.0 / frac[j]);
			}
			if (!transient_free_surface && !steady_flow)
			{
				if (pv0[j] != 0 && pv[j] != 0 && pv0[j] != pv[j])
				{
					cxxSolution * cxxsol = phast_iphreeqc_worker->Get_solution(i);
					cxxsol->multiply(pv[j] / pv0[j]);
				}
			}

			// Set print flags
			phast_iphreeqc_worker->SetOutputStringOn(pr_chem);
			phast_iphreeqc_worker->SetSelectedOutputStringOn(pr_xyz);

			// do the calculation
			std::ostringstream input;
			input << "RUN_CELLS\n";
			input << "  -start_time " << (*this->time_hst - *this->time_step_hst) << "\n";
			input << "  -time_step  " << *this->time_step_hst << "\n";
			input << "  -cells      " << i << "\n";
			input << "END" << "\n";
			if (phast_iphreeqc_worker->RunString(input.str().c_str()) < 0) Error_stop();

			// Adjust for fractional saturation and pore volume
			if (transient_free_surface == TRUE)
				this->Scale_solids(n, i, frac[j]);
			assert(pv0[j] != 0);
			assert(pv[j] != 0);
			if (!transient_free_surface && !steady_flow)
			{
				if (pv0[j] != 0 && pv[j] != 0 && pv0[j] != pv[j])
				{
					cxxSolution * cxxsol = phast_iphreeqc_worker->Get_solution(i);
					cxxsol->multiply(pv0[j] / pv[j]);
				}
			}

			// write headings to xyz file
			if (pr_xyz && this->write_xyz_headings)
			{
				char line_buff[132];
				sprintf(line_buff, "%15s\t%15s\t%15s\t%15s\t%2s\t", "x", "y",
					"z", "time", "in");

				std::ostringstream h;
				int n = phast_iphreeqc_worker->GetSelectedOutputColumnCount();
				VAR pv;
				VarInit(&pv);
				for (int i = 0; i < n; i++)
				{
					phast_iphreeqc_worker->GetSelectedOutputValue(0, i, &pv);
					h.width(15);
					std::string s(pv.sVal);
					s.append("\t");
					h.width(15);
					h << s;
				}
				VarClear(&pv);

				this->write_xyz_headings = false;
				phast_iphreeqc_worker->Get_punch_stream() << line_buff;
				phast_iphreeqc_worker->Get_punch_stream() << h.str().c_str() << "\n";
			}

			// write xyz file
			if (pr_xyz)
			{
				char line_buff[132];
				sprintf(line_buff, "%15g\t%15g\t%15g\t%15g\t%2d\t",
					x_node[j], y_node[j], z_node[j], (*time_hst) * (*cnvtmi),
					active);
				phast_iphreeqc_worker->Get_punch_stream() << line_buff;
				phast_iphreeqc_worker->Get_punch_stream() << phast_iphreeqc_worker->GetSelectedOutputStringLine(0) << "\n";
			}

			// Write output file
			if (pr_chem)
			{
				char line_buff[132];
				sprintf(line_buff, "Time %g. Cell %d: x=%15g\ty=%15g\tz=%15g\n",
					(*time_hst) * (*cnvtmi), j + 1, x_node[j],  y_node[j],
					z_node[j]);
				phast_iphreeqc_worker->Get_out_stream() << line_buff;
				phast_iphreeqc_worker->Get_out_stream() << phast_iphreeqc_worker->GetOutputString();
			}

			// Write output file
			if (pr_hdf)
			{
				phast_iphreeqc_worker->Selected_out_to_double();
			}
		} // end active
		else
		{
			if (pr_chem)
			{
				std::ostringstream line;
				line << "Time " << (*time_hst) * (*cnvtmi);
				line << ". Cell " << j + 1 << ": ";
				line << "x= " << x_node[j] << "\t";
				line << "y= " << y_node[j] << "\t";
				line << "z= " << z_node[j] << "\n";
				line << "Cell is dry.\n";
				phast_iphreeqc_worker->Get_out_stream() << line.str().c_str();
			}
			// write xyz file
			if (pr_xyz)
			{
				char line_buff[132];
				sprintf(line_buff, "%15g\t%15g\t%15g\t%15g\t%2d\t\n",
					x_node[j], y_node[j], z_node[j], (*time_hst) * (*cnvtmi),
					active);
				phast_iphreeqc_worker->Get_punch_stream() << line_buff;
			}
			// Write output file
			if (pr_hdf)
			{	
				std::vector<LDBLE> empty;
				phast_iphreeqc_worker->Get_punch_vector().push_back(empty);
			}
		}
		if (i%50 == 0 && (n == 1 /*|| n == 2*/))
		{
			std::cerr << "\tThread: " << n << " Time: " << (double) (clock() - t0) << " Cell: " << i << "\n";
		}
	} // end one cell

	this->Solutions2Fractions_thread(n);
	clock_t t_elapsed = clock() - t0;
	std::cerr << "Thread: " << n << " Time: " << (double) t_elapsed << " Cells: " << this->end_cell[n] - this->start_cell[n] + 1 << std::endl;
	phast_iphreeqc_worker->Set_thread_clock_time((double) t_elapsed);
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Scale_solids(int n, int iphrq, LDBLE frac)
/* ---------------------------------------------------------------------- */
{
	int n_user;

	/* 
	 * repartition solids for partially saturated cells
	 */

	//if (equal(old_frac[ihst], new_frac, 1e-8) == TRUE)  return(OK);

	n_user = iphrq;
	cxxMix cxxmix;
	cxxmix.Add(n_user, frac);
	/*
	 *   Scale compositions
	 */
	cxxStorageBin sz_bin;
	IPhreeqcPhast *phast_iphreeqc_worker = this->workers[n];
	phast_iphreeqc_worker->Put_cell_in_storage_bin(sz_bin, n_user);
	if (sz_bin.Get_Exchange(n_user) != NULL)
	{
		cxxExchange cxxentity(sz_bin.Get_Exchangers(), cxxmix, n_user);
		sz_bin.Set_Exchange(n_user, &cxxentity);
	}
	if (sz_bin.Get_PPassemblage(n_user) != NULL)
	{
		cxxPPassemblage cxxentity(sz_bin.Get_PPassemblages(), cxxmix, n_user);
		sz_bin.Set_PPassemblage(n_user, &cxxentity);
	}
	if (sz_bin.Get_GasPhase(n_user) != NULL)
	{
		cxxGasPhase cxxentity(sz_bin.Get_GasPhases(), cxxmix, n_user);
		sz_bin.Set_GasPhase(n_user, &cxxentity);
	}
	if (sz_bin.Get_SSassemblage(n_user) != NULL)
	{
		cxxSSassemblage cxxentity(sz_bin.Get_SSassemblages(), cxxmix, n_user);
		sz_bin.Set_SSassemblage(n_user, &cxxentity);
	}
	if (sz_bin.Get_Kinetics(n_user) != NULL)
	{
		cxxKinetics cxxentity(sz_bin.Get_Kinetics(), cxxmix, n_user);
		sz_bin.Set_Kinetics(n_user, &cxxentity);
	}
	if (sz_bin.Get_Surface(n_user) != NULL)
	{
		cxxSurface cxxentity(sz_bin.Get_Surfaces(), cxxmix, n_user);
		sz_bin.Set_Surface(n_user, &cxxentity);
	}
	phast_iphreeqc_worker->Get_cell_from_storage_bin(sz_bin, n_user);
	return;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Send_restart_name(std::string name)
/* ---------------------------------------------------------------------- */
{
	int	i = (int) FileMap.size();
	FileMap[name] = i;
}
#ifdef USE_MPI
void
Reaction_module::Set_end_cells(void)
/* ---------------------------------------------------------------------- */
{
	int n = this->count_chem / this->mpi_tasks;
	int extra = this->count_chem - n*this->mpi_tasks;
	std::vector<int> cells;
	for (int i = 0; i < extra; i++)
	{
		cells.push_back(n+1);
	}
	for (int i = extra; i < this->mpi_tasks; i++)
	{
		cells.push_back(n);
	}
	int cell0 = 0;
	for (int i = 0; i < this->mpi_tasks; i++)
	{
		this->start_cell.push_back(cell0);
		this->end_cell.push_back(cell0 + cells[i] - 1);
		cell0 = cell0 + cells[i];
	}
	
}
#else
void
Reaction_module::Set_end_cells(void)
/* ---------------------------------------------------------------------- */
{
	int n = this->count_chem / this->nthreads;
	int extra = this->count_chem - n*this->nthreads;
	std::vector<int> cells;
	for (int i = 0; i < extra; i++)
	{
		cells.push_back(n+1);
	}
	for (int i = extra; i < this->nthreads; i++)
	{
		cells.push_back(n);
	}
	int cell0 = 0;
	for (int i = 0; i < this->nthreads; i++)
	{
		this->start_cell.push_back(cell0);
		this->end_cell.push_back(cell0 + cells[i] - 1);
		cell0 = cell0 + cells[i];
	}
}
#endif
/* ---------------------------------------------------------------------- */
void
Reaction_module::Setup_boundary_conditions(
					const int n_boundary, 
					int *boundary_solution1,
					int *boundary_solution2, 
					double *fraction1,
					double *boundary_fraction, 
					int dim)
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes a list of solution numbers and returns a set of
 *   mass fractions
 *   Input: n_boundary - number of boundary conditions in list
 *          boundary_solution1 - list of first solution numbers to be mixed
 *          boundary_solution2 - list of second solution numbers to be mixed
 *          fraction1 - fraction of first solution 0 <= f <= 1
 *          dim - leading dimension of array boundary mass fractions
 *                must be >= to n_boundary
 *
 *   Output: boundary_fraction - mass fractions for boundary conditions
 *                             - dimensions must be >= n_boundary x n_comp
 *
 */
	int	i, n_old1, n_old2;
	double f1, f2;

	for (i = 0; i < n_boundary; i++)
	{
		cxxMix mixmap;
		n_old1 = boundary_solution1[i];
		n_old2 = boundary_solution2[i];
		f1 = fraction1[i];
		f2 = 1 - f1;
		mixmap.Add(n_old1, f1);
		if (f2 > 0.0)
		{
			mixmap.Add(n_old2, f2);
		}
		
		// Make mass fractions in d
		cxxSolution	cxxsoln(phreeqc_bin.Get_Solutions(), mixmap, 0);
		std::vector<double> d;
		cxxSolution2fraction(&cxxsoln, d);

		// Put mass fractions in boundary_fraction
		double *d_ptr = &boundary_fraction[i];
		size_t j;
		for (j = 0; j < components.size(); j++)
		{
			d_ptr[dim * j] = d[j];
		}
	}
}
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
void
Reaction_module::Solutions2Fractions(void)
/* ---------------------------------------------------------------------- */
{
	// convert Reaction module solution data to hst mass fractions
	MPI_Status mpi_status;
	std::vector<double> d;  // scratch space to convert from moles to mass fraction
	std::vector<double> solns;
	cxxNameDouble::iterator it;

	int n = this->mpi_myself;
	for (int j = this->start_cell[n]; j <= this->end_cell[n]; j++)
	{
		// load fractions into d
		cxxSolution * cxxsoln_ptr = this->Get_workers()[0]->Get_solution(j);
		assert (cxxsoln_ptr);
		this->cxxSolution2fraction(cxxsoln_ptr, d);
		for (int i = 0; i < this->components.size(); i++)
		{
			solns.push_back(d[i]);
		}
	}
	
	// make buffer to recv solutions
	double * recv_solns = new double[(size_t) this->count_chem * this->components.size()];

	// each thread has its own vector of solution components
	// gather vectors to root
	for (int n = 1; n < this->mpi_tasks; n++)
	{
		int count = this->end_cell[n] - this->start_cell[n] + 1;
		int num_doubles = count * (int) this->components.size();
		if (this->mpi_myself == n)
		{
			MPI_Send((void *) solns.data(), num_doubles, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
		}
		else if (this->mpi_myself == 0)
		{
			MPI_Recv(recv_solns, num_doubles, MPI_DOUBLE, n, 0, MPI_COMM_WORLD, &mpi_status);
			for (int i = 0; i < num_doubles; i++)
			{
				solns.push_back(recv_solns[i]);
			}
		}
	}

	// delete recv buffer
	delete recv_solns;

	// Write vector into fraction
	if (this->mpi_myself == 0)
	{
		assert (solns.size() == this->count_chem*this->components.size());
		int n = 0;
		for (int j = 0; j < count_chem; j++)
		{
			std::vector<double> d;
			for (size_t i = 0; i < this->components.size(); i++)
			{
				d.push_back(solns[n++]);
			}
			std::vector<int>::iterator it;
			for (it = this->back[j].begin(); it != this->back[j].end(); it++)
			{
				double *d_ptr = &this->fraction[*it];
				size_t i;
				for (i = 0; i < this->components.size(); i++)
				{
					d_ptr[this->nxyz * i] = d[i];
				}
			}
		}
	}

}
#else
/* ---------------------------------------------------------------------- */
void
Reaction_module::Solutions2Fractions(void)
/* ---------------------------------------------------------------------- */
{
	// convert Reaction module solution data to hst mass fractions

	std::vector<double> d;  // scratch space to convert from moles to mass fraction
	cxxNameDouble::iterator it;

	int j; 

	for (int n = 0; n < this->nthreads; n++)
	{
		for (j = this->start_cell[n]; j <= this->end_cell[n]; j++)
		{
			// load fractions into d
			cxxSolution * cxxsoln_ptr = this->Get_workers()[n]->Get_solution(j);
			assert (cxxsoln_ptr);
			this->cxxSolution2fraction(cxxsoln_ptr, d);

			// store in fraction at 1, 2, or 4 places depending on chemistry dimensions
			std::vector<int>::iterator it;
			for (it = this->back[j].begin(); it != this->back[j].end(); it++)
			{
				double *d_ptr = &this->fraction[*it];
				size_t i;
				for (i = 0; i < this->components.size(); i++)
				{
					d_ptr[this->nxyz * i] = d[i];
				}
			}
		}
	}
}
#endif
/* ---------------------------------------------------------------------- */
void
Reaction_module::Solutions2Fractions_thread(int n)
/* ---------------------------------------------------------------------- */
{
	// convert Reaction module solution data to hst mass fractions

	std::vector<double> d;  // scratch space to convert from moles to mass fraction
	cxxNameDouble::iterator it;
	int j; 

	for (j = this->start_cell[n]; j <= this->end_cell[n]; j++)
	{
		// load fractions into d
		cxxSolution * cxxsoln_ptr = this->Get_workers()[n]->Get_solution(j);
		assert (cxxsoln_ptr);
		this->cxxSolution2fraction(cxxsoln_ptr, d);

		// store in fraction at 1, 2, or 4 places depending on chemistry dimensions
		std::vector<int>::iterator it;
		for (it = this->back[j].begin(); it != this->back[j].end(); it++)
		{
			double *d_ptr = &this->fraction[*it];
			size_t i;
			for (i = 0; i < this->components.size(); i++)
			{
				d_ptr[this->nxyz * i] = d[i];
			}
		}
	}
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Write_bc_raw(int *solution_list, int * bc_solution_count, 
			int * solution_number, const std::string &fn)
/* ---------------------------------------------------------------------- */
{
	if (*solution_number == 0) return;
	std::ofstream ofs;
	ofs.open(fn.c_str(), std::ios_base::app);
	if (!ofs.is_open())
	{
		std::ostringstream e_msg;
		e_msg << "Could not open file. " << fn;
		Write_error(e_msg.str());
		Error_stop();
	}

	int raw_number = *solution_number;
	for (int i = 0; i < *bc_solution_count; i++)
	{
		int n_fort = solution_list[i];
		int n_chem = this->forward[n_fort - 1];
		if (n_chem >= 0)
		{
			IPhreeqcPhast * phast_iphreeqc_worker = NULL;
			for (int j = 0; j < this->nthreads; j++)
			{
				if (j >= start_cell[j] && j <= end_cell[j])
				{
					phast_iphreeqc_worker = this->workers[j];
				}
			}
			if (phast_iphreeqc_worker)
			{
				ofs << "# Fortran cell " << n_fort << ". Time " << (*this->time_hst) * (*this->cnvtmi) << "\n";
				cxxSolution *soln_ptr=  phast_iphreeqc_worker->Get_solution(n_chem);
				soln_ptr->dump_raw(ofs, raw_number++, 0);
			}
			else
			{
				assert(false);
			}
		}
		else
		{
			assert(false);
		}
	}
	ofs << "# Done with zone for time step." << std::endl;
	ofs.close();
	return;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module:: Write_error(std::string item)
/* ---------------------------------------------------------------------- */
{
	RM_interface::phast_io.error_msg(item.c_str());
}
/* ---------------------------------------------------------------------- */
void
Reaction_module:: Write_log(std::string item)
/* ---------------------------------------------------------------------- */
{
	RM_interface::phast_io.log_msg(item.c_str());
}
/* ---------------------------------------------------------------------- */
void
Reaction_module:: Write_output(std::string item)
/* ---------------------------------------------------------------------- */
{
	RM_interface::phast_io.output_msg(item.c_str());
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Write_restart(void)
/* ---------------------------------------------------------------------- */
{

	std::string temp_name("temp_restart_file.gz");
	std::string name(this->file_prefix);
	name.append(".restart.gz");
	std::string backup_name(this->file_prefix);
	backup_name.append(".restart.backup.gz");

	// open file 
	ogzstream ofs_restart;
	ofs_restart.open(temp_name.c_str());
	if (!ofs_restart.good())
	{
		std::ostringstream errstr;
		errstr << "Temporary restart file could not be opened: " << temp_name;
		error_msg(errstr.str().c_str(), 1);	
	}

	// write header
	ofs_restart << "#PHAST restart file" << std::endl;
	time_t now = time(NULL);
	ofs_restart << "#Prefix: " << this->file_prefix << std::endl;
	ofs_restart << "#Date: " << ctime(&now);
	ofs_restart << "#Current model time: " << this->time_hst << std::endl;
	ofs_restart << "#nx, ny, nz: " << this->nx << ", " << this->ny << ", " << this->nz << std::
		endl;

	// write index
	int i, j;
	ofs_restart << count_chem << std::endl;
	for (j = 0; j < count_chem; j++)	/* j is count_chem number */
	{
		//i = back[j].list[0];	
		i = back[j][0];			/* i is nxyz number */
		ofs_restart << x_node[i] << "  " << y_node[i] << "  " <<
			z_node[i] << "  " << j << "  ";
		// solution 
		ofs_restart << ic1[7 * i] << "  ";
		// pp_assemblage
		ofs_restart << ic1[7 * i + 1] << "  ";
		// exchange
		ofs_restart << ic1[7 * i + 2] << "  ";
		// surface
		ofs_restart << ic1[7 * i + 3] << "  ";
		// gas_phase
		ofs_restart << ic1[7 * i + 4] << "  ";
		// solid solution
		ofs_restart << ic1[7 * i + 5] << "  ";
		// kinetics
		ofs_restart << ic1[7 * i + 6] << std::endl;
	}

	// write data
	for (int n = 0; n < (int) this->workers.size() - 1; n++)
	{
		this->workers[n]->SetDumpStringOn(true); 
		std::ostringstream in;
		in << "DUMP; -cells " << this->start_cell[n] << "-" << this->end_cell[n] << "\n";
		this->workers[n]->RunString(in.str().c_str());
		ofs_restart << this->Get_workers()[n]->GetDumpString();
	}

	ofs_restart.close();
	// rename files
	this->File_rename(temp_name.c_str(), name.c_str(), backup_name.c_str());
}
/* ---------------------------------------------------------------------- */
void
Reaction_module:: Write_screen(std::string item)
/* ---------------------------------------------------------------------- */
{
	RM_interface::phast_io.screen_msg(item.c_str());
}
/* ---------------------------------------------------------------------- */
void
Reaction_module:: Write_xyz(std::string item)
/* ---------------------------------------------------------------------- */
{
	RM_interface::phast_io.punch_msg(item.c_str());
}
/* ---------------------------------------------------------------------- */




