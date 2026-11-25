#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>
#include <process.h>
#include <stdint.h>
#else
#include <pthread.h>
#endif
#include "c99_quad.h"

static const double first_points[8][3] = {
    {0,0,0}, {.5,.5,.5}, {.75,.25,.75}, {.25,.75,.25},
    {.375,.375,.625}, {.875,.875,.125}, {.625,.125,.375}, {.125,.625,.875}
};

static int verify_sequence(void)
{
    long long seed = 0;
    double point[3];
    int i, j;
    for (i = 0; i < 8; ++i) {
        lmx_sobol_i8_sobol(3, &seed, point);
        for (j = 0; j < 3; ++j) if (point[j] != first_points[i][j]) return 1;
    }
    return 0;
}

#ifdef _WIN32
static unsigned __stdcall sequence_worker(void *unused)
{
    (void)unused;
    return (unsigned)verify_sequence();
}
#else
static void *sequence_worker(void *unused)
{
    (void)unused;
    return verify_sequence() ? (void *)1 : NULL;
}
#endif

int main(void)
{
    double *points;
    float *single;
    double high_dimension[1111];
    long long seed = 0;
#ifdef _WIN32
    HANDLE threads[4];
    DWORD status;
#else
    pthread_t threads[4];
    void *status;
#endif
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
#ifdef _WIN32
    for (i = 0; i < 4; ++i) {
        threads[i] = (HANDLE)_beginthreadex(NULL, 0, sequence_worker, NULL, 0, NULL);
        if (!threads[i]) return 4;
    }
    for (i = 0; i < 4; ++i) {
        if (WaitForSingleObject(threads[i], INFINITE) != WAIT_OBJECT_0 ||
            !GetExitCodeThread(threads[i], &status) || status != 0) return 5;
        CloseHandle(threads[i]);
    }
#else
    for (i = 0; i < 4; ++i) if (pthread_create(&threads[i], NULL, sequence_worker, NULL)) return 4;
    for (i = 0; i < 4; ++i)
        if (pthread_join(threads[i], &status) || status != NULL) return 5;
#endif
    if (lmx_sobol_i8_sobol_generate(0, 2, 0) != NULL ||
        lmx_sobol_i4_sobol_generate(2, -1, 0) != NULL) return 6;
    puts("Sobol: known prefix, float/double, 1111 dimensions and concurrent calls passed");
    return EXIT_SUCCESS;
}
