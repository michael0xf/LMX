#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <libbf.h>
#include <softfloat.h>
#include <fix16.h>
#include <fixmatrix.h>
#include <lmx_fp16.h>
#include <cminpack.h>
#include <imrat.h>

#define CHECK(x) do { if (!(x)) { fprintf(stderr, "FAIL line %d: %s\n", __LINE__, #x); return 1; } } while (0)

static void *allocator(void *context, void *pointer, size_t size)
{
    (void)context;
    if (!size) { free(pointer); return NULL; }
    return realloc(pointer, size);
}

static int root_function(void *context, int count, const double *x, double *f, int flag)
{
    (void)context; (void)flag;
    if (count != 1) return -1;
    f[0] = x[0] * x[0] - 2.0;
    return 0;
}

int main(void)
{
    bf_context_t context;
    bf_t a, b, c, epsilon;
    char *digits;
    size_t length;
    int flags;
    float64_t sf_a, sf_b, sf_c;
    float128_t sf_quad;
    mf16 ma = {0}, mb = {0}, mc = {0};
    mpq_t qa, qb, qc;
    char rational[32];
    double x[1] = {1.0}, residual[1], work[8];
    double common_product;
    int outcome;

    bf_context_init(&context, allocator, NULL);
    bf_init(&context, &a); bf_init(&context, &b);
    bf_init(&context, &c); bf_init(&context, &epsilon);
    CHECK(bf_set_ui(&a, 1) == 0);
    CHECK(bf_set_ui(&epsilon, 1) == 0);
    CHECK(bf_mul_2exp(&epsilon, -100, 256, BF_RNDN) == 0);
    CHECK(bf_add(&b, &a, &epsilon, 256, BF_RNDN) == 0);
    CHECK(bf_sub(&c, &b, &a, 256, BF_RNDN) == 0);
    CHECK(!bf_is_zero(&c) && bf_cmp_eq(&c, &epsilon));
    CHECK(bf_set_ui(&a, 2) == 0);
    flags = bf_sqrt(&b, &a, 256, BF_RNDN);
    CHECK(!(flags & (BF_ST_INVALID_OP | BF_ST_MEM_ERROR)));
    digits = bf_ftoa(&length, &b, 10, 70, BF_RNDN | BF_FTOA_FORMAT_FIXED);
    CHECK(digits && !strncmp(digits, "1.41421356237309504880168872420969807856967187537694807317667973799", 65));
    printf("LibBF sqrt(2), 256 bits: %s\n", digits);
    bf_free(&context, digits);
    /* One small task across independent scalar backends, with exact inputs. */
    CHECK(bf_set_ui(&a, 3) == 0 && bf_set_ui(&b, 1) == 0);
    CHECK(bf_mul_2exp(&b, -1, 256, BF_RNDN) == 0);
    CHECK(bf_mul(&c, &a, &b, 256, BF_RNDN) == 0);
    CHECK(bf_get_float64(&c, &common_product, BF_RNDN) == 0 && common_product == 1.5);
    bf_delete(&epsilon); bf_delete(&c); bf_delete(&b); bf_delete(&a);
    bf_context_end(&context);

    softfloat_roundingMode = softfloat_round_near_even;
    softfloat_exceptionFlags = 0;
    sf_a.v = UINT64_C(0x3ff8000000000000); /* 1.5 */
    sf_b.v = UINT64_C(0x4002000000000000); /* 2.25 */
    sf_c = f64_add(sf_a, sf_b);
    CHECK(sf_c.v == UINT64_C(0x400e000000000000)); /* 3.75 */
    CHECK(!softfloat_exceptionFlags);
    sf_quad = f64_to_f128(sf_c);
    CHECK(f128_to_f64(sf_quad).v == sf_c.v);
    sf_a.v = UINT64_C(0x4008000000000000); /* 3.0 */
    sf_b.v = UINT64_C(0x3fe0000000000000); /* 0.5 */
    CHECK(f64_mul(sf_a, sf_b).v == UINT64_C(0x3ff8000000000000));
    CHECK(fix16_mul(fix16_from_int(3), fix16_from_float(0.5f)) == fix16_from_float(1.5f));
    puts("Same task, LibBF / SoftFloat / libfixmath: 3 * 0.5 = 1.5");
    ma.rows = ma.columns = mb.rows = mb.columns = mc.rows = mc.columns = 2;
    mf16_fill_diagonal(&ma, fix16_from_int(2));
    mf16_fill_diagonal(&mb, fix16_from_int(3));
    mf16_mul(&mc, &ma, &mb);
    CHECK(!mc.errors && mc.data[0][0] == fix16_from_int(6) && mc.data[0][1] == 0);
    CHECK(lmx_fp16_ieee_from_float(1.5f) == UINT16_C(0x3e00));
    CHECK(lmx_fp16_ieee_to_float(UINT16_C(0x3e00)) == 1.5f);
    CHECK(lmx_fp16_alt_to_float(lmx_fp16_alt_from_float(2.5f)) == 2.5f);

    outcome = hybrd1(root_function, NULL, 1, x, residual, 1e-12, work, 8);
    CHECK(outcome == 1 && fabs(x[0] * x[0] - 2.0) < 1e-12);
    printf("CMINPACK root x^2=2: %.15f\n", x[0]);
    CHECK(mp_rat_init(&qa) == MP_OK && mp_rat_init(&qb) == MP_OK && mp_rat_init(&qc) == MP_OK);
    CHECK(mp_rat_set_value(&qa, 1, 3) == MP_OK && mp_rat_set_value(&qb, 1, 6) == MP_OK);
    CHECK(mp_rat_add(&qa, &qb, &qc) == MP_OK);
    CHECK(mp_rat_to_string(&qc, 10, rational, sizeof rational) == MP_OK);
    CHECK(!strcmp(rational, "1/2"));
    mp_rat_clear(&qc); mp_rat_clear(&qb); mp_rat_clear(&qa);
    printf("PASS: 7 numeric libraries; arbitrary real, IEEE formats, fixed-point matrices, half conversion, nonlinear roots, exact rationals\n");
    return 0;
}
