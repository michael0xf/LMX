#ifndef C99_QUAD_H
#define C99_QUAD_H

#include <math.h>
#include "lmx_quadpack.h"
#include "lmx_stroud.h"
#include "lmx_sparse_grid_hw.h"
#include "lmx_sobol.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef double (*c99_quad_1d_func)(double x);
typedef double (*c99_quad_nd_func)(int dim, const double *x, void *userdata);

/* Simple callbacks matching the proposed interface; use lmx_quadpack_* when a
 * callback needs userdata. Invalid arguments return NAN and ier=6 when supplied.
 */
double c99_quad_dqags(c99_quad_1d_func func, double a, double b,
    double epsabs, double epsrel, double *abserr, int *neval, int *ier);
/* inf=1: [bound,+infinity); inf=-1: (-infinity,bound]; inf=2: entire real line. */
double c99_quad_dqagi(c99_quad_1d_func func, double bound, int inf,
    double epsabs, double epsrel, double *abserr, int *neval, int *ier);
/* CQUADPACK's native 21-point routine is named G_K21, not dqk21. */
double c99_quad_dqk21(c99_quad_1d_func func, double a, double b,
    double *abserr, double *resabs, double *resasc);

/* Deterministic Sobol quadrature on [0,1]^dim; no probabilistic error estimate.
 * This convenient wrapper intentionally limits dim to 40; native Sobol supports
 * up to 1111. Invalid arguments/nonfinite integrand results return NAN.
 * The first sample is the all-zero point, so endpoint singularities need care.
 */
double c99_quad_qmc_sobol(c99_quad_nd_func func, int dim,
    int num_samples, void *userdata);

#ifdef __cplusplus
}
#endif
#endif
