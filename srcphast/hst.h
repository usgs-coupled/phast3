#ifdef PHREEQC_IDENT
static char const svnid[] = "$Id$";
#endif
/* 
 *  STRUCTURES
 */
struct buffer {
	char *name;
	struct master *master;
	LDBLE moles;
	LDBLE fraction;
	LDBLE gfw;
	int first_master;
	int last_master;
};
struct activity_list {
	char *name;
	struct master *master;
	LDBLE la;
};
/* 
 *  VARIABLES
 */
EXTERNAL int first_user_number;
EXTERNAL int first_solution, first_gas_phase, first_exchange, 
        first_pp_assemblage, first_surface, first_s_s_assemblage, first_kinetics;
EXTERNAL int n_solution, n_gas_phase, n_exchange, n_pp_assemblage, n_surface,
	n_s_s_assemblage, n_kinetics;
EXTERNAL struct buffer *buffer;
EXTERNAL int count_component;
EXTERNAL int count_total;
EXTERNAL struct activity_list *activity_list;
EXTERNAL int count_activity_list;
EXTERNAL int transport_charge;
EXTERNAL char *file_prefix;

struct back_list {
	int list[4];
};
/*
 *  Used to reduce dimension of problem for phreeqc
 */
EXTERNAL int *forward;
EXTERNAL struct back_list *back;
EXTERNAL int count_back_list;
EXTERNAL int ix, iy, iz;
EXTERNAL int ixy, ixz, iyz, ixyz;
EXTERNAL int count_chem;
/* extra for transient free surface calculation */
EXTERNAL LDBLE * old_frac;
EXTERNAL int transient_free_surface;
struct system {
	struct solution *solution;
	struct exchange *exchange;
	struct pp_assemblage *pp_assemblage;
	struct gas_phase *gas_phase;
	struct s_s_assemblage *s_s_assemblage;
	struct kinetics *kinetics;
	struct surface *surface;
};
EXTERNAL struct system **uz;
EXTERNAL struct system **sz;
EXTERNAL double *frac1;
EXTERNAL int *initial1, *initial2;
EXTERNAL double rebalance_fraction;
