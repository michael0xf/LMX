#ifndef LMX_ARRAY_GRAPH_WALK_TEST_H
#define LMX_ARRAY_GRAPH_WALK_TEST_H
/* Actual kernel native/walker projected field-place proof. These C builders
   make the existing code graph, not another path resolver. This is not proof
   of the L2 frontend's still-open mixed path lowering or all K07 consumers. */
#include <stdio.h>
#include <string.h>
static int lmx_array_walk_checks, lmx_array_walk_failures;
#define LMX_ARRAY_WALK_CHECK(x) do { ++lmx_array_walk_checks; if (!(x)) { ++lmx_array_walk_failures; \
    fprintf(stderr, "FAIL %d: %s\n", __LINE__, #x); } } while (0)
static size_t lmx_array_walk_map[] = {1,0,1,0};

static Lmx *lmx_array_walk_node(LmxArena *arena, Lmx *parent, size_t width) {
    Lmx *node = parent ? lmx_struct_new_owned(parent, arena) : lmx_node_new_owned(arena);
    return node && (!width || !lmx_arena_refs_open_owned(arena, node, width)) ? node : NULL;
}
static Lmx *lmx_array_walk_frame(LmxArena *arena, Lmx *roles, Lmx *parent, size_t at, int op, size_t width) {
    Lmx *node = lmx_walk_frame(arena, roles, parent, op, width);
    return node && !lmx_arena_ref_store(parent, at, node) ? node : NULL;
}
static Lmx *lmx_array_walk_of(LmxArena *arena, Lmx *roles, Lmx *parent, size_t at, Lmx *array, Lmx *model) {
    Lmx *of = lmx_array_walk_frame(arena, roles, parent, at, LMX_WALK_OP_OF, 4);
    Lmx *literal = of ? lmx_array_walk_frame(arena, roles, of, 1, LMX_WALK_OP_LIT, 2) : NULL;
    if (!literal || lmx_arena_ref_store(literal, 1, array) ||
        lmx_walk_store_size(arena, of, 2, 0) || lmx_arena_ref_store(of, 3, model)) return NULL;
    return of;
}
static int lmx_array_walk_native_apply(int mode, void *owner, void **refs, size_t nargs, void *dest,
                          void **out, LmxArena *arena, Lmx *code) {
    Lmx *ret = lmx_arena_ref_struct(code, code->array.size - 1);
    Lmx *of = ret ? lmx_arena_ref_struct(ret, 1) : NULL;
    Lmx *model = of ? lmx_arena_ref_struct(of, 3) : NULL;
    size_t physical;
    int *address;
    (void)refs;
    if (!owner || !out || !dest || !model || nargs ||
        lmx_implements_slot(arena, owner, model, 0, &physical)) return 1;
    address = lmx_graph_value_in(arena, owner, physical);
    if (!address || lmx_range_type_of(arena, address) != LMX_TYPE_INT) return 1;
    if (mode == 1 && lmx_int_store_known(address, 31)) return 1;
    if (mode == 2) *address = 57;
    *(int *)dest = *address;
    *out = dest;
    return 0;
}
#define LMX_ARRAY_WALK_NATIVE(name, mode) static int name(void *owner, void **refs, size_t nargs, void *dest, \
    void **out, LmxArena *arena, Lmx *code) { return lmx_array_walk_native_apply(mode, owner, refs, nargs, dest, out, arena, code); }
LMX_ARRAY_WALK_NATIVE(lmx_array_walk_native_read, 0)
LMX_ARRAY_WALK_NATIVE(lmx_array_walk_native_store, 1)
LMX_ARRAY_WALK_NATIVE(lmx_array_walk_native_address, 2)

