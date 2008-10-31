#if !defined(PHAST_TRANSFORM_H_INCLUDED)
#define PHAST_TRANSFORM_H_INCLUDED
#include "Point.h"

#include <boost/numeric/ublas/vector.hpp>
#include <boost/numeric/ublas/matrix.hpp>
	class PHAST_Transform 
{
  public:enum COORDINATE_SYSTEM 
	{ MAP = 0, GRID = 1, NONE = 2
	};
  public:PHAST_Transform(void);
	PHAST_Transform(double x, double y, double z, double angle);
	PHAST_Transform(double x, double y, double z, double angle_degrees,
					 double scale_x, double scale_y, double scale_z);
	void Transform(Point & p);
	void Inverse_transform(Point & p);
	void Transform(std::vector < Point > &pts);
	void Inverse_transform(std::vector < Point > &pts);
  public:virtual ~ PHAST_Transform(void);
	boost::numeric::ublas::matrix < double >trans;
	boost::numeric::ublas::matrix < double >inverse;
};
extern PHAST_Transform *map_to_grid;
extern
	PHAST_Transform::COORDINATE_SYSTEM
	target_coordinate_system;

#endif // !defined(PHAST_TRANSFORM_H_INCLUDED)
