#include <fstream>
#include <iostream>				// std::cout std::cerr
#include <ctime>
#define EXTERNAL extern
#include "global.h"
#include "hst.h"
#include "StorageBin.h"
#include "cxxMix.h"
#include "Solution.h"
#include "PPassemblage.h"
#include "Exchange.h"
#include "Surface.h"
#include "GasPhase.h"
#include "SSassemblage.h"
#include "cxxKinetics.h"
#include "phreeqc/output.h"
#include "phreeqc/phqalloc.h"
#include "phreeqc/phrqproto.h"
#include "phastproto.h"
#include "gzstream.h"
#include "Pointers_to_fortran.h"
/*
 * cxxhstsubs.cxx
 */

extern cxxStorageBin uzBin;
extern cxxStorageBin szBin;
extern cxxStorageBin phreeqcBin;

#define CONSTANT_KG_WATER
#ifdef CONSTANT_KG_WATER
/* ---------------------------------------------------------------------- */
void
buffer_to_cxxsolution(int n)
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
	if (cxxsoln_ptr == NULL)
	{
		cxxSolution cxxsoln;
		szBin.setSolution(n, &cxxsoln);
		cxxsoln_ptr = szBin.getSolution(n);
		cxxsoln_ptr->set_n_user(n);
		cxxsoln_ptr->set_n_user_end(n);
	}
	cxxsoln_ptr->set_total_h(buffer[0].moles + 2 / gfw_water);
	cxxsoln_ptr->set_total_o(buffer[1].moles + 1 / gfw_water);

/* 
 *  Put totals in solution structure
 */
	for (i = 2; i < count_total; i++)
	{
		if (buffer[i].moles <= 1e-14)
		{
			//solution_ptr->totals[i-2].moles = 0;
			cxxsoln_ptr->set_total(buffer[i].name, 0);
		}
		else
		{
			old_moles = cxxsoln_ptr->get_total(buffer[i].name);
			//if (solution_ptr->totals[i-2].moles <= 0) {
			if (old_moles <= 0)
			{
				t = log10(buffer[i].moles) - 2.0;
				for (j = buffer[i].first_master; j <= buffer[i].last_master;
					 j++)
				{
					//solution_ptr->master_activity[j].la = t;
					cxxsoln_ptr->set_master_activity(activity_list[j].name,
													 t);
				}
			}
			else
			{
				//t = log10(buffer[i].moles / solution_ptr->totals[i-2].moles);
				t = log10(buffer[i].moles / old_moles);
				for (j = buffer[i].first_master; j <= buffer[i].last_master;
					 j++)
				{
					//solution_ptr->master_activity[j].la += t;
					old_la =
						cxxsoln_ptr->get_master_activity(activity_list[j].
														 name);
					cxxsoln_ptr->set_master_activity(activity_list[j].name,
													 old_la + t);
				}
			}
			//solution_ptr->totals[i-2].moles = buffer[i].moles;
			cxxsoln_ptr->set_total(buffer[i].name, buffer[i].moles);
		}
	}
/*
 *   Switch in transport of charge
 */
	if (transport_charge == TRUE)
	{
		//solution_ptr->cb = buffer[i].moles;
		cxxsoln_ptr->set_cb(buffer[i].moles);
	}
	return;
}

/* ---------------------------------------------------------------------- */
void
cxxsolution_to_buffer(cxxSolution * cxxsoln_ptr)
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
	moles_water = 1 / gfw_water;

	buffer[0].moles = cxxsoln_ptr->get_total_h() - 2 * moles_water;
	buffer[1].moles = cxxsoln_ptr->get_total_o() - moles_water;
	for (i = 2; i < count_total; i++)
	{
		buffer[i].moles = cxxsoln_ptr->get_total_element(buffer[i].name);
	}
/*
 *   Switch in transport of charge
 */
	if (transport_charge == TRUE)
	{
		buffer[i].moles = cxxsoln_ptr->get_cb();
	}
	return;
}
#else
/* ---------------------------------------------------------------------- */
void
buffer_to_cxxsolution(int n)
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
	if (cxxsoln_ptr == NULL)
	{
		cxxSolution cxxsoln;
		szBin.setSolution(n, &cxxsoln);
		cxxsoln_ptr = szBin.getSolution(n);
		cxxsoln_ptr->set_n_user(n);
		cxxsoln_ptr->set_n_user_end(n);
	}
	cxxsoln_ptr->set_total_h(buffer[0].moles);
	cxxsoln_ptr->set_total_o(buffer[1].moles);

/* 
 *  Put totals in solution structure
 */
	for (i = 2; i < count_total; i++)
	{
		if (buffer[i].moles <= 1e-14)
		{
			cxxsoln_ptr->set_total(buffer[i].name, 0);
		}
		else
		{
			old_moles = cxxsoln_ptr->get_total(buffer[i].name);
			if (old_moles <= 0)
			{
				t = log10(buffer[i].moles) - 2.0;
				for (j = buffer[i].first_master; j <= buffer[i].last_master;
					 j++)
				{
					cxxsoln_ptr->set_master_activity(activity_list[j].name,
													 t);
				}
			}
			else
			{
				t = log10(buffer[i].moles / old_moles);
				for (j = buffer[i].first_master; j <= buffer[i].last_master;
					 j++)
				{
					old_la =
						cxxsoln_ptr->get_master_activity(activity_list[j].
														 name);
					cxxsoln_ptr->set_master_activity(activity_list[j].name,
													 old_la + t);
				}
			}
			cxxsoln_ptr->set_total(buffer[i].name, buffer[i].moles);
		}
	}
