#include <sodium.h>
#include <stdio.h>
#include <string.h>

#define CHECK(x) do { if (!(x)) { fprintf(stderr, "check failed: %s (%s:%d)\n", #x, __FILE__, __LINE__); return 1; } } while (0)

int main(void)
{
    static const unsigned char text[] = "LMX C99 crypto integration";
    static const unsigned char sha256_abc[32] = {
        0xba,0x78,0x16,0xbf,0x8f,0x01,0xcf,0xea,0x41,0x41,0x40,0xde,0x5d,0xae,0x22,0x23,
        0xb0,0x03,0x61,0xa3,0x96,0x17,0x7a,0x9c,0xb4,0x10,0xff,0x61,0xf2,0x00,0x15,0xad
    };
    unsigned char key[crypto_secretbox_KEYBYTES];
    unsigned char nonce[crypto_secretbox_NONCEBYTES];
    unsigned char encrypted[sizeof(text) + crypto_secretbox_MACBYTES];
    unsigned char opened[sizeof(text)];
    unsigned char hash[crypto_hash_sha256_BYTES];
    unsigned char pk[crypto_sign_PUBLICKEYBYTES], sk[crypto_sign_SECRETKEYBYTES];
    unsigned char signature[crypto_sign_BYTES];
    unsigned long long signature_len = 0;

    CHECK(sodium_init() >= 0);
    CHECK(strcmp(sodium_version_string(), "1.0.22") == 0);
    CHECK(crypto_hash_sha256(hash, (const unsigned char *)"abc", 3) == 0);
    CHECK(sodium_memcmp(hash, sha256_abc, sizeof(hash)) == 0);

    crypto_secretbox_keygen(key);
    randombytes_buf(nonce, sizeof(nonce));
    CHECK(crypto_secretbox_easy(encrypted, text, sizeof(text), nonce, key) == 0);
    CHECK(crypto_secretbox_open_easy(opened, encrypted, sizeof(encrypted), nonce, key) == 0);
    CHECK(sodium_memcmp(opened, text, sizeof(text)) == 0);
    encrypted[0] ^= 1;
    CHECK(crypto_secretbox_open_easy(opened, encrypted, sizeof(encrypted), nonce, key) == -1);

    CHECK(crypto_sign_keypair(pk, sk) == 0);
    CHECK(crypto_sign_detached(signature, &signature_len, text, sizeof(text), sk) == 0);
    CHECK(signature_len == crypto_sign_BYTES);
    CHECK(crypto_sign_verify_detached(signature, text, sizeof(text), pk) == 0);
    signature[0] ^= 1;
    CHECK(crypto_sign_verify_detached(signature, text, sizeof(text), pk) == -1);
    sodium_memzero(key, sizeof(key));
    sodium_memzero(sk, sizeof(sk));
    return 0;
}
