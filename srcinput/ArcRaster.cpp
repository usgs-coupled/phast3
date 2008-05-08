#include "ArcRaster.h"
#include "message.h"
#include <iostream>
#include <istream>
#include <fstream>
#include "Point.h"
ArcRaster::ArcRaster(void)
{
}
ArcRaster::ArcRaster(std::string filename)
{
  std::string token;
  std::ifstream input (filename.c_str());
  bool error = false;
  if (!input.is_open())
  {
    error = true;
    std::ostringstream estring;
    estring << "Could not open file " << filename.c_str() << std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
  }

  // ncols
  input >> token;
  if (strcmp(token.c_str(), "ncols") != 0)  error = true;
  input >> this->ncols;

  // nrows
  input >> token;
  if (strcmp(token.c_str(), "nrows") != 0) error = true;
  input >> this->nrows;

  // xllcorner
  input >> token;
  if (strcmp(token.c_str(), "xllcorner") != 0) error = true;
  input >> this->xllcorner;

  // yllcorner
  input >> token;
  if (strcmp(token.c_str(), "yllcorner") != 0) error = true;
  input >> this->yllcorner;

  // cellsize
  input >> token;
  if (strcmp(token.c_str(), "cellsize") != 0) error = true;
  input >> this->cellsize;

  // NODATA_value
  input >> token;
  if (strcmp(token.c_str(), "NODATA_value") != 0) error = true;
  input >> this->nodata_value;

  if (error)
  {
    std::ostringstream estring;
    estring << "Does not appear to be an Arc raster file, " << filename.c_str() << std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
  }

  double value, xpos, ypos;
  int i, j;
  for (i = 0; i < nrows; i++)
  {
    ypos = this->yllcorner + (double (this->nrows - i) + 0.5) * this->cellsize;
    //char line[10000];
    //input.getline(line, 10000);
    //std::istringstream iss(line);

    for (j = 0; j  < this->ncols; j++)
    {    
      input >> value;
      xpos = this->xllcorner + (double (j) + 0.5) * this->cellsize;
      if (value != this->nodata_value)
      {
	this->pts.push_back(Point(xpos, ypos, 0.0, value)); 
      }
    }
  }
}

ArcRaster::~ArcRaster(void)
{
}
