#include "XYZTfile.h"
#include "message.h"

//#include <strstream>
#include "Point.h"
#include "PHAST_polygon.h"

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

XYZTfile::XYZTfile(void)
{
	this->file_stream = NULL;
	this->current_set = -1;
}

XYZTfile::XYZTfile(std::string filename, PHAST_Transform::COORDINATE_SYSTEM cs)
{
	this->file_stream = NULL;
	this->filename = filename;
	this->file_type = Filedata::XYZT;
	this->coordinate_system = cs;

	if (!this->Open())
	{
		std::ostringstream estring;
		estring << "Could not open file " << filename.c_str() << std::endl;
		error_msg(estring.str().c_str(), EA_STOP);
	}



	// Make vector of times and number of lines
	std::string line;
	double x, y, z, t, v, tlast = -9999999.;


	// start 
	{
		std::getline(*this->file_stream, line);
		std::stringstream stream(line);
		if(stream >> x && stream >> y && stream >> z && stream >> t && stream >> v)
		{
			this->times_vector.push_back(t);
			tlast = t;
		}
	}

	// continue
	int lines = 1;
	while (std::getline(*this->file_stream, line))
	{
		std::stringstream stream(line);
		if (stream >> x && stream >> y && stream >> z && stream >> t && stream >> v)
		{
			if (t > tlast)
			{
				this->count_lines.push_back(lines);
				this->times_vector.push_back(t);
				tlast = t;
				lines = 0; 
			}
		}
		else
		{
			std::ostringstream estring;
			estring << "Data ignored, expected x, y, z, t, v " << filename.c_str() << std::endl;
			warning_msg(estring.str().c_str());
		}
		lines++;
	
	}
	this->count_lines.push_back(lines);
	if (times_vector.size() == 0)
	{
		std::ostringstream estring;
		estring << "No data in file " << filename.c_str() << std::endl;
		error_msg(estring.str().c_str(), EA_STOP);
	}
	// read first data set
	this->Close();
	this->Open();
	this->current_set = -1;
	//this->read_set();

	//this->close();
}

XYZTfile::~XYZTfile(void)
{
	delete this->file_stream;
}
bool XYZTfile::Open(void)
{
	if (this->file_stream != NULL) 
	{
		delete this->file_stream;
	}
	this->file_stream = new std::ifstream(this->filename.c_str());
	//this->file_stream->open(this->filename.c_str(),std::ios_base::in);
	//this->file_stream.seekg(0, std::ios_base::beg);

	if (!this->file_stream->is_open())
	{
		std::ostringstream estring;
		estring << "Could not open file " << filename.c_str() << std::endl;
		return false;
	}
	this->current_set = -1;
	return true;
}
bool XYZTfile::Close(void)
{
	if (this->file_stream != NULL)
	{
		this->file_stream->close();
		delete this->file_stream;
		this->file_stream = NULL;
	}
	this->current_set = -1;
	return true;
}
bool XYZTfile::Read(double time)
{
	// find set number
	int i;
	i = this->current_set;

	// check if already at the correct time plane
	double fudge = (1.0 + 1e-6);
	bool current = false;
	if (i >= 0 && i < (int) this->times_vector.size())
	{
		if (fudge*time >= this->times_vector[i])
		{
			if (i == ((int) this->times_vector.size() - 1) )
			{
				current = true;
			} 
			else if (i < ((int) this->times_vector.size() - 1) && time*fudge < this->times_vector[i + 1])
			{
				current = true;
			}
		}
	}
	if (current) return true;

	for (i = 0; i < (int) (this->times_vector.size() - 1); i++)
	{
		if (time*fudge >= this->times_vector[i] && time*fudge < this->times_vector[i + 1] ) break;
	}
	int target_set = i;
	int number_of_sets_to_read;

	if (this->current_set == target_set) return true;
	if (this->current_set < target_set)
	{
		number_of_sets_to_read = target_set - current_set - 1;
	}
	else
	{
		this->Close();
		this->Open();
		number_of_sets_to_read = target_set;
	}
	for (i = 0; i <= number_of_sets_to_read; i++)
	{
		this->Read_set();
	}

	// convert coordinate system
	this->Get_data_source(-1)->Convert_coordinates(target_coordinate_system, map_to_grid);
	return true;

}
bool XYZTfile::Read_set(void)
{
	if (this->current_set + 1 == (int) this->times_vector.size()) return false;
	this->current_set++;
	
	size_t i;

	std::string line;
	double x, y, z, t, v;
	std::vector<Point> pts; 

	for (i = 0; i < this->count_lines[this->current_set]; i++)
	{
		std::getline(*this->file_stream, line);
		std::stringstream stream(line);
		if (stream >> x && stream >> y && stream >> z && stream >> t && stream >> v)
		{
			Point p(x, y, z, v);
			pts.push_back(p);
		}
		else
		{
			std::ostringstream estring;
			estring << "Data ignored, expected x, y, z, t, v " << filename.c_str() << std::endl;
			warning_msg(estring.str().c_str());
		}
	}
	//this->Add_data_source(-1, pts, 4, this->coordinate_system);

	int columns = 4;
	int attribute = -1;
	Data_source *ds = new Data_source(pts, this->coordinate_system);
	ds->Set_columns(columns);

	// remove old Data_source
	Data_source *ds1 = this->Get_data_source(-1);
	delete ds1;

	ds->Set_attribute(attribute);
	this->data_source_map[attribute] = ds;

	return true;
}
