#include "Domain.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <iostream>
#include <ostream>


Domain::Domain(void)
: Cube(PHAST_Transform::GRID)
{
	this->type = GRID_DOMAIN;
}

Domain::Domain(const struct zone *zone_ptr)
: Cube(zone_ptr, PHAST_Transform::GRID)
{
	this->type = GRID_DOMAIN;
}

Domain::~Domain(void)
{
}

Domain* Domain::clone() const
{
	return new Domain(*this);
}

Domain* Domain::create() const
{
	return new Domain();
}

void Domain::SetZone(const struct zone *zone_ptr)
{
	// Define cube in standard order left, front, bottom point first
	this->p.clear();
	this->p.push_back(Point(zone_ptr->x1, zone_ptr->y1, zone_ptr->z1));
	this->p.push_back(Point(zone_ptr->x2, zone_ptr->y2, zone_ptr->z2));

	Point mn(this->p.begin(), this->p.end(), Point::MIN);
	Point mx(this->p.begin(), this->p.end(), Point::MAX);

	this->p.clear();
	this->p.push_back(mn);
	this->p.push_back(mx);

	// Set bounding box
	this->Set_bounding_box();
}

void Domain::printOn(std::ostream & os) const
{
	os << "\t" << "-domain\n";
	if (this->description.size())
	{
		os << "\t\t" << "-description " << this->description << "\n";
	}
}
