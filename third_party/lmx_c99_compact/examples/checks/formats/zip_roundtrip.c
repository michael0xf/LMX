#include "check.h"
#include <stdlib.h>
#include <string.h>
#include <kuba_zip/zip.h>
#ifdef LMX_TEST_SHARED_MINIZ_ZLIB
#include <zlib.h>
#include <miniz.h>
#endif
int main(void) {
    const char message[] = "LMX zip, miniz and zlib can coexist";
    struct zip_t *w, *rd; void *data = NULL, *entry = NULL; size_t length = 0, n = 0;
    w = zip_stream_open(NULL, 0, ZIP_DEFAULT_COMPRESSION_LEVEL, 'w'); CHECK(w != NULL);
    CHECK(zip_entry_open(w, "message.txt") == 0);
    CHECK(zip_entry_write(w, message, sizeof(message)) == 0); CHECK(zip_entry_close(w) == 0);
    CHECK(zip_stream_copy(w, &data, &length) > 0 && length != 0); zip_stream_close(w);
    rd = zip_stream_open((const char *)data, length, 0, 'r'); CHECK(rd != NULL);
    CHECK(zip_entries_total(rd) == 1 && zip_entry_open(rd, "message.txt") == 0);
    CHECK(zip_entry_size(rd) == sizeof(message));
    CHECK(zip_entry_read(rd, &entry, &n) == (ssize_t)sizeof(message));
    CHECK(n == sizeof(message) && memcmp(entry, message, n) == 0); free(entry);
    CHECK(zip_entry_close(rd) == 0); CHECK(zip_entry_open(rd, "missing") < 0);
    zip_stream_close(rd); free(data);
#ifdef LMX_TEST_SHARED_MINIZ_ZLIB
    CHECK(mz_crc32(0, (const unsigned char *)message, sizeof(message)) ==
          crc32(0, (const unsigned char *)message, sizeof(message)));
#endif
    puts("kuba zip memory ZIP creation/extraction/missing-entry + symbol isolation: OK"); return 0;
}
