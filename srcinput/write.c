#define EXTERNAL extern
#include "hstinpt.h"
#include "message.h"
#include "stddef.h"
static char const svnid[] = "$Id$";

char *line_from_string(char **ptr);
double print_value(struct time *time_ptr);
int write_bc_static(void);
int write_bc_transient(void);
int write_calculation_static(void);
int write_calculation_transient(void);
int write_double_element_property(size_t offset, double factor);
int write_double_cell_property(size_t offset, double factor);
int write_file_names(void);
int write_fluid(void);
static int write_grid(void);
int write_initial(void);
int write_integer_cell_property(size_t offset);
int write_ic(void);
int write_media(void);
int write_output_static(void);
int write_output_transient(void);
int write_source_sink(void);

/* ---------------------------------------------------------------------- */
int write_hst(void)
/* ---------------------------------------------------------------------- */
{
	int i, j;
/*
 *   calculate number of boundary conditions
 */
	count_specified = 0;
	count_flux = 0;
	count_leaky = 0;
	count_river_segments = 0;
	for (i = 0; i < nxyz; i++) {
		if (cells[i].cell_active == FALSE) continue;
		if (cells[i].bc_type == SPECIFIED) {
			count_specified++;
			continue;
		}
		for (j = 0; j < 3; j++) {
			if (cells[i].bc_face[j].bc_type == FLUX) count_flux++;
			if (cells[i].bc_face[j].bc_type == LEAKY) count_leaky++;
		}
		if (cells[i].bc_face[2].bc_type != LEAKY) count_river_segments += cells[i].count_river_polygons;
	}
	if (simulation == 0) {
		write_file_names();
		write_initial();
		write_grid();
		write_fluid();
		write_media();
		write_source_sink();
		write_bc_static();
		write_ic();
		write_calculation_static();
		write_output_static();
	} 
	write_bc_transient();
	write_calculation_transient();
	write_output_transient();

	return(OK);
}

/* ---------------------------------------------------------------------- */
int write_file_names(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes file names for HST to pick up
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *          OK
 *
 */

	if (hst_file == NULL) {
		error_msg("Can not open temporary data file (Phast.tmp)", STOP);
	}
	output_msg(OUTPUT_HST,"%s\n", chemistry_name);
	output_msg(OUTPUT_HST,"%s\n", database_name);
	output_msg(OUTPUT_HST,"%s\n", prefix);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_initial(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes initial HST data lines
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *          OK
 *          ERROR
 *
 */

	char *ptr;
	char *title_line;

	output_msg(OUTPUT_HST,"C.....PHAST Data-Input Form\n");
	output_msg(OUTPUT_HST,"C.....UNRELEASE 1.0\n");
	output_msg(OUTPUT_HST,"C...   Notes:\n");
	output_msg(OUTPUT_HST,"C...   Input lines are denoted by C.N1.N2.N3 where\n");
	output_msg(OUTPUT_HST,"C...        N1 is the read group number, N2.N3 is the record number\n");
	output_msg(OUTPUT_HST,"C...        A letter indicates an exclusive record choice must be made.\n");
	output_msg(OUTPUT_HST,"C...          i.e. A or B or C\n");
	output_msg(OUTPUT_HST,"C...   (O) - Optional data with conditions for requirement\n");
	output_msg(OUTPUT_HST,"C...   P [n.n.n] - The record where parameter P is set\n");
	output_msg(OUTPUT_HST,"C.....Input by x,y,z range format is;\n");
	output_msg(OUTPUT_HST,"C.0.1.. X1,X2,Y1,Y2,Z1,Z2\n");
	output_msg(OUTPUT_HST,"C.0.2.. VAR1,IMOD1,[VAR2,IMOD2,VAR3,IMOD3]\n");
	output_msg(OUTPUT_HST,"C...     Use as many of line 0.1 & 0.2 sets as necessary\n");
	output_msg(OUTPUT_HST,"C...     End with line 0.3\n");
	output_msg(OUTPUT_HST,"C.0.3.. END OR end\n");
	output_msg(OUTPUT_HST,"C...   {nnn} - Indicates that the default number, nnn, is used if a zero\n");
	output_msg(OUTPUT_HST,"C...           is entered for that variable\n");
	output_msg(OUTPUT_HST,"C...   [T/F] - Indicates a logical variable\n");
	output_msg(OUTPUT_HST,"C...   [I] - Indicates an integer variable\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Start of the data file\n");
	output_msg(OUTPUT_HST,"C.....Specification and dimensioning data - READ1\n");
/*
 *   write title
 */
	output_msg(OUTPUT_HST,"C.1.1 .. TITLE LINE 1\n");
	ptr = title_x;
	title_line = line_from_string(&ptr);
	output_msg(OUTPUT_HST,".%s\n", title_line);
	free_check_null(title_line);
	output_msg(OUTPUT_HST,"C.1.2 .. TITLE LINE 2\n");
	title_line = line_from_string(&ptr);
	output_msg(OUTPUT_HST,".%s\n", title_line);
	free_check_null(title_line);

	output_msg(OUTPUT_HST,"C.1.3 .. RESTRT[T/F],TIMRST\n");
	output_msg(OUTPUT_HST,"     f 0.\n");
	output_msg(OUTPUT_HST,"C.....If RESTART, skip to READ3 group\n");
	output_msg(OUTPUT_HST,"C.1.4 .. HEAT[T/F],SOLUTE[T/F],EEUNIT[T/F],CYLIND[T/F],SCALMF[T/F]\n");
	if (flow_only == TRUE) {
		output_msg(OUTPUT_HST,"     f f f f f\n");
	} else {
		output_msg(OUTPUT_HST,"     f t f f f\n");
	}
	output_msg(OUTPUT_HST,"C.1.4.1 STEADY_FLOW[T/F], EPS_HEAD (head), EPS_FLOW (fraction)\n");
	if (steady_flow == TRUE) {
		output_msg(OUTPUT_HST,"     t  %g %g \n", fluid_density * GRAVITY * eps_head * units.head.input_to_si, eps_mass_balance);
	} else {
		output_msg(OUTPUT_HST,"     f  0  0 \n");
	}
	output_msg(OUTPUT_HST,"C   axes t/f t/f t/f (x y z)\n");
	output_msg(OUTPUT_HST,"     %d %d %d\n", axes[0], axes[1], axes[2]);
/*
 *   time unit
 */
	str_tolower(units.time.input);
	output_msg(OUTPUT_HST,"C.1.5 .. TMUNIT[I]\n");
	if (units.time.input[0] == 's') {
		output_msg(OUTPUT_HST,"1\n");
	} else if (units.time.input[0] == 'm') {
		output_msg(OUTPUT_HST,"2\n");
	} else if (units.time.input[0] == 'h') {
		output_msg(OUTPUT_HST,"3\n");
	} else if (units.time.input[0] == 'd') {
		output_msg(OUTPUT_HST,"4\n");
	} else if (units.time.input[0] == 'y') {
		output_msg(OUTPUT_HST,"6\n");
	} else {
		error_msg("Can not interpret time units", STOP);
	}
/*
 *   Number of nodes
 */
	output_msg(OUTPUT_HST,"C.1.6 .. NX,NY,NZ,NHCN, Number of elements\n");
	output_msg(OUTPUT_HST,"     %d %d %d 0 %d\n", grid[0].count_coord, grid[1].count_coord, grid[2].count_coord, (nx-1) * (ny-1) * (nz-1));
	output_msg(OUTPUT_HST,"C.1.7 .. NSBC,NFBC,NLBC,NRBC,NAIFC,NHCBC,NWEL\n");
	output_msg(OUTPUT_HST,"     %d %d %d %d 0 0 %d\n", count_specified, count_flux, count_leaky, count_river_segments, count_wells);
/*
 *   solution method
 */
	output_msg(OUTPUT_HST,"C.1.8 .. SLMETH[I], NPA4\n");
	if (solver_method == DIRECT) {
		output_msg(OUTPUT_HST,"     1 %d\n", solver_memory);
	} else if (solver_method == ITERATIVE) {
		output_msg(OUTPUT_HST,"     5 %d\n", solver_memory);
	} else {
		error_msg("Solver method not defined", STOP);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
char *line_from_string(char **ptr)
/* ---------------------------------------------------------------------- */
{
	int i;
	size_t l;
	char *return_string;


	if (*ptr == NULL) {
		l = 2;
	} else {
		l = strlen(*ptr) + 2;
	}
	return_string = malloc((size_t) l * sizeof(char) );
	if (return_string == NULL) malloc_error();
	if (*ptr == NULL) {
		strcpy(return_string,"");
	} else {
		i = 0;
		while( (*ptr)[i] != '\0' && (*ptr)[i] != '\n') {
			i++;
		}
		strncpy(return_string, *ptr, (size_t) (i));
		return_string[i] = '\0';
		if ((*ptr)[i] == '\n') {
			*ptr = &((*ptr)[i+1]);
		} else {
			*ptr = NULL;
		}
	}
	return(return_string);
}
/* ---------------------------------------------------------------------- */
int write_grid(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes grid data
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *          OK
 *          ERROR
 *
 */

	int j;
	double conversion;
/*
 *  Uniform grid
 */ 
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Static data - READ2\n");
	output_msg(OUTPUT_HST,"C.....Coordinate geometry information\n");
	output_msg(OUTPUT_HST,"C.....   Rectangular coordinates\n");
	output_msg(OUTPUT_HST,"C.2.2A.1 .. UNIGRX,UNIGRY,UNIGRZ; all [T/F];(O) - NOT CYLIND [1.4]\n");
	for (j = 0; j < 3; j++) {
		if (grid[j].uniform == UNDEFINED) {
			output_msg(OUTPUT_HST,"     t");
		} else if (grid[j].uniform == TRUE) {
			output_msg(OUTPUT_HST,"     t ");
		} else if (grid[j].uniform == FALSE) {
			output_msg(OUTPUT_HST,"     f ");
		} else {
			error_msg("Unknown value for grid.uniform.", STOP);
		}
	}
	output_msg(OUTPUT_HST,"\n");
/*
 *   X, Y, Z grid data
 */
	j = 0;
	for (j = 0; j < 3; j++) {
		if (j == 0 || j == 1) {
			conversion = units.horizontal.input_to_si;
		} else {
			conversion = units.vertical.input_to_si;
		}
		output_msg(OUTPUT_HST,"C2.2A.2A .. %c(1), %c(N%c)\n", grid[j].c, grid[j].c, grid[j].c);
		if (grid[j].uniform == UNDEFINED) {
			output_msg(OUTPUT_HST,"%12g %12g \n", 0.0,  1.0);
		}		
		if (grid[j].uniform == TRUE) {
			output_msg(OUTPUT_HST,"%12g  %12g \n", 
				grid[j].coord[0] * conversion,  
				grid[j].coord[grid[j].count_coord - 1] * conversion);
		}  
		output_msg(OUTPUT_HST,"C2.2A.2B .. %c(I)\n", grid[j].c);
		if (grid[j].uniform == FALSE) {
			if (grid[j].count_coord < 2) {
				sprintf(error_string, "Expected two coordinate values and the number of nodes for %c grid information.", grid[j].c);
				error_msg(error_string, CONTINUE);
				input_error++;
				continue;
			}
			vector_print(grid[j].coord, conversion, grid[j].count_coord, hst_file);
		} 
	}
/*
 *   Cylindrical coordinates NOT USED
 */
	output_msg(OUTPUT_HST,"C.....   Cylindrical coordinates\n");
	output_msg(OUTPUT_HST,"C.2.2B.1A .. R(1),R(NR),ARGRID[T/F];(O) - CYLIND [1.4]\n");
	output_msg(OUTPUT_HST,"C.2.2B.1B .. R(I);(O) - CYLIND [1.4] and NOT ARGRID [2.2B.1A]\n");
	output_msg(OUTPUT_HST,"C.2.2B.2 .. UNIGRZ[T/F];(O) - CYLIND [1.4]\n");
	output_msg(OUTPUT_HST,"C.2.2B.3A .. Z(1),Z(NZ);(O) - UNIGRZ [2.2B.3A],CYLIND [1.4]\n");
	output_msg(OUTPUT_HST,"C.2.2B.3B .. Z(K);(O) - NOT UNIGRZ [2.2B.3A],CYLIND [1.4]\n");
	output_msg(OUTPUT_HST,"C.2.3.1 .. TILT[T/F];(O) - NOT CYLIND [1.4]\n");
	output_msg(OUTPUT_HST,"f\n");
	output_msg(OUTPUT_HST,"C.2.3.2 .. THETXZ,THETYZ,THETZZ;(O) - TILT [2.3.1] and NOT CYLIND [1.4]\n");
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_fluid(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes fluid properties
 *
 *      Arguments:
 *         none
 *
 *      Returns:
 *          OK
 *          ERROR
 *
 */


	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Fluid property information\n");
	output_msg(OUTPUT_HST,"C.2.4.1 .. BP\n");
	if (free_surface == TRUE) {
		output_msg(OUTPUT_HST,"     %g\n", 0.0);
		/* warning_msg("Fluid compressibility has been set to zero for free surface calculation."); */
	} else {
		output_msg(OUTPUT_HST,"     %g\n", fluid_compressibility);
	}
	output_msg(OUTPUT_HST,"C.2.4.2 .. P0,T0,W0,DENF0\n");
	output_msg(OUTPUT_HST,"     0. 15. 0. %g\n", fluid_density);
	output_msg(OUTPUT_HST,"C.2.4.3 .. W1,DENF1;(O) - SOLUTE [1.4]\n");
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"     .05 %g\n", fluid_density);
	}
	output_msg(OUTPUT_HST,"C.2.5.1 .. VISFAC\n");
	output_msg(OUTPUT_HST,"     %g\n", -fluid_viscosity);
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Reference condition information\n");
	output_msg(OUTPUT_HST,"C.2.6.1 .. PAATM\n");
	output_msg(OUTPUT_HST,"     0.\n");
	output_msg(OUTPUT_HST,"C.2.6.2 .. P0H,T0H\n");
	output_msg(OUTPUT_HST,"     0. 15.\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Fluid thermal property information\n");
	output_msg(OUTPUT_HST,"C.2.7 .. CPF,KTHF,BT;(O) - HEAT [1.4]\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Solute information\n");
	output_msg(OUTPUT_HST,"C.2.8 .. DM; (O) - SOLUTE [1.4]\n");
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"     %g\n", fluid_diffusivity * units.time.input_to_si);
	}
	return(OK);
}

