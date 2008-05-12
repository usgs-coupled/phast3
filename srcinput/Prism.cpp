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
bool Prism::read(std::istream &lines)
{
    // read information for top, or bottom
  const char *opt_list[] = {
    "perimeter",                     /* 0 */
    "dip",                           /* 1 */
    "top",                           /* 2 */
    "bottom"                         /* 3 */
  };
  int count_opt_list = 4; 
  std::vector<std::string> std_opt_list;
  int i;
  for (i = 0; i < count_opt_list; i++) std_opt_list.push_back(opt_list[i]);

  // get option
  std::string type;
  lines >> type;
  int j = case_picker(std_opt_list, type);
  PRISM_OPTION p_opt;
  switch (j)
  {
  case 0:
    p_opt = Prism::PERIMETER;
    break;
  case 1:
    p_opt = Prism::DIP;
    break;
  case 2:
    p_opt = Prism::TOP;
    break;
  case 3:
    p_opt = Prism::BOTTOM;
    break;
  default:
    error_msg("Error reading prism data (perimeter, dip, top, bottom).", EA_CONTINUE);
    return(false);
  }
  return(this->read(p_opt, lines));
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

