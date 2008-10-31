#include "Cube.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <iostream>
#include <ostream>
#include "stddef.h"
#include "index_range.h"
#include "zone.h"
#include "message.h"

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

// Constructors
Cube::Cube(void)
{
	this->type = CUBE;
	this->coordinate_system = PHAST_Transform::GRID;

	// Default cube
	this->p.push_back(Point(0.0, 0.0, 0.0));
	this->p.push_back(Point(1.0, 1.0, 1.0));

	// Set bounding box
	this->Set_bounding_box();

}
Cube::Cube(const struct zone *zone_ptr)
{
	this->type = CUBE;
	this->coordinate_system = PHAST_Transform::GRID;

	// Define cube in standard order left, front, bottom point first
	this->p.push_back(Point(zone_ptr->x1, zone_ptr->y1, zone_ptr->z1));
	this->p.push_back(Point(zone_ptr->x2, zone_ptr->y2, zone_ptr->z2));

	Point mn(this->p.begin(), this->p.end(), Point::MIN);
	Point mx(this->p.begin(), this->p.end(), Point::MAX);

	this->p.clear();
	this->p.push_back(mn);
	this->p.push_back(mx);

	// Set bounding box
	this->Set_bounding_box();
}

// Destructor
Cube::~Cube(void)
{
}

// Set bounding box
struct zone *
Cube::Set_bounding_box()
{
	assert(this->p.size() == 2);
	this->box.x1 = this->p[0].x();
	this->box.y1 = this->p[0].y();
	this->box.z1 = this->p[0].z();
	this->box.x2 = this->p[1].x();
	this->box.y2 = this->p[1].y();
	this->box.z2 = this->p[1].z();
	this->box.zone_defined = 1;
	return &(this->box);
}

// Methods
bool
Cube::Point_in_polyhedron(const Point & t)
{
	return (this->Point_in_bounding_box(t));
}