/* ---------------------------------------------------------------------- */
int write_media(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes zones for porous media properties
 *
 *      Arguments:
 *         none
 *
 */

	int i, element_number, n;
	int storage_warning;
/*
 *  Write zones
 */ 
	element_number = 1;
	output_msg(OUTPUT_HST,"C.....Porous media zone information\n");
	output_msg(OUTPUT_HST,"C.2.9.1 .. IPMZ,X1Z(IPMZ),X2Z(IPMZ),Y1Z(IPMZ),Y2Z(IPMZ),Z1Z(IPMZ),Z2Z(IPMZ)\n");
	for (i = 0; i < nxyz; i++) {
		if (cells[i].is_element == FALSE) continue;
		if (cells[i].elt_active == FALSE) continue;
		n = ijk_to_n(cells[i].ix + 1, cells[i].iy + 1, cells[i].iz + 1);
		output_msg(OUTPUT_HST,"%7d %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			element_number, 
			cells[i].x * units.horizontal.input_to_si, 
			cells[n].x * units.horizontal.input_to_si,
			cells[i].y * units.horizontal.input_to_si, 
			cells[n].y * units.horizontal.input_to_si,
			cells[i].z * units.vertical.input_to_si, 
			cells[n].z * units.vertical.input_to_si);
		element_number++;
	}
	output_msg(OUTPUT_HST,"C.....Use as many 2.9.1 lines as necessary\n");
	output_msg(OUTPUT_HST,"C.2.9.2 .. End with END\n");
	output_msg(OUTPUT_HST,"END\n");
/*
 *   Hydraulic conductivity
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Porous media property information\n");
	output_msg(OUTPUT_HST,"C.2.10.1 .. KXX(IPMZ),KYY(IPMZ),KZZ(IPMZ),IPMZ=1 to NPMZ [1.7]\n");
	for (i = 0; i < nxyz; i++) {
		if (cells[i].is_element == FALSE) continue;
		if (cells[i].elt_active == FALSE) continue;
		cells[i].x_perm = cells[i].kx * fluid_viscosity / (fluid_density * GRAVITY);
		cells[i].y_perm = cells[i].ky * fluid_viscosity / (fluid_density * GRAVITY);
		cells[i].z_perm = cells[i].kz * fluid_viscosity / (fluid_density * GRAVITY);
	}
/*
 *   kx, ky, kz
 */
	output_msg(OUTPUT_HST,"C... X permeability\n");
	write_double_element_property(offsetof(struct cell, x_perm), units.k.input_to_si);
	output_msg(OUTPUT_HST,"C... Y permeability\n");
	write_double_element_property(offsetof(struct cell, y_perm), units.k.input_to_si);
	output_msg(OUTPUT_HST,"C... Z permeability\n");
	write_double_element_property(offsetof(struct cell, z_perm), units.k.input_to_si);
/*
 *   Porosity
 */
	output_msg(OUTPUT_HST,"C.2.10.2 .. POROS(IPMZ),IPMZ=1 to NPMZ [1.7]\n");
	write_double_element_property(offsetof(struct cell, porosity), 1.0);
/*
 *   specific storage to compressibility
 */
	storage_warning = FALSE;
	for (i = 0; i < nxyz; i++) {
		if (cells[i].is_element == FALSE) continue;
		if (cells[i].elt_active == FALSE) continue;
		if (free_surface == FALSE) {
			cells[i].compress = cells[i].storage * units.s.input_to_si / (fluid_density * GRAVITY) - cells[i].porosity * fluid_compressibility;
		} else {
			cells[i].compress = 0.0;
		}
		if (cells[i].compress < 0.0) {
			storage_warning = TRUE;
		}
	}
	/*
	if (free_surface == TRUE) {
		warning_msg("Aquifer compressibility has been set to zero for free surface calculation.");	
	}
	*/
	if (free_surface == FALSE && storage_warning == TRUE) {
		input_error++;
		sprintf(error_string, "Specific storage (S) results in a negative aquifer compressibility (a),"
			"a = S/(density*G) - porosity * B\n"
			"\tTo have specific storage this small you must reduce the fluid compressibility (B) in FLUID_PROPERTIES, -compressibility.");
		error_msg(error_string, CONTINUE);
	}
	output_msg(OUTPUT_HST,"C.2.10.3 .. ABPM(IPMZ),IPMZ=1 to NPMZ [1.7]\n");
	write_double_element_property(offsetof(struct cell, compress), 1.0);
/*
 *   skip thermal property
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Porous media thermal property information\n");
	output_msg(OUTPUT_HST,"C.2.11.1 .. RCPPM(IPMZ),IPMZ=1 to NPMZ [1.7];(O) - HEAT [1.4]\n");
	output_msg(OUTPUT_HST,"C.2.11.2 .. KTXPM(IPMZ),KTYPM(IPMZ),KTZPM(IPMZ),IPMZ=1 to NPMZ [1.7];(O) -\n");
	output_msg(OUTPUT_HST,"C..          HEAT [1.4]\n");
/*
 *  dispersivity
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Porous media solute and thermal dispersion information\n");
	output_msg(OUTPUT_HST,"C.2.12 .. ALPHL(IPMZ),ALPHT(IPMZ),IPMZ=1 to NPMZ [1.7];(O) - SOLUTE [1.4] \n");
	output_msg(OUTPUT_HST,"C..          and/or HEAT [1.4]\n");
	output_msg(OUTPUT_HST,"C.2.10.3 .. ABPM(IPMZ),IPMZ=1 to NPMZ [1.7]\n");
/*
 *   longitudinal dispersivity
 */
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"C...longitudinal dispersivity\n");
		write_double_element_property(offsetof(struct cell, alpha_long), units.alpha.input_to_si);
	}
