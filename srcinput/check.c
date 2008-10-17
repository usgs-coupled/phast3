#define EXTERNAL extern
#include "hstinpt.h"
#include "stddef.h"
static char const svnid[] = "$Id$";

/* ---------------------------------------------------------------------- */
int check_properties(void)
/* ---------------------------------------------------------------------- */
{
	char name[MAX_LENGTH];

	// Set active cells earlier in setup_bc so can skip inactive cells
	//set_active_cells();
	check_elements();
	check_cells();
	check_dimensions();
	if ((free_surface == FALSE) && (count_rivers > 0)) {
		input_error++;
		error_msg("Rivers may not be used with confined flow.", CONTINUE);
	}
	/* eliminate .xyz.well file for flow_only */
	if ((flow_only == TRUE) && (print_xyz_wells.properties != NULL) && (print_xyz_wells.count_properties > 0)) {
		strcpy(name, prefix);
		strcat(name, ".xyz.wel");
		sprintf(error_string,"The file %s only applies to simulations with chemistry.\n"
			"\tThe file will not be written.", name);
		warning_msg(error_string);
		current_print_xyz_wells.value = 0;
	}
	if ((save_final_heads == TRUE) && (head_ic_file_warning == TRUE)) {
		input_error++;
		strcpy(name, prefix);
		strcat(name, ".head.dat");
		sprintf(error_string,"Writing heads to file (PRINT_FREQUENCY; -save_final_heads true)\n\twill overwrite a file used for initial conditions, %s.", name);
		error_msg(error_string, CONTINUE);
	}
	check_time_data();
	if (input_error > 0) {
		error_msg("Stopping because of input errors.", STOP);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int check_dimensions(void)
/* ---------------------------------------------------------------------- */
{
	int i, j;

	if (flow_only == TRUE) return(OK);
	j = 0;
	for (i = 0; i < 3; i++) {
		if (axes[i] == FALSE) {
			if (grid[i].count_coord != 2) {
				input_error++;
				sprintf(error_string, "Coordinate %c was not defined to be active in -chemistry_dimensions identifier of GRID keyword,\n\texactly 2 nodes must be defined in this direction with GRID.", grid[i].c);
				error_msg(error_string, CONTINUE);
			}
		} else {
			j++;
		}
	}
	if (j == 0) {
		input_error++;
		sprintf(error_string, "No coordinate directions were defined to be active in -chemistry_dimensions identifier of GRID keyword.");
		error_msg(error_string, CONTINUE);
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int check_hst_units(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Check required_units are defined
 *   Include additional factors for units involving time to
 *   convert to user units.
 */	
	si_to_user = 1;
	if (units.time.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Time units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		si_to_user = 1.0 / units.time.input_to_si;
		units.time.input_to_user = 1.0;
	}
	if (units.horizontal.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Horizontal grid units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} 
	if (units.vertical.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Vertical grid units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	}
	if (units.head.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Head units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	}
	if (units.k.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Hydraulic conductivity units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.k.input_to_user = units.k.input_to_si * (1/si_to_user);
	}
	if (units.s.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Specific storage units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	}
	if (units.alpha.defined == FALSE && flow_only == FALSE) {
		input_error++;
		sprintf(error_string, "Dispersivity units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	}
	if (count_leaky > 0 && units.leaky_k.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Hydraulic conductivity units for leaky boundary not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.leaky_k.input_to_user = units.leaky_k.input_to_si * (1/si_to_user);
	}
	if (count_leaky > 0 && units.leaky_thick.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Units of thickness for leaky boundary not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	}
	if (count_flux > 0 && units.flux.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Flux units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.flux.input_to_user = units.flux.input_to_si * (1/si_to_user);
	}
	if (count_wells > 0 && units.well_pumpage.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Well pumpage units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.well_pumpage.input_to_user = units.well_pumpage.input_to_si * (1/si_to_user);
	}
	if (count_wells > 0 && units.well_diameter.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Well diameter units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.well_diameter.input_to_user = units.well_diameter.input_to_si;
	}
	if (count_rivers > 0 && units.river_bed_k.defined == FALSE) {
		input_error++;
		sprintf(error_string, "River bed hydraulic conductivity units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.river_bed_k.input_to_user = units.river_bed_k.input_to_si * (1/si_to_user);
	}
	if (count_rivers > 0 && units.river_bed_thickness.defined == FALSE) {
		input_error++;
		sprintf(error_string, "River bed thickness units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.river_bed_thickness.input_to_user = units.river_bed_thickness.input_to_si;
	}
	if (count_rivers > 0 && units.river_width.defined == FALSE) {
		input_error++;
		sprintf(error_string, "River width units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.river_width.input_to_user = units.river_width.input_to_si;
	}
	if (drains.size() > 0 && units.drain_bed_k.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Drain bed hydraulic conductivity units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.drain_bed_k.input_to_user = units.drain_bed_k.input_to_si * (1/si_to_user);
	}
	if (drains.size() > 0 && units.drain_bed_thickness.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Drain bed thickness units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.drain_bed_thickness.input_to_user = units.drain_bed_thickness.input_to_si;
	}
	if (drains.size() > 0 && units.drain_width.defined == FALSE) {
		input_error++;
		sprintf(error_string, "Drain width units not defined in UNITS data block.");
		error_msg(error_string, CONTINUE);
	} else {
		units.drain_width.input_to_user = units.drain_width.input_to_si;
	}


/*
 *   These units do not involve time
 *   only need to convert to m
 */
	units.horizontal.input_to_user = units.horizontal.input_to_si; 
	units.vertical.input_to_user = units.vertical.input_to_si; 
	units.head.input_to_user = units.head.input_to_si; 
	units.s.input_to_user = units.s.input_to_si; 
	if (flow_only == FALSE) {
		units.alpha.input_to_user = units.alpha.input_to_si; 
	}
	units.leaky_thick.input_to_user = units.leaky_thick.input_to_si; 


	return(OK);
}
/* ---------------------------------------------------------------------- */
int check_time_units(struct time *time_ptr, int required, const char *errstr)
/* ---------------------------------------------------------------------- */
{
/*
 *   function calcuates time_ptr->input_to_usr
 *   checks for units consistency
 *   if required == TRUE, then time_ptr->value_defined must be TRUE
 */

	time_ptr->input_to_user = 1;
/*	
 *   value defined
 */
	if (required == TRUE && time_ptr->value_defined == FALSE) {
		input_error++;
		sprintf(error_string, "Not defined: %s.", errstr);
		error_msg(error_string, CONTINUE);
		return(ERROR);
	} 
/*
 *   STEP can not be used for end_time or time_step
 */
	if (time_ptr->type == STEP && required == TRUE) {
		input_error++;
		sprintf(error_string, "Must enter time unit (T), not STEP, %s.", errstr);
		error_msg(error_string, CONTINUE);
		return(ERROR);
	} 
/*
 *   If step, skip conversion factor
 */
	if (time_ptr->type == STEP) {
		return(OK);
	} 
/*
 *   If units not defined, then user units are assumed
 *   no conversion necessary
 */
	if (time_ptr->input != NULL) {
/*
 *   Calculate conversion factor
 */
		if (units_conversion(time_ptr->input, "s", &(time_ptr->input_to_si), TRUE) == ERROR) {
			input_error++;
			sprintf(error_string, "%s.", errstr);
			error_msg(error_string, CONTINUE);
			return(ERROR);
		}		
		time_ptr->input_to_user = time_ptr->input_to_si * si_to_user;
	} else {
		time_ptr->input_to_si = 1/si_to_user;
	}
	/*
	 *  Check that time step is <= than all print frequencies
	 */
	if (time_ptr->type != UNDEFINED && required == FALSE && time_ptr->value > 0) {
		if (current_time_step.value * current_time_step.input_to_user > time_ptr->value * time_ptr->input_to_user) {
			input_error++;
			sprintf(error_string, "Print frequency, %g, for %s, must not be less than time step, %g %c.", time_ptr->value * time_ptr->input_to_user, errstr, current_time_step.value * current_time_step.input_to_user, units.time.input[0]);
			error_msg(error_string, CONTINUE);
			return(ERROR);
		}
	}
	return(OK);
}
/* ---------------------------------------------------------------------- */
int check_ss_time_units(struct time *time_ptr, const char *errstr)
/* ---------------------------------------------------------------------- */
{
/*
 *   function calcuates time_ptr->input_to_usr
 *   checks for units consistency
 *   if required == TRUE, then time_ptr->value_defined must be TRUE
 */

	time_ptr->input_to_user = 1;
/*
 *   STEP can not be used for end_time or time_step
 */
	if (time_ptr->type == STEP) {
		input_error++;
		sprintf(error_string, "Must enter time unit (T), not STEP, %s.", errstr);
		error_msg(error_string, CONTINUE);
		return(ERROR);
	} 
/*
 *   If units not defined, then user units are assumed
 *   no conversion necessary
 */
	if (time_ptr->input != NULL) {
/*
 *   Calculate conversion factor
 */
		if (units_conversion(time_ptr->input, "s", &(time_ptr->input_to_si), TRUE) == ERROR) {
			input_error++;
			sprintf(error_string, "%s.", errstr);
			error_msg(error_string, CONTINUE);
			return(ERROR);
		}		
		time_ptr->input_to_user = time_ptr->input_to_si * si_to_user;
	} 
	return(OK);
}

/* ---------------------------------------------------------------------- */
int set_active_cells(void)
/* ---------------------------------------------------------------------- */
{
	int i, n;
	int ii, jj, kk;
	int ix, jy, kz;
	int count_active_cells;
/*
 *   Go through elements, set active cells
 */
	count_active_cells = 0;
	for (i = 0; i < nxyz; i++) {
		if (cells[i].is_element == FALSE) continue;
		if (cells[i].elt_active == FALSE) continue;
		ix = cells[i].ix;
		jy = cells[i].iy;
		kz = cells[i].iz;
		for (ii = ix; ii <= ix+1; ii++) {
			for (jj = jy; jj <= jy+1; jj++) {
				for (kk = kz; kk <= kz+1; kk++) {
					n = ijk_to_n(ii, jj, kk);
					if (n < 0) {
						error_msg("Setting active for cells",STOP);
					}
					cells[n].cell_active = TRUE;
					count_active_cells++;
				}
			}
		}
	}
	if (count_active_cells <= 0) {
		input_error++;
		sprintf(error_string,"No active cells in model.\n");
		error_msg(error_string, CONTINUE);
	}
	return(OK);
}

/* ---------------------------------------------------------------------- */
int check_cells(void)
/* ---------------------------------------------------------------------- */
{
  int i;
  /*
  *   check values
  */
  for (i = 0; i < nxyz; i++) {
    if (cells[i].cell_active == FALSE) continue;
    sprintf(tag,"for cell %d (%d,%d,%d) (%g,%g,%g).", 
      cells[i].number,
      cells[i].ix, cells[i].iy,cells[i].iz,
      cells[i].x, cells[i].y,cells[i].z);

    /* 
    *   Head initial condition
    */
    if (cells[i].ic_head_defined == FALSE) {
      input_error++;
      sprintf(error_string,"Head initial condition not defined %s", tag);
      error_msg(error_string, CONTINUE);
    }

    /* 
    *   Solution initial condition
    */
    if (cells[i].ic_solution_defined == FALSE && flow_only == FALSE ) {
      input_error++;
      sprintf(error_string,"Solution initial condition not defined %s", tag);
      error_msg(error_string, CONTINUE);
    }

    /* 
    *   Boundary conditions
    */

    // Specified value
    if (cells[i].specified)
    {
      if (cells[i].count_river_polygons > 0) {
	sprintf(error_string,"River is defined for specified-value cell; river will be ignored %s", tag);
	warning_msg(error_string);
      }
      if (cells[i].drain_polygons->size() > 0) {
	sprintf(error_string,"Drain is defined for specified-value cell; drain will be ignored %s", tag);
	warning_msg(error_string);
      }
      std::list<BC_info>::reverse_iterator rit = cells[i].all_bc_info->rbegin();

      // Head defined
      if (!rit->bc_head_defined)
      {
	// Search for earlier head definition
	for (std::list<BC_info>::reverse_iterator rit1 = cells[i].all_bc_info->rbegin(); rit1 != cells[i].all_bc_info->rend(); rit1++)
	{
	  if (rit1->bc_head_defined)
	  {
	    rit->bc_head = rit1->bc_head;
	    rit->bc_head_defined = true;
	    break;
	  }
	}
	if (!rit->bc_head_defined)
	{
	  input_error++;
	  sprintf(error_string,"Head for SPECIFIED_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	}
      }

      // Solution type defined
      if (rit->bc_solution_type == UNDEFINED && flow_only == FALSE)
      {
	// Search for earlier solution type definition
	for (std::list<BC_info>::reverse_iterator rit1 = cells[i].all_bc_info->rbegin(); rit1 != cells[i].all_bc_info->rend(); rit1++)
	{
	  if (rit1->bc_solution_type != UNDEFINED)
	  {
	    rit->bc_solution_type = rit1->bc_solution_type;
	    break;
	  }
	}
	if (rit->bc_solution_type == UNDEFINED)
	{
	  input_error++;
	  sprintf(error_string,"Solution type for SPECIFIED_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	}
      }

      // Solution defined
      if (!rit->bc_solution_defined && flow_only == FALSE)
      {
	// Search for earlier solution definition
	for (std::list<BC_info>::reverse_iterator rit1 = cells[i].all_bc_info->rbegin(); rit1 != cells[i].all_bc_info->rend(); rit1++)
	{
	  if (rit1->bc_solution_defined)
	  {
	    rit->bc_solution.i1 = rit1->bc_solution.i1;
	    rit->bc_solution.i2 = rit1->bc_solution.i2;
	    rit->bc_solution.f1 = rit1->bc_solution.f1;
	    rit->bc_solution_defined = true;
	    break;
	  }
	}
	if (!rit->bc_solution_defined)
	{
	  input_error++;
	  sprintf(error_string,"Solution for SPECIFIED_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	}
      }
    }

    // Flux bc
    if (cells[i].flux)
    {
      for (std::list<BC_info>::reverse_iterator rit = cells[i].all_bc_info->rbegin(); rit != cells[i].all_bc_info->rend(); rit++)
      {
	if (rit->bc_type != BC_info::BC_FLUX) continue;

	// Flux defined
	if (!rit->bc_flux_defined) {
	  input_error++;
	  sprintf(error_string,"Flux for FLUX_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	}

	// Solution type defined
	if (rit->bc_solution_type != ASSOCIATED && flow_only == FALSE ) {
	  input_error++;
	  sprintf(error_string,"Associated solution for FLUX_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	  break;
	}

	// Solution defined
	if (!rit->bc_solution_defined && flow_only == FALSE ) {
	  input_error++;
	  sprintf(error_string,"Associated solution for FLUX_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	}
      }
    }

    // Leaky bc
    if (cells[i].leaky)
    {
      for (std::list<BC_info>::reverse_iterator rit = cells[i].all_bc_info->rbegin(); rit != cells[i].all_bc_info->rend(); rit++)
      {
	if (rit->bc_type != BC_info::BC_LEAKY) continue;

	// Head defined
	if (!rit->bc_head_defined) {
	  input_error++;
	  sprintf(error_string,"Head for LEAKY_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	}

	// K defined
	if (!rit->bc_k_defined) {
	  input_error++;
	  sprintf(error_string,"Hydraulic conductivity for LEAKY_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	}

	// Thickness defined
	if (!rit->bc_thick_defined) {
	  input_error++;
	  sprintf(error_string,"Thickness for LEAKY_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	}

	// Solution type defined
	if (rit->bc_solution_type != ASSOCIATED && flow_only == FALSE ) {
	  input_error++;
	  sprintf(error_string,"Associated solution for LEAKY_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	  break;
	}

	// Solution defined
	if (!rit->bc_solution_defined && flow_only == FALSE ) {
	  input_error++;
	  sprintf(error_string,"Solution for LEAKY_BC not defined %s", tag);
	  error_msg(error_string, CONTINUE);
	}
      }
    }
  }
  return(OK);
}

/* ---------------------------------------------------------------------- */
int check_elements(void)
/* ---------------------------------------------------------------------- */
{
	int i, need_crossd;
/*
 *   check values
 */
	need_crossd = FALSE;
	for (i = 0; i < nxyz; i++) {
		if (cells[i].is_element == FALSE) continue;
		if (cells[i].elt_active == FALSE) continue;
		sprintf(tag,"for element %d (%d,%d,%d) (%g,%g,%g).", 
			cells[i].number,
			cells[i].ix, cells[i].iy,cells[i].iz,
			cells[i].x, cells[i].y,cells[i].z);
/* 
 *   Porosity
 */
		if (cells[i].porosity_defined == FALSE) {
			input_error++;
			sprintf(error_string,"Porosity not defined %s", tag);
			error_msg(error_string, CONTINUE);
		}
/* 
 *   X hydraulic conductivity
 */
		if (cells[i].kx_defined == FALSE) {
			input_error++;
			sprintf(error_string,"X hydraulic conductivity not defined %s", tag);
			error_msg(error_string, CONTINUE);
		}
/* 
 *   Y hydraulic conductivity
 */
		if (cells[i].ky_defined == FALSE) {
			input_error++;
			sprintf(error_string,"Y hydraulic conductivity not defined %s", tag);
			error_msg(error_string, CONTINUE);
		}
/* 
 *   Z hydraulic conductivity
 */
		if (cells[i].kz_defined == FALSE) {
			input_error++;
			sprintf(error_string,"Z hydraulic conductivity not defined %s", tag);
			error_msg(error_string, CONTINUE);
		}
/* 
 *   Specific storage
 */
		if (free_surface == FALSE && cells[i].storage_defined == FALSE) {
			input_error++;
			sprintf(error_string,"Specific storage not defined %s", tag);
			error_msg(error_string, CONTINUE);
		}
/* 
 *   Longitudinal dispersivity
 */
		if (cells[i].alpha_long_defined == FALSE && flow_only == FALSE ) {
			input_error++;
			sprintf(error_string,"Longitudinal dispersivity not defined %s", tag);
			error_msg(error_string, CONTINUE);
		}
/* 
 *   Horizontal dispersivity
 */
		if (cells[i].alpha_horizontal_defined == FALSE && flow_only == FALSE) {
			input_error++;
			sprintf(error_string,"Horizontal dispersivity not defined %s", tag);
			error_msg(error_string, CONTINUE);
		}

/* 
 *   Vertical dispersivity
 */
		if (cells[i].alpha_vertical_defined == FALSE && flow_only == FALSE) {
			input_error++;
			sprintf(error_string,"Vertical dispersivity not defined %s", tag);
			error_msg(error_string, CONTINUE);
		}

		if (cells[i].alpha_horizontal_defined == TRUE && cells[i].alpha_long_defined == TRUE) {
			if ((cells[i].alpha_horizontal != cells[i].alpha_long) ||
			    (cells[i].alpha_vertical != cells[i].alpha_long)) {
				need_crossd = TRUE;
			}
		}
	}		
	if (flow_only == FALSE && need_crossd == TRUE && cross_dispersion == FALSE) {
		sprintf(error_string,"Horizontal, vertical, and longitudinal dispersivities are not equal for at least one element.\n\tHowever, cross-dispersion calculation is disabled (-cross_dispersion in SOLUTION_METHOD).");
		warning_msg(error_string);
	}
	return(OK);
}

/* ---------------------------------------------------------------------- */
int ijk_to_n_no_error(int i, int j, int k)
/* ---------------------------------------------------------------------- */
{
	int n, return_value;
	n = nx*ny*k + nx*j + i;
	if (n >= 0 && n < nxyz) {
		return_value = n;
	} else {
		return_value = -1;
	}
	return(return_value);
}
/* ---------------------------------------------------------------------- */
int check_leaky_for_face(int i, int j)
/* ---------------------------------------------------------------------- */
{
/* 
 * i is node number 
 * j coordinate direction
 */
	int k, dx, dy, dz, n, return_value;
	int e[8];
/*
 *  Check to see which of eight elements is present
 *  numbering is from lower, front, left by x, y, z.
 *  0, 1, 2, 3 is lower set of elements; 4, 5, 6, 7 is upper set
 */
	k = 0;
	for (dz = -1; dz <= 0; dz++) {
		for (dy = -1; dy <= 0; dy++) {
			for (dx = -1; dx < 1; dx++) {
				n = ijk_to_n_no_error(cells[i].ix + dx, cells[i].iy + dy, cells[i].iz + dz);
				if (n != -1 && cells[n].is_element && cells[n].elt_active == TRUE) {
					e[k] = TRUE;
				} else {
					e[k] = FALSE;
				}
				k++;
			}
		}
	}
/*
 *  Check by coordinate direction
 */
	return_value = ERROR;
	if (j == 0) {
		if ( (e[0] ^ e[1]) ||
		     (e[2] ^ e[3]) ||
		     (e[4] ^ e[5]) ||
		     (e[6] ^ e[7])) {
			return_value = OK;
		}
	} else if (j == 1) {
		if ( (e[0] ^ e[2]) ||
		     (e[1] ^ e[3]) ||
		     (e[4] ^ e[6]) ||
		     (e[5] ^ e[7])) {
			return_value = OK;
		}
	} else if (j == 2) {
		if ( (e[0] ^ e[4]) ||
		     (e[1] ^ e[5]) ||
		     (e[2] ^ e[6]) ||
		     (e[3] ^ e[7])) {
			return_value = OK;
		}
	}
	return (return_value);
}
/* ---------------------------------------------------------------------- */
int check_time_data(void)
/* ---------------------------------------------------------------------- */
{
	/*
	 *   Check steady state velocity flags
	 */
	if (steady_flow == FALSE) {
		if (((print_input_hdf_ss_vel == TRUE) && (print_input_hdf_ss_vel_defined == TRUE))
		    || ((print_input_xyz_ss_vel == TRUE) && (print_input_xyz_ss_vel_defined == TRUE))
		    || ((print_input_ss_vel == TRUE && print_input_ss_vel_defined == TRUE))) {
			sprintf(error_string, "Identifiers Steady_flow_velocities, HDF_steady_flow_velocities,\n"
				"         and XYZ_steady_flow_velocities only apply for steady-flow calculations.");
			warning_msg(error_string);
		}
	} 
	if (steady_flow == TRUE) {
		if (min_ss_time_step.value_defined == FALSE) {
			min_ss_time_step.value = current_time_step.value/1000;
			if (current_time_step.input != NULL) {
				min_ss_time_step.input = string_duplicate(current_time_step.input);
			}
		}
		check_ss_time_units(&min_ss_time_step, "minimum time_step in STEADY_FLOW data block.");
		if (max_ss_time_step.value_defined == FALSE) {
			max_ss_time_step.value = current_time_step.value*1000;
			if (current_time_step.input != NULL) {
				max_ss_time_step.input = string_duplicate(current_time_step.input);
			}
		}
		check_ss_time_units(&max_ss_time_step, "maximum time_step in STEADY_FLOW data block.");
	}
	if (time_start.value_defined == FALSE) {
	  time_start.value = 0.0;
	}
	check_ss_time_units(&time_start, "starting time in TIME_CONTROL data block.");
	return(OK);
}
/* ---------------------------------------------------------------------- */
int check_time_series_data(void)
/* ---------------------------------------------------------------------- */
{
/*
 *   Time parameters
 */
	int i, j;
	/*
	 * Boundary conditions
	 */
	for (i = 0; i < count_bc; i++) {
		if (bc[i]->bc_head != NULL) check_time_series(bc[i]->bc_head, TRUE, "bc head");
		if (bc[i]->bc_flux != NULL) check_time_series(bc[i]->bc_flux, TRUE, "bc head");
		if (bc[i]->bc_solution != NULL && flow_only == FALSE) check_time_series(bc[i]->bc_solution, TRUE, "bc solution");
	}
	/*
	 * Rivers
	 */
	for (i = 0; i < count_rivers; i++) {
		for (j = 0; j < rivers[i].count_points; j++) {
			if (rivers[i].points[j].solution != NULL && flow_only == FALSE) {
				check_time_series(rivers[i].points[j].solution, TRUE, "river solution");
			}
			if (rivers[i].points[j].head != NULL) {
				check_time_series(rivers[i].points[j].head, TRUE, "river head");
			}
		}
	}
	/*
	 * Wells
	 */
	for (i = 0; i < count_wells; i++) {
		if (wells[i].solution != NULL && flow_only == FALSE) {
			check_time_series(wells[i].solution, TRUE, "well solution");
		}
		if (wells[i].q != NULL) {
			check_time_series(wells[i].q, TRUE, "well pumping rate");
		}
	}
	/*
	 * Time step
	 */
	if (time_step.properties != NULL) check_time_series(&time_step, TRUE, "time step");
	/*
	 *  Sort end times
	 */
	if (time_end == NULL) {
		input_error++;
		error_msg("Data not defined for end of simulation, TIME_CONTROL", CONTINUE);
	} else if (time_end[0].value_defined == FALSE) {
		input_error++;
		error_msg("Incorrect data for end of simulation periods, TIME_CONTROL", CONTINUE);
	} else {
		for (i = 0; i < count_time_end; i++) {
			check_time_units(&(time_end[i]), FALSE, "time_end");
		}
		qsort (time_end, (size_t) count_time_end, sizeof(struct time), time_compare);
	}
	/*
	 *  Print frequencies
	 */
	if (print_velocity.properties != NULL) check_time_series(&print_velocity, FALSE, "print velocity");
	if (print_hdf_velocity.properties != NULL) check_time_series(&print_hdf_velocity, FALSE, "print hdf velocity");
	if (print_xyz_velocity.properties != NULL) check_time_series(&print_xyz_velocity, FALSE, "print xyz velocity");
	if (print_head.properties != NULL) check_time_series(&print_head, FALSE, "print head");
	if (print_hdf_head.properties != NULL) check_time_series(&print_hdf_head, FALSE, "print hdf head");
	if (print_xyz_head.properties != NULL) check_time_series(&print_xyz_head, FALSE, "print xyz head");
	if (flow_only == FALSE) {
		if (print_force_chem.properties != NULL) check_time_series(&print_force_chem, FALSE, "force chemistry print");
		if (print_hdf_chem.properties != NULL) check_time_series(&print_hdf_chem, FALSE, "print hdf chemistry");
		if (print_xyz_chem.properties != NULL) check_time_series(&print_xyz_chem, FALSE, "print xyz chemistry");
		if (print_comp.properties != NULL) check_time_series(&print_comp, FALSE, "print components");
		if (print_xyz_comp.properties != NULL) check_time_series(&print_xyz_comp, FALSE, "print xyz components");
	}
	if (print_wells.properties != NULL) check_time_series(&print_wells, FALSE, "print wells");
	if (print_xyz_wells.properties != NULL) check_time_series(&print_xyz_wells, FALSE, "print xyz wells");
	if (print_statistics.properties != NULL) check_time_series(&print_statistics, FALSE, "print statistics");
	if (print_flow_balance.properties != NULL) check_time_series(&print_flow_balance, FALSE, "print flow balance");
	if (print_bc_flow.properties != NULL) check_time_series(&print_bc_flow, FALSE, "print bc flow");
	if (print_conductances.properties != NULL) check_time_series(&print_conductances, FALSE, "print conductances");
	if (print_bc.properties != NULL) check_time_series(&print_bc, FALSE, "print boundary conditions");
	if (print_end_of_period.properties != NULL) check_time_series(&print_end_of_period, FALSE, "print end of period default");
	if (print_restart.properties != NULL) check_time_series(&print_restart, FALSE, "print restart");
	if (print_zone_budget.properties != NULL) check_time_series(&print_zone_budget, FALSE, "print zone budget");
	/* 
	 * check defaults
	 */
	check_time_units(&current_print_velocity, FALSE, "current_print_velocity");
	check_time_units(&current_print_hdf_velocity, FALSE, "current_print_hdf_velocity");
	check_time_units(&current_print_xyz_velocity, FALSE, "current_print_xyz_velocity");
	check_time_units(&current_print_head, FALSE, "current_print_head");
	check_time_units(&current_print_hdf_head, FALSE, "current_print_hdf_head");
	check_time_units(&current_print_xyz_head, FALSE, "current_print_xyz_head");
	if (flow_only == FALSE) {
		check_time_units(&current_print_force_chem, FALSE, "current_print_force_chem");
		check_time_units(&current_print_hdf_chem, FALSE, "current_print_hdf_chem");
		check_time_units(&current_print_xyz_chem, FALSE, "current_print_xyz_chem");
		check_time_units(&current_print_comp, FALSE, "current_print_comp");
		check_time_units(&current_print_xyz_comp, FALSE, "current_print_xyz_comp");
	}
	check_time_units(&current_print_wells, FALSE, "current_print_wells");
	check_time_units(&current_print_xyz_wells, FALSE, "current_print_xyz_wells");
	check_time_units(&current_print_statistics, FALSE, "current_print_statistics");
	check_time_units(&current_print_flow_balance, FALSE, "current_print_flow_balance");
	check_time_units(&current_print_bc_flow, FALSE, "current_print_bc_flow");
	check_time_units(&current_print_conductances, FALSE, "current_print_conductances");

	return(OK);
}
/* ---------------------------------------------------------------------- */
int check_time_series(struct time_series *ts_ptr, int start_at_zero, const char * errorString)
/* ---------------------------------------------------------------------- */
{
	int i, count;

	count = ts_ptr->count_properties;

	for (i = 0; i < count; i++) {
		if (check_time_units(&(ts_ptr->properties[i]->time), FALSE, "time series") == ERROR) {
			input_error++;
			sprintf(error_string,"Time units error %s:", errorString);
			error_msg(error_string, CONTINUE);
			return(ERROR);
		}
		if (ts_ptr->properties[i]->time_value.value_defined == TRUE) {
			if (check_time_units(&(ts_ptr->properties[i]->time_value), FALSE, "time series") == ERROR) {
				input_error++;
				sprintf(error_string,"Time units error: %s", errorString);
				error_msg(error_string, CONTINUE);
				return(ERROR);
			}
		}
	}
	

	time_series_sort (ts_ptr);
	if (start_at_zero == TRUE) {
		if (ts_ptr->properties != NULL) {
			if (ts_ptr->properties[0]->time.value != 0.0) {
				input_error++;
				sprintf(error_string,"Time series must start at time zero: %s", errorString);
				error_msg(error_string, CONTINUE);
				return(ERROR);
			}
		} else {
			input_error++;
			sprintf(error_string,"Time series is unreadable: %s", errorString);
			error_msg(error_string, CONTINUE);
			return(ERROR);
		}
	}
	return(OK);

}
