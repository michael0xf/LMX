#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "webp/encode.h"
#include "webp/decode.h"
#include "webp/demux.h"
#include "webp/mux.h"
#define CHECK(c) do { if (!(c)) { fprintf(stderr, "WebP check failed at %d: %s\n", __LINE__, #c); return 1; } } while (0)
int main(void)
{
    uint8_t pixels[8 * 8 * 4], *encoded = NULL, *decoded;
    const uint8_t metadata[] = { 'L', 'M', 'X', ':', 'C', '9', '9' };
    WebPData image, exif, assembled, extracted;
    WebPMux *mux;
    WebPDemuxer *demux;
    WebPChunkIterator chunk;
    size_t length;
    int i, width, height;
    for (i = 0; i < 64; ++i) {
        pixels[4 * i] = (uint8_t)(i * 3);
        pixels[4 * i + 1] = (uint8_t)(255 - i * 2);
        pixels[4 * i + 2] = (uint8_t)(i * 7);
        pixels[4 * i + 3] = 255;
    }
    length = WebPEncodeLosslessRGBA(pixels, 8, 8, 8 * 4, &encoded);
    CHECK(length > 0 && encoded);
    decoded = WebPDecodeRGBA(encoded, length, &width, &height);
    CHECK(decoded && width == 8 && height == 8);
    CHECK(memcmp(decoded, pixels, sizeof(pixels)) == 0);
    WebPFree(decoded);
    image.bytes = encoded; image.size = length;
    exif.bytes = metadata; exif.size = sizeof(metadata);
    mux = WebPMuxNew(); CHECK(mux);
    CHECK(WebPMuxSetImage(mux, &image, 1) == WEBP_MUX_OK);
    CHECK(WebPMuxSetChunk(mux, "EXIF", &exif, 1) == WEBP_MUX_OK);
    WebPDataInit(&assembled);
    CHECK(WebPMuxAssemble(mux, &assembled) == WEBP_MUX_OK);
    CHECK(WebPMuxGetChunk(mux, "EXIF", &extracted) == WEBP_MUX_OK);
    CHECK(extracted.size == sizeof(metadata) && memcmp(extracted.bytes, metadata, sizeof(metadata)) == 0);
    demux = WebPDemux(&assembled); CHECK(demux);
    CHECK(WebPDemuxGetI(demux, WEBP_FF_CANVAS_WIDTH) == 8);
    CHECK(WebPDemuxGetI(demux, WEBP_FF_CANVAS_HEIGHT) == 8);
    CHECK(WebPDemuxGetI(demux, WEBP_FF_FRAME_COUNT) == 1);
    CHECK(WebPDemuxGetChunk(demux, "EXIF", 1, &chunk));
    CHECK(chunk.chunk.size == sizeof(metadata) && memcmp(chunk.chunk.bytes, metadata, sizeof(metadata)) == 0);
    WebPDemuxReleaseChunkIterator(&chunk);
    decoded = WebPDecodeRGBA(assembled.bytes, assembled.size, &width, &height);
    CHECK(decoded && memcmp(decoded, pixels, sizeof(pixels)) == 0);
    WebPFree(decoded); WebPDemuxDelete(demux); WebPMuxDelete(mux);
    WebPDataClear(&assembled); WebPFree(encoded);
    puts("WebP: exact lossless RGBA, mux EXIF, demux metadata and decoded pixels OK");
    return 0;
}
