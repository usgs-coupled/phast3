#define EXTERNAL extern
#include "phreeqc/global.h"
#include "phreeqc/output.h"
#include "hst.h"
#include "phreeqc/phqalloc.h"
#include "phreeqc/phrqproto.h"
#include "phastproto.h"

/*     $Date: 2004/11/04 15:22:27 $ */
static char const rcsid[] = "$RCSfile: hstsubs.c,v $  $Revision: 1.25 $";



/* ---------------------------------------------------------------------- */
void add_all_components(void) 
/* ---------------------------------------------------------------------- */
{
/*
 *   Routine accumulates elements from all solutions, phases, gas phases,
 *   exchangers, and surfaces. Counts number of aqueous components
 *   to transport. Stores in global variable count_component.
 *   Also calculates a number greater than all user numbers and
 *   stores in global variable first_user_number.
 */
	int i, save_print_use;

	if (rcsid == NULL) fprintf(stderr," ");
	save_print_use = pr.use;
	pr.use = FALSE;
	first_user_number = 1;
/*
 *   Delete solutions less than -1
 */
	while (count_solution > 0 && solution[0]->n_user < -1) {
		solution_delete(0);
	}
/*
 *   add all solutions
 */
	xsolution_zero();
	for (i = 0; i < count_solution; i++) {
		if (solution[i]->n_user > first_user_number) first_user_number = solution[i]->n_user;
		add_solution(solution[i], 1.0/solution[i]->mass_water, 1.0);
	}
/*
 *   add all irrev reactions
 */
	for (i = 0; i < count_irrev; i++) {
		if (irrev[i].n_user > first_user_number) first_user_number = irrev[i].n_user;
 		add_reaction(&irrev[i], 1, 1.0);
	}
/*
 *   Add pure phases
 */
	for (i = 0; i < count_pp_assemblage; i++) {
		if (pp_assemblage[i].n_user > first_user_number) first_user_number = pp_assemblage[i].n_user;
		add_pp_assemblage(&pp_assemblage[i]);
	}
/*
 *   Exchangers
 */
	/* transport_charge = FALSE; */
	transport_charge = TRUE;
	for (i = 0; i < count_exchange; i++) {
		transport_charge = TRUE;
		if (exchange[i].n_user > first_user_number) first_user_number = exchange[i].n_user;
		add_exchange(&exchange[i]);
	}
/*
 *   Surfaces
 */
	for (i = 0; i < count_surface; i++) {
		if (surface[i].diffuse_layer == FALSE) transport_charge = TRUE;
		if (surface[i].n_user > first_user_number) first_user_number = surface[i].n_user;
		add_surface(&surface[i]);
	}
/*
 *   Gases
 */
	for (i = 0; i < count_gas_phase; i++) {
		if (gas_phase[i].n_user > first_user_number) first_user_number = gas_phase[i].n_user;
		add_gas_phase(&gas_phase[i]);
	}
/*
 *   Add solid-solution pure phases
 */
	for (i = 0; i < count_s_s_assemblage; i++) {
		if (s_s_assemblage[i].n_user > first_user_number) first_user_number = s_s_assemblage[i].n_user;
		add_s_s_assemblage(&s_s_assemblage[i]);
	}
/*
 *   Add elements in kinetic reactions
 */
	for (i = 0; i < count_kinetics; i++) {
		if (kinetics[i].n_user > first_user_number) first_user_number = kinetics[i].n_user;
		calc_dummy_kinetic_reaction(&kinetics[i]);
		add_kinetics(&kinetics[i]);
	}
	first_user_number++;
/*
 *   reset pr.use
 */
	pr.use = save_print_use;
	return;
}
/* ---------------------------------------------------------------------- */
void buffer_print(const char *ptr, int n)
/* ---------------------------------------------------------------------- */
/*
 *   Puts boundary conditions for same component every dim position
 */
{
	int j;
	output_msg(OUTPUT_MESSAGE,"\t%s: %d\n", ptr, n);
	output_msg(OUTPUT_MESSAGE,"\t\tSpecies\tFraction\tMoles\n");
	for (j = 0; j < count_component; j++) {
		output_msg(OUTPUT_MESSAGE,"\t\t%s\t%e\t%e\n",buffer[j].master->elt->name,
			(double) buffer[j].fraction, (double) buffer[j].moles);
	}
	return;
}
#ifdef COMP_FIRST_FORTRAN_DIMENSION
/* ---------------------------------------------------------------------- */
void buffer_to_hst(double *first)
/* ---------------------------------------------------------------------- */
/*
 *   Puts boundary conditions for same component together
 */
{
	int j;
	for (j = 0; j < count_component; j++) {
		first[j] = buffer[j].fraction;
	}
	return;
}
#endif
#ifdef CELL_FIRST_FORTRAN_DIMENSION
#endif
/* ---------------------------------------------------------------------- */
void buffer_to_hst(double *first, int dim)
/* ---------------------------------------------------------------------- */
/*
 *   Puts boundary conditions for same component every dim position
 */
{
	int j;
	for (j = 0; j < count_component; j++) {
		first[dim*j] = buffer[j].fraction;
	}
	return;
}
/* ---------------------------------------------------------------------- */
void moles_to_hst(double *first, int dim)
/* ---------------------------------------------------------------------- */
/*
 *   Puts boundary conditions for same component every dim position
 */
{
	int j;
	for (j = 0; j < count_component; j++) {
		first[dim*j] = buffer[j].moles;
	}
	return;
}
#ifdef TRANSPORT_TOTAL_O_H
/* ---------------------------------------------------------------------- */
void buffer_to_mass_fraction(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Uses the moles in component structure to calculate
 *   mass fraction
 */
	int i;
	LDBLE total_mass;
	total_mass = 0.0;
/* gfw = g / mole, total mass in g */
	for (i = 0; i < count_component; i++) {
		total_mass += buffer[i].moles * buffer[i].gfw;
	}
	for (i = 0; i < count_component; i++) {
		buffer[i].fraction = buffer[i].moles * buffer[i].gfw / total_mass;
#ifdef PRINT
		output_msg(OUTPUT_STDERR, "Buffer[%d].fraction: %20.10e, moles: %20.10e, gfw: %20.10e, total_mass: %20.10e\n", i, buffer[i].fraction, buffer[i].moles, buffer[i].gfw, total_mass);
#endif
	}
	return;
}
#endif
#ifdef SKIP
/* ---------------------------------------------------------------------- */
void buffer_to_mass_fraction(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Uses the moles in component structure to calculate
 *   mass fraction
 */
	int i;
	LDBLE total_mass;
/* 1 kg water = 1000 g */
	total_mass = 1000.0;
/* gfw = g / mole, total mass in g */
	for (i = 0; i < count_component; i++) {
		total_mass += buffer[i].moles * buffer[i].gfw;
	}
	for (i = 0; i < count_component; i++) {
		buffer[i].fraction = buffer[i].moles * buffer[i].gfw / total_mass;
#ifdef PRINT
		output_msg(OUTPUT_STDERR, "Buffer[%d].fraction: %20.10e, moles: %20.10e, gfw: %20.10e, total_mass: %20.10e\n", i, buffer[i].fraction, buffer[i].moles, buffer[i].gfw, total_mass);
#endif
	}
	return;
}
#endif
/* ---------------------------------------------------------------------- */
void buffer_to_mass_fraction(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Uses the moles in component structure to calculate
 *   mass fraction
 */
	/* fraction = mass solute(g) / (1000 + mass solute (g)) 
	   note:
	        (1) 1 kg water is fixed and is not the real mass of water
	        (2) each component is calculated separately, changes in mass of a solute
		    do not affect other solutes
                (3) Excess H and O are transported, that is total H minus H in water and
		    total O minus O in water
                (4) For each solute, Mass is calculated by f/(1-f)
                (5) Total mass of H is 1 kg water plus mass of excess H, same for O

           This approach avoids mass balance errors resulting from consumption or production
           of water by reactions or change in mass fraction due to change in another solute.
	*/
	int i;

	for (i = 0; i < count_component; i++) {
		/*
		buffer[i].fraction = buffer[i].moles * buffer[i].gfw / (1000. + buffer[i].moles * buffer[i].gfw );
		*/
		buffer[i].fraction = buffer[i].moles * buffer[i].gfw / 1000.;
#ifdef PRINT
		output_msg(OUTPUT_STDERR, "Buffer[%d].fraction: %20.10e, moles: %20.10e, gfw: %20.10e, total_mass: %20.10e\n", i, buffer[i].fraction, buffer[i].moles, buffer[i].gfw, total_mass);
#endif
	}
	return;
}