/*
 *   transverse dispersivity
 */
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"C...horizontal dispersivity\n");
		write_double_element_property(offsetof(struct cell, alpha_horizontal), units.alpha.input_to_si);
		output_msg(OUTPUT_HST,"C...vertical dispersivity\n");
		write_double_element_property(offsetof(struct cell, alpha_vertical), units.alpha.input_to_si);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_source_sink(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes source sink data, NOT USED
 *
 *      Arguments:
 *         none
 *
 */
	int i, j, code;
	double diameter;
/*
 *   Skip solute property
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Porous media solute property information\n");
	output_msg(OUTPUT_HST,"C.2.13 .. DBKD(IPMZ),IPMZ=1 to NPMZ [1.7];(O) - SOLUTE [1.4]\n");
	output_msg(OUTPUT_HST,"C...REMOVED...\n");
/*
 *    Source-sink well information
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Source-sink well information\n");
	output_msg(OUTPUT_HST,"C.2.14.1 .. IWEL,XW,YW,ZBW,ZTW,WBOD,WQMETH[I];(O) - NWEL [1.6] >0\n");
	output_msg(OUTPUT_HST,"C.2.14.1 .. well id number,x,y, diameter, wqmeth\n");
	output_msg(OUTPUT_HST,"C.2.14.2 .. WCF(L);L = 1 to NZ (EXCLUSIVE) by ELEMENT\n");
	output_msg(OUTPUT_HST,"C.2.14.2 .. cell number, fraction of cell that is screened\n");
	output_msg(OUTPUT_HST,"C.2.14.3 .. WSF(L);L = 1 to NZ (EXCLUSIVE) by ELEMENT\n");
	output_msg(OUTPUT_HST,"C.2.14.4 .. WRISL,WRID,WRRUF,WRANGL;(O) - NWEL [1.6] >0 and\n");
	output_msg(OUTPUT_HST,"C..          WRCALC(WQMETH [2.14.3] >30)\n");
	output_msg(OUTPUT_HST,"C.2.14.5 .. HTCWR,DTHAWR,KTHAWR,KTHWR,TABWR,TATWR;(O) - NWEL [1.6] >0\n");
	output_msg(OUTPUT_HST,"C..          WRCALC(WQMETH [2.14.3] >30) and HEAT [1.4]\n");
	output_msg(OUTPUT_HST,"C.....Use as many sets of 2.14.1-5 lines as necessary for each well\n");
	output_msg(OUTPUT_HST,"C.2.14.6 .. End with END\n");
	output_msg(OUTPUT_HST,"C.2.14.7 .. MXITQW{14},TOLDPW{6.E-3},TOLFPW{.001},TOLQW{.001},DAMWRC{2.},\n");
	output_msg(OUTPUT_HST,"C..          DZMIN{.01},EPSWR{.001};(O) - NWEL [1.6] >0\n");
	output_msg(OUTPUT_HST,"C..          and WRCALC(WQMETH[2.14.3] >30)\n");
	if (well_defined == TRUE) {
		output_msg(OUTPUT_HST,"C..  well number, x, y, diameter, wqmeth\n");
		output_msg(OUTPUT_HST,"C..  well number, x, y, zb, zt, db, dt, diameter, wqmeth\n");
		for (i = 0; i < count_wells; i++) {
			if (wells[i].diameter_defined == TRUE) {
				diameter = wells[i].diameter;
			} else {
				diameter = wells[i].radius*2;
			}
			if (wells[i].mobility_and_pressure == TRUE) {
				code = 10;
			} else {
				code = 11;
			}
			output_msg(OUTPUT_HST,"%d %16.7e %16.7e %16.7e %16.7e  %16.7e %16.7e %e %d\n", 
				wells[i].n_user, 
				wells[i].x * units.horizontal.input_to_si, 
				wells[i].y * units.horizontal.input_to_si, 
				wells[i].screen_bottom * units.vertical.input_to_si, 
				wells[i].screen_top * units.vertical.input_to_si, 
				wells[i].screen_depth_bottom * units.vertical.input_to_si, 
				wells[i].screen_depth_top * units.vertical.input_to_si, 
				diameter * units.well_diameter.input_to_si, 
				code);
			/* output_msg(OUTPUT_HST,"C..  cell number, cell fraction\n"); */
			output_msg(OUTPUT_HST,"C..  cell number, screened interval below node (m), screened interval above node (m)\n"); 
			for (j = 0; j < wells[i].count_cell_fraction; j++) {
				/* output_msg(OUTPUT_HST,"\t%d %e\n", wells[i].cell_fraction[j].cell + 1, wells[i].cell_fraction[j].f); */
				output_msg(OUTPUT_HST,"\t%d %e %e\n", wells[i].cell_fraction[j].cell + 1, wells[i].cell_fraction[j].lower * units.vertical.input_to_si, wells[i].cell_fraction[j].upper * units.vertical.input_to_si); 
			}
				
			output_msg(OUTPUT_HST,"END\n");
		}
		output_msg(OUTPUT_HST,"END\n");
	}
	
	return(OK);
}

/* ---------------------------------------------------------------------- */
int write_bc_static(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes bc zones
 *
 *      Arguments:
 *         none
 *
 */

	int i, j, n;
	double elevation, factor;
	double river_k, thickness;
	double area, w0, w1, leakance, z, z0, z1;
	int river_number, point_number;
/*
 *  Write zones
 */ 
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Boundary condition information\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
/*
 *   Specified value
 */
	output_msg(OUTPUT_HST,"C.....     Specified value b.c.\n");
	output_msg(OUTPUT_HST,"C.2.15 .. IBC by x,y,z range {0.1-0.3} with no IMOD parameter;(O) -\n");
	output_msg(OUTPUT_HST,"C..          NSBC [1.6] > 0\n");

	if (count_specified > 0) {
		for (i = 0; i < nxyz; i++) {
			if (cells[i].cell_active == FALSE) continue;
			if (cells[i].bc_type == SPECIFIED) {
				output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
					cells[i].x * units.horizontal.input_to_si,
					cells[i].x * units.horizontal.input_to_si,
					cells[i].y * units.horizontal.input_to_si, 
					cells[i].y * units.horizontal.input_to_si,
					cells[i].z * units.vertical.input_to_si, 
					cells[i].z * units.vertical.input_to_si);
				if (flow_only == TRUE) {
					j = 0;
				} else {
				/* 1 specified pressure */
				/* 2 temperature = 0 */
				/* 3 solution  0 = associated, 1 = specified */
					if (cells[i].bc_face[0].bc_solution_type == ASSOCIATED) {
						j = 0;
					} else {
						j = 1;
					}
				}
				output_msg(OUTPUT_HST,"10%d\n", j);
			}
		}
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   Flux
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....     Specified flux b.c.\n");
	output_msg(OUTPUT_HST,"C.2.16 .. IBC by x,y,z range {0.1-0.3} with no IMOD parameter;(O) -\n");
	output_msg(OUTPUT_HST,"C..          NFBC [1.6] > 0\n");
	if (count_flux > 0 ) {
		for (i = 0; i < nxyz; i++) {
			if (cells[i].cell_active == FALSE) continue;
			if (cells[i].bc_type == SPECIFIED) continue;
			for (j = 0; j < 3; j++) {
				if (cells[i].bc_face[j].bc_type == FLUX) {
					output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
						cells[i].x * units.horizontal.input_to_si,
						cells[i].x * units.horizontal.input_to_si,
						cells[i].y * units.horizontal.input_to_si, 
						cells[i].y * units.horizontal.input_to_si,
						cells[i].z * units.vertical.input_to_si, 
						cells[i].z * units.vertical.input_to_si);
				
					/* 1 direction 1=x */
					/* 2 0 */
					/* 3 0 */
					/* 4 2 = fluid flux */
					/* 5 0 head flux */
					/* 6 0 pure solute flux */
					output_msg(OUTPUT_HST,"%d00200\n", j + 1);
				}
			}
		}
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   LEAKY
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....     Aquifer and river leakage b.c.\n");
	output_msg(OUTPUT_HST,"C.2.16.1 .. IBC by x,y,z range {0.1-0.3} with no IMOD parameter;(O) -\n");
	output_msg(OUTPUT_HST,"C..          NLBC [1.6] >0\n");

	/* zone, index codes */
	if (count_leaky > 0) {
		for (i = 0; i < nxyz; i++) {
			if (cells[i].cell_active == FALSE) continue;
			if (cells[i].bc_type == SPECIFIED) continue;
			for (j = 0; j < 3; j++) {
				if (cells[i].bc_face[j].bc_type == LEAKY) {
					output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
						cells[i].x * units.horizontal.input_to_si,
						cells[i].x * units.horizontal.input_to_si,
						cells[i].y * units.horizontal.input_to_si, 
						cells[i].y * units.horizontal.input_to_si,
						cells[i].z * units.vertical.input_to_si, 
						cells[i].z * units.vertical.input_to_si);
					/* 2 0 */
					/* 3 0 */
					/* 4 3 = leakage */
					/* 5 0 head flux */
					/* 6 0 pure solute flux */
					output_msg(OUTPUT_HST,"%d00300\n", j + 1);
				}

			}
		}
		output_msg(OUTPUT_HST,"END\n");
		
		/* zone, hydraulic conductivity, thickness, elevation */
		output_msg(OUTPUT_HST,"C.2.16.2 .. KLBC,BBLBC,ZELBC by x,y,z range {0.1-0.3};(O) - NLBC [1.6] >0\n");
		for (i = 0; i < nxyz; i++) {
			if (cells[i].cell_active == FALSE) continue;
			if (cells[i].bc_type == SPECIFIED) continue;
			for (j = 0; j < 3; j++) {
				if (cells[i].bc_face[j].bc_type == LEAKY) {
					if (j == 2) {
						if (cells[i].iz == 0) {
							factor = -1.0;
						} else if (cells[i].iz == (nz - 1)) {
							factor = 1.0;
						} else {
							n = ijk_to_n(cells[i].ix, cells[i].iy, cells[i].iz - 1);
							if (cells[n].cell_active == FALSE) {
								factor = -1.0;
							} else {
								factor = 1.0;
							}
						}

						elevation = cells[i].z * units.vertical.input_to_si  
							+ factor * cells[i].bc_face[j].bc_thick * units.leaky_thick.input_to_si;
					} else {
						elevation = cells[i].z * units.vertical.input_to_si;
					}
					output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
						cells[i].x * units.horizontal.input_to_si,
						cells[i].x * units.horizontal.input_to_si,
						cells[i].y * units.horizontal.input_to_si, 
						cells[i].y * units.horizontal.input_to_si,
						cells[i].z * units.vertical.input_to_si, 
						cells[i].z * units.vertical.input_to_si);

					/* convert bc_k to permeability */
					output_msg(OUTPUT_HST,"     %11g 1 %11g 1 %11g 1\n", 
						cells[i].bc_face[j].bc_k * units.leaky_k.input_to_si * fluid_viscosity / (fluid_density * GRAVITY), 
						cells[i].bc_face[j].bc_thick * units.leaky_thick.input_to_si, 
						elevation);
				}
			}
		}
		output_msg(OUTPUT_HST,"END\n");
	}

