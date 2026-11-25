/* Application-owned renderer callbacks only count drawing operations.
 * Checks map data and callback integration, not graphical output or GUI input. */
#include "stb_test_common.h"

static int rectangle_calls;
static int tile_calls;
static void draw_rect(int x0, int y0, int x1, int y1, unsigned int color) {
    (void)x0; (void)y0; (void)x1; (void)y1; (void)color;
    ++rectangle_calls;
}
static void draw_tile(int x, int y, unsigned short tile, int highlight, float *data) {
    (void)x; (void)y; (void)tile; (void)highlight; (void)data;
    ++tile_calls;
}

#define STBTE_DRAW_RECT draw_rect
#define STBTE_DRAW_TILE draw_tile
#define STBTE_MAX_TILEMAP_X 16
#define STBTE_MAX_TILEMAP_Y 16
#define STBTE_MAX_LAYERS 2
#define STBTE_MAX_CATEGORIES 8
#define STBTE_UNDO_BUFFER_BYTES 4096
#define STBTE_MAX_COPY 256
#define STBTE_MAX_PROPERTIES 2
#define STBTE_PROP_TYPE(n, tiledata, params) STBTE_PROP_float
#define STBTE_ALLOW_LINK(src, src_props, dst, dst_props) 1
#define STB_TILEMAP_EDITOR_IMPLEMENTATION
#include <stb_tilemap_editor.h>

int main(void) {
    stbte_tilemap *map = stbte_create_map(8, 8, 2, 16, 16, 4);
    CHECK(map != NULL);
    stbte_define_tile(map, 1, 3, "terrain");
    stbte_define_tile(map, 2, 3, "terrain");
    CHECK(stbte_get_tile(map, 2, 3)[1] == STBTE_EMPTY);
    stbte_set_tile(map, 2, 3, 1, 2);
    CHECK(stbte_get_tile(map, 2, 3)[1] == 2);
    stbte_set_property(map, 2, 3, 0, 7.5f);
    CHECK(stbte_get_properties(map, 2, 3)[0] == 7.5f);
    int width = 0, height = 0;
    stbte_get_dimensions(map, &width, &height);
    CHECK(width == 8 && height == 8);
    stbte_set_display(0, 0, 640, 480);
    stbte_tick(map, 0.016f);
    stbte_draw(map);
    CHECK(rectangle_calls > 0 && tile_calls > 0);
    stbte_clear_map(map);
    CHECK(stbte_get_tile(map, 2, 3)[1] == STBTE_EMPTY);
    /* Cross every inner row boundary, including the final stored cell. */
    stbte_set_dimensions(map, STBTE_MAX_TILEMAP_X, STBTE_MAX_TILEMAP_Y);
    stbte_set_background_tile(map, 1);
    stbte_set_property(map, 15, 15, 1, 9.0f);
    stbte_set_link(map, 15, 15, 0, 0);
    int dx = -1, dy = -1;
    stbte_get_link(map, 15, 15, &dx, &dy);
    CHECK(dx == 0 && dy == 0);
    stbte_clear_map(map);
    for (int y = 0; y < STBTE_MAX_TILEMAP_Y; ++y) {
        for (int x = 0; x < STBTE_MAX_TILEMAP_X; ++x) {
            CHECK(stbte_get_tile(map, x, y)[0] == 1);
            CHECK(stbte_get_tile(map, x, y)[1] == STBTE_EMPTY);
            CHECK(stbte_get_properties(map, x, y)[0] == 0);
            CHECK(stbte_get_properties(map, x, y)[1] == 0);
            stbte_get_link(map, x, y, &dx, &dy);
            CHECK(dx == -1 && dy == -1);
        }
    }
    /* Upstream allocates each tilemap in one malloc block; no destroy API. */
    free(map);
    return EXIT_SUCCESS;
}
