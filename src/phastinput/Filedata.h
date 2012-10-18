#if !defined(FILEDATA_H_INCLUDED)
#define FILEDATA_H_INCLUDED
#include <vector>
class Point;
class NNInterpolator;
#include "zone.h"
#include "gpc.h"
#include "PHAST_Transform.h"
#include "Data_source.h"
class PHAST_polygon;
#include <map>
#include <string>
class Filedata
{
  public:
	enum FILE_TYPE
	{
		SHAPE = 0,
		ARCRASTER = 1,
		XYZ = 2,
		NONE = 3,
		XYZT = 4
	};

	  Filedata(void);
	  Filedata(FILE_TYPE ft, std::string filename, int attribute, PHAST_Transform::COORDINATE_SYSTEM point_system, const Data_source *ds);
  public:
	virtual ~ Filedata(void);
	virtual bool Make_polygons(int field, PHAST_polygon & polygons) = 0;
	std::vector < Point > &Get_points(int attribute);
	double Interpolate(int attribute, Point p,
					   PHAST_Transform::COORDINATE_SYSTEM point_system,
					   PHAST_Transform * map2grid);
	void Add_data_source(int attribute, std::vector < Point > in_pts,
						 int columns,
						 PHAST_Transform::COORDINATE_SYSTEM system);

	Data_source *Get_data_source(int attribute);
	const Data_source *Get_data_source(int attribute)const;
	NNInterpolator *Get_nni(int attribute)const;
	FILE_TYPE Get_file_type(void)
	{
		return this->file_type;
	};
	void Set_file_type(FILE_TYPE ft)
	{
		this->file_type = ft;
	};

	std::string & Get_filename(void)
	{
		return this->filename;
	};
	void Set_filename(std::string fn)
	{
		this->filename = fn;
	};

	PHAST_Transform::COORDINATE_SYSTEM Get_coordinate_system(void)
	{
		return this->coordinate_system;
	};
	void Set_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM cs)
	{
		this->coordinate_system = cs;
		std::map<int, Data_source*>::iterator it = this->data_source_map.begin();
		for (; it != this->data_source_map.end(); ++it)
		{
			it->second->Set_coordinate_system(cs);
			it->second->Set_user_coordinate_system(cs);
		}
	};

	//void                               Add_to_pts_map (int attribute);
	// data
	static std::map < std::string, Filedata * >file_data_map;

	bool operator==(const Filedata &other) const;
	bool operator!=(const Filedata &other) const;

  protected:
	// Data
	// Because units may be converted, the Filedata does not have a bounding box
	// Data_source has the bounding box information 

	FILE_TYPE file_type;

	std::string filename;
	std::map < int, Data_source * >data_source_map;
	std::vector < Point > empty_pts;
	PHAST_Transform::COORDINATE_SYSTEM coordinate_system;	// Coordinate system of file X, Y data
};
void Clear_file_data_map(void);
#endif // FILEDATA_H_INCLUDED
