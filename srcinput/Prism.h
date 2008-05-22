#if !defined(PRISM_H_INCLUDED)
#define PRISM_H_INCLUDED
#include "polyhedron.h"
#include "Data_source.h"

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
    BOTTOM       = 3,
    PERIMETER_Z  = 4
  };

  enum PERIMETER_OPTION
  {
    CONSTANT       = 0,
    ATTRIBUTE      = 1,
    USE_Z          = 2,
    DEFAULT        = 3
  };

public:
  // Virtual methods
  void Points_in_polyhedron(std::list<int> & list, std::vector<Point> &point_xyz);
  Polyhedron* clone() const;
  Polyhedron* create() const;
  //gpc_polygon *Face_polygon(Cell_Face face);
  gpc_polygon * Slice(Cell_Face face, double coord);
protected:
  // Virtual methods
  struct zone *Bounding_box();
  void printOn(std::ostream& o) const;

public:
  // Methods
  bool read(PRISM_OPTION p_opt, std::istream &lines);
  bool read(std::istream &lines);
  bool Project_point(Point &p, Cell_Face face, double coord);
  bool Project_points(std::vector<Point> &pts, Cell_Face face, double coord);
  friend void tidy_prisms(void);
  void tidy();
  // data

  gpc_polygon *perimeter_poly; // Not currently used
  Data_source perimeter;
  Point prism_dip;
  double perimeter_datum;
  PERIMETER_OPTION perimeter_option;

  Data_source bottom;

  Data_source top;

  
  static std::vector<Prism * > prism_vector;
};
#endif // !defined(PRISM_H_INCLUDED)