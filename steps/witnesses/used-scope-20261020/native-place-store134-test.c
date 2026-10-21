#include "codex_body123_inherited_channel.c"
#include "l2src/lmx_array_owned.lm1.h"
#define main l2_generated_main
#ifndef PLACES134_SOURCE
#error Define PLACES134_SOURCE
#endif
#include PLACES134_SOURCE
#undef main
#ifndef PLACES134_EXPECT_NATIVE
#define PLACES134_EXPECT_NATIVE 1
#endif
static int invoke_place(LmxArena *a,Lmx *callee,LmxWalkValue *input,size_t n,LmxWalkValue *out){
 void *args[2]={lmx_walk_value_storage(input),n>1?lmx_walk_value_storage(input+1):NULL},*raw=NULL;
 LmxWalkValue context={0};int status=lmx_call_prim_values(a,callee,callee,args,n,NULL,&raw,input,&context);
 int type=lmx_walk_witness_type(a,lmx_graph_value_in(a,lmx_graph_ref_struct_in(a,callee,1),0));
 lmx_walk_value_ref_context(out,type,raw,&context);return status;
}
int main(void){
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *program=node(a,73);if(l2_program_build(a,program,NULL))abort();
 Lmx *boxmodel=lmx_graph_ref_struct_in(a,program,65);
 Lmx *d=pair(a,0,0),*e=pair(a,0,0),*r=pair(a,0,0),*models[]={d,e,r};
 for(int k=0;k<3;++k)if(lmx_implements_register_map(a,models[k],models[k],NULL,0,tokens+k)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *sheet=node(a,1);size_at(a,sheet,0,0);Lmx *rr=record(a,catalog(a,2,2),sheet,d);
 size_t boxmap[]={3,4,0,2,1,3,4,0,2,1};char box_token;
 if(!boxmodel||boxmodel->array.size!=5)abort();
 for(int array=0;array<2;++array)for(int target=0;target<2;++target){
  Lmx *wanted=target?e:d,*prior=target?d:e,*v=candidate(a,d,e);
  Lmx *writer=lmx_graph_ref_struct_in(a,program,array?69:66);
  Lmx *getter=lmx_graph_ref_struct_in(a,program,array?70:67);
  Lmx *taker=lmx_graph_ref_struct_in(a,program,array?71:68);
  int ty=lmx_walk_witness_type(a,lmx_graph_value_in(a,lmx_graph_ref_struct_in(a,writer,0),1));
  LmxArray *values=lmx_array_new_owned(LMX_TYPE_ARRAY_OF_POINTER_BASE+ty-LMX_TYPE_POINTER_BASE,2,a);
  void *field=lmx_pointer_new_owned(ty,a);if(!values||!field)abort();
  Lmx *box=node(a,5);for(size_t k=0;k<5;++k)put(box,boxmap[k],lmx_graph_value_in(a,boxmodel,k));
  put(box,2,number(a,19));put(box,0,values);put(box,3,field);
  if(lmx_implements_register_map(a,box,boxmodel,boxmap,5,&box_token)!=LMX_IMPLEMENTS_YES)abort();
  LmxWalkPlace selected={0};if(array){if(lmx_value_array_place(a,values,1,&selected)!=LMX_WALK_OK)abort();}
  else{selected.address=selected.storage=field;selected.type=ty;}
  LmxWalkValue held={0},input[2]={{0}},out={0},loaded={0},address={0};
  lmx_walk_value_ref_parts(&held,ty,v,prior,sheet);
  if(lmx_walk_value_store(a,&selected,&held)!=LMX_WALK_OK)abort();
  lmx_walk_value_ref(input,LMX_TYPE_LMX,box);lmx_walk_value_ref_parts(input+1,ty,v,wanted,sheet);
  ck(writer&&getter&&taker&&!!writer->native==PLACES134_EXPECT_NATIVE&&!!getter->native==PLACES134_EXPECT_NATIVE&&!!taker->native==PLACES134_EXPECT_NATIVE,"all source field/Array read,write and address bodies select the requested actual engine");
  int status=invoke_place(a,writer,input,2,&out);
  ck(status==LMX_WALK_OK&&out.ref==v&&out.model==wanted&&out.references==sheet,"generated source write returns CURRENT context at the SAME raw payload");
  ck(lmx_walk_place_load(a,&selected,&loaded)==LMX_WALK_OK&&loaded.ref==v&&loaded.model==wanted&&loaded.references==sheet,"fresh physical place read proves persisted context rather than a repaired return");
  status=invoke_place(a,getter,input,1,&out);
  ck(status==LMX_WALK_OK&&out.ref==v&&out.model==wanted&&out.references==sheet,"independent generated source read retains the written CURRENT context");
  ck(lmx_walk_value_admit(a,&out,r,rr)==LMX_WALK_OK&&read_at(a,out.ref,r,0)==(target?9:7)&&read_at(a,out.ref,r,1)==(target?7:9),"real mapped7/9 values consume the source read rather than successful translation alone");
  status=invoke_place(a,taker,input,1,&address);
  ck(status==LMX_WALK_OK&&address.ref==selected.address,"generated address-of selects exactly the permuted field or indexed element physical cell");
  LmxWalkValue indirect[2]={address,{0}};lmx_walk_value_ref_parts(indirect+1,ty,v,prior,sheet);
  status=invoke_place(a,lmx_graph_ref_struct_in(a,program,63),indirect,2,&out);
  ck(status==LMX_WALK_OK&&out.ref==v&&out.model==prior,"write through the generated taken address changes CURRENT state via the same indirect operation");
  ck(lmx_walk_place_load(a,&selected,&loaded)==LMX_WALK_OK&&loaded.model==prior&&loaded.references==sheet,"address-derived write persists at the original field/Array cell");
  ck(lmx_int_value_known(lmx_graph_value_in(a,box,2))==19&&!lmx_pointer_value_promised(a,lmx_array_cell_in(a,values,0),ty),"mapped field/index writes preserve unrelated physical neighbors");
 }
 lmx_arena_release(a);
 printf("native source field/Array context: %d checks, %d failures; native=%d\n",checks,failures,PLACES134_EXPECT_NATIVE);
 return failures!=0;
}
