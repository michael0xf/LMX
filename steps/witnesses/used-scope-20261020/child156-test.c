#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main child156_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,adapters,roots,folds;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
    (void)site;if(!watching)return;
    if(fn==(void*)l2_path_steps_operand)++adapters;
    if(fn==(void*)l2_path_root_resolve)++roots;
    if(fn==(void*)l2_path_walk_steps_from)++folds;
}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL CHILD156: %s\n",why);}}
static void begin(void){adapters=roots=folds=0;watching=1;}
static void owners(void){
    l2_bound_free();l2_application_free();l2_indent_free();l2_expr_sites_free();l2_graph_places_free();
    for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);
    l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;
}
#ifdef CHILD156_CURRENT
static L2Path *held(L2ValueSpan *span){
    if(span->prepared)return span->prepared;
    if(span->operand){L2Path *p=held(span->operand);if(p)return p;}
    for(int i=0;i<span->value_n;++i){L2Path *p=held(span->values+i);if(p)return p;}
    return NULL;
}
#endif
int main(int argc,char **argv){
    if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();
    LmP0Text p={0},q={0},word={0};p.data="p";p.length=1;q.data="q";q.length=1;word.data="int";word.length=3;
    LmP0Text *names[]={&p},*method_names[]={NULL,NULL};void *input_rows[]={names,names};
    int ft0[]={0},ft1[]={0},*ft_rows[]={ft0,ft1},arity[]={1,1},dynamic[]={0,0},slots[]={0,0};LmP0Node *nodes[]={NULL,NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=2;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="child156";l2_rw_quiet=1;l2_construct_phase=-1;
    const int ranks[]={0,1,2,6,65,129};
    for(unsigned k=0;k<sizeof ranks/sizeof ranks[0];++k)for(int qualified=0;qualified<2;++qualified)for(int form=0;form<3;++form){
        int rank=ranks[k],n=0,original=rank?l2_foreign_intern_parts(&word,rank,qualified,0):0;
        ft0[0]=ft1[0]=original;for(int d=1;d<=rank+1;++d)l2_foreign_intern_parts(&word,d,qualified,0);
        char source[2048];strcpy(source,form==0?"return: (p":form==1?"return: -(p":"return: (@: p");
        for(int i=0;i<rank;++i)strcat(source,"[0]");
        strcat(source,form==2?")\n":" + 2) + 3\n");
        LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        L2ValueSpan *tok=l2_value_fields(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&n);if(!tok)abort();
        int exact=-1;begin();int kind=l2_value_span_type(tok,0,&exact);watching=0;
        ck(kind==(form==2?-5:0),"group/sign/address Frame retains unchanged value kind");
        printf("CHILD156 rank=%d const=%d form=%d first adapters=%d roots=%d folds=%d\n",rank,qualified,form,adapters,roots,folds);
#ifdef CHILD156_CURRENT
        L2Path *path=held(tok);if(!path)abort();
        ck(tok->values&&exact>=0&&path->n==rank&&roots==1&&folds==(rank?1:0),"one embedded list owns the arbitrary-rank path and exact first semantic result");
        int stored=exact,geometry=path->n;
        begin();int type=l2_rw_span_ty(tok);watching=0;
        ck(type==l2_own_ty_of_param(stored)&&!roots&&!folds,"retained typing borrows the same child result");
        char data[1024];L2Tx dest={0};if(l2_tx_open(&dest,data,sizeof data))abort();
        names[0]=&q;ft0[0]=rank?0:11;
        begin();kind=l2_value_span_type(tok,0,&exact);int status=l2_emit_native_span(tok,0,"",&dest,NULL);watching=0;
        ck(kind==(form==2?-5:0)&&exact==stored&&!status&&!roots&&!folds&&path->n==geometry,"native/type borrow the child after name+FT poison,not a group/Frame reparse");
        names[0]=&p;ft0[0]=original;
        begin();status=l2_check_value_span(tok,0,l2_src,stmt);watching=0;
        ck(!status&&!roots&&!folds,"CHECK borrows completed embedded paths without reconstructing their lists");
        l2_rw_t=0;l2_rw_emit=0;l2_rw_machine=0;
        begin();int out=-1;status=l2_rw_span(tok,l2_own_ty_of_param(stored),-2,&out);watching=0;
        int count=l2_rw_t,machine=l2_rw_machine;
        ck(!status&&!roots&&!folds,"retained COUNT uses the existing child preparation");
        l2_rw_t=0;l2_rw_emit=1;l2_rw_machine=0;
        begin();status=l2_rw_span(tok,l2_own_ty_of_param(stored),-2,&out);watching=0;
        ck(!status&&l2_rw_t==count&&l2_rw_machine==machine&&!roots&&!folds,"retained EMIT shares child resolution and COUNT geometry");
        l2_rw_emit=0;
#endif
        l2_value_spans_release(tok,n);owners();lm_p0_document_destroy(doc);
    }
#ifdef CHILD156_CURRENT
    {
        const int depths[]={1,4,16,65};
        ft0[0]=l2_foreign_intern_parts(&word,1,0,0);
        for(unsigned k=0;k<sizeof depths/sizeof depths[0];++k){
            int depth=depths[k],n=0;char source[2048];strcpy(source,"return: ");
            for(int i=0;i<depth;++i)strcat(source,"(");
            strcat(source,"p[0]");for(int i=0;i<depth;++i)strcat(source," + 2)");
            strcat(source," + 3\n");
            LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
            LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
            L2ValueSpan *tok=l2_value_fields(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&n);if(!tok)abort();
            int exact=-1;begin();int kind=l2_value_span_type(tok,0,&exact);watching=0;
            ck(kind==0&&exact==0&&roots==1&&folds==1,"deep embedded lists retain one common root/fold,not a fixed parenthesis depth");
            char data[1024];L2Tx dest={0};if(l2_tx_open(&dest,data,sizeof data))abort();
            begin();int status=l2_check_value_span(tok,0,l2_src,stmt);status|=l2_emit_native_span(tok,0,"",&dest,NULL);watching=0;
            ck(!status&&!roots&&!folds,"deep CHECK/native consumers borrow every nested child preparation");
            l2_rw_t=0;l2_rw_emit=0;l2_rw_machine=0;int out=-1;
            begin();status=l2_rw_span(tok,0,-2,&out);watching=0;int count=l2_rw_t;
            ck(!status&&!roots&&!folds,"deep retained COUNT borrows the same recursively owned list");
            l2_rw_t=0;l2_rw_emit=1;l2_rw_machine=0;
            begin();status=l2_rw_span(tok,0,-2,&out);watching=0;
            ck(!status&&l2_rw_t==count&&!roots&&!folds,"deep retained EMIT keeps COUNT geometry without a second child parse");
            l2_rw_emit=0;l2_value_spans_release(tok,n);owners();lm_p0_document_destroy(doc);
            printf("CHILD156 group-depth=%d actual semantic/native/COUNT/EMIT completed\n",depth);
        }
    }
    {
        const char *source="return: ((p[0] + 2) + 3)\n";LmP0Document *doc=NULL;
        ft0[0]=l2_foreign_intern_parts(&word,1,0,0);
        if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        LmP0Field *first=stmt->as->frame->body->first_field;int fields=l2_count_active(stmt->as->frame->body),n=0;
        size_t live=l2_alloc_live,before=l2_alloc_n;
        L2ValueSpan *tok=l2_value_fields(first,fields,&n);size_t sites=l2_alloc_n-before;if(!tok)abort();
        l2_value_spans_release(tok,n);
        ck(sites>0&&sites<128&&l2_alloc_live==live,"measure complete nested child constructor ownership");
        for(size_t point=1;point<=sites;++point){
            l2_fail_left=(int)point;l2_alloc_err=0;tok=l2_value_fields(first,fields,&n);
            ck(!tok&&l2_alloc_err&&l2_fail_left==0,"every nested list/path child allocation refusal is final");
            if(tok)l2_value_spans_release(tok,n);
            ck(l2_alloc_live==live,"partial nested expression owns and releases each child once");
            l2_fail_left=0;l2_alloc_err=0;
        }
        printf("CHILD156 constructor allocation sites=%zu\n",sites);
        lm_p0_document_destroy(doc);
    }
#endif
    fclose(l2_out);l2_out=NULL;
    printf("CHILD156: %d checks, %d failures\n",checks,failures);return failures!=0;
}
