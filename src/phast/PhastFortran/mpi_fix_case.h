#ifdef SKIP
#define MPI_Barrier                      RM_mpi_barrier
#define MPI_BARRIER                      RM_mpi_barrier
#define MPI_Bcast                        RM_mpi_bcast
#define MPI_BCAST                        RM_mpi_bcast
#define MPI_Comm_create                  RM_mpi_comm_create
#define MPI_COMM_CREATE                  RM_mpi_comm_create
#define MPI_Comm_group                   RM_mpi_comm_group
#define MPI_COMM_GROUP                   RM_mpi_comm_group
#define MPI_Get_address                  RM_mpi_get_address
#define MPI_GET_ADDRESS                  RM_mpi_get_address
#define MPI_Group_incl                   RM_mpi_group_incl
#define MPI_GROUP_INCL                   RM_mpi_group_incl
#define MPI_Recv                         RM_mpi_recv
#define MPI_RECV                         RM_mpi_recv
#define MPI_Send                         RM_mpi_send
#define MPI_SEND                         RM_mpi_send
#define MPI_Type_commit                  RM_mpi_type_commit
#define MPI_TYPE_COMMIT                  RM_mpi_type_commit
#define MPI_Type_create_struct           RM_mpi_type_create_struct
#define MPI_TYPE_CREATE_STRUCT           RM_mpi_type_create_struct
#define MPI_Type_free                    RM_mpi_type_free
#define MPI_TYPE_FREE                    RM_mpi_type_free
#define MPI_Wtime                        RM_mpi_wtime
#endif