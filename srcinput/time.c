#define EXTERNAL extern
#include "hstinpt.h"
#include <stddef.h>
#define OPTION_EOF -1
#define OPTION_KEYWORD -2
#define OPTION_ERROR -3
#define OPTION_DEFAULT -4
#define OPTION_DEFAULT2 -5
static char const svnid[] = "$Id$";

/* ---------------------------------------------------------------------- */
struct time_series *
time_series_read_property(char *ptr, const char **opt_list,
						  int count_opt_list, int *opt)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads time series data as a series of time, property
 *
 *      Arguments:
 *         ptr    entry: points to line to read from
 *            
 *      Returns:
 *         pointer to time_series structure
 */

	char token[MAX_LENGTH];
	int l;
	struct time_series *ts_ptr;
	struct property_time *property_time_ptr;
	char *next_char, *ptr1;

	ts_ptr = time_series_alloc();
	next_char = ptr;
	ptr1 = ptr;

	/* read any remaining data on option line */
	if (copy_token(token, &ptr1, &l) != EMPTY)
	{

		if (property_time_read
			(next_char, &property_time_ptr, opt_list, count_opt_list,
			 opt) == ERROR)
		{
			time_series_free(ts_ptr);
			free_check_null(ts_ptr);
			return NULL;
		}
		if (time_series_add(ts_ptr, property_time_ptr) == ERROR)
		{
			time_series_free(ts_ptr);
			free_check_null(ts_ptr);
			return NULL;
		}
	}
	else
	{
		*opt = get_option(opt_list, count_opt_list, &next_char);
	}
	for (;;)
	{
		if (*opt == OPTION_KEYWORD || *opt == OPTION_EOF
			|| *opt == OPTION_ERROR)
		{
			break;
		}
		else if (*opt >= 0)
		{
			break;
		}
		next_char = line;
		if (property_time_read
			(next_char, &property_time_ptr, opt_list, count_opt_list,
			 opt) == ERROR)
		{
			time_series_free(ts_ptr);
			free_check_null(ts_ptr);
			return NULL;
		}
		if (time_series_add(ts_ptr, property_time_ptr) == ERROR)
		{
			time_series_free(ts_ptr);
			free_check_null(ts_ptr);
			return NULL;
		}
	}
	return (ts_ptr);
}

/* ---------------------------------------------------------------------- */
int
time_series_add(struct time_series *time_series_ptr,
				struct property_time *property_time_ptr)
