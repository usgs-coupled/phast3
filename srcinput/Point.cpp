#include "Point.h"
#include <iostream>
#include <map>

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
    std::cerr << "Nearest neighbor search had no points." << std::endl;
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
    std::cerr << "Inverse_square calculation had no points." << std::endl;
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
