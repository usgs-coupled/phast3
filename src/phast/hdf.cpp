/*
  hdf.cpp
*/
#ifdef USE_MPI
//MPICH seems to require mpi.h to be first
#include <mpi.h>
#endif
#include <string.h>
#include <stdlib.h>
#if defined(_MT)
#define _HDF5USEDLL_			/* reqd for Multithreaded run-time library (Win32) */
#endif
#include <hdf5.h>

#include <string>
#include <vector>
#include <assert.h>
#include <iostream>

#include "phrqtype.h"
#include "hdf.h"


#define PHRQ_malloc malloc
#define PHRQ_free free
#define PHRQ_calloc calloc
#define PHRQ_realloc realloc

#define OK 1
#define STOP 1
#define CONTINUE 0
#define TRUE 1
#define FALSE 0
#define EMPTY 2
#define MAX_PATH 260

#define hssize_t hsize_t
int string_trim(char *str);
void malloc_error(void);
void error_msg(const char * msg, int stop);
char error_string[1024];

/*
 *   static functions
 */
int file_exists(const char *name);
static hid_t open_hdf_file(const char *prefix, int prefix_l);
//static void write_proc_timestep(int rank, int cell_count,
//								hid_t file_dspace_id, hid_t dset_id,
//								double *array, std::vector <std::vector <int> > &back);
static void write_proc_timestep(int rank, int cell_count,
								hid_t file_dspace_id, hid_t dset_id,
								std::vector<double> &array, std::vector <std::vector <int> > &back);
static void write_axis(hid_t loc_id, double *a, int na, const char *name);
static void write_vector(hid_t loc_id, double a[], int na, const char *name);
static void write_vector_mask(hid_t loc_id, int a[], int na,
							  const char *name);
static void hdf_finalize_headings(void);


/*
 *   statics used only by process 0
 */
static struct root_info
{
	hid_t hdf_file_id;
	hid_t grid_gr_id;
	hid_t features_gr_id;
	hid_t current_file_dspace_id;
	hid_t current_file_dset_id;
	hid_t current_timestep_gr_id;
	int nx;
	int ny;
	int nz;
	int nxy;
	int nxyz;
	size_t scalar_name_max_len;
	std::vector <std::string> scalar_names;
#ifdef USE_MPI
	double *recv_array;
	int recv_array_count;
#endif
	char timestep_units[40];
	char timestep_buffer[120];
	int active_count;
	int *active;
	int *natural_to_active;
	double *f_array;
	int print_chem;
	int f_scalar_index;
	int time_step_scalar_count;
	int *time_step_scalar_indices;
	int time_step_count;
	char **time_steps;
	size_t time_step_max_len;
	int vector_name_count;
	char **vector_names;
	size_t vector_name_max_len;
	size_t intermediate_idx;
	std::string hdf_prefix;
	std::string hdf_file_name;
} root;

/*
 *   statics used by all processes (including process 0)
 */
static struct proc_info
{
	int cell_count;
	int scalar_count;			/* chemistry scalar count (doesn't include fortran scalars) */
	//double *array;
	std::vector<double> array;
} proc;

std::vector<std::string> g_hdf_scalar_names;

/* string constants */
static const char szTimeSteps[] = "TimeSteps";
static const char szHDF5Ext[] = ".h5";
static const char szX[] = "X";
static const char szY[] = "Y";
static const char szZ[] = "Z";
static const char szActive[] = "Active";
static const char szGrid[] = "Grid";
static const char szFeatures[] = "Features";
static const char szTimeStepFormat[] = "%.15g %s";
static const char szActiveArray[] = "ActiveArray";
static const char szScalars[] = "Scalars";
static const char szVectors[] = "Vectors";
static const char szVx_node[] = "Vx_node";
static const char szVy_node[] = "Vy_node";
static const char szVz_node[] = "Vz_node";
static const char szVmask[] = "Vmask";

/*
 *   Constamts
 */
static const float INACTIVE_CELL_VALUE = 1.0e30f;

/*-------------------------------------------------------------------------
 * Function          HDF_Init (called by all procs)
 *
 * Preconditions:    HDF prefix
 *
 * Postconditions:   root                init for proc 0
 *                   proc                init for all procs
 *                   HDF file is opened as root.hdf_file_id
 *-------------------------------------------------------------------------
 */
void
HDF_Init(const char *prefix, int prefix_l)
{
#if defined(NDEBUG)
#ifndef _WIN64
	H5Eset_auto(NULL, NULL);
#else
	H5Eset_auto1(NULL, NULL);
#endif
#endif

	/* Open the HDF file */
	root.hdf_file_id = open_hdf_file(prefix, prefix_l);
	assert(root.hdf_file_id > 0);

#ifdef USE_MPI
	root.recv_array = NULL;
	root.recv_array_count = 0;
	root.f_array = NULL;
#endif

	root.current_timestep_gr_id = -1;
	root.current_file_dspace_id = -1;
	root.current_file_dset_id = -1;
	root.print_chem = -1;

	root.time_step_scalar_indices = NULL;
	root.scalar_name_max_len = 0;

	root.time_steps = NULL;
	root.time_step_count = 0;
	root.time_step_max_len = 0;

	root.vector_names = NULL;
	root.vector_name_count = 0;
	root.vector_name_max_len = 0;

	root.intermediate_idx = 0;

	/* init proc */
	proc.cell_count = 0;
	proc.scalar_count = 0;
	//proc.array = NULL;
}
/*-------------------------------------------------------------------------
 * Function          HDF_Finalize (called by all procs)
 *
 * Preconditions:    TODO:
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
void
HDF_Finalize(void)
{
	int i;

	herr_t status;

	assert(root.current_file_dspace_id == -1);	/* shouldn't be open */
	assert(root.current_file_dset_id == -1);	/* shouldn't be open */

	hdf_finalize_headings();

	root.scalar_names.clear();

	if (root.vector_name_count > 0)
	{
		/* free space */
		for (i = 0; i < root.vector_name_count; ++i)
		{
			PHRQ_free(root.vector_names[i]);
		}
		PHRQ_free(root.vector_names);
		root.vector_names = NULL;
		root.vector_name_count = 0;
		root.vector_name_max_len = 0;
	}

	if (root.time_step_count > 0)
	{
		/* free space */
		for (i = 0; i < root.time_step_count; ++i)
		{
			PHRQ_free(root.time_steps[i]);
		}
		PHRQ_free(root.time_steps);
		root.time_steps = NULL;
		root.time_step_count = 0;
		root.time_step_max_len = 0;
	}

	/* free mem */
