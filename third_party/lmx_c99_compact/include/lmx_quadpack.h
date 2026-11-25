/* MIT-licensed upstream APIs, namespaced for the LMX collection.
 * Original notices and sources are retained under vendor/. */
#ifndef LMX_QUADPACK_H
#define LMX_QUADPACK_H
#ifdef __cplusplus
extern "C" {
#endif
typedef double(*lmx_quadpack_dq_function_type)(double, void*);

/* Integration routines */
/* Gauss-Kronrod for integration over finite range. */
double lmx_quadpack_G_K15(lmx_quadpack_dq_function_type f,double a,double b,double *abserr,
    double *resabs, double *resasc, void* user_data);
double lmx_quadpack_G_K21(lmx_quadpack_dq_function_type f, double a, double b, double *abserr,
    double *resabs, double *resasc, void* user_data);
double lmx_quadpack_G_K31(lmx_quadpack_dq_function_type f, double a, double b, double *abserr,
    double *resabs, double *resasc, void* user_data);
double lmx_quadpack_G_K41(lmx_quadpack_dq_function_type f, double a, double b, double *abserr,
    double *resabs, double *resasc, void* user_data);
double lmx_quadpack_G_K51(lmx_quadpack_dq_function_type f, double a, double b, double *abserr,
    double *resabs, double *resasc, void* user_data);
double lmx_quadpack_G_K61(lmx_quadpack_dq_function_type f, double a, double b, double *abserr,
    double *resabs, double *resasc, void* user_data);

/* Gauss-Kronrod for integration over infinite range. */
double lmx_quadpack_G_K15I(lmx_quadpack_dq_function_type f, double boun, int inf, double a, double b,
    double *abserr,double *resabs, double *resasc, void* user_data);

/* Gauss-Kronrod for integration of weighted function. */
double lmx_quadpack_G_K15W(lmx_quadpack_dq_function_type f, double w(), double p1, double p2, double p3,
    double p4,int kp,double a,double b,double *abserr,
    double *resabs, double *resasc, void* user_data);
double lmx_quadpack_dqext(int *n, double epstab [], double *abserr,
    double res3la[],int *nres);
void lmx_quadpack_dqsort(int limit, int last, int *maxerr, double *ermax,
    double elist[],int iord[],int *nrmax);
double lmx_quadpack_dqagi(lmx_quadpack_dq_function_type f, double bound, int inf, double epsabs,
    double epsrel,double *abserr,int *neval,int *ier, void* user_data);
double lmx_quadpack_dqags(lmx_quadpack_dq_function_type f, double a, double b, double epsabs,
    double epsrel,double *abserr,int *neval,int *ier, void* user_data);
double lmx_quadpack_dqagp(lmx_quadpack_dq_function_type f, double a, double b, int npts2, double *points,
    double epsabs,double epsrel,double *abserr,int *neval,int *ier, void* user_data);
double lmx_quadpack_dqng(lmx_quadpack_dq_function_type f, double a, double b, double epsabs, double epsrel,
    double *abserr,int *neval,int *ier, void* user_data);
double lmx_quadpack_dqag(lmx_quadpack_dq_function_type f, double a, double b, double epsabs, double epsrel,
    int irule,double *abserr,int *neval,int *ier, void* user_data);
double lmx_quadpack_dqage(lmx_quadpack_dq_function_type f, double a, double b, double epsabs, double epsrel,
    int irule,double *abserr,int *neval,int *ier,int *last, void* user_data);
double lmx_quadpack_dqwgtc(double x, double c, double p2, double p3, double p4,
    int kp);
double lmx_quadpack_dqwgto(double x, double omega, double p2, double p3, double p4,
    int integr);
double lmx_quadpack_dqwgts(double x, double a, double b, double alpha, double beta,
    int integr);
void lmx_quadpack_dqcheb(double *x, double *fval, double *cheb12, double *cheb24);
double lmx_quadpack_dqc25o(lmx_quadpack_dq_function_type f, double a, double b, double omega, int integr,
    int nrmom,int maxp1,int ksave,double *abserr,int *neval,
    double *resabs,double *resasc,int *momcom,double **chebmo, void* user_data);
double lmx_quadpack_dqfour(lmx_quadpack_dq_function_type f, double a, double b, double omega, int integr,
    double epsabs,double epsrel,int icall,int maxp1,
    double *abserr,int *neval,int *ier,int *momcom,
    double **chebmo, void* user_data);
double lmx_quadpack_dqawfe(lmx_quadpack_dq_function_type f, double a, double omega, int integr, double epsabs,
    int limlst,int maxp1,double *abserr,int *neval,int *ier,
    double *rslst,double *erlist,int *ierlst,double **chebmo, void* user_data);
double lmx_quadpack_dqawf(lmx_quadpack_dq_function_type f, double a, double omega, int integr, double epsabs,
    double *abserr,int *neval,int *ier, void* user_data);
double lmx_quadpack_dqawo(lmx_quadpack_dq_function_type f, double a, double b, double omega, int integr, double epsabs,
    double epsrel,double *abserr,int *neval,int *ier, void* user_data);
double lmx_quadpack_dqaws(lmx_quadpack_dq_function_type f, double a, double b, double alfa, double beta, int wgtfunc,
    double epsabs,double epsrel,double *abserr,int *neval,int *ier, void* user_data);
double lmx_quadpack_dqawse(lmx_quadpack_dq_function_type f, double a, double b, double alfa, double beta,
    int wgtfunc,double epsabs,double epsrel,double *abserr,
    int *neval,int *ier, void* user_data);
void lmx_quadpack_dqmomo(double alfa, double beta, double ri [], double rj [], double rg [],
    double rh[],int wgtfunc);
double lmx_quadpack_dqc25s(lmx_quadpack_dq_function_type f, double a, double b, double bl, double br, double alfa,
    double beta,double ri[],double rj[],double rg[],double rh[],
    double *abserr,double *resasc,int wgtfunc,int *nev, void* user_data);
double lmx_quadpack_dqc25c(lmx_quadpack_dq_function_type f, double a, double b, double c, double *abserr,
    int *krul,int *neval, void* user_data);
double lmx_quadpack_dqawc(lmx_quadpack_dq_function_type f, double a, double b, double c, double epsabs,
    double epsrel,double *abserr,int *neval,int *ier, void* user_data);
double lmx_quadpack_dqawce(lmx_quadpack_dq_function_type f, double a, double b, double c, double epsabs,
    double epsrel,double *abserr,int *neval,int *ier, void* user_data);
#ifdef __cplusplus
}
#endif
#endif
