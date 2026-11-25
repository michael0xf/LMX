/* C99 example: arbitrary integers and correctly rounded decimal arithmetic.
 * Link with LMX::precision; no global ANSI define or hand-written declarations.
 */
#include <stdio.h>
#include <stdlib.h>
#include "tommath.h"
#include "mpdecimal.h"

static int bigint_example(void)
{
    mp_int a, b, product;
    mp_err err;
    int capacity = 0;
    char *text = NULL;
    int result = EXIT_FAILURE;
    err = mp_init_multi(&a, &b, &product, NULL);
    if (err != MP_OKAY) {
        fprintf(stderr, "LibTomMath initialization: %s\n", mp_error_to_string(err));
        return result;
    }
    err = mp_read_radix(&a, "123456789012345678901234567890", 10);
    if (err != MP_OKAY) goto done;
    err = mp_read_radix(&b, "987654321098765432109876543210", 10);
    if (err != MP_OKAY) goto done;
    err = mp_mul(&a, &b, &product);
    if (err != MP_OKAY) goto done;
    /* Capacity includes the terminating NUL; a scalar char is not a buffer. */
    err = mp_radix_size(&product, 10, &capacity);
    if (err != MP_OKAY || capacity < 1) goto done;
    text = malloc((size_t)capacity);
    if (text == NULL) { err = MP_MEM; goto done; }
    err = mp_to_decimal(&product, text, (size_t)capacity);
    if (err != MP_OKAY) goto done;
    printf("BigInt product: %s\n", text);
    result = EXIT_SUCCESS;
done:
    if (result != EXIT_SUCCESS) fprintf(stderr, "LibTomMath: %s\n", mp_error_to_string(err));
    free(text);
    mp_clear_multi(&a, &b, &product, NULL);
    return result;
}

static int decimal_example(void)
{
    mpd_context_t ctx;
    mpd_t *x = NULL, *square_root = NULL;
    uint32_t status = 0;
    char *text = NULL;
    char flags[MPD_MAX_FLAG_STRING];
    int result = EXIT_FAILURE;
    /* Quiet API reports status to the caller rather than invoking a trap. */
    mpd_defaultcontext(&ctx);
    ctx.prec = 50;                 /* Significant decimal digits. */
    ctx.round = MPD_ROUND_HALF_EVEN;
    ctx.traps = 0;
    x = mpd_qnew(); square_root = mpd_qnew();
    if (x == NULL || square_root == NULL) { status |= MPD_Malloc_error; goto done; }
    mpd_qset_string(x, "2", &ctx, &status);
    mpd_qsqrt(square_root, x, &ctx, &status);
    if (status & ~(MPD_Rounded | MPD_Inexact)) goto done;
    text = mpd_to_sci(square_root, 1);
    if (text == NULL) { status |= MPD_Malloc_error; goto done; }
    printf("sqrt(2), 50 decimal digits: %s\n", text);
    mpd_snprint_flags(flags, (int)sizeof(flags), status);
    printf("Rounding status: %s\n", flags);
    result = EXIT_SUCCESS;
done:
    if (result != EXIT_SUCCESS) {
        mpd_snprint_flags(flags, (int)sizeof(flags), status);
        fprintf(stderr, "MPDecimal: %s\n", flags);
    }
    if (text != NULL) mpd_free(text);  /* Honors a custom MPDecimal allocator. */
    if (x != NULL) mpd_del(x);
    if (square_root != NULL) mpd_del(square_root);
    return result;
}

int main(void)
{
    if (bigint_example() != EXIT_SUCCESS) return EXIT_FAILURE;
    return decimal_example();
}
