#ifndef _INC_HSTINPT
#define _INC_HSTINPT

#ifdef PHREEQC_IDENT
static char const svnid[] = "$Id$";
#endif
#define NO_DOS
/*
 *  HST uses: 
 *  pressure, not head
 *     h = p / (fluid_density*g) + (z -z0)
 *
 *  permeability, not hydraulic conductivity
 *     permeability(k) = hydraulic conductivity(K) * fluid_viscosity / (fluid_density*g)
 *  
 *  Compressibility, not specific storage
 *     compressibility = storage / (fluid_density*g) - porosity * fluid_compressibility
 */
/*
 * uncomment following line, to use default DOS file name for
 * output file
 */
/*#define DOS*/
#define __OPEN_NAMESPACE__
/* ----------------------------------------------------------------------
 *   INCLUDE FILES
 * ---------------------------------------------------------------------- */
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#if defined(__WPHAST__)
#include "../phqalloc.h"
#else
#ifdef _DEBUG
#define _CRTDBG_MAP_ALLOC
#include <crtdbg.h>
#endif
#endif
#include <ctype.h>
#include <math.h>
#include <errno.h>
#include <float.h>
#include "gpc.h"
/* ----------------------------------------------------------------------
 *   DEFINITIONS
 * ---------------------------------------------------------------------- */
#define GRAVITY 9.80665
#ifndef PI
EXTERNAL double PI;
#endif
typedef enum { kcal, cal, kjoules, joules } DELTA_H_UNIT;
typedef enum { PT_MIX, PT_DOUBLE, PT_INTEGER } property_type;
#define UNDEFINED 2
#define TRUE 1
#define FALSE 0
#define OK 1
#define ERROR 0
#define STOP 1
#define CONTINUE 0
#define UPDATE 3

/* check_line values, plus EMPTY, EOF, OK */
#define KEYWORD 3

/* copy_token values */
#define EMPTY 2
#define UPPER 4
#define LOWER 5
#define DIGIT 6
#define UNKNOWN 7
#define OPTION 8

#define INIT -1
#define MAX_LENGTH 100

#define ZONE 4
#define WATER_TABLE 5
#define FULL 6
#define CHEMISTRY 7
#define SPECIFIED 8
#define FLUX 9
#define LEAKY 10
#define LINEAR 11
#define FIXED 12
#define ASSOCIATED 13
#define ITERATIVE 14
#define DIRECT 15
#define STEP 16
#define UNITS 17
#define MIXTURE 18
#define DONE 19
/* ic_type: UNDEFINED, ZONE, WATER_TABLE */
/* bc_type: UNDEFINED, SPECIFIED, FLUX, LEAKY */
/* linear->type: UNDEFINED, LINEAR, FIXED */
/* bc_solution_type: UNDEFINED, FIXED, ASSOCIATED */
/* time */

/* ---------------------------------------------------------------------- 
 *   time/frequency data
 * ---------------------------------------------------------------------- */
struct time {
	int type;
	double value;
	int value_defined;
	char *input;
	double input_to_si;
	double input_to_user;
};
#include "time.h"
/* ---------------------------------------------------------------------- 
 *   Grid definition
 * ---------------------------------------------------------------------- */
struct grid {
	double *coord;
	int count_coord;
	double min;
	int uniform;
	int uniform_expanded;
	int direction;
	char c;
	double *elt_centroid;
};
EXTERNAL struct grid grid[3];         /* x=0, y=1, z=2 */
EXTERNAL struct grid *grid_overlay;  
EXTERNAL int count_grid_overlay;
EXTERNAL double snap[3];
/* ---------------------------------------------------------------------- 
 *   Zone
 * ---------------------------------------------------------------------- */
struct zone {
	int zone_defined;
	double x1;
	double y1;
	double z1;
	double x2;
	double y2;
	double z2;
};
/* ---------------------------------------------------------------------- 
 *   Index Range
 * ---------------------------------------------------------------------- */
struct index_range {
	int i1;
	int j1;
	int k1;
	int i2;
	int j2;
	int k2;
};
/* ---------------------------------------------------------------------- 
 *   Grid Elements
 * ---------------------------------------------------------------------- */
