#include "XYZfile.h"
#include "message.h"
#include <iostream>
#include <istream>
#include <fstream>
#include "Point.h"
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
    if (i%3 == 2) this->pts.push_back(p);
    i++;
  }
  // Set bounding box
  this->Set_bounding_box();
}

XYZfile::~XYZfile(void)
{
}
void XYZfile::Set_bounding_box(void)
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
struct zone *XYZfile::Bounding_box(void)
{
  return(&this->box);
}
gpc_polygon * XYZfile::Get_polygons(void)
{
  if (this->polygons == NULL)
  {
    this->polygons = points_to_poly(this->pts);
  }
  return (this->polygons);
}