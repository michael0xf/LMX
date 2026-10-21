#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main root136_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static const char *capture_path;
static void ck136(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL retained root: %s\n",why);}}
static void capture(void){if(l2_out)fclose(l2_out);l2_out=fopen(capture_path,"w+b");if(!l2_out){perror("explicit fixture capture");abort();}}
static void captured(char *out,size_t cap){fflush(l2_out);long n=ftell(l2_out);if(n<0||(size_t)n>=cap)abort();rewind(l2_out);if(fread(out,1,(size_t)n,l2_out)!=(size_t)n)abort();out[n]=0;}
int main(int argc,char **argv){
 if(argc!=2)abort();capture_path=argv[1];
 LmP0Text p={0},q={0},word={0};p.data="p";p.length=1;q.data="q";q.length=1;word.data="void";word.length=4;
 LmP0Text *names[]={&p},*slot_names[]={&p},*machine_names[]={&p},*method_names[]={NULL};
 void *input_rows[]={names};int ft[]={18},*ft_rows[]={ft},arity[]={1},dynamic[]={0},slots[]={0};
 int slot_type[]={18},machine_type[]={18},machine_model[]={-1},machine_rw[]={7};
 LmP0Node *nodes[]={NULL};
 l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=0;l2_cur_mi=l2_rw_mi=0;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;
 l2_m_sn=slots;l2_sn=slot_names;l2_st=slot_type;l2_m_name=method_names;l2_m_node=l2_m_body=nodes;
 l2_ml_nm=machine_names;l2_ml_ty=machine_type;l2_ml_ns=machine_model;l2_ml_rw=machine_rw;
 l2_src="retained-root-test";l2_rw_quiet=1;l2_construct_phase=-1;
 for(int binding=0;binding<3;++binding)for(int rank=1;rank<=2;++rank){
  names[0]=slot_names[0]=machine_names[0]=&p;
  arity[0]=binding==0?1:0;slots[0]=binding==1?1:0;l2_ml_n=binding==2?1:0;
  int ty=rank==1?18:l2_foreign_intern_parts(&word,3,0,0);
  ft[0]=slot_type[0]=machine_type[0]=ty;l2_diag_n=0;l2_rw_quiet_msg=NULL;
  const char *source=rank==1?"p[0]: 0\n":"p[0][0]: 0\n";LmP0Document *document=NULL;
  int parse=lm_p0_parse_bytes(source,strlen(source),&document);
  ck136(!parse&&document,"original head parses");if(parse||!document)abort();
  LmP0Node *root=lm_p0_document_mutable_root(document);LmP0Field *field=l2_next_active(root->as->structure->first_field);
  LmP0Node *stmt=field->value;L2Address place;int status=l2_raw_index_location(stmt,0,&place);
  ck136(!status,"common raw view resolves original declared binding");if(status)abort();
  ck136((binding==0&&place.path.fi==0&&place.path.oi==-1)||(binding==1&&place.path.root_kind==5&&place.path.root==0)||(binding==2&&place.path.root_kind==4&&place.path.root==0),"selected root coordinate is retained for formal/slot/machine binding");
  ck136(place.source_type==ty&&place.index==16,"all consumed types come from the selected root");
  int head_status;L2HeadExpression *e=l2_head_expression(stmt,&head_status);
  ck136(e&&place.path.n==rank&&place.path.indexed==rank&&e->prepared.fi==-1,"typed view and cached unresolved grammar are separate owners");
  /* Poison lookup spelling after resolution. This is a translator consumer
     test,not a claim that a changed runtime program must use an old ancestor. */
  names[0]=slot_names[0]=machine_names[0]=&q;
  capture();char storage[4096],text[32768];L2Tx out;int context=-1;
  l2_tx_local(&out,storage,sizeof storage);l2_tn=0;
  status=l2_emit_raw_index_location(&place,0,"    ",&out,&context);
  ck136(!status,"native consumes the selected root without spelling fallback");
  captured(text,sizeof text);
  const char *expected=binding==0?"l2_p0_0":binding==1?"l2_s0_0":" q";
  ck136(!status&&strstr(text,expected)!=NULL,"native emits that actual input/slot/local,not the old source word");
  ck136(!status&&context>=0&&out.len>0,"native retains ready physical address and current context");
  l2_rw_emit=0;l2_rw_t=0;l2_rw_machine=0;int child=-1;
  int counted=l2_rw_machine_index(&place,stmt->as->frame->head,NULL,0,0,&child),count=l2_rw_t;
  ck136(!counted&&child>=0,"graph COUNT consumes the same selected root");
  capture();l2_rw_emit=1;l2_rw_t=0;l2_rw_machine=0;child=-1;
  int emitted=l2_rw_machine_index(&place,stmt->as->frame->head,NULL,0,0,&child);
  ck136(!emitted&&child>=0,"graph EMIT consumes the same selected root");
  ck136(!counted&&!emitted&&count>0&&l2_rw_t==count,"COUNT and EMIT retain identical constructor cardinality");
  ck136(e->prepared.n==rank&&e->prepared.indexed==rank&&e->prepared.fi==-1,"backend consumers do not overwrite cached grammar with a verdict");
  l2_address_release(&place);
  ck136(!place.resolved&&!place.path.n,"selected view releases its own step storage");
  l2_application_free();ck136(!l2_head_expressions,"cached P0 heads use the existing application lifetime");
  lm_p0_document_destroy(document);
 }
 if(l2_out)fclose(l2_out);l2_out=NULL;
 printf("retained binding roots: %d checks, %d failures\n",checks,failures);return failures!=0;
}
