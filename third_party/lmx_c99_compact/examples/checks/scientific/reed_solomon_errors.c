#include <correct.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define CHECK(c) do { if (!(c)) { \
    fprintf(stderr, "RS check failed at line %d: %s\n", __LINE__, #c); \
    return 1; } } while (0)

static void damage(uint8_t *block, size_t position, unsigned int index) {
    block[position] ^= (uint8_t)(1u + ((index * 29u + 13u) % 255u));
}

int main(void) {
    uint8_t message[223], encoded[255], damaged[255], recovered[255];
    uint8_t erasures[20];
    size_t i;
    ssize_t result;
    correct_reed_solomon *rs = correct_reed_solomon_create(
        correct_rs_primitive_polynomial_8_4_3_2_0, 1, 1, 32);
    CHECK(rs != NULL);
    for (i = 0; i < sizeof(message); ++i)
        message[i] = (uint8_t)(i * 37u + 11u);

    CHECK(correct_reed_solomon_encode(rs, message, sizeof(message), encoded) == 255);
    CHECK(correct_reed_solomon_decode(rs, encoded, 255, recovered) == 223);
    CHECK(memcmp(message, recovered, sizeof(message)) == 0);

    /* RS(255,223): 32 parity bytes correct 16 distinct unknown byte errors. */
    memcpy(damaged, encoded, sizeof(encoded));
    for (i = 0; i < 16; ++i) damage(damaged, (i * 13u + 5u) % 255u, (unsigned int)i);
    CHECK(correct_reed_solomon_decode(rs, damaged, 255, recovered) == 223);
    CHECK(memcmp(message, recovered, sizeof(message)) == 0);

    /* 20 erasures + four unknown errors: 20 + 2*4 < 32. */
    memcpy(damaged, encoded, sizeof(encoded));
    for (i = 0; i < 20; ++i) {
        erasures[i] = (uint8_t)(i * 7u);
        damage(damaged, erasures[i], (unsigned int)i);
    }
    for (i = 0; i < 4; ++i) damage(damaged, 180u + i * 11u, (unsigned int)(i + 20u));
    CHECK(correct_reed_solomon_decode_with_erasures(
        rs, damaged, 255, erasures, 20, recovered) == 223);
    CHECK(memcmp(message, recovered, sizeof(message)) == 0);

    /* A deterministic beyond-capacity fixture. This is not a promise that
       every larger corruption is detectable; application integrity is separate. */
    memcpy(damaged, encoded, sizeof(encoded));
    for (i = 0; i < 24; ++i) damage(damaged, (i * 7u + 1u) % 255u, (unsigned int)i);
    result = correct_reed_solomon_decode(rs, damaged, 255, recovered);
    CHECK(result == -1);

    /* Shortened block, plus an overlapping input/output encode/decode. */
    memcpy(encoded, message, 67);
    CHECK(correct_reed_solomon_encode(rs, encoded, 67, encoded) == 99);
    for (i = 0; i < 8; ++i) damage(encoded, i * 11u, (unsigned int)i);
    CHECK(correct_reed_solomon_decode(rs, encoded, 99, encoded) == 67);
    CHECK(memcmp(message, encoded, 67) == 0);
    correct_reed_solomon_destroy(rs);
    puts("RS: 16 errors, 20 erasures + 4 errors, shortened/in-place block recovered; 24-error fixture rejected");
    return 0;
}
