#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main source163_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static unsigned long calls,projections,raw,adapters,fields;
static int depth;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *at){
 (void)at;
 if(fn==(void*)l2_reference_source_value){++calls;++depth;}
 if(depth){
  if(fn==(void*)l2_reference_value_core)++projections;
  if(fn==(void*)l2_reference_source||fn==(void*)l2_reference_source_core||fn==(void*)l2_reference_fields)++raw;
  if(fn==(void*)l2_path_steps_operand)++adapters;
  if(fn==(void*)l2_value_fields)++fields;
 }
}
void __cyg_profile_func_exit(void *fn,void *at){(void)at;if(fn==(void*)l2_reference_source_value)--depth;}
int main(int argc,char **argv) __attribute__((no_instrument_function));
int main(int argc,char **argv){
 int result=source163_frontend_main(argc,argv);
 fprintf(stderr,"SOURCE163 calls=%lu projections=%lu raw=%lu adapters=%lu fields=%lu depth=%d\n",calls,projections,raw,adapters,fields,depth);
 return result;
}
