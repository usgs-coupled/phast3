#if !defined(FILEDATA_H_INCLUDED)
#define FILEDATA_H_INCLUDED
#include <vector>
class Point;
#include "zone.h"
#include "gpc.h"
#include <map>

class Filedata
{
public:
  Filedata(void);
public:
  ~Filedata(void);
  virtual struct zone *Bounding_box() = 0;
  virtual std::vector<Point> & Get_points(const int field) = 0;
  virtual gpc_polygon * Get_polygons(void) = 0;
  // Data
  struct zone box;
  static std::map<std::string,Filedata *> file_data_map;
};
#endif // FILEDATA_H_INCLUDED