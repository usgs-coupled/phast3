#if !defined(DRAIN_H_INCLUDED)
#define DRAIN_H_INCLUDED
#include <vector>   // std::vector
#include <string>   // std::string
#include "gpc.h"
#include "River.h"

class Drain
{
public:
  Drain(void);
  void Convert_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM target, PHAST_Transform *map2grid);
public:
  ~Drain(void);
public:
  // Data
  std::vector<River_Point> points;
  int n_user;
  std::string description;
  PHAST_Transform::COORDINATE_SYSTEM coordinate_system;
};
  // subroutines
  int tidy_drains(void);
  int build_drains(void);
  int setup_drains(void);
#endif // !defined(DRAIN_H_INCLUDED)
