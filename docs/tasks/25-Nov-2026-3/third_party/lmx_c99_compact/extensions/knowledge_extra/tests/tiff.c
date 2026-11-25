#include <tiffio.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "TIFF check failed at %d: %s\n", __LINE__, #x); exit(1); } } while (0)
static void roundtrip(const char *mode, uint16_t compression)
{
    static const char path[] = "knowledge_extra_roundtrip.tif";
    const uint8_t samples[12] = {0,1,255,12,41,99,128,3,200,9,17,64};
    const char description[] = "LMX offline scientific image";
    TIFF *t = TIFFOpen(path, mode);
    uint32_t row, width = 0, height = 0;
    char *read_description = NULL;
    CHECK(t);
    CHECK(TIFFSetField(t, TIFFTAG_IMAGEWIDTH, 4));
    CHECK(TIFFSetField(t, TIFFTAG_IMAGELENGTH, 3));
    CHECK(TIFFSetField(t, TIFFTAG_BITSPERSAMPLE, 8));
    CHECK(TIFFSetField(t, TIFFTAG_SAMPLESPERPIXEL, 1));
    CHECK(TIFFSetField(t, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_MINISBLACK));
    CHECK(TIFFSetField(t, TIFFTAG_PLANARCONFIG, PLANARCONFIG_CONTIG));
    CHECK(TIFFSetField(t, TIFFTAG_ROWSPERSTRIP, 2));
    CHECK(TIFFSetField(t, TIFFTAG_COMPRESSION, compression));
    if (compression == COMPRESSION_LZW || compression == COMPRESSION_ADOBE_DEFLATE ||
        compression == COMPRESSION_DEFLATE)
        CHECK(TIFFSetField(t, TIFFTAG_PREDICTOR, PREDICTOR_HORIZONTAL));
    CHECK(TIFFSetField(t, TIFFTAG_IMAGEDESCRIPTION, description));
    for (row=0; row<3; ++row) CHECK(TIFFWriteScanline(t, (void *)(samples+row*4), row, 0) == 1);
    TIFFClose(t);
    t = TIFFOpen(path, "r"); CHECK(t);
    CHECK(TIFFGetField(t, TIFFTAG_IMAGEWIDTH, &width) && width == 4);
    CHECK(TIFFGetField(t, TIFFTAG_IMAGELENGTH, &height) && height == 3);
    CHECK(TIFFGetField(t, TIFFTAG_IMAGEDESCRIPTION, &read_description));
    CHECK(strcmp(read_description, description) == 0);
    CHECK(TIFFIsBigTIFF(t) == (strchr(mode, '8') != NULL));
    for (row=0; row<3; ++row) {
        uint8_t read_samples[4];
        CHECK(TIFFReadScanline(t, read_samples, row, 0) == 1);
        CHECK(memcmp(read_samples, samples+row*4, 4) == 0);
    }
    TIFFClose(t); CHECK(remove(path) == 0);
}
int main(void)
{
    const char *modes[] = {"wl", "wb", "w8l", "w8b"};
    const uint16_t codecs[] = {COMPRESSION_NONE, COMPRESSION_LZW, COMPRESSION_PACKBITS,
                              COMPRESSION_ADOBE_DEFLATE, COMPRESSION_DEFLATE};
    size_t a,b;
    for (a=0; a<sizeof(modes)/sizeof(modes[0]); ++a)
        for (b=0; b<sizeof(codecs)/sizeof(codecs[0]); ++b) roundtrip(modes[a], codecs[b]);
    return 0;
}
