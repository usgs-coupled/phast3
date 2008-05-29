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
class NNInterpolator;

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
  
  
  ~Data_source(void);


  void init();
  bool Read(std::istream &lines);
  void Tidy(const bool make_nni);
  void Add_to_file_map (Filedata *f, const bool make_nni);
  void Add_nni_to_data_source (void);
  bool Make_polygons();
  double Interpolate(Point p);

  // Getter 
  bool Get_defined(void) {return this->defined;};
  std::vector<Point> & Get_points(void);
  DATA_SOURCE_TYPE  Get_source_type(void) {return this->source_type;}
  int Get_attribute(void) {return this->attribute;}
  PHST_polygon & Get_phst_polygons(void) {return this->phst_polygons;};
  struct zone *Get_bounding_box();

  // Setter
  void Set_source_type(DATA_SOURCE_TYPE dt) {this->source_type = dt;};
  void Set_bounding_box(void);
  void Set_defined(bool tf) {this->defined = tf;};

  // Data
protected:
  bool defined;
  std::string file_name;
  DATA_SOURCE_TYPE source_type;
  Filedata *filedata;
  std::vector<Point> pts;
  //gpc_polygon *polygons;
  PHST_polygon phst_polygons;
  NNInterpolator *nni;

  int attribute;
  struct zone box;
  static std::map<std::string,Data_source> data_source_map;
};
#endif // !defined(DATA_SOURCE_H_INCLUDED)