#ifndef LMX_TEST_REENTRY_COPY_OBSERVER_H
#define LMX_TEST_REENTRY_COPY_OBSERVER_H
#include <stdio.h>

/* Test-only observation of the actual merge return, never a graph/name scan.
   The source R() and bare-R value routes remain separate compiler debt. */
static Lmx *l2_test_reentry_original;
static Lmx *l2_test_reentry_copy;
static LmxArena *l2_test_reentry_arena;
static int l2_test_reentry_captures;

static void l2_test_reentry_capture(int status, Lmx **operands, size_t count,
    LmxArena *dst, Lmx **out)
{
    if (status == 0 && count == 1 && out != 0 && *out != 0) {
        l2_test_reentry_original = operands[0];
        l2_test_reentry_copy = *out;
        l2_test_reentry_arena = dst;
        ++l2_test_reentry_captures;
    }
}

static int l2_test_reentry_merge(Lmx **operands, size_t count, Lmx *body,
    Lmx *container, LmxArena *src, LmxArena *dst, LmxMergePair **overrides,
    size_t override_count, Lmx **out)
{
    int status = l2_driver_merge_owned(operands, count, body, container,
                                     src, dst, overrides, override_count, out);
    l2_test_reentry_capture(status, operands, count, dst, out);
    return status;
}

static int l2_test_reentry_merge_profiles(Lmx **operands, size_t count, Lmx *body,
    Lmx *container, LmxArena *src, LmxArena *dst, Lmx **profiles,
    size_t profile_count, LmxMergePair **overrides, size_t override_count,
    Lmx **out)
{
    int status = l2_driver_merge_profiles_owned(operands, count, body, container,
        src, dst, profiles, profile_count, overrides, override_count, out);
    l2_test_reentry_capture(status, operands, count, dst, out);
    return status;
}

static int l2_test_reentry_dispatch(int walked_original)
{
    void *result = 0;
    if (l2_test_reentry_captures != 1 || l2_test_reentry_original == 0 ||
        l2_test_reentry_copy == 0 ||
        l2_test_reentry_copy == l2_test_reentry_original)
        return 91;
    if (lmx_range_classify(l2_test_reentry_arena, l2_test_reentry_copy) != LMX_KIND_STRUCT)
        return 92;
    if ((l2_test_reentry_original->native == 0) != (walked_original != 0))
        return 93;
    /* Test-only forced walk, exactly as WalkRoot. The pre-clear native status
       is diagnostic, not a requirement on future merge implementations. */
    printf("reentry copied native before clear: %d\n", l2_test_reentry_copy->native != 0);
    l2_test_reentry_copy->native = 0;
    if (l2_test_reentry_copy->native != 0)
        return 94;
    return lmx_call_prim(l2_test_reentry_arena, l2_test_reentry_copy,
                         l2_test_reentry_copy, 0, 0, 0, &result);
}

#undef lmx_merge_owned
#define lmx_merge_owned l2_test_reentry_merge
#undef lmx_merge_profiles_owned
#define lmx_merge_profiles_owned l2_test_reentry_merge_profiles
#endif
