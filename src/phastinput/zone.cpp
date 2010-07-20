#include "zone.h"
#include "KDtree/Point.h"
#include <list>
zone::zone()
{
	this->zone_defined = 0;		// false
	this->x1 = 0;
	this->y1 = 0;
	this->z1 = 0;
	this->x2 = 0;
	this->y2 = 0;
	this->z2 = 0;
}

zone::zone(Point min, Point max)
{
	this->zone_defined = 1;		// true
	this->x1 = min.x();
	this->y1 = min.y();
	this->z1 = min.z();
	this->x2 = max.x();
	this->y2 = max.y();
	this->z2 = max.z();
}

zone::zone(double m_x1, double m_y1, double m_z1, double m_x2, double m_y2, double m_z2)
{
	this->zone_defined = 1;		// true
	this->x1 = m_x1;
	this->y1 = m_y1;
	this->z1 = m_z1;
	this->x2 = m_x2;
	this->y2 = m_y2;
	this->z2 = m_z2;
}
zone::zone(struct zone *zone_ptr)
{
	this->zone_defined = 1;		// true
	this->x1 = zone_ptr->x1;
	this->y1 = zone_ptr->y1;
	this->z1 = zone_ptr->z1;
	this->x2 = zone_ptr->x2;
	this->y2 = zone_ptr->y2;
	this->z2 = zone_ptr->z2;
}
zone::zone(gpc_polygon *poly)
{
	std::list<Point> pts;
	int i, k, N;

	for (k = 0; k < poly->num_contours; k++)
	{
		N = poly->contour[k].num_vertices;
		for (i = 0; i < poly->contour[k].num_vertices; i++)
		{
			pts.push_back(Point(poly->contour[k].vertex[i].x, poly->contour[k].vertex[i].y, 0));
		}
	}
	zone z;
	if (pts.size() > 0)
	{
		zone z1(Point(pts.begin(), pts.end(),  Point::MIN), Point(pts.begin(), pts.end(),  Point::MAX));
		z = z1;
	}
	this->zone_defined = 1;		// true
	this->x1 = z.x1;
	this->y1 = z.y1;
	this->z1 = z.z1;
	this->x2 = z.x2;
	this->y2 = z.y2;
	this->z2 = z.z2;

	return;
}
zone::~zone(void)
{
}

bool zone::Point_in_zone(Point p)
{
	if (p.x() >= this->x1 && p.x() <= this->x2 &&
		p.y() >= this->y1 && p.y() <= this->y2 &&
		p.z() >= this->z1 && p.z() <= this->z2)
		return true;
	return false;
}

bool zone::Point_in_xy_zone(Point p)
{
	if (p.x() >= this->x1 && p.x() <= this->x2 &&
		p.y() >= this->y1 && p.y() <= this->y2)
		return true;
	return false;
}

bool zone::operator==(const zone &other) const
{
	return (
		this->zone_defined == other.zone_defined &&
		this->x1           == other.x1 &&
		this->x2           == other.x2 &&
		this->y1           == other.y1 &&
		this->y2           == other.y2 &&
		this->z1           == other.z1 &&
		this->z2           == other.z2
		);
}

bool zone::operator!=(const zone &other) const
{
	return !(*this == other);
}
