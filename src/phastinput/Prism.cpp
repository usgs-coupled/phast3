#include "Prism.h"
#include "Cube.h"
#include "Wedge.h"
#include "KDtree/Cell_Face.h"
#include "PHAST_Transform.h"
#include "message.h"
#include <sstream>
#include <iostream>
#include <algorithm>
#include "Utilities.h"
#include <assert.h>
std::list < Prism * >Prism::prism_list;

#if defined(__WPHAST__) && defined(_DEBUG)
#include <afx.h>
#undef min
#undef max
#endif

#define TRUE 1
#define FALSE 0

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

Prism::Prism(void)
{
	this->type = PRISM;

	//this->perimeter_poly = NULL;
	this->prism_dip = Point(0, 0, 1, 0);
	this->perimeter.Set_coordinate_system(PHAST_Transform::MAP);
	this->top.Set_coordinate_system(PHAST_Transform::MAP);
	this->bottom.Set_coordinate_system(PHAST_Transform::MAP);
	zone_init(&this->box);
	Prism::prism_list.push_back(this);
}

Prism::Prism(char * char_tag)
{
	this->type = PRISM;

	//this->perimeter_poly = NULL;
	this->prism_dip = Point(0, 0, 1, 0);
	this->perimeter.Set_coordinate_system(PHAST_Transform::MAP);
	this->top.Set_coordinate_system(PHAST_Transform::MAP);
	this->bottom.Set_coordinate_system(PHAST_Transform::MAP);
	zone_init(&this->box);
	std::string tag(char_tag);
	this->Set_tag(tag);
	Prism::prism_list.push_back(this);
}
Prism::Prism(Cube & c)
{
	this->type = PRISM;

	//this->coordinate_system = c.Get_coordinate_system();
	this->perimeter.Set_coordinate_system(c.Get_coordinate_system());
	this->top.Set_coordinate_system(c.Get_coordinate_system());
	this->bottom.Set_coordinate_system(c.Get_coordinate_system());

	this->perimeter.Set_user_coordinate_system(c.Get_coordinate_system());
	this->top.Set_user_coordinate_system(c.Get_coordinate_system());
	this->bottom.Set_user_coordinate_system(c.Get_coordinate_system());

	this->prism_dip = Point(0, 0, 1, 0);
	zone_init(&this->box);

	std::vector < Point > pts;
	zone c_zone(c.Get_bounding_box());

	// define perimeter
	this->perimeter.Set_defined(true);
	this->perimeter.Set_source_type(Data_source::POINTS);
	this->perimeter.Set_user_source_type(Data_source::POINTS);
	pts.push_back(Point(c_zone.x1, c_zone.y1, c_zone.z2));
	pts.push_back(Point(c_zone.x2, c_zone.y1, c_zone.z2));
	pts.push_back(Point(c_zone.x2, c_zone.y2, c_zone.z2));
	pts.push_back(Point(c_zone.x1, c_zone.y2, c_zone.z2));
	this->perimeter.Set_points(pts);

	// define top
	pts.clear();
	this->top.Set_defined(true);
	this->top.Set_source_type(Data_source::CONSTANT);
	this->top.Set_user_source_type(Data_source::CONSTANT);
	pts.push_back(Point(c_zone.x1, c_zone.y1, c_zone.z2));
	this->top.Set_points(pts);

	// define bottom
	pts.clear();
	this->bottom.Set_defined(true);
	this->bottom.Set_source_type(Data_source::CONSTANT);
	this->bottom.Set_user_source_type(Data_source::CONSTANT);
	pts.push_back(Point(c_zone.x1, c_zone.y1, c_zone.z1));
	this->bottom.Set_points(pts);

	this->Set_bounding_box();
	Prism::prism_list.push_back(this);
}

