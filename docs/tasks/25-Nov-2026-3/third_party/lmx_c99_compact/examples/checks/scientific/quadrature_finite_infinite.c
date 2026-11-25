#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "c99_quad.h"

static double sinc(double x) { return x == 0.0 ? 1.0 : sin(x) / x; }
static double fourth(double x) { return x*x*x*x; }
static double decay(double x) { return exp(-x); }
static double gaussian(double x) { return exp(-x*x); }
static double singular(double x) { return 1.0 / sqrt(x); }
static double weighted_square(double x, void *data) { return *(double *)data*x*x; }

int main(void)
{
    double error, value, resabs, resasc, scale = 6.0;
    int neval, ier;
    value = c99_quad_dqags(sinc, 0, 10, 1e-10, 1e-10, &error, &neval, &ier);
    if (ier || neval <= 0 || fabs(value - 1.65834759421887404933) > 1e-10 || error > 1e-9) return 1;
    value = c99_quad_dqags(singular, 0, 1, 1e-10, 1e-10, &error, &neval, &ier);
    if (ier || fabs(value - 2.0) > 1e-9) return 2;
    value = c99_quad_dqagi(decay, 0, 1, 1e-10, 1e-10, &error, &neval, &ier);
    if (ier || fabs(value - 1.0) > 1e-10) return 3;
    value = c99_quad_dqagi(gaussian, 0, 2, 1e-10, 1e-10, &error, &neval, &ier);
    if (ier || fabs(value - sqrt(acos(-1.0))) > 1e-10) return 4;
    value = c99_quad_dqk21(fourth, 0, 1, &error, &resabs, &resasc);
    if (fabs(value - 0.2) > 1e-14 || error > 1e-12 || resabs <= 0 || resasc <= 0) return 5;
    value = lmx_quadpack_dqags(weighted_square, 0, 1, 1e-12, 1e-12,
        &error, &neval, &ier, &scale);
    if (ier || fabs(value - 2.0) > 1e-12) return 6;
    value = c99_quad_dqags(NULL, 0, 1, 1e-10, 1e-10, &error, &neval, &ier);
    if (!isnan(value) || ier != 6 || neval != 0) return 7;
    value = c99_quad_dqagi(decay, 0, 9, 1e-10, 1e-10, &error, &neval, &ier);
    if (!isnan(value) || ier != 6) return 8;
    puts("CQUADPACK: finite, singular, infinite, 21-point rule and userdata passed");
    return EXIT_SUCCESS;
}
