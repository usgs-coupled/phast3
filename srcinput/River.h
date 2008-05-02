#if !defined(RIVER_H_INCLUDED)
#define RIVER_H_INCLUDED
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
	int z_input_defined;
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
#endif // !defined(RIVER_H_INCLUDED)
