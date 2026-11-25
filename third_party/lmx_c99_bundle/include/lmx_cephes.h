/* Cephes C99 namespaced API, generated from the selected upstream definitions.
 * Algorithms and copyright: Stephen L. Moshier; see vendor/cephes/readme.
 * Public names intentionally do not replace libc math.h/complex.h symbols.
 */
#ifndef LMX_CEPHES_H
#define LMX_CEPHES_H
#ifdef __cplusplus
extern "C" {
#endif

typedef struct { double r, i; } lmx_cephes_complex;
extern double lmx_cephes_acos (double x);
extern double lmx_cephes_acosh (double x);
extern int lmx_cephes_airy (double x, double *ai, double *aip, double *bi, double *bip);
extern double lmx_cephes_asin (double x);
extern double lmx_cephes_asinh (double xx);
extern double lmx_cephes_atan (double x);
extern double lmx_cephes_atan2 (double y, double x);
extern double lmx_cephes_atanh (double x);
extern double lmx_cephes_bdtr (int k, int n, double p);
extern double lmx_cephes_bdtrc (int k, int n, double p);
extern double lmx_cephes_bdtri (int k, int n, double y);
extern double lmx_cephes_beta (double a, double b);
extern double lmx_cephes_btdtr (double a, double b, double x);
extern double lmx_cephes_cabs (lmx_cephes_complex *z);
extern void lmx_cephes_cacos (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_cacosh (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_cadd (lmx_cephes_complex *a, lmx_cephes_complex *b, lmx_cephes_complex *c);
extern void lmx_cephes_casin (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_casinh (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_catan (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_catanh (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern double lmx_cephes_cbrt (double x);
extern void lmx_cephes_ccos (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_ccosh (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_ccot (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_cdiv (lmx_cephes_complex *a, lmx_cephes_complex *b, lmx_cephes_complex *c);
extern double lmx_cephes_ceil (double x);
extern void lmx_cephes_cexp (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern double lmx_cephes_chbevl (double x, double *array, int n);
extern double lmx_cephes_chdtr (double df, double x);
extern double lmx_cephes_chdtrc (double df, double x);
extern double lmx_cephes_chdtri (double df, double y);
extern void lmx_cephes_clog (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_cmov (void *a, void *b);
extern void lmx_cephes_cmul (lmx_cephes_complex *a, lmx_cephes_complex *b, lmx_cephes_complex *c);
extern void lmx_cephes_cneg (lmx_cephes_complex *a);
extern double lmx_cephes_cos (double x);
extern double lmx_cephes_cosdg (double x);
extern double lmx_cephes_cosh (double x);
extern double lmx_cephes_cosm1 (double x);
extern double lmx_cephes_cot (double x);
extern double lmx_cephes_cotdg (double x);
extern void lmx_cephes_cpow (lmx_cephes_complex *a, lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_csin (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_csinh (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_csqrt (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_csub (lmx_cephes_complex *a, lmx_cephes_complex *b, lmx_cephes_complex *c);
extern void lmx_cephes_ctan (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern void lmx_cephes_ctanh (lmx_cephes_complex *z, lmx_cephes_complex *w);
extern int lmx_cephes_drand (double *a);
extern double lmx_cephes_erf (double x);
extern double lmx_cephes_erfc (double a);
extern double lmx_cephes_exp (double x);
extern double lmx_cephes_exp10 (double x);
extern double lmx_cephes_exp2 (double x);
extern double lmx_cephes_expm1 (double x);
extern double lmx_cephes_expx2 (double x, int sign);
extern double lmx_cephes_fabs (double x);
extern double lmx_cephes_fdtr (int ia, int ib, double x);
extern double lmx_cephes_fdtrc (int ia, int ib, double x);
extern double lmx_cephes_fdtri (int ia, int ib, double y);
extern double lmx_cephes_floor (double x);
extern double lmx_cephes_frexp (double x, int *pw2);
extern double lmx_cephes_gamma (double x);
extern double lmx_cephes_gdtr (double a, double b, double x);
extern double lmx_cephes_gdtrc (double a, double b, double x);
extern double lmx_cephes_hyp2f0 (double a, double b, double x, int type, double *err);
extern double lmx_cephes_hyp2f1 (double a, double b, double c, double x);
extern double lmx_cephes_hyperg (double a, double b, double x);
extern double lmx_cephes_hypot (double x, double y);
extern double lmx_cephes_i0 (double x);
extern double lmx_cephes_i0e (double x);
extern double lmx_cephes_i1 (double x);
extern double lmx_cephes_i1e (double x);
extern double lmx_cephes_igam (double a, double x);
extern double lmx_cephes_igamc (double a, double x);
extern double lmx_cephes_igami (double a, double y0);
extern double lmx_cephes_incbet (double aa, double bb, double xx);
extern double lmx_cephes_incbi (double aa, double bb, double yy0);
extern int lmx_cephes_isfinite (double x);
extern int lmx_cephes_isnan (double x);
extern double lmx_cephes_iv (double v, double x);
extern double lmx_cephes_j0 (double x);
extern double lmx_cephes_j1 (double x);
extern double lmx_cephes_jn (int n, double x);
extern double lmx_cephes_jv (double n, double x);
extern double lmx_cephes_k0 (double x);
extern double lmx_cephes_k0e (double x);
extern double lmx_cephes_k1 (double x);
extern double lmx_cephes_k1e (double x);
extern double lmx_cephes_kn (int nn, double x);
extern double lmx_cephes_kolmogi (double p);
extern double lmx_cephes_kolmogorov (double y);
extern double lmx_cephes_lbeta (double a, double b);
extern double lmx_cephes_ldexp (double x, int pw2);
extern double lmx_cephes_lgam (double x);
extern double lmx_cephes_log (double x);
extern double lmx_cephes_log10 (double x);
extern double lmx_cephes_log1p (double x);
extern double lmx_cephes_log2 (double x);
extern int lmx_cephes_mtherr (char *name, int code);
extern double lmx_cephes_nbdtr (int k, int n, double p);
extern double lmx_cephes_nbdtrc (int k, int n, double p);
extern double lmx_cephes_nbdtri (int k, int n, double p);
extern double lmx_cephes_ndtr (double a);
extern double lmx_cephes_ndtri (double y0);
extern double lmx_cephes_onef2 (double a, double b, double c, double x, double *err);
extern double lmx_cephes_p1evl (double x, double *coef, int N);
extern double lmx_cephes_pdtr (int k, double m);
extern double lmx_cephes_pdtrc (int k, double m);
extern double lmx_cephes_pdtri (int k, double y);
extern double lmx_cephes_polevl (double x, double *coef, int N);
extern double lmx_cephes_pow (double x, double y);
extern double lmx_cephes_powi (double x, int nn);
extern double lmx_cephes_psi (double x);
extern double lmx_cephes_radian (double d, double m, double s);
extern double lmx_cephes_round (double x);
extern int lmx_cephes_signbit (double x);
extern double lmx_cephes_sin (double x);
extern double lmx_cephes_sindg (double x);
extern double lmx_cephes_sinh (double x);
extern double lmx_cephes_smirnov (int n, double e);
extern double lmx_cephes_smirnovi (int n, double p);
extern double lmx_cephes_sqrt (double x);
extern double lmx_cephes_stdtr (int k, double t);
extern double lmx_cephes_stdtri (int k, double p);
extern double lmx_cephes_struve (double v, double x);
extern double lmx_cephes_tan (double x);
extern double lmx_cephes_tandg (double x);
extern double lmx_cephes_tanh (double x);
extern double lmx_cephes_threef0 (double a, double b, double c, double x, double *err);
extern double lmx_cephes_y0 (double x);
extern double lmx_cephes_y1 (double x);
extern double lmx_cephes_yn (int n, double x);
extern double lmx_cephes_yv (double v, double x);

/* Upstream error/sign state is global; concurrent calls require caller locking. */
extern int lmx_cephes_merror;
extern int lmx_cephes_sgngam;
#ifdef __cplusplus
}
#endif
#endif
