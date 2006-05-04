/* main.c */
#ifdef PHREEQC_IDENT
static char const svnid[] = "$Id$";
#endif
int clean_up(void);
int reset_transient_data(void);

/* accumulate.c */
int accumulate(void);
int check_face(struct bc *bc_ptr, struct index_range *range_ptr);
int coord_to_cell(double x1, double *coord, int count_coord, int *i1);
int coords_to_range(double x1, double x2, double *coord, int count_coord, double eps, int uniform,
		    int *i1, int *i2);
int coords_to_elt_range(double x1, double x2, double *coord, int count_coord, double eps, int uniform,
		    int *i1, int *i2);
int coord_to_cell(double x1, double *coord, int count_coord, int *i1);
int distribute_property_to_cells(struct index_range *range_ptr, 
				 struct property *mask,
				 struct property *property_ptr,
				 size_t offset, size_t offset_defined,
				 property_type p_type,
				 int match_bc_type,
				 int face,
				 int bc_type);
int distribute_type_to_cells(struct index_range *range_ptr, 
			     struct property *mask,
			     int integer_value,
			     size_t offset,
			     int match_bc_type, int face, int bc_type);
int distribute_property_to_elements(struct index_range *range_ptr, 
				 struct property *mask,
				 struct property *property_ptr,
				 size_t offset, size_t offset_defined,
				    int integer);
int double_compare (const void *ptr1, const void *ptr2);
int get_double_property_value(struct cell *cell_ptr, struct property *property_ptr, 
		       int node_sequence, double *value);
int get_integer_property_value_mix(struct cell *cell_ptr, struct property *property_ptr, 
				   int node_sequence, struct mix *mix_ptr);
int get_integer_property_value(struct cell *cell_ptr, struct property *property_ptr, 
			       int node_sequence, double *value, int *integer_value);
int get_property_value_element(struct cell *cell_ptr, struct property *property_ptr, 
		       int node_sequence, double *value, int *integer_value);
int ijk_to_n(int i, int j, int k);
struct index_range *zone_to_range(struct zone *zone_ptr);
struct index_range *zone_to_elt_range(struct zone *zone_ptr);
int int_compare (const void *ptr1, const void *ptr2);
int setup_bc(void);
int setup_chem_ic(void);
int setup_head_ic(void);
int setup_media(void);
int setup_print_locations(struct print_zones_struct *print_zones_struct_ptr, size_t offset1, size_t offset2);
int snap_out_to_range(double x1, double x2, double *coord, int count_coord, int uniform,
		    int *i1, int *i2);
struct index_range *vertex_to_range(gpc_vertex *v, int count_points);
int which_cell(double x1, double y1, double z1, int *i1, int *j1, int *k1);

/* check.c */
int check_properties(void);
int check_cells(void);
int check_dimensions(void);
int check_elements(void);
int check_hst_units(void);
int check_leaky_for_face(int i, int j);
int check_time_data(void);
int check_ss_time_units(struct time *time_ptr, char *errstr);
int check_time_units(struct time *time_ptr, int required, char *errstr);
int check_time_series(struct time_series *ts_ptr, int start_at_zero);
int check_time_series_data(void);
int ijk_to_n_no_error(int i, int j, int k);
int set_active_cells(void);

/* read.c */
int read_file_doubles(char *next_char, double **d, int *count_d, int *count_alloc);
int read_input(void);
int read_lines_times(char *next_char, struct time **times, int *count_times, const char **opt_list, int count_opt_list, int *opt);
struct property *read_property(char *ptr, const char **opt_list, int count_opt_list, int *opt, int delimited, int allow_restart);
int get_option (const char **opt_list, int count_opt_list, char **next_char);

/* rivers */
double PolygonArea(gpc_vertex *polygon, int N);
double angle_between_segments(gpc_vertex p0, gpc_vertex p1, gpc_vertex p2);
double angle_of_segment(gpc_vertex p0, gpc_vertex p1);
int bisector_points(gpc_vertex p0, gpc_vertex p1, gpc_vertex p2, River_Point *r_ptr);
int trapezoid_points(gpc_vertex p0, gpc_vertex p1, River_Point *r_ptr0, double width1);
int build_rivers(void);
int check_quad(gpc_vertex *v);
double gpc_polygon_area(gpc_polygon *poly);
gpc_polygon *gpc_polygon_duplicate(gpc_polygon *in_poly);
gpc_polygon *vertex_to_poly(gpc_vertex *v, int n);
void gpc_polygon_write(gpc_polygon *p);
int interpolate(River_Polygon *river_polygon_ptr);
double river_distance(River_Point *river_ptr1, River_Point *river_ptr2);
int setup_rivers(void);
int tidy_rivers(void);
int update_rivers(void);
void    Centroid3( gpc_vertex p1, gpc_vertex p2, gpc_vertex p3, gpc_vertex *c );
void line_seg_point_near_3d ( double x1, double y1, double z1, 
			      double x2, double y2, double z2, double x, double y, double z,
			      double *xn, double *yn, double *zn, double *dist, double *t );

