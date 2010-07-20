#include <cassert>
#include "zone.h"
#include "Data_source.h"
#include "message.h"
#include "Utilities.h"
#include "KDtree/Point.h"
#include "Shapefiles/Shapefile.h"
#include "ArcRaster.h"
#include "XYZfile.h"
#include "XYZTfile.h"
#include "PHAST_polygon.h"
#include "NNInterpolator/NNInterpolator.h"
#include "Filedata.h"
#include "UniqueMap.h"

#if defined(__WPHAST__) && defined(_DEBUG)
#include <afx.h> // CDumpContext
#undef min
#undef max
#endif

#define TRUE 1
#define FALSE 0

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

Data_source::Data_source(void)
{
	this->Init();
	this->filedata = NULL;
	this->tree = NULL;
	this->tree3d = NULL;
}

Data_source::Data_source(std::vector < Point > &in_pts,
						 PHAST_Transform::COORDINATE_SYSTEM system)
{
	this->Init();
	this->defined = true;
	//file_name;
	this->source_type = POINTS;
	this->source_type_user = POINTS;
	this->filedata = NULL;
	this->pts = in_pts;
	this->pts_user = in_pts;
	//PHAST_polygon       PHAST_polygons;
	//Polygon_tree       *tree;
	this->tree = NULL;
	//NNInterpolator *   nni;
	//struct cunit       h_units;
	//struct cunit       v_units;
	this->tree3d = NULL;
	//int                columns;
	//int                attribute;
	this->Set_bounding_box();
	//struct zone        box;
	this->coordinate_system = system;
	this->coordinate_system_user = system;
}
Data_source::~Data_source(void)
{
	// this->nni cleaned up in main Clear_NNInterpolatorList()
	if (this->tree != NULL)
		delete this->tree;
	delete this->tree3d;
	this->pts.clear();
}
Data_source::Data_source(const Data_source & r):
defined(r.defined),
file_name(r.file_name),
source_type(r.source_type),
source_type_user(r.source_type_user),
filedata(r.filedata),
pts(r.pts),
pts_user(r.pts_user),
phast_polygons(r.phast_polygons),
tree(NULL),
nni_unique(r.nni_unique),
tree3d(NULL),
columns(r.columns),
attribute(r.attribute),
box(r.box),
coordinate_system(r.coordinate_system),
coordinate_system_user(r.coordinate_system_user)
{
}
Data_source & Data_source::operator=(const Data_source & rhs)
{
	if (this != &rhs)
	{
		this->defined = rhs.defined;
		this->file_name = rhs.file_name;
		this->source_type = rhs.source_type;
		this->source_type_user = rhs.source_type_user;
		this->filedata = rhs.filedata;
		this->pts = rhs.pts;
		this->pts_user = rhs.pts_user;
		this->phast_polygons = rhs.phast_polygons;
		this->tree = NULL;		// lazy initialization
		//this->nni                    = rhs.nni;
		this->nni_unique = rhs.nni_unique;
		this->tree3d = NULL;	// lazy initialization
		this->columns = rhs.columns;
		this->attribute = rhs.attribute;
		this->box = rhs.box;
		this->coordinate_system = rhs.coordinate_system;
		this->coordinate_system_user = rhs.coordinate_system_user;
	}
	return *this;
}

void
Data_source::Init()
{
	this->pts.clear();
	this->file_name.clear();
	this->defined = false;
	this->source_type = Data_source::NONE;
	this->source_type_user = Data_source::NONE;
	this->attribute = -1;
	zone_init(&this->box);
	this->nni_unique = -1;
	this->columns = 0;
	this->tree = NULL;
	this->tree3d = NULL;
	this->coordinate_system = PHAST_Transform::NONE;
	this->coordinate_system_user = PHAST_Transform::NONE;
}

