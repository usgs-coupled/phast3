#include "BC_info.h"
#include "Utilities.h"
extern int mix_init(struct mix *mix_ptr);
BC_info::BC_info(void)
{
  this->bc_type = BC_UNDEFINED;
  this->bc_head = 0;
  this->bc_head_defined = false;
  this->bc_flux = 0;
  this->bc_flux_defined = false;
  this->bc_k = 0;
  this->bc_k_defined = false;
  this->bc_thick = 0;
  this->bc_thick_defined = false;
  this->bc_solution_type = 2; /* UNDEFINED */
  mix_init(&(this->bc_solution)); 
  this->bc_solution_defined = false;
  this->poly = NULL;
  this->area = 0.0;
  this->bc_definition = -1;
  this->face = CF_UNKNOWN;

}
BC_info::BC_info(const BC_info &bcinfo)
{
  this->Copy(bcinfo);
}
BC_info::~BC_info(void)
{
  this->Free_poly();
}

void BC_info::Free_poly(void)
{
  if (this->poly != NULL)
  {
    gpc_free_polygon(this->poly);
    free_check_null(this->poly);
  }
  this->poly = NULL;
  this->area = 0.0;
}

BC_info & BC_info::operator=(const BC_info &bcinfo)
{
  if (this != &bcinfo)
  {
    this->Copy(bcinfo);
  }
  return(*this);
}
void BC_info::Copy(const BC_info &bcinfo)
{
    this->bc_type = bcinfo.bc_type;
    this->bc_head = bcinfo.bc_head;
    this->bc_head_defined = bcinfo.bc_head_defined;
    this->bc_flux = bcinfo.bc_flux;
    this->bc_flux_defined = bcinfo.bc_flux_defined;
    this->bc_k = bcinfo.bc_k;
    this->bc_k_defined = bcinfo.bc_k_defined;
    this->bc_thick = bcinfo.bc_thick;
    this->bc_thick_defined = bcinfo.bc_thick_defined;
    this->bc_solution_type = bcinfo.bc_solution_type; 

    this->bc_solution.i1 = bcinfo.bc_solution.i1;
    this->bc_solution.i2 = bcinfo.bc_solution.i2;
    this->bc_solution.f1 = bcinfo.bc_solution.f1;

    this->bc_solution_defined = bcinfo.bc_solution_defined;
    this->poly = NULL;
    if (bcinfo.poly != NULL)
    {
      this->poly = gpc_polygon_duplicate(bcinfo.poly);
    } 
    this->area = bcinfo.area;
    this->bc_definition = bcinfo.bc_definition;
    this->face = bcinfo.face;
}
