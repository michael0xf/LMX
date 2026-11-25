#include <complex.h>
#include "lmx_scientific.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CHECK(c) do { if (!(c)) {fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #c); return 1;} } while (0)

static int residuals(int m, int n, double *p, double *dy, double **dvec, void *data)
{
    int i;
    (void)n; (void)dvec; (void)data;
    for (i = 0; i < m; ++i) dy[i] = (2.0 + 3.0 * i) - (p[0] + p[1] * i);
    return 0;
}
int main(void)
{
    unsigned i;
    mat4x4 translate, inverse, product;
    vec4 input = {1, 1, 1, 1}, output;
    kiss_fft_cpx impulse[8] = {{1,0}}, frequency[8], recovered[8];
    kiss_fft_cfg forward = kiss_fft_alloc(8, 0, NULL, NULL);
    kiss_fft_cfg backward = kiss_fft_alloc(8, 1, NULL, NULL);
    const double fft_tol = sizeof(kiss_fft_scalar) == sizeof(float) ? 2e-5 : 2e-12;
    tsBSpline spline = ts_bspline_init();
    tsBSpline restored = ts_bspline_init();
    tsDeBoorNet net = ts_deboornet_init();
    tsDeBoorNet restored_net = ts_deboornet_init();
    char *spline_json = NULL;
    tsReal controls[4] = {0, 0, 2, 4}, *point = NULL;
    wave_object wave;
    wt_object wt;
    double signal[32], reconstructed[32];
    double parameters[2] = {0, 0};
    mp_result fit;

    mat4x4_translate(translate, 2, 3, 4);
    mat4x4_mul_vec4(output, translate, input);
    CHECK(output[0] == 3 && output[1] == 4 && output[2] == 5 && output[3] == 1);
    mat4x4_invert(inverse, translate);
    mat4x4_mul(product, translate, inverse);
    for (i = 0; i < 16; ++i) CHECK(fabs(product[i/4][i%4] - (i/4 == i%4)) < 1e-6);

    CHECK(forward && backward);
    kiss_fft(forward, impulse, frequency);
    for (i = 0; i < 8; ++i) CHECK(fabs(frequency[i].r - 1) < fft_tol && fabs(frequency[i].i) < fft_tol);
    kiss_fft(backward, frequency, recovered);
    for (i = 0; i < 8; ++i) CHECK(fabs(recovered[i].r / 8 - impulse[i].r) < fft_tol && fabs(recovered[i].i) < fft_tol);
    kiss_fft_free(forward); kiss_fft_free(backward);

    CHECK(ts_bspline_new(2, 2, 1, TS_CLAMPED, &spline, NULL) == TS_SUCCESS);
    CHECK(ts_bspline_set_control_points(&spline, controls, NULL) == TS_SUCCESS);
    CHECK(ts_bspline_eval(&spline, 0.5, &net, NULL) == TS_SUCCESS);
    CHECK(ts_deboornet_result(&net, &point, NULL) == TS_SUCCESS);
    CHECK(fabs(point[0] - 1) < 1e-12 && fabs(point[1] - 2) < 1e-12);
    free(point); point = NULL;
    CHECK(ts_bspline_to_json(&spline, &spline_json, NULL) == TS_SUCCESS);
    CHECK(spline_json != NULL);
    CHECK(ts_bspline_parse_json(spline_json, &restored, NULL) == TS_SUCCESS);
    CHECK(ts_bspline_eval(&restored, 0.5, &restored_net, NULL) == TS_SUCCESS);
    CHECK(ts_deboornet_result(&restored_net, &point, NULL) == TS_SUCCESS);
    CHECK(fabs(point[0] - 1) < 1e-12 && fabs(point[1] - 2) < 1e-12);
    free(point); free(spline_json);
    ts_deboornet_free(&net); ts_deboornet_free(&restored_net);
    ts_bspline_free(&spline); ts_bspline_free(&restored);

    wave = wave_init("db2"); CHECK(wave);
    wt = wt_init(wave, "dwt", 32, 2); CHECK(wt);
    for (i = 0; i < 32; ++i) signal[i] = sin(0.3 * i) + 0.2 * cos(0.7 * i);
    setDWTExtension(wt, "per"); setWTConv(wt, "direct");
    dwt(wt, signal); idwt(wt, reconstructed);
    for (i = 0; i < 32; ++i) CHECK(fabs(signal[i] - reconstructed[i]) < 1e-10);
    wt_free(wt); wave_free(wave);

    memset(&fit, 0, sizeof fit);
    CHECK(mpfit(residuals, 12, 2, parameters, NULL, NULL, NULL, &fit) > 0);
    CHECK(fabs(parameters[0] - 2) < 1e-8 && fabs(parameters[1] - 3) < 1e-8);
    CHECK(fit.bestnorm < 1e-14);
    puts("linmath, complex FFT roundtrip, linear spline, DWT reconstruction, and least-squares fit passed");
    return 0;
}
