/* 0BSD, see LICENSE.integration. Regression for two different divsufsort APIs. */
#include <divsufsort.h>
#include <zstd.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

int main(void)
{
    static const sauchar_t text[] = "banana";
    static const saidx_t expected[6] = {5, 3, 1, 0, 4, 2};
    saidx_t suffix[6];
    sauchar_t transformed[6];
    uint8_t compressed[128], restored[sizeof(text)];
    size_t size, decoded;
    /* Calling the version function also forces the actual standalone object
       into the executable; a Zstd-internal function cannot impersonate it. */
    if (divsufsort_version() == NULL || divsufsort(text, suffix, 6) != 0 ||
        memcmp(suffix, expected, sizeof(expected)) != 0) return 1;
    if (divbwt(text, transformed, suffix, 6) < 0) return 2;
    size = ZSTD_compress(compressed, sizeof(compressed), text, sizeof(text), 3);
    if (ZSTD_isError(size)) return 3;
    decoded = ZSTD_decompress(restored, sizeof(restored), compressed, size);
    if (ZSTD_isError(decoded) || decoded != sizeof(text) ||
        memcmp(restored, text, sizeof(text))) return 4;
    puts("Standalone suffix sort/BWT and Zstd compression coexist with separate internal symbols: PASS");
    return 0;
}
