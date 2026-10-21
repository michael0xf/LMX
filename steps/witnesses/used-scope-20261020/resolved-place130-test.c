#include "codex_body123_inherited_channel.c"
#define main l2_generated_main
#ifndef PLACE130_SOURCE
#define PLACE130_SOURCE "codex_place130_baseline_01/unit.c"
#endif
#include PLACE130_SOURCE
#undef main
extern int lmx_walk_args_open_values(LmxWalkFrame *,LmxWalkValue *);
static Lmx *place130_arg(LmxArena *a,Lmx *roles,size_t k,void *w){
 Lmx *p=op(a,roles,LMX_WALK_OP_ARG,4);size_at(a,p,1,k);put(p,3,w);return p;
}
static Lmx *place130_set(LmxArena *a,Lmx *roles,size_t k,void *w,Lmx *value){
 Lmx *p=op(a,roles,LMX_WALK_OP_SET_ARG,4);size_at(a,p,1,k);put(p,2,value);put(p,3,w);return p;
}
int main(void){
 (void)channel122_main();
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *program=node(a,59);if(l2_program_build(a,program,NULL))abort();
 Lmx *echo=lmx_graph_ref_struct_in(a,program,55);
 Lmx *echo_args=lmx_graph_ref_struct_in(a,echo,0),*echo_return=lmx_graph_ref_struct_in(a,echo,1);
 void *address_witness=lmx_graph_value_in(a,echo_args,0);
 int address_type=lmx_walk_witness_type(a,address_witness),pointer_type=LMX_TYPE_POINTER_BASE+16;
 if(address_type<pointer_type||!echo||!echo->native)abort();
 Lmx *d=pair(a,0,0),*e=pair(a,0,0),*r=pair(a,0,0);Lmx *models[]={d,e,r};
 for(int i=0;i<3;++i)if(lmx_implements_register_map(a,models[i],models[i],NULL,0,tokens+i)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *sheet=node(a,1);size_at(a,sheet,0,0);Lmx *rr=record(a,catalog(a,2,2),sheet,d);
 Lmx *roles=lmx_walk_roles_open(a),*host=node(a,0);test_parent=host;if(!roles)abort();
 LmxPool cells={0};LmxScratch scratch={0};if(lmx_scratch_open(&scratch,a,&cells,256)!=LMX_SCRATCH_OK)abort();
 LmxWalkContext ctx={0};ctx.arena=a;ctx.roles=roles;ctx.scratch=&scratch;
 const size_t depths[]={1,5,17};
 for(int target=0;target<2;++target)for(int shared=0;shared<2;++shared)for(int native=0;native<7;++native)for(size_t di=0;di<3;++di)for(int carrier=0;carrier<2;++carrier){
  size_t depth=depths[di],n=depth+2;
  LmxWalkValue *in=calloc(n,sizeof *in);void **refs=calloc(n,sizeof *refs);Lmx **args=calloc(n,sizeof *args);void **w=calloc(n,sizeof *w);int *types=calloc(n,sizeof *types);
  if(!in||!refs||!args||!w||!types)abort();
  Lmx *first=candidate(a,d,e),*next=shared?first:candidate(a,d,e);Lmx *prior=target?d:e,*wanted=target?e:d;
  lmx_walk_value_ref_parts(in,pointer_type,first,prior,sheet);lmx_walk_value_ref_parts(in+1,pointer_type,next,wanted,sheet);
  w[0]=w[1]=lmx_pointer_new_owned(pointer_type,a);types[0]=types[1]=pointer_type;
  for(size_t k=2;k<n;++k){
   types[k]=k==2?address_type:address_type+(int)k;
   w[k]=k==2?address_witness:lmx_pointer_new_owned(types[k],a);
   lmx_walk_value_ref(in+k,types[k],NULL);
  }
  for(size_t k=0;k<n;++k){if(!w[k])abort();refs[k]=lmx_walk_value_storage(in+k);args[k]=place130_arg(a,roles,k,w[k]);}
  LmxWalkFrame f={0};f.context=&ctx;f.arena=a;f.roles=roles;f.node=f.code=f.source=host;f.args=refs;f.nargs=n;
  ck(lmx_walk_args_open_values(&f,in)==LMX_WALK_OK,"addressed inputs own stable payload and context storage");
  LmxWalkValue out={0};actual128_trace=actual128_effects=0;
  for(size_t k=2;k<n;++k){
   size_t previous=k==2?0:k-1;Lmx *take=op(a,roles,LMX_WALK_OP_ADDRESS,3);put(take,1,args[previous]);put(take,2,w[k]);
   Lmx *set=place130_set(a,roles,k,w[k],take);
   ck(lmx_walk_eval(&f,set,&out)==LMX_WALK_OK&&out.ref==lmx_walk_value_storage(f.argown+previous),"ADDRESS identifies the actual preceding activation cell at every level");
   if(k==2&&native){
    size_t method=55U+(size_t)((native-1)/2);Lmx *selected=lmx_graph_ref_struct_in(a,program,method);
    if(native%2==1){
     LmxWalkValue supplied={0},context={0};if(lmx_walk_eval(&f,args[2],&supplied)!=LMX_WALK_OK)abort();
     void *native_refs[]={lmx_walk_value_storage(&supplied)},*raw=NULL;
     if(lmx_call_prim_values(a,selected,selected,native_refs,1,NULL,&raw,&supplied,&context))abort();
     /* The uniform ABI separates payload from context. Reconstitute the
        Value with a whole context copy,not a guessed parent/layout Model. */
     context.present=1;context.kind=LMX_WALK_VALUE_REFERENCE;context.type=address_type;context.ref=raw;
     f.guarded=&context;set=place130_set(a,roles,2,w[2],op(a,roles,LMX_WALK_OP_GUARDED,1));
     if(lmx_walk_eval(&f,set,&out)!=LMX_WALK_OK)abort();
     f.guarded=NULL;
    }else{
     Lmx *sig=node(a,2);put(sig,0,lmx_graph_ref_struct_in(a,selected,0));put(sig,1,lmx_graph_ref_struct_in(a,selected,1));Lmx *call=op(a,roles,LMX_WALK_OP_CALL,6);put(call,1,selected);put(call,3,sig);put(call,5,args[2]);
     set=place130_set(a,roles,2,w[2],call);if(lmx_walk_eval(&f,set,&out)!=LMX_WALK_OK)abort();
    }
   }
  }
  ck(!native||(actual128_trace==4&&actual128_effects==1),"an address passes through the ordinary generated native body once,including real walked CALL");
  Lmx *place=args[n-1];size_t at=n-1;
  int carried=1;
  if(carrier){
   Lmx *wh=node(a,1);put(wh,0,lmx_pointer_new_owned(types[n-1],a));Lmx *own=op(a,roles,LMX_WALK_OP_OWN,3);put(own,1,wh);size_at(a,own,2,0);
   Lmx *set=op(a,roles,LMX_WALK_OP_SET,3);put(set,1,own);put(set,2,place);
   carried=lmx_walk_work_make(&f,own,wh,0,lmx_arena_ref_cell(wh,0))==LMX_WALK_OK&&lmx_walk_eval(&f,set,&out)==LMX_WALK_OK;
   place=own;
  }
  ck(carried,"a stored working pointer carries the same resolved address binding rather than only its raw payload");
  while(at>=2){size_t previous=at==2?0:at-1;Lmx *step=op(a,roles,LMX_WALK_OP_DEREF,3);put(step,1,place);put(step,2,w[previous]);place=step;at=previous;}
  Lmx *store=op(a,roles,LMX_WALK_OP_PUT,3);put(store,1,place);put(store,2,args[1]);
  ck(lmx_walk_eval(&f,store,&out)==LMX_WALK_OK,"one general PUT resolves the stored address chain and writes its RHS");
  ck(lmx_walk_eval(&f,args[0],&out)==LMX_WALK_OK&&out.ref==next&&out.model==wanted&&out.references==sheet,"the addressed value carries the RHS CURRENT pair,including a different view of the SAME raw address");
  ck(in[0].ref==first&&in[0].model==prior&&in[0].references==sheet&&in[1].model==wanted,"alias mutation changes only the activation's target,not caller input records");
  ck(lmx_walk_value_admit(a,&out,r,rr)==LMX_WALK_OK&&out.model==r,"ordinary receiving consumes the current addressed value,not a stale Model from before PUT");
  int expected=target?9:7,neighbor=target?7:9;
  ck(read_at(a,out.ref,r,0)==expected&&read_at(a,out.ref,r,1)==neighbor,"the applied reordered map reads actual7/9,not just a successful admission");
  LmxWalkValue part={0};f.guarded=&out;Lmx *path=op(a,roles,LMX_WALK_OP_OF,4);put(path,1,op(a,roles,LMX_WALK_OP_GUARDED,1));size_at(a,path,2,0);put(path,3,r);
  Lmx *write=op(a,roles,LMX_WALK_OP_PUT,3);put(write,1,path);put(write,2,literal_int(a,roles,41));
  ck(lmx_walk_eval(&f,write,&part)==LMX_WALK_OK&&read_at(a,out.ref,r,0)==41&&read_at(a,out.ref,r,1)==neighbor,"mapped write after address-chain rebinding changes41 and preserves the neighbor");
  Lmx *take=op(a,roles,LMX_WALK_OP_ADDRESS,3);put(take,1,path);void *int_pointer=lmx_pointer_new_owned(LMX_TYPE_POINTER_BASE+LMX_TYPE_INT,a);put(take,2,int_pointer);
  size_t physical=slot(a,out.ref,r,0);ck(lmx_walk_eval(&f,take,&part)==LMX_WALK_OK&&part.ref==lmx_graph_value_in(a,out.ref,physical),"the taken address identifies the actual field selected by the new map");
  if(part.ref)lmx_int_store_known(part.ref,43);
  ck(read_at(a,out.ref,r,0)==43&&read_at(a,out.ref,r,1)==neighbor,"reading after taken-address mutation observes43 and the intact neighbor");
  free(types);free(w);free(args);free(refs);free(in);
 }
 for(int clear=0;clear<2;++clear){
  Lmx *v=candidate(a,d,e);LmxWalkValue in[3]={{0}},out={0};void *refs[3];
  lmx_walk_value_ref_parts(in,pointer_type,v,d,sheet);
  if(clear)lmx_walk_value_ref(in+1,pointer_type,v);
  else lmx_walk_value_ref_parts(in+1,pointer_type,NULL,e,sheet);
  lmx_walk_value_ref(in+2,address_type,NULL);
  for(size_t k=0;k<3;++k)refs[k]=lmx_walk_value_storage(in+k);
  void *pointer_witness=lmx_pointer_new_owned(pointer_type,a);
  Lmx *arg0=place130_arg(a,roles,0,pointer_witness),*arg1=place130_arg(a,roles,1,pointer_witness),*arg2=place130_arg(a,roles,2,address_witness);
  LmxWalkFrame f={0};f.context=&ctx;f.arena=a;f.roles=roles;f.node=f.code=f.source=host;f.args=refs;f.nargs=3;
  ck(lmx_walk_args_open_values(&f,in)==LMX_WALK_OK,"raw/null replacement has an independent activation target");
  Lmx *take=op(a,roles,LMX_WALK_OP_ADDRESS,3);put(take,1,arg0);put(take,2,address_witness);
  ck(lmx_walk_eval(&f,place130_set(a,roles,2,address_witness,take),&out)==LMX_WALK_OK,"the stored alias resolves the original cell before replacement");
  Lmx *deref=op(a,roles,LMX_WALK_OP_DEREF,3);put(deref,1,arg2);put(deref,2,pointer_witness);
  Lmx *store=op(a,roles,LMX_WALK_OP_PUT,3);put(store,1,deref);put(store,2,arg1);
  ck(lmx_walk_eval(&f,store,&out)==LMX_WALK_OK,"common addressed store accepts present-null or an unannotated SAME raw replacement");
  ck(lmx_walk_eval(&f,arg0,&out)==LMX_WALK_OK&&out.ref==(clear?v:NULL)&&out.model==(clear?NULL:e)&&out.references==(clear?NULL:sheet),"raw replacement clears old Model even without a raw-address change;null retains its explicit pair");
  ck(lmx_walk_eval(&f,arg0,f.argown)==LMX_WALK_OK&&f.argown[0].ref==(clear?v:NULL)&&f.argown[0].model==(clear?NULL:e)&&f.argown[0].references==(clear?NULL:sheet),"resolved load may alias its owning Value without clearing the saved context before reading it");
  ck(in[0].ref==v&&in[0].model==d&&in[0].references==sheet,"raw/null alias replacement leaves caller input state intact");
  if(!clear)ck(lmx_walk_value_admit(a,&out,r,rr)==LMX_WALK_OK&&!out.ref&&out.model==r&&out.references==sheet,"ordinary receiving validates present-null after the addressed store");
  else ck(!out.model&&!out.references,"an unannotated replacement does not retain a stale declared namespace");
 }
 lmx_scratch_close(&scratch);lmx_arena_release(a);
 printf("resolved place alias context: %d checks, %d failures\n",checks,failures);return failures!=0;
}
