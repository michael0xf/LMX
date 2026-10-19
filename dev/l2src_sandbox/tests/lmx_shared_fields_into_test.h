#include "lmx_shared_fields_test.h"

static int field_view_into_test(void)
{
    LmxArena source, destination;
    Lmx *op, *receiver, *place, *array;
    LmxMergePair first = {0, 1, 1}, second = {1, 1, 0};
    LmxMergePair *pairs[2] = {&first, &second};
    void *pointer, *saved, *unchanged;
    int status;
    memset(&source, 0, sizeof source);
    memset(&destination, 0, sizeof destination);
    CHECK(lmx_arena_open(&source) == 0 && lmx_arena_open(&destination) == 0);
    op = lmx_node_new_owned(&source);
    receiver = lmx_node_new_owned(&destination);
    CHECK(op && receiver);
    if (!op || !receiver) goto done;
    CHECK(lmx_arena_refs_open_owned(&source, op, 2) == 0);
    CHECK(lmx_arena_refs_open_owned(&destination, receiver, 3) == 0);
    place = field_occurrence(&source, op, 0, NULL);
    CHECK(place != NULL);
    if (!place) goto done;
    array = lmx_array_new_child_profiled(place, LMX_TYPE_ARRAY_OF_INT, 2, &source, NULL);
    pointer = lmx_pointer_new_profiled(LMX_TYPE_POINTER_BASE + 4096, &source, NULL);
    unchanged = lmx_int_new_owned(&destination);
    CHECK(array && pointer && unchanged);
    if (!array || !pointer || !unchanged) goto done;
    CHECK(lmx_int_store_known(unchanged, 97) == 0);
    CHECK(lmx_arena_ref_store(receiver, 2, unchanged) == 0);
    CHECK(lmx_arena_ref_store(op, 0, array) == 0);
    CHECK(lmx_arena_ref_store(op, 1, pointer) == 0);
    CHECK(lmx_pointer_store_in(&source, pointer, lmx_graph_cell_in(&source, op, 0)) == 0);
    *(int *)lmx_graph_cell_in(&source, array, 0) = 41;
    *(int *)lmx_graph_cell_in(&source, array, 1) = 73;
    status = lmx_merge_into_owned(receiver, op, &source, &destination, pairs, 2);
    printf("field_view_into_status=%d\n", status);
    CHECK(status == LMX_MERGE_OK);
    if (status != LMX_MERGE_OK) goto done;
    array = lmx_graph_node_in(&destination, lmx_graph_value_in(&destination, receiver, 1));
    saved = lmx_pointer_value_in(&destination, lmx_graph_value_in(&destination, receiver, 0));
    CHECK(array && saved);
    if (!array || !saved) goto done;
    CHECK(array->parent && array->parent->parent == receiver);
    CHECK(lmx_graph_cell_in(&destination, array->parent, 0) == lmx_graph_cell_in(&destination, receiver, 1));
    CHECK(saved == lmx_graph_cell_in(&destination, receiver, 1));
    CHECK(lmx_arena_release(&source) == 0);
    *(void **)saved = NULL;
    CHECK(lmx_graph_value_in(&destination, receiver, 1) == NULL);
    CHECK(lmx_graph_value_in(&destination, array->parent, 0) == NULL);
    *(void **)saved = array;
    *(int *)lmx_graph_cell_in(&destination, array, 1) = 59;
    CHECK(*(int *)lmx_graph_cell_in(&destination, array, 0) == 41);
    CHECK(*(int *)lmx_graph_cell_in(&destination, array, 1) == 59);
    CHECK(lmx_graph_value_in(&destination, receiver, 2) == unchanged);
    CHECK(lmx_int_value_known(unchanged) == 97);
done:
    CHECK(lmx_arena_release(&source) == 0 && lmx_arena_release(&destination) == 0);
    printf("field_view_into: %d checks, %d failures\n", checks, failures);
    return failures != 0;
}