bool Data_source::Read(std::istream & lines, bool read_num)
{
	bool
		success = true;
	this->Init();

	// read information for top, or bottom
	const char *
		opt_list[] = {
		"constant",				/* 0 */
		"points",				/* 1 */
		"shape",				/* 2 */
		"xyz",					/* 3 */
		"arcraster",			/* 4 */
		"xyzt"                  /* 5 */
	};

	int
		count_opt_list = 6;
	std::vector < std::string > std_opt_list;
	int
		i;
	for (i = 0; i < count_opt_list; i++)
		std_opt_list.push_back(opt_list[i]);

	std::string type;
	lines >> type;

	int
		j = case_picker(std_opt_list, type);
	if (j < 0)
	{
		error_msg
			("Error reading data type (CONSTANT, POINTS, SHAPE, XYZ, or ArcRaster).",
			 EA_CONTINUE);
		return (false);
	}

	// Read coordinate system
	std::string cs;
	lines >> cs;
	std::transform(cs.begin(), cs.end(), cs.begin(),::tolower);
	std::string grid("grid"), map("map");
	if (cs == grid)
	{
		this->coordinate_system = PHAST_Transform::GRID;
		this->coordinate_system_user = PHAST_Transform::GRID;
	}
	else if (cs == map)
	{
		this->coordinate_system = PHAST_Transform::MAP;
		this->coordinate_system_user = PHAST_Transform::MAP;
	}
	else
	{
		this->coordinate_system = PHAST_Transform::NONE;
		this->coordinate_system_user = PHAST_Transform::NONE;
		error_msg
			("Error reading coordinate system (GRID or MAP) for CONSTANT, POINTS, SHAPE, XYZ, or ArcRaster.",
			 EA_CONTINUE);
		return (false);
	}

	switch (j)
	{
		// constant
	case 0:
		this->source_type = Data_source::CONSTANT;
		this->source_type_user = Data_source::CONSTANT;
		double
			elev;
		if (!(lines >> elev))
		{
			error_msg("Error reading constant elevation of prism top.",
					  EA_CONTINUE);
			success = false;
		}
		else
		{
			this->pts.push_back(Point(0.0, 0.0, elev, elev));
		}
		break;

		// points
	case 1:
		this->source_type = Data_source::POINTS;
		this->source_type_user = Data_source::POINTS;
		{
			this->columns = Read_points(lines, this->pts);

			// for prism set v = z
			if (this->columns < 4)
			{
				std::vector < Point >::iterator it;
				for (it = this->pts.begin(); it != this->pts.end(); it++)
				{
					it->set_v(it->z());
				}
			}
			this->pts_user = this->pts;
		}

		// Allow single point for 3d interpolator
		//if (this->pts.size() < 3)
		//{
		//  error_msg("Error reading top of prism, expected at least 3 points.", EA_CONTINUE);
		//  success = false;
		//}
		break;

		// Shape file
	case 2:
		this->source_type = Data_source::SHAPE;
		this->source_type_user = Data_source::SHAPE;
		//if (!(lines >> this->file_name)) success = false;
		//lines >> this->attribute;
		success =
			Data_source::Read_filename(lines, read_num, this->file_name,
									   this->attribute);
		if (!success)
			error_msg("Error reading shape file name or attribute number.",
					  EA_CONTINUE);
		break;
		// XYZ file
	case 3:
		this->source_type = Data_source::XYZ;
		this->source_type_user = Data_source::XYZ;
		//if (!(lines >> this->file_name)) success = false;
		success =
			Data_source::Read_filename(lines, false, this->file_name,
									   this->attribute);
		if (!success)
			error_msg("Error reading xyz file name.", EA_CONTINUE);
		break;
		// Arc Raster file
	case 4:
		this->source_type = Data_source::ARCRASTER;
		this->source_type_user = Data_source::ARCRASTER;
		//if (!(lines >> this->file_name)) success = false;
		success =
			Data_source::Read_filename(lines, false, this->file_name,
									   this->attribute);
		if (!success)
			error_msg("Error reading ArcRaster file name.", EA_CONTINUE);
		break;
	case 5:
		this->source_type = Data_source::XYZT;
		this->source_type_user = Data_source::XYZT;
		success =
			Data_source::Read_filename(lines, false, this->file_name,
									   this->attribute);
		if (!success)
			error_msg("Error reading xyzt file name.", EA_CONTINUE);
		break;
	default:
		success = false;
		break;
	}
	if (success)
		this->defined = true;
	return (success);
}
bool Data_source::Read_mixture(std::istream & lines)
{
	bool
		success = true;
	this->Init();

	// read information for property
	const char *
		opt_list[] = {
		"constant",				/* 0 */
		"points",				/* 1 */
		"xyz"					/* 2 */
	};

	int	count_opt_list = 3;
	std::vector < std::string > std_opt_list;
	int	i;
	for (i = 0; i < count_opt_list; i++)
		std_opt_list.push_back(opt_list[i]);

	std::string type;
	lines >> type;

	int
		j = case_picker(std_opt_list, type);
	if (j < 0)
	{
		error_msg
			("Error reading data type (CONSTANT, POINTS, or XYZ).",
			 EA_CONTINUE);
		return (false);
	}
	bool no_coordinate_system = false;
	// Read coordinate system
	std::string cs;
	lines >> cs;
	std::transform(cs.begin(), cs.end(), cs.begin(),::tolower);
	std::string grid("grid"), map("map");
	if (cs == grid)
	{
		this->coordinate_system = PHAST_Transform::GRID;
		this->coordinate_system_user = PHAST_Transform::GRID;
	}
	else if (cs == map)
	{
		this->coordinate_system = PHAST_Transform::MAP;
		this->coordinate_system_user = PHAST_Transform::MAP;
	}
	else if (j == 0)
	{
		this->coordinate_system = PHAST_Transform::GRID;
		this->coordinate_system_user = PHAST_Transform::GRID;
		no_coordinate_system = true;
	}
	else
	{

		this->coordinate_system = PHAST_Transform::NONE;
		this->coordinate_system_user = PHAST_Transform::NONE;
		error_msg ("Error reading coordinate system (GRID or MAP) for CONSTANT, POINTS, SHAPE, XYZ, or ArcRaster.",
				EA_CONTINUE);
			return (false);
	}

	switch (j)
	{
		// constant
	case 0:
		{
			bool err_flag = false;
			this->source_type = Data_source::CONSTANT;
			this->source_type_user = Data_source::CONSTANT;
			double elev;
			if (no_coordinate_system)
			{
				if (sscanf(cs.c_str(),"%lf", &elev) != 1) err_flag = true;
			}
			else
			{
				if (!(lines >> elev)) err_flag = true;
			}
			if (err_flag)
			{
				error_msg("Error reading constant property.",
					EA_CONTINUE);
				success = false;
			}
			else
			{
				this->pts.push_back(Point(0.0, 0.0, elev, elev));
			}
			break;
		}

		// points
	case 1:
		this->source_type = Data_source::POINTS;
		this->source_type_user = Data_source::POINTS;
		{
			this->columns = Read_points(lines, this->pts);

			// for prism set v = z
			if (this->columns < 4)
			{
				std::vector < Point >::iterator it;
				for (it = this->pts.begin(); it != this->pts.end(); it++)
				{
					it->set_v(it->z());
				}
			}
		}
		break;

		// XYZ file
	case 2:
		this->source_type = Data_source::XYZ;
		this->source_type_user = Data_source::XYZ;
		//if (!(lines >> this->file_name)) success = false;
		success =
			Data_source::Read_filename(lines, false, this->file_name,
									   this->attribute);
		if (!success)
			error_msg("Error reading xyz file name.", EA_CONTINUE);
		break;

	default:
		success = false;
		break;
	}
	if (success)
		this->defined = true;
	return (success);
}
bool Data_source::Read_filename(std::istream & lines, bool read_num,
								std::string & filename, int &num)
{
	bool
		success = true;

	std::string line;
	std::getline(lines, line);

	std::string std_token;

	std::string::reverse_iterator rit;
	int
		erase = 0;
	for (rit = line.rbegin(); rit != line.rend(); rit++)
	{
		if (isspace(*rit))
		{
			erase++;
			continue;
		}
		break;
	}
	if (rit == line.rend())
	{
		error_msg("Missing file name", EA_CONTINUE);
		return false;
	}
	line = line.substr(0, line.size() - erase);
	if (read_num)
	{
		int
			keep = 0;
		for (rit = line.rbegin(); rit != line.rend(); rit++)
		{
			if (!isspace(*rit))
			{
				keep++;
				continue;
			}
			break;
		}
		if (rit == line.rend())
		{
			error_msg("Missing attribute number", EA_CONTINUE);
			return false;
		}
		std::string number = line.substr(line.size() - keep, line.size());
		if (sscanf(number.c_str(), "%d", &num) != 1)
		{
			error_msg("Expecting attribute number", EA_CONTINUE);
			return false;
		}
		line = line.substr(0, line.size() - keep);
	}

	// strip front and back
	erase = 0;
	for (rit = line.rbegin(); rit != line.rend(); rit++)
	{
		if (isspace(*rit))
		{
			erase++;
			continue;
		}
		break;
	}
	line = line.substr(0, line.size() - erase);
	erase = 0;
	std::string::iterator it;
	for (it = line.begin(); it != line.end(); it++)
	{
		if (isspace(*it))
		{
			erase++;
			continue;
		}
		break;
	}
	filename = line.substr(erase, line.size());

	return success;
}
#ifdef SKIP
void
Data_source::Tidy(const bool make_nni)
{
	// First read data
	switch (this->source_type)
	{
	case Data_source::SHAPE:
		// read data from shape file
		if (Filedata::file_data_map.find(this->file_name) ==
			Filedata::file_data_map.end())
		{
			Shapefile *sf =
				new Shapefile(this->file_name, this->coordinate_system);
			sf->Set_coordinate_system(this->coordinate_system);
			Filedata::file_data_map[this->file_name] = (Filedata *) sf;
		}
		// Add Data_source for attribute
		{
			Filedata *f =
				Filedata::file_data_map.find(this->file_name)->second;
			if (f->Get_file_type() != Filedata::SHAPE)
				error_msg("File read as non-shape and shape file?", EA_STOP);
			this->filedata = f;
			if (f->Get_data_source(this->attribute) == NULL)
			{
				Shapefile *sf = dynamic_cast < Shapefile * >(f);
				std::vector < Point > temp_pts;
				sf->Make_points(this->attribute, temp_pts);
				int col = 3;
				if (this->attribute < 0)
					col = 2;
				sf->Add_data_source(this->attribute, temp_pts, col,
									this->coordinate_system);
			}
		}
		break;
	case Data_source::ARCRASTER:
		if (Filedata::file_data_map.find(this->file_name) ==
			Filedata::file_data_map.end())
		{
			ArcRaster *ar =
				new ArcRaster(this->file_name, this->coordinate_system);
			//ar->Set_coordinate_system (this->coordinate_system);
			Filedata::file_data_map[this->file_name] = (Filedata *) ar;
		}
		{
			Filedata *f =
				Filedata::file_data_map.find(this->file_name)->second;
			if (f->Get_file_type() != Filedata::ARCRASTER)
				error_msg("File read as non arcraster and arcraster file?",
						  EA_STOP);
			this->filedata = f;
			//Data_source added to data_source_map in ArcRaster constructor
		}
		break;
	case Data_source::XYZ:
		if (Filedata::file_data_map.find(this->file_name) ==
			Filedata::file_data_map.end())
		{
			XYZfile *xyz =
				new XYZfile(this->file_name, this->coordinate_system);
			xyz->Set_coordinate_system(this->coordinate_system);
			Filedata::file_data_map[this->file_name] = (Filedata *) xyz;
		}
		{
			Filedata *f =
				Filedata::file_data_map.find(this->file_name)->second;
			if (f->Get_file_type() != Filedata::XYZ)
				error_msg("File read as non XYZ and XYZ file?", EA_STOP);
			this->filedata = f;
			//Data_source added to data_source_map in XYZfile constructor
		}
		break;
	case Data_source::CONSTANT:
	case Data_source::POINTS:
	case Data_source::NONE:
		break;
	}

	// Convert coordinate system if necessary
	this->Convert_coordinates(target_coordinate_system, map_to_grid);

	// Make nni if necessary
	// First read data
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
	case Data_source::POINTS:
		if (make_nni)
		{
			bool success = this->Make_nni();
			assert(success);
		}
		break;
	case Data_source::CONSTANT:
	case Data_source::NONE:
		break;
	}

	this->Set_bounding_box();
}
#endif
void
Data_source::Tidy(const bool make_nni)
{
	// First read data
	switch (this->source_type)
	{
	case Data_source::SHAPE:
		// read data from shape file
		if (Filedata::file_data_map.find(this->file_name) ==
			Filedata::file_data_map.end())
		{
			Shapefile *sf =
				new Shapefile(this->file_name, this->coordinate_system);
			sf->Set_coordinate_system(this->coordinate_system);
			Filedata::file_data_map[this->file_name] = (Filedata *) sf;
		}
		// Add Data_source for attribute
		{
			Filedata *f =
				Filedata::file_data_map.find(this->file_name)->second;
			if (f->Get_file_type() != Filedata::SHAPE)
				error_msg("File read as non-shape and shape file?", EA_STOP);
			this->filedata = f;
			if (f->Get_data_source(this->attribute) == NULL)
			{
				Shapefile *sf = dynamic_cast < Shapefile * >(f);
				std::vector < Point > temp_pts;
				sf->Make_points(this->attribute, temp_pts);
				int col = 3;
				if (this->attribute < 0)
					col = 2;
				sf->Add_data_source(this->attribute, temp_pts, col,
									this->coordinate_system);
			}
		}
		break;
	case Data_source::ARCRASTER:
		if (Filedata::file_data_map.find(this->file_name) ==
			Filedata::file_data_map.end())
		{
			ArcRaster *ar =
				new ArcRaster(this->file_name, this->coordinate_system);
			//ar->Set_coordinate_system (this->coordinate_system);
			Filedata::file_data_map[this->file_name] = (Filedata *) ar;
		}
		{
			Filedata *f =
				Filedata::file_data_map.find(this->file_name)->second;
			if (f->Get_file_type() != Filedata::ARCRASTER)
				error_msg("File read as non arcraster and arcraster file?",
						  EA_STOP);
			this->filedata = f;
			//Data_source added to data_source_map in ArcRaster constructor
		}
		break;
	case Data_source::XYZ:
		if (Filedata::file_data_map.find(this->file_name) ==
			Filedata::file_data_map.end())
		{
			XYZfile *xyz =
				new XYZfile(this->file_name, this->coordinate_system);
			xyz->Set_coordinate_system(this->coordinate_system);
			Filedata::file_data_map[this->file_name] = (Filedata *) xyz;
		}
		{
			Filedata *f =
				Filedata::file_data_map.find(this->file_name)->second;
			if (f->Get_file_type() != Filedata::XYZ)
				error_msg("File read as non XYZ and XYZ file?", EA_STOP);
			this->filedata = f;
			//Data_source added to data_source_map in XYZfile constructor
		}
		break;
	case Data_source::CONSTANT:
	case Data_source::POINTS:
		this->pts_user = this->pts;
		break;
	case Data_source::XYZT:
		if (Filedata::file_data_map.find(this->file_name) ==
			Filedata::file_data_map.end())
		{
			XYZTfile *xyzt = new XYZTfile(this->file_name, this->coordinate_system);
			xyzt->Set_coordinate_system(this->coordinate_system);
			Filedata::file_data_map[this->file_name] = (Filedata *) xyzt;
		}
		{
			Filedata *f = Filedata::file_data_map.find(this->file_name)->second;
			if (f->Get_file_type() != Filedata::XYZT)
				error_msg("File read as non XYZT and XYZT file?", EA_STOP);
			this->filedata = f;
			//Data_source added to data_source_map in XYZTfile constructor
		}
		break;
	case Data_source::NONE:
		break;
	}

	// Convert coordinate system if necessary
	// !!!! Not converting coordinate system here
	// this->Convert_coordinates(target_coordinate_system, map_to_grid);
#ifdef SKIP
	// Make nni if necessary
	// First read data
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
	case Data_source::POINTS:
		if (make_nni)
		{
			bool success = this->Make_nni();
			assert(success);
		}
		break;
	case Data_source::CONSTANT:
	case Data_source::NONE:
		break;
	}
