#include "Prism.h"
#include "Cube.h"
#include "message.h"
#include <sstream>
#include <iostream>
#include <algorithm>
#include "Utilities.h"
#include <assert.h>
std::vector<Prism * > Prism::prism_vector;

Prism::Prism(void)
{
  this->perimeter_poly = NULL;
  this->prism_dip = Point(0,0,0,0);
  this->perimeter_datum = 0.0;
  this->perimeter_option = DEFAULT;
  zone_init(&this->box);
  this->prism_vector.push_back(this);
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
    "bottom",                        /* 3 */
    "vector",                        /* 4 */
    "perimeter_z"                    /* 5 */
  };
  int count_opt_list = 6; 
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
  case 4:
    p_opt = Prism::DIP;
    break;
  case 2:
    p_opt = Prism::TOP;
    break;
  case 3:
    p_opt = Prism::BOTTOM;
    break;
  case 5:
    p_opt = Prism::PERIMETER_Z;
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
  //lines >> token;
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
      if (success)
      {
	if (coord[2] != 0.0)
	{
	  // normalize
	  coord[0] /= coord[2];
	  coord[1] /= coord[2];
	  coord[2] /= coord[2];
	} else 
	{
	  error_msg("Z coordinate of vector for prism must not be zero.", EA_CONTINUE);
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
    if (!this->bottom.read(lines)) error_msg("Reading bottom of prism", EA_CONTINUE);
    break;
  case PERIMETER_Z:
    {
      lines >> token;
      char str[250];
      strcpy(str,token.c_str());
      if (isdigit(str[0]))
      {
	this->perimeter_option = CONSTANT;
	sscanf(str,"%lf", &(this->perimeter_datum));
      } else if (str[0] == 'a')
      {
	this->perimeter_option = ATTRIBUTE;
      } else if (str[0] == 'u')
      {
	this->perimeter_option = USE_Z;
      } else
      {
	error_msg("Reading perimeter_z option.", EA_CONTINUE);
	success = false;
      }
    }
    break;

  }
  return (success);
}
void Prism::Points_in_polyhedron(std::list<int> & list, std::vector<Point> &point_xyz)
{
  // TODO
}

Polyhedron* Prism::clone()const
{
  return new Prism(*this);
}
Polyhedron* Prism::create() const
{
  return new Prism();
}
gpc_polygon * Prism::Slice(Cell_Face face, double coord)
{

  // Determine if dip is parallel to face
  Cube::PLANE_INTERSECTION p_intersection;
  Point p1;
  double t;

  Point lp1, lp2;
  switch (face)
  {
  case CF_X:
    p_intersection = Segment_intersect_plane(1.0, 0.0, 0.0, -coord, p1, this->prism_dip, t);
    lp1 = Point(coord, this->box.y1 - 1, grid_zone()->z2);
    lp2 = Point(coord, this->box.y2 + 1, grid_zone()->z2);
    break;
  case CF_Y:
    p_intersection = Segment_intersect_plane(0.0, 1.0, 0.0, -coord, p1, this->prism_dip, t);
    lp1 = Point(this->box.x1 - 1, coord, grid_zone()->z2);
    lp2 = Point(this->box.x2 + 1, coord, grid_zone()->z2);
    break;
  case CF_Z:
    p_intersection = Segment_intersect_plane(0.0, 0.0, 1.0, -coord, p1, this->prism_dip, t);
    break;
  }


  if (p_intersection == Cube::PI_POINT)
  {
    // Dip of prism is not parallel to face
    std::vector<Point> project;
    std::vector<Point>::iterator it;
    for ( it = this->perimeter.pts.begin(); it != this->perimeter.pts.end(); it++)
    {
      Point p = *it;
      if (!(this->Project_point(p, face, coord)))
      {
	error_msg("Could not project point?", EA_CONTINUE);
      }
      project.push_back(p);
    }
    gpc_polygon *slice = points_to_poly(project);
    return slice;
  } else
  {
    // Dip of prism is parallel to face
    std::vector<Point> intersect_pts;
    gpc_polygon *slice = empty_polygon();
    {
      line_intersect_polygon(lp1, lp2, this->perimeter.pts, intersect_pts);
      int i;
      for (i = 0; i < (int) intersect_pts.size(); i = i + 2)
      {
	// add upper points
	std::vector<Point> pts;
	pts.push_back(Point(pts[i].x(), pts[i].y(), grid_zone()->z2));
	pts.push_back(Point(pts[i+1].x(), pts[i+1].y(), grid_zone()->z2));
	// add lower points
	Point p2;
	p2 = pts[i+1];
	p2.set_z(grid_zone()->z2);
	this->Project_point(p2, face, grid_zone()->z1);
	pts.push_back(p2);


	p2 = pts[i];
	this->Project_point(p2, face, grid_zone()->z1);
	pts.push_back(p2);

	// generate polygon
	gpc_polygon * contour = points_to_poly(pts);

	// add to slice
	gpc_polygon_clip(GPC_UNION, slice, contour, slice);

      }
    }
  }


  return(NULL);
}

struct zone *Prism::Bounding_box()
{
  // TODO
  return(NULL);
}
void Prism::printOn(std::ostream& o) const
{
  // TODO
}

bool Prism::Project_point(Point &p, Cell_Face face, double coord)
{
  bool success = true;
  // Project point to a z plane
  double t;
  Point a;
  a.get_coord()[(int) face] = 1.0;
  if (Segment_intersect_plane(a.x(), a.y(), a.z(), -coord,  p, this->prism_dip, t) == Cube::PI_NONE)
  {
    success = false;
  }
  p = p + t * this->prism_dip;
  return(success);
}
bool Prism::Project_points(std::vector<Point> &pts, Cell_Face face, double coord)
{
  bool success = true;
  std::vector<Point>::iterator it;
  for (it = pts.begin(); it != pts.end(); it++)
  {
    if (!this->Project_point(*it, face, coord)) success = false;
  }
  return(success);
}
void tidy_prisms(void)
{
  std::vector<Prism *>::const_iterator it;

  for (it = Prism::prism_vector.begin(); it != Prism::prism_vector.end(); it++)
  {
   (*it)->tidy();
  }
}

void Prism::tidy()
{
  top.tidy();

  bottom.tidy();

  perimeter.tidy();

  // Make polygons and fix up z for perimeter
  assert(this->perimeter.Make_polygons());
  std::vector<Point>::iterator it;
  switch (this->perimeter_option) 
  {
  case DEFAULT:
    this->perimeter_datum = grid_zone()->z2;
  case CONSTANT:
    {
      this->perimeter.phst_polygons.set_z(this->perimeter_datum);
    }
    break;
  case ATTRIBUTE:
    if (this->perimeter.Get_source_type() != Data_source::ARCRASTER)
    {
      error_msg("Perimeter_z attribute option can only be used with SHAPE files.", EA_CONTINUE);
    } else
    {
      this->perimeter.phst_polygons.set_z_to_v();
    }
    break;
  case USE_Z:
    break;
  }
  // Project points to top of grid
  this->Project_points(this->perimeter.pts, CF_Z, grid_zone()->z2); 
  this->perimeter_datum = grid_zone()->z2;
}