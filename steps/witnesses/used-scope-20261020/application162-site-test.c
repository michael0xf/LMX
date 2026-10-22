#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main site162_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
#define abort() do{fprintf(stderr,"SITE162 PRECONDITION %d\n",__LINE__);exit(96);}while(0)
static int checks,failures,watching,adapters,fields,roots,folds;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){(void)site;if(!watching)return;if(fn==(void*)l2_path_steps_operand)++adapters;if(fn==(void*)l2_value_fields)++fields;if(fn==(void*)l2_path_root_resolve)++roots;if(fn==(void*)l2_path_walk_steps_from)++folds;}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;}
static void begin(void){adapters=fields=roots=folds=0;watching=1;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL SITE162: %s\n",why);}}
static void owners(void){l2_bound_free();l2_application_free();l2_indent_free();l2_expr_sites_free();l2_graph_places_free();l2_scope_free();for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;l2_foreign_free();l2_xfree(l2_lmx_name_cache);l2_lmx_name_cache=NULL;l2_xfree(l2_void_name_cache);l2_void_name_cache=NULL;l2_xfree(l2_sender_name_cache);l2_sender_name_cache=NULL;l2_xfree(l2_payload_name_cache);l2_payload_name_cache=NULL;}
static L2ValueSpan *values(const char *source,LmP0Document **doc,int *n){if(lm_p0_parse_bytes(source,strlen(source),doc)||!*doc)abort();LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(*doc)->as->structure->first_field)->value;return l2_value_fields(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),n);}
int main(int argc,char **argv){
 if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();
 LmP0Text p={"p",1},q={"q",1},a={"a",1},b={"b",1},deliver={"deliver",7};LmP0Text *names[]={&p,&q},*formal[]={&a,&b},*method_names[]={NULL,&deliver};void *input_rows[]={names,formal};int ft0[]={11,11},ft1[]={0,0},*ft_rows[]={ft0,ft1},arity[]={2,2},dynamic[]={0,0},slots[]={0,0},returns[]={0,0};LmP0Node *nodes[]={NULL,NULL};
 l2_m_n=l2_m_cap=l2_slot_cap=2;l2_e=l2_cur_mi=l2_rw_mi=0;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;l2_m_ret=returns;l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="site162";l2_rw_quiet=1;l2_construct_phase=-1;
 {
  size_t baseline=l2_alloc_live;LmP0Document *doc=NULL;int n=0;L2ValueSpan *outer=values("return: deliver(a: p[q[0]]; b: q[0] + 1)\n",&doc,&n);if(!outer||n!=1)abort();L2ApplicationSite *site=NULL,*other=NULL,*hit=NULL;
  begin();int status=l2_application_site_get(outer->node,0,outer,l2_src,&site);watching=0;
  ck(!status&&site&&site->method==0&&!site->bound&&site->signature==-1&&!adapters&&!fields&&!roots&&!folds,"persistent site copies existing grammar before head role,without parser or type binding");
  ck(site->value.primary&&site->value.primary!=outer->primary&&site->value.primary->body!=outer->primary->body,"site owns independent stable primary children,not replaceable descendant pointers");
  size_t before=l2_alloc_n;begin();status=l2_application_site_get(outer->node,0,NULL,l2_src,&hit);watching=0;
  ck(!status&&hit==site&&l2_alloc_n==before&&!adapters&&!fields&&!roots&&!folds,"same source/method site is reused without construction or allocation");
  begin();status=l2_application_site_get(outer->node,1,outer,l2_src,&other);watching=0;
  ck(!status&&other&&other!=site&&other->source==site->source&&other->value.primary->body!=site->value.primary->body&&!adapters&&!fields,"same source in another method namespace owns a distinct semantic preparation");
  begin();status=l2_application_site_bind(site,1,-1,l2_src);watching=0;
  ck(!status&&site->bound&&site->arguments.count==2&&!adapters&&!fields&&!roots&&!folds,"one site retains the common formal projection rather than synthetic P0 actual fields");
  before=l2_alloc_n;begin();status=l2_application_site_bind(site,1,-1,l2_src);watching=0;
  ck(!status&&l2_alloc_n==before&&!adapters&&!fields,"repeated binding keeps the same prepared application result");
  l2_value_spans_release(outer,n);L2ValueSpan *v=&site->arguments.actuals[0].value;int exact=-1;begin();int kind=l2_value_span_type(v,0,&exact);watching=0;
  ck(kind==0&&exact==0&&!adapters&&!fields,"site arguments survive original expression-owner release and use their held grammar");
  ck(other->value.primary->body[0].primary->body->prepared->value_status==0,"another namespace's grammar stays semantically fresh");
  owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==baseline&&!l2_application_sites&&!l2_application_site_index&&!l2_application_site_capacity&&!l2_application_site_count,"site arguments,grammar and dynamic index release at compilation close");
 }
 {
  size_t baseline=l2_alloc_live;LmP0Document *doc=NULL;int n=0;L2ValueSpan *outer=values("return: p[deliver(a: q[0]; b: p[0])]\n",&doc,&n);if(!outer||n!=1||!outer->prepared)abort();L2Path *parent=outer->prepared;L2ValueSpan *child=parent->steps[0].index.values;L2ApplicationSite *site=NULL;
  if(!child||!child->primary||l2_application_site_get(child->node,0,child,l2_src,&site))abort();LmP0Node *source=child->node;L2Path replacement;begin();int status=l2_path_prepared_view(parent,&replacement);watching=0;int owned=parent->owned;parent->owned=0;l2_path_release(parent);memcpy(parent,&replacement,sizeof replacement);parent->owned=owned;
  ck(!status&&!adapters&&!fields&&site->source==source&&site->value.primary&&site->value.primary->body,"site remains independently owned after ordinary parent INDEX-view replacement");
  l2_value_spans_release(outer,n);begin();status=l2_application_site_bind(site,1,-1,l2_src);watching=0;
  ck(!status&&site->bound&&site->arguments.count==2&&!adapters&&!fields,"detached child call binds from stable grammar after containing path release");
  owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==baseline,"replaced parent and independent child site release without dangling child owners");
 }
 {
  LmP0Document *doc=NULL;int n=0;L2ValueSpan *outer=values("return: deliver(a: p[q[0]]; b: q[0])\n",&doc,&n);if(!outer||n!=1)abort();L2ApplicationSite *site=NULL;size_t live=l2_alloc_live,before=l2_alloc_n;
  if(l2_application_site_get(outer->node,0,outer,l2_src,&site))abort();size_t sites=l2_alloc_n-before;l2_application_sites_free();ck(sites>0&&sites<=(size_t)INT_MAX&&(size_t)l2_alloc_live==live,"measure complete site/copy/index construction allocation sites");
  for(size_t point=1;point<=sites;++point){l2_fail_left=(int)point;l2_alloc_err=0;begin();int status=l2_application_site_get(outer->node,0,outer,l2_src,&site);watching=0;ck(status&&l2_alloc_err&&l2_fail_left==0&&!site&&!l2_application_sites&&!l2_application_site_count&&!adapters&&!fields&&!roots&&!folds,"every site construction allocation refusal is final and publishes no partial site");ck((size_t)l2_alloc_live==live,"failed site construction releases all partial owners without touching original grammar");l2_fail_left=l2_alloc_err=0;}
  printf("SITE162 construction-allocation-sites=%zu\n",sites);l2_value_spans_release(outer,n);owners();lm_p0_document_destroy(doc);
 }
 {
  enum{width=129};char source[8192],word[32];strcpy(source,"return: deliver(");for(int i=0;i<width;++i){snprintf(word,sizeof word,"data%d: q[0]",i);strcat(source,word);strcat(source,i+1<width?"; ":")\n");}LmP0Document *doc=NULL;int n=0;size_t baseline=l2_alloc_live;L2ValueSpan *outer=values(source,&doc,&n);if(!outer||n!=1||outer->primary->body_n!=width)abort();L2ApplicationSite *kept[width];
  for(int i=0;i<width;++i){L2ValueSpan *v=outer->primary->body+i;begin();int status=l2_application_site_get(v->node,0,v,l2_src,kept+i);watching=0;ck(!status&&kept[i]&&!kept[i]->bound&&kept[i]->signature==-1&&!adapters&&!fields,"data Frame gets syntax ownership,not callable classification,through the same dynamic pool");}
  for(int i=0;i<width;++i)ck(l2_application_site_find(kept[i]->source,0)==kept[i],"all129 earlier site addresses survive dynamic-index growth");
  ck(l2_application_site_count==width&&l2_application_site_capacity>2U*width,"source-site inventory grows beyond prior small counts without a count ceiling");l2_value_spans_release(outer,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==baseline,"large source-site pool and all source owners release completely");
 }
 {
  LmP0Document *doc=NULL;int n=0;size_t baseline=l2_alloc_live;L2ValueSpan *outer=values("return: @(p[q[0]]; q[0])\n",&doc,&n);if(!outer||n!=1)abort();L2ApplicationSite *site=NULL;int count=-1;
  if(l2_application_site_get(outer->node,-1,outer,l2_src,&site))abort();size_t before=l2_alloc_n;begin();int status=l2_application_first_operand(outer->node,-1,&count);watching=0;
  ck(!status&&site&&site->method==-1&&!site->bound&&count==outer->values[0].count&&count<l2_count_active(outer->node->as->frame->body)&&l2_alloc_n==before&&!adapters&&!fields&&!roots&&!folds,"pre-namespace operand boundary borrows the same owned grammar without type binding or a repeated path measurement");
  l2_value_spans_release(outer,n);begin();status=l2_application_first_operand(site->source,-1,&count);watching=0;
  ck(!status&&count==site->value.values[0].count&&l2_alloc_n==before&&!adapters&&!fields&&!roots&&!folds,"operand boundary remains stable after original expression-owner release");
  owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==baseline,"pre-namespace grammar shares the ordinary compilation-owner lifetime");
 }
 {
  LmP0Document *doc=NULL;int n=0;size_t baseline=l2_alloc_live;L2ValueSpan *outer=values("return: deliver(a: q[0]; b: p[0])\n",&doc,&n);if(!outer||n!=1)abort();L2ValueSpan *written=outer->primary->body;int width=outer->primary->body_n;L2ApplicationActuals positional={0};size_t live=l2_alloc_live;
  begin();int status=l2_value_actuals_positional(written,width,&positional);watching=0;
  ck(!status&&width==2&&positional.count==width&&positional.written_count==width&&!adapters&&!fields&&!roots&&!folds,"already selected positional vector is projected without another named binding or parser");
  for(int i=0;i<width;++i)ck(positional.actuals[i].written==written+i&&!positional.actuals[i].wrapper&&positional.actuals[i].rank==i&&positional.actuals[i].value.node==written[i].node&&positional.actuals[i].value.primary==written[i].primary,"selected Frame remains the whole value even when its head spells a formal name");
  l2_value_actuals_release(&positional);ck((size_t)l2_alloc_live==live,"positional projection releases only its metadata,not the selected values");
  l2_fail_left=1;l2_alloc_err=0;begin();status=l2_value_actuals_positional(written,width,&positional);watching=0;
  ck(status&&l2_alloc_err&&l2_fail_left==0&&!positional.actuals&&!positional.count&&!adapters&&!fields&&!roots&&!folds&&(size_t)l2_alloc_live==live,"positional allocation refusal is transactional and never retries a source binder");l2_fail_left=l2_alloc_err=0;
  l2_value_spans_release(outer,n);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==baseline,"selected positional source lifetime balances");
 }
 fclose(l2_out);l2_out=NULL;printf("SITE162: %d checks, %d failures\n",checks,failures);return failures!=0;
}