#ifdef USE_MPI
	assert(root.recv_array != NULL || root.recv_array_count == 0);
	PHRQ_free(root.recv_array);
	root.recv_array = NULL;
	root.recv_array_count = 0;
#endif

#ifdef HDF_ERROR
	assert(root.f_array != NULL);
#endif
	PHRQ_free(root.f_array);
	root.f_array = NULL;

#ifdef HDF_ERROR
	assert(root.natural_to_active != NULL);
#endif
	PHRQ_free(root.natural_to_active);
	root.natural_to_active = NULL;

#ifdef HDF_ERROR
	assert(root.active != NULL);
#endif
	PHRQ_free(root.active);
	root.active = NULL;

	/* close the file */
	assert(root.hdf_file_id > 0);
	status = H5Fclose(root.hdf_file_id);
	assert(status >= 0);


	/* free proc resources */
	//PHRQ_free(proc.array);
	proc.cell_count = 0;
	proc.scalar_count = 0;
	//proc.array = NULL;
}

/*-------------------------------------------------------------------------
 * Function          open_hdf_file
 *
 * Preconditions:    TODO:
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
static hid_t
open_hdf_file(const char *prefix, int prefix_l)
{

	hid_t file_id;
	char hdf_prefix[257];
	char hdf_file_name[257];
	char hdf_backup_name[257];

	strncpy(hdf_prefix, prefix, prefix_l);
	hdf_prefix[prefix_l] = '\0';
	string_trim(hdf_prefix);

	sprintf(hdf_file_name, "%s%s", hdf_prefix, szHDF5Ext);


	root.hdf_prefix    = hdf_prefix;
	root.hdf_file_name = hdf_file_name;
	if (file_exists(hdf_file_name))
	{
		sprintf(hdf_backup_name, "%s%s~", hdf_prefix, szHDF5Ext);
		if (file_exists(hdf_backup_name))
			remove(hdf_backup_name);
		rename(hdf_file_name, hdf_backup_name);
	}


	file_id =
		H5Fcreate(hdf_file_name, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
	if (file_id <= 0)
	{
		sprintf(error_string, "Unable to open HDF file:%s\n", hdf_file_name);
		error_msg(error_string, STOP);
	}
	return file_id;
}


/*-------------------------------------------------------------------------
 * Function          HDF_INIT_INVARIANT (called only by proc 0)
 *
 * Preconditions:    root.hdf_file_id    open
 *
 * Postconditions:   root.grid_gr_id       open
 *                   root.features_gr_id   open
 *-------------------------------------------------------------------------
 */
void
HDF_INIT_INVARIANT(void)
{
	/*
	 * Create the "/Grid" group
	 */
	assert(root.hdf_file_id > 0);	/* precondition */
	root.grid_gr_id = H5Gcreate(root.hdf_file_id, szGrid, 0);
	if (root.grid_gr_id <= 0)
	{
		sprintf(error_string, "Unable to create /%s group\n", szGrid);
		error_msg(error_string, STOP);
	}

	/*
	 * Create the "/szFeatures" group
	 */
	root.features_gr_id = H5Gcreate(root.hdf_file_id, szFeatures, 0);
	if (root.grid_gr_id <= 0)
	{
		sprintf(error_string, "Unable to create /%s group\n", szFeatures);
		error_msg(error_string, STOP);
	}
}

/*-------------------------------------------------------------------------
 * Function          HDF_FINALIZE_INVARIANT (called only by proc 0)
 *
 * Preconditions:    root.grid_gr_id      open
 *                   root.features_gr_id  open
 *
 * Postconditions:   root.grid_gr_id      closed
 *                   root.features_gr_id  closed
 *-------------------------------------------------------------------------
 */
void
HDF_FINALIZE_INVARIANT(void)
{
	herr_t status;

	status = H5Gclose(root.grid_gr_id);
	assert(status >= 0);
	status = H5Gclose(root.features_gr_id);
	assert(status >= 0);
}

/*-------------------------------------------------------------------------
 * Function:         HDF_WRITE_GRID (called by all procs)
 *
 * Purpose:          Writes x, y, z vectors and active cell list to HDF
 *                   file.
 *
 * Preconditions:    TODO
 *                   root.grid_gr_id            created and open
 *
 * Postconditions:   TODO
 *                   proc.scalar_count          set
 *                   root.nx, root.ny, root.nz  set
 *                   root.nxy, root.nxyz        set
 *-------------------------------------------------------------------------
 */
void
HDF_WRITE_GRID(double x[], double y[], double z[],
			   int *nx, int *ny, int *nz,
			   int ibc[], char *UTULBL, int UTULBL_l)
{
	int i;

	/* copy and trim time units */
	strncpy(root.timestep_units, UTULBL, UTULBL_l);
	root.timestep_units[UTULBL_l] = '\0';
	string_trim(root.timestep_units);

	assert(root.grid_gr_id > 0);	/* precondition */

	write_axis(root.grid_gr_id, x, *nx, szX);
	write_axis(root.grid_gr_id, y, *ny, szY);
	write_axis(root.grid_gr_id, z, *nz, szZ);

	root.nx = *nx;
	root.ny = *ny;
	root.nz = *nz;
	root.nxy = root.nx * root.ny;
	root.nxyz = root.nxy * root.nz;

	assert(root.active_count == 0);
	assert(root.natural_to_active == NULL);

	root.natural_to_active = (int *) PHRQ_malloc(sizeof(int) * root.nxyz);
	if (root.natural_to_active == NULL)
		malloc_error();

	root.active = (int *) PHRQ_malloc(sizeof(int) * root.nxyz);
	if (root.active == NULL)
		malloc_error();

	root.active_count = 0;
	for (i = 0; i < root.nxyz; ++i)
	{
		if (ibc[i] >= 0)
		{
			root.natural_to_active[i] = root.active_count;
			root.active[root.active_count] = i;
			++root.active_count;
		}
		else
		{
			root.natural_to_active[i] = -1;
		}
	}
	if (root.active_count <= 0)
	{
		error_msg("No active cells in model.", STOP);
	}

	/* allocate space for fortran scalars */
	assert(root.f_array == NULL);
	root.f_array =
		(double *) PHRQ_malloc(sizeof(double) * root.active_count);
	if (root.f_array == NULL)
		malloc_error();

	if (root.active_count != root.nxyz)
	{						/* Don't write if all are active */
		hsize_t dims[2], maxdims[2];
		hid_t dspace_id;
		hid_t dset_id;
		herr_t status;

		/* Create the "/Grid/Active" dataspace. */
		dims[0] = maxdims[0] = root.active_count;
		dspace_id = H5Screate_simple(1, dims, maxdims);
		assert(dspace_id > 0);

		/* Create the "/Grid/Active" dataset */
		dset_id =
			H5Dcreate(root.grid_gr_id, szActive, H5T_NATIVE_INT,
			dspace_id, H5P_DEFAULT);
		assert(dset_id > 0);

		/* Write the "/Grid/Active" dataset */
		if (H5Dwrite
			(dset_id, H5T_NATIVE_INT, dspace_id, H5S_ALL, H5P_DEFAULT,
			root.active) < 0)
		{
			printf("HDF Error: Unable to write \"/%s/%s\" dataset\n",
				szGrid, szActive);
		}

		/* Close the "/Grid/Active" dataset */
		status = H5Dclose(dset_id);
		assert(status >= 0);

		/* Close the "/Grid/Active" dataspace */
		status = H5Sclose(dspace_id);
		assert(status >= 0);
	}

	proc.scalar_count = (int) g_hdf_scalar_names.size();

}

