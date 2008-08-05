#include "PHST_polygon.h"
#include "message.h"
#include <iostream>
#include <cassert>

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

PHST_polygon::PHST_polygon(void)
{
}
PHST_polygon::PHST_polygon(gpc_polygon *poly)
{
  int i, j;
  for (i = 0; i < poly->num_contours; i++)
  {
    for (j = 0; j < poly->contour[i].num_vertices; j++)
    {
      Point p(poly->contour[i].vertex[j].x, poly->contour[i].vertex[j].y, 0.0);
      this->pts.push_back(p);
    }
  }

  std::vector<Point>::iterator it = this->pts.begin();
  for (i = 0; i < poly->num_contours; i++)
  {
    this->begin.push_back(it);
    for (j = 0; j < poly->contour[i].num_vertices; j++)
    {
      it++;
    }
    this->end.push_back(it);
  }
}
PHST_polygon::PHST_polygon(const std::vector<Point> &points)
: pts(points)
{
	this->begin.push_back(this->pts.begin());
	this->end.push_back(this->pts.end());
}
PHST_polygon::PHST_polygon(const PHST_polygon &poly)
: pts(poly.pts)
{
	std::vector< std::vector<Point>::iterator >::const_iterator bi = poly.begin.begin();
	for (; bi != poly.begin.end(); ++bi)
	{
		std::vector<Point>::difference_type diff = *bi - poly.pts.begin();
		this->begin.push_back(this->pts.begin() + diff);
	}
	std::vector< std::vector<Point>::iterator >::const_iterator ei = poly.end.begin();
	for (; ei != poly.end.end(); ++ei)
	{
		std::vector<Point>::difference_type diff = *ei - poly.pts.begin();
		this->end.push_back(this->pts.begin() + diff);
	}
	assert(poly.pts.size()   == this->pts.size());
	assert(poly.begin.size() == this->begin.size());
	assert(poly.end.size()   == this->end.size());
}
PHST_polygon::~PHST_polygon(void)
{
}
void PHST_polygon::set_z(double z)
{

  // for each point, set z value
  std::vector<Point>::iterator it;
  for (it = this->pts.begin(); it != this->pts.end(); it++)
  {
    it->set_z(z);
  }
}
void PHST_polygon::set_z_to_v()
{

  // for each point, set z value
  std::vector<Point>::iterator it;
  for (it = this->pts.begin(); it != this->pts.end(); it++)
  {
    it->set_z(it->get_v());
  }
}

bool PHST_polygon::Point_in_polygon(Point p) 

{
//int pnpoly(int npol, float *xp, float *yp, float x, float y)
  
  int poly;
  for (poly = 0; poly < (int) this->begin.size(); poly++)
  {
    if (Point_in_simple_polygon(p, this->begin[poly], this->end[poly])) return true;
  }

  return(false);
}
bool Point_in_simple_polygon(Point p, std::vector<Point>::iterator begin, std::vector<Point>::iterator end)
{
  bool in = false;
  double x = p.x();
  double y = p.y();
  std::vector<Point>::iterator i_it, j_it, npol_it;
  //int i, j;
  //int npol = pts.size();
  npol_it = end;
  //for (i = 0, j = npol-1; i < npol; j = i++) {
  j_it = npol_it - 1;
  for (i_it = begin; i_it != npol_it; j_it = i_it++)
  {
    //double xpi = pts[i].x();
    double xpi = i_it->x();
    //double xpj = pts[j].x();
    double xpj = j_it->x();
    //double ypi = pts[i].y();
    double ypi = i_it->y();
    //double ypj = pts[j].y();
    double ypj = j_it->y();
    if ((((ypi <= y) && (y < ypj)) ||
      ((ypj <= y) && (y < ypi))) &&
      (x < (xpj - xpi) * (y - ypi) / (ypj - ypi) + xpi))
      in = !in;
  }
  if (in) 
  {
    return(true);
  }
  // Also check if point is on an edge
  double z = 0.0, z1 = 0.0, z2 = 0.0;

  //j = pts.size() - 1;
  j_it = end - 1;
  //for (i = 0; i < (int) pts.size(); i++)
  for (i_it = begin; i_it != npol_it; i_it++)
  {
    double x1, y1, x2, y2;
    //x1 = pts[i].x();
    x1 = i_it->x();
    //y1 = pts[i].y();
    y1 = i_it->y();
    //x2 = pts[j].x();
    x2 = j_it->x();
    //y2 = pts[j].y();
    y2 = j_it->y();
    double xn, yn, zn, dist, t;
    line_seg_point_near_3d(x1, y1, z1, x2, y2, z2, x, y, z, &xn, &yn, &zn, &dist, &t);
    if (dist < 1e-6) {
      return(true);
    }
    //j = i;
    j_it = i_it;
  }
  return false;
}
bool PHST_polygon::Line_intersect(Point lp1, Point lp2, std::vector<Point> &intersect_pts)
{
  // lp1 is assumed to be outside bounding box of the polygon
  //int i, j;
  int poly;
  for (poly = 0; poly < (int) this->begin.size(); poly++)
  {
    if (Line_intersect_simple_polygon(lp1, lp2, this->begin[poly], this->end[poly], intersect_pts)) return true;
  }
  return(false);
}

