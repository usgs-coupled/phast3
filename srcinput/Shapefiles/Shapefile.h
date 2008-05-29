#if !defined(SHAPEFILE_H_INCLUDED)
#define SHAPEFILE_H_INCLUDED
#include "../Filedata.h"
#include "shapefil.h"
#include <stdio.h>
#include <vector>   // std::vector
#include <map>
class Point;
#include "../gpc.h"

class Shapefile : public Filedata
{
public:
  Shapefile(void);
  Shapefile(std::string &fname);
  void Dump(std::ostream &oss);
  //bool Set_points(const int field);
  bool Make_points(const int field, std::vector<Point> &pts);
  std::vector<Point> &Shapefile::Get_points(int attribute);
  bool Shapefile::Make_polygons( int field, PHST_polygon &polygons);
  bool Point_in_polygon(const Point p);
  struct zone *Get_bounding_box(void);
  void Set_bounding_box();
  // destructor
  ~Shapefile(void);

  // Data
  SHPInfo *shpinfo;
  DBFInfo *dbfinfo;
  std::vector<SHPObject *> objects;
  
};
#endif // !defined(SHAPEFILE_H_INCLUDED)
