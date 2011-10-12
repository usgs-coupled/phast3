#include "Reaction_module.h"
#include "PHRQ_base.h"
#include "PHRQ_io.h"
#include "IPhreeqc.hpp"

Reaction_module::Reaction_module(PHRQ_io *io)
	//
	// default constructor for cxxExchComp 
	//
: PHRQ_base(io)
{
	this->iphreeqc_worker = new IPhreeqc;
	this->mpi_myself = 0;
	this->mpi_tasks = 1;

	ncomps = 0;

	nxyz = 0;							// number of nodes 
	nx = ny = nz = 0;					// number of nodes in each coordinate direction
	time_hst = 0;						// scalar time from transport 
	time_step_hst = 0;					// scalar time step from transport
	cnvtmi = 1;							// scalar conversion factor for time
	*x_hst = NULL;						// array locations of x nodes 
	*y_hst = NULL;						// array of locations of y nodes  
	*z_hst = NULL;						// array of locations of z nodes 
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
/* ---------------------------------------------------------------------- */
int
Reaction_module::Load_database(std::string database_name)
/* ---------------------------------------------------------------------- */
{
	this->database_file_name = database_name;
	if (this->iphreeqc_worker->LoadDatabase(this->database_file_name.c_str()) != 0) 
	{
		std::ostringstream errstr;
		errstr << iphreeqc_worker->GetErrorString() << std::endl;
		error_msg(errstr.str().c_str(), 1);
		return 0;
	}
	return 1;
}
/* ---------------------------------------------------------------------- */
int
Reaction_module::Initial_phreeqc_run(std::string chemistry_name)
/* ---------------------------------------------------------------------- */
/*
 *  Run PHREEQC to obtain PHAST reactants
 */
{
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
	iphreeqc_worker->AccumulateLine("PRINT; -status false; -other false");
	if (iphreeqc_worker->RunAccumulated() != 0)
	{
		std::ostringstream errstr;
		errstr << iphreeqc_worker->GetErrorString() << std::endl;
		error_msg(errstr.str().c_str(), 1);
	}

	if (iphreeqc_worker->RunFile(chemistry_name.c_str()) != 0) 
	{
		std::ostringstream errstr;
		errstr << iphreeqc_worker->GetErrorString() << std::endl;
		error_msg(errstr.str().c_str(), 1);
	}
	if (mpi_myself == 0)
	{
		this->Get_io()->output_string(PHRQ_io::OUTPUT_LOG, "\nSuccessfully processed chemistry data file.\n");
	}

	return 1;
}


