// This is the main DLL file.
#include <boost/multi_array.hpp>
#include "KDtree.h"
using namespace boost;

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

// static
std::list < KDtree * >KDtree::KDtreeList;
KDtree::KDtree(const KDtree & t):
realdata(t.realdata),
v(t.v)
{
	this->tree = new kdtree2(this->realdata, true);
}

KDtree::KDtree(std::vector < Point > &pts, size_t dims):realdata(extents[pts.size()][dims])
{
	int
		n = (int) pts.size();
	int
		i,
		j;
	for (i = 0; i < n; i++)
	{
		v.push_back(pts[i].get_v());
		for (j = 0; j < dims; j++)
		{
			realdata[i][j] = pts[i].get_coord()[j];
		}
	}
	this->tree = new kdtree2(this->realdata, true);
}

#ifdef SKIP
KDtree::KDtree(point * pts, size_t count):realdata(extents[count][3])
{
	size_t i;
	for (i = 0; i < count; i++)
	{
		realdata[i][0] = pts[i].x;
		realdata[i][1] = pts[i].y;
		realdata[i][2] = pts[i].z;
	}
	this->tree = new kdtree2(this->realdata, true);
}
#endif
KDtree & KDtree::operator=(const KDtree & rhs)
{
	if (this != &rhs)
	{
		this->v = rhs.v;
		this->realdata = rhs.realdata;
		this->tree = new kdtree2(this->realdata, true);
	}
	return *this;
}

int
KDtree::Nearest(Point pt)
{
	int dim = this->tree->dim;
	kdtree2_result_vector result;
	vector < double >query(dim);
	query[0] = pt.x();
	query[1] = pt.y();
	if (dim > 2)
	{
		query[2] = pt.z();
	}

	this->tree->n_nearest(query, 1, result);
	return (result[0].idx);

}

#ifdef SKIP
int
KDtree::Nearest(point pt)
{
	int dim = this->tree->dim;
	kdtree2_result_vector result;
	vector < double >query(dim);
	query[0] = pt.x;
	query[1] = pt.y;
	query[2] = pt.z;

	this->tree->n_nearest(query, 1, result);
	return (result[0].idx);
}
#endif
double
KDtree::Interpolate3d(Point pt)
{
	int i = this->Nearest(pt);
	assert(i >= 0 && i < (int) this->v.size());
	return (v[i]);
}

KDtree::~KDtree(void)
{
	delete this->tree;
}

void
Clear_KDtreeList(void)
{
	std::list < KDtree * >::iterator it = KDtree::KDtreeList.begin();
	for (; it != KDtree::KDtreeList.end(); ++it)
	{
		delete(*it);
	}
	KDtree::KDtreeList.clear();
}
