#if !defined(DATA_SOURCE_H_INCLUDED)
#define DATA_SOURCE_H_INCLUDED
#include <sstream>
#include <vector>
#include <map>

#include "gpc.h"
#include "PHST_polygon.h"
class Filedata;
class Point;
struct zone;

class Data_source
{
public:
  enum DATA_SOURCE_TYPE
  {
    SHAPE        = 0,
    ARCRASTER    = 1,
    XYZ          = 2,
    CONSTANT     = 3,
    POINTS       = 4,
    NONE         = 5
  };
  Data_source(void);
  bool read(std::istream &lines);
  void init();
  ~Data_source(void);
  void tidy();
  std::vector<Point> & Get_points(void);
  bool Make_polygons();
  //gpc_polygon * Get_polygons();
  Data_source::DATA_SOURCE_TYPE  Get_source_type(void) {return this->source_type;}
  PHST_polygon & Get_polygons(void) {return this->phst_polygons;};
  int Get_attribute(void) {return this->attribute;}
  

  // Data
  bool defined;
  std::string file_name;
  DATA_SOURCE_TYPE source_type;
  Filedata *filedata;
  std::vector<Point> pts;
  //gpc_polygon *polygons;
  PHST_polygon phst_polygons;

  int attribute;
  struct zone box;
  static std::map<std::string,Data_source> data_source_map;
};
#endif // !defined(DATA_SOURCE_H_INCLUDED)