#if !defined(ARCRASTER_H_INCLUDED)
#define ARCRASTER_H_INCLUDED
#include "Filedata.h"
#include <string>
#include <vector>
class Point;
class ArcRaster : public Filedata
{
public:
  ArcRaster(void);
  ArcRaster(std::string filename);
  bool                     Make_points(const int field, std::vector<Point> &pts, double h_scale, double v_scale); 
  bool                     Make_polygons( int field, PHST_polygon &polygons, double h_scale, double v_scale)  {return false;}
  std::vector<Point> &     Get_points(int attribute);
  //void Set_bounding_box(void);
  //struct zone *Get_bounding_box(void);
public:
  virtual ~ArcRaster(void);

protected:
  // data
  double cellsize;
  double xllcorner, yllcorner;
  int ncols, nrows;
  double nodata_value;
};
#endif // !defined(ARCRASTER_H_INCLUDED)