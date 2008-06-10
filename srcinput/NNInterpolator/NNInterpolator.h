#if !defined(NNINTERPOLATOR_H_INCLUDED)
#define NNINTERPOLATOR__H_INCLUDED
#include <vector>
#include "../Point.h"
#include "nn.h"



class NNInterpolator
{
  // TODO: Add your methods for this class here.
public:
  // constructors
  NNInterpolator(void);
  
  // destructor
  virtual ~NNInterpolator(void);
  bool preprocess(std::vector<Point> &pts_in, std::vector<Point> &corners);
  double interpolate(const Point& pt);

public:
  // data
  delaunay* delaunay_triangulation;
  nnpi* nn;
  point *pin;

friend bool nnpi_interpolate(std::vector<Point> &pts_in, std::vector<Point> &pts_out, double wmin); 
};


#endif // !defined(NNINTERPOLATOR_H_INCLUDED)
