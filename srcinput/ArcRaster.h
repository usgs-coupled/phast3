#if !defined(ARCRASTER_H_INCLUDED)
#define ARCRASTER_H_INCLUDED
#include "Filedata.h"
#include <string>
#include <vector>
class Point;
class ArcRaster:public Filedata
{
  public:
	ArcRaster(void);
	  ArcRaster(std::string filename, PHAST_Transform::COORDINATE_SYSTEM cs);
	bool Make_polygons(int field, PHAST_polygon & polygons)
	{
		return false;
	}

  public:
	  virtual ~ ArcRaster(void);

  protected:
	// data
	double cellsize;
	double xllcorner, yllcorner;
	int ncols, nrows;
	double nodata_value;
};
#endif // !defined(ARCRASTER_H_INCLUDED)
