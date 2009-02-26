#ifndef _INC_ZONE
#define _INC_ZONE
class Point;
/* ---------------------------------------------------------------------- 
 *   Zone
 * ---------------------------------------------------------------------- */
struct zone
{
	int zone_defined;
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
	 ~zone(void);

	// methods
	bool Point_in_zone(Point p);
	bool Point_in_xy_zone(Point p);
	bool operator==(const zone &other) const;
	bool operator!=(const zone &other) const;
};

#endif /* _INC_ZONE */
