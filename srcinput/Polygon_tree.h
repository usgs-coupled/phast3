#if !defined(POLYGON_TREE_H_INCLUDED)
#define POLYGON_TREE_H_INCLUDED
#include <vector>
#include "gpc.h"
#include "zone.h"
#include "PHST_polygon.h"
class Point;
class Polygon_leaf
{
public:
  Polygon_leaf();
  virtual ~Polygon_leaf();

  // methods
  bool split(void);
  bool Point_in_polygon(Point p);

  // Data
  zone box;
  Polygon_leaf *left;
  Polygon_leaf *right;
  PHST_polygon *polygon;
  bool split_x;
  bool tip;
};
class Polygon_tree
{
public:
  Polygon_tree(void);
  Polygon_tree(PHST_polygon &polys);

public:
  virtual ~Polygon_tree(void);

  bool Point_in_polygon(Point p);

public:
  // Data
  Polygon_leaf *root;
  std::vector<Polygon_leaf *> all_leaves;
};
#endif // !defined(POLYGON_TREE_H_INCLUDED)