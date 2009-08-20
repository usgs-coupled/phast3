#include "Polygon_tree.h"
#include "Point.h"
#include "PHAST_polygon.h"

#include <list>

extern void free_check_null(void *ptr);

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

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
	if (this->polygon->Get_points().size() < 10)
		return false;
	PHAST_Transform::COORDINATE_SYSTEM cs =
		this->polygon->Get_coordinate_system();
// COMMENT: {7/7/2008 5:27:11 PM}  if (this->polygon->Get_points().size() < 10) return false;

	gpc_polygon *
		whole = PHAST_polygon2gpc_polygon(this->polygon);

	this->left = new Polygon_leaf;
	this->right = new Polygon_leaf;

	this->left->box = this->box;
	this->right->box = this->box;
	if (this->split_x)
	{
		this->left->box.x2 = (this->left->box.x1 + this->left->box.x2) / 2.0;
		this->right->box.x1 =
			(this->right->box.x1 + this->right->box.x2) / 2.0;
	}
	else
	{
		this->left->box.y2 = (this->left->box.y1 + this->left->box.y2) / 2.0;
		this->right->box.y1 =
			(this->right->box.y1 + this->right->box.y2) / 2.0;
	}
	this->left->split_x = !this->split_x;
	this->right->split_x = !this->split_x;

	// Make left leaf
	{
		gpc_polygon *
			rect = rectangle(this->left->box.x1, this->left->box.y1,
							 this->left->box.x2, this->left->box.y2);
		gpc_polygon *
			gpc_poly = empty_polygon();
		gpc_polygon_clip(GPC_INT, whole, rect, gpc_poly);
		this->left->polygon = new PHAST_polygon(gpc_poly, cs);
		gpc_free_polygon(rect);
		free_check_null(rect);
		gpc_free_polygon(gpc_poly);
		free_check_null(gpc_poly);
	}

	// Make right leaf
	{
		gpc_polygon *
			rect = rectangle(this->right->box.x1, this->right->box.y1,
							 this->right->box.x2, this->right->box.y2);
		gpc_polygon *
			gpc_poly = empty_polygon();
		gpc_polygon_clip(GPC_INT, whole, rect, gpc_poly);
		this->right->polygon = new PHAST_polygon(gpc_poly, cs);
		gpc_free_polygon(rect);
		free_check_null(rect);
		gpc_free_polygon(gpc_poly);
		free_check_null(gpc_poly);
	}
	gpc_free_polygon(whole);
	free_check_null(whole);
	return true;

}

bool Polygon_leaf::Point_in_polygon(Point p)
{
	return (this->polygon->Point_in_polygon(p));
}

Polygon_tree::Polygon_tree(void)
{
	this->root = NULL;
}

Polygon_tree::Polygon_tree(PHAST_polygon & polys)
{
	this->root = new Polygon_leaf;
	this->root->polygon = new PHAST_polygon(polys);
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
	std::vector < Polygon_leaf * >::iterator it;
	for (it = this->all_leaves.begin(); it != this->all_leaves.end(); it++)
	{
		delete *it;
	}
}

bool Polygon_tree::Point_in_polygon(Point p1)
{
	Point
		p = p1;
	p.set_z(0.0);
	if (!(this->root->box.Point_in_xy_zone(p)))
		return false;
	std::list < Polygon_leaf * >nodes_to_visit;
	nodes_to_visit.push_front(this->root);
	bool
		split_once = true;
	while (nodes_to_visit.size() > 0)
	{
		Polygon_leaf *
			visit;
		visit = *(nodes_to_visit.begin());
		nodes_to_visit.erase(nodes_to_visit.begin());

		// split node if needed
		if (visit->tip && split_once)
		{
			if (visit->split())
			{
				if (visit->left->box.Point_in_xy_zone(p))
				{
					nodes_to_visit.push_front(visit->left);
				}
				if (visit->right->box.Point_in_xy_zone(p))
				{
					nodes_to_visit.push_front(visit->right);
				}
				delete
					visit->
					polygon;
				visit->polygon = NULL;
				visit->tip = false;
				this->all_leaves.push_back(visit->left);
				this->all_leaves.push_back(visit->right);
			}
			else
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
		}
		else
		{
			if (visit->left->box.Point_in_xy_zone(p))
			{
				nodes_to_visit.push_front(visit->left);
			}
			if (visit->right->box.Point_in_xy_zone(p))
			{
				nodes_to_visit.push_front(visit->right);
			}
		}
	}
	return (false);
}
gpc_polygon *Polygon_tree::Intersect(gpc_polygon * cell_polygon)
{
	std::vector < Polygon_leaf * >::iterator it = this->all_leaves.begin();
	gpc_polygon *cummulative_intersection = empty_polygon();
	zone z(cell_polygon);
	for ( ; it != all_leaves.end(); it++)
	{
		if ((*it)->tip)
		{
			zone *z_leaf = (*it)->polygon->Get_bounding_box();
			if (z.x1 > z_leaf->x2 || z.x2 < z_leaf->x1 ||
				z.y1 > z_leaf->y2 || z.y2 < z_leaf->y1) continue;
			gpc_polygon *intersection = empty_polygon();
			//gpc_polygon *sub_polygon = PHAST_polygon2gpc_polygon((*it)->polygon);
			gpc_polygon *sub_poly = PHAST_polygon2gpc_polygon((*it)->polygon);
			gpc_polygon_clip(GPC_INT, sub_poly, cell_polygon, intersection);
			gpc_polygon_clip(GPC_UNION, cummulative_intersection, intersection, cummulative_intersection);
			/* free space */
			gpc_free_polygon(sub_poly);
			free_check_null(sub_poly);
			gpc_free_polygon(intersection);
			free_check_null(intersection);
		}
	}

	return cummulative_intersection;
}
void Polygon_tree::Dump_tree(void)
{
	int i = 0;
	std::vector < Polygon_leaf * >::iterator it = this->all_leaves.begin();
	for ( ; it != this->all_leaves.end(); it++)
	{
		std::cerr << "Leaf number: " << i++ << std::endl;
		(*it)->Dump_leaf();
	}
}
void Polygon_leaf::Dump_leaf(void)
{
	std::cerr << "   Low pt:  " << this->box.x1 << "  " << this->box.y1 << "  " << this->box.z1 << std::endl;
	std::cerr << "   High pt: " << this->box.x2 << "  " << this->box.y2 << "  " << this->box.z2 << std::endl;
	if (this->polygon != NULL) std::cerr << "   No. Pts: " <<  this->polygon->Get_points().size() << std::endl;
	std::cerr << "   Tip?:    " << this->tip << std::endl;
	std::cerr << "   Split_x: " << this->split_x << std::endl;

	/*
	zone box;
	Polygon_leaf *left;
	Polygon_leaf *right;
	PHAST_polygon *polygon;
	bool split_x;
	bool tip;	
	*/
}
