#include "codex_body123_inherited_channel.c"
#define main l2_generated_main
#ifndef CALL125_SOURCE
#define CALL125_SOURCE "codex_formal127_probe_01/unit.c"
#endif
#include CALL125_SOURCE
#undef main
static void formal127_input(LmxArena *a,Lmx *program,int source,int typed,int target,LmxWalkValue in[2],void *args[2]){
 LmxWalkValue context={0};void *raw=NULL;l2_test_declared_raw=NULL;
 Lmx *fn=lmx_graph_ref_struct_in(a,program,typed?11U:(source?8U:7U));
 void *choice[]={number(a,source)};
 if(!fn||lmx_call_prim_values(a,fn,fn,typed?choice:NULL,typed?1U:0U,NULL,&raw,NULL,&context)||!raw||!context.model||!context.references)abort();
 lmx_walk_value_ref_parts(in,typed?LMX_TYPE_LMX:LMX_TYPE_POINTER_BASE+16,raw,context.model,context.references);
 lmx_walk_value_num(in+1,LMX_TYPE_INT,(size_t)target);
 args[0]=lmx_walk_value_storage(in);args[1]=lmx_walk_value_storage(in+1);
}
int main(void){
 (void)channel122_main();
 LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
 Lmx *program=node(a,32);if(l2_program_build(a,program,NULL))abort();
 Lmx *d=lmx_graph_ref_struct_in(a,program,1),*e=lmx_graph_ref_struct_in(a,program,2),*r=lmx_graph_ref_struct_in(a,program,5);
 Lmx *roles=lmx_walk_roles_open(a);test_parent=program;if(!roles)abort();
 LmxPool cells={0};LmxScratch scratch={0};if(lmx_scratch_open(&scratch,a,&cells,128)!=LMX_SCRATCH_OK)abort();
 LmxWalkContext ctx={0};ctx.arena=a;ctx.roles=roles;ctx.scratch=&scratch;
 LmxWalkFrame f={0};f.context=&ctx;f.arena=a;f.roles=roles;f.node=f.code=f.source=program;
 {
  Lmx *forward=lmx_graph_ref_struct_in(a,program,10),*receive=lmx_graph_ref_struct_in(a,program,11);
  void *args[]={number(a,2)},*raw=NULL;LmxWalkValue result={0};unsigned before=l2_call125_source_calls;
  int status=lmx_call_prim_values(a,forward,forward,args,1,NULL,&raw,NULL,&result);
  ck(status==0&&raw&&result.model==e&&!result.references&&l2_call125_source_calls==before+1,"native universal forwarding preserves a malformed present pair without erasing it to untyped");
  before=l2_call125_source_calls;
  status=lmx_call_prim_values(a,receive,receive,args,1,NULL,&raw,NULL,&result);
  ck(status!=0&&!result.model&&!result.references&&l2_call125_source_calls==before+1,"ordinary native receiving rejects half-present computed call context rather than rescuing it from raw candidate history");
  args[0]=number(a,3);before=l2_call125_source_calls;
  status=lmx_call_prim_values(a,forward,forward,args,1,NULL,&raw,NULL,&result);
  ck(status==0&&!raw&&result.model==e&&result.references&&l2_call125_source_calls==before+1,"grouped native universal forwarding preserves present-null CURRENT Model/reference sheet");
  before=l2_call125_source_calls;
  status=lmx_call_prim_values(a,receive,receive,args,1,NULL,&raw,NULL,&result);
  ck(status==0&&!raw&&result.model==r&&result.references&&l2_call125_source_calls==before+1,"ordinary native receiver validates and republishes present-null call result as its declared R");
  ck(!lmx_implements_find(a,l2_test_declared_raw,r),"null receiving publishes context without admitting an unrelated non-null candidate");
 }
 {
  Lmx *stored=lmx_graph_ref_struct_in(a,program,14),*receive=lmx_graph_ref_struct_in(a,program,15);
  void *args[]={number(a,2)},*raw=NULL;LmxWalkValue result={0};unsigned before=l2_call125_source_calls;
  int status=lmx_call_prim_values(a,stored,stored,args,1,NULL,&raw,NULL,&result);
  ck(status==0&&raw&&result.model==e&&!result.references&&l2_call125_source_calls==before+1,"working-value store/load preserves malformed present pair rather than erasing to raw");
  before=l2_call125_source_calls;status=lmx_call_prim_values(a,receive,receive,args,1,NULL,&raw,NULL,&result);
  ck(status!=0&&!result.model&&!result.references&&l2_call125_source_calls==before+1,"receiving a loaded working value rejects half-present metadata with no history rescue");
  args[0]=number(a,3);before=l2_call125_source_calls;status=lmx_call_prim_values(a,stored,stored,args,1,NULL,&raw,NULL,&result);
  ck(status==0&&!raw&&result.model==e&&result.references&&l2_call125_source_calls==before+1,"present-null working value retains CURRENT context through store/load and ordinary universal return");
  before=l2_call125_source_calls;status=lmx_call_prim_values(a,receive,receive,args,1,NULL,&raw,NULL,&result);
  ck(status==0&&!raw&&result.model==r&&result.references&&l2_call125_source_calls==before+1,"ordinary receiving consumes loaded present-null working context and returns R");
 }
 for(int choice=0;choice<2;++choice){
  Lmx *forward=lmx_graph_ref_struct_in(a,program,10);void *args[]={number(a,choice)},*raw=NULL;LmxWalkValue context={0};
  unsigned before=l2_call125_source_calls,raw_before=l2_call125_raw_calls;
  int status=lmx_call_prim_values(a,forward,forward,args,1,NULL,&raw,NULL,&context);
  ck(status==0&&raw&&context.model==(choice?e:d)&&context.references&&l2_call125_source_calls==before+1&&l2_call125_raw_calls==raw_before+1,"ordinary universal forwarding return preserves the runtime-selected CURRENT pair through grouped native call,once");
  Lmx *stored=lmx_graph_ref_struct_in(a,program,14),*clear=lmx_graph_ref_struct_in(a,program,18);before=l2_call125_source_calls;
  status=lmx_call_prim_values(a,stored,stored,args,1,NULL,&raw,NULL,&context);
  ck(status==0&&raw&&context.model==(choice?e:d)&&context.references&&l2_call125_source_calls==before+1,"ordinary native working pointer forwards runtime-selected pair without guessing it from type or raw address");
  before=l2_call125_source_calls;status=lmx_call_prim_values(a,clear,clear,args,1,NULL,&raw,NULL,&context);
  ck(status==0&&!raw&&!context.model&&!context.references&&l2_call125_source_calls==before+1,"unannotated replacement clears prior working context instead of retaining stale Model/sheet");
  for(size_t method=11;method<=21;++method){
   if(method==14||method==18)continue;
   unsigned expected_calls=(method==16||method==17||method==20)?2U:1U;
   Lmx *fn=lmx_graph_ref_struct_in(a,program,method);raw=NULL;context.model=e;context.references=NULL;before=l2_call125_source_calls;raw_before=l2_call125_raw_calls;
   status=lmx_call_prim_values(a,fn,fn,args,1,NULL,&raw,NULL,&context);
   ck(fn&&fn->native&&status==0&&raw&&context.model==r&&context.references&&l2_call125_source_calls==before+expected_calls&&l2_call125_raw_calls==raw_before+expected_calls,"ordinary native receiver consumes computed/working pair through SAME admission,each written source evaluated once");
   Lmx *value=raw;int expected=choice?9:7,neighbor=choice?7:9;size_t mapped=(size_t)-1;
   int mapped_ok=value&&lmx_implements_slot(a,value,r,0,&mapped)==0;
   ck(mapped_ok&&mapped==(size_t)choice&&read_at(a,value,r,0)==expected&&read_at(a,value,r,2)==neighbor,"native receiving projection follows runtime D/E current context,not first historical admission or static return type");
   void **address=mapped_ok?lmx_graph_ref_cell_in(a,value,mapped):NULL;
   ck(address&&lmx_int_store_known(*address,41)==0&&read_at(a,value,r,0)==41&&read_at(a,value,r,2)==neighbor,"native result's receiving map controls real41 write and preserves other field");
   if(address)*address=number(a,43);
   ck(mapped_ok&&read_at(a,value,r,0)==43&&read_at(a,value,r,2)==neighbor,"native taken-address replacement observes43 with intact neighbor under either runtime current view");
   Lmx *sig=node(a,2);put(sig,0,lmx_graph_ref_struct_in(a,fn,0));put(sig,1,lmx_graph_ref_struct_in(a,fn,1));
   Lmx *call=call_node(a,roles,fn,sig,literal_int(a,roles,choice),0);LmxWalkValue result={0};before=l2_call125_source_calls;raw_before=l2_call125_raw_calls;
   status=lmx_walk_eval(&f,call,&result);value=result.ref;
   ck(status==LMX_WALK_OK&&value&&result.model==r&&result.references&&l2_call125_source_calls==before+expected_calls&&l2_call125_raw_calls==raw_before+expected_calls,"real walked CALL reaches native receiver with computed/working pair and evaluates each written source once");
   ck(value&&read_at(a,value,r,0)==expected&&read_at(a,value,r,2)==neighbor,"walked CALL result carries actual reordered values after native receiving admission");
   /* Subsequent operations consume this computed Value; they must not
      execute the source call again and allocate a fresh candidate. */
   f.guarded=&result;
   Lmx *path=op(a,roles,LMX_WALK_OP_OF,4);put(path,1,op(a,roles,LMX_WALK_OP_GUARDED,1));size_at(a,path,2,0);put(path,3,r);
   LmxWalkValue out={0};
   ck(lmx_walk_eval(&f,path,&out)==LMX_WALK_OK&&out.number==expected&&l2_call125_source_calls==before+expected_calls,"walked path reads SAME computed received value without re-evaluating runtime selector");
   Lmx *set=op(a,roles,LMX_WALK_OP_PUT,3);put(set,1,path);put(set,2,literal_int(a,roles,41));
   ck(lmx_walk_eval(&f,set,&out)==LMX_WALK_OK&&value&&read_at(a,value,r,0)==41&&read_at(a,value,r,2)==neighbor,"walked PUT uses native call's admitted current map for actual41");
   Lmx *take=op(a,roles,LMX_WALK_OP_ADDRESS,3);put(take,1,path);void *pw=lmx_pointer_new_owned(LMX_TYPE_POINTER_BASE+LMX_TYPE_INT,a);if(!pw)abort();put(take,2,pw);
   mapped=(size_t)-1;mapped_ok=value&&lmx_implements_slot(a,value,r,0,&mapped)==0;
   ck(lmx_walk_eval(&f,take,&out)==LMX_WALK_OK&&mapped_ok&&out.ref==lmx_graph_value_in(a,value,mapped),"walked address names actual mapped int cell from the native receiving result");
   if(out.ref)lmx_int_store_known(out.ref,43);
   ck(value&&read_at(a,value,r,0)==43&&read_at(a,value,r,2)==neighbor&&l2_call125_source_calls==before+expected_calls,"write through walked address observes43 and intact neighbor without any source re-evaluation");
   f.guarded=NULL;
  }
 }
 {
  LmxWalkValue in[2],context={0};void *args[2],*raw=NULL;formal127_input(a,program,1,0,0,in,args);
  Lmx *echo=lmx_graph_ref_struct_in(a,program,22),*receive=lmx_graph_ref_struct_in(a,program,23),*clear=lmx_graph_ref_struct_in(a,program,26),*sheet=in[0].references;
  void *original=in[0].ref;int status;
  in[0].ref=NULL;
  status=lmx_call_prim_values(a,echo,echo,args,1,NULL,&raw,in,&context);
  ck(status==0&&!raw&&context.model==e&&context.references==sheet,"native formal entry and read preserve present-null CURRENT input pair");
  status=lmx_call_prim_values(a,receive,receive,args,1,NULL,&raw,in,&context);
  ck(status==0&&!raw&&context.model==r&&context.references,"ordinary native receiving consumes present-null formal pair and publishes its required R");
  status=lmx_call_prim_values(a,clear,clear,args,1,NULL,&raw,in,&context);
  ck(status==0&&!raw&&!context.model&&!context.references&&in[0].model==e&&in[0].references==sheet,"null formal rebinding clears local pair without clearing caller-owned null metadata");
  in[0].ref=original;in[0].references=NULL;
  status=lmx_call_prim_values(a,echo,echo,args,1,NULL,&raw,in,&context);
  ck(status==0&&raw==original&&context.model==e&&!context.references,"native formal entry/load transports a malformed present pair without silently erasing it");
  status=lmx_call_prim_values(a,receive,receive,args,1,NULL,&raw,in,&context);
  ck(status!=0&&!context.model&&!context.references&&!lmx_implements_find(a,original,r),"ordinary native formal receiving rejects malformed pair instead of raw-history rescue");
  ck(in[0].ref==original&&in[0].model==e&&!in[0].references,"failed formal receiving never edits the caller's input value/context");
  in[0].references=sheet;
  status=lmx_call_prim_values(a,echo,echo,args,1,NULL,&raw,NULL,&context);
  ck(status==0&&raw==original&&!context.model&&!context.references,"raw native caller remains unannotated rather than inheriting a previous activation's formal pair");
  status=lmx_call_prim_values(a,echo,echo,args,1,NULL,&raw,in,in);
  ck(status==0&&raw==original&&in[0].ref==original&&in[0].model==e&&in[0].references==sheet,"native formal snapshot is established before an aliased output-context destination can overwrite caller metadata");
 }
 for(int source=0;source<2;++source){
  const size_t special[]={22,26,28,29};
  for(size_t k=0;k<4;++k){
   size_t method=special[k];LmxWalkValue in[2],context={0};void *args[2],*raw=NULL;int target=1-source;
   formal127_input(a,program,source,0,target,in,args);void *original=in[0].ref;Lmx *model=in[0].model,*sheet=in[0].references;
   unsigned before=l2_call125_source_calls,raw_before=l2_call125_raw_calls;Lmx *fn=lmx_graph_ref_struct_in(a,program,method);
   int status=lmx_call_prim_values(a,fn,fn,args,method==29?2U:1U,NULL,&raw,in,&context);
   if(method==22)ck(status==0&&raw==original&&context.model==model&&context.references==sheet,"ordinary native formal read returns CURRENT input pair without explicit metadata service");
   if(method==26)ck(status==0&&!raw&&!context.model&&!context.references,"formal unannotated null replacement clears its current pair");
   if(method==28)ck(status==0&&raw==original&&!context.model&&!context.references&&l2_call125_raw_calls==raw_before+1,"formal raw replacement clears context even when the raw address happens to be identical");
   if(method==29)ck(status==0&&raw&&raw!=original&&context.model==(target?e:d)&&context.references&&read_at(a,raw,context.model,target?2:0)==(target?9:7),"formal rebinding forwards new computed CURRENT pair rather than stale caller input metadata");
   ck(in[0].ref==original&&in[0].model==model&&in[0].references==sheet&&l2_call125_source_calls==before+(method==29?1U:0U),"native formal state is activation-owned and never mutates the caller's computed input record");
  }
  const size_t methods[]={23,24,25,27,30};
  for(size_t k=0;k<5;++k)for(int walked=0;walked<2;++walked){
   size_t method=methods[k];int rebound=method==25||method==27,typed=method==27,target=rebound?1-source:source;
   unsigned acts=rebound||method==30?1U:0U;
   LmxWalkValue in[2],result={0},part={0};void *args[2],*raw=NULL;
   formal127_input(a,program,source,typed,target,in,args);void *original=in[0].ref;Lmx *model=in[0].model,*sheet=in[0].references;
   unsigned before=l2_call125_source_calls;Lmx *fn=lmx_graph_ref_struct_in(a,program,method);size_t nargs=rebound?2U:1U;
   int status;
   if(walked){
    Lmx *sig=node(a,2);put(sig,0,lmx_graph_ref_struct_in(a,fn,0));put(sig,1,lmx_graph_ref_struct_in(a,fn,1));
    Lmx *call=op(a,roles,LMX_WALK_OP_CALL,5+nargs);put(call,1,fn);put(call,3,sig);put(call,5,op(a,roles,LMX_WALK_OP_GUARDED,1));if(nargs==2)put(call,6,literal_int(a,roles,target));
    f.guarded=in;status=lmx_walk_eval(&f,call,&result);raw=result.ref;
   }else{
    status=lmx_call_prim_values(a,fn,fn,args,nargs,NULL,&raw,in,&result);
   }
   Lmx *value=raw;int expected=target?9:7,neighbor=target?7:9;size_t mapped=(size_t)-1;
   int mapped_ok=value&&lmx_implements_slot(a,value,r,0,&mapped)==0;
   ck(status==0&&value&&result.model==r&&result.references&&l2_call125_source_calls==before+acts,"native or real walked CALL consumes CURRENT formal state through ordinary receiving,not its original caller snapshot");
   Lmx *path=NULL,*take=NULL;void **address=NULL;
   if(walked){
    f.guarded=&result;path=op(a,roles,LMX_WALK_OP_OF,4);put(path,1,op(a,roles,LMX_WALK_OP_GUARDED,1));size_at(a,path,2,0);put(path,3,r);
    ck(lmx_walk_eval(&f,path,&part)==LMX_WALK_OK&&part.number==expected&&read_at(a,value,r,2)==neighbor&&mapped_ok&&mapped==(size_t)target,"walked path uses actual reordered formal-result map and reads7/9");
    Lmx *set=op(a,roles,LMX_WALK_OP_PUT,3);put(set,1,path);put(set,2,literal_int(a,roles,41));
    ck(lmx_walk_eval(&f,set,&part)==LMX_WALK_OK&&value&&read_at(a,value,r,0)==41&&read_at(a,value,r,2)==neighbor,"walked PUT after native formal receiving updates mapped41 only");
    take=op(a,roles,LMX_WALK_OP_ADDRESS,3);put(take,1,path);void *pw=lmx_pointer_new_owned(LMX_TYPE_POINTER_BASE+LMX_TYPE_INT,a);if(!pw)abort();put(take,2,pw);
    ck(lmx_walk_eval(&f,take,&part)==LMX_WALK_OK&&mapped_ok&&part.ref==lmx_graph_value_in(a,value,mapped),"walked address after native formal receiving is the actual mapped int cell");
    if(part.ref)lmx_int_store_known(part.ref,43);
   }else{
    ck(mapped_ok&&mapped==(size_t)target&&read_at(a,value,r,0)==expected&&read_at(a,value,r,2)==neighbor,"native formal-result receiving map reads actual7/9 rather than old current view");
    address=mapped_ok?lmx_graph_ref_cell_in(a,value,mapped):NULL;
    ck(address&&lmx_int_store_known(*address,41)==0&&read_at(a,value,r,0)==41&&read_at(a,value,r,2)==neighbor,"native formal-result map controls real41 store");
    ck(address&&address==lmx_graph_ref_cell_in(a,value,(size_t)target),"native taken address identifies the actual reordered physical field");
    if(address)*address=number(a,43);
   }
   int old_untouched=!rebound||read_at(a,original,model,typed?0:(source?2:0))==(source?9:7);
   ck(value&&read_at(a,value,r,0)==43&&read_at(a,value,r,2)==neighbor&&in[0].ref==original&&in[0].model==model&&in[0].references==sheet&&old_untouched&&l2_call125_source_calls==before+acts,"address write observes43 and intact neighbor;rebinding leaves caller value/context unchanged and never re-evaluates sources");
   f.guarded=NULL;
  }
 }
 lmx_scratch_close(&scratch);lmx_arena_release(a);
 printf("computed native call context: %d checks, %d failures\n",checks,failures);return failures!=0;
}
