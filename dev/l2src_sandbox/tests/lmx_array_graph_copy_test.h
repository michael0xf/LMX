#ifndef LMX_ARRAY_GRAPH_COPY_TEST_H
#define LMX_ARRAY_GRAPH_COPY_TEST_H
/* K07 header, parent, typed backing, alias and saved-address copy proof.
   Native entry identity is checked, not execution/admission of an Array. */
#include <stdio.h>
#include <string.h>

static int lmx_array_copy_checks, lmx_array_copy_failures;
#define LMX_ARRAY_COPY_CHECK(x) do { ++lmx_array_copy_checks; if (!(x)) { ++lmx_array_copy_failures; \
    fprintf(stderr, "FAIL %d: %s\n", __LINE__, #x); } } while (0)

static void lmx_array_copy_native(void) { }
static void *lmx_array_copy_int_pointer_read(void *cell) { return *(int **)cell; }
static int lmx_array_copy_int_pointer_write(void *cell, void *value) {
    *(int **)cell = (int *)value;
    return 0;
}

static int lmx_array_graph_copy_case(int array_root, int same_arena) {
    LmxArena source_arena, destination_arena;
    LmxArena *destination;
    Lmx *root, *place, *element, *copied = NULL, *new_root, *new_place, *new_element;
    LmxArray *array, *scalar, *pointers, *empty;
    LmxArray *new_array, *new_scalar, *new_pointers, *new_empty;
    int *cell, *new_cell;
    void *new_pointer_cell;
    int before = lmx_array_copy_failures;
    memset(&source_arena, 0, sizeof source_arena);
    memset(&destination_arena, 0, sizeof destination_arena);
    destination = same_arena ? &source_arena : &destination_arena;
    LMX_ARRAY_COPY_CHECK(lmx_arena_open(&source_arena) == 0);
    LMX_ARRAY_COPY_CHECK(lmx_arena_open(&destination_arena) == 0);
    root = lmx_node_new_owned(&source_arena);
    place = lmx_struct_new_owned(root, &source_arena);
    LMX_ARRAY_COPY_CHECK(root != NULL && place != NULL);
    LMX_ARRAY_COPY_CHECK(lmx_arena_refs_open_owned(&source_arena, root, 6) == 0);
    LMX_ARRAY_COPY_CHECK(lmx_arena_refs_open_owned(&source_arena, place, 1) == 0);
    array = lmx_array_ref_new_child_profiled(place, LMX_TYPE_ARRAY_OF_LMX, 1, &source_arena, NULL);
    element = lmx_struct_new_owned(array, &source_arena);
    scalar = lmx_array_new_child_profiled(place, LMX_TYPE_ARRAY_OF_INT, 3, &source_arena, NULL);
    pointers = lmx_array_new_typed_child_profiled(place, LMX_TYPE_ARRAY_OF_POINTER_BASE + 2048,
        1, &source_arena, NULL, sizeof(int *), lmx_array_copy_int_pointer_read, lmx_array_copy_int_pointer_write);
    empty = lmx_array_new_child_profiled(place, LMX_TYPE_ARRAY_OF_INT, 0, &source_arena, NULL);
    LMX_ARRAY_COPY_CHECK(array != NULL && element != NULL && scalar != NULL && pointers != NULL && empty != NULL);
    if (!array || !element || !scalar || !pointers || !empty) goto done;
    array->native = lmx_array_copy_native;
    cell = (int *)lmx_array_cell_in(&source_arena, scalar, 1);
    LMX_ARRAY_COPY_CHECK(cell != NULL);
    if (cell == NULL) goto done;
    *cell = 17;
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_store(root, 0, place) == 0);
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_store(place, 0, array) == 0);
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_store(array, 0, element) == 0);
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_store(root, 1, array) == 0);
    /* Saved backing cell precedes its Array header in graph visit order. */
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_store(root, 2, cell) == 0);
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_store(root, 3, scalar) == 0);
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_store(root, 4, pointers) == 0);
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_store(root, 5, empty) == 0);
    LMX_ARRAY_COPY_CHECK(lmx_pointer_store_in(&source_arena, lmx_array_cell_in(&source_arena, pointers, 0), cell) == 0);
    {
        int status = lmx_graph_copy_owned(array_root ? array : root, &source_arena, destination, &copied);
        LMX_ARRAY_COPY_CHECK(status == LMX_GRAPH_COPY_OK);
        if (status != LMX_GRAPH_COPY_OK || copied == NULL) {
            fprintf(stderr, "COPY status=%d ArrayRoot=%d SameArena=%d\n", status, array_root, same_arena);
            goto done;
        }
    }
    if (array_root) {
        new_array = copied;
        new_place = new_array->parent;
        new_root = new_place ? new_place->parent : NULL;
    } else {
        new_root = copied;
        new_place = lmx_arena_ref_struct(new_root, 0);
        new_array = new_place ? lmx_arena_ref_struct(new_place, 0) : NULL;
    }
    LMX_ARRAY_COPY_CHECK(new_root != NULL && new_place != NULL && new_array != NULL);
    if (!new_root || !new_place || !new_array) goto done;
    LMX_ARRAY_COPY_CHECK(new_root != root && new_place != place && new_array != array);
    LMX_ARRAY_COPY_CHECK(new_root->parent == NULL && new_place->parent == new_root && new_array->parent == new_place);
    LMX_ARRAY_COPY_CHECK(new_array->native == lmx_array_copy_native);
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_struct(new_root, 0) == new_place);
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_value(new_root, 1) == new_array);
    new_element = lmx_graph_value_in(destination, new_array, 0);
    LMX_ARRAY_COPY_CHECK(new_element != NULL && new_element != element && new_element->parent == new_array);
    new_scalar = lmx_arena_ref_value(new_root, 3);
    new_pointers = lmx_arena_ref_value(new_root, 4);
    new_empty = lmx_arena_ref_value(new_root, 5);
    LMX_ARRAY_COPY_CHECK(new_scalar != NULL && new_pointers != NULL && new_empty != NULL);
    if (!new_scalar || !new_pointers || !new_empty) goto done;
    LMX_ARRAY_COPY_CHECK(new_scalar != scalar && new_scalar->parent == new_place);
    LMX_ARRAY_COPY_CHECK(new_pointers != pointers && new_pointers->parent == new_place);
    LMX_ARRAY_COPY_CHECK(new_empty != empty && new_empty->parent == new_place);
    LMX_ARRAY_COPY_CHECK(new_empty->array.size == 0 && new_empty->array.data == NULL);
    new_cell = lmx_array_cell_in(destination, new_scalar, 1);
    LMX_ARRAY_COPY_CHECK(new_cell != NULL && new_cell != cell);
    if (new_cell == NULL) goto done;
    LMX_ARRAY_COPY_CHECK(lmx_arena_ref_value(new_root, 2) == new_cell);
    new_pointer_cell = lmx_array_cell_in(destination, new_pointers, 0);
    LMX_ARRAY_COPY_CHECK(new_pointer_cell != NULL);
    if (new_pointer_cell == NULL) goto done;
    LMX_ARRAY_COPY_CHECK(lmx_pointer_value_in(destination, new_pointer_cell) == new_cell);
    LMX_ARRAY_COPY_CHECK(lmx_range_cell_pool(destination, new_pointer_cell)->pointer_read == lmx_array_copy_int_pointer_read);
    LMX_ARRAY_COPY_CHECK(array->parent == place && place->parent == root && array->native == lmx_array_copy_native);
    if (!same_arena) LMX_ARRAY_COPY_CHECK(lmx_arena_release(&source_arena) == 0);
    LMX_ARRAY_COPY_CHECK(*new_cell == 17);
    **(int **)new_pointer_cell = 29;
    LMX_ARRAY_COPY_CHECK(*new_cell == 29);
    LMX_ARRAY_COPY_CHECK(*(int *)lmx_arena_ref_value(new_root, 2) == 29);
done:
    LMX_ARRAY_COPY_CHECK(lmx_arena_release(&source_arena) == 0);
    LMX_ARRAY_COPY_CHECK(lmx_arena_release(&destination_arena) == 0);
    return lmx_array_copy_failures != before;
}

static int lmx_array_graph_copy_test(void) {
    lmx_array_graph_copy_case(0, 0);
    lmx_array_graph_copy_case(1, 0);
    lmx_array_graph_copy_case(0, 1);
    lmx_array_graph_copy_case(1, 1);
    printf("K07 common graph copy: %d checks, %d failures\n", lmx_array_copy_checks, lmx_array_copy_failures);
    return lmx_array_copy_failures != 0;
}


#undef LMX_ARRAY_COPY_CHECK
#endif
