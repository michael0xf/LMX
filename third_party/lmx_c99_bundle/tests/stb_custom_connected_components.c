/* Small 8x8 application configuration. Tests topology changes across a wall. */
#include "stb_test_common.h"
#include <string.h>
#define STBCC_GRID_COUNT_X_LOG2 3
#define STBCC_GRID_COUNT_Y_LOG2 3
/* Clusters must have enough edge slots for the packed connection bitsets. */
#define STBCC_CLUSTER_SIZE_X_LOG2 2
#define STBCC_CLUSTER_SIZE_Y_LOG2 2
#define STB_CONNECTED_COMPONENTS_IMPLEMENTATION
#include <stb_connected_components.h>

int main(void) {
    unsigned char cells[8 * 8] = {0};
    for (int y = 0; y < 8; ++y) cells[y * 8 + 3] = 1;
    stbcc_grid *grid = (stbcc_grid *)malloc(stbcc_grid_sizeof());
    CHECK(grid != NULL);
    stbcc_init_grid(grid, cells, 8, 8);
    CHECK(stbcc_query_grid_open(grid, 0, 0));
    CHECK(!stbcc_query_grid_open(grid, 3, 4));
    CHECK(stbcc_query_grid_node_connection(grid, 0, 0, 2, 7));
    CHECK(!stbcc_query_grid_node_connection(grid, 0, 0, 7, 7));
    CHECK(stbcc_get_unique_id(grid, 3, 4) == STBCC_NULL_UNIQUE_ID);
    stbcc_update_grid(grid, 3, 4, 0);
    CHECK(stbcc_query_grid_node_connection(grid, 0, 0, 7, 7));
    CHECK(stbcc_get_unique_id(grid, 0, 0) == stbcc_get_unique_id(grid, 7, 7));
    stbcc_update_grid(grid, 3, 4, 1);
    CHECK(!stbcc_query_grid_node_connection(grid, 0, 0, 7, 7));
    stbcc_update_batch_begin(grid);
    stbcc_update_grid(grid, 3, 2, 0);
    stbcc_update_grid(grid, 3, 5, 0);
    stbcc_update_batch_end(grid);
    CHECK(stbcc_query_grid_node_connection(grid, 0, 0, 7, 7));
    free(grid);
    return EXIT_SUCCESS;
}
