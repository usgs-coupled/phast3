#include "KDtree/Point.h"
#include "NNInterpolator/NNInterpolator.h"
#include "Filedata.h"
#include "message.h"
#include "NNInterpolator/nan.h"

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

std::map < std::string, Filedata * >Filedata::file_data_map;
Filedata::Filedata(void)
{
	this->file_type = Filedata::NONE;
}

Filedata::~Filedata(void)
{
	//this->nni_map.clear();
	/*
	   std::map<int, std::vector<Point> >::iterator it1;
	   for (it1 = this->pts_map.begin(); it1 != this->pts_map.end(); it1++)
	   {
	   delete it1->second;
	   }
	 */
	std::map < int, Data_source * >::iterator it;
	for (it = this->data_source_map.begin();
		 it != this->data_source_map.end(); it++)
	{
		delete it->second;
	}

}
void
Clear_file_data_map(void)
{
	std::map < std::string, Filedata * >::iterator it;
	for (it = Filedata::file_data_map.begin();
		 it != Filedata::file_data_map.end(); it++)
	{
		delete it->second;
	}
	Filedata::file_data_map.clear();
}

void
Filedata::Add_data_source(int attribute, std::vector < Point > in_pts,
						  int columns,
						  PHAST_Transform::COORDINATE_SYSTEM system)
{
	// Store list of points if necessary
	if (this->data_source_map.size() == 0
		|| (this->data_source_map.find(attribute) ==
			this->data_source_map.end()))
	{
		//std::vector<Point> temp_pts;
		//this->Make_points(attribute, temp_pts);
		Data_source *ds = new Data_source(in_pts, system);
		ds->Set_columns(columns);
		ds->Set_attribute(attribute);
		this->data_source_map[attribute] = ds;
	}
}

std::vector < Point > &Filedata::Get_points(int attribute)
{
	if (this->data_source_map.find(attribute) != this->data_source_map.end())
	{
		return (this->data_source_map.find(attribute)->second->Get_points());
	}
	return (this->empty_pts);
}

Data_source *
Filedata::Get_data_source(int attribute)
{
	if (this->data_source_map.find(attribute) != this->data_source_map.end())
	{
		return (this->data_source_map.find(attribute)->second);
	}
	return (NULL);
}

double
Filedata::Interpolate(int attribute, Point p,
					  PHAST_Transform::COORDINATE_SYSTEM point_system,
					  PHAST_Transform * map2grid)
{
	if (this->Get_data_source(attribute) == NULL)
	{
		std::ostringstream estring;
		estring << "No data source defined for attribute " << attribute <<
			std::endl;
		error_msg(estring.str().c_str(), EA_CONTINUE);
		return (NaN);
	}
	if (this->Get_nni(attribute) == NULL)
	{
		std::ostringstream estring;
		estring << "No interpolator for file data source " << std::endl;
		error_msg(estring.str().c_str(), EA_STOP);
	}
	Data_source *ds = this->Get_data_source(attribute);
	switch (point_system)
	{
	case PHAST_Transform::GRID:
		switch (ds->Get_coordinate_system())
		{
		case PHAST_Transform::GRID:
			return (ds->Get_nni()->interpolate(p));
			break;
		case PHAST_Transform::MAP:
			{
				Point pt = p;
				map2grid->Inverse_transform(pt);
				return (ds->Get_nni()->interpolate(pt));
			}
		default:
			break;
		}
	case PHAST_Transform::MAP:
		switch (ds->Get_coordinate_system())
		{
		case PHAST_Transform::MAP:
			return (ds->Get_nni()->interpolate(p));
			break;
		case PHAST_Transform::GRID:
			{
				Point pt = p;
				map2grid->Transform(pt);
				return (ds->Get_nni()->interpolate(pt));
			}
		default:
			break;
		}
	case PHAST_Transform::NONE:
		break;
	}
	std::ostringstream estring;
	estring <<
		"A coordinate system was not defined for Filedata::Interpolate " <<
		std::endl;
	error_msg(estring.str().c_str(), EA_STOP);
	return (0.0);

}

NNInterpolator *
Filedata::Get_nni(int attribute)
{
	std::map < int, Data_source * >::iterator it =
		this->data_source_map.find(attribute);
	assert(it->second->Get_source_type() == Data_source::POINTS);
	if (it != this->data_source_map.end())
	{
		return (it->second->Get_nni());
	}
	return (NULL);
}

bool
Filedata::operator==(const Filedata &other) const
{
	if (this->file_type != other.file_type)
	{
		return false;
	}
	if (this->filename != other.filename)
	{
		return false;
	}
	if (this->data_source_map != other.data_source_map)
	{
		return false;
	}
	if (this->empty_pts != other.empty_pts)
	{
		return false;
	}
	if (this->coordinate_system != other.coordinate_system)
	{
		return false;
	}
	return true;
}

bool
Filedata::operator!=(const Filedata &other) const
{
	return !(*this == other);
}
