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
  std::vector<Point> &Get_points(const int field) {return this->pts;};
  gpc_polygon *Get_polygons();
  void Set_bounding_box(void);
  struct zone *Bounding_box(void);
public:
  ~XYZfile(void);

protected:
  // data
  std::vector<Point> pts;
  gpc_polygon * polygons;
};
#endif // !defined(XYZFILE_H_INCLUDED)