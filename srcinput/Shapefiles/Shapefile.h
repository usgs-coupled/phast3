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
  // constructors
  Shapefile(void);
  Shapefile(std::string &fname);

  // destructor
  ~Shapefile(void);

  void                               Dump             (std::ostream &oss);
  bool                               Make_points      (const int field, std::vector<Point> &pts, double h_scale, double v_scale);
  std::vector<Point> &               Get_points       (int attribute);
  bool                               Make_polygons    ( int field, PHST_polygon &polygons, double h_scale, double v_scale);
  bool                               Point_in_polygon (const Point p);
  //struct zone *                      Get_bounding_box (void);
  //void                               Set_bounding_box (void);


  // Data
  SHPInfo *                          shpinfo;
  DBFInfo *                          dbfinfo;
  std::vector<SHPObject *>           objects;
  
};
#endif // !defined(SHAPEFILE_H_INCLUDED)
