#define EXTERNAL
#include "hstinpt.h"
#include "message.h"
static char const svnid[] = "$Id$";

/* ---------------------------------------------------------------------- */
int setup_rivers(void)
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

	if (count_rivers <= 0) return(OK);
	/*
	 *   gpc_vertex list for cell boundary
	 */
	p = malloc((size_t) 4 * sizeof (gpc_vertex));
	if (p == NULL) malloc_error();
	/*
	 *   gpc_polygon for cell boundary
	 */
	poly2.contour = malloc((size_t) sizeof(gpc_vertex_list));
	if (poly2.contour == NULL) malloc_error();
	poly2.contour[0].vertex = p;
	poly2.contour[0].num_vertices = 4;
	poly2.num_contours = 1;
	/*
	 *   Go through each river polygon
	 *   Intersect with cells
	 *   Save intersection in Cell structure
	 */
	for (l = 0; l < count_rivers; l++) {
		if (rivers[l].new_def != FALSE) continue;
		river_ptr = &(rivers[l]);
		count_points = river_ptr->count_points;
		/*
		 *  Go through river polygons
		 */
		for (m = 0; m < count_points - 1; m++) {
			poly_ptr = river_ptr->points[m].polygon;
			range_ptr = vertex_to_range(poly_ptr->contour[0].vertex, poly_ptr->contour[0].num_vertices);
			/*
			 *   Set gpc_polygon for cell boundary
			 */
			k = range_ptr->k1;
			for (i = range_ptr->i1; i <= range_ptr->i2; i++) {
				for (j = range_ptr->j1; j <= range_ptr->j2; j++) {
					n = ijk_to_n(i, j, k);
					p[0].x = cells[n].zone->x1;
					p[0].y = cells[n].zone->y1;
					p[1].x = cells[n].zone->x2;
					p[1].y = cells[n].zone->y1;
					p[2].x = cells[n].zone->x2;
					p[2].y = cells[n].zone->y2;
					p[3].x = cells[n].zone->x1;
					p[3].y = cells[n].zone->y2;
					gpc_polygon_clip(GPC_INT, poly_ptr, &poly2, &intersection);
					/*
					 *   check if intersection empty
					 */
					if (intersection.num_contours == 0) {
						gpc_free_polygon(&intersection);
						continue;
					}
					/*
					 *   Allocate space
					 */
					count_river_polygons = cells[n].count_river_polygons++;
					cells[n].river_polygons = realloc ( cells[n].river_polygons, (size_t) (count_river_polygons + 1) * sizeof (River_Polygon));
					if (cells[n].river_polygons == NULL) malloc_error();
					/*
					 *   Save River_Polygon for cell
					 */
					cells[n].river_polygons[count_river_polygons].poly = gpc_polygon_duplicate(&intersection);
					if (cells[n].river_polygons[count_river_polygons].poly->contour[0].num_vertices > 10) {
						output_msg(OUTPUT_STDERR,"Huhnn?\n");
					}
					cells[n].river_polygons[count_river_polygons].river_number = l;
					cells[n].river_polygons[count_river_polygons].point_number = m;
					gpc_free_polygon(&intersection);
				}
			}
			free_check_null(range_ptr);
		}
	}
	/*
	 *    Remove duplicate areas from cell river polygons
	 */
	for (i = 0; i < count_cells; i++) {
		if (cells[i].count_river_polygons <= 1) continue;
		for (j = 0; j < cells[i].count_river_polygons - 1; j++) {
			for (k = j + 1; k < cells[i].count_river_polygons; k++) {
				gpc_polygon_clip(GPC_INT, cells[i].river_polygons[k].poly, cells[i].river_polygons[j].poly, &intersection);
				if (intersection.num_contours == 0) {
					gpc_free_polygon(&intersection);
					continue;
				}
				gpc_free_polygon(&intersection);
				gpc_polygon_clip(GPC_DIFF, cells[i].river_polygons[k].poly, cells[i].river_polygons[j].poly, &intersection);				
				gpc_free_polygon(cells[i].river_polygons[k].poly);
				free_check_null(cells[i].river_polygons[k].poly);
				cells[i].river_polygons[k].poly = gpc_polygon_duplicate(&intersection);
				gpc_free_polygon(&intersection);
			}
		}
	}
	/*
	 *    Remove empty polygons
	 */
	for (i = 0; i < count_cells; i++) {
		if (cells[i].count_river_polygons < 1) continue;
		k = 0;
		for (j = 0; j < cells[i].count_river_polygons; j++) {
			if (cells[i].river_polygons[j].poly->num_contours == 0) {
				gpc_free_polygon(cells[i].river_polygons[j].poly);
			} else { 
				if (j != k) {
					cells[i].river_polygons[k].poly = gpc_polygon_duplicate(cells[i].river_polygons[j].poly);
				}
				k++;
			}
		}
		cells[i].count_river_polygons = k;
	}
	/*
	 *   Find interpolation point and weighing factor
	 */
	for (i = 0; i < count_cells; i++) {
		for (j = 0; j < cells[i].count_river_polygons; j++) {
			/*
			 *   Interpolate value for river_polygon
			 */
			cells[i].river_polygons[j].area = gpc_polygon_area(cells[i].river_polygons[j].poly);
#ifdef DEBUG
			output_msg(OUTPUT_STDERR,"#cell: %d\tarea: %e\n", i, cells[i].river_polygons[j].area);
#endif
			interpolate(&cells[i].river_polygons[j]);
#ifdef DEBUG
			output_msg(OUTPUT_STDERR,"\t%g\t%g\n", cells[i].river_polygons[j].x, cells[i].river_polygons[j].y);
			gpc_polygon_write(cells[i].river_polygons[j].poly);
#endif
		}
	}
	/*  frees contours and vertices p */
	gpc_free_polygon(&poly2);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int tidy_rivers(void)
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
	if (count_rivers <= 0) return(OK);
	if (simulation > 0) return(OK);
	for (j = 0; j < count_rivers; j++) {
		assert(rivers[j].new_def == TRUE);
		if (rivers[j].new_def == FALSE) continue;
		rivers[j].update = TRUE;
		river_ptr = &(rivers[j]);
		/*
		 *  Logical checks on river
		 */
		if (river_ptr->count_points < 2) {
			sprintf(error_string,"River must have at least 2 points. River %d %s.", river_ptr->n_user, river_ptr->description);
			error_msg(error_string, CONTINUE);
			return_value = FALSE;
			input_error++;
		}
		/*
		 *   Check river data
		 */
		for (i=0; i < river_ptr->count_points; i++) {
			river_ptr->points[i].update = TRUE;
			rivers_update = TRUE;
			if (river_ptr->points[i].x_defined == FALSE || river_ptr->points[i].y_defined == FALSE) {
				sprintf(error_string,"X or Y not defined for river point %d of river %d.", i + 1, j);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			}
		}
		/*
		 *   Check head data
		 */
		if (river_ptr->points[0].head_defined == FALSE || river_ptr->points[river_ptr->count_points - 1].head_defined == FALSE) {
			sprintf(error_string,"Head must be defined at first and last river point (1 and %d) of river %d.", river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		} else {
			/*
			 *   Interpolate head data
			 */
			i = 0;
			length = 0;
			head1 = 0;
			while (i < river_ptr->count_points) {
				if (river_ptr->points[i].head_defined == TRUE) {
					length = 0;
					head1 = river_ptr->points[i].current_head;
				} else {
					k = i;
					while (river_ptr->points[k].head_defined == FALSE) {
						length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
						k++;
					}
					length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
					total_length = length;
					head2 = river_ptr->points[k].current_head;
					if (total_length == 0) total_length = 1.0;
					length = 0;
					for ( ; i < k; i++) {
						length += river_distance(&(river_ptr->points[i]), &(river_ptr->points[i-1]));
						river_ptr->points[i].current_head = head1 + length/total_length*(head2 - head1);
					}
				}
				i++;
			}
		}
		/*
		 *   Check width data
		 */
		if (river_ptr->points[0].width_defined == FALSE || river_ptr->points[river_ptr->count_points - 1].width_defined == FALSE) {
			sprintf(error_string,"Width must be defined at first and last river point (1 and %d) of river %d.", river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		} else {
			/*
			 *   Interpolate width data
			 */
			i = 0;
			length = 0;
			x1 = 0;
			while (i < river_ptr->count_points) {
				if (river_ptr->points[i].width_defined == TRUE) {
					length = 0;
					x1 = river_ptr->points[i].width;
				} else {
					k = i;
					while (river_ptr->points[k].width_defined == FALSE) {
						length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
						k++;
					}
					length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
					total_length = length;
					x2 = river_ptr->points[k].width;
					if (total_length == 0) total_length = 1.0;
					length = 0;
					for ( ; i < k; i++) {
						length += river_distance(&(river_ptr->points[i]), &(river_ptr->points[i-1]));
						river_ptr->points[i].width = x1 + length/total_length*(x2 - x1);
					}
				}
				i++;
			}
		}
		/*
		 *   Check k data
		 */
		if (river_ptr->points[0].k_defined == FALSE || river_ptr->points[river_ptr->count_points - 1].k_defined == FALSE) {
			sprintf(error_string,"Hydraulic conductivity must be defined at first and last river point (1 and %d) of river %d.", river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		} else {
			/*
			 *   Interpolate k data
			 */
			i = 0;
			length = 0;
			x1 = 0;
			while (i < river_ptr->count_points) {
				if (river_ptr->points[i].k_defined == TRUE) {
					length = 0;
					x1 = river_ptr->points[i].k;
				} else {
					k = i;
					while (river_ptr->points[k].k_defined == FALSE) {
						length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
						k++;
					}
					length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
					total_length = length;
					x2 = river_ptr->points[k].k;
					if (total_length == 0) total_length = 1.0;
					length = 0;
					for ( ; i < k; i++) {
						length += river_distance(&(river_ptr->points[i]), &(river_ptr->points[i-1]));
						river_ptr->points[i].k = x1 + length/total_length*(x2 - x1);
					}
				}
				i++;
			}
		}
		/*
		 *   Check thickness data
		 */
		if (river_ptr->points[0].thickness_defined == FALSE || river_ptr->points[river_ptr->count_points - 1].thickness_defined == FALSE) {
			sprintf(error_string,"Thickness must be defined at first and last river point (1 and %d) of river %d.", river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		} else {
			/*
			 *   Interpolate thickness data
			 */
			i = 0;
			length = 0;
			x1 = 0;
			while (i < river_ptr->count_points) {
				if (river_ptr->points[i].thickness_defined == TRUE) {
					length = 0;
					x1 = river_ptr->points[i].thickness;
				} else {
					k = i;
					while (river_ptr->points[k].thickness_defined == FALSE) {
						length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
						k++;
					}
					length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
					total_length = length;
					x2 = river_ptr->points[k].thickness;
					if (total_length == 0) total_length = 1.0;
					length = 0;
					for ( ; i < k; i++) {
						length += river_distance(&(river_ptr->points[i]), &(river_ptr->points[i-1]));
						river_ptr->points[i].thickness = x1 + length/total_length*(x2 - x1);
					}
				}
				i++;
			}
		}
		/*
		 *   Check solution data
		 */
		if (flow_only == FALSE) {
			if (river_ptr->points[0].solution_defined == FALSE || river_ptr->points[river_ptr->count_points - 1].solution_defined == FALSE) {
				sprintf(error_string,"Solution must be defined at first and last river point (1 and %d) of river %d.", river_ptr->count_points, j);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			} else {
				/*
				 *   Interpolate solution data
				 */
				i = 0;
				length = 0;
				i1 = -999;
				while (i < river_ptr->count_points) {
					if (river_ptr->points[i].solution_defined == TRUE) {
						length = 0;
						i1 = river_ptr->points[i].current_solution;
						river_ptr->points[i].solution1 = river_ptr->points[i].current_solution;
						river_ptr->points[i].solution2 = -1;
						river_ptr->points[i].f1 = 1.0;
						i++;
					} else {
						k = i;
						while (river_ptr->points[k].solution_defined == FALSE) {
							length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
							k++;
						}
						i2 = k;
						length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
						total_length = length;
						i2 = river_ptr->points[k].current_solution;
						if (total_length == 0) total_length = 1.0;
						length = 0;
						for ( ; i < k; i++) {
							length += river_distance(&(river_ptr->points[i]), &(river_ptr->points[i-1]));
							river_ptr->points[i].solution1 = i1;
							river_ptr->points[i].solution2 = i2;
							river_ptr->points[i].f1 = 1 - length/total_length;
						}
					}
				}
			}
		}
		/*
		 *   Calculate z from depth for points without z data
		 */
		for (i = 0; i < river_ptr->count_points; i++) {
			if (river_ptr->points[i].head_defined == TRUE && river_ptr->points[i].depth_defined == TRUE && river_ptr->points[i].z_defined == FALSE) {
				river_ptr->points[i].z = river_ptr->points[i].current_head - river_ptr->points[i].depth;
				river_ptr->points[i].z_defined = TRUE;
			}
		}
		/* 
		 *   Check z data
		 */
		if (river_ptr->points[0].z_defined == FALSE || river_ptr->points[river_ptr->count_points - 1].z_defined == FALSE) {
			sprintf(error_string,"River bottom or depth must be defined at first and last river point (1 and %d) of river %d.", river_ptr->count_points, j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		} else {
			/*
			 *   Interpolate z data
			 */
			i = 0;
			length = 0;
			x1 = 0;
			while (i < river_ptr->count_points) {
				if (river_ptr->points[i].z_defined == TRUE) {
					length = 0;
					x1 = river_ptr->points[i].z;
				} else {
					k = i;
					while (river_ptr->points[k].z_defined == FALSE) {
						length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
						k++;
					}
					length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
					total_length = length;
					x2 = river_ptr->points[k].z;
					if (total_length == 0) total_length = 1.0;
					length = 0;
					for ( ; i < k; i++) {
						length += river_distance(&(river_ptr->points[i]), &(river_ptr->points[i-1]));
						river_ptr->points[i].z = x1 + length/total_length*(x2 - x1);
					}
				}
				i++;
			}
		}
	}
	/*
	 *   Check for duplicate numbers
	 */
	for (j = 0; j < count_rivers; j++) {
		for(i = j + 1; i < count_rivers; i++) {
			if (rivers[j].n_user == rivers[i].n_user) {
				sprintf(error_string,"Two rivers have the same identifying number. Sequence number %d %s and sequence number %d %s.", j, rivers[j].description, i, rivers[i].description);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			}
		}
	}
	return(return_value);
}
/* ---------------------------------------------------------------------- */
int build_rivers(void)
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
	p = malloc((size_t) sizeof (gpc_vertex));
	if (p == NULL) malloc_error();

	if (count_rivers <= 0) { 
		free_check_null(p);
		return(OK);
	}
	for (j = 0; j < count_rivers; j++) {
		if (rivers[j].new_def == FALSE) continue;
		rivers[j].new_def = FALSE;
		river_ptr = &(rivers[j]);
		if (river_ptr->count_points < 2) {
			sprintf(error_string,"River must have at least 2 points. River %d %s.", river_ptr->n_user, river_ptr->description);
			error_msg(error_string, CONTINUE);
			input_error++;
			continue;
		}
		count_points = river_ptr->count_points;
		/*
		 *  Build river topology
		 */
		p = realloc(p, (size_t) river_ptr->count_points * sizeof (gpc_vertex));
		if (p == NULL) malloc_error();
		for (i=0; i < river_ptr->count_points; i++) {
			p[i].x = river_ptr->points[i].x;
			p[i].y = river_ptr->points[i].y;
		}
		/*
		 *  Trapezoid points for last River Point
		 */
		n = count_points - 1;
		phantom.x = p[n].x + (p[n].x - p[n - 1].x);
		phantom.y = p[n].y + (p[n].y - p[n - 1].y);
		trapezoid_points(p[n], phantom, &(river_ptr->points[n]), river_ptr->points[n].width);
		river_ptr->points[n].vertex[2].x = river_ptr->points[n].vertex[1].x;
		river_ptr->points[n].vertex[2].y = river_ptr->points[n].vertex[1].y;
		river_ptr->points[n].vertex[3].x = river_ptr->points[n].vertex[0].x;
		river_ptr->points[n].vertex[3].y = river_ptr->points[n].vertex[0].y;
		/*
		 *  Trapezoid points for River Points
		 */
		for (i = 0; i < count_points - 1; i++) {
			trapezoid_points(p[i], p[i+1], &(river_ptr->points[i]), river_ptr->points[i+1].width);
		}
		/*
		 *  Union of polygon and gap with next polygon
		 */
		for (i = 0; i < count_points - 2; i++) {
			river_ptr->points[i].polygon = vertex_to_poly(river_ptr->points[i].vertex, 4);
			trapezoid = vertex_to_poly(river_ptr->points[i].vertex, 4);

			vertex[0].x = river_ptr->points[i].vertex[2].x;
			vertex[0].y = river_ptr->points[i].vertex[2].y;
			vertex[1].x = river_ptr->points[i].vertex[3].x;
			vertex[1].y = river_ptr->points[i].vertex[3].y;
			vertex[2].x = river_ptr->points[i+1].vertex[0].x;
			vertex[2].y = river_ptr->points[i+1].vertex[0].y;
			vertex[3].x = river_ptr->points[i+1].vertex[1].x;
			vertex[3].y = river_ptr->points[i+1].vertex[1].y;
			gap_polygon = vertex_to_poly(vertex, 4);

			gpc_free_polygon(river_ptr->points[i].polygon);
			gpc_polygon_clip(GPC_UNION, trapezoid, gap_polygon, river_ptr->points[i].polygon);

			gpc_free_polygon(trapezoid);
			free(trapezoid);
			gpc_free_polygon(gap_polygon);
			free(gap_polygon);


		}
		/*
		 *  Last polygon
		 */
		river_ptr->points[i].polygon = vertex_to_poly(river_ptr->points[i].vertex, 4);
	}
	/*
	 *   Free work space
	 */
	free_check_null(p);
	return(return_code);
}
/* ---------------------------------------------------------------------- */
int update_rivers(void)
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
	if (count_rivers <= 0) return(OK);
	for (j = 0; j < count_rivers; j++) {
		if (rivers[j].update == FALSE) continue;
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
		while (i < river_ptr->count_points) {
			if (river_ptr->points[i].head_defined == TRUE) {
				length = 0;
				head1 = river_ptr->points[i].current_head;
			} else {
				k = i;
				while (river_ptr->points[k].head_defined == FALSE) {
					length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
					k++;
				}
				length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
				total_length = length;
				head2 = river_ptr->points[k].current_head;
				if (total_length == 0) total_length = 1.0;
				length = 0;
				for ( ; i < k; i++) {
					length += river_distance(&(river_ptr->points[i]), &(river_ptr->points[i-1]));
					river_ptr->points[i].current_head = head1 + length/total_length*(head2 - head1);
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
		while (i < river_ptr->count_points) {
			if (river_ptr->points[i].solution_defined == TRUE) {
				length = 0;
				i1 = river_ptr->points[i].current_solution;
				river_ptr->points[i].solution1 = river_ptr->points[i].current_solution;
				river_ptr->points[i].solution2 = -1;
				river_ptr->points[i].f1 = 1.0;
				i++;
			} else {
				k = i;
				while (river_ptr->points[k].solution_defined == FALSE) {
					length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
					k++;
				}
				i2 = k;
				length += river_distance(&(river_ptr->points[k]), &(river_ptr->points[k-1]));
				total_length = length;
				i2 = river_ptr->points[k].current_solution;
				if (total_length == 0) total_length = 1.0;
				length = 0;
				for ( ; i < k; i++) {
					length += river_distance(&(river_ptr->points[i]), &(river_ptr->points[i-1]));
					river_ptr->points[i].solution1 = i1;
					river_ptr->points[i].solution2 = i2;
					river_ptr->points[i].f1 = 1 - length/total_length;
				}
			}
		}
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_rivers(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Check river data 
 */
	int i, j, k, count_points;
	River *river_ptr;

	if (count_rivers <= 0) return(OK);
	for (j = 0; j < count_rivers; j++) {
		if (rivers[j].new_def != FALSE) continue;
		river_ptr = &(rivers[j]);
		count_points = river_ptr->count_points;
		/*
		 *   Write points for river
		 */
		output_msg(OUTPUT_ECHO, "@type xy\n");
		output_msg(OUTPUT_ECHO, "#river segments %d %s\n", river_ptr->n_user, river_ptr->description);
		for (i = 0; i < river_ptr->count_points; i++) {
			output_msg(OUTPUT_ECHO,"\t%15e\t%15e\n", river_ptr->points[i].x, river_ptr->points[i].y);
		}
		output_msg(OUTPUT_ECHO, "&\n");
		/*
		 *   Write polygons for river
		 */
		output_msg(OUTPUT_ECHO, "@type xy\n");
		output_msg(OUTPUT_ECHO, "#river polygons %d %s\n", river_ptr->n_user, river_ptr->description);
		for (i = 0; i < river_ptr->count_points - 1; i++) {
			for (k = 0; k < 4; k++) {
				output_msg(OUTPUT_ECHO,"\t%15e\t%15e\n", river_ptr->points[i].vertex[k].x, river_ptr->points[i].vertex[k].y);
			}
			output_msg(OUTPUT_ECHO,"\t%15e\t%15e\n", river_ptr->points[i].vertex[0].x, river_ptr->points[i].vertex[0].y);
		}
		output_msg(OUTPUT_ECHO, "&\n");
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
double river_distance(River_Point *river_ptr1, River_Point *river_ptr2)
/* ---------------------------------------------------------------------- */
{
/*
 *   Calculate distance between two points
 */
	double x, y;

	x = river_ptr2->x - river_ptr1->x;
	y = river_ptr2->y - river_ptr1->y;
	return(sqrt(x*x + y*y));
}

/* ---------------------------------------------------------------------- */
int check_quad(gpc_vertex *v)
/* ---------------------------------------------------------------------- */
{
	double angle, angle1;

	angle = 0;
	/*
	 *   absolute angle of segments
	 */
	angle1 = angle_between_segments(v[0], v[1], v[2]);
#ifdef DEBUG
	output_msg(OUTPUT_STDERR, "Angle1 %g\n", angle1);
#endif
	if (angle1 > PI) angle1 = 2*PI - angle1;
	angle += angle1;
	angle1 = angle_between_segments(v[1], v[2], v[3]);
#ifdef DEBUG
	output_msg(OUTPUT_STDERR, "Angle2 %g\n", angle1);
#endif
	if (angle1 > PI) angle1 = 2*PI - angle1;
	angle += angle1;
	angle1 = angle_between_segments(v[2], v[3], v[0]);
#ifdef DEBUG
	output_msg(OUTPUT_STDERR, "Angle3 %g\n", angle1);
#endif
	if (angle1 > PI) angle1 = 2*PI - angle1;
	angle += angle1;
	angle1 = angle_between_segments(v[3], v[0], v[1]);
#ifdef DEBUG
	output_msg(OUTPUT_STDERR, "Angle4 %g\n", angle1);
#endif
	if (angle1 > PI) angle1 = 2*PI - angle1;
	angle += angle1;
#ifdef DEBUG
	output_msg(OUTPUT_STDERR, "Angle %g\n", angle);
#endif
	if (angle + 1e-8 < 2*PI) return(ERROR);

	return(OK);
}

/* ---------------------------------------------------------------------- */
double angle_between_segments(gpc_vertex p0, gpc_vertex p1, gpc_vertex p2)
/* ---------------------------------------------------------------------- */
{
	double angle1, angle2, angle;
	/*
	 *   absolute angle of segments
	 */
	angle1 = angle_of_segment(p0, p1) + PI;
	if (angle1 > 2*PI) {
		angle1 -= 2*PI;
	}
	angle2 = angle_of_segment(p1, p2);
	/*
	 *   absolute angle of bisector
	 */
	angle = angle2 - angle1;
	if (angle < 0) {
		angle += 2*PI;
	}
	return(angle);
}
/* ---------------------------------------------------------------------- */
double angle_of_segment(gpc_vertex p0, gpc_vertex p1)
/* ---------------------------------------------------------------------- */
{
	gpc_vertex points[2];
	double angle;
	/*
	 *   Make copy of data and translate
	 */
	points[1].x = p1.x - p0.x;
	points[1].y = p1.y - p0.y;
	/*
	 *   absolute angle of segments
	 */
	angle = atan2(points[1].y, points[1].x);
	if (angle < 0) {
		angle = angle + 2*PI;
	}

	return(angle);
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
int bisector_points(gpc_vertex p0, gpc_vertex p1, gpc_vertex p2, River_Point *r_ptr)
/* ---------------------------------------------------------------------- */
{
	double width;
	double x, y;
	double angle1, angle2, angle;

	width = r_ptr->width;
	/*
	 *   absolute angle of segments
	 */
	angle1 = angle_of_segment(p0, p1) + PI;
	if (angle1 > 2*PI) {
		angle1 -= 2*PI;
	}
	angle2 = angle_of_segment(p1, p2);
	/*
	 *   absolute angle of bisector
	 */
	angle = (angle2 + angle1) / 2;
	/*
	 *   position of points
	 */
	r_ptr->right.x = cos(angle) * width / 2;
	r_ptr->right.y = sin(angle) * width / 2;
	r_ptr->left.x = -cos(angle) * width / 2;
	r_ptr->left.y = -sin(angle) * width / 2;
	/*
	 *   translate 
	 */
	r_ptr->right.x += p1.x;
	r_ptr->right.y += p1.y;
	r_ptr->left.x += p1.x;
	r_ptr->left.y += p1.y;
	/*
	 *   determine side, order is right then left
	 */
	angle1 = angle_between_segments(p0, p1, p2);
	angle2 = angle_between_segments(p0, p1, r_ptr->right);
	/*
	 *   Switch left and right if necessary
	 */
	if (angle2 > angle1) {
		x = r_ptr->right.x;
		y = r_ptr->right.y;
		r_ptr->right.x = r_ptr->left.x;
		r_ptr->right.y = r_ptr->left.y;
		r_ptr->left.x = x;
		r_ptr->left.y = y;
	}
	return(OK);
}
#endif
/* ---------------------------------------------------------------------- */
int trapezoid_points(gpc_vertex p0, gpc_vertex p1, River_Point *r_ptr, double width1)
/* ---------------------------------------------------------------------- */
{
	double width0;
	double a, b;
	double x, y;

	width0 = r_ptr->width;
	/*
	 *   Translate to origin
	 */
	x = p1.x - p0.x;
	y = p1.y - p0.y;
	/*
	 *    
	 */
	if (x != 0 || y != 0) {
		a = x/sqrt(x*x + y*y);
		b = y/sqrt(x*x + y*y);
	} else {
		a = 0;
		b = 0;
	}
	/*
	 *   position of points
	 */
#ifdef SKIP
	r_ptr->right.x = p0.x + b * width / 2;
	r_ptr->right.y = p0.y - a * width / 2;
	r_ptr->left.x  = p0.x - b * width / 2;
	r_ptr->left.y  = p0.y + a * width / 2;
#endif
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

	return(OK);
}
/* ---------------------------------------------------------------------- */
int interpolate(River_Polygon *river_polygon_ptr)
/* ---------------------------------------------------------------------- */
{
	River_Point *p0_ptr, *p1_ptr;
	gpc_polygon *poly, *slice;
	gpc_vertex vertex[3], centroid, c3;
	double a2, Areasum2;
	double w0, w1;
	int i, j;
	double x0, y0, x1, y1, x2, y2, xn, yn, zn, dist;

	p0_ptr = &(rivers[river_polygon_ptr->river_number].points[river_polygon_ptr->point_number]);
	p1_ptr = &(rivers[river_polygon_ptr->river_number].points[river_polygon_ptr->point_number + 1]);
	poly = river_polygon_ptr->poly;
	/*
	 *   find centroid of polygon
	 */
	Areasum2 = 0.0;
	for (i = 0; i < poly->num_contours; i++) {
#ifdef SKIP
		if (i > 0) {
			error_msg("Two contours in polygon", CONTINUE);
			continue;
		}
#endif
		vertex[0].x = poly->contour[i].vertex[0].x;
		vertex[0].y = poly->contour[i].vertex[0].y;
		centroid.x = 0;
		centroid.y = 0;
		for (j = 1; j < poly->contour[i].num_vertices-1; j++) {
			Centroid3(poly->contour[i].vertex[0], poly->contour[i].vertex[j], poly->contour[i].vertex[j + 1], &c3);
			vertex[1].x = poly->contour[i].vertex[j].x;
			vertex[1].y = poly->contour[i].vertex[j].y;
			vertex[2].x = poly->contour[i].vertex[j+1].x;
			vertex[2].y = poly->contour[i].vertex[j+1].y;
			slice = vertex_to_poly(vertex, 3);
			a2 = 2*gpc_polygon_area(slice);
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
	x1 = p0_ptr->x;
	y1 = p0_ptr->y;
	x2 = p1_ptr->x;
	y2 = p1_ptr->y;
	/* distance from centroid to line is */
	line_seg_point_near_3d ( x1, y1, 0, 
				 x2, y2, 0, 
				 x0, y0, 0,
				 &xn, &yn, &zn, &dist, &w1 );

	/*
	 *   Calculate weighting factors for River_Point 0 and 1
	 */
	w0 = 1 - w1;
	/*
	 *   Put weighted values in River_Polygon
	 */
	river_polygon_ptr->w = w0;
	/*
	 *  Debug print
	 */
#ifdef DEBUG
	output_msg(OUTPUT_STDERR,"@type xy\n");
	for (i = 0; i < poly->num_contours; i++) {
		if (i > 0) {
			output_msg(OUTPUT_STDERR,"#   Contour %d\n", i);
#ifdef SKIP
			continue;
#endif
		}
		for (j = 0; j < poly->contour[0].num_vertices; j++) {
			output_msg(OUTPUT_STDERR,"\t%g\t%g\t%d\n", poly->contour[i].vertex[j].x, poly->contour[i].vertex[j].y, j);
		}
		output_msg(OUTPUT_STDERR,"\t%g\t%g\t%d\n", poly->contour[i].vertex[0].x, poly->contour[i].vertex[0].y, j);
	}
	output_msg(OUTPUT_STDERR,"\t%g\t%g\n", centroid.x, centroid.y);
	output_msg(OUTPUT_STDERR,"&\n");
#endif
	return(OK);
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
int interpolate(River_Polygon *river_polygon_ptr)
/* ---------------------------------------------------------------------- */
{
	River_Point *p0_ptr, *p1_ptr;
	gpc_polygon *poly;
	double x1, x2, x3, x4, x7;
	double y1, y2, y3, y4, y7;
	double a, b, c;
	double f, f1, q;
	double w0, w1;
	double sign;
	int n, i, j;
	f = -99.;
	f1 = -99.;

	p0_ptr = &(rivers[river_polygon_ptr->river_number].points[river_polygon_ptr->point_number]);
	p1_ptr = &(rivers[river_polygon_ptr->river_number].points[river_polygon_ptr->point_number + 1]);
	poly = river_polygon_ptr->poly;
	/*
	 *   find average xy in polygon
	 */
	x7 = 0;
	y7=0;
	n = 0;
	for (i = 0; i < poly->num_contours; i++) {
		n += poly->contour[i].num_vertices;
	}
	for (i = 0; i < poly->num_contours; i++) {
		for (j = 0; j < poly->contour[i].num_vertices; j ++) {
			x7 += poly->contour[i].vertex[j].x / n;
			y7 += poly->contour[i].vertex[j].y / n;
		}
	}
	/*
	 * solve quadratic for fraction of quadrilateral
	 * such that the line passes through the target point
	 */
	x1 = p0_ptr->vertex[0].x;
	x2 = p0_ptr->vertex[1].x;
	x3 = p0_ptr->vertex[2].x;
	x4 = p0_ptr->vertex[3].x;
	y1 = p0_ptr->vertex[0].y;
	y2 = p0_ptr->vertex[1].y;
	y3 = p0_ptr->vertex[2].y;
	y4 = p0_ptr->vertex[3].y;
	river_polygon_ptr->x = x7;
	river_polygon_ptr->y = y7;

	/*  f-square factor */
	a = -x2*y3 + x1*y3 + x2*y4 - x1*y4 + x3*y2 - x3*y1 - x4*y2 + x4*y1;
	/*  f factor */
	b = (-x3 + x4 + x2 - x1)*y7 + (-y4 - y2 + y1 + y3)*x7 - x2*y4 - x1*y3 + 2*x1*y4 + x4*y2 + x3*y1 - 2*x4*y1;
	/*  constant */
	c = (-x4 + x1)*y7 + (y4 - y1)*x7 - x1*y4 + x4*y1;
	/*  solve for f */
	if (fabs(a) > 1e-10) {
		sign = 1;
		if (b < 0) sign = -1;
		q = -0.5*(b + sign*sqrt(b*b - 4*a*c));
		f = q / a;
		if (q != 0) {
			f1 = c / q;
		}
	} else if (b != 0) {
		f = -c/b;
	} else {
		error_msg("Failed in quadratic formula", STOP);
	}
#ifdef DEBUG
	output_msg(OUTPUT_STDERR, "# f value: %7.3f\tf1 value: %7.3f\n", f, f1);
#endif
	/*
	 *   Calculate weighting factors for River_Point 0 and 1
	 */
	if (f >= 0 && f <= 1.) {
		w0 = 1 - f;
		w1 = f;
	} else if (f1 >= 0 && f1 <= 1.) {
		w0 = 1 - f1;
		w1 = f1;
	} else {
		output_msg(OUTPUT_STDERR, "What happened in interpolate?\n");
		w0 = .5;
		w1 = .5;
	}
	/*
	 *   Put weighted values in River_Polygon
	 */
	river_polygon_ptr->w = w0;
	return(OK);
}
#endif
/* ---------------------------------------------------------------------- */
double PolygonArea(polygon, N)
/* ---------------------------------------------------------------------- */
gpc_vertex *polygon;
int N;
{
   int i,j;
   double area = 0;

   for (i=0;i<N;i++) {
      j = (i + 1) % N;
      area += polygon[i].x * polygon[j].y;
      area -= polygon[i].y * polygon[j].x;
   }

   area /= 2;
   return(area < 0 ? -area : area);
}
/* ---------------------------------------------------------------------- */
double gpc_polygon_area(gpc_polygon *poly)
/* ---------------------------------------------------------------------- */
{
   int i,j, k, N;
   double area1;
   double area = 0;

   for (k = 0; k < poly->num_contours; k++) {
	   area1 = 0;
	   N = poly->contour[k].num_vertices;
	   for (i=0; i < poly->contour[k].num_vertices; i++) {
		   j = (i + 1) % N;
		   area1 += poly->contour[k].vertex[i].x * poly->contour[k].vertex[j].y;
		   area1 -= poly->contour[k].vertex[i].y * poly->contour[k].vertex[j].x;
	   }
	   area += area1 / 2;
   }
   return(area < 0 ? -area : area);
}
/* ---------------------------------------------------------------------- */
gpc_polygon *gpc_polygon_duplicate(gpc_polygon *in_poly)
/* ---------------------------------------------------------------------- */
{
	int i,k;
	gpc_polygon *out_poly = NULL;

	/*
	 *   Malloc space and initialize
	 */
	out_poly = malloc ((size_t) sizeof(gpc_polygon));
	if (out_poly == NULL) malloc_error();

	out_poly->num_contours = in_poly->num_contours;
	out_poly->contour = NULL;
	if (out_poly->num_contours == 0) return(out_poly);
	/*
	 *   Malloc contours
	 */
	out_poly->contour = malloc ((size_t) (in_poly->num_contours * sizeof(gpc_vertex_list)));
	if (out_poly->contour == NULL) malloc_error();
	/*
	 *   Copy each contour
	 */
	for (k = 0; k < in_poly->num_contours; k++) {
		out_poly->contour[k].num_vertices = in_poly->contour[k].num_vertices;
		out_poly->contour[k].vertex = NULL;
		if (out_poly->contour[k].num_vertices == 0) continue;
		out_poly->contour[k].vertex = malloc((size_t) in_poly->contour[k].num_vertices * sizeof(gpc_vertex));
		for (i=0; i < out_poly->contour[k].num_vertices; i++) {
			out_poly->contour[k].vertex[i].x = in_poly->contour[k].vertex[i].x;
			out_poly->contour[k].vertex[i].y = in_poly->contour[k].vertex[i].y;

		}
	}
	return(out_poly);
}
/* ---------------------------------------------------------------------- */
void gpc_polygon_write(gpc_polygon *p)
/* ---------------------------------------------------------------------- */
{
	int c, v;
	
	/*	fprintf(echo_file, "%d\n", p->num_contours); */
	for (c= 0; c < p->num_contours; c++) {
		/*		fprintf(echo_file, "%d\n", p->contour[c].num_vertices); */
		output_msg(OUTPUT_ECHO,"@type xy\n");
		for (v= 0; v < p->contour[c].num_vertices; v++) {
			output_msg(OUTPUT_ECHO, "\t%e\t %e\n",
				p->contour[c].vertex[v].x,
				p->contour[c].vertex[v].y);
		}
		output_msg(OUTPUT_ECHO, "\t%e\t %e\n",
			p->contour[c].vertex[0].x,
			p->contour[c].vertex[0].y);
		output_msg(OUTPUT_ECHO,"&\n");
	}
}
/* ---------------------------------------------------------------------- */
gpc_polygon *vertex_to_poly(gpc_vertex *v, int n)
/* ---------------------------------------------------------------------- */
{
	gpc_polygon *poly_ptr;
	int i;
	gpc_vertex *p;

	poly_ptr =  malloc((size_t) sizeof(gpc_polygon));
	if (poly_ptr == NULL) malloc_error();
	/*
	 *   gpc_polygon for river polygon
	 */
	poly_ptr->contour = malloc((size_t) sizeof(gpc_vertex_list));
	if (poly_ptr->contour == NULL) malloc_error();
	p = malloc((size_t) n * sizeof (gpc_vertex));
	if (p == NULL) malloc_error();
	poly_ptr->contour[0].vertex = p;
	poly_ptr->contour[0].num_vertices = n;
	poly_ptr->num_contours = 1;
	/*
	 *   gpc_vertex list for cell boundary
	 */
	for (i = 0; i < n; i++) {
		p[i].x = v[i].x;
		p[i].y = v[i].y;
	}
	return(poly_ptr);
}
/*
        Written by Joseph O'Rourke
        orourke@cs.smith.edu
        October 27, 1995

        Computes the centroid (center of gravity) of an arbitrary
        simple polygon via a weighted sum of signed triangle areas,
        weighted by the centroid of each triangle.
        Reads x,y coordinates from stdin.  
        NB: Assumes points are entered in ccw order!  
        E.g., input for square:
                0       0
                10      0
                10      10
                0       10
        This solves Exercise 12, p.47, of my text,
        Computational Geometry in C.  See the book for an explanation
        of why this works. Follow links from
                http://cs.smith.edu/~orourke/

*/
#ifdef SKIP

#define DIM     2               /* Dimension of points */
typedef int     tPointi[DIM];   /* type integer point */
typedef double  tPointd[DIM];   /* type double point */

#define PMAX    1000            /* Max # of pts in polygon */
typedef tPointi tPolygoni[PMAX];/* type integer polygon */

int     Area2( tPointi a, tPointi b, tPointi c );
void    FindCG( int n, tPolygoni P, tPointd CG );
int     ReadPoints( tPolygoni P );
void    Centroid3( tPointi p1, tPointi p2, tPointi p3, tPointi c );
void    PrintPoint( tPointd p );


/* 
        Returns twice the signed area of the triangle determined by a,b,c,
        positive if a,b,c are oriented ccw, and negative if cw.
*/
int     Area2( tPointi a, tPointi b, tPointi c )
{
        return
                (b[0] - a[0]) * (c[1] - a[1]) -
                (c[0] - a[0]) * (b[1] - a[1]);
}

/*      
        Returns the cg in CG.  Computes the weighted sum of
        each triangle's area times its centroid.  Twice area
        and three times centroid is used to avoid division
        until the last moment.
*/
void     FindCG( int n, tPolygoni P, tPointd CG)
{
        int     i;
        double  A2, Areasum2 = 0;        /* Partial area sum */    
        tPointi Cent3;

        CG[0] = 0;
        CG[1] = 0;
        for (i = 1; i < n-1; i++) {
                Centroid3( P[0], P[i], P[i+1], Cent3 );
                A2 =  Area2( P[0], P[i], P[i+1]);
                CG[0] += A2 * Cent3[0];
                CG[1] += A2 * Cent3[1];
                Areasum2 += A2;
              }
        CG[0] /= 3 * Areasum2;
        CG[1] /= 3 * Areasum2;
        return;
}
#endif
/*
        Returns three times the centroid.  The factor of 3 is
        left in to permit division to be avoided until later.
*/
void    Centroid3( gpc_vertex p1, gpc_vertex p2, gpc_vertex p3, gpc_vertex *c_ptr )
{
        c_ptr->x = p1.x + p2.x + p3.x;
        c_ptr->y = p1.y + p2.y + p3.y;
        return;
}
#ifdef SKIP
void    Centroid3( tPointi p1, tPointi p2, tPointi p3, tPointi c )
{
        c[0] = p1[0] + p2[0] + p3[0];
        c[1] = p1[1] + p2[1] + p3[1];
        return;
}
#endif

/**********************************************************************/

void line_seg_point_near_3d ( double x1, double y1, double z1, 
  double x2, double y2, double z2, double x, double y, double z,
  double *xn, double *yn, double *zn, double *dist, double *t )

/**********************************************************************/

/*
  Purpose:

    LINE_SEG_POINT_NEAR_3D finds the point on a line segment nearest a point in 3D.

  Modified:

    17 April 1999

  Author:

    John Burkardt

  Parameters:

    Input, double X1, Y1, Z1, X2, Y2, Z2, the two endpoints of the line segment.

    (X1,Y1,Z1) should generally be different from (X2,Y2,Z2), but
    if they are equal, the program will still compute a meaningful
    result.

    Input, double X, Y, Z, the point whose nearest neighbor
    on the line segment is to be determined.

    Output, double *XN, *YN, *ZN, the point on the line segment which is
    nearest the point (X,Y,Z).
 
    Output, double *DIST, the distance from the point to the nearest point
    on the line segment.

    Output, double *T, the relative position of the nearest point
    (XN,YN,ZN) to the defining points (X1,Y1,Z1) and (X2,Y2,Z2).

      (XN,YN,ZN) = (1-T)*(X1,Y1,Z1) + T*(X2,Y2,Z2).

    T will always be between 0 and 1.

*/
{
  double bot;

  if ( x1 == x2 && y1 == y2 && z1 == z2 ) {
    *t = 0.0;
    *xn = x1;
    *yn = y1;
    *zn = z1;
  }
  else {

    bot = 
        ( x1 - x2 ) * ( x1 - x2 )
      + ( y1 - y2 ) * ( y1 - y2 )
      + ( z1 - z2 ) * ( z1 - z2 );

    *t = (
      + ( x1 - x ) * ( x1 - x2 )
      + ( y1 - y ) * ( y1 - y2 )
      + ( z1 - z ) * ( z1 - z2 ) ) / bot;

    if ( *t < 0.0 ) {
      *t = 0.0;
      *xn = x1;
      *yn = y1;
      *zn = z1;
    }
    else if ( *t > 1.0 ) {
      *t = 1.0;
      *xn = x2;
      *yn = y2;
      *zn = z2;
    }
    else {
      *xn = x1 + *t * ( x2 - x1 );
      *yn = y1 + *t * ( y2 - y1 );
      *zn = z1 + *t * ( z2 - z1 );
    }
  }
  *dist = sqrt ( 
      ( *xn - x ) * ( *xn - x ) 
    + ( *yn - y ) * ( *yn - y ) 
    + ( *zn - z ) * ( *zn - z ) );

  return;
}
