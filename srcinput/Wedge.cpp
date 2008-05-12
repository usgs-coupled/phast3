#include "Wedge.h"
#include <algorithm>
#include <cctype>
#include "message.h"
#include "gpc.h"
#include "Helpers.h"
// Constructors

Wedge::Wedge(void)
{
  this->type = WEDGE;

  // Default wedge
  this->p.push_back(Point(0.0, 0.0, 0.0));
  this->p.push_back(Point(1.0, 1.0, 1.0));

    // set 8 vertices of cube
  std::vector<Point> v;
  // counter clockwise at low z
  v.push_back(Point(p[0].x(), p[0].y(), p[0].z()));
  v.push_back(Point(p[1].x(), p[0].y(), p[0].z()));
  v.push_back(Point(p[1].x(), p[1].y(), p[0].z()));
  v.push_back(Point(p[0].x(), p[1].y(), p[0].z()));
  // counter clockwise at high z
  v.push_back(Point(p[0].x(), p[0].y(), p[1].z()));
  v.push_back(Point(p[1].x(), p[0].y(), p[1].z()));
  v.push_back(Point(p[1].x(), p[1].y(), p[1].z()));
  v.push_back(Point(p[0].x(), p[1].y(), p[1].z()));

  // Set default X1 wedge
  this->orientation = X1;
  this->wedge_axis = CF_X;
  this->wedge_number = 1;
  // start with right angle
  this->vertices.push_back(v[0]);
  this->vertices.push_back(v[4]);
  this->vertices.push_back(v[3]);
  this->vertices.push_back(v[1]);
  this->vertices.push_back(v[5]);
  this->vertices.push_back(v[2]);
}

