#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main address148_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
#define abort() do { fprintf(stderr,"address148 fixture abort line %d\n",__LINE__);exit(3); } while(0)
static int checks,failures,watching,legacy,adapters,roots,folds,total_legacy,total_adapters,stack_n;
static void *stack[4096];
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
    (void)site;if(!watching)return;
    void *caller=stack_n?stack[stack_n-1]:NULL;
#ifndef PATHS149_CURRENT
    if(fn==(void*)l2_indexed_node){++total_legacy;if(caller!=(void*)l2_indexed_operand)++legacy;}
#endif
    if(fn==(void*)l2_path_steps_run){++total_adapters;if(caller==(void*)l2_path_resolve_run)++adapters;}
    if(fn==(void*)l2_path_root_resolve)++roots;
    if(fn==(void*)l2_path_walk_steps_from)++folds;
    if(stack_n==4096)exit(4);stack[stack_n++]=fn;
}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;if(watching&&stack_n)--stack_n;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL address148: %s\n",why);}}
int main(int argc,char **argv){
    LmP0Text p={0},word={0};p.data="p";p.length=1;word.data="int";word.length=3;
    LmP0Text *names[]={&p},*method_names[]={NULL};void *input_rows[]={names};
    int ft[]={18},*ft_rows[]={ft},arity[]={1},dynamic[]={0},slots[]={0};
    LmP0Node *nodes[]={NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="address148";l2_rw_quiet=1;l2_construct_phase=-1;
    if(argc!=2)abort();l2_out=fopen(argv[1],"w");if(!l2_out)abort();
    const int ranks[]={1,2,6,65,129};
    for(int ri=0;ri<5;++ri)for(int qualified=0;qualified<2;++qualified){
        int rank=ranks[ri];char source[2048];strcpy(source,"@: p");for(int i=0;i<rank;++i)strcat(source,"[0]");strcat(source,"\n");
        ft[0]=l2_foreign_intern_parts(&word,rank,qualified,0);
        LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *node=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        if(!l2_frame_head(node,"@"))abort();
        for(int consumer=0;consumer<4;++consumer){
            int result=-999,ty=-999,context=-99;char buffer[1024];L2Tx tx;
            if(!l2_tx_local(&tx,buffer,sizeof buffer))abort();
            legacy=adapters=roots=folds=total_legacy=total_adapters=stack_n=0;watching=1;
            if(consumer==0)result=l2_colon_simple_ty(node,0,&ty);
            if(consumer==1)result=l2_native_leaf_ty(node,0);
            if(consumer==2)result=l2_check_addr(node,0,l2_src);
            if(consumer==3)result=l2_prep_context(node,0,"    ",&tx,&context);
            watching=0;
            fprintf(stderr,"observed rank=%d const=%d consumer=%d verdict=%d type=%d direct_legacy=%d common_adapters=%d roots=%d folds=%d total_legacy=%d total_adapters=%d\n",rank,qualified,consumer,result,ty,legacy,adapters,roots,folds,total_legacy,total_adapters);
            ck(consumer==1?result==-99:result==0,"consumer's actual existing verdict");
            if(consumer==0){LmP0Text actual;int depth=-1,is_const=-1;
                ck(l2_type_parts(l2_formal_raw(ty),&actual,&depth,&is_const)==0&&l2_text_eq(&actual,"int")&&depth==1&&is_const==qualified,"exact declared qualified address type");}
            ck(legacy==0,"no direct node-client entry into legacy adapter; nested field-span debt separately observed");
            ck(adapters==1,"one actual common complete-path adapter entry");
            ck(roots==1,"one actual selected root");
            ck(folds==1,"one actual common semantic step fold");
        }
        lm_p0_document_destroy(doc);
    }
#ifdef ADDRESS148_CURRENT
    LmP0Document *doc=NULL;const char *mixed="return: p[0]\\x[0]\\y\n";
    if(lm_p0_parse_bytes(mixed,strlen(mixed),&doc)||!doc)abort();
    LmP0Node *ret=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
    LmP0Structure *body=ret->as->frame->body;L2Path path;
    if(l2_path_steps_run(body->first_field,l2_count_active(body),&path))abort();
    ck(path.n==4&&path.indexed==2&&path.names==0,"actual mixed grammar counters: names is first-index prefix");
    ck(l2_check_resolved_indices(ret,0,l2_src,&path)==0,"fields after indices retain valid complete geometry");
    path.names=1;ck(l2_check_resolved_indices(ret,0,l2_src,&path)==1,"wrong prefix count is detected");path.names=0;
    path.indexed=1;ck(l2_check_resolved_indices(ret,0,l2_src,&path)==1,"wrong index count is detected");path.indexed=2;
    int cap=path.cap;path.cap=path.n-1;ck(l2_check_resolved_indices(ret,0,l2_src,&path)==1,"capacity inconsistency is detected");path.cap=cap;
    ck(l2_check_resolved_indices(ret,0,l2_src,&path)==0,"restored whole record remains valid");
    l2_path_release(&path);lm_p0_document_destroy(doc);
#endif
    fclose(l2_out);l2_out=NULL;
    printf("address148 complete-node consumers: %d checks, %d failures\n",checks,failures);return failures!=0;
}
