#include "Exterior_cell.h"
#include "message.h"
#include "Helpers.h"
Exterior_cell::Exterior_cell(void)
{
  xn = xp = yn = yp = zn = zp = false;
  xn_area = xp_area = yn_area = yp_area = zn_area = zp_area = 0.0;
  xn_gon = xp_gon = yn_gon = yp_gon = zn_gon = zp_gon = NULL;
}
Exterior_cell::~Exterior_cell(void)
{
  gpc_free_polygon(this->xn_gon);
  free_check_null(this->xn_gon);

  gpc_free_polygon(this->xp_gon);
  free_check_null(this->xp_gon);

  gpc_free_polygon(this->yn_gon);
  free_check_null(this->yn_gon);

  gpc_free_polygon(this->yp_gon);
  free_check_null(this->yp_gon);

  gpc_free_polygon(this->zn_gon);
  free_check_null(this->zn_gon);

  gpc_free_polygon(this->zp_gon);
  free_check_null(this->zp_gon);
}

gpc_polygon * Exterior_cell::get_exterior_polygon(Cell_Face face)
{
  // get polygon for cell face
  gpc_polygon *cell_face_polygon = NULL;
  switch (face)
  {
  case CF_X:
    if (this->xn)
    {
      cell_face_polygon  = this->xn_gon;
    } else if (this->xp)
    {
      cell_face_polygon  = this->xp_gon;
    }
    break;
  case CF_Y:
    if (this->yn)
    {
      cell_face_polygon  = this->yn_gon;
    } else if (this->yp)
    {
      cell_face_polygon  = this->yp_gon;
    }
    break;
  case CF_Z:
    if (this->zn)
    {
      cell_face_polygon  = this->zn_gon;
    } else if (this->zp)
    {
      cell_face_polygon  = this->zp_gon;
    }
    break;
  default:
    break;
  }
  return(cell_face_polygon);
}

extern double gpc_polygon_area(gpc_polygon *p_ptr);
void Exterior_cell::dump(void)
{
  std::ostringstream ostring;
  if (this->xn) ostring << "xn: " << this->xn << " area: " << this->xn_area << std::endl;
  if (this->xn) ostring << "xn: " << this->xn << " area: " << gpc_polygon_area(this->xn_gon) << std::endl;

  if (this->xp) ostring << "xp: " << this->xp << " area: " << this->xp_area << std::endl;
  if (this->xp) ostring << "xp: " << this->xp << " area: " << gpc_polygon_area(this->xp_gon) << std::endl;

  if (this->yn) ostring << "yn: " << this->yn << " area: " << this->yn_area << std::endl;
  if (this->yn) ostring << "yn: " << this->yn << " area: " << gpc_polygon_area(this->yn_gon) << std::endl;

  if (this->yp) ostring << "yp: " << this->yp << " area: " << this->yp_area << std::endl;
  if (this->yp) ostring << "yp: " << this->yp << " area: " << gpc_polygon_area(this->yp_gon) << std::endl;

  if (this->zn) ostring << "zn: " << this->zn << " area: " << this->zn_area << std::endl;
  if (this->zn) ostring << "zn: " << this->zn << " area: " << gpc_polygon_area(this->zn_gon) << std::endl;

  if (this->zp) ostring << "zp: " << this->zp << " area: " << this->zp_area << std::endl;
  if (this->zp) ostring << "zp: " << this->zp << " area: " << gpc_polygon_area(this->zp_gon) << std::endl;

  output_msg(OUTPUT_MESSAGE, "%s\n", ostring.str().c_str());
}
