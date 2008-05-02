#if !defined(EXTERIOR_CELL_H_INCLUDED)
#define EXTERIOR_CELL_H_INCLUDED
#include "gpc.h"
#include "Cell_Face.h"

class Exterior_cell
{
public:
  Exterior_cell(void);
public:
  ~Exterior_cell(void);

  // methods
  void dump();
  gpc_polygon * get_exterior_polygon(Cell_Face face);

  // data
  bool xn, xp, yn, yp, zn, zp;
  double xn_area, xp_area, yn_area, yp_area, zn_area, zp_area;
  gpc_polygon *xn_gon, *xp_gon, *yn_gon, *yp_gon, *zn_gon, *zp_gon;

};

#endif // !defined(EXTERIOR_CELL_H_INCLUDED)
