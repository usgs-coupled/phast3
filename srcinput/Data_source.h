#if !defined(DATA_SOURCE_H_INCLUDED)
#define DATA_SOURCE_H_INCLUDED
#include <sstream>
#include <vector>
class Point;
class Data_source
{
public:
  enum DATA_SOURCE_TYPE
  {
    SHAPE        = 0,
    ARCRASTER    = 1,
    XYZ          = 2,
    CONSTANT     = 3,
    POINTS       = 4,
    NONE         = 5
  };
  Data_source(void);
  bool read(std::istream &lines);
  void init();
  ~Data_source(void);

  // Data
  bool defined;
  std::string file_name;
  DATA_SOURCE_TYPE source_type;
  std::vector<Point> pts;
  int attribute;
};
#endif // !defined(DATA_SOURCE_H_INCLUDED)