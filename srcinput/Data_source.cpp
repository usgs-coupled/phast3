#include "zone.h"
#include "Data_source.h"
#include "message.h"
#include "Utilities.h"
#include "Point.h"
#include "Shapefiles/Shapefile.h"
#include "ArcRaster.h"
#include "XYZfile.h"
#include "PHST_polygon.h"
#include "NNInterpolator/NNInterpolator.h"
#include "Filedata.h"

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

Data_source::Data_source(void)
{
  this->Init();
  this->filedata = NULL;
  this->tree = NULL;
}
Data_source::~Data_source(void)
{
  if (this->nni != NULL) delete this->nni;
  if (this->tree != NULL) delete this->tree;
  this->pts.clear();
}
Data_source::Data_source(const Data_source& r)
:defined(r.defined)
,file_name(r.file_name)
,source_type(r.source_type)
,filedata(r.filedata)
,pts(r.pts)
,phst_polygons(r.phst_polygons)
,nni(r.nni)
,h_units(r.h_units)
,v_units(r.v_units)
,attribute(r.attribute)
,box(r.box)
{
  // lazy initialization
  this->tree = NULL;
}
Data_source& Data_source::operator=(const Data_source& rhs)
{
  if (this != &rhs)
  {
    this->defined       = rhs.defined;
    this->file_name     = rhs.file_name;
    this->source_type   = rhs.source_type;
    this->filedata      = rhs.filedata;
    this->pts           = rhs.pts;
    this->phst_polygons = rhs.phst_polygons;
    this->tree          = NULL;       // lazy initialization
    this->nni           = rhs.nni;
    this->h_units       = rhs.h_units;
    this->v_units       = rhs.v_units;
    this->attribute     = rhs.attribute;
    this->box           = rhs.box;
  }
  return *this;
}
void Data_source::Init()
{
  this->pts.clear();
  this->file_name.clear();
  this->defined = false;
  this->source_type = Data_source::NONE;
  this->attribute = -1;
  zone_init(&this->box);
  this->nni = NULL;
  this->h_units = cunit("m");
  this->v_units = cunit("m");
}
bool Data_source::Read(std::istream &lines)
{
  bool success = true;
  this->Init();
 
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
      this->pts.push_back(Point(0.0, 0.0, elev, elev));
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
	if (i%3 == 2) {
	  p.set_v(p.z());
	  this->pts.push_back(p);
	}
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
    // XYZ file
  case 3:
    this->source_type = Data_source::XYZ;
    if (!(lines >> this->file_name)) success = false;
    if (!success) error_msg("Error reading xyz file name.", EA_CONTINUE);
    break;
    // Arc Raster file
  case 4:
    this->source_type = Data_source::ARCRASTER;
    if (!(lines >> this->file_name)) success = false;
    if (!success) error_msg("Error reading ArcRaster file name.", EA_CONTINUE);
    break;

  default:
    success = false;
    break;
  }
  if (success) this->defined = true;
  return(success);
}
bool Data_source::Read_units(std::istream &lines)
{
  bool success = true;

  std::string std_token;
  lines >> std_token;
  if (!this->h_units.set_input(std_token.c_str()))
  {
    error_msg("Reading horizontal units for prism top, bottom, or perimeter.", EA_CONTINUE);
    success = false;
  }
  lines >> std_token;
  if (!this->v_units.set_input(std_token.c_str()))
  {
    error_msg("Reading vertical units for prism top, bottom, or perimeter.", EA_CONTINUE);
    success = false;
  }
  return success;
}
void Data_source::Tidy(const bool make_nni)
{

  switch (this->source_type)
  {
  case Data_source::SHAPE:
    if (Filedata::file_data_map.find(this->file_name) == Filedata::file_data_map.end())
    {
      Shapefile *sf = new Shapefile(this->file_name);
      sf->Set_file_type (Filedata::SHAPE);
      Filedata::file_data_map[this->file_name] = (Filedata *) sf;
    }
    {
      Filedata *f =  Filedata::file_data_map.find(this->file_name)->second;
      if (f->Get_file_type() != Filedata::SHAPE) error_msg("File read as non-shape and shape file?", EA_STOP);
      this->Add_to_file_map (f, make_nni);
    }
    
    break;
  case Data_source::ARCRASTER:
    //fprintf(stderr, "Starting to read raster file\n");
    if (Filedata::file_data_map.find(this->file_name) == Filedata::file_data_map.end())
    {
      ArcRaster *ar = new ArcRaster(this->file_name);
      Filedata::file_data_map[this->file_name] = (Filedata *) ar;
      ar->Set_file_type(Filedata::ARCRASTER);
    }
    //fprintf(stderr, "Finished read raster file\n");
    {
      Filedata *f =  Filedata::file_data_map.find(this->file_name)->second;
      if (f->Get_file_type() != Filedata::ARCRASTER) error_msg("File read as non arcraster and arcraster file?", EA_STOP);
      this->Add_to_file_map (f, make_nni);
    }
    //fprintf(stderr, "Build interpolator\n");
    break;
  case Data_source::XYZ:
    if (Filedata::file_data_map.find(this->file_name) == Filedata::file_data_map.end())
    {
      XYZfile *xyz = new XYZfile(this->file_name);
      Filedata::file_data_map[this->file_name] = (Filedata *) xyz;
      xyz->Set_file_type(Filedata::XYZ);
    }
    {
      Filedata *f =  Filedata::file_data_map.find(this->file_name)->second;
      if (f->Get_file_type() != Filedata::XYZ) error_msg("File read as non XYZ and XYZ file?", EA_STOP);
      this->Add_to_file_map (f, make_nni);
    }
    break;
  case Data_source::CONSTANT:
    // convert units
    {
      std::vector<Point>::iterator it;
      for (it = this->pts.begin(); it != this->pts.end(); it++)
      {
	it->set_x(it->x()*this->h_units.input_to_si);
	it->set_y(it->y()*this->h_units.input_to_si);
	it->set_z(it->z()*this->v_units.input_to_si);
	it->set_v(it->get_v()*this->v_units.input_to_si);
      }
    }
    break;
  case Data_source::POINTS:
    // convert units
    {
      std::vector<Point>::iterator it;
      for (it = this->pts.begin(); it != this->pts.end(); it++)
      {
	it->set_x(it->x()*this->h_units.input_to_si);
	it->set_y(it->y()*this->h_units.input_to_si);
	it->set_z(it->z()*this->v_units.input_to_si);
	it->set_v(it->get_v()*this->v_units.input_to_si);
      }
    }
    if (make_nni) Add_nni_to_data_source();
    break;
  case Data_source::NONE:
    break;
  }
  this->Set_bounding_box();
}
std::vector<Point> & Data_source::Get_points()
{
  switch (this->source_type)
  {
  case Data_source::ARCRASTER:
  case Data_source::XYZ:
  case Data_source::SHAPE:
//    {
//      std::map<std::string,Filedata *>::iterator it = Filedata::file_data_map.find(this->file_name);
//      Filedata *f_ptr = it->second;
//      std::vector<Point> pts = f_ptr->Get_points(this->attribute);
//    }
    return (Filedata::file_data_map.find(this->file_name)->second->Get_points(this->attribute));
    break;
  default:
    break;
  }
  /*
  case Data_source::SHAPE:
  case Data_source::CONSTANT:
  case Data_source::POINTS:
  case Data_source::NONE:
  */
  return (this->pts);
}
bool Data_source::Make_polygons()
{
  switch (this->source_type)
  {
  case Data_source::SHAPE:
  case Data_source::XYZ:
    // go to file data and make polygon(s)
    return(Filedata::file_data_map.find(this->file_name)->second->Make_polygons(this->attribute, this->phst_polygons, this->h_units.input_to_si, this->v_units.input_to_si));
    break;

  case Data_source::POINTS:
    if (this->phst_polygons.Get_points().size() == 0)
    {
      this->phst_polygons.Get_points() = this->pts;
      this->phst_polygons.Get_begin().push_back(this->phst_polygons.Get_points().begin());
      this->phst_polygons.Get_end().push_back(this->phst_polygons.Get_points().end());
      this->phst_polygons.Set_bounding_box();
    }
    break;
  default:
  /*
  case Data_source::ARCRASTER:
  case Data_source::CONSTANT:
  case Data_source::NONE:
  */
    return false;
    break;
  }
  return (true);
}

