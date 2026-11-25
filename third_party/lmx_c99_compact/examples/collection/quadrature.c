#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "c99_quad.h"

static double f1d(double x)
{
    return x == 0.0 ? 1.0 : sin(x) / x;
}

static double f3d(int dim, const double *x, void *userdata)
{
    double sum = 0;
    int i;
    (void)userdata;
    for (i = 0; i < dim; ++i) sum += x[i]*x[i];
    return sum;
}

int main(void)
{
    double abserr, integral, qmc;
    int neval, ier;
    integral = c99_quad_dqags(f1d, 0.0, 10.0, 1e-10, 1e-10,
        &abserr, &neval, &ier);
    if (ier != 0 || !isfinite(integral)) {
        fprintf(stderr, "Adaptive quadrature failed: ier=%d\n", ier);
        return EXIT_FAILURE;
    }
    printf("Integral sin(x)/x [0,10]: %.17g; estimated error %.3g; evaluations %d\n",
        integral, abserr, neval);
    qmc = c99_quad_qmc_sobol(f3d, 3, 65536, NULL);
    if (!isfinite(qmc)) return EXIT_FAILURE;
    printf("Sobol integral x^2+y^2+z^2 [0,1]^3: %.17g; exact integral 1\n", qmc);
    return EXIT_SUCCESS;
}
