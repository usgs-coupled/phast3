#ifndef _INC_PROPERTY
#define _INC_PROPERTY


/* ----------------------------------------------------------------------
 *   Property structure
 * ---------------------------------------------------------------------- */
struct property {
	int type;   /* UNDEFINED, FIXED, LINEAR, ZONE */
	double *v;
	int count_v;
	int count_alloc;
	char coord;
	int icoord;
	double dist1;
	double dist2;
	int new_def;
};

#endif /* _INC_PROPERTY */
