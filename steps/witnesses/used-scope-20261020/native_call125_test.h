#ifndef LMX_NATIVE_CALL125_TEST_H
#define LMX_NATIVE_CALL125_TEST_H
#include "l2src/tests/opaque_declared_views_test.h"
#include "l2src/lmx_call.lm1.h"
static unsigned l2_call125_source_calls,l2_call125_raw_calls;
static void *l2_call125_raw(void){
 ++l2_call125_raw_calls;return l2_test_opaque_declared();
}
/* Explicit test service chooses an actual native method at runtime. It does
   not manufacture a Model: both result fields come from the common call.
   Fresh independent candidates avoid conflicting admissions from prior runs. */
static void *l2_call125_select(int choice,LmxWalkValue *context){
 ++l2_call125_source_calls;l2_test_declared_raw=NULL;
 Lmx *fn=lmx_arena_ref_struct(l2_program_unit,choice?8U:7U);void *result=NULL;
 if(!fn||!fn->native||lmx_call_prim_values(l2_program_arena,fn,fn,NULL,0,NULL,&result,NULL,context))abort();
 if(choice==2&&context)context->references=NULL;
 if(choice==3)result=NULL;
 return result;
}
#endif
