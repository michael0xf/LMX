#include "check.h"
#include <stdlib.h>
#include <string.h>
#include "lz4.h"
#include "lz4hc.h"
#include "lz4frame.h"
int main(void) {
    const char src[] = "LZ4 block and frame roundtrip roundtrip roundtrip";
    char compressed[256], restored[256]; int n; size_t cap, count, input, output, status;
    void *frame; LZ4F_dctx *dctx;
    n = LZ4_compress_HC(src, compressed, sizeof(src), sizeof(compressed), LZ4HC_CLEVEL_DEFAULT); CHECK(n > 0);
    CHECK(LZ4_decompress_safe(compressed, restored, n, sizeof(restored)) == (int)sizeof(src));
    CHECK(memcmp(src, restored, sizeof(src)) == 0);
    CHECK(LZ4_decompress_safe(compressed, restored, n, 2) < 0);
    cap = LZ4F_compressFrameBound(sizeof(src), NULL); frame = malloc(cap); CHECK(frame != NULL);
    count = LZ4F_compressFrame(frame, cap, src, sizeof(src), NULL); CHECK(!LZ4F_isError(count));
    CHECK(!LZ4F_isError(LZ4F_createDecompressionContext(&dctx, LZ4F_VERSION)));
    input = count; output = sizeof(restored); status = LZ4F_decompress(dctx, restored, &output, frame, &input, NULL);
    CHECK(!LZ4F_isError(status) && status == 0 && input == count && output == sizeof(src));
    CHECK(memcmp(src, restored, sizeof(src)) == 0); LZ4F_freeDecompressionContext(dctx); free(frame);
    printf("LZ4 %s HC block/frame roundtrip + undersized output rejection: OK\n", LZ4_versionString()); return 0;
}
