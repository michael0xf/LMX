#define main inherited120_main
#include "value-transport120-test.c"
#undef main
#include "l2src/lmx_array_owned.lm1.h"
#include <signal.h>
#include <setjmp.h>
#define main l2_generated_main
#include BARRIER134_SOURCE
#undef main
static jmp_buf barrier_jump;
static volatile sig_atomic_t barrier_rejected;
static void barrier_abort(int sig){(void)sig;barrier_rejected=1;longjmp(barrier_jump,1);}
int main(int argc,char **argv){
 if(argc!=3)return 99;
 int sealed=atoi(argv[1]),must_reject=atoi(argv[2]);
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *program=node(a,4);if(l2_program_build(a,program,NULL))abort();
 Lmx *model=lmx_graph_ref_struct_in(a,program,0),*callee=lmx_graph_ref_struct_in(a,program,1),*profile=node(a,0);
 LmxArray *array=lmx_array_new_profiled(LMX_TYPE_ARRAY_OF_INT,2,a,profile);
 if(!model||!callee||!array||model->array.size!=1)abort();
 void *selected=lmx_array_cell_in(a,array,1),*neighbor=lmx_array_cell_in(a,array,0);
 if(lmx_int_store_known(selected,7)||lmx_int_store_known(neighbor,3))abort();
 Lmx *actual=node(a,1);put(actual,0,array);
 size_t map[]={0,0};char token;
 if(lmx_implements_register_map(a,actual,model,map,1,&token)!=LMX_IMPLEMENTS_YES)abort();
 if(sealed&&lmx_arena_seal_profile(a,profile))abort();
 ck(!!callee->native==BARRIER134_EXPECT_NATIVE,"actual source writer uses the requested engine");
 ck(lmx_int_value_known(selected)==7&&lmx_range_profile(a,selected)==profile,"actual indexed cell starts at7 in its exact profile");
 ck(!!lmx_range_sealed_profile(a,selected)==sealed,"the qualified-storage precondition is physical,not a source-name guess");
 LmxWalkValue value={0};lmx_walk_value_ref(&value,LMX_TYPE_LMX,actual);
 void *args[]={lmx_walk_value_storage(&value)},*raw=NULL;
 signal(SIGABRT,barrier_abort);
 if(setjmp(barrier_jump)==0)(void)lmx_call_prim_values(a,callee,callee,args,1,NULL,&raw,&value,NULL);
 signal(SIGABRT,SIG_DFL);
 ck(!!barrier_rejected==must_reject,"qualification refusal is observed in the actual writer,not in merge preparation");
 ck(lmx_int_value_known(selected)==(must_reject?7:9),"refusal precedes the physical write;the mutable/old-violation observation is actual9");
 ck(lmx_int_value_known(neighbor)==3,"the neighboring physical element remains3");
 printf("source indexed write barrier: %d checks, %d failures; native=%d; rejected=%d\n",checks,failures,BARRIER134_EXPECT_NATIVE,(int)barrier_rejected);
 fflush(stdout);
 /* SIGABRT is intercepted only by this C invariant fixture. Do not run
    another activation or pretend its aborted frames were normally unwound. */
 _Exit(failures!=0);
}
