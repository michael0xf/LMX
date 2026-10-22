#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main heads150_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,parses,adapters,texts,roots,folds;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
    (void)site;if(!watching)return;
    if(fn==(void*)lm_p0_parse_bytes)++parses;
    if(fn==(void*)l2_path_steps_operand)++adapters;
    if(fn==(void*)l2_path_steps_text)++texts;
    if(fn==(void*)l2_path_root_resolve)++roots;
    if(fn==(void*)l2_path_walk_steps_from)++folds;
}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL prepared head150: %s\n",why);}}
static void begin(void){parses=adapters=texts=roots=folds=0;watching=1;}
static void no_reparse(void){watching=0;ck(!parses&&!adapters&&!texts,"retained grammar never re-enters P0/run/text parsers");}
int main(void){
    LmP0Text p={0},word={0};p.data="p";p.length=1;word.data="int";word.length=3;
    LmP0Text *names[]={&p},*method_names[]={NULL};void *input_rows[]={names};
    int ft[]={0},*ft_rows[]={ft},arity[]={1},dynamic[]={0},slots[]={0};LmP0Node *nodes[]={NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="prepared-head150";l2_rw_quiet=1;l2_construct_phase=-1;
    const int ranks[]={1,2,6,65,129};
    for(unsigned k=0;k<sizeof ranks/sizeof ranks[0];++k)for(int qualified=0;qualified<2;++qualified){
        int rank=ranks[k];ft[0]=l2_foreign_intern_parts(&word,rank,qualified,0);int original=ft[0];
        char source[2048];strcpy(source,"p");for(int i=0;i<rank;++i)strcat(source,"[0]");strcat(source,": 7\n");
        LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;int status;
        L2HeadExpression *head=l2_head_expression(stmt,&status);if(!head||status)abort();
        ck(head->path_status==0&&head->prepared.n==rank&&head->prepared.indexed==rank,"one cached whole grammar at arbitrary rank");
        L2Path path;begin();status=l2_path_resolve_head(stmt,&path);no_reparse();
        ck(status==0&&roots==1&&folds==1,"one root and one semantic fold of retained grammar");
        ck(path.fi==0&&path.n==rank&&path.indexed==rank&&path.run_count==head->prepared.run_count,"selected formal and complete geometry retained");
        ck(l2_path_rec_leaf_ft(&path)==0,"exact int leaf type is a value,not missing type");
        for(int i=0;i<rank;++i){
            LmP0Text base;int depth=-1,c=-1;L2PathStep *step=path.steps+i;
            ck(step->locus==7&&step->address_ft>=0&&l2_type_parts(l2_formal_raw(step->address_ft),&base,&depth,&c)==0&&l2_text_eq(&base,"int")&&depth==rank-i&&c==qualified,"every step retains consumed type and qualification");
        }
        ck(path.steps[rank-1].cell_const==qualified,"selected final cell preserves write qualification");
        ft[0]=0;
        ck(l2_path_rec_leaf_ft(&path)==0&&path.steps[0].address_ft==original,"held completed verdict survives later source-table change");
        l2_path_release(&path);
        begin();status=l2_path_resolve_head(stmt,&path);no_reparse();
        ck(status!=0&&roots==1,"new query sees current non-pointer contract,not a stale semantic cache");
        l2_path_release(&path);ft[0]=original;
        l2_application_free();lm_p0_document_destroy(doc);
    }
    const char *misses[]={"p[0]+1: 7\n","p\\missing: 7\n"};
    ft[0]=l2_foreign_intern_parts(&word,1,0,0);
    for(int k=0;k<2;++k){
        LmP0Document *doc=NULL;if(lm_p0_parse_bytes(misses[k],strlen(misses[k]),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;int status;
        L2HeadExpression *head=l2_head_expression(stmt,&status);if(!head||status)abort();
        L2Path path;begin();status=l2_path_resolve_head(stmt,&path);no_reparse();
        ck(k?status==-1:status==2,"semantic refusal and incomplete head stay distinct");
        ck(roots==(k?1:0),"grammar miss never starts a root lookup or text fallback");
        l2_path_release(&path);l2_application_free();lm_p0_document_destroy(doc);
    }
    printf("prepared heads: %d checks, %d failures\n",checks,failures);return failures!=0;
}
