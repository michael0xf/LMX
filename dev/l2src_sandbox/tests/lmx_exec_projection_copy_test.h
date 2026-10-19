#ifndef LMX_EXEC_PROJECTION_COPY_TEST_H
#define LMX_EXEC_PROJECTION_COPY_TEST_H
#include <stdio.h>
#include "l2src/lmx_walk.lm1.h"
#include "l2src/lmx_graph_copy_owned.lm1.h"
#include "l2src/lmx_implements.lm1.h"
#include "l2src/lmx_call.lm1.h"
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"

/* The same code graph, unchanged across copy: read, store, take an address
   and write through it. Both actual dispatch modes must observe the values.
   C is the kernel test builder, not a second language path implementation. */
static Lmx *root_new(LmxArena *arena, size_t n)
{
    Lmx *root = lmx_node_new_owned(arena);
    return root && !lmx_arena_refs_open_owned(arena, root, n) ? root : 0;
}

static Lmx *frame(LmxArena *arena, Lmx *roles, Lmx *parent,
                  size_t slot, int op, size_t n)
{
    Lmx *result = lmx_walk_frame(arena, roles, parent, op, n);
    return result && !lmx_arena_ref_store(parent, slot, result) ? result : 0;
}

static int native_places(void *owner, void **refs, size_t nargs, void *dest,
                         void **out, LmxArena *arena, Lmx *code)
{
    int mode, *address;
    void *cell = lmx_arena_ref_value((Lmx *)owner,
        lmx_implements_exec_index(arena, code, 0));
    if (out) *out = 0;
    if (nargs != 1 || !refs || !refs[0] || !dest || !out || !cell ||
        lmx_range_type_of(arena, cell) != LMX_TYPE_INT) return 1;
    mode = *(int *)refs[0];
    address = (int *)cell;
    if (mode == 1 && lmx_int_store_known(cell, 13)) return 1;
    if (mode == 2) *address = 21;
    *(int *)dest = *address;
    *out = dest;
    return 0;
}

static Lmx *edge_operand(LmxArena *arena, Lmx *roles, Lmx *parent, size_t slot)
{
    Lmx *of = frame(arena, roles, parent, slot, LMX_WALK_OP_OF_EDGE, 3);
    Lmx *node = of ? frame(arena, roles, of, 1, LMX_WALK_OP_NODE, 2) : 0;
    if (!node || lmx_walk_store_size(arena, node, 1, 0) ||
        lmx_walk_store_size(arena, of, 2, 0)) return 0;
    return of;
}

static int store_if(LmxArena *arena, Lmx *roles, Lmx *root,
                    size_t slot, int mode, int number)
{
    Lmx *branch = frame(arena, roles, root, slot, LMX_WALK_OP_IF, 3);
    Lmx *eq = branch ? frame(arena, roles, branch, 1, LMX_WALK_OP_EQ, 3) : 0;
    Lmx *arg = eq ? frame(arena, roles, eq, 1, LMX_WALK_OP_ARG, 4) : 0;
    Lmx *lit = eq ? frame(arena, roles, eq, 2, LMX_WALK_OP_LIT, 2) : 0;
    Lmx *body = root_new(arena, 1), *put, *target;
    if (!arg || !lit || !body || lmx_walk_store_size(arena, arg, 1, 0) ||
        lmx_walk_store_int(arena, arg, 3, 0) ||
        lmx_walk_store_int(arena, lit, 1, mode) || lmx_arena_ref_store(branch, 2, body)) return 1;
    body->parent = branch;
    put = frame(arena, roles, body, 0, LMX_WALK_OP_PUT, 3);
    if (!put) return 1;
    if (mode == 2) {
        Lmx *deref = frame(arena, roles, put, 1, LMX_WALK_OP_DEREF, 3);
        Lmx *address = deref ? frame(arena, roles, deref, 1, LMX_WALK_OP_ADDRESS, 3) : 0;
        target = address ? edge_operand(arena, roles, address, 1) : 0;
        if (!target || lmx_walk_store_int(arena, deref, 2, 0) ||
            lmx_walk_store_int(arena, address, 2, 0)) return 1;
    } else if (!edge_operand(arena, roles, put, 1)) return 1;
    lit = frame(arena, roles, put, 2, LMX_WALK_OP_LIT, 2);
    return !lit || lmx_walk_store_int(arena, lit, 1, number);
}

