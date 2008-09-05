#ifndef _INC_PROPERTY
#define _INC_PROPERTY
class Data_source;
enum PROP_TYPE
{
	PROP_UNDEFINED      = 100,
	PROP_FIXED          = 101,
	PROP_LINEAR         = 102,
	PROP_ZONE           = 103,
	PROP_MIXTURE        = 104,
	PROP_POINTS         = 105,
	PROP_XYZ            = 106
};
/* ----------------------------------------------------------------------
 *   Property structure
 * ---------------------------------------------------------------------- */
struct property {
	//int type;   /* UNDEFINED, FIXED, LINEAR, ZONE */
	PROP_TYPE type;
	double *v;
	int count_v;
	int count_alloc;
	char coord;
	int icoord;
	double dist1;
	double dist2;
	int new_def;
	Data_source *data_source;
};
EXTERNAL std::vector<property *> properties_with_data_source;
#endif /* _INC_PROPERTY */
