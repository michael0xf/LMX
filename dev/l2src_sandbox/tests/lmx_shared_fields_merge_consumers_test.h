#include "lmx_shared_fields_test.h"

static void case_merge_consumers(int indirect_source)
{
    LmxArena source, destination;
    Lmx *scope, *op, *owner, *target;
    LmxMergePair first = {0, 1, indirect_source ? 0 : 1}, second = {1, 1, indirect_source ? 1 : 0};
    LmxMergePair *pairs[2] = {&first, &second};
    void *fields[2], *original, *saved, *pointer, *live;
    int status;
    memset(&source, 0, sizeof source); memset(&destination, 0, sizeof destination);
    CHECK(lmx_arena_open(&source) == 0 && lmx_arena_open(&destination) == 0);
    scope = lmx_node_new_owned(&source); owner = lmx_node_new_owned(&destination);
    CHECK(scope && owner);
    if (!scope || !owner) goto done;
    CHECK(lmx_arena_refs_open_owned(&source, scope, 3) == 0);
    CHECK(lmx_arena_refs_open_owned(&destination, owner, 3) == 0);
    CHECK(lmx_graph_ref_store_in(&source, scope, 0, lmx_int_new_owned(&source)) == 0);
    CHECK(lmx_int_store_known(lmx_graph_value_in(&source, scope, 0), 59) == 0);
    pointer = lmx_pointer_new_owned(LMX_TYPE_POINTER_BASE + 4096, &source);
    CHECK(pointer && lmx_pointer_store_in(&source, pointer, lmx_graph_cell_in(&source, scope, 0)) == 0);
    CHECK(lmx_graph_ref_store_in(&source, scope, 1, pointer) == 0);
    original = lmx_int_new_owned(&destination);
    CHECK(original && lmx_int_store_known(original, 17) == 0);
    CHECK(lmx_graph_ref_store_in(&destination, owner, 0, original) == 0);
    CHECK(lmx_graph_ref_store_in(&destination, owner, 1, lmx_int_new_owned(&destination)) == 0);
    CHECK(lmx_int_store_known(lmx_graph_value_in(&destination, owner, 1), 97) == 0);
    target = lmx_struct_new_profiled(owner, &destination, NULL);
    CHECK(target != NULL);
    if (!target) goto done;
    fields[0] = lmx_graph_cell_in(&destination, owner, 2); fields[1] = lmx_graph_cell_in(&destination, owner, 0);
    target->array.size = 2;
    CHECK(lmx_graph_fields_bind(&destination, target, fields) == 0);
    op = lmx_struct_new_profiled(scope, &source, NULL);
    CHECK(op != NULL);
    if (!op) goto done;
    op->array.size = 2;
    fields[0] = lmx_graph_cell_in(&source, scope, indirect_source ? 1 : 0);
    fields[1] = lmx_graph_cell_in(&source, scope, indirect_source ? 0 : 1);
    CHECK(lmx_graph_fields_bind(&source, op, fields) == 0);
    status = lmx_merge_into_owned(target, op, &source, &destination, pairs, 2);
    printf("merge_consumers indirect_source=%d status=%d\n", indirect_source, status);
    CHECK(status == LMX_MERGE_OK);
    CHECK(lmx_graph_cell_in(&destination, target, 0) == lmx_graph_cell_in(&destination, owner, 2));
    CHECK(lmx_graph_cell_in(&destination, target, 1) == lmx_graph_cell_in(&destination, owner, 0));
    live = lmx_graph_value_in(&destination, owner, 0);
    CHECK(live != original && lmx_range_type_of(&destination, live) == LMX_TYPE_INT);
    if (live != original && lmx_range_type_of(&destination, live) == LMX_TYPE_INT)
        CHECK(lmx_int_value_known(live) == 59);
    saved = lmx_pointer_value_in(&destination, lmx_graph_value_in(&destination, owner, 2));
    CHECK(saved == lmx_graph_cell_in(&destination, owner, 0));
    CHECK(lmx_int_value_known(lmx_graph_value_in(&destination, owner, 1)) == 97);
    CHECK(lmx_arena_release(&source) == 0);
    if (saved == lmx_graph_cell_in(&destination, owner, 0)) {
        *(void **)saved = NULL;
        CHECK(lmx_graph_value_in(&destination, target, 1) == NULL);
        *(void **)saved = live;
        CHECK(lmx_graph_value_in(&destination, target, 1) == live);
    }
done:
    CHECK(lmx_arena_release(&source) == 0 && lmx_arena_release(&destination) == 0);
}

static int field_view_merge_consumers_test(void)
{
    case_merge_consumers(0); case_merge_consumers(1);
    printf("field_view_merge_consumers: %d checks, %d failures\n", checks, failures);
    return failures != 0;
}
