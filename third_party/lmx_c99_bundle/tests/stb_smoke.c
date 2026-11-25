#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "stb_image.h"
#include "stb_image_write.h"
#include "stb_image_resize2.h"
#include "stb_sprintf.h"
#include "stb_ds.h"
#include "stb_rect_pack.h"
#include "stb_c_lexer.h"
#include "stb_divide.h"
#include "stb_perlin.h"
#include "stb_dxt.h"
#include "stb_truetype.h"
#include "stb_include.h"
#include "stb_hexwave.h"
#include "stb_herringbone_wang_tile.h"
#define STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"

#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)

typedef struct { unsigned char *bytes; size_t length; int failed; } Blob;
static void append_bytes(void *context, void *data, int count)
{
    Blob *b = (Blob *)context;
    unsigned char *next;
    if (b->failed || count < 0) { b->failed = 1; return; }
    next = (unsigned char *)realloc(b->bytes, b->length + (size_t)count);
    if (!next) { b->failed = 1; return; }
    b->bytes = next;
    memcpy(b->bytes + b->length, data, (size_t)count);
    b->length += (size_t)count;
}

static int images(void)
{
    unsigned char pixels[4 * 4 * 3], resized[8 * 8 * 3];
    unsigned char *decoded;
    Blob encoded = {0};
    int x, y, components;
    for (size_t i = 0; i < sizeof pixels; ++i) pixels[i] = (unsigned char)(i * 5);
    CHECK(stbi_write_png_to_func(append_bytes, &encoded, 4, 4, 3, pixels, 4 * 3));
    CHECK(!encoded.failed && encoded.length > 8);
    decoded = stbi_load_from_memory(encoded.bytes, (int)encoded.length, &x, &y, &components, 3);
    CHECK(decoded && x == 4 && y == 4 && components == 3);
    CHECK(memcmp(decoded, pixels, sizeof pixels) == 0);
    CHECK(stbir_resize_uint8_linear(decoded, 4, 4, 0, resized, 8, 8, 0, STBIR_RGB) == resized);
    stbi_image_free(decoded);
    free(encoded.bytes);
    return 0;
}

static int containers_and_packing(void)
{
    int *array = NULL;
    struct Pair { int key, value; } *map = NULL;
    stbrp_context context;
    stbrp_node nodes[16];
    stbrp_rect rectangles[3] = {{1, 4, 4, 0, 0, 0}, {2, 6, 3, 0, 0, 0}, {3, 2, 8, 0, 0, 0}};
    for (int i = 0; i < 100; ++i) {
        arrput(array, i);
        hmput(map, i, i * 3);
    }
    CHECK(arrlen(array) == 100 && array[73] == 73);
    for (int key = 0; key < 100; ++key) CHECK(hmget(map, key) == key * 3);
    arrdel(array, 0);
    CHECK(arrlen(array) == 99 && array[0] == 1);
    arrfree(array);
    hmfree(map);
    stbrp_init_target(&context, 16, 16, nodes, 16);
    CHECK(stbrp_pack_rects(&context, rectangles, 3));
    for (int i = 0; i < 3; ++i) {
        CHECK(rectangles[i].was_packed);
        CHECK(rectangles[i].x + rectangles[i].w <= 16);
        CHECK(rectangles[i].y + rectangles[i].h <= 16);
        for (int j = i + 1; j < 3; ++j)
            CHECK(rectangles[i].x + rectangles[i].w <= rectangles[j].x ||
                  rectangles[j].x + rectangles[j].w <= rectangles[i].x ||
                  rectangles[i].y + rectangles[i].h <= rectangles[j].y ||
                  rectangles[j].y + rectangles[j].h <= rectangles[i].y);
    }
    return 0;
}

