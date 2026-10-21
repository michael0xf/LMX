#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main path142_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks, failures;
static void ck142(int yes,const char *why) {
    ++checks;
    if(!yes) { ++failures; fprintf(stderr,"FAIL common INDEX: %s\n",why); }
}
int main(void) {
    LmP0Text p={0},q={0},word={0}; p.data="p";p.length=1;q.data="q";q.length=1;
    LmP0Text *names[]={&p},*slot_names[]={&p},*machine_names[]={&p},*method_names[]={NULL};
    void *input_rows[]={names}; int ft[]={18},*ft_rows[]={ft},arity[]={1},dynamic[]={0},slots[]={0};
    int slot_type[]={18},machine_type[]={18},machine_model[]={-1},machine_rw[]={7};
    LmP0Node *nodes[]={NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;
    l2_m_sn=slots;l2_sn=slot_names;l2_st=slot_type;l2_m_name=method_names;l2_m_node=l2_m_body=nodes;
    l2_ml_nm=machine_names;l2_ml_ty=machine_type;l2_ml_ns=machine_model;l2_ml_rw=machine_rw;
    l2_src="common-machine-index-test";l2_rw_quiet=1;l2_construct_phase=-1;
    const int ranks[]={1,2,6,65,129};
    for(int binding=0;binding<3;++binding) for(int ri=0;ri<5;++ri) for(int qualified=0;qualified<2;++qualified) {
        int rank=ranks[ri]; char source[2048]; strcpy(source,"p");
        for(int i=0;i<rank;++i) strcat(source,"[0]");strcat(source,": 0\n");
        word.data=qualified?"int":"void";word.length=qualified?3:4;
        int ty=l2_foreign_intern_parts(&word,rank+(qualified?0:1),qualified,0);
        names[0]=slot_names[0]=machine_names[0]=&p;
        ft[0]=slot_type[0]=machine_type[0]=ty;
        arity[0]=binding==0?1:0;slots[0]=binding==1?1:0;l2_ml_n=binding==2?1:0;
        LmP0Document *document=NULL;int status=lm_p0_parse_bytes(source,strlen(source),&document);
        ck142(!status&&document,"actual P0 head parses at every rank");if(status||!document)abort();
        LmP0Node *root=lm_p0_document_mutable_root(document);
        LmP0Node *stmt=l2_next_active(root->as->structure->first_field)->value;
        int head_status; L2HeadExpression *head=l2_head_expression(stmt,&head_status);L2Path path;
        if(!head||head_status||l2_path_prepared_view(&head->prepared,&path))abort();
        status=l2_path_walk(&path);
        ck142(!status&&path.fail_why==0&&path.leaf_kind==13,"COMMON walk resolves,not a backend rescue");
        ck142(path.leaf_ty==(qualified?0:16),"common leaf has the actual scalar/pointer contract");
        ck142(path.n==rank&&path.indexed==rank&&path.names==0&&path.run_count==head->prepared.run_count,"all geometry remains original");
        int step_types=1,address_types=1,spans=1,qualification=1;
        for(int i=0;i<rank;++i) {
            L2PathStep *step=path.steps+i,*grammar=head->prepared.steps+i;
            if(step->cell_ft!=step->elem_ty||step->elem_ty<0||l2_pointer_depth(l2_formal_raw(step->elem_ty))!=rank-i-(qualified?1:0))step_types=0;
#ifdef PATH142_COMMON
            if(step->address_ft<0||l2_pointer_depth(l2_formal_raw(step->address_ft))!=rank-i+(qualified?0:1))address_types=0;
            if(step->cell_const!=(qualified&&i==rank-1))qualification=0;
#else
            address_types=0;qualification=0;
#endif
            if(step->locus!=7||step->index.first!=grammar->index.first||step->index.node!=grammar->index.node||step->index.count!=grammar->index.count)spans=0;
        }
        ck142(step_types,"each consumed type is in the common record");
        ck142(address_types,"each PRE-step address type is in the common record");
        ck142(qualification,"write qualification is resolved per cell,not rederived in native");
        ck142(spans,"all original index AST spans survive semantic resolution");
        ck142(!status&&l2_path_effect_raises(&path,0,0)==0,"physical indexing adds no graph Array failure channel");
        L2Path grammar;
        int cloned=l2_path_prepared_view(&path,&grammar);int cleared=!cloned;
        if(!cloned)for(int i=0;i<rank;++i) {
            if(grammar.steps[i].elem_ty!=-1||grammar.steps[i].cell_ft!=-1)cleared=0;
#ifdef PATH142_COMMON
            if(grammar.steps[i].address_ft!=-1||grammar.steps[i].cell_const!=0)cleared=0;
#endif
        }
        ck142(cleared,"an unresolved grammar view clears ALL old typed verdicts");
        if(!cloned)l2_path_release(&grammar);
        /* Deliberate compiler-table poison AFTER resolution. It does not
           mutate the current source graph or ask to recover an ancestor. */
        names[0]=slot_names[0]=machine_names[0]=&q;ft[0]=slot_type[0]=machine_type[0]=0;
        L2Address place;int projected=l2_raw_index_path(&path,0,&place);
        ck142(!projected,"physical projection consumes ready types,not the now-poisoned type table");
        ck142(!projected&&place.source_type==ty&&place.index==(qualified?0:16),"ready root/leaf contracts survive projection");
        ck142(!projected&&place.type>=0&&place.immutable==qualified,"exact address and write qualifier survive projection");
        ck142(!projected&&place.path.leaf_kind==13&&place.path.fail_why==0&&memcmp(place.path.steps,path.steps,(size_t)rank*sizeof(L2PathStep))==0,"projection copies the full verdict,not only grammar");
        if(!projected)l2_address_release(&place);
        ft[0]=slot_type[0]=machine_type[0]=ty;names[0]=slot_names[0]=machine_names[0]=&p;
        l2_path_release(&path);l2_application_free();lm_p0_document_destroy(document);
    }
    printf("common machine INDEX: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