/*
 *   Switch in transport of charge
 */
	if (transport_charge == TRUE)
	{
		cxxsoln_ptr->set_cb(buffer[i].moles);
	}
	return;
}

/* ---------------------------------------------------------------------- */
void
cxxsolution_to_buffer(cxxSolution * cxxsoln_ptr)
/* ---------------------------------------------------------------------- */
{
	// Assumes all solutions are defined with totals, not valence states
	// Count_all_components puts solutions in standard form
	// before they are transferred to cxx classes

	int i;
	cxxNameDouble::iterator it;

	buffer[0].moles = cxxsoln_ptr->get_total_h();
	buffer[1].moles = cxxsoln_ptr->get_total_o();
	for (i = 2; i < count_total; i++)
	{
		buffer[i].moles = cxxsoln_ptr->get_total_element(buffer[i].name);
	}
/*
 *   Switch in transport of charge
 */
	if (transport_charge == TRUE)
	{
		buffer[i].moles = cxxsoln_ptr->get_cb();
	}
	return;
}
#endif
/* ---------------------------------------------------------------------- */
void
unpackcxx_from_hst(double *fraction, int *dim)
/* ---------------------------------------------------------------------- */
{
	int i, j;
	for (i = 0; i < ixyz; i++)
	{
		j = forward[i];
		if (j < 0)
			continue;
		hst_to_buffer(&fraction[i], *dim);
		buffer_to_moles();
		buffer_to_cxxsolution(j);
	}
	return;
}

/* ---------------------------------------------------------------------- */
void
system_cxxInitialize(int i, int n_user_new, int *initial_conditions1,
					 int *initial_conditions2, double *fraction1)
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
		cxxSolution cxxsoln(phreeqcBin.getSolutions(), mx, n_user_new);
		szBin.setSolution(n_user_new, &cxxsoln);
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
		cxxPPassemblage cxxentity(phreeqcBin.getPPassemblages(), mx,
								  n_user_new);
		szBin.setPPassemblage(n_user_new, &cxxentity);
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
		cxxExchange cxxexch(phreeqcBin.getExchangers(), mx, n_user_new);
		szBin.setExchange(n_user_new, &cxxexch);
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
		cxxSurface cxxentity(phreeqcBin.getSurfaces(), mx, n_user_new);
		szBin.setSurface(n_user_new, &cxxentity);
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
		cxxGasPhase cxxentity(phreeqcBin.getGasPhases(), mx, n_user_new);
		szBin.setGasPhase(n_user_new, &cxxentity);
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
		cxxSSassemblage cxxentity(phreeqcBin.getSSassemblages(), mx,
								  n_user_new);
		szBin.setSSassemblage(n_user_new, &cxxentity);
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
		cxxKinetics cxxentity(phreeqcBin.getKinetics(), mx, n_user_new);
		szBin.setKinetics(n_user_new, &cxxentity);
	}

	return;
}