Wedge::Wedge(const struct zone *zone_ptr, std::string &orientation)
{
  this->type = WEDGE;

  this->p.clear();
  // Put points in standard form
  this->p.push_back(Point(zone_ptr->x1, zone_ptr->y1, zone_ptr->z1));
  this->p.push_back(Point(zone_ptr->x2, zone_ptr->y2, zone_ptr->z2));

  Point mn( this->p.begin(), this->p.end(), Point::MIN);
  Point mx( this->p.begin(), this->p.end(), Point::MAX);

  this->p.clear();
  this->p.push_back(mn);
  this->p.push_back(mx);

  // set bounding box
  this->Bounding_box();

  // set 8 vertices of cube
  std::vector<Point> v;
  // counter clockwise at low z
  v.push_back(Point(p[0].x(), p[0].y(), p[0].z()));
  v.push_back(Point(p[1].x(), p[0].y(), p[0].z()));
  v.push_back(Point(p[1].x(), p[1].y(), p[0].z()));
  v.push_back(Point(p[0].x(), p[1].y(), p[0].z()));
  // counter clockwise at high z
  v.push_back(Point(p[0].x(), p[0].y(), p[1].z()));
  v.push_back(Point(p[1].x(), p[0].y(), p[1].z()));
  v.push_back(Point(p[1].x(), p[1].y(), p[1].z()));
  v.push_back(Point(p[0].x(), p[1].y(), p[1].z()));

  std::string orient(orientation);
  std::transform(orient.begin(), orient.end(), orient.begin(),
                (int(*)(int)) std::toupper);
  if (orient.compare("X1") == 0)
  {
    this->orientation = X1;
    this->wedge_axis = CF_X;
    this->wedge_number = 1;
    // start with right angle
    this->vertices.push_back(v[0]);
    this->vertices.push_back(v[4]);
    this->vertices.push_back(v[3]);
    this->vertices.push_back(v[1]);
    this->vertices.push_back(v[5]);
    this->vertices.push_back(v[2]);
  } else if (orient.compare("X2") == 0)
  {
    this->orientation = X2;
    this->wedge_axis = CF_X;
    this->wedge_number = 2;
    // start with right angle
    this->vertices.push_back(v[4]);
    this->vertices.push_back(v[7]);
    this->vertices.push_back(v[0]);
    this->vertices.push_back(v[5]);
    this->vertices.push_back(v[6]);
    this->vertices.push_back(v[1]);
  } else if (orient.compare("X3") == 0)
  {
    this->orientation = X3;
    this->wedge_axis = CF_X;
    this->wedge_number = 3;
    // start with right angle
    this->vertices.push_back(v[7]);
    this->vertices.push_back(v[3]);
    this->vertices.push_back(v[4]);
    this->vertices.push_back(v[6]);
    this->vertices.push_back(v[2]);
    this->vertices.push_back(v[5]);
  } else if (orient.compare("X4") == 0)
  {
    this->orientation = X4;
    this->wedge_axis = CF_X;
    this->wedge_number = 4;
    // start with right angle
    this->vertices.push_back(v[3]);
    this->vertices.push_back(v[0]);
    this->vertices.push_back(v[7]);
    this->vertices.push_back(v[2]);
    this->vertices.push_back(v[1]);
    this->vertices.push_back(v[6]);
  } else if (orient.compare("Y1") == 0)
  {
    this->orientation = Y1;
    this->wedge_axis = CF_Y;
    this->wedge_number = 1;
    // start with right angle
    this->vertices.push_back(v[0]);
    this->vertices.push_back(v[1]);
    this->vertices.push_back(v[4]);
    this->vertices.push_back(v[3]);
    this->vertices.push_back(v[2]);
    this->vertices.push_back(v[7]);
  } else if (orient.compare("Y2") == 0)
  {
    this->orientation = Y2;
    this->wedge_axis = CF_Y;
    this->wedge_number = 2;
    // start with right angle
    this->vertices.push_back(v[1]);
    this->vertices.push_back(v[5]);
    this->vertices.push_back(v[0]);
    this->vertices.push_back(v[2]);
    this->vertices.push_back(v[6]);
    this->vertices.push_back(v[3]);
  } else if (orient.compare("Y3") == 0)
  {
    this->orientation = Y3;
    this->wedge_axis = CF_Y;
    this->wedge_number = 3;
    // start with right angle
    this->vertices.push_back(v[5]);
    this->vertices.push_back(v[4]);
    this->vertices.push_back(v[1]);
    this->vertices.push_back(v[6]);
    this->vertices.push_back(v[7]);
    this->vertices.push_back(v[2]);
  } else if (orient.compare("Y4") == 0)
  {
    this->orientation = Y4;
    this->wedge_axis = CF_Y;
    this->wedge_number = 4;
    // start with right angle
    this->vertices.push_back(v[4]);
    this->vertices.push_back(v[0]);
    this->vertices.push_back(v[5]);
    this->vertices.push_back(v[7]);
    this->vertices.push_back(v[3]);
    this->vertices.push_back(v[6]);
  } else if (orient.compare("Z1") == 0)
  {
    this->orientation = Z1;
    this->wedge_axis = CF_Z;
    this->wedge_number = 1;
    // start with right angle
    this->vertices.push_back(v[0]);
    this->vertices.push_back(v[3]);
    this->vertices.push_back(v[1]);
    this->vertices.push_back(v[4]);
    this->vertices.push_back(v[7]);
    this->vertices.push_back(v[5]);
  } else if (orient.compare("Z2") == 0)
  {
    this->orientation = Z2;
    this->wedge_axis = CF_Z;
    this->wedge_number = 2;
    // start with right angle
    this->vertices.push_back(v[3]);
    this->vertices.push_back(v[2]);
    this->vertices.push_back(v[0]);
    this->vertices.push_back(v[7]);
    this->vertices.push_back(v[6]);
    this->vertices.push_back(v[4]);
  } else if (orient.compare("Z3") == 0)
  {
    this->orientation = Z3;
    this->wedge_axis = CF_Z;
    this->wedge_number = 3;
    // start with right angle
    this->vertices.push_back(v[2]);
    this->vertices.push_back(v[1]);
    this->vertices.push_back(v[3]);
    this->vertices.push_back(v[6]);
    this->vertices.push_back(v[5]);
    this->vertices.push_back(v[7]);
  } else if (orient.compare("Z4") == 0)
  {
    this->orientation = Z4;
    this->wedge_axis = CF_Z;
    this->wedge_number = 4;
    // start with right angle
    this->vertices.push_back(v[1]);
    this->vertices.push_back(v[0]);
    this->vertices.push_back(v[2]);
    this->vertices.push_back(v[5]);
    this->vertices.push_back(v[4]);
    this->vertices.push_back(v[6]);
  } else
  {
    this->orientation = WEDGE_ERROR;
    this->wedge_number = CF_UNKNOWN;
    std::ostringstream estring;
    estring << "Unknown wedge orientation " << orientation.c_str() << std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
  }
}

// Destructor
Wedge::~Wedge(void)
{
}

