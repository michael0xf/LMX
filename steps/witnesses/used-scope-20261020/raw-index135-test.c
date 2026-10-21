#include "codex_body123_inherited_channel.c"
#define main l2_generated_main
#ifndef INDIRECT133_SOURCE
#error Define INDIRECT133_SOURCE to this profile's generated unit.c
#endif
#include INDIRECT133_SOURCE
#undef main
#ifndef INDIRECT133_EXPECT_NATIVE
#define INDIRECT133_EXPECT_NATIVE 1
#endif
int main(void){
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *program=node(a,73);if(l2_program_build(a,program,NULL))abort();
 Lmx *d=pair(a,0,0),*e=pair(a,0,0),*r=pair(a,0,0);Lmx *models[]={d,e,r};
 for(int k=0;k<3;++k)if(lmx_implements_register_map(a,models[k],models[k],NULL,0,tokens+k)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *sheet=node(a,1);size_at(a,sheet,0,0);Lmx *rr=record(a,catalog(a,2,2),sheet,d);
 Lmx *roles=lmx_walk_roles_open(a),*host=node(a,0);test_parent=host;
 LmxPool cells={0};LmxScratch scratch={0};if(lmx_scratch_open(&scratch,a,&cells,256)!=LMX_SCRATCH_OK)abort();
 LmxWalkContext ctx={0};ctx.arena=a;ctx.roles=roles;ctx.scratch=&scratch;
 LmxWalkFrame f={0};f.context=&ctx;f.arena=a;f.roles=roles;f.node=f.code=f.source=host;
 for(int target=0;target<2;++target)for(int storage=0;storage<2;++storage)
 for(size_t method=63;method<65;++method){
  Lmx *wanted=target?e:d,*prior=target?d:e,*v=candidate(a,d,e);
  Lmx *callee=lmx_graph_ref_struct_in(a,program,method),*args=lmx_graph_ref_struct_in(a,callee,0);
  ck(callee&&!!callee->native==INDIRECT133_EXPECT_NATIVE,"source pointer write actually selects the requested native/forced-walker body");
  int address_type=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,0));
  int ty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,1));
  LmxWalkValue held={0},input[2]={{0}},out={0},context={0},loaded={0};void *cell;
  lmx_walk_value_ref_parts(&held,ty,v,prior,sheet);
  if(storage){cell=lmx_walk_value_storage(&held);lmx_walk_value_ref(&input[0],address_type,cell);input[0].referent=&held;}
  else{
   cell=lmx_pointer_new_owned(ty,a);LmxWalkPlace p={0};p.address=p.storage=cell;p.type=ty;
   if(lmx_walk_value_store(a,&p,&held)!=LMX_WALK_OK)abort();
   lmx_walk_value_ref(&input[0],address_type,cell);
  }
  lmx_walk_value_ref_parts(input+1,ty,v,wanted,sheet);
  void *raw=NULL,*refs[]={lmx_walk_value_storage(input),lmx_walk_value_storage(input+1)};
  int status=lmx_call_prim_values(a,callee,callee,refs,2,NULL,&raw,input,&context);
  context.present=1;context.kind=LMX_WALK_VALUE_REFERENCE;context.type=ty;context.ref=raw;out=context;
  ck(status==LMX_WALK_OK&&raw==v,"actual source pointer assignment and following read complete with the true C payload");
  ck(status==LMX_WALK_OK&&out.model==wanted&&out.references==sheet,"source indirect write replaces CURRENT namespace even at the SAME raw address");
  LmxWalkPlace p={0};p.address=p.storage=cell;p.type=ty;if(storage)p.context=&held;
  int load=lmx_walk_place_load(a,&p,&loaded);
  ck(load==LMX_WALK_OK&&loaded.ref==v&&loaded.model==wanted&&loaded.references==sheet,"a fresh independent place read sees persisted state,not a repaired return only");
  ck(input[0].ref==cell&&input[0].referent==(storage?&held:NULL)&&input[1].ref==v&&input[1].model==wanted&&input[1].references==sheet,"incoming address and value records stay immutable while the addressed cell changes");
  int received=lmx_walk_value_admit(a,&loaded,r,rr);
  ck(received==LMX_WALK_OK&&read_at(a,loaded.ref,r,0)==(target?9:7)&&read_at(a,loaded.ref,r,1)==(target?7:9),"real reordered7/9 values follow source assignment and fresh load of the written current state");
 }

 /* Actual two-cell pointer backing,not two arbitrary adjacent allocations.
    input's explicit owner belongs to index0;index1 must select its own state. */
 for(int target=0;target<2;++target)for(int rank=1;rank<=2;++rank){
  Lmx *wanted=target?e:d,*prior=target?d:e,*v=candidate(a,d,e);
  size_t method=rank==1?65:66;
  Lmx *callee=lmx_graph_ref_struct_in(a,program,method),*args=lmx_graph_ref_struct_in(a,callee,0);
  ck(callee&&callee->native,"raw C indexing retains an actual native body,not fake interpreted Array");
  int ty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,rank+1));
  int aty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,0));
  void **block=lmx_arena_pointer_cells_profiled(a,ty,NULL,sizeof(void*),lmx_arena_pointer_void_read,lmx_arena_pointer_void_write,2);
  if(!block)abort();
  LmxWalkValue initial={0},input[4]={{0}},context={0},loaded={0};
  lmx_walk_value_ref_parts(&initial,ty,v,prior,sheet);
  if(lmx_pointer_store_context_in(a,block,v,&initial)||lmx_pointer_store_context_in(a,block+1,v,&initial))abort();
  void **outer[2]={block,block};
  lmx_walk_value_ref(input,aty,rank==1?(void*)block:(void*)outer);
  if(rank==1)input[0].referent=lmx_pointer_cell_context(a,block);
  for(int i=1;i<=rank;++i)lmx_walk_value_num(input+i,LMX_TYPE_INT,i==rank?1:0);
  lmx_walk_value_ref_parts(input+rank+1,ty,v,wanted,sheet);
  void *refs[4],*raw=NULL;for(int i=0;i<rank+2;++i)refs[i]=lmx_walk_value_storage(input+i);
  int status=lmx_call_prim_values(a,callee,callee,refs,rank+2,NULL,&raw,input,&context);
  ck(status==LMX_WALK_OK&&raw==v,"indexed pointer assignment reaches actual selected cell");
  LmxWalkPlace p={0};p.address=p.storage=block+1;p.type=ty;
  int load=lmx_walk_place_load(a,&p,&loaded);
  ck(load==LMX_WALK_OK&&loaded.ref==v&&loaded.model==wanted&&loaded.references==sheet,"nonzero index stores CURRENT context in selected companion");
  LmxWalkValue *untouched=lmx_pointer_cell_context(a,block);
  ck(block[0]==v&&untouched&&untouched->model==prior&&untouched->references==sheet,"index1 does not overwrite index0 payload/context or its explicit owner");
  ck(context.model==wanted&&context.references==sheet,"raw writer leaves giving record coherent");
  int received=lmx_walk_value_admit(a,&loaded,r,rr);
  ck(received==LMX_WALK_OK&&read_at(a,loaded.ref,r,0)==(target?9:7)&&read_at(a,loaded.ref,r,1)==(target?7:9),"post-index fresh load applies the actual reordered implements map");
 }
 /* Typed C pointer chain has seven actual levels,not repunned void** cells. */
 {
  Lmx *callee=lmx_graph_ref_struct_in(a,program,70),*args=lmx_graph_ref_struct_in(a,callee,0),*v=candidate(a,d,e);
  int ty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,1)),aty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,0));
  void **cell=lmx_pointer_new_owned(ty,a);void ***p2=&cell;void ****p3=&p2;
  void *****p4=&p3;void ******p5=&p4;void *******p6=&p5;
  LmxWalkValue input[2]={{0}},loaded={0},context={0};
  lmx_walk_value_ref(input,aty,p6);lmx_walk_value_ref_parts(input+1,ty,v,e,sheet);
  void *refs[]={lmx_walk_value_storage(input),lmx_walk_value_storage(input+1)},*raw=NULL;
  int status=lmx_call_prim_values(a,callee,callee,refs,2,NULL,&raw,input,&context);
  ck(callee&&callee->native&&status==LMX_WALK_OK&&raw==v,"six index steps execute through exact typed depth7 C chain");
  LmxWalkPlace place={0};place.address=place.storage=cell;place.type=ty;
  ck(lmx_walk_place_load(a,&place,&loaded)==LMX_WALK_OK&&loaded.ref==v&&loaded.model==e&&loaded.references==sheet,"depth7 writer reaches and persists final owned cell state");
 }
 {
  Lmx *callee=lmx_graph_ref_struct_in(a,program,67),*args=lmx_graph_ref_struct_in(a,callee,0),*v=candidate(a,d,e);
  int ty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,1)),aty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,0));
  int sentinel[6]={1,2,3,4,5,6};
  index135_b[0]=sentinel;index135_b[1]=sentinel+1;
  index135_c[0]=sentinel+2;index135_c[1]=sentinel+3;
  index135_d[0]=sentinel+4;index135_d[1]=sentinel+5;
  index135_outer[0]=index135_d;index135_outer[1]=index135_c;
  index135_order=index135_marks=index135_gives=0;
  LmxWalkValue input[2]={{0}},context={0};
  lmx_walk_value_ref(input,aty,index135_outer);lmx_walk_value_ref(input+1,ty,v);
  void *refs[]={lmx_walk_value_storage(input),lmx_walk_value_storage(input+1)},*raw=NULL;
  int status=lmx_call_prim_values(a,callee,callee,refs,2,NULL,&raw,input,&context);
  ck(status==LMX_WALK_OK&&raw==v,"effectful index/RHS source execution completes");
  ck(index135_order==123&&index135_marks==2&&index135_gives==1,"indices and RHS each execute exactly once,left to right");
  ck(index135_b[1]==v&&index135_b[0]==sentinel,"selected intermediate pointer is frozen before next index and target before RHS");
  ck(index135_c[1]==sentinel+3&&index135_d[1]==sentinel+5&&index135_outer[0]==index135_d,"later source rebinding neither retargets write nor changes other cells");
 }
 for(int negative=0;negative<2;++negative){
  Lmx *callee=lmx_graph_ref_struct_in(a,program,negative?69:68),*args=lmx_graph_ref_struct_in(a,callee,0);
  int aty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,0)),values[]={11,22,33};
  LmxWalkValue input[3]={{0}},context={0};int n=negative?2:3;
  lmx_walk_value_ref(input,aty,values+1);if(!negative)lmx_walk_value_num(input+1,LMX_TYPE_INT,1);
  lmx_walk_value_num(input+n-1,LMX_TYPE_INT,77);
  void *refs[3],*raw=NULL;for(int i=0;i<n;++i)refs[i]=lmx_walk_value_storage(input+i);
  int result=-1;int status=lmx_call_prim_values(a,callee,callee,refs,n,&result,&raw,input,&context);
  ck(status==LMX_WALK_OK&&raw==&result&&result==0&&values[negative?0:2]==77,"typed scalar pointer write preserves signed index semantics");
  ck(values[1]==22&&values[negative?2:0]==(negative?33:11),"scalar write preserves nonselected C cells");
 }

 lmx_scratch_close(&scratch);lmx_arena_release(a);
 printf("native source indirect write context: %d checks, %d failures; native=%d\n",checks,failures,INDIRECT133_EXPECT_NATIVE);
 return failures!=0;
}
