#if !defined(DATA_SOURCE_H_INCLUDED)
#define DATA_SOURCE_H_INCLUDED
#include <sstream>
#include <vector>
#include <map>

#include "gpc.h"
#include "PHST_polygon.h"
#include "unit_impl.h"
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

// Data read from a file are stored in Filedata
// Data read for CONSTANT and POINTS are stored here in Data_source
// Files:
//   Units are converted for file data in Make_points and Make_polygon
//   Data stored in pts_map and nni_map have had units converted
// CONSTANT and POINTS
//   Units are converted in Data_source::Tidy so that this->pts has been converted.

  void                     Init();
  bool                     Read                   (std::istream &lines);
  void                     Tidy                   (const bool make_nni);
  void                     Add_to_file_map        (Filedata *f, const bool make_nni);
  void                     Add_nni_to_data_source (void);
  bool                     Make_polygons          (void);
  double                   Interpolate            (Point p);
  bool                     Read_units             (std::istream &lines);

  // Getter 
  bool                     Get_defined            (void) {return this->defined;};
  std::vector<Point> &     Get_points             (void);
  DATA_SOURCE_TYPE         Get_source_type        (void) {return this->source_type;}
  int                      Get_attribute          (void) {return this->attribute;}
  PHST_polygon &           Get_phst_polygons      (void) {return this->phst_polygons;};
  struct zone *            Get_bounding_box       (void);
  struct cunit *           Get_v_units            (void) {return &this->v_units;};

  // Setter
  void                     Set_source_type        (DATA_SOURCE_TYPE dt) {this->source_type = dt;};
  void                     Set_bounding_box       (void);
  void                     Set_defined            (bool tf) {this->defined = tf;};

  // Data
protected:
  bool               defined;
  std::string        file_name;
  DATA_SOURCE_TYPE   source_type;
  Filedata *         filedata;
  std::vector<Point> pts;
  PHST_polygon       phst_polygons;
  NNInterpolator *   nni;
  struct cunit       h_units;
  struct cunit       v_units;

  int                attribute;
  struct zone        box;

  // Static
  static std::map<std::string,Data_source> data_source_map;
};
#endif // !defined(DATA_SOURCE_H_INCLUDED)