#ifdef TRANSPORT_TOTAL_O_H
/* ---------------------------------------------------------------------- */
void buffer_to_moles(void)
/* ---------------------------------------------------------------------- */
{
	int i;
/* 0.001 * gfw = kg / mole */
/* fraction / mass_water = kg component / kg water */
	for (i = 0; i < count_component; i++) {
		buffer[i].moles = (buffer[i].fraction / (0.001 * buffer[i].gfw));
#ifdef PRINT
		output_msg(OUTPUT_STDERR, "Buffer[%d].fraction: %20.10e, moles: %20.10e, gfw: %20.10e\n", i, buffer[i].fraction, buffer[i].moles, buffer[i].gfw);
#endif
	}
	return;
}
#endif
#ifdef SKIP
/* ---------------------------------------------------------------------- */
void buffer_to_moles(void)
/* ---------------------------------------------------------------------- */
{
	int i;
	LDBLE mass_water;

	mass_water = 1.0;
	for (i = 0; i < count_component; i++) {
		mass_water -= buffer[i].fraction;
	}
/* 0.001 * gfw = kg / mole */
/* fraction / mass_water = kg component / kg water */
	for (i = 0; i < count_component; i++) {
		buffer[i].moles = (buffer[i].fraction / (0.001 * buffer[i].gfw)) /  mass_water;
#ifdef PRINT
		output_msg(OUTPUT_STDERR, "Buffer[%d].fraction: %20.10e, moles: %20.10e, gfw: %20.10e, mass_water: %20.10e\n", i, buffer[i].fraction, buffer[i].moles, buffer[i].gfw, mass_water);
#endif
	}
	
	return;
}
#endif
/* ---------------------------------------------------------------------- */
void buffer_to_moles(void)
/* ---------------------------------------------------------------------- */
{
	int i;

	/* fraction = mass solute / (1 + mass solute) 
	   note:
	        (1) 1 kg water is fixed and is not the real mass of water
	        (2) each component is calculated separately, changes in mass of a solute
		    do not affect other solutes
                (3) Excess H and O are transported, that is total H minus H in water and
		    total O minus O in water
                (4) For each solute, Mass is calculated by f/(1-f)
                (5) Total mass of H is 1 kg water plus mass of excess H, same for O

           This approach avoids mass balance errors resulting from consumption or production
           of water by reactions or change in mass fraction due to change in another solute.
	*/
	for (i = 0; i < count_component; i++) {
		/*
		buffer[i].moles = (buffer[i].fraction / (0.001 * buffer[i].gfw)) /  (1 - buffer[i].fraction);
		*/
		buffer[i].moles = 1000.*buffer[i].fraction / buffer[i].gfw;
#ifdef PRINT
		output_msg(OUTPUT_STDERR, "Buffer[%d].fraction: %20.10e, moles: %20.10e, gfw: %20.10e, mass_water: %20.10e\n", i, buffer[i].fraction, buffer[i].moles, buffer[i].gfw, mass_water);
#endif
	}
	
	return;
}

