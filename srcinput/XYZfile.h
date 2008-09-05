#if !defined(XYZFILE_H_INCLUDED)
#define XYZFILE_H_INCLUDED
#include "Filedata.h"
#include <string>
#include <vector>
class Point;
class XYZfile : public Filedata
{
public:
  XYZfile(void);
  XYZfile(std::string filename, PHAST_Transform::COORDINATE_SYSTEM cs);
  bool                          Make_polygons( int field, PHAST_polygon &polygons);
  int                           Get_columns(void) {return this->columns;};
  void                          Set_columns(int i) {this->columns = i;};

public:
  virtual ~XYZfile(void);

protected:
  // data
	int columns;
};
#endif // !defined(XYZFILE_H_INCLUDED)