struct grid_elt {
	struct zone *zone;
	struct property *mask;
	struct property *active;
	struct property *porosity;
	struct property *kx;
	struct property *ky;
	struct property *kz;
	struct property *storage;
	struct property *alpha_long;
	struct property *alpha_trans;
	struct property *alpha_horizontal;
	struct property *alpha_vertical;
};
EXTERNAL struct grid_elt **grid_elt_zones;   /* contains input media properties */
EXTERNAL int count_grid_elt_zones;
/* ---------------------------------------------------------------------- 
 *   Mixture structure
 * ---------------------------------------------------------------------- */
struct mix {
	int i1;
	int i2;
	double f1;
};

/* ---------------------------------------------------------------------- 
 *   Property structure
 * ---------------------------------------------------------------------- */
struct property {
	int type;   /* UNDEFINED, FIXED, LINEAR, ZONE */
	double *v;
	int count_v;
	int count_alloc;
	char coord;
	int icoord;
	double dist1;
	double dist2;
	int new_def;
};

/*   Allowed values */
/*
   HEAD_IC_TYPE:     UNDEFINED, ZONE, WATER_TABLE
   BC_TYPE:          UNDEFINED, SPECIFIED, FLUX, LEAKY
   BC_SOLUTION_TYPE: UNDEFINED, FIXED, ASSOCIATED
   PROPERTY_TYPE:    UNDEFINED, LINEAR, FIXED, ZONE  
 */
/* ---------------------------------------------------------------------- 
 *   head initial conditions
 * ---------------------------------------------------------------------- */
struct head_ic {
	struct zone *zone;
	struct property *mask;
	int ic_type;      /* UNDEFINED, ZONE, WATER_TABLE */
	/* storage for specified head distribution and linear head distribution */
	struct property *head; 
};
/* ---------------------------------------------------------------------- 
 *   chemistry initial conditions
 * ---------------------------------------------------------------------- */
struct chem_ic {
	struct zone *zone;
	struct property *mask;

	/* cell chemistry ic*/
	struct property *solution;
	struct property *equilibrium_phases;
	struct property *exchange;
	struct property *surface;
	struct property *gas_phase;
	struct property *solid_solutions;
	struct property *kinetics;
};
/* ---------------------------------------------------------------------- 
 *   boundary conditions
 * ---------------------------------------------------------------------- */
struct bc {
	struct zone *zone;
	struct property *mask;
	
	/* boundary condition information */
	int bc_type;      /* UNDEFINED, SPECIFIED, FLUX, LEAKY */
	int new_def;

	/* head for SPECIFIED and LEAKY */
	struct time_series *bc_head;
	struct property *current_bc_head;

	/* flux for FLUX BC */
	struct time_series *bc_flux;
	struct property *current_bc_flux;

	/* other parameters for LEAKY */
	struct property *bc_k;
	struct property *bc_thick;
	
	/* flux face for FLUX and LEAKY, 0, 1, or 2 */
	int face;
	int face_defined;

	/* solution information for bc */
	int bc_solution_type; /* UNDEFINED, FIXED, ASSOCIATED */
	struct time_series *bc_solution;
	struct property *current_bc_solution;
};
/* ---------------------------------------------------------------------- 
 *   Rivers
 * ---------------------------------------------------------------------- */
typedef struct {
	double x;
	int x_defined;
	double y;
	int y_defined;
	double width;
	int width_defined;
	double k;
	int k_defined;
	double thickness;
	int thickness_defined;
	struct time_series *head;
	int head_defined;
	double current_head;
	double depth;
	int depth_defined;
	double z;
	int z_defined;
	struct time_series *solution;
	int solution_defined;
	int current_solution; 
	int solution1;
	int solution2; 
	double f1;
  /*	gpc_vertex right, left; */
	gpc_vertex vertex[4];
	gpc_polygon *polygon;
	int update;
} River_Point;
typedef struct {
	River_Point *points;
	int count_points;
	int new_def;
	int update;
	int n_user;
	char *description;
} River;
typedef struct {
	gpc_polygon *poly;
	double x;
	double y;
	double area;
	int river_number;
	int point_number;
	double w;
} River_Polygon;
EXTERNAL River *rivers;
EXTERNAL int count_rivers;
/*
 *    Well data
 */
