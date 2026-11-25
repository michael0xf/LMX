/* A few baseline consumers through the complete LMX::all link interface.
 * This is a combined-link check, not a whole-archive or complete API test. */
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <curl/curl.h>
#include <sqlite3.h>
#include <zlib.h>
#include <sodium.h>
#include <tommath.h>

int main(void)
{
    sqlite3 *db = NULL;
    sqlite3_stmt *query = NULL;
    mp_int a, b;
    unsigned char digest[crypto_hash_sha256_BYTES];
    assert(curl_version_info(CURLVERSION_NOW) != NULL);
    assert(crc32(0, (const Bytef *)"123456789", 9) == UINT32_C(0xcbf43926));
    assert(sodium_init() >= 0);
    assert(crypto_hash_sha256(digest, (const unsigned char *)"abc", 3) == 0);
    assert(digest[0] == 0xba && digest[1] == 0x78 && digest[31] == 0xad);
    assert(sqlite3_open(":memory:", &db) == SQLITE_OK);
    assert(sqlite3_prepare_v2(db, "SELECT 6 * 7", -1, &query, NULL) == SQLITE_OK);
    assert(sqlite3_step(query) == SQLITE_ROW && sqlite3_column_int(query, 0) == 42);
    assert(sqlite3_finalize(query) == SQLITE_OK);
    assert(sqlite3_close(db) == SQLITE_OK);
    assert(mp_init(&a) == MP_OKAY && mp_init(&b) == MP_OKAY);
    mp_set_i32(&a, 7);
    assert(mp_mul(&a, &a, &b) == MP_OKAY && mp_get_i32(&b) == 49);
    mp_clear(&b); mp_clear(&a);
    puts("PASS: LMX::all with curl, zlib, sodium, SQLite and LibTomMath consumers");
    return 0;
}
