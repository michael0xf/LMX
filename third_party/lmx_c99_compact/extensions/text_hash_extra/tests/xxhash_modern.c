#include <lmx_xxhash_modern.h>
#include <stdio.h>

#define CHECK(expr) do { if (!(expr)) { fprintf(stderr, "check failed at %d: %s\n", __LINE__, #expr); return 1; } } while (0)

int main(void)
{
    unsigned char input[4097];
    size_t i;
    XXH3_state_t *state = XXH3_createState();
    XXH128_hash_t h128, decoded;
    XXH128_canonical_t canonical;
    CHECK(state != NULL);
    CHECK(XXH_versionNumber() == 804);
    CHECK(XXH32("", 0, 0) == UINT32_C(0x02cc5d05));
    CHECK(XXH64("", 0, 0) == UINT64_C(0xef46db3751d8e999));
    for (i = 0; i < sizeof input; ++i) input[i] = (unsigned char)(i * 37u + 11u);
    CHECK(XXH3_64bits_reset_withSeed(state, 123456789) == XXH_OK);
    for (i = 0; i < sizeof input; i += 13) {
        size_t chunk = sizeof input - i < 13 ? sizeof input - i : 13;
        CHECK(XXH3_64bits_update(state, input + i, chunk) == XXH_OK);
    }
    CHECK(XXH3_64bits_digest(state) == XXH3_64bits_withSeed(input, sizeof input, 123456789));
    CHECK(XXH3_128bits_reset(state) == XXH_OK);
    CHECK(XXH3_128bits_update(state, input, 19) == XXH_OK);
    CHECK(XXH3_128bits_update(state, input + 19, sizeof input - 19) == XXH_OK);
    h128 = XXH3_128bits(input, sizeof input);
    CHECK(XXH128_isEqual(h128, XXH3_128bits_digest(state)));
    XXH128_canonicalFromHash(&canonical, h128);
    decoded = XXH128_hashFromCanonical(&canonical);
    CHECK(XXH128_isEqual(h128, decoded));
    CHECK(XXH3_freeState(state) == XXH_OK);
    return 0;
}
