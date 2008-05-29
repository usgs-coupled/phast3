#if !defined(POLYHEDRON_H_INCLUDED)
#define POLYHEDRON_H_INCLUDED

#include <vector>   // std::vector
#include <list>     // std::list
#include "Point.h"
#include "zone.h"
#include "Cell_Face.h"

class Polyhedron
{
public:

  // can not instantiate
  Polyhedron(void);

  // destructor
  virtual ~Polyhedron(void);

  // type enum
  enum POLYHEDRON_TYPE
  {
    CUBE         = 0,
    WEDGE        = 1
  };

  // Methods
  virtual void Points_in_polyhedron(std::list<int> & list, std::vector<Point> &point_xyz) = 0;
  virtual Polyhedron* clone() const = 0;
  virtual Polyhedron* create() const = 0;
  //virtual gpc_polygon *Face_polygon(Cell_Face face) = 0;
  virtual gpc_polygon * Slice(Cell_Face face, double coord) = 0;

  struct zone *Get_bounding_box() {return &(this->box);}
  bool Point_in_bounding_box(const Point &pt);
  enum POLYHEDRON_TYPE get_type(void)const;

  friend std::ostream& operator<< (std::ostream& o, const Polyhedron& p);

protected:
  // Methods
  virtual struct zone *Set_bounding_box() = 0;

  // Data
  std::vector<Point> p;
  enum POLYHEDRON_TYPE type;
  struct zone box;
  virtual void printOn(std::ostream& o) const = 0;
};

inline std::ostream& operator<< (std::ostream& o, const Polyhedron& p)
{
  p.printOn(o);
  return o;
}

inline enum Polyhedron::POLYHEDRON_TYPE Polyhedron::get_type(void) const
{
  return type;
}

#endif // !defined(POLYHEDRON_H_INCLUDED)
