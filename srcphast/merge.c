#include <assert.h>      /* assert */
static char const svnid[] = "$Id$";

#if defined(_WIN32) && defined(_MT)
#define _HDF5USEDLL_     /* reqd for Multithreaded run-time library (Win32) */
#endif
#include <mpi.h>         /* MPI routines */
#include <hdf5.h>        /* HDF routines */
#include <stdarg.h>      /* va_start va_list va_end */
#define MPI_MAX_TASKS 50 /* from hst.c */

#define EXTERNAL extern
#define USE_DEFAULT_FPRINTF
#include "phreeqc/global.h"      /* error_string */
#include "hst.h"                 /* struct back_list */
#include "phreeqc/phqalloc.h"    /* PHRQ_malloc PHRQ_realloc PHRQ_free */
#include "phreeqc/output.h"
#include "phreeqc/phrqproto.h"
#include "phastproto.h"
#include "phast_files.h"
#undef USE_DEFAULT_FPRINTF
#undef EXTERNAL


static int output_handler(const int type, const char *err_str, const int stop, void *cookie, const char *format, va_list args);


static struct CaptureInfo {
    int captured;
    hid_t file_id;
    hid_t vls_id;
    hid_t dspace_id;
    hssize_t coord[1][1];
    int in_equilibrate;
} s_ci;

struct FileInfo {
    char* buffer;
    int buffer_size;
    int buffer_pos;
    hid_t dset_id;
    FILE* stream;
    int MSG_TAG;
  int *buffer_size_array;
  int max_buffer_size_array;
};

static int Merge_fprintf2(struct FileInfo *pFileInfo, const char *format, ...);
static int Merge_vfprintf2(struct FileInfo *pFileInfo, const char *format, va_list args);

static struct FileInfo s_fiOutput;
static struct FileInfo s_fiPunch;
static struct FileInfo s_fiEcho;

static void FileInfo_init(struct FileInfo* pFileInfo, const int msg_val)
{
    /* init vars */
    pFileInfo->buffer      = NULL;
    pFileInfo->buffer_size = 0;
    pFileInfo->buffer_pos  = 0;
    pFileInfo->dset_id     = 0;
    pFileInfo->stream      = NULL;
    pFileInfo->MSG_TAG     = msg_val;
    pFileInfo->buffer_size_array      = NULL;
    pFileInfo->max_buffer_size_array  = 0;
}


static void FileInfo_alloc(struct FileInfo* pFileInfo, int size)
{
    /* initialize storage */
    pFileInfo->buffer_size = size;
    space ((void **) ((void *) &(pFileInfo->buffer)), INIT, &pFileInfo->buffer_size, sizeof(char));
    assert(pFileInfo->buffer != NULL);

    pFileInfo->max_buffer_size_array = size;
    space ((void **) ((void *) &(pFileInfo->buffer_size_array)), INIT, &pFileInfo->max_buffer_size_array, sizeof(int));
    assert(pFileInfo->buffer_size_array != NULL);
}

static void FileInfo_del(struct FileInfo* pFileInfo)
{
    /* release storage */
    /* may want to close file here */
    /* for some reason, needed to flush buffer on large version of chain3d problem */
    fflush(pFileInfo->stream);
    pFileInfo->buffer_size = 0;
    pFileInfo->buffer = (char *) free_check_null(pFileInfo->buffer);
    pFileInfo->max_buffer_size_array = 0;
    pFileInfo->buffer_size_array = (int *) free_check_null(pFileInfo->buffer_size_array);
}

static void FileInfo_open(struct FileInfo* pFileInfo, const char* name, const char *mode)
{
    /* open stream */
    if ((pFileInfo->stream = fopen(name, mode)) == NULL)
    {
        sprintf(error_string, "Can't open file, %s.", name);
        error_msg(error_string, STOP);
    }
}

