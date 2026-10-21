#include "codex_body123_inherited_channel.c"
#include "index140_effects.h"
#define main l2_generated_main
#include INDEX140_SOURCE
#undef main
int main(void){
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *program=node(a,INDEX140_FIELDS);if(l2_program_build(a,program,NULL))abort();
 Lmx *d=pair(a,0,0),*e=pair(a,0,0),*r=pair(a,0,0),*models[]={d,e,r};
 for(int k=0;k<3;k++)if(lmx_implements_register_map(a,models[k],models[k],NULL,0,tokens+k)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *sheet=node(a,1);size_at(a,sheet,0,0);Lmx *rr=record(a,catalog(a,2,2),sheet,d);
 Lmx *reader=lmx_graph_ref_struct_in(a,program,0),*returns=lmx_graph_ref_struct_in(a,reader,1);
 int ty=lmx_walk_witness_type(a,lmx_graph_value_in(a,returns,0));
 for(int method=0;method<2;method++)for(int target=0;target<2;target++){
  Lmx *callee=lmx_graph_ref_struct_in(a,program,method),*args=lmx_graph_ref_struct_in(a,callee,0);
  int aty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,0));Lmx *v=candidate(a,d,e),*wanted=target?e:d,*prior=target?d:e;
  LmxWalkValue held={0},before={0},input={0},context={0},loaded={0};
  lmx_walk_value_ref_parts(&held,ty,v,wanted,sheet);lmx_walk_value_ref_parts(&before,ty,v,prior,sheet);
  index140_b=lmx_arena_pointer_cells_profiled(a,ty,NULL,sizeof(void*),lmx_arena_pointer_void_read,lmx_arena_pointer_void_write,2);
  index140_c=lmx_arena_pointer_cells_profiled(a,ty,NULL,sizeof(void*),lmx_arena_pointer_void_read,lmx_arena_pointer_void_write,2);
  if(!index140_b||!index140_c||lmx_pointer_store_context_in(a,index140_b,v,&before)||lmx_pointer_store_context_in(a,index140_b+1,v,&held)||lmx_pointer_store_context_in(a,index140_c+1,v,&before))abort();
  index140_outer[0]=index140_c;index140_outer[1]=index140_c;index140_order=index140_marks=0;
  lmx_walk_value_ref(&input,aty,index140_outer);LmxWalkValue original=input;void *refs[]={lmx_walk_value_storage(&input)},*raw=NULL;
  int status=lmx_call_prim_values(a,callee,callee,refs,1,NULL,&raw,&input,&context);
  ck(callee&&callee->native&&status==LMX_WALK_OK&&raw==(method?(void*)(index140_b+1):(void*)v),"effectful index consumer returns actual frozen B cell/value,not later rebound C");
  ck(method?(context.referent==lmx_pointer_cell_context(a,index140_b+1)):(context.model==wanted&&context.references==sheet),"effectful index consumer preserves selected owner/CURRENT context at SAME raw payload");
  ck(index140_order==12&&index140_marks==2&&index140_outer[0]==index140_c,"index expressions execute once each,in source order,and second really rebinds the earlier pointer");
  ck(!memcmp(&input,&original,sizeof input),"effectful read/address leave input value record unchanged");
  LmxWalkPlace selected={0};selected.address=selected.storage=method?raw:(void*)(index140_b+1);selected.type=ty;
  if(method)selected.context=context.referent;
  if(lmx_walk_place_load(a,&selected,&loaded)!=LMX_WALK_OK)abort();
  if(!method)lmx_walk_value_ref_context(&loaded,ty,raw,&context);
  ck(lmx_walk_value_admit(a,&loaded,r,rr)==LMX_WALK_OK&&read_at(a,v,r,0)==(target?9:7)&&read_at(a,v,r,1)==(target?7:9),"effectful selected value feeds a real reordered receiving map");
  if(method){
   ck(lmx_walk_value_store(a,&selected,&before)==LMX_WALK_OK,"write through effectfully taken address uses the same common store");
   ck(lmx_walk_place_load(a,&selected,&loaded)==LMX_WALK_OK&&loaded.ref==v&&loaded.model==prior&&lmx_pointer_cell_context(a,index140_c+1)->model==prior,"address write persists in frozen B,without overwriting its state from rebound C");
  }
 }
 lmx_arena_release(a);printf("source indexed effect context: %d checks, %d failures\n",checks,failures);return failures!=0;
}
