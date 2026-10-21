#include "codex_native122_inherited.c"
#include "l2src/lmx_call.lm1.h"
#include "l2src/lmx_thread.lm1.h"
#include "l2src/lmx_schedule.lm1.h"
#include "l2src/lmx_post.lm1.h"
static int n_calls,n_forward_calls,n_input_pairs;
static int n_receive(void *owner,void **refs,size_t n,void *dest,void **raw,LmxArena *a,Lmx *code,LmxWalkValue *values,LmxWalkValue *context){
 (void)dest;(void)code;++n_calls;if(!owner||n!=1||!refs||!refs[0]||!raw)return 1;
 LmxWalkValue value={0};if(values){value=values[0];if(value.model&&value.references)++n_input_pairs;}else if(lmx_walk_value_load(a,refs[0],LMX_TYPE_LMX,&value)!=LMX_WALK_OK)return 1;
 Lmx *model=lmx_graph_ref_struct_in(a,owner,0),*rr=lmx_graph_ref_struct_in(a,owner,1);
 if(lmx_walk_value_admit(a,&value,model,rr)!=LMX_WALK_OK)return 2;
 *raw=value.ref;if(context){context->model=value.model;context->references=value.references;}return 0;
}
static int n_forward(void *owner,void **refs,size_t n,void *dest,void **raw,LmxArena *a,Lmx *code,LmxWalkValue *values,LmxWalkValue *context){
 (void)code;++n_forward_calls;return lmx_call_prim_values(a,lmx_graph_ref_struct_in(a,owner,0),lmx_graph_ref_struct_in(a,owner,1),refs,n,dest,raw,values,context);
}
static int n_unannotated(void *owner,void **refs,size_t n,void *dest,void **raw,LmxArena *a,Lmx *code,LmxWalkValue *values,LmxWalkValue *context){
 (void)owner;(void)dest;(void)a;(void)code;(void)values;(void)context;if(n!=1||!refs||!refs[0]||!raw)return 1;*raw=lmx_pointer_value_known(refs[0]);return 0;
}
static int n_half_pair(void *owner,void **refs,size_t n,void *dest,void **raw,LmxArena *a,Lmx *code,LmxWalkValue *values,LmxWalkValue *context){
 int st=n_unannotated(owner,refs,n,dest,raw,a,code,values,context);if(!st&&context){context->model=values?values[0].model:NULL;context->references=NULL;}return st;
}
static int n_failure(void *owner,void **refs,size_t n,void *dest,void **raw,LmxArena *a,Lmx *code,LmxWalkValue *values,LmxWalkValue *context){
 (void)owner;(void)refs;(void)n;(void)dest;(void)raw;(void)a;(void)code;if(context&&values){context->model=values[0].model;context->references=values[0].references;}return 7;
}
static int n_stop(void *owner,void **refs,size_t n,void *dest,void **raw,LmxArena *a,Lmx *code,LmxWalkValue *values,LmxWalkValue *context){
 (void)refs;(void)n;(void)dest;(void)code;(void)values;if(!raw||!context||!lmx_thread_current())return 8;
 context->model=lmx_graph_ref_struct_in(a,owner,0);context->references=lmx_graph_ref_struct_in(a,owner,1);*raw=owner;
 return lmx_stop_request(lmx_thread_current(),1,0)==LMX_THREAD_OK?0:9;
}
static int n_number(void *owner,void **refs,size_t n,void *dest,void **raw,LmxArena *a,Lmx *code,LmxWalkValue *values,LmxWalkValue *context){
 (void)refs;(void)a;(void)code;(void)values;if(n||!dest||!raw)return 1;if(context){context->model=owner;context->references=owner;}lmx_int_store_known(dest,123);*raw=dest;return 0;
}
static Lmx *n_code(LmxArena *a,LmxPrimitiveEntry fn,Lmx *one,Lmx *two){Lmx *c=node(a,2);put(c,0,one);put(c,1,two);c->native=(LmxEntry)fn;return c;}
int channel122_main(void){
 (void)native122_inherited_main();
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *d=pair(a,0,0),*e=pair(a,0,0),*r=pair(a,0,0),*s=pair(a,0,0),*models[]={d,e,r,s};
 for(int i=0;i<4;++i)if(lmx_implements_register_map(a,models[i],models[i],NULL,0,tokens+i)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *sheet=node(a,1);size_at(a,sheet,0,0);Lmx *rr=record(a,catalog(a,2,2),sheet,d),*rs=record(a,catalog(a,3,3),sheet,d),*roles=lmx_walk_roles_open(a),*host=node(a,0);test_parent=host;if(!roles)abort();
 void *record_backing=rr->array.data,*stored=lmx_graph_value_in(a,rr,4);lmx_walk_program_bind(roles);
 Lmx *native=n_code(a,n_receive,r,rr),*forward=n_code(a,n_forward,native,native),*callee=callee_admit(a,roles,r,rr),*to_walk=n_code(a,n_forward,callee,callee);
 LmxWalkValue source={0},out={0},context={0};Lmx *v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheet);void *args[]={lmx_walk_value_storage(&source)},*raw=NULL;
 n_calls=n_forward_calls=n_input_pairs=0;
 ck(lmx_call_prim_values(a,native,native,args,1,NULL,&raw,&source,&context)==0&&raw==v&&context.model==r&&context.references==sheet&&n_input_pairs==1,"native uniform entry receives the exact CURRENT Model/sheet and returns its receiving context");
 ck(read_at(a,v,r,0)==9&&read_at(a,v,r,1)==7&&source.model==e&&source.ref==v,"native admission uses CURRENT E rather than stored D without mutating its caller input");
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheet);
 ck(lmx_call_prim_values(a,forward,forward,args,1,NULL,&raw,&source,&context)==0&&n_forward_calls==1&&raw==v&&context.model==r&&read_at(a,v,r,0)==9,"native-to-native re-entry preserves per-call context with no current-call global");
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheet);
 ck(lmx_call_prim_values(a,to_walk,to_walk,args,1,NULL,&raw,&source,&context)==0&&raw==v&&context.model==r&&context.references==sheet&&read_at(a,v,r,0)==9,"native-to-walk bridge supplies the same typed input span and returns context before scratch release");
 LmxPool cells={0};LmxScratch scratch={0};if(lmx_scratch_open(&scratch,a,&cells,64)!=LMX_SCRATCH_OK)abort();
 LmxWalkContext ctx={0};ctx.arena=a;ctx.scratch=&scratch;ctx.roles=roles;LmxWalkFrame f={0};f.context=&ctx;f.arena=a;f.roles=roles;f.node=f.code=f.source=host;f.guarded=&source;
 Lmx *sig=signature(a,e,r),*call=call_node(a,roles,native,sig,op(a,roles,LMX_WALK_OP_GUARDED,1),0);
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheet);
 ck(lmx_walk_eval(&f,call,&out)==LMX_WALK_OK&&out.ref==v&&out.model==r&&out.references==sheet&&read_at(a,v,r,0)==9,"walked CALL to a real native entry retains its returned CURRENT context");
 Lmx *again=admit(a,roles,s,rs,call);v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheet);
 ck(lmx_walk_eval(&f,again,&out)==LMX_WALK_OK&&out.model==s&&read_at(a,v,s,0)==9,"walker consumes native result through the SAME receiving operation,not a raw unqualified fallback");
 LmxPrimitive *primitive=lmx_arena_take(a,sizeof *primitive,LMX_DOMAIN_KIND_PRIMITIVE,LMX_DOMAIN_PRIMITIVE);if(!primitive)abort();primitive->fn=n_receive;primitive->owner=native;primitive->signature=sig;
 Lmx *prim=op(a,roles,LMX_WALK_OP_PRIM,4);put(prim,1,primitive);put(prim,3,op(a,roles,LMX_WALK_OP_GUARDED,1));
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheet);
 ck(lmx_walk_eval(&f,prim,&out)==LMX_WALK_OK&&out.ref==v&&out.model==r&&read_at(a,v,r,0)==9,"PRIM uses the same computed actuals and result-context marshaller as native CALL");
 ck(lmx_walk_value_admit(a,&out,s,rs)==LMX_WALK_OK&&out.model==s&&read_at(a,v,s,0)==9,"primitive native result remains typed for the next receiver");
 Lmx *bridge_call=call_node(a,roles,to_walk,sig,op(a,roles,LMX_WALK_OP_GUARDED,1),0);v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheet);
 ck(lmx_walk_eval(&f,bridge_call,&out)==LMX_WALK_OK&&out.ref==v&&out.model==r&&read_at(a,v,r,0)==9,"walk-native-walk re-entry retains each activation's actual value context");
 void **address=lmx_graph_ref_cell_in(a,v,slot(a,v,r,0));
 ck(address&&lmx_int_store_known(*address,41)==0&&read_at(a,v,r,0)==41,"map returned through both backend boundaries writes the actual selected field");
 if(address)*address=number(a,43);
 ck(read_at(a,v,r,0)==43&&read_at(a,v,r,1)==7,"taken-address replacement after native/walk re-entry changes43,not neighboring7");
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheet);
 ck(lmx_call_prim_values(a,native,native,args,1,NULL,&raw,&source,&source)==0&&source.ref==v&&source.model==r&&source.references==sheet&&read_at(a,v,r,0)==9,"result context may alias the caller input record without clearing it before dispatch");
 lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,NULL,e,sheet);
 ck(lmx_walk_eval(&f,call,&out)==LMX_WALK_OK&&out.present&&!out.ref&&out.model==r&&out.references==sheet,"native present-null result keeps the declared receiving context rather than becoming absent");
 Lmx *plain=n_code(a,n_unannotated,NULL,NULL);context.model=r;context.references=sheet;v=candidate(a,d,e);lmx_walk_value_ref_parts(&source,LMX_TYPE_LMX,v,e,sheet);
 ck(lmx_call_prim_values(a,plain,plain,args,1,NULL,&raw,&source,&context)==0&&raw==v&&!context.model&&!context.references,"an unannotated native result cannot inherit stale output context or guess a Model");
 Lmx *half=n_code(a,n_half_pair,NULL,NULL),*half_call=call_node(a,roles,half,sig,op(a,roles,LMX_WALK_OP_GUARDED,1),0);
 ck(lmx_walk_eval(&f,half_call,&out)==LMX_WALK_OK&&out.model==e&&!out.references,"native result transport preserves a malformed present pair,not silent erasure to untyped");
 ck(lmx_walk_value_admit(a,&out,r,rr)==LMX_WALK_THROWN+LMX_WALK_NAME_IMPLEMENTS&&!lmx_implements_find(a,v,r),"the shared receiver rejects the half-present native context instead of rescuing it through stored D");
 Lmx *failure=n_code(a,n_failure,NULL,NULL);context.model=r;context.references=sheet;
 ck(lmx_call_prim_values(a,failure,failure,args,1,NULL,&raw,&source,&context)==7&&!context.model&&!context.references,"native failure status cannot leak a success context into a caller value");
 Lmx *numeric=n_code(a,n_number,r,rr),*numeric_sig=node(a,2),*returns=node(a,1),*number_call=op(a,roles,LMX_WALK_OP_CALL,5);put(returns,0,number(a,0));put(numeric_sig,0,node(a,0));put(numeric_sig,1,returns);put(number_call,1,numeric);put(number_call,3,numeric_sig);
 ck(lmx_walk_eval(&f,number_call,&out)==LMX_WALK_OK&&out.kind==LMX_WALK_VALUE_NUMBER&&out.number==123&&!out.model&&!out.references,"numeric marshalling clears any callback-supplied reference context and preserves declared int width");
 ck(rr->array.data==record_backing&&lmx_graph_value_in(a,rr,4)==stored,"all native/walk/re-entrant calls leave the shared receiving graph record unchanged");
 LmxPost *mailbox=lmx_arena_take(a,sizeof *mailbox,LMX_DOMAIN_KIND_POST,LMX_DOMAIN_POST);
 LmxSchedule *schedule=lmx_arena_take(a,sizeof *schedule,LMX_DOMAIN_KIND_SCHEDULE,LMX_DOMAIN_SCHEDULE);
 LmxThread *thread=lmx_arena_take(a,sizeof *thread,LMX_DOMAIN_KIND_MSG_RECORD,LMX_DOMAIN_THREAD);
 if(!mailbox||!schedule||!thread||lmx_post_init(a,mailbox)!=LMX_POST_OK||lmx_schedule_init(schedule,a,thread,4)!=LMX_SCHEDULE_OK||lmx_thread_init(a,thread,host,mailbox,schedule)!=LMX_THREAD_OK)abort();
 LmxMsg *message=lmx_thread_message(thread);message->running=1;if(lmx_thread_enter(thread)!=LMX_THREAD_OK)abort();
 Lmx *stop=n_code(a,n_stop,r,sheet);context.model=r;context.references=sheet;raw=v;
 ck(lmx_call_prim_values(a,stop,stop,NULL,0,NULL,&raw,NULL,&context)==0&&!raw&&!context.model&&!context.references,"real current-Thread stop clears both the native raw result and its success context in the common dispatcher");
 ck(!message->running&&lmx_thread_leave(thread)==LMX_THREAD_OK&&!lmx_thread_current(),"stopped native call leaves its real Message/Thread normally without a hidden context stack");
 lmx_scratch_close(&scratch);lmx_arena_release(a);
 printf("uniform native value channel: %d checks, %d failures\n",checks,failures);return failures!=0;
}
