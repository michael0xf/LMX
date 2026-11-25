#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
uint64_t lmx_test_hash_legacy(const void *bytes, size_t length);
uint64_t lmx_test_hash_modern(const void *bytes, size_t length);
int main(void)
{
    unsigned char input[4097];
    size_t i;
    for (i = 0; i < sizeof input; ++i) input[i] = (unsigned char)(i * 37u + 11u);
    if (lmx_test_hash_legacy(input, sizeof input) != lmx_test_hash_modern(input, sizeof input)) {
        fputs("XXH64 legacy/modern same-input comparison failed\n", stderr);
        return 1;
    }
    return 0;
}
