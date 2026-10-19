#include "lmx_shared_fields_test.h"

static int field_view_mixed_test(void)
{
    LmxArena source, destination;
    Lmx *profile, *scope, *view, *copied_profile, *copy = NULL, *copied_view;
    LmxPool *extra;
    void *cells[2], *good, *garbage;
    int status;
    memset(&source, 0, sizeof source);
    memset(&destination, 0, sizeof destination);
    CHECK(lmx_arena_open(&source) == 0 && lmx_arena_open(&destination) == 0);
    profile = lmx_node_new_owned(&source);
    scope = lmx_node_new_profiled(&source, profile);
    view = lmx_struct_new_profiled(scope, &source, profile);
    CHECK(profile && scope && view);
    if (!profile || !scope || !view) goto done;
    CHECK(lmx_arena_refs_open_profiled(&source, scope, 2, profile) == 0);
    extra = lmx_pool_make_profiled(&source, sizeof(void *), sizeof(void *), LMX_KIND_CHILDREN, LMX_TYPE_REFS, profile);
    CHECK(extra != NULL);
    if (!extra) goto done;
    cells[0] = lmx_graph_cell_in(&source, scope, 0);
    cells[1] = lmx_chunk_data(extra->head);
    view->array.size = 2;
    CHECK(lmx_graph_fields_bind(&source, view, cells) == 0);
    CHECK(lmx_range_classify(&source, view->array.data) == LMX_KIND_FIELD_ADDRESSES);
    CHECK(lmx_graph_ref_store_in(&source, scope, 0, lmx_int_new_profiled(&source, profile)) == 0);
    CHECK(lmx_int_store_known(lmx_graph_value_in(&source, scope, 0), 17) == 0);
    CHECK(lmx_graph_ref_store_in(&source, scope, 1, view) == 0);
    CHECK(lmx_graph_ref_store_in(&source, view, 1, lmx_int_new_profiled(&source, profile)) == 0);
    CHECK(lmx_int_store_known(lmx_graph_value_in(&source, view, 1), 59) == 0);
    status = lmx_qualify_tree_preflight_full(&source, scope, NULL, NULL, 0, NULL, 0, NULL, 0);
    printf("mixed_source_qualify=%d\n", status);
    CHECK(status == LMX_QUALIFY_OK);
    good = ((void **)view->array.data)[0];
    ((void **)view->array.data)[0] = view->array.data;
    CHECK(lmx_graph_cell_in(&source, view, 0) == NULL);
    CHECK(lmx_qualify_tree_preflight_full(&source, scope, NULL, NULL, 0, NULL, 0, NULL, 0) != LMX_QUALIFY_OK);
    ((void **)view->array.data)[0] = lmx_graph_value_in(&source, scope, 0);
    CHECK(lmx_graph_cell_in(&source, view, 0) == NULL);
    ((void **)view->array.data)[0] = good;
    copied_profile = lmx_node_new_owned(&destination);
    CHECK(copied_profile != NULL);
    status = lmx_graph_copy_qualified_owned(scope, &source, &destination, NULL, 0, copied_profile, &copy);
    printf("mixed_copy=%d\n", status);
    CHECK(status == LMX_GRAPH_COPY_OK && copy != NULL);
    if (status != LMX_GRAPH_COPY_OK || !copy) goto done;
    copied_view = lmx_graph_node_in(&destination, lmx_graph_value_in(&destination, copy, 1));
    CHECK(copied_view && copied_view->parent == copy);
    if (!copied_view) goto done;
    CHECK(lmx_graph_cell_in(&destination, copy, 0) == lmx_graph_cell_in(&destination, copied_view, 0));
    status = lmx_qualify_tree_preflight_full(&destination, copy, NULL, NULL, 0, NULL, 0, NULL, 0);
    printf("mixed_destination_qualify=%d\n", status);
    CHECK(status == LMX_QUALIFY_OK);
    CHECK(lmx_arena_release(&source) == 0);
    garbage = lmx_int_new_owned(&destination);
    CHECK(garbage != NULL);
    CHECK(lmx_gc_mark_value(&destination, copy, 101U, 0) == LMX_GC_OK);
    CHECK(lmx_gc_sweep(&destination, 101U) == LMX_GC_OK);
    CHECK(lmx_range_classify(&destination, garbage) == LMX_KIND_NONE);
    CHECK(lmx_int_value_known(lmx_graph_value_in(&destination, copied_view, 0)) == 17);
    CHECK(lmx_int_value_known(lmx_graph_value_in(&destination, copied_view, 1)) == 59);
    CHECK(lmx_graph_ref_store_in(&destination, copied_view, 0, NULL) == 0);
    CHECK(lmx_graph_value_in(&destination, copy, 0) == NULL);
done:
    CHECK(lmx_arena_release(&source) == 0 && lmx_arena_release(&destination) == 0);
    printf("field_view_mixed: %d checks, %d failures\n", checks, failures);
    return failures != 0;
}
