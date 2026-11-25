/* MIT; deterministic numerical checks, no external framework. */
#include "lsoda.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern char *_strdup_printf(char *, ...);

static int decay(double t, double *y, double *dy, void *user)
{
    double rate = *(const double *)user;
    (void)t;
    dy[0] = -rate * y[0];
    return 0;
}

static int robertson(double t, double *y, double *dy, void *user)
{
    (void)t;
    (void)user;
    dy[0] = 1.0e4 * y[1] * y[2] - 0.04 * y[0];
    dy[2] = 3.0e7 * y[1] * y[1];
    dy[1] = -dy[0] - dy[2];
    return 0;
}

static int decay_check(void)
{
    double rates[2] = {0.25, 1.75};
    double y[2] = {2.0, 3.0}, t[2] = {0.0, 0.0};
    double rtol[2] = {1e-9, 1e-9}, atol[2] = {1e-11, 1e-11};
    struct lsoda_context_t ctx[2] = {{0}, {0}};
    struct lsoda_opt_t opt[2] = {{0}, {0}};
    int i, k, ok = 1;
    for (i = 0; i < 2; ++i) {
        ctx[i].function = decay;
        ctx[i].data = &rates[i];
        ctx[i].neq = 1;
        ctx[i].state = 1;
        opt[i].rtol = &rtol[i]; opt[i].atol = &atol[i]; opt[i].itask = 1;
        if (!lsoda_prepare(&ctx[i], &opt[i])) return 0;
    }
    /* Interleaving checks independent caller contexts, not thread safety. */
    for (k = 1; k <= 20; ++k) {
        for (i = 0; i < 2; ++i) {
            double want = (2.0 + i) * exp(-rates[i] * k * 0.2);
            if (lsoda(&ctx[i], &y[i], &t[i], k * 0.2) <= 0 ||
                fabs(y[i] - want) > 2e-7) ok = 0;
        }
    }
    for (i = 0; i < 2; ++i) lsoda_free(&ctx[i]);
    return ok;
}

static int stiff_check(void)
{
    double y[3] = {1, 0, 0}, t = 0;
    double rtol[3] = {1e-7, 1e-7, 1e-7};
    double atol[3] = {1e-10, 1e-13, 1e-10};
    struct lsoda_context_t ctx = {0};
    struct lsoda_opt_t opt = {0};
    int result;
    ctx.function = robertson; ctx.neq = 3; ctx.state = 1;
    opt.rtol = rtol; opt.atol = atol; opt.itask = 1; opt.mxstep = 10000;
    if (!lsoda_prepare(&ctx, &opt)) return 0;
    result = lsoda(&ctx, y, &t, 40.0);
    printf("Robertson t=%.9g y=%.12g %.12g %.12g state=%d\n", t, y[0], y[1], y[2], result);
    lsoda_free(&ctx);
    /* Independent reference: SciPy 1.17 Radau, rtol=1e-11,
       atol={1e-13,1e-16,1e-13}; no Python needed to run this C test. */
    return result > 0 && fabs(y[0] - 0.7158270687194047) < 2e-7 &&
        fabs(y[1] - 9.185534764557964e-6) < 2e-10 &&
        fabs(y[2] - 0.2841637457458303) < 2e-7 &&
        fabs(y[0] + y[1] + y[2] - 1.0) < 1e-9;
}

static int diagnostics_check(void)
{
    char *text = _strdup_printf("%s/%d", "complete", 12345);
    char *empty = _strdup_printf("%s", "");
    int ok = text != NULL && strcmp(text, "complete/12345") == 0 &&
             empty != NULL && empty[0] == '\0';
    free(text); free(empty);
    return ok;
}

int main(void)
{
    int a = decay_check(), b = stiff_check(), c = diagnostics_check();
    if (!a || !b || !c) {
        fprintf(stderr, "decay=%d stiff=%d diagnostics=%d\n", a, b, c);
        fputs("LSODA check failed\n", stderr); return 1;
    }
    puts("LSODA: independent decay contexts, stiff Robertson system, complete diagnostics PASS");
    return 0;
}