static Lmx *lmx_array_walk_program(LmxArena *arena, Lmx *roles, Lmx *parent, size_t at,
                      Lmx *array, Lmx *model, int mode) {
    Lmx *code = lmx_array_walk_node(arena, parent, mode ? 2 : 1);
    Lmx *ret, *put, *literal, *target;
    if (!code || lmx_arena_ref_store(parent, at, code)) return NULL;
    if (mode == 1) {
        put = lmx_array_walk_frame(arena, roles, code, 0, LMX_WALK_OP_PUT_OF, 5);
        literal = put ? lmx_array_walk_frame(arena, roles, put, 1, LMX_WALK_OP_LIT, 2) : NULL;
        if (!literal || lmx_arena_ref_store(literal, 1, array) || lmx_walk_store_size(arena, put, 2, 0) ||
            lmx_arena_ref_store(put, 4, model)) return NULL;
        literal = lmx_array_walk_frame(arena, roles, put, 3, LMX_WALK_OP_LIT, 2);
        if (!literal || lmx_walk_store_int(arena, literal, 1, 31)) return NULL;
    }
    if (mode == 2) {
        Lmx *deref, *address;
        put = lmx_array_walk_frame(arena, roles, code, 0, LMX_WALK_OP_PUT, 3);
        deref = put ? lmx_array_walk_frame(arena, roles, put, 1, LMX_WALK_OP_DEREF, 3) : NULL;
        address = deref ? lmx_array_walk_frame(arena, roles, deref, 1, LMX_WALK_OP_ADDRESS, 3) : NULL;
        target = address ? lmx_array_walk_of(arena, roles, address, 1, array, model) : NULL;
        if (!target || lmx_walk_store_int(arena, deref, 2, 0) || lmx_walk_store_int(arena, address, 2, 0)) return NULL;
        literal = lmx_array_walk_frame(arena, roles, put, 2, LMX_WALK_OP_LIT, 2);
        if (!literal || lmx_walk_store_int(arena, literal, 1, 57)) return NULL;
    }
    ret = lmx_array_walk_frame(arena, roles, code, mode ? 1 : 0, LMX_WALK_OP_RET, 2);
    if (!ret || !lmx_array_walk_of(arena, roles, ret, 1, array, model)) return NULL;
    code->native = (LmxEntry)(mode == 0 ? lmx_array_walk_native_read : mode == 1 ? lmx_array_walk_native_store : lmx_array_walk_native_address);
    return code;
}

static void lmx_array_walk_matrix(LmxArena *arena, LmxWalkContext *context, Lmx *bundle, const char *label) {
    Lmx *array = lmx_arena_ref_struct(bundle, 0);
    int mode, engine;
    for (mode = 0; mode < 3; ++mode) {
        Lmx *code = lmx_arena_ref_struct(bundle, 2 + mode);
        LmxEntry entry = code->native;
        for (engine = 0; engine < 2; ++engine) {
            int number = -1, status, expected = mode == 0 ? 11 : mode == 1 ? 31 : 57;
            void *out = NULL;
            LmxWalkValue value = {0};
            *(int *)lmx_array_cell_in(arena, array, 0) = 22;
            *(int *)lmx_array_cell_in(arena, array, 1) = 11;
            *(int *)lmx_array_cell_in(arena, array, 2) = 77;
            if (!engine) {
                status = lmx_call_prim(arena, code, array, NULL, 0, &number, &out);
                LMX_ARRAY_WALK_CHECK(status == 0 && out && number == expected);
            } else {
                code->native = NULL;
                status = lmx_walk_run(context, code, NULL, 0, &value);
                code->native = entry;
                LMX_ARRAY_WALK_CHECK(status == 0 && value.present && value.kind == LMX_WALK_VALUE_NUMBER &&
                       value.type == LMX_TYPE_INT && value.number == expected);
            }
            LMX_ARRAY_WALK_CHECK(*(int *)lmx_array_cell_in(arena, array, 1) == expected);
            LMX_ARRAY_WALK_CHECK(*(int *)lmx_array_cell_in(arena, array, 0) == 22);
            LMX_ARRAY_WALK_CHECK(*(int *)lmx_array_cell_in(arena, array, 2) == 77);
            fprintf(stderr, "%s %s mode%d status%d value%d expected%d\n", label,
                engine ? "walk" : "native", mode, status, engine ? value.number : number, expected);
        }
    }
}

static void lmx_array_walk_reject_raw(void) {
    /* Keep a malformed foreign domain separate: inserting it into a healthy
       arena intentionally prevents later typed allocation in that arena. */
    LmxArena arena = {0};
    LmxPool scratch_pool = {0};
    LmxScratch scratch = {0};
    LmxWalkContext context = {0};
    LmxWalkValue ignored = {0};
    LmxPool *raw;
    Lmx *roles, *bad, *length, *literal;
    LMX_ARRAY_WALK_CHECK(lmx_arena_open(&arena) == 0);
    LMX_ARRAY_WALK_CHECK(lmx_scratch_open(&scratch, &arena, &scratch_pool, 64) == LMX_SCRATCH_OK);
    roles = lmx_walk_roles_open(&arena);
    raw = lmx_pool_make(&arena, sizeof(VoidArray), sizeof(VoidArray), LMX_KIND_ARRAY, LMX_TYPE_ARRAY_OF_INT);
    bad = lmx_array_walk_node(&arena, NULL, 1);
    length = bad ? lmx_array_walk_frame(&arena, roles, bad, 0, LMX_WALK_OP_LENGTH, 2) : NULL;
    literal = length ? lmx_array_walk_frame(&arena, roles, length, 1, LMX_WALK_OP_LIT, 2) : NULL;
    LMX_ARRAY_WALK_CHECK(raw && literal);
    if (raw && literal) {
        LMX_ARRAY_WALK_CHECK(lmx_arena_ref_store(literal, 1, lmx_chunk_data(raw->head)) == 0);
        context.arena = &arena; context.scratch = &scratch; context.roles = roles;
        LMX_ARRAY_WALK_CHECK(lmx_walk_run(&context, bad, NULL, 0, &ignored) == LMX_WALK_INVALID);
    }
    lmx_scratch_close(&scratch);
    LMX_ARRAY_WALK_CHECK(lmx_arena_release(&arena) == 0);
}

