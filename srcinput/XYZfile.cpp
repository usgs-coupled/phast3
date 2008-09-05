#include "XYZfile.h"
#include "message.h"
#include <iostream>
#include <istream>
#include <fstream>
//#include <strstream>
#include "Point.h"
#include "PHAST_polygon.h"

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

XYZfile::XYZfile(void)
{
}
XYZfile::XYZfile(std::string filename, PHAST_Transform::COORDINATE_SYSTEM cs)
{
	std::string token;
	std::ifstream input (filename.c_str());
	bool error = false;
	if (!input.is_open())
	{
		error = true;
		std::ostringstream estring;
		estring << "Could not open file " << filename.c_str() << std::endl;
		error_msg(estring.str().c_str(), EA_STOP);
	}
	this->filename = filename;
	this->file_type = Filedata::XYZ;

	std::vector<Point> temp_pts;
	//this->Get_pts_map()[-1] = temp_pts;
	//this->columns = Read_points(input, this->Get_points(-1));
	this->columns = Read_points(input, temp_pts);
	this->coordinate_system = cs;
	this->Add_data_source(-1, temp_pts, this->columns, this->coordinate_system);

  // Set bounding box
  //this->Set_bounding_box();
}

XYZfile::~XYZfile(void)
{
}

bool XYZfile::Make_polygons( int field, PHAST_polygon &polygons)
{
	//this->Make_points(-1, polygons.Get_points());
	polygons.Get_points() = this->Get_points(-1);
	polygons.Get_begin().push_back(this->Get_points(-1).begin());
	polygons.Get_end().push_back(this->Get_points(-1).end());
	polygons.Set_coordinate_system(this->coordinate_system);
	polygons.Set_bounding_box();
	return true;
}


