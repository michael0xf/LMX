#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main refspan164_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,adapters,roots,folds,raw;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *at){(void)at;if(!watching)return;if(fn==(void*)l2_path_steps_operand||fn==(void*)l2_value_fields)++adapters;if(fn==(void*)l2_path_root_resolve)++roots;if(fn==(void*)l2_path_walk_steps_from)++folds;if(fn==(void*)l2_rw_reference_value||fn==(void*)l2_reference_descriptor)++raw;}
void __cyg_profile_func_exit(void *fn,void *at){(void)fn;(void)at;}
static void ck(int okay,const char *why){++checks;if(!okay){++failures;fprintf(stderr,"FAIL REFSPAN164: %s\n",why);}}
static void begin(void){adapters=roots=folds=raw=0;watching=1;}
static void owners(void){l2_bound_free();l2_application_free();l2_indent_free();l2_expr_sites_free();l2_graph_places_free();l2_scope_free();for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;l2_foreign_free();l2_xfree(l2_lmx_name_cache);l2_lmx_name_cache=NULL;l2_xfree(l2_void_name_cache);l2_void_name_cache=NULL;}
int main(int argc,char **argv){
 if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();
 LmP0Text p={"p",1},q={"q",1},integer={"int",3};LmP0Text *names[]={&p},*method_names[]={NULL};void *inputs[]={names};
 int ft[]={0},*types[]={ft},arity[]={1},dynamic[]={0},slots[]={0};LmP0Node *nodes[]={NULL};
 l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=l2_cur_mi=l2_rw_mi=0;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_sn=slots;l2_m_fn=inputs;l2_m_ft=types;l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="refspan164";l2_rw_quiet=1;l2_construct_phase=-1;
 const char *forms[]={"p","(p)","((p))","0","((0))","0U"};
 for(unsigned k=0;k<sizeof forms/sizeof forms[0];++k){
  size_t live=l2_alloc_live;ft[0]=l2_foreign_intern(&integer,1,0);if(ft[0]<100)abort();int ty=l2_own_ty_of_param(ft[0]);
  char text[256];snprintf(text,sizeof text,"return: %s\n",forms[k]);LmP0Document *doc=NULL;if(lm_p0_parse_bytes(text,strlen(text),&doc)||!doc)abort();
  LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;L2ValueSpan value;
  if(l2_value_expression_prepare(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&value))abort();int exact=-1;if(l2_value_span_type(&value,0,&exact)==-99)abort();
  names[0]=&q;l2_rw_t=0;l2_rw_emit=0;l2_rw_machine=0;int out=-1;
  begin();int status=l2_rw_reference_span(&value,ty,-2,&out);watching=0;int count=l2_rw_t,machine=l2_rw_machine;
  ck(!status&&count>0&&!adapters&&!roots&&!folds&&!raw,"reference COUNT consumes the held grammar after formal-name poison,without another descriptor/root lookup");
  l2_rw_t=0;l2_rw_emit=1;l2_rw_machine=0;long first=ftell(l2_out);
  begin();status=l2_rw_reference_span(&value,ty,-2,&out);watching=0;long last=ftell(l2_out);
  ck(!status&&count==l2_rw_t&&machine==l2_rw_machine&&!adapters&&!roots&&!folds&&!raw,"reference EMIT has COUNT's topology and no legacy reference/parser route");
  if(k>=3){char type[128];if(l2_ptr_cell_type(ft[0],type))abort();if(fflush(l2_out)||fseek(l2_out,first,SEEK_SET))abort();char *emission=malloc((size_t)(last-first)+1);if(!emission||fread(emission,1,(size_t)(last-first),l2_out)!=(size_t)(last-first))abort();emission[last-first]=0;
   ck(strstr(emission,"lmx_pointer_new_profiled(")&&strstr(emission,type),"a received zero remains a pointer cell of the declared type,not an int cell");free(emission);if(fseek(l2_out,0,SEEK_END))abort();
  }
  names[0]=&p;l2_rw_emit=0;l2_value_span_release(&value);owners();lm_p0_document_destroy(doc);ck((size_t)l2_alloc_live==live,"reference preparation,projection and ABI type owners release completely");
 }
 fclose(l2_out);l2_out=NULL;printf("REFSPAN164: %d checks, %d failures\n",checks,failures);return failures!=0;
}
