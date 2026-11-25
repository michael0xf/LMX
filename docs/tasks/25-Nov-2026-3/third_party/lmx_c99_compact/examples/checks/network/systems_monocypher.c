#include "check.h"
#include <string.h>
#include "monocypher.h"
#include "monocypher-ed25519.h"
int main(void) {
    static const uint8_t expected[64] = {
        0xba,0x80,0xa5,0x3f,0x98,0x1c,0x4d,0x0d,0x6a,0x27,0x97,0xb6,0x9f,0x12,0xf6,0xe9,
        0x4c,0x21,0x2f,0x14,0x68,0x5a,0xc4,0xb7,0x4b,0x12,0xbb,0x6f,0xdb,0xff,0xa2,0xd1,
        0x7d,0x87,0xc5,0x39,0x2a,0xab,0x79,0x2d,0xc2,0x52,0xd5,0xde,0x45,0x33,0xcc,0x95,
        0x18,0xd3,0x8a,0xa8,0xdb,0xf1,0x92,0x5a,0xb9,0x23,0x86,0xed,0xd4,0x00,0x99,0x23};
    uint8_t digest[64], key[32] = {1}, nonce[24] = {2}, mac[16], encrypted[3], plain[3];
    uint8_t seed[32] = {3}, sk[64], pk[32], signature[64]; const uint8_t msg[3] = {'a','b','c'};
    crypto_blake2b(digest, sizeof(digest), msg, sizeof(msg)); CHECK(memcmp(digest, expected, 64) == 0);
    crypto_aead_lock(encrypted, mac, key, nonce, (const uint8_t *)"LMX", 3, msg, sizeof(msg));
    CHECK(crypto_aead_unlock(plain, mac, key, nonce, (const uint8_t *)"LMX", 3, encrypted, 3) == 0);
    CHECK(memcmp(msg, plain, 3) == 0); mac[0] ^= 1;
    CHECK(crypto_aead_unlock(plain, mac, key, nonce, (const uint8_t *)"LMX", 3, encrypted, 3) != 0);
    crypto_ed25519_key_pair(sk, pk, seed); crypto_ed25519_sign(signature, sk, msg, 3);
    CHECK(crypto_ed25519_check(signature, pk, msg, 3) == 0); signature[0] ^= 1;
    CHECK(crypto_ed25519_check(signature, pk, msg, 3) != 0);
    puts("Monocypher BLAKE2b vector, AEAD + Ed25519 roundtrip/tamper: OK"); return 0;
}
