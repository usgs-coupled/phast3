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
  std::vector<Point> &Get_points(const int field) {return this->pts;};
  gpc_polygon *Get_polygons();
  void Set_bounding_box(void);
  struct zone *Bounding_box(void);
public:
  ~ArcRaster(void);

protected:
  // data
  std::vector<Point> pts;
  double cellsize;
  double xllcorner, yllcorner;
  int ncols, nrows;
  double nodata_value;
};
#endif // !defined(ARCRASTER_H_INCLUDED)