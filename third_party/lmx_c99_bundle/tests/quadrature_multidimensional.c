#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "c99_quad.h"

static double sum_squares(int dim, const double *point, void *data)
{
    double value = 0;
    int i;
    (void)data;
    for (i = 0; i < dim; ++i) value += point[i]*point[i];
    return value;
}

int main(void)
{
    const int dim = 3, level = 3, samples = 65536;
    int order = lmx_stroud_cn_leg_03_1_size(dim);
    int capacity, count, j, i;
    double *nodes = malloc((size_t)dim*(size_t)order*sizeof(double));
    double *weights = malloc((size_t)order*sizeof(double));
    double value = 0, mass = 0, sobol;
    if (!nodes || !weights) return 1;
    lmx_stroud_cn_leg_03_1(dim, order, nodes, weights);
    for (j = 0; j < order; ++j) {
        value += weights[j] * sum_squares(dim, nodes + j*dim, NULL);
        mass += weights[j];
    }
    free(nodes); free(weights);
    /* Stroud Legendre rules use [-1,1]^3, whose volume and integral are 8. */
    if (fabs(mass - 8) > 1e-12 || fabs(value - 8) > 1e-12) return 2;
    capacity = lmx_sparse_nwspgr_size(lmx_sparse_gqu_order, dim, level);
    nodes = malloc((size_t)dim*(size_t)capacity*sizeof(double));
    weights = malloc((size_t)capacity*sizeof(double));
    if (!nodes || !weights) return 3;
    lmx_sparse_nwspgr(lmx_sparse_gqu, lmx_sparse_gqu_order, dim, level,
        capacity, &count, nodes, weights);
    value = 0; mass = 0;
    for (j = 0; j < count; ++j) {
        for (i = 0; i < dim; ++i)
            if (nodes[i+j*dim] < 0 || nodes[i+j*dim] > 1) return 4;
        value += weights[j] * sum_squares(dim, nodes + j*dim, NULL);
        mass += weights[j];
    }
    free(nodes); free(weights);
    if (fabs(mass - 1) > 1e-12 || fabs(value - 1) > 1e-12) return 5;
    sobol = c99_quad_qmc_sobol(sum_squares, dim, samples, NULL);
    if (fabs(sobol - 1) > 3e-5 ||
        fabs(sobol - (1 - 1.5/samples + 0.5/((double)samples*samples))) > 1e-13) return 6;
    if (!isnan(c99_quad_qmc_sobol(NULL, 3, 100, NULL)) ||
        !isnan(c99_quad_qmc_sobol(sum_squares, 41, 100, NULL)) ||
        !isnan(c99_quad_qmc_sobol(sum_squares, 3, 0, NULL))) return 7;
    printf("Stroud, sparse grid, Sobol 3D: %0.17g (exact integral 1)\n", sobol);
    return EXIT_SUCCESS;
}
