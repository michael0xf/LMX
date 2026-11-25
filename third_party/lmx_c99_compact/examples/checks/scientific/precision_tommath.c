#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tommath.h"

static int same_decimal(const mp_int *value, const char *expected)
{
    int size = 0;
    char *text;
    int equal;
    if (mp_radix_size(value, 10, &size) != MP_OKAY || size < 1) return 0;
    text = malloc((size_t)size);
    if (text == NULL) return 0;
    if (mp_to_decimal(value, text, (size_t)size) != MP_OKAY) {
        free(text);
        return 0;
    }
    equal = strcmp(text, expected) == 0;
    if (!equal) fprintf(stderr, "Expected %s, got %s\n", expected, text);
    free(text);
    return equal;
}

int main(void)
{
    mp_int a, b, product, quotient, remainder;
    char input[1001];
    char expected[2001];
    char tiny[2];
    int rc = EXIT_FAILURE;
    if (mp_init_multi(&a, &b, &product, &quotient, &remainder, NULL) != MP_OKAY) return rc;
    if (mp_read_radix(&a, "123456789012345678901234567890", 10) != MP_OKAY ||
        mp_read_radix(&b, "987654321098765432109876543210", 10) != MP_OKAY ||
        mp_mul(&a, &b, &product) != MP_OKAY) goto done;
    if (!same_decimal(&product,
        "121932631137021795226185032733622923332237463801111263526900")) goto done;
    if (mp_div(&product, &a, &quotient, &remainder) != MP_OKAY ||
        mp_cmp(&quotient, &b) != MP_EQ || !mp_iszero(&remainder)) goto done;
    if (mp_to_decimal(&product, tiny, sizeof(tiny)) != MP_BUF) goto done;

    /* Known decimal form of (10^1000 - 1)^2 exercises large-integer paths. */
    memset(input, '9', sizeof(input) - 1);
    input[1000] = '\0';
    memset(expected, '9', 999);
    expected[999] = '8';
    memset(expected + 1000, '0', 999);
    expected[1999] = '1';
    expected[2000] = '\0';
    if (mp_read_radix(&a, input, 10) != MP_OKAY ||
        mp_sqr(&a, &product) != MP_OKAY || !same_decimal(&product, expected)) goto done;
    if (mp_sqrt(&product, &quotient) != MP_OKAY || mp_cmp(&quotient, &a) != MP_EQ) goto done;
    puts("LibTomMath: exact product, division, buffer error, 1000-digit square/root passed");
    rc = EXIT_SUCCESS;
done:
    mp_clear_multi(&a, &b, &product, &quotient, &remainder, NULL);
    return rc;
}