Prism::Prism(Wedge & w)
{
	this->type = PRISM;

	//this->coordinate_system = c.Get_coordinate_system();
	this->perimeter.Set_coordinate_system(w.Get_coordinate_system());
	this->top.Set_coordinate_system(w.Get_coordinate_system());
	this->bottom.Set_coordinate_system(w.Get_coordinate_system());

	this->perimeter.Set_user_coordinate_system(w.Get_coordinate_system());
	this->top.Set_user_coordinate_system(w.Get_coordinate_system());
	this->bottom.Set_user_coordinate_system(w.Get_coordinate_system());

	this->prism_dip = Point(0, 0, 1, 0);
	zone_init(&this->box);

	std::vector < Point > pts;
	zone w_zone(w.Get_bounding_box());

	// define perimeter
	this->perimeter.Set_defined(true);
	this->perimeter.Set_source_type(Data_source::POINTS);
	this->perimeter.Set_user_source_type(Data_source::POINTS);
	if (w.Get_wedge_axis() == CF_Z)
	{
		switch (w.Get_wedge_number())
		{
		case 1:
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z2));
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z2));
			this->perimeter.Set_points(pts);
			break;
		case 2:
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z2));
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z2));
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z2));
			this->perimeter.Set_points(pts);
			break;
		case 3:
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z2));
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z2));
			this->perimeter.Set_points(pts);
			break;
		case 4:
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z2));

			this->perimeter.Set_points(pts);
			break;
		}
	}
	else
	{
		pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z2));
		pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z2));
		pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z2));
		pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z2));
		this->perimeter.Set_points(pts);
	}

	// define top and bottom

	// First define as constant
	pts.clear();
	this->top.Set_defined(true);
	this->top.Set_source_type(Data_source::CONSTANT);
	this->top.Set_user_source_type(Data_source::CONSTANT);
	pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z2));
	this->top.Set_points(pts);

	pts.clear();
	this->bottom.Set_defined(true);
	this->bottom.Set_source_type(Data_source::CONSTANT);
	this->bottom.Set_user_source_type(Data_source::CONSTANT);
	pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z1));
	this->bottom.Set_points(pts);

	// for Z, we are done
	pts.clear();
	if (w.Get_wedge_axis() == CF_X)
	{
		switch (w.Get_wedge_number())
		{
		case 1:
			// Top
			this->top.Set_source_type(Data_source::POINTS);
			this->top.Set_user_source_type(Data_source::POINTS);
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z1));
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z1));
			this->top.Set_points(pts);

			// Bottom is constant
			break;
		case 2:
			// Top is constant

			// Bottom
			this->bottom.Set_source_type(Data_source::POINTS);
			this->bottom.Set_user_source_type(Data_source::POINTS);
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z1));
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z1));
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z2));
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z2));
			this->bottom.Set_points(pts);
			break;
		case 3:
			// Top is constant

			// Bottom
			this->bottom.Set_source_type(Data_source::POINTS);
			this->bottom.Set_user_source_type(Data_source::POINTS);
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z1));
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z1));
			this->bottom.Set_points(pts);
			break;

		case 4:
			// Top
			this->top.Set_source_type(Data_source::POINTS);
			this->top.Set_user_source_type(Data_source::POINTS);
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z1));
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z1));
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z2));
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z2));
			this->top.Set_points(pts);

			// Bottom is constant
			break;
		}
	}

	if (w.Get_wedge_axis() == CF_Y)
	{
		switch (w.Get_wedge_number())
		{
		case 1:
			// Top
			this->top.Set_source_type(Data_source::POINTS);
			this->top.Set_user_source_type(Data_source::POINTS);
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z1));
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z1));
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z2));
			this->top.Set_points(pts);

			// Bottom is constant
			break;
		case 2:
			this->top.Set_source_type(Data_source::POINTS);
			this->top.Set_user_source_type(Data_source::POINTS);
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z1));
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z2));
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z1));
			this->top.Set_points(pts);

			// Bottom is constant
			break;
		case 3:
			// Top is constant

			// Bottom
			this->bottom.Set_source_type(Data_source::POINTS);
			this->bottom.Set_user_source_type(Data_source::POINTS);
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z1));
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z1));
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z2));
			this->bottom.Set_points(pts);
			break;
		case 4:
			// Top is constant

			// Bottom
			this->bottom.Set_source_type(Data_source::POINTS);
			this->bottom.Set_user_source_type(Data_source::POINTS);
			pts.push_back(Point(w_zone.x1, w_zone.y1, w_zone.z1));
			pts.push_back(Point(w_zone.x2, w_zone.y1, w_zone.z2));
			pts.push_back(Point(w_zone.x2, w_zone.y2, w_zone.z2));
			pts.push_back(Point(w_zone.x1, w_zone.y2, w_zone.z1));
			this->bottom.Set_points(pts);
			break;
		}
	}

	this->Set_bounding_box();
	Prism::prism_list.push_back(this);
}

Prism::Prism(std::vector< Point > perimeter_pts, PHAST_Transform::COORDINATE_SYSTEM cs)
{
	this->type = PRISM;

	this->perimeter.Set_coordinate_system(cs);
	this->top.Set_coordinate_system(cs);
	this->bottom.Set_coordinate_system(cs);

	this->perimeter.Set_user_coordinate_system(cs);
	this->top.Set_user_coordinate_system(cs);
	this->bottom.Set_user_coordinate_system(cs);

	this->prism_dip = Point(0, 0, 1, 0);
	zone_init(&this->box);

	// define perimeter
	this->perimeter.Set_defined(true);
	this->perimeter.Set_source_type(Data_source::POINTS);
	this->perimeter.Set_user_source_type(Data_source::POINTS);
	this->perimeter.Set_points(perimeter_pts);
	this->perimeter.Set_columns(3);

	Prism::prism_list.push_back(this);
}

Prism::Prism(const Prism & c):
Polyhedron(c),
perimeter(c.perimeter),
prism_dip(c.prism_dip),
bottom(c.bottom),
top(c.top)
{
	Prism::prism_list.push_back(this);
}
Prism::~Prism(void)
{
	// remove from prism_vector
	std::list < Prism * >::iterator it = Prism::prism_list.begin();
	for (; it != Prism::prism_list.end(); ++it)
	{
		if (*it == this)
			break;
	}
	assert(it != Prism::prism_list.end());	// should be found
	if (it != Prism::prism_list.end())
		Prism::prism_list.erase(it);
}

bool Prism::Read(std::istream & lines)
{
	// read information for top, or bottom
	const char *
		opt_list[] = {
		"perimeter"				/* 0 */
			, "dip"				/* 1 */
			, "top"				/* 2 */
			, "bottom"			/* 3 */
			, "description"     /* 4 */
			//,"vector"                        /* 4 */
			//"perimeter_z",                   /* 5 */
			//"units_top",                     /* 6 */
			//"units_bottom",                  /* 7 */
			//"units_perimeter"                /* 8 */
			//"perimeter_coordinate_system",     /* 5 */
			//"top_coordinate_system",           /* 6 */
			//"bottom_coordinate_system"         /* 7 */
	};
	int
		count_opt_list = 5;
	std::vector < std::string > std_opt_list;
	int
		i;
	for (i = 0; i < count_opt_list; i++)
		std_opt_list.push_back(opt_list[i]);

	// get option
	std::string l_type;
	lines >> l_type;
	if (l_type.size() == 0)
		return true;
	int
		j = case_picker(std_opt_list, l_type);
	PRISM_OPTION
		p_opt;
	switch (j)
	{
	case 0:
		p_opt = Prism::PERIMETER;
		break;
	case 2:
		p_opt = Prism::TOP;
		break;
	case 3:
		p_opt = Prism::BOTTOM;
		break;

	case 4:
		p_opt = Prism::DESCRIPTION;
		break;

	default:
		error_msg("Error reading prism data (perimeter, top, bottom).",
				  EA_CONTINUE);
		return (false);
	}
	return (this->Read(p_opt, lines));
}