typedef struct {
	double top;
	double bottom;
} Well_Interval;
typedef struct {
	int cell;
	double f;
	double upper;
	double lower;
} Cell_Fraction;

typedef struct {
	int n_user;
	char *description;
	int new_def;
	double x;
	int x_defined;
	double y;
	int y_defined;
	double radius;
	int radius_defined;
	double diameter;
	int diameter_defined;
	struct time_series *solution;
	int solution_defined;
	int current_solution;
	double lsd;
	int lsd_defined;
	int mobility_and_pressure;
	Well_Interval *depth;
	int count_depth;
	int depth_defined;
	Well_Interval *elevation;
	int count_elevation;
	int elevation_defined;
	struct time_series *q;
	int q_defined;
	double current_q;
	Cell_Fraction *cell_fraction;
	int count_cell_fraction;
	int update;
	double screen_bottom, screen_top, screen_depth_bottom, screen_depth_top;
} Well;
EXTERNAL Well *wells;
EXTERNAL int count_wells;
/* ---------------------------------------------------------------------- 
 *   all cell and element properties
 * ---------------------------------------------------------------------- */
struct bc_face {
	int bc_type;
	double bc_head;
#ifdef SKIP
	double bc_pressure; 
#endif
	int bc_head_defined;
	double bc_flux;
	int bc_flux_defined;
	double bc_k;
	int bc_k_defined;
	double bc_thick;
	int bc_thick_defined;
#ifdef SKIP
	int bc_face;
	int bc_face_defined;
#endif
	int bc_solution_type;
#ifdef MIX
	int bc_solution;
#endif
	struct mix bc_solution;
	int bc_solution_defined;
	int old_bc_solution_type;
};
struct cell {
	struct zone *zone;
	struct property *mask;
	int number;
	int ix, iy, iz;
	double x, y, z;
	double elt_x, elt_y, elt_z;
	int cell_active;
	/* initial conditions */
	int print_xyz;
	int print_xyz_defined;
	int print_hdf;
	int print_hdf_defined;
	int print_chem;
	int print_chem_defined;
	double ic_head;
	int ic_head_defined;
	double ic_pressure;
	struct mix ic_solution;
	int ic_solution_defined;
	struct mix ic_equilibrium_phases;
	int ic_equilibrium_phases_defined;
	struct mix ic_exchange;
	int ic_exchange_defined;
	struct mix ic_surface;
	int ic_surface_defined;
	struct mix ic_gas_phase;
	int ic_gas_phase_defined;
	struct mix ic_kinetics;
	int ic_kinetics_defined;
	struct mix ic_solid_solutions;
	int ic_solid_solutions_defined;

	/* boundary conditions  triplicate flux and leaky for x, y, and z face */
	struct mix temp_mix;
	double value;
	int bc_type;
	struct bc_face bc_face[3];
	River_Polygon *river_polygons;
	int count_river_polygons;

	/* associated grid element (node is left, forward, lower corner) */
	int is_element;
	int elt_active;
	int elt_active_defined;
	double porosity;
	int porosity_defined;
	double kx;
	int kx_defined;
	double ky;
	int ky_defined;
	double kz;
	int kz_defined;
	double x_perm, y_perm, z_perm;
	double storage;
	int storage_defined;
	double compress;
	double alpha_long;
	int alpha_long_defined;
	double alpha_horizontal;
	int alpha_horizontal_defined;
	double alpha_vertical;
	int alpha_vertical_defined;
};
/* ---------------------------------------------------------------------- 
 *   units conversion
 * ---------------------------------------------------------------------- */
