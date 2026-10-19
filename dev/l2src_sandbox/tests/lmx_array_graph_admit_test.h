#ifndef LMX_ARRAY_GRAPH_ADMIT_TEST_H
#define LMX_ARRAY_GRAPH_ADMIT_TEST_H
/* Actual graph admission, two-half field maps, Array-backed map frames,
   weak-record retention and cross-arena relocation. No backend proof. */
#include <stdio.h>
#include <string.h>
static int lmx_array_admit_checks, lmx_array_admit_failures;
#define LMX_ARRAY_ADMIT_CHECK(x) do { ++lmx_array_admit_checks; if (!(x)) { ++lmx_array_admit_failures; \
    fprintf(stderr, "FAIL %d: %s\n", __LINE__, #x); } } while (0)
static size_t lmx_array_admit_map[] = {1,0,1,0};
static Lmx *lmx_array_admit_node(LmxArena *arena, Lmx *parent, size_t count) {
    Lmx *node = parent ? lmx_struct_new_owned(parent, arena) : lmx_node_new_owned(arena);
    return node && (!count || !lmx_arena_refs_open_owned(arena, node, count)) ? node : NULL;
}
static int lmx_array_admit_number(LmxArena *arena, Lmx *node, size_t index, int number) {
    void *cell = lmx_int_new_owned(arena);
    return !cell || lmx_int_store_known(cell, number) || lmx_arena_ref_store(node, index, cell);
}

static int lmx_array_graph_admit_test(void) {
    LmxArena arena, target;
    Lmx *root, *model, *frame_model, *outer_a, *outer_b, *outer_model, *plain, *copy = NULL;
    LmxArray *value, *short_value, *char_value, *empty, *frame;
    LmxImplEntry pending;
    LmxImplEntry *record;
    Lmx *new_value, *new_model, *new_frame, *new_frame_model;
    size_t index = (size_t)-1, before;
    int *cell;
    memset(&arena, 0, sizeof arena);
    memset(&target, 0, sizeof target);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_open(&arena) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_open(&target) == 0);
    root = lmx_array_admit_node(&arena, NULL, 4);
    model = lmx_array_admit_node(&arena, root, 2);
    frame_model = lmx_array_admit_node(&arena, root, 2);
    value = lmx_array_new_child_profiled(root, LMX_TYPE_ARRAY_OF_INT, 3, &arena, NULL);
    frame = lmx_array_new_child_profiled(root, LMX_TYPE_ARRAY_OF_SIZE_T, 4, &arena, NULL);
    LMX_ARRAY_ADMIT_CHECK(root && model && frame_model && value && frame);
    if (!root || !model || !frame_model || !value || !frame) goto done;
    LMX_ARRAY_ADMIT_CHECK(lmx_array_admit_number(&arena, model, 0, 0) == 0 && lmx_array_admit_number(&arena, model, 1, 0) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_array_admit_number(&arena, frame_model, 0, 0) == 0 && lmx_array_admit_number(&arena, frame_model, 1, 0) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_ref_store(root, 0, value) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_ref_store(root, 1, model) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_ref_store(root, 2, frame) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_ref_store(root, 3, frame_model) == 0);
    *(int *)lmx_array_cell_in(&arena, value, 0) = 22;
    *(int *)lmx_array_cell_in(&arena, value, 1) = 11;
    *(int *)lmx_array_cell_in(&arena, value, 2) = 77;
    for (index = 0; index < 4; ++index) *(size_t *)lmx_array_cell_in(&arena, frame, index) = lmx_array_admit_map[index];
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_receiver_view(&arena, value, value, model, NULL) == LMX_IMPLEMENTS_YES);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_register_map(&arena, value, model, lmx_array_admit_map, 2, NULL) == LMX_IMPLEMENTS_YES);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_slot(&arena, value, model, 0, &index) == 0 && index == 1);
    cell = lmx_graph_value_in(&arena, value, index);
    LMX_ARRAY_ADMIT_CHECK(cell && *cell == 11);
    if (!cell) goto done;
    *cell = 31;
    LMX_ARRAY_ADMIT_CHECK(*(int *)lmx_array_cell_in(&arena, value, 1) == 31);
    LMX_ARRAY_ADMIT_CHECK(*(int *)lmx_array_cell_in(&arena, value, 0) == 22);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_slot(&arena, value, model, 2, &index) == 0 && index == 1);
    *cell = 0;
    memset(&pending, 0, sizeof pending);
    pending.value = value; pending.req = model; pending.frame = frame; pending.n = 2; pending.holes = 1;
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_at(&arena, &pending, 0, &index) == 0 && index == 1);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_at_last(&arena, &pending, 0, &index) == 0 && index == 1);
    pending.req = frame_model;
    pending.holes = 0;
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_register(&arena, value, frame_model, &pending) == LMX_IMPLEMENTS_YES);
    short_value = lmx_array_new_owned(LMX_TYPE_ARRAY_OF_INT, 1, &arena);
    char_value = lmx_array_new_owned(LMX_TYPE_ARRAY_OF_CHAR, 3, &arena);
    empty = lmx_array_new_owned(LMX_TYPE_ARRAY_OF_INT, 0, &arena);
    LMX_ARRAY_ADMIT_CHECK(short_value && char_value && empty);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_receiver_view(&arena, short_value, short_value, model, NULL) == LMX_IMPLEMENTS_NO);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_receiver_view(&arena, char_value, char_value, model, NULL) == LMX_IMPLEMENTS_NO);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_receiver_view(&arena, empty, empty, value, NULL) == LMX_IMPLEMENTS_YES);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_receiver_view(&arena, value, value, empty, NULL) == LMX_IMPLEMENTS_YES);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_receiver_view(&arena, char_value, char_value, empty, NULL) == LMX_IMPLEMENTS_NO);
    plain = lmx_array_admit_node(&arena, NULL, 2);
    outer_a = lmx_array_admit_node(&arena, NULL, 1);
    outer_b = lmx_array_admit_node(&arena, NULL, 1);
    outer_model = lmx_array_admit_node(&arena, NULL, 1);
    LMX_ARRAY_ADMIT_CHECK(plain && outer_a && outer_b && outer_model);
    if (!plain || !outer_a || !outer_b || !outer_model) goto done;
    LMX_ARRAY_ADMIT_CHECK(lmx_array_admit_number(&arena, plain, 0, 41) == 0 && lmx_array_admit_number(&arena, plain, 1, 43) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_ref_store(outer_a, 0, value) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_ref_store(outer_b, 0, plain) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_ref_store(outer_model, 0, model) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_receiver_view(&arena, outer_a, outer_b, outer_model, NULL) == LMX_IMPLEMENTS_YES);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_exec_save(&arena, value, lmx_array_admit_map, 2) == LMX_IMPLEMENTS_YES);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_exec_index(&arena, value, 0) == 1);
    before = arena.impl_len;
    lmx_arena_impl_prune(&arena);
    LMX_ARRAY_ADMIT_CHECK(arena.impl_len == before);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_find(&arena, value, model) != NULL);
    LMX_ARRAY_ADMIT_CHECK(lmx_graph_copy_owned(root, &arena, &target, &copy) == LMX_GRAPH_COPY_OK);
    LMX_ARRAY_ADMIT_CHECK(copy != NULL);
    if (!copy) goto done;
    new_value = lmx_arena_ref_struct(copy, 0);
    new_model = lmx_arena_ref_struct(copy, 1);
    new_frame = lmx_arena_ref_struct(copy, 2);
    new_frame_model = lmx_arena_ref_struct(copy, 3);
    LMX_ARRAY_ADMIT_CHECK(new_value && new_model && new_frame);
    record = lmx_implements_find(&target, new_value, new_model);
    LMX_ARRAY_ADMIT_CHECK(record != NULL);
    if (!record) goto done;
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_slot(&target, new_value, new_model, 0, &index) == 0 && index == 1);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_exec_index(&target, new_value, 0) == 1);
    record = lmx_implements_find(&target, new_value, new_frame_model);
    LMX_ARRAY_ADMIT_CHECK(record && record->frame == new_frame);
    LMX_ARRAY_ADMIT_CHECK(lmx_implements_slot(&target, new_value, new_frame_model, 0, &index) == 0 && index == 1);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_release(&arena) == 0);
    cell = lmx_graph_value_in(&target, new_value, index);
    LMX_ARRAY_ADMIT_CHECK(cell && *cell == 0);
    if (!cell) goto done;
    *cell = 57;
    LMX_ARRAY_ADMIT_CHECK(*(int *)lmx_array_cell_in(&target, new_value, 1) == 57);
    LMX_ARRAY_ADMIT_CHECK(*(int *)lmx_array_cell_in(&target, new_value, 0) == 22);
    LMX_ARRAY_ADMIT_CHECK(*(int *)lmx_array_cell_in(&target, new_value, 2) == 77);
done:
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_release(&arena) == 0);
    LMX_ARRAY_ADMIT_CHECK(lmx_arena_release(&target) == 0);
    printf("K07 graph admission: %d checks, %d failures\n", lmx_array_admit_checks, lmx_array_admit_failures);
    return lmx_array_admit_failures != 0;
}


#undef LMX_ARRAY_ADMIT_CHECK
#endif
