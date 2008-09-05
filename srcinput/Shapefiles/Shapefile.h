#if !defined(SHAPEFILE_H_INCLUDED)
#define SHAPEFILE_H_INCLUDED
#include "../Filedata.h"
#include "shapefil.h"
#include <stdio.h>
#include <vector>   // std::vector
#include <map>
#include <string>
class Point;
#include "../gpc.h"

class Shapefile : public Filedata
{
public:
  // constructors
  Shapefile(void);
  Shapefile(std::string &fname, PHAST_Transform::COORDINATE_SYSTEM cs);

  // destructor
  virtual ~Shapefile(void);

  void                               Dump             (std::ostream &oss);
  bool                               Make_points      (const int field, std::vector<Point> &pts);

  std::vector< std::string >         Get_headers      (void);
  bool                               Make_polygons    ( int field, PHAST_polygon &polygons);
  bool                               Point_in_polygon (const Point p);

  // Data
  SHPInfo *                          shpinfo;
  DBFInfo *                          dbfinfo;
  std::vector<SHPObject *>           objects;
  
};
#endif // !defined(SHAPEFILE_H_INCLUDED)