/*-------------------------------------------------------------------------
 * Function:         write_axis
 *
 * Purpose:          Writes the given vector <name> to the loc_id group.
 *
 * Preconditions:    loc_id                     open
 *
 * Postconditions:   "loc_id/<name>" is written to HDF
 *-------------------------------------------------------------------------
 */
static void
write_axis(hid_t loc_id, double *a, int na, const char *name)
{
	hsize_t dims[1], maxdims[1];
	hid_t dspace_id;
	hid_t dset_id;
	herr_t status;

	if (!(na > 0))
		return;

	/* Create the "/Grid/name" dataspace. */
	dims[0] = maxdims[0] = na;
	dspace_id = H5Screate_simple(1, dims, maxdims);

	/* Create the "/Grid/name" dataset */
	dset_id =
		H5Dcreate(loc_id, name, H5T_NATIVE_FLOAT, dspace_id, H5P_DEFAULT);

	/* Write the "/Grid/name" dataset */
	if (H5Dwrite
		(dset_id, H5T_NATIVE_DOUBLE, dspace_id, H5S_ALL, H5P_DEFAULT, a) < 0)
	{
		sprintf(error_string,
				"HDF Error: Unable to write \"/%s/%s\" dataset\n", szGrid,
				name);
		error_msg(error_string, STOP);
	}

	/* Close the "/Grid/name" dataset */
	status = H5Dclose(dset_id);
	assert(status >= 0);

	/* Close the "/Grid/name" dataspace */
	status = H5Sclose(dspace_id);
	assert(status >= 0);
}

/*-------------------------------------------------------------------------
 * Function:         HDF_WRITE_FEATURE
 *
 * Purpose:          Write list of <feature_name> cell indices to HDF.
 *
 * Preconditions:    root.features_gr_id            created and open
 *
 * Postconditions:   <feature_name> dataset is written to HDF
 *-------------------------------------------------------------------------
 */
void
HDF_WRITE_FEATURE(char *feature_name, int *nodes1, int *node_count,
				  int feature_name_l)
{

	char feature_name_copy[120];
	int i;
	hsize_t dims[1], maxdims[1];
	hid_t dspace_id;
	hid_t dset_id;
	herr_t status;
	int *nodes0;

	if (*node_count == 0)
	{
		/* nothing to do */
		return;
	}

	/* copy and trim feature_name */
	strncpy(feature_name_copy, feature_name, feature_name_l);
	feature_name_copy[feature_name_l] = '\0';
	string_trim(feature_name_copy);

	/* Create the "/szFeatures/feature_name" dataspace. */
	dims[0] = maxdims[0] = *node_count;
	dspace_id = H5Screate_simple(1, dims, maxdims);

	/* Create the "/szFeatures/feature_name" dataset */
	dset_id =
		H5Dcreate(root.features_gr_id, feature_name_copy, H5T_NATIVE_INT,
				  dspace_id, H5P_DEFAULT);

	/* Convert from 1-based to 0-based */
	nodes0 = (int *) PHRQ_malloc(sizeof(int) * (*node_count));
	if (nodes0 == NULL)
		malloc_error();
	for (i = 0; i < *node_count; ++i)
	{
		nodes0[i] = nodes1[i] - 1;
	}

	/* Write the "/szFeatures/feature_name" dataset. */
	if (H5Dwrite
		(dset_id, H5T_NATIVE_INT, dspace_id, H5S_ALL, H5P_DEFAULT,
		 nodes0) < 0)
	{
		printf("HDF Error: Unable to write \"/%s/%s\" dataset.\n", szFeatures,
			   feature_name_copy);
		assert(0);
	}

	/* Close the "/szFeatures/feature_name" dataset */
	status = H5Dclose(dset_id);
	assert(status >= 0);

	/* Close the "/szFeatures/feature_name" dataspace. */
	status = H5Sclose(dspace_id);
	assert(status >= 0);

	PHRQ_free(nodes0);
}

/*-------------------------------------------------------------------------
 * Function:         HDF_OPEN_TIME_STEP (called only by proc 0)
 *
 * Purpose:          TODO
 *
 * Preconditions:    TODO
 *
 * Postconditions:   TODO
 *-------------------------------------------------------------------------
 */