#endif
	this->Set_bounding_box();
}
std::vector < Point > &Data_source::Get_points()
{
	switch (this->source_type)
	{
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
	case Data_source::SHAPE:
	case Data_source::XYZT:
//    {
//      std::map<std::string,Filedata *>::iterator it = Filedata::file_data_map.find(this->file_name);
//      Filedata *f_ptr = it->second;
//      std::vector<Point> pts = f_ptr->Get_points(this->attribute);
//    }
		return (Filedata::file_data_map.find(this->file_name)->second->
				Get_points(this->attribute));
		break;
	default:
		break;
	}
	/*
	   case Data_source::CONSTANT:
	   case Data_source::POINTS:
	   case Data_source::NONE:
	 */
	return (this->pts);
}

std::vector < Point > &Data_source::Get_user_points()
{
	return (this->pts_user);
}

void Data_source::Set_user_points(std::vector<Point> &m_pts)
{
	this->pts_user = m_pts;
}

bool Data_source::Make_polygons()
{
	Data_source *
		ds1 = this->Get_data_source_with_points();
	//this->phst_polygons.Clear();
	assert(ds1 != NULL);
	ds1->phast_polygons.Clear();
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::XYZ:
		// go to file data and make polygon(s)
		if (Filedata::file_data_map.find(this->file_name) !=
			Filedata::file_data_map.end())
		{
			Filedata *
				f = Filedata::file_data_map.find(this->file_name)->second;
			Data_source *
				ds = f->Get_data_source(this->attribute);
			//return(f->Make_polygons(this->attribute, this->phst_polygons));
			return (f->Make_polygons(this->attribute, ds->phast_polygons));
		}
		break;

	case Data_source::POINTS:
		if (this->phast_polygons.Get_points().size() == 0)
		{
			this->phast_polygons.Get_points() = this->pts;
			this->phast_polygons.Get_begin().push_back(this->phast_polygons.
													   Get_points().begin());
			this->phast_polygons.Get_end().push_back(this->phast_polygons.
													 Get_points().end());
			this->phast_polygons.Set_coordinate_system(this->
													   coordinate_system);
			this->phast_polygons.Set_bounding_box();
			return true;
		}
		break;
	default:
		/*
		   case Data_source::ARCRASTER:
		   case Data_source::CONSTANT:
		   case Data_source::NONE:
		 */
		break;
	}
	return false;
}

