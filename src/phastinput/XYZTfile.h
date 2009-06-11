#if !defined(XYZTFILE_H_INCLUDED)
#define XYZTFILE_H_INCLUDED
#include "Filedata.h"
#include <string>
#include <vector>
#include <iostream>
#include <istream>
#include <fstream>
class Point;
class XYZTfile:public Filedata
{
  public:
	XYZTfile(void);
	XYZTfile(std::string filename, PHAST_Transform::COORDINATE_SYSTEM cs);
	bool Make_polygons(int field, PHAST_polygon & polygons)
	{
		return false;
	}

	bool Open(void);
	bool Close(void);
	bool Read(double time);
	bool Read_set(void);

	std::vector<double> & Get_times_vector(void)
	{
		return times_vector;
	};
	std::vector<size_t> & Get_count_lines(void)
	{
		return count_lines;
	};
  public:
	virtual ~ XYZTfile(void);

  protected:
	// data
	std::vector<double> times_vector;
	std::vector<size_t> count_lines;
	int current_set;
	std::ifstream *file_stream;
};
#endif // !defined(XYZTFILE_H_INCLUDED)
