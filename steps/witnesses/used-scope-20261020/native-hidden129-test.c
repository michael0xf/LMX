#include "codex_body123_inherited_channel.c"
#define main l2_generated_main
#ifndef ACTUAL128_SOURCE
#define ACTUAL128_SOURCE "codex_actual128_probe_01/unit.c"
#endif
#include ACTUAL128_SOURCE
#undef main
static void actual128_consumers(LmxArena *a,LmxWalkFrame *f,Lmx *roles,Lmx *r,LmxWalkValue *value,int source,int walked){
 Lmx *v=value->ref;int expected=source?9:7,neighbor=source?7:9;size_t mapped=(size_t)-1;
 int fit=v&&lmx_implements_slot(a,v,r,0,&mapped)==0;
 ck(value->present&&value->kind==LMX_WALK_VALUE_REFERENCE&&value->model==r&&value->references&&fit&&mapped==(size_t)source,"native actual CURRENT pair produces the real reordered R map,not a Model inferred from its raw pointer");
 if(walked){
  LmxWalkValue part={0};f->guarded=value;
  Lmx *path=op(a,roles,LMX_WALK_OP_OF,4);put(path,1,op(a,roles,LMX_WALK_OP_GUARDED,1));size_at(a,path,2,0);put(path,3,r);
  ck(lmx_walk_eval(f,path,&part)==LMX_WALK_OK&&part.number==expected&&read_at(a,v,r,2)==neighbor,"walked OF reads7/9 through native nested-actual map");
  Lmx *set=op(a,roles,LMX_WALK_OP_PUT,3);put(set,1,path);put(set,2,literal_int(a,roles,41));
  ck(lmx_walk_eval(f,set,&part)==LMX_WALK_OK&&read_at(a,v,r,0)==41&&read_at(a,v,r,2)==neighbor,"walked PUT uses the actual map and preserves its neighbor");
  Lmx *take=op(a,roles,LMX_WALK_OP_ADDRESS,3);put(take,1,path);void *pw=lmx_pointer_new_owned(LMX_TYPE_POINTER_BASE+LMX_TYPE_INT,a);if(!pw)abort();put(take,2,pw);
  ck(lmx_walk_eval(f,take,&part)==LMX_WALK_OK&&fit&&part.ref==lmx_graph_value_in(a,v,mapped),"walked address identifies the current physical int cell after nested native calls");
  if(part.ref)lmx_int_store_known(part.ref,43);
  f->guarded=NULL;
 }else{
  void **address=fit?lmx_graph_ref_cell_in(a,v,mapped):NULL;
  ck(fit&&read_at(a,v,r,0)==expected&&read_at(a,v,r,2)==neighbor,"native result is consumed as actual7/9 with its receiving map");
  ck(address&&lmx_int_store_known(*address,41)==0&&read_at(a,v,r,0)==41&&read_at(a,v,r,2)==neighbor,"native-result mapped store writes41 only");
  ck(address&&address==lmx_graph_ref_cell_in(a,v,(size_t)source),"native-result taken address is the actual reordered field");
  if(address)*address=number(a,43);
 }
 ck(v&&read_at(a,v,r,0)==43&&read_at(a,v,r,2)==neighbor,"reading after taken-address mutation observes43 and intact neighbor");
}
int main(void){
 (void)channel122_main();
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *program=node(a,56);if(l2_program_build(a,program,NULL))abort();
 Lmx *d=lmx_graph_ref_struct_in(a,program,1),*e=lmx_graph_ref_struct_in(a,program,2),*r=lmx_graph_ref_struct_in(a,program,5);
 Lmx *roles=lmx_walk_roles_open(a);test_parent=program;if(!roles)abort();
 LmxPool cells={0};LmxScratch scratch={0};if(lmx_scratch_open(&scratch,a,&cells,128)!=LMX_SCRATCH_OK)abort();
 LmxWalkContext ctx={0};ctx.arena=a;ctx.roles=roles;ctx.scratch=&scratch;
 LmxWalkFrame f={0};f.context=&ctx;f.arena=a;f.roles=roles;f.node=f.code=f.source=program;
 for(int source=0;source<2;++source){
  Lmx *echo=lmx_graph_ref_struct_in(a,program,32);void *args[]={number(a,source)},*raw=NULL;LmxWalkValue value={0};unsigned before=l2_call125_source_calls;
  int status=lmx_call_prim_values(a,echo,echo,args,1,NULL,&raw,NULL,&value);
  ck(status==0&&raw&&value.model==(source?e:d)&&value.references&&l2_call125_source_calls==before+1,"native caller supplies full CURRENT context to another ordinary universal native formal,once");
  const size_t methods[]={33,34,35,36,37,39,45,49,50,54};
  for(size_t k=0;k<10;++k)for(int walked=0;walked<2;++walked){
   size_t method=methods[k];Lmx *fn=lmx_graph_ref_struct_in(a,program,method);LmxWalkValue in={0},result={0};void *local[1],*out=NULL;
   int inputmethod=method==36||method==50;
   if(inputmethod){
    l2_test_declared_raw=NULL;
    Lmx *producer=lmx_graph_ref_struct_in(a,program,source?8:7);LmxWalkValue pair={0};
    if(lmx_call_prim_values(a,producer,producer,NULL,0,NULL,&out,NULL,&pair))abort();
    lmx_walk_value_ref_parts(&in,LMX_TYPE_POINTER_BASE+16,out,pair.model,pair.references);local[0]=lmx_walk_value_storage(&in);
   }else local[0]=number(a,source);
   void *original=in.ref;Lmx *model=in.model,*sheet=in.references;before=l2_call125_source_calls;
   actual128_trace=actual128_effects=0;
   if(walked){
    Lmx *sig=node(a,2);put(sig,0,lmx_graph_ref_struct_in(a,fn,0));put(sig,1,lmx_graph_ref_struct_in(a,fn,1));
    Lmx *call=op(a,roles,LMX_WALK_OP_CALL,6);put(call,1,fn);put(call,3,sig);
    put(call,5,inputmethod?op(a,roles,LMX_WALK_OP_GUARDED,1):literal_int(a,roles,source));f.guarded=inputmethod?&in:NULL;
    status=lmx_walk_eval(&f,call,&result);f.guarded=NULL;out=result.ref;
   }else{
    status=lmx_call_prim_values(a,fn,fn,local,1,NULL,&out,inputmethod?&in:NULL,&result);
    /* The native ABI has separate payload and context outputs. Build the
       consumer's Value from those outputs,not from an empty context.ref. */
    lmx_walk_value_ref_parts(&result,LMX_TYPE_LMX,out,result.model,result.references);
   }
   ck(status==0&&out&&l2_call125_source_calls==before+(inputmethod?0U:1U),"ordinary native caller evaluates each declared actual exactly once and retains its pair through nested calls");
   actual128_consumers(a,&f,roles,r,&result,source,walked);
   ck(in.ref==original&&in.model==model&&in.references==sheet,"native input formation/admission never mutates its caller's input record");
   if(method==45)ck(actual128_trace==3&&actual128_effects==1,"named mixed reference/numeric actuals retain written-order effect and formal-order values");
  }
  for(size_t method=51;method<=52;++method){
   Lmx *fn=lmx_graph_ref_struct_in(a,program,method);void *raw=NULL;LmxWalkValue value={0},input={0};void *args[1];
   if(method==52){
    l2_test_declared_raw=NULL;Lmx *producer=lmx_graph_ref_struct_in(a,program,source?8:7);
    if(lmx_call_prim_values(a,producer,producer,NULL,0,NULL,&raw,NULL,&input))abort();
    lmx_walk_value_ref_parts(&input,LMX_TYPE_POINTER_BASE+16,raw,input.model,input.references);args[0]=lmx_walk_value_storage(&input);
   }else args[0]=number(a,source);
   void *original=input.ref;Lmx *model=input.model,*sheet=input.references;before=l2_call125_source_calls;
   int status=lmx_call_prim_values(a,fn,fn,args,1,NULL,&raw,method==52?&input:NULL,&value);
   ck(status==0&&raw&&value.model==(source?e:d)&&value.references,"hidden ordinary pointer transports its explicit CURRENT pair from working/formal state without guessing a Model");
   ck(input.ref==original&&input.model==model&&input.references==sheet&&l2_call125_source_calls==before+(method==51?1U:0U),"hidden transport preserves caller input and evaluates its source once");
  }
 }
 {
  const size_t methods[]={32,33,34,35,37,39,49,54};
  for(size_t k=0;k<8;++k){
   Lmx *fn=lmx_graph_ref_struct_in(a,program,methods[k]);void *args[]={number(a,2)},*raw=NULL;LmxWalkValue out={0};unsigned before=l2_call125_source_calls;
   int status=lmx_call_prim_values(a,fn,fn,args,1,NULL,&raw,NULL,&out);
   if(methods[k]==32)ck(status==0&&raw&&out.model==e&&!out.references,"native actual transport retains a malformed half-present pair rather than erasing it to raw");
   else ck(status!=0&&!out.model&&!out.references,"receiving a native actual rejects the malformed CURRENT pair without stored-history rescue");
   ck(l2_call125_source_calls==before+1,"malformed native actual is not re-evaluated after refusal");
  }
  Lmx *fn=lmx_graph_ref_struct_in(a,program,40);void *raw=NULL;LmxWalkValue out={0};unsigned before=l2_call125_source_calls;
  ck(lmx_call_prim_values(a,fn,fn,NULL,0,NULL,&raw,NULL,&out)==0&&!raw&&out.model==r&&out.references&&l2_call125_source_calls==before+1,"present-null native actual is admitted and transported as selected formal R,not an absent input");
  fn=lmx_graph_ref_struct_in(a,program,42);int result=0;
  ck(lmx_call_prim_values(a,fn,fn,NULL,0,&result,&raw,NULL,NULL)==0&&result==42,"the same full native actual span carries exact int values");
  fn=lmx_graph_ref_struct_in(a,program,44);
  actual128_trace=actual128_effects=0;result=0;
  ck(lmx_call_prim_values(a,fn,fn,NULL,0,&result,&raw,NULL,NULL)==0&&result==3&&actual128_trace==21&&actual128_effects==2,"native caller freezes named actuals in written right,left order before formal-order transport");
  actual128_trace=actual128_effects=0;
  Lmx *sig=node(a,2);put(sig,0,lmx_graph_ref_struct_in(a,fn,0));put(sig,1,lmx_graph_ref_struct_in(a,fn,1));
  Lmx *call=op(a,roles,LMX_WALK_OP_CALL,5);put(call,1,fn);put(call,3,sig);LmxWalkValue scalar={0};
  ck(lmx_walk_eval(&f,call,&scalar)==LMX_WALK_OK&&scalar.number==3&&actual128_trace==21&&actual128_effects==2,"real walked CALL to the generated named-actual native body observes values and effect order,not just translation");
  fn=lmx_graph_ref_struct_in(a,program,49);void *choice[]={number(a,3)};before=l2_call125_source_calls;out.model=out.references=NULL;
  ck(lmx_call_prim_values(a,fn,fn,choice,1,NULL,&raw,NULL,&out)==0&&!raw&&out.model==r&&out.references&&l2_call125_source_calls==before+1,"a hidden present-null CURRENT value survives ordinary native transport and receives R");
 }
 lmx_scratch_close(&scratch);lmx_arena_release(a);
 printf("native hidden values: %d checks, %d failures\n",checks,failures);return failures!=0;
}