bool Prism::Read(PRISM_OPTION p_opt, std::istream & lines)
{
	size_t startpos;
	size_t endpos;
	std::string token;
	// identifier
	//lines >> token;
	bool
		success = true;
	switch (p_opt)
	{
	case PERIMETER:
		if (!this->perimeter.Read(lines, false))
		{
			error_msg("Reading perimeter of prism", EA_CONTINUE);
		}
		else if (this->perimeter.Get_source_type() != Data_source::POINTS &&
				 this->perimeter.Get_source_type() != Data_source::SHAPE &&
				 this->perimeter.Get_source_type() != Data_source::XYZ)
		{
			error_msg("Perimeter must be points, XYZ file, or a shape file",
					  EA_CONTINUE);
		}
		break;
	case TOP:
		if (!this->top.Read(lines, true))
			error_msg("Reading top of prism", EA_CONTINUE);
		break;
	case BOTTOM:
		if (!this->bottom.Read(lines, true))
			error_msg("Reading bottom of prism", EA_CONTINUE);
		break;
	case DESCRIPTION:
		std::getline(lines, this->description);

		// trim leading and trailing spaces
		startpos = this->description.find_first_not_of(" \t");
		endpos = this->description.find_last_not_of(" \t");

		if((startpos == string::npos) || (endpos == string::npos))
		{
			this->description = "";
		}
		else
		{
			this->description = this->description.substr(startpos, endpos - startpos + 1);
		}
		break;
	default:
		error_msg("Unknown option in prism::read.", EA_CONTINUE);
		break;

#ifdef SKIP
	case PERIMETER_COORD_SYS:
		{
			lines >> token;
			char
				str[250];
			strcpy(str, token.c_str());
			str_tolower(str);
			if (strstr(str, "map") == str)
			{
				this->perimeter.Set_coordinate_system(PHAST_Transform::MAP);
			}
			else if (strstr(str, "grid") == str)
			{
				this->perimeter.Set_coordinate_system(PHAST_Transform::GRID);
			}
			else
			{
				error_msg("Reading perimeter coordinate system option.",
						  EA_CONTINUE);
				success = false;
			}
		}
		break;
	case TOP_COORD_SYS:
		{
			lines >> token;
			char
				str[250];
			strcpy(str, token.c_str());
			str_tolower(str);
			if (strstr(str, "map") == str)
			{
				this->top.Set_coordinate_system(PHAST_Transform::MAP);
			}
			else if (strstr(str, "grid") == str)
			{
				this->top.Set_coordinate_system(PHAST_Transform::GRID);
			}
			else
			{
				error_msg("Reading top coordinate system option.",
						  EA_CONTINUE);
				success = false;
			}
		}
	case BOTTOM_COORD_SYS:
		{
			lines >> token;
			char
				str[250];
			strcpy(str, token.c_str());
			str_tolower(str);
			if (strstr(str, "map") == str)
			{
				this->bottom.Set_coordinate_system(PHAST_Transform::MAP);
			}
			else if (strstr(str, "grid") == str)
			{
				this->bottom.Set_coordinate_system(PHAST_Transform::GRID);
			}
			else
			{
				error_msg("Reading bottom coordinate system option.",
						  EA_CONTINUE);
				success = false;
			}
		}
		break;
#endif
	}
	return (success);
}

void
Prism::Points_in_polyhedron(std::list < int >&list_of_numbers,
							std::vector < Point > &point_xyz)
{
	std::list < int >::iterator it = list_of_numbers.begin();
	while (it != list_of_numbers.end())
	{
		int n = *it;
		if (!(this->Point_in_polyhedron(point_xyz[n])))
		{
			it = list_of_numbers.erase(it);
		}
		else
		{
			it++;
		}
	}
}
bool Prism::Point_in_polyhedron(const Point & l_p)
{
	Point
	p1(l_p);

	// Check bounding box of prism
	if (!this->Point_in_bounding_box(p1))
		return false;

	// Check top
	if (this->top.Get_defined())
	{
		double
			t = this->top.Interpolate(p1);
		if (p1.z() > t)
		{
			return false;
		}
	}

	// Check bottom
	if (this->bottom.Get_defined())
	{
		double
			b = this->bottom.Interpolate(p1);
		if (p1.z() < b)
		{
			return false;
		}
	}

	// check perimeter
	this->Project_point(p1, CF_Z, grid_zone()->z2);
	//return (this->perimeter.Get_phast_polygons().Point_in_polygon(p1));
	return (this->perimeter.Get_tree()->Point_in_polygon(p1));
}

Polyhedron *
Prism::clone() const
{
	return new Prism(*this);
}

