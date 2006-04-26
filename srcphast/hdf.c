/*
  hdf.c
*/

#include <stdio.h>       /* printf sprintf */
#include <string.h>      /* strncpy strtok strcat */
#include <assert.h>      /* assert */
#include <stdarg.h>      /* va_arg */
#if defined(_MT)
#define _HDF5USEDLL_     /* reqd for Multithreaded run-time library (Win32) */
#endif
#include <hdf5.h>        /* HDF routines */

static char const svnid[] = "$Id$";

#ifdef USE_MPI
#include <mpi.h>         /* MPI routines */
#define MPI_MAX_TASKS 50 /* from hst.c */
static char const DEFINE_USE_MPI[] = "#define USE_MPI 1";
#else
static char const DEFINE_USE_MPI[] = "#define USE_MPI 0";
#endif

#define EXTERNAL extern
#include "phreeqc/global.h"      /* error_string */
#include "phreeqc/output.h"
#include "hst.h"                 /* struct back_list */
#include "phreeqc/phqalloc.h"    /* PHRQ_malloc PHRQ_realloc PHRQ_free */
#undef EXTERNAL
#include "phreeqc/phrqproto.h"
#include "phastproto.h"

/*
 *   static functions
 */
extern int file_exists(const char* name);
static hid_t open_hdf_file(char* prefix, int prefix_l);
static void write_proc_timestep(int rank, int cell_count, hid_t file_dspace_id, hid_t dset_id, double* array);
static int get_c_scalar_count(int load_names, char** names);
static void write_axis(hid_t loc_id, double* a, int na, const char* name);
static void write_vector(hid_t loc_id, double a[], int na, const char* name);
static void write_vector_mask(hid_t loc_id, int a[], int na, const char* name);
static int hdf_callback(const int action, const int type, const char *name, const int stop, void *cookie, const char *format, va_list args);


/*
 *   statics used only by process 0
 */
static struct root_info {
    hid_t   hdf_file_id;
    hid_t   grid_gr_id;
    hid_t   features_gr_id;
    hid_t   current_file_dspace_id;
    hid_t   current_file_dset_id;
    hid_t   current_timestep_gr_id;
    int     nx;
    int     ny;
    int     nz;
    int     nxy;
    int     nxyz;
    int     scalar_name_count;       /* 0..proc_info.scalar_count                  chem scalars    */
    char**  scalar_names;            /* proc_info.scalar_count..scalar_name_count  fortran scalars */
    size_t  scalar_name_max_len;
#ifdef USE_MPI
    double* recv_array;
    int     recv_array_count;
#endif
    char    timestep_units[40];
    char    timestep_buffer[120];
    int     active_count;
    int*    active;
    int*    natural_to_active;
    double* f_array;
    int     print_chem;
    int     f_scalar_index;
    int     time_step_scalar_count;
    int*    time_step_scalar_indices;
    int     time_step_count;
    char**  time_steps;
    size_t  time_step_max_len;
    int     vector_name_count;
    char**  vector_names;
    size_t  vector_name_max_len;
} root;

/*
 *   statics used by all processes (including process 0)
 */
static struct proc_info {
    int     cell_count;
    int     cell_index;
    int     scalar_count;  /* chemistry scalar count (doesn't include fortran scalars) */
    int     scalar_index;
    double* array;
} proc;

static int g_hdf_scalar_count;
static char** g_hdf_scalar_names;


static enum HDF_STATE {
    HDF_NORMAL,
    HDF_GET_COUNT,
    HDF_GET_NAMES
} g_hdf_state;


/* string constants */
static const char szTimeSteps[]             = "TimeSteps";
static const char szHDF5Ext[]               = ".h5";
static const char szX[]                     = "X";
static const char szY[]                     = "Y";
static const char szZ[]                     = "Z";
static const char szActive[]                = "Active";
static const char szGrid[]                  = "Grid";
static const char szFeatures[]              = "Features";
static const char szTimeStepFormat[]        = "%.15g %s";
static const char szActiveArray[]           = "ActiveArray";
static const char szScalars[]               = "Scalars";
static const char szVectors[]               = "Vectors";
static const char szVx_node[]               = "Vx_node";
static const char szVy_node[]               = "Vy_node";
static const char szVz_node[]               = "Vz_node";
static const char szVmask[]                 = "Vmask";

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
void HDF_Init(char* prefix, int prefix_l)
{
#ifdef USE_MPI
    extern int mpi_myself;
#else
    const int mpi_myself = 0;
#endif

    if (svnid == NULL) fprintf(stderr," ");
    if (mpi_myself == 0) {
        /* Open the HDF file */
        root.hdf_file_id = open_hdf_file(prefix, prefix_l);
        assert(root.hdf_file_id > 0);

#ifdef USE_MPI
        root.recv_array               = NULL;
        root.recv_array_count         = 0;
        root.f_array                  = NULL;
#endif
        
        root.current_timestep_gr_id   = -1;
        root.current_file_dspace_id   = -1;
        root.current_file_dset_id     = -1;
        root.print_chem               = -1;
        
        root.time_step_scalar_indices = NULL;
        root.scalar_names             = NULL;
        root.scalar_name_count        = 0;
        root.scalar_name_max_len      = 0;

        root.time_steps               = NULL;
        root.time_step_count          = 0;
        root.time_step_max_len        = 0;

        root.vector_names             = NULL;
        root.vector_name_count        = 0;
        root.vector_name_max_len      = 0;
    }

    /* init proc */
    proc.cell_count   = 0;
    proc.cell_index   = 0;
    proc.scalar_count = 0;
    proc.scalar_index = 0;
    proc.array        = NULL;

	/* add callback */
	add_output_callback(hdf_callback, NULL);
}

