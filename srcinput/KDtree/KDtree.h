#if !defined(KDTREE_H_INCLUDED)
#define KDTREE_H_INCLUDED
#include "kdtree2.hpp"
#include "../Point.h"
#include "../NNInterpolator/nn.h"
#include <list>
class KDtree
{
public:
  ~KDtree();
  KDtree(std::vector<Point> &pts);
  KDtree(point *pts, size_t count);

  int Nearest(Point pt);
  int Nearest(point pt);

  double Interpolate3d(Point pt);


  // Data
  kdtree2 *tree;
  std::vector<double> v;
  static std::list<KDtree*> KDtreeList;
};
void Clear_KDtreeList(void);
#endif // !defined(KDTREE_H_INCLUDED)
