#ifndef _INC_TIME_HEADER_
#define _INC_TIME_HEADER_

#ifdef PHREEQC_IDENT
static char const svnid[] = "$Id$";
#endif
#define TIME_EPS 1e-8   /* user_units */
struct property_time {
	struct time time;
	struct property *property;
	struct time time_value;
	int int_value;
};
struct time_series {
	struct property_time **properties;
	int count_properties;
};
EXTERNAL double *simulation_periods;
EXTERNAL int count_simulation_periods;

EXTERNAL struct time_series print_velocity;
EXTERNAL struct time_series print_hdf_velocity;
EXTERNAL struct time_series print_xyz_velocity;
EXTERNAL struct time_series print_head;
EXTERNAL struct time_series print_hdf_head;
EXTERNAL struct time_series print_xyz_head;
EXTERNAL struct time_series print_force_chem;
EXTERNAL struct time_series print_hdf_chem;
EXTERNAL struct time_series print_xyz_chem;
EXTERNAL struct time_series print_comp;
EXTERNAL struct time_series print_xyz_comp;
EXTERNAL struct time_series print_wells;
EXTERNAL struct time_series print_xyz_wells;
EXTERNAL struct time_series print_statistics;
EXTERNAL struct time_series print_flow_balance;
EXTERNAL struct time_series print_bc_flow;
EXTERNAL struct time_series print_conductances;
EXTERNAL struct time_series print_bc;

#endif
