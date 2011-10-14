#include "Reaction_module.h"
#include "PHRQ_base.h"
#include "PHRQ_io.h"
#include "IPhreeqc.hpp"
#include <assert.h>
enum SURFACE_TYPE
{ UNKNOWN_DL, NO_EDL, DDL, CD_MUSIC, CCM };
enum DIFFUSE_LAYER_TYPE
{ NO_DL, BORKOVEK_DL, DONNAN_DL };
enum SITES_UNITS
{ SITES_ABSOLUTE, SITES_DENSITY };
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


Reaction_module::Reaction_module(PHRQ_io *io)
	//
	// default constructor for cxxExchComp 
	//
: PHRQ_base(io)
{
	this->phast_iphreeqc_worker = new PHAST_IPhreeqc;
	this->mpi_myself = 0;
	this->mpi_tasks = 1;

	nxyz = 0;							// number of nodes 
	nx = ny = nz = 0;					// number of nodes in each coordinate direction
	time_hst = 0;						// scalar time from transport 
	time_step_hst = 0;					// scalar time step from transport
	cnvtmi = 1;							// scalar conversion factor for time
	*x_node = NULL;						// nxyz array of X coordinates for nodes
	*y_node = NULL;						// nxyz array of Y coordinates for nodes 
	*z_node = NULL;						// nxyz array of Z coordinates for nodes
	*fraction = NULL;					// nxyz by ncomps mass fractions nxyz:components
	*frac = NULL;						// nxyz saturation fraction
	*pv = NULL;							// nxyz current pore volumes 
	*pv0 = NULL;						// nxyz initial pore volumes
	*volume = NULL;						// nxyz geometric cell volumes 
	*printzone_chem = NULL;				// nxyz print flags for output file
	*printzone_xyz = NULL;				// nxyz print flags for chemistry XYZ file 
	rebalance_fraction_hst = 0.5;		// parameter for rebalancing process load for parallel	

	// print flags
	prslm = false;						// solution method print flag 
	print_out = false;					// print flag for output file 
	print_sel = false;					// print flag for selected output
	print_hdf = false;					// print flag for hdf file
	print_restart = false;				// print flag for writing restart file 
}
Reaction_module::~Reaction_module(void)
{
}
/* ---------------------------------------------------------------------- */
int
Reaction_module::Load_database(std::string database_name)
/* ---------------------------------------------------------------------- */
{
	this->database_file_name = database_name;
	if (this->phast_iphreeqc_worker->LoadDatabase(this->database_file_name.c_str()) != 0) 
	{
		std::ostringstream errstr;
		errstr << phast_iphreeqc_worker->GetErrorString() << std::endl;
		error_msg(errstr.str().c_str(), 1);
		return 0;
	}
	return 1;
}
/* ---------------------------------------------------------------------- */
int
Reaction_module::Initial_phreeqc_run(std::string chemistry_name)
/* ---------------------------------------------------------------------- */
{
	/*
	*  Run PHREEQC to obtain PHAST reactants
	*/

	/*
	 *   initialize HDF
	 */
#ifdef HDF5_CREATE
// TODO, implement HDF	HDF_Init(prefix.c_str(), prefix.size());
#endif
	/*
	 *   initialize merge
	 */
	//TODO MPI and merge
#if defined(USE_MPI) && defined(HDF5_CREATE) && defined(MERGE_FILES)
	output_close(OUTPUT_ECHO);
	MergeInit(prefix, prefix_l, *solute);	/* opens .chem.txt,  .chem.xyz.tsv, .log.txt */
#endif


	/*
	 *   Run  input file
	 */
	if (mpi_myself == 0)
	{
		this->Get_io()->output_msg(PHRQ_io::OUTPUT_ECHO, "%s", "Initial PHREEQC run.\n");
	}
	phast_iphreeqc_worker->AccumulateLine("PRINT; -status false; -other false");
	if (phast_iphreeqc_worker->RunAccumulated() != 0)
	{
		std::ostringstream errstr;
		errstr << phast_iphreeqc_worker->GetErrorString() << std::endl;
		error_msg(errstr.str().c_str(), 1);
	}

	if (phast_iphreeqc_worker->RunFile(chemistry_name.c_str()) != 0) 
	{
		std::ostringstream errstr;
		errstr << phast_iphreeqc_worker->GetErrorString() << std::endl;
		error_msg(errstr.str().c_str(), 1);
	}
	//TODO make phreeqc_bin
	if (mpi_myself == 0)
	{
		this->Get_io()->output_string(PHRQ_io::OUTPUT_LOG, "\nSuccessfully processed chemistry data file.\n");
	}

	return 1;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Distribute_initial_conditions(
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
	*  Use indices defined in initial_conditions and fractions
	*  to mix reactants and store as initial conditions in a StorageBin
	*/
	/*
	 *      nxyz - number of cells
	 *      initial_conditions1 - Fortran, 7 x nxyz integer array, containing
	 *           solution number
	 *           pure_phases number
	 *           exchange number
	 *           surface number
	 *           gas number
	 *           solid solution number
	 *           kinetics number
	 *      initial_conditions2 - Fortran, 7 x nxyz integer array, containing
	 *      fraction for 1 - Fortran, 7 x nxyz double array, containing
	 *
	 *      Routine mixes solutions, pure_phase assemblages,
	 *      exchangers, surface complexers, gases, solid solution assemblages,
	 *      and kinetics for each cell.
	 */
	int
		i,
		j;
	//struct system *system_ptr;
	/*
	 *  Copy solution, exchange, surface, gas phase, kinetics, solid solution for each active cell.
	 *  Does nothing for indexes less than 0 (i.e. restart files)
	 */
	size_t count_negative_porosity = 0;
	for (i = 0; i < this->nxyz; i++)
	{							/* i is nxyz number */
		j = forward[i];			/* j is count_chem number */
		if (j < 0)
			continue;
		assert(forward[i] >= 0);
		assert (volume[i] > 0.0);
		double porosity = pv0[i] / volume[i];
		if (pv0[i] < 0 || volume[i] < 0)
		{
			std::ostringstream errstr;
			errstr << "Negative volume in cell " << i << ": volume, " 
				<< volume[i] << "\t initial volume, " << pv0[i] << ".",
			count_negative_porosity++;
			error_msg(errstr.str().c_str());
			continue;
		}
		assert (porosity > 0.0);
		double porosity_factor = (1.0 - porosity) / porosity;
		this->System_initialize(i, j, initial_conditions1, initial_conditions2,
			fraction1,
			exchange_units, surface_units, ssassemblage_units,
			ppassemblage_units, gasphase_units, kinetics_units,
			porosity_factor);
	}
	if (count_negative_porosity > 0)
	{
		std::ostringstream errstr;
		errstr << "Negative initial volumes may be due to initial head distribution.\n"
			"Make initial heads greater than or equal to the elevation of the node for each cell.\n"
			"Increase porosity, decrease specific storage, or use free surface boundary.";
		error_msg(errstr.str().c_str());
	}
	/*
	 * Read any restart files
	 */
	for (std::map < std::string, int >::iterator it = FileMap.begin();
		 it != FileMap.end(); it++)
	{
		int
			ifile = -100 - it->second;

		// use gsztream
		igzstream myfile;
		myfile.open(it->first.c_str());
		if (!myfile.good())

		{
			std::ostringstream errstr;
			errstr << "File could not be opened: " << it->first.c_str();
			error_msg(errstr.str().c_str());
			break;
		}

		std::ostringstream oss;
		CParser
		cparser(myfile, oss, std::cerr);
		cparser.set_echo_file(CParser::EO_NONE);
		cparser.set_echo_stream(CParser::EO_NONE);

		// skip headers
		while (cparser.check_line("restart", false, true, true, false) ==
			   CParser::LT_EMPTY);

		// read number of lines of index
		int
			n = -1;
		if (!(cparser.get_iss() >> n) || n < 4)
		{
			std::ostringstream errstr;
			errstr << "File does not have node locations: " << it->first.c_str() << "\nPerhaps it is an old format restart file.";
			error_msg(errstr.str().c_str());
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
		//int * index = (int *) PHRQ_malloc((size_t) (n * 7 * sizeof(int)));
		int * index = new int( (n * 7 * sizeof(int)) );

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

			cparser.get_iss() >> index[i * 7];
			cparser.get_iss() >> index[i * 7 + 1];
			cparser.get_iss() >> index[i * 7 + 2];
			cparser.get_iss() >> index[i * 7 + 3];
			cparser.get_iss() >> index[i * 7 + 4];
			cparser.get_iss() >> index[i * 7 + 5];
			cparser.get_iss() >> index[i * 7 + 6];
		}
		KDtree
		index_tree(pts);

		cxxStorageBin
			tempBin;
		tempBin.read_raw(cparser);

		for (j = 0; j < count_chem; j++)	/* j is count_chem number */
		{
			//i = back[j].list[0];	/* i is nxyz number */
			i = back[j][0];
			Point
			p(x_node[i], y_node[i], z_node[i]);
			int
				k = (int) index_tree.Interpolate3d(p);	// k is index number in tempBin

			// solution
			if (initial_conditions1[i * 7] == ifile)
			{
				if (index[k * 7] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_Solution(k) != NULL)
					{
						sz_bin.Set_Solution(j, tempBin.Get_Solution(k));
					}
					else
					{
						initial_conditions1[7 * i] = -1;
					}
				}
			}

			// PPassemblage
			if (initial_conditions1[i * 7 + 1] == ifile)
			{
				if (index[k * 7 + 1] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_PPassemblage(k) != NULL)
					{
						sz_bin.Set_PPassemblage(j, tempBin.Get_PPassemblage(k));
					}
					else
					{
						initial_conditions1[7 * i + 1] = -1;
					}
				}
			}

			// Exchange
			if (initial_conditions1[i * 7 + 2] == ifile)
			{
				if (index[k * 7 + 2] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_Exchange(k) != NULL)
					{
						sz_bin.Set_Exchange(j, tempBin.Get_Exchange(k));
					}
					else
					{
						initial_conditions1[7 * i + 2] = -1;
					}
				}
			}

			// Surface
			if (initial_conditions1[i * 7 + 3] == ifile)
			{
				if (index[k * 7 + 3] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_Surface(k) != NULL)
					{
						sz_bin.Set_Surface(j, tempBin.Get_Surface(k));
					}
					else
					{
						initial_conditions1[7 * i + 3] = -1;
					}
				}
			}

			// Gas phase
			if (initial_conditions1[i * 7 + 4] == ifile)
			{
				if (index[k * 7 + 4] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_GasPhase(k) != NULL)
					{
						sz_bin.Set_GasPhase(j, tempBin.Get_GasPhase(k));
					}
					else
					{
						initial_conditions1[7 * i + 4] = -1;
					}
				}
			}

			// Solid solution
			if (initial_conditions1[i * 7 + 5] == ifile)
			{
				if (index[k * 7 + 5] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_SSassemblage(k) != NULL)
					{
						sz_bin.Set_SSassemblage(j, tempBin.Get_SSassemblage(k));
					}
					else
					{
						initial_conditions1[7 * i + 5] = -1;
					}
				}
			}

			// Kinetics
			if (initial_conditions1[i * 7 + 6] == ifile)
			{
				if (index[k * 7 + 6] != -1)	// entity k should be defined in tempBin
				{
					if (tempBin.Get_Kinetics(k) != NULL)
					{
						sz_bin.Set_Kinetics(j, tempBin.Get_Kinetics(k));
					}
					else
					{
						initial_conditions1[7 * i + 6] = -1;
					}
				}
			}
		}
		myfile.close();
		delete index;
	}
	if (this->Get_io()->Get_io_error_count() > 0)
	{
		error_msg("Terminating in distribute_initial_conditions.\n", 1);
	}
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

	count_chem = 1;

	int ixy = this->nx * this->ny;
	int ixz = this->nx * this->nz;
	int iyz = this->ny * this->nz;
	int ixyz = this->nxyz;

	if (!axes[0] && !axes[1] && !axes[2])
	{
		error_msg("No active coordinate direction in DIMENSIONS keyword.", 1);
	}
	if (axes[0])
		count_chem *= this->nx;
	if (axes[1])
		count_chem *= this->ny;
	if (axes[2])
		count_chem *= this->nz;
