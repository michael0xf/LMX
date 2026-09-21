/* Path A executable harness for tracked seed lm1/build/own.lm1.c
 * Does not modify the seed. Links against the seed's real implementation.
 * Compile with -I. -Ilm1/build so #include "l1src/p0.lm1.h" resolves,
 * plus lm1/build/own.lm1.c on the same command line.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "l1src/p0.lm1.h"

extern int lm_own_alloc_fails;
extern int lm_own_ok_left;

extern char *lm_own_copy_bytes(const char *source, size_t length);
extern void lm_own_delete_plain(void *object);
extern void *lm_own_new_zero(size_t size);

extern void lm_own_ptr_stack_init(LmOwnPtrStack *stack, LmOwnDelete delete_item);
extern void lm_own_ptr_stack_destroy(LmOwnPtrStack *stack);
extern int lm_own_ptr_stack_push(LmOwnPtrStack *stack, void *item);
extern void *lm_own_ptr_stack_pop(LmOwnPtrStack *stack);
extern void *lm_own_ptr_stack_top(const LmOwnPtrStack *stack);
extern void *lm_own_ptr_stack_at(const LmOwnPtrStack *stack, size_t index);

extern int lm_own_arena_init(LmOwnArena *arena);
extern void lm_own_arena_destroy(LmOwnArena *arena);
extern void *lm_own_arena_new_zero(LmOwnArena *arena, size_t size);
extern char *lm_own_arena_copy_bytes(LmOwnArena *arena, const char *source, size_t length);

static int g_checks;
static int g_fails;

static void expect(int ok, const char *label)
{
    g_checks += 1;
    if (!ok) {
        g_fails += 1;
        fprintf(stderr, "VM_OWN_FAIL %s\n", label);
    }
}

int main(void)
{
    char *copy;
    LmOwnPtrStack stack;
    char a = 'a', b = 'b', c = 'c';
    void *t;
    LmOwnArena arena;
    char *acopy;
    void *block;
    void *should_fail;

    g_checks = 0;
    g_fails = 0;
    lm_own_alloc_fails = 0;
    lm_own_ok_left = -1;

    /* 1) lm_own_copy_bytes: content + trailing NUL */
    copy = lm_own_copy_bytes("own", 3U);
    expect(copy != 0, "copy_bytes_alloc");
    expect(copy != 0 && copy[0] == 'o' && copy[1] == 'w' && copy[2] == 'n', "copy_bytes_content");
    expect(copy != 0 && copy[3] == '\0', "copy_bytes_nul");
    lm_own_delete_plain(copy);

    /* 2) pointer-stack push / top / pop / order */
    memset(&stack, 0, sizeof(stack));
    lm_own_ptr_stack_init(&stack, 0);
    expect(lm_own_ptr_stack_push(&stack, &a) == 0, "stack_push_a");
    expect(lm_own_ptr_stack_push(&stack, &b) == 0, "stack_push_b");
    expect(lm_own_ptr_stack_push(&stack, &c) == 0, "stack_push_c");
    expect(lm_own_ptr_stack_top(&stack) == &c, "stack_top_c");
    expect(lm_own_ptr_stack_at(&stack, 0U) == &a, "stack_at_0_a");
    expect(lm_own_ptr_stack_at(&stack, 1U) == &b, "stack_at_1_b");
    expect(lm_own_ptr_stack_at(&stack, 2U) == &c, "stack_at_2_c");
    t = lm_own_ptr_stack_pop(&stack);
    expect(t == &c, "stack_pop_c");
    t = lm_own_ptr_stack_pop(&stack);
    expect(t == &b, "stack_pop_b");
    t = lm_own_ptr_stack_pop(&stack);
    expect(t == &a, "stack_pop_a");
    expect(lm_own_ptr_stack_pop(&stack) == 0, "stack_pop_empty");
    lm_own_ptr_stack_destroy(&stack);

    /* 3) arena allocate / copy / destroy */
    memset(&arena, 0, sizeof(arena));
    expect(lm_own_arena_init(&arena) == 0, "arena_init");
    block = lm_own_arena_new_zero(&arena, 16U);
    expect(block != 0, "arena_new_zero");
    acopy = lm_own_arena_copy_bytes(&arena, "path-a", 6U);
    expect(acopy != 0 && acopy[0] == 'p' && acopy[5] == 'a' && acopy[6] == '\0', "arena_copy_bytes");
    lm_own_arena_destroy(&arena);
    expect(arena.allocations == 0, "arena_destroy_cleared");

    /* 4) portable allocation-failure control (lm_own_alloc_fails) */
    lm_own_alloc_fails = 1;
    should_fail = lm_own_new_zero(8U);
    expect(should_fail == 0, "alloc_fails_returns_null");
    expect(lm_own_alloc_fails == 0, "alloc_fails_consumed");
    should_fail = lm_own_new_zero(8U);
    expect(should_fail != 0, "alloc_recovers");
    lm_own_delete_plain(should_fail);
    lm_own_alloc_fails = 0;

    if (g_fails != 0) {
        fprintf(stderr, "VM_OWN_FAIL checks=%d fails=%d\n", g_checks, g_fails);
        return 1;
    }
    printf("VM_OWN_OK checks=%d\n", g_checks);
    return 0;
}
