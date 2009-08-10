#define EXTERNAL extern
#include "hstinpt.h"
#include "message.h"
#include "stddef.h"
#include "Zone_budget.h"
#include <set>
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
int write_zone_budget(void);
/* ---------------------------------------------------------------------- */
int
write_hst(void)
/* ---------------------------------------------------------------------- */
{
	int i;
/*
 *   calculate number of boundary conditions
 */
	count_specified = 0;
	count_flux = 0;
	count_leaky = 0;
	count_river_segments = 0;
	count_drain_segments = 0;

	for (i = 0; i < nxyz; i++)
	{
		if (!cells[i].specified)
			count_river_segments += cells[i].count_river_polygons;
		if (cells[i].cell_active == FALSE)
			continue;
		if (cells[i].specified)
			count_specified++;
		if (cells[i].flux)
			count_flux++;
		if (cells[i].leaky)
			count_leaky++;
		if (!cells[i].specified)
		{
			//count_river_segments += cells[i].count_river_polygons;
			count_drain_segments += cells[i].drain_segments->size();
		}
	}

	if (simulation == 0)
	{
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
		write_zone_budget();
		/*
		 *   Thru is false here
		 */
		output_msg(OUTPUT_HST,
				   "C------------------------------------------------------------------------------\n");
		output_msg(OUTPUT_HST,
				   "C------------------------------------------------------------------------------\n");
		output_msg(OUTPUT_HST, "C..... TRANSIENT DATA - READ3\n");
		output_msg(OUTPUT_HST, "C.3.1 .. THRU[T/F]\n");
		output_msg(OUTPUT_HST, "     f\n");
	}
	write_bc_transient();
	write_calculation_transient();
	write_output_transient();

	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_file_names(void)
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
	if (hst_file == NULL)
	{
		error_msg("Can not open temporary data file (Phast.tmp)", STOP);
	}
	output_msg(OUTPUT_HST, "%s\n", chemistry_name);
	output_msg(OUTPUT_HST, "%s\n", database_name);
	output_msg(OUTPUT_HST, "%s\n", prefix);
	output_msg(OUTPUT_HST, "%10d\n", FileMap.size());
	for (std::map < std::string, int >::const_iterator it = FileMap.begin();
		 it != FileMap.end(); it++)
	{
		output_msg(OUTPUT_HST, "%s\n", (it->first).c_str());
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_initial(void)
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

	output_msg(OUTPUT_HST, "C.....PHAST Data-Input Form\n");
	output_msg(OUTPUT_HST, "C.....UNRELEASE 1.0\n");
	output_msg(OUTPUT_HST, "C...   Notes:\n");
	output_msg(OUTPUT_HST,
			   "C...   Input lines are denoted by C.N1.N2.N3 where\n");
	output_msg(OUTPUT_HST,
			   "C...        N1 is the read group number, N2.N3 is the record number\n");
	output_msg(OUTPUT_HST,
			   "C...        A letter indicates an exclusive record choice must be made.\n");
	output_msg(OUTPUT_HST, "C...          i.e. A or B or C\n");
	output_msg(OUTPUT_HST,
			   "C...   (O) - Optional data with conditions for requirement\n");
	output_msg(OUTPUT_HST,
			   "C...   P [n.n.n] - The record where parameter P is set\n");
	output_msg(OUTPUT_HST, "C.....Input by x,y,z range format is;\n");
	output_msg(OUTPUT_HST, "C.0.1.. X1,X2,Y1,Y2,Z1,Z2\n");
	output_msg(OUTPUT_HST, "C.0.2.. VAR1,IMOD1,[VAR2,IMOD2,VAR3,IMOD3]\n");
	output_msg(OUTPUT_HST,
			   "C...     Use as many of line 0.1 & 0.2 sets as necessary\n");
	output_msg(OUTPUT_HST, "C...     End with line 0.3\n");
	output_msg(OUTPUT_HST, "C.0.3.. END OR end\n");
	output_msg(OUTPUT_HST,
			   "C...   {nnn} - Indicates that the default number, nnn, is used if a zero\n");
	output_msg(OUTPUT_HST, "C...           is entered for that variable\n");
	output_msg(OUTPUT_HST, "C...   [T/F] - Indicates a logical variable\n");
	output_msg(OUTPUT_HST, "C...   [I] - Indicates an integer variable\n");
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Start of the data file\n");
	output_msg(OUTPUT_HST,
			   "C.....Specification and dimensioning data - READ1\n");
/*
 *   write title
 */
	output_msg(OUTPUT_HST, "C.1.1 .. TITLE LINE 1\n");
	ptr = title_x;
	title_line = line_from_string(&ptr);
	output_msg(OUTPUT_HST, ".%s\n", title_line);
	free_check_null(title_line);
	output_msg(OUTPUT_HST, "C.1.2 .. TITLE LINE 2\n");
	title_line = line_from_string(&ptr);
	output_msg(OUTPUT_HST, ".%s\n", title_line);
	free_check_null(title_line);

	output_msg(OUTPUT_HST, "C.1.3 .. RESTRT[T/F],TIMRST\n");
/*	output_msg(OUTPUT_HST,"     f 0.\n");*/
	output_msg(OUTPUT_HST, "     f %g\n",
			   time_start.value * time_start.input_to_user);
	output_msg(OUTPUT_HST, "C.....If RESTART, skip to READ3 group\n");
	output_msg(OUTPUT_HST,
			   "C.1.4 .. HEAT[T/F],SOLUTE[T/F],EEUNIT[T/F],CYLIND[T/F],SCALMF[T/F]\n");
	if (flow_only == TRUE)
	{
		output_msg(OUTPUT_HST, "     f f f f f\n");
	}
	else
	{
		output_msg(OUTPUT_HST, "     f t f f f\n");
	}
	output_msg(OUTPUT_HST,
			   "C.1.4.1 .. STEADY_FLOW[T/F], EPS_HEAD (head), EPS_FLOW (fraction)\n");
	if (steady_flow == TRUE)
	{
		output_msg(OUTPUT_HST, "     t  %g %g \n",
				   fluid_density * GRAVITY * eps_head *
				   units.head.input_to_si, eps_mass_balance);
	}
	else
	{
		output_msg(OUTPUT_HST, "     f  0  0 \n");
	}
	output_msg(OUTPUT_HST,
			   "C.1.4.2 .. coordinate axes included (x y z) [I]\n");
	output_msg(OUTPUT_HST, "     %d %d %d\n", axes[0], axes[1], axes[2]);
/*
 *   time unit
 */
	str_tolower(units.time.input);
	output_msg(OUTPUT_HST, "C.1.5 .. TMUNIT[I]\n");
	if (units.time.input[0] == 's')
	{
		output_msg(OUTPUT_HST, "1\n");
	}
	else if (units.time.input[0] == 'm')
	{
		output_msg(OUTPUT_HST, "2\n");
	}
	else if (units.time.input[0] == 'h')
	{
		output_msg(OUTPUT_HST, "3\n");
	}
	else if (units.time.input[0] == 'd')
	{
		output_msg(OUTPUT_HST, "4\n");
	}
	else if (units.time.input[0] == 'y')
	{
		output_msg(OUTPUT_HST, "6\n");
	}
	else
	{
		error_msg("Can not interpret time units", STOP);
	}
/*
 *   Number of nodes
 */
	output_msg(OUTPUT_HST, "C.1.6 .. NX,NY,NZ,NHCN, Number of elements\n");
	output_msg(OUTPUT_HST, "     %d %d %d 0 %d\n", grid[0].count_coord,
			   grid[1].count_coord, grid[2].count_coord,
			   (nx - 1) * (ny - 1) * (nz - 1));
	output_msg(OUTPUT_HST,
			   "C.1.7 .. NSBC,NFBC,NLBC,NRBC,NDBC, NAIFC,NHCBC,NWEL\n");
	//output_msg(OUTPUT_HST,"     %d %d %d %d 0 0 %d\n", count_specified, count_flux, count_leaky, count_river_segments, count_wells);
	output_msg(OUTPUT_HST, "     %d %d %d %d %d 0 0 %d\n", count_specified,
			   count_flux, count_leaky, count_river_segments,
			   count_drain_segments, count_wells_in_region);
/*
 *   solution method
 */
	output_msg(OUTPUT_HST, "C.1.8 .. SLMETH[I], NPA4\n");
	if (solver_method == DIRECT)
	{
		output_msg(OUTPUT_HST, "     1 %d\n", solver_memory);
	}
	else if (solver_method == ITERATIVE)
	{
		output_msg(OUTPUT_HST, "     5 %d\n", solver_memory);
	}
	else
	{
		error_msg("Solver method not defined", STOP);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
char *
line_from_string(char **ptr)
/* ---------------------------------------------------------------------- */
{
	int i;
	size_t l;
	char *return_string;


	if (*ptr == NULL)
	{
		l = 2;
	}
	else
	{
		l = strlen(*ptr) + 2;
	}
	return_string = (char *) malloc((size_t) l * sizeof(char));
	if (return_string == NULL)
		malloc_error();
	if (*ptr == NULL)
	{
		strcpy(return_string, "");
	}
	else
	{
		i = 0;
		while ((*ptr)[i] != '\0' && (*ptr)[i] != '\n')
		{
			i++;
		}
		strncpy(return_string, *ptr, (size_t) (i));
		return_string[i] = '\0';
		if ((*ptr)[i] == '\n')
		{
			*ptr = &((*ptr)[i + 1]);
		}
		else
		{
			*ptr = NULL;
		}
	}
	return (return_string);
}

/* ---------------------------------------------------------------------- */
int
write_grid(void)
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
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Static data - READ2\n");
	output_msg(OUTPUT_HST, "C.....Coordinate geometry information\n");
	output_msg(OUTPUT_HST, "C.....   Rectangular coordinates\n");
	output_msg(OUTPUT_HST,
			   "C.2.2A.1 .. UNIGRX,UNIGRY,UNIGRZ; all [T/F];(O) - NOT CYLIND [1.4]\n");
	for (j = 0; j < 3; j++)
	{
		if (grid[j].uniform == UNDEFINED)
		{
			output_msg(OUTPUT_HST, "     t");
		}
		else if (grid[j].uniform == TRUE)
		{
			output_msg(OUTPUT_HST, "     t ");
		}
		else if (grid[j].uniform == FALSE)
		{
			output_msg(OUTPUT_HST, "     f ");
		}
		else
		{
			error_msg("Unknown value for grid.uniform.", STOP);
		}
	}
	output_msg(OUTPUT_HST, "\n");
/*
 *   X, Y, Z grid data
 */
	j = 0;
	for (j = 0; j < 3; j++)
	{
		if (j == 0 || j == 1)
		{
			conversion = units.horizontal.input_to_si;
		}
		else
		{
			conversion = units.vertical.input_to_si;
		}
		output_msg(OUTPUT_HST, "C2.2A.2A .. %c(1), %c(N%c)\n", grid[j].c,
				   grid[j].c, grid[j].c);
		if (grid[j].uniform == UNDEFINED)
		{
			output_msg(OUTPUT_HST, "%12g %12g \n", 0.0, 1.0);
		}
		if (grid[j].uniform == TRUE)
		{
			output_msg(OUTPUT_HST, "%12g  %12g \n",
					   grid[j].coord[0] * conversion,
					   grid[j].coord[grid[j].count_coord - 1] * conversion);
		}
		output_msg(OUTPUT_HST, "C2.2A.2B .. %c(I)\n", grid[j].c);
		if (grid[j].uniform == FALSE)
		{
			if (grid[j].count_coord < 2)
			{
				sprintf(error_string,
						"Expected two coordinate values and the number of nodes for %c grid information.",
						grid[j].c);
				error_msg(error_string, CONTINUE);
				input_error++;
				continue;
			}
			vector_print(grid[j].coord, conversion, grid[j].count_coord,
						 hst_file);
		}
	}
/*
 *   Cylindrical coordinates NOT USED
 */
	output_msg(OUTPUT_HST, "C.....   Cylindrical coordinates\n");
	output_msg(OUTPUT_HST,
			   "C.2.2B.1A .. R(1),R(NR),ARGRID[T/F];(O) - CYLIND [1.4]\n");
	output_msg(OUTPUT_HST,
			   "C.2.2B.1B .. R(I);(O) - CYLIND [1.4] and NOT ARGRID [2.2B.1A]\n");
	output_msg(OUTPUT_HST, "C.2.2B.2 .. UNIGRZ[T/F];(O) - CYLIND [1.4]\n");
	output_msg(OUTPUT_HST,
			   "C.2.2B.3A .. Z(1),Z(NZ);(O) - UNIGRZ [2.2B.3A],CYLIND [1.4]\n");
	output_msg(OUTPUT_HST,
			   "C.2.2B.3B .. Z(K);(O) - NOT UNIGRZ [2.2B.3A],CYLIND [1.4]\n");
	output_msg(OUTPUT_HST, "C.2.3.1 .. TILT[T/F];(O) - NOT CYLIND [1.4]\n");
	output_msg(OUTPUT_HST, "f\n");
	output_msg(OUTPUT_HST,
			   "C.2.3.2 .. THETXZ,THETYZ,THETZZ;(O) - TILT [2.3.1] and NOT CYLIND [1.4]\n");
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_fluid(void)
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


	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Fluid property information\n");
	output_msg(OUTPUT_HST, "C.2.4.1 .. BP\n");
	if (free_surface == TRUE)
	{
		output_msg(OUTPUT_HST, "     %g\n", 0.0);
		/* warning_msg("Fluid compressibility has been set to zero for free surface calculation."); */
	}
	else
	{
		output_msg(OUTPUT_HST, "     %g\n", fluid_compressibility);
	}
	output_msg(OUTPUT_HST, "C.2.4.2 .. P0,T0,W0,DENF0\n");
	output_msg(OUTPUT_HST, "     0. 15. 0. %g\n", fluid_density);
	output_msg(OUTPUT_HST, "C.2.4.3 .. W1,DENF1;(O) - SOLUTE [1.4]\n");
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST, "     .05 %g\n", fluid_density);
	}
	output_msg(OUTPUT_HST, "C.2.5.1 .. VISFAC\n");
	output_msg(OUTPUT_HST, "     %g\n", -fluid_viscosity);
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Reference condition information\n");
	output_msg(OUTPUT_HST, "C.2.6.1 .. PAATM\n");
	output_msg(OUTPUT_HST, "     0.\n");
	output_msg(OUTPUT_HST, "C.2.6.2 .. P0H,T0H\n");
	output_msg(OUTPUT_HST, "     0. 15.\n");
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Fluid thermal property information\n");
	output_msg(OUTPUT_HST, "C.2.7 .. CPF,KTHF,BT;(O) - HEAT [1.4]\n");
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Solute information\n");
	output_msg(OUTPUT_HST, "C.2.8 .. DM; (O) - SOLUTE [1.4]\n");
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST, "     %g\n",
				   fluid_diffusivity * units.time.input_to_si);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_media(void)
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
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Porous media zone information\n");
	output_msg(OUTPUT_HST,
			   "C.2.9.1 .. IPMZ,X1Z(IPMZ),X2Z(IPMZ),Y1Z(IPMZ),Y2Z(IPMZ),Z1Z(IPMZ),Z2Z(IPMZ)\n");
	for (i = 0; i < nxyz; i++)
	{
		if (cells[i].is_element == FALSE)
			continue;
		if (cells[i].elt_active == FALSE)
			continue;
		n = ijk_to_n(cells[i].ix + 1, cells[i].iy + 1, cells[i].iz + 1);
		output_msg(OUTPUT_HST,
				   "%7d %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   element_number, cells[i].x * units.horizontal.input_to_si,
				   cells[n].x * units.horizontal.input_to_si,
				   cells[i].y * units.horizontal.input_to_si,
				   cells[n].y * units.horizontal.input_to_si,
				   cells[i].z * units.vertical.input_to_si,
				   cells[n].z * units.vertical.input_to_si);
		element_number++;
	}
	//output_msg(OUTPUT_HST,"C.....Use as many 2.9.1 lines as necessary\n");
	//output_msg(OUTPUT_HST,"C.2.9.2 .. End with END\n");
	output_msg(OUTPUT_HST, "C .. End 2.9.1\n");
	output_msg(OUTPUT_HST, "END\n");