Polyhedron *
Prism::create() const
{
	return new Prism();
}
#ifdef SKIP
gpc_polygon *
Prism::Slice(Cell_Face face, double coord)
{

	// Determine if dip is parallel to face
	Cube::PLANE_INTERSECTION p_intersection;
	Point p1;
	double t;

	Point lp1, lp2;
	switch (face)
	{
	case CF_X:
		p_intersection =
			Segment_intersect_plane(1.0, 0.0, 0.0, -coord, p1,
									this->prism_dip, t);
		lp1 = Point(coord, this->box.y1 - (this->box.y2 - this->box.y1), grid_zone()->z2);
		lp2 = Point(coord, this->box.y2 + (this->box.y2 - this->box.y1), grid_zone()->z2);
		break;
	case CF_Y:
		p_intersection =
			Segment_intersect_plane(0.0, 1.0, 0.0, -coord, p1,
									this->prism_dip, t);
		lp1 = Point(this->box.x1 - (this->box.x2 - this->box.x1), coord, grid_zone()->z2);
		lp2 = Point(this->box.x2 + (this->box.x2 - this->box.x1), coord, grid_zone()->z2);
		break;
	case CF_Z:
		p_intersection =
			Segment_intersect_plane(0.0, 0.0, 1.0, -coord, p1,
									this->prism_dip, t);
		break;
	default:
		error_msg("Unhandled case in Prism::Slice.", EA_STOP);
	}


	if (p_intersection == Cube::PI_POINT)
	{
		// Dip of prism is not parallel to face
		std::vector < Point > project;
		std::vector < Point >::iterator it;
		for (it = this->perimeter.Get_points().begin();
			 it != this->perimeter.Get_points().end(); it++)
		{
			Point p = *it;
			if (!(this->Project_point(p, face, coord)))
			{
				error_msg("Could not project point?", EA_CONTINUE);
			}
			project.push_back(p);
		}
		gpc_polygon *slice = points_to_poly(project, face);
		return slice;
	}
	else
	{
		// Dip of prism is parallel to face
		std::vector < Point > intersect_pts;
		gpc_polygon *slice = empty_polygon();
		{
			//line_intersect_polygon(lp1, lp2, this->perimeter.pts, intersect_pts);
			this->perimeter.Get_phast_polygons().Line_intersect(lp1, lp2,
																intersect_pts);
			int i;
			for (i = 0; i < (int) intersect_pts.size(); i = i + 2)
			{
				// add upper points
				std::vector < Point > pts;
				//pts.push_back(Point(pts[i].x(), pts[i].y(), grid_zone()->z2));
				//pts.push_back(Point(pts[i+1].x(), pts[i+1].y(), grid_zone()->z2));
				pts.push_back(intersect_pts[i]);
				pts.push_back(intersect_pts[i + 1]);
				// add lower points
				Point p2;
				p2 = intersect_pts[i + 1];

				// Need to change if prism slants
				p2.set_z(grid_zone()->z1);
				//this->Project_point(p2, face, grid_zone()->z1);
				pts.push_back(p2);

				p2 = intersect_pts[i];
				// Need to change if prism slants
				p2.set_z(grid_zone()->z1);
				//this->Project_point(p2, face, grid_zone()->z1);
				pts.push_back(p2);

				// generate polygon
				gpc_polygon *contour = points_to_poly(pts, face);

				// add to slice
				gpc_polygon_clip(GPC_UNION, slice, contour, slice);
				gpc_free_polygon(contour);
				free_check_null(contour);
			}
		}
		return slice;
	}
	return (NULL);
}
#endif
gpc_polygon *
Prism::Slice(Cell_Face face, double coord)
{

	// Determine if dip is parallel to face
	Cube::PLANE_INTERSECTION p_intersection = Cube::PI_NONE;
	Point p1;
	double t;

	Point lp1, lp2;
	switch (face)
	{
	case CF_X:
		p_intersection =
			Segment_intersect_plane(1.0, 0.0, 0.0, -coord, p1,
									this->prism_dip, t);
		lp1 = Point(coord, this->box.y1 - (this->box.y2 - this->box.y1), grid_zone()->z2);
		lp2 = Point(coord, this->box.y2 + (this->box.y2 - this->box.y1), grid_zone()->z2);
		break;
	case CF_Y:
		p_intersection =
			Segment_intersect_plane(0.0, 1.0, 0.0, -coord, p1,
									this->prism_dip, t);
		lp1 = Point(this->box.x1 - (this->box.x2 - this->box.x1), coord, grid_zone()->z2);
		lp2 = Point(this->box.x2 + (this->box.x2 - this->box.x1), coord, grid_zone()->z2);
		break;
	case CF_Z:
		p_intersection =
			Segment_intersect_plane(0.0, 0.0, 1.0, -coord, p1,
									this->prism_dip, t);
		break;
	default:
		error_msg("Unhandled case in Prism::Slice.", EA_STOP);
	}


	if (p_intersection == Cube::PI_POINT)
	{
		// Dip of prism is not parallel to face
		std::vector < Point > project;
		//std::vector < Point >::iterator it;
		//for (it = this->perimeter.Get_points().begin();
		//	 it != this->perimeter.Get_points().end(); it++)
		//{
		//	Point p = *it;
		//	if (!(this->Project_point(p, face, coord)))
		//	{
		//		error_msg("Could not project point?", EA_CONTINUE);
		//	}
		//	project.push_back(p);
		//}
		//gpc_polygon *slice = points_to_poly(project, face);
		gpc_polygon *slice = PHAST_polygon2gpc_polygon(&this->perimeter.Get_phast_polygons());
		return slice;
	}
	else
	{
		// Dip of prism is parallel to face
		std::vector < Point > intersect_pts;
		gpc_polygon *slice = empty_polygon();
		{
			//line_intersect_polygon(lp1, lp2, this->perimeter.pts, intersect_pts);
			this->perimeter.Get_phast_polygons().Line_intersect(lp1, lp2,
																intersect_pts);
			int i;
			for (i = 0; i < (int) intersect_pts.size(); i = i + 2)
			{
				// add upper points
				std::vector < Point > pts;
				//pts.push_back(Point(pts[i].x(), pts[i].y(), grid_zone()->z2));
				//pts.push_back(Point(pts[i+1].x(), pts[i+1].y(), grid_zone()->z2));
				pts.push_back(intersect_pts[i]);
				pts.push_back(intersect_pts[i + 1]);
				// add lower points
				Point p2;
				p2 = intersect_pts[i + 1];

				// Need to change if prism slants
				p2.set_z(grid_zone()->z1);
				//this->Project_point(p2, face, grid_zone()->z1);
				pts.push_back(p2);

				p2 = intersect_pts[i];
				// Need to change if prism slants
				p2.set_z(grid_zone()->z1);
				//this->Project_point(p2, face, grid_zone()->z1);
				pts.push_back(p2);

				// generate polygon
				gpc_polygon *contour = points_to_poly(pts, face);

				// add to slice
				gpc_polygon_clip(GPC_UNION, slice, contour, slice);
				gpc_free_polygon(contour);
				free_check_null(contour);
			}
		}
		return slice;
	}
	return (NULL);
}

