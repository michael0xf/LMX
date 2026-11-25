#include "check.h"
#include <string.h>
#include "zlib.h"
#include "miniz.h"
#ifndef MINIZ_NO_ZLIB_COMPATIBLE_NAMES
#error Miniz zlib aliases must be disabled in every consumer
#endif
int main(void) {
    const char data[] = "LMX ZIP and zlib coexistence test test test";
    unsigned char compressed[256], restored[256]; mz_ulong n = sizeof(compressed), m = sizeof(restored);
    mz_zip_archive w, rd; void *zip = NULL, *entry; size_t zlen = 0, len = 0;
    CHECK(mz_compress(compressed, &n, (const unsigned char *)data, sizeof(data)) == MZ_OK);
    CHECK(mz_uncompress(restored, &m, compressed, n) == MZ_OK && m == sizeof(data));
    CHECK(memcmp(restored, data, sizeof(data)) == 0);
    CHECK(mz_crc32(0, (const unsigned char *)data, sizeof(data)) == crc32(0, (const Bytef *)data, sizeof(data)));
    CHECK(strcmp(zlibVersion(), ZLIB_VERSION) == 0);
    memset(&w, 0, sizeof(w)); memset(&rd, 0, sizeof(rd));
    CHECK(mz_zip_writer_init_heap(&w, 0, 0));
    CHECK(mz_zip_writer_add_mem(&w, "message.txt", data, sizeof(data), MZ_BEST_COMPRESSION));
    CHECK(mz_zip_writer_finalize_heap_archive(&w, &zip, &zlen)); CHECK(mz_zip_writer_end(&w));
    CHECK(mz_zip_reader_init_mem(&rd, zip, zlen, 0));
    entry = mz_zip_reader_extract_to_heap(&rd, 0, &len, 0);
    CHECK(entry != NULL && len == sizeof(data) && memcmp(entry, data, len) == 0);
    mz_free(entry); CHECK(mz_zip_reader_end(&rd)); mz_free(zip);
    puts("miniz deflate + ZIP memory roundtrip, shared TU with zlib: OK"); return 0;
}
