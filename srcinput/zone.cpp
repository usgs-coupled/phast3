#include "zone.h"
#include "Point.h"
zone::zone()
{
	this->zone_defined = 0; // false
	this->x1 = 0;
	this->y1 = 0;
	this->z1 = 0;
	this->x2 = 0;
	this->y2 = 0;
	this->z2 = 0;
}
zone::zone(Point min, Point max)
{
  this->zone_defined = 1; // true
  this->x1 = min.x();
  this->y1 = min.y();
  this->z1 = min.z();
  this->x2 = max.x();
  this->y2 = max.y();
  this->z2 = max.z();
}
zone::zone(double x1, double y1, double z1, double x2, double y2, double z2)
{
  this->zone_defined = 1; // true
  this->x1 = x1;
  this->y1 = y1;
  this->z1 = z1;
  this->x2 = x2;
  this->y2 = y2;
  this->z2 = z2;
}
zone::zone(struct zone *zone_ptr)
{
  this->zone_defined = 1; // true
  this->x1 = zone_ptr->x1;
  this->y1 = zone_ptr->y1;
  this->z1 = zone_ptr->z1;
  this->x2 = zone_ptr->x2;
  this->y2 = zone_ptr->y2;
  this->z2 = zone_ptr->z2;
}
zone::~zone(void)
{
}
bool zone::Point_in_zone(Point p)
{
  if (p.x() >= this->x1 && p.x() <= this->x2 &&
    p.y() >= this->y1 && p.y() <= this->y2 &&
    p.z() >= this->z1 && p.z() <= this->z2 ) return true;
  return false;
}
