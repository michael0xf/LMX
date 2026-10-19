#ifndef LMX_SOURCE_ARRAY_FIELD_PARENT_OBSERVER_H
#define LMX_SOURCE_ARRAY_FIELD_PARENT_OBSERVER_H
#include <string.h>

/* Observe existing graph addresses only. Never repair a parent or invent an
   owner by a source name. A shared field place and its owner use ONE cell. */
static int l2_test_source_array_field_parent(LmxArena *arena, void *value,
                                            int type, size_t count)
{
    Lmx *array = lmx_graph_node_in(arena, value), *place, *owner;
    void *cell;
    size_t i, matches = 0;
    if (!array || lmx_range_classify(arena, array) != LMX_KIND_ARRAY ||
        array->array.size != count || array->native) return 0;
    if (type ? lmx_range_type_of(arena, array) != type :
               lmx_range_type_of(arena, array) < LMX_TYPE_ARRAY_OF_POINTER_BASE) return 0;
    place = lmx_graph_node_in(arena, array->parent);
    if (!place || lmx_range_classify(arena, place) != LMX_KIND_STRUCT ||
        place->array.size != 1 || place->native) return 0;
    owner = lmx_graph_node_in(arena, place->parent);
    cell = lmx_graph_ref_cell_in(arena, place, 0);
    if (!owner || !cell || *(void **)cell != array ||
        lmx_range_profile(arena, array) != lmx_range_profile(arena, place) ||
        lmx_range_profile(arena, array) != lmx_range_profile(arena, cell)) return 0;
    for (i = 0; i < owner->array.size; ++i)
        if (lmx_graph_cell_in(arena, owner, i) == cell) ++matches;
    if (matches != 1) return 0;
    if (!count) return array->array.data == NULL;
    if (!lmx_graph_cell_in(arena, array, count - 1)) return 0;
    if (!type && !lmx_pointer_pool_in(arena, lmx_graph_cell_in(arena, array, 0))) return 0;
    if (type == LMX_TYPE_ARRAY_OF_INT && count == 2 &&
        (*(int *)lmx_graph_cell_in(arena, array, 0) != 17 ||
         *(int *)lmx_graph_cell_in(arena, array, 1) != 29)) return 0;
    if (!type) {
        void *target = lmx_pointer_value_in(arena, lmx_graph_cell_in(arena, array, 0));
        if (lmx_range_type_of(arena, target) != LMX_TYPE_INT ||
            lmx_int_value_known(target) != 41) return 0;
    }
    return 1;
}

static int l2_test_source_array_scope_copy(LmxArena *arena, Lmx *scope, void *value)
{
    LmxArena first, second;
    Lmx *copy = NULL, *again = NULL, *array;
    size_t slot, found = (size_t)-1;
    int okay = 0;
    if (!l2_test_source_array_field_parent(arena, value, LMX_TYPE_ARRAY_OF_INT, 3) ||
        ((Lmx *)value)->parent->parent != scope) return 0;
    for (slot = 0; slot < scope->array.size; ++slot)
        if (lmx_graph_value_in(arena, scope, slot) == value) found = slot;
    if (found == (size_t)-1) return 0;
    memset(&first, 0, sizeof first); memset(&second, 0, sizeof second);
    if (lmx_arena_open(&first)) return 0;
    if (lmx_arena_open(&second)) { lmx_arena_release(&first); return 0; }
    if (lmx_graph_copy_owned(scope, arena, &first, &copy) != LMX_GRAPH_COPY_OK || !copy) goto done;
    if (lmx_graph_copy_owned(copy, &first, &second, &again) != LMX_GRAPH_COPY_OK || !again) goto done;
    if (lmx_arena_release(&first)) goto done;
    array = lmx_graph_node_in(&second, lmx_graph_value_in(&second, again, found));
    if (!l2_test_source_array_field_parent(&second, array, LMX_TYPE_ARRAY_OF_INT, 3) ||
        array->parent->parent != again || array == value ||
        *(int *)lmx_graph_cell_in(&second, array, 0) != 0) goto done;
    *(int *)lmx_graph_cell_in(&second, array, 0) = 73;
    okay = *(int *)lmx_graph_cell_in(&second, array, 0) == 73 &&
           *(int *)lmx_graph_cell_in(&second, array, 1) == 0 &&
           *(int *)lmx_graph_cell_in(arena, value, 0) == 0 &&
           l2_test_source_array_field_parent(arena, value, LMX_TYPE_ARRAY_OF_INT, 3);
done:
    if (lmx_arena_release(&first) || lmx_arena_release(&second)) okay = 0;
    return okay;
}
#endif
