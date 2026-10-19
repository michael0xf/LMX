#ifndef LMX_ARRAY_GRAPH_REPARENT_TEST_H
#define LMX_ARRAY_GRAPH_REPARENT_TEST_H
/* K07: a real Message-parent move copies a lost qualified graph, including
   Array roots, and redirects graph/header/T * cells through their actual C
   accessors. This is a kernel lifecycle proof, not L2 path-emission proof. */
#include <stdio.h>
#include <string.h>
static int lmx_array_reparent_checks, lmx_array_reparent_failures;
static int lmx_array_reparent_reads, lmx_array_reparent_writes;
static int lmx_array_reparent_local_writes;
static void *lmx_array_reparent_watched[2];
#define LMX_ARRAY_REPARENT_CHECK(x) do { ++lmx_array_reparent_checks; if (!(x)) { \
    ++lmx_array_reparent_failures; fprintf(stderr, "FAIL %d: %s\n", __LINE__, #x); } } while (0)
static void *lmx_array_reparent_read(void *cell) {
    ++lmx_array_reparent_reads;
    return *(int **)cell;
}
static int lmx_array_reparent_write(void *cell, void *value) {
    ++lmx_array_reparent_writes;
    if (cell == lmx_array_reparent_watched[0] || cell == lmx_array_reparent_watched[1]) ++lmx_array_reparent_local_writes;
    *(int **)cell = value;
    return 0;
}
static LmxThread *lmx_array_reparent_thread(LmxArena *arena) {
    Lmx *graph = lmx_node_new_owned(arena);
    LmxThread *thread = lmx_arena_take(arena, sizeof *thread, LMX_DOMAIN_KIND_MSG_RECORD, LMX_DOMAIN_THREAD);
    LmxPost *mail = lmx_arena_take(arena, sizeof *mail, LMX_DOMAIN_KIND_POST, LMX_DOMAIN_POST);
    LmxSchedule *slot = lmx_arena_take(arena, sizeof *slot, LMX_DOMAIN_KIND_SCHEDULE, LMX_DOMAIN_SCHEDULE);
    void *children = lmx_list_new_owned(LMX_TYPE_ARRAY_OF_POINTER_BASE + LMX_DOMAIN_THREAD, arena);
    if (!graph || !thread || !mail || !slot || !children) return NULL;
    if (lmx_post_init(arena, mail) != LMX_POST_OK ||
        lmx_schedule_init(slot, arena, thread, 1000) != LMX_SCHEDULE_OK ||
        lmx_thread_init(arena, thread, graph, mail, slot) != LMX_THREAD_OK ||
        lmx_thread_children_bind(thread, children, arena) != LMX_THREAD_OK) return NULL;
    return thread;
}
static void lmx_array_reparent_case(int array_root) {
    LmxArena donor, moved, destination;
    LmxThread *owner = NULL, *child = NULL, *next = NULL;
    Lmx *profile, *source, *graph, *copied;
    LmxArray *array, *numbers, *source_pointers, *local, *pointers, *new_array, *new_numbers;
    LmxCopyMap lost;
    LmxReparentEdges edges;
    size_t i;
    int parent_edge = 0, pointer_edge = 0, donor_live = 1, status;
    memset(&donor, 0, sizeof donor);
    memset(&moved, 0, sizeof moved);
    memset(&destination, 0, sizeof destination);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_open(&donor) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_open(&moved) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_open(&destination) == 0);
    owner = lmx_array_reparent_thread(&donor);
    child = lmx_array_reparent_thread(&moved);
    next = lmx_array_reparent_thread(&destination);
    LMX_ARRAY_REPARENT_CHECK(owner && child && next);
    if (!owner || !child || !next) goto done;
    LMX_ARRAY_REPARENT_CHECK(lmx_thread_child_add(owner, child, &donor) == LMX_THREAD_OK);
    profile = lmx_node_new_owned(&donor);
    source = array_root ? NULL : lmx_node_new_profiled(&donor, profile);
    array = array_root
        ? lmx_array_ref_new_profiled(LMX_TYPE_ARRAY_OF_LMX, 2, &donor, profile)
        : lmx_array_ref_new_child_profiled(source, LMX_TYPE_ARRAY_OF_LMX, 2, &donor, profile);
    if (array_root) source = array;
    LMX_ARRAY_REPARENT_CHECK(profile && source && array);
    if (!profile || !source || !array) goto done;
    if (!array_root) {
        LMX_ARRAY_REPARENT_CHECK(lmx_arena_refs_open_profiled(&donor, source, 1, profile) == 0);
        LMX_ARRAY_REPARENT_CHECK(lmx_arena_ref_store(source, 0, array) == 0);
    }
    numbers = lmx_array_new_child_profiled(array, LMX_TYPE_ARRAY_OF_INT, 2, &donor, profile);
    source_pointers = lmx_array_new_typed_child_profiled(array, LMX_TYPE_ARRAY_OF_POINTER_BASE + 2048,
        1, &donor, profile, sizeof(int *), lmx_array_reparent_read, lmx_array_reparent_write);
    LMX_ARRAY_REPARENT_CHECK(numbers && source_pointers);
    if (!numbers || !source_pointers) goto done;
    *(int *)lmx_array_cell_in(&donor, numbers, 0) = 11;
    *(int *)lmx_array_cell_in(&donor, numbers, 1) = 29;
    *(int **)lmx_array_cell_in(&donor, source_pointers, 0) = lmx_array_cell_in(&donor, numbers, 1);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_ref_store(array, 0, numbers) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_ref_store(array, 1, source_pointers) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_qualify_tree_preflight_full(&donor, source, NULL, NULL, 0, NULL, 0, NULL, 0) == LMX_QUALIFY_OK);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_seal_profile(&donor, profile) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_reparent_profile_root(&donor, profile) == source);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_refs_open_owned(&donor, lmx_thread_message(owner)->graph, 1) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_ref_store(lmx_thread_message(owner)->graph, 0, source) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_range_import_profile(&moved, &donor, profile) == 0);
    graph = lmx_thread_message(child)->graph;
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_refs_open_owned(&moved, graph, 1) == 0);
    local = lmx_array_ref_new_child_profiled(graph, LMX_TYPE_ARRAY_OF_LMX, 2, &moved, NULL);
    /* A real Lmx * parent member also points into the soon-lost profile. */
    pointers = lmx_array_new_typed_child_profiled(array, LMX_TYPE_ARRAY_OF_POINTER_BASE + 2048,
        2, &moved, NULL, sizeof(int *), lmx_array_reparent_read, lmx_array_reparent_write);
    LMX_ARRAY_REPARENT_CHECK(local && pointers);
    if (!local || !pointers) goto done;
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_ref_store(graph, 0, local) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_ref_store(local, 0, source) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_ref_store(local, 1, pointers) == 0);
    *(int **)lmx_array_cell_in(&moved, pointers, 0) = lmx_array_cell_in(&donor, numbers, 1);
    *(int **)lmx_array_cell_in(&moved, pointers, 1) = lmx_array_cell_in(&donor, numbers, 0);
    memset(&lost, 0, sizeof lost);
    memset(&edges, 0, sizeof edges);
    LMX_ARRAY_REPARENT_CHECK(lmx_reparent_scan(child, next, &lost, &edges) == LMX_REPARENT_OWNER);
    for (i = 0; i < edges.n; ++i) {
        LmxReparentEdge *edge = edges.data + i;
        if (edge->slot == &pointers->parent && edge->read == lmx_reparent_lmx_read && edge->write == lmx_reparent_lmx_write) parent_edge = 1;
        if (edge->slot == lmx_array_cell_in(&moved, pointers, 0) && edge->read == lmx_array_reparent_read && edge->write == lmx_array_reparent_write) pointer_edge = 1;
    }
    LMX_ARRAY_REPARENT_CHECK(parent_edge && pointer_edge && lost.n == 1);
    lmx_copy_map_dispose(&lost);
    lmx_reparent_edges_dispose(&edges);
    lmx_array_reparent_watched[0] = lmx_array_cell_in(&moved, pointers, 0);
    lmx_array_reparent_watched[1] = lmx_array_cell_in(&moved, pointers, 1);
    lmx_array_reparent_local_writes = 0;
    lmx_array_reparent_reads = lmx_array_reparent_writes = 0;
    status = lmx_reparent_prepare(child, next);
    LMX_ARRAY_REPARENT_CHECK(status == LMX_REPARENT_OK);
    if (status != LMX_REPARENT_OK) goto done;
    LMX_ARRAY_REPARENT_CHECK(lmx_thread_parent(child) == owner);
    copied = lmx_graph_value_in(&moved, local, 0);
    LMX_ARRAY_REPARENT_CHECK(copied && copied != source);
    if (!copied || copied == source) goto done;
    new_array = array_root ? copied : lmx_graph_value_in(&moved, copied, 0);
    new_numbers = lmx_graph_value_in(&moved, new_array, 0);
    LMX_ARRAY_REPARENT_CHECK(new_array && new_numbers && new_numbers != numbers);
    LMX_ARRAY_REPARENT_CHECK(pointers->parent == new_array && local->parent == graph);
    LMX_ARRAY_REPARENT_CHECK(lmx_array_reparent_reads > 0 && lmx_array_reparent_writes >= 3);
    LMX_ARRAY_REPARENT_CHECK(lmx_array_reparent_local_writes == 2);
    LMX_ARRAY_REPARENT_CHECK(*(int **)lmx_array_cell_in(&moved, pointers, 0) == lmx_array_cell_in(&moved, new_numbers, 1));
    LMX_ARRAY_REPARENT_CHECK(*(int **)lmx_array_cell_in(&moved, pointers, 1) == lmx_array_cell_in(&moved, new_numbers, 0));
    LMX_ARRAY_REPARENT_CHECK(lmx_thread_adopt(child, next) == LMX_THREAD_OK);
    LMX_ARRAY_REPARENT_CHECK(lmx_thread_parent(child) == next && lmx_thread_child_count(owner) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_post_close(&donor, owner->mail) == LMX_POST_OK);
    owner = NULL;
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_release(&donor) == 0);
    donor_live = 0;
    LMX_ARRAY_REPARENT_CHECK(**(int **)lmx_array_cell_in(&moved, pointers, 0) == 29);
    **(int **)lmx_array_cell_in(&moved, pointers, 0) = 57;
    LMX_ARRAY_REPARENT_CHECK(*(int *)lmx_array_cell_in(&moved, new_numbers, 1) == 57);
    LMX_ARRAY_REPARENT_CHECK(*(int *)lmx_array_cell_in(&moved, new_numbers, 0) == 11);
    source_pointers = lmx_graph_value_in(&moved, new_array, 1);
    LMX_ARRAY_REPARENT_CHECK(**(int **)lmx_array_cell_in(&moved, source_pointers, 0) == 57);
done:
    lmx_array_reparent_watched[0] = lmx_array_reparent_watched[1] = NULL;
    if (owner) LMX_ARRAY_REPARENT_CHECK(lmx_post_close(&donor, owner->mail) == LMX_POST_OK);
    if (child) LMX_ARRAY_REPARENT_CHECK(lmx_post_close(&moved, child->mail) == LMX_POST_OK);
    if (next) LMX_ARRAY_REPARENT_CHECK(lmx_post_close(&destination, next->mail) == LMX_POST_OK);
    if (donor_live) LMX_ARRAY_REPARENT_CHECK(lmx_arena_release(&donor) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_release(&moved) == 0);
    LMX_ARRAY_REPARENT_CHECK(lmx_arena_release(&destination) == 0);
}
static int lmx_array_graph_reparent_test(void) {
    lmx_array_reparent_case(0);
    lmx_array_reparent_case(1);
    printf("K07 common graph reparent: %d checks, %d failures\n", lmx_array_reparent_checks, lmx_array_reparent_failures);
    return lmx_array_reparent_failures != 0;
}
#endif
