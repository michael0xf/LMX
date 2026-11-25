#include <stdio.h>
#include <stdlib.h>
#include "c99_gsl.h"

#ifdef LMX_MATH_HAS_QUADRATURE
static double sinc_function(double x)
{
    return x == 0.0 ? 1.0 : sin(x) / x;
}
#endif

static int integer_example(void)
{
    mp_int a, b, result;
    mp_err error;
    int capacity = 0;
    char *buffer = NULL;

    error = mp_init_multi(&a, &b, &result, NULL);
    if (error != MP_OKAY) {
        fprintf(stderr, "LibTomMath initialization: %s\n", mp_error_to_string(error));
        return 1;
    }
    error = mp_read_radix(&a, "123456789012345678901234567890", 10);
    if (error != MP_OKAY) goto cleanup;
    error = mp_read_radix(&b, "987654321098765432109876543210", 10);
    if (error != MP_OKAY) goto cleanup;
    error = mp_mul(&a, &b, &result);
    if (error != MP_OKAY) goto cleanup;

    /* The selected version reports the required size, including the NUL. */
    error = mp_radix_size(&result, 10, &capacity);
    if (error != MP_OKAY) goto cleanup;
    if (capacity <= 0 || !(buffer = (char *)malloc((size_t)capacity))) {
        error = MP_MEM;
        goto cleanup;
    }
    error = mp_to_decimal(&result, buffer, (size_t)capacity);
    if (error != MP_OKAY) goto cleanup;
    printf("BigInt product: %s\n", buffer);

cleanup:
    free(buffer);
    mp_clear_multi(&a, &b, &result, NULL);
    if (error != MP_OKAY)
        fprintf(stderr, "LibTomMath: %s\n", mp_error_to_string(error));
    return error == MP_OKAY ? 0 : 1;
}

static int decimal_example(void)
{
    mpd_context_t context;
    mpd_t *x = NULL, *root = NULL;
    uint32_t status = 0;
    char *text = NULL;
    int result = 1;

    mpd_defaultcontext(&context);
    context.prec = 50; /* Decimal significant digits, not binary bits. */
    context.traps = 0;
    x = mpd_qnew();
    root = mpd_qnew();
    if (!x || !root) {
        status |= MPD_Malloc_error;
        goto cleanup;
    }
    mpd_qset_string(x, "2", &context, &status);
    mpd_qsqrt(root, x, &context, &status);
    /* Rounded/Inexact are expected for sqrt(2); real failures are errors. */
    if (status & ~(MPD_Rounded | MPD_Inexact)) goto cleanup;
    text = mpd_to_sci(root, 1);
    if (!text) {
        status |= MPD_Malloc_error;
        goto cleanup;
    }
    printf("Sqrt(2), 50 decimal digits: %s\n", text);
    result = 0;

cleanup:
    if (text) mpd_free(text); /* Matches MPDecimal's configurable allocator. */
    if (x) mpd_del(x);
    if (root) mpd_del(root);
    if (result)
        fprintf(stderr, "MPDecimal failed (status=0x%08lx)\n", (unsigned long)status);
    return result;
}

int main(void)
{
    lmx_rng rng;
    unsigned i;
    if (integer_example() || decimal_example()) return EXIT_FAILURE;

    /* Reproducible numerical PRNG. Use libsodium for secrets and keys. */
    lmx_rng_seed(&rng, UINT64_C(42));
    printf("Seeded uniform samples:");
    for (i = 0; i < 4; ++i)
        printf(" %.17g", c99_gsl_rng_uniform(&rng));
    putchar('\n');
#ifdef LMX_MATH_HAS_QUADRATURE
    {
        double absolute_error;
        int evaluations, status;
        double integral = c99_quad_dqags(sinc_function, 0.0, 10.0,
            1e-10, 1e-10, &absolute_error, &evaluations, &status);
        if (status || !isfinite(integral)) {
            fprintf(stderr, "QUADPACK failed (status=%d)\n", status);
            return EXIT_FAILURE;
        }
        printf("Integral sin(x)/x on [0,10]: %.12f (estimated error %.3g, %d evaluations)\n",
            integral, absolute_error, evaluations);
    }
#endif
    return EXIT_SUCCESS;
}
