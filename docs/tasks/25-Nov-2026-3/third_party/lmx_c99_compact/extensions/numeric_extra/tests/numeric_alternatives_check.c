#include <pffft/pffft.h>
#include <pffft/pffft_double.h>
#include <pcg_variants.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define CHECK(condition) do { if (!(condition)) { \
    fprintf(stderr, "check failed at line %d: %s\n", __LINE__, #condition); \
    exit(1); } } while (0)

int main(void)
{
    int i;
    PFFFT_Setup *single = pffft_new_setup(32, PFFFT_COMPLEX);
    PFFFTD_Setup *wide = pffftd_new_setup(32, PFFFT_COMPLEX);
    float *f = (float *)pffft_aligned_malloc(64 * sizeof *f);
    float *ft = (float *)pffft_aligned_malloc(64 * sizeof *ft);
    float *fw = (float *)pffft_aligned_malloc(64 * sizeof *fw);
    double *d = (double *)pffftd_aligned_malloc(64 * sizeof *d);
    double *dt = (double *)pffftd_aligned_malloc(64 * sizeof *dt);
    double *dw = (double *)pffftd_aligned_malloc(64 * sizeof *dw);
    pcg32_random_t rng, jumped;
    CHECK(single && wide && f && ft && fw && d && dt && dw);
    CHECK(pffft_simd_size() == 1 && pffftd_simd_size() == 1);
    for (i = 0; i < 64; ++i) { f[i] = 0; d[i] = 0; }
    f[0] = 1; d[0] = 1;
    pffft_transform_ordered(single, f, ft, fw, PFFFT_FORWARD);
    pffftd_transform_ordered(wide, d, dt, dw, PFFFT_FORWARD);
    for (i = 0; i < 32; ++i) {
        CHECK(fabsf(ft[2 * i] - 1) < 1e-6f && fabsf(ft[2 * i + 1]) < 1e-6f);
        CHECK(fabs(dt[2 * i] - 1) < 1e-12 && fabs(dt[2 * i + 1]) < 1e-12);
    }
    pffft_transform_ordered(single, ft, f, fw, PFFFT_BACKWARD);
    pffftd_transform_ordered(wide, dt, d, dw, PFFFT_BACKWARD);
    for (i = 0; i < 64; ++i) {
        CHECK(fabsf(f[i] / 32 - (i == 0)) < 1e-6f);
        CHECK(fabs(d[i] / 32 - (i == 0)) < 1e-12);
    }
    pffft_destroy_setup(single); pffftd_destroy_setup(wide);
    pffft_aligned_free(f); pffft_aligned_free(ft); pffft_aligned_free(fw);
    pffftd_aligned_free(d); pffftd_aligned_free(dt); pffftd_aligned_free(dw);
    pcg32_srandom_r(&rng, 42, 54);
    CHECK(pcg32_random_r(&rng) == UINT32_C(0xa15c02b7));
    CHECK(pcg32_random_r(&rng) == UINT32_C(0x7b47f409));
    jumped = rng;
    pcg32_advance_r(&jumped, 1000);
    for (i = 0; i < 1000; ++i) (void)pcg32_random_r(&rng);
    CHECK(pcg32_random_r(&rng) == pcg32_random_r(&jumped));
    for (i = 0; i < 100; ++i) CHECK(pcg32_boundedrand_r(&rng, 7) < 7);
    puts("PASS: PFFFT float/double impulse FFT and inverse; PCG seeded vector and jump-ahead");
    return 0;
}
