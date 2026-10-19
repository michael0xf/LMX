#ifndef LMX_TEST_ARRAY_VALUE_OBSERVER_H
#define LMX_TEST_ARRAY_VALUE_OBSERVER_H
#include "array_address_observer.h"

/* Record only a descriptor whose independent owner-slot identity was checked.
   The caller compares the returned value before any possible dereference. */
static void *l2_test_array_return_expected;
static int l2_test_array_return_mark(LmxArena *arena, Lmx *owner,
                                     void *candidate, int type,
                                     size_t size, void *backing)
{
    if (!l2_test_array_address(arena, owner, candidate, type, size, backing))
        return 0;
    l2_test_array_return_expected = candidate;
    return 1;
}
static int l2_test_array_return_check(void *candidate)
{
    return candidate != 0 && candidate == l2_test_array_return_expected;
}

/* The pointer-element fixture has exactly one Array in this activation.
   Find its owner-slot identity independently of element-address lowering. */
static int l2_test_pointer_array(LmxArena *arena, Lmx *owner, void *candidate,
                                 int *first, size_t size)
{
    void *found = 0;
    LmxArray *expected;
    Lmx *node;
    LmxPool *pool;
    int matches = 0;
    if (lmx_range_classify(arena, candidate) != LMX_KIND_ARRAY ||
        !(node = lmx_graph_node_in(arena, candidate)))
        return 0;
    /* Use the same ownership traversal as the descriptor/address checks:
       four-part methods do not put source fields directly on the fn root. */
    l2_test_array_find(arena, owner, lmx_range_type_of(arena, candidate),
                       size, node->array.data, &found, &matches);
    expected = found;
    if (matches != 1 || candidate != expected || expected->array.size != size ||
        lmx_range_type_of(arena, expected) < LMX_TYPE_ARRAY_OF_POINTER_BASE)
        return 0;
    if (lmx_pointer_value_in(arena, lmx_graph_cell_in(arena, expected, 0)) != first ||
        lmx_pointer_value_in(arena, lmx_graph_cell_in(arena, expected, 1)) != 0)
        return 0;
    /* Native @values[i] is int **, so the producer must actually allocate
       int * objects. Canonical void * cells plus a cast do not satisfy it. */
    pool = lmx_pointer_pool_in(arena, expected->array.data);
    if (!pool || pool->stride != sizeof(int *) ||
        lmx_pointer_cell_canonical(arena, expected->array.data))
        return 0;
    if (((int **)expected->array.data)[0] != first ||
        ((int **)expected->array.data)[1] != 0)
        return 0;
    ++l2_test_array_address_checks;
    return 1;
}

/* A pure walked producer passes its observed Array to a native observer.
   Follow its real field place; never identify an owner by a source name. */
static int l2_test_pointer_array_owner(LmxArena *arena, void *candidate,
                                      int *first, size_t size)
{
    Lmx *array, *place;
    if (lmx_range_classify(arena, candidate) != LMX_KIND_ARRAY ||
        !(array = lmx_graph_node_in(arena, candidate)))
        return 0;
    place = lmx_graph_node_in(arena, array->parent);
    if (!place || lmx_range_classify(arena, place) != LMX_KIND_STRUCT ||
        place->array.size != 1 ||
        lmx_graph_value_in(arena, place, 0) != candidate)
        return 0;
    return l2_test_pointer_array(arena, place, candidate, first, size);
}
#endif
