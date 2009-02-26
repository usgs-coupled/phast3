#if !defined(NNINTERPOLATOR_H_INCLUDED)
#define NNINTERPOLATOR__H_INCLUDED
#include <vector>
#include <list>
#include "../Point.h"
#include "../zone.h"
#include "../PHAST_Transform.h"
#include "../UniqueMap.h"
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
// COMMENT: {7/11/2008 9:27:18 PM}  bool preprocess(std::vector<Point> &pts_in, std::vector<Point> &corners);
	bool preprocess(std::vector < Point > &pts_in,
					PHAST_Transform::COORDINATE_SYSTEM cs);
	double interpolate(const Point & pt);
	double interpolate(const Point & pt,
					   PHAST_Transform::COORDINATE_SYSTEM point_system,
					   PHAST_Transform * map2grid);
	KDtree *get_tree(void);

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

	//static std::list<NNInterpolator*> NNInterpolatorList;
	static UniqueMap < NNInterpolator * >NNInterpolatorMap;

  protected:
	KDtree * tree;

	friend bool nnpi_interpolate(std::vector < Point > &pts_in,
								 std::vector < Point > &pts_out, double wmin);
};

void Clear_NNInterpolatorList(void);

#endif // !defined(NNINTERPOLATOR_H_INCLUDED)
