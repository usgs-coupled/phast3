// This is the main DLL file.
#include <float.h>

#include <map>
#include <set>
#include "../KDtree/Point.h"
#include "config.h"
#include "nan.h"
#include "../message.h"
#include "../KDtree/KDtree.h"
#include "NNInterpolator.h"
#include "../Data_source.h"


// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

// static
std::map< const NNInterpolator*, KDtree* > NNInterpolator::KDtreeMap;

// Constructors
NNInterpolator::NNInterpolator(void)
{
	this->delaunay_triangulation = NULL;
	this->nn = NULL;
	this->pin = NULL;
	this->point_count = 0;
	this->coordinate_system = PHAST_Transform::NONE;
}

// Destructor
NNInterpolator::~NNInterpolator(void)
{
	if (this->nn != NULL)
		nnpi_destroy(this->nn);
	if (this->delaunay_triangulation != NULL)
		delaunay_destroy(this->delaunay_triangulation);
	if (this->pin != NULL)
		delete [] this->pin;
	// KDtree* cleaned up in main Clear_KDtreeList()
	std::map< const NNInterpolator *, KDtree * >::iterator cit = NNInterpolator::KDtreeMap.find(this);
	if (cit != NNInterpolator::KDtreeMap.end())
	{
		NNInterpolator::KDtreeMap.erase(cit);
	}
}

bool
nnpi_interpolate(std::vector < Point > &pts_in,
				 std::vector < Point > &pts_out, double wmin)
{
	if (pts_in.size() == 0 || pts_out.size() == 0)
	{
		return false;
	}
	// set up points in input array
	size_t nin = pts_in.size();
	point *pin = new point[nin];

	size_t i;
	for (i = 0; i < nin; i++)
	{
		pin[i].x = pts_in[i].x();
		pin[i].y = pts_in[i].y();
		pin[i].z = pts_in[i].get_v();
	}

	// set up points in output array
	size_t nout = pts_out.size();
	point *pout = new point[nout];
	for (i = 0; i < nout; i++)
	{
		pout[i].x = pts_out[i].x();
		pout[i].y = pts_out[i].y();
		pout[i].z = 0.0;
	}

	nnpi_interpolate_points((int) nin, pin, wmin, (int) nout, pout);

	KDtree kdt(pts_in);

	// set up points for return
	for (i = 0; i < nout; i++)
	{
		if (isnan(pout[i].z))
		{
			int n = kdt.Nearest(pts_out[i]);
			pts_out[i].set_v(pts_in[n].get_v());
			//Point p;
			//p.set_x(pout[i].x);
			//p.set_y(pout[i].y);
			//pts_out[i].set_v(pts_in[n].get_v());
			//pts_out[i].set_v(-300);
		}
		else
		{
			pts_out[i].set_v(pout[i].z);
		}
	}

	// remove added Points
	//pts_in.erase(original_end + 1, pts_in.end());

	// delete points
	delete[]pin;
	delete[]pout;
	return true;
}

bool NNInterpolator::preprocess(const std::vector < Point > &pts_in,
								PHAST_Transform::COORDINATE_SYSTEM cs)
{
	this->coordinate_system = cs;

	// set up points in input array
	this->point_count = pts_in.size();
	size_t
		nin = pts_in.size();
	this->pin = new point[nin];

	size_t
		i;
	this->bounds = zone();
	this->bounds.zone_defined = 1;
	for (i = 0; i < nin; i++)
	{
		this->pin[i].x = pts_in[i].x();
		this->pin[i].y = pts_in[i].y();
		//this->pin[i].z = pts_in[i].get_v();
		this->pin[i].z = pts_in[i].z();
		if (this->pin[i].x < this->bounds.x1)
			this->bounds.x1 = this->pin[i].x;
		if (this->pin[i].y < this->bounds.y1)
			this->bounds.y1 = this->pin[i].y;
		if (this->pin[i].z < this->bounds.z1)
			this->bounds.z1 = this->pin[i].z;
		if (this->pin[i].x > this->bounds.x2)
			this->bounds.x2 = this->pin[i].x;
		if (this->pin[i].y > this->bounds.y2)
			this->bounds.y2 = this->pin[i].y;
		if (this->pin[i].z > this->bounds.z2)
			this->bounds.z2 = this->pin[i].z;
	}

	assert(this->delaunay_triangulation == 0);
	assert(this->nn == 0);

	if (pts_in.size() < 3)
	{
		return false;
	}

	this->delaunay_triangulation =
		delaunay_build((int) nin, this->pin, 0, NULL, 0, NULL);
	this->nn = nnpi_create(this->delaunay_triangulation);
	// int seed = 0;

	double
		wmin = 0;				// no extrapolation
	nnpi_setwmin(this->nn, wmin);
	return true;
}