static Lmx *places_program(LmxArena *arena, Lmx *roles, int permuted)
{
    Lmx *root = root_new(arena, 5);
    Lmx *ret;
    if (!root || lmx_walk_store_int(arena, root, permuted ? 1 : 0, permuted ? 9 : 5) ||
        lmx_walk_store_int(arena, root, 2, 77) ||
        store_if(arena, roles, root, permuted ? 0 : 1, 1, 13) ||
        store_if(arena, roles, root, 3, 2, 21)) return 0;
    ret = frame(arena, roles, root, 4, LMX_WALK_OP_RET, 2);
    if (!ret || !edge_operand(arena, roles, ret, 1)) return 0;
    return root;
}

static int matrix(LmxArena *arena, LmxWalkContext *context,
                  const char *label, Lmx *root)
{
    int mode, engine, status, expected, number, failures = 0;
    Lmx *input = root_new(arena, 1);
    LmxEntry native = root->native;
    if (!input || native != (LmxEntry)native_places) return 100;
    for (mode = 0; mode < 3; ++mode) {
        expected = mode == 0 ? 9 : mode == 1 ? 13 : 21;
        for (engine = 0; engine < 2; ++engine) {
            void *out = 0, *args[1];
            LmxWalkValue result = {0};
            int good;
            if (lmx_int_store_known(lmx_arena_ref_value(root, 1), 9) ||
                lmx_walk_store_int(arena, input, 0, mode)) return 100;
            args[0] = lmx_arena_ref_value(input, 0);
            number = -999;
            if (!engine) {
                status = lmx_call_prim(arena, root, root, args, 1, &number, &out);
                good = !status && out && number == expected;
            } else {
                root->native = 0;
                status = lmx_walk_run(context, root, args, 1, &result);
                root->native = native;
                number = result.number;
                good = !status && result.present && result.type == LMX_TYPE_INT && number == expected;
            }
            good = good && lmx_int_value_known(lmx_arena_ref_value(root, 1)) == expected &&
                   lmx_int_value_known(lmx_arena_ref_value(root, 2)) == 77;
            fprintf(stderr, "%s %s mode=%d status=%d value=%d expected=%d neighbour=%d %s\n",
                    label, engine ? "walker" : "native", mode, status, number, expected,
                    lmx_int_value_known(lmx_arena_ref_value(root, 2)), good ? "OK" : "FAIL");
            failures += !good;
        }
    }
    return failures;
}