struct zone *
Data_source::Get_bounding_box()
{
	return (&this->box);
}

void
Data_source::Set_bounding_box(void)
{
	Point min(this->Get_points().begin(), this->Get_points().end(),
			  Point::MIN);
	Point max(this->Get_points().begin(), this->Get_points().end(),
			  Point::MAX);
	this->box.zone_defined = TRUE;
	this->box.x1 = min.x();
	this->box.y1 = min.y();
	this->box.z1 = min.z();
	this->box.x2 = max.x();
	this->box.y2 = max.y();
	this->box.z2 = max.z();
}

void
Data_source::Set_points(std::vector < Point > &in_pts)
{
	this->pts = this->pts_user = in_pts;
}
double
Data_source::Interpolate(const Point & p)
{
	// By default, point is in grid coordinate system
	PHAST_Transform::COORDINATE_SYSTEM point_system = PHAST_Transform::GRID;
	// map_to grid is default transform

	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
		{
			// go to file data and make polygon(s)

			if (Filedata::file_data_map.find(this->file_name) !=
				Filedata::file_data_map.end())
			{
				Filedata *f =
					Filedata::file_data_map.find(this->file_name)->second;
				return (f->
						Interpolate(this->attribute, p, point_system,
									map_to_grid));
				//Filedata *f = Filedata::file_data_map.find(this->file_name)->second;
				//NNInterpolator *nni = f->Get_nni_map().find(this->attribute)->second;
				//return (nni->interpolate(p));
			}
		}
		break;

	case Data_source::CONSTANT:
		return this->pts.begin()->z();
		break;
	case Data_source::POINTS:
		if (this->Get_nni() != NULL)
		{
			return (this->Get_nni()->
					interpolate(p, point_system, map_to_grid));
		}

	default:
		break;
	}
	return (-999.);
}