void
HDF_OPEN_TIME_STEP(double *time, double *cnvtmi, int *print_chem,
				   int *print_vel, int *f_scalar_count)
{
	hsize_t dims[1];
	int i;
	size_t len;

#ifdef USE_MPI
	/*    extern int mpi_myself; */
#else
	/*    const int mpi_myself = 0; */
#endif

	assert(root.current_timestep_gr_id == -1);	/* shouldn't be open yet */
	assert(root.current_file_dset_id == -1);	/* shouldn't be open yet */
	assert(root.current_file_dspace_id == -1);	/* shouldn't be open yet */

	/* determine scalar count for this timestep */
	root.print_chem = (*print_chem);
	root.time_step_scalar_count =
		(root.print_chem ? proc.scalar_count : 0) + (*f_scalar_count);
	if (root.time_step_scalar_count == 0 && *print_vel == 0)
	{
		return;					/* no hdf scalar or vector output for this time step */
	}

	/* format timestep string */
	sprintf(root.timestep_buffer, szTimeStepFormat, (*time) * (*cnvtmi),
			root.timestep_units);

	/* add time step string to list */
	root.time_steps =
		(char **) PHRQ_realloc(root.time_steps,
							   sizeof(char *) * (root.time_step_count + 1));
	if (root.time_steps == NULL)
		malloc_error();
	len = strlen(root.timestep_buffer) + 1;
	if (root.time_step_max_len < len)
		root.time_step_max_len = len;
	root.time_steps[root.time_step_count] = (char *) PHRQ_malloc(len);
	if (root.time_steps[root.time_step_count] == NULL)
		malloc_error();
	strcpy(root.time_steps[root.time_step_count], root.timestep_buffer);
	++root.time_step_count;

	/* Create the /<timestep string> group */
	assert(root.timestep_buffer && strlen(root.timestep_buffer));
	root.current_timestep_gr_id =
		H5Gcreate(root.hdf_file_id, root.timestep_buffer, 0);
	if (root.current_timestep_gr_id < 0)
	{
		assert(0);
		sprintf(error_string, "HDF ERROR: Unable to create group /%s\n",
				root.timestep_buffer);
		error_msg(error_string, STOP);
	}

	if (root.time_step_scalar_count != 0)
	{

		/* allocate space for time step scalar indices */
		assert(root.time_step_scalar_indices == NULL);
		root.time_step_scalar_indices =
			(int *) PHRQ_malloc(sizeof(int) * root.time_step_scalar_count);
		if (root.time_step_scalar_indices == NULL)
			malloc_error();

		/* add cscalar indices (fortran indices are added one by one in PRNARR_HDF) */
		if (root.print_chem)
		{
			for (i = 0; i < proc.scalar_count; ++i)
			{
				root.time_step_scalar_indices[i] = i;
			}
		}

		/* Create the "/<timestep string>/ActiveArray" file dataspace. */
		dims[0] = root.active_count * root.time_step_scalar_count;
		root.current_file_dspace_id = H5Screate_simple(1, dims, NULL);
		if (root.current_file_dspace_id < 0)
		{
			assert(0);
			sprintf(error_string,
					"HDF ERROR: Unable to create dataspace(DIM=%d) for /%s/%s\n",
					(int) dims[0], root.timestep_buffer, szActiveArray);
			error_msg(error_string, STOP);
		}

		/* Create the "/<timestep string>/ActiveArray" dataset */
		root.current_file_dset_id =
			H5Dcreate(root.current_timestep_gr_id, szActiveArray,
					  H5T_NATIVE_FLOAT, root.current_file_dspace_id,
					  H5P_DEFAULT);
		if (root.current_file_dset_id < 0)
		{
			assert(0);
			sprintf(error_string,
					"HDF ERROR: Unable to create dataset /%s/%s\n",
					root.timestep_buffer, szActiveArray);
			error_msg(error_string, STOP);
		}
	}

	/* reset fortran scalar index */
	root.f_scalar_index = 0;
}

/*-------------------------------------------------------------------------
 * Function:         HDF_CLOSE_TIME_STEP (called only by proc 0)
 *
 * Purpose:          TODO
 *
 * Preconditions:    TODO
 *
 * Postconditions:   TODO
 *-------------------------------------------------------------------------
 */
void
HDF_CLOSE_TIME_STEP(void)
{
	herr_t status;

	if (root.current_file_dset_id > 0)
	{
		status = H5Dclose(root.current_file_dset_id);
		assert(status >= 0);
	}
	root.current_file_dset_id = -1;

	if (root.current_file_dspace_id > 0)
	{
		status = H5Sclose(root.current_file_dspace_id);
		assert(status >= 0);
	}
	root.current_file_dspace_id = -1;

	if (root.time_step_scalar_count > 0)
	{
		/* write the scalar indices for this timestep */
		hsize_t dims[1];
		hid_t dspace, dset;
		herr_t status;

		dims[0] = root.time_step_scalar_count;
		dspace = H5Screate_simple(1, dims, NULL);
		if (dspace <= 0)
		{
			assert(0);
			sprintf(error_string,
					"HDF ERROR: Unable to create file dataspace(DIM(%d)) for dataset /%s/%s\n",
					(int) dims[0], root.timestep_buffer, szScalars);
			error_msg(error_string, STOP);
		}
		dset =
			H5Dcreate(root.current_timestep_gr_id, szScalars, H5T_NATIVE_INT,
					  dspace, H5P_DEFAULT);
		if (dset <= 0)
		{
			assert(0);
			sprintf(error_string,
					"HDF ERROR: Unable to create dataset /%s/%s\n",
					root.timestep_buffer, szScalars);
			error_msg(error_string, STOP);
		}
		status =
			H5Dwrite(dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT,
					 root.time_step_scalar_indices);
		if (status < 0)
		{
			assert(0);
			sprintf(error_string,
					"HDF ERROR: Unable to write dataset /%s/%s\n",
					root.timestep_buffer, szScalars);
			error_msg(error_string, STOP);
		}
		status = H5Dclose(dset);
		assert(status >= 0);

		PHRQ_free(root.time_step_scalar_indices);
		root.time_step_scalar_indices = NULL;

		status = H5Sclose(dspace);
		assert(status >= 0);
	}

	/* close the time step group */
	if (root.current_timestep_gr_id > 0)
	{
		status = H5Gclose(root.current_timestep_gr_id);
		assert(status >= 0);
	}
	root.current_timestep_gr_id = -1;
}


/*-------------------------------------------------------------------------
 * Function:         HDFBeginCTimeStep (called by all procs)
 *
 * Purpose:          TODO
 *
 * Preconditions:    TODO
 *
 * Postconditions:   TODO
 *-------------------------------------------------------------------------
 */
