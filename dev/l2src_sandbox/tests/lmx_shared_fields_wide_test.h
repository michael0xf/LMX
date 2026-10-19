#include "lmx_shared_fields_test.h"

static int field_view_wide_test(void)
{
    LmxArena source, destination;
    Lmx *model, *op, *view, *result = NULL, *operands[2];
    LmxArena copied_arena;
    Lmx *copied, *copied_view, *copied_owner;
    LmxMergePair first = {0, 1, 1}, second = {1, 1, 0};
    LmxMergePair *pairs[2] = {&first, &second};
    void *new_x, *old_x;
    int status, copy_view_first;
    memset(&source, 0, sizeof source);
    memset(&destination, 0, sizeof destination);
    CHECK(lmx_arena_open(&source) == 0 && lmx_arena_open(&destination) == 0);
    model = lmx_node_new_owned(&source); op = lmx_node_new_owned(&source);
    CHECK(model && op);
    if (!model || !op) goto done;
    CHECK(lmx_arena_refs_open_owned(&source, model, 2) == 0);
    CHECK(lmx_arena_refs_open_owned(&source, op, 3) == 0);
    CHECK(lmx_arena_ref_store(model, 0, lmx_int_new_owned(&source)) == 0);
    CHECK(lmx_arena_ref_store(model, 1, lmx_int_new_owned(&source)) == 0);
    CHECK(lmx_int_store_known(lmx_arena_ref_value(model, 0), 17) == 0);
    CHECK(lmx_int_store_known(lmx_arena_ref_value(model, 1), 29) == 0);
    CHECK(lmx_arena_ref_store(op, 0, lmx_int_new_owned(&source)) == 0);
    CHECK(lmx_arena_ref_store(op, 1, lmx_int_new_owned(&source)) == 0);
    CHECK(lmx_int_store_known(lmx_arena_ref_value(op, 0), 43) == 0);
    CHECK(lmx_int_store_known(lmx_arena_ref_value(op, 1), 61) == 0);
    view = lmx_struct_new_profiled(op, &source, NULL);
    CHECK(view != NULL);
    if (!view) goto done;
    view->array.size = 2; view->array.data = lmx_graph_cell_in(&source, op, 0);
    CHECK(lmx_graph_cell_in(&source, view, 1) == lmx_graph_cell_in(&source, op, 1));
    CHECK(lmx_arena_ref_store(op, 2, view) == 0);
    operands[0] = model; operands[1] = op;
    status = lmx_merge_owned(operands, 2, NULL, &source, &destination, pairs, 2, &result);
    printf("field_view_wide_status=%d\n", status);
    CHECK(status == LMX_MERGE_OK && result && result->array.size == 3);
    if (status != LMX_MERGE_OK || !result) goto done;
    view = lmx_graph_node_in(&destination, lmx_graph_value_in(&destination, result, 2));
    CHECK(view && view->array.size == 2 && view->parent == result);
    if (!view) goto done;
    CHECK(lmx_graph_cell_in(&destination, view, 0) == lmx_graph_cell_in(&destination, result, 1));
    CHECK(lmx_graph_cell_in(&destination, view, 1) == lmx_graph_cell_in(&destination, result, 0));
    CHECK(lmx_arena_release(&source) == 0);
    CHECK(lmx_int_value_known(lmx_graph_value_in(&destination, view, 0)) == 43);
    CHECK(lmx_int_value_known(lmx_graph_value_in(&destination, view, 1)) == 61);
    new_x = lmx_int_new_owned(&destination);
    CHECK(new_x && lmx_int_store_known(new_x, 83) == 0);
    old_x = lmx_graph_value_in(&destination, result, 0);
    *(void **)lmx_graph_cell_in(&destination, view, 1) = new_x;
    CHECK(lmx_graph_value_in(&destination, result, 0) == new_x);
    CHECK(lmx_int_value_known(old_x) == 61);
    CHECK(lmx_int_value_known(lmx_graph_value_in(&destination, result, 1)) == 43);
    for (copy_view_first = 0; copy_view_first < 2; ++copy_view_first) {
        memset(&copied_arena, 0, sizeof copied_arena);
        CHECK(lmx_arena_open(&copied_arena) == 0);
        copied = NULL;
        status = lmx_graph_copy_owned(copy_view_first ? view : result, &destination, &copied_arena, &copied);
        printf("wide_copy_view_first=%d status=%d\n", copy_view_first, status);
        CHECK(status == LMX_GRAPH_COPY_OK && copied != NULL);
        if (status == LMX_GRAPH_COPY_OK && copied) {
            copied_owner = copy_view_first ? copied->parent : copied;
            copied_view = copy_view_first ? copied : lmx_graph_node_in(&copied_arena, lmx_graph_value_in(&copied_arena, copied, 2));
            CHECK(copied_view && copied_view->parent == copied_owner);
            if (copied_view) {
                CHECK(lmx_graph_cell_in(&copied_arena, copied_view, 0) == lmx_graph_cell_in(&copied_arena, copied_owner, 1));
                CHECK(lmx_graph_cell_in(&copied_arena, copied_view, 1) == lmx_graph_cell_in(&copied_arena, copied_owner, 0));
                CHECK(lmx_int_value_known(lmx_graph_value_in(&copied_arena, copied_view, 0)) == 43);
                CHECK(lmx_int_value_known(lmx_graph_value_in(&copied_arena, copied_view, 1)) == 83);
                *(void **)lmx_graph_cell_in(&copied_arena, copied_view, 0) = NULL;
                CHECK(lmx_graph_value_in(&copied_arena, copied_owner, 1) == NULL);
                CHECK(lmx_int_value_known(lmx_graph_value_in(&destination, result, 1)) == 43);
            }
        }
        CHECK(lmx_arena_release(&copied_arena) == 0);
    }
done:
    CHECK(lmx_arena_release(&source) == 0 && lmx_arena_release(&destination) == 0);
    printf("field_view_wide: %d checks, %d failures\n", checks, failures);
    return failures != 0;
}
