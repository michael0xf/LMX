#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main opaque_address168_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
#define abort() do{fprintf(stderr,"OPAQUE_ADDRESS168 PRECONDITION %d\n",__LINE__);exit(96);}while(0)
static int checks,failures,watching,parsers,roots,folds,raw;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *at){(void)at;if(!watching)return;if(fn==(void*)l2_value_fields||fn==(void*)l2_path_steps_operand||fn==(void*)l2_expr_span)++parsers;if(fn==(void*)l2_path_root_resolve)++roots;if(fn==(void*)l2_path_walk_steps_from)++folds;if(fn==(void*)l2_check_fields||fn==(void*)l2_emit_fields_context||fn==(void*)l2_rw_texpr)++raw;}
void __cyg_profile_func_exit(void *fn,void *at){(void)fn;(void)at;}
static void begin(void){parsers=roots=folds=raw=0;watching=1;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL OPAQUE_ADDRESS168 %s\n",why);}}
static void owners(void){l2_bound_free();l2_application_free();l2_indent_free();l2_expr_sites_free();l2_graph_places_free();l2_scope_free();for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;l2_foreign_free();l2_xfree(l2_lmx_name_cache);l2_lmx_name_cache=NULL;l2_xfree(l2_void_name_cache);l2_void_name_cache=NULL;}
int main(int argc,char **argv){
 if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();
 LmP0Text p={"p",1},gone={"gone",4},foreign={"c.L2DispatchPair",16};LmP0Text *names[]={&p},*method_names[]={NULL};void *inputs[]={names};int ft[]={0},*types[]={ft},arity[]={1},dynamic[]={0},slots[]={0},returns[]={0};LmP0Node *nodes[]={NULL};
 l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=l2_cur_mi=l2_rw_mi=0;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_sn=slots;l2_m_fn=inputs;l2_m_ft=types;l2_m_name=method_names;l2_m_ret=returns;l2_m_node=l2_m_body=nodes;l2_src="opaque-address168";l2_rw_quiet=1;l2_construct_phase=-1;
 const char *forms[]={"@p\\value","@: (p\\value)","(@: ((p\\value)))"};
 for(int k=0;k<3;++k){size_t live=l2_alloc_live;names[0]=&p;ft[0]=l2_foreign_intern(&foreign,0,0);if(ft[0]<100)abort();char source[512];snprintf(source,sizeof source,"return: %s\n",forms[k]);LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
  L2ValueSpan original;if(l2_value_expression_prepare(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&original))abort();int pre=l2_check_value_span(&original,0,l2_src,stmt);ck(!pre,"CHECK accepts the selected opaque machine-member address before poison,without inventing a primitive field type");
  L2ValueSpan held;if(l2_value_span_clone(&original,&held,1))abort();l2_value_span_release(&original);names[0]=&gone;ft[0]=0;
  begin();int status=l2_check_value_span(&held,0,l2_src,stmt);watching=0;printf("OPAQUE_ADDRESS168 check case=%d status=%d parsers=%d roots=%d folds=%d raw=%d\n",k,status,parsers,roots,folds,raw);ck(!status&&!parsers&&!roots&&!folds&&!raw,"CHECK retains the accepted opaque address result,not a requirement for a known L2 member type");
  char buffer[4096];L2Tx text={0};if(l2_tx_open(&text,buffer,sizeof buffer))abort();begin();status=l2_emit_native_span(&held,0,"",&text,NULL);watching=0;printf("OPAQUE_ADDRESS168 native case=%d status=%d parsers=%d roots=%d folds=%d raw=%d\n",k,status,parsers,roots,folds,raw);ck(!status&&text.len&&!parsers&&!roots&&!folds&&!raw,"native uses the same C-root and member coordinates after name/FT poison");
  l2_rw_t=0;l2_rw_emit=0;l2_rw_machine=0;int out=-1;begin();status=l2_rw_span(&held,-1,-2,&out);watching=0;int count=l2_rw_t,machine=l2_rw_machine;printf("OPAQUE_ADDRESS168 count case=%d status=%d nodes=%d machine=%d parsers=%d roots=%d folds=%d raw=%d\n",k,status,count,machine,parsers,roots,folds,raw);ck(!status&&count>0&&machine&&!parsers&&!roots&&!folds&&!raw,"retained opaque C address COUNT projects its accepted machine representation");
  l2_rw_t=0;l2_rw_emit=1;l2_rw_machine=0;begin();status=l2_rw_span(&held,-1,-2,&out);watching=0;printf("OPAQUE_ADDRESS168 emit case=%d status=%d nodes=%d machine=%d parsers=%d roots=%d folds=%d raw=%d\n",k,status,l2_rw_t,l2_rw_machine,parsers,roots,folds,raw);ck(!status&&count==l2_rw_t&&machine==l2_rw_machine&&!parsers&&!roots&&!folds&&!raw,"opaque EMIT matches COUNT without source/type retry");
  l2_rw_emit=0;names[0]=&p;l2_value_span_release(&held);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"opaque address keeps no borrowed owner or fabricated type allocation");
 }
 fclose(l2_out);printf("OPAQUE_ADDRESS168: %d checks, %d failures\n",checks,failures);return failures!=0;
}
