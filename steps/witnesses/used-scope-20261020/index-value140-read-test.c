#include "codex_body123_inherited_channel.c"
#define main l2_generated_main
#ifndef INDEX140_SOURCE
#error Need exact generated source
#endif
#include INDEX140_SOURCE
#undef main
#ifndef INDEX140_FIELDS
#error Need actual constructed root width
#endif
int main(void){
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *program=node(a,INDEX140_FIELDS);if(l2_program_build(a,program,NULL))abort();
 Lmx *d=pair(a,0,0),*e=pair(a,0,0),*r=pair(a,0,0),*models[]={d,e,r};
 for(int k=0;k<3;k++)if(lmx_implements_register_map(a,models[k],models[k],NULL,0,tokens+k)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *sheet=node(a,1);size_at(a,sheet,0,0);Lmx *rr=record(a,catalog(a,2,2),sheet,d);
 for(int target=0;target<2;target++)for(int mode=0;mode<4;mode++){
  int method=mode==1?1:(mode==2?3:0),n=mode==1?3:2,index=mode==3?0:1;
  Lmx *callee=lmx_graph_ref_struct_in(a,program,method),*args=lmx_graph_ref_struct_in(a,callee,0);
  Lmx *wanted=target?e:d,*prior=target?d:e,*v=candidate(a,d,e);
  int aty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,0));
  int ty=lmx_walk_witness_type(a,lmx_graph_value_in(a,lmx_graph_ref_struct_in(a,callee,1),0));
  LmxWalkValue held={0},input[3]={{0}},context={0},loaded={0};void **block=NULL;
  lmx_walk_value_ref_parts(&held,ty,v,wanted,sheet);
  if(mode==3){block=(void**)lmx_walk_value_storage(&held);}
  else{
   block=lmx_arena_pointer_cells_profiled(a,ty,NULL,sizeof(void*),lmx_arena_pointer_void_read,lmx_arena_pointer_void_write,2);
   LmxWalkValue before={0};lmx_walk_value_ref_parts(&before,ty,v,prior,sheet);
   if(!block||lmx_pointer_store_context_in(a,block,v,&before)||lmx_pointer_store_context_in(a,block+1,v,&held))abort();
  }
  /* Every intermediate is a real object of the C pointer type it is read as. */
  void **outer[2]={block,block};void ***p2=&block;void ****p3=&p2;
  void *****p4=&p3;void ******p5=&p4;void *******p6=&p5;
  lmx_walk_value_ref(input,aty,mode==1?(void*)outer:(mode==2?(void*)p6:(void*)block));
  if(mode==3)input[0].referent=&held;
  if(mode==0)input[0].referent=lmx_pointer_cell_context(a,block);
  lmx_walk_value_num(input+1,LMX_TYPE_INT,mode==1?1:index);
  if(mode==1)lmx_walk_value_num(input+2,LMX_TYPE_INT,index);
  LmxWalkValue original[3];memcpy(original,input,sizeof input);
  void *refs[3],*raw=NULL;for(int i=0;i<n;i++)refs[i]=lmx_walk_value_storage(input+i);
  int status=lmx_call_prim_values(a,callee,callee,refs,n,NULL,&raw,input,&context);
  /* The uniform ABI returns raw payload and context separately. Construct
     the caller's Value with the SAME common marshaller,without inventing a
     Model/reference sheet. context alone is not the result payload. */
  lmx_walk_value_ref_context(&context,ty,raw,&context);
  ck(callee&&callee->native,"indexed reader actually executes its generated native body");
  ck(status==LMX_WALK_OK&&raw==v,"source indexed read returns actual selected payload");
  ck(context.model==wanted&&context.references==sheet,"source indexed read returns CURRENT selected-cell Model and sheet,not root or stored Model");
  ck(context.ref==raw&&context.present,"source indexed result keeps a complete present typed value");
  LmxWalkPlace p={0};p.address=p.storage=block+index;p.type=ty;if(mode==3)p.context=&held;
  ck(lmx_walk_place_load(a,&p,&loaded)==LMX_WALK_OK&&loaded.ref==v&&loaded.model==wanted&&loaded.references==sheet,"independent read confirms the source reader did not alter selected state");
  ck(!memcmp(original,input,sizeof input),"indexed read leaves incoming address/value records unchanged");
  if(mode!=3){LmxWalkValue *zero=lmx_pointer_cell_context(a,block);ck(block[0]==v&&zero&&zero->model==prior&&zero->references==sheet,"nonselected index0 keeps its distinct CURRENT state at SAME raw payload");}
  int admitted=lmx_walk_value_admit(a,&context,r,rr);
  ck(admitted==LMX_WALK_OK&&read_at(a,raw,r,0)==(target?9:7)&&read_at(a,raw,r,1)==(target?7:9),"actual7/9 read through reordered receiving map uses the indexed result's CURRENT context");
 }
 for(int index=-1;index<=1;index+=2){
  Lmx *callee=lmx_graph_ref_struct_in(a,program,2),*args=lmx_graph_ref_struct_in(a,callee,0);
  int aty=lmx_walk_witness_type(a,lmx_graph_value_in(a,args,0)),data[]={11,22,33},result=0;
  LmxWalkValue input[2]={{0}},context={0};lmx_walk_value_ref(input,aty,data+1);lmx_walk_value_num(input+1,LMX_TYPE_INT,index);
  void *refs[]={lmx_walk_value_storage(input),lmx_walk_value_storage(input+1)},*raw=NULL;
  int status=lmx_call_prim_values(a,callee,callee,refs,2,&result,&raw,input,&context);
  ck(status==LMX_WALK_OK&&raw==&result&&result==(index<0?11:33),"typed scalar read preserves signed index and actual nonzero C element");
  ck(data[0]==11&&data[1]==22&&data[2]==33,"scalar index read leaves every C cell unchanged");
 }
 lmx_arena_release(a);
 printf("source indexed read context: %d checks, %d failures\n",checks,failures);
 return failures!=0;
}
