#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mpdecimal.h"

static int same_decimal(const mpd_t *value, const char *expected)
{
    char *text = mpd_to_sci(value, 1);
    int equal;
    if (text == NULL) return 0;
    equal = strcmp(text, expected) == 0;
    if (!equal) fprintf(stderr, "Expected %s, got %s\n", expected, text);
    mpd_free(text);
    return equal;
}

int main(void)
{
    mpd_context_t ctx;
    mpd_t *x = NULL, *y = NULL, *result = NULL;
    uint32_t status = 0;
    char nines[1001], expected[2001];
    mpd_uint128_triple_t triple = {MPD_TRIPLE_NORMAL, 0, UINT64_MAX, UINT64_MAX, 0};
    mpd_uint128_triple_t back;
    int rc = EXIT_FAILURE;
    mpd_defaultcontext(&ctx);
    ctx.prec = 50;
    ctx.round = MPD_ROUND_HALF_EVEN;
    ctx.traps = 0;
    x = mpd_qnew(); y = mpd_qnew(); result = mpd_qnew();
    if (x == NULL || y == NULL || result == NULL) goto done;
    mpd_qset_string(x, "2", &ctx, &status);
    mpd_qsqrt(result, x, &ctx, &status);
    if (status != (MPD_Rounded | MPD_Inexact) || !same_decimal(result,
        "1.4142135623730950488016887242096980785696718753769")) goto done;
    status = 0;
    mpd_qset_string(x, "0.1", &ctx, &status);
    mpd_qset_string(y, "0.2", &ctx, &status);
    mpd_qadd(result, x, y, &ctx, &status);
    if (status != 0 || !same_decimal(result, "0.3")) goto done;

    status = 0;
    mpd_qset_string(x, "1.005", &ctx, &status);
    mpd_qset_string(y, "0.01", &ctx, &status);
    mpd_qquantize(result, x, y, &ctx, &status);
    if (status != (MPD_Rounded | MPD_Inexact) || !same_decimal(result, "1.00")) goto done;

    /* Forces the portable 128-bit triple conversion implementation. */
    status = 0;
    if (mpd_from_uint128_triple(x, &triple, &status) != 0 || status != 0 ||
        !same_decimal(x, "340282366920938463463374607431768211455")) goto done;
    back = mpd_as_uint128_triple(x);
    if (back.tag != triple.tag || back.sign != triple.sign || back.hi != triple.hi ||
        back.lo != triple.lo || back.exp != triple.exp) goto done;

    ctx.prec = 2010;
    memset(nines, '9', 1000); nines[1000] = '\0';
    memset(expected, '9', 999); expected[999] = '8';
    memset(expected + 1000, '0', 999); expected[1999] = '1'; expected[2000] = '\0';
    mpd_qset_string(x, nines, &ctx, &status);
    mpd_qmul(result, x, x, &ctx, &status);
    if (status != 0 || !same_decimal(result, expected)) goto done;

    status = 0;
    mpd_qset_string(x, "not a number", &ctx, &status);
    if (!(status & MPD_Conversion_syntax) || !mpd_isnan(x)) goto done;
    puts("MPDecimal: 50-digit sqrt, decimal rounding, uint128 conversion, large product passed");
    rc = EXIT_SUCCESS;
done:
    if (x != NULL) mpd_del(x);
    if (y != NULL) mpd_del(y);
    if (result != NULL) mpd_del(result);
    return rc;
}
