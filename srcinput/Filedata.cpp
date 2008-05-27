#include "Filedata.h"
#include "Point.h"
std::map<std::string,Filedata *> Filedata::file_data_map;
Filedata::Filedata(void)
{
}

Filedata::~Filedata(void)
{

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