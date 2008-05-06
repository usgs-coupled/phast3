#if !defined(SHAPEFILE_H_INCLUDED)
#define SHAPEFILE_H_INCLUDED
#include "shapefil.h"
#include <stdio.h>
#include <iostream>
#include <vector>   // std::vector
#include "../Point.h"
#include "../gpc.h"

class Shapefile 
{
public:
  Shapefile(void);
  Shapefile(std::string &fname);
  void Dump(std::ostream &oss);
  void Extract_surface(std::vector<Point> &pts, const int field);
  gpc_polygon *Extract_polygon(void);
  // destructor
  ~Shapefile(void);

  // Data
  SHPInfo *shpinfo;
  DBFInfo *dbfinfo;
  std::vector<SHPObject *> objects;
  
};
#endif // !defined(SHAPEFILE_H_INCLUDED)
