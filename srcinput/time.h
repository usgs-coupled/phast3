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
double *simulation_periods;
int count_simulation_periods;

struct time_series print_velocity;
struct time_series print_hdf_velocity;
struct time_series print_xyz_velocity;
struct time_series print_head;
struct time_series print_hdf_head;
struct time_series print_xyz_head;
struct time_series print_force_chem;
struct time_series print_hdf_chem;
struct time_series print_xyz_chem;
struct time_series print_comp;
struct time_series print_xyz_comp;
struct time_series print_wells;
struct time_series print_xyz_wells;
struct time_series print_statistics;
struct time_series print_flow_balance;
struct time_series print_bc_flow;
struct time_series print_conductances;
struct time_series print_bc;

