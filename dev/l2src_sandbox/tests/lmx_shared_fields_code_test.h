#include "lmx_shared_fields_test.h"

static void check_code(LmxArena *arena, Lmx *code)
{
    LmxWalkContext context;
    LmxWalkFrame frame;
    LmxWalkValue value;
    Lmx *data = lmx_graph_node_in(arena, lmx_graph_value_in(arena, code, 1));
    Lmx *address;
    void *element;
    int status;
    memset(&context, 0, sizeof context); memset(&frame, 0, sizeof frame);
    CHECK(data != NULL);
    if (!data) return;
    context.arena = arena; frame.arena = arena; frame.context = &context;
    frame.node = data; frame.source = data; frame.code = code;
    element = lmx_graph_value_in(arena, data, 1);
    status = lmx_walk_eval(&frame, code, &value);
    CHECK(status == LMX_WALK_OK && value.kind == LMX_WALK_VALUE_NUMBER && value.number == 31);
    address = lmx_walk_frame(arena, NULL, code, LMX_WALK_OP_ADDRESS, 3);
    CHECK(address != NULL);
    if (!address) return;
    CHECK(lmx_graph_ref_store_in(arena, address, 1, code) == 0);
    CHECK(lmx_graph_ref_store_in(arena, address, 2, lmx_pointer_new_owned(LMX_TYPE_POINTER_BASE + LMX_TYPE_INT, arena)) == 0);
    status = lmx_walk_eval(&frame, address, &value);
    CHECK(status == LMX_WALK_OK && value.ref == element);
    if (status == LMX_WALK_OK && value.ref == element) *(int *)value.ref = 47;
    status = lmx_walk_eval(&frame, code, &value);
    CHECK(status == LMX_WALK_OK && value.kind == LMX_WALK_VALUE_NUMBER && value.number == 47);
}

static int field_view_code_test(void)
{
    LmxArena source, destination;
    Lmx *owner, *data, *code, *copy = NULL;
    void *fields[3];
    int status;
    memset(&source, 0, sizeof source); memset(&destination, 0, sizeof destination);
    CHECK(lmx_arena_open(&source) == 0 && lmx_arena_open(&destination) == 0);
    owner = lmx_node_new_owned(&source); data = lmx_node_new_owned(&source);
    code = lmx_struct_new_profiled(owner, &source, NULL);
    CHECK(owner && data && code);
    if (!owner || !data || !code) goto done;
    CHECK(lmx_arena_refs_open_owned(&source, owner, 3) == 0);
    CHECK(lmx_arena_refs_open_owned(&source, data, 2) == 0);
    CHECK(lmx_walk_store_size(&source, owner, 0, 1) == 0);
    CHECK(lmx_graph_ref_store_in(&source, owner, 1, lmx_walk_role_cell(&source, LMX_WALK_OP_AT, NULL)) == 0);
    CHECK(lmx_graph_ref_store_in(&source, owner, 2, data) == 0);
    CHECK(lmx_walk_store_int(&source, data, 1, 31) == 0);
    fields[0] = lmx_graph_cell_in(&source, owner, 1);
    fields[1] = lmx_graph_cell_in(&source, owner, 2);
    fields[2] = lmx_graph_cell_in(&source, owner, 0);
    code->array.size = 3;
    CHECK(lmx_graph_fields_bind(&source, code, fields) == 0);
    check_code(&source, code);
    CHECK(lmx_int_store_known(lmx_graph_value_in(&source, data, 1), 31) == 0);
    status = lmx_graph_copy_owned(code, &source, &destination, &copy);
    printf("indirect_code_copy=%d\n", status);
    CHECK(status == LMX_GRAPH_COPY_OK && copy != NULL);
    CHECK(lmx_arena_release(&source) == 0);
    if (status == LMX_GRAPH_COPY_OK && copy) check_code(&destination, copy);
done:
    CHECK(lmx_arena_release(&source) == 0 && lmx_arena_release(&destination) == 0);
    printf("field_view_code: %d checks, %d failures\n", checks, failures);
    return failures != 0;
}