void
Prism::printOn(std::ostream & os) const
{
	os << "\t-prism" << std::endl;
	/*
	   os << "\t\t#-vector " << this->prism_dip.x() << " " << this->prism_dip.y() << " " << this->prism_dip.z() << std::endl;
	 */

	if (this->description.size())
	{
		os << "\t\t" << "-description " << this->description << "\n";
	}

	if (this->top.Get_source_type() != Data_source::NONE && this->top.Get_user_source_type() != Data_source::NONE)
	{
		os << "\t\t-top       " << this->top;
		{
			/*
			   Data_source top_copy(this->top);
			   if (top_copy.Get_h_units()->defined || top_copy.Get_v_units()->defined)
			   {
			   os << "\t\t-units_top ";
			   os << (top_copy.Get_h_units()->defined) ? top_copy.Get_h_units()->input : top_copy.Get_h_units()->si;
			   os << (top_copy.Get_v_units()->defined) ? top_copy.Get_v_units()->input : top_copy.Get_v_units()->si;
			   os << std::endl;
			   }
			 */
		}
	}

	if (this->bottom.Get_source_type() != Data_source::NONE && this->bottom.Get_user_source_type() != Data_source::NONE)
	{
		os << "\t\t-bottom    " << this->bottom;
		{
			/*
			   Data_source bottom_copy(this->bottom);
			   if (bottom_copy.Get_h_units()->defined || bottom_copy.Get_v_units()->defined)
			   {
			   os << "\t\t-units_bottom ";
			   os << (bottom_copy.Get_h_units()->defined) ? bottom_copy.Get_h_units()->input : bottom_copy.Get_h_units()->si;
			   os << (bottom_copy.Get_v_units()->defined) ? bottom_copy.Get_v_units()->input : bottom_copy.Get_v_units()->si;
			   os << std::endl;
			   }
			 */
		}
	}

	if (this->perimeter.Get_source_type() != Data_source::NONE)
	{
		os << "\t\t-perimeter " << this->perimeter;
		{
			/*
			   Data_source perimeter_copy(this->perimeter);
			   if (perimeter_copy.Get_h_units()->defined || perimeter_copy.Get_v_units()->defined)
			   {
			   os << "\t\t-units_perimeter ";
			   os << (perimeter_copy.Get_h_units()->defined) ? perimeter_copy.Get_h_units()->input : perimeter_copy.Get_h_units()->si;
			   os << (perimeter_copy.Get_v_units()->defined) ? perimeter_copy.Get_v_units()->input : perimeter_copy.Get_v_units()->si;
			   os << std::endl;
			   }
			 */
		}
	}
}

bool Prism::Project_point(Point & l_p, Cell_Face face, double coord)
{
	bool
		success = true;
	// Project point to a z plane
	double
		t;
	Point
		a;
	a.get_coord()[(int) face] = 1.0;
	if (Segment_intersect_plane
		(a.x(), a.y(), a.z(), -coord, l_p, this->prism_dip, t) == Cube::PI_NONE)
	{
		success = false;
	}
	l_p = l_p + t * this->prism_dip;
	return (success);
}

bool Prism::Project_points(std::vector < Point > &pts, Cell_Face face,
						   double coord)
{
	bool
		success = true;
	std::vector < Point >::iterator it;
	for (it = pts.begin(); it != pts.end(); it++)
	{
		if (!this->Project_point(*it, face, coord))
			success = false;
	}
	return (success);
}