void
HDFBeginCTimeStep(int count_chem)
{
#ifdef USE_MPI
#ifdef TODO
	extern std::vector<int> start_cell;
	extern std::vector<int> end_cell;
	extern int *random_list;
	extern int mpi_myself;

	int *ptr_begin;
	int *ptr_end;
#endif
#endif

	int i;
	int array_count;

	if (proc.scalar_count == 0)
		return;

	proc.cell_count = count_chem;

	/* allocate space for this time step */
	assert(proc.cell_count > 0);
	assert(proc.scalar_count > 0);
	array_count = proc.cell_count * proc.scalar_count;
	//proc.array =
	//	(double *) PHRQ_realloc(proc.array, sizeof(double) * array_count);
	//if (proc.array == NULL)
	//	malloc_error();
	proc.array.resize(array_count);

	/* init entire array to inactive */
	for (i = 0; i < array_count; ++i)
	{
		proc.array[i] = INACTIVE_CELL_VALUE;
	}
}
/*-------------------------------------------------------------------------
 * Function:         HDFEndCTimeStep   (called by all procs)
 *
 * Purpose:          Write chemistry scalars to HDF file
 *
 * Preconditions:    if (proc.cell_count > 0 && mpi_myself == 0)
 *                      root.current_file_dspace_id   OPENED (>0)
 *                      root.current_file_dset_id     OPENED (>0)
 *                   else
 *                      none
 *
 * Postconditions:   Chemistry scalars are written to HDF
 *-------------------------------------------------------------------------
 */
void
HDFEndCTimeStep(std::vector <std::vector <int> > &back)
{
#ifdef USE_MPI
	const int TAG_HDF_DATA = 5;
#endif
	const int mpi_myself = 0;


	if (proc.cell_count == 0)
		return;					/* nothing to do */

	//if (mpi_myself == 0)
	//{
		assert(root.current_file_dspace_id > 0);	/* precondition */
		assert(root.current_file_dset_id > 0);	/* precondition */

		/* write proc 0 data */
		write_proc_timestep(mpi_myself, proc.cell_count,
							root.current_file_dspace_id,
							root.current_file_dset_id, proc.array, back);
	//}
}

/*-------------------------------------------------------------------------
 * Function          write_proc_timestep
 *
 * Preconditions:    Called only by proc 0 (for each proc including 0)
 *
 * Postconditions:   Timestep for the process(rank) is written to HDF
 *-------------------------------------------------------------------------
 */
static void
write_proc_timestep(int rank, int cell_count, hid_t file_dspace_id,
//					hid_t dset_id, double *array, std::vector <std::vector <int> > &back)
					hid_t dset_id, std::vector<double> &array, std::vector <std::vector <int> > &back)
{

	hssize_t(*coor)[1];
	hid_t mem_dspace;
	herr_t status;
	hsize_t dims[1];
	int i, j, n;

	/* create the memory dataspace */
	dims[0] = cell_count * proc.scalar_count;
	assert(dims[0] > 0);
	mem_dspace = H5Screate_simple(1, dims, NULL);
	if (mem_dspace < 0)
	{
		sprintf(error_string,
				"HDF ERROR: Unable to create memory dataspace for process %d\n",
				rank);
		error_msg(error_string, STOP);
	}

	/* allocate coordinates for file dataspace selection */
	coor =
		(hssize_t(*)[1]) PHRQ_malloc(sizeof(hssize_t[1]) * cell_count *
									 proc.scalar_count);
	if (coor == NULL)
		malloc_error();

	for (n = 0; n < (int) back[0].size(); ++n)
	{
		for (j = 0; j < proc.scalar_count; ++j)
		{
			for (i = 0; i < cell_count; ++i)
			{
				coor[i + j * cell_count][0] =
					root.natural_to_active[back[i][n]] +
					j * root.active_count;
			}
		}

		/* make the independent points selection for the file dataspace */
		status =
			H5Sselect_elements(file_dspace_id, H5S_SELECT_SET,
							   cell_count * proc.scalar_count,
#if (H5_VERS_MAJOR>1)||((H5_VERS_MAJOR==1)&&(H5_VERS_MINOR>=8))||((H5_VERS_MAJOR==1)&&(H5_VERS_MINOR==6)&&(H5_VERS_RELEASE>=7))
							   (const hssize_t *) coor);
#else
							   (const hssize_t **) coor);
#endif
		assert(status >= 0);

		status =
			H5Dwrite(dset_id, H5T_NATIVE_DOUBLE, mem_dspace, file_dspace_id,
					 H5P_DEFAULT, array.data());
		if (status < 0)
		{
			sprintf(error_string, "HDF ERROR: Unable to write dataspace\n");
			error_msg(error_string, STOP);
		}
	}

	PHRQ_free(coor);

	status = H5Sclose(mem_dspace);
	assert(status >= 0);
}
void
HDFSetScalarNames(std::vector<std::string> &names)
{
		g_hdf_scalar_names = names;
		root.scalar_names = names;
		proc.scalar_count = (int) root.scalar_names.size();
}
/*-------------------------------------------------------------------------
 * Function          FillHyperSlab
 *
 * Preconditions:    HDFBeginTimeStep has been called
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
void
HDFFillHyperSlab(int chem_number, std::vector< double > &d, size_t columns)
{
	if (columns > 0)
	{
		assert (d.size()%columns == 0);

		for (size_t j = 0; j < d.size()/columns; j++)
		{
			int n = (int) j + chem_number;
			size_t k = j * columns;
			for (size_t i = 0; i < columns; i++)
			{
				assert(proc.array[i * proc.cell_count + n] == (double) INACTIVE_CELL_VALUE);
				proc.array[i * proc.cell_count + n] = (double) d[k + i];
			}
		}
	}
}
/*-------------------------------------------------------------------------
 * Function:         PRNTAR_HDF
 *
 * Purpose:          TODO:
 *
 * Preconditions:    TODO:
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
void
PRNTAR_HDF(double array[], double frac[], double *cnv, char *name, int name_l)
{
	char name_buffer[120];
	hssize_t start[1];
	hsize_t dims[1], count[1];
	hid_t mem_dspace;
	herr_t status;
	int i;

	assert(root.time_step_scalar_count > 0);

	/* copy and trim scalar name label */
	strncpy(name_buffer, name, name_l);
	name_buffer[name_l] = '\0';
	string_trim(name_buffer);

	/* check if this f_scalar has been added to root.scalar_names yet */
	/* phreeqc scalar count is proc.scalar_count */
	for (i = proc.scalar_count; i < (int) root.scalar_names.size(); ++i)
	{
		if (root.scalar_names[i] == name_buffer)
			break;
	}
	if (i == (int) root.scalar_names.size())
	{
		size_t len = strlen(name_buffer) + 1;
		if (root.scalar_name_max_len < len)
			root.scalar_name_max_len = len;
		root.scalar_names.push_back(name_buffer);
	}

	/* add this scalar index to the list of scalar indices */
	assert(((root.print_chem ? proc.scalar_count : 0) + root.f_scalar_index) <
		   root.time_step_scalar_count);
	root.time_step_scalar_indices[(root.print_chem ? proc.scalar_count : 0) +
								  root.f_scalar_index] = i;

	/* copy the fortran scalar array into the active scalar array (f_array) */
	assert(root.f_array != NULL);
	assert(root.active_count > 0);
	if (root.active && root.f_array && frac)
	{
		for (i = 0; i < root.active_count; ++i)
		{
			assert(root.active[i] >= 0 && root.active[i] < root.nxyz);
			if (frac[root.active[i]] <= 0.0001)
			{
				root.f_array[i] = INACTIVE_CELL_VALUE;
			}
			else
			{
				root.f_array[i] = array[root.active[i]] * (*cnv);
			}
		}
	}

	/* create the memory dataspace */
	dims[0] = root.active_count;
	mem_dspace = H5Screate_simple(1, dims, NULL);
	if (mem_dspace <= 0)
	{
		assert(0);
		sprintf(error_string,
				"HDF Error: Unable to create memory dataspace\n");
		error_msg(error_string, STOP);
	}

	/* select within the file dataspace the hyperslab to write to */

	start[0] =
		(root.f_scalar_index +
		 (root.print_chem ? proc.scalar_count : 0)) * root.active_count;
	count[0] = root.active_count;

	assert(root.current_file_dspace_id > 0);	/* precondition */
	status =
		H5Sselect_hyperslab(root.current_file_dspace_id, H5S_SELECT_SET,
							start, NULL, count, NULL);
	assert(status >= 0);

	/* Write the "/<timestep>/ActiveArray" dataset selection for this scalar */
	assert(root.current_file_dset_id > 0);	/* precondition */
	if (H5Dwrite
		(root.current_file_dset_id, H5T_NATIVE_DOUBLE, mem_dspace,
		 root.current_file_dspace_id, H5P_DEFAULT, root.f_array) < 0)
	{
		assert(0);
		sprintf(error_string, "HDF Error: Unable to write dataset\n");
		error_msg(error_string, STOP);
	}

	/* Close the memory dataspace */
	status = H5Sclose(mem_dspace);
	assert(status >= 0);

	/* increment f_scalar_index */
	++root.f_scalar_index;
}