void Data_source::Add_to_file_map (Filedata *f, const bool make_nni)
{
  // Store list of points if necessary
  if (f->Get_pts_map().size() == 0 || (f->Get_pts_map().find(this->attribute) == f->Get_pts_map().end()) )
  {
    std::vector<Point> temp_pts; 
    f->Make_points(this->attribute, temp_pts, this->h_units.input_to_si, this->v_units.input_to_si);

    //std::vector<Point> pts = new std::vector<Point>(temp_pts);
    f->Get_pts_map()[this->attribute] = temp_pts;
  }
  if (make_nni)
  {
    std::vector<Point> corners;
    corners.push_back(Point(grid_zone()->x1, grid_zone()->y1, grid_zone()->z2, grid_zone()->z2));
    corners.push_back(Point(grid_zone()->x2, grid_zone()->y1, grid_zone()->z2, grid_zone()->z2));
    corners.push_back(Point(grid_zone()->x2, grid_zone()->y2, grid_zone()->z2, grid_zone()->z2));
    corners.push_back(Point(grid_zone()->x1, grid_zone()->y2, grid_zone()->z2, grid_zone()->z2));
    // nni does not exist for attribute
    if (f->Get_pts_map().size() == 0 || (f->Get_nni_map().find(this->attribute) == f->Get_nni_map().end()))
    {
      std::vector<Point> temp_pts;
      f->Make_points(this->attribute, temp_pts, this->h_units.input_to_si, this->v_units.input_to_si);

      NNInterpolator *nni = new NNInterpolator();
      nni->preprocess(temp_pts, corners);
      f->Get_nni_map()[this->attribute] = nni;
    }
  } 
#ifdef SKIP 
  else 
  {
    // list of points does not exist for attribute
    if (f->Get_pts_map().size() == 0 || (f->Get_pts_map().find(this->attribute) == f->Get_pts_map().end()) )
    {
      std::vector<Point> temp_pts; 
      f->Make_points(this->attribute, temp_pts, this->h_units.input_to_si, this->v_units.input_to_si);

      //std::vector<Point> pts = new std::vector<Point>(temp_pts);
      f->Get_pts_map()[this->attribute] = temp_pts;
    }
  }
#endif
}
void Data_source::Add_nni_to_data_source (void)
{
  std::vector<Point> corners;
  corners.push_back(Point(grid_zone()->x1, grid_zone()->y1, grid_zone()->z2, grid_zone()->z2));
  corners.push_back(Point(grid_zone()->x2, grid_zone()->y1, grid_zone()->z2, grid_zone()->z2));
  corners.push_back(Point(grid_zone()->x2, grid_zone()->y2, grid_zone()->z2, grid_zone()->z2));
  corners.push_back(Point(grid_zone()->x1, grid_zone()->y2, grid_zone()->z2, grid_zone()->z2));

  // make nni
  this->nni = new NNInterpolator();
  this->nni->preprocess(this->Get_points(), corners);
}
struct zone *Data_source::Get_bounding_box()
{
  return(&this->box);
}
void Data_source::Set_bounding_box(void)
{
  Point min(this->Get_points().begin(), this->Get_points().end(), Point::MIN); 
  Point max(this->Get_points().begin(), this->Get_points().end(), Point::MAX); 
  this->box.x1 = min.x();
  this->box.y1 = min.y();
  this->box.z1 = min.z();
  this->box.x2 = max.x();
  this->box.y2 = max.y();
  this->box.z2 = max.z();
#ifdef SKIP
  Point min(this->pts.begin(), this->pts.end(), Point::MIN); 
  Point max(this->pts.begin(), this->pts.end(), Point::MAX); 
  this->box.x1 = min.x();
  this->box.y1 = min.y();
  this->box.z1 = min.z();
  this->box.x2 = max.x();
  this->box.y2 = max.y();
  this->box.z2 = max.z();
#endif
}
double Data_source::Interpolate(const Point& p)
{
  switch (this->source_type)
  {
  case Data_source::SHAPE:
  case Data_source::ARCRASTER:
  case Data_source::XYZ:
    {
      // go to file data and make polygon(s)
      Filedata *f = Filedata::file_data_map.find(this->file_name)->second;
      NNInterpolator *nni = f->Get_nni_map().find(this->attribute)->second;
      return (nni->interpolate(p));
    }
    break;

  case Data_source::CONSTANT:
    return this->pts.begin()->z();
    break;
  case Data_source::POINTS:
    return (this->nni->interpolate(p));
  default:
    break;
  }
  return(-999.);
}
