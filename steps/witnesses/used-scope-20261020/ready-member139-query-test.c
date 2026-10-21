#ifndef L2_FRONTEND_SOURCE
#error Need exact instrumented frontend source
#endif
#define main member139_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
int main(int argc,char **argv){
 if(argc!=2)return 2;
 LmP0Text p={0},type={0};p.data="p";p.length=1;type.data="Member139Table";type.length=strlen(type.data);
 LmP0Text *names[]={&p},*methods[]={NULL};void *rows[]={names};
 int arity[]={1},dyn[]={0},sn[]={0},ret[]={0},ft[]={0},*fts[]={ft};LmP0Node *nodes[]={NULL};
 l2_m_n=l2_m_cap=1;l2_cur_mi=l2_rw_mi=l2_e=0;l2_m_name=methods;l2_m_arity=arity;l2_m_dyn=dyn;l2_m_sn=sn;
 l2_m_fn=rows;l2_m_ft=fts;l2_m_node=l2_m_body=nodes;l2_m_ret=ret;l2_src="member139-query-fixture";l2_construct_phase=-1;l2_work_mi=-1;
 ft[0]=l2_foreign_intern_parts(&type,1,0,1);if(ft[0]<100)return 2;
 l2_out=fopen(argv[1],"w+b");if(!l2_out)return 2;
 LmP0Document *doc=NULL;char storage[4096];L2Tx dest;l2_tx_local(&dest,storage,sizeof storage);
 if(lm_p0_parse_bytes("p\n",2,&doc)||!doc)return 2;
 LmP0Node *root=lm_p0_document_mutable_root(doc),*atom=l2_next_active(root->as->structure->first_field)->value;
 atom->as->atom->data="p\\field";atom->as->atom->length=7;
 member139_root_queries=0;int rc=l2_prep_context(atom,0,"    ",&dest,NULL);
 printf("ATOM status=%d root_queries=%d value=%s\n",rc,member139_root_queries,dest.data);
 if(rc||!strstr(dest.data,"l2_p0_0")||!strstr(dest.data,"field"))return 1;
 lm_p0_document_destroy(doc);doc=NULL;l2_tx_clear(&dest);
 const char *source="p\\tick(5)\n";
 if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)return 2;
 root=lm_p0_document_mutable_root(doc);LmP0Node *call=l2_next_active(root->as->structure->first_field)->value;
 member139_root_queries=0;rc=l2_prep_context(call,0,"    ",&dest,NULL);
 printf("CALL status=%d root_queries=%d value=%s\n",rc,member139_root_queries,dest.data);
 if(rc||!strstr(dest.data,"l2_p0_0")||!strstr(dest.data,"tick")||!strstr(dest.data,"5"))return 1;
 l2_application_free();lm_p0_document_destroy(doc);fclose(l2_out);l2_out=NULL;return 0;
}
