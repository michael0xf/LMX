#ifndef LMX_NATIVE_RESULT124_FULL_TEST_H
#define LMX_NATIVE_RESULT124_FULL_TEST_H
#include "native_result124_test.h"
static unsigned l2_result124_bad_calls;
static void *l2_result124_bad(void){
 ++l2_result124_bad_calls;Lmx *v=lmx_node_new_owned(l2_program_arena);void *p=lmx_int_new_owned(l2_program_arena);
 if(!v||!p||lmx_arena_refs_open_owned(l2_program_arena,v,1)||lmx_int_store_known(p,5)||lmx_arena_ref_store(v,0,p))abort();return v;
}
#endif
