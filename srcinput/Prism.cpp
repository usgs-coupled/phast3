#include "Prism.h"
#include "message.h"
#include <sstream>
#include <iostream>
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
      std::string type;
      lines >> type;

      
      if (strstr(type.c_str(), "const") == type.c_str())
	// constant
      {
	double elev;
	if (!(lines >> elev))
	{
	  error_msg("Error reading constant elevation of prism top.", EA_CONTINUE);
	  success = false;
	} else
	{
	  this->top.push_back(Point(0.0, 0.0, elev));
	}

      } else if (strstr(type.c_str(), "point") == type.c_str())
	// points
      {
	int i = 0;
	Point p;
	double *coord = p.get_coord();
	while (lines >> coord[i%3])
	{
	  if (i%3 == 2) this->top.push_back(p);
	}
	if (this->top.size() < 3)
	{
	  error_msg("Error reading top of prism, expected at least 3 points.", EA_CONTINUE);
	  success = false;
	}
      } else if (strstr(type.c_str(), "shape") == type.c_str())
      {
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