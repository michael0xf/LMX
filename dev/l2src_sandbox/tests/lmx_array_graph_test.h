#ifndef LMX_ARRAY_GRAPH_TEST_H
#define LMX_ARRAY_GRAPH_TEST_H

/* K07 physical-header/typed-cell/GC proof. This does not claim that all
   language paths, native dispatch, copy/merge or receiver admission have
   completed their Array migration. No replacement graph or runtime hook. */
#include <stddef.h>
#include <stdio.h>
#include <string.h>

static int lmx_array_graph_checks, lmx_array_graph_failures;
#define LMX_ARRAY_GRAPH_CHECK(test) do { ++lmx_array_graph_checks; if (!(test)) { ++lmx_array_graph_failures; \
    fprintf(stderr, "FAIL %d: %s\n", __LINE__, #test); } } while (0)

static void lmx_array_graph_native(void) { }
static void *lmx_array_graph_int_pointer_read(void *cell) { return *(int **)cell; }
static int lmx_array_graph_int_pointer_write(void *cell, void *value) {
    *(int **)cell = (int *)value;
    return 0;
}

static int lmx_array_graph_runtime_test(void) {
    LmxArena arena;
    Lmx *root, *arr_place, *element;
    LmxArray *array, *alias, *scalar, *empty, *nested, *pointers;
    LmxPool *pool;
    int value = 23;
    int *scalar_cell;
    void *pointer_cell;
    memset(&arena, 0, sizeof arena);
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_open(&arena) == 0);
    root = lmx_node_new_owned(&arena);
    LMX_ARRAY_GRAPH_CHECK(root != NULL);
    arr_place = lmx_struct_new_owned(root, &arena);
    LMX_ARRAY_GRAPH_CHECK(arr_place != NULL);
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_refs_open_owned(&arena, root, 2) == 0);
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_refs_open_owned(&arena, arr_place, 1) == 0);
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_ref_store(root, 0, arr_place) == 0);
    array = lmx_array_ref_new_child_profiled(arr_place, LMX_TYPE_ARRAY_OF_LMX, 2, &arena, NULL);
    LMX_ARRAY_GRAPH_CHECK(array != NULL);
    if (array == NULL) goto done;
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_ref_store(arr_place, 0, array) == 0);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_node_in(&arena, array) == array);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_node_in(&arena, arr_place) == arr_place);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_node_in(&arena, &array->array) == NULL);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_cell_in(&arena, arr_place, 0) == lmx_arena_ref_cell(arr_place, 0));
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_value_in(&arena, arr_place, 0) == array);
    LMX_ARRAY_GRAPH_CHECK(array->parent == arr_place && arr_place->parent == root);
    LMX_ARRAY_GRAPH_CHECK(array->native == NULL);
    LMX_ARRAY_GRAPH_CHECK(sizeof(LmxArray) == sizeof(Lmx));
    LMX_ARRAY_GRAPH_CHECK(offsetof(Lmx, parent) == 0);
    LMX_ARRAY_GRAPH_CHECK(offsetof(Lmx, array) >= sizeof(Lmx *) + sizeof(LmxEntry));
    LMX_ARRAY_GRAPH_CHECK((void *)&array->array != (void *)array);
    LMX_ARRAY_GRAPH_CHECK(lmx_range_classify(&arena, array) == LMX_KIND_ARRAY);
    LMX_ARRAY_GRAPH_CHECK(lmx_range_type_of(&arena, array) == LMX_TYPE_ARRAY_OF_LMX);
    LMX_ARRAY_GRAPH_CHECK(lmx_range_classify(&arena, &array->array) == LMX_KIND_NONE);
    LMX_ARRAY_GRAPH_CHECK(lmx_range_stride(&arena, array) == sizeof(Lmx));
    element = lmx_struct_new_owned(array, &arena);
    LMX_ARRAY_GRAPH_CHECK(element != NULL && element->parent == array);
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_ref_store(array, 0, element) == 0);
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_ref_struct(array, 0) == element);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_value_in(&arena, array, 0) == element);
    array->native = lmx_array_graph_native;
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_ref_store(root, 1, array) == 0);
    alias = (LmxArray *)lmx_arena_ref_value(root, 1);
    LMX_ARRAY_GRAPH_CHECK(alias == array && alias->parent == arr_place);
    LMX_ARRAY_GRAPH_CHECK(alias->native == lmx_array_graph_native);
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_ref_struct(alias, 0) == element);
    scalar = lmx_array_new_child_profiled(arr_place, LMX_TYPE_ARRAY_OF_INT, 3, &arena, NULL);
    LMX_ARRAY_GRAPH_CHECK(scalar != NULL);
    if (scalar == NULL) goto done;
    LMX_ARRAY_GRAPH_CHECK(scalar->parent == arr_place && scalar->native == NULL);
    LMX_ARRAY_GRAPH_CHECK(lmx_range_stride(&arena, scalar) == sizeof(Lmx));
    LMX_ARRAY_GRAPH_CHECK(lmx_range_stride(&arena, scalar->array.data) == sizeof(int));
    scalar_cell = (int *)lmx_array_cell_in(&arena, scalar, 1);
    LMX_ARRAY_GRAPH_CHECK(scalar_cell == (int *)scalar->array.data + 1);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_cell_in(&arena, scalar, 1) == scalar_cell);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_value_in(&arena, scalar, 1) == scalar_cell);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_node_in(&arena, scalar_cell) == NULL);
    if (scalar_cell != NULL) *scalar_cell = 41;
    LMX_ARRAY_GRAPH_CHECK(*(int *)lmx_array_cell_in(&arena, scalar, 1) == 41);
    LMX_ARRAY_GRAPH_CHECK(lmx_array_cell_in(&arena, scalar, 3) == NULL);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_cell_in(&arena, scalar, 3) == NULL);
    empty = lmx_array_new_owned(LMX_TYPE_ARRAY_OF_INT, 0, &arena);
    LMX_ARRAY_GRAPH_CHECK(empty != NULL && empty->parent == NULL && empty->native == NULL);
    LMX_ARRAY_GRAPH_CHECK(empty->array.size == 0 && empty->array.data == NULL);
    nested = lmx_array_ref_new_child_profiled(array, LMX_TYPE_ARRAY_OF_DESC, 1, &arena, NULL);
    LMX_ARRAY_GRAPH_CHECK(nested != NULL && nested->parent == array);
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_ref_store(nested, 0, scalar) == 0);
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_ref_value(nested, 0) == scalar && scalar->parent == arr_place);
    pointers = lmx_array_new_typed_child_profiled(arr_place,
        LMX_TYPE_ARRAY_OF_POINTER_BASE + 2048, 2, &arena, NULL,
        sizeof(int *), lmx_array_graph_int_pointer_read, lmx_array_graph_int_pointer_write);
    LMX_ARRAY_GRAPH_CHECK(pointers != NULL && pointers->parent == arr_place);
    if (pointers == NULL) goto done;
    pointer_cell = lmx_array_cell_in(&arena, pointers, 1);
    pool = lmx_range_cell_pool(&arena, pointer_cell);
    LMX_ARRAY_GRAPH_CHECK(pool != NULL && pool->type == LMX_TYPE_POINTER_BASE + 2048);
    LMX_ARRAY_GRAPH_CHECK(pool != NULL && pool->stride == sizeof(int *));
    LMX_ARRAY_GRAPH_CHECK(pool != NULL && pool->pointer_read == lmx_array_graph_int_pointer_read);
    LMX_ARRAY_GRAPH_CHECK(pool != NULL && pool->pointer_write == lmx_array_graph_int_pointer_write);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_value_in(&arena, pointers, 1) == pointer_cell);
    LMX_ARRAY_GRAPH_CHECK(lmx_pointer_store_in(&arena, pointer_cell, &value) == 0);
    LMX_ARRAY_GRAPH_CHECK(lmx_pointer_value_in(&arena, pointer_cell) == &value);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_value_in(&arena, pointers, 1) == pointer_cell);
    LMX_ARRAY_GRAPH_CHECK(**((int **)pointer_cell) == 23);
    LMX_ARRAY_GRAPH_CHECK(lmx_array_new_child_profiled(NULL, LMX_TYPE_ARRAY_OF_INT, 1, &arena, NULL) == NULL);
    LMX_ARRAY_GRAPH_CHECK(lmx_array_ref_new_child_profiled(NULL, LMX_TYPE_ARRAY_OF_LMX, 1, &arena, NULL) == NULL);
