#define EXTERNAL extern
#include "hstinpt.h"
#include <stddef.h>
static char const svnid[] = "$Id$";

/* **********************************************************************
 *
 *   Routines related to structure "grid_elt"
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
int grid_elt_free(struct grid_elt *grid_elt_ptr)
/* ---------------------------------------------------------------------- */
/*
 *  Initializes a grid_elt structure that has already been allocated
 *
 *      arguments
 *      input:  ptr to grid_elt to be freed
 *      output: none
 *      return: OK
 */
{
     free_check_null(grid_elt_ptr->zone);
     property_free(grid_elt_ptr->mask);
     property_free(grid_elt_ptr->active);
     property_free(grid_elt_ptr->porosity);
     property_free(grid_elt_ptr->kx);
     property_free(grid_elt_ptr->ky);
     property_free(grid_elt_ptr->kz);
     property_free(grid_elt_ptr->storage);
     property_free(grid_elt_ptr->alpha_long);
     property_free(grid_elt_ptr->alpha_trans);
     property_free(grid_elt_ptr->alpha_horizontal);
     property_free(grid_elt_ptr->alpha_vertical);

     free_check_null(grid_elt_ptr);
     return(OK);
}
/* ---------------------------------------------------------------------- */
struct grid_elt *grid_elt_alloc(void)
/* ---------------------------------------------------------------------- */
/*
 *  Allocates grid_elt structure 
 *
 *      arguments
 *      input:  none
 *      output: none
 *      return: new grid_elt structure
 */
{
	struct grid_elt *grid_elt_ptr;

	grid_elt_ptr = (struct grid_elt *) malloc (sizeof(struct grid_elt));
	if (grid_elt_ptr == NULL) malloc_error();
	grid_elt_ptr->zone = (struct zone *) zone_alloc();
	if (grid_elt_ptr->zone == NULL) malloc_error();
	grid_elt_ptr->mask = NULL;
	grid_elt_ptr->active = NULL;
	grid_elt_ptr->porosity = NULL;
	grid_elt_ptr->kx = NULL;
	grid_elt_ptr->ky = NULL;
	grid_elt_ptr->kz = NULL;
	grid_elt_ptr->storage = NULL;
	grid_elt_ptr->alpha_long = NULL;
	grid_elt_ptr->alpha_trans = NULL;
	grid_elt_ptr->alpha_horizontal = NULL;
	grid_elt_ptr->alpha_vertical = NULL;
	return(grid_elt_ptr);
}
/* **********************************************************************
 *
 *   Routines related to structure "cell"
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
int cell_free(struct cell *cell_ptr)
/* ---------------------------------------------------------------------- */
/*
 *  Frees a cell structure
 *
 *      arguments
 *      input:  ptr to cell struct to be freed
 *      output: none
 *      return: OK
 */
{
	int i;
	free_check_null(cell_ptr->zone);
	property_free(cell_ptr->mask);
	for (i = 0; i < cell_ptr->count_river_polygons; i++) {
		gpc_free_polygon(cell_ptr->river_polygons[i].poly);
		free_check_null(cell_ptr->river_polygons[i].poly);
	}
	free_check_null(cell_ptr->river_polygons);
	
	return(OK);
}
/* ---------------------------------------------------------------------- */
int cell_init(struct cell *cell_ptr)
/* ---------------------------------------------------------------------- */
/*
 *  Initializes a cell structure that has already been allocated
 *
 *      arguments
 *      input:  ptr to cell to be initialized
 *      output: none
 *      return: OK
 */
{
/*
 *   Initialize
 */
	int i;

	cell_ptr->cell_active = FALSE;
	cell_ptr->print_xyz = TRUE;
	cell_ptr->print_xyz_defined = FALSE;
	cell_ptr->print_hdf = TRUE;
	cell_ptr->print_hdf_defined = FALSE;
	cell_ptr->print_chem = TRUE;
	cell_ptr->print_chem_defined = FALSE;
	cell_ptr->zone = malloc((size_t) sizeof (struct zone));
	if (cell_ptr->zone == NULL) malloc_error();
	cell_ptr->mask = NULL; /* cell_alloc is never called */

	/* head ic */
	cell_ptr->ic_head_defined = FALSE;

	/* chemistry ic */
	mix_init(&cell_ptr->ic_solution);
	cell_ptr->ic_solution_defined = FALSE;
	mix_init(&cell_ptr->ic_equilibrium_phases);
	cell_ptr->ic_equilibrium_phases_defined = FALSE;
	mix_init(&cell_ptr->ic_exchange);
	cell_ptr->ic_exchange_defined = FALSE;
	mix_init(&cell_ptr->ic_surface);
	cell_ptr->ic_surface_defined = FALSE;
	mix_init(&cell_ptr->ic_gas_phase);
	cell_ptr->ic_gas_phase_defined = FALSE;
	mix_init(&cell_ptr->ic_solid_solutions);
	cell_ptr->ic_solid_solutions_defined = FALSE;
	mix_init(&cell_ptr->ic_kinetics);
	cell_ptr->ic_kinetics_defined = FALSE;

	/* boundary conditions */

	cell_ptr->bc_type = UNDEFINED;

	for (i = 0; i < 3; i++) {
		cell_ptr->bc_face[i].bc_type = UNDEFINED;
		cell_ptr->bc_face[i].bc_head_defined = FALSE;
		cell_ptr->bc_face[i].bc_flux_defined = FALSE;
		cell_ptr->bc_face[i].bc_k_defined = FALSE;
		cell_ptr->bc_face[i].bc_thick_defined = FALSE;
		cell_ptr->bc_face[i].bc_solution_type = UNDEFINED;
		mix_init(&cell_ptr->bc_face[i].bc_solution);
	}

	/* rivers */
	cell_ptr->river_polygons = malloc((size_t) sizeof(River_Polygon));
	if (cell_ptr->river_polygons == NULL) malloc_error();
	cell_ptr->count_river_polygons = 0;

	/* grid_elt */
	cell_ptr->is_element = FALSE;
	cell_ptr->elt_active = TRUE;
	cell_ptr->elt_active_defined = TRUE;
	cell_ptr->porosity_defined = FALSE;
	cell_ptr->kx_defined = FALSE;
	cell_ptr->ky_defined = FALSE;
	cell_ptr->kz_defined = FALSE;
	cell_ptr->storage = 0;
	cell_ptr->storage_defined = FALSE;
	cell_ptr->alpha_long_defined = FALSE;
	cell_ptr->alpha_horizontal_defined = FALSE;
	cell_ptr->alpha_vertical_defined = FALSE;

	return(OK);
}
/* ---------------------------------------------------------------------- */
struct cell *cell_alloc(void)
/* ---------------------------------------------------------------------- */
/*
 *  Allocates cell structure 
 *
 *      arguments
 *      input:  none
 *      output: none
 *      return: new cell structure
 */
{
	struct cell *cell_ptr;

	cell_ptr = (struct cell *) malloc (sizeof(struct cell));
	if (cell_ptr == NULL) malloc_error();
	cell_ptr->mask = NULL;
	return(cell_ptr);
}
/* ---------------------------------------------------------------------- */
struct zone *zone_alloc(void)
/* ---------------------------------------------------------------------- */
{
	struct zone *zone_ptr;
	zone_ptr = (struct zone *) malloc (sizeof(struct zone));
	if (zone_ptr == NULL) malloc_error();
	zone_ptr->zone_defined = UNDEFINED;
	return (zone_ptr);
}
/* **********************************************************************
 *
 *   Routines related to structure "zone"
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
/* ---------------------------------------------------------------------- */
int zone_check(struct zone *zone_ptr)
/* ---------------------------------------------------------------------- */
{
	int return_value;
	return_value = OK;
	if(zone_ptr->x2 < zone_ptr->x1) {
		return_value = ERROR;
	}
	if(zone_ptr->y2 < zone_ptr->y1) {
		return_value = ERROR;
	}
	if(zone_ptr->z2 < zone_ptr->z1) {
		return_value = ERROR;
	}
	return(return_value);
}