/*
 *   River leakage bc,
 */
	output_msg(OUTPUT_HST,"C.....          River leakage b.c.\n");
	output_msg(OUTPUT_HST,"C.2.16.3 .. X1,Y1,X2,Y2,KRBC,BBRBC,ZERBC;(O) - NLBC [1.6] > 0\n");
	output_msg(OUTPUT_HST,"C.2.16.3 .. cell number, area, leakance, z\n");
	output_msg(OUTPUT_HST,"C.2.16.4 .. End with END\n");

        if (count_river_segments > 0) {
		for (i = 0; i < count_cells; i++) {
			if (cells[i].cell_active == FALSE) continue;
			if (cells[i].bc_type == SPECIFIED) continue;
			if (cells[i].bc_face[2].bc_type == LEAKY) continue;

			for (j = 0; j < cells[i].count_river_polygons; j++) {
				area = cells[i].river_polygons[j].area * units.horizontal.input_to_si * units.horizontal.input_to_si;
				river_number = cells[i].river_polygons[j].river_number;
				point_number = cells[i].river_polygons[j].point_number;
				w0 = cells[i].river_polygons[j].w;
				w1 = 1. - w0;
				river_k = (rivers[river_number].points[point_number].k*w0 + rivers[river_number].points[point_number + 1].k*w1) * units.river_bed_k.input_to_si;
				thickness = (rivers[river_number].points[point_number].thickness*w0 + rivers[river_number].points[point_number + 1].thickness*w1) * units.river_bed_thickness.input_to_si;

				leakance =  river_k / thickness * fluid_viscosity / (fluid_density * GRAVITY);

				/*  calculate bottom elevations, convert to SI*/

				if (rivers[river_number].points[point_number].z_defined == FALSE) {
					z0 = rivers[river_number].points[point_number].current_head * units.head.input_to_si - rivers[river_number].points[point_number].depth * units.vertical.input_to_si;
				} else {
					z0 = rivers[river_number].points[point_number].z * units.vertical.input_to_si;
				}
				if (rivers[river_number].points[point_number + 1].z_defined == FALSE) {
					z1 = rivers[river_number].points[point_number + 1].current_head * units.head.input_to_si - rivers[river_number].points[point_number + 1].depth * units.vertical.input_to_si;
				} else {
					z1 = rivers[river_number].points[point_number + 1].z * units.vertical.input_to_si;
				}

#ifdef SKIP
				z = (rivers[river_number].points[point_number].z*w0 + rivers[river_number].points[point_number + 1].z*w1) * units.vertical.input_to_si;
#endif
				z = (z0*w0 + z1*w1);

				/* cell no., area, leakance, z */
				output_msg(OUTPUT_HST,"%d %e %e %e\n", i + 1, area, leakance, z);
			}
		}
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   Aquifer influence functions NOT USED
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....     Aquifer influence functions\n");
	output_msg(OUTPUT_HST,"C.2.18.1 .. IBC by x,y,z range {0.1-0.3} with no IMOD parameter;(O) -\n");
	output_msg(OUTPUT_HST,"C..          NAIFC [1.6] > 0\n");
	output_msg(OUTPUT_HST,"C.2.18.2 .. UVAIFC by x,y,z range {0.1-0.3};(O) - NAIFC [1.6] > 0\n");
	output_msg(OUTPUT_HST,"C.2.18.3 .. IAIF;(O) - NAIFC [1.6] > 0\n");
	output_msg(OUTPUT_HST,"C.....          Pot  a.i.f.\n");
	output_msg(OUTPUT_HST,"C.2.18.4A .. ABOAR,POROAR,VOAR;(O) - IAIF [2.18.3] = 1\n");
	output_msg(OUTPUT_HST,"C.....          Transient, Carter-Tracy a.i.f.\n");
	output_msg(OUTPUT_HST,"C.2.18.4B .. KOAR,ABOAR,VISOAR,POROAR,BOAR,RIOAR,ANGOAR;(O) -\n");
	output_msg(OUTPUT_HST,"C..          IAIF [2.18.3] = 2\n");
/*
 *   Heat bc NOT USED
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....     Heat conduction b.c.\n");
	output_msg(OUTPUT_HST,"C.2.19.1 .. ZHCBC(K);(O) - HEAT [1.4] and NHCBC [1.6] > 0\n");
	output_msg(OUTPUT_HST,"C.2.19.2 .. IBC by x,y,z range {0.1-0.3} with no IMOD parameter;(O) - \n");
	output_msg(OUTPUT_HST,"c..          HEAT [1.4] and NHCBC [1.6] > 0\n");
	output_msg(OUTPUT_HST,"C.2.19.3 .. UDTHHC by x,y,z range {0.1-0.3} FOR HCBC NODES;(O) -\n");
	output_msg(OUTPUT_HST,"C..          HEAT [1.4] and NHCBC [1.6] > 0\n");
	output_msg(OUTPUT_HST,"C.2.19.4 .. UKHCBC by x,y,z range {0.1-0.3} FOR HCBC NODES;(O) -\n");
	output_msg(OUTPUT_HST,"C..          HEAT [1.4] and NHCBC [1.6] > 0\n");
/*
 *   Free surface
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Free surface b.c.\n");
	output_msg(OUTPUT_HST,"C.2.20 .. FRESUR[T/F] ADJ_WR_RATIO[T/N]\n");
	if (free_surface == TRUE) {
		if (steady_flow == FALSE && adjust_water_rock_ratio == TRUE) {
			output_msg(OUTPUT_HST, "    t    t\n");
		} else {			
			output_msg(OUTPUT_HST, "    t    f\n");
		}
	} else {
		output_msg(OUTPUT_HST, "    f     f\n");
	}

	return(OK);
}

/* ---------------------------------------------------------------------- */
int write_ic(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes ic information
 *
 *      Arguments:
 *         none
 *
 */

	int i;
/*
 *  
 */ 
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Initial condition information\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.2.21.1 .. ICHYDP; [T/F]\n");
	output_msg(OUTPUT_HST,"     f\n");
	output_msg(OUTPUT_HST,"C.2.21.2 .. ICHWT[T/F];(O) - FRESUR [2.20]\n");
	if (free_surface == TRUE) {
		output_msg(OUTPUT_HST,"f\n");
	}
	output_msg(OUTPUT_HST,"C.2.21.3A .. ZPINIT,PINIT;(O) - ICHYDP [2.21.1] and NOT ICHWT [2.21.2]\n");
	output_msg(OUTPUT_HST,"C.2.21.3B .. P by x,y,z range {0.1-0.3};(O) - NOT ICHYDP [2.21.1] and\n");
	output_msg(OUTPUT_HST,"C..          NOT ICHWT [2.21.2]\n");
/*
 *   Initial head distribution by node
 */	
	
	output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
		cells[0].x * units.horizontal.input_to_si, 
		cells[nxyz-1].x * units.horizontal.input_to_si,
		cells[0].y * units.horizontal.input_to_si, 
		cells[nxyz-1].y * units.horizontal.input_to_si,
		cells[0].z * units.vertical.input_to_si, 
		cells[nxyz-1].z * units.vertical.input_to_si);
	output_msg(OUTPUT_HST,"     0. 4\n");

	/* convert to pressure */
	for (i = 0; i < nxyz; i++) {
		if (cells[i].cell_active == FALSE) continue;
		cells[i].ic_pressure = fluid_density * GRAVITY * 
			(cells[i].ic_head * units.head.input_to_si - 
			 cells[i].z * units.vertical.input_to_si);
	}
	write_double_cell_property(offsetof(struct cell, ic_pressure), 1.0);
	output_msg(OUTPUT_HST,"END\n");
/* 
 *   NOT USED
 */
	output_msg(OUTPUT_HST,"C.2.21.3C .. HWT by x,y,z range {0.1-0.3};(O) - FRESUR [2.20] and\n");
	output_msg(OUTPUT_HST,"C..          ICHWT [2.21.2]\n");
	output_msg(OUTPUT_HST,"C.2.21.4B .. T by x,y,z range {0.1-0.3};(O) - HEAT [1.4] and NOT ICTPRO\n");
	output_msg(OUTPUT_HST,"C..           [2.21.1]\n");
	output_msg(OUTPUT_HST,"C.2.21.5 .. NZTPHC, ZTHC(I),TVZHC(I);(O) - HEAT [1.4] and NHCBC [1.6] >0,\n");
	output_msg(OUTPUT_HST,"C..          limit of 5\n");
	output_msg(OUTPUT_HST,"C.2.21.6B .. C by x,y,z range {0.1-0.3};(O) - SOLUTE [1.4] and NOT ICCPRO\n");
	output_msg(OUTPUT_HST,"C..           [2.21.1]\n");

/*
 *   Initial solution by node
 */	
	output_msg(OUTPUT_HST,"C...Initial solution \n");
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_solution.i1));
		write_integer_cell_property(offsetof(struct cell, ic_solution.i2));
		write_double_cell_property(offsetof(struct cell, ic_solution.f1), 1.0);
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   Initial equilibrium_phases by node
 */	
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"C...Initial equilibrium_phases \n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_equilibrium_phases.i1));
		write_integer_cell_property(offsetof(struct cell, ic_equilibrium_phases.i2));
		write_double_cell_property(offsetof(struct cell, ic_equilibrium_phases.f1), 1.0);
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   Initial exchange by node
 */	
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"C...Initial exchange\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_exchange.i1));
		write_integer_cell_property(offsetof(struct cell, ic_exchange.i2));
		write_double_cell_property(offsetof(struct cell, ic_exchange.f1), 1.0);
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   Initial surface by node
 */	
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"C...Initial surface\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_surface.i1));
		write_integer_cell_property(offsetof(struct cell, ic_surface.i2));
		write_double_cell_property(offsetof(struct cell, ic_surface.f1), 1.0);
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   Initial gas_phase by node
 */	
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"C...Initial gas_phase\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_gas_phase.i1));
		write_integer_cell_property(offsetof(struct cell, ic_gas_phase.i2));
		write_double_cell_property(offsetof(struct cell, ic_gas_phase.f1), 1.0);
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   Initial solid_solutions by node
 */	
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"C...Initial solid_solutions\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_solid_solutions.i1));
		write_integer_cell_property(offsetof(struct cell, ic_solid_solutions.i2));
		write_double_cell_property(offsetof(struct cell, ic_solid_solutions.f1), 1.0);
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   Initial kinetics by node
 */	
	if (flow_only == FALSE) {
		output_msg(OUTPUT_HST,"C...Initial kinetics\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_kinetics.i1));
		write_integer_cell_property(offsetof(struct cell, ic_kinetics.i2));
		write_double_cell_property(offsetof(struct cell, ic_kinetics.f1), 1.0);
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   Done with initial conditions
 */	
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_calculation_static(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes calculation information
 *
 *      Arguments:
 *         none
 *
 */

	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Calculation information\n");
	output_msg(OUTPUT_HST,"C.2.22.1 .. FDSMTH,FDTMTH\n");
	output_msg(OUTPUT_HST,"     %g  %g\n", solver_space, solver_time);
	output_msg(OUTPUT_HST,"C.2.22.1a .. CROSD [T/F]\n");
	if (flow_only != TRUE) {
		if (cross_dispersion == TRUE) {
			output_msg(OUTPUT_HST,"     T\n");
		} else {
			output_msg(OUTPUT_HST,"     F\n");
		}
	}
	output_msg(OUTPUT_HST,"C.2.22.2 .. TOLDEN{.001},MAXITN{5}\n");
	output_msg(OUTPUT_HST,"     .001  %d\n", max_ss_iterations);

#ifdef SKIP	
	output_msg(OUTPUT_HST,"C.2.22.3 .. EPSFS;(O) - FRESUR [2.20]\n");
	if (free_surface == TRUE) {
		output_msg(OUTPUT_HST,"     1.e-4\n");
	}
#endif

	output_msg(OUTPUT_HST,"C.....     Red-black restarted conjugate gradient solver\n");
	output_msg(OUTPUT_HST,"C.2.22.5 .. IDIR,MILU,NSDR,EPSSLV{1.e-8},MAXIT2{500};\n");
	output_msg(OUTPUT_HST,"C..          (O) - SLMETH [1.8] = 3\n");
	if (solver_method == ITERATIVE) {
		output_msg(OUTPUT_HST,"     1 t %d %g %d\n", solver_save_directions,
		       solver_tolerance, solver_maximum);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_output_static(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes static output information
 *
 *      Arguments:
 *         none
 *
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Output information\n");
	output_msg(OUTPUT_HST,"C.2.23.1 .. PRTPMP,PRTFP,PRTBC,PRTSLM,PRTWEL,PRT_KD; all [T/F]\n");
	output_msg(OUTPUT_HST,"     ");
	if (print_input_media == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_media == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_fluid == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_fluid == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_bc == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_bc == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_method == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_method == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_wells == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_wells == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_conductances == TRUE) output_msg(OUTPUT_HST, "t \n");
	if (print_input_conductances == FALSE) output_msg(OUTPUT_HST, "f \n");

	output_msg(OUTPUT_HST,"C.2.23.2 .. PRTIC_C, PRTIC_MAPC, PRTIC_P, PRTIC_MAPHEAD, PRTIC_SS_VEL, PRTIC_XYZ_SS_VEL, PRTIC_CONC, PRTIC_FORCE_CHEM; all [T/F]\n");
	output_msg(OUTPUT_HST,"     ");
	if (print_input_comp == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_comp == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_xyz_comp == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_xyz_comp == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_head == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_head == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_xyz_head == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_xyz_head == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_ss_vel == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_ss_vel == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_xyz_ss_vel == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_xyz_ss_vel == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_xyz_chem == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_xyz_chem == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_force_chem == TRUE) output_msg(OUTPUT_HST, "t \n");
	if (print_input_force_chem == FALSE) output_msg(OUTPUT_HST, "f \n");

	output_msg(OUTPUT_HST,"C.2.23.2.1 .. PRTIC_HDF_CONC, PRTIC_HDF_HEAD, PRTIC_HDF_SS_VEL; all [T/F]\n");
	output_msg(OUTPUT_HST,"     ");
	if (print_input_hdf_chem == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_hdf_chem == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_hdf_head == TRUE) output_msg(OUTPUT_HST, "t ");
	if (print_input_hdf_head == FALSE) output_msg(OUTPUT_HST, "f ");
	if (print_input_hdf_ss_vel == TRUE) output_msg(OUTPUT_HST, "t \n");
	if (print_input_hdf_ss_vel == FALSE) output_msg(OUTPUT_HST, "f \n");

	output_msg(OUTPUT_HST,"C.2.23.3 .. ORENPR[I];(O) - NOT CYLIND [1.4]\n");
	if (print_input_xy == TRUE) {
		output_msg(OUTPUT_HST,"     12\n");
	} else {
		output_msg(OUTPUT_HST,"     13\n");
	}
	output_msg(OUTPUT_HST,"C.2.23.4 .. PLTZON[T/F];(O) - PRTPMP [2.23.1]\n");
	if (print_input_media == TRUE) {
		output_msg(OUTPUT_HST,"     f\n");
	}
	output_msg(OUTPUT_HST,"C.2.23.5 .. PRTIC_XYZ_WELL[T/F]\n");
	if (print_input_xyz_wells == TRUE) output_msg(OUTPUT_HST, "t \n");
	if (print_input_xyz_wells == FALSE) output_msg(OUTPUT_HST, "f \n");
/*
 *   Print information by node
 */	
	if (flow_only == FALSE) {
		/* O.chem file */
		output_msg(OUTPUT_HST,"C...Cell print information for O.chem, initial conditions\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_chem));
		output_msg(OUTPUT_HST,"END\n");
		/* xyz.chem file */
		output_msg(OUTPUT_HST,"C...Cell print information for xyz.chem, initial conditions\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_xyz));
		output_msg(OUTPUT_HST,"END\n");
#ifdef SKIP		
		/* h5 file */
		output_msg(OUTPUT_HST,"C...Cell print information for h5, initial conditions\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_hdf));
		output_msg(OUTPUT_HST,"END\n");
#endif
	}
/*
 *   Thru is false here
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C..... TRANSIENT DATA - READ3\n");
	output_msg(OUTPUT_HST,"C.3.1 .. THRU[T/F]\n");
	output_msg(OUTPUT_HST,"     f\n");
	output_msg(OUTPUT_HST,"C.....If THRU is true, proceed to record 3.99\n");

	return(OK);
}

/* ---------------------------------------------------------------------- */
int write_bc_transient(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes transient bc data
 *
 *      Arguments:
 *         none
 *
 */
	int i, j, k;
	int river_number, point_number, solution1, solution2;
	double w0, w1, head;
	int solution;
	int def1, def2;
/*
 *  Write zones
 */ 
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....The following is for NOT THRU\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Source-sink well information\n");
	output_msg(OUTPUT_HST,"C.3.2.1 .. RDWTD[T/F];(O) - NWEL [1.6] > 0\n");
	if (count_wells > 0) {
		if (well_defined == TRUE) {
			output_msg(OUTPUT_HST,"\tT\n");
		} else {
			output_msg(OUTPUT_HST,"\tF\n");
		}
	} 
	output_msg(OUTPUT_HST,"C.3.2.2 .. IWEL,QWV,PWSUR,PWKT,TWSRKT,CWKT;(O) - RDWTD [3.2.1] \n");
	output_msg(OUTPUT_HST,"C.....Use as many 3.2.2 lines as necessay\n");
	output_msg(OUTPUT_HST,"C.3.2.3 .. End with END\n");
	if (count_wells > 0 && well_defined == TRUE) {
		output_msg(OUTPUT_HST,"C..  well sequence number, q, solution number\n");
		for (i = 0; i < count_wells; i++) {
			if (wells[i].update == TRUE) {
				if (wells[i].solution_defined == TRUE) {
					solution = wells[i].current_solution; 
				} else {
					solution = -1;
				}
				output_msg(OUTPUT_HST,"%d %e %d\n", 
					i + 1,
					wells[i].current_q * units.well_pumpage.input_to_user, 
					solution);
			}				
		}
		output_msg(OUTPUT_HST,"END\n");
	}

	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Boundary condition information\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
/*
 *   Specified value
 */
	output_msg(OUTPUT_HST,"C.....     Specified value b.c.\n");
	output_msg(OUTPUT_HST,"C.3.3.1 .. RDSPBC,RDSTBC,RDSCBC; all [T/F];(O) - NSBC [1.6] > 0\n");
	if (count_specified > 0 && bc_specified_defined == TRUE) {
		output_msg(OUTPUT_HST,"     t f f\n");
	} else if (count_specified > 0 && bc_specified_defined == FALSE) {
		output_msg(OUTPUT_HST,"     f f f\n");
	}
	if (count_specified > 0 && bc_specified_defined == TRUE) {
		output_msg(OUTPUT_HST,"C.3.3.2 .. PNP B.C. by x,y,z range {0.1-0.3};(O) - RDSPBC [3.3.1]\n");

		/* write head data for every node */
		output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0.0  4\n");

		/* Convert bc_head to bc_pressure */
		for (i = 0; i < nxyz; i++) {
			cells[i].value = 0;
			if (cells[i].cell_active == FALSE) continue;
			if (cells[i].bc_type == SPECIFIED) {
				cells[i].value = fluid_density * GRAVITY * 
					(cells[i].bc_face[0].bc_head * units.head.input_to_si -
					 cells[i].z * units.vertical.input_to_si);
			}
		}
		write_double_cell_property(offsetof(struct cell, value), 1.0);
		output_msg(OUTPUT_HST,"END\n");

		/* heat NOT USED */
		output_msg(OUTPUT_HST,"C.3.3.3 .. TSBC by x,y,z range {0.1-0.3};(O) - RDSPBC [3.3.1] and\n");
		output_msg(OUTPUT_HST,"C..          HEAT [1.4]\n");

		/* write solution data for every node */
		output_msg(OUTPUT_HST,"C.3.3.4 .. CSBC by x,y,z range {0.1-0.3}; (O) - RDSPBC [3.3.1] and\n");
		output_msg(OUTPUT_HST,"C..          SOLUTE [1.4]\n");
		if (flow_only == FALSE) {
			output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				cells[0].x * units.horizontal.input_to_si, 
				cells[nxyz-1].x * units.horizontal.input_to_si,
				cells[0].y * units.horizontal.input_to_si, 
				cells[nxyz-1].y * units.horizontal.input_to_si,
				cells[0].z * units.vertical.input_to_si, 
				cells[nxyz-1].z * units.vertical.input_to_si);
			output_msg(OUTPUT_HST,"     0 4 0 4 0 4\n");
			write_integer_cell_property(offsetof(struct cell, bc_face[0].bc_solution.i1));
			write_integer_cell_property(offsetof(struct cell, bc_face[0].bc_solution.i2));
			write_double_cell_property(offsetof(struct cell, bc_face[0].bc_solution.f1), 1.0);
			output_msg(OUTPUT_HST,"END\n");
		}

	} else {
		output_msg(OUTPUT_HST,"C.3.3.2 .. PNP B.C. by x,y,z range {0.1-0.3};(O) - RDSPBC [3.3.1]\n");
		output_msg(OUTPUT_HST,"C.3.3.3 .. TSBC by x,y,z range {0.1-0.3};(O) - RDSPBC [3.3.1] and\n");
		output_msg(OUTPUT_HST,"C..          HEAT [1.4]\n");
		output_msg(OUTPUT_HST,"C.3.3.4 .. CSBC by x,y,z range {0.1-0.3}; (O) - RDSPBC [3.3.1] and\n");
		output_msg(OUTPUT_HST,"C..          SOLUTE [1.4]\n");
	}


	/* NOT USED, Both specified and associated solutions are defined with 3.3.1 */
	output_msg(OUTPUT_HST,"C.3.3.5 .. TNP B.C. by x,y,z range {0.1-0.3};(O) - RDSTBC [3.3.1] and\n");
	output_msg(OUTPUT_HST,"C..          HEAT [1.4]\n");
	output_msg(OUTPUT_HST,"C.3.3.6 .. CNP B.C. by x,y,z range {0.1-0.3};(O) - RDSCBC [3.3.1] and\n");
	output_msg(OUTPUT_HST,"C..          SOLUTE [1.4]\n");
	/* rdscbc always false */
/*
 *   Flux
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....     Specified flux b.c.\n");
	output_msg(OUTPUT_HST,"C.3.4.1 .. RDFLXQ,RDFLXH,RDFLXS; all [T/F];(O) - NFBC [1.6] > 0\n");
	if (count_flux > 0 && bc_flux_defined == TRUE) {
		output_msg(OUTPUT_HST,"     t f f\n");
	} else if (count_flux > 0 && bc_flux_defined == FALSE) {
		output_msg(OUTPUT_HST,"     f f f\n");
	}
	if (count_flux > 0 && bc_flux_defined == TRUE) {
		output_msg(OUTPUT_HST,"C.3.4.2 .. QFFX,QFFY,QFFZ B.C. by x,y,z range {0.1-0.3};(O) -\n");
		output_msg(OUTPUT_HST,"C..          RDFLXQ [3.4.1]\n");

		/* write flux data for every node */
		output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0.0  4\n");

		/* Accumulate flux bc info in value */
		for (i = 0; i < nxyz; i++) {
			cells[i].value = 0;
			if (cells[i].cell_active == FALSE) continue;
			if (cells[i].bc_type != SPECIFIED) {
				for (j = 0; j < 3; j++) {
					if (cells[i].bc_face[j].bc_type == FLUX) {
						cells[i].value = cells[i].bc_face[j].bc_flux * units.flux.input_to_user;
					}
				}
			}
		}
		write_double_cell_property(offsetof(struct cell, value), 1.0);
		output_msg(OUTPUT_HST,"END\n");

		/* Density */
		output_msg(OUTPUT_HST,"C.3.4.3 .. UDENBC  by x,y,z range {0.1-0.3};(O) - RDFLXQ [3.4.1]\n");
		output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     %g  1\n", fluid_density);
		output_msg(OUTPUT_HST,"END\n");

		/* NOT USED */
		output_msg(OUTPUT_HST,"C.3.4.4 .. TFLX B.C. by x,y,z range {0.1-0.3};(O) - RDFLXQ [3.4.1] and\n");
		output_msg(OUTPUT_HST,"C..          HEAT [1.4]\n");

		/* write solution data for every node */
		output_msg(OUTPUT_HST,"C.3.4.5 .. CFLX B.C. by x,y,z range {0.1-0.3};(O) - RDFLXQ [3.4.1] and\n");
		output_msg(OUTPUT_HST,"C..          SOLUTE [1.4]\n");
		if (flow_only == FALSE) {
			output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				cells[0].x * units.horizontal.input_to_si, 
				cells[nxyz-1].x * units.horizontal.input_to_si,
				cells[0].y * units.horizontal.input_to_si, 
				cells[nxyz-1].y * units.horizontal.input_to_si,
				cells[0].z * units.vertical.input_to_si, 
				cells[nxyz-1].z * units.vertical.input_to_si);
			output_msg(OUTPUT_HST,"     0 4 0 4 0 4\n");

			/* Accumulate solution info in integer_value */
			for (i = 0; i < nxyz; i++) {
				mix_init(&cells[i].temp_mix);
				if (cells[i].cell_active == FALSE) continue;
				if (cells[i].bc_type != SPECIFIED) {
					for (j = 0; j < 3; j++) {
						if (cells[i].bc_face[j].bc_type == FLUX) {
							cells[i].temp_mix.i1 = cells[i].bc_face[j].bc_solution.i1;
							cells[i].temp_mix.i2 = cells[i].bc_face[j].bc_solution.i2;
							cells[i].temp_mix.f1 = cells[i].bc_face[j].bc_solution.f1;
						}
					}
				}
			}
			write_integer_cell_property(offsetof(struct cell, temp_mix.i1));
			write_integer_cell_property(offsetof(struct cell, temp_mix.i2));
			write_double_cell_property(offsetof(struct cell, temp_mix.f1), 1.0);
			output_msg(OUTPUT_HST,"END\n");
		}
	} else {
		output_msg(OUTPUT_HST,"C.3.4.2 .. QFFX,QFFY,QFFZ B.C. by x,y,z range {0.1-0.3};(O) -\n");
		output_msg(OUTPUT_HST,"C..          RDFLXQ [3.4.1]\n");
		output_msg(OUTPUT_HST,"C.3.4.3 .. UDENBC  by x,y,z range {0.1-0.3};(O) - RDFLXQ [3.4.1]\n");
		output_msg(OUTPUT_HST,"C.3.4.4 .. TFLX B.C. by x,y,z range {0.1-0.3};(O) - RDFLXQ [3.4.1] and\n");
		output_msg(OUTPUT_HST,"C..          HEAT [1.4]\n");
		output_msg(OUTPUT_HST,"C.3.4.5 .. CFLX B.C. by x,y,z range {0.1-0.3};(O) - RDFLXQ [3.4.1] and\n");
		output_msg(OUTPUT_HST,"C..          SOLUTE [1.4]\n");
	}

	/* NOT USED */
	output_msg(OUTPUT_HST,"C.3.4.6 .. QHFX,QHFY,QHFZ B.C. by x,y,z range {0.1-0.3};(O) - RDFLXH [3.4.5]\n");
	output_msg(OUTPUT_HST,"C.3.4.7 .. QSFX,QSFY,QSFZ B.C. by x,y,z range {0.1-0.3};(O) - RDFLXS [3.4.1]\n");
/*
 *   Leaky
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....     Leakage b.c.\n");
	output_msg(OUTPUT_HST,"C.3.5.1 .. RDLBC[T/F];(O) - NLBC [1.6] > 0\n");
	if (count_leaky > 0 ) {
		if (bc_leaky_defined == TRUE) {
			output_msg(OUTPUT_HST,"     t\n");
		} else if (bc_leaky_defined == FALSE) {
			output_msg(OUTPUT_HST,"     f\n");
		}
	}
	if (count_leaky > 0 && bc_leaky_defined == TRUE) {

		/* print g*head */
/*
 *   Convert bc_head to energy per unit mass
 */
		output_msg(OUTPUT_HST,"C.3.5.2a .. PHILBC by x,y,z range {0.1-0.3};(O) - RDLBC [3.5.1]\n");
		output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0.0  4 \n");
		for (i = 0; i < nxyz; i++) {
			cells[i].value = 0;
			if (cells[i].cell_active == FALSE) continue;
			if (cells[i].bc_type != SPECIFIED) {
				for (j = 0; j < 3; j++) {
					if (cells[i].bc_face[j].bc_type == LEAKY) {
						cells[i].value = GRAVITY * cells[i].bc_face[j].bc_head * units.head.input_to_si;
					}
				}
			}
		}
		write_double_cell_property(offsetof(struct cell, value), 1.0);
		output_msg(OUTPUT_HST,"END\n");

		output_msg(OUTPUT_HST,"C.3.5.2b .. DENLBC by x,y,z range {0.1-0.3};(O) - RDLBC [3.5.1]\n");
		output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     %g  1 \n", fluid_density);
		output_msg(OUTPUT_HST,"END\n");

		output_msg(OUTPUT_HST,"C.3.5.2c .. ,VISLBC by x,y,z range {0.1-0.3};(O) - RDLBC [3.5.1]\n");
		output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     %g  1\n", fluid_viscosity);
		output_msg(OUTPUT_HST,"END\n");
		
		/* NOT USED */
		output_msg(OUTPUT_HST,"C.3.5.3 .. TLBC by x,y,z range {0.1-0.3};(O) - RDLBC [3.5.1] and HEAT [1.4]\n");

		/* solution data for leaky bc */
		output_msg(OUTPUT_HST,"C.3.5.4 .. CLBC by x,y,z range {0.1-0.3};(O) - RDLBC [3.5.1] and SOLUTE [1.4]\n");
		if (flow_only == FALSE) {
			output_msg(OUTPUT_HST,"     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				cells[0].x * units.horizontal.input_to_si, 
				cells[nxyz-1].x * units.horizontal.input_to_si,
				cells[0].y * units.horizontal.input_to_si, 
				cells[nxyz-1].y * units.horizontal.input_to_si,
				cells[0].z * units.vertical.input_to_si, 
				cells[nxyz-1].z * units.vertical.input_to_si);
			output_msg(OUTPUT_HST,"     0 4 0 4 0 4\n");
			/* Accumulate solution info in integer_value */
			for (i = 0; i < nxyz; i++) {
				mix_init(&cells[i].temp_mix);
				if (cells[i].cell_active == FALSE) continue;
				if (cells[i].bc_type != SPECIFIED) {
					for (j = 0; j < 3; j++) {
						if (cells[i].bc_face[j].bc_type == LEAKY) {
							cells[i].temp_mix.i1 = cells[i].bc_face[j].bc_solution.i1;
							cells[i].temp_mix.i2 = cells[i].bc_face[j].bc_solution.i2;
							cells[i].temp_mix.f1 = cells[i].bc_face[j].bc_solution.f1;
							
						}
					}
				}
			}
			write_integer_cell_property(offsetof(struct cell, temp_mix.i1));
			write_integer_cell_property(offsetof(struct cell, temp_mix.i2));
			write_double_cell_property(offsetof(struct cell, temp_mix.f1), 1.0);
			output_msg(OUTPUT_HST,"END\n");
		}
	} else {
		output_msg(OUTPUT_HST,"C.3.5.2 .. PHILBC,DENLBC,VISLBC by x,y,z range {0.1-0.3};(O) - RDLBC [3.5.1]\n");
		output_msg(OUTPUT_HST,"C.3.5.3 .. TLBC by x,y,z range {0.1-0.3};(O) - RDLBC [3.5.1] and HEAT [1.4]\n");
		output_msg(OUTPUT_HST,"C.3.5.4 .. CLBC by x,y,z range {0.1-0.3};(O) - RDLBC [3.5.1] and SOLUTE [1.4]\n");
	}
	output_msg(OUTPUT_HST,"C.....River Leakage\n");
	output_msg(OUTPUT_HST,"C.3.5.5 .. RDRBC t/f\n");
	if (count_river_segments > 0) {
		if (river_defined == TRUE) {
			output_msg(OUTPUT_HST,"     t\n");
		} else if (river_defined == FALSE) {
			output_msg(OUTPUT_HST,"     f\n");
		}
	}
	output_msg(OUTPUT_HST,"C.3.5.5 .. X1,Y1,X2,Y2,HRBC,DENRBC,VISRBC,TRBC,CRBC;(O) - RDRBC [3.5.1]\n");
	output_msg(OUTPUT_HST,"C.....Use as many 3.5.5 lines as necessary\n");
	output_msg(OUTPUT_HST,"C.3.5.5 .. river segment number, head, solution 1, solution 2, weight solution 1\n");
	output_msg(OUTPUT_HST,"C.3.5.6 .. End with END\n");
	if (count_river_segments > 0 && river_defined == TRUE) {
		k = 1;
		for (i = 0; i < count_cells; i++) {
			if (cells[i].cell_active == FALSE) continue;
			if (cells[i].bc_type == SPECIFIED) continue;
			if (cells[i].bc_face[2].bc_type == LEAKY) continue;
			for (j = 0; j < cells[i].count_river_polygons; j++) {
				river_number = cells[i].river_polygons[j].river_number;
				point_number = cells[i].river_polygons[j].point_number;
				w0 = cells[i].river_polygons[j].w;
				w1 = 1. - w0;
				head = (rivers[river_number].points[point_number].current_head*w0 + rivers[river_number].points[point_number + 1].current_head*w1) * units.head.input_to_si;
				/*
				solution1 = rivers[river_number].points[point_number].solution;
				solution2 = rivers[river_number].points[point_number + 1].solution;
				*/
			        def1 = rivers[river_number].points[point_number].solution_defined;
				def2 = rivers[river_number].points[point_number + 1].solution_defined;
				if (def1 == TRUE && def2 == TRUE) {
					solution1 = rivers[river_number].points[point_number].current_solution;
					solution2 = rivers[river_number].points[point_number + 1].current_solution;
					w0 = w0;
				} else if (def1 == TRUE && def2 == FALSE) {
					assert (rivers[river_number].points[point_number].solution1 == rivers[river_number].points[point_number + 1].solution1);
					solution1 = rivers[river_number].points[point_number].current_solution;
					solution2 = rivers[river_number].points[point_number + 1].solution2;
					w0 = w0*(1.) + (1. - w0) * rivers[river_number].points[point_number + 1].f1;
				} else if (def1 == FALSE && def2 == TRUE) {
					assert (rivers[river_number].points[point_number].solution2 == rivers[river_number].points[point_number + 1].solution1);
					solution1 = rivers[river_number].points[point_number].solution1;
					solution2 = rivers[river_number].points[point_number + 1].current_solution;
					w0 = w0*rivers[river_number].points[point_number].f1;
				} else if (def1 == FALSE && def2 == FALSE) {
					assert (rivers[river_number].points[point_number].solution1 == rivers[river_number].points[point_number + 1].solution1);
					assert (rivers[river_number].points[point_number].solution2 == rivers[river_number].points[point_number + 1].solution2);
					solution1 = rivers[river_number].points[point_number].solution1;
					solution2 = rivers[river_number].points[point_number].solution2;
					w0 = w0*rivers[river_number].points[point_number].f1 + (1. - w0) * rivers[river_number].points[point_number + 1].f1;
				} else {
					assert(FALSE);
					
				}
				assert (solution2 != -999999);
				/* entry number, head, solution1, w, solution2 */
				if (rivers[river_number].update == TRUE) {
					output_msg(OUTPUT_HST,"%d %e %d %d %e\n", k, head, solution1, solution2, w0);
					/* Debug
					fprintf(stderr,"%d %d %e %d %d %e\n", point_number, k, head, solution1, solution2, w0);
					fprintf(stderr,"\t%e\t%e\t%e\n", rivers[river_number].points[point_number].f1, rivers[river_number].points[point_number + 1].f1, 1.-w1);
					*/
				}
				k++;
			}
		}
		output_msg(OUTPUT_HST,"END\n");
	}
/*
 *   Aquifer influence function NOT USED
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....     Aquifer influence function b.c.\n");
	output_msg(OUTPUT_HST,"C.3.6.1 .. RDAIF[T/F];(O) - NAIFC [1.6] > 0\n");
	output_msg(OUTPUT_HST,"C.3.6.2 .. DENOAR by x,y,z range {0.1-0.3};(O) - RDAIF [3.6.1]\n");
	output_msg(OUTPUT_HST,"C.3.6.3 .. TAIF by x,y,z range {0.1-0.3};(O) - RDAIF [3.6.1] and HEAT [1.4]\n");
	output_msg(OUTPUT_HST,"C.3.6.4 .. CAIF by x,y,z range {0.1-0.3};(O) - RDAIF [3.6.1] and SOLUTE [1.4]\n");

	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_calculation_transient(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes time stepping data
 *
 *      Arguments:
 *         none
 *
 */
	double max;

	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Calculation information\n");
	output_msg(OUTPUT_HST,"C.3.7.1 .. RDCALC[T/F]\n");
	output_msg(OUTPUT_HST,"     t\n");
	output_msg(OUTPUT_HST,"C.3.7.2 .. AUTOTS[T/F];(O) - RDCALC [3.7.1]\n");
	output_msg(OUTPUT_HST,"     f\n");
	/* time step */
	output_msg(OUTPUT_HST,"C.3.7.3.A .. DELTIM;(O) - RDCALC [3.7.1] and NOT AUTOTS [3.7.2]\n");
	output_msg(OUTPUT_HST,"     %g\n", current_time_step.value * current_time_step.input_to_user);

	output_msg(OUTPUT_HST,"C.3.7.3.B .. DPTAS{5E4},DCTAS{.25},DTIMMN{1.E4},DTIMMX{1.E7};\n");
	if (steady_flow == TRUE) {
		if (max_ss_head_change <=0) {
			max = (grid[2].coord[grid[2].count_coord - 1] - grid[2].coord[0]) * 0.3 * units.vertical.input_to_si * fluid_density * GRAVITY;
		} else {
			max = max_ss_head_change *  units.head.input_to_si * fluid_density * GRAVITY;
		}
		output_msg(OUTPUT_HST,"     %g %g %g %g\n", 
			max,
			1.,
			min_ss_time_step.value * min_ss_time_step.input_to_user,
			max_ss_time_step.value * max_ss_time_step.input_to_user);
	}
	output_msg(OUTPUT_HST,"C..           (O) - RDCALC [3.7.1] and AUTOTS [3.7.2]\n");

	/* time change */
	output_msg(OUTPUT_HST,"C.3.7.4 .. TIMCHG\n");
	/*	output_msg(OUTPUT_HST,"     %f\n", current_time_end.value * current_time_end.input_to_user);*/
	output_msg(OUTPUT_HST,"     %f\n", current_end_time);
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_output_transient(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes printing information
 *
 *      Arguments:
 *         none
 *
 */
	double cntmap, velmap, compmap;

	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Output information\n");
	output_msg(OUTPUT_HST,"C.3.8.1 .. PRISLM,PRIKD,PRIP,PRIC,PRICPHRQ,PRIFORCE_CHEM_PHRQ,PRIVEL,PRIGFB,PRIBCF,PRIWEL; all [I]\n");
	output_msg(OUTPUT_HST,"     %f %f %f %f %f %f %f %f %f %f\n",
		print_value(&current_print_statistics),
		print_value(&current_print_conductances),
		print_value(&current_print_head),
		print_value(&current_print_comp),
		print_value(&current_print_xyz_chem),
		print_value(&current_print_force_chem),
		print_value(&current_print_velocity),
		print_value(&current_print_flow_balance),
		print_value(&current_print_bc_flow),
		print_value(&current_print_wells));
	output_msg(OUTPUT_HST,"C.3.8.1.1 .. PRT_BC; [T/F]\n");
	if (current_print_bc == TRUE) output_msg(OUTPUT_HST,"     T\n");
	if (current_print_bc == FALSE) output_msg(OUTPUT_HST,"     F\n");
	output_msg(OUTPUT_HST,"C.3.8.2 .. PRIHDF_CONC, PRIHDF_HEAD, PRIHDF_VEL\n");
	output_msg(OUTPUT_HST,"     %f %f %f\n",
		print_value(&current_print_hdf_chem),
		print_value(&current_print_hdf_head),
		print_value(&current_print_hdf_velocity));
	output_msg(OUTPUT_HST,"C.3.8.2a .. PRI_ICHEAD; [T/F]\n");
	if (save_final_heads == TRUE) output_msg(OUTPUT_HST, "     t \n");
	if (save_final_heads == FALSE) output_msg(OUTPUT_HST, "     f \n");
/*
 *   new line to control phreeqc prints
 */
	output_msg(OUTPUT_HST,"C.3.8.3 .. CHKPTD[T/F],PRICPD,SAVLDO[T/F]\n");
	output_msg(OUTPUT_HST,"f 0 f\n");
/*
 *  contour map info
 */
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....Contour and vector map information\n");
	output_msg(OUTPUT_HST,"C.3.9.1 .. CNTMAP[T/F], PRIMAPHEAD, COMPMAP[T/F], PRIMAPCOMP,VECMAP[T/F], PRIMAPV\n");
	cntmap = print_value(&current_print_xyz_head);
	velmap = print_value(&current_print_xyz_velocity);
	compmap = print_value(&current_print_xyz_comp);

	if (cntmap != 0) {
		output_msg(OUTPUT_HST,"     t %f", cntmap);
	} else {
		output_msg(OUTPUT_HST,"     f %f", cntmap);
	}
	if (compmap != 0) {
		output_msg(OUTPUT_HST,"     t %f", compmap);
	} else {
		output_msg(OUTPUT_HST,"     f %f", compmap);
	}
	if (velmap != 0) {
		output_msg(OUTPUT_HST,"     t %f\n", velmap);
	} else {
		output_msg(OUTPUT_HST,"     f %f\n", velmap);
	}

	output_msg(OUTPUT_HST,"C.3.9.2 .. PRIXYZ_WELL\n");
	output_msg(OUTPUT_HST,"     %f\n", print_value(&current_print_xyz_wells));
/*
 *   Print information by node
 */	
	if (flow_only == FALSE) {
		/* .O.chem file */
		output_msg(OUTPUT_HST,"C...Cell print information for .O.chem file, transient chemistry\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_chem));
		output_msg(OUTPUT_HST,"END\n");
		/* .xyz.chem file */
		output_msg(OUTPUT_HST,"C...Cell print information for .xyz.chem file, transient chemistry\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_xyz));
		output_msg(OUTPUT_HST,"END\n");
#ifdef SKIP
		/* .h5 file */
		output_msg(OUTPUT_HST,"C...Cell print information for .h5 file, transient chemistry\n");
		output_msg(OUTPUT_HST,"%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			cells[0].x * units.horizontal.input_to_si, 
			cells[nxyz-1].x * units.horizontal.input_to_si,
			cells[0].y * units.horizontal.input_to_si, 
			cells[nxyz-1].y * units.horizontal.input_to_si,
			cells[0].z * units.vertical.input_to_si, 
			cells[nxyz-1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST,"     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_hdf));
		output_msg(OUTPUT_HST,"END\n");
#endif
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
double print_value(struct time *time_ptr)
/* ---------------------------------------------------------------------- */
{
	if (time_ptr->type == UNDEFINED) {
		return(-(current_time_end.value * current_time_end.input_to_user));
	}
	if (time_ptr->type == STEP) return(floor(time_ptr->value + 1e-8));
	return(-(time_ptr->value * time_ptr->input_to_user));
	
}
/* ---------------------------------------------------------------------- */
int write_double_cell_property(size_t offset, double factor)
/* ---------------------------------------------------------------------- */

{
	int first, count_values, i;
	double value, value_old;
	int print_return;

	first = TRUE;
	count_values = 0;
	value_old = 0;
	print_return = 0;
	output_msg(OUTPUT_HST,"     ");
	for (i = 0; i < nxyz; i++) {
		if (cells[i].cell_active == FALSE) {
			value = value_old;
		} else {
			value = *(double *) ((char *) &(cells[i]) + offset);
			value *= factor;
		}
		if (first == TRUE) {
			value_old = value;
			count_values = 1;
			first = FALSE;
		} else if (value == value_old) {
			count_values++;
		} else {
			if (count_values == 1) {
				output_msg(OUTPUT_HST,"%20.12e ", value_old);
				print_return++;
			} else {
				output_msg(OUTPUT_HST,"%d*%-20.12e ", count_values, value_old);
				print_return++;
			}
			value_old = value;
			count_values = 1;
		}
		if (print_return > 5 ) {
			output_msg(OUTPUT_HST,"\n     ");
			print_return = 0;
		}
	}
	if (count_values == 1) {
		output_msg(OUTPUT_HST,"%20.12e\n", value_old);
	} else {
		output_msg(OUTPUT_HST,"%d*%-20.12e\n", count_values, value_old);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_integer_cell_property(size_t offset)
/* ---------------------------------------------------------------------- */

{
	int first, count_values, i;
	int value, value_old, print_return;

	first = TRUE;
	count_values = 0;
	value_old = 0;
	print_return = 0;
	output_msg(OUTPUT_HST,"     ");
	for (i = 0; i < nxyz; i++) {
		if (cells[i].cell_active == FALSE) {
			value = -1;
		} else {
			value = *(int *) ((char *) &(cells[i]) + offset);
		}
		if (first == TRUE) {
			value_old = value;
			count_values = 1;
			first = FALSE;
		} else if (value == value_old) {
			count_values++;
		} else {
			if (count_values == 1) {
				output_msg(OUTPUT_HST,"%d ", value_old);
				print_return++;
			} else {
				output_msg(OUTPUT_HST,"%d*%d ", count_values, value_old);
				print_return++;
			}
			value_old = value;
			count_values = 1;
		}
		if (print_return > 5 ) {
			output_msg(OUTPUT_HST,"\n     ");
			print_return = 0;
		}
	}
	if (count_values == 1) {
		output_msg(OUTPUT_HST,"%d\n", value_old);
	} else {
		output_msg(OUTPUT_HST,"%d*%d\n", count_values, value_old);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_double_element_property(size_t offset, double factor)
/* ---------------------------------------------------------------------- */

{
	int first, count_values, i;
	int print_return;
	double value, value_old;

	first = TRUE;
	count_values = 0;
	value_old = 0;
	print_return = 0;
	output_msg(OUTPUT_HST,"     ");
	for (i = 0; i < nxyz; i++) {
		if (cells[i].is_element == FALSE) continue;
		if (cells[i].elt_active == FALSE) continue;
		value = *(double *) ((char *) &(cells[i]) + offset);
		value *= factor;
		if (first == TRUE) {
			value_old = value;
			count_values = 1;
			first = FALSE;
		} else if (value == value_old) {
			count_values++;
		} else {
			if (count_values == 1) {
				output_msg(OUTPUT_HST,"%20.12e ", value_old);
				print_return++;
			} else {
				output_msg(OUTPUT_HST,"%d*%-20.12e ", count_values, value_old);
				print_return++;
			}
			value_old = value;
			count_values = 1;
		}
		if (print_return > 3 ) {
			output_msg(OUTPUT_HST,"\n     ");
			print_return = 0;
		}
	}
	if (count_values == 1) {
		output_msg(OUTPUT_HST,"%20.12e\n", value_old);
	} else {
		output_msg(OUTPUT_HST,"%d*%-20.12e\n", count_values, value_old);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int write_thru(int thru)
/* ---------------------------------------------------------------------- */

{
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....End of transient information\n");
	output_msg(OUTPUT_HST,"C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n");
	output_msg(OUTPUT_HST,"C.....Read sets of READ3 data at each TIMCHG until THRU  (Lines 3.N1.N2)\n");
	output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,"C.....End of simulation line follows, THRU=.TRUE.\n");
	output_msg(OUTPUT_HST,"C.3.99.1 .. THRU\n");
	if (thru == TRUE) {
		output_msg(OUTPUT_HST,"     t\n");
		output_msg(OUTPUT_HST,"C.....End of the data file\n");
		output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
		output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	} else {
		output_msg(OUTPUT_HST,"     f\n");
		output_msg(OUTPUT_HST,"C------------------------------------------------------------------------------\n");
	}
	return(OK);
}


