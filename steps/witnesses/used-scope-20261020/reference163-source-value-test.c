#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main source163_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
#define abort() do { fprintf(stderr,"SOURCE163 PRECONDITION %d\n",__LINE__);exit(96); } while(0)
static int checks,failures,watching,parsers,roots,folds,queries;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *at){(void)at;if(!watching)return;if(fn==(void*)l2_reference_fields||fn==(void*)l2_path_steps_operand)++parsers;if(fn==(void*)l2_path_root_resolve)++roots;if(fn==(void*)l2_path_walk_steps_from)++folds;if(fn==(void*)l2_reference_value_core)++queries;}
void __cyg_profile_func_exit(void *fn,void *at){(void)fn;(void)at;}
static void ck(int good,const char *why){++checks;if(!good){++failures;fprintf(stderr,"FAIL SOURCE163: %s\n",why);}}
static void begin(void){parsers=roots=folds=queries=0;watching=1;}
static void owners(void){l2_bound_free();l2_application_free();l2_indent_free();for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;}
static L2ValueSpan *values(const char *text,LmP0Document **doc,int *n){if(lm_p0_parse_bytes(text,strlen(text),doc)||!*doc)abort();LmP0Node *node=l2_next_active(lm_p0_document_mutable_root(*doc)->as->structure->first_field)->value;return l2_value_fields(node->as->frame->body->first_field,l2_count_active(node->as->frame->body),n);}
static void selected(L2ValueSpan *v,int model){L2Path *p=v->prepared;if(!p)abort();p->ni=model;p->oi=p->root_own=-1;p->fi=3;p->root_ft=p->leaf_ty=l2_graph_code();p->leaf_kind=13;p->leaf_model=model;p->value_status=1;p->value_method=0;p->value_revision=l2_value_revision;}
int main(void){
 int arity[]={0,0},dynamic[]={0,0},slots[]={0,0};LmP0Node *method_nodes[]={NULL,NULL};LmP0Text *method_names[]={NULL,NULL};
 int nsty_mi[]={0,1},nsty_k[]={-1,-1},nsty_models[]={5,3};LmP0Text *model_names[8]={0};
 l2_m_n=2;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_sn=slots;l2_m_name=method_names;l2_m_node=l2_m_body=method_nodes;l2_e=1;l2_cur_mi=0;l2_src="source-value163";l2_construct_phase=-1;
 l2_nsty_n=2;l2_nsty_mi=nsty_mi;l2_nsty_k=nsty_k;l2_nsty_ni=nsty_models;l2_ns_n=8;l2_ns_name=model_names;
 {
  LmP0Document *doc=NULL;int n=0;size_t live=l2_alloc_live;L2ValueSpan *v=values("return: p\n",&doc,&n);if(!v||n!=1)abort();selected(v,5);L2ValueSpan borrow=*v;L2ReferenceSource a,b;
  begin();int status=l2_reference_source_value(v,0,&a);watching=0;
  ck(!status&&a.schema==5&&a.layout==-1&&a.method==0&&a.place==3,"source comes from the current selected input,not a lexical requirement");
  ck(queries==1&&!parsers&&!roots&&!folds&&v->prepared->source_value.status==1,"first source query projects the same held path without parsing or resolving it again");
  v->prepared->leaf_model=6;v->prepared->ni=6;
  begin();status=l2_reference_source_value(&borrow,0,&b);watching=0;
  ck(!status&&b.schema==5&&b.origin==a.origin&&!queries&&!parsers&&!roots&&!folds,"borrowed argument shares the original owner's completed source verdict");
  L2Path kept,fresh;if(l2_path_record_copy(v->prepared,&kept)||l2_path_prepared_view(v->prepared,&fresh))abort();
  ck(kept.source_value.status==1&&kept.source_value.result.schema==5&&fresh.source_value.status==0,"verdict copies retain the source result while fresh grammar drops semantic readiness");
  l2_path_release(&kept);l2_path_release(&fresh);
  ++l2_source_revision;begin();status=l2_reference_source_value(&borrow,0,&b);watching=0;
  ck(!status&&b.schema==6&&queries==1&&!parsers&&!roots&&!folds,"new source inventory refreshes one common source result without a syntax retry");
  char one_buf[1024],two_buf[1024];L2Tx one={0},two={0};l2_tx_open(&one,one_buf,sizeof one_buf);l2_tx_open(&two,two_buf,sizeof two_buf);
  if(l2_source_plan_value_source(&one,&v->prepared->source_value))abort();
  v->prepared->source_value.result.schema=4;if(l2_source_plan_value_source(&two,&v->prepared->source_value))abort();
  ck(strcmp(one.data,two.data)!=0,"convergence compares actual source contracts,not only the leaf type or revision number");
  L2PathFact original={0},ambiguous={0};original.method=0;original.source=v->node;original.source_use=2;l2_path_facts=&original;
  ++l2_source_revision;begin();status=l2_reference_source_value(v,0,&b);watching=0;
  ck(!status&&b.schema==6&&b.path==&original&&!parsers&&!roots&&!folds,"source provenance retains the unique original source-use identity without resolving its name again");
  ambiguous=original;original.next=&ambiguous;++l2_source_revision;
  begin();status=l2_reference_source_value(v,0,&b);watching=0;
  ck(!status&&b.schema==-1&&!b.path&&queries==1&&!parsers&&!roots&&!folds,"ambiguous original source inventory stays unknown and does not activate a fallback");
  original.next=NULL;++l2_source_revision;begin();status=l2_reference_source_value(v,0,&b);watching=0;
  ck(!status&&b.schema==6&&b.path==&original&&queries==1,"a changed source inventory refreshes the same owner rather than retaining old ambiguity");
  l2_path_facts=NULL;++l2_source_revision;
  ++l2_value_revision;v->prepared->value_revision=l2_value_revision;v->prepared->ni=7;v->prepared->leaf_model=7;
  begin();status=l2_reference_source_value(v,0,&b);watching=0;
  ck(!status&&b.schema==7&&queries==1&&!parsers&&!roots&&!folds,"a new common value plan refreshes provenance even with unchanged source membership");
  l2_path_fail(v->prepared,0,2);begin();status=l2_reference_source_value(&borrow,0,&b);watching=0;
  ck(!status&&b.schema==-1&&b.layout==-1&&b.method==-1&&b.place==-1&&!b.path,"a refused path cannot reuse a previously successful source or receiving proof");
  ck(!parsers&&!roots&&!folds,"source refusal adds no alternate parser or root/field resolver");
  l2_value_spans_release(v,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"path source memo has no separate owner or leaked AST");
 }
 {
  LmP0Document *doc=NULL;int n=0;size_t live=l2_alloc_live;L2ValueSpan *original=values("return: give(1)\n",&doc,&n);if(!original||n!=1)abort();L2ApplicationSite *site=NULL;if(l2_application_site_get(original->node,0,original,l2_src,&site))abort();L2ValueSpan *v=&site->value;site->bound=1;site->signature=0;site->held=-1;L2ReferenceSource a,b;
  l2_value_spans_release(original,n);begin();int status=l2_reference_source_value(v,0,&a);watching=0;
  ck(!status&&a.schema==5&&a.method==0&&a.place==-1&&queries==1&&!parsers&&!roots&&!folds,"call result provenance uses its already bound application/result port after original-owner release");
  L2ValueSpan borrow=*v;nsty_models[0]=4;begin();status=l2_reference_source_value(&borrow,0,&b);watching=0;
  ck(!status&&b.schema==5&&!queries,"primary borrowers share one source verdict,not copied status flags");
  site->signature=1;begin();status=l2_reference_source_value(v,0,&b);watching=0;
  ck(!status&&b.schema==3&&b.method==1&&queries==1&&!parsers&&!roots&&!folds,"changed bound signature refreshes the source port without reclassifying source text");
  site->bound=0;begin();status=l2_reference_source_value(v,0,&b);watching=0;
  ck(!status&&b.schema==-1&&b.method==-1&&queries==1,"an unclassified data Frame does not reuse its former callable result");
  begin();status=l2_reference_source_value(&borrow,0,&b);watching=0;
  ck(!status&&b.schema==-1&&!queries,"unknown source is a completed shared verdict,not permission to retry classification");
  L2PrimaryBody *kept=NULL,*fresh=NULL;if(l2_primary_clone(v->primary,1,&kept)||l2_primary_clone(v->primary,0,&fresh))abort();
  ck(kept->source_value.status==1&&kept->source_value.result.schema==-1&&!fresh->source_value.status,"primary copies preserve or reset the whole source verdict with their ordinary clone mode");
  l2_primary_release(kept);l2_primary_release(fresh);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"primary source memo and independent application owner release completely");nsty_models[0]=5;
 }
 {
  LmP0Document *doc=NULL;int n=0;size_t live=l2_alloc_live;L2ValueSpan *v=values("return: ((p))\n",&doc,&n);if(!v||n!=1)abort();L2ValueSpan *child=v;while(child->values&&child->value_n==1)child=child->values;selected(child,5);L2ReferenceSource out;begin();int status=l2_reference_source_value(v,0,&out);watching=0;
  ck(!status&&out.schema==5&&out.origin==child->node&&out.origin_count==child->count&&!parsers&&!roots&&!folds,"transparent groups keep their actual child's source construction rather than inventing a wrapper origin");
  l2_value_spans_release(v,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"grouped source ownership balances");
 }
 {
  LmP0Document *doc=NULL;int n=0;size_t live=l2_alloc_live;L2ValueSpan *v=values("return: cast: (@: void) p\n",&doc,&n);if(!v||n!=1||!v->primary||v->primary->body_n!=2)abort();selected(v->primary->body+1,5);L2ReferenceSource out;begin();int status=l2_reference_source_value(v,0,&out);watching=0;
  ck(!status&&out.schema==5&&out.method==0&&out.place==3&&out.origin==v->node&&out.origin_count==1,"a pointer cast preserves actual operand provenance but retains the containing cast's construction identity");
  ck(!parsers&&!roots&&!folds,"cast source consumes its already prepared operand,not a raw field run");
  l2_value_spans_release(v,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"cast source ownership balances");
 }
 {
  LmP0Document *doc=NULL;int n=0;size_t live=l2_alloc_live;L2ValueSpan *v=values("return: cast: (@: void) 1\n",&doc,&n);if(!v||n!=1)abort();L2ReferenceSource out;begin();int status=l2_reference_source_value(v,0,&out);watching=0;
  ck(!status&&out.schema==-1&&out.method==-1&&out.place==-1&&!parsers&&!roots&&!folds,"casting a number to a pointer invents neither descriptor provenance nor source permission");
  l2_value_spans_release(v,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"unknown cast source releases normally");
 }
 l2_nsty_n=0;l2_nsty_mi=l2_nsty_k=l2_nsty_ni=NULL;
 printf("SOURCE163 held values: %d checks, %d failures\n",checks,failures);return failures!=0;
}
