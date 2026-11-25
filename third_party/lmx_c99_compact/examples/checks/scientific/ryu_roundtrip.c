#include <ryu/ryu.h>
#include <fenv.h>
#include <float.h>
#include <limits.h>
#include <locale.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CHECK(expr) do { if(!(expr)) { \
    fprintf(stderr, "check failed at %s:%d: %s\n", __FILE__, __LINE__, #expr); \
    return 1; } } while(0)

static int double_roundtrip(uint64_t bits)
{
    double input, parsed;
    uint64_t result_bits;
    char output[128], *end;
    int count;
    memcpy(&input, &bits, sizeof input);
    memset(output, 0x5a, sizeof output);
    count = d2s_buffered_n(input, output);
    CHECK(count > 0 && count < (int)sizeof output);
    CHECK(output[count] == 0x5a); /* _n writes length bytes, no trailing NUL. */
    output[count] = '\0';
    if(isnan(input)) { CHECK(strcmp(output, "NaN") == 0); return 0; }
    parsed = strtod(output, &end);
    CHECK(end == output + count);
    memcpy(&result_bits, &parsed, sizeof result_bits);
    CHECK(result_bits == bits); /* Includes -0, infinities and subnormals. */
    return 0;
}

static int float_roundtrip(uint32_t bits)
{
    float input, parsed;
    uint32_t result_bits;
    char output[128], *end;
    int count;
    memcpy(&input, &bits, sizeof input);
    memset(output, 0x5a, sizeof output);
    count = f2s_buffered_n(input, output);
    CHECK(count > 0 && count < (int)sizeof output);
    CHECK(output[count] == 0x5a);
    output[count] = '\0';
    if(isnan(input)) { CHECK(strcmp(output, "NaN") == 0); return 0; }
    parsed = strtof(output, &end);
    CHECK(end == output + count);
    memcpy(&result_bits, &parsed, sizeof result_bits);
    CHECK(result_bits == bits);
    return 0;
}

static int allocated_buffers(void)
{
    char actual[128];
    {
        char *allocated = d2s(0.1);
        CHECK(allocated != NULL);
        d2s_buffered(0.1, actual);
        CHECK(strcmp(allocated, actual) == 0);
        free(allocated);
        allocated = f2s(0.1f);
        CHECK(allocated != NULL);
        f2s_buffered(0.1f, actual);
        CHECK(strcmp(allocated, actual) == 0);
        free(allocated);
    }
    return 0;
}

static int fixed_scientific(void)
{
    const double values[] = {0.0, -0.0, 0.125, -1.5, 1.25, 2.5, 3.5,
        0.1, 1e20, 1e-20, DBL_MIN, DBL_MAX};
    const unsigned precisions[] = {0, 1, 6, 17, 40};
    char expected[1024], actual[1024];
    size_t i, j;
    for(i = 0; i < sizeof values / sizeof values[0]; ++i) {
        for(j = 0; j < sizeof precisions / sizeof precisions[0]; ++j) {
            int count = snprintf(expected, sizeof expected, "%.*f", (int)precisions[j], values[i]);
            CHECK(count >= 0 && count < (int)sizeof expected);
            d2fixed_buffered(values[i], precisions[j], actual);
            CHECK(strcmp(expected, actual) == 0);
            count = snprintf(expected, sizeof expected, "%.*e", (int)precisions[j], values[i]);
            CHECK(count >= 0 && count < (int)sizeof expected);
            d2exp_buffered(values[i], precisions[j], actual);
            CHECK(strcmp(expected, actual) == 0);
        }
    }
    return 0;
}

int main(void)
{
    const uint64_t edges64[] = {
        UINT64_C(0), UINT64_C(0x8000000000000000), UINT64_C(1),
        UINT64_C(0x000fffffffffffff), UINT64_C(0x0010000000000000),
        UINT64_C(0x3fefffffffffffff), UINT64_C(0x3ff0000000000000),
        UINT64_C(0x3ff0000000000001), UINT64_C(0x3fb999999999999a),
        UINT64_C(0x4340000000000000), UINT64_C(0x7fefffffffffffff),
        UINT64_C(0xffefffffffffffff), UINT64_C(0x7ff0000000000000),
        UINT64_C(0xfff0000000000000), UINT64_C(0x7ff8000000000001)
    };
    const uint32_t edges32[] = {
        UINT32_C(0), UINT32_C(0x80000000), UINT32_C(1), UINT32_C(0x007fffff),
        UINT32_C(0x00800000), UINT32_C(0x3f7fffff), UINT32_C(0x3f800000),
        UINT32_C(0x3f800001), UINT32_C(0x3dcccccd), UINT32_C(0x4b800000),
        UINT32_C(0x7f7fffff), UINT32_C(0xff7fffff), UINT32_C(0x7f800000),
        UINT32_C(0xff800000), UINT32_C(0x7fc00001)
    };
    uint64_t state = UINT64_C(0x4c4d585f52595531);
    size_t i;
    CHECK(CHAR_BIT == 8 && sizeof(float) == 4 && sizeof(double) == 8);
    CHECK(FLT_RADIX == 2 && FLT_MANT_DIG == 24 && DBL_MANT_DIG == 53);
    CHECK(setlocale(LC_NUMERIC, "C") != NULL);
    CHECK(fesetround(FE_TONEAREST) == 0);
    for(i = 0; i < sizeof edges64 / sizeof edges64[0]; ++i) CHECK(double_roundtrip(edges64[i]) == 0);
    for(i = 0; i < sizeof edges32 / sizeof edges32[0]; ++i) CHECK(float_roundtrip(edges32[i]) == 0);
    for(i = 0; i < 8192; ++i) {
        state ^= state << 13;
        state ^= state >> 7;
        state ^= state << 17;
        CHECK(double_roundtrip(state) == 0);
        CHECK(float_roundtrip((uint32_t)(state >> 19)) == 0);
    }
    CHECK(allocated_buffers() == 0);
    CHECK(fixed_scientific() == 0);
    puts("Ryu: binary32/binary64 edges + 8192 seeded patterns each, allocating API, fixed/scientific passed");
    return 0;
}
