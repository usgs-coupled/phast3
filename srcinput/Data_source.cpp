#include <cassert>
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

#define TRUE 1
#define FALSE 0

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

Data_source::Data_source(void)
{
  this->Init();
  this->filedata = NULL;
  this->tree = NULL;
  this->tree3d = NULL;
}
Data_source::~Data_source(void)
{
  // this->nni cleaned up in main Clear_NNInterpolatorList()
  if (this->tree != NULL) delete this->tree;
  delete this->tree3d;
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
,columns(r.columns)
,attribute(r.attribute)
,box(r.box)
{
  // lazy initialization
  this->tree = NULL;
  this->tree3d = NULL;
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
	this->tree3d        = NULL;       // lazy initialization
    this->columns       = rhs.columns;
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
  this->columns = 0;
  this->tree = NULL;
  this->tree3d = NULL;
}
bool Data_source::Read(std::istream &lines, bool read_num)
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
			this->columns = Read_points(lines, this->pts);

			// for prism set v = z
			if (this->columns < 4)
			{
			  std::vector<Point>::iterator it;
			  for (it = this->pts.begin(); it != this->pts.end(); it++)
			  {
			    it->set_v(it->z());
			  }
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
		//if (!(lines >> this->file_name)) success = false;
		//lines >> this->attribute;
		success = Data_source::Read_filename(lines, read_num, this->file_name, this->attribute);
		if (!success) error_msg("Error reading shape file name or attribute number.", EA_CONTINUE);
		break;
		// XYZ file
	case 3:
		this->source_type = Data_source::XYZ;
		//if (!(lines >> this->file_name)) success = false;
		success = Data_source::Read_filename(lines, false, this->file_name, this->attribute);
		if (!success) error_msg("Error reading xyz file name.", EA_CONTINUE);
		break;
		// Arc Raster file
	case 4:
		this->source_type = Data_source::ARCRASTER;
		//if (!(lines >> this->file_name)) success = false;
		success = Data_source::Read_filename(lines, false, this->file_name, this->attribute);
		if (!success) error_msg("Error reading ArcRaster file name.", EA_CONTINUE);
		break;

	default:
		success = false;
		break;
	}
	if (success) this->defined = true;
	return(success);
}
bool Data_source::Read_filename (std::istream &lines, bool read_num, std::string &filename, int &num)
{
  bool success = true;

  std::string line;
  std::getline(lines, line);

  std::string std_token;

  std::string::reverse_iterator rit;
  int erase = 0;
  for (rit = line.rbegin(); rit != line.rend(); rit++)
  {
	  if (isspace(*rit)) {
		  erase++;
		  continue;
	  }
	  break;
  }
  if (rit == line.rend()) 
  {
	  error_msg("Missing file name", EA_CONTINUE);
	  return false;
  }
  line = line.substr(0, line.size() - erase);
  if (read_num)
  {
	  int keep = 0;
	  for (rit = line.rbegin(); rit != line.rend(); rit++)
	  {
		  if (!isspace(*rit)) {
			  keep++;
			  continue;
		  }
		  break;
	  }
	  if (rit == line.rend()) 
	  {
		  error_msg("Missing attribute number", EA_CONTINUE);
		  return false;
	  }
	  std::string number = line.substr(line.size() - keep, line.size());
	  if (sscanf(number.c_str(), "%d", &num) != 1)
	  {
		  error_msg("Expecting attribute number", EA_CONTINUE);
		  return false;
	  }
	  line = line.substr(0, line.size() - keep);
  }

  // strip front and back
  erase = 0;
  for (rit = line.rbegin(); rit != line.rend(); rit++)
  {
	  if (isspace(*rit)) {
		  erase++;
		  continue;
	  }
	  break;
  }
  line = line.substr(0, line.size() - erase);
  erase = 0;
  std::string::iterator it;
  for (it = line.begin(); it != line.end(); it++)
  {
	  if (isspace(*it)) {
		  erase++;
		  continue;
	  }
	  break;
  }
  filename = line.substr(erase, line.size());

  return success;
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
			this->filedata = f;
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
			this->filedata = f;
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
			this->filedata = f;
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
  case Data_source::CONSTANT:
  case Data_source::POINTS:
  case Data_source::NONE:
  */
  return (this->pts);
}
bool Data_source::Make_polygons()
{
  this->phst_polygons.Clear();
  switch (this->source_type)
  {
  case Data_source::SHAPE:
  case Data_source::XYZ:
    // go to file data and make polygon(s)
    return(Filedata::file_data_map.find(this->file_name)->second->Make_polygons(this->attribute, this->phst_polygons, this->h_units.input_to_si, this->v_units.input_to_si));
    break;

  case Data_source::POINTS:
  case Data_source::NONE:
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
// COMMENT: {7/11/2008 9:29:47 PM}    std::vector<Point> corners;
// COMMENT: {7/11/2008 9:29:47 PM}    corners.push_back(Point(grid_zone()->x1, grid_zone()->y1, grid_zone()->z2, grid_zone()->z2));
// COMMENT: {7/11/2008 9:29:47 PM}    corners.push_back(Point(grid_zone()->x2, grid_zone()->y1, grid_zone()->z2, grid_zone()->z2));
// COMMENT: {7/11/2008 9:29:47 PM}    corners.push_back(Point(grid_zone()->x2, grid_zone()->y2, grid_zone()->z2, grid_zone()->z2));
// COMMENT: {7/11/2008 9:29:47 PM}    corners.push_back(Point(grid_zone()->x1, grid_zone()->y2, grid_zone()->z2, grid_zone()->z2));
    // nni does not exist for attribute
    if (f->Get_pts_map().size() == 0 || (f->Get_nni_map().find(this->attribute) == f->Get_nni_map().end()))
    {
      std::vector<Point> temp_pts;
      f->Make_points(this->attribute, temp_pts, this->h_units.input_to_si, this->v_units.input_to_si);

      NNInterpolator *nni = new NNInterpolator();
// COMMENT: {7/11/2008 9:29:56 PM}      nni->preprocess(temp_pts, corners);
      nni->preprocess(temp_pts);
      f->Get_nni_map()[this->attribute] = nni;
      NNInterpolator::NNInterpolatorList.push_back(nni);
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
// COMMENT: {7/11/2008 9:30:20 PM}  std::vector<Point> corners;
// COMMENT: {7/11/2008 9:30:20 PM}  corners.push_back(Point(grid_zone()->x1, grid_zone()->y1, grid_zone()->z2, grid_zone()->z2));
// COMMENT: {7/11/2008 9:30:20 PM}  corners.push_back(Point(grid_zone()->x2, grid_zone()->y1, grid_zone()->z2, grid_zone()->z2));
// COMMENT: {7/11/2008 9:30:20 PM}  corners.push_back(Point(grid_zone()->x2, grid_zone()->y2, grid_zone()->z2, grid_zone()->z2));
// COMMENT: {7/11/2008 9:30:20 PM}  corners.push_back(Point(grid_zone()->x1, grid_zone()->y2, grid_zone()->z2, grid_zone()->z2));

  // make nni
  this->nni = new NNInterpolator();
// COMMENT: {7/11/2008 9:30:13 PM}  this->nni->preprocess(this->Get_points(), corners);
  this->nni->preprocess(this->Get_points());
  NNInterpolator::NNInterpolatorList.push_back(this->nni);
}
struct zone *Data_source::Get_bounding_box()
{
  return(&this->box);
}
void Data_source::Set_bounding_box(void)
{
  Point min(this->Get_points().begin(), this->Get_points().end(), Point::MIN); 
  Point max(this->Get_points().begin(), this->Get_points().end(), Point::MAX); 
  this->box.zone_defined = TRUE;
  this->box.x1 = min.x();
  this->box.y1 = min.y();
  this->box.z1 = min.z();
  this->box.x2 = max.x();
  this->box.y2 = max.y();
  this->box.z2 = max.z();
}
void Data_source::Set_points(std::vector<Point> in_pts)
{
	this->pts.clear();
	std::vector<Point>::iterator it;
	for (it = in_pts.begin(); it != in_pts.end(); it++)
	{
		this->pts.push_back(*it);
	}
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

std::ostream& operator<< (std::ostream &os, const Data_source &ds)
{
  switch (ds.source_type)
  {
  case Data_source::SHAPE:
    os << "SHAPE     " << ds.Get_file_name();
    if (ds.Get_attribute() != -1)
    {
        os << " " << ds.Get_attribute();
    }
    os << std::endl;
    break;
  case Data_source::ARCRASTER:
    os << "ARCRASTER " << ds.Get_file_name() << std::endl;
    break;
  case Data_source::XYZ:
    os << "XYZ       " << ds.Get_file_name() << std::endl;
    break;
  case Data_source::CONSTANT:
    os << "CONSTANT  " << ds.pts.front().z() << std::endl;
    break;
  case Data_source::POINTS:
    os << "POINTS" << std::endl;
    {
      std::vector<Point>::const_iterator citer = ds.pts.begin();
      for (; citer != ds.pts.end(); ++citer)
      {
        os << "\t\t\t" << citer->x() << " " << citer->y() << " " << citer->z() << std::endl;
      }
    }
    break;
  case Data_source::NONE:
    break;
  default:
    break;
  }
  return os;
}
void Data_source::Set_file_name(std::string fn)
{
	// check if in map
	if (this->file_name.size())
	{
		std::map< std::string, Filedata*>::iterator fi = Filedata::file_data_map.find(this->file_name);
		if (fi != Filedata::file_data_map.end())
		{
			// if found update map
			assert(fi->second != NULL);
			assert(this->filedata == fi->second);
			this->filedata = fi->second;
			Filedata::file_data_map.erase(fi);
			Filedata::file_data_map[fn] = this->filedata;
		}
	}
	assert(fn.size());
	this->file_name = fn;
}
