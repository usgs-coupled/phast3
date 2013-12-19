#include <stdlib.h>

// Fortran functions
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif
#if defined(FC_FUNC_)
// Calls to Fortran
#define advection_f90         FC_FUNC_ (advection_f90,       ADVECTION_F90)
#endif

#if defined(__cplusplus)
extern "C" {
#endif
	
extern void advection_f90(void);
extern void advection_c(void);

#if defined(__cplusplus)
}
#endif

// C++ function
extern int advection_cpp();

#if defined(USE_MPI)
#include <mpi.h>
#endif

int main(int argc, char* argv[])
{
	int mpi_tasks;
	int mpi_myself;

#if defined(USE_MPI)
	if (MPI_Init(&argc, &argv) != MPI_SUCCESS)
	{
		return EXIT_FAILURE;
	}

	if (MPI_Comm_size(MPI_COMM_WORLD, &mpi_tasks) != MPI_SUCCESS)
	{
		return EXIT_FAILURE;
	}

	if (MPI_Comm_rank(MPI_COMM_WORLD, &mpi_myself) != MPI_SUCCESS)
	{
		return EXIT_FAILURE;
	}
#else
	mpi_tasks = 1;
	mpi_myself = 0;
#endif

	//advection_cpp();
	advection_f90();
	//advection_c();

#if defined(USE_MPI)
	MPI_Finalize();
#endif
	return EXIT_SUCCESS;
}
