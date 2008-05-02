// This is the main DLL file.
#include <boost/multi_array.hpp>
#include "KDtree.h"
using namespace boost; 

KDtree::KDtree(std::vector<Point> &pts)
{
  //array2ddouble data(extents[10][3]);  // declare a 10000 x 3 array.
  int n = pts.size();
  int dim = 3;
  multi_array<double,2>  realdata(extents[n][dim]);
  int i, j;
  for (i = 0; i < n; i++)
  {
    for (j = 0; j < 3; j++)
    {
      realdata[i][j] = pts[i].get_coord()[j];
    }
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

KDtree::~KDtree(void)
{
  delete this->tree;
}
