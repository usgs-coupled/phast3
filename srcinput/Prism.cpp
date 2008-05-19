#include "Prism.h"
#include "Cube.h"
#include "message.h"
#include <sstream>
#include <iostream>
#include <algorithm>
#include "Utilities.h"
Prism::Prism(void)
{
  this->perimeter_poly = NULL;
  this->prism_dip = Point(0,0,0,0);
  zone_init(&this->box);
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
    "vector"                         /* 4 */
  };
  int count_opt_list = 5; 
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
//gpc_polygon *Prism::Face_polygon(Cell_Face face)
//{
//  return(NULL);
//}
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
  return(NULL);
}
void Prism::printOn(std::ostream& o) const
{
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