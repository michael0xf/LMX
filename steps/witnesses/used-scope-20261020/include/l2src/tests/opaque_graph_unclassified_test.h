#ifndef LMX_TEST_OPAQUE_UNCLASSIFIED_H
#define LMX_TEST_OPAQUE_UNCLASSIFIED_H
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
extern LmxArena *l2_program_arena;
/* Test-only opaque door: same one-int shape as Model, but no layout or
   completed receiving correspondence. A catalog row is not that proof. */
static void *l2_test_opaque_unclassified(void)
{
    Lmx *value=lmx_node_new_owned(l2_program_arena);
    void *cell=lmx_int_new_owned(l2_program_arena);
    if(!value||!cell||lmx_arena_refs_open_owned(l2_program_arena,value,1U)||
       lmx_int_store_known(cell,7)||lmx_arena_ref_store(value,0U,cell))
        return NULL;
    return value;
}
#endif
