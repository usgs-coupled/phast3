#if !defined(WEDGE_H_INCLUDED)
#define WEDGE_H_INCLUDED
#include "Cube.h"

class Wedge:public Cube
{
  public:
	Wedge(void);

	//template<class InputIterator>
	  Wedge(const struct zone *zone_ptr, std::string & orient);

	  virtual ~ Wedge(void);

	enum WEDGE_ORIENTATION
	{
		X1, X2, X3, X4,
		Y1, Y2, Y3, Y4,
		Z1, Z2, Z3, Z4,
		WEDGE_ERROR
	};

	// methods
	bool Point_in_polyhedron(const Point & t);
	void Points_in_polyhedron(std::list < int >&list,
							  std::vector < Point > &point_coord);
	//gpc_polygon *Face_polygon(Cell_Face face);
	gpc_polygon *Slice(Cell_Face face, double coord);
	virtual Wedge *clone() const;
	virtual Wedge *create() const;

	WEDGE_ORIENTATION Get_orientation(void)
	{
		return this->orientation;
	};
	Cell_Face Get_wedge_axis()
	{
		return this->wedge_axis;
	};
	int Get_wedge_number()
	{
		return this->wedge_number;
	};
	// Data
	enum WEDGE_ORIENTATION orientation;
	enum Cell_Face wedge_axis;
	int wedge_number;
	std::vector < Point > vertices;	// lower triangle first, right angle is second vertex, then upper triangle

  protected:
	virtual void printOn(std::ostream & os) const;
};

#endif // !defined(WEDGE_H_INCLUDED)
