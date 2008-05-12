#include "Prism.h"
#include "message.h"
#include <sstream>
#include <iostream>
#include <algorithm>
#include "Helpers.h"
Prism::Prism(void)
{
  this->perimeter_poly = NULL;
}

Prism::~Prism(void)
{
  if (this->perimeter_poly != NULL)
  {
    gpc_free_polygon(this->perimeter_poly);
  }
  free_check_null(this->perimeter_poly);
}

bool Prism::read(PRISM_OPTION p_opt, std::istream &lines)
{
  std::string token;
  // identifier
  lines >> token;
  bool success = true;
  switch (p_opt)
  {
  case DIP:
    {
      double *coord = this->prism_dip.get_coord();
      int i;
      for (i = 0; i < 3; i++)
      {
	if (!(lines >> coord[i]))
	{
	  error_msg("Error reading dip of prism.", EA_CONTINUE);
	  success = false;
	}
      }
    }
    break;
  case PERIMETER:
    if (!this->perimeter.read(lines)) 
    {
      error_msg("Reading perimeter of prism", EA_CONTINUE);
    } else if (this->perimeter.source_type != Data_source::POINTS &&
      this->perimeter.source_type != Data_source::SHAPE)
    {
      error_msg("Perimeter must be either points or a shape file", EA_CONTINUE);
    } else if (this->perimeter.source_type == Data_source::POINTS && this->perimeter.pts.size() < 3)
    {
      error_msg("Perimeter must be defined by at least 3 points.", EA_CONTINUE);
    }
    break;
  case TOP:
    if (!this->top.read(lines)) error_msg("Reading top of prism", EA_CONTINUE);
    break;
  case BOTTOM:
    if (!this->top.read(lines)) error_msg("Reading top of prism", EA_CONTINUE);
    break;

  }
  return (success);
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