static int parsing_and_math(void)
{
    stb_lexer lexer;
    char storage[128], formatted[128], error[256];
    const char *input = "answer = 42;";
    char *expanded;
    stb_c_lexer_init(&lexer, input, NULL, storage, (int)sizeof storage);
    CHECK(stb_c_lexer_get_token(&lexer) && lexer.token == CLEX_id && strcmp(lexer.string, "answer") == 0);
    CHECK(stb_c_lexer_get_token(&lexer) && lexer.token == '=');
    CHECK(stb_c_lexer_get_token(&lexer) && lexer.token == CLEX_intlit && lexer.int_number == 42);
    CHECK(stb_c_lexer_get_token(&lexer) && lexer.token == ';');
    /* Upstream default STB_C_LEX_0_IS_EOF=N returns NUL as token zero. */
    CHECK(stb_c_lexer_get_token(&lexer) && lexer.token == 0);
    CHECK(stbsp_snprintf(formatted, (int)sizeof formatted, "%s=%d %.2f", "x", 42, 1.25) > 0);
    CHECK(strcmp(formatted, "x=42 1.25") == 0);
    CHECK(stb_div_floor(-7, 3) == -3 && stb_div_trunc(-7, 3) == -2);
    CHECK(stb_mod_eucl(-7, 3) == 2);
    CHECK(isfinite(stb_perlin_noise3(0.2f, 0.3f, 0.4f, 0, 0, 0)));
    expanded = stb_include_string("before\n#inject\nafter\n", "inserted\n", ".", "test", error);
    CHECK(expanded && strstr(expanded, "inserted") && strstr(expanded, "after"));
    stb_include_free(expanded);
    return 0;
}

static int audio_and_format_validation(void)
{
    HexWave wave;
    float samples[256];
    double energy = 0;
    unsigned char invalid[32] = {0};
    unsigned char rgba[4 * 4 * 4], compressed[16];
    int error = 0;
    hexwave_init(16, 4, NULL);
    hexwave_create(&wave, 1, 0.5f, 0.0f, 0.0f);
    hexwave_generate_samples(samples, 256, &wave, 440.0f / 48000.0f);
    for (int i = 0; i < 256; ++i) { CHECK(isfinite(samples[i])); energy += samples[i] * samples[i]; }
    CHECK(energy > 0);
    hexwave_shutdown(NULL);
    CHECK(stb_vorbis_open_memory(invalid, (int)sizeof invalid, &error, NULL) == NULL);
    CHECK(error != 0);
    CHECK(stbtt_GetNumberOfFonts(invalid) == 0);
    CHECK(stbtt_GetFontOffsetForIndex(invalid, 0) == -1);
    for (int i = 0; i < 16; ++i) {
        rgba[4*i] = 255; rgba[4*i+1] = 0; rgba[4*i+2] = 0; rgba[4*i+3] = 255;
    }
    memset(compressed, 0, sizeof compressed);
    stb_compress_dxt_block(compressed, rgba, 1, STB_DXT_NORMAL);
    CHECK(compressed[0] == 255);
    return 0;
}

static int wang_tiles(void)
{
    stbhw_config config = {0};
    stbhw_tileset tiles = {0};
    unsigned char *image;
    unsigned char output[32 * 32 * 3];
    int width, height;
    config.short_side_len = 4;
    config.num_vary_x = config.num_vary_y = 1;
    for (int i = 0; i < 6; ++i) config.num_color[i] = 1;
    stbhw_get_template_size(&config, &width, &height);
    CHECK(width > 0 && height > 0);
    image = (unsigned char *)malloc((size_t)width * (size_t)height * 3);
    CHECK(image);
    CHECK(stbhw_make_template(&config, image, width, height, width * 3));
    CHECK(stbhw_build_tileset_from_image(&tiles, image, width * 3, width, height));
    CHECK(stbhw_generate_image(&tiles, NULL, output, 32 * 3, 32, 32));
    stbhw_free_tileset(&tiles);
    free(image);
    return 0;
}

int main(void)
{
    CHECK(images() == 0);
    CHECK(containers_and_packing() == 0);
    CHECK(parsing_and_math() == 0);
    CHECK(audio_and_format_validation() == 0);
    CHECK(wang_tiles() == 0);
    return 0;
}
