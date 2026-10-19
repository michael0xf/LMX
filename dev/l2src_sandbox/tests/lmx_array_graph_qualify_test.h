#ifndef LMX_ARRAY_GRAPH_QUALIFY_TEST_H
#define LMX_ARRAY_GRAPH_QUALIFY_TEST_H
/* K07 physical containment/qualification and complete-profile coverage proof.
   This does not establish receiver admission or native/walker execution. */
#include <stdio.h>
#include <string.h>
static int lmx_array_qual_checks, lmx_array_qual_failures;
#define LMX_ARRAY_QUAL_CHECK(x) do { ++lmx_array_qual_checks; if (!(x)) { ++lmx_array_qual_failures; \
    fprintf(stderr, "FAIL %d: %s\n", __LINE__, #x); } } while (0)
static void *lmx_array_qual_pointer_read(void *cell) { return *(int **)cell; }
static int lmx_array_qual_pointer_write(void *cell, void *value) { *(int **)cell = value; return 0; }

static int lmx_array_qual_simple_array_root(int parent_present) {
    LmxArena arena;
    Lmx *profile, *parent;
    LmxArray *array;
    memset(&arena, 0, sizeof arena);
    LMX_ARRAY_QUAL_CHECK(lmx_arena_open(&arena) == 0);
    profile = lmx_node_new_owned(&arena);
    parent = parent_present ? lmx_node_new_owned(&arena) : NULL;
    array = parent_present
        ? lmx_array_new_child_profiled(parent, LMX_TYPE_ARRAY_OF_INT, 2, &arena, profile)
        : lmx_array_new_profiled(LMX_TYPE_ARRAY_OF_INT, 2, &arena, profile);
    LMX_ARRAY_QUAL_CHECK(profile != NULL && array != NULL);
    if (!profile || !array) goto done;
    *(int *)lmx_array_cell_in(&arena, array, 0) = 13;
    *(int *)lmx_array_cell_in(&arena, array, 1) = 29;
    LMX_ARRAY_QUAL_CHECK(lmx_qualify_tree_preflight_full(&arena, array, NULL, NULL, 0, NULL, 0, NULL, 0) == LMX_QUALIFY_OK);
    LMX_ARRAY_QUAL_CHECK(array->parent == parent);
    LMX_ARRAY_QUAL_CHECK(*(int *)lmx_array_cell_in(&arena, array, 1) == 29);
done:
    LMX_ARRAY_QUAL_CHECK(lmx_arena_release(&arena) == 0);
    return 0;
}

static int lmx_array_qual_mixed_tree(int array_root) {
    LmxArena arena;
    Lmx *profile, *root, *place, *element, *alien;
    LmxArray *array, *scalar, *pointers, *empty;
    void *value;
    memset(&arena, 0, sizeof arena);
    LMX_ARRAY_QUAL_CHECK(lmx_arena_open(&arena) == 0);
    profile = lmx_node_new_owned(&arena);
    LMX_ARRAY_QUAL_CHECK(profile != NULL);
    if (!profile) goto done;
    if (array_root) {
        array = lmx_array_ref_new_profiled(LMX_TYPE_ARRAY_OF_LMX, 4, &arena, profile);
        root = array;
        place = root;
    } else {
        root = lmx_node_new_profiled(&arena, profile);
        place = lmx_struct_new_profiled(root, &arena, profile);
        LMX_ARRAY_QUAL_CHECK(root != NULL && place != NULL);
        if (!root || !place) goto done;
        LMX_ARRAY_QUAL_CHECK(lmx_arena_refs_open_profiled(&arena, root, 4, profile) == 0);
        LMX_ARRAY_QUAL_CHECK(lmx_arena_refs_open_profiled(&arena, place, 1, profile) == 0);
        array = lmx_array_ref_new_child_profiled(place, LMX_TYPE_ARRAY_OF_LMX, 2, &arena, profile);
        LMX_ARRAY_QUAL_CHECK(lmx_arena_ref_store(root, 0, place) == 0);
        LMX_ARRAY_QUAL_CHECK(lmx_arena_ref_store(place, 0, array) == 0);
        LMX_ARRAY_QUAL_CHECK(lmx_arena_ref_store(root, 1, array) == 0);
    }
    element = lmx_struct_new_profiled(array, &arena, profile);
    LMX_ARRAY_QUAL_CHECK(element != NULL && array != NULL);
    if (!element || !array) goto done;
    LMX_ARRAY_QUAL_CHECK(lmx_arena_refs_open_profiled(&arena, element, 1, profile) == 0);
    value = lmx_int_new_profiled(&arena, profile);
    LMX_ARRAY_QUAL_CHECK(value != NULL);
    LMX_ARRAY_QUAL_CHECK(lmx_int_store_known(value, 9) == 0);
    LMX_ARRAY_QUAL_CHECK(lmx_arena_ref_store(element, 0, value) == 0);
    scalar = lmx_array_new_child_profiled(array, LMX_TYPE_ARRAY_OF_INT, 2, &arena, profile);
    pointers = lmx_array_new_typed_child_profiled(root, LMX_TYPE_ARRAY_OF_POINTER_BASE + 2048,
        1, &arena, profile, sizeof(int *), lmx_array_qual_pointer_read, lmx_array_qual_pointer_write);
    empty = lmx_array_new_child_profiled(root, LMX_TYPE_ARRAY_OF_INT, 0, &arena, profile);
    LMX_ARRAY_QUAL_CHECK(scalar != NULL && pointers != NULL && empty != NULL);
    if (!scalar || !pointers || !empty) goto done;
    LMX_ARRAY_QUAL_CHECK(lmx_arena_ref_store(array, 0, element) == 0);
    LMX_ARRAY_QUAL_CHECK(lmx_arena_ref_store(array, 1, scalar) == 0);
    LMX_ARRAY_QUAL_CHECK(lmx_arena_ref_store(root, 2, pointers) == 0);
    LMX_ARRAY_QUAL_CHECK(lmx_arena_ref_store(root, 3, empty) == 0);
    *(int *)lmx_array_cell_in(&arena, scalar, 0) = 17;
    *(int *)lmx_array_cell_in(&arena, scalar, 1) = 41;
    LMX_ARRAY_QUAL_CHECK(lmx_pointer_store_in(&arena, lmx_array_cell_in(&arena, pointers, 0), lmx_array_cell_in(&arena, scalar, 1)) == 0);
    LMX_ARRAY_QUAL_CHECK(lmx_qualify_tree_preflight_full(&arena, root, NULL, NULL, 0, NULL, 0, NULL, 0) == LMX_QUALIFY_OK);
    /* Typed-pointer loads remain actual cell addresses, not primitive bits. */
    LMX_ARRAY_QUAL_CHECK(*(int *)lmx_pointer_value_in(&arena, lmx_array_cell_in(&arena, pointers, 0)) == 41);
    element->parent = profile;
    LMX_ARRAY_QUAL_CHECK(lmx_qualify_tree_preflight(&arena, root, NULL, NULL, 0, NULL, 0, NULL, 0) == LMX_QUALIFY_INVALID);
    element->parent = array;
    LMX_ARRAY_QUAL_CHECK(lmx_qualify_tree_preflight_full(&arena, root, NULL, NULL, 0, NULL, 0, NULL, 0) == LMX_QUALIFY_OK);
    value = lmx_int_new_owned(&arena);
    LMX_ARRAY_QUAL_CHECK(lmx_pointer_store_in(&arena, lmx_array_cell_in(&arena, pointers, 0), value) == 0);
    LMX_ARRAY_QUAL_CHECK(lmx_qualify_tree_preflight(&arena, root, NULL, NULL, 0, NULL, 0, NULL, 0) == LMX_QUALIFY_INVALID);
    LMX_ARRAY_QUAL_CHECK(lmx_pointer_store_in(&arena, lmx_array_cell_in(&arena, pointers, 0), lmx_array_cell_in(&arena, scalar, 1)) == 0);
    alien = lmx_node_new_profiled(&arena, profile);
    LMX_ARRAY_QUAL_CHECK(alien != NULL);
    LMX_ARRAY_QUAL_CHECK(lmx_qualify_tree_preflight(&arena, root, NULL, NULL, 0, NULL, 0, NULL, 0) == LMX_QUALIFY_OK);
    /* A shared physical profile is not permission to seal this other root. */
    LMX_ARRAY_QUAL_CHECK(lmx_qualify_tree_preflight_full(&arena, root, NULL, NULL, 0, NULL, 0, NULL, 0) == LMX_QUALIFY_INVALID);
done:
    LMX_ARRAY_QUAL_CHECK(lmx_arena_release(&arena) == 0);
    return 0;
}

static int lmx_array_graph_qualify_test(void) {
    lmx_array_qual_simple_array_root(0);
    lmx_array_qual_simple_array_root(1);
    lmx_array_qual_mixed_tree(0);
    lmx_array_qual_mixed_tree(1);
    printf("K07 common graph qualification: %d checks, %d failures\n", lmx_array_qual_checks, lmx_array_qual_failures);
    return lmx_array_qual_failures != 0;
}


#undef LMX_ARRAY_QUAL_CHECK
#endif
