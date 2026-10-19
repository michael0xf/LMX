#ifndef LMX_ARRAY_GRAPH_MERGE_TEST_H
#define LMX_ARRAY_GRAPH_MERGE_TEST_H
/* Absorbed Structure roots must disappear from every copied graph edge:
   Array parents, Array reference backing and actual typed Lmx * elements.
   This does not claim that all Array-root merge forms are implemented. */
#include <stdio.h>
#include <string.h>
static int lmx_array_merge_checks, lmx_array_merge_failures;
static void *lmx_array_merge_last_cell, *lmx_array_merge_last_value;
static void *lmx_array_merge_previous_cell, *lmx_array_merge_previous_value;
#define LMX_ARRAY_MERGE_CHECK(x) do { ++lmx_array_merge_checks; if (!(x)) { ++lmx_array_merge_failures; \
    fprintf(stderr, "FAIL %d: %s\n", __LINE__, #x); } } while (0)
static void *lmx_array_merge_read(void *cell) { return *(Lmx **)cell; }
static int lmx_array_merge_write(void *cell, void *value) {
    *(Lmx **)cell = value;
    if (value) {
        lmx_array_merge_previous_cell = lmx_array_merge_last_cell;
        lmx_array_merge_previous_value = lmx_array_merge_last_value;
        lmx_array_merge_last_cell = cell; lmx_array_merge_last_value = value;
    }
    return 0;
}
static int lmx_array_graph_merge_test(void) {
    LmxArena source = {0}, target = {0};
    Lmx *root, *other, *profile, *result = NULL, *operands[2];
    LmxArray *refs, *pointers, *numbers, *new_refs, *new_pointers, *new_numbers, *through_numbers;
    void *eight, *pointer, *new_pointer;
    int status;
    LMX_ARRAY_MERGE_CHECK(lmx_arena_open(&source) == 0);
    LMX_ARRAY_MERGE_CHECK(lmx_arena_open(&target) == 0);
    root = lmx_node_new_owned(&source);
    other = lmx_node_new_owned(&source);
    profile = lmx_node_new_owned(&target);
    LMX_ARRAY_MERGE_CHECK(root && other && profile);
    if (!root || !other || !profile) goto done;
    LMX_ARRAY_MERGE_CHECK(lmx_arena_refs_open_owned(&source, root, 4) == 0);
    LMX_ARRAY_MERGE_CHECK(lmx_arena_refs_open_owned(&source, other, 1) == 0);
    refs = lmx_array_ref_new_child_profiled(root, LMX_TYPE_ARRAY_OF_LMX, 1, &source, NULL);
    pointers = lmx_array_new_typed_child_profiled(root, LMX_TYPE_ARRAY_OF_POINTER_BASE + 2050, 1,
        &source, NULL, sizeof(Lmx *), lmx_array_merge_read, lmx_array_merge_write);
    numbers = lmx_array_new_child_profiled(root, LMX_TYPE_ARRAY_OF_INT, 2, &source, NULL);
    pointer = lmx_pointer_new_typed_profiled(LMX_TYPE_POINTER_BASE + 2050, &source, NULL,
        sizeof(Lmx *), lmx_array_merge_read, lmx_array_merge_write);
    eight = lmx_int_new_owned(&source);
    LMX_ARRAY_MERGE_CHECK(refs && pointers && numbers && pointer && eight);
    if (!refs || !pointers || !numbers || !pointer || !eight) goto done;
    LMX_ARRAY_MERGE_CHECK(lmx_arena_ref_store(root, 0, refs) == 0);
    LMX_ARRAY_MERGE_CHECK(lmx_arena_ref_store(root, 1, pointers) == 0);
    LMX_ARRAY_MERGE_CHECK(lmx_arena_ref_store(root, 2, numbers) == 0);
    LMX_ARRAY_MERGE_CHECK(lmx_arena_ref_store(root, 3, pointer) == 0);
    LMX_ARRAY_MERGE_CHECK(lmx_arena_ref_store(refs, 0, root) == 0);
    *(Lmx **)lmx_array_cell_in(&source, pointers, 0) = root;
    *(Lmx **)pointer = root;
    *(int *)lmx_array_cell_in(&source, numbers, 0) = 11;
    *(int *)lmx_array_cell_in(&source, numbers, 1) = 29;
    LMX_ARRAY_MERGE_CHECK(lmx_int_store_known(eight, 8) == 0 && lmx_arena_ref_store(other, 0, eight) == 0);
    operands[0] = root; operands[1] = other;
    lmx_array_merge_last_cell = lmx_array_merge_last_value = NULL;
    lmx_array_merge_previous_cell = lmx_array_merge_previous_value = NULL;
    status = lmx_merge_qualified_owned(operands, 2, NULL, &source, &target, NULL, 0, NULL, 0, profile, &result);
    LMX_ARRAY_MERGE_CHECK(status == LMX_MERGE_OK && result && result->array.size == 5);
    if (status != LMX_MERGE_OK || !result) goto done;
    new_refs = lmx_graph_value_in(&target, result, 0);
    new_pointers = lmx_graph_value_in(&target, result, 1);
    new_numbers = lmx_graph_value_in(&target, result, 2);
    new_pointer = lmx_graph_value_in(&target, result, 3);
    LMX_ARRAY_MERGE_CHECK(new_refs && new_pointers && new_numbers && new_pointer);
    if (!new_refs || !new_pointers || !new_numbers || !new_pointer) goto done;
    LMX_ARRAY_MERGE_CHECK(new_refs->parent == result && new_pointers->parent == result && new_numbers->parent == result);
    LMX_ARRAY_MERGE_CHECK(lmx_graph_value_in(&target, new_refs, 0) == result);
    LMX_ARRAY_MERGE_CHECK(*(Lmx **)lmx_array_cell_in(&target, new_pointers, 0) == result);
    LMX_ARRAY_MERGE_CHECK(*(Lmx **)new_pointer == result);
    LMX_ARRAY_MERGE_CHECK(lmx_array_merge_last_value == result && lmx_array_merge_previous_value == result);
    LMX_ARRAY_MERGE_CHECK((lmx_array_merge_last_cell == lmx_array_cell_in(&target, new_pointers, 0) && lmx_array_merge_previous_cell == new_pointer) ||
        (lmx_array_merge_previous_cell == lmx_array_cell_in(&target, new_pointers, 0) && lmx_array_merge_last_cell == new_pointer));
    LMX_ARRAY_MERGE_CHECK(lmx_qualify_tree_preflight_full(&target, result, NULL, NULL, 0, NULL, 0, NULL, 0) == LMX_QUALIFY_OK);
    LMX_ARRAY_MERGE_CHECK(lmx_arena_release(&source) == 0);
    LMX_ARRAY_MERGE_CHECK(lmx_graph_value_in(&target, new_refs, 0) == result);
    LMX_ARRAY_MERGE_CHECK(*(Lmx **)lmx_array_cell_in(&target, new_pointers, 0) == result);
    LMX_ARRAY_MERGE_CHECK(*(Lmx **)new_pointer == result);
    LMX_ARRAY_MERGE_CHECK(*(int *)lmx_array_cell_in(&target, new_numbers, 1) == 29);
    through_numbers = lmx_graph_value_in(&target, *(Lmx **)lmx_array_cell_in(&target, new_pointers, 0), 2);
    LMX_ARRAY_MERGE_CHECK(through_numbers == new_numbers);
    if (!through_numbers) goto done;
    *(int *)lmx_array_cell_in(&target, through_numbers, 1) = 57;
    LMX_ARRAY_MERGE_CHECK(*(int *)lmx_array_cell_in(&target, new_numbers, 1) == 57 && *(int *)lmx_array_cell_in(&target, new_numbers, 0) == 11);
    LMX_ARRAY_MERGE_CHECK(lmx_int_value_known(lmx_graph_value_in(&target, result, 4)) == 8);
done:
    LMX_ARRAY_MERGE_CHECK(lmx_arena_release(&target) == 0);
    LMX_ARRAY_MERGE_CHECK(lmx_arena_release(&source) == 0);
    printf("K07 common graph merge absorption: %d checks, %d failures\n", lmx_array_merge_checks, lmx_array_merge_failures);
    return lmx_array_merge_failures != 0;
}
#endif
