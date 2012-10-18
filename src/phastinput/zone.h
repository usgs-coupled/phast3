#ifndef _INC_ZONE
#define _INC_ZONE
#include "gpc.h"
class Point;
/* ---------------------------------------------------------------------- 
 *   Zone
 * ---------------------------------------------------------------------- */
struct zone
{
	bool zone_defined;
	double x1;
	double y1;
	double z1;
	double x2;
	double y2;
	double z2;

	// constructors
	  zone(void);
	  zone(Point min, Point max);
	  zone(double x1, double y1, double z1, double x2, double y2, double z2);
	  zone(struct zone *zone_ptr);
	  zone(gpc_polygon *gpc_poly);
	 ~zone(void);

	// methods
	bool Point_in_zone(const Point &p)const;
	bool Point_in_xy_zone(const Point &p)const;
	bool operator==(const zone &other) const;
	bool operator!=(const zone &other) const;
};

#endif /* _INC_ZONE */
