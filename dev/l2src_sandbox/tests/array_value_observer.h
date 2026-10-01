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
    size_t i;
    VoidArray *expected = 0;
    int matches = 0;
    if (lmx_range_classify(arena, candidate) != LMX_KIND_ARRAY)
        return 0;
    for (i = 0; i < owner->array.size; ++i) {
        void *value = lmx_arena_ref_value(owner, i);
        if (lmx_range_classify(arena, value) == LMX_KIND_ARRAY) {
            expected = value;
            ++matches;
        }
    }
    if (matches != 1 || candidate != expected || expected->size != size ||
        lmx_range_type_of(arena, expected) < LMX_TYPE_ARRAY_OF_POINTER_BASE)
        return 0;
    if (((int **)expected->data)[0] != first ||
        ((int **)expected->data)[1] != 0)
        return 0;
    ++l2_test_array_address_checks;
    return 1;
}
#endif
