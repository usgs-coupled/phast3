#if !defined(SHAPEFILE_H_INCLUDED)
#define SHAPEFILE_H_INCLUDED
#include "../Filedata.h"
#include "shapefil.h"
#include <stdio.h>
#include <vector>   // std::vector
#include <map>
class Point;
#include "../gpc.h"

class Shapefile : Filedata
{
public:
  Shapefile(void);
  Shapefile(std::string &fname);
  void Dump(std::ostream &oss);
  std::vector<Point> & Get_points(const int field);
  gpc_polygon *Get_polygons();
  bool Point_in_polygon(const Point p);
  struct zone *Bounding_box(void);
  void Set_bounding_box();
  // destructor
  ~Shapefile(void);

  // Data
  SHPInfo *shpinfo;
  DBFInfo *dbfinfo;
  std::vector<SHPObject *> objects;
  std::vector<Point> pts;
  int current_field;
  
};
#endif // !defined(SHAPEFILE_H_INCLUDED)
