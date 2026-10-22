#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main check153_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,adapters,roots,folds,bindings,constants;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
    (void)site;if(!watching)return;
    if(fn==(void*)l2_path_steps_operand)++adapters;
    if(fn==(void*)l2_path_root_resolve)++roots;
    if(fn==(void*)l2_path_walk_steps_from)++folds;
    if(fn==(void*)l2_define_name)++constants;
    if(fn==(void*)l2_param_find||fn==(void*)l2_resolved_own||fn==(void*)l2_slot_find||fn==(void*)l2_ml_find||fn==(void*)l2_ns_find_payload)++bindings;
}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL CHECK153: %s\n",why);}}
static void begin(void){adapters=roots=folds=bindings=constants=0;watching=1;}
int main(int argc,char **argv){
    (void)argc;(void)argv;
    LmP0Text p={0},word={0};p.data="p";p.length=1;word.data="int";word.length=3;
    LmP0Text *names[]={&p},*method_names[]={NULL,NULL};void *input_rows[]={names,names};
    int ft0[]={0},ft1[]={0},*ft_rows[]={ft0,ft1},arity[]={1,1},dynamic[]={0,0},slots[]={0,0};LmP0Node *nodes[]={NULL,NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=2;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="check153";l2_rw_quiet=1;l2_construct_phase=-1;
    const int ranks[]={1,2,6,65,129};
    for(unsigned k=0;k<sizeof ranks/sizeof ranks[0];++k)for(int qualified=0;qualified<2;++qualified)for(int prefix=0;prefix<2;++prefix){
        int rank=ranks[k],n=0,count;
        ft0[0]=l2_foreign_intern_parts(&word,rank,qualified,0);ft1[0]=ft0[0];int original=ft0[0];
        /* Compilation-owned type interning is not operand ownership. */
        for(int depth=1;depth<=rank;++depth)l2_foreign_intern_parts(&word,depth,qualified,0);
        char source[2048];strcpy(source,prefix?"return: - p":"return: p");for(int i=0;i<rank;++i)strcat(source,"[0]");strcat(source," + 2\n");
        LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        LmP0Field *first=stmt->as->frame->body->first_field;count=l2_count_active(stmt->as->frame->body);
        size_t live=l2_alloc_live;
        begin();int status=l2_check_fields(first,count,0,l2_src,stmt);watching=0;
        ck(!status,"whole CHECK accepts the unchanged arbitrary-rank numeric path");
        printf("CHECK153 rank=%d const=%d prefix=%d status=%d adapters=%d roots=%d folds=%d bindings=%d\n",rank,qualified,prefix,status,adapters,roots,folds,bindings);
        l2_bound_free();l2_application_free();
        printf("CHECK153 lifetime before=%zu after=%d foreign=%d\n",live,l2_alloc_live,l2_foreign_n);
        ck(l2_alloc_live==live,"CHECK operand, bound-use and application-contract owners all release exactly");
#ifdef CHECK153_CURRENT
        L2ValueSpan *tok=l2_value_fields(first,count,&n);if(!tok||n!=3)abort();
        L2ValueSpan *leaf=prefix?tok->operand:tok;
        ck(!l2_check_prepared_kinds(tok,n,0,l2_src,stmt),"kind check consumes already prepared operands");
        ft0[0]=0;
        begin();status=l2_check_value_span(leaf,0,l2_src,stmt);watching=0;
        ck(!status&&!roots&&!folds&&!bindings,"CHECK keeps a held result after source-table poison without another binding/fold");
        ck(leaf->prepared->n==rank&&leaf->prepared->steps[0].address_ft==original,"CHECK does not cut or relabel the common record");
        printf("CHECK153 held rank=%d independent-index-adapters=%d roots=%d folds=%d bindings=%d\n",rank,adapters,roots,folds,bindings);
        ft0[0]=original;l2_value_spans_release(tok,n);l2_bound_free();l2_application_free();
        ck(l2_alloc_live==live,"borrowed CHECK and type uses preserve one balanced owner");
#endif
        lm_p0_document_destroy(doc);l2_application_free();
    }
#ifdef CHECK153_CURRENT
    {
        const char *source="define: SYMBOL 73\nreturn: SYMBOL\n";LmP0Document *doc=NULL;
        if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Field *definition=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field);
        LmP0Node *definitions[]={definition->value};
        l2_def=definitions;l2_def_n=1;
        LmP0Node *stmt=l2_next_active(definition->next)->value;int n=0;
        L2ValueSpan *tok=l2_value_fields(stmt->as->frame->body->first_field,1,&n);if(!tok||n!=1)abort();
        L2Path *held=NULL;begin();int status=l2_value_span_path(tok,0,&held);watching=0;
        ck(!status&&held&&held->root_kind==6&&roots==1&&constants==1,"common root selection records declared external constant role once");
        l2_def_n=0;
        begin();status=l2_check_value_span(tok,0,l2_src,stmt);watching=0;
        ck(!status&&!roots&&!folds&&!bindings&&!constants,"held CHECK uses the selected constant role after declaration-table poison");
        char data[128];L2Tx dest={0};if(l2_tx_open(&dest,data,sizeof data))abort();
        begin();status=l2_emit_prepared_value(tok,0,"",&dest,NULL);watching=0;
        ck(!status&&!strcmp(dest.data,"SYMBOL")&&!roots&&!folds&&!bindings&&!constants,"native constant projection uses its held source identity without reclassification");
        int emitted=-1,saved_temp=l2_rw_t;l2_rw_t=0;l2_rw_emit=0;l2_rw_machine=0;
        begin();status=l2_rw_prepared_value(tok,0,&emitted);watching=0;int count_end=l2_rw_t;
        ck(!status&&l2_rw_machine&&!roots&&!folds&&!bindings&&!constants,"retained COUNT projects the held native-only constant without another search");
        FILE *saved_output=l2_out;if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();l2_rw_t=0;l2_rw_emit=1;l2_rw_machine=0;
        begin();status=l2_rw_prepared_value(tok,0,&emitted);watching=0;
        ck(!status&&l2_rw_machine&&l2_rw_t==count_end&&!roots&&!folds&&!bindings&&!constants,"retained EMIT uses the same selected constant and COUNT geometry without another search");
        fclose(l2_out);l2_out=saved_output;l2_rw_emit=0;l2_rw_t=saved_temp;
        L2Address address;begin();status=l2_address_span(tok,0,&address);watching=0;
        ck(status&&!roots&&!folds&&!bindings&&!constants,"a selected external constant has no invented addressable L2 cell");
        int fresh_n=0;L2ValueSpan *fresh=l2_value_fields(stmt->as->frame->body->first_field,1,&fresh_n);if(!fresh)abort();
        begin();status=l2_value_span_path(fresh,0,&held);watching=0;
        ck(status==2&&roots==1&&constants==1,"an independent current query sees the removed declaration,not an ancestor cache");
        l2_value_spans_release(fresh,fresh_n);l2_value_spans_release(tok,n);
        l2_def=NULL;l2_def_n=0;l2_bound_free();l2_application_free();lm_p0_document_destroy(doc);
    }
    {
        const char *source="return: p p\n";LmP0Document *doc=NULL;int n=0;
        ft0[0]=0;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        size_t live=l2_alloc_live;
        L2ValueSpan *tok=l2_value_fields(stmt->as->frame->body->first_field,2,&n);
        ck(tok&&n==2&&!l2_value_spans_expression(tok,n),"a foreign value list keeps prepared values without inventing a binary expression");
        L2ValueSpan borrowed;l2_value_span_ref(&borrowed,stmt->as->frame->body->first_field,1);
        begin();int refused=l2_check_value_span(&borrowed,0,l2_src,stmt);watching=0;
        ck(refused&&!roots&&!folds&&!adapters,"an unprepared borrowed operand cannot masquerade as an operator or trigger a fallback");
        ck(!l2_check_prepared_kinds(tok,n,0,l2_src,stmt),"nonbinary receiving role does not discard operand ownership");
        begin();int status=l2_check_value_span(tok,0,l2_src,stmt);status|=l2_check_value_span(tok+1,0,l2_src,stmt);watching=0;
        ck(!status&&roots==2,"independent written operands each resolve their own current use once");
        l2_value_spans_release(tok,n);l2_bound_free();l2_application_free();ck(l2_alloc_live==live,"nonbinary, bound-use and application owners release all records");
        lm_p0_document_destroy(doc);l2_application_free();
    }
    {
        const char *source="return: p[0] + 2\n";LmP0Document *doc=NULL;
        ft0[0]=l2_foreign_intern_parts(&word,1,0,0);
        if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        LmP0Field *first=stmt->as->frame->body->first_field;int count=l2_count_active(stmt->as->frame->body);
        size_t live=l2_alloc_live,before=l2_alloc_n;
        int status=l2_check_fields(first,count,0,l2_src,stmt);
        size_t sites=l2_alloc_n-before;l2_bound_free();l2_application_free();
        ck(!status&&sites>0&&sites<128&&l2_alloc_live==live,"measure all CHECK allocation sites with the actual enclosing owners");
        for(size_t point=1;point<=sites;++point){
            l2_fail_left=(int)point;l2_alloc_err=0;
            status=l2_check_fields(first,count,0,l2_src,stmt);
            ck(status!=0&&l2_alloc_err&&l2_fail_left==0,"every measured CHECK allocation refusal is a terminal refusal,not another parser route");
            l2_bound_free();l2_application_free();
            ck(l2_alloc_live==live,"every partial CHECK/list/path/bound record releases with its original owner");
            l2_fail_left=0;l2_alloc_err=0;
        }
        printf("CHECK153 allocation sites=%zu\n",sites);
        lm_p0_document_destroy(doc);
    }
#endif
    printf("CHECK153: %d checks, %d failures\n",checks,failures);return failures!=0;
}
