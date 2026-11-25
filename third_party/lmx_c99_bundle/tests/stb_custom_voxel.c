/* Mode 1 CPU mesh generation for default/explicit geometry and empty input.
 * Shader strings are returned, not executed; no OpenGL or OS dependency.
 * Other render modes and GPU output are not validated here. */
#include "stb_test_common.h"
#include <string.h>
#define STBVOX_CONFIG_MODE 1
#define STB_VOXEL_RENDER_IMPLEMENTATION
#include <stb_voxel_render.h>

int main(void) {
    stbvox_mesh_maker maker;
    stbvox_init_mesh_maker(&maker);
    CHECK(stbvox_get_buffer_count(&maker) == 2);
    CHECK(stbvox_get_buffer_size_per_quad(&maker, 0) == 16);
    CHECK(stbvox_get_buffer_size_per_quad(&maker, 1) == 4);

    /* Padding supplies the six neighboring cells that the mesher reads.
     * Z is contiguous, Y stride is 3, X stride is 9. */
    unsigned char blocks[27] = {0};
    blocks[1 * 9 + 1 * 3 + 1] = 1;
    stbvox_uint32 vertices[4 * 128];
    stbvox_uint32 faces[128];
    stbvox_input_description *input = stbvox_get_input_description(&maker);
    memset(input, 0, sizeof(*input));
    input->blocktype = blocks;
    stbvox_set_input_stride(&maker, 9, 3);
    stbvox_set_input_range(&maker, 1, 1, 1, 2, 2, 2);
    stbvox_set_buffer(&maker, 0, 0, vertices, sizeof(vertices));
    stbvox_set_buffer(&maker, 0, 1, faces, sizeof(faces));
    CHECK(stbvox_make_mesh(&maker) == 1);
    CHECK(stbvox_get_quad_count(&maker, 0) == 6);
    CHECK(stbvox_get_vertex_shader() != NULL && strlen(stbvox_get_vertex_shader()) > 0);
    CHECK(stbvox_get_fragment_shader() != NULL && strlen(stbvox_get_fragment_shader()) > 0);

    /* Explicit geometry takes a separate [6][4] vertex-table path. */
    unsigned char geometry[256] = {0};
    geometry[1] = STBVOX_GEOM_solid;
    input->block_geometry = geometry;
    stbvox_reset_buffers(&maker);
    stbvox_set_buffer(&maker, 0, 0, vertices, sizeof(vertices));
    stbvox_set_buffer(&maker, 0, 1, faces, sizeof(faces));
    stbvox_set_input_range(&maker, 1, 1, 1, 2, 2, 2);
    CHECK(stbvox_make_mesh(&maker) == 1);
    CHECK(stbvox_get_quad_count(&maker, 0) == 6);

    /* Full-height vheight takes the second corrected table initialization. */
    unsigned char heights[27] = {0};
    heights[1 * 9 + 1 * 3 + 1] = STBVOX_MAKE_VHEIGHT(2, 2, 2, 2);
    geometry[1] = STBVOX_GEOM_floor_vheight_03;
    input->vheight = heights;
    stbvox_reset_buffers(&maker);
    stbvox_set_buffer(&maker, 0, 0, vertices, sizeof(vertices));
    stbvox_set_buffer(&maker, 0, 1, faces, sizeof(faces));
    stbvox_set_input_range(&maker, 1, 1, 1, 2, 2, 2);
    CHECK(stbvox_make_mesh(&maker) == 1);
    CHECK(stbvox_get_quad_count(&maker, 0) == 6);

    stbvox_reset_buffers(&maker);
    stbvox_set_buffer(&maker, 0, 0, vertices, sizeof(vertices));
    stbvox_set_buffer(&maker, 0, 1, faces, sizeof(faces));
    blocks[1 * 9 + 1 * 3 + 1] = 0;
    stbvox_set_input_range(&maker, 1, 1, 1, 2, 2, 2);
    CHECK(stbvox_make_mesh(&maker) == 1);
    CHECK(stbvox_get_quad_count(&maker, 0) == 0);
    return EXIT_SUCCESS;
}