double
Data_source::Interpolate(const Point & p,
						 PHAST_Transform::COORDINATE_SYSTEM point_system,
						 PHAST_Transform * map2grid)
{
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
		{
			// go to file data and make polygon(s)

			if (Filedata::file_data_map.find(this->file_name) !=
				Filedata::file_data_map.end())
			{
				Filedata *f =
					Filedata::file_data_map.find(this->file_name)->second;
				return (f->
						Interpolate(this->attribute, p, point_system,
									map2grid));
				//Filedata *f = Filedata::file_data_map.find(this->file_name)->second;
				//NNInterpolator *nni = f->Get_nni_map().find(this->attribute)->second;
				//return (nni->interpolate(p));
			}
		}
		break;

	case Data_source::CONSTANT:
		return this->pts.begin()->z();
		break;
	case Data_source::POINTS:
		if (this->Get_nni() != NULL)
		{
			return (this->Get_nni()->interpolate(p));
		}
	default:
		break;
	}
	return (-999.);
}
#ifdef SKIP
NNInterpolator *
Data_source::Get_nni(void)
{
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
		{
			return (this->filedata->Get_nni(this->attribute));
		}
		break;

	case Data_source::CONSTANT:
		return (NULL);
		break;
	case Data_source::POINTS:
		if (NNInterpolator::NNInterpolatorMap.find(this->nni_unique) !=
			NNInterpolator::NNInterpolatorMap.end())
		{
			return (NNInterpolator::NNInterpolatorMap.at(this->nni_unique));
		}
		else
		{
			return (NULL);
		}
		break;
	default:
		break;
	}
	return NULL;
}
#endif
NNInterpolator *
Data_source::Get_nni(void)
{
	/*	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
	case Data_source::POINTS:
		if (make_nni)
		{
			bool success = this->Make_nni();
			assert(success);
		}
		break;
	case Data_source::CONSTANT:
	case Data_source::NONE:
		break;
	}*/
//bool Data_source::Make_nni(void)
//{
//	Data_source *
//		ds = this->Get_data_source_with_points();
//	if (ds == NULL)
//		return false;
//
//	if (ds->nni_unique == -1)
//	{
//		NNInterpolator *
//			nni = new NNInterpolator();
//		nni->preprocess(ds->Get_points(), ds->coordinate_system);
//		ds->Set_nni_unique(NNInterpolator::NNInterpolatorMap.push_back(nni));
//	}
//	return true;
//}

	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
	case Data_source::POINTS:
		{
			Data_source * ds = this->Get_data_source_with_points();
			if (ds == NULL) return (NULL);
			if (ds->nni_unique == std::string::npos)
			{
				NNInterpolator * nni = new NNInterpolator();
				nni->preprocess(ds->Get_points(), ds->coordinate_system);
				ds->Set_nni_unique(NNInterpolator::NNInterpolatorMap.push_back(nni));
			}
			return (NNInterpolator::NNInterpolatorMap.at(ds->nni_unique));
		}
		break;
	default:
		break;
	}
	return NULL;
}
void
Data_source::Replace_nni(NNInterpolator * nni_ptr)
{
	Data_source *ds;
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
		ds = this->filedata->Get_data_source(this->attribute);
		break;
	case Data_source::CONSTANT:
		return;
		break;
	case Data_source::POINTS:
		ds = this;
		break;
	default:
		return;
		break;
	}
	assert(ds != NULL);
	if (ds->nni_unique != std::string::npos)
	{
		NNInterpolator::NNInterpolatorMap.replace(ds->nni_unique, nni_ptr);
	}
	else
	{
		ds->Set_nni_unique(NNInterpolator::NNInterpolatorMap.
						   push_back(nni_ptr));
	}
	return;
}

