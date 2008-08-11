#if !defined(POINT_H_INCLUDED)
#define POINT_H_INCLUDED
#include <vector>
#include <math.h>
#include "gpc.h"
class Point
{
public:

  // enums
  enum POINT_STAT 
  {
    MAX,
    MIN
  };

  // constructors
  Point(void);

  Point(double x, double y, double z) {
    this->coord[0] = x;
    this->coord[1] = y;
    this->coord[2] = z;
    this->v = 0.0;
  };

  Point(double x, double y, double z, double v) {
    this->coord[0] = x;
    this->coord[1] = y;
    this->coord[2] = z;
    this->v = v;
  };

  // Apparently this use of templates requires the code to be in the header file
  template<class InputIterator>
  Point(InputIterator First, InputIterator Last, Point::POINT_STAT stat)
  {
    int i ;
    // origin by default
    if (First == Last)
    {
      this->coord[0] = 0.0;
      this->coord[1] = 0.0;
      this->coord[2] = 0.0;
      this->v = 0.0;
      return;
    }

    // start with first point
    InputIterator it = First;
    this->coord[0] = it->coord[0];
    this->coord[1] = it->coord[1];
    this->coord[2] = it->coord[2];
    this->v = it->v;
    it++;

    // find min or max
    switch (stat)
    {
    case MAX:
      for (  ; it != Last; it++) 
      {
	for(i = 0; i < 3; i++)
	{
	  if (it->coord[i] > this->coord[i]) this->coord[i] = it->coord[i];
	}
	if (it->v > this->v) this->v = it->v;
      }
      break;
    case MIN:
      for (  ; it != Last; it++) 
      {
	for(i = 0; i < 3; i++)
	{
	  if (it->coord[i] < this->coord[i]) this->coord[i] = it->coord[i];
	}
	if (it->v < this->v) this->v = it->v;
      }
      break;
    }
  } 
  // end constructor Point(InputIterator First, InputIterator Last, Point::POINT_STAT stat)

  // destructor
  ~Point(void);

  // methods
  double modulus() {return sqrt(this->coord[0]*this->coord[0] + this->coord[1]*this->coord[1] + this->coord[2]*this->coord[2]);}

  // get methods
  double x(void)const {return this->coord[0];}
  double y(void)const {return this->coord[1];}
  double z(void)const {return this->coord[2];}
  double *get_coord() {return this->coord;}
  double get_v()const {return this->v;}

  // set methods
  void set_x(double t) {this->coord[0] = t;}
  void set_y(double t) {this->coord[1] = t;}
  void set_z(double t) {this->coord[2] = t;}
  void set_v(double t) {this->v = t;}
  friend double interpolate_inverse_square(std::vector<Point> &pts, Point &grid_pt);
  friend double interpolate_nearest(std::vector<Point> &pts, Point &grid_pt);
  friend int Read_points(std::istream &input, std::vector<Point> &pts);

  // operator overload
  friend Point operator+(Point a, Point b);
  friend Point operator-(Point a, Point b);
  friend Point operator*(Point a, double b);
  friend Point operator*(double b, Point a);
  friend bool operator < (Point &a, Point &b);
  friend bool operator == (Point &a, Point &b);
  bool point_in_gpc_polygon(gpc_polygon *poly_ptr);
  bool Point_in_polygon(std::vector<Point> &pts);


#ifdef SKIP
  // Required to be in header?
  // 3D point in polygon routine
  // Accuracy problem?
#define TWOPI 6.283185307179586476925287
#define EPSILON 1e-8
  template<class InputIterator>
  bool Point_in_polygon(InputIterator First, InputIterator Last) 
  {
    InputIterator it = First;
    Point p1, p2;
    double anglesum = 0;
    double costheta;
    for ( ; it != Last; it++)
    {
      p1 = Point(it->x() - this->x(), it->y() - this->y(), it->z() - this->z());
      if (it + 1 != Last)
      {
	p2 = Point((it+1)->x() - this->x(), (it+1)->y() - this->y(), (it+1)->z() - this->z());
      } else
      {
	p2 = Point(First->x() - this->x(), First->y() - this->y(), First->z() - this->z());
      }
      double m1 = p1.modulus();
      double m2 = p2.modulus();
      if (m1*m2 <= EPSILON)
      {
	return(true); /* We are on a node, consider this inside */
      } else
      {
	costheta = (p1.x()*p2.x() + p1.y()*p2.y() + p1.z()*p2.z()) / (m1*m2);
      }
      anglesum += acos(costheta);
    }
    if (fabs(anglesum - TWOPI) < EPSILON) return(true);
    return false;
  }
#endif
protected:
  double coord[3];
  double v;

};
class Segment
{
  public:
  // constructors
  Segment(void);
  Segment(Point p1, Point p2);
  // destructor
  ~Segment(void);
  std::vector<Point> pts;
};
#endif // !defined(POINT_H_INCLUDED)


// point in polygon methods
#ifdef SKIP
//http://local.wasp.uwa.edu.au/~pbourke/geometry/insidepoly/
int pnpoly(int npol, float *xp, float *yp, float x, float y)
{
  int i, j, c = 0;
  for (i = 0, j = npol-1; i < npol; j = i++) {
    if ((((yp[i] <= y) && (y < yp[j])) ||
      ((yp[j] <= y) && (y < yp[i]))) &&
      (x < (xp[j] - xp[i]) * (y - yp[i]) / (yp[j] - yp[i]) + xp[i]))
      c = !c;
  }
  return c;
}

//3D
typedef struct {
  double x,y,z;
} XYZ;
#define EPSILON  0.0000001
#define MODULUS(p) (sqrt(p.x*p.x + p.y*p.y + p.z*p.z))
#define TWOPI 6.283185307179586476925287
#define RTOD 57.2957795
double CalcAngleSum(XYZ q,XYZ *p,int n)
{
  int i;
  double m1,m2;
  double anglesum=0,costheta;
  XYZ p1,p2;

  for (i=0;i<n;i++) {

    p1.x = p[i].x - q.x;
    p1.y = p[i].y - q.y;
    p1.z = p[i].z - q.z;
    p2.x = p[(i+1)%n].x - q.x;
    p2.y = p[(i+1)%n].y - q.y;
    p2.z = p[(i+1)%n].z - q.z;

    m1 = MODULUS(p1);
    m2 = MODULUS(p2);
    if (m1*m2 <= EPSILON)
      return(TWOPI); /* We are on a node, consider this inside */
    else
      costheta = (p1.x*p2.x + p1.y*p2.y + p1.z*p2.z) / (m1*m2);

    anglesum += acos(costheta);
  }
  return(anglesum);
}


#endif
