#if !defined(KDTREE_H_INCLUDED)
#define KDTREE_H_INCLUDED
#include "kdtree2.hpp"
#include "../Point.h"
#include "../NNInterpolator/nn.h"
class KDtree
{
public:
  ~KDtree();
  KDtree(std::vector<Point> &pts);
  KDtree(point *pts, size_t count);

  int Nearest(Point pt);
  int Nearest(point pt);


  // Data
  kdtree2 *tree;
};

#endif // !defined(KDTREE_H_INCLUDED)