static int lmx_array_walk_native_constant(void *owner, void **refs, size_t nargs, void *dest,
                               void **out, LmxArena *arena, Lmx *code) {
    (void)refs;
    (void)arena;
    if (!owner || !code || !dest || !out || nargs) return 1;
    *(int *)dest = 7;
    *out = dest;
    return 0;
}

/* The selected code container itself is an Array, not just its data. The
   body is the same ordinary graph in both routes; no Array-only interpreter
   or callback wrapper is installed. */
static void lmx_array_walk_code_routes(LmxArena *arena, LmxScratch *scratch, Lmx *roles,
                                        Lmx *code, const char *label) {
    LmxWalkContext context = {0};
    LmxWalkValue result = {0};
    Lmx *ret, *literal;
    LmxEntry native = code->native;
    int route = -1, status;
    LMX_ARRAY_WALK_CHECK(lmx_range_classify(arena, code) == LMX_KIND_ARRAY);
    LMX_ARRAY_WALK_CHECK(native == (LmxEntry)lmx_array_walk_native_constant);
    status = lmx_call_ready(arena, code);
    LMX_ARRAY_WALK_CHECK(status == LMX_CALL_OK);
    if (status == LMX_CALL_OK && native == (LmxEntry)lmx_array_walk_native_constant)
        status = lmx_call0_mode(arena, code, &route);
    LMX_ARRAY_WALK_CHECK(status == 7 && route == LMX_CALL_ROUTE_NATIVE);
    printf("Array code %s native value=%d route=%d\n", label, status, route);
    code->native = NULL;
    context.arena = arena; context.scratch = scratch; context.roles = roles;
    status = lmx_walk_run(&context, code, NULL, 0, &result);
    LMX_ARRAY_WALK_CHECK(status == LMX_WALK_OK && result.present && result.type == LMX_TYPE_INT && result.number == 7);
    printf("Array code %s walk status=%d value=%zu\n", label, status, result.number);
    ret = lmx_graph_value_in(arena, code, 0);
    literal = ret ? lmx_graph_value_in(arena, ret, 1) : NULL;
    LMX_ARRAY_WALK_CHECK(ret && literal && ret->parent == code && literal->parent == ret);
    code->native = native; /* unchanged graph, restore its saved entry for the copy checks */
}

static void lmx_array_walk_code_header(void) {
    LmxArena arena = {0}, target = {0};
    LmxScratch scratch = {0}, target_scratch = {0};
    LmxPool pool = {0}, target_pool = {0};
    Lmx *roles, *ret, *literal, *copy = NULL, *cross = NULL;
    LmxArray *code;
    LMX_ARRAY_WALK_CHECK(lmx_arena_open(&arena) == 0);
    LMX_ARRAY_WALK_CHECK(lmx_arena_open(&target) == 0);
    LMX_ARRAY_WALK_CHECK(lmx_scratch_open(&scratch, &arena, &pool, 64) == LMX_SCRATCH_OK);
    LMX_ARRAY_WALK_CHECK(lmx_scratch_open(&target_scratch, &target, &target_pool, 64) == LMX_SCRATCH_OK);
    roles = lmx_walk_roles_open(&arena);
    code = lmx_array_ref_new_owned(LMX_TYPE_ARRAY_OF_LMX, 1, &arena);
    ret = code ? lmx_array_walk_frame(&arena, roles, code, 0, LMX_WALK_OP_RET, 2) : NULL;
    literal = ret ? lmx_array_walk_frame(&arena, roles, ret, 1, LMX_WALK_OP_LIT, 2) : NULL;
    LMX_ARRAY_WALK_CHECK(roles && code && ret && literal);
    if (!roles || !code || !ret || !literal) goto done;
    LMX_ARRAY_WALK_CHECK(lmx_walk_store_int(&arena, literal, 1, 7) == 0);
    code->native = (LmxEntry)lmx_array_walk_native_constant;
    lmx_array_walk_code_routes(&arena, &scratch, roles, code, "original");
    LMX_ARRAY_WALK_CHECK(lmx_graph_copy_owned(code, &arena, &arena, &copy) == LMX_GRAPH_COPY_OK && copy && copy != code);
    if (copy) lmx_array_walk_code_routes(&arena, &scratch, roles, copy, "copy");
    LMX_ARRAY_WALK_CHECK(lmx_graph_copy_owned(code, &arena, &target, &cross) == LMX_GRAPH_COPY_OK && cross && cross != code);
    lmx_scratch_close(&scratch);
    LMX_ARRAY_WALK_CHECK(lmx_arena_release(&arena) == 0);
    roles = lmx_walk_roles_open(&target);
    LMX_ARRAY_WALK_CHECK(roles != NULL);
    if (cross && roles) lmx_array_walk_code_routes(&target, &target_scratch, roles, cross, "cross after source release");
done:
    lmx_scratch_close(&scratch);
    lmx_scratch_close(&target_scratch);
    LMX_ARRAY_WALK_CHECK(lmx_arena_release(&arena) == 0);
    LMX_ARRAY_WALK_CHECK(lmx_arena_release(&target) == 0);
}

