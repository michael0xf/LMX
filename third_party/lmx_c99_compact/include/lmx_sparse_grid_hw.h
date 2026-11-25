/* MIT-licensed upstream APIs, namespaced for the LMX collection.
 * Original notices and sources are retained under vendor/. */
#ifndef LMX_SPARSE_GRID_HW_H
#define LMX_SPARSE_GRID_HW_H
#ifdef __cplusplus
extern "C" {
#endif
int lmx_sparse_cce_order ( int l );
int lmx_sparse_ccl_order ( int l );
int lmx_sparse_ccs_order ( int l );
void lmx_sparse_cc ( int n, double x[], double w[] );
double lmx_sparse_fn_integral ( int d );
double *lmx_sparse_fn_value ( int d, int n, double x[] );
double lmx_sparse_fu_integral ( int d );
double *lmx_sparse_fu_value ( int d, int n, double x[] );
int *lmx_sparse_get_seq ( int d, int norm, int seq_num );
void lmx_sparse_gqn ( int n, double x[], double w[] );
int lmx_sparse_gqn_order ( int l );
int lmx_sparse_gqn2_order ( int l );
void lmx_sparse_gqu ( int n, double x[], double w[] );
int lmx_sparse_gqu_order ( int l );
int lmx_sparse_i4_choose ( int n, int k );
int lmx_sparse_i4_factorial2 ( int n );
int lmx_sparse_i4_max ( int i1, int i2 );
int lmx_sparse_i4_min ( int i1, int i2 );
int lmx_sparse_i4_mop ( int i );
int lmx_sparse_i4_power ( int i, int j );
void lmx_sparse_i4mat_print ( int m, int n, int a[], char *title );
void lmx_sparse_i4mat_print_some ( int m, int n, int a[], int ilo, int jlo, int ihi,
  int jhi, char *title );
int *lmx_sparse_i4vec_cum0_new ( int n, int a[] );
void lmx_sparse_i4vec_print ( int n, int a[], char *title );
int lmx_sparse_i4vec_product ( int n, int a[] );
int lmx_sparse_i4vec_sum ( int n, int a[] );
void lmx_sparse_i4vec_transpose_print ( int n, int a[], char *title );
void lmx_sparse_kpn ( int n, double x[], double w[] );
int lmx_sparse_kpn_order ( int l );
void lmx_sparse_kpu ( int n, double x[], double w[] );
int lmx_sparse_kpu_order ( int l );
int lmx_sparse_num_seq ( int n, int k );
void lmx_sparse_nwspgr ( void rule ( int n, double x[], double w[] ), 
  int rule_order ( int l ), int dim, int k, int r_size, int *s_size, 
  double nodes[], double weights[] );
int lmx_sparse_nwspgr_size ( int rule_order ( int l ), int dim, int k );
void lmx_sparse_quad_rule_print ( int m, int n, double x[], double w[], char *title );
double lmx_sparse_r8_uniform_01 ( int *seed );
int *lmx_sparse_r8cvv_offset ( int m, int nr[] );
void lmx_sparse_r8cvv_print ( int mn, double a[], int m, int roff[], char *title );
double *lmx_sparse_r8cvv_rget_new ( int mn, double a[], int m, int roff[], int i );
void lmx_sparse_r8cvv_rset ( int mn, double a[], int m, int roff[], int i, double ai[] );
double *lmx_sparse_r8mat_normal_01_new ( int m, int n, int *seed );
void lmx_sparse_r8mat_transpose_print ( int m, int n, double a[], char *title );
void lmx_sparse_r8mat_transpose_print_some ( int m, int n, double a[], int ilo, int jlo,
  int ihi, int jhi, char *title );
double *lmx_sparse_r8mat_uniform_01_new ( int m, int n, int *seed );
void lmx_sparse_r8vec_copy ( int n, double a1[], double a2[] );
void lmx_sparse_r8vec_direct_product ( int factor_index, int factor_order,
  double factor_value[], int factor_num, int point_num, double x[] );
void lmx_sparse_r8vec_direct_product2 ( int factor_index, int factor_order,
  double factor_value[], int factor_num, int point_num, double w[] );
double lmx_sparse_r8vec_dot_product ( int n, double a1[], double a2[] );
double *lmx_sparse_r8vec_normal_01_new ( int n, int *seed );
void lmx_sparse_r8vec_print ( int n, double a[], char *title );
double lmx_sparse_r8vec_sum ( int n, double a[] );
void lmx_sparse_r8vec_transpose_print ( int n, double a[], char *title );
double *lmx_sparse_r8vec_uniform_01_new ( int n, int *seed );
void lmx_sparse_rule_adjust ( double a, double b, double c, double d, int n, double x[], 
  double w[] );
void lmx_sparse_rule_sort ( int m, int n, double x[], double w[] );
void lmx_sparse_sort_heap_external ( int n, int *indx, int *i, int *j, int isgn );
int lmx_sparse_symmetric_sparse_size ( int nr, int dim, double nodes[], double x0 );
void lmx_sparse_tensor_product ( int d, int order1d[], int n1d, double x1d[], 
  double w1d[], int n, double xnd[], double wnd[] );
void lmx_sparse_tensor_product_cell ( int nc, double xc[], double wc[], int dim, int nr[], 
  int roff[], int np, double xp[], double wp[] );
#ifdef __cplusplus
}
#endif
#endif