void
Tidy_prisms(void)
{
	std::list < Prism * >::const_iterator it;

	for (it = Prism::prism_list.begin(); it != Prism::prism_list.end(); it++)
	{
		(*it)->Tidy();
	}
}
void
Convert_coordinates_prisms(PHAST_Transform::COORDINATE_SYSTEM cs,
						   PHAST_Transform * map2grid)
{
	std::list < Prism * >::const_iterator it;

	for (it = Prism::prism_list.begin(); it != Prism::prism_list.end(); it++)
	{
		(*it)->Convert_coordinates(cs, map2grid);
	}
}
void
Prism::Tidy()
{
	//
	// set defaults
	if (this->perimeter.Get_source_type() == Data_source::NONE)
	{
		this->perimeter.Set_defined(true);
		this->perimeter.Set_coordinate_system(PHAST_Transform::GRID);
		this->perimeter.Set_user_coordinate_system(PHAST_Transform::GRID);
		this->perimeter.Set_source_type(Data_source::POINTS);
		assert(this->perimeter.Get_user_source_type() == Data_source::NONE);
		this->perimeter.Get_points().
			push_back(Point
					  (grid_zone()->x1, grid_zone()->y1, grid_zone()->z2,
					   grid_zone()->z2));
		this->perimeter.Get_points().
			push_back(Point
					  (grid_zone()->x2, grid_zone()->y1, grid_zone()->z2,
					   grid_zone()->z2));
		this->perimeter.Get_points().
			push_back(Point
					  (grid_zone()->x2, grid_zone()->y2, grid_zone()->z2,
					   grid_zone()->z2));
		this->perimeter.Get_points().
			push_back(Point
					  (grid_zone()->x1, grid_zone()->y2, grid_zone()->z2,
					   grid_zone()->z2));
	}
	if (this->top.Get_source_type() == Data_source::NONE)
	{
		this->top.Set_defined(true);
		this->top.Set_coordinate_system(PHAST_Transform::GRID);
		this->top.Set_user_coordinate_system(PHAST_Transform::GRID);
		this->top.Set_source_type(Data_source::CONSTANT);
		assert(this->top.Get_user_source_type() == Data_source::NONE);
		this->top.Get_points().
			push_back(Point
					  (grid_zone()->x1, grid_zone()->y1, grid_zone()->z2,
					   grid_zone()->z2));
	}
	if (this->bottom.Get_source_type() == Data_source::NONE)
	{
		this->bottom.Set_defined(true);
		this->bottom.Set_coordinate_system(PHAST_Transform::GRID);
		this->bottom.Set_user_coordinate_system(PHAST_Transform::GRID);
		this->bottom.Set_source_type(Data_source::CONSTANT);
		assert(this->bottom.Get_user_source_type() == Data_source::NONE);
		this->bottom.Get_points().
			push_back(Point
					  (grid_zone()->x1, grid_zone()->y1, grid_zone()->z1,
					   grid_zone()->z1));
	}

	this->top.Tidy(true);
	if ((this->top.Get_source_type() == Data_source::POINTS ||
		this->top.Get_source_type() == Data_source::XYZ)
		&& this->top.Get_points().size() == 0)
	{
		std::string emsg("No points defined for top of prism ");
		emsg.append(this->tag);
		error_msg(emsg.c_str(), EA_CONTINUE);
	}

	this->bottom.Tidy(true);
	if ((this->bottom.Get_source_type() == Data_source::POINTS ||
		this->bottom.Get_source_type() == Data_source::XYZ)
		&& this->bottom.Get_points().size() == 0)
	{
		std::string emsg("No points defined for bottom of prism ");
		emsg.append(this->tag);
		error_msg(emsg.c_str(), EA_CONTINUE);
	}
	this->perimeter.Tidy(false);
	if (this->perimeter.Get_source_type() == Data_source::POINTS
			 && this->perimeter.Get_points().size() < 3)
	{
		std::string emsg("Perimeter must be defined by at least 3 points ");
		emsg.append(this->tag);
		error_msg(emsg.c_str(), EA_CONTINUE);
	}
	if (this->perimeter.Get_source_type() == Data_source::XYZ ||
		this->perimeter.Get_source_type() == Data_source::POINTS)
	{
		if (Prism::Polygon_intersects_self(this->perimeter.Get_points()))
		{
			std::ostringstream oss;
			oss << "Perimeter intersects self " << this->tag;
			error_msg(oss.str().c_str(), EA_CONTINUE);
		}
	}

	//if (!this->perimeter.Make_polygons())
	//{
	//  error_msg("Failed to make polygons in Prism::tidy.", EA_STOP);
	//};
	// Make polygons if needed
	//this->perimeter.Get_phast_polygons();

	//std::vector < Point >::iterator it;
	// Project points to top of grid
	//this->Project_points(this->perimeter.Get_points(), CF_Z, grid_zone()->z2);
	//  this->perimeter_datum = grid_zone()->z2;
	// set bounding box
	this->Set_bounding_box();
	//Polygon_tree *temp_tree = new Polygon_tree(this->perimeter.Get_phast_polygons());
	//this->perimeter.Set_tree(temp_tree);

}
struct zone *
Prism::Set_bounding_box(void)
{
	std::vector < Point > m;
	if (this->perimeter.Get_defined())
	{
		m.push_back(Point(this->perimeter.Get_bounding_box()->x1,
						  this->perimeter.Get_bounding_box()->y1,
						  grid_zone()->z1));
		m.push_back(Point(this->perimeter.Get_bounding_box()->x2,
						  this->perimeter.Get_bounding_box()->y2,
						  grid_zone()->z2));
	}
	else
	{
		error_msg("Perimeter not defined in Prism::Set_bounding_box",
				  EA_STOP);
	}

	//m.push_back(Point(this->perimeter.Get_phast_polygons().Get_points().begin(),
	//  this->perimeter.Get_phast_polygons().Get_points().end(),
	//  Point::MIN));
	//m.push_back(Point(this->perimeter.Get_phast_polygons().Get_points().begin(),
	//  this->perimeter.Get_phast_polygons().Get_points().end(),
	//  Point::MAX));

	//std::vector<Point> b = this->perimeter.Get_phast_polygons().Get_points();
	//this->Project_points(b, CF_Z, grid_zone()->z1);
	//m.push_back(Point(b.begin(), b.end(), Point::MIN));
	//m.push_back(Point(b.begin(), b.end(), Point::MAX));

	// project points to bottom
	std::vector < Point > proj = m;
	this->Project_points(proj, CF_Z, grid_zone()->z1);
	m.push_back(Point(proj.begin(), proj.end(), Point::MIN));
	m.push_back(Point(proj.begin(), proj.end(), Point::MAX));


	Point min(Point(m.begin(), m.end(), Point::MIN));
	Point max(Point(m.begin(), m.end(), Point::MAX));

	// Check top
	Point ptop, pbottom;
	if (this->top.Get_defined())
	{
		std::vector < Point > &pts1 = this->top.Get_points();
		ptop = Point(pts1.begin(), pts1.end(), Point::MAX);
		if (ptop.z() < max.z())
			max.set_z(ptop.z());
	}
	// Check bottom
	if (this->bottom.Get_defined())
	{
		std::vector < Point > &pts1 = this->bottom.Get_points();
		pbottom = Point(pts1.begin(), pts1.end(), Point::MIN);
		if (pbottom.z() > min.z())
			min.set_z(pbottom.z());
	}
	this->box.zone_defined = true;
	this->box.x1 = min.x();
	this->box.y1 = min.y();
	this->box.z1 = min.z();

	this->box.x2 = max.x();
	this->box.y2 = max.y();
	this->box.z2 = max.z();
	return (&this->box);

}