static int lmx_array_graph_walk_test(void) {
    LmxArena arena = {0}, target = {0};
    LmxScratch scratch = {0}, target_scratch = {0};
    LmxPool pool = {0}, target_pool = {0};
    LmxWalkContext context = {0}, target_context = {0};
    Lmx *bundle, *model, *roles, *copy = NULL, *cross = NULL;
    LmxArray *array;
    int i;
    LMX_ARRAY_WALK_CHECK(lmx_arena_open(&arena) == 0);
    LMX_ARRAY_WALK_CHECK(lmx_arena_open(&target) == 0);
    LMX_ARRAY_WALK_CHECK(lmx_scratch_open(&scratch, &arena, &pool, 64) == LMX_SCRATCH_OK);
    LMX_ARRAY_WALK_CHECK(lmx_scratch_open(&target_scratch, &target, &target_pool, 64) == LMX_SCRATCH_OK);
    roles = lmx_walk_roles_open(&arena);
    bundle = lmx_array_walk_node(&arena, NULL, 5);
    model = lmx_array_walk_node(&arena, bundle, 2);
    array = lmx_array_new_child_profiled(bundle, LMX_TYPE_ARRAY_OF_INT, 3, &arena, NULL);
    LMX_ARRAY_WALK_CHECK(roles && bundle && model && array);
    if (!roles || !bundle || !model || !array) goto done;
    LMX_ARRAY_WALK_CHECK(lmx_walk_store_int(&arena, model, 0, 0) == 0);
    LMX_ARRAY_WALK_CHECK(lmx_walk_store_int(&arena, model, 1, 0) == 0);
    LMX_ARRAY_WALK_CHECK(lmx_arena_ref_store(bundle, 0, array) == 0 && lmx_arena_ref_store(bundle, 1, model) == 0);
    LMX_ARRAY_WALK_CHECK(lmx_implements_register_map(&arena, array, model, lmx_array_walk_map, 2, NULL) == LMX_IMPLEMENTS_YES);
    for (i = 0; i < 3; ++i) LMX_ARRAY_WALK_CHECK(lmx_array_walk_program(&arena, roles, bundle, 2 + i, array, model, i) != NULL);
    context.arena = &arena; context.scratch = &scratch; context.roles = roles;
    lmx_array_walk_matrix(&arena, &context, bundle, "original");
    lmx_array_walk_reject_raw();
    LMX_ARRAY_WALK_CHECK(lmx_graph_copy_owned(bundle, &arena, &arena, &copy) == LMX_GRAPH_COPY_OK && copy);
    if (copy) lmx_array_walk_matrix(&arena, &context, copy, "copy");
    LMX_ARRAY_WALK_CHECK(lmx_graph_copy_owned(bundle, &arena, &target, &cross) == LMX_GRAPH_COPY_OK && cross);
    target_context.arena = &target; target_context.scratch = &target_scratch;
    target_context.roles = lmx_walk_roles_open(&target);
    lmx_scratch_close(&scratch);
    LMX_ARRAY_WALK_CHECK(lmx_arena_release(&arena) == 0);
    if (cross) lmx_array_walk_matrix(&target, &target_context, cross, "cross after source release");
done:
    lmx_scratch_close(&target_scratch);
    LMX_ARRAY_WALK_CHECK(lmx_arena_release(&target) == 0);
    LMX_ARRAY_WALK_CHECK(lmx_arena_release(&arena) == 0);
    lmx_array_walk_code_header();
    printf("K07 native + walk mapped Array: %d checks, %d failures\n", lmx_array_walk_checks, lmx_array_walk_failures);
    return lmx_array_walk_failures != 0;
}


#undef LMX_ARRAY_WALK_CHECK
#undef LMX_ARRAY_WALK_NATIVE
#endif
