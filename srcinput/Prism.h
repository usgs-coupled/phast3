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
    BOTTOM       = 3
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
  // Methods
  bool read(PRISM_OPTION p_opt, std::istream &lines);
  bool read(std::istream &lines);

  // data

  gpc_polygon *perimeter_poly;
  Data_source perimeter;

  Data_source bottom;

  Data_source top;

  Point prism_dip;
 
};
#endif // !defined(PRISM_H_INCLUDED)