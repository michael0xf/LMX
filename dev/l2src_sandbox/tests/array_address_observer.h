#ifndef LMX_TEST_ARRAY_ADDRESS_OBSERVER_H
#define LMX_TEST_ARRAY_ADDRESS_OBSERVER_H

/* Test-only traversal of existing owner slots. It makes no production registry
   and does not assert that retained operator bodies are already canonical. */
static int l2_test_array_address_checks;

static void l2_test_array_find(LmxArena *arena, Lmx *owner, int type,
                               size_t size, void *backing, void **found,
                               int *matches)
{
    size_t i;
    for (i = 0; i < owner->array.size; ++i) {
        void *value = lmx_arena_ref_value(owner, i);
        int kind = lmx_range_classify(arena, value);
        if (kind == LMX_KIND_ARRAY && lmx_range_type_of(arena, value) == type) {
            VoidArray *array = value;
            if (array->size == size && array->data == backing) {
                *found = value;
                ++*matches;
            }
        } else if (kind == LMX_KIND_STRUCT) {
            Lmx *child = value;
            if (child->parent == owner)
                l2_test_array_find(arena, child, type, size, backing, found, matches);
        }
    }
}

static int l2_test_array_address(LmxArena *arena, Lmx *owner, void *candidate,
                                int type, size_t size, void *backing)
{
    void *expected = 0;
    int matches = 0;
    /* Never read a candidate descriptor until its classification AND exact
       identity with the independently found owner field have been established. */
    if (lmx_range_classify(arena, candidate) != LMX_KIND_ARRAY ||
        lmx_range_type_of(arena, candidate) != type)
        return 0;
    l2_test_array_find(arena, owner, type, size, backing, &expected, &matches);
    if (matches != 1 || candidate != expected)
        return 0;
    if (((VoidArray *)candidate)->size != size ||
        ((VoidArray *)candidate)->data != backing)
        return 0;
    ++l2_test_array_address_checks;
    return 1;
}

static int l2_test_array_address_count(int expected)
{
    return l2_test_array_address_checks == expected;
}
#endif
