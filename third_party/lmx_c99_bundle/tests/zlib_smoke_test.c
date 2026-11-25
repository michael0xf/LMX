#include <stdio.h>
#include <string.h>
#include <zlib.h>

#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)

int main(void)
{
    unsigned char input[8192], compressed[9000], output[8192];
    uLongf compressed_size = sizeof(compressed), output_size = sizeof(output);
    size_t i;
    for (i = 0; i < sizeof(input); ++i)
        input[i] = (unsigned char)((i / 19) % 41);
    CHECK(strcmp(ZLIB_VERSION, "1.4") == 0);
    CHECK(strcmp(zlibVersion(), ZLIB_VERSION) == 0);
    CHECK(compress2(compressed, &compressed_size, input, sizeof(input), Z_BEST_COMPRESSION) == Z_OK);
    CHECK(compressed_size < sizeof(input));
    CHECK(uncompress(output, &output_size, compressed, compressed_size) == Z_OK);
    CHECK(output_size == sizeof(input));
    CHECK(memcmp(input, output, sizeof(input)) == 0);
    CHECK(crc32(0, input, sizeof(input)) == crc32(0, output, sizeof(output)));
    compressed[compressed_size - 1] ^= 1;
    output_size = sizeof(output);
    CHECK(uncompress(output, &output_size, compressed, compressed_size) == Z_DATA_ERROR);
    return 0;
}
