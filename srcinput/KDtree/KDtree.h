#if !defined(KDTREE_H_INCLUDED)
#define KDTREE_H_INCLUDED
#include "kdtree2.hpp"
#include "../Point.h"
class KDtree
{
public:
  ~KDtree();
  KDtree(std::vector<Point> &pts);
  int Nearest(Point pt);

  // Data
  kdtree2 *tree;
};

#endif // !defined(KDTREE_H_INCLUDED)
