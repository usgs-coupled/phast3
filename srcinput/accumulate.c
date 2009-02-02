#define EXTERNAL extern
#include <iostream>
#include <set>
#include "hstinpt.h"
#include "message.h"
#include "stddef.h"
#include "Polyhedron.h"
#include "Prism.h"
#include "Cube.h"
#include "Wedge.h"
#include "Exterior_cell.h"
#include "PHAST_Transform.h"
#include "Zone_budget.h"
static char const svnid[] =
	"$Id$";
int setup_grid(void);
static void distribute_flux_bc(int i, std::list < int >&pts, char *tag);
static void distribute_leaky_bc(int i, std::list < int >&pts, char *tag);
static void distribute_specified_bc(int i, std::list < int >&pts, char *tag);
static void cells_with_exterior_faces_in_zone(std::list < int >&pts,
											  struct zone *zone_ptr);
static void faces_intersect_polyhedron(int i,
									   std::list < int >&list_of_numbers,
									   Cell_Face face);
static void any_faces_intersect_polyhedron(int i,
										   std::list < int >&list_of_numbers,
										   Cell_Face face);
void process_bc(struct cell *cell_ptr);
static void Tidy_cubes(PHAST_Transform::COORDINATE_SYSTEM target,
					   PHAST_Transform * map2grid);
static void Tidy_properties(PHAST_Transform::COORDINATE_SYSTEM target,
							PHAST_Transform * map2grid);