void
Cube::Points_in_polyhedron(std::list < int >&list_of_numbers,
						   std::vector < Point > &node_xyz)
{
	std::list < int >::iterator it = list_of_numbers.begin();
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
gpc_polygon *
Cube::Face_polygon(Cell_Face face)
{
	// Generates a new gpc_polygon
	gpc_polygon *poly_ptr;
	struct zone *zone_ptr = this->Get_box();
	switch (face)
	{
	case CF_X:
		poly_ptr =
			rectangle(zone_ptr->y1, zone_ptr->z1, zone_ptr->y2, zone_ptr->z2);
		break;
	case CF_Y:
		poly_ptr =
			rectangle(zone_ptr->x1, zone_ptr->z1, zone_ptr->x2, zone_ptr->z2);
		break;
	case CF_Z:
		poly_ptr =
			rectangle(zone_ptr->x1, zone_ptr->y1, zone_ptr->x2, zone_ptr->y2);
		break;
	default:
		error_msg("Error in Cube::Face_polygon", EA_STOP);
	}
	return (poly_ptr);
}
#endif
gpc_polygon *
Cube::Slice(Cell_Face face, double coord)
{
	// Generates a new gpc_polygon
	gpc_polygon *poly_ptr;
	struct zone *zone_ptr = this->Get_bounding_box();

	switch (face)
	{
	case CF_X:
		if (coord < zone_ptr->x1 || coord > zone_ptr->x2)
		{
			poly_ptr = NULL;
		}
		else
		{
			poly_ptr =
				rectangle(zone_ptr->y1, zone_ptr->z1, zone_ptr->y2,
						  zone_ptr->z2);
		}
		break;
	case CF_Y:
		if (coord < zone_ptr->y1 || coord > zone_ptr->y2)
		{
			poly_ptr = NULL;
		}
		else
		{
			poly_ptr =
				rectangle(zone_ptr->x1, zone_ptr->z1, zone_ptr->x2,
						  zone_ptr->z2);
		}
		break;
	case CF_Z:
		if (coord < zone_ptr->z1 || coord > zone_ptr->z2)
		{
			poly_ptr = NULL;
		}
		else
		{
			poly_ptr =
				rectangle(zone_ptr->x1, zone_ptr->y1, zone_ptr->x2,
						  zone_ptr->y2);
		}
		break;
	default:
		error_msg("Error in Cube::Slice", EA_STOP);
	}
	return (poly_ptr);
}

void
	 Cube::printOn(std::ostream & os) const
	 {
		 os << "\t" << "-zone"
			 << " " << this->box.x1
			 << " " << this->box.y1
			 << " " << this->box.z1
			 << " " << this->box.x2
			 << " " << this->box.y2 << " " << this->box.z2 << "\n";
		 if (this->description.size())
		 {
			 os << "\t\t" << "-description " << this->description << "\n";
		 }
	 }

Cube *
	 Cube::clone() const
	 {
		 return new Cube(*this);
	 }

	 Cube *Cube::create() const
	 {
		 return new Cube();
	 }


bool
Cube::Segment_in_cube(Point & p1, Point & p2, Point & i1, Point & i2,
					  double &length,
					  Cube::CUBE_INTERSECTION & c_intersection)
{
	// Input: Segment defined by p1 and p2
	// Output: Segment defined by i1 and i2 is in the cube
	//         length is length of segment in cube
	//         type is interior, surface, or edge
	length = 0;

	struct zone *zo = this->Get_bounding_box();

	// Points in cube?
	bool in1 = this->Point_in_bounding_box(p1);
	bool in2 = this->Point_in_bounding_box(p2);

	// find intersection with 6 planes
	Point diff = p2 - p1;
	double t[6];
	Cube::PLANE_INTERSECTION pi[6];
	bool in_cube[6];

	// X minus 
	pi[0] = Segment_intersect_plane(1.0, 0.0, 0.0, -zo->x1, p1, diff, t[0]);
	// Y minus 
	pi[1] = Segment_intersect_plane(0.0, 1.0, 0.0, -zo->y1, p1, diff, t[1]);
	// Z minus 
	pi[2] = Segment_intersect_plane(0.0, 0.0, 1.0, -zo->z1, p1, diff, t[2]);
	// X plus 
	pi[3] = Segment_intersect_plane(1.0, 0.0, 0.0, -zo->x2, p1, diff, t[3]);
	// Y plus 
	pi[4] = Segment_intersect_plane(0.0, 1.0, 0.0, -zo->y2, p1, diff, t[4]);
	// Z plus 
	pi[5] = Segment_intersect_plane(0.0, 0.0, 1.0, -zo->z2, p1, diff, t[5]);

	// determine if intersection points with planes are in cube
	int i;
	for (i = 0; i < 6; i++)
	{
		switch (pi[i])
		{
		case Cube::PI_POINT:
			{
				Point p = p1 + diff * t[i];
				in_cube[i] = this->Point_in_bounding_box(p);
				break;
			}
		case Cube::PI_SEGMENT:
			if (((p1.get_coord()[i % 3] <= this->p[1].get_coord()[i % 3]) &&
				 (p2.get_coord()[i % 3] >= this->p[0].get_coord()[i % 3])) ||
				((p1.get_coord()[i % 3] >= this->p[0].get_coord()[i % 3]) &&
				 (p2.get_coord()[i % 3] <= this->p[1].get_coord()[i % 3])))
			{
				in_cube[i] = true;
			}
			else
			{
				in_cube[i] = false;
			}
			break;
		case Cube::PI_NONE:
			in_cube[i] = false;
			break;
		}
	}


	// determine segment length
	double min_t = 1;
	double max_t = 0;
	bool in = false;
	// both points in cube
	if (in1 && in2)
	{
		in = true;
		length = diff.modulus();
		i1 = p1;
		i2 = p2;
	}
	else
	{
		// determine length of intersection
		for (i = 0; i < 6; i++)
		{
			if (in_cube[i])
			{
				if (t[i] >= 0 && t[i] <= 1.0)
				{
					in = true;
					if (t[i] > max_t)
						max_t = t[i];
					if (t[i] < min_t)
						min_t = t[i];
				}
			}
		}
		// There is an intersection with a cell face of the cube
		if (in)
		{
			// Point 1 is inside cube
			if (in1)
			{
				i1 = p1;
				Point p = max_t * diff;
				i2 = p1 + p;
				length = p.modulus();
			}
			else if (in2)
			{
				i2 = p2;
				Point p = min_t * diff;
				i1 = p1 + p;
				length = p.modulus();
			}
			else
			{
				i1 = p1 + min_t * diff;
				Point p = (max_t - min_t) * diff;
				i2 = i1 + p;
				length = p.modulus();
			}
		}
	}
	if (length <= 0.0)
		in = false;

	// determine type of intersection
	if (!in)
	{
		c_intersection = Cube::CI_NONE;
	}
	else
	{
		int count_faces = 0;
		for (i = 0; i < 6; i++)
		{
			if (pi[i] == Cube::PI_SEGMENT)
				count_faces++;
		}
		switch (count_faces)
		{
		case 1:
			c_intersection = Cube::CI_FACE;
			break;
		case 2:
			c_intersection = Cube::CI_EDGE;
			break;
		default:
			c_intersection = Cube::CI_INTERIOR;
			break;
		}
	}

	return (in);
}

Cube::PLANE_INTERSECTION Segment_intersect_plane(const double a,
												 const double b,
												 const double c,
												 const double d, Point & p1,
												 Point & diff, double &t)
{
	//    Plane is defined as:
	//    a*x + b*y + c*z + d = 0
	double den = a * diff.x() + b * diff.y() + c * diff.z();
	double num = a * p1.x() + b * p1.y() + c * p1.z() + d;
	t = -1.0;


	Cube::PLANE_INTERSECTION intersect;
	if (den == 0.0)
	{
		if (num == 0.0)
		{
			intersect = Cube::PI_SEGMENT;
		}
		else
		{
			intersect = Cube::PI_NONE;
		}
	}
	else
	{
		intersect = Cube::PI_POINT;
		t = -num / den;
	}
	return (intersect);
}

//#ifdef SKIP
//
//----------------------------------------------------------------------Subject 5.05:How
//do
//  I find the intersection of a line and a plane ? If the plane is defined as : a * x + b * y + c * z + d = 0 and the line is defined as:
//
//  x = x1 + (x2 - x1) * t = x1 + i * t y = y1 + (y2 - y1) * t = y1 + j * t z = z1 + (z2 - z1) * t = z1 + k * t Then just substitute these into the plane equation.You end up with:
//
//t = -(a * x1 + b * y1 + c * z1 + d) / (a * i + b * j + c * k)
//      When the denominator is zero, the line is contained in the plane
//      if the numerator is also zero(the point at t = 0 satisfies the
//                                        plane equation)
//  , otherwise the line is parallel to the plane.
//#endif
