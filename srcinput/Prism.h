#if !defined(PRISM_H_INCLUDED)
#define PRISM_H_INCLUDED
#include "polyhedron.h"

class Prism :
  public Polyhedron
{
public:
  Prism(void);
public:
  ~Prism(void);

  // type enum
  enum PRISM_OPTION
  {
    PERIMETER    = 0,
    DIP          = 1,
    TOP          = 2,
    BOTTOM       = 3
  };
  enum PRISM_DATA_TYPE
  {
    SHAPE        = 0,
    ARCRASTER    = 1,
    XYZ          = 2,
    CONSTANT     = 3,
    POINTS       = 4,
    NONE         = 5
  };
public:
  // Virtual methods
  void Points_in_polyhedron(std::list<int> & list, std::vector<Point> &point_xyz);
  Polyhedron* clone() const;
  Polyhedron* create() const;
  gpc_polygon *Face_polygon(Cell_Face face);
  gpc_polygon * Slice(Cell_Face face, double coord);
protected:
  // Virtual methods
  struct zone *Bounding_box();
  void printOn(std::ostream& o) const;
public:
  // Mthods
  bool read(PRISM_OPTION p_opt, std::istream &lines);

  // data
  bool perimeter_defined;
  std::string perimeter_file;
  PRISM_DATA_TYPE perimeter_file_type;
  gpc_polygon *perimeter;

  bool top_defined;
  std::string top_file;
  PRISM_DATA_TYPE top_file_type;
  std::vector<Point> top;

  bool bottom_defined;
  std::string bottom_file;
  PRISM_DATA_TYPE bottom_file_type;
  std::vector<Point> bottom;

  Point prism_dip;


  
};
#endif // !defined(PRISM_H_INCLUDED)