/*-------------------------------------------------------------------------
 * Function:         HDF_VEL
 *
 * Purpose:          TODO:
 *
 * Preconditions:    TODO:
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
void
HDF_VEL(double vx_node[], double vy_node[], double vz_node[], int vmask[])
{
	int i;
	const char name[] = "Velocities";

	/* check if the vector "Velocities" has been added to root.vector_names yet */
	for (i = 0; i < root.vector_name_count; ++i)
	{
		if (strcmp(root.vector_names[i], name) == 0)
			break;
	}
	if (i == root.vector_name_count)
	{
		/* new scalar name */
		size_t len = strlen(name) + 1;
		root.vector_names =
			(char **) PHRQ_realloc(root.vector_names,
								   sizeof(char *) * (root.vector_name_count +
													 1));
		if (root.vector_names == NULL)
			malloc_error();
		if (root.vector_name_max_len < len)
			root.vector_name_max_len = len;
		root.vector_names[root.vector_name_count] = (char *) PHRQ_malloc(len);
		if (root.vector_names[root.vector_name_count] == NULL)
			malloc_error();
		strcpy(root.vector_names[root.vector_name_count], name);
		++root.vector_name_count;
	}
	assert(root.vector_name_count == 1);	/* Has a new vector been added? */


	write_vector(root.current_timestep_gr_id, vx_node, root.nxyz, szVx_node);
	write_vector(root.current_timestep_gr_id, vy_node, root.nxyz, szVy_node);
	write_vector(root.current_timestep_gr_id, vz_node, root.nxyz, szVz_node);
	write_vector_mask(root.current_timestep_gr_id, vmask, root.nxyz, szVmask);
}


/*-------------------------------------------------------------------------
 * Function:         write_vector
 *
 * Purpose:          Writes the given vector <name> to the loc_id group.
 *
 * Preconditions:    loc_id                     open
 *
 * Postconditions:   "loc_id/<name>" is written to HDF
 *-------------------------------------------------------------------------
 */
static void
write_vector(hid_t loc_id, double a[], int na, const char *name)
{
	hsize_t dims[1];
	hid_t dspace_id;
	hid_t dset_id;
	herr_t status;

	if (na <= 0)
		return;

	/* Create the "/<timestep string>/name" dataspace. */
	dims[0] = na;
	dspace_id = H5Screate_simple(1, dims, NULL);

	/* Create the "/<timestep string>/name" dataset */
	dset_id =
		H5Dcreate(loc_id, name, H5T_NATIVE_FLOAT, dspace_id, H5P_DEFAULT);

	/* Write the "/<timestep string>/name" dataset */
	if (H5Dwrite
		(dset_id, H5T_NATIVE_DOUBLE, dspace_id, H5S_ALL, H5P_DEFAULT, a) < 0)
	{
		sprintf(error_string,
				"HDF Error: Unable to write \"/%s/%s\" dataset\n",
				root.timestep_buffer, name);
		error_msg(error_string, STOP);
	}

	/* Close the "/<timestep string>/name" dataset */
	status = H5Dclose(dset_id);
	assert(status >= 0);

	/* Close the "/<timestep string>/name" dataspace */
	status = H5Sclose(dspace_id);
	assert(status >= 0);
}

/*-------------------------------------------------------------------------
 * Function:         write_vector_mask
 *
 * Purpose:          Writes the given vector <name> to the loc_id group.
 *
 * Preconditions:    loc_id                     open
 *
 * Postconditions:   "loc_id/<name>" is written to HDF
 *-------------------------------------------------------------------------
 */
