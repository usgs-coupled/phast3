#if !defined(RIVER_H_INCLUDED)
#define RIVER_H_INCLUDED
#include "PHAST_Transform.h"

/* ----------------------------------------------------------------------
 *   Rivers
 * ---------------------------------------------------------------------- */
typedef struct
{
	double x_user;
	int x_user_defined;
	double y_user;
	int y_user_defined;
	double width_user;
	int width_user_defined;
	double k;
	int k_defined;
	double thickness;
	int thickness_defined;
	struct time_series *head;
	int head_defined;
	double current_head;
	double depth_user;
	int depth_user_defined;
	double z_user;
	int z_user_defined;
	//int z_input_defined;

	double x_grid;
	double y_grid;
	double width_grid; 
	double z_grid;

	struct time_series *solution;
	int solution_defined;
	int current_solution;
	int solution1;
	int solution2;
	double f1;
	/*    gpc_vertex right, left; */
	gpc_vertex vertex[4];
	gpc_polygon *polygon;
	int update;
} River_Point;
typedef struct
{
	River_Point *points;
	int count_points;
	int new_def;
	int update;
	int n_user;
	char *description;
	PHAST_Transform::COORDINATE_SYSTEM coordinate_system;
	PHAST_Transform::COORDINATE_SYSTEM z_coordinate_system_user;
} River;
typedef struct
{
	gpc_polygon *poly;
	double x;
	double y;
	double area;
	int river_number;
	int point_number;
	double w;
} River_Polygon;

void river_polygon_init(River_Polygon * rp_ptr);

#endif // !defined(RIVER_H_INCLUDED)