std::ostream & operator<<(std::ostream & os, const Data_source & ds)
{
	const char *coor_name[] = { " MAP ", " GRID ", " NONE " };

	size_t cs = ds.coordinate_system_user;
	assert(cs >= PHAST_Transform::MAP && cs <= PHAST_Transform::NONE);

	switch (ds.source_type)
	{
	case Data_source::SHAPE:
		os << "SHAPE     " << coor_name[cs] << ds.Get_file_name();
		if (ds.Get_attribute() != -1)
		{
			os << " " << ds.Get_attribute();
		}
		os << std::endl;
		break;
	case Data_source::ARCRASTER:
		os << "ARCRASTER " << coor_name[cs] << ds.
			Get_file_name() << std::endl;
		break;
	case Data_source::XYZ:
		os << "XYZ       " << coor_name[cs] << ds.
			Get_file_name() << std::endl;
		break;
	case Data_source::CONSTANT:
		if (ds.source_type_user != Data_source::NONE)
		{
			os << "CONSTANT  " << coor_name[cs] << ds.pts.front().
				z() << std::endl;
		}
		break;
	case Data_source::POINTS:
		os << "POINTS" << coor_name[cs] << std::endl;
		{
			std::vector < Point >::const_iterator citer = ds.pts_user.begin();
			for (; citer != ds.pts_user.end(); ++citer)
			{
				os << "\t\t\t" << citer->x() << " " << citer->
					y() << " " << citer->z() << std::endl;
			}
			os << "\t\t\tend_points" << std::endl;
		}
		break;
	case Data_source::NONE:
		break;
	default:
		break;
	}
	return os;
}

