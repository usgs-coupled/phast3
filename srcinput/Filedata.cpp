#include "Point.h"
#include "NNInterpolator/NNInterpolator.h"
#include "Filedata.h"

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

std::map<std::string, Filedata *> Filedata::file_data_map;
Filedata::Filedata(void)
{
  this->file_type = Filedata::NONE;
}

Filedata::~Filedata(void)
{
  this->nni_map.clear();
  /*
  std::map<int, std::vector<Point> >::iterator it1;
  for (it1 = this->pts_map.begin(); it1 != this->pts_map.end(); it1++)
  {
    delete it1->second;
  }
  */

}
void Clear_file_data_map(void)
{
  std::map<std::string, Filedata * >::iterator it;
  for (it = Filedata::file_data_map.begin(); it != Filedata::file_data_map.end(); it++)
  {
    delete it->second;
  }
  Filedata::file_data_map.clear();
}

void Filedata::Add_to_pts_map (int attribute)
{
  // Store list of points if necessary
  if (this->pts_map.size() == 0 || (this->pts_map.find(attribute) == this->pts_map.end()) )
  {
    std::vector<Point> temp_pts; 
    this->Make_points(attribute, temp_pts, 1.0, 1.0);

    this->pts_map[attribute] = temp_pts;
  }
}
#ifdef SKIP
void Filedata::Convert_coordinates (int attribute, PHAST_Transform &transform, PHAST_Transform::)
{
  // Store list of points if necessary
  if (this->pts_map.size() == 0 || (this->pts_map.find(attribute) == this->pts_map.end()) )
  {
    std::vector<Point> temp_pts; 
    this->Make_points(attribute, temp_pts, 1.0, 1.0);

    this->pts_map[attribute] = temp_pts;
  }
}
#endif