struct unit {
	char *input;
	char *si; 
	double input_to_si;
/*	double si_to_user; */
	double input_to_user;
	int defined;
#if defined(__cplusplus)
// Constructors
	unit(void);
	unit(const char* si);
	~unit(void);
	unit(const unit& src);
// Assignment Operators
	unit& operator=(const unit& src);
// Utilities
	int set_input(const char* input);
	const char* c_str(void)const;
#endif
};
struct units {
	struct unit time;
	struct unit horizontal;
	struct unit vertical;
	struct unit head;
	struct unit k;	
	struct unit s;	
	struct unit alpha;	
	struct unit leaky_k;	
	struct unit leaky_thick;	
	struct unit flux;	
	struct unit well_diameter;	
	struct unit well_pumpage;	
	struct unit river_bed_k;	
	struct unit river_bed_thickness;	
#if defined(__cplusplus)
// Constructors
	units(void);
	~units(void);
//	units(const units& src);
// Assignment Operators
	units& operator=(const units& rhs);
#endif
};
EXTERNAL struct units units;
EXTERNAL struct head_ic **head_ic;
EXTERNAL int count_head_ic;
EXTERNAL struct chem_ic **chem_ic;
EXTERNAL int count_chem_ic;
EXTERNAL struct bc **bc;
EXTERNAL int count_bc;

EXTERNAL struct cell *cells;
EXTERNAL int count_cells;

EXTERNAL int free_surface;

/*---------------------------------------------------------------------- 
 *   Keywords
 *---------------------------------------------------------------------- */
struct key {
	const char *name;
	int keycount;
};
#ifdef MAIN
                          /* list of valid keywords */
struct key keyword[] = {            
	{"eof", 0},
	{"end", 0},
	{"title", 0},
	{"comment", 0},
	{"grid", 0},
	{"media", 0},
	{"head_ic", 0},
	{"chemistry_ic", 0},
	{"free_surface_bc", 0},
	{"specified_value_bc", 0},
	{"specified_bc", 0},
	{"flux_bc", 0},
	{"leaky_bc", 0},
	{"units", 0},
	{"fluid_properties", 0},
	{"solution_method", 0},
	{"time_control", 0},
	{"print_frequency", 0},
	{"print_input", 0},
	{"flow_only", 0},
	{"free_surface", 0},
	{"rivers", 0},
	{"river", 0},
 	{"wells", 0},
 	{"well", 0},
	{"flow"},
	{"print_locations"},
	{"print_location"},
	{"steady_flow"},
	{"steady_state_flow"},
	{"print_initial"},
	{"solute_transport"},
	{"specified_head_bc"}
};
int NKEYS = (sizeof(keyword) / sizeof(struct key));  /* Number of valid keywords */
#else
     extern struct key keyword[];
     extern int NKEYS;
#endif

/* ----------------------------------------------------------------------
 *   Print
 * ---------------------------------------------------------------------- */
struct prints {
	int echo_input;
};
#ifdef MAIN
struct prints pr = {TRUE};
#else
     extern struct prints pr;
#endif
struct print_zones {
	struct zone *zone;
	struct property *print;
	struct property *mask;
};
struct print_zones_struct {
  struct print_zones *print_zones;
  int count_print_zones;
  int thin_grid[3];
  int *thin_grid_list[3];
  int thin_grid_count[3];
};
EXTERNAL struct print_zones_struct print_zones_xyz, print_zones_chem;

EXTERNAL char *title_x;

/* ----------------------------------------------------------------------
 *   GLOBAL DECLARATIONS 
 * ---------------------------------------------------------------------- */
EXTERNAL FILE  *input_file;
EXTERNAL FILE  *input;                        
EXTERNAL FILE  *database_file;
EXTERNAL FILE  *log_file;
EXTERNAL FILE  *echo_file;
EXTERNAL FILE  *std_error;
EXTERNAL FILE  *error_log;
EXTERNAL FILE  *hst_file;
EXTERNAL FILE  *transport_file;
EXTERNAL FILE  *chemistry_file;
EXTERNAL int   head_ic_file_warning;
EXTERNAL char  *prefix, *transport_name, *chemistry_name, *database_name;

EXTERNAL char  error_string[10*MAX_LENGTH];
EXTERNAL char  tag[10*MAX_LENGTH];
EXTERNAL int   input_error;
EXTERNAL int   count_warnings;
EXTERNAL int   next_keyword;
EXTERNAL int   max_line;
EXTERNAL char  *line;
EXTERNAL char  *line_save;
EXTERNAL int   check_line_return;

