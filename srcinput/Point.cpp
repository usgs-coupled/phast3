#include "Point.h"
#include <map>
#include "gpc.h"
#include "message.h"
// constructor
Point::Point(void)
{
  this->coord[0] = 0.0;
  this->coord[1] = 0.0;
  this->coord[2] = 0.0;
  this->v =        0.0;
}

// operator overload
Point operator+(Point a, Point b)
{
  Point c(a.x() + b.x(), a.y() + b.y(), a.z() + b.z());
  c.set_v(a.get_v() + b.get_v());
  return(c);
}
Point operator-(Point a, Point b)
{
  Point c(a.x() - b.x(), a.y() - b.y(), a.z() - b.z());
  c.set_v(a.get_v() - b.get_v());
  return(c);
}
Point operator*(Point a, double b)
{
  Point c(a.x()*b, a.y()*b, a.z()*b);
  c.set_v(a.get_v()*b);
  return(c);
}
Point operator*(double b, Point a)
{
  Point c(a.x()*b, a.y()*b, a.z()*b);
  c.set_v(a.get_v()*b);
  return(c);
}
bool operator < (Point &a, Point &b)
{
  if (a.x() < b.x()) return true;
  if (a.x() > b.x()) return false;
  if (a.y() < b.y()) return true;
  if (a.y() > b.y()) return false;
  if (a.z() < b.z()) return true;
  if (a.z() > b.z()) return false;
  return false;
}
bool operator == (Point &a, Point &b)
{
  if (a.x() == b.x() && a.y() == b.y() && a.z() == b.z()) 
  {
    return true;
  }
  return false;
}
// destructor
Point::~Point(void)
{
}

// constructor and methods with templates are required to be
// in header for some reason.

