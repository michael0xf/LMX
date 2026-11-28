// Host C99 integer-semantics oracle, NOT an LMX runtime test.
#include <inttypes.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>

static unsigned failures = 0, cases = 0;
static void check(int ok, const char *label, int64_t n) {
    if (!ok) { ++failures; fprintf(stderr, "%s: %" PRId64 "\n", label, n); }
}
#define TEST(T, NAME) \
static void NAME(T n) { \
    T q = n; \
    uint64_t magnitude = n < 0 ? UINT64_C(0) - (uint64_t)n : (uint64_t)n; \
    uint64_t actual = 0, bit = 1, count = magnitude; \
    unsigned bits = 0, ones = 0, squares = 0, multiplies = 0, present = 0; \
    ++cases; \
    while (count) { ++bits; ones += (unsigned)(count & 1); count >>= 1; } \
    if (n == 0 || n == 1) return; \
    while (q != 0) { \
        if (q % 2 != 0) { actual += bit; if (present) ++multiplies; present = 1; } \
        q = q / 2; \
        if (q != 0) { bit *= 2; ++squares; } \
    } \
    check(actual == magnitude, #NAME " magnitude", (int64_t)n); \
    check(squares == bits - 1, #NAME " square count", (int64_t)n); \
    check(multiplies == ones - 1, #NAME " accumulation count", (int64_t)n); \
}
TEST(int32_t, verify32)
TEST(int64_t, verify64)

int main(void) {
    const int32_t a[] = {INT32_MIN,INT32_MIN+1,-129,-128,-127,-5,-3,-2,-1,0,1,2,3,5,127,128,129,INT32_MAX};
    const int64_t b[] = {INT64_MIN,INT64_MIN+1,-129,-128,-127,-5,-3,-2,-1,0,1,2,3,5,127,128,129,INT64_MAX};
    for (size_t i=0;i<sizeof a/sizeof *a;++i) verify32(a[i]);
    for (size_t i=0;i<sizeof b/sizeof *b;++i) verify64(b[i]);
    for (int32_t i=-10000;i<=10000;++i) verify32(i);
    printf("{\"mode\":\"HOST_C99_INTEGER_ORACLE_NOT_LMX\",\"cases\":%u,\"failures\":%u,\"int_bits\":%u}\n",
           cases,failures,(unsigned)(sizeof(int)*CHAR_BIT));
    return failures != 0;
}