void
Data_source::Set_file_name(std::string fn)
{
	// check if in map
#if SKIP
	if (this->file_name.size())
	{
		std::map < std::string, Filedata * >::iterator fi =
			Filedata::file_data_map.find(this->file_name);
		if (fi != Filedata::file_data_map.end())
		{
			// if found update map
			assert(fi->second != NULL);
			assert(this->filedata == fi->second);
			this->filedata = fi->second;
			Filedata::file_data_map.erase(fi);
			Filedata::file_data_map[fn] = this->filedata;
		}
	}
#endif
	assert(fn.size());
	this->file_name = fn;
}

void
Data_source::Convert_coordinates(PHAST_Transform::COORDINATE_SYSTEM target,
								 PHAST_Transform * map2grid)
{
	Data_source *ds = this->Get_data_source_with_points();

	switch (target)
	{
	case PHAST_Transform::NONE:
		break;
	case PHAST_Transform::GRID:
		if (ds->coordinate_system == PHAST_Transform::MAP)
		{
			// Points
			map2grid->Transform(ds->pts);
			//this->Set_bounding_box();
			ds->Set_bounding_box();
			ds->Set_coordinate_system(PHAST_Transform::GRID);
			ds->nni_unique = -1;
			ds->phast_polygons.Clear();

			// nni
			//if (ds->Get_nni() != NULL)
			//{
			//	NNInterpolator *nni_ptr = new NNInterpolator;
			//	nni_ptr->preprocess(ds->Get_points(), PHAST_Transform::GRID);
			//	ds->Replace_nni(nni_ptr);
			//}

			// Todo polygons
		}
		break;
	case PHAST_Transform::MAP:
		if (this->coordinate_system == PHAST_Transform::GRID)
		{
			// Points
			map2grid->Inverse_transform(ds->pts);
			//this->Set_bounding_box();
			ds->Set_bounding_box();
			ds->Set_coordinate_system(PHAST_Transform::MAP);
			ds->nni_unique = -1;
			ds->phast_polygons.Clear();

			// nni
			/*if (ds->Get_nni() != NULL)
			{
				NNInterpolator *nni_ptr = new NNInterpolator;
				nni_ptr->preprocess(ds->Get_points(), PHAST_Transform::MAP);
				this->Replace_nni(nni_ptr);
			}*/

			// Todo polygons
		}
		break;
	}
	if (ds != this)
	{
		this->coordinate_system = ds->Get_coordinate_system();
		this->Set_bounding_box();
	}
}
Data_source *
Data_source::Get_data_source_with_points(void)
{
	Data_source *ds = NULL;
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
	case Data_source::XYZT:
		assert(this->filedata != NULL);
		ds = this->filedata->Get_data_source(this->attribute);
		break;
	case Data_source::CONSTANT:
	case Data_source::POINTS:
		ds = this;
		break;
	case NONE:
		ds = NULL;
	}
	assert(ds != NULL);
	return (ds);
}

bool Data_source::Make_nni(void)
{
	Data_source *
		ds = this->Get_data_source_with_points();
	if (ds == NULL)
		return false;

	//if (ds->nni_unique == -1)
	if (ds->nni_unique == std::string::npos)

	{
		NNInterpolator *
			nni = new NNInterpolator();
		nni->preprocess(ds->Get_points(), ds->coordinate_system);
		ds->Set_nni_unique(NNInterpolator::NNInterpolatorMap.push_back(nni));
	}
	return true;
}

PHAST_Transform::COORDINATE_SYSTEM Data_source::Get_coordinate_system(void) const
{
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
		{
			const Data_source *
				ds =
				const_cast <
				Data_source * >(this)->Get_data_source_with_points();
			return ds->Get_coordinate_system();
		}
		break;
	default:
		break;
	}
	return this->coordinate_system;
}

PHAST_Transform::COORDINATE_SYSTEM Data_source::Get_user_coordinate_system(void) const
{
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
		{
			const Data_source *
				ds =
				const_cast <
				Data_source * >(this)->Get_data_source_with_points();
			return ds->Get_user_coordinate_system();
		}
		break;
	default:
		break;
	}
	return this->coordinate_system_user;
}


int
Data_source::Get_columns(void)
{
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::ARCRASTER:
	case Data_source::XYZ:
		{
			Data_source *ds = this->Get_data_source_with_points();
			return ds->Get_columns();
		}
		break;
	default:
		break;
	}
	return this->columns;
}

