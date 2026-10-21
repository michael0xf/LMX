#include "codex_body123_inherited_channel.c"
#define main l2_generated_main
#include INDEX140_SOURCE
#undef main
int main(void){
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *program=node(a,INDEX140_FIELDS);if(l2_program_build(a,program,NULL))abort();
 Lmx *d=pair(a,0,0),*e=pair(a,0,0),*r=pair(a,0,0),*s=pair(a,0,0),*models[]={d,e,r,s};
 for(int k=0;k<4;k++)if(lmx_implements_register_map(a,models[k],models[k],NULL,0,tokens+k)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *sheet=node(a,1);size_at(a,sheet,0,0);Lmx *rr=record(a,catalog(a,2,2),sheet,d),*rs=record(a,catalog(a,3,2),sheet,d);
 for(int target=0;target<2;target++)for(int storage=0;storage<2;storage++){
  Lmx *callee=lmx_graph_ref_struct_in(a,program,0),*args=lmx_graph_ref_struct_in(a,callee,0);
  Lmx *wanted=target?e:d,*prior=target?d:e,*v=candidate(a,d,e);
  int aty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,0));
  Lmx *writer=lmx_graph_ref_struct_in(a,program,1),*wargs=lmx_graph_ref_struct_in(a,writer,0);
  int ty=lmx_walk_witness_type(a,lmx_graph_value_in(a,wargs,2)),index=storage?0:1;
  LmxWalkValue held={0},before={0},input[3]={{0}},context={0},loaded={0};void **block;
  lmx_walk_value_ref_parts(&held,ty,v,wanted,sheet);lmx_walk_value_ref_parts(&before,ty,v,prior,sheet);
  if(storage)block=(void**)lmx_walk_value_storage(&held);
  else{
   block=lmx_arena_pointer_cells_profiled(a,ty,NULL,sizeof(void*),lmx_arena_pointer_void_read,lmx_arena_pointer_void_write,2);
   if(!block||lmx_pointer_store_context_in(a,block,v,&before)||lmx_pointer_store_context_in(a,block+1,v,&held))abort();
  }
  LmxWalkValue *owner=storage?&held:lmx_pointer_cell_context(a,block+index);
  lmx_walk_value_ref(input,aty,block);input[0].referent=storage?&held:lmx_pointer_cell_context(a,block);
  lmx_walk_value_num(input+1,LMX_TYPE_INT,index);
  LmxWalkValue incoming[2]={input[0],input[1]};
  void *refs[]={lmx_walk_value_storage(input),lmx_walk_value_storage(input+1),lmx_walk_value_storage(input+2)},*raw=NULL;
  int status=lmx_call_prim_values(a,callee,callee,refs,2,NULL,&raw,input,&context);
  ck(callee&&callee->native&&status==LMX_WALK_OK&&raw==(void*)(block+index),"address-of index returns the actual physical cell,not a loaded temporary");
  ck(context.referent==owner&&context.referent&&context.referent->model==wanted&&context.referent->references==sheet,"taken address carries the selected live owner,not index0's context or a stack temporary");
  LmxWalkPlace selected={0};selected.address=selected.storage=raw;selected.type=ty;selected.context=context.referent;
  ck(lmx_walk_value_store(a,&selected,&before)==LMX_WALK_OK,"common store through the taken address is admitted");
  ck(lmx_walk_place_load(a,&selected,&loaded)==LMX_WALK_OK&&loaded.ref==v&&loaded.model==prior&&loaded.references==sheet,"fresh load sees the SAME-address context changed through the taken address");
  ck(lmx_walk_value_admit(a,&loaded,r,rr)==LMX_WALK_OK&&read_at(a,v,r,0)==(target?7:9)&&read_at(a,v,r,1)==(target?9:7),"reordered receiving map observes actual opposite values after address write");
  lmx_walk_value_ref_parts(input+2,ty,v,wanted,sheet);memset(&context,0,sizeof context);raw=NULL;
  refs[2]=lmx_walk_value_storage(input+2);
  status=lmx_call_prim_values(a,writer,writer,refs,3,NULL,&raw,input,&context);
  lmx_walk_value_ref_context(&context,ty,raw,&context);
  ck(writer&&writer->native&&status==LMX_WALK_OK&&raw==v&&context.model==wanted&&context.references==sheet,"source working-address write and following indexed read preserve CURRENT state");
  ck(lmx_walk_place_load(a,&selected,&loaded)==LMX_WALK_OK&&loaded.ref==v&&loaded.model==wanted&&loaded.references==sheet,"source write persists in the actual taken cell,not only its returned value");
  /* A second fresh receiving role measures CURRENT producer transport.
     Reusing R would measure the separate already-admitted-map reuse policy.
     The original same-R50/4 observation is preserved in test_02.c. */
  ck(lmx_walk_value_admit(a,&context,s,rs)==LMX_WALK_OK&&read_at(a,v,s,0)==(target?9:7)&&read_at(a,v,s,1)==(target?7:9),"actual7/9 values after source address write follow its current implements map");
  ck(!memcmp(incoming,input,sizeof incoming)&&input[2].model==wanted&&input[2].references==sheet,"source address/read/write leave incoming records unchanged");
  if(!storage){LmxWalkValue *zero=lmx_pointer_cell_context(a,block);ck(block[0]==v&&zero&&zero->model==prior,"nonzero-index address write leaves index0 payload and state unchanged");}
 }
 for(int method=2;method<=3;method++)for(int index=-1;index<=1;index+=2){
  Lmx *callee=lmx_graph_ref_struct_in(a,program,method),*args=lmx_graph_ref_struct_in(a,callee,0);
  int aty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,0)),data[]={11,22,33},result=0;
  LmxWalkValue input[2]={{0}},context={0};lmx_walk_value_ref(input,aty,data+1);lmx_walk_value_num(input+1,LMX_TYPE_INT,index);
  void *refs[]={lmx_walk_value_storage(input),lmx_walk_value_storage(input+1)},*raw=NULL;
  int status=lmx_call_prim_values(a,callee,callee,refs,2,method==2?&result:NULL,&raw,input,&context);
  ck(callee&&callee->native&&status==LMX_WALK_OK,"readonly typed index consumer executes its native body");
  ck(method==2?(raw==&result&&result==(index<0?11:33)):(raw==(void*)(data+1+index)&&*(const int*)raw==(index<0?11:33)),"const read/address keeps exact qualification,signed index and actual value");
  ck(data[0]==11&&data[1]==22&&data[2]==33,"readonly index projection changes no C data");
 }
 lmx_arena_release(a);printf("source indexed address context: %d checks, %d failures\n",checks,failures);return failures!=0;
}
