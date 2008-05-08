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
  enum PRISM_FILE_TYPE
  {
    SHAPE        = 0,
    ARCRASTER    = 1,
    XYZ          = 2,
    NONE         = 3
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
  std::string prism_file;
  gpc_polygon *perimeter;
  Point prism_dip;

  std::string top_file;
  PRISM_FILE_TYPE top_file_type;
  std::vector<Point> top;

  std::string bottom_file;
  PRISM_FILE_TYPE bottom_file_type;
  std::vector<Point> bottom;


  
};
#endif // !defined(PRISM_H_INCLUDED)