double
NNInterpolator::interpolate(const Point & p,
							PHAST_Transform::COORDINATE_SYSTEM point_system,
							PHAST_Transform * map2grid)const
{
	switch (point_system)
	{
	case PHAST_Transform::GRID:
		switch (this->coordinate_system)
		{
		case PHAST_Transform::GRID:
			return (this->interpolate(p));
			break;
		case PHAST_Transform::MAP:
			{
				Point pt = p;
				map2grid->Inverse_transform(pt);
				pt.set_z(this->interpolate(pt));
				map2grid->Transform(pt);
				return (pt.z());
			}
		default:
			break;
		}
	case PHAST_Transform::MAP:
		switch (this->coordinate_system)
		{
		case PHAST_Transform::MAP:
			return (this->interpolate(p));
			break;
		case PHAST_Transform::GRID:
			{
				Point pt = p;
				map2grid->Transform(pt);
				pt.set_z(this->interpolate(pt));
				map2grid->Inverse_transform(pt);
				return (pt.z());
			}
		default:
			break;
		}
	case PHAST_Transform::NONE:
		break;
	}
	std::ostringstream estring;
	estring <<
		"A oordinate system was not defined for NNInterpolate::interpolate "
		<< std::endl;
	error_msg(estring.str().c_str(), EA_STOP);
	return (0.0);
}

double
NNInterpolator::interpolate(const Point & pt)const
{
	// Point is in same coordinate units as nni interpolator
	point pout;
	if (this->nn != NULL && this->bounds.Point_in_xy_zone(pt) )
	{
		pout.x = pt.x();
		pout.y = pt.y();
		pout.z = 0.0;
		nnpi_interpolate_point(this->nn, &pout);
		if (isnan(pout.z))
		{
			if (this->get_tree())
			{
				int n = this->get_tree()->Nearest(pt);
				assert((0 <= n) && (n < (int) this->point_count));
				pout.z = this->pin[n].z;
			}
		}
	}
	else
	{
		pout.z = NaN;
		if (this->get_tree())
		{
			int n = this->get_tree()->Nearest(pt);
			assert((0 <= n) && (n < (int) this->point_count));
			pout.z = this->pin[n].z;
		}
	}
	return (pout.z);
}

KDtree *
NNInterpolator::get_tree(void)const
{
	if (NNInterpolator::KDtreeMap.find(this) == NNInterpolator::KDtreeMap.end())
	{
		KDtree *tree = NULL;
		if (this->point_count > 0)
		{
			assert(this->pin != NULL);
			std::vector < Point > pts;
			size_t i;
			for (i = 0; i < this->point_count; i++)
			{
				Point p(this->pin[i].x, this->pin[i].y, this->pin[i].z);
				pts.push_back(p);
			}
			tree = new KDtree(pts, 2);
			KDtree::KDtreeList.push_back(tree);
		}
		NNInterpolator::KDtreeMap.insert(
			std::map < const NNInterpolator *, KDtree * >::value_type(this, tree)
			);
	}

	std::map< const NNInterpolator *, KDtree * >::iterator it = NNInterpolator::KDtreeMap.find(this);
	if (it != NNInterpolator::KDtreeMap.end())
	{
		return it->second;
	}
	else
	{
		assert(false);
	}
	return NULL;
}

void
Clear_NNInterpolatorList(void)
{
	std::list < NNInterpolator * >::iterator it = Data_source::NNInterpolatorList.begin();
	for (; it != Data_source::NNInterpolatorList.end(); ++it)
	{
		delete(*it);
	}
	Data_source::NNInterpolatorList.clear();
}
