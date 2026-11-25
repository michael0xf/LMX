/* Generates CPU-side vertices and checks text metrics; no graphics API. */
#include "stb_test_common.h"
#include <stb_easy_font.h>

struct font_vertex {
    float x, y, z;
    unsigned char color[4];
};

int main(void) {
    struct font_vertex vertices[512];
    unsigned char color[4] = {10, 20, 30, 255};
    char text[] = "LMX";
    char two_lines[] = "LMX\nC99";
    CHECK(sizeof(struct font_vertex) == 16);
    CHECK(stb_easy_font_width(text) > 0);
    CHECK(stb_easy_font_height(text) == 12);
    CHECK(stb_easy_font_height(two_lines) == 24);
    int quads = stb_easy_font_print(2.0f, 3.0f, text, color, vertices, (int)sizeof(vertices));
    CHECK(quads > 0 && quads * 4 <= 512);
    for (int i = 0; i < quads * 4; ++i) {
        CHECK(vertices[i].z == 0.0f);
        CHECK(vertices[i].color[0] == 10 && vertices[i].color[3] == 255);
    }
    int original_width = stb_easy_font_width(text);
    stb_easy_font_spacing(1.0f);
    CHECK(stb_easy_font_width(text) > original_width);
    stb_easy_font_spacing(0.0f);
    return EXIT_SUCCESS;
}
