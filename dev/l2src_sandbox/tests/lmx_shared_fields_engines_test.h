#include "lmx_shared_fields_test.h"

/* Native kernel consumer: the completed implements map selects one logical
   field, the common resolver returns its PHYSICAL cell, and the Array pool
   returns its typed element. No second search/projection follows either. */
static int *native_prepared_element(LmxArena *arena, Lmx *view, Lmx *model,
                                   void ***field_address)
{
    size_t physical;
    Lmx *array;
    if (lmx_implements_slot(arena, view, model, 0, &physical) != 0) return NULL;
    *field_address = lmx_graph_cell_in(arena, view, physical);
    if (!*field_address) return NULL;
    array = lmx_graph_node_in(arena, **field_address);
    return array ? lmx_graph_cell_in(arena, array, 1) : NULL;
}

static int field_view_engines_test(void)
{
    LmxArena arena;
    Lmx *owner, *view, *a, *b, *model, *roles, *of, *lit, *elem, *index, *address, *at;
    LmxWalkContext context;
    LmxWalkFrame frame;
    LmxWalkValue value;
    LmxWalkPlace place;
    size_t permutation[4] = {1, 0, 1, 0};
    void *fields[2], **field_address = NULL;
    int *element;
    int status;
    memset(&arena, 0, sizeof arena);
    memset(&context, 0, sizeof context);
    memset(&frame, 0, sizeof frame);
    CHECK(lmx_arena_open(&arena) == 0);
    owner = lmx_node_new_owned(&arena); view = lmx_struct_new_profiled(owner, &arena, NULL);
    model = lmx_node_new_owned(&arena); roles = lmx_walk_roles_open(&arena);
    CHECK(owner && view && model && roles);
    if (!owner || !view || !model || !roles) goto done;
    CHECK(lmx_arena_refs_open_owned(&arena, owner, 2) == 0);
    CHECK(lmx_arena_refs_open_owned(&arena, model, 2) == 0);
    a = lmx_array_new_child_profiled(owner, LMX_TYPE_ARRAY_OF_INT, 2, &arena, NULL);
    b = lmx_array_new_child_profiled(owner, LMX_TYPE_ARRAY_OF_INT, 2, &arena, NULL);
    CHECK(a && b);
    if (!a || !b) goto done;
    CHECK(lmx_graph_ref_store_in(&arena, owner, 0, a) == 0 && lmx_graph_ref_store_in(&arena, owner, 1, b) == 0);
    CHECK(lmx_graph_ref_store_in(&arena, model, 0, a) == 0 && lmx_graph_ref_store_in(&arena, model, 1, b) == 0);
    *(int *)lmx_graph_cell_in(&arena, a, 0) = 11; *(int *)lmx_graph_cell_in(&arena, a, 1) = 23;
    *(int *)lmx_graph_cell_in(&arena, b, 0) = 37; *(int *)lmx_graph_cell_in(&arena, b, 1) = 41;
    fields[0] = lmx_graph_cell_in(&arena, owner, 1); fields[1] = lmx_graph_cell_in(&arena, owner, 0);
    view->array.size = 2;
    CHECK(lmx_graph_fields_bind(&arena, view, fields) == 0);
    CHECK(lmx_implements_register_map(&arena, view, model, permutation, 2, NULL) == LMX_IMPLEMENTS_YES);
    element = native_prepared_element(&arena, view, model, &field_address);
    CHECK(element == lmx_graph_cell_in(&arena, a, 1));
    CHECK(field_address == lmx_graph_cell_in(&arena, owner, 0));
    if (!element || !field_address) goto done;
    CHECK(*element == 23);
    *element = 83;
    CHECK(*(int *)lmx_graph_cell_in(&arena, a, 1) == 83);
    *field_address = NULL;
    CHECK(lmx_graph_value_in(&arena, owner, 0) == NULL && lmx_graph_value_in(&arena, view, 1) == NULL);
    *field_address = a;
    of = lmx_walk_frame(&arena, roles, owner, LMX_WALK_OP_OF, 4);
    lit = lmx_walk_frame(&arena, roles, of, LMX_WALK_OP_LIT, 2);
    elem = lmx_walk_frame(&arena, roles, owner, LMX_WALK_OP_ELEM, 3);
    index = lmx_walk_frame(&arena, roles, elem, LMX_WALK_OP_LIT, 2);
    address = lmx_walk_frame(&arena, roles, owner, LMX_WALK_OP_ADDRESS, 3);
    at = lmx_walk_frame(&arena, roles, owner, LMX_WALK_OP_AT, 3);
    CHECK(of && lit && elem && index && address && at);
    if (!of || !lit || !elem || !index || !address || !at) goto done;
    CHECK(lmx_graph_ref_store_in(&arena, lit, 1, view) == 0);
    CHECK(lmx_graph_ref_store_in(&arena, of, 1, lit) == 0 && lmx_graph_ref_store_in(&arena, of, 3, model) == 0);
    CHECK(lmx_walk_store_size(&arena, of, 2, 0) == 0 && lmx_walk_store_size(&arena, index, 1, 1) == 0);
    CHECK(lmx_graph_ref_store_in(&arena, elem, 1, of) == 0 && lmx_graph_ref_store_in(&arena, elem, 2, index) == 0);
    CHECK(lmx_graph_ref_store_in(&arena, address, 1, elem) == 0);
    CHECK(lmx_graph_ref_store_in(&arena, address, 2, lmx_pointer_new_owned(LMX_TYPE_POINTER_BASE + LMX_TYPE_INT, &arena)) == 0);
    CHECK(lmx_graph_ref_store_in(&arena, at, 1, view) == 0 && lmx_walk_store_size(&arena, at, 2, 1) == 0);
    context.arena = &arena; context.roles = roles;
    frame.context = &context; frame.arena = &arena; frame.roles = roles;
    frame.node = view; frame.source = view;
    CHECK(lmx_walk_eval(&frame, elem, &value) == LMX_WALK_OK && value.number == 83);
    CHECK(lmx_walk_place(&frame, elem, 1, &place) == LMX_WALK_OK && place.address == element);
    memset(&value, 0, sizeof value); value.present = 1; value.kind = LMX_WALK_VALUE_NUMBER; value.type = LMX_TYPE_INT; value.number = 97;
    CHECK(lmx_walk_value_store(&arena, &place, &value) == LMX_WALK_OK);
    CHECK(*element == 97 && *(int *)lmx_graph_cell_in(&arena, a, 1) == 97);
    CHECK(lmx_walk_eval(&frame, address, &value) == LMX_WALK_OK && value.ref == element);
    if (value.ref == element) *(int *)value.ref = 109;
    CHECK(lmx_walk_eval(&frame, elem, &value) == LMX_WALK_OK && value.number == 109);
    CHECK(*(int *)lmx_graph_cell_in(&arena, b, 1) == 41);
    status = lmx_walk_place(&frame, at, 1, &place);
    CHECK(status == LMX_WALK_OK && place.descriptor && place.address == a && place.storage == field_address);
    if (status == LMX_WALK_OK && place.descriptor && place.storage == field_address) {
        *(void **)place.storage = NULL;
        CHECK(lmx_graph_value_in(&arena, owner, 0) == NULL);
        *(void **)place.storage = a;
    }
done:
    CHECK(lmx_arena_release(&arena) == 0);
    printf("field_view_engines: %d checks, %d failures\n", checks, failures);
    return failures != 0;
}
