#include <correct.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

int main(void) {
    static const uint8_t message[] = "LMX forward error correction";
    uint8_t block[255], recovered[255];
    const size_t length = sizeof(message) - 1u;
    correct_reed_solomon *rs = correct_reed_solomon_create(
        correct_rs_primitive_polynomial_8_4_3_2_0, 1, 1, 16);
    ssize_t encoded, decoded;
    if (rs == NULL) return 1;
    encoded = correct_reed_solomon_encode(rs, message, length, block);
    if (encoded < 0) { correct_reed_solomon_destroy(rs); return 1; }
    block[1] ^= 0x2bu;
    block[8] ^= 0x6du;
    block[length + 4u] ^= 0x71u;
    decoded = correct_reed_solomon_decode(rs, block, (size_t)encoded, recovered);
    correct_reed_solomon_destroy(rs);
    if (decoded != (ssize_t)length || memcmp(message, recovered, length) != 0) return 1;
    printf("Recovered %lu bytes after three corrupted symbols: %.*s\n",
           (unsigned long)length, (int)length, (const char *)recovered);
    return 0;
}