/*
 *   Hydraulic conductivity
 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Porous media property information\n");
	for (i = 0; i < nxyz; i++)
	{
		if (cells[i].is_element == FALSE)
			continue;
		if (cells[i].elt_active == FALSE)
			continue;
		cells[i].x_perm =
			cells[i].kx * fluid_viscosity / (fluid_density * GRAVITY);
		cells[i].y_perm =
			cells[i].ky * fluid_viscosity / (fluid_density * GRAVITY);
		cells[i].z_perm =
			cells[i].kz * fluid_viscosity / (fluid_density * GRAVITY);
	}
/*
 *   kx, ky, kz
 */
	output_msg(OUTPUT_HST, "C.2.10.1.1 .. X permeability\n");
	write_double_element_property(offsetof(struct cell, x_perm),
								  units.k.input_to_si);
	output_msg(OUTPUT_HST, "C.2.10.1.2 .. Y permeability\n");
	write_double_element_property(offsetof(struct cell, y_perm),
								  units.k.input_to_si);
	output_msg(OUTPUT_HST, "C.2.10.1.3 .. Z permeability\n");
	write_double_element_property(offsetof(struct cell, z_perm),
								  units.k.input_to_si);
/*
 *   Porosity
 */
	output_msg(OUTPUT_HST, "C.2.10.2 .. POROS(IPMZ),IPMZ=1 to NPMZ [1.7]\n");
	write_double_element_property(offsetof(struct cell, porosity), 1.0);
/*
 *   specific storage to compressibility
 */
	storage_warning = FALSE;
	for (i = 0; i < nxyz; i++)
	{
		if (cells[i].is_element == FALSE)
			continue;
		if (cells[i].elt_active == FALSE)
			continue;
		if (free_surface == FALSE)
		{
			cells[i].compress =
				cells[i].storage * units.s.input_to_si / (fluid_density *
														  GRAVITY) -
				cells[i].porosity * fluid_compressibility;
		}
		else
		{
			cells[i].compress = 0.0;
		}
		if (cells[i].compress < 0.0)
		{
			storage_warning = TRUE;
		}
	}
	/*
	   if (free_surface == TRUE) {
	   warning_msg("Aquifer compressibility has been set to zero for free surface calculation.");   
	   }
	 */
	if (free_surface == FALSE && storage_warning == TRUE)
	{
		input_error++;
		sprintf(error_string,
				"Specific storage (S) results in a negative aquifer compressibility (a),"
				"a = S/(density*G) - porosity * B\n"
				"\tTo have specific storage this small you must reduce the fluid compressibility (B) in FLUID_PROPERTIES, -compressibility.");
		error_msg(error_string, CONTINUE);
	}
	output_msg(OUTPUT_HST, "C.2.10.3 .. ABPM(IPMZ),IPMZ=1 to NPMZ [1.7]\n");
	write_double_element_property(offsetof(struct cell, compress), 1.0);
/*
 *   skip thermal property
 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,
			   "C.....Porous media thermal property information\n");
	output_msg(OUTPUT_HST,
			   "C.2.11.1 .. RCPPM(IPMZ),IPMZ=1 to NPMZ [1.7];(O) - HEAT [1.4]\n");
	output_msg(OUTPUT_HST,
			   "C.2.11.2 .. KTXPM(IPMZ),KTYPM(IPMZ),KTZPM(IPMZ),IPMZ=1 to NPMZ [1.7];(O) -\n");
	output_msg(OUTPUT_HST, "C..          HEAT [1.4]\n");
/*
 *  dispersivity
 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,
			   "C.....Porous media solute and thermal dispersion information\n");
/*
 *   longitudinal dispersivity
 */
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST,
				   "C.2.12.1 .. longitudinal dispersivity: alphl\n");
		write_double_element_property(offsetof(struct cell, alpha_long),
									  units.alpha.input_to_si);
	}
/*
 *   transverse dispersivity
 */
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST,
				   "C.2.12.2 .. horizontal transverse dispersivity: alphth\n");
		write_double_element_property(offsetof(struct cell, alpha_horizontal),
									  units.alpha.input_to_si);
		output_msg(OUTPUT_HST,
				   "C.2.12.3 .. vertical transverse dispersivity: alphtv\n");
		write_double_element_property(offsetof(struct cell, alpha_vertical),
									  units.alpha.input_to_si);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_source_sink(void)
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
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,
			   "C.....Porous media solute property information\n");
	output_msg(OUTPUT_HST,
			   "C.2.13 .. DBKD(IPMZ),IPMZ=1 to NPMZ [1.7];(O) - SOLUTE [1.4]\n");
	output_msg(OUTPUT_HST, "C...REMOVED...\n");
