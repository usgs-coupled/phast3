#define EXTERNAL extern
#include "hstinpt.h"
#include "message.h"
static char const svnid[] =
	"$Id$";
//static void river_convert_coordinate_system(River * river_ptr,
//											PHAST_Transform::
//											COORDINATE_SYSTEM target,
//											PHAST_Transform * map2grid);
//static void rivers_convert_coordinate_system(PHAST_Transform::
//											 COORDINATE_SYSTEM target,
//											 PHAST_Transform * map2grid);
void river_convert_width_to_grid(River * river_ptr);
void river_convert_xy_to_grid(River * river_ptr, PHAST_Transform * map2grid);
void river_convert_z_to_grid(River * river_ptr, PHAST_Transform * map2grid);
/* ---------------------------------------------------------------------- */
int
setup_rivers(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Check river data 
 */
	int i, j, k, l, m, n, count_points;
	River *river_ptr;
	gpc_vertex *p;
	gpc_polygon poly2;
	gpc_polygon *poly_ptr;
	gpc_polygon intersection;
	struct index_range *range_ptr;
	int count_river_polygons;

	gpc_polygon_init(&poly2);
	gpc_polygon_init(&intersection);
	if (count_rivers <= 0)
		return (OK);
	/*
	 *   gpc_vertex list for cell boundary
	 */
	p = (gpc_vertex *) malloc((size_t) 4 * sizeof(gpc_vertex));
	if (p == NULL)
		malloc_error();
	/*
	 *   gpc_polygon for cell boundary
	 */
	poly2.contour =
		(gpc_vertex_list *) malloc((size_t) sizeof(gpc_vertex_list));
	if (poly2.contour == NULL)
		malloc_error();
	poly2.contour[0].vertex = p;
	poly2.contour[0].num_vertices = 4;
	poly2.num_contours = 1;
	poly2.hole = (int *) malloc(sizeof(int));
	poly2.hole[0] = 0;			// hole is false
	/*
	 *   Go through each river polygon
	 *   Intersect with cells
	 *   Save intersection in Cell structure
	 */
	for (l = 0; l < count_rivers; l++)
	{
		if (rivers[l].new_def != FALSE)
			continue;
		river_ptr = &(rivers[l]);
		count_points = river_ptr->count_points;
		/*
		 *  Go through river polygons
		 */
		for (m = 0; m < count_points - 1; m++)
		{
			poly_ptr = river_ptr->points[m].polygon;
			range_ptr =
				vertex_to_range(poly_ptr->contour[0].vertex,
								poly_ptr->contour[0].num_vertices);
			/*
			 *   Set gpc_polygon for cell boundary
			 */
			if (range_ptr == NULL)
				continue;
			k = range_ptr->k1;
			for (i = range_ptr->i1; i <= range_ptr->i2; i++)
			{
				for (j = range_ptr->j1; j <= range_ptr->j2; j++)
				{
					n = ijk_to_n(i, j, k);
					p[0].x = cells[n].zone->x1;
					p[0].y = cells[n].zone->y1;
					p[1].x = cells[n].zone->x2;
					p[1].y = cells[n].zone->y1;
					p[2].x = cells[n].zone->x2;
					p[2].y = cells[n].zone->y2;
					p[3].x = cells[n].zone->x1;
					p[3].y = cells[n].zone->y2;
					gpc_polygon_clip(GPC_INT, poly_ptr, &poly2,
									 &intersection);
					/*
					 *   check if intersection empty
					 */
					if (intersection.num_contours == 0)
					{
						gpc_free_polygon(&intersection);
						continue;
					}
					/*
					 *   Allocate space
					 */
					count_river_polygons = cells[n].count_river_polygons++;
					cells[n].river_polygons =
						(River_Polygon *) realloc(cells[n].river_polygons,
												  (size_t)
												  (count_river_polygons +
												   1) *
												  sizeof(River_Polygon));
					if (cells[n].river_polygons == NULL)
						malloc_error();
					/*
					 *   Save River_Polygon for cell
					 */
					cells[n].river_polygons[count_river_polygons].poly =
						gpc_polygon_duplicate(&intersection);
					if (cells[n].river_polygons[count_river_polygons].poly->
						contour[0].num_vertices > 10)
					{
						output_msg(OUTPUT_STDERR, "Huhnn?\n");
					}
					cells[n].river_polygons[count_river_polygons].
						river_number = l;
					cells[n].river_polygons[count_river_polygons].
						point_number = m;
					gpc_free_polygon(&intersection);
				}
			}
			free_check_null(range_ptr);
		}
	}
	/*
	 *    Remove duplicate areas from cell river polygons
	 */
	for (i = 0; i < count_cells; i++)
	{
		if (cells[i].count_river_polygons <= 1)
			continue;
		for (j = 0; j < cells[i].count_river_polygons - 1; j++)
		{
			for (k = j + 1; k < cells[i].count_river_polygons; k++)
			{
				gpc_polygon_clip(GPC_INT, cells[i].river_polygons[k].poly,
								 cells[i].river_polygons[j].poly,
								 &intersection);
				if (intersection.num_contours == 0)
				{
					gpc_free_polygon(&intersection);
					continue;
				}
				gpc_free_polygon(&intersection);
				gpc_polygon_clip(GPC_DIFF, cells[i].river_polygons[k].poly,
								 cells[i].river_polygons[j].poly,
								 &intersection);
				gpc_free_polygon(cells[i].river_polygons[k].poly);
				free_check_null(cells[i].river_polygons[k].poly);
				cells[i].river_polygons[k].poly =
					gpc_polygon_duplicate(&intersection);
				gpc_free_polygon(&intersection);
			}
		}
	}
	/*
	 *    Remove empty polygons
	 */
	for (i = 0; i < count_cells; i++)
	{
		if (cells[i].count_river_polygons < 1)
			continue;
		k = 0;
		for (j = 0; j < cells[i].count_river_polygons; j++)
		{
			if (cells[i].river_polygons[j].poly->num_contours == 0 ||
				gpc_polygon_area(cells[i].river_polygons[j].poly) <= 0)
			{
				gpc_free_polygon(cells[i].river_polygons[j].poly);
			}
			else
			{
				if (j != k)
				{
					cells[i].river_polygons[k].poly =
						gpc_polygon_duplicate(cells[i].river_polygons[j].
											  poly);
				}
				k++;
			}
		}
		cells[i].count_river_polygons = k;
	}
	/*
	 *   Find interpolation point and weighing factor
	 */
	for (i = 0; i < count_cells; i++)
	{
		for (j = 0; j < cells[i].count_river_polygons; j++)
		{
			/*
			 *   Interpolate value for river_polygon
			 */
			cells[i].river_polygons[j].area =
				gpc_polygon_area(cells[i].river_polygons[j].poly);
#ifdef DEBUG_RIVERS
			output_msg(OUTPUT_STDERR, "#cell: %d\tarea: %e\n", i,
					   cells[i].river_polygons[j].area);
#endif
			interpolate(&cells[i].river_polygons[j]);
#ifdef DEBUG_RIVERS
			output_msg(OUTPUT_STDERR, "\t%g\t%g\n",
					   cells[i].river_polygons[j].x,
					   cells[i].river_polygons[j].y);
			gpc_polygon_write(cells[i].river_polygons[j].poly);
#endif
		}
	}
	/*  frees contours and vertices p */
	gpc_free_polygon(&poly2);
	return (OK);
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
int
tidy_rivers(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Check river data 
 */
	int i, j, k, return_value;
	double length, total_length, head1, head2;
	River *river_ptr;
	double x1, x2;
	int i1, i2;
	return_value = OK;
	if (count_rivers <= 0)
		return (OK);
	if (simulation > 0)
		return (OK);

	// Convert coordinate system if necessary
	rivers_convert_coordinate_system(target_coordinate_system, map_to_grid);

	for (j = 0; j < count_rivers; j++)
	{
		assert(rivers[j].new_def == TRUE);
		if (rivers[j].new_def == FALSE)
			continue;
		rivers[j].update = TRUE;
		river_ptr = &(rivers[j]);
		/*
		 *  Logical checks on river
		 */
		if (river_ptr->count_points < 2)
		{
			sprintf(error_string,
					"River must have at least 2 points. River %d %s.",
					river_ptr->n_user, river_ptr->description);
			error_msg(error_string, CONTINUE);
			return_value = FALSE;
			input_error++;
		}
		/*
		 *   Check river data
		 */
		for (i = 0; i < river_ptr->count_points; i++)
		{
			river_ptr->points[i].update = TRUE;
			rivers_update = TRUE;
			if (river_ptr->points[i].x_defined == FALSE
				|| river_ptr->points[i].y_defined == FALSE)
			{
				sprintf(error_string,
						"X or Y not defined for river point %d of river %d.",
						i + 1, j);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			}
		}
		/*
		 *   Check head data
		 */
		if (river_ptr->points[0].head_defined == FALSE
			|| river_ptr->points[river_ptr->count_points - 1].head_defined ==
			FALSE)
		{
			sprintf(error_string,
					"Head must be defined at first and last river point (1 and %d) of river %d.",
					river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		else
		{
			/*
			 *   Interpolate head data
			 */
			i = 0;
			length = 0;
			head1 = 0;
			while (i < river_ptr->count_points)
			{
				if (river_ptr->points[i].head_defined == TRUE)
				{
					length = 0;
					head1 = river_ptr->points[i].current_head;
				}
				else
				{
					k = i;
					while (river_ptr->points[k].head_defined == FALSE)
					{
						length +=
							river_distance(&(river_ptr->points[k]),
										   &(river_ptr->points[k - 1]));
						k++;
					}
					length +=
						river_distance(&(river_ptr->points[k]),
									   &(river_ptr->points[k - 1]));
					total_length = length;
					head2 = river_ptr->points[k].current_head;
					if (total_length == 0)
						total_length = 1.0;
					length = 0;
					for (; i < k; i++)
					{
						length +=
							river_distance(&(river_ptr->points[i]),
										   &(river_ptr->points[i - 1]));
						river_ptr->points[i].current_head =
							head1 + length / total_length * (head2 - head1);
					}
				}
				i++;
			}
		}
		/*
		 *   Check width data
		 */
		if (river_ptr->points[0].width_defined == FALSE
			|| river_ptr->points[river_ptr->count_points - 1].width_defined ==
			FALSE)
		{
			sprintf(error_string,
					"Width must be defined at first and last river point (1 and %d) of river %d.",
					river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		else
		{
			/*
			 *   Interpolate width data
			 */
			i = 0;
			length = 0;
			x1 = 0;
			while (i < river_ptr->count_points)
			{
				if (river_ptr->points[i].width_defined == TRUE)
				{
					length = 0;
					x1 = river_ptr->points[i].width;
				}
				else
				{
					k = i;
					while (river_ptr->points[k].width_defined == FALSE)
					{
						length +=
							river_distance(&(river_ptr->points[k]),
										   &(river_ptr->points[k - 1]));
						k++;
					}
					length +=
						river_distance(&(river_ptr->points[k]),
									   &(river_ptr->points[k - 1]));
					total_length = length;
					x2 = river_ptr->points[k].width;
					if (total_length == 0)
						total_length = 1.0;
					length = 0;
					for (; i < k; i++)
					{
						length +=
							river_distance(&(river_ptr->points[i]),
										   &(river_ptr->points[i - 1]));
						river_ptr->points[i].width =
							x1 + length / total_length * (x2 - x1);
					}
				}
				i++;
			}
		}
		/*
		 *   Check k data
		 */
		if (river_ptr->points[0].k_defined == FALSE
			|| river_ptr->points[river_ptr->count_points - 1].k_defined ==
			FALSE)
		{
			sprintf(error_string,
					"Hydraulic conductivity must be defined at first and last river point (1 and %d) of river %d.",
					river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		else
		{
			/*
			 *   Interpolate k data
			 */
			i = 0;
			length = 0;
			x1 = 0;
			while (i < river_ptr->count_points)
			{
				if (river_ptr->points[i].k_defined == TRUE)
				{
					length = 0;
					x1 = river_ptr->points[i].k;
				}
				else
				{
					k = i;
					while (river_ptr->points[k].k_defined == FALSE)
					{
						length +=
							river_distance(&(river_ptr->points[k]),
										   &(river_ptr->points[k - 1]));
						k++;
					}
					length +=
						river_distance(&(river_ptr->points[k]),
									   &(river_ptr->points[k - 1]));
					total_length = length;
					x2 = river_ptr->points[k].k;
					if (total_length == 0)
						total_length = 1.0;
					length = 0;
					for (; i < k; i++)
					{
						length +=
							river_distance(&(river_ptr->points[i]),
										   &(river_ptr->points[i - 1]));
						river_ptr->points[i].k =
							x1 + length / total_length * (x2 - x1);
					}
				}
				i++;
			}
		}
		/*
		 *   Check thickness data
		 */
		if (river_ptr->points[0].thickness_defined == FALSE
			|| river_ptr->points[river_ptr->count_points -
								 1].thickness_defined == FALSE)
		{
			sprintf(error_string,
					"Thickness must be defined at first and last river point (1 and %d) of river %d.",
					river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		else
		{
			/*
			 *   Interpolate thickness data
			 */
			i = 0;
			length = 0;
			x1 = 0;
			while (i < river_ptr->count_points)
			{
				if (river_ptr->points[i].thickness_defined == TRUE)
				{
					length = 0;
					x1 = river_ptr->points[i].thickness;
				}
				else
				{
					k = i;
					while (river_ptr->points[k].thickness_defined == FALSE)
					{
						length +=
							river_distance(&(river_ptr->points[k]),
										   &(river_ptr->points[k - 1]));
						k++;
					}
					length +=
						river_distance(&(river_ptr->points[k]),
									   &(river_ptr->points[k - 1]));
					total_length = length;
					x2 = river_ptr->points[k].thickness;
					if (total_length == 0)
						total_length = 1.0;
					length = 0;
					for (; i < k; i++)
					{
						length +=
							river_distance(&(river_ptr->points[i]),
										   &(river_ptr->points[i - 1]));
						river_ptr->points[i].thickness =
							x1 + length / total_length * (x2 - x1);
					}
				}
				i++;
			}
		}
		/*
		 *   Check solution data
		 */
		if (flow_only == FALSE)
		{
			if (river_ptr->points[0].solution_defined == FALSE
				|| river_ptr->points[river_ptr->count_points -
									 1].solution_defined == FALSE)
			{
				sprintf(error_string,
						"Solution must be defined at first and last river point (1 and %d) of river %d.",
						river_ptr->count_points, j);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			}
			else
			{
				/*
				 *   Interpolate solution data
				 */
				i = 0;
				length = 0;
				i1 = -999;
				while (i < river_ptr->count_points)
				{
					if (river_ptr->points[i].solution_defined == TRUE)
					{
						length = 0;
						i1 = river_ptr->points[i].current_solution;
						river_ptr->points[i].solution1 =
							river_ptr->points[i].current_solution;
						river_ptr->points[i].solution2 = -1;
						river_ptr->points[i].f1 = 1.0;
						i++;
					}
					else
					{
						k = i;
						while (river_ptr->points[k].solution_defined == FALSE)
						{
							length +=
								river_distance(&(river_ptr->points[k]),
											   &(river_ptr->points[k - 1]));
							k++;
						}
						i2 = k;
						length +=
							river_distance(&(river_ptr->points[k]),
										   &(river_ptr->points[k - 1]));
						total_length = length;
						i2 = river_ptr->points[k].current_solution;
						if (total_length == 0)
							total_length = 1.0;
						length = 0;
						for (; i < k; i++)
						{
							length +=
								river_distance(&(river_ptr->points[i]),
											   &(river_ptr->points[i - 1]));
							river_ptr->points[i].solution1 = i1;
							river_ptr->points[i].solution2 = i2;
							river_ptr->points[i].f1 =
								1 - length / total_length;
						}
					}
				}
			}
		}
		/*
		 *   Calculate z from depth for points without z data
		 */
		for (i = 0; i < river_ptr->count_points; i++)
		{
			if (river_ptr->points[i].head_defined == TRUE
				&& river_ptr->points[i].depth_defined == TRUE
				&& river_ptr->points[i].z_defined == FALSE)
			{
				river_ptr->points[i].z =
					river_ptr->points[i].current_head -
					river_ptr->points[i].depth;
				river_ptr->points[i].z_defined = TRUE;
			}
		}
		/* 
		 *   Check z data
		 */
		if (river_ptr->points[0].z_defined == FALSE
			|| river_ptr->points[river_ptr->count_points - 1].z_defined ==
			FALSE)
		{
			sprintf(error_string,
					"River bottom or depth must be defined at first and last river point (1 and %d) of river %d.",
					river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		else
		{
			/*
			 *   Interpolate z data
			 */
			i = 0;
			length = 0;
			x1 = 0;
			while (i < river_ptr->count_points)
			{
				if (river_ptr->points[i].z_defined == TRUE)
				{
					length = 0;
					x1 = river_ptr->points[i].z;
				}
				else
				{
					k = i;
					while (river_ptr->points[k].z_defined == FALSE)
					{
						length +=
							river_distance(&(river_ptr->points[k]),
										   &(river_ptr->points[k - 1]));
						k++;
					}
					length +=
						river_distance(&(river_ptr->points[k]),
									   &(river_ptr->points[k - 1]));
					total_length = length;
					x2 = river_ptr->points[k].z;
					if (total_length == 0)
						total_length = 1.0;
					length = 0;
					for (; i < k; i++)
					{
						length +=
							river_distance(&(river_ptr->points[i]),
										   &(river_ptr->points[i - 1]));
						river_ptr->points[i].z =
							x1 + length / total_length * (x2 - x1);
					}
				}
				i++;
			}
		}
	}
	/*
	 *   Check for duplicate numbers
	 */
	for (j = 0; j < count_rivers; j++)
	{
		for (i = j + 1; i < count_rivers; i++)
		{
			if (rivers[j].n_user == rivers[i].n_user)
			{
				sprintf(error_string,
						"Two rivers have the same identifying number. Sequence number %d %s and sequence number %d %s.",
						j, rivers[j].description, i, rivers[i].description);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			}
		}
	}
	return (return_value);
}
#endif
/* ---------------------------------------------------------------------- */
int
tidy_rivers(void)
/* ---------------------------------------------------------------------- */
{
	/*
	*   Check river data 
	*/
	int i, j, k, return_value;
	double length, total_length, head1, head2;
	River *river_ptr;
	double x1, x2;
	int i1, i2;
	return_value = OK;
	if (count_rivers <= 0)
		return (OK);
	if (simulation > 0)
		return (OK);

	for (j = 0; j < count_rivers; j++)
	{
		assert(rivers[j].new_def == TRUE);
		if (rivers[j].new_def == FALSE)
			continue;
		rivers[j].update = TRUE;
		river_ptr = &(rivers[j]);
		/*
		*  Logical checks on river
		*/
		if (river_ptr->count_points < 2)
		{
			sprintf(error_string,
				"River must have at least 2 points. River %d %s.",
				river_ptr->n_user, river_ptr->description);
			error_msg(error_string, CONTINUE);
			return_value = FALSE;
			input_error++;
		}
		/*
		*   Check river data
		*/
		for (i = 0; i < river_ptr->count_points; i++)
		{
			river_ptr->points[i].update = TRUE;
			rivers_update = TRUE;
			if (river_ptr->points[i].x_user_defined == FALSE
				|| river_ptr->points[i].y_user_defined == FALSE)
			{
				sprintf(error_string,
					"X or Y not defined for river point %d of river %d.",
					i + 1, j);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			}
		}
		/*
		*   Check head data
		*/
		if (river_ptr->points[0].head_defined == FALSE
			|| river_ptr->points[river_ptr->count_points - 1].head_defined ==
			FALSE)
		{
			sprintf(error_string,
				"Head must be defined at first and last river point (1 and %d) of river %d.",
				river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		/*
		*   Check width data
		*/
		if (river_ptr->points[0].width_user_defined == FALSE
			|| river_ptr->points[river_ptr->count_points - 1].width_user_defined ==	FALSE)
		{
			sprintf(error_string,
				"Width must be defined at first and last river point (1 and %d) of river %d.",
				river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		/*
		*   Check k data
		*/
		if (river_ptr->points[0].k_defined == FALSE
			|| river_ptr->points[river_ptr->count_points - 1].k_defined == FALSE)
		{
			sprintf(error_string,
				"Hydraulic conductivity must be defined at first and last river point (1 and %d) of river %d.",
				river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		/*
		*   Check thickness data
		*/
		if (river_ptr->points[0].thickness_defined == FALSE
			|| river_ptr->points[river_ptr->count_points - 1].thickness_defined == FALSE)
		{
			sprintf(error_string,
				"Thickness must be defined at first and last river point (1 and %d) of river %d.",
				river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		/*
		*   Check solution data
		*/
		if (flow_only == FALSE)
		{
			if (river_ptr->points[0].solution_defined == FALSE
				|| river_ptr->points[river_ptr->count_points - 1].solution_defined == FALSE)
			{
				sprintf(error_string,
					"Solution must be defined at first and last river point (1 and %d) of river %d.",
					river_ptr->count_points, j);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			}
		}
		/* 
		*   Check z data
		*/
		if ((river_ptr->points[0].z_user_defined == FALSE && river_ptr->points[0].depth_user_defined == FALSE)
			|| (river_ptr->points[river_ptr->count_points - 1].z_user_defined == FALSE && river_ptr->points[river_ptr->count_points - 1].depth_user_defined == FALSE))
		{
			sprintf(error_string,
				"River bottom or depth must be defined at first and last river point (1 and %d) of river %d.",
				river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
	}

	if (return_value == FALSE) return (FALSE);




	for (j = 0; j < count_rivers; j++)
	{
		river_ptr = &(rivers[j]);

		river_convert_xy_to_grid(&rivers[j], map_to_grid);
		river_convert_z_to_grid(&rivers[j],map_to_grid);
		river_convert_width_to_grid(&rivers[j]);

		/*
		*   Interpolate head data
		*/
		i = 0;
		length = 0;
		head1 = 0;
		while (i < river_ptr->count_points)
		{
			if (river_ptr->points[i].head_defined == TRUE)
			{
				length = 0;
				head1 = river_ptr->points[i].current_head;
			}
			else
			{
				k = i;
				while (river_ptr->points[k].head_defined == FALSE)
				{
					length +=
						river_distance_grid(&(river_ptr->points[k]),
						&(river_ptr->points[k - 1]));
					k++;
				}
				length +=
					river_distance_grid(&(river_ptr->points[k]),
					&(river_ptr->points[k - 1]));
				total_length = length;
				head2 = river_ptr->points[k].current_head;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(river_ptr->points[i]),
						&(river_ptr->points[i - 1]));
					river_ptr->points[i].current_head =
						head1 + length / total_length * (head2 - head1);
				}
			}
			i++;
		}

		/*
		*   Interpolate width data
		*/
		i = 0;
		length = 0;
		x1 = 0;
		while (i < river_ptr->count_points)
		{
			if (river_ptr->points[i].width_user_defined == TRUE)
			{
				length = 0;
				x1 = river_ptr->points[i].width_grid;
			}
			else
			{
				k = i;
				while (river_ptr->points[k].width_user_defined == FALSE)
				{
					length +=
						river_distance_grid(&(river_ptr->points[k]),
						&(river_ptr->points[k - 1]));
					k++;
				}
				length +=
					river_distance_grid(&(river_ptr->points[k]),
					&(river_ptr->points[k - 1]));
				total_length = length;
				x2 = river_ptr->points[k].width_grid;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(river_ptr->points[i]),
						&(river_ptr->points[i - 1]));
					river_ptr->points[i].width_grid =
						x1 + length / total_length * (x2 - x1);
				}
			}
			i++;
		}

		/*
		*   Interpolate k data
		*/
		i = 0;
		length = 0;
		x1 = 0;
		while (i < river_ptr->count_points)
		{
			if (river_ptr->points[i].k_defined == TRUE)
			{
				length = 0;
				x1 = river_ptr->points[i].k;
			}
			else
			{
				k = i;
				while (river_ptr->points[k].k_defined == FALSE)
				{
					length +=
						river_distance_grid(&(river_ptr->points[k]),
						&(river_ptr->points[k - 1]));
					k++;
				}
				length +=
					river_distance_grid(&(river_ptr->points[k]),
					&(river_ptr->points[k - 1]));
				total_length = length;
				x2 = river_ptr->points[k].k;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(river_ptr->points[i]),
						&(river_ptr->points[i - 1]));
					river_ptr->points[i].k =
						x1 + length / total_length * (x2 - x1);
				}
			}
			i++;
		}

		/*
		*   Interpolate thickness data
		*/
		i = 0;
		length = 0;
		x1 = 0;
		while (i < river_ptr->count_points)
		{
			if (river_ptr->points[i].thickness_defined == TRUE)
			{
				length = 0;
				x1 = river_ptr->points[i].thickness;
			}
			else
			{
				k = i;
				while (river_ptr->points[k].thickness_defined == FALSE)
				{
					length +=
						river_distance_grid(&(river_ptr->points[k]),
						&(river_ptr->points[k - 1]));
					k++;
				}
				length +=
					river_distance_grid(&(river_ptr->points[k]),
					&(river_ptr->points[k - 1]));
				total_length = length;
				x2 = river_ptr->points[k].thickness;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(river_ptr->points[i]),
						&(river_ptr->points[i - 1]));
					river_ptr->points[i].thickness =
						x1 + length / total_length * (x2 - x1);
				}
			}
			i++;
		}

		/*
		*   Interpolate solution data
		*/
		i = 0;
		length = 0;
		i1 = -999;
		if (flow_only == FALSE)
		{
			while (i < river_ptr->count_points)
			{
				if (river_ptr->points[i].solution_defined == TRUE)
				{
					length = 0;
					i1 = river_ptr->points[i].current_solution;
					river_ptr->points[i].solution1 =
						river_ptr->points[i].current_solution;
					river_ptr->points[i].solution2 = -1;
					river_ptr->points[i].f1 = 1.0;
					i++;
				}
				else
				{
					k = i;
					while (river_ptr->points[k].solution_defined == FALSE)
					{
						length +=
							river_distance_grid(&(river_ptr->points[k]),
							&(river_ptr->points[k - 1]));
						k++;
					}
					i2 = k;
					length +=
						river_distance_grid(&(river_ptr->points[k]),
						&(river_ptr->points[k - 1]));
					total_length = length;
					i2 = river_ptr->points[k].current_solution;
					if (total_length == 0)
						total_length = 1.0;
					length = 0;
					for (; i < k; i++)
					{
						length +=
							river_distance_grid(&(river_ptr->points[i]),
							&(river_ptr->points[i - 1]));
						river_ptr->points[i].solution1 = i1;
						river_ptr->points[i].solution2 = i2;
						river_ptr->points[i].f1 =
							1 - length / total_length;
					}
				}
			}
		}



		/*
		*   Calculate z from depth for points without z data
		*/
		for (i = 0; i < river_ptr->count_points; i++)
		{
			if (/*river_ptr->points[i].head_defined == TRUE	&&*/ /* head has been interpolated */
				river_ptr->points[i].depth_user_defined == TRUE
				&& river_ptr->points[i].z_user_defined == FALSE)
			{
				river_ptr->points[i].z_grid =
					river_ptr->points[i].current_head * units.head.input_to_si / units.vertical.input_to_si -
					river_ptr->points[i].depth_user * units.river_depth.input_to_si / units.vertical.input_to_si;
				//river_ptr->points[i].z_user_defined = TRUE;
			}
		}

		/*
		*   Interpolate z data
		*/
		i = 0;
		length = 0;
		x1 = 0;
		while (i < river_ptr->count_points)
		{
			if (river_ptr->points[i].z_user_defined == TRUE || river_ptr->points[i].depth_user_defined == TRUE)
			{
				length = 0;
				x1 = river_ptr->points[i].z_grid;
			}
			else
			{
				k = i;
				while (river_ptr->points[k].z_user_defined == FALSE && river_ptr->points[k].depth_user_defined == FALSE)
				{
					length +=
						river_distance_grid(&(river_ptr->points[k]),
						&(river_ptr->points[k - 1]));
					k++;
				}
				length +=
					river_distance_grid(&(river_ptr->points[k]),
					&(river_ptr->points[k - 1]));
				total_length = length;
				x2 = river_ptr->points[k].z_grid;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(river_ptr->points[i]),
						&(river_ptr->points[i - 1]));
					river_ptr->points[i].z_grid =
						x1 + length / total_length * (x2 - x1);
				}
			}
			i++;
		}
	}

	/*
	*   Check for duplicate numbers
	*/
	for (j = 0; j < count_rivers; j++)
	{
		for (i = j + 1; i < count_rivers; i++)
		{
			if (rivers[j].n_user == rivers[i].n_user)
			{
				sprintf(error_string,
					"Two rivers have the same identifying number. Sequence number %d %s and sequence number %d %s.",
					j, rivers[j].description, i, rivers[i].description);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			}
		}
	}
	return (return_value);
}

/* ---------------------------------------------------------------------- */
int
build_rivers(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Check river data 
 */
	int i, j, n, count_points, return_code;
	River *river_ptr;
	gpc_vertex *p, phantom, vertex[4];
	gpc_polygon *trapezoid, *gap_polygon;

	return_code = OK;
	p = (gpc_vertex *) malloc((size_t) sizeof(gpc_vertex));
	if (p == NULL)
		malloc_error();

	if (count_rivers <= 0)
	{
		free_check_null(p);
		return (OK);
	}
	for (j = 0; j < count_rivers; j++)
	{
		if (rivers[j].new_def == FALSE)
			continue;
		rivers[j].new_def = FALSE;
		river_ptr = &(rivers[j]);
		if (river_ptr->count_points < 2)
		{
			sprintf(error_string,
					"River must have at least 2 points. River %d %s.",
					river_ptr->n_user, river_ptr->description);
			error_msg(error_string, CONTINUE);
			input_error++;
			continue;
		}
		count_points = river_ptr->count_points;
		/*
		 *  Build river topology
		 */
		p = (gpc_vertex *) realloc(p,
								   (size_t) river_ptr->count_points *
								   sizeof(gpc_vertex));
		if (p == NULL)
			malloc_error();
		for (i = 0; i < river_ptr->count_points; i++)
		{
			p[i].x = river_ptr->points[i].x_grid;
			p[i].y = river_ptr->points[i].y_grid;
		}
		/*
		 *  Trapezoid points for last River Point
		 */
		n = count_points - 1;
		phantom.x = p[n].x + (p[n].x - p[n - 1].x);
		phantom.y = p[n].y + (p[n].y - p[n - 1].y);
		trapezoid_points(p[n], phantom, &(river_ptr->points[n]),
						 river_ptr->points[n].width_grid);
		river_ptr->points[n].vertex[2].x = river_ptr->points[n].vertex[1].x;
		river_ptr->points[n].vertex[2].y = river_ptr->points[n].vertex[1].y;
		river_ptr->points[n].vertex[3].x = river_ptr->points[n].vertex[0].x;
		river_ptr->points[n].vertex[3].y = river_ptr->points[n].vertex[0].y;
		/*
		 *  Trapezoid points for River Points
		 */
		for (i = 0; i < count_points - 1; i++)
		{
			trapezoid_points(p[i], p[i + 1], &(river_ptr->points[i]),
							 river_ptr->points[i + 1].width_grid);
		}
		/*
		 *  Union of polygon and gap with next polygon
		 */
		for (i = 0; i < count_points - 2; i++)
		{
			river_ptr->points[i].polygon =
				vertex_to_poly(river_ptr->points[i].vertex, 4);
			trapezoid = vertex_to_poly(river_ptr->points[i].vertex, 4);

			vertex[0].x = river_ptr->points[i].vertex[2].x;
			vertex[0].y = river_ptr->points[i].vertex[2].y;
			vertex[1].x = river_ptr->points[i].vertex[3].x;
			vertex[1].y = river_ptr->points[i].vertex[3].y;
			vertex[2].x = river_ptr->points[i + 1].vertex[0].x;
			vertex[2].y = river_ptr->points[i + 1].vertex[0].y;
			vertex[3].x = river_ptr->points[i + 1].vertex[1].x;
			vertex[3].y = river_ptr->points[i + 1].vertex[1].y;
			gap_polygon = vertex_to_poly(vertex, 4);

			gpc_free_polygon(river_ptr->points[i].polygon);
			gpc_polygon_clip(GPC_UNION, trapezoid, gap_polygon,
							 river_ptr->points[i].polygon);

			gpc_free_polygon(trapezoid);
			free(trapezoid);
			gpc_free_polygon(gap_polygon);
			free(gap_polygon);


		}
		/*
		 *  Last polygon
		 */
		river_ptr->points[i].polygon =
			vertex_to_poly(river_ptr->points[i].vertex, 4);
	}
	/*
	 *   Free work space
	 */
	free_check_null(p);
	return (return_code);
}

/* ---------------------------------------------------------------------- */
int
update_rivers(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Check river data 
 */
	int i, j, k, count_points;
	River *river_ptr;
	double length, head1, total_length, head2;
	int i1, i2;

	rivers_update = FALSE;
	if (count_rivers <= 0)
		return (OK);
	for (j = 0; j < count_rivers; j++)
	{
		if (rivers[j].update == FALSE)
			continue;
		river_ptr = &(rivers[j]);
		rivers[j].new_def = UPDATE;
		rivers_update = TRUE;
		count_points = river_ptr->count_points;
		/*
		 *   Interpolate head data
		 */
		i = 0;
		length = 0;
		head1 = 0;
		while (i < river_ptr->count_points)
		{
			if (river_ptr->points[i].head_defined == TRUE)
			{
				length = 0;
				head1 = river_ptr->points[i].current_head;
			}
			else
			{
				k = i;
				while (river_ptr->points[k].head_defined == FALSE)
				{
					length +=
						river_distance_grid(&(river_ptr->points[k]),
									   &(river_ptr->points[k - 1]));
					k++;
				}
				length +=
					river_distance_grid(&(river_ptr->points[k]),
								   &(river_ptr->points[k - 1]));
				total_length = length;
				head2 = river_ptr->points[k].current_head;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(river_ptr->points[i]),
									   &(river_ptr->points[i - 1]));
					river_ptr->points[i].current_head =
						head1 + length / total_length * (head2 - head1);
					/* river_ptr->points[i].head_defined = TRUE; */
				}
			}
			i++;
		}
		/*
		 *   Interpolate solution data
		 */
		i = 0;
		length = 0;
		i1 = -999;
		while (i < river_ptr->count_points)
		{
			if (river_ptr->points[i].solution_defined == TRUE)
			{
				length = 0;
				i1 = river_ptr->points[i].current_solution;
				river_ptr->points[i].solution1 =
					river_ptr->points[i].current_solution;
				river_ptr->points[i].solution2 = -1;
				river_ptr->points[i].f1 = 1.0;
				i++;
			}
			else
			{
				k = i;
				while (river_ptr->points[k].solution_defined == FALSE)
				{
					length +=
						river_distance_grid(&(river_ptr->points[k]),
									   &(river_ptr->points[k - 1]));
					k++;
				}
				i2 = k;
				length +=
					river_distance_grid(&(river_ptr->points[k]),
								   &(river_ptr->points[k - 1]));
				total_length = length;
				i2 = river_ptr->points[k].current_solution;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(river_ptr->points[i]),
									   &(river_ptr->points[i - 1]));
					river_ptr->points[i].solution1 = i1;
					river_ptr->points[i].solution2 = i2;
					river_ptr->points[i].f1 = 1 - length / total_length;
				}
			}
		}
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_rivers(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Check river data 
 */
	int i, j, k, count_points;
	River *river_ptr;

	if (count_rivers <= 0)
		return (OK);
	for (j = 0; j < count_rivers; j++)
	{
		if (rivers[j].new_def != FALSE)
			continue;
		river_ptr = &(rivers[j]);
		count_points = river_ptr->count_points;
		/*
		 *   Write points for river
		 */
		output_msg(OUTPUT_ECHO, "@type xy\n");
		output_msg(OUTPUT_ECHO, "#river segments %d %s\n", river_ptr->n_user,
				   river_ptr->description);
		for (i = 0; i < river_ptr->count_points; i++)
		{
			output_msg(OUTPUT_ECHO, "\t%15e\t%15e\n", river_ptr->points[i].x_grid,
					   river_ptr->points[i].y_grid);
		}
		output_msg(OUTPUT_ECHO, "&\n");
		/*
		 *   Write polygons for river
		 */
		output_msg(OUTPUT_ECHO, "@type xy\n");
		output_msg(OUTPUT_ECHO, "#river polygons %d %s\n", river_ptr->n_user,
				   river_ptr->description);
		for (i = 0; i < river_ptr->count_points - 1; i++)
		{
			for (k = 0; k < 4; k++)
			{
				output_msg(OUTPUT_ECHO, "\t%15e\t%15e\n",
						   river_ptr->points[i].vertex[k].x,
						   river_ptr->points[i].vertex[k].y);
			}
			output_msg(OUTPUT_ECHO, "\t%15e\t%15e\n",
					   river_ptr->points[i].vertex[0].x,
					   river_ptr->points[i].vertex[0].y);
		}
		output_msg(OUTPUT_ECHO, "&\n");
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
double
river_distance_grid(River_Point * river_ptr1, River_Point * river_ptr2)
/* ---------------------------------------------------------------------- */
{
/*
 *   Calculate distance between two points
 */
	double x, y;

	x = river_ptr2->x_grid - river_ptr1->x_grid;
	y = river_ptr2->y_grid - river_ptr1->y_grid;
	return (sqrt(x * x + y * y));
}

/* ---------------------------------------------------------------------- */
int
check_quad(gpc_vertex * v)
/* ---------------------------------------------------------------------- */
{
	double angle, angle1;

	angle = 0;
	/*
	 *   absolute angle of segments
	 */
	angle1 = angle_between_segments(v[0], v[1], v[2]);
#ifdef DEBUG_RIVERS
	output_msg(OUTPUT_STDERR, "Angle1 %g\n", angle1);
#endif
	if (angle1 > PI)
		angle1 = 2 * PI - angle1;
	angle += angle1;
	angle1 = angle_between_segments(v[1], v[2], v[3]);
#ifdef DEBUG_RIVERS
	output_msg(OUTPUT_STDERR, "Angle2 %g\n", angle1);
#endif
	if (angle1 > PI)
		angle1 = 2 * PI - angle1;
	angle += angle1;
	angle1 = angle_between_segments(v[2], v[3], v[0]);
#ifdef DEBUG_RIVERS
	output_msg(OUTPUT_STDERR, "Angle3 %g\n", angle1);
#endif
	if (angle1 > PI)
		angle1 = 2 * PI - angle1;
	angle += angle1;
	angle1 = angle_between_segments(v[3], v[0], v[1]);
#ifdef DEBUG_RIVERS
	output_msg(OUTPUT_STDERR, "Angle4 %g\n", angle1);
#endif
	if (angle1 > PI)
		angle1 = 2 * PI - angle1;
	angle += angle1;
#ifdef DEBUG_RIVERS
	output_msg(OUTPUT_STDERR, "Angle %g\n", angle);
#endif
	if (angle + 1e-8 < 2 * PI)
		return (ERROR);

	return (OK);
}


/* ---------------------------------------------------------------------- */
int
trapezoid_points(gpc_vertex p0, gpc_vertex p1, River_Point * r_ptr,
				 double width1)
/* ---------------------------------------------------------------------- */
{
	double width0;
	double a, b;
	double x, y;

	width0 = r_ptr->width_grid;
	/*
	 *   Translate to origin
	 */
	x = p1.x - p0.x;
	y = p1.y - p0.y;
	/*
	 *    
	 */
	if (x != 0 || y != 0)
	{
		a = x / sqrt(x * x + y * y);
		b = y / sqrt(x * x + y * y);
	}
	else
	{
		a = 0;
		b = 0;
	}
	/*
	 *   position of points
	 */

	/* right point 0 */
	r_ptr->vertex[0].x = p0.x + b * width0 / 2;
	r_ptr->vertex[0].y = p0.y - a * width0 / 2;
	/* left point 0 */
	r_ptr->vertex[1].x = p0.x - b * width0 / 2;
	r_ptr->vertex[1].y = p0.y + a * width0 / 2;
	/* left point 1 */
	r_ptr->vertex[2].x = p1.x - b * width1 / 2;
	r_ptr->vertex[2].y = p1.y + a * width1 / 2;
	/* right point 1 */
	r_ptr->vertex[3].x = p1.x + b * width1 / 2;
	r_ptr->vertex[3].y = p1.y - a * width1 / 2;

	return (OK);
}

/* ---------------------------------------------------------------------- */
int
interpolate(River_Polygon * river_polygon_ptr)
/* ---------------------------------------------------------------------- */
{
	River_Point *p0_ptr, *p1_ptr;
	gpc_polygon *poly, *slice;
	gpc_vertex vertex[3], centroid, c3;
	double a2, Areasum2;
	double w0, w1;
	int i, j;
	double x0, y0, x1, y1, x2, y2, xn, yn, zn, dist;

	p0_ptr =
		&(rivers[river_polygon_ptr->river_number].
		  points[river_polygon_ptr->point_number]);
	p1_ptr =
		&(rivers[river_polygon_ptr->river_number].
		  points[river_polygon_ptr->point_number + 1]);
	poly = river_polygon_ptr->poly;
	/*
	 *   find centroid of polygon
	 */
	Areasum2 = 0.0;
	for (i = 0; i < poly->num_contours; i++)
	{
		vertex[0].x = poly->contour[i].vertex[0].x;
		vertex[0].y = poly->contour[i].vertex[0].y;
		centroid.x = 0;
		centroid.y = 0;
		for (j = 1; j < poly->contour[i].num_vertices - 1; j++)
		{
			Centroid3(poly->contour[i].vertex[0], poly->contour[i].vertex[j],
					  poly->contour[i].vertex[j + 1], &c3);
			vertex[1].x = poly->contour[i].vertex[j].x;
			vertex[1].y = poly->contour[i].vertex[j].y;
			vertex[2].x = poly->contour[i].vertex[j + 1].x;
			vertex[2].y = poly->contour[i].vertex[j + 1].y;
			slice = vertex_to_poly(vertex, 3);
			a2 = 2 * gpc_polygon_area(slice);
			centroid.x += a2 * c3.x;
			centroid.y += a2 * c3.y;
			Areasum2 += a2;
			gpc_free_polygon(slice);
			free(slice);
		}
	}
	centroid.x /= 3 * Areasum2;
	centroid.y /= 3 * Areasum2;
	x0 = centroid.x;
	y0 = centroid.y;
	x1 = p0_ptr->x_grid;
	y1 = p0_ptr->y_grid;
	x2 = p1_ptr->x_grid;
	y2 = p1_ptr->y_grid;
	/* distance from centroid to line is */
	Point::line_seg_point_near_3d(x1, y1, 0,
								  x2, y2, 0,
								  x0, y0, 0, &xn, &yn, &zn, &dist, &w1);

	/*
	 *   Calculate weighting factors for River_Point 0 and 1
	 */
	w0 = 1 - w1;
	/*
	 *   Put weighted values in River_Polygon
	 */
	river_polygon_ptr->w = w0;

	return (OK);
}

/* ---------------------------------------------------------------------- */
void
river_point_init(River_Point * rp_ptr)
/* ---------------------------------------------------------------------- */
{
	rp_ptr->x_user = 0.0;
	rp_ptr->x_user_defined = FALSE;
	rp_ptr->y_user = 0.0;
	rp_ptr->y_user_defined = FALSE;
	rp_ptr->width_user = 0.0;
	rp_ptr->width_user_defined = FALSE;
	rp_ptr->k = 0.0;
	rp_ptr->k_defined = FALSE;
	rp_ptr->thickness = 0.0;
	rp_ptr->thickness_defined = FALSE;
	rp_ptr->head = NULL;
	rp_ptr->head_defined = FALSE;
	rp_ptr->current_head = 0.0;
	rp_ptr->depth_user = 0.0;
	rp_ptr->depth_user_defined = FALSE;
	rp_ptr->z_user = 0.0;
	rp_ptr->z_user_defined = FALSE;
	//rp_ptr->z_input_defined = FALSE;
	rp_ptr->solution = NULL;
	rp_ptr->solution_defined = FALSE;
	rp_ptr->current_solution = -999999;
	rp_ptr->solution1 = -99;
	rp_ptr->solution2 = -99;
	rp_ptr->f1 = 1.0;
	rp_ptr->x_grid = 0.0;
	rp_ptr->y_grid = 0.0;
	rp_ptr->z_grid = 0.0;
	rp_ptr->width_grid = 0.0;
	// Initialize vertices
	int i;
	for (i = 0; i < 4; i++)
	{
		rp_ptr->vertex[i].x = 0.0;
		rp_ptr->vertex[i].y = 0.0;
	}
	rp_ptr->polygon = NULL;
	rp_ptr->update = 0;

}

/* ---------------------------------------------------------------------- */
void
river_polygon_init(River_Polygon * rp_ptr)
/* ---------------------------------------------------------------------- */
{
	rp_ptr->poly = NULL;
	rp_ptr->x = 0;
	rp_ptr->y = 0;
	rp_ptr->area = 0;
	rp_ptr->river_number = -1;
	rp_ptr->point_number = -1;
	rp_ptr->w = 0;
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
void
rivers_convert_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM target,
								 PHAST_Transform * map2grid)
/* ---------------------------------------------------------------------- */
{
	River *river_ptr;
/*
 *   Convert coordinates of all rivers 
 */
	int j;
	if (count_rivers <= 0)
		return;
	if (simulation > 0)
		return;

	// Convert coordinate system for river points
	for (j = 0; j < count_rivers; j++)
	{
		assert(rivers[j].new_def == TRUE);
		if (rivers[j].new_def == FALSE)
			continue;
		river_ptr = &(rivers[j]);
		river_convert_coordinate_system(river_ptr, target, map2grid);
	}
}

/* ---------------------------------------------------------------------- */
void
river_convert_coordinate_system(River * river_ptr,
								PHAST_Transform::COORDINATE_SYSTEM target,
								PHAST_Transform * map2grid)
/* ---------------------------------------------------------------------- */
{
	int i;
	if (river_ptr->coordinate_system == target)
		return;
	if (river_ptr->coordinate_system == PHAST_Transform::NONE)
	{
		sprintf(error_string, "Error with coordinate system for river %d %s.",
				river_ptr->n_user, river_ptr->description);
		error_msg(error_string, CONTINUE);
		input_error++;
		return;
	}
	switch (target)
	{
	case PHAST_Transform::GRID:
		for (i = 0; i < river_ptr->count_points; i++)
		{
			if (river_ptr->points[i].x_defined == FALSE
				|| river_ptr->points[i].y_defined == FALSE)
			{
				input_error++;
				continue;
			}
			Point p(river_ptr->points[i].x, river_ptr->points[i].y, 0.0);
			map2grid->Transform(p);
			river_ptr->points[i].x = p.x();
			river_ptr->points[i].y = p.y();
		}
		river_ptr->coordinate_system = PHAST_Transform::GRID;
		break;
	case PHAST_Transform::MAP:
		for (i = 0; i < river_ptr->count_points; i++)
		{
			if (river_ptr->points[i].x_defined == FALSE
				|| river_ptr->points[i].y_defined == FALSE)
			{
				input_error++;
				continue;
			}
			Point p(river_ptr->points[i].x, river_ptr->points[i].y, 0.0);
			map2grid->Inverse_transform(p);
			river_ptr->points[i].x = p.x();
			river_ptr->points[i].y = p.y();
		}
		river_ptr->coordinate_system = PHAST_Transform::MAP;
		break;
	default:
		sprintf(error_string,
				"Error converting river coordinate system %d, %s",
				river_ptr->n_user, river_ptr->description);
		error_msg(error_string, CONTINUE);
		input_error++;
	}
}
#endif
/* ---------------------------------------------------------------------- */
void
river_convert_xy_to_grid(River * river_ptr, PHAST_Transform * map2grid)
/* ---------------------------------------------------------------------- */
{
	int i;

	if (river_ptr->coordinate_system == PHAST_Transform::NONE)
	{
		sprintf(error_string, "Error with XY coordinate system for river %d %s.",
			river_ptr->n_user, river_ptr->description);
		error_msg(error_string, CONTINUE);
		input_error++;
		return;
	}
	switch (river_ptr->coordinate_system)
	{
	case PHAST_Transform::GRID:
		for (i = 0; i < river_ptr->count_points; i++)
		{
			if (river_ptr->points[i].x_user_defined == FALSE
				|| river_ptr->points[i].y_user_defined == FALSE)
			{

				input_error++;
				sprintf(error_string, "Missing X or Y coordinate %d, %s",
					river_ptr->n_user, river_ptr->description);
				error_msg(error_string, CONTINUE);
				return;
			}
			river_ptr->points[i].x_grid = river_ptr->points[i].x_user;
			river_ptr->points[i].y_grid = river_ptr->points[i].y_user;
		}
		break;
	case PHAST_Transform::MAP:
		for (i = 0; i < river_ptr->count_points; i++)
		{
			if (river_ptr->points[i].x_user_defined == FALSE
				|| river_ptr->points[i].y_user_defined == FALSE)
			{

				input_error++;
				sprintf(error_string, "Missing X or Y coordinate %d, %s",
					river_ptr->n_user, river_ptr->description);
				error_msg(error_string, CONTINUE);
				return;
			}
			Point p(river_ptr->points[i].x_user, river_ptr->points[i].y_user, 0.0);
			map2grid->Transform(p);
			river_ptr->points[i].x_grid = p.x();
			river_ptr->points[i].y_grid = p.y();
		}
		break;
	default:
		sprintf(error_string,
			"Error converting drain coordinate system %d, %s",
			river_ptr->n_user, river_ptr->description);
		error_msg(error_string, CONTINUE);
		input_error++;
	}
}
/* ---------------------------------------------------------------------- */
void
river_convert_z_to_grid(River * river_ptr, PHAST_Transform * map2grid)
/* ---------------------------------------------------------------------- */
{
	int i;

	if (river_ptr->coordinate_system == PHAST_Transform::NONE)
	{
		sprintf(error_string, "Error with Z coordinate system for river %d %s.",
			river_ptr->n_user, river_ptr->description);
		error_msg(error_string, CONTINUE);
		input_error++;
		return;
	}
	switch (river_ptr->coordinate_system)
	{
	case PHAST_Transform::GRID:
		for (i = 0; i < river_ptr->count_points; i++)
		{
			if (river_ptr->points[i].z_user_defined == TRUE)
			{
				river_ptr->points[i].z_grid = river_ptr->points[i].z_user;
			}
		}
		break;
	case PHAST_Transform::MAP:
		for (i = 0; i < river_ptr->count_points; i++)
		{
			if (river_ptr->points[i].z_user_defined == TRUE)
			{
				Point p(0.0, 0.0, river_ptr->points[i].z_user);
				map2grid->Transform(p);
				river_ptr->points[i].z_grid = p.z();
			}
		}
		break;
	default:
		sprintf(error_string,
			"Error converting drain coordinate system %d, %s",
			river_ptr->n_user, river_ptr->description);
		error_msg(error_string, CONTINUE);
		input_error++;
	}
}
/* ---------------------------------------------------------------------- */
void
river_convert_width_to_grid(River * river_ptr)
/* ---------------------------------------------------------------------- */
{
	int i;

	for (i = 0; i < river_ptr->count_points; i++)
	{
		if (river_ptr->points[i].width_user_defined == TRUE)
		{
			river_ptr->points[i].width_grid = river_ptr->points[i].width_user * units.river_width.input_to_si / units.horizontal.input_to_si;
		}
	}

}
