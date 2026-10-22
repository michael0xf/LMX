#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main operands151_frontend_main
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
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL owned operand151: %s\n",why);}}
static void begin(void){adapters=roots=folds=0;watching=1;}
int main(void){
    LmP0Text p={0},word={0},other={0};p.data="p";p.length=1;word.data="int";word.length=3;other.data="unsigned";other.length=8;
    LmP0Text *names[]={&p},*method_names[]={NULL,NULL};void *input_rows[]={names,names};
    int ft0[]={0},ft1[]={0},*ft_rows[]={ft0,ft1},arity[]={1,1},dynamic[]={0,0},slots[]={0,0};LmP0Node *nodes[]={NULL,NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=2;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="owned-operands151";l2_rw_quiet=1;l2_construct_phase=-1;
    const int ranks[]={1,2,6,65,129};
    for(unsigned k=0;k<sizeof ranks/sizeof ranks[0];++k)for(int qualified=0;qualified<2;++qualified)for(int prefix=0;prefix<2;++prefix){
        int rank=ranks[k],m=0,exact=-1;
        ft0[0]=l2_foreign_intern_parts(&word,rank,qualified,0);ft1[0]=l2_foreign_intern_parts(&other,rank,qualified,0);int original=ft0[0];
        char source[2048];strcpy(source,prefix?"return: - p":"return: p");for(int i=0;i<rank;++i)strcat(source,"[0]");strcat(source," + 2\n");
        LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        LmP0Field *first=stmt->as->frame->body->first_field;
        L2ValueSpan *tok=l2_value_spans(first,l2_count_active(stmt->as->frame->body),&m);if(!tok||m!=3)abort();
        L2ValueSpan *leaf=prefix?tok->operand:tok;
        ck(leaf&&leaf->grammar==1&&leaf->prepared&&leaf->prepared->n==rank,"whole arbitrary-rank grammar belongs to this operand");
        begin();int kind=l2_value_expr_type(tok,0,m-1,0,&exact);watching=0;
        ck(kind==0&&exact==0,"native kind and exact result come from held int path");
        ck(!adapters&&roots==1&&folds==1,"first type use walks prepared grammar once without parsing");
        begin();int retained=l2_rw_tyof(tok,0,m-1);watching=0;
        ck(retained==0&&!adapters&&!roots&&!folds,"retained type projects the SAME completed result");
        L2Path *held=NULL;begin();int status=l2_value_span_path(leaf,0,&held);watching=0;
        ck(!status&&held==leaf->prepared&&!adapters&&!roots&&!folds,"another consumer borrows result without a second search");
        ck(held->steps[0].address_ft==original&&held->steps[rank-1].cell_const==qualified,"per-step consumed contract and qualification remain held");
        ft0[0]=0;exact=-1;begin();kind=l2_value_expr_type(tok,0,m-1,0,&exact);watching=0;
        ck(kind==0&&exact==0&&!adapters&&!roots&&!folds&&held->steps[0].address_ft==original,"source-table poison cannot relabel this held verdict");
        int fresh_n=0;L2ValueSpan *fresh=l2_value_spans(first,l2_count_active(stmt->as->frame->body),&fresh_n);if(!fresh)abort();
        exact=-1;begin();kind=l2_value_expr_type(fresh,0,fresh_n-1,0,&exact);watching=0;
        ck(kind==-99&&!adapters&&roots==1,"independent new use sees current incompatible contract,not a stale cache");
        l2_value_spans_release(fresh,fresh_n);ft0[0]=original;
        begin();status=l2_value_span_path(leaf,1,&held);watching=0;
        ck(!status&&!adapters&&roots==1&&folds==1,"different method gets fresh verdict from same prepared grammar");
        ck(l2_path_rec_leaf_ft(held)==34&&held->steps[0].address_ft==ft1[0]&&leaf->prepared->value_method==1,"method context does not inherit old type/map fields");
        l2_value_spans_release(tok,m);l2_application_free();lm_p0_document_destroy(doc);
    }
    ft0[0]=l2_foreign_intern_parts(&word,1,0,0);
    for(int prefix=0;prefix<2;++prefix){
        const char *source=prefix?"return: @ p\n":"return: p + 1\n";LmP0Document *doc=NULL;int n=0;
        if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        L2ValueSpan *tok=l2_value_spans(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&n);if(!tok)abort();
        L2ValueSpan *leaf=prefix?tok->operand:tok;L2Path *held=NULL;begin();int status=l2_value_span_path(leaf,0,&held);watching=0;
        ck(!status&&!adapters&&roots==1&&folds==0&&held->n==0&&l2_path_rec_leaf_ft(held)==ft0[0],"zero-step and prefix child retain ordinary complete root contract");
        L2Path view;ck(!l2_path_record_view(held,&view)&&view.n==0&&view.leaf_ty==held->leaf_ty,"zero-step record view needs no fictitious step allocation");
        l2_path_release(&view);l2_value_spans_release(tok,n);l2_application_free();lm_p0_document_destroy(doc);
    }
    {
        const char *source="return: - p[0] + p[0]\n";LmP0Document *doc=NULL;
        if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        LmP0Field *first=stmt->as->frame->body->first_field;int count=l2_count_active(stmt->as->frame->body),n=0;
        size_t before=l2_alloc_n,live=l2_alloc_live;
        L2ValueSpan *tok=l2_value_spans(first,count,&n);if(!tok)abort();
        size_t sites=l2_alloc_n-before;
        ck(sites>0&&sites<128,"bounded fixture measures actual constructor allocation sites");
        l2_value_spans_release(tok,n);
        ck(l2_alloc_live==live,"complete recursive release balances all owned grammar allocations");
        for(size_t point=1;point<=sites;++point){
            l2_fail_left=(int)point;l2_alloc_err=0;n=0;
            tok=l2_value_spans(first,count,&n);
            ck(!tok&&l2_alloc_err&&l2_fail_left==0,"each actual constructor allocation may refuse without a partial result");
            if(tok)l2_value_spans_release(tok,n);
            ck(l2_alloc_live==live,"each partial prefix/path/token construction releases its complete owned subtree");
            l2_fail_left=0;l2_alloc_err=0;
        }
        ft0[0]=l2_foreign_intern_parts(&word,1,0,0);live=l2_alloc_live;
        tok=l2_value_spans(first,count,&n);if(!tok||!tok->operand)abort();
        L2Path *held=NULL;l2_fail_left=1;l2_alloc_err=0;
        begin();int status=l2_value_span_path(tok->operand,0,&held);watching=0;
        ck(status==3&&l2_alloc_err&&!adapters&&!roots&&!folds,"view allocation refusal cannot retry a parser or semantic root");
        l2_fail_left=0;l2_alloc_err=0;
        begin();status=l2_value_span_path(tok->operand,0,&held);watching=0;
        ck(status==2&&!adapters&&!roots&&!folds,"held refusal remains authoritative rather than becoming a fallback query");
        l2_value_spans_release(tok,n);
        ck(l2_alloc_live==live,"allocation-refused semantic view preserves one releasable owned grammar");
        lm_p0_document_destroy(doc);l2_application_free();
    }
    printf("owned operand records: %d checks, %d failures\n",checks,failures);return failures!=0;
}