/*
 *    Source-sink well information
 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Source-sink well information\n");
	output_msg(OUTPUT_HST,
			   "C.2.14.1 .. well id number,x,y, diameter, wqmeth\n");
	output_msg(OUTPUT_HST,
			   "C.2.14.2 .. cell number, fraction of cell that is screened\n");
	output_msg(OUTPUT_HST,
			   "C.2.14.3 .. WSF(L);L = 1 to NZ (EXCLUSIVE) by ELEMENT\n");
	output_msg(OUTPUT_HST,
			   "C.2.14.4 .. WRISL,WRID,WRRUF,WRANGL;(O) - NWEL [1.6] >0 and\n");
	output_msg(OUTPUT_HST, "C..          WRCALC(WQMETH [2.14.3] >30)\n");
	output_msg(OUTPUT_HST,
			   "C.2.14.5 .. HTCWR,DTHAWR,KTHAWR,KTHWR,TABWR,TATWR;(O) - NWEL [1.6] >0\n");
	output_msg(OUTPUT_HST,
			   "C..          WRCALC(WQMETH [2.14.3] >30) and HEAT [1.4]\n");
	output_msg(OUTPUT_HST,
			   "C.....Use as many sets of 2.14.1-5 lines as necessary for each well\n");
	output_msg(OUTPUT_HST, "C.2.14.6 .. End with END\n");
	output_msg(OUTPUT_HST,
			   "C.2.14.7 .. MXITQW{14},TOLDPW{6.E-3},TOLFPW{.001},TOLQW{.001},DAMWRC{2.},\n");
	output_msg(OUTPUT_HST,
			   "C..          DZMIN{.01},EPSWR{.001};(O) - NWEL [1.6] >0\n");
	output_msg(OUTPUT_HST, "C..          and WRCALC(WQMETH[2.14.3] >30)\n");
	if (well_defined == TRUE)
	{
		for (i = 0; i < count_wells; i++)
		{
			if (!wells[i].in_region) continue;
			output_msg(OUTPUT_HST,
					   "C.2.14.8 .. well number, x, y, zb, zt, db, dt, diameter, wqmeth\n");
			if (wells[i].diameter_defined == TRUE)
			{
				diameter = wells[i].diameter;
			}
			else
			{
				diameter = wells[i].radius * 2;
			}
			if (wells[i].mobility_and_pressure == TRUE)
			{
				code = 10;
			}
			else
			{
				code = 11;
			}
			/*
			output_msg(OUTPUT_HST,
					   "%d %16.7e %16.7e %16.7e %16.7e  %16.7e %16.7e %e %d\n",
					   wells[i].n_user,
					   wells[i].x * units.horizontal.input_to_si,
					   wells[i].y * units.horizontal.input_to_si,
					   wells[i].screen_bottom * units.vertical.input_to_si,
					   wells[i].screen_top * units.vertical.input_to_si,
					   wells[i].screen_depth_bottom *
					   units.vertical.input_to_si,
					   wells[i].screen_depth_top * units.vertical.input_to_si,
					   diameter * units.well_diameter.input_to_si, code);
			*/
			output_msg(OUTPUT_HST,
					   "%d %16.7e %16.7e %16.7e %16.7e  %16.7e %16.7e %e %d\n",
					   wells[i].n_user,
					   wells[i].x_grid * units.horizontal.input_to_si,
					   wells[i].y_grid * units.horizontal.input_to_si,
					   //0.0, 0.0, 0.0, 0.0,
					  
					   wells[i].screen_bottom * units.vertical.input_to_si,
					   wells[i].screen_top * units.vertical.input_to_si,
					   0.0, 0.0,
					   /* No longer used
					   wells[i].screen_depth_bottom * units.vertical.input_to_si,
					   wells[i].screen_depth_top * units.vertical.input_to_si,
					   */
					   diameter * units.well_diameter.input_to_si, code);
			output_msg(OUTPUT_HST,
					   "C.2.14.9 .. cell number, screened interval below node (m), screened interval above node (m)\n");
			for (j = 0; j < wells[i].count_cell_fraction; j++)
			{
				/* output_msg(OUTPUT_HST,"\t%d %e\n", wells[i].cell_fraction[j].cell + 1, wells[i].cell_fraction[j].f); */
				output_msg(OUTPUT_HST, "    %d %e %e\n",
						   wells[i].cell_fraction[j].cell + 1,
						   wells[i].cell_fraction[j].lower * units.vertical.input_to_si,
						   wells[i].cell_fraction[j].upper * units.vertical.input_to_si);
			}
			output_msg(OUTPUT_HST, "C ..  end 2.14.9\n");
			output_msg(OUTPUT_HST, "END\n");
		}
		output_msg(OUTPUT_HST, "C .. end 2.14.8\n");
		output_msg(OUTPUT_HST, "END\n");
	}

	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_bc_static(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *      Writes bc zones
	 *
	 *      Arguments:
	 *         none
	 *
	 */

	int i, j;
	double elevation;
	double river_k, thickness;
	double area, w0, w1, leakance, z, z0, z1;
	int river_number, point_number;
	/*
	 *  Write zones
	 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Boundary condition information\n");
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	/*
	 *   Specified value
	 */
	output_msg(OUTPUT_HST, "C.....     Specified value b.c.\n");
	output_msg(OUTPUT_HST, "C.2.15 .. segment, cell number, ibc code\n");

	if (count_specified > 0)
	{
		int segment = 1;
		for (i = 0; i < nxyz; i++)
		{
			if (cells[i].cell_active == FALSE)
				continue;
#ifdef OLD
			if (cells[i].bc_type == BC_info::BC_SPECIFIED)
			{
				output_msg(OUTPUT_HST,
						   "     %15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
						   cells[i].x * units.horizontal.input_to_si,
						   cells[i].x * units.horizontal.input_to_si,
						   cells[i].y * units.horizontal.input_to_si,
						   cells[i].y * units.horizontal.input_to_si,
						   cells[i].z * units.vertical.input_to_si,
						   cells[i].z * units.vertical.input_to_si);
				if (flow_only == TRUE)
				{
					j = 0;
				}
				else
				{
					/* 1 specified pressure */
					/* 2 temperature = 0 */
					/* 3 solution  0 = associated, 1 = specified */
					std::list < BC_info >::reverse_iterator rit =
						cells[i].all_bc_info->rbegin();
					if (rit->bc_solution_type == ASSOCIATED)
					{
						j = 0;
					}
					else
					{
						j = 1;
					}
				}
				output_msg(OUTPUT_HST, "10%d\n", j);
			}
#endif
			if (cells[i].bc_type == BC_info::BC_SPECIFIED)
			{
				if (flow_only == TRUE)
				{
					j = 0;
				}
				else
				{
					/* 1 specified pressure */
					/* 2 temperature = 0 */
					/* 3 solution  0 = associated, 1 = specified */
					std::list < BC_info >::reverse_iterator rit =
						cells[i].all_bc_info->rbegin();
					if (rit->bc_solution_type == ASSOCIATED)
					{
						j = 0;
					}
					else
					{
						j = 1;
					}
				}
				output_msg(OUTPUT_HST, "%d %d 10%d\n", segment, i + 1, j);
				segment++;
			}
		}
		output_msg(OUTPUT_HST, "C .. End 2.15\n");
		output_msg(OUTPUT_HST, "END\n");
	}
	/*
	 *   Flux
	 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....     Specified flux b.c.\n");
	output_msg(OUTPUT_HST,
			   "C.2.16 .. modified: segment number, cell_number, face_index, area\n");
	if (count_flux > 0)
	{
		int segment = 1;

		for (i = 0; i < nxyz; i++)
		{
			if (cells[i].cell_active == FALSE)
				continue;
			if (!cells[i].flux)
				continue;
			cells[i].flux_starting_segment_fortran = segment;
			// Reverse iterator on list of BC_info
			for (std::list < BC_info >::reverse_iterator rit =
				 cells[i].all_bc_info->rbegin();
				 rit != cells[i].all_bc_info->rend(); rit++)
			{
				if (rit->bc_type != BC_info::BC_FLUX)
					continue;

				// area
				area = rit->area;
				if (rit->face == CF_Z)
				{
					area *=
						units.horizontal.input_to_si *
						units.horizontal.input_to_si;
				}
				else
				{
					area *=
						units.horizontal.input_to_si *
						units.vertical.input_to_si;
				}

				// segment number, cell number, face, area
				output_msg(OUTPUT_HST, "   %d %d %d %20.10e\n", segment,
						   i + 1, ((int) rit->face + 1), area);
				segment++;
			}
		}
		output_msg(OUTPUT_HST, "C .. End 2.16\n");
		output_msg(OUTPUT_HST, "END\n");
	}
	/*
	 *   LEAKY
	 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....    Aquifer leakage b.c.\n");
	output_msg(OUTPUT_HST,
			   "C.2.17 .. segment number, cell_number, face_index, area, permeability, thickness, elevation\n");

	/* zone, index codes */
	if (count_leaky > 0)
	{
		int segment = 1;
		for (i = 0; i < nxyz; i++)
		{
			if (cells[i].cell_active == FALSE)
				continue;
			if (!cells[i].leaky)
				continue;
			cells[i].leaky_starting_segment_fortran = segment;
			// Reverse terator on list of BC_info
			for (std::list < BC_info >::reverse_iterator rit =
				 cells[i].all_bc_info->rbegin();
				 rit != cells[i].all_bc_info->rend(); rit++)
			{
				if (rit->bc_type != BC_info::BC_LEAKY)
					continue;
				// area
				area = rit->area;
				if (rit->face == CF_Z)
				{
					area *=
						units.horizontal.input_to_si *
						units.horizontal.input_to_si;
				}
				else
				{
					area *=
						units.horizontal.input_to_si *
						units.vertical.input_to_si;
				}
				// permeability
				double permeability =
					rit->bc_k * units.leaky_k.input_to_si * fluid_viscosity /
					(fluid_density * GRAVITY);

				// segment number, cell number, face, area, permeability, thickness, elevation

				// thickness
				thickness = rit->bc_thick * units.leaky_thick.input_to_si;
				// elevation
				elevation = cells[i].z * units.vertical.input_to_si;
				if (rit->face == CF_Z)
				{
					if (cells[i].exterior->zn)
						elevation -= thickness;
					if (cells[i].exterior->zp)
						elevation += thickness;
				}

				// write segment info
				output_msg(OUTPUT_HST,
						   "   %d %d %d %20.10e %20.10e %20.10e %20.10e\n",
						   segment, i + 1, ((int) rit->face + 1), area,
						   permeability, thickness, elevation);
				segment++;
			}
		}
		output_msg(OUTPUT_HST, "C .. End 2.17\n");
		output_msg(OUTPUT_HST, "END\n");
	}

	/*
	 *   River leakage bc,
	 */
	output_msg(OUTPUT_HST, "C.....          River leakage b.c.\n");
	output_msg(OUTPUT_HST,
			   "C.2.17.1 .. segment number cell number, area, leakance, z\n");

	if (count_river_segments > 0)
	{
		int segment = 1;
		for (i = 0; i < count_cells; i++)
		{
			//if (cells[i].cell_active == FALSE) continue;
			if (cells[i].specified)
				continue;
			if (cells[i].count_river_polygons > 0)
			{
				cells[i].river_starting_segment_fortran = segment;
			}
			for (j = 0; j < cells[i].count_river_polygons; j++)
			{
				area =
					cells[i].river_polygons[j].area *
					units.horizontal.input_to_si *
					units.horizontal.input_to_si;
					/*units.river_width.input_to_si;*/ /* Area now calculated in grid units */
				river_number = cells[i].river_polygons[j].river_number;
				point_number = cells[i].river_polygons[j].point_number;
				w0 = cells[i].river_polygons[j].w;
				w1 = 1. - w0;
				river_k =
					(rivers[river_number].points[point_number].k * w0 +
					 rivers[river_number].points[point_number +
												 1].k * w1) *
					units.river_bed_k.input_to_si;
				thickness =
					(rivers[river_number].points[point_number].thickness *
					 w0 + rivers[river_number].points[point_number +
													  1].thickness * w1) *
					units.river_bed_thickness.input_to_si;

				leakance =
					river_k / thickness * fluid_viscosity / (fluid_density *
															 GRAVITY);

				/*  calculate bottom elevations, convert to SI */
#ifdef SKIP
				if (rivers[river_number].points[point_number].z_user_defined ==
					FALSE)
				{
					z0 = rivers[river_number].points[point_number].
						current_head * units.head.input_to_si -
						rivers[river_number].points[point_number].depth *
						units.vertical.input_to_si;
				}
				else
				{
					z0 = rivers[river_number].points[point_number].z *
						units.vertical.input_to_si;
				}
#endif
				z0 = rivers[river_number].points[point_number].z_grid *
						units.vertical.input_to_si;
#ifdef SKIP
				if (rivers[river_number].points[point_number + 1].z_defined ==
					FALSE)
				{
					z1 = rivers[river_number].points[point_number +
													 1].current_head *
						units.head.input_to_si -
						rivers[river_number].points[point_number +
													1].depth *
						units.vertical.input_to_si;
				}
				else
				{
					z1 = rivers[river_number].points[point_number +
													 1].z *
						units.vertical.input_to_si;
				}
#endif
				z1 = rivers[river_number].points[point_number + 1].z_grid *
						units.vertical.input_to_si;
				z = (z0 * w0 + z1 * w1);

				/* segment number, cell no., area, leakance, z */
				output_msg(OUTPUT_HST, "%d %d %e %e %e\n", segment, i + 1,
						   area, leakance, z);
				segment++;
			}
		}
		output_msg(OUTPUT_HST, "C .. End 2.17.1\n");
		output_msg(OUTPUT_HST, "END\n");
	}
	/*
	 *   drain bc,
	 */
	output_msg(OUTPUT_HST, "C.....          Drain leakage b.c.\n");
	output_msg(OUTPUT_HST,
			   "C.2.18.1 .. segment number, cell number, area, leakance, elevation\n");

	if (count_drain_segments > 0)
	{
		int segment = 1;
		for (i = 0; i < count_cells; i++)
		{
			if (cells[i].cell_active == FALSE)
				continue;
			if (cells[i].specified)
				continue;
			if (cells[i].drain_segments->size() == 0)
				continue;
			cells[i].drain_starting_segment_fortran = segment;
			std::vector < River_Polygon >::iterator j_it =
				cells[i].drain_segments->begin();
			for (; j_it != cells[i].drain_segments->end(); j_it++)
			{
				area =
					j_it->area * units.horizontal.input_to_si *
					units.horizontal.input_to_si;
					/*units.drain_width.input_to_si;*/ /* area now calculated in grid units */
				int drain_number = j_it->river_number;
				point_number = j_it->point_number;
				w0 = j_it->w;
				w1 = 1. - w0;
				double drain_k =
					(drains[drain_number]->points[point_number].k * w0 +
					 drains[drain_number]->points[point_number +
												  1].k * w1) *
					units.drain_bed_k.input_to_si;
				thickness =
					(drains[drain_number]->points[point_number].thickness *
					 w0 + drains[drain_number]->points[point_number +
													   1].thickness * w1) *
					units.drain_bed_thickness.input_to_si;

				leakance =
					drain_k / thickness * fluid_viscosity / (fluid_density *
															 GRAVITY);

				/*  get elevations, convert to SI */
				z0 = drains[drain_number]->points[point_number].z_grid *
					units.vertical.input_to_si;
				z1 = drains[drain_number]->points[point_number + 1].z_grid *
					units.vertical.input_to_si;
				z = (z0 * w0 + z1 * w1);

				/* segment number, cell no., area, leakance, z */
				output_msg(OUTPUT_HST, "%d %d %e %e %e\n", segment, i + 1,
						   area, leakance, z);
				segment++;
			}
		}
		output_msg(OUTPUT_HST, "C .. End 2.18.1\n");
		output_msg(OUTPUT_HST, "END\n");
	}
	/*
	 *   Aquifer influence functions NOT USED
	 */
#ifdef SKIP
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....     Aquifer influence functions\n");
	output_msg(OUTPUT_HST,
			   "C.2.18.1 .. IBC by x,y,z range {0.1-0.3} with no IMOD parameter;(O) -\n");
	output_msg(OUTPUT_HST, "C..          NAIFC [1.6] > 0\n");
	output_msg(OUTPUT_HST,
			   "C.2.18.2 .. UVAIFC by x,y,z range {0.1-0.3};(O) - NAIFC [1.6] > 0\n");
	output_msg(OUTPUT_HST, "C.2.18.3 .. IAIF;(O) - NAIFC [1.6] > 0\n");
	output_msg(OUTPUT_HST, "C.....          Pot  a.i.f.\n");
	output_msg(OUTPUT_HST,
			   "C.2.18.4A .. ABOAR,POROAR,VOAR;(O) - IAIF [2.18.3] = 1\n");
	output_msg(OUTPUT_HST,
			   "C.....          Transient, Carter-Tracy a.i.f.\n");
	output_msg(OUTPUT_HST,
			   "C.2.18.4B .. KOAR,ABOAR,VISOAR,POROAR,BOAR,RIOAR,ANGOAR;(O) -\n");
	output_msg(OUTPUT_HST, "C..          IAIF [2.18.3] = 2\n");
#endif
	output_msg(OUTPUT_HST,
			   "C.....       Aquifer influence functions not available\n");
	/*
	 *   Heat bc NOT USED
	 */
#ifdef SKIP
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....     Heat conduction b.c.\n");
	output_msg(OUTPUT_HST,
			   "C.2.19.1 .. ZHCBC(K);(O) - HEAT [1.4] and NHCBC [1.6] > 0\n");
	output_msg(OUTPUT_HST,
			   "C.2.19.2 .. IBC by x,y,z range {0.1-0.3} with no IMOD parameter;(O) - \n");
	output_msg(OUTPUT_HST, "c..          HEAT [1.4] and NHCBC [1.6] > 0\n");
	output_msg(OUTPUT_HST,
			   "C.2.19.3 .. UDTHHC by x,y,z range {0.1-0.3} FOR HCBC NODES;(O) -\n");
	output_msg(OUTPUT_HST, "C..          HEAT [1.4] and NHCBC [1.6] > 0\n");
	output_msg(OUTPUT_HST,
			   "C.2.19.4 .. UKHCBC by x,y,z range {0.1-0.3} FOR HCBC NODES;(O) -\n");
	output_msg(OUTPUT_HST, "C..          HEAT [1.4] and NHCBC [1.6] > 0\n");
#endif
	output_msg(OUTPUT_HST, "C.....       Heat conduction not available\n");
	/*
	 *   Free surface
	 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Free surface b.c.\n");
	output_msg(OUTPUT_HST, "C.2.20 .. FRESUR[T/F] ADJ_WR_RATIO[T/N]\n");
	if (free_surface == TRUE)
	{
		if (steady_flow == FALSE && adjust_water_rock_ratio == TRUE)
		{
			output_msg(OUTPUT_HST, "    t    t\n");
		}
		else
		{
			output_msg(OUTPUT_HST, "    t    f\n");
		}
	}
	else
	{
		output_msg(OUTPUT_HST, "    f     f\n");
	}

	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_ic(void)
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
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Initial condition information\n");
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.2.21.1 .. ICHYDP; [T/F]\n");
	output_msg(OUTPUT_HST, "     f\n");
	output_msg(OUTPUT_HST, "C.2.21.2 .. ICHWT[T/F];(O) - FRESUR [2.20]\n");
	if (free_surface == TRUE)
	{
		output_msg(OUTPUT_HST, "f\n");
	}
	output_msg(OUTPUT_HST,
			   "C.2.21.3A .. ZPINIT,PINIT;(O) - ICHYDP [2.21.1] and NOT ICHWT [2.21.2]\n");
	output_msg(OUTPUT_HST,
			   "C.2.21.3B .. P by x,y,z range {0.1-0.3};(O) - NOT ICHYDP [2.21.1] and\n");
	output_msg(OUTPUT_HST, "C..          NOT ICHWT [2.21.2]\n");
/*
 *   Initial head distribution by node
 */

	output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
			   cells[0].x * units.horizontal.input_to_si,
			   cells[nxyz - 1].x * units.horizontal.input_to_si,
			   cells[0].y * units.horizontal.input_to_si,
			   cells[nxyz - 1].y * units.horizontal.input_to_si,
			   cells[0].z * units.vertical.input_to_si,
			   cells[nxyz - 1].z * units.vertical.input_to_si);
	output_msg(OUTPUT_HST, "     0. 4\n");

	/* convert to pressure */
	for (i = 0; i < nxyz; i++)
	{
		if (cells[i].cell_active == FALSE)
			continue;
		cells[i].ic_pressure = fluid_density * GRAVITY *
			(cells[i].ic_head * units.head.input_to_si -
			 cells[i].z * units.vertical.input_to_si);
	}
	write_double_cell_property(offsetof(struct cell, ic_pressure), 1.0);
	output_msg(OUTPUT_HST, "C .. End 2.21.3\n");
	output_msg(OUTPUT_HST, "END\n");
