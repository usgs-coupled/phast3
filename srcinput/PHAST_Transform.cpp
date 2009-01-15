#if (_MSC_VER >= 1400)
#pragma warning( push )
#pragma warning( disable: 4244 ) // 'argument' : conversion from 'type1' to 'type2', possible loss of data
#pragma warning( disable: 4267 ) // 'var' : conversion from 'size_t' to 'type', possible loss of data
#pragma warning( disable: 4996 ) // 'function': was declared deprecated
#endif

#include "PHAST_Transform.h"
#include "message.h"
PHAST_Transform *map_to_grid = NULL;
PHAST_Transform::COORDINATE_SYSTEM target_coordinate_system =
	PHAST_Transform::NONE;
PHAST_Transform::PHAST_Transform(void)
{
	this->trans.resize(4, 4, false);
	boost::numeric::ublas::identity_matrix < double >ident(4, 4);
	this->trans = ident;
	this->inverse = ident;
}

PHAST_Transform::PHAST_Transform(double x, double y, double z,
								 double angle_degrees)
{
	this->trans.resize(4, 4, false);
	this->trans.clear();

	boost::numeric::ublas::matrix < double >t(4, 4);
	boost::numeric::ublas::matrix < double >r(4, 4);

	t.clear();
	r.clear();

	double angle = (angle_degrees / 180.) * acos(-1.0);

	// set rotation matrix
	r(0, 0) = cos(angle);
	r(0, 1) = sin(angle);
	r(1, 0) = -sin(angle);
	r(1, 1) = cos(angle);
	r(2, 2) = 1.0;
	r(3, 3) = 1.0;

	// set translation
	t(0, 3) = -x;
	t(1, 3) = -y;
	t(2, 3) = -z;
	t(0, 0) = 1.0;
	t(1, 1) = 1.0;
	t(2, 2) = 1.0;
	t(3, 3) = 1.0;

	this->trans = this->trans_ns = boost::numeric::ublas::prod(r, t);

	// Make inverse
	// set rotation matrix
	r(0, 0) = cos(angle);
	r(0, 1) = -sin(angle);
	r(1, 0) = sin(angle);
	r(1, 1) = cos(angle);

	// set translation
	t(0, 3) = x;
	t(1, 3) = y;
	t(2, 3) = z;

	this->inverse = this->inverse_ns = boost::numeric::ublas::prod(t, r);
}
PHAST_Transform::PHAST_Transform(double x, double y, double z,
								 double angle_degrees, double scale_x,
								 double scale_y, double scale_z)
{
	// Scale factors are map unit / grid unit
	// Calculate scale factor from unit structure input_to_si_map / input_to_si_grid

	this->trans.resize(4, 4, false);
	this->trans.clear();

	this->trans_ns.resize(4, 4, false);
	this->trans_ns.clear();

	boost::numeric::ublas::matrix < double >t(4, 4);
	boost::numeric::ublas::matrix < double >r(4, 4);
	boost::numeric::ublas::matrix < double >s(4, 4);
	boost::numeric::ublas::matrix < double >p(4, 4);

	t.clear();
	r.clear();
	s.clear();
	p.clear();

	double angle = (angle_degrees / 180.) * acos(-1.0);

	// set rotation matrix
	r(0, 0) = cos(angle);
	r(0, 1) = sin(angle);
	r(1, 0) = -sin(angle);
	r(1, 1) = cos(angle);
	r(2, 2) = 1.0;
	r(3, 3) = 1.0;

	// set translation
	t(0, 3) = -x;
	t(1, 3) = -y;
	t(2, 3) = -z;
	t(0, 0) = 1.0;
	t(1, 1) = 1.0;
	t(2, 2) = 1.0;
	t(3, 3) = 1.0;

	// transform w/o scaling
	this->trans_ns = boost::numeric::ublas::prod(r, t);

	// set scaling
	s(0, 0) = scale_x;
	s(1, 1) = scale_y;
	s(2, 2) = scale_z;
	s(3, 3) = 1.0;

	this->trans = boost::numeric::ublas::prod(s, this->trans_ns);

	// Make inverse
	// set rotation matrix
	r(0, 0) = cos(angle);
	r(0, 1) = -sin(angle);
	r(1, 0) = sin(angle);
	r(1, 1) = cos(angle);

	// set translation
	t(0, 3) = x;
	t(1, 3) = y;
	t(2, 3) = z;

	// inverse w/o scaling
	this->inverse_ns = boost::numeric::ublas::prod(t, r);

	// set scaling
	if (scale_x == 0.0 || scale_y == 0.0 || scale_z == 0)
	{
		error_msg("Scale factor was 0.0 in tranform.", EA_STOP);
	}
	s(0, 0) = 1.0 / scale_x;
	s(1, 1) = 1.0 / scale_y;
	s(2, 2) = 1.0 / scale_z;

	p.clear();

	p = boost::numeric::ublas::prod(r, s);
	this->inverse = boost::numeric::ublas::prod(t, p);

}
PHAST_Transform::~PHAST_Transform(void)
{
}
void
PHAST_Transform::Transform(Point & p)const
{
	boost::numeric::ublas::vector < double >v(4);
	v(0) = p.x();
	v(1) = p.y();
	v(2) = p.z();
	v(3) = 1.0;

	//std::cerr << "In vector: " << v(0) << " " << v(1) << " " << v(2) << " " << v(3) << std::endl;

	boost::numeric::ublas::vector < double >vt =
		boost::numeric::ublas::prod(this->trans, v);
	//std::cerr << "transform vector: " << vt(0) << " " << vt(1) << " " << vt(2) << " " << vt(3) << std::endl;

	//v.clear();
	//v = boost::numeric::ublas::prod(this->inverse, vt);
	//std::cerr << "inverse vector: " << v(0) << " " << v(1) << " " << v(2) << " " << v(3) << std::endl;

	p.set_x(vt(0));
	p.set_y(vt(1));
	p.set_z(vt(2));
}