PHAST_polygon & Data_source::Get_phast_polygons(void)
{
	Data_source *
		ds = this->Get_data_source_with_points();
	if (ds->phast_polygons.Get_points().size() > 2)
		return (ds->phast_polygons);

	// Data source does not contain a good PHAST_polygon
	switch (this->source_type)
	{
	case Data_source::SHAPE:
	case Data_source::XYZ:
	case POINTS:
		this->Make_polygons();
		return (ds->phast_polygons);
		break;
	case CONSTANT:
		error_msg
			("Error in Get_phast_polygons, CONSTANT is not suitable for perimeter.",
			 EA_CONTINUE);
		return (this->phast_polygons);
		break;
	case Data_source::ARCRASTER:
		error_msg
			("Error in Get_phast_polygons, ArcRaster file is not suitable for perimeter.",
			 EA_CONTINUE);
		return (this->phast_polygons);
		break;
	default:
		break;
	}
	error_msg
		("Error in Get_phast_polygons, could not determine data source type.",
		 EA_CONTINUE);
	return (this->phast_polygons);
}

bool Data_source::operator==(const Data_source &other) const
{
	if (this->defined != other.defined)
	{
		return false;
	}
	if (this->file_name != other.file_name)
	{
		return false;
	}
	if (this->source_type != other.source_type)
	{
		return false;
	}
// COMMENT: {12/6/2008 9:06:03 PM}	if (this->source_type_user != other.source_type_user)
// COMMENT: {12/6/2008 9:06:03 PM}	{
// COMMENT: {12/6/2008 9:06:03 PM}		return false;
// COMMENT: {12/6/2008 9:06:03 PM}	}
	if (this->filedata == 0 && other.filedata != 0)
	{
		return false;
	}
	if (this->filedata != 0 && other.filedata == 0)
	{
		return false;
	}
	if (*this->filedata != *other.filedata)
	{
		return false;
	}
	if (this->pts != other.pts)
	{
		return false;
	}
	if (this->pts_user != other.pts_user)
	{
		return false;
	}
	// TODO PHAST_polygon phast_polygons;
	// TODO Polygon_tree *tree;
	// TODO KDtree *tree3d;
	if (this->columns != other.columns)
	{
		return false;
	}
	if (this->attribute != other.attribute)
	{
		return false;
	}
	if (this->box != other.box)
	{
		return false;
	}
	if (this->coordinate_system != other.coordinate_system)
	{
		return false;
	}
	if (this->coordinate_system_user != other.coordinate_system_user)
	{
		return false;
	}
	return true;
}

bool Data_source::operator!=(const Data_source &other) const
{
	return !(*this == other);
}

#if defined(__WPHAST__) && defined(_DEBUG)
CDumpContext& operator<<(CDumpContext& dc, Data_source::DATA_SOURCE_TYPE st)
{
	switch (st)
	{
	case Data_source::SHAPE:
		dc << "SHAPE";
		break;
	case Data_source::ARCRASTER:
		dc << "ARCRASTER";
		break;
	case Data_source::XYZ:
		dc << "XYZ";
		break;
	case Data_source::CONSTANT:
		dc << "CONSTANT";
		break;
	case Data_source::POINTS:
		dc << "POINTS";
		break;
	case Data_source::NONE:
		dc << "NONE";
		break;
	default:
		dc << "<ERROR/>";
		break;
	}
	return dc;
}
CDumpContext& operator<<(CDumpContext& dc, PHAST_Transform::COORDINATE_SYSTEM cs)
{
	switch (cs)
	{
	case PHAST_Transform::MAP:
		dc << "MAP";
		break;
	case PHAST_Transform::GRID:
		dc << "GRID";
		break;
	case PHAST_Transform::NONE:
		dc << "NONE";
		break;
	default:
		dc << "COORDINATE_SYSTEM_ERROR";
		break;
	}
	return dc;
}

CDumpContext& operator<<(CDumpContext& dc, const std::vector<Point>& pts)
{
	std::vector<Point>::const_iterator it = pts.begin();
	for (; it != pts.end(); ++it)
	{
		Point pt(*it);
		double *c = pt.get_coord();
		dc << c[0] << ", " << c[1] << ", " << c[2] << "\n";
	}
	return dc;
}

void Data_source::Dump(CDumpContext& dc) const
{
	dc << "<Data_source>\n";
	dc << "<defined>" << (this->defined ? "true" : "false") << "</defined>\n";
	dc << "<source_type>" << this->source_type << "</source_type>\n";
	dc << "<source_type_user>" << this->source_type_user << "</source_type_user>\n";
	dc << "<pts coordinate_system=" << "\"" << this->coordinate_system << "\"" << ">\n";
	dc << this->pts;
	dc << "</pts>\n";
	dc << "<pts_user coordinate_system=" << "\"" << this->coordinate_system_user << "\"" << ">\n";
	dc << this->pts_user;
	dc << "</pts_user>\n";
	dc << "</Data_source>\n";
	//this->source_type
}

#endif
