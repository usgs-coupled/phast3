#include "Domain.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <iostream>
#include <ostream>


Domain::Domain(PHAST_Transform::COORDINATE_SYSTEM cs)
: Cube(cs)
{
}

Domain::Domain(const struct zone *zone_ptr, PHAST_Transform::COORDINATE_SYSTEM cs)
: Cube(zone_ptr, cs)
{
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

void Domain::printOn(std::ostream & os) const
{
	os << "\t" << "-domain\n";
	if (this->description.size())
	{
		os << "\t\t" << "-description " << this->description << "\n";
	}
}