/*
 *   malloc space
 */
	forward.reserve(ixyz);
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
				forward[i] = n;
				back[n].push_back(i);
				n++;
			}
			else
			{
				forward[i] = -1;
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
			n_to_ijk(i, ii, jj, kk);
			if (kk == 0 && (initial_conditions[7 * i] >= 0 || initial_conditions[7 * i] <= -100) )
			{
				forward[i] = n;
				back[n].push_back(i);
				back[n].push_back(i + ixy);
				n++;
			}
			else
			{
				forward[i] = -1;
			}
		}
		count_chem = n;
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
			n_to_ijk(i, ii, jj, kk);
			if (jj == 0	&& (initial_conditions[7 * i] >= 0 || initial_conditions[7 * i] <= -100))
			{
				forward[i] = n;
				back[n].push_back(i);
				back[n].push_back(i + this->nx);
				n++;
			}
			else
			{
				forward[i] = -1;
			}
		}
		count_chem = n;
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
			n_to_ijk(i, ii, jj, kk);
			if (ii == 0	&& (initial_conditions[7 * i] >= 0 || initial_conditions[7 * i] <= -100))
			{
				forward[i] = n;
				back[n].push_back(i);
				back[n].push_back(i + 1);
				n++;
			}
			else
			{
				forward[i] = -1;
			}
		}
		count_chem = n;
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
			n_to_ijk(i, ii, jj, kk);
			if (jj == 0 && kk == 0)
			{
				forward[i] = n;
				back[n].push_back(i);
				back[n].push_back(i + this->nx);
				back[n].push_back(i + ixy);
				back[n].push_back(i + ixy + this->nx);
				n++;
			}
			else
			{
				forward[i] = -1;
			}
		}
		count_chem = n;
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
			n_to_ijk(i, ii, jj, kk);
			if (ii == 0 && kk == 0)
			{
				forward[i] = n;
				back[n].push_back(i);
				back[n].push_back(i + 1);
				back[n].push_back(i + ixy);
				back[n].push_back(i + ixy + 1);
				n++;
			}
			else
			{
				forward[i] = -1;
			}
		}
		count_chem = n;
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
			n_to_ijk(i, ii, jj, kk);
			if (ii == 0 && jj == 0)
			{
				forward[i] = n;
				back[n].push_back(i);
				back[n].push_back(i + 1);
				back[n].push_back(i + this->nx);
				back[n].push_back(i + this->nx + 1);
				n++;
			}
			else
			{
				forward[i] = -1;
			}
		}
		count_chem = n;
	}
	return;
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
Reaction_module::System_initialize(
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

	/*
	 *   Copy solution
	 */
	n_old1 = initial_conditions1[7 * i];
	n_old2 = initial_conditions2[7 * i];
	f1 = fraction1[7 * i];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.add(n_old1, f1);
		if (n_old2 >= 0)
			mx.add(n_old2, 1 - f1);
		cxxSolution cxxsoln(phreeqc_bin.Get_Solutions(), mx, n_user_new);
		sz_bin.Set_Solution(n_user_new, &cxxsoln);
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
		mx.add(n_old1, f1);
		if (n_old2 >= 0)
			mx.add(n_old2, 1 - f1);
		if (ppassemblage_units == 2)
		{
			mx.multiply(porosity_factor);
		}
		cxxPPassemblage cxxentity(phreeqc_bin.Get_PPassemblages(), mx,
								  n_user_new);
		sz_bin.Set_PPassemblage(n_user_new, &cxxentity);
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
		mx.add(n_old1, f1);
		if (n_old2 >= 0)
			mx.add(n_old2, 1 - f1);
		if (exchange_units == 2)
		{
			mx.multiply(porosity_factor);
		}
		cxxExchange cxxexch(phreeqc_bin.Get_Exchangers(), mx, n_user_new);
		sz_bin.Set_Exchange(n_user_new, &cxxexch);
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
		mx.add(n_old1, f1);
		if (n_old2 >= 0)
			mx.add(n_old2, 1 - f1);
		if (surface_units == 2)
		{
			mx.multiply(porosity_factor);
		}
		cxxSurface cxxentity(phreeqc_bin.Get_Surfaces(), mx, n_user_new);
		sz_bin.Set_Surface(n_user_new, &cxxentity);
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
		mx.add(n_old1, f1);
		if (n_old2 >= 0)
			mx.add(n_old2, 1 - f1);
		if (gasphase_units == 2)
		{
			mx.multiply(porosity_factor);
		}
		cxxGasPhase cxxentity(phreeqc_bin.Get_GasPhases(), mx, n_user_new);
		sz_bin.Set_GasPhase(n_user_new, &cxxentity);
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
		mx.add(n_old1, f1);
		if (n_old2 >= 0)
			mx.add(n_old2, 1 - f1);
		if (ssassemblage_units == 2)
		{
			mx.multiply(porosity_factor);
		}
		cxxSSassemblage cxxentity(phreeqc_bin.Get_SSassemblages(), mx,
								  n_user_new);
		sz_bin.Set_SSassemblage(n_user_new, &cxxentity);
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
		mx.add(n_old1, f1);
		if (n_old2 >= 0)
			mx.add(n_old2, 1 - f1);
		if (kinetics_units == 2)
		{
			mx.multiply(porosity_factor);
		}
		cxxKinetics cxxentity(phreeqc_bin.Get_Kinetics(), mx, n_user_new);
		sz_bin.Set_Kinetics(n_user_new, &cxxentity);
	}

	return;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::Get_components(
					int *n_comp,		// returns number of components including H, O, charge
					char *names,		// array of component names
					int length)			// length of each component name from Fortran
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
	size_t count_components = this->phast_iphreeqc_worker->GetComponentCount();
	size_t i;
	for (i = 0; i < count_components; i++)
	{
		std::string comp(this->phast_iphreeqc_worker->GetComponent((int) i));
		assert (comp != "H");
		assert (comp != "O");
		assert (comp != "Charge");
		assert (comp != "charge");

		components.push_back(comp);
		char * ptr = &names[(i+4) * length];
		strncpy(ptr, comp.c_str(), length);
	}
	*n_comp = (int) components.size();

	// Calculate gfw for components
	for (i = 0; i < components.size(); i++)
	{
		if (components[i] == "Charge")
		{
			gfw.push_back(1.0);
		}
		else
		{
			gfw.push_back(this->phast_iphreeqc_worker->Get_gfw(components[i].c_str()));
		}
	}
	if (this->mpi_myself == 0)
	{
		std::ostringstream outstr;
		outstr << "List of Components:\n" << std::endl;
		for (i = 0; i < this->components.size(); i++)
		{
			outstr << "\t" << i + 1 << "\t" << components[i].c_str() << std::endl;
		}
	}
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::unpack_c_array(void)
/* ---------------------------------------------------------------------- */
{
	size_t i, j, k;

	std::vector<double> d;  // scratch space to convert from mass fraction to moles

	double gfw_water = this->phast_iphreeqc_worker->Get_gfw("H2O");
	for (i = 0; i < (size_t) nxyz; i++)
	{
		j = forward[i];
		if (j < 0) continue;

		// store mass fractions in d
		double *ptr = &fraction[i];
		for (k = 0; k < components.size(); k++)
		{	
			d.push_back(ptr[nxyz * j]);
		}

		// convert to d to moles
		for (j = 0; j < components.size(); j++)
		{
			d[j] *= 1000.0/gfw[j];
		}

		// update solution sz_bin solution
		cxxNameDouble nd;
		nd.add("H", d[0] + 2.0/gfw_water);
		nd.add("O", d[1] + 1.0/gfw_water);
		nd.add("Charge", d[2]);

		for (j = 3; j < components.size(); j++)
		{
			if (d[j] <= 1e-14) d[j] = 0.0;
			nd.add(components[j].c_str(), d[j]);
		}	
		sz_bin.Get_Solution((int) j)->Update(nd);
	}
	return;
}
///* ---------------------------------------------------------------------- */
//void
//Reaction_module::pack_c_array(void)
///* ---------------------------------------------------------------------- */
//{
//	size_t i, j, k;
//
//	std::vector<double> d;  // scratch space to convert from mass fraction to moles
//
//	double gfw_water = this->phast_iphreeqc_worker->Get_gfw("H2O");
//	for (i = 0; i < (size_t) nxyz; i++)
//	{
//		j = forward[i];
//		if (j < 0) continue;
//		cxxSolution * sol = sz_bin.Get_Solution((int) j);
//
//		// store mass fractions in d
//		double *ptr = &fraction[i];
//		for (k = 0; k < components.size(); k++)
//		{	
//			d.push_back(ptr[nxyz * j]);
//		}
//
//		// convert to d to moles
//		for (j = 0; j < components.size(); j++)
//		{
//			d[j] *= 1000.0/gfw[j];
//		}
//
//		// update solution sz_bin solution
//		cxxNameDouble nd;
//		nd.add("H", d[0] + 2.0/gfw_water);
//		nd.add("O", d[1] + 1.0/gfw_water);
//		nd.add("Charge", d[2]);
//
//		for (j = 3; j < components.size(); j++)
//		{
//			if (d[j] <= 1e-14) d[j] = 0.0;
//			nd.add(components[j].c_str(), d[j]);
//		}	
//		sz_bin.Get_Solution((int) j)->Update(nd);
//	}
//
//
//	std::vector<double> d;  // scratch space to convert from mass fraction to moles
//
//	cxxNameDouble::iterator it;
//	double gfw_water = this->phast_iphreeqc_worker->Get_gfw("H2O");
//	double  moles_water;
//
//	moles_water = 1.0 / gfw_water;
//	d.push_back(
//	buffer[0].moles = cxxsoln_ptr->get_total_h() - 2 * moles_water;
//	buffer[1].moles = cxxsoln_ptr->get_total_o() - moles_water;
//	for (i = 2; i < count_total; i++)
//	{
//		buffer[i].moles = cxxsoln_ptr->get_total_element(buffer[i].name);
//	}
///*
// *   Switch in transport of charge
// */
//	if (transport_charge == TRUE)
//	{
//		buffer[i].moles = cxxsoln_ptr->get_cb();
//	}
//	return;
//}