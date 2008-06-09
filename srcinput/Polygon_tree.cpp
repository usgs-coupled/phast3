#include "Polygon_tree.h"
#include "Point.h"
#include "PHST_polygon.h"
#include <list>
Polygon_leaf::Polygon_leaf()
{
  this->left = NULL;
  this->right = NULL;
  this->tip = true;
  this->split_x = true;
}
Polygon_leaf::~Polygon_leaf()
{
  if (this->polygon != NULL)
  {
    delete this->polygon;
  }
}
bool Polygon_leaf::split()
{
  // check number of points
  if (this->polygon->Get_points().size() < 10) return false;

  gpc_polygon *whole = PHST_polygon2gpc_polygon(this->polygon);

  this->left = new Polygon_leaf;
  this->right = new Polygon_leaf;

  this->left->box = this->box;
  this->right->box = this->box;
  if (this->split_x)
  {
    this->left->box.x2 = (this->left->box.x1 + this->left->box.x2) / 2.0;
    this->right->box.x1 = (this->right->box.x1 + this->right->box.x2) / 2.0;
  } else
  {
    this->left->box.y2 = (this->left->box.y1 + this->left->box.y2) / 2.0;
    this->right->box.y1 = (this->right->box.y1 + this->right->box.y2) / 2.0;
  }
  this->left->split_x = !this->split_x;
  this->right->split_x = !this->split_x;

  // Make left leaf
  {
    gpc_polygon *rect = rectangle(this->left->box.x1, this->left->box.y1, this->left->box.x2, this->left->box.y2);
    gpc_polygon *gpc_poly = empty_polygon();
    gpc_polygon_clip (GPC_INT, whole, rect, gpc_poly);
    this->left->polygon = new PHST_polygon(gpc_poly);
    gpc_free_polygon(rect);
    free(rect);
    gpc_free_polygon(gpc_poly);
    free(gpc_poly);
  }

  // Make right leaf
  {
    gpc_polygon *rect = rectangle(this->right->box.x1, this->right->box.y1, this->right->box.x2, this->right->box.y2);
    gpc_polygon *gpc_poly = empty_polygon();
    gpc_polygon_clip (GPC_INT, whole, rect, gpc_poly);
    this->right->polygon = new PHST_polygon(gpc_poly);
    gpc_free_polygon(rect);
    free(rect);
    gpc_free_polygon(gpc_poly);
    free(gpc_poly);
  }
  gpc_free_polygon(whole);
  free(whole);
  return true;

}
bool Polygon_leaf::Point_in_polygon(Point p)
{
  return(this->polygon->Point_in_polygon(p));
}
Polygon_tree::Polygon_tree(void)
{
  this->root = NULL;
}

Polygon_tree::Polygon_tree(PHST_polygon &polys)
{
  this->root = new Polygon_leaf;
  this->root->polygon = new PHST_polygon (polys);
  zone *zone_ptr = polys.Get_bounding_box();
  this->root->box.x1 = zone_ptr->x1;
  this->root->box.y1 = zone_ptr->y1;
  this->root->box.z1 = zone_ptr->z1;
  this->root->box.x2 = zone_ptr->x2;
  this->root->box.y2 = zone_ptr->y2;
  this->root->box.z2 = zone_ptr->z2;
  this->all_leaves.push_back(root);

}


Polygon_tree::~Polygon_tree(void)
{
  std::vector<Polygon_leaf *>::iterator it;
  for (it = this->all_leaves.begin(); it != this->all_leaves.end(); it++)
  {
    delete *it;
  }
}

bool Polygon_tree::Point_in_polygon(Point p1)
{
  Point p = p1;
  p.set_z(0.0);
  if (!(this->root->box.Point_in_zone(p))) return false;
  std::list<Polygon_leaf *> nodes_to_visit;
  nodes_to_visit.push_front(this->root);
  bool split_once = true;
  while (nodes_to_visit.size() > 0)
  {
    Polygon_leaf * visit;
    visit = *(nodes_to_visit.begin());
    nodes_to_visit.erase(nodes_to_visit.begin());

    // split node if needed
    if (visit->tip && split_once)
    {
      if (visit->split())
      {
	if (visit->left->box.Point_in_zone(p))
	{
	  nodes_to_visit.push_front(visit->left);
	}
	if (visit->right->box.Point_in_zone(p))
	{
	  nodes_to_visit.push_front(visit->right);
	}
	delete visit->polygon;
	visit->polygon = NULL;
	visit->tip = false;
	this->all_leaves.push_back(visit->left);
	this->all_leaves.push_back(visit->right);
      } else
      {
	nodes_to_visit.push_front(visit);
      }
      split_once = false;
      continue;
    }
    if (visit->tip)
    {
      // Ready to test for point in polygon
      if (visit->Point_in_polygon(p)) 
      {
	return true;
      }
    } else
    {
      if (visit->left->box.Point_in_zone(p))
      {
	nodes_to_visit.push_front(visit->left);
      }
      if (visit->right->box.Point_in_zone(p))
      {
	nodes_to_visit.push_front(visit->right);
      }
    }
  }
  return(false);
}
