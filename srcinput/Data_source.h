#if !defined(DATA_SOURCE_H_INCLUDED)
#define DATA_SOURCE_H_INCLUDED
#include <sstream>
#include <vector>
#include <map>

#include "gpc.h"
#include "PHST_polygon.h"
#include "unit_impl.h"
#include "Polygon_tree.h"
#include "KDtree/KDtree.h"
#include "PHAST_Transform.h"
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

  Data_source(const Data_source& r);
  
  ~Data_source(void);

// Data read from a file are stored in Filedata
// Data read for CONSTANT and POINTS are stored here in Data_source
// Files:
//   Units are converted for file data in Make_points and Make_polygon
//   Data stored in pts_map and nni_map have had units converted
// CONSTANT and POINTS
//   Units are converted in Data_source::Tidy so that this->pts has been converted.

  void                     Init();
  bool                     Read                   (std::istream &lines, bool read_num);
  void                     Tidy                   (const bool make_nni);
  void                     Add_to_file_map        (Filedata *f, const bool make_nni);
  void                     Add_nni_to_data_source (void);
  bool                     Make_polygons          (void);
  double                   Interpolate            (const Point& p);
  bool                     Read_units             (std::istream &lines);
  static bool              Read_filename          (std::istream &lines, bool read_num, std::string &filename, int &num);
  // Getter 
  bool                     Get_defined            (void) {return this->defined;};
  std::vector<Point> &     Get_points             (void);
  DATA_SOURCE_TYPE         Get_source_type        (void)const {return this->source_type;}
  int                      Get_attribute          (void)const {return this->attribute;}
  PHST_polygon &           Get_phst_polygons      (void) {return this->phst_polygons;};
  struct zone *            Get_bounding_box       (void);
  struct cunit *           Get_h_units            (void) {return &this->h_units;};
  struct cunit *           Get_v_units            (void) {return &this->v_units;};
  Polygon_tree *           Get_tree               (void);
  KDtree *                 Get_tree3d             (void);
  std::string              Get_file_name          (void)const {return this->file_name;};
  Filedata *               Get_filedata           (void)const {return this->filedata;};
  int                      Get_columns            (void)const {return this->columns;};
  // Setter
  void                     Set_source_type        (DATA_SOURCE_TYPE dt) {this->source_type = dt;};
  void                     Set_bounding_box       (void);
  void                     Set_defined            (bool tf) {this->defined = tf;};
  void                     Set_file_name          (std::string fn);
  void                     Set_attribute          (int a) {this->attribute = a;};
  void                     Set_columns            (int i) {this->columns = i;};
  void                     Set_points             (std::vector<Point> pts);
  Data_source &            operator=              (const Data_source& r);

  PHAST_Transform::COORDINATE_SYSTEM   Get_coordinate_system() {return this->coordinate_system;};
  void                                 Set_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM c) {this->coordinate_system = c;};

  friend std::ostream& operator<< (std::ostream &os, const Data_source &ds);

  // Data
protected:
  bool               defined;
  std::string        file_name;
  DATA_SOURCE_TYPE   source_type;
  Filedata *         filedata;
  std::vector<Point> pts;
  PHST_polygon       phst_polygons;
  Polygon_tree       *tree;
  NNInterpolator *   nni;
  struct cunit       h_units;
  struct cunit       v_units;
  KDtree *           tree3d;
  int                columns;
  int                attribute;
  struct zone        box;
  PHAST_Transform::COORDINATE_SYSTEM   coordinate_system;
};

inline KDtree * Data_source::Get_tree3d(void)
{
	if (!this->tree3d)
	{
		// Use points to make 3D tree
		this->tree3d = new KDtree(this->Get_points());

		// No longer need points
		this->pts.clear();
	}
	return this->tree3d;
}
inline Polygon_tree * Data_source::Get_tree(void)
{
  if (!this->tree)
  {
    this->tree = new Polygon_tree(this->Get_phst_polygons());
  }
  return this->tree;
}

#endif // !defined(DATA_SOURCE_H_INCLUDED)
