#include "Prism.h"
extern int free_check_null(void *ptr);
Prism::Prism(void)
{
  this->perimeter = NULL;
}

Prism::~Prism(void)
{
  if (this->perimeter != NULL)
  {
    gpc_free_polygon(this->perimeter);
  }
  free_check_null(this->perimeter);
}
bool Prism::read(PRISM_OPTION p_opt, char *next_char)
{

  switch (p_opt)
  {
  case VECTOR:
    break;
  case PERIMETER:
    break;
  case TOP:
    break;
  case BOTTOM:
    break;

  }
  return (true);
}
void Prism::Points_in_polyhedron(std::list<int> & list, std::vector<Point> &point_xyz)
{
}
Polyhedron* Prism::clone()const
{
  return(NULL);
}
Polyhedron* Prism::create() const
{
  return(NULL);
}
gpc_polygon *Prism::Face_polygon(Cell_Face face)
{
  return(NULL);
}
gpc_polygon * Prism::Slice(Cell_Face face, double coord)
{
  return(NULL);
}

struct zone *Prism::Bounding_box()
{
  return(NULL);
}
void Prism::printOn(std::ostream& o) const
{
}