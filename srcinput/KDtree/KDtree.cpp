// This is the main DLL file.
#include <boost/multi_array.hpp>
#include "KDtree.h"
using namespace boost; 

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

// static
std::list<KDtree*> KDtree::KDtreeList;

KDtree::KDtree(std::vector<Point> &pts)
{
	//array2ddouble data(extents[10][3]);  // declare a 10000 x 3 array.
	int n = pts.size();
	int dim = 3;
	multi_array<double,2>  realdata(extents[n][dim]);
	int i, j;
	for (i = 0; i < n; i++)
	{
		v.push_back(pts[i].get_v());
		for (j = 0; j < 3; j++)
		{
			realdata[i][j] = pts[i].get_coord()[j];
		}
	}
	this->tree = new kdtree2(realdata,true);
}
KDtree::KDtree(point *pts, size_t count)
{
  size_t dim = 3;
  multi_array<double,2>  realdata(extents[count][dim]);
  size_t i;
  for (i = 0; i < count; i++)
  {
    realdata[i][0] = pts[i].x;
    realdata[i][1] = pts[i].y;
    realdata[i][2] = pts[i].z;
  }
  this->tree = new kdtree2(realdata,true);
}
int KDtree::Nearest(Point pt)
{
  int dim = this->tree->dim;
  kdtree2_result_vector result;
  vector<double> query(dim);
  query[0] = pt.x();
  query[1] = pt.y();
  query[2] = pt.z();

  this->tree->n_nearest(query, 1, result);
  return(result[0].idx);

}
int KDtree::Nearest(point pt)
{
  int dim = this->tree->dim;
  kdtree2_result_vector result;
  vector<double> query(dim);
  query[0] = pt.x;
  query[1] = pt.y;
  query[2] = pt.z;

  this->tree->n_nearest(query, 1, result);
  return(result[0].idx);
}
double KDtree::Interpolate3d(Point pt)
{
	int i = this->Nearest(pt);
	assert (i >= 0 && i < (int) this->v.size());
	return(v[i]);
}
KDtree::~KDtree(void)
{
  delete this->tree;
}
void Clear_KDtreeList(void)
{
	std::list<KDtree*>::iterator it = KDtree::KDtreeList.begin();
	for (; it != KDtree::KDtreeList.end(); ++it)
	{
		delete (*it);
	}
	KDtree::KDtreeList.clear();
}