#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main receive159_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,adapters,roots,folds,compatibility_depth,type_adapters;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
 (void)site;if(!watching)return;
 if(fn==(void*)l2_colon_types_compatible)++compatibility_depth;
 if(fn==(void*)l2_path_steps_operand){if(compatibility_depth)++type_adapters;else ++adapters;}
 if(fn==(void*)l2_path_root_resolve)++roots;
 if(fn==(void*)l2_path_walk_steps_from)++folds;
}
void __cyg_profile_func_exit(void *fn,void *site){(void)site;if(watching&&fn==(void*)l2_colon_types_compatible)--compatibility_depth;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL RECEIVE159: %s\n",why);}}
static void begin(void){adapters=roots=folds=type_adapters=compatibility_depth=0;watching=1;}
static void owners(void){
 l2_bound_free();l2_application_free();l2_indent_free();l2_expr_sites_free();l2_graph_places_free();l2_scope_free();
 for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);
 l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;
}
int main(int argc,char **argv){
 if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();
 LmP0Text q={0},r={0};q.data="q";q.length=1;r.data="r";r.length=1;
 LmP0Text *names[]={&q},*method_names[]={NULL};void *input_rows[]={names};
 int ft[]={2},*ft_rows[]={ft},arity[]={1},dynamic[]={0},slots[]={0};LmP0Node *nodes[]={NULL};
 l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=l2_cur_mi=l2_rw_mi=0;
 l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
 l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="receive159";l2_rw_quiet=1;l2_construct_phase=-1;
 const char *expressions[]={"q","q + 1U","(q + 1U)","+(q + 1U)","0","((0))","'a'"};
 for(unsigned k=0;k<sizeof expressions/sizeof expressions[0];++k){
  char source[256];snprintf(source,sizeof source,"return: %s\n",expressions[k]);
  LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
  LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
  L2ValueSpan value;int count=l2_count_active(stmt->as->frame->body);
  if(l2_value_expression_prepare(stmt->as->frame->body->first_field,count,&value))abort();
  L2NumericReceive plan;begin();int status=l2_numeric_receive_prepare(&value,2,0,l2_src,&plan);watching=0;
  ck(!status&&plan.value==&value&&plan.target_ft==2&&plan.converter==-1&&!adapters,"one receiving result borrows the exact owned expression without another adapter");
  ck(k<4?plan.source_ft==2:plan.source_ft==-10&&plan.literal!=NULL,"typed arithmetic and transparent literal groups keep distinct receiving contracts");
  names[0]=&r;ft[0]=0;
  begin();status=l2_check_numeric_receive_span(&value,2,0,l2_src,stmt);watching=0;
  ck(!status&&!adapters&&!roots&&!folds,"CHECK borrows closed source types after formal name+FT poison");
  char output[1024];L2Tx dest={0};if(l2_tx_open(&dest,output,sizeof output))abort();
  begin();status=l2_emit_numeric_receive(&plan,0,"",&dest);watching=0;
  ck(!status&&!adapters&&!roots&&!folds,"native projects the same receiving result without source reconstruction or rebinding");
  l2_rw_t=0;l2_rw_emit=0;l2_rw_machine=0;int out=-1;
  begin();status=l2_rw_numeric_receive(&plan,-2,&out);watching=0;int total=l2_rw_t,machine=l2_rw_machine;
  printf("RECEIVE159 form=%s COUNT status=%d source-adapters=%d primitive-type-adapters=%d roots=%d folds=%d\n",expressions[k],status,adapters,type_adapters,roots,folds);
  ck(!status&&!adapters&&!roots&&!folds,"retained COUNT projects the same source contract without receiving reparse");
  l2_rw_t=0;l2_rw_emit=1;l2_rw_machine=0;
  begin();status=l2_rw_numeric_receive(&plan,-2,&out);watching=0;
  printf("RECEIVE159 form=%s EMIT status=%d source-adapters=%d primitive-type-adapters=%d roots=%d folds=%d\n",expressions[k],status,adapters,type_adapters,roots,folds);
  ck(!status&&l2_rw_t==total&&l2_rw_machine==machine&&!adapters&&!roots&&!folds,"retained EMIT keeps COUNT topology and the same closed contract");
  l2_rw_emit=0;names[0]=&q;ft[0]=2;
  printf("RECEIVE159 form=%s source-ft=%d literal=%d source-adapters=%d primitive-type-adapters=%d projections complete\n",expressions[k],plan.source_ft,plan.literal!=NULL,adapters,type_adapters);
  l2_value_span_release(&value);owners();lm_p0_document_destroy(doc);
 }
 {
  const char *source="return: q + 1U\n";LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
  LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
  L2ValueSpan value;int phase=l2_value_expression_prepare(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&value);if(phase){fprintf(stderr,"UNEXPECTED RECEIVE159 fault-constructor status=%d alloc=%d\n",phase,l2_alloc_err);return 3;}
  L2NumericReceive plan;phase=l2_numeric_receive_prepare(&value,2,0,l2_src,&plan);if(phase){fprintf(stderr,"UNEXPECTED RECEIVE159 prime status=%d alloc=%d source-ft=%d kind=%d\n",phase,l2_alloc_err,plan.source_ft,plan.kind);return 3;}
  size_t live=l2_alloc_live,before=l2_alloc_n;phase=l2_numeric_receive_prepare(&value,2,0,l2_src,&plan);if(phase){fprintf(stderr,"UNEXPECTED RECEIVE159 repeated status=%d alloc=%d source-ft=%d kind=%d\n",phase,l2_alloc_err,plan.source_ft,plan.kind);return 3;}size_t sites=l2_alloc_n-before;
  ck(sites==0&&l2_alloc_live==live,"closed identity reception is a literal projection,not another type-word compatibility allocation");
  L2ValueSpan copy;before=l2_alloc_n;if(l2_value_expression_prepare(value.first,value.count,&copy))abort();sites=l2_alloc_n-before;l2_value_span_release(&copy);
  ck(sites>0&&sites<=(size_t)INT_MAX&&l2_alloc_live==live,"measure the actual raw-entry constructor allocations with balanced owners");
  for(size_t point=1;point<=sites;++point){
   l2_fail_left=(int)point;l2_alloc_err=0;begin();int status=l2_value_expression_prepare(value.first,value.count,&copy);watching=0;
   ck(status!=0&&l2_alloc_err&&l2_fail_left==0&&!roots&&!folds,"every raw receiving constructor allocation failure is final,not a semantic retry");
   l2_value_span_release(&copy);
   ck(l2_alloc_live==live,"partial receiving compatibility releases every actual allocation");l2_fail_left=l2_alloc_err=0;
  }
  printf("RECEIVE159 raw constructor allocation sites=%zu;identity receiving sites=0\n",sites);l2_value_span_release(&value);owners();lm_p0_document_destroy(doc);
 }
 {
  /* Raw C is an explicit machine contract,not an unknown L2 expression.
     General primary/body preparation is still open: do not claim that
     these primary consumers are zero-adapter projections. */
  const char *forms[]={"c.abs(3)","(c.abs(3))","c.abs(3) + 1","((c.abs(3) + 1))","-(c.abs(3))","+(c.abs(3))"};
  for(unsigned k=0;k<sizeof forms/sizeof forms[0];++k){
   char source[256];snprintf(source,sizeof source,"return: %s\n",forms[k]);
   LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
   LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
   L2ValueSpan value;if(l2_value_expression_prepare(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&value))abort();
   int exact=-1,kind=l2_value_span_type(&value,0,&exact);L2NumericReceive plan;
   ck(kind==-99&&exact==-12,"common single/group/composite typing preserves an explicit opaque machine contract");
   ck(!l2_numeric_receive_prepare(&value,2,0,l2_src,&plan)&&plan.source_ft==-12&&plan.converter==-1&&plan.literal==NULL,"numeric receiving projects opaque C without rediscovering its source head");
   l2_value_span_release(&value);owners();lm_p0_document_destroy(doc);
  }
  const char *source="return: missing + 1\n";LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
  LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
  L2ValueSpan value;if(l2_value_expression_prepare(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&value))abort();
  L2NumericReceive plan;ck(l2_numeric_receive_prepare(&value,2,0,l2_src,&plan)!=0&&plan.source_ft!=-12,"an unresolved language value never becomes an opaque machine result");
  l2_value_span_release(&value);owners();lm_p0_document_destroy(doc);
 }
 fclose(l2_out);l2_out=NULL;printf("RECEIVE159: %d checks, %d failures\n",checks,failures);return failures!=0;
}
