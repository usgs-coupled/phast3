#include "StorageBin.h"
#include "phreeqcpp/Solution.h"
#include "hst.h"
#include "phreeqc/phqalloc.h"
#include "phreeqc/phrqproto.h"
#include "phastproto.h"
/*
 * hstcxxsubs.c
 */

void buffer_to_cxxsolution(int n);
void cxxsolution_to_buffer(cxxSolution *solution_ptr);
void unpackcxx_from_hst(double *fraction, int *dim);

extern cxxStorageBin szBin;

#include <iostream>     // std::cout std::cerr
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
	//std::ostringstream oss;
	//szBin.dump_raw(oss,0);
	//std::cerr << oss.str();

	cxxsoln_ptr = szBin.get_solution(n);
	//std::ostringstream oss;
	//cxxsoln_ptr->dump_raw(oss,0);
	//std::cerr << oss.str();

	cxxsoln_ptr->set_total_h( buffer[0].moles + 2  / gfw_water);
	cxxsoln_ptr->set_total_o( buffer[1].moles + 1 / gfw_water);

/* 
 *  Put totals in solution structure
 */
#ifdef PRINT
	output_msg(OUTPUT_STDERR,"Unpack solution %d.\n", solution_ptr->n_user);
#endif
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
#ifdef PRINT
		output_msg(OUTPUT_STDERR,"\t%s\t%g\n", solution_ptr->totals[i-2].description, solution_ptr->totals[i-2].moles);
#endif
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
	int i;
	cxxNameDouble::iterator it;
	LDBLE moles_water;
	//moles_water = solution_ptr->get_mass_water / gfw_water;
	moles_water = 1/gfw_water;
/* gfw_water = 0.018 */
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
