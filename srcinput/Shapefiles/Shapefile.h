#if !defined(SHAPEFILE_H_INCLUDED)
#define SHAPEFILE_H_INCLUDED
#include "shapefil.h"
#include <stdio.h>
#include <vector>   // std::vector
class Point;
#include "../gpc.h"

class Shapefile 
{
public:
  Shapefile(void);
  Shapefile(std::string &fname);
  void Dump(std::ostream &oss);
  void Extract_surface(std::vector<Point> &pts, const int field);
  bool Point_in_polygon(const Point p);
  gpc_polygon *Extract_polygon(void);
  // destructor
  ~Shapefile(void);

  // Data
  SHPInfo *shpinfo;
  DBFInfo *dbfinfo;
  std::vector<SHPObject *> objects;
  
};
#endif // !defined(SHAPEFILE_H_INCLUDED)