/*-------------------------------------------------------------------------
 * Function          HDF_Finalize (called by all procs)
 *
 * Preconditions:    TODO:
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
void HDF_Finalize(void)
{
    int i;

#ifdef USE_MPI
    extern int mpi_myself;
#else
    const int mpi_myself = 0;
#endif

    if (mpi_myself == 0) {
        hid_t fls_type;
        herr_t status;

        assert(root.current_file_dspace_id == -1);  /* shouldn't be open */
        assert(root.current_file_dset_id   == -1);  /* shouldn't be open */

        /* create fixed length string type for /Scalar /TimeSteps and /Vectors */	
        fls_type = H5Tcopy(H5T_C_S1);
        if (fls_type <= 0) {
            assert(0);
            sprintf(error_string, "HDF ERROR: Unable to copy H5T_C_S1.\n");
            error_msg(error_string, STOP);
        }
        status = H5Tset_strpad(fls_type, H5T_STR_NULLTERM);
        if (status < 0) {
            assert(0);
            sprintf(error_string, "HDF ERROR: Unable to set size of fixed length string type(size=%d).\n",
                (int)root.scalar_name_max_len);
            error_msg(error_string, STOP);
        }


        if (root.scalar_name_count > 0) {
            hsize_t dims[1];
            hid_t dspace;
            hid_t dset;
            char* scalar_names;

            /*
             * write scalar names to file
             */

            status = H5Tset_size(fls_type, root.scalar_name_max_len);
            if (status < 0) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to set size of fixed length string type(size=%d).\n",
                    (int)root.scalar_name_max_len);
                error_msg(error_string, STOP);
            }

            assert(root.scalar_names != NULL);

            /* create the /Scalars dataspace */
            dims[0] = root.scalar_name_count;
            dspace = H5Screate_simple(1, dims, NULL);
            if (dspace <= 0) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to create the /%s dataset dataspace.\n", szScalars);
                error_msg(error_string, STOP);      
            }
      
            /* create the /Scalars dataset */
            dset = H5Dcreate(root.hdf_file_id, szScalars, fls_type, dspace, H5P_DEFAULT);
            if (dset <= 0 ) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to create the /%s dataset.\n", szScalars);
                error_msg(error_string, STOP);
            }

            /* copy variable length scalar names to fixed length scalar names */
            scalar_names = (char *) PHRQ_calloc(root.scalar_name_max_len * root.scalar_name_count, sizeof(char));
			/* java req'd */
            for (i = 0; i < root.scalar_name_count; ++i) {
                strcpy(scalar_names + i * root.scalar_name_max_len, root.scalar_names[i]);	      
            }

            /* write the /Scalars dataset */
            status = H5Dwrite(dset, fls_type, H5S_ALL, H5S_ALL, H5P_DEFAULT, scalar_names);
            if (status < 0) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to write the /%s dataset.\n", szScalars);
                error_msg(error_string, STOP);
            }

            PHRQ_free(scalar_names);
      
            status = H5Sclose(dspace);
            assert(status >= 0);
      
            status = H5Dclose(dset);
            assert(status >= 0);


            /* free space */
            for (i = 0; i < root.scalar_name_count; ++i) {
                PHRQ_free(root.scalar_names[i]);
            }
            PHRQ_free(root.scalar_names);
            root.scalar_names        = NULL;
            root.scalar_name_count   = 0;
            root.scalar_name_max_len = 0;
        }

        if (root.vector_name_count > 0) {
            hsize_t dims[1];
            hid_t dspace;
            hid_t dset;
            char* vector_names;

            /*
             * write vector names to file
             */
      
            assert(root.vector_name_count == 1);  /* Has a new vector been added? */
            assert(root.vector_names != NULL);

            status = H5Tset_size(fls_type, root.vector_name_max_len);
            if (status < 0) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to set size of fixed length string type(size=%d).\n",
                    (int)root.scalar_name_max_len);
                error_msg(error_string, STOP);
            }


            /* create the /Vectors dataspace */
            dims[0] = root.vector_name_count;
            dspace = H5Screate_simple(1, dims, NULL);
            if (dspace <= 0) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to create the /%s dataset dataspace.\n", szVectors);
                error_msg(error_string, STOP);      
            }

            /* create the /Vectors dataset */
            dset = H5Dcreate(root.hdf_file_id, szVectors, fls_type, dspace, H5P_DEFAULT);
            if (dset <= 0 ) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to create the /%s dataset.\n", szVectors);
                error_msg(error_string, STOP);
            }

            /* copy variable length vectors to fixed length strings */
            vector_names = (char *) PHRQ_calloc(root.vector_name_max_len * root.vector_name_count, sizeof(char));
            for (i = 0; i < root.vector_name_count; ++i) {
                strcpy(vector_names + i * root.vector_name_max_len, root.vector_names[i]);	      
            }

            /* write the /Vectors dataset */
            status = H5Dwrite(dset, fls_type, H5S_ALL, H5S_ALL, H5P_DEFAULT, vector_names);
            if (status < 0) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to write the /%s dataset.\n", szVectors);
                error_msg(error_string, STOP);
            }

            PHRQ_free(vector_names);

            status = H5Sclose(dspace);
            assert(status >= 0);

            status = H5Dclose(dset);
            assert(status >= 0);

            /* free space */
            for (i = 0; i < root.vector_name_count; ++i) {
                PHRQ_free(root.vector_names[i]);
            }
            PHRQ_free(root.vector_names);
            root.vector_names        = NULL;
            root.vector_name_count   = 0;
            root.vector_name_max_len = 0;
        }

        if (root.time_step_count > 0) {
            hsize_t dims[1];
            hid_t dspace;
            hid_t dset;
            char* time_steps;

            /*
             * write time step names to file
             */

            status = H5Tset_size(fls_type, root.time_step_max_len);
            if (status < 0) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to set size of fixed length string type(size=%d).\n",
                    (int)root.time_step_max_len);
                error_msg(error_string, STOP);
            }

            assert(root.time_steps != NULL);

            /* create the /TimeSteps (szTimeSteps) dataspace */
            dims[0] = root.time_step_count;
            dspace = H5Screate_simple(1, dims, NULL);
            if (dspace <= 0) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to create the /%s dataset dataspace.\n", szTimeSteps);
                error_msg(error_string, STOP);      
            }

            /* create the /TimeSteps (szTimeSteps) dataset */
            dset = H5Dcreate(root.hdf_file_id, szTimeSteps, fls_type, dspace, H5P_DEFAULT);
            if (dset <= 0 ) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to create the /%s dataset.\n", szTimeSteps);
                error_msg(error_string, STOP);
            }

            /* copy variable length time steps to fixed length strings */
            time_steps = (char *) PHRQ_calloc(root.time_step_max_len * root.time_step_count, sizeof(char));
            for (i = 0; i < root.time_step_count; ++i) {
                strcpy(time_steps + i * root.time_step_max_len, root.time_steps[i]);	      
            }

            /* write the /TimeSteps (szTimeSteps) dataset */
            status = H5Dwrite(dset, fls_type, H5S_ALL, H5S_ALL, H5P_DEFAULT, time_steps);
            if (status < 0) {
                assert(0);
                sprintf(error_string, "HDF ERROR: Unable to write the /%s dataset.\n", szTimeSteps);
                error_msg(error_string, STOP);
            }

            PHRQ_free(time_steps);

            status = H5Sclose(dspace);
            assert(status >= 0);
      
            status = H5Dclose(dset);
            assert(status >= 0);

            /* free space */
            for (i = 0; i < root.time_step_count; ++i) {
                PHRQ_free(root.time_steps[i]);
            }
            PHRQ_free(root.time_steps);
            root.time_steps        = NULL;
            root.time_step_count   = 0;
            root.time_step_max_len = 0;
        }

        /* close the fixed lenght string type */
        status = H5Tclose(fls_type);
        assert(status >= 0);      
    
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
    }

    /* free proc resources */
    PHRQ_free(proc.array);
    proc.cell_count   = 0;
    proc.cell_index   = 0;
    proc.scalar_count = 0;
    proc.scalar_index = 0;
    proc.array        = NULL;
}


