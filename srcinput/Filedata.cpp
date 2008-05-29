#include "Filedata.h"
#include "Point.h"
#include "NNInterpolator/NNInterpolator.h"
std::map<std::string,Filedata *> Filedata::file_data_map;
Filedata::Filedata(void)
{
  this->file_type = Filedata::NONE;
}

Filedata::~Filedata(void)
{
  std::map<int, NNInterpolator *>::iterator it;
  for (it = this->nni_map.begin(); it != this->nni_map.end(); it++)
  {
    delete it->second;
  }
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
  std::map<std::string,Filedata *>::iterator it;
  for (it = Filedata::file_data_map.begin(); it != Filedata::file_data_map.end(); it++)
  {
    delete it->second;
  }
  Filedata::file_data_map.clear();
}