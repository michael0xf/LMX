/* MIT-licensed upstream APIs, namespaced for the LMX collection.
 * Original notices and sources are retained under vendor/. */
#ifndef LMX_STROUD_RULE_H
#define LMX_STROUD_RULE_H
#ifdef __cplusplus
extern "C" {
#endif
double lmx_stroud_ball_f1_nd ( double func ( int n, double x[] ), int n, double center[], 
  double r );
double lmx_stroud_ball_f3_nd ( double func ( int n, double x[] ), int n, double center[], 
  double r );
double lmx_stroud_ball_monomial_nd ( int n, int p[], double r );
double lmx_stroud_ball_unit_07_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_ball_unit_14_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_ball_unit_15_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_ball_unit_f1_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_ball_unit_f3_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_ball_unit_volume_3d (void);
double lmx_stroud_ball_unit_volume_nd ( int n );
double lmx_stroud_ball_volume_3d ( double r );
double lmx_stroud_ball_volume_nd ( int n, double r );
double lmx_stroud_c1_geg_monomial_integral ( double alpha, int expon );
double lmx_stroud_c1_jac_monomial_integral ( double alpha, double beta, int expon );
double lmx_stroud_c1_leg_monomial_integral ( int expon );
double lmx_stroud_circle_annulus ( double func ( double x, double y ), double center[2], 
  double radius1, double radius2, int nr );
double lmx_stroud_circle_annulus_area_2d ( double radius1, double radius2 );
double lmx_stroud_circle_annulus_sector ( double func ( double x, double y ), 
  double center[2], double radius1, double radius2, double theta1, 
  double theta2, int nr );
double lmx_stroud_circle_annulus_sector_area_2d ( double radius1, double radius2, 
  double theta1, double theta2 );
double lmx_stroud_circle_area_2d ( double r );
double lmx_stroud_circle_cap_area_2d ( double r, double h );
double lmx_stroud_circle_cum ( double func ( double x, double y ), double center[2], 
  double radius, int order );
void lmx_stroud_circle_rt_set ( int rule, int nr, int nt, int nc, double ra[], 
  double rw[], double ta[], double tw[], double *cw );
void lmx_stroud_circle_rt_size ( int rule, int *nr, int *nt, int *nc );
double lmx_stroud_circle_rt_sum ( double func ( double x, double y ), double center[2], 
  double radius, int nr, double ra[], double rw[], int nt, double ta[], 
  double tw[], double zw );
double lmx_stroud_circle_sector ( double func ( double x, double y ), double center[2], 
  double radius, double theta1, double theta2, int nr );
double lmx_stroud_circle_sector_area_2d ( double r, double theta1, double theta2 );
double lmx_stroud_circle_triangle_area_2d ( double r, double theta1, double theta2 );
void lmx_stroud_circle_xy_set ( int rule, int order, double xtab[], double ytab[], 
  double weight[] );
int lmx_stroud_circle_xy_size ( int rule );
double lmx_stroud_circle_xy_sum ( double func ( double x, double y ), double center[2], 
  double r, int order, double xtab[], double ytab[], double weight[] );
void lmx_stroud_cn_geg_00_1 ( int n, double alpha, int o, double x[], double w[] );
int lmx_stroud_cn_geg_00_1_size ( int n, double alpha );
void lmx_stroud_cn_geg_01_1 ( int n, double alpha, int o, double x[], double w[] );
int lmx_stroud_cn_geg_01_1_size ( int n, double alpha );
void lmx_stroud_cn_geg_02_xiu ( int n, double alpha, int o, double x[], double w[] );
int lmx_stroud_cn_geg_02_xiu_size ( int n, double alpha );
void lmx_stroud_cn_geg_03_xiu ( int n, double alpha, int o, double x[], double w[] );
int lmx_stroud_cn_geg_03_xiu_size ( int n, double alpha );
double lmx_stroud_cn_geg_monomial_integral ( int n, double alpha, int expon[] );
void lmx_stroud_cn_jac_00_1 ( int n, double alpha, double beta, int o, double x[], 
  double w[] );
int lmx_stroud_cn_jac_00_1_size ( int n, double alpha, double beta );
void lmx_stroud_cn_jac_01_1 ( int n, double alpha, double beta, int o, double x[], 
  double w[] );
int lmx_stroud_cn_jac_01_1_size ( int n, double alpha, double beta );
double lmx_stroud_cn_jac_monomial_integral ( int n, double alpha, double beta, 
  int expon[] );
void lmx_stroud_cn_jac_02_xiu ( int n, double alpha, double beta, int o, double x[], 
  double w[] );
int lmx_stroud_cn_jac_02_xiu_size ( int n, double alpha, double beta );
void lmx_stroud_cn_leg_01_1 ( int n, int o, double x[], double w[] );
int lmx_stroud_cn_leg_01_1_size ( int n );
void lmx_stroud_cn_leg_02_xiu ( int n, int o, double x[], double w[] );
int lmx_stroud_cn_leg_02_xiu_size ( int n );
void lmx_stroud_cn_leg_03_1 ( int n, int o, double x[], double w[] );
int lmx_stroud_cn_leg_03_1_size ( int n );
void lmx_stroud_cn_leg_03_xiu ( int n, int o, double x[], double w[] );
int lmx_stroud_cn_leg_03_xiu_size ( int n );
void lmx_stroud_cn_leg_05_1 ( int n, int option, int o, double x[], double w[] );
int lmx_stroud_cn_leg_05_1_size ( int n );
void lmx_stroud_cn_leg_05_2 ( int n, int o, double x[], double w[] );
int lmx_stroud_cn_leg_05_2_size ( int n );
double lmx_stroud_cn_leg_monomial_integral ( int n, int expon[] );
double lmx_stroud_cone_unit_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_cone_volume_3d ( double r, double h );
double lmx_stroud_cube_shell_nd ( double func ( int n, double x[] ), int n, double r1, 
  double r2 );
double lmx_stroud_cube_shell_volume_nd ( int n, double r1, double r2 );
double lmx_stroud_cube_unit_3d ( double func ( double x, double y, double z ) );
void lmx_stroud_cube_unit_nd ( double func ( int n, double x[] ), double qa[], 
  double qb[], int n, int k );
double lmx_stroud_cube_unit_volume_nd ( int n );
double lmx_stroud_ellipse_area_2d ( double r1, double r2 );
double lmx_stroud_ellipse_circumference_2d ( double r1, double r2 );
double lmx_stroud_ellipse_eccentricity_2d ( double r1, double r2 );
double lmx_stroud_ellipsoid_volume_3d ( double r1, double r2, double r3 );
int lmx_stroud_en_r2_01_1_size ( int n );
void lmx_stroud_en_r2_01_1 ( int n, int o, double x[], double w[] );
int lmx_stroud_en_r2_02_xiu_size ( int n );
void lmx_stroud_en_r2_02_xiu ( int n, int o, double x[], double w[] );
int lmx_stroud_en_r2_03_1_size ( int n );
void lmx_stroud_en_r2_03_1 ( int n, int o, double x[], double w[] );
int lmx_stroud_en_r2_03_2_size ( int n );
void lmx_stroud_en_r2_03_2 ( int n, int o, double x[], double w[] );
void lmx_stroud_en_r2_03_xiu ( int n, int o, double x[], double w[] );
int lmx_stroud_en_r2_03_xiu_size ( int n );
int lmx_stroud_en_r2_05_1_size ( int n );
void lmx_stroud_en_r2_05_1 ( int n, int option, int o, double x[], double w[] );
int lmx_stroud_en_r2_05_2_size ( int n );
void lmx_stroud_en_r2_05_2 ( int n, int o, double x[], double w[] );
int lmx_stroud_en_r2_05_3_size ( int n );
void lmx_stroud_en_r2_05_3 ( int n, int o, double x[], double w[] );
int lmx_stroud_en_r2_05_4_size ( int n );
void lmx_stroud_en_r2_05_4 ( int n, int o, double x[], double w[] );
int lmx_stroud_en_r2_05_5_size ( int n );
void lmx_stroud_en_r2_05_5 ( int n, int o, double x[], double w[] );
int lmx_stroud_en_r2_05_6_size ( int n );
void lmx_stroud_en_r2_05_6 ( int n, int o, double x[], double w[] );
int lmx_stroud_en_r2_07_1_size ( int n );
void lmx_stroud_en_r2_07_1 ( int n, int option, int o, double x[], double w[] );
int lmx_stroud_en_r2_07_2_size ( int n );
void lmx_stroud_en_r2_07_2 ( int n, int o, double x[], double w[] );
int lmx_stroud_en_r2_07_3_size ( int n );
void lmx_stroud_en_r2_07_3 ( int n, int option, int o, double x[], double w[] );
int lmx_stroud_en_r2_09_1_size ( int n );
void lmx_stroud_en_r2_09_1 ( int n, int option, int o, double x[], double w[] );
int lmx_stroud_en_r2_11_1_size ( int n );
void lmx_stroud_en_r2_11_1 ( int n, int option, int o, double x[], double w[] );
double lmx_stroud_en_r2_monomial_integral ( int n, int alpha[] );
double lmx_stroud_ep1_glg_monomial_integral ( int expon, double alpha );
double lmx_stroud_ep1_lag_monomial_integral ( int expon );
void lmx_stroud_epn_glg_00_1 ( int n, double alpha, int o, double x[], double w[] );
int lmx_stroud_epn_glg_00_1_size ( int n, double alpha );
void lmx_stroud_epn_glg_01_1 ( int n, double alpha, int o, double x[], double w[] );
int lmx_stroud_epn_glg_01_1_size ( int n, double alpha );
void lmx_stroud_epn_glg_02_xiu ( int n, double alpha, int o, double x[], double w[] );
int lmx_stroud_epn_glg_02_xiu_size ( int n, double alpha );
double lmx_stroud_epn_glg_monomial_integral ( int n, int expon[], double alpha );
void lmx_stroud_epn_lag_00_1 ( int n, int o, double x[], double w[] );
int lmx_stroud_epn_lag_00_1_size ( int n );
void lmx_stroud_epn_lag_01_1 ( int n, int o, double x[], double w[] );
int lmx_stroud_epn_lag_01_1_size ( int n );
void lmx_stroud_epn_lag_02_xiu ( int n, int o, double x[], double w[] );
int lmx_stroud_epn_lag_02_xiu_size ( int n );
double lmx_stroud_epn_lag_monomial_integral ( int n, int expon[] );
void lmx_stroud_gw_02_xiu ( int n, int o, double gamma0, double delta0, double c1, 
  double volume_1d, double x[], double w[] );
int lmx_stroud_gw_02_xiu_size ( int n );
double lmx_stroud_hexagon_area_2d ( double r );
double lmx_stroud_hexagon_sum ( double func ( double x, double y ), double center[2], 
  double r, int order, double xtab[], double ytab[], double weight[] );
double lmx_stroud_hexagon_unit_area_2d (void);
void lmx_stroud_hexagon_unit_set ( int rule, int order, double xtab[], double ytab[], 
  double weight[] );
int lmx_stroud_hexagon_unit_size ( int rule );
int lmx_stroud_i4_factorial ( int n );
int lmx_stroud_i4_factorial2 ( int n );
int lmx_stroud_i4_max ( int i1, int i2 );
int lmx_stroud_i4_min ( int i1, int i2 );
int lmx_stroud_i4_power ( int i, int j );
int lmx_stroud_i4vec_sum ( int n, int a[] );
void lmx_stroud_i4vec_zero ( int n, int a[] );
void lmx_stroud_ksub_next2 ( int n, int k, int a[], int *in, int *iout );
void lmx_stroud_legendre_set ( int order, double xtab[], double weight[] );
void lmx_stroud_legendre_set_x1 ( int order, double xtab[], double weight[] );
void lmx_stroud_legendre_set_x2 ( int order, double xtab[], double weight[] );
double lmx_stroud_lens_half_2d ( double func ( double x, double y ), double center[2], 
  double r, double theta1, double theta2, int order );
double lmx_stroud_lens_half_area_2d ( double r, double theta1, double theta2 );
double lmx_stroud_lens_half_h_area_2d ( double r, double h );
double lmx_stroud_lens_half_w_area_2d ( double r, double w );
double *lmx_stroud_monomial_value ( int dim_num, int point_num, double x[], int expon[] );
double lmx_stroud_octahedron_unit_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_octahedron_unit_volume_nd ( int n );
double lmx_stroud_parallelipiped_volume_3d ( double x[4], double y[4], double z[4] );
double lmx_stroud_parallelipiped_volume_nd ( int n, double v[] );
double lmx_stroud_polygon_1_2d ( int n, double x[], double y[] );
double lmx_stroud_polygon_x_2d ( int n, double x[], double y[] );
double lmx_stroud_polygon_xx_2d ( int n, double x[], double y[] );
double lmx_stroud_polygon_xy_2d ( int n, double x[], double y[] );
double lmx_stroud_polygon_y_2d ( int n, double x[], double y[] );
double lmx_stroud_polygon_yy_2d ( int n, double x[], double y[] );
double lmx_stroud_pyramid_unit_o01_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_pyramid_unit_o05_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_pyramid_unit_o06_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_pyramid_unit_o08_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_pyramid_unit_o08b_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_pyramid_unit_o09_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_pyramid_unit_o13_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_pyramid_unit_o18_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_pyramid_unit_o27_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_pyramid_unit_o48_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_pyramid_unit_monomial_3d ( int alpha, int beta, int gamma );
double lmx_stroud_pyramid_unit_volume_3d (void);
double lmx_stroud_pyramid_volume_3d ( double r, double h );
double lmx_stroud_qmdpt ( double func ( int n, double x[] ), int n, int nsub );
double lmx_stroud_qmult_1d ( double func ( double x ), double a, double b );
double lmx_stroud_qmult_2d ( double func ( double x, double y ), double a, double b, 
  double fup ( double x ), double flo ( double x ) );
double lmx_stroud_qmult_3d ( double func ( double x, double y, double z ), double a, 
  double b, double fup1 ( double x ), double flo1 ( double x ), 
  double fup2 ( double x, double y ), double flo2 ( double x, double y ) );
double lmx_stroud_r8_asin ( double s );
double lmx_stroud_r8_choose ( int n, int k );
double lmx_stroud_r8_factorial ( int n );
double lmx_stroud_r8_hyper_2f1 ( double a, double b, double c, double x );
double lmx_stroud_r8_mop ( int i );
double lmx_stroud_r8_psi ( double xx );
void lmx_stroud_r8_swap ( double *x, double *y );
void lmx_stroud_r8_swap3 ( double *x, double *y, double *z );
double lmx_stroud_r8_uniform_01 ( int *seed );
double lmx_stroud_r8ge_det ( int n, double a_lu[], int pivot[] );
int lmx_stroud_r8ge_fa ( int n, double a[], int pivot[] );
double lmx_stroud_r8vec_dot_product ( int n, double a1[], double a2[] );
double lmx_stroud_r8vec_even_select ( int n, double xlo, double xhi, int ival );
int lmx_stroud_r8vec_mirror_next ( int n, double a[] );
void lmx_stroud_r8vec_print ( int n, double a[], char *title );
void lmx_stroud_r8vec_zero ( int n, double a[] );
double lmx_stroud_rectangle_3d ( double func ( double x, double y, double z ),
  double a[3], double b[3] );
double lmx_stroud_rectangle_sub_2d ( double func ( double x, double y ), double xval[2], 
  double yval[2], int nsub[2], int order, double xtab[], double ytab[], 
  double weight[] );
void lmx_stroud_rule_adjust ( double a, double b, double c, double d, int order, 
  double x[], double w[] );
int lmx_stroud_s_len_trim ( char *s );
double lmx_stroud_simplex_nd ( double func ( int n, double x[] ), int n, double v[] );
double lmx_stroud_simplex_unit_01_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_simplex_unit_03_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_simplex_unit_05_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_simplex_unit_05_2_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_simplex_unit_volume_nd ( int n );
double lmx_stroud_simplex_volume_nd ( int n, double v[] );
double lmx_stroud_sin_power_int ( double a, double b, int n );
double lmx_stroud_sphere_05_nd ( double func ( int n, double x[] ), int n, double center[], 
  double r );
double lmx_stroud_sphere_07_1_nd ( double func ( int n, double x[] ), int n, 
  double center[], double r );
double lmx_stroud_sphere_area_3d ( double r );
double lmx_stroud_sphere_area_nd ( int n, double r );
double lmx_stroud_sphere_cap_area_2d ( double r, double h );
double lmx_stroud_sphere_cap_area_3d ( double r, double h );
double lmx_stroud_sphere_cap_area_nd ( int dim_num, double r, double h );
double lmx_stroud_sphere_cap_volume_2d ( double r, double h );
double lmx_stroud_sphere_cap_volume_3d ( double r, double h );
double lmx_stroud_sphere_cap_volume_nd ( int dim_num, double r, double h );
double lmx_stroud_sphere_k ( int n );
double lmx_stroud_sphere_monomial_int_nd ( int n, double r, int e[] );
double lmx_stroud_sphere_shell_03_nd ( double func ( int n, double x[] ), int n, 
  double center[], double r1, double r2 );
double lmx_stroud_sphere_shell_volume_nd ( int n, double r1, double r2 );
double lmx_stroud_sphere_unit_03_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_sphere_unit_04_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_sphere_unit_05_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_sphere_unit_07_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_sphere_unit_07_1_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_sphere_unit_07_2_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_sphere_unit_11_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_sphere_unit_11_nd ( double func ( int n, double x[] ), int n );
double lmx_stroud_sphere_unit_14_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_sphere_unit_15_3d ( double func ( double x, double y, double z ) );
double lmx_stroud_sphere_unit_area_3d (void);
double lmx_stroud_sphere_unit_area_nd ( int n );
void lmx_stroud_sphere_unit_area_values ( int *n_data, int *n, double *area );
double lmx_stroud_sphere_unit_monomial_nd ( int n, int p[] );
double lmx_stroud_sphere_unit_volume_nd ( int dim_num );
void lmx_stroud_sphere_unit_volume_values ( int *n_data, int *n, double *volume );
double lmx_stroud_sphere_volume_2d ( double r );
double lmx_stroud_sphere_volume_3d ( double r );
double lmx_stroud_sphere_volume_nd ( int dim_num, double r );
double lmx_stroud_square_sum ( double func ( double x, double y ), double center[2], 
  double r, int order, double xtab[], double ytab[], double weight[] );
void lmx_stroud_square_unit_set ( int rule, int order, double xtab[], double ytab[], 
  double weight[] );
int lmx_stroud_square_unit_size ( int rule );
double lmx_stroud_square_unit_sum ( double func ( double x, double y ), int order, 
  double xtab[], double ytab[], double weight[] );
void lmx_stroud_subset_gray_next ( int n, int a[], int *more, int *ncard, int *iadd );
double lmx_stroud_tetra_07 ( double func ( double x, double y, double z ), double x[], 
  double y[], double z[] );
double lmx_stroud_tetra_sum ( double func ( double x, double y, double z ), double x[4], 
  double y[4], double z[4], int order, double xtab[], double ytab[], 
  double ztab[], double weight[] );
double lmx_stroud_tetra_tproduct ( double func ( double x, double y, double z ), 
  int order, double x[4], double y[4], double z[4] );
int lmx_stroud_tetra_unit_size ( int rule );
void lmx_stroud_tetra_unit_set ( int rule, int order, double xtab[], double ytab[], 
  double ztab[], double weight[] );
double lmx_stroud_tetra_unit_sum ( double func ( double x, double y, double z ), 
  int order, double xtab[], double ytab[], double ztab[], double weight[] );
double lmx_stroud_tetra_unit_volume (void);
double lmx_stroud_tetra_volume ( double x[4], double y[4], double z[4] );
double lmx_stroud_torus_1 ( double func ( double x, double y, double z ), double r1, 
  double r2, int n );
double lmx_stroud_torus_14s ( double func ( double x, double y, double z ), double r1, 
  double r2 );
double lmx_stroud_torus_5s2 ( double func ( double x, double y, double z ), double r1, 
  double r2 );
double lmx_stroud_torus_6s2 ( double func ( double x, double y, double z ), double r1, 
  double r2 );
double lmx_stroud_torus_area_3d ( double r1, double r2 );
double lmx_stroud_torus_square_14c ( double func ( double x, double y, double z ), 
  double r1, double r2 );
double lmx_stroud_torus_square_5c2 ( double func ( double x, double y, double z ), 
  double r1, double r2 );
double lmx_stroud_torus_square_area_3d ( double r1, double r2 );
double lmx_stroud_torus_square_volume_3d ( double r1, double r2 );
double lmx_stroud_torus_volume_3d ( double r1, double r2 );
void lmx_stroud_triangle_rule_adjust ( double xval[3], double yval[3], int order, 
  double xtab[], double ytab[], double weight[], double xtab2[], double ytab2[], 
  double weight2[] );
double lmx_stroud_triangle_sub ( double func ( double x, double y ), double xval[3], 
  double yval[], int nsub, int order, double xtab[], double ytab[], 
  double weight[] );
double lmx_stroud_triangle_sum ( double func ( double x, double y ), 
  double xval[3], double yval[3], int order, double xtab[], double ytab[], 
  double weight[] );
double lmx_stroud_triangle_sum_adjusted ( double func ( double x, double y ), 
  int order, double xtab[], double ytab[], double weight[] );
void lmx_stroud_triangle_unit_product_set ( int rule, int order, double xtab[], 
  double ytab[], double weight[] );
int lmx_stroud_triangle_unit_product_size ( int rule );
void lmx_stroud_triangle_unit_set ( int rule, int order, double xtab[], double ytab[], 
  double weight[] );
int lmx_stroud_triangle_unit_size ( int rule );
double lmx_stroud_triangle_unit_sum ( double func ( double x, double y ), int order, 
  double xtab[], double ytab[], double weight[] );
double lmx_stroud_triangle_unit_volume (void);
double lmx_stroud_triangle_volume ( double x[3], double y[3] );
double *lmx_stroud_tvec_even ( int nt );
double *lmx_stroud_tvec_even2 ( int nt );
double *lmx_stroud_tvec_even3 ( int nt );
double *lmx_stroud_tvec_even_bracket ( int nt, double theta1, double theta2 );
double *lmx_stroud_tvec_even_bracket2 ( int nt, double theta1, double theta2 );
double *lmx_stroud_tvec_even_bracket3 ( int nt, double theta1, double theta2 );
void lmx_stroud_vec_lex_next ( int dim_num, int base, int a[], int *more );
#ifdef __cplusplus
}
#endif
#endif