void
Prism::Remove_top_bottom(gpc_polygon * polygon, Cell_Face face, double coord)
{
	// Assumes everything in grid coordinates (I think)
	PHAST_polygon phast_polygon(polygon, PHAST_Transform::GRID);
	phast_polygon.Set_bounding_box();
	zone face_zone;
	int ndiv = 10;
	double divisions = (double) ndiv;
	std::vector < Point > top_pts, bottom_pts;
	switch (face)
	{
	case CF_X:

		face_zone.x1 = coord;
		face_zone.y1 = phast_polygon.Get_bounding_box()->x1;
		face_zone.z1 = phast_polygon.Get_bounding_box()->y1;
		face_zone.x2 = coord;
		face_zone.y2 = phast_polygon.Get_bounding_box()->x2;
		face_zone.z2 = phast_polygon.Get_bounding_box()->y2;

		// Make polygon for top, intersect with polygon
		if (this->top.Get_defined()
			&& this->top.Get_bounding_box()->z1 < face_zone.z2)
		{
			top_pts.push_back(Point(face_zone.y1, grid_zone()->z1, 0.0));
			double d;
			//for (d = face_zone.y1; d <= face_zone.y2; d += (face_zone.y2 - face_zone.y1) / divisions)
			int i;
			for (i = 0; i < ndiv + 1; i++)
			{
				d = face_zone.y1 + (double) i / divisions * (face_zone.y2 -
															 face_zone.y1);
				Point l_p(coord, d, 0, 0);
				double l_top;
				l_top = this->top.Interpolate(l_p);
				top_pts.push_back(Point(d, l_top, 0.0));
			}
			top_pts.push_back(Point(face_zone.y2, grid_zone()->z1, 0.0));
			gpc_polygon *top_poly = points_to_poly(top_pts, CF_Z);
			gpc_polygon_clip(GPC_INT, polygon, top_poly, polygon);
			gpc_free_polygon(top_poly);
			free_check_null(top_poly);
		}
		// Make polygon for bottom, intersect with polygon
		if (this->bottom.Get_defined()
			&& this->bottom.Get_bounding_box()->z2 > face_zone.z1)
		{
			bottom_pts.push_back(Point(face_zone.y1, grid_zone()->z2, 0.0));
			double d;
			//for (d = face_zone.y1; d <= face_zone.y2; d += (face_zone.y2 - face_zone.y1) / divisions)
			int i;
			for (i = 0; i < ndiv + 1; i++)
			{
				d = face_zone.y1 + (double) i / divisions * (face_zone.y2 -
															 face_zone.y1);
				Point l_p(coord, d, 0, 0);
				double l_bottom;
				l_bottom = this->bottom.Interpolate(l_p);
				bottom_pts.push_back(Point(d, l_bottom, 0.0));
			}
			bottom_pts.push_back(Point(face_zone.y2, grid_zone()->z2, 0.0));
			gpc_polygon *bottom_poly = points_to_poly(bottom_pts, CF_Z);
			gpc_polygon_clip(GPC_INT, polygon, bottom_poly, polygon);
			gpc_free_polygon(bottom_poly);
			free_check_null(bottom_poly);
		}
		break;
	case CF_Y:
		face_zone.x1 = phast_polygon.Get_bounding_box()->x1;
		face_zone.y1 = coord;
		face_zone.z1 = phast_polygon.Get_bounding_box()->y1;
		face_zone.x2 = phast_polygon.Get_bounding_box()->x2;
		face_zone.y2 = coord;
		face_zone.z2 = phast_polygon.Get_bounding_box()->y2;


		// Make polygon for top, intersect with polygon
		if (this->top.Get_defined()
			&& this->top.Get_bounding_box()->z1 < face_zone.z2)
		{
			top_pts.push_back(Point(face_zone.x1, grid_zone()->z1, 0.0));
			double d;
			//for (d = face_zone.x1; d <= face_zone.x2; d += (face_zone.x2 - face_zone.x1) / divisions)
			int i;
			for (i = 0; i < ndiv + 1; i++)
			{
				d = face_zone.x1 + (double) i / divisions * (face_zone.x2 -
															 face_zone.x1);
				Point l_p(d, coord, 0, 0);
				double l_top;
				l_top = this->top.Interpolate(l_p);
				top_pts.push_back(Point(d, l_top, 0.0));
			}
			top_pts.push_back(Point(face_zone.x2, grid_zone()->z1, 0.0));
			gpc_polygon *top_poly = points_to_poly(top_pts, CF_Z);
			gpc_polygon_clip(GPC_INT, polygon, top_poly, polygon);
			gpc_free_polygon(top_poly);
			free_check_null(top_poly);
		}
		// Make polygon for bottom, intersect with polygon
		if (this->bottom.Get_defined()
			&& this->bottom.Get_bounding_box()->z2 > face_zone.z1)
		{
			bottom_pts.push_back(Point(face_zone.x1, grid_zone()->z2, 0.0));
			double d;
			//for (d = face_zone.x1; d <= face_zone.x2; d += (face_zone.x2 - face_zone.x1) / divisions)
			int i;
			for (i = 0; i < ndiv + 1; i++)
			{
				d = face_zone.x1 + (double) i / divisions * (face_zone.x2 -
															 face_zone.x1);
				Point l_p(d, coord, 0, 0);
				double l_bottom;
				l_bottom = this->bottom.Interpolate(l_p);
				bottom_pts.push_back(Point(d, l_bottom, 0.0));
			}
			bottom_pts.push_back(Point(face_zone.x2, grid_zone()->z2, 0.0));
			gpc_polygon *bottom_poly = points_to_poly(bottom_pts, CF_Z);
			gpc_polygon_clip(GPC_INT, polygon, bottom_poly, polygon);
			gpc_free_polygon(bottom_poly);
			free_check_null(bottom_poly);
		}
		break;
	case CF_Z:
		{
			face_zone.x1 = phast_polygon.Get_bounding_box()->x1;
			face_zone.y1 = phast_polygon.Get_bounding_box()->y1;
			face_zone.z1 = coord;
			face_zone.x2 = phast_polygon.Get_bounding_box()->x2;
			face_zone.y2 = phast_polygon.Get_bounding_box()->y2;
			face_zone.z2 = coord;

			// Check if polygon is below bounding box of top
			bool do_top = false;
			if (this->top.Get_defined()
				&& this->top.Get_bounding_box()->z1 < face_zone.z2)
			{
				do_top = true;
			}
			// Check if polygon is below bounding box of top
			bool do_bottom = false;
			if (this->bottom.Get_defined()
				&& this->bottom.Get_bounding_box()->z2 > face_zone.z1)
			{
				do_bottom = true;
			}
			// Do simple-minded integration if necessary
			if (do_top || do_bottom)
			{
				double dx = (face_zone.x2 - face_zone.x1) / divisions;
				double dy = (face_zone.y2 - face_zone.y1) / divisions;
				double x, y;
				//for (x = face_zone.x1 + dx/2.0; x < face_zone.x2; x += dx)
				int i;
				for (i = 0; i < ndiv; i++)
				{
					x = face_zone.x1 + dx * (((double) i) + 0.5);
					//for (y = face_zone.y1 + dy/2.0; y < face_zone.y2; y += dy)
					int j;
					for (j = 0; j < ndiv; j++)
					{
						y = face_zone.y1 + dy * (((double) j) + 0.5);
						bool point_in_prism = true;
						Point l_p(x, y, coord, coord);
						if (do_top && (coord > this->top.Interpolate(l_p)))
						{
							point_in_prism = false;
						}
						if (do_bottom
							&& (coord < this->bottom.Interpolate(l_p)))
						{
							point_in_prism = false;
						}
						if (!point_in_prism)
						{
							// Subtract area from polygon
							gpc_polygon *rect =
								rectangle(x - dx / 2.0, y - dy / 2.0,
										  x + dx / 2.0, y + dy / 2.0);
							gpc_polygon_clip(GPC_DIFF, polygon, rect,
											 polygon);
							gpc_free_polygon(rect);
							free_check_null(rect);
						}
					}

				}
			}
		}
		break;

	default:
		error_msg("Error illegal cell face in Prism::remove_top_bottom.",
				  EA_STOP);
		break;
	}
}
void
Prism::Convert_coordinates(PHAST_Transform::COORDINATE_SYSTEM cs,
						   PHAST_Transform * map2grid)
{
	if (this->perimeter.Get_defined())
	{
		this->perimeter.Convert_coordinates(cs, map2grid);
	}
	if (this->top.Get_defined())
	{
		this->top.Convert_coordinates(cs, map2grid);
	}
	if (this->bottom.Get_defined())
	{
		this->bottom.Convert_coordinates(cs, map2grid);
	}
	this->Set_bounding_box();
}
PHAST_Transform::COORDINATE_SYSTEM Prism::What_coordinates(void)
{
	if (
	  (this->perimeter.Get_coordinate_system() == this->top.Get_coordinate_system() ) &&
	  (this->perimeter.Get_coordinate_system() == this->bottom.Get_coordinate_system())
	  )
	{
		return this->perimeter.Get_coordinate_system();
	}
	return PHAST_Transform::NONE;
}

