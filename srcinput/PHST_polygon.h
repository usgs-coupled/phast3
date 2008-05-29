#if !defined(PHST_POLYGON_H_INCLUDED)
#define PHST_POLYGON_H_INCLUDED
#include <vector>
#include "Point.h"
class PHST_polygon
{
public:
  PHST_polygon(void);
public:
  ~PHST_polygon(void);
  // methods
  void set_z(double z);
  void set_z_to_v();
  bool Point_in_polygon(Point p);
  bool Line_intersect(Point lp1, Point lp2, std::vector<Point> &intersect_pts);
  std::vector<Point> &Get_points() {return this->pts;};
  std::vector< std::vector<Point>::iterator > &Get_begin() {return this->begin;};
  std::vector< std::vector<Point>::iterator > &Get_end() {return this->end;};

protected:
  // data
  std::vector<Point> pts;
  std::vector< std::vector<Point>::iterator > begin;
  std::vector< std::vector<Point>::iterator > end;

public:
  friend bool Point_in_simple_polygon(Point p, std::vector<Point>::iterator begin, std::vector<Point>::iterator end);
  friend bool Line_intersect_simple_polygon(Point lp1, Point lp2, std::vector<Point>::iterator begin, std::vector<Point>::iterator end, std::vector<Point> &intersect_pts);
};
#endif // PHST_POLYGON_H_INCLUDED
