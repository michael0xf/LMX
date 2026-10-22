#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main call162_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int depth[6];
static unsigned long calls[6],adapters[6],fields[6],spans[6],copies[6],legacy[6];
static void **route_stack;
static size_t route_n,route_cap;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
 (void)site;
 if(route_n==route_cap){size_t next=route_cap?route_cap*2U:64U;void **grown=realloc(route_stack,next*sizeof *grown);if(!grown)exit(95);route_stack=grown;route_cap=next;}
 route_stack[route_n++]=fn;
 if(fn==(void*)l2_check_call_at){++depth[0];++calls[0];}
 if(fn==(void*)l2_emit_call_value){++depth[1];++calls[1];}
 if(fn==(void*)l2_rw_call_values){++depth[2];++calls[2];}
 if(fn==(void*)l2_check_held_call){++depth[3];++calls[3];}
 if(fn==(void*)l2_prep_held_call){++depth[4];++calls[4];}
 if(fn==(void*)l2_rw_mad_call){++depth[5];++calls[5];}
 for(int i=0;i<6;++i)if(depth[i]){
  if(fn==(void*)l2_path_steps_operand){++adapters[i];if(adapters[i]==1)for(size_t j=route_n>12?route_n-12:0;j<route_n;++j)fprintf(stderr,"CALL162 STACK phase=%d offset=%lld\n",i,(long long)((char*)route_stack[j]-(char*)call162_frontend_main));}
  if(fn==(void*)l2_value_fields)++fields[i];
  if(fn==(void*)l2_expr_span)++spans[i];
  if(fn==(void*)l2_bind_call_in)++copies[i];
  if(fn==(void*)l2_cf_actual_rec||fn==(void*)l2_cf_held||fn==(void*)l2_occ_actual||fn==(void*)l2_cf_actual_emit||fn==(void*)l2_rw_callable_actual)++legacy[i];
 }
}
void __cyg_profile_func_exit(void *fn,void *site){
 (void)site;
 if(fn==(void*)l2_check_call_at)--depth[0];
 if(fn==(void*)l2_emit_call_value)--depth[1];
 if(fn==(void*)l2_rw_call_values)--depth[2];
 if(fn==(void*)l2_check_held_call)--depth[3];
 if(fn==(void*)l2_prep_held_call)--depth[4];
 if(fn==(void*)l2_rw_mad_call)--depth[5];
 if(!route_n||route_stack[route_n-1]!=fn)exit(94);--route_n;
}
int main(int argc,char **argv) __attribute__((no_instrument_function));
int main(int argc,char **argv){
 int result=call162_frontend_main(argc,argv);
 const char *labels[]={"CHECK","NATIVE","RETAINED","HELD-CHECK","HELD-NATIVE","HELD-RETAINED"};
 for(int i=0;i<6;++i)fprintf(stderr,"CALL162 %s calls=%lu adapters=%lu fields=%lu old-spans=%lu synthetic-copies=%lu legacy-callables=%lu depth=%d\n",labels[i],calls[i],adapters[i],fields[i],spans[i],copies[i],legacy[i],depth[i]);
 free(route_stack);
 return result;
}