#ifdef TRANSPORT_TOTAL_O_H
/* ---------------------------------------------------------------------- */
void buffer_to_solution(struct solution *solution_ptr)
/* ---------------------------------------------------------------------- */
{
	int i, j;
	LDBLE t;
/* 
 *  add water to hydrogen and oxygen
 */

	solution_ptr->total_h = buffer[0].moles;
	solution_ptr->total_o = buffer[1].moles;

/* 
 *  Put totals in solution structure
 */
#ifdef PRINT
	output_msg(OUTPUT_STDERR,"Unpack solution %d.\n", solution_ptr->n_user);
#endif
	for (i = 2; i < count_total; i++) {
		if (buffer[i].moles <= 1e-14) {
			solution_ptr->totals[i-2].moles = 0;
		} else {
			if (solution_ptr->totals[i-2].moles <= 0) {
				t = log10(buffer[i].moles) - 2.0;
				for (j = buffer[i].first_master; j <= buffer[i].last_master; j++) {
					solution_ptr->master_activity[j].la = t;
				}
			} else {
				t = log10(buffer[i].moles / solution_ptr->totals[i-2].moles);
				for (j = buffer[i].first_master; j <= buffer[i].last_master; j++) {
					solution_ptr->master_activity[j].la += t;
				}
			}
			solution_ptr->totals[i-2].moles = buffer[i].moles;
		}
#ifdef PRINT
		output_msg(OUTPUT_STDERR,"\t%s\t%g\n", solution_ptr->totals[i-2].description, solution_ptr->totals[i-2].moles);
#endif
	}
/*
 *   Switch in transport of charge
 */
	if (transport_charge == TRUE) {
		solution_ptr->cb = buffer[i].moles;
	}
	return;
}
#endif
/* ---------------------------------------------------------------------- */
void buffer_to_solution(struct solution *solution_ptr)
/* ---------------------------------------------------------------------- */
{
	int i, j;
	LDBLE t;
/* 
 *  add water to hydrogen and oxygen
 */
	solution_ptr->total_h = buffer[0].moles + 2  / gfw_water ;
	solution_ptr->total_o = buffer[1].moles + 1 / gfw_water;

/* 
 *  Put totals in solution structure
 */
#ifdef PRINT
	output_msg(OUTPUT_STDERR,"Unpack solution %d.\n", solution_ptr->n_user);
#endif
	for (i = 2; i < count_total; i++) {
		if (buffer[i].moles <= 1e-14) {
			solution_ptr->totals[i-2].moles = 0;
		} else {
			if (solution_ptr->totals[i-2].moles <= 0) {
				t = log10(buffer[i].moles) - 2.0;
				for (j = buffer[i].first_master; j <= buffer[i].last_master; j++) {
					solution_ptr->master_activity[j].la = t;
				}
			} else {
				t = log10(buffer[i].moles / solution_ptr->totals[i-2].moles);
				for (j = buffer[i].first_master; j <= buffer[i].last_master; j++) {
					solution_ptr->master_activity[j].la += t;
				}
			}
			solution_ptr->totals[i-2].moles = buffer[i].moles;
		}
#ifdef PRINT
		output_msg(OUTPUT_STDERR,"\t%s\t%g\n", solution_ptr->totals[i-2].description, solution_ptr->totals[i-2].moles);
#endif
	}
/*
 *   Switch in transport of charge
 */
	if (transport_charge == TRUE) {
		solution_ptr->cb = buffer[i].moles;
	}
	return;
}
#ifdef COMP_FIRST_FORTRAN_DIMENSION
/* ---------------------------------------------------------------------- */
void hst_to_buffer(double *first)
/* ---------------------------------------------------------------------- */
/*
 *   Pulls out solution composition for a single cell
 */
{
	int j;
	for (j = 0; j < count_component; j++) {
		buffer[j].fraction = first[j];
	}
	return;
}
#endif
#ifdef CELL_FIRST_FORTRAN_DIMENSION
#endif
/* ---------------------------------------------------------------------- */
void hst_to_buffer(double *first, int dim)
/* ---------------------------------------------------------------------- */
/*
 *   Pulls out solution composition for a single cell
 */
{
	int j;
	for (j = 0; j < count_component; j++) {
		buffer[j].fraction = first[dim*j];
	}
	return;
}
/* ---------------------------------------------------------------------- */
void hst_moles_to_buffer(double *first, int dim)
/* ---------------------------------------------------------------------- */
/*
 *   Pulls out solution composition for a single cell
 */
{
	int j;
	for (j = 0; j < count_component; j++) {
		buffer[j].moles = first[dim*j];
	}
	return;
}
#ifdef TRANSPORT_TOTAL_O_H
/* ---------------------------------------------------------------------- */
void solution_to_buffer(struct solution *solution_ptr)
/* ---------------------------------------------------------------------- */
{
	int i;
/* gfw_water = 0.018 */
#ifdef PRINT
	output_msg(OUTPUT_STDERR,"Pack solution %d.\n", solution_ptr->n_user);
#endif
	buffer[0].moles = solution_ptr->total_h;
	buffer[1].moles = solution_ptr->total_o;
	for (i = 2; i < count_total; i++) {
		buffer[i].moles = solution_ptr->totals[i-2].moles;
#ifdef PRINT
		output_msg(OUTPUT_STDERR,"\t%s\t%g\n", solution_ptr->totals[i-2].description, solution_ptr->totals[i-2].moles);
#endif
	}
/*
 *   Switch in transport of charge
 */
	if (transport_charge == TRUE) {
		buffer[i].moles = solution_ptr->cb;
	}
	return;
}
#endif
/* ---------------------------------------------------------------------- */
void solution_to_buffer(struct solution *solution_ptr)
/* ---------------------------------------------------------------------- */
{
	int i;
	LDBLE moles_water;
	moles_water = solution_ptr->mass_water / gfw_water;
	moles_water = 1/gfw_water;
/* gfw_water = 0.018 */
	buffer[0].moles = solution_ptr->total_h - 2 * moles_water;
	buffer[1].moles = solution_ptr->total_o - moles_water;
#ifdef PRINT
	output_msg(OUTPUT_STDERR,"Pack solution %d.\n", solution_ptr->n_user);
#endif
	for (i = 2; i < count_total; i++) {
		buffer[i].moles = solution_ptr->totals[i-2].moles;
#ifdef PRINT
		output_msg(OUTPUT_STDERR,"\t%s\t%g\n", solution_ptr->totals[i-2].description, solution_ptr->totals[i-2].moles);
#endif
	}
/*
 *   Switch in transport of charge
 */
	if (transport_charge == TRUE) {
		buffer[i].moles = solution_ptr->cb;
	}
	return;
}
/* ---------------------------------------------------------------------- */
void set_use_hst(void)
/* ---------------------------------------------------------------------- */
{
	int n_user;
	struct exchange *exchange_ptr;
	struct gas_phase *gas_phase_ptr;
	struct kinetics *kinetics_ptr;
	struct pp_assemblage *pp_assemblage_ptr;
	struct surface *surface_ptr;
	struct s_s_assemblage *s_s_assemblage_ptr;

	use.temperature_ptr = NULL;
	use.irrev_ptr = NULL;
	use.mix_ptr = NULL;

	n_user = solution[n_solution]->n_user;
/*
 *   set solution
 */
	use.solution_ptr = solution[n_solution];
	use.n_solution_user = n_user;
	use.n_solution = n_solution;
	use.solution_in = TRUE;
	save.solution = TRUE;
	save.n_solution_user = n_user;
	save.n_solution_user_end = n_user;
/*
 *   Switch in exchange
 */
	exchange_ptr = exchange_bsearch(n_user, &n_exchange);
	if (exchange_ptr != NULL) {
		use.exchange_ptr = &exchange[n_exchange];
		use.n_exchange_user = n_user;
		use.n_exchange = n_exchange;
		use.exchange_in = TRUE;
		save.exchange = TRUE;
		save.n_exchange_user = n_user;
		save.n_exchange_user_end = n_user;
	} else {
		use.exchange_ptr = NULL;
		use.exchange_in = FALSE;
		save.exchange = FALSE;
	}
/*
 *   Switch in gas_phase
 */
	gas_phase_ptr = gas_phase_bsearch(n_user, &n_gas_phase);
	if (gas_phase_ptr != NULL) {
		use.gas_phase_ptr = &gas_phase[n_gas_phase];
		use.n_gas_phase_user = n_user;
		use.n_gas_phase = n_gas_phase;
		use.gas_phase_in = TRUE;
		save.gas_phase = TRUE;
		save.n_gas_phase_user = n_user;
		save.n_gas_phase_user_end = n_user;
	} else {
		use.gas_phase_ptr = NULL;
		use.gas_phase_in = FALSE;
		save.gas_phase = FALSE;
	}
/*
 *   Switch in pp_assemblage
 */
	pp_assemblage_ptr = pp_assemblage_bsearch(n_user, &n_pp_assemblage);
	if (pp_assemblage_ptr != NULL) {
		use.pp_assemblage_ptr = &pp_assemblage[n_pp_assemblage];
		use.n_pp_assemblage_user = n_user;
		use.n_pp_assemblage = n_pp_assemblage;
		use.pp_assemblage_in = TRUE;
		save.pp_assemblage = TRUE;
		save.n_pp_assemblage_user = n_user;
		save.n_pp_assemblage_user_end = n_user;
	} else {
		use.pp_assemblage_ptr = NULL;
		use.pp_assemblage_in = FALSE;
		save.pp_assemblage = FALSE;
	}
/*
 *   Switch in surface
 */
	surface_ptr = surface_bsearch(n_user, &n_surface);
	if (surface_ptr != NULL) {
		use.surface_ptr = &surface[n_surface];
		use.n_surface_user = n_user;
		use.n_surface = n_surface;
		use.surface_in = TRUE;
		save.surface = TRUE;
		save.n_surface_user = n_user;
		save.n_surface_user_end = n_user;
	} else {
		use.surface_ptr = NULL;
		use.surface_in = FALSE;
		save.surface = FALSE;
	}
/*
 *   Switch in s_s_assemblage
 */
	s_s_assemblage_ptr = s_s_assemblage_bsearch(n_user, &n_s_s_assemblage);
	if (s_s_assemblage_ptr != NULL) {
		use.s_s_assemblage_ptr = &s_s_assemblage[n_s_s_assemblage];
		use.n_s_s_assemblage_user = n_user;
		use.n_s_s_assemblage = n_s_s_assemblage;
		use.s_s_assemblage_in = TRUE;
		save.s_s_assemblage = TRUE;
		save.n_s_s_assemblage_user = n_user;
		save.n_s_s_assemblage_user_end = n_user;
	} else {
		use.s_s_assemblage_ptr = NULL;
		use.s_s_assemblage_in = FALSE;
		save.s_s_assemblage = FALSE;
	}
/*
 *   Switch in kinetics
 */
	kinetics_ptr = kinetics_bsearch(n_user, &n_kinetics);
	if (kinetics_ptr != NULL) {
		use.kinetics_ptr = &kinetics[n_kinetics];
		use.n_kinetics_user = n_user;
		use.n_kinetics = n_kinetics;
		use.kinetics_in = TRUE;
		save.kinetics = TRUE;
		save.n_kinetics_user = n_user;
		save.n_kinetics_user_end = n_user;
	} else {
		use.kinetics_ptr = NULL;
		use.kinetics_in = FALSE;
		save.kinetics = FALSE;
	}
	return;
}
/* ---------------------------------------------------------------------- */
void unpack_from_hst(double *fraction, int *dim)
/* ---------------------------------------------------------------------- */
{
	int i, j, n;
	solution_bsearch(first_user_number, &first_solution, TRUE);
	for (i = 0; i < ixyz; i++) {
		j = forward[i];
		if (j < 0) continue;
		n = first_solution + j;
		hst_to_buffer(&fraction[i], *dim);
		buffer_to_moles();
		buffer_to_solution(solution[n]);
	}
	return;
}
/* ---------------------------------------------------------------------- */
int xexchange_save_hst(int n)
/* ---------------------------------------------------------------------- */
{
/*
 *   Save exchanger assemblage into structure exchange with user 
 *   number n_user.
 */
	int i, j;
	int count_comps;
	LDBLE charge;

	count_comps = exchange[n].count_comps;
	exchange[n].new_def = FALSE;
/*
 *   Write exch_comp structure for each exchange component
 */
	count_comps = 0;
	
	for (i = 0; i < count_unknowns; i++) {
		if (x[i]->type == EXCH) {
			free_check_null (exchange[n].comps[count_comps].totals);
			exchange[n].comps[count_comps].master = x[i]->master[0];
			exchange[n].comps[count_comps].la = x[i]->master[0]->s->la;
/*
 *   Save element concentrations on exchanger
 */
			count_elts = 0;
			paren_count = 0;
			charge = 0.0;
			for (j=0; j < count_species_list; j++) {
				if (species_list[j].master_s == x[i]->master[0]->s) {
					add_elt_list(species_list[j].s->next_elt, species_list[j].s->moles);
					charge += species_list[j].s->moles * species_list[j].s->z;
				}
			}
/*
 *   Keep exchanger related to phase even if none currently in solution
 */			
			if (x[i]->exch_comp->phase_name != NULL && count_elts == 0) {
				add_elt_list(x[i]->master[0]->s->next_elt, MIN_TOTAL);
			}
/*
 *   Store list
 */
			exchange[n].comps[count_comps].charge_balance = charge;
			exchange[n].comps[count_comps].totals = elt_list_save();
			count_comps++;
		}
	}
	if (count_comps < exchange[n].count_comps) {
		for (i = count_comps; i < exchange[n].count_comps; i++) {
			exchange[n].comps[i].totals = (struct elt_list *) free_check_null (exchange[n].comps[i].totals);
			exchange[n].comps[i].formula_totals = (struct elt_list *) free_check_null (exchange[n].comps[i].formula_totals);
		}
	}
        exchange[n].count_comps = count_comps;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int xgas_save_hst(int n)
/* ---------------------------------------------------------------------- */
{
/*
 *   Save gas composition into structure gas_phase n
 */
	int count_comps, i;
	struct gas_comp *gas_comp_ptr;
/*
 *   Update amounts
 */
	count_comps = gas_phase[n].count_comps;
	gas_comp_ptr = gas_phase[n].comps;
	
	for (i = 0; i < count_comps; i++) {
		gas_comp_ptr[i].moles = use.gas_phase_ptr->comps[i].phase->moles_x;
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int xpp_assemblage_save_hst(int n)
/* ---------------------------------------------------------------------- */
{
/*
 *   Save pure_phase assemblage into structure pp_assemblage n
 */
	int j, i;
	struct pure_phase *pure_phase_ptr;
/*
 *   Count pure phases
 */
	pure_phase_ptr = pp_assemblage[n].pure_phases;
/*
 *   Update amounts
 */
	i = 0;
	for (j=0; j < count_unknowns; j++) {
		if (x[j]->type != PP) continue;
		pure_phase_ptr[i].moles = x[j]->moles;
		pure_phase_ptr[i].delta = 0.0;
		i++;
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int xsolution_save_hst(int n)
/* ---------------------------------------------------------------------- */
{
/*
 *   Save solution composition into structure solution n
 *
 *   input:  n is pointer number in solution
 */
	int j;
	struct solution *solution_ptr;

	solution_ptr = solution[n];
	solution_ptr->totals = PHRQ_realloc (solution_ptr->totals, (size_t) (count_total - 1) * sizeof(struct conc));
	solution_ptr->master_activity = PHRQ_realloc (solution_ptr->master_activity, (size_t) (count_activity_list + 1) * sizeof(struct master_activity));
	solution_ptr->ph = ph_x;
	solution_ptr->solution_pe = solution_pe_x;
	solution_ptr->mu = mu_x;
	solution_ptr->ah2o = ah2o_x;
	solution_ptr->density = density_x;
	solution_ptr->total_h = total_h_x;
	solution_ptr->total_o = total_o_x;
	solution_ptr->total_alkalinity = total_alkalinity;
	solution_ptr->total_co2 = total_co2 / mass_water_aq_x;
	solution_ptr->cb = cb_x;   /* cb_x does not include surface charge */
	solution_ptr->mass_water = mass_water_aq_x;
/*
 *   Copy totals data
 */
	for (j = 2; j < count_total; j++) {
		solution_ptr->totals[j-2].moles = buffer[j].master->total_primary;
		solution_ptr->totals[j-2].description = buffer[j].master->elt->name;
/*		solution_ptr->totals[j-2].input_conc = master[i]->total; */
		solution_ptr->totals[j-2].skip = FALSE;
		solution_ptr->totals[j-2].units = solution_ptr->units;
		solution_ptr->totals[j-2].equation_name = NULL;
		solution_ptr->totals[j-2].n_pe = 0;
		solution_ptr->totals[j-2].phase = NULL;
		solution_ptr->totals[j-2].phase_si = 0.0;
		solution_ptr->totals[j-2].as = NULL;
		solution_ptr->totals[j-2].gfw = 0.0;
	}
	solution_ptr->totals[j-2].description = NULL;
	for (j = 0; j < count_activity_list; j++) {
		solution_ptr->master_activity[j].la = activity_list[j].master->s->la;
		solution_ptr->master_activity[j].description = activity_list[j].master->elt->name;
#ifdef SKIP
		output_msg(OUTPUT_MESSAGE, "xsolution_save_hst: %s\t%e\n", activity_list[j].master->elt->name, 
			activity_list[j].master->s->la);
#endif
	}
	solution_ptr->master_activity[j].description = NULL;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int xsurface_save_hst(int n)
/* ---------------------------------------------------------------------- */
{
/*
 *   Save surface data into structure surface with user 
 *   number n_user.
 */
	int i, j;
	int count_comps, count_charge;
	struct surface_comp *comps_ptr;
	struct surface_charge *charge_ptr;

/*
 *   Write surface_comp structure for each surf component into comps_ptr
 */
	count_comps = 0;
	count_charge = 0;
	comps_ptr = surface[n].comps;
	charge_ptr = surface[n].charge;
	surface[n].new_def = FALSE;

	for (i = 0; i < count_unknowns; i++) {
		if (x[i]->type == SURFACE) {
			comps_ptr[count_comps].la = x[i]->master[0]->s->la;
			comps_ptr[count_comps].charge = x[i]->surface_comp->charge;
/*
 *   Save element concentrations on surface
 */
			count_elts = 0;
			paren_count = 0;
			for (j=0; j < count_species_list; j++) {
				if (species_list[j].master_s == x[i]->master[0]->s) {
					add_elt_list(species_list[j].s->next_elt, species_list[j].s->moles);
				}
			}
			free_check_null(comps_ptr[count_comps].totals);
			comps_ptr[count_comps].totals = elt_list_save();
			count_comps++;
		} else if (x[i]->type == SURFACE_CB) {
			charge_ptr[count_charge].charge_balance = x[i]->f; 
			charge_ptr[count_charge].mass_water = x[i]->surface_charge->mass_water;
			charge_ptr[count_charge].psi_master = x[i]->master[0];
			charge_ptr[count_charge].la_psi = x[i]->master[0]->s->la;
/*
 *   Store moles from diffuse_layer
 */
			if (diffuse_layer_x == TRUE) {
				sum_diffuse_layer(x[i]->surface_charge);
				free_check_null(charge_ptr[count_charge].diffuse_layer_totals); 
				charge_ptr[count_charge].diffuse_layer_totals = elt_list_save();
			}
			count_charge++;
		}
	}
	surface[n].count_comps = count_comps;
	surface[n].count_charge = count_charge;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int xs_s_assemblage_save_hst(int n)
/* ---------------------------------------------------------------------- */
{
/*
 *   Save pure_phase assemblage into structure s_s_assemblage n
 */
	int j, i;
	int count_comps;
/*
 *   Update amounts in initial_moles
 */
	for (i = 0; i < use.s_s_assemblage_ptr->count_s_s; i++) {
		count_comps = use.s_s_assemblage_ptr->s_s[i].count_comps;
		/* set initial moles for quick setup*/
		for (j = 0; j < count_comps; j++) {
			use.s_s_assemblage_ptr->s_s[i].comps[j].initial_moles = use.s_s_assemblage_ptr->s_s[i].comps[j].moles;
		}
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int calc_dummy_kinetic_reaction(struct kinetics *kinetics_ptr)
/* ---------------------------------------------------------------------- */
{
/*
 *    Go through kinetic components and add positive amount of each reactant
 */
	int i, j;
	LDBLE coef;
	char token[MAX_LENGTH];
	char *ptr;
	struct phase *phase_ptr;
/*
 *   Go through list and generate list of elements and
 *   coefficient of elements in reaction
 */
	free_check_null(kinetics_ptr->totals);
	count_elts = 0;
	paren_count = 0;
	for (i=0; i < kinetics_ptr->count_comps; i++) {
		coef = 1.0;
/*
 *   Reactant is a pure phase, copy formula into token
 */
		phase_ptr = NULL;
		if (kinetics_ptr->comps[i].count_list == 1) {
			strcpy(token, kinetics_ptr->comps[i].list[0].name);
			phase_ptr = phase_bsearch(token, &j, FALSE);
		}
		if (phase_ptr != NULL) {
			add_elt_list(phase_ptr->next_elt, coef);
		} else {
			for (j = 0; j < kinetics_ptr->comps[i].count_list; j++) {
				ptr = kinetics_ptr->comps[i].list[j].name;
#ifdef SKIP
				get_elts_in_species (&ptr, coef * kinetics_ptr->comps[i].list[j].coef);
#endif
				get_elts_in_species (&ptr, coef);
			}
		}

	}
	kinetics_ptr->totals = elt_list_save();

	return(OK);
}
/* ---------------------------------------------------------------------- */
int print_using_hst(int cell_number)
/* ---------------------------------------------------------------------- */
{
/*
 *   Print entities used in calculation
 */
#ifdef SKIP
	struct mix *mix_ptr;
	struct solution *solution_ptr;
	struct exchange *exchange_ptr;
	struct surface *surface_ptr;
	struct pp_assemblage *pp_assemblage_ptr;
	struct s_s_assemblage *s_s_assemblage_ptr;
	struct gas_phase *gas_phase_ptr;
	struct temperature *temperature_ptr;
	struct irrev *irrev_ptr;
	struct kinetics *kinetics_ptr;
	int n;
#endif
/*
 *   Mixture or Solution
 */
	output_msg(OUTPUT_MESSAGE,"Using solution %d.\n", cell_number);
/*
 *   Exchange and surface
 */
	if (use.exchange_in == TRUE) {
		output_msg(OUTPUT_MESSAGE,"Using exchange %d\n", cell_number);
	}
	if (use.surface_in == TRUE) {
		output_msg(OUTPUT_MESSAGE,"Using surface %d.\n", cell_number);
	}
	if (use.pp_assemblage_in == TRUE) {
		output_msg(OUTPUT_MESSAGE,"Using pure phase assemblage %d.\n", cell_number);
	}
	if (use.s_s_assemblage_in == TRUE) {
		output_msg(OUTPUT_MESSAGE,"Using solid solution assemblage %d.\n", cell_number);
	}
	if (use.gas_phase_in == TRUE) {
		output_msg(OUTPUT_MESSAGE,"Using gas phase %d.\n", cell_number);
	}
	if (use.temperature_in == TRUE) {
		output_msg(OUTPUT_MESSAGE,"Using temperature %d.\n", cell_number);
	}
	if (use.irrev_in == TRUE) {
		output_msg(OUTPUT_MESSAGE,"Using reaction %d.\n", cell_number);
	}
	if (use.kinetics_in == TRUE) {
		output_msg(OUTPUT_MESSAGE,"Using kinetics %d.\n", cell_number);
	}
	output_msg(OUTPUT_MESSAGE,"\n");
	return(OK);
}
/* ---------------------------------------------------------------------- */
int scale_solution(int n_solution, double factor)
/* ---------------------------------------------------------------------- */
{
/*
 *   Print entities used in calculation
 */
	int i, j;

	i = n_solution;
	xsolution_zero();
	add_solution(solution[i], factor, 1.0);
	for(j = 2; j < count_total; j++) {
		buffer[j].master->total_primary = buffer[j].master->total;
	}
	xsolution_save_hst(i);
	return(OK);
}
