#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main projection167_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
#define abort() do{fprintf(stderr,"PROJECTION167 PRECONDITION %d\n",__LINE__);exit(96);}while(0)
static int checks,failures,watching,parsers,roots,folds,raw;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *at){(void)at;if(!watching)return;
 if(fn==(void*)l2_value_fields||fn==(void*)l2_path_steps_operand||fn==(void*)l2_expr_span)++parsers;
 if(fn==(void*)l2_path_root_resolve)++roots;if(fn==(void*)l2_path_walk_steps_from)++folds;
 if(fn==(void*)l2_check_fields||fn==(void*)l2_emit_fields_context||fn==(void*)l2_rw_texpr||fn==(void*)l2_rw_machine_actual||fn==(void*)l2_array_length_own||fn==(void*)l2_length_place||fn==(void*)l2_ccall_box_int)++raw;
}
void __cyg_profile_func_exit(void *fn,void *at){(void)fn;(void)at;}
static void begin(void){parsers=roots=folds=raw=0;watching=1;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL PROJECTION167 %s\n",why);}}
static void owners(void){l2_bound_free();l2_application_free();l2_indent_free();l2_expr_sites_free();l2_graph_places_free();l2_scope_free();for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;l2_foreign_free();l2_xfree(l2_lmx_name_cache);l2_lmx_name_cache=NULL;l2_xfree(l2_void_name_cache);l2_void_name_cache=NULL;}
static void warm(L2ValueSpan *v){int exact=-1;l2_value_span_type(v,0,&exact);if(v->operand)warm(v->operand);for(int i=0;i<v->value_n;++i)warm(v->values+i);if(v->primary){for(int i=0;i<v->primary->body_n;++i)warm(v->primary->body+i);for(int i=0;i<v->primary->body_trailer_n;++i)warm(v->primary->body_trailer+i);for(int i=0;i<v->primary->trailer_n;++i)warm(v->primary->trailer+i);}}
int main(int argc,char **argv){
 if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();
 LmP0Text p={"p",1},q={"q",1},gone={"gone",4};LmP0Text *names[]={&p,&q},*method_names[]={NULL};void *inputs[]={names};int ft[]={11,11},*types[]={ft},arity[]={2},dynamic[]={0},slots[]={0};LmP0Node *nodes[]={NULL};
 l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=l2_cur_mi=l2_rw_mi=0;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_sn=slots;l2_m_fn=inputs;l2_m_ft=types;l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="projection167";l2_rw_quiet=1;l2_construct_phase=-1;
 const char *forms[]={"cast: (int) p[q[0] + 1]","c.abs(p[q[0] + 1])","cast: (size_t) c.abs(p[q[0] + 1])","c.fmax(p[0] + 1, q[0] + 2)","length(p)","cast: (size_t) length(p)","c.abs((cast: (int) p[0]))"};
 for(unsigned k=0;k<sizeof forms/sizeof forms[0];++k){
  size_t live=l2_alloc_live;char source[512];snprintf(source,sizeof source,"return: %s\n",forms[k]);LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;int n=0;
  names[0]=&p;names[1]=&q;ft[0]=(k==4||k==5)?l2_array_desc_ty():11;ft[1]=11;
  L2ValueSpan *original=l2_value_fields(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&n);if(!original||n!=1)abort();
  int prestatus=l2_check_value_span(original,0,l2_src,stmt);printf("PROJECTION167 unpoisoned case=%u status=%d\n",k,prestatus);
#ifdef PROJECTION167_CURRENT
  ck(!prestatus,"ordinary CHECK admits the positive primary before poison");
#endif
  warm(original);L2ValueSpan held;if(l2_value_span_clone(original,&held,1))abort();l2_value_spans_release(original,n);
  names[0]=names[1]=&gone;ft[0]=ft[1]=0;
  begin();int exact=-1;int kind=l2_value_span_type(&held,0,&exact);int rty=l2_rw_span_ty(&held);watching=0;
  printf("PROJECTION167 type case=%u kind=%d exact=%d retained=%d parsers=%d roots=%d folds=%d raw=%d\n",k,kind,exact,rty,parsers,roots,folds,raw);
#ifdef PROJECTION167_CURRENT
  const int kinds[]={0,-99,2,-99,2,2,-99},exacts[]={0,-12,2,-12,2,2,-12},retained[]={0,-1,2,-1,2,2,-1};
  ck(kind==kinds[k]&&exact==exacts[k]&&rty==retained[k],"the shared primary type keeps exact cast/Array/opaque-C contracts,not just a successful query");
  ck(!parsers&&!roots&&!folds&&!raw,"type queries project the held primary contract after original owner release");
#endif
  begin();int status=l2_check_value_span(&held,0,l2_src,stmt);watching=0;
  printf("PROJECTION167 check case=%u status=%d parsers=%d roots=%d folds=%d raw=%d\n",k,status,parsers,roots,folds,raw);
#ifdef PROJECTION167_CURRENT
  ck(!status&&!parsers&&!roots&&!folds&&!raw,"CHECK retains the SAME nested children after formal-name and FT poison");
#endif
  char buffer[2048];L2Tx text={0};if(l2_tx_open(&text,buffer,sizeof buffer))abort();begin();status=l2_emit_native_span(&held,0,"",&text,NULL);watching=0;
  printf("PROJECTION167 native case=%u status=%d parsers=%d roots=%d folds=%d raw=%d\n",k,status,parsers,roots,folds,raw);
#ifdef PROJECTION167_CURRENT
  ck(!status&&text.len&&!parsers&&!roots&&!folds&&!raw,"native does not transitive-retry a raw primary body after receiving its span");
#endif
  l2_rw_t=0;l2_rw_emit=0;l2_rw_machine=0;int out=-1;begin();status=l2_rw_span(&held,-1,-2,&out);watching=0;int count=l2_rw_t,machine=l2_rw_machine;
  printf("PROJECTION167 count case=%u status=%d nodes=%d machine=%d parsers=%d roots=%d folds=%d raw=%d\n",k,status,count,machine,parsers,roots,folds,raw);
#ifdef PROJECTION167_CURRENT
  ck(count>0&&machine==(k!=4),"casts and foreign calls remain native-only; the pure Array length is actually walkable");
  ck(!status&&!parsers&&!roots&&!folds&&!raw,"retained COUNT uses the same typed primary children,not machine-actual reparsing");
#endif
  l2_rw_t=0;l2_rw_emit=1;l2_rw_machine=0;begin();status=l2_rw_span(&held,-1,-2,&out);watching=0;
  printf("PROJECTION167 emit case=%u status=%d nodes=%d machine=%d parsers=%d roots=%d folds=%d raw=%d\n",k,status,l2_rw_t,l2_rw_machine,parsers,roots,folds,raw);
#ifdef PROJECTION167_CURRENT
  ck(!status&&count==l2_rw_t&&machine==l2_rw_machine&&!parsers&&!roots&&!folds&&!raw,"retained EMIT preserves COUNT geometry and the exact held children");
#endif
  l2_rw_emit=0;names[0]=&p;names[1]=&q;l2_value_span_release(&held);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"borrowed primary projections add no owner or dangling scratch view");
 }
#ifdef PROJECTION167_CURRENT
 {
  size_t live=l2_alloc_live;const char *source="return: length(missing)\n";LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;int n=0;L2ValueSpan *tok=l2_value_fields(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&n);if(!tok||n!=1)abort();L2ValueSpan operand;if(l2_primary_slice(tok,0,-1,&operand))abort();int exact=-1;l2_value_span_type(&operand,0,&exact);
  l2_fail_left=1;l2_alloc_err=0;int status=l2_primary_array_value(tok,0,&operand);printf("PROJECTION167 unresolved Array under allocation refusal: status=%d allocation-error=%d countdown=%d\n",status,l2_alloc_err,l2_fail_left);l2_fail_left=l2_alloc_err=0;
  ck(status!=0,"an unresolved Array operand cannot match a failed descriptor-type interning sentinel");l2_value_spans_release(tok,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"the refused Array contract balances its prepared owners");
 }
#endif
 fclose(l2_out);printf("PROJECTION167: %d checks, %d failures\n",checks,failures);return failures!=0;
}