/* structures.c */
struct bc *bc_alloc(void);
int bc_free(struct bc *bc_ptr);
int bc_init(struct bc *bc_ptr);
struct cell *cell_alloc(void);
int cell_free(struct cell *cell_ptr);
int cell_init(struct cell *cell_ptr);
struct chem_ic *chem_ic_alloc(void);
int chem_ic_free(struct chem_ic *chem_ic_ptr);
int chem_ic_init(struct chem_ic *chem_ic_ptr);
int copy_time (struct time *time_source, struct time *time_destination);
struct head_ic *head_ic_alloc(void);
int head_ic_free(struct head_ic *head_ic_ptr);
int head_ic_init(struct head_ic *head_ic_ptr);
struct grid_elt *grid_elt_alloc(void);
int grid_elt_free(struct grid_elt *grid_elt_ptr);
int grid_elt_init(struct grid_elt *grid_elt_ptr);
int mix_init (struct mix *mix_ptr);
struct property *property_alloc(void);
int property_free(struct property *property_ptr);
int river_free (River *river_ptr);
River *river_search (int n_user, int *n);
int well_free (Well *well_ptr);
Well *well_search (int n_user, int *n);
int well_interval_compare (const void *ptr1, const void *ptr2);
struct zone *zone_alloc(void);
int zone_check(struct zone *zone_ptr);
int print_zone_struct_init (struct print_zones_struct *print_zones_struct_ptr);
int print_zone_struct_free (struct print_zones_struct *print_zones_struct_ptr);

/* time.c */
int accumulate_time_series(struct time_series *ts_ptr);
int collate_simulation_periods(void);
int get_current_property_position(struct time_series *ts_ptr, double cur_time, struct property_time **pt_ptr);
struct print_frequency *print_frequency_alloc (void);
int print_frequency_compare (const void *ptr1, const void *ptr2);
int print_frequency_init (struct print_frequency *print_frequency_ptr);
struct property_time *property_time_alloc (void);
int property_time_compare (const void *ptr1, const void *ptr2);
int property_time_read(char *next_char, struct property_time **property_time_ptr, const char **opt_list, int count_opt_list, int *opt);
int read_lines_times(char *next_char, struct time **times, int *count_times, const char **opt_list, int count_opt_list, int *opt);
int read_line_times(char *ptr, struct time **times, int *count_times);
struct property *read_property_limited(char *ptr);

/* time structure */
struct time *time_alloc();
int time_compare (const void *ptr1, const void *ptr2);
int time_copy(struct time *source, struct time *target);
int time_free(struct time *time_ptr);
int times_free(struct time *time_ptr, int count);
int time_init(struct time *time_ptr);

/* time_series */
int time_series_add (struct time_series *time_series_ptr, struct property_time *property_time_ptr);
struct time_series * time_series_alloc (void);
struct property_time *time_series_alloc_property_time (struct time_series *time_series_ptr);
int time_series_realloc (struct time_series *time_series_ptr);
struct time_series * time_series_free (struct time_series *ts_ptr);
struct time_series * time_series_read_property (char *ptr, const char **opt_list, int count_opt_list, int *opt);
int time_series_sort (struct time_series *time_series_ptr);
int time_series_init (struct time_series *ts_ptr);

/* utilities.c */
int backspace (FILE *file, int spaces);
int convert_to_si (char *unit, double *conversion);
int units_conversion(char *input, char *target, double *conversion, int report_error);
int copy_token (char *token_ptr, char **ptr, int *length);
int dup_print(const char *ptr, int emphasis);
int equal (double a, double b, double eps);
int error_msg (const char *err_str, const int stop);
int free_check_null(void *ptr);
int islegit(const char c);
void malloc_error (void);
int print_centered(const char *string);
int replace(const char *str1, const char *str2, char *str);
void squeeze_white(char *s_l);
int status (int count);
void str_tolower(char *str);
void str_toupper(char *str);
int strcmp_nocase(const char *str1, const char *str2);
int strcmp_nocase_arg1(const char *str1, const char *str2);
char * string_duplicate (const char *token);
int vector_print(double *d, double scalar, int n, FILE *file);
int warning_msg (const char *err_str);

/* wells.c */

int build_wells(void);
int setup_wells(void);
int tidy_wells(void);
int update_wells(void);

/* write.c */

int write_hst(void);
int write_thru(int thru);
