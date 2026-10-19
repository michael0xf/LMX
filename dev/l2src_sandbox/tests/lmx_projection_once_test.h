#include "lmx_shared_fields_test.h"

static int projection_writes;
static void projection_native_marker(void) { }
static void *projection_intptr_read(void *cell) { return *(int **)cell; }
static int projection_intptr_write(void *cell, void *value)
{
    ++projection_writes;
    *(int **)cell = value;
    return 0;
}

static int projection_once_test(void)
{
    LmxArena arena;
    LmxCopyMap footprint, projection;
    Lmx *root;
    LmxArray *pointers, *numbers;
    int *a, *b, *c;
    void *p, *q, *cell;
    size_t i;
    memset(&arena, 0, sizeof arena);
    CHECK(lmx_arena_open(&arena) == 0);
    CHECK(lmx_copy_map_init(&footprint) == 0);
    CHECK(lmx_copy_map_init(&projection) == 0);
    root = lmx_node_new_owned(&arena);
    CHECK(root != NULL);
    if (!root) goto done;
    CHECK(lmx_arena_refs_open_owned(&arena, root, 6) == 0);
    a = lmx_int_new_owned(&arena); b = lmx_int_new_owned(&arena); c = lmx_int_new_owned(&arena);
    CHECK(a && b && c);
    if (!a || !b || !c) goto done;
    *a = 11; *b = 23; *c = 37;
    p = lmx_pointer_new_typed_profiled(LMX_TYPE_POINTER_BASE + 4099, &arena, NULL,
        sizeof(int *), projection_intptr_read, projection_intptr_write);
    q = lmx_pointer_new_typed_profiled(LMX_TYPE_POINTER_BASE + 4099, &arena, NULL,
        sizeof(int *), projection_intptr_read, projection_intptr_write);
    pointers = lmx_array_new_typed_profiled(LMX_TYPE_ARRAY_OF_POINTER_BASE + 4099, 2,
        &arena, NULL, sizeof(int *), projection_intptr_read, projection_intptr_write);
    numbers = lmx_array_new_owned(LMX_TYPE_ARRAY_OF_INT, 2, &arena);
    CHECK(p && q && pointers && numbers);
    if (!p || !q || !pointers || !numbers) goto done;
    *(int **)p = a; *(int **)q = b;
    *(int **)lmx_graph_cell_in(&arena, pointers, 0) = a;
    *(int **)lmx_graph_cell_in(&arena, pointers, 1) = b;
    *(int *)lmx_graph_cell_in(&arena, numbers, 0) = 17;
    *(int *)lmx_graph_cell_in(&arena, numbers, 1) = 19;
    CHECK(lmx_arena_ref_store(root, 0, a) == 0 && lmx_arena_ref_store(root, 1, b) == 0);
    CHECK(lmx_arena_ref_store(root, 2, p) == 0 && lmx_arena_ref_store(root, 3, q) == 0);
    CHECK(lmx_arena_ref_store(root, 4, pointers) == 0 && lmx_arena_ref_store(root, 5, numbers) == 0);
    root->native = projection_native_marker;
    CHECK(lmx_copy_map_put(&projection, a, b) == 0);
    CHECK(lmx_copy_map_put(&projection, b, c) == 0);
    CHECK(lmx_copy_map_put(&footprint, root, root) == 0);
    for (i = 0; i < 6; ++i) {
        cell = lmx_graph_cell_in(&arena, root, i);
        CHECK(lmx_copy_map_put(&footprint, cell, cell) == 0);
    }
    CHECK(lmx_copy_map_put(&footprint, p, p) == 0 && lmx_copy_map_put(&footprint, q, q) == 0);
    CHECK(lmx_copy_map_put(&footprint, pointers, pointers) == 0);
    CHECK(lmx_copy_map_put(&footprint, numbers, numbers) == 0);
    for (i = 0; i < 2; ++i) {
        cell = lmx_graph_cell_in(&arena, pointers, i);
        CHECK(lmx_copy_map_put(&footprint, cell, cell) == 0);
    }
    projection_writes = 0;
    CHECK(lmx_graph_copy_project_mapped(&arena, &footprint, &projection, root) == LMX_GRAPH_COPY_OK);
    CHECK(lmx_arena_ref_value(root, 0) == b && lmx_arena_ref_value(root, 1) == c);
    CHECK(*(int **)p == b && *(int **)q == c);
    CHECK(*(int **)lmx_graph_cell_in(&arena, pointers, 0) == b);
    CHECK(*(int **)lmx_graph_cell_in(&arena, pointers, 1) == c);
    CHECK(projection_writes == 4);
    CHECK(*a == 11 && *b == 23 && *c == 37);
    CHECK(*(int *)lmx_graph_cell_in(&arena, numbers, 0) == 17);
    CHECK(*(int *)lmx_graph_cell_in(&arena, numbers, 1) == 19);
    CHECK(root->native == projection_native_marker);
    CHECK(!lmx_pointer_cell_canonical(&arena, p));
done:
    lmx_copy_map_dispose(&footprint);
    lmx_copy_map_dispose(&projection);
    CHECK(lmx_arena_release(&arena) == 0);
    printf("projection_once: %d checks, %d failures\n", checks, failures);
    return failures != 0;
}
