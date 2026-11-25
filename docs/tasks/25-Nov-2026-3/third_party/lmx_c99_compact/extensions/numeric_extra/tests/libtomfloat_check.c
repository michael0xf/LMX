#include <tomfloat.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

#define CHECK(condition) do { if (!(condition)) { \
    fprintf(stderr, "check failed at line %d: %s\n", __LINE__, #condition); \
    exit(1); } } while (0)

static double as_double(const mp_float *a)
{
    return ldexp(mp_get_double(&a->mantissa), (int)a->exp);
}

int main(void)
{
    mp_float a, b, c, d;
    CHECK(mpf_init_multi(256, &a, &b, &c, &d, NULL) == MP_OKAY);
    CHECK(mpf_const_d(&a, 3) == MP_OKAY && mpf_const_d(&b, 1) == MP_OKAY);
    CHECK(mpf_div_2(&b, &b) == MP_OKAY && mpf_mul(&a, &b, &c) == MP_OKAY);
    CHECK(as_double(&c) == 1.5);
    CHECK(mpf_const_d(&a, 2) == MP_OKAY && mpf_sqrt(&a, &b) == MP_OKAY);
    CHECK(mpf_sqr(&b, &c) == MP_OKAY && mpf_sub(&c, &a, &d) == MP_OKAY);
    CHECK(fabs(as_double(&d)) <= 0x1p-200);
    CHECK(mpf_const_d(&a, 1) == MP_OKAY && mpf_const_d(&b, 1) == MP_OKAY);
    b.exp -= 100;
    CHECK(mpf_add(&a, &b, &c) == MP_OKAY && mpf_sub(&c, &a, &d) == MP_OKAY);
    CHECK(mpf_cmp(&b, &d) == MP_EQ && mpf_iszero(&d) == MP_NO);
    CHECK(mpf_const_d(&a, 0) == MP_OKAY && mpf_sqrt(&a, &b) == MP_OKAY);
    CHECK(mpf_iszero(&b) == MP_YES);
#if LONG_MAX > 2147483647L
    CHECK(mpf_const_d(&a, 4294967297L) == MP_OKAY);
    CHECK(as_double(&a) == 4294967297.0);
#endif
    CHECK(mpf_const_d(&a, LONG_MIN) == MP_OKAY);
    CHECK(as_double(&a) == (double)LONG_MIN);
    mpf_clear_multi(&a, &b, &c, &d, NULL);
    puts("PASS: experimental LibTomFloat, 3*0.5=1.5, 256-bit epsilon/sqrt2, sqrt0 and full signed-long fixes");
    return 0;
}
