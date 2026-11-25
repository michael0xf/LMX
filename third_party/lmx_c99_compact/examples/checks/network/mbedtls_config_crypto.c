#include <mbedtls/build_info.h>
#include <mbedtls/version.h>
#include <mbedtls/sha256.h>
#include <mbedtls/des.h>
#include <psa/crypto.h>
#include <stdio.h>
#include <string.h>

#if !defined(MBEDTLS_THREADING_C) || !defined(MBEDTLS_THREADING_PTHREAD)
#error "The shared server/client Mbed TLS build must be thread safe."
#endif
#if !defined(MBEDTLS_DES_C)
#error "The pinned curl NTLM configuration requires the DES module."
#endif

#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)

int main(void)
{
    static const unsigned char sha_expected[32] = {
        0xba,0x78,0x16,0xbf,0x8f,0x01,0xcf,0xea,0x41,0x41,0x40,0xde,0x5d,0xae,0x22,0x23,
        0xb0,0x03,0x61,0xa3,0x96,0x17,0x7a,0x9c,0xb4,0x10,0xff,0x61,0xf2,0x00,0x15,0xad
    };
    static const unsigned char des_key[8] = {0x13,0x34,0x57,0x79,0x9b,0xbc,0xdf,0xf1};
    static const unsigned char des_plain[8] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef};
    static const unsigned char des_expected[8] = {0x85,0xe8,0x13,0x54,0x0f,0x0a,0xb4,0x05};
    unsigned char digest[32], encrypted[8];
    mbedtls_des_context des;
    char version[18];
    CHECK(mbedtls_version_get_number() == 0x03060700u);
    mbedtls_version_get_string_full(version);
    CHECK(psa_crypto_init() == PSA_SUCCESS);
    CHECK(mbedtls_sha256((const unsigned char *)"abc", 3, digest, 0) == 0);
    CHECK(memcmp(digest, sha_expected, sizeof(digest)) == 0);
    mbedtls_des_init(&des);
    CHECK(mbedtls_des_setkey_enc(&des, des_key) == 0);
    CHECK(mbedtls_des_crypt_ecb(&des, des_plain, encrypted) == 0);
    CHECK(memcmp(encrypted, des_expected, sizeof(encrypted)) == 0);
    mbedtls_des_free(&des);
    printf("%s: SHA-256, DES ABI and threaded configuration verified\n", version);
    return 0;
}
