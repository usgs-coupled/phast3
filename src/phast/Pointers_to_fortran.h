#if !defined(POINTERS_TO_FORTRAN_H_INCLUDED)
#define POINTERS_TO_FORTRAN_H_INCLUDED

// Pointers to Fortran arrays

// 7xnxyz initial condition arrays
EXTERNAL int *initial_conditions1_c, *initial_conditions2_c;
EXTERNAL double *mxfrac_c;

// Grid info nxyz
EXTERNAL double *x_node_c, *y_node_c, *z_node_c;
EXTERNAL int nxyz_c;

#endif // POINTERS_TO_FORTRAN_H_INCLUDED
