#if !defined(DATA_SOURCE_H_INCLUDED)
#define DATA_SOURCE_H_INCLUDED
#include <sstream>
#include <vector>
#include <map>

#include "gpc.h"
#include "PHAST_polygon.h"
#include "unit_impl.h"
#include "Polygon_tree.h"
#include "KDtree/KDtree.h"
#include "PHAST_Transform.h"
class Filedata;
class Point;
struct zone;
class NNInterpolator;

class Data_source
{
  public:
	enum DATA_SOURCE_TYPE
	{
		SHAPE = 0,
		ARCRASTER = 1,
		XYZ = 2,
		CONSTANT = 3,
		POINTS = 4,
		NONE = 5,
		XYZT = 6
	};
	  Data_source(void);
	  Data_source(std::vector < Point > &in_pts,
				  PHAST_Transform::COORDINATE_SYSTEM system);
	  Data_source(const Data_source & r);

	 ~Data_source(void);

// Data read from a file are stored in Filedata
// Data read for CONSTANT and POINTS are stored here in Data_source
// Files:
//   Units are converted for file data in Make_points and Make_polygon
//   Data stored in pts_map and nni_map have had units converted
// CONSTANT and POINTS
//   Units are converted in Data_source::Tidy so that this->pts has been converted.

	void Init();
	bool Read(std::istream & lines, bool read_num);
	bool Read_mixture(std::istream & lines);
	void Tidy(const bool make_nni);
	void Convert_coordinates(PHAST_Transform::COORDINATE_SYSTEM target,
							 PHAST_Transform * map2grid);
	//void                     Add_to_file_map        (Filedata *f, const bool make_nni);
	//void                     Add_nni_to_data_source (void);
	bool Make_polygons(void);
	bool Make_nni(void);
	double Interpolate(const Point & p);
	double Interpolate(const Point & p,
					   PHAST_Transform::COORDINATE_SYSTEM point_system,
					   PHAST_Transform * map2grid);
	//bool                     Read_units             (std::istream &lines);
	static bool Read_filename(std::istream & lines, bool read_num,
							  std::string & filename, int &num);
	// Getter and setter
	bool Get_defined(void)
	{
		return this->defined;
	};
	void Set_defined(bool tf)
	{
		this->defined = tf;
	};

	std::string Get_file_name(void) const
	{
		return this->file_name;
	};
	void Set_file_name(std::string fn);

	DATA_SOURCE_TYPE Get_source_type(void) const
	{
		return this->source_type;
	}
	void Set_source_type(DATA_SOURCE_TYPE dt)
	{
		this->source_type = dt;
	};

	DATA_SOURCE_TYPE Get_user_source_type(void) const
	{
		return this->source_type_user;
	}
	void Set_user_source_type(DATA_SOURCE_TYPE dt)
	{
		this->source_type_user = dt;
	};

	Filedata *Get_filedata(void) const
	{
		return this->filedata;
	};
	void Set_filedata(Filedata *f)
	{
		this->filedata = f;
	};

	std::vector < Point > &Get_points(void);
	void Set_points(std::vector < Point > &pts);

	std::vector < Point > &Get_user_points(void);
	void Set_user_points(std::vector < Point > &pts);

	bool            Test_phast_polygons(void);
	PHAST_polygon & Get_phast_polygons(void);
	bool            Test_tree(void);
	Polygon_tree *  Get_tree(void);

	NNInterpolator *Get_nni(void);
	void Replace_nni(NNInterpolator *);

	size_t Get_nni_unique(void)
	{
		return this->nni_unique;
	};
	void Set_nni_unique(size_t i)
	{
		this->nni_unique = i;
	};

	KDtree *Get_tree3d(void);

	int Get_columns(void);
	void Set_columns(int i)
	{
		this->columns = i;
	};

	int Get_attribute(void) const
	{
		return this->attribute;
	}
	void Set_attribute(int a)
	{
		this->attribute = a;
	};

	struct zone *Get_bounding_box(void);
	void Set_bounding_box(void);

	Data_source *Get_data_source_with_points(void);

	void Set_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM c)
	{
		this->coordinate_system = c;
	};
	PHAST_Transform::COORDINATE_SYSTEM Get_coordinate_system()const;

	void Set_user_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM c)
	{
		this->coordinate_system_user = c;
	};
	PHAST_Transform::COORDINATE_SYSTEM Get_user_coordinate_system()const;


	Data_source & operator=(const Data_source & r);
	friend std::ostream & operator<<(std::ostream & os,
									 const Data_source & ds);

	bool operator==(const Data_source &other) const;
	bool operator!=(const Data_source &other) const;

	// Data
  protected:
	bool defined;
	std::string file_name;
	DATA_SOURCE_TYPE source_type;
	DATA_SOURCE_TYPE source_type_user;
	Filedata *filedata;
	std::vector < Point > pts;
	std::vector < Point > pts_user;
	PHAST_polygon phast_polygons;
	Polygon_tree *tree;
	//NNInterpolator *   nni;
	size_t nni_unique;
	KDtree *tree3d;				/* used for 3D interpolation */
	int columns;
	int attribute;
	struct zone box;
	PHAST_Transform::COORDINATE_SYSTEM coordinate_system;
	PHAST_Transform::COORDINATE_SYSTEM coordinate_system_user;
	
#if defined(__WPHAST__) && defined(_DEBUG)
  public:
	virtual void Dump(class CDumpContext& dc) const;
#endif
};
inline KDtree *
Data_source::Get_tree3d(void)
{
	Data_source *ds = this->Get_data_source_with_points();
	if (!ds->tree3d)
	{
		// Use points to make 3D tree
		ds->tree3d = new KDtree(ds->Get_points());

		// No longer need points
		//ds->pts.clear();
	}
	return ds->tree3d;
}
inline Polygon_tree *
Data_source::Get_tree(void)
{
	if (!this->Test_tree())
	{
		if (!this->Test_phast_polygons())
		{
			this->Make_polygons();
		}
	}

	Data_source *ds = this->Get_data_source_with_points();

	if (!ds->tree)
	{
		//ds->Get_phast_polygons();
		assert(ds->phast_polygons.Get_points().size() != 0);
		ds->tree = new Polygon_tree(ds->phast_polygons);
	}
	return ds->tree;
}
inline bool
Data_source::Test_tree(void)
{
	Data_source *ds = this->Get_data_source_with_points();
	if (ds->tree == NULL) return false;
	return true;
}
inline bool
Data_source::Test_phast_polygons(void)
{
	Data_source *ds = this->Get_data_source_with_points();
	if (ds->phast_polygons.Get_points().size() < 3) return false;
	return true;
}
#endif // !defined(DATA_SOURCE_H_INCLUDED)
