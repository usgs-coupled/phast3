#include "Shapefile.h"
#include "../Point.h"
#include "../message.h"
extern int free_check_null(void *);
Shapefile::Shapefile(void)
{
}
// Destructor
Shapefile::~Shapefile(void)
{
  int i;
  for (i = 0; i < this->shpinfo->nRecords; i++)
  {
    SHPDestroyObject( this->objects[i] );
  }
  this->objects.clear();

  SHPClose(this->shpinfo);
  DBFClose(this->dbfinfo);
}
Shapefile::Shapefile(std::string &fname)
{
/* -------------------------------------------------------------------- */
/*      Open the passed shapefile.                                      */
/* -------------------------------------------------------------------- */

  std::string shpname(fname);
  shpname.append(".shp");
  this->shpinfo = SHPOpen( shpname.c_str(), "rb" );

  SHPInfo *hSHP = this->shpinfo;

  if( hSHP == NULL )
  {
    printf( "Unable to open:%s\n", shpname.c_str() );
    exit( 1 );
  }

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
    if( hSHP->nShapeType >  10)
  {
    printf( "Shape type %s not implemented\n", SHPTypeName( hSHP->nShapeType ));
    exit( 1 );
  }


  // Get info
  int		nShapeType, nEntities, i, bValidate = 0,nInvalidCount=0;
  double 	adfMinBound[4], adfMaxBound[4];
  SHPGetInfo( hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound );

  // Read records
  for( i = 0; i < nEntities; i++ )
  {
    SHPObject	*psShape;

    psShape = SHPReadObject( hSHP, i );
    this->objects.push_back(psShape);


    if( bValidate )
    {
      int nAltered = SHPRewindObject( hSHP, psShape );

      if( nAltered > 0 )
      {
	printf( "  %d rings wound in the wrong direction.\n",
	  nAltered );
	nInvalidCount++;
      }
    }
  }

  // Now read dbf information
  std::string dbfname(fname);
  dbfname.append(".dbf");
  this->dbfinfo = DBFOpen( dbfname.c_str(), "rb" );
  DBFInfo *hDBF = this->dbfinfo;

  if( hDBF == NULL )
  {
    printf( "DBFOpen(%s,\"r\") failed.\n", dbfname.c_str() );
    exit( 2 );
  }


  /* -------------------------------------------------------------------- */
  /*	If there is no data in this file let the user know.		*/
  /* -------------------------------------------------------------------- */
  if( DBFGetFieldCount(hDBF) == 0 )
  {
    printf( "There are no fields in this table!\n" );
    exit( 3 );
  }



        //SHPClose( hSHP );
}
void Shapefile::Dump(std::ostream &oss)
{

    SHPInfo *hSHP = this->shpinfo;

    if( hSHP == NULL )
    {
	oss << "No header data for Shapefile object\n";
	return;
    }

    // get info
    int		nShapeType, nEntities, i, iPart, bValidate = 0,nInvalidCount=0;
    const char 	*pszPlus;
    double 	adfMinBound[4], adfMaxBound[4];

    SHPGetInfo( hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound );

    char str[200];
    sprintf_s(str, "Shapefile Type: %s   # of Shapes: %d\n\n",
            SHPTypeName( nShapeType ), nEntities );
    oss << str;
    
    sprintf_s(str, "File Bounds: (%12.3f,%12.3f,%g,%g)\n"
            "         to  (%12.3f,%12.3f,%g,%g)\n",
            adfMinBound[0], 
            adfMinBound[1], 
            adfMinBound[2], 
            adfMinBound[3], 
            adfMaxBound[0], 
            adfMaxBound[1], 
            adfMaxBound[2], 
            adfMaxBound[3] );
    oss << str;

    for( i = 0; i < nEntities; i++ )
    {
	int		j;
        SHPObject	*psShape;

	psShape = this->objects[i];

	sprintf_s(str, "\nShape:%d (%s)  nVertices=%d, nParts=%d\n"
	  "  Bounds:(%12.3f,%12.3f, %g, %g)\n"
	  "      to (%12.3f,%12.3f, %g, %g)\n",
		  i, SHPTypeName(psShape->nSHPType),
	  psShape->nVertices, psShape->nParts,
	  psShape->dfXMin, psShape->dfYMin,
	  psShape->dfZMin, psShape->dfMMin,
	  psShape->dfXMax, psShape->dfYMax,
	  psShape->dfZMax, psShape->dfMMax );
	oss << str;


	for( j = 0, iPart = 1; j < psShape->nVertices; j++ )
	{
            const char	*pszPartType = "";

            if( j == 0 && psShape->nParts > 0 )
                pszPartType = SHPPartTypeName( psShape->panPartType[0] );
            
	    if( iPart < psShape->nParts
                && psShape->panPartStart[iPart] == j )
	    {
                pszPartType = SHPPartTypeName( psShape->panPartType[iPart] );
		iPart++;
		pszPlus = "+";
	    }
	    else
	        pszPlus = " ";

	    char str[200];
	    sprintf_s(str, "   %s (%12.3f,%12.3f, %g, %g) %s \n",
                   pszPlus,
                   psShape->padfX[j],
                   psShape->padfY[j],
                   psShape->padfZ[j],
                   psShape->padfM[j],
                   pszPartType );
	    oss << str;
	}
    }

    // Dump dbf 
    sprintf_s(str, "\nDBF Header\n\n");
    oss << str;

    DBFInfo *hDBF = this->dbfinfo;

    bool bHeader = true;  // flag to print header
    char	szTitle[12];
    int		nWidth, nDecimals;

    if( bHeader )
    {
        for( i = 0; i < DBFGetFieldCount(hDBF); i++ )
        {
            DBFFieldType	eType;
            const char	 	*pszTypeName;
	    

            eType = DBFGetFieldInfo( hDBF, i, szTitle, &nWidth, &nDecimals );
            if( eType == FTString )
                pszTypeName = "String";
            else if( eType == FTInteger )
                pszTypeName = "Integer";
            else if( eType == FTDouble )
                pszTypeName = "Double";
            else if( eType == FTInvalid )
                pszTypeName = "Invalid";

            sprintf_s(str, "Field %d: Type=%s, Title=`%s', Width=%d, Decimals=%d\n",
                    i, pszTypeName, szTitle, nWidth, nDecimals );
	    oss << str;
        }
    }

    // More print flags
    bool bMultiLine = false; 
    bool bRaw = false;
    int		*panWidth;
    int         iRecord;
    char	szFormat[32];

    /* -------------------------------------------------------------------- */
    /*	Compute offsets to use when printing each of the field 		*/
    /*	values. We make each field as wide as the field title+1, or 	*/
    /*	the field value + 1. 						*/
    /* -------------------------------------------------------------------- */
    panWidth = (int *) malloc( DBFGetFieldCount( hDBF ) * sizeof(int) );

    for( i = 0; i < DBFGetFieldCount(hDBF) && !bMultiLine; i++ )
    {
      DBFFieldType	eType;

      eType = DBFGetFieldInfo( hDBF, i, szTitle, &nWidth, &nDecimals );
      if( strlen(szTitle) > (unsigned int) nWidth )
	panWidth[i] = strlen(szTitle);
      else
	panWidth[i] = nWidth;

      if( eType == FTString )
	sprintf_s( szFormat, "%%-%ds ", panWidth[i] );
      else
	sprintf_s( szFormat, "%%%ds ", panWidth[i] );
      sprintf_s(str, szFormat, szTitle );
      oss << str;

    }
    //printf( "\n" );
    oss << std::endl;

    /* -------------------------------------------------------------------- */
    /*	Read all the records 						*/
    /* -------------------------------------------------------------------- */
    for( iRecord = 0; iRecord < DBFGetRecordCount(hDBF); iRecord++ )
    {
      if( bMultiLine ) {
	sprintf_s(str, "Record: %d\n", iRecord );
	oss << str;
      }

      for( i = 0; i < DBFGetFieldCount(hDBF); i++ )
      {
	DBFFieldType	eType;

	eType = DBFGetFieldInfo( hDBF, i, szTitle, &nWidth, &nDecimals );

	if( bMultiLine )
	{
	  sprintf_s(str, "%s: ", szTitle );
	  oss << str;
	}

	/* -------------------------------------------------------------------- */
	/*      Print the record according to the type and formatting           */
	/*      information implicit in the DBF field description.              */
	/* -------------------------------------------------------------------- */
	if( !bRaw )
	{
	  if( DBFIsAttributeNULL( hDBF, iRecord, i ) )
	  {
	    if( eType == FTString )
	      sprintf_s( szFormat, "%%-%ds", nWidth );
	    else
	      sprintf_s( szFormat, "%%%ds", nWidth );

	    sprintf_s(str, szFormat, "(NULL)" );
	    oss << str;
	  }
	  else
	  {
	    switch( eType )
	    {
	    case FTString:
	      sprintf_s( szFormat, "%%-%ds", nWidth );
	      sprintf_s(str, szFormat, 
		DBFReadStringAttribute( hDBF, iRecord, i ) );
	      oss << str;
	      break;

	    case FTInteger:
	      sprintf_s( szFormat, "%%%dd", nWidth );
	      sprintf_s(str, szFormat, 
		DBFReadIntegerAttribute( hDBF, iRecord, i ) );
	      oss << str;
	      break;

	    case FTDouble:
	      sprintf_s( szFormat, "%%%d.%dlf", nWidth, nDecimals );
	      sprintf_s(str, szFormat, 
		DBFReadDoubleAttribute( hDBF, iRecord, i ) );
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
	  sprintf_s( szFormat, "%%-%ds", nWidth );
	  sprintf_s(str, szFormat, 
	    DBFReadStringAttribute( hDBF, iRecord, i ) );
	  oss << str;
	}

	/* -------------------------------------------------------------------- */
	/*      Write out any extra spaces required to pad out the field        */
	/*      width.                                                          */
	/* -------------------------------------------------------------------- */
	if( !bMultiLine )
	{
	  sprintf_s( szFormat, "%%%ds", panWidth[i] - nWidth + 1 );
	  sprintf_s(str, szFormat, "" );
	  oss << str;
	}

	if( bMultiLine ) {
	  //printf( "\n" );
	  oss << std::endl;
	}

	//fflush( stdout );
      }
      //printf( "\n" );
      oss << std::endl;
    }
}

void Shapefile::Extract_surface(std::vector<Point> &pts, const int field)
{
  // Point contains a x, y, z + value

  std::vector<double> m;  // rough-in in case M values are given in .shp file

  SHPInfo *hSHP = this->shpinfo;
  DBFInfo *hDBF = this->dbfinfo;


  // get info
  int		nShapeType, nEntities, i, bValidate = 0,nInvalidCount=0;
  double 	adfMinBound[4], adfMaxBound[4];

  SHPGetInfo( hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound );

  // Check field number
  int dbf_fields = DBFGetFieldCount(hDBF);
  int dbf_records = DBFGetRecordCount(hDBF);

  if (field < 0 || field >= dbf_fields)
  {
    std::ostringstream estring;
    estring << "Requested field number, " << field 
      << " (starting from zero), is greater than maximum field number in dbf file " 
      << dbf_fields - 1 << std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
  }

  char	szTitle[12];
  int	nWidth, nDecimals;
  DBFFieldType	eType;

  eType = DBFGetFieldInfo( hDBF, field, szTitle, &nWidth, &nDecimals );
  if (eType != FTDouble && eType != FTInteger)
  {
    std::ostringstream estring;
    estring << "Requested field number, " << field 
      << " is not a real or integer number in dbf file" 
      << std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
  } else
  {
    std::ostringstream ostring;
    ostring << "Extracting field " << field << " "
      << szTitle << std::endl;
    output_msg(OUTPUT_SCREEN, "%s\n", ostring.str().c_str());
  }

  double xlast = -99, ylast = -99, zlast = -99;
  for( i = 0; i < nEntities; i++ )
  {
    int		j;
    SHPObject	*psShape;

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
    double value = DBFReadDoubleAttribute( hDBF, i, field );

    // Apply value to all vertices
    for( j = 0; j < psShape->nVertices; j++ )
    {
      if ((i == 0 && j == 0) ||
	psShape->padfX[j] != xlast ||
	psShape->padfY[j] != ylast ||
	psShape->padfZ[j] != zlast )
      {
	// add to list
	Point pt;
	pt.set_x(psShape->padfX[j]);
	pt.set_y(psShape->padfY[j]);
	pt.set_z(psShape->padfZ[j]);
	pt.set_v(value);
	pts.push_back(pt);

	// Place holder for implementing m shape files
	m.push_back(psShape->padfM[j]);

	// save last point
	xlast = psShape->padfX[j];
	ylast = psShape->padfY[j];
	zlast = psShape->padfZ[j];
      }
    }
  }
}
gpc_polygon *Shapefile::Extract_polygon(void)
{
  // Point contains a x, y, z + value

  std::vector<double> m;  // rough-in in case M values are given in .shp file

  SHPInfo *hSHP = this->shpinfo;
  DBFInfo *hDBF = this->dbfinfo;


  // get info
  int		nShapeType, nEntities, i, bValidate = 0,nInvalidCount=0;
  double 	adfMinBound[4], adfMaxBound[4];

  SHPGetInfo( hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound );

  // Shape type should be polygon
  if (nShapeType != 5) {
    std::ostringstream estring;
    estring << "Shape file does not have shape type of polygon." <<  std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
  }

  
  gpc_polygon *cumulative_polygon = empty_polygon();
  for( i = 0; i < nEntities; i++ )
  {
    int		j;
    SHPObject	*psShape;

    psShape = this->objects[i];
    std::vector<Point> pts;
    double xlast = -99, ylast = -99, zlast = -99;

    // Make polygon from  vertices
    for( j = 0; j < psShape->nVertices; j++ )
    {
      if ((i == 0 && j == 0) ||
	psShape->padfX[j] != xlast ||
	psShape->padfY[j] != ylast ||
	psShape->padfZ[j] != zlast )
      {
	// add to list
	Point pt;
	pt.set_x(psShape->padfX[j]);
	pt.set_y(psShape->padfY[j]);
	pt.set_z(psShape->padfZ[j]);
	pt.set_v(0.0);
	pts.push_back(pt);

	// Place holder for implementing m shape files
	//m.push_back(psShape->padfM[j]);

	// save last point
	xlast = psShape->padfX[j];
	ylast = psShape->padfY[j];
	zlast = psShape->padfZ[j];
      }
    }
    gpc_polygon *temp_polygon = points_to_poly(pts);
    gpc_polygon_clip(GPC_UNION, cumulative_polygon, temp_polygon, cumulative_polygon);
    gpc_free_polygon(temp_polygon);
    free_check_null(temp_polygon);
  }
  return(cumulative_polygon);
}
bool Shapefile::Point_in_polygon(const Point p)
{
  // Point contains a x, y, z + value

  Point work = p;
  std::vector<double> m;  // rough-in in case M values are given in .shp file

  SHPInfo *hSHP = this->shpinfo;
  DBFInfo *hDBF = this->dbfinfo;


  // get info
  int		nShapeType, nEntities, i, bValidate = 0,nInvalidCount=0;
  double 	adfMinBound[4], adfMaxBound[4];

  SHPGetInfo( hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound );

  // Shape type should be polygon
  if (nShapeType != 5) {
    std::ostringstream estring;
    estring << "Shape file does not have shape type of polygon." <<  std::endl;
    error_msg(estring.str().c_str(), EA_STOP);
  }

  for( i = 0; i < nEntities; i++ )
  {
    int		j;
    SHPObject	*psShape;

    psShape = this->objects[i];
    std::vector<Point> pts;
    double xlast = -99, ylast = -99, zlast = -99;

    // Make polygon from  vertices
    for( j = 0; j < psShape->nVertices; j++ )
    {
      if ((i == 0 && j == 0) ||
	psShape->padfX[j] != xlast ||
	psShape->padfY[j] != ylast ||
	psShape->padfZ[j] != zlast )
      {
	// add to list
	Point pt;
	pt.set_x(psShape->padfX[j]);
	pt.set_y(psShape->padfY[j]);
	pt.set_z(psShape->padfZ[j]);
	pt.set_v(0.0);
	pts.push_back(pt);

	// Place holder for implementing m shape files
	//m.push_back(psShape->padfM[j]);

	// save last point
	xlast = psShape->padfX[j];
	ylast = psShape->padfY[j];
	zlast = psShape->padfZ[j];
      }
    }
    bool in = work.point_in_polygon(pts);
    if (in) return(true);
  }
  return(false);
}