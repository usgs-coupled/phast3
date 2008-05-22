#if !defined(XYZFILE_H_INCLUDED)
#define XYZFILE_H_INCLUDED
#include "Filedata.h"
#include <string>
#include <vector>
class Point;
class XYZfile : Filedata
{
public:
  XYZfile(void);
  XYZfile(std::string filename);
  //bool Set_points(const int field) {return true;}
  bool Make_points(const int field, std::vector<Point> &pts);
  std::vector<Point> &Get_points() {return this->pts;};
  bool Make_polygons( int field, PHST_polygon &polygons);
  void Set_bounding_box(void);
  struct zone *Bounding_box(void);
public:
  ~XYZfile(void);

protected:
  // data
};
#endif // !defined(XYZFILE_H_INCLUDED)