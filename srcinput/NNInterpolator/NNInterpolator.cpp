// This is the main DLL file.
#include <float.h>

#include "../Point.h"
#include "config.h"
#include "nan.h"
#include "../KDtree/KDtree.h"
#include "NNInterpolator.h"

// Constructors
NNInterpolator::NNInterpolator(void)
{
  this->delaunay_triangulation = NULL;
  this->nn = NULL;
  this->pin = NULL;

}
// Destructor
NNInterpolator::~NNInterpolator(void)
{
  if (this->nn != NULL) nnpi_destroy(this->nn);
  if (this->delaunay_triangulation != NULL) delaunay_destroy(this->delaunay_triangulation);
  if (this->pin != NULL) delete this->pin;
}
bool nnpi_interpolate(std::vector<Point> &pts_in, std::vector<Point> &pts_out, double wmin)
{
  if (pts_in.size() == 0 || pts_out.size() == 0)
  {
    return false;
  }
#ifdef SKIP

  // determine bounding box of output points
  Point out_min = Point(pts_out.begin(), pts_out.end(), Point::MIN);
  Point out_max = Point(pts_out.begin(), pts_out.end(), Point::MAX);
  double xmin, xmax, ymin, ymax;
  xmin = out_min.x();
  xmax = out_max.x();
  ymin = out_min.y();
  ymax = out_max.y();

  // Save location of last point
  std::vector<Point>::iterator original_end = pts_in.end() - 1;

  // add points to edges of interpolation region
  // Not used, ndiv = 0
  int ndiv = 0; // ndiv >= 2 adds points to edges

  int i;

  // Add edge points for x axis
  for (i = 0; i < ndiv; i++)
  {
    double current_x = xmin + ((double) i)/((double) (ndiv - 1)) * (xmax - xmin);
    Point p(current_x, ymin, 0.0);
    p.set_v(interpolate_nearest(pts_in, p));
    pts_in.push_back(p);
    Point p1(current_x, ymax, 0.0);
    p1.set_v(interpolate_nearest(pts_in, p1));
    pts_in.push_back(p1);
  }

  // fill in edge points for y axis
  for (i = 1; i < ndiv - 1; i++)
  {
    double current_y = ymin + ((double) i)/((double) (ndiv - 1)) * (ymax - ymin);
    Point p(xmin, current_y, 0.0);
    p.set_v(interpolate_nearest(pts_in, p));
    pts_in.push_back(p);
    Point p1(xmax, current_y, 0.0);
    p1.set_v(interpolate_nearest(pts_in, p1));
    pts_in.push_back(p1);
  }

#endif

  // set up points in input array
  int nin = pts_in.size();
  point * pin = new point[nin];

  int i;
  for (i = 0; i < nin; i++)
  {
    pin[i].x = pts_in[i].x();
    pin[i].y = pts_in[i].y();
    pin[i].z = pts_in[i].get_v();
  }

  // set up points in output array
  int nout = pts_out.size();
  point * pout = new point[nout];
  for (i = 0; i < nout; i++)
  {
    pout[i].x = pts_out[i].x();
    pout[i].y = pts_out[i].y();
    pout[i].z = 0.0;
  }

  nnpi_interpolate_points(nin, pin, wmin, nout, pout);

  KDtree kdt(pts_in);
#ifdef SKIP
  for (i = 0; i < nout; i++)
  {
    int n = kdt.Nearest(pts_out[i]);
    pts_out[i].set_v(pts_in[n].get_v());
  }
#endif

  // set up points for return
  for (i = 0; i < nout; i++)
  {
    if (isnan(pout[i].z))
    {
      int n = kdt.Nearest(pts_out[i]);
      pts_out[i].set_v(pts_in[n].get_v());
      //Point p;
      //p.set_x(pout[i].x);
      //p.set_y(pout[i].y);
      //pts_out[i].set_v(pts_in[n].get_v());
      //pts_out[i].set_v(-300);
    } else
    {
      pts_out[i].set_v(pout[i].z);
    }
  }

  // remove added Points
  //pts_in.erase(original_end + 1, pts_in.end());
  
  // delete points
  delete [] pin;
  delete [] pout;
  return true;
}
bool NNInterpolator::preprocess(std::vector<Point> &pts_in, std::vector<Point> &corners)
{

  if (pts_in.size() == 0)
  {
    return false;
  }

  // set up points in input array
  int nin = pts_in.size();
  this->pin = new point[nin + corners.size()];

  int i;
  for (i = 0; i < nin; i++)
  {
    this->pin[i].x = pts_in[i].x();
    this->pin[i].y = pts_in[i].y();
    this->pin[i].z = pts_in[i].get_v();
  }

  assert(this->delaunay_triangulation == 0);
  assert(this->nn == 0);

  this->delaunay_triangulation = delaunay_build(nin, this->pin, 0, NULL, 0, NULL);
  this->nn = nnpi_create(this->delaunay_triangulation);
  int seed = 0;

  double wmin = 0;  // no extrapolation
  nnpi_setwmin(this->nn, wmin);

  // find corners not in convex hull 
  int new_nin = nin;
  if (corners.size() > 0) {
    for (i = 0; i < (int) corners.size(); i++)
    {
      Point p = corners[i];
   
      if (isnan(this->interpolate(p)))
      {
	this->pin[new_nin].x = corners[i].x();
	this->pin[new_nin].y = corners[i].y();

	// find value of nearest point in pts_in
	this->pin[new_nin].z = interpolate_nearest(pts_in, corners[i]);
	new_nin++;
      }
    }
  }
  if (new_nin > nin)
  {
    if (this->nn != NULL) nnpi_destroy(this->nn);
    if (this->delaunay_triangulation != NULL) delaunay_destroy(this->delaunay_triangulation);
    this->nn = NULL;
    this->delaunay_triangulation = NULL;
    this->delaunay_triangulation = delaunay_build(new_nin, this->pin, 0, NULL, 0, NULL);
    this->nn = nnpi_create(this->delaunay_triangulation);
    nnpi_setwmin(this->nn, wmin);
  }

  return true;
}
double NNInterpolator::interpolate(const Point pt)
{
  point pout;
  pout.x = pt.x();
  pout.y = pt.y();
  pout.z = 0.0;
  nnpi_interpolate_point(this->nn, &pout);
  return (pout.z);
}