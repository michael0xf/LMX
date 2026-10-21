#include "codex_body123_inherited_channel.c"
#define main l2_generated_main
#ifndef RESULT124_SOURCE
#define RESULT124_SOURCE "codex_result124_probe_05/unit.c"
#endif
#include RESULT124_SOURCE
#undef main
static Lmx *result124_catalog(LmxArena *a,Lmx *d,Lmx *e,void *required){
 Lmx *cat=node(a,15),*sources[]={d,e};size_at(a,cat,0,2);
 for(size_t k=0;k<2;++k){size_t at=1+7*k;void *token=lmx_implements_layout(a,sources[k]);if(!token)abort();token_at(a,cat,at,token);token_at(a,cat,at+1,required);size_at(a,cat,at+2,2);for(size_t j=0;j<4;++j)size_at(a,cat,at+3+j,k?(j%2?0:2):(j%2?2:0));}
 return cat;
}
int main(void){
 (void)channel122_main();
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();Lmx *program=node(a,14);if(l2_program_build(a,program,NULL))abort();
 Lmx *d=lmx_graph_ref_struct_in(a,program,1),*e=lmx_graph_ref_struct_in(a,program,2),*produce=lmx_graph_ref_struct_in(a,program,7),*null_fn=lmx_graph_ref_struct_in(a,program,8);
 ck(produce&&produce->native==(LmxEntry)l2_m2_tr&&null_fn&&null_fn->native==(LmxEntry)l2_m3_tr,"ordinary declared-Model return methods are real generated native bodies selected by their graph");
 LmxWalkValue context={0},received={0};void *raw=NULL;unsigned before=l2_result124_calls;
 int status=lmx_call_prim_values(a,produce,produce,NULL,0,NULL,&raw,NULL,&context);
 ck(status==0&&raw&&context.model==e&&context.references&&lmx_graph_node_in(a,context.references)==context.references,"ordinary native return publishes the Model/reference sheet from its SAME successful receiving operation without an explicit metadata service");
 ck(l2_result124_calls==before+1,"ordinary declared native result evaluates its actual source once and returns the SAME materialized value");
 Lmx *v=raw;size_t physical=(size_t)-1;
 ck(v&&lmx_implements_slot(a,v,e,2,&physical)==0&&physical==1&&lmx_int_value_known(lmx_graph_value_in(a,v,physical))==9,"ordinary native producer returns the real E view of the opaque D/E candidate");
 Lmx *r=pair(a,0,0);if(lmx_implements_register_map(a,r,r,NULL,0,tokens+2)!=LMX_IMPLEMENTS_YES)abort();
 Lmx *sheet=node(a,1);size_at(a,sheet,0,0);Lmx *rr=record(a,result124_catalog(a,d,e,tokens+2),sheet,d);
 lmx_walk_value_ref_parts(&received,LMX_TYPE_LMX,raw,context.model,context.references);
 ck(lmx_walk_value_admit(a,&received,r,rr)==LMX_WALK_OK&&read_at(a,v,r,0)==9&&read_at(a,v,r,1)==7,"next common receiver uses the actual ordinary native return's CURRENT E,not historic D's7");
 void **address=lmx_graph_ref_cell_in(a,v,slot(a,v,r,0));
 ck(address&&lmx_int_store_known(*address,41)==0&&read_at(a,v,r,0)==41&&read_at(a,v,r,1)==7,"map from ordinary native result admission controls a real41 write");
 if(address)*address=number(a,43);
 ck(read_at(a,v,r,0)==43&&read_at(a,v,r,1)==7,"taken-address replacement after ordinary native result changes43,not neighbor7");
 before=l2_result124_null_calls;context.model=r;context.references=sheet;raw=v;
 ck(lmx_call_prim_values(a,null_fn,null_fn,NULL,0,NULL,&raw,NULL,&context)==0&&!raw&&context.model==e&&context.references&&l2_result124_null_calls==before+1,"ordinary present-null native result receives its declared Model/sheet through the SAME value-admit worker");
 if(lmx_int_store_known(lmx_graph_value_in(a,v,physical),9))abort();
 Lmx *roles=lmx_walk_roles_open(a);test_parent=program;if(!roles)abort();
 LmxPool cells={0};LmxScratch scratch={0};if(lmx_scratch_open(&scratch,a,&cells,64)!=LMX_SCRATCH_OK)abort();
 LmxWalkContext ctx={0};ctx.arena=a;ctx.roles=roles;ctx.scratch=&scratch;LmxWalkFrame f={0};f.context=&ctx;f.arena=a;f.roles=roles;f.node=f.code=f.source=program;
 Lmx *sig=node(a,2);put(sig,0,lmx_graph_ref_struct_in(a,produce,0));put(sig,1,lmx_graph_ref_struct_in(a,produce,1));
 Lmx *call=op(a,roles,LMX_WALK_OP_CALL,5);put(call,1,produce);put(call,3,sig);before=l2_result124_calls;
 ck(lmx_walk_eval(&f,call,&received)==LMX_WALK_OK&&received.ref==v&&received.model==e&&received.references&&l2_result124_calls==before+1,"real walked unary CALL receives the CURRENT pair automatically produced by an ordinary native declared return");
 Lmx *ad=admit(a,roles,r,rr,call),*path=op(a,roles,LMX_WALK_OP_OF,4);put(path,1,ad);size_at(a,path,2,0);put(path,3,r);
 ck(lmx_walk_eval(&f,path,&received)==LMX_WALK_OK&&received.number==9&&read_at(a,v,r,1)==7,"walked path after ordinary native return uses CURRENT E's reordered9,not history");
 Lmx *set=op(a,roles,LMX_WALK_OP_PUT,3);put(set,1,path);put(set,2,literal_int(a,roles,41));
 ck(lmx_walk_eval(&f,set,&received)==LMX_WALK_OK&&read_at(a,v,r,0)==41&&read_at(a,v,r,1)==7,"walked store after ordinary native return changes mapped41 only");
 Lmx *take=op(a,roles,LMX_WALK_OP_ADDRESS,3);put(take,1,path);void *pw=lmx_pointer_new_owned(LMX_TYPE_POINTER_BASE+LMX_TYPE_INT,a);if(!pw)abort();put(take,2,pw);
 ck(lmx_walk_eval(&f,take,&received)==LMX_WALK_OK&&received.ref==lmx_graph_value_in(a,v,slot(a,v,r,0)),"walked address after ordinary native return is the actual mapped int cell");
 if(received.ref)lmx_int_store_known(received.ref,43);
 ck(read_at(a,v,r,0)==43&&read_at(a,v,r,1)==7,"write through walked address after ordinary native return observes43 and intact neighbor7");
 lmx_scratch_close(&scratch);
 Lmx *bad=lmx_graph_ref_struct_in(a,program,10),*merged=lmx_graph_ref_struct_in(a,program,11),*conditional=lmx_graph_ref_struct_in(a,program,12);
 ck(bad&&bad->native&&merged&&merged->native&&conditional&&conditional->native,"failure/return-merge/control-body returns all select real native entries");
 before=l2_result124_bad_calls;context.model=e;context.references=sheet;
 ck(lmx_call_prim_values(a,bad,bad,NULL,0,NULL,&raw,NULL,&context)!=0&&!context.model&&!context.references&&l2_result124_bad_calls==before+1,"ordinary native receiving refusal throws once and publishes no success context");
 before=l2_result124_calls;
 ck(lmx_call_prim_values(a,conditional,conditional,NULL,0,NULL,&raw,NULL,&context)==0&&raw==v&&context.model==e&&context.references&&l2_result124_calls==before+1,"native return inside control body uses the same receiving-value producer and one source evaluation");
 ck(lmx_call_prim_values(a,merged,merged,NULL,0,NULL,&raw,NULL,&context)==0&&raw&&context.model==e&&context.references,"return-merge uses the same ordinary receiving-value producer,not a separate metadata rule");
 physical=(size_t)-1;
 ck(raw&&lmx_implements_slot(a,raw,e,2,&physical)==0&&lmx_int_value_known(lmx_graph_value_in(a,raw,physical))==2,"returned native merge preserves real SeedE v2 through its declared E result map");
 lmx_arena_release(a);printf("ordinary native result producer: %d checks, %d failures\n",checks,failures);return failures!=0;
}
