#include "Reaction_module.h"
#include "Reaction_module.h"
#include "PHRQ_base.h"
#include "PHRQ_io.h"
#include "IPhreeqc.h"
#include "IPhreeqc.hpp"
#include "IPhreeqcPhast.h"
#include "IPhreeqcPhastLib.h"
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
#include "CSelectedOutput.hxx"
#include <time.h>
#include "hdf.h"
#ifdef THREADED_PHAST
#include <omp.h>
#endif
#ifdef USE_MPI
#include <mpi.h>
#endif
#include "Phreeqc.h"

std::map<size_t, Reaction_module*> Reaction_module::Instances;
size_t Reaction_module::InstancesIndex = 0;
PHRQ_io Reaction_module::phast_io;

//// static Reaction_module methods
/* ---------------------------------------------------------------------- */
void Reaction_module::CleanupReactionModuleInstances(void)
/* ---------------------------------------------------------------------- */
{
	std::map<size_t, Reaction_module*>::iterator it = Reaction_module::Instances.begin();
	std::vector<Reaction_module*> rm_list;
	for ( ; it != Reaction_module::Instances.end(); it++)
	{
		rm_list.push_back(it->second);
	}
	for (size_t i = 0; i < rm_list.size(); i++)
	{
		delete rm_list[i];
	}
}
/* ---------------------------------------------------------------------- */
int
Reaction_module::CreateReactionModule(int *nxyz, int *nthreads)
/* ---------------------------------------------------------------------- */
{
	int n = IRM_OUTOFMEMORY;
	try
	{
		Reaction_module * Reaction_module_ptr = new Reaction_module(nxyz, nthreads);
		if (Reaction_module_ptr)
		{
			n = (int) Reaction_module_ptr->GetWorkers()[0]->Get_Index();
			Reaction_module::Instances[n] = Reaction_module_ptr;
			return n;
		}
	}
	catch(...)
	{
		return IRM_OUTOFMEMORY;
	}
	return IRM_OUTOFMEMORY; 
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::DestroyReactionModule(int *id)
/* ---------------------------------------------------------------------- */
{
	IRM_RESULT retval = IRM_BADINSTANCE;
	if (id)
	{
		std::map<size_t, Reaction_module*>::iterator it = Reaction_module::Instances.find(size_t(*id));
		if (it != Reaction_module::Instances.end())
		{
			delete (*it).second;
			retval = IRM_OK;
		}
	}
	return retval;
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::ErrorStop(const char *err_str, long l)
/* ---------------------------------------------------------------------- */
{
	//
	// Delete all Reaction_module instances
	//
	std::string error_string;
	error_string = "Stopping in Reaction_module::ErrorStop\n";
	if (err_str)
	{
		error_string.append(Char2TrimString(err_str, l));
	}
	else
	{
	}
#ifdef MPI
	MPI_Abort(MPI_COMM_WORLD);
#endif
	PHRQ_io io = Reaction_module::GetRmIo();
	io.error_msg(error_string.c_str(), false);
	Reaction_module::CleanupReactionModuleInstances();
	IPhreeqcPhastLib::CleanupIPhreeqcPhast();
	exit(4);
}
/* ---------------------------------------------------------------------- */
Reaction_module*
Reaction_module::GetInstance(int *id)
/* ---------------------------------------------------------------------- */
{
	if (id != NULL)
	{
		std::map<size_t, Reaction_module*>::iterator it = Reaction_module::Instances.find(size_t(*id));
		if (it != Reaction_module::Instances.end())
		{
			return (*it).second;
		}
	}
	return 0;
}
/*
//
// end static Reaction_module methods
//
*/

Reaction_module::Reaction_module(int *nxyz_arg, int *thread_count, PHRQ_io *io)
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
	// Determine mpi_myself
	this->mpi_myself = 0;
	this->mpi_tasks = 1;
#ifdef USE_MPI
	if (MPI_Comm_size(MPI_COMM_WORLD, &this->mpi_tasks) != MPI_SUCCESS)
	{
		error_msg("MPI communicator not defined", 1);
	}

	if (MPI_Comm_rank(MPI_COMM_WORLD, &this->mpi_myself) != MPI_SUCCESS)
	{
		error_msg("MPI communicator not defined", 1);
	}
#endif
	if (mpi_myself == 0)
	{
		if (*nxyz_arg == NULL)
		{
			std::ostringstream errstr;
			errstr << "Number of grid cells (nxyz) not defined in creating Reaction_module"; 
			error_msg(errstr.str().c_str(), 1);
		}
		this->nxyz = *nxyz_arg;
	}
#ifdef USE_MPI
	MPI_Bcast(&this->nxyz, 1, MPI_INT, 0, MPI_COMM_WORLD);
	this->nthreads = 1;
#else
	this->nthreads = n;
	if (*thread_count != NULL)
	{
		this->nthreads = (*thread_count > 0) ? *thread_count : n;
	}
#endif

	// last one is to calculate well pH
	for (int i = 0; i < this->nthreads + 2; i++)
	{
		this->workers.push_back(new IPhreeqcPhast);
	}
	if (this->GetWorkers()[0])
	{
		std::map<size_t, Reaction_module*>::value_type instance(this->GetWorkers()[0]->Get_Index(), this);
		Reaction_module::Instances.insert(instance);
	}
	else
	{
		std::cerr << "Reaction module not created." << std::endl;
		exit(4);
	}


	this->gfw_water = 18.;						// gfw of water
	this->count_chemistry = this->nxyz;
	//this->free_surface = false;					// free surface calculation
	//this->steady_flow = false;					// steady-state flow calculation
	this->partition_uz_solids = false;
	this->time = 0;							    // scalar time from transport 
	this->time_step = 0;					    // scalar time step from transport
	this->time_conversion = NULL;				// scalar conversion factor for time
	this->rebalance_fraction = 0.5;				// parameter for rebalancing process load for parallel	

	// print flags
	this->print_chemistry_on = false;			// print flag for chemistry output file 
	this->selected_output_on = true;			// Create selected output
	this->input_units_Solution = 3;				// 1 mg/L, 2 mmol/L, 3 kg/kgs
	this->input_units_PPassemblage = 1;			// water 1, rock 2
	this->input_units_Exchange = 1;			    // water 1, rock 2
	this->input_units_Surface = 1;			    // water 1, rock 2
	this->input_units_GasPhase = 1;			    // water 1, rock 2
	this->input_units_SSassemblage = 1;			// water 1, rock 2
	this->input_units_Kinetics = 1;			    // water 1, rock 2

	this->stop_message = false;

	// initialize arrays
	for (int i = 0; i < this->nxyz; i++)
	{
		forward.push_back(i);
		std::vector<int> temp;
		temp.push_back(i);
		back.push_back(temp);
		saturation.push_back(1.0);
		old_saturation.push_back(1.0);
		pore_volume.push_back(0.1);
		pore_volume_zero.push_back(0.1);
		cell_volume.push_back(1.0);
		print_chem_mask.push_back(0);
		density.push_back(1.0);
		pressure.push_back(1.0);
		tempc.push_back(25.0);
	}

	// set work for each thread or process
	SetEndCells();
}
Reaction_module::~Reaction_module(void)
{
	std::map<size_t, Reaction_module*>::iterator it = Reaction_module::Instances.find(this->GetWorkers()[0]->Get_Index());

	for (int i = 0; i <= it->second->GetNthreads(); i++)
	{
		delete it->second->GetWorkers()[i];
	}
	if (it != Reaction_module::Instances.end())
	{
		Reaction_module::Instances.erase(it);
	}

}

// Reaction_module methods

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
	this->GetWorkers()[this->nthreads]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(temp_bin, 0);
	std::string input;
	input.append("RUN_CELLS; -cell 0; SELECTED_OUTPUT; -reset false; -pH; -alkalinity; END");
	this->GetWorkers()[0]->RunString(input.c_str());

	VAR pvar;
	this->GetWorkers()[this->nthreads]->GetSelectedOutputValue(1,0,&pvar);
	*pH = pvar.dVal;
	this->GetWorkers()[this->nthreads]->GetSelectedOutputValue(1,1,&pvar);
	*alkalinity = pvar.dVal;

	// Alternatively
	//*pH = -(this->phast_iphreeqc_worker->Get_PhreeqcPtr()->s_hplus->la);
	//*alkalinity = this->phast_iphreeqc_worker->Get_PhreeqcPtr()->total_alkalinity / 
	//	this->phast_iphreeqc_worker->Get_PhreeqcPtr()->mass_water_aq_x;
	return;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::CellInitialize(
					int i, 
					int n_user_new, 
					int *initial_conditions1,
					int *initial_conditions2, 
					double *fraction1,
					std::set<std::string> error_set)
/* ---------------------------------------------------------------------- */
{
	int n_old1, n_old2;
	double f1;

	cxxStorageBin initial_bin;

	IRM_RESULT rtn = IRM_OK;
	double cell_porosity_local = pore_volume_zero[i] / cell_volume[i];
	double porosity_factor = (1.0 - cell_porosity_local) / cell_porosity_local;

	/*
	 *   Copy solution
	 */
	n_old1 = initial_conditions1[i];
	n_old2 = initial_conditions2[i];
	if (phreeqc_bin.Get_Solutions().find(n_old1) == phreeqc_bin.Get_Solutions().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition SOLUTION " << n_old1 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	if (n_old2 > 0 && phreeqc_bin.Get_Solutions().find(n_old2) == phreeqc_bin.Get_Solutions().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition SOLUTION " << n_old2 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	f1 = fraction1[i];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		// Account for saturation of cell
		double sat = 1.0;
		if (saturation[i] > 0) 
			sat = saturation[i];
		mx.Add(n_old1, f1 * sat);
		if (n_old2 >= 0)
			mx.Add(n_old2, (1 - f1) * sat);
		cxxSolution cxxsoln(phreeqc_bin.Get_Solutions(), mx, n_user_new);
		initial_bin.Set_Solution(n_user_new, &cxxsoln);
	}

	/*
	 *   Copy pp_assemblage
	 */
	n_old1 = initial_conditions1[this->nxyz + i];
	n_old2 = initial_conditions2[this->nxyz + i];
	if (n_old1 > 0 && phreeqc_bin.Get_PPassemblages().find(n_old1) == phreeqc_bin.Get_PPassemblages().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition EQUILIBRIUM_PHASES " << n_old1 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	if (n_old2 > 0 && phreeqc_bin.Get_PPassemblages().find(n_old2) == phreeqc_bin.Get_PPassemblages().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition EQUILIBRIUM_PHASES " << n_old2 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	f1 = fraction1[this->nxyz + i];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (this->input_units_PPassemblage == 2)
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

	n_old1 = initial_conditions1[2 * this->nxyz + i];
	n_old2 = initial_conditions2[2 * this->nxyz + i];
	if (n_old1 > 0 && phreeqc_bin.Get_Exchangers().find(n_old1) == phreeqc_bin.Get_Exchangers().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition EXCHANGE " << n_old1 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	if (n_old2 > 0 && phreeqc_bin.Get_Exchangers().find(n_old2) == phreeqc_bin.Get_Exchangers().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition EXCHANGE " << n_old2 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	f1 = fraction1[2 * this->nxyz + i];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (this->input_units_Exchange == 2)
		{
			mx.Multiply(porosity_factor);
		}
		cxxExchange cxxexch(phreeqc_bin.Get_Exchangers(), mx, n_user_new);
		initial_bin.Set_Exchange(n_user_new, &cxxexch);
	}
	/*
	 *   Copy surface assemblage
	 */
	n_old1 = initial_conditions1[3 * this->nxyz + i];
	n_old2 = initial_conditions2[3 * this->nxyz + i];
	if (n_old1 > 0 && phreeqc_bin.Get_Surfaces().find(n_old1) == phreeqc_bin.Get_Surfaces().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition SURFACE " << n_old1 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	if (n_old2 > 0 && phreeqc_bin.Get_Surfaces().find(n_old2) == phreeqc_bin.Get_Surfaces().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition SURFACE " << n_old2 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	f1 = fraction1[3 * this->nxyz + i];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (this->input_units_Surface == 2)
		{
			mx.Multiply(porosity_factor);
		}
		cxxSurface cxxentity(phreeqc_bin.Get_Surfaces(), mx, n_user_new);
		initial_bin.Set_Surface(n_user_new, &cxxentity);
	}
	/*
	 *   Copy gas phase
	 */
	n_old1 = initial_conditions1[4 * this->nxyz + i];
	n_old2 = initial_conditions2[4 * this->nxyz + i];
	if (n_old1 > 0 && phreeqc_bin.Get_GasPhases().find(n_old1) == phreeqc_bin.Get_GasPhases().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition GAS_PHASE " << n_old1 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	if (n_old2 > 0 && phreeqc_bin.Get_GasPhases().find(n_old2) == phreeqc_bin.Get_GasPhases().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition GAS_PHASE " << n_old2 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	f1 = fraction1[4 * this->nxyz + i];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (this->input_units_GasPhase == 2)
		{
			mx.Multiply(porosity_factor);
		}
		cxxGasPhase cxxentity(phreeqc_bin.Get_GasPhases(), mx, n_user_new);
		initial_bin.Set_GasPhase(n_user_new, &cxxentity);
	}
	/*
	 *   Copy solid solution
	 */
	n_old1 = initial_conditions1[5 * this->nxyz + i];
	n_old2 = initial_conditions2[5 * this->nxyz + i];
	if (n_old1 > 0 && phreeqc_bin.Get_SSassemblages().find(n_old1) == phreeqc_bin.Get_SSassemblages().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition SOLID_SOLUTIONS " << n_old1 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	if (n_old2 > 0 && phreeqc_bin.Get_SSassemblages().find(n_old2) == phreeqc_bin.Get_SSassemblages().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition SOLID_SOLUTIONS " << n_old2 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	f1 = fraction1[5 * this->nxyz + i];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (this->input_units_SSassemblage == 2)
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
	n_old1 = initial_conditions1[6 * this->nxyz + i];
	n_old2 = initial_conditions2[6 * this->nxyz + i];
	if (n_old1 > 0 && phreeqc_bin.Get_Kinetics().find(n_old1) == phreeqc_bin.Get_Kinetics().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition KINETICS " << n_old1 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	if (n_old2 > 0 && phreeqc_bin.Get_SSassemblages().find(n_old2) == phreeqc_bin.Get_SSassemblages().end())
	{
		std::ostringstream e_stream;
		e_stream << "Initial condition KINETICS " << n_old2 << " not found.";
		error_set.insert(e_stream.str());
		rtn = IRM_FAIL;
	}
	f1 = fraction1[6 * this->nxyz + i];
	if (n_old1 >= 0)
	{
		cxxMix mx;
		mx.Add(n_old1, f1);
		if (n_old2 >= 0)
			mx.Add(n_old2, 1 - f1);
		if (this->input_units_Kinetics == 2)
		{
			mx.Multiply(porosity_factor);
		}
		cxxKinetics cxxentity(phreeqc_bin.Get_Kinetics(), mx, n_user_new);
		initial_bin.Set_Kinetics(n_user_new, &cxxentity);
	}
	this->GetWorkers()[0]->Get_PhreeqcPtr()->cxxStorageBin2phreeqc(initial_bin);
	return rtn;
}

/* ---------------------------------------------------------------------- */
int 
Reaction_module::CheckSelectedOutput()
/* ---------------------------------------------------------------------- */
{
#ifdef USE_MPI
	if (this->mpi_tasks <= 1) return VR_OK;
	
	// check number of selected output
	{
		int nso = (int) this->workers[0]->CSelectedOutputMap.size();
		// Gather number of selected output at root
		std::vector<int> recv_buffer;
		recv_buffer.resize(this->mpi_tasks);
		MPI_Gather(&nso, 1, MPI_INT, recv_buffer.data(), 1, MPI_INT, 0, MPI_COMM_WORLD);
		for (int i = 1; i < this->mpi_tasks; i++)
		{
			if (recv_buffer[i] != recv_buffer[0])
			{
				error_msg("MPI processes have different number of selected output definitions.", STOP);
			}
		}
	}

	// check number of columns
	{
		std::map < int, CSelectedOutput >::iterator it = this->workers[0]->CSelectedOutputMap.begin();
		for ( ; it != this->workers[0]->CSelectedOutputMap.end(); it++)
		{
			int col = (int) it->second.GetColCount();
			// Gather number of columns at root
			std::vector<int> recv_buffer;
			recv_buffer.resize(this->mpi_tasks);
			MPI_Gather(&col, 1, MPI_INT, recv_buffer.data(), 1, MPI_INT, 0, MPI_COMM_WORLD);
			for (int i = 1; i < this->mpi_tasks; i++)
			{
				if (recv_buffer[i] != recv_buffer[0])
				{
					error_msg("MPI processes have different number of selected output columns.", STOP);
				}
			}
		}
	}

	// check headings
	{
		std::map < int, CSelectedOutput >::iterator it = this->workers[0]->CSelectedOutputMap.begin();
		for ( ; it != this->workers[0]->CSelectedOutputMap.end(); it++)
		{
			std::string headings;
			int length;
			// Make string with headings
			int col = (int) it->second.GetColCount();
			for (int i = 0; i < col; i++)
			{
				CVar cvar;
				cvar = it->second.Get(0, i);
				if (cvar.type == TT_STRING)
				{
					headings.append(cvar.sVal);
				}
				else
				{
					error_msg("MPI processes has selected output column that is not a string.", STOP);
				}
			}
			

			if (this->mpi_myself == 0)
			{
				length = (int) headings.size();
			}
			MPI_Bcast(&length,  1, MPI_INT, 0, MPI_COMM_WORLD);

			// Broadcast string
			char *headings_bcast = new char[length + 1];
			if (this->mpi_myself == 0)
			{
				strcpy(headings_bcast, headings.c_str());
			}

			MPI_Bcast(headings_bcast, length + 1, MPI_CHARACTER, 0, MPI_COMM_WORLD);
			
			int equal = strcmp(headings_bcast, headings.c_str()) == 0 ? 1 : 0;

			std::vector<int> recv_buffer;
			recv_buffer.resize(this->mpi_tasks);
			MPI_Gather(&equal, 1, MPI_INT, recv_buffer.data(), 1, MPI_INT, 0, MPI_COMM_WORLD);
			if (mpi_myself == 0)
			{
				for (int i = 1; i < this->mpi_tasks; i++)
				{
					if (recv_buffer[i] == 0)
					{
						error_msg("MPI processes have different column headings.", STOP);
					}
				}
			}
		}
	}
	// Count rows
	{	
		std::map < int, CSelectedOutput >::iterator it = this->workers[0]->CSelectedOutputMap.begin();
		for ( ; it != this->workers[0]->CSelectedOutputMap.end(); it++)
		{
			int rows = (int) it->second.GetRowCount() - 1;
			std::vector<int> recv_buffer;
			recv_buffer.resize(this->mpi_tasks);
			MPI_Gather(&rows, 1, MPI_INT, recv_buffer.data(), 1, MPI_INT, 0, MPI_COMM_WORLD);
			if (this->mpi_myself == 0) 
			{
				int count = 0;
				for (int n = 0; n < this->mpi_tasks; n++)
				{ 
					count += recv_buffer[n];
				}
				if (count != this->count_chemistry)
				{
					error_msg("Sum of rows is not equal to count_chem.", STOP);
				}
			}
		}
	}
#else
	if (this->nthreads <= 1) return VR_OK;
	
	// check number of selected output
	{
		for (int i = 1; i < this->mpi_tasks; i++)
		{
			if (this->workers[i]->CSelectedOutputMap.size() != this->workers[0]->CSelectedOutputMap.size())
			{
				error_msg("Threads have different number of selected output definitions.", STOP);
			}
		}
	}

	// check number of columns
	{		
		for (int n = 1; n < this->mpi_tasks; n++)
		{
			std::map < int, CSelectedOutput >::iterator root_it = this->workers[0]->CSelectedOutputMap.begin();
			std::map < int, CSelectedOutput >::iterator n_it = this->workers[n]->CSelectedOutputMap.begin();
			for( ; root_it != this->workers[0]->CSelectedOutputMap.end(); root_it++, n_it++)
			{
				if (root_it->second.GetColCount() != n_it->second.GetColCount())
				{
					error_msg("Threads have different number of selected output columns.", STOP);
				}
			}
		}
	}

	// check headings
	{		
		for (int n = 1; n < this->mpi_tasks; n++)
		{
			std::map < int, CSelectedOutput >::iterator root_it = this->workers[0]->CSelectedOutputMap.begin();
			std::map < int, CSelectedOutput >::iterator n_it = this->workers[n]->CSelectedOutputMap.begin();
			for( ; root_it != this->workers[0]->CSelectedOutputMap.end(); root_it++, n_it++)
			{
				for (int i = 0; i < root_it->second.GetColCount(); i++)
				{
					CVar root_cvar;
					root_it->second.Get(0, i, &root_cvar);
					CVar n_cvar;
					n_it->second.Get(0, i, &n_cvar);
					if (root_cvar.type != TT_STRING || n_cvar.type != TT_STRING)
					{
						error_msg("Threads has selected output column that is not a string.", STOP);
					}
					if (strcmp(root_cvar.sVal, n_cvar.sVal) != 0)
					{
						error_msg("Threads have different column headings.", STOP);
					}
				}
			}
		}
	}

	// Count rows
	{			
		for (int nso = 0; nso < (int) this->workers[0]->CSelectedOutputMap.size(); nso++)
		{
			int n_user = this->GetNthSelectedOutputUserNumber(&nso);
			int count = 0;
			for (int n = 0; n < this->nthreads; n++)
			{ 
				std::map < int, CSelectedOutput >::iterator n_it = this->workers[n]->CSelectedOutputMap.find(n_user);
				count += (int) n_it->second.GetRowCount() - 1;
			}
			if (count != this->count_chemistry)
			{
				error_msg("Sum of rows is not equal to count_chem.", STOP);
			}
		}
	}
#endif
	return VR_OK;
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
IRM_RESULT
Reaction_module::CreateMapping(int *t)
/* ---------------------------------------------------------------------- */
{
	IRM_RESULT rtn = IRM_OK;
	std::vector<int> grid2chem;
	grid2chem.resize(this->nxyz);
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in CreateMapping", 1);
		memcpy(grid2chem.data(), t, (size_t) (this->nxyz * sizeof(int)));
	}
#ifdef USE_MPI
	MPI_Bcast(grid2chem.data(), this->nxyz, MPI_INT, 0, MPI_COMM_WORLD);
#endif

	back.clear();
	forward.clear();

	// find count_chem
	this->count_chemistry = 0;
	for (int i = 0; i < this->nxyz; i++)
	{
		if (grid2chem[i] > count_chemistry)
		{
			count_chemistry = grid2chem[i];
		}
	}
	count_chemistry ++; 

	for (int i = 0; i < count_chemistry; i++)
	{
		std::vector<int> temp;
		back.push_back(temp);
	}
	for (int i = 0; i < this->nxyz; i++)
	{
		int n = grid2chem[i];
		if (n >= count_chemistry)
		{
			error_msg("Error in cell out of range in mapping (grid to chem).", 0);
			rtn = IRM_INVALIDARG;
		}

		// copy to forward
		forward.push_back(n);

		// add to back
		if (n >= 0) 
		{
			back[n].push_back(i);
		}
	}
	
	// set -1 for back items > 0
	for (int i = 0; i < this->count_chemistry; i++)
	{
		// add to back
		for (size_t j = 1; j < back[i].size(); j++)
		{
			int n = back[i][j];
			forward[n] = -1;
		}
	}
	// check that all count_chem have at least 1 cell
	for (int i = 0; i < this->count_chemistry; i++)
	{
		if (back[i].size() == 0)
		{
			error_msg("Error in building inverse mapping (chem to grid).", 0);
			rtn = IRM_INVALIDARG;
		}
	}
	
	// Distribute work with new count_chemistry
	SetEndCells();

	return rtn;
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::cxxSolution2concentration(cxxSolution * cxxsoln_ptr, std::vector<double> & d)
/* ---------------------------------------------------------------------- */
{
	d.clear();

	// Simplify totals
	{
	  cxxNameDouble nd = cxxsoln_ptr->Get_totals().Simplify_redox();
	  cxxsoln_ptr->Set_totals(nd);
	}

	// convert units
	switch (this->input_units_Solution)
	{
	case 1:  // convert to mg/L 
			d.push_back(cxxsoln_ptr->Get_total_h() * this->gfw[0] * 1000. / cxxsoln_ptr->Get_soln_vol()); 
			d.push_back(cxxsoln_ptr->Get_total_o() * this->gfw[1] * 1000. / cxxsoln_ptr->Get_soln_vol()); 
			d.push_back(cxxsoln_ptr->Get_cb() * this->gfw[2] * 1000. / cxxsoln_ptr->Get_soln_vol()); 
			for (size_t i = 3; i < this->components.size(); i++)
			{
				d.push_back(cxxsoln_ptr->Get_total(components[i].c_str()) * this->gfw[i] / 1000. / cxxsoln_ptr->Get_soln_vol()); 
			}
		break;
	case 2:  // convert to mol/L
		{
			d.push_back(cxxsoln_ptr->Get_total_h() / cxxsoln_ptr->Get_soln_vol()); 
			d.push_back(cxxsoln_ptr->Get_total_o() / cxxsoln_ptr->Get_soln_vol()); 
			d.push_back(cxxsoln_ptr->Get_cb()  / cxxsoln_ptr->Get_soln_vol()); 
			for (size_t i = 3; i < this->components.size(); i++)
			{
				d.push_back(cxxsoln_ptr->Get_total(components[i].c_str())  / cxxsoln_ptr->Get_soln_vol()); 
			}	
		}
		break;
	case 3:  // convert to mass fraction kg/kgs
		{
			double kgs = cxxsoln_ptr->Get_soln_vol() * cxxsoln_ptr->Get_density();
			d.push_back(cxxsoln_ptr->Get_total_h() * this->gfw[0] / 1000. / kgs); 
			d.push_back(cxxsoln_ptr->Get_total_o() * this->gfw[1] / 1000. / kgs); 
			d.push_back(cxxsoln_ptr->Get_cb() * this->gfw[2] / 1000. / kgs); 
			for (size_t i = 3; i < this->components.size(); i++)
			{
				d.push_back(cxxsoln_ptr->Get_total(components[i].c_str()) * this->gfw[i] / 1000. / kgs); 
			}	
		}
		break;
	}
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::DumpModule(int *dump_on, int *use_gz_in)
/* ---------------------------------------------------------------------- */
{
	bool dump = false;
	if (this->mpi_myself == 0)
	{
		if (dump_on != NULL)
		{
			dump = (*dump_on != 0);
		}
	}
#ifdef USE_MPI
	MPI_Bcast(&dump, 1, MPI_LOGICAL, 0, MPI_COMM_WORLD);
#endif

	if (dump)
	{
		std::string char_buffer;
		bool use_gz;
		use_gz = (use_gz_in && (*use_gz_in != 0)) ? true : false;
		ogzstream ofs_restart_gz;
		ofstream ofs_restart;

		std::string temp_name("temp_dump_file");
		std::string name(this->file_prefix);
		std::string backup_name(this->file_prefix);

		if (mpi_myself == 0)
		{
			name.append(".dump");
			backup_name.append(".dump.backup");
			if (use_gz)
			{
				temp_name.append(".gz");
				name.append(".gz");
				backup_name.append(".gz");
				ofs_restart_gz.open(temp_name.c_str());
				if (!ofs_restart_gz.good())
				{
					std::ostringstream errstr;
					errstr << "Temporary restart file could not be opened: " << temp_name;
					WriteError(errstr.str().c_str());
					ErrorStop();
				}
			}
			else
			{
				ofs_restart.open(temp_name.c_str(), std::ofstream::out);  // ::app for append
				if (!ofs_restart.good())
				{
					std::ostringstream errstr;
					errstr << "Temporary restart file could not be opened: " << temp_name;
					WriteError(errstr.str().c_str());
					ErrorStop();
				}
			}
		}

		// write data
#ifdef USE_MPI
		this->workers[0]->SetDumpStringOn(true); 
		std::ostringstream in;

		in << "DUMP; -cells " << this->start_cell[this->mpi_myself] << "-" << this->end_cell[this->mpi_myself] << "\n";
		this->workers[0]->RunString(in.str().c_str());
		for (int n = 0; n < this->mpi_tasks; n++)
		{
			// Need to transfer output stream to root and print
			if (this->mpi_myself == n)
			{
				if (n == 0)
				{			
					if (use_gz)
					{
						ofs_restart_gz << this->GetWorkers()[0]->GetDumpString();
					} 
					else
					{
						ofs_restart << this->GetWorkers()[0]->GetDumpString();
					}
				}
				else
				{
					int size = (int) strlen(this->workers[0]->GetDumpString());
					MPI_Send(&size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
					MPI_Send((void *) this->workers[0]->GetDumpString(), size, MPI_CHARACTER, 0, 0, MPI_COMM_WORLD);
				}	
			}
			else if (this->mpi_myself == 0)
			{
				MPI_Status mpi_status;
				int size;
				MPI_Recv(&size, 1, MPI_INT, n, 0, MPI_COMM_WORLD, &mpi_status);
				char_buffer.resize(size+1);
				MPI_Recv((void *) char_buffer.c_str(), size, MPI_CHARACTER, n, 0, MPI_COMM_WORLD, &mpi_status);
				char_buffer[size] = '\0';
				if (use_gz)
				{
					ofs_restart_gz << char_buffer;
				} 
				else
				{
					ofs_restart << char_buffer;
				}
			}
			// Clear dump string to save space
			std::ostringstream clr;
			clr << "END\n";
			this->GetWorkers()[0]->RunString(clr.str().c_str());
		}
#else
		for (int n = 0; n < (int) this->nthreads; n++)
		{
			this->workers[n]->SetDumpStringOn(true); 
			std::ostringstream in;
			in << "DUMP; -cells " << this->start_cell[n] << "-" << this->end_cell[n] << "\n";
			this->workers[n]->RunString(in.str().c_str());
			if (use_gz)
			{
				ofs_restart_gz << this->GetWorkers()[n]->GetDumpString();
			} 
			else
			{
				ofs_restart << this->GetWorkers()[n]->GetDumpString();
			}
			// Clear dump string to save space
			std::ostringstream clr;
			clr << "END\n";
			this->GetWorkers()[n]->RunString(clr.str().c_str());
		}
#endif
		if (use_gz)
		{
			ofs_restart_gz.close();
		}
		else
		{
			ofs_restart.close();
		}
		// rename files
		Reaction_module::FileRename(temp_name.c_str(), name.c_str(), backup_name.c_str());
	}
	return IRM_OK;
}


/* ---------------------------------------------------------------------- */
bool
Reaction_module::FileExists(const std::string &name)
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
Reaction_module::FileRename(const std::string &temp_name, const std::string &name, 
	const std::string &backup_name)
/* ---------------------------------------------------------------------- */
{
	if (Reaction_module::FileExists(name))
	{
		if (Reaction_module::FileExists(backup_name.c_str()))
			remove(backup_name.c_str());
		rename(name.c_str(), backup_name.c_str());
	}
	rename(temp_name.c_str(), name.c_str());
}
/* ---------------------------------------------------------------------- */
int
Reaction_module::FindComponents(void)	
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
	IPhreeqcPhast * phast_iphreeqc_worker = this->GetWorkers()[0];
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
		WriteOutput(outstr.str().c_str());
	}
	return (int) this->components.size();
}
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
void
Reaction_module::GetConcentrations(double * c)
/* ---------------------------------------------------------------------- */
{
	// convert Reaction module solution data to concentrations for transport
	MPI_Status mpi_status;
	std::vector<double> d;  // scratch space to convert from moles to mass fraction
	std::vector<double> solns;
	cxxNameDouble::iterator it;

	if (mpi_myself == 0)
	{
		if (c == NULL) error_msg("NULL pointer in Module2Concentrations", 1);
	}
	int n = this->mpi_myself;
	for (int j = this->start_cell[n]; j <= this->end_cell[n]; j++)
	{
		// load fractions into d
		cxxSolution * cxxsoln_ptr = this->GetWorkers()[0]->Get_solution(j);
		assert (cxxsoln_ptr);
		this->cxxSolution2concentration(cxxsoln_ptr, d);
		for (int i = 0; i < (int) this->components.size(); i++)
		{
			solns.push_back(d[i]);
		}
	}

	// make buffer to recv solutions
	double * recv_solns = new double[(size_t) this->count_chemistry * this->components.size()];

	// each process has its own vector of solution components
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

	// Write vector into c
	if (this->mpi_myself == 0)
	{
		assert (solns.size() == this->count_chemistry*this->components.size());
		int n = 0;
		for (int j = 0; j < count_chemistry; j++)
		{
			std::vector<double> d;
			for (size_t i = 0; i < this->components.size(); i++)
			{
				d.push_back(solns[n++]);
			}
			std::vector<int>::iterator it;
			for (it = this->back[j].begin(); it != this->back[j].end(); it++)
			{
				double *d_ptr = &c[*it];
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
Reaction_module::GetConcentrations(double * c)
/* ---------------------------------------------------------------------- */
{
	// convert Reaction module solution data to hst mass fractions

	std::vector<double> d;  // scratch space to convert from moles to mass fraction
	cxxNameDouble::iterator it;

	int j; 
	if (c == NULL) ErrorStop("NULL pointer in Module2Concentrations");
	for (int n = 0; n < this->nthreads; n++)
	{
		for (j = this->start_cell[n]; j <= this->end_cell[n]; j++)
		{
			// load fractions into d
			cxxSolution * cxxsoln_ptr = this->GetWorkers()[n]->Get_solution(j);
			assert (cxxsoln_ptr);
			this->cxxSolution2concentration(cxxsoln_ptr, d);

			// store in fraction at 1, 2, or 4 places depending on chemistry dimensions
			std::vector<int>::iterator it;
			for (it = this->back[j].begin(); it != this->back[j].end(); it++)
			{
				double *d_ptr = &c[*it];
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
std::vector<double> &
Reaction_module::GetDensity(void)
/* ---------------------------------------------------------------------- */
{

	this->density.clear();
	this->density.resize(this->nxyz, INACTIVE_CELL_VALUE);
	std::vector<double> dbuffer;

#ifdef USE_MPI
	int n = this->mpi_myself;
	for (int i = this->start_cell[n]; i <= this->end_cell[n]; i++)
	{
		double d = this->workers[0]->Get_solution(i)->Get_density();
		for(size_t j = 0; j < back[i].size(); j++)
		{
			int n = back[i][j];
			this->density[n] = d;
		}
	}
	for (int n = 0; n < this->mpi_tasks; n++)
	{
		if (this->mpi_myself == n)
		{
			if (this->mpi_myself = 0)
			{
				continue;
			}
			else
			{
				int l = this->end_cell[n] - this->start_cell[n] + 1;
				MPI_Send((void *) &this->density[this->start_cell[n]], l, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
			}
		}
		else if (this->mpi_myself == 0)
		{	
			std::vector<double> dbuffer;
			MPI_Status mpi_status;
			int l = this->end_cell[n] - this->start_cell[n] + 1;
			dbuffer.resize(l);
			MPI_Recv(dbuffer.data(), l, MPI_DOUBLE, n, 0, MPI_COMM_WORLD, &mpi_status);
			for (int i = 0; i < l; i++)
			{
				this->density[this->start_cell[n] +i] = dbuffer[i];
			}
		}
	}
#else
	for (int n = 0; n < this->nthreads; n++)
	{
		for (int i = start_cell[n]; i <= this->end_cell[n]; i++)
		{
			cxxSolution *soln_ptr = this->workers[n]->Get_solution(i);
			double d = this->workers[n]->Get_solution(i)->Get_density();
			for(size_t j = 0; j < back[i].size(); j++)
			{
				int n = back[i][j];
				this->density[n] = d;
			}
		}
	}
#endif
	return this->density;
}
/* ---------------------------------------------------------------------- */
int
Reaction_module::GetNthSelectedOutputUserNumber(int *i)
/* ---------------------------------------------------------------------- */
{
	if (i != NULL && *i >= 0) 
	{
		return this->workers[0]->GetNthSelectedOutputUserNumber(*i);
	}
	return IRM_INVALIDARG;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::GetSelectedOutput(double *so)
/* ---------------------------------------------------------------------- */
{
	
	IRM_RESULT rtn = IRM_OK;
	int n_user = this->workers[0]->GetCurrentSelectedOutputUserNumber();
#ifdef USE_MPI
	MPI_Bcast(&n_user,  1, MPI_INT, 0, MPI_COMM_WORLD);
	if (n_user >= 0)
	{
		std::map< int, CSelectedOutput >::iterator it = this->workers[0]->CSelectedOutputMap.find(n_user);
		if (it != this->workers[0]->CSelectedOutputMap.end())
		{
			this->SetCurrentSelectedOutputUserNumber(&n_user);
			int ncol = this->GetSelectedOutputColumnCount();
			int local_start_cell = 0;
			std::vector<double> dbuffer;
			for (int n = 0; n < this->mpi_tasks; n++)
			{
				int nrow;	
				if (this->mpi_myself == n)
				{	
					if (this->mpi_myself == 0) 
					{	
						it->second.Doublize(nrow, ncol, dbuffer);
					}
					else
					{
						it->second.Doublize(nrow, ncol, dbuffer);
						int length[2];
						length[0] = nrow;
						length[1] = ncol;
						MPI_Send(length, 2, MPI_INT, 0, 0, MPI_COMM_WORLD);
						MPI_Send(dbuffer.data(), nrow*ncol, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
					}

				}
				else if (this->mpi_myself == 0)
				{	
					MPI_Status mpi_status;
					int length[2];
					MPI_Recv(length, 2, MPI_INT, n, 0, MPI_COMM_WORLD, &mpi_status);
					nrow = length[0];
					ncol = length[1];
					dbuffer.resize(nrow*ncol);
					MPI_Recv(dbuffer.data(), nrow*ncol, MPI_DOUBLE, n, 0, MPI_COMM_WORLD, &mpi_status);
				}
				if (mpi_myself == 0)
				{
					if (so)
					{
						// Now write data from the process to so
						for (size_t icol = 0; icol < ncol; icol++)
						{
							for (size_t irow = 0; irow < nrow; irow++)
							{
								int ichem = local_start_cell + (int) irow;
								for (size_t k = 0; k < back[ichem].size(); k++)
								{
									int ixyz = back[ichem][k];
									so[icol*this->nxyz + ixyz] = dbuffer[icol*nrow + irow];
								}
							}
						}
						local_start_cell += nrow;
					}
					else
					{
						error_msg("NULL pointer in argument to GetSelectedOutput", 0);
						rtn = IRM_INVALIDARG;
					}
				}
			}
		}
		else
		{
			error_msg("Did not find current selected output in CSelectedOutputMap in  GetSelectedOutput", 0);
			rtn = IRM_INVALIDARG;
		}
		return rtn;
	}
#else

	if (n_user >= 0)
	{
		this->SetCurrentSelectedOutputUserNumber(&n_user);
		int ncol = this->GetSelectedOutputColumnCount();
		std::vector<double> dbuffer;
		int local_start_cell = 0;
		for (int n = 0; n < this->nthreads; n++)
		{
			int nrow_x, ncol_x;
			std::map< int, CSelectedOutput>::iterator cso_it = this->workers[n]->CSelectedOutputMap.find(n_user);
			if (cso_it != this->workers[n]->CSelectedOutputMap.end())
			{
				cso_it->second.Doublize(nrow_x, ncol_x, dbuffer);
				//assert(nrow_x == nrow);
				assert(ncol_x = ncol);

				// Now write data from thread to so
				if (so)
				{
					for (size_t icol = 0; icol < ncol; icol++)
					{
						for (size_t irow = 0; irow < nrow_x; irow++)
						{
							int ichem = local_start_cell + (int) irow;
							for (size_t k = 0; k < back[ichem].size(); k++)
							{
								int ixyz = back[ichem][k];
								so[icol*this->nxyz + ixyz] = dbuffer[icol*nrow_x + irow];
							}
						}
					}
				}
				else
				{
					error_msg("NULL pointer in argument to GetSelectedOutput", 0);
					rtn = IRM_INVALIDARG;
				}
			}
			else
			{
				return IRM_INVALIDARG;
			}
			local_start_cell += nrow_x;
		}
		return rtn;
	}
#endif
	return IRM_INVALIDARG;
}
/* ---------------------------------------------------------------------- */
int
Reaction_module::GetSelectedOutputColumnCount()
/* ---------------------------------------------------------------------- */
{	
	if (this->workers[0]->CurrentSelectedOutputUserNumber >= 0)
	{
		std::map< int, CSelectedOutput >::iterator it = this->workers[0]->CSelectedOutputMap.find(
			this->workers[0]->CurrentSelectedOutputUserNumber);
		if (it != this->workers[0]->CSelectedOutputMap.end())
		{
			return (int) it->second.GetColCount();
		}
	}
	return IRM_INVALIDARG;
}
/* ---------------------------------------------------------------------- */
int 
Reaction_module::GetSelectedOutputCount(void)
/* ---------------------------------------------------------------------- */
{	
	return (int) this->workers[0]->CSelectedOutputMap.size();
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::GetSelectedOutputHeading(int *icol, std::string &heading)
/* ---------------------------------------------------------------------- */
{
	if (this->workers[0]->CurrentSelectedOutputUserNumber >= 0)
	{
		std::map< int, CSelectedOutput >::iterator it = this->workers[0]->CSelectedOutputMap.find(
			this->workers[0]->CurrentSelectedOutputUserNumber);
		if (it != this->workers[0]->CSelectedOutputMap.end())
		{
			VAR pVar;
			VarInit(&pVar);
			if (icol != NULL && it->second.Get(0, *icol, &pVar) == IRM_OK)
			{
				if (pVar.type == TT_STRING)
				{
					heading = pVar.sVal;
					return IRM_OK;
				}
			}
		}
	}
	return IRM_INVALIDARG;
}
/* ---------------------------------------------------------------------- */
int
Reaction_module::GetSelectedOutputRowCount()
/* ---------------------------------------------------------------------- */
{
	return this->nxyz;
}
/* ---------------------------------------------------------------------- */
std::string 
Reaction_module::Char2TrimString(const char * str, long l)
/* ---------------------------------------------------------------------- */
{
	std::string stdstr;
	if (str)
	{
		if (l >= 0)
		{
			std::string tstr(str, l);
			stdstr = tstr;
		}
		else
		{
			stdstr = str;
		}
	}
	stdstr = trim(stdstr);
	return stdstr;
};
/* ---------------------------------------------------------------------- */
void
Reaction_module::Concentrations2Solutions(int n, std::vector<double> &c)
/* ---------------------------------------------------------------------- */
{
	// assumes total H, total O, and charge are transported
	int i, j, k;

#ifdef USE_MPI
	int start = this->start_cell[this->mpi_myself];
	int end = this->end_cell[this->mpi_myself];
#else
	int start = this->start_cell[n];
	int end = this->end_cell[n];
#endif

	for (j = start; j <= end; j++)
	{		
		std::vector<double> d;  // scratch space to convert from mass fraction to moles
		// j is count_chem number
		i = this->back[j][0];
		if (j < 0) continue;

		switch (this->input_units_Solution)
		{
		case 1:  // mg/L to mol/L
			{
				double *ptr = &c[i];
				// convert to mol/L
				for (k = 0; k < (int) this->components.size(); k++)
				{	
					d.push_back(ptr[this->nxyz * k] * 1e-3 / this->gfw[k]);
				}	
			}
			break;
		case 2:  // mol/L
			{
				double *ptr = &c[i];
				// convert to mol/L
				for (k = 0; k < (int) this->components.size(); k++)
				{	
					d.push_back(ptr[this->nxyz * k]);
				}	
			}
			break;
		case 3:  // mass fraction, kg/kg solution to mol/L
			{
				double *ptr = &c[i];
				// convert to mol/L
				for (k = 0; k < (int) this->components.size(); k++)
				{	
					d.push_back(ptr[this->nxyz * k] * 1000.0 / this->gfw[k] * density[i]);
				}	
			}
			break;
		}

		// convert mol/L to moles per cell
		for (k = 0; k < (int) this->components.size(); k++)
		{	
			d[k] *= this->pore_volume[i] / this->pore_volume_zero[i] * saturation[i];
		}
				
		// update solution 
		cxxNameDouble nd;
		for (k = 3; k < (int) components.size(); k++)
		{
			if (d[k] <= 1e-14) d[k] = 0.0;
			nd.add(components[k].c_str(), d[k]);
		}	

		cxxSolution *soln_ptr = this->GetWorkers()[n]->Get_solution(j);
		if (soln_ptr)
		{
			soln_ptr->Update(d[0], d[1], d[2], nd);
			soln_ptr->Set_patm(this->pressure[i]);
			soln_ptr->Set_tc(this->tempc[i]);
		}
	}
	return;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::RunFileThread(int n)
/* ---------------------------------------------------------------------- */
{
		IPhreeqcPhast * iphreeqc_phast_worker = this->GetWorkers()[n];
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

		// Run chemistry file
		if (iphreeqc_phast_worker->RunFile(this->chemistry_file_name.c_str()) > 0) ErrorStop("RunFile failed\n");

		// Create a StorageBin with initial PHREEQC for boundary conditions
		if (n == 0)
		{
			WriteOutput(iphreeqc_phast_worker->GetOutputString());
			this->Get_phreeqc_bin().Clear();
			this->GetWorkers()[0]->Get_PhreeqcPtr()->phreeqc2cxxStorageBin(this->Get_phreeqc_bin());
		}
		return IRM_OK;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::RunStringThread(int n, std::string & input)
/* ---------------------------------------------------------------------- */
{
		IPhreeqcPhast * iphreeqc_phast_worker = this->GetWorkers()[n];
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

		// Run chemistry file
		if (iphreeqc_phast_worker->RunString(input.c_str()) > 0) ErrorStop("RunString failed\n");

		// Create a StorageBin with initial PHREEQC for boundary conditions
		if (n == 0)
		{
			WriteOutput(iphreeqc_phast_worker->GetOutputString());
			this->Get_phreeqc_bin().Clear();
			this->GetWorkers()[0]->Get_PhreeqcPtr()->phreeqc2cxxStorageBin(this->Get_phreeqc_bin());
		}
		return IRM_OK;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::InitialPhreeqc2Concentrations(
					double *c, 
					int *n_boundary_in, 
					int *dim_in,
					int *boundary_solution1,
					int *boundary_solution2, 
					double *fraction1)
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
 *   Output: c - concentrations for boundary conditions
 *             - dimensions must be >= n_boundary x n_comp
 *
 */
	if (this->mpi_myself == 0) 
	{
		if (c != NULL && n_boundary_in != NULL && dim_in != NULL && boundary_solution1 != NULL)
		{
			int n_boundary = *n_boundary_in;
			int dim = *dim_in;
			int	i, n_old1, n_old2;
			double f1, f2;

			for (i = 0; i < n_boundary; i++)
			{
				cxxMix mixmap;
				n_old1 = boundary_solution1[i];
				n_old2 = (boundary_solution2) ? -1 : boundary_solution2[i];
				f1 = (fraction1) ? 1.0 : fraction1[i];
				f2 = 1 - f1;
				mixmap.Add(n_old1, f1);
				if (f2 > 0.0)
				{
					mixmap.Add(n_old2, f2);
				}

				// Make mass fractions in d
				cxxSolution	cxxsoln(phreeqc_bin.Get_Solutions(), mixmap, 0);
				std::vector<double> d;
				cxxSolution2concentration(&cxxsoln, d);

				// Put mass fractions in c
				double *d_ptr = &c[i];
				size_t j;
				for (j = 0; j < components.size(); j++)
				{
					d_ptr[dim * j] = d[j];
				}
			}
			return IRM_OK;
		}
		return IRM_INVALIDARG;
	}
	return IRM_OK;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::InitialPhreeqc2Module(
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
	initial_conditions2.resize(7 * this->nxyz, -1);
	fraction1.resize(7 * this->nxyz, 1.0);
	size_t array_size = (size_t) (7 * this->nxyz);
	if (this->mpi_myself == 0)
	{
		if (initial_conditions1_in == NULL)
		{
			std::ostringstream errstr;
			errstr << "NULL pointer in call to DistributeInitialConditions\n";
			error_msg(errstr.str().c_str(), 1);
		}

		memcpy(initial_conditions1.data(), initial_conditions1_in, array_size * sizeof(int));
		if (initial_conditions2_in != NULL)
		{
			memcpy(initial_conditions2.data(), initial_conditions2_in, array_size * sizeof(int));
		}
		if (fraction1_in != NULL)
		{
			memcpy(fraction1.data(), fraction1_in, array_size * sizeof(double));
		}
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
	 *  Copy solution, exchange, surface, gas phase, kinetics, solid solution for each active cell.
	 *  Does nothing for indexes less than 0 (i.e. restart files)
	 */

	size_t count_negative_porosity = 0;
	std::set<std::string> error_set;

#ifdef USE_MPI
	int begin = this->start_cell[this->mpi_myself];
	int end = this->end_cell[this->mpi_myself] + 1;
#else
	int begin = 0;
	int end = this->nxyz;
#endif
	
	for (int k = begin; k < end; k++)
	{	
#ifdef USE_MPI
		i = this->back[k][0];           /* i is ixyz number */
		j = k;                          /* j is count_chem number */
#else
		i = k;                          /* i is ixyz number */   
		j = this->forward[i];			/* j is count_chem number */
		if (j < 0)	continue;
#endif
		assert(forward[i] >= 0);
		assert (cell_volume[i] > 0.0);
		if (pore_volume_zero[i] < 0 || cell_volume[i] <= 0)
		{
			std::ostringstream errstr;
			errstr << "Nonpositive volume in cell " << i << ": volume, " << cell_volume[i]; 
			errstr << "\t initial volume, " << this->pore_volume_zero[i] << ".",
			count_negative_porosity++;
			error_msg(errstr.str().c_str());
			rtn = IRM_FAIL;
			continue;
		}
		if (this->CellInitialize(i, j, initial_conditions1.data(), initial_conditions2.data(),
			fraction1.data(), error_set) != IRM_OK)
		{
			rtn = IRM_FAIL;
		}
	}

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
#ifndef USE_MPI	
	// distribute to thread IPhreeqcs
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
		if (this->GetWorkers()[0]->RunString(delete_command.str().c_str()) > 0) ErrorStop("RunString failed");
	}
#endif
	return rtn;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::RunFile(int *initial_phreeqc, int * workers, int * utility, const char * chemistry_name, long l)
/* ---------------------------------------------------------------------- */
{
	if (mpi_myself == 0)
	{
		if (initial_phreeqc == NULL || workers == NULL || utility == NULL || chemistry_name == NULL)
		{
			Reaction_module::ErrorStop("NULL pointer in Reaction_module::RunFile");
		}
	}
	/*
	*  Run PHREEQC to obtain PHAST reactants
	*/
	std::vector<int> flags;
	flags.resize(3);
	this->SetChemistryFileName(chemistry_name, l);
	if (mpi_myself == 0)
	{
		flags[0] = *initial_phreeqc;
		flags[1] = *workers;
		flags[2] = *utility;
	}
#ifdef USE_MPI
	MPI_Bcast((void *) flags.data(), 3, MPI_INT, 0, MPI_COMM_WORLD);
#endif
	if (flags[0] != 0)
	{
		RunFileThread(this->nthreads);
	}
	if (flags[1] != 0)
	{
#ifdef THREADED_PHAST
		omp_set_num_threads(this->nthreads);
		#pragma omp parallel 
		#pragma omp for
#endif
		for (int n = 0; n < this->nthreads; n++)
		{
			RunFileThread(n);
		} 
	}	
	if (flags[2] != 0)
	{
		RunFileThread(this->nthreads + 1);
	}
	return IRM_OK;
}
/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::RunString(int *initial_phreeqc, int * workers, int * utility, const char * input_string, long l)
/* ---------------------------------------------------------------------- */
{
	if (mpi_myself == 0)
	{
		if (initial_phreeqc == NULL || workers == NULL || utility == NULL || input_string == NULL)
		{
			Reaction_module::ErrorStop("NULL pointer in Reaction_module::RunFile");
		}
	}
	/*
	*  Run PHREEQC to obtain PHAST reactants
	*/
	std::string input = Char2TrimString(input_string, l);
	std::vector<int> flags;
	flags.resize(4);
	if (mpi_myself == 0)
	{
		flags[0] = *initial_phreeqc;
		flags[1] = *workers;
		flags[2] = *utility;
		flags[3] = (int) input.size();
	}
#ifdef USE_MPI
	MPI_Bcast((void *) flags.data(), 4, MPI_INT, 0, MPI_COMM_WORLD);
	input.resize(flags[4]);
	MPI_Bcast((void *) input.c_str(), flags[4], MPI_CHAR, 0, MPI_COMM_WORLD);
#endif
	if (flags[0] != 0)
	{
		RunStringThread(this->nthreads, input);
	}
	if (flags[1] != 0)
	{
#ifdef THREADED_PHAST
		omp_set_num_threads(this->nthreads);
		#pragma omp parallel 
		#pragma omp for
#endif
		for (int n = 0; n < this->nthreads; n++)
		{
			RunStringThread(n, input);
		} 
	}	
	if (flags[2] != 0)
	{
		RunStringThread(this->nthreads + 1, input);
	}
	return IRM_OK;
}
/* ---------------------------------------------------------------------- */
int
Reaction_module::LoadDatabase(const char * database, long l)
/* ---------------------------------------------------------------------- */
{
	int rtn1 = this->SetDatabaseFileName(database, l);
	if (rtn1 < 0) 
	{
			error_msg("Reaction_module.LoadDatabase: Could not open database.", 0);
	}

	std::vector< int > rtn;
	rtn.resize(this->nthreads + 2);
#ifdef THREADED_PHAST
	omp_set_num_threads(this->nthreads+1);
	#pragma omp parallel 
	#pragma omp for
#endif
	for (int n = 0; n < this->nthreads + 2; n++)
	{
		rtn[n] = this->workers[n]->LoadDatabase(this->database_file_name.c_str());
	} 	
	int rtn_value = 0;
	for (int n = 0; n < this->nthreads + 2; n++)
	{
		rtn_value += rtn[n];
		if (rtn[n] != 0)
		{
			error_msg(this->workers[n]->GetErrorString(), 0);
		}
	}
	return rtn_value;
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::PartitionUZ(int n, int iphrq, int ihst, double new_frac)
/* ---------------------------------------------------------------------- */
{
	int n_user;
	double s1, s2, uz1, uz2;

	/* 
	 * repartition solids for partially saturated cells
	 */

	if ((fabs(this->old_saturation[ihst] - new_frac) > 1e-8) ? true : false)
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
	else if (new_frac > this->old_saturation[ihst])
	{
		/* wetting cell */
		uz1 = 0.;
		uz2 = (1.0 - new_frac) / (1.0 - this->old_saturation[ihst]);
		s1 = 1.;
		s2 = 1.0 - uz2;
	}
	else
	{
		/* draining cell */
		s1 = new_frac / this->old_saturation[ihst];
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

	this->old_saturation[ihst] = new_frac;
}
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
void
Reaction_module::RebalanceLoadPerCell(void)
/* ---------------------------------------------------------------------- */
{
	if (this->mpi_tasks <= 1) return;
	if (this->mpi_tasks > count_chemistry) return;
#include <time.h>

	// vectors for each cell (count_chem)
	std::vector<double> recv_cell_times, normalized_cell_times;
	recv_cell_times.resize(this->count_chemistry);
	
	// vectors for each process (mpi_tasks)
	std::vector<double> standard_time, task_fraction, task_time;
	
	// Assume homogeneous cluster for now
	double tasks_total = 0;
	for (size_t i = 0; i < (size_t) mpi_tasks; i++)
	{
		standard_time.push_back(1.0);   // For heterogeneous cluster, need times for a standard task here
		tasks_total += 1.0 / standard_time[i];
	}

	for (size_t i = 0; i < (size_t) mpi_tasks; i++)
	{
		task_fraction.push_back((1.0 / standard_time[i]) / tasks_total);
	}
	// Collect times
	IPhreeqcPhast * phast_iphreeqc_worker = this->workers[0];
	// manager
	if (mpi_myself == 0)
	{
		recv_cell_times.insert(recv_cell_times.begin(), 
			phast_iphreeqc_worker->Get_cell_clock_times().begin(),
			phast_iphreeqc_worker->Get_cell_clock_times().end());
	}

	// workers
	for (int i = 1; i < mpi_tasks; i++)
	{
		int n = end_cell[i] - start_cell[i] + 1;
		if (mpi_myself == i)
		{
			MPI_Send(phast_iphreeqc_worker->Get_cell_clock_times().data(), n, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
		}
		if (mpi_myself == 0)
		{
			MPI_Status mpi_status;
			MPI_Recv((void *) &recv_cell_times[start_cell[i]], n, MPI_DOUBLE, i, 0, MPI_COMM_WORLD, &mpi_status);
		}
	}

	// Root normalizes times, calculates efficiency, rebalances work
	double normalized_total_time = 0;
	double max_task_time = 0;
	// working space
	std::vector<int> start_cell_new;
	std::vector<int> end_cell_new;
	start_cell_new.resize(mpi_tasks, 0);
	end_cell_new.resize(mpi_tasks, 0);

	if (mpi_myself == 0)
	{
		// Normalize times
		max_task_time = 0;
		for (size_t i = 0; i < (size_t) mpi_tasks; i++)
		{		
			double task_sum = 0;
			// normalize cell_times with standard_time
			for (size_t j = (size_t) start_cell[i]; j <= (size_t) end_cell[i]; j++)
			{
				task_sum += recv_cell_times[j];
				normalized_cell_times.push_back(recv_cell_times[j]/standard_time[i]);
				normalized_total_time += normalized_cell_times.back();
			}
			task_time.push_back(task_sum);
			max_task_time = (task_sum > max_task_time) ? task_sum : max_task_time;
		}

		// calculate efficiency
		double efficiency = 0;
		for (size_t i = 0; i < (size_t) mpi_tasks; i++)
		{
			efficiency += task_time[i] / max_task_time * task_fraction[i];
		}
		std::cerr << "          Estimated efficiency of chemistry without communication: " << 
					   (float) (100. * efficiency) << "\n";

		// Split up work
		double f_low, f_high;
		f_high = 1 + 0.5 / ((double) mpi_tasks);
		f_low = 1;
		int j = 0;
		for (size_t i = 0; i < (size_t) mpi_tasks - 1; i++)
		{
			if (i > 0)
			{
				start_cell_new[i] = end_cell_new[i - 1] + 1;
			}
			double sum_work = 0;
			double temp_sum_work = 0;
			bool next = true;
			while (next)
			{
				temp_sum_work += normalized_cell_times[j] / normalized_total_time;
				if ((temp_sum_work < task_fraction[i]) && (((size_t) count_chemistry - j) > (size_t) (mpi_tasks - i)))
					//(temp_sum_work < f_high * task_fraction[i]) || (sum_work < 0.5 * task_fraction[i])
					//) 
					//&&
					//(count_chem - j) > (mpi_tasks - i)
					//)
				{
					sum_work = temp_sum_work;
					j++;
					next = true;
				}
				else
				{
					if (j == start_cell_new[i])
					{
						end_cell_new[i] = j;
						j++;
					}
					else
					{
						end_cell_new[i] = j - 1;
					}
					next = false;
				}
			}
		}
		assert(j < count_chemistry);
		assert(mpi_tasks > 1);
		start_cell_new[mpi_tasks - 1] = end_cell_new[mpi_tasks - 2] + 1;
		end_cell_new[mpi_tasks - 1] = count_chemistry - 1;

		// Apply rebalance fraction
		for (size_t i = 0; i < (size_t) mpi_tasks - 1; i++)
		{
			int	icells;
			icells = (int) (((double) (end_cell_new[i] - end_cell[i])) * (this->rebalance_fraction) );
			if (icells == 0)
			{
				icells = end_cell_new[i] - end_cell[i];
			}
			end_cell_new[i] = end_cell[i] + icells;
			start_cell_new[i + 1] = end_cell_new[i] + 1;
		}
	}
	
	/*
	 *   Broadcast new subcolumns
	 */
	
	MPI_Bcast((void *) start_cell_new.data(), mpi_tasks, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast((void *) end_cell_new.data(), mpi_tasks, MPI_INT, 0, MPI_COMM_WORLD);
	
	/*
	 *   Redefine columns
	 */
	int nnew = 0;
	int old = 0;
	int change = 0;
	std::vector<std::vector<int> > change_list;

	for (int k = 0; k < this->count_chemistry; k++)
	{
		int i = k;
		//int iphrq = i;			/* iphrq is 1 to count_chem */
		int ihst = this->back[i][0];	/* ihst is 1 to nxyz */
		old_saturation[ihst] = saturation[ihst];    /* update all old_frac */
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

		// Need to send cell from old task to nnew task
		std::vector<int> ints;
		ints.push_back(k);
		ints.push_back(old);
		ints.push_back(nnew);
		change_list.push_back(ints);
	}

	// Transfer cells
	int transfers = 0;
	int count=0;
	if (change_list.size() > 0)
	{
		std::vector<std::vector<int> >::const_iterator it = change_list.begin();
		int pold = (*it)[1];
		int pnew = (*it)[2];
		cxxStorageBin t_bin;
		for (; it != change_list.end(); it++)
		{
			int n = (*it)[0];
			int old = (*it)[1];
			int nnew = (*it)[2];
			if (old != pold || nnew != pnew)
			{
				transfers++;
				this->TransferCells(t_bin, pold, pnew);
				t_bin.Clear();
				pold = old;
				pnew = nnew;
				
			}	
			count++;
			// Put cell in t_bin
			if (this->mpi_myself == pold)
			{
				phast_iphreeqc_worker->Get_PhreeqcPtr()->phreeqc2cxxStorageBin(t_bin, n);
				std::ostringstream del;
				del << "DELETE; -cell " << n << "\n";
				phast_iphreeqc_worker->RunString(del.str().c_str());
			}
		}
		// Last transfer
		transfers++;
		this->TransferCells(t_bin, pold, pnew);
	}
	
	for (int i = 0; i < this->mpi_tasks; i++)
	{
		start_cell[i] = start_cell_new[i];
		end_cell[i] = end_cell_new[i];
	}

	if (this->mpi_myself == 0)
	{
		std::cerr << "          Cells shifted between processes   " << change << "\n";
		//std::cerr << "          Number of mpi cell transfers      " << transfers << "\n";
	}
	return;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::RebalanceLoad(void)
/* ---------------------------------------------------------------------- */
{
	if (this->mpi_tasks <= 1) return;
	if (this->mpi_tasks > count_chemistry) return;
	if (this->rebalance_method != 0)
	{
		return RebalanceLoadPerCell();
	}
#include <time.h>

	// working space
	std::vector<int> start_cell_new;
	std::vector<int> end_cell_new;
	for (int i = 0; i < this->mpi_tasks; i++)
	{
		start_cell_new.push_back(0);
		end_cell_new.push_back(0);
	}
	std::vector<int> cells_v;
	std::ostringstream error_stream;
	bool good_enough = false;

	// Calculate time per cell for this process
	IPhreeqcPhast * phast_iphreeqc_worker = this->workers[0];
	int cells = this->end_cell[this->mpi_myself] - this->start_cell[this->mpi_myself] + 1;
	double time_per_cell = phast_iphreeqc_worker->Get_thread_clock_time()/((double) cells);

	// Gather times at root
	std::vector<double> recv_buffer;
	recv_buffer.resize(this->mpi_tasks);
	MPI_Gather(&time_per_cell, 1, MPI_DOUBLE, recv_buffer.data(), 1, MPI_DOUBLE, 0,
			   MPI_COMM_WORLD);
	
	if (this->mpi_myself == 0)
	{
		double total = 0;
		for (int i = 0; i < this->mpi_tasks; i++)
		{
			total += recv_buffer[i];
		}
		double avg = total / (double) this->mpi_tasks;
		// Normalize
		total = 0;
		for (int i = 0; i < this->mpi_tasks; i++)
		{
			assert(recv_buffer[i] >= 0);
			if (recv_buffer[i] == 0) recv_buffer[i] = 0.25*avg;
			total += recv_buffer[0] / recv_buffer[i];
		}

		// Set first and last cells
		double new_n = this->count_chemistry / total; /* new_n is number of cells for root */


		// Calculate number of cells per process, rounded to lower number
		int	total_cells = 0;
		int n = 0;
		for (int i = 0; i < this->mpi_tasks; i++)
		{
			n = (int) floor(new_n * recv_buffer[0] / recv_buffer[i]);
			if (n < 1)
				n = 1;
			cells_v.push_back(n);
			total_cells += n;
		}

		// Distribute cells from rounding down
		int diff_cells = this->count_chemistry - total_cells;
		if (diff_cells > 0)
		{
			for (int j = 0; j < diff_cells; j++)
			{
				int min_cell = 0;
				double min_time = (cells_v[0] + 1) * recv_buffer[0];
				for (int i = 1; i < this->mpi_tasks; i++)
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
				for (int i = 0; i < this->mpi_tasks; i++)
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

		// Fill in subcolumn ends
		int last = -1;
		for (int i = 0; i < this->mpi_tasks; i++)
		{
			start_cell_new[i] = last + 1;
			end_cell_new[i] = start_cell_new[i] + cells_v[i] - 1;
			last = end_cell_new[i];
		}

		// Check that all cells are distributed
		if (end_cell_new[this->mpi_tasks - 1] != this->count_chemistry - 1)
		{
			error_stream << "Failed: " << diff_cells << ", count_cells " << this->count_chemistry << ", last cell "
				<< end_cell_new[this->mpi_tasks - 1] << "\n";
			for (int i = 0; i < this->mpi_tasks; i++)
			{
				error_stream << i << ": first " << start_cell_new[i] << "\tlast " << end_cell_new[i] << "\n";
			}
			error_stream << "Failed to redistribute cells." << "\n";
			error_msg(error_stream.str().c_str(), STOP);
		}

		// Compare old and new times
		double max_old = 0.0;
		double max_new = 0.0;
		for (int i = 0; i < this->mpi_tasks; i++)
		{
			double t = cells_v[i] * recv_buffer[i];
			if (t > max_new)
				max_new = t;
			t = (end_cell[i] - start_cell[i] + 1) * recv_buffer[i];
			if (t > max_old)
				max_old = t;
		}
		std::cerr << "          Estimated efficiency of chemistry " << (float) ((LDBLE) 100. * max_new / max_old) << "\n";


		if ((max_old - max_new) / max_old < 0.05)
		{
			for (int i = 0; i < this->mpi_tasks; i++)
			{
				start_cell_new[i] = start_cell[i];
				end_cell_new[i] = end_cell[i];
			}
			good_enough = true;
		}
		else
		{
			for (int i = 0; i < this->mpi_tasks - 1; i++)
			{
				int icells = (int) ((end_cell_new[i] - end_cell[i]) * this->rebalance_fraction);
				end_cell_new[i] = end_cell[i] + icells;
				start_cell_new[i + 1] = end_cell_new[i] + 1;
			}
		}
	}

	/*
	 *   Broadcast new subcolumns
	 */
	
	MPI_Bcast((void *) start_cell_new.data(), mpi_tasks, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast((void *) end_cell_new.data(), mpi_tasks, MPI_INT, 0, MPI_COMM_WORLD);
	
	/*
	 *   Redefine columns
	 */
	int nnew = 0;
	int old = 0;
	int change = 0;
	std::vector<std::vector<int> > change_list;

	for (int k = 0; k < this->count_chemistry; k++)
	{
		int i = k;
		//int iphrq = i;			/* iphrq is 1 to count_chem */
		int ihst = this->back[i][0];	/* ihst is 1 to nxyz */
		old_saturation[ihst] = saturation[ihst];    /* update all old_frac */
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

		// Need to send cell from old task to nnew task
		std::vector<int> ints;
		ints.push_back(k);
		ints.push_back(old);
		ints.push_back(nnew);
		change_list.push_back(ints);
	}

	// Transfer cells
	int transfers = 0;
	int count=0;
	if (change_list.size() > 0)
	{
		std::vector<std::vector<int> >::const_iterator it = change_list.begin();
		int pold = (*it)[1];
		int pnew = (*it)[2];
		cxxStorageBin t_bin;
		for (; it != change_list.end(); it++)
		{
			int n = (*it)[0];
			int old = (*it)[1];
			int nnew = (*it)[2];
			if (old != pold || nnew != pnew)
			{
				transfers++;
				this->TransferCells(t_bin, pold, pnew);
				t_bin.Clear();
				pold = old;
				pnew = nnew;
				
			}	
			count++;
			// Put cell in t_bin
			if (this->mpi_myself == pold)
			{
				phast_iphreeqc_worker->Get_PhreeqcPtr()->phreeqc2cxxStorageBin(t_bin, n);
				std::ostringstream del;
				del << "DELETE; -cell " << n << "\n";
				phast_iphreeqc_worker->RunString(del.str().c_str());
			}
		}
		// Last transfer
		transfers++;
		this->TransferCells(t_bin, pold, pnew);
	}
	
	for (int i = 0; i < this->mpi_tasks; i++)
	{
		start_cell[i] = start_cell_new[i];
		end_cell[i] = end_cell_new[i];
	}

	if (this->mpi_myself == 0)
	{
		std::cerr << "          Cells shifted between threads     " << change << "\n";
		//std::cerr << "          Number of mpi cell transfers      " << transfers << "\n";
	}
	return;
}
void
Reaction_module::TransferCells(cxxStorageBin &t_bin, int old, int nnew)
{
	if (this->mpi_myself == old)
	{
		std::ostringstream raw_stream;
		t_bin.dump_raw(raw_stream, 0);

		int size = (int) raw_stream.str().size();
		MPI_Send(&size, 1, MPI_INT, nnew, 0, MPI_COMM_WORLD);
		MPI_Send((void *) raw_stream.str().c_str(), size, MPI_CHARACTER, nnew, 0, MPI_COMM_WORLD);	
	}
	else if (this->mpi_myself == nnew)
	{	
		MPI_Status mpi_status;
		// Transfer cells		
		int size;
		MPI_Recv(&size, 1, MPI_INT, old, 0, MPI_COMM_WORLD, &mpi_status);
		std::vector<char> raw_buffer;
		raw_buffer.resize(size + 1);
		MPI_Recv((void *) raw_buffer.data(), size, MPI_CHARACTER, old, 0, MPI_COMM_WORLD, &mpi_status);
		raw_buffer[size] = '\0';

		// RunString to enter in module
		IPhreeqcPhast * phast_iphreeqc_worker = this->workers[0];
		phast_iphreeqc_worker->RunString(raw_buffer.data());
	}
}
#else
/* ---------------------------------------------------------------------- */
void
Reaction_module::RebalanceLoad(void)
/* ---------------------------------------------------------------------- */
{
	// Threaded version
	if (this->nthreads <= 1) return;
	if (this->nthreads > count_chemistry) return;
#include <time.h>
	if (this->rebalance_method != 0)
	{
		RebalanceLoadPerCell();
		return; 
	}
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
			error_stream << "Time for cell " << i << ": " << recv_buffer.back() << "\n";
			recv_buffer.back() = 1;
			//error = true;
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
	double new_n = this->count_chemistry / total; /* new_n is number of cells for root */
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
	int diff_cells = this->count_chemistry - total_cells;
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
	if (end_cell_new[this->nthreads - 1] != this->count_chemistry - 1)
	{
		error_stream << "Failed: " << diff_cells << ", count_cells " << this->count_chemistry << ", last cell "
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


	if ((max_old - max_new) / max_old < 0.05)
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
			int icells = (int) ((end_cell_new[i] - end_cell[i]) * this->rebalance_fraction);
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

	for (int k = 0; k < this->count_chemistry; k++)
	{
		int i = k;
		int iphrq = i;			/* iphrq is 1 to count_chem */
		//int ihst = this->back[i][0];	/* ihst is 1 to nxyz */
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
Reaction_module::RebalanceLoadPerCell(void)
/* ---------------------------------------------------------------------- */
{
	// Threaded version
	if (this->nthreads <= 1) return;
	if (this->nthreads > count_chemistry) return;
#include <time.h>

	// vectors for each cell (count_chem)
	std::vector<double> recv_cell_times, normalized_cell_times;
	
	// vectors for each process (mpi_tasks)
	std::vector<double> standard_time, task_fraction, task_time;
	
	// Assume homogeneous cluster for now
	double tasks_total = 0;
	for (size_t i = 0; i < (size_t) this->nthreads; i++)
	{
		standard_time.push_back(1.0);   // For heterogeneous cluster, need times for a standard task here
		tasks_total += 1.0 / standard_time[i];
	}

	for (size_t i = 0; i < (size_t) this->nthreads; i++)
	{
		task_fraction.push_back((1.0 / standard_time[i]) / tasks_total);
	}


	for (size_t i = 0; i < (size_t) this->nthreads; i++)
	{
		IPhreeqcPhast * phast_iphreeqc_worker = this->workers[i];
		//std::cerr << "Thread: " << i << " " << phast_iphreeqc_worker->Get_cell_clock_times().size() << std::endl;
		std::vector<double>::const_iterator cit;
		for (cit = phast_iphreeqc_worker->Get_cell_clock_times().begin();
			cit != phast_iphreeqc_worker->Get_cell_clock_times().end();
			cit++)
		{
			recv_cell_times.push_back(*cit);
			//std::cerr << "Threadxx: " << i << " " << recv_cell_times.back() << std::endl;
		}
	}

	// Root normalizes times, calculates efficiency, rebalances work
	double normalized_total_time = 0;
	double max_task_time = 0;
	// working space
	std::vector<int> start_cell_new;
	std::vector<int> end_cell_new;
	start_cell_new.resize(this->nthreads, 0);
	end_cell_new.resize(this->nthreads, 0);

	//if (mpi_myself == 0)
	{
		// Normalize times
		max_task_time = 0;
		for (size_t i = 0; i < (size_t) this->nthreads; i++)
		{		
			double task_sum = 0;
			// normalize cell_times with standard_time
			for (size_t j = (size_t) start_cell[i]; j <= (size_t) end_cell[i]; j++)
			{
				task_sum += recv_cell_times[j];
				normalized_cell_times.push_back(recv_cell_times[j]/standard_time[i]);
				normalized_total_time += normalized_cell_times.back();
			}
			task_time.push_back(task_sum);
			max_task_time = (task_sum > max_task_time) ? task_sum : max_task_time;
		}

		// calculate efficiency
		double efficiency = 0;
		for (size_t i = 0; i < (size_t) this->nthreads; i++)
		{
			efficiency += task_time[i] / max_task_time * task_fraction[i];
		}
		std::cerr << "          Estimated efficiency of chemistry without communication: " << 
					   (float) (100. * efficiency) << "\n";;

		// Split up work
		double f_low, f_high;
		f_high = 1 + 0.5 / ((double) this->nthreads);
		f_low = 1;
		int j = 0;
		for (size_t i = 0; i < (size_t) this->nthreads - 1; i++)
		{
			if (i > 0)
			{
				start_cell_new[i] = end_cell_new[i - 1] + 1;
			}
			double sum_work = 0;
			double temp_sum_work = 0;
			bool next = true;
			while (next)
			{
				temp_sum_work += normalized_cell_times[j] / normalized_total_time;
				if ((temp_sum_work < task_fraction[i]) && ((count_chemistry - (int) j) > (this->nthreads - (int) i)))
				{
					sum_work = temp_sum_work;
					j++;
					next = true;
				}
				else
				{
					if (j == start_cell_new[i])
					{
						end_cell_new[i] = j;
						j++;
					}
					else
					{
						end_cell_new[i] = j - 1;
					}
					next = false;
				}
			}
		}
		assert(j < count_chemistry);
		assert(this->nthreads > 1);
		start_cell_new[this->nthreads - 1] = end_cell_new[this->nthreads - 2] + 1;
		end_cell_new[this->nthreads - 1] = count_chemistry - 1;

		// Apply rebalance fraction
		for (size_t i = 0; i < (size_t) this->nthreads - 1; i++)
		{
			int	icells;
			icells = (int) (((double) (end_cell_new[i] - end_cell[i])) * (this->rebalance_fraction) );
			if (icells == 0)
			{
				icells = end_cell_new[i] - end_cell[i];
			}
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

	for (int k = 0; k < this->count_chemistry; k++)
	{
		int i = k;
		int iphrq = i;			/* iphrq is 1 to count_chem */
		//int ihst = this->back[i][0];	/* ihst is 1 to nxyz */
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
#endif
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
void
Reaction_module::RunCells()
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes mass fractions from HST, equilibrates each cell,
 *   and returns new mass fractions to HST
 */

/*
 *   Update solution compositions in sz_bin
 */
	
	//clock_t t0 = clock();
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
		RunCellsThread(n);
	} 

	std::vector<char> char_buffer;
	std::vector<double> double_buffer;
	for (int n = 0; n < this->mpi_tasks; n++)
	{

		// write output results
		if (this->print_chemistry_on)
		{		
			// Need to transfer output stream to root and print
			if (this->mpi_myself == n)
			{
				if (n == 0)
				{
					WriteOutput(this->workers[0]->Get_out_stream().str().c_str());
					delete &this->workers[0]->Get_out_stream();
				}
				else
				{
					int size = (int) this->workers[0]->Get_out_stream().str().size();
					MPI_Send(&size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
					MPI_Send((void *) this->workers[0]->Get_out_stream().str().c_str(), size, MPI_CHARACTER, 0, 0, MPI_COMM_WORLD);
					delete &this->workers[0]->Get_out_stream();
				}	
			}
			else if (this->mpi_myself == 0)
			{
				MPI_Status mpi_status;
				int size;
				MPI_Recv(&size, 1, MPI_INT, n, 0, MPI_COMM_WORLD, &mpi_status);
				char_buffer.resize(size + 1);
				MPI_Recv((void *) char_buffer.data(), size, MPI_CHARACTER, n, 0, MPI_COMM_WORLD, &mpi_status);
				char_buffer[size] = '\0';
				WriteOutput(char_buffer.data());
			}
		}
	} 	
	this->CheckSelectedOutput();

	// Rebalance load
	this->RebalanceLoad();
	//std::cerr << "Running: " << (double) (clock() - t0) << std::endl;
}
#else
/* ---------------------------------------------------------------------- */
void
Reaction_module::RunCells()
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine takes mass fractions from HST, equilibrates each cell,
 *   and returns new mass fractions to HST
 */

/*
 *   Update solution compositions in sz_bin
 */
	//clock_t t0 = clock();


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
		RunCellsThread(n);
	} 
	for (int n = 0; n < this->nthreads; n++)
	{
		// write output results
		if (this->print_chemistry_on)
		{
			WriteOutput(this->workers[n]->Get_out_stream().str().c_str());
		}
		delete &this->workers[n]->Get_out_stream();
	} 	
	this->CheckSelectedOutput();

	// Rebalance load
	this->RebalanceLoad();
	//std::cerr << "Running: " << (double) (clock() - t0) << std::endl;
}
#endif
/* ---------------------------------------------------------------------- */
void 
Reaction_module::RunCellsThread(int n)
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

	int i, j;
	IPhreeqcPhast *phast_iphreeqc_worker = this->GetWorkers()[n];

	// selected output IPhreeqcPhast
	phast_iphreeqc_worker->CSelectedOutputMap.clear();
	std::vector<int> types;
	std::vector<long> longs;
	std::vector<double> doubles;
	std::string strings;

	// Do not write to files from phreeqc, run_cells writes files
	phast_iphreeqc_worker->SetLogFileOn(false);
	phast_iphreeqc_worker->SetSelectedOutputFileOn(false);
	phast_iphreeqc_worker->SetDumpFileOn(false);
	phast_iphreeqc_worker->SetDumpStringOn(false);
	phast_iphreeqc_worker->SetOutputFileOn(false);
	phast_iphreeqc_worker->SetErrorFileOn(false);
#ifdef USE_MPI
	int start = this->start_cell[this->mpi_myself];
	int end = this->end_cell[this->mpi_myself];
#else
	int start = this->start_cell[n];
	int end = this->end_cell[n];
#endif
	phast_iphreeqc_worker->Get_cell_clock_times().clear();
	for (i = start; i <= end; i++)
	{							/* i is count_chem number */
		j = back[i][0];			/* j is nxyz number */
#ifdef USE_MPI
		phast_iphreeqc_worker->Get_cell_clock_times().push_back(- (double) MPI_Wtime());
#else
		phast_iphreeqc_worker->Get_cell_clock_times().push_back(- (double) clock());
#endif
		// Set local print flags
		bool pr_chem = this->print_chemistry_on && (this->print_chem_mask[j] != 0);

		// partition solids between UZ and SZ
		if (this->partition_uz_solids)
		{
			this->PartitionUZ(n, i, j, this->saturation[j]);
		}

		// ignore small saturations
		bool active = true;
		if (this->saturation[j] <= 1e-10) 
		{
			this->saturation[j] = 0.0;
			active = false;
		}
		
		if (active)
		{
			// set cell number, pore volume got Basic functions
			phast_iphreeqc_worker->Set_cell_volumes(i, pore_volume_zero[j], this->saturation[j], cell_volume[j]);

			// Set print flags
			phast_iphreeqc_worker->SetOutputStringOn(pr_chem);

			// do the calculation
			std::ostringstream input;
			input << "RUN_CELLS\n";
			input << "  -start_time " << (this->time - this->time_step) << "\n";
			input << "  -time_step  " << this->time_step << "\n";
			input << "  -cells      " << i << "\n";
			input << "END" << "\n";
			if (phast_iphreeqc_worker->RunString(input.str().c_str()) < 0) ErrorStop();

			// Write output file
			if (pr_chem)
			{
				std::ostringstream line_buff;
				line_buff << "Time:           " << (this->time) * (this->time_conversion) << "\n";
                line_buff << "Chemistry cell: " << j << "\n";
				line_buff << "Grid cell(s):   ";
				for (size_t ib = 0; ib < this->back[j].size(); ib++)
				{
					line_buff << back[j][ib] << " ";
				}
				line_buff << "\n";
				phast_iphreeqc_worker->Get_out_stream() << line_buff.str();
				phast_iphreeqc_worker->Get_out_stream() << phast_iphreeqc_worker->GetOutputString();
			}

			// Save selected output data
			if (this->selected_output_on)
			{
				// Add selected output values to IPhreeqcPhast CSelectedOutputMap's
				std::map< int, CSelectedOutput* >::iterator it = phast_iphreeqc_worker->SelectedOutputMap.begin();
				for ( ; it != phast_iphreeqc_worker->SelectedOutputMap.end(); it++)
				{
					int n_user = it->first;
					std::map< int, CSelectedOutput >::iterator ipp_it = phast_iphreeqc_worker->CSelectedOutputMap.find(n_user);
					assert(it->second->GetRowCount() == 2);
					if (ipp_it == phast_iphreeqc_worker->CSelectedOutputMap.end())
					{
						CSelectedOutput cso;
						phast_iphreeqc_worker->CSelectedOutputMap[n_user] = cso;
						ipp_it = phast_iphreeqc_worker->CSelectedOutputMap.find(n_user);
					}
					types.clear();
					longs.clear();
					doubles.clear();
					strings.clear();
					it->second->Serialize(types, longs, doubles, strings);
					ipp_it->second.DeSerialize(types, longs, doubles, strings);
				}
			}
		} // end active
		else
		{
			if (pr_chem)
			{
				std::ostringstream line_buff;
				line_buff << "Time:           " << (this->time) * (this->time_conversion) << "\n";
                line_buff << "Chemistry cell: " << j + 1 << "\n";
				line_buff << "Grid cell(s):   ";
				for (size_t ib = 0; ib < this->back[j].size(); ib++)
				{
					line_buff << back[j][ib] << " ";
				}
				line_buff << "\nCell is dry.\n";
				phast_iphreeqc_worker->Get_out_stream() << line_buff.str();
			}
			// Write hdf file
			if (this->selected_output_on)
			{
				bool add_to_cselectedoutputmap = false;
				// Make dummy run if CSelectedOutputMap not complete	
				{
					std::map< int, CSelectedOutput* >::iterator it = phast_iphreeqc_worker->SelectedOutputMap.begin();
					for ( ; it != phast_iphreeqc_worker->SelectedOutputMap.end(); it++)
					{
						std::map< int, CSelectedOutput >::iterator ipp_it = phast_iphreeqc_worker->CSelectedOutputMap.find(it->first);
						if (ipp_it == phast_iphreeqc_worker->CSelectedOutputMap.end())
						{
							// Make a dummy run to fill in headings of selected output
							std::ostringstream input;
							input << "SOLUTION " << n + 1 << "; DELETE; -solution " << n + 1 << "\n";
							if (phast_iphreeqc_worker->RunString(input.str().c_str()) < 0) ErrorStop();
							add_to_cselectedoutputmap = true;
							break;
						}
					}
				}
				if (add_to_cselectedoutputmap)
				{
					std::map< int, CSelectedOutput* >::iterator it = phast_iphreeqc_worker->SelectedOutputMap.begin();
					for ( ; it != phast_iphreeqc_worker->SelectedOutputMap.end(); it++)
					{
						int iso = it->first;
						std::map< int, CSelectedOutput >::iterator ipp_it = phast_iphreeqc_worker->CSelectedOutputMap.find(it->first);
						if (ipp_it == phast_iphreeqc_worker->CSelectedOutputMap.end())
						{
							// Add new item to CSelectedOutputMap
							CSelectedOutput cso;
							// Fill in columns
							phast_iphreeqc_worker->SetCurrentSelectedOutputUserNumber(iso);
							int columns = phast_iphreeqc_worker->GetSelectedOutputColumnCount();
							for (int i = 0; i < columns; i++)
							{
								VAR pvar, pvar1;
								VarInit(&pvar);
								VarInit(&pvar1);
								phast_iphreeqc_worker->GetSelectedOutputValue(0, i, &pvar);
								cso.PushBack(pvar.sVal, pvar1);
							}
							phast_iphreeqc_worker->CSelectedOutputMap[iso] = cso;
						}
					}
				}
				// Add selected output values to IPhreeqcPhast CSelectedOutputMap
				std::map< int, CSelectedOutput* >::iterator it = phast_iphreeqc_worker->SelectedOutputMap.begin();
				for ( ; it != phast_iphreeqc_worker->SelectedOutputMap.end(); it++)
				{
					int iso = it->first;
					std::map< int, CSelectedOutput >::iterator ipp_it = phast_iphreeqc_worker->CSelectedOutputMap.find(iso);
					ipp_it->second.EndRow();
				}
			}
		}
#ifdef USE_MPI
		phast_iphreeqc_worker->Get_cell_clock_times().back() += (double) MPI_Wtime();
#else
		phast_iphreeqc_worker->Get_cell_clock_times().back() += (double) clock();
#endif
	} // end one cell
#ifndef USE_MPI
#endif
	clock_t t_elapsed = clock() - t0;

#ifdef USE_MPI
	//std::cerr << "          Process: " << this->mpi_myself << " Time: " << (double) t_elapsed << " Cells: " << this->end_cell[this->mpi_myself] - this->start_cell[this->mpi_myself] + 1 << std::endl;
#else
	//std::cerr << "          Thread: " << n << " Time: " << (double) t_elapsed << " Cells: " << this->end_cell[n] - this->start_cell[n] + 1 << "\n";
#endif
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
int 
Reaction_module::SetCurrentSelectedOutputUserNumber(int *i)
{
	if (i != NULL && *i >= 0)
	{
		return this->workers[0]->SetCurrentSelectedOutputUserNumber(*i);
	}
	return VR_INVALIDARG;
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::SetFilePrefix(const char * prefix, long l)
/* ---------------------------------------------------------------------- */
{
	if (this->mpi_myself == 0)
	{	
		this->file_prefix = Char2TrimString(prefix, l);
	}
#ifdef USE_MPI
	int l1 = 0;
	if (mpi_myself == 0)
	{
		l1 = (int) this->file_prefix.size();
	}
	MPI_Bcast(&l1, 1, MPI_INT, 0, MPI_COMM_WORLD);
	this->file_prefix.resize(l1);
	MPI_Bcast((void *) this->file_prefix.c_str(), l1, MPI_CHARACTER, 0, MPI_COMM_WORLD);
#endif
	if (this->file_prefix.size() > 0)
	{
		return IRM_OK;
	}
	return IRM_INVALIDARG;
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::SetCellVolume(double *t)
/* ---------------------------------------------------------------------- */
{
	if (this->cell_volume.size() < this->nxyz)
	{
		this->cell_volume.resize(this->nxyz);
	}
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in Set_volume", 1);
		memcpy(this->cell_volume.data(), t, (size_t) (this->nxyz * sizeof(double)));
	}
#ifdef USE_MPI
	MPI_Bcast(this->cell_volume.data(), this->nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::SetChemistryFileName(const char * cn, long l)
/* ---------------------------------------------------------------------- */
{
	if (this->mpi_myself == 0)
	{	
		this->chemistry_file_name = Char2TrimString(cn, l);
	}
#ifdef USE_MPI
	int l1 = 0;
	if (mpi_myself == 0)
	{
		l1 = (int) this->chemistry_file_name.size();
	}
	MPI_Bcast(&l1, 1, MPI_INT, 0, MPI_COMM_WORLD);
	this->chemistry_file_name.resize(l1);
	MPI_Bcast((void *) this->chemistry_file_name.c_str(), l1, MPI_CHARACTER, 0, MPI_COMM_WORLD);
#endif
	if (this->chemistry_file_name.size() > 0)
	{
		return IRM_OK;
	}
	return IRM_INVALIDARG;
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::SetConcentrations(double *t)
/* ---------------------------------------------------------------------- */
{
	// Distribute data
	size_t ncomps = this->components.size();
	std::vector<double> c;
	c.resize(ncomps * nxyz, INACTIVE_CELL_VALUE);
	if (mpi_myself == 0)
	{
		if (t == NULL) ErrorStop("NULL pointer in SetConcentrations");
		memcpy(c.data(), t, (size_t) (this->nxyz * ncomps * sizeof(double)));
	}
#ifdef USE_MPI
	MPI_Bcast(c.data(), this->nxyz * (int) ncomps, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
	for (int n = 0; n < nthreads; n++)
	{
		this->Concentrations2Solutions(n, c);
	}
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::SetDatabaseFileName(const char * db, long l)
/* ---------------------------------------------------------------------- */
{
	if (this->mpi_myself == 0)
	{	
		this->database_file_name = Char2TrimString(db, l);
	}
#ifdef USE_MPI
	int l1 = 0;
	if (mpi_myself == 0)
	{
		l1 = (int) this->database_file_name.size();
	}
	MPI_Bcast(&l1, 1, MPI_INT, 0, MPI_COMM_WORLD);
	this->database_file_name.resize(l1);
	MPI_Bcast((void *) this->database_file_name.c_str(), l1, MPI_CHARACTER, 0, MPI_COMM_WORLD);
#endif
	if (this->database_file_name.size() > 0)
	{
		return IRM_OK;
	}
	return IRM_INVALIDARG;
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::SetDensity(double *t)
/* ---------------------------------------------------------------------- */
{
	if (this->density.size() < this->nxyz)
	{
		this->density.resize((size_t) (this->nxyz), 0.0);
	}
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in Set_density", 1);
		memcpy(this->density.data(), t, (size_t) (this->nxyz * sizeof(double)));
	}
#ifdef USE_MPI
	MPI_Bcast(this->density.data(), this->nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::SetEndCells(void)
/* ---------------------------------------------------------------------- */
{
#ifdef USE_MPI
	int ntasks = this->mpi_tasks;
#else
	int ntasks = this->nthreads;
#endif
	int n = this->count_chemistry / ntasks;
	int extra = this->count_chemistry - n*ntasks;
	std::vector<int> cells;
	for (int i = 0; i < extra; i++)
	{
		cells.push_back(n+1);
	}
	for (int i = extra; i < ntasks; i++)
	{
		cells.push_back(n);
	}
	int cell0 = 0;
	start_cell.clear();
	end_cell.clear();
	for (int i = 0; i < ntasks; i++)
	{
		this->start_cell.push_back(cell0);
		this->end_cell.push_back(cell0 + cells[i] - 1);
		cell0 = cell0 + cells[i];
	}
}

/* ---------------------------------------------------------------------- */
IRM_RESULT
Reaction_module::SetFilePrefix(std::string &prefix)
/* ---------------------------------------------------------------------- */
{
	this->file_prefix.clear();
	if (mpi_myself == 0)
	{
		this->file_prefix = trim(prefix);
	}
#ifdef USE_MPI
	int l = 0;
	if (mpi_myself == 0)
	{
		l = (int) prefix.size();
	}
	MPI_Bcast(&l, 1, MPI_INT, 0, MPI_COMM_WORLD);
	this->file_prefix.resize(l);
	MPI_Bcast((void *) this->file_prefix.c_str(), l, MPI_CHARACTER, 0, MPI_COMM_WORLD);
#endif
	return IRM_OK;
}

/* ---------------------------------------------------------------------- */
void 
Reaction_module::SetPartitionUZSolids(int * t)
/* ---------------------------------------------------------------------- */
{
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in SetPartitionUZSolids", 1);
		this->partition_uz_solids = (*t != 0);
	}
#ifdef USE_MPI
	MPI_Bcast(&this->partition_uz_solids, 1, MPI_LOGICAL, 0, MPI_COMM_WORLD);
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::SetPoreVolume(double *t)
/* ---------------------------------------------------------------------- */
{
	if (this->pore_volume.size() < this->nxyz)
	{
		this->pore_volume.resize(this->nxyz);
	}
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in Set_pv", 1);
		memcpy(this->pore_volume.data(), t, (size_t) (this->nxyz * sizeof(double)));
	}
#ifdef USE_MPI
	MPI_Bcast(this->pore_volume.data(), this->nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::SetPoreVolumeZero(double *t)
/* ---------------------------------------------------------------------- */
{
	if (this->pore_volume_zero.size() < this->nxyz)
	{
		this->pore_volume_zero.resize(this->nxyz);
	}
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in Set_pv0", 1);
		memcpy(this->pore_volume_zero.data(), t, (size_t) (this->nxyz * sizeof(double)));
	}
#ifdef USE_MPI
	MPI_Bcast(pore_volume_zero.data(), this->nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::SetPressure(double *t)
/* ---------------------------------------------------------------------- */
{
	if (this->pressure.size() < this->nxyz)
	{
		this->pressure.resize(this->nxyz);
	}
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in Set_pressure", 1);
		memcpy(this->pressure.data(), t, (size_t) (this->nxyz * sizeof(double)));
	}
#ifdef USE_MPI
	MPI_Bcast(this->pressure.data(), this->nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}
/* ---------------------------------------------------------------------- */
void 
Reaction_module::SetPrintChemistryOn(int *t)
/* ---------------------------------------------------------------------- */
{
	if (mpi_myself == 0 && t != NULL)
	{
		this->print_chemistry_on = (*t != 0);
	}
#ifdef USE_MPI
	MPI_Bcast(&this->print_chemistry_on, 1, MPI_LOGICAL, 0, MPI_COMM_WORLD);
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::SetPrintChemistryMask(int * t)
/* ---------------------------------------------------------------------- */
{
	if (this->print_chem_mask.size() < this->nxyz)
	{
		this->print_chem_mask.resize(this->nxyz);
	}
	if (this->mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in Set_print_chem_mask", 1);
		memcpy(this->print_chem_mask.data(), t, (size_t) (this->nxyz * sizeof(int)));
	}
#ifdef USE_MPI	
	MPI_Bcast(this->print_chem_mask.data(), this->nxyz, MPI_INT, 0, MPI_COMM_WORLD);
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::SetRebalanceFraction(double *t)
/* ---------------------------------------------------------------------- */
{
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in SetRebalanceFraction", 1);
		this->rebalance_fraction = *t;
	}
#ifdef USE_MPI
	MPI_Bcast(&(this->rebalance_fraction), 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::SetRebalanceMethod(int *t)
/* ---------------------------------------------------------------------- */
{
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in SetRebalanceMethod", 1);
		this->rebalance_method = (*t != 0);
	}
#ifdef USE_MPI
	MPI_Bcast(&(this->rebalance_method), 1, MPI_LOGICAL, 0, MPI_COMM_WORLD);
#endif
}
/* ---------------------------------------------------------------------- */
void
Reaction_module::SetSaturation(double *t)
/* ---------------------------------------------------------------------- */
{
	if (this->saturation.size() < this->nxyz)
	{
		this->saturation.resize(this->nxyz);
	}
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in Set_saturation", 1);
		memcpy(this->saturation.data(), t, (size_t) (this->nxyz * sizeof(double)));
	}
#ifdef USE_MPI
	MPI_Bcast(this->saturation.data(), this->nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::SetSelectedOutputOn(int *t)
/* ---------------------------------------------------------------------- */
{
	if (mpi_myself == 0 && t != NULL)
	{
		this->selected_output_on = *t != 0;
	}
#ifdef USE_MPI
	MPI_Bcast(&this->selected_output_on, 1, MPI_LOGICAL, 0, MPI_COMM_WORLD);
#endif
}
/* ---------------------------------------------------------------------- */
void 
Reaction_module::SetStopMessage(bool t)
/* ---------------------------------------------------------------------- */
{
	if (mpi_myself == 0)
	{
		this->stop_message = t;
	}
#ifdef USE_MPI
	MPI_Bcast(&this->stop_message, 1, MPI_LOGICAL, 0, MPI_COMM_WORLD);
#endif
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::SetTemperature(double *t)
/* ---------------------------------------------------------------------- */
{
	if (this->tempc.size() < this->nxyz)
	{
		this->tempc.resize(this->nxyz);
	}
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in Set_tempc", 1);
		memcpy(this->tempc.data(), t, (size_t) (this->nxyz * sizeof(double)));
	}
#ifdef USE_MPI
	MPI_Bcast(this->tempc.data(), this->nxyz, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::SetTime(double *t)
/* ---------------------------------------------------------------------- */
{
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in Set_time", 1);
		this->time = *t;
	}
#ifdef USE_MPI
	MPI_Bcast(&this->time, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::SetTimeConversion(double *t)
/* ---------------------------------------------------------------------- */
{
	if (mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in SetTimeConversion", 1);
		this->time_conversion = *t;
	}
#ifdef USE_MPI
	MPI_Bcast(&this->time_conversion, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::SetTimeStep(double *t)
/* ---------------------------------------------------------------------- */
{
	if (this->mpi_myself == 0)
	{
		if (t == NULL) error_msg("NULL pointer in Set_time_step", 1);
		this->time_step = *t;
	}
#ifdef USE_MPI
	MPI_Bcast(&this->time_step, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif
}

/* ---------------------------------------------------------------------- */
void
Reaction_module::SetUnits(int *sol, int *pp, int *ex, int *surf, int *gas, int *ss, int *kin)
/* ---------------------------------------------------------------------- */
{
	int local_sol, local_pp, local_ex, local_surf, local_gas, local_ss, local_kin;
	if (mpi_myself == 0)
	{
		local_sol  = (sol  != NULL) ? *sol  : -1;
		local_pp   = (pp   != NULL) ? *pp   : -1;
		local_ex   = (ex   != NULL) ? *ex   : -1;
		local_surf = (surf != NULL) ? *surf : -1;
		local_gas  = (gas  != NULL) ? *gas  : -1;
		local_ss   = (ss   != NULL) ? *ss   : -1;
		local_kin  = (kin  != NULL) ? *kin  : -1;
	}
#ifdef USE_MPI
	MPI_Bcast(&local_sol,  1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(&local_pp,   1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(&local_ex,   1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(&local_surf, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(&local_gas,  1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(&local_ss,   1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(&local_kin,  1, MPI_INT, 0, MPI_COMM_WORLD);
#endif

	if (local_sol >= 0)
	{
		SetUnitsSolution(local_sol);
	}
	if (local_pp >= 0)
	{
		SetUnitsPPassemblage(local_pp);
	}
	if (local_ex >= 0)
	{
		SetUnitsExchange(local_ex);
	}
	if (local_surf >= 0)
	{
		SetUnitsSurface(local_surf);
	}	
	if (local_gas >= 0)
	{
		SetUnitsGasPhase(local_gas);
	}
	if (local_ss >= 0)
	{
		SetUnitsSSassemblage(local_ss);
	}
	if (local_kin >= 0)
	{
		SetUnitsKinetics(local_kin);
	}
}
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
void
Reaction_module::Write_bc_raw(int *solution_list, int * bc_solution_count, 
			int * solution_number, const std::string &fn)
/* ---------------------------------------------------------------------- */
{
	// solution_list is Fortran nxyz number
	MPI_Bcast(solution_number, 1, MPI_INT, 0, MPI_COMM_WORLD);
	if (*solution_number == 0) return;
	MPI_Bcast(bc_solution_count, 1, MPI_INT, 0, MPI_COMM_WORLD);


	// Broadcast solution list
	std::vector<int> my_solution_list;
	if (mpi_myself == 0)
	{
		MPI_Bcast(solution_list, *bc_solution_count, MPI_INT, 0, MPI_COMM_WORLD);
	}
	else
	{
		my_solution_list.resize((size_t) bc_solution_count);
		MPI_Bcast(my_solution_list.data(), *bc_solution_count, MPI_INT, 0, MPI_COMM_WORLD);
	}

	std::ofstream ofs;
	// Open file on root
	if (this->mpi_myself == 0)
	{
		ofs.open(fn.c_str(), std::ios_base::app);
		if (!ofs.is_open())
		{
			std::ostringstream e_msg;
			e_msg << "Could not open file. " << fn;
			WriteError(e_msg.str().c_str());
			ErrorStop();
		}
	}

	// dump solutions to oss
	std::ostringstream oss;
	for (int i = 0; i < *bc_solution_count; i++)
	{
		int raw_number = *solution_number + i;
		int n_fort = solution_list[i];
		int n_chem = this->forward[n_fort - 1];
		if (n_chem >= this->start_cell[this->mpi_myself] || 
			n_chem <= this->end_cell[this->mpi_myself])
		{
			oss << "# Fortran cell " << n_fort << ". Time " << (this->time) * (this->time_conversion) << "\n";
			this->workers[0]->Get_solution(n_chem)->dump_raw(oss, 0, &raw_number);
		}
	}

	// Write root solutions
	if (this->mpi_myself == 0 && oss.str().size() > 0)
	{
		ofs << oss.str();
	}

	// Retrieve from nonroot processes
	std::vector<char> char_buffer;
	for (int i = 1; i < this->mpi_tasks; i++)
	{
		int buffer_length = 0;
		MPI_Status mpi_status;

		// Send dump string to root
		if (mpi_myself == i)
		{
			buffer_length = (int) oss.str().size();
			MPI_Send(&buffer_length, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
			if (buffer_length > 0)
			{
				MPI_Send((void *) oss.str().c_str(), buffer_length, MPI_CHAR, 0, 0,
					MPI_COMM_WORLD);
			}
		}
		// Write dump string to file
		else if (mpi_myself == 0)
		{
			MPI_Recv(&buffer_length, 1, MPI_INT, i, 0, MPI_COMM_WORLD,
				&mpi_status);			
			if (buffer_length > 0)
			{
				char_buffer.resize(buffer_length + 1);
				MPI_Recv(char_buffer.data(), buffer_length, MPI_CHAR, i, 0,
					MPI_COMM_WORLD, &mpi_status);
				char_buffer[buffer_length] = '\0';
				ofs << char_buffer.data(); 
			}
		}
	}

	// Final write
	if (this->mpi_myself == 0)
	{
		ofs << "# Done with zone for time step." << std::endl;
		ofs.close();
	}

	return;
}
#else
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
		WriteError(e_msg.str().c_str());
		ErrorStop();
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
				ofs << "# Fortran cell " << n_fort << ". Time " << (this->time) * (this->time_conversion) << "\n";
				cxxSolution *soln_ptr=  phast_iphreeqc_worker->Get_solution(n_chem);
				soln_ptr->dump_raw(ofs, 0, &raw_number);
				raw_number++;
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
#endif
/* ---------------------------------------------------------------------- */
void
Reaction_module:: WriteError(const char * item)
/* ---------------------------------------------------------------------- */
{
	Reaction_module::phast_io.error_msg(item);
}
/* ---------------------------------------------------------------------- */
void
Reaction_module:: WriteOutput(const char * item)
/* ---------------------------------------------------------------------- */
{
	Reaction_module::phast_io.output_msg(item);
}

