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
void scale_cxxsolution(int n_solution, double factor);
struct system *cxxsystem_initialize(int i, int n_user_new, int *initial_conditions1, int *initial_conditions2, double *fraction1);

extern cxxStorageBin szBin;
extern cxxStorageBin phreeqcBin;

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

	cxxsoln_ptr = szBin.getSolution(n);
	if (cxxsoln_ptr == NULL) {
		cxxSolution cxxsoln;
		szBin.setSolution(n, &cxxsoln);
		cxxsoln_ptr = szBin.getSolution(n);
		cxxsoln_ptr->set_n_user(n);
		cxxsoln_ptr->set_n_user_end(n);
	}
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
#ifdef SKIP
void cxxsolution_to_buffer(cxxSolution *cxxsoln_ptr)
/* ---------------------------------------------------------------------- */
{
	struct solution *solution_ptr;
	int i;
	cxxNameDouble::iterator it;
	LDBLE moles_water;

	/* gfw_water = 0.018 */
	moles_water = 1/gfw_water;

	buffer[0].moles = cxxsoln_ptr->get_total_h() - 2 * moles_water;
	buffer[1].moles = cxxsoln_ptr->get_total_o() - moles_water;

	/*
	 *  Sum valence states
	 */
	solution_ptr = cxxsoln_ptr->cxxSolution2solution();
	xsolution_zero();
	add_solution(solution_ptr, 1.0, 1.0);
	for (i = 2; i < count_total; i++) {
		buffer[i].moles = buffer[i].master->total;
	}	
	/*
	 *   Switch in transport of charge
	 */
	if (transport_charge == TRUE) {
		buffer[i].moles = cxxsoln_ptr->get_cb();
	}
	solution_free(solution_ptr);
	return;
}
#endif
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
void scale_cxxsolution(int n_solution, double factor)
/* ---------------------------------------------------------------------- */
{
/*
 *   Print entities used in calculation
 */
	//xsolution_zero();
	//add_solution(solution[i], factor, 1.0);
	//for(j = 2; j < count_total; j++) {
	//	buffer[j].master->total_primary = buffer[j].master->total;
	//}
	//xsolution_save_hst(i);
	cxxMix mixmap;
	//std::map<int,double> *comps;
	//comps = mixmap.comps();
	//(*comps)[n_solution] = factor;
	mixmap.add(n_solution, factor);
	cxxSolution *cxxsoln = szBin.mix_cxxSolutions(mixmap);
	szBin.setSolution(n_solution, cxxsoln);
}
/* ---------------------------------------------------------------------- */
struct system *cxxsystem_initialize(int i, int n_user_new, int *initial_conditions1, int *initial_conditions2, double *fraction1)
/* ---------------------------------------------------------------------- */
{
	struct solution *solution_ptr;
	struct exchange *exchange_ptr;
	struct pp_assemblage *pp_assemblage_ptr;
	struct gas_phase *gas_phase_ptr;
	struct s_s_assemblage *s_s_assemblage_ptr;
	struct surface *surface_ptr;
	struct kinetics *kinetics_ptr;
	struct system *system_ptr;
	int n, n_old1, n_old2;
	double f1;

	system_ptr = system_alloc();   
	reinitialize();
	/*
	 *   Get solution
	 */
	n_old1 = initial_conditions1[7*i];
	cxxSolution *entity_ptr1 = phreeqcBin.getSolution(n_old1);
	solution[0] = entity_ptr1->cxxSolution2solution();
	count_solution++;
	n_old2 = initial_conditions2[7*i];
	if (n_old2 >= 0) {
		cxxSolution *entity_ptr2 = phreeqcBin.getSolution(n_old2);
		solution[1] = entity_ptr2->cxxSolution2solution();
		count_solution++;
		solution_sort();
	} 
	f1 = fraction1[7*i];
	if (n_old1 >= 0) {
		mix_solutions(n_old1, n_old2, f1, -1, "reinitial");
		solution_ptr = solution_bsearch(-1, &n, TRUE);
		system_ptr->solution = solution_replicate(solution_ptr, n_user_new);
	}
		
	/*
	 *   Get pp_assemblage
	 */
	n_old1 = initial_conditions1[ 7*i + 1 ];
	if (n_old1 >= 0) {
		cxxPPassemblage *entity_ptr1 = phreeqcBin.getPPassemblage(n_old1);
		struct pp_assemblage *pp_assemblage_ptr1 = entity_ptr1->cxxPPassemblage2pp_assemblage();
		pp_assemblage_ptr_to_user(pp_assemblage_ptr1, n_old1);
		pp_assemblage_free(pp_assemblage_ptr1);
		free_check_null(pp_assemblage_ptr1);
		n_old2 = initial_conditions2[ 7*i + 1 ];
		if (n_old2 >= 0) {
			cxxPPassemblage *entity_ptr2 = phreeqcBin.getPPassemblage(n_old2);
			struct pp_assemblage *pp_assemblage_ptr2 = entity_ptr2->cxxPPassemblage2pp_assemblage();
			pp_assemblage_ptr_to_user(pp_assemblage_ptr2, n_old2);
			pp_assemblage_free(pp_assemblage_ptr2);
			free_check_null(pp_assemblage_ptr2);
		}
		f1 = fraction1[7*i + 1];
		mix_pp_assemblage(n_old1, n_old2, f1, -1);
		pp_assemblage_ptr = pp_assemblage_bsearch(-1, &n);
		system_ptr->pp_assemblage = pp_assemblage_replicate(pp_assemblage_ptr, n_user_new);
	}
	/*
	 *   Copy exchange assemblage
	 */
	n_old1 = initial_conditions1[ 7*i + 2 ];
	if (n_old1 >= 0) {
		cxxExchange *entity_ptr1 = phreeqcBin.getExchange(n_old1);
		struct exchange *exchange_ptr1 = entity_ptr1->cxxExchange2exchange();
		exchange_ptr_to_user(exchange_ptr1, n_old1);
		exchange_free(exchange_ptr1);
		free_check_null(exchange_ptr1);
		n_old2 = initial_conditions2[ 7*i + 2 ];
		if (n_old2 >= 0) {
			cxxExchange *entity_ptr2 = phreeqcBin.getExchange(n_old2);
			struct exchange *exchange_ptr2 = entity_ptr2->cxxExchange2exchange();
			exchange_ptr_to_user(exchange_ptr2, n_old2);
			exchange_free(exchange_ptr2);
			free_check_null(exchange_ptr2);
		}
		f1 = fraction1[7*i + 2];
		mix_exchange(n_old1, n_old2, f1, -1);
		exchange_ptr = exchange_bsearch(-1, &n);
		system_ptr->exchange = exchange_replicate(exchange_ptr, n_user_new);
	}
	/*
	 *   Copy surface assemblage
	 */
	n_old1 = initial_conditions1[ 7*i + 3 ];
	if (n_old1 >= 0) {
		cxxSurface *entity_ptr1 = phreeqcBin.getSurface(n_old1);
		struct surface *surface_ptr1 = entity_ptr1->cxxSurface2surface();
		surface_ptr_to_user(surface_ptr1, n_old1);
		surface_free(surface_ptr1);
		free_check_null(surface_ptr1);
		n_old2 = initial_conditions2[ 7*i + 3 ];
		if (n_old2 >= 0) {
			cxxSurface *entity_ptr2 = phreeqcBin.getSurface(n_old2);
			struct surface *surface_ptr2 = entity_ptr2->cxxSurface2surface();
			surface_ptr_to_user(surface_ptr2, n_old2);
			surface_free(surface_ptr2);
			free_check_null(surface_ptr2);
		}
		f1 = fraction1[7*i + 3];
		mix_surface(n_old1, n_old2, f1, -1);
		surface_ptr = surface_bsearch(-1, &n);
		system_ptr->surface = surface_replicate(surface_ptr, n_user_new);
	}
	/*
	 *   Copy gas phase
	 */
	n_old1 = initial_conditions1[ 7*i + 4 ];
	if (n_old1 >= 0) {
		cxxGasPhase *entity_ptr1 = phreeqcBin.getGasPhase(n_old1);
		struct gas_phase *gas_phase_ptr1 = entity_ptr1->cxxGasPhase2gas_phase();
		gas_phase_ptr_to_user(gas_phase_ptr1, n_old1);
		gas_phase_free(gas_phase_ptr1);
		free_check_null(gas_phase_ptr1);
		n_old2 = initial_conditions2[ 7*i + 4 ];
		if (n_old2 >= 0) {
			cxxGasPhase *entity_ptr2 = phreeqcBin.getGasPhase(n_old2);
			struct gas_phase *gas_phase_ptr2 = entity_ptr2->cxxGasPhase2gas_phase();
			gas_phase_ptr_to_user(gas_phase_ptr2, n_old2);
			gas_phase_free(gas_phase_ptr2);
			free_check_null(gas_phase_ptr2);
		}
		f1 = fraction1[7*i + 4];
		mix_gas_phase(n_old1, n_old2, f1, -1);
		gas_phase_ptr = gas_phase_bsearch(-1, &n);
		system_ptr->gas_phase = gas_phase_replicate(gas_phase_ptr, n_user_new);
	}
	/*
	 *   Copy solid solution
	 */
	n_old1 = initial_conditions1[ 7*i + 5 ];
	if (n_old1 >= 0) {
		cxxSSassemblage *entity_ptr1 = phreeqcBin.getSSassemblage(n_old1);
		struct s_s_assemblage *s_s_assemblage_ptr1 = entity_ptr1->cxxSSassemblage2s_s_assemblage();
		s_s_assemblage_ptr_to_user(s_s_assemblage_ptr1, n_old1);
		s_s_assemblage_free(s_s_assemblage_ptr1);
		free_check_null(s_s_assemblage_ptr1);
		n_old2 = initial_conditions2[ 7*i + 5 ];
		if (n_old2 >= 0) {
			cxxSSassemblage *entity_ptr2 = phreeqcBin.getSSassemblage(n_old2);
			struct s_s_assemblage *s_s_assemblage_ptr2 = entity_ptr2->cxxSSassemblage2s_s_assemblage();
			s_s_assemblage_ptr_to_user(s_s_assemblage_ptr2, n_old2);
			s_s_assemblage_free(s_s_assemblage_ptr2);
			free_check_null(s_s_assemblage_ptr2);
		}
		f1 = fraction1[7*i + 5];
		mix_s_s_assemblage(n_old1, n_old2, f1, -1);
		s_s_assemblage_ptr = s_s_assemblage_bsearch(-1, &n);
		system_ptr->s_s_assemblage = s_s_assemblage_replicate(s_s_assemblage_ptr, n_user_new);
	}
	/*
	 *   Copy kinetics
	 */
	n_old1 = initial_conditions1[ 7*i + 6 ];
	if (n_old1 >= 0) {
		cxxKinetics *entity_ptr1 = phreeqcBin.getKinetics(n_old1);
		struct kinetics *kinetics_ptr1 = entity_ptr1->cxxKinetics2kinetics();
		kinetics_ptr_to_user(kinetics_ptr1, n_old1);
		kinetics_free(kinetics_ptr1);
		free_check_null(kinetics_ptr1);
		n_old2 = initial_conditions2[ 7*i + 6 ];
		if (n_old2 >= 0) {
			cxxKinetics *entity_ptr2 = phreeqcBin.getKinetics(n_old2);
			struct kinetics *kinetics_ptr2 = entity_ptr2->cxxKinetics2kinetics();
			kinetics_ptr_to_user(kinetics_ptr2, n_old2);
			kinetics_free(kinetics_ptr2);
			free_check_null(kinetics_ptr2);
		}
		f1 = fraction1[7*i + 6];
		mix_kinetics(n_old1, n_old2, f1, -1);
		kinetics_ptr = kinetics_bsearch(-1, &n);
		system_ptr->kinetics = kinetics_replicate(kinetics_ptr, n_user_new);
	}
	return(system_ptr);
}
