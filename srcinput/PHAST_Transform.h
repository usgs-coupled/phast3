#if !defined(PHAST_TRANSFORM_H_INCLUDED)
#define PHAST_TRANSFORM_H_INCLUDED
#include "Point.h"

#include <boost/numeric/ublas/vector.hpp>
#include <boost/numeric/ublas/matrix.hpp>

class PHAST_Transform
{

public:
	PHAST_Transform(void);
	PHAST_Transform(double x, double y, double z, double angle);
	void transform(Point &p);
	void inverse_transform(Point &p);
public:
	virtual ~PHAST_Transform(void);

	boost::numeric::ublas::matrix<double> trans;
	boost::numeric::ublas::matrix<double> inverse;
};
#endif // !defined(PHAST_TRANSFORM_H_INCLUDED)
