#if defined(__WPHAST__)
#include "../StdAfx.h"
#endif

#include <cassert>

#define EXTERNAL extern
#include "hstinpt.h"
#undef EXTERNAL

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

cunits::cunits(void):
time("s"),
horizontal("m"),
vertical("m"),
head("m"),
k("m/s"),
s("1/m"),
alpha("m"),
leaky_k("m/s"),
leaky_thick("m"),
flux("m/s"),
well_diameter("m"),
well_pumpage("m^3/s"),
river_bed_k("m/s"),
river_bed_thickness("m"),
drain_bed_k("m/s"),
drain_bed_thickness("m"),
drain_width("m"),
map_horizontal("m"),
map_vertical("m"),
river_width("m")
{
}

cunits::~cunits(void)
{
}

void
cunits::undefine(void)
{
	this->time.undefine();
	this->horizontal.undefine();
	this->vertical.undefine();
	this->head.undefine();
	this->k.undefine();
	this->s.undefine();
	this->alpha.undefine();
	this->leaky_k.undefine();
	this->leaky_thick.undefine();
	this->flux.undefine();
	this->well_diameter.undefine();
	this->well_pumpage.undefine();
	this->river_bed_k.undefine();
	this->river_bed_thickness.undefine();
	this->drain_bed_k.undefine();
	this->drain_bed_thickness.undefine();
	this->drain_width.undefine();
	this->map_horizontal.undefine();
	this->map_vertical.undefine();
	this->river_width.undefine();
}
