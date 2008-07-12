#if !defined(NNINTERPOLATOR_H_INCLUDED)
#define NNINTERPOLATOR__H_INCLUDED
#include <vector>
#include "../Point.h"
#include "../zone.h"
#include "nn.h"

class KDtree;

class NNInterpolator
{
  // TODO: Add your methods for this class here.
public:
  // constructors
  NNInterpolator(void);
  
  // destructor
  virtual ~NNInterpolator(void);
// COMMENT: {7/11/2008 9:27:18 PM}  bool preprocess(std::vector<Point> &pts_in, std::vector<Point> &corners);
  bool preprocess(std::vector<Point> &pts_in);
  double interpolate(const Point& pt);
  KDtree* get_tree(void);

public:
  // data
  delaunay* delaunay_triangulation;
  nnpi* nn;
  point *pin;
  size_t point_count;
  zone bounds;

protected:
  KDtree *tree;

friend bool nnpi_interpolate(std::vector<Point> &pts_in, std::vector<Point> &pts_out, double wmin); 
};


#endif // !defined(NNINTERPOLATOR_H_INCLUDED)
