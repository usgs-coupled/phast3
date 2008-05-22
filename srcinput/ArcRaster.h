#if !defined(ARCRASTER_H_INCLUDED)
#define ARCRASTER_H_INCLUDED
#include "Filedata.h"
#include <string>
#include <vector>
class Point;
class ArcRaster : Filedata
{
public:
  ArcRaster(void);
  ArcRaster(std::string filename);
  //bool Set_points(const int field) {return true;};
  std::vector<Point> &Get_points() {return this->pts;};
  bool Make_points(const int field, std::vector<Point> &pts); 
  bool Make_polygons( int field, PHST_polygon &polygons)  {return false;}
  void Set_bounding_box(void);
  struct zone *Bounding_box(void);
public:
  ~ArcRaster(void);

protected:
  // data
  double cellsize;
  double xllcorner, yllcorner;
  int ncols, nrows;
  double nodata_value;
};
#endif // !defined(ARCRASTER_H_INCLUDED)