/* **********************************************************************
 *
 *   Routines related to structure "bc"
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
struct bc *bc_alloc(void)
/* ---------------------------------------------------------------------- */
/*
 *  Allocates bc structure 
 *
 *      arguments
 *      input:  none
 *      output: none
 *      return: new bc structure
 */
{
	struct bc *bc_ptr;

	bc_ptr = (struct bc *) malloc (sizeof(struct bc));
	if (bc_ptr == NULL) malloc_error();
	bc_init(bc_ptr);
	return(bc_ptr);
}
/* ---------------------------------------------------------------------- */
int bc_free(struct bc *bc_ptr)
/* ---------------------------------------------------------------------- */
/*
 *  frees a bc structure
 *
 *      arguments
 *      input:  ptr to bc struct to be freed
 *      output: none
 *      return: OK
 */
{
     free_check_null(bc_ptr->zone);
     time_series_free(bc_ptr->bc_head);
     time_series_free(bc_ptr->bc_flux);
     property_free(bc_ptr->bc_k);
     property_free(bc_ptr->bc_thick);
     time_series_free(bc_ptr->bc_solution);

     free_check_null(bc_ptr->bc_head);
     free_check_null(bc_ptr->bc_flux);
     free_check_null(bc_ptr->bc_solution);
     property_free(bc_ptr->mask);
     return(OK);
}
/* ---------------------------------------------------------------------- */
int bc_init(struct bc *bc_ptr)
/* ---------------------------------------------------------------------- */
/*
 *  Initializes a bc structure that has already been allocated
 *
 *      arguments
 *      input:  ptr to bc to be initialized
 *      output: none
 *      return: OK
 */
{
/*
 *   Initialize
 */
	/* head ic */
	bc_ptr->zone = NULL;
	bc_ptr->mask = NULL;

	/* boundary conditions */
	bc_ptr->bc_type = UNDEFINED;
	bc_ptr->bc_head = NULL;
	bc_ptr->bc_flux = NULL;
	bc_ptr->current_bc_flux = NULL;
	bc_ptr->bc_k = NULL;
	bc_ptr->bc_thick = NULL;
	bc_ptr->face = -1;
	bc_ptr->face_defined = FALSE;
	bc_ptr->bc_solution_type = UNDEFINED;
	bc_ptr->bc_solution = NULL;
	bc_ptr->current_bc_solution = NULL;
	bc_ptr->current_bc_head = NULL;

	return(OK);
}
/* **********************************************************************
 *
 *   Routines related to structure "chem_ic"
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
struct chem_ic *chem_ic_alloc(void)
/* ---------------------------------------------------------------------- */
/*
 *  Allocates chem_ic structure 
 *
 *      arguments
 *      input:  none
 *      output: none
 *      return: new chem_ic structure
 */
{
	struct chem_ic *chem_ic_ptr;

	chem_ic_ptr = (struct chem_ic *) malloc (sizeof(struct chem_ic));
	if (chem_ic_ptr == NULL) malloc_error();
	chem_ic_ptr->mask = NULL;
	return(chem_ic_ptr);
}
/* ---------------------------------------------------------------------- */
int chem_ic_free(struct chem_ic *chem_ic_ptr)
/* ---------------------------------------------------------------------- */
/*
 *  frees a chem_ic structure
 *
 *      arguments
 *      input:  ptr to chem_ic struct to be freed
 *      output: none
 *      return: OK
 */
{
     free_check_null(chem_ic_ptr->zone);
     property_free(chem_ic_ptr->mask);
     property_free(chem_ic_ptr->solution);
     property_free(chem_ic_ptr->equilibrium_phases);
     property_free(chem_ic_ptr->exchange);
     property_free(chem_ic_ptr->surface);
     property_free(chem_ic_ptr->gas_phase);
     property_free(chem_ic_ptr->solid_solutions);
     property_free(chem_ic_ptr->kinetics);
     return(OK);
}
/* ---------------------------------------------------------------------- */
int chem_ic_init(struct chem_ic *chem_ic_ptr)
/* ---------------------------------------------------------------------- */
/*
 *  Initializes a chem_ic structure that has already been allocated
 *
 *      arguments
 *      input:  ptr to chem_ic to be initialized
 *      output: none
 *      return: OK
 */
{
/*
 *   Initialize
 */
	/* head ic */
	chem_ic_ptr->zone = NULL;

	/* chemistry ic */
	chem_ic_ptr->solution = NULL;
	chem_ic_ptr->equilibrium_phases = NULL;
	chem_ic_ptr->exchange = NULL;
	chem_ic_ptr->surface = NULL;
	chem_ic_ptr->gas_phase = NULL;
	chem_ic_ptr->solid_solutions = NULL;
	chem_ic_ptr->kinetics = NULL;

	return(OK);
}
/* **********************************************************************
 *
 *   Routines related to structure "head_ic"
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
struct head_ic *head_ic_alloc(void)
/* ---------------------------------------------------------------------- */
/*
 *  Allocates head_ic structure 
 *
 *      arguments
 *      input:  none
 *      output: none
 *      return: new head_ic structure
 */
{
	struct head_ic *head_ic_ptr;

	head_ic_ptr = (struct head_ic *) malloc (sizeof(struct head_ic));
	if (head_ic_ptr == NULL) malloc_error();
	head_ic_ptr->mask = NULL;
	return(head_ic_ptr);
}
/* ---------------------------------------------------------------------- */
int head_ic_free(struct head_ic *head_ic_ptr)
/* ---------------------------------------------------------------------- */
/*
 *  frees a head_ic structure
 *
 *      arguments
 *      input:  ptr to head_ic struct to be freed
 *      output: none
 *      return: OK
 */
{
     free_check_null(head_ic_ptr->zone);
     property_free(head_ic_ptr->head);
     property_free(head_ic_ptr->mask);
     return(OK);
}
/* ---------------------------------------------------------------------- */
int head_ic_init(struct head_ic *head_ic_ptr)
/* ---------------------------------------------------------------------- */
/*
 *  Initializes a head_ic structure that has already been allocated
 *
 *      arguments
 *      input:  ptr to head_ic to be initialized
 *      output: none
 *      return: OK
 */
{
/*
 *   Initialize
 */
	/* head ic */
	head_ic_ptr->zone = NULL;

	/* headistry ic */
	head_ic_ptr->ic_type = UNDEFINED;
	head_ic_ptr->head = NULL;
	return(OK);
}
/* **********************************************************************
 *
 *   Routines related to structure "property"
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
struct property *property_alloc(void)
/* ---------------------------------------------------------------------- */
/*
 *  Allocates property structure 
 *
 *      arguments
 *      input:  none
 *      output: none
 *      return: new property structure
 */
{
	struct property *property_ptr;

	property_ptr = (struct property *) malloc (sizeof(struct property));
	if (property_ptr == NULL) malloc_error();
	property_ptr->v = malloc ((size_t) 2 * sizeof(double));
	if (property_ptr->v == NULL) malloc_error();
	property_ptr->count_v = 0;
	property_ptr->count_alloc = 2;
	property_ptr->type = UNDEFINED;
	property_ptr->coord = '\000';
	property_ptr->icoord = -1;
	property_ptr->dist1 = -1;
	property_ptr->dist2 = -1;
	return(property_ptr);
}
/* ---------------------------------------------------------------------- */
int property_free(struct property *property_ptr)
/* ---------------------------------------------------------------------- */
/*
 *  frees a property structure
 *
 *      arguments
 *      input:  ptr to property struct to be freed
 *      output: none
 *      return: OK
 */
{
	if (property_ptr == NULL) return(OK);
	free_check_null(property_ptr->v);
	free_check_null(property_ptr);

     return(OK);
}
/* **********************************************************************
 *
 *   Routines related to rivers
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
River *river_search (int n_user, int *n)
/* ---------------------------------------------------------------------- */
{
/*   Linear search of the structure array "river" for user number n_user.
 *
 *   Arguments:
 *      n_user  input, user number
 *      n       output, position in river
 *
 *   Returns:
 *      if found, the address of the river element
 *      if not found, NULL
 */
	int i;
	for (i=0; i < count_rivers; i++) {
		if ( rivers[i].n_user == n_user) {
			*n = i;
			return (&(rivers[i]));
		}
	}
/*
 *   River not found
 */
	return (NULL);
}
/* ---------------------------------------------------------------------- */
int river_free (River *river_ptr)
/* ---------------------------------------------------------------------- */
{
/*
 *   Frees all data associated with river structure.
 */
	int i;
	if (river_ptr == NULL) return(ERROR);
/*
 *   Free space allocated for river structure
 */
	free_check_null (river_ptr->description);
	for (i = 0; i < river_ptr->count_points; i++) {
		if (river_ptr->points[i].polygon != NULL) {
			gpc_free_polygon(river_ptr->points[i].polygon);
		}
		free_check_null(river_ptr->points[i].polygon);
		time_series_free(river_ptr->points[i].head);
		time_series_free(river_ptr->points[i].solution);

	
		free_check_null(river_ptr->points[i].head);
		free_check_null(river_ptr->points[i].solution);
	}
	free_check_null (river_ptr->points);
	return(OK);
}
/* **********************************************************************
 *
 *   Routines related to wells
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
Well *well_search (int n_user, int *n)
/* ---------------------------------------------------------------------- */
{
/*   Linear search of the structure array "well" for user number n_user.
 *
 *   Arguments:
 *      n_user  input, user number
 *      n       output, position in well
 *
 *   Returns:
 *      if found, the address of the well element
 *      if not found, NULL
 */
	int i;
	for (i=0; i < count_wells; i++) {
		if ( wells[i].n_user == n_user) {
			*n = i;
			return (&(wells[i]));
		}
	}
/*
 *   Well not found
 */
	return (NULL);
}
/* ---------------------------------------------------------------------- */
int well_free (Well *well_ptr)
/* ---------------------------------------------------------------------- */
{
/*
 *   Frees all data associated with well structure.
 */
	if (well_ptr == NULL) return(ERROR);
/*
 *   Free space allocated for well structure
 */
	free_check_null (well_ptr->description);
	free_check_null (well_ptr->depth);
	free_check_null (well_ptr->elevation);
	free_check_null (well_ptr->cell_fraction);
	time_series_free(well_ptr->solution);
	time_series_free(well_ptr->q);
	free_check_null(well_ptr->solution);
	free_check_null(well_ptr->q);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int well_interval_compare (const void *ptr1, const void *ptr2)
/* ---------------------------------------------------------------------- */
{
	const Well_Interval *well_interval_ptr1, *well_interval_ptr2;
	well_interval_ptr1 = (const Well_Interval *) ptr1;
	well_interval_ptr2 = (const Well_Interval *) ptr2;
	if (well_interval_ptr1->top > well_interval_ptr2->top) return(1);
	if (well_interval_ptr1->top < well_interval_ptr2->top) return(-1);
	return(0);

}
/* **********************************************************************
 *
 *   Routines related to mix
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
int mix_init (struct mix *mix_ptr)
/* ---------------------------------------------------------------------- */
{
	mix_ptr->i1 = -1;
	mix_ptr->i2 = -1;
	mix_ptr->f1 = 0;
	return(OK);
}
/* ---------------------------------------------------------------------- */
int copy_time (struct time *time_source, struct time *time_destination)
/* ---------------------------------------------------------------------- */
{
	free_check_null(time_destination->input);
	time_destination->type = time_source->type;
	time_destination->value = time_source->value;
	time_destination->value_defined = time_source->value_defined;
	if (time_source->input != NULL) {
		time_destination->input = string_duplicate(time_source->input);
	} else {
		time_destination->input = NULL;
	}
	time_destination->input_to_si = time_source->input_to_si;
	time_destination->input_to_user = time_source->input_to_user;
	return(OK);
}
/* **********************************************************************
 *
 *   Routines related to print_zones_struct
 *
 * ********************************************************************** */
/* ---------------------------------------------------------------------- */
int print_zone_struct_init (struct print_zones_struct *print_zones_struct_ptr)
/* ---------------------------------------------------------------------- */
{
	int i;
	if (print_zones_struct_ptr == NULL) return(ERROR);

	print_zones_struct_ptr->print_zones = NULL;
	print_zones_struct_ptr->count_print_zones = 0;

	for (i = 0; i < 3; ++i) {
		print_zones_struct_ptr->thin_grid[i] = 0;
		print_zones_struct_ptr->thin_grid_list[i] = NULL;
		print_zones_struct_ptr->thin_grid_count[i] = 0;
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int print_zone_struct_free (struct print_zones_struct *print_zones_struct_ptr)
/* ---------------------------------------------------------------------- */
{
/*
 *   Frees all data associated with print_zones_struct structure.
 */
	int i;
	if (print_zones_struct_ptr == NULL) return(ERROR);
/*
 *   Free space allocated for print_zones_struct structure
 */
	for (i = 0; i < print_zones_struct_ptr->count_print_zones; ++i) {
		free_check_null(print_zones_struct_ptr->print_zones[i].zone);
		property_free(print_zones_struct_ptr->print_zones[i].print);
		property_free(print_zones_struct_ptr->print_zones[i].mask);
	}
	for (i = 0; i < 3; ++i) {
		free_check_null(print_zones_struct_ptr->thin_grid_list[i]);
	}
	free_check_null(print_zones_struct_ptr->print_zones);
	return(OK);
}
