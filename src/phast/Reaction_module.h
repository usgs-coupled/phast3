#if !defined(REACTION_MODULE_H_INCLUDED)
#define REACTION_MODULE_H_INCLUDED
#include "PHRQ_base.h"

class PHRQ_io;
class IPhreeqc;

class Reaction_module: public PHRQ_base
{
public:
	Reaction_module(PHRQ_io * io=NULL);
	int Load_database(std::string database_name);
	int Initial_phreeqc_run(std::string chemistry_name);
	void Pass_data_to_reaction_module(
		int *nx, int *ny, int *nz,
		double *time_hst, 
		double *time_step_hst, 
		double *cnvtmi,
		double *x_hst,	
		double *y_hst, 
		double *z_hst, 
		double *fraction,	
		double *frac, 
		double *pv, 
		double *pv0, 
		double *volume,
		int *printzone_chem, 
		int *printzone_xyz, 
		double *rebalance_fraction_hst);
	void Pass_print_flags_reaction_module(
		 int * prslm,
		 int * print_out,
		 int * print_sel,
		 int * print_hdf,
		 int * print_restart );
	void Distribute_initial_conditions(
		int *initial_conditions1,
		int *initial_conditions2,	
		double *fraction1,
		int *exchange_units,
		int *surface_units,
		int *ssassemblage_units,
		int *ppassemblage_units,
		int *gasphase_units,
		int *kinetics_units);
	void Set_database_file_name(std::string fn) {this->database_file_name = fn;};
	const int Get_mpi_tasks(void) const {return this->mpi_tasks;};
	void Set_mpi_tasks(int t) {this->mpi_tasks = t;};
	const int Get_mpi_myself(void) const {return this->mpi_myself;};
	void Set_mpi_myself(int t) {this->mpi_myself = t;};

	const int Get_nxyz(void) const {return this->nxyz;};
	void Set_nxyz(int t) {this->nxyz = t;};
	const int Get_nx(void) const {return this->nx;};
	void Set_nx(int t) {this->nx = t;};
	const int Get_ny(void) const {return this->ny;};
	void Set_ny(int t) {this->ny = t;};
	const int Get_nz(void) const {return this->nz;};
	void Set_nz(int t) {this->nz = t;};
	const int Get_ncomps(void) const {return this->ncomps;};
	void Set_ncomps(int t) {this->ncomps = t;};
	const double Get_time_hst(void) const {return this->time_hst;};
	void Set_time_hst(double t) {this->time_hst = t;};
	const double Get_time_step_hst(void) const {return this->time_step_hst;};
	void Set_time_step_hst(double t) {this->time_step_hst = t;};
	const double Get_cnvtmi(void) const {return this->cnvtmi;};
	void Set_cnvtmi(double t) {this->cnvtmi = t;};
	const double * Get_x_hst(void) const {return this->x_hst;};
	void Set_x_hst(double * t) {this->x_hst = t;};
	const double * Get_y_hst(void) const {return this->y_hst;};
	void Set_y_hst(double * t) {this->y_hst = t;};
	const double * Get_z_hst(void) const {return this->z_hst;};
	void Set_z_hst(double * t) {this->z_hst = t;};
	double * Get_fraction(void) const {return this->fraction;};
	void Set_fraction(double * t) {this->fraction = t;};
	const double * Get_frac(void) const {return this->frac;};
	void Set_frac(double * t) {this->frac = t;};
	const double * Get_pv(void) const {return this->pv;};
	void Set_pv(double * t) {this->pv = t;};
	const double * Get_pv0(void) const {return this->pv0;};
	void Set_pv0(double * t) {this->pv0 = t;};
	const double * Get_volume(void) const {return this->volume;};
	void Set_volume(double * t) {this->volume = t;};
	const int * Get_printzone_chem(void) const {return this->printzone_chem;};
	void Set_printzone_chem(int * t) {this->printzone_chem = t;};
	const int * Get_printzone_xyz(void) const {return this->printzone_xyz;};
	void Set_printzone_xyz(int * t) {this->printzone_xyz = t;};
	const double Get_rebalance_fraction_hst(void) const {return this->rebalance_fraction_hst;};
	void Set_rebalance_fraction_hst(double t) {this->rebalance_fraction_hst = t;};

	const bool Get_prslm(void) const {return this->prslm;};
	void Set_prslm(bool t) {this->prslm = t;};
	const bool Get_print_out(void) const {return this->print_out;};
	void Set_print_out(bool t) {this->print_out = t;};
	const bool Get_print_sel(void) const {return this->print_sel;};
	void Set_print_sel(bool t) {this->print_sel = t;};
	const bool Get_print_hdf(void) const {return this->print_hdf;};
	void Set_print_hdf(bool t) {this->print_hdf = t;};
	const bool Get_print_restart(void) const {return this->print_restart;};
	void Set_print_restart(bool t) {this->print_restart = t;};

private:
	IPhreeqc * iphreeqc_worker;
	std::string database_file_name;
	int mpi_myself;
	int mpi_tasks;
	int ncomps;

	// Pointers to Fortran
	int nxyz;							// number of nodes 
	int nx, ny, nz;						// number of nodes in each coordinate direction
	double time_hst;					// scalar time from transport 
	double time_step_hst;				// scalar time step from transport
	double cnvtmi;						// scalar conversion factor for time
	double *x_hst;						// array locations of x nodes 
	double *y_hst;						// array of locations of y nodes  
	double *z_hst;						// array of locations of z nodes 
	double *fraction;					// nxyz by ncomps mass fractions nxyz:components
	double *frac;						// nxyz saturation fraction
	double *pv;							// nxyz current pore volumes 
	double *pv0;						// nxyz initial pore volumes
	double *volume;						// nxyz geometric cell volumes 
	int *printzone_chem;				// nxyz print flags for output file
	int *printzone_xyz;					// nxyz print flags for chemistry XYZ file 
	double rebalance_fraction_hst;		// parameter for rebalancing process load for parallel	

	// print flags
	bool prslm;							// solution method print flag 
	bool print_out;						// print flag for output file 
	bool print_sel;						// print flag for selected output
	bool print_hdf;						// print flag for hdf file
	bool print_restart;					// print flag for writing restart file 

};
#endif // !defined(REACTION_MODULE_H_INCLUDED)
