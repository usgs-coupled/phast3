#if !defined(FILEDATA_H_INCLUDED)
#define FILEDATA_H_INCLUDED
#include <vector>
class Point;
class NNInterpolator;
#include "zone.h"
#include "gpc.h"
class PHST_polygon;
#include <map>

class Filedata
{
public:
  Filedata(void);
public:
  ~Filedata(void);
  virtual struct zone *Bounding_box() = 0;
  virtual bool Make_points(const int field, std::vector<Point> &pts) = 0;
  virtual bool Make_polygons( int field, PHST_polygon &polygons) = 0;
  std::vector<Point> &Get_points() {return pts;};
  // Data
  struct zone box;
  std::vector<Point> pts;
  //std::map<int, std::vector<Point> > pts_map;
  //std::map<int, std::vector<NNInterpolator *> > nni_map;
  static std::map<std::string,Filedata *> file_data_map;

  friend void Clear_file_data_map(void);
};
#endif // FILEDATA_H_INCLUDED