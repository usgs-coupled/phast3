#include <stdlib.h>

#if defined(USE_MPI)
#include <mpi.h>
#endif

#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) name
#endif

#if defined(FC_FUNC_)
#define PHAST_SUB FC_FUNC_(phast_sub, PHAST_SUB)
#endif

extern "C" void PHAST_SUB(int *mpi_tasks, int *mpi_myself);

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
	PHAST_SUB(&mpi_tasks, &mpi_myself);
	return EXIT_SUCCESS;
}