double interpolate_nearest(std::vector<Point> &pts, Point &grid_pt)
{

  if(pts.size() == 0) {
    warning_msg("Nearest neighbor search had no points.");
    return(0);
  }

  std::vector<Point>::iterator it = pts.begin();

  double least = 1e30;
  double v = 0;

  double d, dx, dy, dz;
  // find minimum distance
  for (it = pts.begin(); it != pts.end(); it++)
  {
    dx = it->x() - grid_pt.x();
    dy = it->y() - grid_pt.y();
    dz = it->z() - grid_pt.z();

    d = sqrt(dx*dx + dy*dy + dz*dz);
    if (d < least)
    {
      least = d;
      v = it->get_v();
    }
  }
  return(v);
}
double interpolate_inverse_square(std::vector<Point> &pts, Point &grid_pt)
{

  if(pts.size() == 0) {
    warning_msg("Inverse_square calculation had no points.");
    return(0);
  }



  double d2, dx, dy, dz;
  std::vector<std::pair<double, double> > d_v;

  // calculate distance
  double sum = 0;
  for (std::vector<Point>::iterator it = pts.begin(); it != pts.end(); it++)
  {
    dx = it->x() - grid_pt.x();
    dy = it->y() - grid_pt.y();
    dz = it->z() - grid_pt.z();

    d2 = dx*dx + dy*dy + dz*dz;
    if (d2 == 0.0) {
      return (it->get_v());
    }
    d2 = 1.0/d2;
    sum += d2;
    std::pair<double, double> p(d2, it->get_v());
    d_v.push_back(p);
  }

  // Calculate weighted value
  double v = 0;
  for (std::vector<std::pair<double, double> >::iterator it = d_v.begin(); it != d_v.end(); it++)
  {
    v += it->first / sum * it->second;
  }

  return(v);
}
#ifdef SKIP
bool Point::point_in_polygon(gpc_polygon *poly_ptr) 
{
  int i, j;
  Point p1, p2;
  double anglesum = 0;
  double costheta;
  for (i = 0; i < poly_ptr->num_contours; i++)
  {
    for (j = 0; j < poly_ptr->contour[i].num_vertices ; j++)
    {
      p1 = Point(poly_ptr->contour[i].vertex[j].x - this->x(), poly_ptr->contour[i].vertex[j].y - this->y(), 0.0);
      if (j <  poly_ptr->contour[i].num_vertices - 1)
      {
	p2 = Point(poly_ptr->contour[i].vertex[j+1].x - this->x(), poly_ptr->contour[i].vertex[j+1].y - this->y(), 0.0);
      } else
      {
	p2 = Point(poly_ptr->contour[i].vertex[0].x - this->x(), poly_ptr->contour[i].vertex[0].y - this->y(), 0.0);
      }

      double m1 = p1.modulus();
      double m2 = p2.modulus();
      if (m1*m2 <= EPSILON)
      {
	return(true); /* We are on a node, consider this inside */
      } else
      {
	costheta = (p1.x()*p2.x() + p1.y()*p2.y() + p1.z()*p2.z()) / (m1*m2);
      }
      anglesum += acos(costheta);
    }
    if (fabs(anglesum - TWOPI) < EPSILON) return(true);
  }
  return false;
}
#endif
bool Point::point_in_gpc_polygon(gpc_polygon *poly_ptr) 
{
//int pnpoly(int npol, float *xp, float *yp, float x, float y)
  
  double x = this->x();
  double y = this->y();

  int l;
  for (l = 0; l < poly_ptr->num_contours; l++)
  {
    bool in = false;
    int i, j;
    int npol = poly_ptr->contour[l].num_vertices;
    for (i = 0, j = npol-1; i < npol; j = i++) {
      double xpi = poly_ptr->contour[l].vertex[i].x;
      double xpj = poly_ptr->contour[l].vertex[j].x;
      double ypi = poly_ptr->contour[l].vertex[i].y;
      double ypj = poly_ptr->contour[l].vertex[j].y;
      if ((((ypi <= y) && (y < ypj)) ||
	((ypj <= y) && (y < ypi))) &&
	(x < (xpj - xpi) * (y - ypi) / (ypj - ypi) + xpi))
	in = !in;
    }
    if (in) return(true);
  }

  // Also check if point is on an edge
  double z = 0.0, z1 = 0.0, z2 = 0.0;
  for (l = 0; l < poly_ptr->num_contours; l++)
  {
    int i, j;
    j = poly_ptr->contour[l].num_vertices - 1;
    for (i = 0; i < poly_ptr->contour[l].num_vertices; i++)
    {
      double x1, y1, x2, y2;
      x1 = poly_ptr->contour[l].vertex[i].x;
      y1 = poly_ptr->contour[l].vertex[i].y;
      x2 = poly_ptr->contour[l].vertex[j].x;
      y2 = poly_ptr->contour[l].vertex[j].y;
      double xn, yn, zn, dist, t;
      line_seg_point_near_3d(x1, y1, z1, x2, y2, z2, x, y, z, &xn, &yn, &zn, &dist, &t);
      if (dist < 1e-6) {
	return(true);
      }
      j = i;
    }
  }

  return(false);

}
bool Point::Point_in_polygon(std::vector<Point> &pts) 
{
//int pnpoly(int npol, float *xp, float *yp, float x, float y)
  
  double x = this->x();
  double y = this->y();

  bool in = false;
  int i, j;
  int npol = pts.size();
  for (i = 0, j = npol-1; i < npol; j = i++) {
    double xpi = pts[i].x();
    double xpj = pts[j].x();
    double ypi = pts[i].y();
    double ypj = pts[j].y();
    if ((((ypi <= y) && (y < ypj)) ||
      ((ypj <= y) && (y < ypi))) &&
      (x < (xpj - xpi) * (y - ypi) / (ypj - ypi) + xpi))
      in = !in;
  }
  if (in) return(true);


  // Also check if point is on an edge
  double z = 0.0, z1 = 0.0, z2 = 0.0;

  j = pts.size() - 1;
  for (i = 0; i < (int) pts.size(); i++)
  {
    double x1, y1, x2, y2;
    x1 = pts[i].x();
    y1 = pts[i].y();
    x2 = pts[j].x();
    y2 = pts[j].y();
    double xn, yn, zn, dist, t;
    line_seg_point_near_3d(x1, y1, z1, x2, y2, z2, x, y, z, &xn, &yn, &zn, &dist, &t);
    if (dist < 1e-6) {
      return(true);
    }
    j = i;
  }

  return(false);
}

// constructor
Segment::Segment(void)
{
  this->pts.push_back(Point(0,0,0,0));
  this->pts.push_back(Point(0,0,0,0));
}
Segment::Segment(Point p1, Point p2)
{
  this->pts.push_back(p1);
  this->pts.push_back(p2);
}
// destructor
Segment::~Segment(void)
{
}
