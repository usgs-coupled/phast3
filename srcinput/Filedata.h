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
  enum FILE_TYPE
  {
    SHAPE        = 0,
    ARCRASTER    = 1,
    XYZ          = 2,
    NONE         = 3
  };

  Filedata(void);
public:
  ~Filedata(void);
  virtual struct zone *Get_bounding_box() = 0;
  virtual bool Make_points(const int field, std::vector<Point> &pts) = 0;
  virtual bool Make_polygons( int field, PHST_polygon &polygons) = 0;
  virtual std::vector<Point> &Get_points(int attribute) = 0; 
  void set_file_type(FILE_TYPE ft) {this->file_type = ft;};
  FILE_TYPE get_file_type(void) {return this->file_type;};
  std::map<int, NNInterpolator *> &get_nni_map() {return this->nni_map;};
  std::map<int, std::vector<Point> > &get_pts_map() {return this->pts_map;};
  friend void Clear_file_data_map(void);

  // data
  static std::map<std::string,Filedata *> file_data_map;

protected:
  // Data
  struct zone box;
  FILE_TYPE file_type;
  //std::vector<Point> pts;
  std::map<int, std::vector<Point> > pts_map;
  std::map<int, NNInterpolator *> nni_map;

};
#endif // FILEDATA_H_INCLUDED