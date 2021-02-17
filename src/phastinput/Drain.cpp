#include "Drain.h"
#define EXTERNAL extern
#include "hstinpt.h"
#include "message.h"
static int interpolate_drain(River_Polygon * drain_polygon_ptr);

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif


Drain::Drain(void)
{
	// Data
	this->n_user = -99;
	this->coordinate_system = PHAST_Transform::GRID;
	this->z_coordinate_system = PHAST_Transform::GRID;
}

Drain::~Drain(void)
{
	for (std::vector < River_Point >::iterator it = this->points.begin();
		 it != this->points.end(); it++)
	{
		if (it->polygon != NULL)
		{
			gpc_free_polygon(it->polygon);
			free_check_null(it->polygon);
		}
	}
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
int
tidy_drains(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *   Check drain data 
	 */
	int i, j, k, return_value;
	double length, total_length;
	Drain *drain_ptr;
	int count_drains = drains.size();
	double x1, x2;
	return_value = OK;
	if (count_drains <= 0)
		return (OK);
	if (simulation > 0)
		return (OK);
	for (j = 0; j < count_drains; j++)
	{
		drain_ptr = drains[j];
		/*
		 *  Logical checks on drain
		 */
		if (drain_ptr->points.size() < 2)
		{
			sprintf(error_string,
					"Drain must have at least 2 points. Drain %d %s.",
					drain_ptr->n_user, drain_ptr->description.c_str());
			error_msg(error_string, CONTINUE);
			return_value = FALSE;
			input_error++;
		}
		/*
		 *   Check drain data
		 */
		for (i = 0; i < (int) drain_ptr->points.size(); i++)
		{
			if (drain_ptr->points[i].x_defined == FALSE
				|| drain_ptr->points[i].y_defined == FALSE)
			{
				sprintf(error_string,
						"X or Y not defined for drain point %d of drain %d.",
						i + 1, j);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			}
		}

		/*
		 *   Check width data
		 */
		if (drain_ptr->points[0].width_defined == FALSE
			|| drain_ptr->points[drain_ptr->points.size() -
								 1].width_defined == FALSE)
		{
			sprintf(error_string,
					"Width must be defined at first and last drain point (1 and %d) of drain %d.",
					(int) drain_ptr->points.size(), j);
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
			while (i < (int) drain_ptr->points.size())
			{
				if (drain_ptr->points[i].width_defined == TRUE)
				{
					length = 0;
					x1 = drain_ptr->points[i].width;
				}
				else
				{
					k = i;
					while (drain_ptr->points[k].width_defined == FALSE)
					{
						length +=
							river_distance(&(drain_ptr->points[k]),
										   &(drain_ptr->points[k - 1]));
						k++;
					}
					length +=
						river_distance(&(drain_ptr->points[k]),
									   &(drain_ptr->points[k - 1]));
					total_length = length;
					x2 = drain_ptr->points[k].width;
					if (total_length == 0)
						total_length = 1.0;
					length = 0;
					for (; i < k; i++)
					{
						length +=
							river_distance(&(drain_ptr->points[i]),
										   &(drain_ptr->points[i - 1]));
						drain_ptr->points[i].width =
							x1 + length / total_length * (x2 - x1);
					}
				}
				i++;
			}
		}
		/*
		 *   Check k data
		 */
		if (drain_ptr->points[0].k_defined == FALSE
			|| drain_ptr->points[drain_ptr->points.size() - 1].k_defined ==
			FALSE)
		{
			sprintf(error_string,
					"Hydraulic conductivity must be defined at first and last drain point (1 and %d) of drain %d.",
					(int) drain_ptr->points.size(), j);
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
			while (i < (int) drain_ptr->points.size())
			{
				if (drain_ptr->points[i].k_defined == TRUE)
				{
					length = 0;
					x1 = drain_ptr->points[i].k;
				}
				else
				{
					k = i;
					while (drain_ptr->points[k].k_defined == FALSE)
					{
						length +=
							river_distance(&(drain_ptr->points[k]),
										   &(drain_ptr->points[k - 1]));
						k++;
					}
					length +=
						river_distance(&(drain_ptr->points[k]),
									   &(drain_ptr->points[k - 1]));
					total_length = length;
					x2 = drain_ptr->points[k].k;
					if (total_length == 0)
						total_length = 1.0;
					length = 0;
					for (; i < k; i++)
					{
						length +=
							river_distance(&(drain_ptr->points[i]),
										   &(drain_ptr->points[i - 1]));
						drain_ptr->points[i].k =
							x1 + length / total_length * (x2 - x1);
					}
				}
				i++;
			}
		}
		/*
		 *   Check thickness data
		 */
		if (drain_ptr->points[0].thickness_defined == FALSE
			|| drain_ptr->points[drain_ptr->points.size() -
								 1].thickness_defined == FALSE)
		{
			sprintf(error_string,
					"Thickness must be defined at first and last drain point (1 and %d) of drain %d.",
					(int) drain_ptr->points.size(), j);
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
			while (i < (int) drain_ptr->points.size())
			{
				if (drain_ptr->points[i].thickness_defined == TRUE)
				{
					length = 0;
					x1 = drain_ptr->points[i].thickness;
				}
				else
				{
					k = i;
					while (drain_ptr->points[k].thickness_defined == FALSE)
					{
						length +=
							river_distance(&(drain_ptr->points[k]),
										   &(drain_ptr->points[k - 1]));
						k++;
					}
					length +=
						river_distance(&(drain_ptr->points[k]),
									   &(drain_ptr->points[k - 1]));
					total_length = length;
					x2 = drain_ptr->points[k].thickness;
					if (total_length == 0)
						total_length = 1.0;
					length = 0;
					for (; i < k; i++)
					{
						length +=
							river_distance(&(drain_ptr->points[i]),
										   &(drain_ptr->points[i - 1]));
						drain_ptr->points[i].thickness =
							x1 + length / total_length * (x2 - x1);
					}
				}
				i++;
			}
		}

		/* 
		 *   Check z data
		 */
		if (drain_ptr->points[0].z_defined == FALSE
			|| drain_ptr->points[drain_ptr->points.size() - 1].z_defined ==
			FALSE)
		{
			sprintf(error_string,
					"Drain elevation must be defined at first and last drain point (1 and %d) of drain %d.",
					(int) drain_ptr->points.size(), j);
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
			while (i < (int) drain_ptr->points.size())
			{
				if (drain_ptr->points[i].z_defined == TRUE)
				{
					length = 0;
					x1 = drain_ptr->points[i].z;
				}
				else
				{
					k = i;
					while (drain_ptr->points[k].z_defined == FALSE)
					{
						length +=
							river_distance(&(drain_ptr->points[k]),
										   &(drain_ptr->points[k - 1]));
						k++;
					}
					length +=
						river_distance(&(drain_ptr->points[k]),
									   &(drain_ptr->points[k - 1]));
					total_length = length;
					x2 = drain_ptr->points[k].z;
					if (total_length == 0)
						total_length = 1.0;
					length = 0;
					for (; i < k; i++)
					{
						length +=
							river_distance(&(drain_ptr->points[i]),
										   &(drain_ptr->points[i - 1]));
						drain_ptr->points[i].z =
							x1 + length / total_length * (x2 - x1);
					}
				}
				i++;
			}
		}
	}
	/*
	 * Convert coordinates if necessary
	 */
	for (j = 0; j < count_drains; j++)
	{
		drains[j]->Convert_coordinate_system(target_coordinate_system,
											 map_to_grid);
	}

	/*
	 *   Check for duplicate numbers
	 */
	for (j = 0; j < count_drains; j++)
	{
		for (i = j + 1; i < (int) drains.size(); i++)
		{
			if (drains[j]->n_user == drains[i]->n_user)
			{
				sprintf(error_string,
						"Two drains have the same identifying number. Sequence number %d %s and sequence number %d %s.",
						j, drains[j]->description.c_str(), i,
						drains[i]->description.c_str());
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
tidy_drains(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *   Check drain data 
	 */
	int return_value;
	size_t i, j, k;
	double length, total_length;
	Drain *drain_ptr;
	size_t count_drains = drains.size();
	double x1, x2;
	return_value = OK;
	if (count_drains <= 0)
		return (OK);
	if (simulation > 0)
		return (OK);
	for (j = 0; j < count_drains; j++)
	{
		drain_ptr = drains[j];
		/*
		 *  Logical checks on drain
		 */
		if (drain_ptr->points.size() < 2)
		{
			sprintf(error_string,
					"Drain must have at least 2 points. Drain %d %s.",
					drain_ptr->n_user, drain_ptr->description.c_str());
			error_msg(error_string, CONTINUE);
			return_value = FALSE;
			input_error++;
		}
		/*
		 *   Check drain data
		 */
		for (i = 0; i < drain_ptr->points.size(); i++)
		{
			if (drain_ptr->points[i].x_user_defined == FALSE
				|| drain_ptr->points[i].y_user_defined == FALSE)
			{
				sprintf(error_string,
						"X or Y not defined for drain point %d of drain %d.",
						(int) i + 1, (int) j);
				error_msg(error_string, CONTINUE);
				input_error++;
				return_value = FALSE;
			}
		}
		/*
		 *   Check width data
		 */
		if (drain_ptr->points[0].width_user_defined == FALSE
			|| drain_ptr->points[drain_ptr->points.size() -
								 1].width_user_defined == FALSE)
		{
			sprintf(error_string,
					"Width must be defined at first and last drain point (1 and %d) of drain %d.",
				(int) drain_ptr->points.size(), (int) j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		/*
		 *   Check k data
		 */
		if (drain_ptr->points[0].k_defined == FALSE
			|| drain_ptr->points[drain_ptr->points.size() - 1].k_defined ==
			FALSE)
		{
			sprintf(error_string,
					"Hydraulic conductivity must be defined at first and last drain point (1 and %d) of drain %d.",
					(int) drain_ptr->points.size(), (int) j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		/*
		 *   Check thickness data
		 */
		if (drain_ptr->points[0].thickness_defined == FALSE
			|| drain_ptr->points[drain_ptr->points.size() -
								 1].thickness_defined == FALSE)
		{
			sprintf(error_string,
					"Thickness must be defined at first and last drain point (1 and %d) of drain %d.",
					(int) drain_ptr->points.size(), (int) j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
		/* 
		 *   Check z data
		 */
		if (drain_ptr->points[0].z_user_defined == FALSE
			|| drain_ptr->points[drain_ptr->points.size() - 1].z_user_defined ==
			FALSE)
		{
			sprintf(error_string,
					"Drain elevation must be defined at first and last drain point (1 and %d) of drain %d.",
					(int) drain_ptr->points.size(), (int) j);
			error_msg(error_string, CONTINUE);
			input_error++;
			return_value = FALSE;
		}
	}

	if (return_value == FALSE) return(FALSE);

	/* continue processing drains */

	for (j = 0; j < count_drains; j++)
	{
		drain_ptr = drains[j];



		/* calculate grid x, y, z in grid units */

		drains[j]->Convert_xy_to_grid(map_to_grid);
		drains[j]->Convert_z_to_grid(map_to_grid);
		drains[j]->Convert_width_to_grid();

		/*
		*   Interpolate width data
		*/
		i = 0;
		length = 0;
		x1 = 0;
		while (i < drain_ptr->points.size())
		{
			if (drain_ptr->points[i].width_user_defined == TRUE)
			{
				length = 0;
				x1 = drain_ptr->points[i].width_grid;
			}
			else
			{
				k = i;
				while (drain_ptr->points[k].width_user_defined == FALSE)
				{
					length +=
						river_distance_grid(&(drain_ptr->points[k]),
						&(drain_ptr->points[k - 1]));
					k++;
				}
				length +=
					river_distance_grid(&(drain_ptr->points[k]),
					&(drain_ptr->points[k - 1]));
				total_length = length;
				x2 = drain_ptr->points[k].width_grid;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(drain_ptr->points[i]),
						&(drain_ptr->points[i - 1]));
					drain_ptr->points[i].width_grid =
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
		while (i < drain_ptr->points.size())
		{
			if (drain_ptr->points[i].k_defined == TRUE)
			{
				length = 0;
				x1 = drain_ptr->points[i].k;
			}
			else
			{
				k = i;
				while (drain_ptr->points[k].k_defined == FALSE)
				{
					length +=
						river_distance_grid(&(drain_ptr->points[k]),
						&(drain_ptr->points[k - 1]));
					k++;
				}
				length +=
					river_distance_grid(&(drain_ptr->points[k]),
					&(drain_ptr->points[k - 1]));
				total_length = length;
				x2 = drain_ptr->points[k].k;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(drain_ptr->points[i]),
						&(drain_ptr->points[i - 1]));
					drain_ptr->points[i].k =
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
		while (i < drain_ptr->points.size())
		{
			if (drain_ptr->points[i].thickness_defined == TRUE)
			{
				length = 0;
				x1 = drain_ptr->points[i].thickness;
			}
			else
			{
				k = i;
				while (drain_ptr->points[k].thickness_defined == FALSE)
				{
					length +=
						river_distance_grid(&(drain_ptr->points[k]),
						&(drain_ptr->points[k - 1]));
					k++;
				}
				length +=
					river_distance_grid(&(drain_ptr->points[k]),
					&(drain_ptr->points[k - 1]));
				total_length = length;
				x2 = drain_ptr->points[k].thickness;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(drain_ptr->points[i]),
						&(drain_ptr->points[i - 1]));
					drain_ptr->points[i].thickness =
						x1 + length / total_length * (x2 - x1);
				}
			}
			i++;
		}



		/*
		*   Interpolate z data
		*/
		i = 0;
		length = 0;
		x1 = 0;
		while (i < drain_ptr->points.size())
		{
			if (drain_ptr->points[i].z_user_defined == TRUE)
			{
				length = 0;
				x1 = drain_ptr->points[i].z_grid;
			}
			else
			{
				k = i;
				while (drain_ptr->points[k].z_user_defined == FALSE)
				{
					length +=
						river_distance_grid(&(drain_ptr->points[k]),
						&(drain_ptr->points[k - 1]));
					k++;
				}
				length +=
					river_distance_grid(&(drain_ptr->points[k]),
					&(drain_ptr->points[k - 1]));
				total_length = length;
				x2 = drain_ptr->points[k].z_grid;
				if (total_length == 0)
					total_length = 1.0;
				length = 0;
				for (; i < k; i++)
				{
					length +=
						river_distance_grid(&(drain_ptr->points[i]),
						&(drain_ptr->points[i - 1]));
					drain_ptr->points[i].z_grid =
						x1 + length / total_length * (x2 - x1);
				}
			}
			i++;
		}
	}

	/*
	 *   Check for duplicate numbers
	 */
	for (j = 0; j < count_drains; j++)
	{
		for (i = j + 1; i < drains.size(); i++)
		{
			if (drains[j]->n_user == drains[i]->n_user)
			{
				sprintf(error_string,
						"Two drains have the same identifying number. Sequence number %d %s and sequence number %d %s.",
						(int) j, drains[j]->description.c_str(), (int) i,
						drains[i]->description.c_str());
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
build_drains(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *   Check drain data 
	 */
	int return_code;
	size_t count_points, i, j, n;
	Drain *drain_ptr;
	gpc_vertex *p, phantom, vertex[4];
	gpc_polygon *trapezoid, *gap_polygon;

	return_code = OK;
	p = (gpc_vertex *) malloc((size_t) sizeof(gpc_vertex));
	if (p == NULL)
		malloc_error();

	size_t count_drains = drains.size();
	if (count_drains <= 0)
	{
		free_check_null(p);
		return (OK);
	}
	for (j = 0; j < count_drains; j++)
	{
		drain_ptr = drains[j];
		if (drain_ptr->points.size() < 2)
		{
			sprintf(error_string,
					"Drain must have at least 2 points. drain %d %s.",
					drain_ptr->n_user, drain_ptr->description.c_str());
			error_msg(error_string, CONTINUE);
			input_error++;
			continue;
		}
		count_points = drain_ptr->points.size();
		/*
		 *  Build drain topology
		 */
		p = (gpc_vertex *) realloc(p,
								   (size_t) (count_points *
											 sizeof(gpc_vertex)));
		if (p == NULL)
			malloc_error();

		for (i = 0; i < count_points; i++)
		{
			p[i].x = drain_ptr->points[i].x_grid;
			p[i].y = drain_ptr->points[i].y_grid;
			/*
			* Check for duplicate points
			*/
			if (i > 0 && p[i].x == p[i-1].x && p[i].y == p[i-1].y)
			{
				sprintf(error_string,
					"Duplicate drain points %d %d, drain %d %s.",
					(int) (i - 1), (int) i, drain_ptr->n_user, drain_ptr->description.c_str());
				warning_msg(error_string);

			}
		}
		/*
		 *  Trapezoid points for last drain Point
		 */
		n = count_points - 1;
		phantom.x = p[n].x + (p[n].x - p[n - 1].x);
		phantom.y = p[n].y + (p[n].y - p[n - 1].y);
		trapezoid_points(p[n], phantom, &(drain_ptr->points[n]),
						 drain_ptr->points[n].width_grid);
		drain_ptr->points[n].vertex[2].x = drain_ptr->points[n].vertex[1].x;
		drain_ptr->points[n].vertex[2].y = drain_ptr->points[n].vertex[1].y;
		drain_ptr->points[n].vertex[3].x = drain_ptr->points[n].vertex[0].x;
		drain_ptr->points[n].vertex[3].y = drain_ptr->points[n].vertex[0].y;
		/*
		 *  Trapezoid points for drain Points
		 */
		for (i = 0; i < count_points - 1; i++)
		{
			trapezoid_points(p[i], p[i + 1], &(drain_ptr->points[i]),
							 drain_ptr->points[i + 1].width_grid);
		}
		/*
		 *  Union of polygon and gap with next polygon
		 */
		for (i = 0; i < count_points - 2; i++)
		{
			drain_ptr->points[i].polygon =
				vertex_to_poly(drain_ptr->points[i].vertex, 4);
			trapezoid = vertex_to_poly(drain_ptr->points[i].vertex, 4);

			vertex[0].x = drain_ptr->points[i].vertex[2].x;
			vertex[0].y = drain_ptr->points[i].vertex[2].y;
			vertex[1].x = drain_ptr->points[i].vertex[3].x;
			vertex[1].y = drain_ptr->points[i].vertex[3].y;
			vertex[2].x = drain_ptr->points[i + 1].vertex[0].x;
			vertex[2].y = drain_ptr->points[i + 1].vertex[0].y;
			vertex[3].x = drain_ptr->points[i + 1].vertex[1].x;
			vertex[3].y = drain_ptr->points[i + 1].vertex[1].y;
			gap_polygon = vertex_to_poly(vertex, 4);

			gpc_free_polygon(drain_ptr->points[i].polygon);
			gpc_polygon_clip(GPC_UNION, trapezoid, gap_polygon,
							 drain_ptr->points[i].polygon);

			gpc_free_polygon(trapezoid);
			free(trapezoid);
			gpc_free_polygon(gap_polygon);
			free(gap_polygon);
		}
		/*
		 *  Last polygon
		 */
		drain_ptr->points[i].polygon =
			vertex_to_poly(drain_ptr->points[i].vertex, 4);
	}
	/*
	 *   Free work space
	 */
	free_check_null(p);
	return (return_code);
}

/* ---------------------------------------------------------------------- */
int
setup_drains(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *   Check drain data 
	 */
	int i, j, k, l, m, n;
	size_t count_points;
	Drain *drain_ptr;
	size_t count_drains = drains.size();
	gpc_vertex *p;
	gpc_polygon poly2;
	gpc_polygon *poly_ptr;
	gpc_polygon intersection;
	struct index_range *range_ptr;
	gpc_polygon_init(&poly2);
	gpc_polygon_init(&intersection);
	if (count_drains <= 0)
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
	 *   Go through each drain polygon
	 *   Intersect with cells
	 *   Save intersection in Cell structure
	 */
	for (l = 0; l < (int) count_drains; l++)
	{
		drain_ptr = drains[l];
		count_points = drain_ptr->points.size();
		/*
		 *  Go through drain polygons
		 */
		for (m = 0; m < (int) count_points - 1; m++)
		{
			poly_ptr = drain_ptr->points[m].polygon;
			if (poly_ptr->contour == NULL)
				continue;
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
					 *   Add to list
					 */
					/*
					   count_drain_polygons = cells[n].count_drain_polygons++;
					   cells[n].drain_polygons = (drain_Polygon *) realloc ( cells[n].drain_polygons, (size_t) (count_drain_polygons + 1) * sizeof (drain_Polygon));
					   if (cells[n].drain_polygons == NULL) malloc_error();
					 */

					/*
					 *   Save drain_Polygon for cell
					 */
					River_Polygon rpoly;
					rpoly.poly = gpc_polygon_duplicate(&intersection);
					rpoly.river_number = l;
					rpoly.point_number = m;
					cells[n].drain_polygons->push_back(rpoly);

					/*
					   cells[n].drain_polygons[count_drain_polygons].poly = gpc_polygon_duplicate(&intersection);
					   cells[n].drain_polygons[count_drain_polygons].drain_number = l;
					   cells[n].drain_polygons[count_drain_polygons].point_number = m;
					 */
					gpc_free_polygon(&intersection);
				}
			}
			free_check_null(range_ptr);
		}
	}
	/*
	 *    Remove duplicate areas from cell drain polygons
	 */
	/*
	   for (i = 0; i < count_cells; i++) {
	   if (cells[i].drain_polygons->size() <= 1) continue;
	   for (j = 0; j < (int) cells[i].drain_polygons->size() - 1; j++) {
	   for (k = j + 1; k < (int) cells[i].drain_polygons->size(); k++) {
	   gpc_polygon_clip(GPC_INT, cells[i].drain_polygons[k].poly, cells[i].drain_polygons[j]->poly, &intersection);
	   if (intersection.num_contours == 0) {
	   gpc_free_polygon(&intersection);
	   continue;
	   }
	   gpc_free_polygon(&intersection);
	   gpc_polygon_clip(GPC_DIFF, cells[i].drain_polygons[k].poly, cells[i].drain_polygons[j].poly, &intersection);             
	   gpc_free_polygon(cells[i].drain_polygons[k].poly);
	   free_check_null(cells[i].drain_polygons[k].poly);
	   cells[i].drain_polygons[k].poly = gpc_polygon_duplicate(&intersection);
	   gpc_free_polygon(&intersection);
	   }
	   }
	   }
	 */
	for (i = 0; i < count_cells; i++)
	{
		std::vector < River_Polygon >::iterator j_it =
			cells[i].drain_polygons->begin();
		std::vector < River_Polygon >::iterator k_it =
			cells[i].drain_polygons->begin();
		if (cells[i].drain_polygons->size() <= 1)
			continue;
		for (; j_it != cells[i].drain_polygons->end() - 1; j_it++)
		{
			for (k_it = j_it + 1; k_it != cells[i].drain_polygons->end();
				 k_it++)
			{
				gpc_polygon_clip(GPC_INT, k_it->poly, j_it->poly,
								 &intersection);
				if (intersection.num_contours == 0)
				{
					gpc_free_polygon(&intersection);
					continue;
				}
				gpc_free_polygon(&intersection);
				gpc_polygon_clip(GPC_DIFF, k_it->poly, j_it->poly,
								 &intersection);
				gpc_free_polygon(k_it->poly);
				free_check_null(k_it->poly);
				k_it->poly = gpc_polygon_duplicate(&intersection);
				gpc_free_polygon(&intersection);
			}
		}
	}
	/*
	 *    Remove empty polygons
	 */

	for (i = 0; i < count_cells; i++)
	{
		if (cells[i].drain_polygons->size() < 1)
			continue;

		/*
		   k = 0;
		   for (j = 0; j < (int) cells[i].drain_polygons.size(); j++) {
		   if (cells[i].drain_polygons[j]->poly->num_contours == 0) {
		   gpc_free_polygon(cells[i].drain_polygons[j]->poly);
		   } else { 
		   if (j != k) {
		   cells[i].drain_polygons[k]->poly = gpc_polygon_duplicate(cells[i].drain_polygons[j]->poly);
		   }
		   k++;
		   }
		   }
		   cells[i].count_drain_polygons = k;
		 */
		std::vector < River_Polygon >::iterator k_it =
			cells[i].drain_polygons->begin();
		std::vector < River_Polygon >::iterator j_it =
			cells[i].drain_polygons->begin();
		for (; j_it != cells[i].drain_polygons->end(); j_it++)
		{
			if (j_it->poly->num_contours == 0)
			{
				gpc_free_polygon(j_it->poly);
			}
			else
			{
				if (j_it != k_it)
				{
					gpc_free_polygon(k_it->poly);
					free_check_null(k_it->poly);
					k_it->poly = gpc_polygon_duplicate(j_it->poly);
				}
				k_it++;
			}
		}
		for (std::vector < River_Polygon >::iterator it = k_it;
			 it != cells[i].drain_polygons->end(); it++)
		{
			gpc_free_polygon(it->poly);
			free_check_null(it->poly);
		}
		cells[i].drain_polygons->erase(k_it, cells[i].drain_polygons->end());
	}
	/*
	 *   Find interpolation point and weighing factor
	 */
	for (i = 0; i < count_cells; i++)
	{

		std::vector < River_Polygon >::iterator j_it =
			cells[i].drain_polygons->begin();
		for (; j_it != cells[i].drain_polygons->end(); j_it++)
		{
			j_it->area = gpc_polygon_area(j_it->poly);
			interpolate_drain(&(*j_it));
		}
	}
	/*  frees contours and vertices p */
	gpc_free_polygon(&poly2);


	// Make list of drain segments in correct vertical cell

	for (i = 0; i < count_cells; i++)
	{
		if (cells[i].drain_polygons->size() == 0)
			continue;
		std::vector < River_Polygon >::iterator j_it =
			cells[i].drain_polygons->begin();
		for (; j_it != cells[i].drain_polygons->end(); j_it++)
		{
			int drain_number = j_it->river_number;
			int point_number = j_it->point_number;

			/*  get elevation I */
			double w0 = j_it->w;
			double w1 = 1. - w0;
			double z0 = drains[drain_number]->points[point_number].z_grid;
			double z1 = drains[drain_number]->points[point_number + 1].z_grid;
			double z = (z0 * w0 + z1 * w1);

			// determine cell number from z
			int i1, j1, k1;
			if (which_cell(cells[i].x, cells[i].y, z, &i1, &j1, &k1) == 0)
			{

			}
			int n = ijk_to_n(i1, j1, k1);

			// Note only pointer is saved, do not free
			cells[n].drain_segments->push_back(*j_it);
		}
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_drains(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Check drain data 
 */
	int i, j, k;
	size_t count_points;
	Drain *drain_ptr;
	size_t count_drains = drains.size();
	if (count_drains <= 0)
		return (OK);
	for (j = 0; j < (int) count_drains; j++)
	{
		drain_ptr = drains[j];
		count_points = drain_ptr->points.size();
		/*
		 *   Write points for drain
		 */
		output_msg(OUTPUT_ECHO, "@type xy\n");
		output_msg(OUTPUT_ECHO, "#drain segments %d %s\n", drain_ptr->n_user,
				   drain_ptr->description.c_str());
		for (i = 0; i < (int) count_points; i++)
		{
			output_msg(OUTPUT_ECHO, "\t%15e\t%15e\n", drain_ptr->points[i].x_grid,
					   drain_ptr->points[i].y_grid);
		}
		output_msg(OUTPUT_ECHO, "&\n");
		/*
		 *   Write polygons for drain
		 */
		output_msg(OUTPUT_ECHO, "@type xy\n");
		output_msg(OUTPUT_ECHO, "#drain polygons %d %s\n", drain_ptr->n_user,
				   drain_ptr->description.c_str());
		for (i = 0; i < (int) count_points - 1; i++)
		{
			for (k = 0; k < 4; k++)
			{
				output_msg(OUTPUT_ECHO, "\t%15e\t%15e\n",
						   drain_ptr->points[i].vertex[k].x,
						   drain_ptr->points[i].vertex[k].y);
			}
			output_msg(OUTPUT_ECHO, "\t%15e\t%15e\n",
					   drain_ptr->points[i].vertex[0].x,
					   drain_ptr->points[i].vertex[0].y);
		}
		output_msg(OUTPUT_ECHO, "&\n");
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
interpolate_drain(River_Polygon * drain_polygon_ptr)
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
		&(drains[drain_polygon_ptr->river_number]->
		  points[drain_polygon_ptr->point_number]);
	p1_ptr =
		&(drains[drain_polygon_ptr->river_number]->
		  points[drain_polygon_ptr->point_number + 1]);
	poly = drain_polygon_ptr->poly;
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
	 *   Calculate weighting factors for drain_Point 0 and 1
	 */
	w0 = 1 - w1;
	/*
	 *   Put weighted values in drain_Polygon
	 */
	drain_polygon_ptr->w = w0;

	return (OK);
}
#ifdef SKIP
/* ---------------------------------------------------------------------- */
void
Drain::Convert_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM target,
								 PHAST_Transform * map2grid)
/* ---------------------------------------------------------------------- */
{
	if (this->coordinate_system == target)
		return;
	if (this->coordinate_system == PHAST_Transform::NONE)
	{
		sprintf(error_string, "Error with coordinate system for river %d %s.",
				this->n_user, this->description.c_str());
		error_msg(error_string, CONTINUE);
		input_error++;
		return;
	}
	switch (target)
	{
	case PHAST_Transform::GRID:
		for (std::vector < River_Point >::iterator it = this->points.begin();
			 it != this->points.end(); it++)
		{
			if (it->x_defined == FALSE || it->y_defined == FALSE
				|| it->y_defined == FALSE)
			{
				input_error++;
				sprintf(error_string, "Missing x, y, or z coordinate %d, %s",
						this->n_user, this->description.c_str());
				error_msg(error_string, CONTINUE);
				return;
			}
			Point p(it->x, it->y, it->z);
			map2grid->Transform(p);
			it->x = p.x();
			it->y = p.y();
			it->z = p.z();
		}
		this->coordinate_system = PHAST_Transform::GRID;
		break;
	case PHAST_Transform::MAP:
		for (std::vector < River_Point >::iterator it = this->points.begin();
			 it != this->points.end(); it++)
		{
			if (it->x_defined == FALSE || it->y_defined == FALSE
				|| it->y_defined == FALSE)
			{
				input_error++;
				sprintf(error_string, "Missing x, y, or z coordinate %d, %s",
						this->n_user, this->description.c_str());
				error_msg(error_string, CONTINUE);
				return;
			}
			Point p(it->x, it->y, it->z);
			map2grid->Inverse_transform(p);
			it->x = p.x();
			it->y = p.y();
			it->z = p.z();
		}
		this->coordinate_system = PHAST_Transform::MAP;
		break;
	default:
		sprintf(error_string,
				"Error converting river coordinate system %d, %s",
				this->n_user, this->description.c_str());
		error_msg(error_string, CONTINUE);
		input_error++;
	}
}
#endif
/* ---------------------------------------------------------------------- */
void
Drain::Convert_xy_to_grid(PHAST_Transform * map2grid)
/* ---------------------------------------------------------------------- */
{
	if (this->coordinate_system == PHAST_Transform::NONE)
	{
		sprintf(error_string, "Error with XY coordinate system for drain %d %s.",
				this->n_user, this->description.c_str());
		error_msg(error_string, CONTINUE);
		input_error++;
		return;
	}
	switch (this->coordinate_system)
	{
	case PHAST_Transform::GRID:
		for (std::vector < River_Point >::iterator it = this->points.begin();
			 it != this->points.end(); it++)
		{
			if (it->x_user_defined == FALSE || it->y_user_defined == FALSE)
			{
				input_error++;
				sprintf(error_string, "Missing X or Y coordinate %d, %s",
						this->n_user, this->description.c_str());
				error_msg(error_string, CONTINUE);
				return;
			}
			it->x_grid = it->x_user;
			it->y_grid = it->y_user;
		}
		break;
	case PHAST_Transform::MAP:
		for (std::vector < River_Point >::iterator it = this->points.begin();
			 it != this->points.end(); it++)
		{
			if (it->x_user_defined == FALSE || it->y_user_defined == FALSE)
			{
				input_error++;
				sprintf(error_string, "Missing X or Y coordinate %d, %s",
						this->n_user, this->description.c_str());
				error_msg(error_string, CONTINUE);
				return;
			}
			Point p(it->x_user, it->y_user, 0.0);
			map2grid->Transform(p);
			it->x_grid = p.x();
			it->y_grid = p.y();
		}
		break;
	default:
		sprintf(error_string,
				"Error converting drain coordinate system %d, %s",
				this->n_user, this->description.c_str());
		error_msg(error_string, CONTINUE);
		input_error++;
	}
}
/* ---------------------------------------------------------------------- */
void
Drain::Convert_z_to_grid(PHAST_Transform * map2grid)
/* ---------------------------------------------------------------------- */
{
	if (this->z_coordinate_system == PHAST_Transform::NONE)
	{
		sprintf(error_string, "Error with Z coordinate system for drain %d %s.",
				this->n_user, this->description.c_str());
		error_msg(error_string, CONTINUE);
		input_error++;
		return;
	}
	switch (this->z_coordinate_system)
	{
	case PHAST_Transform::GRID:
		for (std::vector < River_Point >::iterator it = this->points.begin();
			 it != this->points.end(); it++)
		{
			if (it->z_user_defined == TRUE)
			{
				it->z_grid = it->z_user;
			}
		}
		break;
	case PHAST_Transform::MAP:
		for (std::vector < River_Point >::iterator it = this->points.begin();
			 it != this->points.end(); it++)
		{
			if (it->z_user_defined == TRUE)
			{
				Point p(0.0, 0.0, it->z_user);
				map2grid->Transform(p);
				it->z_grid = p.z();
			}
		}
		break;
	default:
		sprintf(error_string,
				"Error converting drain coordinate system %d, %s",
				this->n_user, this->description.c_str());
		error_msg(error_string, CONTINUE);
		input_error++;
	}
}
/* ---------------------------------------------------------------------- */
void
Drain::Convert_width_to_grid(void)
/* ---------------------------------------------------------------------- */
{

	for (std::vector < River_Point >::iterator it = this->points.begin();
		it != this->points.end(); it++)
	{
		if (it->width_user_defined == TRUE)
		{
			it->width_grid = it->width_user * units.drain_width.input_to_si / units.horizontal.input_to_si;
		}
	}

}
