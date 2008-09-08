#include "message.h"
#include "gpc.h"
#include "gpc_helper.h"
#include "Point.h"
#include "Utilities.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "PHAST_polygon.h"
#if defined(__WPHAST__) && !defined(_DEBUG)
#include "../phqalloc.h"
#else
#ifdef _DEBUG
#define _CRTDBG_MAP_ALLOC
#include <crtdbg.h>
#endif
#endif
extern void malloc_error (void);
#ifndef PI
extern double PI;
#endif
void gpc_polygon_init(gpc_polygon *ptr)
{
	ptr->hole = NULL;
	ptr->contour = NULL;
	ptr->num_contours = 0;
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
double PolygonArea(gpc_vertex *polygon, int N)
/* ---------------------------------------------------------------------- */
/*
gpc_vertex *polygon;
int N;
*/
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
	out_poly = (gpc_polygon*) malloc ((size_t) sizeof(gpc_polygon));
	if (out_poly == NULL) malloc_error();

	out_poly->num_contours = in_poly->num_contours;
	out_poly->contour = NULL;
	if (out_poly->num_contours == 0) return(out_poly);
	/*
	 *   Malloc contours
	 */
	out_poly->contour = (gpc_vertex_list*) malloc ((size_t) (in_poly->num_contours * sizeof(gpc_vertex_list)));
	if (out_poly->contour == NULL) malloc_error();
	/*
	 *   Copy each contour
	 */
	for (k = 0; k < in_poly->num_contours; k++) {
		out_poly->contour[k].num_vertices = in_poly->contour[k].num_vertices;
		out_poly->contour[k].vertex = NULL;
		if (out_poly->contour[k].num_vertices == 0) continue;
		out_poly->contour[k].vertex = (gpc_vertex*) malloc((size_t) in_poly->contour[k].num_vertices * sizeof(gpc_vertex));
		for (i=0; i < out_poly->contour[k].num_vertices; i++) {
			out_poly->contour[k].vertex[i].x = in_poly->contour[k].vertex[i].x;
			out_poly->contour[k].vertex[i].y = in_poly->contour[k].vertex[i].y;

		}
	}

	// malloc holes
	out_poly->hole = (int *) malloc ((size_t) (in_poly->num_contours * sizeof(int)));
	if (out_poly->hole == NULL) malloc_error();
	memcpy(out_poly->hole, in_poly->hole, (size_t) (in_poly->num_contours * sizeof(int)));


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

	poly_ptr =  (gpc_polygon*) malloc((size_t) sizeof(gpc_polygon));
	if (poly_ptr == NULL) malloc_error();

	/*
	 *   gpc_polygon for river polygon
	 */
	poly_ptr->contour = (gpc_vertex_list*) malloc((size_t) sizeof(gpc_vertex_list));
	if (poly_ptr->contour == NULL) malloc_error();
	p = (gpc_vertex*) malloc((size_t) n * sizeof (gpc_vertex));
	if (p == NULL) malloc_error();
	poly_ptr->contour[0].vertex = p;
	poly_ptr->contour[0].num_vertices = n;
	poly_ptr->num_contours = 1;
	poly_ptr->hole = (int *) malloc(sizeof(int));
	poly_ptr->hole[0] = 0;  // hole is false
	/*
	 *   gpc_vertex list for cell boundary
	 */
	for (i = 0; i < n; i++) {
		p[i].x = v[i].x;
		p[i].y = v[i].y;
	}
	return(poly_ptr);
}
/* ---------------------------------------------------------------------- */
gpc_polygon *points_to_poly(std::vector<Point> &pts, Cell_Face face)
/* ---------------------------------------------------------------------- */
{
  gpc_polygon *poly_ptr;
  int i;
  gpc_vertex *p;

  int n = pts.size();
  poly_ptr =  (gpc_polygon*) malloc((size_t) sizeof(gpc_polygon));
  if (poly_ptr == NULL) malloc_error();
  
  /*
  *   gpc_polygon for river polygon
  */
  poly_ptr->contour = (gpc_vertex_list*) malloc((size_t) sizeof(gpc_vertex_list));
  if (poly_ptr->contour == NULL) malloc_error();
  p = (gpc_vertex*) malloc((size_t) n * sizeof (gpc_vertex));
  if (p == NULL) malloc_error();
  poly_ptr->contour[0].vertex = p;
  poly_ptr->contour[0].num_vertices = n;
  poly_ptr->num_contours = 1;
  poly_ptr->hole = (int *) malloc(sizeof(int));
  poly_ptr->hole[0] = 0; // hole is false
  /*
  *   gpc_vertex list for cell boundary
  */
  switch (face)
  {
  case CF_X:
    for (i = 0; i < n; i++) 
    {
      p[i].x = pts[i].y();
      p[i].y = pts[i].z();
    }
    break;
  case CF_Y:
    for (i = 0; i < n; i++) 
    {
      p[i].x = pts[i].x();
      p[i].y = pts[i].z();
    }
    break;
  case CF_Z:
    for (i = 0; i < n; i++) 
    {
      p[i].x = pts[i].x();
      p[i].y = pts[i].y();
    }
    break;
  default:
    error_msg("Unhandled case in points_to_poly.", EA_STOP);
    break;
  }
  return(poly_ptr);
}
/* ---------------------------------------------------------------------- */
gpc_polygon *points_to_poly(std::vector<Point> &pts)
/* ---------------------------------------------------------------------- */
{
	gpc_polygon *poly_ptr;
	int i;
	gpc_vertex *p;

	int n = pts.size();
	poly_ptr =  (gpc_polygon*) malloc((size_t) sizeof(gpc_polygon));
	if (poly_ptr == NULL) malloc_error();
	/*
	 *   gpc_polygon for river polygon
	 */
	poly_ptr->contour = (gpc_vertex_list*) malloc((size_t) sizeof(gpc_vertex_list));
	if (poly_ptr->contour == NULL) malloc_error();
	p = (gpc_vertex*) malloc((size_t) n * sizeof (gpc_vertex));
	if (p == NULL) malloc_error();
	poly_ptr->contour[0].vertex = p;
	poly_ptr->contour[0].num_vertices = n;
	poly_ptr->num_contours = 1;
	poly_ptr->hole = (int *) malloc(sizeof(int));
	poly_ptr->hole[0] = 0;  // hole is false
	/*
	 *   gpc_vertex list for cell boundary
	 */
	for (i = 0; i < n; i++) {
		p[i].x = pts[i].x();
		p[i].y = pts[i].y();
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
#ifdef SKIP
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
#endif
/* ---------------------------------------------------------------------- */
gpc_polygon *rectangle(double x1, double y1, double x2, double y2)
/* ---------------------------------------------------------------------- */
{
	gpc_polygon *poly_ptr;
	gpc_vertex *p;

	int n = 4;

	// Malloc gpc_polygon
	poly_ptr =  (gpc_polygon*) malloc((size_t) sizeof(gpc_polygon));
	if (poly_ptr == NULL) malloc_error();

	// Malloc contour
	poly_ptr->contour = (gpc_vertex_list*) malloc((size_t) sizeof(gpc_vertex_list));
	if (poly_ptr->contour == NULL) malloc_error();

	// Malloc vertices
	p = (gpc_vertex*) malloc((size_t) n * sizeof (gpc_vertex));
	if (p == NULL) malloc_error();

	poly_ptr->contour[0].vertex = p;
	poly_ptr->contour[0].num_vertices = n;
	poly_ptr->num_contours = 1;
	poly_ptr->hole = (int *) malloc(sizeof(int));
	poly_ptr->hole[0] = 0;  // hole is false
	/*
	 *   gpc_vertex list for rectangle
	 */
	p[0].x = x1;
	p[0].y = y1;
	p[1].x = x2;
	p[1].y = y1;
	p[2].x = x2;
	p[2].y = y2;
	p[3].x = x1;
	p[3].y = y2;

	return(poly_ptr);
}
/* ---------------------------------------------------------------------- */
gpc_polygon *triangle(double x1, double y1, double x2, double y2, double x3, double y3)
/* ---------------------------------------------------------------------- */
{
	gpc_polygon *poly_ptr;
	gpc_vertex *p;

	int n = 3;

	// Malloc gpc_polygon
	poly_ptr =  (gpc_polygon*) malloc((size_t) sizeof(gpc_polygon));
	if (poly_ptr == NULL) malloc_error();

	// Malloc contour
	poly_ptr->contour = (gpc_vertex_list*) malloc((size_t) sizeof(gpc_vertex_list));
	if (poly_ptr->contour == NULL) malloc_error();

	// Malloc vertices
	p = (gpc_vertex*) malloc((size_t) n * sizeof (gpc_vertex));
	if (p == NULL) malloc_error();

	poly_ptr->contour[0].vertex = p;
	poly_ptr->contour[0].num_vertices = n;
	poly_ptr->num_contours = 1;
	poly_ptr->hole = (int *) malloc(sizeof(int));
	poly_ptr->hole[0] = 0;  // hole is false
	/*
	 *   gpc_vertex list for rectangle
	 */
	p[0].x = x1;
	p[0].y = y1;
	p[1].x = x2;
	p[1].y = y2;
	p[2].x = x3;
	p[2].y = y3;
	return(poly_ptr);
}
/* ---------------------------------------------------------------------- */
gpc_polygon *empty_polygon(void)
/* ---------------------------------------------------------------------- */
{
	gpc_polygon *poly_ptr;

	// Malloc gpc_polygon
	poly_ptr =  (gpc_polygon*) malloc((size_t) sizeof(gpc_polygon));
	if (poly_ptr == NULL) malloc_error();

	// Malloc contour
	//poly_ptr->contour = (gpc_vertex_list*) malloc((size_t) sizeof(gpc_vertex_list));
	//if (poly_ptr->contour == NULL) malloc_error();
	poly_ptr->contour = NULL;
	poly_ptr->hole = NULL;

	// Malloc vertices
	//p = (gpc_vertex*) malloc((size_t) n * sizeof (gpc_vertex));
	//if (p == NULL) malloc_error();

	//poly_ptr->contour[0].vertex = p;
	//poly_ptr->contour[0].vertex = NULL;
	//poly_ptr->contour[0].num_vertices = 0;
	poly_ptr->num_contours = 0;

	return(poly_ptr);
}

bool line_and_segment_intersection(Point p1, Point p2, Point q1, Point q2, std::vector<Point> &intersection)
{
	// http://www.ucancode.net/faq/C-Line-Intersection-2D-drawing.htm
	// p1 and p2 define line, q1 and q2 define segment
	// ax + by = c
	double a1 = p2.y() - p1.y();
	double b1 = p1.x() - p2.x();
	double c1 = a1*p1.x() + b1*p1.y();

	double a2 = q2.y() - q1.y();
	double b2 = q1.x() - q2.x();
	double c2 = a2*q1.x() + b2*q1.y();

	double det = a1*b2 - a2*b1;
	std::vector<Point>::iterator last_it = intersection.end();

	if (intersection.size() > 0)
	{
		last_it = last_it - 1;
	}

	if (det == 0)
	{
		// Skip line segments
#ifdef SKIP
		//Lines are parallel; check for line segment on line
		Point p;
		if (equal(a1*q1.x() + b1*q1.y(), c1, 1e-8))
		{
			if (last_it == intersection.end() || !(*last_it == q2))
			{
				intersection.push_back(q2);
			}
			if (!(q1 == q2))
			{
				intersection.push_back(q1);
			}
			return(true);
		}
#endif

	} 
	else
	{
		double x = (b2*c1 - b1*c2)/det;
		double y = (a1*c2 - a2*c1)/det;
		// point intersection 
		{
			std::vector<Point> pts;
			pts.push_back(q1);
			pts.push_back(q2);
			Point pmin(pts.begin(), pts.end(), Point::MIN);
			Point pmax(pts.begin(), pts.end(), Point::MAX);
			if (pmin.x() > x || pmax.x() < x) return (false);
			if (pmin.y() > y || pmax.y() < y) return (false);
		}
		Point p(x, y, p1.z(), p1.get_v());
		if (last_it == intersection.end() || !(*last_it == p))
		{
			intersection.push_back(p);
		}
		return(true);
	}
	return(false);
}
#ifdef SKIP
bool line_and_segment_intersection(Point p1, Point p2, Point q1, Point q2, std::vector<Point> &intersection)
{
  // p1 and p2 define line, q1 and q2 define segment
  // ax + by = c
  double a1 = p2.y() - p1.y();
  double b1 = p2.x() - p2.y();
  double c1 = a1*p1.x() + b1*p1.y();

  double a2 = q2.y() - q1.y();
  double b2 = q2.x() - q2.y();
  double c2 = a2*q1.x() + b2*q1.y();

  double det = a1*b2 - a2*b1;
  std::vector<Point>::iterator last_it = intersection.end();

  if (intersection.size() > 0)
  {
    last_it = last_it - 1;
  }

  if (det == 0)
  {
    //Lines are parallel; check for line segment on line
    Point p;
    if (equal(a1*q1.x() + b1*q1.y(), c1, 1e-8))
    {
      if (last_it == intersection.end() || !(*last_it == q2))
      {
	intersection.push_back(q2);
      }
      if (!(q1 == q2))
      {
	intersection.push_back(q1);
      }
      return(true);
    }

  } else
  {
    double x = (a2*c1 - b1*c2)/det;
    double y = (a1*c2 - a2*c1)/det;
    // intersection is in segment
    {
      std::vector<Point> pts;
      pts.push_back(q1);
      pts.push_back(q2);
      Point pmin(pts.begin(), pts.end(), Point::MIN);
      Point pmax(pts.begin(), pts.end(), Point::MAX);
      if (pmin.x() > x || pmax.x() < x) return (false);
      if (pmin.y() > y || pmax.y() < y) return (false);
    }
    Point p(x, y, p1.z(), p1.get_v());
    if (last_it == intersection.end() || !(*last_it == p))
    {
	intersection.push_back(p);
    }
    return(true);
  }


  return(false);
}
#endif
bool line_intersect_polygon(Point lp1, Point lp2, std::vector<Point> pts, std::vector<Point> intersect_pts)
{
  // lp1 is assumed to be outside bounding box of the polygon
  int i, j;
  int npol = pts.size();
  j = npol-1;
  for (i = 0; i < npol; j = i++) {
    line_and_segment_intersection(lp1, lp2, pts[i], pts[j], intersect_pts);
  }

  // Should be an even number of points
  if(intersect_pts.size()%2 != 0) error_msg("Number of points of intersection of line with polygon should be even", EA_STOP);

  if (intersect_pts.size()> 0)
  {
    return(true);
  }
  return(false);
}
gpc_polygon *PHAST_polygon2gpc_polygon(PHAST_polygon *polys)
{
  int poly;
  gpc_polygon *cumulative = empty_polygon();
  // For each polygon
  for (poly = 0; poly < (int) polys->Get_begin().size(); poly++)
  {
    // accumulate points
    std::vector<Point> pts;
    std::vector<Point>::iterator it;
    for (it = polys->Get_begin()[poly]; it != polys->Get_end()[poly]; it++)
    {
      pts.push_back(*it);
    }
    
    // Make gpc polygon
    gpc_polygon *contour = points_to_poly(pts);

    // Append to gpc_polygon
    gpc_polygon_clip (GPC_UNION, cumulative, contour, cumulative);

    // Free contour
    gpc_free_polygon(contour);
    free_check_null(contour);
  }
  return (cumulative);

}
