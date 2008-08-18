#include "PHAST_Transform.h"
PHAST_Transform *map_to_grid = NULL;
PHAST_Transform::COORDINATE_SYSTEM coordinate_conversion = PHAST_Transform::NONE;
PHAST_Transform::PHAST_Transform(void)
{
	this->trans.resize(4, 4, false);
	boost::numeric::ublas::identity_matrix<double> ident(4,4);
	this->trans = ident;
	this->inverse = ident;
}

PHAST_Transform::PHAST_Transform(double x, double y, double z, double angle_degrees)
{
	this->trans.resize(4, 4, false);
	this->trans.clear();

	boost::numeric::ublas::matrix<double> t(4,4);
	boost::numeric::ublas::matrix<double> r(4,4);

	t.clear();
	r.clear();

	double angle = (angle_degrees / 180.) * acos(-1.0);

	// set rotation matrix
	r(0,0) = cos(angle);
	r(0,1) = sin(angle);
	r(1,0) = -sin(angle);
	r(1,1) = cos(angle);
	r(2,2) = 1.0;
	r(3,3) = 1.0;

	// set translation
	t(0,3) = -x;
	t(1,3) = -y;
	t(2,3) = -z;
	t(0,0) = 1.0;
	t(1,1) = 1.0;
	t(2,2) = 1.0;
	t(3,3) = 1.0;

	this->trans = boost::numeric::ublas::prod(r, t);


    // Make inverse
	// set rotation matrix
	r(0,0) = cos(angle);
	r(0,1) = -sin(angle);
	r(1,0) = sin(angle);
	r(1,1) = cos(angle);

	// set translation
	t(0,3) = x;
	t(1,3) = y;
	t(2,3) = z;

	this->inverse = boost::numeric::ublas::prod(t, r);

}
PHAST_Transform::~PHAST_Transform(void)
{
}
void PHAST_Transform::Transform(Point &p)
{
	boost::numeric::ublas::vector<double> v(4);
	v(0) = p.x();
	v(1) = p.y();
	v(2) = p.z();
	v(3) = 1.0;

	//std::cerr << "In vector: " << v(0) << " " << v(1) << " " << v(2) << " " << v(3) << std::endl;

	boost::numeric::ublas::vector<double> vt = boost::numeric::ublas::prod(this->trans, v);
	//std::cerr << "transform vector: " << vt(0) << " " << vt(1) << " " << vt(2) << " " << vt(3) << std::endl;

	//v.clear();
	//v = boost::numeric::ublas::prod(this->inverse, vt);
	//std::cerr << "inverse vector: " << v(0) << " " << v(1) << " " << v(2) << " " << v(3) << std::endl;

	p.set_x(vt(0));
	p.set_y(vt(1));
	p.set_z(vt(2));
}
void PHAST_Transform::Inverse_transform(Point &p)
{
	boost::numeric::ublas::vector<double> v(4);
	v(0) = p.x();
	v(1) = p.y();
	v(2) = p.z();
	v(3) = 1.0;

	//std::cerr << "In vector: " << v(0) << " " << v(1) << " " << v(2) << " " << v(3) << std::endl;
	boost::numeric::ublas::vector<double> vt = boost::numeric::ublas::prod(this->inverse, v);
	//std::cerr << "transform vector: " << vt(0) << " " << vt(1) << " " << vt(2) << " " << vt(3) << std::endl;

	p.set_x(vt(0));
	p.set_y(vt(1));
	p.set_z(vt(2));
}

void PHAST_Transform::Transform(std::vector<Point> &pts)
{
	std::vector<Point>::iterator it;
	for (it = pts.begin(); it != pts.end(); it++)
	{
		this->Transform(*it);
	}
}
void PHAST_Transform::Inverse_transform(std::vector<Point> &pts)
{
	std::vector<Point>::iterator it;
	for (it = pts.begin(); it != pts.end(); it++)
	{
		this->Inverse_transform(*it);
	}
}
//http://na37.nada.kth.se/mediawiki/index.php/Using_uBLAS#Examples
//http://en.wikipedia.org/wiki/Transformation_matrix