static void
write_vector_mask(hid_t loc_id, int a[], int na, const char *name)
{
	hsize_t dims[1];
	hid_t dspace_id;
	hid_t dset_id;
	herr_t status;

	if (na <= 0)
		return;

	/* Create the "/<timestep string>/name" dataspace. */
	dims[0] = na;
	dspace_id = H5Screate_simple(1, dims, NULL);

	/* Create the "/<timestep string>/name" dataset */
	dset_id = H5Dcreate(loc_id, name, H5T_NATIVE_INT, dspace_id, H5P_DEFAULT);

	/* Write the "/<timestep string>/name" dataset */
	if (H5Dwrite(dset_id, H5T_NATIVE_INT, dspace_id, H5S_ALL, H5P_DEFAULT, a)
		< 0)
	{
		sprintf(error_string,
				"HDF Error: Unable to write \"/%s/%s\" dataset\n",
				root.timestep_buffer, name);
		error_msg(error_string, STOP);
	}

	/* Close the "/<timestep string>/name" dataset */
	status = H5Dclose(dset_id);
	assert(status >= 0);

	/* Close the "/<timestep string>/name" dataspace */
	status = H5Sclose(dspace_id);
	assert(status >= 0);
}
void
HDF_INTERMEDIATE(void)
{

	herr_t status;

	// close the file
	assert(root.hdf_file_id > 0);
	status = H5Fclose(root.hdf_file_id);
	assert(status >= 0);

	// create intermediate filename
	char int_fn[MAX_PATH];
	sprintf(int_fn, "%s.intermediate%s", root.hdf_prefix.c_str(), szHDF5Ext);
		
	// copy to the intermediate file
	char command[3*MAX_PATH];
#if WIN32
	sprintf(command, "copy \"%s\" \"%s\"", root.hdf_file_name.c_str(), int_fn);
#else
	sprintf(command, "cp \"%s\" \"%s\"", root.hdf_file_name.c_str(), int_fn);
#endif
	system(command);

	// open intermediate file for finalization
	root.hdf_file_id = H5Fopen(int_fn, H5F_ACC_RDWR , H5P_DEFAULT);
	if (root.hdf_file_id <= 0)
	{
		sprintf(error_string, "Unable to open HDF file:%s\n", int_fn);
		error_msg(error_string, STOP);
	}

	// finalize intermediate
	hdf_finalize_headings();

	// close the file
	assert(root.hdf_file_id > 0);
	status = H5Fclose(root.hdf_file_id);
	assert(status >= 0);


	// reopen hdf file
	root.hdf_file_id = H5Fopen(root.hdf_file_name.c_str(), H5F_ACC_RDWR , H5P_DEFAULT);
	if (root.hdf_file_id <= 0)
	{
		sprintf(error_string, "Unable to open HDF file:%s\n", root.hdf_file_name.c_str());
		error_msg(error_string, STOP);
	}
}


