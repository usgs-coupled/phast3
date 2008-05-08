#if !defined(ARCRASTER_H_INCLUDED)
#define ARCRASTER_H_INCLUDED
#include <string>
#include <vector>
class Point;
class ArcRaster
{
public:
  ArcRaster(void);
  ArcRaster(std::string filename);
  std::vector<Point> &get_points() {return this->pts;};
public:
  ~ArcRaster(void);

protected:
  // data
  std::vector<Point> pts;
  double cellsize;
  double xllcorner, yllcorner;
  int ncols, nrows;
  double nodata_value;
};
#endif // !defined(ARCRASTER_H_INCLUDED)