static int lmx_exec_projection_copy_test(void)
{
    LmxArena arena = {0}, other = {0};
    LmxScratch scratch = {0}, other_scratch = {0};
    LmxPool pool = {0}, other_pool = {0};
    LmxWalkContext context = {0}, other_context = {0};
    Lmx *roles, *source, *value, *copy = 0, *cross = 0, *receiving_frame, *wrapper, *wrapped_cross = 0, *nested, *partial = 0;
    Lmx *anchors[4];
    size_t selectors[] = {0, 0, 0, 0}, slots[] = {0, 1, 3, 4}, lengths[] = {1, 1, 1, 1};
    LmxImplEntry identity = {0};
    size_t map[] = {1, 0, 2, 3, 4, 1, 0, 2, 3, 4};
    int failures = 0;
    size_t i;
    if (lmx_arena_open(&arena) || lmx_scratch_open(&scratch, &arena, &pool, 64)) return 2;
    roles = lmx_walk_roles_open(&arena);
    source = roles ? places_program(&arena, roles, 0) : 0;
    value = roles ? places_program(&arena, roles, 1) : 0;
    if (!source || !value) return 2;
    /* A real positional reception stored in frame cells is independent of
       the execution projection. It is not reachable from the copied graph. */
    receiving_frame = root_new(&arena, 10);
    if (!receiving_frame) return 2;
    for (i = 0; i < 10; ++i)
        if (lmx_walk_store_size(&arena, receiving_frame, i, i % 5)) return 2;
    identity.frame = receiving_frame;
    identity.n = 5;
    if (lmx_implements_register(&arena, value, value, &identity) != LMX_IMPLEMENTS_YES ||
        lmx_implements_exec_register(&arena, value, source, map, 5) != LMX_IMPLEMENTS_YES) return 2;
    value->native = (LmxEntry)native_places;
    context.arena = &arena; context.scratch = &scratch; context.roles = roles;
    failures += matrix(&arena, &context, "original", value);
    if (lmx_int_store_known(lmx_arena_ref_value(value, 1), 9) ||
        lmx_graph_copy_owned(value, &arena, &arena, &copy) || !copy) return 2;
    failures += copy == value || copy->native != value->native ||
        lmx_arena_ref_value(copy, 1) == lmx_arena_ref_value(value, 1);
    failures += matrix(&arena, &context, "copy", copy);
    failures += lmx_int_value_known(lmx_arena_ref_value(value, 1)) != 9;
    if (lmx_arena_open(&other) || lmx_scratch_open(&other_scratch, &other, &other_pool, 64) ||
        lmx_graph_copy_owned(value, &arena, &other, &cross) || !cross) return 2;
    other_context.arena = &other; other_context.scratch = &other_scratch;
    other_context.roles = lmx_walk_roles_open(&other);
    if (!other_context.roles) return 2;
    wrapper = root_new(&arena, 1);
    if (!wrapper || lmx_arena_ref_store(wrapper, 0, value)) return 2;
    value->parent = wrapper;
    if (lmx_graph_copy_owned(wrapper, &arena, &other, &wrapped_cross) || !wrapped_cross) return 2;
    nested = lmx_arena_ref_struct(wrapped_cross, 0);
    if (!nested) return 2;
    /* The public used-copy API omits only the unused neighbour. Its existing
       policy clears native; this is walker/holes evidence, not native proof. */
    for (i = 0; i < 4; ++i) anchors[i] = value;
    if (lmx_graph_copy_part_used_owned(value, &arena, &other, 0, 0,
            anchors, selectors, slots, lengths, 4, 4, &partial) || !partial) return 2;
    failures += partial->native != 0;
    lmx_scratch_close(&scratch); lmx_arena_release(&arena);
    failures += matrix(&other, &other_context, "cross_after_source_release", cross);
    failures += matrix(&other, &other_context, "nested_cross_after_source_release", nested);
    {
        Lmx *input = root_new(&other, 1);
        int mode;
        if (!input) return 2;
        for (mode = 0; mode < 3; ++mode) {
            LmxWalkValue result = {0};
            void *args[1];
            int status, expected = mode == 0 ? 9 : mode == 1 ? 13 : 21;
            if (lmx_int_store_known(lmx_arena_ref_value(partial, 1), 9) ||
                lmx_walk_store_int(&other, input, 0, mode)) return 2;
            args[0] = lmx_arena_ref_value(input, 0);
            status = lmx_walk_run(&other_context, partial, args, 1, &result);
            failures += status || !result.present || result.type != LMX_TYPE_INT ||
                result.number != expected ||
                lmx_int_value_known(lmx_arena_ref_value(partial, 1)) != expected;
            fprintf(stderr, "partial walker mode=%d status=%d type=%d value=%d expected=%d\n",
                    mode, status, result.type, result.number, expected);
        }
        failures += !lmx_implements_holes(&other, partial) ||
            lmx_arena_ref_value(partial, 2) != 0 ||
            lmx_implements_exec_index(&other, partial, 0) != 1 ||
            lmx_implements_exec_index(&other, partial, 2) != (size_t)-1;
    }
    fprintf(stderr, "mapped-copy places positive: %d failures\n", failures);
    lmx_scratch_close(&other_scratch); lmx_arena_release(&other);
    return failures != 0;
}
#endif
