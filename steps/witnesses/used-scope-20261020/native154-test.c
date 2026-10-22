#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main native154_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,adapters,roots,folds,bindings,type_depth,type_queries;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
    (void)site;if(!watching)return;
    if(fn==(void*)l2_ptr_type_word)++type_depth;
    if(fn==(void*)l2_path_steps_operand)++adapters;
    if(fn==(void*)l2_path_root_resolve)++roots;
    if(fn==(void*)l2_path_walk_steps_from)++folds;
    if(fn==(void*)l2_param_find||fn==(void*)l2_resolved_own||fn==(void*)l2_slot_find||fn==(void*)l2_ml_find||fn==(void*)l2_ns_find_payload){if(type_depth)++type_queries;else ++bindings;}
}
void __cyg_profile_func_exit(void *fn,void *site){(void)site;if(watching&&fn==(void*)l2_ptr_type_word)--type_depth;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL native154: %s\n",why);}}
static void begin(void){adapters=roots=folds=bindings=type_depth=type_queries=0;watching=1;}
static void owners(void){
    l2_bound_free();l2_application_free();l2_indent_free();
    for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);
    l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;
}
int main(int argc,char **argv){
    if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();
    LmP0Text p={0},word={0},removed={0};p.data="p";p.length=1;word.data="int";word.length=3;removed.data="q";removed.length=1;
    LmP0Text *names[]={&p},*method_names[]={NULL,NULL};void *input_rows[]={names,names};
    int ft0[]={0},ft1[]={0},*ft_rows[]={ft0,ft1},arity[]={1,1},dynamic[]={0,0},slots[]={0,0};LmP0Node *nodes[]={NULL,NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=2;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="native154";l2_rw_quiet=1;l2_construct_phase=-1;
    const int ranks[]={1,2,6,65,129};
    for(unsigned k=0;k<sizeof ranks/sizeof ranks[0];++k)for(int qualified=0;qualified<2;++qualified)for(int prefix=0;prefix<2;++prefix){
        int rank=ranks[k],n=0;
        ft0[0]=l2_foreign_intern_parts(&word,rank,qualified,0);ft1[0]=ft0[0];
        for(int depth=1;depth<=rank+1;++depth)l2_foreign_intern_parts(&word,depth,qualified,0);
        char source[2048];strcpy(source,prefix?"return: - p":"return: p");for(int i=0;i<rank;++i)strcat(source,"[0]");strcat(source," + 2\n");
        LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        LmP0Field *first=stmt->as->frame->body->first_field;int count=l2_count_active(stmt->as->frame->body);
        char data[1024];L2Tx dest={0};if(l2_tx_open(&dest,data,sizeof data))abort();
        begin();int status=l2_emit_fields(first,count,0,"",&dest);watching=0;
        ck(!status,"raw native boundary accepts unchanged arbitrary-rank numeric path");
        printf("NATIVE154 rank=%d const=%d sign=%d status=%d adapters=%d roots=%d folds=%d bindings=%d\n",rank,qualified,prefix,status,adapters,roots,folds,bindings);
#ifdef NATIVE154_CURRENT
        ck(roots==1&&folds==1,"native expression resolves its whole path once,not a whole/names-only retry");
        L2ValueSpan *tok=l2_value_fields(first,count,&n);if(!tok||n!=3)abort();
        ck(!l2_check_prepared_kinds(tok,n,0,l2_src,stmt),"CHECK completes the same native operand list");
        L2ValueSpan *leaf=prefix?tok->operand:tok;L2Path *held=leaf->prepared;
        int geometry=held->n;
        /* Reuse the complete verdict; type-table poisoning of physical roots
           is separately open. Pointer-type spelling queries are separately
           counted,not disguised as source-path rebinding. */
        names[0]=&removed;
        begin();status=l2_emit_native_values(tok,0,n-1,0,"",&dest,NULL);watching=0;
        names[0]=&p;
        printf("NATIVE154 held rank=%d status=%d adapters=%d roots=%d folds=%d path-bindings=%d pointer-type-queries=%d\n",rank,status,adapters,roots,folds,bindings,type_queries);
        ck(!status&&!roots&&!folds&&!bindings,"native uses held root/types/steps without another semantic resolution");
        ck(held->n==geometry&&geometry==rank,"native does not cut or relabel the common record");
        l2_value_spans_release(tok,n);
#endif
        owners();lm_p0_document_destroy(doc);
    }
#ifdef NATIVE154_CURRENT
    {
        const char *source="return: \\ \\ p\n";LmP0Document *doc=NULL;int n=0;
        ft0[0]=l2_foreign_intern_parts(&word,2,0,0);
        if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        L2ValueSpan *tok=l2_value_fields(stmt->as->frame->body->first_field,3,&n);if(!tok||n!=1)abort();
        int exact=-1;begin();int ty=l2_value_span_type(tok,0,&exact);watching=0;
        ck(ty==0&&exact==0&&roots==1,"dereference typing borrows the recursively prepared pointer child");
        char data[1024];L2Tx dest={0};if(l2_tx_open(&dest,data,sizeof data))abort();
        begin();int status=l2_emit_native_span(tok,0,"",&dest,NULL);watching=0;
        ck(!status&&!roots&&!folds&&!bindings&&!adapters,"native dereference projects held child without another adapter/root/fold");
        ft0[0]=0;int fresh_n=0;L2ValueSpan *fresh=l2_value_fields(stmt->as->frame->body->first_field,3,&fresh_n);if(!fresh)abort();
        begin();ty=l2_value_span_type(fresh,0,&exact);watching=0;
        ck(ty==-99&&roots==1,"fresh dereference sees incompatible current type,not an ancestor cache");
        l2_value_spans_release(fresh,fresh_n);l2_value_spans_release(tok,n);owners();lm_p0_document_destroy(doc);
    }
    {
        const char *source="return: p[0] + 2\n";LmP0Document *doc=NULL;
        ft0[0]=l2_foreign_intern_parts(&word,1,0,0);
        if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        LmP0Field *first=stmt->as->frame->body->first_field;int count=l2_count_active(stmt->as->frame->body);
        owners();size_t live=l2_alloc_live,before=l2_alloc_n;
        char data[1024];L2Tx dest={0};if(l2_tx_open(&dest,data,sizeof data))abort();
        int status=l2_emit_fields(first,count,0,"",&dest);size_t sites=l2_alloc_n-before;owners();
        ck(!status&&sites>0&&sites<128&&l2_alloc_live==live,"native emission owners release the measured successful lifetime");
        for(size_t point=1;point<=sites;++point){
            l2_fail_left=(int)point;l2_alloc_err=0;
            status=l2_emit_fields(first,count,0,"",&dest);
            ck(status&&l2_alloc_err&&l2_fail_left==0,"each measured native allocation refusal is final,not a fallback route");
            owners();ck(l2_alloc_live==live,"each partial native operand/projector/tx owner releases exactly");
            l2_fail_left=0;l2_alloc_err=0;
        }
        printf("NATIVE154 allocation sites=%zu\n",sites);lm_p0_document_destroy(doc);
    }
#endif
    fclose(l2_out);l2_out=NULL;
    printf("NATIVE154: %d checks, %d failures\n",checks,failures);return failures!=0;
}