bool Line_intersect_simple_polygon(Point lp1, Point lp2, std::vector<Point>::iterator begin, std::vector<Point>::iterator end, std::vector<Point> &intersect)
{
  // lp1 is assumed to be outside bounding box of the polygon
  //int i, j;
  std::vector<Point>::iterator i_it, j_it, npol_it;
  std::vector<Point> intersect_pts;
  //int npol = pts.size();
  npol_it = end;
  //j = npol-1;
  j_it = npol_it - 1;
  //for (i = 0; i < npol; j = i++) {
  for (i_it = begin; i_it != npol_it; j_it = i_it++)
  {
    //line_and_segment_intersection(lp1, lp2, pts[i], pts[j], intersect_pts);
    line_and_segment_intersection(lp1, lp2, *i_it, *j_it, intersect_pts);
  }

  if (intersect_pts.size() == 0) return(false);
  // Need to check if midpoint of line segments is interior
  std::vector<Point>::iterator k_it, l_it, n_it;
  n_it = intersect_pts.end();
  l_it = n_it - 1;
#ifdef SKIP
  for (k_it = intersect_pts.begin(); k_it != intersect_pts.end(); l_it = k_it++)
  {
    Point p = *l_it + 0.5 * (*k_it - *l_it);
    if (Point_in_simple_polygon(p, begin, end)) {
      intersect.push_back(*l_it);
      intersect.push_back(*k_it);
    }
  }
#endif
  for (k_it = intersect_pts.begin(); k_it != intersect_pts.end() - 1; k_it++)
  {
	l_it = k_it + 1;
    Point p = *l_it + 0.5 * (*k_it - *l_it);
    if (Point_in_simple_polygon(p, begin, end)) {
      intersect.push_back(*l_it);
      intersect.push_back(*k_it);
    }
  }

  // Should be an even number of points
  if(intersect_pts.size()%2 != 0) error_msg("Number of points of intersection of line with polygon should be even", EA_STOP);

  if (intersect_pts.size()> 0)
  {
    return(true);
  }
  return(false);
}
void PHST_polygon::Set_bounding_box(void)
{
  Point min(this->pts.begin(), this->pts.end(), Point::MIN);
  Point max(this->pts.begin(), this->pts.end(), Point::MAX);
  this->box.x1 = min.x();
  this->box.y1 = min.y();
  this->box.z1 = min.z();
  this->box.x2 = max.x();
  this->box.y2 = max.y();
  this->box.z2 = max.z();
}
void PHST_polygon::Clear(void)
{
  this->pts.clear();
  this->begin.clear();
  this->end.clear();
  this->box = zone();
}

