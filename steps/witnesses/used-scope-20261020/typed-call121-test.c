/* Execute the unchanged120 assertions, then probe the explicit typed boundary. */
#define main value_context120_main
#include "value-transport120-test.c"
#undef main
#include "l2src/lmx_primitive.lm1.h"
extern int lmx_walk_enter_parts_values(LmxWalkFrame *,LmxWalkContext *,Lmx *,Lmx *,Lmx *,Lmx *,void **,size_t,LmxWalkValue *);
static Lmx *argument(LmxArena *a,Lmx *roles,size_t k,void *witness,Lmx *fallback){
 Lmx *v=op(a,roles,LMX_WALK_OP_ARG,4);size_at(a,v,1,k);put(v,2,fallback);put(v,3,witness);return v;
}
static Lmx *body_return(LmxArena *a,Lmx *roles,Lmx *value){
 Lmx *body=node(a,1),*ret=op(a,roles,LMX_WALK_OP_RET,2);put(ret,1,value);value->parent=ret;put(body,0,ret);ret->parent=body;return body;
}
static Lmx *callee_admit(LmxArena *a,Lmx *roles,Lmx *model,Lmx *rr){
 Lmx *arg=argument(a,roles,0,model,NULL),*ad=admit(a,roles,model,rr,arg);arg->parent=ad;return body_return(a,roles,ad);
}
static Lmx *signature(LmxArena *a,void *input,void *output){
 Lmx *v=node(a,2),*in=node(a,1),*ret=node(a,output?1:0);put(in,0,input);if(output)put(ret,0,output);put(v,0,in);put(v,1,ret);return v;
}
static Lmx *call_node(LmxArena *a,Lmx *roles,Lmx *callee,Lmx *sig,Lmx *value,int execute){
 Lmx *call=op(a,roles,execute?LMX_WALK_OP_EXEC:LMX_WALK_OP_CALL,6);
 if(execute){put(call,1,node(a,0));put(call,2,callee);}else put(call,1,callee);
 put(call,3,sig);put(call,5,value);value->parent=call;return call;
}
static int produced;
static Lmx *literal_int(LmxArena *a,Lmx *roles,int n){Lmx *v=op(a,roles,LMX_WALK_OP_LIT,2);put(v,1,number(a,n));return v;}
static int produce(void *owner,void **argv,size_t argc,void *dest,void **out,LmxArena *arena,Lmx *code){
 (void)argv;(void)dest;(void)arena;(void)code;if(argc||!out)return 1;++produced;*out=owner;return 0;
}
int main(void){
 (void)value_context120_main();
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *d=pair(a,0,0),*e=pair(a,0,0),*r=pair(a,0,0),*s=pair(a,0,0);
 Lmx *models[]={d,e,r,s};for(int i=0;i<4;++i)if(lmx_implements_register_map(a,models[i],models[i],NULL,0,tokens+i)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *sheets=node(a,1);size_at(a,sheets,0,0);
 Lmx *rr=record(a,catalog(a,2,2),sheets,d),*rs=record(a,catalog(a,3,3),sheets,d);
 Lmx *roles=lmx_walk_roles_open(a),*host=node(a,0);if(!roles)abort();test_parent=host;
 LmxPool cells={0};LmxScratch scratch={0};if(lmx_scratch_open(&scratch,a,&cells,64)!=LMX_SCRATCH_OK)abort();
 LmxWalkContext ctx={0};ctx.arena=a;ctx.scratch=&scratch;ctx.roles=roles;
 LmxWalkValue source={0},out={0};Lmx *v=candidate(a,d,e),*callee=callee_admit(a,roles,r,rr);
 lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheets);void *argv[]={lmx_walk_value_storage(&source)};
 ck(lmx_walk_activate_values(&ctx,callee,callee,argv,1,&source,&out)==LMX_WALK_OK&&out.ref==v&&out.model==r&&out.references==sheets,"native C typed caller transports CURRENT E into the ordinary activation");
 ck(read_at(a,v,r,0)==9&&read_at(a,v,r,1)==7&&source.model==e,"callee receiving map selects9,not stored D's7;caller input is unchanged");
 ck(lmx_walk_value_admit(a,&out,s,rs)==LMX_WALK_OK&&out.model==s&&read_at(a,v,s,0)==9,"returned context survives the callee scratch rewind and feeds the next receiver");
 void **address=lmx_graph_ref_cell_in(a,v,slot(a,v,s,0));
 ck(address&&lmx_int_store_known(*address,41)==0&&read_at(a,v,s,0)==41,"typed call's actual reordered map applies to a physical write");
 if(address)*address=number(a,43);
 ck(read_at(a,v,s,0)==43&&read_at(a,v,s,1)==7,"address obtained after typed calls changes the real mapped field,not its neighbor");
 Lmx *raw_value=candidate(a,d,e);void *raw=raw_value,*raw_args[]={&raw};
 ck(lmx_walk_activate(&ctx,callee,callee,raw_args,1,&out)==LMX_WALK_OK&&out.model==r&&read_at(a,raw_value,r,0)==7,"legacy raw entry uses only its explicit D context;it never guesses E from history");
 LmxWalkFrame caller={0};caller.context=&ctx;caller.arena=a;caller.roles=roles;caller.node=caller.code=caller.source=host;caller.guarded=&source;
 Lmx *guarded=op(a,roles,LMX_WALK_OP_GUARDED,1),*sig=signature(a,e,r);
 Lmx *call=call_node(a,roles,callee,sig,guarded,0);v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheets);
 ck(lmx_walk_eval(&caller,call,&out)==LMX_WALK_OK&&out.ref==v&&out.model==r&&read_at(a,v,r,0)==9,"walked CALL keeps the actual producer's Model into the same activation worker");
 Lmx *exec=call_node(a,roles,callee,sig,op(a,roles,LMX_WALK_OP_GUARDED,1),1);v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheets);
 ck(lmx_walk_eval(&caller,exec,&out)==LMX_WALK_OK&&out.ref==v&&out.model==r&&read_at(a,v,r,0)==9&&!ctx.split_entry,"walked EXEC with distinct explicit data uses the same typed input route");
 Lmx *named=op(a,roles,LMX_WALK_OP_NAMED,3);size_at(a,named,1,0);put(named,2,op(a,roles,LMX_WALK_OP_GUARDED,1));
 Lmx *named_call=call_node(a,roles,callee,sig,named,0);v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheets);
 ck(lmx_walk_eval(&caller,named_call,&out)==LMX_WALK_OK&&read_at(a,v,r,0)==9&&out.model==r,"named actual coordinates carry their full computed value,not only its ref box");
 Lmx *forward_arg=argument(a,roles,0,e,NULL),*inner=call_node(a,roles,callee,sig,forward_arg,0),*outer=body_return(a,roles,inner);
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheets);
 ck(lmx_walk_activate_values(&ctx,outer,outer,argv,1,&source,&out)==LMX_WALK_OK&&read_at(a,v,r,0)==9&&out.model==r,"two nested activations forward one value and retain the returned receiving pair");
 Lmx *plain_arg=argument(a,roles,0,e,NULL),*identity_body=body_return(a,roles,plain_arg);
 lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,NULL,e,sheets);
 ck(lmx_walk_activate_values(&ctx,callee,callee,argv,1,&source,&out)==LMX_WALK_OK&&out.present&&!out.ref&&out.model==r&&out.references==sheets,"present-null crosses a call as present typed reference,not absence");
 lmx_walk_value_clear(&source);void *missing[]={NULL};
 ck(lmx_walk_activate_values(&ctx,identity_body,identity_body,missing,1,&source,&out)==LMX_WALK_OK&&!out.present&&!out.model,"absent typed actual stays absent and does not fabricate a pointer box");
 v=candidate(a,d,e);Lmx *default_value=op(a,roles,LMX_WALK_OP_LIT,2);put(default_value,1,v);
 Lmx *default_admit=admit(a,roles,r,rr,default_value),*default_arg=argument(a,roles,0,r,default_admit),*default_body=body_return(a,roles,default_arg);default_admit->parent=default_arg;
 ck(lmx_walk_activate_values(&ctx,default_body,default_body,missing,1,&source,&out)==LMX_WALK_OK&&out.ref==v&&out.model==r&&read_at(a,v,r,0)==7,"absent input's evaluated default establishes its own receiving context");
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheets);
 ck(lmx_walk_activate_values(&ctx,callee,callee,argv,1,&source,&source)==LMX_WALK_OK&&source.ref==v&&source.model==r&&read_at(a,v,r,0)==9,"input/output record alias snapshots the input before clearing the result");
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheets);
 LmxScratchMark mark;if(lmx_scratch_mark(&scratch,&mark)!=LMX_SCRATCH_OK)abort();LmxWalkFrame frame={0};
 ck(lmx_walk_enter_parts_values(&frame,&ctx,identity_body,identity_body,identity_body,identity_body,argv,1,&source)==LMX_WALK_OK&&frame.argown&&frame.argown[0].model==e,"entry copies the typed input into callee-owned storage before body execution");
 LmxWalkPlace place={0};ck(lmx_walk_place(&frame,plain_arg,0,&place)==LMX_WALK_OK&&place.address==&frame.argown[0].ref&&place.address!=argv[0],"formal address names the stable callee place,never caller value storage");
 void *stable=place.address;Lmx *replacement=candidate(a,d,e);
 ck(lmx_pointer_store_known(place.address,replacement)==0&&lmx_walk_eval(&frame,plain_arg,&out)==LMX_WALK_OK&&out.ref==replacement&&out.model==e&&source.ref==v,"store through the formal's taken address is callee-local and keeps its declared context");
 LmxWalkValue received={0};lmx_walk_value_ref_parts(&received,LMX_TYPE_LMX,replacement,e,sheets);if(lmx_walk_value_admit(a,&received,r,rr)!=LMX_WALK_OK)abort();
 ck(lmx_walk_arg_write(&frame,0,LMX_TYPE_LMX,&received,&out)==LMX_WALK_OK&&out.model==r&&frame.args[0]==stable&&source.model==e&&source.ref==v,"formal rebinding replaces context locally without moving its address or changing the caller");
 ck(lmx_walk_eval(&frame,admit(a,roles,s,rs,plain_arg),&out)==LMX_WALK_OK&&out.model==s&&read_at(a,replacement,s,0)==9,"later consumption follows the rebound formal's current Model");
 if(lmx_scratch_rewind(&scratch,&mark)!=LMX_SCRATCH_OK)abort();
 void *other=v,*bad_args[]={&other};
 ck(lmx_walk_activate_values(&ctx,callee,callee,bad_args,1,&source,&out)==LMX_WALK_INVALID&&!out.present,"explicit typed span cannot silently fall back when its storage span does not correspond");
 LmxWalkValue malformed={0};malformed.present=1;
 ck(lmx_walk_activate_values(&ctx,identity_body,identity_body,missing,1,&malformed,&out)==LMX_WALK_INVALID&&!out.present,"present malformed value with no valid storage is rejected rather than treated as missing");
 lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,candidate(a,d,e),e,NULL);
 ck(lmx_walk_activate_values(&ctx,callee,callee,argv,1,&source,&out)==LMX_WALK_THROWN+LMX_WALK_NAME_IMPLEMENTS,"half-present CURRENT pair stays malformed across the call and cannot recover stored D");
 void *iw=number(a,0);Lmx *int_body=body_return(a,roles,argument(a,roles,0,iw,NULL));
 lmx_walk_value_num(&source,LMX_TYPE_INT,123);argv[0]=lmx_walk_value_storage(&source);
 ck(lmx_walk_activate_values(&ctx,int_body,int_body,argv,1,&source,&out)==LMX_WALK_OK&&out.kind==LMX_WALK_VALUE_NUMBER&&out.number==123&&!out.model,"the same typed entry carries exact int storage without reference reinterpretation");
 void *sw=lmx_size_new_owned(a);if(!sw)abort();Lmx *size_body=body_return(a,roles,argument(a,roles,0,sw,NULL));lmx_walk_value_num(&source,LMX_TYPE_SIZE_T,((size_t)1<<40)+17);argv[0]=lmx_walk_value_storage(&source);
 ck(lmx_walk_activate_values(&ctx,size_body,size_body,argv,1,&source,&out)==LMX_WALK_OK&&out.wide==((size_t)1<<40)+17,"size_t input/result keeps bits above32 through declared-width storage");
 ck(lmx_walk_activate_values(&ctx,int_body,int_body,argv,1,&source,&out)==LMX_WALK_INVALID&&!out.present,"a present typed input cannot be reinterpreted through a different formal width");
 /* A source effect occurs once before the nested call,not again for its Model. */
 v=candidate(a,d,e);LmxPrimitive *primitive=lmx_arena_take(a,sizeof *primitive,LMX_DOMAIN_KIND_PRIMITIVE,LMX_DOMAIN_PRIMITIVE);
 if(!primitive)abort();primitive->fn=produce;primitive->signature=signature(a,e,e);primitive->owner=v;Lmx *record_node=(Lmx *)primitive;
 Lmx *psig=((LmxPrimitive *)record_node)->signature;put(psig,0,node(a,0));
 Lmx *prim=op(a,roles,LMX_WALK_OP_PRIM,3);put(prim,1,record_node);
 Lmx *e_record=record(a,catalog(a,1,1),sheets,d),*e_value=admit(a,roles,e,e_record,prim),*effect_call=call_node(a,roles,callee,sig,e_value,0);
 produced=0;
 ck(lmx_walk_eval(&caller,effect_call,&out)==LMX_WALK_OK&&produced==1&&out.ref==v&&out.model==r&&read_at(a,v,r,0)==9,"effectful actual is evaluated once and its receiving Model crosses the call without re-evaluation");
 ck(lmx_walk_value_admit(a,&out,s,rs)==LMX_WALK_OK&&out.model==s&&read_at(a,v,s,0)==9,"effectful nested call's result carries the same pair into another receiving consumer");
 /* Consume the returned map with the real walked place/read/store/@ route. */
 source=out;caller.guarded=&source;Lmx *path=op(a,roles,LMX_WALK_OP_OF,4);put(path,1,op(a,roles,LMX_WALK_OP_GUARDED,1));size_at(a,path,2,0);put(path,3,s);
 ck(lmx_walk_eval(&caller,path,&out)==LMX_WALK_OK&&out.number==9,"walked physical read after nested typed call uses the reordered receiving map");
 Lmx *write=op(a,roles,LMX_WALK_OP_PUT,3);put(write,1,path);put(write,2,literal_int(a,roles,41));
 ck(lmx_walk_eval(&caller,write,&out)==LMX_WALK_OK&&read_at(a,v,s,0)==41&&read_at(a,v,s,1)==7,"walked physical write after typed call changes only the mapped field");
 Lmx *take=op(a,roles,LMX_WALK_OP_ADDRESS,3);put(take,1,path);void *pw=lmx_pointer_new_owned(LMX_TYPE_POINTER_BASE+LMX_TYPE_INT,a);if(!pw)abort();put(take,2,pw);
 ck(lmx_walk_eval(&caller,take,&out)==LMX_WALK_OK&&out.ref==lmx_graph_value_in(a,v,1),"walked taken address is the actual post-map int cell,not an ordinal or temporary");
 void *taken=out.ref;LmxWalkValue held=out;caller.guarded=&held;Lmx *deref=op(a,roles,LMX_WALK_OP_DEREF,3);put(deref,1,op(a,roles,LMX_WALK_OP_GUARDED,1));put(deref,2,iw);
 Lmx *indirect_write=op(a,roles,LMX_WALK_OP_PUT,3);put(indirect_write,1,deref);put(indirect_write,2,literal_int(a,roles,43));
 ck(lmx_walk_eval(&caller,indirect_write,&out)==LMX_WALK_OK&&read_at(a,v,s,0)==43&&read_at(a,v,s,1)==7&&lmx_int_value_known(taken)==43,"walked write through the obtained address changes the same physical value to43");
 ck(lmx_walk_eval(&caller,deref,&out)==LMX_WALK_OK&&out.number==43,"walked dereference observes the real value after the address write");
 /* Role-selected fn parts enter that same worker without borrowing a second graph. */
 Lmx *method=lmx_node_new_role_profiled(a,NULL,LMX_POOL_ROLE_FN);if(!method||lmx_arena_refs_open_owned(a,method,4))abort();
 put(method,0,lmx_graph_value_in(a,sig,0));put(method,1,lmx_graph_value_in(a,sig,1));put(method,2,node(a,0));put(method,3,callee);
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheets);argv[0]=lmx_walk_value_storage(&source);
 ck(lmx_walk_activate_values(&ctx,method,lmx_graph_ref_struct_in(a,method,2),argv,1,&source,&out)==LMX_WALK_OK&&out.ref==v&&out.model==r&&read_at(a,v,r,0)==9,"receiver-produced four-part fn selects its body then consumes the same typed inputs");
 /* Empty use coverage grants no field proof. Later use resolves the exact
    physical template to the explicitly carried Model,not a historical role. */
 Lmx *coverage=node(a,2);size_at(a,coverage,0,2);size_at(a,coverage,1,0);
 Lmx *empty_record=record(a,catalog(a,2,2),sheets,d);put(empty_record,1,coverage);size_at(a,empty_record,2,2);
 v=candidate(a,d,e);if(lmx_implements_register_map(a,v,v,NULL,0,tokens+1)!=LMX_IMPLEMENTS_YES)abort();lmx_walk_value_ref(&source,LMX_TYPE_LMX,v);
 ck(lmx_walk_value_admit(a,&source,r,empty_record)==LMX_WALK_OK&&source.model==r&&!lmx_implements_find(a,v,r),"empty Consumer accepts and labels its value without inventing a whole-model permission or map");
 ck(lmx_walk_activate_values(&ctx,callee,callee,argv,1,&source,&out)==LMX_WALK_OK&&out.model==r&&read_at(a,v,r,0)==9,"first real consumption after empty admission resolves the exact physical-to-CURRENT Model template");
 Lmx *conflict_catalog=catalog(a,2,3);token_at(a,conflict_catalog,15,tokens+1);Lmx *conflict_record=record(a,conflict_catalog,sheets,d),*conflict_callee=callee_admit(a,roles,r,conflict_record);
 v=candidate(a,d,e);if(lmx_implements_register_map(a,v,v,NULL,0,tokens+1)!=LMX_IMPLEMENTS_YES)abort();lmx_walk_value_ref(&source,LMX_TYPE_LMX,v);if(lmx_walk_value_admit(a,&source,r,empty_record)!=LMX_WALK_OK)abort();
 ck(lmx_walk_activate_values(&ctx,conflict_callee,conflict_callee,argv,1,&source,&out)==LMX_WALK_THROWN+LMX_WALK_NAME_IMPLEMENTS&&!lmx_implements_find(a,v,r),"conflicting direct templates for CURRENT Model refuse atomically;first row does not win");
 ck(lmx_implements_find(a,v,d)&&lmx_implements_find(a,v,e)&&!lmx_implements_find(a,v,r),"failed direct resolution leaves other historical namespaces intact without using them as fallback");
 lmx_scratch_close(&scratch);lmx_arena_release(a);
 printf("typed inter-call values: %d checks, %d failures\n",checks,failures);return failures!=0;
}
