/* Research probe, NOT a new accepted graph ABI or a production workaround.
   The field occurrence is an ordinary Lmx view of the ONE existing void *
   variable cell. No duplicate value cell, name registry, opcode or wrapper
   around primitive element storage is added. */
#include <stdio.h>
#include <string.h>

static int checks, failures;
#define CHECK(x) do { ++checks; if (!(x)) { ++failures; fprintf(stderr, "FAIL %d: %s\n", __LINE__, #x); } } while (0)

static Lmx *field_occurrence(LmxArena *arena, Lmx *scope, size_t index, Lmx *profile)
{
    Lmx *place = lmx_field_place_new(arena, scope, index);
    return place && lmx_range_profile(arena, place) == profile ? place : NULL;
}

static void case_view(int array_first)
{
    LmxArena arena, destination;
    Lmx *profile, *scope, *place, *copy = NULL, *new_scope, *new_place, *new_array;
    LmxArray *array;
    void *saved;
    int qualify, copied;
    memset(&arena, 0, sizeof arena);
    memset(&destination, 0, sizeof destination);
    CHECK(lmx_arena_open(&arena) == 0);
    CHECK(lmx_arena_open(&destination) == 0);
    profile = lmx_node_new_owned(&arena);
    scope = lmx_node_new_profiled(&arena, profile);
    CHECK(scope != NULL);
    if (!scope) goto done;
    CHECK(lmx_arena_refs_open_profiled(&arena, scope, 3, profile) == 0);
    place = field_occurrence(&arena, scope, 0, profile);
    CHECK(place != NULL);
    if (!place) goto done;
    array = lmx_array_new_child_profiled(place, LMX_TYPE_ARRAY_OF_INT, 2, &arena, profile);
    CHECK(array != NULL);
    if (!array) goto done;
    CHECK(lmx_arena_ref_store(scope, 0, array) == 0);
    *(int *)lmx_array_cell_in(&arena, array, 0) = 41;
    *(int *)lmx_array_cell_in(&arena, array, 1) = 73;
    CHECK(lmx_arena_ref_store(scope, 1, lmx_int_new_profiled(&arena, profile)) == 0);
    saved = lmx_pointer_new_profiled(LMX_TYPE_POINTER_BASE + 4096, &arena, profile);
    CHECK(saved != NULL);
    CHECK(lmx_pointer_store_in(&arena, saved, lmx_arena_ref_cell(scope, 0)) == 0);
    CHECK(lmx_arena_ref_store(scope, 2, saved) == 0);
    CHECK(array->parent == place && place->parent == scope);
    CHECK(lmx_arena_ref_cell(place, 0) == lmx_arena_ref_cell(scope, 0));
    CHECK(lmx_arena_ref_value(place, 0) == array);
    qualify = lmx_qualify_tree_preflight_full(&arena, scope, NULL, NULL, 0, NULL, 0, NULL, 0);
    printf("array_first=%d qualification=%d\n", array_first, qualify);
    CHECK(qualify == LMX_QUALIFY_OK);
    copied = lmx_graph_copy_owned(array_first ? array : scope, &arena, &destination, &copy);
    printf("array_first=%d copy=%d\n", array_first, copied);
    CHECK(copied == LMX_GRAPH_COPY_OK && copy != NULL);
    if (copied != LMX_GRAPH_COPY_OK || !copy) goto done;
    new_scope = array_first ? copy->parent->parent : copy;
    new_array = lmx_arena_ref_struct(new_scope, 0);
    new_place = new_array ? new_array->parent : NULL;
    CHECK(new_place && new_place != place && new_place->parent == new_scope);
    CHECK(new_place && lmx_arena_ref_cell(new_place, 0) == lmx_arena_ref_cell(new_scope, 0));
    CHECK(lmx_pointer_value_in(&destination, lmx_arena_ref_value(new_scope, 2)) == lmx_arena_ref_cell(new_scope, 0));
    CHECK(new_array && *(int *)lmx_graph_cell_in(&destination, new_array, 0) == 41);
    CHECK(new_array && *(int *)lmx_graph_cell_in(&destination, new_array, 1) == 73);
done:
    CHECK(lmx_arena_release(&arena) == 0);
    CHECK(lmx_arena_release(&destination) == 0);
}

static void case_place_validation(void)
{
    LmxArena arena;
    Lmx forged, *scope, *place;
    LmxArray *array;
    LmxPool *nodes;
    size_t before;
    memset(&arena, 0, sizeof arena);
    memset(&forged, 0, sizeof forged);
    CHECK(lmx_arena_open(&arena) == 0);
    scope = lmx_node_new_owned(&arena);
    CHECK(scope != NULL);
    if (!scope) goto done;
    CHECK(lmx_arena_refs_open_owned(&arena, scope, 1) == 0);
    place = lmx_field_place_new(&arena, scope, 0);
    CHECK(place && place->parent == scope && place->array.size == 1 && !place->native);
    if (!place) goto done;
    array = lmx_array_new_child_profiled(place, LMX_TYPE_ARRAY_OF_INT, 1, &arena, NULL);
    CHECK(array != NULL);
    if (!array) goto done;
    CHECK(lmx_arena_ref_store(scope, 0, array) == 0);
    nodes = lmx_arena_find(&arena, LMX_KIND_STRUCT, LMX_TYPE_STRUCT);
    CHECK(nodes != NULL);
    before = lmx_pool_count(nodes);
    CHECK(lmx_field_place_new(NULL, scope, 0) == NULL);
    CHECK(lmx_field_place_new(&arena, NULL, 0) == NULL);
    CHECK(lmx_field_place_new(&arena, scope, 1) == NULL);
    CHECK(lmx_field_place_new(&arena, scope, (size_t)-1) == NULL);
    CHECK(lmx_field_place_new(&arena, array, 0) == NULL);
    CHECK(lmx_field_place_new(&arena, &forged, 0) == NULL);
    CHECK(lmx_pool_count(nodes) == before);
    CHECK(lmx_graph_ref_cell_in(&arena, place, 0) == lmx_graph_ref_cell_in(&arena, scope, 0));
    CHECK(lmx_graph_value_in(&arena, place, 0) == array && array->parent == place);
done:
    CHECK(lmx_arena_release(&arena) == 0);
}

static int field_view_test(void)
{
    case_place_validation();
    case_view(0);
    case_view(1);
    printf("field_view_probe: %d checks, %d failures\n", checks, failures);
    return failures ? 1 : 0;
}
