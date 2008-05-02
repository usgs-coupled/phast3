#if !defined(NNINTERPOLATOR_H_INCLUDED)
#define NNINTERPOLATOR__H_INCLUDED
#include <vector>
#include "../Point.h"


class NNInterpolator
{
  // TODO: Add your methods for this class here.
public:
  friend bool nnpi_interpolate(std::vector<Point> &pts_in, std::vector<Point> &pts_out, double wmin); 
};


#endif // !defined(NNINTERPOLATOR_H_INCLUDED)