/* ---------------------------------------------------------------------- */
{
	if (time_series_realloc(time_series_ptr) == ERROR)
		return (ERROR);
	time_series_ptr->properties[time_series_ptr->count_properties - 1] =
		property_time_ptr;
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
time_series_sort(struct time_series *time_series_ptr)
/* ---------------------------------------------------------------------- */
{
/*
 *   Compare times in time series 
 */
	if (time_series_ptr->count_properties > 1)
	{
		qsort(time_series_ptr->properties,
			  (size_t) time_series_ptr->count_properties,
			  (size_t) sizeof(struct property_time *), property_time_compare);
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
struct property_time *
property_time_alloc(void)
/* ---------------------------------------------------------------------- */
{
	struct property_time *property_time_ptr;

	property_time_ptr =
		(struct property_time *) malloc(sizeof(struct property_time));
	if (property_time_ptr == NULL)
		malloc_error();
	property_time_ptr->property = NULL;
	time_init(&property_time_ptr->time);
	time_init(&property_time_ptr->time_value);
	return (property_time_ptr);
}

/* ---------------------------------------------------------------------- */
int
property_time_compare(const void *ptr1, const void *ptr2)
/* ---------------------------------------------------------------------- */
{
	const struct property_time **property_time_ptr1, **property_time_ptr2;
	property_time_ptr1 = (const struct property_time **) ptr1;
	property_time_ptr2 = (const struct property_time **) ptr2;
	if ((*property_time_ptr1)->time.value *
		(*property_time_ptr1)->time.input_to_user >
		(*property_time_ptr2)->time.value *
		(*property_time_ptr2)->time.input_to_user)
	{
		return 1;
	}
	else if ((*property_time_ptr1)->time.value *
			 (*property_time_ptr1)->time.input_to_user <
			 (*property_time_ptr2)->time.value *
			 (*property_time_ptr2)->time.input_to_user)
	{
		return -1;
	}
	return 0;
}

/* ---------------------------------------------------------------------- */
struct time_series *
time_series_alloc(void)
/* ---------------------------------------------------------------------- */
{
	struct time_series *ts_ptr;

	ts_ptr = (struct time_series *) malloc(sizeof(struct time_series));
	if (ts_ptr == NULL)
		malloc_error();
	ts_ptr->count_properties = 0;
	ts_ptr->properties = NULL;
	return ts_ptr;

}

/* ---------------------------------------------------------------------- */
struct property_time *
time_series_alloc_property_time(struct time_series *time_series_ptr)
/* ---------------------------------------------------------------------- */
{
	struct property_time *property_time_ptr;
	if (time_series_realloc(time_series_ptr) == ERROR)
		return (NULL);
	property_time_ptr = property_time_alloc();
	time_series_ptr->properties[time_series_ptr->count_properties - 1] =
		property_time_ptr;
	return (property_time_ptr);

}

/* ---------------------------------------------------------------------- */
int
time_series_realloc(struct time_series *time_series_ptr)
/* ---------------------------------------------------------------------- */
{
	if (time_series_ptr == NULL)
		return (ERROR);
	time_series_ptr->count_properties++;
	time_series_ptr->properties =
		(struct property_time **) realloc(time_series_ptr->properties,
										  (size_t) time_series_ptr->
										  count_properties *
										  sizeof(struct property_time *));
	if (time_series_ptr->properties == NULL)
		malloc_error();

	return (OK);

}

/* ---------------------------------------------------------------------- */
int
time_series_init(struct time_series *ts_ptr)
/* ---------------------------------------------------------------------- */
{
	if (ts_ptr == NULL)
		return (ERROR);
	ts_ptr->count_properties = 0;
	ts_ptr->properties = NULL;
	return (OK);
}

/* ---------------------------------------------------------------------- */
struct time_series *
time_series_free(struct time_series *ts_ptr)
/* ---------------------------------------------------------------------- */
{
	int i;

	if (ts_ptr == NULL)
		return NULL;
	for (i = 0; i < ts_ptr->count_properties; i++)
	{
		property_free(ts_ptr->properties[i]->property);
		time_free(&ts_ptr->properties[i]->time);
		time_free(&ts_ptr->properties[i]->time_value);
		free_check_null(ts_ptr->properties[i]);
	};
	free_check_null(ts_ptr->properties);
	return NULL;
}

/* ---------------------------------------------------------------------- */
int
property_time_read(char *next_char, struct property_time **property_time_ptr,
				   const char **opt_list, int count_opt_list, int *opt)
/* ---------------------------------------------------------------------- */
{
	int i, j, l, time_unit;
	double f;
	char token[MAX_LENGTH];
	char *next_char_test;

	j = copy_token(token, &next_char, &l);
	while (j == EMPTY)
	{
		*opt = get_option(opt_list, count_opt_list, &next_char);
		if (*opt == OPTION_KEYWORD || *opt == OPTION_EOF
			|| *opt == OPTION_ERROR || *opt >= 0)
		{
			input_error++;
			error_msg("Reading property time series", CONTINUE);
			*property_time_ptr = NULL;
			return (ERROR);
		}
		j = copy_token(token, &next_char, &l);
	}
	if (j != DIGIT)
	{
		input_error++;
		error_msg("Reading property for time series", CONTINUE);
		*property_time_ptr = NULL;
		*opt = get_option(opt_list, count_opt_list, &next_char);
		return (ERROR);
	}
	*property_time_ptr = property_time_alloc();
	sscanf(token, "%lf", &(*property_time_ptr)->time.value);
	/*
	 *  Read units for time, if available
	 */
	next_char_test = next_char;
	j = copy_token(token, &next_char_test, &l);
	while (j == EMPTY)
	{
		*opt = get_option(opt_list, count_opt_list, &next_char);
		if (*opt == OPTION_KEYWORD || *opt == OPTION_EOF
			|| *opt == OPTION_ERROR || *opt >= 0)
		{
			input_error++;
			error_msg("Reading property time series", CONTINUE);
			*property_time_ptr = NULL;
			return (ERROR);
		}
		next_char_test = next_char;
		j = copy_token(token, &next_char, &l);
	}
	time_unit = FALSE;
	if (j == UPPER || j == LOWER)
	{
		if (strcmp_nocase(token, "y") == 0)
		{
			/* 
			 * interpreting as interpolation on Y axis,
			 * should be exactly 4 values following Y
			 */
			for (i = 0; i < 4; i++)
			{
				if (copy_token(token, &next_char_test, &l) != DIGIT)
				{
					time_unit = TRUE;
					break;
				}
			}
			if (time_unit == FALSE)
			{
				if (copy_token(token, &next_char_test, &l) != EMPTY)
				{
					time_unit = TRUE;
				}
			}
		}
		else if (units_conversion(token, "s", &f, FALSE) == TRUE)
		{
			time_unit = TRUE;
		}
	}
	/*
	 *  If time unit, read it
	 */
	if (time_unit == TRUE)
	{
		j = copy_token(token, &next_char, &l);
		str_tolower(token);
		(*property_time_ptr)->time.input = string_duplicate(token);
		(*property_time_ptr)->time.type = UNITS;
	}
	(*property_time_ptr)->property =
		read_property(next_char, opt_list, count_opt_list, opt, TRUE, FALSE);
	/*(*property_time_ptr)->property = read_property(next_char); */
	if ((*property_time_ptr)->property == NULL)
	{
		input_error++;
		error_msg("Reading property for time series", CONTINUE);
	}

	return (OK);
}

/* ---------------------------------------------------------------------- */
struct time *
time_alloc()
/* ---------------------------------------------------------------------- */
{
	struct time *time_ptr;
	time_ptr = (struct time *) malloc(sizeof(struct time));
	if (time_ptr == NULL)
		malloc_error();
	time_init(time_ptr);
	return (time_ptr);
}

/* ---------------------------------------------------------------------- */
int
time_compare(const void *ptr1, const void *ptr2)
/* ---------------------------------------------------------------------- */
{
	const struct time *time_ptr1, *time_ptr2;
	time_ptr1 = (const struct time *) ptr1;
	time_ptr2 = (const struct time *) ptr2;
	if (time_ptr1->value * time_ptr1->input_to_user <
		time_ptr2->value * time_ptr2->input_to_user)
	{
		return -1;
	}
	else if (time_ptr1->value * time_ptr1->input_to_user >
			 time_ptr2->value * time_ptr2->input_to_user)
	{
		return 1;
	}
	return 0;
}

/* ---------------------------------------------------------------------- */
int
time_copy(struct time *source, struct time *target)
/* ---------------------------------------------------------------------- */
{
	if (source == NULL || target == NULL)
		return (ERROR);
	time_free(target);
	target->type = source->type;
	target->value = source->value;
	target->value_defined = source->value_defined;
	target->input = NULL;
	if (source->input != NULL)
		target->input = string_duplicate(source->input);
	target->input_to_si = source->input_to_si;
	target->input_to_user = source->input_to_user;

	return (OK);
}

/* ---------------------------------------------------------------------- */
int
time_free(struct time *time_ptr)
/* ---------------------------------------------------------------------- */
{
	free_check_null(time_ptr->input);
	time_ptr->input = NULL;
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
times_free(struct time *time_ptr, int count)
/* ---------------------------------------------------------------------- */
{
	int i;
	for (i = 0; i < count; i++)
	{
		free_check_null(time_ptr[i].input);
		time_ptr[i].input = NULL;
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
time_init(struct time *time_ptr)
/* ---------------------------------------------------------------------- */
{
	time_ptr->type = UNDEFINED;
	time_ptr->value = 0;
	time_ptr->value_defined = FALSE;
	time_ptr->input = NULL;
	time_ptr->input_to_si = 1;
	time_ptr->input_to_user = 1;

	return (OK);
}

/* ---------------------------------------------------------------------- */
int
collate_simulation_periods(void)
/* ---------------------------------------------------------------------- */
{
	/* build list of all times from simulation periods */
	int i, j, k;

	/*
	 *  End of simulation periods, except last
	 */
	/*
	 *  Boundary conditions
	 */
	for (i = 0; i < count_bc; i++)
	{
		accumulate_time_series(bc[i]->bc_head);
		accumulate_time_series(bc[i]->bc_flux);
		accumulate_time_series(bc[i]->bc_solution);
	}
	for (i = 0; i < count_rivers; i++)
	{
		for (j = 0; j < rivers[i].count_points; j++)
		{
			accumulate_time_series(rivers[i].points[j].solution);
			accumulate_time_series(rivers[i].points[j].head);
		}
	}
	for (i = 0; i < count_wells; i++)
	{
		accumulate_time_series(wells[i].solution);
		accumulate_time_series(wells[i].q);
	}
	accumulate_time_series(&time_step);
	/* print frequencies */
	accumulate_time_series(&print_velocity);
	accumulate_time_series(&print_hdf_velocity);
	accumulate_time_series(&print_xyz_velocity);
	accumulate_time_series(&print_head);
	accumulate_time_series(&print_hdf_head);
	accumulate_time_series(&print_xyz_head);
	accumulate_time_series(&print_force_chem);
	accumulate_time_series(&print_hdf_chem);
	accumulate_time_series(&print_xyz_chem);
	accumulate_time_series(&print_comp);
	accumulate_time_series(&print_xyz_comp);
	accumulate_time_series(&print_wells);
	accumulate_time_series(&print_xyz_wells);
	accumulate_time_series(&print_statistics);
	accumulate_time_series(&print_flow_balance);
	accumulate_time_series(&print_bc_flow);
	accumulate_time_series(&print_conductances);
	accumulate_time_series(&print_bc);
	accumulate_time_series(&print_restart);
	accumulate_time_series(&print_zone_budget);
	accumulate_time_series(&print_zone_budget_tsv);

	/*
	 *  Add in all but last time_end
	 */
	simulation_periods =
		(double *) realloc(simulation_periods,
						   (size_t) (count_simulation_periods +
									 count_time_end - 1) * sizeof(double));
	if (simulation_periods == NULL)
		malloc_error();
	for (i = 0; i < count_time_end - 1; i++)
	{
		simulation_periods[count_simulation_periods++] =
			time_end[i].value * time_end[i].input_to_user;
	}
	qsort(simulation_periods, (size_t) count_simulation_periods,
		  sizeof(double), double_compare);
	/*
	 *  Keep unique time values
	 */
	k = 0;
	for (i = 1; i < count_simulation_periods; i++)
	{
		if (simulation_periods[i] >=
			time_end[count_time_end - 1].value * time_end[count_time_end -
														  1].input_to_user)
		{
			warning_msg
				("Final end time is less than or equal to some time series data.");
			break;
		}
		if (equal(simulation_periods[k], simulation_periods[i], TIME_EPS) ==
			TRUE)
		{
			continue;
		}
		else
		{
			k++;
			simulation_periods[k] = simulation_periods[i];
		}
	}
	count_simulation_periods = k + 1;
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
accumulate_time_series(struct time_series *ts_ptr)
/* ---------------------------------------------------------------------- */
{
	int i, count;

	if (ts_ptr == NULL)
		return (OK);
	count = ts_ptr->count_properties;
	/*
	 *  realloc space
	 */
	simulation_periods =
		(double *) realloc(simulation_periods,
						   (size_t) (count_simulation_periods +
									 count) * sizeof(double));
	if (simulation_periods == NULL)
		malloc_error();
	for (i = 0; i < count; i++)
	{
		simulation_periods[count_simulation_periods++] =
			ts_ptr->properties[i]->time.value *
			ts_ptr->properties[i]->time.input_to_user;
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
get_current_property_position(struct time_series *ts_ptr, double cur_time,
							  struct property_time **pt_ptr)
/* ---------------------------------------------------------------------- */
{
	/* cur_time is in user units */
	int i, count;

	/* *property_ptr = NULL; */
	if (ts_ptr == NULL)
		return (-1);
	count = ts_ptr->count_properties;
	for (i = 0; i < count; i++)
	{
		if (equal
			(cur_time,
			 ts_ptr->properties[i]->time.value *
			 ts_ptr->properties[i]->time.input_to_user, TIME_EPS) == TRUE)
		{
			*pt_ptr = ts_ptr->properties[i];
			return (i);
		}
		if (ts_ptr->properties[i]->time.value *
			ts_ptr->properties[i]->time.input_to_user > cur_time)
			break;
	}
	return (-1);
}

/* ---------------------------------------------------------------------- */
int
read_lines_times(char *next_char, struct time **times, int *count_times,
				 const char **opt_list, int count_opt_list, int *opt)
/* ---------------------------------------------------------------------- */
{
/*
 *      Reads time structures on line starting at next_char
 *      and on succeeding lines. Appends to d.
 *      Stops at KEYWORD, OPTION, and EOF
 *
 *      Input Arguments:
 *         next_char    points to line to read from
 *         times        points to array of time structures, must be malloced
 *         count_times  number of elements in array
 *
 *      Output Arguments:
 *         times            points to array of doubles, may have been
 *                          realloced
 *         count_times      updated number of elements in array
 *
 *      Returns:
 *         KEYWORD
 *         OPTION
 *         EOF
 *         ERROR if any errors reading doubles
 */

	if (read_line_times(next_char, times, count_times) == ERROR)
	{
		return (ERROR);
	}
	for (;;)
	{
		*opt = get_option(opt_list, count_opt_list, &next_char);
		if (*opt == OPTION_KEYWORD || *opt == OPTION_EOF
			|| *opt == OPTION_ERROR)
		{
			break;
		}
		else if (*opt >= 0)
		{
			break;
		}
		next_char = line;
		if (read_line_times(next_char, times, count_times) == ERROR)
		{
			return (ERROR);
		}
	}
	return (OK);
}

/* ---------------------------------------------------------------------- */
int
read_line_times(char *ptr, struct time **times, int *count_times)
/* ---------------------------------------------------------------------- */
{
	int j, l;
	double value;
	char token[MAX_LENGTH];
	char *ptr_save;
/*
 *   Reads a list of double numbers until end of line is reached or 
 *   a double can not be read from a token.
 *
 *      Arguments:
 *         ptr    entry: points to line to read from
 *                exit:  points to next non-double token or end of line
 *
 *         count_doubles exit: number of doubles read
 *
 *      Returns:
 *         pointer to a list of count_doubles doubles.
 */

	ptr_save = ptr;
	while ((j = copy_token(token, &ptr, &l)) != EMPTY)
	{
		if (j == DIGIT)
		{
			if (sscanf(token, "%lf", &value) == 1)
			{
				*count_times = *count_times + 1;
				*times =
					(struct time *) realloc(*times,
											(size_t) (*count_times) *
											sizeof(struct time));
				if (times == NULL)
					malloc_error();
				(*times)[(*count_times) - 1].input = NULL;
				(*times)[(*count_times) - 1].value = value;
				(*times)[(*count_times) - 1].value_defined = TRUE;
				(*times)[(*count_times) - 1].type = UNITS;
				ptr_save = ptr;
			}
			else
			{
				error_msg("How did this happen", STOP);
				ptr = ptr_save;
				break;
			}
		}
		else if ((j == UPPER || j == LOWER) && *count_times > 0)
		{
			(*times)[(*count_times) - 1].input = string_duplicate(token);
			str_tolower(token);
			if (strstr(token, "step") == token)
			{
				(*times)[(*count_times) - 1].type = STEP;
			}
		}
		else
		{
			input_error++;
			error_msg
				("Expected list of times with or without trailing time units",
				 CONTINUE);
			return (ERROR);
		}
	}
	return (OK);
}
