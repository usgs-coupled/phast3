#include "Data_source.h"
#include "message.h"
#include "Helpers.h"
#include "Point.h"
Data_source::Data_source(void)
{
  this->init();
}
Data_source::~Data_source(void)
{
}
void Data_source::init()
{
  this->pts.clear();
  this->file_name.clear();
  this->defined = false;
  this->source_type = Data_source::NONE;
  this->attribute = -1;
}
bool Data_source::read(std::istream &lines)
{
  bool success = true;
  this->init();
 
  // read information for top, or bottom
  const char *opt_list[] = {
    "constant",                         /* 0 */
    "points",                           /* 1 */
    "shape",                            /* 2 */
    "xyz",                              /* 3 */
    "arcraster"                         /* 4 */
  };
  int count_opt_list = 5; 
  std::vector<std::string> std_opt_list;
  int i;
  for (i = 0; i < count_opt_list; i++) std_opt_list.push_back(opt_list[i]);

  std::string type;
  lines >> type;
  int j = case_picker(std_opt_list, type);
  if (j < 0)
  {
    error_msg("Error reading data type (CONSTANT, POINTS, SHAPE, XYZ, or ArcRaster).", EA_CONTINUE);
    return(false);
  }

  switch (j)
  {
    // constant
  case 0:
    this->source_type = Data_source::CONSTANT;
    double elev;
    if (!(lines >> elev))
    {
      error_msg("Error reading constant elevation of prism top.", EA_CONTINUE);
      success = false;
    } else
    {
      this->pts.push_back(Point(0.0, 0.0, elev));
    }
    break;

    // points
  case 1:
    this->source_type = Data_source::POINTS;
    {
      i = 0;
      Point p;
      double *coord = p.get_coord();
      while (lines >> coord[i%3])
      {
	if (i%3 == 2) this->pts.push_back(p);
	i++;
      }
    }
    if (this->pts.size() < 3)
    {
      error_msg("Error reading top of prism, expected at least 3 points.", EA_CONTINUE);
      success = false;
    } 
    break;

    // Shape file
  case 2:
    this->source_type = Data_source::SHAPE;
    if (!(lines >> this->file_name)) success = false;
    lines >> this->attribute;
    if (!success) error_msg("Error reading shape file name or attribute number.", EA_CONTINUE);
    break;

    // Arc Raster file
  case 3:
    this->source_type = Data_source::ARCRASTER;
    if (!(lines >> this->file_name)) success = false;
    if (!success) error_msg("Error reading ArcRaster file name.", EA_CONTINUE);
    break;
    // Arc Raster file
  case 4:
    this->source_type = Data_source::XYZ;
    if (!(lines >> this->file_name)) success = false;
    if (!success) error_msg("Error reading xyz file name.", EA_CONTINUE);
    break;
  default:
    success = false;
    break;
  }
  if (success) this->defined = true;
  return(success);
}
