#include "Polyhedron.h"

Polyhedron::Polyhedron(void)
{
}

Polyhedron::~Polyhedron(void)
{
}

bool Polyhedron::Point_in_bounding_box(const Point & s)const
{
	const struct zone *
		zo = this->Get_bounding_box();
	Point
		t = s;
	if (t.x() >= zo->x1 && t.x() <= zo->x2 &&
		t.y() >= zo->y1 && t.y() <= zo->y2 &&
		t.z() >= zo->z1 && t.z() <= zo->z2)
	{
		return true;
	}
	return false;
}