// Methods
bool Wedge::Point_in_polyhedron(Point &t)
{
  // compare to bounding box
  if (!this->Point_in_bounding_box(t)) return false;

  // Project point to front, left, or lower triangular face
  Point test_pt = t;
  struct zone *zo = this->Get_box();
  switch (this->wedge_axis)
  {
  case CF_X:
    test_pt.set_x(zo->x1);
    break;
  case CF_Y:
    test_pt.set_y(zo->y1);
    break;
  case CF_Z:
    test_pt.set_z(zo->z1);
    break;
  default:
    std::ostringstream estring;
    estring << "Wrong face defined in Wedge::Point_in_polyhedron" << std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
    break;
  }

  // Check if point is in triangle (first 3 point of vertices)
  return (test_pt.point_in_polygon(this->vertices.begin(), this->vertices.begin() + 3));

}

void Wedge::Points_in_polyhedron(std::list<int> & list_of_numbers, std::vector<Point> &node_xyz)
{
  std::list<int>::iterator it = list_of_numbers.begin();
  while (it != list_of_numbers.end())
  {
    int n = *it;
    if (this->Point_in_polyhedron(node_xyz[n]) == false)
    {
      it = list_of_numbers.erase(it);
    }
    else
    {
      it++;
    }
  }
  return;
}
#ifdef SKIP
gpc_polygon * Wedge::Face_polygon(Cell_Face face)
{
  gpc_polygon *poly_ptr;
  struct zone *zone_ptr = this->Get_box();
  switch (face)
  {
  case CF_X:
    if (this->wedge_axis == CF_X)
    {
      poly_ptr = triangle(
	this->vertices[0].y(), this->vertices[0].z(),
	this->vertices[1].y(), this->vertices[1].z(),
	this->vertices[2].y(), this->vertices[2].z());
    } else
    {
      poly_ptr = rectangle(zone_ptr->y1, zone_ptr->z1, zone_ptr->y2, zone_ptr->z2);
    }
    break;
  case CF_Y:
    if (this->wedge_axis == CF_Y)
    {
      poly_ptr = triangle(
	this->vertices[0].x(), this->vertices[0].z(),
	this->vertices[1].x(), this->vertices[1].z(),
	this->vertices[2].x(), this->vertices[2].z());
    } else
    {
      poly_ptr = rectangle(zone_ptr->x1, zone_ptr->z1, zone_ptr->x2, zone_ptr->z2);
    }
    break;
  case CF_Z:
    if (this->wedge_axis == CF_Z)
    {
      poly_ptr = triangle(
	this->vertices[0].x(), this->vertices[0].y(),
	this->vertices[1].x(), this->vertices[1].y(),
	this->vertices[2].x(), this->vertices[2].y());
    } else
    {
      poly_ptr = rectangle(zone_ptr->x1, zone_ptr->y1, zone_ptr->x2, zone_ptr->y2);
    }
    break;
  default:
    std::ostringstream estring;
    estring << "Error in Wedge::face_polygon" << std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
  }
  return(poly_ptr);
}
#endif
gpc_polygon * Wedge::Slice(Cell_Face face, double coord)
{


  // Generates a new gpc_polygon
  gpc_polygon *tri, *rect, *result, *slice;
  tri = rect = result = slice = NULL;
  struct zone *zone_ptr = this->Get_box();
  struct zone slice_zone;

  switch (this->wedge_axis)
  {
  case CF_X: // Wedge direction
    if (coord < zone_ptr->x1 || coord > zone_ptr->x2) return(NULL);
    tri = triangle(
      this->vertices[0].y(), this->vertices[0].z(),
      this->vertices[1].y(), this->vertices[1].z(),
      this->vertices[2].y(), this->vertices[2].z());
    switch (face )
    {
    case CF_X: // Slice direction
      // slice is triangle
      slice = gpc_polygon_duplicate(tri);
      break;
    case CF_Y:
      {
	// Wedge X, Intersect at Y = coord, use y, z, calculating z values
	std::vector<double> z;

	// no intersection area
	if (coord <= zone_ptr->y1 ) 
	{
	  break;
	}
	rect = rectangle(zone_ptr->y1, zone_ptr->z1, coord, zone_ptr->z2);
	result = empty_polygon();
	gpc_polygon_clip(GPC_INT, tri, rect, result);

	// Deal with results
	if (result->contour != NULL && result->contour->vertex != NULL)
	{
	  int i;
	  for (i = 0; i < result->contour->num_vertices; i++)
	  {
	    if (result->contour->vertex[i].x == coord)
	    {
	      z.push_back(result->contour->vertex[i].y);
	    }
	  }
	  if (z.size() < 2)
	  {
	    slice = empty_polygon();
	  } else if (z.size() == 2)
	  {
	    // Wedge X, Y intersection plane, use x, calculated z
	    slice = rectangle(zone_ptr->x1, z[0], zone_ptr->x2, z[1]);
	    slice_zone.x1 = zone_ptr->x1;
	    slice_zone.y1 = coord;
	    slice_zone.z1 = z[0];
	    slice_zone.x2 = zone_ptr->x2;
	    slice_zone.y2 = coord;
	    slice_zone.z2 = z[1];
	  } else
	  {
	    std::ostringstream estring;
	    estring << "Error in Wedge::Slice 1" << std::endl;
	    error_msg(estring.str().c_str(), EA_STOP);
	  }
	} else
	{
	  std::ostringstream estring;
	  estring << "Error in Wedge::Slice 2" << std::endl;
	  error_msg(estring.str().c_str(), EA_STOP);
	}
      }
      break;
    case CF_Z: // Slice direction
      {
	// Wedge X, Intersect at z = coord, use y, z, calculating y values
	std::vector<double> y;

	// no intersection area
	if (coord <= zone_ptr->z1 ) 
	{
	  break;
	}
	rect = rectangle(zone_ptr->y1, zone_ptr->z1, zone_ptr->y2, coord);
	result = empty_polygon();
	gpc_polygon_clip(GPC_INT, tri, rect, result);

	// Deal with results
	if (result->contour != NULL && result->contour->vertex != NULL)
	{
	  int i;
	  for (i = 0; i < result->contour->num_vertices; i++)
	  {
	    if (result->contour->vertex[i].y == coord)
	    {
	      y.push_back(result->contour->vertex[i].x);
	    }
	  }
	  if (y.size() < 2)
	  {
	    slice = empty_polygon();
	  } else if (y.size() == 2)
	  {
	    // Wedge X, Z intersection plane, use x, calculated y
	    slice = rectangle(zone_ptr->x1, y[0], zone_ptr->x2, y[1]);
	    slice_zone.x1 = zone_ptr->x1;
	    slice_zone.y1 = y[0];
	    slice_zone.z1 = coord;
	    slice_zone.x2 = zone_ptr->x2;
	    slice_zone.y2 = y[1];
	    slice_zone.z2 = coord;
	  } else
	  {
	    std::ostringstream estring;
	    estring << "Error in Wedge::Slice 3" << std::endl;
	    error_msg(estring.str().c_str(), EA_STOP);
	  }
	} else
	{
	  std::ostringstream estring;
	  estring << "Error in Wedge::Slice 4" << std::endl;
	  error_msg(estring.str().c_str(), EA_STOP);
	}
      }
      break;
    default:
      std::ostringstream estring;
      estring << "Wrong face defined in Wedge::Slice" << std::endl;
      error_msg(estring.str().c_str(), EA_STOP);
      break;

    } // end of Wedge direction CF_X
    break;

  case CF_Y: // Wedge direction
    if (coord < zone_ptr->y1 || coord > zone_ptr->y2) return(NULL);
    tri = triangle(
      this->vertices[0].x(), this->vertices[0].z(),
      this->vertices[1].x(), this->vertices[1].z(),
      this->vertices[2].x(), this->vertices[2].z());
    switch (face )
    {
    case CF_X: // Slice direction
      {
	// Wedge Y, Intersect at x = coord, use x, z, calculating z values
	std::vector<double> z;

	// no intersection area
	if (coord <= zone_ptr->x1 ) 
	{
	  break;
	}
	rect = rectangle(zone_ptr->x1, zone_ptr->z1, coord, zone_ptr->z2);
	result = empty_polygon();
	gpc_polygon_clip(GPC_INT, tri, rect, result);

	// Deal with results
	if (result->contour != NULL && result->contour->vertex != NULL)
	{
	  int i;
	  for (i = 0; i < result->contour->num_vertices; i++)
	  {
	    if (result->contour->vertex[i].x == coord)
	    {
	      z.push_back(result->contour->vertex[i].y);
	    }
	  }
	  if (z.size() < 2)
	  {
	    slice = empty_polygon();
	  } else if (z.size() == 2)
	  {
	    // Wedge Y, X intersection plane, use y, calculated z
	    slice = rectangle(zone_ptr->y1, z[0], zone_ptr->y2, z[1]);
	    slice_zone.x1 = coord;
	    slice_zone.y1 = zone_ptr->y1;
	    slice_zone.z1 = z[0];
	    slice_zone.x2 = coord;
	    slice_zone.y2 = zone_ptr->y2;
	    slice_zone.z2 = z[1];
	  } else
	  {
	    std::ostringstream estring;
	    estring << "Error in Wedge::Slice 5" << std::endl;
	    error_msg(estring.str().c_str(), EA_STOP);
	  }
	} else
	{
	  std::ostringstream estring;
	  estring << "Error in Wedge::Slice 6" << std::endl;
	  error_msg(estring.str().c_str(), EA_STOP);
	}
      }
      break;
    case CF_Y:
      // slice is triangle
      slice = gpc_polygon_duplicate(tri);
      break;

    case CF_Z: // Slice direction
      {
	// Wedge Y, Intersect at z = coord, use x, z, calculating x values
	std::vector<double> x;

	// no intersection area
	if (coord <= zone_ptr->z1 ) 
	{
	  break;
	}

	rect = rectangle(zone_ptr->x1, zone_ptr->z1, zone_ptr->x2, coord);
	result = empty_polygon();
	gpc_polygon_clip(GPC_INT, tri, rect, result);

	// Deal with results
	if (result->contour != NULL && result->contour->vertex != NULL)
	{
	  int i;
	  for (i = 0; i < result->contour->num_vertices; i++)
	  {
	    if (result->contour->vertex[i].y == coord)
	    {
	      x.push_back(result->contour->vertex[i].x);
	    }
	  }
	  if (x.size() < 2)
	  {
	    slice = empty_polygon();
	  } else if (x.size() == 2)
	  {
	    // Wedge Y, Z intersection plane, use y, calculated x
	    slice = rectangle(x[0], zone_ptr->y1, x[1], zone_ptr->y2);
	    slice_zone.x1 = x[0];
	    slice_zone.y1 = zone_ptr->y1;
	    slice_zone.z1 = coord;
	    slice_zone.x2 = x[1];
	    slice_zone.y2 = zone_ptr->y2;
	    slice_zone.z2 = coord;
	  } else
	  {
	    std::ostringstream estring;
	    estring << "Error in Wedge::Slice 7" << std::endl;
	    error_msg(estring.str().c_str(), EA_STOP);
	  }
	} else
	{
	  std::ostringstream estring;
	  estring << "Error in Wedge::Slice 8" << std::endl;
	  error_msg(estring.str().c_str(), EA_STOP);
	}
      }
      break;
    default:
      std::ostringstream estring;
      estring << "Wrong face defined in Wedge::Slice" << std::endl;
      error_msg(estring.str().c_str(), EA_STOP);
      break;
    } // end of Wedge direction CF_Y
    break;

  case CF_Z: // Wedge direction
    if (coord < zone_ptr->z1 || coord > zone_ptr->z2) return(NULL);
    tri = triangle(
      this->vertices[0].x(), this->vertices[0].y(),
      this->vertices[1].x(), this->vertices[1].y(),
      this->vertices[2].x(), this->vertices[2].y());
    switch (face )
    {
    case CF_X: // Slice direction
      {
	// Wedge Z, Intersect at x = coord, use x, y, calculating y values
	std::vector<double> y;

	// no intersection area
	if (coord <= zone_ptr->x1 ) 
	{
	  break;
	}
	rect = rectangle(zone_ptr->x1, zone_ptr->y1, coord, zone_ptr->y2);
	result = empty_polygon();
	gpc_polygon_clip(GPC_INT, tri, rect, result);

	// Deal with results
	if (result->contour != NULL && result->contour->vertex != NULL)
	{
	  int i;
	  for (i = 0; i < result->contour->num_vertices; i++)
	  {
	    if (result->contour->vertex[i].x == coord)
	    {
	      y.push_back(result->contour->vertex[i].y);
	    }
	  }
	  if (y.size() < 2)
	  {
	    slice = empty_polygon();
	  } else if (y.size() == 2)
	  {
	    // Wedge Z, X intersection plane, use z, calculated y
	    slice = rectangle(y[0], zone_ptr->z1, y[1], zone_ptr->z2);
	    slice_zone.x1 = coord;
	    slice_zone.y1 = y[0];
	    slice_zone.z1 = zone_ptr->z1;
	    slice_zone.x2 = coord;
	    slice_zone.y2 = y[1];
	    slice_zone.z2 = zone_ptr->z2;
	  } else
	  {
	    std::ostringstream estring;
	    estring << "Error in Wedge::Slice 9" << std::endl;
	    error_msg(estring.str().c_str(), EA_STOP);
	  }
	} else
	{
	  std::ostringstream estring;
	  estring << "Error in Wedge::Slice 10" << std::endl;
	  error_msg(estring.str().c_str(), EA_STOP);
	}
      }
      break;

    case CF_Y: // Slice direction
      {
	// Wedge Z, Intersect at y = coord, use x, y, calculating x values
	std::vector<double> x;

	// no intersection area
	if (coord <= zone_ptr->y1 ) 
	{
	  break;
	}
	rect = rectangle(zone_ptr->x1, zone_ptr->y1, zone_ptr->x2, coord);
	result = empty_polygon();
	gpc_polygon_clip(GPC_INT, tri, rect, result);

	// Deal with results
	if (result->contour != NULL && result->contour->vertex != NULL)
	{
	  int i;
	  for (i = 0; i < result->contour->num_vertices; i++)
	  {
	    if (result->contour->vertex[i].y == coord)
	    {
	      x.push_back(result->contour->vertex[i].x);
	    }
	  }
	  if (x.size() < 2)
	  {
	    slice = empty_polygon();
	  } else if (x.size() == 2)
	  {
	    // Wedge Z, Y intersection plane, use z, calculated x
	    slice = rectangle(x[0], zone_ptr->z1, x[1], zone_ptr->z2);
	    slice_zone.x1 = x[0];
	    slice_zone.y1 = coord;
	    slice_zone.z1 = zone_ptr->z1;
	    slice_zone.x2 = x[1];
	    slice_zone.y2 = coord;
	    slice_zone.z2 = zone_ptr->z2;
	  } else
	  {
	    std::ostringstream estring;
	    estring << "Error in Wedge::Slice 11" << std::endl;
	    error_msg(estring.str().c_str(), EA_STOP);
	  }
	} else
	{
	  std::ostringstream estring;
	  estring << "Error in Wedge::Slice 12" << std::endl;
	  error_msg(estring.str().c_str(), EA_STOP);
	}
      }
      break;
    case CF_Z:
      // slice is triangle
      slice = gpc_polygon_duplicate(tri);
      break;
    default:
      std::ostringstream estring;
      estring << "Wrong face defined in Wedge::Slice" << std::endl;
      error_msg(estring.str().c_str(), EA_STOP);
      break;
    } // end of Wedge direction CF_Z
    break;
  default:
    std::ostringstream estring;
    estring << "Wrong face defined in Wedge::Slice" << std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
    break;
  }
  if (tri != NULL)
  {
    gpc_free_polygon(tri);
    free_check_null(tri);
  }
  if (rect != NULL)
  {
    gpc_free_polygon(rect);
    free_check_null(rect);
  }
  if (result != NULL)
  {
    gpc_free_polygon(result);
    free_check_null(result);
  }
 /* if (slice != NULL && slice->contour != NULL && slice->contour->num_vertices == 4)
  {
    std::ostringstream ostring;
    ostring << "Zone point 1: " << slice_zone.x1 << "  " << slice_zone.y1 << "   " << slice_zone.z1 << std::endl;
    ostring << "Zone point 2: " << slice_zone.x2 << "  " << slice_zone.y2 << "   " << slice_zone.z2 << std::endl;
    output_msg(OUTPUT_MESSAGE, "%s\n", ostring.str().c_str());
  }*/
  return(slice);
}

void Wedge::printOn(std::ostream& os) const
{
	static const char *a[] = { "X1", "X2", "X3", "X4",
		"Y1", "Y2", "Y3", "Y4",
		"Z1", "Z2", "Z3", "Z4",
		"WEDGE_ERROR"
	};
	const char* orient;
	if (this->orientation < Wedge::X1 || Wedge::Z4 < this->orientation)
	{
		orient = a[WEDGE_ERROR];
	}
	else
	{
		orient = a[this->orientation];
	}

	os << "\t" << "-wedge"
		<< " " << this->box.x1
		<< " " << this->box.y1
		<< " " << this->box.z1
		<< " " << this->box.x2
		<< " " << this->box.y2
		<< " " << this->box.z2
		<< " " << orient
		<< "\n";
}

Wedge* Wedge::clone() const
{
	return new Wedge(*this);
}

Wedge* Wedge::create() const
{
	return new Wedge();
}