static bool find_shell(Polyhedron *poly, double *width, std::list<int> &list_of_elements);
/* ---------------------------------------------------------------------- */
int
accumulate(void)
/* ---------------------------------------------------------------------- */
{
	if (simulation == 0)
	{
		setup_grid();

		// Set up transform
		double scale_h = 1;
		double scale_v = 1;
		if (units.map_horizontal.defined == TRUE)
		{
			scale_h =
				units.map_horizontal.input_to_si /
				units.horizontal.input_to_si;
		}
		if (units.map_vertical.defined == TRUE)
		{
			scale_v =
				units.map_vertical.input_to_si / units.vertical.input_to_si;
		}
		map_to_grid =
			new PHAST_Transform(grid_origin[0], grid_origin[1],
								grid_origin[2], grid_angle, scale_h, scale_h,
								scale_v);
		Point p(275000., 810000, 0);
		map_to_grid->Transform(p);

		// Convert units to grid
		target_coordinate_system = PHAST_Transform::GRID;
		Tidy_cubes(target_coordinate_system, map_to_grid);
		Tidy_properties(target_coordinate_system, map_to_grid);
		Tidy_prisms();
		Convert_coordinates_prisms(target_coordinate_system, map_to_grid);

		if (tidy_rivers() == OK)
		{
			if (build_rivers() == OK)
			{
				setup_rivers();
			}
		}
		if (tidy_drains() == OK)
		{
			if (build_drains() == OK)
			{
				setup_drains();
			}
		}
		if (tidy_wells() == OK)
		{
			if (wells_convert_coordinate_systems())
			{
					setup_wells();
			}
		}
#ifdef DEBUG_RIVERS
		write_rivers();
#endif
	}
	else
	{
		update_rivers();
		update_wells();
	}
	if (simulation == 0)
	{
		setup_head_ic();
		setup_chem_ic();
		setup_media();
	}
	setup_bc();
	setup_print_locations(&print_zones_chem,
						  offsetof(struct cell, print_chem),
						  offsetof(struct cell, print_chem_defined));
	setup_print_locations(&print_zones_xyz, offsetof(struct cell, print_xyz),
						  offsetof(struct cell, print_xyz_defined));
	if (input_error > 0)
	{
		error_msg("Stopping because of input errors.", STOP);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
setup_grid(void)
/* ---------------------------------------------------------------------- */
{
	int i, j, k, n, count, start;
	double x1, x2, increment;
	double d1, d2;
	double diff;
	struct grid *grid_ptr;
	double *nodes;
	int count_nodes;
	char c[3] = { 'X', 'Y', 'Z' };
	/*
	 *   process grid information
	 */
	strcpy(dimension, "   ");
	for (i = 0; i < 3; i++)
	{
		if (grid[i].uniform == UNDEFINED)
		{
			sprintf(error_string, "Grid not defined for %c coordinate", c[i]);
			error_msg(error_string, CONTINUE);
			input_error++;
			grid[i].coord =
				(double *) realloc(grid[i].coord,
								   (size_t) 2 * sizeof(double));
			if (grid[i].coord == NULL)
				malloc_error();
			grid[i].count_coord = 2;
			grid[i].coord[0] = 0.0;
			grid[i].coord[1] = 1.0;
			grid[i].uniform = TRUE;
		}
		else if (grid[i].uniform == TRUE)
		{
			x1 = grid[i].coord[0];
			x2 = grid[i].coord[1];
			if (x2 <= x1)
			{
				sprintf(error_string,
						"Coordinate values must be in ascending order for %c grid definition",
						grid[i].c);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			increment = (x2 - x1) / (grid[i].count_coord - 1);
			grid[i].coord =
				(double *) realloc(grid[i].coord,
								   (size_t) grid[i].count_coord *
								   sizeof(double));
			if (grid[i].coord == NULL)
			{
				sprintf(error_string, "Allocating grid %d, %d.", i,
						grid[i].count_coord);
				error_msg(error_string, CONTINUE);
				malloc_error();
			}
			for (j = 1; j < grid[i].count_coord; j++)
			{
				grid[i].coord[j] = x1 + ((double) j) * increment;
			}
			grid[i].uniform_expanded = TRUE;
			dimension[i] = grid[i].c;
		}
		else
		{
			for (j = 1; j < grid[i].count_coord; j++)
			{
				if (grid[i].coord[j] <= grid[i].coord[j - 1])
				{
					sprintf(error_string,
							"Coordinate values must be in ascending order for %c grid definition\n%g\t%g",
							grid[i].c, grid[i].coord[j - 1],
							grid[i].coord[j]);
					error_msg(error_string, CONTINUE);
					input_error++;
				}
			}
			dimension[i] = grid[i].c;
		}
	}
	/*
	 *  Overlays
	 */
	for (i = 0; i < count_grid_overlay; i++)
	{
		j = grid_overlay[i].direction;
		/*
		 *  convert to nonuniform
		 */
		grid[j].uniform = FALSE;
		grid_ptr = &grid_overlay[i];
		if (grid_ptr->uniform == TRUE)
		{
			d1 = grid_ptr->coord[0];
			d2 = grid_ptr->coord[1];
			grid_ptr->coord =
				(double *) realloc(grid_ptr->coord,
								   (size_t) grid_ptr->count_coord *
								   sizeof(double));
			if (grid_ptr->coord == NULL)
				malloc_error();
			for (k = 0; k < grid_ptr->count_coord; k++)
			{
				grid_ptr->coord[k] =
					d1 + (double) k *(d2 -
									  d1) / ((double) (grid_ptr->count_coord -
													   1));
			}
			grid_ptr->uniform = FALSE;
		}
		for (k = 1; k < grid_ptr->count_coord; k++)
		{
			if (grid_ptr->coord[k] <= grid_ptr->coord[k - 1])
			{
				sprintf(error_string,
						"Coordinate values must be in ascending order for %c grid overlay definition\n%g\t%g",
						grid[i].c, grid_ptr->coord[k - 1],
						grid_ptr->coord[k]);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
		}
		/* 
		 *  Merge nodes 
		 */
		count_nodes = grid[j].count_coord + grid_ptr->count_coord;
		nodes = (double *) malloc((size_t) count_nodes * sizeof(double));
		if (nodes == NULL)
			malloc_error();
		for (k = 0; k < grid[j].count_coord; k++)
		{
			nodes[k] = grid[j].coord[k];
		}
		start = k;
		for (k = 0; k < grid_ptr->count_coord; k++)
		{
			nodes[start + k] = grid_ptr->coord[k];
		}
		/*
		 *  Sort nodes
		 */
		qsort(nodes, (size_t) count_nodes, sizeof(double), double_compare);
		/*
		 * remove nodes too close
		 */
		n = 1;
		for (k = 1; k < count_nodes; k++)
		{
			if (nodes[k] - nodes[n - 1] > snap[j])
			{
				nodes[n++] = nodes[k];
			}
		}
		if (n < count_nodes)
		{
			if (nodes[n - 1] < grid[j].coord[grid[j].count_coord - 1])
			{
				nodes[n++] = grid[j].coord[grid[j].count_coord - 1];
			}
		}
		count_nodes = n;
		free_check_null(grid[j].coord);
		grid[j].coord = nodes;
		grid[j].count_coord = count_nodes;
	}
	if (input_error > 0)
	{
		error_msg("Stopping due to input errors.", STOP);
	}
	for (i = 0; i < 3; i++)
	{
		/*
		 *   Store element centroids
		 */
		grid[i].elt_centroid =
			(double *) malloc((size_t) (grid[i].count_coord - 1) *
							  sizeof(double));
		if (grid[i].elt_centroid == NULL)
			malloc_error();
		for (j = 0; j < grid[i].count_coord - 1; j++)
		{
			grid[i].elt_centroid[j] =
				(grid[i].coord[j] + grid[i].coord[j + 1]) * 0.5;
		}
	}
	if (input_error > 0)
	{
		error_msg("Stopping due to input errors.", STOP);
	}
	nx = grid[0].count_coord;
	ny = grid[1].count_coord;
	nz = grid[2].count_coord;
	nxyz = nx * ny * nz;
	/*
	 *   Allocate space for array of nodes that fills the domain
	 */
	cells = (struct cell *) malloc((size_t) nxyz * sizeof(struct cell));
	if (cells == NULL)
	{
		sprintf(error_string, "Not enough memory to allocate work space for"
				" entire domain.");
		error_msg(error_string, CONTINUE);
		malloc_error();
	}
	/*
	 *   assign number and coordinates
	 */
	count_cells = 0;
	for (k = 0; k < nz; k++)
	{
		for (j = 0; j < ny; j++)
		{
			for (i = 0; i < nx; i++)
			{
				cell_init(&(cells[count_cells]));
				cells[count_cells].number = count_cells;
				cells[count_cells].ix = i;
				cells[count_cells].iy = j;
				cells[count_cells].iz = k;

				cells[count_cells].x = grid[0].coord[i];
				cells[count_cells].y = grid[1].coord[j];
				cells[count_cells].z = grid[2].coord[k];
				count_cells++;
			}
		}
	}
	/*
	 *  define  zone for cells
	 */
	count = 0;
	for (k = 0; k < nz; k++)
	{
		for (j = 0; j < ny; j++)
		{
			for (i = 0; i < nx; i++)
			{
				if (i == 0)
				{
					cells[count].zone->x1 = grid[0].coord[i];
				}
				else
				{
					cells[count].zone->x1 =
						(grid[0].coord[i - 1] + grid[0].coord[i]) / 2;
				}

				if (j == 0)
				{
					cells[count].zone->y1 = grid[1].coord[j];
				}
				else
				{
					cells[count].zone->y1 =
						(grid[1].coord[j - 1] + grid[1].coord[j]) / 2;
				}

				if (k == 0)
				{
					cells[count].zone->z1 = grid[2].coord[k];
				}
				else
				{
					cells[count].zone->z1 =
						(grid[2].coord[k - 1] + grid[2].coord[k]) / 2;
				}

				if (i == nx - 1)
				{
					cells[count].zone->x2 = grid[0].coord[i];
				}
				else
				{
					cells[count].zone->x2 =
						(grid[0].coord[i] + grid[0].coord[i + 1]) / 2;
				}

				if (j == ny - 1)
				{
					cells[count].zone->y2 = grid[1].coord[j];
				}
				else
				{
					cells[count].zone->y2 =
						(grid[1].coord[j] + grid[1].coord[j + 1]) / 2;
				}

				if (k == nz - 1)
				{
					cells[count].zone->z2 = grid[2].coord[k];
				}
				else
				{
					cells[count].zone->z2 =
						(grid[2].coord[k] + grid[2].coord[k + 1]) / 2;
				}
				count++;
			}
		}
	}
	/*
	 *   Mark cells that represent elements
	 */
	for (k = 0; k < nz - 1; k++)
	{
		for (j = 0; j < ny - 1; j++)
		{
			for (i = 0; i < nx - 1; i++)
			{
				n = ijk_to_n(i, j, k);
				cells[n].is_element = TRUE;
				cells[n].elt_x =
					(grid[0].coord[i] + grid[0].coord[i + 1]) * 0.5;
				cells[n].elt_y =
					(grid[1].coord[j] + grid[1].coord[j + 1]) * 0.5;
				cells[n].elt_z =
					(grid[2].coord[k] + grid[2].coord[k + 1]) * 0.5;
			}
		}
	}
	/*
	 *  Calculate minimum distance between nodes in each direction
	 */
	for (k = 0; k < 3; k++)
	{
		grid[k].min =
			grid[k].coord[grid[k].count_coord - 1] - grid[k].coord[0];
		for (i = 1; i < grid[k].count_coord; i++)
		{
			diff = grid[k].coord[i] - grid[k].coord[i - 1];
			if (diff < grid[k].min)
				grid[k].min = diff;
		}
		grid[k].min *= 1e-6;
	}
	/*
	 *  Save locations of cells and elements
	 */
	for (i = 0; i < nxyz; i++)
	{
		cell_xyz->push_back(Point(cells[i].x, cells[i].y, cells[i].z));
		element_xyz->
			push_back(Point(cells[i].elt_x, cells[i].elt_y, cells[i].elt_z));
	}

	/*
	 *  Save zone of entire domain
	 */
	domain.x1 = grid[0].coord[0];
	domain.y1 = grid[1].coord[0];
	domain.z1 = grid[2].coord[0];
	domain.x2 = grid[0].coord[grid[0].count_coord - 1];
	domain.y2 = grid[1].coord[grid[1].count_coord - 1];
	domain.z2 = grid[2].coord[grid[2].count_coord - 1];

	return (OK);
}

/* ---------------------------------------------------------------------- */
int
ijk_to_n(int i, int j, int k)
/* ---------------------------------------------------------------------- */
{
	int n, return_value;
	n = nx * ny * k + nx * j + i;
	if (n >= 0 && n < nxyz)
	{
		return_value = n;
	}
	else
	{
		error_msg("i,j,k triple out of range.", CONTINUE);
		return_value = -1;
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
void
n_to_ijk(int n, int &i, int &j, int &k)
/* ---------------------------------------------------------------------- */
{
	assert(n >= 0 && n < count_cells);

	i = cells[n].ix;
	j = cells[n].iy;
	k = cells[n].iz;
	return;
}

/* ---------------------------------------------------------------------- */
void
neighbors(int n, std::vector < int >&stencil)
/* ---------------------------------------------------------------------- */
{
	assert(n >= 0 && n < count_cells);
	stencil.clear();

	// stencil has 7 elements, index numbers for x-, x+, y-, y+, z-, z+, top of column
	int i, j, k, m;
	for (i = 0; i < 7; i++)
	{
		stencil.push_back(-1);
	}
	n_to_ijk(n, i, j, k);
	if (i > 0)
	{
		m = ijk_to_n(i - 1, j, k);
		//if (cells[m].cell_active)
		{
			stencil[0] = m;
		}
	}
	if (i < nx - 1)
	{
		m = ijk_to_n(i + 1, j, k);
		//if (cells[m].cell_active)
		{
			stencil[1] = m;
		}
	}
	if (j > 0)
	{
		m = ijk_to_n(i, j - 1, k);
		//if (cells[m].cell_active)
		{
			stencil[2] = m;
		}
	}
	if (j < ny - 1)
	{
		m = ijk_to_n(i, j + 1, k);
		//if (cells[m].cell_active)
		{
			stencil[3] = m;
		}
	}
	if (k > 0)
	{
		m = ijk_to_n(i, j, k - 1);
		//if (cells[m].cell_active)
		{
			stencil[4] = m;
		}
	}
	if (k < nz - 1)
	{
		m = ijk_to_n(i, j, k + 1);
		//if (cells[m].cell_active)
		{
			stencil[5] = m;
		}
	}
	stencil[6] = ijk_to_n(i, j, nz - 1);


	return;
}
/* ---------------------------------------------------------------------- */
void
elt_neighbors(int n, std::vector < int >&stencil)
/* ---------------------------------------------------------------------- */
{

	// n is a cell number
	// stencil returns 8 element numbers, -1 if missing or inactive

	assert(n >= 0 && n < count_cells);
	stencil.clear();

	// stencil has 8 elements that contain a node
	int i, j, k, m;
	for (i = 0; i < 8; i++)
	{
		stencil.push_back(-1);
	}
	n_to_ijk(n, i, j, k);

	// find elements in natural order, lower plane
	if (i - 1 >= 0 && j - 1 >= 0 && k - 1 >= 0)
	{
		m = ijk_to_n(i - 1, j - 1, k - 1);
		if (cells[m].is_element && cells[m].elt_active)
		{
			stencil[0] = m;
		}
	}
	if (i >= 0 && j - 1 >= 0 && k - 1 >= 0)
	{
		m = ijk_to_n(i, j - 1, k - 1);
		if (cells[m].is_element && cells[m].elt_active)
		{
			stencil[1] = m;
		}
	}
	if (i - 1 >= 0 && j >= 0 && k - 1 >= 0)
	{
		m = ijk_to_n(i - 1, j, k - 1);
		if (cells[m].is_element && cells[m].elt_active)
		{
			stencil[2] = m;
		}
	}
	if (i >= 0 && j >= 0 && k - 1 >= 0)
	{
		m = ijk_to_n(i, j, k - 1);
		if (cells[m].is_element && cells[m].elt_active)
		{
			stencil[3] = m;
		}
	}

	// find elements in natural order, upper plane
	if (i - 1 >= 0 && j - 1 >= 0 && k >= 0)
	{
		m = ijk_to_n(i - 1, j - 1, k);
		if (cells[m].is_element && cells[m].elt_active)
		{
			stencil[4] = m;
		}
	}
	if (i >= 0 && j - 1 >= 0 && k >= 0)
	{
		m = ijk_to_n(i, j - 1, k);
		if (cells[m].is_element && cells[m].elt_active)
		{
			stencil[5] = m;
		}
	}
	if (i - 1 >= 0 && j >= 0 && k >= 0)
	{
		m = ijk_to_n(i - 1, j, k);
		if (cells[m].is_element && cells[m].elt_active)
		{
			stencil[6] = m;
		}
	}
	if (i >= 0 && j >= 0 && k >= 0)
	{
		m = ijk_to_n(i, j, k);
		if (cells[m].is_element && cells[m].elt_active)
		{
			stencil[7] = m;
		}
	}

	return;
}
/* ---------------------------------------------------------------------- */
struct index_range *
zone_to_range(struct zone *zone_ptr)
	/* ---------------------------------------------------------------------- */
{
	struct index_range *range_ptr;
	int i1, i2, j1, j2, k1, k2;

	/* 
	 *    check zone data
	 */
	if (zone_ptr->zone_defined == UNDEFINED || zone_check(zone_ptr) == ERROR)
	{
		return (NULL);
	}
	if (coords_to_range(zone_ptr->x1, zone_ptr->x2,
						grid[0].coord, grid[0].count_coord, grid[0].min,
						grid[0].uniform, &i1, &i2) == ERROR)
	{
		return (NULL);
	}
	if (coords_to_range(zone_ptr->y1, zone_ptr->y2,
						grid[1].coord, grid[1].count_coord, grid[1].min,
						grid[1].uniform, &j1, &j2) == ERROR)
	{
		return (NULL);
	}
	if (coords_to_range(zone_ptr->z1, zone_ptr->z2,
						grid[2].coord, grid[2].count_coord, grid[2].min,
						grid[2].uniform, &k1, &k2) == ERROR)
	{
		return (NULL);
	}
	range_ptr = (struct index_range *) malloc(sizeof(struct index_range));
	if (range_ptr == NULL)
		malloc_error();
	range_ptr->i1 = i1;
	range_ptr->i2 = i2;
	range_ptr->j1 = j1;
	range_ptr->j2 = j2;
	range_ptr->k1 = k1;
	range_ptr->k2 = k2;
	return (range_ptr);
}

/* ---------------------------------------------------------------------- */
struct index_range *
zone_to_elt_range(struct zone *zone_ptr, const bool silent)
	/* ---------------------------------------------------------------------- */
{
	struct index_range *range_ptr;
	int i1, i2, j1, j2, k1, k2;

	/* 
	 *    check zone data
	 */
	if (zone_ptr->zone_defined == UNDEFINED || zone_check(zone_ptr) == ERROR)
	{
		return (NULL);
	}
	if (coords_to_elt_range(zone_ptr->x1, zone_ptr->x2,
							grid[0].elt_centroid, grid[0].count_coord - 1,
							grid[0].min, grid[0].uniform, &i1, &i2, silent) == ERROR)
	{
		return (NULL);
	}
	if (coords_to_elt_range(zone_ptr->y1, zone_ptr->y2,
							grid[1].elt_centroid, grid[1].count_coord - 1,
							grid[1].min, grid[1].uniform, &j1, &j2, silent) == ERROR)
	{
		return (NULL);
	}
	if (coords_to_elt_range(zone_ptr->z1, zone_ptr->z2,
							grid[2].elt_centroid, grid[2].count_coord - 1,
							grid[2].min, grid[2].uniform, &k1, &k2, silent) == ERROR)
	{
		return (NULL);
	}
	range_ptr = (struct index_range *) malloc(sizeof(struct index_range));
	if (range_ptr == NULL)
		malloc_error();
	range_ptr->i1 = i1;
	range_ptr->i2 = i2;
	range_ptr->j1 = j1;
	range_ptr->j2 = j2;
	range_ptr->k1 = k1;
	range_ptr->k2 = k2;
	return (range_ptr);
}

/* ---------------------------------------------------------------------- */
int
coords_to_range(double x1, double x2, double *coord, int count_coord,
				double eps, int uniform, int *i1, int *i2)
					/* ---------------------------------------------------------------------- */
{
	int i;
	if (uniform == UNDEFINED)
	{
		*i1 = 0;
		*i2 = 1;
		return (OK);
	}
	*i1 = count_coord;
	*i2 = 0;
	for (i = 0; i < count_coord; i++)
	{
		if (coord[i] >= x1 - eps)
		{
			*i1 = i;
			break;
		}
	}
	if (*i1 >= count_coord)
	{
		error_msg("Zone is outside domain", CONTINUE);
		return (ERROR);
	}
	if (x2 + eps < coord[i])
	{
		error_msg("Zone is empty", CONTINUE);
		return (ERROR);
	}
	for (; i < count_coord; i++)
	{
		if (coord[i] <= x2 + eps)
		{
			*i2 = i;
		}
		else
		{
			break;
		}
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
coords_to_elt_range(double x1, double x2, double *coord, int count_coord,
					double eps, int uniform, int *i1, int *i2, const bool silent)
/* ---------------------------------------------------------------------- */
{
	int i;
	if (uniform == UNDEFINED)
	{
		*i1 = 0;
		*i2 = 1;
		return (OK);
	}
	*i1 = 0;
	*i2 = 1;
	for (i = 0; i < count_coord; i++)
	{
		if (coord[i] >= x1 - eps)
		{
			*i1 = i;
			break;
		}
	}
	if (i >= count_coord)
	{
		if (!silent)
		{
			warning_msg("Zone is outside all element centroids.");
			return (ERROR);
		}
	}
	if (x2 + eps < coord[i])
	{
		if (!silent)
		{
			warning_msg("Zone does not contain centroids of any elements.");
			return (ERROR);
		}
	}
	for (; i < count_coord; i++)
	{
		if (coord[i] <= x2 + eps)
		{
			*i2 = i;
		}
		else
		{
			break;
		}
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
setup_head_ic(void)
/* ---------------------------------------------------------------------- */
{
	int i, n;
	int ii, jj, kk, nn;
	int return_value;
	struct index_range *range_ptr;
	int head_ic_type;

	head_ic_type = UNDEFINED;
	for (i = 0; i < count_head_ic; i++)
	{
		sprintf(tag, "in HEAD_IC, definition %d.\n", i + 1);
		switch (head_ic[i]->ic_type)
		{
		case UNDEFINED:
			input_error++;
			sprintf(error_string, "Initial condition type undefined %s", tag);
			error_msg(error_string, CONTINUE);
			break;
		case ZONE:
			if (head_ic_type != UNDEFINED && head_ic_type != ZONE)
			{
				sprintf(error_string,
						"ZONE and WATER_TABLE are mutually exclusive initial conditions %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = ERROR;
			}

			if (head_ic[i]->polyh == NULL)
			{
				input_error++;
				sprintf(error_string, "No zone definition %s", tag);
				error_msg(error_string, CONTINUE);
				break;
			}
			else
			{
				struct zone *zone_ptr = head_ic[i]->polyh->Get_bounding_box();
				range_ptr = zone_to_range(zone_ptr);
				std::list < int >list_of_cells;
				range_to_list(range_ptr, list_of_cells);
				free_check_null(range_ptr);
				range_ptr = NULL;
				{
					head_ic[i]->polyh->Points_in_polyhedron(list_of_cells,
															*cell_xyz);
					if (list_of_cells.size() == 0)
					{
						input_error++;
						sprintf(error_string,
								"Bad zone or wedge definition %s", tag);
						error_msg(error_string, CONTINUE);
						break;
					}
					if (head_ic[i]->head != NULL)
					{
						if (distribute_property_to_list_of_cells
							(list_of_cells, head_ic[i]->mask,
							 head_ic[i]->head, offsetof(struct cell, ic_head),
							 offsetof(struct cell, ic_head_defined),
							 PT_DOUBLE, FALSE, 0,
							 BC_info::BC_UNDEFINED) == ERROR)
						{
							input_error++;
							sprintf(error_string, "Bad head definition %s",
									tag);
							error_msg(error_string, CONTINUE);
						}
					}
					//free_check_null(range_ptr);
					head_ic_type = ZONE;
				}
			}
			break;
		case WATER_TABLE:
			if (head_ic_type != UNDEFINED && head_ic_type != WATER_TABLE)
			{
				sprintf(error_string,
						"ZONE and WATER_TABLE are mutually exclusive initial conditions %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = ERROR;
			}
			if (head_ic_type == WATER_TABLE)
			{
				sprintf(error_string, "Water_table has been redefined %s",
						tag);
				warning_msg(error_string);
			}
			if (head_ic[i]->head == NULL)
			{
				sprintf(error_string,
						"Heads for water_table have not been defined %s",
						tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			if (head_ic[i]->head->count_v != nx * ny)
			{
				sprintf(error_string,
						"Number of head values for water table, %d, not equal nx * ny, %d %s",
						head_ic[i]->head->count_v, nx * ny, tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				break;
			}

			/* copy data vertically from head_list to cells */
			for (ii = 0; ii < nx; ii++)
			{
				for (jj = 0; jj < ny; jj++)
				{
					nn = jj * nx + ii;
					for (kk = 0; kk < nz; kk++)
					{
						n = ijk_to_n(ii, jj, kk);
						cells[n].ic_head = head_ic[i]->head->v[nn];
						cells[n].ic_head_defined = TRUE;
					}
				}
			}
			head_ic_type = WATER_TABLE;
			break;
		}
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
setup_print_locations(struct print_zones_struct *print_zones_struct_ptr,
					  size_t offset1, size_t offset2)
/* ---------------------------------------------------------------------- */
{
	int i;
	int j, j1, i0, i1, i2, n, count, quit;
	struct index_range *range_ptr;

	/* set print flags for subgrid */
	if (print_zones_struct_ptr->thin_grid[0] > 0
		|| print_zones_struct_ptr->thin_grid[1] > 0
		|| print_zones_struct_ptr->thin_grid[2] > 0)
	{
		for (i = 0; i < 3; i++)
		{
			if (print_zones_struct_ptr->thin_grid_list[i] != NULL)
				free_check_null(print_zones_struct_ptr->thin_grid_list[i]);
			print_zones_struct_ptr->thin_grid_list[i] =
				(int *) malloc((size_t) (grid[i].count_coord * sizeof(int)));
			if (print_zones_struct_ptr->thin_grid_list[i] == NULL)
				malloc_error();
			if (print_zones_struct_ptr->thin_grid[i] <= 0)
			{
				/* print all node numbers */
				for (j = 0; j < grid[i].count_coord; j++)
				{
					print_zones_struct_ptr->thin_grid_list[i][j] = j;
				}
				print_zones_struct_ptr->thin_grid_count[i] =
					grid[i].count_coord;
			}
			else
			{
				/* make list of node numbers to print */
				j = 0 - print_zones_struct_ptr->thin_grid[i];
				j1 = (grid[i].count_coord - 1) +
					print_zones_struct_ptr->thin_grid[i];
				count = 0;
				quit = FALSE;
				while (quit == FALSE)
				{
					j = j + print_zones_struct_ptr->thin_grid[i];
					if (j < j1)
					{
						print_zones_struct_ptr->thin_grid_list[i][count++] =
							j;
					}
					else
					{
						quit = TRUE;
					}
					j1 = j1 - print_zones_struct_ptr->thin_grid[i];
					if (j1 > j)
					{
						print_zones_struct_ptr->thin_grid_list[i][count++] =
							j1;
					}
					else
					{
						quit = TRUE;
					}
				}
				print_zones_struct_ptr->thin_grid_count[i] = count;
				/*
				 *  Sort node indexes
				 */
				qsort(print_zones_struct_ptr->thin_grid_list[i],
					  (size_t) count, sizeof(int), int_compare);
			}
		}
		for (i = 0; i < nxyz; i++)
		{
			*(int *) ((char *) &(cells[i]) + offset1) = 0;
			*(int *) ((char *) &(cells[i]) + offset2) = TRUE;
			/*
			   cells[i].print = 0;
			   cells[i].print_defined = TRUE;
			 */
		}
		for (i0 = 0; i0 < print_zones_struct_ptr->thin_grid_count[0]; i0++)
		{
			for (i1 = 0; i1 < print_zones_struct_ptr->thin_grid_count[1];
				 i1++)
			{
				for (i2 = 0; i2 < print_zones_struct_ptr->thin_grid_count[2];
					 i2++)
				{
					n = ijk_to_n(print_zones_struct_ptr->
								 thin_grid_list[0][i0],
								 print_zones_struct_ptr->
								 thin_grid_list[1][i1],
								 print_zones_struct_ptr->
								 thin_grid_list[2][i2]);
					/* cells[n].print = 1; */
					*(int *) ((char *) &(cells[n]) + offset1) = 1;
				}
			}
		}
	}
	for (i = 0; i < print_zones_struct_ptr->count_print_zones; i++)
	{
		sprintf(tag, "in PRINT_LOCATIONS, definition %d.\n", i + 1);

		if (print_zones_struct_ptr->print_zones[i].polyh == NULL)
		{
			input_error++;
			sprintf(error_string, "No zone definition %s", tag);
			error_msg(error_string, CONTINUE);
			break;
		}
		else
		{
			struct zone *zone_ptr =
				print_zones_struct_ptr->print_zones[i].polyh->
				Get_bounding_box();
			range_ptr = zone_to_range(zone_ptr);
			if (range_ptr == NULL)
			{
				input_error++;
				sprintf(error_string, "Bad zone or wedge definition %s", tag);
				error_msg(error_string, CONTINUE);
				break;
			}
			std::list < int >list_of_cells;
			range_to_list(range_ptr, list_of_cells);
			free_check_null(range_ptr);
			range_ptr = NULL;
			print_zones_struct_ptr->print_zones[i].polyh->
				Points_in_polyhedron(list_of_cells, *cell_xyz);

			if (list_of_cells.size() == 0)
			{
				input_error++;
				sprintf(error_string, "Bad zone or wedge definition %s", tag);
				error_msg(error_string, CONTINUE);
				break;
			}
			if (print_zones_struct_ptr->print_zones[i].print != NULL)
			{
				if (distribute_property_to_list_of_cells(list_of_cells,
														 print_zones_struct_ptr->
														 print_zones[i].mask,
														 print_zones_struct_ptr->
														 print_zones[i].print,
														 offset1, offset2,
														 PT_INTEGER, FALSE, 0,
														 BC_info::
														 BC_UNDEFINED) ==
					ERROR)
				{
					input_error++;
					sprintf(error_string, "Bad print definition %s", tag);
					error_msg(error_string, CONTINUE);
				}
			}
		}
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
distribute_property_to_list_of_cells(std::list < int >&pts,	// list of cell numbers in natural order
									 struct property *mask,
									 struct property *property_ptr,
									 size_t offset, size_t offset_defined,
									 property_type p_type,
									 int match_bc_type,
									 int face, BC_info::BC_TYPE bc_type)
/* ---------------------------------------------------------------------- */
{
	int n, node_sequence;
	int *i_ptr;
	double value, mask_value;
	double *d_ptr;
	struct mix *mix_ptr;
	n = pts.size();
	if (property_ptr->type == PROP_ZONE)
	{
		if (n != property_ptr->count_v)
		{
			sprintf(error_string, "Zone has %d nodes,"
					" property has %d values.", n, property_ptr->count_v);
			error_msg(error_string, CONTINUE);
			input_error++;
			return (ERROR);
		}
	}
	if (property_ptr->type == PROP_MIXTURE)
	{
		if (n != property_ptr->count_v - 2)
		{
			sprintf(error_string, "Zone has %d nodes,"
					" property has %d values.", n, property_ptr->count_v - 2);
			error_msg(error_string, CONTINUE);
			input_error++;
			return (ERROR);
		}
	}
	if (mask != NULL && mask->type == PROP_ZONE)
	{
		if (n != mask->count_v)
		{
			sprintf(error_string, "Zone has %d nodes,"
					" mask has %d values.", n, mask->count_v);
			error_msg(error_string, CONTINUE);
			input_error++;
			return (ERROR);
		}
	}
	node_sequence = 0;
	for (std::list < int >::iterator it = pts.begin(); it != pts.end(); it++)
	{
		n = *it;
		mask_value = 1;
		if (mask != NULL)
		{
			if (get_double_property_for_cell
				(&(cells[n]), mask, node_sequence, &mask_value) == ERROR)
			{
				error_msg("Error in mask.", CONTINUE);
				return (ERROR);
			}
		}
		if (mask_value > 0)
		{
			//if (match_bc_type == TRUE && cells[n].bc_face[face].bc_type != bc_type) continue;
			if (p_type == PT_MIX)
			{
				mix_ptr = (struct mix *) ((char *) &(cells[n]) + offset);
				if (get_mix_property_for_cell
					(&(cells[n]), property_ptr, node_sequence,
					 mix_ptr) == ERROR)
				{
					return (ERROR);
				}
			}
			else if (p_type == PT_INTEGER)
			{
				/*
				   if (get_integer_property_value(&(cells[n]), property_ptr, node_sequence, &value, &integer_value) == ERROR) {
				   return(ERROR);
				   } 
				 */
				if (get_double_property_for_cell
					(&(cells[n]), property_ptr, node_sequence,
					 &value) == ERROR)
				{
					return (ERROR);
				}
				i_ptr = (int *) ((char *) &(cells[n]) + offset);
				if (value > 0)
				{
					*i_ptr = TRUE;
				}
				else
				{
					*i_ptr = FALSE;
				}
			}
			else if (p_type == PT_DOUBLE)
			{
				if (get_double_property_for_cell
					(&(cells[n]), property_ptr, node_sequence,
					 &value) == ERROR)
				{
					return (ERROR);
				}
				d_ptr = (double *) ((char *) &(cells[n]) + offset);
				*d_ptr = value;
			}
			else
			{
				error_msg
					("Unknown property type in distribute_property_to_cells",
					 STOP);
			}
			i_ptr = (int *) ((char *) &(cells[n]) + offset_defined);
			*i_ptr = TRUE;
		}
		node_sequence++;
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
distribute_property_to_list_of_elements(std::list < int >&pts,	// list of cell numbers in natural order
										struct property *mask,
										struct property *property_ptr,
										size_t offset, size_t offset_defined,
										int integer)
/* ---------------------------------------------------------------------- */
{
	int n, element_sequence;
	int integer_value;
	int *i_ptr;
	double value, mask_value;
	double *d_ptr;
	/*
	 *  element_sequence tells which property value to retrieve from a list
	 */
	n = pts.size();
	if (n <= 0)
	{
		sprintf(error_string, "Zone contains no elements.");
		error_msg(error_string, CONTINUE);
		input_error++;
		return (ERROR);
	}
	if (property_ptr->type == PROP_ZONE)
	{
		if (n != property_ptr->count_v)
		{
			sprintf(error_string, "Zone has %d elements,"
					" property has %d values.", n, property_ptr->count_v);
			error_msg(error_string, CONTINUE);
			input_error++;
			return (ERROR);
		}
	}
	if (mask != NULL && mask->type == PROP_LINEAR)
	{
		sprintf(error_string,
				"LINEAR property definition not allowed for mask.");
		error_msg(error_string, CONTINUE);
		input_error++;
		return (ERROR);
	}
	if (mask != NULL && mask->type == PROP_ZONE)
	{
		if (n != mask->count_v)
		{
			sprintf(error_string, "Zone has %d elements,"
					" mask has %d values.", n, mask->count_v);
			error_msg(error_string, CONTINUE);
			input_error++;
			return (ERROR);
		}
	}
	if (property_ptr->type == PROP_MIXTURE ||
		property_ptr->type == PROP_MIX_CONSTANT ||
		property_ptr->type == PROP_MIX_POINTS ||
		property_ptr->type == PROP_MIX_XYZ
		)
	{
		input_error++;
		error_msg("MIXTURE option not allowed for this property", CONTINUE);
		return (ERROR);
	}
	element_sequence = 0;
	for (std::list < int >::iterator it = pts.begin(); it != pts.end(); it++)
	{
		n = *it;
		mask_value = 1;
		if (mask != NULL)
		{
			if (get_property_for_element
				(&(cells[n]), mask, element_sequence, &mask_value,
				 &integer_value) == ERROR)
			{
				error_msg("Error in mask.", CONTINUE);
				return (ERROR);
			}
		}
		if (mask_value > 0)
		{
			if (cells[n].is_element == FALSE)
			{
				error_msg("Node is not an element node.", CONTINUE);
			}
			if (get_property_for_element
				(&(cells[n]), property_ptr, element_sequence, &value,
				 &integer_value) == ERROR)
			{
				return (ERROR);
			}
			if (integer == TRUE)
			{
				i_ptr = (int *) ((char *) &(cells[n]) + offset);
				if (value > 0)
				{
					*i_ptr = TRUE;
				}
				else
				{
					*i_ptr = FALSE;
				}
			}
			else
			{
				d_ptr = (double *) ((char *) &(cells[n]) + offset);
				*d_ptr = value;
			}
			i_ptr = (int *) ((char *) &(cells[n]) + offset_defined);
			*i_ptr = TRUE;
		}
		element_sequence++;
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
get_double_property_for_cell(struct cell *cell_ptr,
							 struct property *property_ptr, int node_sequence,
							 double *value)
/* ---------------------------------------------------------------------- */
{
	double slope, b;
	*value = 0;
	switch (property_ptr->type)
	{
	case PROP_UNDEFINED:
		input_error++;
		error_msg("Property type is not defined", CONTINUE);
		return (ERROR);
		break;
	case PROP_FIXED:
		*value = property_ptr->v[0];
		break;
	case PROP_ZONE:
		if (node_sequence >= property_ptr->count_v)
		{
			error_msg("OOPS in get_property_value", CONTINUE);
			return (ERROR);
		}
		*value = property_ptr->v[node_sequence];
		break;
	case PROP_MIXTURE:
	case PROP_MIX_POINTS:
	case PROP_MIX_XYZ:
	case PROP_MIX_CONSTANT:
		input_error++;
		error_msg("MIXTURE option not allowed for this property", CONTINUE);
		return (ERROR);
		break;
	case PROP_LINEAR:
		{
			double dist;
			if (property_ptr->coord == 'x')
			{
				dist = cell_ptr->x;
			}
			if (property_ptr->coord == 'y')
			{
				dist = cell_ptr->y;
			}
			if (property_ptr->coord == 'z')
			{
				dist = cell_ptr->z;
			}
			if (dist <= property_ptr->dist1)
			{
				*value = property_ptr->v[0];
			}
			else if (dist >= property_ptr->dist2)
			{
				*value = property_ptr->v[1];
			}
			else
			{
				if ((property_ptr->dist2 - property_ptr->dist1) != 0)
				{
					slope =
						(property_ptr->v[1] -
						 property_ptr->v[0]) / (property_ptr->dist2 -
												property_ptr->dist1);
				}
				else
				{
					slope = 0;
				}
				b = property_ptr->v[0] - slope * property_ptr->dist1;
				*value = dist * slope + b;
			}
		}
		break;
	case PROP_POINTS:
	case PROP_XYZ:
		Point pt(cell_ptr->x, cell_ptr->y, cell_ptr->z);
		*value = property_ptr->data_source->Get_tree3d()->Interpolate3d(pt);
		break;
	}


	return (OK);
}

/* ---------------------------------------------------------------------- */
int
get_mix_property_for_cell(struct cell *cell_ptr,
						  struct property *property_ptr, int node_sequence,
						  struct mix *mix_ptr)
/* ---------------------------------------------------------------------- */
{
	switch (property_ptr->type)
	{
	case PROP_UNDEFINED:
		input_error++;
		error_msg("Property type is not defined", CONTINUE);
		return (ERROR);
		break;
	case PROP_FIXED:
		mix_ptr->i1 = (int) floor(property_ptr->v[0] + 1e-8);
		mix_ptr->i2 = -1;
		mix_ptr->f1 = 1.0;
		break;
	case PROP_ZONE:
		if (node_sequence >= property_ptr->count_v)
		{
			error_msg("OOPS in get_property_value", CONTINUE);
			return (ERROR);
		}
		mix_ptr->i1 = (int) (floor(property_ptr->v[node_sequence] + 1e-8));
		mix_ptr->i2 = -1;
		mix_ptr->f1 = 1.0;
		break;
	case PROP_MIX_POINTS:
	case PROP_MIX_XYZ:
		{
			mix_ptr->i1 = (int) floor(property_ptr->v[0] + 1e-8);
			mix_ptr->i2 = (int) floor(property_ptr->v[1] + 1e-8);
			Point pt(cell_ptr->x, cell_ptr->y, cell_ptr->z);
			mix_ptr->f1 =
				property_ptr->data_source->Get_tree3d()->Interpolate3d(pt);
		}
		break;
	case PROP_MIX_CONSTANT:
		{
			mix_ptr->i1 = (int) floor(property_ptr->v[0] + 1e-8);
			mix_ptr->i2 = (int) floor(property_ptr->v[1] + 1e-8);
			mix_ptr->f1 = property_ptr->data_source->Interpolate(Point(0,0,0));
		}
		break;
	case PROP_MIXTURE:
		mix_ptr->i1 = (int) floor(property_ptr->v[0] + 1e-8);
		mix_ptr->i2 = (int) floor(property_ptr->v[1] + 1e-8);
		mix_ptr->f1 = property_ptr->v[node_sequence + 2];
		break;
	case PROP_LINEAR:
		mix_ptr->i1 = (int) floor(property_ptr->v[0] + 1e-8);
		mix_ptr->i2 = (int) floor(property_ptr->v[1] + 1e-8);
		if ((property_ptr->dist2 - property_ptr->dist1) == 0)
		{
			mix_ptr->f1 = 1;
		}
		else
		{
			if (property_ptr->coord == 'x')
			{
				mix_ptr->f1 =
					(property_ptr->dist2 -
					 cell_ptr->x) / (property_ptr->dist2 -
									 property_ptr->dist1);
			}
			if (property_ptr->coord == 'y')
			{
				mix_ptr->f1 =
					(property_ptr->dist2 -
					 cell_ptr->y) / (property_ptr->dist2 -
									 property_ptr->dist1);
			}
			if (property_ptr->coord == 'z')
			{
				mix_ptr->f1 =
					(property_ptr->dist2 -
					 cell_ptr->z) / (property_ptr->dist2 -
									 property_ptr->dist1);
			}
			if (mix_ptr->f1 > 1)
				mix_ptr->f1 = 1;
			if (mix_ptr->f1 < 0)
				mix_ptr->f1 = 0;
		}
		break;
	case PROP_POINTS:
	case PROP_XYZ:
		{
			double value;
			Point pt(cell_ptr->x, cell_ptr->y, cell_ptr->z);
			value =
				property_ptr->data_source->Get_tree3d()->Interpolate3d(pt);
			mix_ptr->i1 = (int) (value + 1e-8);
			mix_ptr->i2 = -1;
			mix_ptr->f1 = 1.0;
		}
		break;
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
get_property_for_element(struct cell *cell_ptr, struct property *property_ptr,
						 int node_sequence, double *value, int *integer_value)
/* ---------------------------------------------------------------------- */
{
	double slope, b;
	*value = 0;
	*integer_value = 0;

	switch (property_ptr->type)
	{
	case PROP_UNDEFINED:
		input_error++;
		error_msg("Property type is not defined", CONTINUE);
		return (ERROR);
		break;
	case PROP_FIXED:
		*value = property_ptr->v[0];
		break;
	case PROP_ZONE:
		if (node_sequence >= property_ptr->count_v)
		{
			error_msg("OOPS in get_property_for_element", CONTINUE);
			return (ERROR);
		}
		*value = property_ptr->v[node_sequence];
		break;
	case PROP_MIXTURE:
	case PROP_MIX_POINTS:
	case PROP_MIX_XYZ:
	case PROP_MIX_CONSTANT:
		input_error++;
		error_msg("MIXTURE option not allowed for this property", CONTINUE);
		return (ERROR);
		break;
	case PROP_LINEAR:
		{
			double dist;
			if (property_ptr->coord == 'x')
			{
				dist = cell_ptr->elt_x;
			}
			if (property_ptr->coord == 'y')
			{
				dist = cell_ptr->elt_y;
			}
			if (property_ptr->coord == 'z')
			{
				dist = cell_ptr->elt_z;
			}
			if (dist <= property_ptr->dist1)
			{
				*value = property_ptr->v[0];
			}
			else if (dist >= property_ptr->dist2)
			{
				*value = property_ptr->v[1];
			}
			else
			{
				if ((property_ptr->dist2 - property_ptr->dist1) != 0)
				{
					slope =
						(property_ptr->v[1] -
						 property_ptr->v[0]) / (property_ptr->dist2 -
												property_ptr->dist1);
				}
				else
				{
					slope = 0;
				}
				b = property_ptr->v[0] - slope * property_ptr->dist1;
				*value = dist * slope + b;
			}
		}
		break;
	case PROP_POINTS:
	case PROP_XYZ:
		{
			Point pt(cell_ptr->elt_x, cell_ptr->elt_y, cell_ptr->elt_z);
			*value =
				property_ptr->data_source->Get_tree3d()->Interpolate3d(pt);
		}
		break;
	}
	*integer_value = (int) floor(*value + 1e-8);
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
setup_chem_ic(void)
/* ---------------------------------------------------------------------- */
{
	int i;
	struct index_range *range_ptr;

	for (i = 0; i < count_chem_ic; i++)
	{
		sprintf(tag, "in CHEMISTRY_IC, definition %d.\n", i + 1);

		if (chem_ic[i]->polyh == NULL)
		{
			input_error++;
			sprintf(error_string, "No zone or wedge definition %s", tag);
			error_msg(error_string, CONTINUE);
			break;
		}
		else
		{
			struct zone *zone_ptr = chem_ic[i]->polyh->Get_bounding_box();
			range_ptr = zone_to_range(zone_ptr);
			if (range_ptr == NULL)
			{
				input_error++;
				sprintf(error_string, "Bad zone or wedge definition %s", tag);
				error_msg(error_string, CONTINUE);
				break;
			}
			std::list < int >list_of_cells;
			range_to_list(range_ptr, list_of_cells);
			free_check_null(range_ptr);
			range_ptr = NULL;
			chem_ic[i]->polyh->Points_in_polyhedron(list_of_cells, *cell_xyz);

			if (list_of_cells.size() == 0)
			{
				input_error++;
				sprintf(error_string, "Bad zone or wedge definition %s", tag);
				error_msg(error_string, CONTINUE);
				break;
			}

			/*
			 *   Solution initial condition
			 */
			if (chem_ic[i]->solution != NULL)
			{
				if (distribute_property_to_list_of_cells(list_of_cells,
														 chem_ic[i]->mask,
														 chem_ic[i]->solution,
														 offsetof(struct cell,
																  ic_solution),
														 offsetof(struct cell,
																  ic_solution_defined),
														 PT_MIX, FALSE, 0,
														 BC_info::
														 BC_UNDEFINED) ==
					ERROR)
				{
					sprintf(error_string, "Bad solution definition %s", tag);
					error_msg(error_string, CONTINUE);
					input_error++;
				}
			}
			/*
			 *   Equilibrium_Phases initial condition
			 */
			if (chem_ic[i]->equilibrium_phases != NULL)
			{
				if (distribute_property_to_list_of_cells(list_of_cells,
														 chem_ic[i]->mask,
														 chem_ic[i]->
														 equilibrium_phases,
														 offsetof(struct cell,
																  ic_equilibrium_phases),
														 offsetof(struct cell,
																  ic_equilibrium_phases_defined),
														 PT_MIX, FALSE, 0,
														 BC_info::
														 BC_UNDEFINED) ==
					ERROR)
				{
					sprintf(error_string,
							"Bad equilibrium_phases definition %s", tag);
					error_msg(error_string, CONTINUE);
					input_error++;
				}
			}
			/*
			 *   Exchange initial condition
			 */
			if (chem_ic[i]->exchange != NULL)
			{
				if (distribute_property_to_list_of_cells(list_of_cells,
														 chem_ic[i]->mask,
														 chem_ic[i]->exchange,
														 offsetof(struct cell,
																  ic_exchange),
														 offsetof(struct cell,
																  ic_exchange_defined),
														 PT_MIX, FALSE, 0,
														 BC_info::
														 BC_UNDEFINED) ==
					ERROR)
				{
					sprintf(error_string, "Bad exchange definition %s", tag);
					error_msg(error_string, CONTINUE);
					input_error++;
				}
			}
			/*
			 *   Surface initial condition
			 */
			if (chem_ic[i]->surface != NULL)
			{
				if (distribute_property_to_list_of_cells(list_of_cells,
														 chem_ic[i]->mask,
														 chem_ic[i]->surface,
														 offsetof(struct cell,
																  ic_surface),
														 offsetof(struct cell,
																  ic_surface_defined),
														 PT_MIX, FALSE, 0,
														 BC_info::
														 BC_UNDEFINED) ==
					ERROR)
				{
					sprintf(error_string, "Bad surface definition %s", tag);
					error_msg(error_string, CONTINUE);
					input_error++;
				}
			}
			/*
			 *   Gas_Phase initial condition
			 */
			if (chem_ic[i]->gas_phase != NULL)
			{
				if (distribute_property_to_list_of_cells(list_of_cells,
														 chem_ic[i]->mask,
														 chem_ic[i]->
														 gas_phase,
														 offsetof(struct cell,
																  ic_gas_phase),
														 offsetof(struct cell,
																  ic_gas_phase_defined),
														 PT_MIX, FALSE, 0,
														 BC_info::
														 BC_UNDEFINED) ==
					ERROR)
				{
					sprintf(error_string, "Bad gas_phase definition %s", tag);
					error_msg(error_string, CONTINUE);
					input_error++;
				}
			}
			/*
			 *   Solid_Solutions initial condition
			 */
			if (chem_ic[i]->solid_solutions != NULL)
			{
				if (distribute_property_to_list_of_cells(list_of_cells,
														 chem_ic[i]->mask,
														 chem_ic[i]->
														 solid_solutions,
														 offsetof(struct cell,
																  ic_solid_solutions),
														 offsetof(struct cell,
																  ic_solid_solutions_defined),
														 PT_MIX, FALSE, 0,
														 BC_info::
														 BC_UNDEFINED) ==
					ERROR)
				{
					sprintf(error_string, "Bad solid_solutions definition %s",
							tag);
					error_msg(error_string, CONTINUE);
					input_error++;
				}
			}
			/*
			 *   Kinetics initial condition
			 */
			if (chem_ic[i]->kinetics != NULL)
			{
				if (distribute_property_to_list_of_cells(list_of_cells,
														 chem_ic[i]->mask,
														 chem_ic[i]->kinetics,
														 offsetof(struct cell,
																  ic_kinetics),
														 offsetof(struct cell,
																  ic_kinetics_defined),
														 PT_MIX, FALSE, 0,
														 BC_info::
														 BC_UNDEFINED) ==
					ERROR)
				{
					sprintf(error_string, "Bad kinetics definition %s", tag);
					error_msg(error_string, CONTINUE);
					input_error++;
				}
			}
		}
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
zone_to_string(struct zone *zone_ptr, char *ptr)
/* ---------------------------------------------------------------------- */
{
	ptr[0] = '\0';
	if (zone_ptr == NULL)
	{
		return (ERROR);
	}
	sprintf(ptr, "Zone: %g\t%g\t%g\t\t%g\t%g\t%g",
			zone_ptr->x1,
			zone_ptr->y1,
			zone_ptr->z1, zone_ptr->x2, zone_ptr->y2, zone_ptr->z2);
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
setup_bc(void)
/* ---------------------------------------------------------------------- */
{
	int i, match_bc;
	struct index_range *range_ptr;

	if (simulation > 0)
	{
		match_bc = TRUE;
		for (i = 0; i < nxyz; i++)
		{
			cells[i].all_bc_info->clear();
		}
	}
	else
	{
		match_bc = FALSE;
	}
	count_specified = count_flux = count_leaky = 0;
	for (i = 0; i < count_bc; i++)
	{
		if (bc[i]->bc_type == BC_info::BC_SPECIFIED)
		{
			count_specified++;
			sprintf(tag, "in SPECIFIED_HEAD_BC, definition %d.\n",
					count_specified);
		}
		else if (bc[i]->bc_type == BC_info::BC_FLUX)
		{
			count_flux++;
			sprintf(tag, "in FLUX_BC, definition %d.\n", count_flux);
		}
		else if (bc[i]->bc_type == BC_info::BC_LEAKY)
		{
			count_leaky++;
			sprintf(tag, "in LEAKY_BC, definition %d.\n", count_leaky);
		}
		else
		{
			error_msg("No bc type in subroutine setup_bc", STOP);
		}


		if (bc[i]->polyh == NULL)
		{
			input_error++;
			sprintf(error_string, "No zone or wedge definition %s", tag);
			error_msg(error_string, CONTINUE);
			break;
		}
		else
		{
			std::list < int >list_of_cells;
			struct zone *zone_ptr = bc[i]->polyh->Get_bounding_box();

			if (bc[i]->bc_type == BC_info::BC_SPECIFIED)
			{
				range_ptr = zone_to_range(zone_ptr);
				if (range_ptr == NULL)
				{
					input_error++;
					sprintf(error_string, "Bad zone or wedge definition %s",
							tag);
					error_msg(error_string, CONTINUE);
					break;
				}
				if (bc[i]->cell_face == CF_UNKNOWN
					|| bc[i]->cell_face == CF_NONE)
				{
					range_to_list(range_ptr, list_of_cells);
					bc[i]->polyh->Points_in_polyhedron(list_of_cells,
													   *cell_xyz);
				}
				else
				{
					cells_with_exterior_faces_in_zone(list_of_cells,
													  zone_ptr);
					any_faces_intersect_polyhedron(i, list_of_cells,
												   bc[i]->cell_face);
				}
				free_check_null(range_ptr);
				//bc[i]->cell_face = CF_NONE;
				//bc[i]->face = 0;
			}
			else
			{
				cells_with_exterior_faces_in_zone(list_of_cells, zone_ptr);
				if (bc[i]->cell_face == CF_UNKNOWN)
				{
					// Guess face
					bc[i]->cell_face = guess_face(list_of_cells, zone_ptr);
					if (bc[i]->cell_face == CF_UNKNOWN)
						continue;
				}
				bc[i]->face = bc[i]->cell_face;
				//cells_with_faces(list_of_cells, bc[i]->cell_face); // moved to faces_intersect_polyhedron
				faces_intersect_polyhedron(i, list_of_cells,
										   bc[i]->cell_face);
			}


			if (list_of_cells.size() == 0)
			{
				input_error++;
				sprintf(error_string, "Bad zone or wedge definition %s", tag);
				error_msg(error_string, CONTINUE);
				break;
			}

			switch (bc[i]->bc_type)
			{
			case BC_info::BC_UNDEFINED:
				input_error++;
				error_msg("Bad bc type in setup_ic.", CONTINUE);
				break;
				/*
				 *   Specified head boundary condition
				 */
			case BC_info::BC_SPECIFIED:

				distribute_specified_bc(i, list_of_cells, tag);
				break;
				/*
				 *   Flux boundary condition
				 */
			case BC_info::BC_FLUX:

				distribute_flux_bc(i, list_of_cells, tag);

				break;
				/*
				 *   Leaky boundary condition
				 */
			case BC_info::BC_LEAKY:

				distribute_leaky_bc(i, list_of_cells, tag);
				break;
			}
		}
	}

	// Should be able to set the active cells now
	set_active_cells();

	// Tidy boundary conditions
	if (simulation == 0)
	{
		for (i = 0; i < nxyz; i++)
		{
			if (cells[i].cell_active == TRUE)
			{
				process_bc(&cells[i]);
			}
		}
	}
	/*
	 *  for specified concentration bc (-fixed_solution), no reactions
	 *  should be allowed
	 */
	for (i = 0; i < nxyz; i++)
	{
		if (cells[i].cell_active == TRUE && cells[i].specified)
		{
			std::list < BC_info >::reverse_iterator rit =
				cells[i].all_bc_info->rbegin();
			assert(rit != cells[i].all_bc_info->rend());
			if (rit->bc_solution_type == FIXED)
			{
				mix_init(&cells[i].ic_equilibrium_phases);
				mix_init(&cells[i].ic_exchange);
				mix_init(&cells[i].ic_surface);
				mix_init(&cells[i].ic_gas_phase);
				mix_init(&cells[i].ic_solid_solutions);
				mix_init(&cells[i].ic_kinetics);
			}
		}
	}

	return (OK);
}

/* ---------------------------------------------------------------------- */
Cell_Face
guess_face(std::list < int >&list_of_numbers, struct zone * zone_ptr)
/* ---------------------------------------------------------------------- */
{
	//try using range pointer
	/*
	 *   Find dimension of zone
	 */
	int idim = 3;
	if (zone_ptr->x1 == zone_ptr->x2)
		idim--;
	if (zone_ptr->y1 == zone_ptr->y2)
		idim--;
	if (zone_ptr->z1 == zone_ptr->z2)
		idim--;
	/*
	 *   Find possible faces from range
	 */
	bool ix_range, iy_range, iz_range;
	ix_range = iy_range = iz_range = false;
	if (zone_ptr->x1 == zone_ptr->x2)
		ix_range = true;
	if (zone_ptr->y1 == zone_ptr->y2)
		iy_range = true;
	if (zone_ptr->z1 == zone_ptr->z2)
		iz_range = true;


	// count each type of face
	int fcount[3];
	int i;
	for (i = 0; i < 3; i++)
		fcount[i] = 0;

	std::list < int >::iterator it = list_of_numbers.begin();
	while (it != list_of_numbers.end())
	{
		int n = *it;
		if (cells[n].exterior != NULL)
		{
			if (cells[n].exterior->xn == true
				|| cells[n].exterior->xp == true)
				fcount[0]++;
			if (cells[n].exterior->yn == true
				|| cells[n].exterior->yp == true)
				fcount[1]++;
			if (cells[n].exterior->zn == true
				|| cells[n].exterior->zp == true)
				fcount[2]++;
		}
		it++;
	}

	// determine maximum face count
	int max = fcount[0];
	int imax = 0;
	for (i = 1; i < 3; i++)
	{
		if (fcount[i] > max)
		{
			max = fcount[i];
			imax = i;
		}
	}
	if (max == 0)
	{
		input_error++;
		sprintf(error_string,
				"No exterior faces in zone for Flux or Leaky bc.");
		error_msg(error_string, CONTINUE);
		return (CF_UNKNOWN);
	}

	// are there more than 1 maximum face count
	int count_max = 0;
	for (i = 0; i < 3; i++)
	{
		if (fcount[i] == max)
			count_max++;
	}

	// Logic
	Cell_Face face = CF_UNKNOWN;
	if (idim == 2)
	{
		if (ix_range)
			face = CF_X;
		if (iy_range)
			face = CF_Y;
		if (iz_range)
			face = CF_Z;
	}
	else if (count_max == 1)
	{
		if (imax == 0)
			face = CF_X;
		if (imax == 1)
			face = CF_Y;
		if (imax == 2)
			face = CF_Z;
	}
	else
	{
		input_error++;
		error_msg
			("Can not determine face, please specify X, y, or Z face for LEAKY_BC and FLUX_BC.",
			 STOP);
	}

	std::string dir;
	switch (face)
	{
	case CF_X:
		dir.append("X");
		break;
	case CF_Y:
		dir.append("Y");
		break;
	case CF_Z:
		dir.append("Z");
		break;
	default:
		return (face);
		break;
	}
	sprintf(error_string,
			"Guessing boundary condition face to be %s\nPlease specify X, Y, or Z face for LEAKY_BC and FLUX_BC.",
			dir.c_str());
	warning_msg(error_string);
	return (face);
}

/* ---------------------------------------------------------------------- */
int
setup_media(void)
/* ---------------------------------------------------------------------- */
{
	int i;
	struct index_range *range_ptr;

	for (i = 0; i < count_grid_elt_zones; i++)
	{
		sprintf(tag, "in MEDIA, definition %d.\n", i + 1);
		/*
		 *   process zone information
		 */
		std::list < int >list_of_elements;
		if (grid_elt_zones[i]->polyh == NULL)
		{
			input_error++;
			sprintf(error_string, "No zone or wedge definition %s", tag);
			error_msg(error_string, CONTINUE);
			break;
		}
		else
		{
			if (!grid_elt_zones[i]->shell)
			{
				struct zone *zone_ptr =	grid_elt_zones[i]->polyh->Get_bounding_box();
				range_ptr = zone_to_elt_range(zone_ptr, true);
				if (range_ptr == NULL)
				{
					input_error++;
					sprintf(error_string, "Bad zone or wedge definition %s", tag);
					error_msg(error_string, CONTINUE);
					break;
				}
				range_to_list(range_ptr, list_of_elements);
				free_check_null(range_ptr);
				range_ptr = NULL;
				grid_elt_zones[i]->polyh->Points_in_polyhedron(list_of_elements, *element_xyz);
			}
			else
			{
				if (!find_shell(grid_elt_zones[i]->polyh, grid_elt_zones[i]->shell_width, list_of_elements))
				{
					input_error++;
					sprintf(error_string, "Bad zone or wedge definition for shell %s", tag);
					error_msg(error_string, CONTINUE);
					break;
				}
			}

			if (list_of_elements.size() == 0)
			{
				input_error++;
				sprintf(error_string, "Bad zone or wedge definition %s", tag);
				error_msg(error_string, CONTINUE);
				break;
			}
			/*
			 *   process active 
			 */
			if (grid_elt_zones[i]->active != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->active,
															offsetof(struct
																	 cell,
																	 elt_active),
															offsetof(struct
																	 cell,
																	 elt_active_defined),
															TRUE) == ERROR)
				{
					input_error++;
					sprintf(error_string, "Bad definition of active cells %s",
							tag);
					error_msg(error_string, CONTINUE);
				}
			}
			/*
			 *   process porosity 
			 */
			if (grid_elt_zones[i]->porosity != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->porosity,
															offsetof(struct
																	 cell,
																	 porosity),
															offsetof(struct
																	 cell,
																	 porosity_defined),
															FALSE) == ERROR)
				{
					input_error++;
					sprintf(error_string, "Bad definition of porosity %s",
							tag);
					error_msg(error_string, CONTINUE);
				}
			}

			/*
			 *   process kx 
			 */
			if (grid_elt_zones[i]->kx != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->kx,
															offsetof(struct
																	 cell,
																	 kx),
															offsetof(struct
																	 cell,
																	 kx_defined),
															FALSE) == ERROR)
				{
					input_error++;
					sprintf(error_string,
							"Bad definition of X hydraulic conductivity %s",
							tag);
					error_msg(error_string, CONTINUE);
				}
			}

			/*
			 *   process ky 
			 */
			if (grid_elt_zones[i]->ky != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->ky,
															offsetof(struct
																	 cell,
																	 ky),
															offsetof(struct
																	 cell,
																	 ky_defined),
															FALSE) == ERROR)
				{
					input_error++;
					sprintf(error_string,
							"Bad definition of Y hydraulic conductivity %s",
							tag);
					error_msg(error_string, CONTINUE);
				}
			}
			/*
			 *   process kz 
			 */
			if (grid_elt_zones[i]->kz != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->kz,
															offsetof(struct
																	 cell,
																	 kz),
															offsetof(struct
																	 cell,
																	 kz_defined),
															FALSE) == ERROR)
				{
					input_error++;
					sprintf(error_string,
							"Bad definition of Z hydraulic conductivity %s",
							tag);
					error_msg(error_string, CONTINUE);
				}
			}
			/*
			 *   process storage 
			 */
			if (grid_elt_zones[i]->storage != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->storage,
															offsetof(struct
																	 cell,
																	 storage),
															offsetof(struct
																	 cell,
																	 storage_defined),
															FALSE) == ERROR)
				{
					input_error++;
					sprintf(error_string,
							"Bad definition of specific storage %s", tag);
					error_msg(error_string, CONTINUE);
				}
			}
			/*
			 *   process alpha_long 
			 */
			if (grid_elt_zones[i]->alpha_long != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->alpha_long,
															offsetof(struct
																	 cell,
																	 alpha_long),
															offsetof(struct
																	 cell,
																	 alpha_long_defined),
															FALSE) == ERROR)
				{
					input_error++;
					sprintf(error_string,
							"Bad definition of longitudinal dispersivity %s",
							tag);
					error_msg(error_string, CONTINUE);
				}
			}
			/*
			 *   process alpha_trans
			 *   Should use alpha_horizontal and alpha vertical instead
			 */
			if (grid_elt_zones[i]->alpha_trans != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->alpha_trans,
															offsetof(struct
																	 cell,
																	 alpha_horizontal),
															offsetof(struct
																	 cell,
																	 alpha_horizontal_defined),
															FALSE) == ERROR)
				{
					input_error++;
					sprintf(error_string,
							"Bad definition of transverse dispersivity %s",
							tag);
					error_msg(error_string, CONTINUE);
				}
			}
			if (grid_elt_zones[i]->alpha_trans != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->alpha_trans,
															offsetof(struct
																	 cell,
																	 alpha_vertical),
															offsetof(struct
																	 cell,
																	 alpha_vertical_defined),
															FALSE) == ERROR)
				{
					input_error++;
					sprintf(error_string,
							"Bad definition of transverse dispersivity %s",
							tag);
					error_msg(error_string, CONTINUE);
				}
			}
			/*
			 *   process alpha_horizontal
			 */
			if (grid_elt_zones[i]->alpha_horizontal != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->
															alpha_horizontal,
															offsetof(struct
																	 cell,
																	 alpha_horizontal),
															offsetof(struct
																	 cell,
																	 alpha_horizontal_defined),
															FALSE) == ERROR)
				{
					input_error++;
					sprintf(error_string,
							"Bad definition of horizontal_dispersivity %s",
							tag);
					error_msg(error_string, CONTINUE);
				}
			}
			/*
			 *   process alpha_vertical
			 */
			if (grid_elt_zones[i]->alpha_vertical != NULL)
			{
				if (distribute_property_to_list_of_elements(list_of_elements,
															grid_elt_zones
															[i]->mask,
															grid_elt_zones
															[i]->
															alpha_vertical,
															offsetof(struct
																	 cell,
																	 alpha_vertical),
															offsetof(struct
																	 cell,
																	 alpha_vertical_defined),
															FALSE) == ERROR)
				{
					input_error++;
					sprintf(error_string,
							"Bad definition of vertical_dispersivity %s",
							tag);
					error_msg(error_string, CONTINUE);
				}
			}
		}
	}
	/*
	 * Determine exterior cells
	 */
	set_exterior_cells();
	return (OK);
}

/* ---------------------------------------------------------------------- */
struct index_range *
vertex_to_range(gpc_vertex * poly, int count_points)
	/* ---------------------------------------------------------------------- */
{
	struct zone zone;
	struct index_range *range_ptr;
	int i1, i2, j1, j2;
	int i;
	/* 
	 *    find min, max, x, y
	 */

	zone.x1 = poly[0].x;
	zone.y1 = poly[0].y;
	zone.z1 = grid[2].coord[grid[2].count_coord - 1];
	zone.x2 = poly[0].x;
	zone.y2 = poly[0].y;
	zone.z2 = grid[2].coord[grid[2].count_coord - 1];

	for (i = 1; i < count_points; i++)
	{
		if (poly[i].x < zone.x1)
		{
			zone.x1 = poly[i].x;
		}
		if (poly[i].x > zone.x2)
		{
			zone.x2 = poly[i].x;
		}
		if (poly[i].y < zone.y1)
		{
			zone.y1 = poly[i].y;
		}
		if (poly[i].y > zone.y2)
		{
			zone.y2 = poly[i].y;
		}
	}
	if (snap_out_to_range(zone.x1, zone.x2,
						  grid[0].coord, grid[0].count_coord, grid[0].uniform,
						  &i1, &i2) == ERROR)
	{
		return (NULL);
	}
	if (snap_out_to_range(zone.y1, zone.y2,
						  grid[1].coord, grid[1].count_coord, grid[1].uniform,
						  &j1, &j2) == ERROR)
	{
		return (NULL);
	}
	range_ptr = (struct index_range *) malloc(sizeof(struct index_range));
	if (range_ptr == NULL)
		malloc_error();
	range_ptr->i1 = i1;
	range_ptr->i2 = i2;
	range_ptr->j1 = j1;
	range_ptr->j2 = j2;
	range_ptr->k1 = grid[2].count_coord - 1;
	range_ptr->k2 = grid[2].count_coord - 1;
	return (range_ptr);
}

/* ---------------------------------------------------------------------- */
void
range_plus_one(struct index_range *range_ptr)
/* ---------------------------------------------------------------------- */
{
	if (range_ptr == NULL)
		return;

	if (range_ptr->i1 > 0)
		range_ptr->i1--;
	if (range_ptr->i2 < grid[0].count_coord - 1)
		range_ptr->i2++;

	if (range_ptr->j1 > 0)
		range_ptr->j1--;
	if (range_ptr->j2 < grid[1].count_coord - 1)
		range_ptr->j2++;

	if (range_ptr->k1 > 0)
		range_ptr->k1--;
	if (range_ptr->k2 < grid[2].count_coord - 1)
		range_ptr->k2++;

	return;
}

/* ---------------------------------------------------------------------- */
int
snap_out_to_range(double x1, double x2, double *coord, int count_coord,
				  int uniform, int *i1, int *i2)
/* ---------------------------------------------------------------------- */
{
	int i;
	if (uniform == UNDEFINED)
	{
		*i1 = 0;
		*i2 = 1;
		return (OK);
	}
	*i1 = 0;
	*i2 = count_coord - 1;
	for (i = 0; i < count_coord; i++)
	{
		if (coord[i] <= x1)
		{
			*i1 = i;
		}
		else
		{
			break;
		}
	}
	for (i = 0; i < count_coord; i++)
	{
		if (coord[i] >= x2)
		{
			*i2 = i;
			break;
		}
	}
	if (*i2 == 0)
	{
		warning_msg("River polygon is outside model domain.");
		return (ERROR);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
which_cell(double x1, double y1, double z1, int *i1, int *j1, int *k1)
/* ---------------------------------------------------------------------- */
{
	/* 
	 *    calculate cell in which point falls
	 */
	*i1 = -1;
	*j1 = -1;
	*k1 = -1;
	if (coord_to_cell(x1, grid[0].coord, grid[0].count_coord, i1) == ERROR)
	{
		return (ERROR);
	}
	if (coord_to_cell(y1, grid[1].coord, grid[1].count_coord, j1) == ERROR)
	{
		return (ERROR);
	}
	if (coord_to_cell(z1, grid[2].coord, grid[2].count_coord, k1) == ERROR)
	{
		return (ERROR);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
coord_to_cell(double x1, double *coord, int count_coord, int *i1)
/* ---------------------------------------------------------------------- */
{
	/*
	 *   coord are grid points
	 */
	int i;
	*i1 = -1;
	if (x1 < coord[0])
	{
		return (ERROR);
	}
	if (x1 > coord[count_coord - 1])
	{
		return (ERROR);
	}
	for (i = 0; i < count_coord - 1; i++)
	{
		if (x1 <= (coord[i] + coord[i + 1]) * 0.5)
		{
			*i1 = i;
			break;
		}
	}
	if (i == count_coord - 1)
	{
		*i1 = count_coord - 1;
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
double_compare(const void *ptr1, const void *ptr2)
/* ---------------------------------------------------------------------- */
{
	double d1, d2;
	d1 = *((const double *) ptr1);
	d2 = *((const double *) ptr2);
	if (d1 > d2)
		return (1);
	if (d1 < d2)
		return (-1);
	return (0);
}

/* ---------------------------------------------------------------------- */
int
int_compare(const void *ptr1, const void *ptr2)
/* ---------------------------------------------------------------------- */
{
	int i1, i2;
	i1 = *((const int *) ptr1);
	i2 = *((const int *) ptr2);
	if (i1 > i2)
		return (1);
	if (i1 < i2)
		return (-1);
	return (0);
}

/* ---------------------------------------------------------------------- */
int
reset_transient_data(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *   Time parameters
	 */
	int i, j;
	int update;
	struct property_time *pt_ptr;
	/*
	 *  Make time structure for current_time_end
	 */
	current_time_end.value = current_end_time;
	current_time_end.value_defined = TRUE;
	current_time_end.input = NULL;
	current_time_end.input_to_user = 1.0;
	/*
	 *   bc conditions defined, skip write on subsequent time periods if FALSE
	 */
	bc_specified_defined = FALSE;
	bc_flux_defined = FALSE;
	bc_leaky_defined = FALSE;
	well_defined = FALSE;
	river_defined = FALSE;
	/*
	 * Set current values
	 */
	for (i = 0; i < count_bc; i++)
	{
		update = FALSE;
		if (get_current_property_position
			(bc[i]->bc_head, current_start_time, &pt_ptr) >= 0)
		{
			bc[i]->current_bc_head = pt_ptr->property;
			bc[i]->current_bc_head->new_def = TRUE;
			update = TRUE;
		}
		if (get_current_property_position
			(bc[i]->bc_flux, current_start_time, &pt_ptr) >= 0)
		{
			bc[i]->current_bc_flux = pt_ptr->property;
			bc[i]->current_bc_flux->new_def = TRUE;
			update = TRUE;
		}
		if (flow_only == FALSE)
		{
			if (get_current_property_position
				(bc[i]->bc_solution, current_start_time, &pt_ptr) >= 0)
			{
				bc[i]->current_bc_solution = pt_ptr->property;
				bc[i]->current_bc_solution->new_def = TRUE;
				update = TRUE;
			}
		}
		/*
		 *  Set boundary condition definition flags
		 */
		if (update == TRUE)
		{
			if (bc[i]->bc_type == BC_info::BC_SPECIFIED)
			{
				bc_specified_defined = TRUE;
			}
			else if (bc[i]->bc_type == BC_info::BC_FLUX)
			{
				bc_flux_defined = update;
			}
			else if (bc[i]->bc_type == BC_info::BC_LEAKY)
			{
				bc_leaky_defined = update;
			}
		}
	}
	update = FALSE;
	for (i = 0; i < count_rivers; i++)
	{
		rivers[i].update = FALSE;
		for (j = 0; j < rivers[i].count_points; j++)
		{
			if (get_current_property_position
				(rivers[i].points[j].solution, current_start_time,
				 &pt_ptr) >= 0)
			{
				rivers[i].points[j].current_solution =
					(int) pt_ptr->property->v[0];
				update = TRUE;
				rivers[i].update = TRUE;
			}
			if (get_current_property_position
				(rivers[i].points[j].head, current_start_time, &pt_ptr) >= 0)
			{
				rivers[i].points[j].current_head = pt_ptr->property->v[0];
				update = TRUE;
				rivers[i].update = TRUE;
			}
		}
	}
	/*
	 *  Set river definition flag
	 */
	river_defined = update;

	update = FALSE;
	for (i = 0; i < count_wells; i++)
	{
		if (get_current_property_position
			(wells[i].solution, current_start_time, &pt_ptr) >= 0)
		{
			wells[i].current_solution = (int) pt_ptr->property->v[0];
			update = TRUE;
		}
		if (get_current_property_position
			(wells[i].q, current_start_time, &pt_ptr) >= 0)
		{
			wells[i].current_q = pt_ptr->property->v[0];
			update = TRUE;
		}
	}
	well_defined = update;
	/*
	 *  Time step
	 */
	if (get_current_property_position(&time_step, current_start_time, &pt_ptr)
		>= 0)
	{
		copy_time(&pt_ptr->time_value, &current_time_step);
	}
	/*
	 *  Update print frequency
	 */
	if (get_current_property_position
		(&print_velocity, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_velocity);
	}
	if (get_current_property_position
		(&print_hdf_velocity, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_hdf_velocity);
	}
	if (get_current_property_position
		(&print_xyz_velocity, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_xyz_velocity);
	}
	if (get_current_property_position
		(&print_head, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_head);
	}
	if (get_current_property_position
		(&print_hdf_head, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_hdf_head);
	}
	if (get_current_property_position
		(&print_xyz_head, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_xyz_head);
	}
	if (get_current_property_position
		(&print_force_chem, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_force_chem);
	}
	if (get_current_property_position
		(&print_hdf_chem, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_hdf_chem);
	}
	if (get_current_property_position
		(&print_xyz_chem, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_xyz_chem);
	}
	if (get_current_property_position
		(&print_comp, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_comp);
	}
	if (get_current_property_position
		(&print_xyz_comp, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_xyz_comp);
	}
	if (get_current_property_position
		(&print_wells, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_wells);
	}
	if (get_current_property_position
		(&print_xyz_wells, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_xyz_wells);
	}
	if (get_current_property_position
		(&print_statistics, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_statistics);
	}
	if (get_current_property_position
		(&print_flow_balance, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_flow_balance);
	}
	if (get_current_property_position
		(&print_bc_flow, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_bc_flow);
	}
	if (get_current_property_position
		(&print_conductances, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_conductances);
	}
	if (get_current_property_position(&print_bc, current_start_time, &pt_ptr)
		>= 0)
	{
		current_print_bc = pt_ptr->int_value;
	}
	if (get_current_property_position
		(&print_end_of_period, current_start_time, &pt_ptr) >= 0)
	{
		current_print_end_of_period = pt_ptr->int_value;
	}
	if (get_current_property_position
		(&print_restart, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_restart);
	}
	if (get_current_property_position
		(&print_zone_budget, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_zone_budget);
	}
	if (get_current_property_position
		(&print_zone_budget_tsv, current_start_time, &pt_ptr) >= 0)
	{
		time_copy(&(pt_ptr->time_value), &current_print_zone_budget_tsv);
	}

	return (OK);
}

/* ---------------------------------------------------------------------- */
void
range_to_list(struct index_range *range_ptr, std::list < int >&vec)
/* ---------------------------------------------------------------------- */
{
	int i, j, k;
	vec.clear();
	for (k = range_ptr->k1; k <= range_ptr->k2; k++)
	{
		for (j = range_ptr->j1; j <= range_ptr->j2; j++)
		{
			for (i = range_ptr->i1; i <= range_ptr->i2; i++)
			{
				vec.push_back(ijk_to_n(i, j, k));
			}
		}
	}
	return;
}

/* ---------------------------------------------------------------------- */
void
set_exterior_cells()
/* ---------------------------------------------------------------------- */
{
	int k, j, i, n, l;
	for (k = 0; k < nz; k++)
	{
		for (j = 0; j < ny; j++)
		{
			for (i = 0; i < nx; i++)
			{
				n = ijk_to_n(i, j, k);
				cells[n].exterior = NULL;
				int e[8];
				for (l = 0; l < 8; l++)
				{
					e[l] = -1;
				}

				// lower 4 elements (natrual order)
				if (i > 0 && j > 0 && k > 0)
					e[0] = ijk_to_n(i - 1, j - 1, k - 1);
				if (i < (nx - 1) && j > 0 && k > 0)
					e[1] = ijk_to_n(i, j - 1, k - 1);
				if (i > 0 && j < (ny - 1) && k > 0)
					e[2] = ijk_to_n(i - 1, j, k - 1);
				if (i < (nx - 1) && j < (ny - 1) && k > 0)
					e[3] = ijk_to_n(i, j, k - 1);

				// upper 4 elements (natrual order)
				if (i > 0 && j > 0 && k < (nz - 1))
					e[4] = ijk_to_n(i - 1, j - 1, k);
				if (i < (nx - 1) && j > 0 && k < (nz - 1))
					e[5] = ijk_to_n(i, j - 1, k);
				if (i > 0 && j < (ny - 1) && k < (nz - 1))
					e[6] = ijk_to_n(i - 1, j, k);
				if (i < (nx - 1) && j < (ny - 1) && k < (nz - 1))
					e[7] = ijk_to_n(i, j, k);

				// Add faces for elements that are inactive
				// Cell is exterior if at least one element is marked -1    
				bool exterior = false;
				for (l = 0; l < 8; l++)
				{
					if (e[l] >= 0 && cells[e[l]].elt_active == FALSE)
						e[l] = -1;
					if (e[l] >= 0)
						exterior = true;
				}
				if (exterior == false)
					continue;

				// now determine areas
				struct zone *zone_ptr = cells[n].zone;
				double x_areas[4], y_areas[4], z_areas[4];
				gpc_polygon *x_gon[4], *y_gon[4], *z_gon[4];

				gpc_polygon *xn_gon = empty_polygon();
				gpc_polygon *xp_gon = empty_polygon();
				gpc_polygon *yn_gon = empty_polygon();
				gpc_polygon *yp_gon = empty_polygon();
				gpc_polygon *zn_gon = empty_polygon();
				gpc_polygon *zp_gon = empty_polygon();

				// X
				x_areas[0] =
					(cells[n].y - zone_ptr->y1) * (cells[n].z - zone_ptr->z1);
				x_gon[0] =
					rectangle(zone_ptr->y1, zone_ptr->z1, cells[n].y,
							  cells[n].z);

				x_areas[1] =
					(cells[n].y - zone_ptr->y1) * (zone_ptr->z2 - cells[n].z);
				x_gon[1] =
					rectangle(zone_ptr->y1, cells[n].z, cells[n].y,
							  zone_ptr->z2);

				x_areas[2] =
					(zone_ptr->y2 - cells[n].y) * (zone_ptr->z2 - cells[n].z);
				x_gon[2] =
					rectangle(cells[n].y, cells[n].z, zone_ptr->y2,
							  zone_ptr->z2);

				x_areas[3] =
					(zone_ptr->y2 - cells[n].y) * (cells[n].z - zone_ptr->z1);
				x_gon[3] =
					rectangle(cells[n].y, zone_ptr->z1, zone_ptr->y2,
							  cells[n].z);

				// y
				y_areas[0] =
					(cells[n].x - zone_ptr->x1) * (cells[n].z - zone_ptr->z1);
				y_gon[0] =
					rectangle(zone_ptr->x1, zone_ptr->z1, cells[n].x,
							  cells[n].z);

				y_areas[1] =
					(zone_ptr->x2 - cells[n].x) * (cells[n].z - zone_ptr->z1);
				y_gon[1] =
					rectangle(cells[n].x, zone_ptr->z1, zone_ptr->x2,
							  cells[n].z);

				y_areas[2] =
					(zone_ptr->x2 - cells[n].x) * (zone_ptr->z2 - cells[n].z);
				y_gon[2] =
					rectangle(cells[n].x, cells[n].z, zone_ptr->x2,
							  zone_ptr->z2);

				y_areas[3] =
					(cells[n].x - zone_ptr->x1) * (zone_ptr->z2 - cells[n].z);
				y_gon[3] =
					rectangle(zone_ptr->x1, cells[n].z, cells[n].x,
							  zone_ptr->z2);

				// z
				z_areas[0] =
					(cells[n].x - zone_ptr->x1) * (cells[n].y - zone_ptr->y1);
				z_gon[0] =
					rectangle(zone_ptr->x1, zone_ptr->y1, cells[n].x,
							  cells[n].y);

				z_areas[1] =
					(zone_ptr->x2 - cells[n].x) * (cells[n].y - zone_ptr->y1);
				z_gon[1] =
					rectangle(cells[n].x, zone_ptr->y1, zone_ptr->x2,
							  cells[n].y);

				z_areas[2] =
					(zone_ptr->x2 - cells[n].x) * (zone_ptr->y2 - cells[n].y);
				z_gon[2] =
					rectangle(cells[n].x, cells[n].y, zone_ptr->x2,
							  zone_ptr->y2);

				z_areas[3] =
					(cells[n].x - zone_ptr->x1) * (zone_ptr->y2 - cells[n].y);
				z_gon[3] =
					rectangle(zone_ptr->x1, cells[n].y, cells[n].x,
							  zone_ptr->y2);

				Exterior_cell *ext = new Exterior_cell();
				double xn_area = 0.0, yn_area = 0.0, zn_area = 0.0;
				double xp_area = 0.0, yp_area = 0.0, zp_area = 0.0;

				// X negative face
				if (e[0] < 0 && e[1] >= 0)
				{
					xn_area += x_areas[0];
					gpc_polygon_clip(GPC_UNION, xn_gon, x_gon[0], xn_gon);
				}
				if (e[2] < 0 && e[3] >= 0)
				{
					xn_area += x_areas[3];
					gpc_polygon_clip(GPC_UNION, xn_gon, x_gon[3], xn_gon);
				}
				if (e[4] < 0 && e[5] >= 0)
				{
					xn_area += x_areas[1];
					gpc_polygon_clip(GPC_UNION, xn_gon, x_gon[1], xn_gon);
				}
				if (e[6] < 0 && e[7] >= 0)
				{
					xn_area += x_areas[2];
					gpc_polygon_clip(GPC_UNION, xn_gon, x_gon[2], xn_gon);
				}
				//gpc_polygon_write(xn_gon);

				// X positive face
				if (e[1] < 0 && e[0] >= 0)
				{
					xp_area += x_areas[0];
					gpc_polygon_clip(GPC_UNION, xp_gon, x_gon[0], xp_gon);
				}
				if (e[3] < 0 && e[2] >= 0)
				{
					xp_area += x_areas[3];
					gpc_polygon_clip(GPC_UNION, xp_gon, x_gon[3], xp_gon);
				}
				if (e[5] < 0 && e[4] >= 0)
				{
					xp_area += x_areas[1];
					gpc_polygon_clip(GPC_UNION, xp_gon, x_gon[1], xp_gon);
				}
				if (e[7] < 0 && e[6] >= 0)
				{
					xp_area += x_areas[2];
					gpc_polygon_clip(GPC_UNION, xp_gon, x_gon[2], xp_gon);
				}

				// Y negative face
				if (e[0] < 0 && e[2] >= 0)
				{
					yn_area += y_areas[0];
					gpc_polygon_clip(GPC_UNION, yn_gon, y_gon[0], yn_gon);
				}
				if (e[1] < 0 && e[3] >= 0)
				{
					yn_area += y_areas[1];
					gpc_polygon_clip(GPC_UNION, yn_gon, y_gon[1], yn_gon);
				}
				if (e[4] < 0 && e[6] >= 0)
				{
					yn_area += y_areas[3];
					gpc_polygon_clip(GPC_UNION, yn_gon, y_gon[3], yn_gon);
				}
				if (e[5] < 0 && e[7] >= 0)
				{
					yn_area += y_areas[2];
					gpc_polygon_clip(GPC_UNION, yn_gon, y_gon[2], yn_gon);
				}

				// Y positive face
				if (e[2] < 0 && e[0] >= 0)
				{
					yp_area += y_areas[0];
					gpc_polygon_clip(GPC_UNION, yp_gon, y_gon[0], yp_gon);
				}
				if (e[3] < 0 && e[1] >= 0)
				{
					yp_area += y_areas[1];
					gpc_polygon_clip(GPC_UNION, yp_gon, y_gon[1], yp_gon);
				}
				if (e[6] < 0 && e[4] >= 0)
				{
					yp_area += y_areas[3];
					gpc_polygon_clip(GPC_UNION, yp_gon, y_gon[3], yp_gon);
				}
				if (e[7] < 0 && e[5] >= 0)
				{
					yp_area += y_areas[2];
					gpc_polygon_clip(GPC_UNION, yp_gon, y_gon[2], yp_gon);
				}

				// Z negative face
				if (e[0] < 0 && e[4] >= 0)
				{
					zn_area += z_areas[0];
					gpc_polygon_clip(GPC_UNION, zn_gon, z_gon[0], zn_gon);
				}
				if (e[1] < 0 && e[5] >= 0)
				{
					zn_area += z_areas[1];
					gpc_polygon_clip(GPC_UNION, zn_gon, z_gon[1], zn_gon);
				}
				if (e[2] < 0 && e[6] >= 0)
				{
					zn_area += z_areas[3];
					gpc_polygon_clip(GPC_UNION, zn_gon, z_gon[3], zn_gon);
				}
				if (e[3] < 0 && e[7] >= 0)
				{
					zn_area += z_areas[2];
					gpc_polygon_clip(GPC_UNION, zn_gon, z_gon[2], zn_gon);
				}

				// Z positive face
				if (e[4] < 0 && e[0] >= 0)
				{
					zp_area += z_areas[0];
					gpc_polygon_clip(GPC_UNION, zp_gon, z_gon[0], zp_gon);
				}
				if (e[5] < 0 && e[1] >= 0)
				{
					zp_area += z_areas[1];
					gpc_polygon_clip(GPC_UNION, zp_gon, z_gon[1], zp_gon);
				}
				if (e[6] < 0 && e[2] >= 0)
				{
					zp_area += z_areas[3];
					gpc_polygon_clip(GPC_UNION, zp_gon, z_gon[3], zp_gon);
				}
				if (e[7] < 0 && e[3] >= 0)
				{
					zp_area += z_areas[2];
					gpc_polygon_clip(GPC_UNION, zp_gon, z_gon[2], zp_gon);
				}

				ext->xn_gon = xn_gon;
				ext->xp_gon = xp_gon;
				ext->yn_gon = yn_gon;
				ext->yp_gon = yp_gon;
				ext->zn_gon = zn_gon;
				ext->zp_gon = zp_gon;

				if (xn_area > 0.0)
				{
					ext->xn = true;
					ext->xn_area = xn_area;
				}
				if (xp_area > 0.0)
				{
					ext->xp = true;
					ext->xp_area = xp_area;
				}
				if (yn_area > 0.0)
				{
					ext->yn = true;
					ext->yn_area = yn_area;
				}
				if (yp_area > 0.0)
				{
					ext->yp = true;
					ext->yp_area = yp_area;
				}
				if (zn_area > 0.0)
				{
					ext->zn = true;
					ext->zn_area = zn_area;
				}
				if (zp_area > 0.0)
				{
					ext->zp = true;
					ext->zp_area = zp_area;
				}
				// save pointer to exterior face information
				cells[n].exterior = ext;
				//fprintf(stderr, "\nCell %d: \n", n);
				//cells[n].exterior->dump();
				for (l = 0; l < 4; l++)
				{
					gpc_free_polygon(x_gon[l]);
					free_check_null(x_gon[l]);
					gpc_free_polygon(y_gon[l]);
					free_check_null(y_gon[l]);
					gpc_free_polygon(z_gon[l]);
					free_check_null(z_gon[l]);
				}
			}
		}
	}
#ifdef DEBUG_AREAS
	double xn = 0, yn = 0, zn = 0, xp = 0, yp = 0, zp = 0;
	for (i = 0; i < nxyz; i++)
	{
		if (cells[i].exterior != NULL)
		{
			xn += cells[i].exterior->xn_area;
			yn += cells[i].exterior->yn_area;
			zn += cells[i].exterior->zn_area;
			xp += cells[i].exterior->xp_area;
			yp += cells[i].exterior->yp_area;
			zp += cells[i].exterior->zp_area;
		}
	}
	fprintf(stderr, "xn_area: %g\n", xn);
	fprintf(stderr, "yn_area: %g\n", yn);
	fprintf(stderr, "zn_area: %g\n", zn);
	fprintf(stderr, "xp_area: %g\n", xp);
	fprintf(stderr, "yp_area: %g\n", yp);
	fprintf(stderr, "zp_area: %g\n", zp);
#endif
	return;
}

void
cells_with_faces(std::list < int >&list_of_numbers, Cell_Face face)
{
	std::list < int >::iterator it = list_of_numbers.begin();
	while (it != list_of_numbers.end())
	{
		int n = *it;
		if (face == CF_UNKNOWN)
		{
			input_error++;
			error_msg("Face not defined", STOP);
		}
		if (cells[n].exterior == NULL ||
			(face == CF_X && cells[n].exterior->xn == false
			 && cells[n].exterior->xp == false) || (face == CF_Y
													&& cells[n].exterior->
													yn == false
													&& cells[n].exterior->
													yp == false)
			|| (face == CF_Z && cells[n].exterior->zn == false
				&& cells[n].exterior->zp == false))
		{
			it = list_of_numbers.erase(it);
		}
		else
		{
			it++;
		}
	}
	return;
}

void
any_faces_intersect_polyhedron(int i, std::list < int >&list_of_numbers,
							   Cell_Face face)
{
	if (face == CF_NONE)
		return;
	std::set < int >accumulator;
	Cell_Face cf_save = bc[i]->cell_face;
	std::list < int >::iterator it = list_of_numbers.begin();
	int f;
	for (f = (int) CF_X; f <= (int) CF_Z; f++)
	{
		std::list < int >temp_list(list_of_numbers);
		Cell_Face cf;
		cf = (Cell_Face) f;
		if (cf_save == CF_ALL)
		{
			bc[i]->cell_face = cf;
		}
		if (cf == face || face == CF_ALL)
		{
			faces_intersect_polyhedron(i, temp_list, cf);
		}
		std::list < int >::iterator it = temp_list.begin();
		for (; it != temp_list.end(); it++)
		{
			accumulator.insert(*it);
		}
	}
	bc[i]->cell_face = cf_save;
	list_of_numbers.clear();
	std::set < int >::iterator jt = accumulator.begin();
	for (; jt != accumulator.end(); jt++)
	{
		list_of_numbers.push_back(*jt);
	}
}
void
faces_intersect_polyhedron(int i, std::list < int >&list_of_numbers,
						   Cell_Face face)
{
	cells_with_faces(list_of_numbers, bc[i]->cell_face);
	std::list < int >::iterator it = list_of_numbers.begin();
	while (it != list_of_numbers.end())
	{
		int n = *it;
		bool keep = false;
		//gpc_polygon *bc_area = bc[i]->polyh->Face_polygon(bc[i]->cell_face);
		double coord;

		switch (bc[i]->cell_face)
		{
		case CF_X:
			coord = cells[n].x;
			break;
		case CF_Y:
			coord = cells[n].y;
			break;
		case CF_Z:
			coord = cells[n].z;
			break;
		default:
			error_msg("Wrong face defined in distribute_flux_bc",
					  EA_CONTINUE);
			return;
		}

		//gpc_polygon *bc_area = bc[i]->polyh->Face_polygon(bc[i]->cell_face);
		gpc_polygon *bc_area = bc[i]->polyh->Slice(bc[i]->cell_face, coord);

		if (bc_area != NULL)
		{
			// get polygon for cell face
			// This is a pointer to the cell face polygon in exterior, do not destroy.
			gpc_polygon *polygon_ptr =
				cells[n].exterior->get_exterior_polygon(bc[i]->cell_face);
			if (polygon_ptr == NULL)
			{
				sprintf(error_string, "Exterior cell face not found %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
				continue;
			}

			// Intersect cell face with boundary condition polygon
			gpc_polygon *cell_face_polygon = empty_polygon();
			gpc_polygon_clip(GPC_INT, bc_area, polygon_ptr,
							 cell_face_polygon);

			Prism *prism = dynamic_cast < Prism * >(bc[i]->polyh);
			if (prism != NULL)
			{
				prism->Remove_top_bottom(cell_face_polygon, bc[i]->cell_face,
										 coord);
			}
			if (cell_face_polygon->num_contours > 0)
			{
				keep = true;
			}

			// Free space
			if (cell_face_polygon != NULL)
			{
				gpc_free_polygon(cell_face_polygon);
				free_check_null(cell_face_polygon);
			}
		}

		// Free space
		if (bc_area != NULL)
		{
			gpc_free_polygon(bc_area);
			free_check_null(bc_area);
		}

		if (!keep)
		{
			it = list_of_numbers.erase(it);
		}
		else
		{
			it++;
		}
	}
	return;
}

/* ---------------------------------------------------------------------- */
bool
get_property_for_cell(int ncells,	// number of point in zone
					  int n,	// cell_number
					  int node_sequence,	// sequence of node in zone
					  struct property * mask,	// mask pointer
					  struct property * property_ptr,	// property pointer
					  property_type p_type,	// property type
					  int *i_ptr,	// return integer
					  double *d_ptr,	// return double
					  struct mix * mix_ptr)	// return mix
/* ---------------------------------------------------------------------- */
{

	double value, mask_value;

	// n = pts.size();
	if (property_ptr->type == PROP_ZONE)
	{
		if (ncells != property_ptr->count_v)
		{
			sprintf(error_string, "Zone has %d nodes,"
					" property has %d values.", n, property_ptr->count_v);
			error_msg(error_string, CONTINUE);
			input_error++;
			return (false);
		}
	}
	if (property_ptr->type == PROP_MIXTURE)
	{
		if (ncells != property_ptr->count_v - 2)
		{
			sprintf(error_string, "Zone has %d nodes,"
					" property has %d values.", n, property_ptr->count_v - 2);
			error_msg(error_string, CONTINUE);
			input_error++;
			return (false);
		}
	}
	if (mask != NULL && mask->type == PROP_ZONE)
	{
		if (ncells != mask->count_v)
		{
			sprintf(error_string, "Zone has %d nodes,"
					" mask has %d values.", n, mask->count_v);
			error_msg(error_string, CONTINUE);
			input_error++;
			return (false);
		}
	}
	//node_sequence = 0;
	//for(std::list<int>::iterator it = pts.begin(); it != pts.end(); it++)
	//{
	//  n = *it;
	mask_value = 1;
	if (mask != NULL)
	{
		if (get_double_property_for_cell
			(&(cells[n]), mask, node_sequence, &mask_value) == ERROR)
		{
			error_msg("Error in mask.", CONTINUE);
			return (false);
		}
	}
	if (mask_value > 0)
	{
		//if (match_bc_type == TRUE && cells[n].bc_face[face].bc_type != bc_type) continue;
		if (p_type == PT_MIX)
		{
			if (get_mix_property_for_cell
				(&(cells[n]), property_ptr, node_sequence, mix_ptr) == ERROR)
			{
				return (false);
			}
		}
		else if (p_type == PT_INTEGER)
		{
			if (get_double_property_for_cell
				(&(cells[n]), property_ptr, node_sequence, &value) == ERROR)
			{
				return (false);
			}
			if (value > 0)
			{
				*i_ptr = TRUE;
			}
			else
			{
				*i_ptr = FALSE;
			}
		}
		else if (p_type == PT_DOUBLE)
		{
			if (get_double_property_for_cell
				(&(cells[n]), property_ptr, node_sequence, &value) == ERROR)
			{
				return (false);
			}
			*d_ptr = value;
		}
		else
		{
			error_msg("Unknown property type in distribute_property_to_cells",
					  STOP);
		}
	}
	return (true);
}


/* ---------------------------------------------------------------------- */
void
distribute_specified_bc(int i,	// bc[i]
						std::list < int >&pts,	// list of cell numbers in natural order
						char *tag)
/* ---------------------------------------------------------------------- */
{
	int ncells = pts.size();
	int node_sequence = -1;

	for (std::list < int >::iterator it = pts.begin(); it != pts.end(); it++)
	{
		int n = *it;
		BC_info bc_info;

		int i_dummy;
		double d_dummy;
		struct mix mix_dummy;

		node_sequence++;

		// bc_head
		if (bc[i]->bc_head != NULL)
		{
			if (get_property_for_cell(ncells, n, node_sequence, bc[i]->mask,
									  bc[i]->current_bc_head,
									  PT_DOUBLE,
									  &i_dummy, &bc_info.bc_head, &mix_dummy))
			{
				bc_info.bc_head_defined = true;
			}
			else
			{
				bc_info.bc_head_defined = false;
				sprintf(error_string, "Head %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			bc[i]->current_bc_head->new_def = FALSE;
		}

		// solution mix
		if (bc[i]->bc_solution != NULL && flow_only == FALSE)
		{
			bc_info.bc_solution_defined = false;
			if (get_property_for_cell(ncells, n, node_sequence, bc[i]->mask,
									  bc[i]->current_bc_solution,
									  PT_MIX,
									  &i_dummy,
									  &d_dummy, &bc_info.bc_solution))
			{
				bc_info.bc_solution_defined = true;
			}
			else
			{
				bc_info.bc_solution_defined = false;
				sprintf(error_string, "Solution %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			bc[i]->current_bc_solution->new_def = FALSE;
		}

		// solution type
		bc_info.bc_solution_type = bc[i]->bc_solution_type;
		bc_info.bc_definition = i;
		bc_info.face = bc[i]->cell_face;
		bc_info.bc_type = BC_info::BC_SPECIFIED;

		// no areas for specifie need areas for simulation == 0

		// Store info
		cells[n].all_bc_info->push_back(bc_info);

	}

	return;
}

/* ---------------------------------------------------------------------- */
void
distribute_flux_bc(int i,		// bc[i]
				   std::list < int >&pts,	// list of cell numbers in natural order
				   char *tag)
/* ---------------------------------------------------------------------- */
{
	int ncells = pts.size();
	int node_sequence = -1;

	for (std::list < int >::iterator it = pts.begin(); it != pts.end(); it++)
	{
		int n = *it;
		BC_info bc_info;

		int i_dummy;
		double d_dummy;
		struct mix mix_dummy;

		node_sequence++;

		// bc_flux
		if (bc[i]->bc_flux != NULL)
		{
			bc_info.bc_flux_defined = false;
			if (get_property_for_cell(ncells, n, node_sequence, bc[i]->mask,
									  bc[i]->current_bc_flux,
									  PT_DOUBLE,
									  &i_dummy, &bc_info.bc_flux, &mix_dummy))
			{
				bc_info.bc_flux_defined = true;
			}
			else
			{
				bc_info.bc_flux_defined = false;
				sprintf(error_string, "Flux %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			bc[i]->current_bc_flux->new_def = FALSE;
		}
		struct zone zo;
		zo.x1 = 0;
		zo.y1 = 0;
		zo.z1 = 0;
		zo.x2 = 1;
		zo.y2 = 1;
		zo.z2 = 1;

		// solution mix
		if (bc[i]->bc_solution != NULL && flow_only == FALSE)
		{
			bc_info.bc_solution_defined = false;
			if (get_property_for_cell(ncells, n, node_sequence, bc[i]->mask,
									  bc[i]->current_bc_solution,
									  PT_MIX,
									  &i_dummy,
									  &d_dummy, &bc_info.bc_solution))
			{
				bc_info.bc_solution_defined = true;
			}
			else
			{
				bc_info.bc_solution_defined = false;
				sprintf(error_string, "Solution %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			bc[i]->current_bc_solution->new_def = FALSE;
		}

		// solution type
		bc_info.bc_solution_type = bc[i]->bc_solution_type;
		bc_info.bc_definition = i;
		bc_info.face = bc[i]->cell_face;
		bc_info.bc_type = BC_info::BC_FLUX;

		// only need areas for simulation == 0
		if (simulation == 0)
		{
			//gpc_polygon *bc_area = bc[i]->polyh->Face_polygon(bc[i]->cell_face);
			double coord;

			switch (bc[i]->cell_face)
			{
			case CF_X:
				coord = cells[n].x;
				break;
			case CF_Y:
				coord = cells[n].y;
				break;
			case CF_Z:
				coord = cells[n].z;
				break;
			default:
				error_msg("Wrong face defined in distribute_flux_bc",
						  EA_CONTINUE);
				break;
			}
			//gpc_polygon *bc_area = bc[i]->polyh->Face_polygon(bc[i]->cell_face);
			gpc_polygon *bc_area =
				bc[i]->polyh->Slice(bc[i]->cell_face, coord);
			if (bc_area != NULL)
			{

				// get polygon for cell face
				// This is a pointer to the cell face polygon in exterior, do not destroy.
				gpc_polygon *polygon_ptr =
					cells[n].exterior->get_exterior_polygon(bc[i]->cell_face);
				if (polygon_ptr == NULL)
				{
					sprintf(error_string, "Exterior cell face not found %s",
							tag);
					error_msg(error_string, CONTINUE);
					input_error++;
					continue;
				}

				// Intersect cell face with boundary condition polygon
				gpc_polygon *cell_face_polygon = empty_polygon();
				gpc_polygon_clip(GPC_INT, bc_area, polygon_ptr,
								 cell_face_polygon);

				Prism *prism = dynamic_cast < Prism * >(bc[i]->polyh);
				if (prism != NULL)
				{
					prism->Remove_top_bottom(cell_face_polygon,
											 bc[i]->cell_face, coord);
				}
				bc_info.poly = cell_face_polygon;
			}

			// Free space
			if (bc_area != NULL)
			{
				gpc_free_polygon(bc_area);
				free_check_null(bc_area);
			}
		}

		// Store info
		cells[n].all_bc_info->push_back(bc_info);

	}

	return;
}


/* ---------------------------------------------------------------------- */
void
distribute_leaky_bc(int i,		// bc[i]
					std::list < int >&pts,	// list of cell numbers in natural order
					char *tag)
/* ---------------------------------------------------------------------- */
{
	int ncells = pts.size();
	int node_sequence = -1;
	//gpc_polygon *bc_area = bc[i]->polyh->Face_polygon(bc[i]->cell_face);

	for (std::list < int >::iterator it = pts.begin(); it != pts.end(); it++)
	{
		int n = *it;
		//BC_info *bc_info = new BC_info; 
		BC_info bc_info;

		int i_dummy;
		double d_dummy;
		struct mix mix_dummy;

		node_sequence++;

		// bc_head
		if (bc[i]->bc_head != NULL)
		{
			if (get_property_for_cell(ncells, n, node_sequence, bc[i]->mask,
									  bc[i]->current_bc_head,
									  PT_DOUBLE,
									  &i_dummy, &bc_info.bc_head, &mix_dummy))
			{
				bc_info.bc_head_defined = true;
			}
			else
			{
				bc_info.bc_head_defined = false;
				sprintf(error_string, "Head %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			bc[i]->current_bc_head->new_def = FALSE;
		}

		// Hydraulic conductivity
		if (bc[i]->bc_k != NULL)
		{
			if (get_property_for_cell(ncells, n, node_sequence, bc[i]->mask,
									  bc[i]->bc_k,
									  PT_DOUBLE,
									  &i_dummy, &bc_info.bc_k, &mix_dummy))
			{
				bc_info.bc_k_defined = true;
			}
			else
			{
				bc_info.bc_k_defined = false;
				sprintf(error_string, "Hydraulic conductivity %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
		}

		// Thickness
		if (bc[i]->bc_thick != NULL)
		{
			if (get_property_for_cell(ncells, n, node_sequence, bc[i]->mask,
									  bc[i]->bc_thick,
									  PT_DOUBLE,
									  &i_dummy,
									  &bc_info.bc_thick, &mix_dummy))
			{
				bc_info.bc_thick_defined = true;
			}
			else
			{
				bc_info.bc_thick_defined = false;
				sprintf(error_string, "Thick %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
		}

		// Solution mix
		if (bc[i]->bc_solution != NULL && flow_only == FALSE)
		{
			if (get_property_for_cell(ncells, n, node_sequence, bc[i]->mask,
									  bc[i]->current_bc_solution,
									  PT_MIX,
									  &i_dummy,
									  &d_dummy, &bc_info.bc_solution))
			{
				bc_info.bc_solution_defined = true;
			}
			else
			{
				bc_info.bc_solution_defined = false;
				sprintf(error_string, "Solution %s", tag);
				error_msg(error_string, CONTINUE);
				input_error++;
			}
			bc[i]->current_bc_solution->new_def = FALSE;
		}

		// solution type
		bc_info.bc_solution_type = bc[i]->bc_solution_type;
		bc_info.bc_definition = i;
		bc_info.face = bc[i]->cell_face;
		bc_info.bc_type = BC_info::BC_LEAKY;

		// only need areas for simulation == 0
		if (simulation == 0)
		{
			double coord;

			switch (bc[i]->cell_face)
			{
			case CF_X:
				coord = cells[n].x;
				break;
			case CF_Y:
				coord = cells[n].y;
				break;
			case CF_Z:
				coord = cells[n].z;
				break;
			default:
				error_msg("Wrong face defined in distribute_flux_bc",
						  EA_CONTINUE);
				break;
			}
			//gpc_polygon *bc_area = bc[i]->polyh->Face_polygon(bc[i]->cell_face);
			gpc_polygon *bc_area =
				bc[i]->polyh->Slice(bc[i]->cell_face, coord);
			if (bc_area != NULL)
			{
				// get polygon for cell face
				// This is a pointer to the cell face polygon in exterior, do not destroy.
				gpc_polygon *polygon_ptr =
					cells[n].exterior->get_exterior_polygon(bc[i]->cell_face);
				if (polygon_ptr == NULL)
				{
					sprintf(error_string, "Exterior cell face not found %s",
							tag);
					error_msg(error_string, CONTINUE);
					input_error++;
					continue;
				}

				// Intersect cell face with boundary condition polygon
				gpc_polygon *cell_face_polygon = empty_polygon();
				gpc_polygon_clip(GPC_INT, bc_area, polygon_ptr,
								 cell_face_polygon);
				Prism *prism = dynamic_cast < Prism * >(bc[i]->polyh);
				if (prism != NULL)
				{
					prism->Remove_top_bottom(cell_face_polygon,
											 bc[i]->cell_face, coord);
				}
				bc_info.poly = cell_face_polygon;

			}

			// Free space
			if (bc_area != NULL)
			{
				gpc_free_polygon(bc_area);
				free_check_null(bc_area);
			}
		}

		// Store info
		cells[n].all_bc_info->push_back(bc_info);

	}

	return;
}

/* ---------------------------------------------------------------------- */
void
process_bc(struct cell *cell_ptr)
/* ---------------------------------------------------------------------- */
{
	if (cell_ptr->all_bc_info->size() == 0)
		return;

	// Reverse terator on list of BC_info
	std::list < BC_info >::reverse_iterator rit =
		cell_ptr->all_bc_info->rbegin();

	cell_ptr->specified = false;
	cell_ptr->leaky = false;
	cell_ptr->flux = false;
	// type is last defined
	cell_ptr->bc_type = rit->bc_type;
	if (cell_ptr->bc_type == BC_info::BC_SPECIFIED)
	{
		cell_ptr->specified = true;
		return;
	}
	bool check = false;
	for (int type = 0; type < 2; type++)
	{
		BC_info::BC_TYPE bctype;
		if (type == 0)
			bctype = BC_info::BC_FLUX;
		if (type == 1)
			bctype = BC_info::BC_LEAKY;
		for (int face = 0; face < 3; face++)
		{
			Cell_Face cf = (Cell_Face) face;
			// Intersect areas for all other boundary types
			gpc_polygon *excluded_area = empty_polygon();
			for (rit = cell_ptr->all_bc_info->rbegin();
				 rit != cell_ptr->all_bc_info->rend(); rit++)
			{
				if (rit->bc_type == bctype && rit->face == cf)
				{
					if (type == 0)
					{
						cell_ptr->flux = true;
					}
					if (type == 1)
					{
						cell_ptr->leaky = true;
					}
					if (rit->poly != NULL)
					{
						// remove excluded area from polygon
						gpc_polygon_clip(GPC_DIFF, rit->poly, excluded_area,
										 rit->poly);

						// add area to excluded area
						gpc_polygon_clip(GPC_UNION, rit->poly, excluded_area,
										 excluded_area);

						// calculate area
						rit->area = gpc_polygon_area(rit->poly);
					}
					check = true;
				}
			}
			gpc_free_polygon(excluded_area);
			free_check_null(excluded_area);
		}
	}
	assert(check);
	return;
}

/* ---------------------------------------------------------------------- */
void
cells_with_exterior_faces_in_zone(std::list < int >&pts,
								  struct zone *zone_ptr)
/* ---------------------------------------------------------------------- */
{
	int i;
	for (i = 0; i < nxyz; i++)
	{
		if (cells[i].exterior == NULL)
			continue;


		struct zone *cell_zone_ptr = cells[i].zone;

		// cell does not intersect zone
		if ((cell_zone_ptr->x1 > zone_ptr->x2
			 || cell_zone_ptr->x2 < zone_ptr->x1)
			|| (cell_zone_ptr->y1 > zone_ptr->y2
				|| cell_zone_ptr->y2 < zone_ptr->y1)
			|| (cell_zone_ptr->z1 > zone_ptr->z2
				|| cell_zone_ptr->z2 < zone_ptr->z1))
			continue;

		bool face_in_zone = false;
		// Check each possible face

		// X
		if ((cells[i].exterior->xn || cells[i].exterior->xp)
			&& (cells[i].x >= zone_ptr->x1 && cells[i].x <= zone_ptr->x2))
		{
			// Must be non trivial intersection
			if ((cell_zone_ptr->y1 < zone_ptr->y2) &&
				(cell_zone_ptr->y2 > zone_ptr->y1) &&
				(cell_zone_ptr->z1 < zone_ptr->z2) &&
				(cell_zone_ptr->z2 > zone_ptr->z1))
			{
				face_in_zone = true;
			}
		}
		// Y
		if ((cells[i].exterior->yn || cells[i].exterior->yp)
			&& (cells[i].y >= zone_ptr->y1 && cells[i].y <= zone_ptr->y2))
		{
			// Must be non trivial intersection
			if ((cell_zone_ptr->x1 < zone_ptr->x2) &&
				(cell_zone_ptr->x2 > zone_ptr->x1) &&
				(cell_zone_ptr->z1 < zone_ptr->z2) &&
				(cell_zone_ptr->z2 > zone_ptr->z1))
			{
				face_in_zone = true;
			}
		}
		// Z
		if ((cells[i].exterior->zn || cells[i].exterior->zp)
			&& (cells[i].z >= zone_ptr->z1 && cells[i].z <= zone_ptr->z2))
		{
			// Must be non trivial intersection
			if ((cell_zone_ptr->x1 < zone_ptr->x2) &&
				(cell_zone_ptr->x2 > zone_ptr->x1) &&
				(cell_zone_ptr->y1 < zone_ptr->y2) &&
				(cell_zone_ptr->y2 > zone_ptr->y1))
			{
				face_in_zone = true;
			}
		}

		if (face_in_zone)
			pts.push_back(i);
	}
}

/* ---------------------------------------------------------------------- */
void
Tidy_cubes(PHAST_Transform::COORDINATE_SYSTEM target,
		   PHAST_Transform * map2grid)
/* ---------------------------------------------------------------------- */
{
	if (target == PHAST_Transform::NONE)
		return;
	int i;
	// Grid_elt
	for (i = 0; i < count_grid_elt_zones; i++)
	{
		Wedge *w = dynamic_cast < Wedge * >(grid_elt_zones[i]->polyh);
		Cube *c = dynamic_cast < Cube * >(grid_elt_zones[i]->polyh);
		if (w == NULL && c == NULL)
			continue;
		if (c->Get_coordinate_system() == target)
			continue;
		assert(c->Get_coordinate_system() != PHAST_Transform::NONE);
		Prism *p;
		if (w != NULL)
		{
			p = new Prism(*w);
		}
		else
		{
			p = new Prism(*c);
		}
		p->Convert_coordinates(target, map2grid);
		delete grid_elt_zones[i]->polyh;
		grid_elt_zones[i]->polyh = p;
	}

	//head_ic_ptr
	for (i = 0; i < count_head_ic; i++)
	{
		Wedge *w = dynamic_cast < Wedge * >(head_ic[i]->polyh);
		Cube *c = dynamic_cast < Cube * >(head_ic[i]->polyh);
		if (w == NULL && c == NULL)
			continue;
		if (c->Get_coordinate_system() == target)
			continue;
		assert(c->Get_coordinate_system() != PHAST_Transform::NONE);
		Prism *p;
		if (w != NULL)
		{
			p = new Prism(*w);
		}
		else
		{
			p = new Prism(*c);
		}
		p->Convert_coordinates(target, map2grid);
		delete head_ic[i]->polyh;
		head_ic[i]->polyh = p;
	}
	//chem_ic_ptr
	for (i = 0; i < count_chem_ic; i++)
	{
		Wedge *w = dynamic_cast < Wedge * >(chem_ic[i]->polyh);
		Cube *c = dynamic_cast < Cube * >(chem_ic[i]->polyh);
		if (w == NULL && c == NULL)
			continue;
		if (c->Get_coordinate_system() == target)
			continue;
		assert(c->Get_coordinate_system() != PHAST_Transform::NONE);
		Prism *p;
		if (w != NULL)
		{
			p = new Prism(*w);
		}
		else
		{
			p = new Prism(*c);
		}
		p->Convert_coordinates(target, map2grid);
		delete chem_ic[i]->polyh;
		chem_ic[i]->polyh = p;
	}
	//bc_ptr
	for (i = 0; i < count_bc; i++)
	{
		Wedge *w = dynamic_cast < Wedge * >(bc[i]->polyh);
		Cube *c = dynamic_cast < Cube * >(bc[i]->polyh);
		if (w == NULL && c == NULL)
			continue;
		if (c->Get_coordinate_system() == target)
			continue;
		assert(c->Get_coordinate_system() != PHAST_Transform::NONE);
		Prism *p;
		if (w != NULL)
		{
			p = new Prism(*w);
		}
		else
		{
			p = new Prism(*c);
		}
		p->Convert_coordinates(target, map2grid);
		delete bc[i]->polyh;
		bc[i]->polyh = p;
	}
	//print_zones_chem
	for (i = 0; i < print_zones_chem.count_print_zones; i++)
	{
		Wedge *w =
			dynamic_cast < Wedge * >(print_zones_chem.print_zones[i].polyh);
		Cube *c =
			dynamic_cast < Cube * >(print_zones_chem.print_zones[i].polyh);
		if (w == NULL && c == NULL)
			continue;
		if (c->Get_coordinate_system() == target)
			continue;
		assert(c->Get_coordinate_system() != PHAST_Transform::NONE);
		Prism *p;
		if (w != NULL)
		{
			p = new Prism(*w);
		}
		else
		{
			p = new Prism(*c);
		}
		p->Convert_coordinates(target, map2grid);
		delete print_zones_chem.print_zones[i].polyh;
		print_zones_chem.print_zones[i].polyh = p;
	}
	//print_zones_xyz
	for (i = 0; i < print_zones_chem.count_print_zones; i++)
	{
		Wedge *w =
			dynamic_cast < Wedge * >(print_zones_xyz.print_zones[i].polyh);
		Cube *c =
			dynamic_cast < Cube * >(print_zones_xyz.print_zones[i].polyh);
		if (w == NULL && c == NULL)
			continue;
		if (c->Get_coordinate_system() == target)
			continue;
		assert(c->Get_coordinate_system() != PHAST_Transform::NONE);
		Prism *p;
		if (w != NULL)
		{
			p = new Prism(*w);
		}
		else
		{
			p = new Prism(*c);
		}
		p->Convert_coordinates(target, map2grid);
		delete print_zones_xyz.print_zones[i].polyh;
		print_zones_xyz.print_zones[i].polyh = p;
	}

	// zone_budget
	std::map < int, Zone_budget * >::iterator it;
	for (it = Zone_budget::zone_budget_map.begin();
		 it != Zone_budget::zone_budget_map.end(); it++)
	{
		Wedge *w = dynamic_cast < Wedge * >(it->second->Get_polyh());
		Cube *c = dynamic_cast < Cube * >(it->second->Get_polyh());
		if (w == NULL && c == NULL)
			continue;
		if (c->Get_coordinate_system() == target)
			continue;
		assert(c->Get_coordinate_system() != PHAST_Transform::NONE);
		Prism *p;
		if (w != NULL)
		{
			p = new Prism(*w);
		}
		else
		{
			p = new Prism(*c);
		}
		p->Convert_coordinates(target, map2grid);
		delete it->second->Get_polyh();
		it->second->Set_polyh(p);
	}
}

/* ---------------------------------------------------------------------- */
void
Tidy_properties(PHAST_Transform::COORDINATE_SYSTEM target,
				PHAST_Transform * map2grid)
/* ---------------------------------------------------------------------- */
{
	std::list < property * >::iterator it =
		properties_with_data_source.begin();
	// Grid_elt
	for (; it != properties_with_data_source.end(); it++)
	{
		(*it)->data_source->Convert_coordinates(target, map2grid);
	}
	return;
}
/* ---------------------------------------------------------------------- */
bool
find_shell(Polyhedron *polyh, double *width, std::list<int> &list_of_elements)
/* ---------------------------------------------------------------------- */
{
	struct index_range *range_ptr;

	struct zone *zone_ptr =	polyh->Get_bounding_box();
	range_ptr = zone_to_range(zone_ptr); // list of cells not elements in polyh
	if (range_ptr == NULL)
	{
		return false;
	}

	/* put cells in list */
	std::list < int > list_of_cells;
	range_to_list(range_ptr, list_of_cells);

	// Find cells in polyhedron
	polyh->Points_in_polyhedron(list_of_cells, *cell_xyz);
	if (list_of_cells.size() == 0)
	{
		return false;
	}

	// Make set of cells 
	std::set < int > set_of_cells;
	std::list < int >::iterator lit = list_of_cells.begin();
	for ( ; lit != list_of_cells.end(); lit++)
	{
		set_of_cells.insert(*lit);
	}

	// select cells with adjacent active cells outside of zone
	std::set<int> set_of_exterior_cells;
	std::set < int >::iterator sit = set_of_cells.begin();

	for ( ; sit != set_of_cells.end(); sit++)
	{
		int n = *sit;
		std::vector < int >stencil;
		neighbors(n, stencil);
		int ii;
		for (ii = 0; ii < 6; ii++)
		{
			if (stencil[ii] >= 0)
			{
				// adjacent cell is not in set 
				if (set_of_cells.find(stencil[ii]) == set_of_cells.end() /*&& cells[stencil[ii]].cell_active*/)
				{
					break;
				}
			}
		}

		// remove if all neighbors are inactive or within zone
		if (ii < 6)
		{
			set_of_exterior_cells.insert(*sit);
		}
	}

	// select all elements that adjoin selected cells
	std::set<int> set_of_elements;
	for (sit = set_of_exterior_cells.begin(); sit != set_of_exterior_cells.end(); sit++)
	{
		std::vector<int> stencil;
		elt_neighbors(*sit, stencil);
		int ii;

		// include elements for cell
		for(ii = 0; ii < 8; ii++)
		{
			if (stencil[ii] >= 0)
			{
				set_of_elements.insert(stencil[ii]);
			}
		}
#ifdef SKIP
		// include other elements within witdth of shell in each direction
		if (width[0] > 0 || width[1] > 0 || width[2] > 0)
		{
			for(ii = 0; ii < 8; ii++)
			{
				if (stencil[ii] > 0)
				{
					double x1, y1, z1, x2, y2, z2;
					x1 = cells[stencil[ii]].elt_x - width[0]/2.0;
					y1 = cells[stencil[ii]].elt_y - width[1]/2.0;
					z1 = cells[stencil[ii]].elt_z - width[2]/2.0;
					x2 = cells[stencil[ii]].elt_x + width[0]/2.0;
					y2 = cells[stencil[ii]].elt_y + width[1]/2.0;
					z2 = cells[stencil[ii]].elt_z + width[2]/2.0;
					Point min(x1, y1, z1);
					Point max(x2, y2, z2);
					zone z(min, max);
					struct index_range *r_ptr;
					r_ptr = zone_to_elt_range(&z);
					std::list<int> more_elements;
					range_to_list(r_ptr, more_elements);
					if (more_elements.size() > 0)
					{
						std::list<int>::iterator lit1 = more_elements.begin();
						for (; lit1 != more_elements.end(); lit1++)
						{
							//if (cells[*lit].is_element /*&& cells[*lit].elt_active*/)
							{
								set_of_elements.insert(*lit1);
							}
						}
					}
					free_check_null(r_ptr);
					r_ptr = NULL;
				}
			}
		}
#endif
		// include other elements within witdth of shell in each direction
		if (width[0] > 0 || width[1] > 0 || width[2] > 0)
		{

			double x1, y1, z1, x2, y2, z2;
			x1 = cells[*sit].x - width[0]/2.0;
			y1 = cells[*sit].y - width[1]/2.0;
			z1 = cells[*sit].z - width[2]/2.0;
			x2 = cells[*sit].x + width[0]/2.0;
			y2 = cells[*sit].y + width[1]/2.0;
			z2 = cells[*sit].z + width[2]/2.0;
			Point min(x1, y1, z1);
			Point max(x2, y2, z2);
			zone z(min, max);
			struct index_range *r_ptr;
			r_ptr = zone_to_elt_range(&z, true);
			if (r_ptr != NULL)
			{
				std::list<int> more_elements;
				range_to_list(r_ptr, more_elements);
				if (more_elements.size() > 0)
				{
					std::list<int>::iterator lit1 = more_elements.begin();
					for (; lit1 != more_elements.end(); lit1++)
					{
						//if (cells[*lit].is_element /*&& cells[*lit].elt_active*/)
						{
							set_of_elements.insert(*lit1);
						}
					}
				}
			}
			free_check_null(r_ptr);
			r_ptr = NULL;
		}
	}
	// copy  set_of_elements to list_of_elements  
	for (sit = set_of_elements.begin(); sit != set_of_elements.end(); sit++)
	{
		list_of_elements.push_back(*sit);
	}
	return true;
}