void
PHAST_Transform::Inverse_transform(Point & p)const
{
	boost::numeric::ublas::vector < double >v(4);
	v(0) = p.x();
	v(1) = p.y();
	v(2) = p.z();
	v(3) = 1.0;

	//std::cerr << "In vector: " << v(0) << " " << v(1) << " " << v(2) << " " << v(3) << std::endl;
	boost::numeric::ublas::vector < double >vt =
		boost::numeric::ublas::prod(this->inverse, v);
	//std::cerr << "transform vector: " << vt(0) << " " << vt(1) << " " << vt(2) << " " << vt(3) << std::endl;

	p.set_x(vt(0));
	p.set_y(vt(1));
	p.set_z(vt(2));
}

void
PHAST_Transform::Transform(std::vector < Point > &pts)const
{
	std::vector < Point >::iterator it;
	for (it = pts.begin(); it != pts.end(); it++)
	{
		this->Transform(*it);
	}
}

void
PHAST_Transform::Inverse_transform(std::vector < Point > &pts)const
{
	std::vector < Point >::iterator it;
	for (it = pts.begin(); it != pts.end(); it++)
	{
		this->Inverse_transform(*it);
	}
}

void
PHAST_Transform::Inverse_transformNS(std::vector < Point > &pts)const
{
	std::vector < Point >::iterator it;
	for (it = pts.begin(); it != pts.end(); it++)
	{
		this->Inverse_transformNS(*it);
	}
}

void
PHAST_Transform::TransformNS(Point & p)const
{
	boost::numeric::ublas::vector < double >v(4);
	v(0) = p.x();
	v(1) = p.y();
	v(2) = p.z();
	v(3) = 1.0;

	//std::cerr << "In vector: " << v(0) << " " << v(1) << " " << v(2) << " " << v(3) << std::endl;

	boost::numeric::ublas::vector < double >vt =
		boost::numeric::ublas::prod(this->trans_ns, v);
	//std::cerr << "transform vector: " << vt(0) << " " << vt(1) << " " << vt(2) << " " << vt(3) << std::endl;

	//v.clear();
	//v = boost::numeric::ublas::prod(this->inverse, vt);
	//std::cerr << "inverse vector: " << v(0) << " " << v(1) << " " << v(2) << " " << v(3) << std::endl;

	p.set_x(vt(0));
	p.set_y(vt(1));
	p.set_z(vt(2));
}

void
PHAST_Transform::Inverse_transformNS(Point & p)const
{
	boost::numeric::ublas::vector < double >v(4);
	v(0) = p.x();
	v(1) = p.y();
	v(2) = p.z();
	v(3) = 1.0;

	//std::cerr << "In vector: " << v(0) << " " << v(1) << " " << v(2) << " " << v(3) << std::endl;
	boost::numeric::ublas::vector < double >vt =
		boost::numeric::ublas::prod(this->inverse_ns, v);
	//std::cerr << "transform vector: " << vt(0) << " " << vt(1) << " " << vt(2) << " " << vt(3) << std::endl;

	p.set_x(vt(0));
	p.set_y(vt(1));
	p.set_z(vt(2));
}

void
PHAST_Transform::TransformNS(std::vector < Point > &pts)const
{
	std::vector < Point >::iterator it;
	for (it = pts.begin(); it != pts.end(); it++)
	{
		this->TransformNS(*it);
	}
}


//http://na37.nada.kth.se/mediawiki/index.php/Using_uBLAS#Examples
//http://en.wikipedia.org/wiki/Transformation_matrix

#if (_MSC_VER >= 1400)
#pragma warning( pop )
#endif