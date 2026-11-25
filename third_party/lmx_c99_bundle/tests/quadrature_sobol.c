#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "c99_quad.h"

static const double first_points[8][3] = {
    {0,0,0}, {.5,.5,.5}, {.75,.25,.75}, {.25,.75,.25},
    {.375,.375,.625}, {.875,.875,.125}, {.625,.125,.375}, {.125,.625,.875}
};

static void *sequence_worker(void *unused)
{
    long long seed = 0;
    double point[3];
    int i, j;
    (void)unused;
    for (i = 0; i < 8; ++i) {
        lmx_sobol_i8_sobol(3, &seed, point);
        for (j = 0; j < 3; ++j) if (point[j] != first_points[i][j]) return (void *)1;
    }
    return NULL;
}

int main(void)
{
    double *points;
    float *single;
    double high_dimension[1111];
    long long seed = 0;
    pthread_t threads[4];
    void *status;
    int i, j;
    points = lmx_sobol_i8_sobol_generate(3, 8, 0);
    single = lmx_sobol_i4_sobol_generate(3, 8, 0);
    if (!points || !single) return 1;
    for (i = 0; i < 8; ++i) for (j = 0; j < 3; ++j)
        if (points[i*3+j] != first_points[i][j] || single[i*3+j] != first_points[i][j]) return 2;
    free(points); free(single);
    for (i = 0; i < 2; ++i) {
        lmx_sobol_i8_sobol(1111, &seed, high_dimension);
        for (j = 0; j < 1111; ++j)
            if (high_dimension[j] != i * 0.5) return 3;
    }
    for (i = 0; i < 4; ++i) if (pthread_create(&threads[i], NULL, sequence_worker, NULL)) return 4;
    for (i = 0; i < 4; ++i)
        if (pthread_join(threads[i], &status) || status != NULL) return 5;
    if (lmx_sobol_i8_sobol_generate(0, 2, 0) != NULL ||
        lmx_sobol_i4_sobol_generate(2, -1, 0) != NULL) return 6;
    puts("Sobol: known prefix, float/double, 1111 dimensions and concurrent calls passed");
    return EXIT_SUCCESS;
}
