#include "../zone.h"
#include "Shapefile.h"
#include "../KDtree/Point.h"
#include "../message.h"
#include "../Utilities.h"
#include "../PHAST_polygon.h"
#include <iostream>

// Note: No header files should follow the next three lines
#if defined(_WIN32) && defined(_DEBUG)
#define new new(_NORMAL_BLOCK, __FILE__, __LINE__)
#endif

Shapefile::Shapefile(void)
{
}

// Destructor
Shapefile::~Shapefile(void)
{
	int i;
	for (i = 0; i < this->shpinfo->nRecords; i++)
	{
		SHPDestroyObject(this->objects[i]);
	}
	this->objects.clear();

	SHPClose(this->shpinfo);
	DBFClose(this->dbfinfo);
}

Shapefile::Shapefile(std::string & fname,
					 PHAST_Transform::COORDINATE_SYSTEM cs)
{
/* -------------------------------------------------------------------- */
/*      Open the passed shapefile.                                      */
/* -------------------------------------------------------------------- */

	std::string basename(fname);
	std::string::size_type p = basename.find(".shp");
	if (p != std::string::npos && p == (basename.size() - 4))
	{
		basename.erase(p, 4);
	}
	std::string shpname(basename);
	shpname.append(".shp");
	this->shpinfo = SHPOpen(shpname.c_str(), "rb");

	SHPInfo *hSHP = this->shpinfo;

	if (hSHP == NULL)
	{
		//printf( "Unable to open:%s, .shx, or .dbf\n", shpname.c_str() );
		//exit( 1 );
		std::ostringstream estring;
		estring << "Unable to open: " << shpname.c_str() << ", .shx, or .dbf" << std::endl;
		error_msg(estring.str().c_str(), EA_STOP);
	}
	this->filename = shpname;
	this->file_type = Filedata::SHAPE;

/*
Value Shape Type
0 Null Shape
1 Point
3 PolyLine
5 Polygon
8 MultiPoint
11 PointZ
13 PolyLineZ
15 PolygonZ
18 MultiPointZ
21 PointM
23 PolyLineM
25 PolygonM
28 MultiPointM
31 MultiPatch
*/
	if (hSHP->nShapeType > 10)
	{
		//printf( "Shape type %s not implemented\n", SHPTypeName( hSHP->nShapeType ));
		//exit( 1 );
		std::ostringstream estring;
		estring << "Shape type  " << SHPTypeName(hSHP->
												 nShapeType) <<
			" not implemented. " << shpname.c_str() << std::endl;
		error_msg(estring.str().c_str(), EA_STOP);
	}


	// Get info
	int nShapeType, nEntities, i, bValidate = 1, nInvalidCount = 0;
	double adfMinBound[4], adfMaxBound[4];
	SHPGetInfo(hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound);

	// Read records
	for (i = 0; i < nEntities; i++)
	{
		SHPObject *psShape;

		psShape = SHPReadObject(hSHP, i);
		this->objects.push_back(psShape);


		if (bValidate)
		{
			int nAltered = SHPRewindObject(hSHP, psShape);

			if (nAltered > 0)
			{
				printf("  %d rings wound in the wrong direction.\n",
					   nAltered);
				nInvalidCount++;
			}
		}
	}

	// Now read dbf information
	std::string dbfname(basename);
	dbfname.append(".dbf");
	this->dbfinfo = DBFOpen(dbfname.c_str(), "rb");
	DBFInfo *hDBF = this->dbfinfo;

	if (hDBF == NULL)
	{
		//printf( "DBFOpen(%s,\"r\") failed.\n", dbfname.c_str() );
		//exit( 2 );
		std::ostringstream estring;
		estring << "DBFOpen " << dbfname.c_str() << " failed." << std::endl;
		error_msg(estring.str().c_str(), EA_STOP);
	}


	//this->Dump(std::cerr);
	//exit(4);
	this->coordinate_system = cs;

	/* -------------------------------------------------------------------- */
	/*    If there is no data in this file let the user know.     */
	/* -------------------------------------------------------------------- */
	if (DBFGetFieldCount(hDBF) == 0)
	{
		printf("There are no fields in this table!\n");
		exit(3);
	}
	//this->Set_bounding_box();
}
void
Shapefile::Dump(std::ostream & oss)
{

	SHPInfo *hSHP = this->shpinfo;

	if (hSHP == NULL)
	{
		oss << "No header data for Shapefile object\n";
		return;
	}

	// get info
	int nShapeType, nEntities, i, iPart;	//, bValidate = 0,nInvalidCount=0;
	const char *pszPlus;
	double adfMinBound[4], adfMaxBound[4];

	SHPGetInfo(hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound);

	char str[200];
	sprintf(str, "Shapefile Type: %s   # of Shapes: %d\n\n",
			  SHPTypeName(nShapeType), nEntities);
	oss << str;

	sprintf(str, "File Bounds: (%12.3f,%12.3f,%g,%g)\n"
			  "         to  (%12.3f,%12.3f,%g,%g)\n",
			  adfMinBound[0],
			  adfMinBound[1],
			  adfMinBound[2],
			  adfMinBound[3],
			  adfMaxBound[0], adfMaxBound[1], adfMaxBound[2], adfMaxBound[3]);
	oss << str;

	int vertex = 0;
	for (i = 0; i < nEntities; i++)
	{
		int j;
		SHPObject *psShape;

		psShape = this->objects[i];

		sprintf(str, "\nShape:%d (%s)  nVertices=%d, nParts=%d\n"
				  "  Bounds:(%12.3f,%12.3f, %g, %g)\n"
				  "      to (%12.3f,%12.3f, %g, %g)\n",
				  i, SHPTypeName(psShape->nSHPType),
				  psShape->nVertices, psShape->nParts,
				  psShape->dfXMin, psShape->dfYMin,
				  psShape->dfZMin, psShape->dfMMin,
				  psShape->dfXMax, psShape->dfYMax,
				  psShape->dfZMax, psShape->dfMMax);
		oss << str;


		for (j = 0, iPart = 1; j < psShape->nVertices; j++)
		{
			vertex++;
			const char *pszPartType = "";

			if (j == 0 && psShape->nParts > 0)
				pszPartType = SHPPartTypeName(psShape->panPartType[0]);

			if (iPart < psShape->nParts && psShape->panPartStart[iPart] == j)
			{
				pszPartType = SHPPartTypeName(psShape->panPartType[iPart]);
				iPart++;
				pszPlus = "+";
			}
			else
				pszPlus = " ";

			char str[200];
			sprintf(str, "   %s (%12.3f,%12.3f, %g, %g) %d %s \n",
					  pszPlus,
					  psShape->padfX[j],
					  psShape->padfY[j],
					  psShape->padfZ[j], psShape->padfM[j], vertex, pszPartType);
			oss << str;
		}
	}

	// Dump dbf
	sprintf(str, "\nDBF Header\n\n");
	oss << str;

	DBFInfo *hDBF = this->dbfinfo;

	bool bHeader = true;		// flag to print header
	char szTitle[12];
	int nWidth, nDecimals;

	if (bHeader)
	{
		for (i = 0; i < DBFGetFieldCount(hDBF); i++)
		{
			DBFFieldType eType;
			const char *pszTypeName;


			eType = DBFGetFieldInfo(hDBF, i, szTitle, &nWidth, &nDecimals);
			if (eType == FTString)
				pszTypeName = "String";
			else if (eType == FTInteger)
				pszTypeName = "Integer";
			else if (eType == FTDouble)
				pszTypeName = "Double";
			else if (eType == FTInvalid)
				pszTypeName = "Invalid";

			sprintf(str,
					  "Field %d: Type=%s, Title=`%s', Width=%d, Decimals=%d\n",
					  i, pszTypeName, szTitle, nWidth, nDecimals);
			oss << str;
		}
	}

	// More print flags
	bool bMultiLine = false;
	bool bRaw = false;
	int *panWidth;
	int iRecord;
	char szFormat[32];

	/* -------------------------------------------------------------------- */
	/*  Compute offsets to use when printing each of the field      */
	/*  values. We make each field as wide as the field title+1, or     */
	/*  the field value + 1.                        */
	/* -------------------------------------------------------------------- */
	panWidth = (int *) malloc(DBFGetFieldCount(hDBF) * sizeof(int));

	for (i = 0; i < DBFGetFieldCount(hDBF) && !bMultiLine; i++)
	{
		DBFFieldType eType;

		eType = DBFGetFieldInfo(hDBF, i, szTitle, &nWidth, &nDecimals);
		if (strlen(szTitle) > (unsigned int) nWidth)
			panWidth[i] = (int) strlen(szTitle);
		else
			panWidth[i] = nWidth;

		if (eType == FTString)
			sprintf(szFormat, "%%-%ds ", panWidth[i]);
		else
			sprintf(szFormat, "%%%ds ", panWidth[i]);
		sprintf(str, szFormat, szTitle);
		oss << str;

	}
	//printf( "\n" );
	oss << std::endl;

	/* -------------------------------------------------------------------- */
	/*  Read all the records                        */
	/* -------------------------------------------------------------------- */
	for (iRecord = 0; iRecord < DBFGetRecordCount(hDBF); iRecord++)
	{
		if (bMultiLine)
		{
			sprintf(str, "Record: %d\n", iRecord);
			oss << str;
		}

		for (i = 0; i < DBFGetFieldCount(hDBF); i++)
		{
			DBFFieldType eType;

			eType = DBFGetFieldInfo(hDBF, i, szTitle, &nWidth, &nDecimals);

			if (bMultiLine)
			{
				sprintf(str, "%s: ", szTitle);
				oss << str;
			}

			/* -------------------------------------------------------------------- */
			/*      Print the record according to the type and formatting           */
			/*      information implicit in the DBF field description.              */
			/* -------------------------------------------------------------------- */
			if (!bRaw)
			{
				if (DBFIsAttributeNULL(hDBF, iRecord, i))
				{
					if (eType == FTString)
						sprintf(szFormat, "%%-%ds", nWidth);
					else
						sprintf(szFormat, "%%%ds", nWidth);

					sprintf(str, szFormat, "(NULL)");
					oss << str;
				}
				else
				{
					switch (eType)
					{
					case FTString:
						sprintf(szFormat, "%%-%ds", nWidth);
						sprintf(str, szFormat,
								  DBFReadStringAttribute(hDBF, iRecord, i));
						oss << str;
						break;

					case FTInteger:
						sprintf(szFormat, "%%%dd", nWidth);
						sprintf(str, szFormat,
								  DBFReadIntegerAttribute(hDBF, iRecord, i));
						oss << str;
						break;

					case FTDouble:
						sprintf(szFormat, "%%%d.%dlf", nWidth, nDecimals);
						sprintf(str, szFormat,
								  DBFReadDoubleAttribute(hDBF, iRecord, i));
						oss << str;
						break;

					default:
						break;
					}
				}
			}

			/* -------------------------------------------------------------------- */
			/*      Just dump in raw form (as formatted in the file).               */
			/* -------------------------------------------------------------------- */
			else
			{
				sprintf(szFormat, "%%-%ds", nWidth);
				sprintf(str, szFormat,
						  DBFReadStringAttribute(hDBF, iRecord, i));
				oss << str;
			}

			/* -------------------------------------------------------------------- */
			/*      Write out any extra spaces required to pad out the field        */
			/*      width.                                                          */
			/* -------------------------------------------------------------------- */
			if (!bMultiLine)
			{
				sprintf(szFormat, "%%%ds", panWidth[i] - nWidth + 1);
				sprintf(str, szFormat, "");
				oss << str;
			}

			if (bMultiLine)
			{
				//printf( "\n" );
				oss << std::endl;
			}

			//fflush( stdout );
		}
		//printf( "\n" );
		oss << std::endl;
	}
}
#ifdef SKIP
bool Shapefile::Make_points(const int attribute, std::vector < Point > &pts)
{
	// Point contains a x, y, z + value

	//if (this->pts.size() > 0 && field == this->current_field) return (true);
	//this->pts.clear();

	std::vector < double >
		m;						// rough-in in case M values are given in .shp file

	SHPInfo *
		hSHP = this->shpinfo;
	DBFInfo *
		hDBF = this->dbfinfo;


	// get info
	int
		nShapeType,
		nEntities,
		i;						//, bValidate = 0,nInvalidCount=0;
	double
		adfMinBound[4],
		adfMaxBound[4];

	SHPGetInfo(hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound);

	// Check field number
	int
		dbf_fields = DBFGetFieldCount(hDBF);
	int
		dbf_records = DBFGetRecordCount(hDBF);

	//this->Dump(std::cerr);
	if (attribute >= dbf_fields)
	{
		std::ostringstream estring;
		estring << "Requested field number, " << attribute
			<<
			" (starting from zero), is greater than maximum field number in dbf file "
			<< dbf_fields - 1 << " " << this->filename << std::endl;
		error_msg(estring.str().c_str(), EA_STOP);
	}

	char
		szTitle[12];
	int
		nWidth,
		nDecimals;
	DBFFieldType
		eType;

	if (attribute >= 0 && attribute < dbf_fields)
	{
		eType =
			DBFGetFieldInfo(hDBF, attribute, szTitle, &nWidth, &nDecimals);
		if (eType != FTDouble && eType != FTInteger)
		{
			std::ostringstream estring;
			estring << "Requested field number, " << attribute
				<< " is not a real or integer number in dbf file"
				<< " " << this->filename
				<< std::endl;
			error_msg(estring.str().c_str(), EA_STOP);
		}
		else
		{
			std::ostringstream ostring;
			ostring << "Extracting field " << attribute << " "
				<< szTitle << " " << this->filename << std::endl;
			output_msg(OUTPUT_SCREEN, "%s\n", ostring.str().c_str());
		}
	}

	double
		xlast = -99, ylast = -99, zlast = -99;
	int vertex_number = 0;
	for (i = 0; i < nEntities; i++)
	{
		int
			j;
		SHPObject *
			psShape;

		psShape = this->objects[i];

		// get corresponding value from dbf
		if (i >= dbf_records)
		{
			std::ostringstream estring;
			estring << "Requested record number, " << j
				<<
				" (starting from zero), is greater than number of records in dbf file "
				<< dbf_records << std::endl;
			error_msg(estring.str().c_str(), EA_STOP);
		}


		// Apply value to all vertices
		for (j = 0; j < psShape->nVertices; j++)
		{
			vertex_number++;
			if ( ( i != 0 || j != 0) &&
				psShape->padfX[j] == xlast &&
				psShape->padfY[j] == ylast && psShape->padfZ[j] == zlast)
			{
				psShape->padfX[j] += 1e-12*psShape->padfX[j];
				psShape->padfY[j] += 1e-12*psShape->padfY[j];
			}
			if ( ( i == 0 && j == 0) ||
				psShape->padfX[j] != xlast ||
				psShape->padfY[j] != ylast || psShape->padfZ[j] != zlast)
			{
				double
					value = psShape->padfZ[j];
				if (attribute >= 0)
					value = DBFReadDoubleAttribute(hDBF, i, attribute);
				// add to list
				Point
					pt;
				pt.set_x(psShape->padfX[j]);
				pt.set_y(psShape->padfY[j]);
				//pt.set_z(psShape->padfZ[j]);
				pt.set_z(value);
				pt.set_v(value);
				//this->pts.push_back(pt);
				pts.push_back(pt);

				// Place holder for implementing m shape files
				m.push_back(psShape->padfM[j]);

				// save last point
				xlast = psShape->padfX[j];
				ylast = psShape->padfY[j];
				zlast = psShape->padfZ[j];
			}
			else
			{
								//fprintf(stderr, "Skipped vertex\n");
			}
		}
	}
	return true;
}
#endif
bool Shapefile::Make_points(const int attribute, std::vector < Point > &pts)
{
	// Point contains a x, y, z + value

	std::vector < double >
		m;						// rough-in in case M values are given in .shp file

	SHPInfo *
		hSHP = this->shpinfo;
	DBFInfo *
		hDBF = this->dbfinfo;


	// get info
	int
		nShapeType,
		nEntities,
		i;						//, bValidate = 0,nInvalidCount=0;
	double
		adfMinBound[4],
		adfMaxBound[4];

	SHPGetInfo(hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound);

	// Check field number
	int
		dbf_fields = DBFGetFieldCount(hDBF);
	int
		dbf_records = DBFGetRecordCount(hDBF);

	//this->Dump(std::cerr);
	if (attribute >= dbf_fields)
	{
		std::ostringstream estring;
		estring << "Requested field number, " << attribute
			<<
			" (starting from zero), is greater than maximum field number in dbf file "
			<< dbf_fields - 1 << " " << this->filename << std::endl;
		error_msg(estring.str().c_str(), EA_STOP);
	}

	char
		szTitle[12];
	int
		nWidth,
		nDecimals;
	DBFFieldType
		eType;

	if (attribute >= 0 && attribute < dbf_fields)
	{
		eType =
			DBFGetFieldInfo(hDBF, attribute, szTitle, &nWidth, &nDecimals);
		if (eType != FTDouble && eType != FTInteger)
		{
			std::ostringstream estring;
			estring << "Requested field number, " << attribute
				<< " is not a real or integer number in dbf file"
				<< " " << this->filename
				<< std::endl;
			error_msg(estring.str().c_str(), EA_STOP);
		}
		else
		{
			std::ostringstream ostring;
			ostring << "Extracting field " << attribute << " "
				<< szTitle << " " << this->filename << std::endl;
			output_msg(OUTPUT_SCREEN, "%s\n", ostring.str().c_str());
		}
	}

	int vertex_number = 0;
	for (i = 0; i < nEntities; i++)
	{
		int
			j;
		SHPObject *
			psShape;

		psShape = this->objects[i];

		// get corresponding value from dbf
		if (i >= dbf_records)
		{
			std::ostringstream estring;
			estring << "Requested record number, " << j
				<< " (starting from zero), is greater than number of records in dbf file "
				<< dbf_records << std::endl;
			error_msg(estring.str().c_str(), EA_STOP);
		}


		// Apply value to all vertices
		for (j = 0; j < psShape->nVertices; j++)
		{
			vertex_number++;

			double value = psShape->padfZ[j];
			if (attribute >= 0)
				value = DBFReadDoubleAttribute(hDBF, i, attribute);
			// add to list
			Point pt;
			pt.set_x(psShape->padfX[j]);
			pt.set_y(psShape->padfY[j]);
			pt.set_z(value);
			pt.set_v(value);

			pts.push_back(pt);

			// Place holder for implementing m shape files
			m.push_back(psShape->padfM[j]);
		}
	}
	return true;
}
#ifdef SKIP
bool Shapefile::Make_polygons(int field, PHAST_polygon & polygons)
{
	// Requires field number
	// Requires point vector
	// Requires 2 vectors of iterators for input

	// Point contains  x, y, z + value

	// Set points
	//this->Make_points(field, polygons.Get_points());
	Data_source *
		ds = this->Get_data_source(field);
	assert(ds->Get_source_type() == Data_source::POINTS);
	assert(ds->Get_points().size() > 3);
	polygons.Get_points() = ds->Get_points();



	std::vector < double >
		m;						// rough-in in case M values are given in .shp file

	SHPInfo *
		hSHP = this->shpinfo;
	//DBFInfo *hDBF = this->dbfinfo;


	// get info
	int
		nShapeType,
		nEntities,
		i;						//, bValidate = 0,nInvalidCount=0;
	double
		adfMinBound[4],
		adfMaxBound[4];

	SHPGetInfo(hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound);

	// Shape type should be polygon
	if (nShapeType != 5)
	{
		std::ostringstream estring;
		estring << "Shape file does not have shape type of polygon." << std::
			endl;
		//error_msg(estring.str().c_str(), EA_STOP);
		warning_msg(estring.str().c_str());
	}
	std::vector < Point >::iterator it = polygons.Get_points().begin();
	for (i = 0; i < nEntities; i++)
	{
		polygons.Get_begin().push_back(it);

		SHPObject *
			psShape;
		psShape = this->objects[i];

		int
			j;
		for (j = 0; j < psShape->nVertices; j++)
		{
			it++;
		}
		polygons.Get_end().push_back(it);
	}
	polygons.Set_coordinate_system(this->coordinate_system);
	polygons.Set_bounding_box();
	return true;
}
#endif
bool Shapefile::Make_polygons(int field, PHAST_polygon & polygons)
{
	// Requires field number
	// Requires point vector
	// Requires 2 vectors of iterators for input

	// Point contains  x, y, z + value

	// Set points
	//this->Make_points(field, polygons.Get_points());
	Data_source *
		ds = this->Get_data_source(field);
	assert(ds->Get_source_type() == Data_source::POINTS);
	assert(ds->Get_points().size() > 3);
	polygons.Get_points() = ds->Get_points();
	bool dumped = false;

	std::vector < double >
		m;						// rough-in in case M values are given in .shp file

	SHPInfo *
		hSHP = this->shpinfo;
	//DBFInfo *hDBF = this->dbfinfo;


	// get info
	int
		nShapeType,
		nEntities,
		i;						//, bValidate = 0,nInvalidCount=0;
	double
		adfMinBound[4],
		adfMaxBound[4];

	SHPGetInfo(hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound);

	// Shape type should be polygon
	if (nShapeType != 5)
	{
		std::ostringstream estring;
		estring << "Shape file does not have shape type of polygon." << " " << this->filename << std::
			endl;
		//error_msg(estring.str().c_str(), EA_STOP);
		warning_msg(estring.str().c_str());
	}
	else
	{
		// check for holes in polygon shape file
		for (i = 0; i < nEntities; i++)
		{
			SHPObject *	psShape;
			psShape = this->objects[i];
			int iPart;
			for (iPart = 0; iPart < psShape->nParts; ++iPart)
			{
				size_t ii;
				size_t jj;
				size_t nn = psShape->nVertices;;
				double area = 0.0;
				if (iPart + 1 < psShape->nParts) nn = psShape->panPartStart[iPart + 1];
				for (ii = psShape->panPartStart[iPart]; ii < nn; ++ii)
				{
					jj = ii + 1;
					if (jj == nn) jj = psShape->panPartStart[iPart];
					area += psShape->padfX[ii]*psShape->padfY[jj];
					area -= psShape->padfY[ii]*psShape->padfX[jj];

				}
				if (area > 0.0)
				{
					std::ostringstream estring;
					estring << "Ignoring holes in polygon shape file. " << this->filename << std::endl;
					warning_msg(estring.str().c_str());
					if (!dumped)
					{
						//this->Dump(std::cerr);
						dumped = true;
					}
					break;
				}
			}
		}
	}
	std::vector < Point >::iterator it = polygons.Get_points().begin();
	int vertex_number = 0;
	for (i = 0; i < nEntities; i++)
	{
		polygons.Get_begin().push_back(it);

		SHPObject *	psShape;
		psShape = this->objects[i];

		int	j;

		// Add multiple rings
		int iPart;

		//for (j = 0, iPart = 1; j < psShape->nVertices; j++)
		//{
		//	//vertex++;
		//	it++;
		//	const char *pszPartType = "";

		//	if (iPart < psShape->nParts && psShape->panPartStart[iPart] == j)
		//	{
		//		polygons.Get_end().push_back(it);
		//	}
		//}

		for (iPart = 0; iPart < psShape->nParts; iPart++)
		{
			int end = psShape->nVertices;
			if (iPart + 1 < psShape->nParts) end = psShape->panPartStart[iPart + 1];
			for (j = psShape->panPartStart[iPart]; j < end; j++)
			{
				it++;
				vertex_number++;
			}
			polygons.Get_end().push_back(it);
			//fprintf(stderr, "End Shape %d, Part %d, Within Part %d, Vertex %d\n", i, iPart, j, vertex_number);
			if (iPart + 1 < psShape->nParts)
			{
				polygons.Get_begin().push_back(it);
			}
		}

	}
	//std::vector < Point >::iterator jit;
	//size_t j, count(0);
	//for (j = 0; j < polygons.Get_begin().size(); j++)
	//{
	//	for (jit = polygons.Get_begin()[j]; jit != polygons.Get_end()[j]; jit++)
	//	{
	//		count++;
	//	}
	//}
	polygons.Tidy();
	polygons.Set_coordinate_system(this->coordinate_system);
	polygons.Set_bounding_box();
	return true;
}
		//int iPart;
		//const char *pszPlus;
		//// account for multiple rings in a polygon
		//for (j = 0, iPart = 1; j < psShape->nVertices; j++)
		//{
		//	const char *pszPartType = "";

		//	if (j == 0 && psShape->nParts > 0)
		//		pszPartType = SHPPartTypeName(psShape->panPartType[0]);

		//	if (iPart < psShape->nParts && psShape->panPartStart[iPart] == j)
		//	{
		//		pszPartType = SHPPartTypeName(psShape->panPartType[iPart]);
		//		iPart++;
		//		pszPlus = "+";
		//	}
		//	else
		//		pszPlus = " ";

		//	//char str[200];
		//	//sprintf(str, "   %s (%12.3f,%12.3f, %g, %g) %s \n",
		//	//		  pszPlus,
		//	//		  psShape->padfX[j],
		//	//		  psShape->padfY[j],
		//	//		  psShape->padfZ[j], psShape->padfM[j], pszPartType);
		//	//oss << str;
		//}
std::vector < std::string > Shapefile::Get_headers(void)
{
	std::vector < std::string > headers;
	if (this->dbfinfo)
	{
		char
			szTitle[12];
		for (int i = 0; i < DBFGetFieldCount(this->dbfinfo); ++i)
		{
			//const char *pszTypeName;
			DBFGetFieldInfo(this->dbfinfo, i, szTitle, NULL, NULL);
			headers.push_back(szTitle);
		}
	}
	return headers;
}