EXTERNAL int   simulation;
EXTERNAL double *simulation_periods;
EXTERNAL char  dimension[3];
EXTERNAL int   nx, ny, nz, nxyz;
EXTERNAL int count_specified, count_flux, count_leaky, count_river_segments;

/* Fluid properties */
EXTERNAL double fluid_compressibility;
EXTERNAL double fluid_density;
EXTERNAL double fluid_viscosity;
EXTERNAL double fluid_diffusivity;

/* Solution method */
EXTERNAL int solver_method;
EXTERNAL int solver_memory;
EXTERNAL double solver_tolerance;
EXTERNAL int solver_save_directions;
EXTERNAL int solver_maximum;
EXTERNAL double solver_space;
EXTERNAL double solver_time;
EXTERNAL double cross_dispersion;

/* time stepping */
EXTERNAL struct time_series time_step;
EXTERNAL struct time current_time_step;
EXTERNAL struct time *time_end;
EXTERNAL int count_time_end;
EXTERNAL struct time current_time_end;
EXTERNAL double last_time_end;
EXTERNAL double si_to_user;
EXTERNAL double current_start_time;
EXTERNAL double current_end_time;


/* print frequency */
EXTERNAL struct time current_print_velocity;
EXTERNAL struct time current_print_hdf_velocity;
EXTERNAL struct time current_print_xyz_velocity;

EXTERNAL struct time current_print_head;
EXTERNAL struct time current_print_hdf_head;
EXTERNAL struct time current_print_xyz_head;

EXTERNAL struct time current_print_force_chem;
EXTERNAL struct time current_print_hdf_chem;
EXTERNAL struct time current_print_xyz_chem;

EXTERNAL struct time current_print_comp;
EXTERNAL struct time current_print_xyz_comp;

EXTERNAL struct time current_print_wells;
EXTERNAL struct time current_print_xyz_wells;

EXTERNAL struct time current_print_statistics;
EXTERNAL struct time current_print_flow_balance;
EXTERNAL struct time current_print_bc_flow;
EXTERNAL struct time current_print_conductances;
EXTERNAL int current_print_bc;

/* print input data */
EXTERNAL int print_input_media;
EXTERNAL int print_input_conductances;
EXTERNAL int print_input_bc;
EXTERNAL int print_input_fluid;
EXTERNAL int print_input_method;
EXTERNAL int print_input_wells;
EXTERNAL int print_input_xyz_wells;
EXTERNAL int print_input_xy;

EXTERNAL int print_input_force_chem;
EXTERNAL int print_input_comp;
EXTERNAL int print_input_xyz_comp;
EXTERNAL int print_input_head;
EXTERNAL int print_input_xyz_head;
EXTERNAL int print_input_ss_vel;
EXTERNAL int print_input_ss_vel_defined;
EXTERNAL int print_input_xyz_ss_vel;
EXTERNAL int print_input_xyz_ss_vel_defined;
EXTERNAL int print_input_hdf_chem;
EXTERNAL int print_input_hdf_head;
EXTERNAL int print_input_hdf_ss_vel;
EXTERNAL int print_input_hdf_ss_vel_defined;
EXTERNAL int print_input_xyz_chem;

/* keep track of transient information */
EXTERNAL int bc_specified_defined;
EXTERNAL int bc_flux_defined;
EXTERNAL int bc_leaky_defined;
EXTERNAL int river_defined;
EXTERNAL int rivers_update;
EXTERNAL int well_defined;
EXTERNAL int wells_update;

/* define dimensions */
EXTERNAL int axes[3];

/* define flow_only */
EXTERNAL int flow_only;
EXTERNAL int steady_flow;
EXTERNAL double eps_head;
EXTERNAL double eps_mass_balance;
EXTERNAL struct time min_ss_time_step;
EXTERNAL struct time max_ss_time_step;
EXTERNAL double max_ss_head_change;
EXTERNAL int max_ss_iterations;
EXTERNAL int save_final_heads;
EXTERNAL int adjust_water_rock_ratio;

#include "inputproto.h"

#endif /* _INC_HSTINPT */
