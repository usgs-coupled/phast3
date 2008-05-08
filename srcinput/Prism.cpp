#include "Prism.h"
#include "message.h"
#include <sstream>
#include <iostream>
#include <algorithm>
#include "Helpers.h"
Prism::Prism(void)
{
  this->perimeter = NULL;
  this->perimeter_defined = false;
  this->perimeter_file_type = Prism::NONE;

  this->top_defined = false;
  this->top_file_type = Prism::NONE;

  this->bottom_defined = false;
  this->bottom_file_type = Prism::NONE;
}

Prism::~Prism(void)
{
  if (this->perimeter != NULL)
  {
    gpc_free_polygon(this->perimeter);
  }
  free_check_null(this->perimeter);
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
    break;
  case TOP:
    {
      this->top.clear();
      this->top_file.clear();

      const char *opt_list[] = {
      	"constant",                         /* 0 */
	"points",                           /* 1 */
	"shape",                            /* 2 */
	"xyz",                              /* 3 */
	"arcraster"                         /* 4 */
      };
      int count_opt_list = 5; 
      std::vector<std::string> std_opt_list;
      int i;
      for (i = 0; i < count_opt_list; i++) std_opt_list.push_back(opt_list[i]);

      std::string type;
      lines >> type;
      int j = case_picker(std_opt_list, type);
      
      switch (j)
      {
	// constant
      case 0:
	this->top_file_type = Prism::CONSTANT;
	double elev;
	if (!(lines >> elev))
	{
	  error_msg("Error reading constant elevation of prism top.", EA_CONTINUE);
	  success = false;
	} else
	{
	  this->top.push_back(Point(0.0, 0.0, elev));
	  this->top_defined = true;
	}
	break;

	// points
      case 1:
	this->top_file_type = Prism::POINTS;
	{
	  i = 0;
	  Point p;
	  double *coord = p.get_coord();
	  while (lines >> coord[i%3])
	  {
	    if (i%3 == 2) this->top.push_back(p);
	  }
	}
	if (this->top.size() < 3)
	{
	  error_msg("Error reading top of prism, expected at least 3 points.", EA_CONTINUE);
	  success = false;
	} else
	{
	  this->top_defined = true;
	}
	break;

	// Shape file
      case 2:
	this->top_file_type = Prism::SHAPE;
	break;

	// Arc Raster file
      case 3:
	break;

      
      }
     }
    break;
  case BOTTOM:
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

