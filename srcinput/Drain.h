#if !defined(DRAIN_H_INCLUDED)
#define DRAIN_H_INCLUDED
#include <vector>				// std::vector
#include <string>				// std::string
#include "gpc.h"
#include "River.h"

class Drain
{
  public:
	Drain(void);
	//void Convert_xy_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM target,
	//							   PHAST_Transform * map2grid);
	//void Convert_z_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM target,
	//							   PHAST_Transform * map2grid);
	void Convert_xy_to_grid(PHAST_Transform * map2grid);
	void Convert_z_to_grid(PHAST_Transform * map2grid);
	void Convert_width_to_grid(void);
  public:
	 ~Drain(void);
  public:
	// Data
	  std::vector < River_Point > points;
	int n_user;
	  std::string description;
	  PHAST_Transform::COORDINATE_SYSTEM coordinate_system;
	  PHAST_Transform::COORDINATE_SYSTEM z_coordinate_system;
};
  // subroutines
int tidy_drains(void);
int build_drains(void);
int setup_drains(void);
#endif // !defined(DRAIN_H_INCLUDED)
