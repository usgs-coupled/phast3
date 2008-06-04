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
  virtual ~Filedata(void);
  //virtual struct zone *                Get_bounding_box() = 0;
  virtual bool                         Make_points(const int field, std::vector<Point> &pts, double h_scale, double v_scale) = 0;
  virtual bool                         Make_polygons( int field, PHST_polygon &polygons, double h_scale, double v_scale) = 0;
  virtual std::vector<Point> &         Get_points(int attribute) = 0; 
  void                                 Set_file_type(FILE_TYPE ft) {this->file_type = ft;};
  FILE_TYPE                            Get_file_type(void) {return this->file_type;};
  std::map<int, NNInterpolator *> &    Get_nni_map() {return this->nni_map;};
  std::map<int, std::vector<Point> > & Get_pts_map() {return this->pts_map;};
  friend void                          Clear_file_data_map(void);

  // data
  static std::map<std::string,Filedata *> file_data_map;

protected:
  // Data
  // Because units may be converted, the Filedata does not have a bounding box
  // Data_source has the bounding box information 

  FILE_TYPE                            file_type;

  // Units have been converted in pts_map and nni_map
  std::map<int, std::vector<Point> >   pts_map;
  std::map<int, NNInterpolator *>      nni_map;

};
#endif // FILEDATA_H_INCLUDED