static void FileInfo_merge(struct FileInfo* ptr_info, hid_t xfer_pid, hid_t mem_dspace, int *cell_to_proc)
{
    extern int end_cells[MPI_MAX_TASKS][2];
    extern int mpi_myself;
    extern int count_chem;
    extern int mpi_tasks;
    herr_t status;
    int e;
    char *rdata[1];
    int size;
    int mpi_return;
    int *local_record_size_array, *local_record_size_buffer, *root_record_size_array, *root_record_size_buffer;
    int local_count_chem, buffer_size, i, j, k;

    assert(ptr_info->dset_id > 0);

    /* find size of each record */
    
    /* allocate space */
    local_count_chem = end_cells[mpi_myself][1] - end_cells[mpi_myself][0] + 1;
    local_record_size_array = NULL;
    local_record_size_buffer = NULL;
    root_record_size_array = NULL;
    root_record_size_buffer = NULL;
    if (mpi_myself != 0) {
	buffer_size = 2*local_count_chem;
	local_record_size_array = (int *) PHRQ_malloc((size_t) (local_count_chem * sizeof(int)));
	if (local_record_size_array == NULL) malloc_error();
	local_record_size_buffer = (int *) PHRQ_malloc((size_t) (buffer_size * sizeof(int)));
	if (local_record_size_buffer == NULL) malloc_error();
    } else {
	root_record_size_array = (int *) PHRQ_malloc((size_t) (count_chem * sizeof(int)));
	if (root_record_size_array == NULL) malloc_error();
	root_record_size_buffer = (int *) PHRQ_malloc((size_t) 2 * count_chem * sizeof(int));
	if (root_record_size_buffer == NULL) malloc_error();
    }
    /* find record sizes */
    i = 0;
    j = 0;
    for (e = 0; e < count_chem; ++e) {
	/* read (and if nec send cell) */
	if (cell_to_proc[e] == mpi_myself) { 
	    if (mpi_myself != 0) {
	      size = ptr_info->buffer_size_array[j];
	      assert(j < local_count_chem);
	      local_record_size_array[j++] = size;
	      local_record_size_buffer[i++] = e;
	      assert(i < buffer_size);
	      local_record_size_buffer[i++] = size;
	    } else {
	      size = ptr_info->buffer_size_array[j];
	      assert(e < count_chem);
	      root_record_size_array[e] = size;
	      j++;
	    }
	}
    }
    /*
     * send lists of record sizes to root from non-root processes 
     */
    for (k = 1; k < mpi_tasks; k++) {
	if (k == mpi_myself) {
	    assert (i == buffer_size); 
	    assert (j == local_count_chem); 
	    /* send sizes to root */
	    mpi_return = MPI_Send(&buffer_size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
	    assert(mpi_return == MPI_SUCCESS);
	    mpi_return = MPI_Send(local_record_size_buffer, buffer_size, MPI_INT, 0, 0, MPI_COMM_WORLD);
	    assert(mpi_return == MPI_SUCCESS);
	} else if (mpi_myself == 0) {
	    MPI_Status mpi_status;
	    /* collect sizes to root */
	    mpi_return = MPI_Recv(&buffer_size, 1, MPI_INT, k, 0, MPI_COMM_WORLD, &mpi_status);
	    assert(mpi_return == MPI_SUCCESS);
	    mpi_return = MPI_Recv(root_record_size_buffer, buffer_size, MPI_INT, k, 0, MPI_COMM_WORLD, &mpi_status);
	    assert(mpi_return == MPI_SUCCESS);
	    i = 0;
	    for (j = 0; j < buffer_size/2; j++) {
		assert(i < buffer_size);
		e = root_record_size_buffer[i++];
		assert(e >= 0 && e < count_chem);
		assert(i < buffer_size);
		root_record_size_array[e] = root_record_size_buffer[i++];
	    }
	}
    }
    /*
     *   Now actually send the strings that are needed
     */

    s_ci.coord[0][0] = 0;
    i = 0;
    for (e = 0; e < count_chem; ++e) {
	/* read (and if nec send cell) */
	if (cell_to_proc[e] == mpi_myself) { 
	    if (mpi_myself == 0) {
		if (root_record_size_array[e] > 0) {
		    /* select dataspace */
		    assert((int)s_ci.coord[0][0] <= local_count_chem);
		    status = H5Sselect_elements(s_ci.dspace_id, H5S_SELECT_SET, 1, (const hssize_t **) ((void *) s_ci.coord));
		    assert(status >= 0);
		    /* just read cell */
		    assert((int)s_ci.coord[0][0] <= local_count_chem);
		    status = H5Dread(ptr_info->dset_id, s_ci.vls_id, mem_dspace, s_ci.dspace_id, H5P_DEFAULT, rdata);
		    assert(status >= 0);
		}
	    } else {
		if (local_record_size_array[i] > 1) {
		    /* select dataspace */
		    assert((int)s_ci.coord[0][0] <= local_count_chem);
		    status = H5Sselect_elements(s_ci.dspace_id, H5S_SELECT_SET, 1, (const hssize_t **) ((void *) s_ci.coord));
		    assert(status >= 0);
		    /* read cell */
		    assert((int)s_ci.coord[0][0] <= local_count_chem);
		    status = H5Dread(ptr_info->dset_id, s_ci.vls_id, mem_dspace, s_ci.dspace_id, H5P_DEFAULT, rdata);
		    assert(status >= 0);
		    /* send cell */
		    mpi_return = MPI_Send((void*)rdata[0], local_record_size_array[i], MPI_CHAR, 0, ptr_info->MSG_TAG, MPI_COMM_WORLD);
		    assert(mpi_return == MPI_SUCCESS);
		    /* free space used by var length datatype */
		    assert((int)s_ci.coord[0][0] <= local_count_chem);
		    status = H5Dvlen_reclaim(s_ci.vls_id, mem_dspace, xfer_pid, rdata);
		    assert(status >= 0);
		}
		++s_ci.coord[0][0];
		i++;
	    }
	}
	/* (if nec recieve cell and)  write to file */
	if (mpi_myself == 0) { 
	    if (cell_to_proc[e] == 0) {
		/* skip messages with length less than or equal to 1 */
		if (root_record_size_array[e] > 1) {
		    /* write cell */
		    fprintf(ptr_info->stream, "%s", rdata[0]);
		    /* free space used by var length datatype */
		    assert((int)s_ci.coord[0][0] <= local_count_chem);
		    status = H5Dvlen_reclaim(s_ci.vls_id, mem_dspace, xfer_pid, rdata);
		    assert(status >= 0);
		}
		++s_ci.coord[0][0];
	    } else {
		MPI_Status mpi_status;
		int count_char;
		if (root_record_size_array[e] > 1) {
		    /* recv size */
		    count_char = root_record_size_array[e];
		    space ((void **) ((void *) &(ptr_info->buffer)), count_char, &ptr_info->buffer_size, sizeof(char));
		    /* recv cell */
		    mpi_return = MPI_Recv((void*)ptr_info->buffer, count_char, MPI_CHAR, cell_to_proc[e], ptr_info->MSG_TAG, MPI_COMM_WORLD, &mpi_status);
		    assert(mpi_return == MPI_SUCCESS);
			
		    /* write cell */
		    fprintf(ptr_info->stream, "%s", ptr_info->buffer);
		}
	    }
	}
    }

    status = H5Dclose(ptr_info->dset_id);
    assert(status >= 0);

    ptr_info->dset_id = 0;
    /* free space */
    if (mpi_myself != 0) {
	local_record_size_buffer = (int *) free_check_null(local_record_size_buffer);
	local_record_size_array = (int *) free_check_null(local_record_size_array);
    } else {
	root_record_size_buffer = (int *) free_check_null(root_record_size_buffer);
	root_record_size_array = (int *) free_check_null(root_record_size_array);
    }
}

static int FileInfo_capture(struct FileInfo* ptr_info, const int length, const char* format, va_list argptr)
{
    int retval;

    assert(ptr_info->buffer != NULL && ptr_info->buffer_size > 0);
    assert(ptr_info->dset_id > 0); /* should be open */


    space ((void **) ((void *) &(ptr_info->buffer)), ptr_info->buffer_pos + length, &ptr_info->buffer_size, sizeof(char));

    retval = vsprintf(ptr_info->buffer + ptr_info->buffer_pos, format, argptr);

    assert(retval == length);

    ptr_info->buffer_pos += retval;

    return retval;
}

static int FileInfo_printf(struct FileInfo* ptr_info, const char* format, va_list argptr)
{
    assert(ptr_info->stream != NULL);
    return vfprintf(ptr_info->stream, format, argptr);	
}

static void FileInfo_dataset_create(struct FileInfo* ptr_info, const char* name, int count_buffer_size_array)
{
    assert(s_ci.file_id   != 0);
    assert(s_ci.vls_id    != 0);
    assert(s_ci.dspace_id != 0);

    assert(ptr_info->dset_id == 0);

    /* reallocate buffer_size_array if necessary*/
    space ((void **) ((void *) &(ptr_info->buffer_size_array)), count_buffer_size_array, &ptr_info->max_buffer_size_array, sizeof(int));

    ptr_info->dset_id = H5Dcreate(s_ci.file_id, name, s_ci.vls_id, s_ci.dspace_id, H5P_DEFAULT);
    if (ptr_info->dset_id <= 0 ) {
        sprintf(error_string, "HDF ERROR: Unable to create \"%s\" dataset.\n", name);
        error_msg(error_string, STOP);
    }
}

/*-------------------------------------------------------------------------
 * Function          
 *
 * Preconditions:    
 *
 * Postconditions:   
 *                   
 *-------------------------------------------------------------------------
 */
void MergeInit(char* prefix, int prefix_l, int solute)
{
    extern int mpi_myself;

    s_ci.captured       = 0;
    s_ci.file_id        = 0;
    s_ci.vls_id         = 0;
    s_ci.dspace_id      = 0;
    s_ci.coord[0][0]    = 0;
    s_ci.in_equilibrate = 0;

    if (solute) {
	    FileInfo_init(&s_fiOutput, 6);	
	    FileInfo_init(&s_fiPunch, 7);
    }
    FileInfo_init(&s_fiEcho, 8);


    if (mpi_myself == 0)
    {
        char default_name[MAX_LENGTH];
    
        strncpy(error_string, prefix, prefix_l);
        error_string[prefix_l] = '\0';
        string_trim(error_string);

        sprintf(default_name, "%s.O.chem", error_string);
        FileInfo_open(&s_fiOutput, default_name, "w");
	strcpy(output_file_name, default_name);

        sprintf(default_name, "%s.xyz.chem", error_string);
        FileInfo_open(&s_fiPunch, default_name, "w");

        sprintf(default_name, "%s.log", error_string);
        FileInfo_open(&s_fiEcho, default_name, "a");
    }


    /* create variable length string type */
    s_ci.vls_id = H5Tcopy(H5T_C_S1);
    if (s_ci.vls_id <= 0) {
        sprintf(error_string, "HDF ERROR: Unable to copy H5T_C_S1.\n");
        error_msg(error_string, STOP);
    }
    if (H5Tset_size(s_ci.vls_id, H5T_VARIABLE) < 0) {
        sprintf(error_string, "HDF ERROR: Unable to set size of variable length string type.\n");
        error_msg(error_string, STOP);
    }

    /* initialize storage */
    if (solute)
    {
      FileInfo_alloc(&s_fiOutput, 6000);
      FileInfo_alloc(&s_fiPunch, 6000);
    }
    FileInfo_alloc(&s_fiEcho, 6000);
}

/*-------------------------------------------------------------------------
 * Function          
 *
 * Preconditions:    
 *
 * Postconditions:   
 *                   
 *-------------------------------------------------------------------------
 */
void MergeFinalize(void)
{

    /* release variable length string type */
    assert(s_ci.vls_id);
    H5Tclose(s_ci.vls_id);
    s_ci.vls_id = 0;

    /* release storage */
    FileInfo_del(&s_fiOutput);
    FileInfo_del(&s_fiPunch);
    FileInfo_del(&s_fiEcho);
}


void MergeFinalizeEcho(void)
{

    /* release variable length string type */
    assert(s_ci.vls_id);
    H5Tclose(s_ci.vls_id);
    s_ci.vls_id = 0;

    /* release storage */
    FileInfo_del(&s_fiEcho);
}

/*-------------------------------------------------------------------------
 * Function          
 *
 * Preconditions:    
 *
 * Postconditions:   
 *                   
 *-------------------------------------------------------------------------
 */
void MergeBeginTimeStep(int print_sel, int print_out)
{
    extern int end_cells[MPI_MAX_TASKS][2];
    extern int* random_list;
    extern int mpi_myself;

    hsize_t dims[1];    
    int* ptr_beg;
    int* ptr_end;

    s_ci.in_equilibrate = TRUE;
    /* Always open file for output in case of a warning message */

    /* open temp hdf file to store timestep */
    sprintf(error_string, "~%d.capture.h5~", mpi_myself);
    s_ci.file_id = H5Fcreate(error_string, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
    if (s_ci.file_id <= 0) {
        sprintf(error_string, "Unable to open HDF file:~%d.capture.h5~\n", mpi_myself);
        error_msg(error_string, STOP);
    }

    /* determine space */
    ptr_beg = &(random_list[end_cells[mpi_myself][0]]);
    ptr_end = &(random_list[end_cells[mpi_myself][1]]);
    dims[0] = ptr_end - ptr_beg + 1;

    /* create the dataspace */
    assert(dims[0] > 0);
    s_ci.dspace_id = H5Screate_simple(1, dims, NULL);
    if (s_ci.dspace_id <= 0) {
        sprintf(error_string, "HDF ERROR: Unable to create dataspace.\n");
        error_msg(error_string, STOP);      
    }

    /* Always open file for output in case of a warning message */
    {
      /* create the O.chem dataset */
      FileInfo_dataset_create(&s_fiOutput, "O.chem", (int) dims[0]);
    } 

    if (print_sel == TRUE)
    {
      /* create the xyz.chem dataset */
      FileInfo_dataset_create(&s_fiPunch, "xyz.chem", (int) dims[0]);
    }

    /* Always open file for echo in case of a warning message */
    {
      /* create the O.chem dataset */
      FileInfo_dataset_create(&s_fiEcho, "log", (int) dims[0]);
    } 
    /* init dspace coordinates */
    s_ci.coord[0][0] = 0;
}

/*-------------------------------------------------------------------------
 * Function          MergeEndTimeStep (Called by all procs)
 *
 * Preconditions:    completed timestep
 *
 * Postconditions:   strings stored in hdf files are merged and
 *                   printed to file
 *-------------------------------------------------------------------------
 */
void MergeEndTimeStep(int print_sel, int print_out)
{
    extern int mpi_myself;
    extern int mpi_tasks;

    extern int end_cells[MPI_MAX_TASKS][2];
    extern int* random_list;

    int *cell_to_proc;

    herr_t status;
    hid_t xfer_pid;
    hid_t mem_dspace;
    hsize_t dims[1];
    int task_number, k;
    /* Always open file for output in case of a warning message */

    /* create list of cell-index to proc-index */
    cell_to_proc = (int *) PHRQ_malloc((size_t) count_chem * sizeof(int));
    if (cell_to_proc == NULL) malloc_error();
    for (task_number = 0; task_number < mpi_tasks; ++task_number)
    {
        for (k = end_cells[task_number][0]; k <= end_cells[task_number][1]; ++k)
        {
            cell_to_proc[random_list[k]] = task_number;
        }
    }

    /* create and set variable length memory manager */
    xfer_pid = H5Pcreate(H5P_DATASET_XFER);
    assert(xfer_pid > 0);

    status = H5Pset_vlen_mem_manager(xfer_pid, NULL, NULL, NULL, NULL);
    assert(status >= 0);

    /* create memory dataspace */
    dims[0] = 1;
    mem_dspace = H5Screate_simple(1, dims, NULL);
    assert(mem_dspace > 0);

    if (print_sel == TRUE)
    {
        assert(s_fiPunch.dset_id > 0);
        FileInfo_merge(&s_fiPunch, xfer_pid, mem_dspace, cell_to_proc);
    }
    /* Always open file for output in case of a warning message */
    {
        assert(s_fiOutput.dset_id > 0);
        FileInfo_merge(&s_fiOutput, xfer_pid, mem_dspace, cell_to_proc);
    }
    /* Always open file for echo in case of a warning message */
    {
        assert(s_fiEcho.dset_id > 0);
        FileInfo_merge(&s_fiEcho, xfer_pid, mem_dspace, cell_to_proc);
    }

    /* close memory dataspace */
    status = H5Sclose(mem_dspace);
    assert(status >= 0);
	
    /* release variable length memory manager */
    status = H5Pclose (xfer_pid);
    assert(status >= 0);

    /* close file dataspace */
    status = H5Sclose(s_ci.dspace_id);
    assert(status >= 0);

    /* close file */
    status = H5Fclose(s_ci.file_id);
    assert(status >= 0);

    /* delete hdf file */
    sprintf(error_string, "~%d.capture.h5~", mpi_myself);
    remove(error_string);


    /* clean-up */
    if (mpi_myself != 0)
    {
      if (s_fiOutput.stream) rewind(s_fiOutput.stream);
      if (s_fiPunch.stream)  rewind(s_fiPunch.stream);
    }
    PHRQ_free(cell_to_proc);
}

/*-------------------------------------------------------------------------
 * Function          MergeBeginCell
 *
 * Preconditions:    s_mi -- initialized (MergeInit)
 *
 * Postconditions:   s_fiOutput.buffer_pos   -- reset
 *                   s_ci.captured     -- reset
 *-------------------------------------------------------------------------
 */
void MergeBeginCell(void)
{
    assert(s_ci.captured == 0); /* MergeEndCell not called yet? */
    s_ci.captured = 1;


    s_fiOutput.buffer_pos = 0;
    s_fiPunch.buffer_pos = 0;
    s_fiEcho.buffer_pos = 0;
}

/*-------------------------------------------------------------------------
 * Function          MergeEndCell
 *
 * Preconditions:    MergeBeginCapture called => (s_ci.captured != 0)
 *
 * Postconditions:   print_all string stored to hdf
 *                   s_fiOutput.buffer_pos and s_ci.captured reset
 *-------------------------------------------------------------------------
 */
void MergeEndCell(int print_sel, int print_out, int print_hdf, int n_proc)
{
    assert(s_ci.captured != 0);
    s_ci.captured = 0;

    s_fiOutput.buffer_size_array[n_proc] = 0;
    if (print_sel == TRUE) s_fiPunch.buffer_size_array[n_proc] = 0;
    s_fiEcho.buffer_size_array[n_proc] = 0;

    if (s_fiOutput.buffer_pos > 0)
    {
        herr_t status;
        hid_t mem_dspace;
        hsize_t dims[1];

        /* create memory dataspace */
        dims[0] = 1;
        mem_dspace = H5Screate_simple(1, dims, NULL);
        if (mem_dspace < 0) {
            sprintf(error_string, "HDF ERROR: Unable to create_simple dataspace.\n");
            error_msg(error_string, STOP);
        }

        /* make dataspace selection */
        status = H5Sselect_elements(s_ci.dspace_id, H5S_SELECT_SET, 1, (const hssize_t **) ((void *) s_ci.coord));
        if (status < 0) {
            sprintf(error_string, "HDF ERROR: Unable to write dataset.\n");
            error_msg(error_string, STOP);
        }

        assert(s_fiOutput.buffer[s_fiOutput.buffer_pos] == 0);
        assert(strlen(s_fiOutput.buffer) == (size_t)s_fiOutput.buffer_pos);
	s_fiOutput.buffer_size_array[n_proc] = s_fiOutput.buffer_pos + 1;

        /* write the dataset */
        assert(s_fiOutput.dset_id > 0);
        status = H5Dwrite(s_fiOutput.dset_id, s_ci.vls_id, mem_dspace, s_ci.dspace_id, H5P_DEFAULT, &s_fiOutput.buffer);
        if (status < 0) {
            sprintf(error_string, "HDF ERROR: Unable to write dataset.\n");
            error_msg(error_string, STOP);
        }

        /* close memory dataspace */
        status = H5Sclose(mem_dspace);
        assert(status >= 0);

        s_fiOutput.buffer_pos = 0;
        s_fiOutput.buffer[0] = 0;
    }

    if (s_fiPunch.buffer_pos > 0)
    {
        herr_t status;
        hid_t mem_dspace;
        hsize_t dims[1];

        /* create memory dataspace */
        dims[0] = 1;
        mem_dspace = H5Screate_simple(1, dims, NULL);
        if (mem_dspace < 0) {
            sprintf(error_string, "HDF ERROR: Unable to create_simple dataspace.\n");
            error_msg(error_string, STOP);
        }

        /* make dataspace selection */
        status = H5Sselect_elements(s_ci.dspace_id, H5S_SELECT_SET, 1, (const hssize_t **) ((void *) s_ci.coord));
        if (status < 0) {
            sprintf(error_string, "HDF ERROR: Unable to write dataset.\n");
            error_msg(error_string, STOP);
        }

        assert(s_fiPunch.buffer[s_fiPunch.buffer_pos] == 0);
        assert(strlen(s_fiPunch.buffer) == (size_t)s_fiPunch.buffer_pos);
	s_fiPunch.buffer_size_array[n_proc] = s_fiPunch.buffer_pos + 1;

        /* write the dataset */
        assert(s_fiPunch.dset_id > 0);
        status = H5Dwrite(s_fiPunch.dset_id, s_ci.vls_id, mem_dspace, s_ci.dspace_id, H5P_DEFAULT, &s_fiPunch.buffer);
        if (status < 0) {
            sprintf(error_string, "HDF ERROR: Unable to write dataset.\n");
            error_msg(error_string, STOP);
        }

        /* close memory dataspace */
        status = H5Sclose(mem_dspace);
        assert(status >= 0);

        s_fiPunch.buffer_pos = 0;
        s_fiPunch.buffer[0] = 0;
    }

    if (s_fiEcho.buffer_pos > 0)
    {
        herr_t status;
        hid_t mem_dspace;
        hsize_t dims[1];

        /* create memory dataspace */
        dims[0] = 1;
        mem_dspace = H5Screate_simple(1, dims, NULL);
        if (mem_dspace < 0) {
            sprintf(error_string, "HDF ERROR: Unable to create_simple dataspace.\n");
            error_msg(error_string, STOP);
        }

        /* make dataspace selection */
        status = H5Sselect_elements(s_ci.dspace_id, H5S_SELECT_SET, 1, (const hssize_t **) ((void *) s_ci.coord));
        if (status < 0) {
            sprintf(error_string, "HDF ERROR: Unable to write dataset.\n");
            error_msg(error_string, STOP);
        }

        assert(s_fiEcho.buffer[s_fiEcho.buffer_pos] == 0);
        assert(strlen(s_fiEcho.buffer) == (size_t)s_fiEcho.buffer_pos);
	s_fiEcho.buffer_size_array[n_proc] = s_fiEcho.buffer_pos + 1;

        /* write the dataset */
        assert(s_fiEcho.dset_id > 0);
        status = H5Dwrite(s_fiEcho.dset_id, s_ci.vls_id, mem_dspace, s_ci.dspace_id, H5P_DEFAULT, &s_fiEcho.buffer);
        if (status < 0) {
            sprintf(error_string, "HDF ERROR: Unable to write dataset.\n");
            error_msg(error_string, STOP);
        }

        /* close memory dataspace */
        status = H5Sclose(mem_dspace);
        assert(status >= 0);

        s_fiEcho.buffer_pos = 0;
        s_fiEcho.buffer[0] = 0;
    }

    /* incr dataspace coordinates */
    ++s_ci.coord[0][0];
}


/* ---------------------------------------------------------------------- */
int Merge_fpunchf(const int length, const char* format, va_list argptr)
/* ---------------------------------------------------------------------- */
{
    extern int mpi_myself;
    int ret_val;


    ret_val = 0;
    if (s_ci.in_equilibrate == FALSE) return length;  /* ignore punch until EQUILIBRATE is called */

    if (s_ci.captured == TRUE)
    {
		static char big_buffer[200];
		/* determine length of buffer reqd */
		ret_val = vsprintf(big_buffer, format, argptr);

		assert(ret_val < 200);
        ret_val = FileInfo_capture(&s_fiPunch, ret_val, format, argptr);
    }
    else if (mpi_myself == 0)
    {
        ret_val = FileInfo_printf(&s_fiPunch, format, argptr);
    }
    return ret_val;
}

/* ---------------------------------------------------------------------- */
int merge_handler(const int action, const int type, const char *name, const int stop, void *cookie, const char *format, va_list args)
/* ---------------------------------------------------------------------- */
{
	switch (action) {
	case ACTION_OUTPUT:
		return output_handler(type, name, stop, cookie, format, args);
		break;
	}
	return(OK);
}


/* ---------------------------------------------------------------------- */
static int output_handler(const int type, const char *err_str, const int stop, void *cookie, const char *format, va_list args)
/* ---------------------------------------------------------------------- */
{
    extern int mpi_myself;

	switch (type) {

	case OUTPUT_ERROR:
		Merge_fprintf2(&s_fiOutput, "ERROR: %s\n", err_str);
		if (stop == STOP) {
			Merge_fprintf2(&s_fiOutput, "Stopping.\n");
		}
		break;
	case OUTPUT_WARNING:
		if (state == TRANSPORT && transport_warnings == FALSE) return(OK);
		if (state == ADVECTION && advection_warnings == FALSE) return(OK);
		if (pr.warnings >= 0) {
			if (count_warnings > pr.warnings) return(OK);
		}
		Merge_fprintf2(&s_fiOutput, "WARNING: %s\n", err_str);
		break;
	case OUTPUT_CHECKLINE:
		if (pr.echo_input == TRUE) {
			Merge_vfprintf2(&s_fiOutput, format, args);
			if (phreeqc_mpi_myself == 0) {
				Merge_vfprintf2(&s_fiEcho, format, args);
			}
		}
		break;
	case OUTPUT_MESSAGE:
	case OUTPUT_BASIC:
		Merge_vfprintf2(&s_fiOutput, format, args);
		break;
	case OUTPUT_PUNCH:
		if (pr.punch == TRUE && punch.in == TRUE) {
			if (s_ci.captured == TRUE)
			{
				Merge_vfprintf2(&s_fiPunch, format, args);
			}
			else if (mpi_myself == 0 && s_ci.in_equilibrate)
			{
				Merge_vfprintf2(&s_fiPunch, format, args);
			}
		}
		break;
	case OUTPUT_ECHO:
		Merge_vfprintf2(&s_fiEcho, format, args);
		break;
	}
	return(OK);
}

/* ---------------------------------------------------------------------- */
static int Merge_vfprintf2(struct FileInfo *pFileInfo, const char *format, va_list args)
/* ---------------------------------------------------------------------- */
{
  extern int mpi_myself;
  int retval;
  static char buffer[500];
  
  retval = 0;
  
  if (s_ci.captured == TRUE)
  {
#ifdef VACOPY
    va_list args_copy;
    va_copy (args_copy, args);
    retval = vsprintf(buffer, format, args);
    assert(retval < 500);
    assert(pFileInfo->dset_id > 0);
    FileInfo_capture(pFileInfo, retval, format, args_copy);
    va_end(args_copy);
#else
    retval = vsprintf(buffer, format, args);
    assert(retval < 500);
    assert(pFileInfo->dset_id > 0);
    FileInfo_capture(pFileInfo, retval, format, args);
#endif
  }
  else if (mpi_myself == 0)
  {
    retval = FileInfo_printf(pFileInfo, format, args);
  }
  return retval;
}

/* ---------------------------------------------------------------------- */
static int Merge_fprintf2(struct FileInfo *pFileInfo, const char *format, ...)
/* ---------------------------------------------------------------------- */
{
    va_list args;
    int retval;

    va_start(args, format);
    retval = Merge_vfprintf2(pFileInfo, format, args);
    va_end(args);
    return retval;
}