/* 
 *   NOT USED
 */
	output_msg(OUTPUT_HST,
			   "C.2.21.3C .. HWT by x,y,z range {0.1-0.3};(O) - FRESUR [2.20] and\n");
	output_msg(OUTPUT_HST, "C..          ICHWT [2.21.2]\n");
	output_msg(OUTPUT_HST,
			   "C.2.21.4B .. T by x,y,z range {0.1-0.3};(O) - HEAT [1.4] and NOT ICTPRO\n");
	output_msg(OUTPUT_HST, "C..           [2.21.1]\n");
	output_msg(OUTPUT_HST,
			   "C.2.21.5 .. NZTPHC, ZTHC(I),TVZHC(I);(O) - HEAT [1.4] and NHCBC [1.6] >0,\n");
	output_msg(OUTPUT_HST, "C..          limit of 5\n");
	output_msg(OUTPUT_HST,
			   "C.2.21.6B .. C by x,y,z range {0.1-0.3};(O) - SOLUTE [1.4] and NOT ICCPRO\n");
	output_msg(OUTPUT_HST, "C..           [2.21.1]\n");

/*
 *   Initial solution by node
 */
	output_msg(OUTPUT_HST, "C.2.21.7 .. Initial solution \n");
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_solution.i1));
		write_integer_cell_property(offsetof(struct cell, ic_solution.i2));
		write_double_cell_property(offsetof(struct cell, ic_solution.f1),
								   1.0);
		output_msg(OUTPUT_HST, "C .. End 2.21.7\n");
		output_msg(OUTPUT_HST, "END\n");
	}
/*
 *   Initial equilibrium_phases by node
 */
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST, "C.2.21.8 .. Initial equilibrium_phases \n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof
									(struct cell, ic_equilibrium_phases.i1));
		write_integer_cell_property(offsetof
									(struct cell, ic_equilibrium_phases.i2));
		write_double_cell_property(offsetof
								   (struct cell, ic_equilibrium_phases.f1),
								   1.0);
		output_msg(OUTPUT_HST, "C .. End 2.21.8\n");
		output_msg(OUTPUT_HST, "END\n");
	}
/*
 *   Initial exchange by node
 */
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST, "C.2.21.9 .. Initial exchange\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_exchange.i1));
		write_integer_cell_property(offsetof(struct cell, ic_exchange.i2));
		write_double_cell_property(offsetof(struct cell, ic_exchange.f1),
								   1.0);
		output_msg(OUTPUT_HST, "C .. End 2.21.9\n");
		output_msg(OUTPUT_HST, "END\n");
	}
/*
 *   Initial surface by node
 */
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST, "C.2.21.10 .. Initial surface\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_surface.i1));
		write_integer_cell_property(offsetof(struct cell, ic_surface.i2));
		write_double_cell_property(offsetof(struct cell, ic_surface.f1), 1.0);
		output_msg(OUTPUT_HST, "C .. End 2.21.10\n");
		output_msg(OUTPUT_HST, "END\n");
	}
/*
 *   Initial gas_phase by node
 */
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST, "C.2.21.11 .. Initial gas_phase\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_gas_phase.i1));
		write_integer_cell_property(offsetof(struct cell, ic_gas_phase.i2));
		write_double_cell_property(offsetof(struct cell, ic_gas_phase.f1),
								   1.0);
		output_msg(OUTPUT_HST, "C .. End 2.21.11\n");
		output_msg(OUTPUT_HST, "END\n");
	}
/*
 *   Initial solid_solutions by node
 */
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST, "C.2.21.12 .. Initial solid_solutions\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof
									(struct cell, ic_solid_solutions.i1));
		write_integer_cell_property(offsetof
									(struct cell, ic_solid_solutions.i2));
		write_double_cell_property(offsetof
								   (struct cell, ic_solid_solutions.f1), 1.0);
		output_msg(OUTPUT_HST, "C .. End 2.21.12\n");
		output_msg(OUTPUT_HST, "END\n");
	}
/*
 *   Initial kinetics by node
 */
	if (flow_only == FALSE)
	{
		output_msg(OUTPUT_HST, "C.2.21.13 .. Initial kinetics\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4 0 4 0 4\n");
		write_integer_cell_property(offsetof(struct cell, ic_kinetics.i1));
		write_integer_cell_property(offsetof(struct cell, ic_kinetics.i2));
		write_double_cell_property(offsetof(struct cell, ic_kinetics.f1),
								   1.0);
		output_msg(OUTPUT_HST, "C .. End 2.21.13\n");
		output_msg(OUTPUT_HST, "END\n");
	}
