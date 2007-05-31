#include <fstream>
#include <iostream>     // std::cout std::cerr
#include <ctime>
#include "StorageBin.h"
#include "phreeqcpp/Solution.h"
#include "phreeqc/output.h"
#include "hst.h"
#include "phreeqc/phqalloc.h"
#include "phreeqc/phrqproto.h"
#include "phastproto.h"
/*
 * cxxhstsubs.cxx
 */

extern cxxStorageBin szBin;
extern cxxStorageBin phreeqcBin;

/* ---------------------------------------------------------------------- */
void buffer_to_cxxsolution(int n)
/* ---------------------------------------------------------------------- */
{
	int i, j;
	LDBLE old_moles, old_la;
	LDBLE t;
	cxxSolution *cxxsoln_ptr;
	/* 
	 *  add water to hydrogen and oxygen
	 */
	cxxsoln_ptr = szBin.getSolution(n);
	if (cxxsoln_ptr == NULL) {
		cxxSolution cxxsoln;
		szBin.setSolution(n, &cxxsoln);
		cxxsoln_ptr = szBin.getSolution(n);
		cxxsoln_ptr->set_n_user(n);
		cxxsoln_ptr->set_n_user_end(n);
	}
	cxxsoln_ptr->set_total_h( buffer[0].moles + 2  / gfw_water);
	cxxsoln_ptr->set_total_o( buffer[1].moles + 1 / gfw_water);

/* 
 *  Put totals in solution structure
 */
	for (i = 2; i < count_total; i++) {
		if (buffer[i].moles <= 1e-14) {
			//solution_ptr->totals[i-2].moles = 0;
			cxxsoln_ptr->set_total(buffer[i].name, 0);
		} else {
			old_moles = cxxsoln_ptr->get_total(buffer[i].name);
			//if (solution_ptr->totals[i-2].moles <= 0) {
			if (old_moles <= 0) {
				t = log10(buffer[i].moles) - 2.0;
				for (j = buffer[i].first_master; j <= buffer[i].last_master; j++) {
					//solution_ptr->master_activity[j].la = t;
					cxxsoln_ptr->set_master_activity(activity_list[j].name, t);
				}
			} else {
				//t = log10(buffer[i].moles / solution_ptr->totals[i-2].moles);
				t = log10(buffer[i].moles / old_moles);
				for (j = buffer[i].first_master; j <= buffer[i].last_master; j++) {
					//solution_ptr->master_activity[j].la += t;
					old_la = cxxsoln_ptr->get_master_activity(activity_list[j].name);
					cxxsoln_ptr->set_master_activity(activity_list[j].name, old_la + t);
				}
			}
			//solution_ptr->totals[i-2].moles = buffer[i].moles;
			cxxsoln_ptr->set_total(buffer[i].name, buffer[i].moles);
		}
	}
/*
 *   Switch in transport of charge
 */
	if (transport_charge == TRUE) {
		//solution_ptr->cb = buffer[i].moles;
		cxxsoln_ptr->set_cb(buffer[i].moles);
	}
	return;
}
/* ---------------------------------------------------------------------- */
void cxxsolution_to_buffer(cxxSolution *cxxsoln_ptr)
/* ---------------------------------------------------------------------- */
{
	// Assumes all solutions are defined with totals, not valence states
	// Count_all_components puts solutions in standard form
        // before they are transferred to cxx classes

	int i;
	cxxNameDouble::iterator it;
	LDBLE moles_water;

	/* gfw_water = 0.018 */
	//moles_water = solution_ptr->get_mass_water / gfw_water;
	moles_water = 1/gfw_water;

	buffer[0].moles = cxxsoln_ptr->get_total_h() - 2 * moles_water;
	buffer[1].moles = cxxsoln_ptr->get_total_o() - moles_water;
	for (i = 2; i < count_total; i++) {
		buffer[i].moles = cxxsoln_ptr->get_total(buffer[i].name);
	}	
/*
 *   Switch in transport of charge
 */
	if (transport_charge == TRUE) {
		buffer[i].moles = cxxsoln_ptr->get_cb();
	}
	return;
}
/* ---------------------------------------------------------------------- */
void unpackcxx_from_hst(double *fraction, int *dim)
/* ---------------------------------------------------------------------- */
{
	int i, j;
	for (i = 0; i < ixyz; i++) {
		j = forward[i];
		if (j < 0) continue;
		hst_to_buffer(&fraction[i], *dim);
		buffer_to_moles();
		buffer_to_cxxsolution(j);
	}
	return;
}
/* ---------------------------------------------------------------------- */
void system_cxxInitialize(int i, int n_user_new, int *initial_conditions1, int *initial_conditions2, double *fraction1)
/* ---------------------------------------------------------------------- */
{
	int n_old1, n_old2;
	double f1;

	/*
	 *   Copy solution
	 */
	n_old1 = initial_conditions1[7*i];
	n_old2 = initial_conditions2[7*i];
	f1 = fraction1[7*i];
	if (n_old1 >= 0) {
		cxxMix mx;
		mx.add(n_old1, f1);
		if (n_old2 >= 0) mx.add(n_old2, 1 - f1);
		cxxSolution cxxsoln(phreeqcBin.getSolutions(), mx, n_user_new);
		szBin.setSolution(n_user_new, &cxxsoln);
	}
		
	/*
	 *   Copy pp_assemblage
	 */
	n_old1 = initial_conditions1[ 7*i + 1 ];
	n_old2 = initial_conditions2[ 7*i + 1 ];
	f1 = fraction1[7*i + 1];
	if (n_old1 >= 0) 
	{
		cxxMix mx;
		mx.add(n_old1, f1);
		if (n_old2 >= 0) mx.add(n_old2, 1 - f1);
		cxxPPassemblage cxxentity(phreeqcBin.getPPassemblages(), mx, n_user_new);
		szBin.setPPassemblage(n_user_new, &cxxentity);
	}
	/*
	 *   Copy exchange assemblage
	 */

	n_old1 = initial_conditions1[ 7*i + 2 ];
	n_old2 = initial_conditions2[ 7*i + 2 ];
	f1 = fraction1[7*i + 2];
	if (n_old1 >= 0) {
		cxxMix mx;
		mx.add(n_old1, f1);
		if (n_old2 >= 0) mx.add(n_old2, 1 - f1);
		cxxExchange cxxexch(phreeqcBin.getExchangers(), mx, n_user_new);
		szBin.setExchange(n_user_new, &cxxexch);
	}
	/*
	 *   Copy surface assemblage
	 */
	n_old1 = initial_conditions1[ 7*i + 3 ];
	n_old2 = initial_conditions2[ 7*i + 3 ];
	f1 = fraction1[7*i + 3];
	if (n_old1 >= 0) {
		cxxMix mx;
		mx.add(n_old1, f1);
		if (n_old2 >= 0) mx.add(n_old2, 1 - f1);
		cxxSurface cxxentity(phreeqcBin.getSurfaces(), mx, n_user_new);
		szBin.setSurface(n_user_new, &cxxentity);	}
	/*
	 *   Copy gas phase
	 */
	n_old1 = initial_conditions1[ 7*i + 4 ];
	n_old2 = initial_conditions2[ 7*i + 4 ];
	f1 = fraction1[7*i + 4];
	if (n_old1 >= 0) 
	{
	  cxxMix mx;
	  mx.add(n_old1, f1);
	  if (n_old2 >= 0) mx.add(n_old2, 1 - f1);
	  cxxGasPhase cxxentity(phreeqcBin.getGasPhases(), mx, n_user_new);
	  szBin.setGasPhase(n_user_new, &cxxentity);
	}
	/*
	 *   Copy solid solution
	 */
	n_old1 = initial_conditions1[ 7*i + 5 ];
	n_old2 = initial_conditions2[ 7*i + 5 ];
	f1 = fraction1[7*i + 5];
	if (n_old1 >= 0) {
	  cxxMix mx;
	  mx.add(n_old1, f1);
	  if (n_old2 >= 0) mx.add(n_old2, 1 - f1);
	  cxxSSassemblage cxxentity(phreeqcBin.getSSassemblages(), mx, n_user_new);
	  szBin.setSSassemblage(n_user_new, &cxxentity);
	}
	/*
	 *   Copy kinetics
	 */
	n_old1 = initial_conditions1[ 7*i + 6 ];
	n_old2 = initial_conditions2[ 7*i + 6 ];
	f1 = fraction1[7*i + 6];
	if (n_old1 >= 0) {
	  cxxMix mx;
	  mx.add(n_old1, f1);
	  if (n_old2 >= 0) mx.add(n_old2, 1 - f1);
	  cxxKinetics cxxentity(phreeqcBin.getKinetics(), mx, n_user_new);
	  szBin.setKinetics(n_user_new, &cxxentity);
	}

	return;
}
/* ---------------------------------------------------------------------- */
int write_restart(double time_hst)
/* ---------------------------------------------------------------------- */
{
	std::string temp_name("temp_restart_file");
	string_trim(file_prefix);
	std::string name(file_prefix);
	name.append(".restart");
	std::string backup_name = name;
	backup_name.append(".backup");
	// open file 
	std::ofstream ofs(temp_name.c_str());
	// write header
	ofs << "#PHAST restart file" << std::endl;
	time_t now = time(NULL);
	ofs << "#Prefix: " << file_prefix << std::endl;
	ofs << "#Date: " << ctime(&now);
	ofs << "#Current model time: " << time_hst << std::endl;
	ofs << "#nx, ny, nz: " << ix << ", " << iy << ", " << iz << std::endl;
	// write data
	szBin.dump_raw(ofs, 0);
	ofs.close();
	// rename files
	file_rename(temp_name.c_str(), name.c_str(), backup_name.c_str());
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_restart_init(std::ofstream& ofs, double time_hst)
/* ---------------------------------------------------------------------- */
{
	// write header
	ofs << "#PHAST restart file" << std::endl;
	ofs << "#Prefix: " << file_prefix << std::endl;
	time_t now = time(NULL);
	ofs << "#Date: " << ctime(&now);
	ofs << "#Current model time: " << time_hst << std::endl;
	ofs << "#nx, ny, nz: " << ix << ", " << iy << ", " << iz << std::endl;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int scale_cxxsystem(int iphrq, LDBLE frac)
/* ---------------------------------------------------------------------- */
{
	int n_user;

	/* 
	 * repartition solids for partially saturated cells
	 */
	
	//if (equal(old_frac[ihst], new_frac, 1e-8) == TRUE)  return(OK);

	n_user = iphrq;
	cxxMix cxxmix;
	cxxmix.add(n_user, frac);
	/*
	 *   Scale compositions
	 */
	if (szBin.getExchange(n_user) != NULL)
	{
		cxxExchange cxxexch(szBin.getExchangers(), cxxmix, n_user);
		szBin.setExchange(n_user, &cxxexch);
	}
	if (szBin.getPPassemblage(n_user) != NULL)
	{
	  	cxxPPassemblage cxxentity(szBin.getPPassemblages(), cxxmix, n_user);
		szBin.setPPassemblage(n_user, &cxxentity);
	}
	if (szBin.getGasPhase(n_user) != NULL)
	{
	  	cxxGasPhase cxxentity(szBin.getGasPhases(), cxxmix, n_user);
		szBin.setGasPhase(n_user, &cxxentity);
	}
	if (szBin.getSSassemblage(n_user) != NULL)
	{
	  cxxSSassemblage cxxentity(szBin.getSSassemblages(), cxxmix, n_user);
	  szBin.setSSassemblage(n_user, &cxxentity);
	}
	if (szBin.getKinetics(n_user) != NULL)
	{
	  cxxKinetics cxxentity(szBin.getKinetics(), cxxmix, n_user);
	  szBin.setKinetics(n_user, &cxxentity);
	}
	if (szBin.getSurface(n_user) != NULL)
	{
	  cxxSurface cxxentity(szBin.getSurfaces(), cxxmix, n_user);
	  szBin.setSurface(n_user, &cxxentity);
	}
	return(OK);
}
