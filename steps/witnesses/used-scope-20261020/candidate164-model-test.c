#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main model164_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
#define abort() do { fprintf(stderr,"MODEL164 PRECONDITION %d\n",__LINE__);exit(96); } while(0)
static int checks,failures,watching,adapters,roots,folds,bindings,sources;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *at){
 (void)at;if(!watching)return;
 if(fn==(void*)l2_path_steps_operand||fn==(void*)l2_value_fields)++adapters;
 if(fn==(void*)l2_path_root_resolve)++roots;
 if(fn==(void*)l2_path_walk_steps_from)++folds;
 if(fn==(void*)l2_actual_ns||fn==(void*)l2_resolved_own||fn==(void*)l2_bound_nsty||fn==(void*)l2_graph_nsty||fn==(void*)l2_ns_find_payload||fn==(void*)l2_call_head_method)++bindings;
 if(fn==(void*)l2_reference_source_value||fn==(void*)l2_reference_source)++sources;
}
void __cyg_profile_func_exit(void *fn,void *at){(void)fn;(void)at;}
static void ck(int okay,const char *why){++checks;if(!okay){++failures;fprintf(stderr,"FAIL MODEL164: %s\n",why);}}
static void begin(void){adapters=roots=folds=bindings=sources=0;watching=1;}
static void owners(void){l2_bound_free();l2_application_free();l2_indent_free();for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;l2_foreign_free();l2_xfree(l2_lmx_name_cache);l2_lmx_name_cache=NULL;l2_xfree(l2_void_name_cache);l2_void_name_cache=NULL;}
static L2ValueSpan *values(const char *text,LmP0Document **doc,int *n){if(lm_p0_parse_bytes(text,strlen(text),doc)||!*doc)abort();LmP0Node *node=l2_next_active(lm_p0_document_mutable_root(*doc)->as->structure->first_field)->value;return l2_value_fields(node->as->frame->body->first_field,l2_count_active(node->as->frame->body),n);}
static void selected(L2ValueSpan *v,int model){L2Path *p=v->prepared;if(!p)abort();p->ni=model;p->oi=p->root_own=-1;p->fi=3;p->root_ft=p->leaf_ty=l2_graph_code();p->leaf_kind=13;p->leaf_model=model;p->value_status=1;p->value_method=0;p->value_revision=l2_value_revision;}
int main(void){
 int arity[]={0,0},dynamic[]={0,0},slots[]={0,0},nsty_mi[]={0,1},nsty_k[]={-1,-1},models[]={3,4},returns[]={0,0};returns[0]=returns[1]=l2_graph_code();
 int model_local[8],model_parent[8];for(int i=0;i<8;++i)model_local[i]=model_parent[i]=-1;
 LmP0Node *method_nodes[]={NULL,NULL},*model_nodes[8]={0};LmP0Text *method_names[]={NULL,NULL},need={"Need",4},*model_names[8]={0};model_names[2]=&need;
 l2_m_n=2;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_sn=slots;l2_m_name=method_names;l2_m_node=l2_m_body=method_nodes;l2_m_ret=returns;
 l2_nsty_n=2;l2_nsty_mi=nsty_mi;l2_nsty_k=nsty_k;l2_nsty_ni=models;l2_ns_n=8;l2_ns_name=model_names;l2_ns_local=model_local;l2_ns_parent=model_parent;l2_ns_at=model_nodes;l2_e=1;l2_cur_mi=0;l2_here_mi=-1;l2_src="model164";l2_construct_phase=-1;
 const int depths[]={0,1,4,16,65,129};
 for(unsigned k=0;k<sizeof depths/sizeof depths[0];++k){
  char text[4096];strcpy(text,"return: p");for(int i=0;i<depths[k];++i)strcat(text,i%2?"\\child":"[0]");strcat(text,"\n");
  LmP0Document *doc=NULL;int n=0,model=-9;size_t live=l2_alloc_live;L2ValueSpan *v=values(text,&doc,&n);if(!v||n!=1)abort();selected(v,5);v->prepared->source_value.result.schema=7;
  int exact=-9;begin();int status=l2_value_model(v,0,l2_src,v->node,&model,&exact);watching=0;
  ck(!status&&model==5&&exact==l2_graph_code()&&!adapters&&!roots&&!folds&&!bindings&&!sources,"whole roots and arbitrary mixed paths project the SAME Model and exact type,not another name or physical-source query");
  L2ValueSpan borrow=*v;begin();status=l2_value_model(&borrow,0,l2_src,v->node,&model,NULL);watching=0;
  ck(!status&&model==5&&!adapters&&!roots&&!folds&&!bindings&&!sources,"a borrowed formal-order actual projects the same prepared contract");
  if(!depths[k]){
   v->prepared->array_leaf=1;model=-9;begin();status=l2_value_model(v,0,l2_src,v->node,&model,NULL);watching=0;
   ck(status==2&&model==-1&&!adapters&&!bindings,"a whole Array is not silently classified as its element Model");v->prepared->array_leaf=0;
   v->prepared->leaf_model=-1;v->prepared->res=3;begin();status=l2_value_model(v,0,l2_src,v->node,&model,NULL);watching=0;
   ck(!status&&model==l2_schema_merge(3)&&!adapters&&!bindings&&!sources,"an already selected composed root keeps its existing schema handle without an alias walk");v->prepared->res=-1;
  }
  l2_path_fail(v->prepared,0,1);model=exact=-9;begin();status=l2_value_model(v,0,l2_src,v->node,&model,&exact);watching=0;
  ck(status==1&&model==-1&&exact==-1&&!adapters&&!roots&&!folds&&!bindings&&!sources,"a refused held path drops both old contracts and cannot retry capture/name binding");
  l2_value_spans_release(v,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"candidate projection adds no AST or source-owner lifetime");
 }
 {
  LmP0Document *doc=NULL;int n=0,model;size_t live=l2_alloc_live;L2ValueSpan *v=values("return: ((p))\n",&doc,&n);if(!v||n!=1)abort();L2ValueSpan *child=v;while(child->values&&child->value_n==1)child=child->values;selected(child,5);
  begin();int status=l2_value_model(v,0,l2_src,v->node,&model,NULL);watching=0;
  ck(!status&&model==5&&!adapters&&!roots&&!folds&&!bindings&&!sources,"transparent groups project the same child contract without another operand adapter");
  l2_value_spans_release(v,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"grouped candidate ownership balances");
 }
 {
  LmP0Document *doc=NULL;int n=0,model;size_t live=l2_alloc_live;L2ValueSpan *original=values("return: give(1)\n",&doc,&n);if(!original||n!=1)abort();L2ApplicationSite *site=NULL;if(l2_application_site_get(original->node,0,original,l2_src,&site))abort();l2_value_spans_release(original,n);site->bound=1;site->signature=0;site->held=-1;
  int exact=-9;begin();int status=l2_value_model(&site->value,0,l2_src,site->source,&model,&exact);watching=0;
  ck(!status&&model==3&&exact==returns[0]&&!adapters&&!roots&&!folds&&!bindings&&!sources,"a call candidate projects its signature's Model AND exact type after the original grammar owner is released");
  site->signature=1;begin();status=l2_value_model(&site->value,0,l2_src,site->source,&model,NULL);watching=0;
  ck(!status&&model==4&&!adapters&&!bindings,"changing the bound callable changes its declared result Model without a head lookup");
  site->bound=0;begin();status=l2_value_model(&site->value,0,l2_src,site->source,&model,&exact);watching=0;
  ck(status==2&&model==-1&&exact==-1&&!adapters&&!bindings&&!sources,"an unclassified data Frame cannot borrow a former callable result/type or retry its written name");
  owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"classified application ownership balances");
 }
 const char *casts[]={"return: cast: (@: void) p\n","return: cast: (@: Need) p\n","return: cast: (@@: Need) p\n"};
 for(int k=0;k<3;++k){
  LmP0Document *doc=NULL;int n=0,model;size_t live=l2_alloc_live;L2ValueSpan *v=values(casts[k],&doc,&n);if(!v||n!=1||!v->primary||v->primary->body_n!=2)abort();selected(v->primary->body+1,5);
  int exact=-9;begin();int status=l2_value_model(v,0,l2_src,v->node,&model,&exact);watching=0;
  ck((k==1?(!status&&model==2):(status==2&&model==-1))&&l2_pointer_depth(exact)==(k==2?2:1),"a cast's Model and exact pointer depth come from its declared target,never its physical operand's Model");
  ck(!adapters&&!roots&&!folds&&!bindings&&!sources,"cast typing does not reparse or resolve its prepared operand");
  if(k==0){L2ReferenceSource source;if(l2_reference_source_value(v,0,&source))abort();ck(source.schema==5,"the same opaque cast still retains its actual physical-source provenance independently");}
  l2_value_spans_release(v,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"cast type/source owners release completely");
 }
 {
  LmP0Document *doc=NULL;int n=0,model;size_t live=l2_alloc_live;L2ValueSpan *v=values("return: p\n",&doc,&n);if(!v||n!=1)abort();L2ValueSpan raw;l2_value_span_ref(&raw,v->first,v->count);
  begin();int status=l2_value_model(&raw,0,l2_src,raw.node,&model,NULL);watching=0;
  ck(status==2&&model==-1&&!adapters&&!roots&&!folds&&!bindings&&!sources,"a missing grammar owner is not permission for a consumer-side raw fallback");
  l2_alloc_err=1;begin();status=l2_value_model(v,0,l2_src,v->node,&model,NULL);watching=0;
  ck(status==1&&model==-1&&!adapters&&!roots&&!folds&&!bindings&&!sources,"allocation failure stays fatal rather than becoming an unknown candidate or a parser retry");l2_alloc_err=0;
  l2_value_spans_release(v,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"unknown candidate releases normally");
 }
 l2_nsty_n=0;l2_nsty_mi=l2_nsty_k=l2_nsty_ni=NULL;
 printf("MODEL164: %d checks, %d failures\n",checks,failures);return failures!=0;
}
