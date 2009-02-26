#if !defined(BC_INFO_H_INCLUDED)
#define BC_INFO_H_INCLUDED
#include "Mix.h"
#include "gpc.h"
#include "Cell_Face.h"
class BC_info
{
  public:

	enum BC_TYPE
	{
		BC_SPECIFIED = 8,
		BC_FLUX = 9,
		BC_LEAKY = 10,
		BC_UNDEFINED
	};
	  BC_info(void);
	  BC_info(const BC_info & bcinfo);
	  BC_info & operator=(const BC_info & bcinfo);
  public:
	 ~BC_info(void);
  public:
	// Methods
	void Free_poly(void);


	// Data
	BC_TYPE bc_type;
	double bc_head;
	bool bc_head_defined;
	double bc_flux;
	bool bc_flux_defined;
	double bc_k;
	bool bc_k_defined;
	double bc_thick;
	bool bc_thick_defined;
	int bc_solution_type;
	struct mix bc_solution;
	bool bc_solution_defined;
	gpc_polygon *poly;
	double area;
	int bc_definition;
	Cell_Face face;

  protected:
	void Copy(const BC_info & bcinfo);
};
#endif // !defined(BC_INFO_H_INCLUDED)
