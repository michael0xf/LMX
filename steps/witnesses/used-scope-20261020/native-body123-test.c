#include "codex_body123_inherited_channel.c"
#define main l2_generated_main
#ifndef BODY123_SOURCE
#define BODY123_SOURCE "codex_body123_probe_01/unit.c"
#endif
#include BODY123_SOURCE
#undef main
int main(void){
 (void)channel122_main();
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *program=node(a,3);if(l2_program_build(a,program,NULL))abort();
 Lmx *echo=lmx_graph_ref_struct_in(a,program,1);
 ck(echo&&echo->native==(LmxEntry)l2_m0_tr,"actual L2-generated method graph selects its compiled uniform native adapter");
 Lmx *d=pair(a,0,0),*e=pair(a,0,0),*r=pair(a,0,0),*models[]={d,e,r};
 for(int i=0;i<3;++i)if(lmx_implements_register_map(a,models[i],models[i],NULL,0,tokens+i)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *sheet=node(a,1);size_at(a,sheet,0,0);Lmx *rr=record(a,catalog(a,2,2),sheet,d);
 LmxWalkValue input={0},context={0},received={0};Lmx *v=candidate(a,d,e);void *raw=NULL;
 lmx_walk_value_ref_parts(&input,LMX_TYPE_POINTER_BASE+16,v,e,sheet);void *args[]={lmx_walk_value_storage(&input)};
 unsigned before=l2_native_context123_calls;
 ck(lmx_call_prim_values(a,echo,echo,args,1,NULL,&raw,&input,&context)==0&&raw==v&&context.model==e&&context.references==sheet&&l2_native_context123_calls==before+1,"uniform adapter passes the SAME computed context through the generated typed-body signature and its explicit L2 service exactly once");
 ck(input.ref==v&&input.model==e&&input.references==sheet,"generated native body does not change caller-owned computed-value metadata");
 lmx_walk_value_ref_parts(&received,LMX_TYPE_LMX,raw,context.model,context.references);
 ck(lmx_walk_value_admit(a,&received,r,rr)==LMX_WALK_OK&&read_at(a,v,r,0)==9&&read_at(a,v,r,1)==7,"real result from generated native body uses CURRENT E,not historic D,in the common receiver");
 void **address=lmx_graph_ref_cell_in(a,v,slot(a,v,r,0));
 ck(address&&lmx_int_store_known(*address,41)==0&&read_at(a,v,r,0)==41,"generated native result's received map controls the real physical write");
 if(address)*address=number(a,43);
 ck(read_at(a,v,r,0)==43&&read_at(a,v,r,1)==7,"address taken after generated native result admission updates43 and preserves neighbor7");
 lmx_walk_value_ref_parts(&input,LMX_TYPE_POINTER_BASE+16,NULL,e,sheet);
 ck(lmx_call_prim_values(a,echo,echo,args,1,NULL,&raw,&input,&context)==0&&!raw&&context.model==e&&context.references==sheet,"generated typed body transports a present-null input/result pair without a pointee-derived Model");
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&input,LMX_TYPE_POINTER_BASE+16,v,e,sheet);context.model=r;context.references=sheet;
 ck(lmx_call_prim_values(a,echo,echo,args,1,NULL,&raw,NULL,&context)==0&&raw==v&&!context.model&&!context.references,"raw caller remains explicitly unannotated through generated native body instead of inheriting stale context");
 lmx_walk_value_ref_parts(&input,LMX_TYPE_POINTER_BASE+16,v,e,NULL);
 ck(lmx_call_prim_values(a,echo,echo,args,1,NULL,&raw,&input,&context)==0&&context.model==e&&!context.references,"generated native bridge preserves a half-present pair rather than hiding malformed metadata");
 lmx_walk_value_ref_parts(&received,LMX_TYPE_LMX,raw,context.model,context.references);
 ck(lmx_walk_value_admit(a,&received,r,rr)==LMX_WALK_THROWN+LMX_WALK_NAME_IMPLEMENTS&&!lmx_implements_find(a,v,r),"malformed context from generated native body is rejected by the common receiver with no history fallback");
 Lmx *roles=lmx_walk_roles_open(a);test_parent=program;if(!roles)abort();
 LmxPool cells={0};LmxScratch scratch={0};if(lmx_scratch_open(&scratch,a,&cells,64)!=LMX_SCRATCH_OK)abort();
 LmxWalkContext ctx={0};ctx.arena=a;ctx.roles=roles;ctx.scratch=&scratch;
 LmxWalkFrame f={0};f.context=&ctx;f.arena=a;f.roles=roles;f.node=f.code=f.source=program;f.guarded=&input;
 void *witness=lmx_graph_value_in(a,lmx_graph_ref_struct_in(a,echo,0),0);
 Lmx *sig=signature(a,witness,witness),*call=call_node(a,roles,echo,sig,op(a,roles,LMX_WALK_OP_GUARDED,1),0);
 v=candidate(a,d,e);lmx_walk_value_ref_parts(&input,LMX_TYPE_POINTER_BASE+16,v,e,sheet);
 ck(lmx_walk_eval(&f,call,&received)==LMX_WALK_OK&&received.ref==v&&received.model==e&&received.references==sheet,"real walked CALL reaches the generated native adapter/body and receives its explicit context");
 Lmx *ad=admit(a,roles,r,rr,call),*path=op(a,roles,LMX_WALK_OP_OF,4);put(path,1,ad);size_at(a,path,2,0);put(path,3,r);
 ck(lmx_walk_eval(&f,path,&received)==LMX_WALK_OK&&received.number==9&&read_at(a,v,r,1)==7,"walked path consumes the generated native result's CURRENT context and reads reordered9");
 Lmx *set=op(a,roles,LMX_WALK_OP_PUT,3);put(set,1,path);put(set,2,literal_int(a,roles,41));
 ck(lmx_walk_eval(&f,set,&received)==LMX_WALK_OK&&read_at(a,v,r,0)==41&&read_at(a,v,r,1)==7,"walked path writes41 through the map received from generated native body");
 Lmx *take=op(a,roles,LMX_WALK_OP_ADDRESS,3);put(take,1,path);void *pw=lmx_pointer_new_owned(LMX_TYPE_POINTER_BASE+LMX_TYPE_INT,a);if(!pw)abort();put(take,2,pw);
 ck(lmx_walk_eval(&f,take,&received)==LMX_WALK_OK&&received.ref==lmx_graph_value_in(a,v,slot(a,v,r,0)),"walked address after generated native result names the real mapped int cell");
 if(received.ref)lmx_int_store_known(received.ref,43);
 ck(read_at(a,v,r,0)==43&&read_at(a,v,r,1)==7,"write through address taken after generated native result changes43,not neighbor7");
 lmx_scratch_close(&scratch);
 lmx_arena_release(a);printf("generated native body channel: %d checks, %d failures\n",checks,failures);return failures!=0;
}
