#include <divsufsort.h>
#include <divsufsort64.h>
#include <stdio.h>
#include <string.h>

#define CHECK(expr) do { if (!(expr)) { fprintf(stderr, "check failed at %d: %s\n", __LINE__, #expr); return 1; } } while (0)

int main(void)
{
    const sauchar_t text[] = "banana";
    const sauchar_t query[] = "ana";
    const saidx_t expected[] = { 5, 3, 1, 0, 4, 2 };
    saidx_t sa[6], left, primary;
    saidx64_t sa64[6], left64, primary64;
    sauchar_t bwt[6], original[6];
    size_t i;
    CHECK(divsufsort(text, sa, 6) == 0);
    CHECK(sufcheck(text, sa, 6, 0) == 0);
    for (i = 0; i < 6; ++i) CHECK(sa[i] == expected[i]);
    CHECK(sa_search(text, 6, query, 3, sa, 6, &left) == 2);
    CHECK(left == 1);
    CHECK(sa_simplesearch(text, 6, sa, 6, 'n', &left) == 2);
    CHECK(bw_transform(text, bwt, sa, 6, &primary) == 0);
    CHECK(inverse_bw_transform(bwt, original, NULL, 6, primary) == 0);
    CHECK(memcmp(text, original, 6) == 0);
    primary = divbwt(text, bwt, NULL, 6);
    CHECK(primary > 0);
    CHECK(inverse_bw_transform(bwt, original, NULL, 6, primary) == 0);
    CHECK(memcmp(text, original, 6) == 0);
    CHECK(divsufsort64(text, sa64, 6) == 0);
    CHECK(sufcheck64(text, sa64, 6, 0) == 0);
    for (i = 0; i < 6; ++i) CHECK(sa64[i] == expected[i]);
    CHECK(sa_search64(text, 6, query, 3, sa64, 6, &left64) == 2);
    CHECK(left64 == 1);
    primary64 = divbwt64(text, bwt, NULL, 6);
    CHECK(primary64 > 0);
    CHECK(inverse_bw_transform64(bwt, original, NULL, 6, primary64) == 0);
    CHECK(memcmp(text, original, 6) == 0);
    CHECK(divsufsort(NULL, sa, 6) == -1);
    CHECK(divsufsort_version() != NULL && divsufsort64_version() != NULL);
    return 0;
}