bool Prism::operator==(const Prism &other) const
{
	if (this->type != other.type)
	{
		return false;
	}
	if (this->box != other.box)
	{
		return false;
	}
	if (this->perimeter != other.perimeter)
	{
		return false;
	}
	if (this->prism_dip != other.prism_dip)
	{
		return false;
	}
	if (this->bottom != other.bottom)
	{
		return false;
	}
	if (this->top != other.top)
	{
		return false;
	}
	return true;
}

bool 
Prism::operator!=(const Prism &other) const
{
	return !(*this == other);
}

bool
Prism::Polygon_intersects_self(std::vector<Point> &vect)
{
	if (vect.size() < 3)
	{
		return false;
	}

	// check if first point is the same as the last point
	size_t last_vertex = vect.size();
	if (vect[0].get_coord()[0] == vect[last_vertex - 1].get_coord()[0] &&
		vect[0].get_coord()[1] == vect[last_vertex - 1].get_coord()[1])
	{
		--last_vertex;
	}

	double *a, *b, *c, *d;
	if (last_vertex == 3)
	{
		// special case (no d)
		a = vect[0].get_coord();
		b = vect[1].get_coord();
		c = vect[2].get_coord();

		// check for 3 collinear points by comparing slopes
		if ((b[0]-a[0]) == 0 || (c[0]-b[0]) == 0)
		{
			if ((b[0]-a[0]) == 0 && (c[0]-b[0]) == 0)
			{
				return true;
			}
		}
		else
		{
			double mab = (b[1]-a[1])/(b[0]-a[0]);
			double mbc = (c[1]-b[1])/(c[0]-b[0]);
			if (mab == mbc)
			{
				return true;
			}
		}
		return false;
	}

	double rn, sn, den, r, s;
	a = vect[0].get_coord();
	for (size_t i = 0; i < last_vertex; ++i)
	{
		// see comp.graphics.algorithms faq 1.03:
		// How do I find intersections of 2 2D line segments?
		b = vect[(i + 1) % last_vertex].get_coord();
		c = vect[(i + 2) % last_vertex].get_coord();
		for (size_t j = i+2; j <= i+last_vertex-2; ++j)
		{
			d   = vect[(j + 1) % last_vertex].get_coord();
			rn  = (a[1]-c[1])*(d[0]-c[0])-(a[0]-c[0])*(d[1]-c[1]);
			sn  = (a[1]-c[1])*(b[0]-a[0])-(a[0]-c[0])*(b[1]-a[1]);
			den = (b[0]-a[0])*(d[1]-c[1])-(b[1]-a[1])*(d[0]-c[0]);
			if (den != 0)
			{
				r = rn/den;
				s = sn/den;
				if (r >= 0 && r <= 1 && s >= 0 && s <= 1)
				{
					return true;
				}
			}
			else if (rn == 0)
			{
				// both AB and CD are collinear (coincident)
				// project values to each axis to check for overlap
				for (size_t k = 0; k < 2; ++k)
				{
					double minab = (a[k] < b[k]) ? a[k] : b[k];
					double maxab = (a[k] > b[k]) ? a[k] : b[k];
					if (minab <= c[k] && c[k] <= maxab)
					{
						if (minab != maxab)
						{
							return true;
						}
					}
					if (minab <= d[k] && d[k] <= maxab)
					{
						if (minab != maxab)
						{
							return true;
						}
					}
				}
			}
			c = d;
		}
		a = b;
	}
	return false;
}

#if defined(__WPHAST__) && defined(_DEBUG)
void Prism::Dump(CDumpContext& dc) const
{
	dc << "<Prism>\n";
	dc << "<top>\n";
	this->top.Dump(dc);
	dc << "</top>\n";
	dc << "<perimeter>\n";
	this->perimeter.Dump(dc);
	dc << "</perimeter>\n";
	dc << "<bottom>\n";
	this->bottom.Dump(dc);
	dc << "</bottom>\n";
	dc << "</Prism>\n";
}
#endif

bool Prism::Is_homogeneous(void)const
{
	return (this->perimeter.Get_user_coordinate_system() == this->top.Get_user_coordinate_system()
		&&
		this->perimeter.Get_user_coordinate_system() == this->bottom.Get_user_coordinate_system());
}

PHAST_Transform::COORDINATE_SYSTEM Prism::Get_best_coordinate_system(void)const
{
	// ARCRASTER > SHAPE > XYZT > XYZ > POINTS > NONE > CONSTANT
	//
	const Data_source::DATA_SOURCE_TYPE types[] = { 
		Data_source::ARCRASTER,
		Data_source::SHAPE,
		Data_source::XYZT,
		Data_source::XYZ,
		Data_source::POINTS,
		Data_source::NONE,
		Data_source::CONSTANT
	};

	const Data_source *sources[3];
	sources[0] = &this->top;
	sources[1] = &this->bottom;
	sources[2] = &this->perimeter;

	for (int t = 0; t < sizeof(types)/sizeof(types[0]); ++t)
	{
		for (int i = 0; i < 3; ++i)
		{
			if (sources[i]->Get_user_source_type() == types[t])
			{
				return sources[i]->Get_user_coordinate_system();
			}
		}
	}

	return this->perimeter.Get_user_coordinate_system();
}
