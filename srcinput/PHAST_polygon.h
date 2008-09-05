#if !defined(PHAST_POLYGON_H_INCLUDED)
#define PHAST_POLYGON_H_INCLUDED
#include <vector>
#include "Point.h"
#include "gpc.h"
#include "zone.h"
#include "PHAST_Transform.h"
class PHAST_polygon
{
public:
  PHAST_polygon(void);
  PHAST_polygon(gpc_polygon *poly, PHAST_Transform::COORDINATE_SYSTEM cs);
  PHAST_polygon(const std::vector<Point> &pts, PHAST_Transform::COORDINATE_SYSTEM cs);
  PHAST_polygon(const PHAST_polygon &poly);

public:
  ~PHAST_polygon(void);
  // methods
  void set_z(double z);
  void set_z_to_v();
  bool Point_in_polygon(Point p);
  bool Line_intersect(Point lp1, Point lp2, std::vector<Point> &intersect_pts);
  std::vector<Point> &Get_points() {return this->pts;};
  std::vector< std::vector<Point>::iterator > &Get_begin() {return this->begin;};
  std::vector< std::vector<Point>::iterator > &Get_end() {return this->end;};
  void          Set_bounding_box(void);
  struct zone * Get_bounding_box(void){return &(this->box);};

  PHAST_Transform::COORDINATE_SYSTEM Get_coordinate_system(void) {return this->coordinate_system;};
  void                               Set_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM cs) {this->coordinate_system = cs;};
  void Clear(void);
  PHAST_polygon& operator=(const PHAST_polygon& poly);

protected:
  // data
  struct zone box;
  std::vector<Point> pts;
  std::vector< std::vector<Point>::iterator > begin;
  std::vector< std::vector<Point>::iterator > end;
  PHAST_Transform::COORDINATE_SYSTEM coordinate_system;

public:
  //friend bool Point_in_simple_polygon(Point p, std::vector<Point>::iterator begin, std::vector<Point>::iterator end);
  //friend bool Line_intersect_simple_polygon(Point lp1, Point lp2, std::vector<Point>::iterator begin, std::vector<Point>::iterator end, std::vector<Point> &intersect_pts);
};
bool Point_in_simple_polygon(Point p, std::vector<Point>::iterator begin, std::vector<Point>::iterator end);
bool Line_intersect_simple_polygon(Point lp1, Point lp2, std::vector<Point>::iterator begin, std::vector<Point>::iterator end, std::vector<Point> &intersect_pts);
#endif // PHAST_POLYGON_H_INCLUDED
