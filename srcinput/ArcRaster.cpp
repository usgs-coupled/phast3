#include "ArcRaster.h"
#include "message.h"
#include <iostream>
#include <istream>
#include <fstream>
#include "Point.h"

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

ArcRaster::ArcRaster(void)
{
}
ArcRaster::ArcRaster(std::string filename)
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

  // ncols
  input >> token;
  if (strcmp(token.c_str(), "ncols") != 0)  error = true;
  input >> this->ncols;

  // nrows
  input >> token;
  if (strcmp(token.c_str(), "nrows") != 0) error = true;
  input >> this->nrows;

  // xllcorner
  input >> token;
  if (strcmp(token.c_str(), "xllcorner") != 0) error = true;
  input >> this->xllcorner;

  // yllcorner
  input >> token;
  if (strcmp(token.c_str(), "yllcorner") != 0) error = true;
  input >> this->yllcorner;

  // cellsize
  input >> token;
  if (strcmp(token.c_str(), "cellsize") != 0) error = true;
  input >> this->cellsize;

  // NODATA_value
  input >> token;
  if (strcmp(token.c_str(), "NODATA_value") != 0) error = true;
  input >> this->nodata_value;

  if (error)
  {
    std::ostringstream estring;
    estring << "Does not appear to be an Arc raster file, " << filename.c_str() << std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
  }

  std::vector<Point>& temp_pts = this->pts_map[-1];
  temp_pts.reserve(this->nrows*this->ncols);
  temp_pts.clear();
  double value, xpos, ypos;
  int i, j;
  for (i = 0; i < nrows; i++)
  {
    ypos = this->yllcorner + (double (this->nrows - i) + 0.5) * this->cellsize;
    //char line[10000];
    //input.getline(line, 10000);
    //std::istringstream iss(line);

    for (j = 0; j  < this->ncols; j++)
    {    
      input >> value;
      xpos = this->xllcorner + (double (j) + 0.5) * this->cellsize;
      if (value != this->nodata_value)
      {
	//this->Get_points(-1).push_back(Point(xpos, ypos, value, value)); 
	temp_pts.push_back(Point(xpos, ypos, value, value));
      }
    }
  }
  temp_pts.resize(temp_pts.size());
  // Set bounding box
  //this->Set_bounding_box();
}

ArcRaster::~ArcRaster(void)
{
}
#ifdef SKIP
void ArcRaster::Set_bounding_box(void)
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
struct zone *ArcRaster::Get_bounding_box(void)
{
  return(&this->box);
}
#endif
#ifdef SKIP
gpc_polygon * ArcRaster::Get_polygons(void)
{
  return NULL;
}
#endif
bool ArcRaster::Make_points(int field, std::vector<Point> &new_pts, double h_scale, double v_scale)
{
  size_t i;
  std::vector<Point>::iterator it;
  std::vector<Point> &file_pts = this->Get_points(-1);
  new_pts.resize(file_pts.size());
  for (i = 0, it = file_pts.begin(); it != file_pts.end(); ++i, ++it)
  {
    new_pts[i] = Point(it->x()*h_scale, it->y()*h_scale, it->z()*v_scale, it->get_v()*v_scale);
  }
  return true; 
}
std::vector<Point> &ArcRaster::Get_points(int attribute)
{
  return this->pts_map.begin()->second;
}
