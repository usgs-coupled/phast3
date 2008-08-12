#include "XYZfile.h"
#include "message.h"
#include <iostream>
#include <istream>
#include <fstream>
#include "Point.h"
#include "PHST_polygon.h"

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

XYZfile::XYZfile(void)
{
}
XYZfile::XYZfile(std::string filename)
{
  std::string token;
  std::ifstream input (filename.c_str());
  bool error = false;
  if (!input.is_open())
  {
    error = true;
    std::ostringstream estring;
    estring << "Could not open file " << filename.c_str() << std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
  }
  int i = 0;
  Point p;
  double *coord = p.get_coord();
  while (input >> coord[i%3])
  {
    if (i%3 == 2) this->Get_points(-1).push_back(p);
    i++;
  }
  // Set bounding box
  //this->Set_bounding_box();
}

XYZfile::~XYZfile(void)
{
}
#ifdef SKIP
void XYZfile::Set_bounding_box(void)
{
  
  Point min(this->Get_points(-1).begin(), this->Get_points(-1).end(), Point::MIN); 
  Point max(this->Get_points(-1).begin(), this->Get_points(-1).end(), Point::MAX); 
  this->box.x1 = min.x();
  this->box.y1 = min.y();
  this->box.z1 = min.z();
  this->box.x2 = max.x();
  this->box.y2 = max.y();
  this->box.z2 = max.z();
}
struct zone *XYZfile::Get_bounding_box(void)
{
  return(&this->box);
}
#endif
#ifdef SKIP
gpc_polygon * XYZfile::Get_polygons(void)
{
  if (this->polygons == NULL)
  {
    this->polygons = points_to_poly(this->pts);
  }
  return (this->polygons);
}
#endif
bool XYZfile::Make_polygons( int field, PHST_polygon &polygons, double h_scale, double v_scale)
{
  this->Make_points(-1, polygons.Get_points(), h_scale, v_scale);
  polygons.Get_begin().push_back(this->Get_points(-1).begin());
  polygons.Get_end().push_back(this->Get_points(-1).end());
  polygons.Set_bounding_box();
  return true;
}
bool XYZfile::Make_points(int field, std::vector<Point> &pts, double h_scale, double v_scale)
{
  std::vector<Point>::iterator it;
  for (it = this->Get_points(-1).begin(); it != this->Get_points(-1).end(); it++)
  {
    Point p(it->x()*h_scale, it->y()*h_scale, it->z()*v_scale, it->get_v()*v_scale);
    pts.push_back(p);
  }
  return true; 
}
std::vector<Point> &XYZfile::Get_points(int attribute)
{
    return this->pts_map.begin()->second;
}