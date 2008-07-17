#if !defined(PRISM_H_INCLUDED)
#define PRISM_H_INCLUDED
#include "Polyhedron.h"
#include "Data_source.h"

class Prism :
  public Polyhedron
{
  
public:
  Prism(void);
  Prism(const Prism& c);
public:
  ~Prism(void);

  // type enum
  enum PRISM_OPTION
  {
    PERIMETER    = 0,
    DIP          = 1,
    TOP          = 2,
    BOTTOM       = 3,
    PERIMETER_Z  = 4,
    UNITS_TOP    = 5,
    UNITS_BOTTOM = 6,
    UNITS_PERIMETER = 7
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
  struct zone *Set_bounding_box();
  virtual void printOn(std::ostream& os) const;

public:
  // Methods
  bool Read(PRISM_OPTION p_opt, std::istream &lines);
  bool Read(std::istream &lines);
  bool Project_point(Point &p, Cell_Face face, double coord);
  bool Project_points(std::vector<Point> &pts, Cell_Face face, double coord);
  bool Point_in_polyhedron(const Point& p);
  void remove_top_bottom(gpc_polygon *polygon, Cell_Face face, double coord);
  //friend void Tidy_prisms(void);
  void Tidy();
  // data

  gpc_polygon *perimeter_poly; // Not currently used
  Data_source perimeter;
  Point prism_dip;
  double perimeter_datum;
  double orig_perimeter_datum;
  PERIMETER_OPTION perimeter_option;

  Data_source bottom;

  Data_source top;

  
  static std::list<Prism *> prism_list;

};
void Tidy_prisms(void);
#endif // !defined(PRISM_H_INCLUDED)