/* ---------------------------------------------------------------------- */
int
write_restart(double time_hst)
/* ---------------------------------------------------------------------- */
{

	std::string temp_name("temp_restart_file.gz");
	string_trim(file_prefix);
	std::string name(file_prefix);
	name.append(".restart.gz");
	std::string backup_name(file_prefix);
	backup_name.append(".restart.backup.gz");
	// open file 
	//std::ofstream ofs(temp_name.c_str());
	ogzstream ofs_restart;
	ofs_restart.open(temp_name.c_str());
	if (!ofs_restart.good())
	{
		sprintf(error_string, "File could not be opened: %s.",
				temp_name.c_str());
		error_msg(error_string, STOP);
	}

	// write header
	ofs_restart << "#PHAST restart file" << std::endl;
	time_t now = time(NULL);
	ofs_restart << "#Prefix: " << file_prefix << std::endl;
	ofs_restart << "#Date: " << ctime(&now);
	ofs_restart << "#Current model time: " << time_hst << std::endl;
	ofs_restart << "#nx, ny, nz: " << ix << ", " << iy << ", " << iz << std::
		endl;

	// write index
	int i, j;
	ofs_restart << count_chem << std::endl;
	for (j = 0; j < count_chem; j++)	/* j is count_chem number */
	{
		i = back[j].list[0];	/* i is ixyz number */
		ofs_restart << x_node_c[i] << "  " << y_node_c[i] << "  " <<
			z_node_c[i] << "  " << j << "  ";
		// solution 
		ofs_restart << initial_conditions1_c[7 * i] << "  ";
		// pp_assemblage
		ofs_restart << initial_conditions1_c[7 * i + 1] << "  ";
		// exchange
		ofs_restart << initial_conditions1_c[7 * i + 2] << "  ";
		// surface
		ofs_restart << initial_conditions1_c[7 * i + 3] << "  ";
		// gas_phase
		ofs_restart << initial_conditions1_c[7 * i + 4] << "  ";
		// solid solution
		ofs_restart << initial_conditions1_c[7 * i + 5] << "  ";
		// kinetics
		ofs_restart << initial_conditions1_c[7 * i + 6] << std::endl;
	}

	// write data
	szBin.dump_raw(ofs_restart, 0);
	ofs_restart.close();
	// rename files
	file_rename(temp_name.c_str(), name.c_str(), backup_name.c_str());
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
scale_cxxsystem(int iphrq, LDBLE frac)
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
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
partition_uz(int iphrq, int ihst, LDBLE new_frac)
/* ---------------------------------------------------------------------- */
{
	int n_user;
	LDBLE s1, s2, uz1, uz2;

	/* 
	 * repartition solids for partially saturated cells
	 */

	if (equal(old_frac[ihst], new_frac, 1e-8) == TRUE)
		return (OK);

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
	else if (new_frac > old_frac[ihst])
	{
		/* wetting cell */
		uz1 = 0.;
		uz2 = (1.0 - new_frac) / (1.0 - old_frac[ihst]);
		s1 = 1.;
		s2 = 1.0 - uz2;
	}
	else
	{
		/* draining cell */
		s1 = new_frac / old_frac[ihst];
		s2 = 0.0;
		uz1 = 1.0 - s1;
		uz2 = 1.0;
	}
	cxxMix szmix, uzmix;
	szmix.add(0, s1);
	szmix.add(1, s2);
	uzmix.add(0, uz1);
	uzmix.add(1, uz2);
	/*
	 *   Calculate new compositions
	 */

//Exchange
	if (szBin.getExchange(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.setExchange(0, szBin.getExchange(n_user));
		tempBin.setExchange(1, uzBin.getExchange(n_user));
		cxxExchange newsz(tempBin.getExchangers(), szmix, n_user);
		cxxExchange newuz(tempBin.getExchangers(), uzmix, n_user);
		szBin.setExchange(n_user, &newsz);
		uzBin.setExchange(n_user, &newuz);
	}
//PPassemblage
	if (szBin.getPPassemblage(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.setPPassemblage(0, szBin.getPPassemblage(n_user));
		tempBin.setPPassemblage(1, uzBin.getPPassemblage(n_user));
		cxxPPassemblage newsz(tempBin.getPPassemblages(), szmix, n_user);
		cxxPPassemblage newuz(tempBin.getPPassemblages(), uzmix, n_user);
		szBin.setPPassemblage(n_user, &newsz);
		uzBin.setPPassemblage(n_user, &newuz);
	}
//Gas_phase
	if (szBin.getGasPhase(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.setGasPhase(0, szBin.getGasPhase(n_user));
		tempBin.setGasPhase(1, uzBin.getGasPhase(n_user));
		cxxGasPhase newsz(tempBin.getGasPhases(), szmix, n_user);
		cxxGasPhase newuz(tempBin.getGasPhases(), uzmix, n_user);
		szBin.setGasPhase(n_user, &newsz);
		uzBin.setGasPhase(n_user, &newuz);
	}
//SSassemblage
	if (szBin.getSSassemblage(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.setSSassemblage(0, szBin.getSSassemblage(n_user));
		tempBin.setSSassemblage(1, uzBin.getSSassemblage(n_user));
		cxxSSassemblage newsz(tempBin.getSSassemblages(), szmix, n_user);
		cxxSSassemblage newuz(tempBin.getSSassemblages(), uzmix, n_user);
		szBin.setSSassemblage(n_user, &newsz);
		uzBin.setSSassemblage(n_user, &newuz);
	}
//Kinetics
	if (szBin.getKinetics(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.setKinetics(0, szBin.getKinetics(n_user));
		tempBin.setKinetics(1, uzBin.getKinetics(n_user));
		cxxKinetics newsz(tempBin.getKinetics(), szmix, n_user);
		cxxKinetics newuz(tempBin.getKinetics(), uzmix, n_user);
		szBin.setKinetics(n_user, &newsz);
		uzBin.setKinetics(n_user, &newuz);
	}
//Surface
	if (szBin.getSurface(n_user) != NULL)
	{
		cxxStorageBin tempBin;
		tempBin.setSurface(0, szBin.getSurface(n_user));
		tempBin.setSurface(1, uzBin.getSurface(n_user));
		cxxSurface newsz(tempBin.getSurfaces(), szmix, n_user);
		cxxSurface newuz(tempBin.getSurfaces(), uzmix, n_user);
		szBin.setSurface(n_user, &newsz);
		uzBin.setSurface(n_user, &newuz);
	}
	/*
	 *   Eliminate uz if new fraction 1.0
	 */
	if (new_frac >= 1.0)
	{
		uzBin.remove(iphrq);
	}

	old_frac[ihst] = new_frac;
	return (OK);
}