/*
 *   Done with initial conditions
 */
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_calculation_static(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes calculation information
 *
 *      Arguments:
 *         none
 *
 */

	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Calculation information\n");
	output_msg(OUTPUT_HST, "C.2.22.1 .. FDSMTH,FDTMTH\n");
	output_msg(OUTPUT_HST, "     %g  %g\n", solver_space, solver_time);
	output_msg(OUTPUT_HST, "C.2.22.2 .. CROSD [T/F]\n");
	if (flow_only != TRUE)
	{
		if (cross_dispersion == TRUE)
		{
			output_msg(OUTPUT_HST, "     T\n");
		}
		else
		{
			output_msg(OUTPUT_HST, "     F\n");
		}
		output_msg(OUTPUT_HST,
				   "C.2.22.3 .. rebalance fraction for parallel processing, rebalance_by_cell 0/1\n");
		output_msg(OUTPUT_HST, "     %g %d\n", rebalance_fraction,
				   rebalance_by_cell);
	}
	output_msg(OUTPUT_HST, "C.2.22.4 .. TOLDEN{.001},MAXITN{5}\n");
	output_msg(OUTPUT_HST, "     .001  %d\n", max_ss_iterations);

#ifdef SKIP
	output_msg(OUTPUT_HST, "C.2.22.3 .. EPSFS;(O) - FRESUR [2.20]\n");
	if (free_surface == TRUE)
	{
		output_msg(OUTPUT_HST, "     1.e-4\n");
	}
#endif

	output_msg(OUTPUT_HST,
			   "C.....     restarted conjugate gradient solver\n");
	output_msg(OUTPUT_HST,
			   "C.2.22.5 .. IDIR,MILU,NSDR,EPSSLV{1.e-8},MAXIT2{500}; (O) - SLMETH [1.8] = 3\n");
	if (solver_method == ITERATIVE)
	{
		output_msg(OUTPUT_HST, "     1 t %d %g %d\n", solver_save_directions,
				   solver_tolerance, solver_maximum);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_output_static(void)
/* ---------------------------------------------------------------------- */
{
/*
 *      Writes static output information
 *
 *      Arguments:
 *         none
 *
 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Output information\n");
	output_msg(OUTPUT_HST,
			   "C.2.23.1 .. PRTPMP,PRTFP,PRTBC,PRTSLM,PRTWEL,PRT_KD; all [T/F]\n");
	output_msg(OUTPUT_HST, "     ");
	if (print_input_media == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_media == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_fluid == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_fluid == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_bc == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_bc == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_method == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_method == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_wells == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_wells == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_conductances == TRUE)
		output_msg(OUTPUT_HST, "t \n");
	if (print_input_conductances == FALSE)
		output_msg(OUTPUT_HST, "f \n");

	output_msg(OUTPUT_HST,
			   "C.2.23.2 .. PRTIC_C, PRTIC_MAPC, PRTIC_P, PRTIC_MAPHEAD, PRTIC_SS_VEL, PRTIC_XYZ_SS_VEL, PRTIC_CONC, PRTIC_FORCE_CHEM; all [T/F]\n");
	output_msg(OUTPUT_HST, "     ");
	if (print_input_comp == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_comp == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_xyz_comp == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_xyz_comp == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_head == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_head == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_xyz_head == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_xyz_head == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_ss_vel == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_ss_vel == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_xyz_ss_vel == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_xyz_ss_vel == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_xyz_chem == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_xyz_chem == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_force_chem == TRUE)
		output_msg(OUTPUT_HST, "t \n");
	if (print_input_force_chem == FALSE)
		output_msg(OUTPUT_HST, "f \n");

	output_msg(OUTPUT_HST,
			   "C.2.23.2.1 .. PRTIC_HDF_CONC, PRTIC_HDF_HEAD, PRTIC_HDF_SS_VEL, PRTIC_HDF_MEDIA; all [T/F]\n");
	output_msg(OUTPUT_HST, "     ");
	if (print_input_hdf_chem == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_hdf_chem == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_hdf_head == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_hdf_head == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_hdf_ss_vel == TRUE)
		output_msg(OUTPUT_HST, "t ");
	if (print_input_hdf_ss_vel == FALSE)
		output_msg(OUTPUT_HST, "f ");
	if (print_input_hdf_media == TRUE)
		output_msg(OUTPUT_HST, "t \n");
	if (print_input_hdf_media == FALSE)
		output_msg(OUTPUT_HST, "f \n");

	output_msg(OUTPUT_HST, "C.2.23.2.2 .. HDF_media: units, Conversions user_to_si k, ss\n");
	if (print_input_hdf_media == TRUE)
	{
		output_msg(OUTPUT_HST, "C.2.23.2.2.1 .. K: units, input_to_si, fluid_density, fluid_viscosity\n");
		output_msg(OUTPUT_HST, "\"%s\" %15.7e %15.7e %15.7e\n", units.k.input, units.k.input_to_si, fluid_density, fluid_viscosity);
		output_msg(OUTPUT_HST, "C.2.23.2.2.2 .. Storage: units, input_to_si, fluid_compressibility\n");
		output_msg(OUTPUT_HST, "\"%s\" %15.7e %15.7e\n", units.s.input, units.s.input_to_si, fluid_compressibility);
	}
	output_msg(OUTPUT_HST, "C.2.23.2.3 .. HDF_media: Conversions user_to_si alpha\n");
	if (print_input_hdf_media == TRUE && flow_only != TRUE)
	{
		output_msg(OUTPUT_HST, "C.2.23.2.3.1 .. Alpha: units, input_to_si\n");
		output_msg(OUTPUT_HST, "\"%s\" %15.7e\n", units.alpha.input, units.alpha.input_to_si);
	}

	output_msg(OUTPUT_HST, "C.2.23.3 .. ORENPR[I];(O) - NOT CYLIND [1.4]\n");
	if (print_input_xy == TRUE)
	{
		output_msg(OUTPUT_HST, "     12\n");
	}
	else
	{
		output_msg(OUTPUT_HST, "     13\n");
	}
	output_msg(OUTPUT_HST, "C.2.23.4 .. PLTZON[T/F];(O) - PRTPMP [2.23.1]\n");
	if (print_input_media == TRUE)
	{
		output_msg(OUTPUT_HST, "     f\n");
	}
	output_msg(OUTPUT_HST, "C.2.23.5 .. PRTIC_XYZ_WELL[T/F]\n");
	if (print_input_xyz_wells == TRUE)
		output_msg(OUTPUT_HST, "t \n");
	if (print_input_xyz_wells == FALSE)
		output_msg(OUTPUT_HST, "f \n");
/*
 *   Print information by node
 */
	if (flow_only == FALSE)
	{
		/* O.chem file */
		output_msg(OUTPUT_HST,
				   "C.2.23.6 .. Cell print information for O.chem, initial conditions; (O) - solute\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_chem));
		output_msg(OUTPUT_HST, "C .. End 2.23.6\n");
		output_msg(OUTPUT_HST, "END\n");
		/* xyz.chem file */
		output_msg(OUTPUT_HST,
				   "C.2.23.7 .. Cell print information for xyz.chem, initial conditions; (O) - solute\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_xyz));
		output_msg(OUTPUT_HST, "C .. End 2.23.7\n");
		output_msg(OUTPUT_HST, "END\n");
#ifdef SKIP
		/* h5 file */
		output_msg(OUTPUT_HST,
				   "C...Cell print information for h5, initial conditions\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_hdf));
		output_msg(OUTPUT_HST, "END\n");
#endif
	}
#ifdef SKIP

#endif
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_bc_transient(void)
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
	 *  Write Wells
	 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....The following is for NOT THRU\n");
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Source-sink well information\n");
	output_msg(OUTPUT_HST, "C.3.2.1 .. RDWTD[T/F];(O) - NWEL [1.6] > 0\n");
	if (count_wells_in_region > 0)
	{
		if (well_defined == TRUE)
		{
			output_msg(OUTPUT_HST, "\tT\n");
		}
		else
		{
			output_msg(OUTPUT_HST, "\tF\n");
		}
	}
	output_msg(OUTPUT_HST,
			   "C.3.2.2 .. IWEL,QWV,PWSUR,PWKT,TWSRKT,CWKT;(O) - RDWTD [3.2.1] \n");
	output_msg(OUTPUT_HST, "C.....Use as many 3.2.2 lines as necessay\n");
	output_msg(OUTPUT_HST, "C.3.2.3 .. End with END\n");
	if (count_wells_in_region > 0 && well_defined == TRUE)
	{
		output_msg(OUTPUT_HST,
				   "C.3.2.4 .. well sequence number, q, solution number\n");
		int j = 0;
		for (i = 0; i < count_wells; i++)
		{
			if (!wells[i].in_region) continue;
			j++;
			//if (wells[i].update == TRUE) {
			//write all well information
			if (wells[i].solution_defined == TRUE)
			{
				solution = wells[i].current_solution;
			}
			else
			{
				solution = -1;
			}
			output_msg(OUTPUT_HST, "%d %e %d\n",
					   j,
					   wells[i].current_q * units.well_pumpage.input_to_user,
					   solution);
			//}             
		}
		output_msg(OUTPUT_HST, "C .. End 3.2.4\n");
		output_msg(OUTPUT_HST, "END\n");
	}

	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Boundary condition information\n");
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	/*
	 *   Specified value
	 */
	output_msg(OUTPUT_HST, "C.....     Specified value b.c.\n");
	output_msg(OUTPUT_HST,
			   "C.3.3.1 .. RDSPBC,RDSTBC,RDSCBC; all [T/F];(O) - NSBC [1.6] > 0\n");
	if (count_specified > 0 && bc_specified_defined == TRUE)
	{
		output_msg(OUTPUT_HST, "     t f f\n");
	}
	else if (count_specified > 0 && bc_specified_defined == FALSE)
	{
		output_msg(OUTPUT_HST, "     f f f\n");
	}
	if (count_specified > 0 && bc_specified_defined == TRUE)
	{
		output_msg(OUTPUT_HST,
				   "C.3.3.2 .. segment, psbc, solution 1, solution 2, mix factor\n");

		int segment = 1;
		for (i = 0; i < nxyz; i++)
		{
			if (cells[i].cell_active == FALSE)
				continue;
			if (cells[i].specified)
			{
				std::list < BC_info >::reverse_iterator rit =
					cells[i].all_bc_info->rbegin();
				double pressure =
					fluid_density * GRAVITY * (rit->bc_head *
											   units.head.input_to_si -
											   cells[i].z *
											   units.vertical.input_to_si);
				output_msg(OUTPUT_HST, "%d %20.10e %d %d %e\n", segment,
						   pressure, rit->bc_solution.i1, rit->bc_solution.i2,
						   rit->bc_solution.f1);
				segment++;
			}
		}
		output_msg(OUTPUT_HST, "C .. End 3.3.2\n");
		output_msg(OUTPUT_HST, "END\n");
	}
	else
	{
		output_msg(OUTPUT_HST,
				   "C.3.3.2 .. PNP B.C. by x,y,z range {0.1-0.3};(O) - RDSPBC [3.3.1]\n");
		output_msg(OUTPUT_HST,
				   "C.3.3.3 .. TSBC by x,y,z range {0.1-0.3};(O) - RDSPBC [3.3.1] and\n");
		output_msg(OUTPUT_HST, "C..          HEAT [1.4]\n");
		output_msg(OUTPUT_HST,
				   "C.3.3.4 .. CSBC by x,y,z range {0.1-0.3}; (O) - RDSPBC [3.3.1] and\n");
		output_msg(OUTPUT_HST, "C..          SOLUTE [1.4]\n");
	}


	/* NOT USED, Both specified and associated solutions are defined with 3.3.1 */
	//output_msg(OUTPUT_HST,"C.3.3.5 .. TNP B.C. by x,y,z range {0.1-0.3};(O) - RDSTBC [3.3.1] and\n");
	//output_msg(OUTPUT_HST,"C..          HEAT [1.4]\n");
	output_msg(OUTPUT_HST,
			   "C.3.3.3 .. CNP B.C. by x,y,z range {0.1-0.3};(O) - RDSCBC [3.3.1] and\n");
	output_msg(OUTPUT_HST, "C..          SOLUTE [1.4]\n");
	/* rdscbc always false */
	/*
	 *   Flux
	 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....     Specified flux b.c.\n");
	output_msg(OUTPUT_HST,
			   "C.3.4.1 .. RDFLXQ,RDFLXH,RDFLXS; all [T/F];(O) - NFBC [1.6] > 0\n");
	if (count_flux > 0 && bc_flux_defined == TRUE)
	{
		output_msg(OUTPUT_HST, "     t f f\n");
	}
	else if (count_flux > 0 && bc_flux_defined == FALSE)
	{
		output_msg(OUTPUT_HST, "     f f f\n");
	}
	if (count_flux > 0 && bc_flux_defined == TRUE)
	{
		output_msg(OUTPUT_HST,
				   "C.3.4.2 .. Segment number, flux (relative to cell), solution 1, solution 2, mix factor, cell number\n");
		int segment = 1;
		for (i = 0; i < nxyz; i++)
		{
			if (cells[i].cell_active == FALSE)
				continue;
			if (!cells[i].flux)
				continue;
			// Reverse iterator on list of BC_info
			for (std::list < BC_info >::reverse_iterator rit =
				 cells[i].all_bc_info->rbegin();
				 rit != cells[i].all_bc_info->rend(); rit++)
			{
				if (rit->bc_type != BC_info::BC_FLUX)
					continue;
				double sign = 1.0;
				switch (rit->face)
				{
				case CF_X:
					if (cells[i].exterior->xp)
					{
						sign = -1;
					}
					break;
				case CF_Y:
					if (cells[i].exterior->yp)
					{
						sign = -1;
					}
					break;
				case CF_Z:
					if (cells[i].exterior->zp)
					{
						sign = -1;
					}
					break;
				default:
					error_msg("Wrong face for flux definition.", STOP);
				}
				// segment number, flux, solution 1, solution 2, factor
				// Note: convention is positive flux is into the cell
				output_msg(OUTPUT_HST, "   %d %20.10e %d %d %e %d\n", segment,
						   sign * rit->bc_flux * units.flux.input_to_user,
						   rit->bc_solution.i1, rit->bc_solution.i2,
						   rit->bc_solution.f1, i + 1);
				segment++;
			}
		}
		output_msg(OUTPUT_HST, "C .. End 3.4.2\n");
		output_msg(OUTPUT_HST, "END\n");

		/* NOT USED */
		//output_msg(OUTPUT_HST,"C.3.4.4 .. TFLX B.C. by x,y,z range {0.1-0.3};(O) - RDFLXQ [3.4.1] and\n");
		//output_msg(OUTPUT_HST,"C..          HEAT [1.4]\n");
	}

	/* NOT USED */
	//output_msg(OUTPUT_HST,"C.3.4.6 .. QHFX,QHFY,QHFZ B.C. by x,y,z range {0.1-0.3};(O) - RDFLXH [3.4.5]\n");
	//output_msg(OUTPUT_HST,"C.3.4.7 .. QSFX,QSFY,QSFZ B.C. by x,y,z range {0.1-0.3};(O) - RDFLXS [3.4.1]\n");
	/*
	 *   Leaky
	 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....     Leakage b.c.\n");
	output_msg(OUTPUT_HST, "C.3.5.1 .. RDLBC[T/F];(O) - NLBC [1.6] > 0\n");
	if (count_leaky > 0)
	{
		if (bc_leaky_defined == TRUE)
		{
			output_msg(OUTPUT_HST, "     t\n");
		}
		else if (bc_leaky_defined == FALSE)
		{
			output_msg(OUTPUT_HST, "     f\n");
		}
	}
	if (count_leaky > 0 && bc_leaky_defined == TRUE)
	{
		output_msg(OUTPUT_HST,
				   "C.3.5.2 .. Segment number, head, solution 1, solution 2, mix factor, cell number\n");
		int segment = 1;
		for (i = 0; i < nxyz; i++)
		{
			if (cells[i].cell_active == FALSE)
				continue;
			if (!cells[i].leaky)
				continue;
			// Reverse iterator on list of BC_info
			for (std::list < BC_info >::reverse_iterator rit =
				 cells[i].all_bc_info->rbegin();
				 rit != cells[i].all_bc_info->rend(); rit++)
			{
				if (rit->bc_type != BC_info::BC_LEAKY)
					continue;

				// energy per unit mass
				double head = rit->bc_head * units.head.input_to_si;

				// segment number, head, solution 1, solution 2, factor
				output_msg(OUTPUT_HST, "   %d %20.10e %d %d %e %d\n", segment,
						   head, rit->bc_solution.i1, rit->bc_solution.i2,
						   rit->bc_solution.f1, i + 1);
				segment++;
			}
		}
		output_msg(OUTPUT_HST, "C .. End 3.5.2\n");
		output_msg(OUTPUT_HST, "END\n");

		/* NOT USED */
		//output_msg(OUTPUT_HST,"C.3.4.4 .. TFLX B.C. by x,y,z range {0.1-0.3};(O) - RDFLXQ [3.4.1] and\n");
		//output_msg(OUTPUT_HST,"C..          HEAT [1.4]\n");
	}
	/*
	 * River leakage
	 */
	output_msg(OUTPUT_HST, "C.....River Leakage\n");
	output_msg(OUTPUT_HST, "C.3.6.1 .. RDRBC t/f\n");
	if (count_river_segments > 0)
	{
		if (river_defined == TRUE)
		{
			output_msg(OUTPUT_HST, "     t\n");
		}
		else if (river_defined == FALSE)
		{
			output_msg(OUTPUT_HST, "     f\n");
		}
	}
	output_msg(OUTPUT_HST,
			   "C.3.6.2 .. river segment number, head, solution 1, solution 2, weight solution 1\n");
	if (count_river_segments > 0 && river_defined == TRUE)
	{
		k = 1;
		for (i = 0; i < count_cells; i++)
		{
			//if (cells[i].cell_active == FALSE) continue;
			if (cells[i].bc_type == BC_info::BC_SPECIFIED)
				continue;

			for (j = 0; j < cells[i].count_river_polygons; j++)
			{
				river_number = cells[i].river_polygons[j].river_number;
				point_number = cells[i].river_polygons[j].point_number;
				w0 = cells[i].river_polygons[j].w;
				w1 = 1. - w0;
				head =
					(rivers[river_number].points[point_number].current_head *
					 w0 + rivers[river_number].points[point_number +
													  1].current_head * w1) *
					units.head.input_to_si;
				/*
				   solution1 = rivers[river_number].points[point_number].solution;
				   solution2 = rivers[river_number].points[point_number + 1].solution;
				 */
				def1 =
					rivers[river_number].points[point_number].
					solution_defined;
				def2 =
					rivers[river_number].points[point_number +
												1].solution_defined;
				if (def1 == TRUE && def2 == TRUE)
				{
					solution1 =
						rivers[river_number].points[point_number].
						current_solution;
					solution2 =
						rivers[river_number].points[point_number +
													1].current_solution;
					w0 = w0;
				}
				else if (def1 == TRUE && def2 == FALSE)
				{
					assert(rivers[river_number].points[point_number].
						   solution1 ==
						   rivers[river_number].points[point_number +
													   1].solution1);
					solution1 =
						rivers[river_number].points[point_number].
						current_solution;
					solution2 =
						rivers[river_number].points[point_number +
													1].solution2;
					w0 = w0 * (1.) + (1. -
									  w0) *
						rivers[river_number].points[point_number + 1].f1;
				}
				else if (def1 == FALSE && def2 == TRUE)
				{
					assert(rivers[river_number].points[point_number].
						   solution2 ==
						   rivers[river_number].points[point_number +
													   1].solution1);
					solution1 =
						rivers[river_number].points[point_number].solution1;
					solution2 =
						rivers[river_number].points[point_number +
													1].current_solution;
					w0 = w0 * rivers[river_number].points[point_number].f1;
				}
				else if (def1 == FALSE && def2 == FALSE)
				{
					assert(rivers[river_number].points[point_number].
						   solution1 ==
						   rivers[river_number].points[point_number +
													   1].solution1);
					assert(rivers[river_number].points[point_number].
						   solution2 ==
						   rivers[river_number].points[point_number +
													   1].solution2);
					solution1 =
						rivers[river_number].points[point_number].solution1;
					solution2 =
						rivers[river_number].points[point_number].solution2;
					w0 = w0 * rivers[river_number].points[point_number].f1 +
						(1. - w0) * rivers[river_number].points[point_number +
																1].f1;
				}
				else
				{
					assert(FALSE);

				}
				assert(solution2 != -999999);
				/* entry number, head, solution1, w, solution2 */
				//if (rivers[river_number].update == TRUE) {
				// Write all rivers if anything changes
				assert(0.0 <= w0 && w0 <= 1.0);
				output_msg(OUTPUT_HST, "%d %e %d %d %e\n", k, head, solution1,
						   solution2, w0);
				/* Debug
				   fprintf(stderr,"%d %d %e %d %d %e\n", point_number, k, head, solution1, solution2, w0);
				   fprintf(stderr,"\t%e\t%e\t%e\n", rivers[river_number].points[point_number].f1, rivers[river_number].points[point_number + 1].f1, 1.-w1);
				 */
				//}
				k++;
			}
		}
		output_msg(OUTPUT_HST, "C .. End 3.6.2\n");
		output_msg(OUTPUT_HST, "END\n");
	}
	/*
	 *   Drains
	 */
	output_msg(OUTPUT_HST, "C.....    Drain leakage b.c.\n");
	output_msg(OUTPUT_HST, "C.....    No transient parameters\n");
	/*
	 *   Aquifer influence function NOT USED
	 */
#ifdef SKIP
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....     Aquifer influence function b.c.\n");
	output_msg(OUTPUT_HST, "C.3.6.1 .. RDAIF[T/F];(O) - NAIFC [1.6] > 0\n");
	output_msg(OUTPUT_HST,
			   "C.3.6.2 .. DENOAR by x,y,z range {0.1-0.3};(O) - RDAIF [3.6.1]\n");
	output_msg(OUTPUT_HST,
			   "C.3.6.3 .. TAIF by x,y,z range {0.1-0.3};(O) - RDAIF [3.6.1] and HEAT [1.4]\n");
	output_msg(OUTPUT_HST,
			   "C.3.6.4 .. CAIF by x,y,z range {0.1-0.3};(O) - RDAIF [3.6.1] and SOLUTE [1.4]\n");
#endif
	output_msg(OUTPUT_HST,
			   "C.....    Aquifer influence function b.c. not available\n");
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_calculation_transient(void)
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

	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Calculation information\n");
	output_msg(OUTPUT_HST, "C.3.7.1 .. RDCALC[T/F]\n");
	output_msg(OUTPUT_HST, "     t\n");
	output_msg(OUTPUT_HST, "C.3.7.2 .. AUTOTS[T/F];(O) - RDCALC [3.7.1]\n");
	output_msg(OUTPUT_HST, "     f\n");
	/* time step */
	output_msg(OUTPUT_HST,
			   "C.3.7.3.A .. DELTIM;(O) - RDCALC [3.7.1] and NOT AUTOTS [3.7.2]\n");
	output_msg(OUTPUT_HST, "     %g\n",
			   current_time_step.value * current_time_step.input_to_user);

	output_msg(OUTPUT_HST,
			   "C.3.7.3.B .. DPTAS{5E4},DCTAS{.25},DTIMMN{1.E4},DTIMMX{1.E7}, Growth_factor;\n");
	if (steady_flow == TRUE)
	{
		if (max_ss_head_change <= 0)
		{
			max =
				(grid[2].coord[grid[2].count_coord - 1] -
				 grid[2].coord[0]) * 0.3 * units.vertical.input_to_si *
				fluid_density * GRAVITY;
		}
		else
		{
			max =
				max_ss_head_change * units.head.input_to_si * fluid_density *
				GRAVITY;
		}
		output_msg(OUTPUT_HST, "     %g %g %g %g %g\n",
				   max,
				   1.,
				   min_ss_time_step.value * min_ss_time_step.input_to_user,
				   max_ss_time_step.value * max_ss_time_step.input_to_user,
				   growth_factor_ss);
	}
	output_msg(OUTPUT_HST,
			   "C..           (O) - RDCALC [3.7.1] and AUTOTS [3.7.2]\n");

	/* time change */
	output_msg(OUTPUT_HST, "C.3.7.4 .. TIMCHG\n");
	/*  output_msg(OUTPUT_HST,"     %f\n", current_time_end.value * current_time_end.input_to_user); */
	output_msg(OUTPUT_HST, "     %g\n", current_end_time);
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_output_transient(void)
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

	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Output information\n");
	output_msg(OUTPUT_HST,
			   "C.3.8.1 .. PRISLM,PRIKD,PRIP,PRIC,PRICPHRQ,PRIFORCE_CHEM_PHRQ,PRIVEL,PRIGFB,PRIBCF,PRIWEL; all [I]\n");
	output_msg(OUTPUT_HST, "     %f %f %f %f %f %f %f %f %f %f\n",
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
	output_msg(OUTPUT_HST, "C.3.8.1.1 .. PRT_BC; [T/F]\n");
	if (current_print_bc == TRUE)
		output_msg(OUTPUT_HST, "     T\n");
	if (current_print_bc == FALSE)
		output_msg(OUTPUT_HST, "     F\n");
	output_msg(OUTPUT_HST,
			   "C.3.8.2 .. PRIHDF_CONC, PRIHDF_HEAD, PRIHDF_VEL\n");
	output_msg(OUTPUT_HST, "     %f %f %f\n",
			   print_value(&current_print_hdf_chem),
			   print_value(&current_print_hdf_head),
			   print_value(&current_print_hdf_velocity));
	output_msg(OUTPUT_HST, "C.3.8.2.1 .. PRI_ICHEAD; [T/F]\n");
	if (save_final_heads == TRUE)
		output_msg(OUTPUT_HST, "     t \n");
	if (save_final_heads == FALSE)
		output_msg(OUTPUT_HST, "     f \n");
	output_msg(OUTPUT_HST, "C.3.8.2.2 .. pri_zf, pri_zf_tsv, pri_zf_heads\n");
	if (Zone_budget::zone_budget_map.size() > 0)
	{
		output_msg(OUTPUT_HST, "     %f %f %f\n",
				   print_value(&current_print_zone_budget),
				   print_value(&current_print_zone_budget_tsv),
				   print_value(&current_print_zone_budget_heads));
	}
/*
 *   new line to control phreeqc prints
 */
	output_msg(OUTPUT_HST, "C.3.8.3 .. CHKPTD[T/F],PRICPD,SAVLDO[T/F]\n");
	output_msg(OUTPUT_HST, "f 0 f\n");
/*
 *  contour map info
 */
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....Contour and vector map information\n");
	output_msg(OUTPUT_HST,
			   "C.3.9.1 .. CNTMAP[T/F], PRIMAPHEAD, COMPMAP[T/F], PRINT_XYZ_COMP, VECMAP[T/F], PRIMAPV\n");
	cntmap = print_value(&current_print_xyz_head);
	velmap = print_value(&current_print_xyz_velocity);
	compmap = print_value(&current_print_xyz_comp);

	if (cntmap != 0)
	{
		output_msg(OUTPUT_HST, "     t %f", cntmap);
	}
	else
	{
		output_msg(OUTPUT_HST, "     f %f", cntmap);
	}
	if (compmap != 0)
	{
		output_msg(OUTPUT_HST, "     t %f", compmap);
	}
	else
	{
		output_msg(OUTPUT_HST, "     f %f", compmap);
	}
	if (velmap != 0)
	{
		output_msg(OUTPUT_HST, "     t %f\n", velmap);
	}
	else
	{
		output_msg(OUTPUT_HST, "     f %f\n", velmap);
	}

	output_msg(OUTPUT_HST,
			   "C.3.9.2 .. PRIXYZ_WELL, PRINT_RESTART, PRINT_END_OF_PERIOD [t/t]\n");
	output_msg(OUTPUT_HST, "     %f %f",
			   print_value(&current_print_xyz_wells),
			   print_value(&current_print_restart));
	if (current_print_end_of_period == TRUE)
		output_msg(OUTPUT_HST, "     T\n");
	if (current_print_end_of_period == FALSE)
		output_msg(OUTPUT_HST, "     F\n");
/*
 *   Print information by node
 */
	if (flow_only == FALSE)
	{
		/* .O.chem file */
		output_msg(OUTPUT_HST,
				   "C.3.9.3 .. Cell print information for .O.chem file, transient chemistry\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_chem));
		output_msg(OUTPUT_HST, "C .. End 3.9.3\n");
		output_msg(OUTPUT_HST, "END\n");
		/* .xyz.chem file */
		output_msg(OUTPUT_HST,
				   "C.3.9.4 .. Cell print information for .xyz.chem file, transient chemistry\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_xyz));
		output_msg(OUTPUT_HST, "C .. End 3.9.4\n");
		output_msg(OUTPUT_HST, "END\n");
#ifdef SKIP
		/* .h5 file */
		output_msg(OUTPUT_HST,
				   "C...Cell print information for .h5 file, transient chemistry\n");
		output_msg(OUTPUT_HST, "%15.7e %15.7e %15.7e %15.7e %15.7e %15.7e\n",
				   cells[0].x * units.horizontal.input_to_si,
				   cells[nxyz - 1].x * units.horizontal.input_to_si,
				   cells[0].y * units.horizontal.input_to_si,
				   cells[nxyz - 1].y * units.horizontal.input_to_si,
				   cells[0].z * units.vertical.input_to_si,
				   cells[nxyz - 1].z * units.vertical.input_to_si);
		output_msg(OUTPUT_HST, "     0 4\n");
		write_integer_cell_property(offsetof(struct cell, print_hdf));
		output_msg(OUTPUT_HST, "END\n");
#endif
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
double
print_value(struct time *time_ptr)
/* ---------------------------------------------------------------------- */
{
	if (time_ptr->type == UNDEFINED)
	{
		return (-(current_time_end.value * current_time_end.input_to_user));
	}
	if (time_ptr->type == STEP)
		return (floor(time_ptr->value + 1e-8));
	return (-(time_ptr->value * time_ptr->input_to_user));

}

/* ---------------------------------------------------------------------- */
int
write_double_cell_property(size_t offset, double factor)
/* ---------------------------------------------------------------------- */
{
	int first, count_values, i;
	double value, value_old;
	int print_return;

	first = TRUE;
	count_values = 0;
	value_old = 0;
	print_return = 0;
	output_msg(OUTPUT_HST, "     ");
	for (i = 0; i < nxyz; i++)
	{
		if (cells[i].cell_active == FALSE)
		{
			value = value_old;
		}
		else
		{
			value = *(double *) ((char *) &(cells[i]) + offset);
			value *= factor;
		}
		if (first == TRUE)
		{
			value_old = value;
			count_values = 1;
			first = FALSE;
		}
		else if (value == value_old)
		{
			count_values++;
		}
		else
		{
			if (count_values == 1)
			{
				output_msg(OUTPUT_HST, "%20.12e ", value_old);
				print_return++;
			}
			else
			{
				output_msg(OUTPUT_HST, "%d*%-20.12e ", count_values,
						   value_old);
				print_return++;
			}
			value_old = value;
			count_values = 1;
		}
		if (print_return > 5)
		{
			output_msg(OUTPUT_HST, "\n     ");
			print_return = 0;
		}
	}
	if (count_values == 1)
	{
		output_msg(OUTPUT_HST, "%20.12e\n", value_old);
	}
	else
	{
		output_msg(OUTPUT_HST, "%d*%-20.12e\n", count_values, value_old);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_integer_cell_property(size_t offset)
/* ---------------------------------------------------------------------- */
{
	int first, count_values, i;
	int value, value_old, print_return;

	first = TRUE;
	count_values = 0;
	value_old = 0;
	print_return = 0;
	output_msg(OUTPUT_HST, "     ");
	for (i = 0; i < nxyz; i++)
	{
		if (cells[i].cell_active == FALSE)
		{
			value = -1;
		}
		else
		{
			value = *(int *) ((char *) &(cells[i]) + offset);
		}
		if (first == TRUE)
		{
			value_old = value;
			count_values = 1;
			first = FALSE;
		}
		else if (value == value_old)
		{
			count_values++;
		}
		else
		{
			if (count_values == 1)
			{
				output_msg(OUTPUT_HST, "%d ", value_old);
				print_return++;
			}
			else
			{
				output_msg(OUTPUT_HST, "%d*%d ", count_values, value_old);
				print_return++;
			}
			value_old = value;
			count_values = 1;
		}
		if (print_return > 5)
		{
			output_msg(OUTPUT_HST, "\n     ");
			print_return = 0;
		}
	}
	if (count_values == 1)
	{
		output_msg(OUTPUT_HST, "%d\n", value_old);
	}
	else
	{
		output_msg(OUTPUT_HST, "%d*%d\n", count_values, value_old);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_double_element_property(size_t offset, double factor)
/* ---------------------------------------------------------------------- */
{
	int first, count_values, i;
	int print_return;
	double value, value_old;

	first = TRUE;
	count_values = 0;
	value_old = 0;
	print_return = 0;
	output_msg(OUTPUT_HST, "     ");
	for (i = 0; i < nxyz; i++)
	{
		if (cells[i].is_element == FALSE)
			continue;
		if (cells[i].elt_active == FALSE)
			continue;
		value = *(double *) ((char *) &(cells[i]) + offset);
		value *= factor;
		if (first == TRUE)
		{
			value_old = value;
			count_values = 1;
			first = FALSE;
		}
		else if (value == value_old)
		{
			count_values++;
		}
		else
		{
			if (count_values == 1)
			{
				output_msg(OUTPUT_HST, "%20.12e ", value_old);
				print_return++;
			}
			else
			{
				output_msg(OUTPUT_HST, "%d*%-20.12e ", count_values,
						   value_old);
				print_return++;
			}
			value_old = value;
			count_values = 1;
		}
		if (print_return > 3)
		{
			output_msg(OUTPUT_HST, "\n     ");
			print_return = 0;
		}
	}
	if (count_values == 1)
	{
		output_msg(OUTPUT_HST, "%20.12e\n", value_old);
	}
	else
	{
		output_msg(OUTPUT_HST, "%d*%-20.12e\n", count_values, value_old);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
write_thru(int thru)
/* ---------------------------------------------------------------------- */
{
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST, "C.....End of transient information\n");
	output_msg(OUTPUT_HST,
			   "C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n");
	output_msg(OUTPUT_HST,
			   "C.....Read sets of READ3 data at each TIMCHG until THRU  (Lines 3.N1.N2)\n");
	output_msg(OUTPUT_HST,
			   "C------------------------------------------------------------------------------\n");
	output_msg(OUTPUT_HST,
			   "C.....End of simulation line follows, THRU=.TRUE.\n");
	output_msg(OUTPUT_HST, "C.3.99.1 .. THRU\n");
	if (thru == TRUE)
	{
		output_msg(OUTPUT_HST, "     t\n");
		output_msg(OUTPUT_HST, "C.....End of the data file\n");
		output_msg(OUTPUT_HST,
				   "C------------------------------------------------------------------------------\n");
		output_msg(OUTPUT_HST,
				   "C------------------------------------------------------------------------------\n");
	}
	else
	{
		output_msg(OUTPUT_HST, "     f\n");
		output_msg(OUTPUT_HST,
				   "C------------------------------------------------------------------------------\n");
	}
	return (OK);
}

#ifdef SKIP
/* ---------------------------------------------------------------------- */
int
write_zone_budget(void)
/* ---------------------------------------------------------------------- */
{

	// Zone budget information
	output_msg(OUTPUT_HST, "C  Number of zone budgets \n");
	output_msg(OUTPUT_HST, "%d\n", (int) Zone_budget::zone_budget_map.size());

	int zone_budget_number = 1;
	std::map < int, Zone_budget * >::iterator it;
	for (it = Zone_budget::zone_budget_map.begin();
		 it != Zone_budget::zone_budget_map.end(); it++)
	{

		// vector of bools
		std::vector < bool > cells_in_budget;
		cells_in_budget.reserve(nxyz);
		int i;
		for (i = 0; i < nxyz; i++)
		{
			cells_in_budget.push_back(false);
		}

		zone z;
		it->second->Add_cells(cells_in_budget, &z, nxyz, cell_xyz);
		// cells_in_budget is nxyz list of 0 and 1

		assert(z.zone_defined);

		struct index_range *range_ptr = zone_to_range(&z);
		std::vector < std::pair < int, int >>faces;
		std::vector < int >specified_vector;	// list of cells
		std::vector < int >leaky_vector;	// list of segment numbers
		std::vector < int >flux_vector;	// list of segment numbers
		std::vector < int >flux_conditional_vector;	// list of segment numbers
		std::vector < int >river_vector;	// list of segment numbers
		std::vector < int >drain_vector;	// list of segment numbers
		std::vector < std::pair < int, int >>well_vector;	// list well, cell_fraction number

		int j, k, l, n;
		for (i = range_ptr->i1; i <= range_ptr->i2; i++)
		{
			for (j = range_ptr->j1; j <= range_ptr->j2; j++)
			{
				for (k = range_ptr->k1; k <= range_ptr->k2; k++)
				{
					n = ijk_to_n(i, j, k);
					if (!cells_in_budget[n])
						continue;
					if (!cells[n].cell_active)
						continue;
					std::vector < int >stencil;
					neighbors(n, stencil);

					// Cell face flows
					// x-
					if ((stencil[0] >= 0) && !cells_in_budget[stencil[0]])
					{
						faces.push_back(std::pair < int, int >(n, 3));
					}
					// x+
					if ((stencil[1] >= 0) && !cells_in_budget[stencil[1]])
					{
						faces.push_back(std::pair < int, int >(n, 4));
					}
					// y-
					if ((stencil[2] >= 0) && !cells_in_budget[stencil[2]])
					{
						faces.push_back(std::pair < int, int >(n, 2));
					}
					// y+
					if ((stencil[3] >= 0) && !cells_in_budget[stencil[3]])
					{
						faces.push_back(std::pair < int, int >(n, 5));
					}
					// z-
					if ((stencil[4] >= 0) && !cells_in_budget[stencil[4]])
					{
						faces.push_back(std::pair < int, int >(n, 1));
					}
					// z+
					if ((stencil[5] >= 0) && !cells_in_budget[stencil[5]])
					{
						faces.push_back(std::pair < int, int >(n, 6));
					}

					// Boundary condition flows
					// specified value
					if (cells[n].specified)
					{
						specified_vector.push_back(n);
						break;
					}

					// leaky
					if (cells[n].leaky)
					{
						int seg = cells[n].leaky_starting_segment_fortran;
						// Reverse terator on list of BC_info
						for (std::list < BC_info >::reverse_iterator rit =
							 cells[i].all_bc_info->rbegin();
							 rit != cells[i].all_bc_info->rend(); rit++)
						{
							if (rit->bc_type != BC_info::BC_LEAKY)
								continue;
							leaky_vector.push_back(seg++);
						}
					}

					// drain
					if (cells[n].drain_polygons->size() > 0)
					{
						int seg = cells[n].drain_starting_segment_fortran;
						for (std::vector < River_Polygon >::iterator j_it =
							 cells[i].drain_segments->begin();
							 j_it != cells[i].drain_segments->end(); j_it++)
						{
							drain_vector.push_back(seg++);
						}
					}

					// flux to cell, all but Z flux
					if (cells[n].flux)
					{
						int seg = cells[n].flux_starting_segment_fortran;
						// Reverse iterator on list of BC_info
						for (std::list < BC_info >::reverse_iterator rit =
							 cells[i].all_bc_info->rbegin();
							 rit != cells[i].all_bc_info->rend(); rit++)
						{
							if (rit->bc_type != BC_info::BC_FLUX)
								continue;
							if (rit->face != CF_Z)
							{
								flux_vector.push_back(seg);
							}
							seg++;
							// may want to skip z flux here and put in a conditional list
						}
					}

					//  Make conditional list for z fluxes
					for (l = stencil[6]; l >= n; l -= nx * ny)
					{
						if (cells[l].flux)
						{
							int seg = cells[l].flux_starting_segment_fortran;
							for (std::list < BC_info >::reverse_iterator rit =
								 cells[i].all_bc_info->rbegin();
								 rit != cells[i].all_bc_info->rend(); rit++)
							{
								if (rit->bc_type != BC_info::BC_FLUX)
									continue;
								if (rit->face == CF_Z)
								{
									flux_conditional_vector.push_back(seg);
								}
								seg++;
							}
						}
					}

					// Make conditional list of river segments at top of column
					if (cells[stencil[6]].count_river_polygons > 0)
					{

						int seg =
							cells[stencil[6]].river_starting_segment_fortran;
						for (l = 0;
							 l < cells[stencil[6]].count_river_polygons; l++)
						{
							river_vector.push_back(seg++);
						}
					}
				}
			}
		}
		for (i = 0; i < count_wells; i++)
		{
			for (j = 0; j < wells[i].count_cell_fraction; j++)
			{
				n = wells[i].cell_fraction[j].cell;
				if (cells_in_budget[n])
				{
					well_vector.push_back(std::pair < int,
										  int >(i + 1, j + 1));
				}
			}
		}

		// Write one zone budget 
		output_msg(OUTPUT_HST, "C Data for zone budget number %d \n",
				   zone_budget_number);

		// Inter cell flows
		output_msg(OUTPUT_HST,
				   "C Inter cell flows: list of <cell number, face> pairs followed by END\n");
		for (std::vector < std::pair < int, int >>::iterator it =
			 faces.begin(); it != faces.end(); it++)
		{
			output_msg(OUTPUT_HST, "     %d  %d\n", it->first, it->second);
		}
		output_msg(OUTPUT_HST, "END");

		// Specified value cells
		output_msg(OUTPUT_HST,
				   "C Specified value cells: list of cell numbers followed by END\n");
		for (std::vector < int >::iterator it = specified_vector.begin();
			 it != specified_vector.end(); it++)
		{
			output_msg(OUTPUT_HST, "     %d  \n", *it);
		}
		output_msg(OUTPUT_HST, "END");

		// Leaky segments
		output_msg(OUTPUT_HST,
				   "C Leaky: list of segment numbers followed by END\n");
		for (std::vector < int >::iterator it = leaky_vector.begin();
			 it != leaky_vector.end(); it++)
		{
			output_msg(OUTPUT_HST, "     %d  \n", *it);
		}
		output_msg(OUTPUT_HST, "END");

		// Flux segments
		output_msg(OUTPUT_HST,
				   "C Flux: list of segment numbers followed by END\n");
		for (std::vector < int >::iterator it = leaky_vector.begin();
			 it != leaky_vector.end(); it++)
		{
			output_msg(OUTPUT_HST, "     %d  \n", *it);
		}
		output_msg(OUTPUT_HST, "END");
	}

	return (OK);
}
#endif
/* ---------------------------------------------------------------------- */
int
write_zone_budget(void)
/* ---------------------------------------------------------------------- */
{

	// Zone budget information
	output_msg(OUTPUT_HST,
			   "C.2.23.8 .. Number of zones for flow rates: num_flo_zones \n");
	output_msg(OUTPUT_HST, "%d\n", (int) Zone_budget::zone_budget_map.size());
	if (Zone_budget::zone_budget_map.size() == 0)
		return (OK);

	int zone_budget_number = 1;
	std::map < int, Zone_budget * >::iterator it;
	for (it = Zone_budget::zone_budget_map.begin();
		 it != Zone_budget::zone_budget_map.end(); it++)
	{

		// vector of bools
		std::vector < bool > cells_in_budget;
		cells_in_budget.reserve(nxyz);
		int i;
		for (i = 0; i < nxyz; i++)
		{
			cells_in_budget.push_back(false);
		}

		zone z;
		it->second->Add_cells(cells_in_budget, &z, nxyz, cell_xyz);
		// cells_in_budget is nxyz list of 0 and 1

		assert(z.zone_defined);

		struct index_range *range_ptr = zone_to_range(&z);

		std::map < int, bool > budget_map;	// list of cells
		std::vector < std::pair < int, int > >faces;	// <cell number, face> pair 
		std::vector < int >specified_vector;	// list of cells
		std::vector < int >leaky_vector;	// list of cells
		std::vector < int >flux_vector;	// list of cells
		//std::vector< std::pair<int, int> > flux_conditional_vector;  // <target cell, flux cell> pair
		//std::map< int, bool > flux_conditional_map;                  // flux cells that might apear in budget
		std::set < int >flux_conditional_set;	// set of zplus flux cells

		//std::vector< std::pair<int, int> > river_vector;             // <target cell, river cell> pair 
		//std::map< int, bool > river_map;                             // river cells that might appear in budget
		std::set < int >river_set;	// set of river cells
		std::vector < int >drain_vector;	// list of cells
		std::vector < int >well_vector;	// list cells

		int j, k, l, n;

		// Need definition of zone for zp flux and river flux
		std::list < std::vector < int > >zone_def;
		//if (free_surface && (count_rivers > 0 || count_flux > 0))
		{
			for (i = range_ptr->i1; i <= range_ptr->i2; i++)
			{
				for (j = range_ptr->j1; j <= range_ptr->j2; j++)
				{
					std::vector < int >quad;
					quad.push_back(i);
					quad.push_back(j);
					for (k = range_ptr->k1; k <= range_ptr->k2; k++)
					{
						n = ijk_to_n(i, j, k);
						if (!cells_in_budget[n])
							continue;
						if (!cells[n].cell_active)
							continue;
						quad.push_back(k);
						break;
					}
					for (k = range_ptr->k2; k >= range_ptr->k1; k--)
					{
						n = ijk_to_n(i, j, k);
						if (!cells_in_budget[n])
							continue;
						if (!cells[n].cell_active)
							continue;
						quad.push_back(k);
						break;
					}
					assert(quad.size() == 2 || quad.size() == 4);
					if (quad.size() == 4)
					{
						zone_def.push_back(quad);
					}
				}
			}
		}
		for (k = range_ptr->k1; k <= range_ptr->k2; k++)
		{
			for (j = range_ptr->j1; j <= range_ptr->j2; j++)
			{
				for (i = range_ptr->i1; i <= range_ptr->i2; i++)
				{
					n = ijk_to_n(i, j, k);
					if (!cells_in_budget[n])
						continue;
					if (!cells[n].cell_active)
						continue;
					budget_map[n] = true;
					std::vector < int >stencil;
					neighbors_active(n, stencil);

					// Cell face flows
					// x-
					if ((stencil[0] >= 0) && !cells_in_budget[stencil[0]])
					{
						faces.push_back(std::pair < int, int >(n, 3));
					}
					// x+
					if ((stencil[1] >= 0) && !cells_in_budget[stencil[1]])
					{
						faces.push_back(std::pair < int, int >(n, 4));
					}
					// y-
					if ((stencil[2] >= 0) && !cells_in_budget[stencil[2]])
					{
						faces.push_back(std::pair < int, int >(n, 2));
					}
					// y+
					if ((stencil[3] >= 0) && !cells_in_budget[stencil[3]])
					{
						faces.push_back(std::pair < int, int >(n, 5));
					}
					// z-
					if ((stencil[4] >= 0) && !cells_in_budget[stencil[4]])
					{
						faces.push_back(std::pair < int, int >(n, 1));
					}
					// z+
					if ((stencil[5] >= 0) && !cells_in_budget[stencil[5]])
					{
						faces.push_back(std::pair < int, int >(n, 6));
					}

					// Boundary condition flows
					// specified value
					if (cells[n].specified)
					{
						specified_vector.push_back(n);
						continue;
					}

					// leaky
					if (cells[n].leaky)
					{
						leaky_vector.push_back(n);
					}

					// flux to cell, all but ZP flux
					if (cells[n].flux)
					{
						for (std::list < BC_info >::reverse_iterator rit =
							 cells[n].all_bc_info->rbegin();
							 rit != cells[n].all_bc_info->rend(); rit++)
						{
							if (rit->bc_type != BC_info::BC_FLUX)
								continue;
							// skipping z flux here and put in a conditional list
							if (rit->face != CF_Z
								|| (rit->face == CF_Z
									&& cells[n].exterior->zn)
								|| !free_surface)
							{
								flux_vector.push_back(n);
								break;
							}
						}
					}

					//  Make conditional list for z fluxes
					if (free_surface)
					{
						for (l = stencil[6]; l >= n; l -= nx * ny)
						{
							if (cells[l].flux)
							{
								for (std::list <
									 BC_info >::reverse_iterator rit =
									 cells[l].all_bc_info->rbegin();
									 rit != cells[l].all_bc_info->rend();
									 rit++)
								{
									if (rit->bc_type != BC_info::BC_FLUX)
										continue;
									if (rit->face == CF_Z
										&& cells[n].exterior->zp)
									{
										//flux_conditional_vector.push_back(std::pair<int, int> (n, l));
										//flux_conditional_map[l] = true;
										flux_conditional_set.insert(l);
										break;
									}
								}
							}
						}
					}

					// Make conditional list of river segments at top of column
					if (cells[stencil[6]].count_river_polygons > 0)
					{
						if (!cells[stencil[6]].specified)
						{
							river_set.insert(stencil[6]);
						}
					}

					// drain
					if (cells[n].drain_segments->size() > 0)
					{
						drain_vector.push_back(n);

					}
				}
			}
		}
		free_check_null(range_ptr);
		std::map < int, bool > well_map;
		for (i = 0; i < count_wells; i++)
		{
			if (!wells[i].in_region) continue;
			for (j = 0; j < wells[i].count_cell_fraction; j++)
			{
				n = wells[i].cell_fraction[j].cell;
				if (cells_in_budget[n])
				{
					well_map[n] = true;
				}
			}
		}

		// Write one zone budget 

		output_msg(OUTPUT_HST, "C.2.23.9 .. Title data for zone number %d \n",
				   zone_budget_number);
		output_msg(OUTPUT_HST, " %d %s\n", it->first,
				   it->second->Get_description().c_str());
		output_msg(OUTPUT_HST,
			"C.2.23.9.1 .. Write heads [t/f], file name\n");
		if (it->second->Get_write_heads())
		{
			output_msg(OUTPUT_HST, "t %s\n", it->second->Get_filename_heads().c_str());
		}
		else
		{
			output_msg(OUTPUT_HST, "f %s\n", "none");
		}
		int return_max = 10;
		int return_counter = 0;

		// Write zone definition if necessary
		if ((free_surface && (count_rivers > 0 || count_flux > 0)) || it->second->Get_write_heads())
		{
			output_msg(OUTPUT_HST,
					   "C.2.23.10 .. Cell volume indices: num_cell_columns; fresur && (nfbc > 0 || nrbc > 0)\n");
			output_msg(OUTPUT_HST, " %d\n", (int) zone_def.size());
			output_msg(OUTPUT_HST,
					   "C.2.23.11 .. Cell volume indices: i, j, kmin, kmax for num_cell_columns in zone\n");
			std::list < std::vector < int > >::iterator it = zone_def.begin();
			for (; it != zone_def.end(); it++)
			{
				std::vector < int >::iterator jt = it->begin();
				for (; jt != it->end(); jt++)
				{
					output_msg(OUTPUT_HST, "     %d", *jt + 1);
				}
				output_msg(OUTPUT_HST, "\n");
			}
		}


		// Inter cell flows
		output_msg(OUTPUT_HST,
				   "C.2.23.12 .. Internal boundaries: count; (O) - num_flo_zones > 0\n");
		output_msg(OUTPUT_HST, " %d\n", faces.size());
		output_msg(OUTPUT_HST,
				   "C.2.23.13 .. Internal boundaries: list of [cell number, face index] pairs; (O) - num_flo_zones > 0\n");
		return_counter = 0;
		return_max = 5;
		for (std::vector < std::pair < int, int > >::iterator it =
			 faces.begin(); it != faces.end(); it++)
		{
			output_msg(OUTPUT_HST, "     %d  %d", it->first + 1, it->second);
			if (++return_counter == return_max)
			{
				output_msg(OUTPUT_HST, "\n");
				return_counter = 0;
			}

		}
		if (return_counter != 0)
			output_msg(OUTPUT_HST, "\n");

		// Specified value cells
		if (count_specified > 0)
		{
			output_msg(OUTPUT_HST,
					   "C.2.23.14 .. Specified head cells: count; (O) nsbc > 0\n");
			output_msg(OUTPUT_HST, " %d\n", specified_vector.size());
			if (specified_vector.size() > 0)
			{
				output_msg(OUTPUT_HST,
						   "C.2.23.15 .. Specified head cells: list of cell numbers; (O) nsbc > 0\n");
				return_max = 10;
				return_counter = 0;
				for (std::vector < int >::iterator it =
					 specified_vector.begin(); it != specified_vector.end();
					 it++)
				{
					output_msg(OUTPUT_HST, "     %d", *it + 1);
					if (++return_counter == return_max)
					{
						output_msg(OUTPUT_HST, "\n");
						return_counter = 0;
					}
				}
				if (return_counter != 0)
					output_msg(OUTPUT_HST, "\n");
			}
		}

		// Flux cells
		if (count_flux > 0)
		{
			output_msg(OUTPUT_HST,
					   "C.2.23.16 .. Flux cells: count; (O) nfbc > 0\n");
			output_msg(OUTPUT_HST, " %d\n", flux_vector.size());
			if (flux_vector.size() > 0)
			{
				output_msg(OUTPUT_HST,
						   "C.2.23.17 .. Flux cells: list of cell numbers; (O) nfbc > 0\n");
				return_counter = 0;
				for (std::vector < int >::iterator it = flux_vector.begin();
					 it != flux_vector.end(); it++)
				{
					output_msg(OUTPUT_HST, "     %d", *it + 1);
					if (++return_counter == return_max)
					{
						output_msg(OUTPUT_HST, "\n");
						return_counter = 0;
					}
				}
				if (return_counter != 0)
					output_msg(OUTPUT_HST, "\n");
			}
		}
		// Conditional flux cells

		if (free_surface && count_flux > 0)
		{
			output_msg(OUTPUT_HST,
					   "C.2.23.18 .. Conditional Zplus flux cells: count; (O) - nfbc > 0 && fresur\n");
			output_msg(OUTPUT_HST, " %d\n", flux_conditional_set.size());
			output_msg(OUTPUT_HST,
					   "C.2.23.19 .. Conditional Zplus flux cells: list of cell numbers\n");

			return_counter = 0;
			for (std::set < int >::iterator it = flux_conditional_set.begin();
				 it != flux_conditional_set.end(); it++)
			{
				output_msg(OUTPUT_HST, "     %d", *it + 1);
				if (++return_counter == return_max)
				{
					output_msg(OUTPUT_HST, "\n");
					return_counter = 0;
				}
			}
			if (return_counter != 0)
				output_msg(OUTPUT_HST, "\n");
		}

		// Leaky cells
		if (count_leaky > 0)
		{
			output_msg(OUTPUT_HST,
					   "C.2.23.20 .. Leakage cells: count; (O) nlbc > 0\n");
			output_msg(OUTPUT_HST, " %d\n", leaky_vector.size());
			if (leaky_vector.size() > 0)
			{
				output_msg(OUTPUT_HST,
						   "C.2.23.21 .. Leakage cells: list of cell numbers; (O) nlbc > 0\n");
				return_counter = 0;
				for (std::vector < int >::iterator it = leaky_vector.begin();
					 it != leaky_vector.end(); it++)
				{
					output_msg(OUTPUT_HST, "     %d", *it + 1);
					if (++return_counter == return_max)
					{
						output_msg(OUTPUT_HST, "\n");
						return_counter = 0;
					}
				}
				if (return_counter != 0)
					output_msg(OUTPUT_HST, "\n");
			}
		}


		// Conditional river segments

		if (count_river_segments > 0)
		{
			output_msg(OUTPUT_HST,
					   "C.2.23.22 .. Conditional river leakage cells: count; (O) nrbc > 0\n");
			output_msg(OUTPUT_HST, " %d\n", river_set.size());
			if (river_set.size() > 0)
			{
				output_msg(OUTPUT_HST,
						   "C.2.23.23 .. Conditional river leakage cells: list of cell numbers; (O) nrbc > 0\n");
				return_counter = 0;
				for (std::set < int >::iterator it = river_set.begin();
					 it != river_set.end(); it++)
				{
					output_msg(OUTPUT_HST, "     %d", *it + 1);
					if (++return_counter == return_max)
					{
						output_msg(OUTPUT_HST, "\n");
						return_counter = 0;
					}
				}
				if (return_counter != 0)
					output_msg(OUTPUT_HST, "\n");
			}
		}

		// Drain cells
		if (count_drain_segments > 0)
		{
			output_msg(OUTPUT_HST,
					   "C.2.23.24 .. Drain cells: count; (O) ndbc > 0\n");
			output_msg(OUTPUT_HST, " %d\n", drain_vector.size());
			if (drain_vector.size() > 0)
			{
				output_msg(OUTPUT_HST,
						   "C.2.23.25 .. Drain cells: list of cell numbers; (O) ndbc > 0\n");
				return_counter = 0;
				for (std::vector < int >::iterator it = drain_vector.begin();
					 it != drain_vector.end(); it++)
				{
					output_msg(OUTPUT_HST, "     %d", *it + 1);
					if (++return_counter == return_max)
					{
						output_msg(OUTPUT_HST, "\n");
						return_counter = 0;
					}
				}
				if (return_counter != 0)
					output_msg(OUTPUT_HST, "\n");
			}
		}

		// Well cells
		if (count_wells_in_region > 0)
		{
			output_msg(OUTPUT_HST,
					   "C.2.23.26 .. Well cells: count; (O) nwel > 0\n");
			output_msg(OUTPUT_HST, " %d\n", well_map.size());
			if (well_map.size() > 0)
			{
				output_msg(OUTPUT_HST,
						   "C.2.23.27 .. Well cells: list of cell numbers; (O) nwel > 0\n");
				return_counter = 0;
				for (std::map < int, bool >::iterator it = well_map.begin();
					 it != well_map.end(); it++)
				{
					output_msg(OUTPUT_HST, "     %d", it->first + 1);
					if (++return_counter == return_max)
					{
						output_msg(OUTPUT_HST, "\n");
						return_counter = 0;
					}
				}
				if (return_counter != 0)
					output_msg(OUTPUT_HST, "\n");
			}
		}
		output_msg(OUTPUT_HST,
				   "C.... Use as many 2.23.9-2.23.27 lines as necessary\n");

	}
	//output_msg(OUTPUT_HST, "C.2.23.16 .. End with END; (O) - num_flow_zones > 0\n");
	output_msg(OUTPUT_HST, "C .. End 2.23.8 Zone flow accounting\n");
	output_msg(OUTPUT_HST, "END\n");
	return (OK);
}
