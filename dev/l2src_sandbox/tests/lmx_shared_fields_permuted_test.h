#include "lmx_shared_fields_test.h"

static int field_view_permuted_test(void)
{
    LmxArena source, target;
    Lmx *model, *other, *ma, *mb, *a, *b, *result = NULL;
    Lmx *operands[2];
    LmxMergePair first = {0, 1, 1}, second = {1, 1, 0};
    LmxMergePair *pairs[2] = {&first, &second};
    void *pa, *pb, *saved;
    int status;
    memset(&source, 0, sizeof source);
    memset(&target, 0, sizeof target);
    CHECK(lmx_arena_open(&source) == 0 && lmx_arena_open(&target) == 0);
    model = lmx_node_new_owned(&source); other = lmx_node_new_owned(&source);
    CHECK(model && other);
    if (!model || !other) goto done;
    CHECK(lmx_arena_refs_open_owned(&source, model, 2) == 0);
    CHECK(lmx_arena_refs_open_owned(&source, other, 2) == 0);
    ma = field_occurrence(&source, model, 0, NULL);
    mb = field_occurrence(&source, other, 1, NULL);
    CHECK(ma && mb);
    if (!ma || !mb) goto done;
    a = lmx_array_new_child_profiled(ma, LMX_TYPE_ARRAY_OF_INT, 2, &source, NULL);
    b = lmx_array_new_child_profiled(mb, LMX_TYPE_ARRAY_OF_INT, 2, &source, NULL);
    pa = lmx_pointer_new_profiled(LMX_TYPE_POINTER_BASE + 5010, &source, NULL);
    pb = lmx_pointer_new_profiled(LMX_TYPE_POINTER_BASE + 5010, &source, NULL);
    CHECK(a && b && pa && pb);
    if (!a || !b || !pa || !pb) goto done;
    CHECK(lmx_arena_ref_store(model, 0, a) == 0 && lmx_arena_ref_store(model, 1, pa) == 0);
    CHECK(lmx_arena_ref_store(other, 0, pb) == 0 && lmx_arena_ref_store(other, 1, b) == 0);
    CHECK(lmx_pointer_store_in(&source, pa, lmx_arena_ref_cell(model, 0)) == 0);
    CHECK(lmx_pointer_store_in(&source, pb, lmx_arena_ref_cell(other, 1)) == 0);
    *(int *)lmx_graph_cell_in(&source, a, 0) = 11;
    *(int *)lmx_graph_cell_in(&source, a, 1) = 22;
    *(int *)lmx_graph_cell_in(&source, b, 0) = 33;
    *(int *)lmx_graph_cell_in(&source, b, 1) = 44;
    operands[0] = model; operands[1] = other;
    status = lmx_merge_owned(operands, 2, NULL, &source, &target, pairs, 2, &result);
    CHECK(status == LMX_MERGE_OK && result && result->array.size == 2);
    if (status != LMX_MERGE_OK || !result) goto done;
    b = lmx_graph_node_in(&target, lmx_graph_value_in(&target, result, 0));
    saved = lmx_pointer_value_in(&target, lmx_graph_value_in(&target, result, 1));
    CHECK(b && saved);
    if (!b || !saved) goto done;
    CHECK(b->parent && b->parent->parent == result);
    CHECK(lmx_arena_ref_cell(b->parent, 0) == lmx_arena_ref_cell(result, 0));
    CHECK(saved == lmx_arena_ref_cell(result, 0));
    CHECK(lmx_arena_release(&source) == 0);
    CHECK(*(int *)lmx_graph_cell_in(&target, b, 0) == 33);
    CHECK(*(int *)lmx_graph_cell_in(&target, b, 1) == 44);
    *(void **)saved = NULL;
    CHECK(lmx_arena_ref_value(result, 0) == NULL && lmx_arena_ref_value(b->parent, 0) == NULL);
    *(void **)saved = b;
    *(int *)lmx_graph_cell_in(&target, b, 0) = 57;
    CHECK(*(int *)lmx_graph_cell_in(&target, lmx_arena_ref_struct(result, 0), 0) == 57);
    CHECK(*(int *)lmx_graph_cell_in(&target, b, 1) == 44);
done:
    CHECK(lmx_arena_release(&source) == 0 && lmx_arena_release(&target) == 0);
    printf("field_view_permuted: %d checks, %d failures\n", checks, failures);
    return failures != 0;
}
