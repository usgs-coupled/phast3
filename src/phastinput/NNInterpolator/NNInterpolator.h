#if !defined(NNINTERPOLATOR_H_INCLUDED)
#define NNINTERPOLATOR__H_INCLUDED
#include <vector>
#include <list>
#include <map>
#include "../KDtree/Point.h"
#include "../zone.h"
#include "../PHAST_Transform.h"
#include "nn.h"

class KDtree;

class NNInterpolator
{
	// TODO: Add your methods for this class here.
  public:
	// constructors
	NNInterpolator(void);

	// destructor
	  virtual ~ NNInterpolator(void);
	bool preprocess(const std::vector < Point > &pts_in,
					PHAST_Transform::COORDINATE_SYSTEM cs);
	double interpolate(const Point & pt)const;
	double interpolate(const Point & pt,
					   PHAST_Transform::COORDINATE_SYSTEM point_system,
					   PHAST_Transform * map2grid)const;
	KDtree *get_tree(void)const;

	void Set_coordinate_system(PHAST_Transform::COORDINATE_SYSTEM cs)
	{
		this->coordinate_system = cs;
	};
	PHAST_Transform::COORDINATE_SYSTEM Get_coordinate_system(void)
	{
		return this->coordinate_system;
	};
  public:
	// data
	delaunay * delaunay_triangulation;
	nnpi *nn;
	point *pin;
	size_t point_count;
	zone bounds;
	PHAST_Transform::COORDINATE_SYSTEM coordinate_system;

  protected:
	static std::map< const NNInterpolator *, KDtree * > KDtreeMap;

	friend bool nnpi_interpolate(std::vector < Point > &pts_in,
								 std::vector < Point > &pts_out, double wmin);
  private:
	NNInterpolator(const NNInterpolator&);  // Not implemented.
	void operator=(const NNInterpolator&);  // Not implemented.
};

void Clear_NNInterpolatorList(void);

#endif // !defined(NNINTERPOLATOR_H_INCLUDED)