done:
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_release(&arena) == 0);
    LMX_ARRAY_GRAPH_CHECK(arena.blocks == NULL && arena.arrays == NULL);
    printf("K07 common-header construction: %d checks, %d failures\n", lmx_array_graph_checks, lmx_array_graph_failures);
    return lmx_array_graph_failures != 0;
}




static int lmx_array_graph_test(void) {
    LmxArena arena;
    Lmx *parent;
    LmxArray *array;
    LmxPool *parent_pool, *array_pool, *data_pool, *raw_pool;
    LmxChunk *parent_chunk, *array_chunk, *data_chunk;
    size_t raw_count;
    unsigned generation;
    LMX_ARRAY_GRAPH_CHECK(lmx_array_graph_runtime_test() == 0);
    memset(&arena, 0, sizeof arena);
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_open(&arena) == 0);
    parent = lmx_node_new_owned(&arena);
    array = lmx_array_new_child_profiled(parent, LMX_TYPE_ARRAY_OF_INT, 3, &arena, NULL);
    LMX_ARRAY_GRAPH_CHECK(parent != NULL && array != NULL);
    if (parent == NULL || array == NULL) goto done;
    parent_pool = lmx_range_cell_pool(&arena, parent);
    array_pool = lmx_range_cell_pool(&arena, array);
    data_pool = lmx_range_cell_pool(&arena, array->array.data);
    parent_chunk = lmx_pool_chunk_at(parent_pool, parent);
    array_chunk = lmx_pool_chunk_at(array_pool, array);
    data_chunk = lmx_pool_chunk_at(data_pool, array->array.data);
    LMX_ARRAY_GRAPH_CHECK(parent_chunk != NULL && array_chunk != NULL && data_chunk != NULL);
    LMX_ARRAY_GRAPH_CHECK(parent_chunk != array_chunk && array_chunk != data_chunk && data_chunk != parent_chunk);
    generation = lmx_arena_generation_next(&arena);
    LMX_ARRAY_GRAPH_CHECK(generation != 0);
    LMX_ARRAY_GRAPH_CHECK(lmx_gc_mark_value(&arena, array, generation, 0) == LMX_GC_OK);
    LMX_ARRAY_GRAPH_CHECK(array_chunk->mark == generation);
    LMX_ARRAY_GRAPH_CHECK(data_chunk->mark == generation);
    /* No reference from the Array's backing points to parent: only the
       common header's parent edge can keep this different typed pool live. */
    LMX_ARRAY_GRAPH_CHECK(parent_chunk->mark == generation);
    LMX_ARRAY_GRAPH_CHECK(lmx_gc_sweep(&arena, generation) == LMX_GC_OK);
    LMX_ARRAY_GRAPH_CHECK(lmx_range_classify(&arena, parent) == LMX_KIND_STRUCT);
    LMX_ARRAY_GRAPH_CHECK(lmx_range_classify(&arena, array) == LMX_KIND_ARRAY);
    LMX_ARRAY_GRAPH_CHECK(lmx_range_type_of(&arena, array->array.data) == LMX_TYPE_INT);
    LMX_ARRAY_GRAPH_CHECK(array->parent == parent);
    raw_pool = lmx_pool_make(&arena, sizeof(VoidArray), sizeof(VoidArray), LMX_KIND_ARRAY, LMX_TYPE_ARRAY_OF_INT);
    LMX_ARRAY_GRAPH_CHECK(raw_pool != NULL);
    raw_count = lmx_pool_count(raw_pool);
    LMX_ARRAY_GRAPH_CHECK(lmx_array_desc_new(&arena, raw_pool, 0, NULL) == NULL);
    LMX_ARRAY_GRAPH_CHECK(lmx_pool_count(raw_pool) == raw_count);
    LMX_ARRAY_GRAPH_CHECK(lmx_graph_node_in(&arena, lmx_chunk_data(raw_pool->head)) == NULL);
    LMX_ARRAY_GRAPH_CHECK(lmx_gc_mark_value(&arena, lmx_chunk_data(raw_pool->head), generation + 1, 0) == LMX_GC_INVALID);
    LMX_ARRAY_GRAPH_CHECK(lmx_array_desc_new(&arena, array_pool, 0, NULL) != NULL);
done:
    LMX_ARRAY_GRAPH_CHECK(lmx_arena_release(&arena) == 0);
    printf("K07 common-header + GC: %d checks, %d failures\n", lmx_array_graph_checks, lmx_array_graph_failures);
    return lmx_array_graph_failures != 0;
}


#undef LMX_ARRAY_GRAPH_CHECK
#endif
