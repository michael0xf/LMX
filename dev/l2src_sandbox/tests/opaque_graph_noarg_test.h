#ifndef LMX_TEST_OPAQUE_GRAPH_NOARG_H
#define LMX_TEST_OPAQUE_GRAPH_NOARG_H
/* Test-only foreign door. In this fixture include/Model/Good occupy root
   children 0/1/2. The consumer independently asserts candidate == Good.
   This does not register a map or bypass source-level receiving admission. */
extern Lmx *l2_program_unit;
static void *l2_test_opaque_graph_noarg(void)
{
    return lmx_arena_ref_value(l2_program_unit, 2U);
}
#endif
