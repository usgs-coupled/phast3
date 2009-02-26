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
  public:  PHAST_Transform(void);
	  PHAST_Transform(double x, double y, double z, double angle);
	  PHAST_Transform(double x, double y, double z, double angle_degrees,
					  double scale_x, double scale_y, double scale_z);
	void Transform(Point & p)const;
	void Inverse_transform(Point & p)const;
	void Transform(std::vector < Point > &pts)const;
	void Inverse_transform(std::vector < Point > &pts)const;

	// No scale versions
	void TransformNS(Point & p)const;
	void Inverse_transformNS(Point & p)const;
	void TransformNS(std::vector < Point > &pts)const;
	void Inverse_transformNS(std::vector < Point > &pts)const;

  public:  virtual ~ PHAST_Transform(void);
	  boost::numeric::ublas::matrix < double >trans;
	  boost::numeric::ublas::matrix < double >inverse;
	  boost::numeric::ublas::matrix < double >trans_ns;
	  boost::numeric::ublas::matrix < double >inverse_ns;
};
extern PHAST_Transform *map_to_grid;
extern
	PHAST_Transform::COORDINATE_SYSTEM
	target_coordinate_system;

#endif // !defined(PHAST_TRANSFORM_H_INCLUDED)
