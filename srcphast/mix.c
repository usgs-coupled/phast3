#define EXTERNAL extern
#include "phreeqc/global.h"
#include "hst.h"
#include "phreeqc/phqalloc.h"
#include "phreeqc/output.h"
#include "phreeqc/phrqproto.h"
#include "phastproto.h"

extern int mpi_myself;
static char const svnid[] = "$Id$";

/* ---------------------------------------------------------------------- */
int sum_solutions (struct solution *source1, LDBLE f1, struct solution *source2, LDBLE f2, struct solution *target)
/* ---------------------------------------------------------------------- */
{
/*
 *   adds two solutions, saves result in target
 */
	int j;
	struct solution *solution_ptr1, *solution_ptr2;

	LDBLE intensive, extensive;
	if (svnid == NULL) fprintf(stderr," ");
/*
 *   Zero out global solution data
 */
	xsolution_zero();
/*
 *
 */	
	solution_ptr1 = source1;
	if (solution_ptr1 == NULL) {
		sprintf(error_string, "Null pointer for solution 1 in sum_solutions.");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	solution_ptr2 = source2;
	extensive = f1;
	intensive = f1;
	add_solution(solution_ptr1, extensive, intensive);
	if (solution_ptr2 != NULL) {
		extensive = f2;
		intensive = f2;
		add_solution(solution_ptr2, extensive, intensive);
	}
	for(j = 2; j < count_total; j++) {
		buffer[j].master->total_primary = buffer[j].master->total;
	}
	if (target == NULL) {
		sprintf(error_string, "Target solutione is NULL in sum_esolution");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	}
	xsolution_save_hst_ptr(target);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int sum_exchange (struct exchange *source1, LDBLE f1, struct exchange *source2, LDBLE f2, struct exchange *target)
/* ---------------------------------------------------------------------- */
{
/*
 *   sums two exchangers, saves result in target
 */
	int new_n_user, found;
	int i, j;
	struct exchange temp_exchange, *exchange_ptr;

	struct exchange *exchange_ptr1, *exchange_ptr2;
	char token[MAX_LENGTH];
	int count_comps;

/*
 *   Find exchangers
 */	
	exchange_ptr1 = source1;
	if (exchange_ptr1 == NULL) {
		sprintf(error_string, "Null pointer for exchange 1 in sum_exchnage.");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	exchange_ptr2 = source2;
/*
 *   Store data for structure exchange
 */
	new_n_user = exchange_ptr1->n_user;
	temp_exchange.n_user = new_n_user;
	temp_exchange.n_user_end = new_n_user;
	temp_exchange.new_def = TRUE;
	sprintf(token, "Initial condition");
	temp_exchange.description = string_duplicate(token);
	temp_exchange.solution_equilibria = FALSE;
	temp_exchange.n_solution = -2;
	temp_exchange.related_phases = exchange_ptr1->related_phases;
	temp_exchange.related_rate = exchange_ptr1->related_rate;
/*
 *   Write exch_comp structure for each exchange component
 */
	count_comps = exchange_ptr1->count_comps;
	temp_exchange.comps = (struct exch_comp *) PHRQ_malloc ((size_t) (count_comps) * sizeof (struct exch_comp));
	for (i = 0; i < exchange_ptr1->count_comps; i++) {
		memcpy(&temp_exchange.comps[i], &exchange_ptr1->comps[i], sizeof(struct exch_comp));
		temp_exchange.comps[i].formula_totals = elt_list_dup(exchange_ptr1->comps[i].formula_totals);
		temp_exchange.comps[i].moles *= f1;
		count_elts = 0;
		add_elt_list(exchange_ptr1->comps[i].totals, f1);
		temp_exchange.comps[i].totals = elt_list_save();
		temp_exchange.comps[i].charge_balance *= f1;
	}
	/* merge exchange comps from second exchanger */
	if (exchange_ptr2 != NULL) {
		for (i = 0; i < exchange_ptr2->count_comps; i++) {
			/*
			 * Look in current comps
			 */
			found = FALSE;
			for (j = 0; j < count_comps; j++) {
				if (temp_exchange.comps[j].formula == exchange_ptr2->comps[i].formula) {
					found = TRUE;
					break;
				}
			}
			if (found == TRUE) {
				/*
				 * merge with old component
				 */
				count_elts = 0;
				add_elt_list(temp_exchange.comps[j].totals, 1.0);
				add_elt_list(exchange_ptr2->comps[i].totals, f2);
				if (count_elts > 0 ) {
					qsort (elt_list, (size_t) count_elts, (size_t) sizeof(struct elt_list), elt_list_compare);
					elt_list_combine ();
				}
				free_check_null(temp_exchange.comps[j].totals);
				temp_exchange.comps[j].totals = elt_list_save();
				temp_exchange.comps[j].charge_balance += f2*exchange_ptr2->comps[i].charge_balance;
			} else {
				/*
				 * add a new component
				 */
				temp_exchange.comps = (struct exch_comp *) PHRQ_malloc ((size_t) (count_comps + 1) * sizeof (struct exch_comp));
				if (temp_exchange.comps == NULL) malloc_error();
				memcpy(&temp_exchange.comps[count_comps], &exchange_ptr2->comps[i], sizeof(struct exch_comp));
				temp_exchange.comps[count_comps].moles *= f2;
				count_elts = 0;
				add_elt_list(exchange_ptr2->comps[i].totals, f2);
				temp_exchange.comps[count_comps].totals = elt_list_save();
				temp_exchange.comps[count_comps].formula_totals = elt_list_dup(exchange_ptr2->comps[i].formula_totals);
				temp_exchange.comps[count_comps].charge_balance *= f2;
				count_comps++;
			}
		}
	}
	temp_exchange.count_comps = count_comps;
/*
 *   Finish up
 */
	exchange_ptr = target;
	if (exchange_ptr == NULL) {
		sprintf(error_string, "Target exchange pointer is NULL in sum_exchange");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	}
	memcpy(exchange_ptr, &temp_exchange, sizeof(struct exchange));

	return(OK);
}
/* ---------------------------------------------------------------------- */
int sum_pp_assemblage (struct pp_assemblage *source1, LDBLE f1, struct pp_assemblage *source2, LDBLE f2, struct pp_assemblage *target)
/* ---------------------------------------------------------------------- */
{
/*
 *   sums two pp_assemblages, saves result in target
 */
	int new_n_user, found;
	int i, j;
	struct pp_assemblage temp_pp_assemblage, *pp_assemblage_ptr;

	struct pp_assemblage *pp_assemblage_ptr1, *pp_assemblage_ptr2;
	char token[MAX_LENGTH];
	int count_comps, count_comps1, count_comps2;

/*
 *   Find pp_assemblagers
 */	
	pp_assemblage_ptr1 = source1;
	if (pp_assemblage_ptr1 == NULL) {
		sprintf(error_string, "Null pointer for pp_assemblage 1 in sum_pp_assemblage.");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	pp_assemblage_ptr2 = source2;
/*
 *   Store data for structure pp_assemblage
 */
	new_n_user = pp_assemblage_ptr1->n_user;
	temp_pp_assemblage.n_user = new_n_user;
	temp_pp_assemblage.n_user_end = new_n_user;
	temp_pp_assemblage.new_def = pp_assemblage_ptr1->new_def;
	sprintf(token, "Initial condition");
	temp_pp_assemblage.description = string_duplicate(token);
	count_elts = 0;
	add_elt_list(pp_assemblage_ptr1->next_elt, 1.0);
	if (pp_assemblage_ptr2 != NULL) {
		add_elt_list(pp_assemblage_ptr2->next_elt, 1.0);
	}
	if (count_elts > 0 ) {
		qsort (elt_list, (size_t) count_elts, (size_t) sizeof(struct elt_list), elt_list_compare);
		elt_list_combine ();
	}
	temp_pp_assemblage.next_elt = elt_list_save();

/*
 *   Count pp_assemblage components for assemblage 1 and allocate space
 */
	count_comps = pp_assemblage_ptr1->count_comps;
	temp_pp_assemblage.count_comps = count_comps;
	temp_pp_assemblage.pure_phases = (struct pure_phase *) PHRQ_malloc ( (size_t) count_comps * sizeof(struct pure_phase));
	if (temp_pp_assemblage.pure_phases == NULL) malloc_error();
	memcpy( (void *) temp_pp_assemblage.pure_phases, 
	       (void *) pp_assemblage_ptr1->pure_phases,
	       (size_t) count_comps * sizeof(struct pure_phase) );
	for (i = 0; i < count_comps; i++) {
		temp_pp_assemblage.pure_phases[i].moles *= f1;
	}
/*
 *   Count pp_assemblage components for assemblage 1 and allocate space
 */
        count_comps1 = count_comps;
	if (pp_assemblage_ptr2 != NULL) {
		count_comps2 = pp_assemblage_ptr2->count_comps;
		for(i = 0; i < count_comps2; i++) {
			found = FALSE;
			for(j = 0; j < count_comps1; j++) {

				/* pure phase in both assemblages */
				if (pp_assemblage_ptr2->pure_phases[i].phase ==
				    pp_assemblage_ptr1->pure_phases[j].phase) {

					found = TRUE;
					temp_pp_assemblage.pure_phases[j].moles = temp_pp_assemblage.pure_phases[j].moles + pp_assemblage_ptr2->pure_phases[i].moles * f2;
					temp_pp_assemblage.pure_phases[j].si = temp_pp_assemblage.pure_phases[j].si * f1 + pp_assemblage_ptr2->pure_phases[i].si * f2;
					temp_pp_assemblage.pure_phases[j].delta = temp_pp_assemblage.pure_phases[j].delta * f1 + pp_assemblage_ptr2->pure_phases[i].delta * f2;
					if (pp_assemblage_ptr2->pure_phases[i].add_formula !=
					    pp_assemblage_ptr1->pure_phases[j].add_formula) {
						sprintf(error_string, "Add formula for phase %s not the same. Can not mix phase assemblages. ", pp_assemblage_ptr2->pure_phases[i].name);
						error_msg(error_string, CONTINUE);
						input_error++;
						break;
					}
				}
			}
			if (found == FALSE ) {
				/* pure phase not in both assemblages */
				temp_pp_assemblage.pure_phases = (struct pure_phase *) PHRQ_realloc (temp_pp_assemblage.pure_phases, (size_t) (count_comps + 1) * sizeof(struct pure_phase));
				if (temp_pp_assemblage.pure_phases == NULL) malloc_error();
				memcpy( (void *) &temp_pp_assemblage.pure_phases[count_comps], 
					(void *) &pp_assemblage_ptr2->pure_phases[i],
					(size_t) sizeof(struct pure_phase) );
				temp_pp_assemblage.pure_phases[count_comps].moles *= f2;
				count_comps++;
			}
		}
	}
	temp_pp_assemblage.count_comps = count_comps;
/*
 *   Finish up
 */
	pp_assemblage_ptr = target;
	if (pp_assemblage_ptr == NULL) {
		sprintf(error_string, "Target pp_assemblage pointer is NULL in sum_pp_assemblage");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	}
	memcpy(pp_assemblage_ptr, &temp_pp_assemblage, sizeof(struct pp_assemblage));
	return(OK);
}
/* ---------------------------------------------------------------------- */
int sum_gas_phase (struct gas_phase *source1, LDBLE f1, struct gas_phase *source2, LDBLE f2, struct gas_phase *target)
/* ---------------------------------------------------------------------- */
{
/*
 *   sums two gas_phases, saves result in target
 */
	int i, j;
	int new_n_user, found;
	struct gas_phase temp_gas_phase, *gas_phase_ptr;

	struct gas_phase *gas_phase_ptr1, *gas_phase_ptr2;
	char token[MAX_LENGTH];
	int count_comps, count_comps1, count_comps2;

/*
 *   Find gas_phases
 */	
	gas_phase_ptr1 = source1;
	if (gas_phase_ptr1 == NULL) {
		sprintf(error_string, "Null pointer for gas_phase 1 in sum_gas_phase.");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	gas_phase_ptr2 = source2;
/*	
 *   Logical checks
 */
	if (gas_phase_ptr2 != NULL) {
		if (gas_phase_ptr2->type != gas_phase_ptr1->type) {
			sprintf(error_string, "One gas phase is fixed volume and one is fixed pressure. Can not mix gas phases.");
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		}
	}
/*
 *   Store data for structure gas_phase
 */
	new_n_user = gas_phase_ptr1->n_user;
	temp_gas_phase.n_user = new_n_user;
	temp_gas_phase.n_user_end = new_n_user;
	sprintf(token, "Copy");
	temp_gas_phase.description = string_duplicate(token);
	temp_gas_phase.new_def = gas_phase_ptr1->new_def;
	temp_gas_phase.solution_equilibria = FALSE;
	temp_gas_phase.n_solution = -99;
	temp_gas_phase.type = gas_phase_ptr1->type;

	temp_gas_phase.total_p = gas_phase_ptr1->total_p*f1;
	temp_gas_phase.total_moles = gas_phase_ptr1->total_moles*f1;
	temp_gas_phase.volume = gas_phase_ptr1->volume*f1;
	temp_gas_phase.temperature = gas_phase_ptr1->temperature*f1;

	if (gas_phase_ptr2 != NULL) {
		temp_gas_phase.total_p += gas_phase_ptr2->total_p*f2;
		temp_gas_phase.total_moles += gas_phase_ptr2->total_moles*f2;
		temp_gas_phase.volume += gas_phase_ptr2->volume*f2;
		temp_gas_phase.temperature += gas_phase_ptr2->temperature*f2;
	}
/*
 *   Count gas_phase components for assemblage 1 and allocate space
 */
	count_comps = gas_phase_ptr1->count_comps;
	temp_gas_phase.count_comps = count_comps;
	temp_gas_phase.comps = (struct gas_comp *) PHRQ_malloc ( (size_t) count_comps * sizeof(struct gas_comp));
	if (temp_gas_phase.comps == NULL) malloc_error();
	memcpy( (void *) temp_gas_phase.comps, 
	       (void *) gas_phase_ptr1->comps,
	       (size_t) count_comps * sizeof(struct gas_comp) );
	for (i = 0; i < count_comps; i++) {
		temp_gas_phase.comps[i].p_read *= f1;
		temp_gas_phase.comps[i].moles *= f1;
	}
/*
 *   Count gas_phase components for assemblage 1 and allocate space
 */
        count_comps1 = count_comps;
	if (gas_phase_ptr2 != NULL) {
		count_comps2 = gas_phase_ptr2->count_comps;
		for(i = 0; i < count_comps2; i++) {
			found = FALSE;
			for(j = 0; j < count_comps1; j++) {

				/* gas component in both gas phases */
				if (gas_phase_ptr2->comps[i].phase ==
				    gas_phase_ptr1->comps[j].phase) {

					found = TRUE;
					temp_gas_phase.comps[j].moles = temp_gas_phase.comps[j].moles + gas_phase_ptr2->comps[i].moles * f2;
					temp_gas_phase.comps[j].p_read = temp_gas_phase.comps[j].p_read + gas_phase_ptr2->comps[i].p_read * f2;
					break;
				}
			}
			if (found == FALSE ) {

				/* gas component phase not in both assemblages */
				temp_gas_phase.comps = (struct gas_comp *) PHRQ_realloc (temp_gas_phase.comps, (size_t) (count_comps + 1) * sizeof(struct gas_comp));
				if (temp_gas_phase.comps == NULL) malloc_error();
				memcpy( (void *) &temp_gas_phase.comps[count_comps], 
					(void *) &gas_phase_ptr2->comps[i],
					(size_t) sizeof(struct gas_comp) );
				temp_gas_phase.comps[count_comps].moles *= f2;
				count_comps++;
			}
		}
	}
	temp_gas_phase.count_comps = count_comps;
/*
 *   Finish up
 */
	gas_phase_ptr = target;
	if (gas_phase_ptr == NULL) {
		sprintf(error_string, "Target gas_phase is NULL in sum_gas_phase");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	}
	memcpy(gas_phase_ptr, &temp_gas_phase, sizeof(struct gas_phase));
	return(OK);
}
/* ---------------------------------------------------------------------- */
int sum_s_s_assemblage (struct s_s_assemblage *source1, LDBLE f1, struct s_s_assemblage *source2, LDBLE f2, struct s_s_assemblage *target)

/* ---------------------------------------------------------------------- */
{
/*
 *   sums two s_s_assemblages, saves result in target
 */
	int i, j, k, l;
	int count_s_s, count_s_s1, count_s_s2;
	int i1, i2, k1, k2;
	int new_n_user, found, found_comp;
	struct s_s_assemblage temp_s_s_assemblage, *s_s_assemblage_ptr;

	struct s_s_assemblage *s_s_assemblage_ptr1, *s_s_assemblage_ptr2;
	char token[MAX_LENGTH];
	int count_comps1, count_comps2;

/*
 *   Find s_s_assemblagers
 */	
	s_s_assemblage_ptr1 = source1;
	if (s_s_assemblage_ptr1 == NULL) {
		sprintf(error_string, "Null pointer for s_s_assemblage 1 in sum_s_s_assemblage.");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	s_s_assemblage_ptr2 = source2;
/*
 *   Store data for structure s_s_assemblage
 */
	new_n_user = s_s_assemblage_ptr1->n_user;
	s_s_assemblage_copy(s_s_assemblage_ptr1, &temp_s_s_assemblage, new_n_user);
	free_check_null(temp_s_s_assemblage.description);
	sprintf(token, "Copy");
	temp_s_s_assemblage.description = string_duplicate(token);
/*
 *   Count s_s_assemblage s_s for assemblage 1
 */
	count_s_s = s_s_assemblage_ptr1->count_s_s;
	temp_s_s_assemblage.count_s_s = count_s_s;
	for (i = 0; i < count_s_s; i++) {
		temp_s_s_assemblage.s_s[i].total_moles *= f1;
		for (j = 0; j < temp_s_s_assemblage.s_s[i].count_comps; j++) {
			temp_s_s_assemblage.s_s[i].comps[j].initial_moles *= f1;
			temp_s_s_assemblage.s_s[i].comps[j].moles *= f1;
			temp_s_s_assemblage.s_s[i].comps[j].delta *= f1;
		}
	}
/*
 *   Add s_s from assemblage 2 
 */
        count_s_s1 = count_s_s;
	if (s_s_assemblage_ptr2 != NULL) {
		count_s_s2 = s_s_assemblage_ptr2->count_s_s;
		for(i2 = 0; i2 < count_s_s2; i2++) {
			found = FALSE;
			count_comps2 = s_s_assemblage_ptr2->s_s[i2].count_comps;
			for(i1 = 0; i1 < count_s_s1; i1++) {

				/* solid solution in both assemblages */
				if (strcmp_nocase(s_s_assemblage_ptr2->s_s[i2].name, s_s_assemblage_ptr1->s_s[i1].name) == 0) {

					found = TRUE;
					count_comps1 = s_s_assemblage_ptr1->s_s[i1].count_comps;
					temp_s_s_assemblage.s_s[i1].total_moles += s_s_assemblage_ptr2->s_s[i2].total_moles * f2;
					if (count_comps1 != count_comps2) {
						sprintf(error_string, "Solid solution %s has different number of components for assemblages. Can not mix assemblages.", s_s_assemblage_ptr2->s_s[i2].name);
						error_msg(error_string, CONTINUE);
						input_error++;
						return(ERROR);
					}
					/* update each component */
					for (k2 = 0; k2 < count_comps2; k2++) {
						found_comp = FALSE;
						for (k1 = 0; k1 < count_comps1; k1++) {
							if (s_s_assemblage_ptr2->s_s[i2].comps[k2].phase == s_s_assemblage_ptr1->s_s[i1].comps[k1].phase) {
								temp_s_s_assemblage.s_s[i1].comps[k1].moles += s_s_assemblage_ptr2->s_s[i2].comps[k2].moles * f2;
								found_comp = TRUE;
								break;
							}
						}
						if (found_comp == FALSE) {
							sprintf(error_string, "Solid solution %s has different components in assemblages. Can not mix assemblages.", s_s_assemblage_ptr2->s_s[i2].name);
							error_msg(error_string, CONTINUE);
							input_error++;
							return(ERROR);
						}
					}
				}
			}
			if (found == FALSE ) {

				/* solid solution only in assemblage 2, add to combined assemblage */
				/* copy s_s */
				temp_s_s_assemblage.s_s = (struct s_s *) PHRQ_realloc (temp_s_s_assemblage.s_s, (size_t) (count_s_s + 1) * sizeof(struct s_s));
				if (temp_s_s_assemblage.s_s == NULL) malloc_error();
				memcpy( (void *) &temp_s_s_assemblage.s_s[count_s_s], 
					(void *) &s_s_assemblage_ptr2->s_s[i2],
					(size_t) sizeof(struct s_s) );
				temp_s_s_assemblage.s_s[count_s_s].total_moles *= f2;

				/* copy components */
				count_comps2 = s_s_assemblage_ptr2->s_s[i2].count_comps;
				temp_s_s_assemblage.s_s[count_s_s].comps = PHRQ_malloc((size_t) (count_comps2 * sizeof(struct s_s_comp)));
				if (temp_s_s_assemblage.s_s[count_s_s].comps == NULL) malloc_error();
				memcpy( (void *) temp_s_s_assemblage.s_s[count_s_s].comps, 
					(void *) s_s_assemblage_ptr2->s_s[i2].comps,
					(size_t) (count_comps2 * sizeof(struct s_s_comp)) );
				
				for (k2 = 0; k2 < count_comps2; k2++) {
					temp_s_s_assemblage.s_s[count_s_s].comps[k2].moles *= f2;
				}
				count_s_s++;
			}
		}
	}
	temp_s_s_assemblage.count_s_s = count_s_s;
/*
 *   Check phases
 */
	for (i = 0; i < count_s_s - 1; i++) {
		for (j = 0; j < temp_s_s_assemblage.s_s[i].count_comps; j++) {
			for (k = i+1; k < count_s_s; k++) {
				for (l = 0; l < temp_s_s_assemblage.s_s[k].count_comps; l++) {
					if (temp_s_s_assemblage.s_s[i].comps[j].phase == temp_s_s_assemblage.s_s[k].comps[l].phase) {
						sprintf(error_string, "Different solid solutions %s and %s have same phase %s in assemblages. Error mixing assemblages.", temp_s_s_assemblage.s_s[i].name, temp_s_s_assemblage.s_s[k].name, temp_s_s_assemblage.s_s[i].comps[j].name);
						error_msg(error_string, CONTINUE);
						input_error++;
						return(ERROR);
					}
				}
			}
		}
	}
						
/*
 *   Finish up
 */
	s_s_assemblage_ptr = target;
	if (s_s_assemblage_ptr == NULL) {
		sprintf(error_string, "Target s_s_assemblage is NULL in sum_s_s_assemblage");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	}
	memcpy(s_s_assemblage_ptr, &temp_s_s_assemblage, sizeof(struct s_s_assemblage));
	return(OK);
}
/* ---------------------------------------------------------------------- */
int sum_kinetics (struct kinetics *source1, LDBLE f1, struct kinetics *source2, LDBLE f2, struct kinetics *target)
/* ---------------------------------------------------------------------- */
{
/*
 *   sums two kinetics, saves result in target
 */
	int i, i1, i2;
	int new_n_user, found;
	struct kinetics temp_kinetics, *kinetics_ptr;

	struct kinetics *kinetics_ptr1, *kinetics_ptr2;
	char token[MAX_LENGTH];
	int count_comps, count_comps1, count_comps2;

/*
 *   Find kinetics
 */	
	kinetics_ptr1 = source1;
	if (kinetics_ptr1 == NULL) {
		sprintf(error_string, "Null pointer for s_s_assemblage 1 in sum_s_s_assemblage.");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	kinetics_ptr2 = source2;
/*
 *   Store data for structure kinetics
 */
	new_n_user = kinetics_ptr1->n_user;
	memcpy(&temp_kinetics, kinetics_ptr1, sizeof(struct kinetics));
	temp_kinetics.n_user = new_n_user;
	temp_kinetics.n_user_end = new_n_user;
	sprintf(token, "Copy");
	temp_kinetics.description = string_duplicate(token);
	temp_kinetics.steps = NULL;
	temp_kinetics.count_steps = 0;
/*
 *   Count kinetics components for assemblage 1 and allocate space
 */
	count_comps = kinetics_ptr1->count_comps;
	temp_kinetics.count_comps = count_comps;
	temp_kinetics.comps = (struct kinetics_comp *) PHRQ_malloc ( (size_t) count_comps * sizeof(struct kinetics_comp));
	if (temp_kinetics.comps == NULL) malloc_error();
	for (i = 0; i < count_comps; i++) {
		kinetics_comp_duplicate(&temp_kinetics.comps[i], &kinetics_ptr1->comps[i]);
		temp_kinetics.comps[i].m *= f1;
		temp_kinetics.comps[i].m0 *= f1;
		temp_kinetics.comps[i].moles *= f1;
	}
/*
 *   Add in kinetics_ptr2
 */
        count_comps1 = count_comps;
	if (kinetics_ptr2 != NULL) {
		count_comps2 = kinetics_ptr2->count_comps;
		for(i2 = 0; i2 < count_comps2; i2++) {
			found = FALSE;
			for(i1 = 0; i1 < count_comps1; i1++) {

				/* kinetics component in both kinetics assemblages */
				if (kinetics_ptr2->comps[i2].rate_name ==
				    kinetics_ptr1->comps[i1].rate_name) {

					found = TRUE;
					temp_kinetics.comps[i1].m += kinetics_ptr2->comps[i2].m * f2;
					temp_kinetics.comps[i1].m0 += kinetics_ptr2->comps[i2].m0 * f2;
					temp_kinetics.comps[i1].moles += kinetics_ptr2->comps[i2].moles * f2;
					break;
				}
			}
			if (found == FALSE ) {
				
				/* kinetics component not in both assemblages */
				temp_kinetics.comps = (struct kinetics_comp *) PHRQ_realloc (temp_kinetics.comps, (size_t) (count_comps + 1) * sizeof(struct kinetics_comp));
				if (temp_kinetics.comps == NULL) malloc_error();
				kinetics_comp_duplicate(&temp_kinetics.comps[count_comps], &kinetics_ptr2->comps[i2]);
				temp_kinetics.comps[count_comps].m *= f2;
				temp_kinetics.comps[count_comps].m0 *= f2;
				temp_kinetics.comps[count_comps].moles *= f2;
				count_comps++;
			}
		}
	}
	temp_kinetics.count_comps = count_comps;

	temp_kinetics.steps = NULL;
	temp_kinetics.totals = NULL;

/*
 *   Finish up
 */
	kinetics_ptr = target;
	if (kinetics_ptr == NULL) {
		sprintf(error_string, "Target kinetics is NULL in sum_kinetics");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	}
	memcpy(kinetics_ptr, &temp_kinetics, sizeof(struct kinetics));
	return(OK);
}
/* ---------------------------------------------------------------------- */
int sum_surface (struct surface *source1, LDBLE f1, struct surface *source2, LDBLE f2, struct surface *target)
/* ---------------------------------------------------------------------- */
{
/*
 *   mixes two surfacers, saves result in surface new_n_user
 */
	int i, i1, i2, j, l;
	int new_n_user, found;
	struct surface temp_surface, *surface_ptr;
	char *ptr;

	struct surface *surface_ptr1, *surface_ptr2;
	char token[MAX_LENGTH], name[MAX_LENGTH];
	int count_comps, count_comps1, count_comps2;
	int count_charge, count_charge1, count_charge2;

/*
 *   Find surfacers
 */	
	surface_ptr1 = source1;
	if (surface_ptr1 == NULL) {
		sprintf(error_string, "Null pointer for surface 1 in sum_surface.");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	surface_ptr2 = source2;
/*	
 *   Logical checks
 */
	if (surface_ptr2 != NULL) {
		if (surface_ptr1->diffuse_layer != surface_ptr2->diffuse_layer) {
			sprintf(error_string, "Surfaces differ in definition of diffuse layer. Can not mix.");
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		}
		if (surface_ptr1->edl != surface_ptr2->edl) {
			sprintf(error_string, "Surfaces differ in use of electrical double layer. Can not mix.");
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		}
		if (surface_ptr1->only_counter_ions != surface_ptr2->only_counter_ions) {
			sprintf(error_string, "Surfaces differ in use of only counter ions in the diffuse layer. Can not mix.");
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		}
		if (surface_ptr1->related_phases != surface_ptr2->related_phases) {
			sprintf(error_string, "Surfaces differ in use of related phases (sites proportional to moles of an equilibrium phase). Can not mix.");
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		}
		if (surface_ptr1->related_rate != surface_ptr2->related_rate) {
			sprintf(error_string, "Surfaces differ in use of related rate (sites proportional to moles of a kinetic reactant). Can not mix.");
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		}
	}
/*
 *   Store data for structure surface
 */
	new_n_user = surface_ptr1->n_user;
	surface_copy(surface_ptr1, &temp_surface, new_n_user);
	sprintf(token, "Copy");
	free_check_null(temp_surface.description);
	temp_surface.description = string_duplicate(token);
	temp_surface.solution_equilibria = FALSE;
	temp_surface.n_solution = -99;
/*
 *   Multiply component compositions by f1
 */
	for (i = 0; i < surface_ptr1->count_comps; i++) {
		temp_surface.comps[i].moles *= f1;
		temp_surface.comps[i].cb *= f1;
		count_elts = 0;
		add_elt_list(surface_ptr1->comps[i].totals, f1);
		free_check_null(temp_surface.comps[i].totals);
		temp_surface.comps[i].totals = elt_list_save();
	}
	if (temp_surface.edl == TRUE) {
		for (i = 0; i < surface_ptr1->count_charge; i++) {
			temp_surface.charge[i].grams *= f1;
			temp_surface.charge[i].charge_balance *= f1;
			temp_surface.charge[i].mass_water *= f1;
			temp_surface.charge[i].g = NULL;
			temp_surface.charge[i].count_g = 0;
			count_elts = 0;
			if (surface_ptr1->charge[i].diffuse_layer_totals != NULL) {
				add_elt_list(surface_ptr1->charge[i].diffuse_layer_totals, f1);
				free_check_null(temp_surface.charge[i].diffuse_layer_totals);
				temp_surface.charge[i].diffuse_layer_totals = elt_list_save();
			} else {
				temp_surface.charge[i].diffuse_layer_totals = NULL;
			}
		}
	}
/*
 *   Add in surface_ptr2
 */

	count_comps = surface_ptr1->count_comps;
        count_comps1 = surface_ptr1->count_comps;
	count_charge = surface_ptr1->count_charge;
        count_charge1 = surface_ptr1->count_charge;
	if (surface_ptr2 != NULL) {
		count_comps2 = surface_ptr2->count_comps;
		count_charge2 = surface_ptr2->count_charge;

		for(i2 = 0; i2 < count_comps2; i2++) {
			found = FALSE;

			/*
			 *  Now handle comps
			 */
			for(i1 = 0; i1 < count_comps1; i1++) {

				/* surface component in both surface assemblages */
				if (surface_ptr2->comps[i2].formula == surface_ptr1->comps[i1].formula) {
					found = TRUE;
					if ((surface_ptr1->comps[i1].phase_name != NULL && surface_ptr2->comps[i2].phase_name == NULL) ||
					    (surface_ptr1->comps[i1].phase_name == NULL && surface_ptr2->comps[i2].phase_name != NULL)) {
						sprintf(error_string, "Surfaces differ in use of related phases (sites proportional to moles of an equilibrium phase). Can not mix.");
						error_msg(error_string, CONTINUE);
						input_error++;
						return(ERROR);
					} else if (surface_ptr1->comps[i1].phase_name != NULL && surface_ptr2->comps[i2].phase_name != NULL && strcmp_nocase(surface_ptr1->comps[i1].phase_name, surface_ptr2->comps[i2].phase_name) != 0) {
						sprintf(error_string, "Surfaces differ in use of related phases (sites proportional to moles of an equilibrium phase). Can not mix.");
						error_msg(error_string, CONTINUE);
						input_error++;
						return(ERROR);
					}
					if ((surface_ptr1->comps[i1].rate_name != NULL && surface_ptr2->comps[i2].rate_name == NULL) ||
					    (surface_ptr1->comps[i1].rate_name == NULL && surface_ptr2->comps[i2].rate_name != NULL)) {
						sprintf(error_string, "Surfaces differ in use of related rate (sites proportional to moles of a kinetic reactant). Can not mix.");
						error_msg(error_string, CONTINUE);
						input_error++;
						return(ERROR);
					} else if (surface_ptr1->comps[i1].rate_name != NULL && surface_ptr2->comps[i2].rate_name != NULL && strcmp_nocase(surface_ptr1->comps[i1].rate_name, surface_ptr2->comps[i2].rate_name) != 0) {
						sprintf(error_string, "Surfaces differ in use of related rates (sites proportional to moles of a kinetic reactant). Can not mix.");
						error_msg(error_string, CONTINUE);
						input_error++;
						return(ERROR);
					}
					temp_surface.comps[i1].moles += surface_ptr2->comps[i2].moles * f2;
					/* set below */
					/* temp_surface.comps[i1].charge += surface_ptr2->comps[i2].charge * f2; */
					count_elts = 0;
					add_elt_list(temp_surface.comps[i1].totals, 1.0);
					add_elt_list(surface_ptr2->comps[i2].totals, f2);
					free_check_null(temp_surface.comps[i1].totals);
					temp_surface.comps[i1].totals = elt_list_save();
					break;
				}
			}

			if (found == FALSE ) {

				/* surface component not in both assemblages */
				temp_surface.comps = (struct surface_comp *) PHRQ_realloc (temp_surface.comps, (size_t) (count_comps + 1) * sizeof(struct surface_comp));
				if (temp_surface.comps == NULL) malloc_error();
				memcpy(&temp_surface.comps[count_comps], &surface_ptr2->comps[i2], sizeof(struct surface_comp));
				temp_surface.comps[count_comps].moles *= f2;
				temp_surface.comps[count_comps].cb *= f2;
				count_elts = 0;
				add_elt_list(surface_ptr2->comps[i2].totals, f2);
				temp_surface.comps[count_comps].totals = elt_list_save();
				count_comps++;
			}
		}
		/*
		 *  Now handle charge
		 */
		if (temp_surface.edl == TRUE) {
			for(i2 = 0; i2 < count_charge2; i2++) {
				found = FALSE;
				for(i1 = 0; i1 < count_charge1; i1++) {

					/* surface charge in both surface assemblages */
					if (surface_ptr2->charge[i2].name == surface_ptr1->charge[i1].name) {
						found = TRUE;
						temp_surface.charge[i1].grams += surface_ptr2->charge[i2].grams * f2;
						temp_surface.charge[i1].charge_balance += surface_ptr2->charge[i2].charge_balance * f2;
						temp_surface.charge[i1].mass_water += surface_ptr2->charge[i2].mass_water * f2;
						count_elts = 0;
						add_elt_list(temp_surface.charge[i1].diffuse_layer_totals, 1.0);
						add_elt_list(surface_ptr2->charge[i2].diffuse_layer_totals, f2);
						free_check_null(temp_surface.charge[i1].diffuse_layer_totals);
						temp_surface.charge[i1].diffuse_layer_totals = elt_list_save();
						break;
					}
				}
			
				if (found == FALSE ) {

					/* surface charge not in both assemblages */
					temp_surface.charge = (struct surface_charge *) PHRQ_realloc (temp_surface.charge, (size_t) (count_charge + 1) * sizeof(struct surface_charge));
					if (temp_surface.charge == NULL) malloc_error();
					memcpy(&temp_surface.charge[count_charge], &surface_ptr2->charge[i2], sizeof(struct surface_charge));
					temp_surface.charge[count_charge].grams *= f2;
					temp_surface.charge[count_charge].charge_balance *= f2;
					temp_surface.charge[count_charge].mass_water *= f2;
					temp_surface.charge[count_charge].g = NULL;
					temp_surface.charge[count_charge].count_g = 0;
					count_elts = 0;
					add_elt_list(surface_ptr2->charge[i2].diffuse_layer_totals, f2);
					temp_surface.charge[count_charge].diffuse_layer_totals = elt_list_save();
					count_charge++;
				}
			}
		}
	}
	temp_surface.count_comps = count_comps;
	temp_surface.count_charge = count_charge;
/*
 *   set charge, integer number of position in charge structures
 */	
	if (temp_surface.edl == TRUE) {
		for (i = 0; i < count_comps; i++) {
			strcpy(token, temp_surface.comps[i].formula);
			ptr = token;
			get_elt(&ptr, name, &l);
			ptr = strchr(name,'_');
			if (ptr != NULL) ptr[0] = '\0';
			for (j = 0; j < count_charge; j++) {
				if (strcmp(temp_surface.charge[j].name, name) == 0) break;
			}
			if (j == count_charge) {
				sprintf(error_string, "Mixed surfaces. Did not find expected charge structure.");
				error_msg(error_string, CONTINUE);
				input_error++;
				return(ERROR);
			} else {
				temp_surface.comps[i].charge = j;
			}
		}
	}
			
/*
 *   Finish up
 */
	surface_ptr = target;
	if (surface_ptr == NULL) {
		sprintf(error_string, "Target kinetics is NULL in sum_kinetics");
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	}
	memcpy(surface_ptr, &temp_surface, sizeof(struct surface));
	return(OK);
}
/* ---------------------------------------------------------------------- */
int xsolution_save_hst_ptr(struct solution *solution_ptr)
/* ---------------------------------------------------------------------- */
{
/*
 *   Save solution composition into structure solution n
 *
 *   input:  n is pointer number in solution
 */
	int i, j;

	solution_ptr->totals = PHRQ_realloc (solution_ptr->totals, (size_t) (count_total - 1) * sizeof(struct conc));
	solution_ptr->master_activity = PHRQ_realloc (solution_ptr->master_activity, (size_t) (count_activity_list + 1) * sizeof(struct master_activity));
	solution_ptr->count_master_activity = count_activity_list;
	solution_ptr->ph = ph_x;
	solution_ptr->solution_pe = solution_pe_x;
	solution_ptr->mu = mu_x;
	solution_ptr->ah2o = ah2o_x;
	solution_ptr->density = density_x;
	solution_ptr->total_h = total_h_x;
	solution_ptr->total_o = total_o_x;
	solution_ptr->total_alkalinity = total_alkalinity;
	/*solution_ptr->total_co2 = total_co2 / mass_water_aq_x;*/
	solution_ptr->cb = cb_x;   /* cb_x does not include surface charge */
	solution_ptr->mass_water = mass_water_aq_x;
/*
 *   Copy totals data
 */
	for (j = 2; j < count_total; j++) {
		solution_ptr->totals[j-2].moles = buffer[j].master->total_primary;
		solution_ptr->totals[j-2].description = buffer[j].master->elt->name;
/*		solution_ptr->totals[j-2].input_conc = master[i]->total; */
/*		solution_ptr->totals[j-2].skip = FALSE; */
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

	if (pitzer_model == TRUE) {
		i = 0;
		for (j = 0; j < count_s; j++) {
			if (s[j]->lg != 0.0) i++;
		}
		solution_ptr->species_gamma = PHRQ_realloc(solution_ptr->species_gamma, (size_t) (i * sizeof(struct master_activity)));
		if (solution_ptr->species_gamma == NULL) malloc_error();
		i = 0;
		for (j= 0; j < count_s; j++) {
			if (s[j]->lg != 0.0) {
				solution_ptr->species_gamma[i].la = s[j]->lg;
				solution_ptr->species_gamma[i].description = s[j]->name;
				i++;
			}
		}
		solution_ptr->count_species_gamma = i;
	} else {
		solution_ptr->species_gamma = NULL;
		solution_ptr->count_species_gamma = 0;
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int mix_solutions (int n_user1, int n_user2, LDBLE f1, int n_user_new, char *conditions)
/* ---------------------------------------------------------------------- */
{
/*
 *   mixes two solutions, saves result in solution -1
 */
	int i, j, n1, n2;
	int return_code;

	LDBLE intensive, extensive, f2;
	struct solution *solution_ptr, *solution_ptr1, *solution_ptr2;
/*
 *   Zero out global solution data
 */
	xsolution_zero();
/*
 *
 */	
	return_code = OK;
	f2 = 1.0 - f1;
	solution_ptr1 = solution_bsearch (n_user1, &n1, TRUE);
	if (solution_ptr1 == NULL) {
		sprintf(error_string, "Solution %d not found while processing %s conditions.", n_user1, conditions);
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	solution_ptr2 = NULL;
	if (n_user2 >= 0) {
		solution_ptr2 = solution_bsearch (n_user2, &n2, TRUE);
		if (solution_ptr2 == NULL) {
			sprintf(error_string, "Solution %d not found while processing %s conditions.", n_user1, conditions);
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		} 
	} 
	extensive = f1;
	intensive = f1;
	add_solution(solution_ptr1, extensive, intensive);
	if (solution_ptr2 != NULL) {
		extensive = f2;
		intensive = f2;
		add_solution(solution_ptr2, extensive, intensive);
	}
	xsolution_save(n_user_new);
/*
 *   Realloc space for totals and activities for all solutions to make 
 *   enough room during hst simulation, put array in standard form
 */
	solution_ptr = solution_bsearch (n_user_new, &i, TRUE);
	xsolution_zero();
	if (solution[i]->mass_water <= 0.0) {
		sprintf(error_string, "Mass of water is %e in mix_solutions.\n n_user1 %d, n_user2 %d, n_user_new %d, f %e, Conditions %s", (double) solution[i]->mass_water, n_user1, n_user2,  n_user_new, (double) f1, conditions);
		error_msg(error_string, STOP);
	}
	add_solution(solution[i], (LDBLE) 1.0/solution[i]->mass_water, (LDBLE) 1.0);
	solution[i]->totals = PHRQ_realloc (solution[i]->totals, (size_t) (count_total - 1) * sizeof(struct conc));
	if (solution[i]->totals == NULL) malloc_error();
	solution[i]->master_activity = PHRQ_realloc (solution[i]->master_activity, (size_t) (count_activity_list + 1) * sizeof(struct master_activity));
	if (solution[i]->master_activity == NULL) malloc_error();
	solution[i]->count_master_activity = count_activity_list;
	for(j = 2; j < count_total; j++) {
		buffer[j].master->total_primary = buffer[j].master->total;
	}
	xsolution_save_hst(i);
	return(return_code);
}
/* ---------------------------------------------------------------------- */
int mix_exchange (int n_user1, int n_user2, LDBLE f1, int new_n_user)
/* ---------------------------------------------------------------------- */
{
/*
 *   mixes two exchangers, saves result in exchange new_n_user
 */
	int n;
	int n1, n2;
	int return_code;
	struct exchange temp_exchange, *exchange_ptr;

	LDBLE f2;
	struct exchange *exchange_ptr1, *exchange_ptr2;

	return_code = OK;
/*
 *   Find exchangers
 */	
	f2 = 1.0 - f1;
	exchange_ptr1 = exchange_bsearch (n_user1, &n1);
	if (exchange_ptr1 == NULL) {
		sprintf(error_string, "Exchange %d not found while processing initial conditions.", n_user1);
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	if (n_user2 >= 0) {
		exchange_ptr2 = exchange_bsearch (n_user2, &n2);
		if (exchange_ptr2 == NULL) {
			sprintf(error_string, "Exchange %d not found while processing initial conditions.", n_user2);
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		} 
	} else {
		exchange_duplicate(exchange_ptr1->n_user, new_n_user);
		return(OK);
	}
/*	
 *   Logical checks
 */
	if (sum_exchange(exchange_ptr1, f1, exchange_ptr2, f2, &temp_exchange) == ERROR) {
		return(ERROR);
	}
/*
 *   Store data for structure exchange
 */
	temp_exchange.n_user = new_n_user;
	temp_exchange.n_user_end = new_n_user;
	temp_exchange.new_def = TRUE;
/*
 *   Finish up
 */
	exchange_ptr = exchange_bsearch(new_n_user, &n);
	if (exchange_ptr == NULL) {
		n = count_exchange++;
		space ((void *) &exchange, count_exchange, &max_exchange, sizeof(struct exchange));
	} else {
		exchange_free(&exchange[n]); 
	}
	memcpy(&exchange[n], &temp_exchange, sizeof(struct exchange));
	/* sort only if necessary */
	if (n == count_exchange - 1 && count_exchange > 1) {
		if (exchange[n].n_user < exchange[n-1].n_user) {
			qsort (exchange,
			       (size_t) count_exchange,
			       (size_t) sizeof (struct exchange),
			       exchange_compare);
		}
	}

	return(return_code);
}
/* ---------------------------------------------------------------------- */
int mix_pp_assemblage (int n_user1, int n_user2, LDBLE f1, int new_n_user)
/* ---------------------------------------------------------------------- */
{
/*
 *   mixes two pp_assemblages, saves result in pp_assemblage new_n_user
 */
	int n;
	int n1, n2;
	int return_code;
	struct pp_assemblage temp_pp_assemblage, *pp_assemblage_ptr;

	LDBLE f2;
	struct pp_assemblage *pp_assemblage_ptr1, *pp_assemblage_ptr2;

	return_code = OK;
/*
 *   Find pp_assemblagers
 */	
	f2 = 1.0 - f1;
	pp_assemblage_ptr1 = pp_assemblage_bsearch (n_user1, &n1);
	if (pp_assemblage_ptr1 == NULL) {
		sprintf(error_string, "Pure phase assemblage %d not found while processing initial conditions.", n_user1);
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	if (n_user2 >= 0) {
		pp_assemblage_ptr2 = pp_assemblage_bsearch (n_user2, &n2);
		if (pp_assemblage_ptr2 == NULL) {
			sprintf(error_string, "Pure phase assemblage %d not found while processing initial conditions.", n_user2);
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		} 
	} else {
		pp_assemblage_duplicate(pp_assemblage_ptr1->n_user, new_n_user);
		return(OK);
	}
/*	
 *   Logical checks
 */
	if (sum_pp_assemblage(pp_assemblage_ptr1, f1, pp_assemblage_ptr2, f2, &temp_pp_assemblage) == ERROR) {
		return(ERROR);
	}
/*
 *   Store data for structure pp_assemblage
 */
	temp_pp_assemblage.n_user = new_n_user;
	temp_pp_assemblage.n_user_end = new_n_user;
	temp_pp_assemblage.new_def = pp_assemblage_ptr1->new_def;
/*
 *   Finish up
 */
	pp_assemblage_ptr = pp_assemblage_bsearch(new_n_user, &n);
	if (pp_assemblage_ptr == NULL) {
		space ((void *) &pp_assemblage, count_pp_assemblage, &max_pp_assemblage, sizeof(struct pp_assemblage));
		n = count_pp_assemblage++;
	} else {
		pp_assemblage_free(&pp_assemblage[n]); 
	}
	memcpy(&pp_assemblage[n], &temp_pp_assemblage, sizeof(struct pp_assemblage));
	/* sort only if necessary */
	if (n == count_pp_assemblage - 1 && count_pp_assemblage > 1) {
		if (pp_assemblage[n].n_user < pp_assemblage[n-1].n_user) {
			qsort (pp_assemblage,
			       (size_t) count_pp_assemblage,
			       (size_t) sizeof (struct pp_assemblage),
			       pp_assemblage_compare);
		}
	}
	return(return_code);
}
/* ---------------------------------------------------------------------- */
int mix_gas_phase (int n_user1, int n_user2, LDBLE f1, int new_n_user)
/* ---------------------------------------------------------------------- */
{
/*
 *   mixes two gas_phases, saves result in gas_phase new_n_user
 */
	int n;
	int n1, n2;
	int return_code;
	struct gas_phase temp_gas_phase, *gas_phase_ptr;

	LDBLE f2;
	struct gas_phase *gas_phase_ptr1, *gas_phase_ptr2;

	return_code = OK;
/*
 *   Find gas_phases
 */	
	f2 = 1.0 - f1;
	gas_phase_ptr1 = gas_phase_bsearch (n_user1, &n1);
	if (gas_phase_ptr1 == NULL) {
		sprintf(error_string, "Gas phase %d not found while processing initial conditions.", n_user1);
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	if (n_user2 >= 0) {
		gas_phase_ptr2 = gas_phase_bsearch (n_user2, &n2);
		if (gas_phase_ptr2 == NULL) {
			sprintf(error_string, "Gas phase %d not found while processing initial conditions.", n_user2);
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		} 
	} else {
		gas_phase_duplicate(gas_phase_ptr1->n_user, new_n_user);
		return(OK);
	}
/*	
 *   Logical checks
 */
	if (gas_phase_ptr2->type != gas_phase_ptr1->type) {
		sprintf(error_string, "One gas phase is fixed volume and one is fixed pressure. Can not mix gas phases %d and %d.", n_user1, n_user2);
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	}
	if (sum_gas_phase(gas_phase_ptr1, f1, gas_phase_ptr2, f2, &temp_gas_phase) == ERROR) {
		return(ERROR);
	}

/*
 *   Store data for structure gas_phase
 */
	temp_gas_phase.n_user = new_n_user;
	temp_gas_phase.n_user_end = new_n_user;
	temp_gas_phase.new_def = gas_phase_ptr1->new_def;
/*
 *   Finish up
 */
	gas_phase_ptr = gas_phase_bsearch(new_n_user, &n);
	if (gas_phase_ptr == NULL) {
		n = count_gas_phase++;
		space ((void *) &gas_phase, count_gas_phase, &max_gas_phase, sizeof(struct gas_phase));
	} else {
		gas_phase_free(&gas_phase[n]); 
	}
	memcpy(&gas_phase[n], &temp_gas_phase, sizeof(struct gas_phase));
	/* sort only if necessary */
	if (n == count_gas_phase - 1 && count_gas_phase > 1) {
		if (gas_phase[n].n_user < gas_phase[n-1].n_user) {
			qsort (gas_phase,
			       (size_t) count_gas_phase,
			       (size_t) sizeof (struct gas_phase),
			       gas_phase_compare);
		}
	}
	return(return_code);
}
/* ---------------------------------------------------------------------- */
int mix_s_s_assemblage (int n_user1, int n_user2, LDBLE f1, int new_n_user)
/* ---------------------------------------------------------------------- */
{
/*
 *   mixes two s_s_assemblages, saves result in s_s_assemblage new_n_user
 */
	int n;
	int n1, n2;
	int return_code;
	struct s_s_assemblage temp_s_s_assemblage, *s_s_assemblage_ptr;

	LDBLE f2;
	struct s_s_assemblage *s_s_assemblage_ptr1, *s_s_assemblage_ptr2;

	return_code = OK;
/*
 *   Find s_s_assemblagers
 */	
	f2 = 1.0 - f1;
	s_s_assemblage_ptr1 = s_s_assemblage_bsearch (n_user1, &n1);
	if (s_s_assemblage_ptr1 == NULL) {
		sprintf(error_string, "Solid solution assemblage %d not found while processing initial conditions.", n_user1);
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	if (n_user2 >= 0) {
		s_s_assemblage_ptr2 = s_s_assemblage_bsearch (n_user2, &n2);
		if (s_s_assemblage_ptr2 == NULL) {
			sprintf(error_string, "Solid solution assemblage %d not found while processing initial conditions.", n_user2);
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		} 
	} else {
		s_s_assemblage_duplicate(s_s_assemblage_ptr1->n_user, new_n_user);
		return(OK);
	}
/*	
 *   Logical checks
 */
	if (sum_s_s_assemblage(s_s_assemblage_ptr1, f1, s_s_assemblage_ptr2, f2, &temp_s_s_assemblage) == ERROR) {
		return(ERROR);
	}

/*
 *   Store data for structure s_s_assemblage
 */
	temp_s_s_assemblage.n_user = new_n_user;
	temp_s_s_assemblage.n_user_end = new_n_user;
/*
 *   Finish up
 */
	s_s_assemblage_ptr = s_s_assemblage_bsearch(new_n_user, &n);
	if (s_s_assemblage_ptr == NULL) {
		space ((void *) &s_s_assemblage, count_s_s_assemblage, &max_s_s_assemblage, sizeof(struct s_s_assemblage));
		n = count_s_s_assemblage++;
	} else {
		s_s_assemblage_free(&s_s_assemblage[n]); 
	}
	memcpy(&s_s_assemblage[n], &temp_s_s_assemblage, sizeof(struct s_s_assemblage));
	/* sort only if necessary */
	if (n == count_s_s_assemblage - 1 && count_s_s_assemblage > 1) {
		if (s_s_assemblage[n].n_user < s_s_assemblage[n-1].n_user) {
			qsort (s_s_assemblage,
			       (size_t) count_s_s_assemblage,
			       (size_t) sizeof (struct s_s_assemblage),
			       s_s_assemblage_compare);
		}
	}
	return(return_code);
}
/* ---------------------------------------------------------------------- */
int mix_kinetics (int n_user1, int n_user2, LDBLE f1, int new_n_user)
/* ---------------------------------------------------------------------- */
{
/*
 *   mixes two kinetics, saves result in kinetics new_n_user
 */
	int n;
	int n1, n2;
	int return_code;
	struct kinetics temp_kinetics, *kinetics_ptr;

	LDBLE f2;
	struct kinetics *kinetics_ptr1, *kinetics_ptr2;

	return_code = OK;
/*
 *   Find kinetics
 */	
	f2 = 1.0 - f1;
	kinetics_ptr1 = kinetics_bsearch (n_user1, &n1);
	if (kinetics_ptr1 == NULL) {
		sprintf(error_string, "Kinetics %d not found while processing initial conditions.", n_user1);
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	if (n_user2 >= 0) {
		kinetics_ptr2 = kinetics_bsearch (n_user2, &n2);
		if (kinetics_ptr2 == NULL) {
			sprintf(error_string, "Kinetics %d not found while processing initial conditions.", n_user2);
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		} 
	} else {
		kinetics_duplicate(kinetics_ptr1->n_user, new_n_user);
		return(OK);
	}
/*	
 *   Logical checks
 */
	if (sum_kinetics(kinetics_ptr1, f1, kinetics_ptr2, f2, &temp_kinetics) == ERROR) {
		return(ERROR);
	}
/*
 *   Store data for structure kinetics
 */
	temp_kinetics.n_user = new_n_user;
	temp_kinetics.n_user_end = new_n_user;
/*
 *   Finish up
 */
	kinetics_ptr = kinetics_bsearch(new_n_user, &n);
	if (kinetics_ptr == NULL) {
		space ((void *) &kinetics, count_kinetics, &max_kinetics, sizeof(struct kinetics));
		n = count_kinetics++;
	} else {
		kinetics_free(&kinetics[n]); 
	}
	memcpy(&kinetics[n], &temp_kinetics, sizeof(struct kinetics));
	/* sort only if necessary */
	if (n == count_kinetics - 1 && count_kinetics > 1) {
		if (kinetics[n].n_user < kinetics[n-1].n_user) {
			qsort (kinetics,
			       (size_t) count_kinetics,
			       (size_t) sizeof (struct kinetics),
			       kinetics_compare);
		}
	}
	return(return_code);
}
/* ---------------------------------------------------------------------- */
int mix_surface (int n_user1, int n_user2, LDBLE f1, int new_n_user)
/* ---------------------------------------------------------------------- */
{
/*
 *   mixes two surfacers, saves result in surface new_n_user
 */
	int n;
	int n1, n2;
	int return_code;
	struct surface temp_surface, *surface_ptr;

	LDBLE f2;
	struct surface *surface_ptr1, *surface_ptr2;

	return_code = OK;
/*
 *   Find surfacers
 */	
	f2 = 1.0 - f1;
	surface_ptr1 = surface_bsearch (n_user1, &n1);
	if (surface_ptr1 == NULL) {
		sprintf(error_string, "Surface %d not found while processing initial conditions.", n_user1);
		error_msg(error_string, CONTINUE);
		input_error++;
		return(ERROR);
	} 
	if (n_user2 >= 0) {
		surface_ptr2 = surface_bsearch (n_user2, &n2);
		if (surface_ptr2 == NULL) {
			sprintf(error_string, "Surface %d not found while processing initial conditions.", n_user2);
			error_msg(error_string, CONTINUE);
			input_error++;
			return(ERROR);
		} 
	} else {
		surface_duplicate(surface_ptr1->n_user, new_n_user);
		return(OK);
	}
/*	
 *   Logical checks
 */
	if (surface_ptr1->diffuse_layer != surface_ptr2->diffuse_layer) {
			sprintf(error_string, "Surfaces %d and %d differ in definition of diffuse layer. Can not mix.", n_user1, n_user2);
			error_msg(error_string, CONTINUE);
			return_code = ERROR;
			input_error++;
	}
	if (surface_ptr1->edl != surface_ptr2->edl) {
			sprintf(error_string, "Surfaces %d and %d differ in use of electrical double layer. Can not mix.", n_user1, n_user2);
			error_msg(error_string, CONTINUE);
			return_code = ERROR;
			input_error++;
	}
	if (surface_ptr1->only_counter_ions != surface_ptr2->only_counter_ions) {
			sprintf(error_string, "Surfaces %d and %d differ in use of only counter ions in the diffuse layer. Can not mix.", n_user1, n_user2);
			error_msg(error_string, CONTINUE);
			return_code = ERROR;
			input_error++;
	}
	if (surface_ptr1->related_phases != surface_ptr2->related_phases) {
			sprintf(error_string, "Surfaces %d and %d differ in use of related phases (sites proportional to moles of an equilibrium phase). Can not mix.", n_user1, n_user2);
			error_msg(error_string, CONTINUE);
			return_code = ERROR;
			input_error++;
	}
	if (surface_ptr1->related_rate != surface_ptr2->related_rate) {
			sprintf(error_string, "Surfaces %d and %d differ in use of related rate (sites proportional to moles of a kinetic reactant). Can not mix.", n_user1, n_user2);
			error_msg(error_string, CONTINUE);
			return_code = ERROR;
			input_error++;
	}

	if (sum_surface(surface_ptr1, f1, surface_ptr2, f2, &temp_surface) == ERROR) {
		return(ERROR);
	}
/*
 *   Store data for structure surface
 */
	temp_surface.n_user = new_n_user;
	temp_surface.n_user_end = new_n_user;
/*
 *   Finish up
 */
	surface_ptr = surface_bsearch(new_n_user, &n);
	if (surface_ptr == NULL) {
		n = count_surface++;
		space ((void *) &surface, count_surface, &max_surface, sizeof(struct surface));
	} else {
		surface_free(&surface[n]); 
	}
	memcpy(&surface[n], &temp_surface, sizeof(struct surface));
	/* sort only if necessary */
	if (n == count_surface - 1 && count_surface > 1) {
		if (surface[n].n_user < surface[n-1].n_user) {
			qsort (surface,
			       (size_t) count_surface,
			       (size_t) sizeof (struct surface),
			       surface_compare);
		}
	}

	return(return_code);
}
#ifdef USE_MPI
/* ---------------------------------------------------------------------- */
int partition_uz(int iphrq, int ihst, LDBLE new_frac)
/* ---------------------------------------------------------------------- */
{
	/* iphrq is count_chem number*/
	/* ihst is nxyz number */
	/*
	int n;
	int first_solution, n_solution, n_user;
	*/
	int n_user;
	LDBLE s1, s2, uz1, uz2;
	struct system *sys_ptr;

	struct solution *solution_ptr;
	struct exchange *exchange_ptr, *exchange_ptr_unsat, sat_exchange, unsat_exchange;
	struct pp_assemblage *pp_assemblage_ptr, *pp_assemblage_ptr_unsat, sat_pp_assemblage, unsat_pp_assemblage;
	struct gas_phase *gas_phase_ptr, *gas_phase_ptr_unsat, sat_gas_phase, unsat_gas_phase;
	struct s_s_assemblage *s_s_assemblage_ptr, *s_s_assemblage_ptr_unsat, sat_s_s_assemblage, unsat_s_s_assemblage;
	struct surface *surface_ptr, *surface_ptr_unsat, sat_surface, unsat_surface;
	struct kinetics *kinetics_ptr, *kinetics_ptr_unsat, sat_kinetics, unsat_kinetics;
	
	/* 
	 * repartition solids for partially saturated cells
	 */
	
	if (equal(old_frac[ihst], new_frac, 1e-8) == TRUE)  return(OK);

	/* solution number */
	/*
	solution_bsearch(first_user_number, &first_solution, TRUE);
	n_solution = first_solution + iphrq;
	exchange_ptr = exchange_bsearch(n_user, &n);
	pp_assemblage_ptr = pp_assemblage_bsearch(n_user, &n);
	gas_phase_ptr = gas_phase_bsearch(n_user, &n);
	s_s_assemblage_ptr = s_s_assemblage_bsearch(n_user, &n);
	kinetics_ptr = kinetics_bsearch(n_user, &n);
	surface_ptr = surface_bsearch(n_user, &n);
	*/
	assert(sz[iphrq]);
	solution_ptr = sz[iphrq]->solution;
	n_user = solution_ptr->n_user;
	exchange_ptr = sz[iphrq]->exchange;
	pp_assemblage_ptr = sz[iphrq]->pp_assemblage;
	gas_phase_ptr = sz[iphrq]->gas_phase;
	s_s_assemblage_ptr = sz[iphrq]->s_s_assemblage;
	kinetics_ptr = sz[iphrq]->kinetics;
	surface_ptr = sz[iphrq]->surface;
	
	if (new_frac >= 1.0) {
		/* put everything in saturated zone */
		uz1 = 0;
		uz2 = 0;
		s1 = 1.0; 
		s2 = 1.0;
	} else if (new_frac <= 1e-10) {
		/* put everything in unsaturated zone */
		uz1 = 1.0;
		uz2 = 1.0;
		s1 = 0.0; 
		s2 = 0.0;
	} else if (new_frac > old_frac[ihst]) {
		/* wetting cell */
		uz1 = 0.;
		uz2 = (1.0 - new_frac)/(1.0 - old_frac[ihst]);
		s1 = 1.;
		s2 = 1.0 - uz2;
	} else {
		/* draining cell */
		s1 = new_frac/old_frac[ihst];
		s2 = 0.0;
		uz1 = 1.0 - s1;
		uz2 = 1.0;
	}
	/*
	 *  Set current uz pointers
	 */

	sys_ptr = uz[iphrq];
	if (sys_ptr == NULL) {
		exchange_ptr_unsat = NULL;
		pp_assemblage_ptr_unsat = NULL;
		gas_phase_ptr_unsat = NULL;
		s_s_assemblage_ptr_unsat = NULL;
		kinetics_ptr_unsat = NULL;
		surface_ptr_unsat = NULL;
	} else {
		exchange_ptr_unsat = sys_ptr->exchange;
		pp_assemblage_ptr_unsat = sys_ptr->pp_assemblage;
		gas_phase_ptr_unsat = sys_ptr->gas_phase;
		s_s_assemblage_ptr_unsat = sys_ptr->s_s_assemblage;
		kinetics_ptr_unsat = sys_ptr->kinetics;
		surface_ptr_unsat = sys_ptr->surface;
	}
	/*
	 *   Calculate new compositions
	 */
	if (exchange_ptr != NULL) {
		if (sum_exchange(exchange_ptr, s1, exchange_ptr_unsat, s2, &sat_exchange) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_exchange(exchange_ptr, uz1, exchange_ptr_unsat, uz2, &unsat_exchange) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	if (pp_assemblage_ptr != NULL) {
		if (sum_pp_assemblage(pp_assemblage_ptr, s1, pp_assemblage_ptr_unsat, s2, &sat_pp_assemblage) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_pp_assemblage(pp_assemblage_ptr, uz1, pp_assemblage_ptr_unsat, uz2, &unsat_pp_assemblage) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	if (gas_phase_ptr != NULL) {
		if (sum_gas_phase(gas_phase_ptr, s1, gas_phase_ptr_unsat, s2, &sat_gas_phase) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_gas_phase(gas_phase_ptr, uz1, gas_phase_ptr_unsat, uz2, &unsat_gas_phase) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	if (s_s_assemblage_ptr != NULL) {
		if (sum_s_s_assemblage(s_s_assemblage_ptr, s1, s_s_assemblage_ptr_unsat, s2, &sat_s_s_assemblage) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_s_s_assemblage(s_s_assemblage_ptr, uz1, s_s_assemblage_ptr_unsat, uz2, &unsat_s_s_assemblage) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	if (kinetics_ptr != NULL) {
		if (sum_kinetics(kinetics_ptr, s1, kinetics_ptr_unsat, s2, &sat_kinetics) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_kinetics(kinetics_ptr, uz1, kinetics_ptr_unsat, uz2, &unsat_kinetics) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	if (surface_ptr != NULL) {
		if (sum_surface(surface_ptr, s1, surface_ptr_unsat, s2, &sat_surface) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_surface(surface_ptr, uz1, surface_ptr_unsat, uz2, &unsat_surface) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	/*
	 *   Make uz if new fraction is less than zero
	 */
	if (new_frac < 1.0 && uz[iphrq] == NULL) {
		uz[iphrq] = system_alloc();
		if (exchange_ptr != NULL) {
			/*
			uz[iphrq]->exchange = exchange_alloc(); 
			memcpy(uz[iphrq]->exchange, exchange_ptr, sizeof(struct exchange));
			*/
			uz[iphrq]->exchange = exchange_alloc(); 
			exchange_copy(exchange_ptr, uz[iphrq]->exchange, exchange_ptr->n_user); 
		}
		if (pp_assemblage_ptr != NULL) {
			/*
			uz[iphrq]->pp_assemblage = pp_assemblage_alloc();
			memcpy(uz[iphrq]->pp_assemblage, pp_assemblage_ptr, sizeof(struct pp_assemblage));
			*/
			uz[iphrq]->pp_assemblage = pp_assemblage_alloc(); 
			pp_assemblage_copy(pp_assemblage_ptr, uz[iphrq]->pp_assemblage, pp_assemblage_ptr->n_user); 
		}
		if (gas_phase_ptr != NULL) {
			/*
			uz[iphrq]->gas_phase = gas_phase_alloc();
			memcpy(uz[iphrq]->gas_phase, gas_phase_ptr, sizeof(struct gas_phase));
			*/
			uz[iphrq]->gas_phase = gas_phase_alloc(); 
			gas_phase_copy(gas_phase_ptr, uz[iphrq]->gas_phase, gas_phase_ptr->n_user); 
		}
		if (s_s_assemblage_ptr != NULL) {
			/*
			uz[iphrq]->s_s_assemblage = s_s_assemblage_alloc();
			memcpy(uz[iphrq]->s_s_assemblage, s_s_assemblage_ptr, sizeof(struct s_s_assemblage));
			*/
			uz[iphrq]->s_s_assemblage = s_s_assemblage_alloc(); 
			s_s_assemblage_copy(s_s_assemblage_ptr, uz[iphrq]->s_s_assemblage, s_s_assemblage_ptr->n_user); 
		}
		if (kinetics_ptr != NULL) {
			/*
			uz[iphrq]->kinetics = kinetics_alloc();
			memcpy(uz[iphrq]->kinetics, kinetics, sizeof(struct kinetics));
			*/
			uz[iphrq]->kinetics = kinetics_alloc(); 
			kinetics_copy(kinetics_ptr, uz[iphrq]->kinetics, kinetics_ptr->n_user); 
		}
		if (surface_ptr != NULL) {
			/*n
			uz[iphrq]->surface = surface_alloc();
			memcpy(uz[iphrq]->surface, surface, sizeof(struct surface));
			*/
			uz[iphrq]->surface = surface_alloc(); 
			surface_copy(surface_ptr, uz[iphrq]->surface, surface_ptr->n_user); 
		}
	}
	/*
	 *   Eliminate uz if new fraction 1.0
	 */
	if (new_frac >= 1.0 && uz[iphrq] != NULL) {
		system_free(uz[iphrq]);
		free_check_null(uz[iphrq]);
		uz[iphrq] = NULL;
	}
	sys_ptr = uz[iphrq];

	if (sys_ptr == NULL) {
		exchange_ptr_unsat = NULL;
		pp_assemblage_ptr_unsat = NULL;
		gas_phase_ptr_unsat = NULL;
		s_s_assemblage_ptr_unsat = NULL;
		kinetics_ptr_unsat = NULL;
		surface_ptr_unsat = NULL;
	} else {
		exchange_ptr_unsat = sys_ptr->exchange;
		pp_assemblage_ptr_unsat = sys_ptr->pp_assemblage;
		gas_phase_ptr_unsat = sys_ptr->gas_phase;
		s_s_assemblage_ptr_unsat = sys_ptr->s_s_assemblage;
		kinetics_ptr_unsat = sys_ptr->kinetics;
		surface_ptr_unsat = sys_ptr->surface;
	}

	/*
	 *   Copy into sat and unsat
	 */
	if (exchange_ptr != NULL) {
		if (exchange_ptr_unsat != NULL) {
			exchange_free(exchange_ptr_unsat);
			exchange_copy(&unsat_exchange, exchange_ptr_unsat, n_user);
		}
		exchange_free(exchange_ptr);
		exchange_copy(&sat_exchange, exchange_ptr, n_user);
		exchange_free(&unsat_exchange);
		exchange_free(&sat_exchange);
	}
	if (pp_assemblage_ptr != NULL) {
		if (pp_assemblage_ptr_unsat != NULL) {
			pp_assemblage_free(pp_assemblage_ptr_unsat);
			pp_assemblage_copy(&unsat_pp_assemblage, pp_assemblage_ptr_unsat, n_user);
		}
		pp_assemblage_free(pp_assemblage_ptr);
		pp_assemblage_copy(&sat_pp_assemblage, pp_assemblage_ptr, n_user);
		pp_assemblage_free(&unsat_pp_assemblage);
		pp_assemblage_free(&sat_pp_assemblage);
	}
	if (gas_phase_ptr != NULL) {
		if (gas_phase_ptr_unsat != NULL) {
			gas_phase_free(gas_phase_ptr_unsat);
			gas_phase_copy(&unsat_gas_phase, gas_phase_ptr_unsat, n_user);
		}
		gas_phase_free(gas_phase_ptr);
		gas_phase_copy(&sat_gas_phase, gas_phase_ptr, n_user);
		gas_phase_free(&unsat_gas_phase);
		gas_phase_free(&sat_gas_phase);
	}
	if (s_s_assemblage_ptr != NULL) {
		if (s_s_assemblage_ptr_unsat != NULL) {
			s_s_assemblage_free(s_s_assemblage_ptr_unsat);
			s_s_assemblage_copy(&unsat_s_s_assemblage, s_s_assemblage_ptr_unsat, n_user);
		}
		s_s_assemblage_free(s_s_assemblage_ptr);
		s_s_assemblage_copy(&sat_s_s_assemblage, s_s_assemblage_ptr, n_user);
		s_s_assemblage_free(&unsat_s_s_assemblage);
		s_s_assemblage_free(&sat_s_s_assemblage);
	}
	if (kinetics_ptr != NULL) {
		if (kinetics_ptr_unsat != NULL) {
			kinetics_free(kinetics_ptr_unsat);
			kinetics_copy(&unsat_kinetics, kinetics_ptr_unsat, n_user);
		}
		kinetics_free(kinetics_ptr);
		kinetics_copy(&sat_kinetics, kinetics_ptr, n_user);
		kinetics_free(&unsat_kinetics);
		kinetics_free(&sat_kinetics);
	}
	if (surface_ptr != NULL) {
		if (surface_ptr_unsat != NULL) {
			surface_free(surface_ptr_unsat);
			surface_copy(&unsat_surface, surface_ptr_unsat, n_user);
		}
		surface_free(surface_ptr);
		surface_copy(&sat_surface, surface_ptr, n_user);
		surface_free(&unsat_surface);
		surface_free(&sat_surface);
	}
#ifdef SKIP
	/*
	 * debugging
	 */
	system_total_solids(exchange_ptr, pp_assemblage_ptr, gas_phase_ptr, s_s_assemblage_ptr, surface_ptr);
	output_msg(OUTPUT_STDERR, "\nChemistry cell %d of %d, old %f, new %f: \n", iphrq, count_chem, old_frac[ihst], new_frac);
	output_msg(OUTPUT_STDERR, "\ns1 %f, s2 %f, uz1, %f, uz2, %f \n", s1, s2, uz1, uz2);
	output_msg(OUTPUT_STDERR, "\nSaturated zone solids: \n");
	elt_list_print0(elt_list);

	output_msg(OUTPUT_STDERR, "\nUnsaturated zone solids: \n");
	system_total_solids(exchange_ptr_unsat, pp_assemblage_ptr_unsat, gas_phase_ptr_unsat, s_s_assemblage_ptr_unsat, surface_ptr_unsat);
	elt_list_print0(elt_list);
#endif

	old_frac[ihst] = new_frac;

	return(OK);
}
#else
/* ---------------------------------------------------------------------- */
int partition_uz(int iphrq, int ihst, LDBLE new_frac)
/* ---------------------------------------------------------------------- */
{
	int n;
	int first_solution, n_solution, n_user;
	LDBLE s1, s2, uz1, uz2;
	struct system *sys_ptr;

	struct exchange *exchange_ptr, *exchange_ptr_unsat, sat_exchange, unsat_exchange;
	struct pp_assemblage *pp_assemblage_ptr, *pp_assemblage_ptr_unsat, sat_pp_assemblage, unsat_pp_assemblage;
	struct gas_phase *gas_phase_ptr, *gas_phase_ptr_unsat, sat_gas_phase, unsat_gas_phase;
	struct s_s_assemblage *s_s_assemblage_ptr, *s_s_assemblage_ptr_unsat, sat_s_s_assemblage, unsat_s_s_assemblage;
	struct surface *surface_ptr, *surface_ptr_unsat, sat_surface, unsat_surface;
	struct kinetics *kinetics_ptr, *kinetics_ptr_unsat, sat_kinetics, unsat_kinetics;
	
	/* 
	 * repartition solids for partially saturated cells
	 */
	
	if (equal(old_frac[ihst], new_frac, 1e-8) == TRUE)  return(OK);

	/* solution number */
	solution_bsearch(first_user_number, &first_solution, TRUE);
	n_solution = first_solution + iphrq;
	n_user = solution[n_solution]->n_user;
	exchange_ptr = exchange_bsearch(n_user, &n);
	pp_assemblage_ptr = pp_assemblage_bsearch(n_user, &n);
	gas_phase_ptr = gas_phase_bsearch(n_user, &n);
	s_s_assemblage_ptr = s_s_assemblage_bsearch(n_user, &n);
	kinetics_ptr = kinetics_bsearch(n_user, &n);
	surface_ptr = surface_bsearch(n_user, &n);
	
	if (new_frac >= 1.0) {
		/* put everything in saturated zone */
		uz1 = 0;
		uz2 = 0;
		s1 = 1.0; 
		s2 = 1.0;
	} else if (new_frac <= 1e-10) {
		/* put everything in unsaturated zone */
		uz1 = 1.0;
		uz2 = 1.0;
		s1 = 0.0; 
		s2 = 0.0;
	} else if (new_frac > old_frac[ihst]) {
		/* wetting cell */
		uz1 = 0.;
		uz2 = (1.0 - new_frac)/(1.0 - old_frac[ihst]);
		s1 = 1.;
		s2 = 1.0 - uz2;
	} else {
		/* draining cell */
		s1 = new_frac/old_frac[ihst];
		s2 = 0.0;
		uz1 = 1.0 - s1;
		uz2 = 1.0;
	}
	/*
	 *  Set current uz pointers
	 */

	sys_ptr = uz[iphrq];
	if (sys_ptr == NULL) {
		exchange_ptr_unsat = NULL;
		pp_assemblage_ptr_unsat = NULL;
		gas_phase_ptr_unsat = NULL;
		s_s_assemblage_ptr_unsat = NULL;
		kinetics_ptr_unsat = NULL;
		surface_ptr_unsat = NULL;
	} else {
		exchange_ptr_unsat = sys_ptr->exchange;
		pp_assemblage_ptr_unsat = sys_ptr->pp_assemblage;
		gas_phase_ptr_unsat = sys_ptr->gas_phase;
		s_s_assemblage_ptr_unsat = sys_ptr->s_s_assemblage;
		kinetics_ptr_unsat = sys_ptr->kinetics;
		surface_ptr_unsat = sys_ptr->surface;
	}
	/*
	 *   Calculate new compositions
	 */
	if (exchange_ptr != NULL) {
		if (sum_exchange(exchange_ptr, s1, exchange_ptr_unsat, s2, &sat_exchange) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_exchange(exchange_ptr, uz1, exchange_ptr_unsat, uz2, &unsat_exchange) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	if (pp_assemblage_ptr != NULL) {
		if (sum_pp_assemblage(pp_assemblage_ptr, s1, pp_assemblage_ptr_unsat, s2, &sat_pp_assemblage) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_pp_assemblage(pp_assemblage_ptr, uz1, pp_assemblage_ptr_unsat, uz2, &unsat_pp_assemblage) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	if (gas_phase_ptr != NULL) {
		if (sum_gas_phase(gas_phase_ptr, s1, gas_phase_ptr_unsat, s2, &sat_gas_phase) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_gas_phase(gas_phase_ptr, uz1, gas_phase_ptr_unsat, uz2, &unsat_gas_phase) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	if (s_s_assemblage_ptr != NULL) {
		if (sum_s_s_assemblage(s_s_assemblage_ptr, s1, s_s_assemblage_ptr_unsat, s2, &sat_s_s_assemblage) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_s_s_assemblage(s_s_assemblage_ptr, uz1, s_s_assemblage_ptr_unsat, uz2, &unsat_s_s_assemblage) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	if (kinetics_ptr != NULL) {
		if (sum_kinetics(kinetics_ptr, s1, kinetics_ptr_unsat, s2, &sat_kinetics) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_kinetics(kinetics_ptr, uz1, kinetics_ptr_unsat, uz2, &unsat_kinetics) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	if (surface_ptr != NULL) {
		if (sum_surface(surface_ptr, s1, surface_ptr_unsat, s2, &sat_surface) == ERROR) {
			error_msg("UZ calculation", STOP);
		}
		if (sum_surface(surface_ptr, uz1, surface_ptr_unsat, uz2, &unsat_surface) == ERROR) {
			error_msg("UZ calculation", STOP);
		}			
	}
	/*
	 *   Make uz if new fraction is less than zero
	 */
	if (new_frac < 1.0 && uz[iphrq] == NULL) {
		uz[iphrq] = system_alloc();
		if (exchange_ptr != NULL) {
			/*
			uz[iphrq]->exchange = exchange_alloc(); 
			memcpy(uz[iphrq]->exchange, exchange_ptr, sizeof(struct exchange));
			*/
			uz[iphrq]->exchange = exchange_alloc(); 
			exchange_copy(exchange_ptr, uz[iphrq]->exchange, exchange_ptr->n_user); 
		}
		if (pp_assemblage_ptr != NULL) {
			/*
			uz[iphrq]->pp_assemblage = pp_assemblage_alloc();
			memcpy(uz[iphrq]->pp_assemblage, pp_assemblage_ptr, sizeof(struct pp_assemblage));
			*/
			uz[iphrq]->pp_assemblage = pp_assemblage_alloc(); 
			pp_assemblage_copy(pp_assemblage_ptr, uz[iphrq]->pp_assemblage, pp_assemblage_ptr->n_user); 
		}
		if (gas_phase_ptr != NULL) {
			/*
			uz[iphrq]->gas_phase = gas_phase_alloc();
			memcpy(uz[iphrq]->gas_phase, gas_phase_ptr, sizeof(struct gas_phase));
			*/
			uz[iphrq]->gas_phase = gas_phase_alloc(); 
			gas_phase_copy(gas_phase_ptr, uz[iphrq]->gas_phase, gas_phase_ptr->n_user); 
		}
		if (s_s_assemblage_ptr != NULL) {
			/*
			uz[iphrq]->s_s_assemblage = s_s_assemblage_alloc();
			memcpy(uz[iphrq]->s_s_assemblage, s_s_assemblage_ptr, sizeof(struct s_s_assemblage));
			*/
			uz[iphrq]->s_s_assemblage = s_s_assemblage_alloc(); 
			s_s_assemblage_copy(s_s_assemblage_ptr, uz[iphrq]->s_s_assemblage, s_s_assemblage_ptr->n_user); 
		}
		if (kinetics_ptr != NULL) {
			/*
			uz[iphrq]->kinetics = kinetics_alloc();
			memcpy(uz[iphrq]->kinetics, kinetics, sizeof(struct kinetics));
			*/
			uz[iphrq]->kinetics = kinetics_alloc(); 
			kinetics_copy(kinetics_ptr, uz[iphrq]->kinetics, kinetics_ptr->n_user); 
		}
		if (surface_ptr != NULL) {
			/*n
			uz[iphrq]->surface = surface_alloc();
			memcpy(uz[iphrq]->surface, surface, sizeof(struct surface));
			*/
			uz[iphrq]->surface = surface_alloc(); 
			surface_copy(surface_ptr, uz[iphrq]->surface, surface_ptr->n_user); 
		}
	}
	/*
	 *   Eliminate uz if new fraction 1.0
	 */
	if (new_frac >= 1.0 && uz[iphrq] != NULL) {
		system_free(uz[iphrq]);
		free_check_null(uz[iphrq]);
		uz[iphrq] = NULL;
	}
	sys_ptr = uz[iphrq];

	if (sys_ptr == NULL) {
		exchange_ptr_unsat = NULL;
		pp_assemblage_ptr_unsat = NULL;
		gas_phase_ptr_unsat = NULL;
		s_s_assemblage_ptr_unsat = NULL;
		kinetics_ptr_unsat = NULL;
		surface_ptr_unsat = NULL;
	} else {
		exchange_ptr_unsat = sys_ptr->exchange;
		pp_assemblage_ptr_unsat = sys_ptr->pp_assemblage;
		gas_phase_ptr_unsat = sys_ptr->gas_phase;
		s_s_assemblage_ptr_unsat = sys_ptr->s_s_assemblage;
		kinetics_ptr_unsat = sys_ptr->kinetics;
		surface_ptr_unsat = sys_ptr->surface;
	}

	/*
	 *   Copy into sat and unsat
	 */
	if (exchange_ptr != NULL) {
		if (exchange_ptr_unsat != NULL) {
			exchange_free(exchange_ptr_unsat);
			exchange_copy(&unsat_exchange, exchange_ptr_unsat, n_user);
		}
		exchange_free(exchange_ptr);
		exchange_copy(&sat_exchange, exchange_ptr, n_user);
		exchange_free(&unsat_exchange);
		exchange_free(&sat_exchange);
	}
	if (pp_assemblage_ptr != NULL) {
		if (pp_assemblage_ptr_unsat != NULL) {
			pp_assemblage_free(pp_assemblage_ptr_unsat);
			pp_assemblage_copy(&unsat_pp_assemblage, pp_assemblage_ptr_unsat, n_user);
		}
		pp_assemblage_free(pp_assemblage_ptr);
		pp_assemblage_copy(&sat_pp_assemblage, pp_assemblage_ptr, n_user);
		pp_assemblage_free(&unsat_pp_assemblage);
		pp_assemblage_free(&sat_pp_assemblage);
	}
	if (gas_phase_ptr != NULL) {
		if (gas_phase_ptr_unsat != NULL) {
			gas_phase_free(gas_phase_ptr_unsat);
			gas_phase_copy(&unsat_gas_phase, gas_phase_ptr_unsat, n_user);
		}
		gas_phase_free(gas_phase_ptr);
		gas_phase_copy(&sat_gas_phase, gas_phase_ptr, n_user);
		gas_phase_free(&unsat_gas_phase);
		gas_phase_free(&sat_gas_phase);
	}
	if (s_s_assemblage_ptr != NULL) {
		if (s_s_assemblage_ptr_unsat != NULL) {
			s_s_assemblage_free(s_s_assemblage_ptr_unsat);
			s_s_assemblage_copy(&unsat_s_s_assemblage, s_s_assemblage_ptr_unsat, n_user);
		}
		s_s_assemblage_free(s_s_assemblage_ptr);
		s_s_assemblage_copy(&sat_s_s_assemblage, s_s_assemblage_ptr, n_user);
		s_s_assemblage_free(&unsat_s_s_assemblage);
		s_s_assemblage_free(&sat_s_s_assemblage);
	}
	if (kinetics_ptr != NULL) {
		if (kinetics_ptr_unsat != NULL) {
			kinetics_free(kinetics_ptr_unsat);
			kinetics_copy(&unsat_kinetics, kinetics_ptr_unsat, n_user);
		}
		kinetics_free(kinetics_ptr);
		kinetics_copy(&sat_kinetics, kinetics_ptr, n_user);
		kinetics_free(&unsat_kinetics);
		kinetics_free(&sat_kinetics);
	}
	if (surface_ptr != NULL) {
		if (surface_ptr_unsat != NULL) {
			surface_free(surface_ptr_unsat);
			surface_copy(&unsat_surface, surface_ptr_unsat, n_user);
		}
		surface_free(surface_ptr);
		surface_copy(&sat_surface, surface_ptr, n_user);
		surface_free(&unsat_surface);
		surface_free(&sat_surface);
	}
#ifdef SKIP
	/*
	 * debugging
	 */
	system_total_solids(exchange_ptr, pp_assemblage_ptr, gas_phase_ptr, s_s_assemblage_ptr, surface_ptr);
	output_msg(OUTPUT_STDERR, "\nChemistry cell %d of %d, old %f, new %f: \n", iphrq, count_chem, old_frac[ihst], new_frac);
	output_msg(OUTPUT_STDERR, "\ns1 %f, s2 %f, uz1, %f, uz2, %f \n", s1, s2, uz1, uz2);
	output_msg(OUTPUT_STDERR, "\nSaturated zone solids: \n");
	elt_list_print0(elt_list);

	output_msg(OUTPUT_STDERR, "\nUnsaturated zone solids: \n");
	system_total_solids(exchange_ptr_unsat, pp_assemblage_ptr_unsat, gas_phase_ptr_unsat, s_s_assemblage_ptr_unsat, surface_ptr_unsat);
	elt_list_print0(elt_list);
#endif

	old_frac[ihst] = new_frac;

	return(OK);
}
#endif
/* ---------------------------------------------------------------------- */
int system_free(struct system *system_ptr) 
/* ---------------------------------------------------------------------- */
{
	if (system_ptr == NULL) return(OK);

	if (system_ptr->solution != NULL) {
		solution_free(system_ptr->solution);
		system_ptr->solution = NULL;
	}

	if (system_ptr->exchange != NULL) {
		exchange_free(system_ptr->exchange);
		free_check_null(system_ptr->exchange);
		system_ptr->exchange = NULL;
	}
	if (system_ptr->pp_assemblage != NULL) {
		pp_assemblage_free(system_ptr->pp_assemblage);
		free_check_null(system_ptr->pp_assemblage);
		system_ptr->pp_assemblage = NULL;
	}
	if (system_ptr->gas_phase != NULL) {
		gas_phase_free(system_ptr->gas_phase);
		free_check_null(system_ptr->gas_phase);
		system_ptr->gas_phase = NULL;
	}
	if (system_ptr->s_s_assemblage != NULL) {
		s_s_assemblage_free(system_ptr->s_s_assemblage);
		free_check_null(system_ptr->s_s_assemblage);
		system_ptr->s_s_assemblage = NULL;
	}
	if (system_ptr->kinetics != NULL) {
		kinetics_free(system_ptr->kinetics);
		free_check_null(system_ptr->kinetics);
		system_ptr->kinetics = NULL;
	}
	if (system_ptr->surface != NULL) {
		surface_free(system_ptr->surface);
		free_check_null(system_ptr->surface);
		system_ptr->surface = NULL;
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
struct system *system_alloc(void) 
/* ---------------------------------------------------------------------- */
{
	struct system *system_ptr;

	system_ptr = PHRQ_malloc(sizeof (struct system));
	if (system_ptr == NULL) malloc_error();
	system_init(system_ptr);
	return(system_ptr);
}
/* ---------------------------------------------------------------------- */
int system_init(struct system *system_ptr) 
/* ---------------------------------------------------------------------- */
{
	system_ptr->solution = NULL;
	system_ptr->exchange = NULL;
	system_ptr->pp_assemblage = NULL;
	system_ptr->gas_phase = NULL;
	system_ptr->s_s_assemblage = NULL;
	system_ptr->kinetics = NULL;
	system_ptr->surface = NULL;
	return(OK);
}
