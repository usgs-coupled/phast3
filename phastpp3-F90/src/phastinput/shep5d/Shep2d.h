#if !defined(SHEP2D_H_INCLUDED)
#define SHEP2D_H_INCLUDED
#include "Interpolator.h"
#include "Point.h"
#include "Cell_Face.h"
class Shep2d :
  public Interpolator
{
public:
  Shep2d(void);
  //Shep2d(std::vector<Point> &pts, int icoord[2]);
  Shep2d(std::vector<Point> &pts, Cell_Face face);
  double Evaluate(Point pt, Cell_Face face);

public:
  ~Shep2d(void);

  // data
  bool shep_error;
  std::string shep_error_string;
};
#endif // !defined(SHEP2D__H_INCLUDED)
	/*
	int i, j;
	std::vector<Point> pts;
	for (i = -3; i < 10; i += 3)
	{
	  for (j = -3; j < 10; j += 3)
	  {
	    Point pt;
	    pt.set_x((double) (i));
	    pt.set_y((double) (j));
	    pt.set_z((double) (i*j));
	    
	    pts.push_back(pt);
	  }
	}

	int icoord[2];
	icoord[0] = 0;
	icoord[1] = 1;

	Shep2d shep(pts, icoord);
	assert(!shep.shep_error);
	
	double p[3];
	p[1] = -2;
	p[2] = 2;
	double result = shep.QSMVAL(p);
	*/
