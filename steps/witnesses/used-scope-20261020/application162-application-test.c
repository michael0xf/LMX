#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main application161_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
#define abort() do { fprintf(stderr,"APPLICATION161 PRECONDITION %d\n",__LINE__);exit(96); } while(0)
static int checks,failures,watching,adapters,roots,folds,old_spans,bindings,old_named;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){(void)site;if(!watching)return;if(fn==(void*)l2_path_steps_operand)++adapters;if(fn==(void*)l2_path_root_resolve)++roots;if(fn==(void*)l2_path_walk_steps_from)++folds;if(fn==(void*)l2_expr_span)++old_spans;if(fn==(void*)l2_bind_value_actuals)++bindings;if(fn==(void*)l2_call_actuals)++old_named;}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;}
static void begin(void){adapters=roots=folds=old_spans=bindings=old_named=0;watching=1;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL APPLICATION161: %s\n",why);}}
static void owners(void){l2_bound_free();l2_application_free();l2_indent_free();l2_expr_sites_free();l2_graph_places_free();l2_scope_free();for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;l2_foreign_free();l2_xfree(l2_lmx_name_cache);l2_lmx_name_cache=NULL;l2_xfree(l2_void_name_cache);l2_void_name_cache=NULL;l2_xfree(l2_sender_name_cache);l2_sender_name_cache=NULL;l2_xfree(l2_payload_name_cache);l2_payload_name_cache=NULL;}
static L2ValueSpan *body(const char *source,LmP0Document **doc,int *n){
 if(lm_p0_parse_bytes(source,strlen(source),doc)||!*doc)abort();
 LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(*doc)->as->structure->first_field)->value;
 L2ValueSpan *outer=l2_value_fields(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),n);
 if(!outer||*n!=1||!outer->primary)abort();return outer;
}
int main(int argc,char **argv){
 if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();
 LmP0Text p={"p",1},q={"q",1},r={"r",1},a={"a",1},b={"b",1},deliver={"deliver",7};LmP0Text *names[]={&p,&q},*formal[]={&a,&b},*method_names[]={NULL,&deliver};void *input_rows[]={names,formal};
 int ft0[]={11,11},ft1[]={11,11},*ft_rows[]={ft0,ft1},arity[]={2,2},dynamic[]={0,0},slots[]={0,0};LmP0Node *nodes[]={NULL,NULL};
 l2_m_n=l2_m_cap=l2_slot_cap=2;l2_e=l2_cur_mi=l2_rw_mi=0;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="application161";l2_rw_quiet=1;l2_construct_phase=-1;
 const char *forms[]={"return: deliver(b: q[0] + 1; a: p[q[0]])\n","return: deliver(p[q[0]]; q[0] + 1)\n","return: deliver(a: (); b: 1 2)\n"};
 for(unsigned k=0;k<sizeof forms/sizeof forms[0];++k){
  size_t baseline=l2_alloc_live;LmP0Document *doc=NULL;int n=0;L2ValueSpan *outer=body(forms[k],&doc,&n);L2PrimaryBody *owned=outer->primary;L2ApplicationActuals plan={0};size_t live=l2_alloc_live;
  begin();int status=l2_bind_value_actuals(owned->body,owned->body_n,2,formal,"deliver",l2_src,outer->node,&plan);watching=0;
  ck(!status&&plan.count==2&&plan.written_count==2&&!adapters&&!roots&&!folds&&!old_spans,"formal projection borrows the prepared argument list with no parser,path adapter or binding search");
  ck(plan.actuals[0].rank==(k==0?1:0)&&plan.actuals[1].rank==(k==0?0:1),"formal coordinate and written evaluation order remain distinct");
  ck((plan.actuals[0].wrapper!=NULL)==(k!=1)&&(plan.actuals[1].wrapper!=NULL)==(k!=1),"only the signature selects named wrappers;positional values stay positional");
  if(k<2)for(int j=0;j<2;++j){
   L2ValueSpan *v=&plan.actuals[j].value;int exact=-1;begin();int kind=l2_value_span_type(v,0,&exact);watching=0;
   ck(kind==0&&exact==0&&!adapters&&!old_spans,"projected actual closes through its existing complete path and nested INDEX children");
   L2ValueSpan *original=plan.actuals[j].written;if(k==0)original=original->primary->body;
   ck(v->grammar==3?v->values==original&&v->value_n>1:v->prepared==original->prepared&&v->prepared->value_status==1,"the formal projection shares the same owned verdict or expression list,not copied or rebound paths");
   char text[1024];L2Tx dest={0};if(l2_tx_open(&dest,text,sizeof text))abort();begin();status=l2_check_value_span(v,0,l2_src,v->node);status|=l2_emit_native_span(v,0,"",&dest,NULL);watching=0;
   ck(!status&&!adapters&&!old_spans,"CHECK/native first close independently evaluated INDEX children using the same held grammar");
   names[0]=names[1]=&r;ft0[0]=ft0[1]=0;if(l2_tx_open(&dest,text,sizeof text))abort();
   begin();status=l2_check_value_span(v,0,l2_src,v->node);status|=l2_emit_native_span(v,0,"",&dest,NULL);watching=0;
   ck(!status&&!adapters&&!roots&&!folds&&!old_spans,"CHECK/native keep the same projected actual after original name and type poison");
   int out=-1;l2_rw_t=0;l2_rw_emit=0;l2_rw_machine=0;begin();status=l2_rw_span(v,0,-2,&out);watching=0;int count=l2_rw_t,machine=l2_rw_machine;
   ck(!status&&!adapters&&!roots&&!folds&&!old_spans,"COUNT borrows the same projected actual verdict");
   l2_rw_t=0;l2_rw_emit=1;l2_rw_machine=0;begin();status=l2_rw_span(v,0,-2,&out);watching=0;l2_rw_emit=0;
   ck(!status&&count==l2_rw_t&&machine==l2_rw_machine&&!adapters&&!roots&&!folds&&!old_spans,"EMIT preserves projected COUNT topology after name and type poison");
   names[0]=&p;names[1]=&q;ft0[0]=ft0[1]=11;
  }else{
   ck(plan.actuals[0].structured&&plan.actuals[0].value.value_n==0&&plan.actuals[0].value.count==0,"empty named body keeps its structural receiving role,not an invented zero");
   ck(plan.actuals[1].structured&&plan.actuals[1].value.value_n==2&&plan.actuals[1].value.values==owned->body[1].primary->body,"nonexpression named body borrows all written fields,not only its first value");
  }
  LmP0Field *actual[2]={0};int spans[2]={0};begin();status=l2_bind_actuals(outer->node->as->frame->body->first_field,2,formal,"deliver",actual,spans,l2_src,outer->node);watching=0;
  ck(!status&&!old_spans&&actual[0]==plan.actuals[0].written->first&&actual[1]==plan.actuals[1].written->first,"raw compatibility entry uses the same formal projection,not the old expression-span binder");
  ck(spans[0]==(k==1?plan.actuals[0].value.count:0)&&spans[1]==(k==1?plan.actuals[1].value.count:0),"legacy coordinates remain exact while actual values retain their original owners");
  begin();status=l2_scan_actuals_value(outer->node,outer,0,NULL);watching=0;
  ck(!status&&bindings==1&&!old_named&&!adapters&&!old_spans,"lexical named/positional/structural actuals consume the same projection,not a private formal recognizer or source parser");
  size_t before_release=l2_alloc_live;L2PrimaryBody *same_owner=outer->primary;l2_value_actuals_release(&plan);ck((size_t)l2_alloc_live+1==before_release&&same_owner==outer->primary&&outer->primary->body==owned->body,"releasing projection metadata releases exactly its one allocation,never borrowed body or nested verdicts");
  l2_value_spans_release(outer,n);owners();lm_p0_document_destroy(doc);ck(l2_alloc_live==baseline,"whole application source owners balance at compilation close");
 }
 {
  const char *source="return: deliver(a: q[0]; b: - p[0])\n";LmP0Document *doc=NULL;int n=0;L2ValueSpan *outer=body(source,&doc,&n);L2ApplicationActuals plan={0};begin();int status=l2_bind_value_actuals(outer->primary->body,outer->primary->body_n,2,formal,"deliver",l2_src,outer->node,&plan);watching=0;
  int first_fields=l2_count_active(outer->primary->body[0].node->as->frame->body),second_fields=l2_count_active(outer->primary->body[1].node->as->frame->body);
  printf("APPLICATION161 named-prefix raw-fields=%d/%d projected-fields=%d/%d\n",first_fields,second_fields,plan.actuals[0].value.count,plan.actuals[1].value.count);
  ck(!status&&!adapters&&!roots&&!folds&&!old_spans&&plan.actuals[0].value.count==first_fields&&plan.actuals[1].value.count==second_fields&&plan.actuals[1].value.operand&&plan.actuals[1].value.count==1+plan.actuals[1].value.operand->count,"named prefix retains the exact original field counts and its own complete expression,never joins the preceding formal's value");
  ck(plan.actuals[1].value.operand==outer->primary->body[1].primary->body->operand&&!plan.actuals[1].structured,"named prefix borrows its exact existing child without synthetic P0 wrapping");
  begin();status=l2_scan_actuals_value(outer->node,outer,0,NULL);watching=0;ck(!status&&bindings==1&&!old_named&&!adapters&&!old_spans,"named prefix lexical traversal uses the common projection too");l2_value_actuals_release(&plan);l2_value_spans_release(outer,n);owners();lm_p0_document_destroy(doc);
 }
 {
  const char *bad[]={"return: deliver(a: q[0]; a: p[0])\n","return: deliver(a: q[0]; p[0])\n","return: deliver(a: q[0])\n","return: deliver(p[0]; q[0]; 1)\n","return: deliver(a: q[0]; typo: p[0])\n"};
  for(unsigned k=0;k<sizeof bad/sizeof bad[0];++k){LmP0Document *doc=NULL;int n=0;L2ValueSpan *outer=body(bad[k],&doc,&n);L2ApplicationActuals plan={0};size_t live=l2_alloc_live;begin();int status=l2_bind_value_actuals(outer->primary->body,outer->primary->body_n,2,formal,"deliver",l2_src,outer->node,&plan);watching=0;ck(status&&plan.actuals==NULL&&!plan.count&&!plan.written_count&&!adapters&&!old_spans,"refused named/positional binding is transactional and never retries raw source");ck(l2_alloc_live==live,"refused binding preserves source owners and releases all projection storage");l2_value_spans_release(outer,n);owners();lm_p0_document_destroy(doc);}
 }
 {
  LmP0Document *doc=NULL;int n=0;L2ValueSpan *outer=body(forms[0],&doc,&n);L2ApplicationActuals plan={0};size_t live=l2_alloc_live,before=l2_alloc_n;if(l2_bind_value_actuals(outer->primary->body,outer->primary->body_n,2,formal,"deliver",l2_src,outer->node,&plan))abort();size_t sites=l2_alloc_n-before;l2_value_actuals_release(&plan);ck(sites>0&&sites<=(size_t)INT_MAX&&l2_alloc_live==live,"measure actual projection allocation sites");
  for(size_t point=1;point<=sites;++point){l2_fail_left=(int)point;l2_alloc_err=0;begin();int status=l2_bind_value_actuals(outer->primary->body,outer->primary->body_n,2,formal,"deliver",l2_src,outer->node,&plan);watching=0;ck(status&&l2_alloc_err&&l2_fail_left==0&&!plan.actuals&&!plan.count&&!adapters&&!roots&&!folds&&!old_spans,"every projection allocation refusal is final without parser fallback");ck(l2_alloc_live==live,"failed projection leaves exact original grammar owners alive");l2_fail_left=l2_alloc_err=0;}
  printf("APPLICATION161 projection-allocation-sites=%zu\n",sites);l2_value_spans_release(outer,n);owners();lm_p0_document_destroy(doc);
 }
 {
  enum { formal_count=129 };char words[formal_count][24];LmP0Text text[formal_count],*many[formal_count];char source[8192];strcpy(source,"return: deliver(");
  for(int i=0;i<formal_count;++i){snprintf(words[i],sizeof words[i],"argument%d",i);text[i].data=words[i];text[i].length=strlen(words[i]);many[i]=text+i;}
  for(int i=formal_count-1;i>=0;--i){strcat(source,words[i]);strcat(source,": q[0]");strcat(source,i?"; ":")\n");}
  LmP0Document *doc=NULL;int n=0;size_t baseline=l2_alloc_live;L2ValueSpan *outer=body(source,&doc,&n);L2ApplicationActuals plan={0};begin();int status=l2_bind_value_actuals(outer->primary->body,outer->primary->body_n,formal_count,many,"deliver",l2_src,outer->node,&plan);watching=0;
  ck(!status&&plan.count==formal_count&&plan.written_count==formal_count&&!adapters&&!roots&&!folds&&!old_spans,"129 reordered formals use the same dynamic projection without a form or count ceiling");
  for(int i=0;i<formal_count;++i)ck(plan.actuals[i].rank==formal_count-1-i&&plan.actuals[i].wrapper==outer->primary->body[formal_count-1-i].node&&plan.actuals[i].value.prepared==outer->primary->body[formal_count-1-i].primary->body->prepared,"every high formal coordinate retains written order and the exact owned INDEX record");
  l2_value_actuals_release(&plan);l2_value_spans_release(outer,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==baseline,"large formal projection and source owners release completely");
 }
 fclose(l2_out);l2_out=NULL;printf("APPLICATION161: %d checks, %d failures\n",checks,failures);return failures!=0;
}