/*-------------------------------------------------------------------------
 * Function          open_hdf_file
 *
 * Preconditions:    TODO:
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
static hid_t open_hdf_file(char* prefix, int prefix_l)
{
#ifdef USE_MPI
    extern int mpi_myself;
    extern int mpi_tasks;
#else
    const int mpi_myself = 0;
    const int mpi_tasks  = 1;
#endif
    hid_t file_id;
    char hdf_prefix[120];
    char hdf_file_name[120];
    char hdf_backup_name[120];
    
    strncpy(hdf_prefix, prefix, prefix_l);
    hdf_prefix[prefix_l] = '\0';
    string_trim(hdf_prefix);  
    if (mpi_tasks == 1) {
        sprintf(hdf_file_name, "%s%s", hdf_prefix, szHDF5Ext);    
    }
    else {
        sprintf(hdf_file_name, "%s%s", hdf_prefix, szHDF5Ext);
    }
    
    if (mpi_myself == 0) {
        if (file_exists(hdf_file_name)) {
            sprintf(hdf_backup_name, "%s%s~", hdf_prefix, szHDF5Ext);
            if (file_exists(hdf_backup_name)) remove(hdf_backup_name);
            rename(hdf_file_name, hdf_backup_name);
        }
    }
    
    file_id = H5Fcreate(hdf_file_name, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
    if (file_id <= 0) {
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
void HDF_INIT_INVARIANT(void)
{
#ifndef NDEBUG
#ifdef USE_MPI
    extern int mpi_myself;
#else
    const int mpi_myself = 0;
#endif
#endif
    assert(mpi_myself == 0);

    /*
     * Create the "/Grid" group
     */
    assert(root.hdf_file_id > 0);  /* precondition */
    root.grid_gr_id = H5Gcreate(root.hdf_file_id, szGrid, 0);
    if (root.grid_gr_id <= 0) {
        sprintf(error_string, "Unable to create /%s group\n", szGrid);
        error_msg(error_string, STOP);
    }
  
    /*
     * Create the "/szFeatures" group
     */
    root.features_gr_id = H5Gcreate(root.hdf_file_id, szFeatures, 0);
    if (root.grid_gr_id <= 0) {
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
void HDF_FINALIZE_INVARIANT(void)
{
    herr_t status;
#ifdef USE_MPI
#ifndef NDEBUG
    extern int mpi_myself;
    assert(mpi_myself == 0);
#endif
#endif

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
void HDF_WRITE_GRID(double x[], double y[], double z[],
                    int *nx, int *ny, int *nz,
                    int ibc[], char* UTULBL, int UTULBL_l)
{
#ifdef USE_MPI
    extern int mpi_myself;
#else
    const int mpi_myself = 0;
#endif

#ifndef NDEBUG
    /*    fprintf(stdout, "In HDF_WRITE_GRID\n"); */
#endif

    if (mpi_myself == 0) {
        int i;

    
        /* copy and trim time units */
        strncpy(root.timestep_units, UTULBL, UTULBL_l);
        root.timestep_units[UTULBL_l] = '\0';
        string_trim(root.timestep_units);
    
        assert(root.grid_gr_id > 0); /* precondition */
    
        write_axis(root.grid_gr_id, x, *nx, szX);
        write_axis(root.grid_gr_id, y, *ny, szY);
        write_axis(root.grid_gr_id, z, *nz, szZ);
    
        root.nx   = *nx;
        root.ny   = *ny;
        root.nz   = *nz;
        root.nxy  = root.nx * root.ny;
        root.nxyz = root.nxy * root.nz;
    
        assert(root.active_count == 0);
        assert(root.natural_to_active == NULL);
    
        root.natural_to_active = (int*)PHRQ_malloc(sizeof(int) * root.nxyz);
        if (root.natural_to_active == NULL) malloc_error();
    
        root.active = (int*)PHRQ_malloc(sizeof(int) * root.nxyz);
        if (root.active == NULL) malloc_error();
    
        root.active_count = 0;
        for (i = 0; i < root.nxyz; ++i) {
            if (ibc[i] >= 0) {
                root.natural_to_active[i] = root.active_count;
                root.active[root.active_count] = i;
                ++root.active_count;
            }
            else {
                root.natural_to_active[i] = -1;
            }
        }
	if (root.active_count <= 0) {
		error_msg("No active cells in model.", STOP);
	}
#ifndef NDEBUG
        /*      fprintf(stdout, "In HDF_WRITE_GRID root.active_count = %d\n", root.active_count); */
#endif

        /* allocate space for fortran scalars */
        assert(root.f_array == NULL);
        root.f_array = (double *) PHRQ_malloc(sizeof(double) * root.active_count);
        if (root.f_array == NULL) malloc_error();
        
        if (root.active_count != root.nxyz) { /* Don't write if all are active */
            hsize_t dims[2], maxdims[2];
            hid_t dspace_id;
            hid_t dset_id;
            herr_t status;
      
            /* Create the "/Grid/Active" dataspace. */
            dims[0] = maxdims[0] = root.active_count;
            dspace_id = H5Screate_simple(1, dims, maxdims);
            assert(dspace_id > 0);
      
            /* Create the "/Grid/Active" dataset */
            dset_id = H5Dcreate(root.grid_gr_id, szActive, H5T_NATIVE_INT, dspace_id, H5P_DEFAULT);
            assert(dset_id > 0);
      
            /* Write the "/Grid/Active" dataset */
            if (H5Dwrite(dset_id, H5T_NATIVE_INT, dspace_id, H5S_ALL, H5P_DEFAULT, root.active) < 0) {
                printf("HDF Error: Unable to write \"/%s/%s\" dataset\n", szGrid, szActive);
            }
      
            /* Close the "/Grid/Active" dataset */
            status = H5Dclose(dset_id);
            assert(status >= 0);
      
            /* Close the "/Grid/Active" dataspace */
            status = H5Sclose(dspace_id);
            assert(status >= 0);
        }
    
        proc.scalar_count = get_c_scalar_count(0, NULL);
        assert(root.scalar_names == NULL);
    }

#ifdef USE_MPI
    /* send scalar_count to all procs */
    MPI_Bcast(&proc.scalar_count, 1, MPI_INT, 0, MPI_COMM_WORLD);
#endif
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
static void write_axis(hid_t loc_id, double* a, int na, const char* name)
{
    hsize_t dims[1], maxdims[1];
    hid_t dspace_id;
    hid_t dset_id;
    herr_t status;
  
    if (!(na > 0)) return;
  
    /* Create the "/Grid/name" dataspace. */
    dims[0] = maxdims[0] = na;
    dspace_id = H5Screate_simple(1, dims, maxdims);
    
    /* Create the "/Grid/name" dataset */
    dset_id = H5Dcreate(loc_id, name, H5T_NATIVE_FLOAT, dspace_id, H5P_DEFAULT);
    
    /* Write the "/Grid/name" dataset */
    if (H5Dwrite(dset_id, H5T_NATIVE_DOUBLE, dspace_id, H5S_ALL, H5P_DEFAULT, a) < 0) {
        sprintf(error_string, "HDF Error: Unable to write \"/%s/%s\" dataset\n", szGrid, name);
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
void HDF_WRITE_FEATURE(char* feature_name, int* nodes1, int* node_count, int feature_name_l)
{
#ifndef NDEBUG
#ifdef USE_MPI
    extern int mpi_myself;
#else
    const int mpi_myself = 0;
#endif
#endif

    char feature_name_copy[120];
    int i;
    hsize_t dims[1], maxdims[1];
    hid_t dspace_id;
    hid_t dset_id;
    herr_t status;
    int* nodes0;

    assert(mpi_myself == 0);
  
    if (*node_count == 0) {
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
    dset_id = H5Dcreate(root.features_gr_id, feature_name_copy, H5T_NATIVE_INT, dspace_id, H5P_DEFAULT);
  
    /* Convert from 1-based to 0-based */
    nodes0 = (int*)PHRQ_malloc(sizeof(int) * (*node_count));
    if (nodes0 == NULL) malloc_error();  
    for (i = 0; i < *node_count; ++i) {
        nodes0[i] = nodes1[i] - 1;
    }
  
    /* Write the "/szFeatures/feature_name" dataset. */
    if (H5Dwrite(dset_id, H5T_NATIVE_INT, dspace_id, H5S_ALL, H5P_DEFAULT, nodes0) < 0) {
        printf("HDF Error: Unable to write \"/%s/%s\" dataset.\n", szFeatures, feature_name_copy);
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
void HDF_OPEN_TIME_STEP(double* time, double* cnvtmi, int* print_chem, int* print_vel, int* f_scalar_count)
{
    hsize_t dims[1];
    int i;
    size_t len;

#ifdef USE_MPI
    /*    extern int mpi_myself; */
#else
    /*    const int mpi_myself = 0; */
#endif

    /*    assert(mpi_myself == 0); */                  /* should only be called by proc 0 */
    assert(root.current_timestep_gr_id == -1);  /* shouldn't be open yet */  
    assert(root.current_file_dset_id   == -1);  /* shouldn't be open yet */
    assert(root.current_file_dspace_id == -1);  /* shouldn't be open yet */

    if (root.print_chem == -1) {
        /* first call */
        assert(root.scalar_names == NULL);
        assert(proc.scalar_count == get_c_scalar_count(0, NULL));
        /* load chemistry scalar names */
        if (proc.scalar_count > 0) {
            root.scalar_names = (char **) PHRQ_malloc(sizeof(char*) * proc.scalar_count);
            if (root.scalar_names == NULL) malloc_error();
            get_c_scalar_count(1, root.scalar_names);
            for (i = 0; i < proc.scalar_count; ++i) {
                size_t len = strlen(root.scalar_names[i]) + 1;
                if (root.scalar_name_max_len < len) root.scalar_name_max_len = len;
            }
        }
        root.scalar_name_count = proc.scalar_count;
    }

    /* determine scalar count for this timestep */
    root.print_chem = (*print_chem);
    root.time_step_scalar_count = (root.print_chem ? proc.scalar_count : 0) + (*f_scalar_count);
    if (root.time_step_scalar_count == 0 && *print_vel == 0) {
        return; /* no hdf scalar or vector output for this time step */
    }

    /* format timestep string */
    sprintf(root.timestep_buffer, szTimeStepFormat, (*time) * (*cnvtmi), root.timestep_units);

    /* add time step string to list */
    root.time_steps = (char **) PHRQ_realloc(root.time_steps, sizeof(char*) * (root.time_step_count + 1));
    if (root.time_steps == NULL) malloc_error();
    len = strlen(root.timestep_buffer) + 1;
    if (root.time_step_max_len < len) root.time_step_max_len = len;
    root.time_steps[root.time_step_count] = (char *) PHRQ_malloc(len);
    if (root.time_steps[root.time_step_count] == NULL) malloc_error();
    strcpy(root.time_steps[root.time_step_count], root.timestep_buffer);
    ++root.time_step_count;

    /* Create the /<timestep string> group */
    assert(root.timestep_buffer && strlen(root.timestep_buffer));
    root.current_timestep_gr_id = H5Gcreate(root.hdf_file_id, root.timestep_buffer, 0);
    if (root.current_timestep_gr_id < 0) {
        assert(0);
        sprintf(error_string, "HDF ERROR: Unable to create group /%s\n", root.timestep_buffer);      
        error_msg(error_string, STOP);
    }

    if (root.time_step_scalar_count != 0) {

        /* allocate space for time step scalar indices */
        assert(root.time_step_scalar_indices == NULL);
        root.time_step_scalar_indices = (int *) PHRQ_malloc(sizeof(int) * root.time_step_scalar_count);
        if (root.time_step_scalar_indices == NULL) malloc_error();

        /* add cscalar indices (fortran indices are added one by one in PRNARR_HDF) */
        if (root.print_chem) {
            for (i = 0; i < proc.scalar_count; ++i) {
                root.time_step_scalar_indices[i] = i;
            }
        }

        /* Create the "/<timestep string>/ActiveArray" file dataspace. */
        dims[0] = root.active_count * root.time_step_scalar_count;
        root.current_file_dspace_id = H5Screate_simple(1, dims, NULL);
        if (root.current_file_dspace_id < 0) {
            assert(0);
            sprintf(error_string, "HDF ERROR: Unable to create dataspace(DIM=%d) for /%s/%s\n", (int)dims[0], root.timestep_buffer, szActiveArray);
            error_msg(error_string, STOP);
        }

        /* Create the "/<timestep string>/ActiveArray" dataset */
        root.current_file_dset_id = H5Dcreate(root.current_timestep_gr_id, szActiveArray, H5T_NATIVE_FLOAT, root.current_file_dspace_id, H5P_DEFAULT);
        if (root.current_file_dset_id < 0) {
            assert(0);
            sprintf(error_string, "HDF ERROR: Unable to create dataset /%s/%s\n", root.timestep_buffer, szActiveArray);      
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
void HDF_CLOSE_TIME_STEP(void)
{
    herr_t status;
#ifdef USE_MPI
    /*extern int mpi_myself;*/
#else
    /*const int mpi_myself = 0;*/
#endif

    /*assert(mpi_myself == 0);*/ /* should only be called by proc 0 */
 
    if (root.current_file_dset_id > 0) {
        status = H5Dclose(root.current_file_dset_id);
        assert(status >= 0);
    }
    root.current_file_dset_id = -1;
  
    if (root.current_file_dspace_id > 0) {
        status = H5Sclose(root.current_file_dspace_id);
        assert(status >= 0);
    }
    root.current_file_dspace_id = -1;

    if (root.time_step_scalar_count > 0) {
        /* write the scalar indices for this timestep */
        hsize_t dims[1];
        hid_t dspace, dset;
        herr_t status;
    
        dims[0] = root.time_step_scalar_count;
        dspace = H5Screate_simple(1, dims, NULL);
        if (dspace <= 0) {
            assert(0);
            sprintf(error_string, "HDF ERROR: Unable to create file dataspace(DIM(%d)) for dataset /%s/%s\n",
                    (int)dims[0], root.timestep_buffer, szScalars);      
            error_msg(error_string, STOP);      
        }
        dset = H5Dcreate(root.current_timestep_gr_id, szScalars, H5T_NATIVE_INT, dspace, H5P_DEFAULT);
        if (dset <= 0) {
            assert(0);
            sprintf(error_string, "HDF ERROR: Unable to create dataset /%s/%s\n", root.timestep_buffer, szScalars);
            error_msg(error_string, STOP);
        }
        status = H5Dwrite(dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, root.time_step_scalar_indices);
        if (status < 0) {
            assert(0);
            sprintf(error_string, "HDF ERROR: Unable to write dataset /%s/%s\n", root.timestep_buffer, szScalars);
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
    if (root.current_timestep_gr_id > 0) {
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
void HDFBeginCTimeStep(void)
{
#ifdef USE_MPI
    extern int end_cells[MPI_MAX_TASKS][2];
    extern int* random_list;
    extern int mpi_myself;

    int* ptr_begin;
    int* ptr_end;
#endif

    int i;
    int array_count;

    if (proc.scalar_count == 0) return;

#ifdef USE_MPI
    assert(count_back_list == 1 || count_back_list == 2 || count_back_list == 4);
    /* determine how many cells we're going to be doing */
    ptr_begin  = &(random_list[end_cells[mpi_myself][0]]);
    ptr_end    = &(random_list[end_cells[mpi_myself][1]]);
    proc.cell_count = ptr_end - ptr_begin + 1;
#else
    proc.cell_count = count_chem;
#endif
  
    /* allocate space for this time step */
    assert(proc.cell_count > 0);
    assert(proc.scalar_count > 0);
    array_count = proc.cell_count * proc.scalar_count;
    proc.array = (double *)PHRQ_realloc(proc.array,  sizeof(double) * array_count);
    if (proc.array == NULL) malloc_error();
  
    /* init entire array to inactive */
    for (i = 0; i < array_count; ++i) {
        proc.array[i] = INACTIVE_CELL_VALUE;
    }

    /* init indices */
    proc.cell_index   = -1;
    proc.scalar_index = 0;
}

/*-------------------------------------------------------------------------
 * Function:         HDFSetCell   (called by all procs)
 *
 * Purpose:          TODO
 *
 * Preconditions:    TODO
 *
 * Postconditions:   TODO
 *-------------------------------------------------------------------------
 */
void HDFSetCell(const int n) /* n is the natural cell number */
{
    /* reset scalar_index */
    proc.scalar_index = 0;

    /* increment timestep cell_index */
    ++proc.cell_index;
    /*
    proc.cell_index
        SERIAL  =>  [0..count_chem)
        MPI     =>  [0..&(random_list[end_cells[rank][1]]) - &(random_list[end_cells[rank][0]]) + 1)
            or the current position in sort_random_list
    */

    if (proc.cell_count == 0) return;

    assert(proc.cell_index >= 0);    /* if (cell_index == 0) than this is
                                        the first call after HDFBeginCTimeStep */
    assert(proc.cell_index < proc.cell_count);


#ifndef NDEBUG
#ifdef USE_MPI
    {
        extern int end_cells[MPI_MAX_TASKS][2];
        extern int* random_list;
        extern int mpi_myself;
        extern int int_compare(const void*, const void*);
        int* sort_random_list;
        int* ptr_begin;
        int* ptr_end;

        /* verify cell_count */
        ptr_begin  = &(random_list[end_cells[mpi_myself][0]]);
        ptr_end    = &(random_list[end_cells[mpi_myself][1]]);
        assert(proc.cell_count == ptr_end - ptr_begin + 1);

        /* verify n (natural cell index) */
        sort_random_list = (int*) PHRQ_malloc((size_t) (proc.cell_count) * sizeof(int));
        if (sort_random_list == NULL) malloc_error();
        memcpy(sort_random_list, &random_list[end_cells[mpi_myself][0]], sizeof(int) * proc.cell_count);
        qsort (sort_random_list, (size_t) (proc.cell_count), sizeof(int), int_compare);
        assert(n == back[sort_random_list[proc.cell_index]].list[0]);

        PHRQ_free(sort_random_list);
    }
#else
    {
        assert(n == back[proc.cell_index].list[0]);
    }
#endif
#endif
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
void HDFEndCTimeStep(void)
{
#ifdef USE_MPI
    const int TAG_HDF_DATA = 5;
    extern int mpi_myself;
    extern int mpi_tasks;
    int task_number;
#else
    const int mpi_myself = 0;
#endif

    if (proc.cell_count == 0) return;  /* nothing to do */

    if (mpi_myself == 0) {
        assert(root.current_file_dspace_id > 0);  /* precondition */
        assert(root.current_file_dset_id   > 0);  /* precondition */

        /* write proc 0 data */
        write_proc_timestep(mpi_myself, proc.cell_count, root.current_file_dspace_id, root.current_file_dset_id, proc.array);    
    }

#ifdef USE_MPI
    for (task_number = 1; task_number < mpi_tasks; ++task_number) {
        int array_count;
        if (mpi_myself == task_number) {
            MPI_Send(&mpi_myself,                     1, MPI_INT,                 0, TAG_HDF_DATA, MPI_COMM_WORLD);
            MPI_Send(&proc.cell_count,                1, MPI_INT,                 0, TAG_HDF_DATA, MPI_COMM_WORLD);

            array_count = proc.cell_count * proc.scalar_count;
            MPI_Send((void*)proc.array,     array_count, MPI_DOUBLE,              0, TAG_HDF_DATA, MPI_COMM_WORLD);
        }
        if (mpi_myself == 0) {
            MPI_Status mpi_status;
            int cell_count;
            int rank;

            MPI_Recv(&rank,                           1, MPI_INT,    MPI_ANY_SOURCE, TAG_HDF_DATA, MPI_COMM_WORLD, &mpi_status);
            MPI_Recv(&cell_count,                     1, MPI_INT,              rank, TAG_HDF_DATA, MPI_COMM_WORLD, &mpi_status);

            array_count = cell_count * proc.scalar_count;
            if (root.recv_array_count <  array_count) {
                root.recv_array = (double *) PHRQ_realloc(root.recv_array, sizeof(double) * array_count);
                if (root.recv_array == NULL) malloc_error();
                root.recv_array_count = array_count;
            }
            MPI_Recv((void*)root.recv_array, array_count, MPI_DOUBLE,          rank, TAG_HDF_DATA, MPI_COMM_WORLD, &mpi_status);
            if (1 /* mpi_status bOK */) {
                write_proc_timestep(rank, cell_count, root.current_file_dspace_id, root.current_file_dset_id, root.recv_array);    
            }
        }
    }  
#endif
}

/*-------------------------------------------------------------------------
 * Function          write_proc_timestep
 *
 * Preconditions:    Called only by proc 0 (for each proc including 0)
 *
 * Postconditions:   Timestep for the process(rank) is written to HDF
 *-------------------------------------------------------------------------
 */
static void write_proc_timestep(int rank, int cell_count, hid_t file_dspace_id, hid_t dset_id, double* array)
{
#ifdef USE_MPI
    extern int end_cells[MPI_MAX_TASKS][2];
    extern int* random_list;
    extern int int_compare(const void*, const void*);
    int* sort_random_list;
#else
    /*extern int count_chem;*/
#endif

    hssize_t (*coor)[1];
    hid_t mem_dspace;
    herr_t status;
    hsize_t dims[1];
    int i, j, n;

    /* create the memory dataspace */
    dims[0] = cell_count * proc.scalar_count;
    assert(dims[0] > 0);
    mem_dspace = H5Screate_simple(1, dims, NULL);
    if (mem_dspace < 0) {
        sprintf(error_string, "HDF ERROR: Unable to create memory dataspace for process %d\n", rank);
        error_msg(error_string, STOP);
    }

    /* allocate coordinates for file dataspace selection */
    coor = (hssize_t (*)[1]) PHRQ_malloc(sizeof(hssize_t[1]) * cell_count * proc.scalar_count);
    if (coor == NULL) malloc_error();
  
#ifndef USE_MPI
    /* Non-MPI */
    /*assert(cell_count == count_chem);*/

    /*
     * make the file dataspace selection
     */  
    for (n = 0; n < count_back_list; ++n) {
        for (j = 0; j < proc.scalar_count; ++j) {
            for (i = 0; i < cell_count; ++i) {
                coor[i + j * cell_count][0] = root.natural_to_active[back[i].list[n]] + j * root.active_count;
            }
        }
    
        /* make the independent points selection for the file dataspace */
        status = H5Sselect_elements(file_dspace_id, H5S_SELECT_SET, cell_count * proc.scalar_count, (const hssize_t**) coor);
        assert(status >= 0);
    
        status = H5Dwrite(dset_id, H5T_NATIVE_DOUBLE, mem_dspace, file_dspace_id, H5P_DEFAULT, array);
        if (status <  0) {
            sprintf(error_string, "HDF ERROR: Unable to write dataspace\n");
            error_msg(error_string, STOP);    
        }
    }
#else
    /* MPI */  
    assert(cell_count == &(random_list[end_cells[rank][1]]) - &(random_list[end_cells[rank][0]]) + 1);
  
    /* sort random list for this proc (to be used for element selection */
    sort_random_list = (int*) PHRQ_malloc((size_t) (cell_count) * sizeof(int));
    if (sort_random_list == NULL) malloc_error();
    memcpy(sort_random_list, &random_list[end_cells[rank][0]], sizeof(int) * cell_count);
    qsort (sort_random_list, (size_t) (cell_count), sizeof(int), int_compare);
  
    /*
     * make the file dataspace selection
     */
    for (n = 0; n < count_back_list; ++n) {
        for (j = 0; j < proc.scalar_count; ++j) {
            for (i = 0; i < cell_count; ++i) {
                coor[i + j * cell_count][0] = root.natural_to_active[back[sort_random_list[i]].list[n]] + j * root.active_count;
            }
        }

        /* make the independent points selection for the file dataspace */
        status = H5Sselect_elements(file_dspace_id, H5S_SELECT_SET, cell_count * proc.scalar_count, (const hssize_t**) coor);
        assert(status >= 0);

        status = H5Dwrite(dset_id, H5T_NATIVE_DOUBLE, mem_dspace, file_dspace_id, H5P_DEFAULT, array);
        if (status <  0) {
            sprintf(error_string, "HDF ERROR: Unable to write dataspace for process %d\n", rank);
            error_msg(error_string, STOP);    
        }
    }
    PHRQ_free(sort_random_list);
#endif

    PHRQ_free(coor);

    status = H5Sclose(mem_dspace);
    assert(status >= 0);
}

/*-------------------------------------------------------------------------
 * Function          get_c_scalar_count
 * 
 * NOTE: May want to rewrite this and call it punch_all_hdf
 *
 * Preconditions:    TODO:
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
static int get_c_scalar_count(int load_names, char** names)
{
	/*FILE* save_punch_file;*/
    int prhdf, prpunch;

    g_hdf_scalar_count = 0;
    /*
    save_punch_file = punch_file;
    punch_file = NULL;
    */
    prpunch = pr.punch;
    pr.punch = FALSE;
    prhdf = pr.hdf;
    pr.hdf = TRUE;
    if (load_names) {
        g_hdf_state = HDF_GET_NAMES;
        assert(names != NULL);
        g_hdf_scalar_names = names;
    }
    else {
        g_hdf_state = HDF_GET_COUNT;
    }

    punch_all();
    /* punch_file = save_punch_file; */
    g_hdf_state = HDF_NORMAL;
    pr.hdf = prhdf;
    pr.punch = prpunch;
    return g_hdf_scalar_count;
}

/*-------------------------------------------------------------------------
 * Function          HDFWriteHyperSlabV
 *
 * Preconditions:    HDFBeginTimeStep has been called
 *
 * Postconditions:   TODO:
 *-------------------------------------------------------------------------
 */
void HDFWriteHyperSlabV(const char* name, const char* format, va_list argptr)
{
#ifndef NDEBUG
#ifdef USE_MPI
    extern int mpi_myself;
#else
    const int mpi_myself = 0;
#endif
#endif
    int bWrite;
    int state;
    int bLongDouble;
    char ch;
    double value;
  
    /* state values
       0 Haven't found start(%)
       1 Just read start(%)
       2 Just read Flags(-0+ #) (zero or more)
       3 Just read Width
       4 Just read Precision start (.)
       5 Just read Size modifier
       6 Just read Type
    */
  
    if (name == NULL) return;
  
    bWrite = 0;
    bLongDouble = 0;
    state = 0;
    ch = *format++;
    while (ch != '\0') {
        switch (state) {
            case 0: /* looking for Start specification (%) */
                switch (ch) {
                    case '%':
                        state = 1;
                        break;
                    default:
                        break;
                }
                ch = *format++;
                break;
            case 1: /* reading Flags (zero or more(-,+,0,# or space)) */
                switch (ch) {
                    case '-': case '0': case '+': case ' ': case '#':
                        ch = *format++;
                        break;
                    default:
                        state = 2;
                        break;
                }
                break;
            case 2: /* reading Minimum field width (decimal integer constant) */
                switch (ch) {
                    case '.':
                        state = 3;
                        ch = *format++;
                        break;
                    case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
                        ch = *format++;
                        break;
                    default:
                        state = 4;
                        break;
                }
                break;
            case 3: /* reading Precision specification (period already read) */
                switch (ch)
                {
                    case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
                        ch = *format++;
                        break;
                    default:
                        state = 4;
                        break;
                }
                break;
            case 4: /* reading Size modifier */
                switch (ch)
                {
                    case 'l':
                        ch = *format++;
                        break;
                    case 'L':
                        bLongDouble = 1;
                        ch = *format++;
                        break;
                    case 'h':
                        ch = *format++;
                        break;
                }
                state = 5;
                break;
            case 5: /* reading Conversion letter */
                switch (ch) {
                    case 'c':
                    case 'd':
                    case 'i':
                    case 'n':
                    case 'o':
                    case 'p':
                    case 's':
                    case 'u':
                    case 'x':
                    case 'X':
                    case '%':
                        break;
                    case 'f':
                    case 'e':
                    case 'E':
                    case 'g':
                    case 'G':
                        bWrite = 1;
                        break;
                    default:
                        assert(0);
                        break;
                }
                ch = '\0';  /* done */
                break;
        }
    }

    if (bWrite) {

        switch (g_hdf_state) {
            case HDF_GET_COUNT:
                ++g_hdf_scalar_count;
                return;
                break;
            case HDF_GET_NAMES:
                g_hdf_scalar_names[g_hdf_scalar_count] = (char *) PHRQ_malloc(strlen(name) + 1);
                if (g_hdf_scalar_names[g_hdf_scalar_count] == NULL) malloc_error();
                strcpy(g_hdf_scalar_names[g_hdf_scalar_count], name);
                ++g_hdf_scalar_count;
                return;
                break;
            case HDF_NORMAL:
                /* keep going */
                break;
        }
        assert(pr.hdf == TRUE);   /* should not be called */
        if (bLongDouble) {
            value = (double)va_arg(argptr, long double);
        }
        else {
            value = va_arg(argptr, double);
        }

        assert(proc.array != NULL); /* Has HDFBeginCTimeStep been called? */
    
        /* validate scalar_index */
        assert(proc.scalar_index >= 0);
        assert(proc.scalar_index < proc.scalar_count);

#ifndef NDEBUG
        if (mpi_myself == 0) {
            /* verify scalar_count */
            assert(root.time_step_scalar_count > 0);

            /* verify scalar name */
            if (strcmp(name, root.scalar_names[proc.scalar_index]) != 0) {
                output_msg(OUTPUT_STDERR, "name = \"%s\", root.scalar_names[%d] = \"%s\"\n", name, proc.scalar_index, root.scalar_names[proc.scalar_index]);
            }
            assert(strcmp(name, root.scalar_names[proc.scalar_index]) == 0);
        }
#endif
    
        /* store value */    
        assert(proc.array[proc.scalar_index * proc.cell_count + proc.cell_index] == (double)INACTIVE_CELL_VALUE);
        proc.array[proc.scalar_index * proc.cell_count + proc.cell_index] = value;

        /* increment */
        ++proc.scalar_index;
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
void PRNTAR_HDF(double array[], double frac[], double* cnv, char* name, int name_l)
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
    for (i = proc.scalar_count; i < root.scalar_name_count; ++i) {
        if (strcmp(root.scalar_names[i], name_buffer) == 0) break;
    }
    if (i == root.scalar_name_count) {
        /* new scalar name */
        size_t len = strlen(name_buffer) + 1;
        if (root.scalar_name_max_len < len) root.scalar_name_max_len = len;
        root.scalar_names = (char **) PHRQ_realloc(root.scalar_names, sizeof(char*) * (root.scalar_name_count + 1));
        if (root.scalar_names == NULL) malloc_error();
        root.scalar_names[root.scalar_name_count] = (char *) PHRQ_malloc(strlen(name_buffer) + 1);
        if (root.scalar_names[root.scalar_name_count] == NULL) malloc_error();
        strcpy(root.scalar_names[root.scalar_name_count], name_buffer);
        ++root.scalar_name_count;
    }

    /* add this scalar index to the list of scalar indices */
    assert(((root.print_chem ? proc.scalar_count : 0) + root.f_scalar_index) < root.time_step_scalar_count);
    root.time_step_scalar_indices[(root.print_chem ? proc.scalar_count : 0) + root.f_scalar_index] = i;

    /* copy the fortran scalar array into the active scalar array (f_array) */
    assert(root.f_array != NULL);
    assert(root.active_count > 0);
    for (i = 0; i < root.active_count; ++i) {
        assert(root.active[i] >= 0 && root.active[i] < root.nxyz);
        if (frac[root.active[i]] <= 0.0001) {
            root.f_array[i] = INACTIVE_CELL_VALUE;
        }
        else {
            root.f_array[i] = array[root.active[i]] * (*cnv);
        }
    }

    /* create the memory dataspace */
    dims[0] = root.active_count;
    mem_dspace = H5Screate_simple(1, dims, NULL);
    if (mem_dspace <= 0) {
        assert(0);
        sprintf(error_string, "HDF Error: Unable to create memory dataspace\n");
        error_msg(error_string, STOP);
    }

    /* select within the file dataspace the hyperslab to write to */

    start[0] = (root.f_scalar_index + (root.print_chem ? proc.scalar_count : 0)) * root.active_count;
    count[0] = root.active_count;

    assert(root.current_file_dspace_id > 0);     /* precondition */
    status = H5Sselect_hyperslab(root.current_file_dspace_id, H5S_SELECT_SET, start, NULL, count, NULL);
    assert(status >= 0);

    /* Write the "/<timestep>/ActiveArray" dataset selection for this scalar */
    assert(root.current_file_dset_id > 0);       /* precondition */
    if (H5Dwrite(root.current_file_dset_id, H5T_NATIVE_DOUBLE, mem_dspace, root.current_file_dspace_id, H5P_DEFAULT, root.f_array) < 0) {
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
void HDF_VEL(double vx_node[], double vy_node[], double vz_node[], int vmask[])
{
    int i;
    const char name[] = "Velocities";

    /* check if the vector "Velocities" has been added to root.vector_names yet */
    for (i = 0; i < root.vector_name_count; ++i)
    {
        if (strcmp(root.vector_names[i], name) == 0) break;
    }
    if (i == root.vector_name_count)
    {
        /* new scalar name */
        size_t len = strlen(name) + 1;
        root.vector_names = (char **) PHRQ_realloc(root.vector_names, sizeof(char*) * (root.vector_name_count + 1));
        if (root.vector_names == NULL) malloc_error();
        if (root.vector_name_max_len < len) root.vector_name_max_len = len;
        root.vector_names[root.vector_name_count] = (char *) PHRQ_malloc(len);
        if (root.vector_names[root.vector_name_count] == NULL) malloc_error();
        strcpy(root.vector_names[root.vector_name_count], name);
        ++root.vector_name_count;
    }
    assert(root.vector_name_count == 1);  /* Has a new vector been added? */


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
static void write_vector(hid_t loc_id, double a[], int na, const char* name)
{
    hsize_t dims[1];
    hid_t dspace_id;
    hid_t dset_id;
    herr_t status;
  
    if (na <= 0) return;
  
    /* Create the "/<timestep string>/name" dataspace. */
    dims[0] = na;
    dspace_id = H5Screate_simple(1, dims, NULL);
  
    /* Create the "/<timestep string>/name" dataset */
    dset_id = H5Dcreate(loc_id, name, H5T_NATIVE_FLOAT, dspace_id, H5P_DEFAULT);
  
    /* Write the "/<timestep string>/name" dataset */
    if (H5Dwrite(dset_id, H5T_NATIVE_DOUBLE, dspace_id, H5S_ALL, H5P_DEFAULT, a) < 0) {
        sprintf(error_string, "HDF Error: Unable to write \"/%s/%s\" dataset\n", root.timestep_buffer, name);
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
static void write_vector_mask(hid_t loc_id, int a[], int na, const char* name)
{
    hsize_t dims[1];
    hid_t dspace_id;
    hid_t dset_id;
    herr_t status;
  
    if (na <= 0) return;
  
    /* Create the "/<timestep string>/name" dataspace. */
    dims[0] = na;
    dspace_id = H5Screate_simple(1, dims, NULL);
  
    /* Create the "/<timestep string>/name" dataset */
    dset_id = H5Dcreate(loc_id, name, H5T_NATIVE_INT, dspace_id, H5P_DEFAULT);
  
    /* Write the "/<timestep string>/name" dataset */
    if (H5Dwrite(dset_id, H5T_NATIVE_INT, dspace_id, H5S_ALL, H5P_DEFAULT, a) < 0) {
        sprintf(error_string, "HDF Error: Unable to write \"/%s/%s\" dataset\n", root.timestep_buffer, name);
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
 * Function:         hdf_callback
 *
 * Purpose:          
 *
 * Preconditions:    
 *
 * Postconditions:   
 *-------------------------------------------------------------------------
 */
static int hdf_callback(const int action, const int type, const char *name, const int stop, void *cookie, const char *format, va_list args)
{
	if (action == ACTION_OUTPUT) {
		switch (type) {
		case OUTPUT_PUNCH:
			if (pr.hdf == TRUE) {
				HDFWriteHyperSlabV(name, format, args);
			}
		}
	}
	return(OK);
}

