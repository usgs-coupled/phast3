#include <vector>
#include "Cell_Face.h"
class Point;
double PolygonArea(gpc_vertex *polygon, int N);
double angle_between_segments(gpc_vertex p0, gpc_vertex p1, gpc_vertex p2);
double angle_of_segment(gpc_vertex p0, gpc_vertex p1);
gpc_polygon *empty_polygon(void);
double gpc_polygon_area(gpc_polygon *poly);
gpc_polygon *gpc_polygon_duplicate(gpc_polygon *in_poly);
gpc_polygon *vertex_to_poly(gpc_vertex *v, int n);
gpc_polygon *points_to_poly(std::vector<Point> &pts);
gpc_polygon *points_to_poly(std::vector<Point> &pts, Cell_Face face);
void gpc_polygon_write(gpc_polygon *p);
gpc_polygon *rectangle(double x1, double y1, double x2, double y2);
void    Centroid3( gpc_vertex p1, gpc_vertex p2, gpc_vertex p3, gpc_vertex *c );
void line_seg_point_near_3d ( double x1, double y1, double z1, 
			      double x2, double y2, double z2, double x, double y, double z,
			      double *xn, double *yn, double *zn, double *dist, double *t );
gpc_polygon *triangle(double x1, double y1, double x2, double y2, double x3, double y3);

bool line_and_segment_intersection(Point p1, Point p2, Point q1, Point q2, std::vector<Point> &intersection);
bool line_intersect_polygon(Point ray1, Point ray2, std::vector<Point> pts, std::vector<Point> intersect_pts);
