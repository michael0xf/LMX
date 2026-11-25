#include <float.h>
#include <stddef.h>
#include "c99_quad.h"

typedef struct { c99_quad_1d_func func; } c99_quad_bridge;

static double c99_quad_call(double x, void *userdata)
{
    const c99_quad_bridge *bridge = userdata;
    return bridge->func(x);
}

static int c99_quad_valid(c99_quad_1d_func func, double epsabs, double epsrel,
    double *abserr, int *neval, int *ier)
{
    if (abserr != NULL) *abserr = NAN;
    if (neval != NULL) *neval = 0;
    if (ier != NULL) *ier = 6;
    return func != NULL && abserr != NULL && neval != NULL && ier != NULL &&
        isfinite(epsabs) && isfinite(epsrel) && epsabs >= 0.0 && epsrel >= 0.0 &&
        (epsabs > 0.0 || epsrel >= 50.0 * DBL_EPSILON);
}

double c99_quad_dqags(c99_quad_1d_func func, double a, double b,
    double epsabs, double epsrel, double *abserr, int *neval, int *ier)
{
    c99_quad_bridge bridge;
    if (!c99_quad_valid(func, epsabs, epsrel, abserr, neval, ier) ||
        !isfinite(a) || !isfinite(b)) return NAN;
    bridge.func = func;
    return lmx_quadpack_dqags(c99_quad_call, a, b, epsabs, epsrel,
        abserr, neval, ier, &bridge);
}

double c99_quad_dqagi(c99_quad_1d_func func, double bound, int inf,
    double epsabs, double epsrel, double *abserr, int *neval, int *ier)
{
    c99_quad_bridge bridge;
    if (!c99_quad_valid(func, epsabs, epsrel, abserr, neval, ier) ||
        !isfinite(bound) || (inf != -1 && inf != 1 && inf != 2)) return NAN;
    bridge.func = func;
    return lmx_quadpack_dqagi(c99_quad_call, bound, inf, epsabs, epsrel,
        abserr, neval, ier, &bridge);
}

double c99_quad_dqk21(c99_quad_1d_func func, double a, double b,
    double *abserr, double *resabs, double *resasc)
{
    c99_quad_bridge bridge;
    if (abserr != NULL) *abserr = NAN;
    if (resabs != NULL) *resabs = NAN;
    if (resasc != NULL) *resasc = NAN;
    if (func == NULL || abserr == NULL || resabs == NULL || resasc == NULL ||
        !isfinite(a) || !isfinite(b)) return NAN;
    bridge.func = func;
    return lmx_quadpack_G_K21(c99_quad_call, a, b, abserr, resabs, resasc, &bridge);
}

double c99_quad_qmc_sobol(c99_quad_nd_func func, int dim,
    int num_samples, void *userdata)
{
    double point[40];
    double sum = 0.0, correction = 0.0;
    long long int seed = 0;
    int i;
    if (func == NULL || dim < 1 || dim > 40 || num_samples < 1) return NAN;
    for (i = 0; i < num_samples; ++i) {
        double value, adjusted, next_sum;
        lmx_sobol_i8_sobol(dim, &seed, point);
        value = func(dim, point, userdata);
        if (!isfinite(value)) return NAN;
        adjusted = value - correction;
        next_sum = sum + adjusted;
        correction = (next_sum - sum) - adjusted;
        sum = next_sum;
    }
    return isfinite(sum) ? sum / (double)num_samples : NAN;
}