/*-------------------------------------------------------------------------
 * Function          hdf_finalize_headings
 *
 * Preconditions:    TODO:
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
static void
hdf_finalize_headings(void)
{
	int i;

	herr_t status;
	hid_t fls_type;

	assert(root.current_file_dspace_id == -1);	// shouldn't be open
	assert(root.current_file_dset_id == -1);	// shouldn't be open

	// create fixed length string type for /Scalar /TimeSteps and /Vectors
	fls_type = H5Tcopy(H5T_C_S1);
	if (fls_type <= 0)
	{
		assert(0);
		sprintf(error_string, "HDF ERROR: Unable to copy H5T_C_S1.\n");
		error_msg(error_string, STOP);
	}
	status = H5Tset_strpad(fls_type, H5T_STR_NULLTERM);
	if (status < 0)
	{
		assert(0);
		sprintf(error_string,
			"HDF ERROR: Unable to set size of fixed length string type(size=%d).\n",
			(int) root.scalar_name_max_len);
		error_msg(error_string, STOP);
	}


	//if (root.scalar_name_count > 0)
	if (root.scalar_names.size() > 0)
	{
		hsize_t dims[1];
		hid_t dspace;
		hid_t dset;
		char *scalar_names;

		// write scalar names to file

		status = H5Tset_size(fls_type, root.scalar_name_max_len);
		if (status < 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to set size of fixed length string type(size=%d).\n",
				(int) root.scalar_name_max_len);
			error_msg(error_string, STOP);
		}

		//assert(root.scalar_names != NULL);
		assert (root.scalar_names.size() > 0);

		// create the /Scalars dataspace
		//dims[0] = root.scalar_name_count;
		dims[0] = root.scalar_names.size();
		dspace = H5Screate_simple(1, dims, NULL);
		if (dspace <= 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to create the /%s dataset dataspace.\n",
				szScalars);
			error_msg(error_string, STOP);
		}

		// create the /Scalars dataset
		dset =
			H5Dcreate(root.hdf_file_id, szScalars, fls_type, dspace,
			H5P_DEFAULT);
		if (dset <= 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to create the /%s dataset.\n",
				szScalars);
			error_msg(error_string, STOP);
		}
		for (size_t j = 0; j < root.scalar_names.size(); j++)
		{
			if (root.scalar_names[j].size() + 1 > root.scalar_name_max_len) 
				root.scalar_name_max_len = root.scalar_names[j].size() + 1;
		}

		// copy variable length scalar names to fixed length scalar names
		scalar_names =
			(char *) PHRQ_calloc(root.scalar_name_max_len *
			root.scalar_names.size(), sizeof(char));
		// java req'd
		for (i = 0; i < (int) root.scalar_names.size(); ++i)
		{
			strcpy(scalar_names + i * root.scalar_name_max_len,
				root.scalar_names[i].c_str());
		}


		// write the /Scalars dataset
		status =
			H5Dwrite(dset, fls_type, H5S_ALL, H5S_ALL, H5P_DEFAULT,
			scalar_names);
		if (status < 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to write the /%s dataset.\n",
				szScalars);
			error_msg(error_string, STOP);
		}

		PHRQ_free(scalar_names);

		status = H5Sclose(dspace);
		assert(status >= 0);

		status = H5Dclose(dset);
		assert(status >= 0);
	}

	if (root.vector_name_count > 0)
	{
		hsize_t dims[1];
		hid_t dspace;
		hid_t dset;
		char *vector_names;

		// write vector names to file

		assert(root.vector_name_count == 1);	// Has a new vector been added?
		assert(root.vector_names != NULL);

		status = H5Tset_size(fls_type, root.vector_name_max_len);
		if (status < 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to set size of fixed length string type(size=%d).\n",
				(int) root.scalar_name_max_len);
			error_msg(error_string, STOP);
		}


		// create the /Vectors dataspace
		dims[0] = root.vector_name_count;
		dspace = H5Screate_simple(1, dims, NULL);
		if (dspace <= 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to create the /%s dataset dataspace.\n",
				szVectors);
			error_msg(error_string, STOP);
		}

		// create the /Vectors dataset
		dset =
			H5Dcreate(root.hdf_file_id, szVectors, fls_type, dspace,
			H5P_DEFAULT);
		if (dset <= 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to create the /%s dataset.\n",
				szVectors);
			error_msg(error_string, STOP);
		}

		// copy variable length vectors to fixed length strings
		vector_names =
			(char *) PHRQ_calloc(root.vector_name_max_len *
			root.vector_name_count, sizeof(char));
		for (i = 0; i < root.vector_name_count; ++i)
		{
			strcpy(vector_names + i * root.vector_name_max_len,
				root.vector_names[i]);
		}

		// write the /Vectors dataset
		status =
			H5Dwrite(dset, fls_type, H5S_ALL, H5S_ALL, H5P_DEFAULT,
			vector_names);
		if (status < 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to write the /%s dataset.\n",
				szVectors);
			error_msg(error_string, STOP);
		}

		PHRQ_free(vector_names);

		status = H5Sclose(dspace);
		assert(status >= 0);

		status = H5Dclose(dset);
		assert(status >= 0);
	}

	if (root.time_step_count > 0)
	{
		hsize_t dims[1];
		hid_t dspace;
		hid_t dset;
		char *time_steps;

		// write time step names to file

		status = H5Tset_size(fls_type, root.time_step_max_len);
		if (status < 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to set size of fixed length string type(size=%d).\n",
				(int) root.time_step_max_len);
			error_msg(error_string, STOP);
		}

		assert(root.time_steps != NULL);

		// create the /TimeSteps (szTimeSteps) dataspace
		dims[0] = root.time_step_count;
		dspace = H5Screate_simple(1, dims, NULL);
		if (dspace <= 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to create the /%s dataset dataspace.\n",
				szTimeSteps);
			error_msg(error_string, STOP);
		}

		// create the /TimeSteps (szTimeSteps) dataset
		dset =
			H5Dcreate(root.hdf_file_id, szTimeSteps, fls_type, dspace,
			H5P_DEFAULT);
		if (dset <= 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to create the /%s dataset.\n",
				szTimeSteps);
			error_msg(error_string, STOP);
		}

		// copy variable length time steps to fixed length strings
		time_steps =
			(char *) PHRQ_calloc(root.time_step_max_len *
			root.time_step_count, sizeof(char));
		for (i = 0; i < root.time_step_count; ++i)
		{
			strcpy(time_steps + i * root.time_step_max_len,
				root.time_steps[i]);
		}

		// write the /TimeSteps (szTimeSteps) dataset
		status =
			H5Dwrite(dset, fls_type, H5S_ALL, H5S_ALL, H5P_DEFAULT,
			time_steps);
		if (status < 0)
		{
			assert(0);
			sprintf(error_string,
				"HDF ERROR: Unable to write the /%s dataset.\n",
				szTimeSteps);
			error_msg(error_string, STOP);
		}

		PHRQ_free(time_steps);

		status = H5Sclose(dspace);
		assert(status >= 0);

		status = H5Dclose(dset);
		assert(status >= 0);
	}

	// close the fixed lenght string type
	status = H5Tclose(fls_type);
	assert(status >= 0);

	// close the file
	assert(root.hdf_file_id > 0);
	status = H5Fclose(root.hdf_file_id);
	assert(status >= 0);


	root.hdf_file_id = H5Fopen(root.hdf_file_name.c_str(), H5F_ACC_RDWR , H5P_DEFAULT);
	if (root.hdf_file_id <= 0)
	{
		sprintf(error_string, "Unable to open HDF file:%s\n", root.hdf_file_name.c_str());
		error_msg(error_string, STOP);
	}
}
/* ---------------------------------------------------------------------- */
int 
string_trim(char *str)
/* ---------------------------------------------------------------------- */
{
/*
 *   Function trims white space from left and right of string
 *
 *   Arguments:
 *      str      string to trime
 *
 *   Returns
 *      TRUE     if string was changed
 *      FALSE    if string was not changed
 *      EMPTY    if string is all whitespace
 */
	int i, l, start, end, length;
	char *ptr_start;

	l = (int) strlen(str);
	/*
	 *   leading whitespace
	 */
	for (i = 0; i < l; i++)
	{
		if (isspace((int) str[i]))
			continue;
		break;
	}
	if (i == l)
		return (EMPTY);
	start = i;
	ptr_start = &(str[i]);
	/*
	 *   trailing whitespace
	 */
	for (i = l - 1; i >= 0; i--)
	{
		if (isspace((int) str[i]))
			continue;
		break;
	}
	end = i;
	if (start == 0 && end == l)
		return (FALSE);
	length = end - start + 1;
	memmove((void *) str, (void *) ptr_start, (size_t) length);
	str[length] = '\0';

	return (TRUE);
}
/* ---------------------------------------------------------------------- */
void 
malloc_error(void)
/* ---------------------------------------------------------------------- */
{
	//error_msg("NULL pointer returned from malloc or realloc.", CONTINUE);
	//error_msg("Program terminating.", STOP);
	std::cerr << "NULL pointer returned from malloc or realloc in hdf.cpp.\n";
	std::cerr << "Program terminating." << std::endl;
	exit(4);
}
/* ---------------------------------------------------------------------- */
void 
error_msg(const char * msg, int stop)
/* ---------------------------------------------------------------------- */
{

	std::cerr << msg << "\n";
	if (stop == STOP)
	{
		std::cerr << "Program terminating." << std::endl;
		exit(4);
	}
}
/*-------------------------------------------------------------------------
 * Function          file_exists
 *
 * Preconditions:    TODO:
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
int
file_exists(const char *name)
{
	FILE *stream;
	if ((stream = fopen(name, "r")) == NULL)
	{
		return 0;				/* doesn't exist */
	}
	fclose(stream);
	return 1;					/* exists */
}
