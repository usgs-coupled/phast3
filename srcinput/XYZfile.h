#if !defined(XYZFILE_H_INCLUDED)
#define XYZFILE_H_INCLUDED
#include "Filedata.h"
#include <string>
#include <vector>
class Point;
class XYZfile : public Filedata
{
public:
  XYZfile(void);
  XYZfile(std::string filename);
  bool                          Make_points(const int field, std::vector<Point> &pts, double h_scale, double v_scale);
  std::vector<Point> &          Get_points(int attribute);
  bool                          Make_polygons( int field, PHST_polygon &polygons, double h_scale, double v_scale);
  //void                          Set_bounding_box(void);
  //struct zone *                 Get_bounding_box(void);
public:
  virtual ~XYZfile(void);

protected:
  // data
};
#endif // !defined(XYZFILE_H_INCLUDED)
