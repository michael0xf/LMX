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
 Lmx *program=node(a,66);if(l2_program_build(a,program,NULL))abort();
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
 lmx_scratch_close(&scratch);lmx_arena_release(a);
 printf("native source indirect write context: %d checks, %d failures; native=%d\n",checks,failures,INDIRECT133_EXPECT_NATIVE);
 return failures!=0;
}
