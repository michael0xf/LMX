#include "check.h"
#include <stdlib.h>
#include <string.h>
#include <zstd.h>
int main(void) {
    const size_t n = 1u << 20; size_t bound = ZSTD_compressBound(n), compressed, decoded, i;
    unsigned char *src = malloc(n), *dst = malloc(n), *frame = malloc(bound); ZSTD_CCtx *ctx = ZSTD_createCCtx();
    CHECK(src && dst && frame && ctx);
    for (i = 0; i < n; ++i) src[i] = (unsigned char)((i * 7 + i/521) & 255);
    CHECK(!ZSTD_isError(ZSTD_CCtx_setParameter(ctx, ZSTD_c_compressionLevel, 3)));
    CHECK(!ZSTD_isError(ZSTD_CCtx_setParameter(ctx, ZSTD_c_nbWorkers, 2)));
    compressed = ZSTD_compress2(ctx, frame, bound, src, n); CHECK(!ZSTD_isError(compressed) && compressed < n);
    CHECK(ZSTD_getFrameContentSize(frame, compressed) == n);
    decoded = ZSTD_decompress(dst, n, frame, compressed); CHECK(!ZSTD_isError(decoded) && decoded == n && memcmp(src, dst, n) == 0);
    CHECK(ZSTD_isError(ZSTD_decompress(dst, n, frame, compressed-1)));
    ZSTD_freeCCtx(ctx); free(src); free(dst); free(frame);
    printf("Zstandard %s full amalgamation: threaded compression/decompression + truncated frame rejection: OK\n", ZSTD_versionString()); return 0;
}
